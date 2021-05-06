
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
       e:	d54080e7          	jalr	-684(ra) # d5e <sleep>
    printf("Thread is now running tid=%d\n",kthread_id());
      12:	00001097          	auipc	ra,0x1
      16:	d7c080e7          	jalr	-644(ra) # d8e <kthread_id>
      1a:	85aa                	mv	a1,a0
      1c:	00001517          	auipc	a0,0x1
      20:	20c50513          	addi	a0,a0,524 # 1228 <malloc+0xec>
      24:	00001097          	auipc	ra,0x1
      28:	05a080e7          	jalr	90(ra) # 107e <printf>
    kthread_exit(9);
      2c:	4525                	li	a0,9
      2e:	00001097          	auipc	ra,0x1
      32:	d68080e7          	jalr	-664(ra) # d96 <kthread_exit>
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
      52:	d10080e7          	jalr	-752(ra) # d5e <sleep>
    for(int i=0;i<100;i++){
      56:	4481                	li	s1,0
        printf("%d:Thread is now running tid=%d\n",i,kthread_id());
      58:	00001997          	auipc	s3,0x1
      5c:	1f098993          	addi	s3,s3,496 # 1248 <malloc+0x10c>
    for(int i=0;i<100;i++){
      60:	06400913          	li	s2,100
        printf("%d:Thread is now running tid=%d\n",i,kthread_id());
      64:	00001097          	auipc	ra,0x1
      68:	d2a080e7          	jalr	-726(ra) # d8e <kthread_id>
      6c:	862a                	mv	a2,a0
      6e:	85a6                	mv	a1,s1
      70:	854e                	mv	a0,s3
      72:	00001097          	auipc	ra,0x1
      76:	00c080e7          	jalr	12(ra) # 107e <printf>
    for(int i=0;i<100;i++){
      7a:	2485                	addiw	s1,s1,1
      7c:	ff2494e3          	bne	s1,s2,64 <test_thread_loop+0x26>
    }
    kthread_exit(9);
      80:	4525                	li	a0,9
      82:	00001097          	auipc	ra,0x1
      86:	d14080e7          	jalr	-748(ra) # d96 <kthread_exit>
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
      a6:	cbc080e7          	jalr	-836(ra) # d5e <sleep>
    printf("Thread is now running tid=%d\n",kthread_id());
      aa:	00001097          	auipc	ra,0x1
      ae:	ce4080e7          	jalr	-796(ra) # d8e <kthread_id>
      b2:	85aa                	mv	a1,a0
      b4:	00001517          	auipc	a0,0x1
      b8:	17450513          	addi	a0,a0,372 # 1228 <malloc+0xec>
      bc:	00001097          	auipc	ra,0x1
      c0:	fc2080e7          	jalr	-62(ra) # 107e <printf>
    kthread_exit(9);
      c4:	4525                	li	a0,9
      c6:	00001097          	auipc	ra,0x1
      ca:	cd0080e7          	jalr	-816(ra) # d96 <kthread_exit>
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
      e4:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa70415b>
      e8:	fcf42c23          	sw	a5,-40(s0)
      ec:	fc040e23          	sb	zero,-36(s0)
      f0:	1f400493          	li	s1,500
    for(int i=0;i<500;i++){
        write(1, st, 5);
      f4:	4615                	li	a2,5
      f6:	fd840593          	addi	a1,s0,-40
      fa:	4505                	li	a0,1
      fc:	00001097          	auipc	ra,0x1
     100:	bf2080e7          	jalr	-1038(ra) # cee <write>
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
     120:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa70415b>
     124:	fcf42c23          	sw	a5,-40(s0)
     128:	fc040e23          	sb	zero,-36(s0)
     12c:	1f400493          	li	s1,500
    for(int i=0;i<500;i++){
        write(1, st, 5);
     130:	4615                	li	a2,5
     132:	fd840593          	addi	a1,s0,-40
     136:	4505                	li	a0,1
     138:	00001097          	auipc	ra,0x1
     13c:	bb6080e7          	jalr	-1098(ra) # cee <write>
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
     15a:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa70415b>
     15e:	fef42423          	sw	a5,-24(s0)
     162:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
     166:	4615                	li	a2,5
     168:	fe840593          	addi	a1,s0,-24
     16c:	4505                	li	a0,1
     16e:	00001097          	auipc	ra,0x1
     172:	b80080e7          	jalr	-1152(ra) # cee <write>
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
     190:	b3a080e7          	jalr	-1222(ra) # cc6 <fork>
     194:	84aa                	mv	s1,a0
    if(pid==0){
     196:	ed05                	bnez	a0,1ce <test_sigkill+0x50>
        sleep(5);
     198:	4515                	li	a0,5
     19a:	00001097          	auipc	ra,0x1
     19e:	bc4080e7          	jalr	-1084(ra) # d5e <sleep>
            printf("about to get killed %d\n",i);
     1a2:	00001997          	auipc	s3,0x1
     1a6:	0ce98993          	addi	s3,s3,206 # 1270 <malloc+0x134>
        for(int i=0;i<300;i++)
     1aa:	12c00913          	li	s2,300
            printf("about to get killed %d\n",i);
     1ae:	85a6                	mv	a1,s1
     1b0:	854e                	mv	a0,s3
     1b2:	00001097          	auipc	ra,0x1
     1b6:	ecc080e7          	jalr	-308(ra) # 107e <printf>
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
     1d4:	b8e080e7          	jalr	-1138(ra) # d5e <sleep>
        printf("parent send signal to to kill child\n");
     1d8:	00001517          	auipc	a0,0x1
     1dc:	0b050513          	addi	a0,a0,176 # 1288 <malloc+0x14c>
     1e0:	00001097          	auipc	ra,0x1
     1e4:	e9e080e7          	jalr	-354(ra) # 107e <printf>
        printf("kill ret= %d\n",kill(pid, SIGKILL));
     1e8:	45a5                	li	a1,9
     1ea:	8526                	mv	a0,s1
     1ec:	00001097          	auipc	ra,0x1
     1f0:	b12080e7          	jalr	-1262(ra) # cfe <kill>
     1f4:	85aa                	mv	a1,a0
     1f6:	00001517          	auipc	a0,0x1
     1fa:	0ba50513          	addi	a0,a0,186 # 12b0 <malloc+0x174>
     1fe:	00001097          	auipc	ra,0x1
     202:	e80080e7          	jalr	-384(ra) # 107e <printf>
        printf("parent wait for child\n");
     206:	00001517          	auipc	a0,0x1
     20a:	0ba50513          	addi	a0,a0,186 # 12c0 <malloc+0x184>
     20e:	00001097          	auipc	ra,0x1
     212:	e70080e7          	jalr	-400(ra) # 107e <printf>
        wait(0);
     216:	4501                	li	a0,0
     218:	00001097          	auipc	ra,0x1
     21c:	abe080e7          	jalr	-1346(ra) # cd6 <wait>
        printf("parent: child is dead\n");
     220:	00001517          	auipc	a0,0x1
     224:	0b850513          	addi	a0,a0,184 # 12d8 <malloc+0x19c>
     228:	00001097          	auipc	ra,0x1
     22c:	e56080e7          	jalr	-426(ra) # 107e <printf>
        sleep(10);
     230:	4529                	li	a0,10
     232:	00001097          	auipc	ra,0x1
     236:	b2c080e7          	jalr	-1236(ra) # d5e <sleep>
        exit(0);
     23a:	4501                	li	a0,0
     23c:	00001097          	auipc	ra,0x1
     240:	a92080e7          	jalr	-1390(ra) # cce <exit>

0000000000000244 <sig_handler>:
sig_handler(int signum){
     244:	1101                	addi	sp,sp,-32
     246:	ec06                	sd	ra,24(sp)
     248:	e822                	sd	s0,16(sp)
     24a:	1000                	addi	s0,sp,32
    char st[5] = "wap\n";
     24c:	0a7067b7          	lui	a5,0xa706
     250:	17778793          	addi	a5,a5,375 # a706177 <__global_pointer$+0xa70416e>
     254:	fef42423          	sw	a5,-24(s0)
     258:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
     25c:	4615                	li	a2,5
     25e:	fe840593          	addi	a1,s0,-24
     262:	4505                	li	a0,1
     264:	00001097          	auipc	ra,0x1
     268:	a8a080e7          	jalr	-1398(ra) # cee <write>
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
     284:	a46080e7          	jalr	-1466(ra) # cc6 <fork>
    int signum1=3;
    if(pid==0){
     288:	e569                	bnez	a0,352 <test_usersig+0xde>
        struct sigaction act;
        struct sigaction act2;

        printf("sighandler= %p\n",&sig_handler2);
     28a:	00000597          	auipc	a1,0x0
     28e:	ec458593          	addi	a1,a1,-316 # 14e <sig_handler2>
     292:	00001517          	auipc	a0,0x1
     296:	05e50513          	addi	a0,a0,94 # 12f0 <malloc+0x1b4>
     29a:	00001097          	auipc	ra,0x1
     29e:	de4080e7          	jalr	-540(ra) # 107e <printf>
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
     2cc:	aae080e7          	jalr	-1362(ra) # d76 <sigaction>
     2d0:	84aa                	mv	s1,a0
        printf("old act->sa handler= %p, mask=%d\n",oldact.sa_handler,oldact.sigmask);
     2d2:	fd842603          	lw	a2,-40(s0)
     2d6:	fd043583          	ld	a1,-48(s0)
     2da:	00001517          	auipc	a0,0x1
     2de:	02650513          	addi	a0,a0,38 # 1300 <malloc+0x1c4>
     2e2:	00001097          	auipc	ra,0x1
     2e6:	d9c080e7          	jalr	-612(ra) # 107e <printf>
        printf("child return from sigaction = %d\n",ret);
     2ea:	85a6                	mv	a1,s1
     2ec:	00001517          	auipc	a0,0x1
     2f0:	03c50513          	addi	a0,a0,60 # 1328 <malloc+0x1ec>
     2f4:	00001097          	auipc	ra,0x1
     2f8:	d8a080e7          	jalr	-630(ra) # 107e <printf>
        sleep(10);
     2fc:	4529                	li	a0,10
     2fe:	00001097          	auipc	ra,0x1
     302:	a60080e7          	jalr	-1440(ra) # d5e <sleep>
     306:	44a9                	li	s1,10
        for(int i=0;i<10;i++){
            printf("child doing stuff before exit \n");
     308:	00001917          	auipc	s2,0x1
     30c:	04890913          	addi	s2,s2,72 # 1350 <malloc+0x214>
     310:	854a                	mv	a0,s2
     312:	00001097          	auipc	ra,0x1
     316:	d6c080e7          	jalr	-660(ra) # 107e <printf>
        for(int i=0;i<10;i++){
     31a:	34fd                	addiw	s1,s1,-1
     31c:	f8f5                	bnez	s1,310 <test_usersig+0x9c>
        }
        ret=sigaction(signum1,&act,&oldact);
     31e:	fd040613          	addi	a2,s0,-48
     322:	fc040593          	addi	a1,s0,-64
     326:	450d                	li	a0,3
     328:	00001097          	auipc	ra,0x1
     32c:	a4e080e7          	jalr	-1458(ra) # d76 <sigaction>
        printf("oldact should be the same as new act before \n oldact->mask=%d \t oldact->sa_handler=%d \n",oldact.sigmask,oldact.sa_handler);
     330:	fd043603          	ld	a2,-48(s0)
     334:	fd842583          	lw	a1,-40(s0)
     338:	00001517          	auipc	a0,0x1
     33c:	03850513          	addi	a0,a0,56 # 1370 <malloc+0x234>
     340:	00001097          	auipc	ra,0x1
     344:	d3e080e7          	jalr	-706(ra) # 107e <printf>

        exit(0);
     348:	4501                	li	a0,0
     34a:	00001097          	auipc	ra,0x1
     34e:	984080e7          	jalr	-1660(ra) # cce <exit>
     352:	84aa                	mv	s1,a0

    }
    else{
        sleep(5);
     354:	4515                	li	a0,5
     356:	00001097          	auipc	ra,0x1
     35a:	a08080e7          	jalr	-1528(ra) # d5e <sleep>
        printf("parent send sig 3 to child ret=%d\n",kill(pid,signum1));
     35e:	458d                	li	a1,3
     360:	8526                	mv	a0,s1
     362:	00001097          	auipc	ra,0x1
     366:	99c080e7          	jalr	-1636(ra) # cfe <kill>
     36a:	85aa                	mv	a1,a0
     36c:	00001517          	auipc	a0,0x1
     370:	05c50513          	addi	a0,a0,92 # 13c8 <malloc+0x28c>
     374:	00001097          	auipc	ra,0x1
     378:	d0a080e7          	jalr	-758(ra) # 107e <printf>
        // printf("parent send sig 4 to child ret=%d\n",kill(pid,4));

        wait(0);
     37c:	4501                	li	a0,0
     37e:	00001097          	auipc	ra,0x1
     382:	958080e7          	jalr	-1704(ra) # cd6 <wait>
        exit(0);
     386:	4501                	li	a0,0
     388:	00001097          	auipc	ra,0x1
     38c:	946080e7          	jalr	-1722(ra) # cce <exit>

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
     3a6:	9cc080e7          	jalr	-1588(ra) # d6e <sigprocmask>
    printf("got %d from calling to sigprocmask\n",ans);
     3aa:	0005059b          	sext.w	a1,a0
     3ae:	00001517          	auipc	a0,0x1
     3b2:	04250513          	addi	a0,a0,66 # 13f0 <malloc+0x2b4>
     3b6:	00001097          	auipc	ra,0x1
     3ba:	cc8080e7          	jalr	-824(ra) # 107e <printf>
    int pid=fork();
     3be:	00001097          	auipc	ra,0x1
     3c2:	908080e7          	jalr	-1784(ra) # cc6 <fork>
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
     3d0:	992080e7          	jalr	-1646(ra) # d5e <sleep>
        printf("parent: sent signal 22 to child ->child shuld block\n");
     3d4:	00001517          	auipc	a0,0x1
     3d8:	06450513          	addi	a0,a0,100 # 1438 <malloc+0x2fc>
     3dc:	00001097          	auipc	ra,0x1
     3e0:	ca2080e7          	jalr	-862(ra) # 107e <printf>
     3e4:	44a9                	li	s1,10
        for(int i=0; i<10;i++){
            kill(pid,signum1);
     3e6:	45d9                	li	a1,22
     3e8:	854a                	mv	a0,s2
     3ea:	00001097          	auipc	ra,0x1
     3ee:	914080e7          	jalr	-1772(ra) # cfe <kill>
        for(int i=0; i<10;i++){
     3f2:	34fd                	addiw	s1,s1,-1
     3f4:	f8ed                	bnez	s1,3e6 <test_block+0x56>
        }
        sleep(10);
     3f6:	4529                	li	a0,10
     3f8:	00001097          	auipc	ra,0x1
     3fc:	966080e7          	jalr	-1690(ra) # d5e <sleep>
        kill(pid,signum2);
     400:	45dd                	li	a1,23
     402:	854a                	mv	a0,s2
     404:	00001097          	auipc	ra,0x1
     408:	8fa080e7          	jalr	-1798(ra) # cfe <kill>

        printf("parent: sent signal 23 to child ->child shuld die\n");
     40c:	00001517          	auipc	a0,0x1
     410:	06450513          	addi	a0,a0,100 # 1470 <malloc+0x334>
     414:	00001097          	auipc	ra,0x1
     418:	c6a080e7          	jalr	-918(ra) # 107e <printf>
        wait(0);
     41c:	4501                	li	a0,0
     41e:	00001097          	auipc	ra,0x1
     422:	8b8080e7          	jalr	-1864(ra) # cd6 <wait>
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
     43a:	928080e7          	jalr	-1752(ra) # d5e <sleep>
            printf("child blocking signal %d \n",i);
     43e:	00001997          	auipc	s3,0x1
     442:	fda98993          	addi	s3,s3,-38 # 1418 <malloc+0x2dc>
        for(int i=0;i<1000;i++){
     446:	3e800493          	li	s1,1000
            sleep(1);
     44a:	4505                	li	a0,1
     44c:	00001097          	auipc	ra,0x1
     450:	912080e7          	jalr	-1774(ra) # d5e <sleep>
            printf("child blocking signal %d \n",i);
     454:	85ca                	mv	a1,s2
     456:	854e                	mv	a0,s3
     458:	00001097          	auipc	ra,0x1
     45c:	c26080e7          	jalr	-986(ra) # 107e <printf>
        for(int i=0;i<1000;i++){
     460:	2905                	addiw	s2,s2,1
     462:	fe9914e3          	bne	s2,s1,44a <test_block+0xba>
        exit(0);
     466:	4501                	li	a0,0
     468:	00001097          	auipc	ra,0x1
     46c:	866080e7          	jalr	-1946(ra) # cce <exit>

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
     482:	848080e7          	jalr	-1976(ra) # cc6 <fork>
     486:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
     488:	e915                	bnez	a0,4bc <test_stop_cont+0x4c>
        sleep(2);
     48a:	4509                	li	a0,2
     48c:	00001097          	auipc	ra,0x1
     490:	8d2080e7          	jalr	-1838(ra) # d5e <sleep>
        for(i=0;i<500;i++){
            printf("%d\n ", i);
     494:	00001997          	auipc	s3,0x1
     498:	01498993          	addi	s3,s3,20 # 14a8 <malloc+0x36c>
        for(i=0;i<500;i++){
     49c:	1f400913          	li	s2,500
            printf("%d\n ", i);
     4a0:	85a6                	mv	a1,s1
     4a2:	854e                	mv	a0,s3
     4a4:	00001097          	auipc	ra,0x1
     4a8:	bda080e7          	jalr	-1062(ra) # 107e <printf>
        for(i=0;i<500;i++){
     4ac:	2485                	addiw	s1,s1,1
     4ae:	ff2499e3          	bne	s1,s2,4a0 <test_stop_cont+0x30>
        }
        exit(0);
     4b2:	4501                	li	a0,0
     4b4:	00001097          	auipc	ra,0x1
     4b8:	81a080e7          	jalr	-2022(ra) # cce <exit>
    }else{
        printf("son pid=%d, dad pid=%d\n", pid, getpid());
     4bc:	00001097          	auipc	ra,0x1
     4c0:	892080e7          	jalr	-1902(ra) # d4e <getpid>
     4c4:	862a                	mv	a2,a0
     4c6:	85a6                	mv	a1,s1
     4c8:	00001517          	auipc	a0,0x1
     4cc:	fe850513          	addi	a0,a0,-24 # 14b0 <malloc+0x374>
     4d0:	00001097          	auipc	ra,0x1
     4d4:	bae080e7          	jalr	-1106(ra) # 107e <printf>
        sleep(5);
     4d8:	4515                	li	a0,5
     4da:	00001097          	auipc	ra,0x1
     4de:	884080e7          	jalr	-1916(ra) # d5e <sleep>
        printf("parent send stop ret= %d\n", kill(pid, SIGSTOP));
     4e2:	45c5                	li	a1,17
     4e4:	8526                	mv	a0,s1
     4e6:	00001097          	auipc	ra,0x1
     4ea:	818080e7          	jalr	-2024(ra) # cfe <kill>
     4ee:	85aa                	mv	a1,a0
     4f0:	00001517          	auipc	a0,0x1
     4f4:	fd850513          	addi	a0,a0,-40 # 14c8 <malloc+0x38c>
     4f8:	00001097          	auipc	ra,0x1
     4fc:	b86080e7          	jalr	-1146(ra) # 107e <printf>
        sleep(50);
     500:	03200513          	li	a0,50
     504:	00001097          	auipc	ra,0x1
     508:	85a080e7          	jalr	-1958(ra) # d5e <sleep>
        printf("parent send continue ret= %d\n", kill(pid, SIGCONT));
     50c:	45cd                	li	a1,19
     50e:	8526                	mv	a0,s1
     510:	00000097          	auipc	ra,0x0
     514:	7ee080e7          	jalr	2030(ra) # cfe <kill>
     518:	85aa                	mv	a1,a0
     51a:	00001517          	auipc	a0,0x1
     51e:	fce50513          	addi	a0,a0,-50 # 14e8 <malloc+0x3ac>
     522:	00001097          	auipc	ra,0x1
     526:	b5c080e7          	jalr	-1188(ra) # 107e <printf>
        wait(0);
     52a:	4501                	li	a0,0
     52c:	00000097          	auipc	ra,0x0
     530:	7aa080e7          	jalr	1962(ra) # cd6 <wait>
        // for(int i=0;i<100;i++)
        //  printf("parent..");
        sleep(10);
     534:	4529                	li	a0,10
     536:	00001097          	auipc	ra,0x1
     53a:	828080e7          	jalr	-2008(ra) # d5e <sleep>
        exit(0);
     53e:	4501                	li	a0,0
     540:	00000097          	auipc	ra,0x0
     544:	78e080e7          	jalr	1934(ra) # cce <exit>

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
     55a:	770080e7          	jalr	1904(ra) # cc6 <fork>
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
     568:	00c50513          	addi	a0,a0,12 # 1570 <malloc+0x434>
     56c:	00001097          	auipc	ra,0x1
     570:	b12080e7          	jalr	-1262(ra) # 107e <printf>
        sleep(5);
     574:	4515                	li	a0,5
     576:	00000097          	auipc	ra,0x0
     57a:	7e8080e7          	jalr	2024(ra) # d5e <sleep>
        kill(pid,signum);
     57e:	45d9                	li	a1,22
     580:	8526                	mv	a0,s1
     582:	00000097          	auipc	ra,0x0
     586:	77c080e7          	jalr	1916(ra) # cfe <kill>
        wait(0);
     58a:	4501                	li	a0,0
     58c:	00000097          	auipc	ra,0x0
     590:	74a080e7          	jalr	1866(ra) # cd6 <wait>

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
     5a8:	b98080e7          	jalr	-1128(ra) # 113c <malloc>
     5ac:	89aa                	mv	s3,a0
        oldAct=malloc(sizeof(sigaction));
     5ae:	4505                	li	a0,1
     5b0:	00001097          	auipc	ra,0x1
     5b4:	b8c080e7          	jalr	-1140(ra) # 113c <malloc>
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
     5ce:	7ac080e7          	jalr	1964(ra) # d76 <sigaction>
     5d2:	85aa                	mv	a1,a0
        printf("ans from sigaction %d, old act returned is: mask= %d address= %d\n",ans,oldAct->sigmask,(uint64)oldAct->sa_handler);
     5d4:	00093683          	ld	a3,0(s2)
     5d8:	00892603          	lw	a2,8(s2)
     5dc:	00001517          	auipc	a0,0x1
     5e0:	f2c50513          	addi	a0,a0,-212 # 1508 <malloc+0x3cc>
     5e4:	00001097          	auipc	ra,0x1
     5e8:	a9a080e7          	jalr	-1382(ra) # 107e <printf>
        sleep(6);
     5ec:	4519                	li	a0,6
     5ee:	00000097          	auipc	ra,0x0
     5f2:	770080e7          	jalr	1904(ra) # d5e <sleep>
            printf("child ignoring signal %d\n",i);
     5f6:	00001997          	auipc	s3,0x1
     5fa:	f5a98993          	addi	s3,s3,-166 # 1550 <malloc+0x414>
        for(int i=0;i<300;i++){
     5fe:	12c00913          	li	s2,300
            printf("child ignoring signal %d\n",i);
     602:	85a6                	mv	a1,s1
     604:	854e                	mv	a0,s3
     606:	00001097          	auipc	ra,0x1
     60a:	a78080e7          	jalr	-1416(ra) # 107e <printf>
        for(int i=0;i<300;i++){
     60e:	2485                	addiw	s1,s1,1
     610:	ff2499e3          	bne	s1,s2,602 <test_ignore+0xba>
        exit(0);
     614:	4501                	li	a0,0
     616:	00000097          	auipc	ra,0x0
     61a:	6b8080e7          	jalr	1720(ra) # cce <exit>

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
     638:	f4c50513          	addi	a0,a0,-180 # 1580 <malloc+0x444>
     63c:	00001097          	auipc	ra,0x1
     640:	a42080e7          	jalr	-1470(ra) # 107e <printf>
    printf("sighandler2= %p\n", &sig_handler_loop2);
     644:	00000597          	auipc	a1,0x0
     648:	ace58593          	addi	a1,a1,-1330 # 112 <sig_handler_loop2>
     64c:	00001517          	auipc	a0,0x1
     650:	f4c50513          	addi	a0,a0,-180 # 1598 <malloc+0x45c>
     654:	00001097          	auipc	ra,0x1
     658:	a2a080e7          	jalr	-1494(ra) # 107e <printf>


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
     67c:	64e080e7          	jalr	1614(ra) # cc6 <fork>
     680:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
     682:	ed15                	bnez	a0,6be <test_user_handler_kill+0xa0>
        int ret=sigaction(3,&act,&oldact);
     684:	fb040613          	addi	a2,s0,-80
     688:	fc040593          	addi	a1,s0,-64
     68c:	450d                	li	a0,3
     68e:	00000097          	auipc	ra,0x0
     692:	6e8080e7          	jalr	1768(ra) # d76 <sigaction>
        for(i=0;i<500;i++)
            printf("out-side handler %d\n ", i);
     696:	00001997          	auipc	s3,0x1
     69a:	f1a98993          	addi	s3,s3,-230 # 15b0 <malloc+0x474>
        for(i=0;i<500;i++)
     69e:	1f400913          	li	s2,500
            printf("out-side handler %d\n ", i);
     6a2:	85a6                	mv	a1,s1
     6a4:	854e                	mv	a0,s3
     6a6:	00001097          	auipc	ra,0x1
     6aa:	9d8080e7          	jalr	-1576(ra) # 107e <printf>
        for(i=0;i<500;i++)
     6ae:	2485                	addiw	s1,s1,1
     6b0:	ff2499e3          	bne	s1,s2,6a2 <test_user_handler_kill+0x84>
        exit(0);
     6b4:	4501                	li	a0,0
     6b6:	00000097          	auipc	ra,0x0
     6ba:	618080e7          	jalr	1560(ra) # cce <exit>
    }else{
        printf("son pid=%d, dad pid=%d\n",pid, getpid());
     6be:	00000097          	auipc	ra,0x0
     6c2:	690080e7          	jalr	1680(ra) # d4e <getpid>
     6c6:	862a                	mv	a2,a0
     6c8:	85a6                	mv	a1,s1
     6ca:	00001517          	auipc	a0,0x1
     6ce:	de650513          	addi	a0,a0,-538 # 14b0 <malloc+0x374>
     6d2:	00001097          	auipc	ra,0x1
     6d6:	9ac080e7          	jalr	-1620(ra) # 107e <printf>
        sleep(5);
     6da:	4515                	li	a0,5
     6dc:	00000097          	auipc	ra,0x0
     6e0:	682080e7          	jalr	1666(ra) # d5e <sleep>
        printf("parent send loop ret= %d\n",kill(pid, 3));
     6e4:	458d                	li	a1,3
     6e6:	8526                	mv	a0,s1
     6e8:	00000097          	auipc	ra,0x0
     6ec:	616080e7          	jalr	1558(ra) # cfe <kill>
     6f0:	85aa                	mv	a1,a0
     6f2:	00001517          	auipc	a0,0x1
     6f6:	ed650513          	addi	a0,a0,-298 # 15c8 <malloc+0x48c>
     6fa:	00001097          	auipc	ra,0x1
     6fe:	984080e7          	jalr	-1660(ra) # 107e <printf>
        sleep(20);
     702:	4551                	li	a0,20
     704:	00000097          	auipc	ra,0x0
     708:	65a080e7          	jalr	1626(ra) # d5e <sleep>
        printf("parent send kill ret= %d\n",kill(pid, SIGKILL));
     70c:	45a5                	li	a1,9
     70e:	8526                	mv	a0,s1
     710:	00000097          	auipc	ra,0x0
     714:	5ee080e7          	jalr	1518(ra) # cfe <kill>
     718:	85aa                	mv	a1,a0
     71a:	00001517          	auipc	a0,0x1
     71e:	ece50513          	addi	a0,a0,-306 # 15e8 <malloc+0x4ac>
     722:	00001097          	auipc	ra,0x1
     726:	95c080e7          	jalr	-1700(ra) # 107e <printf>
        wait(0);
     72a:	4501                	li	a0,0
     72c:	00000097          	auipc	ra,0x0
     730:	5aa080e7          	jalr	1450(ra) # cd6 <wait>
        printf("parent exiting\n");
     734:	00001517          	auipc	a0,0x1
     738:	ed450513          	addi	a0,a0,-300 # 1608 <malloc+0x4cc>
     73c:	00001097          	auipc	ra,0x1
     740:	942080e7          	jalr	-1726(ra) # 107e <printf>
        exit(0);
     744:	4501                	li	a0,0
     746:	00000097          	auipc	ra,0x0
     74a:	588080e7          	jalr	1416(ra) # cce <exit>

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
     75c:	fa050513          	addi	a0,a0,-96 # fa0 <vprintf+0x12e>
     760:	00001097          	auipc	ra,0x1
     764:	9dc080e7          	jalr	-1572(ra) # 113c <malloc>
     768:	84aa                	mv	s1,a0
    printf("father tid is = %d\n",kthread_id());
     76a:	00000097          	auipc	ra,0x0
     76e:	624080e7          	jalr	1572(ra) # d8e <kthread_id>
     772:	85aa                	mv	a1,a0
     774:	00001517          	auipc	a0,0x1
     778:	ea450513          	addi	a0,a0,-348 # 1618 <malloc+0x4dc>
     77c:	00001097          	auipc	ra,0x1
     780:	902080e7          	jalr	-1790(ra) # 107e <printf>
    tid = kthread_create(test_thread, stack);
     784:	85a6                	mv	a1,s1
     786:	00000517          	auipc	a0,0x0
     78a:	87a50513          	addi	a0,a0,-1926 # 0 <test_thread>
     78e:	00000097          	auipc	ra,0x0
     792:	5f8080e7          	jalr	1528(ra) # d86 <kthread_create>
     796:	892a                	mv	s2,a0
    printf("child tid %d",tid);
     798:	85aa                	mv	a1,a0
     79a:	00001517          	auipc	a0,0x1
     79e:	e9650513          	addi	a0,a0,-362 # 1630 <malloc+0x4f4>
     7a2:	00001097          	auipc	ra,0x1
     7a6:	8dc080e7          	jalr	-1828(ra) # 107e <printf>
    printf("father tid is = %d\n",kthread_id());
     7aa:	00000097          	auipc	ra,0x0
     7ae:	5e4080e7          	jalr	1508(ra) # d8e <kthread_id>
     7b2:	85aa                	mv	a1,a0
     7b4:	00001517          	auipc	a0,0x1
     7b8:	e6450513          	addi	a0,a0,-412 # 1618 <malloc+0x4dc>
     7bc:	00001097          	auipc	ra,0x1
     7c0:	8c2080e7          	jalr	-1854(ra) # 107e <printf>

    int ans =kthread_join(tid, &status);
     7c4:	fdc40593          	addi	a1,s0,-36
     7c8:	854a                	mv	a0,s2
     7ca:	00000097          	auipc	ra,0x0
     7ce:	5d4080e7          	jalr	1492(ra) # d9e <kthread_join>
     7d2:	892a                	mv	s2,a0
    printf("kthread join ret =%d , my tid =%d\n",ans,kthread_id());
     7d4:	00000097          	auipc	ra,0x0
     7d8:	5ba080e7          	jalr	1466(ra) # d8e <kthread_id>
     7dc:	862a                	mv	a2,a0
     7de:	85ca                	mv	a1,s2
     7e0:	00001517          	auipc	a0,0x1
     7e4:	e6050513          	addi	a0,a0,-416 # 1640 <malloc+0x504>
     7e8:	00001097          	auipc	ra,0x1
     7ec:	896080e7          	jalr	-1898(ra) # 107e <printf>
    tid = kthread_id();
     7f0:	00000097          	auipc	ra,0x0
     7f4:	59e080e7          	jalr	1438(ra) # d8e <kthread_id>
     7f8:	892a                	mv	s2,a0
    free(stack);
     7fa:	8526                	mv	a0,s1
     7fc:	00001097          	auipc	ra,0x1
     800:	8b8080e7          	jalr	-1864(ra) # 10b4 <free>
    printf("Finished testing threads, main thread id: %d, %d\n", tid,status);
     804:	fdc42603          	lw	a2,-36(s0)
     808:	85ca                	mv	a1,s2
     80a:	00001517          	auipc	a0,0x1
     80e:	e5e50513          	addi	a0,a0,-418 # 1668 <malloc+0x52c>
     812:	00001097          	auipc	ra,0x1
     816:	86c080e7          	jalr	-1940(ra) # 107e <printf>
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
     834:	fa050513          	addi	a0,a0,-96 # fa0 <vprintf+0x12e>
     838:	00001097          	auipc	ra,0x1
     83c:	904080e7          	jalr	-1788(ra) # 113c <malloc>
     840:	84aa                	mv	s1,a0
    printf("after malloc\n");
     842:	00001517          	auipc	a0,0x1
     846:	e5e50513          	addi	a0,a0,-418 # 16a0 <malloc+0x564>
     84a:	00001097          	auipc	ra,0x1
     84e:	834080e7          	jalr	-1996(ra) # 107e <printf>
    printf("add of func for new thread : %p\n",&test_thread);
     852:	fffff597          	auipc	a1,0xfffff
     856:	7ae58593          	addi	a1,a1,1966 # 0 <test_thread>
     85a:	00001517          	auipc	a0,0x1
     85e:	e5650513          	addi	a0,a0,-426 # 16b0 <malloc+0x574>
     862:	00001097          	auipc	ra,0x1
     866:	81c080e7          	jalr	-2020(ra) # 107e <printf>
    printf("add of func for new thread : %p\n",&test_thread2);
     86a:	00000597          	auipc	a1,0x0
     86e:	82e58593          	addi	a1,a1,-2002 # 98 <test_thread2>
     872:	00001517          	auipc	a0,0x1
     876:	e3e50513          	addi	a0,a0,-450 # 16b0 <malloc+0x574>
     87a:	00001097          	auipc	ra,0x1
     87e:	804080e7          	jalr	-2044(ra) # 107e <printf>

    tid = kthread_create(&test_thread2, stack);
     882:	85a6                	mv	a1,s1
     884:	00000517          	auipc	a0,0x0
     888:	81450513          	addi	a0,a0,-2028 # 98 <test_thread2>
     88c:	00000097          	auipc	ra,0x0
     890:	4fa080e7          	jalr	1274(ra) # d86 <kthread_create>
     894:	85aa                	mv	a1,a0
    
    printf("after create %d \n",tid);
     896:	00001517          	auipc	a0,0x1
     89a:	e4250513          	addi	a0,a0,-446 # 16d8 <malloc+0x59c>
     89e:	00000097          	auipc	ra,0x0
     8a2:	7e0080e7          	jalr	2016(ra) # 107e <printf>

    sleep(5);
     8a6:	4515                	li	a0,5
     8a8:	00000097          	auipc	ra,0x0
     8ac:	4b6080e7          	jalr	1206(ra) # d5e <sleep>
    printf("after kthread\n");
     8b0:	00001517          	auipc	a0,0x1
     8b4:	e4050513          	addi	a0,a0,-448 # 16f0 <malloc+0x5b4>
     8b8:	00000097          	auipc	ra,0x0
     8bc:	7c6080e7          	jalr	1990(ra) # 107e <printf>
    tid = kthread_id();
     8c0:	00000097          	auipc	ra,0x0
     8c4:	4ce080e7          	jalr	1230(ra) # d8e <kthread_id>
     8c8:	892a                	mv	s2,a0
    free(stack);
     8ca:	8526                	mv	a0,s1
     8cc:	00000097          	auipc	ra,0x0
     8d0:	7e8080e7          	jalr	2024(ra) # 10b4 <free>
    printf("Finished testing threads, main thread id: %d, %d\n", tid,status);
     8d4:	4601                	li	a2,0
     8d6:	85ca                	mv	a1,s2
     8d8:	00001517          	auipc	a0,0x1
     8dc:	d9050513          	addi	a0,a0,-624 # 1668 <malloc+0x52c>
     8e0:	00000097          	auipc	ra,0x0
     8e4:	79e080e7          	jalr	1950(ra) # 107e <printf>
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
     902:	fa050513          	addi	a0,a0,-96 # fa0 <vprintf+0x12e>
     906:	00001097          	auipc	ra,0x1
     90a:	836080e7          	jalr	-1994(ra) # 113c <malloc>
     90e:	84aa                	mv	s1,a0
    printf("add of func for new thread : %p\n",&test_thread);
     910:	fffff597          	auipc	a1,0xfffff
     914:	6f058593          	addi	a1,a1,1776 # 0 <test_thread>
     918:	00001517          	auipc	a0,0x1
     91c:	d9850513          	addi	a0,a0,-616 # 16b0 <malloc+0x574>
     920:	00000097          	auipc	ra,0x0
     924:	75e080e7          	jalr	1886(ra) # 107e <printf>

    tid = kthread_create(&test_thread_loop, stack);
     928:	85a6                	mv	a1,s1
     92a:	fffff517          	auipc	a0,0xfffff
     92e:	71450513          	addi	a0,a0,1812 # 3e <test_thread_loop>
     932:	00000097          	auipc	ra,0x0
     936:	454080e7          	jalr	1108(ra) # d86 <kthread_create>
     93a:	892a                	mv	s2,a0
    
    printf("after create ret tid= %d mytid= %d\n",tid,kthread_id());
     93c:	00000097          	auipc	ra,0x0
     940:	452080e7          	jalr	1106(ra) # d8e <kthread_id>
     944:	862a                	mv	a2,a0
     946:	85ca                	mv	a1,s2
     948:	00001517          	auipc	a0,0x1
     94c:	db850513          	addi	a0,a0,-584 # 1700 <malloc+0x5c4>
     950:	00000097          	auipc	ra,0x0
     954:	72e080e7          	jalr	1838(ra) # 107e <printf>

    free(stack);
     958:	8526                	mv	a0,s1
     95a:	00000097          	auipc	ra,0x0
     95e:	75a080e7          	jalr	1882(ra) # 10b4 <free>
    printf("Finished testing threads, main thread id: %d\n", kthread_id());
     962:	00000097          	auipc	ra,0x0
     966:	42c080e7          	jalr	1068(ra) # d8e <kthread_id>
     96a:	85aa                	mv	a1,a0
     96c:	00001517          	auipc	a0,0x1
     970:	dbc50513          	addi	a0,a0,-580 # 1728 <malloc+0x5ec>
     974:	00000097          	auipc	ra,0x0
     978:	70a080e7          	jalr	1802(ra) # 107e <printf>
    kthread_exit(0);
     97c:	4501                	li	a0,0
     97e:	00000097          	auipc	ra,0x0
     982:	418080e7          	jalr	1048(ra) # d96 <kthread_exit>
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
     9a6:	3ac080e7          	jalr	940(ra) # d4e <getpid>
     9aa:	85aa                	mv	a1,a0
  printf("master id = %d\n",master_pid);
     9ac:	00001517          	auipc	a0,0x1
     9b0:	dac50513          	addi	a0,a0,-596 # 1758 <malloc+0x61c>
     9b4:	00000097          	auipc	ra,0x0
     9b8:	6ca080e7          	jalr	1738(ra) # 107e <printf>
     9bc:	0c800913          	li	s2,200
  for(int i = 0; i < 200; i++){
    int pid = fork();
     9c0:	00000097          	auipc	ra,0x0
     9c4:	306080e7          	jalr	774(ra) # cc6 <fork>
     9c8:	84aa                	mv	s1,a0
    if(pid < 0){
     9ca:	02054263          	bltz	a0,9ee <reparent+0x5c>
      printf("%s: fork failed\n", s);
      exit(1);
    }
    if(pid){
     9ce:	cd21                	beqz	a0,a26 <reparent+0x94>
    //   printf("1\n");//TODO delete

      if(wait(0) != pid){
     9d0:	4501                	li	a0,0
     9d2:	00000097          	auipc	ra,0x0
     9d6:	304080e7          	jalr	772(ra) # cd6 <wait>
     9da:	02951863          	bne	a0,s1,a0a <reparent+0x78>
  for(int i = 0; i < 200; i++){
     9de:	397d                	addiw	s2,s2,-1
     9e0:	fe0910e3          	bnez	s2,9c0 <reparent+0x2e>

        
      exit(0);
    }
  }
  exit(0);
     9e4:	4501                	li	a0,0
     9e6:	00000097          	auipc	ra,0x0
     9ea:	2e8080e7          	jalr	744(ra) # cce <exit>
      printf("%s: fork failed\n", s);
     9ee:	85ce                	mv	a1,s3
     9f0:	00001517          	auipc	a0,0x1
     9f4:	d7850513          	addi	a0,a0,-648 # 1768 <malloc+0x62c>
     9f8:	00000097          	auipc	ra,0x0
     9fc:	686080e7          	jalr	1670(ra) # 107e <printf>
      exit(1);
     a00:	4505                	li	a0,1
     a02:	00000097          	auipc	ra,0x0
     a06:	2cc080e7          	jalr	716(ra) # cce <exit>
        printf("%s: wait wrong pid\n", s);
     a0a:	85ce                	mv	a1,s3
     a0c:	00001517          	auipc	a0,0x1
     a10:	d7450513          	addi	a0,a0,-652 # 1780 <malloc+0x644>
     a14:	00000097          	auipc	ra,0x0
     a18:	66a080e7          	jalr	1642(ra) # 107e <printf>
        exit(1);
     a1c:	4505                	li	a0,1
     a1e:	00000097          	auipc	ra,0x0
     a22:	2b0080e7          	jalr	688(ra) # cce <exit>
      int pid2 = fork();
     a26:	00000097          	auipc	ra,0x0
     a2a:	2a0080e7          	jalr	672(ra) # cc6 <fork>
      exit(0);
     a2e:	4501                	li	a0,0
     a30:	00000097          	auipc	ra,0x0
     a34:	29e080e7          	jalr	670(ra) # cce <exit>

0000000000000a38 <main>:
}

int main(){
     a38:	1141                	addi	sp,sp,-16
     a3a:	e406                	sd	ra,8(sp)
     a3c:	e022                	sd	s0,0(sp)
     a3e:	0800                	addi	s0,sp,16

    // printf("-----------------------------very easy thread test-----------------------------\n");
    // very_easy_thread_test("ff");


    printf("-----------------------------reparent test-----------------------------\n");
     a40:	00001517          	auipc	a0,0x1
     a44:	d5850513          	addi	a0,a0,-680 # 1798 <malloc+0x65c>
     a48:	00000097          	auipc	ra,0x0
     a4c:	636080e7          	jalr	1590(ra) # 107e <printf>
    reparent("ff");
     a50:	00001517          	auipc	a0,0x1
     a54:	d9850513          	addi	a0,a0,-616 # 17e8 <malloc+0x6ac>
     a58:	00000097          	auipc	ra,0x0
     a5c:	f3a080e7          	jalr	-198(ra) # 992 <reparent>

0000000000000a60 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     a60:	1141                	addi	sp,sp,-16
     a62:	e422                	sd	s0,8(sp)
     a64:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     a66:	87aa                	mv	a5,a0
     a68:	0585                	addi	a1,a1,1
     a6a:	0785                	addi	a5,a5,1
     a6c:	fff5c703          	lbu	a4,-1(a1)
     a70:	fee78fa3          	sb	a4,-1(a5)
     a74:	fb75                	bnez	a4,a68 <strcpy+0x8>
    ;
  return os;
}
     a76:	6422                	ld	s0,8(sp)
     a78:	0141                	addi	sp,sp,16
     a7a:	8082                	ret

0000000000000a7c <strcmp>:

int
strcmp(const char *p, const char *q)
{
     a7c:	1141                	addi	sp,sp,-16
     a7e:	e422                	sd	s0,8(sp)
     a80:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     a82:	00054783          	lbu	a5,0(a0)
     a86:	cb91                	beqz	a5,a9a <strcmp+0x1e>
     a88:	0005c703          	lbu	a4,0(a1)
     a8c:	00f71763          	bne	a4,a5,a9a <strcmp+0x1e>
    p++, q++;
     a90:	0505                	addi	a0,a0,1
     a92:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     a94:	00054783          	lbu	a5,0(a0)
     a98:	fbe5                	bnez	a5,a88 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     a9a:	0005c503          	lbu	a0,0(a1)
}
     a9e:	40a7853b          	subw	a0,a5,a0
     aa2:	6422                	ld	s0,8(sp)
     aa4:	0141                	addi	sp,sp,16
     aa6:	8082                	ret

0000000000000aa8 <strlen>:

uint
strlen(const char *s)
{
     aa8:	1141                	addi	sp,sp,-16
     aaa:	e422                	sd	s0,8(sp)
     aac:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     aae:	00054783          	lbu	a5,0(a0)
     ab2:	cf91                	beqz	a5,ace <strlen+0x26>
     ab4:	0505                	addi	a0,a0,1
     ab6:	87aa                	mv	a5,a0
     ab8:	4685                	li	a3,1
     aba:	9e89                	subw	a3,a3,a0
     abc:	00f6853b          	addw	a0,a3,a5
     ac0:	0785                	addi	a5,a5,1
     ac2:	fff7c703          	lbu	a4,-1(a5)
     ac6:	fb7d                	bnez	a4,abc <strlen+0x14>
    ;
  return n;
}
     ac8:	6422                	ld	s0,8(sp)
     aca:	0141                	addi	sp,sp,16
     acc:	8082                	ret
  for(n = 0; s[n]; n++)
     ace:	4501                	li	a0,0
     ad0:	bfe5                	j	ac8 <strlen+0x20>

0000000000000ad2 <memset>:

void*
memset(void *dst, int c, uint n)
{
     ad2:	1141                	addi	sp,sp,-16
     ad4:	e422                	sd	s0,8(sp)
     ad6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     ad8:	ca19                	beqz	a2,aee <memset+0x1c>
     ada:	87aa                	mv	a5,a0
     adc:	1602                	slli	a2,a2,0x20
     ade:	9201                	srli	a2,a2,0x20
     ae0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     ae4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     ae8:	0785                	addi	a5,a5,1
     aea:	fee79de3          	bne	a5,a4,ae4 <memset+0x12>
  }
  return dst;
}
     aee:	6422                	ld	s0,8(sp)
     af0:	0141                	addi	sp,sp,16
     af2:	8082                	ret

0000000000000af4 <strchr>:

char*
strchr(const char *s, char c)
{
     af4:	1141                	addi	sp,sp,-16
     af6:	e422                	sd	s0,8(sp)
     af8:	0800                	addi	s0,sp,16
  for(; *s; s++)
     afa:	00054783          	lbu	a5,0(a0)
     afe:	cb99                	beqz	a5,b14 <strchr+0x20>
    if(*s == c)
     b00:	00f58763          	beq	a1,a5,b0e <strchr+0x1a>
  for(; *s; s++)
     b04:	0505                	addi	a0,a0,1
     b06:	00054783          	lbu	a5,0(a0)
     b0a:	fbfd                	bnez	a5,b00 <strchr+0xc>
      return (char*)s;
  return 0;
     b0c:	4501                	li	a0,0
}
     b0e:	6422                	ld	s0,8(sp)
     b10:	0141                	addi	sp,sp,16
     b12:	8082                	ret
  return 0;
     b14:	4501                	li	a0,0
     b16:	bfe5                	j	b0e <strchr+0x1a>

0000000000000b18 <gets>:

char*
gets(char *buf, int max)
{
     b18:	711d                	addi	sp,sp,-96
     b1a:	ec86                	sd	ra,88(sp)
     b1c:	e8a2                	sd	s0,80(sp)
     b1e:	e4a6                	sd	s1,72(sp)
     b20:	e0ca                	sd	s2,64(sp)
     b22:	fc4e                	sd	s3,56(sp)
     b24:	f852                	sd	s4,48(sp)
     b26:	f456                	sd	s5,40(sp)
     b28:	f05a                	sd	s6,32(sp)
     b2a:	ec5e                	sd	s7,24(sp)
     b2c:	1080                	addi	s0,sp,96
     b2e:	8baa                	mv	s7,a0
     b30:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     b32:	892a                	mv	s2,a0
     b34:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     b36:	4aa9                	li	s5,10
     b38:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     b3a:	89a6                	mv	s3,s1
     b3c:	2485                	addiw	s1,s1,1
     b3e:	0344d863          	bge	s1,s4,b6e <gets+0x56>
    cc = read(0, &c, 1);
     b42:	4605                	li	a2,1
     b44:	faf40593          	addi	a1,s0,-81
     b48:	4501                	li	a0,0
     b4a:	00000097          	auipc	ra,0x0
     b4e:	19c080e7          	jalr	412(ra) # ce6 <read>
    if(cc < 1)
     b52:	00a05e63          	blez	a0,b6e <gets+0x56>
    buf[i++] = c;
     b56:	faf44783          	lbu	a5,-81(s0)
     b5a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     b5e:	01578763          	beq	a5,s5,b6c <gets+0x54>
     b62:	0905                	addi	s2,s2,1
     b64:	fd679be3          	bne	a5,s6,b3a <gets+0x22>
  for(i=0; i+1 < max; ){
     b68:	89a6                	mv	s3,s1
     b6a:	a011                	j	b6e <gets+0x56>
     b6c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     b6e:	99de                	add	s3,s3,s7
     b70:	00098023          	sb	zero,0(s3)
  return buf;
}
     b74:	855e                	mv	a0,s7
     b76:	60e6                	ld	ra,88(sp)
     b78:	6446                	ld	s0,80(sp)
     b7a:	64a6                	ld	s1,72(sp)
     b7c:	6906                	ld	s2,64(sp)
     b7e:	79e2                	ld	s3,56(sp)
     b80:	7a42                	ld	s4,48(sp)
     b82:	7aa2                	ld	s5,40(sp)
     b84:	7b02                	ld	s6,32(sp)
     b86:	6be2                	ld	s7,24(sp)
     b88:	6125                	addi	sp,sp,96
     b8a:	8082                	ret

0000000000000b8c <stat>:

int
stat(const char *n, struct stat *st)
{
     b8c:	1101                	addi	sp,sp,-32
     b8e:	ec06                	sd	ra,24(sp)
     b90:	e822                	sd	s0,16(sp)
     b92:	e426                	sd	s1,8(sp)
     b94:	e04a                	sd	s2,0(sp)
     b96:	1000                	addi	s0,sp,32
     b98:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     b9a:	4581                	li	a1,0
     b9c:	00000097          	auipc	ra,0x0
     ba0:	172080e7          	jalr	370(ra) # d0e <open>
  if(fd < 0)
     ba4:	02054563          	bltz	a0,bce <stat+0x42>
     ba8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     baa:	85ca                	mv	a1,s2
     bac:	00000097          	auipc	ra,0x0
     bb0:	17a080e7          	jalr	378(ra) # d26 <fstat>
     bb4:	892a                	mv	s2,a0
  close(fd);
     bb6:	8526                	mv	a0,s1
     bb8:	00000097          	auipc	ra,0x0
     bbc:	13e080e7          	jalr	318(ra) # cf6 <close>
  return r;
}
     bc0:	854a                	mv	a0,s2
     bc2:	60e2                	ld	ra,24(sp)
     bc4:	6442                	ld	s0,16(sp)
     bc6:	64a2                	ld	s1,8(sp)
     bc8:	6902                	ld	s2,0(sp)
     bca:	6105                	addi	sp,sp,32
     bcc:	8082                	ret
    return -1;
     bce:	597d                	li	s2,-1
     bd0:	bfc5                	j	bc0 <stat+0x34>

0000000000000bd2 <atoi>:

int
atoi(const char *s)
{
     bd2:	1141                	addi	sp,sp,-16
     bd4:	e422                	sd	s0,8(sp)
     bd6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     bd8:	00054603          	lbu	a2,0(a0)
     bdc:	fd06079b          	addiw	a5,a2,-48
     be0:	0ff7f793          	andi	a5,a5,255
     be4:	4725                	li	a4,9
     be6:	02f76963          	bltu	a4,a5,c18 <atoi+0x46>
     bea:	86aa                	mv	a3,a0
  n = 0;
     bec:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     bee:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     bf0:	0685                	addi	a3,a3,1
     bf2:	0025179b          	slliw	a5,a0,0x2
     bf6:	9fa9                	addw	a5,a5,a0
     bf8:	0017979b          	slliw	a5,a5,0x1
     bfc:	9fb1                	addw	a5,a5,a2
     bfe:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     c02:	0006c603          	lbu	a2,0(a3)
     c06:	fd06071b          	addiw	a4,a2,-48
     c0a:	0ff77713          	andi	a4,a4,255
     c0e:	fee5f1e3          	bgeu	a1,a4,bf0 <atoi+0x1e>
  return n;
}
     c12:	6422                	ld	s0,8(sp)
     c14:	0141                	addi	sp,sp,16
     c16:	8082                	ret
  n = 0;
     c18:	4501                	li	a0,0
     c1a:	bfe5                	j	c12 <atoi+0x40>

0000000000000c1c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     c1c:	1141                	addi	sp,sp,-16
     c1e:	e422                	sd	s0,8(sp)
     c20:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     c22:	02b57463          	bgeu	a0,a1,c4a <memmove+0x2e>
    while(n-- > 0)
     c26:	00c05f63          	blez	a2,c44 <memmove+0x28>
     c2a:	1602                	slli	a2,a2,0x20
     c2c:	9201                	srli	a2,a2,0x20
     c2e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     c32:	872a                	mv	a4,a0
      *dst++ = *src++;
     c34:	0585                	addi	a1,a1,1
     c36:	0705                	addi	a4,a4,1
     c38:	fff5c683          	lbu	a3,-1(a1)
     c3c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     c40:	fee79ae3          	bne	a5,a4,c34 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     c44:	6422                	ld	s0,8(sp)
     c46:	0141                	addi	sp,sp,16
     c48:	8082                	ret
    dst += n;
     c4a:	00c50733          	add	a4,a0,a2
    src += n;
     c4e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     c50:	fec05ae3          	blez	a2,c44 <memmove+0x28>
     c54:	fff6079b          	addiw	a5,a2,-1
     c58:	1782                	slli	a5,a5,0x20
     c5a:	9381                	srli	a5,a5,0x20
     c5c:	fff7c793          	not	a5,a5
     c60:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     c62:	15fd                	addi	a1,a1,-1
     c64:	177d                	addi	a4,a4,-1
     c66:	0005c683          	lbu	a3,0(a1)
     c6a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     c6e:	fee79ae3          	bne	a5,a4,c62 <memmove+0x46>
     c72:	bfc9                	j	c44 <memmove+0x28>

0000000000000c74 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     c74:	1141                	addi	sp,sp,-16
     c76:	e422                	sd	s0,8(sp)
     c78:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     c7a:	ca05                	beqz	a2,caa <memcmp+0x36>
     c7c:	fff6069b          	addiw	a3,a2,-1
     c80:	1682                	slli	a3,a3,0x20
     c82:	9281                	srli	a3,a3,0x20
     c84:	0685                	addi	a3,a3,1
     c86:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     c88:	00054783          	lbu	a5,0(a0)
     c8c:	0005c703          	lbu	a4,0(a1)
     c90:	00e79863          	bne	a5,a4,ca0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     c94:	0505                	addi	a0,a0,1
    p2++;
     c96:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     c98:	fed518e3          	bne	a0,a3,c88 <memcmp+0x14>
  }
  return 0;
     c9c:	4501                	li	a0,0
     c9e:	a019                	j	ca4 <memcmp+0x30>
      return *p1 - *p2;
     ca0:	40e7853b          	subw	a0,a5,a4
}
     ca4:	6422                	ld	s0,8(sp)
     ca6:	0141                	addi	sp,sp,16
     ca8:	8082                	ret
  return 0;
     caa:	4501                	li	a0,0
     cac:	bfe5                	j	ca4 <memcmp+0x30>

0000000000000cae <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     cae:	1141                	addi	sp,sp,-16
     cb0:	e406                	sd	ra,8(sp)
     cb2:	e022                	sd	s0,0(sp)
     cb4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     cb6:	00000097          	auipc	ra,0x0
     cba:	f66080e7          	jalr	-154(ra) # c1c <memmove>
}
     cbe:	60a2                	ld	ra,8(sp)
     cc0:	6402                	ld	s0,0(sp)
     cc2:	0141                	addi	sp,sp,16
     cc4:	8082                	ret

0000000000000cc6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     cc6:	4885                	li	a7,1
 ecall
     cc8:	00000073          	ecall
 ret
     ccc:	8082                	ret

0000000000000cce <exit>:
.global exit
exit:
 li a7, SYS_exit
     cce:	4889                	li	a7,2
 ecall
     cd0:	00000073          	ecall
 ret
     cd4:	8082                	ret

0000000000000cd6 <wait>:
.global wait
wait:
 li a7, SYS_wait
     cd6:	488d                	li	a7,3
 ecall
     cd8:	00000073          	ecall
 ret
     cdc:	8082                	ret

0000000000000cde <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     cde:	4891                	li	a7,4
 ecall
     ce0:	00000073          	ecall
 ret
     ce4:	8082                	ret

0000000000000ce6 <read>:
.global read
read:
 li a7, SYS_read
     ce6:	4895                	li	a7,5
 ecall
     ce8:	00000073          	ecall
 ret
     cec:	8082                	ret

0000000000000cee <write>:
.global write
write:
 li a7, SYS_write
     cee:	48c1                	li	a7,16
 ecall
     cf0:	00000073          	ecall
 ret
     cf4:	8082                	ret

0000000000000cf6 <close>:
.global close
close:
 li a7, SYS_close
     cf6:	48d5                	li	a7,21
 ecall
     cf8:	00000073          	ecall
 ret
     cfc:	8082                	ret

0000000000000cfe <kill>:
.global kill
kill:
 li a7, SYS_kill
     cfe:	4899                	li	a7,6
 ecall
     d00:	00000073          	ecall
 ret
     d04:	8082                	ret

0000000000000d06 <exec>:
.global exec
exec:
 li a7, SYS_exec
     d06:	489d                	li	a7,7
 ecall
     d08:	00000073          	ecall
 ret
     d0c:	8082                	ret

0000000000000d0e <open>:
.global open
open:
 li a7, SYS_open
     d0e:	48bd                	li	a7,15
 ecall
     d10:	00000073          	ecall
 ret
     d14:	8082                	ret

0000000000000d16 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     d16:	48c5                	li	a7,17
 ecall
     d18:	00000073          	ecall
 ret
     d1c:	8082                	ret

0000000000000d1e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     d1e:	48c9                	li	a7,18
 ecall
     d20:	00000073          	ecall
 ret
     d24:	8082                	ret

0000000000000d26 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     d26:	48a1                	li	a7,8
 ecall
     d28:	00000073          	ecall
 ret
     d2c:	8082                	ret

0000000000000d2e <link>:
.global link
link:
 li a7, SYS_link
     d2e:	48cd                	li	a7,19
 ecall
     d30:	00000073          	ecall
 ret
     d34:	8082                	ret

0000000000000d36 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     d36:	48d1                	li	a7,20
 ecall
     d38:	00000073          	ecall
 ret
     d3c:	8082                	ret

0000000000000d3e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     d3e:	48a5                	li	a7,9
 ecall
     d40:	00000073          	ecall
 ret
     d44:	8082                	ret

0000000000000d46 <dup>:
.global dup
dup:
 li a7, SYS_dup
     d46:	48a9                	li	a7,10
 ecall
     d48:	00000073          	ecall
 ret
     d4c:	8082                	ret

0000000000000d4e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     d4e:	48ad                	li	a7,11
 ecall
     d50:	00000073          	ecall
 ret
     d54:	8082                	ret

0000000000000d56 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     d56:	48b1                	li	a7,12
 ecall
     d58:	00000073          	ecall
 ret
     d5c:	8082                	ret

0000000000000d5e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     d5e:	48b5                	li	a7,13
 ecall
     d60:	00000073          	ecall
 ret
     d64:	8082                	ret

0000000000000d66 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     d66:	48b9                	li	a7,14
 ecall
     d68:	00000073          	ecall
 ret
     d6c:	8082                	ret

0000000000000d6e <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
     d6e:	48d9                	li	a7,22
 ecall
     d70:	00000073          	ecall
 ret
     d74:	8082                	ret

0000000000000d76 <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
     d76:	48dd                	li	a7,23
 ecall
     d78:	00000073          	ecall
 ret
     d7c:	8082                	ret

0000000000000d7e <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
     d7e:	48e1                	li	a7,24
 ecall
     d80:	00000073          	ecall
 ret
     d84:	8082                	ret

0000000000000d86 <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
     d86:	48e5                	li	a7,25
 ecall
     d88:	00000073          	ecall
 ret
     d8c:	8082                	ret

0000000000000d8e <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
     d8e:	48e9                	li	a7,26
 ecall
     d90:	00000073          	ecall
 ret
     d94:	8082                	ret

0000000000000d96 <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
     d96:	48ed                	li	a7,27
 ecall
     d98:	00000073          	ecall
 ret
     d9c:	8082                	ret

0000000000000d9e <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
     d9e:	48f1                	li	a7,28
 ecall
     da0:	00000073          	ecall
 ret
     da4:	8082                	ret

0000000000000da6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     da6:	1101                	addi	sp,sp,-32
     da8:	ec06                	sd	ra,24(sp)
     daa:	e822                	sd	s0,16(sp)
     dac:	1000                	addi	s0,sp,32
     dae:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     db2:	4605                	li	a2,1
     db4:	fef40593          	addi	a1,s0,-17
     db8:	00000097          	auipc	ra,0x0
     dbc:	f36080e7          	jalr	-202(ra) # cee <write>
}
     dc0:	60e2                	ld	ra,24(sp)
     dc2:	6442                	ld	s0,16(sp)
     dc4:	6105                	addi	sp,sp,32
     dc6:	8082                	ret

0000000000000dc8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     dc8:	7139                	addi	sp,sp,-64
     dca:	fc06                	sd	ra,56(sp)
     dcc:	f822                	sd	s0,48(sp)
     dce:	f426                	sd	s1,40(sp)
     dd0:	f04a                	sd	s2,32(sp)
     dd2:	ec4e                	sd	s3,24(sp)
     dd4:	0080                	addi	s0,sp,64
     dd6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     dd8:	c299                	beqz	a3,dde <printint+0x16>
     dda:	0805c863          	bltz	a1,e6a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     dde:	2581                	sext.w	a1,a1
  neg = 0;
     de0:	4881                	li	a7,0
     de2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     de6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     de8:	2601                	sext.w	a2,a2
     dea:	00001517          	auipc	a0,0x1
     dee:	a0e50513          	addi	a0,a0,-1522 # 17f8 <digits>
     df2:	883a                	mv	a6,a4
     df4:	2705                	addiw	a4,a4,1
     df6:	02c5f7bb          	remuw	a5,a1,a2
     dfa:	1782                	slli	a5,a5,0x20
     dfc:	9381                	srli	a5,a5,0x20
     dfe:	97aa                	add	a5,a5,a0
     e00:	0007c783          	lbu	a5,0(a5)
     e04:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     e08:	0005879b          	sext.w	a5,a1
     e0c:	02c5d5bb          	divuw	a1,a1,a2
     e10:	0685                	addi	a3,a3,1
     e12:	fec7f0e3          	bgeu	a5,a2,df2 <printint+0x2a>
  if(neg)
     e16:	00088b63          	beqz	a7,e2c <printint+0x64>
    buf[i++] = '-';
     e1a:	fd040793          	addi	a5,s0,-48
     e1e:	973e                	add	a4,a4,a5
     e20:	02d00793          	li	a5,45
     e24:	fef70823          	sb	a5,-16(a4)
     e28:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     e2c:	02e05863          	blez	a4,e5c <printint+0x94>
     e30:	fc040793          	addi	a5,s0,-64
     e34:	00e78933          	add	s2,a5,a4
     e38:	fff78993          	addi	s3,a5,-1
     e3c:	99ba                	add	s3,s3,a4
     e3e:	377d                	addiw	a4,a4,-1
     e40:	1702                	slli	a4,a4,0x20
     e42:	9301                	srli	a4,a4,0x20
     e44:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     e48:	fff94583          	lbu	a1,-1(s2)
     e4c:	8526                	mv	a0,s1
     e4e:	00000097          	auipc	ra,0x0
     e52:	f58080e7          	jalr	-168(ra) # da6 <putc>
  while(--i >= 0)
     e56:	197d                	addi	s2,s2,-1
     e58:	ff3918e3          	bne	s2,s3,e48 <printint+0x80>
}
     e5c:	70e2                	ld	ra,56(sp)
     e5e:	7442                	ld	s0,48(sp)
     e60:	74a2                	ld	s1,40(sp)
     e62:	7902                	ld	s2,32(sp)
     e64:	69e2                	ld	s3,24(sp)
     e66:	6121                	addi	sp,sp,64
     e68:	8082                	ret
    x = -xx;
     e6a:	40b005bb          	negw	a1,a1
    neg = 1;
     e6e:	4885                	li	a7,1
    x = -xx;
     e70:	bf8d                	j	de2 <printint+0x1a>

0000000000000e72 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     e72:	7119                	addi	sp,sp,-128
     e74:	fc86                	sd	ra,120(sp)
     e76:	f8a2                	sd	s0,112(sp)
     e78:	f4a6                	sd	s1,104(sp)
     e7a:	f0ca                	sd	s2,96(sp)
     e7c:	ecce                	sd	s3,88(sp)
     e7e:	e8d2                	sd	s4,80(sp)
     e80:	e4d6                	sd	s5,72(sp)
     e82:	e0da                	sd	s6,64(sp)
     e84:	fc5e                	sd	s7,56(sp)
     e86:	f862                	sd	s8,48(sp)
     e88:	f466                	sd	s9,40(sp)
     e8a:	f06a                	sd	s10,32(sp)
     e8c:	ec6e                	sd	s11,24(sp)
     e8e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     e90:	0005c903          	lbu	s2,0(a1)
     e94:	18090f63          	beqz	s2,1032 <vprintf+0x1c0>
     e98:	8aaa                	mv	s5,a0
     e9a:	8b32                	mv	s6,a2
     e9c:	00158493          	addi	s1,a1,1
  state = 0;
     ea0:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     ea2:	02500a13          	li	s4,37
      if(c == 'd'){
     ea6:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
     eaa:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
     eae:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
     eb2:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     eb6:	00001b97          	auipc	s7,0x1
     eba:	942b8b93          	addi	s7,s7,-1726 # 17f8 <digits>
     ebe:	a839                	j	edc <vprintf+0x6a>
        putc(fd, c);
     ec0:	85ca                	mv	a1,s2
     ec2:	8556                	mv	a0,s5
     ec4:	00000097          	auipc	ra,0x0
     ec8:	ee2080e7          	jalr	-286(ra) # da6 <putc>
     ecc:	a019                	j	ed2 <vprintf+0x60>
    } else if(state == '%'){
     ece:	01498f63          	beq	s3,s4,eec <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
     ed2:	0485                	addi	s1,s1,1
     ed4:	fff4c903          	lbu	s2,-1(s1)
     ed8:	14090d63          	beqz	s2,1032 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
     edc:	0009079b          	sext.w	a5,s2
    if(state == 0){
     ee0:	fe0997e3          	bnez	s3,ece <vprintf+0x5c>
      if(c == '%'){
     ee4:	fd479ee3          	bne	a5,s4,ec0 <vprintf+0x4e>
        state = '%';
     ee8:	89be                	mv	s3,a5
     eea:	b7e5                	j	ed2 <vprintf+0x60>
      if(c == 'd'){
     eec:	05878063          	beq	a5,s8,f2c <vprintf+0xba>
      } else if(c == 'l') {
     ef0:	05978c63          	beq	a5,s9,f48 <vprintf+0xd6>
      } else if(c == 'x') {
     ef4:	07a78863          	beq	a5,s10,f64 <vprintf+0xf2>
      } else if(c == 'p') {
     ef8:	09b78463          	beq	a5,s11,f80 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
     efc:	07300713          	li	a4,115
     f00:	0ce78663          	beq	a5,a4,fcc <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
     f04:	06300713          	li	a4,99
     f08:	0ee78e63          	beq	a5,a4,1004 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
     f0c:	11478863          	beq	a5,s4,101c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
     f10:	85d2                	mv	a1,s4
     f12:	8556                	mv	a0,s5
     f14:	00000097          	auipc	ra,0x0
     f18:	e92080e7          	jalr	-366(ra) # da6 <putc>
        putc(fd, c);
     f1c:	85ca                	mv	a1,s2
     f1e:	8556                	mv	a0,s5
     f20:	00000097          	auipc	ra,0x0
     f24:	e86080e7          	jalr	-378(ra) # da6 <putc>
      }
      state = 0;
     f28:	4981                	li	s3,0
     f2a:	b765                	j	ed2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
     f2c:	008b0913          	addi	s2,s6,8
     f30:	4685                	li	a3,1
     f32:	4629                	li	a2,10
     f34:	000b2583          	lw	a1,0(s6)
     f38:	8556                	mv	a0,s5
     f3a:	00000097          	auipc	ra,0x0
     f3e:	e8e080e7          	jalr	-370(ra) # dc8 <printint>
     f42:	8b4a                	mv	s6,s2
      state = 0;
     f44:	4981                	li	s3,0
     f46:	b771                	j	ed2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
     f48:	008b0913          	addi	s2,s6,8
     f4c:	4681                	li	a3,0
     f4e:	4629                	li	a2,10
     f50:	000b2583          	lw	a1,0(s6)
     f54:	8556                	mv	a0,s5
     f56:	00000097          	auipc	ra,0x0
     f5a:	e72080e7          	jalr	-398(ra) # dc8 <printint>
     f5e:	8b4a                	mv	s6,s2
      state = 0;
     f60:	4981                	li	s3,0
     f62:	bf85                	j	ed2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
     f64:	008b0913          	addi	s2,s6,8
     f68:	4681                	li	a3,0
     f6a:	4641                	li	a2,16
     f6c:	000b2583          	lw	a1,0(s6)
     f70:	8556                	mv	a0,s5
     f72:	00000097          	auipc	ra,0x0
     f76:	e56080e7          	jalr	-426(ra) # dc8 <printint>
     f7a:	8b4a                	mv	s6,s2
      state = 0;
     f7c:	4981                	li	s3,0
     f7e:	bf91                	j	ed2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
     f80:	008b0793          	addi	a5,s6,8
     f84:	f8f43423          	sd	a5,-120(s0)
     f88:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
     f8c:	03000593          	li	a1,48
     f90:	8556                	mv	a0,s5
     f92:	00000097          	auipc	ra,0x0
     f96:	e14080e7          	jalr	-492(ra) # da6 <putc>
  putc(fd, 'x');
     f9a:	85ea                	mv	a1,s10
     f9c:	8556                	mv	a0,s5
     f9e:	00000097          	auipc	ra,0x0
     fa2:	e08080e7          	jalr	-504(ra) # da6 <putc>
     fa6:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     fa8:	03c9d793          	srli	a5,s3,0x3c
     fac:	97de                	add	a5,a5,s7
     fae:	0007c583          	lbu	a1,0(a5)
     fb2:	8556                	mv	a0,s5
     fb4:	00000097          	auipc	ra,0x0
     fb8:	df2080e7          	jalr	-526(ra) # da6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     fbc:	0992                	slli	s3,s3,0x4
     fbe:	397d                	addiw	s2,s2,-1
     fc0:	fe0914e3          	bnez	s2,fa8 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
     fc4:	f8843b03          	ld	s6,-120(s0)
      state = 0;
     fc8:	4981                	li	s3,0
     fca:	b721                	j	ed2 <vprintf+0x60>
        s = va_arg(ap, char*);
     fcc:	008b0993          	addi	s3,s6,8
     fd0:	000b3903          	ld	s2,0(s6)
        if(s == 0)
     fd4:	02090163          	beqz	s2,ff6 <vprintf+0x184>
        while(*s != 0){
     fd8:	00094583          	lbu	a1,0(s2)
     fdc:	c9a1                	beqz	a1,102c <vprintf+0x1ba>
          putc(fd, *s);
     fde:	8556                	mv	a0,s5
     fe0:	00000097          	auipc	ra,0x0
     fe4:	dc6080e7          	jalr	-570(ra) # da6 <putc>
          s++;
     fe8:	0905                	addi	s2,s2,1
        while(*s != 0){
     fea:	00094583          	lbu	a1,0(s2)
     fee:	f9e5                	bnez	a1,fde <vprintf+0x16c>
        s = va_arg(ap, char*);
     ff0:	8b4e                	mv	s6,s3
      state = 0;
     ff2:	4981                	li	s3,0
     ff4:	bdf9                	j	ed2 <vprintf+0x60>
          s = "(null)";
     ff6:	00000917          	auipc	s2,0x0
     ffa:	7fa90913          	addi	s2,s2,2042 # 17f0 <malloc+0x6b4>
        while(*s != 0){
     ffe:	02800593          	li	a1,40
    1002:	bff1                	j	fde <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    1004:	008b0913          	addi	s2,s6,8
    1008:	000b4583          	lbu	a1,0(s6)
    100c:	8556                	mv	a0,s5
    100e:	00000097          	auipc	ra,0x0
    1012:	d98080e7          	jalr	-616(ra) # da6 <putc>
    1016:	8b4a                	mv	s6,s2
      state = 0;
    1018:	4981                	li	s3,0
    101a:	bd65                	j	ed2 <vprintf+0x60>
        putc(fd, c);
    101c:	85d2                	mv	a1,s4
    101e:	8556                	mv	a0,s5
    1020:	00000097          	auipc	ra,0x0
    1024:	d86080e7          	jalr	-634(ra) # da6 <putc>
      state = 0;
    1028:	4981                	li	s3,0
    102a:	b565                	j	ed2 <vprintf+0x60>
        s = va_arg(ap, char*);
    102c:	8b4e                	mv	s6,s3
      state = 0;
    102e:	4981                	li	s3,0
    1030:	b54d                	j	ed2 <vprintf+0x60>
    }
  }
}
    1032:	70e6                	ld	ra,120(sp)
    1034:	7446                	ld	s0,112(sp)
    1036:	74a6                	ld	s1,104(sp)
    1038:	7906                	ld	s2,96(sp)
    103a:	69e6                	ld	s3,88(sp)
    103c:	6a46                	ld	s4,80(sp)
    103e:	6aa6                	ld	s5,72(sp)
    1040:	6b06                	ld	s6,64(sp)
    1042:	7be2                	ld	s7,56(sp)
    1044:	7c42                	ld	s8,48(sp)
    1046:	7ca2                	ld	s9,40(sp)
    1048:	7d02                	ld	s10,32(sp)
    104a:	6de2                	ld	s11,24(sp)
    104c:	6109                	addi	sp,sp,128
    104e:	8082                	ret

0000000000001050 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1050:	715d                	addi	sp,sp,-80
    1052:	ec06                	sd	ra,24(sp)
    1054:	e822                	sd	s0,16(sp)
    1056:	1000                	addi	s0,sp,32
    1058:	e010                	sd	a2,0(s0)
    105a:	e414                	sd	a3,8(s0)
    105c:	e818                	sd	a4,16(s0)
    105e:	ec1c                	sd	a5,24(s0)
    1060:	03043023          	sd	a6,32(s0)
    1064:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1068:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    106c:	8622                	mv	a2,s0
    106e:	00000097          	auipc	ra,0x0
    1072:	e04080e7          	jalr	-508(ra) # e72 <vprintf>
}
    1076:	60e2                	ld	ra,24(sp)
    1078:	6442                	ld	s0,16(sp)
    107a:	6161                	addi	sp,sp,80
    107c:	8082                	ret

000000000000107e <printf>:

void
printf(const char *fmt, ...)
{
    107e:	711d                	addi	sp,sp,-96
    1080:	ec06                	sd	ra,24(sp)
    1082:	e822                	sd	s0,16(sp)
    1084:	1000                	addi	s0,sp,32
    1086:	e40c                	sd	a1,8(s0)
    1088:	e810                	sd	a2,16(s0)
    108a:	ec14                	sd	a3,24(s0)
    108c:	f018                	sd	a4,32(s0)
    108e:	f41c                	sd	a5,40(s0)
    1090:	03043823          	sd	a6,48(s0)
    1094:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1098:	00840613          	addi	a2,s0,8
    109c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    10a0:	85aa                	mv	a1,a0
    10a2:	4505                	li	a0,1
    10a4:	00000097          	auipc	ra,0x0
    10a8:	dce080e7          	jalr	-562(ra) # e72 <vprintf>
}
    10ac:	60e2                	ld	ra,24(sp)
    10ae:	6442                	ld	s0,16(sp)
    10b0:	6125                	addi	sp,sp,96
    10b2:	8082                	ret

00000000000010b4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    10b4:	1141                	addi	sp,sp,-16
    10b6:	e422                	sd	s0,8(sp)
    10b8:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    10ba:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    10be:	00000797          	auipc	a5,0x0
    10c2:	7527b783          	ld	a5,1874(a5) # 1810 <freep>
    10c6:	a805                	j	10f6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    10c8:	4618                	lw	a4,8(a2)
    10ca:	9db9                	addw	a1,a1,a4
    10cc:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    10d0:	6398                	ld	a4,0(a5)
    10d2:	6318                	ld	a4,0(a4)
    10d4:	fee53823          	sd	a4,-16(a0)
    10d8:	a091                	j	111c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    10da:	ff852703          	lw	a4,-8(a0)
    10de:	9e39                	addw	a2,a2,a4
    10e0:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    10e2:	ff053703          	ld	a4,-16(a0)
    10e6:	e398                	sd	a4,0(a5)
    10e8:	a099                	j	112e <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    10ea:	6398                	ld	a4,0(a5)
    10ec:	00e7e463          	bltu	a5,a4,10f4 <free+0x40>
    10f0:	00e6ea63          	bltu	a3,a4,1104 <free+0x50>
{
    10f4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    10f6:	fed7fae3          	bgeu	a5,a3,10ea <free+0x36>
    10fa:	6398                	ld	a4,0(a5)
    10fc:	00e6e463          	bltu	a3,a4,1104 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1100:	fee7eae3          	bltu	a5,a4,10f4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    1104:	ff852583          	lw	a1,-8(a0)
    1108:	6390                	ld	a2,0(a5)
    110a:	02059813          	slli	a6,a1,0x20
    110e:	01c85713          	srli	a4,a6,0x1c
    1112:	9736                	add	a4,a4,a3
    1114:	fae60ae3          	beq	a2,a4,10c8 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1118:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    111c:	4790                	lw	a2,8(a5)
    111e:	02061593          	slli	a1,a2,0x20
    1122:	01c5d713          	srli	a4,a1,0x1c
    1126:	973e                	add	a4,a4,a5
    1128:	fae689e3          	beq	a3,a4,10da <free+0x26>
  } else
    p->s.ptr = bp;
    112c:	e394                	sd	a3,0(a5)
  freep = p;
    112e:	00000717          	auipc	a4,0x0
    1132:	6ef73123          	sd	a5,1762(a4) # 1810 <freep>
}
    1136:	6422                	ld	s0,8(sp)
    1138:	0141                	addi	sp,sp,16
    113a:	8082                	ret

000000000000113c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    113c:	7139                	addi	sp,sp,-64
    113e:	fc06                	sd	ra,56(sp)
    1140:	f822                	sd	s0,48(sp)
    1142:	f426                	sd	s1,40(sp)
    1144:	f04a                	sd	s2,32(sp)
    1146:	ec4e                	sd	s3,24(sp)
    1148:	e852                	sd	s4,16(sp)
    114a:	e456                	sd	s5,8(sp)
    114c:	e05a                	sd	s6,0(sp)
    114e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1150:	02051493          	slli	s1,a0,0x20
    1154:	9081                	srli	s1,s1,0x20
    1156:	04bd                	addi	s1,s1,15
    1158:	8091                	srli	s1,s1,0x4
    115a:	0014899b          	addiw	s3,s1,1
    115e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1160:	00000517          	auipc	a0,0x0
    1164:	6b053503          	ld	a0,1712(a0) # 1810 <freep>
    1168:	c515                	beqz	a0,1194 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    116a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    116c:	4798                	lw	a4,8(a5)
    116e:	02977f63          	bgeu	a4,s1,11ac <malloc+0x70>
    1172:	8a4e                	mv	s4,s3
    1174:	0009871b          	sext.w	a4,s3
    1178:	6685                	lui	a3,0x1
    117a:	00d77363          	bgeu	a4,a3,1180 <malloc+0x44>
    117e:	6a05                	lui	s4,0x1
    1180:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1184:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1188:	00000917          	auipc	s2,0x0
    118c:	68890913          	addi	s2,s2,1672 # 1810 <freep>
  if(p == (char*)-1)
    1190:	5afd                	li	s5,-1
    1192:	a895                	j	1206 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    1194:	00000797          	auipc	a5,0x0
    1198:	68478793          	addi	a5,a5,1668 # 1818 <base>
    119c:	00000717          	auipc	a4,0x0
    11a0:	66f73a23          	sd	a5,1652(a4) # 1810 <freep>
    11a4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    11a6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    11aa:	b7e1                	j	1172 <malloc+0x36>
      if(p->s.size == nunits)
    11ac:	02e48c63          	beq	s1,a4,11e4 <malloc+0xa8>
        p->s.size -= nunits;
    11b0:	4137073b          	subw	a4,a4,s3
    11b4:	c798                	sw	a4,8(a5)
        p += p->s.size;
    11b6:	02071693          	slli	a3,a4,0x20
    11ba:	01c6d713          	srli	a4,a3,0x1c
    11be:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    11c0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    11c4:	00000717          	auipc	a4,0x0
    11c8:	64a73623          	sd	a0,1612(a4) # 1810 <freep>
      return (void*)(p + 1);
    11cc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    11d0:	70e2                	ld	ra,56(sp)
    11d2:	7442                	ld	s0,48(sp)
    11d4:	74a2                	ld	s1,40(sp)
    11d6:	7902                	ld	s2,32(sp)
    11d8:	69e2                	ld	s3,24(sp)
    11da:	6a42                	ld	s4,16(sp)
    11dc:	6aa2                	ld	s5,8(sp)
    11de:	6b02                	ld	s6,0(sp)
    11e0:	6121                	addi	sp,sp,64
    11e2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    11e4:	6398                	ld	a4,0(a5)
    11e6:	e118                	sd	a4,0(a0)
    11e8:	bff1                	j	11c4 <malloc+0x88>
  hp->s.size = nu;
    11ea:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    11ee:	0541                	addi	a0,a0,16
    11f0:	00000097          	auipc	ra,0x0
    11f4:	ec4080e7          	jalr	-316(ra) # 10b4 <free>
  return freep;
    11f8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    11fc:	d971                	beqz	a0,11d0 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    11fe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1200:	4798                	lw	a4,8(a5)
    1202:	fa9775e3          	bgeu	a4,s1,11ac <malloc+0x70>
    if(p == freep)
    1206:	00093703          	ld	a4,0(s2)
    120a:	853e                	mv	a0,a5
    120c:	fef719e3          	bne	a4,a5,11fe <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    1210:	8552                	mv	a0,s4
    1212:	00000097          	auipc	ra,0x0
    1216:	b44080e7          	jalr	-1212(ra) # d56 <sbrk>
  if(p == (char*)-1)
    121a:	fd5518e3          	bne	a0,s5,11ea <malloc+0xae>
        return 0;
    121e:	4501                	li	a0,0
    1220:	bf45                	j	11d0 <malloc+0x94>
