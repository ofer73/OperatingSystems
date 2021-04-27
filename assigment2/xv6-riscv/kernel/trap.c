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
  else if((which_dev = devintr()) != 0)
  {
    // ok
  }

  else {
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
  while (((p->pending_signals&1<<SIGCONT)==0)&&!(p->pending_signals&1<<SIGKILL))
  {
    // printf("in handle stop, yielding pid=%d \n",p->pid);//TODO delete
    yield();
  }
  if(p->pending_signals&1<<SIGKILL)
    p->killed=1;
  p->frozen=0;
}


void 
check_pending_signals(struct proc* p){
  for(int sig_num=0;sig_num<32;sig_num++){
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
      // printf("at pending pid=%d signum=%d\n",p->pid,sig_num);
      struct sigaction act;
      act.sa_handler = p->signal_handlers[sig_num];
      act.sigmask = p->handlers_sigmasks[sig_num];

      if(act.sa_handler == (void*)SIG_DFL){
        // printf("at handler DFL signum=%d\n",sig_num);
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
            // printf("pid = %d handeled kill signal",p->pid);//TODO delete
            acquire(&p->lock);
            p->killed = 1;
            release(&p->lock);
        }
      }
      else if(act.sa_handler==(void*)SIGKILL){
        p->killed=1;
      }else if(act.sa_handler==(void*)SIGSTOP){
        handle_stop(p);
      }      
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
        // Its a user signal handler


        int original_mask = p->signal_mask;
        // handle_user_signal(p, sig_num);

        p->handling_user_sig_flag = 1;

        //backup mask, and change the process mask to handler mask 
        p->signal_mask_backup = p->signal_mask;
        p->signal_mask= p->handlers_sigmasks[sig_num];
        
        //copy current trapframe into the user stack for later use
        p->trapframe->sp -= sizeof(struct trapframe);
        p->user_trapframe_backup = (struct trapframe* )(p->trapframe->sp);
        copyout(p->pagetable, (uint64)p->user_trapframe_backup, (char *)p->trapframe, sizeof(struct trapframe));

        // inject the call to sigret to user stack
        uint64 size = (uint64)&end_sigret - (uint64)&call_sigret;
        p->trapframe->sp -= size;
        copyout(p->pagetable, (uint64)p->trapframe->sp, (char *)&call_sigret, size);
      
        // arg0 = signum
        p->trapframe->a0 = sig_num;
        
        // user return address from the user handler will be th .asm code on the user stack
        p->trapframe->ra = p->trapframe->sp;
          
        // Change user program counter to point at the signal handler
        p->trapframe->epc = (uint64)p->signal_handlers[sig_num];
        
        //turn off pending signal
        turn_off_bit(p, sig_num);

        return;
      }

      turn_off_bit(p, sig_num);            
    }
  }
}
void 
handle_user_signal(struct proc* p, int signum){//TODO delete this functiion
 
  p->handling_user_sig_flag = 1;

  //backup mask, and change the process mask to handler mask 
  p->signal_mask_backup = p->signal_mask;
  p->signal_mask= p->handlers_sigmasks[signum];
  
  //copy current trapframe into the user stack for later use
  p->trapframe->sp -= sizeof(struct trapframe);
  p->user_trapframe_backup = (struct trapframe* )(p->trapframe->sp);
  copyout(p->pagetable, (uint64)p->trapframe, (char *)p->trapframe, sizeof(struct trapframe));

  // inject the call to sigret to user stack
  uint64 size = (uint64)&end_sigret - (uint64)&call_sigret;
  p->trapframe->sp -= size;
  copyout(p->pagetable, (uint64)p->trapframe->sp, (char *)&call_sigret, size);
 
  // arg0 = signum
  p->trapframe->a0 = signum;
  
  // user return address from the user handler will be th .asm code on the user stack
  p->trapframe->ra = p->trapframe->sp;
    
  // Change user program counter to point at the signal handler
  p->trapframe->epc = (uint64)p->signal_handlers[signum];
  
  //turn off pending signal
  turn_off_bit(p, signum);
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