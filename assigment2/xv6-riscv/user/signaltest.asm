
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
       e:	cb8080e7          	jalr	-840(ra) # cc2 <sleep>
    printf("Thread is now running tid=%d\n",kthread_id());
      12:	00001097          	auipc	ra,0x1
      16:	ce0080e7          	jalr	-800(ra) # cf2 <kthread_id>
      1a:	85aa                	mv	a1,a0
      1c:	00001517          	auipc	a0,0x1
      20:	16c50513          	addi	a0,a0,364 # 1188 <malloc+0xe8>
      24:	00001097          	auipc	ra,0x1
      28:	fbe080e7          	jalr	-66(ra) # fe2 <printf>
    kthread_exit(9);
      2c:	4525                	li	a0,9
      2e:	00001097          	auipc	ra,0x1
      32:	ccc080e7          	jalr	-820(ra) # cfa <kthread_exit>
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
      52:	c74080e7          	jalr	-908(ra) # cc2 <sleep>
    for(int i=0;i<100;i++){
      56:	4481                	li	s1,0
        printf("%d:Thread is now running tid=%d\n",i,kthread_id());
      58:	00001997          	auipc	s3,0x1
      5c:	15098993          	addi	s3,s3,336 # 11a8 <malloc+0x108>
    for(int i=0;i<100;i++){
      60:	06400913          	li	s2,100
        printf("%d:Thread is now running tid=%d\n",i,kthread_id());
      64:	00001097          	auipc	ra,0x1
      68:	c8e080e7          	jalr	-882(ra) # cf2 <kthread_id>
      6c:	862a                	mv	a2,a0
      6e:	85a6                	mv	a1,s1
      70:	854e                	mv	a0,s3
      72:	00001097          	auipc	ra,0x1
      76:	f70080e7          	jalr	-144(ra) # fe2 <printf>
    for(int i=0;i<100;i++){
      7a:	2485                	addiw	s1,s1,1
      7c:	ff2494e3          	bne	s1,s2,64 <test_thread_loop+0x26>
    }
    kthread_exit(9);
      80:	4525                	li	a0,9
      82:	00001097          	auipc	ra,0x1
      86:	c78080e7          	jalr	-904(ra) # cfa <kthread_exit>
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
      a6:	c20080e7          	jalr	-992(ra) # cc2 <sleep>
    printf("Thread is now running tid=%d\n",kthread_id());
      aa:	00001097          	auipc	ra,0x1
      ae:	c48080e7          	jalr	-952(ra) # cf2 <kthread_id>
      b2:	85aa                	mv	a1,a0
      b4:	00001517          	auipc	a0,0x1
      b8:	0d450513          	addi	a0,a0,212 # 1188 <malloc+0xe8>
      bc:	00001097          	auipc	ra,0x1
      c0:	f26080e7          	jalr	-218(ra) # fe2 <printf>
    kthread_exit(9);
      c4:	4525                	li	a0,9
      c6:	00001097          	auipc	ra,0x1
      ca:	c34080e7          	jalr	-972(ra) # cfa <kthread_exit>
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
      e4:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa704243>
      e8:	fcf42c23          	sw	a5,-40(s0)
      ec:	fc040e23          	sb	zero,-36(s0)
      f0:	1f400493          	li	s1,500
    for(int i=0;i<500;i++){
        write(1, st, 5);
      f4:	4615                	li	a2,5
      f6:	fd840593          	addi	a1,s0,-40
      fa:	4505                	li	a0,1
      fc:	00001097          	auipc	ra,0x1
     100:	b56080e7          	jalr	-1194(ra) # c52 <write>
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
     120:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa704243>
     124:	fcf42c23          	sw	a5,-40(s0)
     128:	fc040e23          	sb	zero,-36(s0)
     12c:	1f400493          	li	s1,500
    for(int i=0;i<500;i++){
        write(1, st, 5);
     130:	4615                	li	a2,5
     132:	fd840593          	addi	a1,s0,-40
     136:	4505                	li	a0,1
     138:	00001097          	auipc	ra,0x1
     13c:	b1a080e7          	jalr	-1254(ra) # c52 <write>
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
     15a:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa704243>
     15e:	fef42423          	sw	a5,-24(s0)
     162:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
     166:	4615                	li	a2,5
     168:	fe840593          	addi	a1,s0,-24
     16c:	4505                	li	a0,1
     16e:	00001097          	auipc	ra,0x1
     172:	ae4080e7          	jalr	-1308(ra) # c52 <write>
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
     190:	a9e080e7          	jalr	-1378(ra) # c2a <fork>
     194:	84aa                	mv	s1,a0
    if(pid==0){
     196:	ed05                	bnez	a0,1ce <test_sigkill+0x50>
        sleep(5);
     198:	4515                	li	a0,5
     19a:	00001097          	auipc	ra,0x1
     19e:	b28080e7          	jalr	-1240(ra) # cc2 <sleep>
            printf("about to get killed %d\n",i);
     1a2:	00001997          	auipc	s3,0x1
     1a6:	02e98993          	addi	s3,s3,46 # 11d0 <malloc+0x130>
        for(int i=0;i<300;i++)
     1aa:	12c00913          	li	s2,300
            printf("about to get killed %d\n",i);
     1ae:	85a6                	mv	a1,s1
     1b0:	854e                	mv	a0,s3
     1b2:	00001097          	auipc	ra,0x1
     1b6:	e30080e7          	jalr	-464(ra) # fe2 <printf>
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
     1d4:	af2080e7          	jalr	-1294(ra) # cc2 <sleep>
        printf("parent send signal to to kill child\n");
     1d8:	00001517          	auipc	a0,0x1
     1dc:	01050513          	addi	a0,a0,16 # 11e8 <malloc+0x148>
     1e0:	00001097          	auipc	ra,0x1
     1e4:	e02080e7          	jalr	-510(ra) # fe2 <printf>
        printf("kill ret= %d\n",kill(pid, SIGKILL));
     1e8:	45a5                	li	a1,9
     1ea:	8526                	mv	a0,s1
     1ec:	00001097          	auipc	ra,0x1
     1f0:	a76080e7          	jalr	-1418(ra) # c62 <kill>
     1f4:	85aa                	mv	a1,a0
     1f6:	00001517          	auipc	a0,0x1
     1fa:	01a50513          	addi	a0,a0,26 # 1210 <malloc+0x170>
     1fe:	00001097          	auipc	ra,0x1
     202:	de4080e7          	jalr	-540(ra) # fe2 <printf>
        printf("parent wait for child\n");
     206:	00001517          	auipc	a0,0x1
     20a:	01a50513          	addi	a0,a0,26 # 1220 <malloc+0x180>
     20e:	00001097          	auipc	ra,0x1
     212:	dd4080e7          	jalr	-556(ra) # fe2 <printf>
        wait(0);
     216:	4501                	li	a0,0
     218:	00001097          	auipc	ra,0x1
     21c:	a22080e7          	jalr	-1502(ra) # c3a <wait>
        printf("parent: child is dead\n");
     220:	00001517          	auipc	a0,0x1
     224:	01850513          	addi	a0,a0,24 # 1238 <malloc+0x198>
     228:	00001097          	auipc	ra,0x1
     22c:	dba080e7          	jalr	-582(ra) # fe2 <printf>
        sleep(10);
     230:	4529                	li	a0,10
     232:	00001097          	auipc	ra,0x1
     236:	a90080e7          	jalr	-1392(ra) # cc2 <sleep>
        exit(0);
     23a:	4501                	li	a0,0
     23c:	00001097          	auipc	ra,0x1
     240:	9f6080e7          	jalr	-1546(ra) # c32 <exit>

0000000000000244 <sig_handler>:
sig_handler(int signum){
     244:	1101                	addi	sp,sp,-32
     246:	ec06                	sd	ra,24(sp)
     248:	e822                	sd	s0,16(sp)
     24a:	1000                	addi	s0,sp,32
    char st[5] = "wap\n";
     24c:	0a7067b7          	lui	a5,0xa706
     250:	17778793          	addi	a5,a5,375 # a706177 <__global_pointer$+0xa704256>
     254:	fef42423          	sw	a5,-24(s0)
     258:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
     25c:	4615                	li	a2,5
     25e:	fe840593          	addi	a1,s0,-24
     262:	4505                	li	a0,1
     264:	00001097          	auipc	ra,0x1
     268:	9ee080e7          	jalr	-1554(ra) # c52 <write>
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
     284:	9aa080e7          	jalr	-1622(ra) # c2a <fork>
    int signum1=3;
    if(pid==0){
     288:	e569                	bnez	a0,352 <test_usersig+0xde>
        struct sigaction act;
        struct sigaction act2;

        printf("sighandler= %p\n",&sig_handler2);
     28a:	00000597          	auipc	a1,0x0
     28e:	ec458593          	addi	a1,a1,-316 # 14e <sig_handler2>
     292:	00001517          	auipc	a0,0x1
     296:	fbe50513          	addi	a0,a0,-66 # 1250 <malloc+0x1b0>
     29a:	00001097          	auipc	ra,0x1
     29e:	d48080e7          	jalr	-696(ra) # fe2 <printf>
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
     2cc:	a12080e7          	jalr	-1518(ra) # cda <sigaction>
     2d0:	84aa                	mv	s1,a0
        printf("old act->sa handler= %p, mask=%d\n",oldact.sa_handler,oldact.sigmask);
     2d2:	fd842603          	lw	a2,-40(s0)
     2d6:	fd043583          	ld	a1,-48(s0)
     2da:	00001517          	auipc	a0,0x1
     2de:	f8650513          	addi	a0,a0,-122 # 1260 <malloc+0x1c0>
     2e2:	00001097          	auipc	ra,0x1
     2e6:	d00080e7          	jalr	-768(ra) # fe2 <printf>
        printf("child return from sigaction = %d\n",ret);
     2ea:	85a6                	mv	a1,s1
     2ec:	00001517          	auipc	a0,0x1
     2f0:	f9c50513          	addi	a0,a0,-100 # 1288 <malloc+0x1e8>
     2f4:	00001097          	auipc	ra,0x1
     2f8:	cee080e7          	jalr	-786(ra) # fe2 <printf>
        sleep(10);
     2fc:	4529                	li	a0,10
     2fe:	00001097          	auipc	ra,0x1
     302:	9c4080e7          	jalr	-1596(ra) # cc2 <sleep>
     306:	44a9                	li	s1,10
        for(int i=0;i<10;i++){
            printf("child doing stuff before exit \n");
     308:	00001917          	auipc	s2,0x1
     30c:	fa890913          	addi	s2,s2,-88 # 12b0 <malloc+0x210>
     310:	854a                	mv	a0,s2
     312:	00001097          	auipc	ra,0x1
     316:	cd0080e7          	jalr	-816(ra) # fe2 <printf>
        for(int i=0;i<10;i++){
     31a:	34fd                	addiw	s1,s1,-1
     31c:	f8f5                	bnez	s1,310 <test_usersig+0x9c>
        }
        ret=sigaction(signum1,&act,&oldact);
     31e:	fd040613          	addi	a2,s0,-48
     322:	fc040593          	addi	a1,s0,-64
     326:	450d                	li	a0,3
     328:	00001097          	auipc	ra,0x1
     32c:	9b2080e7          	jalr	-1614(ra) # cda <sigaction>
        printf("oldact should be the same as new act before \n oldact->mask=%d \t oldact->sa_handler=%d \n",oldact.sigmask,oldact.sa_handler);
     330:	fd043603          	ld	a2,-48(s0)
     334:	fd842583          	lw	a1,-40(s0)
     338:	00001517          	auipc	a0,0x1
     33c:	f9850513          	addi	a0,a0,-104 # 12d0 <malloc+0x230>
     340:	00001097          	auipc	ra,0x1
     344:	ca2080e7          	jalr	-862(ra) # fe2 <printf>

        exit(0);
     348:	4501                	li	a0,0
     34a:	00001097          	auipc	ra,0x1
     34e:	8e8080e7          	jalr	-1816(ra) # c32 <exit>
     352:	84aa                	mv	s1,a0

    }
    else{
        sleep(5);
     354:	4515                	li	a0,5
     356:	00001097          	auipc	ra,0x1
     35a:	96c080e7          	jalr	-1684(ra) # cc2 <sleep>
        printf("parent send sig 3 to child ret=%d\n",kill(pid,signum1));
     35e:	458d                	li	a1,3
     360:	8526                	mv	a0,s1
     362:	00001097          	auipc	ra,0x1
     366:	900080e7          	jalr	-1792(ra) # c62 <kill>
     36a:	85aa                	mv	a1,a0
     36c:	00001517          	auipc	a0,0x1
     370:	fbc50513          	addi	a0,a0,-68 # 1328 <malloc+0x288>
     374:	00001097          	auipc	ra,0x1
     378:	c6e080e7          	jalr	-914(ra) # fe2 <printf>
        // printf("parent send sig 4 to child ret=%d\n",kill(pid,4));

        wait(0);
     37c:	4501                	li	a0,0
     37e:	00001097          	auipc	ra,0x1
     382:	8bc080e7          	jalr	-1860(ra) # c3a <wait>
        exit(0);
     386:	4501                	li	a0,0
     388:	00001097          	auipc	ra,0x1
     38c:	8aa080e7          	jalr	-1878(ra) # c32 <exit>

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
     3a6:	930080e7          	jalr	-1744(ra) # cd2 <sigprocmask>
    printf("got %d from calling to sigprocmask\n",ans);
     3aa:	0005059b          	sext.w	a1,a0
     3ae:	00001517          	auipc	a0,0x1
     3b2:	fa250513          	addi	a0,a0,-94 # 1350 <malloc+0x2b0>
     3b6:	00001097          	auipc	ra,0x1
     3ba:	c2c080e7          	jalr	-980(ra) # fe2 <printf>
    int pid=fork();
     3be:	00001097          	auipc	ra,0x1
     3c2:	86c080e7          	jalr	-1940(ra) # c2a <fork>
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
     3d0:	8f6080e7          	jalr	-1802(ra) # cc2 <sleep>
        printf("parent: sent signal 22 to child ->child shuld block\n");
     3d4:	00001517          	auipc	a0,0x1
     3d8:	fc450513          	addi	a0,a0,-60 # 1398 <malloc+0x2f8>
     3dc:	00001097          	auipc	ra,0x1
     3e0:	c06080e7          	jalr	-1018(ra) # fe2 <printf>
     3e4:	44a9                	li	s1,10
        for(int i=0; i<10;i++){
            kill(pid,signum1);
     3e6:	45d9                	li	a1,22
     3e8:	854a                	mv	a0,s2
     3ea:	00001097          	auipc	ra,0x1
     3ee:	878080e7          	jalr	-1928(ra) # c62 <kill>
        for(int i=0; i<10;i++){
     3f2:	34fd                	addiw	s1,s1,-1
     3f4:	f8ed                	bnez	s1,3e6 <test_block+0x56>
        }
        sleep(10);
     3f6:	4529                	li	a0,10
     3f8:	00001097          	auipc	ra,0x1
     3fc:	8ca080e7          	jalr	-1846(ra) # cc2 <sleep>
        kill(pid,signum2);
     400:	45dd                	li	a1,23
     402:	854a                	mv	a0,s2
     404:	00001097          	auipc	ra,0x1
     408:	85e080e7          	jalr	-1954(ra) # c62 <kill>

        printf("parent: sent signal 23 to child ->child shuld die\n");
     40c:	00001517          	auipc	a0,0x1
     410:	fc450513          	addi	a0,a0,-60 # 13d0 <malloc+0x330>
     414:	00001097          	auipc	ra,0x1
     418:	bce080e7          	jalr	-1074(ra) # fe2 <printf>
        wait(0);
     41c:	4501                	li	a0,0
     41e:	00001097          	auipc	ra,0x1
     422:	81c080e7          	jalr	-2020(ra) # c3a <wait>
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
     43a:	88c080e7          	jalr	-1908(ra) # cc2 <sleep>
            printf("child blocking signal %d \n",i);
     43e:	00001997          	auipc	s3,0x1
     442:	f3a98993          	addi	s3,s3,-198 # 1378 <malloc+0x2d8>
        for(int i=0;i<1000;i++){
     446:	3e800493          	li	s1,1000
            sleep(1);
     44a:	4505                	li	a0,1
     44c:	00001097          	auipc	ra,0x1
     450:	876080e7          	jalr	-1930(ra) # cc2 <sleep>
            printf("child blocking signal %d \n",i);
     454:	85ca                	mv	a1,s2
     456:	854e                	mv	a0,s3
     458:	00001097          	auipc	ra,0x1
     45c:	b8a080e7          	jalr	-1142(ra) # fe2 <printf>
        for(int i=0;i<1000;i++){
     460:	2905                	addiw	s2,s2,1
     462:	fe9914e3          	bne	s2,s1,44a <test_block+0xba>
        exit(0);
     466:	4501                	li	a0,0
     468:	00000097          	auipc	ra,0x0
     46c:	7ca080e7          	jalr	1994(ra) # c32 <exit>

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
     482:	7ac080e7          	jalr	1964(ra) # c2a <fork>
     486:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
     488:	e915                	bnez	a0,4bc <test_stop_cont+0x4c>
        sleep(2);
     48a:	4509                	li	a0,2
     48c:	00001097          	auipc	ra,0x1
     490:	836080e7          	jalr	-1994(ra) # cc2 <sleep>
        for(i=0;i<500;i++){
            printf("%d\n ", i);
     494:	00001997          	auipc	s3,0x1
     498:	f7498993          	addi	s3,s3,-140 # 1408 <malloc+0x368>
        for(i=0;i<500;i++){
     49c:	1f400913          	li	s2,500
            printf("%d\n ", i);
     4a0:	85a6                	mv	a1,s1
     4a2:	854e                	mv	a0,s3
     4a4:	00001097          	auipc	ra,0x1
     4a8:	b3e080e7          	jalr	-1218(ra) # fe2 <printf>
        for(i=0;i<500;i++){
     4ac:	2485                	addiw	s1,s1,1
     4ae:	ff2499e3          	bne	s1,s2,4a0 <test_stop_cont+0x30>
        }
        exit(0);
     4b2:	4501                	li	a0,0
     4b4:	00000097          	auipc	ra,0x0
     4b8:	77e080e7          	jalr	1918(ra) # c32 <exit>
    }else{
        printf("son pid=%d, dad pid=%d\n", pid, getpid());
     4bc:	00000097          	auipc	ra,0x0
     4c0:	7f6080e7          	jalr	2038(ra) # cb2 <getpid>
     4c4:	862a                	mv	a2,a0
     4c6:	85a6                	mv	a1,s1
     4c8:	00001517          	auipc	a0,0x1
     4cc:	f4850513          	addi	a0,a0,-184 # 1410 <malloc+0x370>
     4d0:	00001097          	auipc	ra,0x1
     4d4:	b12080e7          	jalr	-1262(ra) # fe2 <printf>
        sleep(5);
     4d8:	4515                	li	a0,5
     4da:	00000097          	auipc	ra,0x0
     4de:	7e8080e7          	jalr	2024(ra) # cc2 <sleep>
        printf("parent send stop ret= %d\n", kill(pid, SIGSTOP));
     4e2:	45c5                	li	a1,17
     4e4:	8526                	mv	a0,s1
     4e6:	00000097          	auipc	ra,0x0
     4ea:	77c080e7          	jalr	1916(ra) # c62 <kill>
     4ee:	85aa                	mv	a1,a0
     4f0:	00001517          	auipc	a0,0x1
     4f4:	f3850513          	addi	a0,a0,-200 # 1428 <malloc+0x388>
     4f8:	00001097          	auipc	ra,0x1
     4fc:	aea080e7          	jalr	-1302(ra) # fe2 <printf>
        sleep(50);
     500:	03200513          	li	a0,50
     504:	00000097          	auipc	ra,0x0
     508:	7be080e7          	jalr	1982(ra) # cc2 <sleep>
        printf("parent send continue ret= %d\n", kill(pid, SIGCONT));
     50c:	45cd                	li	a1,19
     50e:	8526                	mv	a0,s1
     510:	00000097          	auipc	ra,0x0
     514:	752080e7          	jalr	1874(ra) # c62 <kill>
     518:	85aa                	mv	a1,a0
     51a:	00001517          	auipc	a0,0x1
     51e:	f2e50513          	addi	a0,a0,-210 # 1448 <malloc+0x3a8>
     522:	00001097          	auipc	ra,0x1
     526:	ac0080e7          	jalr	-1344(ra) # fe2 <printf>
        wait(0);
     52a:	4501                	li	a0,0
     52c:	00000097          	auipc	ra,0x0
     530:	70e080e7          	jalr	1806(ra) # c3a <wait>
        // for(int i=0;i<100;i++)
        //  printf("parent..");
        sleep(10);
     534:	4529                	li	a0,10
     536:	00000097          	auipc	ra,0x0
     53a:	78c080e7          	jalr	1932(ra) # cc2 <sleep>
        exit(0);
     53e:	4501                	li	a0,0
     540:	00000097          	auipc	ra,0x0
     544:	6f2080e7          	jalr	1778(ra) # c32 <exit>

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
     55a:	6d4080e7          	jalr	1748(ra) # c2a <fork>
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
     568:	f6c50513          	addi	a0,a0,-148 # 14d0 <malloc+0x430>
     56c:	00001097          	auipc	ra,0x1
     570:	a76080e7          	jalr	-1418(ra) # fe2 <printf>
        sleep(5);
     574:	4515                	li	a0,5
     576:	00000097          	auipc	ra,0x0
     57a:	74c080e7          	jalr	1868(ra) # cc2 <sleep>
        kill(pid,signum);
     57e:	45d9                	li	a1,22
     580:	8526                	mv	a0,s1
     582:	00000097          	auipc	ra,0x0
     586:	6e0080e7          	jalr	1760(ra) # c62 <kill>
        wait(0);
     58a:	4501                	li	a0,0
     58c:	00000097          	auipc	ra,0x0
     590:	6ae080e7          	jalr	1710(ra) # c3a <wait>

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
     5a8:	afc080e7          	jalr	-1284(ra) # 10a0 <malloc>
     5ac:	89aa                	mv	s3,a0
        oldAct=malloc(sizeof(sigaction));
     5ae:	4505                	li	a0,1
     5b0:	00001097          	auipc	ra,0x1
     5b4:	af0080e7          	jalr	-1296(ra) # 10a0 <malloc>
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
     5ce:	710080e7          	jalr	1808(ra) # cda <sigaction>
     5d2:	85aa                	mv	a1,a0
        printf("ans from sigaction %d, old act returned is: mask= %d address= %d\n",ans,oldAct->sigmask,(uint64)oldAct->sa_handler);
     5d4:	00093683          	ld	a3,0(s2)
     5d8:	00892603          	lw	a2,8(s2)
     5dc:	00001517          	auipc	a0,0x1
     5e0:	e8c50513          	addi	a0,a0,-372 # 1468 <malloc+0x3c8>
     5e4:	00001097          	auipc	ra,0x1
     5e8:	9fe080e7          	jalr	-1538(ra) # fe2 <printf>
        sleep(6);
     5ec:	4519                	li	a0,6
     5ee:	00000097          	auipc	ra,0x0
     5f2:	6d4080e7          	jalr	1748(ra) # cc2 <sleep>
            printf("child ignoring signal %d\n",i);
     5f6:	00001997          	auipc	s3,0x1
     5fa:	eba98993          	addi	s3,s3,-326 # 14b0 <malloc+0x410>
        for(int i=0;i<300;i++){
     5fe:	12c00913          	li	s2,300
            printf("child ignoring signal %d\n",i);
     602:	85a6                	mv	a1,s1
     604:	854e                	mv	a0,s3
     606:	00001097          	auipc	ra,0x1
     60a:	9dc080e7          	jalr	-1572(ra) # fe2 <printf>
        for(int i=0;i<300;i++){
     60e:	2485                	addiw	s1,s1,1
     610:	ff2499e3          	bne	s1,s2,602 <test_ignore+0xba>
        exit(0);
     614:	4501                	li	a0,0
     616:	00000097          	auipc	ra,0x0
     61a:	61c080e7          	jalr	1564(ra) # c32 <exit>

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
     638:	eac50513          	addi	a0,a0,-340 # 14e0 <malloc+0x440>
     63c:	00001097          	auipc	ra,0x1
     640:	9a6080e7          	jalr	-1626(ra) # fe2 <printf>
    printf("sighandler2= %p\n", &sig_handler_loop2);
     644:	00000597          	auipc	a1,0x0
     648:	ace58593          	addi	a1,a1,-1330 # 112 <sig_handler_loop2>
     64c:	00001517          	auipc	a0,0x1
     650:	eac50513          	addi	a0,a0,-340 # 14f8 <malloc+0x458>
     654:	00001097          	auipc	ra,0x1
     658:	98e080e7          	jalr	-1650(ra) # fe2 <printf>


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
     67c:	5b2080e7          	jalr	1458(ra) # c2a <fork>
     680:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
     682:	ed15                	bnez	a0,6be <test_user_handler_kill+0xa0>
        int ret=sigaction(3,&act,&oldact);
     684:	fb040613          	addi	a2,s0,-80
     688:	fc040593          	addi	a1,s0,-64
     68c:	450d                	li	a0,3
     68e:	00000097          	auipc	ra,0x0
     692:	64c080e7          	jalr	1612(ra) # cda <sigaction>
        for(i=0;i<500;i++)
            printf("out-side handler %d\n ", i);
     696:	00001997          	auipc	s3,0x1
     69a:	e7a98993          	addi	s3,s3,-390 # 1510 <malloc+0x470>
        for(i=0;i<500;i++)
     69e:	1f400913          	li	s2,500
            printf("out-side handler %d\n ", i);
     6a2:	85a6                	mv	a1,s1
     6a4:	854e                	mv	a0,s3
     6a6:	00001097          	auipc	ra,0x1
     6aa:	93c080e7          	jalr	-1732(ra) # fe2 <printf>
        for(i=0;i<500;i++)
     6ae:	2485                	addiw	s1,s1,1
     6b0:	ff2499e3          	bne	s1,s2,6a2 <test_user_handler_kill+0x84>
        exit(0);
     6b4:	4501                	li	a0,0
     6b6:	00000097          	auipc	ra,0x0
     6ba:	57c080e7          	jalr	1404(ra) # c32 <exit>
    }else{
        printf("son pid=%d, dad pid=%d\n",pid, getpid());
     6be:	00000097          	auipc	ra,0x0
     6c2:	5f4080e7          	jalr	1524(ra) # cb2 <getpid>
     6c6:	862a                	mv	a2,a0
     6c8:	85a6                	mv	a1,s1
     6ca:	00001517          	auipc	a0,0x1
     6ce:	d4650513          	addi	a0,a0,-698 # 1410 <malloc+0x370>
     6d2:	00001097          	auipc	ra,0x1
     6d6:	910080e7          	jalr	-1776(ra) # fe2 <printf>
        sleep(5);
     6da:	4515                	li	a0,5
     6dc:	00000097          	auipc	ra,0x0
     6e0:	5e6080e7          	jalr	1510(ra) # cc2 <sleep>
        printf("parent send loop ret= %d\n",kill(pid, 3));
     6e4:	458d                	li	a1,3
     6e6:	8526                	mv	a0,s1
     6e8:	00000097          	auipc	ra,0x0
     6ec:	57a080e7          	jalr	1402(ra) # c62 <kill>
     6f0:	85aa                	mv	a1,a0
     6f2:	00001517          	auipc	a0,0x1
     6f6:	e3650513          	addi	a0,a0,-458 # 1528 <malloc+0x488>
     6fa:	00001097          	auipc	ra,0x1
     6fe:	8e8080e7          	jalr	-1816(ra) # fe2 <printf>
        sleep(20);
     702:	4551                	li	a0,20
     704:	00000097          	auipc	ra,0x0
     708:	5be080e7          	jalr	1470(ra) # cc2 <sleep>
        printf("parent send kill ret= %d\n",kill(pid, SIGKILL));
     70c:	45a5                	li	a1,9
     70e:	8526                	mv	a0,s1
     710:	00000097          	auipc	ra,0x0
     714:	552080e7          	jalr	1362(ra) # c62 <kill>
     718:	85aa                	mv	a1,a0
     71a:	00001517          	auipc	a0,0x1
     71e:	e2e50513          	addi	a0,a0,-466 # 1548 <malloc+0x4a8>
     722:	00001097          	auipc	ra,0x1
     726:	8c0080e7          	jalr	-1856(ra) # fe2 <printf>
        wait(0);
     72a:	4501                	li	a0,0
     72c:	00000097          	auipc	ra,0x0
     730:	50e080e7          	jalr	1294(ra) # c3a <wait>
        printf("parent exiting\n");
     734:	00001517          	auipc	a0,0x1
     738:	e3450513          	addi	a0,a0,-460 # 1568 <malloc+0x4c8>
     73c:	00001097          	auipc	ra,0x1
     740:	8a6080e7          	jalr	-1882(ra) # fe2 <printf>
        exit(0);
     744:	4501                	li	a0,0
     746:	00000097          	auipc	ra,0x0
     74a:	4ec080e7          	jalr	1260(ra) # c32 <exit>

000000000000074e <thread_test>:
    }
}

//TODO delete func
void thread_test(char *s){
     74e:	7179                	addi	sp,sp,-48
     750:	f406                	sd	ra,40(sp)
     752:	f022                	sd	s0,32(sp)
     754:	ec26                	sd	s1,24(sp)
     756:	e84a                	sd	s2,16(sp)
     758:	1800                	addi	s0,sp,48
    int tid;
    int status;
    void* stack = malloc(4000);
     75a:	6505                	lui	a0,0x1
     75c:	fa050513          	addi	a0,a0,-96 # fa0 <vprintf+0x1ca>
     760:	00001097          	auipc	ra,0x1
     764:	940080e7          	jalr	-1728(ra) # 10a0 <malloc>
     768:	84aa                	mv	s1,a0
    printf("father tid is = %d\n",kthread_id());
     76a:	00000097          	auipc	ra,0x0
     76e:	588080e7          	jalr	1416(ra) # cf2 <kthread_id>
     772:	85aa                	mv	a1,a0
     774:	00001517          	auipc	a0,0x1
     778:	e0450513          	addi	a0,a0,-508 # 1578 <malloc+0x4d8>
     77c:	00001097          	auipc	ra,0x1
     780:	866080e7          	jalr	-1946(ra) # fe2 <printf>
    tid = kthread_create(test_thread, stack);
     784:	85a6                	mv	a1,s1
     786:	00000517          	auipc	a0,0x0
     78a:	87a50513          	addi	a0,a0,-1926 # 0 <test_thread>
     78e:	00000097          	auipc	ra,0x0
     792:	55c080e7          	jalr	1372(ra) # cea <kthread_create>
     796:	892a                	mv	s2,a0
    printf("child tid %d",tid);
     798:	85aa                	mv	a1,a0
     79a:	00001517          	auipc	a0,0x1
     79e:	df650513          	addi	a0,a0,-522 # 1590 <malloc+0x4f0>
     7a2:	00001097          	auipc	ra,0x1
     7a6:	840080e7          	jalr	-1984(ra) # fe2 <printf>
    printf("father tid is = %d\n",kthread_id());
     7aa:	00000097          	auipc	ra,0x0
     7ae:	548080e7          	jalr	1352(ra) # cf2 <kthread_id>
     7b2:	85aa                	mv	a1,a0
     7b4:	00001517          	auipc	a0,0x1
     7b8:	dc450513          	addi	a0,a0,-572 # 1578 <malloc+0x4d8>
     7bc:	00001097          	auipc	ra,0x1
     7c0:	826080e7          	jalr	-2010(ra) # fe2 <printf>

    int ans =kthread_join(tid, &status);
     7c4:	fdc40593          	addi	a1,s0,-36
     7c8:	854a                	mv	a0,s2
     7ca:	00000097          	auipc	ra,0x0
     7ce:	538080e7          	jalr	1336(ra) # d02 <kthread_join>
     7d2:	892a                	mv	s2,a0
    printf("kthread join ret =%d , my tid =%d\n",ans,kthread_id());
     7d4:	00000097          	auipc	ra,0x0
     7d8:	51e080e7          	jalr	1310(ra) # cf2 <kthread_id>
     7dc:	862a                	mv	a2,a0
     7de:	85ca                	mv	a1,s2
     7e0:	00001517          	auipc	a0,0x1
     7e4:	dc050513          	addi	a0,a0,-576 # 15a0 <malloc+0x500>
     7e8:	00000097          	auipc	ra,0x0
     7ec:	7fa080e7          	jalr	2042(ra) # fe2 <printf>
    tid = kthread_id();
     7f0:	00000097          	auipc	ra,0x0
     7f4:	502080e7          	jalr	1282(ra) # cf2 <kthread_id>
     7f8:	892a                	mv	s2,a0
    free(stack);
     7fa:	8526                	mv	a0,s1
     7fc:	00001097          	auipc	ra,0x1
     800:	81c080e7          	jalr	-2020(ra) # 1018 <free>
    printf("Finished testing threads, main thread id: %d, %d\n", tid,status);
     804:	fdc42603          	lw	a2,-36(s0)
     808:	85ca                	mv	a1,s2
     80a:	00001517          	auipc	a0,0x1
     80e:	dbe50513          	addi	a0,a0,-578 # 15c8 <malloc+0x528>
     812:	00000097          	auipc	ra,0x0
     816:	7d0080e7          	jalr	2000(ra) # fe2 <printf>
}
     81a:	70a2                	ld	ra,40(sp)
     81c:	7402                	ld	s0,32(sp)
     81e:	64e2                	ld	s1,24(sp)
     820:	6942                	ld	s2,16(sp)
     822:	6145                	addi	sp,sp,48
     824:	8082                	ret

0000000000000826 <thread_test2>:
void thread_test2(char *s){
     826:	1101                	addi	sp,sp,-32
     828:	ec06                	sd	ra,24(sp)
     82a:	e822                	sd	s0,16(sp)
     82c:	e426                	sd	s1,8(sp)
     82e:	e04a                	sd	s2,0(sp)
     830:	1000                	addi	s0,sp,32
    int tid;
    int status;
    void* stack = malloc(4000);
     832:	6505                	lui	a0,0x1
     834:	fa050513          	addi	a0,a0,-96 # fa0 <vprintf+0x1ca>
     838:	00001097          	auipc	ra,0x1
     83c:	868080e7          	jalr	-1944(ra) # 10a0 <malloc>
     840:	84aa                	mv	s1,a0
    printf("after malloc\n");
     842:	00001517          	auipc	a0,0x1
     846:	dbe50513          	addi	a0,a0,-578 # 1600 <malloc+0x560>
     84a:	00000097          	auipc	ra,0x0
     84e:	798080e7          	jalr	1944(ra) # fe2 <printf>
    printf("add of func for new thread : %p\n",&test_thread);
     852:	fffff597          	auipc	a1,0xfffff
     856:	7ae58593          	addi	a1,a1,1966 # 0 <test_thread>
     85a:	00001517          	auipc	a0,0x1
     85e:	db650513          	addi	a0,a0,-586 # 1610 <malloc+0x570>
     862:	00000097          	auipc	ra,0x0
     866:	780080e7          	jalr	1920(ra) # fe2 <printf>
    printf("add of func for new thread : %p\n",&test_thread2);
     86a:	00000597          	auipc	a1,0x0
     86e:	82e58593          	addi	a1,a1,-2002 # 98 <test_thread2>
     872:	00001517          	auipc	a0,0x1
     876:	d9e50513          	addi	a0,a0,-610 # 1610 <malloc+0x570>
     87a:	00000097          	auipc	ra,0x0
     87e:	768080e7          	jalr	1896(ra) # fe2 <printf>

    tid = kthread_create(&test_thread2, stack);
     882:	85a6                	mv	a1,s1
     884:	00000517          	auipc	a0,0x0
     888:	81450513          	addi	a0,a0,-2028 # 98 <test_thread2>
     88c:	00000097          	auipc	ra,0x0
     890:	45e080e7          	jalr	1118(ra) # cea <kthread_create>
     894:	85aa                	mv	a1,a0
    
    printf("after create %d \n",tid);
     896:	00001517          	auipc	a0,0x1
     89a:	da250513          	addi	a0,a0,-606 # 1638 <malloc+0x598>
     89e:	00000097          	auipc	ra,0x0
     8a2:	744080e7          	jalr	1860(ra) # fe2 <printf>

    sleep(5);
     8a6:	4515                	li	a0,5
     8a8:	00000097          	auipc	ra,0x0
     8ac:	41a080e7          	jalr	1050(ra) # cc2 <sleep>
    printf("after kthread\n");
     8b0:	00001517          	auipc	a0,0x1
     8b4:	da050513          	addi	a0,a0,-608 # 1650 <malloc+0x5b0>
     8b8:	00000097          	auipc	ra,0x0
     8bc:	72a080e7          	jalr	1834(ra) # fe2 <printf>
    tid = kthread_id();
     8c0:	00000097          	auipc	ra,0x0
     8c4:	432080e7          	jalr	1074(ra) # cf2 <kthread_id>
     8c8:	892a                	mv	s2,a0
    free(stack);
     8ca:	8526                	mv	a0,s1
     8cc:	00000097          	auipc	ra,0x0
     8d0:	74c080e7          	jalr	1868(ra) # 1018 <free>
    printf("Finished testing threads, main thread id: %d, %d\n", tid,status);
     8d4:	4601                	li	a2,0
     8d6:	85ca                	mv	a1,s2
     8d8:	00001517          	auipc	a0,0x1
     8dc:	cf050513          	addi	a0,a0,-784 # 15c8 <malloc+0x528>
     8e0:	00000097          	auipc	ra,0x0
     8e4:	702080e7          	jalr	1794(ra) # fe2 <printf>
}
     8e8:	60e2                	ld	ra,24(sp)
     8ea:	6442                	ld	s0,16(sp)
     8ec:	64a2                	ld	s1,8(sp)
     8ee:	6902                	ld	s2,0(sp)
     8f0:	6105                	addi	sp,sp,32
     8f2:	8082                	ret

00000000000008f4 <very_easy_thread_test>:

void very_easy_thread_test(char *s){
     8f4:	1101                	addi	sp,sp,-32
     8f6:	ec06                	sd	ra,24(sp)
     8f8:	e822                	sd	s0,16(sp)
     8fa:	e426                	sd	s1,8(sp)
     8fc:	e04a                	sd	s2,0(sp)
     8fe:	1000                	addi	s0,sp,32
    int tid;
    int status;
    void* stack = malloc(4000);
     900:	6505                	lui	a0,0x1
     902:	fa050513          	addi	a0,a0,-96 # fa0 <vprintf+0x1ca>
     906:	00000097          	auipc	ra,0x0
     90a:	79a080e7          	jalr	1946(ra) # 10a0 <malloc>
     90e:	84aa                	mv	s1,a0
    printf("add of func for new thread : %p\n",&test_thread);
     910:	fffff597          	auipc	a1,0xfffff
     914:	6f058593          	addi	a1,a1,1776 # 0 <test_thread>
     918:	00001517          	auipc	a0,0x1
     91c:	cf850513          	addi	a0,a0,-776 # 1610 <malloc+0x570>
     920:	00000097          	auipc	ra,0x0
     924:	6c2080e7          	jalr	1730(ra) # fe2 <printf>

    tid = kthread_create(&test_thread_loop, stack);
     928:	85a6                	mv	a1,s1
     92a:	fffff517          	auipc	a0,0xfffff
     92e:	71450513          	addi	a0,a0,1812 # 3e <test_thread_loop>
     932:	00000097          	auipc	ra,0x0
     936:	3b8080e7          	jalr	952(ra) # cea <kthread_create>
     93a:	892a                	mv	s2,a0
    
    printf("after create ret tid= %d mytid= %d\n",tid,kthread_id());
     93c:	00000097          	auipc	ra,0x0
     940:	3b6080e7          	jalr	950(ra) # cf2 <kthread_id>
     944:	862a                	mv	a2,a0
     946:	85ca                	mv	a1,s2
     948:	00001517          	auipc	a0,0x1
     94c:	d1850513          	addi	a0,a0,-744 # 1660 <malloc+0x5c0>
     950:	00000097          	auipc	ra,0x0
     954:	692080e7          	jalr	1682(ra) # fe2 <printf>

    free(stack);
     958:	8526                	mv	a0,s1
     95a:	00000097          	auipc	ra,0x0
     95e:	6be080e7          	jalr	1726(ra) # 1018 <free>
    printf("Finished testing threads, main thread id: %d\n", kthread_id());
     962:	00000097          	auipc	ra,0x0
     966:	390080e7          	jalr	912(ra) # cf2 <kthread_id>
     96a:	85aa                	mv	a1,a0
     96c:	00001517          	auipc	a0,0x1
     970:	d1c50513          	addi	a0,a0,-740 # 1688 <malloc+0x5e8>
     974:	00000097          	auipc	ra,0x0
     978:	66e080e7          	jalr	1646(ra) # fe2 <printf>
    kthread_exit(0);
     97c:	4501                	li	a0,0
     97e:	00000097          	auipc	ra,0x0
     982:	37c080e7          	jalr	892(ra) # cfa <kthread_exit>
}
     986:	60e2                	ld	ra,24(sp)
     988:	6442                	ld	s0,16(sp)
     98a:	64a2                	ld	s1,8(sp)
     98c:	6902                	ld	s2,0(sp)
     98e:	6105                	addi	sp,sp,32
     990:	8082                	ret

0000000000000992 <main>:

int main(){
     992:	1141                	addi	sp,sp,-16
     994:	e406                	sd	ra,8(sp)
     996:	e022                	sd	s0,0(sp)
     998:	0800                	addi	s0,sp,16
    // printf("-----------------------------test_ignore-----------------------------\n");
    // test_ignore();
    // printf("-----------------------------test_user_handler_then_kill-----------------------------\n");
    // test_user_handler_kill();

    printf("-----------------------------thread_test-----------------------------\n");
     99a:	00001517          	auipc	a0,0x1
     99e:	d1e50513          	addi	a0,a0,-738 # 16b8 <malloc+0x618>
     9a2:	00000097          	auipc	ra,0x0
     9a6:	640080e7          	jalr	1600(ra) # fe2 <printf>
    thread_test("fuck");
     9aa:	00001517          	auipc	a0,0x1
     9ae:	d5650513          	addi	a0,a0,-682 # 1700 <malloc+0x660>
     9b2:	00000097          	auipc	ra,0x0
     9b6:	d9c080e7          	jalr	-612(ra) # 74e <thread_test>

    // printf("-----------------------------very easy thread test-----------------------------\n");
    // very_easy_thread_test("ff");

    exit(0);
     9ba:	4501                	li	a0,0
     9bc:	00000097          	auipc	ra,0x0
     9c0:	276080e7          	jalr	630(ra) # c32 <exit>

00000000000009c4 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     9c4:	1141                	addi	sp,sp,-16
     9c6:	e422                	sd	s0,8(sp)
     9c8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     9ca:	87aa                	mv	a5,a0
     9cc:	0585                	addi	a1,a1,1
     9ce:	0785                	addi	a5,a5,1
     9d0:	fff5c703          	lbu	a4,-1(a1)
     9d4:	fee78fa3          	sb	a4,-1(a5)
     9d8:	fb75                	bnez	a4,9cc <strcpy+0x8>
    ;
  return os;
}
     9da:	6422                	ld	s0,8(sp)
     9dc:	0141                	addi	sp,sp,16
     9de:	8082                	ret

00000000000009e0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     9e0:	1141                	addi	sp,sp,-16
     9e2:	e422                	sd	s0,8(sp)
     9e4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     9e6:	00054783          	lbu	a5,0(a0)
     9ea:	cb91                	beqz	a5,9fe <strcmp+0x1e>
     9ec:	0005c703          	lbu	a4,0(a1)
     9f0:	00f71763          	bne	a4,a5,9fe <strcmp+0x1e>
    p++, q++;
     9f4:	0505                	addi	a0,a0,1
     9f6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     9f8:	00054783          	lbu	a5,0(a0)
     9fc:	fbe5                	bnez	a5,9ec <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     9fe:	0005c503          	lbu	a0,0(a1)
}
     a02:	40a7853b          	subw	a0,a5,a0
     a06:	6422                	ld	s0,8(sp)
     a08:	0141                	addi	sp,sp,16
     a0a:	8082                	ret

0000000000000a0c <strlen>:

uint
strlen(const char *s)
{
     a0c:	1141                	addi	sp,sp,-16
     a0e:	e422                	sd	s0,8(sp)
     a10:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     a12:	00054783          	lbu	a5,0(a0)
     a16:	cf91                	beqz	a5,a32 <strlen+0x26>
     a18:	0505                	addi	a0,a0,1
     a1a:	87aa                	mv	a5,a0
     a1c:	4685                	li	a3,1
     a1e:	9e89                	subw	a3,a3,a0
     a20:	00f6853b          	addw	a0,a3,a5
     a24:	0785                	addi	a5,a5,1
     a26:	fff7c703          	lbu	a4,-1(a5)
     a2a:	fb7d                	bnez	a4,a20 <strlen+0x14>
    ;
  return n;
}
     a2c:	6422                	ld	s0,8(sp)
     a2e:	0141                	addi	sp,sp,16
     a30:	8082                	ret
  for(n = 0; s[n]; n++)
     a32:	4501                	li	a0,0
     a34:	bfe5                	j	a2c <strlen+0x20>

0000000000000a36 <memset>:

void*
memset(void *dst, int c, uint n)
{
     a36:	1141                	addi	sp,sp,-16
     a38:	e422                	sd	s0,8(sp)
     a3a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     a3c:	ca19                	beqz	a2,a52 <memset+0x1c>
     a3e:	87aa                	mv	a5,a0
     a40:	1602                	slli	a2,a2,0x20
     a42:	9201                	srli	a2,a2,0x20
     a44:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     a48:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     a4c:	0785                	addi	a5,a5,1
     a4e:	fee79de3          	bne	a5,a4,a48 <memset+0x12>
  }
  return dst;
}
     a52:	6422                	ld	s0,8(sp)
     a54:	0141                	addi	sp,sp,16
     a56:	8082                	ret

0000000000000a58 <strchr>:

char*
strchr(const char *s, char c)
{
     a58:	1141                	addi	sp,sp,-16
     a5a:	e422                	sd	s0,8(sp)
     a5c:	0800                	addi	s0,sp,16
  for(; *s; s++)
     a5e:	00054783          	lbu	a5,0(a0)
     a62:	cb99                	beqz	a5,a78 <strchr+0x20>
    if(*s == c)
     a64:	00f58763          	beq	a1,a5,a72 <strchr+0x1a>
  for(; *s; s++)
     a68:	0505                	addi	a0,a0,1
     a6a:	00054783          	lbu	a5,0(a0)
     a6e:	fbfd                	bnez	a5,a64 <strchr+0xc>
      return (char*)s;
  return 0;
     a70:	4501                	li	a0,0
}
     a72:	6422                	ld	s0,8(sp)
     a74:	0141                	addi	sp,sp,16
     a76:	8082                	ret
  return 0;
     a78:	4501                	li	a0,0
     a7a:	bfe5                	j	a72 <strchr+0x1a>

0000000000000a7c <gets>:

char*
gets(char *buf, int max)
{
     a7c:	711d                	addi	sp,sp,-96
     a7e:	ec86                	sd	ra,88(sp)
     a80:	e8a2                	sd	s0,80(sp)
     a82:	e4a6                	sd	s1,72(sp)
     a84:	e0ca                	sd	s2,64(sp)
     a86:	fc4e                	sd	s3,56(sp)
     a88:	f852                	sd	s4,48(sp)
     a8a:	f456                	sd	s5,40(sp)
     a8c:	f05a                	sd	s6,32(sp)
     a8e:	ec5e                	sd	s7,24(sp)
     a90:	1080                	addi	s0,sp,96
     a92:	8baa                	mv	s7,a0
     a94:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     a96:	892a                	mv	s2,a0
     a98:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     a9a:	4aa9                	li	s5,10
     a9c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     a9e:	89a6                	mv	s3,s1
     aa0:	2485                	addiw	s1,s1,1
     aa2:	0344d863          	bge	s1,s4,ad2 <gets+0x56>
    cc = read(0, &c, 1);
     aa6:	4605                	li	a2,1
     aa8:	faf40593          	addi	a1,s0,-81
     aac:	4501                	li	a0,0
     aae:	00000097          	auipc	ra,0x0
     ab2:	19c080e7          	jalr	412(ra) # c4a <read>
    if(cc < 1)
     ab6:	00a05e63          	blez	a0,ad2 <gets+0x56>
    buf[i++] = c;
     aba:	faf44783          	lbu	a5,-81(s0)
     abe:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     ac2:	01578763          	beq	a5,s5,ad0 <gets+0x54>
     ac6:	0905                	addi	s2,s2,1
     ac8:	fd679be3          	bne	a5,s6,a9e <gets+0x22>
  for(i=0; i+1 < max; ){
     acc:	89a6                	mv	s3,s1
     ace:	a011                	j	ad2 <gets+0x56>
     ad0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     ad2:	99de                	add	s3,s3,s7
     ad4:	00098023          	sb	zero,0(s3)
  return buf;
}
     ad8:	855e                	mv	a0,s7
     ada:	60e6                	ld	ra,88(sp)
     adc:	6446                	ld	s0,80(sp)
     ade:	64a6                	ld	s1,72(sp)
     ae0:	6906                	ld	s2,64(sp)
     ae2:	79e2                	ld	s3,56(sp)
     ae4:	7a42                	ld	s4,48(sp)
     ae6:	7aa2                	ld	s5,40(sp)
     ae8:	7b02                	ld	s6,32(sp)
     aea:	6be2                	ld	s7,24(sp)
     aec:	6125                	addi	sp,sp,96
     aee:	8082                	ret

0000000000000af0 <stat>:

int
stat(const char *n, struct stat *st)
{
     af0:	1101                	addi	sp,sp,-32
     af2:	ec06                	sd	ra,24(sp)
     af4:	e822                	sd	s0,16(sp)
     af6:	e426                	sd	s1,8(sp)
     af8:	e04a                	sd	s2,0(sp)
     afa:	1000                	addi	s0,sp,32
     afc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     afe:	4581                	li	a1,0
     b00:	00000097          	auipc	ra,0x0
     b04:	172080e7          	jalr	370(ra) # c72 <open>
  if(fd < 0)
     b08:	02054563          	bltz	a0,b32 <stat+0x42>
     b0c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     b0e:	85ca                	mv	a1,s2
     b10:	00000097          	auipc	ra,0x0
     b14:	17a080e7          	jalr	378(ra) # c8a <fstat>
     b18:	892a                	mv	s2,a0
  close(fd);
     b1a:	8526                	mv	a0,s1
     b1c:	00000097          	auipc	ra,0x0
     b20:	13e080e7          	jalr	318(ra) # c5a <close>
  return r;
}
     b24:	854a                	mv	a0,s2
     b26:	60e2                	ld	ra,24(sp)
     b28:	6442                	ld	s0,16(sp)
     b2a:	64a2                	ld	s1,8(sp)
     b2c:	6902                	ld	s2,0(sp)
     b2e:	6105                	addi	sp,sp,32
     b30:	8082                	ret
    return -1;
     b32:	597d                	li	s2,-1
     b34:	bfc5                	j	b24 <stat+0x34>

0000000000000b36 <atoi>:

int
atoi(const char *s)
{
     b36:	1141                	addi	sp,sp,-16
     b38:	e422                	sd	s0,8(sp)
     b3a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     b3c:	00054603          	lbu	a2,0(a0)
     b40:	fd06079b          	addiw	a5,a2,-48
     b44:	0ff7f793          	andi	a5,a5,255
     b48:	4725                	li	a4,9
     b4a:	02f76963          	bltu	a4,a5,b7c <atoi+0x46>
     b4e:	86aa                	mv	a3,a0
  n = 0;
     b50:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     b52:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     b54:	0685                	addi	a3,a3,1
     b56:	0025179b          	slliw	a5,a0,0x2
     b5a:	9fa9                	addw	a5,a5,a0
     b5c:	0017979b          	slliw	a5,a5,0x1
     b60:	9fb1                	addw	a5,a5,a2
     b62:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     b66:	0006c603          	lbu	a2,0(a3)
     b6a:	fd06071b          	addiw	a4,a2,-48
     b6e:	0ff77713          	andi	a4,a4,255
     b72:	fee5f1e3          	bgeu	a1,a4,b54 <atoi+0x1e>
  return n;
}
     b76:	6422                	ld	s0,8(sp)
     b78:	0141                	addi	sp,sp,16
     b7a:	8082                	ret
  n = 0;
     b7c:	4501                	li	a0,0
     b7e:	bfe5                	j	b76 <atoi+0x40>

0000000000000b80 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     b80:	1141                	addi	sp,sp,-16
     b82:	e422                	sd	s0,8(sp)
     b84:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     b86:	02b57463          	bgeu	a0,a1,bae <memmove+0x2e>
    while(n-- > 0)
     b8a:	00c05f63          	blez	a2,ba8 <memmove+0x28>
     b8e:	1602                	slli	a2,a2,0x20
     b90:	9201                	srli	a2,a2,0x20
     b92:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     b96:	872a                	mv	a4,a0
      *dst++ = *src++;
     b98:	0585                	addi	a1,a1,1
     b9a:	0705                	addi	a4,a4,1
     b9c:	fff5c683          	lbu	a3,-1(a1)
     ba0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     ba4:	fee79ae3          	bne	a5,a4,b98 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     ba8:	6422                	ld	s0,8(sp)
     baa:	0141                	addi	sp,sp,16
     bac:	8082                	ret
    dst += n;
     bae:	00c50733          	add	a4,a0,a2
    src += n;
     bb2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     bb4:	fec05ae3          	blez	a2,ba8 <memmove+0x28>
     bb8:	fff6079b          	addiw	a5,a2,-1
     bbc:	1782                	slli	a5,a5,0x20
     bbe:	9381                	srli	a5,a5,0x20
     bc0:	fff7c793          	not	a5,a5
     bc4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     bc6:	15fd                	addi	a1,a1,-1
     bc8:	177d                	addi	a4,a4,-1
     bca:	0005c683          	lbu	a3,0(a1)
     bce:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     bd2:	fee79ae3          	bne	a5,a4,bc6 <memmove+0x46>
     bd6:	bfc9                	j	ba8 <memmove+0x28>

0000000000000bd8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     bd8:	1141                	addi	sp,sp,-16
     bda:	e422                	sd	s0,8(sp)
     bdc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     bde:	ca05                	beqz	a2,c0e <memcmp+0x36>
     be0:	fff6069b          	addiw	a3,a2,-1
     be4:	1682                	slli	a3,a3,0x20
     be6:	9281                	srli	a3,a3,0x20
     be8:	0685                	addi	a3,a3,1
     bea:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     bec:	00054783          	lbu	a5,0(a0)
     bf0:	0005c703          	lbu	a4,0(a1)
     bf4:	00e79863          	bne	a5,a4,c04 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     bf8:	0505                	addi	a0,a0,1
    p2++;
     bfa:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     bfc:	fed518e3          	bne	a0,a3,bec <memcmp+0x14>
  }
  return 0;
     c00:	4501                	li	a0,0
     c02:	a019                	j	c08 <memcmp+0x30>
      return *p1 - *p2;
     c04:	40e7853b          	subw	a0,a5,a4
}
     c08:	6422                	ld	s0,8(sp)
     c0a:	0141                	addi	sp,sp,16
     c0c:	8082                	ret
  return 0;
     c0e:	4501                	li	a0,0
     c10:	bfe5                	j	c08 <memcmp+0x30>

0000000000000c12 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     c12:	1141                	addi	sp,sp,-16
     c14:	e406                	sd	ra,8(sp)
     c16:	e022                	sd	s0,0(sp)
     c18:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     c1a:	00000097          	auipc	ra,0x0
     c1e:	f66080e7          	jalr	-154(ra) # b80 <memmove>
}
     c22:	60a2                	ld	ra,8(sp)
     c24:	6402                	ld	s0,0(sp)
     c26:	0141                	addi	sp,sp,16
     c28:	8082                	ret

0000000000000c2a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     c2a:	4885                	li	a7,1
 ecall
     c2c:	00000073          	ecall
 ret
     c30:	8082                	ret

0000000000000c32 <exit>:
.global exit
exit:
 li a7, SYS_exit
     c32:	4889                	li	a7,2
 ecall
     c34:	00000073          	ecall
 ret
     c38:	8082                	ret

0000000000000c3a <wait>:
.global wait
wait:
 li a7, SYS_wait
     c3a:	488d                	li	a7,3
 ecall
     c3c:	00000073          	ecall
 ret
     c40:	8082                	ret

0000000000000c42 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     c42:	4891                	li	a7,4
 ecall
     c44:	00000073          	ecall
 ret
     c48:	8082                	ret

0000000000000c4a <read>:
.global read
read:
 li a7, SYS_read
     c4a:	4895                	li	a7,5
 ecall
     c4c:	00000073          	ecall
 ret
     c50:	8082                	ret

0000000000000c52 <write>:
.global write
write:
 li a7, SYS_write
     c52:	48c1                	li	a7,16
 ecall
     c54:	00000073          	ecall
 ret
     c58:	8082                	ret

0000000000000c5a <close>:
.global close
close:
 li a7, SYS_close
     c5a:	48d5                	li	a7,21
 ecall
     c5c:	00000073          	ecall
 ret
     c60:	8082                	ret

0000000000000c62 <kill>:
.global kill
kill:
 li a7, SYS_kill
     c62:	4899                	li	a7,6
 ecall
     c64:	00000073          	ecall
 ret
     c68:	8082                	ret

0000000000000c6a <exec>:
.global exec
exec:
 li a7, SYS_exec
     c6a:	489d                	li	a7,7
 ecall
     c6c:	00000073          	ecall
 ret
     c70:	8082                	ret

0000000000000c72 <open>:
.global open
open:
 li a7, SYS_open
     c72:	48bd                	li	a7,15
 ecall
     c74:	00000073          	ecall
 ret
     c78:	8082                	ret

0000000000000c7a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     c7a:	48c5                	li	a7,17
 ecall
     c7c:	00000073          	ecall
 ret
     c80:	8082                	ret

0000000000000c82 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     c82:	48c9                	li	a7,18
 ecall
     c84:	00000073          	ecall
 ret
     c88:	8082                	ret

0000000000000c8a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     c8a:	48a1                	li	a7,8
 ecall
     c8c:	00000073          	ecall
 ret
     c90:	8082                	ret

0000000000000c92 <link>:
.global link
link:
 li a7, SYS_link
     c92:	48cd                	li	a7,19
 ecall
     c94:	00000073          	ecall
 ret
     c98:	8082                	ret

0000000000000c9a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     c9a:	48d1                	li	a7,20
 ecall
     c9c:	00000073          	ecall
 ret
     ca0:	8082                	ret

0000000000000ca2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     ca2:	48a5                	li	a7,9
 ecall
     ca4:	00000073          	ecall
 ret
     ca8:	8082                	ret

0000000000000caa <dup>:
.global dup
dup:
 li a7, SYS_dup
     caa:	48a9                	li	a7,10
 ecall
     cac:	00000073          	ecall
 ret
     cb0:	8082                	ret

0000000000000cb2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     cb2:	48ad                	li	a7,11
 ecall
     cb4:	00000073          	ecall
 ret
     cb8:	8082                	ret

0000000000000cba <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     cba:	48b1                	li	a7,12
 ecall
     cbc:	00000073          	ecall
 ret
     cc0:	8082                	ret

0000000000000cc2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     cc2:	48b5                	li	a7,13
 ecall
     cc4:	00000073          	ecall
 ret
     cc8:	8082                	ret

0000000000000cca <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     cca:	48b9                	li	a7,14
 ecall
     ccc:	00000073          	ecall
 ret
     cd0:	8082                	ret

0000000000000cd2 <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
     cd2:	48d9                	li	a7,22
 ecall
     cd4:	00000073          	ecall
 ret
     cd8:	8082                	ret

0000000000000cda <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
     cda:	48dd                	li	a7,23
 ecall
     cdc:	00000073          	ecall
 ret
     ce0:	8082                	ret

0000000000000ce2 <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
     ce2:	48e1                	li	a7,24
 ecall
     ce4:	00000073          	ecall
 ret
     ce8:	8082                	ret

0000000000000cea <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
     cea:	48e5                	li	a7,25
 ecall
     cec:	00000073          	ecall
 ret
     cf0:	8082                	ret

0000000000000cf2 <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
     cf2:	48e9                	li	a7,26
 ecall
     cf4:	00000073          	ecall
 ret
     cf8:	8082                	ret

0000000000000cfa <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
     cfa:	48ed                	li	a7,27
 ecall
     cfc:	00000073          	ecall
 ret
     d00:	8082                	ret

0000000000000d02 <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
     d02:	48f1                	li	a7,28
 ecall
     d04:	00000073          	ecall
 ret
     d08:	8082                	ret

0000000000000d0a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     d0a:	1101                	addi	sp,sp,-32
     d0c:	ec06                	sd	ra,24(sp)
     d0e:	e822                	sd	s0,16(sp)
     d10:	1000                	addi	s0,sp,32
     d12:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     d16:	4605                	li	a2,1
     d18:	fef40593          	addi	a1,s0,-17
     d1c:	00000097          	auipc	ra,0x0
     d20:	f36080e7          	jalr	-202(ra) # c52 <write>
}
     d24:	60e2                	ld	ra,24(sp)
     d26:	6442                	ld	s0,16(sp)
     d28:	6105                	addi	sp,sp,32
     d2a:	8082                	ret

0000000000000d2c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     d2c:	7139                	addi	sp,sp,-64
     d2e:	fc06                	sd	ra,56(sp)
     d30:	f822                	sd	s0,48(sp)
     d32:	f426                	sd	s1,40(sp)
     d34:	f04a                	sd	s2,32(sp)
     d36:	ec4e                	sd	s3,24(sp)
     d38:	0080                	addi	s0,sp,64
     d3a:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     d3c:	c299                	beqz	a3,d42 <printint+0x16>
     d3e:	0805c863          	bltz	a1,dce <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     d42:	2581                	sext.w	a1,a1
  neg = 0;
     d44:	4881                	li	a7,0
     d46:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     d4a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     d4c:	2601                	sext.w	a2,a2
     d4e:	00001517          	auipc	a0,0x1
     d52:	9c250513          	addi	a0,a0,-1598 # 1710 <digits>
     d56:	883a                	mv	a6,a4
     d58:	2705                	addiw	a4,a4,1
     d5a:	02c5f7bb          	remuw	a5,a1,a2
     d5e:	1782                	slli	a5,a5,0x20
     d60:	9381                	srli	a5,a5,0x20
     d62:	97aa                	add	a5,a5,a0
     d64:	0007c783          	lbu	a5,0(a5)
     d68:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     d6c:	0005879b          	sext.w	a5,a1
     d70:	02c5d5bb          	divuw	a1,a1,a2
     d74:	0685                	addi	a3,a3,1
     d76:	fec7f0e3          	bgeu	a5,a2,d56 <printint+0x2a>
  if(neg)
     d7a:	00088b63          	beqz	a7,d90 <printint+0x64>
    buf[i++] = '-';
     d7e:	fd040793          	addi	a5,s0,-48
     d82:	973e                	add	a4,a4,a5
     d84:	02d00793          	li	a5,45
     d88:	fef70823          	sb	a5,-16(a4)
     d8c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     d90:	02e05863          	blez	a4,dc0 <printint+0x94>
     d94:	fc040793          	addi	a5,s0,-64
     d98:	00e78933          	add	s2,a5,a4
     d9c:	fff78993          	addi	s3,a5,-1
     da0:	99ba                	add	s3,s3,a4
     da2:	377d                	addiw	a4,a4,-1
     da4:	1702                	slli	a4,a4,0x20
     da6:	9301                	srli	a4,a4,0x20
     da8:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     dac:	fff94583          	lbu	a1,-1(s2)
     db0:	8526                	mv	a0,s1
     db2:	00000097          	auipc	ra,0x0
     db6:	f58080e7          	jalr	-168(ra) # d0a <putc>
  while(--i >= 0)
     dba:	197d                	addi	s2,s2,-1
     dbc:	ff3918e3          	bne	s2,s3,dac <printint+0x80>
}
     dc0:	70e2                	ld	ra,56(sp)
     dc2:	7442                	ld	s0,48(sp)
     dc4:	74a2                	ld	s1,40(sp)
     dc6:	7902                	ld	s2,32(sp)
     dc8:	69e2                	ld	s3,24(sp)
     dca:	6121                	addi	sp,sp,64
     dcc:	8082                	ret
    x = -xx;
     dce:	40b005bb          	negw	a1,a1
    neg = 1;
     dd2:	4885                	li	a7,1
    x = -xx;
     dd4:	bf8d                	j	d46 <printint+0x1a>

0000000000000dd6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     dd6:	7119                	addi	sp,sp,-128
     dd8:	fc86                	sd	ra,120(sp)
     dda:	f8a2                	sd	s0,112(sp)
     ddc:	f4a6                	sd	s1,104(sp)
     dde:	f0ca                	sd	s2,96(sp)
     de0:	ecce                	sd	s3,88(sp)
     de2:	e8d2                	sd	s4,80(sp)
     de4:	e4d6                	sd	s5,72(sp)
     de6:	e0da                	sd	s6,64(sp)
     de8:	fc5e                	sd	s7,56(sp)
     dea:	f862                	sd	s8,48(sp)
     dec:	f466                	sd	s9,40(sp)
     dee:	f06a                	sd	s10,32(sp)
     df0:	ec6e                	sd	s11,24(sp)
     df2:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     df4:	0005c903          	lbu	s2,0(a1)
     df8:	18090f63          	beqz	s2,f96 <vprintf+0x1c0>
     dfc:	8aaa                	mv	s5,a0
     dfe:	8b32                	mv	s6,a2
     e00:	00158493          	addi	s1,a1,1
  state = 0;
     e04:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     e06:	02500a13          	li	s4,37
      if(c == 'd'){
     e0a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
     e0e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
     e12:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
     e16:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     e1a:	00001b97          	auipc	s7,0x1
     e1e:	8f6b8b93          	addi	s7,s7,-1802 # 1710 <digits>
     e22:	a839                	j	e40 <vprintf+0x6a>
        putc(fd, c);
     e24:	85ca                	mv	a1,s2
     e26:	8556                	mv	a0,s5
     e28:	00000097          	auipc	ra,0x0
     e2c:	ee2080e7          	jalr	-286(ra) # d0a <putc>
     e30:	a019                	j	e36 <vprintf+0x60>
    } else if(state == '%'){
     e32:	01498f63          	beq	s3,s4,e50 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
     e36:	0485                	addi	s1,s1,1
     e38:	fff4c903          	lbu	s2,-1(s1)
     e3c:	14090d63          	beqz	s2,f96 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
     e40:	0009079b          	sext.w	a5,s2
    if(state == 0){
     e44:	fe0997e3          	bnez	s3,e32 <vprintf+0x5c>
      if(c == '%'){
     e48:	fd479ee3          	bne	a5,s4,e24 <vprintf+0x4e>
        state = '%';
     e4c:	89be                	mv	s3,a5
     e4e:	b7e5                	j	e36 <vprintf+0x60>
      if(c == 'd'){
     e50:	05878063          	beq	a5,s8,e90 <vprintf+0xba>
      } else if(c == 'l') {
     e54:	05978c63          	beq	a5,s9,eac <vprintf+0xd6>
      } else if(c == 'x') {
     e58:	07a78863          	beq	a5,s10,ec8 <vprintf+0xf2>
      } else if(c == 'p') {
     e5c:	09b78463          	beq	a5,s11,ee4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
     e60:	07300713          	li	a4,115
     e64:	0ce78663          	beq	a5,a4,f30 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
     e68:	06300713          	li	a4,99
     e6c:	0ee78e63          	beq	a5,a4,f68 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
     e70:	11478863          	beq	a5,s4,f80 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
     e74:	85d2                	mv	a1,s4
     e76:	8556                	mv	a0,s5
     e78:	00000097          	auipc	ra,0x0
     e7c:	e92080e7          	jalr	-366(ra) # d0a <putc>
        putc(fd, c);
     e80:	85ca                	mv	a1,s2
     e82:	8556                	mv	a0,s5
     e84:	00000097          	auipc	ra,0x0
     e88:	e86080e7          	jalr	-378(ra) # d0a <putc>
      }
      state = 0;
     e8c:	4981                	li	s3,0
     e8e:	b765                	j	e36 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
     e90:	008b0913          	addi	s2,s6,8
     e94:	4685                	li	a3,1
     e96:	4629                	li	a2,10
     e98:	000b2583          	lw	a1,0(s6)
     e9c:	8556                	mv	a0,s5
     e9e:	00000097          	auipc	ra,0x0
     ea2:	e8e080e7          	jalr	-370(ra) # d2c <printint>
     ea6:	8b4a                	mv	s6,s2
      state = 0;
     ea8:	4981                	li	s3,0
     eaa:	b771                	j	e36 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
     eac:	008b0913          	addi	s2,s6,8
     eb0:	4681                	li	a3,0
     eb2:	4629                	li	a2,10
     eb4:	000b2583          	lw	a1,0(s6)
     eb8:	8556                	mv	a0,s5
     eba:	00000097          	auipc	ra,0x0
     ebe:	e72080e7          	jalr	-398(ra) # d2c <printint>
     ec2:	8b4a                	mv	s6,s2
      state = 0;
     ec4:	4981                	li	s3,0
     ec6:	bf85                	j	e36 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
     ec8:	008b0913          	addi	s2,s6,8
     ecc:	4681                	li	a3,0
     ece:	4641                	li	a2,16
     ed0:	000b2583          	lw	a1,0(s6)
     ed4:	8556                	mv	a0,s5
     ed6:	00000097          	auipc	ra,0x0
     eda:	e56080e7          	jalr	-426(ra) # d2c <printint>
     ede:	8b4a                	mv	s6,s2
      state = 0;
     ee0:	4981                	li	s3,0
     ee2:	bf91                	j	e36 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
     ee4:	008b0793          	addi	a5,s6,8
     ee8:	f8f43423          	sd	a5,-120(s0)
     eec:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
     ef0:	03000593          	li	a1,48
     ef4:	8556                	mv	a0,s5
     ef6:	00000097          	auipc	ra,0x0
     efa:	e14080e7          	jalr	-492(ra) # d0a <putc>
  putc(fd, 'x');
     efe:	85ea                	mv	a1,s10
     f00:	8556                	mv	a0,s5
     f02:	00000097          	auipc	ra,0x0
     f06:	e08080e7          	jalr	-504(ra) # d0a <putc>
     f0a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     f0c:	03c9d793          	srli	a5,s3,0x3c
     f10:	97de                	add	a5,a5,s7
     f12:	0007c583          	lbu	a1,0(a5)
     f16:	8556                	mv	a0,s5
     f18:	00000097          	auipc	ra,0x0
     f1c:	df2080e7          	jalr	-526(ra) # d0a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     f20:	0992                	slli	s3,s3,0x4
     f22:	397d                	addiw	s2,s2,-1
     f24:	fe0914e3          	bnez	s2,f0c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
     f28:	f8843b03          	ld	s6,-120(s0)
      state = 0;
     f2c:	4981                	li	s3,0
     f2e:	b721                	j	e36 <vprintf+0x60>
        s = va_arg(ap, char*);
     f30:	008b0993          	addi	s3,s6,8
     f34:	000b3903          	ld	s2,0(s6)
        if(s == 0)
     f38:	02090163          	beqz	s2,f5a <vprintf+0x184>
        while(*s != 0){
     f3c:	00094583          	lbu	a1,0(s2)
     f40:	c9a1                	beqz	a1,f90 <vprintf+0x1ba>
          putc(fd, *s);
     f42:	8556                	mv	a0,s5
     f44:	00000097          	auipc	ra,0x0
     f48:	dc6080e7          	jalr	-570(ra) # d0a <putc>
          s++;
     f4c:	0905                	addi	s2,s2,1
        while(*s != 0){
     f4e:	00094583          	lbu	a1,0(s2)
     f52:	f9e5                	bnez	a1,f42 <vprintf+0x16c>
        s = va_arg(ap, char*);
     f54:	8b4e                	mv	s6,s3
      state = 0;
     f56:	4981                	li	s3,0
     f58:	bdf9                	j	e36 <vprintf+0x60>
          s = "(null)";
     f5a:	00000917          	auipc	s2,0x0
     f5e:	7ae90913          	addi	s2,s2,1966 # 1708 <malloc+0x668>
        while(*s != 0){
     f62:	02800593          	li	a1,40
     f66:	bff1                	j	f42 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
     f68:	008b0913          	addi	s2,s6,8
     f6c:	000b4583          	lbu	a1,0(s6)
     f70:	8556                	mv	a0,s5
     f72:	00000097          	auipc	ra,0x0
     f76:	d98080e7          	jalr	-616(ra) # d0a <putc>
     f7a:	8b4a                	mv	s6,s2
      state = 0;
     f7c:	4981                	li	s3,0
     f7e:	bd65                	j	e36 <vprintf+0x60>
        putc(fd, c);
     f80:	85d2                	mv	a1,s4
     f82:	8556                	mv	a0,s5
     f84:	00000097          	auipc	ra,0x0
     f88:	d86080e7          	jalr	-634(ra) # d0a <putc>
      state = 0;
     f8c:	4981                	li	s3,0
     f8e:	b565                	j	e36 <vprintf+0x60>
        s = va_arg(ap, char*);
     f90:	8b4e                	mv	s6,s3
      state = 0;
     f92:	4981                	li	s3,0
     f94:	b54d                	j	e36 <vprintf+0x60>
    }
  }
}
     f96:	70e6                	ld	ra,120(sp)
     f98:	7446                	ld	s0,112(sp)
     f9a:	74a6                	ld	s1,104(sp)
     f9c:	7906                	ld	s2,96(sp)
     f9e:	69e6                	ld	s3,88(sp)
     fa0:	6a46                	ld	s4,80(sp)
     fa2:	6aa6                	ld	s5,72(sp)
     fa4:	6b06                	ld	s6,64(sp)
     fa6:	7be2                	ld	s7,56(sp)
     fa8:	7c42                	ld	s8,48(sp)
     faa:	7ca2                	ld	s9,40(sp)
     fac:	7d02                	ld	s10,32(sp)
     fae:	6de2                	ld	s11,24(sp)
     fb0:	6109                	addi	sp,sp,128
     fb2:	8082                	ret

0000000000000fb4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     fb4:	715d                	addi	sp,sp,-80
     fb6:	ec06                	sd	ra,24(sp)
     fb8:	e822                	sd	s0,16(sp)
     fba:	1000                	addi	s0,sp,32
     fbc:	e010                	sd	a2,0(s0)
     fbe:	e414                	sd	a3,8(s0)
     fc0:	e818                	sd	a4,16(s0)
     fc2:	ec1c                	sd	a5,24(s0)
     fc4:	03043023          	sd	a6,32(s0)
     fc8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     fcc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     fd0:	8622                	mv	a2,s0
     fd2:	00000097          	auipc	ra,0x0
     fd6:	e04080e7          	jalr	-508(ra) # dd6 <vprintf>
}
     fda:	60e2                	ld	ra,24(sp)
     fdc:	6442                	ld	s0,16(sp)
     fde:	6161                	addi	sp,sp,80
     fe0:	8082                	ret

0000000000000fe2 <printf>:

void
printf(const char *fmt, ...)
{
     fe2:	711d                	addi	sp,sp,-96
     fe4:	ec06                	sd	ra,24(sp)
     fe6:	e822                	sd	s0,16(sp)
     fe8:	1000                	addi	s0,sp,32
     fea:	e40c                	sd	a1,8(s0)
     fec:	e810                	sd	a2,16(s0)
     fee:	ec14                	sd	a3,24(s0)
     ff0:	f018                	sd	a4,32(s0)
     ff2:	f41c                	sd	a5,40(s0)
     ff4:	03043823          	sd	a6,48(s0)
     ff8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     ffc:	00840613          	addi	a2,s0,8
    1000:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1004:	85aa                	mv	a1,a0
    1006:	4505                	li	a0,1
    1008:	00000097          	auipc	ra,0x0
    100c:	dce080e7          	jalr	-562(ra) # dd6 <vprintf>
}
    1010:	60e2                	ld	ra,24(sp)
    1012:	6442                	ld	s0,16(sp)
    1014:	6125                	addi	sp,sp,96
    1016:	8082                	ret

0000000000001018 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1018:	1141                	addi	sp,sp,-16
    101a:	e422                	sd	s0,8(sp)
    101c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    101e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1022:	00000797          	auipc	a5,0x0
    1026:	7067b783          	ld	a5,1798(a5) # 1728 <freep>
    102a:	a805                	j	105a <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    102c:	4618                	lw	a4,8(a2)
    102e:	9db9                	addw	a1,a1,a4
    1030:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1034:	6398                	ld	a4,0(a5)
    1036:	6318                	ld	a4,0(a4)
    1038:	fee53823          	sd	a4,-16(a0)
    103c:	a091                	j	1080 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    103e:	ff852703          	lw	a4,-8(a0)
    1042:	9e39                	addw	a2,a2,a4
    1044:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    1046:	ff053703          	ld	a4,-16(a0)
    104a:	e398                	sd	a4,0(a5)
    104c:	a099                	j	1092 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    104e:	6398                	ld	a4,0(a5)
    1050:	00e7e463          	bltu	a5,a4,1058 <free+0x40>
    1054:	00e6ea63          	bltu	a3,a4,1068 <free+0x50>
{
    1058:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    105a:	fed7fae3          	bgeu	a5,a3,104e <free+0x36>
    105e:	6398                	ld	a4,0(a5)
    1060:	00e6e463          	bltu	a3,a4,1068 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1064:	fee7eae3          	bltu	a5,a4,1058 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    1068:	ff852583          	lw	a1,-8(a0)
    106c:	6390                	ld	a2,0(a5)
    106e:	02059813          	slli	a6,a1,0x20
    1072:	01c85713          	srli	a4,a6,0x1c
    1076:	9736                	add	a4,a4,a3
    1078:	fae60ae3          	beq	a2,a4,102c <free+0x14>
    bp->s.ptr = p->s.ptr;
    107c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1080:	4790                	lw	a2,8(a5)
    1082:	02061593          	slli	a1,a2,0x20
    1086:	01c5d713          	srli	a4,a1,0x1c
    108a:	973e                	add	a4,a4,a5
    108c:	fae689e3          	beq	a3,a4,103e <free+0x26>
  } else
    p->s.ptr = bp;
    1090:	e394                	sd	a3,0(a5)
  freep = p;
    1092:	00000717          	auipc	a4,0x0
    1096:	68f73b23          	sd	a5,1686(a4) # 1728 <freep>
}
    109a:	6422                	ld	s0,8(sp)
    109c:	0141                	addi	sp,sp,16
    109e:	8082                	ret

00000000000010a0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    10a0:	7139                	addi	sp,sp,-64
    10a2:	fc06                	sd	ra,56(sp)
    10a4:	f822                	sd	s0,48(sp)
    10a6:	f426                	sd	s1,40(sp)
    10a8:	f04a                	sd	s2,32(sp)
    10aa:	ec4e                	sd	s3,24(sp)
    10ac:	e852                	sd	s4,16(sp)
    10ae:	e456                	sd	s5,8(sp)
    10b0:	e05a                	sd	s6,0(sp)
    10b2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    10b4:	02051493          	slli	s1,a0,0x20
    10b8:	9081                	srli	s1,s1,0x20
    10ba:	04bd                	addi	s1,s1,15
    10bc:	8091                	srli	s1,s1,0x4
    10be:	0014899b          	addiw	s3,s1,1
    10c2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    10c4:	00000517          	auipc	a0,0x0
    10c8:	66453503          	ld	a0,1636(a0) # 1728 <freep>
    10cc:	c515                	beqz	a0,10f8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    10ce:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    10d0:	4798                	lw	a4,8(a5)
    10d2:	02977f63          	bgeu	a4,s1,1110 <malloc+0x70>
    10d6:	8a4e                	mv	s4,s3
    10d8:	0009871b          	sext.w	a4,s3
    10dc:	6685                	lui	a3,0x1
    10de:	00d77363          	bgeu	a4,a3,10e4 <malloc+0x44>
    10e2:	6a05                	lui	s4,0x1
    10e4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    10e8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    10ec:	00000917          	auipc	s2,0x0
    10f0:	63c90913          	addi	s2,s2,1596 # 1728 <freep>
  if(p == (char*)-1)
    10f4:	5afd                	li	s5,-1
    10f6:	a895                	j	116a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    10f8:	00000797          	auipc	a5,0x0
    10fc:	63878793          	addi	a5,a5,1592 # 1730 <base>
    1100:	00000717          	auipc	a4,0x0
    1104:	62f73423          	sd	a5,1576(a4) # 1728 <freep>
    1108:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    110a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    110e:	b7e1                	j	10d6 <malloc+0x36>
      if(p->s.size == nunits)
    1110:	02e48c63          	beq	s1,a4,1148 <malloc+0xa8>
        p->s.size -= nunits;
    1114:	4137073b          	subw	a4,a4,s3
    1118:	c798                	sw	a4,8(a5)
        p += p->s.size;
    111a:	02071693          	slli	a3,a4,0x20
    111e:	01c6d713          	srli	a4,a3,0x1c
    1122:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1124:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1128:	00000717          	auipc	a4,0x0
    112c:	60a73023          	sd	a0,1536(a4) # 1728 <freep>
      return (void*)(p + 1);
    1130:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1134:	70e2                	ld	ra,56(sp)
    1136:	7442                	ld	s0,48(sp)
    1138:	74a2                	ld	s1,40(sp)
    113a:	7902                	ld	s2,32(sp)
    113c:	69e2                	ld	s3,24(sp)
    113e:	6a42                	ld	s4,16(sp)
    1140:	6aa2                	ld	s5,8(sp)
    1142:	6b02                	ld	s6,0(sp)
    1144:	6121                	addi	sp,sp,64
    1146:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1148:	6398                	ld	a4,0(a5)
    114a:	e118                	sd	a4,0(a0)
    114c:	bff1                	j	1128 <malloc+0x88>
  hp->s.size = nu;
    114e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1152:	0541                	addi	a0,a0,16
    1154:	00000097          	auipc	ra,0x0
    1158:	ec4080e7          	jalr	-316(ra) # 1018 <free>
  return freep;
    115c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1160:	d971                	beqz	a0,1134 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1162:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1164:	4798                	lw	a4,8(a5)
    1166:	fa9775e3          	bgeu	a4,s1,1110 <malloc+0x70>
    if(p == freep)
    116a:	00093703          	ld	a4,0(s2)
    116e:	853e                	mv	a0,a5
    1170:	fef719e3          	bne	a4,a5,1162 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    1174:	8552                	mv	a0,s4
    1176:	00000097          	auipc	ra,0x0
    117a:	b44080e7          	jalr	-1212(ra) # cba <sbrk>
  if(p == (char*)-1)
    117e:	fd5518e3          	bne	a0,s5,114e <malloc+0xae>
        return 0;
    1182:	4501                	li	a0,0
    1184:	bf45                	j	1134 <malloc+0x94>
