#include "../kernel/param.h"
#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"
#include "../kernel/fs.h"
#include "../kernel/fcntl.h"
#include "../kernel/syscall.h"
#include "../kernel/memlayout.h"
#include "../kernel/riscv.h"
#include "Csemaphore.h"

struct counting_semaphore;

void 
csem_down(struct counting_semaphore *sem){
    if(!sem){
        printf("invalid sem pointer in csem_down\n");
        return;
    }
    
    bsem_down(sem->S1_desc);   //TODO: make sure works
    sem->waiting++;
    bsem_up(sem->S1_desc);

    bsem_down(sem->S2_desc);
    bsem_down(sem->S1_desc);
    sem->waiting--;
    sem->value--;
    if(sem->value > 0)
        bsem_up(sem->S2_desc);
    bsem_up(sem->S1_desc);

}

void            
csem_up(struct counting_semaphore *sem){
    if(!sem){
        printf("invalid sem pointer in csem_up\n");
        return;
    }

    bsem_down(sem->S1_desc);
    sem->value++;
    if(sem->value == 1)
        bsem_up(sem->S2_desc);
    bsem_up(sem->S1_desc);
}


int             
csem_alloc(struct counting_semaphore *sem, int initial_value){
    sem->S1_desc = bsem_alloc();
    sem->S2_desc = bsem_alloc();
    if(sem->S1_desc <0 || sem->S2_desc < 0)
        return -1;
    sem->value = initial_value;
    sem->waiting = 0;

    return 0;
}
void            
csem_free(struct counting_semaphore *sem){
    if(!sem){
        printf("invalid sem pointer in csem_free\n");
        return;
    
    }

    bsem_down(sem->S1_desc);

    if(sem->waiting!=0){
        printf("csem_free: cant free while proc waiting\n");
        bsem_up(sem->S1_desc);
        return;
    }
    bsem_free(sem->S1_desc);
    bsem_free(sem->S2_desc);

}