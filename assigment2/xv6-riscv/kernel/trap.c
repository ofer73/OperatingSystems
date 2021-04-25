#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

extern void* call_sigret;
extern void* end_sigret;

struct spinlock tickslock;
uint ticks;

extern char trampoline[], uservec[], userret[];

// in kernelvec.S, calls kerneltrap().
void kernelvec();

extern int devintr();

void
trapinit(void)
{
  initlock(&tickslock, "time");
}

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
  w_stvec((uint64)kernelvec);
}

//
// handle an interrupt, exception, or system call from user space.
// called from trampoline.S
//
void
usertrap(void)
{
  int which_dev = 0;

  if((r_sstatus() & SSTATUS_SPP) != 0)
    panic("usertrap: not from user mode");

  // send interrupts and exceptions to kerneltrap(),
  // since we're now in the kernel.
  w_stvec((uint64)kernelvec);

  struct proc *p = myproc();
  
  // save user program counter.
  p->trapframe->epc = r_sepc();
  
  
  if(r_scause() == 8){
    // system call

    if(p->killed==1)
      exit(-1);

    // sepc points to the ecall instruction,
    // but we want to return to the next instruction.
    p->trapframe->epc += 4;

    // an interrupt will change sstatus &c registers,
    // so don't enable until done with those registers.
    intr_on();

    syscall();
  } 
  else if((which_dev = devintr()) != 0){
    // ok
  } else {
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    p->killed = 1;
  }

  // give up the CPU if this is a timer interrupt.
  if(which_dev == 2)
    yield();

  //before returning to user space, check pending signals
  check_pending_signals(p);

  if(p->killed==1)
    exit(-1);


  usertrapret();
}
void
handle_stop(struct proc* p){
  p->frozen=1;
  while ((p->pending_signals&1<<SIGCONT)==0)
  {
    // printf("in handle stop, yielding pid=%d \n",p->pid);//TODO delete
    yield();
  }  
  p->frozen=0;
}
void 
check_pending_signals(struct proc* p){
  // printf("proc %d start check\n",p->pid);//TODO delete

  
  
  for(int sig_num=0;sig_num<32;sig_num++){
    // printf("are we locking? %d pid=%d i=%d\n",holding(&p->lock),p->pid,sig_num);
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
      struct sigaction act = p->signal_handlers[sig_num];
      if(act.sa_handler == (void*)SIG_DFL){
        switch (sig_num)
        {          
          case SIGSTOP:
              handle_stop(p);
            break;
          case SIGCONT:    
            // printf("handle sigcont pid=%d\n",p->pid); //TODO delete
            p->frozen = 0;
            break;
          default://case DFL or SIGKILL
            if(act.sa_handler == (void*)SIG_DFL){
              // printf("trying to lock at handle kill\n");//TODO delete
              acquire(&p->lock);
              p->killed = 1;
              release(&p->lock);

              // printf("pid = %d handeled kill signal",p->pid);//TODO delete
            }
        }
      }
      //TODO::::::::::::::::::::::::::::::::::::::::::::;user may change signal handler to be SIGCONT or SIGSTOP
      else if(act.sa_handler != (void*)SIG_IGN){ 
        // Its a user signal handler
        int original_mask = p->signal_mask;
        backup_trapframe(p->user_trapframe_backup, p->trapframe);
        handle_user_signal(p, sig_num);
        
        p->signal_mask = original_mask;
      }
      //turn off pending signal signum
      p->pending_signals^=1<<sig_num;
    }
  }
    // printf("proc %d finish check\n",p->pid);//TODO delete

}
void 
handle_user_signal(struct proc* p,int signum){
  // p-> signal_mask=p->signal_handlers[signum].sigmask;
  // p->trapframe->a0=signum;                                //store argument in a0
  // //inject sigret as the return value
  // int f_size=(uint)&end_sigret - (uint)&call_sigret;      // size of sigret function
  // p->trapframe->sp-=f_size;                               // make space for return func
  // memmove((void*)p->trapframe->sp, &call_sigret, f_size); // put the function in the user stack
  // p->trapframe->ra = p->trapframe->sp;                    // set the return address to the code calling sigret
  // p->trapframe->epc=(uint)p->signal_handlers[signum].sa_handler;

  usertrapret();
}

///TODO delete:
// //reffffffffffff
// uint tmp_backup = p->signal_mask;         // switching to user handle mask 
// p->signal_mask = p->signal_handlers[i].sigmask;
// p->mask_backup = tmp_backup;     // backup will be restored back in sigret
// if((mask & p->signal_mask) == 0){   // check that the signal is not blocked
//   //set flag to block signals when executing user handler
//   p->userHandlerOn = 1;
//   //backup trapframe
//   backup_tf(p);
//   //inject sigret syscall
//   p->tf->esp -= compiledFuncSize;   // save memory on stack for sigret function (starting at esp)
//   memmove((void*)p->tf->esp, &start_sigret, compiledFuncSize); //copy compiled function to esp
//   *((int*)(p->tf->esp - 4)) = i;    // push signum argument for user handler call
//   *((int*)(p->tf->esp - 8)) = p->tf->esp; // push return address of compiled sigret function
//   p->tf->esp -= 8;                        // lower esp after args + return address
//   p->tf->eip = (uint)sa_handler;          //change instruction pointer field in tf to user handler
//   p->pending_signals = p->pending_signals ^ mask;     //set bit of signal off (userHandlerOn is already on)
// //end refffffffffffffffffffffffffffffffffffffffffffffffff

// void handleUserSignal(struct proc* p,int signum){
//     //put tf on stack
//     uint esp = p->tf->esp - sizeof(struct trapframe);       //save space for tf
//     p->usrTFbackup = (struct trapframe*)esp;                
//     copyTF(p->usrTFbackup,p->tf);                           //put tf in backup
//     p->tf->esp = esp;                                       //move sp
//     p->tf->eip = (uint)(p->sigHandlers[signum]);            //move ip to handler()
//     uint funcSize = sigRetCallEnd-sigRetCall;
//     p->tf->esp = p->tf->esp-funcSize;                       //save space for the sigret asm call
//     memmove((void*)(p->tf->esp),sigRetCall,funcSize);       //put sigret asm call on stack
//     void* sigFunc = (void*)p->tf->esp; //address to function on stack-> keep sigret asm code in sigFunc
//     while(p->tf->esp--%4!=0);                               //align 4 
//     p->tf->esp = p->tf->esp-4;                               //place for arg1
//     memmove((void*)(p->tf->esp),&signum,4);                 //put arg1 on stack
//     p->tf->esp = p->tf->esp-4;                              //place for arg2
//     memmove((void*)(p->tf->esp),&sigFunc,4);                //put arg2 on stack
//     turnOffBit(signum,p);                                    //
//     p->handlingSignal=1;
//     return;                                                 
// }

void
backup_trapframe(struct trapframe *trap_frame_backup, struct trapframe *user_trap_frame){
  memmove(trap_frame_backup, user_trap_frame, sizeof(struct trapframe));
}

//
// return to user space
//
void
usertrapret(void)
{
  struct proc *p = myproc();

  // we're about to switch the destination of traps from
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
  p->trapframe->kernel_trap = (uint64)usertrap;
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()

  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
  x |= SSTATUS_SPIE; // enable interrupts in user mode
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
}

// interrupts and exceptions from kernel code go here via kernelvec,
// on whatever the current kernel stack is.
void 
kerneltrap()
{
  int which_dev = 0;
  uint64 sepc = r_sepc();
  uint64 sstatus = r_sstatus();
  uint64 scause = r_scause();
  
  if((sstatus & SSTATUS_SPP) == 0)
    panic("kerneltrap: not from supervisor mode");
  if(intr_get() != 0)
    panic("kerneltrap: interrupts enabled");

  if((which_dev = devintr()) == 0){
    printf("scause %p\n", scause);
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    panic("kerneltrap");
  }

  // give up the CPU if this is a timer interrupt.
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    yield();

  // the yield() may have caused some traps to occur,
  // so restore trap registers for use by kernelvec.S's sepc instruction.
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void
clockintr()
{
  acquire(&tickslock);
  ticks++;
  wakeup(&ticks);
  release(&tickslock);
}

// check if it's an external interrupt or software interrupt,
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
     (scause & 0xff) == 9){
    // this is a supervisor external interrupt, via PLIC.

    // irq indicates which device interrupted.
    int irq = plic_claim();

    if(irq == UART0_IRQ){
      uartintr();
    } else if(irq == VIRTIO0_IRQ){
      virtio_disk_intr();
    } else if(irq){
      printf("unexpected interrupt irq=%d\n", irq);
    }

    // the PLIC allows each device to raise at most one
    // interrupt at a time; tell the PLIC the device is
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    // software interrupt from a machine-mode timer interrupt,
    // forwarded by timervec in kernelvec.S.

    if(cpuid() == 0){
      clockintr();
    }
    
    // acknowledge the software interrupt by clearing
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
  }
}


// void turnOffPending(int bit,struct proc* p){
//   int operand = 1;
//   operand<<=bit;
//   operand = ~operand;
//   int pending = p->pending_signals;
//   p->pending_signals&=pending;
// }