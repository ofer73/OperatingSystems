
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
  14:	fb898993          	addi	s3,s3,-72 # fc8 <malloc+0xea>
    for (int i = 0; i < 22; i++)
  18:	4959                	li	s2,22
        printf("sbrk %d\n",i);
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	00001097          	auipc	ra,0x1
  22:	e02080e7          	jalr	-510(ra) # e20 <printf>
        sbrk(4096);
  26:	6505                	lui	a0,0x1
  28:	00001097          	auipc	ra,0x1
  2c:	b08080e7          	jalr	-1272(ra) # b30 <sbrk>
    for (int i = 0; i < 22; i++)
  30:	2485                	addiw	s1,s1,1
  32:	ff2494e3          	bne	s1,s2,1a <sbark_and_fork+0x1a>
    }
    // notice 6 pages swaped out
    int pid= fork();
  36:	00001097          	auipc	ra,0x1
  3a:	a6a080e7          	jalr	-1430(ra) # aa0 <fork>
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
  46:	a6e080e7          	jalr	-1426(ra) # ab0 <wait>
    printf("test: finished test\n");
  4a:	00001517          	auipc	a0,0x1
  4e:	fae50513          	addi	a0,a0,-82 # ff8 <malloc+0x11a>
  52:	00001097          	auipc	ra,0x1
  56:	dce080e7          	jalr	-562(ra) # e20 <printf>
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
  6e:	f6e50513          	addi	a0,a0,-146 # fd8 <malloc+0xfa>
  72:	00001097          	auipc	ra,0x1
  76:	dae080e7          	jalr	-594(ra) # e20 <printf>
        sbrk(4096);
  7a:	6505                	lui	a0,0x1
  7c:	00001097          	auipc	ra,0x1
  80:	ab4080e7          	jalr	-1356(ra) # b30 <sbrk>
        printf("child sbrk neg\n");
  84:	00001517          	auipc	a0,0x1
  88:	f6450513          	addi	a0,a0,-156 # fe8 <malloc+0x10a>
  8c:	00001097          	auipc	ra,0x1
  90:	d94080e7          	jalr	-620(ra) # e20 <printf>
        sbrk(-4096 * 14);
  94:	7549                	lui	a0,0xffff2
  96:	00001097          	auipc	ra,0x1
  9a:	a9a080e7          	jalr	-1382(ra) # b30 <sbrk>
        printf("child sbrk\n");
  9e:	00001517          	auipc	a0,0x1
  a2:	f3a50513          	addi	a0,a0,-198 # fd8 <malloc+0xfa>
  a6:	00001097          	auipc	ra,0x1
  aa:	d7a080e7          	jalr	-646(ra) # e20 <printf>
        sbrk(4096 * 4);
  ae:	6511                	lui	a0,0x4
  b0:	00001097          	auipc	ra,0x1
  b4:	a80080e7          	jalr	-1408(ra) # b30 <sbrk>
        sleep(5);
  b8:	4515                	li	a0,5
  ba:	00001097          	auipc	ra,0x1
  be:	a7e080e7          	jalr	-1410(ra) # b38 <sleep>
        exit(0);
  c2:	4501                	li	a0,0
  c4:	00001097          	auipc	ra,0x1
  c8:	9e4080e7          	jalr	-1564(ra) # aa8 <exit>

00000000000000cc <just_a_func>:
int
just_a_func(){
  cc:	1141                	addi	sp,sp,-16
  ce:	e406                	sd	ra,8(sp)
  d0:	e022                	sd	s0,0(sp)
  d2:	0800                	addi	s0,sp,16
    printf("func\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	f3c50513          	addi	a0,a0,-196 # 1010 <malloc+0x132>
  dc:	00001097          	auipc	ra,0x1
  e0:	d44080e7          	jalr	-700(ra) # e20 <printf>
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
 100:	f1c50513          	addi	a0,a0,-228 # 1018 <malloc+0x13a>
 104:	00001097          	auipc	ra,0x1
 108:	d1c080e7          	jalr	-740(ra) # e20 <printf>
    printf( "-------------allocating 16 pages-----------------\n");
 10c:	00001517          	auipc	a0,0x1
 110:	f4450513          	addi	a0,a0,-188 # 1050 <malloc+0x172>
 114:	00001097          	auipc	ra,0x1
 118:	d0c080e7          	jalr	-756(ra) # e20 <printf>
    if(fork() == 0){
 11c:	00001097          	auipc	ra,0x1
 120:	984080e7          	jalr	-1660(ra) # aa0 <fork>
 124:	cd09                	beqz	a0,13e <fork_SCFIFO+0x50>
        printf("---------passed scifo test!!!!----------\n");
        gets(in,3);
        exit(0);

    }
    wait(0);
 126:	4501                	li	a0,0
 128:	00001097          	auipc	ra,0x1
 12c:	988080e7          	jalr	-1656(ra) # ab0 <wait>
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
 14c:	9e8080e7          	jalr	-1560(ra) # b30 <sbrk>
 150:	00a93023          	sd	a0,0(s2)
            *pages[i] = i;
 154:	c104                	sw	s1,0(a0)
        for(int i = 0; i < 16; i++){
 156:	2485                	addiw	s1,s1,1
 158:	0921                	addi	s2,s2,8
 15a:	ff3496e3          	bne	s1,s3,146 <fork_SCFIFO+0x58>
        printf( "-------------now add another page. page[0] should move to the file-----------------\n");
 15e:	00001517          	auipc	a0,0x1
 162:	f2a50513          	addi	a0,a0,-214 # 1088 <malloc+0x1aa>
 166:	00001097          	auipc	ra,0x1
 16a:	cba080e7          	jalr	-838(ra) # e20 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 16e:	6505                	lui	a0,0x1
 170:	00001097          	auipc	ra,0x1
 174:	9c0080e7          	jalr	-1600(ra) # b30 <sbrk>
        printf( "-------------now access to pages[1]-----------------\n");
 178:	00001517          	auipc	a0,0x1
 17c:	f6850513          	addi	a0,a0,-152 # 10e0 <malloc+0x202>
 180:	00001097          	auipc	ra,0x1
 184:	ca0080e7          	jalr	-864(ra) # e20 <printf>
        printf("pages[1] contains  %d\n",*pages[1]);
 188:	f4043783          	ld	a5,-192(s0)
 18c:	438c                	lw	a1,0(a5)
 18e:	00001517          	auipc	a0,0x1
 192:	f8a50513          	addi	a0,a0,-118 # 1118 <malloc+0x23a>
 196:	00001097          	auipc	ra,0x1
 19a:	c8a080e7          	jalr	-886(ra) # e20 <printf>
        printf( "-------------now add another page. page[2] should move to the file-----------------\n");
 19e:	00001517          	auipc	a0,0x1
 1a2:	f9250513          	addi	a0,a0,-110 # 1130 <malloc+0x252>
 1a6:	00001097          	auipc	ra,0x1
 1aa:	c7a080e7          	jalr	-902(ra) # e20 <printf>
        pages[17] = (int*)sbrk(PGSIZE);
 1ae:	6505                	lui	a0,0x1
 1b0:	00001097          	auipc	ra,0x1
 1b4:	980080e7          	jalr	-1664(ra) # b30 <sbrk>
        printf( "-------------now acess to page[2] should cause pagefault-----------------\n");
 1b8:	00001517          	auipc	a0,0x1
 1bc:	fd050513          	addi	a0,a0,-48 # 1188 <malloc+0x2aa>
 1c0:	00001097          	auipc	ra,0x1
 1c4:	c60080e7          	jalr	-928(ra) # e20 <printf>
        printf("pages[2] contains  %d\n",*pages[2]);
 1c8:	f4843783          	ld	a5,-184(s0)
 1cc:	438c                	lw	a1,0(a5)
 1ce:	00001517          	auipc	a0,0x1
 1d2:	00a50513          	addi	a0,a0,10 # 11d8 <malloc+0x2fa>
 1d6:	00001097          	auipc	ra,0x1
 1da:	c4a080e7          	jalr	-950(ra) # e20 <printf>
        printf("---------passed scifo test!!!!----------\n");
 1de:	00001517          	auipc	a0,0x1
 1e2:	01250513          	addi	a0,a0,18 # 11f0 <malloc+0x312>
 1e6:	00001097          	auipc	ra,0x1
 1ea:	c3a080e7          	jalr	-966(ra) # e20 <printf>
        gets(in,3);
 1ee:	458d                	li	a1,3
 1f0:	fc840513          	addi	a0,s0,-56
 1f4:	00000097          	auipc	ra,0x0
 1f8:	6fe080e7          	jalr	1790(ra) # 8f2 <gets>
        exit(0);
 1fc:	4501                	li	a0,0
 1fe:	00001097          	auipc	ra,0x1
 202:	8aa080e7          	jalr	-1878(ra) # aa8 <exit>

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
 21a:	00a50513          	addi	a0,a0,10 # 1220 <malloc+0x342>
 21e:	00001097          	auipc	ra,0x1
 222:	c02080e7          	jalr	-1022(ra) # e20 <printf>
    printf( "-------------allocating 16 pages-----------------\n");
 226:	00001517          	auipc	a0,0x1
 22a:	e2a50513          	addi	a0,a0,-470 # 1050 <malloc+0x172>
 22e:	00001097          	auipc	ra,0x1
 232:	bf2080e7          	jalr	-1038(ra) # e20 <printf>
    if(fork() == 0){
 236:	00001097          	auipc	ra,0x1
 23a:	86a080e7          	jalr	-1942(ra) # aa0 <fork>
 23e:	cd19                	beqz	a0,25c <NFUA_test+0x56>
        pages[17] = (int*)sbrk(PGSIZE);
        printf("---------finished NFUA test!!!!----------\n");
        exit(0);

    }
    wait(0);
 240:	4501                	li	a0,0
 242:	00001097          	auipc	ra,0x1
 246:	86e080e7          	jalr	-1938(ra) # ab0 <wait>
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
 26c:	8c8080e7          	jalr	-1848(ra) # b30 <sbrk>
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
 284:	8b8080e7          	jalr	-1864(ra) # b38 <sleep>
        printf("first we will access page 8 %d,\n", *pages[8]);
 288:	f8043483          	ld	s1,-128(s0)
 28c:	408c                	lw	a1,0(s1)
 28e:	00001517          	auipc	a0,0x1
 292:	fca50513          	addi	a0,a0,-54 # 1258 <malloc+0x37a>
 296:	00001097          	auipc	ra,0x1
 29a:	b8a080e7          	jalr	-1142(ra) # e20 <printf>
        sleep(2);
 29e:	4509                	li	a0,2
 2a0:	00001097          	auipc	ra,0x1
 2a4:	898080e7          	jalr	-1896(ra) # b38 <sleep>
        printf( "-------------now access all pages except 8-----------------\n");
 2a8:	00001517          	auipc	a0,0x1
 2ac:	fd850513          	addi	a0,a0,-40 # 1280 <malloc+0x3a2>
 2b0:	00001097          	auipc	ra,0x1
 2b4:	b70080e7          	jalr	-1168(ra) # e20 <printf>
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
 2e4:	858080e7          	jalr	-1960(ra) # b38 <sleep>
        printf( "------------- creating a new page, page 8 should be paged out -----------------\n");
 2e8:	00001517          	auipc	a0,0x1
 2ec:	fd850513          	addi	a0,a0,-40 # 12c0 <malloc+0x3e2>
 2f0:	00001097          	auipc	ra,0x1
 2f4:	b30080e7          	jalr	-1232(ra) # e20 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 2f8:	6505                	lui	a0,0x1
 2fa:	00001097          	auipc	ra,0x1
 2fe:	836080e7          	jalr	-1994(ra) # b30 <sbrk>
        printf( "------------- accessing page 8 -> should cause pagefault-----------------\n");
 302:	00001517          	auipc	a0,0x1
 306:	01650513          	addi	a0,a0,22 # 1318 <malloc+0x43a>
 30a:	00001097          	auipc	ra,0x1
 30e:	b16080e7          	jalr	-1258(ra) # e20 <printf>
        printf("&page 8= %p contains  %d\n",pages[8],*pages[8]);
 312:	4090                	lw	a2,0(s1)
 314:	85a6                	mv	a1,s1
 316:	00001517          	auipc	a0,0x1
 31a:	05250513          	addi	a0,a0,82 # 1368 <malloc+0x48a>
 31e:	00001097          	auipc	ra,0x1
 322:	b02080e7          	jalr	-1278(ra) # e20 <printf>
        printf("doing another sbrk for senity check  %d\n");
 326:	00001517          	auipc	a0,0x1
 32a:	06250513          	addi	a0,a0,98 # 1388 <malloc+0x4aa>
 32e:	00001097          	auipc	ra,0x1
 332:	af2080e7          	jalr	-1294(ra) # e20 <printf>
        pages[17] = (int*)sbrk(PGSIZE);
 336:	6505                	lui	a0,0x1
 338:	00000097          	auipc	ra,0x0
 33c:	7f8080e7          	jalr	2040(ra) # b30 <sbrk>
        printf("---------finished NFUA test!!!!----------\n");
 340:	00001517          	auipc	a0,0x1
 344:	07850513          	addi	a0,a0,120 # 13b8 <malloc+0x4da>
 348:	00001097          	auipc	ra,0x1
 34c:	ad8080e7          	jalr	-1320(ra) # e20 <printf>
        exit(0);
 350:	4501                	li	a0,0
 352:	00000097          	auipc	ra,0x0
 356:	756080e7          	jalr	1878(ra) # aa8 <exit>

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
 36e:	07e50513          	addi	a0,a0,126 # 13e8 <malloc+0x50a>
 372:	00001097          	auipc	ra,0x1
 376:	aae080e7          	jalr	-1362(ra) # e20 <printf>
    if(fork() == 0){
 37a:	00000097          	auipc	ra,0x0
 37e:	726080e7          	jalr	1830(ra) # aa0 <fork>
 382:	cd11                	beqz	a0,39e <LAPA_when_all_equal+0x44>
        printf("---finished LAPA_when_all_equal---\n");

        exit(0);

    }
    wait(0);
 384:	4501                	li	a0,0
 386:	00000097          	auipc	ra,0x0
 38a:	72a080e7          	jalr	1834(ra) # ab0 <wait>
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
 3a4:	0a050513          	addi	a0,a0,160 # 1440 <malloc+0x562>
 3a8:	00001097          	auipc	ra,0x1
 3ac:	a78080e7          	jalr	-1416(ra) # e20 <printf>
        for(int i = 0; i < 16; i++){
 3b0:	f4040913          	addi	s2,s0,-192
        printf( "---------allocating and modifing 16 pages-----------\n");
 3b4:	89ca                	mv	s3,s2
        for(int i = 0; i < 16; i++){
 3b6:	4a41                	li	s4,16
            pages[i] = (int*)sbrk(PGSIZE);
 3b8:	6505                	lui	a0,0x1
 3ba:	00000097          	auipc	ra,0x0
 3be:	776080e7          	jalr	1910(ra) # b30 <sbrk>
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
 3d6:	766080e7          	jalr	1894(ra) # b38 <sleep>
        printf( "----------accessing all pages, starts with page[8]-------------\n");
 3da:	00001517          	auipc	a0,0x1
 3de:	09e50513          	addi	a0,a0,158 # 1478 <malloc+0x59a>
 3e2:	00001097          	auipc	ra,0x1
 3e6:	a3e080e7          	jalr	-1474(ra) # e20 <printf>
        *pages[8] = 8;
 3ea:	f8043483          	ld	s1,-128(s0)
 3ee:	47a1                	li	a5,8
 3f0:	c09c                	sw	a5,0(s1)
        sleep(10);
 3f2:	4529                	li	a0,10
 3f4:	00000097          	auipc	ra,0x0
 3f8:	744080e7          	jalr	1860(ra) # b38 <sleep>
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
 428:	714080e7          	jalr	1812(ra) # b38 <sleep>
        printf( "-------create new page, page 8 need to swapout-----------\n");
 42c:	00001517          	auipc	a0,0x1
 430:	09450513          	addi	a0,a0,148 # 14c0 <malloc+0x5e2>
 434:	00001097          	auipc	ra,0x1
 438:	9ec080e7          	jalr	-1556(ra) # e20 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 43c:	6505                	lui	a0,0x1
 43e:	00000097          	auipc	ra,0x0
 442:	6f2080e7          	jalr	1778(ra) # b30 <sbrk>
        printf( "--------access page 8 shuld cause pagefault---------\n");
 446:	00001517          	auipc	a0,0x1
 44a:	0ba50513          	addi	a0,a0,186 # 1500 <malloc+0x622>
 44e:	00001097          	auipc	ra,0x1
 452:	9d2080e7          	jalr	-1582(ra) # e20 <printf>
        printf("page 8 value =  %d\n",*pages[8]);
 456:	408c                	lw	a1,0(s1)
 458:	00001517          	auipc	a0,0x1
 45c:	0e050513          	addi	a0,a0,224 # 1538 <malloc+0x65a>
 460:	00001097          	auipc	ra,0x1
 464:	9c0080e7          	jalr	-1600(ra) # e20 <printf>
        printf("---finished LAPA_when_all_equal---\n");
 468:	00001517          	auipc	a0,0x1
 46c:	0e850513          	addi	a0,a0,232 # 1550 <malloc+0x672>
 470:	00001097          	auipc	ra,0x1
 474:	9b0080e7          	jalr	-1616(ra) # e20 <printf>
        exit(0);
 478:	4501                	li	a0,0
 47a:	00000097          	auipc	ra,0x0
 47e:	62e080e7          	jalr	1582(ra) # aa8 <exit>

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
 496:	0e650513          	addi	a0,a0,230 # 1578 <malloc+0x69a>
 49a:	00001097          	auipc	ra,0x1
 49e:	986080e7          	jalr	-1658(ra) # e20 <printf>
    printf( "-------------allocating and modifing 16 pages-----------------\n");
 4a2:	00001517          	auipc	a0,0x1
 4a6:	10e50513          	addi	a0,a0,270 # 15b0 <malloc+0x6d2>
 4aa:	00001097          	auipc	ra,0x1
 4ae:	976080e7          	jalr	-1674(ra) # e20 <printf>
    if(fork() == 0){
 4b2:	00000097          	auipc	ra,0x0
 4b6:	5ee080e7          	jalr	1518(ra) # aa0 <fork>
 4ba:	cd11                	beqz	a0,4d6 <LAPA_paging+0x54>
        printf("pages[8] contains  %d\n",*pages[8]);
        printf("-----finish LAPA_paging-----\n");
        exit(0);

    }
    wait(0);
 4bc:	4501                	li	a0,0
 4be:	00000097          	auipc	ra,0x0
 4c2:	5f2080e7          	jalr	1522(ra) # ab0 <wait>
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
 4e6:	64e080e7          	jalr	1614(ra) # b30 <sbrk>
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
 4fe:	63e080e7          	jalr	1598(ra) # b38 <sleep>
        printf( "--------modifing each page 2 times except pages[8]-----------------\n");
 502:	00001517          	auipc	a0,0x1
 506:	0ee50513          	addi	a0,a0,238 # 15f0 <malloc+0x712>
 50a:	00001097          	auipc	ra,0x1
 50e:	916080e7          	jalr	-1770(ra) # e20 <printf>
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
 53e:	5fe080e7          	jalr	1534(ra) # b38 <sleep>
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
 56e:	5ce080e7          	jalr	1486(ra) # b38 <sleep>
        printf( "--------modifing page 8 once----------\n");
 572:	00001517          	auipc	a0,0x1
 576:	0c650513          	addi	a0,a0,198 # 1638 <malloc+0x75a>
 57a:	00001097          	auipc	ra,0x1
 57e:	8a6080e7          	jalr	-1882(ra) # e20 <printf>
        *pages[8] = 8;
 582:	f8043483          	ld	s1,-128(s0)
 586:	47a1                	li	a5,8
 588:	c09c                	sw	a5,0(s1)
        printf( "-----create new page-> page 8 need to swapout------\n");
 58a:	00001517          	auipc	a0,0x1
 58e:	0d650513          	addi	a0,a0,214 # 1660 <malloc+0x782>
 592:	00001097          	auipc	ra,0x1
 596:	88e080e7          	jalr	-1906(ra) # e20 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 59a:	6505                	lui	a0,0x1
 59c:	00000097          	auipc	ra,0x0
 5a0:	594080e7          	jalr	1428(ra) # b30 <sbrk>
        printf( "-------access page 8 need to cause pagefault-------\n");
 5a4:	00001517          	auipc	a0,0x1
 5a8:	0f450513          	addi	a0,a0,244 # 1698 <malloc+0x7ba>
 5ac:	00001097          	auipc	ra,0x1
 5b0:	874080e7          	jalr	-1932(ra) # e20 <printf>
        printf("pages[8] contains  %d\n",*pages[8]);
 5b4:	408c                	lw	a1,0(s1)
 5b6:	00001517          	auipc	a0,0x1
 5ba:	11a50513          	addi	a0,a0,282 # 16d0 <malloc+0x7f2>
 5be:	00001097          	auipc	ra,0x1
 5c2:	862080e7          	jalr	-1950(ra) # e20 <printf>
        printf("-----finish LAPA_paging-----\n");
 5c6:	00001517          	auipc	a0,0x1
 5ca:	12250513          	addi	a0,a0,290 # 16e8 <malloc+0x80a>
 5ce:	00001097          	auipc	ra,0x1
 5d2:	852080e7          	jalr	-1966(ra) # e20 <printf>
        exit(0);
 5d6:	4501                	li	a0,0
 5d8:	00000097          	auipc	ra,0x0
 5dc:	4d0080e7          	jalr	1232(ra) # aa8 <exit>

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
 5f6:	11650513          	addi	a0,a0,278 # 1708 <malloc+0x82a>
 5fa:	00001097          	auipc	ra,0x1
 5fe:	826080e7          	jalr	-2010(ra) # e20 <printf>
    printf( "-------------allocating 16 pages for father-----------------\n");
 602:	00001517          	auipc	a0,0x1
 606:	14650513          	addi	a0,a0,326 # 1748 <malloc+0x86a>
 60a:	00001097          	auipc	ra,0x1
 60e:	816080e7          	jalr	-2026(ra) # e20 <printf>
 612:	f3040913          	addi	s2,s0,-208
    for(int i = 0; i < 16; i++){
 616:	4481                	li	s1,0
 618:	49c1                	li	s3,16
            pages[i] = (int*)sbrk(PGSIZE);
 61a:	6505                	lui	a0,0x1
 61c:	00000097          	auipc	ra,0x0
 620:	514080e7          	jalr	1300(ra) # b30 <sbrk>
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
 638:	504080e7          	jalr	1284(ra) # b38 <sleep>
    printf( "------------- accessing all pages 3 times except page 8-----------------\n");
 63c:	00001517          	auipc	a0,0x1
 640:	14c50513          	addi	a0,a0,332 # 1788 <malloc+0x8aa>
 644:	00000097          	auipc	ra,0x0
 648:	7dc080e7          	jalr	2012(ra) # e20 <printf>
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
 678:	4c4080e7          	jalr	1220(ra) # b38 <sleep>
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
 690:	14c50513          	addi	a0,a0,332 # 17d8 <malloc+0x8fa>
 694:	00000097          	auipc	ra,0x0
 698:	78c080e7          	jalr	1932(ra) # e20 <printf>
        *pages[8] = 8;
 69c:	f7043483          	ld	s1,-144(s0)
 6a0:	47a1                	li	a5,8
 6a2:	c09c                	sw	a5,0(s1)
        *pages[8] = 8;
        sleep(1);
 6a4:	4505                	li	a0,1
 6a6:	00000097          	auipc	ra,0x0
 6aa:	492080e7          	jalr	1170(ra) # b38 <sleep>
    if(fork() == 0){
 6ae:	00000097          	auipc	ra,0x0
 6b2:	3f2080e7          	jalr	1010(ra) # aa0 <fork>
 6b6:	c52d                	beqz	a0,720 <LAPA_test_fork_copy+0x140>
        printf( "-------------Son: now acess to page 8 should cause pagefault-----------------\n");
        printf("page 8 contains  %d\n",*pages[8]);
        exit(0);
    }

    wait(0);
 6b8:	4501                	li	a0,0
 6ba:	00000097          	auipc	ra,0x0
 6be:	3f6080e7          	jalr	1014(ra) # ab0 <wait>
    printf( "-------------Father: create a new page, page 8 should be paged out-----------------\n");
 6c2:	00001517          	auipc	a0,0x1
 6c6:	21650513          	addi	a0,a0,534 # 18d8 <malloc+0x9fa>
 6ca:	00000097          	auipc	ra,0x0
 6ce:	756080e7          	jalr	1878(ra) # e20 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 6d2:	6505                	lui	a0,0x1
 6d4:	00000097          	auipc	ra,0x0
 6d8:	45c080e7          	jalr	1116(ra) # b30 <sbrk>
        
        printf( "-------------Father: now acess to page 8 should cause pagefault-----------------\n");
 6dc:	00001517          	auipc	a0,0x1
 6e0:	25450513          	addi	a0,a0,596 # 1930 <malloc+0xa52>
 6e4:	00000097          	auipc	ra,0x0
 6e8:	73c080e7          	jalr	1852(ra) # e20 <printf>
        printf("page 8 contains : %d",*pages[8]);
 6ec:	408c                	lw	a1,0(s1)
 6ee:	00001517          	auipc	a0,0x1
 6f2:	29a50513          	addi	a0,a0,666 # 1988 <malloc+0xaaa>
 6f6:	00000097          	auipc	ra,0x0
 6fa:	72a080e7          	jalr	1834(ra) # e20 <printf>
        
    printf("---------finished LAPA_test_fork_copy test!!!!----------\n");
 6fe:	00001517          	auipc	a0,0x1
 702:	2a250513          	addi	a0,a0,674 # 19a0 <malloc+0xac2>
 706:	00000097          	auipc	ra,0x0
 70a:	71a080e7          	jalr	1818(ra) # e20 <printf>
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
 724:	0f850513          	addi	a0,a0,248 # 1818 <malloc+0x93a>
 728:	00000097          	auipc	ra,0x0
 72c:	6f8080e7          	jalr	1784(ra) # e20 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 730:	6505                	lui	a0,0x1
 732:	00000097          	auipc	ra,0x0
 736:	3fe080e7          	jalr	1022(ra) # b30 <sbrk>
        printf( "-------------Son: now acess to page 8 should cause pagefault-----------------\n");
 73a:	00001517          	auipc	a0,0x1
 73e:	13650513          	addi	a0,a0,310 # 1870 <malloc+0x992>
 742:	00000097          	auipc	ra,0x0
 746:	6de080e7          	jalr	1758(ra) # e20 <printf>
        printf("page 8 contains  %d\n",*pages[8]);
 74a:	408c                	lw	a1,0(s1)
 74c:	00001517          	auipc	a0,0x1
 750:	17450513          	addi	a0,a0,372 # 18c0 <malloc+0x9e2>
 754:	00000097          	auipc	ra,0x0
 758:	6cc080e7          	jalr	1740(ra) # e20 <printf>
        exit(0);
 75c:	4501                	li	a0,0
 75e:	00000097          	auipc	ra,0x0
 762:	34a080e7          	jalr	842(ra) # aa8 <exit>

0000000000000766 <fork_test>:

int 
fork_test(){
 766:	1141                	addi	sp,sp,-16
 768:	e406                	sd	ra,8(sp)
 76a:	e022                	sd	s0,0(sp)
 76c:	0800                	addi	s0,sp,16
    #ifdef SCFIFO
    return fork_SCFIFO();
    #endif

    #ifdef NFUA
    return NFUA_test();
 76e:	00000097          	auipc	ra,0x0
 772:	a98080e7          	jalr	-1384(ra) # 206 <NFUA_test>
    gets(wait,3);
    return LAPA_test_fork_copy();
    #endif
    return -1;
    
}
 776:	60a2                	ld	ra,8(sp)
 778:	6402                	ld	s0,0(sp)
 77a:	0141                	addi	sp,sp,16
 77c:	8082                	ret

000000000000077e <shiftcheck>:

void shiftcheck(){
 77e:	1141                	addi	sp,sp,-16
 780:	e406                	sd	ra,8(sp)
 782:	e022                	sd	s0,0(sp)
 784:	0800                	addi	s0,sp,16
    long x = 0xFFFFFFFF;
    long y = 0x80000000;
    printf("-----------------------------before x = %p\n",x);
 786:	55fd                	li	a1,-1
 788:	9181                	srli	a1,a1,0x20
 78a:	00001517          	auipc	a0,0x1
 78e:	25650513          	addi	a0,a0,598 # 19e0 <malloc+0xb02>
 792:	00000097          	auipc	ra,0x0
 796:	68e080e7          	jalr	1678(ra) # e20 <printf>
    printf("-----------------------------before y = %p\n",y);
 79a:	4585                	li	a1,1
 79c:	05fe                	slli	a1,a1,0x1f
 79e:	00001517          	auipc	a0,0x1
 7a2:	27250513          	addi	a0,a0,626 # 1a10 <malloc+0xb32>
 7a6:	00000097          	auipc	ra,0x0
 7aa:	67a080e7          	jalr	1658(ra) # e20 <printf>
    x = x>>1;
    printf("-----------------------------after1 x = %p\n",x);
 7ae:	800005b7          	lui	a1,0x80000
 7b2:	fff5c593          	not	a1,a1
 7b6:	00001517          	auipc	a0,0x1
 7ba:	28a50513          	addi	a0,a0,650 # 1a40 <malloc+0xb62>
 7be:	00000097          	auipc	ra,0x0
 7c2:	662080e7          	jalr	1634(ra) # e20 <printf>
    x = x>>1 | y;
    printf("-----------------------------after2 x = %p\n",x);
 7c6:	458d                	li	a1,3
 7c8:	05fa                	slli	a1,a1,0x1e
 7ca:	15fd                	addi	a1,a1,-1
 7cc:	00001517          	auipc	a0,0x1
 7d0:	2a450513          	addi	a0,a0,676 # 1a70 <malloc+0xb92>
 7d4:	00000097          	auipc	ra,0x0
 7d8:	64c080e7          	jalr	1612(ra) # e20 <printf>
    x = x>>1 | y;
    printf("-----------------------------after3 x = %p\n",x);
 7dc:	459d                	li	a1,7
 7de:	05f6                	slli	a1,a1,0x1d
 7e0:	15fd                	addi	a1,a1,-1
 7e2:	00001517          	auipc	a0,0x1
 7e6:	2be50513          	addi	a0,a0,702 # 1aa0 <malloc+0xbc2>
 7ea:	00000097          	auipc	ra,0x0
 7ee:	636080e7          	jalr	1590(ra) # e20 <printf>
    x = x>>1 | y;
    printf("-----------------------------after4 x = %p\n",x);
 7f2:	45bd                	li	a1,15
 7f4:	05f2                	slli	a1,a1,0x1c
 7f6:	15fd                	addi	a1,a1,-1
 7f8:	00001517          	auipc	a0,0x1
 7fc:	2d850513          	addi	a0,a0,728 # 1ad0 <malloc+0xbf2>
 800:	00000097          	auipc	ra,0x0
 804:	620080e7          	jalr	1568(ra) # e20 <printf>
}
 808:	60a2                	ld	ra,8(sp)
 80a:	6402                	ld	s0,0(sp)
 80c:	0141                	addi	sp,sp,16
 80e:	8082                	ret

0000000000000810 <main>:
int
main(int argc, char *argv[])
{
 810:	1141                	addi	sp,sp,-16
 812:	e406                	sd	ra,8(sp)
 814:	e022                	sd	s0,0(sp)
 816:	0800                	addi	s0,sp,16
    // printf("-----------------------------sbark_and_fork-----------------------------\n");
    // sbark_and_fork();
    printf("-----------------------------fork_test-----------------------------\n");
 818:	00001517          	auipc	a0,0x1
 81c:	2e850513          	addi	a0,a0,744 # 1b00 <malloc+0xc22>
 820:	00000097          	auipc	ra,0x0
 824:	600080e7          	jalr	1536(ra) # e20 <printf>
    fork_test();
 828:	00000097          	auipc	ra,0x0
 82c:	f3e080e7          	jalr	-194(ra) # 766 <fork_test>
    // shiftcheck();
    exit(0);
 830:	4501                	li	a0,0
 832:	00000097          	auipc	ra,0x0
 836:	276080e7          	jalr	630(ra) # aa8 <exit>

000000000000083a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 83a:	1141                	addi	sp,sp,-16
 83c:	e422                	sd	s0,8(sp)
 83e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 840:	87aa                	mv	a5,a0
 842:	0585                	addi	a1,a1,1
 844:	0785                	addi	a5,a5,1
 846:	fff5c703          	lbu	a4,-1(a1) # ffffffff7fffffff <__global_pointer$+0xffffffff7fffdc9e>
 84a:	fee78fa3          	sb	a4,-1(a5)
 84e:	fb75                	bnez	a4,842 <strcpy+0x8>
    ;
  return os;
}
 850:	6422                	ld	s0,8(sp)
 852:	0141                	addi	sp,sp,16
 854:	8082                	ret

0000000000000856 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 856:	1141                	addi	sp,sp,-16
 858:	e422                	sd	s0,8(sp)
 85a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 85c:	00054783          	lbu	a5,0(a0)
 860:	cb91                	beqz	a5,874 <strcmp+0x1e>
 862:	0005c703          	lbu	a4,0(a1)
 866:	00f71763          	bne	a4,a5,874 <strcmp+0x1e>
    p++, q++;
 86a:	0505                	addi	a0,a0,1
 86c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 86e:	00054783          	lbu	a5,0(a0)
 872:	fbe5                	bnez	a5,862 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 874:	0005c503          	lbu	a0,0(a1)
}
 878:	40a7853b          	subw	a0,a5,a0
 87c:	6422                	ld	s0,8(sp)
 87e:	0141                	addi	sp,sp,16
 880:	8082                	ret

0000000000000882 <strlen>:

uint
strlen(const char *s)
{
 882:	1141                	addi	sp,sp,-16
 884:	e422                	sd	s0,8(sp)
 886:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 888:	00054783          	lbu	a5,0(a0)
 88c:	cf91                	beqz	a5,8a8 <strlen+0x26>
 88e:	0505                	addi	a0,a0,1
 890:	87aa                	mv	a5,a0
 892:	4685                	li	a3,1
 894:	9e89                	subw	a3,a3,a0
 896:	00f6853b          	addw	a0,a3,a5
 89a:	0785                	addi	a5,a5,1
 89c:	fff7c703          	lbu	a4,-1(a5)
 8a0:	fb7d                	bnez	a4,896 <strlen+0x14>
    ;
  return n;
}
 8a2:	6422                	ld	s0,8(sp)
 8a4:	0141                	addi	sp,sp,16
 8a6:	8082                	ret
  for(n = 0; s[n]; n++)
 8a8:	4501                	li	a0,0
 8aa:	bfe5                	j	8a2 <strlen+0x20>

00000000000008ac <memset>:

void*
memset(void *dst, int c, uint n)
{
 8ac:	1141                	addi	sp,sp,-16
 8ae:	e422                	sd	s0,8(sp)
 8b0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 8b2:	ca19                	beqz	a2,8c8 <memset+0x1c>
 8b4:	87aa                	mv	a5,a0
 8b6:	1602                	slli	a2,a2,0x20
 8b8:	9201                	srli	a2,a2,0x20
 8ba:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 8be:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 8c2:	0785                	addi	a5,a5,1
 8c4:	fee79de3          	bne	a5,a4,8be <memset+0x12>
  }
  return dst;
}
 8c8:	6422                	ld	s0,8(sp)
 8ca:	0141                	addi	sp,sp,16
 8cc:	8082                	ret

00000000000008ce <strchr>:

char*
strchr(const char *s, char c)
{
 8ce:	1141                	addi	sp,sp,-16
 8d0:	e422                	sd	s0,8(sp)
 8d2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 8d4:	00054783          	lbu	a5,0(a0)
 8d8:	cb99                	beqz	a5,8ee <strchr+0x20>
    if(*s == c)
 8da:	00f58763          	beq	a1,a5,8e8 <strchr+0x1a>
  for(; *s; s++)
 8de:	0505                	addi	a0,a0,1
 8e0:	00054783          	lbu	a5,0(a0)
 8e4:	fbfd                	bnez	a5,8da <strchr+0xc>
      return (char*)s;
  return 0;
 8e6:	4501                	li	a0,0
}
 8e8:	6422                	ld	s0,8(sp)
 8ea:	0141                	addi	sp,sp,16
 8ec:	8082                	ret
  return 0;
 8ee:	4501                	li	a0,0
 8f0:	bfe5                	j	8e8 <strchr+0x1a>

00000000000008f2 <gets>:

char*
gets(char *buf, int max)
{
 8f2:	711d                	addi	sp,sp,-96
 8f4:	ec86                	sd	ra,88(sp)
 8f6:	e8a2                	sd	s0,80(sp)
 8f8:	e4a6                	sd	s1,72(sp)
 8fa:	e0ca                	sd	s2,64(sp)
 8fc:	fc4e                	sd	s3,56(sp)
 8fe:	f852                	sd	s4,48(sp)
 900:	f456                	sd	s5,40(sp)
 902:	f05a                	sd	s6,32(sp)
 904:	ec5e                	sd	s7,24(sp)
 906:	1080                	addi	s0,sp,96
 908:	8baa                	mv	s7,a0
 90a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 90c:	892a                	mv	s2,a0
 90e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 910:	4aa9                	li	s5,10
 912:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 914:	89a6                	mv	s3,s1
 916:	2485                	addiw	s1,s1,1
 918:	0344d863          	bge	s1,s4,948 <gets+0x56>
    cc = read(0, &c, 1);
 91c:	4605                	li	a2,1
 91e:	faf40593          	addi	a1,s0,-81
 922:	4501                	li	a0,0
 924:	00000097          	auipc	ra,0x0
 928:	19c080e7          	jalr	412(ra) # ac0 <read>
    if(cc < 1)
 92c:	00a05e63          	blez	a0,948 <gets+0x56>
    buf[i++] = c;
 930:	faf44783          	lbu	a5,-81(s0)
 934:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 938:	01578763          	beq	a5,s5,946 <gets+0x54>
 93c:	0905                	addi	s2,s2,1
 93e:	fd679be3          	bne	a5,s6,914 <gets+0x22>
  for(i=0; i+1 < max; ){
 942:	89a6                	mv	s3,s1
 944:	a011                	j	948 <gets+0x56>
 946:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 948:	99de                	add	s3,s3,s7
 94a:	00098023          	sb	zero,0(s3)
  return buf;
}
 94e:	855e                	mv	a0,s7
 950:	60e6                	ld	ra,88(sp)
 952:	6446                	ld	s0,80(sp)
 954:	64a6                	ld	s1,72(sp)
 956:	6906                	ld	s2,64(sp)
 958:	79e2                	ld	s3,56(sp)
 95a:	7a42                	ld	s4,48(sp)
 95c:	7aa2                	ld	s5,40(sp)
 95e:	7b02                	ld	s6,32(sp)
 960:	6be2                	ld	s7,24(sp)
 962:	6125                	addi	sp,sp,96
 964:	8082                	ret

0000000000000966 <stat>:

int
stat(const char *n, struct stat *st)
{
 966:	1101                	addi	sp,sp,-32
 968:	ec06                	sd	ra,24(sp)
 96a:	e822                	sd	s0,16(sp)
 96c:	e426                	sd	s1,8(sp)
 96e:	e04a                	sd	s2,0(sp)
 970:	1000                	addi	s0,sp,32
 972:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 974:	4581                	li	a1,0
 976:	00000097          	auipc	ra,0x0
 97a:	172080e7          	jalr	370(ra) # ae8 <open>
  if(fd < 0)
 97e:	02054563          	bltz	a0,9a8 <stat+0x42>
 982:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 984:	85ca                	mv	a1,s2
 986:	00000097          	auipc	ra,0x0
 98a:	17a080e7          	jalr	378(ra) # b00 <fstat>
 98e:	892a                	mv	s2,a0
  close(fd);
 990:	8526                	mv	a0,s1
 992:	00000097          	auipc	ra,0x0
 996:	13e080e7          	jalr	318(ra) # ad0 <close>
  return r;
}
 99a:	854a                	mv	a0,s2
 99c:	60e2                	ld	ra,24(sp)
 99e:	6442                	ld	s0,16(sp)
 9a0:	64a2                	ld	s1,8(sp)
 9a2:	6902                	ld	s2,0(sp)
 9a4:	6105                	addi	sp,sp,32
 9a6:	8082                	ret
    return -1;
 9a8:	597d                	li	s2,-1
 9aa:	bfc5                	j	99a <stat+0x34>

00000000000009ac <atoi>:

int
atoi(const char *s)
{
 9ac:	1141                	addi	sp,sp,-16
 9ae:	e422                	sd	s0,8(sp)
 9b0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 9b2:	00054603          	lbu	a2,0(a0)
 9b6:	fd06079b          	addiw	a5,a2,-48
 9ba:	0ff7f793          	andi	a5,a5,255
 9be:	4725                	li	a4,9
 9c0:	02f76963          	bltu	a4,a5,9f2 <atoi+0x46>
 9c4:	86aa                	mv	a3,a0
  n = 0;
 9c6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 9c8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 9ca:	0685                	addi	a3,a3,1
 9cc:	0025179b          	slliw	a5,a0,0x2
 9d0:	9fa9                	addw	a5,a5,a0
 9d2:	0017979b          	slliw	a5,a5,0x1
 9d6:	9fb1                	addw	a5,a5,a2
 9d8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 9dc:	0006c603          	lbu	a2,0(a3)
 9e0:	fd06071b          	addiw	a4,a2,-48
 9e4:	0ff77713          	andi	a4,a4,255
 9e8:	fee5f1e3          	bgeu	a1,a4,9ca <atoi+0x1e>
  return n;
}
 9ec:	6422                	ld	s0,8(sp)
 9ee:	0141                	addi	sp,sp,16
 9f0:	8082                	ret
  n = 0;
 9f2:	4501                	li	a0,0
 9f4:	bfe5                	j	9ec <atoi+0x40>

00000000000009f6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 9f6:	1141                	addi	sp,sp,-16
 9f8:	e422                	sd	s0,8(sp)
 9fa:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 9fc:	02b57463          	bgeu	a0,a1,a24 <memmove+0x2e>
    while(n-- > 0)
 a00:	00c05f63          	blez	a2,a1e <memmove+0x28>
 a04:	1602                	slli	a2,a2,0x20
 a06:	9201                	srli	a2,a2,0x20
 a08:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 a0c:	872a                	mv	a4,a0
      *dst++ = *src++;
 a0e:	0585                	addi	a1,a1,1
 a10:	0705                	addi	a4,a4,1
 a12:	fff5c683          	lbu	a3,-1(a1)
 a16:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 a1a:	fee79ae3          	bne	a5,a4,a0e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 a1e:	6422                	ld	s0,8(sp)
 a20:	0141                	addi	sp,sp,16
 a22:	8082                	ret
    dst += n;
 a24:	00c50733          	add	a4,a0,a2
    src += n;
 a28:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 a2a:	fec05ae3          	blez	a2,a1e <memmove+0x28>
 a2e:	fff6079b          	addiw	a5,a2,-1
 a32:	1782                	slli	a5,a5,0x20
 a34:	9381                	srli	a5,a5,0x20
 a36:	fff7c793          	not	a5,a5
 a3a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 a3c:	15fd                	addi	a1,a1,-1
 a3e:	177d                	addi	a4,a4,-1
 a40:	0005c683          	lbu	a3,0(a1)
 a44:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 a48:	fee79ae3          	bne	a5,a4,a3c <memmove+0x46>
 a4c:	bfc9                	j	a1e <memmove+0x28>

0000000000000a4e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 a4e:	1141                	addi	sp,sp,-16
 a50:	e422                	sd	s0,8(sp)
 a52:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 a54:	ca05                	beqz	a2,a84 <memcmp+0x36>
 a56:	fff6069b          	addiw	a3,a2,-1
 a5a:	1682                	slli	a3,a3,0x20
 a5c:	9281                	srli	a3,a3,0x20
 a5e:	0685                	addi	a3,a3,1
 a60:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 a62:	00054783          	lbu	a5,0(a0)
 a66:	0005c703          	lbu	a4,0(a1)
 a6a:	00e79863          	bne	a5,a4,a7a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 a6e:	0505                	addi	a0,a0,1
    p2++;
 a70:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 a72:	fed518e3          	bne	a0,a3,a62 <memcmp+0x14>
  }
  return 0;
 a76:	4501                	li	a0,0
 a78:	a019                	j	a7e <memcmp+0x30>
      return *p1 - *p2;
 a7a:	40e7853b          	subw	a0,a5,a4
}
 a7e:	6422                	ld	s0,8(sp)
 a80:	0141                	addi	sp,sp,16
 a82:	8082                	ret
  return 0;
 a84:	4501                	li	a0,0
 a86:	bfe5                	j	a7e <memcmp+0x30>

0000000000000a88 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 a88:	1141                	addi	sp,sp,-16
 a8a:	e406                	sd	ra,8(sp)
 a8c:	e022                	sd	s0,0(sp)
 a8e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 a90:	00000097          	auipc	ra,0x0
 a94:	f66080e7          	jalr	-154(ra) # 9f6 <memmove>
}
 a98:	60a2                	ld	ra,8(sp)
 a9a:	6402                	ld	s0,0(sp)
 a9c:	0141                	addi	sp,sp,16
 a9e:	8082                	ret

0000000000000aa0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 aa0:	4885                	li	a7,1
 ecall
 aa2:	00000073          	ecall
 ret
 aa6:	8082                	ret

0000000000000aa8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 aa8:	4889                	li	a7,2
 ecall
 aaa:	00000073          	ecall
 ret
 aae:	8082                	ret

0000000000000ab0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 ab0:	488d                	li	a7,3
 ecall
 ab2:	00000073          	ecall
 ret
 ab6:	8082                	ret

0000000000000ab8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 ab8:	4891                	li	a7,4
 ecall
 aba:	00000073          	ecall
 ret
 abe:	8082                	ret

0000000000000ac0 <read>:
.global read
read:
 li a7, SYS_read
 ac0:	4895                	li	a7,5
 ecall
 ac2:	00000073          	ecall
 ret
 ac6:	8082                	ret

0000000000000ac8 <write>:
.global write
write:
 li a7, SYS_write
 ac8:	48c1                	li	a7,16
 ecall
 aca:	00000073          	ecall
 ret
 ace:	8082                	ret

0000000000000ad0 <close>:
.global close
close:
 li a7, SYS_close
 ad0:	48d5                	li	a7,21
 ecall
 ad2:	00000073          	ecall
 ret
 ad6:	8082                	ret

0000000000000ad8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 ad8:	4899                	li	a7,6
 ecall
 ada:	00000073          	ecall
 ret
 ade:	8082                	ret

0000000000000ae0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 ae0:	489d                	li	a7,7
 ecall
 ae2:	00000073          	ecall
 ret
 ae6:	8082                	ret

0000000000000ae8 <open>:
.global open
open:
 li a7, SYS_open
 ae8:	48bd                	li	a7,15
 ecall
 aea:	00000073          	ecall
 ret
 aee:	8082                	ret

0000000000000af0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 af0:	48c5                	li	a7,17
 ecall
 af2:	00000073          	ecall
 ret
 af6:	8082                	ret

0000000000000af8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 af8:	48c9                	li	a7,18
 ecall
 afa:	00000073          	ecall
 ret
 afe:	8082                	ret

0000000000000b00 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 b00:	48a1                	li	a7,8
 ecall
 b02:	00000073          	ecall
 ret
 b06:	8082                	ret

0000000000000b08 <link>:
.global link
link:
 li a7, SYS_link
 b08:	48cd                	li	a7,19
 ecall
 b0a:	00000073          	ecall
 ret
 b0e:	8082                	ret

0000000000000b10 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 b10:	48d1                	li	a7,20
 ecall
 b12:	00000073          	ecall
 ret
 b16:	8082                	ret

0000000000000b18 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 b18:	48a5                	li	a7,9
 ecall
 b1a:	00000073          	ecall
 ret
 b1e:	8082                	ret

0000000000000b20 <dup>:
.global dup
dup:
 li a7, SYS_dup
 b20:	48a9                	li	a7,10
 ecall
 b22:	00000073          	ecall
 ret
 b26:	8082                	ret

0000000000000b28 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 b28:	48ad                	li	a7,11
 ecall
 b2a:	00000073          	ecall
 ret
 b2e:	8082                	ret

0000000000000b30 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 b30:	48b1                	li	a7,12
 ecall
 b32:	00000073          	ecall
 ret
 b36:	8082                	ret

0000000000000b38 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 b38:	48b5                	li	a7,13
 ecall
 b3a:	00000073          	ecall
 ret
 b3e:	8082                	ret

0000000000000b40 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 b40:	48b9                	li	a7,14
 ecall
 b42:	00000073          	ecall
 ret
 b46:	8082                	ret

0000000000000b48 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 b48:	1101                	addi	sp,sp,-32
 b4a:	ec06                	sd	ra,24(sp)
 b4c:	e822                	sd	s0,16(sp)
 b4e:	1000                	addi	s0,sp,32
 b50:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 b54:	4605                	li	a2,1
 b56:	fef40593          	addi	a1,s0,-17
 b5a:	00000097          	auipc	ra,0x0
 b5e:	f6e080e7          	jalr	-146(ra) # ac8 <write>
}
 b62:	60e2                	ld	ra,24(sp)
 b64:	6442                	ld	s0,16(sp)
 b66:	6105                	addi	sp,sp,32
 b68:	8082                	ret

0000000000000b6a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 b6a:	7139                	addi	sp,sp,-64
 b6c:	fc06                	sd	ra,56(sp)
 b6e:	f822                	sd	s0,48(sp)
 b70:	f426                	sd	s1,40(sp)
 b72:	f04a                	sd	s2,32(sp)
 b74:	ec4e                	sd	s3,24(sp)
 b76:	0080                	addi	s0,sp,64
 b78:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 b7a:	c299                	beqz	a3,b80 <printint+0x16>
 b7c:	0805c863          	bltz	a1,c0c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 b80:	2581                	sext.w	a1,a1
  neg = 0;
 b82:	4881                	li	a7,0
 b84:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 b88:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 b8a:	2601                	sext.w	a2,a2
 b8c:	00001517          	auipc	a0,0x1
 b90:	fc450513          	addi	a0,a0,-60 # 1b50 <digits>
 b94:	883a                	mv	a6,a4
 b96:	2705                	addiw	a4,a4,1
 b98:	02c5f7bb          	remuw	a5,a1,a2
 b9c:	1782                	slli	a5,a5,0x20
 b9e:	9381                	srli	a5,a5,0x20
 ba0:	97aa                	add	a5,a5,a0
 ba2:	0007c783          	lbu	a5,0(a5)
 ba6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 baa:	0005879b          	sext.w	a5,a1
 bae:	02c5d5bb          	divuw	a1,a1,a2
 bb2:	0685                	addi	a3,a3,1
 bb4:	fec7f0e3          	bgeu	a5,a2,b94 <printint+0x2a>
  if(neg)
 bb8:	00088b63          	beqz	a7,bce <printint+0x64>
    buf[i++] = '-';
 bbc:	fd040793          	addi	a5,s0,-48
 bc0:	973e                	add	a4,a4,a5
 bc2:	02d00793          	li	a5,45
 bc6:	fef70823          	sb	a5,-16(a4)
 bca:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 bce:	02e05863          	blez	a4,bfe <printint+0x94>
 bd2:	fc040793          	addi	a5,s0,-64
 bd6:	00e78933          	add	s2,a5,a4
 bda:	fff78993          	addi	s3,a5,-1
 bde:	99ba                	add	s3,s3,a4
 be0:	377d                	addiw	a4,a4,-1
 be2:	1702                	slli	a4,a4,0x20
 be4:	9301                	srli	a4,a4,0x20
 be6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 bea:	fff94583          	lbu	a1,-1(s2)
 bee:	8526                	mv	a0,s1
 bf0:	00000097          	auipc	ra,0x0
 bf4:	f58080e7          	jalr	-168(ra) # b48 <putc>
  while(--i >= 0)
 bf8:	197d                	addi	s2,s2,-1
 bfa:	ff3918e3          	bne	s2,s3,bea <printint+0x80>
}
 bfe:	70e2                	ld	ra,56(sp)
 c00:	7442                	ld	s0,48(sp)
 c02:	74a2                	ld	s1,40(sp)
 c04:	7902                	ld	s2,32(sp)
 c06:	69e2                	ld	s3,24(sp)
 c08:	6121                	addi	sp,sp,64
 c0a:	8082                	ret
    x = -xx;
 c0c:	40b005bb          	negw	a1,a1
    neg = 1;
 c10:	4885                	li	a7,1
    x = -xx;
 c12:	bf8d                	j	b84 <printint+0x1a>

0000000000000c14 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 c14:	7119                	addi	sp,sp,-128
 c16:	fc86                	sd	ra,120(sp)
 c18:	f8a2                	sd	s0,112(sp)
 c1a:	f4a6                	sd	s1,104(sp)
 c1c:	f0ca                	sd	s2,96(sp)
 c1e:	ecce                	sd	s3,88(sp)
 c20:	e8d2                	sd	s4,80(sp)
 c22:	e4d6                	sd	s5,72(sp)
 c24:	e0da                	sd	s6,64(sp)
 c26:	fc5e                	sd	s7,56(sp)
 c28:	f862                	sd	s8,48(sp)
 c2a:	f466                	sd	s9,40(sp)
 c2c:	f06a                	sd	s10,32(sp)
 c2e:	ec6e                	sd	s11,24(sp)
 c30:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 c32:	0005c903          	lbu	s2,0(a1)
 c36:	18090f63          	beqz	s2,dd4 <vprintf+0x1c0>
 c3a:	8aaa                	mv	s5,a0
 c3c:	8b32                	mv	s6,a2
 c3e:	00158493          	addi	s1,a1,1
  state = 0;
 c42:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 c44:	02500a13          	li	s4,37
      if(c == 'd'){
 c48:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 c4c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 c50:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 c54:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 c58:	00001b97          	auipc	s7,0x1
 c5c:	ef8b8b93          	addi	s7,s7,-264 # 1b50 <digits>
 c60:	a839                	j	c7e <vprintf+0x6a>
        putc(fd, c);
 c62:	85ca                	mv	a1,s2
 c64:	8556                	mv	a0,s5
 c66:	00000097          	auipc	ra,0x0
 c6a:	ee2080e7          	jalr	-286(ra) # b48 <putc>
 c6e:	a019                	j	c74 <vprintf+0x60>
    } else if(state == '%'){
 c70:	01498f63          	beq	s3,s4,c8e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 c74:	0485                	addi	s1,s1,1
 c76:	fff4c903          	lbu	s2,-1(s1)
 c7a:	14090d63          	beqz	s2,dd4 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 c7e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 c82:	fe0997e3          	bnez	s3,c70 <vprintf+0x5c>
      if(c == '%'){
 c86:	fd479ee3          	bne	a5,s4,c62 <vprintf+0x4e>
        state = '%';
 c8a:	89be                	mv	s3,a5
 c8c:	b7e5                	j	c74 <vprintf+0x60>
      if(c == 'd'){
 c8e:	05878063          	beq	a5,s8,cce <vprintf+0xba>
      } else if(c == 'l') {
 c92:	05978c63          	beq	a5,s9,cea <vprintf+0xd6>
      } else if(c == 'x') {
 c96:	07a78863          	beq	a5,s10,d06 <vprintf+0xf2>
      } else if(c == 'p') {
 c9a:	09b78463          	beq	a5,s11,d22 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 c9e:	07300713          	li	a4,115
 ca2:	0ce78663          	beq	a5,a4,d6e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 ca6:	06300713          	li	a4,99
 caa:	0ee78e63          	beq	a5,a4,da6 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 cae:	11478863          	beq	a5,s4,dbe <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 cb2:	85d2                	mv	a1,s4
 cb4:	8556                	mv	a0,s5
 cb6:	00000097          	auipc	ra,0x0
 cba:	e92080e7          	jalr	-366(ra) # b48 <putc>
        putc(fd, c);
 cbe:	85ca                	mv	a1,s2
 cc0:	8556                	mv	a0,s5
 cc2:	00000097          	auipc	ra,0x0
 cc6:	e86080e7          	jalr	-378(ra) # b48 <putc>
      }
      state = 0;
 cca:	4981                	li	s3,0
 ccc:	b765                	j	c74 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 cce:	008b0913          	addi	s2,s6,8
 cd2:	4685                	li	a3,1
 cd4:	4629                	li	a2,10
 cd6:	000b2583          	lw	a1,0(s6)
 cda:	8556                	mv	a0,s5
 cdc:	00000097          	auipc	ra,0x0
 ce0:	e8e080e7          	jalr	-370(ra) # b6a <printint>
 ce4:	8b4a                	mv	s6,s2
      state = 0;
 ce6:	4981                	li	s3,0
 ce8:	b771                	j	c74 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 cea:	008b0913          	addi	s2,s6,8
 cee:	4681                	li	a3,0
 cf0:	4629                	li	a2,10
 cf2:	000b2583          	lw	a1,0(s6)
 cf6:	8556                	mv	a0,s5
 cf8:	00000097          	auipc	ra,0x0
 cfc:	e72080e7          	jalr	-398(ra) # b6a <printint>
 d00:	8b4a                	mv	s6,s2
      state = 0;
 d02:	4981                	li	s3,0
 d04:	bf85                	j	c74 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 d06:	008b0913          	addi	s2,s6,8
 d0a:	4681                	li	a3,0
 d0c:	4641                	li	a2,16
 d0e:	000b2583          	lw	a1,0(s6)
 d12:	8556                	mv	a0,s5
 d14:	00000097          	auipc	ra,0x0
 d18:	e56080e7          	jalr	-426(ra) # b6a <printint>
 d1c:	8b4a                	mv	s6,s2
      state = 0;
 d1e:	4981                	li	s3,0
 d20:	bf91                	j	c74 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 d22:	008b0793          	addi	a5,s6,8
 d26:	f8f43423          	sd	a5,-120(s0)
 d2a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 d2e:	03000593          	li	a1,48
 d32:	8556                	mv	a0,s5
 d34:	00000097          	auipc	ra,0x0
 d38:	e14080e7          	jalr	-492(ra) # b48 <putc>
  putc(fd, 'x');
 d3c:	85ea                	mv	a1,s10
 d3e:	8556                	mv	a0,s5
 d40:	00000097          	auipc	ra,0x0
 d44:	e08080e7          	jalr	-504(ra) # b48 <putc>
 d48:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 d4a:	03c9d793          	srli	a5,s3,0x3c
 d4e:	97de                	add	a5,a5,s7
 d50:	0007c583          	lbu	a1,0(a5)
 d54:	8556                	mv	a0,s5
 d56:	00000097          	auipc	ra,0x0
 d5a:	df2080e7          	jalr	-526(ra) # b48 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 d5e:	0992                	slli	s3,s3,0x4
 d60:	397d                	addiw	s2,s2,-1
 d62:	fe0914e3          	bnez	s2,d4a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 d66:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 d6a:	4981                	li	s3,0
 d6c:	b721                	j	c74 <vprintf+0x60>
        s = va_arg(ap, char*);
 d6e:	008b0993          	addi	s3,s6,8
 d72:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 d76:	02090163          	beqz	s2,d98 <vprintf+0x184>
        while(*s != 0){
 d7a:	00094583          	lbu	a1,0(s2)
 d7e:	c9a1                	beqz	a1,dce <vprintf+0x1ba>
          putc(fd, *s);
 d80:	8556                	mv	a0,s5
 d82:	00000097          	auipc	ra,0x0
 d86:	dc6080e7          	jalr	-570(ra) # b48 <putc>
          s++;
 d8a:	0905                	addi	s2,s2,1
        while(*s != 0){
 d8c:	00094583          	lbu	a1,0(s2)
 d90:	f9e5                	bnez	a1,d80 <vprintf+0x16c>
        s = va_arg(ap, char*);
 d92:	8b4e                	mv	s6,s3
      state = 0;
 d94:	4981                	li	s3,0
 d96:	bdf9                	j	c74 <vprintf+0x60>
          s = "(null)";
 d98:	00001917          	auipc	s2,0x1
 d9c:	db090913          	addi	s2,s2,-592 # 1b48 <malloc+0xc6a>
        while(*s != 0){
 da0:	02800593          	li	a1,40
 da4:	bff1                	j	d80 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 da6:	008b0913          	addi	s2,s6,8
 daa:	000b4583          	lbu	a1,0(s6)
 dae:	8556                	mv	a0,s5
 db0:	00000097          	auipc	ra,0x0
 db4:	d98080e7          	jalr	-616(ra) # b48 <putc>
 db8:	8b4a                	mv	s6,s2
      state = 0;
 dba:	4981                	li	s3,0
 dbc:	bd65                	j	c74 <vprintf+0x60>
        putc(fd, c);
 dbe:	85d2                	mv	a1,s4
 dc0:	8556                	mv	a0,s5
 dc2:	00000097          	auipc	ra,0x0
 dc6:	d86080e7          	jalr	-634(ra) # b48 <putc>
      state = 0;
 dca:	4981                	li	s3,0
 dcc:	b565                	j	c74 <vprintf+0x60>
        s = va_arg(ap, char*);
 dce:	8b4e                	mv	s6,s3
      state = 0;
 dd0:	4981                	li	s3,0
 dd2:	b54d                	j	c74 <vprintf+0x60>
    }
  }
}
 dd4:	70e6                	ld	ra,120(sp)
 dd6:	7446                	ld	s0,112(sp)
 dd8:	74a6                	ld	s1,104(sp)
 dda:	7906                	ld	s2,96(sp)
 ddc:	69e6                	ld	s3,88(sp)
 dde:	6a46                	ld	s4,80(sp)
 de0:	6aa6                	ld	s5,72(sp)
 de2:	6b06                	ld	s6,64(sp)
 de4:	7be2                	ld	s7,56(sp)
 de6:	7c42                	ld	s8,48(sp)
 de8:	7ca2                	ld	s9,40(sp)
 dea:	7d02                	ld	s10,32(sp)
 dec:	6de2                	ld	s11,24(sp)
 dee:	6109                	addi	sp,sp,128
 df0:	8082                	ret

0000000000000df2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 df2:	715d                	addi	sp,sp,-80
 df4:	ec06                	sd	ra,24(sp)
 df6:	e822                	sd	s0,16(sp)
 df8:	1000                	addi	s0,sp,32
 dfa:	e010                	sd	a2,0(s0)
 dfc:	e414                	sd	a3,8(s0)
 dfe:	e818                	sd	a4,16(s0)
 e00:	ec1c                	sd	a5,24(s0)
 e02:	03043023          	sd	a6,32(s0)
 e06:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 e0a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 e0e:	8622                	mv	a2,s0
 e10:	00000097          	auipc	ra,0x0
 e14:	e04080e7          	jalr	-508(ra) # c14 <vprintf>
}
 e18:	60e2                	ld	ra,24(sp)
 e1a:	6442                	ld	s0,16(sp)
 e1c:	6161                	addi	sp,sp,80
 e1e:	8082                	ret

0000000000000e20 <printf>:

void
printf(const char *fmt, ...)
{
 e20:	711d                	addi	sp,sp,-96
 e22:	ec06                	sd	ra,24(sp)
 e24:	e822                	sd	s0,16(sp)
 e26:	1000                	addi	s0,sp,32
 e28:	e40c                	sd	a1,8(s0)
 e2a:	e810                	sd	a2,16(s0)
 e2c:	ec14                	sd	a3,24(s0)
 e2e:	f018                	sd	a4,32(s0)
 e30:	f41c                	sd	a5,40(s0)
 e32:	03043823          	sd	a6,48(s0)
 e36:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 e3a:	00840613          	addi	a2,s0,8
 e3e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 e42:	85aa                	mv	a1,a0
 e44:	4505                	li	a0,1
 e46:	00000097          	auipc	ra,0x0
 e4a:	dce080e7          	jalr	-562(ra) # c14 <vprintf>
}
 e4e:	60e2                	ld	ra,24(sp)
 e50:	6442                	ld	s0,16(sp)
 e52:	6125                	addi	sp,sp,96
 e54:	8082                	ret

0000000000000e56 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 e56:	1141                	addi	sp,sp,-16
 e58:	e422                	sd	s0,8(sp)
 e5a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 e5c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e60:	00001797          	auipc	a5,0x1
 e64:	d087b783          	ld	a5,-760(a5) # 1b68 <freep>
 e68:	a805                	j	e98 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 e6a:	4618                	lw	a4,8(a2)
 e6c:	9db9                	addw	a1,a1,a4
 e6e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 e72:	6398                	ld	a4,0(a5)
 e74:	6318                	ld	a4,0(a4)
 e76:	fee53823          	sd	a4,-16(a0)
 e7a:	a091                	j	ebe <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 e7c:	ff852703          	lw	a4,-8(a0)
 e80:	9e39                	addw	a2,a2,a4
 e82:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 e84:	ff053703          	ld	a4,-16(a0)
 e88:	e398                	sd	a4,0(a5)
 e8a:	a099                	j	ed0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e8c:	6398                	ld	a4,0(a5)
 e8e:	00e7e463          	bltu	a5,a4,e96 <free+0x40>
 e92:	00e6ea63          	bltu	a3,a4,ea6 <free+0x50>
{
 e96:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e98:	fed7fae3          	bgeu	a5,a3,e8c <free+0x36>
 e9c:	6398                	ld	a4,0(a5)
 e9e:	00e6e463          	bltu	a3,a4,ea6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ea2:	fee7eae3          	bltu	a5,a4,e96 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 ea6:	ff852583          	lw	a1,-8(a0)
 eaa:	6390                	ld	a2,0(a5)
 eac:	02059813          	slli	a6,a1,0x20
 eb0:	01c85713          	srli	a4,a6,0x1c
 eb4:	9736                	add	a4,a4,a3
 eb6:	fae60ae3          	beq	a2,a4,e6a <free+0x14>
    bp->s.ptr = p->s.ptr;
 eba:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 ebe:	4790                	lw	a2,8(a5)
 ec0:	02061593          	slli	a1,a2,0x20
 ec4:	01c5d713          	srli	a4,a1,0x1c
 ec8:	973e                	add	a4,a4,a5
 eca:	fae689e3          	beq	a3,a4,e7c <free+0x26>
  } else
    p->s.ptr = bp;
 ece:	e394                	sd	a3,0(a5)
  freep = p;
 ed0:	00001717          	auipc	a4,0x1
 ed4:	c8f73c23          	sd	a5,-872(a4) # 1b68 <freep>
}
 ed8:	6422                	ld	s0,8(sp)
 eda:	0141                	addi	sp,sp,16
 edc:	8082                	ret

0000000000000ede <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 ede:	7139                	addi	sp,sp,-64
 ee0:	fc06                	sd	ra,56(sp)
 ee2:	f822                	sd	s0,48(sp)
 ee4:	f426                	sd	s1,40(sp)
 ee6:	f04a                	sd	s2,32(sp)
 ee8:	ec4e                	sd	s3,24(sp)
 eea:	e852                	sd	s4,16(sp)
 eec:	e456                	sd	s5,8(sp)
 eee:	e05a                	sd	s6,0(sp)
 ef0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ef2:	02051493          	slli	s1,a0,0x20
 ef6:	9081                	srli	s1,s1,0x20
 ef8:	04bd                	addi	s1,s1,15
 efa:	8091                	srli	s1,s1,0x4
 efc:	0014899b          	addiw	s3,s1,1
 f00:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 f02:	00001517          	auipc	a0,0x1
 f06:	c6653503          	ld	a0,-922(a0) # 1b68 <freep>
 f0a:	c515                	beqz	a0,f36 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f0c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 f0e:	4798                	lw	a4,8(a5)
 f10:	02977f63          	bgeu	a4,s1,f4e <malloc+0x70>
 f14:	8a4e                	mv	s4,s3
 f16:	0009871b          	sext.w	a4,s3
 f1a:	6685                	lui	a3,0x1
 f1c:	00d77363          	bgeu	a4,a3,f22 <malloc+0x44>
 f20:	6a05                	lui	s4,0x1
 f22:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 f26:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 f2a:	00001917          	auipc	s2,0x1
 f2e:	c3e90913          	addi	s2,s2,-962 # 1b68 <freep>
  if(p == (char*)-1)
 f32:	5afd                	li	s5,-1
 f34:	a895                	j	fa8 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 f36:	00001797          	auipc	a5,0x1
 f3a:	c3a78793          	addi	a5,a5,-966 # 1b70 <base>
 f3e:	00001717          	auipc	a4,0x1
 f42:	c2f73523          	sd	a5,-982(a4) # 1b68 <freep>
 f46:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 f48:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 f4c:	b7e1                	j	f14 <malloc+0x36>
      if(p->s.size == nunits)
 f4e:	02e48c63          	beq	s1,a4,f86 <malloc+0xa8>
        p->s.size -= nunits;
 f52:	4137073b          	subw	a4,a4,s3
 f56:	c798                	sw	a4,8(a5)
        p += p->s.size;
 f58:	02071693          	slli	a3,a4,0x20
 f5c:	01c6d713          	srli	a4,a3,0x1c
 f60:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 f62:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 f66:	00001717          	auipc	a4,0x1
 f6a:	c0a73123          	sd	a0,-1022(a4) # 1b68 <freep>
      return (void*)(p + 1);
 f6e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 f72:	70e2                	ld	ra,56(sp)
 f74:	7442                	ld	s0,48(sp)
 f76:	74a2                	ld	s1,40(sp)
 f78:	7902                	ld	s2,32(sp)
 f7a:	69e2                	ld	s3,24(sp)
 f7c:	6a42                	ld	s4,16(sp)
 f7e:	6aa2                	ld	s5,8(sp)
 f80:	6b02                	ld	s6,0(sp)
 f82:	6121                	addi	sp,sp,64
 f84:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 f86:	6398                	ld	a4,0(a5)
 f88:	e118                	sd	a4,0(a0)
 f8a:	bff1                	j	f66 <malloc+0x88>
  hp->s.size = nu;
 f8c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 f90:	0541                	addi	a0,a0,16
 f92:	00000097          	auipc	ra,0x0
 f96:	ec4080e7          	jalr	-316(ra) # e56 <free>
  return freep;
 f9a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 f9e:	d971                	beqz	a0,f72 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 fa0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 fa2:	4798                	lw	a4,8(a5)
 fa4:	fa9775e3          	bgeu	a4,s1,f4e <malloc+0x70>
    if(p == freep)
 fa8:	00093703          	ld	a4,0(s2)
 fac:	853e                	mv	a0,a5
 fae:	fef719e3          	bne	a4,a5,fa0 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 fb2:	8552                	mv	a0,s4
 fb4:	00000097          	auipc	ra,0x0
 fb8:	b7c080e7          	jalr	-1156(ra) # b30 <sbrk>
  if(p == (char*)-1)
 fbc:	fd5518e3          	bne	a0,s5,f8c <malloc+0xae>
        return 0;
 fc0:	4501                	li	a0,0
 fc2:	bf45                	j	f72 <malloc+0x94>
