#include "kernel/types.h"
#include "kernel/stat.h"
//#include "kernel/defs.h"
#include "user/user.h"
#include "kernel/perf.h"


// struct perf {
//   int ctime;        // process creation time
//   int ttime;        // process termination time
//   int stime;        // the total time the process spent in the SLEEPING state
//   int retime;       // the total time the process spent in the RUNNABLE state
//   int rutime;       // the total time the process spent in the RUNNING state
//   float bursttime;  // approximate estimated burst time
// };

void print_perf(struct perf *performance) {
    fprintf(1, "perf:\n");
    fprintf(1, "\tctime: %d\n", performance->ctime);
    fprintf(1, "\tttime: %d\n", performance->ttime);
    fprintf(1, "\tstime: %d\n", performance->stime);
    fprintf(1, "\tretime: %d\n", performance->retime);
    fprintf(1, "\trutime: %d\n", performance->rutime);
    fprintf(1, "\tavarage_btime: %d\n", performance->average_bursttime);
    fprintf(1, "\n\tTurnaround time: %d\n", (performance->ttime - performance->ctime));
}

// hello i'm a child
// hello i'm a child
// hello i'm a child
// hello i'm a child
// scause 0x0000000000000002
// sepc=0x0000000080001d86 stval=0x0000000000000000
// panic: kerneltrap

void test3(){
		int pid1,pid2, status1,status2;
	struct perf perf2,perf3;
	pid1 = fork();
	
	if (pid1 > 0) { //parent
	
		int s = wait_stat(&status1, &perf2);
		printf("pid is: %d\n", s);
		print_perf(&perf2);
	}
	 else { //child
	 	sleep(10);
		for (int i = 0; i < 20; i++){
			write(1, "hello i'm a child\n", 18);
		}
		sleep(10);
		pid2=fork();
	 	if(pid2==0){//second child
		sleep(10);
		for (int i = 0; i < 20; i++){
			write(1, "hello i'm the second child\n", 28);
		}
		exit(1);
		}
		else//first child
		{
			int s = wait_stat(&status2, &perf3);
			printf("secund child pid is: %d\n", s);
			print_perf(&perf3);
		}

    }
	exit(0);
}
void testFCFS(){
	int pid1=fork();
	if(pid1==0){
		for(;;){}
	}
	else {
		for(int i=0;i<100;i++){
			write(1, "hello i'm a parent\n", 20);
		}
	}

}

int main(int argc, char** argv){
	printf("starting tests");
	  test3();
	// testFCFS();
	exit(0);
}