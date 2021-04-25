
user/_tracetest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_fork>:
#define SYS_mkdir  20
#define SYS_close  21
#define SYS_trace  22

void
test_fork(void){
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int pid = getpid();
   c:	00000097          	auipc	ra,0x0
  10:	476080e7          	jalr	1142(ra) # 482 <getpid>
  14:	85aa                	mv	a1,a0
  int ans=trace(1 << SYS_fork|1 << SYS_sbrk|1<<SYS_mkdir,pid);
  16:	00101537          	lui	a0,0x101
  1a:	0509                	addi	a0,a0,2
  1c:	00000097          	auipc	ra,0x0
  20:	486080e7          	jalr	1158(ra) # 4a2 <trace>
  24:	892a                	mv	s2,a0
  int ans2= trace(1<<SYS_kill,1234);
  26:	4d200593          	li	a1,1234
  2a:	04000513          	li	a0,64
  2e:	00000097          	auipc	ra,0x0
  32:	474080e7          	jalr	1140(ra) # 4a2 <trace>
  36:	84aa                	mv	s1,a0
  // trace(,pid);
  int child = fork();
  38:	00000097          	auipc	ra,0x0
  3c:	3c2080e7          	jalr	962(ra) # 3fa <fork>
  if(child == 0){
  40:	e11d                	bnez	a0,66 <test_fork+0x66>
    sbrk(4096);
  42:	6505                	lui	a0,0x1
  44:	00000097          	auipc	ra,0x0
  48:	446080e7          	jalr	1094(ra) # 48a <sbrk>
    char* name="amit";
    mkdir(name);
  4c:	00001517          	auipc	a0,0x1
  50:	8ec50513          	addi	a0,a0,-1812 # 938 <malloc+0xe8>
  54:	00000097          	auipc	ra,0x0
  58:	416080e7          	jalr	1046(ra) # 46a <mkdir>
    exit(0);
  5c:	4501                	li	a0,0
  5e:	00000097          	auipc	ra,0x0
  62:	3a4080e7          	jalr	932(ra) # 402 <exit>
  }
  else{
    // trace(1<<SYS_mkdir,child);
    wait(0);
  66:	4501                	li	a0,0
  68:	00000097          	auipc	ra,0x0
  6c:	3a2080e7          	jalr	930(ra) # 40a <wait>
    printf("ans should be 0 = %d\n",ans);
  70:	85ca                	mv	a1,s2
  72:	00001517          	auipc	a0,0x1
  76:	8ce50513          	addi	a0,a0,-1842 # 940 <malloc+0xf0>
  7a:	00000097          	auipc	ra,0x0
  7e:	718080e7          	jalr	1816(ra) # 792 <printf>
    printf("ans should be -1 = %d\n",ans2);
  82:	85a6                	mv	a1,s1
  84:	00001517          	auipc	a0,0x1
  88:	8d450513          	addi	a0,a0,-1836 # 958 <malloc+0x108>
  8c:	00000097          	auipc	ra,0x0
  90:	706080e7          	jalr	1798(ra) # 792 <printf>
  }
  exit(0);
  94:	4501                	li	a0,0
  96:	00000097          	auipc	ra,0x0
  9a:	36c080e7          	jalr	876(ra) # 402 <exit>

000000000000009e <test_sbrk>:
} 

void
test_sbrk(void){
  9e:	1141                	addi	sp,sp,-16
  a0:	e406                	sd	ra,8(sp)
  a2:	e022                	sd	s0,0(sp)
  a4:	0800                	addi	s0,sp,16
  int pid = getpid();
  a6:	00000097          	auipc	ra,0x0
  aa:	3dc080e7          	jalr	988(ra) # 482 <getpid>
  ae:	85aa                	mv	a1,a0
  trace(1 << SYS_sbrk,pid);
  b0:	6505                	lui	a0,0x1
  b2:	00000097          	auipc	ra,0x0
  b6:	3f0080e7          	jalr	1008(ra) # 4a2 <trace>
  sbrk(4096);
  ba:	6505                	lui	a0,0x1
  bc:	00000097          	auipc	ra,0x0
  c0:	3ce080e7          	jalr	974(ra) # 48a <sbrk>
  exit(0);
  c4:	4501                	li	a0,0
  c6:	00000097          	auipc	ra,0x0
  ca:	33c080e7          	jalr	828(ra) # 402 <exit>

00000000000000ce <test_kill>:
} 

void
test_kill(void){
  ce:	1101                	addi	sp,sp,-32
  d0:	ec06                	sd	ra,24(sp)
  d2:	e822                	sd	s0,16(sp)
  d4:	e426                	sd	s1,8(sp)
  d6:	1000                	addi	s0,sp,32
  int pid = getpid();
  d8:	00000097          	auipc	ra,0x0
  dc:	3aa080e7          	jalr	938(ra) # 482 <getpid>
  e0:	85aa                	mv	a1,a0
  trace(1 << SYS_kill,pid);
  e2:	04000513          	li	a0,64
  e6:	00000097          	auipc	ra,0x0
  ea:	3bc080e7          	jalr	956(ra) # 4a2 <trace>
  int child = fork();
  ee:	00000097          	auipc	ra,0x0
  f2:	30c080e7          	jalr	780(ra) # 3fa <fork>
  if(child == 0){
  f6:	ed01                	bnez	a0,10e <test_kill+0x40>
    sleep(100);
  f8:	06400513          	li	a0,100
  fc:	00000097          	auipc	ra,0x0
 100:	396080e7          	jalr	918(ra) # 492 <sleep>
    exit(0);
 104:	4501                	li	a0,0
 106:	00000097          	auipc	ra,0x0
 10a:	2fc080e7          	jalr	764(ra) # 402 <exit>
 10e:	84aa                	mv	s1,a0
  }
  else{
    printf("in tracetest, kill child = %d\n",child);
 110:	85aa                	mv	a1,a0
 112:	00001517          	auipc	a0,0x1
 116:	85e50513          	addi	a0,a0,-1954 # 970 <malloc+0x120>
 11a:	00000097          	auipc	ra,0x0
 11e:	678080e7          	jalr	1656(ra) # 792 <printf>
    kill(child);
 122:	8526                	mv	a0,s1
 124:	00000097          	auipc	ra,0x0
 128:	30e080e7          	jalr	782(ra) # 432 <kill>
    wait(0);
 12c:	4501                	li	a0,0
 12e:	00000097          	auipc	ra,0x0
 132:	2dc080e7          	jalr	732(ra) # 40a <wait>
    kill(child);
 136:	8526                	mv	a0,s1
 138:	00000097          	auipc	ra,0x0
 13c:	2fa080e7          	jalr	762(ra) # 432 <kill>
  }
  exit(0);
 140:	4501                	li	a0,0
 142:	00000097          	auipc	ra,0x0
 146:	2c0080e7          	jalr	704(ra) # 402 <exit>

000000000000014a <test_write>:
}

void
test_write(void){
 14a:	1141                	addi	sp,sp,-16
 14c:	e406                	sd	ra,8(sp)
 14e:	e022                	sd	s0,0(sp)
 150:	0800                	addi	s0,sp,16
  int pid = getpid();
 152:	00000097          	auipc	ra,0x0
 156:	330080e7          	jalr	816(ra) # 482 <getpid>
 15a:	85aa                	mv	a1,a0
  trace(1 << SYS_write,pid);
 15c:	6541                	lui	a0,0x10
 15e:	00000097          	auipc	ra,0x0
 162:	344080e7          	jalr	836(ra) # 4a2 <trace>
  char* buf="amit";
  write(1,buf,4);
 166:	4611                	li	a2,4
 168:	00000597          	auipc	a1,0x0
 16c:	7d058593          	addi	a1,a1,2000 # 938 <malloc+0xe8>
 170:	4505                	li	a0,1
 172:	00000097          	auipc	ra,0x0
 176:	2b0080e7          	jalr	688(ra) # 422 <write>
  exit(0);
 17a:	4501                	li	a0,0
 17c:	00000097          	auipc	ra,0x0
 180:	286080e7          	jalr	646(ra) # 402 <exit>

0000000000000184 <main>:
} 

int
main(int argc, char *argv[])
{
 184:	1141                	addi	sp,sp,-16
 186:	e406                	sd	ra,8(sp)
 188:	e022                	sd	s0,0(sp)
 18a:	0800                	addi	s0,sp,16
  test_fork();
 18c:	00000097          	auipc	ra,0x0
 190:	e74080e7          	jalr	-396(ra) # 0 <test_fork>

0000000000000194 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 194:	1141                	addi	sp,sp,-16
 196:	e422                	sd	s0,8(sp)
 198:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 19a:	87aa                	mv	a5,a0
 19c:	0585                	addi	a1,a1,1
 19e:	0785                	addi	a5,a5,1
 1a0:	fff5c703          	lbu	a4,-1(a1)
 1a4:	fee78fa3          	sb	a4,-1(a5)
 1a8:	fb75                	bnez	a4,19c <strcpy+0x8>
    ;
  return os;
}
 1aa:	6422                	ld	s0,8(sp)
 1ac:	0141                	addi	sp,sp,16
 1ae:	8082                	ret

00000000000001b0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b0:	1141                	addi	sp,sp,-16
 1b2:	e422                	sd	s0,8(sp)
 1b4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1b6:	00054783          	lbu	a5,0(a0) # 10000 <__global_pointer$+0xee57>
 1ba:	cb91                	beqz	a5,1ce <strcmp+0x1e>
 1bc:	0005c703          	lbu	a4,0(a1)
 1c0:	00f71763          	bne	a4,a5,1ce <strcmp+0x1e>
    p++, q++;
 1c4:	0505                	addi	a0,a0,1
 1c6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1c8:	00054783          	lbu	a5,0(a0)
 1cc:	fbe5                	bnez	a5,1bc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1ce:	0005c503          	lbu	a0,0(a1)
}
 1d2:	40a7853b          	subw	a0,a5,a0
 1d6:	6422                	ld	s0,8(sp)
 1d8:	0141                	addi	sp,sp,16
 1da:	8082                	ret

00000000000001dc <strlen>:

uint
strlen(const char *s)
{
 1dc:	1141                	addi	sp,sp,-16
 1de:	e422                	sd	s0,8(sp)
 1e0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1e2:	00054783          	lbu	a5,0(a0)
 1e6:	cf91                	beqz	a5,202 <strlen+0x26>
 1e8:	0505                	addi	a0,a0,1
 1ea:	87aa                	mv	a5,a0
 1ec:	4685                	li	a3,1
 1ee:	9e89                	subw	a3,a3,a0
 1f0:	00f6853b          	addw	a0,a3,a5
 1f4:	0785                	addi	a5,a5,1
 1f6:	fff7c703          	lbu	a4,-1(a5)
 1fa:	fb7d                	bnez	a4,1f0 <strlen+0x14>
    ;
  return n;
}
 1fc:	6422                	ld	s0,8(sp)
 1fe:	0141                	addi	sp,sp,16
 200:	8082                	ret
  for(n = 0; s[n]; n++)
 202:	4501                	li	a0,0
 204:	bfe5                	j	1fc <strlen+0x20>

0000000000000206 <memset>:

void*
memset(void *dst, int c, uint n)
{
 206:	1141                	addi	sp,sp,-16
 208:	e422                	sd	s0,8(sp)
 20a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 20c:	ca19                	beqz	a2,222 <memset+0x1c>
 20e:	87aa                	mv	a5,a0
 210:	1602                	slli	a2,a2,0x20
 212:	9201                	srli	a2,a2,0x20
 214:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 218:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 21c:	0785                	addi	a5,a5,1
 21e:	fee79de3          	bne	a5,a4,218 <memset+0x12>
  }
  return dst;
}
 222:	6422                	ld	s0,8(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret

0000000000000228 <strchr>:

char*
strchr(const char *s, char c)
{
 228:	1141                	addi	sp,sp,-16
 22a:	e422                	sd	s0,8(sp)
 22c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 22e:	00054783          	lbu	a5,0(a0)
 232:	cb99                	beqz	a5,248 <strchr+0x20>
    if(*s == c)
 234:	00f58763          	beq	a1,a5,242 <strchr+0x1a>
  for(; *s; s++)
 238:	0505                	addi	a0,a0,1
 23a:	00054783          	lbu	a5,0(a0)
 23e:	fbfd                	bnez	a5,234 <strchr+0xc>
      return (char*)s;
  return 0;
 240:	4501                	li	a0,0
}
 242:	6422                	ld	s0,8(sp)
 244:	0141                	addi	sp,sp,16
 246:	8082                	ret
  return 0;
 248:	4501                	li	a0,0
 24a:	bfe5                	j	242 <strchr+0x1a>

000000000000024c <gets>:

char*
gets(char *buf, int max)
{
 24c:	711d                	addi	sp,sp,-96
 24e:	ec86                	sd	ra,88(sp)
 250:	e8a2                	sd	s0,80(sp)
 252:	e4a6                	sd	s1,72(sp)
 254:	e0ca                	sd	s2,64(sp)
 256:	fc4e                	sd	s3,56(sp)
 258:	f852                	sd	s4,48(sp)
 25a:	f456                	sd	s5,40(sp)
 25c:	f05a                	sd	s6,32(sp)
 25e:	ec5e                	sd	s7,24(sp)
 260:	1080                	addi	s0,sp,96
 262:	8baa                	mv	s7,a0
 264:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 266:	892a                	mv	s2,a0
 268:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 26a:	4aa9                	li	s5,10
 26c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 26e:	89a6                	mv	s3,s1
 270:	2485                	addiw	s1,s1,1
 272:	0344d863          	bge	s1,s4,2a2 <gets+0x56>
    cc = read(0, &c, 1);
 276:	4605                	li	a2,1
 278:	faf40593          	addi	a1,s0,-81
 27c:	4501                	li	a0,0
 27e:	00000097          	auipc	ra,0x0
 282:	19c080e7          	jalr	412(ra) # 41a <read>
    if(cc < 1)
 286:	00a05e63          	blez	a0,2a2 <gets+0x56>
    buf[i++] = c;
 28a:	faf44783          	lbu	a5,-81(s0)
 28e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 292:	01578763          	beq	a5,s5,2a0 <gets+0x54>
 296:	0905                	addi	s2,s2,1
 298:	fd679be3          	bne	a5,s6,26e <gets+0x22>
  for(i=0; i+1 < max; ){
 29c:	89a6                	mv	s3,s1
 29e:	a011                	j	2a2 <gets+0x56>
 2a0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2a2:	99de                	add	s3,s3,s7
 2a4:	00098023          	sb	zero,0(s3)
  return buf;
}
 2a8:	855e                	mv	a0,s7
 2aa:	60e6                	ld	ra,88(sp)
 2ac:	6446                	ld	s0,80(sp)
 2ae:	64a6                	ld	s1,72(sp)
 2b0:	6906                	ld	s2,64(sp)
 2b2:	79e2                	ld	s3,56(sp)
 2b4:	7a42                	ld	s4,48(sp)
 2b6:	7aa2                	ld	s5,40(sp)
 2b8:	7b02                	ld	s6,32(sp)
 2ba:	6be2                	ld	s7,24(sp)
 2bc:	6125                	addi	sp,sp,96
 2be:	8082                	ret

00000000000002c0 <stat>:

int
stat(const char *n, struct stat *st)
{
 2c0:	1101                	addi	sp,sp,-32
 2c2:	ec06                	sd	ra,24(sp)
 2c4:	e822                	sd	s0,16(sp)
 2c6:	e426                	sd	s1,8(sp)
 2c8:	e04a                	sd	s2,0(sp)
 2ca:	1000                	addi	s0,sp,32
 2cc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ce:	4581                	li	a1,0
 2d0:	00000097          	auipc	ra,0x0
 2d4:	172080e7          	jalr	370(ra) # 442 <open>
  if(fd < 0)
 2d8:	02054563          	bltz	a0,302 <stat+0x42>
 2dc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2de:	85ca                	mv	a1,s2
 2e0:	00000097          	auipc	ra,0x0
 2e4:	17a080e7          	jalr	378(ra) # 45a <fstat>
 2e8:	892a                	mv	s2,a0
  close(fd);
 2ea:	8526                	mv	a0,s1
 2ec:	00000097          	auipc	ra,0x0
 2f0:	13e080e7          	jalr	318(ra) # 42a <close>
  return r;
}
 2f4:	854a                	mv	a0,s2
 2f6:	60e2                	ld	ra,24(sp)
 2f8:	6442                	ld	s0,16(sp)
 2fa:	64a2                	ld	s1,8(sp)
 2fc:	6902                	ld	s2,0(sp)
 2fe:	6105                	addi	sp,sp,32
 300:	8082                	ret
    return -1;
 302:	597d                	li	s2,-1
 304:	bfc5                	j	2f4 <stat+0x34>

0000000000000306 <atoi>:

int
atoi(const char *s)
{
 306:	1141                	addi	sp,sp,-16
 308:	e422                	sd	s0,8(sp)
 30a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 30c:	00054603          	lbu	a2,0(a0)
 310:	fd06079b          	addiw	a5,a2,-48
 314:	0ff7f793          	andi	a5,a5,255
 318:	4725                	li	a4,9
 31a:	02f76963          	bltu	a4,a5,34c <atoi+0x46>
 31e:	86aa                	mv	a3,a0
  n = 0;
 320:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 322:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 324:	0685                	addi	a3,a3,1
 326:	0025179b          	slliw	a5,a0,0x2
 32a:	9fa9                	addw	a5,a5,a0
 32c:	0017979b          	slliw	a5,a5,0x1
 330:	9fb1                	addw	a5,a5,a2
 332:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 336:	0006c603          	lbu	a2,0(a3)
 33a:	fd06071b          	addiw	a4,a2,-48
 33e:	0ff77713          	andi	a4,a4,255
 342:	fee5f1e3          	bgeu	a1,a4,324 <atoi+0x1e>
  return n;
}
 346:	6422                	ld	s0,8(sp)
 348:	0141                	addi	sp,sp,16
 34a:	8082                	ret
  n = 0;
 34c:	4501                	li	a0,0
 34e:	bfe5                	j	346 <atoi+0x40>

0000000000000350 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 350:	1141                	addi	sp,sp,-16
 352:	e422                	sd	s0,8(sp)
 354:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 356:	02b57463          	bgeu	a0,a1,37e <memmove+0x2e>
    while(n-- > 0)
 35a:	00c05f63          	blez	a2,378 <memmove+0x28>
 35e:	1602                	slli	a2,a2,0x20
 360:	9201                	srli	a2,a2,0x20
 362:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 366:	872a                	mv	a4,a0
      *dst++ = *src++;
 368:	0585                	addi	a1,a1,1
 36a:	0705                	addi	a4,a4,1
 36c:	fff5c683          	lbu	a3,-1(a1)
 370:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 374:	fee79ae3          	bne	a5,a4,368 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 378:	6422                	ld	s0,8(sp)
 37a:	0141                	addi	sp,sp,16
 37c:	8082                	ret
    dst += n;
 37e:	00c50733          	add	a4,a0,a2
    src += n;
 382:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 384:	fec05ae3          	blez	a2,378 <memmove+0x28>
 388:	fff6079b          	addiw	a5,a2,-1
 38c:	1782                	slli	a5,a5,0x20
 38e:	9381                	srli	a5,a5,0x20
 390:	fff7c793          	not	a5,a5
 394:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 396:	15fd                	addi	a1,a1,-1
 398:	177d                	addi	a4,a4,-1
 39a:	0005c683          	lbu	a3,0(a1)
 39e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3a2:	fee79ae3          	bne	a5,a4,396 <memmove+0x46>
 3a6:	bfc9                	j	378 <memmove+0x28>

00000000000003a8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3a8:	1141                	addi	sp,sp,-16
 3aa:	e422                	sd	s0,8(sp)
 3ac:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3ae:	ca05                	beqz	a2,3de <memcmp+0x36>
 3b0:	fff6069b          	addiw	a3,a2,-1
 3b4:	1682                	slli	a3,a3,0x20
 3b6:	9281                	srli	a3,a3,0x20
 3b8:	0685                	addi	a3,a3,1
 3ba:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3bc:	00054783          	lbu	a5,0(a0)
 3c0:	0005c703          	lbu	a4,0(a1)
 3c4:	00e79863          	bne	a5,a4,3d4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3c8:	0505                	addi	a0,a0,1
    p2++;
 3ca:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3cc:	fed518e3          	bne	a0,a3,3bc <memcmp+0x14>
  }
  return 0;
 3d0:	4501                	li	a0,0
 3d2:	a019                	j	3d8 <memcmp+0x30>
      return *p1 - *p2;
 3d4:	40e7853b          	subw	a0,a5,a4
}
 3d8:	6422                	ld	s0,8(sp)
 3da:	0141                	addi	sp,sp,16
 3dc:	8082                	ret
  return 0;
 3de:	4501                	li	a0,0
 3e0:	bfe5                	j	3d8 <memcmp+0x30>

00000000000003e2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3e2:	1141                	addi	sp,sp,-16
 3e4:	e406                	sd	ra,8(sp)
 3e6:	e022                	sd	s0,0(sp)
 3e8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3ea:	00000097          	auipc	ra,0x0
 3ee:	f66080e7          	jalr	-154(ra) # 350 <memmove>
}
 3f2:	60a2                	ld	ra,8(sp)
 3f4:	6402                	ld	s0,0(sp)
 3f6:	0141                	addi	sp,sp,16
 3f8:	8082                	ret

00000000000003fa <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3fa:	4885                	li	a7,1
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <exit>:
.global exit
exit:
 li a7, SYS_exit
 402:	4889                	li	a7,2
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <wait>:
.global wait
wait:
 li a7, SYS_wait
 40a:	488d                	li	a7,3
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 412:	4891                	li	a7,4
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <read>:
.global read
read:
 li a7, SYS_read
 41a:	4895                	li	a7,5
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <write>:
.global write
write:
 li a7, SYS_write
 422:	48c1                	li	a7,16
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <close>:
.global close
close:
 li a7, SYS_close
 42a:	48d5                	li	a7,21
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <kill>:
.global kill
kill:
 li a7, SYS_kill
 432:	4899                	li	a7,6
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <exec>:
.global exec
exec:
 li a7, SYS_exec
 43a:	489d                	li	a7,7
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <open>:
.global open
open:
 li a7, SYS_open
 442:	48bd                	li	a7,15
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 44a:	48c5                	li	a7,17
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 452:	48c9                	li	a7,18
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 45a:	48a1                	li	a7,8
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <link>:
.global link
link:
 li a7, SYS_link
 462:	48cd                	li	a7,19
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 46a:	48d1                	li	a7,20
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 472:	48a5                	li	a7,9
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <dup>:
.global dup
dup:
 li a7, SYS_dup
 47a:	48a9                	li	a7,10
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 482:	48ad                	li	a7,11
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 48a:	48b1                	li	a7,12
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 492:	48b5                	li	a7,13
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 49a:	48b9                	li	a7,14
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <trace>:
.global trace
trace:
 li a7, SYS_trace
 4a2:	48d9                	li	a7,22
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <wait_stat>:
.global wait_stat
wait_stat:
 li a7, SYS_wait_stat
 4aa:	48dd                	li	a7,23
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 4b2:	48e1                	li	a7,24
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ba:	1101                	addi	sp,sp,-32
 4bc:	ec06                	sd	ra,24(sp)
 4be:	e822                	sd	s0,16(sp)
 4c0:	1000                	addi	s0,sp,32
 4c2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4c6:	4605                	li	a2,1
 4c8:	fef40593          	addi	a1,s0,-17
 4cc:	00000097          	auipc	ra,0x0
 4d0:	f56080e7          	jalr	-170(ra) # 422 <write>
}
 4d4:	60e2                	ld	ra,24(sp)
 4d6:	6442                	ld	s0,16(sp)
 4d8:	6105                	addi	sp,sp,32
 4da:	8082                	ret

00000000000004dc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4dc:	7139                	addi	sp,sp,-64
 4de:	fc06                	sd	ra,56(sp)
 4e0:	f822                	sd	s0,48(sp)
 4e2:	f426                	sd	s1,40(sp)
 4e4:	f04a                	sd	s2,32(sp)
 4e6:	ec4e                	sd	s3,24(sp)
 4e8:	0080                	addi	s0,sp,64
 4ea:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4ec:	c299                	beqz	a3,4f2 <printint+0x16>
 4ee:	0805c863          	bltz	a1,57e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4f2:	2581                	sext.w	a1,a1
  neg = 0;
 4f4:	4881                	li	a7,0
 4f6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4fa:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4fc:	2601                	sext.w	a2,a2
 4fe:	00000517          	auipc	a0,0x0
 502:	49a50513          	addi	a0,a0,1178 # 998 <digits>
 506:	883a                	mv	a6,a4
 508:	2705                	addiw	a4,a4,1
 50a:	02c5f7bb          	remuw	a5,a1,a2
 50e:	1782                	slli	a5,a5,0x20
 510:	9381                	srli	a5,a5,0x20
 512:	97aa                	add	a5,a5,a0
 514:	0007c783          	lbu	a5,0(a5)
 518:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 51c:	0005879b          	sext.w	a5,a1
 520:	02c5d5bb          	divuw	a1,a1,a2
 524:	0685                	addi	a3,a3,1
 526:	fec7f0e3          	bgeu	a5,a2,506 <printint+0x2a>
  if(neg)
 52a:	00088b63          	beqz	a7,540 <printint+0x64>
    buf[i++] = '-';
 52e:	fd040793          	addi	a5,s0,-48
 532:	973e                	add	a4,a4,a5
 534:	02d00793          	li	a5,45
 538:	fef70823          	sb	a5,-16(a4)
 53c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 540:	02e05863          	blez	a4,570 <printint+0x94>
 544:	fc040793          	addi	a5,s0,-64
 548:	00e78933          	add	s2,a5,a4
 54c:	fff78993          	addi	s3,a5,-1
 550:	99ba                	add	s3,s3,a4
 552:	377d                	addiw	a4,a4,-1
 554:	1702                	slli	a4,a4,0x20
 556:	9301                	srli	a4,a4,0x20
 558:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 55c:	fff94583          	lbu	a1,-1(s2)
 560:	8526                	mv	a0,s1
 562:	00000097          	auipc	ra,0x0
 566:	f58080e7          	jalr	-168(ra) # 4ba <putc>
  while(--i >= 0)
 56a:	197d                	addi	s2,s2,-1
 56c:	ff3918e3          	bne	s2,s3,55c <printint+0x80>
}
 570:	70e2                	ld	ra,56(sp)
 572:	7442                	ld	s0,48(sp)
 574:	74a2                	ld	s1,40(sp)
 576:	7902                	ld	s2,32(sp)
 578:	69e2                	ld	s3,24(sp)
 57a:	6121                	addi	sp,sp,64
 57c:	8082                	ret
    x = -xx;
 57e:	40b005bb          	negw	a1,a1
    neg = 1;
 582:	4885                	li	a7,1
    x = -xx;
 584:	bf8d                	j	4f6 <printint+0x1a>

0000000000000586 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 586:	7119                	addi	sp,sp,-128
 588:	fc86                	sd	ra,120(sp)
 58a:	f8a2                	sd	s0,112(sp)
 58c:	f4a6                	sd	s1,104(sp)
 58e:	f0ca                	sd	s2,96(sp)
 590:	ecce                	sd	s3,88(sp)
 592:	e8d2                	sd	s4,80(sp)
 594:	e4d6                	sd	s5,72(sp)
 596:	e0da                	sd	s6,64(sp)
 598:	fc5e                	sd	s7,56(sp)
 59a:	f862                	sd	s8,48(sp)
 59c:	f466                	sd	s9,40(sp)
 59e:	f06a                	sd	s10,32(sp)
 5a0:	ec6e                	sd	s11,24(sp)
 5a2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5a4:	0005c903          	lbu	s2,0(a1)
 5a8:	18090f63          	beqz	s2,746 <vprintf+0x1c0>
 5ac:	8aaa                	mv	s5,a0
 5ae:	8b32                	mv	s6,a2
 5b0:	00158493          	addi	s1,a1,1
  state = 0;
 5b4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5b6:	02500a13          	li	s4,37
      if(c == 'd'){
 5ba:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 5be:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 5c2:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 5c6:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ca:	00000b97          	auipc	s7,0x0
 5ce:	3ceb8b93          	addi	s7,s7,974 # 998 <digits>
 5d2:	a839                	j	5f0 <vprintf+0x6a>
        putc(fd, c);
 5d4:	85ca                	mv	a1,s2
 5d6:	8556                	mv	a0,s5
 5d8:	00000097          	auipc	ra,0x0
 5dc:	ee2080e7          	jalr	-286(ra) # 4ba <putc>
 5e0:	a019                	j	5e6 <vprintf+0x60>
    } else if(state == '%'){
 5e2:	01498f63          	beq	s3,s4,600 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5e6:	0485                	addi	s1,s1,1
 5e8:	fff4c903          	lbu	s2,-1(s1)
 5ec:	14090d63          	beqz	s2,746 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 5f0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5f4:	fe0997e3          	bnez	s3,5e2 <vprintf+0x5c>
      if(c == '%'){
 5f8:	fd479ee3          	bne	a5,s4,5d4 <vprintf+0x4e>
        state = '%';
 5fc:	89be                	mv	s3,a5
 5fe:	b7e5                	j	5e6 <vprintf+0x60>
      if(c == 'd'){
 600:	05878063          	beq	a5,s8,640 <vprintf+0xba>
      } else if(c == 'l') {
 604:	05978c63          	beq	a5,s9,65c <vprintf+0xd6>
      } else if(c == 'x') {
 608:	07a78863          	beq	a5,s10,678 <vprintf+0xf2>
      } else if(c == 'p') {
 60c:	09b78463          	beq	a5,s11,694 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 610:	07300713          	li	a4,115
 614:	0ce78663          	beq	a5,a4,6e0 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 618:	06300713          	li	a4,99
 61c:	0ee78e63          	beq	a5,a4,718 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 620:	11478863          	beq	a5,s4,730 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 624:	85d2                	mv	a1,s4
 626:	8556                	mv	a0,s5
 628:	00000097          	auipc	ra,0x0
 62c:	e92080e7          	jalr	-366(ra) # 4ba <putc>
        putc(fd, c);
 630:	85ca                	mv	a1,s2
 632:	8556                	mv	a0,s5
 634:	00000097          	auipc	ra,0x0
 638:	e86080e7          	jalr	-378(ra) # 4ba <putc>
      }
      state = 0;
 63c:	4981                	li	s3,0
 63e:	b765                	j	5e6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 640:	008b0913          	addi	s2,s6,8
 644:	4685                	li	a3,1
 646:	4629                	li	a2,10
 648:	000b2583          	lw	a1,0(s6)
 64c:	8556                	mv	a0,s5
 64e:	00000097          	auipc	ra,0x0
 652:	e8e080e7          	jalr	-370(ra) # 4dc <printint>
 656:	8b4a                	mv	s6,s2
      state = 0;
 658:	4981                	li	s3,0
 65a:	b771                	j	5e6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 65c:	008b0913          	addi	s2,s6,8
 660:	4681                	li	a3,0
 662:	4629                	li	a2,10
 664:	000b2583          	lw	a1,0(s6)
 668:	8556                	mv	a0,s5
 66a:	00000097          	auipc	ra,0x0
 66e:	e72080e7          	jalr	-398(ra) # 4dc <printint>
 672:	8b4a                	mv	s6,s2
      state = 0;
 674:	4981                	li	s3,0
 676:	bf85                	j	5e6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 678:	008b0913          	addi	s2,s6,8
 67c:	4681                	li	a3,0
 67e:	4641                	li	a2,16
 680:	000b2583          	lw	a1,0(s6)
 684:	8556                	mv	a0,s5
 686:	00000097          	auipc	ra,0x0
 68a:	e56080e7          	jalr	-426(ra) # 4dc <printint>
 68e:	8b4a                	mv	s6,s2
      state = 0;
 690:	4981                	li	s3,0
 692:	bf91                	j	5e6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 694:	008b0793          	addi	a5,s6,8
 698:	f8f43423          	sd	a5,-120(s0)
 69c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6a0:	03000593          	li	a1,48
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	e14080e7          	jalr	-492(ra) # 4ba <putc>
  putc(fd, 'x');
 6ae:	85ea                	mv	a1,s10
 6b0:	8556                	mv	a0,s5
 6b2:	00000097          	auipc	ra,0x0
 6b6:	e08080e7          	jalr	-504(ra) # 4ba <putc>
 6ba:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6bc:	03c9d793          	srli	a5,s3,0x3c
 6c0:	97de                	add	a5,a5,s7
 6c2:	0007c583          	lbu	a1,0(a5)
 6c6:	8556                	mv	a0,s5
 6c8:	00000097          	auipc	ra,0x0
 6cc:	df2080e7          	jalr	-526(ra) # 4ba <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6d0:	0992                	slli	s3,s3,0x4
 6d2:	397d                	addiw	s2,s2,-1
 6d4:	fe0914e3          	bnez	s2,6bc <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 6d8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6dc:	4981                	li	s3,0
 6de:	b721                	j	5e6 <vprintf+0x60>
        s = va_arg(ap, char*);
 6e0:	008b0993          	addi	s3,s6,8
 6e4:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 6e8:	02090163          	beqz	s2,70a <vprintf+0x184>
        while(*s != 0){
 6ec:	00094583          	lbu	a1,0(s2)
 6f0:	c9a1                	beqz	a1,740 <vprintf+0x1ba>
          putc(fd, *s);
 6f2:	8556                	mv	a0,s5
 6f4:	00000097          	auipc	ra,0x0
 6f8:	dc6080e7          	jalr	-570(ra) # 4ba <putc>
          s++;
 6fc:	0905                	addi	s2,s2,1
        while(*s != 0){
 6fe:	00094583          	lbu	a1,0(s2)
 702:	f9e5                	bnez	a1,6f2 <vprintf+0x16c>
        s = va_arg(ap, char*);
 704:	8b4e                	mv	s6,s3
      state = 0;
 706:	4981                	li	s3,0
 708:	bdf9                	j	5e6 <vprintf+0x60>
          s = "(null)";
 70a:	00000917          	auipc	s2,0x0
 70e:	28690913          	addi	s2,s2,646 # 990 <malloc+0x140>
        while(*s != 0){
 712:	02800593          	li	a1,40
 716:	bff1                	j	6f2 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 718:	008b0913          	addi	s2,s6,8
 71c:	000b4583          	lbu	a1,0(s6)
 720:	8556                	mv	a0,s5
 722:	00000097          	auipc	ra,0x0
 726:	d98080e7          	jalr	-616(ra) # 4ba <putc>
 72a:	8b4a                	mv	s6,s2
      state = 0;
 72c:	4981                	li	s3,0
 72e:	bd65                	j	5e6 <vprintf+0x60>
        putc(fd, c);
 730:	85d2                	mv	a1,s4
 732:	8556                	mv	a0,s5
 734:	00000097          	auipc	ra,0x0
 738:	d86080e7          	jalr	-634(ra) # 4ba <putc>
      state = 0;
 73c:	4981                	li	s3,0
 73e:	b565                	j	5e6 <vprintf+0x60>
        s = va_arg(ap, char*);
 740:	8b4e                	mv	s6,s3
      state = 0;
 742:	4981                	li	s3,0
 744:	b54d                	j	5e6 <vprintf+0x60>
    }
  }
}
 746:	70e6                	ld	ra,120(sp)
 748:	7446                	ld	s0,112(sp)
 74a:	74a6                	ld	s1,104(sp)
 74c:	7906                	ld	s2,96(sp)
 74e:	69e6                	ld	s3,88(sp)
 750:	6a46                	ld	s4,80(sp)
 752:	6aa6                	ld	s5,72(sp)
 754:	6b06                	ld	s6,64(sp)
 756:	7be2                	ld	s7,56(sp)
 758:	7c42                	ld	s8,48(sp)
 75a:	7ca2                	ld	s9,40(sp)
 75c:	7d02                	ld	s10,32(sp)
 75e:	6de2                	ld	s11,24(sp)
 760:	6109                	addi	sp,sp,128
 762:	8082                	ret

0000000000000764 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 764:	715d                	addi	sp,sp,-80
 766:	ec06                	sd	ra,24(sp)
 768:	e822                	sd	s0,16(sp)
 76a:	1000                	addi	s0,sp,32
 76c:	e010                	sd	a2,0(s0)
 76e:	e414                	sd	a3,8(s0)
 770:	e818                	sd	a4,16(s0)
 772:	ec1c                	sd	a5,24(s0)
 774:	03043023          	sd	a6,32(s0)
 778:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 77c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 780:	8622                	mv	a2,s0
 782:	00000097          	auipc	ra,0x0
 786:	e04080e7          	jalr	-508(ra) # 586 <vprintf>
}
 78a:	60e2                	ld	ra,24(sp)
 78c:	6442                	ld	s0,16(sp)
 78e:	6161                	addi	sp,sp,80
 790:	8082                	ret

0000000000000792 <printf>:

void
printf(const char *fmt, ...)
{
 792:	711d                	addi	sp,sp,-96
 794:	ec06                	sd	ra,24(sp)
 796:	e822                	sd	s0,16(sp)
 798:	1000                	addi	s0,sp,32
 79a:	e40c                	sd	a1,8(s0)
 79c:	e810                	sd	a2,16(s0)
 79e:	ec14                	sd	a3,24(s0)
 7a0:	f018                	sd	a4,32(s0)
 7a2:	f41c                	sd	a5,40(s0)
 7a4:	03043823          	sd	a6,48(s0)
 7a8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7ac:	00840613          	addi	a2,s0,8
 7b0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7b4:	85aa                	mv	a1,a0
 7b6:	4505                	li	a0,1
 7b8:	00000097          	auipc	ra,0x0
 7bc:	dce080e7          	jalr	-562(ra) # 586 <vprintf>
}
 7c0:	60e2                	ld	ra,24(sp)
 7c2:	6442                	ld	s0,16(sp)
 7c4:	6125                	addi	sp,sp,96
 7c6:	8082                	ret

00000000000007c8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7c8:	1141                	addi	sp,sp,-16
 7ca:	e422                	sd	s0,8(sp)
 7cc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ce:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d2:	00000797          	auipc	a5,0x0
 7d6:	1de7b783          	ld	a5,478(a5) # 9b0 <freep>
 7da:	a805                	j	80a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7dc:	4618                	lw	a4,8(a2)
 7de:	9db9                	addw	a1,a1,a4
 7e0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7e4:	6398                	ld	a4,0(a5)
 7e6:	6318                	ld	a4,0(a4)
 7e8:	fee53823          	sd	a4,-16(a0)
 7ec:	a091                	j	830 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ee:	ff852703          	lw	a4,-8(a0)
 7f2:	9e39                	addw	a2,a2,a4
 7f4:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7f6:	ff053703          	ld	a4,-16(a0)
 7fa:	e398                	sd	a4,0(a5)
 7fc:	a099                	j	842 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7fe:	6398                	ld	a4,0(a5)
 800:	00e7e463          	bltu	a5,a4,808 <free+0x40>
 804:	00e6ea63          	bltu	a3,a4,818 <free+0x50>
{
 808:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 80a:	fed7fae3          	bgeu	a5,a3,7fe <free+0x36>
 80e:	6398                	ld	a4,0(a5)
 810:	00e6e463          	bltu	a3,a4,818 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 814:	fee7eae3          	bltu	a5,a4,808 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 818:	ff852583          	lw	a1,-8(a0)
 81c:	6390                	ld	a2,0(a5)
 81e:	02059813          	slli	a6,a1,0x20
 822:	01c85713          	srli	a4,a6,0x1c
 826:	9736                	add	a4,a4,a3
 828:	fae60ae3          	beq	a2,a4,7dc <free+0x14>
    bp->s.ptr = p->s.ptr;
 82c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 830:	4790                	lw	a2,8(a5)
 832:	02061593          	slli	a1,a2,0x20
 836:	01c5d713          	srli	a4,a1,0x1c
 83a:	973e                	add	a4,a4,a5
 83c:	fae689e3          	beq	a3,a4,7ee <free+0x26>
  } else
    p->s.ptr = bp;
 840:	e394                	sd	a3,0(a5)
  freep = p;
 842:	00000717          	auipc	a4,0x0
 846:	16f73723          	sd	a5,366(a4) # 9b0 <freep>
}
 84a:	6422                	ld	s0,8(sp)
 84c:	0141                	addi	sp,sp,16
 84e:	8082                	ret

0000000000000850 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 850:	7139                	addi	sp,sp,-64
 852:	fc06                	sd	ra,56(sp)
 854:	f822                	sd	s0,48(sp)
 856:	f426                	sd	s1,40(sp)
 858:	f04a                	sd	s2,32(sp)
 85a:	ec4e                	sd	s3,24(sp)
 85c:	e852                	sd	s4,16(sp)
 85e:	e456                	sd	s5,8(sp)
 860:	e05a                	sd	s6,0(sp)
 862:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 864:	02051493          	slli	s1,a0,0x20
 868:	9081                	srli	s1,s1,0x20
 86a:	04bd                	addi	s1,s1,15
 86c:	8091                	srli	s1,s1,0x4
 86e:	0014899b          	addiw	s3,s1,1
 872:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 874:	00000517          	auipc	a0,0x0
 878:	13c53503          	ld	a0,316(a0) # 9b0 <freep>
 87c:	c515                	beqz	a0,8a8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 880:	4798                	lw	a4,8(a5)
 882:	02977f63          	bgeu	a4,s1,8c0 <malloc+0x70>
 886:	8a4e                	mv	s4,s3
 888:	0009871b          	sext.w	a4,s3
 88c:	6685                	lui	a3,0x1
 88e:	00d77363          	bgeu	a4,a3,894 <malloc+0x44>
 892:	6a05                	lui	s4,0x1
 894:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 898:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 89c:	00000917          	auipc	s2,0x0
 8a0:	11490913          	addi	s2,s2,276 # 9b0 <freep>
  if(p == (char*)-1)
 8a4:	5afd                	li	s5,-1
 8a6:	a895                	j	91a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8a8:	00000797          	auipc	a5,0x0
 8ac:	11078793          	addi	a5,a5,272 # 9b8 <base>
 8b0:	00000717          	auipc	a4,0x0
 8b4:	10f73023          	sd	a5,256(a4) # 9b0 <freep>
 8b8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8ba:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8be:	b7e1                	j	886 <malloc+0x36>
      if(p->s.size == nunits)
 8c0:	02e48c63          	beq	s1,a4,8f8 <malloc+0xa8>
        p->s.size -= nunits;
 8c4:	4137073b          	subw	a4,a4,s3
 8c8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ca:	02071693          	slli	a3,a4,0x20
 8ce:	01c6d713          	srli	a4,a3,0x1c
 8d2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8d4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8d8:	00000717          	auipc	a4,0x0
 8dc:	0ca73c23          	sd	a0,216(a4) # 9b0 <freep>
      return (void*)(p + 1);
 8e0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8e4:	70e2                	ld	ra,56(sp)
 8e6:	7442                	ld	s0,48(sp)
 8e8:	74a2                	ld	s1,40(sp)
 8ea:	7902                	ld	s2,32(sp)
 8ec:	69e2                	ld	s3,24(sp)
 8ee:	6a42                	ld	s4,16(sp)
 8f0:	6aa2                	ld	s5,8(sp)
 8f2:	6b02                	ld	s6,0(sp)
 8f4:	6121                	addi	sp,sp,64
 8f6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8f8:	6398                	ld	a4,0(a5)
 8fa:	e118                	sd	a4,0(a0)
 8fc:	bff1                	j	8d8 <malloc+0x88>
  hp->s.size = nu;
 8fe:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 902:	0541                	addi	a0,a0,16
 904:	00000097          	auipc	ra,0x0
 908:	ec4080e7          	jalr	-316(ra) # 7c8 <free>
  return freep;
 90c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 910:	d971                	beqz	a0,8e4 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 912:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 914:	4798                	lw	a4,8(a5)
 916:	fa9775e3          	bgeu	a4,s1,8c0 <malloc+0x70>
    if(p == freep)
 91a:	00093703          	ld	a4,0(s2)
 91e:	853e                	mv	a0,a5
 920:	fef719e3          	bne	a4,a5,912 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 924:	8552                	mv	a0,s4
 926:	00000097          	auipc	ra,0x0
 92a:	b64080e7          	jalr	-1180(ra) # 48a <sbrk>
  if(p == (char*)-1)
 92e:	fd5518e3          	bne	a0,s5,8fe <malloc+0xae>
        return 0;
 932:	4501                	li	a0,0
 934:	bf45                	j	8e4 <malloc+0x94>
