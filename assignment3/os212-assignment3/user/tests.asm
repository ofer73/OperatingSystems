
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
  14:	fd098993          	addi	s3,s3,-48 # fe0 <malloc+0xea>
    for (int i = 0; i < 22; i++)
  18:	4959                	li	s2,22
        printf("sbrk %d\n",i);
  1a:	85a6                	mv	a1,s1
  1c:	854e                	mv	a0,s3
  1e:	00001097          	auipc	ra,0x1
  22:	e1a080e7          	jalr	-486(ra) # e38 <printf>
        sbrk(4096);
  26:	6505                	lui	a0,0x1
  28:	00001097          	auipc	ra,0x1
  2c:	b20080e7          	jalr	-1248(ra) # b48 <sbrk>
    for (int i = 0; i < 22; i++)
  30:	2485                	addiw	s1,s1,1
  32:	ff2494e3          	bne	s1,s2,1a <sbark_and_fork+0x1a>
    }
    // notice 6 pages swaped out
    int pid= fork();
  36:	00001097          	auipc	ra,0x1
  3a:	a82080e7          	jalr	-1406(ra) # ab8 <fork>
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
  46:	a86080e7          	jalr	-1402(ra) # ac8 <wait>
    printf("test: finished test\n");
  4a:	00001517          	auipc	a0,0x1
  4e:	fc650513          	addi	a0,a0,-58 # 1010 <malloc+0x11a>
  52:	00001097          	auipc	ra,0x1
  56:	de6080e7          	jalr	-538(ra) # e38 <printf>
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
  6e:	f8650513          	addi	a0,a0,-122 # ff0 <malloc+0xfa>
  72:	00001097          	auipc	ra,0x1
  76:	dc6080e7          	jalr	-570(ra) # e38 <printf>
        sbrk(4096);
  7a:	6505                	lui	a0,0x1
  7c:	00001097          	auipc	ra,0x1
  80:	acc080e7          	jalr	-1332(ra) # b48 <sbrk>
        printf("child sbrk neg\n");
  84:	00001517          	auipc	a0,0x1
  88:	f7c50513          	addi	a0,a0,-132 # 1000 <malloc+0x10a>
  8c:	00001097          	auipc	ra,0x1
  90:	dac080e7          	jalr	-596(ra) # e38 <printf>
        sbrk(-4096 * 14);
  94:	7549                	lui	a0,0xffff2
  96:	00001097          	auipc	ra,0x1
  9a:	ab2080e7          	jalr	-1358(ra) # b48 <sbrk>
        printf("child sbrk\n");
  9e:	00001517          	auipc	a0,0x1
  a2:	f5250513          	addi	a0,a0,-174 # ff0 <malloc+0xfa>
  a6:	00001097          	auipc	ra,0x1
  aa:	d92080e7          	jalr	-622(ra) # e38 <printf>
        sbrk(4096 * 4);
  ae:	6511                	lui	a0,0x4
  b0:	00001097          	auipc	ra,0x1
  b4:	a98080e7          	jalr	-1384(ra) # b48 <sbrk>
        sleep(5);
  b8:	4515                	li	a0,5
  ba:	00001097          	auipc	ra,0x1
  be:	a96080e7          	jalr	-1386(ra) # b50 <sleep>
        exit(0);
  c2:	4501                	li	a0,0
  c4:	00001097          	auipc	ra,0x1
  c8:	9fc080e7          	jalr	-1540(ra) # ac0 <exit>

00000000000000cc <just_a_func>:
int
just_a_func(){
  cc:	1141                	addi	sp,sp,-16
  ce:	e406                	sd	ra,8(sp)
  d0:	e022                	sd	s0,0(sp)
  d2:	0800                	addi	s0,sp,16
    printf("func\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	f5450513          	addi	a0,a0,-172 # 1028 <malloc+0x132>
  dc:	00001097          	auipc	ra,0x1
  e0:	d5c080e7          	jalr	-676(ra) # e38 <printf>
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
 100:	f3450513          	addi	a0,a0,-204 # 1030 <malloc+0x13a>
 104:	00001097          	auipc	ra,0x1
 108:	d34080e7          	jalr	-716(ra) # e38 <printf>
    printf( "-------------allocating 16 pages-----------------\n");
 10c:	00001517          	auipc	a0,0x1
 110:	f5c50513          	addi	a0,a0,-164 # 1068 <malloc+0x172>
 114:	00001097          	auipc	ra,0x1
 118:	d24080e7          	jalr	-732(ra) # e38 <printf>
    if(fork() == 0){
 11c:	00001097          	auipc	ra,0x1
 120:	99c080e7          	jalr	-1636(ra) # ab8 <fork>
 124:	cd11                	beqz	a0,140 <fork_SCFIFO+0x52>
        printf("---------passed scifo test!!!!----------\n");
        gets(in,3);
        exit(0);

    }
    wait(0);
 126:	4501                	li	a0,0
 128:	00001097          	auipc	ra,0x1
 12c:	9a0080e7          	jalr	-1632(ra) # ac8 <wait>
    return 0;
}
 130:	4501                	li	a0,0
 132:	60ae                	ld	ra,200(sp)
 134:	640e                	ld	s0,192(sp)
 136:	74ea                	ld	s1,184(sp)
 138:	794a                	ld	s2,176(sp)
 13a:	79aa                	ld	s3,168(sp)
 13c:	6169                	addi	sp,sp,208
 13e:	8082                	ret
 140:	84aa                	mv	s1,a0
 142:	f3840913          	addi	s2,s0,-200
        for(int i = 0; i < 16; i++){
 146:	49c1                	li	s3,16
            pages[i] = (int*)sbrk(PGSIZE);
 148:	6505                	lui	a0,0x1
 14a:	00001097          	auipc	ra,0x1
 14e:	9fe080e7          	jalr	-1538(ra) # b48 <sbrk>
 152:	00a93023          	sd	a0,0(s2)
            *pages[i] = i;
 156:	c104                	sw	s1,0(a0)
        for(int i = 0; i < 16; i++){
 158:	2485                	addiw	s1,s1,1
 15a:	0921                	addi	s2,s2,8
 15c:	ff3496e3          	bne	s1,s3,148 <fork_SCFIFO+0x5a>
        printf( "-------------now add another page. page[0] should move to the file-----------------\n");
 160:	00001517          	auipc	a0,0x1
 164:	f4050513          	addi	a0,a0,-192 # 10a0 <malloc+0x1aa>
 168:	00001097          	auipc	ra,0x1
 16c:	cd0080e7          	jalr	-816(ra) # e38 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 170:	6505                	lui	a0,0x1
 172:	00001097          	auipc	ra,0x1
 176:	9d6080e7          	jalr	-1578(ra) # b48 <sbrk>
        printf( "-------------now access to pages[1]-----------------\n");
 17a:	00001517          	auipc	a0,0x1
 17e:	f7e50513          	addi	a0,a0,-130 # 10f8 <malloc+0x202>
 182:	00001097          	auipc	ra,0x1
 186:	cb6080e7          	jalr	-842(ra) # e38 <printf>
        printf("pages[1] contains  %d\n",*pages[1]);
 18a:	f4043783          	ld	a5,-192(s0)
 18e:	438c                	lw	a1,0(a5)
 190:	00001517          	auipc	a0,0x1
 194:	fa050513          	addi	a0,a0,-96 # 1130 <malloc+0x23a>
 198:	00001097          	auipc	ra,0x1
 19c:	ca0080e7          	jalr	-864(ra) # e38 <printf>
        printf( "-------------now add another page. page[2] should move to the file-----------------\n");
 1a0:	00001517          	auipc	a0,0x1
 1a4:	fa850513          	addi	a0,a0,-88 # 1148 <malloc+0x252>
 1a8:	00001097          	auipc	ra,0x1
 1ac:	c90080e7          	jalr	-880(ra) # e38 <printf>
        pages[17] = (int*)sbrk(PGSIZE);
 1b0:	6505                	lui	a0,0x1
 1b2:	00001097          	auipc	ra,0x1
 1b6:	996080e7          	jalr	-1642(ra) # b48 <sbrk>
        printf( "-------------now acess to page[2] should cause pagefault-----------------\n");
 1ba:	00001517          	auipc	a0,0x1
 1be:	fe650513          	addi	a0,a0,-26 # 11a0 <malloc+0x2aa>
 1c2:	00001097          	auipc	ra,0x1
 1c6:	c76080e7          	jalr	-906(ra) # e38 <printf>
        printf("pages[2] contains  %d\n",*pages[2]);
 1ca:	f4843783          	ld	a5,-184(s0)
 1ce:	438c                	lw	a1,0(a5)
 1d0:	00001517          	auipc	a0,0x1
 1d4:	02050513          	addi	a0,a0,32 # 11f0 <malloc+0x2fa>
 1d8:	00001097          	auipc	ra,0x1
 1dc:	c60080e7          	jalr	-928(ra) # e38 <printf>
        printf("---------passed scifo test!!!!----------\n");
 1e0:	00001517          	auipc	a0,0x1
 1e4:	02850513          	addi	a0,a0,40 # 1208 <malloc+0x312>
 1e8:	00001097          	auipc	ra,0x1
 1ec:	c50080e7          	jalr	-944(ra) # e38 <printf>
        gets(in,3);
 1f0:	458d                	li	a1,3
 1f2:	fc840513          	addi	a0,s0,-56
 1f6:	00000097          	auipc	ra,0x0
 1fa:	714080e7          	jalr	1812(ra) # 90a <gets>
        exit(0);
 1fe:	4501                	li	a0,0
 200:	00001097          	auipc	ra,0x1
 204:	8c0080e7          	jalr	-1856(ra) # ac0 <exit>

0000000000000208 <NFUA_test>:

int 
NFUA_test(){
 208:	7131                	addi	sp,sp,-192
 20a:	fd06                	sd	ra,184(sp)
 20c:	f922                	sd	s0,176(sp)
 20e:	f526                	sd	s1,168(sp)
 210:	f14a                	sd	s2,160(sp)
 212:	ed4e                	sd	s3,152(sp)
 214:	e952                	sd	s4,144(sp)
 216:	0180                	addi	s0,sp,192
    int* pages[18];
    ////-----NFU + AGING----------///////////
    printf( "--------------------NFU + AGING:----------------------\n");
 218:	00001517          	auipc	a0,0x1
 21c:	02050513          	addi	a0,a0,32 # 1238 <malloc+0x342>
 220:	00001097          	auipc	ra,0x1
 224:	c18080e7          	jalr	-1000(ra) # e38 <printf>
    printf( "-------------allocating 16 pages-----------------\n");
 228:	00001517          	auipc	a0,0x1
 22c:	e4050513          	addi	a0,a0,-448 # 1068 <malloc+0x172>
 230:	00001097          	auipc	ra,0x1
 234:	c08080e7          	jalr	-1016(ra) # e38 <printf>
    if(fork() == 0){
 238:	00001097          	auipc	ra,0x1
 23c:	880080e7          	jalr	-1920(ra) # ab8 <fork>
 240:	cd19                	beqz	a0,25e <NFUA_test+0x56>
        pages[17] = (int*)sbrk(PGSIZE);
        printf("---------finished NFUA test!!!!----------\n");
        exit(0);

    }
    wait(0);
 242:	4501                	li	a0,0
 244:	00001097          	auipc	ra,0x1
 248:	884080e7          	jalr	-1916(ra) # ac8 <wait>
    return 1;
}
 24c:	4505                	li	a0,1
 24e:	70ea                	ld	ra,184(sp)
 250:	744a                	ld	s0,176(sp)
 252:	74aa                	ld	s1,168(sp)
 254:	790a                	ld	s2,160(sp)
 256:	69ea                	ld	s3,152(sp)
 258:	6a4a                	ld	s4,144(sp)
 25a:	6129                	addi	sp,sp,192
 25c:	8082                	ret
 25e:	84aa                	mv	s1,a0
 260:	f4040913          	addi	s2,s0,-192
    if(fork() == 0){
 264:	89ca                	mv	s3,s2
        for(int i = 0; i < 16; i++){
 266:	4a41                	li	s4,16
            pages[i] = (int*)sbrk(PGSIZE);
 268:	6505                	lui	a0,0x1
 26a:	00001097          	auipc	ra,0x1
 26e:	8de080e7          	jalr	-1826(ra) # b48 <sbrk>
 272:	00a9b023          	sd	a0,0(s3)
            *pages[i] = i;
 276:	c104                	sw	s1,0(a0)
        for(int i = 0; i < 16; i++){
 278:	2485                	addiw	s1,s1,1
 27a:	09a1                	addi	s3,s3,8
 27c:	ff4496e3          	bne	s1,s4,268 <NFUA_test+0x60>
        sleep(20);
 280:	4551                	li	a0,20
 282:	00001097          	auipc	ra,0x1
 286:	8ce080e7          	jalr	-1842(ra) # b50 <sleep>
        printf("first we will access page 8 %d,\n", *pages[8]);
 28a:	f8043483          	ld	s1,-128(s0)
 28e:	408c                	lw	a1,0(s1)
 290:	00001517          	auipc	a0,0x1
 294:	fe050513          	addi	a0,a0,-32 # 1270 <malloc+0x37a>
 298:	00001097          	auipc	ra,0x1
 29c:	ba0080e7          	jalr	-1120(ra) # e38 <printf>
        sleep(2);
 2a0:	4509                	li	a0,2
 2a2:	00001097          	auipc	ra,0x1
 2a6:	8ae080e7          	jalr	-1874(ra) # b50 <sleep>
        printf( "-------------now access all pages except 8-----------------\n");
 2aa:	00001517          	auipc	a0,0x1
 2ae:	fee50513          	addi	a0,a0,-18 # 1298 <malloc+0x3a2>
 2b2:	00001097          	auipc	ra,0x1
 2b6:	b86080e7          	jalr	-1146(ra) # e38 <printf>
 2ba:	4705                	li	a4,1
 2bc:	4781                	li	a5,0
            if (i!=8)
 2be:	45a1                	li	a1,8
        for(int i = 0; i < 16; i++){
 2c0:	453d                	li	a0,15
 2c2:	a021                	j	2ca <NFUA_test+0xc2>
 2c4:	2785                	addiw	a5,a5,1
 2c6:	2705                	addiw	a4,a4,1
 2c8:	0921                	addi	s2,s2,8
 2ca:	0007869b          	sext.w	a3,a5
            if (i!=8)
 2ce:	feb68be3          	beq	a3,a1,2c4 <NFUA_test+0xbc>
                *pages[i] = i;
 2d2:	00093603          	ld	a2,0(s2)
 2d6:	c214                	sw	a3,0(a2)
        for(int i = 0; i < 16; i++){
 2d8:	0007069b          	sext.w	a3,a4
 2dc:	fed554e3          	bge	a0,a3,2c4 <NFUA_test+0xbc>
        sleep(2);
 2e0:	4509                	li	a0,2
 2e2:	00001097          	auipc	ra,0x1
 2e6:	86e080e7          	jalr	-1938(ra) # b50 <sleep>
        printf( "------------- creating a new page, page 8 should be paged out -----------------\n");
 2ea:	00001517          	auipc	a0,0x1
 2ee:	fee50513          	addi	a0,a0,-18 # 12d8 <malloc+0x3e2>
 2f2:	00001097          	auipc	ra,0x1
 2f6:	b46080e7          	jalr	-1210(ra) # e38 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 2fa:	6505                	lui	a0,0x1
 2fc:	00001097          	auipc	ra,0x1
 300:	84c080e7          	jalr	-1972(ra) # b48 <sbrk>
        printf( "------------- accessing page 8 -> should cause pagefault-----------------\n");
 304:	00001517          	auipc	a0,0x1
 308:	02c50513          	addi	a0,a0,44 # 1330 <malloc+0x43a>
 30c:	00001097          	auipc	ra,0x1
 310:	b2c080e7          	jalr	-1236(ra) # e38 <printf>
        printf("&page 8= %p contains  %d\n",pages[8],*pages[8]);
 314:	4090                	lw	a2,0(s1)
 316:	85a6                	mv	a1,s1
 318:	00001517          	auipc	a0,0x1
 31c:	06850513          	addi	a0,a0,104 # 1380 <malloc+0x48a>
 320:	00001097          	auipc	ra,0x1
 324:	b18080e7          	jalr	-1256(ra) # e38 <printf>
        printf("doing another sbrk for senity check  %d\n");
 328:	00001517          	auipc	a0,0x1
 32c:	07850513          	addi	a0,a0,120 # 13a0 <malloc+0x4aa>
 330:	00001097          	auipc	ra,0x1
 334:	b08080e7          	jalr	-1272(ra) # e38 <printf>
        pages[17] = (int*)sbrk(PGSIZE);
 338:	6505                	lui	a0,0x1
 33a:	00001097          	auipc	ra,0x1
 33e:	80e080e7          	jalr	-2034(ra) # b48 <sbrk>
        printf("---------finished NFUA test!!!!----------\n");
 342:	00001517          	auipc	a0,0x1
 346:	08e50513          	addi	a0,a0,142 # 13d0 <malloc+0x4da>
 34a:	00001097          	auipc	ra,0x1
 34e:	aee080e7          	jalr	-1298(ra) # e38 <printf>
        exit(0);
 352:	4501                	li	a0,0
 354:	00000097          	auipc	ra,0x0
 358:	76c080e7          	jalr	1900(ra) # ac0 <exit>

000000000000035c <LAPA_when_all_equal>:

int
LAPA_when_all_equal(){
 35c:	7131                	addi	sp,sp,-192
 35e:	fd06                	sd	ra,184(sp)
 360:	f922                	sd	s0,176(sp)
 362:	f526                	sd	s1,168(sp)
 364:	f14a                	sd	s2,160(sp)
 366:	ed4e                	sd	s3,152(sp)
 368:	e952                	sd	s4,144(sp)
 36a:	0180                	addi	s0,sp,192
    int* pages[18];
    printf( "-----------------------------fork_LAPA_when_all_equal-----------------------------\n");
 36c:	00001517          	auipc	a0,0x1
 370:	09450513          	addi	a0,a0,148 # 1400 <malloc+0x50a>
 374:	00001097          	auipc	ra,0x1
 378:	ac4080e7          	jalr	-1340(ra) # e38 <printf>
    if(fork() == 0){
 37c:	00000097          	auipc	ra,0x0
 380:	73c080e7          	jalr	1852(ra) # ab8 <fork>
 384:	cd19                	beqz	a0,3a2 <LAPA_when_all_equal+0x46>
        printf("---finished LAPA_when_all_equal---\n");

        exit(0);

    }
    wait(0);
 386:	4501                	li	a0,0
 388:	00000097          	auipc	ra,0x0
 38c:	740080e7          	jalr	1856(ra) # ac8 <wait>
    return 0;
}
 390:	4501                	li	a0,0
 392:	70ea                	ld	ra,184(sp)
 394:	744a                	ld	s0,176(sp)
 396:	74aa                	ld	s1,168(sp)
 398:	790a                	ld	s2,160(sp)
 39a:	69ea                	ld	s3,152(sp)
 39c:	6a4a                	ld	s4,144(sp)
 39e:	6129                	addi	sp,sp,192
 3a0:	8082                	ret
 3a2:	84aa                	mv	s1,a0
        printf( "---------allocating and modifing 16 pages-----------\n");
 3a4:	00001517          	auipc	a0,0x1
 3a8:	0b450513          	addi	a0,a0,180 # 1458 <malloc+0x562>
 3ac:	00001097          	auipc	ra,0x1
 3b0:	a8c080e7          	jalr	-1396(ra) # e38 <printf>
        for(int i = 0; i < 16; i++){
 3b4:	f4040913          	addi	s2,s0,-192
        printf( "---------allocating and modifing 16 pages-----------\n");
 3b8:	89ca                	mv	s3,s2
        for(int i = 0; i < 16; i++){
 3ba:	4a41                	li	s4,16
            pages[i] = (int*)sbrk(PGSIZE);
 3bc:	6505                	lui	a0,0x1
 3be:	00000097          	auipc	ra,0x0
 3c2:	78a080e7          	jalr	1930(ra) # b48 <sbrk>
 3c6:	00a9b023          	sd	a0,0(s3)
            *pages[i] = i;
 3ca:	c104                	sw	s1,0(a0)
        for(int i = 0; i < 16; i++){
 3cc:	2485                	addiw	s1,s1,1
 3ce:	09a1                	addi	s3,s3,8
 3d0:	ff4496e3          	bne	s1,s4,3bc <LAPA_when_all_equal+0x60>
        sleep(20); // we want to zero all aging counters 
 3d4:	4551                	li	a0,20
 3d6:	00000097          	auipc	ra,0x0
 3da:	77a080e7          	jalr	1914(ra) # b50 <sleep>
        printf( "----------accessing all pages, starts with page[8]-------------\n");
 3de:	00001517          	auipc	a0,0x1
 3e2:	0b250513          	addi	a0,a0,178 # 1490 <malloc+0x59a>
 3e6:	00001097          	auipc	ra,0x1
 3ea:	a52080e7          	jalr	-1454(ra) # e38 <printf>
        *pages[8] = 8;
 3ee:	f8043483          	ld	s1,-128(s0)
 3f2:	47a1                	li	a5,8
 3f4:	c09c                	sw	a5,0(s1)
        sleep(10);
 3f6:	4529                	li	a0,10
 3f8:	00000097          	auipc	ra,0x0
 3fc:	758080e7          	jalr	1880(ra) # b50 <sleep>
 400:	4705                	li	a4,1
 402:	4781                	li	a5,0
            if (i!=8)
 404:	45a1                	li	a1,8
        for(int i = 0; i < 16; i++){
 406:	453d                	li	a0,15
 408:	a021                	j	410 <LAPA_when_all_equal+0xb4>
 40a:	2785                	addiw	a5,a5,1
 40c:	2705                	addiw	a4,a4,1
 40e:	0921                	addi	s2,s2,8
 410:	0007869b          	sext.w	a3,a5
            if (i!=8)
 414:	feb68be3          	beq	a3,a1,40a <LAPA_when_all_equal+0xae>
                *pages[i] = i;
 418:	00093603          	ld	a2,0(s2)
 41c:	c214                	sw	a3,0(a2)
        for(int i = 0; i < 16; i++){
 41e:	0007069b          	sext.w	a3,a4
 422:	fed554e3          	bge	a0,a3,40a <LAPA_when_all_equal+0xae>
        sleep(5);
 426:	4515                	li	a0,5
 428:	00000097          	auipc	ra,0x0
 42c:	728080e7          	jalr	1832(ra) # b50 <sleep>
        printf( "-------create new page, page 8 need to swapout-----------\n");
 430:	00001517          	auipc	a0,0x1
 434:	0a850513          	addi	a0,a0,168 # 14d8 <malloc+0x5e2>
 438:	00001097          	auipc	ra,0x1
 43c:	a00080e7          	jalr	-1536(ra) # e38 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 440:	6505                	lui	a0,0x1
 442:	00000097          	auipc	ra,0x0
 446:	706080e7          	jalr	1798(ra) # b48 <sbrk>
        printf( "--------access page 8 shuld cause pagefault---------\n");
 44a:	00001517          	auipc	a0,0x1
 44e:	0ce50513          	addi	a0,a0,206 # 1518 <malloc+0x622>
 452:	00001097          	auipc	ra,0x1
 456:	9e6080e7          	jalr	-1562(ra) # e38 <printf>
        printf("page 8 value =  %d\n",*pages[8]);
 45a:	408c                	lw	a1,0(s1)
 45c:	00001517          	auipc	a0,0x1
 460:	0f450513          	addi	a0,a0,244 # 1550 <malloc+0x65a>
 464:	00001097          	auipc	ra,0x1
 468:	9d4080e7          	jalr	-1580(ra) # e38 <printf>
        printf("---finished LAPA_when_all_equal---\n");
 46c:	00001517          	auipc	a0,0x1
 470:	0fc50513          	addi	a0,a0,252 # 1568 <malloc+0x672>
 474:	00001097          	auipc	ra,0x1
 478:	9c4080e7          	jalr	-1596(ra) # e38 <printf>
        exit(0);
 47c:	4501                	li	a0,0
 47e:	00000097          	auipc	ra,0x0
 482:	642080e7          	jalr	1602(ra) # ac0 <exit>

0000000000000486 <LAPA_paging>:

int
LAPA_paging(){
 486:	7131                	addi	sp,sp,-192
 488:	fd06                	sd	ra,184(sp)
 48a:	f922                	sd	s0,176(sp)
 48c:	f526                	sd	s1,168(sp)
 48e:	f14a                	sd	s2,160(sp)
 490:	ed4e                	sd	s3,152(sp)
 492:	e952                	sd	s4,144(sp)
 494:	0180                	addi	s0,sp,192
    int* pages[18];
    printf( "--------------------LAPA_paging--------------------\n");
 496:	00001517          	auipc	a0,0x1
 49a:	0fa50513          	addi	a0,a0,250 # 1590 <malloc+0x69a>
 49e:	00001097          	auipc	ra,0x1
 4a2:	99a080e7          	jalr	-1638(ra) # e38 <printf>
    printf( "-------------allocating and modifing 16 pages-----------------\n");
 4a6:	00001517          	auipc	a0,0x1
 4aa:	12250513          	addi	a0,a0,290 # 15c8 <malloc+0x6d2>
 4ae:	00001097          	auipc	ra,0x1
 4b2:	98a080e7          	jalr	-1654(ra) # e38 <printf>
    if(fork() == 0){
 4b6:	00000097          	auipc	ra,0x0
 4ba:	602080e7          	jalr	1538(ra) # ab8 <fork>
 4be:	cd19                	beqz	a0,4dc <LAPA_paging+0x56>
        printf("pages[8] contains  %d\n",*pages[8]);
        printf("-----finish LAPA_paging-----\n");
        exit(0);

    }
    wait(0);
 4c0:	4501                	li	a0,0
 4c2:	00000097          	auipc	ra,0x0
 4c6:	606080e7          	jalr	1542(ra) # ac8 <wait>
    return 0;
}
 4ca:	4501                	li	a0,0
 4cc:	70ea                	ld	ra,184(sp)
 4ce:	744a                	ld	s0,176(sp)
 4d0:	74aa                	ld	s1,168(sp)
 4d2:	790a                	ld	s2,160(sp)
 4d4:	69ea                	ld	s3,152(sp)
 4d6:	6a4a                	ld	s4,144(sp)
 4d8:	6129                	addi	sp,sp,192
 4da:	8082                	ret
 4dc:	84aa                	mv	s1,a0
 4de:	f4040913          	addi	s2,s0,-192
    if(fork() == 0){
 4e2:	89ca                	mv	s3,s2
        for(int i = 0; i < 16; i++){
 4e4:	4a41                	li	s4,16
            pages[i] = (int*)sbrk(PGSIZE);
 4e6:	6505                	lui	a0,0x1
 4e8:	00000097          	auipc	ra,0x0
 4ec:	660080e7          	jalr	1632(ra) # b48 <sbrk>
 4f0:	00a9b023          	sd	a0,0(s3)
            *pages[i] = i;
 4f4:	c104                	sw	s1,0(a0)
        for(int i = 0; i < 16; i++){
 4f6:	2485                	addiw	s1,s1,1
 4f8:	09a1                	addi	s3,s3,8
 4fa:	ff4496e3          	bne	s1,s4,4e6 <LAPA_paging+0x60>
        sleep(20); // we want to zero all aging counters
 4fe:	4551                	li	a0,20
 500:	00000097          	auipc	ra,0x0
 504:	650080e7          	jalr	1616(ra) # b50 <sleep>
        printf( "--------modifing each page 2 times except pages[8]-----------------\n");
 508:	00001517          	auipc	a0,0x1
 50c:	10050513          	addi	a0,a0,256 # 1608 <malloc+0x712>
 510:	00001097          	auipc	ra,0x1
 514:	928080e7          	jalr	-1752(ra) # e38 <printf>
 518:	86ca                	mv	a3,s2
 51a:	4705                	li	a4,1
 51c:	4781                	li	a5,0
                if (i!=8)
 51e:	4521                	li	a0,8
            for(int i = 0; i < 16; i++){
 520:	483d                	li	a6,15
 522:	a021                	j	52a <LAPA_paging+0xa4>
 524:	2785                	addiw	a5,a5,1
 526:	2705                	addiw	a4,a4,1
 528:	06a1                	addi	a3,a3,8
 52a:	0007861b          	sext.w	a2,a5
                if (i!=8)
 52e:	fea60be3          	beq	a2,a0,524 <LAPA_paging+0x9e>
                    *pages[i] = i;
 532:	628c                	ld	a1,0(a3)
 534:	c190                	sw	a2,0(a1)
            for(int i = 0; i < 16; i++){
 536:	0007061b          	sext.w	a2,a4
 53a:	fec855e3          	bge	a6,a2,524 <LAPA_paging+0x9e>
            sleep(1);// to update the aging counter once
 53e:	4505                	li	a0,1
 540:	00000097          	auipc	ra,0x0
 544:	610080e7          	jalr	1552(ra) # b50 <sleep>
 548:	4705                	li	a4,1
 54a:	4781                	li	a5,0
                if (i!=8)
 54c:	45a1                	li	a1,8
            for(int i = 0; i < 16; i++){
 54e:	453d                	li	a0,15
 550:	a021                	j	558 <LAPA_paging+0xd2>
 552:	2785                	addiw	a5,a5,1
 554:	2705                	addiw	a4,a4,1
 556:	0921                	addi	s2,s2,8
 558:	0007869b          	sext.w	a3,a5
                if (i!=8)
 55c:	feb68be3          	beq	a3,a1,552 <LAPA_paging+0xcc>
                    *pages[i] = i;
 560:	00093603          	ld	a2,0(s2)
 564:	c214                	sw	a3,0(a2)
            for(int i = 0; i < 16; i++){
 566:	0007069b          	sext.w	a3,a4
 56a:	fed554e3          	bge	a0,a3,552 <LAPA_paging+0xcc>
            sleep(1);// to update the aging counter once
 56e:	4505                	li	a0,1
 570:	00000097          	auipc	ra,0x0
 574:	5e0080e7          	jalr	1504(ra) # b50 <sleep>
        printf( "--------modifing page 8 once----------\n");
 578:	00001517          	auipc	a0,0x1
 57c:	0d850513          	addi	a0,a0,216 # 1650 <malloc+0x75a>
 580:	00001097          	auipc	ra,0x1
 584:	8b8080e7          	jalr	-1864(ra) # e38 <printf>
        *pages[8] = 8;
 588:	f8043483          	ld	s1,-128(s0)
 58c:	47a1                	li	a5,8
 58e:	c09c                	sw	a5,0(s1)
        printf( "-----create new page-> page 8 need to swapout------\n");
 590:	00001517          	auipc	a0,0x1
 594:	0e850513          	addi	a0,a0,232 # 1678 <malloc+0x782>
 598:	00001097          	auipc	ra,0x1
 59c:	8a0080e7          	jalr	-1888(ra) # e38 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 5a0:	6505                	lui	a0,0x1
 5a2:	00000097          	auipc	ra,0x0
 5a6:	5a6080e7          	jalr	1446(ra) # b48 <sbrk>
        printf( "-------access page 8 need to cause pagefault-------\n");
 5aa:	00001517          	auipc	a0,0x1
 5ae:	10650513          	addi	a0,a0,262 # 16b0 <malloc+0x7ba>
 5b2:	00001097          	auipc	ra,0x1
 5b6:	886080e7          	jalr	-1914(ra) # e38 <printf>
        printf("pages[8] contains  %d\n",*pages[8]);
 5ba:	408c                	lw	a1,0(s1)
 5bc:	00001517          	auipc	a0,0x1
 5c0:	12c50513          	addi	a0,a0,300 # 16e8 <malloc+0x7f2>
 5c4:	00001097          	auipc	ra,0x1
 5c8:	874080e7          	jalr	-1932(ra) # e38 <printf>
        printf("-----finish LAPA_paging-----\n");
 5cc:	00001517          	auipc	a0,0x1
 5d0:	13450513          	addi	a0,a0,308 # 1700 <malloc+0x80a>
 5d4:	00001097          	auipc	ra,0x1
 5d8:	864080e7          	jalr	-1948(ra) # e38 <printf>
        exit(0);
 5dc:	4501                	li	a0,0
 5de:	00000097          	auipc	ra,0x0
 5e2:	4e2080e7          	jalr	1250(ra) # ac0 <exit>

00000000000005e6 <LAPA_test_fork_copy>:

int
LAPA_test_fork_copy(){
 5e6:	7155                	addi	sp,sp,-208
 5e8:	e586                	sd	ra,200(sp)
 5ea:	e1a2                	sd	s0,192(sp)
 5ec:	fd26                	sd	s1,184(sp)
 5ee:	f94a                	sd	s2,176(sp)
 5f0:	f54e                	sd	s3,168(sp)
 5f2:	f152                	sd	s4,160(sp)
 5f4:	ed56                	sd	s5,152(sp)
 5f6:	0980                	addi	s0,sp,208
    int* pages[18];
    printf( "--------------------LAPA 3 : FORK test:----------------------\n");
 5f8:	00001517          	auipc	a0,0x1
 5fc:	12850513          	addi	a0,a0,296 # 1720 <malloc+0x82a>
 600:	00001097          	auipc	ra,0x1
 604:	838080e7          	jalr	-1992(ra) # e38 <printf>
    printf( "-------------allocating 16 pages for father-----------------\n");
 608:	00001517          	auipc	a0,0x1
 60c:	15850513          	addi	a0,a0,344 # 1760 <malloc+0x86a>
 610:	00001097          	auipc	ra,0x1
 614:	828080e7          	jalr	-2008(ra) # e38 <printf>
 618:	f3040913          	addi	s2,s0,-208
    for(int i = 0; i < 16; i++){
 61c:	4481                	li	s1,0
 61e:	49c1                	li	s3,16
            pages[i] = (int*)sbrk(PGSIZE);
 620:	6505                	lui	a0,0x1
 622:	00000097          	auipc	ra,0x0
 626:	526080e7          	jalr	1318(ra) # b48 <sbrk>
 62a:	00a93023          	sd	a0,0(s2)
            *pages[i] = i;
 62e:	c104                	sw	s1,0(a0)
    for(int i = 0; i < 16; i++){
 630:	2485                	addiw	s1,s1,1
 632:	0921                	addi	s2,s2,8
 634:	ff3496e3          	bne	s1,s3,620 <LAPA_test_fork_copy+0x3a>
        }
    sleep(20);
 638:	4551                	li	a0,20
 63a:	00000097          	auipc	ra,0x0
 63e:	516080e7          	jalr	1302(ra) # b50 <sleep>
    printf( "------------- accessing all pages 3 times except page 8-----------------\n");
 642:	00001517          	auipc	a0,0x1
 646:	15e50513          	addi	a0,a0,350 # 17a0 <malloc+0x8aa>
 64a:	00000097          	auipc	ra,0x0
 64e:	7ee080e7          	jalr	2030(ra) # e38 <printf>
 652:	498d                	li	s3,3
    for(int i = 0; i < 16; i++){
 654:	4a05                	li	s4,1
 656:	4a81                	li	s5,0
        for(int j=0;j<3;j++){
            for(int i = 0; i < 16; i++){
                if (i!=8)
 658:	44a1                	li	s1,8
            for(int i = 0; i < 16; i++){
 65a:	493d                	li	s2,15
 65c:	a035                	j	688 <LAPA_test_fork_copy+0xa2>
 65e:	2785                	addiw	a5,a5,1
 660:	2685                	addiw	a3,a3,1
 662:	0621                	addi	a2,a2,8
 664:	0007871b          	sext.w	a4,a5
                if (i!=8)
 668:	fe970be3          	beq	a4,s1,65e <LAPA_test_fork_copy+0x78>
                    *pages[i] = i;
 66c:	620c                	ld	a1,0(a2)
 66e:	c198                	sw	a4,0(a1)
            for(int i = 0; i < 16; i++){
 670:	0006871b          	sext.w	a4,a3
 674:	fee955e3          	bge	s2,a4,65e <LAPA_test_fork_copy+0x78>
            }
            sleep(1);
 678:	8552                	mv	a0,s4
 67a:	00000097          	auipc	ra,0x0
 67e:	4d6080e7          	jalr	1238(ra) # b50 <sleep>
        for(int j=0;j<3;j++){
 682:	39fd                	addiw	s3,s3,-1
 684:	00098763          	beqz	s3,692 <LAPA_test_fork_copy+0xac>
    for(int i = 0; i < 16; i++){
 688:	f3040613          	addi	a2,s0,-208
 68c:	86d2                	mv	a3,s4
 68e:	87d6                	mv	a5,s5
 690:	bfd1                	j	664 <LAPA_test_fork_copy+0x7e>
        }

        printf( "-------------now access pages 8 only twice-----------------\n");
 692:	00001517          	auipc	a0,0x1
 696:	15e50513          	addi	a0,a0,350 # 17f0 <malloc+0x8fa>
 69a:	00000097          	auipc	ra,0x0
 69e:	79e080e7          	jalr	1950(ra) # e38 <printf>
        *pages[8] = 8;
 6a2:	f7043483          	ld	s1,-144(s0)
 6a6:	47a1                	li	a5,8
 6a8:	c09c                	sw	a5,0(s1)
        *pages[8] = 8;
        sleep(1);
 6aa:	4505                	li	a0,1
 6ac:	00000097          	auipc	ra,0x0
 6b0:	4a4080e7          	jalr	1188(ra) # b50 <sleep>
    if(fork() == 0){
 6b4:	00000097          	auipc	ra,0x0
 6b8:	404080e7          	jalr	1028(ra) # ab8 <fork>
 6bc:	c535                	beqz	a0,728 <LAPA_test_fork_copy+0x142>
        printf( "-------------Son: now acess to page 8 should cause pagefault-----------------\n");
        printf("page 8 contains  %d\n",*pages[8]);
        exit(0);
    }

    wait(0);
 6be:	4501                	li	a0,0
 6c0:	00000097          	auipc	ra,0x0
 6c4:	408080e7          	jalr	1032(ra) # ac8 <wait>
    printf( "-------------Father: create a new page, page 8 should be paged out-----------------\n");
 6c8:	00001517          	auipc	a0,0x1
 6cc:	22850513          	addi	a0,a0,552 # 18f0 <malloc+0x9fa>
 6d0:	00000097          	auipc	ra,0x0
 6d4:	768080e7          	jalr	1896(ra) # e38 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 6d8:	6505                	lui	a0,0x1
 6da:	00000097          	auipc	ra,0x0
 6de:	46e080e7          	jalr	1134(ra) # b48 <sbrk>
        
        printf( "-------------Father: now acess to page 8 should cause pagefault-----------------\n");
 6e2:	00001517          	auipc	a0,0x1
 6e6:	26650513          	addi	a0,a0,614 # 1948 <malloc+0xa52>
 6ea:	00000097          	auipc	ra,0x0
 6ee:	74e080e7          	jalr	1870(ra) # e38 <printf>
        printf("page 8 contains : %d",*pages[8]);
 6f2:	408c                	lw	a1,0(s1)
 6f4:	00001517          	auipc	a0,0x1
 6f8:	2ac50513          	addi	a0,a0,684 # 19a0 <malloc+0xaaa>
 6fc:	00000097          	auipc	ra,0x0
 700:	73c080e7          	jalr	1852(ra) # e38 <printf>
        
    printf("---------finished LAPA_test_fork_copy test!!!!----------\n");
 704:	00001517          	auipc	a0,0x1
 708:	2b450513          	addi	a0,a0,692 # 19b8 <malloc+0xac2>
 70c:	00000097          	auipc	ra,0x0
 710:	72c080e7          	jalr	1836(ra) # e38 <printf>

    return 0;
}
 714:	4501                	li	a0,0
 716:	60ae                	ld	ra,200(sp)
 718:	640e                	ld	s0,192(sp)
 71a:	74ea                	ld	s1,184(sp)
 71c:	794a                	ld	s2,176(sp)
 71e:	79aa                	ld	s3,168(sp)
 720:	7a0a                	ld	s4,160(sp)
 722:	6aea                	ld	s5,152(sp)
 724:	6169                	addi	sp,sp,208
 726:	8082                	ret
        printf( "-------------Son: create a new page, page 8 should be paged out-----------------\n");
 728:	00001517          	auipc	a0,0x1
 72c:	10850513          	addi	a0,a0,264 # 1830 <malloc+0x93a>
 730:	00000097          	auipc	ra,0x0
 734:	708080e7          	jalr	1800(ra) # e38 <printf>
        pages[16] = (int*)sbrk(PGSIZE);
 738:	6505                	lui	a0,0x1
 73a:	00000097          	auipc	ra,0x0
 73e:	40e080e7          	jalr	1038(ra) # b48 <sbrk>
        printf( "-------------Son: now acess to page 8 should cause pagefault-----------------\n");
 742:	00001517          	auipc	a0,0x1
 746:	14650513          	addi	a0,a0,326 # 1888 <malloc+0x992>
 74a:	00000097          	auipc	ra,0x0
 74e:	6ee080e7          	jalr	1774(ra) # e38 <printf>
        printf("page 8 contains  %d\n",*pages[8]);
 752:	408c                	lw	a1,0(s1)
 754:	00001517          	auipc	a0,0x1
 758:	18450513          	addi	a0,a0,388 # 18d8 <malloc+0x9e2>
 75c:	00000097          	auipc	ra,0x0
 760:	6dc080e7          	jalr	1756(ra) # e38 <printf>
        exit(0);
 764:	4501                	li	a0,0
 766:	00000097          	auipc	ra,0x0
 76a:	35a080e7          	jalr	858(ra) # ac0 <exit>

000000000000076e <fork_test>:

int 
fork_test(){
 76e:	1101                	addi	sp,sp,-32
 770:	ec06                	sd	ra,24(sp)
 772:	e822                	sd	s0,16(sp)
 774:	1000                	addi	s0,sp,32
    return NFUA_test();
    #endif

    #ifdef LAPA
    char wait[3];   // used to ask for input and delay between tests
    LAPA_paging();
 776:	00000097          	auipc	ra,0x0
 77a:	d10080e7          	jalr	-752(ra) # 486 <LAPA_paging>
    gets(wait,3);
 77e:	458d                	li	a1,3
 780:	fe840513          	addi	a0,s0,-24
 784:	00000097          	auipc	ra,0x0
 788:	186080e7          	jalr	390(ra) # 90a <gets>
    LAPA_when_all_equal();
 78c:	00000097          	auipc	ra,0x0
 790:	bd0080e7          	jalr	-1072(ra) # 35c <LAPA_when_all_equal>
    gets(wait,3);
 794:	458d                	li	a1,3
 796:	fe840513          	addi	a0,s0,-24
 79a:	00000097          	auipc	ra,0x0
 79e:	170080e7          	jalr	368(ra) # 90a <gets>
    return LAPA_test_fork_copy();
 7a2:	00000097          	auipc	ra,0x0
 7a6:	e44080e7          	jalr	-444(ra) # 5e6 <LAPA_test_fork_copy>
    #endif
    return -1;
    
}
 7aa:	60e2                	ld	ra,24(sp)
 7ac:	6442                	ld	s0,16(sp)
 7ae:	6105                	addi	sp,sp,32
 7b0:	8082                	ret

00000000000007b2 <malloc_and_free>:

int malloc_and_free(){
 7b2:	1101                	addi	sp,sp,-32
 7b4:	ec06                	sd	ra,24(sp)
 7b6:	e822                	sd	s0,16(sp)
 7b8:	e426                	sd	s1,8(sp)
 7ba:	e04a                	sd	s2,0(sp)
 7bc:	1000                	addi	s0,sp,32
    printf("-----------------------------malloc--------\n");
 7be:	00001517          	auipc	a0,0x1
 7c2:	23a50513          	addi	a0,a0,570 # 19f8 <malloc+0xb02>
 7c6:	00000097          	auipc	ra,0x0
 7ca:	672080e7          	jalr	1650(ra) # e38 <printf>

    void* a = sbrk(PGSIZE);
 7ce:	6505                	lui	a0,0x1
 7d0:	00000097          	auipc	ra,0x0
 7d4:	378080e7          	jalr	888(ra) # b48 <sbrk>
 7d8:	892a                	mv	s2,a0
    void* b = malloc(PGSIZE);
 7da:	6505                	lui	a0,0x1
 7dc:	00000097          	auipc	ra,0x0
 7e0:	71a080e7          	jalr	1818(ra) # ef6 <malloc>
 7e4:	84aa                	mv	s1,a0

    printf("-----------------------------free--------\n");
 7e6:	00001517          	auipc	a0,0x1
 7ea:	24250513          	addi	a0,a0,578 # 1a28 <malloc+0xb32>
 7ee:	00000097          	auipc	ra,0x0
 7f2:	64a080e7          	jalr	1610(ra) # e38 <printf>
    free(a);
 7f6:	854a                	mv	a0,s2
 7f8:	00000097          	auipc	ra,0x0
 7fc:	676080e7          	jalr	1654(ra) # e6e <free>
    free(b);
 800:	8526                	mv	a0,s1
 802:	00000097          	auipc	ra,0x0
 806:	66c080e7          	jalr	1644(ra) # e6e <free>
    printf("-----------------------------PASS--------\n");
 80a:	00001517          	auipc	a0,0x1
 80e:	24e50513          	addi	a0,a0,590 # 1a58 <malloc+0xb62>
 812:	00000097          	auipc	ra,0x0
 816:	626080e7          	jalr	1574(ra) # e38 <printf>

    return 0;
}
 81a:	4501                	li	a0,0
 81c:	60e2                	ld	ra,24(sp)
 81e:	6442                	ld	s0,16(sp)
 820:	64a2                	ld	s1,8(sp)
 822:	6902                	ld	s2,0(sp)
 824:	6105                	addi	sp,sp,32
 826:	8082                	ret

0000000000000828 <main>:

int
main(int argc, char *argv[])
{
 828:	1141                	addi	sp,sp,-16
 82a:	e406                	sd	ra,8(sp)
 82c:	e022                	sd	s0,0(sp)
 82e:	0800                	addi	s0,sp,16
    // printf("-----------------------------sbark_and_fork-----------------------------\n");
    // sbark_and_fork();
    printf("-----------------------------fork_test-----------------------------\n");
 830:	00001517          	auipc	a0,0x1
 834:	25850513          	addi	a0,a0,600 # 1a88 <malloc+0xb92>
 838:	00000097          	auipc	ra,0x0
 83c:	600080e7          	jalr	1536(ra) # e38 <printf>
    fork_test();
 840:	00000097          	auipc	ra,0x0
 844:	f2e080e7          	jalr	-210(ra) # 76e <fork_test>
    // printf("-----------------------------malloc_and_free-----------------------------\n");
    // malloc_and_free();
    exit(0);
 848:	4501                	li	a0,0
 84a:	00000097          	auipc	ra,0x0
 84e:	276080e7          	jalr	630(ra) # ac0 <exit>

0000000000000852 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 852:	1141                	addi	sp,sp,-16
 854:	e422                	sd	s0,8(sp)
 856:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 858:	87aa                	mv	a5,a0
 85a:	0585                	addi	a1,a1,1
 85c:	0785                	addi	a5,a5,1
 85e:	fff5c703          	lbu	a4,-1(a1)
 862:	fee78fa3          	sb	a4,-1(a5)
 866:	fb75                	bnez	a4,85a <strcpy+0x8>
    ;
  return os;
}
 868:	6422                	ld	s0,8(sp)
 86a:	0141                	addi	sp,sp,16
 86c:	8082                	ret

000000000000086e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 86e:	1141                	addi	sp,sp,-16
 870:	e422                	sd	s0,8(sp)
 872:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 874:	00054783          	lbu	a5,0(a0)
 878:	cb91                	beqz	a5,88c <strcmp+0x1e>
 87a:	0005c703          	lbu	a4,0(a1)
 87e:	00f71763          	bne	a4,a5,88c <strcmp+0x1e>
    p++, q++;
 882:	0505                	addi	a0,a0,1
 884:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 886:	00054783          	lbu	a5,0(a0)
 88a:	fbe5                	bnez	a5,87a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 88c:	0005c503          	lbu	a0,0(a1)
}
 890:	40a7853b          	subw	a0,a5,a0
 894:	6422                	ld	s0,8(sp)
 896:	0141                	addi	sp,sp,16
 898:	8082                	ret

000000000000089a <strlen>:

uint
strlen(const char *s)
{
 89a:	1141                	addi	sp,sp,-16
 89c:	e422                	sd	s0,8(sp)
 89e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 8a0:	00054783          	lbu	a5,0(a0)
 8a4:	cf91                	beqz	a5,8c0 <strlen+0x26>
 8a6:	0505                	addi	a0,a0,1
 8a8:	87aa                	mv	a5,a0
 8aa:	4685                	li	a3,1
 8ac:	9e89                	subw	a3,a3,a0
 8ae:	00f6853b          	addw	a0,a3,a5
 8b2:	0785                	addi	a5,a5,1
 8b4:	fff7c703          	lbu	a4,-1(a5)
 8b8:	fb7d                	bnez	a4,8ae <strlen+0x14>
    ;
  return n;
}
 8ba:	6422                	ld	s0,8(sp)
 8bc:	0141                	addi	sp,sp,16
 8be:	8082                	ret
  for(n = 0; s[n]; n++)
 8c0:	4501                	li	a0,0
 8c2:	bfe5                	j	8ba <strlen+0x20>

00000000000008c4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 8c4:	1141                	addi	sp,sp,-16
 8c6:	e422                	sd	s0,8(sp)
 8c8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 8ca:	ca19                	beqz	a2,8e0 <memset+0x1c>
 8cc:	87aa                	mv	a5,a0
 8ce:	1602                	slli	a2,a2,0x20
 8d0:	9201                	srli	a2,a2,0x20
 8d2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 8d6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 8da:	0785                	addi	a5,a5,1
 8dc:	fee79de3          	bne	a5,a4,8d6 <memset+0x12>
  }
  return dst;
}
 8e0:	6422                	ld	s0,8(sp)
 8e2:	0141                	addi	sp,sp,16
 8e4:	8082                	ret

00000000000008e6 <strchr>:

char*
strchr(const char *s, char c)
{
 8e6:	1141                	addi	sp,sp,-16
 8e8:	e422                	sd	s0,8(sp)
 8ea:	0800                	addi	s0,sp,16
  for(; *s; s++)
 8ec:	00054783          	lbu	a5,0(a0)
 8f0:	cb99                	beqz	a5,906 <strchr+0x20>
    if(*s == c)
 8f2:	00f58763          	beq	a1,a5,900 <strchr+0x1a>
  for(; *s; s++)
 8f6:	0505                	addi	a0,a0,1
 8f8:	00054783          	lbu	a5,0(a0)
 8fc:	fbfd                	bnez	a5,8f2 <strchr+0xc>
      return (char*)s;
  return 0;
 8fe:	4501                	li	a0,0
}
 900:	6422                	ld	s0,8(sp)
 902:	0141                	addi	sp,sp,16
 904:	8082                	ret
  return 0;
 906:	4501                	li	a0,0
 908:	bfe5                	j	900 <strchr+0x1a>

000000000000090a <gets>:

char*
gets(char *buf, int max)
{
 90a:	711d                	addi	sp,sp,-96
 90c:	ec86                	sd	ra,88(sp)
 90e:	e8a2                	sd	s0,80(sp)
 910:	e4a6                	sd	s1,72(sp)
 912:	e0ca                	sd	s2,64(sp)
 914:	fc4e                	sd	s3,56(sp)
 916:	f852                	sd	s4,48(sp)
 918:	f456                	sd	s5,40(sp)
 91a:	f05a                	sd	s6,32(sp)
 91c:	ec5e                	sd	s7,24(sp)
 91e:	1080                	addi	s0,sp,96
 920:	8baa                	mv	s7,a0
 922:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 924:	892a                	mv	s2,a0
 926:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 928:	4aa9                	li	s5,10
 92a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 92c:	89a6                	mv	s3,s1
 92e:	2485                	addiw	s1,s1,1
 930:	0344d863          	bge	s1,s4,960 <gets+0x56>
    cc = read(0, &c, 1);
 934:	4605                	li	a2,1
 936:	faf40593          	addi	a1,s0,-81
 93a:	4501                	li	a0,0
 93c:	00000097          	auipc	ra,0x0
 940:	19c080e7          	jalr	412(ra) # ad8 <read>
    if(cc < 1)
 944:	00a05e63          	blez	a0,960 <gets+0x56>
    buf[i++] = c;
 948:	faf44783          	lbu	a5,-81(s0)
 94c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 950:	01578763          	beq	a5,s5,95e <gets+0x54>
 954:	0905                	addi	s2,s2,1
 956:	fd679be3          	bne	a5,s6,92c <gets+0x22>
  for(i=0; i+1 < max; ){
 95a:	89a6                	mv	s3,s1
 95c:	a011                	j	960 <gets+0x56>
 95e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 960:	99de                	add	s3,s3,s7
 962:	00098023          	sb	zero,0(s3)
  return buf;
}
 966:	855e                	mv	a0,s7
 968:	60e6                	ld	ra,88(sp)
 96a:	6446                	ld	s0,80(sp)
 96c:	64a6                	ld	s1,72(sp)
 96e:	6906                	ld	s2,64(sp)
 970:	79e2                	ld	s3,56(sp)
 972:	7a42                	ld	s4,48(sp)
 974:	7aa2                	ld	s5,40(sp)
 976:	7b02                	ld	s6,32(sp)
 978:	6be2                	ld	s7,24(sp)
 97a:	6125                	addi	sp,sp,96
 97c:	8082                	ret

000000000000097e <stat>:

int
stat(const char *n, struct stat *st)
{
 97e:	1101                	addi	sp,sp,-32
 980:	ec06                	sd	ra,24(sp)
 982:	e822                	sd	s0,16(sp)
 984:	e426                	sd	s1,8(sp)
 986:	e04a                	sd	s2,0(sp)
 988:	1000                	addi	s0,sp,32
 98a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 98c:	4581                	li	a1,0
 98e:	00000097          	auipc	ra,0x0
 992:	172080e7          	jalr	370(ra) # b00 <open>
  if(fd < 0)
 996:	02054563          	bltz	a0,9c0 <stat+0x42>
 99a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 99c:	85ca                	mv	a1,s2
 99e:	00000097          	auipc	ra,0x0
 9a2:	17a080e7          	jalr	378(ra) # b18 <fstat>
 9a6:	892a                	mv	s2,a0
  close(fd);
 9a8:	8526                	mv	a0,s1
 9aa:	00000097          	auipc	ra,0x0
 9ae:	13e080e7          	jalr	318(ra) # ae8 <close>
  return r;
}
 9b2:	854a                	mv	a0,s2
 9b4:	60e2                	ld	ra,24(sp)
 9b6:	6442                	ld	s0,16(sp)
 9b8:	64a2                	ld	s1,8(sp)
 9ba:	6902                	ld	s2,0(sp)
 9bc:	6105                	addi	sp,sp,32
 9be:	8082                	ret
    return -1;
 9c0:	597d                	li	s2,-1
 9c2:	bfc5                	j	9b2 <stat+0x34>

00000000000009c4 <atoi>:

int
atoi(const char *s)
{
 9c4:	1141                	addi	sp,sp,-16
 9c6:	e422                	sd	s0,8(sp)
 9c8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 9ca:	00054603          	lbu	a2,0(a0)
 9ce:	fd06079b          	addiw	a5,a2,-48
 9d2:	0ff7f793          	andi	a5,a5,255
 9d6:	4725                	li	a4,9
 9d8:	02f76963          	bltu	a4,a5,a0a <atoi+0x46>
 9dc:	86aa                	mv	a3,a0
  n = 0;
 9de:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 9e0:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 9e2:	0685                	addi	a3,a3,1
 9e4:	0025179b          	slliw	a5,a0,0x2
 9e8:	9fa9                	addw	a5,a5,a0
 9ea:	0017979b          	slliw	a5,a5,0x1
 9ee:	9fb1                	addw	a5,a5,a2
 9f0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 9f4:	0006c603          	lbu	a2,0(a3)
 9f8:	fd06071b          	addiw	a4,a2,-48
 9fc:	0ff77713          	andi	a4,a4,255
 a00:	fee5f1e3          	bgeu	a1,a4,9e2 <atoi+0x1e>
  return n;
}
 a04:	6422                	ld	s0,8(sp)
 a06:	0141                	addi	sp,sp,16
 a08:	8082                	ret
  n = 0;
 a0a:	4501                	li	a0,0
 a0c:	bfe5                	j	a04 <atoi+0x40>

0000000000000a0e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 a0e:	1141                	addi	sp,sp,-16
 a10:	e422                	sd	s0,8(sp)
 a12:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 a14:	02b57463          	bgeu	a0,a1,a3c <memmove+0x2e>
    while(n-- > 0)
 a18:	00c05f63          	blez	a2,a36 <memmove+0x28>
 a1c:	1602                	slli	a2,a2,0x20
 a1e:	9201                	srli	a2,a2,0x20
 a20:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 a24:	872a                	mv	a4,a0
      *dst++ = *src++;
 a26:	0585                	addi	a1,a1,1
 a28:	0705                	addi	a4,a4,1
 a2a:	fff5c683          	lbu	a3,-1(a1)
 a2e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 a32:	fee79ae3          	bne	a5,a4,a26 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 a36:	6422                	ld	s0,8(sp)
 a38:	0141                	addi	sp,sp,16
 a3a:	8082                	ret
    dst += n;
 a3c:	00c50733          	add	a4,a0,a2
    src += n;
 a40:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 a42:	fec05ae3          	blez	a2,a36 <memmove+0x28>
 a46:	fff6079b          	addiw	a5,a2,-1
 a4a:	1782                	slli	a5,a5,0x20
 a4c:	9381                	srli	a5,a5,0x20
 a4e:	fff7c793          	not	a5,a5
 a52:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 a54:	15fd                	addi	a1,a1,-1
 a56:	177d                	addi	a4,a4,-1
 a58:	0005c683          	lbu	a3,0(a1)
 a5c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 a60:	fee79ae3          	bne	a5,a4,a54 <memmove+0x46>
 a64:	bfc9                	j	a36 <memmove+0x28>

0000000000000a66 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 a66:	1141                	addi	sp,sp,-16
 a68:	e422                	sd	s0,8(sp)
 a6a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 a6c:	ca05                	beqz	a2,a9c <memcmp+0x36>
 a6e:	fff6069b          	addiw	a3,a2,-1
 a72:	1682                	slli	a3,a3,0x20
 a74:	9281                	srli	a3,a3,0x20
 a76:	0685                	addi	a3,a3,1
 a78:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 a7a:	00054783          	lbu	a5,0(a0)
 a7e:	0005c703          	lbu	a4,0(a1)
 a82:	00e79863          	bne	a5,a4,a92 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 a86:	0505                	addi	a0,a0,1
    p2++;
 a88:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 a8a:	fed518e3          	bne	a0,a3,a7a <memcmp+0x14>
  }
  return 0;
 a8e:	4501                	li	a0,0
 a90:	a019                	j	a96 <memcmp+0x30>
      return *p1 - *p2;
 a92:	40e7853b          	subw	a0,a5,a4
}
 a96:	6422                	ld	s0,8(sp)
 a98:	0141                	addi	sp,sp,16
 a9a:	8082                	ret
  return 0;
 a9c:	4501                	li	a0,0
 a9e:	bfe5                	j	a96 <memcmp+0x30>

0000000000000aa0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 aa0:	1141                	addi	sp,sp,-16
 aa2:	e406                	sd	ra,8(sp)
 aa4:	e022                	sd	s0,0(sp)
 aa6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 aa8:	00000097          	auipc	ra,0x0
 aac:	f66080e7          	jalr	-154(ra) # a0e <memmove>
}
 ab0:	60a2                	ld	ra,8(sp)
 ab2:	6402                	ld	s0,0(sp)
 ab4:	0141                	addi	sp,sp,16
 ab6:	8082                	ret

0000000000000ab8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 ab8:	4885                	li	a7,1
 ecall
 aba:	00000073          	ecall
 ret
 abe:	8082                	ret

0000000000000ac0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 ac0:	4889                	li	a7,2
 ecall
 ac2:	00000073          	ecall
 ret
 ac6:	8082                	ret

0000000000000ac8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 ac8:	488d                	li	a7,3
 ecall
 aca:	00000073          	ecall
 ret
 ace:	8082                	ret

0000000000000ad0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 ad0:	4891                	li	a7,4
 ecall
 ad2:	00000073          	ecall
 ret
 ad6:	8082                	ret

0000000000000ad8 <read>:
.global read
read:
 li a7, SYS_read
 ad8:	4895                	li	a7,5
 ecall
 ada:	00000073          	ecall
 ret
 ade:	8082                	ret

0000000000000ae0 <write>:
.global write
write:
 li a7, SYS_write
 ae0:	48c1                	li	a7,16
 ecall
 ae2:	00000073          	ecall
 ret
 ae6:	8082                	ret

0000000000000ae8 <close>:
.global close
close:
 li a7, SYS_close
 ae8:	48d5                	li	a7,21
 ecall
 aea:	00000073          	ecall
 ret
 aee:	8082                	ret

0000000000000af0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 af0:	4899                	li	a7,6
 ecall
 af2:	00000073          	ecall
 ret
 af6:	8082                	ret

0000000000000af8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 af8:	489d                	li	a7,7
 ecall
 afa:	00000073          	ecall
 ret
 afe:	8082                	ret

0000000000000b00 <open>:
.global open
open:
 li a7, SYS_open
 b00:	48bd                	li	a7,15
 ecall
 b02:	00000073          	ecall
 ret
 b06:	8082                	ret

0000000000000b08 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 b08:	48c5                	li	a7,17
 ecall
 b0a:	00000073          	ecall
 ret
 b0e:	8082                	ret

0000000000000b10 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 b10:	48c9                	li	a7,18
 ecall
 b12:	00000073          	ecall
 ret
 b16:	8082                	ret

0000000000000b18 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 b18:	48a1                	li	a7,8
 ecall
 b1a:	00000073          	ecall
 ret
 b1e:	8082                	ret

0000000000000b20 <link>:
.global link
link:
 li a7, SYS_link
 b20:	48cd                	li	a7,19
 ecall
 b22:	00000073          	ecall
 ret
 b26:	8082                	ret

0000000000000b28 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 b28:	48d1                	li	a7,20
 ecall
 b2a:	00000073          	ecall
 ret
 b2e:	8082                	ret

0000000000000b30 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 b30:	48a5                	li	a7,9
 ecall
 b32:	00000073          	ecall
 ret
 b36:	8082                	ret

0000000000000b38 <dup>:
.global dup
dup:
 li a7, SYS_dup
 b38:	48a9                	li	a7,10
 ecall
 b3a:	00000073          	ecall
 ret
 b3e:	8082                	ret

0000000000000b40 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 b40:	48ad                	li	a7,11
 ecall
 b42:	00000073          	ecall
 ret
 b46:	8082                	ret

0000000000000b48 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 b48:	48b1                	li	a7,12
 ecall
 b4a:	00000073          	ecall
 ret
 b4e:	8082                	ret

0000000000000b50 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 b50:	48b5                	li	a7,13
 ecall
 b52:	00000073          	ecall
 ret
 b56:	8082                	ret

0000000000000b58 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 b58:	48b9                	li	a7,14
 ecall
 b5a:	00000073          	ecall
 ret
 b5e:	8082                	ret

0000000000000b60 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 b60:	1101                	addi	sp,sp,-32
 b62:	ec06                	sd	ra,24(sp)
 b64:	e822                	sd	s0,16(sp)
 b66:	1000                	addi	s0,sp,32
 b68:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 b6c:	4605                	li	a2,1
 b6e:	fef40593          	addi	a1,s0,-17
 b72:	00000097          	auipc	ra,0x0
 b76:	f6e080e7          	jalr	-146(ra) # ae0 <write>
}
 b7a:	60e2                	ld	ra,24(sp)
 b7c:	6442                	ld	s0,16(sp)
 b7e:	6105                	addi	sp,sp,32
 b80:	8082                	ret

0000000000000b82 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 b82:	7139                	addi	sp,sp,-64
 b84:	fc06                	sd	ra,56(sp)
 b86:	f822                	sd	s0,48(sp)
 b88:	f426                	sd	s1,40(sp)
 b8a:	f04a                	sd	s2,32(sp)
 b8c:	ec4e                	sd	s3,24(sp)
 b8e:	0080                	addi	s0,sp,64
 b90:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 b92:	c299                	beqz	a3,b98 <printint+0x16>
 b94:	0805c863          	bltz	a1,c24 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 b98:	2581                	sext.w	a1,a1
  neg = 0;
 b9a:	4881                	li	a7,0
 b9c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 ba0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 ba2:	2601                	sext.w	a2,a2
 ba4:	00001517          	auipc	a0,0x1
 ba8:	f3450513          	addi	a0,a0,-204 # 1ad8 <digits>
 bac:	883a                	mv	a6,a4
 bae:	2705                	addiw	a4,a4,1
 bb0:	02c5f7bb          	remuw	a5,a1,a2
 bb4:	1782                	slli	a5,a5,0x20
 bb6:	9381                	srli	a5,a5,0x20
 bb8:	97aa                	add	a5,a5,a0
 bba:	0007c783          	lbu	a5,0(a5)
 bbe:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 bc2:	0005879b          	sext.w	a5,a1
 bc6:	02c5d5bb          	divuw	a1,a1,a2
 bca:	0685                	addi	a3,a3,1
 bcc:	fec7f0e3          	bgeu	a5,a2,bac <printint+0x2a>
  if(neg)
 bd0:	00088b63          	beqz	a7,be6 <printint+0x64>
    buf[i++] = '-';
 bd4:	fd040793          	addi	a5,s0,-48
 bd8:	973e                	add	a4,a4,a5
 bda:	02d00793          	li	a5,45
 bde:	fef70823          	sb	a5,-16(a4)
 be2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 be6:	02e05863          	blez	a4,c16 <printint+0x94>
 bea:	fc040793          	addi	a5,s0,-64
 bee:	00e78933          	add	s2,a5,a4
 bf2:	fff78993          	addi	s3,a5,-1
 bf6:	99ba                	add	s3,s3,a4
 bf8:	377d                	addiw	a4,a4,-1
 bfa:	1702                	slli	a4,a4,0x20
 bfc:	9301                	srli	a4,a4,0x20
 bfe:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 c02:	fff94583          	lbu	a1,-1(s2)
 c06:	8526                	mv	a0,s1
 c08:	00000097          	auipc	ra,0x0
 c0c:	f58080e7          	jalr	-168(ra) # b60 <putc>
  while(--i >= 0)
 c10:	197d                	addi	s2,s2,-1
 c12:	ff3918e3          	bne	s2,s3,c02 <printint+0x80>
}
 c16:	70e2                	ld	ra,56(sp)
 c18:	7442                	ld	s0,48(sp)
 c1a:	74a2                	ld	s1,40(sp)
 c1c:	7902                	ld	s2,32(sp)
 c1e:	69e2                	ld	s3,24(sp)
 c20:	6121                	addi	sp,sp,64
 c22:	8082                	ret
    x = -xx;
 c24:	40b005bb          	negw	a1,a1
    neg = 1;
 c28:	4885                	li	a7,1
    x = -xx;
 c2a:	bf8d                	j	b9c <printint+0x1a>

0000000000000c2c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 c2c:	7119                	addi	sp,sp,-128
 c2e:	fc86                	sd	ra,120(sp)
 c30:	f8a2                	sd	s0,112(sp)
 c32:	f4a6                	sd	s1,104(sp)
 c34:	f0ca                	sd	s2,96(sp)
 c36:	ecce                	sd	s3,88(sp)
 c38:	e8d2                	sd	s4,80(sp)
 c3a:	e4d6                	sd	s5,72(sp)
 c3c:	e0da                	sd	s6,64(sp)
 c3e:	fc5e                	sd	s7,56(sp)
 c40:	f862                	sd	s8,48(sp)
 c42:	f466                	sd	s9,40(sp)
 c44:	f06a                	sd	s10,32(sp)
 c46:	ec6e                	sd	s11,24(sp)
 c48:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 c4a:	0005c903          	lbu	s2,0(a1)
 c4e:	18090f63          	beqz	s2,dec <vprintf+0x1c0>
 c52:	8aaa                	mv	s5,a0
 c54:	8b32                	mv	s6,a2
 c56:	00158493          	addi	s1,a1,1
  state = 0;
 c5a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 c5c:	02500a13          	li	s4,37
      if(c == 'd'){
 c60:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 c64:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 c68:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 c6c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 c70:	00001b97          	auipc	s7,0x1
 c74:	e68b8b93          	addi	s7,s7,-408 # 1ad8 <digits>
 c78:	a839                	j	c96 <vprintf+0x6a>
        putc(fd, c);
 c7a:	85ca                	mv	a1,s2
 c7c:	8556                	mv	a0,s5
 c7e:	00000097          	auipc	ra,0x0
 c82:	ee2080e7          	jalr	-286(ra) # b60 <putc>
 c86:	a019                	j	c8c <vprintf+0x60>
    } else if(state == '%'){
 c88:	01498f63          	beq	s3,s4,ca6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 c8c:	0485                	addi	s1,s1,1
 c8e:	fff4c903          	lbu	s2,-1(s1)
 c92:	14090d63          	beqz	s2,dec <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 c96:	0009079b          	sext.w	a5,s2
    if(state == 0){
 c9a:	fe0997e3          	bnez	s3,c88 <vprintf+0x5c>
      if(c == '%'){
 c9e:	fd479ee3          	bne	a5,s4,c7a <vprintf+0x4e>
        state = '%';
 ca2:	89be                	mv	s3,a5
 ca4:	b7e5                	j	c8c <vprintf+0x60>
      if(c == 'd'){
 ca6:	05878063          	beq	a5,s8,ce6 <vprintf+0xba>
      } else if(c == 'l') {
 caa:	05978c63          	beq	a5,s9,d02 <vprintf+0xd6>
      } else if(c == 'x') {
 cae:	07a78863          	beq	a5,s10,d1e <vprintf+0xf2>
      } else if(c == 'p') {
 cb2:	09b78463          	beq	a5,s11,d3a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 cb6:	07300713          	li	a4,115
 cba:	0ce78663          	beq	a5,a4,d86 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 cbe:	06300713          	li	a4,99
 cc2:	0ee78e63          	beq	a5,a4,dbe <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 cc6:	11478863          	beq	a5,s4,dd6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 cca:	85d2                	mv	a1,s4
 ccc:	8556                	mv	a0,s5
 cce:	00000097          	auipc	ra,0x0
 cd2:	e92080e7          	jalr	-366(ra) # b60 <putc>
        putc(fd, c);
 cd6:	85ca                	mv	a1,s2
 cd8:	8556                	mv	a0,s5
 cda:	00000097          	auipc	ra,0x0
 cde:	e86080e7          	jalr	-378(ra) # b60 <putc>
      }
      state = 0;
 ce2:	4981                	li	s3,0
 ce4:	b765                	j	c8c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 ce6:	008b0913          	addi	s2,s6,8
 cea:	4685                	li	a3,1
 cec:	4629                	li	a2,10
 cee:	000b2583          	lw	a1,0(s6)
 cf2:	8556                	mv	a0,s5
 cf4:	00000097          	auipc	ra,0x0
 cf8:	e8e080e7          	jalr	-370(ra) # b82 <printint>
 cfc:	8b4a                	mv	s6,s2
      state = 0;
 cfe:	4981                	li	s3,0
 d00:	b771                	j	c8c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 d02:	008b0913          	addi	s2,s6,8
 d06:	4681                	li	a3,0
 d08:	4629                	li	a2,10
 d0a:	000b2583          	lw	a1,0(s6)
 d0e:	8556                	mv	a0,s5
 d10:	00000097          	auipc	ra,0x0
 d14:	e72080e7          	jalr	-398(ra) # b82 <printint>
 d18:	8b4a                	mv	s6,s2
      state = 0;
 d1a:	4981                	li	s3,0
 d1c:	bf85                	j	c8c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 d1e:	008b0913          	addi	s2,s6,8
 d22:	4681                	li	a3,0
 d24:	4641                	li	a2,16
 d26:	000b2583          	lw	a1,0(s6)
 d2a:	8556                	mv	a0,s5
 d2c:	00000097          	auipc	ra,0x0
 d30:	e56080e7          	jalr	-426(ra) # b82 <printint>
 d34:	8b4a                	mv	s6,s2
      state = 0;
 d36:	4981                	li	s3,0
 d38:	bf91                	j	c8c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 d3a:	008b0793          	addi	a5,s6,8
 d3e:	f8f43423          	sd	a5,-120(s0)
 d42:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 d46:	03000593          	li	a1,48
 d4a:	8556                	mv	a0,s5
 d4c:	00000097          	auipc	ra,0x0
 d50:	e14080e7          	jalr	-492(ra) # b60 <putc>
  putc(fd, 'x');
 d54:	85ea                	mv	a1,s10
 d56:	8556                	mv	a0,s5
 d58:	00000097          	auipc	ra,0x0
 d5c:	e08080e7          	jalr	-504(ra) # b60 <putc>
 d60:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 d62:	03c9d793          	srli	a5,s3,0x3c
 d66:	97de                	add	a5,a5,s7
 d68:	0007c583          	lbu	a1,0(a5)
 d6c:	8556                	mv	a0,s5
 d6e:	00000097          	auipc	ra,0x0
 d72:	df2080e7          	jalr	-526(ra) # b60 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 d76:	0992                	slli	s3,s3,0x4
 d78:	397d                	addiw	s2,s2,-1
 d7a:	fe0914e3          	bnez	s2,d62 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 d7e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 d82:	4981                	li	s3,0
 d84:	b721                	j	c8c <vprintf+0x60>
        s = va_arg(ap, char*);
 d86:	008b0993          	addi	s3,s6,8
 d8a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 d8e:	02090163          	beqz	s2,db0 <vprintf+0x184>
        while(*s != 0){
 d92:	00094583          	lbu	a1,0(s2)
 d96:	c9a1                	beqz	a1,de6 <vprintf+0x1ba>
          putc(fd, *s);
 d98:	8556                	mv	a0,s5
 d9a:	00000097          	auipc	ra,0x0
 d9e:	dc6080e7          	jalr	-570(ra) # b60 <putc>
          s++;
 da2:	0905                	addi	s2,s2,1
        while(*s != 0){
 da4:	00094583          	lbu	a1,0(s2)
 da8:	f9e5                	bnez	a1,d98 <vprintf+0x16c>
        s = va_arg(ap, char*);
 daa:	8b4e                	mv	s6,s3
      state = 0;
 dac:	4981                	li	s3,0
 dae:	bdf9                	j	c8c <vprintf+0x60>
          s = "(null)";
 db0:	00001917          	auipc	s2,0x1
 db4:	d2090913          	addi	s2,s2,-736 # 1ad0 <malloc+0xbda>
        while(*s != 0){
 db8:	02800593          	li	a1,40
 dbc:	bff1                	j	d98 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 dbe:	008b0913          	addi	s2,s6,8
 dc2:	000b4583          	lbu	a1,0(s6)
 dc6:	8556                	mv	a0,s5
 dc8:	00000097          	auipc	ra,0x0
 dcc:	d98080e7          	jalr	-616(ra) # b60 <putc>
 dd0:	8b4a                	mv	s6,s2
      state = 0;
 dd2:	4981                	li	s3,0
 dd4:	bd65                	j	c8c <vprintf+0x60>
        putc(fd, c);
 dd6:	85d2                	mv	a1,s4
 dd8:	8556                	mv	a0,s5
 dda:	00000097          	auipc	ra,0x0
 dde:	d86080e7          	jalr	-634(ra) # b60 <putc>
      state = 0;
 de2:	4981                	li	s3,0
 de4:	b565                	j	c8c <vprintf+0x60>
        s = va_arg(ap, char*);
 de6:	8b4e                	mv	s6,s3
      state = 0;
 de8:	4981                	li	s3,0
 dea:	b54d                	j	c8c <vprintf+0x60>
    }
  }
}
 dec:	70e6                	ld	ra,120(sp)
 dee:	7446                	ld	s0,112(sp)
 df0:	74a6                	ld	s1,104(sp)
 df2:	7906                	ld	s2,96(sp)
 df4:	69e6                	ld	s3,88(sp)
 df6:	6a46                	ld	s4,80(sp)
 df8:	6aa6                	ld	s5,72(sp)
 dfa:	6b06                	ld	s6,64(sp)
 dfc:	7be2                	ld	s7,56(sp)
 dfe:	7c42                	ld	s8,48(sp)
 e00:	7ca2                	ld	s9,40(sp)
 e02:	7d02                	ld	s10,32(sp)
 e04:	6de2                	ld	s11,24(sp)
 e06:	6109                	addi	sp,sp,128
 e08:	8082                	ret

0000000000000e0a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 e0a:	715d                	addi	sp,sp,-80
 e0c:	ec06                	sd	ra,24(sp)
 e0e:	e822                	sd	s0,16(sp)
 e10:	1000                	addi	s0,sp,32
 e12:	e010                	sd	a2,0(s0)
 e14:	e414                	sd	a3,8(s0)
 e16:	e818                	sd	a4,16(s0)
 e18:	ec1c                	sd	a5,24(s0)
 e1a:	03043023          	sd	a6,32(s0)
 e1e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 e22:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 e26:	8622                	mv	a2,s0
 e28:	00000097          	auipc	ra,0x0
 e2c:	e04080e7          	jalr	-508(ra) # c2c <vprintf>
}
 e30:	60e2                	ld	ra,24(sp)
 e32:	6442                	ld	s0,16(sp)
 e34:	6161                	addi	sp,sp,80
 e36:	8082                	ret

0000000000000e38 <printf>:

void
printf(const char *fmt, ...)
{
 e38:	711d                	addi	sp,sp,-96
 e3a:	ec06                	sd	ra,24(sp)
 e3c:	e822                	sd	s0,16(sp)
 e3e:	1000                	addi	s0,sp,32
 e40:	e40c                	sd	a1,8(s0)
 e42:	e810                	sd	a2,16(s0)
 e44:	ec14                	sd	a3,24(s0)
 e46:	f018                	sd	a4,32(s0)
 e48:	f41c                	sd	a5,40(s0)
 e4a:	03043823          	sd	a6,48(s0)
 e4e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 e52:	00840613          	addi	a2,s0,8
 e56:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 e5a:	85aa                	mv	a1,a0
 e5c:	4505                	li	a0,1
 e5e:	00000097          	auipc	ra,0x0
 e62:	dce080e7          	jalr	-562(ra) # c2c <vprintf>
}
 e66:	60e2                	ld	ra,24(sp)
 e68:	6442                	ld	s0,16(sp)
 e6a:	6125                	addi	sp,sp,96
 e6c:	8082                	ret

0000000000000e6e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 e6e:	1141                	addi	sp,sp,-16
 e70:	e422                	sd	s0,8(sp)
 e72:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 e74:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e78:	00001797          	auipc	a5,0x1
 e7c:	c787b783          	ld	a5,-904(a5) # 1af0 <freep>
 e80:	a805                	j	eb0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 e82:	4618                	lw	a4,8(a2)
 e84:	9db9                	addw	a1,a1,a4
 e86:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 e8a:	6398                	ld	a4,0(a5)
 e8c:	6318                	ld	a4,0(a4)
 e8e:	fee53823          	sd	a4,-16(a0)
 e92:	a091                	j	ed6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 e94:	ff852703          	lw	a4,-8(a0)
 e98:	9e39                	addw	a2,a2,a4
 e9a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 e9c:	ff053703          	ld	a4,-16(a0)
 ea0:	e398                	sd	a4,0(a5)
 ea2:	a099                	j	ee8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ea4:	6398                	ld	a4,0(a5)
 ea6:	00e7e463          	bltu	a5,a4,eae <free+0x40>
 eaa:	00e6ea63          	bltu	a3,a4,ebe <free+0x50>
{
 eae:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 eb0:	fed7fae3          	bgeu	a5,a3,ea4 <free+0x36>
 eb4:	6398                	ld	a4,0(a5)
 eb6:	00e6e463          	bltu	a3,a4,ebe <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 eba:	fee7eae3          	bltu	a5,a4,eae <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 ebe:	ff852583          	lw	a1,-8(a0)
 ec2:	6390                	ld	a2,0(a5)
 ec4:	02059813          	slli	a6,a1,0x20
 ec8:	01c85713          	srli	a4,a6,0x1c
 ecc:	9736                	add	a4,a4,a3
 ece:	fae60ae3          	beq	a2,a4,e82 <free+0x14>
    bp->s.ptr = p->s.ptr;
 ed2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 ed6:	4790                	lw	a2,8(a5)
 ed8:	02061593          	slli	a1,a2,0x20
 edc:	01c5d713          	srli	a4,a1,0x1c
 ee0:	973e                	add	a4,a4,a5
 ee2:	fae689e3          	beq	a3,a4,e94 <free+0x26>
  } else
    p->s.ptr = bp;
 ee6:	e394                	sd	a3,0(a5)
  freep = p;
 ee8:	00001717          	auipc	a4,0x1
 eec:	c0f73423          	sd	a5,-1016(a4) # 1af0 <freep>
}
 ef0:	6422                	ld	s0,8(sp)
 ef2:	0141                	addi	sp,sp,16
 ef4:	8082                	ret

0000000000000ef6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 ef6:	7139                	addi	sp,sp,-64
 ef8:	fc06                	sd	ra,56(sp)
 efa:	f822                	sd	s0,48(sp)
 efc:	f426                	sd	s1,40(sp)
 efe:	f04a                	sd	s2,32(sp)
 f00:	ec4e                	sd	s3,24(sp)
 f02:	e852                	sd	s4,16(sp)
 f04:	e456                	sd	s5,8(sp)
 f06:	e05a                	sd	s6,0(sp)
 f08:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 f0a:	02051493          	slli	s1,a0,0x20
 f0e:	9081                	srli	s1,s1,0x20
 f10:	04bd                	addi	s1,s1,15
 f12:	8091                	srli	s1,s1,0x4
 f14:	0014899b          	addiw	s3,s1,1
 f18:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 f1a:	00001517          	auipc	a0,0x1
 f1e:	bd653503          	ld	a0,-1066(a0) # 1af0 <freep>
 f22:	c515                	beqz	a0,f4e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f24:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 f26:	4798                	lw	a4,8(a5)
 f28:	02977f63          	bgeu	a4,s1,f66 <malloc+0x70>
 f2c:	8a4e                	mv	s4,s3
 f2e:	0009871b          	sext.w	a4,s3
 f32:	6685                	lui	a3,0x1
 f34:	00d77363          	bgeu	a4,a3,f3a <malloc+0x44>
 f38:	6a05                	lui	s4,0x1
 f3a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 f3e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 f42:	00001917          	auipc	s2,0x1
 f46:	bae90913          	addi	s2,s2,-1106 # 1af0 <freep>
  if(p == (char*)-1)
 f4a:	5afd                	li	s5,-1
 f4c:	a895                	j	fc0 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 f4e:	00001797          	auipc	a5,0x1
 f52:	baa78793          	addi	a5,a5,-1110 # 1af8 <base>
 f56:	00001717          	auipc	a4,0x1
 f5a:	b8f73d23          	sd	a5,-1126(a4) # 1af0 <freep>
 f5e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 f60:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 f64:	b7e1                	j	f2c <malloc+0x36>
      if(p->s.size == nunits)
 f66:	02e48c63          	beq	s1,a4,f9e <malloc+0xa8>
        p->s.size -= nunits;
 f6a:	4137073b          	subw	a4,a4,s3
 f6e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 f70:	02071693          	slli	a3,a4,0x20
 f74:	01c6d713          	srli	a4,a3,0x1c
 f78:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 f7a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 f7e:	00001717          	auipc	a4,0x1
 f82:	b6a73923          	sd	a0,-1166(a4) # 1af0 <freep>
      return (void*)(p + 1);
 f86:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 f8a:	70e2                	ld	ra,56(sp)
 f8c:	7442                	ld	s0,48(sp)
 f8e:	74a2                	ld	s1,40(sp)
 f90:	7902                	ld	s2,32(sp)
 f92:	69e2                	ld	s3,24(sp)
 f94:	6a42                	ld	s4,16(sp)
 f96:	6aa2                	ld	s5,8(sp)
 f98:	6b02                	ld	s6,0(sp)
 f9a:	6121                	addi	sp,sp,64
 f9c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 f9e:	6398                	ld	a4,0(a5)
 fa0:	e118                	sd	a4,0(a0)
 fa2:	bff1                	j	f7e <malloc+0x88>
  hp->s.size = nu;
 fa4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 fa8:	0541                	addi	a0,a0,16
 faa:	00000097          	auipc	ra,0x0
 fae:	ec4080e7          	jalr	-316(ra) # e6e <free>
  return freep;
 fb2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 fb6:	d971                	beqz	a0,f8a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 fb8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 fba:	4798                	lw	a4,8(a5)
 fbc:	fa9775e3          	bgeu	a4,s1,f66 <malloc+0x70>
    if(p == freep)
 fc0:	00093703          	ld	a4,0(s2)
 fc4:	853e                	mv	a0,a5
 fc6:	fef719e3          	bne	a4,a5,fb8 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 fca:	8552                	mv	a0,s4
 fcc:	00000097          	auipc	ra,0x0
 fd0:	b7c080e7          	jalr	-1156(ra) # b48 <sbrk>
  if(p == (char*)-1)
 fd4:	fd5518e3          	bne	a0,s5,fa4 <malloc+0xae>
        return 0;
 fd8:	4501                	li	a0,0
 fda:	bf45                	j	f8a <malloc+0x94>
