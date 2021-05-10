
user/_signaltest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <sig_handler_loop>:
    write(1, st, 5);
    return;
}

void
sig_handler_loop(int signum){
       0:	7179                	addi	sp,sp,-48
       2:	f406                	sd	ra,40(sp)
       4:	f022                	sd	s0,32(sp)
       6:	ec26                	sd	s1,24(sp)
       8:	1800                	addi	s0,sp,48
    char st[5] = "dap\n";
       a:	0a7067b7          	lui	a5,0xa706
       e:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa70438a>
      12:	fcf42c23          	sw	a5,-40(s0)
      16:	fc040e23          	sb	zero,-36(s0)
      1a:	1f400493          	li	s1,500
    for(int i=0;i<500;i++){
        write(1, st, 5);
      1e:	4615                	li	a2,5
      20:	fd840593          	addi	a1,s0,-40
      24:	4505                	li	a0,1
      26:	00001097          	auipc	ra,0x1
      2a:	a0a080e7          	jalr	-1526(ra) # a30 <write>
    for(int i=0;i<500;i++){
      2e:	34fd                	addiw	s1,s1,-1
      30:	f4fd                	bnez	s1,1e <sig_handler_loop+0x1e>
    }
    
    return;
}
      32:	70a2                	ld	ra,40(sp)
      34:	7402                	ld	s0,32(sp)
      36:	64e2                	ld	s1,24(sp)
      38:	6145                	addi	sp,sp,48
      3a:	8082                	ret

000000000000003c <sig_handler_loop2>:
void
sig_handler_loop2(int signum){
      3c:	7179                	addi	sp,sp,-48
      3e:	f406                	sd	ra,40(sp)
      40:	f022                	sd	s0,32(sp)
      42:	ec26                	sd	s1,24(sp)
      44:	1800                	addi	s0,sp,48
    char st[5] = "dap\n";
      46:	0a7067b7          	lui	a5,0xa706
      4a:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa70438a>
      4e:	fcf42c23          	sw	a5,-40(s0)
      52:	fc040e23          	sb	zero,-36(s0)
      56:	06400493          	li	s1,100
    for(int i=0;i<100;i++){
        sleep(1);
      5a:	4505                	li	a0,1
      5c:	00001097          	auipc	ra,0x1
      60:	a44080e7          	jalr	-1468(ra) # aa0 <sleep>
        write(1, st, 5);
      64:	4615                	li	a2,5
      66:	fd840593          	addi	a1,s0,-40
      6a:	4505                	li	a0,1
      6c:	00001097          	auipc	ra,0x1
      70:	9c4080e7          	jalr	-1596(ra) # a30 <write>
    for(int i=0;i<100;i++){
      74:	34fd                	addiw	s1,s1,-1
      76:	f0f5                	bnez	s1,5a <sig_handler_loop2+0x1e>
    }
    
    return;
}
      78:	70a2                	ld	ra,40(sp)
      7a:	7402                	ld	s0,32(sp)
      7c:	64e2                	ld	s1,24(sp)
      7e:	6145                	addi	sp,sp,48
      80:	8082                	ret

0000000000000082 <sig_handler2>:
void
sig_handler2(int signum){
      82:	1101                	addi	sp,sp,-32
      84:	ec06                	sd	ra,24(sp)
      86:	e822                	sd	s0,16(sp)
      88:	1000                	addi	s0,sp,32
    char st[5] = "dap\n";
      8a:	0a7067b7          	lui	a5,0xa706
      8e:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa70438a>
      92:	fef42423          	sw	a5,-24(s0)
      96:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
      9a:	4615                	li	a2,5
      9c:	fe840593          	addi	a1,s0,-24
      a0:	4505                	li	a0,1
      a2:	00001097          	auipc	ra,0x1
      a6:	98e080e7          	jalr	-1650(ra) # a30 <write>
    return;
}
      aa:	60e2                	ld	ra,24(sp)
      ac:	6442                	ld	s0,16(sp)
      ae:	6105                	addi	sp,sp,32
      b0:	8082                	ret

00000000000000b2 <test_thread>:
void test_thread(){
      b2:	1141                	addi	sp,sp,-16
      b4:	e406                	sd	ra,8(sp)
      b6:	e022                	sd	s0,0(sp)
      b8:	0800                	addi	s0,sp,16
    sleep(5);
      ba:	4515                	li	a0,5
      bc:	00001097          	auipc	ra,0x1
      c0:	9e4080e7          	jalr	-1564(ra) # aa0 <sleep>
    printf("Thread is now running tid=%d\n",kthread_id());
      c4:	00001097          	auipc	ra,0x1
      c8:	a0c080e7          	jalr	-1524(ra) # ad0 <kthread_id>
      cc:	85aa                	mv	a1,a0
      ce:	00001517          	auipc	a0,0x1
      d2:	02250513          	addi	a0,a0,34 # 10f0 <csem_free+0x42>
      d6:	00001097          	auipc	ra,0x1
      da:	d0c080e7          	jalr	-756(ra) # de2 <printf>
    kthread_exit(9);
      de:	4525                	li	a0,9
      e0:	00001097          	auipc	ra,0x1
      e4:	9f8080e7          	jalr	-1544(ra) # ad8 <kthread_exit>
}
      e8:	60a2                	ld	ra,8(sp)
      ea:	6402                	ld	s0,0(sp)
      ec:	0141                	addi	sp,sp,16
      ee:	8082                	ret

00000000000000f0 <test_thread_loop>:
void test_thread_loop(){
      f0:	7179                	addi	sp,sp,-48
      f2:	f406                	sd	ra,40(sp)
      f4:	f022                	sd	s0,32(sp)
      f6:	ec26                	sd	s1,24(sp)
      f8:	e84a                	sd	s2,16(sp)
      fa:	e44e                	sd	s3,8(sp)
      fc:	1800                	addi	s0,sp,48
    sleep(5);
      fe:	4515                	li	a0,5
     100:	00001097          	auipc	ra,0x1
     104:	9a0080e7          	jalr	-1632(ra) # aa0 <sleep>
    for(int i=0;i<100;i++){
     108:	4481                	li	s1,0
        printf("%d:Thread is now running tid=%d\n",i,kthread_id());
     10a:	00001997          	auipc	s3,0x1
     10e:	00698993          	addi	s3,s3,6 # 1110 <csem_free+0x62>
    for(int i=0;i<100;i++){
     112:	06400913          	li	s2,100
        printf("%d:Thread is now running tid=%d\n",i,kthread_id());
     116:	00001097          	auipc	ra,0x1
     11a:	9ba080e7          	jalr	-1606(ra) # ad0 <kthread_id>
     11e:	862a                	mv	a2,a0
     120:	85a6                	mv	a1,s1
     122:	854e                	mv	a0,s3
     124:	00001097          	auipc	ra,0x1
     128:	cbe080e7          	jalr	-834(ra) # de2 <printf>
    for(int i=0;i<100;i++){
     12c:	2485                	addiw	s1,s1,1
     12e:	ff2494e3          	bne	s1,s2,116 <test_thread_loop+0x26>
    kthread_exit(9);
     132:	4525                	li	a0,9
     134:	00001097          	auipc	ra,0x1
     138:	9a4080e7          	jalr	-1628(ra) # ad8 <kthread_exit>
}
     13c:	70a2                	ld	ra,40(sp)
     13e:	7402                	ld	s0,32(sp)
     140:	64e2                	ld	s1,24(sp)
     142:	6942                	ld	s2,16(sp)
     144:	69a2                	ld	s3,8(sp)
     146:	6145                	addi	sp,sp,48
     148:	8082                	ret

000000000000014a <test_thread2>:
void test_thread2(){
     14a:	1141                	addi	sp,sp,-16
     14c:	e406                	sd	ra,8(sp)
     14e:	e022                	sd	s0,0(sp)
     150:	0800                	addi	s0,sp,16
    sleep(5);
     152:	4515                	li	a0,5
     154:	00001097          	auipc	ra,0x1
     158:	94c080e7          	jalr	-1716(ra) # aa0 <sleep>
    printf("Thread is now running tid=%d\n",kthread_id());
     15c:	00001097          	auipc	ra,0x1
     160:	974080e7          	jalr	-1676(ra) # ad0 <kthread_id>
     164:	85aa                	mv	a1,a0
     166:	00001517          	auipc	a0,0x1
     16a:	f8a50513          	addi	a0,a0,-118 # 10f0 <csem_free+0x42>
     16e:	00001097          	auipc	ra,0x1
     172:	c74080e7          	jalr	-908(ra) # de2 <printf>
    kthread_exit(9);
     176:	4525                	li	a0,9
     178:	00001097          	auipc	ra,0x1
     17c:	960080e7          	jalr	-1696(ra) # ad8 <kthread_exit>
}
     180:	60a2                	ld	ra,8(sp)
     182:	6402                	ld	s0,0(sp)
     184:	0141                	addi	sp,sp,16
     186:	8082                	ret

0000000000000188 <test_sigkill>:
test_sigkill(){//
     188:	7179                	addi	sp,sp,-48
     18a:	f406                	sd	ra,40(sp)
     18c:	f022                	sd	s0,32(sp)
     18e:	ec26                	sd	s1,24(sp)
     190:	e84a                	sd	s2,16(sp)
     192:	e44e                	sd	s3,8(sp)
     194:	1800                	addi	s0,sp,48
   int pid = fork();
     196:	00001097          	auipc	ra,0x1
     19a:	872080e7          	jalr	-1934(ra) # a08 <fork>
     19e:	84aa                	mv	s1,a0
    if(pid==0){
     1a0:	ed05                	bnez	a0,1d8 <test_sigkill+0x50>
        sleep(5);
     1a2:	4515                	li	a0,5
     1a4:	00001097          	auipc	ra,0x1
     1a8:	8fc080e7          	jalr	-1796(ra) # aa0 <sleep>
            printf("about to get killed %d\n",i);
     1ac:	00001997          	auipc	s3,0x1
     1b0:	f8c98993          	addi	s3,s3,-116 # 1138 <csem_free+0x8a>
        for(int i=0;i<100;i++)
     1b4:	06400913          	li	s2,100
            printf("about to get killed %d\n",i);
     1b8:	85a6                	mv	a1,s1
     1ba:	854e                	mv	a0,s3
     1bc:	00001097          	auipc	ra,0x1
     1c0:	c26080e7          	jalr	-986(ra) # de2 <printf>
        for(int i=0;i<100;i++)
     1c4:	2485                	addiw	s1,s1,1
     1c6:	ff2499e3          	bne	s1,s2,1b8 <test_sigkill+0x30>
}
     1ca:	70a2                	ld	ra,40(sp)
     1cc:	7402                	ld	s0,32(sp)
     1ce:	64e2                	ld	s1,24(sp)
     1d0:	6942                	ld	s2,16(sp)
     1d2:	69a2                	ld	s3,8(sp)
     1d4:	6145                	addi	sp,sp,48
     1d6:	8082                	ret
        sleep(7);
     1d8:	451d                	li	a0,7
     1da:	00001097          	auipc	ra,0x1
     1de:	8c6080e7          	jalr	-1850(ra) # aa0 <sleep>
        printf("parent send signal to to kill child\n");
     1e2:	00001517          	auipc	a0,0x1
     1e6:	f6e50513          	addi	a0,a0,-146 # 1150 <csem_free+0xa2>
     1ea:	00001097          	auipc	ra,0x1
     1ee:	bf8080e7          	jalr	-1032(ra) # de2 <printf>
        printf("kill ret= %d\n",kill(pid, SIGKILL));
     1f2:	45a5                	li	a1,9
     1f4:	8526                	mv	a0,s1
     1f6:	00001097          	auipc	ra,0x1
     1fa:	84a080e7          	jalr	-1974(ra) # a40 <kill>
     1fe:	85aa                	mv	a1,a0
     200:	00001517          	auipc	a0,0x1
     204:	f7850513          	addi	a0,a0,-136 # 1178 <csem_free+0xca>
     208:	00001097          	auipc	ra,0x1
     20c:	bda080e7          	jalr	-1062(ra) # de2 <printf>
        printf("parent wait for child\n");
     210:	00001517          	auipc	a0,0x1
     214:	f7850513          	addi	a0,a0,-136 # 1188 <csem_free+0xda>
     218:	00001097          	auipc	ra,0x1
     21c:	bca080e7          	jalr	-1078(ra) # de2 <printf>
        wait(0);
     220:	4501                	li	a0,0
     222:	00000097          	auipc	ra,0x0
     226:	7f6080e7          	jalr	2038(ra) # a18 <wait>
        printf("parent: child is dead\n");
     22a:	00001517          	auipc	a0,0x1
     22e:	f7650513          	addi	a0,a0,-138 # 11a0 <csem_free+0xf2>
     232:	00001097          	auipc	ra,0x1
     236:	bb0080e7          	jalr	-1104(ra) # de2 <printf>
        sleep(10);
     23a:	4529                	li	a0,10
     23c:	00001097          	auipc	ra,0x1
     240:	864080e7          	jalr	-1948(ra) # aa0 <sleep>
        return;
     244:	b759                	j	1ca <test_sigkill+0x42>

0000000000000246 <sig_handler>:
sig_handler(int signum){
     246:	1101                	addi	sp,sp,-32
     248:	ec06                	sd	ra,24(sp)
     24a:	e822                	sd	s0,16(sp)
     24c:	1000                	addi	s0,sp,32
    char st[5] = "wap\n";
     24e:	0a7067b7          	lui	a5,0xa706
     252:	17778793          	addi	a5,a5,375 # a706177 <__global_pointer$+0xa70439d>
     256:	fef42423          	sw	a5,-24(s0)
     25a:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
     25e:	4615                	li	a2,5
     260:	fe840593          	addi	a1,s0,-24
     264:	4505                	li	a0,1
     266:	00000097          	auipc	ra,0x0
     26a:	7ca080e7          	jalr	1994(ra) # a30 <write>
}
     26e:	60e2                	ld	ra,24(sp)
     270:	6442                	ld	s0,16(sp)
     272:	6105                	addi	sp,sp,32
     274:	8082                	ret

0000000000000276 <test_usersig>:


void 
test_usersig(){
     276:	7139                	addi	sp,sp,-64
     278:	fc06                	sd	ra,56(sp)
     27a:	f822                	sd	s0,48(sp)
     27c:	f426                	sd	s1,40(sp)
     27e:	f04a                	sd	s2,32(sp)
     280:	0080                	addi	s0,sp,64
    int pid = fork();
     282:	00000097          	auipc	ra,0x0
     286:	786080e7          	jalr	1926(ra) # a08 <fork>
    int signum1=3;
    if(pid==0){
     28a:	c129                	beqz	a0,2cc <test_usersig+0x56>
     28c:	84aa                	mv	s1,a0

        exit(0);

    }
    else{
        sleep(5);
     28e:	4515                	li	a0,5
     290:	00001097          	auipc	ra,0x1
     294:	810080e7          	jalr	-2032(ra) # aa0 <sleep>
        printf("parent send sig 3 to child ret=%d\n",kill(pid,signum1));
     298:	458d                	li	a1,3
     29a:	8526                	mv	a0,s1
     29c:	00000097          	auipc	ra,0x0
     2a0:	7a4080e7          	jalr	1956(ra) # a40 <kill>
     2a4:	85aa                	mv	a1,a0
     2a6:	00001517          	auipc	a0,0x1
     2aa:	fea50513          	addi	a0,a0,-22 # 1290 <csem_free+0x1e2>
     2ae:	00001097          	auipc	ra,0x1
     2b2:	b34080e7          	jalr	-1228(ra) # de2 <printf>
        // printf("parent send sig 4 to child ret=%d\n",kill(pid,4));

        wait(0);
     2b6:	4501                	li	a0,0
     2b8:	00000097          	auipc	ra,0x0
     2bc:	760080e7          	jalr	1888(ra) # a18 <wait>
    }
}
     2c0:	70e2                	ld	ra,56(sp)
     2c2:	7442                	ld	s0,48(sp)
     2c4:	74a2                	ld	s1,40(sp)
     2c6:	7902                	ld	s2,32(sp)
     2c8:	6121                	addi	sp,sp,64
     2ca:	8082                	ret
        printf("sighandler= %p\n",&sig_handler2);
     2cc:	00000597          	auipc	a1,0x0
     2d0:	db658593          	addi	a1,a1,-586 # 82 <sig_handler2>
     2d4:	00001517          	auipc	a0,0x1
     2d8:	ee450513          	addi	a0,a0,-284 # 11b8 <csem_free+0x10a>
     2dc:	00001097          	auipc	ra,0x1
     2e0:	b06080e7          	jalr	-1274(ra) # de2 <printf>
        act.sa_handler = &sig_handler2;
     2e4:	00000797          	auipc	a5,0x0
     2e8:	d9e78793          	addi	a5,a5,-610 # 82 <sig_handler2>
     2ec:	fcf43023          	sd	a5,-64(s0)
        act.sigmask = mask;
     2f0:	004007b7          	lui	a5,0x400
     2f4:	fcf42423          	sw	a5,-56(s0)
        oldact.sigmask=0;
     2f8:	fc042c23          	sw	zero,-40(s0)
        oldact.sa_handler=0;
     2fc:	fc043823          	sd	zero,-48(s0)
        int ret=sigaction(signum1,&act,&oldact);
     300:	fd040613          	addi	a2,s0,-48
     304:	fc040593          	addi	a1,s0,-64
     308:	450d                	li	a0,3
     30a:	00000097          	auipc	ra,0x0
     30e:	7ae080e7          	jalr	1966(ra) # ab8 <sigaction>
     312:	84aa                	mv	s1,a0
        printf("old act->sa handler= %p, mask=%d\n",oldact.sa_handler,oldact.sigmask);
     314:	fd842603          	lw	a2,-40(s0)
     318:	fd043583          	ld	a1,-48(s0)
     31c:	00001517          	auipc	a0,0x1
     320:	eac50513          	addi	a0,a0,-340 # 11c8 <csem_free+0x11a>
     324:	00001097          	auipc	ra,0x1
     328:	abe080e7          	jalr	-1346(ra) # de2 <printf>
        printf("child return from sigaction = %d\n",ret);
     32c:	85a6                	mv	a1,s1
     32e:	00001517          	auipc	a0,0x1
     332:	ec250513          	addi	a0,a0,-318 # 11f0 <csem_free+0x142>
     336:	00001097          	auipc	ra,0x1
     33a:	aac080e7          	jalr	-1364(ra) # de2 <printf>
        sleep(10);
     33e:	4529                	li	a0,10
     340:	00000097          	auipc	ra,0x0
     344:	760080e7          	jalr	1888(ra) # aa0 <sleep>
     348:	44a9                	li	s1,10
            printf("child doing stuff before exit \n");
     34a:	00001917          	auipc	s2,0x1
     34e:	ece90913          	addi	s2,s2,-306 # 1218 <csem_free+0x16a>
     352:	854a                	mv	a0,s2
     354:	00001097          	auipc	ra,0x1
     358:	a8e080e7          	jalr	-1394(ra) # de2 <printf>
        for(int i=0;i<10;i++){
     35c:	34fd                	addiw	s1,s1,-1
     35e:	f8f5                	bnez	s1,352 <test_usersig+0xdc>
        ret=sigaction(signum1,&act,&oldact);
     360:	fd040613          	addi	a2,s0,-48
     364:	fc040593          	addi	a1,s0,-64
     368:	450d                	li	a0,3
     36a:	00000097          	auipc	ra,0x0
     36e:	74e080e7          	jalr	1870(ra) # ab8 <sigaction>
        printf("oldact should be the same as new act before \n oldact->mask=%d \t oldact->sa_handler=%p \n",oldact.sigmask,oldact.sa_handler);
     372:	fd043603          	ld	a2,-48(s0)
     376:	fd842583          	lw	a1,-40(s0)
     37a:	00001517          	auipc	a0,0x1
     37e:	ebe50513          	addi	a0,a0,-322 # 1238 <csem_free+0x18a>
     382:	00001097          	auipc	ra,0x1
     386:	a60080e7          	jalr	-1440(ra) # de2 <printf>
        exit(0);
     38a:	4501                	li	a0,0
     38c:	00000097          	auipc	ra,0x0
     390:	684080e7          	jalr	1668(ra) # a10 <exit>

0000000000000394 <test_block>:
void 
test_block(){//parent block 22 child block 23 
     394:	7179                	addi	sp,sp,-48
     396:	f406                	sd	ra,40(sp)
     398:	f022                	sd	s0,32(sp)
     39a:	ec26                	sd	s1,24(sp)
     39c:	e84a                	sd	s2,16(sp)
     39e:	e44e                	sd	s3,8(sp)
     3a0:	1800                	addi	s0,sp,48
//          child get both signal and need do block the both

    int signum1=22;
    int signum2=23;
    int ans=sigprocmask(1<<signum1);
     3a2:	00400537          	lui	a0,0x400
     3a6:	00000097          	auipc	ra,0x0
     3aa:	70a080e7          	jalr	1802(ra) # ab0 <sigprocmask>
    printf("got %d from calling to sigprocmask\n",ans);
     3ae:	0005059b          	sext.w	a1,a0
     3b2:	00001517          	auipc	a0,0x1
     3b6:	f0650513          	addi	a0,a0,-250 # 12b8 <csem_free+0x20a>
     3ba:	00001097          	auipc	ra,0x1
     3be:	a28080e7          	jalr	-1496(ra) # de2 <printf>
    int pid=fork();
     3c2:	00000097          	auipc	ra,0x0
     3c6:	646080e7          	jalr	1606(ra) # a08 <fork>
     3ca:	892a                	mv	s2,a0
    if(pid==0){
     3cc:	c535                	beqz	a0,438 <test_block+0xa4>
            printf("child blocking signal %d \n",i);
        }
        exit(0);

    }else{
        sleep(1);//wait for child to block sig
     3ce:	4505                	li	a0,1
     3d0:	00000097          	auipc	ra,0x0
     3d4:	6d0080e7          	jalr	1744(ra) # aa0 <sleep>
        printf("parent: sent signal 22 to child ->child shuld block\n");
     3d8:	00001517          	auipc	a0,0x1
     3dc:	f2850513          	addi	a0,a0,-216 # 1300 <csem_free+0x252>
     3e0:	00001097          	auipc	ra,0x1
     3e4:	a02080e7          	jalr	-1534(ra) # de2 <printf>
     3e8:	44a9                	li	s1,10
        for(int i=0; i<10;i++){
            kill(pid,signum1);
     3ea:	45d9                	li	a1,22
     3ec:	854a                	mv	a0,s2
     3ee:	00000097          	auipc	ra,0x0
     3f2:	652080e7          	jalr	1618(ra) # a40 <kill>
        for(int i=0; i<10;i++){
     3f6:	34fd                	addiw	s1,s1,-1
     3f8:	f8ed                	bnez	s1,3ea <test_block+0x56>
        }
        sleep(10);
     3fa:	4529                	li	a0,10
     3fc:	00000097          	auipc	ra,0x0
     400:	6a4080e7          	jalr	1700(ra) # aa0 <sleep>
        kill(pid,signum2);
     404:	45dd                	li	a1,23
     406:	854a                	mv	a0,s2
     408:	00000097          	auipc	ra,0x0
     40c:	638080e7          	jalr	1592(ra) # a40 <kill>

        printf("parent: sent signal 23 to child ->child shuld die\n");
     410:	00001517          	auipc	a0,0x1
     414:	f2850513          	addi	a0,a0,-216 # 1338 <csem_free+0x28a>
     418:	00001097          	auipc	ra,0x1
     41c:	9ca080e7          	jalr	-1590(ra) # de2 <printf>
        wait(0);
     420:	4501                	li	a0,0
     422:	00000097          	auipc	ra,0x0
     426:	5f6080e7          	jalr	1526(ra) # a18 <wait>
    }
    // exit(0);
}
     42a:	70a2                	ld	ra,40(sp)
     42c:	7402                	ld	s0,32(sp)
     42e:	64e2                	ld	s1,24(sp)
     430:	6942                	ld	s2,16(sp)
     432:	69a2                	ld	s3,8(sp)
     434:	6145                	addi	sp,sp,48
     436:	8082                	ret
        sleep(3);
     438:	450d                	li	a0,3
     43a:	00000097          	auipc	ra,0x0
     43e:	666080e7          	jalr	1638(ra) # aa0 <sleep>
            printf("child blocking signal %d \n",i);
     442:	00001997          	auipc	s3,0x1
     446:	e9e98993          	addi	s3,s3,-354 # 12e0 <csem_free+0x232>
        for(int i=0;i<1000;i++){
     44a:	3e800493          	li	s1,1000
            sleep(1);
     44e:	4505                	li	a0,1
     450:	00000097          	auipc	ra,0x0
     454:	650080e7          	jalr	1616(ra) # aa0 <sleep>
            printf("child blocking signal %d \n",i);
     458:	85ca                	mv	a1,s2
     45a:	854e                	mv	a0,s3
     45c:	00001097          	auipc	ra,0x1
     460:	986080e7          	jalr	-1658(ra) # de2 <printf>
        for(int i=0;i<1000;i++){
     464:	2905                	addiw	s2,s2,1
     466:	fe9914e3          	bne	s2,s1,44e <test_block+0xba>
        exit(0);
     46a:	4501                	li	a0,0
     46c:	00000097          	auipc	ra,0x0
     470:	5a4080e7          	jalr	1444(ra) # a10 <exit>

0000000000000474 <test_stop_cont>:

void
test_stop_cont(){
     474:	7179                	addi	sp,sp,-48
     476:	f406                	sd	ra,40(sp)
     478:	f022                	sd	s0,32(sp)
     47a:	ec26                	sd	s1,24(sp)
     47c:	e84a                	sd	s2,16(sp)
     47e:	e44e                	sd	s3,8(sp)
     480:	1800                	addi	s0,sp,48
    int pid = fork();
     482:	00000097          	auipc	ra,0x0
     486:	586080e7          	jalr	1414(ra) # a08 <fork>
     48a:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
     48c:	c949                	beqz	a0,51e <test_stop_cont+0xaa>
        for(i=0;i<500;i++){
            printf("%d\n ", i);
        }
        exit(0);
    }else{
        printf("son pid=%d, dad pid=%d\n", pid, getpid());
     48e:	00000097          	auipc	ra,0x0
     492:	602080e7          	jalr	1538(ra) # a90 <getpid>
     496:	862a                	mv	a2,a0
     498:	85a6                	mv	a1,s1
     49a:	00001517          	auipc	a0,0x1
     49e:	ede50513          	addi	a0,a0,-290 # 1378 <csem_free+0x2ca>
     4a2:	00001097          	auipc	ra,0x1
     4a6:	940080e7          	jalr	-1728(ra) # de2 <printf>
        sleep(5);
     4aa:	4515                	li	a0,5
     4ac:	00000097          	auipc	ra,0x0
     4b0:	5f4080e7          	jalr	1524(ra) # aa0 <sleep>
        printf("parent send stop ret= %d\n", kill(pid, SIGSTOP));
     4b4:	45c5                	li	a1,17
     4b6:	8526                	mv	a0,s1
     4b8:	00000097          	auipc	ra,0x0
     4bc:	588080e7          	jalr	1416(ra) # a40 <kill>
     4c0:	85aa                	mv	a1,a0
     4c2:	00001517          	auipc	a0,0x1
     4c6:	ece50513          	addi	a0,a0,-306 # 1390 <csem_free+0x2e2>
     4ca:	00001097          	auipc	ra,0x1
     4ce:	918080e7          	jalr	-1768(ra) # de2 <printf>
        sleep(50);
     4d2:	03200513          	li	a0,50
     4d6:	00000097          	auipc	ra,0x0
     4da:	5ca080e7          	jalr	1482(ra) # aa0 <sleep>
        printf("parent send continue ret= %d\n", kill(pid, SIGCONT));
     4de:	45cd                	li	a1,19
     4e0:	8526                	mv	a0,s1
     4e2:	00000097          	auipc	ra,0x0
     4e6:	55e080e7          	jalr	1374(ra) # a40 <kill>
     4ea:	85aa                	mv	a1,a0
     4ec:	00001517          	auipc	a0,0x1
     4f0:	ec450513          	addi	a0,a0,-316 # 13b0 <csem_free+0x302>
     4f4:	00001097          	auipc	ra,0x1
     4f8:	8ee080e7          	jalr	-1810(ra) # de2 <printf>
        wait(0);
     4fc:	4501                	li	a0,0
     4fe:	00000097          	auipc	ra,0x0
     502:	51a080e7          	jalr	1306(ra) # a18 <wait>
        // for(int i=0;i<100;i++)
        //  printf("parent..");
        sleep(10);
     506:	4529                	li	a0,10
     508:	00000097          	auipc	ra,0x0
     50c:	598080e7          	jalr	1432(ra) # aa0 <sleep>
        return;
    }
}
     510:	70a2                	ld	ra,40(sp)
     512:	7402                	ld	s0,32(sp)
     514:	64e2                	ld	s1,24(sp)
     516:	6942                	ld	s2,16(sp)
     518:	69a2                	ld	s3,8(sp)
     51a:	6145                	addi	sp,sp,48
     51c:	8082                	ret
        sleep(2);
     51e:	4509                	li	a0,2
     520:	00000097          	auipc	ra,0x0
     524:	580080e7          	jalr	1408(ra) # aa0 <sleep>
            printf("%d\n ", i);
     528:	00001997          	auipc	s3,0x1
     52c:	e4898993          	addi	s3,s3,-440 # 1370 <csem_free+0x2c2>
        for(i=0;i<500;i++){
     530:	1f400913          	li	s2,500
            printf("%d\n ", i);
     534:	85a6                	mv	a1,s1
     536:	854e                	mv	a0,s3
     538:	00001097          	auipc	ra,0x1
     53c:	8aa080e7          	jalr	-1878(ra) # de2 <printf>
        for(i=0;i<500;i++){
     540:	2485                	addiw	s1,s1,1
     542:	ff2499e3          	bne	s1,s2,534 <test_stop_cont+0xc0>
        exit(0);
     546:	4501                	li	a0,0
     548:	00000097          	auipc	ra,0x0
     54c:	4c8080e7          	jalr	1224(ra) # a10 <exit>

0000000000000550 <test_ignore>:

void 
test_ignore(){
     550:	7179                	addi	sp,sp,-48
     552:	f406                	sd	ra,40(sp)
     554:	f022                	sd	s0,32(sp)
     556:	ec26                	sd	s1,24(sp)
     558:	e84a                	sd	s2,16(sp)
     55a:	e44e                	sd	s3,8(sp)
     55c:	1800                	addi	s0,sp,48
    int pid= fork();
     55e:	00000097          	auipc	ra,0x0
     562:	4aa080e7          	jalr	1194(ra) # a08 <fork>
     566:	84aa                	mv	s1,a0
    int signum=22;
    if(pid==0){
     568:	c129                	beqz	a0,5aa <test_ignore+0x5a>
            printf("child ignoring signal %d\n",i);
        }
        exit(0);

    }else{
        printf("son pid= %d",pid);
     56a:	85aa                	mv	a1,a0
     56c:	00001517          	auipc	a0,0x1
     570:	ecc50513          	addi	a0,a0,-308 # 1438 <csem_free+0x38a>
     574:	00001097          	auipc	ra,0x1
     578:	86e080e7          	jalr	-1938(ra) # de2 <printf>
        sleep(5);
     57c:	4515                	li	a0,5
     57e:	00000097          	auipc	ra,0x0
     582:	522080e7          	jalr	1314(ra) # aa0 <sleep>
        kill(pid,signum);
     586:	45d9                	li	a1,22
     588:	8526                	mv	a0,s1
     58a:	00000097          	auipc	ra,0x0
     58e:	4b6080e7          	jalr	1206(ra) # a40 <kill>
        wait(0);
     592:	4501                	li	a0,0
     594:	00000097          	auipc	ra,0x0
     598:	484080e7          	jalr	1156(ra) # a18 <wait>
    }
}
     59c:	70a2                	ld	ra,40(sp)
     59e:	7402                	ld	s0,32(sp)
     5a0:	64e2                	ld	s1,24(sp)
     5a2:	6942                	ld	s2,16(sp)
     5a4:	69a2                	ld	s3,8(sp)
     5a6:	6145                	addi	sp,sp,48
     5a8:	8082                	ret
        newAct=malloc(sizeof(sigaction));
     5aa:	4505                	li	a0,1
     5ac:	00001097          	auipc	ra,0x1
     5b0:	8f4080e7          	jalr	-1804(ra) # ea0 <malloc>
     5b4:	89aa                	mv	s3,a0
        oldAct=malloc(sizeof(sigaction));
     5b6:	4505                	li	a0,1
     5b8:	00001097          	auipc	ra,0x1
     5bc:	8e8080e7          	jalr	-1816(ra) # ea0 <malloc>
     5c0:	892a                	mv	s2,a0
        newAct->sigmask = 0;
     5c2:	0009a423          	sw	zero,8(s3)
        newAct->sa_handler=(void*)SIG_IGN;
     5c6:	4785                	li	a5,1
     5c8:	00f9b023          	sd	a5,0(s3)
        int ans=sigaction(signum,newAct,oldAct);
     5cc:	862a                	mv	a2,a0
     5ce:	85ce                	mv	a1,s3
     5d0:	4559                	li	a0,22
     5d2:	00000097          	auipc	ra,0x0
     5d6:	4e6080e7          	jalr	1254(ra) # ab8 <sigaction>
     5da:	85aa                	mv	a1,a0
        printf("ans from sigaction %d, old act returned is: mask= %d address= %d\n",ans,oldAct->sigmask,(uint64)oldAct->sa_handler);
     5dc:	00093683          	ld	a3,0(s2)
     5e0:	00892603          	lw	a2,8(s2)
     5e4:	00001517          	auipc	a0,0x1
     5e8:	dec50513          	addi	a0,a0,-532 # 13d0 <csem_free+0x322>
     5ec:	00000097          	auipc	ra,0x0
     5f0:	7f6080e7          	jalr	2038(ra) # de2 <printf>
        sleep(6);
     5f4:	4519                	li	a0,6
     5f6:	00000097          	auipc	ra,0x0
     5fa:	4aa080e7          	jalr	1194(ra) # aa0 <sleep>
            printf("child ignoring signal %d\n",i);
     5fe:	00001997          	auipc	s3,0x1
     602:	e1a98993          	addi	s3,s3,-486 # 1418 <csem_free+0x36a>
        for(int i=0;i<300;i++){
     606:	12c00913          	li	s2,300
            printf("child ignoring signal %d\n",i);
     60a:	85a6                	mv	a1,s1
     60c:	854e                	mv	a0,s3
     60e:	00000097          	auipc	ra,0x0
     612:	7d4080e7          	jalr	2004(ra) # de2 <printf>
        for(int i=0;i<300;i++){
     616:	2485                	addiw	s1,s1,1
     618:	ff2499e3          	bne	s1,s2,60a <test_ignore+0xba>
        exit(0);
     61c:	4501                	li	a0,0
     61e:	00000097          	auipc	ra,0x0
     622:	3f2080e7          	jalr	1010(ra) # a10 <exit>

0000000000000626 <test_user_handler_kill>:
void
test_user_handler_kill(){
     626:	7139                	addi	sp,sp,-64
     628:	fc06                	sd	ra,56(sp)
     62a:	f822                	sd	s0,48(sp)
     62c:	f426                	sd	s1,40(sp)
     62e:	0080                	addi	s0,sp,64
    struct sigaction act;

    printf("sighandler1= %p\n", &sig_handler_loop);
     630:	00000597          	auipc	a1,0x0
     634:	9d058593          	addi	a1,a1,-1584 # 0 <sig_handler_loop>
     638:	00001517          	auipc	a0,0x1
     63c:	e1050513          	addi	a0,a0,-496 # 1448 <csem_free+0x39a>
     640:	00000097          	auipc	ra,0x0
     644:	7a2080e7          	jalr	1954(ra) # de2 <printf>
    printf("sighandler2= %p\n", &sig_handler_loop2);
     648:	00000597          	auipc	a1,0x0
     64c:	9f458593          	addi	a1,a1,-1548 # 3c <sig_handler_loop2>
     650:	00001517          	auipc	a0,0x1
     654:	e1050513          	addi	a0,a0,-496 # 1460 <csem_free+0x3b2>
     658:	00000097          	auipc	ra,0x0
     65c:	78a080e7          	jalr	1930(ra) # de2 <printf>


    uint mask = 0;
    mask ^= (1<<22);

    act.sigmask = mask;
     660:	004007b7          	lui	a5,0x400
     664:	fcf42c23          	sw	a5,-40(s0)
    
    struct sigaction oldact;
    oldact.sigmask=0;
     668:	fc042423          	sw	zero,-56(s0)
    oldact.sa_handler=0;
     66c:	fc043023          	sd	zero,-64(s0)
    
    act.sa_handler=&sig_handler_loop2;
     670:	00000797          	auipc	a5,0x0
     674:	9cc78793          	addi	a5,a5,-1588 # 3c <sig_handler_loop2>
     678:	fcf43823          	sd	a5,-48(s0)


    int pid = fork();
     67c:	00000097          	auipc	ra,0x0
     680:	38c080e7          	jalr	908(ra) # a08 <fork>
    int i;
    if(pid==0){
     684:	e12d                	bnez	a0,6e6 <test_user_handler_kill+0xc0>
        int ret=sigaction(3,&act,&oldact);
     686:	fc040613          	addi	a2,s0,-64
     68a:	fd040593          	addi	a1,s0,-48
     68e:	450d                	li	a0,3
     690:	00000097          	auipc	ra,0x0
     694:	428080e7          	jalr	1064(ra) # ab8 <sigaction>
        if(ret <0 ){
     698:	06400493          	li	s1,100
     69c:	02054863          	bltz	a0,6cc <test_user_handler_kill+0xa6>
            printf("sigaction FAILED\n");
            exit(-1);
        }

        for(i=0;i<100;i++)
            sleep(1);
     6a0:	4505                	li	a0,1
     6a2:	00000097          	auipc	ra,0x0
     6a6:	3fe080e7          	jalr	1022(ra) # aa0 <sleep>
        for(i=0;i<100;i++)
     6aa:	34fd                	addiw	s1,s1,-1
     6ac:	f8f5                	bnez	s1,6a0 <test_user_handler_kill+0x7a>
            printf("out-side handler %d\n ", i);
     6ae:	06400593          	li	a1,100
     6b2:	00001517          	auipc	a0,0x1
     6b6:	dde50513          	addi	a0,a0,-546 # 1490 <csem_free+0x3e2>
     6ba:	00000097          	auipc	ra,0x0
     6be:	728080e7          	jalr	1832(ra) # de2 <printf>
        exit(0);
     6c2:	4501                	li	a0,0
     6c4:	00000097          	auipc	ra,0x0
     6c8:	34c080e7          	jalr	844(ra) # a10 <exit>
            printf("sigaction FAILED\n");
     6cc:	00001517          	auipc	a0,0x1
     6d0:	dac50513          	addi	a0,a0,-596 # 1478 <csem_free+0x3ca>
     6d4:	00000097          	auipc	ra,0x0
     6d8:	70e080e7          	jalr	1806(ra) # de2 <printf>
            exit(-1);
     6dc:	557d                	li	a0,-1
     6de:	00000097          	auipc	ra,0x0
     6e2:	332080e7          	jalr	818(ra) # a10 <exit>
     6e6:	84aa                	mv	s1,a0
    }else{
        printf("son pid=%d, dad pid=%d\n",pid, getpid());
     6e8:	00000097          	auipc	ra,0x0
     6ec:	3a8080e7          	jalr	936(ra) # a90 <getpid>
     6f0:	862a                	mv	a2,a0
     6f2:	85a6                	mv	a1,s1
     6f4:	00001517          	auipc	a0,0x1
     6f8:	c8450513          	addi	a0,a0,-892 # 1378 <csem_free+0x2ca>
     6fc:	00000097          	auipc	ra,0x0
     700:	6e6080e7          	jalr	1766(ra) # de2 <printf>
        sleep(5);
     704:	4515                	li	a0,5
     706:	00000097          	auipc	ra,0x0
     70a:	39a080e7          	jalr	922(ra) # aa0 <sleep>
        printf("parent send loop ret= %d\n",kill(pid, 3));
     70e:	458d                	li	a1,3
     710:	8526                	mv	a0,s1
     712:	00000097          	auipc	ra,0x0
     716:	32e080e7          	jalr	814(ra) # a40 <kill>
     71a:	85aa                	mv	a1,a0
     71c:	00001517          	auipc	a0,0x1
     720:	d8c50513          	addi	a0,a0,-628 # 14a8 <csem_free+0x3fa>
     724:	00000097          	auipc	ra,0x0
     728:	6be080e7          	jalr	1726(ra) # de2 <printf>
        sleep(20);
     72c:	4551                	li	a0,20
     72e:	00000097          	auipc	ra,0x0
     732:	372080e7          	jalr	882(ra) # aa0 <sleep>
        printf("parent send kill ret= %d\n",kill(pid, SIGKILL));
     736:	45a5                	li	a1,9
     738:	8526                	mv	a0,s1
     73a:	00000097          	auipc	ra,0x0
     73e:	306080e7          	jalr	774(ra) # a40 <kill>
     742:	85aa                	mv	a1,a0
     744:	00001517          	auipc	a0,0x1
     748:	d8450513          	addi	a0,a0,-636 # 14c8 <csem_free+0x41a>
     74c:	00000097          	auipc	ra,0x0
     750:	696080e7          	jalr	1686(ra) # de2 <printf>
        wait(0);
     754:	4501                	li	a0,0
     756:	00000097          	auipc	ra,0x0
     75a:	2c2080e7          	jalr	706(ra) # a18 <wait>
        printf("parent exiting\n");
     75e:	00001517          	auipc	a0,0x1
     762:	d8a50513          	addi	a0,a0,-630 # 14e8 <csem_free+0x43a>
     766:	00000097          	auipc	ra,0x0
     76a:	67c080e7          	jalr	1660(ra) # de2 <printf>
    }
}
     76e:	70e2                	ld	ra,56(sp)
     770:	7442                	ld	s0,48(sp)
     772:	74a2                	ld	s1,40(sp)
     774:	6121                	addi	sp,sp,64
     776:	8082                	ret

0000000000000778 <main>:


int main(){
     778:	1141                	addi	sp,sp,-16
     77a:	e406                	sd	ra,8(sp)
     77c:	e022                	sd	s0,0(sp)
     77e:	0800                	addi	s0,sp,16
    // test_usersig();
    // printf("-----------------------------test_block-----------------------------\n");
    // test_block();
    // printf("-----------------------------test_ignore-----------------------------\n");
    // test_ignore();
    printf("-----------------------------test_user_handler_then_kill-----------------------------\n");
     780:	00001517          	auipc	a0,0x1
     784:	d7850513          	addi	a0,a0,-648 # 14f8 <csem_free+0x44a>
     788:	00000097          	auipc	ra,0x0
     78c:	65a080e7          	jalr	1626(ra) # de2 <printf>
    test_user_handler_kill();
     790:	00000097          	auipc	ra,0x0
     794:	e96080e7          	jalr	-362(ra) # 626 <test_user_handler_kill>


  
   

    exit(0);
     798:	4501                	li	a0,0
     79a:	00000097          	auipc	ra,0x0
     79e:	276080e7          	jalr	630(ra) # a10 <exit>

00000000000007a2 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     7a2:	1141                	addi	sp,sp,-16
     7a4:	e422                	sd	s0,8(sp)
     7a6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     7a8:	87aa                	mv	a5,a0
     7aa:	0585                	addi	a1,a1,1
     7ac:	0785                	addi	a5,a5,1
     7ae:	fff5c703          	lbu	a4,-1(a1)
     7b2:	fee78fa3          	sb	a4,-1(a5)
     7b6:	fb75                	bnez	a4,7aa <strcpy+0x8>
    ;
  return os;
}
     7b8:	6422                	ld	s0,8(sp)
     7ba:	0141                	addi	sp,sp,16
     7bc:	8082                	ret

00000000000007be <strcmp>:

int
strcmp(const char *p, const char *q)
{
     7be:	1141                	addi	sp,sp,-16
     7c0:	e422                	sd	s0,8(sp)
     7c2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     7c4:	00054783          	lbu	a5,0(a0)
     7c8:	cb91                	beqz	a5,7dc <strcmp+0x1e>
     7ca:	0005c703          	lbu	a4,0(a1)
     7ce:	00f71763          	bne	a4,a5,7dc <strcmp+0x1e>
    p++, q++;
     7d2:	0505                	addi	a0,a0,1
     7d4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     7d6:	00054783          	lbu	a5,0(a0)
     7da:	fbe5                	bnez	a5,7ca <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     7dc:	0005c503          	lbu	a0,0(a1)
}
     7e0:	40a7853b          	subw	a0,a5,a0
     7e4:	6422                	ld	s0,8(sp)
     7e6:	0141                	addi	sp,sp,16
     7e8:	8082                	ret

00000000000007ea <strlen>:

uint
strlen(const char *s)
{
     7ea:	1141                	addi	sp,sp,-16
     7ec:	e422                	sd	s0,8(sp)
     7ee:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     7f0:	00054783          	lbu	a5,0(a0)
     7f4:	cf91                	beqz	a5,810 <strlen+0x26>
     7f6:	0505                	addi	a0,a0,1
     7f8:	87aa                	mv	a5,a0
     7fa:	4685                	li	a3,1
     7fc:	9e89                	subw	a3,a3,a0
     7fe:	00f6853b          	addw	a0,a3,a5
     802:	0785                	addi	a5,a5,1
     804:	fff7c703          	lbu	a4,-1(a5)
     808:	fb7d                	bnez	a4,7fe <strlen+0x14>
    ;
  return n;
}
     80a:	6422                	ld	s0,8(sp)
     80c:	0141                	addi	sp,sp,16
     80e:	8082                	ret
  for(n = 0; s[n]; n++)
     810:	4501                	li	a0,0
     812:	bfe5                	j	80a <strlen+0x20>

0000000000000814 <memset>:

void*
memset(void *dst, int c, uint n)
{
     814:	1141                	addi	sp,sp,-16
     816:	e422                	sd	s0,8(sp)
     818:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     81a:	ca19                	beqz	a2,830 <memset+0x1c>
     81c:	87aa                	mv	a5,a0
     81e:	1602                	slli	a2,a2,0x20
     820:	9201                	srli	a2,a2,0x20
     822:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     826:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     82a:	0785                	addi	a5,a5,1
     82c:	fee79de3          	bne	a5,a4,826 <memset+0x12>
  }
  return dst;
}
     830:	6422                	ld	s0,8(sp)
     832:	0141                	addi	sp,sp,16
     834:	8082                	ret

0000000000000836 <strchr>:

char*
strchr(const char *s, char c)
{
     836:	1141                	addi	sp,sp,-16
     838:	e422                	sd	s0,8(sp)
     83a:	0800                	addi	s0,sp,16
  for(; *s; s++)
     83c:	00054783          	lbu	a5,0(a0)
     840:	cb99                	beqz	a5,856 <strchr+0x20>
    if(*s == c)
     842:	00f58763          	beq	a1,a5,850 <strchr+0x1a>
  for(; *s; s++)
     846:	0505                	addi	a0,a0,1
     848:	00054783          	lbu	a5,0(a0)
     84c:	fbfd                	bnez	a5,842 <strchr+0xc>
      return (char*)s;
  return 0;
     84e:	4501                	li	a0,0
}
     850:	6422                	ld	s0,8(sp)
     852:	0141                	addi	sp,sp,16
     854:	8082                	ret
  return 0;
     856:	4501                	li	a0,0
     858:	bfe5                	j	850 <strchr+0x1a>

000000000000085a <gets>:

char*
gets(char *buf, int max)
{
     85a:	711d                	addi	sp,sp,-96
     85c:	ec86                	sd	ra,88(sp)
     85e:	e8a2                	sd	s0,80(sp)
     860:	e4a6                	sd	s1,72(sp)
     862:	e0ca                	sd	s2,64(sp)
     864:	fc4e                	sd	s3,56(sp)
     866:	f852                	sd	s4,48(sp)
     868:	f456                	sd	s5,40(sp)
     86a:	f05a                	sd	s6,32(sp)
     86c:	ec5e                	sd	s7,24(sp)
     86e:	1080                	addi	s0,sp,96
     870:	8baa                	mv	s7,a0
     872:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     874:	892a                	mv	s2,a0
     876:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     878:	4aa9                	li	s5,10
     87a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     87c:	89a6                	mv	s3,s1
     87e:	2485                	addiw	s1,s1,1
     880:	0344d863          	bge	s1,s4,8b0 <gets+0x56>
    cc = read(0, &c, 1);
     884:	4605                	li	a2,1
     886:	faf40593          	addi	a1,s0,-81
     88a:	4501                	li	a0,0
     88c:	00000097          	auipc	ra,0x0
     890:	19c080e7          	jalr	412(ra) # a28 <read>
    if(cc < 1)
     894:	00a05e63          	blez	a0,8b0 <gets+0x56>
    buf[i++] = c;
     898:	faf44783          	lbu	a5,-81(s0)
     89c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     8a0:	01578763          	beq	a5,s5,8ae <gets+0x54>
     8a4:	0905                	addi	s2,s2,1
     8a6:	fd679be3          	bne	a5,s6,87c <gets+0x22>
  for(i=0; i+1 < max; ){
     8aa:	89a6                	mv	s3,s1
     8ac:	a011                	j	8b0 <gets+0x56>
     8ae:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     8b0:	99de                	add	s3,s3,s7
     8b2:	00098023          	sb	zero,0(s3)
  return buf;
}
     8b6:	855e                	mv	a0,s7
     8b8:	60e6                	ld	ra,88(sp)
     8ba:	6446                	ld	s0,80(sp)
     8bc:	64a6                	ld	s1,72(sp)
     8be:	6906                	ld	s2,64(sp)
     8c0:	79e2                	ld	s3,56(sp)
     8c2:	7a42                	ld	s4,48(sp)
     8c4:	7aa2                	ld	s5,40(sp)
     8c6:	7b02                	ld	s6,32(sp)
     8c8:	6be2                	ld	s7,24(sp)
     8ca:	6125                	addi	sp,sp,96
     8cc:	8082                	ret

00000000000008ce <stat>:

int
stat(const char *n, struct stat *st)
{
     8ce:	1101                	addi	sp,sp,-32
     8d0:	ec06                	sd	ra,24(sp)
     8d2:	e822                	sd	s0,16(sp)
     8d4:	e426                	sd	s1,8(sp)
     8d6:	e04a                	sd	s2,0(sp)
     8d8:	1000                	addi	s0,sp,32
     8da:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     8dc:	4581                	li	a1,0
     8de:	00000097          	auipc	ra,0x0
     8e2:	172080e7          	jalr	370(ra) # a50 <open>
  if(fd < 0)
     8e6:	02054563          	bltz	a0,910 <stat+0x42>
     8ea:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     8ec:	85ca                	mv	a1,s2
     8ee:	00000097          	auipc	ra,0x0
     8f2:	17a080e7          	jalr	378(ra) # a68 <fstat>
     8f6:	892a                	mv	s2,a0
  close(fd);
     8f8:	8526                	mv	a0,s1
     8fa:	00000097          	auipc	ra,0x0
     8fe:	13e080e7          	jalr	318(ra) # a38 <close>
  return r;
}
     902:	854a                	mv	a0,s2
     904:	60e2                	ld	ra,24(sp)
     906:	6442                	ld	s0,16(sp)
     908:	64a2                	ld	s1,8(sp)
     90a:	6902                	ld	s2,0(sp)
     90c:	6105                	addi	sp,sp,32
     90e:	8082                	ret
    return -1;
     910:	597d                	li	s2,-1
     912:	bfc5                	j	902 <stat+0x34>

0000000000000914 <atoi>:

int
atoi(const char *s)
{
     914:	1141                	addi	sp,sp,-16
     916:	e422                	sd	s0,8(sp)
     918:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     91a:	00054603          	lbu	a2,0(a0)
     91e:	fd06079b          	addiw	a5,a2,-48
     922:	0ff7f793          	zext.b	a5,a5
     926:	4725                	li	a4,9
     928:	02f76963          	bltu	a4,a5,95a <atoi+0x46>
     92c:	86aa                	mv	a3,a0
  n = 0;
     92e:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     930:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     932:	0685                	addi	a3,a3,1
     934:	0025179b          	slliw	a5,a0,0x2
     938:	9fa9                	addw	a5,a5,a0
     93a:	0017979b          	slliw	a5,a5,0x1
     93e:	9fb1                	addw	a5,a5,a2
     940:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     944:	0006c603          	lbu	a2,0(a3)
     948:	fd06071b          	addiw	a4,a2,-48
     94c:	0ff77713          	zext.b	a4,a4
     950:	fee5f1e3          	bgeu	a1,a4,932 <atoi+0x1e>
  return n;
}
     954:	6422                	ld	s0,8(sp)
     956:	0141                	addi	sp,sp,16
     958:	8082                	ret
  n = 0;
     95a:	4501                	li	a0,0
     95c:	bfe5                	j	954 <atoi+0x40>

000000000000095e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     95e:	1141                	addi	sp,sp,-16
     960:	e422                	sd	s0,8(sp)
     962:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     964:	02b57463          	bgeu	a0,a1,98c <memmove+0x2e>
    while(n-- > 0)
     968:	00c05f63          	blez	a2,986 <memmove+0x28>
     96c:	1602                	slli	a2,a2,0x20
     96e:	9201                	srli	a2,a2,0x20
     970:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     974:	872a                	mv	a4,a0
      *dst++ = *src++;
     976:	0585                	addi	a1,a1,1
     978:	0705                	addi	a4,a4,1
     97a:	fff5c683          	lbu	a3,-1(a1)
     97e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     982:	fee79ae3          	bne	a5,a4,976 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     986:	6422                	ld	s0,8(sp)
     988:	0141                	addi	sp,sp,16
     98a:	8082                	ret
    dst += n;
     98c:	00c50733          	add	a4,a0,a2
    src += n;
     990:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     992:	fec05ae3          	blez	a2,986 <memmove+0x28>
     996:	fff6079b          	addiw	a5,a2,-1
     99a:	1782                	slli	a5,a5,0x20
     99c:	9381                	srli	a5,a5,0x20
     99e:	fff7c793          	not	a5,a5
     9a2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     9a4:	15fd                	addi	a1,a1,-1
     9a6:	177d                	addi	a4,a4,-1
     9a8:	0005c683          	lbu	a3,0(a1)
     9ac:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     9b0:	fee79ae3          	bne	a5,a4,9a4 <memmove+0x46>
     9b4:	bfc9                	j	986 <memmove+0x28>

00000000000009b6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     9b6:	1141                	addi	sp,sp,-16
     9b8:	e422                	sd	s0,8(sp)
     9ba:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     9bc:	ca05                	beqz	a2,9ec <memcmp+0x36>
     9be:	fff6069b          	addiw	a3,a2,-1
     9c2:	1682                	slli	a3,a3,0x20
     9c4:	9281                	srli	a3,a3,0x20
     9c6:	0685                	addi	a3,a3,1
     9c8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     9ca:	00054783          	lbu	a5,0(a0)
     9ce:	0005c703          	lbu	a4,0(a1)
     9d2:	00e79863          	bne	a5,a4,9e2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     9d6:	0505                	addi	a0,a0,1
    p2++;
     9d8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     9da:	fed518e3          	bne	a0,a3,9ca <memcmp+0x14>
  }
  return 0;
     9de:	4501                	li	a0,0
     9e0:	a019                	j	9e6 <memcmp+0x30>
      return *p1 - *p2;
     9e2:	40e7853b          	subw	a0,a5,a4
}
     9e6:	6422                	ld	s0,8(sp)
     9e8:	0141                	addi	sp,sp,16
     9ea:	8082                	ret
  return 0;
     9ec:	4501                	li	a0,0
     9ee:	bfe5                	j	9e6 <memcmp+0x30>

00000000000009f0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     9f0:	1141                	addi	sp,sp,-16
     9f2:	e406                	sd	ra,8(sp)
     9f4:	e022                	sd	s0,0(sp)
     9f6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     9f8:	00000097          	auipc	ra,0x0
     9fc:	f66080e7          	jalr	-154(ra) # 95e <memmove>
}
     a00:	60a2                	ld	ra,8(sp)
     a02:	6402                	ld	s0,0(sp)
     a04:	0141                	addi	sp,sp,16
     a06:	8082                	ret

0000000000000a08 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     a08:	4885                	li	a7,1
 ecall
     a0a:	00000073          	ecall
 ret
     a0e:	8082                	ret

0000000000000a10 <exit>:
.global exit
exit:
 li a7, SYS_exit
     a10:	4889                	li	a7,2
 ecall
     a12:	00000073          	ecall
 ret
     a16:	8082                	ret

0000000000000a18 <wait>:
.global wait
wait:
 li a7, SYS_wait
     a18:	488d                	li	a7,3
 ecall
     a1a:	00000073          	ecall
 ret
     a1e:	8082                	ret

0000000000000a20 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     a20:	4891                	li	a7,4
 ecall
     a22:	00000073          	ecall
 ret
     a26:	8082                	ret

0000000000000a28 <read>:
.global read
read:
 li a7, SYS_read
     a28:	4895                	li	a7,5
 ecall
     a2a:	00000073          	ecall
 ret
     a2e:	8082                	ret

0000000000000a30 <write>:
.global write
write:
 li a7, SYS_write
     a30:	48c1                	li	a7,16
 ecall
     a32:	00000073          	ecall
 ret
     a36:	8082                	ret

0000000000000a38 <close>:
.global close
close:
 li a7, SYS_close
     a38:	48d5                	li	a7,21
 ecall
     a3a:	00000073          	ecall
 ret
     a3e:	8082                	ret

0000000000000a40 <kill>:
.global kill
kill:
 li a7, SYS_kill
     a40:	4899                	li	a7,6
 ecall
     a42:	00000073          	ecall
 ret
     a46:	8082                	ret

0000000000000a48 <exec>:
.global exec
exec:
 li a7, SYS_exec
     a48:	489d                	li	a7,7
 ecall
     a4a:	00000073          	ecall
 ret
     a4e:	8082                	ret

0000000000000a50 <open>:
.global open
open:
 li a7, SYS_open
     a50:	48bd                	li	a7,15
 ecall
     a52:	00000073          	ecall
 ret
     a56:	8082                	ret

0000000000000a58 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     a58:	48c5                	li	a7,17
 ecall
     a5a:	00000073          	ecall
 ret
     a5e:	8082                	ret

0000000000000a60 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     a60:	48c9                	li	a7,18
 ecall
     a62:	00000073          	ecall
 ret
     a66:	8082                	ret

0000000000000a68 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     a68:	48a1                	li	a7,8
 ecall
     a6a:	00000073          	ecall
 ret
     a6e:	8082                	ret

0000000000000a70 <link>:
.global link
link:
 li a7, SYS_link
     a70:	48cd                	li	a7,19
 ecall
     a72:	00000073          	ecall
 ret
     a76:	8082                	ret

0000000000000a78 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     a78:	48d1                	li	a7,20
 ecall
     a7a:	00000073          	ecall
 ret
     a7e:	8082                	ret

0000000000000a80 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     a80:	48a5                	li	a7,9
 ecall
     a82:	00000073          	ecall
 ret
     a86:	8082                	ret

0000000000000a88 <dup>:
.global dup
dup:
 li a7, SYS_dup
     a88:	48a9                	li	a7,10
 ecall
     a8a:	00000073          	ecall
 ret
     a8e:	8082                	ret

0000000000000a90 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     a90:	48ad                	li	a7,11
 ecall
     a92:	00000073          	ecall
 ret
     a96:	8082                	ret

0000000000000a98 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     a98:	48b1                	li	a7,12
 ecall
     a9a:	00000073          	ecall
 ret
     a9e:	8082                	ret

0000000000000aa0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     aa0:	48b5                	li	a7,13
 ecall
     aa2:	00000073          	ecall
 ret
     aa6:	8082                	ret

0000000000000aa8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     aa8:	48b9                	li	a7,14
 ecall
     aaa:	00000073          	ecall
 ret
     aae:	8082                	ret

0000000000000ab0 <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
     ab0:	48d9                	li	a7,22
 ecall
     ab2:	00000073          	ecall
 ret
     ab6:	8082                	ret

0000000000000ab8 <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
     ab8:	48dd                	li	a7,23
 ecall
     aba:	00000073          	ecall
 ret
     abe:	8082                	ret

0000000000000ac0 <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
     ac0:	48e1                	li	a7,24
 ecall
     ac2:	00000073          	ecall
 ret
     ac6:	8082                	ret

0000000000000ac8 <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
     ac8:	48e5                	li	a7,25
 ecall
     aca:	00000073          	ecall
 ret
     ace:	8082                	ret

0000000000000ad0 <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
     ad0:	48e9                	li	a7,26
 ecall
     ad2:	00000073          	ecall
 ret
     ad6:	8082                	ret

0000000000000ad8 <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
     ad8:	48ed                	li	a7,27
 ecall
     ada:	00000073          	ecall
 ret
     ade:	8082                	ret

0000000000000ae0 <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
     ae0:	48f1                	li	a7,28
 ecall
     ae2:	00000073          	ecall
 ret
     ae6:	8082                	ret

0000000000000ae8 <bsem_alloc>:
.global bsem_alloc
bsem_alloc:
 li a7, SYS_bsem_alloc
     ae8:	48f5                	li	a7,29
 ecall
     aea:	00000073          	ecall
 ret
     aee:	8082                	ret

0000000000000af0 <bsem_free>:
.global bsem_free
bsem_free:
 li a7, SYS_bsem_free
     af0:	48f9                	li	a7,30
 ecall
     af2:	00000073          	ecall
 ret
     af6:	8082                	ret

0000000000000af8 <bsem_down>:
.global bsem_down
bsem_down:
 li a7, SYS_bsem_down
     af8:	48fd                	li	a7,31
 ecall
     afa:	00000073          	ecall
 ret
     afe:	8082                	ret

0000000000000b00 <bsem_up>:
.global bsem_up
bsem_up:
 li a7, SYS_bsem_up
     b00:	02000893          	li	a7,32
 ecall
     b04:	00000073          	ecall
 ret
     b08:	8082                	ret

0000000000000b0a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     b0a:	1101                	addi	sp,sp,-32
     b0c:	ec06                	sd	ra,24(sp)
     b0e:	e822                	sd	s0,16(sp)
     b10:	1000                	addi	s0,sp,32
     b12:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     b16:	4605                	li	a2,1
     b18:	fef40593          	addi	a1,s0,-17
     b1c:	00000097          	auipc	ra,0x0
     b20:	f14080e7          	jalr	-236(ra) # a30 <write>
}
     b24:	60e2                	ld	ra,24(sp)
     b26:	6442                	ld	s0,16(sp)
     b28:	6105                	addi	sp,sp,32
     b2a:	8082                	ret

0000000000000b2c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     b2c:	7139                	addi	sp,sp,-64
     b2e:	fc06                	sd	ra,56(sp)
     b30:	f822                	sd	s0,48(sp)
     b32:	f426                	sd	s1,40(sp)
     b34:	f04a                	sd	s2,32(sp)
     b36:	ec4e                	sd	s3,24(sp)
     b38:	0080                	addi	s0,sp,64
     b3a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     b3c:	c299                	beqz	a3,b42 <printint+0x16>
     b3e:	0805c863          	bltz	a1,bce <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     b42:	2581                	sext.w	a1,a1
  neg = 0;
     b44:	4881                	li	a7,0
     b46:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     b4a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     b4c:	2601                	sext.w	a2,a2
     b4e:	00001517          	auipc	a0,0x1
     b52:	a0a50513          	addi	a0,a0,-1526 # 1558 <digits>
     b56:	883a                	mv	a6,a4
     b58:	2705                	addiw	a4,a4,1
     b5a:	02c5f7bb          	remuw	a5,a1,a2
     b5e:	1782                	slli	a5,a5,0x20
     b60:	9381                	srli	a5,a5,0x20
     b62:	97aa                	add	a5,a5,a0
     b64:	0007c783          	lbu	a5,0(a5)
     b68:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     b6c:	0005879b          	sext.w	a5,a1
     b70:	02c5d5bb          	divuw	a1,a1,a2
     b74:	0685                	addi	a3,a3,1
     b76:	fec7f0e3          	bgeu	a5,a2,b56 <printint+0x2a>
  if(neg)
     b7a:	00088b63          	beqz	a7,b90 <printint+0x64>
    buf[i++] = '-';
     b7e:	fd040793          	addi	a5,s0,-48
     b82:	973e                	add	a4,a4,a5
     b84:	02d00793          	li	a5,45
     b88:	fef70823          	sb	a5,-16(a4)
     b8c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     b90:	02e05863          	blez	a4,bc0 <printint+0x94>
     b94:	fc040793          	addi	a5,s0,-64
     b98:	00e78933          	add	s2,a5,a4
     b9c:	fff78993          	addi	s3,a5,-1
     ba0:	99ba                	add	s3,s3,a4
     ba2:	377d                	addiw	a4,a4,-1
     ba4:	1702                	slli	a4,a4,0x20
     ba6:	9301                	srli	a4,a4,0x20
     ba8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     bac:	fff94583          	lbu	a1,-1(s2)
     bb0:	8526                	mv	a0,s1
     bb2:	00000097          	auipc	ra,0x0
     bb6:	f58080e7          	jalr	-168(ra) # b0a <putc>
  while(--i >= 0)
     bba:	197d                	addi	s2,s2,-1
     bbc:	ff3918e3          	bne	s2,s3,bac <printint+0x80>
}
     bc0:	70e2                	ld	ra,56(sp)
     bc2:	7442                	ld	s0,48(sp)
     bc4:	74a2                	ld	s1,40(sp)
     bc6:	7902                	ld	s2,32(sp)
     bc8:	69e2                	ld	s3,24(sp)
     bca:	6121                	addi	sp,sp,64
     bcc:	8082                	ret
    x = -xx;
     bce:	40b005bb          	negw	a1,a1
    neg = 1;
     bd2:	4885                	li	a7,1
    x = -xx;
     bd4:	bf8d                	j	b46 <printint+0x1a>

0000000000000bd6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     bd6:	7119                	addi	sp,sp,-128
     bd8:	fc86                	sd	ra,120(sp)
     bda:	f8a2                	sd	s0,112(sp)
     bdc:	f4a6                	sd	s1,104(sp)
     bde:	f0ca                	sd	s2,96(sp)
     be0:	ecce                	sd	s3,88(sp)
     be2:	e8d2                	sd	s4,80(sp)
     be4:	e4d6                	sd	s5,72(sp)
     be6:	e0da                	sd	s6,64(sp)
     be8:	fc5e                	sd	s7,56(sp)
     bea:	f862                	sd	s8,48(sp)
     bec:	f466                	sd	s9,40(sp)
     bee:	f06a                	sd	s10,32(sp)
     bf0:	ec6e                	sd	s11,24(sp)
     bf2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     bf4:	0005c903          	lbu	s2,0(a1)
     bf8:	18090f63          	beqz	s2,d96 <vprintf+0x1c0>
     bfc:	8aaa                	mv	s5,a0
     bfe:	8b32                	mv	s6,a2
     c00:	00158493          	addi	s1,a1,1
  state = 0;
     c04:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     c06:	02500a13          	li	s4,37
      if(c == 'd'){
     c0a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
     c0e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
     c12:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
     c16:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     c1a:	00001b97          	auipc	s7,0x1
     c1e:	93eb8b93          	addi	s7,s7,-1730 # 1558 <digits>
     c22:	a839                	j	c40 <vprintf+0x6a>
        putc(fd, c);
     c24:	85ca                	mv	a1,s2
     c26:	8556                	mv	a0,s5
     c28:	00000097          	auipc	ra,0x0
     c2c:	ee2080e7          	jalr	-286(ra) # b0a <putc>
     c30:	a019                	j	c36 <vprintf+0x60>
    } else if(state == '%'){
     c32:	01498f63          	beq	s3,s4,c50 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
     c36:	0485                	addi	s1,s1,1
     c38:	fff4c903          	lbu	s2,-1(s1)
     c3c:	14090d63          	beqz	s2,d96 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
     c40:	0009079b          	sext.w	a5,s2
    if(state == 0){
     c44:	fe0997e3          	bnez	s3,c32 <vprintf+0x5c>
      if(c == '%'){
     c48:	fd479ee3          	bne	a5,s4,c24 <vprintf+0x4e>
        state = '%';
     c4c:	89be                	mv	s3,a5
     c4e:	b7e5                	j	c36 <vprintf+0x60>
      if(c == 'd'){
     c50:	05878063          	beq	a5,s8,c90 <vprintf+0xba>
      } else if(c == 'l') {
     c54:	05978c63          	beq	a5,s9,cac <vprintf+0xd6>
      } else if(c == 'x') {
     c58:	07a78863          	beq	a5,s10,cc8 <vprintf+0xf2>
      } else if(c == 'p') {
     c5c:	09b78463          	beq	a5,s11,ce4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
     c60:	07300713          	li	a4,115
     c64:	0ce78663          	beq	a5,a4,d30 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
     c68:	06300713          	li	a4,99
     c6c:	0ee78e63          	beq	a5,a4,d68 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
     c70:	11478863          	beq	a5,s4,d80 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
     c74:	85d2                	mv	a1,s4
     c76:	8556                	mv	a0,s5
     c78:	00000097          	auipc	ra,0x0
     c7c:	e92080e7          	jalr	-366(ra) # b0a <putc>
        putc(fd, c);
     c80:	85ca                	mv	a1,s2
     c82:	8556                	mv	a0,s5
     c84:	00000097          	auipc	ra,0x0
     c88:	e86080e7          	jalr	-378(ra) # b0a <putc>
      }
      state = 0;
     c8c:	4981                	li	s3,0
     c8e:	b765                	j	c36 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
     c90:	008b0913          	addi	s2,s6,8
     c94:	4685                	li	a3,1
     c96:	4629                	li	a2,10
     c98:	000b2583          	lw	a1,0(s6)
     c9c:	8556                	mv	a0,s5
     c9e:	00000097          	auipc	ra,0x0
     ca2:	e8e080e7          	jalr	-370(ra) # b2c <printint>
     ca6:	8b4a                	mv	s6,s2
      state = 0;
     ca8:	4981                	li	s3,0
     caa:	b771                	j	c36 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
     cac:	008b0913          	addi	s2,s6,8
     cb0:	4681                	li	a3,0
     cb2:	4629                	li	a2,10
     cb4:	000b2583          	lw	a1,0(s6)
     cb8:	8556                	mv	a0,s5
     cba:	00000097          	auipc	ra,0x0
     cbe:	e72080e7          	jalr	-398(ra) # b2c <printint>
     cc2:	8b4a                	mv	s6,s2
      state = 0;
     cc4:	4981                	li	s3,0
     cc6:	bf85                	j	c36 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
     cc8:	008b0913          	addi	s2,s6,8
     ccc:	4681                	li	a3,0
     cce:	4641                	li	a2,16
     cd0:	000b2583          	lw	a1,0(s6)
     cd4:	8556                	mv	a0,s5
     cd6:	00000097          	auipc	ra,0x0
     cda:	e56080e7          	jalr	-426(ra) # b2c <printint>
     cde:	8b4a                	mv	s6,s2
      state = 0;
     ce0:	4981                	li	s3,0
     ce2:	bf91                	j	c36 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
     ce4:	008b0793          	addi	a5,s6,8
     ce8:	f8f43423          	sd	a5,-120(s0)
     cec:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
     cf0:	03000593          	li	a1,48
     cf4:	8556                	mv	a0,s5
     cf6:	00000097          	auipc	ra,0x0
     cfa:	e14080e7          	jalr	-492(ra) # b0a <putc>
  putc(fd, 'x');
     cfe:	85ea                	mv	a1,s10
     d00:	8556                	mv	a0,s5
     d02:	00000097          	auipc	ra,0x0
     d06:	e08080e7          	jalr	-504(ra) # b0a <putc>
     d0a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     d0c:	03c9d793          	srli	a5,s3,0x3c
     d10:	97de                	add	a5,a5,s7
     d12:	0007c583          	lbu	a1,0(a5)
     d16:	8556                	mv	a0,s5
     d18:	00000097          	auipc	ra,0x0
     d1c:	df2080e7          	jalr	-526(ra) # b0a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     d20:	0992                	slli	s3,s3,0x4
     d22:	397d                	addiw	s2,s2,-1
     d24:	fe0914e3          	bnez	s2,d0c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
     d28:	f8843b03          	ld	s6,-120(s0)
      state = 0;
     d2c:	4981                	li	s3,0
     d2e:	b721                	j	c36 <vprintf+0x60>
        s = va_arg(ap, char*);
     d30:	008b0993          	addi	s3,s6,8
     d34:	000b3903          	ld	s2,0(s6)
        if(s == 0)
     d38:	02090163          	beqz	s2,d5a <vprintf+0x184>
        while(*s != 0){
     d3c:	00094583          	lbu	a1,0(s2)
     d40:	c9a1                	beqz	a1,d90 <vprintf+0x1ba>
          putc(fd, *s);
     d42:	8556                	mv	a0,s5
     d44:	00000097          	auipc	ra,0x0
     d48:	dc6080e7          	jalr	-570(ra) # b0a <putc>
          s++;
     d4c:	0905                	addi	s2,s2,1
        while(*s != 0){
     d4e:	00094583          	lbu	a1,0(s2)
     d52:	f9e5                	bnez	a1,d42 <vprintf+0x16c>
        s = va_arg(ap, char*);
     d54:	8b4e                	mv	s6,s3
      state = 0;
     d56:	4981                	li	s3,0
     d58:	bdf9                	j	c36 <vprintf+0x60>
          s = "(null)";
     d5a:	00000917          	auipc	s2,0x0
     d5e:	7f690913          	addi	s2,s2,2038 # 1550 <csem_free+0x4a2>
        while(*s != 0){
     d62:	02800593          	li	a1,40
     d66:	bff1                	j	d42 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
     d68:	008b0913          	addi	s2,s6,8
     d6c:	000b4583          	lbu	a1,0(s6)
     d70:	8556                	mv	a0,s5
     d72:	00000097          	auipc	ra,0x0
     d76:	d98080e7          	jalr	-616(ra) # b0a <putc>
     d7a:	8b4a                	mv	s6,s2
      state = 0;
     d7c:	4981                	li	s3,0
     d7e:	bd65                	j	c36 <vprintf+0x60>
        putc(fd, c);
     d80:	85d2                	mv	a1,s4
     d82:	8556                	mv	a0,s5
     d84:	00000097          	auipc	ra,0x0
     d88:	d86080e7          	jalr	-634(ra) # b0a <putc>
      state = 0;
     d8c:	4981                	li	s3,0
     d8e:	b565                	j	c36 <vprintf+0x60>
        s = va_arg(ap, char*);
     d90:	8b4e                	mv	s6,s3
      state = 0;
     d92:	4981                	li	s3,0
     d94:	b54d                	j	c36 <vprintf+0x60>
    }
  }
}
     d96:	70e6                	ld	ra,120(sp)
     d98:	7446                	ld	s0,112(sp)
     d9a:	74a6                	ld	s1,104(sp)
     d9c:	7906                	ld	s2,96(sp)
     d9e:	69e6                	ld	s3,88(sp)
     da0:	6a46                	ld	s4,80(sp)
     da2:	6aa6                	ld	s5,72(sp)
     da4:	6b06                	ld	s6,64(sp)
     da6:	7be2                	ld	s7,56(sp)
     da8:	7c42                	ld	s8,48(sp)
     daa:	7ca2                	ld	s9,40(sp)
     dac:	7d02                	ld	s10,32(sp)
     dae:	6de2                	ld	s11,24(sp)
     db0:	6109                	addi	sp,sp,128
     db2:	8082                	ret

0000000000000db4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     db4:	715d                	addi	sp,sp,-80
     db6:	ec06                	sd	ra,24(sp)
     db8:	e822                	sd	s0,16(sp)
     dba:	1000                	addi	s0,sp,32
     dbc:	e010                	sd	a2,0(s0)
     dbe:	e414                	sd	a3,8(s0)
     dc0:	e818                	sd	a4,16(s0)
     dc2:	ec1c                	sd	a5,24(s0)
     dc4:	03043023          	sd	a6,32(s0)
     dc8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     dcc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     dd0:	8622                	mv	a2,s0
     dd2:	00000097          	auipc	ra,0x0
     dd6:	e04080e7          	jalr	-508(ra) # bd6 <vprintf>
}
     dda:	60e2                	ld	ra,24(sp)
     ddc:	6442                	ld	s0,16(sp)
     dde:	6161                	addi	sp,sp,80
     de0:	8082                	ret

0000000000000de2 <printf>:

void
printf(const char *fmt, ...)
{
     de2:	711d                	addi	sp,sp,-96
     de4:	ec06                	sd	ra,24(sp)
     de6:	e822                	sd	s0,16(sp)
     de8:	1000                	addi	s0,sp,32
     dea:	e40c                	sd	a1,8(s0)
     dec:	e810                	sd	a2,16(s0)
     dee:	ec14                	sd	a3,24(s0)
     df0:	f018                	sd	a4,32(s0)
     df2:	f41c                	sd	a5,40(s0)
     df4:	03043823          	sd	a6,48(s0)
     df8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     dfc:	00840613          	addi	a2,s0,8
     e00:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
     e04:	85aa                	mv	a1,a0
     e06:	4505                	li	a0,1
     e08:	00000097          	auipc	ra,0x0
     e0c:	dce080e7          	jalr	-562(ra) # bd6 <vprintf>
}
     e10:	60e2                	ld	ra,24(sp)
     e12:	6442                	ld	s0,16(sp)
     e14:	6125                	addi	sp,sp,96
     e16:	8082                	ret

0000000000000e18 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     e18:	1141                	addi	sp,sp,-16
     e1a:	e422                	sd	s0,8(sp)
     e1c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
     e1e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     e22:	00000797          	auipc	a5,0x0
     e26:	7be7b783          	ld	a5,1982(a5) # 15e0 <freep>
     e2a:	a805                	j	e5a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
     e2c:	4618                	lw	a4,8(a2)
     e2e:	9db9                	addw	a1,a1,a4
     e30:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
     e34:	6398                	ld	a4,0(a5)
     e36:	6318                	ld	a4,0(a4)
     e38:	fee53823          	sd	a4,-16(a0)
     e3c:	a091                	j	e80 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
     e3e:	ff852703          	lw	a4,-8(a0)
     e42:	9e39                	addw	a2,a2,a4
     e44:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
     e46:	ff053703          	ld	a4,-16(a0)
     e4a:	e398                	sd	a4,0(a5)
     e4c:	a099                	j	e92 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     e4e:	6398                	ld	a4,0(a5)
     e50:	00e7e463          	bltu	a5,a4,e58 <free+0x40>
     e54:	00e6ea63          	bltu	a3,a4,e68 <free+0x50>
{
     e58:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     e5a:	fed7fae3          	bgeu	a5,a3,e4e <free+0x36>
     e5e:	6398                	ld	a4,0(a5)
     e60:	00e6e463          	bltu	a3,a4,e68 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     e64:	fee7eae3          	bltu	a5,a4,e58 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
     e68:	ff852583          	lw	a1,-8(a0)
     e6c:	6390                	ld	a2,0(a5)
     e6e:	02059813          	slli	a6,a1,0x20
     e72:	01c85713          	srli	a4,a6,0x1c
     e76:	9736                	add	a4,a4,a3
     e78:	fae60ae3          	beq	a2,a4,e2c <free+0x14>
    bp->s.ptr = p->s.ptr;
     e7c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
     e80:	4790                	lw	a2,8(a5)
     e82:	02061593          	slli	a1,a2,0x20
     e86:	01c5d713          	srli	a4,a1,0x1c
     e8a:	973e                	add	a4,a4,a5
     e8c:	fae689e3          	beq	a3,a4,e3e <free+0x26>
  } else
    p->s.ptr = bp;
     e90:	e394                	sd	a3,0(a5)
  freep = p;
     e92:	00000717          	auipc	a4,0x0
     e96:	74f73723          	sd	a5,1870(a4) # 15e0 <freep>
}
     e9a:	6422                	ld	s0,8(sp)
     e9c:	0141                	addi	sp,sp,16
     e9e:	8082                	ret

0000000000000ea0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
     ea0:	7139                	addi	sp,sp,-64
     ea2:	fc06                	sd	ra,56(sp)
     ea4:	f822                	sd	s0,48(sp)
     ea6:	f426                	sd	s1,40(sp)
     ea8:	f04a                	sd	s2,32(sp)
     eaa:	ec4e                	sd	s3,24(sp)
     eac:	e852                	sd	s4,16(sp)
     eae:	e456                	sd	s5,8(sp)
     eb0:	e05a                	sd	s6,0(sp)
     eb2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
     eb4:	02051493          	slli	s1,a0,0x20
     eb8:	9081                	srli	s1,s1,0x20
     eba:	04bd                	addi	s1,s1,15
     ebc:	8091                	srli	s1,s1,0x4
     ebe:	0014899b          	addiw	s3,s1,1
     ec2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
     ec4:	00000517          	auipc	a0,0x0
     ec8:	71c53503          	ld	a0,1820(a0) # 15e0 <freep>
     ecc:	c515                	beqz	a0,ef8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
     ece:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
     ed0:	4798                	lw	a4,8(a5)
     ed2:	02977f63          	bgeu	a4,s1,f10 <malloc+0x70>
     ed6:	8a4e                	mv	s4,s3
     ed8:	0009871b          	sext.w	a4,s3
     edc:	6685                	lui	a3,0x1
     ede:	00d77363          	bgeu	a4,a3,ee4 <malloc+0x44>
     ee2:	6a05                	lui	s4,0x1
     ee4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
     ee8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
     eec:	00000917          	auipc	s2,0x0
     ef0:	6f490913          	addi	s2,s2,1780 # 15e0 <freep>
  if(p == (char*)-1)
     ef4:	5afd                	li	s5,-1
     ef6:	a895                	j	f6a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
     ef8:	00000797          	auipc	a5,0x0
     efc:	6f078793          	addi	a5,a5,1776 # 15e8 <base>
     f00:	00000717          	auipc	a4,0x0
     f04:	6ef73023          	sd	a5,1760(a4) # 15e0 <freep>
     f08:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
     f0a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
     f0e:	b7e1                	j	ed6 <malloc+0x36>
      if(p->s.size == nunits)
     f10:	02e48c63          	beq	s1,a4,f48 <malloc+0xa8>
        p->s.size -= nunits;
     f14:	4137073b          	subw	a4,a4,s3
     f18:	c798                	sw	a4,8(a5)
        p += p->s.size;
     f1a:	02071693          	slli	a3,a4,0x20
     f1e:	01c6d713          	srli	a4,a3,0x1c
     f22:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
     f24:	0137a423          	sw	s3,8(a5)
      freep = prevp;
     f28:	00000717          	auipc	a4,0x0
     f2c:	6aa73c23          	sd	a0,1720(a4) # 15e0 <freep>
      return (void*)(p + 1);
     f30:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
     f34:	70e2                	ld	ra,56(sp)
     f36:	7442                	ld	s0,48(sp)
     f38:	74a2                	ld	s1,40(sp)
     f3a:	7902                	ld	s2,32(sp)
     f3c:	69e2                	ld	s3,24(sp)
     f3e:	6a42                	ld	s4,16(sp)
     f40:	6aa2                	ld	s5,8(sp)
     f42:	6b02                	ld	s6,0(sp)
     f44:	6121                	addi	sp,sp,64
     f46:	8082                	ret
        prevp->s.ptr = p->s.ptr;
     f48:	6398                	ld	a4,0(a5)
     f4a:	e118                	sd	a4,0(a0)
     f4c:	bff1                	j	f28 <malloc+0x88>
  hp->s.size = nu;
     f4e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
     f52:	0541                	addi	a0,a0,16
     f54:	00000097          	auipc	ra,0x0
     f58:	ec4080e7          	jalr	-316(ra) # e18 <free>
  return freep;
     f5c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
     f60:	d971                	beqz	a0,f34 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
     f62:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
     f64:	4798                	lw	a4,8(a5)
     f66:	fa9775e3          	bgeu	a4,s1,f10 <malloc+0x70>
    if(p == freep)
     f6a:	00093703          	ld	a4,0(s2)
     f6e:	853e                	mv	a0,a5
     f70:	fef719e3          	bne	a4,a5,f62 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
     f74:	8552                	mv	a0,s4
     f76:	00000097          	auipc	ra,0x0
     f7a:	b22080e7          	jalr	-1246(ra) # a98 <sbrk>
  if(p == (char*)-1)
     f7e:	fd5518e3          	bne	a0,s5,f4e <malloc+0xae>
        return 0;
     f82:	4501                	li	a0,0
     f84:	bf45                	j	f34 <malloc+0x94>

0000000000000f86 <csem_down>:
#include "Csemaphore.h"

struct counting_semaphore;

void 
csem_down(struct counting_semaphore *sem){
     f86:	1101                	addi	sp,sp,-32
     f88:	ec06                	sd	ra,24(sp)
     f8a:	e822                	sd	s0,16(sp)
     f8c:	e426                	sd	s1,8(sp)
     f8e:	1000                	addi	s0,sp,32
    if(!sem){
     f90:	cd29                	beqz	a0,fea <csem_down+0x64>
     f92:	84aa                	mv	s1,a0
        printf("invalid sem pointer in csem_down\n");
        return;
    }
    
    bsem_down(sem->S1_desc);   //TODO: make sure works
     f94:	4108                	lw	a0,0(a0)
     f96:	00000097          	auipc	ra,0x0
     f9a:	b62080e7          	jalr	-1182(ra) # af8 <bsem_down>
    sem->waiting++;
     f9e:	44dc                	lw	a5,12(s1)
     fa0:	2785                	addiw	a5,a5,1
     fa2:	c4dc                	sw	a5,12(s1)
    bsem_up(sem->S1_desc);
     fa4:	4088                	lw	a0,0(s1)
     fa6:	00000097          	auipc	ra,0x0
     faa:	b5a080e7          	jalr	-1190(ra) # b00 <bsem_up>

    bsem_down(sem->S2_desc);
     fae:	40c8                	lw	a0,4(s1)
     fb0:	00000097          	auipc	ra,0x0
     fb4:	b48080e7          	jalr	-1208(ra) # af8 <bsem_down>
    bsem_down(sem->S1_desc);
     fb8:	4088                	lw	a0,0(s1)
     fba:	00000097          	auipc	ra,0x0
     fbe:	b3e080e7          	jalr	-1218(ra) # af8 <bsem_down>
    sem->waiting--;
     fc2:	44dc                	lw	a5,12(s1)
     fc4:	37fd                	addiw	a5,a5,-1
     fc6:	c4dc                	sw	a5,12(s1)
    sem->value--;
     fc8:	449c                	lw	a5,8(s1)
     fca:	37fd                	addiw	a5,a5,-1
     fcc:	0007871b          	sext.w	a4,a5
     fd0:	c49c                	sw	a5,8(s1)
    if(sem->value > 0)
     fd2:	02e04563          	bgtz	a4,ffc <csem_down+0x76>
        bsem_up(sem->S2_desc);
    bsem_up(sem->S1_desc);
     fd6:	4088                	lw	a0,0(s1)
     fd8:	00000097          	auipc	ra,0x0
     fdc:	b28080e7          	jalr	-1240(ra) # b00 <bsem_up>

}
     fe0:	60e2                	ld	ra,24(sp)
     fe2:	6442                	ld	s0,16(sp)
     fe4:	64a2                	ld	s1,8(sp)
     fe6:	6105                	addi	sp,sp,32
     fe8:	8082                	ret
        printf("invalid sem pointer in csem_down\n");
     fea:	00000517          	auipc	a0,0x0
     fee:	58650513          	addi	a0,a0,1414 # 1570 <digits+0x18>
     ff2:	00000097          	auipc	ra,0x0
     ff6:	df0080e7          	jalr	-528(ra) # de2 <printf>
        return;
     ffa:	b7dd                	j	fe0 <csem_down+0x5a>
        bsem_up(sem->S2_desc);
     ffc:	40c8                	lw	a0,4(s1)
     ffe:	00000097          	auipc	ra,0x0
    1002:	b02080e7          	jalr	-1278(ra) # b00 <bsem_up>
    1006:	bfc1                	j	fd6 <csem_down+0x50>

0000000000001008 <csem_up>:

void            
csem_up(struct counting_semaphore *sem){
    1008:	1101                	addi	sp,sp,-32
    100a:	ec06                	sd	ra,24(sp)
    100c:	e822                	sd	s0,16(sp)
    100e:	e426                	sd	s1,8(sp)
    1010:	1000                	addi	s0,sp,32
    if(!sem){
    1012:	c90d                	beqz	a0,1044 <csem_up+0x3c>
    1014:	84aa                	mv	s1,a0
        printf("invalid sem pointer in csem_up\n");
        return;
    }

    bsem_down(sem->S1_desc);
    1016:	4108                	lw	a0,0(a0)
    1018:	00000097          	auipc	ra,0x0
    101c:	ae0080e7          	jalr	-1312(ra) # af8 <bsem_down>
    sem->value++;
    1020:	449c                	lw	a5,8(s1)
    1022:	2785                	addiw	a5,a5,1
    1024:	0007871b          	sext.w	a4,a5
    1028:	c49c                	sw	a5,8(s1)
    if(sem->value == 1)
    102a:	4785                	li	a5,1
    102c:	02f70563          	beq	a4,a5,1056 <csem_up+0x4e>
        bsem_up(sem->S2_desc);
    bsem_up(sem->S1_desc);
    1030:	4088                	lw	a0,0(s1)
    1032:	00000097          	auipc	ra,0x0
    1036:	ace080e7          	jalr	-1330(ra) # b00 <bsem_up>
}
    103a:	60e2                	ld	ra,24(sp)
    103c:	6442                	ld	s0,16(sp)
    103e:	64a2                	ld	s1,8(sp)
    1040:	6105                	addi	sp,sp,32
    1042:	8082                	ret
        printf("invalid sem pointer in csem_up\n");
    1044:	00000517          	auipc	a0,0x0
    1048:	55450513          	addi	a0,a0,1364 # 1598 <digits+0x40>
    104c:	00000097          	auipc	ra,0x0
    1050:	d96080e7          	jalr	-618(ra) # de2 <printf>
        return;
    1054:	b7dd                	j	103a <csem_up+0x32>
        bsem_up(sem->S2_desc);
    1056:	40c8                	lw	a0,4(s1)
    1058:	00000097          	auipc	ra,0x0
    105c:	aa8080e7          	jalr	-1368(ra) # b00 <bsem_up>
    1060:	bfc1                	j	1030 <csem_up+0x28>

0000000000001062 <csem_alloc>:


int             
csem_alloc(struct counting_semaphore *sem, int initial_value){
    1062:	1101                	addi	sp,sp,-32
    1064:	ec06                	sd	ra,24(sp)
    1066:	e822                	sd	s0,16(sp)
    1068:	e426                	sd	s1,8(sp)
    106a:	e04a                	sd	s2,0(sp)
    106c:	1000                	addi	s0,sp,32
    106e:	84aa                	mv	s1,a0
    1070:	892e                	mv	s2,a1
    sem->S1_desc = bsem_alloc();
    1072:	00000097          	auipc	ra,0x0
    1076:	a76080e7          	jalr	-1418(ra) # ae8 <bsem_alloc>
    107a:	c088                	sw	a0,0(s1)
    sem->S2_desc = bsem_alloc();
    107c:	00000097          	auipc	ra,0x0
    1080:	a6c080e7          	jalr	-1428(ra) # ae8 <bsem_alloc>
    1084:	c0c8                	sw	a0,4(s1)
    if(sem->S1_desc <0 || sem->S2_desc < 0)
    1086:	409c                	lw	a5,0(s1)
    1088:	0007cf63          	bltz	a5,10a6 <csem_alloc+0x44>
    108c:	00054f63          	bltz	a0,10aa <csem_alloc+0x48>
        return -1;
    sem->value = initial_value;
    1090:	0124a423          	sw	s2,8(s1)
    sem->waiting = 0;
    1094:	0004a623          	sw	zero,12(s1)

    return 0;
    1098:	4501                	li	a0,0
}
    109a:	60e2                	ld	ra,24(sp)
    109c:	6442                	ld	s0,16(sp)
    109e:	64a2                	ld	s1,8(sp)
    10a0:	6902                	ld	s2,0(sp)
    10a2:	6105                	addi	sp,sp,32
    10a4:	8082                	ret
        return -1;
    10a6:	557d                	li	a0,-1
    10a8:	bfcd                	j	109a <csem_alloc+0x38>
    10aa:	557d                	li	a0,-1
    10ac:	b7fd                	j	109a <csem_alloc+0x38>

00000000000010ae <csem_free>:
void            
csem_free(struct counting_semaphore *sem){
    10ae:	1101                	addi	sp,sp,-32
    10b0:	ec06                	sd	ra,24(sp)
    10b2:	e822                	sd	s0,16(sp)
    10b4:	e426                	sd	s1,8(sp)
    10b6:	1000                	addi	s0,sp,32
    if(!sem){
    10b8:	c10d                	beqz	a0,10da <csem_free+0x2c>
    10ba:	84aa                	mv	s1,a0
        printf("invalid sem pointer in csem_free\n");
        return;
    }

    bsem_free(sem->S1_desc);
    10bc:	4108                	lw	a0,0(a0)
    10be:	00000097          	auipc	ra,0x0
    10c2:	a32080e7          	jalr	-1486(ra) # af0 <bsem_free>
    bsem_free(sem->S2_desc);
    10c6:	40c8                	lw	a0,4(s1)
    10c8:	00000097          	auipc	ra,0x0
    10cc:	a28080e7          	jalr	-1496(ra) # af0 <bsem_free>

    10d0:	60e2                	ld	ra,24(sp)
    10d2:	6442                	ld	s0,16(sp)
    10d4:	64a2                	ld	s1,8(sp)
    10d6:	6105                	addi	sp,sp,32
    10d8:	8082                	ret
        printf("invalid sem pointer in csem_free\n");
    10da:	00000517          	auipc	a0,0x0
    10de:	4de50513          	addi	a0,a0,1246 # 15b8 <digits+0x60>
    10e2:	00000097          	auipc	ra,0x0
    10e6:	d00080e7          	jalr	-768(ra) # de2 <printf>
        return;
    10ea:	b7dd                	j	10d0 <csem_free+0x22>
