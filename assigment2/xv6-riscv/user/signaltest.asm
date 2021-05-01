
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
   c:	17778793          	addi	a5,a5,375 # a706177 <__global_pointer$+0xa704826>
  10:	fef42423          	sw	a5,-24(s0)
  14:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
  18:	4615                	li	a2,5
  1a:	fe840593          	addi	a1,s0,-24
  1e:	4505                	li	a0,1
  20:	00001097          	auipc	ra,0x1
  24:	86e080e7          	jalr	-1938(ra) # 88e <write>
    return;
}
  28:	60e2                	ld	ra,24(sp)
  2a:	6442                	ld	s0,16(sp)
  2c:	6105                	addi	sp,sp,32
  2e:	8082                	ret

0000000000000030 <sig_handler_loop>:

void
sig_handler_loop(int signum){
  30:	7179                	addi	sp,sp,-48
  32:	f406                	sd	ra,40(sp)
  34:	f022                	sd	s0,32(sp)
  36:	ec26                	sd	s1,24(sp)
  38:	1800                	addi	s0,sp,48
    char st[5] = "dap\n";
  3a:	0a7067b7          	lui	a5,0xa706
  3e:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa704813>
  42:	fcf42c23          	sw	a5,-40(s0)
  46:	fc040e23          	sb	zero,-36(s0)
  4a:	1f400493          	li	s1,500
    for(int i=0;i<500;i++){
        // write(1,i,sizeof(int));
        write(1, st, 5);
  4e:	4615                	li	a2,5
  50:	fd840593          	addi	a1,s0,-40
  54:	4505                	li	a0,1
  56:	00001097          	auipc	ra,0x1
  5a:	838080e7          	jalr	-1992(ra) # 88e <write>
    for(int i=0;i<500;i++){
  5e:	34fd                	addiw	s1,s1,-1
  60:	f4fd                	bnez	s1,4e <sig_handler_loop+0x1e>
    }
    
    return;
}
  62:	70a2                	ld	ra,40(sp)
  64:	7402                	ld	s0,32(sp)
  66:	64e2                	ld	s1,24(sp)
  68:	6145                	addi	sp,sp,48
  6a:	8082                	ret

000000000000006c <sig_handler2>:
void
sig_handler2(int signum){
  6c:	1101                	addi	sp,sp,-32
  6e:	ec06                	sd	ra,24(sp)
  70:	e822                	sd	s0,16(sp)
  72:	1000                	addi	s0,sp,32
    char st[5] = "dap\n";
  74:	0a7067b7          	lui	a5,0xa706
  78:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa704813>
  7c:	fef42423          	sw	a5,-24(s0)
  80:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
  84:	4615                	li	a2,5
  86:	fe840593          	addi	a1,s0,-24
  8a:	4505                	li	a0,1
  8c:	00001097          	auipc	ra,0x1
  90:	802080e7          	jalr	-2046(ra) # 88e <write>
    return;
}
  94:	60e2                	ld	ra,24(sp)
  96:	6442                	ld	s0,16(sp)
  98:	6105                	addi	sp,sp,32
  9a:	8082                	ret

000000000000009c <test_sigkill>:
test_sigkill(){//
  9c:	7179                	addi	sp,sp,-48
  9e:	f406                	sd	ra,40(sp)
  a0:	f022                	sd	s0,32(sp)
  a2:	ec26                	sd	s1,24(sp)
  a4:	e84a                	sd	s2,16(sp)
  a6:	e44e                	sd	s3,8(sp)
  a8:	1800                	addi	s0,sp,48
   int pid = fork();
  aa:	00000097          	auipc	ra,0x0
  ae:	7bc080e7          	jalr	1980(ra) # 866 <fork>
  b2:	84aa                	mv	s1,a0
    if(pid==0){
  b4:	ed05                	bnez	a0,ec <test_sigkill+0x50>
        sleep(5);
  b6:	4515                	li	a0,5
  b8:	00001097          	auipc	ra,0x1
  bc:	846080e7          	jalr	-1978(ra) # 8fe <sleep>
            printf("about to get killed %d\n",i);
  c0:	00001997          	auipc	s3,0x1
  c4:	d0898993          	addi	s3,s3,-760 # dc8 <malloc+0xec>
        for(int i=0;i<300;i++)
  c8:	12c00913          	li	s2,300
            printf("about to get killed %d\n",i);
  cc:	85a6                	mv	a1,s1
  ce:	854e                	mv	a0,s3
  d0:	00001097          	auipc	ra,0x1
  d4:	b4e080e7          	jalr	-1202(ra) # c1e <printf>
        for(int i=0;i<300;i++)
  d8:	2485                	addiw	s1,s1,1
  da:	ff2499e3          	bne	s1,s2,cc <test_sigkill+0x30>
}
  de:	70a2                	ld	ra,40(sp)
  e0:	7402                	ld	s0,32(sp)
  e2:	64e2                	ld	s1,24(sp)
  e4:	6942                	ld	s2,16(sp)
  e6:	69a2                	ld	s3,8(sp)
  e8:	6145                	addi	sp,sp,48
  ea:	8082                	ret
        sleep(7);
  ec:	451d                	li	a0,7
  ee:	00001097          	auipc	ra,0x1
  f2:	810080e7          	jalr	-2032(ra) # 8fe <sleep>
        printf("parent send signal to to kill child\n");
  f6:	00001517          	auipc	a0,0x1
  fa:	cea50513          	addi	a0,a0,-790 # de0 <malloc+0x104>
  fe:	00001097          	auipc	ra,0x1
 102:	b20080e7          	jalr	-1248(ra) # c1e <printf>
        printf("kill ret= %d\n",kill(pid, SIGKILL));
 106:	45a5                	li	a1,9
 108:	8526                	mv	a0,s1
 10a:	00000097          	auipc	ra,0x0
 10e:	794080e7          	jalr	1940(ra) # 89e <kill>
 112:	85aa                	mv	a1,a0
 114:	00001517          	auipc	a0,0x1
 118:	cf450513          	addi	a0,a0,-780 # e08 <malloc+0x12c>
 11c:	00001097          	auipc	ra,0x1
 120:	b02080e7          	jalr	-1278(ra) # c1e <printf>
        printf("parent wait for child\n");
 124:	00001517          	auipc	a0,0x1
 128:	cf450513          	addi	a0,a0,-780 # e18 <malloc+0x13c>
 12c:	00001097          	auipc	ra,0x1
 130:	af2080e7          	jalr	-1294(ra) # c1e <printf>
        wait(0);
 134:	4501                	li	a0,0
 136:	00000097          	auipc	ra,0x0
 13a:	740080e7          	jalr	1856(ra) # 876 <wait>
        printf("parent: child is dead\n");
 13e:	00001517          	auipc	a0,0x1
 142:	cf250513          	addi	a0,a0,-782 # e30 <malloc+0x154>
 146:	00001097          	auipc	ra,0x1
 14a:	ad8080e7          	jalr	-1320(ra) # c1e <printf>
        sleep(10);
 14e:	4529                	li	a0,10
 150:	00000097          	auipc	ra,0x0
 154:	7ae080e7          	jalr	1966(ra) # 8fe <sleep>
        exit(0);
 158:	4501                	li	a0,0
 15a:	00000097          	auipc	ra,0x0
 15e:	714080e7          	jalr	1812(ra) # 86e <exit>

0000000000000162 <test_usersig>:


void 
test_usersig(){
 162:	7139                	addi	sp,sp,-64
 164:	fc06                	sd	ra,56(sp)
 166:	f822                	sd	s0,48(sp)
 168:	f426                	sd	s1,40(sp)
 16a:	f04a                	sd	s2,32(sp)
 16c:	0080                	addi	s0,sp,64
    int pid = fork();
 16e:	00000097          	auipc	ra,0x0
 172:	6f8080e7          	jalr	1784(ra) # 866 <fork>
    int signum1=3;
    if(pid==0){
 176:	ed45                	bnez	a0,22e <test_usersig+0xcc>
        struct sigaction act;
        struct sigaction act2;

        printf("sighandler= %p\n",&sig_handler);
 178:	00000597          	auipc	a1,0x0
 17c:	e8858593          	addi	a1,a1,-376 # 0 <sig_handler>
 180:	00001517          	auipc	a0,0x1
 184:	cc850513          	addi	a0,a0,-824 # e48 <malloc+0x16c>
 188:	00001097          	auipc	ra,0x1
 18c:	a96080e7          	jalr	-1386(ra) # c1e <printf>
        printf("sighandler= %p\n",&sig_handler2);
 190:	00000597          	auipc	a1,0x0
 194:	edc58593          	addi	a1,a1,-292 # 6c <sig_handler2>
 198:	00001517          	auipc	a0,0x1
 19c:	cb050513          	addi	a0,a0,-848 # e48 <malloc+0x16c>
 1a0:	00001097          	auipc	ra,0x1
 1a4:	a7e080e7          	jalr	-1410(ra) # c1e <printf>
        uint mask = 0;
        mask ^= (1<<22);

        act.sa_handler = &sig_handler2;
 1a8:	00000797          	auipc	a5,0x0
 1ac:	ec478793          	addi	a5,a5,-316 # 6c <sig_handler2>
 1b0:	fcf43023          	sd	a5,-64(s0)
        act.sigmask = mask;
 1b4:	004007b7          	lui	a5,0x400
 1b8:	fcf42423          	sw	a5,-56(s0)
        // act2.sa_handler = &sig_handler2;
        // act2.sigmask = mask;

        struct sigaction oldact;
        oldact.sigmask=0;
 1bc:	fc042c23          	sw	zero,-40(s0)
        oldact.sa_handler=0;
 1c0:	fc043823          	sd	zero,-48(s0)
        int ret=sigaction(signum1,&act,&oldact);
 1c4:	fd040613          	addi	a2,s0,-48
 1c8:	fc040593          	addi	a1,s0,-64
 1cc:	450d                	li	a0,3
 1ce:	00000097          	auipc	ra,0x0
 1d2:	748080e7          	jalr	1864(ra) # 916 <sigaction>
 1d6:	84aa                	mv	s1,a0
        // int ret2=sigaction(3,&act2,&oldact);
        printf("old act->sa handler= %p, mask=%d\n",oldact.sa_handler,oldact.sigmask);
 1d8:	fd842603          	lw	a2,-40(s0)
 1dc:	fd043583          	ld	a1,-48(s0)
 1e0:	00001517          	auipc	a0,0x1
 1e4:	c7850513          	addi	a0,a0,-904 # e58 <malloc+0x17c>
 1e8:	00001097          	auipc	ra,0x1
 1ec:	a36080e7          	jalr	-1482(ra) # c1e <printf>
        printf("child return from sigaction = %d\n",ret);
 1f0:	85a6                	mv	a1,s1
 1f2:	00001517          	auipc	a0,0x1
 1f6:	c8e50513          	addi	a0,a0,-882 # e80 <malloc+0x1a4>
 1fa:	00001097          	auipc	ra,0x1
 1fe:	a24080e7          	jalr	-1500(ra) # c1e <printf>
        sleep(10);
 202:	4529                	li	a0,10
 204:	00000097          	auipc	ra,0x0
 208:	6fa080e7          	jalr	1786(ra) # 8fe <sleep>
 20c:	44a9                	li	s1,10
        for(int i=0;i<10;i++){
            printf("child doing stuff before exit \n");
 20e:	00001917          	auipc	s2,0x1
 212:	c9a90913          	addi	s2,s2,-870 # ea8 <malloc+0x1cc>
 216:	854a                	mv	a0,s2
 218:	00001097          	auipc	ra,0x1
 21c:	a06080e7          	jalr	-1530(ra) # c1e <printf>
        for(int i=0;i<10;i++){
 220:	34fd                	addiw	s1,s1,-1
 222:	f8f5                	bnez	s1,216 <test_usersig+0xb4>
        }

        exit(0);
 224:	4501                	li	a0,0
 226:	00000097          	auipc	ra,0x0
 22a:	648080e7          	jalr	1608(ra) # 86e <exit>
 22e:	84aa                	mv	s1,a0

    }
    else{
        sleep(5);
 230:	4515                	li	a0,5
 232:	00000097          	auipc	ra,0x0
 236:	6cc080e7          	jalr	1740(ra) # 8fe <sleep>
        printf("parent send sig 3 to child ret=%d\n",kill(pid,signum1));
 23a:	458d                	li	a1,3
 23c:	8526                	mv	a0,s1
 23e:	00000097          	auipc	ra,0x0
 242:	660080e7          	jalr	1632(ra) # 89e <kill>
 246:	85aa                	mv	a1,a0
 248:	00001517          	auipc	a0,0x1
 24c:	c8050513          	addi	a0,a0,-896 # ec8 <malloc+0x1ec>
 250:	00001097          	auipc	ra,0x1
 254:	9ce080e7          	jalr	-1586(ra) # c1e <printf>
        // printf("parent send sig 4 to child ret=%d\n",kill(pid,4));

        wait(0);
 258:	4501                	li	a0,0
 25a:	00000097          	auipc	ra,0x0
 25e:	61c080e7          	jalr	1564(ra) # 876 <wait>
        exit(0);
 262:	4501                	li	a0,0
 264:	00000097          	auipc	ra,0x0
 268:	60a080e7          	jalr	1546(ra) # 86e <exit>

000000000000026c <test_block>:
    }
}
void 
test_block(){//parent block 22 child block 23 
 26c:	7179                	addi	sp,sp,-48
 26e:	f406                	sd	ra,40(sp)
 270:	f022                	sd	s0,32(sp)
 272:	ec26                	sd	s1,24(sp)
 274:	e84a                	sd	s2,16(sp)
 276:	e44e                	sd	s3,8(sp)
 278:	1800                	addi	s0,sp,48
//          child get both signal and need do block the both

    int signum1=22;
    int signum2=23;
    int ans=sigprocmask(1<<signum1);
 27a:	00400537          	lui	a0,0x400
 27e:	00000097          	auipc	ra,0x0
 282:	690080e7          	jalr	1680(ra) # 90e <sigprocmask>
    printf("got %d from calling to sigprocmask\n",ans);
 286:	0005059b          	sext.w	a1,a0
 28a:	00001517          	auipc	a0,0x1
 28e:	c6650513          	addi	a0,a0,-922 # ef0 <malloc+0x214>
 292:	00001097          	auipc	ra,0x1
 296:	98c080e7          	jalr	-1652(ra) # c1e <printf>
    int pid=fork();
 29a:	00000097          	auipc	ra,0x0
 29e:	5cc080e7          	jalr	1484(ra) # 866 <fork>
 2a2:	84aa                	mv	s1,a0
    if(pid==0){
 2a4:	c921                	beqz	a0,2f4 <test_block+0x88>
            printf("child blocking signal %d :-)\n",i);
        }
        exit(0);

    }else{
        sleep(1);//wait for child to block sig
 2a6:	4505                	li	a0,1
 2a8:	00000097          	auipc	ra,0x0
 2ac:	656080e7          	jalr	1622(ra) # 8fe <sleep>
        kill(pid,signum1);
 2b0:	45d9                	li	a1,22
 2b2:	8526                	mv	a0,s1
 2b4:	00000097          	auipc	ra,0x0
 2b8:	5ea080e7          	jalr	1514(ra) # 89e <kill>
        printf("parent: sent signal 22 to child ->child shuld block\n");
 2bc:	00001517          	auipc	a0,0x1
 2c0:	c7c50513          	addi	a0,a0,-900 # f38 <malloc+0x25c>
 2c4:	00001097          	auipc	ra,0x1
 2c8:	95a080e7          	jalr	-1702(ra) # c1e <printf>
        // kill(pid,signum2);
        printf("parent: sent signal 23 to child ->child shuld block\n");
 2cc:	00001517          	auipc	a0,0x1
 2d0:	ca450513          	addi	a0,a0,-860 # f70 <malloc+0x294>
 2d4:	00001097          	auipc	ra,0x1
 2d8:	94a080e7          	jalr	-1718(ra) # c1e <printf>
        wait(0);
 2dc:	4501                	li	a0,0
 2de:	00000097          	auipc	ra,0x0
 2e2:	598080e7          	jalr	1432(ra) # 876 <wait>
    }
    // exit(0);
}
 2e6:	70a2                	ld	ra,40(sp)
 2e8:	7402                	ld	s0,32(sp)
 2ea:	64e2                	ld	s1,24(sp)
 2ec:	6942                	ld	s2,16(sp)
 2ee:	69a2                	ld	s3,8(sp)
 2f0:	6145                	addi	sp,sp,48
 2f2:	8082                	ret
        sleep(3);
 2f4:	450d                	li	a0,3
 2f6:	00000097          	auipc	ra,0x0
 2fa:	608080e7          	jalr	1544(ra) # 8fe <sleep>
            printf("child blocking signal %d :-)\n",i);
 2fe:	00001997          	auipc	s3,0x1
 302:	c1a98993          	addi	s3,s3,-998 # f18 <malloc+0x23c>
        for(int i=0;i<100;i++){
 306:	06400913          	li	s2,100
            printf("child blocking signal %d :-)\n",i);
 30a:	85a6                	mv	a1,s1
 30c:	854e                	mv	a0,s3
 30e:	00001097          	auipc	ra,0x1
 312:	910080e7          	jalr	-1776(ra) # c1e <printf>
        for(int i=0;i<100;i++){
 316:	2485                	addiw	s1,s1,1
 318:	ff2499e3          	bne	s1,s2,30a <test_block+0x9e>
        exit(0);
 31c:	4501                	li	a0,0
 31e:	00000097          	auipc	ra,0x0
 322:	550080e7          	jalr	1360(ra) # 86e <exit>

0000000000000326 <test_stop_cont>:

void
test_stop_cont(){
 326:	7179                	addi	sp,sp,-48
 328:	f406                	sd	ra,40(sp)
 32a:	f022                	sd	s0,32(sp)
 32c:	ec26                	sd	s1,24(sp)
 32e:	e84a                	sd	s2,16(sp)
 330:	e44e                	sd	s3,8(sp)
 332:	1800                	addi	s0,sp,48
    int pid = fork();
 334:	00000097          	auipc	ra,0x0
 338:	532080e7          	jalr	1330(ra) # 866 <fork>
 33c:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
 33e:	e915                	bnez	a0,372 <test_stop_cont+0x4c>
        sleep(2);
 340:	4509                	li	a0,2
 342:	00000097          	auipc	ra,0x0
 346:	5bc080e7          	jalr	1468(ra) # 8fe <sleep>
        for(i=0;i<500;i++)
            printf("%d\n ", i);
 34a:	00001997          	auipc	s3,0x1
 34e:	c5e98993          	addi	s3,s3,-930 # fa8 <malloc+0x2cc>
        for(i=0;i<500;i++)
 352:	1f400913          	li	s2,500
            printf("%d\n ", i);
 356:	85a6                	mv	a1,s1
 358:	854e                	mv	a0,s3
 35a:	00001097          	auipc	ra,0x1
 35e:	8c4080e7          	jalr	-1852(ra) # c1e <printf>
        for(i=0;i<500;i++)
 362:	2485                	addiw	s1,s1,1
 364:	ff2499e3          	bne	s1,s2,356 <test_stop_cont+0x30>
        exit(0);
 368:	4501                	li	a0,0
 36a:	00000097          	auipc	ra,0x0
 36e:	504080e7          	jalr	1284(ra) # 86e <exit>
    }else{
        printf("son pid=%d, dad pid=%d\n",pid, getpid());
 372:	00000097          	auipc	ra,0x0
 376:	57c080e7          	jalr	1404(ra) # 8ee <getpid>
 37a:	862a                	mv	a2,a0
 37c:	85a6                	mv	a1,s1
 37e:	00001517          	auipc	a0,0x1
 382:	c3250513          	addi	a0,a0,-974 # fb0 <malloc+0x2d4>
 386:	00001097          	auipc	ra,0x1
 38a:	898080e7          	jalr	-1896(ra) # c1e <printf>
        sleep(5);
 38e:	4515                	li	a0,5
 390:	00000097          	auipc	ra,0x0
 394:	56e080e7          	jalr	1390(ra) # 8fe <sleep>
        printf("parent send stop ret= %d\n",kill(pid, SIGSTOP));
 398:	45c5                	li	a1,17
 39a:	8526                	mv	a0,s1
 39c:	00000097          	auipc	ra,0x0
 3a0:	502080e7          	jalr	1282(ra) # 89e <kill>
 3a4:	85aa                	mv	a1,a0
 3a6:	00001517          	auipc	a0,0x1
 3aa:	c2250513          	addi	a0,a0,-990 # fc8 <malloc+0x2ec>
 3ae:	00001097          	auipc	ra,0x1
 3b2:	870080e7          	jalr	-1936(ra) # c1e <printf>
        sleep(50);
 3b6:	03200513          	li	a0,50
 3ba:	00000097          	auipc	ra,0x0
 3be:	544080e7          	jalr	1348(ra) # 8fe <sleep>
        printf("parent send continue ret= %d\n",kill(pid, SIGCONT));
 3c2:	45cd                	li	a1,19
 3c4:	8526                	mv	a0,s1
 3c6:	00000097          	auipc	ra,0x0
 3ca:	4d8080e7          	jalr	1240(ra) # 89e <kill>
 3ce:	85aa                	mv	a1,a0
 3d0:	00001517          	auipc	a0,0x1
 3d4:	c1850513          	addi	a0,a0,-1000 # fe8 <malloc+0x30c>
 3d8:	00001097          	auipc	ra,0x1
 3dc:	846080e7          	jalr	-1978(ra) # c1e <printf>
        wait(0);
 3e0:	4501                	li	a0,0
 3e2:	00000097          	auipc	ra,0x0
 3e6:	494080e7          	jalr	1172(ra) # 876 <wait>
        // for(int i=0;i<100;i++)
        //  printf("parent..");
        sleep(10);
 3ea:	4529                	li	a0,10
 3ec:	00000097          	auipc	ra,0x0
 3f0:	512080e7          	jalr	1298(ra) # 8fe <sleep>
        exit(0);
 3f4:	4501                	li	a0,0
 3f6:	00000097          	auipc	ra,0x0
 3fa:	478080e7          	jalr	1144(ra) # 86e <exit>

00000000000003fe <test_ignore>:
    }
}

void 
test_ignore(){
 3fe:	1101                	addi	sp,sp,-32
 400:	ec06                	sd	ra,24(sp)
 402:	e822                	sd	s0,16(sp)
 404:	e426                	sd	s1,8(sp)
 406:	e04a                	sd	s2,0(sp)
 408:	1000                	addi	s0,sp,32
    int pid= fork();
 40a:	00000097          	auipc	ra,0x0
 40e:	45c080e7          	jalr	1116(ra) # 866 <fork>
    int signum=22;
    if(pid==0){
 412:	c129                	beqz	a0,454 <test_ignore+0x56>
 414:	84aa                	mv	s1,a0
            printf("child ignoring signal :-)\n");
        }
        exit(0);

    }else{
        printf("son pid= %d",pid);
 416:	85aa                	mv	a1,a0
 418:	00001517          	auipc	a0,0x1
 41c:	c5850513          	addi	a0,a0,-936 # 1070 <malloc+0x394>
 420:	00000097          	auipc	ra,0x0
 424:	7fe080e7          	jalr	2046(ra) # c1e <printf>
        sleep(5);
 428:	4515                	li	a0,5
 42a:	00000097          	auipc	ra,0x0
 42e:	4d4080e7          	jalr	1236(ra) # 8fe <sleep>
        kill(pid,signum);
 432:	45d9                	li	a1,22
 434:	8526                	mv	a0,s1
 436:	00000097          	auipc	ra,0x0
 43a:	468080e7          	jalr	1128(ra) # 89e <kill>
        wait(0);
 43e:	4501                	li	a0,0
 440:	00000097          	auipc	ra,0x0
 444:	436080e7          	jalr	1078(ra) # 876 <wait>

    }
}
 448:	60e2                	ld	ra,24(sp)
 44a:	6442                	ld	s0,16(sp)
 44c:	64a2                	ld	s1,8(sp)
 44e:	6902                	ld	s2,0(sp)
 450:	6105                	addi	sp,sp,32
 452:	8082                	ret
        newAct=malloc(sizeof(sigaction));
 454:	4505                	li	a0,1
 456:	00001097          	auipc	ra,0x1
 45a:	886080e7          	jalr	-1914(ra) # cdc <malloc>
 45e:	892a                	mv	s2,a0
        oldAct=malloc(sizeof(sigaction));
 460:	4505                	li	a0,1
 462:	00001097          	auipc	ra,0x1
 466:	87a080e7          	jalr	-1926(ra) # cdc <malloc>
 46a:	84aa                	mv	s1,a0
        newAct->sigmask = 0;
 46c:	00092423          	sw	zero,8(s2)
        newAct->sa_handler=(void*)SIG_IGN;
 470:	4785                	li	a5,1
 472:	00f93023          	sd	a5,0(s2)
        int ans=sigaction(signum,newAct,oldAct);
 476:	862a                	mv	a2,a0
 478:	85ca                	mv	a1,s2
 47a:	4559                	li	a0,22
 47c:	00000097          	auipc	ra,0x0
 480:	49a080e7          	jalr	1178(ra) # 916 <sigaction>
 484:	85aa                	mv	a1,a0
        printf("ans from sigaction %d, old act returned is: mask= %d address= %d\n",ans,oldAct->sigmask,(uint64)oldAct->sa_handler);
 486:	6094                	ld	a3,0(s1)
 488:	4490                	lw	a2,8(s1)
 48a:	00001517          	auipc	a0,0x1
 48e:	b7e50513          	addi	a0,a0,-1154 # 1008 <malloc+0x32c>
 492:	00000097          	auipc	ra,0x0
 496:	78c080e7          	jalr	1932(ra) # c1e <printf>
        sleep(6);
 49a:	4519                	li	a0,6
 49c:	00000097          	auipc	ra,0x0
 4a0:	462080e7          	jalr	1122(ra) # 8fe <sleep>
 4a4:	12c00493          	li	s1,300
            printf("child ignoring signal :-)\n");
 4a8:	00001917          	auipc	s2,0x1
 4ac:	ba890913          	addi	s2,s2,-1112 # 1050 <malloc+0x374>
 4b0:	854a                	mv	a0,s2
 4b2:	00000097          	auipc	ra,0x0
 4b6:	76c080e7          	jalr	1900(ra) # c1e <printf>
        for(int i=0;i<300;i++){
 4ba:	34fd                	addiw	s1,s1,-1
 4bc:	f8f5                	bnez	s1,4b0 <test_ignore+0xb2>
        exit(0);
 4be:	4501                	li	a0,0
 4c0:	00000097          	auipc	ra,0x0
 4c4:	3ae080e7          	jalr	942(ra) # 86e <exit>

00000000000004c8 <test_stop_stop_kill>:
void
test_stop_stop_kill(){
 4c8:	715d                	addi	sp,sp,-80
 4ca:	e486                	sd	ra,72(sp)
 4cc:	e0a2                	sd	s0,64(sp)
 4ce:	fc26                	sd	s1,56(sp)
 4d0:	f84a                	sd	s2,48(sp)
 4d2:	f44e                	sd	s3,40(sp)
 4d4:	0880                	addi	s0,sp,80
    struct sigaction act;

    printf("sighandler= %p\n",&sig_handler_loop);
 4d6:	00000597          	auipc	a1,0x0
 4da:	b5a58593          	addi	a1,a1,-1190 # 30 <sig_handler_loop>
 4de:	00001517          	auipc	a0,0x1
 4e2:	96a50513          	addi	a0,a0,-1686 # e48 <malloc+0x16c>
 4e6:	00000097          	auipc	ra,0x0
 4ea:	738080e7          	jalr	1848(ra) # c1e <printf>
    uint mask = 0;
    mask ^= (1<<22);

    act.sigmask = mask;
 4ee:	004007b7          	lui	a5,0x400
 4f2:	fcf42423          	sw	a5,-56(s0)
    act.sa_handler=&sig_handler_loop;
 4f6:	00000797          	auipc	a5,0x0
 4fa:	b3a78793          	addi	a5,a5,-1222 # 30 <sig_handler_loop>
 4fe:	fcf43023          	sd	a5,-64(s0)

    struct sigaction oldact;
    oldact.sigmask=0;
 502:	fa042c23          	sw	zero,-72(s0)
    oldact.sa_handler=0;
 506:	fa043823          	sd	zero,-80(s0)
    


    int pid = fork();
 50a:	00000097          	auipc	ra,0x0
 50e:	35c080e7          	jalr	860(ra) # 866 <fork>
 512:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
 514:	ed15                	bnez	a0,550 <test_stop_stop_kill+0x88>
        int ret=sigaction(3,&act,&oldact);
 516:	fb040613          	addi	a2,s0,-80
 51a:	fc040593          	addi	a1,s0,-64
 51e:	450d                	li	a0,3
 520:	00000097          	auipc	ra,0x0
 524:	3f6080e7          	jalr	1014(ra) # 916 <sigaction>
        for(i=0;i<500;i++)
            printf("out-side handler %d\n ", i);
 528:	00001997          	auipc	s3,0x1
 52c:	b5898993          	addi	s3,s3,-1192 # 1080 <malloc+0x3a4>
        for(i=0;i<500;i++)
 530:	1f400913          	li	s2,500
            printf("out-side handler %d\n ", i);
 534:	85a6                	mv	a1,s1
 536:	854e                	mv	a0,s3
 538:	00000097          	auipc	ra,0x0
 53c:	6e6080e7          	jalr	1766(ra) # c1e <printf>
        for(i=0;i<500;i++)
 540:	2485                	addiw	s1,s1,1
 542:	ff2499e3          	bne	s1,s2,534 <test_stop_stop_kill+0x6c>
        exit(0);
 546:	4501                	li	a0,0
 548:	00000097          	auipc	ra,0x0
 54c:	326080e7          	jalr	806(ra) # 86e <exit>
    }else{
        printf("son pid=%d, dad pid=%d\n",pid, getpid());
 550:	00000097          	auipc	ra,0x0
 554:	39e080e7          	jalr	926(ra) # 8ee <getpid>
 558:	862a                	mv	a2,a0
 55a:	85a6                	mv	a1,s1
 55c:	00001517          	auipc	a0,0x1
 560:	a5450513          	addi	a0,a0,-1452 # fb0 <malloc+0x2d4>
 564:	00000097          	auipc	ra,0x0
 568:	6ba080e7          	jalr	1722(ra) # c1e <printf>
        sleep(5);
 56c:	4515                	li	a0,5
 56e:	00000097          	auipc	ra,0x0
 572:	390080e7          	jalr	912(ra) # 8fe <sleep>
        printf("parent send loop ret= %d\n",kill(pid, 3));
 576:	458d                	li	a1,3
 578:	8526                	mv	a0,s1
 57a:	00000097          	auipc	ra,0x0
 57e:	324080e7          	jalr	804(ra) # 89e <kill>
 582:	85aa                	mv	a1,a0
 584:	00001517          	auipc	a0,0x1
 588:	b1450513          	addi	a0,a0,-1260 # 1098 <malloc+0x3bc>
 58c:	00000097          	auipc	ra,0x0
 590:	692080e7          	jalr	1682(ra) # c1e <printf>
        sleep(1);
 594:	4505                	li	a0,1
 596:	00000097          	auipc	ra,0x0
 59a:	368080e7          	jalr	872(ra) # 8fe <sleep>
        printf("parent send kill ret= %d\n",kill(pid, SIGKILL));
 59e:	45a5                	li	a1,9
 5a0:	8526                	mv	a0,s1
 5a2:	00000097          	auipc	ra,0x0
 5a6:	2fc080e7          	jalr	764(ra) # 89e <kill>
 5aa:	85aa                	mv	a1,a0
 5ac:	00001517          	auipc	a0,0x1
 5b0:	b0c50513          	addi	a0,a0,-1268 # 10b8 <malloc+0x3dc>
 5b4:	00000097          	auipc	ra,0x0
 5b8:	66a080e7          	jalr	1642(ra) # c1e <printf>
        // kill(pid,SIGKILL);
        wait(0);
 5bc:	4501                	li	a0,0
 5be:	00000097          	auipc	ra,0x0
 5c2:	2b8080e7          	jalr	696(ra) # 876 <wait>
        printf("parent exiting\n");
 5c6:	00001517          	auipc	a0,0x1
 5ca:	b1250513          	addi	a0,a0,-1262 # 10d8 <malloc+0x3fc>
 5ce:	00000097          	auipc	ra,0x0
 5d2:	650080e7          	jalr	1616(ra) # c1e <printf>
        exit(0);
 5d6:	4501                	li	a0,0
 5d8:	00000097          	auipc	ra,0x0
 5dc:	296080e7          	jalr	662(ra) # 86e <exit>

00000000000005e0 <main>:
    }
}


int main(){
 5e0:	1141                	addi	sp,sp,-16
 5e2:	e406                	sd	ra,8(sp)
 5e4:	e022                	sd	s0,0(sp)
 5e6:	0800                	addi	s0,sp,16
    // test_usersig();
    // printf("-----------------------------test_block-----------------------------\n");
    // test_block();
    // printf("-----------------------------test_ignore-----------------------------\n");
    // test_ignore();
    printf("-----------------------------test_stop_stop_kill-----------------------------\n");
 5e8:	00001517          	auipc	a0,0x1
 5ec:	b0050513          	addi	a0,a0,-1280 # 10e8 <malloc+0x40c>
 5f0:	00000097          	auipc	ra,0x0
 5f4:	62e080e7          	jalr	1582(ra) # c1e <printf>
    test_stop_stop_kill();
 5f8:	00000097          	auipc	ra,0x0
 5fc:	ed0080e7          	jalr	-304(ra) # 4c8 <test_stop_stop_kill>

0000000000000600 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 600:	1141                	addi	sp,sp,-16
 602:	e422                	sd	s0,8(sp)
 604:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 606:	87aa                	mv	a5,a0
 608:	0585                	addi	a1,a1,1
 60a:	0785                	addi	a5,a5,1
 60c:	fff5c703          	lbu	a4,-1(a1)
 610:	fee78fa3          	sb	a4,-1(a5)
 614:	fb75                	bnez	a4,608 <strcpy+0x8>
    ;
  return os;
}
 616:	6422                	ld	s0,8(sp)
 618:	0141                	addi	sp,sp,16
 61a:	8082                	ret

000000000000061c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 61c:	1141                	addi	sp,sp,-16
 61e:	e422                	sd	s0,8(sp)
 620:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 622:	00054783          	lbu	a5,0(a0)
 626:	cb91                	beqz	a5,63a <strcmp+0x1e>
 628:	0005c703          	lbu	a4,0(a1)
 62c:	00f71763          	bne	a4,a5,63a <strcmp+0x1e>
    p++, q++;
 630:	0505                	addi	a0,a0,1
 632:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 634:	00054783          	lbu	a5,0(a0)
 638:	fbe5                	bnez	a5,628 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 63a:	0005c503          	lbu	a0,0(a1)
}
 63e:	40a7853b          	subw	a0,a5,a0
 642:	6422                	ld	s0,8(sp)
 644:	0141                	addi	sp,sp,16
 646:	8082                	ret

0000000000000648 <strlen>:

uint
strlen(const char *s)
{
 648:	1141                	addi	sp,sp,-16
 64a:	e422                	sd	s0,8(sp)
 64c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 64e:	00054783          	lbu	a5,0(a0)
 652:	cf91                	beqz	a5,66e <strlen+0x26>
 654:	0505                	addi	a0,a0,1
 656:	87aa                	mv	a5,a0
 658:	4685                	li	a3,1
 65a:	9e89                	subw	a3,a3,a0
 65c:	00f6853b          	addw	a0,a3,a5
 660:	0785                	addi	a5,a5,1
 662:	fff7c703          	lbu	a4,-1(a5)
 666:	fb7d                	bnez	a4,65c <strlen+0x14>
    ;
  return n;
}
 668:	6422                	ld	s0,8(sp)
 66a:	0141                	addi	sp,sp,16
 66c:	8082                	ret
  for(n = 0; s[n]; n++)
 66e:	4501                	li	a0,0
 670:	bfe5                	j	668 <strlen+0x20>

0000000000000672 <memset>:

void*
memset(void *dst, int c, uint n)
{
 672:	1141                	addi	sp,sp,-16
 674:	e422                	sd	s0,8(sp)
 676:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 678:	ca19                	beqz	a2,68e <memset+0x1c>
 67a:	87aa                	mv	a5,a0
 67c:	1602                	slli	a2,a2,0x20
 67e:	9201                	srli	a2,a2,0x20
 680:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 684:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 688:	0785                	addi	a5,a5,1
 68a:	fee79de3          	bne	a5,a4,684 <memset+0x12>
  }
  return dst;
}
 68e:	6422                	ld	s0,8(sp)
 690:	0141                	addi	sp,sp,16
 692:	8082                	ret

0000000000000694 <strchr>:

char*
strchr(const char *s, char c)
{
 694:	1141                	addi	sp,sp,-16
 696:	e422                	sd	s0,8(sp)
 698:	0800                	addi	s0,sp,16
  for(; *s; s++)
 69a:	00054783          	lbu	a5,0(a0)
 69e:	cb99                	beqz	a5,6b4 <strchr+0x20>
    if(*s == c)
 6a0:	00f58763          	beq	a1,a5,6ae <strchr+0x1a>
  for(; *s; s++)
 6a4:	0505                	addi	a0,a0,1
 6a6:	00054783          	lbu	a5,0(a0)
 6aa:	fbfd                	bnez	a5,6a0 <strchr+0xc>
      return (char*)s;
  return 0;
 6ac:	4501                	li	a0,0
}
 6ae:	6422                	ld	s0,8(sp)
 6b0:	0141                	addi	sp,sp,16
 6b2:	8082                	ret
  return 0;
 6b4:	4501                	li	a0,0
 6b6:	bfe5                	j	6ae <strchr+0x1a>

00000000000006b8 <gets>:

char*
gets(char *buf, int max)
{
 6b8:	711d                	addi	sp,sp,-96
 6ba:	ec86                	sd	ra,88(sp)
 6bc:	e8a2                	sd	s0,80(sp)
 6be:	e4a6                	sd	s1,72(sp)
 6c0:	e0ca                	sd	s2,64(sp)
 6c2:	fc4e                	sd	s3,56(sp)
 6c4:	f852                	sd	s4,48(sp)
 6c6:	f456                	sd	s5,40(sp)
 6c8:	f05a                	sd	s6,32(sp)
 6ca:	ec5e                	sd	s7,24(sp)
 6cc:	1080                	addi	s0,sp,96
 6ce:	8baa                	mv	s7,a0
 6d0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 6d2:	892a                	mv	s2,a0
 6d4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 6d6:	4aa9                	li	s5,10
 6d8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 6da:	89a6                	mv	s3,s1
 6dc:	2485                	addiw	s1,s1,1
 6de:	0344d863          	bge	s1,s4,70e <gets+0x56>
    cc = read(0, &c, 1);
 6e2:	4605                	li	a2,1
 6e4:	faf40593          	addi	a1,s0,-81
 6e8:	4501                	li	a0,0
 6ea:	00000097          	auipc	ra,0x0
 6ee:	19c080e7          	jalr	412(ra) # 886 <read>
    if(cc < 1)
 6f2:	00a05e63          	blez	a0,70e <gets+0x56>
    buf[i++] = c;
 6f6:	faf44783          	lbu	a5,-81(s0)
 6fa:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 6fe:	01578763          	beq	a5,s5,70c <gets+0x54>
 702:	0905                	addi	s2,s2,1
 704:	fd679be3          	bne	a5,s6,6da <gets+0x22>
  for(i=0; i+1 < max; ){
 708:	89a6                	mv	s3,s1
 70a:	a011                	j	70e <gets+0x56>
 70c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 70e:	99de                	add	s3,s3,s7
 710:	00098023          	sb	zero,0(s3)
  return buf;
}
 714:	855e                	mv	a0,s7
 716:	60e6                	ld	ra,88(sp)
 718:	6446                	ld	s0,80(sp)
 71a:	64a6                	ld	s1,72(sp)
 71c:	6906                	ld	s2,64(sp)
 71e:	79e2                	ld	s3,56(sp)
 720:	7a42                	ld	s4,48(sp)
 722:	7aa2                	ld	s5,40(sp)
 724:	7b02                	ld	s6,32(sp)
 726:	6be2                	ld	s7,24(sp)
 728:	6125                	addi	sp,sp,96
 72a:	8082                	ret

000000000000072c <stat>:

int
stat(const char *n, struct stat *st)
{
 72c:	1101                	addi	sp,sp,-32
 72e:	ec06                	sd	ra,24(sp)
 730:	e822                	sd	s0,16(sp)
 732:	e426                	sd	s1,8(sp)
 734:	e04a                	sd	s2,0(sp)
 736:	1000                	addi	s0,sp,32
 738:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 73a:	4581                	li	a1,0
 73c:	00000097          	auipc	ra,0x0
 740:	172080e7          	jalr	370(ra) # 8ae <open>
  if(fd < 0)
 744:	02054563          	bltz	a0,76e <stat+0x42>
 748:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 74a:	85ca                	mv	a1,s2
 74c:	00000097          	auipc	ra,0x0
 750:	17a080e7          	jalr	378(ra) # 8c6 <fstat>
 754:	892a                	mv	s2,a0
  close(fd);
 756:	8526                	mv	a0,s1
 758:	00000097          	auipc	ra,0x0
 75c:	13e080e7          	jalr	318(ra) # 896 <close>
  return r;
}
 760:	854a                	mv	a0,s2
 762:	60e2                	ld	ra,24(sp)
 764:	6442                	ld	s0,16(sp)
 766:	64a2                	ld	s1,8(sp)
 768:	6902                	ld	s2,0(sp)
 76a:	6105                	addi	sp,sp,32
 76c:	8082                	ret
    return -1;
 76e:	597d                	li	s2,-1
 770:	bfc5                	j	760 <stat+0x34>

0000000000000772 <atoi>:

int
atoi(const char *s)
{
 772:	1141                	addi	sp,sp,-16
 774:	e422                	sd	s0,8(sp)
 776:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 778:	00054603          	lbu	a2,0(a0)
 77c:	fd06079b          	addiw	a5,a2,-48
 780:	0ff7f793          	andi	a5,a5,255
 784:	4725                	li	a4,9
 786:	02f76963          	bltu	a4,a5,7b8 <atoi+0x46>
 78a:	86aa                	mv	a3,a0
  n = 0;
 78c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 78e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 790:	0685                	addi	a3,a3,1
 792:	0025179b          	slliw	a5,a0,0x2
 796:	9fa9                	addw	a5,a5,a0
 798:	0017979b          	slliw	a5,a5,0x1
 79c:	9fb1                	addw	a5,a5,a2
 79e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 7a2:	0006c603          	lbu	a2,0(a3)
 7a6:	fd06071b          	addiw	a4,a2,-48
 7aa:	0ff77713          	andi	a4,a4,255
 7ae:	fee5f1e3          	bgeu	a1,a4,790 <atoi+0x1e>
  return n;
}
 7b2:	6422                	ld	s0,8(sp)
 7b4:	0141                	addi	sp,sp,16
 7b6:	8082                	ret
  n = 0;
 7b8:	4501                	li	a0,0
 7ba:	bfe5                	j	7b2 <atoi+0x40>

00000000000007bc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 7bc:	1141                	addi	sp,sp,-16
 7be:	e422                	sd	s0,8(sp)
 7c0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 7c2:	02b57463          	bgeu	a0,a1,7ea <memmove+0x2e>
    while(n-- > 0)
 7c6:	00c05f63          	blez	a2,7e4 <memmove+0x28>
 7ca:	1602                	slli	a2,a2,0x20
 7cc:	9201                	srli	a2,a2,0x20
 7ce:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 7d2:	872a                	mv	a4,a0
      *dst++ = *src++;
 7d4:	0585                	addi	a1,a1,1
 7d6:	0705                	addi	a4,a4,1
 7d8:	fff5c683          	lbu	a3,-1(a1)
 7dc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 7e0:	fee79ae3          	bne	a5,a4,7d4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 7e4:	6422                	ld	s0,8(sp)
 7e6:	0141                	addi	sp,sp,16
 7e8:	8082                	ret
    dst += n;
 7ea:	00c50733          	add	a4,a0,a2
    src += n;
 7ee:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 7f0:	fec05ae3          	blez	a2,7e4 <memmove+0x28>
 7f4:	fff6079b          	addiw	a5,a2,-1
 7f8:	1782                	slli	a5,a5,0x20
 7fa:	9381                	srli	a5,a5,0x20
 7fc:	fff7c793          	not	a5,a5
 800:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 802:	15fd                	addi	a1,a1,-1
 804:	177d                	addi	a4,a4,-1
 806:	0005c683          	lbu	a3,0(a1)
 80a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 80e:	fee79ae3          	bne	a5,a4,802 <memmove+0x46>
 812:	bfc9                	j	7e4 <memmove+0x28>

0000000000000814 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 814:	1141                	addi	sp,sp,-16
 816:	e422                	sd	s0,8(sp)
 818:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 81a:	ca05                	beqz	a2,84a <memcmp+0x36>
 81c:	fff6069b          	addiw	a3,a2,-1
 820:	1682                	slli	a3,a3,0x20
 822:	9281                	srli	a3,a3,0x20
 824:	0685                	addi	a3,a3,1
 826:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 828:	00054783          	lbu	a5,0(a0)
 82c:	0005c703          	lbu	a4,0(a1)
 830:	00e79863          	bne	a5,a4,840 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 834:	0505                	addi	a0,a0,1
    p2++;
 836:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 838:	fed518e3          	bne	a0,a3,828 <memcmp+0x14>
  }
  return 0;
 83c:	4501                	li	a0,0
 83e:	a019                	j	844 <memcmp+0x30>
      return *p1 - *p2;
 840:	40e7853b          	subw	a0,a5,a4
}
 844:	6422                	ld	s0,8(sp)
 846:	0141                	addi	sp,sp,16
 848:	8082                	ret
  return 0;
 84a:	4501                	li	a0,0
 84c:	bfe5                	j	844 <memcmp+0x30>

000000000000084e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 84e:	1141                	addi	sp,sp,-16
 850:	e406                	sd	ra,8(sp)
 852:	e022                	sd	s0,0(sp)
 854:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 856:	00000097          	auipc	ra,0x0
 85a:	f66080e7          	jalr	-154(ra) # 7bc <memmove>
}
 85e:	60a2                	ld	ra,8(sp)
 860:	6402                	ld	s0,0(sp)
 862:	0141                	addi	sp,sp,16
 864:	8082                	ret

0000000000000866 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 866:	4885                	li	a7,1
 ecall
 868:	00000073          	ecall
 ret
 86c:	8082                	ret

000000000000086e <exit>:
.global exit
exit:
 li a7, SYS_exit
 86e:	4889                	li	a7,2
 ecall
 870:	00000073          	ecall
 ret
 874:	8082                	ret

0000000000000876 <wait>:
.global wait
wait:
 li a7, SYS_wait
 876:	488d                	li	a7,3
 ecall
 878:	00000073          	ecall
 ret
 87c:	8082                	ret

000000000000087e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 87e:	4891                	li	a7,4
 ecall
 880:	00000073          	ecall
 ret
 884:	8082                	ret

0000000000000886 <read>:
.global read
read:
 li a7, SYS_read
 886:	4895                	li	a7,5
 ecall
 888:	00000073          	ecall
 ret
 88c:	8082                	ret

000000000000088e <write>:
.global write
write:
 li a7, SYS_write
 88e:	48c1                	li	a7,16
 ecall
 890:	00000073          	ecall
 ret
 894:	8082                	ret

0000000000000896 <close>:
.global close
close:
 li a7, SYS_close
 896:	48d5                	li	a7,21
 ecall
 898:	00000073          	ecall
 ret
 89c:	8082                	ret

000000000000089e <kill>:
.global kill
kill:
 li a7, SYS_kill
 89e:	4899                	li	a7,6
 ecall
 8a0:	00000073          	ecall
 ret
 8a4:	8082                	ret

00000000000008a6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 8a6:	489d                	li	a7,7
 ecall
 8a8:	00000073          	ecall
 ret
 8ac:	8082                	ret

00000000000008ae <open>:
.global open
open:
 li a7, SYS_open
 8ae:	48bd                	li	a7,15
 ecall
 8b0:	00000073          	ecall
 ret
 8b4:	8082                	ret

00000000000008b6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 8b6:	48c5                	li	a7,17
 ecall
 8b8:	00000073          	ecall
 ret
 8bc:	8082                	ret

00000000000008be <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 8be:	48c9                	li	a7,18
 ecall
 8c0:	00000073          	ecall
 ret
 8c4:	8082                	ret

00000000000008c6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 8c6:	48a1                	li	a7,8
 ecall
 8c8:	00000073          	ecall
 ret
 8cc:	8082                	ret

00000000000008ce <link>:
.global link
link:
 li a7, SYS_link
 8ce:	48cd                	li	a7,19
 ecall
 8d0:	00000073          	ecall
 ret
 8d4:	8082                	ret

00000000000008d6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 8d6:	48d1                	li	a7,20
 ecall
 8d8:	00000073          	ecall
 ret
 8dc:	8082                	ret

00000000000008de <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 8de:	48a5                	li	a7,9
 ecall
 8e0:	00000073          	ecall
 ret
 8e4:	8082                	ret

00000000000008e6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 8e6:	48a9                	li	a7,10
 ecall
 8e8:	00000073          	ecall
 ret
 8ec:	8082                	ret

00000000000008ee <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 8ee:	48ad                	li	a7,11
 ecall
 8f0:	00000073          	ecall
 ret
 8f4:	8082                	ret

00000000000008f6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 8f6:	48b1                	li	a7,12
 ecall
 8f8:	00000073          	ecall
 ret
 8fc:	8082                	ret

00000000000008fe <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 8fe:	48b5                	li	a7,13
 ecall
 900:	00000073          	ecall
 ret
 904:	8082                	ret

0000000000000906 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 906:	48b9                	li	a7,14
 ecall
 908:	00000073          	ecall
 ret
 90c:	8082                	ret

000000000000090e <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
 90e:	48d9                	li	a7,22
 ecall
 910:	00000073          	ecall
 ret
 914:	8082                	ret

0000000000000916 <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
 916:	48dd                	li	a7,23
 ecall
 918:	00000073          	ecall
 ret
 91c:	8082                	ret

000000000000091e <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
 91e:	48e1                	li	a7,24
 ecall
 920:	00000073          	ecall
 ret
 924:	8082                	ret

0000000000000926 <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
 926:	48e5                	li	a7,25
 ecall
 928:	00000073          	ecall
 ret
 92c:	8082                	ret

000000000000092e <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
 92e:	48e9                	li	a7,26
 ecall
 930:	00000073          	ecall
 ret
 934:	8082                	ret

0000000000000936 <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
 936:	48ed                	li	a7,27
 ecall
 938:	00000073          	ecall
 ret
 93c:	8082                	ret

000000000000093e <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
 93e:	48f1                	li	a7,28
 ecall
 940:	00000073          	ecall
 ret
 944:	8082                	ret

0000000000000946 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 946:	1101                	addi	sp,sp,-32
 948:	ec06                	sd	ra,24(sp)
 94a:	e822                	sd	s0,16(sp)
 94c:	1000                	addi	s0,sp,32
 94e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 952:	4605                	li	a2,1
 954:	fef40593          	addi	a1,s0,-17
 958:	00000097          	auipc	ra,0x0
 95c:	f36080e7          	jalr	-202(ra) # 88e <write>
}
 960:	60e2                	ld	ra,24(sp)
 962:	6442                	ld	s0,16(sp)
 964:	6105                	addi	sp,sp,32
 966:	8082                	ret

0000000000000968 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 968:	7139                	addi	sp,sp,-64
 96a:	fc06                	sd	ra,56(sp)
 96c:	f822                	sd	s0,48(sp)
 96e:	f426                	sd	s1,40(sp)
 970:	f04a                	sd	s2,32(sp)
 972:	ec4e                	sd	s3,24(sp)
 974:	0080                	addi	s0,sp,64
 976:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 978:	c299                	beqz	a3,97e <printint+0x16>
 97a:	0805c863          	bltz	a1,a0a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 97e:	2581                	sext.w	a1,a1
  neg = 0;
 980:	4881                	li	a7,0
 982:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 986:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 988:	2601                	sext.w	a2,a2
 98a:	00000517          	auipc	a0,0x0
 98e:	7b650513          	addi	a0,a0,1974 # 1140 <digits>
 992:	883a                	mv	a6,a4
 994:	2705                	addiw	a4,a4,1
 996:	02c5f7bb          	remuw	a5,a1,a2
 99a:	1782                	slli	a5,a5,0x20
 99c:	9381                	srli	a5,a5,0x20
 99e:	97aa                	add	a5,a5,a0
 9a0:	0007c783          	lbu	a5,0(a5)
 9a4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 9a8:	0005879b          	sext.w	a5,a1
 9ac:	02c5d5bb          	divuw	a1,a1,a2
 9b0:	0685                	addi	a3,a3,1
 9b2:	fec7f0e3          	bgeu	a5,a2,992 <printint+0x2a>
  if(neg)
 9b6:	00088b63          	beqz	a7,9cc <printint+0x64>
    buf[i++] = '-';
 9ba:	fd040793          	addi	a5,s0,-48
 9be:	973e                	add	a4,a4,a5
 9c0:	02d00793          	li	a5,45
 9c4:	fef70823          	sb	a5,-16(a4)
 9c8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 9cc:	02e05863          	blez	a4,9fc <printint+0x94>
 9d0:	fc040793          	addi	a5,s0,-64
 9d4:	00e78933          	add	s2,a5,a4
 9d8:	fff78993          	addi	s3,a5,-1
 9dc:	99ba                	add	s3,s3,a4
 9de:	377d                	addiw	a4,a4,-1
 9e0:	1702                	slli	a4,a4,0x20
 9e2:	9301                	srli	a4,a4,0x20
 9e4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 9e8:	fff94583          	lbu	a1,-1(s2)
 9ec:	8526                	mv	a0,s1
 9ee:	00000097          	auipc	ra,0x0
 9f2:	f58080e7          	jalr	-168(ra) # 946 <putc>
  while(--i >= 0)
 9f6:	197d                	addi	s2,s2,-1
 9f8:	ff3918e3          	bne	s2,s3,9e8 <printint+0x80>
}
 9fc:	70e2                	ld	ra,56(sp)
 9fe:	7442                	ld	s0,48(sp)
 a00:	74a2                	ld	s1,40(sp)
 a02:	7902                	ld	s2,32(sp)
 a04:	69e2                	ld	s3,24(sp)
 a06:	6121                	addi	sp,sp,64
 a08:	8082                	ret
    x = -xx;
 a0a:	40b005bb          	negw	a1,a1
    neg = 1;
 a0e:	4885                	li	a7,1
    x = -xx;
 a10:	bf8d                	j	982 <printint+0x1a>

0000000000000a12 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 a12:	7119                	addi	sp,sp,-128
 a14:	fc86                	sd	ra,120(sp)
 a16:	f8a2                	sd	s0,112(sp)
 a18:	f4a6                	sd	s1,104(sp)
 a1a:	f0ca                	sd	s2,96(sp)
 a1c:	ecce                	sd	s3,88(sp)
 a1e:	e8d2                	sd	s4,80(sp)
 a20:	e4d6                	sd	s5,72(sp)
 a22:	e0da                	sd	s6,64(sp)
 a24:	fc5e                	sd	s7,56(sp)
 a26:	f862                	sd	s8,48(sp)
 a28:	f466                	sd	s9,40(sp)
 a2a:	f06a                	sd	s10,32(sp)
 a2c:	ec6e                	sd	s11,24(sp)
 a2e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 a30:	0005c903          	lbu	s2,0(a1)
 a34:	18090f63          	beqz	s2,bd2 <vprintf+0x1c0>
 a38:	8aaa                	mv	s5,a0
 a3a:	8b32                	mv	s6,a2
 a3c:	00158493          	addi	s1,a1,1
  state = 0;
 a40:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 a42:	02500a13          	li	s4,37
      if(c == 'd'){
 a46:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 a4a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 a4e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 a52:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a56:	00000b97          	auipc	s7,0x0
 a5a:	6eab8b93          	addi	s7,s7,1770 # 1140 <digits>
 a5e:	a839                	j	a7c <vprintf+0x6a>
        putc(fd, c);
 a60:	85ca                	mv	a1,s2
 a62:	8556                	mv	a0,s5
 a64:	00000097          	auipc	ra,0x0
 a68:	ee2080e7          	jalr	-286(ra) # 946 <putc>
 a6c:	a019                	j	a72 <vprintf+0x60>
    } else if(state == '%'){
 a6e:	01498f63          	beq	s3,s4,a8c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 a72:	0485                	addi	s1,s1,1
 a74:	fff4c903          	lbu	s2,-1(s1)
 a78:	14090d63          	beqz	s2,bd2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 a7c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 a80:	fe0997e3          	bnez	s3,a6e <vprintf+0x5c>
      if(c == '%'){
 a84:	fd479ee3          	bne	a5,s4,a60 <vprintf+0x4e>
        state = '%';
 a88:	89be                	mv	s3,a5
 a8a:	b7e5                	j	a72 <vprintf+0x60>
      if(c == 'd'){
 a8c:	05878063          	beq	a5,s8,acc <vprintf+0xba>
      } else if(c == 'l') {
 a90:	05978c63          	beq	a5,s9,ae8 <vprintf+0xd6>
      } else if(c == 'x') {
 a94:	07a78863          	beq	a5,s10,b04 <vprintf+0xf2>
      } else if(c == 'p') {
 a98:	09b78463          	beq	a5,s11,b20 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 a9c:	07300713          	li	a4,115
 aa0:	0ce78663          	beq	a5,a4,b6c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 aa4:	06300713          	li	a4,99
 aa8:	0ee78e63          	beq	a5,a4,ba4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 aac:	11478863          	beq	a5,s4,bbc <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 ab0:	85d2                	mv	a1,s4
 ab2:	8556                	mv	a0,s5
 ab4:	00000097          	auipc	ra,0x0
 ab8:	e92080e7          	jalr	-366(ra) # 946 <putc>
        putc(fd, c);
 abc:	85ca                	mv	a1,s2
 abe:	8556                	mv	a0,s5
 ac0:	00000097          	auipc	ra,0x0
 ac4:	e86080e7          	jalr	-378(ra) # 946 <putc>
      }
      state = 0;
 ac8:	4981                	li	s3,0
 aca:	b765                	j	a72 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 acc:	008b0913          	addi	s2,s6,8
 ad0:	4685                	li	a3,1
 ad2:	4629                	li	a2,10
 ad4:	000b2583          	lw	a1,0(s6)
 ad8:	8556                	mv	a0,s5
 ada:	00000097          	auipc	ra,0x0
 ade:	e8e080e7          	jalr	-370(ra) # 968 <printint>
 ae2:	8b4a                	mv	s6,s2
      state = 0;
 ae4:	4981                	li	s3,0
 ae6:	b771                	j	a72 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 ae8:	008b0913          	addi	s2,s6,8
 aec:	4681                	li	a3,0
 aee:	4629                	li	a2,10
 af0:	000b2583          	lw	a1,0(s6)
 af4:	8556                	mv	a0,s5
 af6:	00000097          	auipc	ra,0x0
 afa:	e72080e7          	jalr	-398(ra) # 968 <printint>
 afe:	8b4a                	mv	s6,s2
      state = 0;
 b00:	4981                	li	s3,0
 b02:	bf85                	j	a72 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 b04:	008b0913          	addi	s2,s6,8
 b08:	4681                	li	a3,0
 b0a:	4641                	li	a2,16
 b0c:	000b2583          	lw	a1,0(s6)
 b10:	8556                	mv	a0,s5
 b12:	00000097          	auipc	ra,0x0
 b16:	e56080e7          	jalr	-426(ra) # 968 <printint>
 b1a:	8b4a                	mv	s6,s2
      state = 0;
 b1c:	4981                	li	s3,0
 b1e:	bf91                	j	a72 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 b20:	008b0793          	addi	a5,s6,8
 b24:	f8f43423          	sd	a5,-120(s0)
 b28:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 b2c:	03000593          	li	a1,48
 b30:	8556                	mv	a0,s5
 b32:	00000097          	auipc	ra,0x0
 b36:	e14080e7          	jalr	-492(ra) # 946 <putc>
  putc(fd, 'x');
 b3a:	85ea                	mv	a1,s10
 b3c:	8556                	mv	a0,s5
 b3e:	00000097          	auipc	ra,0x0
 b42:	e08080e7          	jalr	-504(ra) # 946 <putc>
 b46:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 b48:	03c9d793          	srli	a5,s3,0x3c
 b4c:	97de                	add	a5,a5,s7
 b4e:	0007c583          	lbu	a1,0(a5)
 b52:	8556                	mv	a0,s5
 b54:	00000097          	auipc	ra,0x0
 b58:	df2080e7          	jalr	-526(ra) # 946 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 b5c:	0992                	slli	s3,s3,0x4
 b5e:	397d                	addiw	s2,s2,-1
 b60:	fe0914e3          	bnez	s2,b48 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 b64:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 b68:	4981                	li	s3,0
 b6a:	b721                	j	a72 <vprintf+0x60>
        s = va_arg(ap, char*);
 b6c:	008b0993          	addi	s3,s6,8
 b70:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 b74:	02090163          	beqz	s2,b96 <vprintf+0x184>
        while(*s != 0){
 b78:	00094583          	lbu	a1,0(s2)
 b7c:	c9a1                	beqz	a1,bcc <vprintf+0x1ba>
          putc(fd, *s);
 b7e:	8556                	mv	a0,s5
 b80:	00000097          	auipc	ra,0x0
 b84:	dc6080e7          	jalr	-570(ra) # 946 <putc>
          s++;
 b88:	0905                	addi	s2,s2,1
        while(*s != 0){
 b8a:	00094583          	lbu	a1,0(s2)
 b8e:	f9e5                	bnez	a1,b7e <vprintf+0x16c>
        s = va_arg(ap, char*);
 b90:	8b4e                	mv	s6,s3
      state = 0;
 b92:	4981                	li	s3,0
 b94:	bdf9                	j	a72 <vprintf+0x60>
          s = "(null)";
 b96:	00000917          	auipc	s2,0x0
 b9a:	5a290913          	addi	s2,s2,1442 # 1138 <malloc+0x45c>
        while(*s != 0){
 b9e:	02800593          	li	a1,40
 ba2:	bff1                	j	b7e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 ba4:	008b0913          	addi	s2,s6,8
 ba8:	000b4583          	lbu	a1,0(s6)
 bac:	8556                	mv	a0,s5
 bae:	00000097          	auipc	ra,0x0
 bb2:	d98080e7          	jalr	-616(ra) # 946 <putc>
 bb6:	8b4a                	mv	s6,s2
      state = 0;
 bb8:	4981                	li	s3,0
 bba:	bd65                	j	a72 <vprintf+0x60>
        putc(fd, c);
 bbc:	85d2                	mv	a1,s4
 bbe:	8556                	mv	a0,s5
 bc0:	00000097          	auipc	ra,0x0
 bc4:	d86080e7          	jalr	-634(ra) # 946 <putc>
      state = 0;
 bc8:	4981                	li	s3,0
 bca:	b565                	j	a72 <vprintf+0x60>
        s = va_arg(ap, char*);
 bcc:	8b4e                	mv	s6,s3
      state = 0;
 bce:	4981                	li	s3,0
 bd0:	b54d                	j	a72 <vprintf+0x60>
    }
  }
}
 bd2:	70e6                	ld	ra,120(sp)
 bd4:	7446                	ld	s0,112(sp)
 bd6:	74a6                	ld	s1,104(sp)
 bd8:	7906                	ld	s2,96(sp)
 bda:	69e6                	ld	s3,88(sp)
 bdc:	6a46                	ld	s4,80(sp)
 bde:	6aa6                	ld	s5,72(sp)
 be0:	6b06                	ld	s6,64(sp)
 be2:	7be2                	ld	s7,56(sp)
 be4:	7c42                	ld	s8,48(sp)
 be6:	7ca2                	ld	s9,40(sp)
 be8:	7d02                	ld	s10,32(sp)
 bea:	6de2                	ld	s11,24(sp)
 bec:	6109                	addi	sp,sp,128
 bee:	8082                	ret

0000000000000bf0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 bf0:	715d                	addi	sp,sp,-80
 bf2:	ec06                	sd	ra,24(sp)
 bf4:	e822                	sd	s0,16(sp)
 bf6:	1000                	addi	s0,sp,32
 bf8:	e010                	sd	a2,0(s0)
 bfa:	e414                	sd	a3,8(s0)
 bfc:	e818                	sd	a4,16(s0)
 bfe:	ec1c                	sd	a5,24(s0)
 c00:	03043023          	sd	a6,32(s0)
 c04:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 c08:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 c0c:	8622                	mv	a2,s0
 c0e:	00000097          	auipc	ra,0x0
 c12:	e04080e7          	jalr	-508(ra) # a12 <vprintf>
}
 c16:	60e2                	ld	ra,24(sp)
 c18:	6442                	ld	s0,16(sp)
 c1a:	6161                	addi	sp,sp,80
 c1c:	8082                	ret

0000000000000c1e <printf>:

void
printf(const char *fmt, ...)
{
 c1e:	711d                	addi	sp,sp,-96
 c20:	ec06                	sd	ra,24(sp)
 c22:	e822                	sd	s0,16(sp)
 c24:	1000                	addi	s0,sp,32
 c26:	e40c                	sd	a1,8(s0)
 c28:	e810                	sd	a2,16(s0)
 c2a:	ec14                	sd	a3,24(s0)
 c2c:	f018                	sd	a4,32(s0)
 c2e:	f41c                	sd	a5,40(s0)
 c30:	03043823          	sd	a6,48(s0)
 c34:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 c38:	00840613          	addi	a2,s0,8
 c3c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 c40:	85aa                	mv	a1,a0
 c42:	4505                	li	a0,1
 c44:	00000097          	auipc	ra,0x0
 c48:	dce080e7          	jalr	-562(ra) # a12 <vprintf>
}
 c4c:	60e2                	ld	ra,24(sp)
 c4e:	6442                	ld	s0,16(sp)
 c50:	6125                	addi	sp,sp,96
 c52:	8082                	ret

0000000000000c54 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 c54:	1141                	addi	sp,sp,-16
 c56:	e422                	sd	s0,8(sp)
 c58:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 c5a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c5e:	00000797          	auipc	a5,0x0
 c62:	4fa7b783          	ld	a5,1274(a5) # 1158 <freep>
 c66:	a805                	j	c96 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 c68:	4618                	lw	a4,8(a2)
 c6a:	9db9                	addw	a1,a1,a4
 c6c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 c70:	6398                	ld	a4,0(a5)
 c72:	6318                	ld	a4,0(a4)
 c74:	fee53823          	sd	a4,-16(a0)
 c78:	a091                	j	cbc <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 c7a:	ff852703          	lw	a4,-8(a0)
 c7e:	9e39                	addw	a2,a2,a4
 c80:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 c82:	ff053703          	ld	a4,-16(a0)
 c86:	e398                	sd	a4,0(a5)
 c88:	a099                	j	cce <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 c8a:	6398                	ld	a4,0(a5)
 c8c:	00e7e463          	bltu	a5,a4,c94 <free+0x40>
 c90:	00e6ea63          	bltu	a3,a4,ca4 <free+0x50>
{
 c94:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c96:	fed7fae3          	bgeu	a5,a3,c8a <free+0x36>
 c9a:	6398                	ld	a4,0(a5)
 c9c:	00e6e463          	bltu	a3,a4,ca4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ca0:	fee7eae3          	bltu	a5,a4,c94 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 ca4:	ff852583          	lw	a1,-8(a0)
 ca8:	6390                	ld	a2,0(a5)
 caa:	02059813          	slli	a6,a1,0x20
 cae:	01c85713          	srli	a4,a6,0x1c
 cb2:	9736                	add	a4,a4,a3
 cb4:	fae60ae3          	beq	a2,a4,c68 <free+0x14>
    bp->s.ptr = p->s.ptr;
 cb8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 cbc:	4790                	lw	a2,8(a5)
 cbe:	02061593          	slli	a1,a2,0x20
 cc2:	01c5d713          	srli	a4,a1,0x1c
 cc6:	973e                	add	a4,a4,a5
 cc8:	fae689e3          	beq	a3,a4,c7a <free+0x26>
  } else
    p->s.ptr = bp;
 ccc:	e394                	sd	a3,0(a5)
  freep = p;
 cce:	00000717          	auipc	a4,0x0
 cd2:	48f73523          	sd	a5,1162(a4) # 1158 <freep>
}
 cd6:	6422                	ld	s0,8(sp)
 cd8:	0141                	addi	sp,sp,16
 cda:	8082                	ret

0000000000000cdc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 cdc:	7139                	addi	sp,sp,-64
 cde:	fc06                	sd	ra,56(sp)
 ce0:	f822                	sd	s0,48(sp)
 ce2:	f426                	sd	s1,40(sp)
 ce4:	f04a                	sd	s2,32(sp)
 ce6:	ec4e                	sd	s3,24(sp)
 ce8:	e852                	sd	s4,16(sp)
 cea:	e456                	sd	s5,8(sp)
 cec:	e05a                	sd	s6,0(sp)
 cee:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 cf0:	02051493          	slli	s1,a0,0x20
 cf4:	9081                	srli	s1,s1,0x20
 cf6:	04bd                	addi	s1,s1,15
 cf8:	8091                	srli	s1,s1,0x4
 cfa:	0014899b          	addiw	s3,s1,1
 cfe:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 d00:	00000517          	auipc	a0,0x0
 d04:	45853503          	ld	a0,1112(a0) # 1158 <freep>
 d08:	c515                	beqz	a0,d34 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d0a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 d0c:	4798                	lw	a4,8(a5)
 d0e:	02977f63          	bgeu	a4,s1,d4c <malloc+0x70>
 d12:	8a4e                	mv	s4,s3
 d14:	0009871b          	sext.w	a4,s3
 d18:	6685                	lui	a3,0x1
 d1a:	00d77363          	bgeu	a4,a3,d20 <malloc+0x44>
 d1e:	6a05                	lui	s4,0x1
 d20:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 d24:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 d28:	00000917          	auipc	s2,0x0
 d2c:	43090913          	addi	s2,s2,1072 # 1158 <freep>
  if(p == (char*)-1)
 d30:	5afd                	li	s5,-1
 d32:	a895                	j	da6 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 d34:	00000797          	auipc	a5,0x0
 d38:	42c78793          	addi	a5,a5,1068 # 1160 <base>
 d3c:	00000717          	auipc	a4,0x0
 d40:	40f73e23          	sd	a5,1052(a4) # 1158 <freep>
 d44:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 d46:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 d4a:	b7e1                	j	d12 <malloc+0x36>
      if(p->s.size == nunits)
 d4c:	02e48c63          	beq	s1,a4,d84 <malloc+0xa8>
        p->s.size -= nunits;
 d50:	4137073b          	subw	a4,a4,s3
 d54:	c798                	sw	a4,8(a5)
        p += p->s.size;
 d56:	02071693          	slli	a3,a4,0x20
 d5a:	01c6d713          	srli	a4,a3,0x1c
 d5e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 d60:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 d64:	00000717          	auipc	a4,0x0
 d68:	3ea73a23          	sd	a0,1012(a4) # 1158 <freep>
      return (void*)(p + 1);
 d6c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 d70:	70e2                	ld	ra,56(sp)
 d72:	7442                	ld	s0,48(sp)
 d74:	74a2                	ld	s1,40(sp)
 d76:	7902                	ld	s2,32(sp)
 d78:	69e2                	ld	s3,24(sp)
 d7a:	6a42                	ld	s4,16(sp)
 d7c:	6aa2                	ld	s5,8(sp)
 d7e:	6b02                	ld	s6,0(sp)
 d80:	6121                	addi	sp,sp,64
 d82:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 d84:	6398                	ld	a4,0(a5)
 d86:	e118                	sd	a4,0(a0)
 d88:	bff1                	j	d64 <malloc+0x88>
  hp->s.size = nu;
 d8a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 d8e:	0541                	addi	a0,a0,16
 d90:	00000097          	auipc	ra,0x0
 d94:	ec4080e7          	jalr	-316(ra) # c54 <free>
  return freep;
 d98:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 d9c:	d971                	beqz	a0,d70 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d9e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 da0:	4798                	lw	a4,8(a5)
 da2:	fa9775e3          	bgeu	a4,s1,d4c <malloc+0x70>
    if(p == freep)
 da6:	00093703          	ld	a4,0(s2)
 daa:	853e                	mv	a0,a5
 dac:	fef719e3          	bne	a4,a5,d9e <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 db0:	8552                	mv	a0,s4
 db2:	00000097          	auipc	ra,0x0
 db6:	b44080e7          	jalr	-1212(ra) # 8f6 <sbrk>
  if(p == (char*)-1)
 dba:	fd5518e3          	bne	a0,s5,d8a <malloc+0xae>
        return 0;
 dbe:	4501                	li	a0,0
 dc0:	bf45                	j	d70 <malloc+0x94>
