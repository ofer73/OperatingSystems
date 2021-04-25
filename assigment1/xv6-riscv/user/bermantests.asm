
user/_bermantests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test>:
#include "kernel/perf.h"

// #################################### TESTS ##########################

int test()
{
   0:	715d                	addi	sp,sp,-80
   2:	e486                	sd	ra,72(sp)
   4:	e0a2                	sd	s0,64(sp)
   6:	fc26                	sd	s1,56(sp)
   8:	f84a                	sd	s2,48(sp)
   a:	f44e                	sd	s3,40(sp)
   c:	0880                	addi	s0,sp,80
    printf("started\n");
   e:	00001517          	auipc	a0,0x1
  12:	f5250513          	addi	a0,a0,-174 # f60 <malloc+0xe8>
  16:	00001097          	auipc	ra,0x1
  1a:	da4080e7          	jalr	-604(ra) # dba <printf>

    int pid2;
    if ((pid2 = fork()) == 0)
  1e:	00001097          	auipc	ra,0x1
  22:	a04080e7          	jalr	-1532(ra) # a22 <fork>
  26:	cd79                	beqz	a0,104 <test+0x104>
    else
    {
        int status;
        struct perf p;

        int x = wait_stat(&status, &p);
  28:	fb840593          	addi	a1,s0,-72
  2c:	fb440513          	addi	a0,s0,-76
  30:	00001097          	auipc	ra,0x1
  34:	aa2080e7          	jalr	-1374(ra) # ad2 <wait_stat>
  38:	85aa                	mv	a1,a0

        printf("ret val: %d ", x);
  3a:	00001517          	auipc	a0,0x1
  3e:	f4650513          	addi	a0,a0,-186 # f80 <malloc+0x108>
  42:	00001097          	auipc	ra,0x1
  46:	d78080e7          	jalr	-648(ra) # dba <printf>
        printf("ctime: %d ", p.ctime);
  4a:	fb842583          	lw	a1,-72(s0)
  4e:	00001517          	auipc	a0,0x1
  52:	f4250513          	addi	a0,a0,-190 # f90 <malloc+0x118>
  56:	00001097          	auipc	ra,0x1
  5a:	d64080e7          	jalr	-668(ra) # dba <printf>
        printf("ttime: %d ", p.ttime);
  5e:	fbc42583          	lw	a1,-68(s0)
  62:	00001517          	auipc	a0,0x1
  66:	f3e50513          	addi	a0,a0,-194 # fa0 <malloc+0x128>
  6a:	00001097          	auipc	ra,0x1
  6e:	d50080e7          	jalr	-688(ra) # dba <printf>
        printf("stime: %d ", p.stime);
  72:	fc042583          	lw	a1,-64(s0)
  76:	00001517          	auipc	a0,0x1
  7a:	f3a50513          	addi	a0,a0,-198 # fb0 <malloc+0x138>
  7e:	00001097          	auipc	ra,0x1
  82:	d3c080e7          	jalr	-708(ra) # dba <printf>
        printf("retime: %d ", p.retime);
  86:	fc442583          	lw	a1,-60(s0)
  8a:	00001517          	auipc	a0,0x1
  8e:	f3650513          	addi	a0,a0,-202 # fc0 <malloc+0x148>
  92:	00001097          	auipc	ra,0x1
  96:	d28080e7          	jalr	-728(ra) # dba <printf>
        printf("rutime: %d", p.rutime);
  9a:	fc842583          	lw	a1,-56(s0)
  9e:	00001517          	auipc	a0,0x1
  a2:	f3250513          	addi	a0,a0,-206 # fd0 <malloc+0x158>
  a6:	00001097          	auipc	ra,0x1
  aa:	d14080e7          	jalr	-748(ra) # dba <printf>
        printf("bursttime: %d\n", p.average_bursttime);
  ae:	fcc42583          	lw	a1,-52(s0)
  b2:	00001517          	auipc	a0,0x1
  b6:	f2e50513          	addi	a0,a0,-210 # fe0 <malloc+0x168>
  ba:	00001097          	auipc	ra,0x1
  be:	d00080e7          	jalr	-768(ra) # dba <printf>
        printf("xstate: %d\n\n", status);
  c2:	fb442583          	lw	a1,-76(s0)
  c6:	00001517          	auipc	a0,0x1
  ca:	f2a50513          	addi	a0,a0,-214 # ff0 <malloc+0x178>
  ce:	00001097          	auipc	ra,0x1
  d2:	cec080e7          	jalr	-788(ra) # dba <printf>
    }

    wait(0);
  d6:	4501                	li	a0,0
  d8:	00001097          	auipc	ra,0x1
  dc:	95a080e7          	jalr	-1702(ra) # a32 <wait>
    sleep(1);
  e0:	4505                	li	a0,1
  e2:	00001097          	auipc	ra,0x1
  e6:	9d8080e7          	jalr	-1576(ra) # aba <sleep>
    sbrk(4096);
  ea:	6505                	lui	a0,0x1
  ec:	00001097          	auipc	ra,0x1
  f0:	9c6080e7          	jalr	-1594(ra) # ab2 <sbrk>

    return 0;
}
  f4:	4501                	li	a0,0
  f6:	60a6                	ld	ra,72(sp)
  f8:	6406                	ld	s0,64(sp)
  fa:	74e2                	ld	s1,56(sp)
  fc:	7942                	ld	s2,48(sp)
  fe:	79a2                	ld	s3,40(sp)
 100:	6161                	addi	sp,sp,80
 102:	8082                	ret
            printf("sooonnn");
 104:	00001517          	auipc	a0,0x1
 108:	e6c50513          	addi	a0,a0,-404 # f70 <malloc+0xf8>
 10c:	00001097          	auipc	ra,0x1
 110:	cae080e7          	jalr	-850(ra) # dba <printf>
            sleep(10);
 114:	4529                	li	a0,10
 116:	00001097          	auipc	ra,0x1
 11a:	9a4080e7          	jalr	-1628(ra) # aba <sleep>
            printf("sooonnn");
 11e:	00001517          	auipc	a0,0x1
 122:	e5250513          	addi	a0,a0,-430 # f70 <malloc+0xf8>
 126:	00001097          	auipc	ra,0x1
 12a:	c94080e7          	jalr	-876(ra) # dba <printf>
            sleep(10);
 12e:	4529                	li	a0,10
 130:	00001097          	auipc	ra,0x1
 134:	98a080e7          	jalr	-1654(ra) # aba <sleep>
            printf("sooonnn");
 138:	00001517          	auipc	a0,0x1
 13c:	e3850513          	addi	a0,a0,-456 # f70 <malloc+0xf8>
 140:	00001097          	auipc	ra,0x1
 144:	c7a080e7          	jalr	-902(ra) # dba <printf>
            sleep(10);
 148:	4529                	li	a0,10
 14a:	00001097          	auipc	ra,0x1
 14e:	970080e7          	jalr	-1680(ra) # aba <sleep>
            c++;
 152:	448d                	li	s1,3
            printf("%d\n", c);
 154:	00001997          	auipc	s3,0x1
 158:	f4498993          	addi	s3,s3,-188 # 1098 <malloc+0x220>
        while (c < 1000)
 15c:	3e800913          	li	s2,1000
            printf("%d\n", c);
 160:	85a6                	mv	a1,s1
 162:	854e                	mv	a0,s3
 164:	00001097          	auipc	ra,0x1
 168:	c56080e7          	jalr	-938(ra) # dba <printf>
            c++;
 16c:	2485                	addiw	s1,s1,1
        while (c < 1000)
 16e:	ff2499e3          	bne	s1,s2,160 <test+0x160>
        printf("\n");
 172:	00001517          	auipc	a0,0x1
 176:	e0650513          	addi	a0,a0,-506 # f78 <malloc+0x100>
 17a:	00001097          	auipc	ra,0x1
 17e:	c40080e7          	jalr	-960(ra) # dba <printf>
        exit(0);
 182:	4501                	li	a0,0
 184:	00001097          	auipc	ra,0x1
 188:	8a6080e7          	jalr	-1882(ra) # a2a <exit>

000000000000018c <priorityTest>:

int priorityTest()
{
 18c:	1101                	addi	sp,sp,-32
 18e:	ec06                	sd	ra,24(sp)
 190:	e822                	sd	s0,16(sp)
 192:	e426                	sd	s1,8(sp)
 194:	e04a                	sd	s2,0(sp)
 196:	1000                	addi	s0,sp,32
    int mask = (1 << SYS_set_priority);

    int pid = fork();
 198:	00001097          	auipc	ra,0x1
 19c:	88a080e7          	jalr	-1910(ra) # a22 <fork>
 1a0:	84aa                	mv	s1,a0
    trace(mask, pid);
 1a2:	85aa                	mv	a1,a0
 1a4:	01000537          	lui	a0,0x1000
 1a8:	00001097          	auipc	ra,0x1
 1ac:	922080e7          	jalr	-1758(ra) # aca <trace>
    if (pid == 0)
 1b0:	e8b9                	bnez	s1,206 <priorityTest+0x7a>
    {
        int badRes = set_priority(7);
 1b2:	451d                	li	a0,7
 1b4:	00001097          	auipc	ra,0x1
 1b8:	926080e7          	jalr	-1754(ra) # ada <set_priority>
        {
            printf("boundries not working");
            return -1;
        }

        for (int i = 1; i < 6; i++)
 1bc:	4485                	li	s1,1
 1be:	4919                	li	s2,6
        if (badRes == 0)
 1c0:	cd19                	beqz	a0,1de <priorityTest+0x52>
        {
            int goodRes = set_priority(i);
 1c2:	8526                	mv	a0,s1
 1c4:	00001097          	auipc	ra,0x1
 1c8:	916080e7          	jalr	-1770(ra) # ada <set_priority>
            if (goodRes != 0)
 1cc:	e11d                	bnez	a0,1f2 <priorityTest+0x66>
        for (int i = 1; i < 6; i++)
 1ce:	2485                	addiw	s1,s1,1
 1d0:	ff2499e3          	bne	s1,s2,1c2 <priorityTest+0x36>
            {
                printf("priority set not working");
                return -1;
            }
        }
        exit(0);
 1d4:	4501                	li	a0,0
 1d6:	00001097          	auipc	ra,0x1
 1da:	854080e7          	jalr	-1964(ra) # a2a <exit>
            printf("boundries not working");
 1de:	00001517          	auipc	a0,0x1
 1e2:	e2250513          	addi	a0,a0,-478 # 1000 <malloc+0x188>
 1e6:	00001097          	auipc	ra,0x1
 1ea:	bd4080e7          	jalr	-1068(ra) # dba <printf>
            return -1;
 1ee:	557d                	li	a0,-1
 1f0:	a00d                	j	212 <priorityTest+0x86>
                printf("priority set not working");
 1f2:	00001517          	auipc	a0,0x1
 1f6:	e2650513          	addi	a0,a0,-474 # 1018 <malloc+0x1a0>
 1fa:	00001097          	auipc	ra,0x1
 1fe:	bc0080e7          	jalr	-1088(ra) # dba <printf>
                return -1;
 202:	557d                	li	a0,-1
 204:	a039                	j	212 <priorityTest+0x86>
    }
    wait(0);
 206:	4501                	li	a0,0
 208:	00001097          	auipc	ra,0x1
 20c:	82a080e7          	jalr	-2006(ra) # a32 <wait>
    return 0;
 210:	4501                	li	a0,0
}
 212:	60e2                	ld	ra,24(sp)
 214:	6442                	ld	s0,16(sp)
 216:	64a2                	ld	s1,8(sp)
 218:	6902                	ld	s2,0(sp)
 21a:	6105                	addi	sp,sp,32
 21c:	8082                	ret

000000000000021e <fcfsTest>:

int fcfsTest()
{
 21e:	7139                	addi	sp,sp,-64
 220:	fc06                	sd	ra,56(sp)
 222:	f822                	sd	s0,48(sp)
 224:	f426                	sd	s1,40(sp)
 226:	f04a                	sd	s2,32(sp)
 228:	0080                	addi	s0,sp,64

    sleep(10);
 22a:	4529                	li	a0,10
 22c:	00001097          	auipc	ra,0x1
 230:	88e080e7          	jalr	-1906(ra) # aba <sleep>

    // create son
    int pid = fork();
 234:	00000097          	auipc	ra,0x0
 238:	7ee080e7          	jalr	2030(ra) # a22 <fork>
    // int mask2 = (1 << SYS_priority);
    // trace(mask1, father);
    // trace(mask2, pid);

    // son
    if (pid == 0)
 23c:	06400493          	li	s1,100
    }
    // father
    else
    {
        for (int i = 0; i < 100; i++)
            printf("father before son!\n");
 240:	00001917          	auipc	s2,0x1
 244:	e2890913          	addi	s2,s2,-472 # 1068 <malloc+0x1f0>
    if (pid == 0)
 248:	cd55                	beqz	a0,304 <fcfsTest+0xe6>
            printf("father before son!\n");
 24a:	854a                	mv	a0,s2
 24c:	00001097          	auipc	ra,0x1
 250:	b6e080e7          	jalr	-1170(ra) # dba <printf>
        for (int i = 0; i < 100; i++)
 254:	34fd                	addiw	s1,s1,-1
 256:	f8f5                	bnez	s1,24a <fcfsTest+0x2c>
        sleep(3); // go to the back of the line
 258:	450d                	li	a0,3
 25a:	00001097          	auipc	ra,0x1
 25e:	860080e7          	jalr	-1952(ra) # aba <sleep>
        printf("I'am back!!!\n");
 262:	00001517          	auipc	a0,0x1
 266:	e1e50513          	addi	a0,a0,-482 # 1080 <malloc+0x208>
 26a:	00001097          	auipc	ra,0x1
 26e:	b50080e7          	jalr	-1200(ra) # dba <printf>
    }

    struct perf p;

    int x = wait_stat(0,&p);
 272:	fc840593          	addi	a1,s0,-56
 276:	4501                	li	a0,0
 278:	00001097          	auipc	ra,0x1
 27c:	85a080e7          	jalr	-1958(ra) # ad2 <wait_stat>
 280:	85aa                	mv	a1,a0
    printf("ret val: %d ", x);
 282:	00001517          	auipc	a0,0x1
 286:	cfe50513          	addi	a0,a0,-770 # f80 <malloc+0x108>
 28a:	00001097          	auipc	ra,0x1
 28e:	b30080e7          	jalr	-1232(ra) # dba <printf>
    printf("ctime: %d ", p.ctime);
 292:	fc842583          	lw	a1,-56(s0)
 296:	00001517          	auipc	a0,0x1
 29a:	cfa50513          	addi	a0,a0,-774 # f90 <malloc+0x118>
 29e:	00001097          	auipc	ra,0x1
 2a2:	b1c080e7          	jalr	-1252(ra) # dba <printf>
    printf("ttime: %d ", p.ttime);
 2a6:	fcc42583          	lw	a1,-52(s0)
 2aa:	00001517          	auipc	a0,0x1
 2ae:	cf650513          	addi	a0,a0,-778 # fa0 <malloc+0x128>
 2b2:	00001097          	auipc	ra,0x1
 2b6:	b08080e7          	jalr	-1272(ra) # dba <printf>
    printf("stime: %d ", p.stime);
 2ba:	fd042583          	lw	a1,-48(s0)
 2be:	00001517          	auipc	a0,0x1
 2c2:	cf250513          	addi	a0,a0,-782 # fb0 <malloc+0x138>
 2c6:	00001097          	auipc	ra,0x1
 2ca:	af4080e7          	jalr	-1292(ra) # dba <printf>
    printf("retime: %d ", p.retime);
 2ce:	fd442583          	lw	a1,-44(s0)
 2d2:	00001517          	auipc	a0,0x1
 2d6:	cee50513          	addi	a0,a0,-786 # fc0 <malloc+0x148>
 2da:	00001097          	auipc	ra,0x1
 2de:	ae0080e7          	jalr	-1312(ra) # dba <printf>
    printf("rutime: %d\n", p.rutime);
 2e2:	fd842583          	lw	a1,-40(s0)
 2e6:	00001517          	auipc	a0,0x1
 2ea:	daa50513          	addi	a0,a0,-598 # 1090 <malloc+0x218>
 2ee:	00001097          	auipc	ra,0x1
 2f2:	acc080e7          	jalr	-1332(ra) # dba <printf>

    return 0;
}
 2f6:	4501                	li	a0,0
 2f8:	70e2                	ld	ra,56(sp)
 2fa:	7442                	ld	s0,48(sp)
 2fc:	74a2                	ld	s1,40(sp)
 2fe:	7902                	ld	s2,32(sp)
 300:	6121                	addi	sp,sp,64
 302:	8082                	ret
            printf("pid: %d ,my turn now\n", pid);
 304:	00001917          	auipc	s2,0x1
 308:	d3490913          	addi	s2,s2,-716 # 1038 <malloc+0x1c0>
 30c:	4581                	li	a1,0
 30e:	854a                	mv	a0,s2
 310:	00001097          	auipc	ra,0x1
 314:	aaa080e7          	jalr	-1366(ra) # dba <printf>
        for (int i = 0; i < 100; i++)
 318:	34fd                	addiw	s1,s1,-1
 31a:	f8ed                	bnez	s1,30c <fcfsTest+0xee>
        sleep(1);
 31c:	4505                	li	a0,1
 31e:	00000097          	auipc	ra,0x0
 322:	79c080e7          	jalr	1948(ra) # aba <sleep>
        printf("I'am alsoooo back!!!\n");
 326:	00001517          	auipc	a0,0x1
 32a:	d2a50513          	addi	a0,a0,-726 # 1050 <malloc+0x1d8>
 32e:	00001097          	auipc	ra,0x1
 332:	a8c080e7          	jalr	-1396(ra) # dba <printf>
        exit(0);
 336:	4501                	li	a0,0
 338:	00000097          	auipc	ra,0x0
 33c:	6f2080e7          	jalr	1778(ra) # a2a <exit>

0000000000000340 <cfsdTest1>:

int cfsdTest1(){
 340:	7139                	addi	sp,sp,-64
 342:	fc06                	sd	ra,56(sp)
 344:	f822                	sd	s0,48(sp)
 346:	f426                	sd	s1,40(sp)
 348:	f04a                	sd	s2,32(sp)
 34a:	0080                	addi	s0,sp,64
    
    sleep(10);
 34c:	4529                	li	a0,10
 34e:	00000097          	auipc	ra,0x0
 352:	76c080e7          	jalr	1900(ra) # aba <sleep>

    // create son
    int pid = fork();
 356:	00000097          	auipc	ra,0x0
 35a:	6cc080e7          	jalr	1740(ra) # a22 <fork>
    // int mask2 = (1 << SYS_priority);
    // trace(mask1, father);
    // trace(mask2, pid);

    // son
    if(pid == 0){
 35e:	06400493          	li	s1,100
        exit(0);
    }
    // father
    else{
        for (int i = 0; i < 100; i++)
            printf("father before son!\n");
 362:	00001917          	auipc	s2,0x1
 366:	d0690913          	addi	s2,s2,-762 # 1068 <malloc+0x1f0>
    if(pid == 0){
 36a:	c14d                	beqz	a0,40c <cfsdTest1+0xcc>
            printf("father before son!\n");
 36c:	854a                	mv	a0,s2
 36e:	00001097          	auipc	ra,0x1
 372:	a4c080e7          	jalr	-1460(ra) # dba <printf>
        for (int i = 0; i < 100; i++)
 376:	34fd                	addiw	s1,s1,-1
 378:	f8f5                	bnez	s1,36c <cfsdTest1+0x2c>
    }

    struct perf p;

    int x = wait_stat(0,&p);
 37a:	fc840593          	addi	a1,s0,-56
 37e:	4501                	li	a0,0
 380:	00000097          	auipc	ra,0x0
 384:	752080e7          	jalr	1874(ra) # ad2 <wait_stat>
 388:	85aa                	mv	a1,a0
    printf("ret val: %d ", x);
 38a:	00001517          	auipc	a0,0x1
 38e:	bf650513          	addi	a0,a0,-1034 # f80 <malloc+0x108>
 392:	00001097          	auipc	ra,0x1
 396:	a28080e7          	jalr	-1496(ra) # dba <printf>
    printf("ctime: %d ", p.ctime);
 39a:	fc842583          	lw	a1,-56(s0)
 39e:	00001517          	auipc	a0,0x1
 3a2:	bf250513          	addi	a0,a0,-1038 # f90 <malloc+0x118>
 3a6:	00001097          	auipc	ra,0x1
 3aa:	a14080e7          	jalr	-1516(ra) # dba <printf>
    printf("ttime: %d ", p.ttime);
 3ae:	fcc42583          	lw	a1,-52(s0)
 3b2:	00001517          	auipc	a0,0x1
 3b6:	bee50513          	addi	a0,a0,-1042 # fa0 <malloc+0x128>
 3ba:	00001097          	auipc	ra,0x1
 3be:	a00080e7          	jalr	-1536(ra) # dba <printf>
    printf("stime: %d ", p.stime);
 3c2:	fd042583          	lw	a1,-48(s0)
 3c6:	00001517          	auipc	a0,0x1
 3ca:	bea50513          	addi	a0,a0,-1046 # fb0 <malloc+0x138>
 3ce:	00001097          	auipc	ra,0x1
 3d2:	9ec080e7          	jalr	-1556(ra) # dba <printf>
    printf("retime: %d ", p.retime);
 3d6:	fd442583          	lw	a1,-44(s0)
 3da:	00001517          	auipc	a0,0x1
 3de:	be650513          	addi	a0,a0,-1050 # fc0 <malloc+0x148>
 3e2:	00001097          	auipc	ra,0x1
 3e6:	9d8080e7          	jalr	-1576(ra) # dba <printf>
    printf("rutime: %d\n", p.rutime);
 3ea:	fd842583          	lw	a1,-40(s0)
 3ee:	00001517          	auipc	a0,0x1
 3f2:	ca250513          	addi	a0,a0,-862 # 1090 <malloc+0x218>
 3f6:	00001097          	auipc	ra,0x1
 3fa:	9c4080e7          	jalr	-1596(ra) # dba <printf>

    return 0;
}
 3fe:	4501                	li	a0,0
 400:	70e2                	ld	ra,56(sp)
 402:	7442                	ld	s0,48(sp)
 404:	74a2                	ld	s1,40(sp)
 406:	7902                	ld	s2,32(sp)
 408:	6121                	addi	sp,sp,64
 40a:	8082                	ret
        set_priority(5);
 40c:	4515                	li	a0,5
 40e:	00000097          	auipc	ra,0x0
 412:	6cc080e7          	jalr	1740(ra) # ada <set_priority>
            printf("pid: %d ,not here! my turn now\n", pid);
 416:	00001917          	auipc	s2,0x1
 41a:	c8a90913          	addi	s2,s2,-886 # 10a0 <malloc+0x228>
 41e:	4581                	li	a1,0
 420:	854a                	mv	a0,s2
 422:	00001097          	auipc	ra,0x1
 426:	998080e7          	jalr	-1640(ra) # dba <printf>
        for (int i = 0; i < 100;i++)
 42a:	34fd                	addiw	s1,s1,-1
 42c:	f8ed                	bnez	s1,41e <cfsdTest1+0xde>
        exit(0);
 42e:	4501                	li	a0,0
 430:	00000097          	auipc	ra,0x0
 434:	5fa080e7          	jalr	1530(ra) # a2a <exit>

0000000000000438 <cfsdTest2>:

int cfsdTest2(){
 438:	7139                	addi	sp,sp,-64
 43a:	fc06                	sd	ra,56(sp)
 43c:	f822                	sd	s0,48(sp)
 43e:	f426                	sd	s1,40(sp)
 440:	f04a                	sd	s2,32(sp)
 442:	0080                	addi	s0,sp,64
    
    sleep(10);
 444:	4529                	li	a0,10
 446:	00000097          	auipc	ra,0x0
 44a:	674080e7          	jalr	1652(ra) # aba <sleep>

    // create son
    int pid = fork();
 44e:	00000097          	auipc	ra,0x0
 452:	5d4080e7          	jalr	1492(ra) # a22 <fork>
    // int mask2 = (1 << SYS_priority);
    // trace(mask1, father);
    // trace(mask2, pid);

    // son
    if(pid == 0){
 456:	06400493          	li	s1,100
        exit(0);
    }
    // father
    else{
        for (int i = 0; i < 100; i++)
            printf("father before son!\n");
 45a:	00001917          	auipc	s2,0x1
 45e:	c0e90913          	addi	s2,s2,-1010 # 1068 <malloc+0x1f0>
    if(pid == 0){
 462:	c95d                	beqz	a0,518 <cfsdTest2+0xe0>
            printf("father before son!\n");
 464:	854a                	mv	a0,s2
 466:	00001097          	auipc	ra,0x1
 46a:	954080e7          	jalr	-1708(ra) # dba <printf>
        for (int i = 0; i < 100; i++)
 46e:	34fd                	addiw	s1,s1,-1
 470:	f8f5                	bnez	s1,464 <cfsdTest2+0x2c>
    }

    struct perf p;

    int x = wait_stat(0, &p);
 472:	fc840593          	addi	a1,s0,-56
 476:	4501                	li	a0,0
 478:	00000097          	auipc	ra,0x0
 47c:	65a080e7          	jalr	1626(ra) # ad2 <wait_stat>
 480:	85aa                	mv	a1,a0
    printf("ret val: %d ", x);
 482:	00001517          	auipc	a0,0x1
 486:	afe50513          	addi	a0,a0,-1282 # f80 <malloc+0x108>
 48a:	00001097          	auipc	ra,0x1
 48e:	930080e7          	jalr	-1744(ra) # dba <printf>
    printf("ctime: %d ", p.ctime);
 492:	fc842583          	lw	a1,-56(s0)
 496:	00001517          	auipc	a0,0x1
 49a:	afa50513          	addi	a0,a0,-1286 # f90 <malloc+0x118>
 49e:	00001097          	auipc	ra,0x1
 4a2:	91c080e7          	jalr	-1764(ra) # dba <printf>
    printf("ttime: %d ", p.ttime);
 4a6:	fcc42583          	lw	a1,-52(s0)
 4aa:	00001517          	auipc	a0,0x1
 4ae:	af650513          	addi	a0,a0,-1290 # fa0 <malloc+0x128>
 4b2:	00001097          	auipc	ra,0x1
 4b6:	908080e7          	jalr	-1784(ra) # dba <printf>
    printf("stime: %d ", p.stime);
 4ba:	fd042583          	lw	a1,-48(s0)
 4be:	00001517          	auipc	a0,0x1
 4c2:	af250513          	addi	a0,a0,-1294 # fb0 <malloc+0x138>
 4c6:	00001097          	auipc	ra,0x1
 4ca:	8f4080e7          	jalr	-1804(ra) # dba <printf>
    printf("retime: %d ", p.retime);
 4ce:	fd442583          	lw	a1,-44(s0)
 4d2:	00001517          	auipc	a0,0x1
 4d6:	aee50513          	addi	a0,a0,-1298 # fc0 <malloc+0x148>
 4da:	00001097          	auipc	ra,0x1
 4de:	8e0080e7          	jalr	-1824(ra) # dba <printf>
    printf("rutime: %d\n", p.rutime);
 4e2:	fd842583          	lw	a1,-40(s0)
 4e6:	00001517          	auipc	a0,0x1
 4ea:	baa50513          	addi	a0,a0,-1110 # 1090 <malloc+0x218>
 4ee:	00001097          	auipc	ra,0x1
 4f2:	8cc080e7          	jalr	-1844(ra) # dba <printf>
    printf("bursttime: %d\n", p.average_bursttime);
 4f6:	fdc42583          	lw	a1,-36(s0)
 4fa:	00001517          	auipc	a0,0x1
 4fe:	ae650513          	addi	a0,a0,-1306 # fe0 <malloc+0x168>
 502:	00001097          	auipc	ra,0x1
 506:	8b8080e7          	jalr	-1864(ra) # dba <printf>

    return 0;
}
 50a:	4501                	li	a0,0
 50c:	70e2                	ld	ra,56(sp)
 50e:	7442                	ld	s0,48(sp)
 510:	74a2                	ld	s1,40(sp)
 512:	7902                	ld	s2,32(sp)
 514:	6121                	addi	sp,sp,64
 516:	8082                	ret
        set_priority(1);
 518:	4505                	li	a0,1
 51a:	00000097          	auipc	ra,0x0
 51e:	5c0080e7          	jalr	1472(ra) # ada <set_priority>
            printf("pid: %d ,not here! my turn now\n", pid);
 522:	00001917          	auipc	s2,0x1
 526:	b7e90913          	addi	s2,s2,-1154 # 10a0 <malloc+0x228>
 52a:	4581                	li	a1,0
 52c:	854a                	mv	a0,s2
 52e:	00001097          	auipc	ra,0x1
 532:	88c080e7          	jalr	-1908(ra) # dba <printf>
        for (int i = 0; i < 100;i++)
 536:	34fd                	addiw	s1,s1,-1
 538:	f8ed                	bnez	s1,52a <cfsdTest2+0xf2>
        exit(0);
 53a:	4501                	li	a0,0
 53c:	00000097          	auipc	ra,0x0
 540:	4ee080e7          	jalr	1262(ra) # a2a <exit>

0000000000000544 <srtTest>:

// ############################### TASK 4 Test #############################

int srtTest()
{
 544:	7179                	addi	sp,sp,-48
 546:	f406                	sd	ra,40(sp)
 548:	f022                	sd	s0,32(sp)
 54a:	ec26                	sd	s1,24(sp)
 54c:	e84a                	sd	s2,16(sp)
 54e:	e44e                	sd	s3,8(sp)
 550:	e052                	sd	s4,0(sp)
 552:	1800                	addi	s0,sp,48
    // int mask2 = (1 << SYS_priority);
    // trace(mask1, father);
    // trace(mask2, pid);

    // son
    if ((pid = fork() == 0))
 554:	00000097          	auipc	ra,0x0
 558:	4ce080e7          	jalr	1230(ra) # a22 <fork>
 55c:	e91d                	bnez	a0,592 <srtTest+0x4e>
 55e:	84aa                	mv	s1,a0
    {
        for (int i = 0; i < 100; i++)
        {
            if (i%5 == 0)
 560:	4a15                	li	s4,5
            {
                sleep(5);
            }
            printf("son is running\n");
 562:	00001997          	auipc	s3,0x1
 566:	b5e98993          	addi	s3,s3,-1186 # 10c0 <malloc+0x248>
        for (int i = 0; i < 100; i++)
 56a:	06400913          	li	s2,100
 56e:	a809                	j	580 <srtTest+0x3c>
            printf("son is running\n");
 570:	854e                	mv	a0,s3
 572:	00001097          	auipc	ra,0x1
 576:	848080e7          	jalr	-1976(ra) # dba <printf>
        for (int i = 0; i < 100; i++)
 57a:	2485                	addiw	s1,s1,1
 57c:	03248d63          	beq	s1,s2,5b6 <srtTest+0x72>
            if (i%5 == 0)
 580:	0344e7bb          	remw	a5,s1,s4
 584:	f7f5                	bnez	a5,570 <srtTest+0x2c>
                sleep(5);
 586:	4515                	li	a0,5
 588:	00000097          	auipc	ra,0x0
 58c:	532080e7          	jalr	1330(ra) # aba <sleep>
 590:	b7c5                	j	570 <srtTest+0x2c>
        }
        
    }
    else
    {
        sleep(5);
 592:	4515                	li	a0,5
 594:	00000097          	auipc	ra,0x0
 598:	526080e7          	jalr	1318(ra) # aba <sleep>
 59c:	0fa00493          	li	s1,250
        for (int i = 0; i < 250; i++)
        {
            printf("father is running\n");
 5a0:	00001917          	auipc	s2,0x1
 5a4:	b3090913          	addi	s2,s2,-1232 # 10d0 <malloc+0x258>
 5a8:	854a                	mv	a0,s2
 5aa:	00001097          	auipc	ra,0x1
 5ae:	810080e7          	jalr	-2032(ra) # dba <printf>
        for (int i = 0; i < 250; i++)
 5b2:	34fd                	addiw	s1,s1,-1
 5b4:	f8f5                	bnez	s1,5a8 <srtTest+0x64>
        }
    }
    
    
    return 0;
}
 5b6:	4501                	li	a0,0
 5b8:	70a2                	ld	ra,40(sp)
 5ba:	7402                	ld	s0,32(sp)
 5bc:	64e2                	ld	s1,24(sp)
 5be:	6942                	ld	s2,16(sp)
 5c0:	69a2                	ld	s3,8(sp)
 5c2:	6a02                	ld	s4,0(sp)
 5c4:	6145                	addi	sp,sp,48
 5c6:	8082                	ret

00000000000005c8 <fcfsTest2>:

// #################################### runner ##########################

int fcfsTest2()
{
 5c8:	715d                	addi	sp,sp,-80
 5ca:	e486                	sd	ra,72(sp)
 5cc:	e0a2                	sd	s0,64(sp)
 5ce:	fc26                	sd	s1,56(sp)
 5d0:	f84a                	sd	s2,48(sp)
 5d2:	f44e                	sd	s3,40(sp)
 5d4:	0880                	addi	s0,sp,80

    sleep(1);
 5d6:	4505                	li	a0,1
 5d8:	00000097          	auipc	ra,0x0
 5dc:	4e2080e7          	jalr	1250(ra) # aba <sleep>

    // create son
    int pid = fork();
 5e0:	00000097          	auipc	ra,0x0
 5e4:	442080e7          	jalr	1090(ra) # a22 <fork>
    // int mask2 = (1 << SYS_priority);
    // trace(mask1, father);
    // trace(mask2, pid);

    // son
    if (pid == 0)
 5e8:	e555                	bnez	a0,694 <fcfsTest2+0xcc>
 5ea:	44a9                	li	s1,10
    {   
        for(int i = 0; i < 10; i++)
            printf("son need to wait a little bit 2\n");
 5ec:	00001917          	auipc	s2,0x1
 5f0:	afc90913          	addi	s2,s2,-1284 # 10e8 <malloc+0x270>
 5f4:	854a                	mv	a0,s2
 5f6:	00000097          	auipc	ra,0x0
 5fa:	7c4080e7          	jalr	1988(ra) # dba <printf>
        for(int i = 0; i < 10; i++)
 5fe:	34fd                	addiw	s1,s1,-1
 600:	f8f5                	bnez	s1,5f4 <fcfsTest2+0x2c>
        int son2 = fork();
 602:	00000097          	auipc	ra,0x0
 606:	420080e7          	jalr	1056(ra) # a22 <fork>
 60a:	89aa                	mv	s3,a0
 60c:	44a9                	li	s1,10
        for(int i = 0; i < 10; i++)
            printf("son need to wait a little bit 3\n");
 60e:	00001917          	auipc	s2,0x1
 612:	b0290913          	addi	s2,s2,-1278 # 1110 <malloc+0x298>
 616:	854a                	mv	a0,s2
 618:	00000097          	auipc	ra,0x0
 61c:	7a2080e7          	jalr	1954(ra) # dba <printf>
        for(int i = 0; i < 10; i++)
 620:	34fd                	addiw	s1,s1,-1
 622:	f8f5                	bnez	s1,616 <fcfsTest2+0x4e>
        sleep(1);
 624:	4505                	li	a0,1
 626:	00000097          	auipc	ra,0x0
 62a:	494080e7          	jalr	1172(ra) # aba <sleep>
        if(son2 != 0){
 62e:	04098263          	beqz	s3,672 <fcfsTest2+0xaa>
 632:	06400493          	li	s1,100
            for (int i = 0; i < 100; i++)
                printf("pid: %d ,my turn now\n", pid);
 636:	00001917          	auipc	s2,0x1
 63a:	a0290913          	addi	s2,s2,-1534 # 1038 <malloc+0x1c0>
 63e:	4581                	li	a1,0
 640:	854a                	mv	a0,s2
 642:	00000097          	auipc	ra,0x0
 646:	778080e7          	jalr	1912(ra) # dba <printf>
            for (int i = 0; i < 100; i++)
 64a:	34fd                	addiw	s1,s1,-1
 64c:	f8ed                	bnez	s1,63e <fcfsTest2+0x76>
            sleep(1);
 64e:	4505                	li	a0,1
 650:	00000097          	auipc	ra,0x0
 654:	46a080e7          	jalr	1130(ra) # aba <sleep>
            printf("I'am alsoooo back!!!\n");
 658:	00001517          	auipc	a0,0x1
 65c:	9f850513          	addi	a0,a0,-1544 # 1050 <malloc+0x1d8>
 660:	00000097          	auipc	ra,0x0
 664:	75a080e7          	jalr	1882(ra) # dba <printf>
            exit(0);
 668:	4501                	li	a0,0
 66a:	00000097          	auipc	ra,0x0
 66e:	3c0080e7          	jalr	960(ra) # a2a <exit>
 672:	44d1                	li	s1,20

        }
        for(int i = 0 ; i < 20 ; i++)
            printf("grandson is palying!\n");
 674:	00001917          	auipc	s2,0x1
 678:	ac490913          	addi	s2,s2,-1340 # 1138 <malloc+0x2c0>
 67c:	854a                	mv	a0,s2
 67e:	00000097          	auipc	ra,0x0
 682:	73c080e7          	jalr	1852(ra) # dba <printf>
        for(int i = 0 ; i < 20 ; i++)
 686:	34fd                	addiw	s1,s1,-1
 688:	f8f5                	bnez	s1,67c <fcfsTest2+0xb4>
        exit(0);
 68a:	4501                	li	a0,0
 68c:	00000097          	auipc	ra,0x0
 690:	39e080e7          	jalr	926(ra) # a2a <exit>
    }
    // father
    else
    {
        sleep(1);
 694:	4505                	li	a0,1
 696:	00000097          	auipc	ra,0x0
 69a:	424080e7          	jalr	1060(ra) # aba <sleep>
 69e:	06400493          	li	s1,100
        for (int i = 0; i < 100; i++)
            printf("father before son! \n");
 6a2:	00001917          	auipc	s2,0x1
 6a6:	aae90913          	addi	s2,s2,-1362 # 1150 <malloc+0x2d8>
 6aa:	854a                	mv	a0,s2
 6ac:	00000097          	auipc	ra,0x0
 6b0:	70e080e7          	jalr	1806(ra) # dba <printf>
        for (int i = 0; i < 100; i++)
 6b4:	34fd                	addiw	s1,s1,-1
 6b6:	f8f5                	bnez	s1,6aa <fcfsTest2+0xe2>
        sleep(1); // go to the back of the line
 6b8:	4505                	li	a0,1
 6ba:	00000097          	auipc	ra,0x0
 6be:	400080e7          	jalr	1024(ra) # aba <sleep>
        printf("I'am back!!!\n");
 6c2:	00001517          	auipc	a0,0x1
 6c6:	9be50513          	addi	a0,a0,-1602 # 1080 <malloc+0x208>
 6ca:	00000097          	auipc	ra,0x0
 6ce:	6f0080e7          	jalr	1776(ra) # dba <printf>
    }

    struct perf p;

    int x = wait_stat(0,&p);
 6d2:	fb840593          	addi	a1,s0,-72
 6d6:	4501                	li	a0,0
 6d8:	00000097          	auipc	ra,0x0
 6dc:	3fa080e7          	jalr	1018(ra) # ad2 <wait_stat>
 6e0:	85aa                	mv	a1,a0
    printf("ret val: %d ", x);
 6e2:	00001517          	auipc	a0,0x1
 6e6:	89e50513          	addi	a0,a0,-1890 # f80 <malloc+0x108>
 6ea:	00000097          	auipc	ra,0x0
 6ee:	6d0080e7          	jalr	1744(ra) # dba <printf>
    printf("ctime: %d ", p.ctime);
 6f2:	fb842583          	lw	a1,-72(s0)
 6f6:	00001517          	auipc	a0,0x1
 6fa:	89a50513          	addi	a0,a0,-1894 # f90 <malloc+0x118>
 6fe:	00000097          	auipc	ra,0x0
 702:	6bc080e7          	jalr	1724(ra) # dba <printf>
    printf("ttime: %d ", p.ttime);
 706:	fbc42583          	lw	a1,-68(s0)
 70a:	00001517          	auipc	a0,0x1
 70e:	89650513          	addi	a0,a0,-1898 # fa0 <malloc+0x128>
 712:	00000097          	auipc	ra,0x0
 716:	6a8080e7          	jalr	1704(ra) # dba <printf>
    printf("stime: %d ", p.stime);
 71a:	fc042583          	lw	a1,-64(s0)
 71e:	00001517          	auipc	a0,0x1
 722:	89250513          	addi	a0,a0,-1902 # fb0 <malloc+0x138>
 726:	00000097          	auipc	ra,0x0
 72a:	694080e7          	jalr	1684(ra) # dba <printf>
    printf("retime: %d ", p.retime);
 72e:	fc442583          	lw	a1,-60(s0)
 732:	00001517          	auipc	a0,0x1
 736:	88e50513          	addi	a0,a0,-1906 # fc0 <malloc+0x148>
 73a:	00000097          	auipc	ra,0x0
 73e:	680080e7          	jalr	1664(ra) # dba <printf>
    printf("rutime: %d\n", p.rutime);
 742:	fc842583          	lw	a1,-56(s0)
 746:	00001517          	auipc	a0,0x1
 74a:	94a50513          	addi	a0,a0,-1718 # 1090 <malloc+0x218>
 74e:	00000097          	auipc	ra,0x0
 752:	66c080e7          	jalr	1644(ra) # dba <printf>

    return 0;
}
 756:	4501                	li	a0,0
 758:	60a6                	ld	ra,72(sp)
 75a:	6406                	ld	s0,64(sp)
 75c:	74e2                	ld	s1,56(sp)
 75e:	7942                	ld	s2,48(sp)
 760:	79a2                	ld	s3,40(sp)
 762:	6161                	addi	sp,sp,80
 764:	8082                	ret

0000000000000766 <main>:

int main(void)
{
 766:	1141                	addi	sp,sp,-16
 768:	e406                	sd	ra,8(sp)
 76a:	e022                	sd	s0,0(sp)
 76c:	0800                	addi	s0,sp,16

    int res = test();
 76e:	00000097          	auipc	ra,0x0
 772:	892080e7          	jalr	-1902(ra) # 0 <test>
 776:	85aa                	mv	a1,a0
    printf("test1 res: %d\n", res);
 778:	00001517          	auipc	a0,0x1
 77c:	9f050513          	addi	a0,a0,-1552 # 1168 <malloc+0x2f0>
 780:	00000097          	auipc	ra,0x0
 784:	63a080e7          	jalr	1594(ra) # dba <printf>

     printf("\n############################### TASK 4 Test #############################\n\n");
 788:	00001517          	auipc	a0,0x1
 78c:	9f050513          	addi	a0,a0,-1552 # 1178 <malloc+0x300>
 790:	00000097          	auipc	ra,0x0
 794:	62a080e7          	jalr	1578(ra) # dba <printf>
     int res1 = priorityTest();
 798:	00000097          	auipc	ra,0x0
 79c:	9f4080e7          	jalr	-1548(ra) # 18c <priorityTest>
 7a0:	85aa                	mv	a1,a0
     printf("test2 res: %d\n\n\n", res1);
 7a2:	00001517          	auipc	a0,0x1
 7a6:	a2650513          	addi	a0,a0,-1498 # 11c8 <malloc+0x350>
 7aa:	00000097          	auipc	ra,0x0
 7ae:	610080e7          	jalr	1552(ra) # dba <printf>
    // printf("fcfs test res: %d\n\n\n", res5);

    // int res3 = srtTest();
    // printf("srtTest res: %d\n", res3);

    exit(0);
 7b2:	4501                	li	a0,0
 7b4:	00000097          	auipc	ra,0x0
 7b8:	276080e7          	jalr	630(ra) # a2a <exit>

00000000000007bc <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 7bc:	1141                	addi	sp,sp,-16
 7be:	e422                	sd	s0,8(sp)
 7c0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 7c2:	87aa                	mv	a5,a0
 7c4:	0585                	addi	a1,a1,1
 7c6:	0785                	addi	a5,a5,1
 7c8:	fff5c703          	lbu	a4,-1(a1)
 7cc:	fee78fa3          	sb	a4,-1(a5)
 7d0:	fb75                	bnez	a4,7c4 <strcpy+0x8>
    ;
  return os;
}
 7d2:	6422                	ld	s0,8(sp)
 7d4:	0141                	addi	sp,sp,16
 7d6:	8082                	ret

00000000000007d8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 7d8:	1141                	addi	sp,sp,-16
 7da:	e422                	sd	s0,8(sp)
 7dc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 7de:	00054783          	lbu	a5,0(a0)
 7e2:	cb91                	beqz	a5,7f6 <strcmp+0x1e>
 7e4:	0005c703          	lbu	a4,0(a1)
 7e8:	00f71763          	bne	a4,a5,7f6 <strcmp+0x1e>
    p++, q++;
 7ec:	0505                	addi	a0,a0,1
 7ee:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 7f0:	00054783          	lbu	a5,0(a0)
 7f4:	fbe5                	bnez	a5,7e4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 7f6:	0005c503          	lbu	a0,0(a1)
}
 7fa:	40a7853b          	subw	a0,a5,a0
 7fe:	6422                	ld	s0,8(sp)
 800:	0141                	addi	sp,sp,16
 802:	8082                	ret

0000000000000804 <strlen>:

uint
strlen(const char *s)
{
 804:	1141                	addi	sp,sp,-16
 806:	e422                	sd	s0,8(sp)
 808:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 80a:	00054783          	lbu	a5,0(a0)
 80e:	cf91                	beqz	a5,82a <strlen+0x26>
 810:	0505                	addi	a0,a0,1
 812:	87aa                	mv	a5,a0
 814:	4685                	li	a3,1
 816:	9e89                	subw	a3,a3,a0
 818:	00f6853b          	addw	a0,a3,a5
 81c:	0785                	addi	a5,a5,1
 81e:	fff7c703          	lbu	a4,-1(a5)
 822:	fb7d                	bnez	a4,818 <strlen+0x14>
    ;
  return n;
}
 824:	6422                	ld	s0,8(sp)
 826:	0141                	addi	sp,sp,16
 828:	8082                	ret
  for(n = 0; s[n]; n++)
 82a:	4501                	li	a0,0
 82c:	bfe5                	j	824 <strlen+0x20>

000000000000082e <memset>:

void*
memset(void *dst, int c, uint n)
{
 82e:	1141                	addi	sp,sp,-16
 830:	e422                	sd	s0,8(sp)
 832:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 834:	ca19                	beqz	a2,84a <memset+0x1c>
 836:	87aa                	mv	a5,a0
 838:	1602                	slli	a2,a2,0x20
 83a:	9201                	srli	a2,a2,0x20
 83c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 840:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 844:	0785                	addi	a5,a5,1
 846:	fee79de3          	bne	a5,a4,840 <memset+0x12>
  }
  return dst;
}
 84a:	6422                	ld	s0,8(sp)
 84c:	0141                	addi	sp,sp,16
 84e:	8082                	ret

0000000000000850 <strchr>:

char*
strchr(const char *s, char c)
{
 850:	1141                	addi	sp,sp,-16
 852:	e422                	sd	s0,8(sp)
 854:	0800                	addi	s0,sp,16
  for(; *s; s++)
 856:	00054783          	lbu	a5,0(a0)
 85a:	cb99                	beqz	a5,870 <strchr+0x20>
    if(*s == c)
 85c:	00f58763          	beq	a1,a5,86a <strchr+0x1a>
  for(; *s; s++)
 860:	0505                	addi	a0,a0,1
 862:	00054783          	lbu	a5,0(a0)
 866:	fbfd                	bnez	a5,85c <strchr+0xc>
      return (char*)s;
  return 0;
 868:	4501                	li	a0,0
}
 86a:	6422                	ld	s0,8(sp)
 86c:	0141                	addi	sp,sp,16
 86e:	8082                	ret
  return 0;
 870:	4501                	li	a0,0
 872:	bfe5                	j	86a <strchr+0x1a>

0000000000000874 <gets>:

char*
gets(char *buf, int max)
{
 874:	711d                	addi	sp,sp,-96
 876:	ec86                	sd	ra,88(sp)
 878:	e8a2                	sd	s0,80(sp)
 87a:	e4a6                	sd	s1,72(sp)
 87c:	e0ca                	sd	s2,64(sp)
 87e:	fc4e                	sd	s3,56(sp)
 880:	f852                	sd	s4,48(sp)
 882:	f456                	sd	s5,40(sp)
 884:	f05a                	sd	s6,32(sp)
 886:	ec5e                	sd	s7,24(sp)
 888:	1080                	addi	s0,sp,96
 88a:	8baa                	mv	s7,a0
 88c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 88e:	892a                	mv	s2,a0
 890:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 892:	4aa9                	li	s5,10
 894:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 896:	89a6                	mv	s3,s1
 898:	2485                	addiw	s1,s1,1
 89a:	0344d863          	bge	s1,s4,8ca <gets+0x56>
    cc = read(0, &c, 1);
 89e:	4605                	li	a2,1
 8a0:	faf40593          	addi	a1,s0,-81
 8a4:	4501                	li	a0,0
 8a6:	00000097          	auipc	ra,0x0
 8aa:	19c080e7          	jalr	412(ra) # a42 <read>
    if(cc < 1)
 8ae:	00a05e63          	blez	a0,8ca <gets+0x56>
    buf[i++] = c;
 8b2:	faf44783          	lbu	a5,-81(s0)
 8b6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 8ba:	01578763          	beq	a5,s5,8c8 <gets+0x54>
 8be:	0905                	addi	s2,s2,1
 8c0:	fd679be3          	bne	a5,s6,896 <gets+0x22>
  for(i=0; i+1 < max; ){
 8c4:	89a6                	mv	s3,s1
 8c6:	a011                	j	8ca <gets+0x56>
 8c8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 8ca:	99de                	add	s3,s3,s7
 8cc:	00098023          	sb	zero,0(s3)
  return buf;
}
 8d0:	855e                	mv	a0,s7
 8d2:	60e6                	ld	ra,88(sp)
 8d4:	6446                	ld	s0,80(sp)
 8d6:	64a6                	ld	s1,72(sp)
 8d8:	6906                	ld	s2,64(sp)
 8da:	79e2                	ld	s3,56(sp)
 8dc:	7a42                	ld	s4,48(sp)
 8de:	7aa2                	ld	s5,40(sp)
 8e0:	7b02                	ld	s6,32(sp)
 8e2:	6be2                	ld	s7,24(sp)
 8e4:	6125                	addi	sp,sp,96
 8e6:	8082                	ret

00000000000008e8 <stat>:

int
stat(const char *n, struct stat *st)
{
 8e8:	1101                	addi	sp,sp,-32
 8ea:	ec06                	sd	ra,24(sp)
 8ec:	e822                	sd	s0,16(sp)
 8ee:	e426                	sd	s1,8(sp)
 8f0:	e04a                	sd	s2,0(sp)
 8f2:	1000                	addi	s0,sp,32
 8f4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 8f6:	4581                	li	a1,0
 8f8:	00000097          	auipc	ra,0x0
 8fc:	172080e7          	jalr	370(ra) # a6a <open>
  if(fd < 0)
 900:	02054563          	bltz	a0,92a <stat+0x42>
 904:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 906:	85ca                	mv	a1,s2
 908:	00000097          	auipc	ra,0x0
 90c:	17a080e7          	jalr	378(ra) # a82 <fstat>
 910:	892a                	mv	s2,a0
  close(fd);
 912:	8526                	mv	a0,s1
 914:	00000097          	auipc	ra,0x0
 918:	13e080e7          	jalr	318(ra) # a52 <close>
  return r;
}
 91c:	854a                	mv	a0,s2
 91e:	60e2                	ld	ra,24(sp)
 920:	6442                	ld	s0,16(sp)
 922:	64a2                	ld	s1,8(sp)
 924:	6902                	ld	s2,0(sp)
 926:	6105                	addi	sp,sp,32
 928:	8082                	ret
    return -1;
 92a:	597d                	li	s2,-1
 92c:	bfc5                	j	91c <stat+0x34>

000000000000092e <atoi>:

int
atoi(const char *s)
{
 92e:	1141                	addi	sp,sp,-16
 930:	e422                	sd	s0,8(sp)
 932:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 934:	00054603          	lbu	a2,0(a0)
 938:	fd06079b          	addiw	a5,a2,-48
 93c:	0ff7f793          	andi	a5,a5,255
 940:	4725                	li	a4,9
 942:	02f76963          	bltu	a4,a5,974 <atoi+0x46>
 946:	86aa                	mv	a3,a0
  n = 0;
 948:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 94a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 94c:	0685                	addi	a3,a3,1
 94e:	0025179b          	slliw	a5,a0,0x2
 952:	9fa9                	addw	a5,a5,a0
 954:	0017979b          	slliw	a5,a5,0x1
 958:	9fb1                	addw	a5,a5,a2
 95a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 95e:	0006c603          	lbu	a2,0(a3)
 962:	fd06071b          	addiw	a4,a2,-48
 966:	0ff77713          	andi	a4,a4,255
 96a:	fee5f1e3          	bgeu	a1,a4,94c <atoi+0x1e>
  return n;
}
 96e:	6422                	ld	s0,8(sp)
 970:	0141                	addi	sp,sp,16
 972:	8082                	ret
  n = 0;
 974:	4501                	li	a0,0
 976:	bfe5                	j	96e <atoi+0x40>

0000000000000978 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 978:	1141                	addi	sp,sp,-16
 97a:	e422                	sd	s0,8(sp)
 97c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 97e:	02b57463          	bgeu	a0,a1,9a6 <memmove+0x2e>
    while(n-- > 0)
 982:	00c05f63          	blez	a2,9a0 <memmove+0x28>
 986:	1602                	slli	a2,a2,0x20
 988:	9201                	srli	a2,a2,0x20
 98a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 98e:	872a                	mv	a4,a0
      *dst++ = *src++;
 990:	0585                	addi	a1,a1,1
 992:	0705                	addi	a4,a4,1
 994:	fff5c683          	lbu	a3,-1(a1)
 998:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 99c:	fee79ae3          	bne	a5,a4,990 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 9a0:	6422                	ld	s0,8(sp)
 9a2:	0141                	addi	sp,sp,16
 9a4:	8082                	ret
    dst += n;
 9a6:	00c50733          	add	a4,a0,a2
    src += n;
 9aa:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 9ac:	fec05ae3          	blez	a2,9a0 <memmove+0x28>
 9b0:	fff6079b          	addiw	a5,a2,-1
 9b4:	1782                	slli	a5,a5,0x20
 9b6:	9381                	srli	a5,a5,0x20
 9b8:	fff7c793          	not	a5,a5
 9bc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 9be:	15fd                	addi	a1,a1,-1
 9c0:	177d                	addi	a4,a4,-1
 9c2:	0005c683          	lbu	a3,0(a1)
 9c6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 9ca:	fee79ae3          	bne	a5,a4,9be <memmove+0x46>
 9ce:	bfc9                	j	9a0 <memmove+0x28>

00000000000009d0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 9d0:	1141                	addi	sp,sp,-16
 9d2:	e422                	sd	s0,8(sp)
 9d4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 9d6:	ca05                	beqz	a2,a06 <memcmp+0x36>
 9d8:	fff6069b          	addiw	a3,a2,-1
 9dc:	1682                	slli	a3,a3,0x20
 9de:	9281                	srli	a3,a3,0x20
 9e0:	0685                	addi	a3,a3,1
 9e2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 9e4:	00054783          	lbu	a5,0(a0)
 9e8:	0005c703          	lbu	a4,0(a1)
 9ec:	00e79863          	bne	a5,a4,9fc <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 9f0:	0505                	addi	a0,a0,1
    p2++;
 9f2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 9f4:	fed518e3          	bne	a0,a3,9e4 <memcmp+0x14>
  }
  return 0;
 9f8:	4501                	li	a0,0
 9fa:	a019                	j	a00 <memcmp+0x30>
      return *p1 - *p2;
 9fc:	40e7853b          	subw	a0,a5,a4
}
 a00:	6422                	ld	s0,8(sp)
 a02:	0141                	addi	sp,sp,16
 a04:	8082                	ret
  return 0;
 a06:	4501                	li	a0,0
 a08:	bfe5                	j	a00 <memcmp+0x30>

0000000000000a0a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 a0a:	1141                	addi	sp,sp,-16
 a0c:	e406                	sd	ra,8(sp)
 a0e:	e022                	sd	s0,0(sp)
 a10:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 a12:	00000097          	auipc	ra,0x0
 a16:	f66080e7          	jalr	-154(ra) # 978 <memmove>
}
 a1a:	60a2                	ld	ra,8(sp)
 a1c:	6402                	ld	s0,0(sp)
 a1e:	0141                	addi	sp,sp,16
 a20:	8082                	ret

0000000000000a22 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 a22:	4885                	li	a7,1
 ecall
 a24:	00000073          	ecall
 ret
 a28:	8082                	ret

0000000000000a2a <exit>:
.global exit
exit:
 li a7, SYS_exit
 a2a:	4889                	li	a7,2
 ecall
 a2c:	00000073          	ecall
 ret
 a30:	8082                	ret

0000000000000a32 <wait>:
.global wait
wait:
 li a7, SYS_wait
 a32:	488d                	li	a7,3
 ecall
 a34:	00000073          	ecall
 ret
 a38:	8082                	ret

0000000000000a3a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 a3a:	4891                	li	a7,4
 ecall
 a3c:	00000073          	ecall
 ret
 a40:	8082                	ret

0000000000000a42 <read>:
.global read
read:
 li a7, SYS_read
 a42:	4895                	li	a7,5
 ecall
 a44:	00000073          	ecall
 ret
 a48:	8082                	ret

0000000000000a4a <write>:
.global write
write:
 li a7, SYS_write
 a4a:	48c1                	li	a7,16
 ecall
 a4c:	00000073          	ecall
 ret
 a50:	8082                	ret

0000000000000a52 <close>:
.global close
close:
 li a7, SYS_close
 a52:	48d5                	li	a7,21
 ecall
 a54:	00000073          	ecall
 ret
 a58:	8082                	ret

0000000000000a5a <kill>:
.global kill
kill:
 li a7, SYS_kill
 a5a:	4899                	li	a7,6
 ecall
 a5c:	00000073          	ecall
 ret
 a60:	8082                	ret

0000000000000a62 <exec>:
.global exec
exec:
 li a7, SYS_exec
 a62:	489d                	li	a7,7
 ecall
 a64:	00000073          	ecall
 ret
 a68:	8082                	ret

0000000000000a6a <open>:
.global open
open:
 li a7, SYS_open
 a6a:	48bd                	li	a7,15
 ecall
 a6c:	00000073          	ecall
 ret
 a70:	8082                	ret

0000000000000a72 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 a72:	48c5                	li	a7,17
 ecall
 a74:	00000073          	ecall
 ret
 a78:	8082                	ret

0000000000000a7a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 a7a:	48c9                	li	a7,18
 ecall
 a7c:	00000073          	ecall
 ret
 a80:	8082                	ret

0000000000000a82 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 a82:	48a1                	li	a7,8
 ecall
 a84:	00000073          	ecall
 ret
 a88:	8082                	ret

0000000000000a8a <link>:
.global link
link:
 li a7, SYS_link
 a8a:	48cd                	li	a7,19
 ecall
 a8c:	00000073          	ecall
 ret
 a90:	8082                	ret

0000000000000a92 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 a92:	48d1                	li	a7,20
 ecall
 a94:	00000073          	ecall
 ret
 a98:	8082                	ret

0000000000000a9a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 a9a:	48a5                	li	a7,9
 ecall
 a9c:	00000073          	ecall
 ret
 aa0:	8082                	ret

0000000000000aa2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 aa2:	48a9                	li	a7,10
 ecall
 aa4:	00000073          	ecall
 ret
 aa8:	8082                	ret

0000000000000aaa <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 aaa:	48ad                	li	a7,11
 ecall
 aac:	00000073          	ecall
 ret
 ab0:	8082                	ret

0000000000000ab2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 ab2:	48b1                	li	a7,12
 ecall
 ab4:	00000073          	ecall
 ret
 ab8:	8082                	ret

0000000000000aba <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 aba:	48b5                	li	a7,13
 ecall
 abc:	00000073          	ecall
 ret
 ac0:	8082                	ret

0000000000000ac2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 ac2:	48b9                	li	a7,14
 ecall
 ac4:	00000073          	ecall
 ret
 ac8:	8082                	ret

0000000000000aca <trace>:
.global trace
trace:
 li a7, SYS_trace
 aca:	48d9                	li	a7,22
 ecall
 acc:	00000073          	ecall
 ret
 ad0:	8082                	ret

0000000000000ad2 <wait_stat>:
.global wait_stat
wait_stat:
 li a7, SYS_wait_stat
 ad2:	48dd                	li	a7,23
 ecall
 ad4:	00000073          	ecall
 ret
 ad8:	8082                	ret

0000000000000ada <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
 ada:	48e1                	li	a7,24
 ecall
 adc:	00000073          	ecall
 ret
 ae0:	8082                	ret

0000000000000ae2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 ae2:	1101                	addi	sp,sp,-32
 ae4:	ec06                	sd	ra,24(sp)
 ae6:	e822                	sd	s0,16(sp)
 ae8:	1000                	addi	s0,sp,32
 aea:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 aee:	4605                	li	a2,1
 af0:	fef40593          	addi	a1,s0,-17
 af4:	00000097          	auipc	ra,0x0
 af8:	f56080e7          	jalr	-170(ra) # a4a <write>
}
 afc:	60e2                	ld	ra,24(sp)
 afe:	6442                	ld	s0,16(sp)
 b00:	6105                	addi	sp,sp,32
 b02:	8082                	ret

0000000000000b04 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 b04:	7139                	addi	sp,sp,-64
 b06:	fc06                	sd	ra,56(sp)
 b08:	f822                	sd	s0,48(sp)
 b0a:	f426                	sd	s1,40(sp)
 b0c:	f04a                	sd	s2,32(sp)
 b0e:	ec4e                	sd	s3,24(sp)
 b10:	0080                	addi	s0,sp,64
 b12:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 b14:	c299                	beqz	a3,b1a <printint+0x16>
 b16:	0805c863          	bltz	a1,ba6 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 b1a:	2581                	sext.w	a1,a1
  neg = 0;
 b1c:	4881                	li	a7,0
 b1e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 b22:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 b24:	2601                	sext.w	a2,a2
 b26:	00000517          	auipc	a0,0x0
 b2a:	6c250513          	addi	a0,a0,1730 # 11e8 <digits>
 b2e:	883a                	mv	a6,a4
 b30:	2705                	addiw	a4,a4,1
 b32:	02c5f7bb          	remuw	a5,a1,a2
 b36:	1782                	slli	a5,a5,0x20
 b38:	9381                	srli	a5,a5,0x20
 b3a:	97aa                	add	a5,a5,a0
 b3c:	0007c783          	lbu	a5,0(a5)
 b40:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 b44:	0005879b          	sext.w	a5,a1
 b48:	02c5d5bb          	divuw	a1,a1,a2
 b4c:	0685                	addi	a3,a3,1
 b4e:	fec7f0e3          	bgeu	a5,a2,b2e <printint+0x2a>
  if(neg)
 b52:	00088b63          	beqz	a7,b68 <printint+0x64>
    buf[i++] = '-';
 b56:	fd040793          	addi	a5,s0,-48
 b5a:	973e                	add	a4,a4,a5
 b5c:	02d00793          	li	a5,45
 b60:	fef70823          	sb	a5,-16(a4)
 b64:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 b68:	02e05863          	blez	a4,b98 <printint+0x94>
 b6c:	fc040793          	addi	a5,s0,-64
 b70:	00e78933          	add	s2,a5,a4
 b74:	fff78993          	addi	s3,a5,-1
 b78:	99ba                	add	s3,s3,a4
 b7a:	377d                	addiw	a4,a4,-1
 b7c:	1702                	slli	a4,a4,0x20
 b7e:	9301                	srli	a4,a4,0x20
 b80:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 b84:	fff94583          	lbu	a1,-1(s2)
 b88:	8526                	mv	a0,s1
 b8a:	00000097          	auipc	ra,0x0
 b8e:	f58080e7          	jalr	-168(ra) # ae2 <putc>
  while(--i >= 0)
 b92:	197d                	addi	s2,s2,-1
 b94:	ff3918e3          	bne	s2,s3,b84 <printint+0x80>
}
 b98:	70e2                	ld	ra,56(sp)
 b9a:	7442                	ld	s0,48(sp)
 b9c:	74a2                	ld	s1,40(sp)
 b9e:	7902                	ld	s2,32(sp)
 ba0:	69e2                	ld	s3,24(sp)
 ba2:	6121                	addi	sp,sp,64
 ba4:	8082                	ret
    x = -xx;
 ba6:	40b005bb          	negw	a1,a1
    neg = 1;
 baa:	4885                	li	a7,1
    x = -xx;
 bac:	bf8d                	j	b1e <printint+0x1a>

0000000000000bae <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 bae:	7119                	addi	sp,sp,-128
 bb0:	fc86                	sd	ra,120(sp)
 bb2:	f8a2                	sd	s0,112(sp)
 bb4:	f4a6                	sd	s1,104(sp)
 bb6:	f0ca                	sd	s2,96(sp)
 bb8:	ecce                	sd	s3,88(sp)
 bba:	e8d2                	sd	s4,80(sp)
 bbc:	e4d6                	sd	s5,72(sp)
 bbe:	e0da                	sd	s6,64(sp)
 bc0:	fc5e                	sd	s7,56(sp)
 bc2:	f862                	sd	s8,48(sp)
 bc4:	f466                	sd	s9,40(sp)
 bc6:	f06a                	sd	s10,32(sp)
 bc8:	ec6e                	sd	s11,24(sp)
 bca:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 bcc:	0005c903          	lbu	s2,0(a1)
 bd0:	18090f63          	beqz	s2,d6e <vprintf+0x1c0>
 bd4:	8aaa                	mv	s5,a0
 bd6:	8b32                	mv	s6,a2
 bd8:	00158493          	addi	s1,a1,1
  state = 0;
 bdc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 bde:	02500a13          	li	s4,37
      if(c == 'd'){
 be2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 be6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 bea:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 bee:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 bf2:	00000b97          	auipc	s7,0x0
 bf6:	5f6b8b93          	addi	s7,s7,1526 # 11e8 <digits>
 bfa:	a839                	j	c18 <vprintf+0x6a>
        putc(fd, c);
 bfc:	85ca                	mv	a1,s2
 bfe:	8556                	mv	a0,s5
 c00:	00000097          	auipc	ra,0x0
 c04:	ee2080e7          	jalr	-286(ra) # ae2 <putc>
 c08:	a019                	j	c0e <vprintf+0x60>
    } else if(state == '%'){
 c0a:	01498f63          	beq	s3,s4,c28 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 c0e:	0485                	addi	s1,s1,1
 c10:	fff4c903          	lbu	s2,-1(s1)
 c14:	14090d63          	beqz	s2,d6e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 c18:	0009079b          	sext.w	a5,s2
    if(state == 0){
 c1c:	fe0997e3          	bnez	s3,c0a <vprintf+0x5c>
      if(c == '%'){
 c20:	fd479ee3          	bne	a5,s4,bfc <vprintf+0x4e>
        state = '%';
 c24:	89be                	mv	s3,a5
 c26:	b7e5                	j	c0e <vprintf+0x60>
      if(c == 'd'){
 c28:	05878063          	beq	a5,s8,c68 <vprintf+0xba>
      } else if(c == 'l') {
 c2c:	05978c63          	beq	a5,s9,c84 <vprintf+0xd6>
      } else if(c == 'x') {
 c30:	07a78863          	beq	a5,s10,ca0 <vprintf+0xf2>
      } else if(c == 'p') {
 c34:	09b78463          	beq	a5,s11,cbc <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 c38:	07300713          	li	a4,115
 c3c:	0ce78663          	beq	a5,a4,d08 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 c40:	06300713          	li	a4,99
 c44:	0ee78e63          	beq	a5,a4,d40 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 c48:	11478863          	beq	a5,s4,d58 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 c4c:	85d2                	mv	a1,s4
 c4e:	8556                	mv	a0,s5
 c50:	00000097          	auipc	ra,0x0
 c54:	e92080e7          	jalr	-366(ra) # ae2 <putc>
        putc(fd, c);
 c58:	85ca                	mv	a1,s2
 c5a:	8556                	mv	a0,s5
 c5c:	00000097          	auipc	ra,0x0
 c60:	e86080e7          	jalr	-378(ra) # ae2 <putc>
      }
      state = 0;
 c64:	4981                	li	s3,0
 c66:	b765                	j	c0e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 c68:	008b0913          	addi	s2,s6,8
 c6c:	4685                	li	a3,1
 c6e:	4629                	li	a2,10
 c70:	000b2583          	lw	a1,0(s6)
 c74:	8556                	mv	a0,s5
 c76:	00000097          	auipc	ra,0x0
 c7a:	e8e080e7          	jalr	-370(ra) # b04 <printint>
 c7e:	8b4a                	mv	s6,s2
      state = 0;
 c80:	4981                	li	s3,0
 c82:	b771                	j	c0e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 c84:	008b0913          	addi	s2,s6,8
 c88:	4681                	li	a3,0
 c8a:	4629                	li	a2,10
 c8c:	000b2583          	lw	a1,0(s6)
 c90:	8556                	mv	a0,s5
 c92:	00000097          	auipc	ra,0x0
 c96:	e72080e7          	jalr	-398(ra) # b04 <printint>
 c9a:	8b4a                	mv	s6,s2
      state = 0;
 c9c:	4981                	li	s3,0
 c9e:	bf85                	j	c0e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 ca0:	008b0913          	addi	s2,s6,8
 ca4:	4681                	li	a3,0
 ca6:	4641                	li	a2,16
 ca8:	000b2583          	lw	a1,0(s6)
 cac:	8556                	mv	a0,s5
 cae:	00000097          	auipc	ra,0x0
 cb2:	e56080e7          	jalr	-426(ra) # b04 <printint>
 cb6:	8b4a                	mv	s6,s2
      state = 0;
 cb8:	4981                	li	s3,0
 cba:	bf91                	j	c0e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 cbc:	008b0793          	addi	a5,s6,8
 cc0:	f8f43423          	sd	a5,-120(s0)
 cc4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 cc8:	03000593          	li	a1,48
 ccc:	8556                	mv	a0,s5
 cce:	00000097          	auipc	ra,0x0
 cd2:	e14080e7          	jalr	-492(ra) # ae2 <putc>
  putc(fd, 'x');
 cd6:	85ea                	mv	a1,s10
 cd8:	8556                	mv	a0,s5
 cda:	00000097          	auipc	ra,0x0
 cde:	e08080e7          	jalr	-504(ra) # ae2 <putc>
 ce2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 ce4:	03c9d793          	srli	a5,s3,0x3c
 ce8:	97de                	add	a5,a5,s7
 cea:	0007c583          	lbu	a1,0(a5)
 cee:	8556                	mv	a0,s5
 cf0:	00000097          	auipc	ra,0x0
 cf4:	df2080e7          	jalr	-526(ra) # ae2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 cf8:	0992                	slli	s3,s3,0x4
 cfa:	397d                	addiw	s2,s2,-1
 cfc:	fe0914e3          	bnez	s2,ce4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 d00:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 d04:	4981                	li	s3,0
 d06:	b721                	j	c0e <vprintf+0x60>
        s = va_arg(ap, char*);
 d08:	008b0993          	addi	s3,s6,8
 d0c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 d10:	02090163          	beqz	s2,d32 <vprintf+0x184>
        while(*s != 0){
 d14:	00094583          	lbu	a1,0(s2)
 d18:	c9a1                	beqz	a1,d68 <vprintf+0x1ba>
          putc(fd, *s);
 d1a:	8556                	mv	a0,s5
 d1c:	00000097          	auipc	ra,0x0
 d20:	dc6080e7          	jalr	-570(ra) # ae2 <putc>
          s++;
 d24:	0905                	addi	s2,s2,1
        while(*s != 0){
 d26:	00094583          	lbu	a1,0(s2)
 d2a:	f9e5                	bnez	a1,d1a <vprintf+0x16c>
        s = va_arg(ap, char*);
 d2c:	8b4e                	mv	s6,s3
      state = 0;
 d2e:	4981                	li	s3,0
 d30:	bdf9                	j	c0e <vprintf+0x60>
          s = "(null)";
 d32:	00000917          	auipc	s2,0x0
 d36:	4ae90913          	addi	s2,s2,1198 # 11e0 <malloc+0x368>
        while(*s != 0){
 d3a:	02800593          	li	a1,40
 d3e:	bff1                	j	d1a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 d40:	008b0913          	addi	s2,s6,8
 d44:	000b4583          	lbu	a1,0(s6)
 d48:	8556                	mv	a0,s5
 d4a:	00000097          	auipc	ra,0x0
 d4e:	d98080e7          	jalr	-616(ra) # ae2 <putc>
 d52:	8b4a                	mv	s6,s2
      state = 0;
 d54:	4981                	li	s3,0
 d56:	bd65                	j	c0e <vprintf+0x60>
        putc(fd, c);
 d58:	85d2                	mv	a1,s4
 d5a:	8556                	mv	a0,s5
 d5c:	00000097          	auipc	ra,0x0
 d60:	d86080e7          	jalr	-634(ra) # ae2 <putc>
      state = 0;
 d64:	4981                	li	s3,0
 d66:	b565                	j	c0e <vprintf+0x60>
        s = va_arg(ap, char*);
 d68:	8b4e                	mv	s6,s3
      state = 0;
 d6a:	4981                	li	s3,0
 d6c:	b54d                	j	c0e <vprintf+0x60>
    }
  }
}
 d6e:	70e6                	ld	ra,120(sp)
 d70:	7446                	ld	s0,112(sp)
 d72:	74a6                	ld	s1,104(sp)
 d74:	7906                	ld	s2,96(sp)
 d76:	69e6                	ld	s3,88(sp)
 d78:	6a46                	ld	s4,80(sp)
 d7a:	6aa6                	ld	s5,72(sp)
 d7c:	6b06                	ld	s6,64(sp)
 d7e:	7be2                	ld	s7,56(sp)
 d80:	7c42                	ld	s8,48(sp)
 d82:	7ca2                	ld	s9,40(sp)
 d84:	7d02                	ld	s10,32(sp)
 d86:	6de2                	ld	s11,24(sp)
 d88:	6109                	addi	sp,sp,128
 d8a:	8082                	ret

0000000000000d8c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 d8c:	715d                	addi	sp,sp,-80
 d8e:	ec06                	sd	ra,24(sp)
 d90:	e822                	sd	s0,16(sp)
 d92:	1000                	addi	s0,sp,32
 d94:	e010                	sd	a2,0(s0)
 d96:	e414                	sd	a3,8(s0)
 d98:	e818                	sd	a4,16(s0)
 d9a:	ec1c                	sd	a5,24(s0)
 d9c:	03043023          	sd	a6,32(s0)
 da0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 da4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 da8:	8622                	mv	a2,s0
 daa:	00000097          	auipc	ra,0x0
 dae:	e04080e7          	jalr	-508(ra) # bae <vprintf>
}
 db2:	60e2                	ld	ra,24(sp)
 db4:	6442                	ld	s0,16(sp)
 db6:	6161                	addi	sp,sp,80
 db8:	8082                	ret

0000000000000dba <printf>:

void
printf(const char *fmt, ...)
{
 dba:	711d                	addi	sp,sp,-96
 dbc:	ec06                	sd	ra,24(sp)
 dbe:	e822                	sd	s0,16(sp)
 dc0:	1000                	addi	s0,sp,32
 dc2:	e40c                	sd	a1,8(s0)
 dc4:	e810                	sd	a2,16(s0)
 dc6:	ec14                	sd	a3,24(s0)
 dc8:	f018                	sd	a4,32(s0)
 dca:	f41c                	sd	a5,40(s0)
 dcc:	03043823          	sd	a6,48(s0)
 dd0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 dd4:	00840613          	addi	a2,s0,8
 dd8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 ddc:	85aa                	mv	a1,a0
 dde:	4505                	li	a0,1
 de0:	00000097          	auipc	ra,0x0
 de4:	dce080e7          	jalr	-562(ra) # bae <vprintf>
}
 de8:	60e2                	ld	ra,24(sp)
 dea:	6442                	ld	s0,16(sp)
 dec:	6125                	addi	sp,sp,96
 dee:	8082                	ret

0000000000000df0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 df0:	1141                	addi	sp,sp,-16
 df2:	e422                	sd	s0,8(sp)
 df4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 df6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 dfa:	00000797          	auipc	a5,0x0
 dfe:	4067b783          	ld	a5,1030(a5) # 1200 <freep>
 e02:	a805                	j	e32 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 e04:	4618                	lw	a4,8(a2)
 e06:	9db9                	addw	a1,a1,a4
 e08:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 e0c:	6398                	ld	a4,0(a5)
 e0e:	6318                	ld	a4,0(a4)
 e10:	fee53823          	sd	a4,-16(a0)
 e14:	a091                	j	e58 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 e16:	ff852703          	lw	a4,-8(a0)
 e1a:	9e39                	addw	a2,a2,a4
 e1c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 e1e:	ff053703          	ld	a4,-16(a0)
 e22:	e398                	sd	a4,0(a5)
 e24:	a099                	j	e6a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e26:	6398                	ld	a4,0(a5)
 e28:	00e7e463          	bltu	a5,a4,e30 <free+0x40>
 e2c:	00e6ea63          	bltu	a3,a4,e40 <free+0x50>
{
 e30:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e32:	fed7fae3          	bgeu	a5,a3,e26 <free+0x36>
 e36:	6398                	ld	a4,0(a5)
 e38:	00e6e463          	bltu	a3,a4,e40 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e3c:	fee7eae3          	bltu	a5,a4,e30 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 e40:	ff852583          	lw	a1,-8(a0)
 e44:	6390                	ld	a2,0(a5)
 e46:	02059813          	slli	a6,a1,0x20
 e4a:	01c85713          	srli	a4,a6,0x1c
 e4e:	9736                	add	a4,a4,a3
 e50:	fae60ae3          	beq	a2,a4,e04 <free+0x14>
    bp->s.ptr = p->s.ptr;
 e54:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 e58:	4790                	lw	a2,8(a5)
 e5a:	02061593          	slli	a1,a2,0x20
 e5e:	01c5d713          	srli	a4,a1,0x1c
 e62:	973e                	add	a4,a4,a5
 e64:	fae689e3          	beq	a3,a4,e16 <free+0x26>
  } else
    p->s.ptr = bp;
 e68:	e394                	sd	a3,0(a5)
  freep = p;
 e6a:	00000717          	auipc	a4,0x0
 e6e:	38f73b23          	sd	a5,918(a4) # 1200 <freep>
}
 e72:	6422                	ld	s0,8(sp)
 e74:	0141                	addi	sp,sp,16
 e76:	8082                	ret

0000000000000e78 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 e78:	7139                	addi	sp,sp,-64
 e7a:	fc06                	sd	ra,56(sp)
 e7c:	f822                	sd	s0,48(sp)
 e7e:	f426                	sd	s1,40(sp)
 e80:	f04a                	sd	s2,32(sp)
 e82:	ec4e                	sd	s3,24(sp)
 e84:	e852                	sd	s4,16(sp)
 e86:	e456                	sd	s5,8(sp)
 e88:	e05a                	sd	s6,0(sp)
 e8a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 e8c:	02051493          	slli	s1,a0,0x20
 e90:	9081                	srli	s1,s1,0x20
 e92:	04bd                	addi	s1,s1,15
 e94:	8091                	srli	s1,s1,0x4
 e96:	0014899b          	addiw	s3,s1,1
 e9a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 e9c:	00000517          	auipc	a0,0x0
 ea0:	36453503          	ld	a0,868(a0) # 1200 <freep>
 ea4:	c515                	beqz	a0,ed0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ea6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ea8:	4798                	lw	a4,8(a5)
 eaa:	02977f63          	bgeu	a4,s1,ee8 <malloc+0x70>
 eae:	8a4e                	mv	s4,s3
 eb0:	0009871b          	sext.w	a4,s3
 eb4:	6685                	lui	a3,0x1
 eb6:	00d77363          	bgeu	a4,a3,ebc <malloc+0x44>
 eba:	6a05                	lui	s4,0x1
 ebc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 ec0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 ec4:	00000917          	auipc	s2,0x0
 ec8:	33c90913          	addi	s2,s2,828 # 1200 <freep>
  if(p == (char*)-1)
 ecc:	5afd                	li	s5,-1
 ece:	a895                	j	f42 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 ed0:	00000797          	auipc	a5,0x0
 ed4:	33878793          	addi	a5,a5,824 # 1208 <base>
 ed8:	00000717          	auipc	a4,0x0
 edc:	32f73423          	sd	a5,808(a4) # 1200 <freep>
 ee0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 ee2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 ee6:	b7e1                	j	eae <malloc+0x36>
      if(p->s.size == nunits)
 ee8:	02e48c63          	beq	s1,a4,f20 <malloc+0xa8>
        p->s.size -= nunits;
 eec:	4137073b          	subw	a4,a4,s3
 ef0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ef2:	02071693          	slli	a3,a4,0x20
 ef6:	01c6d713          	srli	a4,a3,0x1c
 efa:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 efc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 f00:	00000717          	auipc	a4,0x0
 f04:	30a73023          	sd	a0,768(a4) # 1200 <freep>
      return (void*)(p + 1);
 f08:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 f0c:	70e2                	ld	ra,56(sp)
 f0e:	7442                	ld	s0,48(sp)
 f10:	74a2                	ld	s1,40(sp)
 f12:	7902                	ld	s2,32(sp)
 f14:	69e2                	ld	s3,24(sp)
 f16:	6a42                	ld	s4,16(sp)
 f18:	6aa2                	ld	s5,8(sp)
 f1a:	6b02                	ld	s6,0(sp)
 f1c:	6121                	addi	sp,sp,64
 f1e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 f20:	6398                	ld	a4,0(a5)
 f22:	e118                	sd	a4,0(a0)
 f24:	bff1                	j	f00 <malloc+0x88>
  hp->s.size = nu;
 f26:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 f2a:	0541                	addi	a0,a0,16
 f2c:	00000097          	auipc	ra,0x0
 f30:	ec4080e7          	jalr	-316(ra) # df0 <free>
  return freep;
 f34:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 f38:	d971                	beqz	a0,f0c <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f3a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 f3c:	4798                	lw	a4,8(a5)
 f3e:	fa9775e3          	bgeu	a4,s1,ee8 <malloc+0x70>
    if(p == freep)
 f42:	00093703          	ld	a4,0(s2)
 f46:	853e                	mv	a0,a5
 f48:	fef719e3          	bne	a4,a5,f3a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 f4c:	8552                	mv	a0,s4
 f4e:	00000097          	auipc	ra,0x0
 f52:	b64080e7          	jalr	-1180(ra) # ab2 <sbrk>
  if(p == (char*)-1)
 f56:	fd5518e3          	bne	a0,s5,f26 <malloc+0xae>
        return 0;
 f5a:	4501                	li	a0,0
 f5c:	bf45                	j	f0c <malloc+0x94>
