
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
  10:	9ac58593          	addi	a1,a1,-1620 # 9b8 <malloc+0xe6>
  14:	4505                	li	a0,1
  16:	00000097          	auipc	ra,0x0
  1a:	7d0080e7          	jalr	2000(ra) # 7e6 <fprintf>
    fprintf(1, "\tctime: %d\n", performance->ctime);
  1e:	4090                	lw	a2,0(s1)
  20:	00001597          	auipc	a1,0x1
  24:	9a058593          	addi	a1,a1,-1632 # 9c0 <malloc+0xee>
  28:	4505                	li	a0,1
  2a:	00000097          	auipc	ra,0x0
  2e:	7bc080e7          	jalr	1980(ra) # 7e6 <fprintf>
    fprintf(1, "\tttime: %d\n", performance->ttime);
  32:	40d0                	lw	a2,4(s1)
  34:	00001597          	auipc	a1,0x1
  38:	99c58593          	addi	a1,a1,-1636 # 9d0 <malloc+0xfe>
  3c:	4505                	li	a0,1
  3e:	00000097          	auipc	ra,0x0
  42:	7a8080e7          	jalr	1960(ra) # 7e6 <fprintf>
    fprintf(1, "\tstime: %d\n", performance->stime);
  46:	4490                	lw	a2,8(s1)
  48:	00001597          	auipc	a1,0x1
  4c:	99858593          	addi	a1,a1,-1640 # 9e0 <malloc+0x10e>
  50:	4505                	li	a0,1
  52:	00000097          	auipc	ra,0x0
  56:	794080e7          	jalr	1940(ra) # 7e6 <fprintf>
    fprintf(1, "\tretime: %d\n", performance->retime);
  5a:	44d0                	lw	a2,12(s1)
  5c:	00001597          	auipc	a1,0x1
  60:	99458593          	addi	a1,a1,-1644 # 9f0 <malloc+0x11e>
  64:	4505                	li	a0,1
  66:	00000097          	auipc	ra,0x0
  6a:	780080e7          	jalr	1920(ra) # 7e6 <fprintf>
    fprintf(1, "\trutime: %d\n", performance->rutime);
  6e:	4890                	lw	a2,16(s1)
  70:	00001597          	auipc	a1,0x1
  74:	99058593          	addi	a1,a1,-1648 # a00 <malloc+0x12e>
  78:	4505                	li	a0,1
  7a:	00000097          	auipc	ra,0x0
  7e:	76c080e7          	jalr	1900(ra) # 7e6 <fprintf>
    fprintf(1, "\tavarage_btime: %d\n", performance->bursttime);
  82:	48d0                	lw	a2,20(s1)
  84:	00001597          	auipc	a1,0x1
  88:	98c58593          	addi	a1,a1,-1652 # a10 <malloc+0x13e>
  8c:	4505                	li	a0,1
  8e:	00000097          	auipc	ra,0x0
  92:	758080e7          	jalr	1880(ra) # 7e6 <fprintf>
    fprintf(1, "\n\tTurnaround time: %d\n", (performance->ttime - performance->ctime));
  96:	40d0                	lw	a2,4(s1)
  98:	409c                	lw	a5,0(s1)
  9a:	9e1d                	subw	a2,a2,a5
  9c:	00001597          	auipc	a1,0x1
  a0:	98c58593          	addi	a1,a1,-1652 # a28 <malloc+0x156>
  a4:	4505                	li	a0,1
  a6:	00000097          	auipc	ra,0x0
  aa:	740080e7          	jalr	1856(ra) # 7e6 <fprintf>
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
  c8:	3b8080e7          	jalr	952(ra) # 47c <fork>
	
	if (pid1 > 0) { //parent
  cc:	02a05e63          	blez	a0,108 <test3+0x50>
	
		int s = wait_stat(&status1, &perf2);
  d0:	fc040593          	addi	a1,s0,-64
  d4:	fdc40513          	addi	a0,s0,-36
  d8:	00000097          	auipc	ra,0x0
  dc:	454080e7          	jalr	1108(ra) # 52c <wait_stat>
  e0:	85aa                	mv	a1,a0
		printf("pid is: %d\n", s);
  e2:	00001517          	auipc	a0,0x1
  e6:	95e50513          	addi	a0,a0,-1698 # a40 <malloc+0x16e>
  ea:	00000097          	auipc	ra,0x0
  ee:	72a080e7          	jalr	1834(ra) # 814 <printf>
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
 104:	384080e7          	jalr	900(ra) # 484 <exit>
	 	sleep(10);
 108:	4529                	li	a0,10
 10a:	00000097          	auipc	ra,0x0
 10e:	40a080e7          	jalr	1034(ra) # 514 <sleep>
 112:	0c800493          	li	s1,200
			write(1, "hello i'm a child\n", 18);
 116:	00001917          	auipc	s2,0x1
 11a:	93a90913          	addi	s2,s2,-1734 # a50 <malloc+0x17e>
 11e:	4649                	li	a2,18
 120:	85ca                	mv	a1,s2
 122:	4505                	li	a0,1
 124:	00000097          	auipc	ra,0x0
 128:	380080e7          	jalr	896(ra) # 4a4 <write>
		for (int i = 0; i < 200; i++){
 12c:	34fd                	addiw	s1,s1,-1
 12e:	f8e5                	bnez	s1,11e <test3+0x66>
		sleep(10);
 130:	4529                	li	a0,10
 132:	00000097          	auipc	ra,0x0
 136:	3e2080e7          	jalr	994(ra) # 514 <sleep>
		pid2=fork();
 13a:	00000097          	auipc	ra,0x0
 13e:	342080e7          	jalr	834(ra) # 47c <fork>
	 	if(pid2==0){//second child
 142:	e90d                	bnez	a0,174 <test3+0xbc>
		sleep(10);
 144:	4529                	li	a0,10
 146:	00000097          	auipc	ra,0x0
 14a:	3ce080e7          	jalr	974(ra) # 514 <sleep>
 14e:	44d1                	li	s1,20
			write(1, "hello i'm the second child\n", 28);
 150:	00001917          	auipc	s2,0x1
 154:	91890913          	addi	s2,s2,-1768 # a68 <malloc+0x196>
 158:	4671                	li	a2,28
 15a:	85ca                	mv	a1,s2
 15c:	4505                	li	a0,1
 15e:	00000097          	auipc	ra,0x0
 162:	346080e7          	jalr	838(ra) # 4a4 <write>
		for (int i = 0; i < 20; i++){
 166:	34fd                	addiw	s1,s1,-1
 168:	f8e5                	bnez	s1,158 <test3+0xa0>
		exit(1);
 16a:	4505                	li	a0,1
 16c:	00000097          	auipc	ra,0x0
 170:	318080e7          	jalr	792(ra) # 484 <exit>
			int s = wait_stat(&status2, &perf3);
 174:	fa840593          	addi	a1,s0,-88
 178:	fd840513          	addi	a0,s0,-40
 17c:	00000097          	auipc	ra,0x0
 180:	3b0080e7          	jalr	944(ra) # 52c <wait_stat>
 184:	85aa                	mv	a1,a0
			printf("secund child pid is: %d\n", s);
 186:	00001517          	auipc	a0,0x1
 18a:	90250513          	addi	a0,a0,-1790 # a88 <malloc+0x1b6>
 18e:	00000097          	auipc	ra,0x0
 192:	686080e7          	jalr	1670(ra) # 814 <printf>
			print_perf(&perf3);
 196:	fa840513          	addi	a0,s0,-88
 19a:	00000097          	auipc	ra,0x0
 19e:	e66080e7          	jalr	-410(ra) # 0 <print_perf>
 1a2:	bfb1                	j	fe <test3+0x46>

00000000000001a4 <testFCFS>:
}
void testFCFS(){
 1a4:	7179                	addi	sp,sp,-48
 1a6:	f406                	sd	ra,40(sp)
 1a8:	f022                	sd	s0,32(sp)
 1aa:	ec26                	sd	s1,24(sp)
 1ac:	e84a                	sd	s2,16(sp)
 1ae:	e44e                	sd	s3,8(sp)
 1b0:	1800                	addi	s0,sp,48
	fork();
 1b2:	00000097          	auipc	ra,0x0
 1b6:	2ca080e7          	jalr	714(ra) # 47c <fork>
	fork();
 1ba:	00000097          	auipc	ra,0x0
 1be:	2c2080e7          	jalr	706(ra) # 47c <fork>
	fork();
 1c2:	00000097          	auipc	ra,0x0
 1c6:	2ba080e7          	jalr	698(ra) # 47c <fork>

	int my_pid=getpid();
 1ca:	00000097          	auipc	ra,0x0
 1ce:	33a080e7          	jalr	826(ra) # 504 <getpid>
 1d2:	892a                	mv	s2,a0
 1d4:	44d1                	li	s1,20
	for(int i=0;i<20;i++){
		printf("current child is: %d ",my_pid);
 1d6:	00001997          	auipc	s3,0x1
 1da:	8d298993          	addi	s3,s3,-1838 # aa8 <malloc+0x1d6>
 1de:	85ca                	mv	a1,s2
 1e0:	854e                	mv	a0,s3
 1e2:	00000097          	auipc	ra,0x0
 1e6:	632080e7          	jalr	1586(ra) # 814 <printf>
	for(int i=0;i<20;i++){
 1ea:	34fd                	addiw	s1,s1,-1
 1ec:	f8ed                	bnez	s1,1de <testFCFS+0x3a>
	}
}
 1ee:	70a2                	ld	ra,40(sp)
 1f0:	7402                	ld	s0,32(sp)
 1f2:	64e2                	ld	s1,24(sp)
 1f4:	6942                	ld	s2,16(sp)
 1f6:	69a2                	ld	s3,8(sp)
 1f8:	6145                	addi	sp,sp,48
 1fa:	8082                	ret

00000000000001fc <main>:

int main(int argc, char** argv){
 1fc:	1141                	addi	sp,sp,-16
 1fe:	e406                	sd	ra,8(sp)
 200:	e022                	sd	s0,0(sp)
 202:	0800                	addi	s0,sp,16
	//   test3();
	testFCFS();
 204:	00000097          	auipc	ra,0x0
 208:	fa0080e7          	jalr	-96(ra) # 1a4 <testFCFS>
	exit(0);
 20c:	4501                	li	a0,0
 20e:	00000097          	auipc	ra,0x0
 212:	276080e7          	jalr	630(ra) # 484 <exit>

0000000000000216 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 21c:	87aa                	mv	a5,a0
 21e:	0585                	addi	a1,a1,1
 220:	0785                	addi	a5,a5,1
 222:	fff5c703          	lbu	a4,-1(a1)
 226:	fee78fa3          	sb	a4,-1(a5)
 22a:	fb75                	bnez	a4,21e <strcpy+0x8>
    ;
  return os;
}
 22c:	6422                	ld	s0,8(sp)
 22e:	0141                	addi	sp,sp,16
 230:	8082                	ret

0000000000000232 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 238:	00054783          	lbu	a5,0(a0)
 23c:	cb91                	beqz	a5,250 <strcmp+0x1e>
 23e:	0005c703          	lbu	a4,0(a1)
 242:	00f71763          	bne	a4,a5,250 <strcmp+0x1e>
    p++, q++;
 246:	0505                	addi	a0,a0,1
 248:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 24a:	00054783          	lbu	a5,0(a0)
 24e:	fbe5                	bnez	a5,23e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 250:	0005c503          	lbu	a0,0(a1)
}
 254:	40a7853b          	subw	a0,a5,a0
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret

000000000000025e <strlen>:

uint
strlen(const char *s)
{
 25e:	1141                	addi	sp,sp,-16
 260:	e422                	sd	s0,8(sp)
 262:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 264:	00054783          	lbu	a5,0(a0)
 268:	cf91                	beqz	a5,284 <strlen+0x26>
 26a:	0505                	addi	a0,a0,1
 26c:	87aa                	mv	a5,a0
 26e:	4685                	li	a3,1
 270:	9e89                	subw	a3,a3,a0
 272:	00f6853b          	addw	a0,a3,a5
 276:	0785                	addi	a5,a5,1
 278:	fff7c703          	lbu	a4,-1(a5)
 27c:	fb7d                	bnez	a4,272 <strlen+0x14>
    ;
  return n;
}
 27e:	6422                	ld	s0,8(sp)
 280:	0141                	addi	sp,sp,16
 282:	8082                	ret
  for(n = 0; s[n]; n++)
 284:	4501                	li	a0,0
 286:	bfe5                	j	27e <strlen+0x20>

0000000000000288 <memset>:

void*
memset(void *dst, int c, uint n)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e422                	sd	s0,8(sp)
 28c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 28e:	ca19                	beqz	a2,2a4 <memset+0x1c>
 290:	87aa                	mv	a5,a0
 292:	1602                	slli	a2,a2,0x20
 294:	9201                	srli	a2,a2,0x20
 296:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 29a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 29e:	0785                	addi	a5,a5,1
 2a0:	fee79de3          	bne	a5,a4,29a <memset+0x12>
  }
  return dst;
}
 2a4:	6422                	ld	s0,8(sp)
 2a6:	0141                	addi	sp,sp,16
 2a8:	8082                	ret

00000000000002aa <strchr>:

char*
strchr(const char *s, char c)
{
 2aa:	1141                	addi	sp,sp,-16
 2ac:	e422                	sd	s0,8(sp)
 2ae:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2b0:	00054783          	lbu	a5,0(a0)
 2b4:	cb99                	beqz	a5,2ca <strchr+0x20>
    if(*s == c)
 2b6:	00f58763          	beq	a1,a5,2c4 <strchr+0x1a>
  for(; *s; s++)
 2ba:	0505                	addi	a0,a0,1
 2bc:	00054783          	lbu	a5,0(a0)
 2c0:	fbfd                	bnez	a5,2b6 <strchr+0xc>
      return (char*)s;
  return 0;
 2c2:	4501                	li	a0,0
}
 2c4:	6422                	ld	s0,8(sp)
 2c6:	0141                	addi	sp,sp,16
 2c8:	8082                	ret
  return 0;
 2ca:	4501                	li	a0,0
 2cc:	bfe5                	j	2c4 <strchr+0x1a>

00000000000002ce <gets>:

char*
gets(char *buf, int max)
{
 2ce:	711d                	addi	sp,sp,-96
 2d0:	ec86                	sd	ra,88(sp)
 2d2:	e8a2                	sd	s0,80(sp)
 2d4:	e4a6                	sd	s1,72(sp)
 2d6:	e0ca                	sd	s2,64(sp)
 2d8:	fc4e                	sd	s3,56(sp)
 2da:	f852                	sd	s4,48(sp)
 2dc:	f456                	sd	s5,40(sp)
 2de:	f05a                	sd	s6,32(sp)
 2e0:	ec5e                	sd	s7,24(sp)
 2e2:	1080                	addi	s0,sp,96
 2e4:	8baa                	mv	s7,a0
 2e6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e8:	892a                	mv	s2,a0
 2ea:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2ec:	4aa9                	li	s5,10
 2ee:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2f0:	89a6                	mv	s3,s1
 2f2:	2485                	addiw	s1,s1,1
 2f4:	0344d863          	bge	s1,s4,324 <gets+0x56>
    cc = read(0, &c, 1);
 2f8:	4605                	li	a2,1
 2fa:	faf40593          	addi	a1,s0,-81
 2fe:	4501                	li	a0,0
 300:	00000097          	auipc	ra,0x0
 304:	19c080e7          	jalr	412(ra) # 49c <read>
    if(cc < 1)
 308:	00a05e63          	blez	a0,324 <gets+0x56>
    buf[i++] = c;
 30c:	faf44783          	lbu	a5,-81(s0)
 310:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 314:	01578763          	beq	a5,s5,322 <gets+0x54>
 318:	0905                	addi	s2,s2,1
 31a:	fd679be3          	bne	a5,s6,2f0 <gets+0x22>
  for(i=0; i+1 < max; ){
 31e:	89a6                	mv	s3,s1
 320:	a011                	j	324 <gets+0x56>
 322:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 324:	99de                	add	s3,s3,s7
 326:	00098023          	sb	zero,0(s3)
  return buf;
}
 32a:	855e                	mv	a0,s7
 32c:	60e6                	ld	ra,88(sp)
 32e:	6446                	ld	s0,80(sp)
 330:	64a6                	ld	s1,72(sp)
 332:	6906                	ld	s2,64(sp)
 334:	79e2                	ld	s3,56(sp)
 336:	7a42                	ld	s4,48(sp)
 338:	7aa2                	ld	s5,40(sp)
 33a:	7b02                	ld	s6,32(sp)
 33c:	6be2                	ld	s7,24(sp)
 33e:	6125                	addi	sp,sp,96
 340:	8082                	ret

0000000000000342 <stat>:

int
stat(const char *n, struct stat *st)
{
 342:	1101                	addi	sp,sp,-32
 344:	ec06                	sd	ra,24(sp)
 346:	e822                	sd	s0,16(sp)
 348:	e426                	sd	s1,8(sp)
 34a:	e04a                	sd	s2,0(sp)
 34c:	1000                	addi	s0,sp,32
 34e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 350:	4581                	li	a1,0
 352:	00000097          	auipc	ra,0x0
 356:	172080e7          	jalr	370(ra) # 4c4 <open>
  if(fd < 0)
 35a:	02054563          	bltz	a0,384 <stat+0x42>
 35e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 360:	85ca                	mv	a1,s2
 362:	00000097          	auipc	ra,0x0
 366:	17a080e7          	jalr	378(ra) # 4dc <fstat>
 36a:	892a                	mv	s2,a0
  close(fd);
 36c:	8526                	mv	a0,s1
 36e:	00000097          	auipc	ra,0x0
 372:	13e080e7          	jalr	318(ra) # 4ac <close>
  return r;
}
 376:	854a                	mv	a0,s2
 378:	60e2                	ld	ra,24(sp)
 37a:	6442                	ld	s0,16(sp)
 37c:	64a2                	ld	s1,8(sp)
 37e:	6902                	ld	s2,0(sp)
 380:	6105                	addi	sp,sp,32
 382:	8082                	ret
    return -1;
 384:	597d                	li	s2,-1
 386:	bfc5                	j	376 <stat+0x34>

0000000000000388 <atoi>:

int
atoi(const char *s)
{
 388:	1141                	addi	sp,sp,-16
 38a:	e422                	sd	s0,8(sp)
 38c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 38e:	00054603          	lbu	a2,0(a0)
 392:	fd06079b          	addiw	a5,a2,-48
 396:	0ff7f793          	andi	a5,a5,255
 39a:	4725                	li	a4,9
 39c:	02f76963          	bltu	a4,a5,3ce <atoi+0x46>
 3a0:	86aa                	mv	a3,a0
  n = 0;
 3a2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3a4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3a6:	0685                	addi	a3,a3,1
 3a8:	0025179b          	slliw	a5,a0,0x2
 3ac:	9fa9                	addw	a5,a5,a0
 3ae:	0017979b          	slliw	a5,a5,0x1
 3b2:	9fb1                	addw	a5,a5,a2
 3b4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3b8:	0006c603          	lbu	a2,0(a3)
 3bc:	fd06071b          	addiw	a4,a2,-48
 3c0:	0ff77713          	andi	a4,a4,255
 3c4:	fee5f1e3          	bgeu	a1,a4,3a6 <atoi+0x1e>
  return n;
}
 3c8:	6422                	ld	s0,8(sp)
 3ca:	0141                	addi	sp,sp,16
 3cc:	8082                	ret
  n = 0;
 3ce:	4501                	li	a0,0
 3d0:	bfe5                	j	3c8 <atoi+0x40>

00000000000003d2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3d2:	1141                	addi	sp,sp,-16
 3d4:	e422                	sd	s0,8(sp)
 3d6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3d8:	02b57463          	bgeu	a0,a1,400 <memmove+0x2e>
    while(n-- > 0)
 3dc:	00c05f63          	blez	a2,3fa <memmove+0x28>
 3e0:	1602                	slli	a2,a2,0x20
 3e2:	9201                	srli	a2,a2,0x20
 3e4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3e8:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ea:	0585                	addi	a1,a1,1
 3ec:	0705                	addi	a4,a4,1
 3ee:	fff5c683          	lbu	a3,-1(a1)
 3f2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3f6:	fee79ae3          	bne	a5,a4,3ea <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3fa:	6422                	ld	s0,8(sp)
 3fc:	0141                	addi	sp,sp,16
 3fe:	8082                	ret
    dst += n;
 400:	00c50733          	add	a4,a0,a2
    src += n;
 404:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 406:	fec05ae3          	blez	a2,3fa <memmove+0x28>
 40a:	fff6079b          	addiw	a5,a2,-1
 40e:	1782                	slli	a5,a5,0x20
 410:	9381                	srli	a5,a5,0x20
 412:	fff7c793          	not	a5,a5
 416:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 418:	15fd                	addi	a1,a1,-1
 41a:	177d                	addi	a4,a4,-1
 41c:	0005c683          	lbu	a3,0(a1)
 420:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 424:	fee79ae3          	bne	a5,a4,418 <memmove+0x46>
 428:	bfc9                	j	3fa <memmove+0x28>

000000000000042a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 42a:	1141                	addi	sp,sp,-16
 42c:	e422                	sd	s0,8(sp)
 42e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 430:	ca05                	beqz	a2,460 <memcmp+0x36>
 432:	fff6069b          	addiw	a3,a2,-1
 436:	1682                	slli	a3,a3,0x20
 438:	9281                	srli	a3,a3,0x20
 43a:	0685                	addi	a3,a3,1
 43c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 43e:	00054783          	lbu	a5,0(a0)
 442:	0005c703          	lbu	a4,0(a1)
 446:	00e79863          	bne	a5,a4,456 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 44a:	0505                	addi	a0,a0,1
    p2++;
 44c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 44e:	fed518e3          	bne	a0,a3,43e <memcmp+0x14>
  }
  return 0;
 452:	4501                	li	a0,0
 454:	a019                	j	45a <memcmp+0x30>
      return *p1 - *p2;
 456:	40e7853b          	subw	a0,a5,a4
}
 45a:	6422                	ld	s0,8(sp)
 45c:	0141                	addi	sp,sp,16
 45e:	8082                	ret
  return 0;
 460:	4501                	li	a0,0
 462:	bfe5                	j	45a <memcmp+0x30>

0000000000000464 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 464:	1141                	addi	sp,sp,-16
 466:	e406                	sd	ra,8(sp)
 468:	e022                	sd	s0,0(sp)
 46a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 46c:	00000097          	auipc	ra,0x0
 470:	f66080e7          	jalr	-154(ra) # 3d2 <memmove>
}
 474:	60a2                	ld	ra,8(sp)
 476:	6402                	ld	s0,0(sp)
 478:	0141                	addi	sp,sp,16
 47a:	8082                	ret

000000000000047c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 47c:	4885                	li	a7,1
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <exit>:
.global exit
exit:
 li a7, SYS_exit
 484:	4889                	li	a7,2
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <wait>:
.global wait
wait:
 li a7, SYS_wait
 48c:	488d                	li	a7,3
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 494:	4891                	li	a7,4
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <read>:
.global read
read:
 li a7, SYS_read
 49c:	4895                	li	a7,5
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <write>:
.global write
write:
 li a7, SYS_write
 4a4:	48c1                	li	a7,16
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <close>:
.global close
close:
 li a7, SYS_close
 4ac:	48d5                	li	a7,21
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4b4:	4899                	li	a7,6
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <exec>:
.global exec
exec:
 li a7, SYS_exec
 4bc:	489d                	li	a7,7
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <open>:
.global open
open:
 li a7, SYS_open
 4c4:	48bd                	li	a7,15
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4cc:	48c5                	li	a7,17
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4d4:	48c9                	li	a7,18
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4dc:	48a1                	li	a7,8
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <link>:
.global link
link:
 li a7, SYS_link
 4e4:	48cd                	li	a7,19
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4ec:	48d1                	li	a7,20
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4f4:	48a5                	li	a7,9
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <dup>:
.global dup
dup:
 li a7, SYS_dup
 4fc:	48a9                	li	a7,10
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 504:	48ad                	li	a7,11
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 50c:	48b1                	li	a7,12
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 514:	48b5                	li	a7,13
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 51c:	48b9                	li	a7,14
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <trace>:
.global trace
trace:
 li a7, SYS_trace
 524:	48d9                	li	a7,22
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <wait_stat>:
.global wait_stat
wait_stat:
 li a7, SYS_wait_stat
 52c:	48dd                	li	a7,23
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 534:	48e1                	li	a7,24
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 53c:	1101                	addi	sp,sp,-32
 53e:	ec06                	sd	ra,24(sp)
 540:	e822                	sd	s0,16(sp)
 542:	1000                	addi	s0,sp,32
 544:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 548:	4605                	li	a2,1
 54a:	fef40593          	addi	a1,s0,-17
 54e:	00000097          	auipc	ra,0x0
 552:	f56080e7          	jalr	-170(ra) # 4a4 <write>
}
 556:	60e2                	ld	ra,24(sp)
 558:	6442                	ld	s0,16(sp)
 55a:	6105                	addi	sp,sp,32
 55c:	8082                	ret

000000000000055e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 55e:	7139                	addi	sp,sp,-64
 560:	fc06                	sd	ra,56(sp)
 562:	f822                	sd	s0,48(sp)
 564:	f426                	sd	s1,40(sp)
 566:	f04a                	sd	s2,32(sp)
 568:	ec4e                	sd	s3,24(sp)
 56a:	0080                	addi	s0,sp,64
 56c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 56e:	c299                	beqz	a3,574 <printint+0x16>
 570:	0805c863          	bltz	a1,600 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 574:	2581                	sext.w	a1,a1
  neg = 0;
 576:	4881                	li	a7,0
 578:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 57c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 57e:	2601                	sext.w	a2,a2
 580:	00000517          	auipc	a0,0x0
 584:	54850513          	addi	a0,a0,1352 # ac8 <digits>
 588:	883a                	mv	a6,a4
 58a:	2705                	addiw	a4,a4,1
 58c:	02c5f7bb          	remuw	a5,a1,a2
 590:	1782                	slli	a5,a5,0x20
 592:	9381                	srli	a5,a5,0x20
 594:	97aa                	add	a5,a5,a0
 596:	0007c783          	lbu	a5,0(a5)
 59a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 59e:	0005879b          	sext.w	a5,a1
 5a2:	02c5d5bb          	divuw	a1,a1,a2
 5a6:	0685                	addi	a3,a3,1
 5a8:	fec7f0e3          	bgeu	a5,a2,588 <printint+0x2a>
  if(neg)
 5ac:	00088b63          	beqz	a7,5c2 <printint+0x64>
    buf[i++] = '-';
 5b0:	fd040793          	addi	a5,s0,-48
 5b4:	973e                	add	a4,a4,a5
 5b6:	02d00793          	li	a5,45
 5ba:	fef70823          	sb	a5,-16(a4)
 5be:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5c2:	02e05863          	blez	a4,5f2 <printint+0x94>
 5c6:	fc040793          	addi	a5,s0,-64
 5ca:	00e78933          	add	s2,a5,a4
 5ce:	fff78993          	addi	s3,a5,-1
 5d2:	99ba                	add	s3,s3,a4
 5d4:	377d                	addiw	a4,a4,-1
 5d6:	1702                	slli	a4,a4,0x20
 5d8:	9301                	srli	a4,a4,0x20
 5da:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5de:	fff94583          	lbu	a1,-1(s2)
 5e2:	8526                	mv	a0,s1
 5e4:	00000097          	auipc	ra,0x0
 5e8:	f58080e7          	jalr	-168(ra) # 53c <putc>
  while(--i >= 0)
 5ec:	197d                	addi	s2,s2,-1
 5ee:	ff3918e3          	bne	s2,s3,5de <printint+0x80>
}
 5f2:	70e2                	ld	ra,56(sp)
 5f4:	7442                	ld	s0,48(sp)
 5f6:	74a2                	ld	s1,40(sp)
 5f8:	7902                	ld	s2,32(sp)
 5fa:	69e2                	ld	s3,24(sp)
 5fc:	6121                	addi	sp,sp,64
 5fe:	8082                	ret
    x = -xx;
 600:	40b005bb          	negw	a1,a1
    neg = 1;
 604:	4885                	li	a7,1
    x = -xx;
 606:	bf8d                	j	578 <printint+0x1a>

0000000000000608 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 608:	7119                	addi	sp,sp,-128
 60a:	fc86                	sd	ra,120(sp)
 60c:	f8a2                	sd	s0,112(sp)
 60e:	f4a6                	sd	s1,104(sp)
 610:	f0ca                	sd	s2,96(sp)
 612:	ecce                	sd	s3,88(sp)
 614:	e8d2                	sd	s4,80(sp)
 616:	e4d6                	sd	s5,72(sp)
 618:	e0da                	sd	s6,64(sp)
 61a:	fc5e                	sd	s7,56(sp)
 61c:	f862                	sd	s8,48(sp)
 61e:	f466                	sd	s9,40(sp)
 620:	f06a                	sd	s10,32(sp)
 622:	ec6e                	sd	s11,24(sp)
 624:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 626:	0005c903          	lbu	s2,0(a1)
 62a:	18090f63          	beqz	s2,7c8 <vprintf+0x1c0>
 62e:	8aaa                	mv	s5,a0
 630:	8b32                	mv	s6,a2
 632:	00158493          	addi	s1,a1,1
  state = 0;
 636:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 638:	02500a13          	li	s4,37
      if(c == 'd'){
 63c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 640:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 644:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 648:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 64c:	00000b97          	auipc	s7,0x0
 650:	47cb8b93          	addi	s7,s7,1148 # ac8 <digits>
 654:	a839                	j	672 <vprintf+0x6a>
        putc(fd, c);
 656:	85ca                	mv	a1,s2
 658:	8556                	mv	a0,s5
 65a:	00000097          	auipc	ra,0x0
 65e:	ee2080e7          	jalr	-286(ra) # 53c <putc>
 662:	a019                	j	668 <vprintf+0x60>
    } else if(state == '%'){
 664:	01498f63          	beq	s3,s4,682 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 668:	0485                	addi	s1,s1,1
 66a:	fff4c903          	lbu	s2,-1(s1)
 66e:	14090d63          	beqz	s2,7c8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 672:	0009079b          	sext.w	a5,s2
    if(state == 0){
 676:	fe0997e3          	bnez	s3,664 <vprintf+0x5c>
      if(c == '%'){
 67a:	fd479ee3          	bne	a5,s4,656 <vprintf+0x4e>
        state = '%';
 67e:	89be                	mv	s3,a5
 680:	b7e5                	j	668 <vprintf+0x60>
      if(c == 'd'){
 682:	05878063          	beq	a5,s8,6c2 <vprintf+0xba>
      } else if(c == 'l') {
 686:	05978c63          	beq	a5,s9,6de <vprintf+0xd6>
      } else if(c == 'x') {
 68a:	07a78863          	beq	a5,s10,6fa <vprintf+0xf2>
      } else if(c == 'p') {
 68e:	09b78463          	beq	a5,s11,716 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 692:	07300713          	li	a4,115
 696:	0ce78663          	beq	a5,a4,762 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 69a:	06300713          	li	a4,99
 69e:	0ee78e63          	beq	a5,a4,79a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 6a2:	11478863          	beq	a5,s4,7b2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6a6:	85d2                	mv	a1,s4
 6a8:	8556                	mv	a0,s5
 6aa:	00000097          	auipc	ra,0x0
 6ae:	e92080e7          	jalr	-366(ra) # 53c <putc>
        putc(fd, c);
 6b2:	85ca                	mv	a1,s2
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	e86080e7          	jalr	-378(ra) # 53c <putc>
      }
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	b765                	j	668 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6c2:	008b0913          	addi	s2,s6,8
 6c6:	4685                	li	a3,1
 6c8:	4629                	li	a2,10
 6ca:	000b2583          	lw	a1,0(s6)
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	e8e080e7          	jalr	-370(ra) # 55e <printint>
 6d8:	8b4a                	mv	s6,s2
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	b771                	j	668 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6de:	008b0913          	addi	s2,s6,8
 6e2:	4681                	li	a3,0
 6e4:	4629                	li	a2,10
 6e6:	000b2583          	lw	a1,0(s6)
 6ea:	8556                	mv	a0,s5
 6ec:	00000097          	auipc	ra,0x0
 6f0:	e72080e7          	jalr	-398(ra) # 55e <printint>
 6f4:	8b4a                	mv	s6,s2
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	bf85                	j	668 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6fa:	008b0913          	addi	s2,s6,8
 6fe:	4681                	li	a3,0
 700:	4641                	li	a2,16
 702:	000b2583          	lw	a1,0(s6)
 706:	8556                	mv	a0,s5
 708:	00000097          	auipc	ra,0x0
 70c:	e56080e7          	jalr	-426(ra) # 55e <printint>
 710:	8b4a                	mv	s6,s2
      state = 0;
 712:	4981                	li	s3,0
 714:	bf91                	j	668 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 716:	008b0793          	addi	a5,s6,8
 71a:	f8f43423          	sd	a5,-120(s0)
 71e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 722:	03000593          	li	a1,48
 726:	8556                	mv	a0,s5
 728:	00000097          	auipc	ra,0x0
 72c:	e14080e7          	jalr	-492(ra) # 53c <putc>
  putc(fd, 'x');
 730:	85ea                	mv	a1,s10
 732:	8556                	mv	a0,s5
 734:	00000097          	auipc	ra,0x0
 738:	e08080e7          	jalr	-504(ra) # 53c <putc>
 73c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 73e:	03c9d793          	srli	a5,s3,0x3c
 742:	97de                	add	a5,a5,s7
 744:	0007c583          	lbu	a1,0(a5)
 748:	8556                	mv	a0,s5
 74a:	00000097          	auipc	ra,0x0
 74e:	df2080e7          	jalr	-526(ra) # 53c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 752:	0992                	slli	s3,s3,0x4
 754:	397d                	addiw	s2,s2,-1
 756:	fe0914e3          	bnez	s2,73e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 75a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 75e:	4981                	li	s3,0
 760:	b721                	j	668 <vprintf+0x60>
        s = va_arg(ap, char*);
 762:	008b0993          	addi	s3,s6,8
 766:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 76a:	02090163          	beqz	s2,78c <vprintf+0x184>
        while(*s != 0){
 76e:	00094583          	lbu	a1,0(s2)
 772:	c9a1                	beqz	a1,7c2 <vprintf+0x1ba>
          putc(fd, *s);
 774:	8556                	mv	a0,s5
 776:	00000097          	auipc	ra,0x0
 77a:	dc6080e7          	jalr	-570(ra) # 53c <putc>
          s++;
 77e:	0905                	addi	s2,s2,1
        while(*s != 0){
 780:	00094583          	lbu	a1,0(s2)
 784:	f9e5                	bnez	a1,774 <vprintf+0x16c>
        s = va_arg(ap, char*);
 786:	8b4e                	mv	s6,s3
      state = 0;
 788:	4981                	li	s3,0
 78a:	bdf9                	j	668 <vprintf+0x60>
          s = "(null)";
 78c:	00000917          	auipc	s2,0x0
 790:	33490913          	addi	s2,s2,820 # ac0 <malloc+0x1ee>
        while(*s != 0){
 794:	02800593          	li	a1,40
 798:	bff1                	j	774 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 79a:	008b0913          	addi	s2,s6,8
 79e:	000b4583          	lbu	a1,0(s6)
 7a2:	8556                	mv	a0,s5
 7a4:	00000097          	auipc	ra,0x0
 7a8:	d98080e7          	jalr	-616(ra) # 53c <putc>
 7ac:	8b4a                	mv	s6,s2
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	bd65                	j	668 <vprintf+0x60>
        putc(fd, c);
 7b2:	85d2                	mv	a1,s4
 7b4:	8556                	mv	a0,s5
 7b6:	00000097          	auipc	ra,0x0
 7ba:	d86080e7          	jalr	-634(ra) # 53c <putc>
      state = 0;
 7be:	4981                	li	s3,0
 7c0:	b565                	j	668 <vprintf+0x60>
        s = va_arg(ap, char*);
 7c2:	8b4e                	mv	s6,s3
      state = 0;
 7c4:	4981                	li	s3,0
 7c6:	b54d                	j	668 <vprintf+0x60>
    }
  }
}
 7c8:	70e6                	ld	ra,120(sp)
 7ca:	7446                	ld	s0,112(sp)
 7cc:	74a6                	ld	s1,104(sp)
 7ce:	7906                	ld	s2,96(sp)
 7d0:	69e6                	ld	s3,88(sp)
 7d2:	6a46                	ld	s4,80(sp)
 7d4:	6aa6                	ld	s5,72(sp)
 7d6:	6b06                	ld	s6,64(sp)
 7d8:	7be2                	ld	s7,56(sp)
 7da:	7c42                	ld	s8,48(sp)
 7dc:	7ca2                	ld	s9,40(sp)
 7de:	7d02                	ld	s10,32(sp)
 7e0:	6de2                	ld	s11,24(sp)
 7e2:	6109                	addi	sp,sp,128
 7e4:	8082                	ret

00000000000007e6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7e6:	715d                	addi	sp,sp,-80
 7e8:	ec06                	sd	ra,24(sp)
 7ea:	e822                	sd	s0,16(sp)
 7ec:	1000                	addi	s0,sp,32
 7ee:	e010                	sd	a2,0(s0)
 7f0:	e414                	sd	a3,8(s0)
 7f2:	e818                	sd	a4,16(s0)
 7f4:	ec1c                	sd	a5,24(s0)
 7f6:	03043023          	sd	a6,32(s0)
 7fa:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7fe:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 802:	8622                	mv	a2,s0
 804:	00000097          	auipc	ra,0x0
 808:	e04080e7          	jalr	-508(ra) # 608 <vprintf>
}
 80c:	60e2                	ld	ra,24(sp)
 80e:	6442                	ld	s0,16(sp)
 810:	6161                	addi	sp,sp,80
 812:	8082                	ret

0000000000000814 <printf>:

void
printf(const char *fmt, ...)
{
 814:	711d                	addi	sp,sp,-96
 816:	ec06                	sd	ra,24(sp)
 818:	e822                	sd	s0,16(sp)
 81a:	1000                	addi	s0,sp,32
 81c:	e40c                	sd	a1,8(s0)
 81e:	e810                	sd	a2,16(s0)
 820:	ec14                	sd	a3,24(s0)
 822:	f018                	sd	a4,32(s0)
 824:	f41c                	sd	a5,40(s0)
 826:	03043823          	sd	a6,48(s0)
 82a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 82e:	00840613          	addi	a2,s0,8
 832:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 836:	85aa                	mv	a1,a0
 838:	4505                	li	a0,1
 83a:	00000097          	auipc	ra,0x0
 83e:	dce080e7          	jalr	-562(ra) # 608 <vprintf>
}
 842:	60e2                	ld	ra,24(sp)
 844:	6442                	ld	s0,16(sp)
 846:	6125                	addi	sp,sp,96
 848:	8082                	ret

000000000000084a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 84a:	1141                	addi	sp,sp,-16
 84c:	e422                	sd	s0,8(sp)
 84e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 850:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 854:	00000797          	auipc	a5,0x0
 858:	28c7b783          	ld	a5,652(a5) # ae0 <freep>
 85c:	a805                	j	88c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 85e:	4618                	lw	a4,8(a2)
 860:	9db9                	addw	a1,a1,a4
 862:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 866:	6398                	ld	a4,0(a5)
 868:	6318                	ld	a4,0(a4)
 86a:	fee53823          	sd	a4,-16(a0)
 86e:	a091                	j	8b2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 870:	ff852703          	lw	a4,-8(a0)
 874:	9e39                	addw	a2,a2,a4
 876:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 878:	ff053703          	ld	a4,-16(a0)
 87c:	e398                	sd	a4,0(a5)
 87e:	a099                	j	8c4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 880:	6398                	ld	a4,0(a5)
 882:	00e7e463          	bltu	a5,a4,88a <free+0x40>
 886:	00e6ea63          	bltu	a3,a4,89a <free+0x50>
{
 88a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 88c:	fed7fae3          	bgeu	a5,a3,880 <free+0x36>
 890:	6398                	ld	a4,0(a5)
 892:	00e6e463          	bltu	a3,a4,89a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 896:	fee7eae3          	bltu	a5,a4,88a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 89a:	ff852583          	lw	a1,-8(a0)
 89e:	6390                	ld	a2,0(a5)
 8a0:	02059813          	slli	a6,a1,0x20
 8a4:	01c85713          	srli	a4,a6,0x1c
 8a8:	9736                	add	a4,a4,a3
 8aa:	fae60ae3          	beq	a2,a4,85e <free+0x14>
    bp->s.ptr = p->s.ptr;
 8ae:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8b2:	4790                	lw	a2,8(a5)
 8b4:	02061593          	slli	a1,a2,0x20
 8b8:	01c5d713          	srli	a4,a1,0x1c
 8bc:	973e                	add	a4,a4,a5
 8be:	fae689e3          	beq	a3,a4,870 <free+0x26>
  } else
    p->s.ptr = bp;
 8c2:	e394                	sd	a3,0(a5)
  freep = p;
 8c4:	00000717          	auipc	a4,0x0
 8c8:	20f73e23          	sd	a5,540(a4) # ae0 <freep>
}
 8cc:	6422                	ld	s0,8(sp)
 8ce:	0141                	addi	sp,sp,16
 8d0:	8082                	ret

00000000000008d2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8d2:	7139                	addi	sp,sp,-64
 8d4:	fc06                	sd	ra,56(sp)
 8d6:	f822                	sd	s0,48(sp)
 8d8:	f426                	sd	s1,40(sp)
 8da:	f04a                	sd	s2,32(sp)
 8dc:	ec4e                	sd	s3,24(sp)
 8de:	e852                	sd	s4,16(sp)
 8e0:	e456                	sd	s5,8(sp)
 8e2:	e05a                	sd	s6,0(sp)
 8e4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8e6:	02051493          	slli	s1,a0,0x20
 8ea:	9081                	srli	s1,s1,0x20
 8ec:	04bd                	addi	s1,s1,15
 8ee:	8091                	srli	s1,s1,0x4
 8f0:	0014899b          	addiw	s3,s1,1
 8f4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8f6:	00000517          	auipc	a0,0x0
 8fa:	1ea53503          	ld	a0,490(a0) # ae0 <freep>
 8fe:	c515                	beqz	a0,92a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 900:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 902:	4798                	lw	a4,8(a5)
 904:	02977f63          	bgeu	a4,s1,942 <malloc+0x70>
 908:	8a4e                	mv	s4,s3
 90a:	0009871b          	sext.w	a4,s3
 90e:	6685                	lui	a3,0x1
 910:	00d77363          	bgeu	a4,a3,916 <malloc+0x44>
 914:	6a05                	lui	s4,0x1
 916:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 91a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 91e:	00000917          	auipc	s2,0x0
 922:	1c290913          	addi	s2,s2,450 # ae0 <freep>
  if(p == (char*)-1)
 926:	5afd                	li	s5,-1
 928:	a895                	j	99c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 92a:	00000797          	auipc	a5,0x0
 92e:	1be78793          	addi	a5,a5,446 # ae8 <base>
 932:	00000717          	auipc	a4,0x0
 936:	1af73723          	sd	a5,430(a4) # ae0 <freep>
 93a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 93c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 940:	b7e1                	j	908 <malloc+0x36>
      if(p->s.size == nunits)
 942:	02e48c63          	beq	s1,a4,97a <malloc+0xa8>
        p->s.size -= nunits;
 946:	4137073b          	subw	a4,a4,s3
 94a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 94c:	02071693          	slli	a3,a4,0x20
 950:	01c6d713          	srli	a4,a3,0x1c
 954:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 956:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 95a:	00000717          	auipc	a4,0x0
 95e:	18a73323          	sd	a0,390(a4) # ae0 <freep>
      return (void*)(p + 1);
 962:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 966:	70e2                	ld	ra,56(sp)
 968:	7442                	ld	s0,48(sp)
 96a:	74a2                	ld	s1,40(sp)
 96c:	7902                	ld	s2,32(sp)
 96e:	69e2                	ld	s3,24(sp)
 970:	6a42                	ld	s4,16(sp)
 972:	6aa2                	ld	s5,8(sp)
 974:	6b02                	ld	s6,0(sp)
 976:	6121                	addi	sp,sp,64
 978:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 97a:	6398                	ld	a4,0(a5)
 97c:	e118                	sd	a4,0(a0)
 97e:	bff1                	j	95a <malloc+0x88>
  hp->s.size = nu;
 980:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 984:	0541                	addi	a0,a0,16
 986:	00000097          	auipc	ra,0x0
 98a:	ec4080e7          	jalr	-316(ra) # 84a <free>
  return freep;
 98e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 992:	d971                	beqz	a0,966 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 994:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 996:	4798                	lw	a4,8(a5)
 998:	fa9775e3          	bgeu	a4,s1,942 <malloc+0x70>
    if(p == freep)
 99c:	00093703          	ld	a4,0(s2)
 9a0:	853e                	mv	a0,a5
 9a2:	fef719e3          	bne	a4,a5,994 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 9a6:	8552                	mv	a0,s4
 9a8:	00000097          	auipc	ra,0x0
 9ac:	b64080e7          	jalr	-1180(ra) # 50c <sbrk>
  if(p == (char*)-1)
 9b0:	fd5518e3          	bne	a0,s5,980 <malloc+0xae>
        return 0;
 9b4:	4501                	li	a0,0
 9b6:	bf45                	j	966 <malloc+0x94>
