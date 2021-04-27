// #include "kernel/param.h"
// #include "kernel/types.h"
// #include "kernel/stat.h"
// #include "user/user.h"
// #include "kernel/fs.h"
// #include "kernel/fcntl.h"
// #include "kernel/syscall.h"
// #include "kernel/memlayout.h"
// #include "kernel/riscv.h"

// void test0();
// void test1();
// void test2();
// void test3();
// void test4();
// void test5();
// void test6();
// void test7();
// void test8();
// void test9();
// void test10();
// void test11();
// void test12();
// void test13();
// void test14();
// void test15();
// void test16();


// void test0();
// void test1();
// void test2();
// void test3();
// void test4();
// void test5();
// void test6();
// void test7();
// void test8();
// void test9();
// void test10();
// void test11();
// void test12();
// void test13();
// void test14();
// void test15();
// void test16();

// int
// main(int argc, char **argv)
// {

//     // printf("****TEST0 - valid input for kill****\n");
//     // test0();
    
//     // printf("****TEST1 - sigstop& sigcont****\n");
//     // test1();

//     // printf("****TEST2 - user handled signals****\n");
//     // test2();

//     // printf("****TEST3 - change cont sa handler****\n");
//     // test3();

//     // printf("****TEST4 - kill after stop****\n");
//     // test4();

//     // printf("****TEST5 - kill two sons****\n");
//     // test5();

//     // printf("****TEST6 - kill after sleeping kid****\n");
//     // test6();

//     // printf("****TEST7 - stop, continue, kill****\n");
//     // test7();

//     // printf("****TEST8 - continue after continue****\n");
//     // test8();

//     // printf("****TEST9 - stop after stop******\n");
//     // test9();

//     // printf("****TEST10 - cont then stop a few times****\n");
//     // test10();

//     // printf("****TEST11 - continue afetr wait****\n");
//     // test11();

//     printf("****TEST12 - costume handler two kids****\n");
//     test12();

//     printf("****TEST13 - costume handler two kids****\n");
//     test13();

//     printf("****TEST14 - costume handler change to defult****\n");
//     test14();

//     // printf("******TEST15 - sigprocmask********\n");
//     // test15();

//     // printf("****TEST16 - change handler to sig kill****\n");
//     // test16();

//     // printf( "****FINISHED****\n");
//     exit(0);
// }

// void
// user_handler(int signum) {
//     fprintf( 2, "got to user handler! \n");
// }

// void
// second_user_handler(int signum) {
//     fprintf(2, "got to second user handler! \n");
// }

// int
// fib(int n){
//   if (n < 2)
//     return n;
//   else
//     return fib(n-1) + fib(n-2);
// }

// void
// test0(){
//     int pid1;
//     if((pid1 = fork()) == 0){
//         for(;;){}
//     }
//     if(kill(pid1, 32) != -1){
//         printf( "problem in general test 1");
//         exit(0);
//     }
//     if(kill(-2, SIGKILL) != -1){
//         printf( "problem in general test 1");
//         exit(0);
//     }
//     if(kill(pid1, SIGKILL) != 0){
//         printf( "problem in general test 1");
//         exit(0);
//     }
//     int status = 0;
//     wait(&status);
//     printf("******TEST0 OK******\n");
// }

// void
// test1() {
//     int pid = fork();
//     if (pid==0) {
//         for (int i=0; i<50; i++) {
//             printf( "printing\n");
//         }
//         for (int i=0; i<50; i++) {
//             printf( "printing again\n");
//         }
//     printf( "child terminate\n");
//     exit(0);
//     }

//     else {
//         sleep(10);
//         kill(pid, SIGSTOP);
//         printf( "sent stop\n");
//         sleep(100);
//         kill(pid, SIGCONT);
//         printf( "sent cont\n");
//     }

//     wait(0);
//     printf("******TEST1 OK******\n");
// }

// void
// test2() {
//     int pid;
//     struct sigaction* siguser_action = malloc(sizeof(struct sigaction));
//     siguser_action->sa_handler = user_handler;
//     siguser_action->sigmask = 25;

    
//     pid = fork();
//     if (pid==0) {
//          if (sigaction(3, siguser_action, 0) != 0) {
//              printf("after sigaaction!\n");
//             printf( "FAILED sigaction\n");
//             exit(0);
//         } 
//         else {
//             printf( "sigaction succeed\n");
//             sleep(100);
//             exit(0);
//         }
//     }

//     else {
//         sleep(10);
//         kill(pid, 3);
//         printf( "sent kill to pid: %d\n", pid);
//         sleep(100);
//         wait(0);
//         printf("******TEST2 OK******\n");
//     }
// }

// void
// test3() {
//     int pid;
//     struct sigaction* siguser_action = malloc(sizeof(struct sigaction));
//     siguser_action->sa_handler = (void*)SIGCONT;
//     siguser_action->sigmask = 0;

    
//     pid = fork();

//     if (pid==0) {
//          if (sigaction(5, siguser_action, 0) != 0) {
//             printf( "FAILED sigaction\n");
//             exit(0);
//         } 
//         else {
//             printf( "sigaction succeed\n");
//             int fib_res = fib(40);
//             printf( "pid: %d, fib(40) = %d\n", pid, fib_res);
//             exit(0);
//         }
//     }

//     else {
//         sleep(10);
//         kill(pid, SIGSTOP);
//         printf( "sent stop\n");
//         sleep(100);
//         kill(pid, 5);
//         printf( "sent cont\n");
//         wait(0);
//         printf("******TEST3 OK******\n");
//     }
// }

// void
// test4() {
//     int pid;
//     struct sigaction* siguser_action = malloc(sizeof(struct sigaction));
//     siguser_action->sa_handler = user_handler;
//     siguser_action->sigmask = 0;
    
//     pid = fork();

//     if (pid==0) {
//          if (sigaction(5, siguser_action, 0) != 0) {
//             printf( "FAILED sigaction\n");
//             exit(0);
//         } 
//         else {
//             printf( "sigaction succeed\n");
//             sleep(100);
//             exit(0);
//         }
//     }

//     else {
//         sleep(10);
//         kill(pid, SIGSTOP);
//         printf( "sent stop\n");
//         sleep(200);
//         kill(pid, SIGKILL);
//         printf( "sent kill to pid: %d\n",pid);
//         wait(0);
//         printf("******TEST4 OK******\n");
//     }
// }

// void
// test5(){
//     int pid1, pid2;
//     if((pid1=fork()) == 0){
//         for(;;){}
//     }
//     if((pid2=fork()) == 0){
//         for(;;){}
//     }
//     kill(pid1,SIGKILL);
//     kill(pid2,SIGKILL);

//     wait(0);
//     wait(0);
//     printf("******TEST5 OK******\n");
// }

// void
// test6(){
//     int pid;
//     pid = fork();
//     if(pid == 0){
//         sleep(10);
//         printf("should not happen\n");
//         exit(0);
//     }
//     kill(pid, SIGKILL);
//     wait(0);
//     printf("******TEST6 OK******\n");
// }

// void
// test7(){
//     int pids[10];
//     for(int i=0;i<10;i++){
//         if((pids[i] = fork()) == 0){
//             for(;;){}
//         }
//     }
//     for(int i=0; i<10; i++){
//         kill(pids[i],SIGSTOP);
//     }
//     for(int i=0; i<10; i++){
//         kill(pids[i],SIGCONT);
//     }
//     for(int i=0; i<10; i++){
//         kill(pids[i],SIGKILL);
//     }
//     for(int i=0; i<10; i++){
//         wait(0);
//     }
//     printf("******TEST7 OK******\n");
// }

// void
// test8(){
//     int pid;
//     pid = fork();
//     if(pid == 0){
//         while(1){}
//     }
//     for(int i=0; i<4; i++){
//         printf("sending continue\n");
//         if(kill(pid,SIGCONT) != 0){
//             printf( "never stopped - should not work\n");
//         }
//     }
//     kill(pid,SIGKILL);
//     wait(0);
//     printf("******TEST8 OK******\n");
// }

// void
// test9(){
//     int pid;
//     pid = fork();
//     if(pid == 0){
//         for(;;){}
//     }
//     for(int i=0; i<4; i++){
//         printf("sending stop\n");
//         kill(pid,SIGSTOP);
//     }
//     kill(pid,SIGKILL);
//     wait(0);
//     printf("******TEST9 OK******\n");
// }

// void
// test10(){
//     int pid;
//     pid = fork();
//     if(pid == 0){
//         for(;;){}
//     }
//     for(int i=0; i<4; i++){
//         kill(pid,SIGCONT);
//         kill(pid,SIGSTOP);
//     }
//     kill(pid, SIGKILL);
//     wait(0);
//     printf("******TEST10 OK******\n");
// }

// void
// test11(){
//     int pid1;
//     pid1 = fork();
//     if(pid1 == 0){
//         int pid2;
//         pid2 = fork();
//         if(pid2 == 0){
//             sleep(10);
//             exit(0);
//         }
//         wait(0);
//         printf("NOT GOOD!!!!!!\n");
//     }
//     kill(pid1,SIGCONT);
//     sleep(3);
//     kill(pid1,SIGKILL);
//     wait(0);
//     printf("******TEST11 OK******\n");

// }

// void
// test12(){
//     int pid1,pid2;
//     struct sigaction* siguser_action = malloc(sizeof(struct sigaction));
//     siguser_action->sa_handler = user_handler;
//     siguser_action->sigmask = 0;
//     if((pid1 = fork()) == 0){
//         sigaction(5, siguser_action, 0);
//         for(;;){}
//     }
//     if((pid2 = fork()) == 0){
//         for(;;){}
//     }
//     kill(pid2,SIGKILL);
//     wait(0);
//     kill(pid1,5);
//     sleep(100);
//     kill(pid1,SIGKILL);
//     wait(0);
//     printf("******TEST12 OK******\n");
// }

// void
// test13(){
//     int pid1,pid2;
//     struct sigaction* siguser_action_1 = malloc(sizeof(struct sigaction));
//     siguser_action_1->sa_handler = user_handler;
//     siguser_action_1->sigmask = 0;

//     struct sigaction* siguser_action_2 = malloc(sizeof(struct sigaction));
//     siguser_action_2->sa_handler = second_user_handler;
//     siguser_action_2->sigmask = 0;

//     if((pid1 = fork()) == 0){
//         sigaction(5, siguser_action_1, 0);
//         for(;;){}
//     }
//     if((pid2 = fork()) == 0){
//         sigaction(5, siguser_action_2, 0);
//         for(;;){}
//     }
//     kill(pid1,5);
//     sleep(10);
//     kill(pid1, SIGKILL);
//     kill(pid2,5);
//     sleep(10);
//     kill(pid2,SIGKILL);
//     wait(0);
//     wait(0);
//     printf("******TEST13 OK******\n");
// }

// void
// test14(){
//     int pid1,pid2;
//     struct sigaction* siguser_action_1 = malloc(sizeof(struct sigaction));
//     siguser_action_1->sa_handler = user_handler;
//     siguser_action_1->sigmask = 0;

//     struct sigaction* siguser_action_2 = malloc(sizeof(struct sigaction));
//     siguser_action_2->sa_handler = second_user_handler;
//     siguser_action_2->sigmask = 0;

//     struct sigaction* siguser_action_3 = malloc(sizeof(struct sigaction));
//     siguser_action_3->sa_handler = (void *)SIG_DFL;
//     siguser_action_3->sigmask = 0;

//     if((pid1 = fork()) == 0){
//         sigaction(1, siguser_action_1, 0);
//         fib(20);
//         sigaction(1, siguser_action_3, 0);
//         for(;;){}
//     }
//     if((pid2 = fork()) == 0){
//         sigaction(5, siguser_action_2, 0);
//         for(;;){}
//     }
//     fib(10);
//     kill(pid1,1);
//     sleep(200);
//     kill(pid1,1);
//     wait(0);
//     kill(pid2,5);
//     sleep(100);
//     kill(pid2,SIGKILL);
//     wait(0);
//     printf("******TEST14 OK******\n");
// }

// void
// test15(){
//     int pid;
//     struct sigaction* siguser_action = malloc(sizeof(struct sigaction));
//     siguser_action->sa_handler = user_handler;
//     siguser_action->sigmask = 0;
//     pid = fork();
//     if(pid == 0){
//         sigaction(1, siguser_action, 0);
//         sleep(200);
//         sigprocmask(4);
//         for(;;){}
//     }
//     sleep(100);
//     kill(pid,1);
//     sleep(300);
//     kill(pid,1);
//     sleep(100);
//     kill(pid,SIGKILL);
//     wait(0);
//     printf("******TEST15 OK******\n");
// }

// void
// test16(){
//     struct sigaction* siguser_action_1 = malloc(sizeof(struct sigaction));
//     siguser_action_1->sa_handler = user_handler;
//     siguser_action_1->sigmask = 0;

//     struct sigaction* siguser_action_2 = malloc(sizeof(struct sigaction));
//     siguser_action_2->sa_handler = (void *)SIGKILL;
//     siguser_action_2->sigmask = 0;

//     int pids[10];
//     for(int i=0; i<10; i++){
//         if((pids[i]=fork()) == 0){
//             sigaction(1, siguser_action_1, 0);
//             sigaction(5, siguser_action_2, 0);
//             for(;;){}
//         }

//     }
//     sleep(100);
//     for(int i=0; i<10; i++){
//         kill(pids[i], 1);
//     }
//     for(int i=0; i<10; i++){
//         kill(pids[i], 5);
//     }
//     for(int i=0; i<10; i++){
//         wait(0);
//     }
//     printf("******TEST16 OK******\n");
// }