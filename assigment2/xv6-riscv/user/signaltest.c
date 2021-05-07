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
void sig_handler_loop2(int);
void test_thread();
void test_thread2();
void test_thread_loop();


void test_thread(){
    sleep(5);
    printf("Thread is now running tid=%d\n",kthread_id());
    kthread_exit(9);
}
void test_thread_loop(){
    sleep(5);
    for(int i=0;i<100;i++){
        printf("%d:Thread is now running tid=%d\n",i,kthread_id());
    }
    kthread_exit(9);
}
void test_thread2(){
    sleep(5);
    printf("Thread is now running tid=%d\n",kthread_id());
    kthread_exit(9);
}


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
        write(1, st, 5);
    }
    
    return;
}
void
sig_handler_loop2(int signum){
    char st[5] = "dap\n";
    for(int i=0;i<500;i++){
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

        printf("sighandler= %p\n",&sig_handler2);
        uint mask = 0;
        mask ^= (1<<22);

        act.sa_handler = &sig_handler2;
        act.sigmask = mask;
        

        struct sigaction oldact;
        oldact.sigmask=0;
        oldact.sa_handler=0;
        int ret=sigaction(signum1,&act,&oldact);
        printf("old act->sa handler= %p, mask=%d\n",oldact.sa_handler,oldact.sigmask);
        printf("child return from sigaction = %d\n",ret);
        sleep(10);
        for(int i=0;i<10;i++){
            printf("child doing stuff before exit \n");
        }
        ret=sigaction(signum1,&act,&oldact);
        printf("oldact should be the same as new act before \n oldact->mask=%d \t oldact->sa_handler=%d \n",oldact.sigmask,oldact.sa_handler);

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
        for(int i=0;i<1000;i++){
            sleep(1);
            printf("child blocking signal %d \n",i);
        }
        exit(0);

    }else{
        sleep(1);//wait for child to block sig
        printf("parent: sent signal 22 to child ->child shuld block\n");
        for(int i=0; i<10;i++){
            kill(pid,signum1);
        }
        sleep(10);
        kill(pid,signum2);

        printf("parent: sent signal 23 to child ->child shuld die\n");
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
        for(i=0;i<500;i++){
            printf("%d\n ", i);
        }
        exit(0);
    }else{
        printf("son pid=%d, dad pid=%d\n", pid, getpid());
        sleep(5);
        printf("parent send stop ret= %d\n", kill(pid, SIGSTOP));
        sleep(50);
        printf("parent send continue ret= %d\n", kill(pid, SIGCONT));
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
            printf("child ignoring signal %d\n",i);
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
test_user_handler_kill(){
    struct sigaction act;

    printf("sighandler1= %p\n", &sig_handler_loop);
    printf("sighandler2= %p\n", &sig_handler_loop2);


    uint mask = 0;
    mask ^= (1<<22);

    act.sigmask = mask;
    
    struct sigaction oldact;
    oldact.sigmask=0;
    oldact.sa_handler=0;
    
    act.sa_handler=&sig_handler_loop2;


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
        sleep(20);
        printf("parent send kill ret= %d\n",kill(pid, SIGKILL));
        wait(0);
        printf("parent exiting\n");
        exit(0);
    }
}

//TODO delete func
void thread_test(char *s){
    int tid;
    int status;
    void* stack = malloc(4000);
    printf("father tid is = %d\n",kthread_id());
    tid = kthread_create(test_thread, stack);
    printf("child tid %d",tid);
    printf("father tid is = %d\n",kthread_id());

    int ans =kthread_join(tid, &status);
    printf("kthread join ret =%d , my tid =%d\n",ans,kthread_id());
    tid = kthread_id();
    free(stack);
    printf("Finished testing threads, main thread id: %d, %d\n", tid,status);
}
void thread_test2(char *s){
    int tid;
    int status;
    void* stack = malloc(4000);
    printf("after malloc\n");
    printf("add of func for new thread : %p\n",&test_thread);
    printf("add of func for new thread : %p\n",&test_thread2);

    tid = kthread_create(&test_thread2, stack);
    
    printf("after create %d \n",tid);

    sleep(5);
    printf("after kthread\n");
    tid = kthread_id();
    free(stack);
    printf("Finished testing threads, main thread id: %d, %d\n", tid,status);
}

void very_easy_thread_test(char *s){
    int tid;
    int status;
    void* stack = malloc(4000);
    printf("add of func for new thread : %p\n",&test_thread);

    tid = kthread_create(&test_thread_loop, stack);
    
    printf("after create ret tid= %d mytid= %d\n",tid,kthread_id());

    free(stack);
    printf("Finished testing threads, main thread id: %d\n", kthread_id());
    kthread_exit(0);
}


void
reparent(char *s)
{
  int master_pid = getpid();
  for(int i = 0; i < 200; i++){
    int pid = fork();
    if(pid < 0){
      printf("%s: fork failed\n", s);
      exit(1);
    }
    if(pid){
      if(wait(0) != pid){
        printf("%s: wait wrong pid\n", s);
        exit(1);
      }
    } else {
      int pid2 = fork();
      if(pid2 < 0){
        // kill(master_pid, SIGKILL);
        exit(1);
      }
      exit(0);
    }
  }
  exit(0);
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
    // printf("-----------------------------test_user_handler_then_kill-----------------------------\n");
    // test_user_handler_kill();

    // printf("-----------------------------thread_test-----------------------------\n");
    // thread_test("fuck");

    // printf("-----------------------------very easy thread test-----------------------------\n");
    // very_easy_thread_test("ff");


    printf("-----------------------------reparent test-----------------------------\n");
    reparent("ff");

    exit(0);
    return 0;
}

