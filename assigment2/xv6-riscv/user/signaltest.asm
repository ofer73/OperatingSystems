
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
       e:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa70414b>
      12:	fcf42c23          	sw	a5,-40(s0)
      16:	fc040e23          	sb	zero,-36(s0)
      1a:	1f400493          	li	s1,500
    for(int i=0;i<500;i++){
        write(1, st, 5);
      1e:	4615                	li	a2,5
      20:	fd840593          	addi	a1,s0,-40
      24:	4505                	li	a0,1
      26:	00001097          	auipc	ra,0x1
      2a:	afc080e7          	jalr	-1284(ra) # b22 <write>
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
      4a:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa70414b>
      4e:	fcf42c23          	sw	a5,-40(s0)
      52:	fc040e23          	sb	zero,-36(s0)
      56:	1f400493          	li	s1,500
    for(int i=0;i<500;i++){
        write(1, st, 5);
      5a:	4615                	li	a2,5
      5c:	fd840593          	addi	a1,s0,-40
      60:	4505                	li	a0,1
      62:	00001097          	auipc	ra,0x1
      66:	ac0080e7          	jalr	-1344(ra) # b22 <write>
    for(int i=0;i<500;i++){
      6a:	34fd                	addiw	s1,s1,-1
      6c:	f4fd                	bnez	s1,5a <sig_handler_loop2+0x1e>
    }
    
    return;
}
      6e:	70a2                	ld	ra,40(sp)
      70:	7402                	ld	s0,32(sp)
      72:	64e2                	ld	s1,24(sp)
      74:	6145                	addi	sp,sp,48
      76:	8082                	ret

0000000000000078 <sig_handler2>:
void
sig_handler2(int signum){
      78:	1101                	addi	sp,sp,-32
      7a:	ec06                	sd	ra,24(sp)
      7c:	e822                	sd	s0,16(sp)
      7e:	1000                	addi	s0,sp,32
    char st[5] = "dap\n";
      80:	0a7067b7          	lui	a5,0xa706
      84:	16478793          	addi	a5,a5,356 # a706164 <__global_pointer$+0xa70414b>
      88:	fef42423          	sw	a5,-24(s0)
      8c:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
      90:	4615                	li	a2,5
      92:	fe840593          	addi	a1,s0,-24
      96:	4505                	li	a0,1
      98:	00001097          	auipc	ra,0x1
      9c:	a8a080e7          	jalr	-1398(ra) # b22 <write>
    return;
}
      a0:	60e2                	ld	ra,24(sp)
      a2:	6442                	ld	s0,16(sp)
      a4:	6105                	addi	sp,sp,32
      a6:	8082                	ret

00000000000000a8 <test_thread>:
void test_thread(){
      a8:	1141                	addi	sp,sp,-16
      aa:	e406                	sd	ra,8(sp)
      ac:	e022                	sd	s0,0(sp)
      ae:	0800                	addi	s0,sp,16
    sleep(5);
      b0:	4515                	li	a0,5
      b2:	00001097          	auipc	ra,0x1
      b6:	ae0080e7          	jalr	-1312(ra) # b92 <sleep>
    printf("Thread is now running tid=%d\n",kthread_id());
      ba:	00001097          	auipc	ra,0x1
      be:	b08080e7          	jalr	-1272(ra) # bc2 <kthread_id>
      c2:	85aa                	mv	a1,a0
      c4:	00001517          	auipc	a0,0x1
      c8:	14450513          	addi	a0,a0,324 # 1208 <csem_free+0x68>
      cc:	00001097          	auipc	ra,0x1
      d0:	e08080e7          	jalr	-504(ra) # ed4 <printf>
    kthread_exit(9);
      d4:	4525                	li	a0,9
      d6:	00001097          	auipc	ra,0x1
      da:	af4080e7          	jalr	-1292(ra) # bca <kthread_exit>
}
      de:	60a2                	ld	ra,8(sp)
      e0:	6402                	ld	s0,0(sp)
      e2:	0141                	addi	sp,sp,16
      e4:	8082                	ret

00000000000000e6 <test_thread_loop>:
void test_thread_loop(){
      e6:	7179                	addi	sp,sp,-48
      e8:	f406                	sd	ra,40(sp)
      ea:	f022                	sd	s0,32(sp)
      ec:	ec26                	sd	s1,24(sp)
      ee:	e84a                	sd	s2,16(sp)
      f0:	e44e                	sd	s3,8(sp)
      f2:	1800                	addi	s0,sp,48
    sleep(5);
      f4:	4515                	li	a0,5
      f6:	00001097          	auipc	ra,0x1
      fa:	a9c080e7          	jalr	-1380(ra) # b92 <sleep>
    for(int i=0;i<100;i++){
      fe:	4481                	li	s1,0
        printf("%d:Thread is now running tid=%d\n",i,kthread_id());
     100:	00001997          	auipc	s3,0x1
     104:	12898993          	addi	s3,s3,296 # 1228 <csem_free+0x88>
    for(int i=0;i<100;i++){
     108:	06400913          	li	s2,100
        printf("%d:Thread is now running tid=%d\n",i,kthread_id());
     10c:	00001097          	auipc	ra,0x1
     110:	ab6080e7          	jalr	-1354(ra) # bc2 <kthread_id>
     114:	862a                	mv	a2,a0
     116:	85a6                	mv	a1,s1
     118:	854e                	mv	a0,s3
     11a:	00001097          	auipc	ra,0x1
     11e:	dba080e7          	jalr	-582(ra) # ed4 <printf>
    for(int i=0;i<100;i++){
     122:	2485                	addiw	s1,s1,1
     124:	ff2494e3          	bne	s1,s2,10c <test_thread_loop+0x26>
    kthread_exit(9);
     128:	4525                	li	a0,9
     12a:	00001097          	auipc	ra,0x1
     12e:	aa0080e7          	jalr	-1376(ra) # bca <kthread_exit>
}
     132:	70a2                	ld	ra,40(sp)
     134:	7402                	ld	s0,32(sp)
     136:	64e2                	ld	s1,24(sp)
     138:	6942                	ld	s2,16(sp)
     13a:	69a2                	ld	s3,8(sp)
     13c:	6145                	addi	sp,sp,48
     13e:	8082                	ret

0000000000000140 <test_thread2>:
void test_thread2(){
     140:	1141                	addi	sp,sp,-16
     142:	e406                	sd	ra,8(sp)
     144:	e022                	sd	s0,0(sp)
     146:	0800                	addi	s0,sp,16
    sleep(5);
     148:	4515                	li	a0,5
     14a:	00001097          	auipc	ra,0x1
     14e:	a48080e7          	jalr	-1464(ra) # b92 <sleep>
    printf("Thread is now running tid=%d\n",kthread_id());
     152:	00001097          	auipc	ra,0x1
     156:	a70080e7          	jalr	-1424(ra) # bc2 <kthread_id>
     15a:	85aa                	mv	a1,a0
     15c:	00001517          	auipc	a0,0x1
     160:	0ac50513          	addi	a0,a0,172 # 1208 <csem_free+0x68>
     164:	00001097          	auipc	ra,0x1
     168:	d70080e7          	jalr	-656(ra) # ed4 <printf>
    kthread_exit(9);
     16c:	4525                	li	a0,9
     16e:	00001097          	auipc	ra,0x1
     172:	a5c080e7          	jalr	-1444(ra) # bca <kthread_exit>
}
     176:	60a2                	ld	ra,8(sp)
     178:	6402                	ld	s0,0(sp)
     17a:	0141                	addi	sp,sp,16
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
     190:	96e080e7          	jalr	-1682(ra) # afa <fork>
     194:	84aa                	mv	s1,a0
    if(pid==0){
     196:	ed05                	bnez	a0,1ce <test_sigkill+0x50>
        sleep(5);
     198:	4515                	li	a0,5
     19a:	00001097          	auipc	ra,0x1
     19e:	9f8080e7          	jalr	-1544(ra) # b92 <sleep>
            printf("about to get killed %d\n",i);
     1a2:	00001997          	auipc	s3,0x1
     1a6:	0ae98993          	addi	s3,s3,174 # 1250 <csem_free+0xb0>
        for(int i=0;i<300;i++)
     1aa:	12c00913          	li	s2,300
            printf("about to get killed %d\n",i);
     1ae:	85a6                	mv	a1,s1
     1b0:	854e                	mv	a0,s3
     1b2:	00001097          	auipc	ra,0x1
     1b6:	d22080e7          	jalr	-734(ra) # ed4 <printf>
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
     1d4:	9c2080e7          	jalr	-1598(ra) # b92 <sleep>
        printf("parent send signal to to kill child\n");
     1d8:	00001517          	auipc	a0,0x1
     1dc:	09050513          	addi	a0,a0,144 # 1268 <csem_free+0xc8>
     1e0:	00001097          	auipc	ra,0x1
     1e4:	cf4080e7          	jalr	-780(ra) # ed4 <printf>
        printf("kill ret= %d\n",kill(pid, SIGKILL));
     1e8:	45a5                	li	a1,9
     1ea:	8526                	mv	a0,s1
     1ec:	00001097          	auipc	ra,0x1
     1f0:	946080e7          	jalr	-1722(ra) # b32 <kill>
     1f4:	85aa                	mv	a1,a0
     1f6:	00001517          	auipc	a0,0x1
     1fa:	09a50513          	addi	a0,a0,154 # 1290 <csem_free+0xf0>
     1fe:	00001097          	auipc	ra,0x1
     202:	cd6080e7          	jalr	-810(ra) # ed4 <printf>
        printf("parent wait for child\n");
     206:	00001517          	auipc	a0,0x1
     20a:	09a50513          	addi	a0,a0,154 # 12a0 <csem_free+0x100>
     20e:	00001097          	auipc	ra,0x1
     212:	cc6080e7          	jalr	-826(ra) # ed4 <printf>
        wait(0);
     216:	4501                	li	a0,0
     218:	00001097          	auipc	ra,0x1
     21c:	8f2080e7          	jalr	-1806(ra) # b0a <wait>
        printf("parent: child is dead\n");
     220:	00001517          	auipc	a0,0x1
     224:	09850513          	addi	a0,a0,152 # 12b8 <csem_free+0x118>
     228:	00001097          	auipc	ra,0x1
     22c:	cac080e7          	jalr	-852(ra) # ed4 <printf>
        sleep(10);
     230:	4529                	li	a0,10
     232:	00001097          	auipc	ra,0x1
     236:	960080e7          	jalr	-1696(ra) # b92 <sleep>
        exit(0);
     23a:	4501                	li	a0,0
     23c:	00001097          	auipc	ra,0x1
     240:	8c6080e7          	jalr	-1850(ra) # b02 <exit>

0000000000000244 <sig_handler>:
sig_handler(int signum){
     244:	1101                	addi	sp,sp,-32
     246:	ec06                	sd	ra,24(sp)
     248:	e822                	sd	s0,16(sp)
     24a:	1000                	addi	s0,sp,32
    char st[5] = "wap\n";
     24c:	0a7067b7          	lui	a5,0xa706
     250:	17778793          	addi	a5,a5,375 # a706177 <__global_pointer$+0xa70415e>
     254:	fef42423          	sw	a5,-24(s0)
     258:	fe040623          	sb	zero,-20(s0)
    write(1, st, 5);
     25c:	4615                	li	a2,5
     25e:	fe840593          	addi	a1,s0,-24
     262:	4505                	li	a0,1
     264:	00001097          	auipc	ra,0x1
     268:	8be080e7          	jalr	-1858(ra) # b22 <write>
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
     284:	87a080e7          	jalr	-1926(ra) # afa <fork>
    int signum1=3;
    if(pid==0){
     288:	e569                	bnez	a0,352 <test_usersig+0xde>
        struct sigaction act;
        // struct sigaction act2;

        printf("sighandler= %p\n",&sig_handler2);
     28a:	00000597          	auipc	a1,0x0
     28e:	dee58593          	addi	a1,a1,-530 # 78 <sig_handler2>
     292:	00001517          	auipc	a0,0x1
     296:	03e50513          	addi	a0,a0,62 # 12d0 <csem_free+0x130>
     29a:	00001097          	auipc	ra,0x1
     29e:	c3a080e7          	jalr	-966(ra) # ed4 <printf>
        uint mask = 0;
        mask ^= (1<<22);

        act.sa_handler = &sig_handler2;
     2a2:	00000797          	auipc	a5,0x0
     2a6:	dd678793          	addi	a5,a5,-554 # 78 <sig_handler2>
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
     2cc:	8e2080e7          	jalr	-1822(ra) # baa <sigaction>
     2d0:	84aa                	mv	s1,a0
        printf("old act->sa handler= %p, mask=%d\n",oldact.sa_handler,oldact.sigmask);
     2d2:	fd842603          	lw	a2,-40(s0)
     2d6:	fd043583          	ld	a1,-48(s0)
     2da:	00001517          	auipc	a0,0x1
     2de:	00650513          	addi	a0,a0,6 # 12e0 <csem_free+0x140>
     2e2:	00001097          	auipc	ra,0x1
     2e6:	bf2080e7          	jalr	-1038(ra) # ed4 <printf>
        printf("child return from sigaction = %d\n",ret);
     2ea:	85a6                	mv	a1,s1
     2ec:	00001517          	auipc	a0,0x1
     2f0:	01c50513          	addi	a0,a0,28 # 1308 <csem_free+0x168>
     2f4:	00001097          	auipc	ra,0x1
     2f8:	be0080e7          	jalr	-1056(ra) # ed4 <printf>
        sleep(10);
     2fc:	4529                	li	a0,10
     2fe:	00001097          	auipc	ra,0x1
     302:	894080e7          	jalr	-1900(ra) # b92 <sleep>
     306:	44a9                	li	s1,10
        for(int i=0;i<10;i++){
            printf("child doing stuff before exit \n");
     308:	00001917          	auipc	s2,0x1
     30c:	02890913          	addi	s2,s2,40 # 1330 <csem_free+0x190>
     310:	854a                	mv	a0,s2
     312:	00001097          	auipc	ra,0x1
     316:	bc2080e7          	jalr	-1086(ra) # ed4 <printf>
        for(int i=0;i<10;i++){
     31a:	34fd                	addiw	s1,s1,-1
     31c:	f8f5                	bnez	s1,310 <test_usersig+0x9c>
        }
        ret=sigaction(signum1,&act,&oldact);
     31e:	fd040613          	addi	a2,s0,-48
     322:	fc040593          	addi	a1,s0,-64
     326:	450d                	li	a0,3
     328:	00001097          	auipc	ra,0x1
     32c:	882080e7          	jalr	-1918(ra) # baa <sigaction>
        printf("oldact should be the same as new act before \n oldact->mask=%d \t oldact->sa_handler=%d \n",oldact.sigmask,oldact.sa_handler);
     330:	fd043603          	ld	a2,-48(s0)
     334:	fd842583          	lw	a1,-40(s0)
     338:	00001517          	auipc	a0,0x1
     33c:	01850513          	addi	a0,a0,24 # 1350 <csem_free+0x1b0>
     340:	00001097          	auipc	ra,0x1
     344:	b94080e7          	jalr	-1132(ra) # ed4 <printf>

        exit(0);
     348:	4501                	li	a0,0
     34a:	00000097          	auipc	ra,0x0
     34e:	7b8080e7          	jalr	1976(ra) # b02 <exit>
     352:	84aa                	mv	s1,a0

    }
    else{
        sleep(5);
     354:	4515                	li	a0,5
     356:	00001097          	auipc	ra,0x1
     35a:	83c080e7          	jalr	-1988(ra) # b92 <sleep>
        printf("parent send sig 3 to child ret=%d\n",kill(pid,signum1));
     35e:	458d                	li	a1,3
     360:	8526                	mv	a0,s1
     362:	00000097          	auipc	ra,0x0
     366:	7d0080e7          	jalr	2000(ra) # b32 <kill>
     36a:	85aa                	mv	a1,a0
     36c:	00001517          	auipc	a0,0x1
     370:	03c50513          	addi	a0,a0,60 # 13a8 <csem_free+0x208>
     374:	00001097          	auipc	ra,0x1
     378:	b60080e7          	jalr	-1184(ra) # ed4 <printf>
        // printf("parent send sig 4 to child ret=%d\n",kill(pid,4));

        wait(0);
     37c:	4501                	li	a0,0
     37e:	00000097          	auipc	ra,0x0
     382:	78c080e7          	jalr	1932(ra) # b0a <wait>
        exit(0);
     386:	4501                	li	a0,0
     388:	00000097          	auipc	ra,0x0
     38c:	77a080e7          	jalr	1914(ra) # b02 <exit>

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
     3a6:	800080e7          	jalr	-2048(ra) # ba2 <sigprocmask>
    printf("got %d from calling to sigprocmask\n",ans);
     3aa:	0005059b          	sext.w	a1,a0
     3ae:	00001517          	auipc	a0,0x1
     3b2:	02250513          	addi	a0,a0,34 # 13d0 <csem_free+0x230>
     3b6:	00001097          	auipc	ra,0x1
     3ba:	b1e080e7          	jalr	-1250(ra) # ed4 <printf>
    int pid=fork();
     3be:	00000097          	auipc	ra,0x0
     3c2:	73c080e7          	jalr	1852(ra) # afa <fork>
     3c6:	892a                	mv	s2,a0
    if(pid==0){
     3c8:	c535                	beqz	a0,434 <test_block+0xa4>
            printf("child blocking signal %d \n",i);
        }
        exit(0);

    }else{
        sleep(1);//wait for child to block sig
     3ca:	4505                	li	a0,1
     3cc:	00000097          	auipc	ra,0x0
     3d0:	7c6080e7          	jalr	1990(ra) # b92 <sleep>
        printf("parent: sent signal 22 to child ->child shuld block\n");
     3d4:	00001517          	auipc	a0,0x1
     3d8:	04450513          	addi	a0,a0,68 # 1418 <csem_free+0x278>
     3dc:	00001097          	auipc	ra,0x1
     3e0:	af8080e7          	jalr	-1288(ra) # ed4 <printf>
     3e4:	44a9                	li	s1,10
        for(int i=0; i<10;i++){
            kill(pid,signum1);
     3e6:	45d9                	li	a1,22
     3e8:	854a                	mv	a0,s2
     3ea:	00000097          	auipc	ra,0x0
     3ee:	748080e7          	jalr	1864(ra) # b32 <kill>
        for(int i=0; i<10;i++){
     3f2:	34fd                	addiw	s1,s1,-1
     3f4:	f8ed                	bnez	s1,3e6 <test_block+0x56>
        }
        sleep(10);
     3f6:	4529                	li	a0,10
     3f8:	00000097          	auipc	ra,0x0
     3fc:	79a080e7          	jalr	1946(ra) # b92 <sleep>
        kill(pid,signum2);
     400:	45dd                	li	a1,23
     402:	854a                	mv	a0,s2
     404:	00000097          	auipc	ra,0x0
     408:	72e080e7          	jalr	1838(ra) # b32 <kill>

        printf("parent: sent signal 23 to child ->child shuld die\n");
     40c:	00001517          	auipc	a0,0x1
     410:	04450513          	addi	a0,a0,68 # 1450 <csem_free+0x2b0>
     414:	00001097          	auipc	ra,0x1
     418:	ac0080e7          	jalr	-1344(ra) # ed4 <printf>
        wait(0);
     41c:	4501                	li	a0,0
     41e:	00000097          	auipc	ra,0x0
     422:	6ec080e7          	jalr	1772(ra) # b0a <wait>
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
     436:	00000097          	auipc	ra,0x0
     43a:	75c080e7          	jalr	1884(ra) # b92 <sleep>
            printf("child blocking signal %d \n",i);
     43e:	00001997          	auipc	s3,0x1
     442:	fba98993          	addi	s3,s3,-70 # 13f8 <csem_free+0x258>
        for(int i=0;i<1000;i++){
     446:	3e800493          	li	s1,1000
            sleep(1);
     44a:	4505                	li	a0,1
     44c:	00000097          	auipc	ra,0x0
     450:	746080e7          	jalr	1862(ra) # b92 <sleep>
            printf("child blocking signal %d \n",i);
     454:	85ca                	mv	a1,s2
     456:	854e                	mv	a0,s3
     458:	00001097          	auipc	ra,0x1
     45c:	a7c080e7          	jalr	-1412(ra) # ed4 <printf>
        for(int i=0;i<1000;i++){
     460:	2905                	addiw	s2,s2,1
     462:	fe9914e3          	bne	s2,s1,44a <test_block+0xba>
        exit(0);
     466:	4501                	li	a0,0
     468:	00000097          	auipc	ra,0x0
     46c:	69a080e7          	jalr	1690(ra) # b02 <exit>

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
     482:	67c080e7          	jalr	1660(ra) # afa <fork>
     486:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
     488:	e915                	bnez	a0,4bc <test_stop_cont+0x4c>
        sleep(2);
     48a:	4509                	li	a0,2
     48c:	00000097          	auipc	ra,0x0
     490:	706080e7          	jalr	1798(ra) # b92 <sleep>
        for(i=0;i<500;i++){
            printf("%d\n ", i);
     494:	00001997          	auipc	s3,0x1
     498:	ff498993          	addi	s3,s3,-12 # 1488 <csem_free+0x2e8>
        for(i=0;i<500;i++){
     49c:	1f400913          	li	s2,500
            printf("%d\n ", i);
     4a0:	85a6                	mv	a1,s1
     4a2:	854e                	mv	a0,s3
     4a4:	00001097          	auipc	ra,0x1
     4a8:	a30080e7          	jalr	-1488(ra) # ed4 <printf>
        for(i=0;i<500;i++){
     4ac:	2485                	addiw	s1,s1,1
     4ae:	ff2499e3          	bne	s1,s2,4a0 <test_stop_cont+0x30>
        }
        exit(0);
     4b2:	4501                	li	a0,0
     4b4:	00000097          	auipc	ra,0x0
     4b8:	64e080e7          	jalr	1614(ra) # b02 <exit>
    }else{
        printf("son pid=%d, dad pid=%d\n", pid, getpid());
     4bc:	00000097          	auipc	ra,0x0
     4c0:	6c6080e7          	jalr	1734(ra) # b82 <getpid>
     4c4:	862a                	mv	a2,a0
     4c6:	85a6                	mv	a1,s1
     4c8:	00001517          	auipc	a0,0x1
     4cc:	fc850513          	addi	a0,a0,-56 # 1490 <csem_free+0x2f0>
     4d0:	00001097          	auipc	ra,0x1
     4d4:	a04080e7          	jalr	-1532(ra) # ed4 <printf>
        sleep(5);
     4d8:	4515                	li	a0,5
     4da:	00000097          	auipc	ra,0x0
     4de:	6b8080e7          	jalr	1720(ra) # b92 <sleep>
        printf("parent send stop ret= %d\n", kill(pid, SIGSTOP));
     4e2:	45c5                	li	a1,17
     4e4:	8526                	mv	a0,s1
     4e6:	00000097          	auipc	ra,0x0
     4ea:	64c080e7          	jalr	1612(ra) # b32 <kill>
     4ee:	85aa                	mv	a1,a0
     4f0:	00001517          	auipc	a0,0x1
     4f4:	fb850513          	addi	a0,a0,-72 # 14a8 <csem_free+0x308>
     4f8:	00001097          	auipc	ra,0x1
     4fc:	9dc080e7          	jalr	-1572(ra) # ed4 <printf>
        sleep(50);
     500:	03200513          	li	a0,50
     504:	00000097          	auipc	ra,0x0
     508:	68e080e7          	jalr	1678(ra) # b92 <sleep>
        printf("parent send continue ret= %d\n", kill(pid, SIGCONT));
     50c:	45cd                	li	a1,19
     50e:	8526                	mv	a0,s1
     510:	00000097          	auipc	ra,0x0
     514:	622080e7          	jalr	1570(ra) # b32 <kill>
     518:	85aa                	mv	a1,a0
     51a:	00001517          	auipc	a0,0x1
     51e:	fae50513          	addi	a0,a0,-82 # 14c8 <csem_free+0x328>
     522:	00001097          	auipc	ra,0x1
     526:	9b2080e7          	jalr	-1614(ra) # ed4 <printf>
        wait(0);
     52a:	4501                	li	a0,0
     52c:	00000097          	auipc	ra,0x0
     530:	5de080e7          	jalr	1502(ra) # b0a <wait>
        // for(int i=0;i<100;i++)
        //  printf("parent..");
        sleep(10);
     534:	4529                	li	a0,10
     536:	00000097          	auipc	ra,0x0
     53a:	65c080e7          	jalr	1628(ra) # b92 <sleep>
        exit(0);
     53e:	4501                	li	a0,0
     540:	00000097          	auipc	ra,0x0
     544:	5c2080e7          	jalr	1474(ra) # b02 <exit>

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
     55a:	5a4080e7          	jalr	1444(ra) # afa <fork>
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
     568:	fec50513          	addi	a0,a0,-20 # 1550 <csem_free+0x3b0>
     56c:	00001097          	auipc	ra,0x1
     570:	968080e7          	jalr	-1688(ra) # ed4 <printf>
        sleep(5);
     574:	4515                	li	a0,5
     576:	00000097          	auipc	ra,0x0
     57a:	61c080e7          	jalr	1564(ra) # b92 <sleep>
        kill(pid,signum);
     57e:	45d9                	li	a1,22
     580:	8526                	mv	a0,s1
     582:	00000097          	auipc	ra,0x0
     586:	5b0080e7          	jalr	1456(ra) # b32 <kill>
        wait(0);
     58a:	4501                	li	a0,0
     58c:	00000097          	auipc	ra,0x0
     590:	57e080e7          	jalr	1406(ra) # b0a <wait>

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
     5a8:	9ee080e7          	jalr	-1554(ra) # f92 <malloc>
     5ac:	89aa                	mv	s3,a0
        oldAct=malloc(sizeof(sigaction));
     5ae:	4505                	li	a0,1
     5b0:	00001097          	auipc	ra,0x1
     5b4:	9e2080e7          	jalr	-1566(ra) # f92 <malloc>
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
     5ce:	5e0080e7          	jalr	1504(ra) # baa <sigaction>
     5d2:	85aa                	mv	a1,a0
        printf("ans from sigaction %d, old act returned is: mask= %d address= %d\n",ans,oldAct->sigmask,(uint64)oldAct->sa_handler);
     5d4:	00093683          	ld	a3,0(s2)
     5d8:	00892603          	lw	a2,8(s2)
     5dc:	00001517          	auipc	a0,0x1
     5e0:	f0c50513          	addi	a0,a0,-244 # 14e8 <csem_free+0x348>
     5e4:	00001097          	auipc	ra,0x1
     5e8:	8f0080e7          	jalr	-1808(ra) # ed4 <printf>
        sleep(6);
     5ec:	4519                	li	a0,6
     5ee:	00000097          	auipc	ra,0x0
     5f2:	5a4080e7          	jalr	1444(ra) # b92 <sleep>
            printf("child ignoring signal %d\n",i);
     5f6:	00001997          	auipc	s3,0x1
     5fa:	f3a98993          	addi	s3,s3,-198 # 1530 <csem_free+0x390>
        for(int i=0;i<300;i++){
     5fe:	12c00913          	li	s2,300
            printf("child ignoring signal %d\n",i);
     602:	85a6                	mv	a1,s1
     604:	854e                	mv	a0,s3
     606:	00001097          	auipc	ra,0x1
     60a:	8ce080e7          	jalr	-1842(ra) # ed4 <printf>
        for(int i=0;i<300;i++){
     60e:	2485                	addiw	s1,s1,1
     610:	ff2499e3          	bne	s1,s2,602 <test_ignore+0xba>
        exit(0);
     614:	4501                	li	a0,0
     616:	00000097          	auipc	ra,0x0
     61a:	4ec080e7          	jalr	1260(ra) # b02 <exit>

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
     630:	9d458593          	addi	a1,a1,-1580 # 0 <sig_handler_loop>
     634:	00001517          	auipc	a0,0x1
     638:	f2c50513          	addi	a0,a0,-212 # 1560 <csem_free+0x3c0>
     63c:	00001097          	auipc	ra,0x1
     640:	898080e7          	jalr	-1896(ra) # ed4 <printf>
    printf("sighandler2= %p\n", &sig_handler_loop2);
     644:	00000597          	auipc	a1,0x0
     648:	9f858593          	addi	a1,a1,-1544 # 3c <sig_handler_loop2>
     64c:	00001517          	auipc	a0,0x1
     650:	f2c50513          	addi	a0,a0,-212 # 1578 <csem_free+0x3d8>
     654:	00001097          	auipc	ra,0x1
     658:	880080e7          	jalr	-1920(ra) # ed4 <printf>


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
     670:	9d078793          	addi	a5,a5,-1584 # 3c <sig_handler_loop2>
     674:	fcf43023          	sd	a5,-64(s0)


    int pid = fork();
     678:	00000097          	auipc	ra,0x0
     67c:	482080e7          	jalr	1154(ra) # afa <fork>
     680:	84aa                	mv	s1,a0
    int i;
    if(pid==0){
     682:	ed29                	bnez	a0,6dc <test_user_handler_kill+0xbe>
        int ret=sigaction(3,&act,&oldact);
     684:	fb040613          	addi	a2,s0,-80
     688:	fc040593          	addi	a1,s0,-64
     68c:	450d                	li	a0,3
     68e:	00000097          	auipc	ra,0x0
     692:	51c080e7          	jalr	1308(ra) # baa <sigaction>
        if(ret <0 ){
     696:	02054663          	bltz	a0,6c2 <test_user_handler_kill+0xa4>
            printf("sigaction FAILED\n");
            exit(-1);
        }

        for(i=0;i<500;i++)
            printf("out-side handler %d\n ", i);
     69a:	00001997          	auipc	s3,0x1
     69e:	f0e98993          	addi	s3,s3,-242 # 15a8 <csem_free+0x408>
        for(i=0;i<500;i++)
     6a2:	1f400913          	li	s2,500
            printf("out-side handler %d\n ", i);
     6a6:	85a6                	mv	a1,s1
     6a8:	854e                	mv	a0,s3
     6aa:	00001097          	auipc	ra,0x1
     6ae:	82a080e7          	jalr	-2006(ra) # ed4 <printf>
        for(i=0;i<500;i++)
     6b2:	2485                	addiw	s1,s1,1
     6b4:	ff2499e3          	bne	s1,s2,6a6 <test_user_handler_kill+0x88>
        exit(0);
     6b8:	4501                	li	a0,0
     6ba:	00000097          	auipc	ra,0x0
     6be:	448080e7          	jalr	1096(ra) # b02 <exit>
            printf("sigaction FAILED\n");
     6c2:	00001517          	auipc	a0,0x1
     6c6:	ece50513          	addi	a0,a0,-306 # 1590 <csem_free+0x3f0>
     6ca:	00001097          	auipc	ra,0x1
     6ce:	80a080e7          	jalr	-2038(ra) # ed4 <printf>
            exit(-1);
     6d2:	557d                	li	a0,-1
     6d4:	00000097          	auipc	ra,0x0
     6d8:	42e080e7          	jalr	1070(ra) # b02 <exit>
    }else{
        printf("son pid=%d, dad pid=%d\n",pid, getpid());
     6dc:	00000097          	auipc	ra,0x0
     6e0:	4a6080e7          	jalr	1190(ra) # b82 <getpid>
     6e4:	862a                	mv	a2,a0
     6e6:	85a6                	mv	a1,s1
     6e8:	00001517          	auipc	a0,0x1
     6ec:	da850513          	addi	a0,a0,-600 # 1490 <csem_free+0x2f0>
     6f0:	00000097          	auipc	ra,0x0
     6f4:	7e4080e7          	jalr	2020(ra) # ed4 <printf>
        sleep(5);
     6f8:	4515                	li	a0,5
     6fa:	00000097          	auipc	ra,0x0
     6fe:	498080e7          	jalr	1176(ra) # b92 <sleep>
        printf("parent send loop ret= %d\n",kill(pid, 3));
     702:	458d                	li	a1,3
     704:	8526                	mv	a0,s1
     706:	00000097          	auipc	ra,0x0
     70a:	42c080e7          	jalr	1068(ra) # b32 <kill>
     70e:	85aa                	mv	a1,a0
     710:	00001517          	auipc	a0,0x1
     714:	eb050513          	addi	a0,a0,-336 # 15c0 <csem_free+0x420>
     718:	00000097          	auipc	ra,0x0
     71c:	7bc080e7          	jalr	1980(ra) # ed4 <printf>
        sleep(20);
     720:	4551                	li	a0,20
     722:	00000097          	auipc	ra,0x0
     726:	470080e7          	jalr	1136(ra) # b92 <sleep>
        printf("parent send kill ret= %d\n",kill(pid, SIGKILL));
     72a:	45a5                	li	a1,9
     72c:	8526                	mv	a0,s1
     72e:	00000097          	auipc	ra,0x0
     732:	404080e7          	jalr	1028(ra) # b32 <kill>
     736:	85aa                	mv	a1,a0
     738:	00001517          	auipc	a0,0x1
     73c:	ea850513          	addi	a0,a0,-344 # 15e0 <csem_free+0x440>
     740:	00000097          	auipc	ra,0x0
     744:	794080e7          	jalr	1940(ra) # ed4 <printf>
        wait(0);
     748:	4501                	li	a0,0
     74a:	00000097          	auipc	ra,0x0
     74e:	3c0080e7          	jalr	960(ra) # b0a <wait>
        printf("parent exiting\n");
     752:	00001517          	auipc	a0,0x1
     756:	eae50513          	addi	a0,a0,-338 # 1600 <csem_free+0x460>
     75a:	00000097          	auipc	ra,0x0
     75e:	77a080e7          	jalr	1914(ra) # ed4 <printf>
        exit(0);
     762:	4501                	li	a0,0
     764:	00000097          	auipc	ra,0x0
     768:	39e080e7          	jalr	926(ra) # b02 <exit>

000000000000076c <Csem_test>:
    }
}

void Csem_test(char *s){
     76c:	7179                	addi	sp,sp,-48
     76e:	f406                	sd	ra,40(sp)
     770:	f022                	sd	s0,32(sp)
     772:	1800                	addi	s0,sp,48
	struct counting_semaphore csem;
    int retval;
    int pid;
    
    
    retval = csem_alloc(&csem,1);
     774:	4585                	li	a1,1
     776:	fe040513          	addi	a0,s0,-32
     77a:	00001097          	auipc	ra,0x1
     77e:	9da080e7          	jalr	-1574(ra) # 1154 <csem_alloc>
    if(retval==-1)
     782:	57fd                	li	a5,-1
     784:	08f50763          	beq	a0,a5,812 <Csem_test+0xa6>
    {
		printf("failed csem alloc\n");
		exit(-1);
	}
    csem_down(&csem);
     788:	fe040513          	addi	a0,s0,-32
     78c:	00001097          	auipc	ra,0x1
     790:	8ec080e7          	jalr	-1812(ra) # 1078 <csem_down>
    printf("1. Parent downing semaphore\n");
     794:	00001517          	auipc	a0,0x1
     798:	e9450513          	addi	a0,a0,-364 # 1628 <csem_free+0x488>
     79c:	00000097          	auipc	ra,0x0
     7a0:	738080e7          	jalr	1848(ra) # ed4 <printf>
    if((pid = fork()) == 0){
     7a4:	00000097          	auipc	ra,0x0
     7a8:	356080e7          	jalr	854(ra) # afa <fork>
     7ac:	fca42e23          	sw	a0,-36(s0)
     7b0:	cd35                	beqz	a0,82c <Csem_test+0xc0>
        printf("2. Child downing semaphore\n");
        csem_down(&csem);
        printf("4. Child woke up\n");
        exit(0);
    }
    sleep(5);
     7b2:	4515                	li	a0,5
     7b4:	00000097          	auipc	ra,0x0
     7b8:	3de080e7          	jalr	990(ra) # b92 <sleep>
    printf("3. Let the child wait on the semaphore...\n");
     7bc:	00001517          	auipc	a0,0x1
     7c0:	ec450513          	addi	a0,a0,-316 # 1680 <csem_free+0x4e0>
     7c4:	00000097          	auipc	ra,0x0
     7c8:	710080e7          	jalr	1808(ra) # ed4 <printf>
    sleep(10);
     7cc:	4529                	li	a0,10
     7ce:	00000097          	auipc	ra,0x0
     7d2:	3c4080e7          	jalr	964(ra) # b92 <sleep>
    csem_up(&csem);
     7d6:	fe040513          	addi	a0,s0,-32
     7da:	00001097          	auipc	ra,0x1
     7de:	920080e7          	jalr	-1760(ra) # 10fa <csem_up>
    csem_free(&csem);
     7e2:	fe040513          	addi	a0,s0,-32
     7e6:	00001097          	auipc	ra,0x1
     7ea:	9ba080e7          	jalr	-1606(ra) # 11a0 <csem_free>
    wait(&pid);
     7ee:	fdc40513          	addi	a0,s0,-36
     7f2:	00000097          	auipc	ra,0x0
     7f6:	318080e7          	jalr	792(ra) # b0a <wait>

    printf("Finished bsem test, make sure that the order of the prints is alright. Meaning (1...2...3...4)\n");
     7fa:	00001517          	auipc	a0,0x1
     7fe:	eb650513          	addi	a0,a0,-330 # 16b0 <csem_free+0x510>
     802:	00000097          	auipc	ra,0x0
     806:	6d2080e7          	jalr	1746(ra) # ed4 <printf>
}
     80a:	70a2                	ld	ra,40(sp)
     80c:	7402                	ld	s0,32(sp)
     80e:	6145                	addi	sp,sp,48
     810:	8082                	ret
		printf("failed csem alloc\n");
     812:	00001517          	auipc	a0,0x1
     816:	dfe50513          	addi	a0,a0,-514 # 1610 <csem_free+0x470>
     81a:	00000097          	auipc	ra,0x0
     81e:	6ba080e7          	jalr	1722(ra) # ed4 <printf>
		exit(-1);
     822:	557d                	li	a0,-1
     824:	00000097          	auipc	ra,0x0
     828:	2de080e7          	jalr	734(ra) # b02 <exit>
        printf("2. Child downing semaphore\n");
     82c:	00001517          	auipc	a0,0x1
     830:	e1c50513          	addi	a0,a0,-484 # 1648 <csem_free+0x4a8>
     834:	00000097          	auipc	ra,0x0
     838:	6a0080e7          	jalr	1696(ra) # ed4 <printf>
        csem_down(&csem);
     83c:	fe040513          	addi	a0,s0,-32
     840:	00001097          	auipc	ra,0x1
     844:	838080e7          	jalr	-1992(ra) # 1078 <csem_down>
        printf("4. Child woke up\n");
     848:	00001517          	auipc	a0,0x1
     84c:	e2050513          	addi	a0,a0,-480 # 1668 <csem_free+0x4c8>
     850:	00000097          	auipc	ra,0x0
     854:	684080e7          	jalr	1668(ra) # ed4 <printf>
        exit(0);
     858:	4501                	li	a0,0
     85a:	00000097          	auipc	ra,0x0
     85e:	2a8080e7          	jalr	680(ra) # b02 <exit>

0000000000000862 <main>:



int main(){
     862:	1141                	addi	sp,sp,-16
     864:	e406                	sd	ra,8(sp)
     866:	e022                	sd	s0,0(sp)
     868:	0800                	addi	s0,sp,16
    // printf("-----------------------------test_ignore-----------------------------\n");
    // test_ignore();
    // printf("-----------------------------test_user_handler_then_kill-----------------------------\n");
    // test_user_handler_kill();

    printf("-----------------------------Csem_test-----------------------------\n");
     86a:	00001517          	auipc	a0,0x1
     86e:	ea650513          	addi	a0,a0,-346 # 1710 <csem_free+0x570>
     872:	00000097          	auipc	ra,0x0
     876:	662080e7          	jalr	1634(ra) # ed4 <printf>
    Csem_test("a");
     87a:	00001517          	auipc	a0,0x1
     87e:	ede50513          	addi	a0,a0,-290 # 1758 <csem_free+0x5b8>
     882:	00000097          	auipc	ra,0x0
     886:	eea080e7          	jalr	-278(ra) # 76c <Csem_test>
   

    exit(0);
     88a:	4501                	li	a0,0
     88c:	00000097          	auipc	ra,0x0
     890:	276080e7          	jalr	630(ra) # b02 <exit>

0000000000000894 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     894:	1141                	addi	sp,sp,-16
     896:	e422                	sd	s0,8(sp)
     898:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     89a:	87aa                	mv	a5,a0
     89c:	0585                	addi	a1,a1,1
     89e:	0785                	addi	a5,a5,1
     8a0:	fff5c703          	lbu	a4,-1(a1)
     8a4:	fee78fa3          	sb	a4,-1(a5)
     8a8:	fb75                	bnez	a4,89c <strcpy+0x8>
    ;
  return os;
}
     8aa:	6422                	ld	s0,8(sp)
     8ac:	0141                	addi	sp,sp,16
     8ae:	8082                	ret

00000000000008b0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     8b0:	1141                	addi	sp,sp,-16
     8b2:	e422                	sd	s0,8(sp)
     8b4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     8b6:	00054783          	lbu	a5,0(a0)
     8ba:	cb91                	beqz	a5,8ce <strcmp+0x1e>
     8bc:	0005c703          	lbu	a4,0(a1)
     8c0:	00f71763          	bne	a4,a5,8ce <strcmp+0x1e>
    p++, q++;
     8c4:	0505                	addi	a0,a0,1
     8c6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     8c8:	00054783          	lbu	a5,0(a0)
     8cc:	fbe5                	bnez	a5,8bc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     8ce:	0005c503          	lbu	a0,0(a1)
}
     8d2:	40a7853b          	subw	a0,a5,a0
     8d6:	6422                	ld	s0,8(sp)
     8d8:	0141                	addi	sp,sp,16
     8da:	8082                	ret

00000000000008dc <strlen>:

uint
strlen(const char *s)
{
     8dc:	1141                	addi	sp,sp,-16
     8de:	e422                	sd	s0,8(sp)
     8e0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     8e2:	00054783          	lbu	a5,0(a0)
     8e6:	cf91                	beqz	a5,902 <strlen+0x26>
     8e8:	0505                	addi	a0,a0,1
     8ea:	87aa                	mv	a5,a0
     8ec:	4685                	li	a3,1
     8ee:	9e89                	subw	a3,a3,a0
     8f0:	00f6853b          	addw	a0,a3,a5
     8f4:	0785                	addi	a5,a5,1
     8f6:	fff7c703          	lbu	a4,-1(a5)
     8fa:	fb7d                	bnez	a4,8f0 <strlen+0x14>
    ;
  return n;
}
     8fc:	6422                	ld	s0,8(sp)
     8fe:	0141                	addi	sp,sp,16
     900:	8082                	ret
  for(n = 0; s[n]; n++)
     902:	4501                	li	a0,0
     904:	bfe5                	j	8fc <strlen+0x20>

0000000000000906 <memset>:

void*
memset(void *dst, int c, uint n)
{
     906:	1141                	addi	sp,sp,-16
     908:	e422                	sd	s0,8(sp)
     90a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     90c:	ca19                	beqz	a2,922 <memset+0x1c>
     90e:	87aa                	mv	a5,a0
     910:	1602                	slli	a2,a2,0x20
     912:	9201                	srli	a2,a2,0x20
     914:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     918:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     91c:	0785                	addi	a5,a5,1
     91e:	fee79de3          	bne	a5,a4,918 <memset+0x12>
  }
  return dst;
}
     922:	6422                	ld	s0,8(sp)
     924:	0141                	addi	sp,sp,16
     926:	8082                	ret

0000000000000928 <strchr>:

char*
strchr(const char *s, char c)
{
     928:	1141                	addi	sp,sp,-16
     92a:	e422                	sd	s0,8(sp)
     92c:	0800                	addi	s0,sp,16
  for(; *s; s++)
     92e:	00054783          	lbu	a5,0(a0)
     932:	cb99                	beqz	a5,948 <strchr+0x20>
    if(*s == c)
     934:	00f58763          	beq	a1,a5,942 <strchr+0x1a>
  for(; *s; s++)
     938:	0505                	addi	a0,a0,1
     93a:	00054783          	lbu	a5,0(a0)
     93e:	fbfd                	bnez	a5,934 <strchr+0xc>
      return (char*)s;
  return 0;
     940:	4501                	li	a0,0
}
     942:	6422                	ld	s0,8(sp)
     944:	0141                	addi	sp,sp,16
     946:	8082                	ret
  return 0;
     948:	4501                	li	a0,0
     94a:	bfe5                	j	942 <strchr+0x1a>

000000000000094c <gets>:

char*
gets(char *buf, int max)
{
     94c:	711d                	addi	sp,sp,-96
     94e:	ec86                	sd	ra,88(sp)
     950:	e8a2                	sd	s0,80(sp)
     952:	e4a6                	sd	s1,72(sp)
     954:	e0ca                	sd	s2,64(sp)
     956:	fc4e                	sd	s3,56(sp)
     958:	f852                	sd	s4,48(sp)
     95a:	f456                	sd	s5,40(sp)
     95c:	f05a                	sd	s6,32(sp)
     95e:	ec5e                	sd	s7,24(sp)
     960:	1080                	addi	s0,sp,96
     962:	8baa                	mv	s7,a0
     964:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     966:	892a                	mv	s2,a0
     968:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     96a:	4aa9                	li	s5,10
     96c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     96e:	89a6                	mv	s3,s1
     970:	2485                	addiw	s1,s1,1
     972:	0344d863          	bge	s1,s4,9a2 <gets+0x56>
    cc = read(0, &c, 1);
     976:	4605                	li	a2,1
     978:	faf40593          	addi	a1,s0,-81
     97c:	4501                	li	a0,0
     97e:	00000097          	auipc	ra,0x0
     982:	19c080e7          	jalr	412(ra) # b1a <read>
    if(cc < 1)
     986:	00a05e63          	blez	a0,9a2 <gets+0x56>
    buf[i++] = c;
     98a:	faf44783          	lbu	a5,-81(s0)
     98e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     992:	01578763          	beq	a5,s5,9a0 <gets+0x54>
     996:	0905                	addi	s2,s2,1
     998:	fd679be3          	bne	a5,s6,96e <gets+0x22>
  for(i=0; i+1 < max; ){
     99c:	89a6                	mv	s3,s1
     99e:	a011                	j	9a2 <gets+0x56>
     9a0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     9a2:	99de                	add	s3,s3,s7
     9a4:	00098023          	sb	zero,0(s3)
  return buf;
}
     9a8:	855e                	mv	a0,s7
     9aa:	60e6                	ld	ra,88(sp)
     9ac:	6446                	ld	s0,80(sp)
     9ae:	64a6                	ld	s1,72(sp)
     9b0:	6906                	ld	s2,64(sp)
     9b2:	79e2                	ld	s3,56(sp)
     9b4:	7a42                	ld	s4,48(sp)
     9b6:	7aa2                	ld	s5,40(sp)
     9b8:	7b02                	ld	s6,32(sp)
     9ba:	6be2                	ld	s7,24(sp)
     9bc:	6125                	addi	sp,sp,96
     9be:	8082                	ret

00000000000009c0 <stat>:

int
stat(const char *n, struct stat *st)
{
     9c0:	1101                	addi	sp,sp,-32
     9c2:	ec06                	sd	ra,24(sp)
     9c4:	e822                	sd	s0,16(sp)
     9c6:	e426                	sd	s1,8(sp)
     9c8:	e04a                	sd	s2,0(sp)
     9ca:	1000                	addi	s0,sp,32
     9cc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     9ce:	4581                	li	a1,0
     9d0:	00000097          	auipc	ra,0x0
     9d4:	172080e7          	jalr	370(ra) # b42 <open>
  if(fd < 0)
     9d8:	02054563          	bltz	a0,a02 <stat+0x42>
     9dc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     9de:	85ca                	mv	a1,s2
     9e0:	00000097          	auipc	ra,0x0
     9e4:	17a080e7          	jalr	378(ra) # b5a <fstat>
     9e8:	892a                	mv	s2,a0
  close(fd);
     9ea:	8526                	mv	a0,s1
     9ec:	00000097          	auipc	ra,0x0
     9f0:	13e080e7          	jalr	318(ra) # b2a <close>
  return r;
}
     9f4:	854a                	mv	a0,s2
     9f6:	60e2                	ld	ra,24(sp)
     9f8:	6442                	ld	s0,16(sp)
     9fa:	64a2                	ld	s1,8(sp)
     9fc:	6902                	ld	s2,0(sp)
     9fe:	6105                	addi	sp,sp,32
     a00:	8082                	ret
    return -1;
     a02:	597d                	li	s2,-1
     a04:	bfc5                	j	9f4 <stat+0x34>

0000000000000a06 <atoi>:

int
atoi(const char *s)
{
     a06:	1141                	addi	sp,sp,-16
     a08:	e422                	sd	s0,8(sp)
     a0a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     a0c:	00054603          	lbu	a2,0(a0)
     a10:	fd06079b          	addiw	a5,a2,-48
     a14:	0ff7f793          	andi	a5,a5,255
     a18:	4725                	li	a4,9
     a1a:	02f76963          	bltu	a4,a5,a4c <atoi+0x46>
     a1e:	86aa                	mv	a3,a0
  n = 0;
     a20:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     a22:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     a24:	0685                	addi	a3,a3,1
     a26:	0025179b          	slliw	a5,a0,0x2
     a2a:	9fa9                	addw	a5,a5,a0
     a2c:	0017979b          	slliw	a5,a5,0x1
     a30:	9fb1                	addw	a5,a5,a2
     a32:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     a36:	0006c603          	lbu	a2,0(a3)
     a3a:	fd06071b          	addiw	a4,a2,-48
     a3e:	0ff77713          	andi	a4,a4,255
     a42:	fee5f1e3          	bgeu	a1,a4,a24 <atoi+0x1e>
  return n;
}
     a46:	6422                	ld	s0,8(sp)
     a48:	0141                	addi	sp,sp,16
     a4a:	8082                	ret
  n = 0;
     a4c:	4501                	li	a0,0
     a4e:	bfe5                	j	a46 <atoi+0x40>

0000000000000a50 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     a50:	1141                	addi	sp,sp,-16
     a52:	e422                	sd	s0,8(sp)
     a54:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     a56:	02b57463          	bgeu	a0,a1,a7e <memmove+0x2e>
    while(n-- > 0)
     a5a:	00c05f63          	blez	a2,a78 <memmove+0x28>
     a5e:	1602                	slli	a2,a2,0x20
     a60:	9201                	srli	a2,a2,0x20
     a62:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     a66:	872a                	mv	a4,a0
      *dst++ = *src++;
     a68:	0585                	addi	a1,a1,1
     a6a:	0705                	addi	a4,a4,1
     a6c:	fff5c683          	lbu	a3,-1(a1)
     a70:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     a74:	fee79ae3          	bne	a5,a4,a68 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     a78:	6422                	ld	s0,8(sp)
     a7a:	0141                	addi	sp,sp,16
     a7c:	8082                	ret
    dst += n;
     a7e:	00c50733          	add	a4,a0,a2
    src += n;
     a82:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     a84:	fec05ae3          	blez	a2,a78 <memmove+0x28>
     a88:	fff6079b          	addiw	a5,a2,-1
     a8c:	1782                	slli	a5,a5,0x20
     a8e:	9381                	srli	a5,a5,0x20
     a90:	fff7c793          	not	a5,a5
     a94:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     a96:	15fd                	addi	a1,a1,-1
     a98:	177d                	addi	a4,a4,-1
     a9a:	0005c683          	lbu	a3,0(a1)
     a9e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     aa2:	fee79ae3          	bne	a5,a4,a96 <memmove+0x46>
     aa6:	bfc9                	j	a78 <memmove+0x28>

0000000000000aa8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     aa8:	1141                	addi	sp,sp,-16
     aaa:	e422                	sd	s0,8(sp)
     aac:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     aae:	ca05                	beqz	a2,ade <memcmp+0x36>
     ab0:	fff6069b          	addiw	a3,a2,-1
     ab4:	1682                	slli	a3,a3,0x20
     ab6:	9281                	srli	a3,a3,0x20
     ab8:	0685                	addi	a3,a3,1
     aba:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     abc:	00054783          	lbu	a5,0(a0)
     ac0:	0005c703          	lbu	a4,0(a1)
     ac4:	00e79863          	bne	a5,a4,ad4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     ac8:	0505                	addi	a0,a0,1
    p2++;
     aca:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     acc:	fed518e3          	bne	a0,a3,abc <memcmp+0x14>
  }
  return 0;
     ad0:	4501                	li	a0,0
     ad2:	a019                	j	ad8 <memcmp+0x30>
      return *p1 - *p2;
     ad4:	40e7853b          	subw	a0,a5,a4
}
     ad8:	6422                	ld	s0,8(sp)
     ada:	0141                	addi	sp,sp,16
     adc:	8082                	ret
  return 0;
     ade:	4501                	li	a0,0
     ae0:	bfe5                	j	ad8 <memcmp+0x30>

0000000000000ae2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     ae2:	1141                	addi	sp,sp,-16
     ae4:	e406                	sd	ra,8(sp)
     ae6:	e022                	sd	s0,0(sp)
     ae8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     aea:	00000097          	auipc	ra,0x0
     aee:	f66080e7          	jalr	-154(ra) # a50 <memmove>
}
     af2:	60a2                	ld	ra,8(sp)
     af4:	6402                	ld	s0,0(sp)
     af6:	0141                	addi	sp,sp,16
     af8:	8082                	ret

0000000000000afa <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     afa:	4885                	li	a7,1
 ecall
     afc:	00000073          	ecall
 ret
     b00:	8082                	ret

0000000000000b02 <exit>:
.global exit
exit:
 li a7, SYS_exit
     b02:	4889                	li	a7,2
 ecall
     b04:	00000073          	ecall
 ret
     b08:	8082                	ret

0000000000000b0a <wait>:
.global wait
wait:
 li a7, SYS_wait
     b0a:	488d                	li	a7,3
 ecall
     b0c:	00000073          	ecall
 ret
     b10:	8082                	ret

0000000000000b12 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     b12:	4891                	li	a7,4
 ecall
     b14:	00000073          	ecall
 ret
     b18:	8082                	ret

0000000000000b1a <read>:
.global read
read:
 li a7, SYS_read
     b1a:	4895                	li	a7,5
 ecall
     b1c:	00000073          	ecall
 ret
     b20:	8082                	ret

0000000000000b22 <write>:
.global write
write:
 li a7, SYS_write
     b22:	48c1                	li	a7,16
 ecall
     b24:	00000073          	ecall
 ret
     b28:	8082                	ret

0000000000000b2a <close>:
.global close
close:
 li a7, SYS_close
     b2a:	48d5                	li	a7,21
 ecall
     b2c:	00000073          	ecall
 ret
     b30:	8082                	ret

0000000000000b32 <kill>:
.global kill
kill:
 li a7, SYS_kill
     b32:	4899                	li	a7,6
 ecall
     b34:	00000073          	ecall
 ret
     b38:	8082                	ret

0000000000000b3a <exec>:
.global exec
exec:
 li a7, SYS_exec
     b3a:	489d                	li	a7,7
 ecall
     b3c:	00000073          	ecall
 ret
     b40:	8082                	ret

0000000000000b42 <open>:
.global open
open:
 li a7, SYS_open
     b42:	48bd                	li	a7,15
 ecall
     b44:	00000073          	ecall
 ret
     b48:	8082                	ret

0000000000000b4a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     b4a:	48c5                	li	a7,17
 ecall
     b4c:	00000073          	ecall
 ret
     b50:	8082                	ret

0000000000000b52 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     b52:	48c9                	li	a7,18
 ecall
     b54:	00000073          	ecall
 ret
     b58:	8082                	ret

0000000000000b5a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     b5a:	48a1                	li	a7,8
 ecall
     b5c:	00000073          	ecall
 ret
     b60:	8082                	ret

0000000000000b62 <link>:
.global link
link:
 li a7, SYS_link
     b62:	48cd                	li	a7,19
 ecall
     b64:	00000073          	ecall
 ret
     b68:	8082                	ret

0000000000000b6a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     b6a:	48d1                	li	a7,20
 ecall
     b6c:	00000073          	ecall
 ret
     b70:	8082                	ret

0000000000000b72 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     b72:	48a5                	li	a7,9
 ecall
     b74:	00000073          	ecall
 ret
     b78:	8082                	ret

0000000000000b7a <dup>:
.global dup
dup:
 li a7, SYS_dup
     b7a:	48a9                	li	a7,10
 ecall
     b7c:	00000073          	ecall
 ret
     b80:	8082                	ret

0000000000000b82 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     b82:	48ad                	li	a7,11
 ecall
     b84:	00000073          	ecall
 ret
     b88:	8082                	ret

0000000000000b8a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     b8a:	48b1                	li	a7,12
 ecall
     b8c:	00000073          	ecall
 ret
     b90:	8082                	ret

0000000000000b92 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     b92:	48b5                	li	a7,13
 ecall
     b94:	00000073          	ecall
 ret
     b98:	8082                	ret

0000000000000b9a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     b9a:	48b9                	li	a7,14
 ecall
     b9c:	00000073          	ecall
 ret
     ba0:	8082                	ret

0000000000000ba2 <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
     ba2:	48d9                	li	a7,22
 ecall
     ba4:	00000073          	ecall
 ret
     ba8:	8082                	ret

0000000000000baa <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
     baa:	48dd                	li	a7,23
 ecall
     bac:	00000073          	ecall
 ret
     bb0:	8082                	ret

0000000000000bb2 <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
     bb2:	48e1                	li	a7,24
 ecall
     bb4:	00000073          	ecall
 ret
     bb8:	8082                	ret

0000000000000bba <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
     bba:	48e5                	li	a7,25
 ecall
     bbc:	00000073          	ecall
 ret
     bc0:	8082                	ret

0000000000000bc2 <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
     bc2:	48e9                	li	a7,26
 ecall
     bc4:	00000073          	ecall
 ret
     bc8:	8082                	ret

0000000000000bca <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
     bca:	48ed                	li	a7,27
 ecall
     bcc:	00000073          	ecall
 ret
     bd0:	8082                	ret

0000000000000bd2 <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
     bd2:	48f1                	li	a7,28
 ecall
     bd4:	00000073          	ecall
 ret
     bd8:	8082                	ret

0000000000000bda <bsem_alloc>:
.global bsem_alloc
bsem_alloc:
 li a7, SYS_bsem_alloc
     bda:	48f5                	li	a7,29
 ecall
     bdc:	00000073          	ecall
 ret
     be0:	8082                	ret

0000000000000be2 <bsem_free>:
.global bsem_free
bsem_free:
 li a7, SYS_bsem_free
     be2:	48f9                	li	a7,30
 ecall
     be4:	00000073          	ecall
 ret
     be8:	8082                	ret

0000000000000bea <bsem_down>:
.global bsem_down
bsem_down:
 li a7, SYS_bsem_down
     bea:	48fd                	li	a7,31
 ecall
     bec:	00000073          	ecall
 ret
     bf0:	8082                	ret

0000000000000bf2 <bsem_up>:
.global bsem_up
bsem_up:
 li a7, SYS_bsem_up
     bf2:	02000893          	li	a7,32
 ecall
     bf6:	00000073          	ecall
 ret
     bfa:	8082                	ret

0000000000000bfc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     bfc:	1101                	addi	sp,sp,-32
     bfe:	ec06                	sd	ra,24(sp)
     c00:	e822                	sd	s0,16(sp)
     c02:	1000                	addi	s0,sp,32
     c04:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     c08:	4605                	li	a2,1
     c0a:	fef40593          	addi	a1,s0,-17
     c0e:	00000097          	auipc	ra,0x0
     c12:	f14080e7          	jalr	-236(ra) # b22 <write>
}
     c16:	60e2                	ld	ra,24(sp)
     c18:	6442                	ld	s0,16(sp)
     c1a:	6105                	addi	sp,sp,32
     c1c:	8082                	ret

0000000000000c1e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     c1e:	7139                	addi	sp,sp,-64
     c20:	fc06                	sd	ra,56(sp)
     c22:	f822                	sd	s0,48(sp)
     c24:	f426                	sd	s1,40(sp)
     c26:	f04a                	sd	s2,32(sp)
     c28:	ec4e                	sd	s3,24(sp)
     c2a:	0080                	addi	s0,sp,64
     c2c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     c2e:	c299                	beqz	a3,c34 <printint+0x16>
     c30:	0805c863          	bltz	a1,cc0 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     c34:	2581                	sext.w	a1,a1
  neg = 0;
     c36:	4881                	li	a7,0
     c38:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     c3c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     c3e:	2601                	sext.w	a2,a2
     c40:	00001517          	auipc	a0,0x1
     c44:	b2850513          	addi	a0,a0,-1240 # 1768 <digits>
     c48:	883a                	mv	a6,a4
     c4a:	2705                	addiw	a4,a4,1
     c4c:	02c5f7bb          	remuw	a5,a1,a2
     c50:	1782                	slli	a5,a5,0x20
     c52:	9381                	srli	a5,a5,0x20
     c54:	97aa                	add	a5,a5,a0
     c56:	0007c783          	lbu	a5,0(a5)
     c5a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     c5e:	0005879b          	sext.w	a5,a1
     c62:	02c5d5bb          	divuw	a1,a1,a2
     c66:	0685                	addi	a3,a3,1
     c68:	fec7f0e3          	bgeu	a5,a2,c48 <printint+0x2a>
  if(neg)
     c6c:	00088b63          	beqz	a7,c82 <printint+0x64>
    buf[i++] = '-';
     c70:	fd040793          	addi	a5,s0,-48
     c74:	973e                	add	a4,a4,a5
     c76:	02d00793          	li	a5,45
     c7a:	fef70823          	sb	a5,-16(a4)
     c7e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     c82:	02e05863          	blez	a4,cb2 <printint+0x94>
     c86:	fc040793          	addi	a5,s0,-64
     c8a:	00e78933          	add	s2,a5,a4
     c8e:	fff78993          	addi	s3,a5,-1
     c92:	99ba                	add	s3,s3,a4
     c94:	377d                	addiw	a4,a4,-1
     c96:	1702                	slli	a4,a4,0x20
     c98:	9301                	srli	a4,a4,0x20
     c9a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     c9e:	fff94583          	lbu	a1,-1(s2)
     ca2:	8526                	mv	a0,s1
     ca4:	00000097          	auipc	ra,0x0
     ca8:	f58080e7          	jalr	-168(ra) # bfc <putc>
  while(--i >= 0)
     cac:	197d                	addi	s2,s2,-1
     cae:	ff3918e3          	bne	s2,s3,c9e <printint+0x80>
}
     cb2:	70e2                	ld	ra,56(sp)
     cb4:	7442                	ld	s0,48(sp)
     cb6:	74a2                	ld	s1,40(sp)
     cb8:	7902                	ld	s2,32(sp)
     cba:	69e2                	ld	s3,24(sp)
     cbc:	6121                	addi	sp,sp,64
     cbe:	8082                	ret
    x = -xx;
     cc0:	40b005bb          	negw	a1,a1
    neg = 1;
     cc4:	4885                	li	a7,1
    x = -xx;
     cc6:	bf8d                	j	c38 <printint+0x1a>

0000000000000cc8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     cc8:	7119                	addi	sp,sp,-128
     cca:	fc86                	sd	ra,120(sp)
     ccc:	f8a2                	sd	s0,112(sp)
     cce:	f4a6                	sd	s1,104(sp)
     cd0:	f0ca                	sd	s2,96(sp)
     cd2:	ecce                	sd	s3,88(sp)
     cd4:	e8d2                	sd	s4,80(sp)
     cd6:	e4d6                	sd	s5,72(sp)
     cd8:	e0da                	sd	s6,64(sp)
     cda:	fc5e                	sd	s7,56(sp)
     cdc:	f862                	sd	s8,48(sp)
     cde:	f466                	sd	s9,40(sp)
     ce0:	f06a                	sd	s10,32(sp)
     ce2:	ec6e                	sd	s11,24(sp)
     ce4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     ce6:	0005c903          	lbu	s2,0(a1)
     cea:	18090f63          	beqz	s2,e88 <vprintf+0x1c0>
     cee:	8aaa                	mv	s5,a0
     cf0:	8b32                	mv	s6,a2
     cf2:	00158493          	addi	s1,a1,1
  state = 0;
     cf6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     cf8:	02500a13          	li	s4,37
      if(c == 'd'){
     cfc:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
     d00:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
     d04:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
     d08:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     d0c:	00001b97          	auipc	s7,0x1
     d10:	a5cb8b93          	addi	s7,s7,-1444 # 1768 <digits>
     d14:	a839                	j	d32 <vprintf+0x6a>
        putc(fd, c);
     d16:	85ca                	mv	a1,s2
     d18:	8556                	mv	a0,s5
     d1a:	00000097          	auipc	ra,0x0
     d1e:	ee2080e7          	jalr	-286(ra) # bfc <putc>
     d22:	a019                	j	d28 <vprintf+0x60>
    } else if(state == '%'){
     d24:	01498f63          	beq	s3,s4,d42 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
     d28:	0485                	addi	s1,s1,1
     d2a:	fff4c903          	lbu	s2,-1(s1)
     d2e:	14090d63          	beqz	s2,e88 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
     d32:	0009079b          	sext.w	a5,s2
    if(state == 0){
     d36:	fe0997e3          	bnez	s3,d24 <vprintf+0x5c>
      if(c == '%'){
     d3a:	fd479ee3          	bne	a5,s4,d16 <vprintf+0x4e>
        state = '%';
     d3e:	89be                	mv	s3,a5
     d40:	b7e5                	j	d28 <vprintf+0x60>
      if(c == 'd'){
     d42:	05878063          	beq	a5,s8,d82 <vprintf+0xba>
      } else if(c == 'l') {
     d46:	05978c63          	beq	a5,s9,d9e <vprintf+0xd6>
      } else if(c == 'x') {
     d4a:	07a78863          	beq	a5,s10,dba <vprintf+0xf2>
      } else if(c == 'p') {
     d4e:	09b78463          	beq	a5,s11,dd6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
     d52:	07300713          	li	a4,115
     d56:	0ce78663          	beq	a5,a4,e22 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
     d5a:	06300713          	li	a4,99
     d5e:	0ee78e63          	beq	a5,a4,e5a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
     d62:	11478863          	beq	a5,s4,e72 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
     d66:	85d2                	mv	a1,s4
     d68:	8556                	mv	a0,s5
     d6a:	00000097          	auipc	ra,0x0
     d6e:	e92080e7          	jalr	-366(ra) # bfc <putc>
        putc(fd, c);
     d72:	85ca                	mv	a1,s2
     d74:	8556                	mv	a0,s5
     d76:	00000097          	auipc	ra,0x0
     d7a:	e86080e7          	jalr	-378(ra) # bfc <putc>
      }
      state = 0;
     d7e:	4981                	li	s3,0
     d80:	b765                	j	d28 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
     d82:	008b0913          	addi	s2,s6,8
     d86:	4685                	li	a3,1
     d88:	4629                	li	a2,10
     d8a:	000b2583          	lw	a1,0(s6)
     d8e:	8556                	mv	a0,s5
     d90:	00000097          	auipc	ra,0x0
     d94:	e8e080e7          	jalr	-370(ra) # c1e <printint>
     d98:	8b4a                	mv	s6,s2
      state = 0;
     d9a:	4981                	li	s3,0
     d9c:	b771                	j	d28 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
     d9e:	008b0913          	addi	s2,s6,8
     da2:	4681                	li	a3,0
     da4:	4629                	li	a2,10
     da6:	000b2583          	lw	a1,0(s6)
     daa:	8556                	mv	a0,s5
     dac:	00000097          	auipc	ra,0x0
     db0:	e72080e7          	jalr	-398(ra) # c1e <printint>
     db4:	8b4a                	mv	s6,s2
      state = 0;
     db6:	4981                	li	s3,0
     db8:	bf85                	j	d28 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
     dba:	008b0913          	addi	s2,s6,8
     dbe:	4681                	li	a3,0
     dc0:	4641                	li	a2,16
     dc2:	000b2583          	lw	a1,0(s6)
     dc6:	8556                	mv	a0,s5
     dc8:	00000097          	auipc	ra,0x0
     dcc:	e56080e7          	jalr	-426(ra) # c1e <printint>
     dd0:	8b4a                	mv	s6,s2
      state = 0;
     dd2:	4981                	li	s3,0
     dd4:	bf91                	j	d28 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
     dd6:	008b0793          	addi	a5,s6,8
     dda:	f8f43423          	sd	a5,-120(s0)
     dde:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
     de2:	03000593          	li	a1,48
     de6:	8556                	mv	a0,s5
     de8:	00000097          	auipc	ra,0x0
     dec:	e14080e7          	jalr	-492(ra) # bfc <putc>
  putc(fd, 'x');
     df0:	85ea                	mv	a1,s10
     df2:	8556                	mv	a0,s5
     df4:	00000097          	auipc	ra,0x0
     df8:	e08080e7          	jalr	-504(ra) # bfc <putc>
     dfc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     dfe:	03c9d793          	srli	a5,s3,0x3c
     e02:	97de                	add	a5,a5,s7
     e04:	0007c583          	lbu	a1,0(a5)
     e08:	8556                	mv	a0,s5
     e0a:	00000097          	auipc	ra,0x0
     e0e:	df2080e7          	jalr	-526(ra) # bfc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     e12:	0992                	slli	s3,s3,0x4
     e14:	397d                	addiw	s2,s2,-1
     e16:	fe0914e3          	bnez	s2,dfe <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
     e1a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
     e1e:	4981                	li	s3,0
     e20:	b721                	j	d28 <vprintf+0x60>
        s = va_arg(ap, char*);
     e22:	008b0993          	addi	s3,s6,8
     e26:	000b3903          	ld	s2,0(s6)
        if(s == 0)
     e2a:	02090163          	beqz	s2,e4c <vprintf+0x184>
        while(*s != 0){
     e2e:	00094583          	lbu	a1,0(s2)
     e32:	c9a1                	beqz	a1,e82 <vprintf+0x1ba>
          putc(fd, *s);
     e34:	8556                	mv	a0,s5
     e36:	00000097          	auipc	ra,0x0
     e3a:	dc6080e7          	jalr	-570(ra) # bfc <putc>
          s++;
     e3e:	0905                	addi	s2,s2,1
        while(*s != 0){
     e40:	00094583          	lbu	a1,0(s2)
     e44:	f9e5                	bnez	a1,e34 <vprintf+0x16c>
        s = va_arg(ap, char*);
     e46:	8b4e                	mv	s6,s3
      state = 0;
     e48:	4981                	li	s3,0
     e4a:	bdf9                	j	d28 <vprintf+0x60>
          s = "(null)";
     e4c:	00001917          	auipc	s2,0x1
     e50:	91490913          	addi	s2,s2,-1772 # 1760 <csem_free+0x5c0>
        while(*s != 0){
     e54:	02800593          	li	a1,40
     e58:	bff1                	j	e34 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
     e5a:	008b0913          	addi	s2,s6,8
     e5e:	000b4583          	lbu	a1,0(s6)
     e62:	8556                	mv	a0,s5
     e64:	00000097          	auipc	ra,0x0
     e68:	d98080e7          	jalr	-616(ra) # bfc <putc>
     e6c:	8b4a                	mv	s6,s2
      state = 0;
     e6e:	4981                	li	s3,0
     e70:	bd65                	j	d28 <vprintf+0x60>
        putc(fd, c);
     e72:	85d2                	mv	a1,s4
     e74:	8556                	mv	a0,s5
     e76:	00000097          	auipc	ra,0x0
     e7a:	d86080e7          	jalr	-634(ra) # bfc <putc>
      state = 0;
     e7e:	4981                	li	s3,0
     e80:	b565                	j	d28 <vprintf+0x60>
        s = va_arg(ap, char*);
     e82:	8b4e                	mv	s6,s3
      state = 0;
     e84:	4981                	li	s3,0
     e86:	b54d                	j	d28 <vprintf+0x60>
    }
  }
}
     e88:	70e6                	ld	ra,120(sp)
     e8a:	7446                	ld	s0,112(sp)
     e8c:	74a6                	ld	s1,104(sp)
     e8e:	7906                	ld	s2,96(sp)
     e90:	69e6                	ld	s3,88(sp)
     e92:	6a46                	ld	s4,80(sp)
     e94:	6aa6                	ld	s5,72(sp)
     e96:	6b06                	ld	s6,64(sp)
     e98:	7be2                	ld	s7,56(sp)
     e9a:	7c42                	ld	s8,48(sp)
     e9c:	7ca2                	ld	s9,40(sp)
     e9e:	7d02                	ld	s10,32(sp)
     ea0:	6de2                	ld	s11,24(sp)
     ea2:	6109                	addi	sp,sp,128
     ea4:	8082                	ret

0000000000000ea6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     ea6:	715d                	addi	sp,sp,-80
     ea8:	ec06                	sd	ra,24(sp)
     eaa:	e822                	sd	s0,16(sp)
     eac:	1000                	addi	s0,sp,32
     eae:	e010                	sd	a2,0(s0)
     eb0:	e414                	sd	a3,8(s0)
     eb2:	e818                	sd	a4,16(s0)
     eb4:	ec1c                	sd	a5,24(s0)
     eb6:	03043023          	sd	a6,32(s0)
     eba:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     ebe:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     ec2:	8622                	mv	a2,s0
     ec4:	00000097          	auipc	ra,0x0
     ec8:	e04080e7          	jalr	-508(ra) # cc8 <vprintf>
}
     ecc:	60e2                	ld	ra,24(sp)
     ece:	6442                	ld	s0,16(sp)
     ed0:	6161                	addi	sp,sp,80
     ed2:	8082                	ret

0000000000000ed4 <printf>:

void
printf(const char *fmt, ...)
{
     ed4:	711d                	addi	sp,sp,-96
     ed6:	ec06                	sd	ra,24(sp)
     ed8:	e822                	sd	s0,16(sp)
     eda:	1000                	addi	s0,sp,32
     edc:	e40c                	sd	a1,8(s0)
     ede:	e810                	sd	a2,16(s0)
     ee0:	ec14                	sd	a3,24(s0)
     ee2:	f018                	sd	a4,32(s0)
     ee4:	f41c                	sd	a5,40(s0)
     ee6:	03043823          	sd	a6,48(s0)
     eea:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     eee:	00840613          	addi	a2,s0,8
     ef2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
     ef6:	85aa                	mv	a1,a0
     ef8:	4505                	li	a0,1
     efa:	00000097          	auipc	ra,0x0
     efe:	dce080e7          	jalr	-562(ra) # cc8 <vprintf>
}
     f02:	60e2                	ld	ra,24(sp)
     f04:	6442                	ld	s0,16(sp)
     f06:	6125                	addi	sp,sp,96
     f08:	8082                	ret

0000000000000f0a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     f0a:	1141                	addi	sp,sp,-16
     f0c:	e422                	sd	s0,8(sp)
     f0e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
     f10:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     f14:	00001797          	auipc	a5,0x1
     f18:	90c7b783          	ld	a5,-1780(a5) # 1820 <freep>
     f1c:	a805                	j	f4c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
     f1e:	4618                	lw	a4,8(a2)
     f20:	9db9                	addw	a1,a1,a4
     f22:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
     f26:	6398                	ld	a4,0(a5)
     f28:	6318                	ld	a4,0(a4)
     f2a:	fee53823          	sd	a4,-16(a0)
     f2e:	a091                	j	f72 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
     f30:	ff852703          	lw	a4,-8(a0)
     f34:	9e39                	addw	a2,a2,a4
     f36:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
     f38:	ff053703          	ld	a4,-16(a0)
     f3c:	e398                	sd	a4,0(a5)
     f3e:	a099                	j	f84 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     f40:	6398                	ld	a4,0(a5)
     f42:	00e7e463          	bltu	a5,a4,f4a <free+0x40>
     f46:	00e6ea63          	bltu	a3,a4,f5a <free+0x50>
{
     f4a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     f4c:	fed7fae3          	bgeu	a5,a3,f40 <free+0x36>
     f50:	6398                	ld	a4,0(a5)
     f52:	00e6e463          	bltu	a3,a4,f5a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     f56:	fee7eae3          	bltu	a5,a4,f4a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
     f5a:	ff852583          	lw	a1,-8(a0)
     f5e:	6390                	ld	a2,0(a5)
     f60:	02059813          	slli	a6,a1,0x20
     f64:	01c85713          	srli	a4,a6,0x1c
     f68:	9736                	add	a4,a4,a3
     f6a:	fae60ae3          	beq	a2,a4,f1e <free+0x14>
    bp->s.ptr = p->s.ptr;
     f6e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
     f72:	4790                	lw	a2,8(a5)
     f74:	02061593          	slli	a1,a2,0x20
     f78:	01c5d713          	srli	a4,a1,0x1c
     f7c:	973e                	add	a4,a4,a5
     f7e:	fae689e3          	beq	a3,a4,f30 <free+0x26>
  } else
    p->s.ptr = bp;
     f82:	e394                	sd	a3,0(a5)
  freep = p;
     f84:	00001717          	auipc	a4,0x1
     f88:	88f73e23          	sd	a5,-1892(a4) # 1820 <freep>
}
     f8c:	6422                	ld	s0,8(sp)
     f8e:	0141                	addi	sp,sp,16
     f90:	8082                	ret

0000000000000f92 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
     f92:	7139                	addi	sp,sp,-64
     f94:	fc06                	sd	ra,56(sp)
     f96:	f822                	sd	s0,48(sp)
     f98:	f426                	sd	s1,40(sp)
     f9a:	f04a                	sd	s2,32(sp)
     f9c:	ec4e                	sd	s3,24(sp)
     f9e:	e852                	sd	s4,16(sp)
     fa0:	e456                	sd	s5,8(sp)
     fa2:	e05a                	sd	s6,0(sp)
     fa4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
     fa6:	02051493          	slli	s1,a0,0x20
     faa:	9081                	srli	s1,s1,0x20
     fac:	04bd                	addi	s1,s1,15
     fae:	8091                	srli	s1,s1,0x4
     fb0:	0014899b          	addiw	s3,s1,1
     fb4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
     fb6:	00001517          	auipc	a0,0x1
     fba:	86a53503          	ld	a0,-1942(a0) # 1820 <freep>
     fbe:	c515                	beqz	a0,fea <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
     fc0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
     fc2:	4798                	lw	a4,8(a5)
     fc4:	02977f63          	bgeu	a4,s1,1002 <malloc+0x70>
     fc8:	8a4e                	mv	s4,s3
     fca:	0009871b          	sext.w	a4,s3
     fce:	6685                	lui	a3,0x1
     fd0:	00d77363          	bgeu	a4,a3,fd6 <malloc+0x44>
     fd4:	6a05                	lui	s4,0x1
     fd6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
     fda:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
     fde:	00001917          	auipc	s2,0x1
     fe2:	84290913          	addi	s2,s2,-1982 # 1820 <freep>
  if(p == (char*)-1)
     fe6:	5afd                	li	s5,-1
     fe8:	a895                	j	105c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
     fea:	00001797          	auipc	a5,0x1
     fee:	83e78793          	addi	a5,a5,-1986 # 1828 <base>
     ff2:	00001717          	auipc	a4,0x1
     ff6:	82f73723          	sd	a5,-2002(a4) # 1820 <freep>
     ffa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
     ffc:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1000:	b7e1                	j	fc8 <malloc+0x36>
      if(p->s.size == nunits)
    1002:	02e48c63          	beq	s1,a4,103a <malloc+0xa8>
        p->s.size -= nunits;
    1006:	4137073b          	subw	a4,a4,s3
    100a:	c798                	sw	a4,8(a5)
        p += p->s.size;
    100c:	02071693          	slli	a3,a4,0x20
    1010:	01c6d713          	srli	a4,a3,0x1c
    1014:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1016:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    101a:	00001717          	auipc	a4,0x1
    101e:	80a73323          	sd	a0,-2042(a4) # 1820 <freep>
      return (void*)(p + 1);
    1022:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    1026:	70e2                	ld	ra,56(sp)
    1028:	7442                	ld	s0,48(sp)
    102a:	74a2                	ld	s1,40(sp)
    102c:	7902                	ld	s2,32(sp)
    102e:	69e2                	ld	s3,24(sp)
    1030:	6a42                	ld	s4,16(sp)
    1032:	6aa2                	ld	s5,8(sp)
    1034:	6b02                	ld	s6,0(sp)
    1036:	6121                	addi	sp,sp,64
    1038:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    103a:	6398                	ld	a4,0(a5)
    103c:	e118                	sd	a4,0(a0)
    103e:	bff1                	j	101a <malloc+0x88>
  hp->s.size = nu;
    1040:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1044:	0541                	addi	a0,a0,16
    1046:	00000097          	auipc	ra,0x0
    104a:	ec4080e7          	jalr	-316(ra) # f0a <free>
  return freep;
    104e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1052:	d971                	beqz	a0,1026 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1054:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1056:	4798                	lw	a4,8(a5)
    1058:	fa9775e3          	bgeu	a4,s1,1002 <malloc+0x70>
    if(p == freep)
    105c:	00093703          	ld	a4,0(s2)
    1060:	853e                	mv	a0,a5
    1062:	fef719e3          	bne	a4,a5,1054 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    1066:	8552                	mv	a0,s4
    1068:	00000097          	auipc	ra,0x0
    106c:	b22080e7          	jalr	-1246(ra) # b8a <sbrk>
  if(p == (char*)-1)
    1070:	fd5518e3          	bne	a0,s5,1040 <malloc+0xae>
        return 0;
    1074:	4501                	li	a0,0
    1076:	bf45                	j	1026 <malloc+0x94>

0000000000001078 <csem_down>:
#include "Csemaphore.h"

struct counting_semaphore;

void 
csem_down(struct counting_semaphore *sem){
    1078:	1101                	addi	sp,sp,-32
    107a:	ec06                	sd	ra,24(sp)
    107c:	e822                	sd	s0,16(sp)
    107e:	e426                	sd	s1,8(sp)
    1080:	1000                	addi	s0,sp,32
    if(!sem){
    1082:	cd29                	beqz	a0,10dc <csem_down+0x64>
    1084:	84aa                	mv	s1,a0
        printf("invalid sem pointer in csem_down\n");
        return;
    }
    
    bsem_down(sem->S1_desc);   //TODO: make sure works
    1086:	4108                	lw	a0,0(a0)
    1088:	00000097          	auipc	ra,0x0
    108c:	b62080e7          	jalr	-1182(ra) # bea <bsem_down>
    sem->waiting++;
    1090:	44dc                	lw	a5,12(s1)
    1092:	2785                	addiw	a5,a5,1
    1094:	c4dc                	sw	a5,12(s1)
    bsem_up(sem->S1_desc);
    1096:	4088                	lw	a0,0(s1)
    1098:	00000097          	auipc	ra,0x0
    109c:	b5a080e7          	jalr	-1190(ra) # bf2 <bsem_up>

    bsem_down(sem->S2_desc);
    10a0:	40c8                	lw	a0,4(s1)
    10a2:	00000097          	auipc	ra,0x0
    10a6:	b48080e7          	jalr	-1208(ra) # bea <bsem_down>
    bsem_down(sem->S1_desc);
    10aa:	4088                	lw	a0,0(s1)
    10ac:	00000097          	auipc	ra,0x0
    10b0:	b3e080e7          	jalr	-1218(ra) # bea <bsem_down>
    sem->waiting--;
    10b4:	44dc                	lw	a5,12(s1)
    10b6:	37fd                	addiw	a5,a5,-1
    10b8:	c4dc                	sw	a5,12(s1)
    sem->value--;
    10ba:	449c                	lw	a5,8(s1)
    10bc:	37fd                	addiw	a5,a5,-1
    10be:	0007871b          	sext.w	a4,a5
    10c2:	c49c                	sw	a5,8(s1)
    if(sem->value > 0)
    10c4:	02e04563          	bgtz	a4,10ee <csem_down+0x76>
        bsem_up(sem->S2_desc);
    bsem_up(sem->S1_desc);
    10c8:	4088                	lw	a0,0(s1)
    10ca:	00000097          	auipc	ra,0x0
    10ce:	b28080e7          	jalr	-1240(ra) # bf2 <bsem_up>

}
    10d2:	60e2                	ld	ra,24(sp)
    10d4:	6442                	ld	s0,16(sp)
    10d6:	64a2                	ld	s1,8(sp)
    10d8:	6105                	addi	sp,sp,32
    10da:	8082                	ret
        printf("invalid sem pointer in csem_down\n");
    10dc:	00000517          	auipc	a0,0x0
    10e0:	6a450513          	addi	a0,a0,1700 # 1780 <digits+0x18>
    10e4:	00000097          	auipc	ra,0x0
    10e8:	df0080e7          	jalr	-528(ra) # ed4 <printf>
        return;
    10ec:	b7dd                	j	10d2 <csem_down+0x5a>
        bsem_up(sem->S2_desc);
    10ee:	40c8                	lw	a0,4(s1)
    10f0:	00000097          	auipc	ra,0x0
    10f4:	b02080e7          	jalr	-1278(ra) # bf2 <bsem_up>
    10f8:	bfc1                	j	10c8 <csem_down+0x50>

00000000000010fa <csem_up>:

void            
csem_up(struct counting_semaphore *sem){
    10fa:	1101                	addi	sp,sp,-32
    10fc:	ec06                	sd	ra,24(sp)
    10fe:	e822                	sd	s0,16(sp)
    1100:	e426                	sd	s1,8(sp)
    1102:	1000                	addi	s0,sp,32
    if(!sem){
    1104:	c90d                	beqz	a0,1136 <csem_up+0x3c>
    1106:	84aa                	mv	s1,a0
        printf("invalid sem pointer in csem_up\n");
        return;
    }

    bsem_down(sem->S1_desc);
    1108:	4108                	lw	a0,0(a0)
    110a:	00000097          	auipc	ra,0x0
    110e:	ae0080e7          	jalr	-1312(ra) # bea <bsem_down>
    sem->value++;
    1112:	449c                	lw	a5,8(s1)
    1114:	2785                	addiw	a5,a5,1
    1116:	0007871b          	sext.w	a4,a5
    111a:	c49c                	sw	a5,8(s1)
    if(sem->value == 1)
    111c:	4785                	li	a5,1
    111e:	02f70563          	beq	a4,a5,1148 <csem_up+0x4e>
        bsem_up(sem->S2_desc);
    bsem_up(sem->S1_desc);
    1122:	4088                	lw	a0,0(s1)
    1124:	00000097          	auipc	ra,0x0
    1128:	ace080e7          	jalr	-1330(ra) # bf2 <bsem_up>
}
    112c:	60e2                	ld	ra,24(sp)
    112e:	6442                	ld	s0,16(sp)
    1130:	64a2                	ld	s1,8(sp)
    1132:	6105                	addi	sp,sp,32
    1134:	8082                	ret
        printf("invalid sem pointer in csem_up\n");
    1136:	00000517          	auipc	a0,0x0
    113a:	67250513          	addi	a0,a0,1650 # 17a8 <digits+0x40>
    113e:	00000097          	auipc	ra,0x0
    1142:	d96080e7          	jalr	-618(ra) # ed4 <printf>
        return;
    1146:	b7dd                	j	112c <csem_up+0x32>
        bsem_up(sem->S2_desc);
    1148:	40c8                	lw	a0,4(s1)
    114a:	00000097          	auipc	ra,0x0
    114e:	aa8080e7          	jalr	-1368(ra) # bf2 <bsem_up>
    1152:	bfc1                	j	1122 <csem_up+0x28>

0000000000001154 <csem_alloc>:


int             
csem_alloc(struct counting_semaphore *sem, int initial_value){
    1154:	1101                	addi	sp,sp,-32
    1156:	ec06                	sd	ra,24(sp)
    1158:	e822                	sd	s0,16(sp)
    115a:	e426                	sd	s1,8(sp)
    115c:	e04a                	sd	s2,0(sp)
    115e:	1000                	addi	s0,sp,32
    1160:	84aa                	mv	s1,a0
    1162:	892e                	mv	s2,a1
    sem->S1_desc = bsem_alloc();
    1164:	00000097          	auipc	ra,0x0
    1168:	a76080e7          	jalr	-1418(ra) # bda <bsem_alloc>
    116c:	c088                	sw	a0,0(s1)
    sem->S2_desc = bsem_alloc();
    116e:	00000097          	auipc	ra,0x0
    1172:	a6c080e7          	jalr	-1428(ra) # bda <bsem_alloc>
    1176:	c0c8                	sw	a0,4(s1)
    if(sem->S1_desc <0 || sem->S2_desc < 0)
    1178:	409c                	lw	a5,0(s1)
    117a:	0007cf63          	bltz	a5,1198 <csem_alloc+0x44>
    117e:	00054f63          	bltz	a0,119c <csem_alloc+0x48>
        return -1;
    sem->value = initial_value;
    1182:	0124a423          	sw	s2,8(s1)
    sem->waiting = 0;
    1186:	0004a623          	sw	zero,12(s1)

    return 0;
    118a:	4501                	li	a0,0
}
    118c:	60e2                	ld	ra,24(sp)
    118e:	6442                	ld	s0,16(sp)
    1190:	64a2                	ld	s1,8(sp)
    1192:	6902                	ld	s2,0(sp)
    1194:	6105                	addi	sp,sp,32
    1196:	8082                	ret
        return -1;
    1198:	557d                	li	a0,-1
    119a:	bfcd                	j	118c <csem_alloc+0x38>
    119c:	557d                	li	a0,-1
    119e:	b7fd                	j	118c <csem_alloc+0x38>

00000000000011a0 <csem_free>:
void            
csem_free(struct counting_semaphore *sem){
    11a0:	1101                	addi	sp,sp,-32
    11a2:	ec06                	sd	ra,24(sp)
    11a4:	e822                	sd	s0,16(sp)
    11a6:	e426                	sd	s1,8(sp)
    11a8:	1000                	addi	s0,sp,32
    if(!sem){
    11aa:	c905                	beqz	a0,11da <csem_free+0x3a>
    11ac:	84aa                	mv	s1,a0
        printf("invalid sem pointer in csem_free\n");
        return;
    
    }

    bsem_down(sem->S1_desc);
    11ae:	4108                	lw	a0,0(a0)
    11b0:	00000097          	auipc	ra,0x0
    11b4:	a3a080e7          	jalr	-1478(ra) # bea <bsem_down>

    if(sem->waiting!=0){
    11b8:	44dc                	lw	a5,12(s1)
    11ba:	eb8d                	bnez	a5,11ec <csem_free+0x4c>
        printf("csem_free: cant free while proc waiting\n");
        bsem_up(sem->S1_desc);
        return;
    }
    bsem_free(sem->S1_desc);
    11bc:	4088                	lw	a0,0(s1)
    11be:	00000097          	auipc	ra,0x0
    11c2:	a24080e7          	jalr	-1500(ra) # be2 <bsem_free>
    bsem_free(sem->S2_desc);
    11c6:	40c8                	lw	a0,4(s1)
    11c8:	00000097          	auipc	ra,0x0
    11cc:	a1a080e7          	jalr	-1510(ra) # be2 <bsem_free>

    11d0:	60e2                	ld	ra,24(sp)
    11d2:	6442                	ld	s0,16(sp)
    11d4:	64a2                	ld	s1,8(sp)
    11d6:	6105                	addi	sp,sp,32
    11d8:	8082                	ret
        printf("invalid sem pointer in csem_free\n");
    11da:	00000517          	auipc	a0,0x0
    11de:	5ee50513          	addi	a0,a0,1518 # 17c8 <digits+0x60>
    11e2:	00000097          	auipc	ra,0x0
    11e6:	cf2080e7          	jalr	-782(ra) # ed4 <printf>
        return;
    11ea:	b7dd                	j	11d0 <csem_free+0x30>
        printf("csem_free: cant free while proc waiting\n");
    11ec:	00000517          	auipc	a0,0x0
    11f0:	60450513          	addi	a0,a0,1540 # 17f0 <digits+0x88>
    11f4:	00000097          	auipc	ra,0x0
    11f8:	ce0080e7          	jalr	-800(ra) # ed4 <printf>
        bsem_up(sem->S1_desc);
    11fc:	4088                	lw	a0,0(s1)
    11fe:	00000097          	auipc	ra,0x0
    1202:	9f4080e7          	jalr	-1548(ra) # bf2 <bsem_up>
        return;
    1206:	b7e9                	j	11d0 <csem_free+0x30>
