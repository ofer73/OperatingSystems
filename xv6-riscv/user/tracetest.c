#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"


#define SYS_fork    1
#define SYS_exit    2
#define SYS_wait    3
#define SYS_pipe    4
#define SYS_read    5
#define SYS_kill    6
#define SYS_exec    7
#define SYS_fstat   8
#define SYS_chdir   9
#define SYS_dup    10
#define SYS_getpid 11
#define SYS_sbrk   12
#define SYS_sleep  13
#define SYS_uptime 14
#define SYS_open   15
#define SYS_write  16
#define SYS_mknod  17
#define SYS_unlink 18
#define SYS_link   19
#define SYS_mkdir  20
#define SYS_close  21
#define SYS_trace  22

void
test_fork(void){
  int pid = getpid();
  int ans=trace(1 << SYS_fork|1 << SYS_sbrk|1<<SYS_mkdir,pid);
  int ans2= trace(1<<SYS_kill,1234);
  // trace(,pid);
  int child = fork();
  if(child == 0){
    sbrk(4096);
    char* name="amit";
    mkdir(name);
    exit(0);
  }
  else{
    // trace(1<<SYS_mkdir,child);
    wait(0);
    printf("ans should be 0 = %d\n",ans);
    printf("ans should be -1 = %d\n",ans2);
  }
  exit(0);
} 

void
test_sbrk(void){
  int pid = getpid();
  trace(1 << SYS_sbrk,pid);
  sbrk(4096);
  exit(0);
} 

void
test_kill(void){
  int pid = getpid();
  trace(1 << SYS_kill,pid);
  int child = fork();
  if(child == 0){
    sleep(100);
    exit(0);
  }
  else{
    printf("in tracetest, kill child = %d\n",child);
    kill(child);
    wait(0);
    kill(child);
  }
  exit(0);
}

void
test_write(void){
  int pid = getpid();
  trace(1 << SYS_write,pid);
  char* buf="amit";
  write(1,buf,4);
  exit(0);
} 

int
main(int argc, char *argv[])
{
  test_fork();
  // test_kill();
  // test_sbrk();
  // test_write();
  return 0;
}





