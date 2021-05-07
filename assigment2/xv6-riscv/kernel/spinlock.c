// Mutual exclusion spin locks.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "proc.h"
#include "defs.h"
      
struct bsemaphore bsemaphores[MAX_BSEM];

void
initlock(struct spinlock *lk, char *name)
{
  lk->name = name;
  lk->locked = 0;
  lk->cpu = 0;
}

void
initsemaphores(){
  struct bsemaphore *sem;
  for(sem =bsemaphores; sem<&bsemaphores[MAX_BSEM];sem++){
    sem->state = SUNUSED;
    sem->s = 1;
    sem->waiting = 0;
    initlock(&sem->s_lock,"lock");
  }
}

// Acquire the lock.
// Loops (spins) until the lock is acquired.
void
acquire(struct spinlock *lk){
  push_off(); // disable interrupts to avoid deadlock.
  if(holding(lk)){
    printf("pid=%d tid=%d tried to lock when already holding\n",lk->cpu->proc->pid,mykthread()->tid);//TODO delete
    panic("acquire");

  }

  // On RISC-V, sync_lock_test_and_set turns into an atomic swap:
  //   a5 = 1
  //   s1 = &lk->locked
  //   amoswap.w.aq a5, a5, (s1)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen strictly after the lock is acquired.
  // On RISC-V, this emits a fence instruction.
  __sync_synchronize();

  // Record info about lock acquisition for holding() and debugging.
  lk->cpu = mycpu();
}

// Release the lock.
void
release(struct spinlock *lk)
{
  if(!holding(lk))
    panic("release");

  lk->cpu = 0;
  
  // Tell the C compiler and the CPU to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other CPUs before the lock is released,
  // and that loads in the critical section occur strictly before
  // the lock is released.
  // On RISC-V, this emits a fence instruction.
  __sync_synchronize();

  // Release the lock, equivalent to lk->locked = 0.
  // This code doesn't use a C assignment, since the C standard
  // implies that an assignment might be implemented with
  // multiple store instructions.
  // On RISC-V, sync_lock_release turns into an atomic swap:
  //   s1 = &lk->locked
  //   amoswap.w zero, zero, (s1)
  __sync_lock_release(&lk->locked);

  pop_off();
}

// Check whether this cpu is holding the lock.
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
  return r;
}

// push_off/pop_off are like intr_off()/intr_on() except that they are matched:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    mycpu()->intena = old;
  mycpu()->noff += 1;
}

void
pop_off(void)
{
  struct cpu *c = mycpu();
  if(intr_get())
    panic("pop_off - interruptible");
  if(c->noff < 1)
    panic("pop_off");
  c->noff -= 1;
  if(c->noff == 0 && c->intena)
    intr_on();
}

/////////// bsemaphore/////////////// 

// Allocates a new binary semaphore and returns its descriptor(-1 if failure). You are not
// restricted on the binary semaphore internal structure, but the newly allocated binary
// semaphore should be in unlocked state.
int bsem_alloc(){
  
  struct bsemaphore *sem;
  for(sem =bsemaphores; sem<&bsemaphores[MAX_BSEM];sem++){
    acquire(&sem->s_lock);
    if(sem->state == SUNUSED)
      goto found;
    release(&sem->s_lock);
  }
  panic("Semaphore BOMB");

  // found free semaphore
  found:
  sem->state=SUSED;
  sem->s=1;
  sem->waiting=0;
  release(&sem->s_lock);

  return (int)(sem - bsemaphores);
  
}

// Call the free function with the semaphore down
void
bsem_free(int sem_index){
  if(sem_index<0 || sem_index > MAX_BSEM)
    panic("fudge you give me bad index in bsem_down");

  struct bsemaphore *bsem = &bsemaphores[sem_index];
  acquire(&bsem->s_lock);
  if(bsem->state == SUNUSED ){
    release(&bsem->s_lock);
    panic("fack semaphore is not alloced in bsem_down");
  }
  if(bsem->waiting > 0)
    panic("tried to bsem_free when threads are blocked");

  // if(bsem->s == 0)
  //   panic("tried to free bsem when it is locked!");

  
  bsem->state = SUNUSED;
  release(&bsem->s_lock);
}

// Attempt to acquire (lock) the semaphore, in case that it is already acquired (locked),
// block the current thread until it is unlocked and then acquire it./
void
bsem_down(int sem_index){
  if(sem_index<0 || sem_index > MAX_BSEM)
    panic("fudge you give me bad index in bsem_down");

  struct bsemaphore *bsem = &bsemaphores[sem_index];
  acquire(&bsem->s_lock);
  if(bsem->state == SUNUSED ){
    release(&bsem->s_lock);
    panic("fack semaphore is not alloced in bsem_down");
  }

  bsem->waiting++;
  while(bsem->s == 0){// sleep until semaphore is unlocked
    sleep(bsem, &bsem->s_lock);
  }
  bsem->waiting--;

  bsem->s = 0;
  release(&bsem->s_lock);
}

void bsem_up(int sem_index){
  if(sem_index<0 || sem_index > MAX_BSEM)
    panic("fudge you give me bad index in bsem_down");

  struct bsemaphore *bsem = &bsemaphores[sem_index];
  acquire(&bsem->s_lock);
  if(bsem->state == SUNUSED ){
    release(&bsem->s_lock);
    panic("fack semaphore is not alloced in bsem_down");
  }
  bsem->s++;

  if(bsem->waiting > 0)
    wakeup(bsem);
  
  release(&bsem->s_lock);
}

