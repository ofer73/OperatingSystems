
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
       e:	d50080e7          	jalr	-688(ra) # d5a <sleep>
    printf("Thread is now running tid=%d\n",kthread_id());
      12:	00001097          	auipc	ra,0x1
      16:	d78080e7          	jalr	-648(ra) # d8a <kthread_id>
      1a:	85aa                	mv	a1,a0
      1c:	00001517          	auipc	a0,0x1
      20:	20450513          	addi	a0,a0,516 # 1220 <malloc+0xe8>
      24:	00001097          	auipc	ra,0x1
      28:	056080e7          	jalr	86(ra) # 107a <printf>
    kthread_exit(9);
      2c:	4525                	li	a0,9
      2e:	00001097          	auipc	ra,0x1
      32:	d64080e7          	jalr	-668(ra) # d92 <kthread_exit>
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
      52:	d0c080e7          	jalr	-756(ra) # d5a <sleep>
    for(int i=0;i<100;i++){
      56:	4481                	li	s1,0
        printf("%d:Thread is now running tid=%d\n",i,kthread_id());
      58:	00001997          	auipc	s3,0x1
      5c:	1e898993          	addi	s3,s3,488 # 1240 <malloc+0x108>
    for(int i=0;i<100;i++){
      60:	06400913          	li	s2,100
        printf("%d:Thread is now running tid=%d\n",i,kthread_id());
      64:	00001097          	auipc	ra,0x1
      68:	d26080e7          	jalr	-730(ra) # d8a <kthread_id>
      6c:	862a                	mv	a2,a0
      6e:	85a6                	mv	a1,s1
      70:	854e                	mv	a0,s3
      72:	00001097          	auipc	ra,0x1
      76:	008080e7          	jalr	8(ra) # 107a <printf>
    for(int i=0;i<100;i++){
      7a:	2485                	addiw	s1,s1,1
      7c:	ff2494e3          	bne	s1,s2,64 <test_thread_loop+0x26>
    }
    kthread_exit(9);
      80:	4525                	li	a0,9
      82:	00001097          	auipc	ra,0x1
      86:	d10080e7          	jalr	-752(ra) # d92 <kthread_exit>
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
      a6:	cb8080e7          	jalr	-840(ra) # d5a <sleep>
    printf("Thread is now running tid=%d\n",kthread_id());
      aa:	00001097          	auipc	ra,0x1
      ae:	ce0080e7          	jalr	-800(ra) # d8a <kthread_id>
      b2:	85aa                	mv	a1,a0
      b4:	00001517          	auipc	a0,0x1
      b8:	16c50513          	addi	a0,a0,364 # 1220 <malloc+0xe8>
      bc:	00001097          	auipc	ra,0x1
      c0:	fbe080e7          	jalr	-66(ra) # 107a <printf>
    kthread_exit(9);
      c4:	4525                	li	a0,9
      c6:	00001097          	auipc	ra,0x1
      ca:	ccc080e7          	jalr	-820(ra) # d92 <kthread_exit>
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
      e4:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa704173>
      e8:	fcf42c23          	sw	a5,-40(s0)
      ec:	fc040e23          	sb	zero,-36(s0)
      f0:	1f400493          	li	s1,500
    for(int i=0;i<500;i++){
        write(1, st, 5);
      f4:	4615                	li	a2,5
      f6:	fd840593          	addi	a1,s0,-40
      fa:	4505                	li	a0,1
      fc:	00001097          	auipc	ra,0x1
     100:	bee080e7          	jalr	-1042(ra) # cea <write>
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
     120:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa704173>
     124:	fcf42c23          	sw	a5,-40(s0)
     128:	fc040e23          	sb	zero,-36(s0)
     12c:	1f400493          	li	s1,500
    for(int i=0;i<500;i++){
        write(1, st, 5);
     130:	4615                	li	a2,5
     132:	fd840593          	addi	a1,s0,-40
     136:	4505                	li	a0,1
     138:	00001097          	auipc	ra,0x1
     13c:	bb2080e7          	jalr	-1102(ra) # cea <write>
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
     15a:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa704173>
     15e:	fef42423          	sw	a5,-24(s0)
     162:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
     166:	4615                	li	a2,5
     168:	fe840593          	addi	a1,s0,-24
     16c:	4505                	li	a0,1
     16e:	00001097          	auipc	ra,0x1
     172:	b7c080e7          	jalr	-1156(ra) # cea <write>
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
     190:	b36080e7          	jalr	-1226(ra) # cc2 <fork>
     194:	84aa                	mv	s1,a0
    if(pid==0){
     196:	ed05                	bnez	a0,1ce <test_sigkill+0x50>
        sleep(5);
     198:	4515                	li	a0,5
     19a:	00001097          	auipc	ra,0x1
     19e:	bc0080e7          	jalr	-1088(ra) # d5a <sleep>
            printf("about to get killed %d\n",i);
     1a2:	00001997          	auipc	s3,0x1
     1a6:	0c698993          	addi	s3,s3,198 # 1268 <malloc+0x130>
        for(int i=0;i<300;i++)
     1aa:	12c00913          	li	s2,300
            printf("about to get killed %d\n",i);
     1ae:	85a6                	mv	a1,s1
     1b0:	854e                	mv	a0,s3
     1b2:	00001097          	auipc	ra,0x1
     1b6:	ec8080e7          	jalr	-312(ra) # 107a <printf>
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
     1d4:	b8a080e7          	jalr	-1142(ra) # d5a <sleep>
        printf("parent send signal to to kill child\n");
     1d8:	00001517          	auipc	a0,0x1
     1dc:	0a850513          	addi	a0,a0,168 # 1280 <malloc+0x148>
     1e0:	00001097          	auipc	ra,0x1
     1e4:	e9a080e7          	jalr	-358(ra) # 107a <printf>
        printf("kill ret= %d\n",kill(pid, SIGKILL));
     1e8:	45a5                	li	a1,9
     1ea:	8526                	mv	a0,s1
     1ec:	00001097          	auipc	ra,0x1
     1f0:	b0e080e7          	jalr	-1266(ra) # cfa <kill>
     1f4:	85aa                	mv	a1,a0
     1f6:	00001517          	auipc	a0,0x1
     1fa:	0b250513          	addi	a0,a0,178 # 12a8 <malloc+0x170>
     1fe:	00001097          	auipc	ra,0x1
     202:	e7c080e7          	jalr	-388(ra) # 107a <printf>
        printf("parent wait for child\n");
     206:	00001517          	auipc	a0,0x1
     20a:	0b250513          	addi	a0,a0,178 # 12b8 <malloc+0x180>
     20e:	00001097          	auipc	ra,0x1
     212:	e6c080e7          	jalr	-404(ra) # 107a <printf>
        wait(0);
     216:	4501                	li	a0,0
     218:	00001097          	auipc	ra,0x1
     21c:	aba080e7          	jalr	-1350(ra) # cd2 <wait>
        printf("parent: child is dead\n");
     220:	00001517          	auipc	a0,0x1
     224:	0b050513          	addi	a0,a0,176 # 12d0 <malloc+0x198>
     228:	00001097          	auipc	ra,0x1
     22c:	e52080e7          	jalr	-430(ra) # 107a <printf>
        sleep(10);
     230:	4529                	li	a0,10
     232:	00001097          	auipc	ra,0x1
     236:	b28080e7          	jalr	-1240(ra) # d5a <sleep>
        exit(0);
     23a:	4501                	li	a0,0
     23c:	00001097          	auipc	ra,0x1
     240:	a8e080e7          	jalr	-1394(ra) # cca <exit>

0000000000000244 <sig_handler>:
sig_handler(int signum){
     244:	1101                	addi	sp,sp,-32
     246:	ec06                	sd	ra,24(sp)
     248:	e822                	sd	s0,16(sp)
     24a:	1000                	addi	s0,sp,32
    char st[5] = "wap\n";
     24c:	0a7067b7          	lui	a5,0xa706
     250:	17778793          	addi	a5,a5,375 # a706177 <__global_pointer$+0xa704186>
     254:	fef42423          	sw	a5,-24(s0)
     258:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
     25c:	4615                	li	a2,5
     25e:	fe840593          	addi	a1,s0,-24
     262:	4505                	li	a0,1
     264:	00001097          	auipc	ra,0x1
     268:	a86080e7          	jalr	-1402(ra) # cea <write>
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
     284:	a42080e7          	jalr	-1470(ra) # cc2 <fork>
    int signum1=3;
    if(pid==0){
     288:	e569                	bnez	a0,352 <test_usersig+0xde>
        struct sigaction act;
        struct sigaction act2;

        printf("sighandler= %p\n",&sig_handler2);
     28a:	00000597          	auipc	a1,0x0
     28e:	ec458593          	addi	a1,a1,-316 # 14e <sig_handler2>
     292:	00001517          	auipc	a0,0x1
     296:	05650513          	addi	a0,a0,86 # 12e8 <malloc+0x1b0>
     29a:	00001097          	auipc	ra,0x1
     29e:	de0080e7          	jalr	-544(ra) # 107a <printf>
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
     2cc:	aaa080e7          	jalr	-1366(ra) # d72 <sigaction>
     2d0:	84aa                	mv	s1,a0
        printf("old act->sa handler= %p, mask=%d\n",oldact.sa_handler,oldact.sigmask);
     2d2:	fd842603          	lw	a2,-40(s0)
     2d6:	fd043583          	ld	a1,-48(s0)
     2da:	00001517          	auipc	a0,0x1
     2de:	01e50513          	addi	a0,a0,30 # 12f8 <malloc+0x1c0>
     2e2:	00001097          	auipc	ra,0x1
     2e6:	d98080e7          	jalr	-616(ra) # 107a <printf>
        printf("child return from sigaction = %d\n",ret);
     2ea:	85a6                	mv	a1,s1
     2ec:	00001517          	auipc	a0,0x1
     2f0:	03450513          	addi	a0,a0,52 # 1320 <malloc+0x1e8>
     2f4:	00001097          	auipc	ra,0x1
     2f8:	d86080e7          	jalr	-634(ra) # 107a <printf>
        sleep(10);
     2fc:	4529                	li	a0,10
     2fe:	00001097          	auipc	ra,0x1
     302:	a5c080e7          	jalr	-1444(ra) # d5a <sleep>
     306:	44a9                	li	s1,10
        for(int i=0;i<10;i++){
            printf("child doing stuff before exit \n");
     308:	00001917          	auipc	s2,0x1
     30c:	04090913          	addi	s2,s2,64 # 1348 <malloc+0x210>
     310:	854a                	mv	a0,s2
     312:	00001097          	auipc	ra,0x1
     316:	d68080e7          	jalr	-664(ra) # 107a <printf>
        for(int i=0;i<10;i++){
     31a:	34fd                	addiw	s1,s1,-1
     31c:	f8f5                	bnez	s1,310 <test_usersig+0x9c>
        }
        ret=sigaction(signum1,&act,&oldact);
     31e:	fd040613          	addi	a2,s0,-48
     322:	fc040593          	addi	a1,s0,-64
     326:	450d                	li	a0,3
     328:	00001097          	auipc	ra,0x1
     32c:	a4a080e7          	jalr	-1462(ra) # d72 <sigaction>
        printf("oldact should be the same as new act before \n oldact->mask=%d \t oldact->sa_handler=%d \n",oldact.sigmask,oldact.sa_handler);
     330:	fd043603          	ld	a2,-48(s0)
     334:	fd842583          	lw	a1,-40(s0)
     338:	00001517          	auipc	a0,0x1
     33c:	03050513          	addi	a0,a0,48 # 1368 <malloc+0x230>
     340:	00001097          	auipc	ra,0x1
     344:	d3a080e7          	jalr	-710(ra) # 107a <printf>

        exit(0);
     348:	4501                	li	a0,0
     34a:	00001097          	auipc	ra,0x1
     34e:	980080e7          	jalr	-1664(ra) # cca <exit>
     352:	84aa                	mv	s1,a0

    }
    else{
        sleep(5);
     354:	4515                	li	a0,5
     356:	00001097          	auipc	ra,0x1
     35a:	a04080e7          	jalr	-1532(ra) # d5a <sleep>
        printf("parent send sig 3 to child ret=%d\n",kill(pid,signum1));
     35e:	458d                	li	a1,3
     360:	8526                	mv	a0,s1
     362:	00001097          	auipc	ra,0x1
     366:	998080e7          	jalr	-1640(ra) # cfa <kill>
     36a:	85aa                	mv	a1,a0
     36c:	00001517          	auipc	a0,0x1
     370:	05450513          	addi	a0,a0,84 # 13c0 <malloc+0x288>
     374:	00001097          	auipc	ra,0x1
     378:	d06080e7          	jalr	-762(ra) # 107a <printf>
        // printf("parent send sig 4 to child ret=%d\n",kill(pid,4));

        wait(0);
     37c:	4501                	li	a0,0
     37e:	00001097          	auipc	ra,0x1
     382:	954080e7          	jalr	-1708(ra) # cd2 <wait>
        exit(0);
     386:	4501                	li	a0,0
     388:	00001097          	auipc	ra,0x1
     38c:	942080e7          	jalr	-1726(ra) # cca <exit>

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
     3a6:	9c8080e7          	jalr	-1592(ra) # d6a <sigprocmask>
    printf("got %d from calling to sigprocmask\n",ans);
     3aa:	0005059b          	sext.w	a1,a0
     3ae:	00001517          	auipc	a0,0x1
     3b2:	03a50513          	addi	a0,a0,58 # 13e8 <malloc+0x2b0>
     3b6:	00001097          	auipc	ra,0x1
     3ba:	cc4080e7          	jalr	-828(ra) # 107a <printf>
    int pid=fork();
     3be:	00001097          	auipc	ra,0x1
     3c2:	904080e7          	jalr	-1788(ra) # cc2 <fork>
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
     3d0:	98e080e7          	jalr	-1650(ra) # d5a <sleep>
        printf("parent: sent signal 22 to child ->child shuld block\n");
     3d4:	00001517          	auipc	a0,0x1
     3d8:	05c50513          	addi	a0,a0,92 # 1430 <malloc+0x2f8>
     3dc:	00001097          	auipc	ra,0x1
     3e0:	c9e080e7          	jalr	-866(ra) # 107a <printf>
     3e4:	44a9                	li	s1,10
        for(int i=0; i<10;i++){
            kill(pid,signum1);
     3e6:	45d9                	li	a1,22
     3e8:	854a                	mv	a0,s2
     3ea:	00001097          	auipc	ra,0x1
     3ee:	910080e7          	jalr	-1776(ra) # cfa <kill>
        for(int i=0; i<10;i++){
     3f2:	34fd                	addiw	s1,s1,-1
     3f4:	f8ed                	bnez	s1,3e6 <test_block+0x56>
        }
        sleep(10);
     3f6:	4529                	li	a0,10
     3f8:	00001097          	auipc	ra,0x1
     3fc:	962080e7          	jalr	-1694(ra) # d5a <sleep>
        kill(pid,signum2);
     400:	45dd                	li	a1,23
     402:	854a                	mv	a0,s2
     404:	00001097          	auipc	ra,0x1
     408:	8f6080e7          	jalr	-1802(ra) # cfa <kill>

        printf("parent: sent signal 23 to child ->child shuld die\n");
     40c:	00001517          	auipc	a0,0x1
     410:	05c50513          	addi	a0,a0,92 # 1468 <malloc+0x330>
     414:	00001097          	auipc	ra,0x1
     418:	c66080e7          	jalr	-922(ra) # 107a <printf>
        wait(0);
     41c:	4501                	li	a0,0
     41e:	00001097          	auipc	ra,0x1
     422:	8b4080e7          	jalr	-1868(ra) # cd2 <wait>
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
     43a:	924080e7          	jalr	-1756(ra) # d5a <sleep>
            printf("child blocking signal %d \n",i);
     43e:	00001997          	auipc	s3,0x1
     442:	fd298993          	addi	s3,s3,-46 # 1410 <malloc+0x2d8>
        for(int i=0;i<1000;i++){
     446:	3e800493          	li	s1,1000
            sleep(1);
     44a:	4505                	li	a0,1
     44c:	00001097          	auipc	ra,0x1
     450:	90e080e7          	jalr	-1778(ra) # d5a <sleep>
            printf("child blocking signal %d \n",i);
     454:	85ca                	mv	a1,s2
     456:	854e                	mv	a0,s3
     458:	00001097          	auipc	ra,0x1
     45c:	c22080e7          	jalr	-990(ra) # 107a <printf>
        for(int i=0;i<1000;i++){
     460:	2905                	addiw	s2,s2,1
     462:	fe9914e3          	bne	s2,s1,44a <test_block+0xba>
        exit(0);
     466:	4501                	li	a0,0
     468:	00001097          	auipc	ra,0x1
     46c:	862080e7          	jalr	-1950(ra) # cca <exit>

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
     47e:	00001097          	auipc	ra,0x1
     482:	844080e7          	jalr	-1980(ra) # cc2 <fork>
     486:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
     488:	e915                	bnez	a0,4bc <test_stop_cont+0x4c>
        sleep(2);
     48a:	4509                	li	a0,2
     48c:	00001097          	auipc	ra,0x1
     490:	8ce080e7          	jalr	-1842(ra) # d5a <sleep>
        for(i=0;i<500;i++){
            printf("%d\n ", i);
     494:	00001997          	auipc	s3,0x1
     498:	00c98993          	addi	s3,s3,12 # 14a0 <malloc+0x368>
        for(i=0;i<500;i++){
     49c:	1f400913          	li	s2,500
            printf("%d\n ", i);
     4a0:	85a6                	mv	a1,s1
     4a2:	854e                	mv	a0,s3
     4a4:	00001097          	auipc	ra,0x1
     4a8:	bd6080e7          	jalr	-1066(ra) # 107a <printf>
        for(i=0;i<500;i++){
     4ac:	2485                	addiw	s1,s1,1
     4ae:	ff2499e3          	bne	s1,s2,4a0 <test_stop_cont+0x30>
        }
        exit(0);
     4b2:	4501                	li	a0,0
     4b4:	00001097          	auipc	ra,0x1
     4b8:	816080e7          	jalr	-2026(ra) # cca <exit>
    }else{
        printf("son pid=%d, dad pid=%d\n", pid, getpid());
     4bc:	00001097          	auipc	ra,0x1
     4c0:	88e080e7          	jalr	-1906(ra) # d4a <getpid>
     4c4:	862a                	mv	a2,a0
     4c6:	85a6                	mv	a1,s1
     4c8:	00001517          	auipc	a0,0x1
     4cc:	fe050513          	addi	a0,a0,-32 # 14a8 <malloc+0x370>
     4d0:	00001097          	auipc	ra,0x1
     4d4:	baa080e7          	jalr	-1110(ra) # 107a <printf>
        sleep(5);
     4d8:	4515                	li	a0,5
     4da:	00001097          	auipc	ra,0x1
     4de:	880080e7          	jalr	-1920(ra) # d5a <sleep>
        printf("parent send stop ret= %d\n", kill(pid, SIGSTOP));
     4e2:	45c5                	li	a1,17
     4e4:	8526                	mv	a0,s1
     4e6:	00001097          	auipc	ra,0x1
     4ea:	814080e7          	jalr	-2028(ra) # cfa <kill>
     4ee:	85aa                	mv	a1,a0
     4f0:	00001517          	auipc	a0,0x1
     4f4:	fd050513          	addi	a0,a0,-48 # 14c0 <malloc+0x388>
     4f8:	00001097          	auipc	ra,0x1
     4fc:	b82080e7          	jalr	-1150(ra) # 107a <printf>
        sleep(50);
     500:	03200513          	li	a0,50
     504:	00001097          	auipc	ra,0x1
     508:	856080e7          	jalr	-1962(ra) # d5a <sleep>
        printf("parent send continue ret= %d\n", kill(pid, SIGCONT));
     50c:	45cd                	li	a1,19
     50e:	8526                	mv	a0,s1
     510:	00000097          	auipc	ra,0x0
     514:	7ea080e7          	jalr	2026(ra) # cfa <kill>
     518:	85aa                	mv	a1,a0
     51a:	00001517          	auipc	a0,0x1
     51e:	fc650513          	addi	a0,a0,-58 # 14e0 <malloc+0x3a8>
     522:	00001097          	auipc	ra,0x1
     526:	b58080e7          	jalr	-1192(ra) # 107a <printf>
        wait(0);
     52a:	4501                	li	a0,0
     52c:	00000097          	auipc	ra,0x0
     530:	7a6080e7          	jalr	1958(ra) # cd2 <wait>
        // for(int i=0;i<100;i++)
        //  printf("parent..");
        sleep(10);
     534:	4529                	li	a0,10
     536:	00001097          	auipc	ra,0x1
     53a:	824080e7          	jalr	-2012(ra) # d5a <sleep>
        exit(0);
     53e:	4501                	li	a0,0
     540:	00000097          	auipc	ra,0x0
     544:	78a080e7          	jalr	1930(ra) # cca <exit>

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
     55a:	76c080e7          	jalr	1900(ra) # cc2 <fork>
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
     568:	00450513          	addi	a0,a0,4 # 1568 <malloc+0x430>
     56c:	00001097          	auipc	ra,0x1
     570:	b0e080e7          	jalr	-1266(ra) # 107a <printf>
        sleep(5);
     574:	4515                	li	a0,5
     576:	00000097          	auipc	ra,0x0
     57a:	7e4080e7          	jalr	2020(ra) # d5a <sleep>
        kill(pid,signum);
     57e:	45d9                	li	a1,22
     580:	8526                	mv	a0,s1
     582:	00000097          	auipc	ra,0x0
     586:	778080e7          	jalr	1912(ra) # cfa <kill>
        wait(0);
     58a:	4501                	li	a0,0
     58c:	00000097          	auipc	ra,0x0
     590:	746080e7          	jalr	1862(ra) # cd2 <wait>

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
     5a8:	b94080e7          	jalr	-1132(ra) # 1138 <malloc>
     5ac:	89aa                	mv	s3,a0
        oldAct=malloc(sizeof(sigaction));
     5ae:	4505                	li	a0,1
     5b0:	00001097          	auipc	ra,0x1
     5b4:	b88080e7          	jalr	-1144(ra) # 1138 <malloc>
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
     5ce:	7a8080e7          	jalr	1960(ra) # d72 <sigaction>
     5d2:	85aa                	mv	a1,a0
        printf("ans from sigaction %d, old act returned is: mask= %d address= %d\n",ans,oldAct->sigmask,(uint64)oldAct->sa_handler);
     5d4:	00093683          	ld	a3,0(s2)
     5d8:	00892603          	lw	a2,8(s2)
     5dc:	00001517          	auipc	a0,0x1
     5e0:	f2450513          	addi	a0,a0,-220 # 1500 <malloc+0x3c8>
     5e4:	00001097          	auipc	ra,0x1
     5e8:	a96080e7          	jalr	-1386(ra) # 107a <printf>
        sleep(6);
     5ec:	4519                	li	a0,6
     5ee:	00000097          	auipc	ra,0x0
     5f2:	76c080e7          	jalr	1900(ra) # d5a <sleep>
            printf("child ignoring signal %d\n",i);
     5f6:	00001997          	auipc	s3,0x1
     5fa:	f5298993          	addi	s3,s3,-174 # 1548 <malloc+0x410>
        for(int i=0;i<300;i++){
     5fe:	12c00913          	li	s2,300
            printf("child ignoring signal %d\n",i);
     602:	85a6                	mv	a1,s1
     604:	854e                	mv	a0,s3
     606:	00001097          	auipc	ra,0x1
     60a:	a74080e7          	jalr	-1420(ra) # 107a <printf>
        for(int i=0;i<300;i++){
     60e:	2485                	addiw	s1,s1,1
     610:	ff2499e3          	bne	s1,s2,602 <test_ignore+0xba>
        exit(0);
     614:	4501                	li	a0,0
     616:	00000097          	auipc	ra,0x0
     61a:	6b4080e7          	jalr	1716(ra) # cca <exit>

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
     638:	f4450513          	addi	a0,a0,-188 # 1578 <malloc+0x440>
     63c:	00001097          	auipc	ra,0x1
     640:	a3e080e7          	jalr	-1474(ra) # 107a <printf>
    printf("sighandler2= %p\n", &sig_handler_loop2);
     644:	00000597          	auipc	a1,0x0
     648:	ace58593          	addi	a1,a1,-1330 # 112 <sig_handler_loop2>
     64c:	00001517          	auipc	a0,0x1
     650:	f4450513          	addi	a0,a0,-188 # 1590 <malloc+0x458>
     654:	00001097          	auipc	ra,0x1
     658:	a26080e7          	jalr	-1498(ra) # 107a <printf>


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
     67c:	64a080e7          	jalr	1610(ra) # cc2 <fork>
     680:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
     682:	ed15                	bnez	a0,6be <test_user_handler_kill+0xa0>
        int ret=sigaction(3,&act,&oldact);
     684:	fb040613          	addi	a2,s0,-80
     688:	fc040593          	addi	a1,s0,-64
     68c:	450d                	li	a0,3
     68e:	00000097          	auipc	ra,0x0
     692:	6e4080e7          	jalr	1764(ra) # d72 <sigaction>
        for(i=0;i<500;i++)
            printf("out-side handler %d\n ", i);
     696:	00001997          	auipc	s3,0x1
     69a:	f1298993          	addi	s3,s3,-238 # 15a8 <malloc+0x470>
        for(i=0;i<500;i++)
     69e:	1f400913          	li	s2,500
            printf("out-side handler %d\n ", i);
     6a2:	85a6                	mv	a1,s1
     6a4:	854e                	mv	a0,s3
     6a6:	00001097          	auipc	ra,0x1
     6aa:	9d4080e7          	jalr	-1580(ra) # 107a <printf>
        for(i=0;i<500;i++)
     6ae:	2485                	addiw	s1,s1,1
     6b0:	ff2499e3          	bne	s1,s2,6a2 <test_user_handler_kill+0x84>
        exit(0);
     6b4:	4501                	li	a0,0
     6b6:	00000097          	auipc	ra,0x0
     6ba:	614080e7          	jalr	1556(ra) # cca <exit>
    }else{
        printf("son pid=%d, dad pid=%d\n",pid, getpid());
     6be:	00000097          	auipc	ra,0x0
     6c2:	68c080e7          	jalr	1676(ra) # d4a <getpid>
     6c6:	862a                	mv	a2,a0
     6c8:	85a6                	mv	a1,s1
     6ca:	00001517          	auipc	a0,0x1
     6ce:	dde50513          	addi	a0,a0,-546 # 14a8 <malloc+0x370>
     6d2:	00001097          	auipc	ra,0x1
     6d6:	9a8080e7          	jalr	-1624(ra) # 107a <printf>
        sleep(5);
     6da:	4515                	li	a0,5
     6dc:	00000097          	auipc	ra,0x0
     6e0:	67e080e7          	jalr	1662(ra) # d5a <sleep>
        printf("parent send loop ret= %d\n",kill(pid, 3));
     6e4:	458d                	li	a1,3
     6e6:	8526                	mv	a0,s1
     6e8:	00000097          	auipc	ra,0x0
     6ec:	612080e7          	jalr	1554(ra) # cfa <kill>
     6f0:	85aa                	mv	a1,a0
     6f2:	00001517          	auipc	a0,0x1
     6f6:	ece50513          	addi	a0,a0,-306 # 15c0 <malloc+0x488>
     6fa:	00001097          	auipc	ra,0x1
     6fe:	980080e7          	jalr	-1664(ra) # 107a <printf>
        sleep(20);
     702:	4551                	li	a0,20
     704:	00000097          	auipc	ra,0x0
     708:	656080e7          	jalr	1622(ra) # d5a <sleep>
        printf("parent send kill ret= %d\n",kill(pid, SIGKILL));
     70c:	45a5                	li	a1,9
     70e:	8526                	mv	a0,s1
     710:	00000097          	auipc	ra,0x0
     714:	5ea080e7          	jalr	1514(ra) # cfa <kill>
     718:	85aa                	mv	a1,a0
     71a:	00001517          	auipc	a0,0x1
     71e:	ec650513          	addi	a0,a0,-314 # 15e0 <malloc+0x4a8>
     722:	00001097          	auipc	ra,0x1
     726:	958080e7          	jalr	-1704(ra) # 107a <printf>
        wait(0);
     72a:	4501                	li	a0,0
     72c:	00000097          	auipc	ra,0x0
     730:	5a6080e7          	jalr	1446(ra) # cd2 <wait>
        printf("parent exiting\n");
     734:	00001517          	auipc	a0,0x1
     738:	ecc50513          	addi	a0,a0,-308 # 1600 <malloc+0x4c8>
     73c:	00001097          	auipc	ra,0x1
     740:	93e080e7          	jalr	-1730(ra) # 107a <printf>
        exit(0);
     744:	4501                	li	a0,0
     746:	00000097          	auipc	ra,0x0
     74a:	584080e7          	jalr	1412(ra) # cca <exit>

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
     75c:	fa050513          	addi	a0,a0,-96 # fa0 <vprintf+0x132>
     760:	00001097          	auipc	ra,0x1
     764:	9d8080e7          	jalr	-1576(ra) # 1138 <malloc>
     768:	84aa                	mv	s1,a0
    printf("father tid is = %d\n",kthread_id());
     76a:	00000097          	auipc	ra,0x0
     76e:	620080e7          	jalr	1568(ra) # d8a <kthread_id>
     772:	85aa                	mv	a1,a0
     774:	00001517          	auipc	a0,0x1
     778:	e9c50513          	addi	a0,a0,-356 # 1610 <malloc+0x4d8>
     77c:	00001097          	auipc	ra,0x1
     780:	8fe080e7          	jalr	-1794(ra) # 107a <printf>
    tid = kthread_create(test_thread, stack);
     784:	85a6                	mv	a1,s1
     786:	00000517          	auipc	a0,0x0
     78a:	87a50513          	addi	a0,a0,-1926 # 0 <test_thread>
     78e:	00000097          	auipc	ra,0x0
     792:	5f4080e7          	jalr	1524(ra) # d82 <kthread_create>
     796:	892a                	mv	s2,a0
    printf("child tid %d",tid);
     798:	85aa                	mv	a1,a0
     79a:	00001517          	auipc	a0,0x1
     79e:	e8e50513          	addi	a0,a0,-370 # 1628 <malloc+0x4f0>
     7a2:	00001097          	auipc	ra,0x1
     7a6:	8d8080e7          	jalr	-1832(ra) # 107a <printf>
    printf("father tid is = %d\n",kthread_id());
     7aa:	00000097          	auipc	ra,0x0
     7ae:	5e0080e7          	jalr	1504(ra) # d8a <kthread_id>
     7b2:	85aa                	mv	a1,a0
     7b4:	00001517          	auipc	a0,0x1
     7b8:	e5c50513          	addi	a0,a0,-420 # 1610 <malloc+0x4d8>
     7bc:	00001097          	auipc	ra,0x1
     7c0:	8be080e7          	jalr	-1858(ra) # 107a <printf>

    int ans =kthread_join(tid, &status);
     7c4:	fdc40593          	addi	a1,s0,-36
     7c8:	854a                	mv	a0,s2
     7ca:	00000097          	auipc	ra,0x0
     7ce:	5d0080e7          	jalr	1488(ra) # d9a <kthread_join>
     7d2:	892a                	mv	s2,a0
    printf("kthread join ret =%d , my tid =%d\n",ans,kthread_id());
     7d4:	00000097          	auipc	ra,0x0
     7d8:	5b6080e7          	jalr	1462(ra) # d8a <kthread_id>
     7dc:	862a                	mv	a2,a0
     7de:	85ca                	mv	a1,s2
     7e0:	00001517          	auipc	a0,0x1
     7e4:	e5850513          	addi	a0,a0,-424 # 1638 <malloc+0x500>
     7e8:	00001097          	auipc	ra,0x1
     7ec:	892080e7          	jalr	-1902(ra) # 107a <printf>
    tid = kthread_id();
     7f0:	00000097          	auipc	ra,0x0
     7f4:	59a080e7          	jalr	1434(ra) # d8a <kthread_id>
     7f8:	892a                	mv	s2,a0
    free(stack);
     7fa:	8526                	mv	a0,s1
     7fc:	00001097          	auipc	ra,0x1
     800:	8b4080e7          	jalr	-1868(ra) # 10b0 <free>
    printf("Finished testing threads, main thread id: %d, %d\n", tid,status);
     804:	fdc42603          	lw	a2,-36(s0)
     808:	85ca                	mv	a1,s2
     80a:	00001517          	auipc	a0,0x1
     80e:	e5650513          	addi	a0,a0,-426 # 1660 <malloc+0x528>
     812:	00001097          	auipc	ra,0x1
     816:	868080e7          	jalr	-1944(ra) # 107a <printf>
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
     834:	fa050513          	addi	a0,a0,-96 # fa0 <vprintf+0x132>
     838:	00001097          	auipc	ra,0x1
     83c:	900080e7          	jalr	-1792(ra) # 1138 <malloc>
     840:	84aa                	mv	s1,a0
    printf("after malloc\n");
     842:	00001517          	auipc	a0,0x1
     846:	e5650513          	addi	a0,a0,-426 # 1698 <malloc+0x560>
     84a:	00001097          	auipc	ra,0x1
     84e:	830080e7          	jalr	-2000(ra) # 107a <printf>
    printf("add of func for new thread : %p\n",&test_thread);
     852:	fffff597          	auipc	a1,0xfffff
     856:	7ae58593          	addi	a1,a1,1966 # 0 <test_thread>
     85a:	00001517          	auipc	a0,0x1
     85e:	e4e50513          	addi	a0,a0,-434 # 16a8 <malloc+0x570>
     862:	00001097          	auipc	ra,0x1
     866:	818080e7          	jalr	-2024(ra) # 107a <printf>
    printf("add of func for new thread : %p\n",&test_thread2);
     86a:	00000597          	auipc	a1,0x0
     86e:	82e58593          	addi	a1,a1,-2002 # 98 <test_thread2>
     872:	00001517          	auipc	a0,0x1
     876:	e3650513          	addi	a0,a0,-458 # 16a8 <malloc+0x570>
     87a:	00001097          	auipc	ra,0x1
     87e:	800080e7          	jalr	-2048(ra) # 107a <printf>

    tid = kthread_create(&test_thread2, stack);
     882:	85a6                	mv	a1,s1
     884:	00000517          	auipc	a0,0x0
     888:	81450513          	addi	a0,a0,-2028 # 98 <test_thread2>
     88c:	00000097          	auipc	ra,0x0
     890:	4f6080e7          	jalr	1270(ra) # d82 <kthread_create>
     894:	85aa                	mv	a1,a0
    
    printf("after create %d \n",tid);
     896:	00001517          	auipc	a0,0x1
     89a:	e3a50513          	addi	a0,a0,-454 # 16d0 <malloc+0x598>
     89e:	00000097          	auipc	ra,0x0
     8a2:	7dc080e7          	jalr	2012(ra) # 107a <printf>

    sleep(5);
     8a6:	4515                	li	a0,5
     8a8:	00000097          	auipc	ra,0x0
     8ac:	4b2080e7          	jalr	1202(ra) # d5a <sleep>
    printf("after kthread\n");
     8b0:	00001517          	auipc	a0,0x1
     8b4:	e3850513          	addi	a0,a0,-456 # 16e8 <malloc+0x5b0>
     8b8:	00000097          	auipc	ra,0x0
     8bc:	7c2080e7          	jalr	1986(ra) # 107a <printf>
    tid = kthread_id();
     8c0:	00000097          	auipc	ra,0x0
     8c4:	4ca080e7          	jalr	1226(ra) # d8a <kthread_id>
     8c8:	892a                	mv	s2,a0
    free(stack);
     8ca:	8526                	mv	a0,s1
     8cc:	00000097          	auipc	ra,0x0
     8d0:	7e4080e7          	jalr	2020(ra) # 10b0 <free>
    printf("Finished testing threads, main thread id: %d, %d\n", tid,status);
     8d4:	4601                	li	a2,0
     8d6:	85ca                	mv	a1,s2
     8d8:	00001517          	auipc	a0,0x1
     8dc:	d8850513          	addi	a0,a0,-632 # 1660 <malloc+0x528>
     8e0:	00000097          	auipc	ra,0x0
     8e4:	79a080e7          	jalr	1946(ra) # 107a <printf>
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
     902:	fa050513          	addi	a0,a0,-96 # fa0 <vprintf+0x132>
     906:	00001097          	auipc	ra,0x1
     90a:	832080e7          	jalr	-1998(ra) # 1138 <malloc>
     90e:	84aa                	mv	s1,a0
    printf("add of func for new thread : %p\n",&test_thread);
     910:	fffff597          	auipc	a1,0xfffff
     914:	6f058593          	addi	a1,a1,1776 # 0 <test_thread>
     918:	00001517          	auipc	a0,0x1
     91c:	d9050513          	addi	a0,a0,-624 # 16a8 <malloc+0x570>
     920:	00000097          	auipc	ra,0x0
     924:	75a080e7          	jalr	1882(ra) # 107a <printf>

    tid = kthread_create(&test_thread_loop, stack);
     928:	85a6                	mv	a1,s1
     92a:	fffff517          	auipc	a0,0xfffff
     92e:	71450513          	addi	a0,a0,1812 # 3e <test_thread_loop>
     932:	00000097          	auipc	ra,0x0
     936:	450080e7          	jalr	1104(ra) # d82 <kthread_create>
     93a:	892a                	mv	s2,a0
    
    printf("after create ret tid= %d mytid= %d\n",tid,kthread_id());
     93c:	00000097          	auipc	ra,0x0
     940:	44e080e7          	jalr	1102(ra) # d8a <kthread_id>
     944:	862a                	mv	a2,a0
     946:	85ca                	mv	a1,s2
     948:	00001517          	auipc	a0,0x1
     94c:	db050513          	addi	a0,a0,-592 # 16f8 <malloc+0x5c0>
     950:	00000097          	auipc	ra,0x0
     954:	72a080e7          	jalr	1834(ra) # 107a <printf>

    free(stack);
     958:	8526                	mv	a0,s1
     95a:	00000097          	auipc	ra,0x0
     95e:	756080e7          	jalr	1878(ra) # 10b0 <free>
    printf("Finished testing threads, main thread id: %d\n", kthread_id());
     962:	00000097          	auipc	ra,0x0
     966:	428080e7          	jalr	1064(ra) # d8a <kthread_id>
     96a:	85aa                	mv	a1,a0
     96c:	00001517          	auipc	a0,0x1
     970:	db450513          	addi	a0,a0,-588 # 1720 <malloc+0x5e8>
     974:	00000097          	auipc	ra,0x0
     978:	706080e7          	jalr	1798(ra) # 107a <printf>
    kthread_exit(0);
     97c:	4501                	li	a0,0
     97e:	00000097          	auipc	ra,0x0
     982:	414080e7          	jalr	1044(ra) # d92 <kthread_exit>
}
     986:	60e2                	ld	ra,24(sp)
     988:	6442                	ld	s0,16(sp)
     98a:	64a2                	ld	s1,8(sp)
     98c:	6902                	ld	s2,0(sp)
     98e:	6105                	addi	sp,sp,32
     990:	8082                	ret

0000000000000992 <reparent>:


void
reparent(char *s)
{
     992:	7179                	addi	sp,sp,-48
     994:	f406                	sd	ra,40(sp)
     996:	f022                	sd	s0,32(sp)
     998:	ec26                	sd	s1,24(sp)
     99a:	e84a                	sd	s2,16(sp)
     99c:	e44e                	sd	s3,8(sp)
     99e:	1800                	addi	s0,sp,48
     9a0:	89aa                	mv	s3,a0
  int master_pid = getpid();
     9a2:	00000097          	auipc	ra,0x0
     9a6:	3a8080e7          	jalr	936(ra) # d4a <getpid>
     9aa:	0c800913          	li	s2,200
  for(int i = 0; i < 200; i++){
    int pid = fork();
     9ae:	00000097          	auipc	ra,0x0
     9b2:	314080e7          	jalr	788(ra) # cc2 <fork>
     9b6:	84aa                	mv	s1,a0
    if(pid < 0){
     9b8:	02054263          	bltz	a0,9dc <reparent+0x4a>
      printf("%s: fork failed\n", s);
      exit(1);
    }
    if(pid){
     9bc:	cd21                	beqz	a0,a14 <reparent+0x82>
      if(wait(0) != pid){
     9be:	4501                	li	a0,0
     9c0:	00000097          	auipc	ra,0x0
     9c4:	312080e7          	jalr	786(ra) # cd2 <wait>
     9c8:	02951863          	bne	a0,s1,9f8 <reparent+0x66>
  for(int i = 0; i < 200; i++){
     9cc:	397d                	addiw	s2,s2,-1
     9ce:	fe0910e3          	bnez	s2,9ae <reparent+0x1c>
        exit(1);
      }
      exit(0);
    }
  }
  exit(0);
     9d2:	4501                	li	a0,0
     9d4:	00000097          	auipc	ra,0x0
     9d8:	2f6080e7          	jalr	758(ra) # cca <exit>
      printf("%s: fork failed\n", s);
     9dc:	85ce                	mv	a1,s3
     9de:	00001517          	auipc	a0,0x1
     9e2:	d7250513          	addi	a0,a0,-654 # 1750 <malloc+0x618>
     9e6:	00000097          	auipc	ra,0x0
     9ea:	694080e7          	jalr	1684(ra) # 107a <printf>
      exit(1);
     9ee:	4505                	li	a0,1
     9f0:	00000097          	auipc	ra,0x0
     9f4:	2da080e7          	jalr	730(ra) # cca <exit>
        printf("%s: wait wrong pid\n", s);
     9f8:	85ce                	mv	a1,s3
     9fa:	00001517          	auipc	a0,0x1
     9fe:	d6e50513          	addi	a0,a0,-658 # 1768 <malloc+0x630>
     a02:	00000097          	auipc	ra,0x0
     a06:	678080e7          	jalr	1656(ra) # 107a <printf>
        exit(1);
     a0a:	4505                	li	a0,1
     a0c:	00000097          	auipc	ra,0x0
     a10:	2be080e7          	jalr	702(ra) # cca <exit>
      int pid2 = fork();
     a14:	00000097          	auipc	ra,0x0
     a18:	2ae080e7          	jalr	686(ra) # cc2 <fork>
      if(pid2 < 0){
     a1c:	00054763          	bltz	a0,a2a <reparent+0x98>
      exit(0);
     a20:	4501                	li	a0,0
     a22:	00000097          	auipc	ra,0x0
     a26:	2a8080e7          	jalr	680(ra) # cca <exit>
        exit(1);
     a2a:	4505                	li	a0,1
     a2c:	00000097          	auipc	ra,0x0
     a30:	29e080e7          	jalr	670(ra) # cca <exit>

0000000000000a34 <main>:
}

int main(){
     a34:	1141                	addi	sp,sp,-16
     a36:	e406                	sd	ra,8(sp)
     a38:	e022                	sd	s0,0(sp)
     a3a:	0800                	addi	s0,sp,16

    // printf("-----------------------------very easy thread test-----------------------------\n");
    // very_easy_thread_test("ff");


    printf("-----------------------------reparent test-----------------------------\n");
     a3c:	00001517          	auipc	a0,0x1
     a40:	d4450513          	addi	a0,a0,-700 # 1780 <malloc+0x648>
     a44:	00000097          	auipc	ra,0x0
     a48:	636080e7          	jalr	1590(ra) # 107a <printf>
    reparent("ff");
     a4c:	00001517          	auipc	a0,0x1
     a50:	d8450513          	addi	a0,a0,-636 # 17d0 <malloc+0x698>
     a54:	00000097          	auipc	ra,0x0
     a58:	f3e080e7          	jalr	-194(ra) # 992 <reparent>

0000000000000a5c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     a5c:	1141                	addi	sp,sp,-16
     a5e:	e422                	sd	s0,8(sp)
     a60:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     a62:	87aa                	mv	a5,a0
     a64:	0585                	addi	a1,a1,1
     a66:	0785                	addi	a5,a5,1
     a68:	fff5c703          	lbu	a4,-1(a1)
     a6c:	fee78fa3          	sb	a4,-1(a5)
     a70:	fb75                	bnez	a4,a64 <strcpy+0x8>
    ;
  return os;
}
     a72:	6422                	ld	s0,8(sp)
     a74:	0141                	addi	sp,sp,16
     a76:	8082                	ret

0000000000000a78 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     a78:	1141                	addi	sp,sp,-16
     a7a:	e422                	sd	s0,8(sp)
     a7c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     a7e:	00054783          	lbu	a5,0(a0)
     a82:	cb91                	beqz	a5,a96 <strcmp+0x1e>
     a84:	0005c703          	lbu	a4,0(a1)
     a88:	00f71763          	bne	a4,a5,a96 <strcmp+0x1e>
    p++, q++;
     a8c:	0505                	addi	a0,a0,1
     a8e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     a90:	00054783          	lbu	a5,0(a0)
     a94:	fbe5                	bnez	a5,a84 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     a96:	0005c503          	lbu	a0,0(a1)
}
     a9a:	40a7853b          	subw	a0,a5,a0
     a9e:	6422                	ld	s0,8(sp)
     aa0:	0141                	addi	sp,sp,16
     aa2:	8082                	ret

0000000000000aa4 <strlen>:

uint
strlen(const char *s)
{
     aa4:	1141                	addi	sp,sp,-16
     aa6:	e422                	sd	s0,8(sp)
     aa8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     aaa:	00054783          	lbu	a5,0(a0)
     aae:	cf91                	beqz	a5,aca <strlen+0x26>
     ab0:	0505                	addi	a0,a0,1
     ab2:	87aa                	mv	a5,a0
     ab4:	4685                	li	a3,1
     ab6:	9e89                	subw	a3,a3,a0
     ab8:	00f6853b          	addw	a0,a3,a5
     abc:	0785                	addi	a5,a5,1
     abe:	fff7c703          	lbu	a4,-1(a5)
     ac2:	fb7d                	bnez	a4,ab8 <strlen+0x14>
    ;
  return n;
}
     ac4:	6422                	ld	s0,8(sp)
     ac6:	0141                	addi	sp,sp,16
     ac8:	8082                	ret
  for(n = 0; s[n]; n++)
     aca:	4501                	li	a0,0
     acc:	bfe5                	j	ac4 <strlen+0x20>

0000000000000ace <memset>:

void*
memset(void *dst, int c, uint n)
{
     ace:	1141                	addi	sp,sp,-16
     ad0:	e422                	sd	s0,8(sp)
     ad2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     ad4:	ca19                	beqz	a2,aea <memset+0x1c>
     ad6:	87aa                	mv	a5,a0
     ad8:	1602                	slli	a2,a2,0x20
     ada:	9201                	srli	a2,a2,0x20
     adc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     ae0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     ae4:	0785                	addi	a5,a5,1
     ae6:	fee79de3          	bne	a5,a4,ae0 <memset+0x12>
  }
  return dst;
}
     aea:	6422                	ld	s0,8(sp)
     aec:	0141                	addi	sp,sp,16
     aee:	8082                	ret

0000000000000af0 <strchr>:

char*
strchr(const char *s, char c)
{
     af0:	1141                	addi	sp,sp,-16
     af2:	e422                	sd	s0,8(sp)
     af4:	0800                	addi	s0,sp,16
  for(; *s; s++)
     af6:	00054783          	lbu	a5,0(a0)
     afa:	cb99                	beqz	a5,b10 <strchr+0x20>
    if(*s == c)
     afc:	00f58763          	beq	a1,a5,b0a <strchr+0x1a>
  for(; *s; s++)
     b00:	0505                	addi	a0,a0,1
     b02:	00054783          	lbu	a5,0(a0)
     b06:	fbfd                	bnez	a5,afc <strchr+0xc>
      return (char*)s;
  return 0;
     b08:	4501                	li	a0,0
}
     b0a:	6422                	ld	s0,8(sp)
     b0c:	0141                	addi	sp,sp,16
     b0e:	8082                	ret
  return 0;
     b10:	4501                	li	a0,0
     b12:	bfe5                	j	b0a <strchr+0x1a>

0000000000000b14 <gets>:

char*
gets(char *buf, int max)
{
     b14:	711d                	addi	sp,sp,-96
     b16:	ec86                	sd	ra,88(sp)
     b18:	e8a2                	sd	s0,80(sp)
     b1a:	e4a6                	sd	s1,72(sp)
     b1c:	e0ca                	sd	s2,64(sp)
     b1e:	fc4e                	sd	s3,56(sp)
     b20:	f852                	sd	s4,48(sp)
     b22:	f456                	sd	s5,40(sp)
     b24:	f05a                	sd	s6,32(sp)
     b26:	ec5e                	sd	s7,24(sp)
     b28:	1080                	addi	s0,sp,96
     b2a:	8baa                	mv	s7,a0
     b2c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     b2e:	892a                	mv	s2,a0
     b30:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     b32:	4aa9                	li	s5,10
     b34:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     b36:	89a6                	mv	s3,s1
     b38:	2485                	addiw	s1,s1,1
     b3a:	0344d863          	bge	s1,s4,b6a <gets+0x56>
    cc = read(0, &c, 1);
     b3e:	4605                	li	a2,1
     b40:	faf40593          	addi	a1,s0,-81
     b44:	4501                	li	a0,0
     b46:	00000097          	auipc	ra,0x0
     b4a:	19c080e7          	jalr	412(ra) # ce2 <read>
    if(cc < 1)
     b4e:	00a05e63          	blez	a0,b6a <gets+0x56>
    buf[i++] = c;
     b52:	faf44783          	lbu	a5,-81(s0)
     b56:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     b5a:	01578763          	beq	a5,s5,b68 <gets+0x54>
     b5e:	0905                	addi	s2,s2,1
     b60:	fd679be3          	bne	a5,s6,b36 <gets+0x22>
  for(i=0; i+1 < max; ){
     b64:	89a6                	mv	s3,s1
     b66:	a011                	j	b6a <gets+0x56>
     b68:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     b6a:	99de                	add	s3,s3,s7
     b6c:	00098023          	sb	zero,0(s3)
  return buf;
}
     b70:	855e                	mv	a0,s7
     b72:	60e6                	ld	ra,88(sp)
     b74:	6446                	ld	s0,80(sp)
     b76:	64a6                	ld	s1,72(sp)
     b78:	6906                	ld	s2,64(sp)
     b7a:	79e2                	ld	s3,56(sp)
     b7c:	7a42                	ld	s4,48(sp)
     b7e:	7aa2                	ld	s5,40(sp)
     b80:	7b02                	ld	s6,32(sp)
     b82:	6be2                	ld	s7,24(sp)
     b84:	6125                	addi	sp,sp,96
     b86:	8082                	ret

0000000000000b88 <stat>:

int
stat(const char *n, struct stat *st)
{
     b88:	1101                	addi	sp,sp,-32
     b8a:	ec06                	sd	ra,24(sp)
     b8c:	e822                	sd	s0,16(sp)
     b8e:	e426                	sd	s1,8(sp)
     b90:	e04a                	sd	s2,0(sp)
     b92:	1000                	addi	s0,sp,32
     b94:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     b96:	4581                	li	a1,0
     b98:	00000097          	auipc	ra,0x0
     b9c:	172080e7          	jalr	370(ra) # d0a <open>
  if(fd < 0)
     ba0:	02054563          	bltz	a0,bca <stat+0x42>
     ba4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     ba6:	85ca                	mv	a1,s2
     ba8:	00000097          	auipc	ra,0x0
     bac:	17a080e7          	jalr	378(ra) # d22 <fstat>
     bb0:	892a                	mv	s2,a0
  close(fd);
     bb2:	8526                	mv	a0,s1
     bb4:	00000097          	auipc	ra,0x0
     bb8:	13e080e7          	jalr	318(ra) # cf2 <close>
  return r;
}
     bbc:	854a                	mv	a0,s2
     bbe:	60e2                	ld	ra,24(sp)
     bc0:	6442                	ld	s0,16(sp)
     bc2:	64a2                	ld	s1,8(sp)
     bc4:	6902                	ld	s2,0(sp)
     bc6:	6105                	addi	sp,sp,32
     bc8:	8082                	ret
    return -1;
     bca:	597d                	li	s2,-1
     bcc:	bfc5                	j	bbc <stat+0x34>

0000000000000bce <atoi>:

int
atoi(const char *s)
{
     bce:	1141                	addi	sp,sp,-16
     bd0:	e422                	sd	s0,8(sp)
     bd2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     bd4:	00054603          	lbu	a2,0(a0)
     bd8:	fd06079b          	addiw	a5,a2,-48
     bdc:	0ff7f793          	andi	a5,a5,255
     be0:	4725                	li	a4,9
     be2:	02f76963          	bltu	a4,a5,c14 <atoi+0x46>
     be6:	86aa                	mv	a3,a0
  n = 0;
     be8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     bea:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     bec:	0685                	addi	a3,a3,1
     bee:	0025179b          	slliw	a5,a0,0x2
     bf2:	9fa9                	addw	a5,a5,a0
     bf4:	0017979b          	slliw	a5,a5,0x1
     bf8:	9fb1                	addw	a5,a5,a2
     bfa:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     bfe:	0006c603          	lbu	a2,0(a3)
     c02:	fd06071b          	addiw	a4,a2,-48
     c06:	0ff77713          	andi	a4,a4,255
     c0a:	fee5f1e3          	bgeu	a1,a4,bec <atoi+0x1e>
  return n;
}
     c0e:	6422                	ld	s0,8(sp)
     c10:	0141                	addi	sp,sp,16
     c12:	8082                	ret
  n = 0;
     c14:	4501                	li	a0,0
     c16:	bfe5                	j	c0e <atoi+0x40>

0000000000000c18 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     c18:	1141                	addi	sp,sp,-16
     c1a:	e422                	sd	s0,8(sp)
     c1c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     c1e:	02b57463          	bgeu	a0,a1,c46 <memmove+0x2e>
    while(n-- > 0)
     c22:	00c05f63          	blez	a2,c40 <memmove+0x28>
     c26:	1602                	slli	a2,a2,0x20
     c28:	9201                	srli	a2,a2,0x20
     c2a:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     c2e:	872a                	mv	a4,a0
      *dst++ = *src++;
     c30:	0585                	addi	a1,a1,1
     c32:	0705                	addi	a4,a4,1
     c34:	fff5c683          	lbu	a3,-1(a1)
     c38:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     c3c:	fee79ae3          	bne	a5,a4,c30 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     c40:	6422                	ld	s0,8(sp)
     c42:	0141                	addi	sp,sp,16
     c44:	8082                	ret
    dst += n;
     c46:	00c50733          	add	a4,a0,a2
    src += n;
     c4a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     c4c:	fec05ae3          	blez	a2,c40 <memmove+0x28>
     c50:	fff6079b          	addiw	a5,a2,-1
     c54:	1782                	slli	a5,a5,0x20
     c56:	9381                	srli	a5,a5,0x20
     c58:	fff7c793          	not	a5,a5
     c5c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     c5e:	15fd                	addi	a1,a1,-1
     c60:	177d                	addi	a4,a4,-1
     c62:	0005c683          	lbu	a3,0(a1)
     c66:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     c6a:	fee79ae3          	bne	a5,a4,c5e <memmove+0x46>
     c6e:	bfc9                	j	c40 <memmove+0x28>

0000000000000c70 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     c70:	1141                	addi	sp,sp,-16
     c72:	e422                	sd	s0,8(sp)
     c74:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     c76:	ca05                	beqz	a2,ca6 <memcmp+0x36>
     c78:	fff6069b          	addiw	a3,a2,-1
     c7c:	1682                	slli	a3,a3,0x20
     c7e:	9281                	srli	a3,a3,0x20
     c80:	0685                	addi	a3,a3,1
     c82:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     c84:	00054783          	lbu	a5,0(a0)
     c88:	0005c703          	lbu	a4,0(a1)
     c8c:	00e79863          	bne	a5,a4,c9c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     c90:	0505                	addi	a0,a0,1
    p2++;
     c92:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     c94:	fed518e3          	bne	a0,a3,c84 <memcmp+0x14>
  }
  return 0;
     c98:	4501                	li	a0,0
     c9a:	a019                	j	ca0 <memcmp+0x30>
      return *p1 - *p2;
     c9c:	40e7853b          	subw	a0,a5,a4
}
     ca0:	6422                	ld	s0,8(sp)
     ca2:	0141                	addi	sp,sp,16
     ca4:	8082                	ret
  return 0;
     ca6:	4501                	li	a0,0
     ca8:	bfe5                	j	ca0 <memcmp+0x30>

0000000000000caa <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     caa:	1141                	addi	sp,sp,-16
     cac:	e406                	sd	ra,8(sp)
     cae:	e022                	sd	s0,0(sp)
     cb0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     cb2:	00000097          	auipc	ra,0x0
     cb6:	f66080e7          	jalr	-154(ra) # c18 <memmove>
}
     cba:	60a2                	ld	ra,8(sp)
     cbc:	6402                	ld	s0,0(sp)
     cbe:	0141                	addi	sp,sp,16
     cc0:	8082                	ret

0000000000000cc2 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     cc2:	4885                	li	a7,1
 ecall
     cc4:	00000073          	ecall
 ret
     cc8:	8082                	ret

0000000000000cca <exit>:
.global exit
exit:
 li a7, SYS_exit
     cca:	4889                	li	a7,2
 ecall
     ccc:	00000073          	ecall
 ret
     cd0:	8082                	ret

0000000000000cd2 <wait>:
.global wait
wait:
 li a7, SYS_wait
     cd2:	488d                	li	a7,3
 ecall
     cd4:	00000073          	ecall
 ret
     cd8:	8082                	ret

0000000000000cda <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     cda:	4891                	li	a7,4
 ecall
     cdc:	00000073          	ecall
 ret
     ce0:	8082                	ret

0000000000000ce2 <read>:
.global read
read:
 li a7, SYS_read
     ce2:	4895                	li	a7,5
 ecall
     ce4:	00000073          	ecall
 ret
     ce8:	8082                	ret

0000000000000cea <write>:
.global write
write:
 li a7, SYS_write
     cea:	48c1                	li	a7,16
 ecall
     cec:	00000073          	ecall
 ret
     cf0:	8082                	ret

0000000000000cf2 <close>:
.global close
close:
 li a7, SYS_close
     cf2:	48d5                	li	a7,21
 ecall
     cf4:	00000073          	ecall
 ret
     cf8:	8082                	ret

0000000000000cfa <kill>:
.global kill
kill:
 li a7, SYS_kill
     cfa:	4899                	li	a7,6
 ecall
     cfc:	00000073          	ecall
 ret
     d00:	8082                	ret

0000000000000d02 <exec>:
.global exec
exec:
 li a7, SYS_exec
     d02:	489d                	li	a7,7
 ecall
     d04:	00000073          	ecall
 ret
     d08:	8082                	ret

0000000000000d0a <open>:
.global open
open:
 li a7, SYS_open
     d0a:	48bd                	li	a7,15
 ecall
     d0c:	00000073          	ecall
 ret
     d10:	8082                	ret

0000000000000d12 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     d12:	48c5                	li	a7,17
 ecall
     d14:	00000073          	ecall
 ret
     d18:	8082                	ret

0000000000000d1a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     d1a:	48c9                	li	a7,18
 ecall
     d1c:	00000073          	ecall
 ret
     d20:	8082                	ret

0000000000000d22 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     d22:	48a1                	li	a7,8
 ecall
     d24:	00000073          	ecall
 ret
     d28:	8082                	ret

0000000000000d2a <link>:
.global link
link:
 li a7, SYS_link
     d2a:	48cd                	li	a7,19
 ecall
     d2c:	00000073          	ecall
 ret
     d30:	8082                	ret

0000000000000d32 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     d32:	48d1                	li	a7,20
 ecall
     d34:	00000073          	ecall
 ret
     d38:	8082                	ret

0000000000000d3a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     d3a:	48a5                	li	a7,9
 ecall
     d3c:	00000073          	ecall
 ret
     d40:	8082                	ret

0000000000000d42 <dup>:
.global dup
dup:
 li a7, SYS_dup
     d42:	48a9                	li	a7,10
 ecall
     d44:	00000073          	ecall
 ret
     d48:	8082                	ret

0000000000000d4a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     d4a:	48ad                	li	a7,11
 ecall
     d4c:	00000073          	ecall
 ret
     d50:	8082                	ret

0000000000000d52 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     d52:	48b1                	li	a7,12
 ecall
     d54:	00000073          	ecall
 ret
     d58:	8082                	ret

0000000000000d5a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     d5a:	48b5                	li	a7,13
 ecall
     d5c:	00000073          	ecall
 ret
     d60:	8082                	ret

0000000000000d62 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     d62:	48b9                	li	a7,14
 ecall
     d64:	00000073          	ecall
 ret
     d68:	8082                	ret

0000000000000d6a <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
     d6a:	48d9                	li	a7,22
 ecall
     d6c:	00000073          	ecall
 ret
     d70:	8082                	ret

0000000000000d72 <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
     d72:	48dd                	li	a7,23
 ecall
     d74:	00000073          	ecall
 ret
     d78:	8082                	ret

0000000000000d7a <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
     d7a:	48e1                	li	a7,24
 ecall
     d7c:	00000073          	ecall
 ret
     d80:	8082                	ret

0000000000000d82 <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
     d82:	48e5                	li	a7,25
 ecall
     d84:	00000073          	ecall
 ret
     d88:	8082                	ret

0000000000000d8a <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
     d8a:	48e9                	li	a7,26
 ecall
     d8c:	00000073          	ecall
 ret
     d90:	8082                	ret

0000000000000d92 <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
     d92:	48ed                	li	a7,27
 ecall
     d94:	00000073          	ecall
 ret
     d98:	8082                	ret

0000000000000d9a <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
     d9a:	48f1                	li	a7,28
 ecall
     d9c:	00000073          	ecall
 ret
     da0:	8082                	ret

0000000000000da2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     da2:	1101                	addi	sp,sp,-32
     da4:	ec06                	sd	ra,24(sp)
     da6:	e822                	sd	s0,16(sp)
     da8:	1000                	addi	s0,sp,32
     daa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     dae:	4605                	li	a2,1
     db0:	fef40593          	addi	a1,s0,-17
     db4:	00000097          	auipc	ra,0x0
     db8:	f36080e7          	jalr	-202(ra) # cea <write>
}
     dbc:	60e2                	ld	ra,24(sp)
     dbe:	6442                	ld	s0,16(sp)
     dc0:	6105                	addi	sp,sp,32
     dc2:	8082                	ret

0000000000000dc4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     dc4:	7139                	addi	sp,sp,-64
     dc6:	fc06                	sd	ra,56(sp)
     dc8:	f822                	sd	s0,48(sp)
     dca:	f426                	sd	s1,40(sp)
     dcc:	f04a                	sd	s2,32(sp)
     dce:	ec4e                	sd	s3,24(sp)
     dd0:	0080                	addi	s0,sp,64
     dd2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     dd4:	c299                	beqz	a3,dda <printint+0x16>
     dd6:	0805c863          	bltz	a1,e66 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     dda:	2581                	sext.w	a1,a1
  neg = 0;
     ddc:	4881                	li	a7,0
     dde:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     de2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     de4:	2601                	sext.w	a2,a2
     de6:	00001517          	auipc	a0,0x1
     dea:	9fa50513          	addi	a0,a0,-1542 # 17e0 <digits>
     dee:	883a                	mv	a6,a4
     df0:	2705                	addiw	a4,a4,1
     df2:	02c5f7bb          	remuw	a5,a1,a2
     df6:	1782                	slli	a5,a5,0x20
     df8:	9381                	srli	a5,a5,0x20
     dfa:	97aa                	add	a5,a5,a0
     dfc:	0007c783          	lbu	a5,0(a5)
     e00:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     e04:	0005879b          	sext.w	a5,a1
     e08:	02c5d5bb          	divuw	a1,a1,a2
     e0c:	0685                	addi	a3,a3,1
     e0e:	fec7f0e3          	bgeu	a5,a2,dee <printint+0x2a>
  if(neg)
     e12:	00088b63          	beqz	a7,e28 <printint+0x64>
    buf[i++] = '-';
     e16:	fd040793          	addi	a5,s0,-48
     e1a:	973e                	add	a4,a4,a5
     e1c:	02d00793          	li	a5,45
     e20:	fef70823          	sb	a5,-16(a4)
     e24:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     e28:	02e05863          	blez	a4,e58 <printint+0x94>
     e2c:	fc040793          	addi	a5,s0,-64
     e30:	00e78933          	add	s2,a5,a4
     e34:	fff78993          	addi	s3,a5,-1
     e38:	99ba                	add	s3,s3,a4
     e3a:	377d                	addiw	a4,a4,-1
     e3c:	1702                	slli	a4,a4,0x20
     e3e:	9301                	srli	a4,a4,0x20
     e40:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     e44:	fff94583          	lbu	a1,-1(s2)
     e48:	8526                	mv	a0,s1
     e4a:	00000097          	auipc	ra,0x0
     e4e:	f58080e7          	jalr	-168(ra) # da2 <putc>
  while(--i >= 0)
     e52:	197d                	addi	s2,s2,-1
     e54:	ff3918e3          	bne	s2,s3,e44 <printint+0x80>
}
     e58:	70e2                	ld	ra,56(sp)
     e5a:	7442                	ld	s0,48(sp)
     e5c:	74a2                	ld	s1,40(sp)
     e5e:	7902                	ld	s2,32(sp)
     e60:	69e2                	ld	s3,24(sp)
     e62:	6121                	addi	sp,sp,64
     e64:	8082                	ret
    x = -xx;
     e66:	40b005bb          	negw	a1,a1
    neg = 1;
     e6a:	4885                	li	a7,1
    x = -xx;
     e6c:	bf8d                	j	dde <printint+0x1a>

0000000000000e6e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     e6e:	7119                	addi	sp,sp,-128
     e70:	fc86                	sd	ra,120(sp)
     e72:	f8a2                	sd	s0,112(sp)
     e74:	f4a6                	sd	s1,104(sp)
     e76:	f0ca                	sd	s2,96(sp)
     e78:	ecce                	sd	s3,88(sp)
     e7a:	e8d2                	sd	s4,80(sp)
     e7c:	e4d6                	sd	s5,72(sp)
     e7e:	e0da                	sd	s6,64(sp)
     e80:	fc5e                	sd	s7,56(sp)
     e82:	f862                	sd	s8,48(sp)
     e84:	f466                	sd	s9,40(sp)
     e86:	f06a                	sd	s10,32(sp)
     e88:	ec6e                	sd	s11,24(sp)
     e8a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     e8c:	0005c903          	lbu	s2,0(a1)
     e90:	18090f63          	beqz	s2,102e <vprintf+0x1c0>
     e94:	8aaa                	mv	s5,a0
     e96:	8b32                	mv	s6,a2
     e98:	00158493          	addi	s1,a1,1
  state = 0;
     e9c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     e9e:	02500a13          	li	s4,37
      if(c == 'd'){
     ea2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
     ea6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
     eaa:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
     eae:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     eb2:	00001b97          	auipc	s7,0x1
     eb6:	92eb8b93          	addi	s7,s7,-1746 # 17e0 <digits>
     eba:	a839                	j	ed8 <vprintf+0x6a>
        putc(fd, c);
     ebc:	85ca                	mv	a1,s2
     ebe:	8556                	mv	a0,s5
     ec0:	00000097          	auipc	ra,0x0
     ec4:	ee2080e7          	jalr	-286(ra) # da2 <putc>
     ec8:	a019                	j	ece <vprintf+0x60>
    } else if(state == '%'){
     eca:	01498f63          	beq	s3,s4,ee8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
     ece:	0485                	addi	s1,s1,1
     ed0:	fff4c903          	lbu	s2,-1(s1)
     ed4:	14090d63          	beqz	s2,102e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
     ed8:	0009079b          	sext.w	a5,s2
    if(state == 0){
     edc:	fe0997e3          	bnez	s3,eca <vprintf+0x5c>
      if(c == '%'){
     ee0:	fd479ee3          	bne	a5,s4,ebc <vprintf+0x4e>
        state = '%';
     ee4:	89be                	mv	s3,a5
     ee6:	b7e5                	j	ece <vprintf+0x60>
      if(c == 'd'){
     ee8:	05878063          	beq	a5,s8,f28 <vprintf+0xba>
      } else if(c == 'l') {
     eec:	05978c63          	beq	a5,s9,f44 <vprintf+0xd6>
      } else if(c == 'x') {
     ef0:	07a78863          	beq	a5,s10,f60 <vprintf+0xf2>
      } else if(c == 'p') {
     ef4:	09b78463          	beq	a5,s11,f7c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
     ef8:	07300713          	li	a4,115
     efc:	0ce78663          	beq	a5,a4,fc8 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
     f00:	06300713          	li	a4,99
     f04:	0ee78e63          	beq	a5,a4,1000 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
     f08:	11478863          	beq	a5,s4,1018 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
     f0c:	85d2                	mv	a1,s4
     f0e:	8556                	mv	a0,s5
     f10:	00000097          	auipc	ra,0x0
     f14:	e92080e7          	jalr	-366(ra) # da2 <putc>
        putc(fd, c);
     f18:	85ca                	mv	a1,s2
     f1a:	8556                	mv	a0,s5
     f1c:	00000097          	auipc	ra,0x0
     f20:	e86080e7          	jalr	-378(ra) # da2 <putc>
      }
      state = 0;
     f24:	4981                	li	s3,0
     f26:	b765                	j	ece <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
     f28:	008b0913          	addi	s2,s6,8
     f2c:	4685                	li	a3,1
     f2e:	4629                	li	a2,10
     f30:	000b2583          	lw	a1,0(s6)
     f34:	8556                	mv	a0,s5
     f36:	00000097          	auipc	ra,0x0
     f3a:	e8e080e7          	jalr	-370(ra) # dc4 <printint>
     f3e:	8b4a                	mv	s6,s2
      state = 0;
     f40:	4981                	li	s3,0
     f42:	b771                	j	ece <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
     f44:	008b0913          	addi	s2,s6,8
     f48:	4681                	li	a3,0
     f4a:	4629                	li	a2,10
     f4c:	000b2583          	lw	a1,0(s6)
     f50:	8556                	mv	a0,s5
     f52:	00000097          	auipc	ra,0x0
     f56:	e72080e7          	jalr	-398(ra) # dc4 <printint>
     f5a:	8b4a                	mv	s6,s2
      state = 0;
     f5c:	4981                	li	s3,0
     f5e:	bf85                	j	ece <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
     f60:	008b0913          	addi	s2,s6,8
     f64:	4681                	li	a3,0
     f66:	4641                	li	a2,16
     f68:	000b2583          	lw	a1,0(s6)
     f6c:	8556                	mv	a0,s5
     f6e:	00000097          	auipc	ra,0x0
     f72:	e56080e7          	jalr	-426(ra) # dc4 <printint>
     f76:	8b4a                	mv	s6,s2
      state = 0;
     f78:	4981                	li	s3,0
     f7a:	bf91                	j	ece <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
     f7c:	008b0793          	addi	a5,s6,8
     f80:	f8f43423          	sd	a5,-120(s0)
     f84:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
     f88:	03000593          	li	a1,48
     f8c:	8556                	mv	a0,s5
     f8e:	00000097          	auipc	ra,0x0
     f92:	e14080e7          	jalr	-492(ra) # da2 <putc>
  putc(fd, 'x');
     f96:	85ea                	mv	a1,s10
     f98:	8556                	mv	a0,s5
     f9a:	00000097          	auipc	ra,0x0
     f9e:	e08080e7          	jalr	-504(ra) # da2 <putc>
     fa2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     fa4:	03c9d793          	srli	a5,s3,0x3c
     fa8:	97de                	add	a5,a5,s7
     faa:	0007c583          	lbu	a1,0(a5)
     fae:	8556                	mv	a0,s5
     fb0:	00000097          	auipc	ra,0x0
     fb4:	df2080e7          	jalr	-526(ra) # da2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     fb8:	0992                	slli	s3,s3,0x4
     fba:	397d                	addiw	s2,s2,-1
     fbc:	fe0914e3          	bnez	s2,fa4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
     fc0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
     fc4:	4981                	li	s3,0
     fc6:	b721                	j	ece <vprintf+0x60>
        s = va_arg(ap, char*);
     fc8:	008b0993          	addi	s3,s6,8
     fcc:	000b3903          	ld	s2,0(s6)
        if(s == 0)
     fd0:	02090163          	beqz	s2,ff2 <vprintf+0x184>
        while(*s != 0){
     fd4:	00094583          	lbu	a1,0(s2)
     fd8:	c9a1                	beqz	a1,1028 <vprintf+0x1ba>
          putc(fd, *s);
     fda:	8556                	mv	a0,s5
     fdc:	00000097          	auipc	ra,0x0
     fe0:	dc6080e7          	jalr	-570(ra) # da2 <putc>
          s++;
     fe4:	0905                	addi	s2,s2,1
        while(*s != 0){
     fe6:	00094583          	lbu	a1,0(s2)
     fea:	f9e5                	bnez	a1,fda <vprintf+0x16c>
        s = va_arg(ap, char*);
     fec:	8b4e                	mv	s6,s3
      state = 0;
     fee:	4981                	li	s3,0
     ff0:	bdf9                	j	ece <vprintf+0x60>
          s = "(null)";
     ff2:	00000917          	auipc	s2,0x0
     ff6:	7e690913          	addi	s2,s2,2022 # 17d8 <malloc+0x6a0>
        while(*s != 0){
     ffa:	02800593          	li	a1,40
     ffe:	bff1                	j	fda <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    1000:	008b0913          	addi	s2,s6,8
    1004:	000b4583          	lbu	a1,0(s6)
    1008:	8556                	mv	a0,s5
    100a:	00000097          	auipc	ra,0x0
    100e:	d98080e7          	jalr	-616(ra) # da2 <putc>
    1012:	8b4a                	mv	s6,s2
      state = 0;
    1014:	4981                	li	s3,0
    1016:	bd65                	j	ece <vprintf+0x60>
        putc(fd, c);
    1018:	85d2                	mv	a1,s4
    101a:	8556                	mv	a0,s5
    101c:	00000097          	auipc	ra,0x0
    1020:	d86080e7          	jalr	-634(ra) # da2 <putc>
      state = 0;
    1024:	4981                	li	s3,0
    1026:	b565                	j	ece <vprintf+0x60>
        s = va_arg(ap, char*);
    1028:	8b4e                	mv	s6,s3
      state = 0;
    102a:	4981                	li	s3,0
    102c:	b54d                	j	ece <vprintf+0x60>
    }
  }
}
    102e:	70e6                	ld	ra,120(sp)
    1030:	7446                	ld	s0,112(sp)
    1032:	74a6                	ld	s1,104(sp)
    1034:	7906                	ld	s2,96(sp)
    1036:	69e6                	ld	s3,88(sp)
    1038:	6a46                	ld	s4,80(sp)
    103a:	6aa6                	ld	s5,72(sp)
    103c:	6b06                	ld	s6,64(sp)
    103e:	7be2                	ld	s7,56(sp)
    1040:	7c42                	ld	s8,48(sp)
    1042:	7ca2                	ld	s9,40(sp)
    1044:	7d02                	ld	s10,32(sp)
    1046:	6de2                	ld	s11,24(sp)
    1048:	6109                	addi	sp,sp,128
    104a:	8082                	ret

000000000000104c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    104c:	715d                	addi	sp,sp,-80
    104e:	ec06                	sd	ra,24(sp)
    1050:	e822                	sd	s0,16(sp)
    1052:	1000                	addi	s0,sp,32
    1054:	e010                	sd	a2,0(s0)
    1056:	e414                	sd	a3,8(s0)
    1058:	e818                	sd	a4,16(s0)
    105a:	ec1c                	sd	a5,24(s0)
    105c:	03043023          	sd	a6,32(s0)
    1060:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1064:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1068:	8622                	mv	a2,s0
    106a:	00000097          	auipc	ra,0x0
    106e:	e04080e7          	jalr	-508(ra) # e6e <vprintf>
}
    1072:	60e2                	ld	ra,24(sp)
    1074:	6442                	ld	s0,16(sp)
    1076:	6161                	addi	sp,sp,80
    1078:	8082                	ret

000000000000107a <printf>:

void
printf(const char *fmt, ...)
{
    107a:	711d                	addi	sp,sp,-96
    107c:	ec06                	sd	ra,24(sp)
    107e:	e822                	sd	s0,16(sp)
    1080:	1000                	addi	s0,sp,32
    1082:	e40c                	sd	a1,8(s0)
    1084:	e810                	sd	a2,16(s0)
    1086:	ec14                	sd	a3,24(s0)
    1088:	f018                	sd	a4,32(s0)
    108a:	f41c                	sd	a5,40(s0)
    108c:	03043823          	sd	a6,48(s0)
    1090:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1094:	00840613          	addi	a2,s0,8
    1098:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    109c:	85aa                	mv	a1,a0
    109e:	4505                	li	a0,1
    10a0:	00000097          	auipc	ra,0x0
    10a4:	dce080e7          	jalr	-562(ra) # e6e <vprintf>
}
    10a8:	60e2                	ld	ra,24(sp)
    10aa:	6442                	ld	s0,16(sp)
    10ac:	6125                	addi	sp,sp,96
    10ae:	8082                	ret

00000000000010b0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    10b0:	1141                	addi	sp,sp,-16
    10b2:	e422                	sd	s0,8(sp)
    10b4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    10b6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    10ba:	00000797          	auipc	a5,0x0
    10be:	73e7b783          	ld	a5,1854(a5) # 17f8 <freep>
    10c2:	a805                	j	10f2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    10c4:	4618                	lw	a4,8(a2)
    10c6:	9db9                	addw	a1,a1,a4
    10c8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    10cc:	6398                	ld	a4,0(a5)
    10ce:	6318                	ld	a4,0(a4)
    10d0:	fee53823          	sd	a4,-16(a0)
    10d4:	a091                	j	1118 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    10d6:	ff852703          	lw	a4,-8(a0)
    10da:	9e39                	addw	a2,a2,a4
    10dc:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    10de:	ff053703          	ld	a4,-16(a0)
    10e2:	e398                	sd	a4,0(a5)
    10e4:	a099                	j	112a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    10e6:	6398                	ld	a4,0(a5)
    10e8:	00e7e463          	bltu	a5,a4,10f0 <free+0x40>
    10ec:	00e6ea63          	bltu	a3,a4,1100 <free+0x50>
{
    10f0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    10f2:	fed7fae3          	bgeu	a5,a3,10e6 <free+0x36>
    10f6:	6398                	ld	a4,0(a5)
    10f8:	00e6e463          	bltu	a3,a4,1100 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    10fc:	fee7eae3          	bltu	a5,a4,10f0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    1100:	ff852583          	lw	a1,-8(a0)
    1104:	6390                	ld	a2,0(a5)
    1106:	02059813          	slli	a6,a1,0x20
    110a:	01c85713          	srli	a4,a6,0x1c
    110e:	9736                	add	a4,a4,a3
    1110:	fae60ae3          	beq	a2,a4,10c4 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1114:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1118:	4790                	lw	a2,8(a5)
    111a:	02061593          	slli	a1,a2,0x20
    111e:	01c5d713          	srli	a4,a1,0x1c
    1122:	973e                	add	a4,a4,a5
    1124:	fae689e3          	beq	a3,a4,10d6 <free+0x26>
  } else
    p->s.ptr = bp;
    1128:	e394                	sd	a3,0(a5)
  freep = p;
    112a:	00000717          	auipc	a4,0x0
    112e:	6cf73723          	sd	a5,1742(a4) # 17f8 <freep>
}
    1132:	6422                	ld	s0,8(sp)
    1134:	0141                	addi	sp,sp,16
    1136:	8082                	ret

0000000000001138 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1138:	7139                	addi	sp,sp,-64
    113a:	fc06                	sd	ra,56(sp)
    113c:	f822                	sd	s0,48(sp)
    113e:	f426                	sd	s1,40(sp)
    1140:	f04a                	sd	s2,32(sp)
    1142:	ec4e                	sd	s3,24(sp)
    1144:	e852                	sd	s4,16(sp)
    1146:	e456                	sd	s5,8(sp)
    1148:	e05a                	sd	s6,0(sp)
    114a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    114c:	02051493          	slli	s1,a0,0x20
    1150:	9081                	srli	s1,s1,0x20
    1152:	04bd                	addi	s1,s1,15
    1154:	8091                	srli	s1,s1,0x4
    1156:	0014899b          	addiw	s3,s1,1
    115a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    115c:	00000517          	auipc	a0,0x0
    1160:	69c53503          	ld	a0,1692(a0) # 17f8 <freep>
    1164:	c515                	beqz	a0,1190 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1166:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1168:	4798                	lw	a4,8(a5)
    116a:	02977f63          	bgeu	a4,s1,11a8 <malloc+0x70>
    116e:	8a4e                	mv	s4,s3
    1170:	0009871b          	sext.w	a4,s3
    1174:	6685                	lui	a3,0x1
    1176:	00d77363          	bgeu	a4,a3,117c <malloc+0x44>
    117a:	6a05                	lui	s4,0x1
    117c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1180:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1184:	00000917          	auipc	s2,0x0
    1188:	67490913          	addi	s2,s2,1652 # 17f8 <freep>
  if(p == (char*)-1)
    118c:	5afd                	li	s5,-1
    118e:	a895                	j	1202 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    1190:	00000797          	auipc	a5,0x0
    1194:	67078793          	addi	a5,a5,1648 # 1800 <base>
    1198:	00000717          	auipc	a4,0x0
    119c:	66f73023          	sd	a5,1632(a4) # 17f8 <freep>
    11a0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    11a2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    11a6:	b7e1                	j	116e <malloc+0x36>
      if(p->s.size == nunits)
    11a8:	02e48c63          	beq	s1,a4,11e0 <malloc+0xa8>
        p->s.size -= nunits;
    11ac:	4137073b          	subw	a4,a4,s3
    11b0:	c798                	sw	a4,8(a5)
        p += p->s.size;
    11b2:	02071693          	slli	a3,a4,0x20
    11b6:	01c6d713          	srli	a4,a3,0x1c
    11ba:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    11bc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    11c0:	00000717          	auipc	a4,0x0
    11c4:	62a73c23          	sd	a0,1592(a4) # 17f8 <freep>
      return (void*)(p + 1);
    11c8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    11cc:	70e2                	ld	ra,56(sp)
    11ce:	7442                	ld	s0,48(sp)
    11d0:	74a2                	ld	s1,40(sp)
    11d2:	7902                	ld	s2,32(sp)
    11d4:	69e2                	ld	s3,24(sp)
    11d6:	6a42                	ld	s4,16(sp)
    11d8:	6aa2                	ld	s5,8(sp)
    11da:	6b02                	ld	s6,0(sp)
    11dc:	6121                	addi	sp,sp,64
    11de:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    11e0:	6398                	ld	a4,0(a5)
    11e2:	e118                	sd	a4,0(a0)
    11e4:	bff1                	j	11c0 <malloc+0x88>
  hp->s.size = nu;
    11e6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    11ea:	0541                	addi	a0,a0,16
    11ec:	00000097          	auipc	ra,0x0
    11f0:	ec4080e7          	jalr	-316(ra) # 10b0 <free>
  return freep;
    11f4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    11f8:	d971                	beqz	a0,11cc <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    11fa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    11fc:	4798                	lw	a4,8(a5)
    11fe:	fa9775e3          	bgeu	a4,s1,11a8 <malloc+0x70>
    if(p == freep)
    1202:	00093703          	ld	a4,0(s2)
    1206:	853e                	mv	a0,a5
    1208:	fef719e3          	bne	a4,a5,11fa <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    120c:	8552                	mv	a0,s4
    120e:	00000097          	auipc	ra,0x0
    1212:	b44080e7          	jalr	-1212(ra) # d52 <sbrk>
  if(p == (char*)-1)
    1216:	fd5518e3          	bne	a0,s5,11e6 <malloc+0xae>
        return 0;
    121a:	4501                	li	a0,0
    121c:	bf45                	j	11cc <malloc+0x94>
