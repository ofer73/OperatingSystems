#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

struct cpu cpus[NCPU];

struct proc proc[NPROC];

struct proc *initproc;

int nextpid = 1;
struct spinlock pid_lock;

int nexttid = 1;
struct spinlock tid_lock;

extern void forkret(void);
static void freeproc(struct proc *p);
//

extern char trampoline[]; // trampoline.S

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
  struct proc *p;
  struct kthread *t;

  for(p = proc; p < &proc[NPROC]; p++) {
    int proc_index= (int)(p-proc);
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      int thread_index = (int)(t-p->kthreads);
      uint64 va = KSTACK( proc_index * NTHREAD + thread_index);
      kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    }
  }
}

// initialize the proc table at boot time.
void
procinit(void)
{
  struct proc *p;
  struct kthread *t;
  
  initlock(&pid_lock, "nextpid");
  initlock(&tid_lock,"nexttid");
  initlock(&wait_lock, "wait_lock");
  for(p = proc; p < &proc[NPROC]; p++) {      
      initlock(&p->lock, "proc");
      // p->kstack = KSTACK((int) (p - proc));
      int proc_index= (int)(p-proc);
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
        initlock(&t->lock, "thread");
        int thread_index = (int)(t-p->kthreads);
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
      }
  }
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}//

struct kthread*
mykthread(void){
  push_off();
  struct cpu *c = mycpu();
  struct kthread *t=c->kthread;
  pop_off();
  return t;  
}

int
allocpid() {
  int pid;
  
  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}
int
alloctid() {
  int tid;
  
  acquire(&tid_lock);
  tid = nexttid;
  nexttid = nexttid + 1;
  release(&tid_lock);

  return tid;
}
// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock , t[0]->lock held (in this order).
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    acquire(&p->lock);
    if(p->state == UNUSED) {
      goto found;
    } else {
      release(&p->lock);
    }
  }
  // FORKBOMB
  return 0;

found:
  p->pid = allocpid();
  p->state = USED;

    // Allocate a trapframe page.
  if((p->threads_tf_start =kalloc()) == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // init signals staf
  for(int i=0;i<32;i++){
    p->signal_handlers[i] = SIG_DFL;
    p->handlers_sigmasks[i] = 0;
  }

  p->signal_mask= 0;
  p->pending_signals = 0;
  p->active_threads=1;
  p->signal_mask_backup = 0;
  p->handling_user_sig_flag = 0;
  p->handling_sig_flag=0;

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if(p->pagetable == 0){
    freeproc(p);
    release(&p->lock);
    return 0;
  }


  // initialize threads 
  // init the currently unused threads
  for(int i=0;i<NTHREAD;i++){
    struct kthread *t= &p->kthreads[i];
    t->state=TUNUSED;
    t->chan=0;
    t->tid=-1;
    t->trapframe = (struct trapframe *)p->threads_tf_start + i;     //TODO: check if good or maybe + i*sizeof(struct trapframe)
    t->killed = 0;
    t->frozen = 0;
  }

  struct kthread *t= &p->kthreads[0];
  acquire(&t->lock);

  if(init_thread(t) == -1){
    // encoutered problem
    freeproc(p);
    release(&p->lock);  
    return 0;
  }

  // release(&t->lock);/////////////////////////////////////////////////////////////////check
  
  return p;
}

//We start the func with locked kthread
int
init_thread(struct kthread *t){
  t->state = TUSED;
  t->tid = alloctid();  
  // t->killed=0;
  // t->frozen=0;
  // Allocate a trapframe page.
  
  // if((t->trapframe = (struct trapframe *)kalloc()) == 0){
  //   freethread(t);
  //   release(&t->lock);
  //   return 0;
  // }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&(t->context), 0, sizeof(t->context));
  t->context.ra = (uint64)forkret;
  t->context.sp = t->kstack + PGSIZE;

  return 0;
}

static void
freethread(struct kthread *t){
  // if(t->trapframe)
  //   kfree((void*)t->trapframe);
  // t->trapframe = 0;
  t->tid = 0;
  t->chan = 0;
  t->killed = 0;
  t->xstate = 0;
  t->state = TUNUSED;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  // if(p->trapframe)
  //   kfree((void*)p->trapframe);
  // p->trapframe = 0;

  // Task 3 : release threads
  struct kthread *t;
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    acquire(&t->lock);
    // if(t->state != TUNUSED)//changed 15:50
      freethread(t);
    release(&t->lock);
  }

  p->user_trapframe_backup = 0;
  if(p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  // p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->active_threads = 0;
  p->state = UNUSED;
}

// Create a user page table for a given process,
// with no user memory, but with trampoline pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if(pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    return 0;
  }
  
  // map the trapframe just below TRAMPOLINE, for trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->threads_tf_start), PTE_R | PTE_W) < 0){
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
  uvmfree(pagetable, sz);
}

// a user program that calls exec("/init")
// od -t xC initcode
uchar initcode[] = {
  0x17, 0x05, 0x00, 0x00, 0x13, 0x05, 0x45, 0x02,
  0x97, 0x05, 0x00, 0x00, 0x93, 0x85, 0x35, 0x02,
  0x93, 0x08, 0x70, 0x00, 0x73, 0x00, 0x00, 0x00,
  0x93, 0x08, 0x20, 0x00, 0x73, 0x00, 0x00, 0x00,
  0xef, 0xf0, 0x9f, 0xff, 0x2f, 0x69, 0x6e, 0x69,
  0x74, 0x00, 0x00, 0x24, 0x00, 0x00, 0x00, 0x00,
  0x00, 0x00, 0x00, 0x00
};

// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  struct cpu *c=mycpu();

  p = allocproc();
  initproc = p;
  struct kthread *t = &p->kthreads[0];
  
  // allocate one user page and copy init's instructions
  // and data into it.
  uvminit(p->pagetable, initcode, sizeof(initcode));

  
  p->sz = PGSIZE;
  

  // prepare for the very first "return" from kernel to user.
  t->trapframe->epc = 0;      // user program counter
  t->trapframe->sp = PGSIZE;  // user stack pointer

  safestrcpy(p->name, "initcode", sizeof(p->name));

  p->cwd = namei("/");

  p->state = RUNNABLE;
  t->state = TRUNNABLE;

  release(&p->lock);
  release(&p->kthreads[0].lock);////////////////////////////////////////////////////////////////check
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *p = myproc();

  sz = p->sz;
  if(n > 0){
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
      return -1;
    }
  } else if(n < 0){
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();
  struct kthread *np_first_thread;
  struct kthread *t = mykthread();

  // Allocate process.
  if((np = allocproc()) == 0){//////////////////////////////////////////////////check  lock p and t
    return -1;
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  // copy saved user registers.
  np_first_thread = &np->kthreads[0];
  // acquire(&np_first_thread ->lock);  ////////////////////////////////////////////////////////////////check allready holding

  acquire(&wait_lock);/////////////////////////////////////////////////////////////////check
  *(np_first_thread->trapframe) = *(t->trapframe);
  // Cause fork to return 0 in the child.
  np_first_thread->trapframe->a0 = 0;  // TODO: change reading the ret value from proc a0 to thread a0

  release(&wait_lock);////////////////////////////////////////////////////////////////check
  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    if(p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  np->signal_mask = p->signal_mask;
  for(int i=0;i<32;i++){
    np->signal_handlers[i] = p->signal_handlers[i];
    np->handlers_sigmasks[i] = p->handlers_sigmasks[i];
  }
  np-> pending_signals=0;

  pid = np->pid;
  // release(&np_first_thread->lock);  // ////////////////////////////////////////////////////////////////check
  release(&np->lock);
  acquire(&wait_lock);

  np->parent = p;

  // np->signal_mask = p->signal_mask;//TODO delete later
  // for(int i=0;i<32;i++){
  //   np->signal_handlers[i] = p->signal_handlers[i];
  //   np->handlers_sigmasks[i] = p->handlers_sigmasks[i];
  // }

  // np-> pending_signals=0;
  // np->frozen=0;
  release(&wait_lock);
  acquire(&np->lock);
  // acquire(&np_first_thread->lock); ////////////////////////////////////////////////////////////////check

  int proc_index= (int)(np-proc);//TODO delete
  int my_proc_index= (int)(p-proc);// TODO delete

  printf("%d:at fork idx%d->runable\n",my_proc_index,proc_index);//TODO delete

  np->state = RUNNABLE;   //TOOD: check if we still need this state or should change
  np_first_thread->state = TRUNNABLE;
  release(&np_first_thread->lock);
  release(&np->lock);



  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    if(pp->parent == p){
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

//kill current thread
void 
kthread_exit(int status){
  struct proc *p = myproc(); 
  struct kthread *t=mykthread();
  // printf("kte-a%d\n",p->pid);//TODO delete
  int curr_active_threads; 
  acquire(&p->lock);
  p->active_threads--;
  curr_active_threads=p->active_threads;
  release(&p->lock);
  // printf("kte-b%d\n",p->pid);//TODO delete

  acquire(&t->lock);
  t->xstate = status;
  t->state  = TZOMBIE;
    // printf("kte-c%d\n",p->pid);//TODO delete
  release(&t->lock);////////////////////////////////////////////////////////check
  wakeup(t);
  // printf("kte-d%d\n",p->pid);//TODO delete

  if(curr_active_threads==0){
    // printf("in kthead exit tid=%d  exiting procces\n",t->tid);
      // printf("%d: at kt exit 0t\n",p->pid);

    // release(&t->lock);////////////////////////////////////////////////////////check
    exit_proccess(status);
  }
  else{
    acquire(&t->lock);////////////////////////////////////////////////////////check
    // printf("kte-er%d\n",p->pid);//TODO delete
    // jump to sched and do not return
    sched();
    panic("zombie thread exit");
  }
}


// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().

// the function will send kill=1 to all threads in current procces
void
exit(int status){
  

  struct proc *p = myproc();
  struct kthread *t = mykthread();
  // printf("e%d\n",p->pid);//TODO delete
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    acquire(&t->lock);
    t->killed = 1;
    // In case of sleeping thread we must wake him up
    if(t->state == TSLEEPING)
      t->state = TRUNNABLE;
    release(&t->lock);
  }
  kthread_exit(status);
}

void
exit_proccess(int status)
{
  struct proc *p = myproc();
  struct kthread *t = mykthread();

  int proc_index= (int)(p-proc);// TODO delete
  printf("%d dx: at e_proc\n",proc_index);// TODO delete

  if(p == initproc)
    panic("init exiting");

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd]){
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }
  printf("%d dx: at e_proc_b\n",proc_index);// TODO delete
  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;
  // printf("ep-b%d\n",p->pid);//TODO delete
  acquire(&wait_lock);
  // printf("ep-a%d\n",p->pid);//TODO delete
  printf("%d dx: at e_proc_c\n",proc_index);// TODO delete
  // Give any children to init.
  reparent(p);
  printf("%d dx: at e_proc_d\n",proc_index);// TODO delete
  // Parent might be sleeping in wait().
  wakeup(p->parent);
  printf("%d dx: at e_proc_e\n",proc_index);// TODO delete
  acquire(&p->lock);
  printf("%d dx: at e_proc_f\n",proc_index);// TODO delete
  p->xstate = status;
  p->state = ZOMBIE;
  t->state=TZOMBIE;
  // release(&p->lock);// haya po mikodem :{ XD

  release(&wait_lock);

  // acquire thread lock before sched
  acquire(&t->lock);
  release(&p->lock);// ze po achav :) 
  printf("%d dx: at e_proc_g\n",proc_index);// TODO delete

  // Jump into the scheduler, never to return.
  sched();
  printf("zombie exit %d\n",proc_index);
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(uint64 addr)
{
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();
  acquire(&wait_lock);

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(np = proc; np < &proc[NPROC]; np++){
      if(np->parent == p){
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);


        havekids = 1;
        if(np->state == ZOMBIE){
          // Found one.
          pid = np->pid;
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
                                  sizeof(np->xstate)) < 0) {
            release(&np->lock);
            release(&wait_lock);
            return -1;
          }
          freeproc(np);
          release(&np->lock);
          release(&wait_lock);
          return pid;
        }
        release(&np->lock);
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || p->killed==1){
      release(&wait_lock);
      return -1;
    }
    
    // Wait for a child to exit.

    sleep(p, &wait_lock);  //DOC: wait-sleep


  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  struct kthread *t;
  struct cpu *c = mycpu();
  c->proc = 0;
  c->kthread=0;
  for(;;){
    // Avoid deadlock by ensuring that devices can interrupt.
    intr_on();

    for(p = proc; p < &proc[NPROC]; p++) {
      if(p->state == RUNNABLE) {
        
        // A runnable proccess is a proccess that may have runable threads
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
          acquire(&t->lock);
          if(t->state == TRUNNABLE && !t->frozen) {
            // printf("scheduler() tid= %d running\n",t->tid);
            int proc_index= (int)(p-proc);// TODO delete
            printf("%d\n",proc_index);


            // Switch to chosen process.  It is the process's job
            // to release its lock and then reacquire it
            // before jumping back to us.
            t->state = TRUNNING;
            c->proc = p;
            c->kthread = t;
            swtch(&c->context, &t->context);
            // Process is done running for now.
            // It should have changed its p->state before coming back.
            c->proc = 0;
            c->kthread=0;
          }
          release(&t->lock);
        }
      }
    }
  }
}

// Switch to scheduler
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.

// We hold the thread lock at the start of the function
void
sched(void)
{
  int intena;
  struct proc *p = myproc();
  struct kthread *t=mykthread();

  // if(!holding(&p->lock))
  //   panic("sched p->lock");
  // if(mycpu()->noff != 1)
  //   panic("sched locks");
  // if(p->state == RUNNING)
  //   panic("sched running");
  // if(intr_get())
  //   panic("sched interruptible");
              int proc_index= (int)(p-proc);// TODO delete

  if(!holding(&t->lock))
    panic("sched t->lock");
  if(mycpu()->noff != 1)
    panic("sched locks");
  if(t->state == TRUNNING){
    printf("sched%d\n",proc_index);
    panic("sched running");
  }
  if(intr_get())
    panic("sched interruptible");
  intena = mycpu()->intena;

  swtch(&t->context, &mycpu()->context);
  
  mycpu()->intena = intena;
}

//the process who got the signal will do the following 
// int 
// handle_signal(struct proc *p, int signum){
//   struct sigaction act = p->signal_handlers[signum];
//   int original_mask = p->signal_mask;

//   if(original_mask & (1<<signum) == 1){//Block signal
//     return 0;
//   }
//   p->pending_signals ^= (1<<signum);  // remove signal from pending 
//   if(act.sa_handler==SIG_IGN){//after removed from pending, ignore signal
//     return 0;
//   }
//   p->signal_mask = act.sigmask;
//   switch((uint)act.sa_handler){
//     case(SIG_DFL)
//       if(signum==SIGSTOP){
//         sig_stop_handler();
//       }
//       else if(signum == SIGCONT){
//       }
//   }
// }

// Give up the CPU for one scheduling round.
void
yield(void)
{
  // struct proc *p = myproc();
  struct kthread *t =mykthread();

  acquire(&t->lock);
  t->state = TRUNNABLE;
  sched();
  release(&t->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
  // static variables initialized only once
  static int first = 1;

  // Still holding p->lock from scheduler.
  // release(&myproc()->lock);

  release(&mykthread()->lock);    // TODO: check if this change is good

  if (first) {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }
  // printf("ffret%d\n",myproc()->pid);//TODO delete


  usertrapret();
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  // struct proc *p = myproc();
  struct kthread *t=mykthread();
  struct proc *p=myproc();
  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.
  acquire(&t->lock);  //DOC: sleeplock1
  release(lk);
  // printf("sl-s%d\n",p->pid);//TODO delete
  // Go to sleep.
  t->chan = chan;
  t->state = TSLEEPING;

  sched();

  // Tidy up.
  t->chan = 0;

  // Reacquire original lock.
  release(&t->lock);
  // printf("sl-e%d\n",p->pid);//TODO delete
  acquire(lk);
}

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
  struct proc *p;
  struct kthread *t;
  struct kthread *my_t = mykthread();

  for(p = proc; p < &proc[NPROC]; p++) {
    // acquire(&p->lock);
    if(p->state == RUNNABLE){
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
        if(t != my_t){
          acquire(&t->lock);
          if(t->state == TSLEEPING && t->chan == chan) {
            t->state = TRUNNABLE;
          }
          release(&t->lock);
        }
      }
    }
    // release(&p->lock);
  }
}

// new kill sending signal to process pid - task 2.2.1
int
kill(int pid, int signum)
{
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      if(p->state != RUNNABLE){
        release(&p->lock);
        return -1;
      }
      if(p->signal_handlers[signum] == (void*)SIG_IGN){
        release(&p->lock);
        return 1;
      }
      turn_on_bit(p,signum);
      release(&p->lock);
      // make sure at least one thread is runnable so we will get the kill signal
      if(signum == SIGKILL){
        struct kthread *t;
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
          if(t->state == RUNNABLE){
            break;
          }else{
            acquire(&t->lock);
            if(t->state==TSLEEPING){
              t->state=RUNNABLE;
              release(&t->lock);
              break;
            }
            release(&t->lock);
          } 
        }
      }
        // // Wake process from sleep in case it has to die
        // p->state = RUNNABLE;
      return 0;
    }
    release(&p->lock);
  }

  // didnt find any procces with pid
  return -1;
}

// // Kill the process with the given pid.
// // The victim won't exit until it tries to return
// // to user space (see usertrap() in trap.c).
// int
// sig_kill(int pid)
// {
//   struct proc *p;

//   for(p = proc; p < &proc[NPROC]; p++){
//     acquire(&p->lock);
//     if(p->pid == pid){
//       p->killed = 1;
//       if(p->state == SLEEPING){
//         // Wake process from sleep().
//         p->state = RUNNABLE;
//       }
//       release(&p->lock);
//       return 0;
//     }
//     release(&p->lock);
//   }
//   return -1;
// }

int
sig_stop(int pid)//TODO delete if not used
{
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    acquire(&p->lock);
    if(p->pid == pid){
      p->pending_signals|=(1<<SIGSTOP);

      release(&p->lock);
      return 0;
    }
    release(&p->lock);
  }
  return -1;
}


// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if(user_dst){
    return copyout(p->pagetable, dst, src, len);
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if(user_src){
    return copyin(p->pagetable, dst, src, len);
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  // [SLEEPING]  "sleep ",
  // [RUNNING]   "run   ",
  static char *states[] = {
  [UNUSED]    "unused",
  [RUNNABLE]  "runble",
  [ZOMBIE]    "zombie"
  };


  struct proc *p;
  char *state;

  printf("\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
}

int 
is_valid_sigmask(int sigmask){
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    return 0;
  return 1;
}

uint
sigprocmask(uint new_procmask){
  struct proc *p = myproc();
  if(is_valid_sigmask(new_procmask) == 0)
    return -1;
  acquire(&p->lock);
  int old_procmask = p->signal_mask;
  p->signal_mask = new_procmask;
  release(&p->lock);
  
  return old_procmask;
}

 
int 
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
  
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    return -1;
  struct proc *p = myproc();

  uint new_mask;
  copyin(p->pagetable, (char *)&new_mask, (uint64)&act->sigmask, sizeof(act->sigmask));

  if(is_valid_sigmask(new_mask) == 0)
    return -1;
  acquire(&p->lock);

  if(oldact!=0){
    copyout(p->pagetable, (uint64)&oldact->sa_handler, (char *)&p->signal_handlers[signum], sizeof(act->sa_handler));
    copyout(p->pagetable, (uint64)&oldact->sigmask, (char *)&p->handlers_sigmasks[signum], sizeof(uint));
  }

  p->handlers_sigmasks[signum]=new_mask;
  copyin(p->pagetable, (char *)&p->signal_handlers[signum], (uint64)&act->sa_handler, sizeof(act->sa_handler));

  release(&p->lock);



  return 0;
}

void 
sigret(void){
  struct proc *p = myproc();
  struct kthread *t=mykthread();

  copyin(p->pagetable, (char *)t->trapframe, (uint64)p->user_trapframe_backup, sizeof(struct trapframe));

  // restore user stack pointer
  acquire(&p->lock);
  // TODO maybe we will need to also lock the kthread lock
  t->trapframe->sp += sizeof(struct trapframe);

  p->signal_mask = p->signal_mask_backup;
  
  // Allow user signal handler since we finished handling the current
  p->handling_user_sig_flag = 0;
  // Allow other thread to react to signals
  p->handling_sig_flag = 0;
  release(&p->lock);
}

// we call turn on and turn off when holding p->lock
void
turn_on_bit(struct proc* p, int signum){
  if(!(p->pending_signals & (1 << signum)))
    p->pending_signals ^= (1 << signum);  
}

void
turn_off_bit(struct proc* p, int signum){
  if(p->pending_signals & (1 << signum))
    p->pending_signals ^= (1 << signum);  
}

int kthread_create(void (*start_func)(), void *stack){
  struct proc *p = myproc();
  struct kthread *curr_t = mykthread();
  struct kthread *other_t;

  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    int thread_ind = (int)(other_t - p->kthreads);

    if(curr_t != other_t){
      acquire(&other_t->lock);
      if(other_t->state == TUNUSED){
          freethread(other_t);  // free memory in case this thread entry was previously used
          init_thread(other_t);
          
          
          *(other_t->trapframe) = *(curr_t->trapframe);
          other_t->trapframe->sp = (uint64)stack + MAX_STACK_SIZE-16;

          other_t->trapframe->epc = (uint64)start_func;
          release(&other_t->lock);
          acquire(&p->lock);
          p->active_threads++;
          release(&p->lock);
          other_t->state = TRUNNABLE;
          return other_t->tid;
      }
      release(&other_t->lock);
    }
  }
  return -1;
}



int
kthread_join(int thread_id, int* status){
  struct kthread *nt;
  struct proc *p = myproc();
  struct kthread *t = mykthread();



  if(thread_id == t->tid)
    return -1;
  acquire(&wait_lock);
  // Search for thread in the procces threads array
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){
    if(nt != t){
      acquire(&nt->lock);

      if(nt->tid == thread_id){
        //found target thread 
        goto found;
      }
      release(&nt->lock);
    }
  }

  if(nt->tid != thread_id){
    // printf("thread %d failed to find target %d\n",t->tid,thread_id);
    release(&wait_lock);
    return -1;
  }
  found:
  // printf("%d:join to %d\n",p->pid,thread_id);  // TODO delete
  // Wait for thread to terminate
  // still holding nt lock
  for(;;){
      if(nt->state==TZOMBIE){
        if(status != 0 && copyout(p->pagetable, status, (char *)&nt->xstate,sizeof(nt->xstate)) < 0) {
           release(&nt->lock);
           release(&wait_lock);
           return -1;                   
        }
        freethread(nt);       //make the thread UNUSED again
        release(&nt->lock);
        release(&wait_lock);  //  successfull join     
        return 0;
      }
      // No point waiting if thread isn't running
      else if(nt->state==TUNUSED){ // in case someone already free that thread
        freethread(nt);       
        release(&nt->lock);
        release(&wait_lock);  //  successfull join
        return 1; //thread already exited
      }

    // Check if thread allready terminated and his place was taken by a new thread
    if(t->killed || nt->tid!=thread_id){
      release(&nt->lock);
      release(&wait_lock);
      return -1;
    }
    release(&nt->lock);
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    acquire(&nt->lock);
  }
}

int
kthread_join_all(){
  struct proc *p=myproc();
  struct kthread *t = mykthread();
  struct kthread *nt;
  int res = 1;
  for(nt = p->kthreads; nt < &p->kthreads[NTHREAD]; nt++){
    if(nt != t){
      res &= kthread_join(nt->tid,0);
    }
  }

  return res;
}


void 
printTF(struct kthread *t){//function for debuging, TODO delete
  printf("**************tid=%d*****************\n",t->tid);
  // printf("t->tf->epc = %p\n",t->trapframe->epc);
  // printf("t->tf->ra = %p\n",t->trapframe->ra);
  // printf("t->tf->kernel_sp = %p\n",t->trapframe->kernel_sp);
  printf("t->kstack = %p\n",t->kstack);
  printf("t->context = %p\n",t->context);
  printf("t->tf->sp = %p\n",t->trapframe->sp);
  printf("t->state = %d\n",t->state);
  printf("**************************************\n",t->tid);

}