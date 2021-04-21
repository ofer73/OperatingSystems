#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"
#include "kernel/perf.h"

// #################################### TESTS ##########################

int test()
{
    printf("started\n");

    int pid2;
    if ((pid2 = fork()) == 0)
    {
        int c = 0;
        while (c < 3)
        {
            printf("sooonnn");
            sleep(10);
            c++;
        }
        while (c < 1000)
        {
            printf("%d\n", c);
            c++;
        }
        printf("\n");
        exit(0);
    }
    else
    {
        int status;
        struct perf p;

        int x = wait_stat(&status, &p);

        printf("ret val: %d ", x);
        printf("ctime: %d ", p.ctime);
        printf("ttime: %d ", p.ttime);
        printf("stime: %d ", p.stime);
        printf("retime: %d ", p.retime);
        printf("rutime: %d", p.rutime);
        printf("bursttime: %d\n", p.average_bursttime);
        printf("xstate: %d\n\n", status);
    }

    wait(0);
    sleep(1);
    sbrk(4096);

    return 0;
}

int priorityTest()
{
    int mask = (1 << SYS_set_priority);

    int pid = fork();
    trace(mask, pid);
    if (pid == 0)
    {
        int badRes = set_priority(7);
        if (badRes == 0)
        {
            printf("boundries not working");
            return -1;
        }

        for (int i = 1; i < 6; i++)
        {
            int goodRes = set_priority(i);
            if (goodRes != 0)
            {
                printf("priority set not working");
                return -1;
            }
        }
        exit(0);
    }
    wait(0);
    return 0;
}

int fcfsTest()
{

    sleep(10);

    // create son
    int pid = fork();
    // int father = getpid();
    // int mask1 = (1 << SYS_sbrk);
    // int mask2 = (1 << SYS_priority);
    // trace(mask1, father);
    // trace(mask2, pid);

    // son
    if (pid == 0)
    {
        for (int i = 0; i < 100; i++)
            printf("pid: %d ,my turn now\n", pid);
        sleep(1);
        printf("I'am alsoooo back!!!\n");
        exit(0);
    }
    // father
    else
    {
        for (int i = 0; i < 100; i++)
            printf("father before son!\n");
        sleep(3); // go to the back of the line
        printf("I'am back!!!\n");
    }

    struct perf p;

    int x = wait_stat(0,&p);
    printf("ret val: %d ", x);
    printf("ctime: %d ", p.ctime);
    printf("ttime: %d ", p.ttime);
    printf("stime: %d ", p.stime);
    printf("retime: %d ", p.retime);
    printf("rutime: %d\n", p.rutime);

    return 0;
}

int cfsdTest1(){
    
    sleep(10);

    // create son
    int pid = fork();
    // int father = getpid();
    // int mask1 = (1 << SYS_sbrk);
    // int mask2 = (1 << SYS_priority);
    // trace(mask1, father);
    // trace(mask2, pid);

    // son
    if(pid == 0){
        set_priority(5);
        for (int i = 0; i < 100;i++)
            printf("pid: %d ,not here! my turn now\n", pid);
        exit(0);
    }
    // father
    else{
        for (int i = 0; i < 100; i++)
            printf("father before son!\n");
    }

    struct perf p;

    int x = wait_stat(0,&p);
    printf("ret val: %d ", x);
    printf("ctime: %d ", p.ctime);
    printf("ttime: %d ", p.ttime);
    printf("stime: %d ", p.stime);
    printf("retime: %d ", p.retime);
    printf("rutime: %d\n", p.rutime);

    return 0;
}

int cfsdTest2(){
    
    sleep(10);

    // create son
    int pid = fork();
    // int father = getpid();
    // int mask1 = (1 << SYS_sbrk);
    // int mask2 = (1 << SYS_priority);
    // trace(mask1, father);
    // trace(mask2, pid);

    // son
    if(pid == 0){
        set_priority(1);
        for (int i = 0; i < 100;i++)
            printf("pid: %d ,not here! my turn now\n", pid);
        exit(0);
    }
    // father
    else{
        for (int i = 0; i < 100; i++)
            printf("father before son!\n");
    }

    struct perf p;

    int x = wait_stat(0, &p);
    printf("ret val: %d ", x);
    printf("ctime: %d ", p.ctime);
    printf("ttime: %d ", p.ttime);
    printf("stime: %d ", p.stime);
    printf("retime: %d ", p.retime);
    printf("rutime: %d\n", p.rutime);
    printf("bursttime: %d\n", p.average_bursttime);

    return 0;
}

// ############################### TASK 4 Test #############################

int srtTest()
{
    // create son
    int pid;
    // int father = getpid();
    // int mask1 = (1 << SYS_sbrk);
    // int mask2 = (1 << SYS_priority);
    // trace(mask1, father);
    // trace(mask2, pid);

    // son
    if ((pid = fork() == 0))
    {
        for (int i = 0; i < 100; i++)
        {
            if (i%5 == 0)
            {
                sleep(5);
            }
            printf("son is running\n");
        }
        
    }
    else
    {
        sleep(5);
        for (int i = 0; i < 250; i++)
        {
            printf("father is running\n");
        }
    }
    
    
    return 0;
}

// #################################### runner ##########################

int fcfsTest2()
{

    sleep(1);

    // create son
    int pid = fork();
    // int father = getpid();
    // int mask1 = (1 << SYS_sbrk);
    // int mask2 = (1 << SYS_priority);
    // trace(mask1, father);
    // trace(mask2, pid);

    // son
    if (pid == 0)
    {   
        for(int i = 0; i < 10; i++)
            printf("son need to wait a little bit 2\n");
        int son2 = fork();
        for(int i = 0; i < 10; i++)
            printf("son need to wait a little bit 3\n");
        sleep(1);
        if(son2 != 0){
            for (int i = 0; i < 100; i++)
                printf("pid: %d ,my turn now\n", pid);
            sleep(1);
            printf("I'am alsoooo back!!!\n");
            exit(0);

        }
        for(int i = 0 ; i < 20 ; i++)
            printf("grandson is palying!\n");
        exit(0);
    }
    // father
    else
    {
        sleep(1);
        for (int i = 0; i < 100; i++)
            printf("father before son! \n");
        sleep(1); // go to the back of the line
        printf("I'am back!!!\n");
    }

    struct perf p;

    int x = wait_stat(0,&p);
    printf("ret val: %d ", x);
    printf("ctime: %d ", p.ctime);
    printf("ttime: %d ", p.ttime);
    printf("stime: %d ", p.stime);
    printf("retime: %d ", p.retime);
    printf("rutime: %d\n", p.rutime);

    return 0;
}

int main(void)
{

    int res = test();
    printf("test1 res: %d\n", res);

     printf("\n############################### TASK 4 Test #############################\n\n");
     int res1 = priorityTest();
     printf("test2 res: %d\n\n\n", res1);

    // int res2 = fcfsTest();
    // printf("fcfs test res: %d\n\n\n", res2);

    // int res4 = cfsdTest1();
    // printf("fcfs test res: %d\n\n\n", res4);

    // int res5 = cfsdTest2();
    // printf("fcfs test res: %d\n\n\n", res5);

    // int res3 = srtTest();
    // printf("srtTest res: %d\n", res3);

    exit(0);
    return 0;
}