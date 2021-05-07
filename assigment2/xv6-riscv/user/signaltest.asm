
user/_signaltest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_thread>:
void test_thread();
void test_thread2();
void test_thread_loop();


void test_thread(){
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
    sleep(5);
       8:	4515                	li	a0,5
       a:	00001097          	auipc	ra,0x1
       e:	cb4080e7          	jalr	-844(ra) # cbe <sleep>
    printf("Thread is now running tid=%d\n",kthread_id());
      12:	00001097          	auipc	ra,0x1
      16:	cdc080e7          	jalr	-804(ra) # cee <kthread_id>
      1a:	85aa                	mv	a1,a0
      1c:	00001517          	auipc	a0,0x1
      20:	16c50513          	addi	a0,a0,364 # 1188 <malloc+0xec>
      24:	00001097          	auipc	ra,0x1
      28:	fba080e7          	jalr	-70(ra) # fde <printf>
    kthread_exit(9);
      2c:	4525                	li	a0,9
      2e:	00001097          	auipc	ra,0x1
      32:	cc8080e7          	jalr	-824(ra) # cf6 <kthread_exit>
}
      36:	60a2                	ld	ra,8(sp)
      38:	6402                	ld	s0,0(sp)
      3a:	0141                	addi	sp,sp,16
      3c:	8082                	ret

000000000000003e <test_thread_loop>:
void test_thread_loop(){
      3e:	7179                	addi	sp,sp,-48
      40:	f406                	sd	ra,40(sp)
      42:	f022                	sd	s0,32(sp)
      44:	ec26                	sd	s1,24(sp)
      46:	e84a                	sd	s2,16(sp)
      48:	e44e                	sd	s3,8(sp)
      4a:	1800                	addi	s0,sp,48
    sleep(5);
      4c:	4515                	li	a0,5
      4e:	00001097          	auipc	ra,0x1
      52:	c70080e7          	jalr	-912(ra) # cbe <sleep>
    for(int i=0;i<100;i++){
      56:	4481                	li	s1,0
        printf("%d:Thread is now running tid=%d\n",i,kthread_id());
      58:	00001997          	auipc	s3,0x1
      5c:	15098993          	addi	s3,s3,336 # 11a8 <malloc+0x10c>
    for(int i=0;i<100;i++){
      60:	06400913          	li	s2,100
        printf("%d:Thread is now running tid=%d\n",i,kthread_id());
      64:	00001097          	auipc	ra,0x1
      68:	c8a080e7          	jalr	-886(ra) # cee <kthread_id>
      6c:	862a                	mv	a2,a0
      6e:	85a6                	mv	a1,s1
      70:	854e                	mv	a0,s3
      72:	00001097          	auipc	ra,0x1
      76:	f6c080e7          	jalr	-148(ra) # fde <printf>
    for(int i=0;i<100;i++){
      7a:	2485                	addiw	s1,s1,1
      7c:	ff2494e3          	bne	s1,s2,64 <test_thread_loop+0x26>
    }
    kthread_exit(9);
      80:	4525                	li	a0,9
      82:	00001097          	auipc	ra,0x1
      86:	c74080e7          	jalr	-908(ra) # cf6 <kthread_exit>
}
      8a:	70a2                	ld	ra,40(sp)
      8c:	7402                	ld	s0,32(sp)
      8e:	64e2                	ld	s1,24(sp)
      90:	6942                	ld	s2,16(sp)
      92:	69a2                	ld	s3,8(sp)
      94:	6145                	addi	sp,sp,48
      96:	8082                	ret

0000000000000098 <test_thread2>:
void test_thread2(){
      98:	1141                	addi	sp,sp,-16
      9a:	e406                	sd	ra,8(sp)
      9c:	e022                	sd	s0,0(sp)
      9e:	0800                	addi	s0,sp,16
    sleep(5);
      a0:	4515                	li	a0,5
      a2:	00001097          	auipc	ra,0x1
      a6:	c1c080e7          	jalr	-996(ra) # cbe <sleep>
    printf("Thread is now running tid=%d\n",kthread_id());
      aa:	00001097          	auipc	ra,0x1
      ae:	c44080e7          	jalr	-956(ra) # cee <kthread_id>
      b2:	85aa                	mv	a1,a0
      b4:	00001517          	auipc	a0,0x1
      b8:	0d450513          	addi	a0,a0,212 # 1188 <malloc+0xec>
      bc:	00001097          	auipc	ra,0x1
      c0:	f22080e7          	jalr	-222(ra) # fde <printf>
    kthread_exit(9);
      c4:	4525                	li	a0,9
      c6:	00001097          	auipc	ra,0x1
      ca:	c30080e7          	jalr	-976(ra) # cf6 <kthread_exit>
}
      ce:	60a2                	ld	ra,8(sp)
      d0:	6402                	ld	s0,0(sp)
      d2:	0141                	addi	sp,sp,16
      d4:	8082                	ret

00000000000000d6 <sig_handler_loop>:
    write(1, st, 5);
    return;
}

void
sig_handler_loop(int signum){
      d6:	7179                	addi	sp,sp,-48
      d8:	f406                	sd	ra,40(sp)
      da:	f022                	sd	s0,32(sp)
      dc:	ec26                	sd	s1,24(sp)
      de:	1800                	addi	s0,sp,48
    char st[5] = "dap\n";
      e0:	0a7067b7          	lui	a5,0xa706
      e4:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa70427b>
      e8:	fcf42c23          	sw	a5,-40(s0)
      ec:	fc040e23          	sb	zero,-36(s0)
      f0:	1f400493          	li	s1,500
    for(int i=0;i<500;i++){
        write(1, st, 5);
      f4:	4615                	li	a2,5
      f6:	fd840593          	addi	a1,s0,-40
      fa:	4505                	li	a0,1
      fc:	00001097          	auipc	ra,0x1
     100:	b52080e7          	jalr	-1198(ra) # c4e <write>
    for(int i=0;i<500;i++){
     104:	34fd                	addiw	s1,s1,-1
     106:	f4fd                	bnez	s1,f4 <sig_handler_loop+0x1e>
    }
    
    return;
}
     108:	70a2                	ld	ra,40(sp)
     10a:	7402                	ld	s0,32(sp)
     10c:	64e2                	ld	s1,24(sp)
     10e:	6145                	addi	sp,sp,48
     110:	8082                	ret

0000000000000112 <sig_handler_loop2>:
void
sig_handler_loop2(int signum){
     112:	7179                	addi	sp,sp,-48
     114:	f406                	sd	ra,40(sp)
     116:	f022                	sd	s0,32(sp)
     118:	ec26                	sd	s1,24(sp)
     11a:	1800                	addi	s0,sp,48
    char st[5] = "dap\n";
     11c:	0a7067b7          	lui	a5,0xa706
     120:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa70427b>
     124:	fcf42c23          	sw	a5,-40(s0)
     128:	fc040e23          	sb	zero,-36(s0)
     12c:	1f400493          	li	s1,500
    for(int i=0;i<500;i++){
        write(1, st, 5);
     130:	4615                	li	a2,5
     132:	fd840593          	addi	a1,s0,-40
     136:	4505                	li	a0,1
     138:	00001097          	auipc	ra,0x1
     13c:	b16080e7          	jalr	-1258(ra) # c4e <write>
    for(int i=0;i<500;i++){
     140:	34fd                	addiw	s1,s1,-1
     142:	f4fd                	bnez	s1,130 <sig_handler_loop2+0x1e>
    }
    
    return;
}
     144:	70a2                	ld	ra,40(sp)
     146:	7402                	ld	s0,32(sp)
     148:	64e2                	ld	s1,24(sp)
     14a:	6145                	addi	sp,sp,48
     14c:	8082                	ret

000000000000014e <sig_handler2>:
void
sig_handler2(int signum){
     14e:	1101                	addi	sp,sp,-32
     150:	ec06                	sd	ra,24(sp)
     152:	e822                	sd	s0,16(sp)
     154:	1000                	addi	s0,sp,32
    char st[5] = "dap\n";
     156:	0a7067b7          	lui	a5,0xa706
     15a:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa70427b>
     15e:	fef42423          	sw	a5,-24(s0)
     162:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
     166:	4615                	li	a2,5
     168:	fe840593          	addi	a1,s0,-24
     16c:	4505                	li	a0,1
     16e:	00001097          	auipc	ra,0x1
     172:	ae0080e7          	jalr	-1312(ra) # c4e <write>
    return;
}
     176:	60e2                	ld	ra,24(sp)
     178:	6442                	ld	s0,16(sp)
     17a:	6105                	addi	sp,sp,32
     17c:	8082                	ret

000000000000017e <test_sigkill>:
test_sigkill(){//
     17e:	7179                	addi	sp,sp,-48
     180:	f406                	sd	ra,40(sp)
     182:	f022                	sd	s0,32(sp)
     184:	ec26                	sd	s1,24(sp)
     186:	e84a                	sd	s2,16(sp)
     188:	e44e                	sd	s3,8(sp)
     18a:	1800                	addi	s0,sp,48
   int pid = fork();
     18c:	00001097          	auipc	ra,0x1
     190:	a9a080e7          	jalr	-1382(ra) # c26 <fork>
     194:	84aa                	mv	s1,a0
    if(pid==0){
     196:	ed05                	bnez	a0,1ce <test_sigkill+0x50>
        sleep(5);
     198:	4515                	li	a0,5
     19a:	00001097          	auipc	ra,0x1
     19e:	b24080e7          	jalr	-1244(ra) # cbe <sleep>
            printf("about to get killed %d\n",i);
     1a2:	00001997          	auipc	s3,0x1
     1a6:	02e98993          	addi	s3,s3,46 # 11d0 <malloc+0x134>
        for(int i=0;i<300;i++)
     1aa:	12c00913          	li	s2,300
            printf("about to get killed %d\n",i);
     1ae:	85a6                	mv	a1,s1
     1b0:	854e                	mv	a0,s3
     1b2:	00001097          	auipc	ra,0x1
     1b6:	e2c080e7          	jalr	-468(ra) # fde <printf>
        for(int i=0;i<300;i++)
     1ba:	2485                	addiw	s1,s1,1
     1bc:	ff2499e3          	bne	s1,s2,1ae <test_sigkill+0x30>
}
     1c0:	70a2                	ld	ra,40(sp)
     1c2:	7402                	ld	s0,32(sp)
     1c4:	64e2                	ld	s1,24(sp)
     1c6:	6942                	ld	s2,16(sp)
     1c8:	69a2                	ld	s3,8(sp)
     1ca:	6145                	addi	sp,sp,48
     1cc:	8082                	ret
        sleep(7);
     1ce:	451d                	li	a0,7
     1d0:	00001097          	auipc	ra,0x1
     1d4:	aee080e7          	jalr	-1298(ra) # cbe <sleep>
        printf("parent send signal to to kill child\n");
     1d8:	00001517          	auipc	a0,0x1
     1dc:	01050513          	addi	a0,a0,16 # 11e8 <malloc+0x14c>
     1e0:	00001097          	auipc	ra,0x1
     1e4:	dfe080e7          	jalr	-514(ra) # fde <printf>
        printf("kill ret= %d\n",kill(pid, SIGKILL));
     1e8:	45a5                	li	a1,9
     1ea:	8526                	mv	a0,s1
     1ec:	00001097          	auipc	ra,0x1
     1f0:	a72080e7          	jalr	-1422(ra) # c5e <kill>
     1f4:	85aa                	mv	a1,a0
     1f6:	00001517          	auipc	a0,0x1
     1fa:	01a50513          	addi	a0,a0,26 # 1210 <malloc+0x174>
     1fe:	00001097          	auipc	ra,0x1
     202:	de0080e7          	jalr	-544(ra) # fde <printf>
        printf("parent wait for child\n");
     206:	00001517          	auipc	a0,0x1
     20a:	01a50513          	addi	a0,a0,26 # 1220 <malloc+0x184>
     20e:	00001097          	auipc	ra,0x1
     212:	dd0080e7          	jalr	-560(ra) # fde <printf>
        wait(0);
     216:	4501                	li	a0,0
     218:	00001097          	auipc	ra,0x1
     21c:	a1e080e7          	jalr	-1506(ra) # c36 <wait>
        printf("parent: child is dead\n");
     220:	00001517          	auipc	a0,0x1
     224:	01850513          	addi	a0,a0,24 # 1238 <malloc+0x19c>
     228:	00001097          	auipc	ra,0x1
     22c:	db6080e7          	jalr	-586(ra) # fde <printf>
        sleep(10);
     230:	4529                	li	a0,10
     232:	00001097          	auipc	ra,0x1
     236:	a8c080e7          	jalr	-1396(ra) # cbe <sleep>
        exit(0);
     23a:	4501                	li	a0,0
     23c:	00001097          	auipc	ra,0x1
     240:	9f2080e7          	jalr	-1550(ra) # c2e <exit>

0000000000000244 <sig_handler>:
sig_handler(int signum){
     244:	1101                	addi	sp,sp,-32
     246:	ec06                	sd	ra,24(sp)
     248:	e822                	sd	s0,16(sp)
     24a:	1000                	addi	s0,sp,32
    char st[5] = "wap\n";
     24c:	0a7067b7          	lui	a5,0xa706
     250:	17778793          	addi	a5,a5,375 # a706177 <__global_pointer$+0xa70428e>
     254:	fef42423          	sw	a5,-24(s0)
     258:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
     25c:	4615                	li	a2,5
     25e:	fe840593          	addi	a1,s0,-24
     262:	4505                	li	a0,1
     264:	00001097          	auipc	ra,0x1
     268:	9ea080e7          	jalr	-1558(ra) # c4e <write>
}
     26c:	60e2                	ld	ra,24(sp)
     26e:	6442                	ld	s0,16(sp)
     270:	6105                	addi	sp,sp,32
     272:	8082                	ret

0000000000000274 <test_usersig>:


void 
test_usersig(){
     274:	7139                	addi	sp,sp,-64
     276:	fc06                	sd	ra,56(sp)
     278:	f822                	sd	s0,48(sp)
     27a:	f426                	sd	s1,40(sp)
     27c:	f04a                	sd	s2,32(sp)
     27e:	0080                	addi	s0,sp,64
    int pid = fork();
     280:	00001097          	auipc	ra,0x1
     284:	9a6080e7          	jalr	-1626(ra) # c26 <fork>
    int signum1=3;
    if(pid==0){
     288:	e569                	bnez	a0,352 <test_usersig+0xde>
        struct sigaction act;
        // struct sigaction act2;

        printf("sighandler= %p\n",&sig_handler2);
     28a:	00000597          	auipc	a1,0x0
     28e:	ec458593          	addi	a1,a1,-316 # 14e <sig_handler2>
     292:	00001517          	auipc	a0,0x1
     296:	fbe50513          	addi	a0,a0,-66 # 1250 <malloc+0x1b4>
     29a:	00001097          	auipc	ra,0x1
     29e:	d44080e7          	jalr	-700(ra) # fde <printf>
        uint mask = 0;
        mask ^= (1<<22);

        act.sa_handler = &sig_handler2;
     2a2:	00000797          	auipc	a5,0x0
     2a6:	eac78793          	addi	a5,a5,-340 # 14e <sig_handler2>
     2aa:	fcf43023          	sd	a5,-64(s0)
        act.sigmask = mask;
     2ae:	004007b7          	lui	a5,0x400
     2b2:	fcf42423          	sw	a5,-56(s0)
        

        struct sigaction oldact;
        oldact.sigmask=0;
     2b6:	fc042c23          	sw	zero,-40(s0)
        oldact.sa_handler=0;
     2ba:	fc043823          	sd	zero,-48(s0)
        int ret=sigaction(signum1,&act,&oldact);
     2be:	fd040613          	addi	a2,s0,-48
     2c2:	fc040593          	addi	a1,s0,-64
     2c6:	450d                	li	a0,3
     2c8:	00001097          	auipc	ra,0x1
     2cc:	a0e080e7          	jalr	-1522(ra) # cd6 <sigaction>
     2d0:	84aa                	mv	s1,a0
        printf("old act->sa handler= %p, mask=%d\n",oldact.sa_handler,oldact.sigmask);
     2d2:	fd842603          	lw	a2,-40(s0)
     2d6:	fd043583          	ld	a1,-48(s0)
     2da:	00001517          	auipc	a0,0x1
     2de:	f8650513          	addi	a0,a0,-122 # 1260 <malloc+0x1c4>
     2e2:	00001097          	auipc	ra,0x1
     2e6:	cfc080e7          	jalr	-772(ra) # fde <printf>
        printf("child return from sigaction = %d\n",ret);
     2ea:	85a6                	mv	a1,s1
     2ec:	00001517          	auipc	a0,0x1
     2f0:	f9c50513          	addi	a0,a0,-100 # 1288 <malloc+0x1ec>
     2f4:	00001097          	auipc	ra,0x1
     2f8:	cea080e7          	jalr	-790(ra) # fde <printf>
        sleep(10);
     2fc:	4529                	li	a0,10
     2fe:	00001097          	auipc	ra,0x1
     302:	9c0080e7          	jalr	-1600(ra) # cbe <sleep>
     306:	44a9                	li	s1,10
        for(int i=0;i<10;i++){
            printf("child doing stuff before exit \n");
     308:	00001917          	auipc	s2,0x1
     30c:	fa890913          	addi	s2,s2,-88 # 12b0 <malloc+0x214>
     310:	854a                	mv	a0,s2
     312:	00001097          	auipc	ra,0x1
     316:	ccc080e7          	jalr	-820(ra) # fde <printf>
        for(int i=0;i<10;i++){
     31a:	34fd                	addiw	s1,s1,-1
     31c:	f8f5                	bnez	s1,310 <test_usersig+0x9c>
        }
        ret=sigaction(signum1,&act,&oldact);
     31e:	fd040613          	addi	a2,s0,-48
     322:	fc040593          	addi	a1,s0,-64
     326:	450d                	li	a0,3
     328:	00001097          	auipc	ra,0x1
     32c:	9ae080e7          	jalr	-1618(ra) # cd6 <sigaction>
        printf("oldact should be the same as new act before \n oldact->mask=%d \t oldact->sa_handler=%d \n",oldact.sigmask,oldact.sa_handler);
     330:	fd043603          	ld	a2,-48(s0)
     334:	fd842583          	lw	a1,-40(s0)
     338:	00001517          	auipc	a0,0x1
     33c:	f9850513          	addi	a0,a0,-104 # 12d0 <malloc+0x234>
     340:	00001097          	auipc	ra,0x1
     344:	c9e080e7          	jalr	-866(ra) # fde <printf>

        exit(0);
     348:	4501                	li	a0,0
     34a:	00001097          	auipc	ra,0x1
     34e:	8e4080e7          	jalr	-1820(ra) # c2e <exit>
     352:	84aa                	mv	s1,a0

    }
    else{
        sleep(5);
     354:	4515                	li	a0,5
     356:	00001097          	auipc	ra,0x1
     35a:	968080e7          	jalr	-1688(ra) # cbe <sleep>
        printf("parent send sig 3 to child ret=%d\n",kill(pid,signum1));
     35e:	458d                	li	a1,3
     360:	8526                	mv	a0,s1
     362:	00001097          	auipc	ra,0x1
     366:	8fc080e7          	jalr	-1796(ra) # c5e <kill>
     36a:	85aa                	mv	a1,a0
     36c:	00001517          	auipc	a0,0x1
     370:	fbc50513          	addi	a0,a0,-68 # 1328 <malloc+0x28c>
     374:	00001097          	auipc	ra,0x1
     378:	c6a080e7          	jalr	-918(ra) # fde <printf>
        // printf("parent send sig 4 to child ret=%d\n",kill(pid,4));

        wait(0);
     37c:	4501                	li	a0,0
     37e:	00001097          	auipc	ra,0x1
     382:	8b8080e7          	jalr	-1864(ra) # c36 <wait>
        exit(0);
     386:	4501                	li	a0,0
     388:	00001097          	auipc	ra,0x1
     38c:	8a6080e7          	jalr	-1882(ra) # c2e <exit>

0000000000000390 <test_block>:
    }
}
void 
test_block(){//parent block 22 child block 23 
     390:	7179                	addi	sp,sp,-48
     392:	f406                	sd	ra,40(sp)
     394:	f022                	sd	s0,32(sp)
     396:	ec26                	sd	s1,24(sp)
     398:	e84a                	sd	s2,16(sp)
     39a:	e44e                	sd	s3,8(sp)
     39c:	1800                	addi	s0,sp,48
//          child get both signal and need do block the both

    int signum1=22;
    int signum2=23;
    int ans=sigprocmask(1<<signum1);
     39e:	00400537          	lui	a0,0x400
     3a2:	00001097          	auipc	ra,0x1
     3a6:	92c080e7          	jalr	-1748(ra) # cce <sigprocmask>
    printf("got %d from calling to sigprocmask\n",ans);
     3aa:	0005059b          	sext.w	a1,a0
     3ae:	00001517          	auipc	a0,0x1
     3b2:	fa250513          	addi	a0,a0,-94 # 1350 <malloc+0x2b4>
     3b6:	00001097          	auipc	ra,0x1
     3ba:	c28080e7          	jalr	-984(ra) # fde <printf>
    int pid=fork();
     3be:	00001097          	auipc	ra,0x1
     3c2:	868080e7          	jalr	-1944(ra) # c26 <fork>
     3c6:	892a                	mv	s2,a0
    if(pid==0){
     3c8:	c535                	beqz	a0,434 <test_block+0xa4>
            printf("child blocking signal %d \n",i);
        }
        exit(0);

    }else{
        sleep(1);//wait for child to block sig
     3ca:	4505                	li	a0,1
     3cc:	00001097          	auipc	ra,0x1
     3d0:	8f2080e7          	jalr	-1806(ra) # cbe <sleep>
        printf("parent: sent signal 22 to child ->child shuld block\n");
     3d4:	00001517          	auipc	a0,0x1
     3d8:	fc450513          	addi	a0,a0,-60 # 1398 <malloc+0x2fc>
     3dc:	00001097          	auipc	ra,0x1
     3e0:	c02080e7          	jalr	-1022(ra) # fde <printf>
     3e4:	44a9                	li	s1,10
        for(int i=0; i<10;i++){
            kill(pid,signum1);
     3e6:	45d9                	li	a1,22
     3e8:	854a                	mv	a0,s2
     3ea:	00001097          	auipc	ra,0x1
     3ee:	874080e7          	jalr	-1932(ra) # c5e <kill>
        for(int i=0; i<10;i++){
     3f2:	34fd                	addiw	s1,s1,-1
     3f4:	f8ed                	bnez	s1,3e6 <test_block+0x56>
        }
        sleep(10);
     3f6:	4529                	li	a0,10
     3f8:	00001097          	auipc	ra,0x1
     3fc:	8c6080e7          	jalr	-1850(ra) # cbe <sleep>
        kill(pid,signum2);
     400:	45dd                	li	a1,23
     402:	854a                	mv	a0,s2
     404:	00001097          	auipc	ra,0x1
     408:	85a080e7          	jalr	-1958(ra) # c5e <kill>

        printf("parent: sent signal 23 to child ->child shuld die\n");
     40c:	00001517          	auipc	a0,0x1
     410:	fc450513          	addi	a0,a0,-60 # 13d0 <malloc+0x334>
     414:	00001097          	auipc	ra,0x1
     418:	bca080e7          	jalr	-1078(ra) # fde <printf>
        wait(0);
     41c:	4501                	li	a0,0
     41e:	00001097          	auipc	ra,0x1
     422:	818080e7          	jalr	-2024(ra) # c36 <wait>
    }
    // exit(0);
}
     426:	70a2                	ld	ra,40(sp)
     428:	7402                	ld	s0,32(sp)
     42a:	64e2                	ld	s1,24(sp)
     42c:	6942                	ld	s2,16(sp)
     42e:	69a2                	ld	s3,8(sp)
     430:	6145                	addi	sp,sp,48
     432:	8082                	ret
        sleep(3);
     434:	450d                	li	a0,3
     436:	00001097          	auipc	ra,0x1
     43a:	888080e7          	jalr	-1912(ra) # cbe <sleep>
            printf("child blocking signal %d \n",i);
     43e:	00001997          	auipc	s3,0x1
     442:	f3a98993          	addi	s3,s3,-198 # 1378 <malloc+0x2dc>
        for(int i=0;i<1000;i++){
     446:	3e800493          	li	s1,1000
            sleep(1);
     44a:	4505                	li	a0,1
     44c:	00001097          	auipc	ra,0x1
     450:	872080e7          	jalr	-1934(ra) # cbe <sleep>
            printf("child blocking signal %d \n",i);
     454:	85ca                	mv	a1,s2
     456:	854e                	mv	a0,s3
     458:	00001097          	auipc	ra,0x1
     45c:	b86080e7          	jalr	-1146(ra) # fde <printf>
        for(int i=0;i<1000;i++){
     460:	2905                	addiw	s2,s2,1
     462:	fe9914e3          	bne	s2,s1,44a <test_block+0xba>
        exit(0);
     466:	4501                	li	a0,0
     468:	00000097          	auipc	ra,0x0
     46c:	7c6080e7          	jalr	1990(ra) # c2e <exit>

0000000000000470 <test_stop_cont>:

void
test_stop_cont(){
     470:	7179                	addi	sp,sp,-48
     472:	f406                	sd	ra,40(sp)
     474:	f022                	sd	s0,32(sp)
     476:	ec26                	sd	s1,24(sp)
     478:	e84a                	sd	s2,16(sp)
     47a:	e44e                	sd	s3,8(sp)
     47c:	1800                	addi	s0,sp,48
    int pid = fork();
     47e:	00000097          	auipc	ra,0x0
     482:	7a8080e7          	jalr	1960(ra) # c26 <fork>
     486:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
     488:	e915                	bnez	a0,4bc <test_stop_cont+0x4c>
        sleep(2);
     48a:	4509                	li	a0,2
     48c:	00001097          	auipc	ra,0x1
     490:	832080e7          	jalr	-1998(ra) # cbe <sleep>
        for(i=0;i<500;i++){
            printf("%d\n ", i);
     494:	00001997          	auipc	s3,0x1
     498:	f7498993          	addi	s3,s3,-140 # 1408 <malloc+0x36c>
        for(i=0;i<500;i++){
     49c:	1f400913          	li	s2,500
            printf("%d\n ", i);
     4a0:	85a6                	mv	a1,s1
     4a2:	854e                	mv	a0,s3
     4a4:	00001097          	auipc	ra,0x1
     4a8:	b3a080e7          	jalr	-1222(ra) # fde <printf>
        for(i=0;i<500;i++){
     4ac:	2485                	addiw	s1,s1,1
     4ae:	ff2499e3          	bne	s1,s2,4a0 <test_stop_cont+0x30>
        }
        exit(0);
     4b2:	4501                	li	a0,0
     4b4:	00000097          	auipc	ra,0x0
     4b8:	77a080e7          	jalr	1914(ra) # c2e <exit>
    }else{
        printf("son pid=%d, dad pid=%d\n", pid, getpid());
     4bc:	00000097          	auipc	ra,0x0
     4c0:	7f2080e7          	jalr	2034(ra) # cae <getpid>
     4c4:	862a                	mv	a2,a0
     4c6:	85a6                	mv	a1,s1
     4c8:	00001517          	auipc	a0,0x1
     4cc:	f4850513          	addi	a0,a0,-184 # 1410 <malloc+0x374>
     4d0:	00001097          	auipc	ra,0x1
     4d4:	b0e080e7          	jalr	-1266(ra) # fde <printf>
        sleep(5);
     4d8:	4515                	li	a0,5
     4da:	00000097          	auipc	ra,0x0
     4de:	7e4080e7          	jalr	2020(ra) # cbe <sleep>
        printf("parent send stop ret= %d\n", kill(pid, SIGSTOP));
     4e2:	45c5                	li	a1,17
     4e4:	8526                	mv	a0,s1
     4e6:	00000097          	auipc	ra,0x0
     4ea:	778080e7          	jalr	1912(ra) # c5e <kill>
     4ee:	85aa                	mv	a1,a0
     4f0:	00001517          	auipc	a0,0x1
     4f4:	f3850513          	addi	a0,a0,-200 # 1428 <malloc+0x38c>
     4f8:	00001097          	auipc	ra,0x1
     4fc:	ae6080e7          	jalr	-1306(ra) # fde <printf>
        sleep(50);
     500:	03200513          	li	a0,50
     504:	00000097          	auipc	ra,0x0
     508:	7ba080e7          	jalr	1978(ra) # cbe <sleep>
        printf("parent send continue ret= %d\n", kill(pid, SIGCONT));
     50c:	45cd                	li	a1,19
     50e:	8526                	mv	a0,s1
     510:	00000097          	auipc	ra,0x0
     514:	74e080e7          	jalr	1870(ra) # c5e <kill>
     518:	85aa                	mv	a1,a0
     51a:	00001517          	auipc	a0,0x1
     51e:	f2e50513          	addi	a0,a0,-210 # 1448 <malloc+0x3ac>
     522:	00001097          	auipc	ra,0x1
     526:	abc080e7          	jalr	-1348(ra) # fde <printf>
        wait(0);
     52a:	4501                	li	a0,0
     52c:	00000097          	auipc	ra,0x0
     530:	70a080e7          	jalr	1802(ra) # c36 <wait>
        // for(int i=0;i<100;i++)
        //  printf("parent..");
        sleep(10);
     534:	4529                	li	a0,10
     536:	00000097          	auipc	ra,0x0
     53a:	788080e7          	jalr	1928(ra) # cbe <sleep>
        exit(0);
     53e:	4501                	li	a0,0
     540:	00000097          	auipc	ra,0x0
     544:	6ee080e7          	jalr	1774(ra) # c2e <exit>

0000000000000548 <test_ignore>:
    }
}

void 
test_ignore(){
     548:	7179                	addi	sp,sp,-48
     54a:	f406                	sd	ra,40(sp)
     54c:	f022                	sd	s0,32(sp)
     54e:	ec26                	sd	s1,24(sp)
     550:	e84a                	sd	s2,16(sp)
     552:	e44e                	sd	s3,8(sp)
     554:	1800                	addi	s0,sp,48
    int pid= fork();
     556:	00000097          	auipc	ra,0x0
     55a:	6d0080e7          	jalr	1744(ra) # c26 <fork>
     55e:	84aa                	mv	s1,a0
    int signum=22;
    if(pid==0){
     560:	c129                	beqz	a0,5a2 <test_ignore+0x5a>
            printf("child ignoring signal %d\n",i);
        }
        exit(0);

    }else{
        printf("son pid= %d",pid);
     562:	85aa                	mv	a1,a0
     564:	00001517          	auipc	a0,0x1
     568:	f6c50513          	addi	a0,a0,-148 # 14d0 <malloc+0x434>
     56c:	00001097          	auipc	ra,0x1
     570:	a72080e7          	jalr	-1422(ra) # fde <printf>
        sleep(5);
     574:	4515                	li	a0,5
     576:	00000097          	auipc	ra,0x0
     57a:	748080e7          	jalr	1864(ra) # cbe <sleep>
        kill(pid,signum);
     57e:	45d9                	li	a1,22
     580:	8526                	mv	a0,s1
     582:	00000097          	auipc	ra,0x0
     586:	6dc080e7          	jalr	1756(ra) # c5e <kill>
        wait(0);
     58a:	4501                	li	a0,0
     58c:	00000097          	auipc	ra,0x0
     590:	6aa080e7          	jalr	1706(ra) # c36 <wait>

    }
}
     594:	70a2                	ld	ra,40(sp)
     596:	7402                	ld	s0,32(sp)
     598:	64e2                	ld	s1,24(sp)
     59a:	6942                	ld	s2,16(sp)
     59c:	69a2                	ld	s3,8(sp)
     59e:	6145                	addi	sp,sp,48
     5a0:	8082                	ret
        newAct=malloc(sizeof(sigaction));
     5a2:	4505                	li	a0,1
     5a4:	00001097          	auipc	ra,0x1
     5a8:	af8080e7          	jalr	-1288(ra) # 109c <malloc>
     5ac:	89aa                	mv	s3,a0
        oldAct=malloc(sizeof(sigaction));
     5ae:	4505                	li	a0,1
     5b0:	00001097          	auipc	ra,0x1
     5b4:	aec080e7          	jalr	-1300(ra) # 109c <malloc>
     5b8:	892a                	mv	s2,a0
        newAct->sigmask = 0;
     5ba:	0009a423          	sw	zero,8(s3)
        newAct->sa_handler=(void*)SIG_IGN;
     5be:	4785                	li	a5,1
     5c0:	00f9b023          	sd	a5,0(s3)
        int ans=sigaction(signum,newAct,oldAct);
     5c4:	862a                	mv	a2,a0
     5c6:	85ce                	mv	a1,s3
     5c8:	4559                	li	a0,22
     5ca:	00000097          	auipc	ra,0x0
     5ce:	70c080e7          	jalr	1804(ra) # cd6 <sigaction>
     5d2:	85aa                	mv	a1,a0
        printf("ans from sigaction %d, old act returned is: mask= %d address= %d\n",ans,oldAct->sigmask,(uint64)oldAct->sa_handler);
     5d4:	00093683          	ld	a3,0(s2)
     5d8:	00892603          	lw	a2,8(s2)
     5dc:	00001517          	auipc	a0,0x1
     5e0:	e8c50513          	addi	a0,a0,-372 # 1468 <malloc+0x3cc>
     5e4:	00001097          	auipc	ra,0x1
     5e8:	9fa080e7          	jalr	-1542(ra) # fde <printf>
        sleep(6);
     5ec:	4519                	li	a0,6
     5ee:	00000097          	auipc	ra,0x0
     5f2:	6d0080e7          	jalr	1744(ra) # cbe <sleep>
            printf("child ignoring signal %d\n",i);
     5f6:	00001997          	auipc	s3,0x1
     5fa:	eba98993          	addi	s3,s3,-326 # 14b0 <malloc+0x414>
        for(int i=0;i<300;i++){
     5fe:	12c00913          	li	s2,300
            printf("child ignoring signal %d\n",i);
     602:	85a6                	mv	a1,s1
     604:	854e                	mv	a0,s3
     606:	00001097          	auipc	ra,0x1
     60a:	9d8080e7          	jalr	-1576(ra) # fde <printf>
        for(int i=0;i<300;i++){
     60e:	2485                	addiw	s1,s1,1
     610:	ff2499e3          	bne	s1,s2,602 <test_ignore+0xba>
        exit(0);
     614:	4501                	li	a0,0
     616:	00000097          	auipc	ra,0x0
     61a:	618080e7          	jalr	1560(ra) # c2e <exit>

000000000000061e <test_user_handler_kill>:
void
test_user_handler_kill(){
     61e:	715d                	addi	sp,sp,-80
     620:	e486                	sd	ra,72(sp)
     622:	e0a2                	sd	s0,64(sp)
     624:	fc26                	sd	s1,56(sp)
     626:	f84a                	sd	s2,48(sp)
     628:	f44e                	sd	s3,40(sp)
     62a:	0880                	addi	s0,sp,80
    struct sigaction act;

    printf("sighandler1= %p\n", &sig_handler_loop);
     62c:	00000597          	auipc	a1,0x0
     630:	aaa58593          	addi	a1,a1,-1366 # d6 <sig_handler_loop>
     634:	00001517          	auipc	a0,0x1
     638:	eac50513          	addi	a0,a0,-340 # 14e0 <malloc+0x444>
     63c:	00001097          	auipc	ra,0x1
     640:	9a2080e7          	jalr	-1630(ra) # fde <printf>
    printf("sighandler2= %p\n", &sig_handler_loop2);
     644:	00000597          	auipc	a1,0x0
     648:	ace58593          	addi	a1,a1,-1330 # 112 <sig_handler_loop2>
     64c:	00001517          	auipc	a0,0x1
     650:	eac50513          	addi	a0,a0,-340 # 14f8 <malloc+0x45c>
     654:	00001097          	auipc	ra,0x1
     658:	98a080e7          	jalr	-1654(ra) # fde <printf>


    uint mask = 0;
    mask ^= (1<<22);

    act.sigmask = mask;
     65c:	004007b7          	lui	a5,0x400
     660:	fcf42423          	sw	a5,-56(s0)
    
    struct sigaction oldact;
    oldact.sigmask=0;
     664:	fa042c23          	sw	zero,-72(s0)
    oldact.sa_handler=0;
     668:	fa043823          	sd	zero,-80(s0)
    
    act.sa_handler=&sig_handler_loop2;
     66c:	00000797          	auipc	a5,0x0
     670:	aa678793          	addi	a5,a5,-1370 # 112 <sig_handler_loop2>
     674:	fcf43023          	sd	a5,-64(s0)


    int pid = fork();
     678:	00000097          	auipc	ra,0x0
     67c:	5ae080e7          	jalr	1454(ra) # c26 <fork>
     680:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
     682:	ed29                	bnez	a0,6dc <test_user_handler_kill+0xbe>
        int ret=sigaction(3,&act,&oldact);
     684:	fb040613          	addi	a2,s0,-80
     688:	fc040593          	addi	a1,s0,-64
     68c:	450d                	li	a0,3
     68e:	00000097          	auipc	ra,0x0
     692:	648080e7          	jalr	1608(ra) # cd6 <sigaction>
        if(ret <0 ){
     696:	02054663          	bltz	a0,6c2 <test_user_handler_kill+0xa4>
            printf("sigaction FAILED");
            exit(-1);
        }

        for(i=0;i<500;i++)
            printf("out-side handler %d\n ", i);
     69a:	00001997          	auipc	s3,0x1
     69e:	e8e98993          	addi	s3,s3,-370 # 1528 <malloc+0x48c>
        for(i=0;i<500;i++)
     6a2:	1f400913          	li	s2,500
            printf("out-side handler %d\n ", i);
     6a6:	85a6                	mv	a1,s1
     6a8:	854e                	mv	a0,s3
     6aa:	00001097          	auipc	ra,0x1
     6ae:	934080e7          	jalr	-1740(ra) # fde <printf>
        for(i=0;i<500;i++)
     6b2:	2485                	addiw	s1,s1,1
     6b4:	ff2499e3          	bne	s1,s2,6a6 <test_user_handler_kill+0x88>
        exit(0);
     6b8:	4501                	li	a0,0
     6ba:	00000097          	auipc	ra,0x0
     6be:	574080e7          	jalr	1396(ra) # c2e <exit>
            printf("sigaction FAILED");
     6c2:	00001517          	auipc	a0,0x1
     6c6:	e4e50513          	addi	a0,a0,-434 # 1510 <malloc+0x474>
     6ca:	00001097          	auipc	ra,0x1
     6ce:	914080e7          	jalr	-1772(ra) # fde <printf>
            exit(-1);
     6d2:	557d                	li	a0,-1
     6d4:	00000097          	auipc	ra,0x0
     6d8:	55a080e7          	jalr	1370(ra) # c2e <exit>
    }else{
        printf("son pid=%d, dad pid=%d\n",pid, getpid());
     6dc:	00000097          	auipc	ra,0x0
     6e0:	5d2080e7          	jalr	1490(ra) # cae <getpid>
     6e4:	862a                	mv	a2,a0
     6e6:	85a6                	mv	a1,s1
     6e8:	00001517          	auipc	a0,0x1
     6ec:	d2850513          	addi	a0,a0,-728 # 1410 <malloc+0x374>
     6f0:	00001097          	auipc	ra,0x1
     6f4:	8ee080e7          	jalr	-1810(ra) # fde <printf>
        sleep(5);
     6f8:	4515                	li	a0,5
     6fa:	00000097          	auipc	ra,0x0
     6fe:	5c4080e7          	jalr	1476(ra) # cbe <sleep>
        printf("parent send loop ret= %d\n",kill(pid, 3));
     702:	458d                	li	a1,3
     704:	8526                	mv	a0,s1
     706:	00000097          	auipc	ra,0x0
     70a:	558080e7          	jalr	1368(ra) # c5e <kill>
     70e:	85aa                	mv	a1,a0
     710:	00001517          	auipc	a0,0x1
     714:	e3050513          	addi	a0,a0,-464 # 1540 <malloc+0x4a4>
     718:	00001097          	auipc	ra,0x1
     71c:	8c6080e7          	jalr	-1850(ra) # fde <printf>
        sleep(20);
     720:	4551                	li	a0,20
     722:	00000097          	auipc	ra,0x0
     726:	59c080e7          	jalr	1436(ra) # cbe <sleep>
        printf("parent send kill ret= %d\n",kill(pid, SIGKILL));
     72a:	45a5                	li	a1,9
     72c:	8526                	mv	a0,s1
     72e:	00000097          	auipc	ra,0x0
     732:	530080e7          	jalr	1328(ra) # c5e <kill>
     736:	85aa                	mv	a1,a0
     738:	00001517          	auipc	a0,0x1
     73c:	e2850513          	addi	a0,a0,-472 # 1560 <malloc+0x4c4>
     740:	00001097          	auipc	ra,0x1
     744:	89e080e7          	jalr	-1890(ra) # fde <printf>
        wait(0);
     748:	4501                	li	a0,0
     74a:	00000097          	auipc	ra,0x0
     74e:	4ec080e7          	jalr	1260(ra) # c36 <wait>
        printf("parent exiting\n");
     752:	00001517          	auipc	a0,0x1
     756:	e2e50513          	addi	a0,a0,-466 # 1580 <malloc+0x4e4>
     75a:	00001097          	auipc	ra,0x1
     75e:	884080e7          	jalr	-1916(ra) # fde <printf>
        exit(0);
     762:	4501                	li	a0,0
     764:	00000097          	auipc	ra,0x0
     768:	4ca080e7          	jalr	1226(ra) # c2e <exit>

000000000000076c <thread_test>:
    }
}

//TODO delete func
void thread_test(char *s){
     76c:	7179                	addi	sp,sp,-48
     76e:	f406                	sd	ra,40(sp)
     770:	f022                	sd	s0,32(sp)
     772:	ec26                	sd	s1,24(sp)
     774:	e84a                	sd	s2,16(sp)
     776:	1800                	addi	s0,sp,48
    int tid;
    int status;
    void* stack = malloc(4000);
     778:	6505                	lui	a0,0x1
     77a:	fa050513          	addi	a0,a0,-96 # fa0 <vprintf+0x1ce>
     77e:	00001097          	auipc	ra,0x1
     782:	91e080e7          	jalr	-1762(ra) # 109c <malloc>
     786:	84aa                	mv	s1,a0
    printf("father tid is = %d\n",kthread_id());
     788:	00000097          	auipc	ra,0x0
     78c:	566080e7          	jalr	1382(ra) # cee <kthread_id>
     790:	85aa                	mv	a1,a0
     792:	00001517          	auipc	a0,0x1
     796:	dfe50513          	addi	a0,a0,-514 # 1590 <malloc+0x4f4>
     79a:	00001097          	auipc	ra,0x1
     79e:	844080e7          	jalr	-1980(ra) # fde <printf>
    tid = kthread_create(test_thread, stack);
     7a2:	85a6                	mv	a1,s1
     7a4:	00000517          	auipc	a0,0x0
     7a8:	85c50513          	addi	a0,a0,-1956 # 0 <test_thread>
     7ac:	00000097          	auipc	ra,0x0
     7b0:	53a080e7          	jalr	1338(ra) # ce6 <kthread_create>
     7b4:	892a                	mv	s2,a0
    printf("child tid %d",tid);
     7b6:	85aa                	mv	a1,a0
     7b8:	00001517          	auipc	a0,0x1
     7bc:	df050513          	addi	a0,a0,-528 # 15a8 <malloc+0x50c>
     7c0:	00001097          	auipc	ra,0x1
     7c4:	81e080e7          	jalr	-2018(ra) # fde <printf>
    printf("father tid is = %d\n",kthread_id());
     7c8:	00000097          	auipc	ra,0x0
     7cc:	526080e7          	jalr	1318(ra) # cee <kthread_id>
     7d0:	85aa                	mv	a1,a0
     7d2:	00001517          	auipc	a0,0x1
     7d6:	dbe50513          	addi	a0,a0,-578 # 1590 <malloc+0x4f4>
     7da:	00001097          	auipc	ra,0x1
     7de:	804080e7          	jalr	-2044(ra) # fde <printf>

    int ans =kthread_join(tid, &status);
     7e2:	fdc40593          	addi	a1,s0,-36
     7e6:	854a                	mv	a0,s2
     7e8:	00000097          	auipc	ra,0x0
     7ec:	516080e7          	jalr	1302(ra) # cfe <kthread_join>
     7f0:	892a                	mv	s2,a0
    printf("kthread join ret =%d , my tid =%d\n",ans,kthread_id());
     7f2:	00000097          	auipc	ra,0x0
     7f6:	4fc080e7          	jalr	1276(ra) # cee <kthread_id>
     7fa:	862a                	mv	a2,a0
     7fc:	85ca                	mv	a1,s2
     7fe:	00001517          	auipc	a0,0x1
     802:	dba50513          	addi	a0,a0,-582 # 15b8 <malloc+0x51c>
     806:	00000097          	auipc	ra,0x0
     80a:	7d8080e7          	jalr	2008(ra) # fde <printf>
    tid = kthread_id();
     80e:	00000097          	auipc	ra,0x0
     812:	4e0080e7          	jalr	1248(ra) # cee <kthread_id>
     816:	892a                	mv	s2,a0
    free(stack);
     818:	8526                	mv	a0,s1
     81a:	00000097          	auipc	ra,0x0
     81e:	7fa080e7          	jalr	2042(ra) # 1014 <free>
    printf("Finished testing threads, main thread id: %d, %d\n", tid,status);
     822:	fdc42603          	lw	a2,-36(s0)
     826:	85ca                	mv	a1,s2
     828:	00001517          	auipc	a0,0x1
     82c:	db850513          	addi	a0,a0,-584 # 15e0 <malloc+0x544>
     830:	00000097          	auipc	ra,0x0
     834:	7ae080e7          	jalr	1966(ra) # fde <printf>
}
     838:	70a2                	ld	ra,40(sp)
     83a:	7402                	ld	s0,32(sp)
     83c:	64e2                	ld	s1,24(sp)
     83e:	6942                	ld	s2,16(sp)
     840:	6145                	addi	sp,sp,48
     842:	8082                	ret

0000000000000844 <thread_test2>:
void thread_test2(char *s){
     844:	1101                	addi	sp,sp,-32
     846:	ec06                	sd	ra,24(sp)
     848:	e822                	sd	s0,16(sp)
     84a:	e426                	sd	s1,8(sp)
     84c:	e04a                	sd	s2,0(sp)
     84e:	1000                	addi	s0,sp,32
    int tid;
    void* stack = malloc(4000);
     850:	6505                	lui	a0,0x1
     852:	fa050513          	addi	a0,a0,-96 # fa0 <vprintf+0x1ce>
     856:	00001097          	auipc	ra,0x1
     85a:	846080e7          	jalr	-1978(ra) # 109c <malloc>
     85e:	84aa                	mv	s1,a0
    printf("after malloc\n");
     860:	00001517          	auipc	a0,0x1
     864:	db850513          	addi	a0,a0,-584 # 1618 <malloc+0x57c>
     868:	00000097          	auipc	ra,0x0
     86c:	776080e7          	jalr	1910(ra) # fde <printf>
    printf("add of func for new thread : %p\n",&test_thread);
     870:	fffff597          	auipc	a1,0xfffff
     874:	79058593          	addi	a1,a1,1936 # 0 <test_thread>
     878:	00001517          	auipc	a0,0x1
     87c:	db050513          	addi	a0,a0,-592 # 1628 <malloc+0x58c>
     880:	00000097          	auipc	ra,0x0
     884:	75e080e7          	jalr	1886(ra) # fde <printf>
    printf("add of func for new thread : %p\n",&test_thread2);
     888:	00000597          	auipc	a1,0x0
     88c:	81058593          	addi	a1,a1,-2032 # 98 <test_thread2>
     890:	00001517          	auipc	a0,0x1
     894:	d9850513          	addi	a0,a0,-616 # 1628 <malloc+0x58c>
     898:	00000097          	auipc	ra,0x0
     89c:	746080e7          	jalr	1862(ra) # fde <printf>

    tid = kthread_create(&test_thread2, stack);
     8a0:	85a6                	mv	a1,s1
     8a2:	fffff517          	auipc	a0,0xfffff
     8a6:	7f650513          	addi	a0,a0,2038 # 98 <test_thread2>
     8aa:	00000097          	auipc	ra,0x0
     8ae:	43c080e7          	jalr	1084(ra) # ce6 <kthread_create>
     8b2:	85aa                	mv	a1,a0
    
    printf("after create %d \n",tid);
     8b4:	00001517          	auipc	a0,0x1
     8b8:	d9c50513          	addi	a0,a0,-612 # 1650 <malloc+0x5b4>
     8bc:	00000097          	auipc	ra,0x0
     8c0:	722080e7          	jalr	1826(ra) # fde <printf>

    sleep(5);
     8c4:	4515                	li	a0,5
     8c6:	00000097          	auipc	ra,0x0
     8ca:	3f8080e7          	jalr	1016(ra) # cbe <sleep>
    printf("after kthread\n");
     8ce:	00001517          	auipc	a0,0x1
     8d2:	d9a50513          	addi	a0,a0,-614 # 1668 <malloc+0x5cc>
     8d6:	00000097          	auipc	ra,0x0
     8da:	708080e7          	jalr	1800(ra) # fde <printf>
    tid = kthread_id();
     8de:	00000097          	auipc	ra,0x0
     8e2:	410080e7          	jalr	1040(ra) # cee <kthread_id>
     8e6:	892a                	mv	s2,a0
    free(stack);
     8e8:	8526                	mv	a0,s1
     8ea:	00000097          	auipc	ra,0x0
     8ee:	72a080e7          	jalr	1834(ra) # 1014 <free>
    printf("Finished testing threads, main thread id: %d\n", tid);
     8f2:	85ca                	mv	a1,s2
     8f4:	00001517          	auipc	a0,0x1
     8f8:	d8450513          	addi	a0,a0,-636 # 1678 <malloc+0x5dc>
     8fc:	00000097          	auipc	ra,0x0
     900:	6e2080e7          	jalr	1762(ra) # fde <printf>
}
     904:	60e2                	ld	ra,24(sp)
     906:	6442                	ld	s0,16(sp)
     908:	64a2                	ld	s1,8(sp)
     90a:	6902                	ld	s2,0(sp)
     90c:	6105                	addi	sp,sp,32
     90e:	8082                	ret

0000000000000910 <very_easy_thread_test>:

void very_easy_thread_test(char *s){
     910:	1101                	addi	sp,sp,-32
     912:	ec06                	sd	ra,24(sp)
     914:	e822                	sd	s0,16(sp)
     916:	e426                	sd	s1,8(sp)
     918:	e04a                	sd	s2,0(sp)
     91a:	1000                	addi	s0,sp,32
    int tid;
    void* stack = malloc(4000);
     91c:	6505                	lui	a0,0x1
     91e:	fa050513          	addi	a0,a0,-96 # fa0 <vprintf+0x1ce>
     922:	00000097          	auipc	ra,0x0
     926:	77a080e7          	jalr	1914(ra) # 109c <malloc>
     92a:	84aa                	mv	s1,a0
    printf("add of func for new thread : %p\n",&test_thread);
     92c:	fffff597          	auipc	a1,0xfffff
     930:	6d458593          	addi	a1,a1,1748 # 0 <test_thread>
     934:	00001517          	auipc	a0,0x1
     938:	cf450513          	addi	a0,a0,-780 # 1628 <malloc+0x58c>
     93c:	00000097          	auipc	ra,0x0
     940:	6a2080e7          	jalr	1698(ra) # fde <printf>

    tid = kthread_create(&test_thread_loop, stack);
     944:	85a6                	mv	a1,s1
     946:	fffff517          	auipc	a0,0xfffff
     94a:	6f850513          	addi	a0,a0,1784 # 3e <test_thread_loop>
     94e:	00000097          	auipc	ra,0x0
     952:	398080e7          	jalr	920(ra) # ce6 <kthread_create>
     956:	892a                	mv	s2,a0
    
    printf("after create ret tid= %d mytid= %d\n",tid,kthread_id());
     958:	00000097          	auipc	ra,0x0
     95c:	396080e7          	jalr	918(ra) # cee <kthread_id>
     960:	862a                	mv	a2,a0
     962:	85ca                	mv	a1,s2
     964:	00001517          	auipc	a0,0x1
     968:	d4450513          	addi	a0,a0,-700 # 16a8 <malloc+0x60c>
     96c:	00000097          	auipc	ra,0x0
     970:	672080e7          	jalr	1650(ra) # fde <printf>

    free(stack);
     974:	8526                	mv	a0,s1
     976:	00000097          	auipc	ra,0x0
     97a:	69e080e7          	jalr	1694(ra) # 1014 <free>
    printf("Finished testing threads, main thread id: %d\n", kthread_id());
     97e:	00000097          	auipc	ra,0x0
     982:	370080e7          	jalr	880(ra) # cee <kthread_id>
     986:	85aa                	mv	a1,a0
     988:	00001517          	auipc	a0,0x1
     98c:	cf050513          	addi	a0,a0,-784 # 1678 <malloc+0x5dc>
     990:	00000097          	auipc	ra,0x0
     994:	64e080e7          	jalr	1614(ra) # fde <printf>
    kthread_exit(0);
     998:	4501                	li	a0,0
     99a:	00000097          	auipc	ra,0x0
     99e:	35c080e7          	jalr	860(ra) # cf6 <kthread_exit>
}
     9a2:	60e2                	ld	ra,24(sp)
     9a4:	6442                	ld	s0,16(sp)
     9a6:	64a2                	ld	s1,8(sp)
     9a8:	6902                	ld	s2,0(sp)
     9aa:	6105                	addi	sp,sp,32
     9ac:	8082                	ret

00000000000009ae <main>:

int main(){
     9ae:	1141                	addi	sp,sp,-16
     9b0:	e406                	sd	ra,8(sp)
     9b2:	e022                	sd	s0,0(sp)
     9b4:	0800                	addi	s0,sp,16
    // very_easy_thread_test("ff");


   

    exit(0);
     9b6:	4501                	li	a0,0
     9b8:	00000097          	auipc	ra,0x0
     9bc:	276080e7          	jalr	630(ra) # c2e <exit>

00000000000009c0 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     9c0:	1141                	addi	sp,sp,-16
     9c2:	e422                	sd	s0,8(sp)
     9c4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     9c6:	87aa                	mv	a5,a0
     9c8:	0585                	addi	a1,a1,1
     9ca:	0785                	addi	a5,a5,1
     9cc:	fff5c703          	lbu	a4,-1(a1)
     9d0:	fee78fa3          	sb	a4,-1(a5)
     9d4:	fb75                	bnez	a4,9c8 <strcpy+0x8>
    ;
  return os;
}
     9d6:	6422                	ld	s0,8(sp)
     9d8:	0141                	addi	sp,sp,16
     9da:	8082                	ret

00000000000009dc <strcmp>:

int
strcmp(const char *p, const char *q)
{
     9dc:	1141                	addi	sp,sp,-16
     9de:	e422                	sd	s0,8(sp)
     9e0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     9e2:	00054783          	lbu	a5,0(a0)
     9e6:	cb91                	beqz	a5,9fa <strcmp+0x1e>
     9e8:	0005c703          	lbu	a4,0(a1)
     9ec:	00f71763          	bne	a4,a5,9fa <strcmp+0x1e>
    p++, q++;
     9f0:	0505                	addi	a0,a0,1
     9f2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     9f4:	00054783          	lbu	a5,0(a0)
     9f8:	fbe5                	bnez	a5,9e8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     9fa:	0005c503          	lbu	a0,0(a1)
}
     9fe:	40a7853b          	subw	a0,a5,a0
     a02:	6422                	ld	s0,8(sp)
     a04:	0141                	addi	sp,sp,16
     a06:	8082                	ret

0000000000000a08 <strlen>:

uint
strlen(const char *s)
{
     a08:	1141                	addi	sp,sp,-16
     a0a:	e422                	sd	s0,8(sp)
     a0c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     a0e:	00054783          	lbu	a5,0(a0)
     a12:	cf91                	beqz	a5,a2e <strlen+0x26>
     a14:	0505                	addi	a0,a0,1
     a16:	87aa                	mv	a5,a0
     a18:	4685                	li	a3,1
     a1a:	9e89                	subw	a3,a3,a0
     a1c:	00f6853b          	addw	a0,a3,a5
     a20:	0785                	addi	a5,a5,1
     a22:	fff7c703          	lbu	a4,-1(a5)
     a26:	fb7d                	bnez	a4,a1c <strlen+0x14>
    ;
  return n;
}
     a28:	6422                	ld	s0,8(sp)
     a2a:	0141                	addi	sp,sp,16
     a2c:	8082                	ret
  for(n = 0; s[n]; n++)
     a2e:	4501                	li	a0,0
     a30:	bfe5                	j	a28 <strlen+0x20>

0000000000000a32 <memset>:

void*
memset(void *dst, int c, uint n)
{
     a32:	1141                	addi	sp,sp,-16
     a34:	e422                	sd	s0,8(sp)
     a36:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     a38:	ca19                	beqz	a2,a4e <memset+0x1c>
     a3a:	87aa                	mv	a5,a0
     a3c:	1602                	slli	a2,a2,0x20
     a3e:	9201                	srli	a2,a2,0x20
     a40:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     a44:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     a48:	0785                	addi	a5,a5,1
     a4a:	fee79de3          	bne	a5,a4,a44 <memset+0x12>
  }
  return dst;
}
     a4e:	6422                	ld	s0,8(sp)
     a50:	0141                	addi	sp,sp,16
     a52:	8082                	ret

0000000000000a54 <strchr>:

char*
strchr(const char *s, char c)
{
     a54:	1141                	addi	sp,sp,-16
     a56:	e422                	sd	s0,8(sp)
     a58:	0800                	addi	s0,sp,16
  for(; *s; s++)
     a5a:	00054783          	lbu	a5,0(a0)
     a5e:	cb99                	beqz	a5,a74 <strchr+0x20>
    if(*s == c)
     a60:	00f58763          	beq	a1,a5,a6e <strchr+0x1a>
  for(; *s; s++)
     a64:	0505                	addi	a0,a0,1
     a66:	00054783          	lbu	a5,0(a0)
     a6a:	fbfd                	bnez	a5,a60 <strchr+0xc>
      return (char*)s;
  return 0;
     a6c:	4501                	li	a0,0
}
     a6e:	6422                	ld	s0,8(sp)
     a70:	0141                	addi	sp,sp,16
     a72:	8082                	ret
  return 0;
     a74:	4501                	li	a0,0
     a76:	bfe5                	j	a6e <strchr+0x1a>

0000000000000a78 <gets>:

char*
gets(char *buf, int max)
{
     a78:	711d                	addi	sp,sp,-96
     a7a:	ec86                	sd	ra,88(sp)
     a7c:	e8a2                	sd	s0,80(sp)
     a7e:	e4a6                	sd	s1,72(sp)
     a80:	e0ca                	sd	s2,64(sp)
     a82:	fc4e                	sd	s3,56(sp)
     a84:	f852                	sd	s4,48(sp)
     a86:	f456                	sd	s5,40(sp)
     a88:	f05a                	sd	s6,32(sp)
     a8a:	ec5e                	sd	s7,24(sp)
     a8c:	1080                	addi	s0,sp,96
     a8e:	8baa                	mv	s7,a0
     a90:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     a92:	892a                	mv	s2,a0
     a94:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     a96:	4aa9                	li	s5,10
     a98:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     a9a:	89a6                	mv	s3,s1
     a9c:	2485                	addiw	s1,s1,1
     a9e:	0344d863          	bge	s1,s4,ace <gets+0x56>
    cc = read(0, &c, 1);
     aa2:	4605                	li	a2,1
     aa4:	faf40593          	addi	a1,s0,-81
     aa8:	4501                	li	a0,0
     aaa:	00000097          	auipc	ra,0x0
     aae:	19c080e7          	jalr	412(ra) # c46 <read>
    if(cc < 1)
     ab2:	00a05e63          	blez	a0,ace <gets+0x56>
    buf[i++] = c;
     ab6:	faf44783          	lbu	a5,-81(s0)
     aba:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     abe:	01578763          	beq	a5,s5,acc <gets+0x54>
     ac2:	0905                	addi	s2,s2,1
     ac4:	fd679be3          	bne	a5,s6,a9a <gets+0x22>
  for(i=0; i+1 < max; ){
     ac8:	89a6                	mv	s3,s1
     aca:	a011                	j	ace <gets+0x56>
     acc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     ace:	99de                	add	s3,s3,s7
     ad0:	00098023          	sb	zero,0(s3)
  return buf;
}
     ad4:	855e                	mv	a0,s7
     ad6:	60e6                	ld	ra,88(sp)
     ad8:	6446                	ld	s0,80(sp)
     ada:	64a6                	ld	s1,72(sp)
     adc:	6906                	ld	s2,64(sp)
     ade:	79e2                	ld	s3,56(sp)
     ae0:	7a42                	ld	s4,48(sp)
     ae2:	7aa2                	ld	s5,40(sp)
     ae4:	7b02                	ld	s6,32(sp)
     ae6:	6be2                	ld	s7,24(sp)
     ae8:	6125                	addi	sp,sp,96
     aea:	8082                	ret

0000000000000aec <stat>:

int
stat(const char *n, struct stat *st)
{
     aec:	1101                	addi	sp,sp,-32
     aee:	ec06                	sd	ra,24(sp)
     af0:	e822                	sd	s0,16(sp)
     af2:	e426                	sd	s1,8(sp)
     af4:	e04a                	sd	s2,0(sp)
     af6:	1000                	addi	s0,sp,32
     af8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     afa:	4581                	li	a1,0
     afc:	00000097          	auipc	ra,0x0
     b00:	172080e7          	jalr	370(ra) # c6e <open>
  if(fd < 0)
     b04:	02054563          	bltz	a0,b2e <stat+0x42>
     b08:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     b0a:	85ca                	mv	a1,s2
     b0c:	00000097          	auipc	ra,0x0
     b10:	17a080e7          	jalr	378(ra) # c86 <fstat>
     b14:	892a                	mv	s2,a0
  close(fd);
     b16:	8526                	mv	a0,s1
     b18:	00000097          	auipc	ra,0x0
     b1c:	13e080e7          	jalr	318(ra) # c56 <close>
  return r;
}
     b20:	854a                	mv	a0,s2
     b22:	60e2                	ld	ra,24(sp)
     b24:	6442                	ld	s0,16(sp)
     b26:	64a2                	ld	s1,8(sp)
     b28:	6902                	ld	s2,0(sp)
     b2a:	6105                	addi	sp,sp,32
     b2c:	8082                	ret
    return -1;
     b2e:	597d                	li	s2,-1
     b30:	bfc5                	j	b20 <stat+0x34>

0000000000000b32 <atoi>:

int
atoi(const char *s)
{
     b32:	1141                	addi	sp,sp,-16
     b34:	e422                	sd	s0,8(sp)
     b36:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     b38:	00054603          	lbu	a2,0(a0)
     b3c:	fd06079b          	addiw	a5,a2,-48
     b40:	0ff7f793          	andi	a5,a5,255
     b44:	4725                	li	a4,9
     b46:	02f76963          	bltu	a4,a5,b78 <atoi+0x46>
     b4a:	86aa                	mv	a3,a0
  n = 0;
     b4c:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     b4e:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     b50:	0685                	addi	a3,a3,1
     b52:	0025179b          	slliw	a5,a0,0x2
     b56:	9fa9                	addw	a5,a5,a0
     b58:	0017979b          	slliw	a5,a5,0x1
     b5c:	9fb1                	addw	a5,a5,a2
     b5e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     b62:	0006c603          	lbu	a2,0(a3)
     b66:	fd06071b          	addiw	a4,a2,-48
     b6a:	0ff77713          	andi	a4,a4,255
     b6e:	fee5f1e3          	bgeu	a1,a4,b50 <atoi+0x1e>
  return n;
}
     b72:	6422                	ld	s0,8(sp)
     b74:	0141                	addi	sp,sp,16
     b76:	8082                	ret
  n = 0;
     b78:	4501                	li	a0,0
     b7a:	bfe5                	j	b72 <atoi+0x40>

0000000000000b7c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     b7c:	1141                	addi	sp,sp,-16
     b7e:	e422                	sd	s0,8(sp)
     b80:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     b82:	02b57463          	bgeu	a0,a1,baa <memmove+0x2e>
    while(n-- > 0)
     b86:	00c05f63          	blez	a2,ba4 <memmove+0x28>
     b8a:	1602                	slli	a2,a2,0x20
     b8c:	9201                	srli	a2,a2,0x20
     b8e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     b92:	872a                	mv	a4,a0
      *dst++ = *src++;
     b94:	0585                	addi	a1,a1,1
     b96:	0705                	addi	a4,a4,1
     b98:	fff5c683          	lbu	a3,-1(a1)
     b9c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     ba0:	fee79ae3          	bne	a5,a4,b94 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     ba4:	6422                	ld	s0,8(sp)
     ba6:	0141                	addi	sp,sp,16
     ba8:	8082                	ret
    dst += n;
     baa:	00c50733          	add	a4,a0,a2
    src += n;
     bae:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     bb0:	fec05ae3          	blez	a2,ba4 <memmove+0x28>
     bb4:	fff6079b          	addiw	a5,a2,-1
     bb8:	1782                	slli	a5,a5,0x20
     bba:	9381                	srli	a5,a5,0x20
     bbc:	fff7c793          	not	a5,a5
     bc0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     bc2:	15fd                	addi	a1,a1,-1
     bc4:	177d                	addi	a4,a4,-1
     bc6:	0005c683          	lbu	a3,0(a1)
     bca:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     bce:	fee79ae3          	bne	a5,a4,bc2 <memmove+0x46>
     bd2:	bfc9                	j	ba4 <memmove+0x28>

0000000000000bd4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     bd4:	1141                	addi	sp,sp,-16
     bd6:	e422                	sd	s0,8(sp)
     bd8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     bda:	ca05                	beqz	a2,c0a <memcmp+0x36>
     bdc:	fff6069b          	addiw	a3,a2,-1
     be0:	1682                	slli	a3,a3,0x20
     be2:	9281                	srli	a3,a3,0x20
     be4:	0685                	addi	a3,a3,1
     be6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     be8:	00054783          	lbu	a5,0(a0)
     bec:	0005c703          	lbu	a4,0(a1)
     bf0:	00e79863          	bne	a5,a4,c00 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     bf4:	0505                	addi	a0,a0,1
    p2++;
     bf6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     bf8:	fed518e3          	bne	a0,a3,be8 <memcmp+0x14>
  }
  return 0;
     bfc:	4501                	li	a0,0
     bfe:	a019                	j	c04 <memcmp+0x30>
      return *p1 - *p2;
     c00:	40e7853b          	subw	a0,a5,a4
}
     c04:	6422                	ld	s0,8(sp)
     c06:	0141                	addi	sp,sp,16
     c08:	8082                	ret
  return 0;
     c0a:	4501                	li	a0,0
     c0c:	bfe5                	j	c04 <memcmp+0x30>

0000000000000c0e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     c0e:	1141                	addi	sp,sp,-16
     c10:	e406                	sd	ra,8(sp)
     c12:	e022                	sd	s0,0(sp)
     c14:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     c16:	00000097          	auipc	ra,0x0
     c1a:	f66080e7          	jalr	-154(ra) # b7c <memmove>
}
     c1e:	60a2                	ld	ra,8(sp)
     c20:	6402                	ld	s0,0(sp)
     c22:	0141                	addi	sp,sp,16
     c24:	8082                	ret

0000000000000c26 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     c26:	4885                	li	a7,1
 ecall
     c28:	00000073          	ecall
 ret
     c2c:	8082                	ret

0000000000000c2e <exit>:
.global exit
exit:
 li a7, SYS_exit
     c2e:	4889                	li	a7,2
 ecall
     c30:	00000073          	ecall
 ret
     c34:	8082                	ret

0000000000000c36 <wait>:
.global wait
wait:
 li a7, SYS_wait
     c36:	488d                	li	a7,3
 ecall
     c38:	00000073          	ecall
 ret
     c3c:	8082                	ret

0000000000000c3e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     c3e:	4891                	li	a7,4
 ecall
     c40:	00000073          	ecall
 ret
     c44:	8082                	ret

0000000000000c46 <read>:
.global read
read:
 li a7, SYS_read
     c46:	4895                	li	a7,5
 ecall
     c48:	00000073          	ecall
 ret
     c4c:	8082                	ret

0000000000000c4e <write>:
.global write
write:
 li a7, SYS_write
     c4e:	48c1                	li	a7,16
 ecall
     c50:	00000073          	ecall
 ret
     c54:	8082                	ret

0000000000000c56 <close>:
.global close
close:
 li a7, SYS_close
     c56:	48d5                	li	a7,21
 ecall
     c58:	00000073          	ecall
 ret
     c5c:	8082                	ret

0000000000000c5e <kill>:
.global kill
kill:
 li a7, SYS_kill
     c5e:	4899                	li	a7,6
 ecall
     c60:	00000073          	ecall
 ret
     c64:	8082                	ret

0000000000000c66 <exec>:
.global exec
exec:
 li a7, SYS_exec
     c66:	489d                	li	a7,7
 ecall
     c68:	00000073          	ecall
 ret
     c6c:	8082                	ret

0000000000000c6e <open>:
.global open
open:
 li a7, SYS_open
     c6e:	48bd                	li	a7,15
 ecall
     c70:	00000073          	ecall
 ret
     c74:	8082                	ret

0000000000000c76 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     c76:	48c5                	li	a7,17
 ecall
     c78:	00000073          	ecall
 ret
     c7c:	8082                	ret

0000000000000c7e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     c7e:	48c9                	li	a7,18
 ecall
     c80:	00000073          	ecall
 ret
     c84:	8082                	ret

0000000000000c86 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     c86:	48a1                	li	a7,8
 ecall
     c88:	00000073          	ecall
 ret
     c8c:	8082                	ret

0000000000000c8e <link>:
.global link
link:
 li a7, SYS_link
     c8e:	48cd                	li	a7,19
 ecall
     c90:	00000073          	ecall
 ret
     c94:	8082                	ret

0000000000000c96 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     c96:	48d1                	li	a7,20
 ecall
     c98:	00000073          	ecall
 ret
     c9c:	8082                	ret

0000000000000c9e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     c9e:	48a5                	li	a7,9
 ecall
     ca0:	00000073          	ecall
 ret
     ca4:	8082                	ret

0000000000000ca6 <dup>:
.global dup
dup:
 li a7, SYS_dup
     ca6:	48a9                	li	a7,10
 ecall
     ca8:	00000073          	ecall
 ret
     cac:	8082                	ret

0000000000000cae <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     cae:	48ad                	li	a7,11
 ecall
     cb0:	00000073          	ecall
 ret
     cb4:	8082                	ret

0000000000000cb6 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     cb6:	48b1                	li	a7,12
 ecall
     cb8:	00000073          	ecall
 ret
     cbc:	8082                	ret

0000000000000cbe <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     cbe:	48b5                	li	a7,13
 ecall
     cc0:	00000073          	ecall
 ret
     cc4:	8082                	ret

0000000000000cc6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     cc6:	48b9                	li	a7,14
 ecall
     cc8:	00000073          	ecall
 ret
     ccc:	8082                	ret

0000000000000cce <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
     cce:	48d9                	li	a7,22
 ecall
     cd0:	00000073          	ecall
 ret
     cd4:	8082                	ret

0000000000000cd6 <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
     cd6:	48dd                	li	a7,23
 ecall
     cd8:	00000073          	ecall
 ret
     cdc:	8082                	ret

0000000000000cde <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
     cde:	48e1                	li	a7,24
 ecall
     ce0:	00000073          	ecall
 ret
     ce4:	8082                	ret

0000000000000ce6 <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
     ce6:	48e5                	li	a7,25
 ecall
     ce8:	00000073          	ecall
 ret
     cec:	8082                	ret

0000000000000cee <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
     cee:	48e9                	li	a7,26
 ecall
     cf0:	00000073          	ecall
 ret
     cf4:	8082                	ret

0000000000000cf6 <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
     cf6:	48ed                	li	a7,27
 ecall
     cf8:	00000073          	ecall
 ret
     cfc:	8082                	ret

0000000000000cfe <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
     cfe:	48f1                	li	a7,28
 ecall
     d00:	00000073          	ecall
 ret
     d04:	8082                	ret

0000000000000d06 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     d06:	1101                	addi	sp,sp,-32
     d08:	ec06                	sd	ra,24(sp)
     d0a:	e822                	sd	s0,16(sp)
     d0c:	1000                	addi	s0,sp,32
     d0e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     d12:	4605                	li	a2,1
     d14:	fef40593          	addi	a1,s0,-17
     d18:	00000097          	auipc	ra,0x0
     d1c:	f36080e7          	jalr	-202(ra) # c4e <write>
}
     d20:	60e2                	ld	ra,24(sp)
     d22:	6442                	ld	s0,16(sp)
     d24:	6105                	addi	sp,sp,32
     d26:	8082                	ret

0000000000000d28 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     d28:	7139                	addi	sp,sp,-64
     d2a:	fc06                	sd	ra,56(sp)
     d2c:	f822                	sd	s0,48(sp)
     d2e:	f426                	sd	s1,40(sp)
     d30:	f04a                	sd	s2,32(sp)
     d32:	ec4e                	sd	s3,24(sp)
     d34:	0080                	addi	s0,sp,64
     d36:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     d38:	c299                	beqz	a3,d3e <printint+0x16>
     d3a:	0805c863          	bltz	a1,dca <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     d3e:	2581                	sext.w	a1,a1
  neg = 0;
     d40:	4881                	li	a7,0
     d42:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     d46:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     d48:	2601                	sext.w	a2,a2
     d4a:	00001517          	auipc	a0,0x1
     d4e:	98e50513          	addi	a0,a0,-1650 # 16d8 <digits>
     d52:	883a                	mv	a6,a4
     d54:	2705                	addiw	a4,a4,1
     d56:	02c5f7bb          	remuw	a5,a1,a2
     d5a:	1782                	slli	a5,a5,0x20
     d5c:	9381                	srli	a5,a5,0x20
     d5e:	97aa                	add	a5,a5,a0
     d60:	0007c783          	lbu	a5,0(a5)
     d64:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     d68:	0005879b          	sext.w	a5,a1
     d6c:	02c5d5bb          	divuw	a1,a1,a2
     d70:	0685                	addi	a3,a3,1
     d72:	fec7f0e3          	bgeu	a5,a2,d52 <printint+0x2a>
  if(neg)
     d76:	00088b63          	beqz	a7,d8c <printint+0x64>
    buf[i++] = '-';
     d7a:	fd040793          	addi	a5,s0,-48
     d7e:	973e                	add	a4,a4,a5
     d80:	02d00793          	li	a5,45
     d84:	fef70823          	sb	a5,-16(a4)
     d88:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     d8c:	02e05863          	blez	a4,dbc <printint+0x94>
     d90:	fc040793          	addi	a5,s0,-64
     d94:	00e78933          	add	s2,a5,a4
     d98:	fff78993          	addi	s3,a5,-1
     d9c:	99ba                	add	s3,s3,a4
     d9e:	377d                	addiw	a4,a4,-1
     da0:	1702                	slli	a4,a4,0x20
     da2:	9301                	srli	a4,a4,0x20
     da4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     da8:	fff94583          	lbu	a1,-1(s2)
     dac:	8526                	mv	a0,s1
     dae:	00000097          	auipc	ra,0x0
     db2:	f58080e7          	jalr	-168(ra) # d06 <putc>
  while(--i >= 0)
     db6:	197d                	addi	s2,s2,-1
     db8:	ff3918e3          	bne	s2,s3,da8 <printint+0x80>
}
     dbc:	70e2                	ld	ra,56(sp)
     dbe:	7442                	ld	s0,48(sp)
     dc0:	74a2                	ld	s1,40(sp)
     dc2:	7902                	ld	s2,32(sp)
     dc4:	69e2                	ld	s3,24(sp)
     dc6:	6121                	addi	sp,sp,64
     dc8:	8082                	ret
    x = -xx;
     dca:	40b005bb          	negw	a1,a1
    neg = 1;
     dce:	4885                	li	a7,1
    x = -xx;
     dd0:	bf8d                	j	d42 <printint+0x1a>

0000000000000dd2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     dd2:	7119                	addi	sp,sp,-128
     dd4:	fc86                	sd	ra,120(sp)
     dd6:	f8a2                	sd	s0,112(sp)
     dd8:	f4a6                	sd	s1,104(sp)
     dda:	f0ca                	sd	s2,96(sp)
     ddc:	ecce                	sd	s3,88(sp)
     dde:	e8d2                	sd	s4,80(sp)
     de0:	e4d6                	sd	s5,72(sp)
     de2:	e0da                	sd	s6,64(sp)
     de4:	fc5e                	sd	s7,56(sp)
     de6:	f862                	sd	s8,48(sp)
     de8:	f466                	sd	s9,40(sp)
     dea:	f06a                	sd	s10,32(sp)
     dec:	ec6e                	sd	s11,24(sp)
     dee:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     df0:	0005c903          	lbu	s2,0(a1)
     df4:	18090f63          	beqz	s2,f92 <vprintf+0x1c0>
     df8:	8aaa                	mv	s5,a0
     dfa:	8b32                	mv	s6,a2
     dfc:	00158493          	addi	s1,a1,1
  state = 0;
     e00:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     e02:	02500a13          	li	s4,37
      if(c == 'd'){
     e06:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
     e0a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
     e0e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
     e12:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     e16:	00001b97          	auipc	s7,0x1
     e1a:	8c2b8b93          	addi	s7,s7,-1854 # 16d8 <digits>
     e1e:	a839                	j	e3c <vprintf+0x6a>
        putc(fd, c);
     e20:	85ca                	mv	a1,s2
     e22:	8556                	mv	a0,s5
     e24:	00000097          	auipc	ra,0x0
     e28:	ee2080e7          	jalr	-286(ra) # d06 <putc>
     e2c:	a019                	j	e32 <vprintf+0x60>
    } else if(state == '%'){
     e2e:	01498f63          	beq	s3,s4,e4c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
     e32:	0485                	addi	s1,s1,1
     e34:	fff4c903          	lbu	s2,-1(s1)
     e38:	14090d63          	beqz	s2,f92 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
     e3c:	0009079b          	sext.w	a5,s2
    if(state == 0){
     e40:	fe0997e3          	bnez	s3,e2e <vprintf+0x5c>
      if(c == '%'){
     e44:	fd479ee3          	bne	a5,s4,e20 <vprintf+0x4e>
        state = '%';
     e48:	89be                	mv	s3,a5
     e4a:	b7e5                	j	e32 <vprintf+0x60>
      if(c == 'd'){
     e4c:	05878063          	beq	a5,s8,e8c <vprintf+0xba>
      } else if(c == 'l') {
     e50:	05978c63          	beq	a5,s9,ea8 <vprintf+0xd6>
      } else if(c == 'x') {
     e54:	07a78863          	beq	a5,s10,ec4 <vprintf+0xf2>
      } else if(c == 'p') {
     e58:	09b78463          	beq	a5,s11,ee0 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
     e5c:	07300713          	li	a4,115
     e60:	0ce78663          	beq	a5,a4,f2c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
     e64:	06300713          	li	a4,99
     e68:	0ee78e63          	beq	a5,a4,f64 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
     e6c:	11478863          	beq	a5,s4,f7c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
     e70:	85d2                	mv	a1,s4
     e72:	8556                	mv	a0,s5
     e74:	00000097          	auipc	ra,0x0
     e78:	e92080e7          	jalr	-366(ra) # d06 <putc>
        putc(fd, c);
     e7c:	85ca                	mv	a1,s2
     e7e:	8556                	mv	a0,s5
     e80:	00000097          	auipc	ra,0x0
     e84:	e86080e7          	jalr	-378(ra) # d06 <putc>
      }
      state = 0;
     e88:	4981                	li	s3,0
     e8a:	b765                	j	e32 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
     e8c:	008b0913          	addi	s2,s6,8
     e90:	4685                	li	a3,1
     e92:	4629                	li	a2,10
     e94:	000b2583          	lw	a1,0(s6)
     e98:	8556                	mv	a0,s5
     e9a:	00000097          	auipc	ra,0x0
     e9e:	e8e080e7          	jalr	-370(ra) # d28 <printint>
     ea2:	8b4a                	mv	s6,s2
      state = 0;
     ea4:	4981                	li	s3,0
     ea6:	b771                	j	e32 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
     ea8:	008b0913          	addi	s2,s6,8
     eac:	4681                	li	a3,0
     eae:	4629                	li	a2,10
     eb0:	000b2583          	lw	a1,0(s6)
     eb4:	8556                	mv	a0,s5
     eb6:	00000097          	auipc	ra,0x0
     eba:	e72080e7          	jalr	-398(ra) # d28 <printint>
     ebe:	8b4a                	mv	s6,s2
      state = 0;
     ec0:	4981                	li	s3,0
     ec2:	bf85                	j	e32 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
     ec4:	008b0913          	addi	s2,s6,8
     ec8:	4681                	li	a3,0
     eca:	4641                	li	a2,16
     ecc:	000b2583          	lw	a1,0(s6)
     ed0:	8556                	mv	a0,s5
     ed2:	00000097          	auipc	ra,0x0
     ed6:	e56080e7          	jalr	-426(ra) # d28 <printint>
     eda:	8b4a                	mv	s6,s2
      state = 0;
     edc:	4981                	li	s3,0
     ede:	bf91                	j	e32 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
     ee0:	008b0793          	addi	a5,s6,8
     ee4:	f8f43423          	sd	a5,-120(s0)
     ee8:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
     eec:	03000593          	li	a1,48
     ef0:	8556                	mv	a0,s5
     ef2:	00000097          	auipc	ra,0x0
     ef6:	e14080e7          	jalr	-492(ra) # d06 <putc>
  putc(fd, 'x');
     efa:	85ea                	mv	a1,s10
     efc:	8556                	mv	a0,s5
     efe:	00000097          	auipc	ra,0x0
     f02:	e08080e7          	jalr	-504(ra) # d06 <putc>
     f06:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     f08:	03c9d793          	srli	a5,s3,0x3c
     f0c:	97de                	add	a5,a5,s7
     f0e:	0007c583          	lbu	a1,0(a5)
     f12:	8556                	mv	a0,s5
     f14:	00000097          	auipc	ra,0x0
     f18:	df2080e7          	jalr	-526(ra) # d06 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     f1c:	0992                	slli	s3,s3,0x4
     f1e:	397d                	addiw	s2,s2,-1
     f20:	fe0914e3          	bnez	s2,f08 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
     f24:	f8843b03          	ld	s6,-120(s0)
      state = 0;
     f28:	4981                	li	s3,0
     f2a:	b721                	j	e32 <vprintf+0x60>
        s = va_arg(ap, char*);
     f2c:	008b0993          	addi	s3,s6,8
     f30:	000b3903          	ld	s2,0(s6)
        if(s == 0)
     f34:	02090163          	beqz	s2,f56 <vprintf+0x184>
        while(*s != 0){
     f38:	00094583          	lbu	a1,0(s2)
     f3c:	c9a1                	beqz	a1,f8c <vprintf+0x1ba>
          putc(fd, *s);
     f3e:	8556                	mv	a0,s5
     f40:	00000097          	auipc	ra,0x0
     f44:	dc6080e7          	jalr	-570(ra) # d06 <putc>
          s++;
     f48:	0905                	addi	s2,s2,1
        while(*s != 0){
     f4a:	00094583          	lbu	a1,0(s2)
     f4e:	f9e5                	bnez	a1,f3e <vprintf+0x16c>
        s = va_arg(ap, char*);
     f50:	8b4e                	mv	s6,s3
      state = 0;
     f52:	4981                	li	s3,0
     f54:	bdf9                	j	e32 <vprintf+0x60>
          s = "(null)";
     f56:	00000917          	auipc	s2,0x0
     f5a:	77a90913          	addi	s2,s2,1914 # 16d0 <malloc+0x634>
        while(*s != 0){
     f5e:	02800593          	li	a1,40
     f62:	bff1                	j	f3e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
     f64:	008b0913          	addi	s2,s6,8
     f68:	000b4583          	lbu	a1,0(s6)
     f6c:	8556                	mv	a0,s5
     f6e:	00000097          	auipc	ra,0x0
     f72:	d98080e7          	jalr	-616(ra) # d06 <putc>
     f76:	8b4a                	mv	s6,s2
      state = 0;
     f78:	4981                	li	s3,0
     f7a:	bd65                	j	e32 <vprintf+0x60>
        putc(fd, c);
     f7c:	85d2                	mv	a1,s4
     f7e:	8556                	mv	a0,s5
     f80:	00000097          	auipc	ra,0x0
     f84:	d86080e7          	jalr	-634(ra) # d06 <putc>
      state = 0;
     f88:	4981                	li	s3,0
     f8a:	b565                	j	e32 <vprintf+0x60>
        s = va_arg(ap, char*);
     f8c:	8b4e                	mv	s6,s3
      state = 0;
     f8e:	4981                	li	s3,0
     f90:	b54d                	j	e32 <vprintf+0x60>
    }
  }
}
     f92:	70e6                	ld	ra,120(sp)
     f94:	7446                	ld	s0,112(sp)
     f96:	74a6                	ld	s1,104(sp)
     f98:	7906                	ld	s2,96(sp)
     f9a:	69e6                	ld	s3,88(sp)
     f9c:	6a46                	ld	s4,80(sp)
     f9e:	6aa6                	ld	s5,72(sp)
     fa0:	6b06                	ld	s6,64(sp)
     fa2:	7be2                	ld	s7,56(sp)
     fa4:	7c42                	ld	s8,48(sp)
     fa6:	7ca2                	ld	s9,40(sp)
     fa8:	7d02                	ld	s10,32(sp)
     faa:	6de2                	ld	s11,24(sp)
     fac:	6109                	addi	sp,sp,128
     fae:	8082                	ret

0000000000000fb0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     fb0:	715d                	addi	sp,sp,-80
     fb2:	ec06                	sd	ra,24(sp)
     fb4:	e822                	sd	s0,16(sp)
     fb6:	1000                	addi	s0,sp,32
     fb8:	e010                	sd	a2,0(s0)
     fba:	e414                	sd	a3,8(s0)
     fbc:	e818                	sd	a4,16(s0)
     fbe:	ec1c                	sd	a5,24(s0)
     fc0:	03043023          	sd	a6,32(s0)
     fc4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     fc8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     fcc:	8622                	mv	a2,s0
     fce:	00000097          	auipc	ra,0x0
     fd2:	e04080e7          	jalr	-508(ra) # dd2 <vprintf>
}
     fd6:	60e2                	ld	ra,24(sp)
     fd8:	6442                	ld	s0,16(sp)
     fda:	6161                	addi	sp,sp,80
     fdc:	8082                	ret

0000000000000fde <printf>:

void
printf(const char *fmt, ...)
{
     fde:	711d                	addi	sp,sp,-96
     fe0:	ec06                	sd	ra,24(sp)
     fe2:	e822                	sd	s0,16(sp)
     fe4:	1000                	addi	s0,sp,32
     fe6:	e40c                	sd	a1,8(s0)
     fe8:	e810                	sd	a2,16(s0)
     fea:	ec14                	sd	a3,24(s0)
     fec:	f018                	sd	a4,32(s0)
     fee:	f41c                	sd	a5,40(s0)
     ff0:	03043823          	sd	a6,48(s0)
     ff4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     ff8:	00840613          	addi	a2,s0,8
     ffc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1000:	85aa                	mv	a1,a0
    1002:	4505                	li	a0,1
    1004:	00000097          	auipc	ra,0x0
    1008:	dce080e7          	jalr	-562(ra) # dd2 <vprintf>
}
    100c:	60e2                	ld	ra,24(sp)
    100e:	6442                	ld	s0,16(sp)
    1010:	6125                	addi	sp,sp,96
    1012:	8082                	ret

0000000000001014 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1014:	1141                	addi	sp,sp,-16
    1016:	e422                	sd	s0,8(sp)
    1018:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    101a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    101e:	00000797          	auipc	a5,0x0
    1022:	6d27b783          	ld	a5,1746(a5) # 16f0 <freep>
    1026:	a805                	j	1056 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1028:	4618                	lw	a4,8(a2)
    102a:	9db9                	addw	a1,a1,a4
    102c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1030:	6398                	ld	a4,0(a5)
    1032:	6318                	ld	a4,0(a4)
    1034:	fee53823          	sd	a4,-16(a0)
    1038:	a091                	j	107c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    103a:	ff852703          	lw	a4,-8(a0)
    103e:	9e39                	addw	a2,a2,a4
    1040:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    1042:	ff053703          	ld	a4,-16(a0)
    1046:	e398                	sd	a4,0(a5)
    1048:	a099                	j	108e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    104a:	6398                	ld	a4,0(a5)
    104c:	00e7e463          	bltu	a5,a4,1054 <free+0x40>
    1050:	00e6ea63          	bltu	a3,a4,1064 <free+0x50>
{
    1054:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1056:	fed7fae3          	bgeu	a5,a3,104a <free+0x36>
    105a:	6398                	ld	a4,0(a5)
    105c:	00e6e463          	bltu	a3,a4,1064 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1060:	fee7eae3          	bltu	a5,a4,1054 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    1064:	ff852583          	lw	a1,-8(a0)
    1068:	6390                	ld	a2,0(a5)
    106a:	02059813          	slli	a6,a1,0x20
    106e:	01c85713          	srli	a4,a6,0x1c
    1072:	9736                	add	a4,a4,a3
    1074:	fae60ae3          	beq	a2,a4,1028 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1078:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    107c:	4790                	lw	a2,8(a5)
    107e:	02061593          	slli	a1,a2,0x20
    1082:	01c5d713          	srli	a4,a1,0x1c
    1086:	973e                	add	a4,a4,a5
    1088:	fae689e3          	beq	a3,a4,103a <free+0x26>
  } else
    p->s.ptr = bp;
    108c:	e394                	sd	a3,0(a5)
  freep = p;
    108e:	00000717          	auipc	a4,0x0
    1092:	66f73123          	sd	a5,1634(a4) # 16f0 <freep>
}
    1096:	6422                	ld	s0,8(sp)
    1098:	0141                	addi	sp,sp,16
    109a:	8082                	ret

000000000000109c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    109c:	7139                	addi	sp,sp,-64
    109e:	fc06                	sd	ra,56(sp)
    10a0:	f822                	sd	s0,48(sp)
    10a2:	f426                	sd	s1,40(sp)
    10a4:	f04a                	sd	s2,32(sp)
    10a6:	ec4e                	sd	s3,24(sp)
    10a8:	e852                	sd	s4,16(sp)
    10aa:	e456                	sd	s5,8(sp)
    10ac:	e05a                	sd	s6,0(sp)
    10ae:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    10b0:	02051493          	slli	s1,a0,0x20
    10b4:	9081                	srli	s1,s1,0x20
    10b6:	04bd                	addi	s1,s1,15
    10b8:	8091                	srli	s1,s1,0x4
    10ba:	0014899b          	addiw	s3,s1,1
    10be:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    10c0:	00000517          	auipc	a0,0x0
    10c4:	63053503          	ld	a0,1584(a0) # 16f0 <freep>
    10c8:	c515                	beqz	a0,10f4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    10ca:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    10cc:	4798                	lw	a4,8(a5)
    10ce:	02977f63          	bgeu	a4,s1,110c <malloc+0x70>
    10d2:	8a4e                	mv	s4,s3
    10d4:	0009871b          	sext.w	a4,s3
    10d8:	6685                	lui	a3,0x1
    10da:	00d77363          	bgeu	a4,a3,10e0 <malloc+0x44>
    10de:	6a05                	lui	s4,0x1
    10e0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    10e4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    10e8:	00000917          	auipc	s2,0x0
    10ec:	60890913          	addi	s2,s2,1544 # 16f0 <freep>
  if(p == (char*)-1)
    10f0:	5afd                	li	s5,-1
    10f2:	a895                	j	1166 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    10f4:	00000797          	auipc	a5,0x0
    10f8:	60478793          	addi	a5,a5,1540 # 16f8 <base>
    10fc:	00000717          	auipc	a4,0x0
    1100:	5ef73a23          	sd	a5,1524(a4) # 16f0 <freep>
    1104:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1106:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    110a:	b7e1                	j	10d2 <malloc+0x36>
      if(p->s.size == nunits)
    110c:	02e48c63          	beq	s1,a4,1144 <malloc+0xa8>
        p->s.size -= nunits;
    1110:	4137073b          	subw	a4,a4,s3
    1114:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1116:	02071693          	slli	a3,a4,0x20
    111a:	01c6d713          	srli	a4,a3,0x1c
    111e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1120:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1124:	00000717          	auipc	a4,0x0
    1128:	5ca73623          	sd	a0,1484(a4) # 16f0 <freep>
      return (void*)(p + 1);
    112c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1130:	70e2                	ld	ra,56(sp)
    1132:	7442                	ld	s0,48(sp)
    1134:	74a2                	ld	s1,40(sp)
    1136:	7902                	ld	s2,32(sp)
    1138:	69e2                	ld	s3,24(sp)
    113a:	6a42                	ld	s4,16(sp)
    113c:	6aa2                	ld	s5,8(sp)
    113e:	6b02                	ld	s6,0(sp)
    1140:	6121                	addi	sp,sp,64
    1142:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1144:	6398                	ld	a4,0(a5)
    1146:	e118                	sd	a4,0(a0)
    1148:	bff1                	j	1124 <malloc+0x88>
  hp->s.size = nu;
    114a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    114e:	0541                	addi	a0,a0,16
    1150:	00000097          	auipc	ra,0x0
    1154:	ec4080e7          	jalr	-316(ra) # 1014 <free>
  return freep;
    1158:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    115c:	d971                	beqz	a0,1130 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    115e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1160:	4798                	lw	a4,8(a5)
    1162:	fa9775e3          	bgeu	a4,s1,110c <malloc+0x70>
    if(p == freep)
    1166:	00093703          	ld	a4,0(s2)
    116a:	853e                	mv	a0,a5
    116c:	fef719e3          	bne	a4,a5,115e <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    1170:	8552                	mv	a0,s4
    1172:	00000097          	auipc	ra,0x0
    1176:	b44080e7          	jalr	-1212(ra) # cb6 <sbrk>
  if(p == (char*)-1)
    117a:	fd5518e3          	bne	a0,s5,114a <malloc+0xae>
        return 0;
    117e:	4501                	li	a0,0
    1180:	bf45                	j	1130 <malloc+0x94>
