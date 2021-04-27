#include "../kernel/param.h"
#include "../kernel/types.h"
#include "../kernel/stat.h"
#include "user.h"
#include "../kernel/fs.h"
#include "../kernel/fcntl.h"
#include "../kernel/syscall.h"
#include "../kernel/memlayout.h"
#include "../kernel/riscv.h"

struct sigaction {
  void (*sa_handler) (int);
  uint sigmask;
};

void test_sigkill();
void sig_handler(int);
void test_stop_cont();
void sig_handler_loop(int);


void 
test_sigkill(){//
   int pid = fork();
    if(pid==0){
        sleep(5);
        for(int i=0;i<300;i++)
            printf("about to get killed %d\n",i);
        // exit(0);
    }
    else{
        sleep(7);
        printf("parent send signal to to kill child\n");
        printf("kill ret= %d\n",kill(pid, SIGKILL));
        printf("parent wait for child\n");
        wait(0);
        printf("parent: child is dead\n");
        sleep(10);
        exit(0);
    }
}



void
sig_handler(int signum){
    char st[5] = "wap\n";
    write(1, st, 5);
    return;
}

void
sig_handler_loop(int signum){
    char st[5] = "dap\n";
    for(int i=0;i<500;i++){
        // write(1,i,sizeof(int));
        write(1, st, 5);
    }
    
    return;
}
void
sig_handler2(int signum){
    char st[5] = "dap\n";
    write(1, st, 5);
    return;
}


void 
test_usersig(){
    int pid = fork();
    int signum1=3;
    if(pid==0){
        struct sigaction act;
        struct sigaction act2;

        printf("sighandler= %p\n",&sig_handler);
        printf("sighandler= %p\n",&sig_handler2);
        uint mask = 0;
        mask ^= (1<<22);

        act.sa_handler = &sig_handler2;
        act.sigmask = mask;
        // act2.sa_handler = &sig_handler2;
        // act2.sigmask = mask;

        struct sigaction oldact;
        oldact.sigmask=0;
        oldact.sa_handler=0;
        int ret=sigaction(signum1,&act,&oldact);
        // int ret2=sigaction(3,&act2,&oldact);
        printf("old act->sa handler= %p, mask=%d\n",oldact.sa_handler,oldact.sigmask);
        printf("child return from sigaction = %d\n",ret);
        sleep(10);
        for(int i=0;i<10;i++){
            printf("child doing stuff before exit \n");
        }

        exit(0);

    }
    else{
        sleep(5);
        printf("parent send sig 3 to child ret=%d\n",kill(pid,signum1));
        // printf("parent send sig 4 to child ret=%d\n",kill(pid,4));

        wait(0);
        exit(0);
    }
}
void 
test_block(){//parent block 22 child block 23 
//          child get both signal and need do block the both

    int signum1=22;
    int signum2=23;
    int ans=sigprocmask(1<<signum1);
    printf("got %d from calling to sigprocmask\n",ans);
    int pid=fork();
    if(pid==0){
        // ans=sigprocmask(1<<signum2);
        // printf("child got %d from calling to sigprocmask\n",ans);
        sleep(3);
        for(int i=0;i<100;i++){
            printf("child blocking signal %d :-)\n",i);
        }
        exit(0);

    }else{
        sleep(1);//wait for child to block sig
        kill(pid,signum1);
        printf("parent: sent signal 22 to child ->child shuld block\n");
        // kill(pid,signum2);
        printf("parent: sent signal 23 to child ->child shuld block\n");
        wait(0);
    }
    // exit(0);
}

void
test_stop_cont(){
    int pid = fork();
    int i;
    if(pid==0){
        sleep(2);
        for(i=0;i<500;i++)
            printf("%d\n ", i);
        exit(0);
    }else{
        printf("son pid=%d, dad pid=%d\n",pid, getpid());
        sleep(5);
        printf("parent send stop ret= %d\n",kill(pid, SIGSTOP));
        sleep(50);
        printf("parent send continue ret= %d\n",kill(pid, SIGCONT));
        wait(0);
        // for(int i=0;i<100;i++)
        //  printf("parent..");
        sleep(10);
        exit(0);
    }
}

void 
test_ignore(){
    int pid= fork();
    int signum=22;
    if(pid==0){
        struct sigaction* newAct;
        newAct=malloc(sizeof(sigaction));
        struct sigaction* oldAct;
        oldAct=malloc(sizeof(sigaction));

        newAct->sigmask = 0;
        newAct->sa_handler=(void*)SIG_IGN;
        int ans=sigaction(signum,newAct,oldAct);
        printf("ans from sigaction %d, old act returned is: mask= %d address= %d\n",ans,oldAct->sigmask,(uint64)oldAct->sa_handler);
        
        sleep(6);
        for(int i=0;i<300;i++){
            printf("child ignoring signal :-)\n");
        }
        exit(0);

    }else{
        printf("son pid= %d",pid);
        sleep(5);
        kill(pid,signum);
        wait(0);

    }
}
void
test_stop_stop_kill(){
    struct sigaction act;

    printf("sighandler= %p\n",&sig_handler_loop);
    uint mask = 0;
    mask ^= (1<<22);

    act.sigmask = mask;
    act.sa_handler=&sig_handler_loop;

    struct sigaction oldact;
    oldact.sigmask=0;
    oldact.sa_handler=0;
    


    int pid = fork();
    int i;
    if(pid==0){
        int ret=sigaction(3,&act,&oldact);
        for(i=0;i<500;i++)
            printf("out-side handler %d\n ", i);
        exit(0);
    }else{
        printf("son pid=%d, dad pid=%d\n",pid, getpid());
        sleep(5);
        printf("parent send loop ret= %d\n",kill(pid, 3));
        sleep(1);
        printf("parent send kill ret= %d\n",kill(pid, SIGKILL));
        // kill(pid,SIGKILL);
        wait(0);
        printf("parent exiting\n");
        exit(0);
    }
}


int main(){
    // printf("-----------------------------test_sigkill-----------------------------\n");
    // test_sigkill();

    //  printf("-----------------------------test_stop_cont_sig-----------------------------\n");
    // test_stop_cont();
    
    // printf("-----------------------------test_usersig-----------------------------\n");
    // test_usersig();
    // printf("-----------------------------test_block-----------------------------\n");
    // test_block();
    // printf("-----------------------------test_ignore-----------------------------\n");
    // test_ignore();
    printf("-----------------------------test_stop_stop_kill-----------------------------\n");
    test_stop_stop_kill();



    exit(0);
    return 0;
}

