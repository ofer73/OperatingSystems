
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
  14:	fa898993          	addi	s3,s3,-88 # fb8 <malloc+0xea>
    for (int i = 0; i < 22; i++)
  18:	4959                	li	s2,22
        printf("sbrk %d\n",i);
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	00001097          	auipc	ra,0x1
  22:	df2080e7          	jalr	-526(ra) # e10 <printf>
        sbrk(4096);
  26:	6505                	lui	a0,0x1
  28:	00001097          	auipc	ra,0x1
  2c:	af8080e7          	jalr	-1288(ra) # b20 <sbrk>
    for (int i = 0; i < 22; i++)
  30:	2485                	addiw	s1,s1,1
  32:	ff2494e3          	bne	s1,s2,1a <sbark_and_fork+0x1a>
    }
    // notice 6 pages swaped out
    int pid= fork();
  36:	00001097          	auipc	ra,0x1
  3a:	a5a080e7          	jalr	-1446(ra) # a90 <fork>
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
  46:	a5e080e7          	jalr	-1442(ra) # aa0 <wait>
    printf("test: finished test\n");
  4a:	00001517          	auipc	a0,0x1
  4e:	f9e50513          	addi	a0,a0,-98 # fe8 <malloc+0x11a>
  52:	00001097          	auipc	ra,0x1
  56:	dbe080e7          	jalr	-578(ra) # e10 <printf>
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
  6e:	f5e50513          	addi	a0,a0,-162 # fc8 <malloc+0xfa>
  72:	00001097          	auipc	ra,0x1
  76:	d9e080e7          	jalr	-610(ra) # e10 <printf>
        sbrk(4096);
  7a:	6505                	lui	a0,0x1
  7c:	00001097          	auipc	ra,0x1
  80:	aa4080e7          	jalr	-1372(ra) # b20 <sbrk>
        printf("child sbrk neg\n");
  84:	00001517          	auipc	a0,0x1
  88:	f5450513          	addi	a0,a0,-172 # fd8 <malloc+0x10a>
  8c:	00001097          	auipc	ra,0x1
  90:	d84080e7          	jalr	-636(ra) # e10 <printf>
        sbrk(-4096 * 14);
  94:	7549                	lui	a0,0xffff2
  96:	00001097          	auipc	ra,0x1
  9a:	a8a080e7          	jalr	-1398(ra) # b20 <sbrk>
        printf("child sbrk\n");
  9e:	00001517          	auipc	a0,0x1
  a2:	f2a50513          	addi	a0,a0,-214 # fc8 <malloc+0xfa>
  a6:	00001097          	auipc	ra,0x1
  aa:	d6a080e7          	jalr	-662(ra) # e10 <printf>
        sbrk(4096 * 4);
  ae:	6511                	lui	a0,0x4
  b0:	00001097          	auipc	ra,0x1
  b4:	a70080e7          	jalr	-1424(ra) # b20 <sbrk>
        sleep(5);
  b8:	4515                	li	a0,5
  ba:	00001097          	auipc	ra,0x1
  be:	a6e080e7          	jalr	-1426(ra) # b28 <sleep>
        exit(0);
  c2:	4501                	li	a0,0
  c4:	00001097          	auipc	ra,0x1
  c8:	9d4080e7          	jalr	-1580(ra) # a98 <exit>

00000000000000cc <just_a_func>:
int
just_a_func(){
  cc:	1141                	addi	sp,sp,-16
  ce:	e406                	sd	ra,8(sp)
  d0:	e022                	sd	s0,0(sp)
  d2:	0800                	addi	s0,sp,16
    printf("func\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	f2c50513          	addi	a0,a0,-212 # 1000 <malloc+0x132>
  dc:	00001097          	auipc	ra,0x1
  e0:	d34080e7          	jalr	-716(ra) # e10 <printf>
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
 100:	f0c50513          	addi	a0,a0,-244 # 1008 <malloc+0x13a>
 104:	00001097          	auipc	ra,0x1
 108:	d0c080e7          	jalr	-756(ra) # e10 <printf>
    printf( "-------------allocating 16 pages-----------------\n");
 10c:	00001517          	auipc	a0,0x1
 110:	f3450513          	addi	a0,a0,-204 # 1040 <malloc+0x172>
 114:	00001097          	auipc	ra,0x1
 118:	cfc080e7          	jalr	-772(ra) # e10 <printf>
    if(fork() == 0){
 11c:	00001097          	auipc	ra,0x1
 120:	974080e7          	jalr	-1676(ra) # a90 <fork>
 124:	cd09                	beqz	a0,13e <fork_SCFIFO+0x50>
        printf("---------passed scifo test!!!!----------\n");
        gets(in,3);
        exit(0);

    }
    wait(0);
 126:	4501                	li	a0,0
 128:	00001097          	auipc	ra,0x1
 12c:	978080e7          	jalr	-1672(ra) # aa0 <wait>
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
 14c:	9d8080e7          	jalr	-1576(ra) # b20 <sbrk>
 150:	00a93023          	sd	a0,0(s2)
            *pages[i] = i;
 154:	c104                	sw	s1,0(a0)
        for(int i = 0; i < 16; i++){
 156:	2485                	addiw	s1,s1,1
 158:	0921                	addi	s2,s2,8
 15a:	ff3496e3          	bne	s1,s3,146 <fork_SCFIFO+0x58>
        printf( "-------------now add another page. page[0] should move to the file-----------------\n");
 15e:	00001517          	auipc	a0,0x1
 162:	f1a50513          	addi	a0,a0,-230 # 1078 <malloc+0x1aa>
 166:	00001097          	auipc	ra,0x1
 16a:	caa080e7          	jalr	-854(ra) # e10 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 16e:	6505                	lui	a0,0x1
 170:	00001097          	auipc	ra,0x1
 174:	9b0080e7          	jalr	-1616(ra) # b20 <sbrk>
        printf( "-------------now access to pages[1]-----------------\n");
 178:	00001517          	auipc	a0,0x1
 17c:	f5850513          	addi	a0,a0,-168 # 10d0 <malloc+0x202>
 180:	00001097          	auipc	ra,0x1
 184:	c90080e7          	jalr	-880(ra) # e10 <printf>
        printf("pages[1] contains  %d\n",*pages[1]);
 188:	f4043783          	ld	a5,-192(s0)
 18c:	438c                	lw	a1,0(a5)
 18e:	00001517          	auipc	a0,0x1
 192:	f7a50513          	addi	a0,a0,-134 # 1108 <malloc+0x23a>
 196:	00001097          	auipc	ra,0x1
 19a:	c7a080e7          	jalr	-902(ra) # e10 <printf>
        printf( "-------------now add another page. page[2] should move to the file-----------------\n");
 19e:	00001517          	auipc	a0,0x1
 1a2:	f8250513          	addi	a0,a0,-126 # 1120 <malloc+0x252>
 1a6:	00001097          	auipc	ra,0x1
 1aa:	c6a080e7          	jalr	-918(ra) # e10 <printf>
        pages[17] = (int*)sbrk(PGSIZE);
 1ae:	6505                	lui	a0,0x1
 1b0:	00001097          	auipc	ra,0x1
 1b4:	970080e7          	jalr	-1680(ra) # b20 <sbrk>
        printf( "-------------now acess to page[2] should cause pagefault-----------------\n");
 1b8:	00001517          	auipc	a0,0x1
 1bc:	fc050513          	addi	a0,a0,-64 # 1178 <malloc+0x2aa>
 1c0:	00001097          	auipc	ra,0x1
 1c4:	c50080e7          	jalr	-944(ra) # e10 <printf>
        printf("pages[2] contains  %d\n",*pages[2]);
 1c8:	f4843783          	ld	a5,-184(s0)
 1cc:	438c                	lw	a1,0(a5)
 1ce:	00001517          	auipc	a0,0x1
 1d2:	ffa50513          	addi	a0,a0,-6 # 11c8 <malloc+0x2fa>
 1d6:	00001097          	auipc	ra,0x1
 1da:	c3a080e7          	jalr	-966(ra) # e10 <printf>
        printf("---------passed scifo test!!!!----------\n");
 1de:	00001517          	auipc	a0,0x1
 1e2:	00250513          	addi	a0,a0,2 # 11e0 <malloc+0x312>
 1e6:	00001097          	auipc	ra,0x1
 1ea:	c2a080e7          	jalr	-982(ra) # e10 <printf>
        gets(in,3);
 1ee:	458d                	li	a1,3
 1f0:	fc840513          	addi	a0,s0,-56
 1f4:	00000097          	auipc	ra,0x0
 1f8:	6ee080e7          	jalr	1774(ra) # 8e2 <gets>
        exit(0);
 1fc:	4501                	li	a0,0
 1fe:	00001097          	auipc	ra,0x1
 202:	89a080e7          	jalr	-1894(ra) # a98 <exit>

0000000000000206 <NFUA_test>:

int 
NFUA_test(){
 206:	7131                	addi	sp,sp,-192
 208:	fd06                	sd	ra,184(sp)
 20a:	f922                	sd	s0,176(sp)
 20c:	f526                	sd	s1,168(sp)
 20e:	f14a                	sd	s2,160(sp)
 210:	ed4e                	sd	s3,152(sp)
 212:	e952                	sd	s4,144(sp)
 214:	0180                	addi	s0,sp,192
    int* pages[18];
    ////-----NFU + AGING----------///////////
    printf( "--------------------NFU + AGING:----------------------\n");
 216:	00001517          	auipc	a0,0x1
 21a:	ffa50513          	addi	a0,a0,-6 # 1210 <malloc+0x342>
 21e:	00001097          	auipc	ra,0x1
 222:	bf2080e7          	jalr	-1038(ra) # e10 <printf>
    printf( "-------------allocating 16 pages-----------------\n");
 226:	00001517          	auipc	a0,0x1
 22a:	e1a50513          	addi	a0,a0,-486 # 1040 <malloc+0x172>
 22e:	00001097          	auipc	ra,0x1
 232:	be2080e7          	jalr	-1054(ra) # e10 <printf>
    if(fork() == 0){
 236:	00001097          	auipc	ra,0x1
 23a:	85a080e7          	jalr	-1958(ra) # a90 <fork>
 23e:	cd19                	beqz	a0,25c <NFUA_test+0x56>
        pages[17] = (int*)sbrk(PGSIZE);
        printf("---------finished NFUA test!!!!----------\n");
        exit(0);

    }
    wait(0);
 240:	4501                	li	a0,0
 242:	00001097          	auipc	ra,0x1
 246:	85e080e7          	jalr	-1954(ra) # aa0 <wait>
    return 1;
}
 24a:	4505                	li	a0,1
 24c:	70ea                	ld	ra,184(sp)
 24e:	744a                	ld	s0,176(sp)
 250:	74aa                	ld	s1,168(sp)
 252:	790a                	ld	s2,160(sp)
 254:	69ea                	ld	s3,152(sp)
 256:	6a4a                	ld	s4,144(sp)
 258:	6129                	addi	sp,sp,192
 25a:	8082                	ret
 25c:	84aa                	mv	s1,a0
 25e:	f4040913          	addi	s2,s0,-192
    if(fork() == 0){
 262:	89ca                	mv	s3,s2
        for(int i = 0; i < 16; i++){
 264:	4a41                	li	s4,16
            pages[i] = (int*)sbrk(PGSIZE);
 266:	6505                	lui	a0,0x1
 268:	00001097          	auipc	ra,0x1
 26c:	8b8080e7          	jalr	-1864(ra) # b20 <sbrk>
 270:	00a9b023          	sd	a0,0(s3)
            *pages[i] = i;
 274:	c104                	sw	s1,0(a0)
        for(int i = 0; i < 16; i++){
 276:	2485                	addiw	s1,s1,1
 278:	09a1                	addi	s3,s3,8
 27a:	ff4496e3          	bne	s1,s4,266 <NFUA_test+0x60>
        sleep(20);
 27e:	4551                	li	a0,20
 280:	00001097          	auipc	ra,0x1
 284:	8a8080e7          	jalr	-1880(ra) # b28 <sleep>
        printf("first we will access page 8 %d,\n", *pages[8]);
 288:	f8043483          	ld	s1,-128(s0)
 28c:	408c                	lw	a1,0(s1)
 28e:	00001517          	auipc	a0,0x1
 292:	fba50513          	addi	a0,a0,-70 # 1248 <malloc+0x37a>
 296:	00001097          	auipc	ra,0x1
 29a:	b7a080e7          	jalr	-1158(ra) # e10 <printf>
        sleep(2);
 29e:	4509                	li	a0,2
 2a0:	00001097          	auipc	ra,0x1
 2a4:	888080e7          	jalr	-1912(ra) # b28 <sleep>
        printf( "-------------now access all pages except 8-----------------\n");
 2a8:	00001517          	auipc	a0,0x1
 2ac:	fc850513          	addi	a0,a0,-56 # 1270 <malloc+0x3a2>
 2b0:	00001097          	auipc	ra,0x1
 2b4:	b60080e7          	jalr	-1184(ra) # e10 <printf>
 2b8:	4705                	li	a4,1
 2ba:	4781                	li	a5,0
            if (i!=8)
 2bc:	45a1                	li	a1,8
        for(int i = 0; i < 16; i++){
 2be:	453d                	li	a0,15
 2c0:	a021                	j	2c8 <NFUA_test+0xc2>
 2c2:	2785                	addiw	a5,a5,1
 2c4:	2705                	addiw	a4,a4,1
 2c6:	0921                	addi	s2,s2,8
 2c8:	0007869b          	sext.w	a3,a5
            if (i!=8)
 2cc:	feb68be3          	beq	a3,a1,2c2 <NFUA_test+0xbc>
                *pages[i] = i;
 2d0:	00093603          	ld	a2,0(s2)
 2d4:	c214                	sw	a3,0(a2)
        for(int i = 0; i < 16; i++){
 2d6:	0007069b          	sext.w	a3,a4
 2da:	fed554e3          	bge	a0,a3,2c2 <NFUA_test+0xbc>
        sleep(2);
 2de:	4509                	li	a0,2
 2e0:	00001097          	auipc	ra,0x1
 2e4:	848080e7          	jalr	-1976(ra) # b28 <sleep>
        printf( "------------- creating a new page, page 8 should be paged out -----------------\n");
 2e8:	00001517          	auipc	a0,0x1
 2ec:	fc850513          	addi	a0,a0,-56 # 12b0 <malloc+0x3e2>
 2f0:	00001097          	auipc	ra,0x1
 2f4:	b20080e7          	jalr	-1248(ra) # e10 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 2f8:	6505                	lui	a0,0x1
 2fa:	00001097          	auipc	ra,0x1
 2fe:	826080e7          	jalr	-2010(ra) # b20 <sbrk>
        printf( "------------- accessing page 8 -> should cause pagefault-----------------\n");
 302:	00001517          	auipc	a0,0x1
 306:	00650513          	addi	a0,a0,6 # 1308 <malloc+0x43a>
 30a:	00001097          	auipc	ra,0x1
 30e:	b06080e7          	jalr	-1274(ra) # e10 <printf>
        printf("&page 8= %p contains  %d\n",pages[8],*pages[8]);
 312:	4090                	lw	a2,0(s1)
 314:	85a6                	mv	a1,s1
 316:	00001517          	auipc	a0,0x1
 31a:	04250513          	addi	a0,a0,66 # 1358 <malloc+0x48a>
 31e:	00001097          	auipc	ra,0x1
 322:	af2080e7          	jalr	-1294(ra) # e10 <printf>
        printf("doing another sbrk for senity check  %d\n");
 326:	00001517          	auipc	a0,0x1
 32a:	05250513          	addi	a0,a0,82 # 1378 <malloc+0x4aa>
 32e:	00001097          	auipc	ra,0x1
 332:	ae2080e7          	jalr	-1310(ra) # e10 <printf>
        pages[17] = (int*)sbrk(PGSIZE);
 336:	6505                	lui	a0,0x1
 338:	00000097          	auipc	ra,0x0
 33c:	7e8080e7          	jalr	2024(ra) # b20 <sbrk>
        printf("---------finished NFUA test!!!!----------\n");
 340:	00001517          	auipc	a0,0x1
 344:	06850513          	addi	a0,a0,104 # 13a8 <malloc+0x4da>
 348:	00001097          	auipc	ra,0x1
 34c:	ac8080e7          	jalr	-1336(ra) # e10 <printf>
        exit(0);
 350:	4501                	li	a0,0
 352:	00000097          	auipc	ra,0x0
 356:	746080e7          	jalr	1862(ra) # a98 <exit>

000000000000035a <LAPA_when_all_equal>:

int
LAPA_when_all_equal(){
 35a:	7131                	addi	sp,sp,-192
 35c:	fd06                	sd	ra,184(sp)
 35e:	f922                	sd	s0,176(sp)
 360:	f526                	sd	s1,168(sp)
 362:	f14a                	sd	s2,160(sp)
 364:	ed4e                	sd	s3,152(sp)
 366:	e952                	sd	s4,144(sp)
 368:	0180                	addi	s0,sp,192
    int* pages[18];
    printf( "-----------------------------fork_LAPA_when_all_equal-----------------------------\n");
 36a:	00001517          	auipc	a0,0x1
 36e:	06e50513          	addi	a0,a0,110 # 13d8 <malloc+0x50a>
 372:	00001097          	auipc	ra,0x1
 376:	a9e080e7          	jalr	-1378(ra) # e10 <printf>
    if(fork() == 0){
 37a:	00000097          	auipc	ra,0x0
 37e:	716080e7          	jalr	1814(ra) # a90 <fork>
 382:	cd11                	beqz	a0,39e <LAPA_when_all_equal+0x44>
        printf("---finished LAPA_when_all_equal---\n");

        exit(0);

    }
    wait(0);
 384:	4501                	li	a0,0
 386:	00000097          	auipc	ra,0x0
 38a:	71a080e7          	jalr	1818(ra) # aa0 <wait>
}
 38e:	70ea                	ld	ra,184(sp)
 390:	744a                	ld	s0,176(sp)
 392:	74aa                	ld	s1,168(sp)
 394:	790a                	ld	s2,160(sp)
 396:	69ea                	ld	s3,152(sp)
 398:	6a4a                	ld	s4,144(sp)
 39a:	6129                	addi	sp,sp,192
 39c:	8082                	ret
 39e:	84aa                	mv	s1,a0
        printf( "---------allocating and modifing 16 pages-----------\n");
 3a0:	00001517          	auipc	a0,0x1
 3a4:	09050513          	addi	a0,a0,144 # 1430 <malloc+0x562>
 3a8:	00001097          	auipc	ra,0x1
 3ac:	a68080e7          	jalr	-1432(ra) # e10 <printf>
        for(int i = 0; i < 16; i++){
 3b0:	f4040913          	addi	s2,s0,-192
        printf( "---------allocating and modifing 16 pages-----------\n");
 3b4:	89ca                	mv	s3,s2
        for(int i = 0; i < 16; i++){
 3b6:	4a41                	li	s4,16
            pages[i] = (int*)sbrk(PGSIZE);
 3b8:	6505                	lui	a0,0x1
 3ba:	00000097          	auipc	ra,0x0
 3be:	766080e7          	jalr	1894(ra) # b20 <sbrk>
 3c2:	00a9b023          	sd	a0,0(s3)
            *pages[i] = i;
 3c6:	c104                	sw	s1,0(a0)
        for(int i = 0; i < 16; i++){
 3c8:	2485                	addiw	s1,s1,1
 3ca:	09a1                	addi	s3,s3,8
 3cc:	ff4496e3          	bne	s1,s4,3b8 <LAPA_when_all_equal+0x5e>
        sleep(20); // we want to zero all aging counters 
 3d0:	4551                	li	a0,20
 3d2:	00000097          	auipc	ra,0x0
 3d6:	756080e7          	jalr	1878(ra) # b28 <sleep>
        printf( "----------accessing all pages, starts with page[8]-------------\n");
 3da:	00001517          	auipc	a0,0x1
 3de:	08e50513          	addi	a0,a0,142 # 1468 <malloc+0x59a>
 3e2:	00001097          	auipc	ra,0x1
 3e6:	a2e080e7          	jalr	-1490(ra) # e10 <printf>
        *pages[8] = 8;
 3ea:	f8043483          	ld	s1,-128(s0)
 3ee:	47a1                	li	a5,8
 3f0:	c09c                	sw	a5,0(s1)
        sleep(10);
 3f2:	4529                	li	a0,10
 3f4:	00000097          	auipc	ra,0x0
 3f8:	734080e7          	jalr	1844(ra) # b28 <sleep>
 3fc:	4705                	li	a4,1
 3fe:	4781                	li	a5,0
            if (i!=8)
 400:	45a1                	li	a1,8
        for(int i = 0; i < 16; i++){
 402:	453d                	li	a0,15
 404:	a021                	j	40c <LAPA_when_all_equal+0xb2>
 406:	2785                	addiw	a5,a5,1
 408:	2705                	addiw	a4,a4,1
 40a:	0921                	addi	s2,s2,8
 40c:	0007869b          	sext.w	a3,a5
            if (i!=8)
 410:	feb68be3          	beq	a3,a1,406 <LAPA_when_all_equal+0xac>
                *pages[i] = i;
 414:	00093603          	ld	a2,0(s2)
 418:	c214                	sw	a3,0(a2)
        for(int i = 0; i < 16; i++){
 41a:	0007069b          	sext.w	a3,a4
 41e:	fed554e3          	bge	a0,a3,406 <LAPA_when_all_equal+0xac>
        sleep(5);
 422:	4515                	li	a0,5
 424:	00000097          	auipc	ra,0x0
 428:	704080e7          	jalr	1796(ra) # b28 <sleep>
        printf( "-------create new page, page 8 need to swapout-----------\n");
 42c:	00001517          	auipc	a0,0x1
 430:	08450513          	addi	a0,a0,132 # 14b0 <malloc+0x5e2>
 434:	00001097          	auipc	ra,0x1
 438:	9dc080e7          	jalr	-1572(ra) # e10 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 43c:	6505                	lui	a0,0x1
 43e:	00000097          	auipc	ra,0x0
 442:	6e2080e7          	jalr	1762(ra) # b20 <sbrk>
        printf( "--------access page 8 shuld cause pagefault---------\n");
 446:	00001517          	auipc	a0,0x1
 44a:	0aa50513          	addi	a0,a0,170 # 14f0 <malloc+0x622>
 44e:	00001097          	auipc	ra,0x1
 452:	9c2080e7          	jalr	-1598(ra) # e10 <printf>
        printf("page 8 value =  %d\n",*pages[8]);
 456:	408c                	lw	a1,0(s1)
 458:	00001517          	auipc	a0,0x1
 45c:	0d050513          	addi	a0,a0,208 # 1528 <malloc+0x65a>
 460:	00001097          	auipc	ra,0x1
 464:	9b0080e7          	jalr	-1616(ra) # e10 <printf>
        printf("---finished LAPA_when_all_equal---\n");
 468:	00001517          	auipc	a0,0x1
 46c:	0d850513          	addi	a0,a0,216 # 1540 <malloc+0x672>
 470:	00001097          	auipc	ra,0x1
 474:	9a0080e7          	jalr	-1632(ra) # e10 <printf>
        exit(0);
 478:	4501                	li	a0,0
 47a:	00000097          	auipc	ra,0x0
 47e:	61e080e7          	jalr	1566(ra) # a98 <exit>

0000000000000482 <LAPA_paging>:

int
LAPA_paging(){
 482:	7131                	addi	sp,sp,-192
 484:	fd06                	sd	ra,184(sp)
 486:	f922                	sd	s0,176(sp)
 488:	f526                	sd	s1,168(sp)
 48a:	f14a                	sd	s2,160(sp)
 48c:	ed4e                	sd	s3,152(sp)
 48e:	e952                	sd	s4,144(sp)
 490:	0180                	addi	s0,sp,192
    int* pages[18];
    printf( "--------------------LAPA_paging--------------------\n");
 492:	00001517          	auipc	a0,0x1
 496:	0d650513          	addi	a0,a0,214 # 1568 <malloc+0x69a>
 49a:	00001097          	auipc	ra,0x1
 49e:	976080e7          	jalr	-1674(ra) # e10 <printf>
    printf( "-------------allocating and modifing 16 pages-----------------\n");
 4a2:	00001517          	auipc	a0,0x1
 4a6:	0fe50513          	addi	a0,a0,254 # 15a0 <malloc+0x6d2>
 4aa:	00001097          	auipc	ra,0x1
 4ae:	966080e7          	jalr	-1690(ra) # e10 <printf>
    if(fork() == 0){
 4b2:	00000097          	auipc	ra,0x0
 4b6:	5de080e7          	jalr	1502(ra) # a90 <fork>
 4ba:	cd11                	beqz	a0,4d6 <LAPA_paging+0x54>
        printf("pages[8] contains  %d\n",*pages[8]);
        printf("-----finish LAPA_paging-----\n");
        exit(0);

    }
    wait(0);
 4bc:	4501                	li	a0,0
 4be:	00000097          	auipc	ra,0x0
 4c2:	5e2080e7          	jalr	1506(ra) # aa0 <wait>
}
 4c6:	70ea                	ld	ra,184(sp)
 4c8:	744a                	ld	s0,176(sp)
 4ca:	74aa                	ld	s1,168(sp)
 4cc:	790a                	ld	s2,160(sp)
 4ce:	69ea                	ld	s3,152(sp)
 4d0:	6a4a                	ld	s4,144(sp)
 4d2:	6129                	addi	sp,sp,192
 4d4:	8082                	ret
 4d6:	84aa                	mv	s1,a0
 4d8:	f4040913          	addi	s2,s0,-192
    if(fork() == 0){
 4dc:	89ca                	mv	s3,s2
        for(int i = 0; i < 16; i++){
 4de:	4a41                	li	s4,16
            pages[i] = (int*)sbrk(PGSIZE);
 4e0:	6505                	lui	a0,0x1
 4e2:	00000097          	auipc	ra,0x0
 4e6:	63e080e7          	jalr	1598(ra) # b20 <sbrk>
 4ea:	00a9b023          	sd	a0,0(s3)
            *pages[i] = i;
 4ee:	c104                	sw	s1,0(a0)
        for(int i = 0; i < 16; i++){
 4f0:	2485                	addiw	s1,s1,1
 4f2:	09a1                	addi	s3,s3,8
 4f4:	ff4496e3          	bne	s1,s4,4e0 <LAPA_paging+0x5e>
        sleep(20); // we want to zero all aging counters
 4f8:	4551                	li	a0,20
 4fa:	00000097          	auipc	ra,0x0
 4fe:	62e080e7          	jalr	1582(ra) # b28 <sleep>
        printf( "--------modifing each page 2 times except pages[8]-----------------\n");
 502:	00001517          	auipc	a0,0x1
 506:	0de50513          	addi	a0,a0,222 # 15e0 <malloc+0x712>
 50a:	00001097          	auipc	ra,0x1
 50e:	906080e7          	jalr	-1786(ra) # e10 <printf>
 512:	86ca                	mv	a3,s2
 514:	4705                	li	a4,1
 516:	4781                	li	a5,0
                if (i!=8)
 518:	4521                	li	a0,8
            for(int i = 0; i < 16; i++){
 51a:	483d                	li	a6,15
 51c:	a021                	j	524 <LAPA_paging+0xa2>
 51e:	2785                	addiw	a5,a5,1
 520:	2705                	addiw	a4,a4,1
 522:	06a1                	addi	a3,a3,8
 524:	0007861b          	sext.w	a2,a5
                if (i!=8)
 528:	fea60be3          	beq	a2,a0,51e <LAPA_paging+0x9c>
                    *pages[i] = i;
 52c:	628c                	ld	a1,0(a3)
 52e:	c190                	sw	a2,0(a1)
            for(int i = 0; i < 16; i++){
 530:	0007061b          	sext.w	a2,a4
 534:	fec855e3          	bge	a6,a2,51e <LAPA_paging+0x9c>
            sleep(1);// to update the aging counter once
 538:	4505                	li	a0,1
 53a:	00000097          	auipc	ra,0x0
 53e:	5ee080e7          	jalr	1518(ra) # b28 <sleep>
 542:	4705                	li	a4,1
 544:	4781                	li	a5,0
                if (i!=8)
 546:	45a1                	li	a1,8
            for(int i = 0; i < 16; i++){
 548:	453d                	li	a0,15
 54a:	a021                	j	552 <LAPA_paging+0xd0>
 54c:	2785                	addiw	a5,a5,1
 54e:	2705                	addiw	a4,a4,1
 550:	0921                	addi	s2,s2,8
 552:	0007869b          	sext.w	a3,a5
                if (i!=8)
 556:	feb68be3          	beq	a3,a1,54c <LAPA_paging+0xca>
                    *pages[i] = i;
 55a:	00093603          	ld	a2,0(s2)
 55e:	c214                	sw	a3,0(a2)
            for(int i = 0; i < 16; i++){
 560:	0007069b          	sext.w	a3,a4
 564:	fed554e3          	bge	a0,a3,54c <LAPA_paging+0xca>
            sleep(1);// to update the aging counter once
 568:	4505                	li	a0,1
 56a:	00000097          	auipc	ra,0x0
 56e:	5be080e7          	jalr	1470(ra) # b28 <sleep>
        printf( "--------modifing page 8 once----------\n");
 572:	00001517          	auipc	a0,0x1
 576:	0b650513          	addi	a0,a0,182 # 1628 <malloc+0x75a>
 57a:	00001097          	auipc	ra,0x1
 57e:	896080e7          	jalr	-1898(ra) # e10 <printf>
        *pages[8] = 8;
 582:	f8043483          	ld	s1,-128(s0)
 586:	47a1                	li	a5,8
 588:	c09c                	sw	a5,0(s1)
        printf( "-----create new page-> page 8 need to swapout------\n");
 58a:	00001517          	auipc	a0,0x1
 58e:	0c650513          	addi	a0,a0,198 # 1650 <malloc+0x782>
 592:	00001097          	auipc	ra,0x1
 596:	87e080e7          	jalr	-1922(ra) # e10 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 59a:	6505                	lui	a0,0x1
 59c:	00000097          	auipc	ra,0x0
 5a0:	584080e7          	jalr	1412(ra) # b20 <sbrk>
        printf( "-------access page 8 need to cause pagefault-------\n");
 5a4:	00001517          	auipc	a0,0x1
 5a8:	0e450513          	addi	a0,a0,228 # 1688 <malloc+0x7ba>
 5ac:	00001097          	auipc	ra,0x1
 5b0:	864080e7          	jalr	-1948(ra) # e10 <printf>
        printf("pages[8] contains  %d\n",*pages[8]);
 5b4:	408c                	lw	a1,0(s1)
 5b6:	00001517          	auipc	a0,0x1
 5ba:	10a50513          	addi	a0,a0,266 # 16c0 <malloc+0x7f2>
 5be:	00001097          	auipc	ra,0x1
 5c2:	852080e7          	jalr	-1966(ra) # e10 <printf>
        printf("-----finish LAPA_paging-----\n");
 5c6:	00001517          	auipc	a0,0x1
 5ca:	11250513          	addi	a0,a0,274 # 16d8 <malloc+0x80a>
 5ce:	00001097          	auipc	ra,0x1
 5d2:	842080e7          	jalr	-1982(ra) # e10 <printf>
        exit(0);
 5d6:	4501                	li	a0,0
 5d8:	00000097          	auipc	ra,0x0
 5dc:	4c0080e7          	jalr	1216(ra) # a98 <exit>

00000000000005e0 <LAPA_test_fork_copy>:

int
LAPA_test_fork_copy(){
 5e0:	7155                	addi	sp,sp,-208
 5e2:	e586                	sd	ra,200(sp)
 5e4:	e1a2                	sd	s0,192(sp)
 5e6:	fd26                	sd	s1,184(sp)
 5e8:	f94a                	sd	s2,176(sp)
 5ea:	f54e                	sd	s3,168(sp)
 5ec:	f152                	sd	s4,160(sp)
 5ee:	ed56                	sd	s5,152(sp)
 5f0:	0980                	addi	s0,sp,208
    int* pages[18];
    printf( "--------------------LAPA 3 : FORK test:----------------------\n");
 5f2:	00001517          	auipc	a0,0x1
 5f6:	10650513          	addi	a0,a0,262 # 16f8 <malloc+0x82a>
 5fa:	00001097          	auipc	ra,0x1
 5fe:	816080e7          	jalr	-2026(ra) # e10 <printf>
    printf( "-------------allocating 16 pages for father-----------------\n");
 602:	00001517          	auipc	a0,0x1
 606:	13650513          	addi	a0,a0,310 # 1738 <malloc+0x86a>
 60a:	00001097          	auipc	ra,0x1
 60e:	806080e7          	jalr	-2042(ra) # e10 <printf>
 612:	f3040913          	addi	s2,s0,-208
    for(int i = 0; i < 16; i++){
 616:	4481                	li	s1,0
 618:	49c1                	li	s3,16
            pages[i] = (int*)sbrk(PGSIZE);
 61a:	6505                	lui	a0,0x1
 61c:	00000097          	auipc	ra,0x0
 620:	504080e7          	jalr	1284(ra) # b20 <sbrk>
 624:	00a93023          	sd	a0,0(s2)
            *pages[i] = i;
 628:	c104                	sw	s1,0(a0)
    for(int i = 0; i < 16; i++){
 62a:	2485                	addiw	s1,s1,1
 62c:	0921                	addi	s2,s2,8
 62e:	ff3496e3          	bne	s1,s3,61a <LAPA_test_fork_copy+0x3a>
        }
    sleep(20);
 632:	4551                	li	a0,20
 634:	00000097          	auipc	ra,0x0
 638:	4f4080e7          	jalr	1268(ra) # b28 <sleep>
    printf( "------------- accessing all pages 3 times except page 8-----------------\n");
 63c:	00001517          	auipc	a0,0x1
 640:	13c50513          	addi	a0,a0,316 # 1778 <malloc+0x8aa>
 644:	00000097          	auipc	ra,0x0
 648:	7cc080e7          	jalr	1996(ra) # e10 <printf>
 64c:	498d                	li	s3,3
    for(int i = 0; i < 16; i++){
 64e:	4a05                	li	s4,1
 650:	4a81                	li	s5,0
        for(int j=0;j<3;j++){
            for(int i = 0; i < 16; i++){
                if (i!=8)
 652:	44a1                	li	s1,8
            for(int i = 0; i < 16; i++){
 654:	493d                	li	s2,15
 656:	a035                	j	682 <LAPA_test_fork_copy+0xa2>
 658:	2785                	addiw	a5,a5,1
 65a:	2685                	addiw	a3,a3,1
 65c:	0621                	addi	a2,a2,8
 65e:	0007871b          	sext.w	a4,a5
                if (i!=8)
 662:	fe970be3          	beq	a4,s1,658 <LAPA_test_fork_copy+0x78>
                    *pages[i] = i;
 666:	620c                	ld	a1,0(a2)
 668:	c198                	sw	a4,0(a1)
            for(int i = 0; i < 16; i++){
 66a:	0006871b          	sext.w	a4,a3
 66e:	fee955e3          	bge	s2,a4,658 <LAPA_test_fork_copy+0x78>
            }
            sleep(1);
 672:	8552                	mv	a0,s4
 674:	00000097          	auipc	ra,0x0
 678:	4b4080e7          	jalr	1204(ra) # b28 <sleep>
        for(int j=0;j<3;j++){
 67c:	39fd                	addiw	s3,s3,-1
 67e:	00098763          	beqz	s3,68c <LAPA_test_fork_copy+0xac>
    for(int i = 0; i < 16; i++){
 682:	f3040613          	addi	a2,s0,-208
 686:	86d2                	mv	a3,s4
 688:	87d6                	mv	a5,s5
 68a:	bfd1                	j	65e <LAPA_test_fork_copy+0x7e>
        }

        printf( "-------------now access pages 8 only twice-----------------\n");
 68c:	00001517          	auipc	a0,0x1
 690:	13c50513          	addi	a0,a0,316 # 17c8 <malloc+0x8fa>
 694:	00000097          	auipc	ra,0x0
 698:	77c080e7          	jalr	1916(ra) # e10 <printf>
        *pages[8] = 8;
 69c:	f7043483          	ld	s1,-144(s0)
 6a0:	47a1                	li	a5,8
 6a2:	c09c                	sw	a5,0(s1)
        *pages[8] = 8;
        sleep(1);
 6a4:	4505                	li	a0,1
 6a6:	00000097          	auipc	ra,0x0
 6aa:	482080e7          	jalr	1154(ra) # b28 <sleep>
    if(fork() == 0){
 6ae:	00000097          	auipc	ra,0x0
 6b2:	3e2080e7          	jalr	994(ra) # a90 <fork>
 6b6:	c52d                	beqz	a0,720 <LAPA_test_fork_copy+0x140>
        printf( "-------------Son: now acess to page 8 should cause pagefault-----------------\n");
        printf("page 8 contains  %d\n",*pages[8]);
        exit(0);
    }

    wait(0);
 6b8:	4501                	li	a0,0
 6ba:	00000097          	auipc	ra,0x0
 6be:	3e6080e7          	jalr	998(ra) # aa0 <wait>
    printf( "-------------Father: create a new page, page 8 should be paged out-----------------\n");
 6c2:	00001517          	auipc	a0,0x1
 6c6:	20650513          	addi	a0,a0,518 # 18c8 <malloc+0x9fa>
 6ca:	00000097          	auipc	ra,0x0
 6ce:	746080e7          	jalr	1862(ra) # e10 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 6d2:	6505                	lui	a0,0x1
 6d4:	00000097          	auipc	ra,0x0
 6d8:	44c080e7          	jalr	1100(ra) # b20 <sbrk>
        
        printf( "-------------Father: now acess to page 8 should cause pagefault-----------------\n");
 6dc:	00001517          	auipc	a0,0x1
 6e0:	24450513          	addi	a0,a0,580 # 1920 <malloc+0xa52>
 6e4:	00000097          	auipc	ra,0x0
 6e8:	72c080e7          	jalr	1836(ra) # e10 <printf>
        printf("page 8 contains : %d",*pages[8]);
 6ec:	408c                	lw	a1,0(s1)
 6ee:	00001517          	auipc	a0,0x1
 6f2:	28a50513          	addi	a0,a0,650 # 1978 <malloc+0xaaa>
 6f6:	00000097          	auipc	ra,0x0
 6fa:	71a080e7          	jalr	1818(ra) # e10 <printf>
        
    printf("---------finished LAPA_test_fork_copy test!!!!----------\n");
 6fe:	00001517          	auipc	a0,0x1
 702:	29250513          	addi	a0,a0,658 # 1990 <malloc+0xac2>
 706:	00000097          	auipc	ra,0x0
 70a:	70a080e7          	jalr	1802(ra) # e10 <printf>
}
 70e:	60ae                	ld	ra,200(sp)
 710:	640e                	ld	s0,192(sp)
 712:	74ea                	ld	s1,184(sp)
 714:	794a                	ld	s2,176(sp)
 716:	79aa                	ld	s3,168(sp)
 718:	7a0a                	ld	s4,160(sp)
 71a:	6aea                	ld	s5,152(sp)
 71c:	6169                	addi	sp,sp,208
 71e:	8082                	ret
        printf( "-------------Son: create a new page, page 8 should be paged out-----------------\n");
 720:	00001517          	auipc	a0,0x1
 724:	0e850513          	addi	a0,a0,232 # 1808 <malloc+0x93a>
 728:	00000097          	auipc	ra,0x0
 72c:	6e8080e7          	jalr	1768(ra) # e10 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 730:	6505                	lui	a0,0x1
 732:	00000097          	auipc	ra,0x0
 736:	3ee080e7          	jalr	1006(ra) # b20 <sbrk>
        printf( "-------------Son: now acess to page 8 should cause pagefault-----------------\n");
 73a:	00001517          	auipc	a0,0x1
 73e:	12650513          	addi	a0,a0,294 # 1860 <malloc+0x992>
 742:	00000097          	auipc	ra,0x0
 746:	6ce080e7          	jalr	1742(ra) # e10 <printf>
        printf("page 8 contains  %d\n",*pages[8]);
 74a:	408c                	lw	a1,0(s1)
 74c:	00001517          	auipc	a0,0x1
 750:	16450513          	addi	a0,a0,356 # 18b0 <malloc+0x9e2>
 754:	00000097          	auipc	ra,0x0
 758:	6bc080e7          	jalr	1724(ra) # e10 <printf>
        exit(0);
 75c:	4501                	li	a0,0
 75e:	00000097          	auipc	ra,0x0
 762:	33a080e7          	jalr	826(ra) # a98 <exit>

0000000000000766 <fork_test>:

int 
fork_test(){
 766:	1101                	addi	sp,sp,-32
 768:	ec06                	sd	ra,24(sp)
 76a:	e822                	sd	s0,16(sp)
 76c:	1000                	addi	s0,sp,32
    #ifdef NFUA
    return NFUA_test();
    #endif

    #ifdef LAPA
    LAPA_paging();
 76e:	00000097          	auipc	ra,0x0
 772:	d14080e7          	jalr	-748(ra) # 482 <LAPA_paging>
    gets(wait,3);
 776:	458d                	li	a1,3
 778:	fe840513          	addi	a0,s0,-24
 77c:	00000097          	auipc	ra,0x0
 780:	166080e7          	jalr	358(ra) # 8e2 <gets>
    LAPA_when_all_equal();
 784:	00000097          	auipc	ra,0x0
 788:	bd6080e7          	jalr	-1066(ra) # 35a <LAPA_when_all_equal>
    gets(wait,3);
 78c:	458d                	li	a1,3
 78e:	fe840513          	addi	a0,s0,-24
 792:	00000097          	auipc	ra,0x0
 796:	150080e7          	jalr	336(ra) # 8e2 <gets>
    return LAPA_test_fork_copy();
 79a:	00000097          	auipc	ra,0x0
 79e:	e46080e7          	jalr	-442(ra) # 5e0 <LAPA_test_fork_copy>
    #endif
    return -1;
    
}
 7a2:	60e2                	ld	ra,24(sp)
 7a4:	6442                	ld	s0,16(sp)
 7a6:	6105                	addi	sp,sp,32
 7a8:	8082                	ret

00000000000007aa <malloc_and_free>:

int malloc_and_free(){
 7aa:	1101                	addi	sp,sp,-32
 7ac:	ec06                	sd	ra,24(sp)
 7ae:	e822                	sd	s0,16(sp)
 7b0:	e426                	sd	s1,8(sp)
 7b2:	1000                	addi	s0,sp,32
    printf("-----------------------------malloc--------\n");
 7b4:	00001517          	auipc	a0,0x1
 7b8:	21c50513          	addi	a0,a0,540 # 19d0 <malloc+0xb02>
 7bc:	00000097          	auipc	ra,0x0
 7c0:	654080e7          	jalr	1620(ra) # e10 <printf>

    void* a = sbrk(PGSIZE);
 7c4:	6505                	lui	a0,0x1
 7c6:	00000097          	auipc	ra,0x0
 7ca:	35a080e7          	jalr	858(ra) # b20 <sbrk>
 7ce:	84aa                	mv	s1,a0
    void* b = malloc(PGSIZE);
 7d0:	6505                	lui	a0,0x1
 7d2:	00000097          	auipc	ra,0x0
 7d6:	6fc080e7          	jalr	1788(ra) # ece <malloc>

    printf("-----------------------------free--------\n");
 7da:	00001517          	auipc	a0,0x1
 7de:	22650513          	addi	a0,a0,550 # 1a00 <malloc+0xb32>
 7e2:	00000097          	auipc	ra,0x0
 7e6:	62e080e7          	jalr	1582(ra) # e10 <printf>
    free(a);
 7ea:	8526                	mv	a0,s1
 7ec:	00000097          	auipc	ra,0x0
 7f0:	65a080e7          	jalr	1626(ra) # e46 <free>
    return 0;
}
 7f4:	4501                	li	a0,0
 7f6:	60e2                	ld	ra,24(sp)
 7f8:	6442                	ld	s0,16(sp)
 7fa:	64a2                	ld	s1,8(sp)
 7fc:	6105                	addi	sp,sp,32
 7fe:	8082                	ret

0000000000000800 <main>:

int
main(int argc, char *argv[])
{
 800:	1141                	addi	sp,sp,-16
 802:	e406                	sd	ra,8(sp)
 804:	e022                	sd	s0,0(sp)
 806:	0800                	addi	s0,sp,16
    // printf("-----------------------------sbark_and_fork-----------------------------\n");
    // sbark_and_fork();
    // printf("-----------------------------fork_test-----------------------------\n");
    // fork_test();
    printf("-----------------------------malloc_and_free-----------------------------\n");
 808:	00001517          	auipc	a0,0x1
 80c:	22850513          	addi	a0,a0,552 # 1a30 <malloc+0xb62>
 810:	00000097          	auipc	ra,0x0
 814:	600080e7          	jalr	1536(ra) # e10 <printf>
    malloc_and_free();
 818:	00000097          	auipc	ra,0x0
 81c:	f92080e7          	jalr	-110(ra) # 7aa <malloc_and_free>
    exit(0);
 820:	4501                	li	a0,0
 822:	00000097          	auipc	ra,0x0
 826:	276080e7          	jalr	630(ra) # a98 <exit>

000000000000082a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 82a:	1141                	addi	sp,sp,-16
 82c:	e422                	sd	s0,8(sp)
 82e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 830:	87aa                	mv	a5,a0
 832:	0585                	addi	a1,a1,1
 834:	0785                	addi	a5,a5,1
 836:	fff5c703          	lbu	a4,-1(a1)
 83a:	fee78fa3          	sb	a4,-1(a5)
 83e:	fb75                	bnez	a4,832 <strcpy+0x8>
    ;
  return os;
}
 840:	6422                	ld	s0,8(sp)
 842:	0141                	addi	sp,sp,16
 844:	8082                	ret

0000000000000846 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 846:	1141                	addi	sp,sp,-16
 848:	e422                	sd	s0,8(sp)
 84a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 84c:	00054783          	lbu	a5,0(a0)
 850:	cb91                	beqz	a5,864 <strcmp+0x1e>
 852:	0005c703          	lbu	a4,0(a1)
 856:	00f71763          	bne	a4,a5,864 <strcmp+0x1e>
    p++, q++;
 85a:	0505                	addi	a0,a0,1
 85c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 85e:	00054783          	lbu	a5,0(a0)
 862:	fbe5                	bnez	a5,852 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 864:	0005c503          	lbu	a0,0(a1)
}
 868:	40a7853b          	subw	a0,a5,a0
 86c:	6422                	ld	s0,8(sp)
 86e:	0141                	addi	sp,sp,16
 870:	8082                	ret

0000000000000872 <strlen>:

uint
strlen(const char *s)
{
 872:	1141                	addi	sp,sp,-16
 874:	e422                	sd	s0,8(sp)
 876:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 878:	00054783          	lbu	a5,0(a0)
 87c:	cf91                	beqz	a5,898 <strlen+0x26>
 87e:	0505                	addi	a0,a0,1
 880:	87aa                	mv	a5,a0
 882:	4685                	li	a3,1
 884:	9e89                	subw	a3,a3,a0
 886:	00f6853b          	addw	a0,a3,a5
 88a:	0785                	addi	a5,a5,1
 88c:	fff7c703          	lbu	a4,-1(a5)
 890:	fb7d                	bnez	a4,886 <strlen+0x14>
    ;
  return n;
}
 892:	6422                	ld	s0,8(sp)
 894:	0141                	addi	sp,sp,16
 896:	8082                	ret
  for(n = 0; s[n]; n++)
 898:	4501                	li	a0,0
 89a:	bfe5                	j	892 <strlen+0x20>

000000000000089c <memset>:

void*
memset(void *dst, int c, uint n)
{
 89c:	1141                	addi	sp,sp,-16
 89e:	e422                	sd	s0,8(sp)
 8a0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 8a2:	ca19                	beqz	a2,8b8 <memset+0x1c>
 8a4:	87aa                	mv	a5,a0
 8a6:	1602                	slli	a2,a2,0x20
 8a8:	9201                	srli	a2,a2,0x20
 8aa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 8ae:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 8b2:	0785                	addi	a5,a5,1
 8b4:	fee79de3          	bne	a5,a4,8ae <memset+0x12>
  }
  return dst;
}
 8b8:	6422                	ld	s0,8(sp)
 8ba:	0141                	addi	sp,sp,16
 8bc:	8082                	ret

00000000000008be <strchr>:

char*
strchr(const char *s, char c)
{
 8be:	1141                	addi	sp,sp,-16
 8c0:	e422                	sd	s0,8(sp)
 8c2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 8c4:	00054783          	lbu	a5,0(a0)
 8c8:	cb99                	beqz	a5,8de <strchr+0x20>
    if(*s == c)
 8ca:	00f58763          	beq	a1,a5,8d8 <strchr+0x1a>
  for(; *s; s++)
 8ce:	0505                	addi	a0,a0,1
 8d0:	00054783          	lbu	a5,0(a0)
 8d4:	fbfd                	bnez	a5,8ca <strchr+0xc>
      return (char*)s;
  return 0;
 8d6:	4501                	li	a0,0
}
 8d8:	6422                	ld	s0,8(sp)
 8da:	0141                	addi	sp,sp,16
 8dc:	8082                	ret
  return 0;
 8de:	4501                	li	a0,0
 8e0:	bfe5                	j	8d8 <strchr+0x1a>

00000000000008e2 <gets>:

char*
gets(char *buf, int max)
{
 8e2:	711d                	addi	sp,sp,-96
 8e4:	ec86                	sd	ra,88(sp)
 8e6:	e8a2                	sd	s0,80(sp)
 8e8:	e4a6                	sd	s1,72(sp)
 8ea:	e0ca                	sd	s2,64(sp)
 8ec:	fc4e                	sd	s3,56(sp)
 8ee:	f852                	sd	s4,48(sp)
 8f0:	f456                	sd	s5,40(sp)
 8f2:	f05a                	sd	s6,32(sp)
 8f4:	ec5e                	sd	s7,24(sp)
 8f6:	1080                	addi	s0,sp,96
 8f8:	8baa                	mv	s7,a0
 8fa:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 8fc:	892a                	mv	s2,a0
 8fe:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 900:	4aa9                	li	s5,10
 902:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 904:	89a6                	mv	s3,s1
 906:	2485                	addiw	s1,s1,1
 908:	0344d863          	bge	s1,s4,938 <gets+0x56>
    cc = read(0, &c, 1);
 90c:	4605                	li	a2,1
 90e:	faf40593          	addi	a1,s0,-81
 912:	4501                	li	a0,0
 914:	00000097          	auipc	ra,0x0
 918:	19c080e7          	jalr	412(ra) # ab0 <read>
    if(cc < 1)
 91c:	00a05e63          	blez	a0,938 <gets+0x56>
    buf[i++] = c;
 920:	faf44783          	lbu	a5,-81(s0)
 924:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 928:	01578763          	beq	a5,s5,936 <gets+0x54>
 92c:	0905                	addi	s2,s2,1
 92e:	fd679be3          	bne	a5,s6,904 <gets+0x22>
  for(i=0; i+1 < max; ){
 932:	89a6                	mv	s3,s1
 934:	a011                	j	938 <gets+0x56>
 936:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 938:	99de                	add	s3,s3,s7
 93a:	00098023          	sb	zero,0(s3)
  return buf;
}
 93e:	855e                	mv	a0,s7
 940:	60e6                	ld	ra,88(sp)
 942:	6446                	ld	s0,80(sp)
 944:	64a6                	ld	s1,72(sp)
 946:	6906                	ld	s2,64(sp)
 948:	79e2                	ld	s3,56(sp)
 94a:	7a42                	ld	s4,48(sp)
 94c:	7aa2                	ld	s5,40(sp)
 94e:	7b02                	ld	s6,32(sp)
 950:	6be2                	ld	s7,24(sp)
 952:	6125                	addi	sp,sp,96
 954:	8082                	ret

0000000000000956 <stat>:

int
stat(const char *n, struct stat *st)
{
 956:	1101                	addi	sp,sp,-32
 958:	ec06                	sd	ra,24(sp)
 95a:	e822                	sd	s0,16(sp)
 95c:	e426                	sd	s1,8(sp)
 95e:	e04a                	sd	s2,0(sp)
 960:	1000                	addi	s0,sp,32
 962:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 964:	4581                	li	a1,0
 966:	00000097          	auipc	ra,0x0
 96a:	172080e7          	jalr	370(ra) # ad8 <open>
  if(fd < 0)
 96e:	02054563          	bltz	a0,998 <stat+0x42>
 972:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 974:	85ca                	mv	a1,s2
 976:	00000097          	auipc	ra,0x0
 97a:	17a080e7          	jalr	378(ra) # af0 <fstat>
 97e:	892a                	mv	s2,a0
  close(fd);
 980:	8526                	mv	a0,s1
 982:	00000097          	auipc	ra,0x0
 986:	13e080e7          	jalr	318(ra) # ac0 <close>
  return r;
}
 98a:	854a                	mv	a0,s2
 98c:	60e2                	ld	ra,24(sp)
 98e:	6442                	ld	s0,16(sp)
 990:	64a2                	ld	s1,8(sp)
 992:	6902                	ld	s2,0(sp)
 994:	6105                	addi	sp,sp,32
 996:	8082                	ret
    return -1;
 998:	597d                	li	s2,-1
 99a:	bfc5                	j	98a <stat+0x34>

000000000000099c <atoi>:

int
atoi(const char *s)
{
 99c:	1141                	addi	sp,sp,-16
 99e:	e422                	sd	s0,8(sp)
 9a0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 9a2:	00054603          	lbu	a2,0(a0)
 9a6:	fd06079b          	addiw	a5,a2,-48
 9aa:	0ff7f793          	andi	a5,a5,255
 9ae:	4725                	li	a4,9
 9b0:	02f76963          	bltu	a4,a5,9e2 <atoi+0x46>
 9b4:	86aa                	mv	a3,a0
  n = 0;
 9b6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 9b8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 9ba:	0685                	addi	a3,a3,1
 9bc:	0025179b          	slliw	a5,a0,0x2
 9c0:	9fa9                	addw	a5,a5,a0
 9c2:	0017979b          	slliw	a5,a5,0x1
 9c6:	9fb1                	addw	a5,a5,a2
 9c8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 9cc:	0006c603          	lbu	a2,0(a3)
 9d0:	fd06071b          	addiw	a4,a2,-48
 9d4:	0ff77713          	andi	a4,a4,255
 9d8:	fee5f1e3          	bgeu	a1,a4,9ba <atoi+0x1e>
  return n;
}
 9dc:	6422                	ld	s0,8(sp)
 9de:	0141                	addi	sp,sp,16
 9e0:	8082                	ret
  n = 0;
 9e2:	4501                	li	a0,0
 9e4:	bfe5                	j	9dc <atoi+0x40>

00000000000009e6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 9e6:	1141                	addi	sp,sp,-16
 9e8:	e422                	sd	s0,8(sp)
 9ea:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 9ec:	02b57463          	bgeu	a0,a1,a14 <memmove+0x2e>
    while(n-- > 0)
 9f0:	00c05f63          	blez	a2,a0e <memmove+0x28>
 9f4:	1602                	slli	a2,a2,0x20
 9f6:	9201                	srli	a2,a2,0x20
 9f8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 9fc:	872a                	mv	a4,a0
      *dst++ = *src++;
 9fe:	0585                	addi	a1,a1,1
 a00:	0705                	addi	a4,a4,1
 a02:	fff5c683          	lbu	a3,-1(a1)
 a06:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 a0a:	fee79ae3          	bne	a5,a4,9fe <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 a0e:	6422                	ld	s0,8(sp)
 a10:	0141                	addi	sp,sp,16
 a12:	8082                	ret
    dst += n;
 a14:	00c50733          	add	a4,a0,a2
    src += n;
 a18:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 a1a:	fec05ae3          	blez	a2,a0e <memmove+0x28>
 a1e:	fff6079b          	addiw	a5,a2,-1
 a22:	1782                	slli	a5,a5,0x20
 a24:	9381                	srli	a5,a5,0x20
 a26:	fff7c793          	not	a5,a5
 a2a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 a2c:	15fd                	addi	a1,a1,-1
 a2e:	177d                	addi	a4,a4,-1
 a30:	0005c683          	lbu	a3,0(a1)
 a34:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 a38:	fee79ae3          	bne	a5,a4,a2c <memmove+0x46>
 a3c:	bfc9                	j	a0e <memmove+0x28>

0000000000000a3e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 a3e:	1141                	addi	sp,sp,-16
 a40:	e422                	sd	s0,8(sp)
 a42:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 a44:	ca05                	beqz	a2,a74 <memcmp+0x36>
 a46:	fff6069b          	addiw	a3,a2,-1
 a4a:	1682                	slli	a3,a3,0x20
 a4c:	9281                	srli	a3,a3,0x20
 a4e:	0685                	addi	a3,a3,1
 a50:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 a52:	00054783          	lbu	a5,0(a0)
 a56:	0005c703          	lbu	a4,0(a1)
 a5a:	00e79863          	bne	a5,a4,a6a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 a5e:	0505                	addi	a0,a0,1
    p2++;
 a60:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 a62:	fed518e3          	bne	a0,a3,a52 <memcmp+0x14>
  }
  return 0;
 a66:	4501                	li	a0,0
 a68:	a019                	j	a6e <memcmp+0x30>
      return *p1 - *p2;
 a6a:	40e7853b          	subw	a0,a5,a4
}
 a6e:	6422                	ld	s0,8(sp)
 a70:	0141                	addi	sp,sp,16
 a72:	8082                	ret
  return 0;
 a74:	4501                	li	a0,0
 a76:	bfe5                	j	a6e <memcmp+0x30>

0000000000000a78 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 a78:	1141                	addi	sp,sp,-16
 a7a:	e406                	sd	ra,8(sp)
 a7c:	e022                	sd	s0,0(sp)
 a7e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 a80:	00000097          	auipc	ra,0x0
 a84:	f66080e7          	jalr	-154(ra) # 9e6 <memmove>
}
 a88:	60a2                	ld	ra,8(sp)
 a8a:	6402                	ld	s0,0(sp)
 a8c:	0141                	addi	sp,sp,16
 a8e:	8082                	ret

0000000000000a90 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 a90:	4885                	li	a7,1
 ecall
 a92:	00000073          	ecall
 ret
 a96:	8082                	ret

0000000000000a98 <exit>:
.global exit
exit:
 li a7, SYS_exit
 a98:	4889                	li	a7,2
 ecall
 a9a:	00000073          	ecall
 ret
 a9e:	8082                	ret

0000000000000aa0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 aa0:	488d                	li	a7,3
 ecall
 aa2:	00000073          	ecall
 ret
 aa6:	8082                	ret

0000000000000aa8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 aa8:	4891                	li	a7,4
 ecall
 aaa:	00000073          	ecall
 ret
 aae:	8082                	ret

0000000000000ab0 <read>:
.global read
read:
 li a7, SYS_read
 ab0:	4895                	li	a7,5
 ecall
 ab2:	00000073          	ecall
 ret
 ab6:	8082                	ret

0000000000000ab8 <write>:
.global write
write:
 li a7, SYS_write
 ab8:	48c1                	li	a7,16
 ecall
 aba:	00000073          	ecall
 ret
 abe:	8082                	ret

0000000000000ac0 <close>:
.global close
close:
 li a7, SYS_close
 ac0:	48d5                	li	a7,21
 ecall
 ac2:	00000073          	ecall
 ret
 ac6:	8082                	ret

0000000000000ac8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 ac8:	4899                	li	a7,6
 ecall
 aca:	00000073          	ecall
 ret
 ace:	8082                	ret

0000000000000ad0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 ad0:	489d                	li	a7,7
 ecall
 ad2:	00000073          	ecall
 ret
 ad6:	8082                	ret

0000000000000ad8 <open>:
.global open
open:
 li a7, SYS_open
 ad8:	48bd                	li	a7,15
 ecall
 ada:	00000073          	ecall
 ret
 ade:	8082                	ret

0000000000000ae0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 ae0:	48c5                	li	a7,17
 ecall
 ae2:	00000073          	ecall
 ret
 ae6:	8082                	ret

0000000000000ae8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 ae8:	48c9                	li	a7,18
 ecall
 aea:	00000073          	ecall
 ret
 aee:	8082                	ret

0000000000000af0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 af0:	48a1                	li	a7,8
 ecall
 af2:	00000073          	ecall
 ret
 af6:	8082                	ret

0000000000000af8 <link>:
.global link
link:
 li a7, SYS_link
 af8:	48cd                	li	a7,19
 ecall
 afa:	00000073          	ecall
 ret
 afe:	8082                	ret

0000000000000b00 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 b00:	48d1                	li	a7,20
 ecall
 b02:	00000073          	ecall
 ret
 b06:	8082                	ret

0000000000000b08 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 b08:	48a5                	li	a7,9
 ecall
 b0a:	00000073          	ecall
 ret
 b0e:	8082                	ret

0000000000000b10 <dup>:
.global dup
dup:
 li a7, SYS_dup
 b10:	48a9                	li	a7,10
 ecall
 b12:	00000073          	ecall
 ret
 b16:	8082                	ret

0000000000000b18 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 b18:	48ad                	li	a7,11
 ecall
 b1a:	00000073          	ecall
 ret
 b1e:	8082                	ret

0000000000000b20 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 b20:	48b1                	li	a7,12
 ecall
 b22:	00000073          	ecall
 ret
 b26:	8082                	ret

0000000000000b28 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 b28:	48b5                	li	a7,13
 ecall
 b2a:	00000073          	ecall
 ret
 b2e:	8082                	ret

0000000000000b30 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 b30:	48b9                	li	a7,14
 ecall
 b32:	00000073          	ecall
 ret
 b36:	8082                	ret

0000000000000b38 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 b38:	1101                	addi	sp,sp,-32
 b3a:	ec06                	sd	ra,24(sp)
 b3c:	e822                	sd	s0,16(sp)
 b3e:	1000                	addi	s0,sp,32
 b40:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 b44:	4605                	li	a2,1
 b46:	fef40593          	addi	a1,s0,-17
 b4a:	00000097          	auipc	ra,0x0
 b4e:	f6e080e7          	jalr	-146(ra) # ab8 <write>
}
 b52:	60e2                	ld	ra,24(sp)
 b54:	6442                	ld	s0,16(sp)
 b56:	6105                	addi	sp,sp,32
 b58:	8082                	ret

0000000000000b5a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 b5a:	7139                	addi	sp,sp,-64
 b5c:	fc06                	sd	ra,56(sp)
 b5e:	f822                	sd	s0,48(sp)
 b60:	f426                	sd	s1,40(sp)
 b62:	f04a                	sd	s2,32(sp)
 b64:	ec4e                	sd	s3,24(sp)
 b66:	0080                	addi	s0,sp,64
 b68:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 b6a:	c299                	beqz	a3,b70 <printint+0x16>
 b6c:	0805c863          	bltz	a1,bfc <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 b70:	2581                	sext.w	a1,a1
  neg = 0;
 b72:	4881                	li	a7,0
 b74:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 b78:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 b7a:	2601                	sext.w	a2,a2
 b7c:	00001517          	auipc	a0,0x1
 b80:	f0c50513          	addi	a0,a0,-244 # 1a88 <digits>
 b84:	883a                	mv	a6,a4
 b86:	2705                	addiw	a4,a4,1
 b88:	02c5f7bb          	remuw	a5,a1,a2
 b8c:	1782                	slli	a5,a5,0x20
 b8e:	9381                	srli	a5,a5,0x20
 b90:	97aa                	add	a5,a5,a0
 b92:	0007c783          	lbu	a5,0(a5)
 b96:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 b9a:	0005879b          	sext.w	a5,a1
 b9e:	02c5d5bb          	divuw	a1,a1,a2
 ba2:	0685                	addi	a3,a3,1
 ba4:	fec7f0e3          	bgeu	a5,a2,b84 <printint+0x2a>
  if(neg)
 ba8:	00088b63          	beqz	a7,bbe <printint+0x64>
    buf[i++] = '-';
 bac:	fd040793          	addi	a5,s0,-48
 bb0:	973e                	add	a4,a4,a5
 bb2:	02d00793          	li	a5,45
 bb6:	fef70823          	sb	a5,-16(a4)
 bba:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 bbe:	02e05863          	blez	a4,bee <printint+0x94>
 bc2:	fc040793          	addi	a5,s0,-64
 bc6:	00e78933          	add	s2,a5,a4
 bca:	fff78993          	addi	s3,a5,-1
 bce:	99ba                	add	s3,s3,a4
 bd0:	377d                	addiw	a4,a4,-1
 bd2:	1702                	slli	a4,a4,0x20
 bd4:	9301                	srli	a4,a4,0x20
 bd6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 bda:	fff94583          	lbu	a1,-1(s2)
 bde:	8526                	mv	a0,s1
 be0:	00000097          	auipc	ra,0x0
 be4:	f58080e7          	jalr	-168(ra) # b38 <putc>
  while(--i >= 0)
 be8:	197d                	addi	s2,s2,-1
 bea:	ff3918e3          	bne	s2,s3,bda <printint+0x80>
}
 bee:	70e2                	ld	ra,56(sp)
 bf0:	7442                	ld	s0,48(sp)
 bf2:	74a2                	ld	s1,40(sp)
 bf4:	7902                	ld	s2,32(sp)
 bf6:	69e2                	ld	s3,24(sp)
 bf8:	6121                	addi	sp,sp,64
 bfa:	8082                	ret
    x = -xx;
 bfc:	40b005bb          	negw	a1,a1
    neg = 1;
 c00:	4885                	li	a7,1
    x = -xx;
 c02:	bf8d                	j	b74 <printint+0x1a>

0000000000000c04 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 c04:	7119                	addi	sp,sp,-128
 c06:	fc86                	sd	ra,120(sp)
 c08:	f8a2                	sd	s0,112(sp)
 c0a:	f4a6                	sd	s1,104(sp)
 c0c:	f0ca                	sd	s2,96(sp)
 c0e:	ecce                	sd	s3,88(sp)
 c10:	e8d2                	sd	s4,80(sp)
 c12:	e4d6                	sd	s5,72(sp)
 c14:	e0da                	sd	s6,64(sp)
 c16:	fc5e                	sd	s7,56(sp)
 c18:	f862                	sd	s8,48(sp)
 c1a:	f466                	sd	s9,40(sp)
 c1c:	f06a                	sd	s10,32(sp)
 c1e:	ec6e                	sd	s11,24(sp)
 c20:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 c22:	0005c903          	lbu	s2,0(a1)
 c26:	18090f63          	beqz	s2,dc4 <vprintf+0x1c0>
 c2a:	8aaa                	mv	s5,a0
 c2c:	8b32                	mv	s6,a2
 c2e:	00158493          	addi	s1,a1,1
  state = 0;
 c32:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 c34:	02500a13          	li	s4,37
      if(c == 'd'){
 c38:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 c3c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 c40:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 c44:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 c48:	00001b97          	auipc	s7,0x1
 c4c:	e40b8b93          	addi	s7,s7,-448 # 1a88 <digits>
 c50:	a839                	j	c6e <vprintf+0x6a>
        putc(fd, c);
 c52:	85ca                	mv	a1,s2
 c54:	8556                	mv	a0,s5
 c56:	00000097          	auipc	ra,0x0
 c5a:	ee2080e7          	jalr	-286(ra) # b38 <putc>
 c5e:	a019                	j	c64 <vprintf+0x60>
    } else if(state == '%'){
 c60:	01498f63          	beq	s3,s4,c7e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 c64:	0485                	addi	s1,s1,1
 c66:	fff4c903          	lbu	s2,-1(s1)
 c6a:	14090d63          	beqz	s2,dc4 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 c6e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 c72:	fe0997e3          	bnez	s3,c60 <vprintf+0x5c>
      if(c == '%'){
 c76:	fd479ee3          	bne	a5,s4,c52 <vprintf+0x4e>
        state = '%';
 c7a:	89be                	mv	s3,a5
 c7c:	b7e5                	j	c64 <vprintf+0x60>
      if(c == 'd'){
 c7e:	05878063          	beq	a5,s8,cbe <vprintf+0xba>
      } else if(c == 'l') {
 c82:	05978c63          	beq	a5,s9,cda <vprintf+0xd6>
      } else if(c == 'x') {
 c86:	07a78863          	beq	a5,s10,cf6 <vprintf+0xf2>
      } else if(c == 'p') {
 c8a:	09b78463          	beq	a5,s11,d12 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 c8e:	07300713          	li	a4,115
 c92:	0ce78663          	beq	a5,a4,d5e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 c96:	06300713          	li	a4,99
 c9a:	0ee78e63          	beq	a5,a4,d96 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 c9e:	11478863          	beq	a5,s4,dae <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 ca2:	85d2                	mv	a1,s4
 ca4:	8556                	mv	a0,s5
 ca6:	00000097          	auipc	ra,0x0
 caa:	e92080e7          	jalr	-366(ra) # b38 <putc>
        putc(fd, c);
 cae:	85ca                	mv	a1,s2
 cb0:	8556                	mv	a0,s5
 cb2:	00000097          	auipc	ra,0x0
 cb6:	e86080e7          	jalr	-378(ra) # b38 <putc>
      }
      state = 0;
 cba:	4981                	li	s3,0
 cbc:	b765                	j	c64 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 cbe:	008b0913          	addi	s2,s6,8
 cc2:	4685                	li	a3,1
 cc4:	4629                	li	a2,10
 cc6:	000b2583          	lw	a1,0(s6)
 cca:	8556                	mv	a0,s5
 ccc:	00000097          	auipc	ra,0x0
 cd0:	e8e080e7          	jalr	-370(ra) # b5a <printint>
 cd4:	8b4a                	mv	s6,s2
      state = 0;
 cd6:	4981                	li	s3,0
 cd8:	b771                	j	c64 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 cda:	008b0913          	addi	s2,s6,8
 cde:	4681                	li	a3,0
 ce0:	4629                	li	a2,10
 ce2:	000b2583          	lw	a1,0(s6)
 ce6:	8556                	mv	a0,s5
 ce8:	00000097          	auipc	ra,0x0
 cec:	e72080e7          	jalr	-398(ra) # b5a <printint>
 cf0:	8b4a                	mv	s6,s2
      state = 0;
 cf2:	4981                	li	s3,0
 cf4:	bf85                	j	c64 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 cf6:	008b0913          	addi	s2,s6,8
 cfa:	4681                	li	a3,0
 cfc:	4641                	li	a2,16
 cfe:	000b2583          	lw	a1,0(s6)
 d02:	8556                	mv	a0,s5
 d04:	00000097          	auipc	ra,0x0
 d08:	e56080e7          	jalr	-426(ra) # b5a <printint>
 d0c:	8b4a                	mv	s6,s2
      state = 0;
 d0e:	4981                	li	s3,0
 d10:	bf91                	j	c64 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 d12:	008b0793          	addi	a5,s6,8
 d16:	f8f43423          	sd	a5,-120(s0)
 d1a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 d1e:	03000593          	li	a1,48
 d22:	8556                	mv	a0,s5
 d24:	00000097          	auipc	ra,0x0
 d28:	e14080e7          	jalr	-492(ra) # b38 <putc>
  putc(fd, 'x');
 d2c:	85ea                	mv	a1,s10
 d2e:	8556                	mv	a0,s5
 d30:	00000097          	auipc	ra,0x0
 d34:	e08080e7          	jalr	-504(ra) # b38 <putc>
 d38:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 d3a:	03c9d793          	srli	a5,s3,0x3c
 d3e:	97de                	add	a5,a5,s7
 d40:	0007c583          	lbu	a1,0(a5)
 d44:	8556                	mv	a0,s5
 d46:	00000097          	auipc	ra,0x0
 d4a:	df2080e7          	jalr	-526(ra) # b38 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 d4e:	0992                	slli	s3,s3,0x4
 d50:	397d                	addiw	s2,s2,-1
 d52:	fe0914e3          	bnez	s2,d3a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 d56:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 d5a:	4981                	li	s3,0
 d5c:	b721                	j	c64 <vprintf+0x60>
        s = va_arg(ap, char*);
 d5e:	008b0993          	addi	s3,s6,8
 d62:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 d66:	02090163          	beqz	s2,d88 <vprintf+0x184>
        while(*s != 0){
 d6a:	00094583          	lbu	a1,0(s2)
 d6e:	c9a1                	beqz	a1,dbe <vprintf+0x1ba>
          putc(fd, *s);
 d70:	8556                	mv	a0,s5
 d72:	00000097          	auipc	ra,0x0
 d76:	dc6080e7          	jalr	-570(ra) # b38 <putc>
          s++;
 d7a:	0905                	addi	s2,s2,1
        while(*s != 0){
 d7c:	00094583          	lbu	a1,0(s2)
 d80:	f9e5                	bnez	a1,d70 <vprintf+0x16c>
        s = va_arg(ap, char*);
 d82:	8b4e                	mv	s6,s3
      state = 0;
 d84:	4981                	li	s3,0
 d86:	bdf9                	j	c64 <vprintf+0x60>
          s = "(null)";
 d88:	00001917          	auipc	s2,0x1
 d8c:	cf890913          	addi	s2,s2,-776 # 1a80 <malloc+0xbb2>
        while(*s != 0){
 d90:	02800593          	li	a1,40
 d94:	bff1                	j	d70 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 d96:	008b0913          	addi	s2,s6,8
 d9a:	000b4583          	lbu	a1,0(s6)
 d9e:	8556                	mv	a0,s5
 da0:	00000097          	auipc	ra,0x0
 da4:	d98080e7          	jalr	-616(ra) # b38 <putc>
 da8:	8b4a                	mv	s6,s2
      state = 0;
 daa:	4981                	li	s3,0
 dac:	bd65                	j	c64 <vprintf+0x60>
        putc(fd, c);
 dae:	85d2                	mv	a1,s4
 db0:	8556                	mv	a0,s5
 db2:	00000097          	auipc	ra,0x0
 db6:	d86080e7          	jalr	-634(ra) # b38 <putc>
      state = 0;
 dba:	4981                	li	s3,0
 dbc:	b565                	j	c64 <vprintf+0x60>
        s = va_arg(ap, char*);
 dbe:	8b4e                	mv	s6,s3
      state = 0;
 dc0:	4981                	li	s3,0
 dc2:	b54d                	j	c64 <vprintf+0x60>
    }
  }
}
 dc4:	70e6                	ld	ra,120(sp)
 dc6:	7446                	ld	s0,112(sp)
 dc8:	74a6                	ld	s1,104(sp)
 dca:	7906                	ld	s2,96(sp)
 dcc:	69e6                	ld	s3,88(sp)
 dce:	6a46                	ld	s4,80(sp)
 dd0:	6aa6                	ld	s5,72(sp)
 dd2:	6b06                	ld	s6,64(sp)
 dd4:	7be2                	ld	s7,56(sp)
 dd6:	7c42                	ld	s8,48(sp)
 dd8:	7ca2                	ld	s9,40(sp)
 dda:	7d02                	ld	s10,32(sp)
 ddc:	6de2                	ld	s11,24(sp)
 dde:	6109                	addi	sp,sp,128
 de0:	8082                	ret

0000000000000de2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 de2:	715d                	addi	sp,sp,-80
 de4:	ec06                	sd	ra,24(sp)
 de6:	e822                	sd	s0,16(sp)
 de8:	1000                	addi	s0,sp,32
 dea:	e010                	sd	a2,0(s0)
 dec:	e414                	sd	a3,8(s0)
 dee:	e818                	sd	a4,16(s0)
 df0:	ec1c                	sd	a5,24(s0)
 df2:	03043023          	sd	a6,32(s0)
 df6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 dfa:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 dfe:	8622                	mv	a2,s0
 e00:	00000097          	auipc	ra,0x0
 e04:	e04080e7          	jalr	-508(ra) # c04 <vprintf>
}
 e08:	60e2                	ld	ra,24(sp)
 e0a:	6442                	ld	s0,16(sp)
 e0c:	6161                	addi	sp,sp,80
 e0e:	8082                	ret

0000000000000e10 <printf>:

void
printf(const char *fmt, ...)
{
 e10:	711d                	addi	sp,sp,-96
 e12:	ec06                	sd	ra,24(sp)
 e14:	e822                	sd	s0,16(sp)
 e16:	1000                	addi	s0,sp,32
 e18:	e40c                	sd	a1,8(s0)
 e1a:	e810                	sd	a2,16(s0)
 e1c:	ec14                	sd	a3,24(s0)
 e1e:	f018                	sd	a4,32(s0)
 e20:	f41c                	sd	a5,40(s0)
 e22:	03043823          	sd	a6,48(s0)
 e26:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 e2a:	00840613          	addi	a2,s0,8
 e2e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 e32:	85aa                	mv	a1,a0
 e34:	4505                	li	a0,1
 e36:	00000097          	auipc	ra,0x0
 e3a:	dce080e7          	jalr	-562(ra) # c04 <vprintf>
}
 e3e:	60e2                	ld	ra,24(sp)
 e40:	6442                	ld	s0,16(sp)
 e42:	6125                	addi	sp,sp,96
 e44:	8082                	ret

0000000000000e46 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 e46:	1141                	addi	sp,sp,-16
 e48:	e422                	sd	s0,8(sp)
 e4a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 e4c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e50:	00001797          	auipc	a5,0x1
 e54:	c507b783          	ld	a5,-944(a5) # 1aa0 <freep>
 e58:	a805                	j	e88 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 e5a:	4618                	lw	a4,8(a2)
 e5c:	9db9                	addw	a1,a1,a4
 e5e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 e62:	6398                	ld	a4,0(a5)
 e64:	6318                	ld	a4,0(a4)
 e66:	fee53823          	sd	a4,-16(a0)
 e6a:	a091                	j	eae <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 e6c:	ff852703          	lw	a4,-8(a0)
 e70:	9e39                	addw	a2,a2,a4
 e72:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 e74:	ff053703          	ld	a4,-16(a0)
 e78:	e398                	sd	a4,0(a5)
 e7a:	a099                	j	ec0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e7c:	6398                	ld	a4,0(a5)
 e7e:	00e7e463          	bltu	a5,a4,e86 <free+0x40>
 e82:	00e6ea63          	bltu	a3,a4,e96 <free+0x50>
{
 e86:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e88:	fed7fae3          	bgeu	a5,a3,e7c <free+0x36>
 e8c:	6398                	ld	a4,0(a5)
 e8e:	00e6e463          	bltu	a3,a4,e96 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e92:	fee7eae3          	bltu	a5,a4,e86 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 e96:	ff852583          	lw	a1,-8(a0)
 e9a:	6390                	ld	a2,0(a5)
 e9c:	02059813          	slli	a6,a1,0x20
 ea0:	01c85713          	srli	a4,a6,0x1c
 ea4:	9736                	add	a4,a4,a3
 ea6:	fae60ae3          	beq	a2,a4,e5a <free+0x14>
    bp->s.ptr = p->s.ptr;
 eaa:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 eae:	4790                	lw	a2,8(a5)
 eb0:	02061593          	slli	a1,a2,0x20
 eb4:	01c5d713          	srli	a4,a1,0x1c
 eb8:	973e                	add	a4,a4,a5
 eba:	fae689e3          	beq	a3,a4,e6c <free+0x26>
  } else
    p->s.ptr = bp;
 ebe:	e394                	sd	a3,0(a5)
  freep = p;
 ec0:	00001717          	auipc	a4,0x1
 ec4:	bef73023          	sd	a5,-1056(a4) # 1aa0 <freep>
}
 ec8:	6422                	ld	s0,8(sp)
 eca:	0141                	addi	sp,sp,16
 ecc:	8082                	ret

0000000000000ece <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 ece:	7139                	addi	sp,sp,-64
 ed0:	fc06                	sd	ra,56(sp)
 ed2:	f822                	sd	s0,48(sp)
 ed4:	f426                	sd	s1,40(sp)
 ed6:	f04a                	sd	s2,32(sp)
 ed8:	ec4e                	sd	s3,24(sp)
 eda:	e852                	sd	s4,16(sp)
 edc:	e456                	sd	s5,8(sp)
 ede:	e05a                	sd	s6,0(sp)
 ee0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ee2:	02051493          	slli	s1,a0,0x20
 ee6:	9081                	srli	s1,s1,0x20
 ee8:	04bd                	addi	s1,s1,15
 eea:	8091                	srli	s1,s1,0x4
 eec:	0014899b          	addiw	s3,s1,1
 ef0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 ef2:	00001517          	auipc	a0,0x1
 ef6:	bae53503          	ld	a0,-1106(a0) # 1aa0 <freep>
 efa:	c515                	beqz	a0,f26 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 efc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 efe:	4798                	lw	a4,8(a5)
 f00:	02977f63          	bgeu	a4,s1,f3e <malloc+0x70>
 f04:	8a4e                	mv	s4,s3
 f06:	0009871b          	sext.w	a4,s3
 f0a:	6685                	lui	a3,0x1
 f0c:	00d77363          	bgeu	a4,a3,f12 <malloc+0x44>
 f10:	6a05                	lui	s4,0x1
 f12:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 f16:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 f1a:	00001917          	auipc	s2,0x1
 f1e:	b8690913          	addi	s2,s2,-1146 # 1aa0 <freep>
  if(p == (char*)-1)
 f22:	5afd                	li	s5,-1
 f24:	a895                	j	f98 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 f26:	00001797          	auipc	a5,0x1
 f2a:	b8278793          	addi	a5,a5,-1150 # 1aa8 <base>
 f2e:	00001717          	auipc	a4,0x1
 f32:	b6f73923          	sd	a5,-1166(a4) # 1aa0 <freep>
 f36:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 f38:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 f3c:	b7e1                	j	f04 <malloc+0x36>
      if(p->s.size == nunits)
 f3e:	02e48c63          	beq	s1,a4,f76 <malloc+0xa8>
        p->s.size -= nunits;
 f42:	4137073b          	subw	a4,a4,s3
 f46:	c798                	sw	a4,8(a5)
        p += p->s.size;
 f48:	02071693          	slli	a3,a4,0x20
 f4c:	01c6d713          	srli	a4,a3,0x1c
 f50:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 f52:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 f56:	00001717          	auipc	a4,0x1
 f5a:	b4a73523          	sd	a0,-1206(a4) # 1aa0 <freep>
      return (void*)(p + 1);
 f5e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 f62:	70e2                	ld	ra,56(sp)
 f64:	7442                	ld	s0,48(sp)
 f66:	74a2                	ld	s1,40(sp)
 f68:	7902                	ld	s2,32(sp)
 f6a:	69e2                	ld	s3,24(sp)
 f6c:	6a42                	ld	s4,16(sp)
 f6e:	6aa2                	ld	s5,8(sp)
 f70:	6b02                	ld	s6,0(sp)
 f72:	6121                	addi	sp,sp,64
 f74:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 f76:	6398                	ld	a4,0(a5)
 f78:	e118                	sd	a4,0(a0)
 f7a:	bff1                	j	f56 <malloc+0x88>
  hp->s.size = nu;
 f7c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 f80:	0541                	addi	a0,a0,16
 f82:	00000097          	auipc	ra,0x0
 f86:	ec4080e7          	jalr	-316(ra) # e46 <free>
  return freep;
 f8a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 f8e:	d971                	beqz	a0,f62 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f90:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 f92:	4798                	lw	a4,8(a5)
 f94:	fa9775e3          	bgeu	a4,s1,f3e <malloc+0x70>
    if(p == freep)
 f98:	00093703          	ld	a4,0(s2)
 f9c:	853e                	mv	a0,a5
 f9e:	fef719e3          	bne	a4,a5,f90 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 fa2:	8552                	mv	a0,s4
 fa4:	00000097          	auipc	ra,0x0
 fa8:	b7c080e7          	jalr	-1156(ra) # b20 <sbrk>
  if(p == (char*)-1)
 fac:	fd5518e3          	bne	a0,s5,f7c <malloc+0xae>
        return 0;
 fb0:	4501                	li	a0,0
 fb2:	bf45                	j	f62 <malloc+0x94>
