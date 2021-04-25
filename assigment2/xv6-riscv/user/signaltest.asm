
user/_signaltest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <sig_handler>:
};



void
sig_handler(int signum){
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
    char st[3] = "wap";
   8:	6799                	lui	a5,0x6
   a:	17778793          	addi	a5,a5,375 # 6177 <__global_pointer$+0x4aae>
   e:	fef41423          	sh	a5,-24(s0)
  12:	07000793          	li	a5,112
  16:	fef40523          	sb	a5,-22(s0)
    write(1, st, 3);
  1a:	460d                	li	a2,3
  1c:	fe840593          	addi	a1,s0,-24
  20:	4505                	li	a0,1
  22:	00000097          	auipc	ra,0x0
  26:	69a080e7          	jalr	1690(ra) # 6bc <write>
    return;
}
  2a:	60e2                	ld	ra,24(sp)
  2c:	6442                	ld	s0,16(sp)
  2e:	6105                	addi	sp,sp,32
  30:	8082                	ret

0000000000000032 <test_sigkill>:

void 
test_sigkill(){//
  32:	1101                	addi	sp,sp,-32
  34:	ec06                	sd	ra,24(sp)
  36:	e822                	sd	s0,16(sp)
  38:	e426                	sd	s1,8(sp)
  3a:	e04a                	sd	s2,0(sp)
  3c:	1000                	addi	s0,sp,32
   int pid = fork();
  3e:	00000097          	auipc	ra,0x0
  42:	656080e7          	jalr	1622(ra) # 694 <fork>
    if(pid==0){
  46:	e905                	bnez	a0,76 <test_sigkill+0x44>
        sleep(5);
  48:	4515                	li	a0,5
  4a:	00000097          	auipc	ra,0x0
  4e:	6e2080e7          	jalr	1762(ra) # 72c <sleep>
  52:	44f9                	li	s1,30
        for(int i=0;i<30;i++)
            printf("about to get killed\n");
  54:	00001917          	auipc	s2,0x1
  58:	b7c90913          	addi	s2,s2,-1156 # bd0 <malloc+0xe6>
  5c:	854a                	mv	a0,s2
  5e:	00001097          	auipc	ra,0x1
  62:	9ce080e7          	jalr	-1586(ra) # a2c <printf>
        for(int i=0;i<30;i++)
  66:	34fd                	addiw	s1,s1,-1
  68:	f8f5                	bnez	s1,5c <test_sigkill+0x2a>
        wait(0);
        printf("parent: child is dead\n");
        sleep(10);
        exit(0);
    }
}
  6a:	60e2                	ld	ra,24(sp)
  6c:	6442                	ld	s0,16(sp)
  6e:	64a2                	ld	s1,8(sp)
  70:	6902                	ld	s2,0(sp)
  72:	6105                	addi	sp,sp,32
  74:	8082                	ret
  76:	84aa                	mv	s1,a0
        printf("parent send signal to to kill child\n");
  78:	00001517          	auipc	a0,0x1
  7c:	b7050513          	addi	a0,a0,-1168 # be8 <malloc+0xfe>
  80:	00001097          	auipc	ra,0x1
  84:	9ac080e7          	jalr	-1620(ra) # a2c <printf>
        printf("kill ret= %d\n",kill(pid, SIGKILL));
  88:	45a5                	li	a1,9
  8a:	8526                	mv	a0,s1
  8c:	00000097          	auipc	ra,0x0
  90:	640080e7          	jalr	1600(ra) # 6cc <kill>
  94:	85aa                	mv	a1,a0
  96:	00001517          	auipc	a0,0x1
  9a:	b7a50513          	addi	a0,a0,-1158 # c10 <malloc+0x126>
  9e:	00001097          	auipc	ra,0x1
  a2:	98e080e7          	jalr	-1650(ra) # a2c <printf>
        printf("parent wait for child\n");
  a6:	00001517          	auipc	a0,0x1
  aa:	b7a50513          	addi	a0,a0,-1158 # c20 <malloc+0x136>
  ae:	00001097          	auipc	ra,0x1
  b2:	97e080e7          	jalr	-1666(ra) # a2c <printf>
        wait(0);
  b6:	4501                	li	a0,0
  b8:	00000097          	auipc	ra,0x0
  bc:	5ec080e7          	jalr	1516(ra) # 6a4 <wait>
        printf("parent: child is dead\n");
  c0:	00001517          	auipc	a0,0x1
  c4:	b7850513          	addi	a0,a0,-1160 # c38 <malloc+0x14e>
  c8:	00001097          	auipc	ra,0x1
  cc:	964080e7          	jalr	-1692(ra) # a2c <printf>
        sleep(10);
  d0:	4529                	li	a0,10
  d2:	00000097          	auipc	ra,0x0
  d6:	65a080e7          	jalr	1626(ra) # 72c <sleep>
        exit(0);
  da:	4501                	li	a0,0
  dc:	00000097          	auipc	ra,0x0
  e0:	5c0080e7          	jalr	1472(ra) # 69c <exit>

00000000000000e4 <test_stop_cont>:
void
test_stop_cont(){
  e4:	7179                	addi	sp,sp,-48
  e6:	f406                	sd	ra,40(sp)
  e8:	f022                	sd	s0,32(sp)
  ea:	ec26                	sd	s1,24(sp)
  ec:	e84a                	sd	s2,16(sp)
  ee:	e44e                	sd	s3,8(sp)
  f0:	1800                	addi	s0,sp,48
    int pid = fork();
  f2:	00000097          	auipc	ra,0x0
  f6:	5a2080e7          	jalr	1442(ra) # 694 <fork>
  fa:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
  fc:	e915                	bnez	a0,130 <test_stop_cont+0x4c>
        sleep(2);
  fe:	4509                	li	a0,2
 100:	00000097          	auipc	ra,0x0
 104:	62c080e7          	jalr	1580(ra) # 72c <sleep>
        for(i=0;i<500;i++)
            printf("%d\n ", i);
 108:	00001997          	auipc	s3,0x1
 10c:	b4898993          	addi	s3,s3,-1208 # c50 <malloc+0x166>
        for(i=0;i<500;i++)
 110:	1f400913          	li	s2,500
            printf("%d\n ", i);
 114:	85a6                	mv	a1,s1
 116:	854e                	mv	a0,s3
 118:	00001097          	auipc	ra,0x1
 11c:	914080e7          	jalr	-1772(ra) # a2c <printf>
        for(i=0;i<500;i++)
 120:	2485                	addiw	s1,s1,1
 122:	ff2499e3          	bne	s1,s2,114 <test_stop_cont+0x30>
        exit(0);
 126:	4501                	li	a0,0
 128:	00000097          	auipc	ra,0x0
 12c:	574080e7          	jalr	1396(ra) # 69c <exit>
    }else{
        printf("son pid=%d, dad pid=%d\n",pid, getpid());
 130:	00000097          	auipc	ra,0x0
 134:	5ec080e7          	jalr	1516(ra) # 71c <getpid>
 138:	862a                	mv	a2,a0
 13a:	85a6                	mv	a1,s1
 13c:	00001517          	auipc	a0,0x1
 140:	b1c50513          	addi	a0,a0,-1252 # c58 <malloc+0x16e>
 144:	00001097          	auipc	ra,0x1
 148:	8e8080e7          	jalr	-1816(ra) # a2c <printf>
        sleep(5);
 14c:	4515                	li	a0,5
 14e:	00000097          	auipc	ra,0x0
 152:	5de080e7          	jalr	1502(ra) # 72c <sleep>
        printf("parent send stop ret= %d\n",kill(pid, SIGSTOP));
 156:	45c5                	li	a1,17
 158:	8526                	mv	a0,s1
 15a:	00000097          	auipc	ra,0x0
 15e:	572080e7          	jalr	1394(ra) # 6cc <kill>
 162:	85aa                	mv	a1,a0
 164:	00001517          	auipc	a0,0x1
 168:	b0c50513          	addi	a0,a0,-1268 # c70 <malloc+0x186>
 16c:	00001097          	auipc	ra,0x1
 170:	8c0080e7          	jalr	-1856(ra) # a2c <printf>
        sleep(100);
 174:	06400513          	li	a0,100
 178:	00000097          	auipc	ra,0x0
 17c:	5b4080e7          	jalr	1460(ra) # 72c <sleep>
        printf("parent send continue ret= %d\n",kill(pid, SIGCONT));
 180:	45cd                	li	a1,19
 182:	8526                	mv	a0,s1
 184:	00000097          	auipc	ra,0x0
 188:	548080e7          	jalr	1352(ra) # 6cc <kill>
 18c:	85aa                	mv	a1,a0
 18e:	00001517          	auipc	a0,0x1
 192:	b0250513          	addi	a0,a0,-1278 # c90 <malloc+0x1a6>
 196:	00001097          	auipc	ra,0x1
 19a:	896080e7          	jalr	-1898(ra) # a2c <printf>
        wait(0);
 19e:	4501                	li	a0,0
 1a0:	00000097          	auipc	ra,0x0
 1a4:	504080e7          	jalr	1284(ra) # 6a4 <wait>
        // for(int i=0;i<100;i++)
        //  printf("parent..");
        sleep(10);
 1a8:	4529                	li	a0,10
 1aa:	00000097          	auipc	ra,0x0
 1ae:	582080e7          	jalr	1410(ra) # 72c <sleep>
        exit(0);
 1b2:	4501                	li	a0,0
 1b4:	00000097          	auipc	ra,0x0
 1b8:	4e8080e7          	jalr	1256(ra) # 69c <exit>

00000000000001bc <test_stop_contX>:
    }
}
void
test_stop_contX(){
 1bc:	1101                	addi	sp,sp,-32
 1be:	ec06                	sd	ra,24(sp)
 1c0:	e822                	sd	s0,16(sp)
 1c2:	e426                	sd	s1,8(sp)
 1c4:	e04a                	sd	s2,0(sp)
 1c6:	1000                	addi	s0,sp,32
    int pid = fork();
 1c8:	00000097          	auipc	ra,0x0
 1cc:	4cc080e7          	jalr	1228(ra) # 694 <fork>
    if(pid==0){
 1d0:	e505                	bnez	a0,1f8 <test_stop_contX+0x3c>
        sleep(1);
 1d2:	4505                	li	a0,1
 1d4:	00000097          	auipc	ra,0x0
 1d8:	558080e7          	jalr	1368(ra) # 72c <sleep>
 1dc:	06400493          	li	s1,100
        for(int i=0;i<100;i++)
            printf("child..\n ");
 1e0:	00001917          	auipc	s2,0x1
 1e4:	ad090913          	addi	s2,s2,-1328 # cb0 <malloc+0x1c6>
 1e8:	854a                	mv	a0,s2
 1ea:	00001097          	auipc	ra,0x1
 1ee:	842080e7          	jalr	-1982(ra) # a2c <printf>
        for(int i=0;i<100;i++)
 1f2:	34fd                	addiw	s1,s1,-1
 1f4:	f8f5                	bnez	s1,1e8 <test_stop_contX+0x2c>
 1f6:	a049                	j	278 <test_stop_contX+0xbc>
 1f8:	84aa                	mv	s1,a0
    }
    else{
        printf("son pid=%d, dad pid=%d\n",pid,getpid());
 1fa:	00000097          	auipc	ra,0x0
 1fe:	522080e7          	jalr	1314(ra) # 71c <getpid>
 202:	862a                	mv	a2,a0
 204:	85a6                	mv	a1,s1
 206:	00001517          	auipc	a0,0x1
 20a:	a5250513          	addi	a0,a0,-1454 # c58 <malloc+0x16e>
 20e:	00001097          	auipc	ra,0x1
 212:	81e080e7          	jalr	-2018(ra) # a2c <printf>
        printf("parent send signal to to stop child\n");
 216:	00001517          	auipc	a0,0x1
 21a:	aaa50513          	addi	a0,a0,-1366 # cc0 <malloc+0x1d6>
 21e:	00001097          	auipc	ra,0x1
 222:	80e080e7          	jalr	-2034(ra) # a2c <printf>
        printf("sigstop ret= %d\n",kill(pid, SIGSTOP));
 226:	45c5                	li	a1,17
 228:	8526                	mv	a0,s1
 22a:	00000097          	auipc	ra,0x0
 22e:	4a2080e7          	jalr	1186(ra) # 6cc <kill>
 232:	85aa                	mv	a1,a0
 234:	00001517          	auipc	a0,0x1
 238:	ab450513          	addi	a0,a0,-1356 # ce8 <malloc+0x1fe>
 23c:	00000097          	auipc	ra,0x0
 240:	7f0080e7          	jalr	2032(ra) # a2c <printf>
        // printf("parent: go to sleep \n");
        // sleep(5);
        // for(int i=0;i<10;i++)
        //     printf("parent..");
        printf("parent send signal to to continue child\n");
 244:	00001517          	auipc	a0,0x1
 248:	abc50513          	addi	a0,a0,-1348 # d00 <malloc+0x216>
 24c:	00000097          	auipc	ra,0x0
 250:	7e0080e7          	jalr	2016(ra) # a2c <printf>
 254:	06400493          	li	s1,100
        // printf("sigcont ret= %d\n",kill(pid, SIGCONT));
        for(int i=0;i<100;i++)
            printf("parent..");
 258:	00001917          	auipc	s2,0x1
 25c:	ad890913          	addi	s2,s2,-1320 # d30 <malloc+0x246>
 260:	854a                	mv	a0,s2
 262:	00000097          	auipc	ra,0x0
 266:	7ca080e7          	jalr	1994(ra) # a2c <printf>
        for(int i=0;i<100;i++)
 26a:	34fd                	addiw	s1,s1,-1
 26c:	f8f5                	bnez	s1,260 <test_stop_contX+0xa4>
        sleep(10);
 26e:	4529                	li	a0,10
 270:	00000097          	auipc	ra,0x0
 274:	4bc080e7          	jalr	1212(ra) # 72c <sleep>
        // exit(0);
    }
    

}
 278:	60e2                	ld	ra,24(sp)
 27a:	6442                	ld	s0,16(sp)
 27c:	64a2                	ld	s1,8(sp)
 27e:	6902                	ld	s2,0(sp)
 280:	6105                	addi	sp,sp,32
 282:	8082                	ret

0000000000000284 <test_usersig>:
void 
test_usersig(){//
 284:	7179                	addi	sp,sp,-48
 286:	f406                	sd	ra,40(sp)
 288:	f022                	sd	s0,32(sp)
 28a:	1800                	addi	s0,sp,48
   int pid = fork();
 28c:	00000097          	auipc	ra,0x0
 290:	408080e7          	jalr	1032(ra) # 694 <fork>
    if(pid==0){
 294:	e515                	bnez	a0,2c0 <test_usersig+0x3c>
        struct sigaction act;
        act.sa_handler = &sig_handler;
 296:	00000797          	auipc	a5,0x0
 29a:	d6a78793          	addi	a5,a5,-662 # 0 <sig_handler>
 29e:	fcf43823          	sd	a5,-48(s0)
        act.sigmask = 0;
 2a2:	fc042c23          	sw	zero,-40(s0)
        struct sigaction oldact;
        sigaction(3,&act,&oldact);
 2a6:	fe040613          	addi	a2,s0,-32
 2aa:	fd040593          	addi	a1,s0,-48
 2ae:	450d                	li	a0,3
 2b0:	00000097          	auipc	ra,0x0
 2b4:	494080e7          	jalr	1172(ra) # 744 <sigaction>
    }
    else{
      sleep(10);

    }
}
 2b8:	70a2                	ld	ra,40(sp)
 2ba:	7402                	ld	s0,32(sp)
 2bc:	6145                	addi	sp,sp,48
 2be:	8082                	ret
      sleep(10);
 2c0:	4529                	li	a0,10
 2c2:	00000097          	auipc	ra,0x0
 2c6:	46a080e7          	jalr	1130(ra) # 72c <sleep>
}
 2ca:	b7fd                	j	2b8 <test_usersig+0x34>

00000000000002cc <test_block>:
void 
test_block(){//parent block 22 child block 23 
 2cc:	7179                	addi	sp,sp,-48
 2ce:	f406                	sd	ra,40(sp)
 2d0:	f022                	sd	s0,32(sp)
 2d2:	ec26                	sd	s1,24(sp)
 2d4:	e84a                	sd	s2,16(sp)
 2d6:	e44e                	sd	s3,8(sp)
 2d8:	1800                	addi	s0,sp,48
//          child get both signal and need do block the both

    int signum1=22;
    int signum2=23;
    int ans=sigprocmask(1<<signum1);
 2da:	00400537          	lui	a0,0x400
 2de:	00000097          	auipc	ra,0x0
 2e2:	45e080e7          	jalr	1118(ra) # 73c <sigprocmask>
    printf("got %d from calling to sigprocmask\n",ans);
 2e6:	0005059b          	sext.w	a1,a0
 2ea:	00001517          	auipc	a0,0x1
 2ee:	a5650513          	addi	a0,a0,-1450 # d40 <malloc+0x256>
 2f2:	00000097          	auipc	ra,0x0
 2f6:	73a080e7          	jalr	1850(ra) # a2c <printf>
    int pid=fork();
 2fa:	00000097          	auipc	ra,0x0
 2fe:	39a080e7          	jalr	922(ra) # 694 <fork>
 302:	84aa                	mv	s1,a0
    if(pid==0){
 304:	e515                	bnez	a0,330 <test_block+0x64>
        // ans=sigprocmask(1<<signum2);
        // printf("child got %d from calling to sigprocmask\n",ans);
        sleep(3);
 306:	450d                	li	a0,3
 308:	00000097          	auipc	ra,0x0
 30c:	424080e7          	jalr	1060(ra) # 72c <sleep>
        for(int i=0;i<100;i++){
            printf("child blocking signal @d :-)\n",i);
 310:	00001997          	auipc	s3,0x1
 314:	a5898993          	addi	s3,s3,-1448 # d68 <malloc+0x27e>
        for(int i=0;i<100;i++){
 318:	06400913          	li	s2,100
            printf("child blocking signal @d :-)\n",i);
 31c:	85a6                	mv	a1,s1
 31e:	854e                	mv	a0,s3
 320:	00000097          	auipc	ra,0x0
 324:	70c080e7          	jalr	1804(ra) # a2c <printf>
        for(int i=0;i<100;i++){
 328:	2485                	addiw	s1,s1,1
 32a:	ff2499e3          	bne	s1,s2,31c <test_block+0x50>
 32e:	a089                	j	370 <test_block+0xa4>
        }

    }else{
        sleep(1);//wait for child to block sig
 330:	4505                	li	a0,1
 332:	00000097          	auipc	ra,0x0
 336:	3fa080e7          	jalr	1018(ra) # 72c <sleep>
        kill(pid,signum1);
 33a:	45d9                	li	a1,22
 33c:	8526                	mv	a0,s1
 33e:	00000097          	auipc	ra,0x0
 342:	38e080e7          	jalr	910(ra) # 6cc <kill>
        printf("parent: sent signal 22 to child ->child shuld block\n");
 346:	00001517          	auipc	a0,0x1
 34a:	a4250513          	addi	a0,a0,-1470 # d88 <malloc+0x29e>
 34e:	00000097          	auipc	ra,0x0
 352:	6de080e7          	jalr	1758(ra) # a2c <printf>
        // kill(pid,signum2);
        printf("parent: sent signal 23 to child ->child shuld block\n");
 356:	00001517          	auipc	a0,0x1
 35a:	a6a50513          	addi	a0,a0,-1430 # dc0 <malloc+0x2d6>
 35e:	00000097          	auipc	ra,0x0
 362:	6ce080e7          	jalr	1742(ra) # a2c <printf>
        wait(0);
 366:	4501                	li	a0,0
 368:	00000097          	auipc	ra,0x0
 36c:	33c080e7          	jalr	828(ra) # 6a4 <wait>
    }
    exit(0);
 370:	4501                	li	a0,0
 372:	00000097          	auipc	ra,0x0
 376:	32a080e7          	jalr	810(ra) # 69c <exit>

000000000000037a <test_ignore>:
}

void 
test_ignore(){
 37a:	7139                	addi	sp,sp,-64
 37c:	fc06                	sd	ra,56(sp)
 37e:	f822                	sd	s0,48(sp)
 380:	f426                	sd	s1,40(sp)
 382:	f04a                	sd	s2,32(sp)
 384:	0080                	addi	s0,sp,64
    int pid= fork();
 386:	00000097          	auipc	ra,0x0
 38a:	30e080e7          	jalr	782(ra) # 694 <fork>
    int signum=22;
    if(pid==0){
 38e:	ed31                	bnez	a0,3ea <test_ignore+0x70>
        struct sigaction newAct;
        struct sigaction oldAct;
        newAct.sigmask = 0;
 390:	fc042423          	sw	zero,-56(s0)
        newAct.sa_handler=(void*)SIG_IGN;
 394:	4785                	li	a5,1
 396:	fcf43023          	sd	a5,-64(s0)
        int ans=sigaction(signum,&newAct,&oldAct);
 39a:	fd040613          	addi	a2,s0,-48
 39e:	fc040593          	addi	a1,s0,-64
 3a2:	4559                	li	a0,22
 3a4:	00000097          	auipc	ra,0x0
 3a8:	3a0080e7          	jalr	928(ra) # 744 <sigaction>
 3ac:	85aa                	mv	a1,a0
        printf("ans from sigaction %d, old act returned is: mask= %d address= %d",ans,oldAct.sigmask,(uint64)oldAct.sa_handler);
 3ae:	fd043683          	ld	a3,-48(s0)
 3b2:	fd842603          	lw	a2,-40(s0)
 3b6:	00001517          	auipc	a0,0x1
 3ba:	a4250513          	addi	a0,a0,-1470 # df8 <malloc+0x30e>
 3be:	00000097          	auipc	ra,0x0
 3c2:	66e080e7          	jalr	1646(ra) # a2c <printf>
        
        sleep(6);
 3c6:	4519                	li	a0,6
 3c8:	00000097          	auipc	ra,0x0
 3cc:	364080e7          	jalr	868(ra) # 72c <sleep>
 3d0:	44a9                	li	s1,10
        for(int i=0;i<10;i++){
            printf("child ignoring signal :-)\n");
 3d2:	00001917          	auipc	s2,0x1
 3d6:	a6e90913          	addi	s2,s2,-1426 # e40 <malloc+0x356>
 3da:	854a                	mv	a0,s2
 3dc:	00000097          	auipc	ra,0x0
 3e0:	650080e7          	jalr	1616(ra) # a2c <printf>
        for(int i=0;i<10;i++){
 3e4:	34fd                	addiw	s1,s1,-1
 3e6:	f8f5                	bnez	s1,3da <test_ignore+0x60>
 3e8:	a829                	j	402 <test_ignore+0x88>
 3ea:	84aa                	mv	s1,a0
        }
    }else{
        sleep(5);
 3ec:	4515                	li	a0,5
 3ee:	00000097          	auipc	ra,0x0
 3f2:	33e080e7          	jalr	830(ra) # 72c <sleep>
        kill(pid,signum);
 3f6:	45d9                	li	a1,22
 3f8:	8526                	mv	a0,s1
 3fa:	00000097          	auipc	ra,0x0
 3fe:	2d2080e7          	jalr	722(ra) # 6cc <kill>

    }
}
 402:	70e2                	ld	ra,56(sp)
 404:	7442                	ld	s0,48(sp)
 406:	74a2                	ld	s1,40(sp)
 408:	7902                	ld	s2,32(sp)
 40a:	6121                	addi	sp,sp,64
 40c:	8082                	ret

000000000000040e <main>:


int main(){
 40e:	1141                	addi	sp,sp,-16
 410:	e406                	sd	ra,8(sp)
 412:	e022                	sd	s0,0(sp)
 414:	0800                	addi	s0,sp,16
    // printf("-----------------------------test_sigkill-----------------------------\n");
    // test_sigkill();

     printf("-----------------------------test_stop_cont_sig-----------------------------\n");
 416:	00001517          	auipc	a0,0x1
 41a:	a4a50513          	addi	a0,a0,-1462 # e60 <malloc+0x376>
 41e:	00000097          	auipc	ra,0x0
 422:	60e080e7          	jalr	1550(ra) # a2c <printf>
    test_stop_cont();
 426:	00000097          	auipc	ra,0x0
 42a:	cbe080e7          	jalr	-834(ra) # e4 <test_stop_cont>

000000000000042e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 42e:	1141                	addi	sp,sp,-16
 430:	e422                	sd	s0,8(sp)
 432:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 434:	87aa                	mv	a5,a0
 436:	0585                	addi	a1,a1,1
 438:	0785                	addi	a5,a5,1
 43a:	fff5c703          	lbu	a4,-1(a1)
 43e:	fee78fa3          	sb	a4,-1(a5)
 442:	fb75                	bnez	a4,436 <strcpy+0x8>
    ;
  return os;
}
 444:	6422                	ld	s0,8(sp)
 446:	0141                	addi	sp,sp,16
 448:	8082                	ret

000000000000044a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 44a:	1141                	addi	sp,sp,-16
 44c:	e422                	sd	s0,8(sp)
 44e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 450:	00054783          	lbu	a5,0(a0)
 454:	cb91                	beqz	a5,468 <strcmp+0x1e>
 456:	0005c703          	lbu	a4,0(a1)
 45a:	00f71763          	bne	a4,a5,468 <strcmp+0x1e>
    p++, q++;
 45e:	0505                	addi	a0,a0,1
 460:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 462:	00054783          	lbu	a5,0(a0)
 466:	fbe5                	bnez	a5,456 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 468:	0005c503          	lbu	a0,0(a1)
}
 46c:	40a7853b          	subw	a0,a5,a0
 470:	6422                	ld	s0,8(sp)
 472:	0141                	addi	sp,sp,16
 474:	8082                	ret

0000000000000476 <strlen>:

uint
strlen(const char *s)
{
 476:	1141                	addi	sp,sp,-16
 478:	e422                	sd	s0,8(sp)
 47a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 47c:	00054783          	lbu	a5,0(a0)
 480:	cf91                	beqz	a5,49c <strlen+0x26>
 482:	0505                	addi	a0,a0,1
 484:	87aa                	mv	a5,a0
 486:	4685                	li	a3,1
 488:	9e89                	subw	a3,a3,a0
 48a:	00f6853b          	addw	a0,a3,a5
 48e:	0785                	addi	a5,a5,1
 490:	fff7c703          	lbu	a4,-1(a5)
 494:	fb7d                	bnez	a4,48a <strlen+0x14>
    ;
  return n;
}
 496:	6422                	ld	s0,8(sp)
 498:	0141                	addi	sp,sp,16
 49a:	8082                	ret
  for(n = 0; s[n]; n++)
 49c:	4501                	li	a0,0
 49e:	bfe5                	j	496 <strlen+0x20>

00000000000004a0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 4a0:	1141                	addi	sp,sp,-16
 4a2:	e422                	sd	s0,8(sp)
 4a4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 4a6:	ca19                	beqz	a2,4bc <memset+0x1c>
 4a8:	87aa                	mv	a5,a0
 4aa:	1602                	slli	a2,a2,0x20
 4ac:	9201                	srli	a2,a2,0x20
 4ae:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 4b2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 4b6:	0785                	addi	a5,a5,1
 4b8:	fee79de3          	bne	a5,a4,4b2 <memset+0x12>
  }
  return dst;
}
 4bc:	6422                	ld	s0,8(sp)
 4be:	0141                	addi	sp,sp,16
 4c0:	8082                	ret

00000000000004c2 <strchr>:

char*
strchr(const char *s, char c)
{
 4c2:	1141                	addi	sp,sp,-16
 4c4:	e422                	sd	s0,8(sp)
 4c6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 4c8:	00054783          	lbu	a5,0(a0)
 4cc:	cb99                	beqz	a5,4e2 <strchr+0x20>
    if(*s == c)
 4ce:	00f58763          	beq	a1,a5,4dc <strchr+0x1a>
  for(; *s; s++)
 4d2:	0505                	addi	a0,a0,1
 4d4:	00054783          	lbu	a5,0(a0)
 4d8:	fbfd                	bnez	a5,4ce <strchr+0xc>
      return (char*)s;
  return 0;
 4da:	4501                	li	a0,0
}
 4dc:	6422                	ld	s0,8(sp)
 4de:	0141                	addi	sp,sp,16
 4e0:	8082                	ret
  return 0;
 4e2:	4501                	li	a0,0
 4e4:	bfe5                	j	4dc <strchr+0x1a>

00000000000004e6 <gets>:

char*
gets(char *buf, int max)
{
 4e6:	711d                	addi	sp,sp,-96
 4e8:	ec86                	sd	ra,88(sp)
 4ea:	e8a2                	sd	s0,80(sp)
 4ec:	e4a6                	sd	s1,72(sp)
 4ee:	e0ca                	sd	s2,64(sp)
 4f0:	fc4e                	sd	s3,56(sp)
 4f2:	f852                	sd	s4,48(sp)
 4f4:	f456                	sd	s5,40(sp)
 4f6:	f05a                	sd	s6,32(sp)
 4f8:	ec5e                	sd	s7,24(sp)
 4fa:	1080                	addi	s0,sp,96
 4fc:	8baa                	mv	s7,a0
 4fe:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 500:	892a                	mv	s2,a0
 502:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 504:	4aa9                	li	s5,10
 506:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 508:	89a6                	mv	s3,s1
 50a:	2485                	addiw	s1,s1,1
 50c:	0344d863          	bge	s1,s4,53c <gets+0x56>
    cc = read(0, &c, 1);
 510:	4605                	li	a2,1
 512:	faf40593          	addi	a1,s0,-81
 516:	4501                	li	a0,0
 518:	00000097          	auipc	ra,0x0
 51c:	19c080e7          	jalr	412(ra) # 6b4 <read>
    if(cc < 1)
 520:	00a05e63          	blez	a0,53c <gets+0x56>
    buf[i++] = c;
 524:	faf44783          	lbu	a5,-81(s0)
 528:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 52c:	01578763          	beq	a5,s5,53a <gets+0x54>
 530:	0905                	addi	s2,s2,1
 532:	fd679be3          	bne	a5,s6,508 <gets+0x22>
  for(i=0; i+1 < max; ){
 536:	89a6                	mv	s3,s1
 538:	a011                	j	53c <gets+0x56>
 53a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 53c:	99de                	add	s3,s3,s7
 53e:	00098023          	sb	zero,0(s3)
  return buf;
}
 542:	855e                	mv	a0,s7
 544:	60e6                	ld	ra,88(sp)
 546:	6446                	ld	s0,80(sp)
 548:	64a6                	ld	s1,72(sp)
 54a:	6906                	ld	s2,64(sp)
 54c:	79e2                	ld	s3,56(sp)
 54e:	7a42                	ld	s4,48(sp)
 550:	7aa2                	ld	s5,40(sp)
 552:	7b02                	ld	s6,32(sp)
 554:	6be2                	ld	s7,24(sp)
 556:	6125                	addi	sp,sp,96
 558:	8082                	ret

000000000000055a <stat>:

int
stat(const char *n, struct stat *st)
{
 55a:	1101                	addi	sp,sp,-32
 55c:	ec06                	sd	ra,24(sp)
 55e:	e822                	sd	s0,16(sp)
 560:	e426                	sd	s1,8(sp)
 562:	e04a                	sd	s2,0(sp)
 564:	1000                	addi	s0,sp,32
 566:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 568:	4581                	li	a1,0
 56a:	00000097          	auipc	ra,0x0
 56e:	172080e7          	jalr	370(ra) # 6dc <open>
  if(fd < 0)
 572:	02054563          	bltz	a0,59c <stat+0x42>
 576:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 578:	85ca                	mv	a1,s2
 57a:	00000097          	auipc	ra,0x0
 57e:	17a080e7          	jalr	378(ra) # 6f4 <fstat>
 582:	892a                	mv	s2,a0
  close(fd);
 584:	8526                	mv	a0,s1
 586:	00000097          	auipc	ra,0x0
 58a:	13e080e7          	jalr	318(ra) # 6c4 <close>
  return r;
}
 58e:	854a                	mv	a0,s2
 590:	60e2                	ld	ra,24(sp)
 592:	6442                	ld	s0,16(sp)
 594:	64a2                	ld	s1,8(sp)
 596:	6902                	ld	s2,0(sp)
 598:	6105                	addi	sp,sp,32
 59a:	8082                	ret
    return -1;
 59c:	597d                	li	s2,-1
 59e:	bfc5                	j	58e <stat+0x34>

00000000000005a0 <atoi>:

int
atoi(const char *s)
{
 5a0:	1141                	addi	sp,sp,-16
 5a2:	e422                	sd	s0,8(sp)
 5a4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 5a6:	00054603          	lbu	a2,0(a0)
 5aa:	fd06079b          	addiw	a5,a2,-48
 5ae:	0ff7f793          	andi	a5,a5,255
 5b2:	4725                	li	a4,9
 5b4:	02f76963          	bltu	a4,a5,5e6 <atoi+0x46>
 5b8:	86aa                	mv	a3,a0
  n = 0;
 5ba:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 5bc:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 5be:	0685                	addi	a3,a3,1
 5c0:	0025179b          	slliw	a5,a0,0x2
 5c4:	9fa9                	addw	a5,a5,a0
 5c6:	0017979b          	slliw	a5,a5,0x1
 5ca:	9fb1                	addw	a5,a5,a2
 5cc:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 5d0:	0006c603          	lbu	a2,0(a3)
 5d4:	fd06071b          	addiw	a4,a2,-48
 5d8:	0ff77713          	andi	a4,a4,255
 5dc:	fee5f1e3          	bgeu	a1,a4,5be <atoi+0x1e>
  return n;
}
 5e0:	6422                	ld	s0,8(sp)
 5e2:	0141                	addi	sp,sp,16
 5e4:	8082                	ret
  n = 0;
 5e6:	4501                	li	a0,0
 5e8:	bfe5                	j	5e0 <atoi+0x40>

00000000000005ea <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 5ea:	1141                	addi	sp,sp,-16
 5ec:	e422                	sd	s0,8(sp)
 5ee:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 5f0:	02b57463          	bgeu	a0,a1,618 <memmove+0x2e>
    while(n-- > 0)
 5f4:	00c05f63          	blez	a2,612 <memmove+0x28>
 5f8:	1602                	slli	a2,a2,0x20
 5fa:	9201                	srli	a2,a2,0x20
 5fc:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 600:	872a                	mv	a4,a0
      *dst++ = *src++;
 602:	0585                	addi	a1,a1,1
 604:	0705                	addi	a4,a4,1
 606:	fff5c683          	lbu	a3,-1(a1)
 60a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 60e:	fee79ae3          	bne	a5,a4,602 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 612:	6422                	ld	s0,8(sp)
 614:	0141                	addi	sp,sp,16
 616:	8082                	ret
    dst += n;
 618:	00c50733          	add	a4,a0,a2
    src += n;
 61c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 61e:	fec05ae3          	blez	a2,612 <memmove+0x28>
 622:	fff6079b          	addiw	a5,a2,-1
 626:	1782                	slli	a5,a5,0x20
 628:	9381                	srli	a5,a5,0x20
 62a:	fff7c793          	not	a5,a5
 62e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 630:	15fd                	addi	a1,a1,-1
 632:	177d                	addi	a4,a4,-1
 634:	0005c683          	lbu	a3,0(a1)
 638:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 63c:	fee79ae3          	bne	a5,a4,630 <memmove+0x46>
 640:	bfc9                	j	612 <memmove+0x28>

0000000000000642 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 642:	1141                	addi	sp,sp,-16
 644:	e422                	sd	s0,8(sp)
 646:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 648:	ca05                	beqz	a2,678 <memcmp+0x36>
 64a:	fff6069b          	addiw	a3,a2,-1
 64e:	1682                	slli	a3,a3,0x20
 650:	9281                	srli	a3,a3,0x20
 652:	0685                	addi	a3,a3,1
 654:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 656:	00054783          	lbu	a5,0(a0)
 65a:	0005c703          	lbu	a4,0(a1)
 65e:	00e79863          	bne	a5,a4,66e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 662:	0505                	addi	a0,a0,1
    p2++;
 664:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 666:	fed518e3          	bne	a0,a3,656 <memcmp+0x14>
  }
  return 0;
 66a:	4501                	li	a0,0
 66c:	a019                	j	672 <memcmp+0x30>
      return *p1 - *p2;
 66e:	40e7853b          	subw	a0,a5,a4
}
 672:	6422                	ld	s0,8(sp)
 674:	0141                	addi	sp,sp,16
 676:	8082                	ret
  return 0;
 678:	4501                	li	a0,0
 67a:	bfe5                	j	672 <memcmp+0x30>

000000000000067c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 67c:	1141                	addi	sp,sp,-16
 67e:	e406                	sd	ra,8(sp)
 680:	e022                	sd	s0,0(sp)
 682:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 684:	00000097          	auipc	ra,0x0
 688:	f66080e7          	jalr	-154(ra) # 5ea <memmove>
}
 68c:	60a2                	ld	ra,8(sp)
 68e:	6402                	ld	s0,0(sp)
 690:	0141                	addi	sp,sp,16
 692:	8082                	ret

0000000000000694 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 694:	4885                	li	a7,1
 ecall
 696:	00000073          	ecall
 ret
 69a:	8082                	ret

000000000000069c <exit>:
.global exit
exit:
 li a7, SYS_exit
 69c:	4889                	li	a7,2
 ecall
 69e:	00000073          	ecall
 ret
 6a2:	8082                	ret

00000000000006a4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 6a4:	488d                	li	a7,3
 ecall
 6a6:	00000073          	ecall
 ret
 6aa:	8082                	ret

00000000000006ac <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 6ac:	4891                	li	a7,4
 ecall
 6ae:	00000073          	ecall
 ret
 6b2:	8082                	ret

00000000000006b4 <read>:
.global read
read:
 li a7, SYS_read
 6b4:	4895                	li	a7,5
 ecall
 6b6:	00000073          	ecall
 ret
 6ba:	8082                	ret

00000000000006bc <write>:
.global write
write:
 li a7, SYS_write
 6bc:	48c1                	li	a7,16
 ecall
 6be:	00000073          	ecall
 ret
 6c2:	8082                	ret

00000000000006c4 <close>:
.global close
close:
 li a7, SYS_close
 6c4:	48d5                	li	a7,21
 ecall
 6c6:	00000073          	ecall
 ret
 6ca:	8082                	ret

00000000000006cc <kill>:
.global kill
kill:
 li a7, SYS_kill
 6cc:	4899                	li	a7,6
 ecall
 6ce:	00000073          	ecall
 ret
 6d2:	8082                	ret

00000000000006d4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 6d4:	489d                	li	a7,7
 ecall
 6d6:	00000073          	ecall
 ret
 6da:	8082                	ret

00000000000006dc <open>:
.global open
open:
 li a7, SYS_open
 6dc:	48bd                	li	a7,15
 ecall
 6de:	00000073          	ecall
 ret
 6e2:	8082                	ret

00000000000006e4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 6e4:	48c5                	li	a7,17
 ecall
 6e6:	00000073          	ecall
 ret
 6ea:	8082                	ret

00000000000006ec <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 6ec:	48c9                	li	a7,18
 ecall
 6ee:	00000073          	ecall
 ret
 6f2:	8082                	ret

00000000000006f4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 6f4:	48a1                	li	a7,8
 ecall
 6f6:	00000073          	ecall
 ret
 6fa:	8082                	ret

00000000000006fc <link>:
.global link
link:
 li a7, SYS_link
 6fc:	48cd                	li	a7,19
 ecall
 6fe:	00000073          	ecall
 ret
 702:	8082                	ret

0000000000000704 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 704:	48d1                	li	a7,20
 ecall
 706:	00000073          	ecall
 ret
 70a:	8082                	ret

000000000000070c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 70c:	48a5                	li	a7,9
 ecall
 70e:	00000073          	ecall
 ret
 712:	8082                	ret

0000000000000714 <dup>:
.global dup
dup:
 li a7, SYS_dup
 714:	48a9                	li	a7,10
 ecall
 716:	00000073          	ecall
 ret
 71a:	8082                	ret

000000000000071c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 71c:	48ad                	li	a7,11
 ecall
 71e:	00000073          	ecall
 ret
 722:	8082                	ret

0000000000000724 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 724:	48b1                	li	a7,12
 ecall
 726:	00000073          	ecall
 ret
 72a:	8082                	ret

000000000000072c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 72c:	48b5                	li	a7,13
 ecall
 72e:	00000073          	ecall
 ret
 732:	8082                	ret

0000000000000734 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 734:	48b9                	li	a7,14
 ecall
 736:	00000073          	ecall
 ret
 73a:	8082                	ret

000000000000073c <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
 73c:	48d9                	li	a7,22
 ecall
 73e:	00000073          	ecall
 ret
 742:	8082                	ret

0000000000000744 <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
 744:	48dd                	li	a7,23
 ecall
 746:	00000073          	ecall
 ret
 74a:	8082                	ret

000000000000074c <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
 74c:	48e1                	li	a7,24
 ecall
 74e:	00000073          	ecall
 ret
 752:	8082                	ret

0000000000000754 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 754:	1101                	addi	sp,sp,-32
 756:	ec06                	sd	ra,24(sp)
 758:	e822                	sd	s0,16(sp)
 75a:	1000                	addi	s0,sp,32
 75c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 760:	4605                	li	a2,1
 762:	fef40593          	addi	a1,s0,-17
 766:	00000097          	auipc	ra,0x0
 76a:	f56080e7          	jalr	-170(ra) # 6bc <write>
}
 76e:	60e2                	ld	ra,24(sp)
 770:	6442                	ld	s0,16(sp)
 772:	6105                	addi	sp,sp,32
 774:	8082                	ret

0000000000000776 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 776:	7139                	addi	sp,sp,-64
 778:	fc06                	sd	ra,56(sp)
 77a:	f822                	sd	s0,48(sp)
 77c:	f426                	sd	s1,40(sp)
 77e:	f04a                	sd	s2,32(sp)
 780:	ec4e                	sd	s3,24(sp)
 782:	0080                	addi	s0,sp,64
 784:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 786:	c299                	beqz	a3,78c <printint+0x16>
 788:	0805c863          	bltz	a1,818 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 78c:	2581                	sext.w	a1,a1
  neg = 0;
 78e:	4881                	li	a7,0
 790:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 794:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 796:	2601                	sext.w	a2,a2
 798:	00000517          	auipc	a0,0x0
 79c:	72050513          	addi	a0,a0,1824 # eb8 <digits>
 7a0:	883a                	mv	a6,a4
 7a2:	2705                	addiw	a4,a4,1
 7a4:	02c5f7bb          	remuw	a5,a1,a2
 7a8:	1782                	slli	a5,a5,0x20
 7aa:	9381                	srli	a5,a5,0x20
 7ac:	97aa                	add	a5,a5,a0
 7ae:	0007c783          	lbu	a5,0(a5)
 7b2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 7b6:	0005879b          	sext.w	a5,a1
 7ba:	02c5d5bb          	divuw	a1,a1,a2
 7be:	0685                	addi	a3,a3,1
 7c0:	fec7f0e3          	bgeu	a5,a2,7a0 <printint+0x2a>
  if(neg)
 7c4:	00088b63          	beqz	a7,7da <printint+0x64>
    buf[i++] = '-';
 7c8:	fd040793          	addi	a5,s0,-48
 7cc:	973e                	add	a4,a4,a5
 7ce:	02d00793          	li	a5,45
 7d2:	fef70823          	sb	a5,-16(a4)
 7d6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 7da:	02e05863          	blez	a4,80a <printint+0x94>
 7de:	fc040793          	addi	a5,s0,-64
 7e2:	00e78933          	add	s2,a5,a4
 7e6:	fff78993          	addi	s3,a5,-1
 7ea:	99ba                	add	s3,s3,a4
 7ec:	377d                	addiw	a4,a4,-1
 7ee:	1702                	slli	a4,a4,0x20
 7f0:	9301                	srli	a4,a4,0x20
 7f2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 7f6:	fff94583          	lbu	a1,-1(s2)
 7fa:	8526                	mv	a0,s1
 7fc:	00000097          	auipc	ra,0x0
 800:	f58080e7          	jalr	-168(ra) # 754 <putc>
  while(--i >= 0)
 804:	197d                	addi	s2,s2,-1
 806:	ff3918e3          	bne	s2,s3,7f6 <printint+0x80>
}
 80a:	70e2                	ld	ra,56(sp)
 80c:	7442                	ld	s0,48(sp)
 80e:	74a2                	ld	s1,40(sp)
 810:	7902                	ld	s2,32(sp)
 812:	69e2                	ld	s3,24(sp)
 814:	6121                	addi	sp,sp,64
 816:	8082                	ret
    x = -xx;
 818:	40b005bb          	negw	a1,a1
    neg = 1;
 81c:	4885                	li	a7,1
    x = -xx;
 81e:	bf8d                	j	790 <printint+0x1a>

0000000000000820 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 820:	7119                	addi	sp,sp,-128
 822:	fc86                	sd	ra,120(sp)
 824:	f8a2                	sd	s0,112(sp)
 826:	f4a6                	sd	s1,104(sp)
 828:	f0ca                	sd	s2,96(sp)
 82a:	ecce                	sd	s3,88(sp)
 82c:	e8d2                	sd	s4,80(sp)
 82e:	e4d6                	sd	s5,72(sp)
 830:	e0da                	sd	s6,64(sp)
 832:	fc5e                	sd	s7,56(sp)
 834:	f862                	sd	s8,48(sp)
 836:	f466                	sd	s9,40(sp)
 838:	f06a                	sd	s10,32(sp)
 83a:	ec6e                	sd	s11,24(sp)
 83c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 83e:	0005c903          	lbu	s2,0(a1)
 842:	18090f63          	beqz	s2,9e0 <vprintf+0x1c0>
 846:	8aaa                	mv	s5,a0
 848:	8b32                	mv	s6,a2
 84a:	00158493          	addi	s1,a1,1
  state = 0;
 84e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 850:	02500a13          	li	s4,37
      if(c == 'd'){
 854:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 858:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 85c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 860:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 864:	00000b97          	auipc	s7,0x0
 868:	654b8b93          	addi	s7,s7,1620 # eb8 <digits>
 86c:	a839                	j	88a <vprintf+0x6a>
        putc(fd, c);
 86e:	85ca                	mv	a1,s2
 870:	8556                	mv	a0,s5
 872:	00000097          	auipc	ra,0x0
 876:	ee2080e7          	jalr	-286(ra) # 754 <putc>
 87a:	a019                	j	880 <vprintf+0x60>
    } else if(state == '%'){
 87c:	01498f63          	beq	s3,s4,89a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 880:	0485                	addi	s1,s1,1
 882:	fff4c903          	lbu	s2,-1(s1)
 886:	14090d63          	beqz	s2,9e0 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 88a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 88e:	fe0997e3          	bnez	s3,87c <vprintf+0x5c>
      if(c == '%'){
 892:	fd479ee3          	bne	a5,s4,86e <vprintf+0x4e>
        state = '%';
 896:	89be                	mv	s3,a5
 898:	b7e5                	j	880 <vprintf+0x60>
      if(c == 'd'){
 89a:	05878063          	beq	a5,s8,8da <vprintf+0xba>
      } else if(c == 'l') {
 89e:	05978c63          	beq	a5,s9,8f6 <vprintf+0xd6>
      } else if(c == 'x') {
 8a2:	07a78863          	beq	a5,s10,912 <vprintf+0xf2>
      } else if(c == 'p') {
 8a6:	09b78463          	beq	a5,s11,92e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 8aa:	07300713          	li	a4,115
 8ae:	0ce78663          	beq	a5,a4,97a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 8b2:	06300713          	li	a4,99
 8b6:	0ee78e63          	beq	a5,a4,9b2 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 8ba:	11478863          	beq	a5,s4,9ca <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8be:	85d2                	mv	a1,s4
 8c0:	8556                	mv	a0,s5
 8c2:	00000097          	auipc	ra,0x0
 8c6:	e92080e7          	jalr	-366(ra) # 754 <putc>
        putc(fd, c);
 8ca:	85ca                	mv	a1,s2
 8cc:	8556                	mv	a0,s5
 8ce:	00000097          	auipc	ra,0x0
 8d2:	e86080e7          	jalr	-378(ra) # 754 <putc>
      }
      state = 0;
 8d6:	4981                	li	s3,0
 8d8:	b765                	j	880 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 8da:	008b0913          	addi	s2,s6,8
 8de:	4685                	li	a3,1
 8e0:	4629                	li	a2,10
 8e2:	000b2583          	lw	a1,0(s6)
 8e6:	8556                	mv	a0,s5
 8e8:	00000097          	auipc	ra,0x0
 8ec:	e8e080e7          	jalr	-370(ra) # 776 <printint>
 8f0:	8b4a                	mv	s6,s2
      state = 0;
 8f2:	4981                	li	s3,0
 8f4:	b771                	j	880 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8f6:	008b0913          	addi	s2,s6,8
 8fa:	4681                	li	a3,0
 8fc:	4629                	li	a2,10
 8fe:	000b2583          	lw	a1,0(s6)
 902:	8556                	mv	a0,s5
 904:	00000097          	auipc	ra,0x0
 908:	e72080e7          	jalr	-398(ra) # 776 <printint>
 90c:	8b4a                	mv	s6,s2
      state = 0;
 90e:	4981                	li	s3,0
 910:	bf85                	j	880 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 912:	008b0913          	addi	s2,s6,8
 916:	4681                	li	a3,0
 918:	4641                	li	a2,16
 91a:	000b2583          	lw	a1,0(s6)
 91e:	8556                	mv	a0,s5
 920:	00000097          	auipc	ra,0x0
 924:	e56080e7          	jalr	-426(ra) # 776 <printint>
 928:	8b4a                	mv	s6,s2
      state = 0;
 92a:	4981                	li	s3,0
 92c:	bf91                	j	880 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 92e:	008b0793          	addi	a5,s6,8
 932:	f8f43423          	sd	a5,-120(s0)
 936:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 93a:	03000593          	li	a1,48
 93e:	8556                	mv	a0,s5
 940:	00000097          	auipc	ra,0x0
 944:	e14080e7          	jalr	-492(ra) # 754 <putc>
  putc(fd, 'x');
 948:	85ea                	mv	a1,s10
 94a:	8556                	mv	a0,s5
 94c:	00000097          	auipc	ra,0x0
 950:	e08080e7          	jalr	-504(ra) # 754 <putc>
 954:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 956:	03c9d793          	srli	a5,s3,0x3c
 95a:	97de                	add	a5,a5,s7
 95c:	0007c583          	lbu	a1,0(a5)
 960:	8556                	mv	a0,s5
 962:	00000097          	auipc	ra,0x0
 966:	df2080e7          	jalr	-526(ra) # 754 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 96a:	0992                	slli	s3,s3,0x4
 96c:	397d                	addiw	s2,s2,-1
 96e:	fe0914e3          	bnez	s2,956 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 972:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 976:	4981                	li	s3,0
 978:	b721                	j	880 <vprintf+0x60>
        s = va_arg(ap, char*);
 97a:	008b0993          	addi	s3,s6,8
 97e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 982:	02090163          	beqz	s2,9a4 <vprintf+0x184>
        while(*s != 0){
 986:	00094583          	lbu	a1,0(s2)
 98a:	c9a1                	beqz	a1,9da <vprintf+0x1ba>
          putc(fd, *s);
 98c:	8556                	mv	a0,s5
 98e:	00000097          	auipc	ra,0x0
 992:	dc6080e7          	jalr	-570(ra) # 754 <putc>
          s++;
 996:	0905                	addi	s2,s2,1
        while(*s != 0){
 998:	00094583          	lbu	a1,0(s2)
 99c:	f9e5                	bnez	a1,98c <vprintf+0x16c>
        s = va_arg(ap, char*);
 99e:	8b4e                	mv	s6,s3
      state = 0;
 9a0:	4981                	li	s3,0
 9a2:	bdf9                	j	880 <vprintf+0x60>
          s = "(null)";
 9a4:	00000917          	auipc	s2,0x0
 9a8:	50c90913          	addi	s2,s2,1292 # eb0 <malloc+0x3c6>
        while(*s != 0){
 9ac:	02800593          	li	a1,40
 9b0:	bff1                	j	98c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 9b2:	008b0913          	addi	s2,s6,8
 9b6:	000b4583          	lbu	a1,0(s6)
 9ba:	8556                	mv	a0,s5
 9bc:	00000097          	auipc	ra,0x0
 9c0:	d98080e7          	jalr	-616(ra) # 754 <putc>
 9c4:	8b4a                	mv	s6,s2
      state = 0;
 9c6:	4981                	li	s3,0
 9c8:	bd65                	j	880 <vprintf+0x60>
        putc(fd, c);
 9ca:	85d2                	mv	a1,s4
 9cc:	8556                	mv	a0,s5
 9ce:	00000097          	auipc	ra,0x0
 9d2:	d86080e7          	jalr	-634(ra) # 754 <putc>
      state = 0;
 9d6:	4981                	li	s3,0
 9d8:	b565                	j	880 <vprintf+0x60>
        s = va_arg(ap, char*);
 9da:	8b4e                	mv	s6,s3
      state = 0;
 9dc:	4981                	li	s3,0
 9de:	b54d                	j	880 <vprintf+0x60>
    }
  }
}
 9e0:	70e6                	ld	ra,120(sp)
 9e2:	7446                	ld	s0,112(sp)
 9e4:	74a6                	ld	s1,104(sp)
 9e6:	7906                	ld	s2,96(sp)
 9e8:	69e6                	ld	s3,88(sp)
 9ea:	6a46                	ld	s4,80(sp)
 9ec:	6aa6                	ld	s5,72(sp)
 9ee:	6b06                	ld	s6,64(sp)
 9f0:	7be2                	ld	s7,56(sp)
 9f2:	7c42                	ld	s8,48(sp)
 9f4:	7ca2                	ld	s9,40(sp)
 9f6:	7d02                	ld	s10,32(sp)
 9f8:	6de2                	ld	s11,24(sp)
 9fa:	6109                	addi	sp,sp,128
 9fc:	8082                	ret

00000000000009fe <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9fe:	715d                	addi	sp,sp,-80
 a00:	ec06                	sd	ra,24(sp)
 a02:	e822                	sd	s0,16(sp)
 a04:	1000                	addi	s0,sp,32
 a06:	e010                	sd	a2,0(s0)
 a08:	e414                	sd	a3,8(s0)
 a0a:	e818                	sd	a4,16(s0)
 a0c:	ec1c                	sd	a5,24(s0)
 a0e:	03043023          	sd	a6,32(s0)
 a12:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a16:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a1a:	8622                	mv	a2,s0
 a1c:	00000097          	auipc	ra,0x0
 a20:	e04080e7          	jalr	-508(ra) # 820 <vprintf>
}
 a24:	60e2                	ld	ra,24(sp)
 a26:	6442                	ld	s0,16(sp)
 a28:	6161                	addi	sp,sp,80
 a2a:	8082                	ret

0000000000000a2c <printf>:

void
printf(const char *fmt, ...)
{
 a2c:	711d                	addi	sp,sp,-96
 a2e:	ec06                	sd	ra,24(sp)
 a30:	e822                	sd	s0,16(sp)
 a32:	1000                	addi	s0,sp,32
 a34:	e40c                	sd	a1,8(s0)
 a36:	e810                	sd	a2,16(s0)
 a38:	ec14                	sd	a3,24(s0)
 a3a:	f018                	sd	a4,32(s0)
 a3c:	f41c                	sd	a5,40(s0)
 a3e:	03043823          	sd	a6,48(s0)
 a42:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 a46:	00840613          	addi	a2,s0,8
 a4a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a4e:	85aa                	mv	a1,a0
 a50:	4505                	li	a0,1
 a52:	00000097          	auipc	ra,0x0
 a56:	dce080e7          	jalr	-562(ra) # 820 <vprintf>
}
 a5a:	60e2                	ld	ra,24(sp)
 a5c:	6442                	ld	s0,16(sp)
 a5e:	6125                	addi	sp,sp,96
 a60:	8082                	ret

0000000000000a62 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a62:	1141                	addi	sp,sp,-16
 a64:	e422                	sd	s0,8(sp)
 a66:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a68:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a6c:	00000797          	auipc	a5,0x0
 a70:	4647b783          	ld	a5,1124(a5) # ed0 <freep>
 a74:	a805                	j	aa4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a76:	4618                	lw	a4,8(a2)
 a78:	9db9                	addw	a1,a1,a4
 a7a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a7e:	6398                	ld	a4,0(a5)
 a80:	6318                	ld	a4,0(a4)
 a82:	fee53823          	sd	a4,-16(a0)
 a86:	a091                	j	aca <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a88:	ff852703          	lw	a4,-8(a0)
 a8c:	9e39                	addw	a2,a2,a4
 a8e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 a90:	ff053703          	ld	a4,-16(a0)
 a94:	e398                	sd	a4,0(a5)
 a96:	a099                	j	adc <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a98:	6398                	ld	a4,0(a5)
 a9a:	00e7e463          	bltu	a5,a4,aa2 <free+0x40>
 a9e:	00e6ea63          	bltu	a3,a4,ab2 <free+0x50>
{
 aa2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 aa4:	fed7fae3          	bgeu	a5,a3,a98 <free+0x36>
 aa8:	6398                	ld	a4,0(a5)
 aaa:	00e6e463          	bltu	a3,a4,ab2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 aae:	fee7eae3          	bltu	a5,a4,aa2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 ab2:	ff852583          	lw	a1,-8(a0)
 ab6:	6390                	ld	a2,0(a5)
 ab8:	02059813          	slli	a6,a1,0x20
 abc:	01c85713          	srli	a4,a6,0x1c
 ac0:	9736                	add	a4,a4,a3
 ac2:	fae60ae3          	beq	a2,a4,a76 <free+0x14>
    bp->s.ptr = p->s.ptr;
 ac6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 aca:	4790                	lw	a2,8(a5)
 acc:	02061593          	slli	a1,a2,0x20
 ad0:	01c5d713          	srli	a4,a1,0x1c
 ad4:	973e                	add	a4,a4,a5
 ad6:	fae689e3          	beq	a3,a4,a88 <free+0x26>
  } else
    p->s.ptr = bp;
 ada:	e394                	sd	a3,0(a5)
  freep = p;
 adc:	00000717          	auipc	a4,0x0
 ae0:	3ef73a23          	sd	a5,1012(a4) # ed0 <freep>
}
 ae4:	6422                	ld	s0,8(sp)
 ae6:	0141                	addi	sp,sp,16
 ae8:	8082                	ret

0000000000000aea <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 aea:	7139                	addi	sp,sp,-64
 aec:	fc06                	sd	ra,56(sp)
 aee:	f822                	sd	s0,48(sp)
 af0:	f426                	sd	s1,40(sp)
 af2:	f04a                	sd	s2,32(sp)
 af4:	ec4e                	sd	s3,24(sp)
 af6:	e852                	sd	s4,16(sp)
 af8:	e456                	sd	s5,8(sp)
 afa:	e05a                	sd	s6,0(sp)
 afc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 afe:	02051493          	slli	s1,a0,0x20
 b02:	9081                	srli	s1,s1,0x20
 b04:	04bd                	addi	s1,s1,15
 b06:	8091                	srli	s1,s1,0x4
 b08:	0014899b          	addiw	s3,s1,1
 b0c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b0e:	00000517          	auipc	a0,0x0
 b12:	3c253503          	ld	a0,962(a0) # ed0 <freep>
 b16:	c515                	beqz	a0,b42 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b18:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b1a:	4798                	lw	a4,8(a5)
 b1c:	02977f63          	bgeu	a4,s1,b5a <malloc+0x70>
 b20:	8a4e                	mv	s4,s3
 b22:	0009871b          	sext.w	a4,s3
 b26:	6685                	lui	a3,0x1
 b28:	00d77363          	bgeu	a4,a3,b2e <malloc+0x44>
 b2c:	6a05                	lui	s4,0x1
 b2e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 b32:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 b36:	00000917          	auipc	s2,0x0
 b3a:	39a90913          	addi	s2,s2,922 # ed0 <freep>
  if(p == (char*)-1)
 b3e:	5afd                	li	s5,-1
 b40:	a895                	j	bb4 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 b42:	00000797          	auipc	a5,0x0
 b46:	39678793          	addi	a5,a5,918 # ed8 <base>
 b4a:	00000717          	auipc	a4,0x0
 b4e:	38f73323          	sd	a5,902(a4) # ed0 <freep>
 b52:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b54:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b58:	b7e1                	j	b20 <malloc+0x36>
      if(p->s.size == nunits)
 b5a:	02e48c63          	beq	s1,a4,b92 <malloc+0xa8>
        p->s.size -= nunits;
 b5e:	4137073b          	subw	a4,a4,s3
 b62:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b64:	02071693          	slli	a3,a4,0x20
 b68:	01c6d713          	srli	a4,a3,0x1c
 b6c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b6e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b72:	00000717          	auipc	a4,0x0
 b76:	34a73f23          	sd	a0,862(a4) # ed0 <freep>
      return (void*)(p + 1);
 b7a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 b7e:	70e2                	ld	ra,56(sp)
 b80:	7442                	ld	s0,48(sp)
 b82:	74a2                	ld	s1,40(sp)
 b84:	7902                	ld	s2,32(sp)
 b86:	69e2                	ld	s3,24(sp)
 b88:	6a42                	ld	s4,16(sp)
 b8a:	6aa2                	ld	s5,8(sp)
 b8c:	6b02                	ld	s6,0(sp)
 b8e:	6121                	addi	sp,sp,64
 b90:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 b92:	6398                	ld	a4,0(a5)
 b94:	e118                	sd	a4,0(a0)
 b96:	bff1                	j	b72 <malloc+0x88>
  hp->s.size = nu;
 b98:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b9c:	0541                	addi	a0,a0,16
 b9e:	00000097          	auipc	ra,0x0
 ba2:	ec4080e7          	jalr	-316(ra) # a62 <free>
  return freep;
 ba6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 baa:	d971                	beqz	a0,b7e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bac:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 bae:	4798                	lw	a4,8(a5)
 bb0:	fa9775e3          	bgeu	a4,s1,b5a <malloc+0x70>
    if(p == freep)
 bb4:	00093703          	ld	a4,0(s2)
 bb8:	853e                	mv	a0,a5
 bba:	fef719e3          	bne	a4,a5,bac <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 bbe:	8552                	mv	a0,s4
 bc0:	00000097          	auipc	ra,0x0
 bc4:	b64080e7          	jalr	-1180(ra) # 724 <sbrk>
  if(p == (char*)-1)
 bc8:	fd5518e3          	bne	a0,s5,b98 <malloc+0xae>
        return 0;
 bcc:	4501                	li	a0,0
 bce:	bf45                	j	b7e <malloc+0x94>
