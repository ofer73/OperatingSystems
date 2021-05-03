
user/_signaltest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_thread>:
void sig_handler_loop2(int);
void test_thread();
void test_thread2();


void test_thread(){
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
    printf("Thread is now running\n");
       8:	00001517          	auipc	a0,0x1
       c:	03850513          	addi	a0,a0,56 # 1040 <malloc+0xe6>
      10:	00001097          	auipc	ra,0x1
      14:	e8c080e7          	jalr	-372(ra) # e9c <printf>
    kthread_exit(0);
      18:	4501                	li	a0,0
      1a:	00001097          	auipc	ra,0x1
      1e:	b9a080e7          	jalr	-1126(ra) # bb4 <kthread_exit>
}
      22:	60a2                	ld	ra,8(sp)
      24:	6402                	ld	s0,0(sp)
      26:	0141                	addi	sp,sp,16
      28:	8082                	ret

000000000000002a <test_thread2>:
void test_thread2(){
      2a:	1141                	addi	sp,sp,-16
      2c:	e406                	sd	ra,8(sp)
      2e:	e022                	sd	s0,0(sp)
      30:	0800                	addi	s0,sp,16
    printf("Thread is now running\n");
      32:	00001517          	auipc	a0,0x1
      36:	00e50513          	addi	a0,a0,14 # 1040 <malloc+0xe6>
      3a:	00001097          	auipc	ra,0x1
      3e:	e62080e7          	jalr	-414(ra) # e9c <printf>
    kthread_exit(0);
      42:	4501                	li	a0,0
      44:	00001097          	auipc	ra,0x1
      48:	b70080e7          	jalr	-1168(ra) # bb4 <kthread_exit>
}
      4c:	60a2                	ld	ra,8(sp)
      4e:	6402                	ld	s0,0(sp)
      50:	0141                	addi	sp,sp,16
      52:	8082                	ret

0000000000000054 <sig_handler_loop>:
    write(1, st, 5);
    return;
}

void
sig_handler_loop(int signum){
      54:	7179                	addi	sp,sp,-48
      56:	f406                	sd	ra,40(sp)
      58:	f022                	sd	s0,32(sp)
      5a:	ec26                	sd	s1,24(sp)
      5c:	1800                	addi	s0,sp,48
    char st[5] = "dap\n";
      5e:	0a7067b7          	lui	a5,0xa706
      62:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa704433>
      66:	fcf42c23          	sw	a5,-40(s0)
      6a:	fc040e23          	sb	zero,-36(s0)
      6e:	1f400493          	li	s1,500
    for(int i=0;i<500;i++){
        write(1, st, 5);
      72:	4615                	li	a2,5
      74:	fd840593          	addi	a1,s0,-40
      78:	4505                	li	a0,1
      7a:	00001097          	auipc	ra,0x1
      7e:	a92080e7          	jalr	-1390(ra) # b0c <write>
    for(int i=0;i<500;i++){
      82:	34fd                	addiw	s1,s1,-1
      84:	f4fd                	bnez	s1,72 <sig_handler_loop+0x1e>
    }
    
    return;
}
      86:	70a2                	ld	ra,40(sp)
      88:	7402                	ld	s0,32(sp)
      8a:	64e2                	ld	s1,24(sp)
      8c:	6145                	addi	sp,sp,48
      8e:	8082                	ret

0000000000000090 <sig_handler_loop2>:
void
sig_handler_loop2(int signum){
      90:	7179                	addi	sp,sp,-48
      92:	f406                	sd	ra,40(sp)
      94:	f022                	sd	s0,32(sp)
      96:	ec26                	sd	s1,24(sp)
      98:	1800                	addi	s0,sp,48
    char st[5] = "dap\n";
      9a:	0a7067b7          	lui	a5,0xa706
      9e:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa704433>
      a2:	fcf42c23          	sw	a5,-40(s0)
      a6:	fc040e23          	sb	zero,-36(s0)
      aa:	1f400493          	li	s1,500
    for(int i=0;i<500;i++){
        write(1, st, 5);
      ae:	4615                	li	a2,5
      b0:	fd840593          	addi	a1,s0,-40
      b4:	4505                	li	a0,1
      b6:	00001097          	auipc	ra,0x1
      ba:	a56080e7          	jalr	-1450(ra) # b0c <write>
    for(int i=0;i<500;i++){
      be:	34fd                	addiw	s1,s1,-1
      c0:	f4fd                	bnez	s1,ae <sig_handler_loop2+0x1e>
    }
    
    return;
}
      c2:	70a2                	ld	ra,40(sp)
      c4:	7402                	ld	s0,32(sp)
      c6:	64e2                	ld	s1,24(sp)
      c8:	6145                	addi	sp,sp,48
      ca:	8082                	ret

00000000000000cc <sig_handler2>:
void
sig_handler2(int signum){
      cc:	1101                	addi	sp,sp,-32
      ce:	ec06                	sd	ra,24(sp)
      d0:	e822                	sd	s0,16(sp)
      d2:	1000                	addi	s0,sp,32
    char st[5] = "dap\n";
      d4:	0a7067b7          	lui	a5,0xa706
      d8:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa704433>
      dc:	fef42423          	sw	a5,-24(s0)
      e0:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
      e4:	4615                	li	a2,5
      e6:	fe840593          	addi	a1,s0,-24
      ea:	4505                	li	a0,1
      ec:	00001097          	auipc	ra,0x1
      f0:	a20080e7          	jalr	-1504(ra) # b0c <write>
    return;
}
      f4:	60e2                	ld	ra,24(sp)
      f6:	6442                	ld	s0,16(sp)
      f8:	6105                	addi	sp,sp,32
      fa:	8082                	ret

00000000000000fc <test_sigkill>:
test_sigkill(){//
      fc:	7179                	addi	sp,sp,-48
      fe:	f406                	sd	ra,40(sp)
     100:	f022                	sd	s0,32(sp)
     102:	ec26                	sd	s1,24(sp)
     104:	e84a                	sd	s2,16(sp)
     106:	e44e                	sd	s3,8(sp)
     108:	1800                	addi	s0,sp,48
   int pid = fork();
     10a:	00001097          	auipc	ra,0x1
     10e:	9da080e7          	jalr	-1574(ra) # ae4 <fork>
     112:	84aa                	mv	s1,a0
    if(pid==0){
     114:	ed05                	bnez	a0,14c <test_sigkill+0x50>
        sleep(5);
     116:	4515                	li	a0,5
     118:	00001097          	auipc	ra,0x1
     11c:	a64080e7          	jalr	-1436(ra) # b7c <sleep>
            printf("about to get killed %d\n",i);
     120:	00001997          	auipc	s3,0x1
     124:	f3898993          	addi	s3,s3,-200 # 1058 <malloc+0xfe>
        for(int i=0;i<300;i++)
     128:	12c00913          	li	s2,300
            printf("about to get killed %d\n",i);
     12c:	85a6                	mv	a1,s1
     12e:	854e                	mv	a0,s3
     130:	00001097          	auipc	ra,0x1
     134:	d6c080e7          	jalr	-660(ra) # e9c <printf>
        for(int i=0;i<300;i++)
     138:	2485                	addiw	s1,s1,1
     13a:	ff2499e3          	bne	s1,s2,12c <test_sigkill+0x30>
}
     13e:	70a2                	ld	ra,40(sp)
     140:	7402                	ld	s0,32(sp)
     142:	64e2                	ld	s1,24(sp)
     144:	6942                	ld	s2,16(sp)
     146:	69a2                	ld	s3,8(sp)
     148:	6145                	addi	sp,sp,48
     14a:	8082                	ret
        sleep(7);
     14c:	451d                	li	a0,7
     14e:	00001097          	auipc	ra,0x1
     152:	a2e080e7          	jalr	-1490(ra) # b7c <sleep>
        printf("parent send signal to to kill child\n");
     156:	00001517          	auipc	a0,0x1
     15a:	f1a50513          	addi	a0,a0,-230 # 1070 <malloc+0x116>
     15e:	00001097          	auipc	ra,0x1
     162:	d3e080e7          	jalr	-706(ra) # e9c <printf>
        printf("kill ret= %d\n",kill(pid, SIGKILL));
     166:	45a5                	li	a1,9
     168:	8526                	mv	a0,s1
     16a:	00001097          	auipc	ra,0x1
     16e:	9b2080e7          	jalr	-1614(ra) # b1c <kill>
     172:	85aa                	mv	a1,a0
     174:	00001517          	auipc	a0,0x1
     178:	f2450513          	addi	a0,a0,-220 # 1098 <malloc+0x13e>
     17c:	00001097          	auipc	ra,0x1
     180:	d20080e7          	jalr	-736(ra) # e9c <printf>
        printf("parent wait for child\n");
     184:	00001517          	auipc	a0,0x1
     188:	f2450513          	addi	a0,a0,-220 # 10a8 <malloc+0x14e>
     18c:	00001097          	auipc	ra,0x1
     190:	d10080e7          	jalr	-752(ra) # e9c <printf>
        wait(0);
     194:	4501                	li	a0,0
     196:	00001097          	auipc	ra,0x1
     19a:	95e080e7          	jalr	-1698(ra) # af4 <wait>
        printf("parent: child is dead\n");
     19e:	00001517          	auipc	a0,0x1
     1a2:	f2250513          	addi	a0,a0,-222 # 10c0 <malloc+0x166>
     1a6:	00001097          	auipc	ra,0x1
     1aa:	cf6080e7          	jalr	-778(ra) # e9c <printf>
        sleep(10);
     1ae:	4529                	li	a0,10
     1b0:	00001097          	auipc	ra,0x1
     1b4:	9cc080e7          	jalr	-1588(ra) # b7c <sleep>
        exit(0);
     1b8:	4501                	li	a0,0
     1ba:	00001097          	auipc	ra,0x1
     1be:	932080e7          	jalr	-1742(ra) # aec <exit>

00000000000001c2 <sig_handler>:
sig_handler(int signum){
     1c2:	1101                	addi	sp,sp,-32
     1c4:	ec06                	sd	ra,24(sp)
     1c6:	e822                	sd	s0,16(sp)
     1c8:	1000                	addi	s0,sp,32
    char st[5] = "wap\n";
     1ca:	0a7067b7          	lui	a5,0xa706
     1ce:	17778793          	addi	a5,a5,375 # a706177 <__global_pointer$+0xa704446>
     1d2:	fef42423          	sw	a5,-24(s0)
     1d6:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
     1da:	4615                	li	a2,5
     1dc:	fe840593          	addi	a1,s0,-24
     1e0:	4505                	li	a0,1
     1e2:	00001097          	auipc	ra,0x1
     1e6:	92a080e7          	jalr	-1750(ra) # b0c <write>
}
     1ea:	60e2                	ld	ra,24(sp)
     1ec:	6442                	ld	s0,16(sp)
     1ee:	6105                	addi	sp,sp,32
     1f0:	8082                	ret

00000000000001f2 <test_usersig>:


void 
test_usersig(){
     1f2:	7139                	addi	sp,sp,-64
     1f4:	fc06                	sd	ra,56(sp)
     1f6:	f822                	sd	s0,48(sp)
     1f8:	f426                	sd	s1,40(sp)
     1fa:	f04a                	sd	s2,32(sp)
     1fc:	0080                	addi	s0,sp,64
    int pid = fork();
     1fe:	00001097          	auipc	ra,0x1
     202:	8e6080e7          	jalr	-1818(ra) # ae4 <fork>
    int signum1=3;
    if(pid==0){
     206:	e569                	bnez	a0,2d0 <test_usersig+0xde>
        struct sigaction act;
        struct sigaction act2;

        printf("sighandler= %p\n",&sig_handler2);
     208:	00000597          	auipc	a1,0x0
     20c:	ec458593          	addi	a1,a1,-316 # cc <sig_handler2>
     210:	00001517          	auipc	a0,0x1
     214:	ec850513          	addi	a0,a0,-312 # 10d8 <malloc+0x17e>
     218:	00001097          	auipc	ra,0x1
     21c:	c84080e7          	jalr	-892(ra) # e9c <printf>
        uint mask = 0;
        mask ^= (1<<22);

        act.sa_handler = &sig_handler2;
     220:	00000797          	auipc	a5,0x0
     224:	eac78793          	addi	a5,a5,-340 # cc <sig_handler2>
     228:	fcf43023          	sd	a5,-64(s0)
        act.sigmask = mask;
     22c:	004007b7          	lui	a5,0x400
     230:	fcf42423          	sw	a5,-56(s0)
        

        struct sigaction oldact;
        oldact.sigmask=0;
     234:	fc042c23          	sw	zero,-40(s0)
        oldact.sa_handler=0;
     238:	fc043823          	sd	zero,-48(s0)
        int ret=sigaction(signum1,&act,&oldact);
     23c:	fd040613          	addi	a2,s0,-48
     240:	fc040593          	addi	a1,s0,-64
     244:	450d                	li	a0,3
     246:	00001097          	auipc	ra,0x1
     24a:	94e080e7          	jalr	-1714(ra) # b94 <sigaction>
     24e:	84aa                	mv	s1,a0
        printf("old act->sa handler= %p, mask=%d\n",oldact.sa_handler,oldact.sigmask);
     250:	fd842603          	lw	a2,-40(s0)
     254:	fd043583          	ld	a1,-48(s0)
     258:	00001517          	auipc	a0,0x1
     25c:	e9050513          	addi	a0,a0,-368 # 10e8 <malloc+0x18e>
     260:	00001097          	auipc	ra,0x1
     264:	c3c080e7          	jalr	-964(ra) # e9c <printf>
        printf("child return from sigaction = %d\n",ret);
     268:	85a6                	mv	a1,s1
     26a:	00001517          	auipc	a0,0x1
     26e:	ea650513          	addi	a0,a0,-346 # 1110 <malloc+0x1b6>
     272:	00001097          	auipc	ra,0x1
     276:	c2a080e7          	jalr	-982(ra) # e9c <printf>
        sleep(10);
     27a:	4529                	li	a0,10
     27c:	00001097          	auipc	ra,0x1
     280:	900080e7          	jalr	-1792(ra) # b7c <sleep>
     284:	44a9                	li	s1,10
        for(int i=0;i<10;i++){
            printf("child doing stuff before exit \n");
     286:	00001917          	auipc	s2,0x1
     28a:	eb290913          	addi	s2,s2,-334 # 1138 <malloc+0x1de>
     28e:	854a                	mv	a0,s2
     290:	00001097          	auipc	ra,0x1
     294:	c0c080e7          	jalr	-1012(ra) # e9c <printf>
        for(int i=0;i<10;i++){
     298:	34fd                	addiw	s1,s1,-1
     29a:	f8f5                	bnez	s1,28e <test_usersig+0x9c>
        }
        ret=sigaction(signum1,&act,&oldact);
     29c:	fd040613          	addi	a2,s0,-48
     2a0:	fc040593          	addi	a1,s0,-64
     2a4:	450d                	li	a0,3
     2a6:	00001097          	auipc	ra,0x1
     2aa:	8ee080e7          	jalr	-1810(ra) # b94 <sigaction>
        printf("oldact should be the same as new act before \n oldact->mask=%d \t oldact->sa_handler=%d \n",oldact.sigmask,oldact.sa_handler);
     2ae:	fd043603          	ld	a2,-48(s0)
     2b2:	fd842583          	lw	a1,-40(s0)
     2b6:	00001517          	auipc	a0,0x1
     2ba:	ea250513          	addi	a0,a0,-350 # 1158 <malloc+0x1fe>
     2be:	00001097          	auipc	ra,0x1
     2c2:	bde080e7          	jalr	-1058(ra) # e9c <printf>

        exit(0);
     2c6:	4501                	li	a0,0
     2c8:	00001097          	auipc	ra,0x1
     2cc:	824080e7          	jalr	-2012(ra) # aec <exit>
     2d0:	84aa                	mv	s1,a0

    }
    else{
        sleep(5);
     2d2:	4515                	li	a0,5
     2d4:	00001097          	auipc	ra,0x1
     2d8:	8a8080e7          	jalr	-1880(ra) # b7c <sleep>
        printf("parent send sig 3 to child ret=%d\n",kill(pid,signum1));
     2dc:	458d                	li	a1,3
     2de:	8526                	mv	a0,s1
     2e0:	00001097          	auipc	ra,0x1
     2e4:	83c080e7          	jalr	-1988(ra) # b1c <kill>
     2e8:	85aa                	mv	a1,a0
     2ea:	00001517          	auipc	a0,0x1
     2ee:	ec650513          	addi	a0,a0,-314 # 11b0 <malloc+0x256>
     2f2:	00001097          	auipc	ra,0x1
     2f6:	baa080e7          	jalr	-1110(ra) # e9c <printf>
        // printf("parent send sig 4 to child ret=%d\n",kill(pid,4));

        wait(0);
     2fa:	4501                	li	a0,0
     2fc:	00000097          	auipc	ra,0x0
     300:	7f8080e7          	jalr	2040(ra) # af4 <wait>
        exit(0);
     304:	4501                	li	a0,0
     306:	00000097          	auipc	ra,0x0
     30a:	7e6080e7          	jalr	2022(ra) # aec <exit>

000000000000030e <test_block>:
    }
}
void 
test_block(){//parent block 22 child block 23 
     30e:	7179                	addi	sp,sp,-48
     310:	f406                	sd	ra,40(sp)
     312:	f022                	sd	s0,32(sp)
     314:	ec26                	sd	s1,24(sp)
     316:	e84a                	sd	s2,16(sp)
     318:	e44e                	sd	s3,8(sp)
     31a:	1800                	addi	s0,sp,48
//          child get both signal and need do block the both

    int signum1=22;
    int signum2=23;
    int ans=sigprocmask(1<<signum1);
     31c:	00400537          	lui	a0,0x400
     320:	00001097          	auipc	ra,0x1
     324:	86c080e7          	jalr	-1940(ra) # b8c <sigprocmask>
    printf("got %d from calling to sigprocmask\n",ans);
     328:	0005059b          	sext.w	a1,a0
     32c:	00001517          	auipc	a0,0x1
     330:	eac50513          	addi	a0,a0,-340 # 11d8 <malloc+0x27e>
     334:	00001097          	auipc	ra,0x1
     338:	b68080e7          	jalr	-1176(ra) # e9c <printf>
    int pid=fork();
     33c:	00000097          	auipc	ra,0x0
     340:	7a8080e7          	jalr	1960(ra) # ae4 <fork>
     344:	892a                	mv	s2,a0
    if(pid==0){
     346:	c535                	beqz	a0,3b2 <test_block+0xa4>
            printf("child blocking signal %d \n",i);
        }
        exit(0);

    }else{
        sleep(1);//wait for child to block sig
     348:	4505                	li	a0,1
     34a:	00001097          	auipc	ra,0x1
     34e:	832080e7          	jalr	-1998(ra) # b7c <sleep>
        printf("parent: sent signal 22 to child ->child shuld block\n");
     352:	00001517          	auipc	a0,0x1
     356:	ece50513          	addi	a0,a0,-306 # 1220 <malloc+0x2c6>
     35a:	00001097          	auipc	ra,0x1
     35e:	b42080e7          	jalr	-1214(ra) # e9c <printf>
     362:	44a9                	li	s1,10
        for(int i=0; i<10;i++){
            kill(pid,signum1);
     364:	45d9                	li	a1,22
     366:	854a                	mv	a0,s2
     368:	00000097          	auipc	ra,0x0
     36c:	7b4080e7          	jalr	1972(ra) # b1c <kill>
        for(int i=0; i<10;i++){
     370:	34fd                	addiw	s1,s1,-1
     372:	f8ed                	bnez	s1,364 <test_block+0x56>
        }
        sleep(10);
     374:	4529                	li	a0,10
     376:	00001097          	auipc	ra,0x1
     37a:	806080e7          	jalr	-2042(ra) # b7c <sleep>
        kill(pid,signum2);
     37e:	45dd                	li	a1,23
     380:	854a                	mv	a0,s2
     382:	00000097          	auipc	ra,0x0
     386:	79a080e7          	jalr	1946(ra) # b1c <kill>

        printf("parent: sent signal 23 to child ->child shuld die\n");
     38a:	00001517          	auipc	a0,0x1
     38e:	ece50513          	addi	a0,a0,-306 # 1258 <malloc+0x2fe>
     392:	00001097          	auipc	ra,0x1
     396:	b0a080e7          	jalr	-1270(ra) # e9c <printf>
        wait(0);
     39a:	4501                	li	a0,0
     39c:	00000097          	auipc	ra,0x0
     3a0:	758080e7          	jalr	1880(ra) # af4 <wait>
    }
    // exit(0);
}
     3a4:	70a2                	ld	ra,40(sp)
     3a6:	7402                	ld	s0,32(sp)
     3a8:	64e2                	ld	s1,24(sp)
     3aa:	6942                	ld	s2,16(sp)
     3ac:	69a2                	ld	s3,8(sp)
     3ae:	6145                	addi	sp,sp,48
     3b0:	8082                	ret
        sleep(3);
     3b2:	450d                	li	a0,3
     3b4:	00000097          	auipc	ra,0x0
     3b8:	7c8080e7          	jalr	1992(ra) # b7c <sleep>
            printf("child blocking signal %d \n",i);
     3bc:	00001997          	auipc	s3,0x1
     3c0:	e4498993          	addi	s3,s3,-444 # 1200 <malloc+0x2a6>
        for(int i=0;i<1000;i++){
     3c4:	3e800493          	li	s1,1000
            sleep(1);
     3c8:	4505                	li	a0,1
     3ca:	00000097          	auipc	ra,0x0
     3ce:	7b2080e7          	jalr	1970(ra) # b7c <sleep>
            printf("child blocking signal %d \n",i);
     3d2:	85ca                	mv	a1,s2
     3d4:	854e                	mv	a0,s3
     3d6:	00001097          	auipc	ra,0x1
     3da:	ac6080e7          	jalr	-1338(ra) # e9c <printf>
        for(int i=0;i<1000;i++){
     3de:	2905                	addiw	s2,s2,1
     3e0:	fe9914e3          	bne	s2,s1,3c8 <test_block+0xba>
        exit(0);
     3e4:	4501                	li	a0,0
     3e6:	00000097          	auipc	ra,0x0
     3ea:	706080e7          	jalr	1798(ra) # aec <exit>

00000000000003ee <test_stop_cont>:

void
test_stop_cont(){
     3ee:	7179                	addi	sp,sp,-48
     3f0:	f406                	sd	ra,40(sp)
     3f2:	f022                	sd	s0,32(sp)
     3f4:	ec26                	sd	s1,24(sp)
     3f6:	e84a                	sd	s2,16(sp)
     3f8:	e44e                	sd	s3,8(sp)
     3fa:	1800                	addi	s0,sp,48
    int pid = fork();
     3fc:	00000097          	auipc	ra,0x0
     400:	6e8080e7          	jalr	1768(ra) # ae4 <fork>
     404:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
     406:	e915                	bnez	a0,43a <test_stop_cont+0x4c>
        sleep(2);
     408:	4509                	li	a0,2
     40a:	00000097          	auipc	ra,0x0
     40e:	772080e7          	jalr	1906(ra) # b7c <sleep>
        for(i=0;i<500;i++){
            printf("%d\n ", i);
     412:	00001997          	auipc	s3,0x1
     416:	e7e98993          	addi	s3,s3,-386 # 1290 <malloc+0x336>
        for(i=0;i<500;i++){
     41a:	1f400913          	li	s2,500
            printf("%d\n ", i);
     41e:	85a6                	mv	a1,s1
     420:	854e                	mv	a0,s3
     422:	00001097          	auipc	ra,0x1
     426:	a7a080e7          	jalr	-1414(ra) # e9c <printf>
        for(i=0;i<500;i++){
     42a:	2485                	addiw	s1,s1,1
     42c:	ff2499e3          	bne	s1,s2,41e <test_stop_cont+0x30>
        }
        exit(0);
     430:	4501                	li	a0,0
     432:	00000097          	auipc	ra,0x0
     436:	6ba080e7          	jalr	1722(ra) # aec <exit>
    }else{
        printf("son pid=%d, dad pid=%d\n", pid, getpid());
     43a:	00000097          	auipc	ra,0x0
     43e:	732080e7          	jalr	1842(ra) # b6c <getpid>
     442:	862a                	mv	a2,a0
     444:	85a6                	mv	a1,s1
     446:	00001517          	auipc	a0,0x1
     44a:	e5250513          	addi	a0,a0,-430 # 1298 <malloc+0x33e>
     44e:	00001097          	auipc	ra,0x1
     452:	a4e080e7          	jalr	-1458(ra) # e9c <printf>
        sleep(5);
     456:	4515                	li	a0,5
     458:	00000097          	auipc	ra,0x0
     45c:	724080e7          	jalr	1828(ra) # b7c <sleep>
        printf("parent send stop ret= %d\n", kill(pid, SIGSTOP));
     460:	45c5                	li	a1,17
     462:	8526                	mv	a0,s1
     464:	00000097          	auipc	ra,0x0
     468:	6b8080e7          	jalr	1720(ra) # b1c <kill>
     46c:	85aa                	mv	a1,a0
     46e:	00001517          	auipc	a0,0x1
     472:	e4250513          	addi	a0,a0,-446 # 12b0 <malloc+0x356>
     476:	00001097          	auipc	ra,0x1
     47a:	a26080e7          	jalr	-1498(ra) # e9c <printf>
        sleep(50);
     47e:	03200513          	li	a0,50
     482:	00000097          	auipc	ra,0x0
     486:	6fa080e7          	jalr	1786(ra) # b7c <sleep>
        printf("parent send continue ret= %d\n", kill(pid, SIGCONT));
     48a:	45cd                	li	a1,19
     48c:	8526                	mv	a0,s1
     48e:	00000097          	auipc	ra,0x0
     492:	68e080e7          	jalr	1678(ra) # b1c <kill>
     496:	85aa                	mv	a1,a0
     498:	00001517          	auipc	a0,0x1
     49c:	e3850513          	addi	a0,a0,-456 # 12d0 <malloc+0x376>
     4a0:	00001097          	auipc	ra,0x1
     4a4:	9fc080e7          	jalr	-1540(ra) # e9c <printf>
        wait(0);
     4a8:	4501                	li	a0,0
     4aa:	00000097          	auipc	ra,0x0
     4ae:	64a080e7          	jalr	1610(ra) # af4 <wait>
        // for(int i=0;i<100;i++)
        //  printf("parent..");
        sleep(10);
     4b2:	4529                	li	a0,10
     4b4:	00000097          	auipc	ra,0x0
     4b8:	6c8080e7          	jalr	1736(ra) # b7c <sleep>
        exit(0);
     4bc:	4501                	li	a0,0
     4be:	00000097          	auipc	ra,0x0
     4c2:	62e080e7          	jalr	1582(ra) # aec <exit>

00000000000004c6 <test_ignore>:
    }
}

void 
test_ignore(){
     4c6:	7179                	addi	sp,sp,-48
     4c8:	f406                	sd	ra,40(sp)
     4ca:	f022                	sd	s0,32(sp)
     4cc:	ec26                	sd	s1,24(sp)
     4ce:	e84a                	sd	s2,16(sp)
     4d0:	e44e                	sd	s3,8(sp)
     4d2:	1800                	addi	s0,sp,48
    int pid= fork();
     4d4:	00000097          	auipc	ra,0x0
     4d8:	610080e7          	jalr	1552(ra) # ae4 <fork>
     4dc:	84aa                	mv	s1,a0
    int signum=22;
    if(pid==0){
     4de:	c129                	beqz	a0,520 <test_ignore+0x5a>
            printf("child ignoring signal %d\n",i);
        }
        exit(0);

    }else{
        printf("son pid= %d",pid);
     4e0:	85aa                	mv	a1,a0
     4e2:	00001517          	auipc	a0,0x1
     4e6:	e7650513          	addi	a0,a0,-394 # 1358 <malloc+0x3fe>
     4ea:	00001097          	auipc	ra,0x1
     4ee:	9b2080e7          	jalr	-1614(ra) # e9c <printf>
        sleep(5);
     4f2:	4515                	li	a0,5
     4f4:	00000097          	auipc	ra,0x0
     4f8:	688080e7          	jalr	1672(ra) # b7c <sleep>
        kill(pid,signum);
     4fc:	45d9                	li	a1,22
     4fe:	8526                	mv	a0,s1
     500:	00000097          	auipc	ra,0x0
     504:	61c080e7          	jalr	1564(ra) # b1c <kill>
        wait(0);
     508:	4501                	li	a0,0
     50a:	00000097          	auipc	ra,0x0
     50e:	5ea080e7          	jalr	1514(ra) # af4 <wait>

    }
}
     512:	70a2                	ld	ra,40(sp)
     514:	7402                	ld	s0,32(sp)
     516:	64e2                	ld	s1,24(sp)
     518:	6942                	ld	s2,16(sp)
     51a:	69a2                	ld	s3,8(sp)
     51c:	6145                	addi	sp,sp,48
     51e:	8082                	ret
        newAct=malloc(sizeof(sigaction));
     520:	4505                	li	a0,1
     522:	00001097          	auipc	ra,0x1
     526:	a38080e7          	jalr	-1480(ra) # f5a <malloc>
     52a:	89aa                	mv	s3,a0
        oldAct=malloc(sizeof(sigaction));
     52c:	4505                	li	a0,1
     52e:	00001097          	auipc	ra,0x1
     532:	a2c080e7          	jalr	-1492(ra) # f5a <malloc>
     536:	892a                	mv	s2,a0
        newAct->sigmask = 0;
     538:	0009a423          	sw	zero,8(s3)
        newAct->sa_handler=(void*)SIG_IGN;
     53c:	4785                	li	a5,1
     53e:	00f9b023          	sd	a5,0(s3)
        int ans=sigaction(signum,newAct,oldAct);
     542:	862a                	mv	a2,a0
     544:	85ce                	mv	a1,s3
     546:	4559                	li	a0,22
     548:	00000097          	auipc	ra,0x0
     54c:	64c080e7          	jalr	1612(ra) # b94 <sigaction>
     550:	85aa                	mv	a1,a0
        printf("ans from sigaction %d, old act returned is: mask= %d address= %d\n",ans,oldAct->sigmask,(uint64)oldAct->sa_handler);
     552:	00093683          	ld	a3,0(s2)
     556:	00892603          	lw	a2,8(s2)
     55a:	00001517          	auipc	a0,0x1
     55e:	d9650513          	addi	a0,a0,-618 # 12f0 <malloc+0x396>
     562:	00001097          	auipc	ra,0x1
     566:	93a080e7          	jalr	-1734(ra) # e9c <printf>
        sleep(6);
     56a:	4519                	li	a0,6
     56c:	00000097          	auipc	ra,0x0
     570:	610080e7          	jalr	1552(ra) # b7c <sleep>
            printf("child ignoring signal %d\n",i);
     574:	00001997          	auipc	s3,0x1
     578:	dc498993          	addi	s3,s3,-572 # 1338 <malloc+0x3de>
        for(int i=0;i<300;i++){
     57c:	12c00913          	li	s2,300
            printf("child ignoring signal %d\n",i);
     580:	85a6                	mv	a1,s1
     582:	854e                	mv	a0,s3
     584:	00001097          	auipc	ra,0x1
     588:	918080e7          	jalr	-1768(ra) # e9c <printf>
        for(int i=0;i<300;i++){
     58c:	2485                	addiw	s1,s1,1
     58e:	ff2499e3          	bne	s1,s2,580 <test_ignore+0xba>
        exit(0);
     592:	4501                	li	a0,0
     594:	00000097          	auipc	ra,0x0
     598:	558080e7          	jalr	1368(ra) # aec <exit>

000000000000059c <test_user_handler_kill>:
void
test_user_handler_kill(){
     59c:	715d                	addi	sp,sp,-80
     59e:	e486                	sd	ra,72(sp)
     5a0:	e0a2                	sd	s0,64(sp)
     5a2:	fc26                	sd	s1,56(sp)
     5a4:	f84a                	sd	s2,48(sp)
     5a6:	f44e                	sd	s3,40(sp)
     5a8:	0880                	addi	s0,sp,80
    struct sigaction act;

    printf("sighandler1= %p\n", &sig_handler_loop);
     5aa:	00000597          	auipc	a1,0x0
     5ae:	aaa58593          	addi	a1,a1,-1366 # 54 <sig_handler_loop>
     5b2:	00001517          	auipc	a0,0x1
     5b6:	db650513          	addi	a0,a0,-586 # 1368 <malloc+0x40e>
     5ba:	00001097          	auipc	ra,0x1
     5be:	8e2080e7          	jalr	-1822(ra) # e9c <printf>
    printf("sighandler2= %p\n", &sig_handler_loop2);
     5c2:	00000597          	auipc	a1,0x0
     5c6:	ace58593          	addi	a1,a1,-1330 # 90 <sig_handler_loop2>
     5ca:	00001517          	auipc	a0,0x1
     5ce:	db650513          	addi	a0,a0,-586 # 1380 <malloc+0x426>
     5d2:	00001097          	auipc	ra,0x1
     5d6:	8ca080e7          	jalr	-1846(ra) # e9c <printf>


    uint mask = 0;
    mask ^= (1<<22);

    act.sigmask = mask;
     5da:	004007b7          	lui	a5,0x400
     5de:	fcf42423          	sw	a5,-56(s0)
    
    struct sigaction oldact;
    oldact.sigmask=0;
     5e2:	fa042c23          	sw	zero,-72(s0)
    oldact.sa_handler=0;
     5e6:	fa043823          	sd	zero,-80(s0)
    
    act.sa_handler=&sig_handler_loop2;
     5ea:	00000797          	auipc	a5,0x0
     5ee:	aa678793          	addi	a5,a5,-1370 # 90 <sig_handler_loop2>
     5f2:	fcf43023          	sd	a5,-64(s0)


    int pid = fork();
     5f6:	00000097          	auipc	ra,0x0
     5fa:	4ee080e7          	jalr	1262(ra) # ae4 <fork>
     5fe:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
     600:	ed15                	bnez	a0,63c <test_user_handler_kill+0xa0>
        int ret=sigaction(3,&act,&oldact);
     602:	fb040613          	addi	a2,s0,-80
     606:	fc040593          	addi	a1,s0,-64
     60a:	450d                	li	a0,3
     60c:	00000097          	auipc	ra,0x0
     610:	588080e7          	jalr	1416(ra) # b94 <sigaction>
        for(i=0;i<500;i++)
            printf("out-side handler %d\n ", i);
     614:	00001997          	auipc	s3,0x1
     618:	d8498993          	addi	s3,s3,-636 # 1398 <malloc+0x43e>
        for(i=0;i<500;i++)
     61c:	1f400913          	li	s2,500
            printf("out-side handler %d\n ", i);
     620:	85a6                	mv	a1,s1
     622:	854e                	mv	a0,s3
     624:	00001097          	auipc	ra,0x1
     628:	878080e7          	jalr	-1928(ra) # e9c <printf>
        for(i=0;i<500;i++)
     62c:	2485                	addiw	s1,s1,1
     62e:	ff2499e3          	bne	s1,s2,620 <test_user_handler_kill+0x84>
        exit(0);
     632:	4501                	li	a0,0
     634:	00000097          	auipc	ra,0x0
     638:	4b8080e7          	jalr	1208(ra) # aec <exit>
    }else{
        printf("son pid=%d, dad pid=%d\n",pid, getpid());
     63c:	00000097          	auipc	ra,0x0
     640:	530080e7          	jalr	1328(ra) # b6c <getpid>
     644:	862a                	mv	a2,a0
     646:	85a6                	mv	a1,s1
     648:	00001517          	auipc	a0,0x1
     64c:	c5050513          	addi	a0,a0,-944 # 1298 <malloc+0x33e>
     650:	00001097          	auipc	ra,0x1
     654:	84c080e7          	jalr	-1972(ra) # e9c <printf>
        sleep(5);
     658:	4515                	li	a0,5
     65a:	00000097          	auipc	ra,0x0
     65e:	522080e7          	jalr	1314(ra) # b7c <sleep>
        printf("parent send loop ret= %d\n",kill(pid, 3));
     662:	458d                	li	a1,3
     664:	8526                	mv	a0,s1
     666:	00000097          	auipc	ra,0x0
     66a:	4b6080e7          	jalr	1206(ra) # b1c <kill>
     66e:	85aa                	mv	a1,a0
     670:	00001517          	auipc	a0,0x1
     674:	d4050513          	addi	a0,a0,-704 # 13b0 <malloc+0x456>
     678:	00001097          	auipc	ra,0x1
     67c:	824080e7          	jalr	-2012(ra) # e9c <printf>
        sleep(20);
     680:	4551                	li	a0,20
     682:	00000097          	auipc	ra,0x0
     686:	4fa080e7          	jalr	1274(ra) # b7c <sleep>
        printf("parent send kill ret= %d\n",kill(pid, SIGKILL));
     68a:	45a5                	li	a1,9
     68c:	8526                	mv	a0,s1
     68e:	00000097          	auipc	ra,0x0
     692:	48e080e7          	jalr	1166(ra) # b1c <kill>
     696:	85aa                	mv	a1,a0
     698:	00001517          	auipc	a0,0x1
     69c:	d3850513          	addi	a0,a0,-712 # 13d0 <malloc+0x476>
     6a0:	00000097          	auipc	ra,0x0
     6a4:	7fc080e7          	jalr	2044(ra) # e9c <printf>
        wait(0);
     6a8:	4501                	li	a0,0
     6aa:	00000097          	auipc	ra,0x0
     6ae:	44a080e7          	jalr	1098(ra) # af4 <wait>
        printf("parent exiting\n");
     6b2:	00001517          	auipc	a0,0x1
     6b6:	d3e50513          	addi	a0,a0,-706 # 13f0 <malloc+0x496>
     6ba:	00000097          	auipc	ra,0x0
     6be:	7e2080e7          	jalr	2018(ra) # e9c <printf>
        exit(0);
     6c2:	4501                	li	a0,0
     6c4:	00000097          	auipc	ra,0x0
     6c8:	428080e7          	jalr	1064(ra) # aec <exit>

00000000000006cc <thread_test>:
    }
}

//TODO delete func
void thread_test(char *s){
     6cc:	7179                	addi	sp,sp,-48
     6ce:	f406                	sd	ra,40(sp)
     6d0:	f022                	sd	s0,32(sp)
     6d2:	ec26                	sd	s1,24(sp)
     6d4:	e84a                	sd	s2,16(sp)
     6d6:	1800                	addi	s0,sp,48
    int tid;
    int status;
    void* stack = malloc(4000);
     6d8:	6505                	lui	a0,0x1
     6da:	fa050513          	addi	a0,a0,-96 # fa0 <malloc+0x46>
     6de:	00001097          	auipc	ra,0x1
     6e2:	87c080e7          	jalr	-1924(ra) # f5a <malloc>
     6e6:	84aa                	mv	s1,a0
    printf("father tid is = %d\n",kthread_id());
     6e8:	00000097          	auipc	ra,0x0
     6ec:	4c4080e7          	jalr	1220(ra) # bac <kthread_id>
     6f0:	85aa                	mv	a1,a0
     6f2:	00001517          	auipc	a0,0x1
     6f6:	d0e50513          	addi	a0,a0,-754 # 1400 <malloc+0x4a6>
     6fa:	00000097          	auipc	ra,0x0
     6fe:	7a2080e7          	jalr	1954(ra) # e9c <printf>
    tid = kthread_create(test_thread, stack);
     702:	85a6                	mv	a1,s1
     704:	00000517          	auipc	a0,0x0
     708:	8fc50513          	addi	a0,a0,-1796 # 0 <test_thread>
     70c:	00000097          	auipc	ra,0x0
     710:	498080e7          	jalr	1176(ra) # ba4 <kthread_create>
     714:	892a                	mv	s2,a0

    printf("after create %d \n",tid);
     716:	85aa                	mv	a1,a0
     718:	00001517          	auipc	a0,0x1
     71c:	d0050513          	addi	a0,a0,-768 # 1418 <malloc+0x4be>
     720:	00000097          	auipc	ra,0x0
     724:	77c080e7          	jalr	1916(ra) # e9c <printf>

    int ans =kthread_join(tid, &status);
     728:	fdc40593          	addi	a1,s0,-36
     72c:	854a                	mv	a0,s2
     72e:	00000097          	auipc	ra,0x0
     732:	48e080e7          	jalr	1166(ra) # bbc <kthread_join>
     736:	85aa                	mv	a1,a0
    printf("kthread join ret =%d\n",ans);
     738:	00001517          	auipc	a0,0x1
     73c:	cf850513          	addi	a0,a0,-776 # 1430 <malloc+0x4d6>
     740:	00000097          	auipc	ra,0x0
     744:	75c080e7          	jalr	1884(ra) # e9c <printf>
    tid = kthread_id();
     748:	00000097          	auipc	ra,0x0
     74c:	464080e7          	jalr	1124(ra) # bac <kthread_id>
     750:	892a                	mv	s2,a0
    free(stack);
     752:	8526                	mv	a0,s1
     754:	00000097          	auipc	ra,0x0
     758:	77e080e7          	jalr	1918(ra) # ed2 <free>
    printf("Finished testing threads, main thread id: %d, %d\n", tid,status);
     75c:	fdc42603          	lw	a2,-36(s0)
     760:	85ca                	mv	a1,s2
     762:	00001517          	auipc	a0,0x1
     766:	ce650513          	addi	a0,a0,-794 # 1448 <malloc+0x4ee>
     76a:	00000097          	auipc	ra,0x0
     76e:	732080e7          	jalr	1842(ra) # e9c <printf>
}
     772:	70a2                	ld	ra,40(sp)
     774:	7402                	ld	s0,32(sp)
     776:	64e2                	ld	s1,24(sp)
     778:	6942                	ld	s2,16(sp)
     77a:	6145                	addi	sp,sp,48
     77c:	8082                	ret

000000000000077e <thread_test2>:
void thread_test2(char *s){
     77e:	1101                	addi	sp,sp,-32
     780:	ec06                	sd	ra,24(sp)
     782:	e822                	sd	s0,16(sp)
     784:	e426                	sd	s1,8(sp)
     786:	e04a                	sd	s2,0(sp)
     788:	1000                	addi	s0,sp,32
    int tid;
    int status;
    void* stack = malloc(4000);
     78a:	6505                	lui	a0,0x1
     78c:	fa050513          	addi	a0,a0,-96 # fa0 <malloc+0x46>
     790:	00000097          	auipc	ra,0x0
     794:	7ca080e7          	jalr	1994(ra) # f5a <malloc>
     798:	84aa                	mv	s1,a0
    printf("after malloc\n");
     79a:	00001517          	auipc	a0,0x1
     79e:	ce650513          	addi	a0,a0,-794 # 1480 <malloc+0x526>
     7a2:	00000097          	auipc	ra,0x0
     7a6:	6fa080e7          	jalr	1786(ra) # e9c <printf>
    printf("add of func for new thread : %p\n",&test_thread);
     7aa:	00000597          	auipc	a1,0x0
     7ae:	85658593          	addi	a1,a1,-1962 # 0 <test_thread>
     7b2:	00001517          	auipc	a0,0x1
     7b6:	cde50513          	addi	a0,a0,-802 # 1490 <malloc+0x536>
     7ba:	00000097          	auipc	ra,0x0
     7be:	6e2080e7          	jalr	1762(ra) # e9c <printf>
    printf("add of func for new thread : %p\n",&test_thread2);
     7c2:	00000597          	auipc	a1,0x0
     7c6:	86858593          	addi	a1,a1,-1944 # 2a <test_thread2>
     7ca:	00001517          	auipc	a0,0x1
     7ce:	cc650513          	addi	a0,a0,-826 # 1490 <malloc+0x536>
     7d2:	00000097          	auipc	ra,0x0
     7d6:	6ca080e7          	jalr	1738(ra) # e9c <printf>

    tid = kthread_create(&test_thread2, stack);
     7da:	85a6                	mv	a1,s1
     7dc:	00000517          	auipc	a0,0x0
     7e0:	84e50513          	addi	a0,a0,-1970 # 2a <test_thread2>
     7e4:	00000097          	auipc	ra,0x0
     7e8:	3c0080e7          	jalr	960(ra) # ba4 <kthread_create>
     7ec:	85aa                	mv	a1,a0
    
    printf("after create %d \n",tid);
     7ee:	00001517          	auipc	a0,0x1
     7f2:	c2a50513          	addi	a0,a0,-982 # 1418 <malloc+0x4be>
     7f6:	00000097          	auipc	ra,0x0
     7fa:	6a6080e7          	jalr	1702(ra) # e9c <printf>

    sleep(5);
     7fe:	4515                	li	a0,5
     800:	00000097          	auipc	ra,0x0
     804:	37c080e7          	jalr	892(ra) # b7c <sleep>
    printf("after kthread\n");
     808:	00001517          	auipc	a0,0x1
     80c:	cb050513          	addi	a0,a0,-848 # 14b8 <malloc+0x55e>
     810:	00000097          	auipc	ra,0x0
     814:	68c080e7          	jalr	1676(ra) # e9c <printf>
    tid = kthread_id();
     818:	00000097          	auipc	ra,0x0
     81c:	394080e7          	jalr	916(ra) # bac <kthread_id>
     820:	892a                	mv	s2,a0
    free(stack);
     822:	8526                	mv	a0,s1
     824:	00000097          	auipc	ra,0x0
     828:	6ae080e7          	jalr	1710(ra) # ed2 <free>
    printf("Finished testing threads, main thread id: %d, %d\n", tid,status);
     82c:	4601                	li	a2,0
     82e:	85ca                	mv	a1,s2
     830:	00001517          	auipc	a0,0x1
     834:	c1850513          	addi	a0,a0,-1000 # 1448 <malloc+0x4ee>
     838:	00000097          	auipc	ra,0x0
     83c:	664080e7          	jalr	1636(ra) # e9c <printf>
}
     840:	60e2                	ld	ra,24(sp)
     842:	6442                	ld	s0,16(sp)
     844:	64a2                	ld	s1,8(sp)
     846:	6902                	ld	s2,0(sp)
     848:	6105                	addi	sp,sp,32
     84a:	8082                	ret

000000000000084c <main>:


int main(){
     84c:	1141                	addi	sp,sp,-16
     84e:	e406                	sd	ra,8(sp)
     850:	e022                	sd	s0,0(sp)
     852:	0800                	addi	s0,sp,16
    // printf("-----------------------------test_ignore-----------------------------\n");
    // test_ignore();
    // printf("-----------------------------test_user_handler_then_kill-----------------------------\n");
    // test_user_handler_kill();

    printf("-----------------------------thread_test-----------------------------\n");
     854:	00001517          	auipc	a0,0x1
     858:	c7450513          	addi	a0,a0,-908 # 14c8 <malloc+0x56e>
     85c:	00000097          	auipc	ra,0x0
     860:	640080e7          	jalr	1600(ra) # e9c <printf>
    thread_test("fuck");
     864:	00001517          	auipc	a0,0x1
     868:	cac50513          	addi	a0,a0,-852 # 1510 <malloc+0x5b6>
     86c:	00000097          	auipc	ra,0x0
     870:	e60080e7          	jalr	-416(ra) # 6cc <thread_test>

    // printf("-----------------------------thread_test2-----------------------------\n");
    // thread_test2("fuck");

    exit(0);
     874:	4501                	li	a0,0
     876:	00000097          	auipc	ra,0x0
     87a:	276080e7          	jalr	630(ra) # aec <exit>

000000000000087e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     87e:	1141                	addi	sp,sp,-16
     880:	e422                	sd	s0,8(sp)
     882:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     884:	87aa                	mv	a5,a0
     886:	0585                	addi	a1,a1,1
     888:	0785                	addi	a5,a5,1
     88a:	fff5c703          	lbu	a4,-1(a1)
     88e:	fee78fa3          	sb	a4,-1(a5)
     892:	fb75                	bnez	a4,886 <strcpy+0x8>
    ;
  return os;
}
     894:	6422                	ld	s0,8(sp)
     896:	0141                	addi	sp,sp,16
     898:	8082                	ret

000000000000089a <strcmp>:

int
strcmp(const char *p, const char *q)
{
     89a:	1141                	addi	sp,sp,-16
     89c:	e422                	sd	s0,8(sp)
     89e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     8a0:	00054783          	lbu	a5,0(a0)
     8a4:	cb91                	beqz	a5,8b8 <strcmp+0x1e>
     8a6:	0005c703          	lbu	a4,0(a1)
     8aa:	00f71763          	bne	a4,a5,8b8 <strcmp+0x1e>
    p++, q++;
     8ae:	0505                	addi	a0,a0,1
     8b0:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     8b2:	00054783          	lbu	a5,0(a0)
     8b6:	fbe5                	bnez	a5,8a6 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     8b8:	0005c503          	lbu	a0,0(a1)
}
     8bc:	40a7853b          	subw	a0,a5,a0
     8c0:	6422                	ld	s0,8(sp)
     8c2:	0141                	addi	sp,sp,16
     8c4:	8082                	ret

00000000000008c6 <strlen>:

uint
strlen(const char *s)
{
     8c6:	1141                	addi	sp,sp,-16
     8c8:	e422                	sd	s0,8(sp)
     8ca:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     8cc:	00054783          	lbu	a5,0(a0)
     8d0:	cf91                	beqz	a5,8ec <strlen+0x26>
     8d2:	0505                	addi	a0,a0,1
     8d4:	87aa                	mv	a5,a0
     8d6:	4685                	li	a3,1
     8d8:	9e89                	subw	a3,a3,a0
     8da:	00f6853b          	addw	a0,a3,a5
     8de:	0785                	addi	a5,a5,1
     8e0:	fff7c703          	lbu	a4,-1(a5)
     8e4:	fb7d                	bnez	a4,8da <strlen+0x14>
    ;
  return n;
}
     8e6:	6422                	ld	s0,8(sp)
     8e8:	0141                	addi	sp,sp,16
     8ea:	8082                	ret
  for(n = 0; s[n]; n++)
     8ec:	4501                	li	a0,0
     8ee:	bfe5                	j	8e6 <strlen+0x20>

00000000000008f0 <memset>:

void*
memset(void *dst, int c, uint n)
{
     8f0:	1141                	addi	sp,sp,-16
     8f2:	e422                	sd	s0,8(sp)
     8f4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     8f6:	ca19                	beqz	a2,90c <memset+0x1c>
     8f8:	87aa                	mv	a5,a0
     8fa:	1602                	slli	a2,a2,0x20
     8fc:	9201                	srli	a2,a2,0x20
     8fe:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     902:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     906:	0785                	addi	a5,a5,1
     908:	fee79de3          	bne	a5,a4,902 <memset+0x12>
  }
  return dst;
}
     90c:	6422                	ld	s0,8(sp)
     90e:	0141                	addi	sp,sp,16
     910:	8082                	ret

0000000000000912 <strchr>:

char*
strchr(const char *s, char c)
{
     912:	1141                	addi	sp,sp,-16
     914:	e422                	sd	s0,8(sp)
     916:	0800                	addi	s0,sp,16
  for(; *s; s++)
     918:	00054783          	lbu	a5,0(a0)
     91c:	cb99                	beqz	a5,932 <strchr+0x20>
    if(*s == c)
     91e:	00f58763          	beq	a1,a5,92c <strchr+0x1a>
  for(; *s; s++)
     922:	0505                	addi	a0,a0,1
     924:	00054783          	lbu	a5,0(a0)
     928:	fbfd                	bnez	a5,91e <strchr+0xc>
      return (char*)s;
  return 0;
     92a:	4501                	li	a0,0
}
     92c:	6422                	ld	s0,8(sp)
     92e:	0141                	addi	sp,sp,16
     930:	8082                	ret
  return 0;
     932:	4501                	li	a0,0
     934:	bfe5                	j	92c <strchr+0x1a>

0000000000000936 <gets>:

char*
gets(char *buf, int max)
{
     936:	711d                	addi	sp,sp,-96
     938:	ec86                	sd	ra,88(sp)
     93a:	e8a2                	sd	s0,80(sp)
     93c:	e4a6                	sd	s1,72(sp)
     93e:	e0ca                	sd	s2,64(sp)
     940:	fc4e                	sd	s3,56(sp)
     942:	f852                	sd	s4,48(sp)
     944:	f456                	sd	s5,40(sp)
     946:	f05a                	sd	s6,32(sp)
     948:	ec5e                	sd	s7,24(sp)
     94a:	1080                	addi	s0,sp,96
     94c:	8baa                	mv	s7,a0
     94e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     950:	892a                	mv	s2,a0
     952:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     954:	4aa9                	li	s5,10
     956:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     958:	89a6                	mv	s3,s1
     95a:	2485                	addiw	s1,s1,1
     95c:	0344d863          	bge	s1,s4,98c <gets+0x56>
    cc = read(0, &c, 1);
     960:	4605                	li	a2,1
     962:	faf40593          	addi	a1,s0,-81
     966:	4501                	li	a0,0
     968:	00000097          	auipc	ra,0x0
     96c:	19c080e7          	jalr	412(ra) # b04 <read>
    if(cc < 1)
     970:	00a05e63          	blez	a0,98c <gets+0x56>
    buf[i++] = c;
     974:	faf44783          	lbu	a5,-81(s0)
     978:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     97c:	01578763          	beq	a5,s5,98a <gets+0x54>
     980:	0905                	addi	s2,s2,1
     982:	fd679be3          	bne	a5,s6,958 <gets+0x22>
  for(i=0; i+1 < max; ){
     986:	89a6                	mv	s3,s1
     988:	a011                	j	98c <gets+0x56>
     98a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     98c:	99de                	add	s3,s3,s7
     98e:	00098023          	sb	zero,0(s3)
  return buf;
}
     992:	855e                	mv	a0,s7
     994:	60e6                	ld	ra,88(sp)
     996:	6446                	ld	s0,80(sp)
     998:	64a6                	ld	s1,72(sp)
     99a:	6906                	ld	s2,64(sp)
     99c:	79e2                	ld	s3,56(sp)
     99e:	7a42                	ld	s4,48(sp)
     9a0:	7aa2                	ld	s5,40(sp)
     9a2:	7b02                	ld	s6,32(sp)
     9a4:	6be2                	ld	s7,24(sp)
     9a6:	6125                	addi	sp,sp,96
     9a8:	8082                	ret

00000000000009aa <stat>:

int
stat(const char *n, struct stat *st)
{
     9aa:	1101                	addi	sp,sp,-32
     9ac:	ec06                	sd	ra,24(sp)
     9ae:	e822                	sd	s0,16(sp)
     9b0:	e426                	sd	s1,8(sp)
     9b2:	e04a                	sd	s2,0(sp)
     9b4:	1000                	addi	s0,sp,32
     9b6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     9b8:	4581                	li	a1,0
     9ba:	00000097          	auipc	ra,0x0
     9be:	172080e7          	jalr	370(ra) # b2c <open>
  if(fd < 0)
     9c2:	02054563          	bltz	a0,9ec <stat+0x42>
     9c6:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     9c8:	85ca                	mv	a1,s2
     9ca:	00000097          	auipc	ra,0x0
     9ce:	17a080e7          	jalr	378(ra) # b44 <fstat>
     9d2:	892a                	mv	s2,a0
  close(fd);
     9d4:	8526                	mv	a0,s1
     9d6:	00000097          	auipc	ra,0x0
     9da:	13e080e7          	jalr	318(ra) # b14 <close>
  return r;
}
     9de:	854a                	mv	a0,s2
     9e0:	60e2                	ld	ra,24(sp)
     9e2:	6442                	ld	s0,16(sp)
     9e4:	64a2                	ld	s1,8(sp)
     9e6:	6902                	ld	s2,0(sp)
     9e8:	6105                	addi	sp,sp,32
     9ea:	8082                	ret
    return -1;
     9ec:	597d                	li	s2,-1
     9ee:	bfc5                	j	9de <stat+0x34>

00000000000009f0 <atoi>:

int
atoi(const char *s)
{
     9f0:	1141                	addi	sp,sp,-16
     9f2:	e422                	sd	s0,8(sp)
     9f4:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     9f6:	00054603          	lbu	a2,0(a0)
     9fa:	fd06079b          	addiw	a5,a2,-48
     9fe:	0ff7f793          	andi	a5,a5,255
     a02:	4725                	li	a4,9
     a04:	02f76963          	bltu	a4,a5,a36 <atoi+0x46>
     a08:	86aa                	mv	a3,a0
  n = 0;
     a0a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     a0c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     a0e:	0685                	addi	a3,a3,1
     a10:	0025179b          	slliw	a5,a0,0x2
     a14:	9fa9                	addw	a5,a5,a0
     a16:	0017979b          	slliw	a5,a5,0x1
     a1a:	9fb1                	addw	a5,a5,a2
     a1c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     a20:	0006c603          	lbu	a2,0(a3)
     a24:	fd06071b          	addiw	a4,a2,-48
     a28:	0ff77713          	andi	a4,a4,255
     a2c:	fee5f1e3          	bgeu	a1,a4,a0e <atoi+0x1e>
  return n;
}
     a30:	6422                	ld	s0,8(sp)
     a32:	0141                	addi	sp,sp,16
     a34:	8082                	ret
  n = 0;
     a36:	4501                	li	a0,0
     a38:	bfe5                	j	a30 <atoi+0x40>

0000000000000a3a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     a3a:	1141                	addi	sp,sp,-16
     a3c:	e422                	sd	s0,8(sp)
     a3e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     a40:	02b57463          	bgeu	a0,a1,a68 <memmove+0x2e>
    while(n-- > 0)
     a44:	00c05f63          	blez	a2,a62 <memmove+0x28>
     a48:	1602                	slli	a2,a2,0x20
     a4a:	9201                	srli	a2,a2,0x20
     a4c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     a50:	872a                	mv	a4,a0
      *dst++ = *src++;
     a52:	0585                	addi	a1,a1,1
     a54:	0705                	addi	a4,a4,1
     a56:	fff5c683          	lbu	a3,-1(a1)
     a5a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     a5e:	fee79ae3          	bne	a5,a4,a52 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     a62:	6422                	ld	s0,8(sp)
     a64:	0141                	addi	sp,sp,16
     a66:	8082                	ret
    dst += n;
     a68:	00c50733          	add	a4,a0,a2
    src += n;
     a6c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     a6e:	fec05ae3          	blez	a2,a62 <memmove+0x28>
     a72:	fff6079b          	addiw	a5,a2,-1
     a76:	1782                	slli	a5,a5,0x20
     a78:	9381                	srli	a5,a5,0x20
     a7a:	fff7c793          	not	a5,a5
     a7e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     a80:	15fd                	addi	a1,a1,-1
     a82:	177d                	addi	a4,a4,-1
     a84:	0005c683          	lbu	a3,0(a1)
     a88:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     a8c:	fee79ae3          	bne	a5,a4,a80 <memmove+0x46>
     a90:	bfc9                	j	a62 <memmove+0x28>

0000000000000a92 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     a92:	1141                	addi	sp,sp,-16
     a94:	e422                	sd	s0,8(sp)
     a96:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     a98:	ca05                	beqz	a2,ac8 <memcmp+0x36>
     a9a:	fff6069b          	addiw	a3,a2,-1
     a9e:	1682                	slli	a3,a3,0x20
     aa0:	9281                	srli	a3,a3,0x20
     aa2:	0685                	addi	a3,a3,1
     aa4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     aa6:	00054783          	lbu	a5,0(a0)
     aaa:	0005c703          	lbu	a4,0(a1)
     aae:	00e79863          	bne	a5,a4,abe <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     ab2:	0505                	addi	a0,a0,1
    p2++;
     ab4:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     ab6:	fed518e3          	bne	a0,a3,aa6 <memcmp+0x14>
  }
  return 0;
     aba:	4501                	li	a0,0
     abc:	a019                	j	ac2 <memcmp+0x30>
      return *p1 - *p2;
     abe:	40e7853b          	subw	a0,a5,a4
}
     ac2:	6422                	ld	s0,8(sp)
     ac4:	0141                	addi	sp,sp,16
     ac6:	8082                	ret
  return 0;
     ac8:	4501                	li	a0,0
     aca:	bfe5                	j	ac2 <memcmp+0x30>

0000000000000acc <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     acc:	1141                	addi	sp,sp,-16
     ace:	e406                	sd	ra,8(sp)
     ad0:	e022                	sd	s0,0(sp)
     ad2:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     ad4:	00000097          	auipc	ra,0x0
     ad8:	f66080e7          	jalr	-154(ra) # a3a <memmove>
}
     adc:	60a2                	ld	ra,8(sp)
     ade:	6402                	ld	s0,0(sp)
     ae0:	0141                	addi	sp,sp,16
     ae2:	8082                	ret

0000000000000ae4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     ae4:	4885                	li	a7,1
 ecall
     ae6:	00000073          	ecall
 ret
     aea:	8082                	ret

0000000000000aec <exit>:
.global exit
exit:
 li a7, SYS_exit
     aec:	4889                	li	a7,2
 ecall
     aee:	00000073          	ecall
 ret
     af2:	8082                	ret

0000000000000af4 <wait>:
.global wait
wait:
 li a7, SYS_wait
     af4:	488d                	li	a7,3
 ecall
     af6:	00000073          	ecall
 ret
     afa:	8082                	ret

0000000000000afc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     afc:	4891                	li	a7,4
 ecall
     afe:	00000073          	ecall
 ret
     b02:	8082                	ret

0000000000000b04 <read>:
.global read
read:
 li a7, SYS_read
     b04:	4895                	li	a7,5
 ecall
     b06:	00000073          	ecall
 ret
     b0a:	8082                	ret

0000000000000b0c <write>:
.global write
write:
 li a7, SYS_write
     b0c:	48c1                	li	a7,16
 ecall
     b0e:	00000073          	ecall
 ret
     b12:	8082                	ret

0000000000000b14 <close>:
.global close
close:
 li a7, SYS_close
     b14:	48d5                	li	a7,21
 ecall
     b16:	00000073          	ecall
 ret
     b1a:	8082                	ret

0000000000000b1c <kill>:
.global kill
kill:
 li a7, SYS_kill
     b1c:	4899                	li	a7,6
 ecall
     b1e:	00000073          	ecall
 ret
     b22:	8082                	ret

0000000000000b24 <exec>:
.global exec
exec:
 li a7, SYS_exec
     b24:	489d                	li	a7,7
 ecall
     b26:	00000073          	ecall
 ret
     b2a:	8082                	ret

0000000000000b2c <open>:
.global open
open:
 li a7, SYS_open
     b2c:	48bd                	li	a7,15
 ecall
     b2e:	00000073          	ecall
 ret
     b32:	8082                	ret

0000000000000b34 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     b34:	48c5                	li	a7,17
 ecall
     b36:	00000073          	ecall
 ret
     b3a:	8082                	ret

0000000000000b3c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     b3c:	48c9                	li	a7,18
 ecall
     b3e:	00000073          	ecall
 ret
     b42:	8082                	ret

0000000000000b44 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     b44:	48a1                	li	a7,8
 ecall
     b46:	00000073          	ecall
 ret
     b4a:	8082                	ret

0000000000000b4c <link>:
.global link
link:
 li a7, SYS_link
     b4c:	48cd                	li	a7,19
 ecall
     b4e:	00000073          	ecall
 ret
     b52:	8082                	ret

0000000000000b54 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     b54:	48d1                	li	a7,20
 ecall
     b56:	00000073          	ecall
 ret
     b5a:	8082                	ret

0000000000000b5c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     b5c:	48a5                	li	a7,9
 ecall
     b5e:	00000073          	ecall
 ret
     b62:	8082                	ret

0000000000000b64 <dup>:
.global dup
dup:
 li a7, SYS_dup
     b64:	48a9                	li	a7,10
 ecall
     b66:	00000073          	ecall
 ret
     b6a:	8082                	ret

0000000000000b6c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     b6c:	48ad                	li	a7,11
 ecall
     b6e:	00000073          	ecall
 ret
     b72:	8082                	ret

0000000000000b74 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     b74:	48b1                	li	a7,12
 ecall
     b76:	00000073          	ecall
 ret
     b7a:	8082                	ret

0000000000000b7c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     b7c:	48b5                	li	a7,13
 ecall
     b7e:	00000073          	ecall
 ret
     b82:	8082                	ret

0000000000000b84 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     b84:	48b9                	li	a7,14
 ecall
     b86:	00000073          	ecall
 ret
     b8a:	8082                	ret

0000000000000b8c <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
     b8c:	48d9                	li	a7,22
 ecall
     b8e:	00000073          	ecall
 ret
     b92:	8082                	ret

0000000000000b94 <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
     b94:	48dd                	li	a7,23
 ecall
     b96:	00000073          	ecall
 ret
     b9a:	8082                	ret

0000000000000b9c <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
     b9c:	48e1                	li	a7,24
 ecall
     b9e:	00000073          	ecall
 ret
     ba2:	8082                	ret

0000000000000ba4 <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
     ba4:	48e5                	li	a7,25
 ecall
     ba6:	00000073          	ecall
 ret
     baa:	8082                	ret

0000000000000bac <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
     bac:	48e9                	li	a7,26
 ecall
     bae:	00000073          	ecall
 ret
     bb2:	8082                	ret

0000000000000bb4 <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
     bb4:	48ed                	li	a7,27
 ecall
     bb6:	00000073          	ecall
 ret
     bba:	8082                	ret

0000000000000bbc <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
     bbc:	48f1                	li	a7,28
 ecall
     bbe:	00000073          	ecall
 ret
     bc2:	8082                	ret

0000000000000bc4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     bc4:	1101                	addi	sp,sp,-32
     bc6:	ec06                	sd	ra,24(sp)
     bc8:	e822                	sd	s0,16(sp)
     bca:	1000                	addi	s0,sp,32
     bcc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     bd0:	4605                	li	a2,1
     bd2:	fef40593          	addi	a1,s0,-17
     bd6:	00000097          	auipc	ra,0x0
     bda:	f36080e7          	jalr	-202(ra) # b0c <write>
}
     bde:	60e2                	ld	ra,24(sp)
     be0:	6442                	ld	s0,16(sp)
     be2:	6105                	addi	sp,sp,32
     be4:	8082                	ret

0000000000000be6 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     be6:	7139                	addi	sp,sp,-64
     be8:	fc06                	sd	ra,56(sp)
     bea:	f822                	sd	s0,48(sp)
     bec:	f426                	sd	s1,40(sp)
     bee:	f04a                	sd	s2,32(sp)
     bf0:	ec4e                	sd	s3,24(sp)
     bf2:	0080                	addi	s0,sp,64
     bf4:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     bf6:	c299                	beqz	a3,bfc <printint+0x16>
     bf8:	0805c863          	bltz	a1,c88 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     bfc:	2581                	sext.w	a1,a1
  neg = 0;
     bfe:	4881                	li	a7,0
     c00:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     c04:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     c06:	2601                	sext.w	a2,a2
     c08:	00001517          	auipc	a0,0x1
     c0c:	91850513          	addi	a0,a0,-1768 # 1520 <digits>
     c10:	883a                	mv	a6,a4
     c12:	2705                	addiw	a4,a4,1
     c14:	02c5f7bb          	remuw	a5,a1,a2
     c18:	1782                	slli	a5,a5,0x20
     c1a:	9381                	srli	a5,a5,0x20
     c1c:	97aa                	add	a5,a5,a0
     c1e:	0007c783          	lbu	a5,0(a5)
     c22:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     c26:	0005879b          	sext.w	a5,a1
     c2a:	02c5d5bb          	divuw	a1,a1,a2
     c2e:	0685                	addi	a3,a3,1
     c30:	fec7f0e3          	bgeu	a5,a2,c10 <printint+0x2a>
  if(neg)
     c34:	00088b63          	beqz	a7,c4a <printint+0x64>
    buf[i++] = '-';
     c38:	fd040793          	addi	a5,s0,-48
     c3c:	973e                	add	a4,a4,a5
     c3e:	02d00793          	li	a5,45
     c42:	fef70823          	sb	a5,-16(a4)
     c46:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     c4a:	02e05863          	blez	a4,c7a <printint+0x94>
     c4e:	fc040793          	addi	a5,s0,-64
     c52:	00e78933          	add	s2,a5,a4
     c56:	fff78993          	addi	s3,a5,-1
     c5a:	99ba                	add	s3,s3,a4
     c5c:	377d                	addiw	a4,a4,-1
     c5e:	1702                	slli	a4,a4,0x20
     c60:	9301                	srli	a4,a4,0x20
     c62:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     c66:	fff94583          	lbu	a1,-1(s2)
     c6a:	8526                	mv	a0,s1
     c6c:	00000097          	auipc	ra,0x0
     c70:	f58080e7          	jalr	-168(ra) # bc4 <putc>
  while(--i >= 0)
     c74:	197d                	addi	s2,s2,-1
     c76:	ff3918e3          	bne	s2,s3,c66 <printint+0x80>
}
     c7a:	70e2                	ld	ra,56(sp)
     c7c:	7442                	ld	s0,48(sp)
     c7e:	74a2                	ld	s1,40(sp)
     c80:	7902                	ld	s2,32(sp)
     c82:	69e2                	ld	s3,24(sp)
     c84:	6121                	addi	sp,sp,64
     c86:	8082                	ret
    x = -xx;
     c88:	40b005bb          	negw	a1,a1
    neg = 1;
     c8c:	4885                	li	a7,1
    x = -xx;
     c8e:	bf8d                	j	c00 <printint+0x1a>

0000000000000c90 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     c90:	7119                	addi	sp,sp,-128
     c92:	fc86                	sd	ra,120(sp)
     c94:	f8a2                	sd	s0,112(sp)
     c96:	f4a6                	sd	s1,104(sp)
     c98:	f0ca                	sd	s2,96(sp)
     c9a:	ecce                	sd	s3,88(sp)
     c9c:	e8d2                	sd	s4,80(sp)
     c9e:	e4d6                	sd	s5,72(sp)
     ca0:	e0da                	sd	s6,64(sp)
     ca2:	fc5e                	sd	s7,56(sp)
     ca4:	f862                	sd	s8,48(sp)
     ca6:	f466                	sd	s9,40(sp)
     ca8:	f06a                	sd	s10,32(sp)
     caa:	ec6e                	sd	s11,24(sp)
     cac:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     cae:	0005c903          	lbu	s2,0(a1)
     cb2:	18090f63          	beqz	s2,e50 <vprintf+0x1c0>
     cb6:	8aaa                	mv	s5,a0
     cb8:	8b32                	mv	s6,a2
     cba:	00158493          	addi	s1,a1,1
  state = 0;
     cbe:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     cc0:	02500a13          	li	s4,37
      if(c == 'd'){
     cc4:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
     cc8:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
     ccc:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
     cd0:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     cd4:	00001b97          	auipc	s7,0x1
     cd8:	84cb8b93          	addi	s7,s7,-1972 # 1520 <digits>
     cdc:	a839                	j	cfa <vprintf+0x6a>
        putc(fd, c);
     cde:	85ca                	mv	a1,s2
     ce0:	8556                	mv	a0,s5
     ce2:	00000097          	auipc	ra,0x0
     ce6:	ee2080e7          	jalr	-286(ra) # bc4 <putc>
     cea:	a019                	j	cf0 <vprintf+0x60>
    } else if(state == '%'){
     cec:	01498f63          	beq	s3,s4,d0a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
     cf0:	0485                	addi	s1,s1,1
     cf2:	fff4c903          	lbu	s2,-1(s1)
     cf6:	14090d63          	beqz	s2,e50 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
     cfa:	0009079b          	sext.w	a5,s2
    if(state == 0){
     cfe:	fe0997e3          	bnez	s3,cec <vprintf+0x5c>
      if(c == '%'){
     d02:	fd479ee3          	bne	a5,s4,cde <vprintf+0x4e>
        state = '%';
     d06:	89be                	mv	s3,a5
     d08:	b7e5                	j	cf0 <vprintf+0x60>
      if(c == 'd'){
     d0a:	05878063          	beq	a5,s8,d4a <vprintf+0xba>
      } else if(c == 'l') {
     d0e:	05978c63          	beq	a5,s9,d66 <vprintf+0xd6>
      } else if(c == 'x') {
     d12:	07a78863          	beq	a5,s10,d82 <vprintf+0xf2>
      } else if(c == 'p') {
     d16:	09b78463          	beq	a5,s11,d9e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
     d1a:	07300713          	li	a4,115
     d1e:	0ce78663          	beq	a5,a4,dea <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
     d22:	06300713          	li	a4,99
     d26:	0ee78e63          	beq	a5,a4,e22 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
     d2a:	11478863          	beq	a5,s4,e3a <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
     d2e:	85d2                	mv	a1,s4
     d30:	8556                	mv	a0,s5
     d32:	00000097          	auipc	ra,0x0
     d36:	e92080e7          	jalr	-366(ra) # bc4 <putc>
        putc(fd, c);
     d3a:	85ca                	mv	a1,s2
     d3c:	8556                	mv	a0,s5
     d3e:	00000097          	auipc	ra,0x0
     d42:	e86080e7          	jalr	-378(ra) # bc4 <putc>
      }
      state = 0;
     d46:	4981                	li	s3,0
     d48:	b765                	j	cf0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
     d4a:	008b0913          	addi	s2,s6,8
     d4e:	4685                	li	a3,1
     d50:	4629                	li	a2,10
     d52:	000b2583          	lw	a1,0(s6)
     d56:	8556                	mv	a0,s5
     d58:	00000097          	auipc	ra,0x0
     d5c:	e8e080e7          	jalr	-370(ra) # be6 <printint>
     d60:	8b4a                	mv	s6,s2
      state = 0;
     d62:	4981                	li	s3,0
     d64:	b771                	j	cf0 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
     d66:	008b0913          	addi	s2,s6,8
     d6a:	4681                	li	a3,0
     d6c:	4629                	li	a2,10
     d6e:	000b2583          	lw	a1,0(s6)
     d72:	8556                	mv	a0,s5
     d74:	00000097          	auipc	ra,0x0
     d78:	e72080e7          	jalr	-398(ra) # be6 <printint>
     d7c:	8b4a                	mv	s6,s2
      state = 0;
     d7e:	4981                	li	s3,0
     d80:	bf85                	j	cf0 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
     d82:	008b0913          	addi	s2,s6,8
     d86:	4681                	li	a3,0
     d88:	4641                	li	a2,16
     d8a:	000b2583          	lw	a1,0(s6)
     d8e:	8556                	mv	a0,s5
     d90:	00000097          	auipc	ra,0x0
     d94:	e56080e7          	jalr	-426(ra) # be6 <printint>
     d98:	8b4a                	mv	s6,s2
      state = 0;
     d9a:	4981                	li	s3,0
     d9c:	bf91                	j	cf0 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
     d9e:	008b0793          	addi	a5,s6,8
     da2:	f8f43423          	sd	a5,-120(s0)
     da6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
     daa:	03000593          	li	a1,48
     dae:	8556                	mv	a0,s5
     db0:	00000097          	auipc	ra,0x0
     db4:	e14080e7          	jalr	-492(ra) # bc4 <putc>
  putc(fd, 'x');
     db8:	85ea                	mv	a1,s10
     dba:	8556                	mv	a0,s5
     dbc:	00000097          	auipc	ra,0x0
     dc0:	e08080e7          	jalr	-504(ra) # bc4 <putc>
     dc4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     dc6:	03c9d793          	srli	a5,s3,0x3c
     dca:	97de                	add	a5,a5,s7
     dcc:	0007c583          	lbu	a1,0(a5)
     dd0:	8556                	mv	a0,s5
     dd2:	00000097          	auipc	ra,0x0
     dd6:	df2080e7          	jalr	-526(ra) # bc4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     dda:	0992                	slli	s3,s3,0x4
     ddc:	397d                	addiw	s2,s2,-1
     dde:	fe0914e3          	bnez	s2,dc6 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
     de2:	f8843b03          	ld	s6,-120(s0)
      state = 0;
     de6:	4981                	li	s3,0
     de8:	b721                	j	cf0 <vprintf+0x60>
        s = va_arg(ap, char*);
     dea:	008b0993          	addi	s3,s6,8
     dee:	000b3903          	ld	s2,0(s6)
        if(s == 0)
     df2:	02090163          	beqz	s2,e14 <vprintf+0x184>
        while(*s != 0){
     df6:	00094583          	lbu	a1,0(s2)
     dfa:	c9a1                	beqz	a1,e4a <vprintf+0x1ba>
          putc(fd, *s);
     dfc:	8556                	mv	a0,s5
     dfe:	00000097          	auipc	ra,0x0
     e02:	dc6080e7          	jalr	-570(ra) # bc4 <putc>
          s++;
     e06:	0905                	addi	s2,s2,1
        while(*s != 0){
     e08:	00094583          	lbu	a1,0(s2)
     e0c:	f9e5                	bnez	a1,dfc <vprintf+0x16c>
        s = va_arg(ap, char*);
     e0e:	8b4e                	mv	s6,s3
      state = 0;
     e10:	4981                	li	s3,0
     e12:	bdf9                	j	cf0 <vprintf+0x60>
          s = "(null)";
     e14:	00000917          	auipc	s2,0x0
     e18:	70490913          	addi	s2,s2,1796 # 1518 <malloc+0x5be>
        while(*s != 0){
     e1c:	02800593          	li	a1,40
     e20:	bff1                	j	dfc <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
     e22:	008b0913          	addi	s2,s6,8
     e26:	000b4583          	lbu	a1,0(s6)
     e2a:	8556                	mv	a0,s5
     e2c:	00000097          	auipc	ra,0x0
     e30:	d98080e7          	jalr	-616(ra) # bc4 <putc>
     e34:	8b4a                	mv	s6,s2
      state = 0;
     e36:	4981                	li	s3,0
     e38:	bd65                	j	cf0 <vprintf+0x60>
        putc(fd, c);
     e3a:	85d2                	mv	a1,s4
     e3c:	8556                	mv	a0,s5
     e3e:	00000097          	auipc	ra,0x0
     e42:	d86080e7          	jalr	-634(ra) # bc4 <putc>
      state = 0;
     e46:	4981                	li	s3,0
     e48:	b565                	j	cf0 <vprintf+0x60>
        s = va_arg(ap, char*);
     e4a:	8b4e                	mv	s6,s3
      state = 0;
     e4c:	4981                	li	s3,0
     e4e:	b54d                	j	cf0 <vprintf+0x60>
    }
  }
}
     e50:	70e6                	ld	ra,120(sp)
     e52:	7446                	ld	s0,112(sp)
     e54:	74a6                	ld	s1,104(sp)
     e56:	7906                	ld	s2,96(sp)
     e58:	69e6                	ld	s3,88(sp)
     e5a:	6a46                	ld	s4,80(sp)
     e5c:	6aa6                	ld	s5,72(sp)
     e5e:	6b06                	ld	s6,64(sp)
     e60:	7be2                	ld	s7,56(sp)
     e62:	7c42                	ld	s8,48(sp)
     e64:	7ca2                	ld	s9,40(sp)
     e66:	7d02                	ld	s10,32(sp)
     e68:	6de2                	ld	s11,24(sp)
     e6a:	6109                	addi	sp,sp,128
     e6c:	8082                	ret

0000000000000e6e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     e6e:	715d                	addi	sp,sp,-80
     e70:	ec06                	sd	ra,24(sp)
     e72:	e822                	sd	s0,16(sp)
     e74:	1000                	addi	s0,sp,32
     e76:	e010                	sd	a2,0(s0)
     e78:	e414                	sd	a3,8(s0)
     e7a:	e818                	sd	a4,16(s0)
     e7c:	ec1c                	sd	a5,24(s0)
     e7e:	03043023          	sd	a6,32(s0)
     e82:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     e86:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     e8a:	8622                	mv	a2,s0
     e8c:	00000097          	auipc	ra,0x0
     e90:	e04080e7          	jalr	-508(ra) # c90 <vprintf>
}
     e94:	60e2                	ld	ra,24(sp)
     e96:	6442                	ld	s0,16(sp)
     e98:	6161                	addi	sp,sp,80
     e9a:	8082                	ret

0000000000000e9c <printf>:

void
printf(const char *fmt, ...)
{
     e9c:	711d                	addi	sp,sp,-96
     e9e:	ec06                	sd	ra,24(sp)
     ea0:	e822                	sd	s0,16(sp)
     ea2:	1000                	addi	s0,sp,32
     ea4:	e40c                	sd	a1,8(s0)
     ea6:	e810                	sd	a2,16(s0)
     ea8:	ec14                	sd	a3,24(s0)
     eaa:	f018                	sd	a4,32(s0)
     eac:	f41c                	sd	a5,40(s0)
     eae:	03043823          	sd	a6,48(s0)
     eb2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     eb6:	00840613          	addi	a2,s0,8
     eba:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
     ebe:	85aa                	mv	a1,a0
     ec0:	4505                	li	a0,1
     ec2:	00000097          	auipc	ra,0x0
     ec6:	dce080e7          	jalr	-562(ra) # c90 <vprintf>
}
     eca:	60e2                	ld	ra,24(sp)
     ecc:	6442                	ld	s0,16(sp)
     ece:	6125                	addi	sp,sp,96
     ed0:	8082                	ret

0000000000000ed2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     ed2:	1141                	addi	sp,sp,-16
     ed4:	e422                	sd	s0,8(sp)
     ed6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
     ed8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     edc:	00000797          	auipc	a5,0x0
     ee0:	65c7b783          	ld	a5,1628(a5) # 1538 <freep>
     ee4:	a805                	j	f14 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
     ee6:	4618                	lw	a4,8(a2)
     ee8:	9db9                	addw	a1,a1,a4
     eea:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
     eee:	6398                	ld	a4,0(a5)
     ef0:	6318                	ld	a4,0(a4)
     ef2:	fee53823          	sd	a4,-16(a0)
     ef6:	a091                	j	f3a <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
     ef8:	ff852703          	lw	a4,-8(a0)
     efc:	9e39                	addw	a2,a2,a4
     efe:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
     f00:	ff053703          	ld	a4,-16(a0)
     f04:	e398                	sd	a4,0(a5)
     f06:	a099                	j	f4c <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     f08:	6398                	ld	a4,0(a5)
     f0a:	00e7e463          	bltu	a5,a4,f12 <free+0x40>
     f0e:	00e6ea63          	bltu	a3,a4,f22 <free+0x50>
{
     f12:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     f14:	fed7fae3          	bgeu	a5,a3,f08 <free+0x36>
     f18:	6398                	ld	a4,0(a5)
     f1a:	00e6e463          	bltu	a3,a4,f22 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     f1e:	fee7eae3          	bltu	a5,a4,f12 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
     f22:	ff852583          	lw	a1,-8(a0)
     f26:	6390                	ld	a2,0(a5)
     f28:	02059813          	slli	a6,a1,0x20
     f2c:	01c85713          	srli	a4,a6,0x1c
     f30:	9736                	add	a4,a4,a3
     f32:	fae60ae3          	beq	a2,a4,ee6 <free+0x14>
    bp->s.ptr = p->s.ptr;
     f36:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
     f3a:	4790                	lw	a2,8(a5)
     f3c:	02061593          	slli	a1,a2,0x20
     f40:	01c5d713          	srli	a4,a1,0x1c
     f44:	973e                	add	a4,a4,a5
     f46:	fae689e3          	beq	a3,a4,ef8 <free+0x26>
  } else
    p->s.ptr = bp;
     f4a:	e394                	sd	a3,0(a5)
  freep = p;
     f4c:	00000717          	auipc	a4,0x0
     f50:	5ef73623          	sd	a5,1516(a4) # 1538 <freep>
}
     f54:	6422                	ld	s0,8(sp)
     f56:	0141                	addi	sp,sp,16
     f58:	8082                	ret

0000000000000f5a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
     f5a:	7139                	addi	sp,sp,-64
     f5c:	fc06                	sd	ra,56(sp)
     f5e:	f822                	sd	s0,48(sp)
     f60:	f426                	sd	s1,40(sp)
     f62:	f04a                	sd	s2,32(sp)
     f64:	ec4e                	sd	s3,24(sp)
     f66:	e852                	sd	s4,16(sp)
     f68:	e456                	sd	s5,8(sp)
     f6a:	e05a                	sd	s6,0(sp)
     f6c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
     f6e:	02051493          	slli	s1,a0,0x20
     f72:	9081                	srli	s1,s1,0x20
     f74:	04bd                	addi	s1,s1,15
     f76:	8091                	srli	s1,s1,0x4
     f78:	0014899b          	addiw	s3,s1,1
     f7c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
     f7e:	00000517          	auipc	a0,0x0
     f82:	5ba53503          	ld	a0,1466(a0) # 1538 <freep>
     f86:	c515                	beqz	a0,fb2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
     f88:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
     f8a:	4798                	lw	a4,8(a5)
     f8c:	02977f63          	bgeu	a4,s1,fca <malloc+0x70>
     f90:	8a4e                	mv	s4,s3
     f92:	0009871b          	sext.w	a4,s3
     f96:	6685                	lui	a3,0x1
     f98:	00d77363          	bgeu	a4,a3,f9e <malloc+0x44>
     f9c:	6a05                	lui	s4,0x1
     f9e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
     fa2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
     fa6:	00000917          	auipc	s2,0x0
     faa:	59290913          	addi	s2,s2,1426 # 1538 <freep>
  if(p == (char*)-1)
     fae:	5afd                	li	s5,-1
     fb0:	a895                	j	1024 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
     fb2:	00000797          	auipc	a5,0x0
     fb6:	58e78793          	addi	a5,a5,1422 # 1540 <base>
     fba:	00000717          	auipc	a4,0x0
     fbe:	56f73f23          	sd	a5,1406(a4) # 1538 <freep>
     fc2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
     fc4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
     fc8:	b7e1                	j	f90 <malloc+0x36>
      if(p->s.size == nunits)
     fca:	02e48c63          	beq	s1,a4,1002 <malloc+0xa8>
        p->s.size -= nunits;
     fce:	4137073b          	subw	a4,a4,s3
     fd2:	c798                	sw	a4,8(a5)
        p += p->s.size;
     fd4:	02071693          	slli	a3,a4,0x20
     fd8:	01c6d713          	srli	a4,a3,0x1c
     fdc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
     fde:	0137a423          	sw	s3,8(a5)
      freep = prevp;
     fe2:	00000717          	auipc	a4,0x0
     fe6:	54a73b23          	sd	a0,1366(a4) # 1538 <freep>
      return (void*)(p + 1);
     fea:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
     fee:	70e2                	ld	ra,56(sp)
     ff0:	7442                	ld	s0,48(sp)
     ff2:	74a2                	ld	s1,40(sp)
     ff4:	7902                	ld	s2,32(sp)
     ff6:	69e2                	ld	s3,24(sp)
     ff8:	6a42                	ld	s4,16(sp)
     ffa:	6aa2                	ld	s5,8(sp)
     ffc:	6b02                	ld	s6,0(sp)
     ffe:	6121                	addi	sp,sp,64
    1000:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1002:	6398                	ld	a4,0(a5)
    1004:	e118                	sd	a4,0(a0)
    1006:	bff1                	j	fe2 <malloc+0x88>
  hp->s.size = nu;
    1008:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    100c:	0541                	addi	a0,a0,16
    100e:	00000097          	auipc	ra,0x0
    1012:	ec4080e7          	jalr	-316(ra) # ed2 <free>
  return freep;
    1016:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    101a:	d971                	beqz	a0,fee <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    101c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    101e:	4798                	lw	a4,8(a5)
    1020:	fa9775e3          	bgeu	a4,s1,fca <malloc+0x70>
    if(p == freep)
    1024:	00093703          	ld	a4,0(s2)
    1028:	853e                	mv	a0,a5
    102a:	fef719e3          	bne	a4,a5,101c <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    102e:	8552                	mv	a0,s4
    1030:	00000097          	auipc	ra,0x0
    1034:	b44080e7          	jalr	-1212(ra) # b74 <sbrk>
  if(p == (char*)-1)
    1038:	fd5518e3          	bne	a0,s5,1008 <malloc+0xae>
        return 0;
    103c:	4501                	li	a0,0
    103e:	bf45                	j	fee <malloc+0x94>
