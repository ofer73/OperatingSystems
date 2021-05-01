
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  int i;

  for(i = 1; i < argc; i++){
  10:	4785                	li	a5,1
  12:	06a7d463          	bge	a5,a0,7a <main+0x7a>
  16:	00858493          	addi	s1,a1,8
  1a:	ffe5099b          	addiw	s3,a0,-2
  1e:	02099793          	slli	a5,s3,0x20
  22:	01d7d993          	srli	s3,a5,0x1d
  26:	05c1                	addi	a1,a1,16
  28:	99ae                	add	s3,s3,a1
    write(1, argv[i], strlen(argv[i]));
    if(i + 1 < argc){
      write(1, " ", 1);
  2a:	00001a17          	auipc	s4,0x1
  2e:	81ea0a13          	addi	s4,s4,-2018 # 848 <malloc+0xe8>
    write(1, argv[i], strlen(argv[i]));
  32:	0004b903          	ld	s2,0(s1)
  36:	854a                	mv	a0,s2
  38:	00000097          	auipc	ra,0x0
  3c:	094080e7          	jalr	148(ra) # cc <strlen>
  40:	0005061b          	sext.w	a2,a0
  44:	85ca                	mv	a1,s2
  46:	4505                	li	a0,1
  48:	00000097          	auipc	ra,0x0
  4c:	2ca080e7          	jalr	714(ra) # 312 <write>
    if(i + 1 < argc){
  50:	04a1                	addi	s1,s1,8
  52:	01348a63          	beq	s1,s3,66 <main+0x66>
      write(1, " ", 1);
  56:	4605                	li	a2,1
  58:	85d2                	mv	a1,s4
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	2b6080e7          	jalr	694(ra) # 312 <write>
  for(i = 1; i < argc; i++){
  64:	b7f9                	j	32 <main+0x32>
    } else {
      write(1, "\n", 1);
  66:	4605                	li	a2,1
  68:	00000597          	auipc	a1,0x0
  6c:	7e858593          	addi	a1,a1,2024 # 850 <malloc+0xf0>
  70:	4505                	li	a0,1
  72:	00000097          	auipc	ra,0x0
  76:	2a0080e7          	jalr	672(ra) # 312 <write>
    }
  }
  exit(0);
  7a:	4501                	li	a0,0
  7c:	00000097          	auipc	ra,0x0
  80:	276080e7          	jalr	630(ra) # 2f2 <exit>

0000000000000084 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  84:	1141                	addi	sp,sp,-16
  86:	e422                	sd	s0,8(sp)
  88:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  8a:	87aa                	mv	a5,a0
  8c:	0585                	addi	a1,a1,1
  8e:	0785                	addi	a5,a5,1
  90:	fff5c703          	lbu	a4,-1(a1)
  94:	fee78fa3          	sb	a4,-1(a5)
  98:	fb75                	bnez	a4,8c <strcpy+0x8>
    ;
  return os;
}
  9a:	6422                	ld	s0,8(sp)
  9c:	0141                	addi	sp,sp,16
  9e:	8082                	ret

00000000000000a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e422                	sd	s0,8(sp)
  a4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a6:	00054783          	lbu	a5,0(a0)
  aa:	cb91                	beqz	a5,be <strcmp+0x1e>
  ac:	0005c703          	lbu	a4,0(a1)
  b0:	00f71763          	bne	a4,a5,be <strcmp+0x1e>
    p++, q++;
  b4:	0505                	addi	a0,a0,1
  b6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b8:	00054783          	lbu	a5,0(a0)
  bc:	fbe5                	bnez	a5,ac <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  be:	0005c503          	lbu	a0,0(a1)
}
  c2:	40a7853b          	subw	a0,a5,a0
  c6:	6422                	ld	s0,8(sp)
  c8:	0141                	addi	sp,sp,16
  ca:	8082                	ret

00000000000000cc <strlen>:

uint
strlen(const char *s)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e422                	sd	s0,8(sp)
  d0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  d2:	00054783          	lbu	a5,0(a0)
  d6:	cf91                	beqz	a5,f2 <strlen+0x26>
  d8:	0505                	addi	a0,a0,1
  da:	87aa                	mv	a5,a0
  dc:	4685                	li	a3,1
  de:	9e89                	subw	a3,a3,a0
  e0:	00f6853b          	addw	a0,a3,a5
  e4:	0785                	addi	a5,a5,1
  e6:	fff7c703          	lbu	a4,-1(a5)
  ea:	fb7d                	bnez	a4,e0 <strlen+0x14>
    ;
  return n;
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret
  for(n = 0; s[n]; n++)
  f2:	4501                	li	a0,0
  f4:	bfe5                	j	ec <strlen+0x20>

00000000000000f6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e422                	sd	s0,8(sp)
  fa:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  fc:	ca19                	beqz	a2,112 <memset+0x1c>
  fe:	87aa                	mv	a5,a0
 100:	1602                	slli	a2,a2,0x20
 102:	9201                	srli	a2,a2,0x20
 104:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 108:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 10c:	0785                	addi	a5,a5,1
 10e:	fee79de3          	bne	a5,a4,108 <memset+0x12>
  }
  return dst;
}
 112:	6422                	ld	s0,8(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret

0000000000000118 <strchr>:

char*
strchr(const char *s, char c)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e422                	sd	s0,8(sp)
 11c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 11e:	00054783          	lbu	a5,0(a0)
 122:	cb99                	beqz	a5,138 <strchr+0x20>
    if(*s == c)
 124:	00f58763          	beq	a1,a5,132 <strchr+0x1a>
  for(; *s; s++)
 128:	0505                	addi	a0,a0,1
 12a:	00054783          	lbu	a5,0(a0)
 12e:	fbfd                	bnez	a5,124 <strchr+0xc>
      return (char*)s;
  return 0;
 130:	4501                	li	a0,0
}
 132:	6422                	ld	s0,8(sp)
 134:	0141                	addi	sp,sp,16
 136:	8082                	ret
  return 0;
 138:	4501                	li	a0,0
 13a:	bfe5                	j	132 <strchr+0x1a>

000000000000013c <gets>:

char*
gets(char *buf, int max)
{
 13c:	711d                	addi	sp,sp,-96
 13e:	ec86                	sd	ra,88(sp)
 140:	e8a2                	sd	s0,80(sp)
 142:	e4a6                	sd	s1,72(sp)
 144:	e0ca                	sd	s2,64(sp)
 146:	fc4e                	sd	s3,56(sp)
 148:	f852                	sd	s4,48(sp)
 14a:	f456                	sd	s5,40(sp)
 14c:	f05a                	sd	s6,32(sp)
 14e:	ec5e                	sd	s7,24(sp)
 150:	1080                	addi	s0,sp,96
 152:	8baa                	mv	s7,a0
 154:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 156:	892a                	mv	s2,a0
 158:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 15a:	4aa9                	li	s5,10
 15c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 15e:	89a6                	mv	s3,s1
 160:	2485                	addiw	s1,s1,1
 162:	0344d863          	bge	s1,s4,192 <gets+0x56>
    cc = read(0, &c, 1);
 166:	4605                	li	a2,1
 168:	faf40593          	addi	a1,s0,-81
 16c:	4501                	li	a0,0
 16e:	00000097          	auipc	ra,0x0
 172:	19c080e7          	jalr	412(ra) # 30a <read>
    if(cc < 1)
 176:	00a05e63          	blez	a0,192 <gets+0x56>
    buf[i++] = c;
 17a:	faf44783          	lbu	a5,-81(s0)
 17e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 182:	01578763          	beq	a5,s5,190 <gets+0x54>
 186:	0905                	addi	s2,s2,1
 188:	fd679be3          	bne	a5,s6,15e <gets+0x22>
  for(i=0; i+1 < max; ){
 18c:	89a6                	mv	s3,s1
 18e:	a011                	j	192 <gets+0x56>
 190:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 192:	99de                	add	s3,s3,s7
 194:	00098023          	sb	zero,0(s3)
  return buf;
}
 198:	855e                	mv	a0,s7
 19a:	60e6                	ld	ra,88(sp)
 19c:	6446                	ld	s0,80(sp)
 19e:	64a6                	ld	s1,72(sp)
 1a0:	6906                	ld	s2,64(sp)
 1a2:	79e2                	ld	s3,56(sp)
 1a4:	7a42                	ld	s4,48(sp)
 1a6:	7aa2                	ld	s5,40(sp)
 1a8:	7b02                	ld	s6,32(sp)
 1aa:	6be2                	ld	s7,24(sp)
 1ac:	6125                	addi	sp,sp,96
 1ae:	8082                	ret

00000000000001b0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1b0:	1101                	addi	sp,sp,-32
 1b2:	ec06                	sd	ra,24(sp)
 1b4:	e822                	sd	s0,16(sp)
 1b6:	e426                	sd	s1,8(sp)
 1b8:	e04a                	sd	s2,0(sp)
 1ba:	1000                	addi	s0,sp,32
 1bc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1be:	4581                	li	a1,0
 1c0:	00000097          	auipc	ra,0x0
 1c4:	172080e7          	jalr	370(ra) # 332 <open>
  if(fd < 0)
 1c8:	02054563          	bltz	a0,1f2 <stat+0x42>
 1cc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ce:	85ca                	mv	a1,s2
 1d0:	00000097          	auipc	ra,0x0
 1d4:	17a080e7          	jalr	378(ra) # 34a <fstat>
 1d8:	892a                	mv	s2,a0
  close(fd);
 1da:	8526                	mv	a0,s1
 1dc:	00000097          	auipc	ra,0x0
 1e0:	13e080e7          	jalr	318(ra) # 31a <close>
  return r;
}
 1e4:	854a                	mv	a0,s2
 1e6:	60e2                	ld	ra,24(sp)
 1e8:	6442                	ld	s0,16(sp)
 1ea:	64a2                	ld	s1,8(sp)
 1ec:	6902                	ld	s2,0(sp)
 1ee:	6105                	addi	sp,sp,32
 1f0:	8082                	ret
    return -1;
 1f2:	597d                	li	s2,-1
 1f4:	bfc5                	j	1e4 <stat+0x34>

00000000000001f6 <atoi>:

int
atoi(const char *s)
{
 1f6:	1141                	addi	sp,sp,-16
 1f8:	e422                	sd	s0,8(sp)
 1fa:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1fc:	00054603          	lbu	a2,0(a0)
 200:	fd06079b          	addiw	a5,a2,-48
 204:	0ff7f793          	andi	a5,a5,255
 208:	4725                	li	a4,9
 20a:	02f76963          	bltu	a4,a5,23c <atoi+0x46>
 20e:	86aa                	mv	a3,a0
  n = 0;
 210:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 212:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 214:	0685                	addi	a3,a3,1
 216:	0025179b          	slliw	a5,a0,0x2
 21a:	9fa9                	addw	a5,a5,a0
 21c:	0017979b          	slliw	a5,a5,0x1
 220:	9fb1                	addw	a5,a5,a2
 222:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 226:	0006c603          	lbu	a2,0(a3)
 22a:	fd06071b          	addiw	a4,a2,-48
 22e:	0ff77713          	andi	a4,a4,255
 232:	fee5f1e3          	bgeu	a1,a4,214 <atoi+0x1e>
  return n;
}
 236:	6422                	ld	s0,8(sp)
 238:	0141                	addi	sp,sp,16
 23a:	8082                	ret
  n = 0;
 23c:	4501                	li	a0,0
 23e:	bfe5                	j	236 <atoi+0x40>

0000000000000240 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 240:	1141                	addi	sp,sp,-16
 242:	e422                	sd	s0,8(sp)
 244:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 246:	02b57463          	bgeu	a0,a1,26e <memmove+0x2e>
    while(n-- > 0)
 24a:	00c05f63          	blez	a2,268 <memmove+0x28>
 24e:	1602                	slli	a2,a2,0x20
 250:	9201                	srli	a2,a2,0x20
 252:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 256:	872a                	mv	a4,a0
      *dst++ = *src++;
 258:	0585                	addi	a1,a1,1
 25a:	0705                	addi	a4,a4,1
 25c:	fff5c683          	lbu	a3,-1(a1)
 260:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 264:	fee79ae3          	bne	a5,a4,258 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 268:	6422                	ld	s0,8(sp)
 26a:	0141                	addi	sp,sp,16
 26c:	8082                	ret
    dst += n;
 26e:	00c50733          	add	a4,a0,a2
    src += n;
 272:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 274:	fec05ae3          	blez	a2,268 <memmove+0x28>
 278:	fff6079b          	addiw	a5,a2,-1
 27c:	1782                	slli	a5,a5,0x20
 27e:	9381                	srli	a5,a5,0x20
 280:	fff7c793          	not	a5,a5
 284:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 286:	15fd                	addi	a1,a1,-1
 288:	177d                	addi	a4,a4,-1
 28a:	0005c683          	lbu	a3,0(a1)
 28e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 292:	fee79ae3          	bne	a5,a4,286 <memmove+0x46>
 296:	bfc9                	j	268 <memmove+0x28>

0000000000000298 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 29e:	ca05                	beqz	a2,2ce <memcmp+0x36>
 2a0:	fff6069b          	addiw	a3,a2,-1
 2a4:	1682                	slli	a3,a3,0x20
 2a6:	9281                	srli	a3,a3,0x20
 2a8:	0685                	addi	a3,a3,1
 2aa:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ac:	00054783          	lbu	a5,0(a0)
 2b0:	0005c703          	lbu	a4,0(a1)
 2b4:	00e79863          	bne	a5,a4,2c4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2b8:	0505                	addi	a0,a0,1
    p2++;
 2ba:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2bc:	fed518e3          	bne	a0,a3,2ac <memcmp+0x14>
  }
  return 0;
 2c0:	4501                	li	a0,0
 2c2:	a019                	j	2c8 <memcmp+0x30>
      return *p1 - *p2;
 2c4:	40e7853b          	subw	a0,a5,a4
}
 2c8:	6422                	ld	s0,8(sp)
 2ca:	0141                	addi	sp,sp,16
 2cc:	8082                	ret
  return 0;
 2ce:	4501                	li	a0,0
 2d0:	bfe5                	j	2c8 <memcmp+0x30>

00000000000002d2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e406                	sd	ra,8(sp)
 2d6:	e022                	sd	s0,0(sp)
 2d8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2da:	00000097          	auipc	ra,0x0
 2de:	f66080e7          	jalr	-154(ra) # 240 <memmove>
}
 2e2:	60a2                	ld	ra,8(sp)
 2e4:	6402                	ld	s0,0(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret

00000000000002ea <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ea:	4885                	li	a7,1
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2f2:	4889                	li	a7,2
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <wait>:
.global wait
wait:
 li a7, SYS_wait
 2fa:	488d                	li	a7,3
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 302:	4891                	li	a7,4
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <read>:
.global read
read:
 li a7, SYS_read
 30a:	4895                	li	a7,5
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <write>:
.global write
write:
 li a7, SYS_write
 312:	48c1                	li	a7,16
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <close>:
.global close
close:
 li a7, SYS_close
 31a:	48d5                	li	a7,21
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <kill>:
.global kill
kill:
 li a7, SYS_kill
 322:	4899                	li	a7,6
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <exec>:
.global exec
exec:
 li a7, SYS_exec
 32a:	489d                	li	a7,7
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <open>:
.global open
open:
 li a7, SYS_open
 332:	48bd                	li	a7,15
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 33a:	48c5                	li	a7,17
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 342:	48c9                	li	a7,18
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 34a:	48a1                	li	a7,8
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <link>:
.global link
link:
 li a7, SYS_link
 352:	48cd                	li	a7,19
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 35a:	48d1                	li	a7,20
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 362:	48a5                	li	a7,9
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <dup>:
.global dup
dup:
 li a7, SYS_dup
 36a:	48a9                	li	a7,10
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 372:	48ad                	li	a7,11
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 37a:	48b1                	li	a7,12
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 382:	48b5                	li	a7,13
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 38a:	48b9                	li	a7,14
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
 392:	48d9                	li	a7,22
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
 39a:	48dd                	li	a7,23
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
 3a2:	48e1                	li	a7,24
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
 3aa:	48e5                	li	a7,25
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
 3b2:	48e9                	li	a7,26
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
 3ba:	48ed                	li	a7,27
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
 3c2:	48f1                	li	a7,28
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ca:	1101                	addi	sp,sp,-32
 3cc:	ec06                	sd	ra,24(sp)
 3ce:	e822                	sd	s0,16(sp)
 3d0:	1000                	addi	s0,sp,32
 3d2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3d6:	4605                	li	a2,1
 3d8:	fef40593          	addi	a1,s0,-17
 3dc:	00000097          	auipc	ra,0x0
 3e0:	f36080e7          	jalr	-202(ra) # 312 <write>
}
 3e4:	60e2                	ld	ra,24(sp)
 3e6:	6442                	ld	s0,16(sp)
 3e8:	6105                	addi	sp,sp,32
 3ea:	8082                	ret

00000000000003ec <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3ec:	7139                	addi	sp,sp,-64
 3ee:	fc06                	sd	ra,56(sp)
 3f0:	f822                	sd	s0,48(sp)
 3f2:	f426                	sd	s1,40(sp)
 3f4:	f04a                	sd	s2,32(sp)
 3f6:	ec4e                	sd	s3,24(sp)
 3f8:	0080                	addi	s0,sp,64
 3fa:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3fc:	c299                	beqz	a3,402 <printint+0x16>
 3fe:	0805c863          	bltz	a1,48e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 402:	2581                	sext.w	a1,a1
  neg = 0;
 404:	4881                	li	a7,0
 406:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 40a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 40c:	2601                	sext.w	a2,a2
 40e:	00000517          	auipc	a0,0x0
 412:	45250513          	addi	a0,a0,1106 # 860 <digits>
 416:	883a                	mv	a6,a4
 418:	2705                	addiw	a4,a4,1
 41a:	02c5f7bb          	remuw	a5,a1,a2
 41e:	1782                	slli	a5,a5,0x20
 420:	9381                	srli	a5,a5,0x20
 422:	97aa                	add	a5,a5,a0
 424:	0007c783          	lbu	a5,0(a5)
 428:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 42c:	0005879b          	sext.w	a5,a1
 430:	02c5d5bb          	divuw	a1,a1,a2
 434:	0685                	addi	a3,a3,1
 436:	fec7f0e3          	bgeu	a5,a2,416 <printint+0x2a>
  if(neg)
 43a:	00088b63          	beqz	a7,450 <printint+0x64>
    buf[i++] = '-';
 43e:	fd040793          	addi	a5,s0,-48
 442:	973e                	add	a4,a4,a5
 444:	02d00793          	li	a5,45
 448:	fef70823          	sb	a5,-16(a4)
 44c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 450:	02e05863          	blez	a4,480 <printint+0x94>
 454:	fc040793          	addi	a5,s0,-64
 458:	00e78933          	add	s2,a5,a4
 45c:	fff78993          	addi	s3,a5,-1
 460:	99ba                	add	s3,s3,a4
 462:	377d                	addiw	a4,a4,-1
 464:	1702                	slli	a4,a4,0x20
 466:	9301                	srli	a4,a4,0x20
 468:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 46c:	fff94583          	lbu	a1,-1(s2)
 470:	8526                	mv	a0,s1
 472:	00000097          	auipc	ra,0x0
 476:	f58080e7          	jalr	-168(ra) # 3ca <putc>
  while(--i >= 0)
 47a:	197d                	addi	s2,s2,-1
 47c:	ff3918e3          	bne	s2,s3,46c <printint+0x80>
}
 480:	70e2                	ld	ra,56(sp)
 482:	7442                	ld	s0,48(sp)
 484:	74a2                	ld	s1,40(sp)
 486:	7902                	ld	s2,32(sp)
 488:	69e2                	ld	s3,24(sp)
 48a:	6121                	addi	sp,sp,64
 48c:	8082                	ret
    x = -xx;
 48e:	40b005bb          	negw	a1,a1
    neg = 1;
 492:	4885                	li	a7,1
    x = -xx;
 494:	bf8d                	j	406 <printint+0x1a>

0000000000000496 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 496:	7119                	addi	sp,sp,-128
 498:	fc86                	sd	ra,120(sp)
 49a:	f8a2                	sd	s0,112(sp)
 49c:	f4a6                	sd	s1,104(sp)
 49e:	f0ca                	sd	s2,96(sp)
 4a0:	ecce                	sd	s3,88(sp)
 4a2:	e8d2                	sd	s4,80(sp)
 4a4:	e4d6                	sd	s5,72(sp)
 4a6:	e0da                	sd	s6,64(sp)
 4a8:	fc5e                	sd	s7,56(sp)
 4aa:	f862                	sd	s8,48(sp)
 4ac:	f466                	sd	s9,40(sp)
 4ae:	f06a                	sd	s10,32(sp)
 4b0:	ec6e                	sd	s11,24(sp)
 4b2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4b4:	0005c903          	lbu	s2,0(a1)
 4b8:	18090f63          	beqz	s2,656 <vprintf+0x1c0>
 4bc:	8aaa                	mv	s5,a0
 4be:	8b32                	mv	s6,a2
 4c0:	00158493          	addi	s1,a1,1
  state = 0;
 4c4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4c6:	02500a13          	li	s4,37
      if(c == 'd'){
 4ca:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4ce:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4d2:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4d6:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4da:	00000b97          	auipc	s7,0x0
 4de:	386b8b93          	addi	s7,s7,902 # 860 <digits>
 4e2:	a839                	j	500 <vprintf+0x6a>
        putc(fd, c);
 4e4:	85ca                	mv	a1,s2
 4e6:	8556                	mv	a0,s5
 4e8:	00000097          	auipc	ra,0x0
 4ec:	ee2080e7          	jalr	-286(ra) # 3ca <putc>
 4f0:	a019                	j	4f6 <vprintf+0x60>
    } else if(state == '%'){
 4f2:	01498f63          	beq	s3,s4,510 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4f6:	0485                	addi	s1,s1,1
 4f8:	fff4c903          	lbu	s2,-1(s1)
 4fc:	14090d63          	beqz	s2,656 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 500:	0009079b          	sext.w	a5,s2
    if(state == 0){
 504:	fe0997e3          	bnez	s3,4f2 <vprintf+0x5c>
      if(c == '%'){
 508:	fd479ee3          	bne	a5,s4,4e4 <vprintf+0x4e>
        state = '%';
 50c:	89be                	mv	s3,a5
 50e:	b7e5                	j	4f6 <vprintf+0x60>
      if(c == 'd'){
 510:	05878063          	beq	a5,s8,550 <vprintf+0xba>
      } else if(c == 'l') {
 514:	05978c63          	beq	a5,s9,56c <vprintf+0xd6>
      } else if(c == 'x') {
 518:	07a78863          	beq	a5,s10,588 <vprintf+0xf2>
      } else if(c == 'p') {
 51c:	09b78463          	beq	a5,s11,5a4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 520:	07300713          	li	a4,115
 524:	0ce78663          	beq	a5,a4,5f0 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 528:	06300713          	li	a4,99
 52c:	0ee78e63          	beq	a5,a4,628 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 530:	11478863          	beq	a5,s4,640 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 534:	85d2                	mv	a1,s4
 536:	8556                	mv	a0,s5
 538:	00000097          	auipc	ra,0x0
 53c:	e92080e7          	jalr	-366(ra) # 3ca <putc>
        putc(fd, c);
 540:	85ca                	mv	a1,s2
 542:	8556                	mv	a0,s5
 544:	00000097          	auipc	ra,0x0
 548:	e86080e7          	jalr	-378(ra) # 3ca <putc>
      }
      state = 0;
 54c:	4981                	li	s3,0
 54e:	b765                	j	4f6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 550:	008b0913          	addi	s2,s6,8
 554:	4685                	li	a3,1
 556:	4629                	li	a2,10
 558:	000b2583          	lw	a1,0(s6)
 55c:	8556                	mv	a0,s5
 55e:	00000097          	auipc	ra,0x0
 562:	e8e080e7          	jalr	-370(ra) # 3ec <printint>
 566:	8b4a                	mv	s6,s2
      state = 0;
 568:	4981                	li	s3,0
 56a:	b771                	j	4f6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 56c:	008b0913          	addi	s2,s6,8
 570:	4681                	li	a3,0
 572:	4629                	li	a2,10
 574:	000b2583          	lw	a1,0(s6)
 578:	8556                	mv	a0,s5
 57a:	00000097          	auipc	ra,0x0
 57e:	e72080e7          	jalr	-398(ra) # 3ec <printint>
 582:	8b4a                	mv	s6,s2
      state = 0;
 584:	4981                	li	s3,0
 586:	bf85                	j	4f6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 588:	008b0913          	addi	s2,s6,8
 58c:	4681                	li	a3,0
 58e:	4641                	li	a2,16
 590:	000b2583          	lw	a1,0(s6)
 594:	8556                	mv	a0,s5
 596:	00000097          	auipc	ra,0x0
 59a:	e56080e7          	jalr	-426(ra) # 3ec <printint>
 59e:	8b4a                	mv	s6,s2
      state = 0;
 5a0:	4981                	li	s3,0
 5a2:	bf91                	j	4f6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5a4:	008b0793          	addi	a5,s6,8
 5a8:	f8f43423          	sd	a5,-120(s0)
 5ac:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 5b0:	03000593          	li	a1,48
 5b4:	8556                	mv	a0,s5
 5b6:	00000097          	auipc	ra,0x0
 5ba:	e14080e7          	jalr	-492(ra) # 3ca <putc>
  putc(fd, 'x');
 5be:	85ea                	mv	a1,s10
 5c0:	8556                	mv	a0,s5
 5c2:	00000097          	auipc	ra,0x0
 5c6:	e08080e7          	jalr	-504(ra) # 3ca <putc>
 5ca:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5cc:	03c9d793          	srli	a5,s3,0x3c
 5d0:	97de                	add	a5,a5,s7
 5d2:	0007c583          	lbu	a1,0(a5)
 5d6:	8556                	mv	a0,s5
 5d8:	00000097          	auipc	ra,0x0
 5dc:	df2080e7          	jalr	-526(ra) # 3ca <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5e0:	0992                	slli	s3,s3,0x4
 5e2:	397d                	addiw	s2,s2,-1
 5e4:	fe0914e3          	bnez	s2,5cc <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5e8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	b721                	j	4f6 <vprintf+0x60>
        s = va_arg(ap, char*);
 5f0:	008b0993          	addi	s3,s6,8
 5f4:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5f8:	02090163          	beqz	s2,61a <vprintf+0x184>
        while(*s != 0){
 5fc:	00094583          	lbu	a1,0(s2)
 600:	c9a1                	beqz	a1,650 <vprintf+0x1ba>
          putc(fd, *s);
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	dc6080e7          	jalr	-570(ra) # 3ca <putc>
          s++;
 60c:	0905                	addi	s2,s2,1
        while(*s != 0){
 60e:	00094583          	lbu	a1,0(s2)
 612:	f9e5                	bnez	a1,602 <vprintf+0x16c>
        s = va_arg(ap, char*);
 614:	8b4e                	mv	s6,s3
      state = 0;
 616:	4981                	li	s3,0
 618:	bdf9                	j	4f6 <vprintf+0x60>
          s = "(null)";
 61a:	00000917          	auipc	s2,0x0
 61e:	23e90913          	addi	s2,s2,574 # 858 <malloc+0xf8>
        while(*s != 0){
 622:	02800593          	li	a1,40
 626:	bff1                	j	602 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 628:	008b0913          	addi	s2,s6,8
 62c:	000b4583          	lbu	a1,0(s6)
 630:	8556                	mv	a0,s5
 632:	00000097          	auipc	ra,0x0
 636:	d98080e7          	jalr	-616(ra) # 3ca <putc>
 63a:	8b4a                	mv	s6,s2
      state = 0;
 63c:	4981                	li	s3,0
 63e:	bd65                	j	4f6 <vprintf+0x60>
        putc(fd, c);
 640:	85d2                	mv	a1,s4
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	d86080e7          	jalr	-634(ra) # 3ca <putc>
      state = 0;
 64c:	4981                	li	s3,0
 64e:	b565                	j	4f6 <vprintf+0x60>
        s = va_arg(ap, char*);
 650:	8b4e                	mv	s6,s3
      state = 0;
 652:	4981                	li	s3,0
 654:	b54d                	j	4f6 <vprintf+0x60>
    }
  }
}
 656:	70e6                	ld	ra,120(sp)
 658:	7446                	ld	s0,112(sp)
 65a:	74a6                	ld	s1,104(sp)
 65c:	7906                	ld	s2,96(sp)
 65e:	69e6                	ld	s3,88(sp)
 660:	6a46                	ld	s4,80(sp)
 662:	6aa6                	ld	s5,72(sp)
 664:	6b06                	ld	s6,64(sp)
 666:	7be2                	ld	s7,56(sp)
 668:	7c42                	ld	s8,48(sp)
 66a:	7ca2                	ld	s9,40(sp)
 66c:	7d02                	ld	s10,32(sp)
 66e:	6de2                	ld	s11,24(sp)
 670:	6109                	addi	sp,sp,128
 672:	8082                	ret

0000000000000674 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 674:	715d                	addi	sp,sp,-80
 676:	ec06                	sd	ra,24(sp)
 678:	e822                	sd	s0,16(sp)
 67a:	1000                	addi	s0,sp,32
 67c:	e010                	sd	a2,0(s0)
 67e:	e414                	sd	a3,8(s0)
 680:	e818                	sd	a4,16(s0)
 682:	ec1c                	sd	a5,24(s0)
 684:	03043023          	sd	a6,32(s0)
 688:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 68c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 690:	8622                	mv	a2,s0
 692:	00000097          	auipc	ra,0x0
 696:	e04080e7          	jalr	-508(ra) # 496 <vprintf>
}
 69a:	60e2                	ld	ra,24(sp)
 69c:	6442                	ld	s0,16(sp)
 69e:	6161                	addi	sp,sp,80
 6a0:	8082                	ret

00000000000006a2 <printf>:

void
printf(const char *fmt, ...)
{
 6a2:	711d                	addi	sp,sp,-96
 6a4:	ec06                	sd	ra,24(sp)
 6a6:	e822                	sd	s0,16(sp)
 6a8:	1000                	addi	s0,sp,32
 6aa:	e40c                	sd	a1,8(s0)
 6ac:	e810                	sd	a2,16(s0)
 6ae:	ec14                	sd	a3,24(s0)
 6b0:	f018                	sd	a4,32(s0)
 6b2:	f41c                	sd	a5,40(s0)
 6b4:	03043823          	sd	a6,48(s0)
 6b8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6bc:	00840613          	addi	a2,s0,8
 6c0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6c4:	85aa                	mv	a1,a0
 6c6:	4505                	li	a0,1
 6c8:	00000097          	auipc	ra,0x0
 6cc:	dce080e7          	jalr	-562(ra) # 496 <vprintf>
}
 6d0:	60e2                	ld	ra,24(sp)
 6d2:	6442                	ld	s0,16(sp)
 6d4:	6125                	addi	sp,sp,96
 6d6:	8082                	ret

00000000000006d8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6d8:	1141                	addi	sp,sp,-16
 6da:	e422                	sd	s0,8(sp)
 6dc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6de:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e2:	00000797          	auipc	a5,0x0
 6e6:	1967b783          	ld	a5,406(a5) # 878 <freep>
 6ea:	a805                	j	71a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6ec:	4618                	lw	a4,8(a2)
 6ee:	9db9                	addw	a1,a1,a4
 6f0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6f4:	6398                	ld	a4,0(a5)
 6f6:	6318                	ld	a4,0(a4)
 6f8:	fee53823          	sd	a4,-16(a0)
 6fc:	a091                	j	740 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6fe:	ff852703          	lw	a4,-8(a0)
 702:	9e39                	addw	a2,a2,a4
 704:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 706:	ff053703          	ld	a4,-16(a0)
 70a:	e398                	sd	a4,0(a5)
 70c:	a099                	j	752 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 70e:	6398                	ld	a4,0(a5)
 710:	00e7e463          	bltu	a5,a4,718 <free+0x40>
 714:	00e6ea63          	bltu	a3,a4,728 <free+0x50>
{
 718:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 71a:	fed7fae3          	bgeu	a5,a3,70e <free+0x36>
 71e:	6398                	ld	a4,0(a5)
 720:	00e6e463          	bltu	a3,a4,728 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 724:	fee7eae3          	bltu	a5,a4,718 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 728:	ff852583          	lw	a1,-8(a0)
 72c:	6390                	ld	a2,0(a5)
 72e:	02059813          	slli	a6,a1,0x20
 732:	01c85713          	srli	a4,a6,0x1c
 736:	9736                	add	a4,a4,a3
 738:	fae60ae3          	beq	a2,a4,6ec <free+0x14>
    bp->s.ptr = p->s.ptr;
 73c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 740:	4790                	lw	a2,8(a5)
 742:	02061593          	slli	a1,a2,0x20
 746:	01c5d713          	srli	a4,a1,0x1c
 74a:	973e                	add	a4,a4,a5
 74c:	fae689e3          	beq	a3,a4,6fe <free+0x26>
  } else
    p->s.ptr = bp;
 750:	e394                	sd	a3,0(a5)
  freep = p;
 752:	00000717          	auipc	a4,0x0
 756:	12f73323          	sd	a5,294(a4) # 878 <freep>
}
 75a:	6422                	ld	s0,8(sp)
 75c:	0141                	addi	sp,sp,16
 75e:	8082                	ret

0000000000000760 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 760:	7139                	addi	sp,sp,-64
 762:	fc06                	sd	ra,56(sp)
 764:	f822                	sd	s0,48(sp)
 766:	f426                	sd	s1,40(sp)
 768:	f04a                	sd	s2,32(sp)
 76a:	ec4e                	sd	s3,24(sp)
 76c:	e852                	sd	s4,16(sp)
 76e:	e456                	sd	s5,8(sp)
 770:	e05a                	sd	s6,0(sp)
 772:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 774:	02051493          	slli	s1,a0,0x20
 778:	9081                	srli	s1,s1,0x20
 77a:	04bd                	addi	s1,s1,15
 77c:	8091                	srli	s1,s1,0x4
 77e:	0014899b          	addiw	s3,s1,1
 782:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 784:	00000517          	auipc	a0,0x0
 788:	0f453503          	ld	a0,244(a0) # 878 <freep>
 78c:	c515                	beqz	a0,7b8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 78e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 790:	4798                	lw	a4,8(a5)
 792:	02977f63          	bgeu	a4,s1,7d0 <malloc+0x70>
 796:	8a4e                	mv	s4,s3
 798:	0009871b          	sext.w	a4,s3
 79c:	6685                	lui	a3,0x1
 79e:	00d77363          	bgeu	a4,a3,7a4 <malloc+0x44>
 7a2:	6a05                	lui	s4,0x1
 7a4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7a8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7ac:	00000917          	auipc	s2,0x0
 7b0:	0cc90913          	addi	s2,s2,204 # 878 <freep>
  if(p == (char*)-1)
 7b4:	5afd                	li	s5,-1
 7b6:	a895                	j	82a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7b8:	00000797          	auipc	a5,0x0
 7bc:	0c878793          	addi	a5,a5,200 # 880 <base>
 7c0:	00000717          	auipc	a4,0x0
 7c4:	0af73c23          	sd	a5,184(a4) # 878 <freep>
 7c8:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7ca:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7ce:	b7e1                	j	796 <malloc+0x36>
      if(p->s.size == nunits)
 7d0:	02e48c63          	beq	s1,a4,808 <malloc+0xa8>
        p->s.size -= nunits;
 7d4:	4137073b          	subw	a4,a4,s3
 7d8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7da:	02071693          	slli	a3,a4,0x20
 7de:	01c6d713          	srli	a4,a3,0x1c
 7e2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7e4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7e8:	00000717          	auipc	a4,0x0
 7ec:	08a73823          	sd	a0,144(a4) # 878 <freep>
      return (void*)(p + 1);
 7f0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7f4:	70e2                	ld	ra,56(sp)
 7f6:	7442                	ld	s0,48(sp)
 7f8:	74a2                	ld	s1,40(sp)
 7fa:	7902                	ld	s2,32(sp)
 7fc:	69e2                	ld	s3,24(sp)
 7fe:	6a42                	ld	s4,16(sp)
 800:	6aa2                	ld	s5,8(sp)
 802:	6b02                	ld	s6,0(sp)
 804:	6121                	addi	sp,sp,64
 806:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 808:	6398                	ld	a4,0(a5)
 80a:	e118                	sd	a4,0(a0)
 80c:	bff1                	j	7e8 <malloc+0x88>
  hp->s.size = nu;
 80e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 812:	0541                	addi	a0,a0,16
 814:	00000097          	auipc	ra,0x0
 818:	ec4080e7          	jalr	-316(ra) # 6d8 <free>
  return freep;
 81c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 820:	d971                	beqz	a0,7f4 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 822:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 824:	4798                	lw	a4,8(a5)
 826:	fa9775e3          	bgeu	a4,s1,7d0 <malloc+0x70>
    if(p == freep)
 82a:	00093703          	ld	a4,0(s2)
 82e:	853e                	mv	a0,a5
 830:	fef719e3          	bne	a4,a5,822 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 834:	8552                	mv	a0,s4
 836:	00000097          	auipc	ra,0x0
 83a:	b44080e7          	jalr	-1212(ra) # 37a <sbrk>
  if(p == (char*)-1)
 83e:	fd5518e3          	bne	a0,s5,80e <malloc+0xae>
        return 0;
 842:	4501                	li	a0,0
 844:	bf45                	j	7f4 <malloc+0x94>
