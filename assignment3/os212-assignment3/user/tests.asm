
user/_tests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <sbark_and_fork>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define PGSIZE 4096
int sbark_and_fork(){
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
    for (int i = 0; i < 22; i++)
   e:	4481                	li	s1,0
    {
        printf("sbrk %d\n",i);
  10:	00001997          	auipc	s3,0x1
  14:	ef898993          	addi	s3,s3,-264 # f08 <malloc+0xe8>
    for (int i = 0; i < 22; i++)
  18:	4959                	li	s2,22
        printf("sbrk %d\n",i);
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	00001097          	auipc	ra,0x1
  22:	d44080e7          	jalr	-700(ra) # d62 <printf>
        sbrk(4096);
  26:	6505                	lui	a0,0x1
  28:	00001097          	auipc	ra,0x1
  2c:	a4a080e7          	jalr	-1462(ra) # a72 <sbrk>
    for (int i = 0; i < 22; i++)
  30:	2485                	addiw	s1,s1,1
  32:	ff2494e3          	bne	s1,s2,1a <sbark_and_fork+0x1a>
    }
    // notice 6 pages swaped out
    int pid= fork();
  36:	00001097          	auipc	ra,0x1
  3a:	9ac080e7          	jalr	-1620(ra) # 9e2 <fork>
    if (pid == 0)
  3e:	c515                	beqz	a0,6a <sbark_and_fork+0x6a>
        printf("child sbrk\n");
        sbrk(4096 * 4);
        sleep(5);
        exit(0);
    }
    wait(0);
  40:	4501                	li	a0,0
  42:	00001097          	auipc	ra,0x1
  46:	9b0080e7          	jalr	-1616(ra) # 9f2 <wait>
    printf("test: finished test\n");
  4a:	00001517          	auipc	a0,0x1
  4e:	eee50513          	addi	a0,a0,-274 # f38 <malloc+0x118>
  52:	00001097          	auipc	ra,0x1
  56:	d10080e7          	jalr	-752(ra) # d62 <printf>
    return 0;
}
  5a:	4501                	li	a0,0
  5c:	70a2                	ld	ra,40(sp)
  5e:	7402                	ld	s0,32(sp)
  60:	64e2                	ld	s1,24(sp)
  62:	6942                	ld	s2,16(sp)
  64:	69a2                	ld	s3,8(sp)
  66:	6145                	addi	sp,sp,48
  68:	8082                	ret
        printf("child sbrk\n");
  6a:	00001517          	auipc	a0,0x1
  6e:	eae50513          	addi	a0,a0,-338 # f18 <malloc+0xf8>
  72:	00001097          	auipc	ra,0x1
  76:	cf0080e7          	jalr	-784(ra) # d62 <printf>
        sbrk(4096);
  7a:	6505                	lui	a0,0x1
  7c:	00001097          	auipc	ra,0x1
  80:	9f6080e7          	jalr	-1546(ra) # a72 <sbrk>
        printf("child sbrk neg\n");
  84:	00001517          	auipc	a0,0x1
  88:	ea450513          	addi	a0,a0,-348 # f28 <malloc+0x108>
  8c:	00001097          	auipc	ra,0x1
  90:	cd6080e7          	jalr	-810(ra) # d62 <printf>
        sbrk(-4096 * 14);
  94:	7549                	lui	a0,0xffff2
  96:	00001097          	auipc	ra,0x1
  9a:	9dc080e7          	jalr	-1572(ra) # a72 <sbrk>
        printf("child sbrk\n");
  9e:	00001517          	auipc	a0,0x1
  a2:	e7a50513          	addi	a0,a0,-390 # f18 <malloc+0xf8>
  a6:	00001097          	auipc	ra,0x1
  aa:	cbc080e7          	jalr	-836(ra) # d62 <printf>
        sbrk(4096 * 4);
  ae:	6511                	lui	a0,0x4
  b0:	00001097          	auipc	ra,0x1
  b4:	9c2080e7          	jalr	-1598(ra) # a72 <sbrk>
        sleep(5);
  b8:	4515                	li	a0,5
  ba:	00001097          	auipc	ra,0x1
  be:	9c0080e7          	jalr	-1600(ra) # a7a <sleep>
        exit(0);
  c2:	4501                	li	a0,0
  c4:	00001097          	auipc	ra,0x1
  c8:	926080e7          	jalr	-1754(ra) # 9ea <exit>

00000000000000cc <just_a_func>:
int
just_a_func(){
  cc:	1141                	addi	sp,sp,-16
  ce:	e406                	sd	ra,8(sp)
  d0:	e022                	sd	s0,0(sp)
  d2:	0800                	addi	s0,sp,16
    printf("func\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	e7c50513          	addi	a0,a0,-388 # f50 <malloc+0x130>
  dc:	00001097          	auipc	ra,0x1
  e0:	c86080e7          	jalr	-890(ra) # d62 <printf>
    return 0;
}
  e4:	4501                	li	a0,0
  e6:	60a2                	ld	ra,8(sp)
  e8:	6402                	ld	s0,0(sp)
  ea:	0141                	addi	sp,sp,16
  ec:	8082                	ret

00000000000000ee <fork_SCFIFO>:

int 
fork_SCFIFO(){
  ee:	7155                	addi	sp,sp,-208
  f0:	e586                	sd	ra,200(sp)
  f2:	e1a2                	sd	s0,192(sp)
  f4:	fd26                	sd	s1,184(sp)
  f6:	f94a                	sd	s2,176(sp)
  f8:	f54e                	sd	s3,168(sp)
  fa:	0980                	addi	s0,sp,208
    char in[3];
    int* pages[18];
    ////-----SCFIFO TEST----------///////////
    printf( "--------------------SCFIFO TEST:----------------------\n");
  fc:	00001517          	auipc	a0,0x1
 100:	e5c50513          	addi	a0,a0,-420 # f58 <malloc+0x138>
 104:	00001097          	auipc	ra,0x1
 108:	c5e080e7          	jalr	-930(ra) # d62 <printf>
    printf( "-------------allocating 16 pages-----------------\n");
 10c:	00001517          	auipc	a0,0x1
 110:	e8450513          	addi	a0,a0,-380 # f90 <malloc+0x170>
 114:	00001097          	auipc	ra,0x1
 118:	c4e080e7          	jalr	-946(ra) # d62 <printf>
    if(fork() == 0){
 11c:	00001097          	auipc	ra,0x1
 120:	8c6080e7          	jalr	-1850(ra) # 9e2 <fork>
 124:	cd09                	beqz	a0,13e <fork_SCFIFO+0x50>
        printf("---------passed scifo test!!!!----------\n");
        gets(in,3);
        exit(0);

    }
    wait(0);
 126:	4501                	li	a0,0
 128:	00001097          	auipc	ra,0x1
 12c:	8ca080e7          	jalr	-1846(ra) # 9f2 <wait>
}
 130:	60ae                	ld	ra,200(sp)
 132:	640e                	ld	s0,192(sp)
 134:	74ea                	ld	s1,184(sp)
 136:	794a                	ld	s2,176(sp)
 138:	79aa                	ld	s3,168(sp)
 13a:	6169                	addi	sp,sp,208
 13c:	8082                	ret
 13e:	84aa                	mv	s1,a0
 140:	f3840913          	addi	s2,s0,-200
        for(int i = 0; i < 16; i++){
 144:	49c1                	li	s3,16
            pages[i] = (int*)sbrk(PGSIZE);
 146:	6505                	lui	a0,0x1
 148:	00001097          	auipc	ra,0x1
 14c:	92a080e7          	jalr	-1750(ra) # a72 <sbrk>
 150:	00a93023          	sd	a0,0(s2)
            *pages[i] = i;
 154:	c104                	sw	s1,0(a0)
        for(int i = 0; i < 16; i++){
 156:	2485                	addiw	s1,s1,1
 158:	0921                	addi	s2,s2,8
 15a:	ff3496e3          	bne	s1,s3,146 <fork_SCFIFO+0x58>
        printf( "-------------now add another page. page[0] should move to the file-----------------\n");
 15e:	00001517          	auipc	a0,0x1
 162:	e6a50513          	addi	a0,a0,-406 # fc8 <malloc+0x1a8>
 166:	00001097          	auipc	ra,0x1
 16a:	bfc080e7          	jalr	-1028(ra) # d62 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 16e:	6505                	lui	a0,0x1
 170:	00001097          	auipc	ra,0x1
 174:	902080e7          	jalr	-1790(ra) # a72 <sbrk>
        printf( "-------------now access to pages[1]-----------------\n");
 178:	00001517          	auipc	a0,0x1
 17c:	ea850513          	addi	a0,a0,-344 # 1020 <malloc+0x200>
 180:	00001097          	auipc	ra,0x1
 184:	be2080e7          	jalr	-1054(ra) # d62 <printf>
        printf("pages[1] contains  %d\n",*pages[1]);
 188:	f4043783          	ld	a5,-192(s0)
 18c:	438c                	lw	a1,0(a5)
 18e:	00001517          	auipc	a0,0x1
 192:	eca50513          	addi	a0,a0,-310 # 1058 <malloc+0x238>
 196:	00001097          	auipc	ra,0x1
 19a:	bcc080e7          	jalr	-1076(ra) # d62 <printf>
        printf( "-------------now add another page. page[2] should move to the file-----------------\n");
 19e:	00001517          	auipc	a0,0x1
 1a2:	ed250513          	addi	a0,a0,-302 # 1070 <malloc+0x250>
 1a6:	00001097          	auipc	ra,0x1
 1aa:	bbc080e7          	jalr	-1092(ra) # d62 <printf>
        pages[17] = (int*)sbrk(PGSIZE);
 1ae:	6505                	lui	a0,0x1
 1b0:	00001097          	auipc	ra,0x1
 1b4:	8c2080e7          	jalr	-1854(ra) # a72 <sbrk>
        printf( "-------------now acess to page[2] should cause pagefault-----------------\n");
 1b8:	00001517          	auipc	a0,0x1
 1bc:	f1050513          	addi	a0,a0,-240 # 10c8 <malloc+0x2a8>
 1c0:	00001097          	auipc	ra,0x1
 1c4:	ba2080e7          	jalr	-1118(ra) # d62 <printf>
        printf("pages[2] contains  %d\n",*pages[2]);
 1c8:	f4843783          	ld	a5,-184(s0)
 1cc:	438c                	lw	a1,0(a5)
 1ce:	00001517          	auipc	a0,0x1
 1d2:	f4a50513          	addi	a0,a0,-182 # 1118 <malloc+0x2f8>
 1d6:	00001097          	auipc	ra,0x1
 1da:	b8c080e7          	jalr	-1140(ra) # d62 <printf>
        printf("---------passed scifo test!!!!----------\n");
 1de:	00001517          	auipc	a0,0x1
 1e2:	f5250513          	addi	a0,a0,-174 # 1130 <malloc+0x310>
 1e6:	00001097          	auipc	ra,0x1
 1ea:	b7c080e7          	jalr	-1156(ra) # d62 <printf>
        gets(in,3);
 1ee:	458d                	li	a1,3
 1f0:	fc840513          	addi	a0,s0,-56
 1f4:	00000097          	auipc	ra,0x0
 1f8:	640080e7          	jalr	1600(ra) # 834 <gets>
        exit(0);
 1fc:	4501                	li	a0,0
 1fe:	00000097          	auipc	ra,0x0
 202:	7ec080e7          	jalr	2028(ra) # 9ea <exit>

0000000000000206 <fork_NFUA>:

int 
fork_NFUA(){
 206:	7155                	addi	sp,sp,-208
 208:	e586                	sd	ra,200(sp)
 20a:	e1a2                	sd	s0,192(sp)
 20c:	fd26                	sd	s1,184(sp)
 20e:	f94a                	sd	s2,176(sp)
 210:	f54e                	sd	s3,168(sp)
 212:	f152                	sd	s4,160(sp)
 214:	0980                	addi	s0,sp,208
    char in[3];
    int* pages[18];
    ////-----NFU + AGING----------///////////
    printf( "--------------------NFU + AGING:----------------------\n");
 216:	00001517          	auipc	a0,0x1
 21a:	f4a50513          	addi	a0,a0,-182 # 1160 <malloc+0x340>
 21e:	00001097          	auipc	ra,0x1
 222:	b44080e7          	jalr	-1212(ra) # d62 <printf>
    printf( "-------------allocating 12 pages-----------------\n");
 226:	00001517          	auipc	a0,0x1
 22a:	f7250513          	addi	a0,a0,-142 # 1198 <malloc+0x378>
 22e:	00001097          	auipc	ra,0x1
 232:	b34080e7          	jalr	-1228(ra) # d62 <printf>
    if(fork() == 0){
 236:	00000097          	auipc	ra,0x0
 23a:	7ac080e7          	jalr	1964(ra) # 9e2 <fork>
 23e:	cd19                	beqz	a0,25c <fork_NFUA+0x56>
        printf("---------passed NFUA test!!!!----------\n");
        gets(in,3);
        exit(0);

    }
    wait(0);
 240:	4501                	li	a0,0
 242:	00000097          	auipc	ra,0x0
 246:	7b0080e7          	jalr	1968(ra) # 9f2 <wait>
    return 1;
}
 24a:	4505                	li	a0,1
 24c:	60ae                	ld	ra,200(sp)
 24e:	640e                	ld	s0,192(sp)
 250:	74ea                	ld	s1,184(sp)
 252:	794a                	ld	s2,176(sp)
 254:	79aa                	ld	s3,168(sp)
 256:	7a0a                	ld	s4,160(sp)
 258:	6169                	addi	sp,sp,208
 25a:	8082                	ret
 25c:	84aa                	mv	s1,a0
 25e:	f3840993          	addi	s3,s0,-200
    if(fork() == 0){
 262:	894e                	mv	s2,s3
        for(int i = 0; i < 13; i++){
 264:	4a35                	li	s4,13
            pages[i] = (int*)sbrk(PGSIZE);
 266:	6505                	lui	a0,0x1
 268:	00001097          	auipc	ra,0x1
 26c:	80a080e7          	jalr	-2038(ra) # a72 <sbrk>
 270:	00a93023          	sd	a0,0(s2)
            *pages[i] = i;
 274:	c104                	sw	s1,0(a0)
        for(int i = 0; i < 13; i++){
 276:	2485                	addiw	s1,s1,1
 278:	0921                	addi	s2,s2,8
 27a:	ff4496e3          	bne	s1,s4,266 <fork_NFUA+0x60>
        printf( "-------------now access all pages except pages[5]-----------------\n");
 27e:	00001517          	auipc	a0,0x1
 282:	f5250513          	addi	a0,a0,-174 # 11d0 <malloc+0x3b0>
 286:	00001097          	auipc	ra,0x1
 28a:	adc080e7          	jalr	-1316(ra) # d62 <printf>
 28e:	4685                	li	a3,1
 290:	4781                	li	a5,0
            if (i!=5)
 292:	4595                	li	a1,5
        for(int i = 0; i < 13; i++){
 294:	4531                	li	a0,12
 296:	a021                	j	29e <fork_NFUA+0x98>
 298:	2785                	addiw	a5,a5,1
 29a:	2685                	addiw	a3,a3,1
 29c:	09a1                	addi	s3,s3,8
 29e:	0007871b          	sext.w	a4,a5
            if (i!=5)
 2a2:	feb70be3          	beq	a4,a1,298 <fork_NFUA+0x92>
                *pages[i] = i;
 2a6:	0009b603          	ld	a2,0(s3)
 2aa:	c218                	sw	a4,0(a2)
        for(int i = 0; i < 13; i++){
 2ac:	0006871b          	sext.w	a4,a3
 2b0:	fee554e3          	bge	a0,a4,298 <fork_NFUA+0x92>
        printf( "-------------now create a new page, pages[5] should be moved to file-----------------\n");
 2b4:	00001517          	auipc	a0,0x1
 2b8:	f6450513          	addi	a0,a0,-156 # 1218 <malloc+0x3f8>
 2bc:	00001097          	auipc	ra,0x1
 2c0:	aa6080e7          	jalr	-1370(ra) # d62 <printf>
        pages[13] = (int*)sbrk(PGSIZE);
 2c4:	6505                	lui	a0,0x1
 2c6:	00000097          	auipc	ra,0x0
 2ca:	7ac080e7          	jalr	1964(ra) # a72 <sbrk>
        printf( "-------------now acess to page[5] should cause pagefault-----------------\n");
 2ce:	00001517          	auipc	a0,0x1
 2d2:	fa250513          	addi	a0,a0,-94 # 1270 <malloc+0x450>
 2d6:	00001097          	auipc	ra,0x1
 2da:	a8c080e7          	jalr	-1396(ra) # d62 <printf>
        printf("pages[5] contains  %d\n",*pages[5]);
 2de:	f6043783          	ld	a5,-160(s0)
 2e2:	438c                	lw	a1,0(a5)
 2e4:	00001517          	auipc	a0,0x1
 2e8:	fdc50513          	addi	a0,a0,-36 # 12c0 <malloc+0x4a0>
 2ec:	00001097          	auipc	ra,0x1
 2f0:	a76080e7          	jalr	-1418(ra) # d62 <printf>
        printf("---------passed NFUA test!!!!----------\n");
 2f4:	00001517          	auipc	a0,0x1
 2f8:	fe450513          	addi	a0,a0,-28 # 12d8 <malloc+0x4b8>
 2fc:	00001097          	auipc	ra,0x1
 300:	a66080e7          	jalr	-1434(ra) # d62 <printf>
        gets(in,3);
 304:	458d                	li	a1,3
 306:	fc840513          	addi	a0,s0,-56
 30a:	00000097          	auipc	ra,0x0
 30e:	52a080e7          	jalr	1322(ra) # 834 <gets>
        exit(0);
 312:	4501                	li	a0,0
 314:	00000097          	auipc	ra,0x0
 318:	6d6080e7          	jalr	1750(ra) # 9ea <exit>

000000000000031c <fork_LAPA1>:

int
fork_LAPA1(){
 31c:	7155                	addi	sp,sp,-208
 31e:	e586                	sd	ra,200(sp)
 320:	e1a2                	sd	s0,192(sp)
 322:	fd26                	sd	s1,184(sp)
 324:	f94a                	sd	s2,176(sp)
 326:	f54e                	sd	s3,168(sp)
 328:	f152                	sd	s4,160(sp)
 32a:	0980                	addi	s0,sp,208
    char in[3];
    int* pages[18];
    printf( "--------------------LAPA 1:----------------------\n");
 32c:	00001517          	auipc	a0,0x1
 330:	fdc50513          	addi	a0,a0,-36 # 1308 <malloc+0x4e8>
 334:	00001097          	auipc	ra,0x1
 338:	a2e080e7          	jalr	-1490(ra) # d62 <printf>
    printf( "-------------allocating 12 pages-----------------\n");
 33c:	00001517          	auipc	a0,0x1
 340:	e5c50513          	addi	a0,a0,-420 # 1198 <malloc+0x378>
 344:	00001097          	auipc	ra,0x1
 348:	a1e080e7          	jalr	-1506(ra) # d62 <printf>
    if(fork() == 0){
 34c:	00000097          	auipc	ra,0x0
 350:	696080e7          	jalr	1686(ra) # 9e2 <fork>
 354:	cd11                	beqz	a0,370 <fork_LAPA1+0x54>
        printf("---------passed LALA 1 test!!!!----------\n");
        gets(in,3);
        exit(0);

    }
    wait(0);
 356:	4501                	li	a0,0
 358:	00000097          	auipc	ra,0x0
 35c:	69a080e7          	jalr	1690(ra) # 9f2 <wait>
}
 360:	60ae                	ld	ra,200(sp)
 362:	640e                	ld	s0,192(sp)
 364:	74ea                	ld	s1,184(sp)
 366:	794a                	ld	s2,176(sp)
 368:	79aa                	ld	s3,168(sp)
 36a:	7a0a                	ld	s4,160(sp)
 36c:	6169                	addi	sp,sp,208
 36e:	8082                	ret
 370:	84aa                	mv	s1,a0
 372:	f3840913          	addi	s2,s0,-200
    if(fork() == 0){
 376:	89ca                	mv	s3,s2
        for(int i = 0; i < 16; i++){
 378:	4a41                	li	s4,16
            pages[i] = (int*)sbrk(PGSIZE);
 37a:	6505                	lui	a0,0x1
 37c:	00000097          	auipc	ra,0x0
 380:	6f6080e7          	jalr	1782(ra) # a72 <sbrk>
 384:	00a9b023          	sd	a0,0(s3)
            *pages[i] = i;
 388:	c104                	sw	s1,0(a0)
        for(int i = 0; i < 16; i++){
 38a:	2485                	addiw	s1,s1,1
 38c:	09a1                	addi	s3,s3,8
 38e:	ff4496e3          	bne	s1,s4,37a <fork_LAPA1+0x5e>
        printf( "-------------now access all pages  pages[5] will be acessed first -----------------\n");
 392:	00001517          	auipc	a0,0x1
 396:	fae50513          	addi	a0,a0,-82 # 1340 <malloc+0x520>
 39a:	00001097          	auipc	ra,0x1
 39e:	9c8080e7          	jalr	-1592(ra) # d62 <printf>
        *pages[5] = 5;
 3a2:	f6043483          	ld	s1,-160(s0)
 3a6:	4795                	li	a5,5
 3a8:	c09c                	sw	a5,0(s1)
        sleep(10);
 3aa:	4529                	li	a0,10
 3ac:	00000097          	auipc	ra,0x0
 3b0:	6ce080e7          	jalr	1742(ra) # a7a <sleep>
 3b4:	4705                	li	a4,1
 3b6:	4781                	li	a5,0
            if (i!=5)
 3b8:	4595                	li	a1,5
        for(int i = 0; i < 16; i++){
 3ba:	453d                	li	a0,15
 3bc:	a021                	j	3c4 <fork_LAPA1+0xa8>
 3be:	2785                	addiw	a5,a5,1
 3c0:	2705                	addiw	a4,a4,1
 3c2:	0921                	addi	s2,s2,8
 3c4:	0007869b          	sext.w	a3,a5
            if (i!=5)
 3c8:	feb68be3          	beq	a3,a1,3be <fork_LAPA1+0xa2>
                *pages[i] = i;
 3cc:	00093603          	ld	a2,0(s2)
 3d0:	c214                	sw	a3,0(a2)
        for(int i = 0; i < 16; i++){
 3d2:	0007069b          	sext.w	a3,a4
 3d6:	fed554e3          	bge	a0,a3,3be <fork_LAPA1+0xa2>
        printf( "-------------now create a new page, pages[5] should be moved to file-----------------\n");
 3da:	00001517          	auipc	a0,0x1
 3de:	e3e50513          	addi	a0,a0,-450 # 1218 <malloc+0x3f8>
 3e2:	00001097          	auipc	ra,0x1
 3e6:	980080e7          	jalr	-1664(ra) # d62 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 3ea:	6505                	lui	a0,0x1
 3ec:	00000097          	auipc	ra,0x0
 3f0:	686080e7          	jalr	1670(ra) # a72 <sbrk>
        printf( "-------------now acess to page[5] should cause pagefault-----------------\n");
 3f4:	00001517          	auipc	a0,0x1
 3f8:	e7c50513          	addi	a0,a0,-388 # 1270 <malloc+0x450>
 3fc:	00001097          	auipc	ra,0x1
 400:	966080e7          	jalr	-1690(ra) # d62 <printf>
        printf("pages[5] contains  %d\n",*pages[5]);
 404:	408c                	lw	a1,0(s1)
 406:	00001517          	auipc	a0,0x1
 40a:	eba50513          	addi	a0,a0,-326 # 12c0 <malloc+0x4a0>
 40e:	00001097          	auipc	ra,0x1
 412:	954080e7          	jalr	-1708(ra) # d62 <printf>
        printf("---------passed LALA 1 test!!!!----------\n");
 416:	00001517          	auipc	a0,0x1
 41a:	f8250513          	addi	a0,a0,-126 # 1398 <malloc+0x578>
 41e:	00001097          	auipc	ra,0x1
 422:	944080e7          	jalr	-1724(ra) # d62 <printf>
        gets(in,3);
 426:	458d                	li	a1,3
 428:	fc840513          	addi	a0,s0,-56
 42c:	00000097          	auipc	ra,0x0
 430:	408080e7          	jalr	1032(ra) # 834 <gets>
        exit(0);
 434:	4501                	li	a0,0
 436:	00000097          	auipc	ra,0x0
 43a:	5b4080e7          	jalr	1460(ra) # 9ea <exit>

000000000000043e <fork_LAPA2>:

int
fork_LAPA2(){
 43e:	7155                	addi	sp,sp,-208
 440:	e586                	sd	ra,200(sp)
 442:	e1a2                	sd	s0,192(sp)
 444:	fd26                	sd	s1,184(sp)
 446:	f94a                	sd	s2,176(sp)
 448:	f54e                	sd	s3,168(sp)
 44a:	f152                	sd	s4,160(sp)
 44c:	0980                	addi	s0,sp,208
    char in[3];
    int* pages[18];
    printf( "--------------------LAPA 2:----------------------\n");
 44e:	00001517          	auipc	a0,0x1
 452:	f7a50513          	addi	a0,a0,-134 # 13c8 <malloc+0x5a8>
 456:	00001097          	auipc	ra,0x1
 45a:	90c080e7          	jalr	-1780(ra) # d62 <printf>
    printf( "-------------allocating 12 pages-----------------\n");
 45e:	00001517          	auipc	a0,0x1
 462:	d3a50513          	addi	a0,a0,-710 # 1198 <malloc+0x378>
 466:	00001097          	auipc	ra,0x1
 46a:	8fc080e7          	jalr	-1796(ra) # d62 <printf>
    if(fork() == 0){
 46e:	00000097          	auipc	ra,0x0
 472:	574080e7          	jalr	1396(ra) # 9e2 <fork>
 476:	cd11                	beqz	a0,492 <fork_LAPA2+0x54>
        printf("---------passed LAPA 2 test!!!!----------\n");
        gets(in,3);
        exit(0);

    }
    wait(0);
 478:	4501                	li	a0,0
 47a:	00000097          	auipc	ra,0x0
 47e:	578080e7          	jalr	1400(ra) # 9f2 <wait>
}
 482:	60ae                	ld	ra,200(sp)
 484:	640e                	ld	s0,192(sp)
 486:	74ea                	ld	s1,184(sp)
 488:	794a                	ld	s2,176(sp)
 48a:	79aa                	ld	s3,168(sp)
 48c:	7a0a                	ld	s4,160(sp)
 48e:	6169                	addi	sp,sp,208
 490:	8082                	ret
 492:	84aa                	mv	s1,a0
 494:	f3840913          	addi	s2,s0,-200
    if(fork() == 0){
 498:	89ca                	mv	s3,s2
        for(int i = 0; i < 12; i++){
 49a:	4a31                	li	s4,12
            pages[i] = (int*)sbrk(PGSIZE);
 49c:	6505                	lui	a0,0x1
 49e:	00000097          	auipc	ra,0x0
 4a2:	5d4080e7          	jalr	1492(ra) # a72 <sbrk>
 4a6:	00a9b023          	sd	a0,0(s3)
            *pages[i] = i;
 4aa:	c104                	sw	s1,0(a0)
        for(int i = 0; i < 12; i++){
 4ac:	2485                	addiw	s1,s1,1
 4ae:	09a1                	addi	s3,s3,8
 4b0:	ff4496e3          	bne	s1,s4,49c <fork_LAPA2+0x5e>
        printf( "-------------now access all pages twice except pages[5]-----------------\n");
 4b4:	00001517          	auipc	a0,0x1
 4b8:	f4c50513          	addi	a0,a0,-180 # 1400 <malloc+0x5e0>
 4bc:	00001097          	auipc	ra,0x1
 4c0:	8a6080e7          	jalr	-1882(ra) # d62 <printf>
 4c4:	86ca                	mv	a3,s2
 4c6:	4705                	li	a4,1
 4c8:	4781                	li	a5,0
            if (i!=5)
 4ca:	4515                	li	a0,5
        for(int i = 0; i < 12; i++){
 4cc:	482d                	li	a6,11
 4ce:	a021                	j	4d6 <fork_LAPA2+0x98>
 4d0:	2785                	addiw	a5,a5,1
 4d2:	2705                	addiw	a4,a4,1
 4d4:	06a1                	addi	a3,a3,8
 4d6:	0007861b          	sext.w	a2,a5
            if (i!=5)
 4da:	fea60be3          	beq	a2,a0,4d0 <fork_LAPA2+0x92>
                *pages[i] = i;
 4de:	628c                	ld	a1,0(a3)
 4e0:	c190                	sw	a2,0(a1)
        for(int i = 0; i < 12; i++){
 4e2:	0007061b          	sext.w	a2,a4
 4e6:	fec855e3          	bge	a6,a2,4d0 <fork_LAPA2+0x92>
        sleep(1);
 4ea:	4505                	li	a0,1
 4ec:	00000097          	auipc	ra,0x0
 4f0:	58e080e7          	jalr	1422(ra) # a7a <sleep>
 4f4:	4705                	li	a4,1
 4f6:	4781                	li	a5,0
            if (i!=5)
 4f8:	4595                	li	a1,5
        for(int i = 0; i < 12; i++){
 4fa:	452d                	li	a0,11
 4fc:	a021                	j	504 <fork_LAPA2+0xc6>
 4fe:	2785                	addiw	a5,a5,1
 500:	2705                	addiw	a4,a4,1
 502:	0921                	addi	s2,s2,8
 504:	0007869b          	sext.w	a3,a5
            if (i!=5)
 508:	feb68be3          	beq	a3,a1,4fe <fork_LAPA2+0xc0>
                *pages[i] = i;
 50c:	00093603          	ld	a2,0(s2)
 510:	c214                	sw	a3,0(a2)
        for(int i = 0; i < 12; i++){
 512:	0007069b          	sext.w	a3,a4
 516:	fed554e3          	bge	a0,a3,4fe <fork_LAPA2+0xc0>
        printf( "-------------now access pages[5] once-----------------\n");
 51a:	00001517          	auipc	a0,0x1
 51e:	f3650513          	addi	a0,a0,-202 # 1450 <malloc+0x630>
 522:	00001097          	auipc	ra,0x1
 526:	840080e7          	jalr	-1984(ra) # d62 <printf>
        *pages[5] = 5;
 52a:	f6043483          	ld	s1,-160(s0)
 52e:	4795                	li	a5,5
 530:	c09c                	sw	a5,0(s1)
        printf( "-------------now create a new page, pages[5] should be moved to file-----------------\n");
 532:	00001517          	auipc	a0,0x1
 536:	ce650513          	addi	a0,a0,-794 # 1218 <malloc+0x3f8>
 53a:	00001097          	auipc	ra,0x1
 53e:	828080e7          	jalr	-2008(ra) # d62 <printf>
        pages[12] = (int*)sbrk(PGSIZE);
 542:	6505                	lui	a0,0x1
 544:	00000097          	auipc	ra,0x0
 548:	52e080e7          	jalr	1326(ra) # a72 <sbrk>
        printf( "-------------now acess to page[5] should cause pagefault-----------------\n");
 54c:	00001517          	auipc	a0,0x1
 550:	d2450513          	addi	a0,a0,-732 # 1270 <malloc+0x450>
 554:	00001097          	auipc	ra,0x1
 558:	80e080e7          	jalr	-2034(ra) # d62 <printf>
        printf("pages[5] contains  %d\n",*pages[5]);
 55c:	408c                	lw	a1,0(s1)
 55e:	00001517          	auipc	a0,0x1
 562:	d6250513          	addi	a0,a0,-670 # 12c0 <malloc+0x4a0>
 566:	00000097          	auipc	ra,0x0
 56a:	7fc080e7          	jalr	2044(ra) # d62 <printf>
        printf("---------passed LAPA 2 test!!!!----------\n");
 56e:	00001517          	auipc	a0,0x1
 572:	f1a50513          	addi	a0,a0,-230 # 1488 <malloc+0x668>
 576:	00000097          	auipc	ra,0x0
 57a:	7ec080e7          	jalr	2028(ra) # d62 <printf>
        gets(in,3);
 57e:	458d                	li	a1,3
 580:	fc840513          	addi	a0,s0,-56
 584:	00000097          	auipc	ra,0x0
 588:	2b0080e7          	jalr	688(ra) # 834 <gets>
        exit(0);
 58c:	4501                	li	a0,0
 58e:	00000097          	auipc	ra,0x0
 592:	45c080e7          	jalr	1116(ra) # 9ea <exit>

0000000000000596 <fork_LAPA3>:

int
fork_LAPA3(){
 596:	7155                	addi	sp,sp,-208
 598:	e586                	sd	ra,200(sp)
 59a:	e1a2                	sd	s0,192(sp)
 59c:	fd26                	sd	s1,184(sp)
 59e:	f94a                	sd	s2,176(sp)
 5a0:	f54e                	sd	s3,168(sp)
 5a2:	f152                	sd	s4,160(sp)
 5a4:	0980                	addi	s0,sp,208
    char in[3];
    int* pages[18];
    printf( "--------------------LAPA 3 : FORK test:----------------------\n");
 5a6:	00001517          	auipc	a0,0x1
 5aa:	f1250513          	addi	a0,a0,-238 # 14b8 <malloc+0x698>
 5ae:	00000097          	auipc	ra,0x0
 5b2:	7b4080e7          	jalr	1972(ra) # d62 <printf>
    printf( "-------------allocating 12 pages for father-----------------\n");
 5b6:	00001517          	auipc	a0,0x1
 5ba:	f4250513          	addi	a0,a0,-190 # 14f8 <malloc+0x6d8>
 5be:	00000097          	auipc	ra,0x0
 5c2:	7a4080e7          	jalr	1956(ra) # d62 <printf>
    for(int i = 0; i < 12; i++){
 5c6:	f3840993          	addi	s3,s0,-200
    printf( "-------------allocating 12 pages for father-----------------\n");
 5ca:	894e                	mv	s2,s3
    for(int i = 0; i < 12; i++){
 5cc:	4481                	li	s1,0
 5ce:	4a31                	li	s4,12
            pages[i] = (int*)sbrk(PGSIZE);
 5d0:	6505                	lui	a0,0x1
 5d2:	00000097          	auipc	ra,0x0
 5d6:	4a0080e7          	jalr	1184(ra) # a72 <sbrk>
 5da:	00a93023          	sd	a0,0(s2)
            *pages[i] = i;
 5de:	c104                	sw	s1,0(a0)
    for(int i = 0; i < 12; i++){
 5e0:	2485                	addiw	s1,s1,1
 5e2:	0921                	addi	s2,s2,8
 5e4:	ff4496e3          	bne	s1,s4,5d0 <fork_LAPA3+0x3a>
        }
    printf( "-------------now access all pages twice except pages[5]-----------------\n");
 5e8:	00001517          	auipc	a0,0x1
 5ec:	e1850513          	addi	a0,a0,-488 # 1400 <malloc+0x5e0>
 5f0:	00000097          	auipc	ra,0x0
 5f4:	772080e7          	jalr	1906(ra) # d62 <printf>
 5f8:	864e                	mv	a2,s3
 5fa:	4685                	li	a3,1
 5fc:	4781                	li	a5,0
        for(int i = 0; i < 12; i++){
            if (i!=5)
 5fe:	4515                	li	a0,5
        for(int i = 0; i < 12; i++){
 600:	482d                	li	a6,11
 602:	a021                	j	60a <fork_LAPA3+0x74>
 604:	2785                	addiw	a5,a5,1
 606:	2685                	addiw	a3,a3,1
 608:	0621                	addi	a2,a2,8
 60a:	0007871b          	sext.w	a4,a5
            if (i!=5)
 60e:	fea70be3          	beq	a4,a0,604 <fork_LAPA3+0x6e>
                *pages[i] = i;
 612:	620c                	ld	a1,0(a2)
 614:	c198                	sw	a4,0(a1)
        for(int i = 0; i < 12; i++){
 616:	0006871b          	sext.w	a4,a3
 61a:	fee855e3          	bge	a6,a4,604 <fork_LAPA3+0x6e>
        }
        sleep(1);
 61e:	4505                	li	a0,1
 620:	00000097          	auipc	ra,0x0
 624:	45a080e7          	jalr	1114(ra) # a7a <sleep>
 628:	4685                	li	a3,1
 62a:	4781                	li	a5,0
        for(int i = 0; i < 12; i++){
            if (i!=5)
 62c:	4595                	li	a1,5
        for(int i = 0; i < 12; i++){
 62e:	452d                	li	a0,11
 630:	a021                	j	638 <fork_LAPA3+0xa2>
 632:	2785                	addiw	a5,a5,1
 634:	2685                	addiw	a3,a3,1
 636:	09a1                	addi	s3,s3,8
 638:	0007871b          	sext.w	a4,a5
            if (i!=5)
 63c:	feb70be3          	beq	a4,a1,632 <fork_LAPA3+0x9c>
                *pages[i] = i;
 640:	0009b603          	ld	a2,0(s3)
 644:	c218                	sw	a4,0(a2)
        for(int i = 0; i < 12; i++){
 646:	0006871b          	sext.w	a4,a3
 64a:	fee554e3          	bge	a0,a4,632 <fork_LAPA3+0x9c>
        }
        printf( "-------------now access pages[5] once-----------------\n");
 64e:	00001517          	auipc	a0,0x1
 652:	e0250513          	addi	a0,a0,-510 # 1450 <malloc+0x630>
 656:	00000097          	auipc	ra,0x0
 65a:	70c080e7          	jalr	1804(ra) # d62 <printf>
        *pages[5] = 5;
 65e:	f6043483          	ld	s1,-160(s0)
 662:	4795                	li	a5,5
 664:	c09c                	sw	a5,0(s1)
    if(fork() == 0){
 666:	00000097          	auipc	ra,0x0
 66a:	37c080e7          	jalr	892(ra) # 9e2 <fork>
 66e:	c93d                	beqz	a0,6e4 <fork_LAPA3+0x14e>
        printf( "-------------CHILD: now acess to page[5] should cause pagefault-----------------\n");
        printf("pages[5] contains  %d\n",*pages[5]);
        exit(0);

    }
    wait(0);
 670:	4501                	li	a0,0
 672:	00000097          	auipc	ra,0x0
 676:	380080e7          	jalr	896(ra) # 9f2 <wait>
    printf( "-------------FATHER: create a new page, pages[5] should be moved to file-----------------\n");
 67a:	00001517          	auipc	a0,0x1
 67e:	f7650513          	addi	a0,a0,-138 # 15f0 <malloc+0x7d0>
 682:	00000097          	auipc	ra,0x0
 686:	6e0080e7          	jalr	1760(ra) # d62 <printf>
        pages[14] = (int*)sbrk(PGSIZE);
 68a:	6505                	lui	a0,0x1
 68c:	00000097          	auipc	ra,0x0
 690:	3e6080e7          	jalr	998(ra) # a72 <sbrk>
        
        printf( "-------------FATHER: now acess to page[5] should cause pagefault-----------------\n");
 694:	00001517          	auipc	a0,0x1
 698:	fbc50513          	addi	a0,a0,-68 # 1650 <malloc+0x830>
 69c:	00000097          	auipc	ra,0x0
 6a0:	6c6080e7          	jalr	1734(ra) # d62 <printf>
        printf("pages[5] contains  %d\n",*pages[5]);
 6a4:	408c                	lw	a1,0(s1)
 6a6:	00001517          	auipc	a0,0x1
 6aa:	c1a50513          	addi	a0,a0,-998 # 12c0 <malloc+0x4a0>
 6ae:	00000097          	auipc	ra,0x0
 6b2:	6b4080e7          	jalr	1716(ra) # d62 <printf>
        
        
   
    printf("---------passed LAPA 3 test!!!!----------\n");
 6b6:	00001517          	auipc	a0,0x1
 6ba:	ff250513          	addi	a0,a0,-14 # 16a8 <malloc+0x888>
 6be:	00000097          	auipc	ra,0x0
 6c2:	6a4080e7          	jalr	1700(ra) # d62 <printf>
    gets(in,3);
 6c6:	458d                	li	a1,3
 6c8:	fc840513          	addi	a0,s0,-56
 6cc:	00000097          	auipc	ra,0x0
 6d0:	168080e7          	jalr	360(ra) # 834 <gets>
}
 6d4:	60ae                	ld	ra,200(sp)
 6d6:	640e                	ld	s0,192(sp)
 6d8:	74ea                	ld	s1,184(sp)
 6da:	794a                	ld	s2,176(sp)
 6dc:	79aa                	ld	s3,168(sp)
 6de:	7a0a                	ld	s4,160(sp)
 6e0:	6169                	addi	sp,sp,208
 6e2:	8082                	ret
        printf( "-------------CHILD: create a new page, pages[5] should be moved to file-----------------\n");
 6e4:	00001517          	auipc	a0,0x1
 6e8:	e5450513          	addi	a0,a0,-428 # 1538 <malloc+0x718>
 6ec:	00000097          	auipc	ra,0x0
 6f0:	676080e7          	jalr	1654(ra) # d62 <printf>
        pages[14] = (int*)sbrk(PGSIZE);
 6f4:	6505                	lui	a0,0x1
 6f6:	00000097          	auipc	ra,0x0
 6fa:	37c080e7          	jalr	892(ra) # a72 <sbrk>
        printf( "-------------CHILD: now acess to page[5] should cause pagefault-----------------\n");
 6fe:	00001517          	auipc	a0,0x1
 702:	e9a50513          	addi	a0,a0,-358 # 1598 <malloc+0x778>
 706:	00000097          	auipc	ra,0x0
 70a:	65c080e7          	jalr	1628(ra) # d62 <printf>
        printf("pages[5] contains  %d\n",*pages[5]);
 70e:	408c                	lw	a1,0(s1)
 710:	00001517          	auipc	a0,0x1
 714:	bb050513          	addi	a0,a0,-1104 # 12c0 <malloc+0x4a0>
 718:	00000097          	auipc	ra,0x0
 71c:	64a080e7          	jalr	1610(ra) # d62 <printf>
        exit(0);
 720:	4501                	li	a0,0
 722:	00000097          	auipc	ra,0x0
 726:	2c8080e7          	jalr	712(ra) # 9ea <exit>

000000000000072a <fork_test>:

int 
fork_test(){
 72a:	1141                	addi	sp,sp,-16
 72c:	e406                	sd	ra,8(sp)
 72e:	e022                	sd	s0,0(sp)
 730:	0800                	addi	s0,sp,16
    #ifdef NFUA
    return fork_NFUA();
    #endif

    #ifdef LAPA
    fork_LAPA1();
 732:	00000097          	auipc	ra,0x0
 736:	bea080e7          	jalr	-1046(ra) # 31c <fork_LAPA1>
    fork_LAPA2();
 73a:	00000097          	auipc	ra,0x0
 73e:	d04080e7          	jalr	-764(ra) # 43e <fork_LAPA2>
    return fork_LAPA3();
 742:	00000097          	auipc	ra,0x0
 746:	e54080e7          	jalr	-428(ra) # 596 <fork_LAPA3>
    #endif
    return -1;
    
}
 74a:	60a2                	ld	ra,8(sp)
 74c:	6402                	ld	s0,0(sp)
 74e:	0141                	addi	sp,sp,16
 750:	8082                	ret

0000000000000752 <main>:
int
main(int argc, char *argv[])
{
 752:	1141                	addi	sp,sp,-16
 754:	e406                	sd	ra,8(sp)
 756:	e022                	sd	s0,0(sp)
 758:	0800                	addi	s0,sp,16
    // printf("-----------------------------sbark_and_fork-----------------------------\n");
    // sbark_and_fork();
    printf("-----------------------------fork_test-----------------------------\n");
 75a:	00001517          	auipc	a0,0x1
 75e:	f7e50513          	addi	a0,a0,-130 # 16d8 <malloc+0x8b8>
 762:	00000097          	auipc	ra,0x0
 766:	600080e7          	jalr	1536(ra) # d62 <printf>
    fork_test();
 76a:	00000097          	auipc	ra,0x0
 76e:	fc0080e7          	jalr	-64(ra) # 72a <fork_test>
    exit(0);
 772:	4501                	li	a0,0
 774:	00000097          	auipc	ra,0x0
 778:	276080e7          	jalr	630(ra) # 9ea <exit>

000000000000077c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 77c:	1141                	addi	sp,sp,-16
 77e:	e422                	sd	s0,8(sp)
 780:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 782:	87aa                	mv	a5,a0
 784:	0585                	addi	a1,a1,1
 786:	0785                	addi	a5,a5,1
 788:	fff5c703          	lbu	a4,-1(a1)
 78c:	fee78fa3          	sb	a4,-1(a5)
 790:	fb75                	bnez	a4,784 <strcpy+0x8>
    ;
  return os;
}
 792:	6422                	ld	s0,8(sp)
 794:	0141                	addi	sp,sp,16
 796:	8082                	ret

0000000000000798 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 798:	1141                	addi	sp,sp,-16
 79a:	e422                	sd	s0,8(sp)
 79c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 79e:	00054783          	lbu	a5,0(a0)
 7a2:	cb91                	beqz	a5,7b6 <strcmp+0x1e>
 7a4:	0005c703          	lbu	a4,0(a1)
 7a8:	00f71763          	bne	a4,a5,7b6 <strcmp+0x1e>
    p++, q++;
 7ac:	0505                	addi	a0,a0,1
 7ae:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 7b0:	00054783          	lbu	a5,0(a0)
 7b4:	fbe5                	bnez	a5,7a4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 7b6:	0005c503          	lbu	a0,0(a1)
}
 7ba:	40a7853b          	subw	a0,a5,a0
 7be:	6422                	ld	s0,8(sp)
 7c0:	0141                	addi	sp,sp,16
 7c2:	8082                	ret

00000000000007c4 <strlen>:

uint
strlen(const char *s)
{
 7c4:	1141                	addi	sp,sp,-16
 7c6:	e422                	sd	s0,8(sp)
 7c8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 7ca:	00054783          	lbu	a5,0(a0)
 7ce:	cf91                	beqz	a5,7ea <strlen+0x26>
 7d0:	0505                	addi	a0,a0,1
 7d2:	87aa                	mv	a5,a0
 7d4:	4685                	li	a3,1
 7d6:	9e89                	subw	a3,a3,a0
 7d8:	00f6853b          	addw	a0,a3,a5
 7dc:	0785                	addi	a5,a5,1
 7de:	fff7c703          	lbu	a4,-1(a5)
 7e2:	fb7d                	bnez	a4,7d8 <strlen+0x14>
    ;
  return n;
}
 7e4:	6422                	ld	s0,8(sp)
 7e6:	0141                	addi	sp,sp,16
 7e8:	8082                	ret
  for(n = 0; s[n]; n++)
 7ea:	4501                	li	a0,0
 7ec:	bfe5                	j	7e4 <strlen+0x20>

00000000000007ee <memset>:

void*
memset(void *dst, int c, uint n)
{
 7ee:	1141                	addi	sp,sp,-16
 7f0:	e422                	sd	s0,8(sp)
 7f2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 7f4:	ca19                	beqz	a2,80a <memset+0x1c>
 7f6:	87aa                	mv	a5,a0
 7f8:	1602                	slli	a2,a2,0x20
 7fa:	9201                	srli	a2,a2,0x20
 7fc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 800:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 804:	0785                	addi	a5,a5,1
 806:	fee79de3          	bne	a5,a4,800 <memset+0x12>
  }
  return dst;
}
 80a:	6422                	ld	s0,8(sp)
 80c:	0141                	addi	sp,sp,16
 80e:	8082                	ret

0000000000000810 <strchr>:

char*
strchr(const char *s, char c)
{
 810:	1141                	addi	sp,sp,-16
 812:	e422                	sd	s0,8(sp)
 814:	0800                	addi	s0,sp,16
  for(; *s; s++)
 816:	00054783          	lbu	a5,0(a0)
 81a:	cb99                	beqz	a5,830 <strchr+0x20>
    if(*s == c)
 81c:	00f58763          	beq	a1,a5,82a <strchr+0x1a>
  for(; *s; s++)
 820:	0505                	addi	a0,a0,1
 822:	00054783          	lbu	a5,0(a0)
 826:	fbfd                	bnez	a5,81c <strchr+0xc>
      return (char*)s;
  return 0;
 828:	4501                	li	a0,0
}
 82a:	6422                	ld	s0,8(sp)
 82c:	0141                	addi	sp,sp,16
 82e:	8082                	ret
  return 0;
 830:	4501                	li	a0,0
 832:	bfe5                	j	82a <strchr+0x1a>

0000000000000834 <gets>:

char*
gets(char *buf, int max)
{
 834:	711d                	addi	sp,sp,-96
 836:	ec86                	sd	ra,88(sp)
 838:	e8a2                	sd	s0,80(sp)
 83a:	e4a6                	sd	s1,72(sp)
 83c:	e0ca                	sd	s2,64(sp)
 83e:	fc4e                	sd	s3,56(sp)
 840:	f852                	sd	s4,48(sp)
 842:	f456                	sd	s5,40(sp)
 844:	f05a                	sd	s6,32(sp)
 846:	ec5e                	sd	s7,24(sp)
 848:	1080                	addi	s0,sp,96
 84a:	8baa                	mv	s7,a0
 84c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 84e:	892a                	mv	s2,a0
 850:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 852:	4aa9                	li	s5,10
 854:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 856:	89a6                	mv	s3,s1
 858:	2485                	addiw	s1,s1,1
 85a:	0344d863          	bge	s1,s4,88a <gets+0x56>
    cc = read(0, &c, 1);
 85e:	4605                	li	a2,1
 860:	faf40593          	addi	a1,s0,-81
 864:	4501                	li	a0,0
 866:	00000097          	auipc	ra,0x0
 86a:	19c080e7          	jalr	412(ra) # a02 <read>
    if(cc < 1)
 86e:	00a05e63          	blez	a0,88a <gets+0x56>
    buf[i++] = c;
 872:	faf44783          	lbu	a5,-81(s0)
 876:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 87a:	01578763          	beq	a5,s5,888 <gets+0x54>
 87e:	0905                	addi	s2,s2,1
 880:	fd679be3          	bne	a5,s6,856 <gets+0x22>
  for(i=0; i+1 < max; ){
 884:	89a6                	mv	s3,s1
 886:	a011                	j	88a <gets+0x56>
 888:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 88a:	99de                	add	s3,s3,s7
 88c:	00098023          	sb	zero,0(s3)
  return buf;
}
 890:	855e                	mv	a0,s7
 892:	60e6                	ld	ra,88(sp)
 894:	6446                	ld	s0,80(sp)
 896:	64a6                	ld	s1,72(sp)
 898:	6906                	ld	s2,64(sp)
 89a:	79e2                	ld	s3,56(sp)
 89c:	7a42                	ld	s4,48(sp)
 89e:	7aa2                	ld	s5,40(sp)
 8a0:	7b02                	ld	s6,32(sp)
 8a2:	6be2                	ld	s7,24(sp)
 8a4:	6125                	addi	sp,sp,96
 8a6:	8082                	ret

00000000000008a8 <stat>:

int
stat(const char *n, struct stat *st)
{
 8a8:	1101                	addi	sp,sp,-32
 8aa:	ec06                	sd	ra,24(sp)
 8ac:	e822                	sd	s0,16(sp)
 8ae:	e426                	sd	s1,8(sp)
 8b0:	e04a                	sd	s2,0(sp)
 8b2:	1000                	addi	s0,sp,32
 8b4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 8b6:	4581                	li	a1,0
 8b8:	00000097          	auipc	ra,0x0
 8bc:	172080e7          	jalr	370(ra) # a2a <open>
  if(fd < 0)
 8c0:	02054563          	bltz	a0,8ea <stat+0x42>
 8c4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 8c6:	85ca                	mv	a1,s2
 8c8:	00000097          	auipc	ra,0x0
 8cc:	17a080e7          	jalr	378(ra) # a42 <fstat>
 8d0:	892a                	mv	s2,a0
  close(fd);
 8d2:	8526                	mv	a0,s1
 8d4:	00000097          	auipc	ra,0x0
 8d8:	13e080e7          	jalr	318(ra) # a12 <close>
  return r;
}
 8dc:	854a                	mv	a0,s2
 8de:	60e2                	ld	ra,24(sp)
 8e0:	6442                	ld	s0,16(sp)
 8e2:	64a2                	ld	s1,8(sp)
 8e4:	6902                	ld	s2,0(sp)
 8e6:	6105                	addi	sp,sp,32
 8e8:	8082                	ret
    return -1;
 8ea:	597d                	li	s2,-1
 8ec:	bfc5                	j	8dc <stat+0x34>

00000000000008ee <atoi>:

int
atoi(const char *s)
{
 8ee:	1141                	addi	sp,sp,-16
 8f0:	e422                	sd	s0,8(sp)
 8f2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 8f4:	00054603          	lbu	a2,0(a0)
 8f8:	fd06079b          	addiw	a5,a2,-48
 8fc:	0ff7f793          	andi	a5,a5,255
 900:	4725                	li	a4,9
 902:	02f76963          	bltu	a4,a5,934 <atoi+0x46>
 906:	86aa                	mv	a3,a0
  n = 0;
 908:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 90a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 90c:	0685                	addi	a3,a3,1
 90e:	0025179b          	slliw	a5,a0,0x2
 912:	9fa9                	addw	a5,a5,a0
 914:	0017979b          	slliw	a5,a5,0x1
 918:	9fb1                	addw	a5,a5,a2
 91a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 91e:	0006c603          	lbu	a2,0(a3)
 922:	fd06071b          	addiw	a4,a2,-48
 926:	0ff77713          	andi	a4,a4,255
 92a:	fee5f1e3          	bgeu	a1,a4,90c <atoi+0x1e>
  return n;
}
 92e:	6422                	ld	s0,8(sp)
 930:	0141                	addi	sp,sp,16
 932:	8082                	ret
  n = 0;
 934:	4501                	li	a0,0
 936:	bfe5                	j	92e <atoi+0x40>

0000000000000938 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 938:	1141                	addi	sp,sp,-16
 93a:	e422                	sd	s0,8(sp)
 93c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 93e:	02b57463          	bgeu	a0,a1,966 <memmove+0x2e>
    while(n-- > 0)
 942:	00c05f63          	blez	a2,960 <memmove+0x28>
 946:	1602                	slli	a2,a2,0x20
 948:	9201                	srli	a2,a2,0x20
 94a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 94e:	872a                	mv	a4,a0
      *dst++ = *src++;
 950:	0585                	addi	a1,a1,1
 952:	0705                	addi	a4,a4,1
 954:	fff5c683          	lbu	a3,-1(a1)
 958:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 95c:	fee79ae3          	bne	a5,a4,950 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 960:	6422                	ld	s0,8(sp)
 962:	0141                	addi	sp,sp,16
 964:	8082                	ret
    dst += n;
 966:	00c50733          	add	a4,a0,a2
    src += n;
 96a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 96c:	fec05ae3          	blez	a2,960 <memmove+0x28>
 970:	fff6079b          	addiw	a5,a2,-1
 974:	1782                	slli	a5,a5,0x20
 976:	9381                	srli	a5,a5,0x20
 978:	fff7c793          	not	a5,a5
 97c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 97e:	15fd                	addi	a1,a1,-1
 980:	177d                	addi	a4,a4,-1
 982:	0005c683          	lbu	a3,0(a1)
 986:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 98a:	fee79ae3          	bne	a5,a4,97e <memmove+0x46>
 98e:	bfc9                	j	960 <memmove+0x28>

0000000000000990 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 990:	1141                	addi	sp,sp,-16
 992:	e422                	sd	s0,8(sp)
 994:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 996:	ca05                	beqz	a2,9c6 <memcmp+0x36>
 998:	fff6069b          	addiw	a3,a2,-1
 99c:	1682                	slli	a3,a3,0x20
 99e:	9281                	srli	a3,a3,0x20
 9a0:	0685                	addi	a3,a3,1
 9a2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 9a4:	00054783          	lbu	a5,0(a0)
 9a8:	0005c703          	lbu	a4,0(a1)
 9ac:	00e79863          	bne	a5,a4,9bc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 9b0:	0505                	addi	a0,a0,1
    p2++;
 9b2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 9b4:	fed518e3          	bne	a0,a3,9a4 <memcmp+0x14>
  }
  return 0;
 9b8:	4501                	li	a0,0
 9ba:	a019                	j	9c0 <memcmp+0x30>
      return *p1 - *p2;
 9bc:	40e7853b          	subw	a0,a5,a4
}
 9c0:	6422                	ld	s0,8(sp)
 9c2:	0141                	addi	sp,sp,16
 9c4:	8082                	ret
  return 0;
 9c6:	4501                	li	a0,0
 9c8:	bfe5                	j	9c0 <memcmp+0x30>

00000000000009ca <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 9ca:	1141                	addi	sp,sp,-16
 9cc:	e406                	sd	ra,8(sp)
 9ce:	e022                	sd	s0,0(sp)
 9d0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 9d2:	00000097          	auipc	ra,0x0
 9d6:	f66080e7          	jalr	-154(ra) # 938 <memmove>
}
 9da:	60a2                	ld	ra,8(sp)
 9dc:	6402                	ld	s0,0(sp)
 9de:	0141                	addi	sp,sp,16
 9e0:	8082                	ret

00000000000009e2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 9e2:	4885                	li	a7,1
 ecall
 9e4:	00000073          	ecall
 ret
 9e8:	8082                	ret

00000000000009ea <exit>:
.global exit
exit:
 li a7, SYS_exit
 9ea:	4889                	li	a7,2
 ecall
 9ec:	00000073          	ecall
 ret
 9f0:	8082                	ret

00000000000009f2 <wait>:
.global wait
wait:
 li a7, SYS_wait
 9f2:	488d                	li	a7,3
 ecall
 9f4:	00000073          	ecall
 ret
 9f8:	8082                	ret

00000000000009fa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 9fa:	4891                	li	a7,4
 ecall
 9fc:	00000073          	ecall
 ret
 a00:	8082                	ret

0000000000000a02 <read>:
.global read
read:
 li a7, SYS_read
 a02:	4895                	li	a7,5
 ecall
 a04:	00000073          	ecall
 ret
 a08:	8082                	ret

0000000000000a0a <write>:
.global write
write:
 li a7, SYS_write
 a0a:	48c1                	li	a7,16
 ecall
 a0c:	00000073          	ecall
 ret
 a10:	8082                	ret

0000000000000a12 <close>:
.global close
close:
 li a7, SYS_close
 a12:	48d5                	li	a7,21
 ecall
 a14:	00000073          	ecall
 ret
 a18:	8082                	ret

0000000000000a1a <kill>:
.global kill
kill:
 li a7, SYS_kill
 a1a:	4899                	li	a7,6
 ecall
 a1c:	00000073          	ecall
 ret
 a20:	8082                	ret

0000000000000a22 <exec>:
.global exec
exec:
 li a7, SYS_exec
 a22:	489d                	li	a7,7
 ecall
 a24:	00000073          	ecall
 ret
 a28:	8082                	ret

0000000000000a2a <open>:
.global open
open:
 li a7, SYS_open
 a2a:	48bd                	li	a7,15
 ecall
 a2c:	00000073          	ecall
 ret
 a30:	8082                	ret

0000000000000a32 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 a32:	48c5                	li	a7,17
 ecall
 a34:	00000073          	ecall
 ret
 a38:	8082                	ret

0000000000000a3a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 a3a:	48c9                	li	a7,18
 ecall
 a3c:	00000073          	ecall
 ret
 a40:	8082                	ret

0000000000000a42 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 a42:	48a1                	li	a7,8
 ecall
 a44:	00000073          	ecall
 ret
 a48:	8082                	ret

0000000000000a4a <link>:
.global link
link:
 li a7, SYS_link
 a4a:	48cd                	li	a7,19
 ecall
 a4c:	00000073          	ecall
 ret
 a50:	8082                	ret

0000000000000a52 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 a52:	48d1                	li	a7,20
 ecall
 a54:	00000073          	ecall
 ret
 a58:	8082                	ret

0000000000000a5a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 a5a:	48a5                	li	a7,9
 ecall
 a5c:	00000073          	ecall
 ret
 a60:	8082                	ret

0000000000000a62 <dup>:
.global dup
dup:
 li a7, SYS_dup
 a62:	48a9                	li	a7,10
 ecall
 a64:	00000073          	ecall
 ret
 a68:	8082                	ret

0000000000000a6a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 a6a:	48ad                	li	a7,11
 ecall
 a6c:	00000073          	ecall
 ret
 a70:	8082                	ret

0000000000000a72 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 a72:	48b1                	li	a7,12
 ecall
 a74:	00000073          	ecall
 ret
 a78:	8082                	ret

0000000000000a7a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 a7a:	48b5                	li	a7,13
 ecall
 a7c:	00000073          	ecall
 ret
 a80:	8082                	ret

0000000000000a82 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 a82:	48b9                	li	a7,14
 ecall
 a84:	00000073          	ecall
 ret
 a88:	8082                	ret

0000000000000a8a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 a8a:	1101                	addi	sp,sp,-32
 a8c:	ec06                	sd	ra,24(sp)
 a8e:	e822                	sd	s0,16(sp)
 a90:	1000                	addi	s0,sp,32
 a92:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 a96:	4605                	li	a2,1
 a98:	fef40593          	addi	a1,s0,-17
 a9c:	00000097          	auipc	ra,0x0
 aa0:	f6e080e7          	jalr	-146(ra) # a0a <write>
}
 aa4:	60e2                	ld	ra,24(sp)
 aa6:	6442                	ld	s0,16(sp)
 aa8:	6105                	addi	sp,sp,32
 aaa:	8082                	ret

0000000000000aac <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 aac:	7139                	addi	sp,sp,-64
 aae:	fc06                	sd	ra,56(sp)
 ab0:	f822                	sd	s0,48(sp)
 ab2:	f426                	sd	s1,40(sp)
 ab4:	f04a                	sd	s2,32(sp)
 ab6:	ec4e                	sd	s3,24(sp)
 ab8:	0080                	addi	s0,sp,64
 aba:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 abc:	c299                	beqz	a3,ac2 <printint+0x16>
 abe:	0805c863          	bltz	a1,b4e <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 ac2:	2581                	sext.w	a1,a1
  neg = 0;
 ac4:	4881                	li	a7,0
 ac6:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 aca:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 acc:	2601                	sext.w	a2,a2
 ace:	00001517          	auipc	a0,0x1
 ad2:	c5a50513          	addi	a0,a0,-934 # 1728 <digits>
 ad6:	883a                	mv	a6,a4
 ad8:	2705                	addiw	a4,a4,1
 ada:	02c5f7bb          	remuw	a5,a1,a2
 ade:	1782                	slli	a5,a5,0x20
 ae0:	9381                	srli	a5,a5,0x20
 ae2:	97aa                	add	a5,a5,a0
 ae4:	0007c783          	lbu	a5,0(a5)
 ae8:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 aec:	0005879b          	sext.w	a5,a1
 af0:	02c5d5bb          	divuw	a1,a1,a2
 af4:	0685                	addi	a3,a3,1
 af6:	fec7f0e3          	bgeu	a5,a2,ad6 <printint+0x2a>
  if(neg)
 afa:	00088b63          	beqz	a7,b10 <printint+0x64>
    buf[i++] = '-';
 afe:	fd040793          	addi	a5,s0,-48
 b02:	973e                	add	a4,a4,a5
 b04:	02d00793          	li	a5,45
 b08:	fef70823          	sb	a5,-16(a4)
 b0c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 b10:	02e05863          	blez	a4,b40 <printint+0x94>
 b14:	fc040793          	addi	a5,s0,-64
 b18:	00e78933          	add	s2,a5,a4
 b1c:	fff78993          	addi	s3,a5,-1
 b20:	99ba                	add	s3,s3,a4
 b22:	377d                	addiw	a4,a4,-1
 b24:	1702                	slli	a4,a4,0x20
 b26:	9301                	srli	a4,a4,0x20
 b28:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 b2c:	fff94583          	lbu	a1,-1(s2)
 b30:	8526                	mv	a0,s1
 b32:	00000097          	auipc	ra,0x0
 b36:	f58080e7          	jalr	-168(ra) # a8a <putc>
  while(--i >= 0)
 b3a:	197d                	addi	s2,s2,-1
 b3c:	ff3918e3          	bne	s2,s3,b2c <printint+0x80>
}
 b40:	70e2                	ld	ra,56(sp)
 b42:	7442                	ld	s0,48(sp)
 b44:	74a2                	ld	s1,40(sp)
 b46:	7902                	ld	s2,32(sp)
 b48:	69e2                	ld	s3,24(sp)
 b4a:	6121                	addi	sp,sp,64
 b4c:	8082                	ret
    x = -xx;
 b4e:	40b005bb          	negw	a1,a1
    neg = 1;
 b52:	4885                	li	a7,1
    x = -xx;
 b54:	bf8d                	j	ac6 <printint+0x1a>

0000000000000b56 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 b56:	7119                	addi	sp,sp,-128
 b58:	fc86                	sd	ra,120(sp)
 b5a:	f8a2                	sd	s0,112(sp)
 b5c:	f4a6                	sd	s1,104(sp)
 b5e:	f0ca                	sd	s2,96(sp)
 b60:	ecce                	sd	s3,88(sp)
 b62:	e8d2                	sd	s4,80(sp)
 b64:	e4d6                	sd	s5,72(sp)
 b66:	e0da                	sd	s6,64(sp)
 b68:	fc5e                	sd	s7,56(sp)
 b6a:	f862                	sd	s8,48(sp)
 b6c:	f466                	sd	s9,40(sp)
 b6e:	f06a                	sd	s10,32(sp)
 b70:	ec6e                	sd	s11,24(sp)
 b72:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 b74:	0005c903          	lbu	s2,0(a1)
 b78:	18090f63          	beqz	s2,d16 <vprintf+0x1c0>
 b7c:	8aaa                	mv	s5,a0
 b7e:	8b32                	mv	s6,a2
 b80:	00158493          	addi	s1,a1,1
  state = 0;
 b84:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 b86:	02500a13          	li	s4,37
      if(c == 'd'){
 b8a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 b8e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 b92:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 b96:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 b9a:	00001b97          	auipc	s7,0x1
 b9e:	b8eb8b93          	addi	s7,s7,-1138 # 1728 <digits>
 ba2:	a839                	j	bc0 <vprintf+0x6a>
        putc(fd, c);
 ba4:	85ca                	mv	a1,s2
 ba6:	8556                	mv	a0,s5
 ba8:	00000097          	auipc	ra,0x0
 bac:	ee2080e7          	jalr	-286(ra) # a8a <putc>
 bb0:	a019                	j	bb6 <vprintf+0x60>
    } else if(state == '%'){
 bb2:	01498f63          	beq	s3,s4,bd0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 bb6:	0485                	addi	s1,s1,1
 bb8:	fff4c903          	lbu	s2,-1(s1)
 bbc:	14090d63          	beqz	s2,d16 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 bc0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 bc4:	fe0997e3          	bnez	s3,bb2 <vprintf+0x5c>
      if(c == '%'){
 bc8:	fd479ee3          	bne	a5,s4,ba4 <vprintf+0x4e>
        state = '%';
 bcc:	89be                	mv	s3,a5
 bce:	b7e5                	j	bb6 <vprintf+0x60>
      if(c == 'd'){
 bd0:	05878063          	beq	a5,s8,c10 <vprintf+0xba>
      } else if(c == 'l') {
 bd4:	05978c63          	beq	a5,s9,c2c <vprintf+0xd6>
      } else if(c == 'x') {
 bd8:	07a78863          	beq	a5,s10,c48 <vprintf+0xf2>
      } else if(c == 'p') {
 bdc:	09b78463          	beq	a5,s11,c64 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 be0:	07300713          	li	a4,115
 be4:	0ce78663          	beq	a5,a4,cb0 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 be8:	06300713          	li	a4,99
 bec:	0ee78e63          	beq	a5,a4,ce8 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 bf0:	11478863          	beq	a5,s4,d00 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 bf4:	85d2                	mv	a1,s4
 bf6:	8556                	mv	a0,s5
 bf8:	00000097          	auipc	ra,0x0
 bfc:	e92080e7          	jalr	-366(ra) # a8a <putc>
        putc(fd, c);
 c00:	85ca                	mv	a1,s2
 c02:	8556                	mv	a0,s5
 c04:	00000097          	auipc	ra,0x0
 c08:	e86080e7          	jalr	-378(ra) # a8a <putc>
      }
      state = 0;
 c0c:	4981                	li	s3,0
 c0e:	b765                	j	bb6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 c10:	008b0913          	addi	s2,s6,8
 c14:	4685                	li	a3,1
 c16:	4629                	li	a2,10
 c18:	000b2583          	lw	a1,0(s6)
 c1c:	8556                	mv	a0,s5
 c1e:	00000097          	auipc	ra,0x0
 c22:	e8e080e7          	jalr	-370(ra) # aac <printint>
 c26:	8b4a                	mv	s6,s2
      state = 0;
 c28:	4981                	li	s3,0
 c2a:	b771                	j	bb6 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 c2c:	008b0913          	addi	s2,s6,8
 c30:	4681                	li	a3,0
 c32:	4629                	li	a2,10
 c34:	000b2583          	lw	a1,0(s6)
 c38:	8556                	mv	a0,s5
 c3a:	00000097          	auipc	ra,0x0
 c3e:	e72080e7          	jalr	-398(ra) # aac <printint>
 c42:	8b4a                	mv	s6,s2
      state = 0;
 c44:	4981                	li	s3,0
 c46:	bf85                	j	bb6 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 c48:	008b0913          	addi	s2,s6,8
 c4c:	4681                	li	a3,0
 c4e:	4641                	li	a2,16
 c50:	000b2583          	lw	a1,0(s6)
 c54:	8556                	mv	a0,s5
 c56:	00000097          	auipc	ra,0x0
 c5a:	e56080e7          	jalr	-426(ra) # aac <printint>
 c5e:	8b4a                	mv	s6,s2
      state = 0;
 c60:	4981                	li	s3,0
 c62:	bf91                	j	bb6 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 c64:	008b0793          	addi	a5,s6,8
 c68:	f8f43423          	sd	a5,-120(s0)
 c6c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 c70:	03000593          	li	a1,48
 c74:	8556                	mv	a0,s5
 c76:	00000097          	auipc	ra,0x0
 c7a:	e14080e7          	jalr	-492(ra) # a8a <putc>
  putc(fd, 'x');
 c7e:	85ea                	mv	a1,s10
 c80:	8556                	mv	a0,s5
 c82:	00000097          	auipc	ra,0x0
 c86:	e08080e7          	jalr	-504(ra) # a8a <putc>
 c8a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 c8c:	03c9d793          	srli	a5,s3,0x3c
 c90:	97de                	add	a5,a5,s7
 c92:	0007c583          	lbu	a1,0(a5)
 c96:	8556                	mv	a0,s5
 c98:	00000097          	auipc	ra,0x0
 c9c:	df2080e7          	jalr	-526(ra) # a8a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 ca0:	0992                	slli	s3,s3,0x4
 ca2:	397d                	addiw	s2,s2,-1
 ca4:	fe0914e3          	bnez	s2,c8c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 ca8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 cac:	4981                	li	s3,0
 cae:	b721                	j	bb6 <vprintf+0x60>
        s = va_arg(ap, char*);
 cb0:	008b0993          	addi	s3,s6,8
 cb4:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 cb8:	02090163          	beqz	s2,cda <vprintf+0x184>
        while(*s != 0){
 cbc:	00094583          	lbu	a1,0(s2)
 cc0:	c9a1                	beqz	a1,d10 <vprintf+0x1ba>
          putc(fd, *s);
 cc2:	8556                	mv	a0,s5
 cc4:	00000097          	auipc	ra,0x0
 cc8:	dc6080e7          	jalr	-570(ra) # a8a <putc>
          s++;
 ccc:	0905                	addi	s2,s2,1
        while(*s != 0){
 cce:	00094583          	lbu	a1,0(s2)
 cd2:	f9e5                	bnez	a1,cc2 <vprintf+0x16c>
        s = va_arg(ap, char*);
 cd4:	8b4e                	mv	s6,s3
      state = 0;
 cd6:	4981                	li	s3,0
 cd8:	bdf9                	j	bb6 <vprintf+0x60>
          s = "(null)";
 cda:	00001917          	auipc	s2,0x1
 cde:	a4690913          	addi	s2,s2,-1466 # 1720 <malloc+0x900>
        while(*s != 0){
 ce2:	02800593          	li	a1,40
 ce6:	bff1                	j	cc2 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 ce8:	008b0913          	addi	s2,s6,8
 cec:	000b4583          	lbu	a1,0(s6)
 cf0:	8556                	mv	a0,s5
 cf2:	00000097          	auipc	ra,0x0
 cf6:	d98080e7          	jalr	-616(ra) # a8a <putc>
 cfa:	8b4a                	mv	s6,s2
      state = 0;
 cfc:	4981                	li	s3,0
 cfe:	bd65                	j	bb6 <vprintf+0x60>
        putc(fd, c);
 d00:	85d2                	mv	a1,s4
 d02:	8556                	mv	a0,s5
 d04:	00000097          	auipc	ra,0x0
 d08:	d86080e7          	jalr	-634(ra) # a8a <putc>
      state = 0;
 d0c:	4981                	li	s3,0
 d0e:	b565                	j	bb6 <vprintf+0x60>
        s = va_arg(ap, char*);
 d10:	8b4e                	mv	s6,s3
      state = 0;
 d12:	4981                	li	s3,0
 d14:	b54d                	j	bb6 <vprintf+0x60>
    }
  }
}
 d16:	70e6                	ld	ra,120(sp)
 d18:	7446                	ld	s0,112(sp)
 d1a:	74a6                	ld	s1,104(sp)
 d1c:	7906                	ld	s2,96(sp)
 d1e:	69e6                	ld	s3,88(sp)
 d20:	6a46                	ld	s4,80(sp)
 d22:	6aa6                	ld	s5,72(sp)
 d24:	6b06                	ld	s6,64(sp)
 d26:	7be2                	ld	s7,56(sp)
 d28:	7c42                	ld	s8,48(sp)
 d2a:	7ca2                	ld	s9,40(sp)
 d2c:	7d02                	ld	s10,32(sp)
 d2e:	6de2                	ld	s11,24(sp)
 d30:	6109                	addi	sp,sp,128
 d32:	8082                	ret

0000000000000d34 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 d34:	715d                	addi	sp,sp,-80
 d36:	ec06                	sd	ra,24(sp)
 d38:	e822                	sd	s0,16(sp)
 d3a:	1000                	addi	s0,sp,32
 d3c:	e010                	sd	a2,0(s0)
 d3e:	e414                	sd	a3,8(s0)
 d40:	e818                	sd	a4,16(s0)
 d42:	ec1c                	sd	a5,24(s0)
 d44:	03043023          	sd	a6,32(s0)
 d48:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 d4c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 d50:	8622                	mv	a2,s0
 d52:	00000097          	auipc	ra,0x0
 d56:	e04080e7          	jalr	-508(ra) # b56 <vprintf>
}
 d5a:	60e2                	ld	ra,24(sp)
 d5c:	6442                	ld	s0,16(sp)
 d5e:	6161                	addi	sp,sp,80
 d60:	8082                	ret

0000000000000d62 <printf>:

void
printf(const char *fmt, ...)
{
 d62:	711d                	addi	sp,sp,-96
 d64:	ec06                	sd	ra,24(sp)
 d66:	e822                	sd	s0,16(sp)
 d68:	1000                	addi	s0,sp,32
 d6a:	e40c                	sd	a1,8(s0)
 d6c:	e810                	sd	a2,16(s0)
 d6e:	ec14                	sd	a3,24(s0)
 d70:	f018                	sd	a4,32(s0)
 d72:	f41c                	sd	a5,40(s0)
 d74:	03043823          	sd	a6,48(s0)
 d78:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 d7c:	00840613          	addi	a2,s0,8
 d80:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 d84:	85aa                	mv	a1,a0
 d86:	4505                	li	a0,1
 d88:	00000097          	auipc	ra,0x0
 d8c:	dce080e7          	jalr	-562(ra) # b56 <vprintf>
}
 d90:	60e2                	ld	ra,24(sp)
 d92:	6442                	ld	s0,16(sp)
 d94:	6125                	addi	sp,sp,96
 d96:	8082                	ret

0000000000000d98 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 d98:	1141                	addi	sp,sp,-16
 d9a:	e422                	sd	s0,8(sp)
 d9c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 d9e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 da2:	00001797          	auipc	a5,0x1
 da6:	99e7b783          	ld	a5,-1634(a5) # 1740 <freep>
 daa:	a805                	j	dda <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 dac:	4618                	lw	a4,8(a2)
 dae:	9db9                	addw	a1,a1,a4
 db0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 db4:	6398                	ld	a4,0(a5)
 db6:	6318                	ld	a4,0(a4)
 db8:	fee53823          	sd	a4,-16(a0)
 dbc:	a091                	j	e00 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 dbe:	ff852703          	lw	a4,-8(a0)
 dc2:	9e39                	addw	a2,a2,a4
 dc4:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 dc6:	ff053703          	ld	a4,-16(a0)
 dca:	e398                	sd	a4,0(a5)
 dcc:	a099                	j	e12 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 dce:	6398                	ld	a4,0(a5)
 dd0:	00e7e463          	bltu	a5,a4,dd8 <free+0x40>
 dd4:	00e6ea63          	bltu	a3,a4,de8 <free+0x50>
{
 dd8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 dda:	fed7fae3          	bgeu	a5,a3,dce <free+0x36>
 dde:	6398                	ld	a4,0(a5)
 de0:	00e6e463          	bltu	a3,a4,de8 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 de4:	fee7eae3          	bltu	a5,a4,dd8 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 de8:	ff852583          	lw	a1,-8(a0)
 dec:	6390                	ld	a2,0(a5)
 dee:	02059813          	slli	a6,a1,0x20
 df2:	01c85713          	srli	a4,a6,0x1c
 df6:	9736                	add	a4,a4,a3
 df8:	fae60ae3          	beq	a2,a4,dac <free+0x14>
    bp->s.ptr = p->s.ptr;
 dfc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 e00:	4790                	lw	a2,8(a5)
 e02:	02061593          	slli	a1,a2,0x20
 e06:	01c5d713          	srli	a4,a1,0x1c
 e0a:	973e                	add	a4,a4,a5
 e0c:	fae689e3          	beq	a3,a4,dbe <free+0x26>
  } else
    p->s.ptr = bp;
 e10:	e394                	sd	a3,0(a5)
  freep = p;
 e12:	00001717          	auipc	a4,0x1
 e16:	92f73723          	sd	a5,-1746(a4) # 1740 <freep>
}
 e1a:	6422                	ld	s0,8(sp)
 e1c:	0141                	addi	sp,sp,16
 e1e:	8082                	ret

0000000000000e20 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 e20:	7139                	addi	sp,sp,-64
 e22:	fc06                	sd	ra,56(sp)
 e24:	f822                	sd	s0,48(sp)
 e26:	f426                	sd	s1,40(sp)
 e28:	f04a                	sd	s2,32(sp)
 e2a:	ec4e                	sd	s3,24(sp)
 e2c:	e852                	sd	s4,16(sp)
 e2e:	e456                	sd	s5,8(sp)
 e30:	e05a                	sd	s6,0(sp)
 e32:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 e34:	02051493          	slli	s1,a0,0x20
 e38:	9081                	srli	s1,s1,0x20
 e3a:	04bd                	addi	s1,s1,15
 e3c:	8091                	srli	s1,s1,0x4
 e3e:	0014899b          	addiw	s3,s1,1
 e42:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 e44:	00001517          	auipc	a0,0x1
 e48:	8fc53503          	ld	a0,-1796(a0) # 1740 <freep>
 e4c:	c515                	beqz	a0,e78 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e4e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 e50:	4798                	lw	a4,8(a5)
 e52:	02977f63          	bgeu	a4,s1,e90 <malloc+0x70>
 e56:	8a4e                	mv	s4,s3
 e58:	0009871b          	sext.w	a4,s3
 e5c:	6685                	lui	a3,0x1
 e5e:	00d77363          	bgeu	a4,a3,e64 <malloc+0x44>
 e62:	6a05                	lui	s4,0x1
 e64:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 e68:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 e6c:	00001917          	auipc	s2,0x1
 e70:	8d490913          	addi	s2,s2,-1836 # 1740 <freep>
  if(p == (char*)-1)
 e74:	5afd                	li	s5,-1
 e76:	a895                	j	eea <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 e78:	00001797          	auipc	a5,0x1
 e7c:	8d078793          	addi	a5,a5,-1840 # 1748 <base>
 e80:	00001717          	auipc	a4,0x1
 e84:	8cf73023          	sd	a5,-1856(a4) # 1740 <freep>
 e88:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 e8a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 e8e:	b7e1                	j	e56 <malloc+0x36>
      if(p->s.size == nunits)
 e90:	02e48c63          	beq	s1,a4,ec8 <malloc+0xa8>
        p->s.size -= nunits;
 e94:	4137073b          	subw	a4,a4,s3
 e98:	c798                	sw	a4,8(a5)
        p += p->s.size;
 e9a:	02071693          	slli	a3,a4,0x20
 e9e:	01c6d713          	srli	a4,a3,0x1c
 ea2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ea4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 ea8:	00001717          	auipc	a4,0x1
 eac:	88a73c23          	sd	a0,-1896(a4) # 1740 <freep>
      return (void*)(p + 1);
 eb0:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 eb4:	70e2                	ld	ra,56(sp)
 eb6:	7442                	ld	s0,48(sp)
 eb8:	74a2                	ld	s1,40(sp)
 eba:	7902                	ld	s2,32(sp)
 ebc:	69e2                	ld	s3,24(sp)
 ebe:	6a42                	ld	s4,16(sp)
 ec0:	6aa2                	ld	s5,8(sp)
 ec2:	6b02                	ld	s6,0(sp)
 ec4:	6121                	addi	sp,sp,64
 ec6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 ec8:	6398                	ld	a4,0(a5)
 eca:	e118                	sd	a4,0(a0)
 ecc:	bff1                	j	ea8 <malloc+0x88>
  hp->s.size = nu;
 ece:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ed2:	0541                	addi	a0,a0,16
 ed4:	00000097          	auipc	ra,0x0
 ed8:	ec4080e7          	jalr	-316(ra) # d98 <free>
  return freep;
 edc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ee0:	d971                	beqz	a0,eb4 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ee2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ee4:	4798                	lw	a4,8(a5)
 ee6:	fa9775e3          	bgeu	a4,s1,e90 <malloc+0x70>
    if(p == freep)
 eea:	00093703          	ld	a4,0(s2)
 eee:	853e                	mv	a0,a5
 ef0:	fef719e3          	bne	a4,a5,ee2 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 ef4:	8552                	mv	a0,s4
 ef6:	00000097          	auipc	ra,0x0
 efa:	b7c080e7          	jalr	-1156(ra) # a72 <sbrk>
  if(p == (char*)-1)
 efe:	fd5518e3          	bne	a0,s5,ece <malloc+0xae>
        return 0;
 f02:	4501                	li	a0,0
 f04:	bf45                	j	eb4 <malloc+0x94>
