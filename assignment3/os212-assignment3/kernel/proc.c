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

extern void forkret(void);
static void freeproc(struct proc *p);

extern char trampoline[]; // trampoline.S

// helps ensure that wakeups of wait()ing
// parents are not lost. helps obey the
// memory model when using p->parent.
// must be acquired before any p->lock.
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl)
{
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
  {
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
  }
}

// initialize the proc table at boot time.
void procinit(void)
{
  struct proc *p;

  initlock(&pid_lock, "nextpid");
  initlock(&wait_lock, "wait_lock");
  for (p = proc; p < &proc[NPROC]; p++)
  {
    initlock(&p->lock, "proc");
    p->kstack = KSTACK((int)(p - proc));
  }
}

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid()
{
  int id = r_tp();
  return id;
}

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
  int id = cpuid();
  struct cpu *c = &cpus[id];
  return c;
}

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
  push_off();
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
  pop_off();
  return p;
}

int allocpid()
{
  int pid;

  acquire(&pid_lock);
  pid = nextpid;
  nextpid = nextpid + 1;
  release(&pid_lock);

  return pid;
}

// Look in the process table for an UNUSED proc.
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc *
allocproc(void)
{
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
  {
    acquire(&p->lock);
    if (p->state == UNUSED)
    {
      goto found;
    }
    else
    {
      release(&p->lock);
    }
  }
  return 0;

found:
  p->pid = allocpid();
  p->state = USED;

  // Allocate a trapframe page.
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
  {
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
  if (p->pagetable == 0)
  {
    freeproc(p);
    release(&p->lock);
    return 0;
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
  p->context.ra = (uint64)forkret;
  p->context.sp = p->kstack + PGSIZE;
  p->physical_pages_num = 0;
  p->total_pages_num = 0;
  p->pages_physc_info.free_spaces = 0;
  p->pages_swap_info.free_spaces = 0;
  p->paging_time = 0;

  return p;
}

// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
  if (p->trapframe)
    kfree((void *)p->trapframe);
  p->trapframe = 0;
  if (p->pagetable)
    proc_freepagetable(p->pagetable, p->sz);
  p->pagetable = 0;
  p->sz = 0;
  p->pid = 0;
  p->parent = 0;
  p->name[0] = 0;
  p->chan = 0;
  p->killed = 0;
  p->xstate = 0;
  p->state = UNUSED;
  p->paging_time = 0;
}

// Create a user page table for a given process,
// with no user memory, but with trampoline pages.
pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
  if (pagetable == 0)
    return 0;

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if (mappages(pagetable, TRAMPOLINE, PGSIZE,
               (uint64)trampoline, PTE_R | PTE_X) < 0)
  {
    uvmfree(pagetable, 0);
    return 0;
  }

  // map the trapframe just below TRAMPOLINE, for trampoline.S.
  if (mappages(pagetable, TRAPFRAME, PGSIZE,
               (uint64)(p->trapframe), PTE_R | PTE_W) < 0)
  {
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    uvmfree(pagetable, 0);
    return 0;
  }

  return pagetable;
}

// Free a process's page table, and free the
// physical memory it refers to.
void proc_freepagetable(pagetable_t pagetable, uint64 sz)
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
    0x00, 0x00, 0x00, 0x00};

// Set up first user process.
void userinit(void)
{
  struct proc *p;

  p = allocproc();
  initproc = p;

  // allocate one user page and copy init's instructions
  // and data into it.
  uvminit(p->pagetable, initcode, sizeof(initcode));
  p->sz = PGSIZE;

  // prepare for the very first "return" from kernel to user.
  p->trapframe->epc = 0;     // user program counter
  p->trapframe->sp = PGSIZE; // user stack pointer

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  p->state = RUNNABLE;

  release(&p->lock);
}

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int growproc(int n)
{
  uint sz;
  struct proc *p = myproc();
  sz = p->sz;

  if (n > 0)
  {
//----------------------------------------------BONUS
#ifdef NONE
    // Lazy allocation, we will not allocate any memory, instead just increase proc size
    //  Memory will only be allocated when accessing an unallocated page
    p->sz += n;
    return 0;
#endif
    //----------------------------------------------BONUS

    if ((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0)
    {
      return -1;
    }
  }
  else if (n < 0)
  {
    sz = uvmdealloc(p->pagetable, sz, sz + n);
  }
  p->sz = sz;
  return 0;
}

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();
  // Allocate process.
  if ((np = allocproc()) == 0)
  {
    return -1;
  }
  // Copy user memory from parent to child.
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
  {
    freeproc(np);
    release(&np->lock);
    return -1;
  }
  np->sz = p->sz;

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;

  // increment reference counts on open file descriptors.
  for (i = 0; i < NOFILE; i++)
    if (p->ofile[i])
      np->ofile[i] = filedup(p->ofile[i]);
  np->cwd = idup(p->cwd);

  safestrcpy(np->name, p->name, sizeof(p->name));

  pid = np->pid;

  release(&np->lock);

  // TASK3
  createSwapFile(np);

  // if(p->pid >2 )
  copyFilesInfo(p, np); // TODO: check we need to this for father 1,2

  np->physical_pages_num = p->physical_pages_num;
  np->total_pages_num = p->total_pages_num;

  acquire(&wait_lock);
  np->parent = p;
  release(&wait_lock);

  acquire(&np->lock);
  np->state = RUNNABLE;
  release(&np->lock);

  return pid;
}

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void reparent(struct proc *p)
{
  struct proc *pp;

  for (pp = proc; pp < &proc[NPROC]; pp++)
  {
    if (pp->parent == p)
    {
      pp->parent = initproc;
      wakeup(initproc);
    }
  }
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void exit(int status)
{
  struct proc *p = myproc();

  if (p == initproc)
    panic("init exiting");
  // Close all open files.
  for (int fd = 0; fd < NOFILE; fd++)
  {
    if (p->ofile[fd])
    {
      struct file *f = p->ofile[fd];
      fileclose(f);
      p->ofile[fd] = 0;
    }
  }
  removeSwapFile(p); // Remove swap file of p

  begin_op();
  iput(p->cwd);
  end_op();
  p->cwd = 0;

  acquire(&wait_lock);

  // Give any children to init.
  reparent(p);

  // Parent might be sleeping in wait().
  wakeup(p->parent);
  acquire(&p->lock);

  p->xstate = status;
  p->state = ZOMBIE;

  release(&wait_lock);

  // Jump into the scheduler, never to return.
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int wait(uint64 addr)
{
  struct proc *np;
  int havekids, pid;
  struct proc *p = myproc();

  acquire(&wait_lock);

  for (;;)
  {
    // Scan through table looking for exited children.
    havekids = 0;
    for (np = proc; np < &proc[NPROC]; np++)
    {
      if (np->parent == p)
      {
        // make sure the child isn't still in exit() or swtch().
        acquire(&np->lock);

        havekids = 1;
        if (np->state == ZOMBIE)
        {
          // Found one.
          pid = np->pid;
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
                                   sizeof(np->xstate)) < 0)
          {
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
    if (!havekids || p->killed)
    {
      release(&wait_lock);
      return -1;
    }

    // Wait for a child to exit.
    sleep(p, &wait_lock); //DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run.
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
void scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();

  c->proc = 0;

  for (;;)
  {
    // Avoid deadlock by ensuring that devices can interrupt.
    intr_on();

    for (p = proc; p < &proc[NPROC]; p++)
    {
      acquire(&p->lock);
      if (p->state == RUNNABLE)
      {
        // Switch to chosen process.  It is the process's job
        // to release its lock and then reacquire it
        // before jumping back to us.
        p->state = RUNNING;
        c->proc = p;
        swtch(&c->context, &p->context);

        // update pages info
        if (p->pid > 2)
        {
#ifdef NFUA
          update_pages_info();
#elif LAPA
          update_pages_info();
#endif
        }

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
      }
      release(&p->lock);
    }
  }
}

// Switch to scheduler.  Must hold only p->lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void sched(void)
{
  int intena;
  struct proc *p = myproc();

  if (!holding(&p->lock))
    panic("sched p->lock");
  if (mycpu()->noff != 1)
    panic("sched locks");
  if (p->state == RUNNING)
    panic("sched running");
  if (intr_get())
    panic("sched interruptible");

  intena = mycpu()->intena;
  swtch(&p->context, &mycpu()->context);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void yield(void)
{
  struct proc *p = myproc();
  acquire(&p->lock);
  p->state = RUNNABLE;
  sched();
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);

  if (first)
  {
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();

  // Must acquire p->lock in order to
  // change p->state and then call sched.
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); //DOC: sleeplock1
  release(lk);

  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  release(&p->lock);
  acquire(lk);
}

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
  {
    if (p != myproc())
    {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan)
      {
        p->state = RUNNABLE;
      }
      release(&p->lock);
    }
  }
}

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++)
  {
    acquire(&p->lock);
    if (p->pid == pid)
    {
      p->killed = 1;
      if (p->state == SLEEPING)
      {
        // Wake process from sleep().
        p->state = RUNNABLE;
      }
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
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
  struct proc *p = myproc();
  if (user_dst)
  {
    return copyout(p->pagetable, dst, src, len);
  }
  else
  {
    memmove((char *)dst, src, len);
    return 0;
  }
}

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
  struct proc *p = myproc();
  if (user_src)
  {
    return copyin(p->pagetable, dst, src, len);
  }
  else
  {
    memmove(dst, (char *)src, len);
    return 0;
  }
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
  static char *states[] = {
      [UNUSED] "unused",
      [SLEEPING] "sleep ",
      [RUNNABLE] "runble",
      [RUNNING] "run   ",
      [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
  for (p = proc; p < &proc[NPROC]; p++)
  {
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    printf("%d %s %s", p->pid, state, p->name);
    printf("\n");
  }
}

// Next free space in swap file
int get_next_free_space(uint16 free_spaces)
{
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
  {
    if (!(free_spaces & (1 << i)))
      return i;
  }
  return -1;
}

// Get file vm and return file entery inside swap file if exist
int get_index_in_page_info_array(uint64 va, struct page_info *arr)
{
  uint64 rva = PGROUNDDOWN(va);
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
  {
    struct page_info *po = &arr[i];
    if (po->va == rva)
    {
      return i;
    }
  }
  return -1; // if not found return null
}

//  Call this function when p is accuired
//  free physical memory of page which virtual address va
//  write this page to procs swap file
//  return the new free physical address
uint64
page_out(uint64 va)
{
  struct proc *p = myproc();

  uint64 rva = PGROUNDDOWN(va);

  // find the addrres of the page which sent out
  pte_t *pte = walk(p->pagetable, va, 0);
  uint64 pa = PTE2PA(*pte);

  // insert the page to the swap file

  int page_index = insert_page_to_swap_file(rva);

  int start_offset = page_index * PGSIZE;
  if (page_index < 0 || page_index >= MAX_PSYC_PAGES)
    panic("fadge no free index in page_out");

  writeToSwapFile(p, (char *)pa, start_offset, PGSIZE); // Write page to swap file

  // Update the ram info struct
  remove_page_from_physical_memory(rva);
  p->physical_pages_num--;

  // free space in physical memory
  kfree((void *)pa);

  *pte &= ~PTE_V; // page table entry now invalid
  *pte |= PTE_PG; // paged out to secondary storage

  return pa;
}

// move page from swap file to physical memory
pte_t *
page_in(uint64 va, pte_t *pte)
{
  uint64 pa;
  struct proc *p = myproc();
  uint64 rva = PGROUNDDOWN(va);
  // update swap info
  int swap_old_index = remove_page_from_swap_file(rva);

  if (swap_old_index < 0)
    panic("page_in: index in swap file not found");

  // alloc page in physical memory
  if ((pa = (uint64)kalloc()) == 0)
  {
    printf("retrievingpage: kalloc failed\n");
    return 0;
  }

  mappages(p->pagetable, va, PGSIZE, (uint64)pa, PTE_FLAGS(*pte));

  // update physc info
  insert_page_to_physical_memory(rva);
  p->physical_pages_num++;

  // Write to swap file
  int start_offset = swap_old_index * PGSIZE;
  readFromSwapFile(p, (char *)pa, start_offset, PGSIZE);

  // update pte
  if (!(*pte & PTE_PG))
    panic("page in: page out flag was off");
  *pte = (*pte | PTE_V) & (~PTE_PG);

  return pte;
}

void copyFilesInfo(struct proc *p, struct proc *np)
{
  // Copy swapfile
  void *temp_page;

  if (!(temp_page = kalloc()))
    panic("copyFilesInfo: kalloc failed");

  for (int i = 0; i < MAX_PSYC_PAGES; i++)
  {
    if (p->pages_swap_info.free_spaces & (1 << i))
    {
      int res = readFromSwapFile(p, (char *)temp_page, i * PGSIZE, PGSIZE);

      if (res < 0)
        panic("copyFilesInfo: failed read");

      res = writeToSwapFile(np, temp_page, i * PGSIZE, PGSIZE);

      if (res < 0)
        panic("copyFilesInfo: faild write ");
    }
  }

  kfree(temp_page);

  // Copy swap and ram structs
  np->pages_swap_info.free_spaces = p->pages_swap_info.free_spaces;
  np->pages_physc_info.free_spaces = p->pages_physc_info.free_spaces;

  for (int i = 0; i < MAX_PSYC_PAGES; i++)
  {
    np->pages_swap_info.pages[i] = p->pages_swap_info.pages[i];
    np->pages_physc_info.pages[i] = p->pages_physc_info.pages[i];
  }
}

// return page index in p->phisical_page struct
int get_next_page_to_swap_out()
{
  int selected_pg_index = -2;
  printf("debug: LOOKING FOR PAGE TO SWAPOUT\n");
  print_pages_from_info_arrs();

#ifdef SCFIFO
  struct proc *p = myproc();
  selected_pg_index = -1;
  while (selected_pg_index < 0)
  {
    selected_pg_index = compare_all_pages(SCFIFO_compare);
    if (selected_pg_index >= 0)
    {
      int accessed = is_accessed(&p->pages_physc_info.pages[selected_pg_index], 1);
      if (accessed)
      {
        printf("debug: SCFIFO giving second chance to = %d\n", selected_pg_index);
        // give second chance
        p->pages_physc_info.pages[selected_pg_index].time_inserted = p->paging_time;
        p->paging_time++;
        selected_pg_index = -1;
      }
    }
  }

#elif NFUA
  selected_pg_index = compare_all_pages(NFUA_compare);
#elif LAPA
  selected_pg_index = compare_all_pages(LAPA_compare);
#endif
  printf("debug: NEXT PAGE TO SWAPOUT = %d\n", selected_pg_index);
  return selected_pg_index;
}

long NFUA_compare(struct page_info *pg1, struct page_info *pg2)
{
  if (!pg1 || !pg2)
    panic("NFUA_compare : null input");
  return pg1->aging_counter - pg2->aging_counter;
}

long LAPA_compare(struct page_info *pg1, struct page_info *pg2)
{
  if (!pg1 || !pg2)
    panic("LAPA_compare : null input");
  int res = countOnes(pg1->aging_counter) - countOnes(pg2->aging_counter);

  if (res == 0)
    return pg1->aging_counter - pg2->aging_counter;
  return res;
}

int SCFIFO_compare(struct page_info *pg1, struct page_info *pg2)
{
  if (!pg1 || !pg2)
    panic("SCFIFO_compare : null input");

  return pg1->time_inserted - pg2->time_inserted;
}

long countOnes(long n)
{
  int count = 0;
  while (n)
  {
    count += n & 1;
    n >>= 1;
  }
  return count;
}

// Return the index of the page to swap out acording to paging policy
int compare_all_pages(long (*compare)(struct page_info *pg1, struct page_info *pg2))
{
  struct proc *p = myproc();

  struct page_info *pg_to_swap = 0;
  int min_index = -1;

  for (int i = 0; i < MAX_PSYC_PAGES; i++)
  {
    struct page_info *pg = &p->pages_physc_info.pages[i];
    // #ifdef NFUA
    //   if(is_accessed(pg,1)>0)
    //     pg->aging_counter |= 0x80000000;
    // #endif
    if ((p->pages_physc_info.free_spaces & (1 << i)) && (!pg_to_swap || compare(pg, pg_to_swap) < 0))
    {
      // in case pg_to_swap have not yet been initialize or the current pg is less needable acording to policy
      pg_to_swap = pg;
      min_index = i;
    }
  }
  return min_index;
}

void update_pages_info()
{

#ifdef NFUA

  struct page_info *pg;
  struct proc *p = myproc();

  for (pg = p->pages_physc_info.pages; pg < &p->pages_physc_info.pages[MAX_PSYC_PAGES]; pg++)
  {
    update_NFUA_LAPA_counter(pg);
  }

#elif LAPA

  struct page_info *pg;
  struct proc *p = myproc();

  for (pg = p->pages_physc_info.pages; pg < &p->pages_physc_info.pages[MAX_PSYC_PAGES]; pg++)
  {
    update_NFUA_LAPA_counter(pg);
  }

#endif
}

void update_NFUA_LAPA_counter(struct page_info *pg)
{
  long acc = (long)(is_accessed(pg, 1));
  pg->aging_counter = (pg->aging_counter >> 1);
  if (acc)
    pg->aging_counter = pg->aging_counter | 0x80000000; // if page was accessed set MSB to 1
}

long is_accessed(struct page_info *pg, int to_reset)
{
  struct proc *p = myproc();
  pte_t *pte = walk(p->pagetable, pg->va, 0);
  long accessed = (*pte & PTE_A);
  if (accessed && to_reset)
    *pte ^= PTE_A; // reset accessed flag

  return accessed;
}
void reset_aging_counter(struct page_info *pg)
{
#ifdef NFUA
  pg->aging_counter = 0x00000000; //TODO return to 0
  // pg->aging_counter = 0;//TODO return to 0

#elif LAPA
  pg->aging_counter = 0xFFFFFFFF;
#endif
}

void print_pages_from_info_arrs()
{
  struct proc *p = myproc();
  printf("\n physic pages \t\t\t\t\t\t\t\tswap file::\n");
  printf("index\t(va, used, aging)\t\t\t\t\t\t(va , used)  \n ");
  for (int i = 0; i < MAX_PSYC_PAGES; i++)
  {
    printf("%d:\t(%p , %d ,\t %p)\t\t(%p , %d)  \n ", i, p->pages_physc_info.pages[i].va,
           (p->pages_physc_info.free_spaces & (1 << i)) > 0,
           p->pages_physc_info.pages[i].aging_counter,
           p->pages_swap_info.pages[i].va, (p->pages_swap_info.free_spaces & (1 << i)) > 0);
  }
}
    
//----------------------------------------------BONUS
uint64 lazy_allocate(uint64 va)
{
  uint64 rva = PGROUNDDOWN(va);
  char *pa = kalloc();
  if ( pa <= 0)
    return -1;

  memset(pa, 0, PGSIZE);

  if (mappages(myproc()->pagetable, rva, PGSIZE, (uint64)pa, PTE_W | PTE_X | PTE_R | PTE_U) < 0){
    kfree(pa);
    return -1;
  }


  return (uint64)pa;
}
//----------------------------------------------BONUS
