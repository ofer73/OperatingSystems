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



void
sig_handler(int signum){
    char st[3] = "wap";
    write(1, st, 3);
    return;
}

void 
test_sigkill(){//
   int pid = fork();
    if(pid==0){
        sleep(5);
        for(int i=0;i<30;i++)
            printf("about to get killed\n");
    }
    else{
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
test_stop_cont(){
    int pid = fork();
    if(pid==0){
        for(int i=0;i<100;i++)
            printf("child..\n ");
    }
    else{
        // printf("parent send signal to to stop child\n");
        printf("sigstop ret= %d\n",kill(pid, SIGSTOP));
        // printf("parent: go to sleep \n");
        sleep(5);
        // printf("parent: wakeup \n");
        // printf("parent send signal to to continue child\n");
        printf("sigstop ret= %d\n",kill(pid, SIGCONT));
        sleep(10);
        exit(0);
    }
    

}
void 
test_usersig(){//
   int pid = fork();
    if(pid==0){
        struct sigaction act;
        act.sa_handler = &sig_handler;
        act.sigmask = 0;
        struct sigaction oldact;
        sigaction(3,&act,&oldact);
    }
    else{
      sleep(10);

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
        ans=sigprocmask(1<<signum2);
        printf("child got %d from calling to sigprocmask\n",ans);
        sleep(3);
        for(int i=0;i<10;i++){
            printf("child blocking signal :-)\n");
        }

    }else{
        sleep(1);//wait for child to block sig
        kill(pid,signum1);
        printf("parent: sent signal 22 to child ->child shuld block\n");
        kill(pid,signum2);
        printf("parent: sent signal 23 to child ->child shuld block\n");

    }
}

void 
test_ignore(){
    int pid= fork();
    int signum=22;
    if(pid==0){
        struct sigaction newAct;
        struct sigaction oldAct;
        newAct.sigmask = 0;
        newAct.sa_handler=(void*)SIG_IGN;
        int ans=sigaction(signum,&newAct,&oldAct);
        printf("ans from sigaction %d, old act returned is: mask= %d address= %d",ans,oldAct.sigmask,(int)oldAct.sa_handler);
        
        sleep(6);
        for(int i=0;i<10;i++){
            printf("child ignoring signal :-)\n");
        }
    }else{
        sleep(5);
        kill(pid,signum);

    }
}



int main(){
    // printf("-----------------------------test_sigkill-----------------------------\n");
    // test_sigkill();

     printf("-----------------------------test_stop_cont_sig-----------------------------\n");
    test_stop_cont();

    
    // printf("-----------------------------test_usersig-----------------------------\n");
    //test_usersig();
    // printf("-----------------------------test_block-----------------------------\n");
    // test_block();
    // printf("-----------------------------test_ignore-----------------------------\n");
    // test_ignore();
    return 0;
}