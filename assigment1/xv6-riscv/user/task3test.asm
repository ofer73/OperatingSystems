
user/_task3test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print_perf>:
//   int retime;       // the total time the process spent in the RUNNABLE state
//   int rutime;       // the total time the process spent in the RUNNING state
//   float bursttime;  // approximate estimated burst time
// };

void print_perf(struct perf *performance) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
    fprintf(1, "perf:\n");
   c:	00001597          	auipc	a1,0x1
  10:	99c58593          	addi	a1,a1,-1636 # 9a8 <malloc+0xe8>
  14:	4505                	li	a0,1
  16:	00000097          	auipc	ra,0x0
  1a:	7be080e7          	jalr	1982(ra) # 7d4 <fprintf>
    fprintf(1, "\tctime: %d\n", performance->ctime);
  1e:	4090                	lw	a2,0(s1)
  20:	00001597          	auipc	a1,0x1
  24:	99058593          	addi	a1,a1,-1648 # 9b0 <malloc+0xf0>
  28:	4505                	li	a0,1
  2a:	00000097          	auipc	ra,0x0
  2e:	7aa080e7          	jalr	1962(ra) # 7d4 <fprintf>
    fprintf(1, "\tttime: %d\n", performance->ttime);
  32:	40d0                	lw	a2,4(s1)
  34:	00001597          	auipc	a1,0x1
  38:	98c58593          	addi	a1,a1,-1652 # 9c0 <malloc+0x100>
  3c:	4505                	li	a0,1
  3e:	00000097          	auipc	ra,0x0
  42:	796080e7          	jalr	1942(ra) # 7d4 <fprintf>
    fprintf(1, "\tstime: %d\n", performance->stime);
  46:	4490                	lw	a2,8(s1)
  48:	00001597          	auipc	a1,0x1
  4c:	98858593          	addi	a1,a1,-1656 # 9d0 <malloc+0x110>
  50:	4505                	li	a0,1
  52:	00000097          	auipc	ra,0x0
  56:	782080e7          	jalr	1922(ra) # 7d4 <fprintf>
    fprintf(1, "\tretime: %d\n", performance->retime);
  5a:	44d0                	lw	a2,12(s1)
  5c:	00001597          	auipc	a1,0x1
  60:	98458593          	addi	a1,a1,-1660 # 9e0 <malloc+0x120>
  64:	4505                	li	a0,1
  66:	00000097          	auipc	ra,0x0
  6a:	76e080e7          	jalr	1902(ra) # 7d4 <fprintf>
    fprintf(1, "\trutime: %d\n", performance->rutime);
  6e:	4890                	lw	a2,16(s1)
  70:	00001597          	auipc	a1,0x1
  74:	98058593          	addi	a1,a1,-1664 # 9f0 <malloc+0x130>
  78:	4505                	li	a0,1
  7a:	00000097          	auipc	ra,0x0
  7e:	75a080e7          	jalr	1882(ra) # 7d4 <fprintf>
    fprintf(1, "\tavarage_btime: %d\n", performance->average_bursttime);
  82:	48d0                	lw	a2,20(s1)
  84:	00001597          	auipc	a1,0x1
  88:	97c58593          	addi	a1,a1,-1668 # a00 <malloc+0x140>
  8c:	4505                	li	a0,1
  8e:	00000097          	auipc	ra,0x0
  92:	746080e7          	jalr	1862(ra) # 7d4 <fprintf>
    fprintf(1, "\n\tTurnaround time: %d\n", (performance->ttime - performance->ctime));
  96:	40d0                	lw	a2,4(s1)
  98:	409c                	lw	a5,0(s1)
  9a:	9e1d                	subw	a2,a2,a5
  9c:	00001597          	auipc	a1,0x1
  a0:	97c58593          	addi	a1,a1,-1668 # a18 <malloc+0x158>
  a4:	4505                	li	a0,1
  a6:	00000097          	auipc	ra,0x0
  aa:	72e080e7          	jalr	1838(ra) # 7d4 <fprintf>
}
  ae:	60e2                	ld	ra,24(sp)
  b0:	6442                	ld	s0,16(sp)
  b2:	64a2                	ld	s1,8(sp)
  b4:	6105                	addi	sp,sp,32
  b6:	8082                	ret

00000000000000b8 <test3>:
// hello i'm a child
// scause 0x0000000000000002
// sepc=0x0000000080001d86 stval=0x0000000000000000
// panic: kerneltrap

void test3(){
  b8:	711d                	addi	sp,sp,-96
  ba:	ec86                	sd	ra,88(sp)
  bc:	e8a2                	sd	s0,80(sp)
  be:	e4a6                	sd	s1,72(sp)
  c0:	e0ca                	sd	s2,64(sp)
  c2:	1080                	addi	s0,sp,96
		int pid1,pid2, status1,status2;
	struct perf perf2,perf3;
	pid1 = fork();
  c4:	00000097          	auipc	ra,0x0
  c8:	3a6080e7          	jalr	934(ra) # 46a <fork>
	
	if (pid1 > 0) { //parent
  cc:	02a05e63          	blez	a0,108 <test3+0x50>
	
		int s = wait_stat(&status1, &perf2);
  d0:	fc040593          	addi	a1,s0,-64
  d4:	fdc40513          	addi	a0,s0,-36
  d8:	00000097          	auipc	ra,0x0
  dc:	442080e7          	jalr	1090(ra) # 51a <wait_stat>
  e0:	85aa                	mv	a1,a0
		printf("pid is: %d\n", s);
  e2:	00001517          	auipc	a0,0x1
  e6:	94e50513          	addi	a0,a0,-1714 # a30 <malloc+0x170>
  ea:	00000097          	auipc	ra,0x0
  ee:	718080e7          	jalr	1816(ra) # 802 <printf>
		print_perf(&perf2);
  f2:	fc040513          	addi	a0,s0,-64
  f6:	00000097          	auipc	ra,0x0
  fa:	f0a080e7          	jalr	-246(ra) # 0 <print_perf>
			printf("secund child pid is: %d\n", s);
			print_perf(&perf3);
		}

    }
	exit(0);
  fe:	4501                	li	a0,0
 100:	00000097          	auipc	ra,0x0
 104:	372080e7          	jalr	882(ra) # 472 <exit>
	 	sleep(10);
 108:	4529                	li	a0,10
 10a:	00000097          	auipc	ra,0x0
 10e:	3f8080e7          	jalr	1016(ra) # 502 <sleep>
 112:	44d1                	li	s1,20
			write(1, "hello i'm a child\n", 18);
 114:	00001917          	auipc	s2,0x1
 118:	92c90913          	addi	s2,s2,-1748 # a40 <malloc+0x180>
 11c:	4649                	li	a2,18
 11e:	85ca                	mv	a1,s2
 120:	4505                	li	a0,1
 122:	00000097          	auipc	ra,0x0
 126:	370080e7          	jalr	880(ra) # 492 <write>
		for (int i = 0; i < 20; i++){
 12a:	34fd                	addiw	s1,s1,-1
 12c:	f8e5                	bnez	s1,11c <test3+0x64>
		sleep(10);
 12e:	4529                	li	a0,10
 130:	00000097          	auipc	ra,0x0
 134:	3d2080e7          	jalr	978(ra) # 502 <sleep>
		pid2=fork();
 138:	00000097          	auipc	ra,0x0
 13c:	332080e7          	jalr	818(ra) # 46a <fork>
	 	if(pid2==0){//second child
 140:	e90d                	bnez	a0,172 <test3+0xba>
		sleep(10);
 142:	4529                	li	a0,10
 144:	00000097          	auipc	ra,0x0
 148:	3be080e7          	jalr	958(ra) # 502 <sleep>
 14c:	44d1                	li	s1,20
			write(1, "hello i'm the second child\n", 28);
 14e:	00001917          	auipc	s2,0x1
 152:	90a90913          	addi	s2,s2,-1782 # a58 <malloc+0x198>
 156:	4671                	li	a2,28
 158:	85ca                	mv	a1,s2
 15a:	4505                	li	a0,1
 15c:	00000097          	auipc	ra,0x0
 160:	336080e7          	jalr	822(ra) # 492 <write>
		for (int i = 0; i < 20; i++){
 164:	34fd                	addiw	s1,s1,-1
 166:	f8e5                	bnez	s1,156 <test3+0x9e>
		exit(1);
 168:	4505                	li	a0,1
 16a:	00000097          	auipc	ra,0x0
 16e:	308080e7          	jalr	776(ra) # 472 <exit>
			int s = wait_stat(&status2, &perf3);
 172:	fa840593          	addi	a1,s0,-88
 176:	fd840513          	addi	a0,s0,-40
 17a:	00000097          	auipc	ra,0x0
 17e:	3a0080e7          	jalr	928(ra) # 51a <wait_stat>
 182:	85aa                	mv	a1,a0
			printf("secund child pid is: %d\n", s);
 184:	00001517          	auipc	a0,0x1
 188:	8f450513          	addi	a0,a0,-1804 # a78 <malloc+0x1b8>
 18c:	00000097          	auipc	ra,0x0
 190:	676080e7          	jalr	1654(ra) # 802 <printf>
			print_perf(&perf3);
 194:	fa840513          	addi	a0,s0,-88
 198:	00000097          	auipc	ra,0x0
 19c:	e68080e7          	jalr	-408(ra) # 0 <print_perf>
 1a0:	bfb9                	j	fe <test3+0x46>

00000000000001a2 <testFCFS>:
}
void testFCFS(){
 1a2:	1101                	addi	sp,sp,-32
 1a4:	ec06                	sd	ra,24(sp)
 1a6:	e822                	sd	s0,16(sp)
 1a8:	e426                	sd	s1,8(sp)
 1aa:	e04a                	sd	s2,0(sp)
 1ac:	1000                	addi	s0,sp,32
	int pid1=fork();
 1ae:	00000097          	auipc	ra,0x0
 1b2:	2bc080e7          	jalr	700(ra) # 46a <fork>
	if(pid1==0){
 1b6:	e111                	bnez	a0,1ba <testFCFS+0x18>
		for(;;){}
 1b8:	a001                	j	1b8 <testFCFS+0x16>
 1ba:	06400493          	li	s1,100
	}
	else {
		for(int i=0;i<100;i++){
			write(1, "hello i'm a parent\n", 20);
 1be:	00001917          	auipc	s2,0x1
 1c2:	8da90913          	addi	s2,s2,-1830 # a98 <malloc+0x1d8>
 1c6:	4651                	li	a2,20
 1c8:	85ca                	mv	a1,s2
 1ca:	4505                	li	a0,1
 1cc:	00000097          	auipc	ra,0x0
 1d0:	2c6080e7          	jalr	710(ra) # 492 <write>
		for(int i=0;i<100;i++){
 1d4:	34fd                	addiw	s1,s1,-1
 1d6:	f8e5                	bnez	s1,1c6 <testFCFS+0x24>
		}
	}

}
 1d8:	60e2                	ld	ra,24(sp)
 1da:	6442                	ld	s0,16(sp)
 1dc:	64a2                	ld	s1,8(sp)
 1de:	6902                	ld	s2,0(sp)
 1e0:	6105                	addi	sp,sp,32
 1e2:	8082                	ret

00000000000001e4 <main>:

int main(int argc, char** argv){
 1e4:	1141                	addi	sp,sp,-16
 1e6:	e406                	sd	ra,8(sp)
 1e8:	e022                	sd	s0,0(sp)
 1ea:	0800                	addi	s0,sp,16
	printf("starting tests");
 1ec:	00001517          	auipc	a0,0x1
 1f0:	8c450513          	addi	a0,a0,-1852 # ab0 <malloc+0x1f0>
 1f4:	00000097          	auipc	ra,0x0
 1f8:	60e080e7          	jalr	1550(ra) # 802 <printf>
	  test3();
 1fc:	00000097          	auipc	ra,0x0
 200:	ebc080e7          	jalr	-324(ra) # b8 <test3>

0000000000000204 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 204:	1141                	addi	sp,sp,-16
 206:	e422                	sd	s0,8(sp)
 208:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 20a:	87aa                	mv	a5,a0
 20c:	0585                	addi	a1,a1,1
 20e:	0785                	addi	a5,a5,1
 210:	fff5c703          	lbu	a4,-1(a1)
 214:	fee78fa3          	sb	a4,-1(a5)
 218:	fb75                	bnez	a4,20c <strcpy+0x8>
    ;
  return os;
}
 21a:	6422                	ld	s0,8(sp)
 21c:	0141                	addi	sp,sp,16
 21e:	8082                	ret

0000000000000220 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 220:	1141                	addi	sp,sp,-16
 222:	e422                	sd	s0,8(sp)
 224:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 226:	00054783          	lbu	a5,0(a0)
 22a:	cb91                	beqz	a5,23e <strcmp+0x1e>
 22c:	0005c703          	lbu	a4,0(a1)
 230:	00f71763          	bne	a4,a5,23e <strcmp+0x1e>
    p++, q++;
 234:	0505                	addi	a0,a0,1
 236:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 238:	00054783          	lbu	a5,0(a0)
 23c:	fbe5                	bnez	a5,22c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 23e:	0005c503          	lbu	a0,0(a1)
}
 242:	40a7853b          	subw	a0,a5,a0
 246:	6422                	ld	s0,8(sp)
 248:	0141                	addi	sp,sp,16
 24a:	8082                	ret

000000000000024c <strlen>:

uint
strlen(const char *s)
{
 24c:	1141                	addi	sp,sp,-16
 24e:	e422                	sd	s0,8(sp)
 250:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 252:	00054783          	lbu	a5,0(a0)
 256:	cf91                	beqz	a5,272 <strlen+0x26>
 258:	0505                	addi	a0,a0,1
 25a:	87aa                	mv	a5,a0
 25c:	4685                	li	a3,1
 25e:	9e89                	subw	a3,a3,a0
 260:	00f6853b          	addw	a0,a3,a5
 264:	0785                	addi	a5,a5,1
 266:	fff7c703          	lbu	a4,-1(a5)
 26a:	fb7d                	bnez	a4,260 <strlen+0x14>
    ;
  return n;
}
 26c:	6422                	ld	s0,8(sp)
 26e:	0141                	addi	sp,sp,16
 270:	8082                	ret
  for(n = 0; s[n]; n++)
 272:	4501                	li	a0,0
 274:	bfe5                	j	26c <strlen+0x20>

0000000000000276 <memset>:

void*
memset(void *dst, int c, uint n)
{
 276:	1141                	addi	sp,sp,-16
 278:	e422                	sd	s0,8(sp)
 27a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 27c:	ca19                	beqz	a2,292 <memset+0x1c>
 27e:	87aa                	mv	a5,a0
 280:	1602                	slli	a2,a2,0x20
 282:	9201                	srli	a2,a2,0x20
 284:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 288:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 28c:	0785                	addi	a5,a5,1
 28e:	fee79de3          	bne	a5,a4,288 <memset+0x12>
  }
  return dst;
}
 292:	6422                	ld	s0,8(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret

0000000000000298 <strchr>:

char*
strchr(const char *s, char c)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	cb99                	beqz	a5,2b8 <strchr+0x20>
    if(*s == c)
 2a4:	00f58763          	beq	a1,a5,2b2 <strchr+0x1a>
  for(; *s; s++)
 2a8:	0505                	addi	a0,a0,1
 2aa:	00054783          	lbu	a5,0(a0)
 2ae:	fbfd                	bnez	a5,2a4 <strchr+0xc>
      return (char*)s;
  return 0;
 2b0:	4501                	li	a0,0
}
 2b2:	6422                	ld	s0,8(sp)
 2b4:	0141                	addi	sp,sp,16
 2b6:	8082                	ret
  return 0;
 2b8:	4501                	li	a0,0
 2ba:	bfe5                	j	2b2 <strchr+0x1a>

00000000000002bc <gets>:

char*
gets(char *buf, int max)
{
 2bc:	711d                	addi	sp,sp,-96
 2be:	ec86                	sd	ra,88(sp)
 2c0:	e8a2                	sd	s0,80(sp)
 2c2:	e4a6                	sd	s1,72(sp)
 2c4:	e0ca                	sd	s2,64(sp)
 2c6:	fc4e                	sd	s3,56(sp)
 2c8:	f852                	sd	s4,48(sp)
 2ca:	f456                	sd	s5,40(sp)
 2cc:	f05a                	sd	s6,32(sp)
 2ce:	ec5e                	sd	s7,24(sp)
 2d0:	1080                	addi	s0,sp,96
 2d2:	8baa                	mv	s7,a0
 2d4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2d6:	892a                	mv	s2,a0
 2d8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2da:	4aa9                	li	s5,10
 2dc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2de:	89a6                	mv	s3,s1
 2e0:	2485                	addiw	s1,s1,1
 2e2:	0344d863          	bge	s1,s4,312 <gets+0x56>
    cc = read(0, &c, 1);
 2e6:	4605                	li	a2,1
 2e8:	faf40593          	addi	a1,s0,-81
 2ec:	4501                	li	a0,0
 2ee:	00000097          	auipc	ra,0x0
 2f2:	19c080e7          	jalr	412(ra) # 48a <read>
    if(cc < 1)
 2f6:	00a05e63          	blez	a0,312 <gets+0x56>
    buf[i++] = c;
 2fa:	faf44783          	lbu	a5,-81(s0)
 2fe:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 302:	01578763          	beq	a5,s5,310 <gets+0x54>
 306:	0905                	addi	s2,s2,1
 308:	fd679be3          	bne	a5,s6,2de <gets+0x22>
  for(i=0; i+1 < max; ){
 30c:	89a6                	mv	s3,s1
 30e:	a011                	j	312 <gets+0x56>
 310:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 312:	99de                	add	s3,s3,s7
 314:	00098023          	sb	zero,0(s3)
  return buf;
}
 318:	855e                	mv	a0,s7
 31a:	60e6                	ld	ra,88(sp)
 31c:	6446                	ld	s0,80(sp)
 31e:	64a6                	ld	s1,72(sp)
 320:	6906                	ld	s2,64(sp)
 322:	79e2                	ld	s3,56(sp)
 324:	7a42                	ld	s4,48(sp)
 326:	7aa2                	ld	s5,40(sp)
 328:	7b02                	ld	s6,32(sp)
 32a:	6be2                	ld	s7,24(sp)
 32c:	6125                	addi	sp,sp,96
 32e:	8082                	ret

0000000000000330 <stat>:

int
stat(const char *n, struct stat *st)
{
 330:	1101                	addi	sp,sp,-32
 332:	ec06                	sd	ra,24(sp)
 334:	e822                	sd	s0,16(sp)
 336:	e426                	sd	s1,8(sp)
 338:	e04a                	sd	s2,0(sp)
 33a:	1000                	addi	s0,sp,32
 33c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 33e:	4581                	li	a1,0
 340:	00000097          	auipc	ra,0x0
 344:	172080e7          	jalr	370(ra) # 4b2 <open>
  if(fd < 0)
 348:	02054563          	bltz	a0,372 <stat+0x42>
 34c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 34e:	85ca                	mv	a1,s2
 350:	00000097          	auipc	ra,0x0
 354:	17a080e7          	jalr	378(ra) # 4ca <fstat>
 358:	892a                	mv	s2,a0
  close(fd);
 35a:	8526                	mv	a0,s1
 35c:	00000097          	auipc	ra,0x0
 360:	13e080e7          	jalr	318(ra) # 49a <close>
  return r;
}
 364:	854a                	mv	a0,s2
 366:	60e2                	ld	ra,24(sp)
 368:	6442                	ld	s0,16(sp)
 36a:	64a2                	ld	s1,8(sp)
 36c:	6902                	ld	s2,0(sp)
 36e:	6105                	addi	sp,sp,32
 370:	8082                	ret
    return -1;
 372:	597d                	li	s2,-1
 374:	bfc5                	j	364 <stat+0x34>

0000000000000376 <atoi>:

int
atoi(const char *s)
{
 376:	1141                	addi	sp,sp,-16
 378:	e422                	sd	s0,8(sp)
 37a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 37c:	00054603          	lbu	a2,0(a0)
 380:	fd06079b          	addiw	a5,a2,-48
 384:	0ff7f793          	andi	a5,a5,255
 388:	4725                	li	a4,9
 38a:	02f76963          	bltu	a4,a5,3bc <atoi+0x46>
 38e:	86aa                	mv	a3,a0
  n = 0;
 390:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 392:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 394:	0685                	addi	a3,a3,1
 396:	0025179b          	slliw	a5,a0,0x2
 39a:	9fa9                	addw	a5,a5,a0
 39c:	0017979b          	slliw	a5,a5,0x1
 3a0:	9fb1                	addw	a5,a5,a2
 3a2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3a6:	0006c603          	lbu	a2,0(a3)
 3aa:	fd06071b          	addiw	a4,a2,-48
 3ae:	0ff77713          	andi	a4,a4,255
 3b2:	fee5f1e3          	bgeu	a1,a4,394 <atoi+0x1e>
  return n;
}
 3b6:	6422                	ld	s0,8(sp)
 3b8:	0141                	addi	sp,sp,16
 3ba:	8082                	ret
  n = 0;
 3bc:	4501                	li	a0,0
 3be:	bfe5                	j	3b6 <atoi+0x40>

00000000000003c0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3c0:	1141                	addi	sp,sp,-16
 3c2:	e422                	sd	s0,8(sp)
 3c4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3c6:	02b57463          	bgeu	a0,a1,3ee <memmove+0x2e>
    while(n-- > 0)
 3ca:	00c05f63          	blez	a2,3e8 <memmove+0x28>
 3ce:	1602                	slli	a2,a2,0x20
 3d0:	9201                	srli	a2,a2,0x20
 3d2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3d6:	872a                	mv	a4,a0
      *dst++ = *src++;
 3d8:	0585                	addi	a1,a1,1
 3da:	0705                	addi	a4,a4,1
 3dc:	fff5c683          	lbu	a3,-1(a1)
 3e0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3e4:	fee79ae3          	bne	a5,a4,3d8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3e8:	6422                	ld	s0,8(sp)
 3ea:	0141                	addi	sp,sp,16
 3ec:	8082                	ret
    dst += n;
 3ee:	00c50733          	add	a4,a0,a2
    src += n;
 3f2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3f4:	fec05ae3          	blez	a2,3e8 <memmove+0x28>
 3f8:	fff6079b          	addiw	a5,a2,-1
 3fc:	1782                	slli	a5,a5,0x20
 3fe:	9381                	srli	a5,a5,0x20
 400:	fff7c793          	not	a5,a5
 404:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 406:	15fd                	addi	a1,a1,-1
 408:	177d                	addi	a4,a4,-1
 40a:	0005c683          	lbu	a3,0(a1)
 40e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 412:	fee79ae3          	bne	a5,a4,406 <memmove+0x46>
 416:	bfc9                	j	3e8 <memmove+0x28>

0000000000000418 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 418:	1141                	addi	sp,sp,-16
 41a:	e422                	sd	s0,8(sp)
 41c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 41e:	ca05                	beqz	a2,44e <memcmp+0x36>
 420:	fff6069b          	addiw	a3,a2,-1
 424:	1682                	slli	a3,a3,0x20
 426:	9281                	srli	a3,a3,0x20
 428:	0685                	addi	a3,a3,1
 42a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 42c:	00054783          	lbu	a5,0(a0)
 430:	0005c703          	lbu	a4,0(a1)
 434:	00e79863          	bne	a5,a4,444 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 438:	0505                	addi	a0,a0,1
    p2++;
 43a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 43c:	fed518e3          	bne	a0,a3,42c <memcmp+0x14>
  }
  return 0;
 440:	4501                	li	a0,0
 442:	a019                	j	448 <memcmp+0x30>
      return *p1 - *p2;
 444:	40e7853b          	subw	a0,a5,a4
}
 448:	6422                	ld	s0,8(sp)
 44a:	0141                	addi	sp,sp,16
 44c:	8082                	ret
  return 0;
 44e:	4501                	li	a0,0
 450:	bfe5                	j	448 <memcmp+0x30>

0000000000000452 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 452:	1141                	addi	sp,sp,-16
 454:	e406                	sd	ra,8(sp)
 456:	e022                	sd	s0,0(sp)
 458:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 45a:	00000097          	auipc	ra,0x0
 45e:	f66080e7          	jalr	-154(ra) # 3c0 <memmove>
}
 462:	60a2                	ld	ra,8(sp)
 464:	6402                	ld	s0,0(sp)
 466:	0141                	addi	sp,sp,16
 468:	8082                	ret

000000000000046a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 46a:	4885                	li	a7,1
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <exit>:
.global exit
exit:
 li a7, SYS_exit
 472:	4889                	li	a7,2
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <wait>:
.global wait
wait:
 li a7, SYS_wait
 47a:	488d                	li	a7,3
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 482:	4891                	li	a7,4
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <read>:
.global read
read:
 li a7, SYS_read
 48a:	4895                	li	a7,5
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <write>:
.global write
write:
 li a7, SYS_write
 492:	48c1                	li	a7,16
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <close>:
.global close
close:
 li a7, SYS_close
 49a:	48d5                	li	a7,21
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4a2:	4899                	li	a7,6
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <exec>:
.global exec
exec:
 li a7, SYS_exec
 4aa:	489d                	li	a7,7
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <open>:
.global open
open:
 li a7, SYS_open
 4b2:	48bd                	li	a7,15
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4ba:	48c5                	li	a7,17
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4c2:	48c9                	li	a7,18
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4ca:	48a1                	li	a7,8
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <link>:
.global link
link:
 li a7, SYS_link
 4d2:	48cd                	li	a7,19
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4da:	48d1                	li	a7,20
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4e2:	48a5                	li	a7,9
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <dup>:
.global dup
dup:
 li a7, SYS_dup
 4ea:	48a9                	li	a7,10
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4f2:	48ad                	li	a7,11
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4fa:	48b1                	li	a7,12
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 502:	48b5                	li	a7,13
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 50a:	48b9                	li	a7,14
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <trace>:
.global trace
trace:
 li a7, SYS_trace
 512:	48d9                	li	a7,22
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <wait_stat>:
.global wait_stat
wait_stat:
 li a7, SYS_wait_stat
 51a:	48dd                	li	a7,23
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 522:	48e1                	li	a7,24
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 52a:	1101                	addi	sp,sp,-32
 52c:	ec06                	sd	ra,24(sp)
 52e:	e822                	sd	s0,16(sp)
 530:	1000                	addi	s0,sp,32
 532:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 536:	4605                	li	a2,1
 538:	fef40593          	addi	a1,s0,-17
 53c:	00000097          	auipc	ra,0x0
 540:	f56080e7          	jalr	-170(ra) # 492 <write>
}
 544:	60e2                	ld	ra,24(sp)
 546:	6442                	ld	s0,16(sp)
 548:	6105                	addi	sp,sp,32
 54a:	8082                	ret

000000000000054c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 54c:	7139                	addi	sp,sp,-64
 54e:	fc06                	sd	ra,56(sp)
 550:	f822                	sd	s0,48(sp)
 552:	f426                	sd	s1,40(sp)
 554:	f04a                	sd	s2,32(sp)
 556:	ec4e                	sd	s3,24(sp)
 558:	0080                	addi	s0,sp,64
 55a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 55c:	c299                	beqz	a3,562 <printint+0x16>
 55e:	0805c863          	bltz	a1,5ee <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 562:	2581                	sext.w	a1,a1
  neg = 0;
 564:	4881                	li	a7,0
 566:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 56a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 56c:	2601                	sext.w	a2,a2
 56e:	00000517          	auipc	a0,0x0
 572:	55a50513          	addi	a0,a0,1370 # ac8 <digits>
 576:	883a                	mv	a6,a4
 578:	2705                	addiw	a4,a4,1
 57a:	02c5f7bb          	remuw	a5,a1,a2
 57e:	1782                	slli	a5,a5,0x20
 580:	9381                	srli	a5,a5,0x20
 582:	97aa                	add	a5,a5,a0
 584:	0007c783          	lbu	a5,0(a5)
 588:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 58c:	0005879b          	sext.w	a5,a1
 590:	02c5d5bb          	divuw	a1,a1,a2
 594:	0685                	addi	a3,a3,1
 596:	fec7f0e3          	bgeu	a5,a2,576 <printint+0x2a>
  if(neg)
 59a:	00088b63          	beqz	a7,5b0 <printint+0x64>
    buf[i++] = '-';
 59e:	fd040793          	addi	a5,s0,-48
 5a2:	973e                	add	a4,a4,a5
 5a4:	02d00793          	li	a5,45
 5a8:	fef70823          	sb	a5,-16(a4)
 5ac:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5b0:	02e05863          	blez	a4,5e0 <printint+0x94>
 5b4:	fc040793          	addi	a5,s0,-64
 5b8:	00e78933          	add	s2,a5,a4
 5bc:	fff78993          	addi	s3,a5,-1
 5c0:	99ba                	add	s3,s3,a4
 5c2:	377d                	addiw	a4,a4,-1
 5c4:	1702                	slli	a4,a4,0x20
 5c6:	9301                	srli	a4,a4,0x20
 5c8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5cc:	fff94583          	lbu	a1,-1(s2)
 5d0:	8526                	mv	a0,s1
 5d2:	00000097          	auipc	ra,0x0
 5d6:	f58080e7          	jalr	-168(ra) # 52a <putc>
  while(--i >= 0)
 5da:	197d                	addi	s2,s2,-1
 5dc:	ff3918e3          	bne	s2,s3,5cc <printint+0x80>
}
 5e0:	70e2                	ld	ra,56(sp)
 5e2:	7442                	ld	s0,48(sp)
 5e4:	74a2                	ld	s1,40(sp)
 5e6:	7902                	ld	s2,32(sp)
 5e8:	69e2                	ld	s3,24(sp)
 5ea:	6121                	addi	sp,sp,64
 5ec:	8082                	ret
    x = -xx;
 5ee:	40b005bb          	negw	a1,a1
    neg = 1;
 5f2:	4885                	li	a7,1
    x = -xx;
 5f4:	bf8d                	j	566 <printint+0x1a>

00000000000005f6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5f6:	7119                	addi	sp,sp,-128
 5f8:	fc86                	sd	ra,120(sp)
 5fa:	f8a2                	sd	s0,112(sp)
 5fc:	f4a6                	sd	s1,104(sp)
 5fe:	f0ca                	sd	s2,96(sp)
 600:	ecce                	sd	s3,88(sp)
 602:	e8d2                	sd	s4,80(sp)
 604:	e4d6                	sd	s5,72(sp)
 606:	e0da                	sd	s6,64(sp)
 608:	fc5e                	sd	s7,56(sp)
 60a:	f862                	sd	s8,48(sp)
 60c:	f466                	sd	s9,40(sp)
 60e:	f06a                	sd	s10,32(sp)
 610:	ec6e                	sd	s11,24(sp)
 612:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 614:	0005c903          	lbu	s2,0(a1)
 618:	18090f63          	beqz	s2,7b6 <vprintf+0x1c0>
 61c:	8aaa                	mv	s5,a0
 61e:	8b32                	mv	s6,a2
 620:	00158493          	addi	s1,a1,1
  state = 0;
 624:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 626:	02500a13          	li	s4,37
      if(c == 'd'){
 62a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 62e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 632:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 636:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 63a:	00000b97          	auipc	s7,0x0
 63e:	48eb8b93          	addi	s7,s7,1166 # ac8 <digits>
 642:	a839                	j	660 <vprintf+0x6a>
        putc(fd, c);
 644:	85ca                	mv	a1,s2
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	ee2080e7          	jalr	-286(ra) # 52a <putc>
 650:	a019                	j	656 <vprintf+0x60>
    } else if(state == '%'){
 652:	01498f63          	beq	s3,s4,670 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 656:	0485                	addi	s1,s1,1
 658:	fff4c903          	lbu	s2,-1(s1)
 65c:	14090d63          	beqz	s2,7b6 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 660:	0009079b          	sext.w	a5,s2
    if(state == 0){
 664:	fe0997e3          	bnez	s3,652 <vprintf+0x5c>
      if(c == '%'){
 668:	fd479ee3          	bne	a5,s4,644 <vprintf+0x4e>
        state = '%';
 66c:	89be                	mv	s3,a5
 66e:	b7e5                	j	656 <vprintf+0x60>
      if(c == 'd'){
 670:	05878063          	beq	a5,s8,6b0 <vprintf+0xba>
      } else if(c == 'l') {
 674:	05978c63          	beq	a5,s9,6cc <vprintf+0xd6>
      } else if(c == 'x') {
 678:	07a78863          	beq	a5,s10,6e8 <vprintf+0xf2>
      } else if(c == 'p') {
 67c:	09b78463          	beq	a5,s11,704 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 680:	07300713          	li	a4,115
 684:	0ce78663          	beq	a5,a4,750 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 688:	06300713          	li	a4,99
 68c:	0ee78e63          	beq	a5,a4,788 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 690:	11478863          	beq	a5,s4,7a0 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 694:	85d2                	mv	a1,s4
 696:	8556                	mv	a0,s5
 698:	00000097          	auipc	ra,0x0
 69c:	e92080e7          	jalr	-366(ra) # 52a <putc>
        putc(fd, c);
 6a0:	85ca                	mv	a1,s2
 6a2:	8556                	mv	a0,s5
 6a4:	00000097          	auipc	ra,0x0
 6a8:	e86080e7          	jalr	-378(ra) # 52a <putc>
      }
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	b765                	j	656 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6b0:	008b0913          	addi	s2,s6,8
 6b4:	4685                	li	a3,1
 6b6:	4629                	li	a2,10
 6b8:	000b2583          	lw	a1,0(s6)
 6bc:	8556                	mv	a0,s5
 6be:	00000097          	auipc	ra,0x0
 6c2:	e8e080e7          	jalr	-370(ra) # 54c <printint>
 6c6:	8b4a                	mv	s6,s2
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	b771                	j	656 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6cc:	008b0913          	addi	s2,s6,8
 6d0:	4681                	li	a3,0
 6d2:	4629                	li	a2,10
 6d4:	000b2583          	lw	a1,0(s6)
 6d8:	8556                	mv	a0,s5
 6da:	00000097          	auipc	ra,0x0
 6de:	e72080e7          	jalr	-398(ra) # 54c <printint>
 6e2:	8b4a                	mv	s6,s2
      state = 0;
 6e4:	4981                	li	s3,0
 6e6:	bf85                	j	656 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6e8:	008b0913          	addi	s2,s6,8
 6ec:	4681                	li	a3,0
 6ee:	4641                	li	a2,16
 6f0:	000b2583          	lw	a1,0(s6)
 6f4:	8556                	mv	a0,s5
 6f6:	00000097          	auipc	ra,0x0
 6fa:	e56080e7          	jalr	-426(ra) # 54c <printint>
 6fe:	8b4a                	mv	s6,s2
      state = 0;
 700:	4981                	li	s3,0
 702:	bf91                	j	656 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 704:	008b0793          	addi	a5,s6,8
 708:	f8f43423          	sd	a5,-120(s0)
 70c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 710:	03000593          	li	a1,48
 714:	8556                	mv	a0,s5
 716:	00000097          	auipc	ra,0x0
 71a:	e14080e7          	jalr	-492(ra) # 52a <putc>
  putc(fd, 'x');
 71e:	85ea                	mv	a1,s10
 720:	8556                	mv	a0,s5
 722:	00000097          	auipc	ra,0x0
 726:	e08080e7          	jalr	-504(ra) # 52a <putc>
 72a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 72c:	03c9d793          	srli	a5,s3,0x3c
 730:	97de                	add	a5,a5,s7
 732:	0007c583          	lbu	a1,0(a5)
 736:	8556                	mv	a0,s5
 738:	00000097          	auipc	ra,0x0
 73c:	df2080e7          	jalr	-526(ra) # 52a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 740:	0992                	slli	s3,s3,0x4
 742:	397d                	addiw	s2,s2,-1
 744:	fe0914e3          	bnez	s2,72c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 748:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 74c:	4981                	li	s3,0
 74e:	b721                	j	656 <vprintf+0x60>
        s = va_arg(ap, char*);
 750:	008b0993          	addi	s3,s6,8
 754:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 758:	02090163          	beqz	s2,77a <vprintf+0x184>
        while(*s != 0){
 75c:	00094583          	lbu	a1,0(s2)
 760:	c9a1                	beqz	a1,7b0 <vprintf+0x1ba>
          putc(fd, *s);
 762:	8556                	mv	a0,s5
 764:	00000097          	auipc	ra,0x0
 768:	dc6080e7          	jalr	-570(ra) # 52a <putc>
          s++;
 76c:	0905                	addi	s2,s2,1
        while(*s != 0){
 76e:	00094583          	lbu	a1,0(s2)
 772:	f9e5                	bnez	a1,762 <vprintf+0x16c>
        s = va_arg(ap, char*);
 774:	8b4e                	mv	s6,s3
      state = 0;
 776:	4981                	li	s3,0
 778:	bdf9                	j	656 <vprintf+0x60>
          s = "(null)";
 77a:	00000917          	auipc	s2,0x0
 77e:	34690913          	addi	s2,s2,838 # ac0 <malloc+0x200>
        while(*s != 0){
 782:	02800593          	li	a1,40
 786:	bff1                	j	762 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 788:	008b0913          	addi	s2,s6,8
 78c:	000b4583          	lbu	a1,0(s6)
 790:	8556                	mv	a0,s5
 792:	00000097          	auipc	ra,0x0
 796:	d98080e7          	jalr	-616(ra) # 52a <putc>
 79a:	8b4a                	mv	s6,s2
      state = 0;
 79c:	4981                	li	s3,0
 79e:	bd65                	j	656 <vprintf+0x60>
        putc(fd, c);
 7a0:	85d2                	mv	a1,s4
 7a2:	8556                	mv	a0,s5
 7a4:	00000097          	auipc	ra,0x0
 7a8:	d86080e7          	jalr	-634(ra) # 52a <putc>
      state = 0;
 7ac:	4981                	li	s3,0
 7ae:	b565                	j	656 <vprintf+0x60>
        s = va_arg(ap, char*);
 7b0:	8b4e                	mv	s6,s3
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	b54d                	j	656 <vprintf+0x60>
    }
  }
}
 7b6:	70e6                	ld	ra,120(sp)
 7b8:	7446                	ld	s0,112(sp)
 7ba:	74a6                	ld	s1,104(sp)
 7bc:	7906                	ld	s2,96(sp)
 7be:	69e6                	ld	s3,88(sp)
 7c0:	6a46                	ld	s4,80(sp)
 7c2:	6aa6                	ld	s5,72(sp)
 7c4:	6b06                	ld	s6,64(sp)
 7c6:	7be2                	ld	s7,56(sp)
 7c8:	7c42                	ld	s8,48(sp)
 7ca:	7ca2                	ld	s9,40(sp)
 7cc:	7d02                	ld	s10,32(sp)
 7ce:	6de2                	ld	s11,24(sp)
 7d0:	6109                	addi	sp,sp,128
 7d2:	8082                	ret

00000000000007d4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7d4:	715d                	addi	sp,sp,-80
 7d6:	ec06                	sd	ra,24(sp)
 7d8:	e822                	sd	s0,16(sp)
 7da:	1000                	addi	s0,sp,32
 7dc:	e010                	sd	a2,0(s0)
 7de:	e414                	sd	a3,8(s0)
 7e0:	e818                	sd	a4,16(s0)
 7e2:	ec1c                	sd	a5,24(s0)
 7e4:	03043023          	sd	a6,32(s0)
 7e8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ec:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7f0:	8622                	mv	a2,s0
 7f2:	00000097          	auipc	ra,0x0
 7f6:	e04080e7          	jalr	-508(ra) # 5f6 <vprintf>
}
 7fa:	60e2                	ld	ra,24(sp)
 7fc:	6442                	ld	s0,16(sp)
 7fe:	6161                	addi	sp,sp,80
 800:	8082                	ret

0000000000000802 <printf>:

void
printf(const char *fmt, ...)
{
 802:	711d                	addi	sp,sp,-96
 804:	ec06                	sd	ra,24(sp)
 806:	e822                	sd	s0,16(sp)
 808:	1000                	addi	s0,sp,32
 80a:	e40c                	sd	a1,8(s0)
 80c:	e810                	sd	a2,16(s0)
 80e:	ec14                	sd	a3,24(s0)
 810:	f018                	sd	a4,32(s0)
 812:	f41c                	sd	a5,40(s0)
 814:	03043823          	sd	a6,48(s0)
 818:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 81c:	00840613          	addi	a2,s0,8
 820:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 824:	85aa                	mv	a1,a0
 826:	4505                	li	a0,1
 828:	00000097          	auipc	ra,0x0
 82c:	dce080e7          	jalr	-562(ra) # 5f6 <vprintf>
}
 830:	60e2                	ld	ra,24(sp)
 832:	6442                	ld	s0,16(sp)
 834:	6125                	addi	sp,sp,96
 836:	8082                	ret

0000000000000838 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 838:	1141                	addi	sp,sp,-16
 83a:	e422                	sd	s0,8(sp)
 83c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 83e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 842:	00000797          	auipc	a5,0x0
 846:	29e7b783          	ld	a5,670(a5) # ae0 <freep>
 84a:	a805                	j	87a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 84c:	4618                	lw	a4,8(a2)
 84e:	9db9                	addw	a1,a1,a4
 850:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 854:	6398                	ld	a4,0(a5)
 856:	6318                	ld	a4,0(a4)
 858:	fee53823          	sd	a4,-16(a0)
 85c:	a091                	j	8a0 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 85e:	ff852703          	lw	a4,-8(a0)
 862:	9e39                	addw	a2,a2,a4
 864:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 866:	ff053703          	ld	a4,-16(a0)
 86a:	e398                	sd	a4,0(a5)
 86c:	a099                	j	8b2 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86e:	6398                	ld	a4,0(a5)
 870:	00e7e463          	bltu	a5,a4,878 <free+0x40>
 874:	00e6ea63          	bltu	a3,a4,888 <free+0x50>
{
 878:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87a:	fed7fae3          	bgeu	a5,a3,86e <free+0x36>
 87e:	6398                	ld	a4,0(a5)
 880:	00e6e463          	bltu	a3,a4,888 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 884:	fee7eae3          	bltu	a5,a4,878 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 888:	ff852583          	lw	a1,-8(a0)
 88c:	6390                	ld	a2,0(a5)
 88e:	02059813          	slli	a6,a1,0x20
 892:	01c85713          	srli	a4,a6,0x1c
 896:	9736                	add	a4,a4,a3
 898:	fae60ae3          	beq	a2,a4,84c <free+0x14>
    bp->s.ptr = p->s.ptr;
 89c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8a0:	4790                	lw	a2,8(a5)
 8a2:	02061593          	slli	a1,a2,0x20
 8a6:	01c5d713          	srli	a4,a1,0x1c
 8aa:	973e                	add	a4,a4,a5
 8ac:	fae689e3          	beq	a3,a4,85e <free+0x26>
  } else
    p->s.ptr = bp;
 8b0:	e394                	sd	a3,0(a5)
  freep = p;
 8b2:	00000717          	auipc	a4,0x0
 8b6:	22f73723          	sd	a5,558(a4) # ae0 <freep>
}
 8ba:	6422                	ld	s0,8(sp)
 8bc:	0141                	addi	sp,sp,16
 8be:	8082                	ret

00000000000008c0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8c0:	7139                	addi	sp,sp,-64
 8c2:	fc06                	sd	ra,56(sp)
 8c4:	f822                	sd	s0,48(sp)
 8c6:	f426                	sd	s1,40(sp)
 8c8:	f04a                	sd	s2,32(sp)
 8ca:	ec4e                	sd	s3,24(sp)
 8cc:	e852                	sd	s4,16(sp)
 8ce:	e456                	sd	s5,8(sp)
 8d0:	e05a                	sd	s6,0(sp)
 8d2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d4:	02051493          	slli	s1,a0,0x20
 8d8:	9081                	srli	s1,s1,0x20
 8da:	04bd                	addi	s1,s1,15
 8dc:	8091                	srli	s1,s1,0x4
 8de:	0014899b          	addiw	s3,s1,1
 8e2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8e4:	00000517          	auipc	a0,0x0
 8e8:	1fc53503          	ld	a0,508(a0) # ae0 <freep>
 8ec:	c515                	beqz	a0,918 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f0:	4798                	lw	a4,8(a5)
 8f2:	02977f63          	bgeu	a4,s1,930 <malloc+0x70>
 8f6:	8a4e                	mv	s4,s3
 8f8:	0009871b          	sext.w	a4,s3
 8fc:	6685                	lui	a3,0x1
 8fe:	00d77363          	bgeu	a4,a3,904 <malloc+0x44>
 902:	6a05                	lui	s4,0x1
 904:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 908:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 90c:	00000917          	auipc	s2,0x0
 910:	1d490913          	addi	s2,s2,468 # ae0 <freep>
  if(p == (char*)-1)
 914:	5afd                	li	s5,-1
 916:	a895                	j	98a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 918:	00000797          	auipc	a5,0x0
 91c:	1d078793          	addi	a5,a5,464 # ae8 <base>
 920:	00000717          	auipc	a4,0x0
 924:	1cf73023          	sd	a5,448(a4) # ae0 <freep>
 928:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 92a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 92e:	b7e1                	j	8f6 <malloc+0x36>
      if(p->s.size == nunits)
 930:	02e48c63          	beq	s1,a4,968 <malloc+0xa8>
        p->s.size -= nunits;
 934:	4137073b          	subw	a4,a4,s3
 938:	c798                	sw	a4,8(a5)
        p += p->s.size;
 93a:	02071693          	slli	a3,a4,0x20
 93e:	01c6d713          	srli	a4,a3,0x1c
 942:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 944:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 948:	00000717          	auipc	a4,0x0
 94c:	18a73c23          	sd	a0,408(a4) # ae0 <freep>
      return (void*)(p + 1);
 950:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 954:	70e2                	ld	ra,56(sp)
 956:	7442                	ld	s0,48(sp)
 958:	74a2                	ld	s1,40(sp)
 95a:	7902                	ld	s2,32(sp)
 95c:	69e2                	ld	s3,24(sp)
 95e:	6a42                	ld	s4,16(sp)
 960:	6aa2                	ld	s5,8(sp)
 962:	6b02                	ld	s6,0(sp)
 964:	6121                	addi	sp,sp,64
 966:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 968:	6398                	ld	a4,0(a5)
 96a:	e118                	sd	a4,0(a0)
 96c:	bff1                	j	948 <malloc+0x88>
  hp->s.size = nu;
 96e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 972:	0541                	addi	a0,a0,16
 974:	00000097          	auipc	ra,0x0
 978:	ec4080e7          	jalr	-316(ra) # 838 <free>
  return freep;
 97c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 980:	d971                	beqz	a0,954 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 982:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 984:	4798                	lw	a4,8(a5)
 986:	fa9775e3          	bgeu	a4,s1,930 <malloc+0x70>
    if(p == freep)
 98a:	00093703          	ld	a4,0(s2)
 98e:	853e                	mv	a0,a5
 990:	fef719e3          	bne	a4,a5,982 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 994:	8552                	mv	a0,s4
 996:	00000097          	auipc	ra,0x0
 99a:	b64080e7          	jalr	-1180(ra) # 4fa <sbrk>
  if(p == (char*)-1)
 99e:	fd5518e3          	bne	a0,s5,96e <malloc+0xae>
        return 0;
 9a2:	4501                	li	a0,0
 9a4:	bf45                	j	954 <malloc+0x94>
