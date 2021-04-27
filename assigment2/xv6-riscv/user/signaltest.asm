
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
    char st[5] = "wap\n";
   8:	0a7067b7          	lui	a5,0xa706
   c:	17778793          	addi	a5,a5,375 # a706177 <__global_pointer$+0xa704a0e>
  10:	fef42423          	sw	a5,-24(s0)
  14:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
  18:	4615                	li	a2,5
  1a:	fe840593          	addi	a1,s0,-24
  1e:	4505                	li	a0,1
  20:	00000097          	auipc	ra,0x0
  24:	71a080e7          	jalr	1818(ra) # 73a <write>
    return;
}
  28:	60e2                	ld	ra,24(sp)
  2a:	6442                	ld	s0,16(sp)
  2c:	6105                	addi	sp,sp,32
  2e:	8082                	ret

0000000000000030 <sig_handler2>:

void
sig_handler2(int signum){
  30:	1101                	addi	sp,sp,-32
  32:	ec06                	sd	ra,24(sp)
  34:	e822                	sd	s0,16(sp)
  36:	1000                	addi	s0,sp,32
    char st[5] = "dap\n";
  38:	0a7067b7          	lui	a5,0xa706
  3c:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa7049fb>
  40:	fef42423          	sw	a5,-24(s0)
  44:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
  48:	4615                	li	a2,5
  4a:	fe840593          	addi	a1,s0,-24
  4e:	4505                	li	a0,1
  50:	00000097          	auipc	ra,0x0
  54:	6ea080e7          	jalr	1770(ra) # 73a <write>
    return;
}
  58:	60e2                	ld	ra,24(sp)
  5a:	6442                	ld	s0,16(sp)
  5c:	6105                	addi	sp,sp,32
  5e:	8082                	ret

0000000000000060 <test_sigkill>:
test_sigkill(){//
  60:	7179                	addi	sp,sp,-48
  62:	f406                	sd	ra,40(sp)
  64:	f022                	sd	s0,32(sp)
  66:	ec26                	sd	s1,24(sp)
  68:	e84a                	sd	s2,16(sp)
  6a:	e44e                	sd	s3,8(sp)
  6c:	1800                	addi	s0,sp,48
   int pid = fork();
  6e:	00000097          	auipc	ra,0x0
  72:	6a4080e7          	jalr	1700(ra) # 712 <fork>
  76:	84aa                	mv	s1,a0
    if(pid==0){
  78:	ed05                	bnez	a0,b0 <test_sigkill+0x50>
        sleep(5);
  7a:	4515                	li	a0,5
  7c:	00000097          	auipc	ra,0x0
  80:	72e080e7          	jalr	1838(ra) # 7aa <sleep>
            printf("about to get killed %d\n",i);
  84:	00001997          	auipc	s3,0x1
  88:	bcc98993          	addi	s3,s3,-1076 # c50 <malloc+0xe8>
        for(int i=0;i<300;i++)
  8c:	12c00913          	li	s2,300
            printf("about to get killed %d\n",i);
  90:	85a6                	mv	a1,s1
  92:	854e                	mv	a0,s3
  94:	00001097          	auipc	ra,0x1
  98:	a16080e7          	jalr	-1514(ra) # aaa <printf>
        for(int i=0;i<300;i++)
  9c:	2485                	addiw	s1,s1,1
  9e:	ff2499e3          	bne	s1,s2,90 <test_sigkill+0x30>
}
  a2:	70a2                	ld	ra,40(sp)
  a4:	7402                	ld	s0,32(sp)
  a6:	64e2                	ld	s1,24(sp)
  a8:	6942                	ld	s2,16(sp)
  aa:	69a2                	ld	s3,8(sp)
  ac:	6145                	addi	sp,sp,48
  ae:	8082                	ret
        sleep(7);
  b0:	451d                	li	a0,7
  b2:	00000097          	auipc	ra,0x0
  b6:	6f8080e7          	jalr	1784(ra) # 7aa <sleep>
        printf("parent send signal to to kill child\n");
  ba:	00001517          	auipc	a0,0x1
  be:	bae50513          	addi	a0,a0,-1106 # c68 <malloc+0x100>
  c2:	00001097          	auipc	ra,0x1
  c6:	9e8080e7          	jalr	-1560(ra) # aaa <printf>
        printf("kill ret= %d\n",kill(pid, SIGKILL));
  ca:	45a5                	li	a1,9
  cc:	8526                	mv	a0,s1
  ce:	00000097          	auipc	ra,0x0
  d2:	67c080e7          	jalr	1660(ra) # 74a <kill>
  d6:	85aa                	mv	a1,a0
  d8:	00001517          	auipc	a0,0x1
  dc:	bb850513          	addi	a0,a0,-1096 # c90 <malloc+0x128>
  e0:	00001097          	auipc	ra,0x1
  e4:	9ca080e7          	jalr	-1590(ra) # aaa <printf>
        printf("parent wait for child\n");
  e8:	00001517          	auipc	a0,0x1
  ec:	bb850513          	addi	a0,a0,-1096 # ca0 <malloc+0x138>
  f0:	00001097          	auipc	ra,0x1
  f4:	9ba080e7          	jalr	-1606(ra) # aaa <printf>
        wait(0);
  f8:	4501                	li	a0,0
  fa:	00000097          	auipc	ra,0x0
  fe:	628080e7          	jalr	1576(ra) # 722 <wait>
        printf("parent: child is dead\n");
 102:	00001517          	auipc	a0,0x1
 106:	bb650513          	addi	a0,a0,-1098 # cb8 <malloc+0x150>
 10a:	00001097          	auipc	ra,0x1
 10e:	9a0080e7          	jalr	-1632(ra) # aaa <printf>
        sleep(10);
 112:	4529                	li	a0,10
 114:	00000097          	auipc	ra,0x0
 118:	696080e7          	jalr	1686(ra) # 7aa <sleep>
        exit(0);
 11c:	4501                	li	a0,0
 11e:	00000097          	auipc	ra,0x0
 122:	5fc080e7          	jalr	1532(ra) # 71a <exit>

0000000000000126 <test_usersig>:


void 
test_usersig(){
 126:	7139                	addi	sp,sp,-64
 128:	fc06                	sd	ra,56(sp)
 12a:	f822                	sd	s0,48(sp)
 12c:	f426                	sd	s1,40(sp)
 12e:	f04a                	sd	s2,32(sp)
 130:	0080                	addi	s0,sp,64
    int pid = fork();
 132:	00000097          	auipc	ra,0x0
 136:	5e0080e7          	jalr	1504(ra) # 712 <fork>
    int signum1=3;
    if(pid==0){
 13a:	ed45                	bnez	a0,1f2 <test_usersig+0xcc>
        struct sigaction act;
        struct sigaction act2;

        printf("sighandler= %p\n",&sig_handler);
 13c:	00000597          	auipc	a1,0x0
 140:	ec458593          	addi	a1,a1,-316 # 0 <sig_handler>
 144:	00001517          	auipc	a0,0x1
 148:	b8c50513          	addi	a0,a0,-1140 # cd0 <malloc+0x168>
 14c:	00001097          	auipc	ra,0x1
 150:	95e080e7          	jalr	-1698(ra) # aaa <printf>
        printf("sighandler= %p\n",&sig_handler2);
 154:	00000597          	auipc	a1,0x0
 158:	edc58593          	addi	a1,a1,-292 # 30 <sig_handler2>
 15c:	00001517          	auipc	a0,0x1
 160:	b7450513          	addi	a0,a0,-1164 # cd0 <malloc+0x168>
 164:	00001097          	auipc	ra,0x1
 168:	946080e7          	jalr	-1722(ra) # aaa <printf>
        uint mask = 0;
        mask ^= (1<<22);

        act.sa_handler = &sig_handler2;
 16c:	00000797          	auipc	a5,0x0
 170:	ec478793          	addi	a5,a5,-316 # 30 <sig_handler2>
 174:	fcf43023          	sd	a5,-64(s0)
        act.sigmask = mask;
 178:	004007b7          	lui	a5,0x400
 17c:	fcf42423          	sw	a5,-56(s0)
        // act2.sa_handler = &sig_handler2;
        // act2.sigmask = mask;

        struct sigaction oldact;
        oldact.sigmask=0;
 180:	fc042c23          	sw	zero,-40(s0)
        oldact.sa_handler=0;
 184:	fc043823          	sd	zero,-48(s0)
        int ret=sigaction(signum1,&act,&oldact);
 188:	fd040613          	addi	a2,s0,-48
 18c:	fc040593          	addi	a1,s0,-64
 190:	450d                	li	a0,3
 192:	00000097          	auipc	ra,0x0
 196:	630080e7          	jalr	1584(ra) # 7c2 <sigaction>
 19a:	84aa                	mv	s1,a0
        // int ret2=sigaction(3,&act2,&oldact);
        printf("old act->sa handler= %p, mask=%d\n",oldact.sa_handler,oldact.sigmask);
 19c:	fd842603          	lw	a2,-40(s0)
 1a0:	fd043583          	ld	a1,-48(s0)
 1a4:	00001517          	auipc	a0,0x1
 1a8:	b3c50513          	addi	a0,a0,-1220 # ce0 <malloc+0x178>
 1ac:	00001097          	auipc	ra,0x1
 1b0:	8fe080e7          	jalr	-1794(ra) # aaa <printf>
        printf("child return from sigaction = %d\n",ret);
 1b4:	85a6                	mv	a1,s1
 1b6:	00001517          	auipc	a0,0x1
 1ba:	b5250513          	addi	a0,a0,-1198 # d08 <malloc+0x1a0>
 1be:	00001097          	auipc	ra,0x1
 1c2:	8ec080e7          	jalr	-1812(ra) # aaa <printf>
        sleep(10);
 1c6:	4529                	li	a0,10
 1c8:	00000097          	auipc	ra,0x0
 1cc:	5e2080e7          	jalr	1506(ra) # 7aa <sleep>
 1d0:	44a9                	li	s1,10
        for(int i=0;i<10;i++){
            printf("child doing stuff before exit \n");
 1d2:	00001917          	auipc	s2,0x1
 1d6:	b5e90913          	addi	s2,s2,-1186 # d30 <malloc+0x1c8>
 1da:	854a                	mv	a0,s2
 1dc:	00001097          	auipc	ra,0x1
 1e0:	8ce080e7          	jalr	-1842(ra) # aaa <printf>
        for(int i=0;i<10;i++){
 1e4:	34fd                	addiw	s1,s1,-1
 1e6:	f8f5                	bnez	s1,1da <test_usersig+0xb4>
        }

        exit(0);
 1e8:	4501                	li	a0,0
 1ea:	00000097          	auipc	ra,0x0
 1ee:	530080e7          	jalr	1328(ra) # 71a <exit>
 1f2:	84aa                	mv	s1,a0

    }
    else{
        sleep(5);
 1f4:	4515                	li	a0,5
 1f6:	00000097          	auipc	ra,0x0
 1fa:	5b4080e7          	jalr	1460(ra) # 7aa <sleep>
        printf("parent send sig 3 to child ret=%d\n",kill(pid,signum1));
 1fe:	458d                	li	a1,3
 200:	8526                	mv	a0,s1
 202:	00000097          	auipc	ra,0x0
 206:	548080e7          	jalr	1352(ra) # 74a <kill>
 20a:	85aa                	mv	a1,a0
 20c:	00001517          	auipc	a0,0x1
 210:	b4450513          	addi	a0,a0,-1212 # d50 <malloc+0x1e8>
 214:	00001097          	auipc	ra,0x1
 218:	896080e7          	jalr	-1898(ra) # aaa <printf>
        // printf("parent send sig 4 to child ret=%d\n",kill(pid,4));

        wait(0);
 21c:	4501                	li	a0,0
 21e:	00000097          	auipc	ra,0x0
 222:	504080e7          	jalr	1284(ra) # 722 <wait>
        exit(0);
 226:	4501                	li	a0,0
 228:	00000097          	auipc	ra,0x0
 22c:	4f2080e7          	jalr	1266(ra) # 71a <exit>

0000000000000230 <test_block>:
    }
}
void 
test_block(){//parent block 22 child block 23 
 230:	7179                	addi	sp,sp,-48
 232:	f406                	sd	ra,40(sp)
 234:	f022                	sd	s0,32(sp)
 236:	ec26                	sd	s1,24(sp)
 238:	e84a                	sd	s2,16(sp)
 23a:	e44e                	sd	s3,8(sp)
 23c:	1800                	addi	s0,sp,48
//          child get both signal and need do block the both

    int signum1=22;
    int signum2=23;
    int ans=sigprocmask(1<<signum1);
 23e:	00400537          	lui	a0,0x400
 242:	00000097          	auipc	ra,0x0
 246:	578080e7          	jalr	1400(ra) # 7ba <sigprocmask>
    printf("got %d from calling to sigprocmask\n",ans);
 24a:	0005059b          	sext.w	a1,a0
 24e:	00001517          	auipc	a0,0x1
 252:	b2a50513          	addi	a0,a0,-1238 # d78 <malloc+0x210>
 256:	00001097          	auipc	ra,0x1
 25a:	854080e7          	jalr	-1964(ra) # aaa <printf>
    int pid=fork();
 25e:	00000097          	auipc	ra,0x0
 262:	4b4080e7          	jalr	1204(ra) # 712 <fork>
 266:	84aa                	mv	s1,a0
    if(pid==0){
 268:	c921                	beqz	a0,2b8 <test_block+0x88>
            printf("child blocking signal %d :-)\n",i);
        }
        exit(0);

    }else{
        sleep(1);//wait for child to block sig
 26a:	4505                	li	a0,1
 26c:	00000097          	auipc	ra,0x0
 270:	53e080e7          	jalr	1342(ra) # 7aa <sleep>
        kill(pid,signum1);
 274:	45d9                	li	a1,22
 276:	8526                	mv	a0,s1
 278:	00000097          	auipc	ra,0x0
 27c:	4d2080e7          	jalr	1234(ra) # 74a <kill>
        printf("parent: sent signal 22 to child ->child shuld block\n");
 280:	00001517          	auipc	a0,0x1
 284:	b4050513          	addi	a0,a0,-1216 # dc0 <malloc+0x258>
 288:	00001097          	auipc	ra,0x1
 28c:	822080e7          	jalr	-2014(ra) # aaa <printf>
        // kill(pid,signum2);
        printf("parent: sent signal 23 to child ->child shuld block\n");
 290:	00001517          	auipc	a0,0x1
 294:	b6850513          	addi	a0,a0,-1176 # df8 <malloc+0x290>
 298:	00001097          	auipc	ra,0x1
 29c:	812080e7          	jalr	-2030(ra) # aaa <printf>
        wait(0);
 2a0:	4501                	li	a0,0
 2a2:	00000097          	auipc	ra,0x0
 2a6:	480080e7          	jalr	1152(ra) # 722 <wait>
    }
    // exit(0);
}
 2aa:	70a2                	ld	ra,40(sp)
 2ac:	7402                	ld	s0,32(sp)
 2ae:	64e2                	ld	s1,24(sp)
 2b0:	6942                	ld	s2,16(sp)
 2b2:	69a2                	ld	s3,8(sp)
 2b4:	6145                	addi	sp,sp,48
 2b6:	8082                	ret
        sleep(3);
 2b8:	450d                	li	a0,3
 2ba:	00000097          	auipc	ra,0x0
 2be:	4f0080e7          	jalr	1264(ra) # 7aa <sleep>
            printf("child blocking signal %d :-)\n",i);
 2c2:	00001997          	auipc	s3,0x1
 2c6:	ade98993          	addi	s3,s3,-1314 # da0 <malloc+0x238>
        for(int i=0;i<100;i++){
 2ca:	06400913          	li	s2,100
            printf("child blocking signal %d :-)\n",i);
 2ce:	85a6                	mv	a1,s1
 2d0:	854e                	mv	a0,s3
 2d2:	00000097          	auipc	ra,0x0
 2d6:	7d8080e7          	jalr	2008(ra) # aaa <printf>
        for(int i=0;i<100;i++){
 2da:	2485                	addiw	s1,s1,1
 2dc:	ff2499e3          	bne	s1,s2,2ce <test_block+0x9e>
        exit(0);
 2e0:	4501                	li	a0,0
 2e2:	00000097          	auipc	ra,0x0
 2e6:	438080e7          	jalr	1080(ra) # 71a <exit>

00000000000002ea <test_stop_cont>:

void
test_stop_cont(){
 2ea:	7179                	addi	sp,sp,-48
 2ec:	f406                	sd	ra,40(sp)
 2ee:	f022                	sd	s0,32(sp)
 2f0:	ec26                	sd	s1,24(sp)
 2f2:	e84a                	sd	s2,16(sp)
 2f4:	e44e                	sd	s3,8(sp)
 2f6:	1800                	addi	s0,sp,48
    int pid = fork();
 2f8:	00000097          	auipc	ra,0x0
 2fc:	41a080e7          	jalr	1050(ra) # 712 <fork>
 300:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
 302:	e915                	bnez	a0,336 <test_stop_cont+0x4c>
        sleep(2);
 304:	4509                	li	a0,2
 306:	00000097          	auipc	ra,0x0
 30a:	4a4080e7          	jalr	1188(ra) # 7aa <sleep>
        for(i=0;i<500;i++)
            printf("%d\n ", i);
 30e:	00001997          	auipc	s3,0x1
 312:	b2298993          	addi	s3,s3,-1246 # e30 <malloc+0x2c8>
        for(i=0;i<500;i++)
 316:	1f400913          	li	s2,500
            printf("%d\n ", i);
 31a:	85a6                	mv	a1,s1
 31c:	854e                	mv	a0,s3
 31e:	00000097          	auipc	ra,0x0
 322:	78c080e7          	jalr	1932(ra) # aaa <printf>
        for(i=0;i<500;i++)
 326:	2485                	addiw	s1,s1,1
 328:	ff2499e3          	bne	s1,s2,31a <test_stop_cont+0x30>
        exit(0);
 32c:	4501                	li	a0,0
 32e:	00000097          	auipc	ra,0x0
 332:	3ec080e7          	jalr	1004(ra) # 71a <exit>
    }else{
        printf("son pid=%d, dad pid=%d\n",pid, getpid());
 336:	00000097          	auipc	ra,0x0
 33a:	464080e7          	jalr	1124(ra) # 79a <getpid>
 33e:	862a                	mv	a2,a0
 340:	85a6                	mv	a1,s1
 342:	00001517          	auipc	a0,0x1
 346:	af650513          	addi	a0,a0,-1290 # e38 <malloc+0x2d0>
 34a:	00000097          	auipc	ra,0x0
 34e:	760080e7          	jalr	1888(ra) # aaa <printf>
        sleep(5);
 352:	4515                	li	a0,5
 354:	00000097          	auipc	ra,0x0
 358:	456080e7          	jalr	1110(ra) # 7aa <sleep>
        printf("parent send stop ret= %d\n",kill(pid, SIGSTOP));
 35c:	45c5                	li	a1,17
 35e:	8526                	mv	a0,s1
 360:	00000097          	auipc	ra,0x0
 364:	3ea080e7          	jalr	1002(ra) # 74a <kill>
 368:	85aa                	mv	a1,a0
 36a:	00001517          	auipc	a0,0x1
 36e:	ae650513          	addi	a0,a0,-1306 # e50 <malloc+0x2e8>
 372:	00000097          	auipc	ra,0x0
 376:	738080e7          	jalr	1848(ra) # aaa <printf>
        sleep(50);
 37a:	03200513          	li	a0,50
 37e:	00000097          	auipc	ra,0x0
 382:	42c080e7          	jalr	1068(ra) # 7aa <sleep>
        printf("parent send continue ret= %d\n",kill(pid, SIGCONT));
 386:	45cd                	li	a1,19
 388:	8526                	mv	a0,s1
 38a:	00000097          	auipc	ra,0x0
 38e:	3c0080e7          	jalr	960(ra) # 74a <kill>
 392:	85aa                	mv	a1,a0
 394:	00001517          	auipc	a0,0x1
 398:	adc50513          	addi	a0,a0,-1316 # e70 <malloc+0x308>
 39c:	00000097          	auipc	ra,0x0
 3a0:	70e080e7          	jalr	1806(ra) # aaa <printf>
        wait(0);
 3a4:	4501                	li	a0,0
 3a6:	00000097          	auipc	ra,0x0
 3aa:	37c080e7          	jalr	892(ra) # 722 <wait>
        // for(int i=0;i<100;i++)
        //  printf("parent..");
        sleep(10);
 3ae:	4529                	li	a0,10
 3b0:	00000097          	auipc	ra,0x0
 3b4:	3fa080e7          	jalr	1018(ra) # 7aa <sleep>
        exit(0);
 3b8:	4501                	li	a0,0
 3ba:	00000097          	auipc	ra,0x0
 3be:	360080e7          	jalr	864(ra) # 71a <exit>

00000000000003c2 <test_ignore>:
    }
}

void 
test_ignore(){
 3c2:	1101                	addi	sp,sp,-32
 3c4:	ec06                	sd	ra,24(sp)
 3c6:	e822                	sd	s0,16(sp)
 3c8:	e426                	sd	s1,8(sp)
 3ca:	e04a                	sd	s2,0(sp)
 3cc:	1000                	addi	s0,sp,32
    int pid= fork();
 3ce:	00000097          	auipc	ra,0x0
 3d2:	344080e7          	jalr	836(ra) # 712 <fork>
    int signum=22;
    if(pid==0){
 3d6:	c129                	beqz	a0,418 <test_ignore+0x56>
 3d8:	84aa                	mv	s1,a0
            printf("child ignoring signal :-)\n");
        }
        exit(0);

    }else{
        printf("son pid= %d",pid);
 3da:	85aa                	mv	a1,a0
 3dc:	00001517          	auipc	a0,0x1
 3e0:	b1c50513          	addi	a0,a0,-1252 # ef8 <malloc+0x390>
 3e4:	00000097          	auipc	ra,0x0
 3e8:	6c6080e7          	jalr	1734(ra) # aaa <printf>
        sleep(5);
 3ec:	4515                	li	a0,5
 3ee:	00000097          	auipc	ra,0x0
 3f2:	3bc080e7          	jalr	956(ra) # 7aa <sleep>
        kill(pid,signum);
 3f6:	45d9                	li	a1,22
 3f8:	8526                	mv	a0,s1
 3fa:	00000097          	auipc	ra,0x0
 3fe:	350080e7          	jalr	848(ra) # 74a <kill>
        wait(0);
 402:	4501                	li	a0,0
 404:	00000097          	auipc	ra,0x0
 408:	31e080e7          	jalr	798(ra) # 722 <wait>

    }
}
 40c:	60e2                	ld	ra,24(sp)
 40e:	6442                	ld	s0,16(sp)
 410:	64a2                	ld	s1,8(sp)
 412:	6902                	ld	s2,0(sp)
 414:	6105                	addi	sp,sp,32
 416:	8082                	ret
        newAct=malloc(sizeof(sigaction));
 418:	4505                	li	a0,1
 41a:	00000097          	auipc	ra,0x0
 41e:	74e080e7          	jalr	1870(ra) # b68 <malloc>
 422:	892a                	mv	s2,a0
        oldAct=malloc(sizeof(sigaction));
 424:	4505                	li	a0,1
 426:	00000097          	auipc	ra,0x0
 42a:	742080e7          	jalr	1858(ra) # b68 <malloc>
 42e:	84aa                	mv	s1,a0
        newAct->sigmask = 0;
 430:	00092423          	sw	zero,8(s2)
        newAct->sa_handler=(void*)SIG_IGN;
 434:	4785                	li	a5,1
 436:	00f93023          	sd	a5,0(s2)
        int ans=sigaction(signum,newAct,oldAct);
 43a:	862a                	mv	a2,a0
 43c:	85ca                	mv	a1,s2
 43e:	4559                	li	a0,22
 440:	00000097          	auipc	ra,0x0
 444:	382080e7          	jalr	898(ra) # 7c2 <sigaction>
 448:	85aa                	mv	a1,a0
        printf("ans from sigaction %d, old act returned is: mask= %d address= %d\n",ans,oldAct->sigmask,(uint64)oldAct->sa_handler);
 44a:	6094                	ld	a3,0(s1)
 44c:	4490                	lw	a2,8(s1)
 44e:	00001517          	auipc	a0,0x1
 452:	a4250513          	addi	a0,a0,-1470 # e90 <malloc+0x328>
 456:	00000097          	auipc	ra,0x0
 45a:	654080e7          	jalr	1620(ra) # aaa <printf>
        sleep(6);
 45e:	4519                	li	a0,6
 460:	00000097          	auipc	ra,0x0
 464:	34a080e7          	jalr	842(ra) # 7aa <sleep>
 468:	12c00493          	li	s1,300
            printf("child ignoring signal :-)\n");
 46c:	00001917          	auipc	s2,0x1
 470:	a6c90913          	addi	s2,s2,-1428 # ed8 <malloc+0x370>
 474:	854a                	mv	a0,s2
 476:	00000097          	auipc	ra,0x0
 47a:	634080e7          	jalr	1588(ra) # aaa <printf>
        for(int i=0;i<300;i++){
 47e:	34fd                	addiw	s1,s1,-1
 480:	f8f5                	bnez	s1,474 <test_ignore+0xb2>
        exit(0);
 482:	4501                	li	a0,0
 484:	00000097          	auipc	ra,0x0
 488:	296080e7          	jalr	662(ra) # 71a <exit>

000000000000048c <main>:


int main(){
 48c:	1141                	addi	sp,sp,-16
 48e:	e406                	sd	ra,8(sp)
 490:	e022                	sd	s0,0(sp)
 492:	0800                	addi	s0,sp,16
    // test_sigkill();

    //  printf("-----------------------------test_stop_cont_sig-----------------------------\n");
    // test_stop_cont();
    
    printf("-----------------------------test_usersig-----------------------------\n");
 494:	00001517          	auipc	a0,0x1
 498:	a7450513          	addi	a0,a0,-1420 # f08 <malloc+0x3a0>
 49c:	00000097          	auipc	ra,0x0
 4a0:	60e080e7          	jalr	1550(ra) # aaa <printf>
    test_usersig();
 4a4:	00000097          	auipc	ra,0x0
 4a8:	c82080e7          	jalr	-894(ra) # 126 <test_usersig>

00000000000004ac <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 4ac:	1141                	addi	sp,sp,-16
 4ae:	e422                	sd	s0,8(sp)
 4b0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 4b2:	87aa                	mv	a5,a0
 4b4:	0585                	addi	a1,a1,1
 4b6:	0785                	addi	a5,a5,1
 4b8:	fff5c703          	lbu	a4,-1(a1)
 4bc:	fee78fa3          	sb	a4,-1(a5) # 3fffff <__global_pointer$+0x3fe896>
 4c0:	fb75                	bnez	a4,4b4 <strcpy+0x8>
    ;
  return os;
}
 4c2:	6422                	ld	s0,8(sp)
 4c4:	0141                	addi	sp,sp,16
 4c6:	8082                	ret

00000000000004c8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 4c8:	1141                	addi	sp,sp,-16
 4ca:	e422                	sd	s0,8(sp)
 4cc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 4ce:	00054783          	lbu	a5,0(a0)
 4d2:	cb91                	beqz	a5,4e6 <strcmp+0x1e>
 4d4:	0005c703          	lbu	a4,0(a1)
 4d8:	00f71763          	bne	a4,a5,4e6 <strcmp+0x1e>
    p++, q++;
 4dc:	0505                	addi	a0,a0,1
 4de:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 4e0:	00054783          	lbu	a5,0(a0)
 4e4:	fbe5                	bnez	a5,4d4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 4e6:	0005c503          	lbu	a0,0(a1)
}
 4ea:	40a7853b          	subw	a0,a5,a0
 4ee:	6422                	ld	s0,8(sp)
 4f0:	0141                	addi	sp,sp,16
 4f2:	8082                	ret

00000000000004f4 <strlen>:

uint
strlen(const char *s)
{
 4f4:	1141                	addi	sp,sp,-16
 4f6:	e422                	sd	s0,8(sp)
 4f8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 4fa:	00054783          	lbu	a5,0(a0)
 4fe:	cf91                	beqz	a5,51a <strlen+0x26>
 500:	0505                	addi	a0,a0,1
 502:	87aa                	mv	a5,a0
 504:	4685                	li	a3,1
 506:	9e89                	subw	a3,a3,a0
 508:	00f6853b          	addw	a0,a3,a5
 50c:	0785                	addi	a5,a5,1
 50e:	fff7c703          	lbu	a4,-1(a5)
 512:	fb7d                	bnez	a4,508 <strlen+0x14>
    ;
  return n;
}
 514:	6422                	ld	s0,8(sp)
 516:	0141                	addi	sp,sp,16
 518:	8082                	ret
  for(n = 0; s[n]; n++)
 51a:	4501                	li	a0,0
 51c:	bfe5                	j	514 <strlen+0x20>

000000000000051e <memset>:

void*
memset(void *dst, int c, uint n)
{
 51e:	1141                	addi	sp,sp,-16
 520:	e422                	sd	s0,8(sp)
 522:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 524:	ca19                	beqz	a2,53a <memset+0x1c>
 526:	87aa                	mv	a5,a0
 528:	1602                	slli	a2,a2,0x20
 52a:	9201                	srli	a2,a2,0x20
 52c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 530:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 534:	0785                	addi	a5,a5,1
 536:	fee79de3          	bne	a5,a4,530 <memset+0x12>
  }
  return dst;
}
 53a:	6422                	ld	s0,8(sp)
 53c:	0141                	addi	sp,sp,16
 53e:	8082                	ret

0000000000000540 <strchr>:

char*
strchr(const char *s, char c)
{
 540:	1141                	addi	sp,sp,-16
 542:	e422                	sd	s0,8(sp)
 544:	0800                	addi	s0,sp,16
  for(; *s; s++)
 546:	00054783          	lbu	a5,0(a0)
 54a:	cb99                	beqz	a5,560 <strchr+0x20>
    if(*s == c)
 54c:	00f58763          	beq	a1,a5,55a <strchr+0x1a>
  for(; *s; s++)
 550:	0505                	addi	a0,a0,1
 552:	00054783          	lbu	a5,0(a0)
 556:	fbfd                	bnez	a5,54c <strchr+0xc>
      return (char*)s;
  return 0;
 558:	4501                	li	a0,0
}
 55a:	6422                	ld	s0,8(sp)
 55c:	0141                	addi	sp,sp,16
 55e:	8082                	ret
  return 0;
 560:	4501                	li	a0,0
 562:	bfe5                	j	55a <strchr+0x1a>

0000000000000564 <gets>:

char*
gets(char *buf, int max)
{
 564:	711d                	addi	sp,sp,-96
 566:	ec86                	sd	ra,88(sp)
 568:	e8a2                	sd	s0,80(sp)
 56a:	e4a6                	sd	s1,72(sp)
 56c:	e0ca                	sd	s2,64(sp)
 56e:	fc4e                	sd	s3,56(sp)
 570:	f852                	sd	s4,48(sp)
 572:	f456                	sd	s5,40(sp)
 574:	f05a                	sd	s6,32(sp)
 576:	ec5e                	sd	s7,24(sp)
 578:	1080                	addi	s0,sp,96
 57a:	8baa                	mv	s7,a0
 57c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 57e:	892a                	mv	s2,a0
 580:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 582:	4aa9                	li	s5,10
 584:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 586:	89a6                	mv	s3,s1
 588:	2485                	addiw	s1,s1,1
 58a:	0344d863          	bge	s1,s4,5ba <gets+0x56>
    cc = read(0, &c, 1);
 58e:	4605                	li	a2,1
 590:	faf40593          	addi	a1,s0,-81
 594:	4501                	li	a0,0
 596:	00000097          	auipc	ra,0x0
 59a:	19c080e7          	jalr	412(ra) # 732 <read>
    if(cc < 1)
 59e:	00a05e63          	blez	a0,5ba <gets+0x56>
    buf[i++] = c;
 5a2:	faf44783          	lbu	a5,-81(s0)
 5a6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 5aa:	01578763          	beq	a5,s5,5b8 <gets+0x54>
 5ae:	0905                	addi	s2,s2,1
 5b0:	fd679be3          	bne	a5,s6,586 <gets+0x22>
  for(i=0; i+1 < max; ){
 5b4:	89a6                	mv	s3,s1
 5b6:	a011                	j	5ba <gets+0x56>
 5b8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 5ba:	99de                	add	s3,s3,s7
 5bc:	00098023          	sb	zero,0(s3)
  return buf;
}
 5c0:	855e                	mv	a0,s7
 5c2:	60e6                	ld	ra,88(sp)
 5c4:	6446                	ld	s0,80(sp)
 5c6:	64a6                	ld	s1,72(sp)
 5c8:	6906                	ld	s2,64(sp)
 5ca:	79e2                	ld	s3,56(sp)
 5cc:	7a42                	ld	s4,48(sp)
 5ce:	7aa2                	ld	s5,40(sp)
 5d0:	7b02                	ld	s6,32(sp)
 5d2:	6be2                	ld	s7,24(sp)
 5d4:	6125                	addi	sp,sp,96
 5d6:	8082                	ret

00000000000005d8 <stat>:

int
stat(const char *n, struct stat *st)
{
 5d8:	1101                	addi	sp,sp,-32
 5da:	ec06                	sd	ra,24(sp)
 5dc:	e822                	sd	s0,16(sp)
 5de:	e426                	sd	s1,8(sp)
 5e0:	e04a                	sd	s2,0(sp)
 5e2:	1000                	addi	s0,sp,32
 5e4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 5e6:	4581                	li	a1,0
 5e8:	00000097          	auipc	ra,0x0
 5ec:	172080e7          	jalr	370(ra) # 75a <open>
  if(fd < 0)
 5f0:	02054563          	bltz	a0,61a <stat+0x42>
 5f4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 5f6:	85ca                	mv	a1,s2
 5f8:	00000097          	auipc	ra,0x0
 5fc:	17a080e7          	jalr	378(ra) # 772 <fstat>
 600:	892a                	mv	s2,a0
  close(fd);
 602:	8526                	mv	a0,s1
 604:	00000097          	auipc	ra,0x0
 608:	13e080e7          	jalr	318(ra) # 742 <close>
  return r;
}
 60c:	854a                	mv	a0,s2
 60e:	60e2                	ld	ra,24(sp)
 610:	6442                	ld	s0,16(sp)
 612:	64a2                	ld	s1,8(sp)
 614:	6902                	ld	s2,0(sp)
 616:	6105                	addi	sp,sp,32
 618:	8082                	ret
    return -1;
 61a:	597d                	li	s2,-1
 61c:	bfc5                	j	60c <stat+0x34>

000000000000061e <atoi>:

int
atoi(const char *s)
{
 61e:	1141                	addi	sp,sp,-16
 620:	e422                	sd	s0,8(sp)
 622:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 624:	00054603          	lbu	a2,0(a0)
 628:	fd06079b          	addiw	a5,a2,-48
 62c:	0ff7f793          	andi	a5,a5,255
 630:	4725                	li	a4,9
 632:	02f76963          	bltu	a4,a5,664 <atoi+0x46>
 636:	86aa                	mv	a3,a0
  n = 0;
 638:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 63a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 63c:	0685                	addi	a3,a3,1
 63e:	0025179b          	slliw	a5,a0,0x2
 642:	9fa9                	addw	a5,a5,a0
 644:	0017979b          	slliw	a5,a5,0x1
 648:	9fb1                	addw	a5,a5,a2
 64a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 64e:	0006c603          	lbu	a2,0(a3)
 652:	fd06071b          	addiw	a4,a2,-48
 656:	0ff77713          	andi	a4,a4,255
 65a:	fee5f1e3          	bgeu	a1,a4,63c <atoi+0x1e>
  return n;
}
 65e:	6422                	ld	s0,8(sp)
 660:	0141                	addi	sp,sp,16
 662:	8082                	ret
  n = 0;
 664:	4501                	li	a0,0
 666:	bfe5                	j	65e <atoi+0x40>

0000000000000668 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 668:	1141                	addi	sp,sp,-16
 66a:	e422                	sd	s0,8(sp)
 66c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 66e:	02b57463          	bgeu	a0,a1,696 <memmove+0x2e>
    while(n-- > 0)
 672:	00c05f63          	blez	a2,690 <memmove+0x28>
 676:	1602                	slli	a2,a2,0x20
 678:	9201                	srli	a2,a2,0x20
 67a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 67e:	872a                	mv	a4,a0
      *dst++ = *src++;
 680:	0585                	addi	a1,a1,1
 682:	0705                	addi	a4,a4,1
 684:	fff5c683          	lbu	a3,-1(a1)
 688:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 68c:	fee79ae3          	bne	a5,a4,680 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 690:	6422                	ld	s0,8(sp)
 692:	0141                	addi	sp,sp,16
 694:	8082                	ret
    dst += n;
 696:	00c50733          	add	a4,a0,a2
    src += n;
 69a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 69c:	fec05ae3          	blez	a2,690 <memmove+0x28>
 6a0:	fff6079b          	addiw	a5,a2,-1
 6a4:	1782                	slli	a5,a5,0x20
 6a6:	9381                	srli	a5,a5,0x20
 6a8:	fff7c793          	not	a5,a5
 6ac:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 6ae:	15fd                	addi	a1,a1,-1
 6b0:	177d                	addi	a4,a4,-1
 6b2:	0005c683          	lbu	a3,0(a1)
 6b6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 6ba:	fee79ae3          	bne	a5,a4,6ae <memmove+0x46>
 6be:	bfc9                	j	690 <memmove+0x28>

00000000000006c0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 6c0:	1141                	addi	sp,sp,-16
 6c2:	e422                	sd	s0,8(sp)
 6c4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 6c6:	ca05                	beqz	a2,6f6 <memcmp+0x36>
 6c8:	fff6069b          	addiw	a3,a2,-1
 6cc:	1682                	slli	a3,a3,0x20
 6ce:	9281                	srli	a3,a3,0x20
 6d0:	0685                	addi	a3,a3,1
 6d2:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 6d4:	00054783          	lbu	a5,0(a0)
 6d8:	0005c703          	lbu	a4,0(a1)
 6dc:	00e79863          	bne	a5,a4,6ec <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 6e0:	0505                	addi	a0,a0,1
    p2++;
 6e2:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 6e4:	fed518e3          	bne	a0,a3,6d4 <memcmp+0x14>
  }
  return 0;
 6e8:	4501                	li	a0,0
 6ea:	a019                	j	6f0 <memcmp+0x30>
      return *p1 - *p2;
 6ec:	40e7853b          	subw	a0,a5,a4
}
 6f0:	6422                	ld	s0,8(sp)
 6f2:	0141                	addi	sp,sp,16
 6f4:	8082                	ret
  return 0;
 6f6:	4501                	li	a0,0
 6f8:	bfe5                	j	6f0 <memcmp+0x30>

00000000000006fa <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 6fa:	1141                	addi	sp,sp,-16
 6fc:	e406                	sd	ra,8(sp)
 6fe:	e022                	sd	s0,0(sp)
 700:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 702:	00000097          	auipc	ra,0x0
 706:	f66080e7          	jalr	-154(ra) # 668 <memmove>
}
 70a:	60a2                	ld	ra,8(sp)
 70c:	6402                	ld	s0,0(sp)
 70e:	0141                	addi	sp,sp,16
 710:	8082                	ret

0000000000000712 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 712:	4885                	li	a7,1
 ecall
 714:	00000073          	ecall
 ret
 718:	8082                	ret

000000000000071a <exit>:
.global exit
exit:
 li a7, SYS_exit
 71a:	4889                	li	a7,2
 ecall
 71c:	00000073          	ecall
 ret
 720:	8082                	ret

0000000000000722 <wait>:
.global wait
wait:
 li a7, SYS_wait
 722:	488d                	li	a7,3
 ecall
 724:	00000073          	ecall
 ret
 728:	8082                	ret

000000000000072a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 72a:	4891                	li	a7,4
 ecall
 72c:	00000073          	ecall
 ret
 730:	8082                	ret

0000000000000732 <read>:
.global read
read:
 li a7, SYS_read
 732:	4895                	li	a7,5
 ecall
 734:	00000073          	ecall
 ret
 738:	8082                	ret

000000000000073a <write>:
.global write
write:
 li a7, SYS_write
 73a:	48c1                	li	a7,16
 ecall
 73c:	00000073          	ecall
 ret
 740:	8082                	ret

0000000000000742 <close>:
.global close
close:
 li a7, SYS_close
 742:	48d5                	li	a7,21
 ecall
 744:	00000073          	ecall
 ret
 748:	8082                	ret

000000000000074a <kill>:
.global kill
kill:
 li a7, SYS_kill
 74a:	4899                	li	a7,6
 ecall
 74c:	00000073          	ecall
 ret
 750:	8082                	ret

0000000000000752 <exec>:
.global exec
exec:
 li a7, SYS_exec
 752:	489d                	li	a7,7
 ecall
 754:	00000073          	ecall
 ret
 758:	8082                	ret

000000000000075a <open>:
.global open
open:
 li a7, SYS_open
 75a:	48bd                	li	a7,15
 ecall
 75c:	00000073          	ecall
 ret
 760:	8082                	ret

0000000000000762 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 762:	48c5                	li	a7,17
 ecall
 764:	00000073          	ecall
 ret
 768:	8082                	ret

000000000000076a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 76a:	48c9                	li	a7,18
 ecall
 76c:	00000073          	ecall
 ret
 770:	8082                	ret

0000000000000772 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 772:	48a1                	li	a7,8
 ecall
 774:	00000073          	ecall
 ret
 778:	8082                	ret

000000000000077a <link>:
.global link
link:
 li a7, SYS_link
 77a:	48cd                	li	a7,19
 ecall
 77c:	00000073          	ecall
 ret
 780:	8082                	ret

0000000000000782 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 782:	48d1                	li	a7,20
 ecall
 784:	00000073          	ecall
 ret
 788:	8082                	ret

000000000000078a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 78a:	48a5                	li	a7,9
 ecall
 78c:	00000073          	ecall
 ret
 790:	8082                	ret

0000000000000792 <dup>:
.global dup
dup:
 li a7, SYS_dup
 792:	48a9                	li	a7,10
 ecall
 794:	00000073          	ecall
 ret
 798:	8082                	ret

000000000000079a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 79a:	48ad                	li	a7,11
 ecall
 79c:	00000073          	ecall
 ret
 7a0:	8082                	ret

00000000000007a2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 7a2:	48b1                	li	a7,12
 ecall
 7a4:	00000073          	ecall
 ret
 7a8:	8082                	ret

00000000000007aa <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 7aa:	48b5                	li	a7,13
 ecall
 7ac:	00000073          	ecall
 ret
 7b0:	8082                	ret

00000000000007b2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 7b2:	48b9                	li	a7,14
 ecall
 7b4:	00000073          	ecall
 ret
 7b8:	8082                	ret

00000000000007ba <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
 7ba:	48d9                	li	a7,22
 ecall
 7bc:	00000073          	ecall
 ret
 7c0:	8082                	ret

00000000000007c2 <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
 7c2:	48dd                	li	a7,23
 ecall
 7c4:	00000073          	ecall
 ret
 7c8:	8082                	ret

00000000000007ca <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
 7ca:	48e1                	li	a7,24
 ecall
 7cc:	00000073          	ecall
 ret
 7d0:	8082                	ret

00000000000007d2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 7d2:	1101                	addi	sp,sp,-32
 7d4:	ec06                	sd	ra,24(sp)
 7d6:	e822                	sd	s0,16(sp)
 7d8:	1000                	addi	s0,sp,32
 7da:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 7de:	4605                	li	a2,1
 7e0:	fef40593          	addi	a1,s0,-17
 7e4:	00000097          	auipc	ra,0x0
 7e8:	f56080e7          	jalr	-170(ra) # 73a <write>
}
 7ec:	60e2                	ld	ra,24(sp)
 7ee:	6442                	ld	s0,16(sp)
 7f0:	6105                	addi	sp,sp,32
 7f2:	8082                	ret

00000000000007f4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 7f4:	7139                	addi	sp,sp,-64
 7f6:	fc06                	sd	ra,56(sp)
 7f8:	f822                	sd	s0,48(sp)
 7fa:	f426                	sd	s1,40(sp)
 7fc:	f04a                	sd	s2,32(sp)
 7fe:	ec4e                	sd	s3,24(sp)
 800:	0080                	addi	s0,sp,64
 802:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 804:	c299                	beqz	a3,80a <printint+0x16>
 806:	0805c863          	bltz	a1,896 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 80a:	2581                	sext.w	a1,a1
  neg = 0;
 80c:	4881                	li	a7,0
 80e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 812:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 814:	2601                	sext.w	a2,a2
 816:	00000517          	auipc	a0,0x0
 81a:	74250513          	addi	a0,a0,1858 # f58 <digits>
 81e:	883a                	mv	a6,a4
 820:	2705                	addiw	a4,a4,1
 822:	02c5f7bb          	remuw	a5,a1,a2
 826:	1782                	slli	a5,a5,0x20
 828:	9381                	srli	a5,a5,0x20
 82a:	97aa                	add	a5,a5,a0
 82c:	0007c783          	lbu	a5,0(a5)
 830:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 834:	0005879b          	sext.w	a5,a1
 838:	02c5d5bb          	divuw	a1,a1,a2
 83c:	0685                	addi	a3,a3,1
 83e:	fec7f0e3          	bgeu	a5,a2,81e <printint+0x2a>
  if(neg)
 842:	00088b63          	beqz	a7,858 <printint+0x64>
    buf[i++] = '-';
 846:	fd040793          	addi	a5,s0,-48
 84a:	973e                	add	a4,a4,a5
 84c:	02d00793          	li	a5,45
 850:	fef70823          	sb	a5,-16(a4)
 854:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 858:	02e05863          	blez	a4,888 <printint+0x94>
 85c:	fc040793          	addi	a5,s0,-64
 860:	00e78933          	add	s2,a5,a4
 864:	fff78993          	addi	s3,a5,-1
 868:	99ba                	add	s3,s3,a4
 86a:	377d                	addiw	a4,a4,-1
 86c:	1702                	slli	a4,a4,0x20
 86e:	9301                	srli	a4,a4,0x20
 870:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 874:	fff94583          	lbu	a1,-1(s2)
 878:	8526                	mv	a0,s1
 87a:	00000097          	auipc	ra,0x0
 87e:	f58080e7          	jalr	-168(ra) # 7d2 <putc>
  while(--i >= 0)
 882:	197d                	addi	s2,s2,-1
 884:	ff3918e3          	bne	s2,s3,874 <printint+0x80>
}
 888:	70e2                	ld	ra,56(sp)
 88a:	7442                	ld	s0,48(sp)
 88c:	74a2                	ld	s1,40(sp)
 88e:	7902                	ld	s2,32(sp)
 890:	69e2                	ld	s3,24(sp)
 892:	6121                	addi	sp,sp,64
 894:	8082                	ret
    x = -xx;
 896:	40b005bb          	negw	a1,a1
    neg = 1;
 89a:	4885                	li	a7,1
    x = -xx;
 89c:	bf8d                	j	80e <printint+0x1a>

000000000000089e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 89e:	7119                	addi	sp,sp,-128
 8a0:	fc86                	sd	ra,120(sp)
 8a2:	f8a2                	sd	s0,112(sp)
 8a4:	f4a6                	sd	s1,104(sp)
 8a6:	f0ca                	sd	s2,96(sp)
 8a8:	ecce                	sd	s3,88(sp)
 8aa:	e8d2                	sd	s4,80(sp)
 8ac:	e4d6                	sd	s5,72(sp)
 8ae:	e0da                	sd	s6,64(sp)
 8b0:	fc5e                	sd	s7,56(sp)
 8b2:	f862                	sd	s8,48(sp)
 8b4:	f466                	sd	s9,40(sp)
 8b6:	f06a                	sd	s10,32(sp)
 8b8:	ec6e                	sd	s11,24(sp)
 8ba:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 8bc:	0005c903          	lbu	s2,0(a1)
 8c0:	18090f63          	beqz	s2,a5e <vprintf+0x1c0>
 8c4:	8aaa                	mv	s5,a0
 8c6:	8b32                	mv	s6,a2
 8c8:	00158493          	addi	s1,a1,1
  state = 0;
 8cc:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 8ce:	02500a13          	li	s4,37
      if(c == 'd'){
 8d2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 8d6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 8da:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 8de:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8e2:	00000b97          	auipc	s7,0x0
 8e6:	676b8b93          	addi	s7,s7,1654 # f58 <digits>
 8ea:	a839                	j	908 <vprintf+0x6a>
        putc(fd, c);
 8ec:	85ca                	mv	a1,s2
 8ee:	8556                	mv	a0,s5
 8f0:	00000097          	auipc	ra,0x0
 8f4:	ee2080e7          	jalr	-286(ra) # 7d2 <putc>
 8f8:	a019                	j	8fe <vprintf+0x60>
    } else if(state == '%'){
 8fa:	01498f63          	beq	s3,s4,918 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 8fe:	0485                	addi	s1,s1,1
 900:	fff4c903          	lbu	s2,-1(s1)
 904:	14090d63          	beqz	s2,a5e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 908:	0009079b          	sext.w	a5,s2
    if(state == 0){
 90c:	fe0997e3          	bnez	s3,8fa <vprintf+0x5c>
      if(c == '%'){
 910:	fd479ee3          	bne	a5,s4,8ec <vprintf+0x4e>
        state = '%';
 914:	89be                	mv	s3,a5
 916:	b7e5                	j	8fe <vprintf+0x60>
      if(c == 'd'){
 918:	05878063          	beq	a5,s8,958 <vprintf+0xba>
      } else if(c == 'l') {
 91c:	05978c63          	beq	a5,s9,974 <vprintf+0xd6>
      } else if(c == 'x') {
 920:	07a78863          	beq	a5,s10,990 <vprintf+0xf2>
      } else if(c == 'p') {
 924:	09b78463          	beq	a5,s11,9ac <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 928:	07300713          	li	a4,115
 92c:	0ce78663          	beq	a5,a4,9f8 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 930:	06300713          	li	a4,99
 934:	0ee78e63          	beq	a5,a4,a30 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 938:	11478863          	beq	a5,s4,a48 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 93c:	85d2                	mv	a1,s4
 93e:	8556                	mv	a0,s5
 940:	00000097          	auipc	ra,0x0
 944:	e92080e7          	jalr	-366(ra) # 7d2 <putc>
        putc(fd, c);
 948:	85ca                	mv	a1,s2
 94a:	8556                	mv	a0,s5
 94c:	00000097          	auipc	ra,0x0
 950:	e86080e7          	jalr	-378(ra) # 7d2 <putc>
      }
      state = 0;
 954:	4981                	li	s3,0
 956:	b765                	j	8fe <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 958:	008b0913          	addi	s2,s6,8
 95c:	4685                	li	a3,1
 95e:	4629                	li	a2,10
 960:	000b2583          	lw	a1,0(s6)
 964:	8556                	mv	a0,s5
 966:	00000097          	auipc	ra,0x0
 96a:	e8e080e7          	jalr	-370(ra) # 7f4 <printint>
 96e:	8b4a                	mv	s6,s2
      state = 0;
 970:	4981                	li	s3,0
 972:	b771                	j	8fe <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 974:	008b0913          	addi	s2,s6,8
 978:	4681                	li	a3,0
 97a:	4629                	li	a2,10
 97c:	000b2583          	lw	a1,0(s6)
 980:	8556                	mv	a0,s5
 982:	00000097          	auipc	ra,0x0
 986:	e72080e7          	jalr	-398(ra) # 7f4 <printint>
 98a:	8b4a                	mv	s6,s2
      state = 0;
 98c:	4981                	li	s3,0
 98e:	bf85                	j	8fe <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 990:	008b0913          	addi	s2,s6,8
 994:	4681                	li	a3,0
 996:	4641                	li	a2,16
 998:	000b2583          	lw	a1,0(s6)
 99c:	8556                	mv	a0,s5
 99e:	00000097          	auipc	ra,0x0
 9a2:	e56080e7          	jalr	-426(ra) # 7f4 <printint>
 9a6:	8b4a                	mv	s6,s2
      state = 0;
 9a8:	4981                	li	s3,0
 9aa:	bf91                	j	8fe <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 9ac:	008b0793          	addi	a5,s6,8
 9b0:	f8f43423          	sd	a5,-120(s0)
 9b4:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 9b8:	03000593          	li	a1,48
 9bc:	8556                	mv	a0,s5
 9be:	00000097          	auipc	ra,0x0
 9c2:	e14080e7          	jalr	-492(ra) # 7d2 <putc>
  putc(fd, 'x');
 9c6:	85ea                	mv	a1,s10
 9c8:	8556                	mv	a0,s5
 9ca:	00000097          	auipc	ra,0x0
 9ce:	e08080e7          	jalr	-504(ra) # 7d2 <putc>
 9d2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 9d4:	03c9d793          	srli	a5,s3,0x3c
 9d8:	97de                	add	a5,a5,s7
 9da:	0007c583          	lbu	a1,0(a5)
 9de:	8556                	mv	a0,s5
 9e0:	00000097          	auipc	ra,0x0
 9e4:	df2080e7          	jalr	-526(ra) # 7d2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 9e8:	0992                	slli	s3,s3,0x4
 9ea:	397d                	addiw	s2,s2,-1
 9ec:	fe0914e3          	bnez	s2,9d4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 9f0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 9f4:	4981                	li	s3,0
 9f6:	b721                	j	8fe <vprintf+0x60>
        s = va_arg(ap, char*);
 9f8:	008b0993          	addi	s3,s6,8
 9fc:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 a00:	02090163          	beqz	s2,a22 <vprintf+0x184>
        while(*s != 0){
 a04:	00094583          	lbu	a1,0(s2)
 a08:	c9a1                	beqz	a1,a58 <vprintf+0x1ba>
          putc(fd, *s);
 a0a:	8556                	mv	a0,s5
 a0c:	00000097          	auipc	ra,0x0
 a10:	dc6080e7          	jalr	-570(ra) # 7d2 <putc>
          s++;
 a14:	0905                	addi	s2,s2,1
        while(*s != 0){
 a16:	00094583          	lbu	a1,0(s2)
 a1a:	f9e5                	bnez	a1,a0a <vprintf+0x16c>
        s = va_arg(ap, char*);
 a1c:	8b4e                	mv	s6,s3
      state = 0;
 a1e:	4981                	li	s3,0
 a20:	bdf9                	j	8fe <vprintf+0x60>
          s = "(null)";
 a22:	00000917          	auipc	s2,0x0
 a26:	52e90913          	addi	s2,s2,1326 # f50 <malloc+0x3e8>
        while(*s != 0){
 a2a:	02800593          	li	a1,40
 a2e:	bff1                	j	a0a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 a30:	008b0913          	addi	s2,s6,8
 a34:	000b4583          	lbu	a1,0(s6)
 a38:	8556                	mv	a0,s5
 a3a:	00000097          	auipc	ra,0x0
 a3e:	d98080e7          	jalr	-616(ra) # 7d2 <putc>
 a42:	8b4a                	mv	s6,s2
      state = 0;
 a44:	4981                	li	s3,0
 a46:	bd65                	j	8fe <vprintf+0x60>
        putc(fd, c);
 a48:	85d2                	mv	a1,s4
 a4a:	8556                	mv	a0,s5
 a4c:	00000097          	auipc	ra,0x0
 a50:	d86080e7          	jalr	-634(ra) # 7d2 <putc>
      state = 0;
 a54:	4981                	li	s3,0
 a56:	b565                	j	8fe <vprintf+0x60>
        s = va_arg(ap, char*);
 a58:	8b4e                	mv	s6,s3
      state = 0;
 a5a:	4981                	li	s3,0
 a5c:	b54d                	j	8fe <vprintf+0x60>
    }
  }
}
 a5e:	70e6                	ld	ra,120(sp)
 a60:	7446                	ld	s0,112(sp)
 a62:	74a6                	ld	s1,104(sp)
 a64:	7906                	ld	s2,96(sp)
 a66:	69e6                	ld	s3,88(sp)
 a68:	6a46                	ld	s4,80(sp)
 a6a:	6aa6                	ld	s5,72(sp)
 a6c:	6b06                	ld	s6,64(sp)
 a6e:	7be2                	ld	s7,56(sp)
 a70:	7c42                	ld	s8,48(sp)
 a72:	7ca2                	ld	s9,40(sp)
 a74:	7d02                	ld	s10,32(sp)
 a76:	6de2                	ld	s11,24(sp)
 a78:	6109                	addi	sp,sp,128
 a7a:	8082                	ret

0000000000000a7c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 a7c:	715d                	addi	sp,sp,-80
 a7e:	ec06                	sd	ra,24(sp)
 a80:	e822                	sd	s0,16(sp)
 a82:	1000                	addi	s0,sp,32
 a84:	e010                	sd	a2,0(s0)
 a86:	e414                	sd	a3,8(s0)
 a88:	e818                	sd	a4,16(s0)
 a8a:	ec1c                	sd	a5,24(s0)
 a8c:	03043023          	sd	a6,32(s0)
 a90:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 a94:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 a98:	8622                	mv	a2,s0
 a9a:	00000097          	auipc	ra,0x0
 a9e:	e04080e7          	jalr	-508(ra) # 89e <vprintf>
}
 aa2:	60e2                	ld	ra,24(sp)
 aa4:	6442                	ld	s0,16(sp)
 aa6:	6161                	addi	sp,sp,80
 aa8:	8082                	ret

0000000000000aaa <printf>:

void
printf(const char *fmt, ...)
{
 aaa:	711d                	addi	sp,sp,-96
 aac:	ec06                	sd	ra,24(sp)
 aae:	e822                	sd	s0,16(sp)
 ab0:	1000                	addi	s0,sp,32
 ab2:	e40c                	sd	a1,8(s0)
 ab4:	e810                	sd	a2,16(s0)
 ab6:	ec14                	sd	a3,24(s0)
 ab8:	f018                	sd	a4,32(s0)
 aba:	f41c                	sd	a5,40(s0)
 abc:	03043823          	sd	a6,48(s0)
 ac0:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 ac4:	00840613          	addi	a2,s0,8
 ac8:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 acc:	85aa                	mv	a1,a0
 ace:	4505                	li	a0,1
 ad0:	00000097          	auipc	ra,0x0
 ad4:	dce080e7          	jalr	-562(ra) # 89e <vprintf>
}
 ad8:	60e2                	ld	ra,24(sp)
 ada:	6442                	ld	s0,16(sp)
 adc:	6125                	addi	sp,sp,96
 ade:	8082                	ret

0000000000000ae0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 ae0:	1141                	addi	sp,sp,-16
 ae2:	e422                	sd	s0,8(sp)
 ae4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ae6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 aea:	00000797          	auipc	a5,0x0
 aee:	4867b783          	ld	a5,1158(a5) # f70 <freep>
 af2:	a805                	j	b22 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 af4:	4618                	lw	a4,8(a2)
 af6:	9db9                	addw	a1,a1,a4
 af8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 afc:	6398                	ld	a4,0(a5)
 afe:	6318                	ld	a4,0(a4)
 b00:	fee53823          	sd	a4,-16(a0)
 b04:	a091                	j	b48 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b06:	ff852703          	lw	a4,-8(a0)
 b0a:	9e39                	addw	a2,a2,a4
 b0c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 b0e:	ff053703          	ld	a4,-16(a0)
 b12:	e398                	sd	a4,0(a5)
 b14:	a099                	j	b5a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b16:	6398                	ld	a4,0(a5)
 b18:	00e7e463          	bltu	a5,a4,b20 <free+0x40>
 b1c:	00e6ea63          	bltu	a3,a4,b30 <free+0x50>
{
 b20:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b22:	fed7fae3          	bgeu	a5,a3,b16 <free+0x36>
 b26:	6398                	ld	a4,0(a5)
 b28:	00e6e463          	bltu	a3,a4,b30 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b2c:	fee7eae3          	bltu	a5,a4,b20 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 b30:	ff852583          	lw	a1,-8(a0)
 b34:	6390                	ld	a2,0(a5)
 b36:	02059813          	slli	a6,a1,0x20
 b3a:	01c85713          	srli	a4,a6,0x1c
 b3e:	9736                	add	a4,a4,a3
 b40:	fae60ae3          	beq	a2,a4,af4 <free+0x14>
    bp->s.ptr = p->s.ptr;
 b44:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b48:	4790                	lw	a2,8(a5)
 b4a:	02061593          	slli	a1,a2,0x20
 b4e:	01c5d713          	srli	a4,a1,0x1c
 b52:	973e                	add	a4,a4,a5
 b54:	fae689e3          	beq	a3,a4,b06 <free+0x26>
  } else
    p->s.ptr = bp;
 b58:	e394                	sd	a3,0(a5)
  freep = p;
 b5a:	00000717          	auipc	a4,0x0
 b5e:	40f73b23          	sd	a5,1046(a4) # f70 <freep>
}
 b62:	6422                	ld	s0,8(sp)
 b64:	0141                	addi	sp,sp,16
 b66:	8082                	ret

0000000000000b68 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 b68:	7139                	addi	sp,sp,-64
 b6a:	fc06                	sd	ra,56(sp)
 b6c:	f822                	sd	s0,48(sp)
 b6e:	f426                	sd	s1,40(sp)
 b70:	f04a                	sd	s2,32(sp)
 b72:	ec4e                	sd	s3,24(sp)
 b74:	e852                	sd	s4,16(sp)
 b76:	e456                	sd	s5,8(sp)
 b78:	e05a                	sd	s6,0(sp)
 b7a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 b7c:	02051493          	slli	s1,a0,0x20
 b80:	9081                	srli	s1,s1,0x20
 b82:	04bd                	addi	s1,s1,15
 b84:	8091                	srli	s1,s1,0x4
 b86:	0014899b          	addiw	s3,s1,1
 b8a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 b8c:	00000517          	auipc	a0,0x0
 b90:	3e453503          	ld	a0,996(a0) # f70 <freep>
 b94:	c515                	beqz	a0,bc0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b96:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b98:	4798                	lw	a4,8(a5)
 b9a:	02977f63          	bgeu	a4,s1,bd8 <malloc+0x70>
 b9e:	8a4e                	mv	s4,s3
 ba0:	0009871b          	sext.w	a4,s3
 ba4:	6685                	lui	a3,0x1
 ba6:	00d77363          	bgeu	a4,a3,bac <malloc+0x44>
 baa:	6a05                	lui	s4,0x1
 bac:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 bb0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 bb4:	00000917          	auipc	s2,0x0
 bb8:	3bc90913          	addi	s2,s2,956 # f70 <freep>
  if(p == (char*)-1)
 bbc:	5afd                	li	s5,-1
 bbe:	a895                	j	c32 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 bc0:	00000797          	auipc	a5,0x0
 bc4:	3b878793          	addi	a5,a5,952 # f78 <base>
 bc8:	00000717          	auipc	a4,0x0
 bcc:	3af73423          	sd	a5,936(a4) # f70 <freep>
 bd0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 bd2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 bd6:	b7e1                	j	b9e <malloc+0x36>
      if(p->s.size == nunits)
 bd8:	02e48c63          	beq	s1,a4,c10 <malloc+0xa8>
        p->s.size -= nunits;
 bdc:	4137073b          	subw	a4,a4,s3
 be0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 be2:	02071693          	slli	a3,a4,0x20
 be6:	01c6d713          	srli	a4,a3,0x1c
 bea:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 bec:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 bf0:	00000717          	auipc	a4,0x0
 bf4:	38a73023          	sd	a0,896(a4) # f70 <freep>
      return (void*)(p + 1);
 bf8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 bfc:	70e2                	ld	ra,56(sp)
 bfe:	7442                	ld	s0,48(sp)
 c00:	74a2                	ld	s1,40(sp)
 c02:	7902                	ld	s2,32(sp)
 c04:	69e2                	ld	s3,24(sp)
 c06:	6a42                	ld	s4,16(sp)
 c08:	6aa2                	ld	s5,8(sp)
 c0a:	6b02                	ld	s6,0(sp)
 c0c:	6121                	addi	sp,sp,64
 c0e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 c10:	6398                	ld	a4,0(a5)
 c12:	e118                	sd	a4,0(a0)
 c14:	bff1                	j	bf0 <malloc+0x88>
  hp->s.size = nu;
 c16:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 c1a:	0541                	addi	a0,a0,16
 c1c:	00000097          	auipc	ra,0x0
 c20:	ec4080e7          	jalr	-316(ra) # ae0 <free>
  return freep;
 c24:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 c28:	d971                	beqz	a0,bfc <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c2a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c2c:	4798                	lw	a4,8(a5)
 c2e:	fa9775e3          	bgeu	a4,s1,bd8 <malloc+0x70>
    if(p == freep)
 c32:	00093703          	ld	a4,0(s2)
 c36:	853e                	mv	a0,a5
 c38:	fef719e3          	bne	a4,a5,c2a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 c3c:	8552                	mv	a0,s4
 c3e:	00000097          	auipc	ra,0x0
 c42:	b64080e7          	jalr	-1180(ra) # 7a2 <sbrk>
  if(p == (char*)-1)
 c46:	fd5518e3          	bne	a0,s5,c16 <malloc+0xae>
        return 0;
 c4a:	4501                	li	a0,0
 c4c:	bf45                	j	bfc <malloc+0x94>
