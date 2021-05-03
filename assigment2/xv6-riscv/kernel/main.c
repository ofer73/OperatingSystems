#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "defs.h"

volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
  if(cpuid() == 0){
    consoleinit();
    printfinit();
    printf("\n");
    printf("\n");
    kinit();         // physical page allocator
    kvminit();       // create kernel page table
    kvminithart();   // turn on paging

    procinit();      // process table

    trapinit();      // trap vectors

    trapinithart();  // install kernel trap vector

    plicinit();      // set up interrupt controller
    plicinithart();  // ask PLIC for device interrupts
    binit();         // buffer cache
    iinit();         // inode cache
    fileinit();      // file table
    virtio_disk_init(); // emulated hard disk

    printf("main before user init \n");
    userinit();      // first user process
    printf("main -after user init\n");
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
      ;
    __sync_synchronize();
    printf("hart %d starting\n", cpuid());
    kvminithart();    // turn on paging
    printf("hart %d kvm\n", cpuid());
    trapinithart();   // install kernel trap vector
    printf("hart %d trap\n", cpuid());

    plicinithart();   // ask PLIC for device interrupts
    printf("hart %d plic\n", cpuid());
  }
  printf("before sched %d \n", cpuid());
  scheduler();        
}
