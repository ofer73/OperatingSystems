
user/_signaltest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <sig_handler>:
}



void
sig_handler(int signum){
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
    char st[3] = "wap";
   8:	6799                	lui	a5,0x6
   a:	17778793          	addi	a5,a5,375 # 6177 <__global_pointer$+0x49b6>
   e:	fef41423          	sh	a5,-24(s0)
  12:	07000793          	li	a5,112
  16:	fef40523          	sb	a5,-22(s0)
    write(1, st, 3);
  1a:	460d                	li	a2,3
  1c:	fe840593          	addi	a1,s0,-24
  20:	4505                	li	a0,1
  22:	00000097          	auipc	ra,0x0
  26:	770080e7          	jalr	1904(ra) # 792 <write>
    return;
}
  2a:	60e2                	ld	ra,24(sp)
  2c:	6442                	ld	s0,16(sp)
  2e:	6105                	addi	sp,sp,32
  30:	8082                	ret

0000000000000032 <sig_handler2>:

void
sig_handler2(int signum){
  32:	1101                	addi	sp,sp,-32
  34:	ec06                	sd	ra,24(sp)
  36:	e822                	sd	s0,16(sp)
  38:	1000                	addi	s0,sp,32
    char st[3] = "dap";
  3a:	6799                	lui	a5,0x6
  3c:	16478793          	addi	a5,a5,356 # 6164 <__global_pointer$+0x49a3>
  40:	fef41423          	sh	a5,-24(s0)
  44:	07000793          	li	a5,112
  48:	fef40523          	sb	a5,-22(s0)
    write(1, st, 3);
  4c:	460d                	li	a2,3
  4e:	fe840593          	addi	a1,s0,-24
  52:	4505                	li	a0,1
  54:	00000097          	auipc	ra,0x0
  58:	73e080e7          	jalr	1854(ra) # 792 <write>
    return;
}
  5c:	60e2                	ld	ra,24(sp)
  5e:	6442                	ld	s0,16(sp)
  60:	6105                	addi	sp,sp,32
  62:	8082                	ret

0000000000000064 <test_stop_cont>:
    }
    // exit(0);
}

void
test_stop_cont(){
  64:	7179                	addi	sp,sp,-48
  66:	f406                	sd	ra,40(sp)
  68:	f022                	sd	s0,32(sp)
  6a:	ec26                	sd	s1,24(sp)
  6c:	e84a                	sd	s2,16(sp)
  6e:	e44e                	sd	s3,8(sp)
  70:	1800                	addi	s0,sp,48
    int pid = fork();
  72:	00000097          	auipc	ra,0x0
  76:	6f8080e7          	jalr	1784(ra) # 76a <fork>
  7a:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
  7c:	e915                	bnez	a0,b0 <test_stop_cont+0x4c>
        sleep(2);
  7e:	4509                	li	a0,2
  80:	00000097          	auipc	ra,0x0
  84:	782080e7          	jalr	1922(ra) # 802 <sleep>
        for(i=0;i<500;i++)
            printf("%d\n ", i);
  88:	00001997          	auipc	s3,0x1
  8c:	c2098993          	addi	s3,s3,-992 # ca8 <malloc+0xe8>
        for(i=0;i<500;i++)
  90:	1f400913          	li	s2,500
            printf("%d\n ", i);
  94:	85a6                	mv	a1,s1
  96:	854e                	mv	a0,s3
  98:	00001097          	auipc	ra,0x1
  9c:	a6a080e7          	jalr	-1430(ra) # b02 <printf>
        for(i=0;i<500;i++)
  a0:	2485                	addiw	s1,s1,1
  a2:	ff2499e3          	bne	s1,s2,94 <test_stop_cont+0x30>
        exit(0);
  a6:	4501                	li	a0,0
  a8:	00000097          	auipc	ra,0x0
  ac:	6ca080e7          	jalr	1738(ra) # 772 <exit>
    }else{
        printf("son pid=%d, dad pid=%d\n",pid, getpid());
  b0:	00000097          	auipc	ra,0x0
  b4:	742080e7          	jalr	1858(ra) # 7f2 <getpid>
  b8:	862a                	mv	a2,a0
  ba:	85a6                	mv	a1,s1
  bc:	00001517          	auipc	a0,0x1
  c0:	bf450513          	addi	a0,a0,-1036 # cb0 <malloc+0xf0>
  c4:	00001097          	auipc	ra,0x1
  c8:	a3e080e7          	jalr	-1474(ra) # b02 <printf>
        sleep(5);
  cc:	4515                	li	a0,5
  ce:	00000097          	auipc	ra,0x0
  d2:	734080e7          	jalr	1844(ra) # 802 <sleep>
        printf("parent send stop ret= %d\n",kill(pid, SIGSTOP));
  d6:	45c5                	li	a1,17
  d8:	8526                	mv	a0,s1
  da:	00000097          	auipc	ra,0x0
  de:	6c8080e7          	jalr	1736(ra) # 7a2 <kill>
  e2:	85aa                	mv	a1,a0
  e4:	00001517          	auipc	a0,0x1
  e8:	be450513          	addi	a0,a0,-1052 # cc8 <malloc+0x108>
  ec:	00001097          	auipc	ra,0x1
  f0:	a16080e7          	jalr	-1514(ra) # b02 <printf>
        sleep(50);
  f4:	03200513          	li	a0,50
  f8:	00000097          	auipc	ra,0x0
  fc:	70a080e7          	jalr	1802(ra) # 802 <sleep>
        printf("parent send continue ret= %d\n",kill(pid, SIGCONT));
 100:	45cd                	li	a1,19
 102:	8526                	mv	a0,s1
 104:	00000097          	auipc	ra,0x0
 108:	69e080e7          	jalr	1694(ra) # 7a2 <kill>
 10c:	85aa                	mv	a1,a0
 10e:	00001517          	auipc	a0,0x1
 112:	bda50513          	addi	a0,a0,-1062 # ce8 <malloc+0x128>
 116:	00001097          	auipc	ra,0x1
 11a:	9ec080e7          	jalr	-1556(ra) # b02 <printf>
        wait(0);
 11e:	4501                	li	a0,0
 120:	00000097          	auipc	ra,0x0
 124:	65a080e7          	jalr	1626(ra) # 77a <wait>
        // for(int i=0;i<100;i++)
        //  printf("parent..");
        sleep(10);
 128:	4529                	li	a0,10
 12a:	00000097          	auipc	ra,0x0
 12e:	6d8080e7          	jalr	1752(ra) # 802 <sleep>
        exit(0);
 132:	4501                	li	a0,0
 134:	00000097          	auipc	ra,0x0
 138:	63e080e7          	jalr	1598(ra) # 772 <exit>

000000000000013c <test_sigkill>:
test_sigkill(){//
 13c:	7179                	addi	sp,sp,-48
 13e:	f406                	sd	ra,40(sp)
 140:	f022                	sd	s0,32(sp)
 142:	ec26                	sd	s1,24(sp)
 144:	e84a                	sd	s2,16(sp)
 146:	e44e                	sd	s3,8(sp)
 148:	1800                	addi	s0,sp,48
   int pid = fork();
 14a:	00000097          	auipc	ra,0x0
 14e:	620080e7          	jalr	1568(ra) # 76a <fork>
 152:	84aa                	mv	s1,a0
    if(pid==0){
 154:	ed05                	bnez	a0,18c <test_sigkill+0x50>
        sleep(5);
 156:	4515                	li	a0,5
 158:	00000097          	auipc	ra,0x0
 15c:	6aa080e7          	jalr	1706(ra) # 802 <sleep>
            printf("about to get killed %d\n",i);
 160:	00001997          	auipc	s3,0x1
 164:	ba898993          	addi	s3,s3,-1112 # d08 <malloc+0x148>
        for(int i=0;i<300;i++)
 168:	12c00913          	li	s2,300
            printf("about to get killed %d\n",i);
 16c:	85a6                	mv	a1,s1
 16e:	854e                	mv	a0,s3
 170:	00001097          	auipc	ra,0x1
 174:	992080e7          	jalr	-1646(ra) # b02 <printf>
        for(int i=0;i<300;i++)
 178:	2485                	addiw	s1,s1,1
 17a:	ff2499e3          	bne	s1,s2,16c <test_sigkill+0x30>
}
 17e:	70a2                	ld	ra,40(sp)
 180:	7402                	ld	s0,32(sp)
 182:	64e2                	ld	s1,24(sp)
 184:	6942                	ld	s2,16(sp)
 186:	69a2                	ld	s3,8(sp)
 188:	6145                	addi	sp,sp,48
 18a:	8082                	ret
        sleep(7);
 18c:	451d                	li	a0,7
 18e:	00000097          	auipc	ra,0x0
 192:	674080e7          	jalr	1652(ra) # 802 <sleep>
        printf("parent send signal to to kill child\n");
 196:	00001517          	auipc	a0,0x1
 19a:	b8a50513          	addi	a0,a0,-1142 # d20 <malloc+0x160>
 19e:	00001097          	auipc	ra,0x1
 1a2:	964080e7          	jalr	-1692(ra) # b02 <printf>
        printf("kill ret= %d\n",kill(pid, SIGKILL));
 1a6:	45a5                	li	a1,9
 1a8:	8526                	mv	a0,s1
 1aa:	00000097          	auipc	ra,0x0
 1ae:	5f8080e7          	jalr	1528(ra) # 7a2 <kill>
 1b2:	85aa                	mv	a1,a0
 1b4:	00001517          	auipc	a0,0x1
 1b8:	b9450513          	addi	a0,a0,-1132 # d48 <malloc+0x188>
 1bc:	00001097          	auipc	ra,0x1
 1c0:	946080e7          	jalr	-1722(ra) # b02 <printf>
        printf("parent wait for child\n");
 1c4:	00001517          	auipc	a0,0x1
 1c8:	b9450513          	addi	a0,a0,-1132 # d58 <malloc+0x198>
 1cc:	00001097          	auipc	ra,0x1
 1d0:	936080e7          	jalr	-1738(ra) # b02 <printf>
        wait(0);
 1d4:	4501                	li	a0,0
 1d6:	00000097          	auipc	ra,0x0
 1da:	5a4080e7          	jalr	1444(ra) # 77a <wait>
        printf("parent: child is dead\n");
 1de:	00001517          	auipc	a0,0x1
 1e2:	b9250513          	addi	a0,a0,-1134 # d70 <malloc+0x1b0>
 1e6:	00001097          	auipc	ra,0x1
 1ea:	91c080e7          	jalr	-1764(ra) # b02 <printf>
        sleep(10);
 1ee:	4529                	li	a0,10
 1f0:	00000097          	auipc	ra,0x0
 1f4:	612080e7          	jalr	1554(ra) # 802 <sleep>
        exit(0);
 1f8:	4501                	li	a0,0
 1fa:	00000097          	auipc	ra,0x0
 1fe:	578080e7          	jalr	1400(ra) # 772 <exit>

0000000000000202 <test_usersig>:
test_usersig(){
 202:	711d                	addi	sp,sp,-96
 204:	ec86                	sd	ra,88(sp)
 206:	e8a2                	sd	s0,80(sp)
 208:	e4a6                	sd	s1,72(sp)
 20a:	e0ca                	sd	s2,64(sp)
 20c:	1080                	addi	s0,sp,96
    printf("inside usersig test!\n");
 20e:	00001517          	auipc	a0,0x1
 212:	b7a50513          	addi	a0,a0,-1158 # d88 <malloc+0x1c8>
 216:	00001097          	auipc	ra,0x1
 21a:	8ec080e7          	jalr	-1812(ra) # b02 <printf>
    int pid = fork();
 21e:	00000097          	auipc	ra,0x0
 222:	54c080e7          	jalr	1356(ra) # 76a <fork>
    if(pid==0){
 226:	c125                	beqz	a0,286 <test_usersig+0x84>
 228:	84aa                	mv	s1,a0
        sleep(10);
 22a:	4529                	li	a0,10
 22c:	00000097          	auipc	ra,0x0
 230:	5d6080e7          	jalr	1494(ra) # 802 <sleep>
        printf("parent send sig 3 to child ret=%d\n",kill(pid,3));
 234:	458d                	li	a1,3
 236:	8526                	mv	a0,s1
 238:	00000097          	auipc	ra,0x0
 23c:	56a080e7          	jalr	1386(ra) # 7a2 <kill>
 240:	85aa                	mv	a1,a0
 242:	00001517          	auipc	a0,0x1
 246:	bc650513          	addi	a0,a0,-1082 # e08 <malloc+0x248>
 24a:	00001097          	auipc	ra,0x1
 24e:	8b8080e7          	jalr	-1864(ra) # b02 <printf>
        printf("parent send sig 3 to child ret=%d\n",kill(pid,4));
 252:	4591                	li	a1,4
 254:	8526                	mv	a0,s1
 256:	00000097          	auipc	ra,0x0
 25a:	54c080e7          	jalr	1356(ra) # 7a2 <kill>
 25e:	85aa                	mv	a1,a0
 260:	00001517          	auipc	a0,0x1
 264:	ba850513          	addi	a0,a0,-1112 # e08 <malloc+0x248>
 268:	00001097          	auipc	ra,0x1
 26c:	89a080e7          	jalr	-1894(ra) # b02 <printf>
        wait(0);
 270:	4501                	li	a0,0
 272:	00000097          	auipc	ra,0x0
 276:	508080e7          	jalr	1288(ra) # 77a <wait>
}
 27a:	60e6                	ld	ra,88(sp)
 27c:	6446                	ld	s0,80(sp)
 27e:	64a6                	ld	s1,72(sp)
 280:	6906                	ld	s2,64(sp)
 282:	6125                	addi	sp,sp,96
 284:	8082                	ret
        printf("sighandler= %p\n",&sig_handler);
 286:	00000597          	auipc	a1,0x0
 28a:	d7a58593          	addi	a1,a1,-646 # 0 <sig_handler>
 28e:	00001517          	auipc	a0,0x1
 292:	b1250513          	addi	a0,a0,-1262 # da0 <malloc+0x1e0>
 296:	00001097          	auipc	ra,0x1
 29a:	86c080e7          	jalr	-1940(ra) # b02 <printf>
        printf("sighandler= %p\n",&sig_handler2);
 29e:	00000597          	auipc	a1,0x0
 2a2:	d9458593          	addi	a1,a1,-620 # 32 <sig_handler2>
 2a6:	00001517          	auipc	a0,0x1
 2aa:	afa50513          	addi	a0,a0,-1286 # da0 <malloc+0x1e0>
 2ae:	00001097          	auipc	ra,0x1
 2b2:	854080e7          	jalr	-1964(ra) # b02 <printf>
        printf("stop test= %p\n",&test_stop_cont);
 2b6:	00000597          	auipc	a1,0x0
 2ba:	dae58593          	addi	a1,a1,-594 # 64 <test_stop_cont>
 2be:	00001517          	auipc	a0,0x1
 2c2:	af250513          	addi	a0,a0,-1294 # db0 <malloc+0x1f0>
 2c6:	00001097          	auipc	ra,0x1
 2ca:	83c080e7          	jalr	-1988(ra) # b02 <printf>
        act.sa_handler = &sig_handler;
 2ce:	00000797          	auipc	a5,0x0
 2d2:	d3278793          	addi	a5,a5,-718 # 0 <sig_handler>
 2d6:	faf43023          	sd	a5,-96(s0)
        act.sigmask = mask;
 2da:	004007b7          	lui	a5,0x400
 2de:	faf42423          	sw	a5,-88(s0)
        act2.sa_handler = &sig_handler2;
 2e2:	00000717          	auipc	a4,0x0
 2e6:	d5070713          	addi	a4,a4,-688 # 32 <sig_handler2>
 2ea:	fae43823          	sd	a4,-80(s0)
        act2.sigmask = mask;
 2ee:	faf42c23          	sw	a5,-72(s0)
        int ret=sigaction(3,&act,&oldact);
 2f2:	fc040613          	addi	a2,s0,-64
 2f6:	fa040593          	addi	a1,s0,-96
 2fa:	450d                	li	a0,3
 2fc:	00000097          	auipc	ra,0x0
 300:	51e080e7          	jalr	1310(ra) # 81a <sigaction>
 304:	84aa                	mv	s1,a0
        int ret2=sigaction(4,&act2,&oldact2);
 306:	fd040613          	addi	a2,s0,-48
 30a:	fb040593          	addi	a1,s0,-80
 30e:	4511                	li	a0,4
 310:	00000097          	auipc	ra,0x0
 314:	50a080e7          	jalr	1290(ra) # 81a <sigaction>
        printf("child return from sigaction = %d\n",ret);
 318:	85a6                	mv	a1,s1
 31a:	00001517          	auipc	a0,0x1
 31e:	aa650513          	addi	a0,a0,-1370 # dc0 <malloc+0x200>
 322:	00000097          	auipc	ra,0x0
 326:	7e0080e7          	jalr	2016(ra) # b02 <printf>
        sleep(10);
 32a:	4529                	li	a0,10
 32c:	00000097          	auipc	ra,0x0
 330:	4d6080e7          	jalr	1238(ra) # 802 <sleep>
 334:	44a9                	li	s1,10
            printf("child doing stuff before exit \n");
 336:	00001917          	auipc	s2,0x1
 33a:	ab290913          	addi	s2,s2,-1358 # de8 <malloc+0x228>
 33e:	854a                	mv	a0,s2
 340:	00000097          	auipc	ra,0x0
 344:	7c2080e7          	jalr	1986(ra) # b02 <printf>
        for(int i=0;i<10;i++){
 348:	34fd                	addiw	s1,s1,-1
 34a:	f8f5                	bnez	s1,33e <test_usersig+0x13c>
        exit(0);
 34c:	4501                	li	a0,0
 34e:	00000097          	auipc	ra,0x0
 352:	424080e7          	jalr	1060(ra) # 772 <exit>

0000000000000356 <test_block>:
test_block(){//parent block 22 child block 23 
 356:	7179                	addi	sp,sp,-48
 358:	f406                	sd	ra,40(sp)
 35a:	f022                	sd	s0,32(sp)
 35c:	ec26                	sd	s1,24(sp)
 35e:	e84a                	sd	s2,16(sp)
 360:	e44e                	sd	s3,8(sp)
 362:	1800                	addi	s0,sp,48
    int ans=sigprocmask(1<<signum1);
 364:	00400537          	lui	a0,0x400
 368:	00000097          	auipc	ra,0x0
 36c:	4aa080e7          	jalr	1194(ra) # 812 <sigprocmask>
    printf("got %d from calling to sigprocmask\n",ans);
 370:	0005059b          	sext.w	a1,a0
 374:	00001517          	auipc	a0,0x1
 378:	abc50513          	addi	a0,a0,-1348 # e30 <malloc+0x270>
 37c:	00000097          	auipc	ra,0x0
 380:	786080e7          	jalr	1926(ra) # b02 <printf>
    int pid=fork();
 384:	00000097          	auipc	ra,0x0
 388:	3e6080e7          	jalr	998(ra) # 76a <fork>
 38c:	84aa                	mv	s1,a0
    if(pid==0){
 38e:	c921                	beqz	a0,3de <test_block+0x88>
        sleep(1);//wait for child to block sig
 390:	4505                	li	a0,1
 392:	00000097          	auipc	ra,0x0
 396:	470080e7          	jalr	1136(ra) # 802 <sleep>
        kill(pid,signum1);
 39a:	45d9                	li	a1,22
 39c:	8526                	mv	a0,s1
 39e:	00000097          	auipc	ra,0x0
 3a2:	404080e7          	jalr	1028(ra) # 7a2 <kill>
        printf("parent: sent signal 22 to child ->child shuld block\n");
 3a6:	00001517          	auipc	a0,0x1
 3aa:	ad250513          	addi	a0,a0,-1326 # e78 <malloc+0x2b8>
 3ae:	00000097          	auipc	ra,0x0
 3b2:	754080e7          	jalr	1876(ra) # b02 <printf>
        printf("parent: sent signal 23 to child ->child shuld block\n");
 3b6:	00001517          	auipc	a0,0x1
 3ba:	afa50513          	addi	a0,a0,-1286 # eb0 <malloc+0x2f0>
 3be:	00000097          	auipc	ra,0x0
 3c2:	744080e7          	jalr	1860(ra) # b02 <printf>
        wait(0);
 3c6:	4501                	li	a0,0
 3c8:	00000097          	auipc	ra,0x0
 3cc:	3b2080e7          	jalr	946(ra) # 77a <wait>
}
 3d0:	70a2                	ld	ra,40(sp)
 3d2:	7402                	ld	s0,32(sp)
 3d4:	64e2                	ld	s1,24(sp)
 3d6:	6942                	ld	s2,16(sp)
 3d8:	69a2                	ld	s3,8(sp)
 3da:	6145                	addi	sp,sp,48
 3dc:	8082                	ret
        sleep(3);
 3de:	450d                	li	a0,3
 3e0:	00000097          	auipc	ra,0x0
 3e4:	422080e7          	jalr	1058(ra) # 802 <sleep>
            printf("child blocking signal %d :-)\n",i);
 3e8:	00001997          	auipc	s3,0x1
 3ec:	a7098993          	addi	s3,s3,-1424 # e58 <malloc+0x298>
        for(int i=0;i<100;i++){
 3f0:	06400913          	li	s2,100
            printf("child blocking signal %d :-)\n",i);
 3f4:	85a6                	mv	a1,s1
 3f6:	854e                	mv	a0,s3
 3f8:	00000097          	auipc	ra,0x0
 3fc:	70a080e7          	jalr	1802(ra) # b02 <printf>
        for(int i=0;i<100;i++){
 400:	2485                	addiw	s1,s1,1
 402:	ff2499e3          	bne	s1,s2,3f4 <test_block+0x9e>
        exit(0);
 406:	4501                	li	a0,0
 408:	00000097          	auipc	ra,0x0
 40c:	36a080e7          	jalr	874(ra) # 772 <exit>

0000000000000410 <test_ignore>:
    }
}

void 
test_ignore(){
 410:	1101                	addi	sp,sp,-32
 412:	ec06                	sd	ra,24(sp)
 414:	e822                	sd	s0,16(sp)
 416:	e426                	sd	s1,8(sp)
 418:	e04a                	sd	s2,0(sp)
 41a:	1000                	addi	s0,sp,32
    int pid= fork();
 41c:	00000097          	auipc	ra,0x0
 420:	34e080e7          	jalr	846(ra) # 76a <fork>
    int signum=22;
    if(pid==0){
 424:	c129                	beqz	a0,466 <test_ignore+0x56>
 426:	84aa                	mv	s1,a0
            printf("child ignoring signal :-)\n");
        }
        exit(0);

    }else{
        printf("son pid= %d",pid);
 428:	85aa                	mv	a1,a0
 42a:	00001517          	auipc	a0,0x1
 42e:	b2650513          	addi	a0,a0,-1242 # f50 <malloc+0x390>
 432:	00000097          	auipc	ra,0x0
 436:	6d0080e7          	jalr	1744(ra) # b02 <printf>
        sleep(5);
 43a:	4515                	li	a0,5
 43c:	00000097          	auipc	ra,0x0
 440:	3c6080e7          	jalr	966(ra) # 802 <sleep>
        kill(pid,signum);
 444:	45d9                	li	a1,22
 446:	8526                	mv	a0,s1
 448:	00000097          	auipc	ra,0x0
 44c:	35a080e7          	jalr	858(ra) # 7a2 <kill>
        wait(0);
 450:	4501                	li	a0,0
 452:	00000097          	auipc	ra,0x0
 456:	328080e7          	jalr	808(ra) # 77a <wait>

    }
}
 45a:	60e2                	ld	ra,24(sp)
 45c:	6442                	ld	s0,16(sp)
 45e:	64a2                	ld	s1,8(sp)
 460:	6902                	ld	s2,0(sp)
 462:	6105                	addi	sp,sp,32
 464:	8082                	ret
        newAct=malloc(sizeof(sigaction));
 466:	4505                	li	a0,1
 468:	00000097          	auipc	ra,0x0
 46c:	758080e7          	jalr	1880(ra) # bc0 <malloc>
 470:	892a                	mv	s2,a0
        oldAct=malloc(sizeof(sigaction));
 472:	4505                	li	a0,1
 474:	00000097          	auipc	ra,0x0
 478:	74c080e7          	jalr	1868(ra) # bc0 <malloc>
 47c:	84aa                	mv	s1,a0
        newAct->sigmask = 0;
 47e:	00092423          	sw	zero,8(s2)
        newAct->sa_handler=(void*)SIG_IGN;
 482:	4785                	li	a5,1
 484:	00f93023          	sd	a5,0(s2)
        int ans=sigaction(signum,newAct,oldAct);
 488:	862a                	mv	a2,a0
 48a:	85ca                	mv	a1,s2
 48c:	4559                	li	a0,22
 48e:	00000097          	auipc	ra,0x0
 492:	38c080e7          	jalr	908(ra) # 81a <sigaction>
 496:	85aa                	mv	a1,a0
        printf("ans from sigaction %d, old act returned is: mask= %d address= %d\n",ans,oldAct->sigmask,(uint64)oldAct->sa_handler);
 498:	6094                	ld	a3,0(s1)
 49a:	4490                	lw	a2,8(s1)
 49c:	00001517          	auipc	a0,0x1
 4a0:	a4c50513          	addi	a0,a0,-1460 # ee8 <malloc+0x328>
 4a4:	00000097          	auipc	ra,0x0
 4a8:	65e080e7          	jalr	1630(ra) # b02 <printf>
        sleep(6);
 4ac:	4519                	li	a0,6
 4ae:	00000097          	auipc	ra,0x0
 4b2:	354080e7          	jalr	852(ra) # 802 <sleep>
 4b6:	12c00493          	li	s1,300
            printf("child ignoring signal :-)\n");
 4ba:	00001917          	auipc	s2,0x1
 4be:	a7690913          	addi	s2,s2,-1418 # f30 <malloc+0x370>
 4c2:	854a                	mv	a0,s2
 4c4:	00000097          	auipc	ra,0x0
 4c8:	63e080e7          	jalr	1598(ra) # b02 <printf>
        for(int i=0;i<300;i++){
 4cc:	34fd                	addiw	s1,s1,-1
 4ce:	f8f5                	bnez	s1,4c2 <test_ignore+0xb2>
        exit(0);
 4d0:	4501                	li	a0,0
 4d2:	00000097          	auipc	ra,0x0
 4d6:	2a0080e7          	jalr	672(ra) # 772 <exit>

00000000000004da <main>:


int main(){
 4da:	1141                	addi	sp,sp,-16
 4dc:	e406                	sd	ra,8(sp)
 4de:	e022                	sd	s0,0(sp)
 4e0:	0800                	addi	s0,sp,16
    // test_sigkill();

    //  printf("-----------------------------test_stop_cont_sig-----------------------------\n");
    // test_stop_cont();
    
    printf("-----------------------------test_usersig-----------------------------\n");
 4e2:	00001517          	auipc	a0,0x1
 4e6:	a7e50513          	addi	a0,a0,-1410 # f60 <malloc+0x3a0>
 4ea:	00000097          	auipc	ra,0x0
 4ee:	618080e7          	jalr	1560(ra) # b02 <printf>
    test_usersig();
 4f2:	00000097          	auipc	ra,0x0
 4f6:	d10080e7          	jalr	-752(ra) # 202 <test_usersig>
    // printf("-----------------------------test_ignore-----------------------------\n");
    // test_ignore();
    // exit(0);

    return 0;
}
 4fa:	4501                	li	a0,0
 4fc:	60a2                	ld	ra,8(sp)
 4fe:	6402                	ld	s0,0(sp)
 500:	0141                	addi	sp,sp,16
 502:	8082                	ret

0000000000000504 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 504:	1141                	addi	sp,sp,-16
 506:	e422                	sd	s0,8(sp)
 508:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 50a:	87aa                	mv	a5,a0
 50c:	0585                	addi	a1,a1,1
 50e:	0785                	addi	a5,a5,1
 510:	fff5c703          	lbu	a4,-1(a1)
 514:	fee78fa3          	sb	a4,-1(a5) # 3fffff <__global_pointer$+0x3fe83e>
 518:	fb75                	bnez	a4,50c <strcpy+0x8>
    ;
  return os;
}
 51a:	6422                	ld	s0,8(sp)
 51c:	0141                	addi	sp,sp,16
 51e:	8082                	ret

0000000000000520 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 520:	1141                	addi	sp,sp,-16
 522:	e422                	sd	s0,8(sp)
 524:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 526:	00054783          	lbu	a5,0(a0)
 52a:	cb91                	beqz	a5,53e <strcmp+0x1e>
 52c:	0005c703          	lbu	a4,0(a1)
 530:	00f71763          	bne	a4,a5,53e <strcmp+0x1e>
    p++, q++;
 534:	0505                	addi	a0,a0,1
 536:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 538:	00054783          	lbu	a5,0(a0)
 53c:	fbe5                	bnez	a5,52c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 53e:	0005c503          	lbu	a0,0(a1)
}
 542:	40a7853b          	subw	a0,a5,a0
 546:	6422                	ld	s0,8(sp)
 548:	0141                	addi	sp,sp,16
 54a:	8082                	ret

000000000000054c <strlen>:

uint
strlen(const char *s)
{
 54c:	1141                	addi	sp,sp,-16
 54e:	e422                	sd	s0,8(sp)
 550:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 552:	00054783          	lbu	a5,0(a0)
 556:	cf91                	beqz	a5,572 <strlen+0x26>
 558:	0505                	addi	a0,a0,1
 55a:	87aa                	mv	a5,a0
 55c:	4685                	li	a3,1
 55e:	9e89                	subw	a3,a3,a0
 560:	00f6853b          	addw	a0,a3,a5
 564:	0785                	addi	a5,a5,1
 566:	fff7c703          	lbu	a4,-1(a5)
 56a:	fb7d                	bnez	a4,560 <strlen+0x14>
    ;
  return n;
}
 56c:	6422                	ld	s0,8(sp)
 56e:	0141                	addi	sp,sp,16
 570:	8082                	ret
  for(n = 0; s[n]; n++)
 572:	4501                	li	a0,0
 574:	bfe5                	j	56c <strlen+0x20>

0000000000000576 <memset>:

void*
memset(void *dst, int c, uint n)
{
 576:	1141                	addi	sp,sp,-16
 578:	e422                	sd	s0,8(sp)
 57a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 57c:	ca19                	beqz	a2,592 <memset+0x1c>
 57e:	87aa                	mv	a5,a0
 580:	1602                	slli	a2,a2,0x20
 582:	9201                	srli	a2,a2,0x20
 584:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 588:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 58c:	0785                	addi	a5,a5,1
 58e:	fee79de3          	bne	a5,a4,588 <memset+0x12>
  }
  return dst;
}
 592:	6422                	ld	s0,8(sp)
 594:	0141                	addi	sp,sp,16
 596:	8082                	ret

0000000000000598 <strchr>:

char*
strchr(const char *s, char c)
{
 598:	1141                	addi	sp,sp,-16
 59a:	e422                	sd	s0,8(sp)
 59c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 59e:	00054783          	lbu	a5,0(a0)
 5a2:	cb99                	beqz	a5,5b8 <strchr+0x20>
    if(*s == c)
 5a4:	00f58763          	beq	a1,a5,5b2 <strchr+0x1a>
  for(; *s; s++)
 5a8:	0505                	addi	a0,a0,1
 5aa:	00054783          	lbu	a5,0(a0)
 5ae:	fbfd                	bnez	a5,5a4 <strchr+0xc>
      return (char*)s;
  return 0;
 5b0:	4501                	li	a0,0
}
 5b2:	6422                	ld	s0,8(sp)
 5b4:	0141                	addi	sp,sp,16
 5b6:	8082                	ret
  return 0;
 5b8:	4501                	li	a0,0
 5ba:	bfe5                	j	5b2 <strchr+0x1a>

00000000000005bc <gets>:

char*
gets(char *buf, int max)
{
 5bc:	711d                	addi	sp,sp,-96
 5be:	ec86                	sd	ra,88(sp)
 5c0:	e8a2                	sd	s0,80(sp)
 5c2:	e4a6                	sd	s1,72(sp)
 5c4:	e0ca                	sd	s2,64(sp)
 5c6:	fc4e                	sd	s3,56(sp)
 5c8:	f852                	sd	s4,48(sp)
 5ca:	f456                	sd	s5,40(sp)
 5cc:	f05a                	sd	s6,32(sp)
 5ce:	ec5e                	sd	s7,24(sp)
 5d0:	1080                	addi	s0,sp,96
 5d2:	8baa                	mv	s7,a0
 5d4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5d6:	892a                	mv	s2,a0
 5d8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 5da:	4aa9                	li	s5,10
 5dc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 5de:	89a6                	mv	s3,s1
 5e0:	2485                	addiw	s1,s1,1
 5e2:	0344d863          	bge	s1,s4,612 <gets+0x56>
    cc = read(0, &c, 1);
 5e6:	4605                	li	a2,1
 5e8:	faf40593          	addi	a1,s0,-81
 5ec:	4501                	li	a0,0
 5ee:	00000097          	auipc	ra,0x0
 5f2:	19c080e7          	jalr	412(ra) # 78a <read>
    if(cc < 1)
 5f6:	00a05e63          	blez	a0,612 <gets+0x56>
    buf[i++] = c;
 5fa:	faf44783          	lbu	a5,-81(s0)
 5fe:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 602:	01578763          	beq	a5,s5,610 <gets+0x54>
 606:	0905                	addi	s2,s2,1
 608:	fd679be3          	bne	a5,s6,5de <gets+0x22>
  for(i=0; i+1 < max; ){
 60c:	89a6                	mv	s3,s1
 60e:	a011                	j	612 <gets+0x56>
 610:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 612:	99de                	add	s3,s3,s7
 614:	00098023          	sb	zero,0(s3)
  return buf;
}
 618:	855e                	mv	a0,s7
 61a:	60e6                	ld	ra,88(sp)
 61c:	6446                	ld	s0,80(sp)
 61e:	64a6                	ld	s1,72(sp)
 620:	6906                	ld	s2,64(sp)
 622:	79e2                	ld	s3,56(sp)
 624:	7a42                	ld	s4,48(sp)
 626:	7aa2                	ld	s5,40(sp)
 628:	7b02                	ld	s6,32(sp)
 62a:	6be2                	ld	s7,24(sp)
 62c:	6125                	addi	sp,sp,96
 62e:	8082                	ret

0000000000000630 <stat>:

int
stat(const char *n, struct stat *st)
{
 630:	1101                	addi	sp,sp,-32
 632:	ec06                	sd	ra,24(sp)
 634:	e822                	sd	s0,16(sp)
 636:	e426                	sd	s1,8(sp)
 638:	e04a                	sd	s2,0(sp)
 63a:	1000                	addi	s0,sp,32
 63c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 63e:	4581                	li	a1,0
 640:	00000097          	auipc	ra,0x0
 644:	172080e7          	jalr	370(ra) # 7b2 <open>
  if(fd < 0)
 648:	02054563          	bltz	a0,672 <stat+0x42>
 64c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 64e:	85ca                	mv	a1,s2
 650:	00000097          	auipc	ra,0x0
 654:	17a080e7          	jalr	378(ra) # 7ca <fstat>
 658:	892a                	mv	s2,a0
  close(fd);
 65a:	8526                	mv	a0,s1
 65c:	00000097          	auipc	ra,0x0
 660:	13e080e7          	jalr	318(ra) # 79a <close>
  return r;
}
 664:	854a                	mv	a0,s2
 666:	60e2                	ld	ra,24(sp)
 668:	6442                	ld	s0,16(sp)
 66a:	64a2                	ld	s1,8(sp)
 66c:	6902                	ld	s2,0(sp)
 66e:	6105                	addi	sp,sp,32
 670:	8082                	ret
    return -1;
 672:	597d                	li	s2,-1
 674:	bfc5                	j	664 <stat+0x34>

0000000000000676 <atoi>:

int
atoi(const char *s)
{
 676:	1141                	addi	sp,sp,-16
 678:	e422                	sd	s0,8(sp)
 67a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 67c:	00054603          	lbu	a2,0(a0)
 680:	fd06079b          	addiw	a5,a2,-48
 684:	0ff7f793          	andi	a5,a5,255
 688:	4725                	li	a4,9
 68a:	02f76963          	bltu	a4,a5,6bc <atoi+0x46>
 68e:	86aa                	mv	a3,a0
  n = 0;
 690:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 692:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 694:	0685                	addi	a3,a3,1
 696:	0025179b          	slliw	a5,a0,0x2
 69a:	9fa9                	addw	a5,a5,a0
 69c:	0017979b          	slliw	a5,a5,0x1
 6a0:	9fb1                	addw	a5,a5,a2
 6a2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 6a6:	0006c603          	lbu	a2,0(a3)
 6aa:	fd06071b          	addiw	a4,a2,-48
 6ae:	0ff77713          	andi	a4,a4,255
 6b2:	fee5f1e3          	bgeu	a1,a4,694 <atoi+0x1e>
  return n;
}
 6b6:	6422                	ld	s0,8(sp)
 6b8:	0141                	addi	sp,sp,16
 6ba:	8082                	ret
  n = 0;
 6bc:	4501                	li	a0,0
 6be:	bfe5                	j	6b6 <atoi+0x40>

00000000000006c0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 6c0:	1141                	addi	sp,sp,-16
 6c2:	e422                	sd	s0,8(sp)
 6c4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 6c6:	02b57463          	bgeu	a0,a1,6ee <memmove+0x2e>
    while(n-- > 0)
 6ca:	00c05f63          	blez	a2,6e8 <memmove+0x28>
 6ce:	1602                	slli	a2,a2,0x20
 6d0:	9201                	srli	a2,a2,0x20
 6d2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 6d6:	872a                	mv	a4,a0
      *dst++ = *src++;
 6d8:	0585                	addi	a1,a1,1
 6da:	0705                	addi	a4,a4,1
 6dc:	fff5c683          	lbu	a3,-1(a1)
 6e0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 6e4:	fee79ae3          	bne	a5,a4,6d8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 6e8:	6422                	ld	s0,8(sp)
 6ea:	0141                	addi	sp,sp,16
 6ec:	8082                	ret
    dst += n;
 6ee:	00c50733          	add	a4,a0,a2
    src += n;
 6f2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 6f4:	fec05ae3          	blez	a2,6e8 <memmove+0x28>
 6f8:	fff6079b          	addiw	a5,a2,-1
 6fc:	1782                	slli	a5,a5,0x20
 6fe:	9381                	srli	a5,a5,0x20
 700:	fff7c793          	not	a5,a5
 704:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 706:	15fd                	addi	a1,a1,-1
 708:	177d                	addi	a4,a4,-1
 70a:	0005c683          	lbu	a3,0(a1)
 70e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 712:	fee79ae3          	bne	a5,a4,706 <memmove+0x46>
 716:	bfc9                	j	6e8 <memmove+0x28>

0000000000000718 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 718:	1141                	addi	sp,sp,-16
 71a:	e422                	sd	s0,8(sp)
 71c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 71e:	ca05                	beqz	a2,74e <memcmp+0x36>
 720:	fff6069b          	addiw	a3,a2,-1
 724:	1682                	slli	a3,a3,0x20
 726:	9281                	srli	a3,a3,0x20
 728:	0685                	addi	a3,a3,1
 72a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 72c:	00054783          	lbu	a5,0(a0)
 730:	0005c703          	lbu	a4,0(a1)
 734:	00e79863          	bne	a5,a4,744 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 738:	0505                	addi	a0,a0,1
    p2++;
 73a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 73c:	fed518e3          	bne	a0,a3,72c <memcmp+0x14>
  }
  return 0;
 740:	4501                	li	a0,0
 742:	a019                	j	748 <memcmp+0x30>
      return *p1 - *p2;
 744:	40e7853b          	subw	a0,a5,a4
}
 748:	6422                	ld	s0,8(sp)
 74a:	0141                	addi	sp,sp,16
 74c:	8082                	ret
  return 0;
 74e:	4501                	li	a0,0
 750:	bfe5                	j	748 <memcmp+0x30>

0000000000000752 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 752:	1141                	addi	sp,sp,-16
 754:	e406                	sd	ra,8(sp)
 756:	e022                	sd	s0,0(sp)
 758:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 75a:	00000097          	auipc	ra,0x0
 75e:	f66080e7          	jalr	-154(ra) # 6c0 <memmove>
}
 762:	60a2                	ld	ra,8(sp)
 764:	6402                	ld	s0,0(sp)
 766:	0141                	addi	sp,sp,16
 768:	8082                	ret

000000000000076a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 76a:	4885                	li	a7,1
 ecall
 76c:	00000073          	ecall
 ret
 770:	8082                	ret

0000000000000772 <exit>:
.global exit
exit:
 li a7, SYS_exit
 772:	4889                	li	a7,2
 ecall
 774:	00000073          	ecall
 ret
 778:	8082                	ret

000000000000077a <wait>:
.global wait
wait:
 li a7, SYS_wait
 77a:	488d                	li	a7,3
 ecall
 77c:	00000073          	ecall
 ret
 780:	8082                	ret

0000000000000782 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 782:	4891                	li	a7,4
 ecall
 784:	00000073          	ecall
 ret
 788:	8082                	ret

000000000000078a <read>:
.global read
read:
 li a7, SYS_read
 78a:	4895                	li	a7,5
 ecall
 78c:	00000073          	ecall
 ret
 790:	8082                	ret

0000000000000792 <write>:
.global write
write:
 li a7, SYS_write
 792:	48c1                	li	a7,16
 ecall
 794:	00000073          	ecall
 ret
 798:	8082                	ret

000000000000079a <close>:
.global close
close:
 li a7, SYS_close
 79a:	48d5                	li	a7,21
 ecall
 79c:	00000073          	ecall
 ret
 7a0:	8082                	ret

00000000000007a2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 7a2:	4899                	li	a7,6
 ecall
 7a4:	00000073          	ecall
 ret
 7a8:	8082                	ret

00000000000007aa <exec>:
.global exec
exec:
 li a7, SYS_exec
 7aa:	489d                	li	a7,7
 ecall
 7ac:	00000073          	ecall
 ret
 7b0:	8082                	ret

00000000000007b2 <open>:
.global open
open:
 li a7, SYS_open
 7b2:	48bd                	li	a7,15
 ecall
 7b4:	00000073          	ecall
 ret
 7b8:	8082                	ret

00000000000007ba <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 7ba:	48c5                	li	a7,17
 ecall
 7bc:	00000073          	ecall
 ret
 7c0:	8082                	ret

00000000000007c2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 7c2:	48c9                	li	a7,18
 ecall
 7c4:	00000073          	ecall
 ret
 7c8:	8082                	ret

00000000000007ca <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 7ca:	48a1                	li	a7,8
 ecall
 7cc:	00000073          	ecall
 ret
 7d0:	8082                	ret

00000000000007d2 <link>:
.global link
link:
 li a7, SYS_link
 7d2:	48cd                	li	a7,19
 ecall
 7d4:	00000073          	ecall
 ret
 7d8:	8082                	ret

00000000000007da <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 7da:	48d1                	li	a7,20
 ecall
 7dc:	00000073          	ecall
 ret
 7e0:	8082                	ret

00000000000007e2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 7e2:	48a5                	li	a7,9
 ecall
 7e4:	00000073          	ecall
 ret
 7e8:	8082                	ret

00000000000007ea <dup>:
.global dup
dup:
 li a7, SYS_dup
 7ea:	48a9                	li	a7,10
 ecall
 7ec:	00000073          	ecall
 ret
 7f0:	8082                	ret

00000000000007f2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 7f2:	48ad                	li	a7,11
 ecall
 7f4:	00000073          	ecall
 ret
 7f8:	8082                	ret

00000000000007fa <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 7fa:	48b1                	li	a7,12
 ecall
 7fc:	00000073          	ecall
 ret
 800:	8082                	ret

0000000000000802 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 802:	48b5                	li	a7,13
 ecall
 804:	00000073          	ecall
 ret
 808:	8082                	ret

000000000000080a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 80a:	48b9                	li	a7,14
 ecall
 80c:	00000073          	ecall
 ret
 810:	8082                	ret

0000000000000812 <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
 812:	48d9                	li	a7,22
 ecall
 814:	00000073          	ecall
 ret
 818:	8082                	ret

000000000000081a <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
 81a:	48dd                	li	a7,23
 ecall
 81c:	00000073          	ecall
 ret
 820:	8082                	ret

0000000000000822 <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
 822:	48e1                	li	a7,24
 ecall
 824:	00000073          	ecall
 ret
 828:	8082                	ret

000000000000082a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 82a:	1101                	addi	sp,sp,-32
 82c:	ec06                	sd	ra,24(sp)
 82e:	e822                	sd	s0,16(sp)
 830:	1000                	addi	s0,sp,32
 832:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 836:	4605                	li	a2,1
 838:	fef40593          	addi	a1,s0,-17
 83c:	00000097          	auipc	ra,0x0
 840:	f56080e7          	jalr	-170(ra) # 792 <write>
}
 844:	60e2                	ld	ra,24(sp)
 846:	6442                	ld	s0,16(sp)
 848:	6105                	addi	sp,sp,32
 84a:	8082                	ret

000000000000084c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 84c:	7139                	addi	sp,sp,-64
 84e:	fc06                	sd	ra,56(sp)
 850:	f822                	sd	s0,48(sp)
 852:	f426                	sd	s1,40(sp)
 854:	f04a                	sd	s2,32(sp)
 856:	ec4e                	sd	s3,24(sp)
 858:	0080                	addi	s0,sp,64
 85a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 85c:	c299                	beqz	a3,862 <printint+0x16>
 85e:	0805c863          	bltz	a1,8ee <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 862:	2581                	sext.w	a1,a1
  neg = 0;
 864:	4881                	li	a7,0
 866:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 86a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 86c:	2601                	sext.w	a2,a2
 86e:	00000517          	auipc	a0,0x0
 872:	74250513          	addi	a0,a0,1858 # fb0 <digits>
 876:	883a                	mv	a6,a4
 878:	2705                	addiw	a4,a4,1
 87a:	02c5f7bb          	remuw	a5,a1,a2
 87e:	1782                	slli	a5,a5,0x20
 880:	9381                	srli	a5,a5,0x20
 882:	97aa                	add	a5,a5,a0
 884:	0007c783          	lbu	a5,0(a5)
 888:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 88c:	0005879b          	sext.w	a5,a1
 890:	02c5d5bb          	divuw	a1,a1,a2
 894:	0685                	addi	a3,a3,1
 896:	fec7f0e3          	bgeu	a5,a2,876 <printint+0x2a>
  if(neg)
 89a:	00088b63          	beqz	a7,8b0 <printint+0x64>
    buf[i++] = '-';
 89e:	fd040793          	addi	a5,s0,-48
 8a2:	973e                	add	a4,a4,a5
 8a4:	02d00793          	li	a5,45
 8a8:	fef70823          	sb	a5,-16(a4)
 8ac:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 8b0:	02e05863          	blez	a4,8e0 <printint+0x94>
 8b4:	fc040793          	addi	a5,s0,-64
 8b8:	00e78933          	add	s2,a5,a4
 8bc:	fff78993          	addi	s3,a5,-1
 8c0:	99ba                	add	s3,s3,a4
 8c2:	377d                	addiw	a4,a4,-1
 8c4:	1702                	slli	a4,a4,0x20
 8c6:	9301                	srli	a4,a4,0x20
 8c8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 8cc:	fff94583          	lbu	a1,-1(s2)
 8d0:	8526                	mv	a0,s1
 8d2:	00000097          	auipc	ra,0x0
 8d6:	f58080e7          	jalr	-168(ra) # 82a <putc>
  while(--i >= 0)
 8da:	197d                	addi	s2,s2,-1
 8dc:	ff3918e3          	bne	s2,s3,8cc <printint+0x80>
}
 8e0:	70e2                	ld	ra,56(sp)
 8e2:	7442                	ld	s0,48(sp)
 8e4:	74a2                	ld	s1,40(sp)
 8e6:	7902                	ld	s2,32(sp)
 8e8:	69e2                	ld	s3,24(sp)
 8ea:	6121                	addi	sp,sp,64
 8ec:	8082                	ret
    x = -xx;
 8ee:	40b005bb          	negw	a1,a1
    neg = 1;
 8f2:	4885                	li	a7,1
    x = -xx;
 8f4:	bf8d                	j	866 <printint+0x1a>

00000000000008f6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 8f6:	7119                	addi	sp,sp,-128
 8f8:	fc86                	sd	ra,120(sp)
 8fa:	f8a2                	sd	s0,112(sp)
 8fc:	f4a6                	sd	s1,104(sp)
 8fe:	f0ca                	sd	s2,96(sp)
 900:	ecce                	sd	s3,88(sp)
 902:	e8d2                	sd	s4,80(sp)
 904:	e4d6                	sd	s5,72(sp)
 906:	e0da                	sd	s6,64(sp)
 908:	fc5e                	sd	s7,56(sp)
 90a:	f862                	sd	s8,48(sp)
 90c:	f466                	sd	s9,40(sp)
 90e:	f06a                	sd	s10,32(sp)
 910:	ec6e                	sd	s11,24(sp)
 912:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 914:	0005c903          	lbu	s2,0(a1)
 918:	18090f63          	beqz	s2,ab6 <vprintf+0x1c0>
 91c:	8aaa                	mv	s5,a0
 91e:	8b32                	mv	s6,a2
 920:	00158493          	addi	s1,a1,1
  state = 0;
 924:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 926:	02500a13          	li	s4,37
      if(c == 'd'){
 92a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 92e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 932:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 936:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 93a:	00000b97          	auipc	s7,0x0
 93e:	676b8b93          	addi	s7,s7,1654 # fb0 <digits>
 942:	a839                	j	960 <vprintf+0x6a>
        putc(fd, c);
 944:	85ca                	mv	a1,s2
 946:	8556                	mv	a0,s5
 948:	00000097          	auipc	ra,0x0
 94c:	ee2080e7          	jalr	-286(ra) # 82a <putc>
 950:	a019                	j	956 <vprintf+0x60>
    } else if(state == '%'){
 952:	01498f63          	beq	s3,s4,970 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 956:	0485                	addi	s1,s1,1
 958:	fff4c903          	lbu	s2,-1(s1)
 95c:	14090d63          	beqz	s2,ab6 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 960:	0009079b          	sext.w	a5,s2
    if(state == 0){
 964:	fe0997e3          	bnez	s3,952 <vprintf+0x5c>
      if(c == '%'){
 968:	fd479ee3          	bne	a5,s4,944 <vprintf+0x4e>
        state = '%';
 96c:	89be                	mv	s3,a5
 96e:	b7e5                	j	956 <vprintf+0x60>
      if(c == 'd'){
 970:	05878063          	beq	a5,s8,9b0 <vprintf+0xba>
      } else if(c == 'l') {
 974:	05978c63          	beq	a5,s9,9cc <vprintf+0xd6>
      } else if(c == 'x') {
 978:	07a78863          	beq	a5,s10,9e8 <vprintf+0xf2>
      } else if(c == 'p') {
 97c:	09b78463          	beq	a5,s11,a04 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 980:	07300713          	li	a4,115
 984:	0ce78663          	beq	a5,a4,a50 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 988:	06300713          	li	a4,99
 98c:	0ee78e63          	beq	a5,a4,a88 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 990:	11478863          	beq	a5,s4,aa0 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 994:	85d2                	mv	a1,s4
 996:	8556                	mv	a0,s5
 998:	00000097          	auipc	ra,0x0
 99c:	e92080e7          	jalr	-366(ra) # 82a <putc>
        putc(fd, c);
 9a0:	85ca                	mv	a1,s2
 9a2:	8556                	mv	a0,s5
 9a4:	00000097          	auipc	ra,0x0
 9a8:	e86080e7          	jalr	-378(ra) # 82a <putc>
      }
      state = 0;
 9ac:	4981                	li	s3,0
 9ae:	b765                	j	956 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 9b0:	008b0913          	addi	s2,s6,8
 9b4:	4685                	li	a3,1
 9b6:	4629                	li	a2,10
 9b8:	000b2583          	lw	a1,0(s6)
 9bc:	8556                	mv	a0,s5
 9be:	00000097          	auipc	ra,0x0
 9c2:	e8e080e7          	jalr	-370(ra) # 84c <printint>
 9c6:	8b4a                	mv	s6,s2
      state = 0;
 9c8:	4981                	li	s3,0
 9ca:	b771                	j	956 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 9cc:	008b0913          	addi	s2,s6,8
 9d0:	4681                	li	a3,0
 9d2:	4629                	li	a2,10
 9d4:	000b2583          	lw	a1,0(s6)
 9d8:	8556                	mv	a0,s5
 9da:	00000097          	auipc	ra,0x0
 9de:	e72080e7          	jalr	-398(ra) # 84c <printint>
 9e2:	8b4a                	mv	s6,s2
      state = 0;
 9e4:	4981                	li	s3,0
 9e6:	bf85                	j	956 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 9e8:	008b0913          	addi	s2,s6,8
 9ec:	4681                	li	a3,0
 9ee:	4641                	li	a2,16
 9f0:	000b2583          	lw	a1,0(s6)
 9f4:	8556                	mv	a0,s5
 9f6:	00000097          	auipc	ra,0x0
 9fa:	e56080e7          	jalr	-426(ra) # 84c <printint>
 9fe:	8b4a                	mv	s6,s2
      state = 0;
 a00:	4981                	li	s3,0
 a02:	bf91                	j	956 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 a04:	008b0793          	addi	a5,s6,8
 a08:	f8f43423          	sd	a5,-120(s0)
 a0c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 a10:	03000593          	li	a1,48
 a14:	8556                	mv	a0,s5
 a16:	00000097          	auipc	ra,0x0
 a1a:	e14080e7          	jalr	-492(ra) # 82a <putc>
  putc(fd, 'x');
 a1e:	85ea                	mv	a1,s10
 a20:	8556                	mv	a0,s5
 a22:	00000097          	auipc	ra,0x0
 a26:	e08080e7          	jalr	-504(ra) # 82a <putc>
 a2a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a2c:	03c9d793          	srli	a5,s3,0x3c
 a30:	97de                	add	a5,a5,s7
 a32:	0007c583          	lbu	a1,0(a5)
 a36:	8556                	mv	a0,s5
 a38:	00000097          	auipc	ra,0x0
 a3c:	df2080e7          	jalr	-526(ra) # 82a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a40:	0992                	slli	s3,s3,0x4
 a42:	397d                	addiw	s2,s2,-1
 a44:	fe0914e3          	bnez	s2,a2c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 a48:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 a4c:	4981                	li	s3,0
 a4e:	b721                	j	956 <vprintf+0x60>
        s = va_arg(ap, char*);
 a50:	008b0993          	addi	s3,s6,8
 a54:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 a58:	02090163          	beqz	s2,a7a <vprintf+0x184>
        while(*s != 0){
 a5c:	00094583          	lbu	a1,0(s2)
 a60:	c9a1                	beqz	a1,ab0 <vprintf+0x1ba>
          putc(fd, *s);
 a62:	8556                	mv	a0,s5
 a64:	00000097          	auipc	ra,0x0
 a68:	dc6080e7          	jalr	-570(ra) # 82a <putc>
          s++;
 a6c:	0905                	addi	s2,s2,1
        while(*s != 0){
 a6e:	00094583          	lbu	a1,0(s2)
 a72:	f9e5                	bnez	a1,a62 <vprintf+0x16c>
        s = va_arg(ap, char*);
 a74:	8b4e                	mv	s6,s3
      state = 0;
 a76:	4981                	li	s3,0
 a78:	bdf9                	j	956 <vprintf+0x60>
          s = "(null)";
 a7a:	00000917          	auipc	s2,0x0
 a7e:	52e90913          	addi	s2,s2,1326 # fa8 <malloc+0x3e8>
        while(*s != 0){
 a82:	02800593          	li	a1,40
 a86:	bff1                	j	a62 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 a88:	008b0913          	addi	s2,s6,8
 a8c:	000b4583          	lbu	a1,0(s6)
 a90:	8556                	mv	a0,s5
 a92:	00000097          	auipc	ra,0x0
 a96:	d98080e7          	jalr	-616(ra) # 82a <putc>
 a9a:	8b4a                	mv	s6,s2
      state = 0;
 a9c:	4981                	li	s3,0
 a9e:	bd65                	j	956 <vprintf+0x60>
        putc(fd, c);
 aa0:	85d2                	mv	a1,s4
 aa2:	8556                	mv	a0,s5
 aa4:	00000097          	auipc	ra,0x0
 aa8:	d86080e7          	jalr	-634(ra) # 82a <putc>
      state = 0;
 aac:	4981                	li	s3,0
 aae:	b565                	j	956 <vprintf+0x60>
        s = va_arg(ap, char*);
 ab0:	8b4e                	mv	s6,s3
      state = 0;
 ab2:	4981                	li	s3,0
 ab4:	b54d                	j	956 <vprintf+0x60>
    }
  }
}
 ab6:	70e6                	ld	ra,120(sp)
 ab8:	7446                	ld	s0,112(sp)
 aba:	74a6                	ld	s1,104(sp)
 abc:	7906                	ld	s2,96(sp)
 abe:	69e6                	ld	s3,88(sp)
 ac0:	6a46                	ld	s4,80(sp)
 ac2:	6aa6                	ld	s5,72(sp)
 ac4:	6b06                	ld	s6,64(sp)
 ac6:	7be2                	ld	s7,56(sp)
 ac8:	7c42                	ld	s8,48(sp)
 aca:	7ca2                	ld	s9,40(sp)
 acc:	7d02                	ld	s10,32(sp)
 ace:	6de2                	ld	s11,24(sp)
 ad0:	6109                	addi	sp,sp,128
 ad2:	8082                	ret

0000000000000ad4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 ad4:	715d                	addi	sp,sp,-80
 ad6:	ec06                	sd	ra,24(sp)
 ad8:	e822                	sd	s0,16(sp)
 ada:	1000                	addi	s0,sp,32
 adc:	e010                	sd	a2,0(s0)
 ade:	e414                	sd	a3,8(s0)
 ae0:	e818                	sd	a4,16(s0)
 ae2:	ec1c                	sd	a5,24(s0)
 ae4:	03043023          	sd	a6,32(s0)
 ae8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 aec:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 af0:	8622                	mv	a2,s0
 af2:	00000097          	auipc	ra,0x0
 af6:	e04080e7          	jalr	-508(ra) # 8f6 <vprintf>
}
 afa:	60e2                	ld	ra,24(sp)
 afc:	6442                	ld	s0,16(sp)
 afe:	6161                	addi	sp,sp,80
 b00:	8082                	ret

0000000000000b02 <printf>:

void
printf(const char *fmt, ...)
{
 b02:	711d                	addi	sp,sp,-96
 b04:	ec06                	sd	ra,24(sp)
 b06:	e822                	sd	s0,16(sp)
 b08:	1000                	addi	s0,sp,32
 b0a:	e40c                	sd	a1,8(s0)
 b0c:	e810                	sd	a2,16(s0)
 b0e:	ec14                	sd	a3,24(s0)
 b10:	f018                	sd	a4,32(s0)
 b12:	f41c                	sd	a5,40(s0)
 b14:	03043823          	sd	a6,48(s0)
 b18:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b1c:	00840613          	addi	a2,s0,8
 b20:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 b24:	85aa                	mv	a1,a0
 b26:	4505                	li	a0,1
 b28:	00000097          	auipc	ra,0x0
 b2c:	dce080e7          	jalr	-562(ra) # 8f6 <vprintf>
}
 b30:	60e2                	ld	ra,24(sp)
 b32:	6442                	ld	s0,16(sp)
 b34:	6125                	addi	sp,sp,96
 b36:	8082                	ret

0000000000000b38 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b38:	1141                	addi	sp,sp,-16
 b3a:	e422                	sd	s0,8(sp)
 b3c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b3e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b42:	00000797          	auipc	a5,0x0
 b46:	4867b783          	ld	a5,1158(a5) # fc8 <freep>
 b4a:	a805                	j	b7a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b4c:	4618                	lw	a4,8(a2)
 b4e:	9db9                	addw	a1,a1,a4
 b50:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b54:	6398                	ld	a4,0(a5)
 b56:	6318                	ld	a4,0(a4)
 b58:	fee53823          	sd	a4,-16(a0)
 b5c:	a091                	j	ba0 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b5e:	ff852703          	lw	a4,-8(a0)
 b62:	9e39                	addw	a2,a2,a4
 b64:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 b66:	ff053703          	ld	a4,-16(a0)
 b6a:	e398                	sd	a4,0(a5)
 b6c:	a099                	j	bb2 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b6e:	6398                	ld	a4,0(a5)
 b70:	00e7e463          	bltu	a5,a4,b78 <free+0x40>
 b74:	00e6ea63          	bltu	a3,a4,b88 <free+0x50>
{
 b78:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b7a:	fed7fae3          	bgeu	a5,a3,b6e <free+0x36>
 b7e:	6398                	ld	a4,0(a5)
 b80:	00e6e463          	bltu	a3,a4,b88 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b84:	fee7eae3          	bltu	a5,a4,b78 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 b88:	ff852583          	lw	a1,-8(a0)
 b8c:	6390                	ld	a2,0(a5)
 b8e:	02059813          	slli	a6,a1,0x20
 b92:	01c85713          	srli	a4,a6,0x1c
 b96:	9736                	add	a4,a4,a3
 b98:	fae60ae3          	beq	a2,a4,b4c <free+0x14>
    bp->s.ptr = p->s.ptr;
 b9c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 ba0:	4790                	lw	a2,8(a5)
 ba2:	02061593          	slli	a1,a2,0x20
 ba6:	01c5d713          	srli	a4,a1,0x1c
 baa:	973e                	add	a4,a4,a5
 bac:	fae689e3          	beq	a3,a4,b5e <free+0x26>
  } else
    p->s.ptr = bp;
 bb0:	e394                	sd	a3,0(a5)
  freep = p;
 bb2:	00000717          	auipc	a4,0x0
 bb6:	40f73b23          	sd	a5,1046(a4) # fc8 <freep>
}
 bba:	6422                	ld	s0,8(sp)
 bbc:	0141                	addi	sp,sp,16
 bbe:	8082                	ret

0000000000000bc0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 bc0:	7139                	addi	sp,sp,-64
 bc2:	fc06                	sd	ra,56(sp)
 bc4:	f822                	sd	s0,48(sp)
 bc6:	f426                	sd	s1,40(sp)
 bc8:	f04a                	sd	s2,32(sp)
 bca:	ec4e                	sd	s3,24(sp)
 bcc:	e852                	sd	s4,16(sp)
 bce:	e456                	sd	s5,8(sp)
 bd0:	e05a                	sd	s6,0(sp)
 bd2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bd4:	02051493          	slli	s1,a0,0x20
 bd8:	9081                	srli	s1,s1,0x20
 bda:	04bd                	addi	s1,s1,15
 bdc:	8091                	srli	s1,s1,0x4
 bde:	0014899b          	addiw	s3,s1,1
 be2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 be4:	00000517          	auipc	a0,0x0
 be8:	3e453503          	ld	a0,996(a0) # fc8 <freep>
 bec:	c515                	beqz	a0,c18 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bf0:	4798                	lw	a4,8(a5)
 bf2:	02977f63          	bgeu	a4,s1,c30 <malloc+0x70>
 bf6:	8a4e                	mv	s4,s3
 bf8:	0009871b          	sext.w	a4,s3
 bfc:	6685                	lui	a3,0x1
 bfe:	00d77363          	bgeu	a4,a3,c04 <malloc+0x44>
 c02:	6a05                	lui	s4,0x1
 c04:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 c08:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 c0c:	00000917          	auipc	s2,0x0
 c10:	3bc90913          	addi	s2,s2,956 # fc8 <freep>
  if(p == (char*)-1)
 c14:	5afd                	li	s5,-1
 c16:	a895                	j	c8a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 c18:	00000797          	auipc	a5,0x0
 c1c:	3b878793          	addi	a5,a5,952 # fd0 <base>
 c20:	00000717          	auipc	a4,0x0
 c24:	3af73423          	sd	a5,936(a4) # fc8 <freep>
 c28:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 c2a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 c2e:	b7e1                	j	bf6 <malloc+0x36>
      if(p->s.size == nunits)
 c30:	02e48c63          	beq	s1,a4,c68 <malloc+0xa8>
        p->s.size -= nunits;
 c34:	4137073b          	subw	a4,a4,s3
 c38:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c3a:	02071693          	slli	a3,a4,0x20
 c3e:	01c6d713          	srli	a4,a3,0x1c
 c42:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c44:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c48:	00000717          	auipc	a4,0x0
 c4c:	38a73023          	sd	a0,896(a4) # fc8 <freep>
      return (void*)(p + 1);
 c50:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 c54:	70e2                	ld	ra,56(sp)
 c56:	7442                	ld	s0,48(sp)
 c58:	74a2                	ld	s1,40(sp)
 c5a:	7902                	ld	s2,32(sp)
 c5c:	69e2                	ld	s3,24(sp)
 c5e:	6a42                	ld	s4,16(sp)
 c60:	6aa2                	ld	s5,8(sp)
 c62:	6b02                	ld	s6,0(sp)
 c64:	6121                	addi	sp,sp,64
 c66:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 c68:	6398                	ld	a4,0(a5)
 c6a:	e118                	sd	a4,0(a0)
 c6c:	bff1                	j	c48 <malloc+0x88>
  hp->s.size = nu;
 c6e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c72:	0541                	addi	a0,a0,16
 c74:	00000097          	auipc	ra,0x0
 c78:	ec4080e7          	jalr	-316(ra) # b38 <free>
  return freep;
 c7c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c80:	d971                	beqz	a0,c54 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c82:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c84:	4798                	lw	a4,8(a5)
 c86:	fa9775e3          	bgeu	a4,s1,c30 <malloc+0x70>
    if(p == freep)
 c8a:	00093703          	ld	a4,0(s2)
 c8e:	853e                	mv	a0,a5
 c90:	fef719e3          	bne	a4,a5,c82 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 c94:	8552                	mv	a0,s4
 c96:	00000097          	auipc	ra,0x0
 c9a:	b64080e7          	jalr	-1180(ra) # 7fa <sbrk>
  if(p == (char*)-1)
 c9e:	fd5518e3          	bne	a0,s5,c6e <malloc+0xae>
        return 0;
 ca2:	4501                	li	a0,0
 ca4:	bf45                	j	c54 <malloc+0x94>
