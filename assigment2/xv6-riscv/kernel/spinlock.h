#define  MAX_BSEM 128

int             bsem_alloc();   
void            bsem_free(int);
void            bsem_down(int);
void            bsem_up(int);

// Mutual exclusion lock.
struct spinlock {
  uint locked;       // Is the lock held?

  // For debugging:
  char *name;        // Name of lock.
  struct cpu *cpu;   // The cpu holding the lock.
};


////////// besemaphore ////////////
enum bsemaphore_state { SUNUSED, SUSED};

struct bsemaphore{
  struct spinlock s_lock;
  int s;
  enum bsemaphore_state state;
  int waiting;
};

extern struct bsemaphore bsemaphores[MAX_BSEM];