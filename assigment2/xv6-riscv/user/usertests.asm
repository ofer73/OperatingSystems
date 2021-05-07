
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_handler>:
char buf[BUFSZ];


int wait_sig = 0;

void test_handler(int signum){
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
    wait_sig = 1;
       8:	4785                	li	a5,1
       a:	00008717          	auipc	a4,0x8
       e:	3af72f23          	sw	a5,958(a4) # 83c8 <wait_sig>
    printf("Received sigtest\n");
      12:	00006517          	auipc	a0,0x6
      16:	fbe50513          	addi	a0,a0,-66 # 5fd0 <malloc+0x30e>
      1a:	00006097          	auipc	ra,0x6
      1e:	bea080e7          	jalr	-1046(ra) # 5c04 <printf>
}
      22:	60a2                	ld	ra,8(sp)
      24:	6402                	ld	s0,0(sp)
      26:	0141                	addi	sp,sp,16
      28:	8082                	ret

000000000000002a <test_thread>:

void test_thread(){
      2a:	1141                	addi	sp,sp,-16
      2c:	e406                	sd	ra,8(sp)
      2e:	e022                	sd	s0,0(sp)
      30:	0800                	addi	s0,sp,16
    printf("Thread is now running\n");
      32:	00006517          	auipc	a0,0x6
      36:	fb650513          	addi	a0,a0,-74 # 5fe8 <malloc+0x326>
      3a:	00006097          	auipc	ra,0x6
      3e:	bca080e7          	jalr	-1078(ra) # 5c04 <printf>
    kthread_exit(0);
      42:	4501                	li	a0,0
      44:	00006097          	auipc	ra,0x6
      48:	8d8080e7          	jalr	-1832(ra) # 591c <kthread_exit>
}
      4c:	60a2                	ld	ra,8(sp)
      4e:	6402                	ld	s0,0(sp)
      50:	0141                	addi	sp,sp,16
      52:	8082                	ret

0000000000000054 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      54:	00009797          	auipc	a5,0x9
      58:	48c78793          	addi	a5,a5,1164 # 94e0 <uninit>
      5c:	0000c697          	auipc	a3,0xc
      60:	b9468693          	addi	a3,a3,-1132 # bbf0 <buf>
    if(uninit[i] != '\0'){
      64:	0007c703          	lbu	a4,0(a5)
      68:	e709                	bnez	a4,72 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6a:	0785                	addi	a5,a5,1
      6c:	fed79ce3          	bne	a5,a3,64 <bsstest+0x10>
      70:	8082                	ret
{
      72:	1141                	addi	sp,sp,-16
      74:	e406                	sd	ra,8(sp)
      76:	e022                	sd	s0,0(sp)
      78:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7a:	85aa                	mv	a1,a0
      7c:	00006517          	auipc	a0,0x6
      80:	f8450513          	addi	a0,a0,-124 # 6000 <malloc+0x33e>
      84:	00006097          	auipc	ra,0x6
      88:	b80080e7          	jalr	-1152(ra) # 5c04 <printf>
      exit(1);
      8c:	4505                	li	a0,1
      8e:	00005097          	auipc	ra,0x5
      92:	7c6080e7          	jalr	1990(ra) # 5854 <exit>

0000000000000096 <signal_test>:
void signal_test(char *s){
      96:	715d                	addi	sp,sp,-80
      98:	e486                	sd	ra,72(sp)
      9a:	e0a2                	sd	s0,64(sp)
      9c:	fc26                	sd	s1,56(sp)
      9e:	0880                	addi	s0,sp,80
    struct sigaction act = {test_handler, (uint)(1 << 29)};
      a0:	00000797          	auipc	a5,0x0
      a4:	f6078793          	addi	a5,a5,-160 # 0 <test_handler>
      a8:	fcf43423          	sd	a5,-56(s0)
      ac:	200007b7          	lui	a5,0x20000
      b0:	fcf42823          	sw	a5,-48(s0)
    sigprocmask(0);
      b4:	4501                	li	a0,0
      b6:	00006097          	auipc	ra,0x6
      ba:	83e080e7          	jalr	-1986(ra) # 58f4 <sigprocmask>
    sigaction(testsig, &act, &old);
      be:	fb840613          	addi	a2,s0,-72
      c2:	fc840593          	addi	a1,s0,-56
      c6:	453d                	li	a0,15
      c8:	00006097          	auipc	ra,0x6
      cc:	834080e7          	jalr	-1996(ra) # 58fc <sigaction>
    if((pid = fork()) == 0){
      d0:	00005097          	auipc	ra,0x5
      d4:	77c080e7          	jalr	1916(ra) # 584c <fork>
      d8:	fca42e23          	sw	a0,-36(s0)
      dc:	c90d                	beqz	a0,10e <signal_test+0x78>
    kill(pid, testsig);
      de:	45bd                	li	a1,15
      e0:	00005097          	auipc	ra,0x5
      e4:	7a4080e7          	jalr	1956(ra) # 5884 <kill>
    wait(&pid);
      e8:	fdc40513          	addi	a0,s0,-36
      ec:	00005097          	auipc	ra,0x5
      f0:	770080e7          	jalr	1904(ra) # 585c <wait>
    printf("Finished testing signals\n");
      f4:	00006517          	auipc	a0,0x6
      f8:	f2450513          	addi	a0,a0,-220 # 6018 <malloc+0x356>
      fc:	00006097          	auipc	ra,0x6
     100:	b08080e7          	jalr	-1272(ra) # 5c04 <printf>
}
     104:	60a6                	ld	ra,72(sp)
     106:	6406                	ld	s0,64(sp)
     108:	74e2                	ld	s1,56(sp)
     10a:	6161                	addi	sp,sp,80
     10c:	8082                	ret
        while(!wait_sig)
     10e:	00008797          	auipc	a5,0x8
     112:	2ba7a783          	lw	a5,698(a5) # 83c8 <wait_sig>
     116:	ef81                	bnez	a5,12e <signal_test+0x98>
     118:	00008497          	auipc	s1,0x8
     11c:	2b048493          	addi	s1,s1,688 # 83c8 <wait_sig>
            sleep(1);
     120:	4505                	li	a0,1
     122:	00005097          	auipc	ra,0x5
     126:	7c2080e7          	jalr	1986(ra) # 58e4 <sleep>
        while(!wait_sig)
     12a:	409c                	lw	a5,0(s1)
     12c:	dbf5                	beqz	a5,120 <signal_test+0x8a>
        exit(0);
     12e:	4501                	li	a0,0
     130:	00005097          	auipc	ra,0x5
     134:	724080e7          	jalr	1828(ra) # 5854 <exit>

0000000000000138 <exitwait>:
{
     138:	7139                	addi	sp,sp,-64
     13a:	fc06                	sd	ra,56(sp)
     13c:	f822                	sd	s0,48(sp)
     13e:	f426                	sd	s1,40(sp)
     140:	f04a                	sd	s2,32(sp)
     142:	ec4e                	sd	s3,24(sp)
     144:	e852                	sd	s4,16(sp)
     146:	0080                	addi	s0,sp,64
     148:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
     14a:	4901                	li	s2,0
     14c:	06400993          	li	s3,100
    pid = fork();
     150:	00005097          	auipc	ra,0x5
     154:	6fc080e7          	jalr	1788(ra) # 584c <fork>
     158:	84aa                	mv	s1,a0
    if(pid < 0){
     15a:	02054a63          	bltz	a0,18e <exitwait+0x56>
    if(pid){
     15e:	c151                	beqz	a0,1e2 <exitwait+0xaa>
      if(wait(&xstate) != pid){
     160:	fcc40513          	addi	a0,s0,-52
     164:	00005097          	auipc	ra,0x5
     168:	6f8080e7          	jalr	1784(ra) # 585c <wait>
     16c:	02951f63          	bne	a0,s1,1aa <exitwait+0x72>
      if(i != xstate) {
     170:	fcc42783          	lw	a5,-52(s0)
     174:	05279963          	bne	a5,s2,1c6 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
     178:	2905                	addiw	s2,s2,1
     17a:	fd391be3          	bne	s2,s3,150 <exitwait+0x18>
}
     17e:	70e2                	ld	ra,56(sp)
     180:	7442                	ld	s0,48(sp)
     182:	74a2                	ld	s1,40(sp)
     184:	7902                	ld	s2,32(sp)
     186:	69e2                	ld	s3,24(sp)
     188:	6a42                	ld	s4,16(sp)
     18a:	6121                	addi	sp,sp,64
     18c:	8082                	ret
      printf("%s: fork failed\n", s);
     18e:	85d2                	mv	a1,s4
     190:	00006517          	auipc	a0,0x6
     194:	ea850513          	addi	a0,a0,-344 # 6038 <malloc+0x376>
     198:	00006097          	auipc	ra,0x6
     19c:	a6c080e7          	jalr	-1428(ra) # 5c04 <printf>
      exit(1);
     1a0:	4505                	li	a0,1
     1a2:	00005097          	auipc	ra,0x5
     1a6:	6b2080e7          	jalr	1714(ra) # 5854 <exit>
        printf("%s: wait wrong pid\n", s);
     1aa:	85d2                	mv	a1,s4
     1ac:	00006517          	auipc	a0,0x6
     1b0:	ea450513          	addi	a0,a0,-348 # 6050 <malloc+0x38e>
     1b4:	00006097          	auipc	ra,0x6
     1b8:	a50080e7          	jalr	-1456(ra) # 5c04 <printf>
        exit(1);
     1bc:	4505                	li	a0,1
     1be:	00005097          	auipc	ra,0x5
     1c2:	696080e7          	jalr	1686(ra) # 5854 <exit>
        printf("%s: wait wrong exit status\n", s);
     1c6:	85d2                	mv	a1,s4
     1c8:	00006517          	auipc	a0,0x6
     1cc:	ea050513          	addi	a0,a0,-352 # 6068 <malloc+0x3a6>
     1d0:	00006097          	auipc	ra,0x6
     1d4:	a34080e7          	jalr	-1484(ra) # 5c04 <printf>
        exit(1);
     1d8:	4505                	li	a0,1
     1da:	00005097          	auipc	ra,0x5
     1de:	67a080e7          	jalr	1658(ra) # 5854 <exit>
      exit(i);
     1e2:	854a                	mv	a0,s2
     1e4:	00005097          	auipc	ra,0x5
     1e8:	670080e7          	jalr	1648(ra) # 5854 <exit>

00000000000001ec <twochildren>:
{
     1ec:	1101                	addi	sp,sp,-32
     1ee:	ec06                	sd	ra,24(sp)
     1f0:	e822                	sd	s0,16(sp)
     1f2:	e426                	sd	s1,8(sp)
     1f4:	e04a                	sd	s2,0(sp)
     1f6:	1000                	addi	s0,sp,32
     1f8:	892a                	mv	s2,a0
     1fa:	3e800493          	li	s1,1000
    int pid1 = fork();
     1fe:	00005097          	auipc	ra,0x5
     202:	64e080e7          	jalr	1614(ra) # 584c <fork>
    if(pid1 < 0){
     206:	02054c63          	bltz	a0,23e <twochildren+0x52>
    if(pid1 == 0){
     20a:	c921                	beqz	a0,25a <twochildren+0x6e>
      int pid2 = fork();
     20c:	00005097          	auipc	ra,0x5
     210:	640080e7          	jalr	1600(ra) # 584c <fork>
      if(pid2 < 0){
     214:	04054763          	bltz	a0,262 <twochildren+0x76>
      if(pid2 == 0){
     218:	c13d                	beqz	a0,27e <twochildren+0x92>
        wait(0);
     21a:	4501                	li	a0,0
     21c:	00005097          	auipc	ra,0x5
     220:	640080e7          	jalr	1600(ra) # 585c <wait>
        wait(0);
     224:	4501                	li	a0,0
     226:	00005097          	auipc	ra,0x5
     22a:	636080e7          	jalr	1590(ra) # 585c <wait>
  for(int i = 0; i < 1000; i++){
     22e:	34fd                	addiw	s1,s1,-1
     230:	f4f9                	bnez	s1,1fe <twochildren+0x12>
}
     232:	60e2                	ld	ra,24(sp)
     234:	6442                	ld	s0,16(sp)
     236:	64a2                	ld	s1,8(sp)
     238:	6902                	ld	s2,0(sp)
     23a:	6105                	addi	sp,sp,32
     23c:	8082                	ret
      printf("%s: fork failed\n", s);
     23e:	85ca                	mv	a1,s2
     240:	00006517          	auipc	a0,0x6
     244:	df850513          	addi	a0,a0,-520 # 6038 <malloc+0x376>
     248:	00006097          	auipc	ra,0x6
     24c:	9bc080e7          	jalr	-1604(ra) # 5c04 <printf>
      exit(1);
     250:	4505                	li	a0,1
     252:	00005097          	auipc	ra,0x5
     256:	602080e7          	jalr	1538(ra) # 5854 <exit>
      exit(0);
     25a:	00005097          	auipc	ra,0x5
     25e:	5fa080e7          	jalr	1530(ra) # 5854 <exit>
        printf("%s: fork failed\n", s);
     262:	85ca                	mv	a1,s2
     264:	00006517          	auipc	a0,0x6
     268:	dd450513          	addi	a0,a0,-556 # 6038 <malloc+0x376>
     26c:	00006097          	auipc	ra,0x6
     270:	998080e7          	jalr	-1640(ra) # 5c04 <printf>
        exit(1);
     274:	4505                	li	a0,1
     276:	00005097          	auipc	ra,0x5
     27a:	5de080e7          	jalr	1502(ra) # 5854 <exit>
        exit(0);
     27e:	00005097          	auipc	ra,0x5
     282:	5d6080e7          	jalr	1494(ra) # 5854 <exit>

0000000000000286 <forkfork>:
{
     286:	7179                	addi	sp,sp,-48
     288:	f406                	sd	ra,40(sp)
     28a:	f022                	sd	s0,32(sp)
     28c:	ec26                	sd	s1,24(sp)
     28e:	1800                	addi	s0,sp,48
     290:	84aa                	mv	s1,a0
    int pid = fork();
     292:	00005097          	auipc	ra,0x5
     296:	5ba080e7          	jalr	1466(ra) # 584c <fork>
    if(pid < 0){
     29a:	04054163          	bltz	a0,2dc <forkfork+0x56>
    if(pid == 0){
     29e:	cd29                	beqz	a0,2f8 <forkfork+0x72>
    int pid = fork();
     2a0:	00005097          	auipc	ra,0x5
     2a4:	5ac080e7          	jalr	1452(ra) # 584c <fork>
    if(pid < 0){
     2a8:	02054a63          	bltz	a0,2dc <forkfork+0x56>
    if(pid == 0){
     2ac:	c531                	beqz	a0,2f8 <forkfork+0x72>
    wait(&xstatus);
     2ae:	fdc40513          	addi	a0,s0,-36
     2b2:	00005097          	auipc	ra,0x5
     2b6:	5aa080e7          	jalr	1450(ra) # 585c <wait>
    if(xstatus != 0) {
     2ba:	fdc42783          	lw	a5,-36(s0)
     2be:	ebbd                	bnez	a5,334 <forkfork+0xae>
    wait(&xstatus);
     2c0:	fdc40513          	addi	a0,s0,-36
     2c4:	00005097          	auipc	ra,0x5
     2c8:	598080e7          	jalr	1432(ra) # 585c <wait>
    if(xstatus != 0) {
     2cc:	fdc42783          	lw	a5,-36(s0)
     2d0:	e3b5                	bnez	a5,334 <forkfork+0xae>
}
     2d2:	70a2                	ld	ra,40(sp)
     2d4:	7402                	ld	s0,32(sp)
     2d6:	64e2                	ld	s1,24(sp)
     2d8:	6145                	addi	sp,sp,48
     2da:	8082                	ret
      printf("%s: fork failed", s);
     2dc:	85a6                	mv	a1,s1
     2de:	00006517          	auipc	a0,0x6
     2e2:	daa50513          	addi	a0,a0,-598 # 6088 <malloc+0x3c6>
     2e6:	00006097          	auipc	ra,0x6
     2ea:	91e080e7          	jalr	-1762(ra) # 5c04 <printf>
      exit(1);
     2ee:	4505                	li	a0,1
     2f0:	00005097          	auipc	ra,0x5
     2f4:	564080e7          	jalr	1380(ra) # 5854 <exit>
{
     2f8:	0c800493          	li	s1,200
        int pid1 = fork();
     2fc:	00005097          	auipc	ra,0x5
     300:	550080e7          	jalr	1360(ra) # 584c <fork>
        if(pid1 < 0){
     304:	00054f63          	bltz	a0,322 <forkfork+0x9c>
        if(pid1 == 0){
     308:	c115                	beqz	a0,32c <forkfork+0xa6>
        wait(0);
     30a:	4501                	li	a0,0
     30c:	00005097          	auipc	ra,0x5
     310:	550080e7          	jalr	1360(ra) # 585c <wait>
      for(int j = 0; j < 200; j++){
     314:	34fd                	addiw	s1,s1,-1
     316:	f0fd                	bnez	s1,2fc <forkfork+0x76>
      exit(0);
     318:	4501                	li	a0,0
     31a:	00005097          	auipc	ra,0x5
     31e:	53a080e7          	jalr	1338(ra) # 5854 <exit>
          exit(1);
     322:	4505                	li	a0,1
     324:	00005097          	auipc	ra,0x5
     328:	530080e7          	jalr	1328(ra) # 5854 <exit>
          exit(0);
     32c:	00005097          	auipc	ra,0x5
     330:	528080e7          	jalr	1320(ra) # 5854 <exit>
      printf("%s: fork in child failed", s);
     334:	85a6                	mv	a1,s1
     336:	00006517          	auipc	a0,0x6
     33a:	d6250513          	addi	a0,a0,-670 # 6098 <malloc+0x3d6>
     33e:	00006097          	auipc	ra,0x6
     342:	8c6080e7          	jalr	-1850(ra) # 5c04 <printf>
      exit(1);
     346:	4505                	li	a0,1
     348:	00005097          	auipc	ra,0x5
     34c:	50c080e7          	jalr	1292(ra) # 5854 <exit>

0000000000000350 <forktest>:
{
     350:	7179                	addi	sp,sp,-48
     352:	f406                	sd	ra,40(sp)
     354:	f022                	sd	s0,32(sp)
     356:	ec26                	sd	s1,24(sp)
     358:	e84a                	sd	s2,16(sp)
     35a:	e44e                	sd	s3,8(sp)
     35c:	1800                	addi	s0,sp,48
     35e:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
     360:	4481                	li	s1,0
     362:	3e800913          	li	s2,1000
    pid = fork();
     366:	00005097          	auipc	ra,0x5
     36a:	4e6080e7          	jalr	1254(ra) # 584c <fork>
    if(pid < 0)
     36e:	02054863          	bltz	a0,39e <forktest+0x4e>
    if(pid == 0)
     372:	c115                	beqz	a0,396 <forktest+0x46>
  for(n=0; n<N; n++){
     374:	2485                	addiw	s1,s1,1
     376:	ff2498e3          	bne	s1,s2,366 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
     37a:	85ce                	mv	a1,s3
     37c:	00006517          	auipc	a0,0x6
     380:	d5450513          	addi	a0,a0,-684 # 60d0 <malloc+0x40e>
     384:	00006097          	auipc	ra,0x6
     388:	880080e7          	jalr	-1920(ra) # 5c04 <printf>
    exit(1);
     38c:	4505                	li	a0,1
     38e:	00005097          	auipc	ra,0x5
     392:	4c6080e7          	jalr	1222(ra) # 5854 <exit>
      exit(0);
     396:	00005097          	auipc	ra,0x5
     39a:	4be080e7          	jalr	1214(ra) # 5854 <exit>
  if (n == 0) {
     39e:	cc9d                	beqz	s1,3dc <forktest+0x8c>
  if(n == N){
     3a0:	3e800793          	li	a5,1000
     3a4:	fcf48be3          	beq	s1,a5,37a <forktest+0x2a>
  for(; n > 0; n--){
     3a8:	00905b63          	blez	s1,3be <forktest+0x6e>
    if(wait(0) < 0){
     3ac:	4501                	li	a0,0
     3ae:	00005097          	auipc	ra,0x5
     3b2:	4ae080e7          	jalr	1198(ra) # 585c <wait>
     3b6:	04054163          	bltz	a0,3f8 <forktest+0xa8>
  for(; n > 0; n--){
     3ba:	34fd                	addiw	s1,s1,-1
     3bc:	f8e5                	bnez	s1,3ac <forktest+0x5c>
  if(wait(0) != -1){
     3be:	4501                	li	a0,0
     3c0:	00005097          	auipc	ra,0x5
     3c4:	49c080e7          	jalr	1180(ra) # 585c <wait>
     3c8:	57fd                	li	a5,-1
     3ca:	04f51563          	bne	a0,a5,414 <forktest+0xc4>
}
     3ce:	70a2                	ld	ra,40(sp)
     3d0:	7402                	ld	s0,32(sp)
     3d2:	64e2                	ld	s1,24(sp)
     3d4:	6942                	ld	s2,16(sp)
     3d6:	69a2                	ld	s3,8(sp)
     3d8:	6145                	addi	sp,sp,48
     3da:	8082                	ret
    printf("%s: no fork at all!\n", s);
     3dc:	85ce                	mv	a1,s3
     3de:	00006517          	auipc	a0,0x6
     3e2:	cda50513          	addi	a0,a0,-806 # 60b8 <malloc+0x3f6>
     3e6:	00006097          	auipc	ra,0x6
     3ea:	81e080e7          	jalr	-2018(ra) # 5c04 <printf>
    exit(1);
     3ee:	4505                	li	a0,1
     3f0:	00005097          	auipc	ra,0x5
     3f4:	464080e7          	jalr	1124(ra) # 5854 <exit>
      printf("%s: wait stopped early\n", s);
     3f8:	85ce                	mv	a1,s3
     3fa:	00006517          	auipc	a0,0x6
     3fe:	cfe50513          	addi	a0,a0,-770 # 60f8 <malloc+0x436>
     402:	00006097          	auipc	ra,0x6
     406:	802080e7          	jalr	-2046(ra) # 5c04 <printf>
      exit(1);
     40a:	4505                	li	a0,1
     40c:	00005097          	auipc	ra,0x5
     410:	448080e7          	jalr	1096(ra) # 5854 <exit>
    printf("%s: wait got too many\n", s);
     414:	85ce                	mv	a1,s3
     416:	00006517          	auipc	a0,0x6
     41a:	cfa50513          	addi	a0,a0,-774 # 6110 <malloc+0x44e>
     41e:	00005097          	auipc	ra,0x5
     422:	7e6080e7          	jalr	2022(ra) # 5c04 <printf>
    exit(1);
     426:	4505                	li	a0,1
     428:	00005097          	auipc	ra,0x5
     42c:	42c080e7          	jalr	1068(ra) # 5854 <exit>

0000000000000430 <thread_test>:
void thread_test(char *s){
     430:	7179                	addi	sp,sp,-48
     432:	f406                	sd	ra,40(sp)
     434:	f022                	sd	s0,32(sp)
     436:	ec26                	sd	s1,24(sp)
     438:	e84a                	sd	s2,16(sp)
     43a:	1800                	addi	s0,sp,48
    void* stack = malloc(4000);
     43c:	6505                	lui	a0,0x1
     43e:	fa050513          	addi	a0,a0,-96 # fa0 <preempt+0xd8>
     442:	00006097          	auipc	ra,0x6
     446:	880080e7          	jalr	-1920(ra) # 5cc2 <malloc>
     44a:	84aa                	mv	s1,a0
    printf("after malloc\n");
     44c:	00006517          	auipc	a0,0x6
     450:	cdc50513          	addi	a0,a0,-804 # 6128 <malloc+0x466>
     454:	00005097          	auipc	ra,0x5
     458:	7b0080e7          	jalr	1968(ra) # 5c04 <printf>
    tid = kthread_create(test_thread, stack);
     45c:	85a6                	mv	a1,s1
     45e:	00000517          	auipc	a0,0x0
     462:	bcc50513          	addi	a0,a0,-1076 # 2a <test_thread>
     466:	00005097          	auipc	ra,0x5
     46a:	4a6080e7          	jalr	1190(ra) # 590c <kthread_create>
     46e:	892a                	mv	s2,a0
    printf("after create \n");
     470:	00006517          	auipc	a0,0x6
     474:	cc850513          	addi	a0,a0,-824 # 6138 <malloc+0x476>
     478:	00005097          	auipc	ra,0x5
     47c:	78c080e7          	jalr	1932(ra) # 5c04 <printf>
    kthread_join(tid, &status);
     480:	fdc40593          	addi	a1,s0,-36
     484:	854a                	mv	a0,s2
     486:	00005097          	auipc	ra,0x5
     48a:	49e080e7          	jalr	1182(ra) # 5924 <kthread_join>
    printf("after kthread\n");
     48e:	00006517          	auipc	a0,0x6
     492:	cba50513          	addi	a0,a0,-838 # 6148 <malloc+0x486>
     496:	00005097          	auipc	ra,0x5
     49a:	76e080e7          	jalr	1902(ra) # 5c04 <printf>
    tid = kthread_id();
     49e:	00005097          	auipc	ra,0x5
     4a2:	476080e7          	jalr	1142(ra) # 5914 <kthread_id>
     4a6:	892a                	mv	s2,a0
    free(stack);
     4a8:	8526                	mv	a0,s1
     4aa:	00005097          	auipc	ra,0x5
     4ae:	790080e7          	jalr	1936(ra) # 5c3a <free>
    printf("Finished testing threads, main thread id: %d, %d\n", tid,status);
     4b2:	fdc42603          	lw	a2,-36(s0)
     4b6:	85ca                	mv	a1,s2
     4b8:	00006517          	auipc	a0,0x6
     4bc:	ca050513          	addi	a0,a0,-864 # 6158 <malloc+0x496>
     4c0:	00005097          	auipc	ra,0x5
     4c4:	744080e7          	jalr	1860(ra) # 5c04 <printf>
}
     4c8:	70a2                	ld	ra,40(sp)
     4ca:	7402                	ld	s0,32(sp)
     4cc:	64e2                	ld	s1,24(sp)
     4ce:	6942                	ld	s2,16(sp)
     4d0:	6145                	addi	sp,sp,48
     4d2:	8082                	ret

00000000000004d4 <copyinstr1>:
{
     4d4:	1141                	addi	sp,sp,-16
     4d6:	e406                	sd	ra,8(sp)
     4d8:	e022                	sd	s0,0(sp)
     4da:	0800                	addi	s0,sp,16
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
     4dc:	20100593          	li	a1,513
     4e0:	4505                	li	a0,1
     4e2:	057e                	slli	a0,a0,0x1f
     4e4:	00005097          	auipc	ra,0x5
     4e8:	3b0080e7          	jalr	944(ra) # 5894 <open>
    if(fd >= 0){
     4ec:	02055063          	bgez	a0,50c <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
     4f0:	20100593          	li	a1,513
     4f4:	557d                	li	a0,-1
     4f6:	00005097          	auipc	ra,0x5
     4fa:	39e080e7          	jalr	926(ra) # 5894 <open>
    uint64 addr = addrs[ai];
     4fe:	55fd                	li	a1,-1
    if(fd >= 0){
     500:	00055863          	bgez	a0,510 <copyinstr1+0x3c>
}
     504:	60a2                	ld	ra,8(sp)
     506:	6402                	ld	s0,0(sp)
     508:	0141                	addi	sp,sp,16
     50a:	8082                	ret
    uint64 addr = addrs[ai];
     50c:	4585                	li	a1,1
     50e:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
     510:	862a                	mv	a2,a0
     512:	00006517          	auipc	a0,0x6
     516:	c7e50513          	addi	a0,a0,-898 # 6190 <malloc+0x4ce>
     51a:	00005097          	auipc	ra,0x5
     51e:	6ea080e7          	jalr	1770(ra) # 5c04 <printf>
      exit(1);
     522:	4505                	li	a0,1
     524:	00005097          	auipc	ra,0x5
     528:	330080e7          	jalr	816(ra) # 5854 <exit>

000000000000052c <opentest>:
{
     52c:	1101                	addi	sp,sp,-32
     52e:	ec06                	sd	ra,24(sp)
     530:	e822                	sd	s0,16(sp)
     532:	e426                	sd	s1,8(sp)
     534:	1000                	addi	s0,sp,32
     536:	84aa                	mv	s1,a0
  fd = open("echo", 0);
     538:	4581                	li	a1,0
     53a:	00006517          	auipc	a0,0x6
     53e:	c7650513          	addi	a0,a0,-906 # 61b0 <malloc+0x4ee>
     542:	00005097          	auipc	ra,0x5
     546:	352080e7          	jalr	850(ra) # 5894 <open>
  if(fd < 0){
     54a:	02054663          	bltz	a0,576 <opentest+0x4a>
  close(fd);
     54e:	00005097          	auipc	ra,0x5
     552:	32e080e7          	jalr	814(ra) # 587c <close>
  fd = open("doesnotexist", 0);
     556:	4581                	li	a1,0
     558:	00006517          	auipc	a0,0x6
     55c:	c7850513          	addi	a0,a0,-904 # 61d0 <malloc+0x50e>
     560:	00005097          	auipc	ra,0x5
     564:	334080e7          	jalr	820(ra) # 5894 <open>
  if(fd >= 0){
     568:	02055563          	bgez	a0,592 <opentest+0x66>
}
     56c:	60e2                	ld	ra,24(sp)
     56e:	6442                	ld	s0,16(sp)
     570:	64a2                	ld	s1,8(sp)
     572:	6105                	addi	sp,sp,32
     574:	8082                	ret
    printf("%s: open echo failed!\n", s);
     576:	85a6                	mv	a1,s1
     578:	00006517          	auipc	a0,0x6
     57c:	c4050513          	addi	a0,a0,-960 # 61b8 <malloc+0x4f6>
     580:	00005097          	auipc	ra,0x5
     584:	684080e7          	jalr	1668(ra) # 5c04 <printf>
    exit(1);
     588:	4505                	li	a0,1
     58a:	00005097          	auipc	ra,0x5
     58e:	2ca080e7          	jalr	714(ra) # 5854 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     592:	85a6                	mv	a1,s1
     594:	00006517          	auipc	a0,0x6
     598:	c4c50513          	addi	a0,a0,-948 # 61e0 <malloc+0x51e>
     59c:	00005097          	auipc	ra,0x5
     5a0:	668080e7          	jalr	1640(ra) # 5c04 <printf>
    exit(1);
     5a4:	4505                	li	a0,1
     5a6:	00005097          	auipc	ra,0x5
     5aa:	2ae080e7          	jalr	686(ra) # 5854 <exit>

00000000000005ae <truncate2>:
{
     5ae:	7179                	addi	sp,sp,-48
     5b0:	f406                	sd	ra,40(sp)
     5b2:	f022                	sd	s0,32(sp)
     5b4:	ec26                	sd	s1,24(sp)
     5b6:	e84a                	sd	s2,16(sp)
     5b8:	e44e                	sd	s3,8(sp)
     5ba:	1800                	addi	s0,sp,48
     5bc:	89aa                	mv	s3,a0
  unlink("truncfile");
     5be:	00006517          	auipc	a0,0x6
     5c2:	c4a50513          	addi	a0,a0,-950 # 6208 <malloc+0x546>
     5c6:	00005097          	auipc	ra,0x5
     5ca:	2de080e7          	jalr	734(ra) # 58a4 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     5ce:	60100593          	li	a1,1537
     5d2:	00006517          	auipc	a0,0x6
     5d6:	c3650513          	addi	a0,a0,-970 # 6208 <malloc+0x546>
     5da:	00005097          	auipc	ra,0x5
     5de:	2ba080e7          	jalr	698(ra) # 5894 <open>
     5e2:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     5e4:	4611                	li	a2,4
     5e6:	00006597          	auipc	a1,0x6
     5ea:	c3258593          	addi	a1,a1,-974 # 6218 <malloc+0x556>
     5ee:	00005097          	auipc	ra,0x5
     5f2:	286080e7          	jalr	646(ra) # 5874 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     5f6:	40100593          	li	a1,1025
     5fa:	00006517          	auipc	a0,0x6
     5fe:	c0e50513          	addi	a0,a0,-1010 # 6208 <malloc+0x546>
     602:	00005097          	auipc	ra,0x5
     606:	292080e7          	jalr	658(ra) # 5894 <open>
     60a:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     60c:	4605                	li	a2,1
     60e:	00006597          	auipc	a1,0x6
     612:	c1258593          	addi	a1,a1,-1006 # 6220 <malloc+0x55e>
     616:	8526                	mv	a0,s1
     618:	00005097          	auipc	ra,0x5
     61c:	25c080e7          	jalr	604(ra) # 5874 <write>
  if(n != -1){
     620:	57fd                	li	a5,-1
     622:	02f51b63          	bne	a0,a5,658 <truncate2+0xaa>
  unlink("truncfile");
     626:	00006517          	auipc	a0,0x6
     62a:	be250513          	addi	a0,a0,-1054 # 6208 <malloc+0x546>
     62e:	00005097          	auipc	ra,0x5
     632:	276080e7          	jalr	630(ra) # 58a4 <unlink>
  close(fd1);
     636:	8526                	mv	a0,s1
     638:	00005097          	auipc	ra,0x5
     63c:	244080e7          	jalr	580(ra) # 587c <close>
  close(fd2);
     640:	854a                	mv	a0,s2
     642:	00005097          	auipc	ra,0x5
     646:	23a080e7          	jalr	570(ra) # 587c <close>
}
     64a:	70a2                	ld	ra,40(sp)
     64c:	7402                	ld	s0,32(sp)
     64e:	64e2                	ld	s1,24(sp)
     650:	6942                	ld	s2,16(sp)
     652:	69a2                	ld	s3,8(sp)
     654:	6145                	addi	sp,sp,48
     656:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     658:	862a                	mv	a2,a0
     65a:	85ce                	mv	a1,s3
     65c:	00006517          	auipc	a0,0x6
     660:	bcc50513          	addi	a0,a0,-1076 # 6228 <malloc+0x566>
     664:	00005097          	auipc	ra,0x5
     668:	5a0080e7          	jalr	1440(ra) # 5c04 <printf>
    exit(1);
     66c:	4505                	li	a0,1
     66e:	00005097          	auipc	ra,0x5
     672:	1e6080e7          	jalr	486(ra) # 5854 <exit>

0000000000000676 <forkforkfork>:
{
     676:	1101                	addi	sp,sp,-32
     678:	ec06                	sd	ra,24(sp)
     67a:	e822                	sd	s0,16(sp)
     67c:	e426                	sd	s1,8(sp)
     67e:	1000                	addi	s0,sp,32
     680:	84aa                	mv	s1,a0
  unlink("stopforking");
     682:	00006517          	auipc	a0,0x6
     686:	bce50513          	addi	a0,a0,-1074 # 6250 <malloc+0x58e>
     68a:	00005097          	auipc	ra,0x5
     68e:	21a080e7          	jalr	538(ra) # 58a4 <unlink>
  int pid = fork();
     692:	00005097          	auipc	ra,0x5
     696:	1ba080e7          	jalr	442(ra) # 584c <fork>
  if(pid < 0){
     69a:	04054563          	bltz	a0,6e4 <forkforkfork+0x6e>
  if(pid == 0){
     69e:	c12d                	beqz	a0,700 <forkforkfork+0x8a>
  sleep(20); // two seconds
     6a0:	4551                	li	a0,20
     6a2:	00005097          	auipc	ra,0x5
     6a6:	242080e7          	jalr	578(ra) # 58e4 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
     6aa:	20200593          	li	a1,514
     6ae:	00006517          	auipc	a0,0x6
     6b2:	ba250513          	addi	a0,a0,-1118 # 6250 <malloc+0x58e>
     6b6:	00005097          	auipc	ra,0x5
     6ba:	1de080e7          	jalr	478(ra) # 5894 <open>
     6be:	00005097          	auipc	ra,0x5
     6c2:	1be080e7          	jalr	446(ra) # 587c <close>
  wait(0);
     6c6:	4501                	li	a0,0
     6c8:	00005097          	auipc	ra,0x5
     6cc:	194080e7          	jalr	404(ra) # 585c <wait>
  sleep(10); // one second
     6d0:	4529                	li	a0,10
     6d2:	00005097          	auipc	ra,0x5
     6d6:	212080e7          	jalr	530(ra) # 58e4 <sleep>
}
     6da:	60e2                	ld	ra,24(sp)
     6dc:	6442                	ld	s0,16(sp)
     6de:	64a2                	ld	s1,8(sp)
     6e0:	6105                	addi	sp,sp,32
     6e2:	8082                	ret
    printf("%s: fork failed", s);
     6e4:	85a6                	mv	a1,s1
     6e6:	00006517          	auipc	a0,0x6
     6ea:	9a250513          	addi	a0,a0,-1630 # 6088 <malloc+0x3c6>
     6ee:	00005097          	auipc	ra,0x5
     6f2:	516080e7          	jalr	1302(ra) # 5c04 <printf>
    exit(1);
     6f6:	4505                	li	a0,1
     6f8:	00005097          	auipc	ra,0x5
     6fc:	15c080e7          	jalr	348(ra) # 5854 <exit>
      int fd = open("stopforking", 0);
     700:	00006497          	auipc	s1,0x6
     704:	b5048493          	addi	s1,s1,-1200 # 6250 <malloc+0x58e>
     708:	4581                	li	a1,0
     70a:	8526                	mv	a0,s1
     70c:	00005097          	auipc	ra,0x5
     710:	188080e7          	jalr	392(ra) # 5894 <open>
      if(fd >= 0){
     714:	02055463          	bgez	a0,73c <forkforkfork+0xc6>
      if(fork() < 0){
     718:	00005097          	auipc	ra,0x5
     71c:	134080e7          	jalr	308(ra) # 584c <fork>
     720:	fe0554e3          	bgez	a0,708 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
     724:	20200593          	li	a1,514
     728:	8526                	mv	a0,s1
     72a:	00005097          	auipc	ra,0x5
     72e:	16a080e7          	jalr	362(ra) # 5894 <open>
     732:	00005097          	auipc	ra,0x5
     736:	14a080e7          	jalr	330(ra) # 587c <close>
     73a:	b7f9                	j	708 <forkforkfork+0x92>
        exit(0);
     73c:	4501                	li	a0,0
     73e:	00005097          	auipc	ra,0x5
     742:	116080e7          	jalr	278(ra) # 5854 <exit>

0000000000000746 <bigwrite>:
{
     746:	715d                	addi	sp,sp,-80
     748:	e486                	sd	ra,72(sp)
     74a:	e0a2                	sd	s0,64(sp)
     74c:	fc26                	sd	s1,56(sp)
     74e:	f84a                	sd	s2,48(sp)
     750:	f44e                	sd	s3,40(sp)
     752:	f052                	sd	s4,32(sp)
     754:	ec56                	sd	s5,24(sp)
     756:	e85a                	sd	s6,16(sp)
     758:	e45e                	sd	s7,8(sp)
     75a:	0880                	addi	s0,sp,80
     75c:	8baa                	mv	s7,a0
  unlink("bigwrite");
     75e:	00005517          	auipc	a0,0x5
     762:	7b250513          	addi	a0,a0,1970 # 5f10 <malloc+0x24e>
     766:	00005097          	auipc	ra,0x5
     76a:	13e080e7          	jalr	318(ra) # 58a4 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     76e:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     772:	00005a97          	auipc	s5,0x5
     776:	79ea8a93          	addi	s5,s5,1950 # 5f10 <malloc+0x24e>
      int cc = write(fd, buf, sz);
     77a:	0000ba17          	auipc	s4,0xb
     77e:	476a0a13          	addi	s4,s4,1142 # bbf0 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     782:	6b0d                	lui	s6,0x3
     784:	1c9b0b13          	addi	s6,s6,457 # 31c9 <bigfile+0x3>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     788:	20200593          	li	a1,514
     78c:	8556                	mv	a0,s5
     78e:	00005097          	auipc	ra,0x5
     792:	106080e7          	jalr	262(ra) # 5894 <open>
     796:	892a                	mv	s2,a0
    if(fd < 0){
     798:	04054d63          	bltz	a0,7f2 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     79c:	8626                	mv	a2,s1
     79e:	85d2                	mv	a1,s4
     7a0:	00005097          	auipc	ra,0x5
     7a4:	0d4080e7          	jalr	212(ra) # 5874 <write>
     7a8:	89aa                	mv	s3,a0
      if(cc != sz){
     7aa:	06a49463          	bne	s1,a0,812 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     7ae:	8626                	mv	a2,s1
     7b0:	85d2                	mv	a1,s4
     7b2:	854a                	mv	a0,s2
     7b4:	00005097          	auipc	ra,0x5
     7b8:	0c0080e7          	jalr	192(ra) # 5874 <write>
      if(cc != sz){
     7bc:	04951963          	bne	a0,s1,80e <bigwrite+0xc8>
    close(fd);
     7c0:	854a                	mv	a0,s2
     7c2:	00005097          	auipc	ra,0x5
     7c6:	0ba080e7          	jalr	186(ra) # 587c <close>
    unlink("bigwrite");
     7ca:	8556                	mv	a0,s5
     7cc:	00005097          	auipc	ra,0x5
     7d0:	0d8080e7          	jalr	216(ra) # 58a4 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     7d4:	1d74849b          	addiw	s1,s1,471
     7d8:	fb6498e3          	bne	s1,s6,788 <bigwrite+0x42>
}
     7dc:	60a6                	ld	ra,72(sp)
     7de:	6406                	ld	s0,64(sp)
     7e0:	74e2                	ld	s1,56(sp)
     7e2:	7942                	ld	s2,48(sp)
     7e4:	79a2                	ld	s3,40(sp)
     7e6:	7a02                	ld	s4,32(sp)
     7e8:	6ae2                	ld	s5,24(sp)
     7ea:	6b42                	ld	s6,16(sp)
     7ec:	6ba2                	ld	s7,8(sp)
     7ee:	6161                	addi	sp,sp,80
     7f0:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     7f2:	85de                	mv	a1,s7
     7f4:	00006517          	auipc	a0,0x6
     7f8:	a6c50513          	addi	a0,a0,-1428 # 6260 <malloc+0x59e>
     7fc:	00005097          	auipc	ra,0x5
     800:	408080e7          	jalr	1032(ra) # 5c04 <printf>
      exit(1);
     804:	4505                	li	a0,1
     806:	00005097          	auipc	ra,0x5
     80a:	04e080e7          	jalr	78(ra) # 5854 <exit>
     80e:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     810:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     812:	86ce                	mv	a3,s3
     814:	8626                	mv	a2,s1
     816:	85de                	mv	a1,s7
     818:	00006517          	auipc	a0,0x6
     81c:	a6850513          	addi	a0,a0,-1432 # 6280 <malloc+0x5be>
     820:	00005097          	auipc	ra,0x5
     824:	3e4080e7          	jalr	996(ra) # 5c04 <printf>
        exit(1);
     828:	4505                	li	a0,1
     82a:	00005097          	auipc	ra,0x5
     82e:	02a080e7          	jalr	42(ra) # 5854 <exit>

0000000000000832 <copyin>:
{
     832:	715d                	addi	sp,sp,-80
     834:	e486                	sd	ra,72(sp)
     836:	e0a2                	sd	s0,64(sp)
     838:	fc26                	sd	s1,56(sp)
     83a:	f84a                	sd	s2,48(sp)
     83c:	f44e                	sd	s3,40(sp)
     83e:	f052                	sd	s4,32(sp)
     840:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     842:	4785                	li	a5,1
     844:	07fe                	slli	a5,a5,0x1f
     846:	fcf43023          	sd	a5,-64(s0)
     84a:	57fd                	li	a5,-1
     84c:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     850:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     854:	00006a17          	auipc	s4,0x6
     858:	a44a0a13          	addi	s4,s4,-1468 # 6298 <malloc+0x5d6>
    uint64 addr = addrs[ai];
     85c:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     860:	20100593          	li	a1,513
     864:	8552                	mv	a0,s4
     866:	00005097          	auipc	ra,0x5
     86a:	02e080e7          	jalr	46(ra) # 5894 <open>
     86e:	84aa                	mv	s1,a0
    if(fd < 0){
     870:	08054863          	bltz	a0,900 <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     874:	6609                	lui	a2,0x2
     876:	85ce                	mv	a1,s3
     878:	00005097          	auipc	ra,0x5
     87c:	ffc080e7          	jalr	-4(ra) # 5874 <write>
    if(n >= 0){
     880:	08055d63          	bgez	a0,91a <copyin+0xe8>
    close(fd);
     884:	8526                	mv	a0,s1
     886:	00005097          	auipc	ra,0x5
     88a:	ff6080e7          	jalr	-10(ra) # 587c <close>
    unlink("copyin1");
     88e:	8552                	mv	a0,s4
     890:	00005097          	auipc	ra,0x5
     894:	014080e7          	jalr	20(ra) # 58a4 <unlink>
    n = write(1, (char*)addr, 8192);
     898:	6609                	lui	a2,0x2
     89a:	85ce                	mv	a1,s3
     89c:	4505                	li	a0,1
     89e:	00005097          	auipc	ra,0x5
     8a2:	fd6080e7          	jalr	-42(ra) # 5874 <write>
    if(n > 0){
     8a6:	08a04963          	bgtz	a0,938 <copyin+0x106>
    if(pipe(fds) < 0){
     8aa:	fb840513          	addi	a0,s0,-72
     8ae:	00005097          	auipc	ra,0x5
     8b2:	fb6080e7          	jalr	-74(ra) # 5864 <pipe>
     8b6:	0a054063          	bltz	a0,956 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     8ba:	6609                	lui	a2,0x2
     8bc:	85ce                	mv	a1,s3
     8be:	fbc42503          	lw	a0,-68(s0)
     8c2:	00005097          	auipc	ra,0x5
     8c6:	fb2080e7          	jalr	-78(ra) # 5874 <write>
    if(n > 0){
     8ca:	0aa04363          	bgtz	a0,970 <copyin+0x13e>
    close(fds[0]);
     8ce:	fb842503          	lw	a0,-72(s0)
     8d2:	00005097          	auipc	ra,0x5
     8d6:	faa080e7          	jalr	-86(ra) # 587c <close>
    close(fds[1]);
     8da:	fbc42503          	lw	a0,-68(s0)
     8de:	00005097          	auipc	ra,0x5
     8e2:	f9e080e7          	jalr	-98(ra) # 587c <close>
  for(int ai = 0; ai < 2; ai++){
     8e6:	0921                	addi	s2,s2,8
     8e8:	fd040793          	addi	a5,s0,-48
     8ec:	f6f918e3          	bne	s2,a5,85c <copyin+0x2a>
}
     8f0:	60a6                	ld	ra,72(sp)
     8f2:	6406                	ld	s0,64(sp)
     8f4:	74e2                	ld	s1,56(sp)
     8f6:	7942                	ld	s2,48(sp)
     8f8:	79a2                	ld	s3,40(sp)
     8fa:	7a02                	ld	s4,32(sp)
     8fc:	6161                	addi	sp,sp,80
     8fe:	8082                	ret
      printf("open(copyin1) failed\n");
     900:	00006517          	auipc	a0,0x6
     904:	9a050513          	addi	a0,a0,-1632 # 62a0 <malloc+0x5de>
     908:	00005097          	auipc	ra,0x5
     90c:	2fc080e7          	jalr	764(ra) # 5c04 <printf>
      exit(1);
     910:	4505                	li	a0,1
     912:	00005097          	auipc	ra,0x5
     916:	f42080e7          	jalr	-190(ra) # 5854 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     91a:	862a                	mv	a2,a0
     91c:	85ce                	mv	a1,s3
     91e:	00006517          	auipc	a0,0x6
     922:	99a50513          	addi	a0,a0,-1638 # 62b8 <malloc+0x5f6>
     926:	00005097          	auipc	ra,0x5
     92a:	2de080e7          	jalr	734(ra) # 5c04 <printf>
      exit(1);
     92e:	4505                	li	a0,1
     930:	00005097          	auipc	ra,0x5
     934:	f24080e7          	jalr	-220(ra) # 5854 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     938:	862a                	mv	a2,a0
     93a:	85ce                	mv	a1,s3
     93c:	00006517          	auipc	a0,0x6
     940:	9ac50513          	addi	a0,a0,-1620 # 62e8 <malloc+0x626>
     944:	00005097          	auipc	ra,0x5
     948:	2c0080e7          	jalr	704(ra) # 5c04 <printf>
      exit(1);
     94c:	4505                	li	a0,1
     94e:	00005097          	auipc	ra,0x5
     952:	f06080e7          	jalr	-250(ra) # 5854 <exit>
      printf("pipe() failed\n");
     956:	00006517          	auipc	a0,0x6
     95a:	9c250513          	addi	a0,a0,-1598 # 6318 <malloc+0x656>
     95e:	00005097          	auipc	ra,0x5
     962:	2a6080e7          	jalr	678(ra) # 5c04 <printf>
      exit(1);
     966:	4505                	li	a0,1
     968:	00005097          	auipc	ra,0x5
     96c:	eec080e7          	jalr	-276(ra) # 5854 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     970:	862a                	mv	a2,a0
     972:	85ce                	mv	a1,s3
     974:	00006517          	auipc	a0,0x6
     978:	9b450513          	addi	a0,a0,-1612 # 6328 <malloc+0x666>
     97c:	00005097          	auipc	ra,0x5
     980:	288080e7          	jalr	648(ra) # 5c04 <printf>
      exit(1);
     984:	4505                	li	a0,1
     986:	00005097          	auipc	ra,0x5
     98a:	ece080e7          	jalr	-306(ra) # 5854 <exit>

000000000000098e <copyout>:
{
     98e:	711d                	addi	sp,sp,-96
     990:	ec86                	sd	ra,88(sp)
     992:	e8a2                	sd	s0,80(sp)
     994:	e4a6                	sd	s1,72(sp)
     996:	e0ca                	sd	s2,64(sp)
     998:	fc4e                	sd	s3,56(sp)
     99a:	f852                	sd	s4,48(sp)
     99c:	f456                	sd	s5,40(sp)
     99e:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     9a0:	4785                	li	a5,1
     9a2:	07fe                	slli	a5,a5,0x1f
     9a4:	faf43823          	sd	a5,-80(s0)
     9a8:	57fd                	li	a5,-1
     9aa:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     9ae:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     9b2:	00006a17          	auipc	s4,0x6
     9b6:	9a6a0a13          	addi	s4,s4,-1626 # 6358 <malloc+0x696>
    n = write(fds[1], "x", 1);
     9ba:	00006a97          	auipc	s5,0x6
     9be:	866a8a93          	addi	s5,s5,-1946 # 6220 <malloc+0x55e>
    uint64 addr = addrs[ai];
     9c2:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     9c6:	4581                	li	a1,0
     9c8:	8552                	mv	a0,s4
     9ca:	00005097          	auipc	ra,0x5
     9ce:	eca080e7          	jalr	-310(ra) # 5894 <open>
     9d2:	84aa                	mv	s1,a0
    if(fd < 0){
     9d4:	08054663          	bltz	a0,a60 <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     9d8:	6609                	lui	a2,0x2
     9da:	85ce                	mv	a1,s3
     9dc:	00005097          	auipc	ra,0x5
     9e0:	e90080e7          	jalr	-368(ra) # 586c <read>
    if(n > 0){
     9e4:	08a04b63          	bgtz	a0,a7a <copyout+0xec>
    close(fd);
     9e8:	8526                	mv	a0,s1
     9ea:	00005097          	auipc	ra,0x5
     9ee:	e92080e7          	jalr	-366(ra) # 587c <close>
    if(pipe(fds) < 0){
     9f2:	fa840513          	addi	a0,s0,-88
     9f6:	00005097          	auipc	ra,0x5
     9fa:	e6e080e7          	jalr	-402(ra) # 5864 <pipe>
     9fe:	08054d63          	bltz	a0,a98 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     a02:	4605                	li	a2,1
     a04:	85d6                	mv	a1,s5
     a06:	fac42503          	lw	a0,-84(s0)
     a0a:	00005097          	auipc	ra,0x5
     a0e:	e6a080e7          	jalr	-406(ra) # 5874 <write>
    if(n != 1){
     a12:	4785                	li	a5,1
     a14:	08f51f63          	bne	a0,a5,ab2 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     a18:	6609                	lui	a2,0x2
     a1a:	85ce                	mv	a1,s3
     a1c:	fa842503          	lw	a0,-88(s0)
     a20:	00005097          	auipc	ra,0x5
     a24:	e4c080e7          	jalr	-436(ra) # 586c <read>
    if(n > 0){
     a28:	0aa04263          	bgtz	a0,acc <copyout+0x13e>
    close(fds[0]);
     a2c:	fa842503          	lw	a0,-88(s0)
     a30:	00005097          	auipc	ra,0x5
     a34:	e4c080e7          	jalr	-436(ra) # 587c <close>
    close(fds[1]);
     a38:	fac42503          	lw	a0,-84(s0)
     a3c:	00005097          	auipc	ra,0x5
     a40:	e40080e7          	jalr	-448(ra) # 587c <close>
  for(int ai = 0; ai < 2; ai++){
     a44:	0921                	addi	s2,s2,8
     a46:	fc040793          	addi	a5,s0,-64
     a4a:	f6f91ce3          	bne	s2,a5,9c2 <copyout+0x34>
}
     a4e:	60e6                	ld	ra,88(sp)
     a50:	6446                	ld	s0,80(sp)
     a52:	64a6                	ld	s1,72(sp)
     a54:	6906                	ld	s2,64(sp)
     a56:	79e2                	ld	s3,56(sp)
     a58:	7a42                	ld	s4,48(sp)
     a5a:	7aa2                	ld	s5,40(sp)
     a5c:	6125                	addi	sp,sp,96
     a5e:	8082                	ret
      printf("open(README) failed\n");
     a60:	00006517          	auipc	a0,0x6
     a64:	90050513          	addi	a0,a0,-1792 # 6360 <malloc+0x69e>
     a68:	00005097          	auipc	ra,0x5
     a6c:	19c080e7          	jalr	412(ra) # 5c04 <printf>
      exit(1);
     a70:	4505                	li	a0,1
     a72:	00005097          	auipc	ra,0x5
     a76:	de2080e7          	jalr	-542(ra) # 5854 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     a7a:	862a                	mv	a2,a0
     a7c:	85ce                	mv	a1,s3
     a7e:	00006517          	auipc	a0,0x6
     a82:	8fa50513          	addi	a0,a0,-1798 # 6378 <malloc+0x6b6>
     a86:	00005097          	auipc	ra,0x5
     a8a:	17e080e7          	jalr	382(ra) # 5c04 <printf>
      exit(1);
     a8e:	4505                	li	a0,1
     a90:	00005097          	auipc	ra,0x5
     a94:	dc4080e7          	jalr	-572(ra) # 5854 <exit>
      printf("pipe() failed\n");
     a98:	00006517          	auipc	a0,0x6
     a9c:	88050513          	addi	a0,a0,-1920 # 6318 <malloc+0x656>
     aa0:	00005097          	auipc	ra,0x5
     aa4:	164080e7          	jalr	356(ra) # 5c04 <printf>
      exit(1);
     aa8:	4505                	li	a0,1
     aaa:	00005097          	auipc	ra,0x5
     aae:	daa080e7          	jalr	-598(ra) # 5854 <exit>
      printf("pipe write failed\n");
     ab2:	00006517          	auipc	a0,0x6
     ab6:	8f650513          	addi	a0,a0,-1802 # 63a8 <malloc+0x6e6>
     aba:	00005097          	auipc	ra,0x5
     abe:	14a080e7          	jalr	330(ra) # 5c04 <printf>
      exit(1);
     ac2:	4505                	li	a0,1
     ac4:	00005097          	auipc	ra,0x5
     ac8:	d90080e7          	jalr	-624(ra) # 5854 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     acc:	862a                	mv	a2,a0
     ace:	85ce                	mv	a1,s3
     ad0:	00006517          	auipc	a0,0x6
     ad4:	8f050513          	addi	a0,a0,-1808 # 63c0 <malloc+0x6fe>
     ad8:	00005097          	auipc	ra,0x5
     adc:	12c080e7          	jalr	300(ra) # 5c04 <printf>
      exit(1);
     ae0:	4505                	li	a0,1
     ae2:	00005097          	auipc	ra,0x5
     ae6:	d72080e7          	jalr	-654(ra) # 5854 <exit>

0000000000000aea <truncate1>:
{
     aea:	711d                	addi	sp,sp,-96
     aec:	ec86                	sd	ra,88(sp)
     aee:	e8a2                	sd	s0,80(sp)
     af0:	e4a6                	sd	s1,72(sp)
     af2:	e0ca                	sd	s2,64(sp)
     af4:	fc4e                	sd	s3,56(sp)
     af6:	f852                	sd	s4,48(sp)
     af8:	f456                	sd	s5,40(sp)
     afa:	1080                	addi	s0,sp,96
     afc:	8aaa                	mv	s5,a0
  unlink("truncfile");
     afe:	00005517          	auipc	a0,0x5
     b02:	70a50513          	addi	a0,a0,1802 # 6208 <malloc+0x546>
     b06:	00005097          	auipc	ra,0x5
     b0a:	d9e080e7          	jalr	-610(ra) # 58a4 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     b0e:	60100593          	li	a1,1537
     b12:	00005517          	auipc	a0,0x5
     b16:	6f650513          	addi	a0,a0,1782 # 6208 <malloc+0x546>
     b1a:	00005097          	auipc	ra,0x5
     b1e:	d7a080e7          	jalr	-646(ra) # 5894 <open>
     b22:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     b24:	4611                	li	a2,4
     b26:	00005597          	auipc	a1,0x5
     b2a:	6f258593          	addi	a1,a1,1778 # 6218 <malloc+0x556>
     b2e:	00005097          	auipc	ra,0x5
     b32:	d46080e7          	jalr	-698(ra) # 5874 <write>
  close(fd1);
     b36:	8526                	mv	a0,s1
     b38:	00005097          	auipc	ra,0x5
     b3c:	d44080e7          	jalr	-700(ra) # 587c <close>
  int fd2 = open("truncfile", O_RDONLY);
     b40:	4581                	li	a1,0
     b42:	00005517          	auipc	a0,0x5
     b46:	6c650513          	addi	a0,a0,1734 # 6208 <malloc+0x546>
     b4a:	00005097          	auipc	ra,0x5
     b4e:	d4a080e7          	jalr	-694(ra) # 5894 <open>
     b52:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     b54:	02000613          	li	a2,32
     b58:	fa040593          	addi	a1,s0,-96
     b5c:	00005097          	auipc	ra,0x5
     b60:	d10080e7          	jalr	-752(ra) # 586c <read>
  if(n != 4){
     b64:	4791                	li	a5,4
     b66:	0cf51e63          	bne	a0,a5,c42 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     b6a:	40100593          	li	a1,1025
     b6e:	00005517          	auipc	a0,0x5
     b72:	69a50513          	addi	a0,a0,1690 # 6208 <malloc+0x546>
     b76:	00005097          	auipc	ra,0x5
     b7a:	d1e080e7          	jalr	-738(ra) # 5894 <open>
     b7e:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     b80:	4581                	li	a1,0
     b82:	00005517          	auipc	a0,0x5
     b86:	68650513          	addi	a0,a0,1670 # 6208 <malloc+0x546>
     b8a:	00005097          	auipc	ra,0x5
     b8e:	d0a080e7          	jalr	-758(ra) # 5894 <open>
     b92:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     b94:	02000613          	li	a2,32
     b98:	fa040593          	addi	a1,s0,-96
     b9c:	00005097          	auipc	ra,0x5
     ba0:	cd0080e7          	jalr	-816(ra) # 586c <read>
     ba4:	8a2a                	mv	s4,a0
  if(n != 0){
     ba6:	ed4d                	bnez	a0,c60 <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     ba8:	02000613          	li	a2,32
     bac:	fa040593          	addi	a1,s0,-96
     bb0:	8526                	mv	a0,s1
     bb2:	00005097          	auipc	ra,0x5
     bb6:	cba080e7          	jalr	-838(ra) # 586c <read>
     bba:	8a2a                	mv	s4,a0
  if(n != 0){
     bbc:	e971                	bnez	a0,c90 <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     bbe:	4619                	li	a2,6
     bc0:	00006597          	auipc	a1,0x6
     bc4:	89058593          	addi	a1,a1,-1904 # 6450 <malloc+0x78e>
     bc8:	854e                	mv	a0,s3
     bca:	00005097          	auipc	ra,0x5
     bce:	caa080e7          	jalr	-854(ra) # 5874 <write>
  n = read(fd3, buf, sizeof(buf));
     bd2:	02000613          	li	a2,32
     bd6:	fa040593          	addi	a1,s0,-96
     bda:	854a                	mv	a0,s2
     bdc:	00005097          	auipc	ra,0x5
     be0:	c90080e7          	jalr	-880(ra) # 586c <read>
  if(n != 6){
     be4:	4799                	li	a5,6
     be6:	0cf51d63          	bne	a0,a5,cc0 <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     bea:	02000613          	li	a2,32
     bee:	fa040593          	addi	a1,s0,-96
     bf2:	8526                	mv	a0,s1
     bf4:	00005097          	auipc	ra,0x5
     bf8:	c78080e7          	jalr	-904(ra) # 586c <read>
  if(n != 2){
     bfc:	4789                	li	a5,2
     bfe:	0ef51063          	bne	a0,a5,cde <truncate1+0x1f4>
  unlink("truncfile");
     c02:	00005517          	auipc	a0,0x5
     c06:	60650513          	addi	a0,a0,1542 # 6208 <malloc+0x546>
     c0a:	00005097          	auipc	ra,0x5
     c0e:	c9a080e7          	jalr	-870(ra) # 58a4 <unlink>
  close(fd1);
     c12:	854e                	mv	a0,s3
     c14:	00005097          	auipc	ra,0x5
     c18:	c68080e7          	jalr	-920(ra) # 587c <close>
  close(fd2);
     c1c:	8526                	mv	a0,s1
     c1e:	00005097          	auipc	ra,0x5
     c22:	c5e080e7          	jalr	-930(ra) # 587c <close>
  close(fd3);
     c26:	854a                	mv	a0,s2
     c28:	00005097          	auipc	ra,0x5
     c2c:	c54080e7          	jalr	-940(ra) # 587c <close>
}
     c30:	60e6                	ld	ra,88(sp)
     c32:	6446                	ld	s0,80(sp)
     c34:	64a6                	ld	s1,72(sp)
     c36:	6906                	ld	s2,64(sp)
     c38:	79e2                	ld	s3,56(sp)
     c3a:	7a42                	ld	s4,48(sp)
     c3c:	7aa2                	ld	s5,40(sp)
     c3e:	6125                	addi	sp,sp,96
     c40:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     c42:	862a                	mv	a2,a0
     c44:	85d6                	mv	a1,s5
     c46:	00005517          	auipc	a0,0x5
     c4a:	7aa50513          	addi	a0,a0,1962 # 63f0 <malloc+0x72e>
     c4e:	00005097          	auipc	ra,0x5
     c52:	fb6080e7          	jalr	-74(ra) # 5c04 <printf>
    exit(1);
     c56:	4505                	li	a0,1
     c58:	00005097          	auipc	ra,0x5
     c5c:	bfc080e7          	jalr	-1028(ra) # 5854 <exit>
    printf("aaa fd3=%d\n", fd3);
     c60:	85ca                	mv	a1,s2
     c62:	00005517          	auipc	a0,0x5
     c66:	7ae50513          	addi	a0,a0,1966 # 6410 <malloc+0x74e>
     c6a:	00005097          	auipc	ra,0x5
     c6e:	f9a080e7          	jalr	-102(ra) # 5c04 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     c72:	8652                	mv	a2,s4
     c74:	85d6                	mv	a1,s5
     c76:	00005517          	auipc	a0,0x5
     c7a:	7aa50513          	addi	a0,a0,1962 # 6420 <malloc+0x75e>
     c7e:	00005097          	auipc	ra,0x5
     c82:	f86080e7          	jalr	-122(ra) # 5c04 <printf>
    exit(1);
     c86:	4505                	li	a0,1
     c88:	00005097          	auipc	ra,0x5
     c8c:	bcc080e7          	jalr	-1076(ra) # 5854 <exit>
    printf("bbb fd2=%d\n", fd2);
     c90:	85a6                	mv	a1,s1
     c92:	00005517          	auipc	a0,0x5
     c96:	7ae50513          	addi	a0,a0,1966 # 6440 <malloc+0x77e>
     c9a:	00005097          	auipc	ra,0x5
     c9e:	f6a080e7          	jalr	-150(ra) # 5c04 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     ca2:	8652                	mv	a2,s4
     ca4:	85d6                	mv	a1,s5
     ca6:	00005517          	auipc	a0,0x5
     caa:	77a50513          	addi	a0,a0,1914 # 6420 <malloc+0x75e>
     cae:	00005097          	auipc	ra,0x5
     cb2:	f56080e7          	jalr	-170(ra) # 5c04 <printf>
    exit(1);
     cb6:	4505                	li	a0,1
     cb8:	00005097          	auipc	ra,0x5
     cbc:	b9c080e7          	jalr	-1124(ra) # 5854 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     cc0:	862a                	mv	a2,a0
     cc2:	85d6                	mv	a1,s5
     cc4:	00005517          	auipc	a0,0x5
     cc8:	79450513          	addi	a0,a0,1940 # 6458 <malloc+0x796>
     ccc:	00005097          	auipc	ra,0x5
     cd0:	f38080e7          	jalr	-200(ra) # 5c04 <printf>
    exit(1);
     cd4:	4505                	li	a0,1
     cd6:	00005097          	auipc	ra,0x5
     cda:	b7e080e7          	jalr	-1154(ra) # 5854 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     cde:	862a                	mv	a2,a0
     ce0:	85d6                	mv	a1,s5
     ce2:	00005517          	auipc	a0,0x5
     ce6:	79650513          	addi	a0,a0,1942 # 6478 <malloc+0x7b6>
     cea:	00005097          	auipc	ra,0x5
     cee:	f1a080e7          	jalr	-230(ra) # 5c04 <printf>
    exit(1);
     cf2:	4505                	li	a0,1
     cf4:	00005097          	auipc	ra,0x5
     cf8:	b60080e7          	jalr	-1184(ra) # 5854 <exit>

0000000000000cfc <pipe1>:
{
     cfc:	711d                	addi	sp,sp,-96
     cfe:	ec86                	sd	ra,88(sp)
     d00:	e8a2                	sd	s0,80(sp)
     d02:	e4a6                	sd	s1,72(sp)
     d04:	e0ca                	sd	s2,64(sp)
     d06:	fc4e                	sd	s3,56(sp)
     d08:	f852                	sd	s4,48(sp)
     d0a:	f456                	sd	s5,40(sp)
     d0c:	f05a                	sd	s6,32(sp)
     d0e:	ec5e                	sd	s7,24(sp)
     d10:	1080                	addi	s0,sp,96
     d12:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
     d14:	fa840513          	addi	a0,s0,-88
     d18:	00005097          	auipc	ra,0x5
     d1c:	b4c080e7          	jalr	-1204(ra) # 5864 <pipe>
     d20:	ed25                	bnez	a0,d98 <pipe1+0x9c>
     d22:	84aa                	mv	s1,a0
  pid = fork();
     d24:	00005097          	auipc	ra,0x5
     d28:	b28080e7          	jalr	-1240(ra) # 584c <fork>
     d2c:	8a2a                	mv	s4,a0
  if(pid == 0){
     d2e:	c159                	beqz	a0,db4 <pipe1+0xb8>
  } else if(pid > 0){
     d30:	16a05e63          	blez	a0,eac <pipe1+0x1b0>
    close(fds[1]);
     d34:	fac42503          	lw	a0,-84(s0)
     d38:	00005097          	auipc	ra,0x5
     d3c:	b44080e7          	jalr	-1212(ra) # 587c <close>
    total = 0;
     d40:	8a26                	mv	s4,s1
    cc = 1;
     d42:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
     d44:	0000ba97          	auipc	s5,0xb
     d48:	eaca8a93          	addi	s5,s5,-340 # bbf0 <buf>
      if(cc > sizeof(buf))
     d4c:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
     d4e:	864e                	mv	a2,s3
     d50:	85d6                	mv	a1,s5
     d52:	fa842503          	lw	a0,-88(s0)
     d56:	00005097          	auipc	ra,0x5
     d5a:	b16080e7          	jalr	-1258(ra) # 586c <read>
     d5e:	10a05263          	blez	a0,e62 <pipe1+0x166>
      for(i = 0; i < n; i++){
     d62:	0000b717          	auipc	a4,0xb
     d66:	e8e70713          	addi	a4,a4,-370 # bbf0 <buf>
     d6a:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     d6e:	00074683          	lbu	a3,0(a4)
     d72:	0ff4f793          	andi	a5,s1,255
     d76:	2485                	addiw	s1,s1,1
     d78:	0cf69163          	bne	a3,a5,e3a <pipe1+0x13e>
      for(i = 0; i < n; i++){
     d7c:	0705                	addi	a4,a4,1
     d7e:	fec498e3          	bne	s1,a2,d6e <pipe1+0x72>
      total += n;
     d82:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
     d86:	0019979b          	slliw	a5,s3,0x1
     d8a:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
     d8e:	013b7363          	bgeu	s6,s3,d94 <pipe1+0x98>
        cc = sizeof(buf);
     d92:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     d94:	84b2                	mv	s1,a2
     d96:	bf65                	j	d4e <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
     d98:	85ca                	mv	a1,s2
     d9a:	00005517          	auipc	a0,0x5
     d9e:	6fe50513          	addi	a0,a0,1790 # 6498 <malloc+0x7d6>
     da2:	00005097          	auipc	ra,0x5
     da6:	e62080e7          	jalr	-414(ra) # 5c04 <printf>
    exit(1);
     daa:	4505                	li	a0,1
     dac:	00005097          	auipc	ra,0x5
     db0:	aa8080e7          	jalr	-1368(ra) # 5854 <exit>
    close(fds[0]);
     db4:	fa842503          	lw	a0,-88(s0)
     db8:	00005097          	auipc	ra,0x5
     dbc:	ac4080e7          	jalr	-1340(ra) # 587c <close>
    for(n = 0; n < N; n++){
     dc0:	0000bb17          	auipc	s6,0xb
     dc4:	e30b0b13          	addi	s6,s6,-464 # bbf0 <buf>
     dc8:	416004bb          	negw	s1,s6
     dcc:	0ff4f493          	andi	s1,s1,255
     dd0:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
     dd4:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
     dd6:	6a85                	lui	s5,0x1
     dd8:	42da8a93          	addi	s5,s5,1069 # 142d <linktest+0x205>
{
     ddc:	87da                	mv	a5,s6
        buf[i] = seq++;
     dde:	0097873b          	addw	a4,a5,s1
     de2:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
     de6:	0785                	addi	a5,a5,1
     de8:	fef99be3          	bne	s3,a5,dde <pipe1+0xe2>
        buf[i] = seq++;
     dec:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
     df0:	40900613          	li	a2,1033
     df4:	85de                	mv	a1,s7
     df6:	fac42503          	lw	a0,-84(s0)
     dfa:	00005097          	auipc	ra,0x5
     dfe:	a7a080e7          	jalr	-1414(ra) # 5874 <write>
     e02:	40900793          	li	a5,1033
     e06:	00f51c63          	bne	a0,a5,e1e <pipe1+0x122>
    for(n = 0; n < N; n++){
     e0a:	24a5                	addiw	s1,s1,9
     e0c:	0ff4f493          	andi	s1,s1,255
     e10:	fd5a16e3          	bne	s4,s5,ddc <pipe1+0xe0>
    exit(0);
     e14:	4501                	li	a0,0
     e16:	00005097          	auipc	ra,0x5
     e1a:	a3e080e7          	jalr	-1474(ra) # 5854 <exit>
        printf("%s: pipe1 oops 1\n", s);
     e1e:	85ca                	mv	a1,s2
     e20:	00005517          	auipc	a0,0x5
     e24:	69050513          	addi	a0,a0,1680 # 64b0 <malloc+0x7ee>
     e28:	00005097          	auipc	ra,0x5
     e2c:	ddc080e7          	jalr	-548(ra) # 5c04 <printf>
        exit(1);
     e30:	4505                	li	a0,1
     e32:	00005097          	auipc	ra,0x5
     e36:	a22080e7          	jalr	-1502(ra) # 5854 <exit>
          printf("%s: pipe1 oops 2\n", s);
     e3a:	85ca                	mv	a1,s2
     e3c:	00005517          	auipc	a0,0x5
     e40:	68c50513          	addi	a0,a0,1676 # 64c8 <malloc+0x806>
     e44:	00005097          	auipc	ra,0x5
     e48:	dc0080e7          	jalr	-576(ra) # 5c04 <printf>
}
     e4c:	60e6                	ld	ra,88(sp)
     e4e:	6446                	ld	s0,80(sp)
     e50:	64a6                	ld	s1,72(sp)
     e52:	6906                	ld	s2,64(sp)
     e54:	79e2                	ld	s3,56(sp)
     e56:	7a42                	ld	s4,48(sp)
     e58:	7aa2                	ld	s5,40(sp)
     e5a:	7b02                	ld	s6,32(sp)
     e5c:	6be2                	ld	s7,24(sp)
     e5e:	6125                	addi	sp,sp,96
     e60:	8082                	ret
    if(total != N * SZ){
     e62:	6785                	lui	a5,0x1
     e64:	42d78793          	addi	a5,a5,1069 # 142d <linktest+0x205>
     e68:	02fa0063          	beq	s4,a5,e88 <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
     e6c:	85d2                	mv	a1,s4
     e6e:	00005517          	auipc	a0,0x5
     e72:	67250513          	addi	a0,a0,1650 # 64e0 <malloc+0x81e>
     e76:	00005097          	auipc	ra,0x5
     e7a:	d8e080e7          	jalr	-626(ra) # 5c04 <printf>
      exit(1);
     e7e:	4505                	li	a0,1
     e80:	00005097          	auipc	ra,0x5
     e84:	9d4080e7          	jalr	-1580(ra) # 5854 <exit>
    close(fds[0]);
     e88:	fa842503          	lw	a0,-88(s0)
     e8c:	00005097          	auipc	ra,0x5
     e90:	9f0080e7          	jalr	-1552(ra) # 587c <close>
    wait(&xstatus);
     e94:	fa440513          	addi	a0,s0,-92
     e98:	00005097          	auipc	ra,0x5
     e9c:	9c4080e7          	jalr	-1596(ra) # 585c <wait>
    exit(xstatus);
     ea0:	fa442503          	lw	a0,-92(s0)
     ea4:	00005097          	auipc	ra,0x5
     ea8:	9b0080e7          	jalr	-1616(ra) # 5854 <exit>
    printf("%s: fork() failed\n", s);
     eac:	85ca                	mv	a1,s2
     eae:	00005517          	auipc	a0,0x5
     eb2:	65250513          	addi	a0,a0,1618 # 6500 <malloc+0x83e>
     eb6:	00005097          	auipc	ra,0x5
     eba:	d4e080e7          	jalr	-690(ra) # 5c04 <printf>
    exit(1);
     ebe:	4505                	li	a0,1
     ec0:	00005097          	auipc	ra,0x5
     ec4:	994080e7          	jalr	-1644(ra) # 5854 <exit>

0000000000000ec8 <preempt>:
{
     ec8:	7139                	addi	sp,sp,-64
     eca:	fc06                	sd	ra,56(sp)
     ecc:	f822                	sd	s0,48(sp)
     ece:	f426                	sd	s1,40(sp)
     ed0:	f04a                	sd	s2,32(sp)
     ed2:	ec4e                	sd	s3,24(sp)
     ed4:	e852                	sd	s4,16(sp)
     ed6:	0080                	addi	s0,sp,64
     ed8:	892a                	mv	s2,a0
  pid1 = fork();
     eda:	00005097          	auipc	ra,0x5
     ede:	972080e7          	jalr	-1678(ra) # 584c <fork>
  if(pid1 < 0) {
     ee2:	00054563          	bltz	a0,eec <preempt+0x24>
     ee6:	84aa                	mv	s1,a0
  if(pid1 == 0)
     ee8:	e105                	bnez	a0,f08 <preempt+0x40>
    for(;;)
     eea:	a001                	j	eea <preempt+0x22>
    printf("%s: fork failed", s);
     eec:	85ca                	mv	a1,s2
     eee:	00005517          	auipc	a0,0x5
     ef2:	19a50513          	addi	a0,a0,410 # 6088 <malloc+0x3c6>
     ef6:	00005097          	auipc	ra,0x5
     efa:	d0e080e7          	jalr	-754(ra) # 5c04 <printf>
    exit(1);
     efe:	4505                	li	a0,1
     f00:	00005097          	auipc	ra,0x5
     f04:	954080e7          	jalr	-1708(ra) # 5854 <exit>
  pid2 = fork();
     f08:	00005097          	auipc	ra,0x5
     f0c:	944080e7          	jalr	-1724(ra) # 584c <fork>
     f10:	89aa                	mv	s3,a0
  if(pid2 < 0) {
     f12:	00054463          	bltz	a0,f1a <preempt+0x52>
  if(pid2 == 0)
     f16:	e105                	bnez	a0,f36 <preempt+0x6e>
    for(;;)
     f18:	a001                	j	f18 <preempt+0x50>
    printf("%s: fork failed\n", s);
     f1a:	85ca                	mv	a1,s2
     f1c:	00005517          	auipc	a0,0x5
     f20:	11c50513          	addi	a0,a0,284 # 6038 <malloc+0x376>
     f24:	00005097          	auipc	ra,0x5
     f28:	ce0080e7          	jalr	-800(ra) # 5c04 <printf>
    exit(1);
     f2c:	4505                	li	a0,1
     f2e:	00005097          	auipc	ra,0x5
     f32:	926080e7          	jalr	-1754(ra) # 5854 <exit>
  pipe(pfds);
     f36:	fc840513          	addi	a0,s0,-56
     f3a:	00005097          	auipc	ra,0x5
     f3e:	92a080e7          	jalr	-1750(ra) # 5864 <pipe>
  pid3 = fork();
     f42:	00005097          	auipc	ra,0x5
     f46:	90a080e7          	jalr	-1782(ra) # 584c <fork>
     f4a:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
     f4c:	02054e63          	bltz	a0,f88 <preempt+0xc0>
  if(pid3 == 0){
     f50:	e525                	bnez	a0,fb8 <preempt+0xf0>
    close(pfds[0]);
     f52:	fc842503          	lw	a0,-56(s0)
     f56:	00005097          	auipc	ra,0x5
     f5a:	926080e7          	jalr	-1754(ra) # 587c <close>
    if(write(pfds[1], "x", 1) != 1)
     f5e:	4605                	li	a2,1
     f60:	00005597          	auipc	a1,0x5
     f64:	2c058593          	addi	a1,a1,704 # 6220 <malloc+0x55e>
     f68:	fcc42503          	lw	a0,-52(s0)
     f6c:	00005097          	auipc	ra,0x5
     f70:	908080e7          	jalr	-1784(ra) # 5874 <write>
     f74:	4785                	li	a5,1
     f76:	02f51763          	bne	a0,a5,fa4 <preempt+0xdc>
    close(pfds[1]);
     f7a:	fcc42503          	lw	a0,-52(s0)
     f7e:	00005097          	auipc	ra,0x5
     f82:	8fe080e7          	jalr	-1794(ra) # 587c <close>
    for(;;)
     f86:	a001                	j	f86 <preempt+0xbe>
     printf("%s: fork failed\n", s);
     f88:	85ca                	mv	a1,s2
     f8a:	00005517          	auipc	a0,0x5
     f8e:	0ae50513          	addi	a0,a0,174 # 6038 <malloc+0x376>
     f92:	00005097          	auipc	ra,0x5
     f96:	c72080e7          	jalr	-910(ra) # 5c04 <printf>
     exit(1);
     f9a:	4505                	li	a0,1
     f9c:	00005097          	auipc	ra,0x5
     fa0:	8b8080e7          	jalr	-1864(ra) # 5854 <exit>
      printf("%s: preempt write error", s);
     fa4:	85ca                	mv	a1,s2
     fa6:	00005517          	auipc	a0,0x5
     faa:	57250513          	addi	a0,a0,1394 # 6518 <malloc+0x856>
     fae:	00005097          	auipc	ra,0x5
     fb2:	c56080e7          	jalr	-938(ra) # 5c04 <printf>
     fb6:	b7d1                	j	f7a <preempt+0xb2>
  close(pfds[1]);
     fb8:	fcc42503          	lw	a0,-52(s0)
     fbc:	00005097          	auipc	ra,0x5
     fc0:	8c0080e7          	jalr	-1856(ra) # 587c <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
     fc4:	660d                	lui	a2,0x3
     fc6:	0000b597          	auipc	a1,0xb
     fca:	c2a58593          	addi	a1,a1,-982 # bbf0 <buf>
     fce:	fc842503          	lw	a0,-56(s0)
     fd2:	00005097          	auipc	ra,0x5
     fd6:	89a080e7          	jalr	-1894(ra) # 586c <read>
     fda:	4785                	li	a5,1
     fdc:	02f50363          	beq	a0,a5,1002 <preempt+0x13a>
    printf("%s: preempt read error", s);
     fe0:	85ca                	mv	a1,s2
     fe2:	00005517          	auipc	a0,0x5
     fe6:	54e50513          	addi	a0,a0,1358 # 6530 <malloc+0x86e>
     fea:	00005097          	auipc	ra,0x5
     fee:	c1a080e7          	jalr	-998(ra) # 5c04 <printf>
}
     ff2:	70e2                	ld	ra,56(sp)
     ff4:	7442                	ld	s0,48(sp)
     ff6:	74a2                	ld	s1,40(sp)
     ff8:	7902                	ld	s2,32(sp)
     ffa:	69e2                	ld	s3,24(sp)
     ffc:	6a42                	ld	s4,16(sp)
     ffe:	6121                	addi	sp,sp,64
    1000:	8082                	ret
  close(pfds[0]);
    1002:	fc842503          	lw	a0,-56(s0)
    1006:	00005097          	auipc	ra,0x5
    100a:	876080e7          	jalr	-1930(ra) # 587c <close>
  printf("kill... ");
    100e:	00005517          	auipc	a0,0x5
    1012:	53a50513          	addi	a0,a0,1338 # 6548 <malloc+0x886>
    1016:	00005097          	auipc	ra,0x5
    101a:	bee080e7          	jalr	-1042(ra) # 5c04 <printf>
  kill(pid1, SIGKILL);
    101e:	45a5                	li	a1,9
    1020:	8526                	mv	a0,s1
    1022:	00005097          	auipc	ra,0x5
    1026:	862080e7          	jalr	-1950(ra) # 5884 <kill>
  kill(pid2, SIGKILL);
    102a:	45a5                	li	a1,9
    102c:	854e                	mv	a0,s3
    102e:	00005097          	auipc	ra,0x5
    1032:	856080e7          	jalr	-1962(ra) # 5884 <kill>
  kill(pid3, SIGKILL);
    1036:	45a5                	li	a1,9
    1038:	8552                	mv	a0,s4
    103a:	00005097          	auipc	ra,0x5
    103e:	84a080e7          	jalr	-1974(ra) # 5884 <kill>
  printf("wait... ");
    1042:	00005517          	auipc	a0,0x5
    1046:	51650513          	addi	a0,a0,1302 # 6558 <malloc+0x896>
    104a:	00005097          	auipc	ra,0x5
    104e:	bba080e7          	jalr	-1094(ra) # 5c04 <printf>
  wait(0);
    1052:	4501                	li	a0,0
    1054:	00005097          	auipc	ra,0x5
    1058:	808080e7          	jalr	-2040(ra) # 585c <wait>
  wait(0);
    105c:	4501                	li	a0,0
    105e:	00004097          	auipc	ra,0x4
    1062:	7fe080e7          	jalr	2046(ra) # 585c <wait>
  wait(0);
    1066:	4501                	li	a0,0
    1068:	00004097          	auipc	ra,0x4
    106c:	7f4080e7          	jalr	2036(ra) # 585c <wait>
    1070:	b749                	j	ff2 <preempt+0x12a>

0000000000001072 <unlinkread>:
{
    1072:	7179                	addi	sp,sp,-48
    1074:	f406                	sd	ra,40(sp)
    1076:	f022                	sd	s0,32(sp)
    1078:	ec26                	sd	s1,24(sp)
    107a:	e84a                	sd	s2,16(sp)
    107c:	e44e                	sd	s3,8(sp)
    107e:	1800                	addi	s0,sp,48
    1080:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
    1082:	20200593          	li	a1,514
    1086:	00005517          	auipc	a0,0x5
    108a:	e3a50513          	addi	a0,a0,-454 # 5ec0 <malloc+0x1fe>
    108e:	00005097          	auipc	ra,0x5
    1092:	806080e7          	jalr	-2042(ra) # 5894 <open>
  if(fd < 0){
    1096:	0e054563          	bltz	a0,1180 <unlinkread+0x10e>
    109a:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
    109c:	4615                	li	a2,5
    109e:	00005597          	auipc	a1,0x5
    10a2:	4ea58593          	addi	a1,a1,1258 # 6588 <malloc+0x8c6>
    10a6:	00004097          	auipc	ra,0x4
    10aa:	7ce080e7          	jalr	1998(ra) # 5874 <write>
  close(fd);
    10ae:	8526                	mv	a0,s1
    10b0:	00004097          	auipc	ra,0x4
    10b4:	7cc080e7          	jalr	1996(ra) # 587c <close>
  fd = open("unlinkread", O_RDWR);
    10b8:	4589                	li	a1,2
    10ba:	00005517          	auipc	a0,0x5
    10be:	e0650513          	addi	a0,a0,-506 # 5ec0 <malloc+0x1fe>
    10c2:	00004097          	auipc	ra,0x4
    10c6:	7d2080e7          	jalr	2002(ra) # 5894 <open>
    10ca:	84aa                	mv	s1,a0
  if(fd < 0){
    10cc:	0c054863          	bltz	a0,119c <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
    10d0:	00005517          	auipc	a0,0x5
    10d4:	df050513          	addi	a0,a0,-528 # 5ec0 <malloc+0x1fe>
    10d8:	00004097          	auipc	ra,0x4
    10dc:	7cc080e7          	jalr	1996(ra) # 58a4 <unlink>
    10e0:	ed61                	bnez	a0,11b8 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    10e2:	20200593          	li	a1,514
    10e6:	00005517          	auipc	a0,0x5
    10ea:	dda50513          	addi	a0,a0,-550 # 5ec0 <malloc+0x1fe>
    10ee:	00004097          	auipc	ra,0x4
    10f2:	7a6080e7          	jalr	1958(ra) # 5894 <open>
    10f6:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
    10f8:	460d                	li	a2,3
    10fa:	00005597          	auipc	a1,0x5
    10fe:	4d658593          	addi	a1,a1,1238 # 65d0 <malloc+0x90e>
    1102:	00004097          	auipc	ra,0x4
    1106:	772080e7          	jalr	1906(ra) # 5874 <write>
  close(fd1);
    110a:	854a                	mv	a0,s2
    110c:	00004097          	auipc	ra,0x4
    1110:	770080e7          	jalr	1904(ra) # 587c <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
    1114:	660d                	lui	a2,0x3
    1116:	0000b597          	auipc	a1,0xb
    111a:	ada58593          	addi	a1,a1,-1318 # bbf0 <buf>
    111e:	8526                	mv	a0,s1
    1120:	00004097          	auipc	ra,0x4
    1124:	74c080e7          	jalr	1868(ra) # 586c <read>
    1128:	4795                	li	a5,5
    112a:	0af51563          	bne	a0,a5,11d4 <unlinkread+0x162>
  if(buf[0] != 'h'){
    112e:	0000b717          	auipc	a4,0xb
    1132:	ac274703          	lbu	a4,-1342(a4) # bbf0 <buf>
    1136:	06800793          	li	a5,104
    113a:	0af71b63          	bne	a4,a5,11f0 <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
    113e:	4629                	li	a2,10
    1140:	0000b597          	auipc	a1,0xb
    1144:	ab058593          	addi	a1,a1,-1360 # bbf0 <buf>
    1148:	8526                	mv	a0,s1
    114a:	00004097          	auipc	ra,0x4
    114e:	72a080e7          	jalr	1834(ra) # 5874 <write>
    1152:	47a9                	li	a5,10
    1154:	0af51c63          	bne	a0,a5,120c <unlinkread+0x19a>
  close(fd);
    1158:	8526                	mv	a0,s1
    115a:	00004097          	auipc	ra,0x4
    115e:	722080e7          	jalr	1826(ra) # 587c <close>
  unlink("unlinkread");
    1162:	00005517          	auipc	a0,0x5
    1166:	d5e50513          	addi	a0,a0,-674 # 5ec0 <malloc+0x1fe>
    116a:	00004097          	auipc	ra,0x4
    116e:	73a080e7          	jalr	1850(ra) # 58a4 <unlink>
}
    1172:	70a2                	ld	ra,40(sp)
    1174:	7402                	ld	s0,32(sp)
    1176:	64e2                	ld	s1,24(sp)
    1178:	6942                	ld	s2,16(sp)
    117a:	69a2                	ld	s3,8(sp)
    117c:	6145                	addi	sp,sp,48
    117e:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
    1180:	85ce                	mv	a1,s3
    1182:	00005517          	auipc	a0,0x5
    1186:	3e650513          	addi	a0,a0,998 # 6568 <malloc+0x8a6>
    118a:	00005097          	auipc	ra,0x5
    118e:	a7a080e7          	jalr	-1414(ra) # 5c04 <printf>
    exit(1);
    1192:	4505                	li	a0,1
    1194:	00004097          	auipc	ra,0x4
    1198:	6c0080e7          	jalr	1728(ra) # 5854 <exit>
    printf("%s: open unlinkread failed\n", s);
    119c:	85ce                	mv	a1,s3
    119e:	00005517          	auipc	a0,0x5
    11a2:	3f250513          	addi	a0,a0,1010 # 6590 <malloc+0x8ce>
    11a6:	00005097          	auipc	ra,0x5
    11aa:	a5e080e7          	jalr	-1442(ra) # 5c04 <printf>
    exit(1);
    11ae:	4505                	li	a0,1
    11b0:	00004097          	auipc	ra,0x4
    11b4:	6a4080e7          	jalr	1700(ra) # 5854 <exit>
    printf("%s: unlink unlinkread failed\n", s);
    11b8:	85ce                	mv	a1,s3
    11ba:	00005517          	auipc	a0,0x5
    11be:	3f650513          	addi	a0,a0,1014 # 65b0 <malloc+0x8ee>
    11c2:	00005097          	auipc	ra,0x5
    11c6:	a42080e7          	jalr	-1470(ra) # 5c04 <printf>
    exit(1);
    11ca:	4505                	li	a0,1
    11cc:	00004097          	auipc	ra,0x4
    11d0:	688080e7          	jalr	1672(ra) # 5854 <exit>
    printf("%s: unlinkread read failed", s);
    11d4:	85ce                	mv	a1,s3
    11d6:	00005517          	auipc	a0,0x5
    11da:	40250513          	addi	a0,a0,1026 # 65d8 <malloc+0x916>
    11de:	00005097          	auipc	ra,0x5
    11e2:	a26080e7          	jalr	-1498(ra) # 5c04 <printf>
    exit(1);
    11e6:	4505                	li	a0,1
    11e8:	00004097          	auipc	ra,0x4
    11ec:	66c080e7          	jalr	1644(ra) # 5854 <exit>
    printf("%s: unlinkread wrong data\n", s);
    11f0:	85ce                	mv	a1,s3
    11f2:	00005517          	auipc	a0,0x5
    11f6:	40650513          	addi	a0,a0,1030 # 65f8 <malloc+0x936>
    11fa:	00005097          	auipc	ra,0x5
    11fe:	a0a080e7          	jalr	-1526(ra) # 5c04 <printf>
    exit(1);
    1202:	4505                	li	a0,1
    1204:	00004097          	auipc	ra,0x4
    1208:	650080e7          	jalr	1616(ra) # 5854 <exit>
    printf("%s: unlinkread write failed\n", s);
    120c:	85ce                	mv	a1,s3
    120e:	00005517          	auipc	a0,0x5
    1212:	40a50513          	addi	a0,a0,1034 # 6618 <malloc+0x956>
    1216:	00005097          	auipc	ra,0x5
    121a:	9ee080e7          	jalr	-1554(ra) # 5c04 <printf>
    exit(1);
    121e:	4505                	li	a0,1
    1220:	00004097          	auipc	ra,0x4
    1224:	634080e7          	jalr	1588(ra) # 5854 <exit>

0000000000001228 <linktest>:
{
    1228:	1101                	addi	sp,sp,-32
    122a:	ec06                	sd	ra,24(sp)
    122c:	e822                	sd	s0,16(sp)
    122e:	e426                	sd	s1,8(sp)
    1230:	e04a                	sd	s2,0(sp)
    1232:	1000                	addi	s0,sp,32
    1234:	892a                	mv	s2,a0
  unlink("lf1");
    1236:	00005517          	auipc	a0,0x5
    123a:	40250513          	addi	a0,a0,1026 # 6638 <malloc+0x976>
    123e:	00004097          	auipc	ra,0x4
    1242:	666080e7          	jalr	1638(ra) # 58a4 <unlink>
  unlink("lf2");
    1246:	00005517          	auipc	a0,0x5
    124a:	3fa50513          	addi	a0,a0,1018 # 6640 <malloc+0x97e>
    124e:	00004097          	auipc	ra,0x4
    1252:	656080e7          	jalr	1622(ra) # 58a4 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
    1256:	20200593          	li	a1,514
    125a:	00005517          	auipc	a0,0x5
    125e:	3de50513          	addi	a0,a0,990 # 6638 <malloc+0x976>
    1262:	00004097          	auipc	ra,0x4
    1266:	632080e7          	jalr	1586(ra) # 5894 <open>
  if(fd < 0){
    126a:	10054763          	bltz	a0,1378 <linktest+0x150>
    126e:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
    1270:	4615                	li	a2,5
    1272:	00005597          	auipc	a1,0x5
    1276:	31658593          	addi	a1,a1,790 # 6588 <malloc+0x8c6>
    127a:	00004097          	auipc	ra,0x4
    127e:	5fa080e7          	jalr	1530(ra) # 5874 <write>
    1282:	4795                	li	a5,5
    1284:	10f51863          	bne	a0,a5,1394 <linktest+0x16c>
  close(fd);
    1288:	8526                	mv	a0,s1
    128a:	00004097          	auipc	ra,0x4
    128e:	5f2080e7          	jalr	1522(ra) # 587c <close>
  if(link("lf1", "lf2") < 0){
    1292:	00005597          	auipc	a1,0x5
    1296:	3ae58593          	addi	a1,a1,942 # 6640 <malloc+0x97e>
    129a:	00005517          	auipc	a0,0x5
    129e:	39e50513          	addi	a0,a0,926 # 6638 <malloc+0x976>
    12a2:	00004097          	auipc	ra,0x4
    12a6:	612080e7          	jalr	1554(ra) # 58b4 <link>
    12aa:	10054363          	bltz	a0,13b0 <linktest+0x188>
  unlink("lf1");
    12ae:	00005517          	auipc	a0,0x5
    12b2:	38a50513          	addi	a0,a0,906 # 6638 <malloc+0x976>
    12b6:	00004097          	auipc	ra,0x4
    12ba:	5ee080e7          	jalr	1518(ra) # 58a4 <unlink>
  if(open("lf1", 0) >= 0){
    12be:	4581                	li	a1,0
    12c0:	00005517          	auipc	a0,0x5
    12c4:	37850513          	addi	a0,a0,888 # 6638 <malloc+0x976>
    12c8:	00004097          	auipc	ra,0x4
    12cc:	5cc080e7          	jalr	1484(ra) # 5894 <open>
    12d0:	0e055e63          	bgez	a0,13cc <linktest+0x1a4>
  fd = open("lf2", 0);
    12d4:	4581                	li	a1,0
    12d6:	00005517          	auipc	a0,0x5
    12da:	36a50513          	addi	a0,a0,874 # 6640 <malloc+0x97e>
    12de:	00004097          	auipc	ra,0x4
    12e2:	5b6080e7          	jalr	1462(ra) # 5894 <open>
    12e6:	84aa                	mv	s1,a0
  if(fd < 0){
    12e8:	10054063          	bltz	a0,13e8 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
    12ec:	660d                	lui	a2,0x3
    12ee:	0000b597          	auipc	a1,0xb
    12f2:	90258593          	addi	a1,a1,-1790 # bbf0 <buf>
    12f6:	00004097          	auipc	ra,0x4
    12fa:	576080e7          	jalr	1398(ra) # 586c <read>
    12fe:	4795                	li	a5,5
    1300:	10f51263          	bne	a0,a5,1404 <linktest+0x1dc>
  close(fd);
    1304:	8526                	mv	a0,s1
    1306:	00004097          	auipc	ra,0x4
    130a:	576080e7          	jalr	1398(ra) # 587c <close>
  if(link("lf2", "lf2") >= 0){
    130e:	00005597          	auipc	a1,0x5
    1312:	33258593          	addi	a1,a1,818 # 6640 <malloc+0x97e>
    1316:	852e                	mv	a0,a1
    1318:	00004097          	auipc	ra,0x4
    131c:	59c080e7          	jalr	1436(ra) # 58b4 <link>
    1320:	10055063          	bgez	a0,1420 <linktest+0x1f8>
  unlink("lf2");
    1324:	00005517          	auipc	a0,0x5
    1328:	31c50513          	addi	a0,a0,796 # 6640 <malloc+0x97e>
    132c:	00004097          	auipc	ra,0x4
    1330:	578080e7          	jalr	1400(ra) # 58a4 <unlink>
  if(link("lf2", "lf1") >= 0){
    1334:	00005597          	auipc	a1,0x5
    1338:	30458593          	addi	a1,a1,772 # 6638 <malloc+0x976>
    133c:	00005517          	auipc	a0,0x5
    1340:	30450513          	addi	a0,a0,772 # 6640 <malloc+0x97e>
    1344:	00004097          	auipc	ra,0x4
    1348:	570080e7          	jalr	1392(ra) # 58b4 <link>
    134c:	0e055863          	bgez	a0,143c <linktest+0x214>
  if(link(".", "lf1") >= 0){
    1350:	00005597          	auipc	a1,0x5
    1354:	2e858593          	addi	a1,a1,744 # 6638 <malloc+0x976>
    1358:	00005517          	auipc	a0,0x5
    135c:	3f050513          	addi	a0,a0,1008 # 6748 <malloc+0xa86>
    1360:	00004097          	auipc	ra,0x4
    1364:	554080e7          	jalr	1364(ra) # 58b4 <link>
    1368:	0e055863          	bgez	a0,1458 <linktest+0x230>
}
    136c:	60e2                	ld	ra,24(sp)
    136e:	6442                	ld	s0,16(sp)
    1370:	64a2                	ld	s1,8(sp)
    1372:	6902                	ld	s2,0(sp)
    1374:	6105                	addi	sp,sp,32
    1376:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    1378:	85ca                	mv	a1,s2
    137a:	00005517          	auipc	a0,0x5
    137e:	2ce50513          	addi	a0,a0,718 # 6648 <malloc+0x986>
    1382:	00005097          	auipc	ra,0x5
    1386:	882080e7          	jalr	-1918(ra) # 5c04 <printf>
    exit(1);
    138a:	4505                	li	a0,1
    138c:	00004097          	auipc	ra,0x4
    1390:	4c8080e7          	jalr	1224(ra) # 5854 <exit>
    printf("%s: write lf1 failed\n", s);
    1394:	85ca                	mv	a1,s2
    1396:	00005517          	auipc	a0,0x5
    139a:	2ca50513          	addi	a0,a0,714 # 6660 <malloc+0x99e>
    139e:	00005097          	auipc	ra,0x5
    13a2:	866080e7          	jalr	-1946(ra) # 5c04 <printf>
    exit(1);
    13a6:	4505                	li	a0,1
    13a8:	00004097          	auipc	ra,0x4
    13ac:	4ac080e7          	jalr	1196(ra) # 5854 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    13b0:	85ca                	mv	a1,s2
    13b2:	00005517          	auipc	a0,0x5
    13b6:	2c650513          	addi	a0,a0,710 # 6678 <malloc+0x9b6>
    13ba:	00005097          	auipc	ra,0x5
    13be:	84a080e7          	jalr	-1974(ra) # 5c04 <printf>
    exit(1);
    13c2:	4505                	li	a0,1
    13c4:	00004097          	auipc	ra,0x4
    13c8:	490080e7          	jalr	1168(ra) # 5854 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    13cc:	85ca                	mv	a1,s2
    13ce:	00005517          	auipc	a0,0x5
    13d2:	2ca50513          	addi	a0,a0,714 # 6698 <malloc+0x9d6>
    13d6:	00005097          	auipc	ra,0x5
    13da:	82e080e7          	jalr	-2002(ra) # 5c04 <printf>
    exit(1);
    13de:	4505                	li	a0,1
    13e0:	00004097          	auipc	ra,0x4
    13e4:	474080e7          	jalr	1140(ra) # 5854 <exit>
    printf("%s: open lf2 failed\n", s);
    13e8:	85ca                	mv	a1,s2
    13ea:	00005517          	auipc	a0,0x5
    13ee:	2de50513          	addi	a0,a0,734 # 66c8 <malloc+0xa06>
    13f2:	00005097          	auipc	ra,0x5
    13f6:	812080e7          	jalr	-2030(ra) # 5c04 <printf>
    exit(1);
    13fa:	4505                	li	a0,1
    13fc:	00004097          	auipc	ra,0x4
    1400:	458080e7          	jalr	1112(ra) # 5854 <exit>
    printf("%s: read lf2 failed\n", s);
    1404:	85ca                	mv	a1,s2
    1406:	00005517          	auipc	a0,0x5
    140a:	2da50513          	addi	a0,a0,730 # 66e0 <malloc+0xa1e>
    140e:	00004097          	auipc	ra,0x4
    1412:	7f6080e7          	jalr	2038(ra) # 5c04 <printf>
    exit(1);
    1416:	4505                	li	a0,1
    1418:	00004097          	auipc	ra,0x4
    141c:	43c080e7          	jalr	1084(ra) # 5854 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    1420:	85ca                	mv	a1,s2
    1422:	00005517          	auipc	a0,0x5
    1426:	2d650513          	addi	a0,a0,726 # 66f8 <malloc+0xa36>
    142a:	00004097          	auipc	ra,0x4
    142e:	7da080e7          	jalr	2010(ra) # 5c04 <printf>
    exit(1);
    1432:	4505                	li	a0,1
    1434:	00004097          	auipc	ra,0x4
    1438:	420080e7          	jalr	1056(ra) # 5854 <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
    143c:	85ca                	mv	a1,s2
    143e:	00005517          	auipc	a0,0x5
    1442:	2e250513          	addi	a0,a0,738 # 6720 <malloc+0xa5e>
    1446:	00004097          	auipc	ra,0x4
    144a:	7be080e7          	jalr	1982(ra) # 5c04 <printf>
    exit(1);
    144e:	4505                	li	a0,1
    1450:	00004097          	auipc	ra,0x4
    1454:	404080e7          	jalr	1028(ra) # 5854 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    1458:	85ca                	mv	a1,s2
    145a:	00005517          	auipc	a0,0x5
    145e:	2f650513          	addi	a0,a0,758 # 6750 <malloc+0xa8e>
    1462:	00004097          	auipc	ra,0x4
    1466:	7a2080e7          	jalr	1954(ra) # 5c04 <printf>
    exit(1);
    146a:	4505                	li	a0,1
    146c:	00004097          	auipc	ra,0x4
    1470:	3e8080e7          	jalr	1000(ra) # 5854 <exit>

0000000000001474 <validatetest>:
{
    1474:	7139                	addi	sp,sp,-64
    1476:	fc06                	sd	ra,56(sp)
    1478:	f822                	sd	s0,48(sp)
    147a:	f426                	sd	s1,40(sp)
    147c:	f04a                	sd	s2,32(sp)
    147e:	ec4e                	sd	s3,24(sp)
    1480:	e852                	sd	s4,16(sp)
    1482:	e456                	sd	s5,8(sp)
    1484:	e05a                	sd	s6,0(sp)
    1486:	0080                	addi	s0,sp,64
    1488:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    148a:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    148c:	00005997          	auipc	s3,0x5
    1490:	2e498993          	addi	s3,s3,740 # 6770 <malloc+0xaae>
    1494:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1496:	6a85                	lui	s5,0x1
    1498:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    149c:	85a6                	mv	a1,s1
    149e:	854e                	mv	a0,s3
    14a0:	00004097          	auipc	ra,0x4
    14a4:	414080e7          	jalr	1044(ra) # 58b4 <link>
    14a8:	01251f63          	bne	a0,s2,14c6 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    14ac:	94d6                	add	s1,s1,s5
    14ae:	ff4497e3          	bne	s1,s4,149c <validatetest+0x28>
}
    14b2:	70e2                	ld	ra,56(sp)
    14b4:	7442                	ld	s0,48(sp)
    14b6:	74a2                	ld	s1,40(sp)
    14b8:	7902                	ld	s2,32(sp)
    14ba:	69e2                	ld	s3,24(sp)
    14bc:	6a42                	ld	s4,16(sp)
    14be:	6aa2                	ld	s5,8(sp)
    14c0:	6b02                	ld	s6,0(sp)
    14c2:	6121                	addi	sp,sp,64
    14c4:	8082                	ret
      printf("%s: link should not succeed\n", s);
    14c6:	85da                	mv	a1,s6
    14c8:	00005517          	auipc	a0,0x5
    14cc:	2b850513          	addi	a0,a0,696 # 6780 <malloc+0xabe>
    14d0:	00004097          	auipc	ra,0x4
    14d4:	734080e7          	jalr	1844(ra) # 5c04 <printf>
      exit(1);
    14d8:	4505                	li	a0,1
    14da:	00004097          	auipc	ra,0x4
    14de:	37a080e7          	jalr	890(ra) # 5854 <exit>

00000000000014e2 <copyinstr2>:
{
    14e2:	7155                	addi	sp,sp,-208
    14e4:	e586                	sd	ra,200(sp)
    14e6:	e1a2                	sd	s0,192(sp)
    14e8:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    14ea:	f6840793          	addi	a5,s0,-152
    14ee:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    14f2:	07800713          	li	a4,120
    14f6:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    14fa:	0785                	addi	a5,a5,1
    14fc:	fed79de3          	bne	a5,a3,14f6 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    1500:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    1504:	f6840513          	addi	a0,s0,-152
    1508:	00004097          	auipc	ra,0x4
    150c:	39c080e7          	jalr	924(ra) # 58a4 <unlink>
  if(ret != -1){
    1510:	57fd                	li	a5,-1
    1512:	0ef51063          	bne	a0,a5,15f2 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    1516:	20100593          	li	a1,513
    151a:	f6840513          	addi	a0,s0,-152
    151e:	00004097          	auipc	ra,0x4
    1522:	376080e7          	jalr	886(ra) # 5894 <open>
  if(fd != -1){
    1526:	57fd                	li	a5,-1
    1528:	0ef51563          	bne	a0,a5,1612 <copyinstr2+0x130>
  ret = link(b, b);
    152c:	f6840593          	addi	a1,s0,-152
    1530:	852e                	mv	a0,a1
    1532:	00004097          	auipc	ra,0x4
    1536:	382080e7          	jalr	898(ra) # 58b4 <link>
  if(ret != -1){
    153a:	57fd                	li	a5,-1
    153c:	0ef51b63          	bne	a0,a5,1632 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    1540:	00006797          	auipc	a5,0x6
    1544:	01878793          	addi	a5,a5,24 # 7558 <malloc+0x1896>
    1548:	f4f43c23          	sd	a5,-168(s0)
    154c:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1550:	f5840593          	addi	a1,s0,-168
    1554:	f6840513          	addi	a0,s0,-152
    1558:	00004097          	auipc	ra,0x4
    155c:	334080e7          	jalr	820(ra) # 588c <exec>
  if(ret != -1){
    1560:	57fd                	li	a5,-1
    1562:	0ef51963          	bne	a0,a5,1654 <copyinstr2+0x172>
  int pid = fork();
    1566:	00004097          	auipc	ra,0x4
    156a:	2e6080e7          	jalr	742(ra) # 584c <fork>
  if(pid < 0){
    156e:	10054363          	bltz	a0,1674 <copyinstr2+0x192>
  if(pid == 0){
    1572:	12051463          	bnez	a0,169a <copyinstr2+0x1b8>
    1576:	00007797          	auipc	a5,0x7
    157a:	f6278793          	addi	a5,a5,-158 # 84d8 <big.0>
    157e:	00008697          	auipc	a3,0x8
    1582:	f5a68693          	addi	a3,a3,-166 # 94d8 <__global_pointer$+0x920>
      big[i] = 'x';
    1586:	07800713          	li	a4,120
    158a:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    158e:	0785                	addi	a5,a5,1
    1590:	fed79de3          	bne	a5,a3,158a <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1594:	00008797          	auipc	a5,0x8
    1598:	f4078223          	sb	zero,-188(a5) # 94d8 <__global_pointer$+0x920>
    char *args2[] = { big, big, big, 0 };
    159c:	00007797          	auipc	a5,0x7
    15a0:	b4c78793          	addi	a5,a5,-1204 # 80e8 <malloc+0x2426>
    15a4:	6390                	ld	a2,0(a5)
    15a6:	6794                	ld	a3,8(a5)
    15a8:	6b98                	ld	a4,16(a5)
    15aa:	6f9c                	ld	a5,24(a5)
    15ac:	f2c43823          	sd	a2,-208(s0)
    15b0:	f2d43c23          	sd	a3,-200(s0)
    15b4:	f4e43023          	sd	a4,-192(s0)
    15b8:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    15bc:	f3040593          	addi	a1,s0,-208
    15c0:	00005517          	auipc	a0,0x5
    15c4:	bf050513          	addi	a0,a0,-1040 # 61b0 <malloc+0x4ee>
    15c8:	00004097          	auipc	ra,0x4
    15cc:	2c4080e7          	jalr	708(ra) # 588c <exec>
    if(ret != -1){
    15d0:	57fd                	li	a5,-1
    15d2:	0af50e63          	beq	a0,a5,168e <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    15d6:	55fd                	li	a1,-1
    15d8:	00005517          	auipc	a0,0x5
    15dc:	25050513          	addi	a0,a0,592 # 6828 <malloc+0xb66>
    15e0:	00004097          	auipc	ra,0x4
    15e4:	624080e7          	jalr	1572(ra) # 5c04 <printf>
      exit(1);
    15e8:	4505                	li	a0,1
    15ea:	00004097          	auipc	ra,0x4
    15ee:	26a080e7          	jalr	618(ra) # 5854 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    15f2:	862a                	mv	a2,a0
    15f4:	f6840593          	addi	a1,s0,-152
    15f8:	00005517          	auipc	a0,0x5
    15fc:	1a850513          	addi	a0,a0,424 # 67a0 <malloc+0xade>
    1600:	00004097          	auipc	ra,0x4
    1604:	604080e7          	jalr	1540(ra) # 5c04 <printf>
    exit(1);
    1608:	4505                	li	a0,1
    160a:	00004097          	auipc	ra,0x4
    160e:	24a080e7          	jalr	586(ra) # 5854 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1612:	862a                	mv	a2,a0
    1614:	f6840593          	addi	a1,s0,-152
    1618:	00005517          	auipc	a0,0x5
    161c:	1a850513          	addi	a0,a0,424 # 67c0 <malloc+0xafe>
    1620:	00004097          	auipc	ra,0x4
    1624:	5e4080e7          	jalr	1508(ra) # 5c04 <printf>
    exit(1);
    1628:	4505                	li	a0,1
    162a:	00004097          	auipc	ra,0x4
    162e:	22a080e7          	jalr	554(ra) # 5854 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1632:	86aa                	mv	a3,a0
    1634:	f6840613          	addi	a2,s0,-152
    1638:	85b2                	mv	a1,a2
    163a:	00005517          	auipc	a0,0x5
    163e:	1a650513          	addi	a0,a0,422 # 67e0 <malloc+0xb1e>
    1642:	00004097          	auipc	ra,0x4
    1646:	5c2080e7          	jalr	1474(ra) # 5c04 <printf>
    exit(1);
    164a:	4505                	li	a0,1
    164c:	00004097          	auipc	ra,0x4
    1650:	208080e7          	jalr	520(ra) # 5854 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1654:	567d                	li	a2,-1
    1656:	f6840593          	addi	a1,s0,-152
    165a:	00005517          	auipc	a0,0x5
    165e:	1ae50513          	addi	a0,a0,430 # 6808 <malloc+0xb46>
    1662:	00004097          	auipc	ra,0x4
    1666:	5a2080e7          	jalr	1442(ra) # 5c04 <printf>
    exit(1);
    166a:	4505                	li	a0,1
    166c:	00004097          	auipc	ra,0x4
    1670:	1e8080e7          	jalr	488(ra) # 5854 <exit>
    printf("fork failed\n");
    1674:	00005517          	auipc	a0,0x5
    1678:	3bc50513          	addi	a0,a0,956 # 6a30 <malloc+0xd6e>
    167c:	00004097          	auipc	ra,0x4
    1680:	588080e7          	jalr	1416(ra) # 5c04 <printf>
    exit(1);
    1684:	4505                	li	a0,1
    1686:	00004097          	auipc	ra,0x4
    168a:	1ce080e7          	jalr	462(ra) # 5854 <exit>
    exit(747); // OK
    168e:	2eb00513          	li	a0,747
    1692:	00004097          	auipc	ra,0x4
    1696:	1c2080e7          	jalr	450(ra) # 5854 <exit>
  int st = 0;
    169a:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    169e:	f5440513          	addi	a0,s0,-172
    16a2:	00004097          	auipc	ra,0x4
    16a6:	1ba080e7          	jalr	442(ra) # 585c <wait>
  if(st != 747){
    16aa:	f5442703          	lw	a4,-172(s0)
    16ae:	2eb00793          	li	a5,747
    16b2:	00f71663          	bne	a4,a5,16be <copyinstr2+0x1dc>
}
    16b6:	60ae                	ld	ra,200(sp)
    16b8:	640e                	ld	s0,192(sp)
    16ba:	6169                	addi	sp,sp,208
    16bc:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    16be:	00005517          	auipc	a0,0x5
    16c2:	19250513          	addi	a0,a0,402 # 6850 <malloc+0xb8e>
    16c6:	00004097          	auipc	ra,0x4
    16ca:	53e080e7          	jalr	1342(ra) # 5c04 <printf>
    exit(1);
    16ce:	4505                	li	a0,1
    16d0:	00004097          	auipc	ra,0x4
    16d4:	184080e7          	jalr	388(ra) # 5854 <exit>

00000000000016d8 <exectest>:
{
    16d8:	715d                	addi	sp,sp,-80
    16da:	e486                	sd	ra,72(sp)
    16dc:	e0a2                	sd	s0,64(sp)
    16de:	fc26                	sd	s1,56(sp)
    16e0:	f84a                	sd	s2,48(sp)
    16e2:	0880                	addi	s0,sp,80
    16e4:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    16e6:	00005797          	auipc	a5,0x5
    16ea:	aca78793          	addi	a5,a5,-1334 # 61b0 <malloc+0x4ee>
    16ee:	fcf43023          	sd	a5,-64(s0)
    16f2:	00005797          	auipc	a5,0x5
    16f6:	18e78793          	addi	a5,a5,398 # 6880 <malloc+0xbbe>
    16fa:	fcf43423          	sd	a5,-56(s0)
    16fe:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    1702:	00005517          	auipc	a0,0x5
    1706:	18650513          	addi	a0,a0,390 # 6888 <malloc+0xbc6>
    170a:	00004097          	auipc	ra,0x4
    170e:	19a080e7          	jalr	410(ra) # 58a4 <unlink>
  pid = fork();
    1712:	00004097          	auipc	ra,0x4
    1716:	13a080e7          	jalr	314(ra) # 584c <fork>
  if(pid < 0) {
    171a:	04054663          	bltz	a0,1766 <exectest+0x8e>
    171e:	84aa                	mv	s1,a0
  if(pid == 0) {
    1720:	e959                	bnez	a0,17b6 <exectest+0xde>
    close(1);
    1722:	4505                	li	a0,1
    1724:	00004097          	auipc	ra,0x4
    1728:	158080e7          	jalr	344(ra) # 587c <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    172c:	20100593          	li	a1,513
    1730:	00005517          	auipc	a0,0x5
    1734:	15850513          	addi	a0,a0,344 # 6888 <malloc+0xbc6>
    1738:	00004097          	auipc	ra,0x4
    173c:	15c080e7          	jalr	348(ra) # 5894 <open>
    if(fd < 0) {
    1740:	04054163          	bltz	a0,1782 <exectest+0xaa>
    if(fd != 1) {
    1744:	4785                	li	a5,1
    1746:	04f50c63          	beq	a0,a5,179e <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    174a:	85ca                	mv	a1,s2
    174c:	00005517          	auipc	a0,0x5
    1750:	15c50513          	addi	a0,a0,348 # 68a8 <malloc+0xbe6>
    1754:	00004097          	auipc	ra,0x4
    1758:	4b0080e7          	jalr	1200(ra) # 5c04 <printf>
      exit(1);
    175c:	4505                	li	a0,1
    175e:	00004097          	auipc	ra,0x4
    1762:	0f6080e7          	jalr	246(ra) # 5854 <exit>
     printf("%s: fork failed\n", s);
    1766:	85ca                	mv	a1,s2
    1768:	00005517          	auipc	a0,0x5
    176c:	8d050513          	addi	a0,a0,-1840 # 6038 <malloc+0x376>
    1770:	00004097          	auipc	ra,0x4
    1774:	494080e7          	jalr	1172(ra) # 5c04 <printf>
     exit(1);
    1778:	4505                	li	a0,1
    177a:	00004097          	auipc	ra,0x4
    177e:	0da080e7          	jalr	218(ra) # 5854 <exit>
      printf("%s: create failed\n", s);
    1782:	85ca                	mv	a1,s2
    1784:	00005517          	auipc	a0,0x5
    1788:	10c50513          	addi	a0,a0,268 # 6890 <malloc+0xbce>
    178c:	00004097          	auipc	ra,0x4
    1790:	478080e7          	jalr	1144(ra) # 5c04 <printf>
      exit(1);
    1794:	4505                	li	a0,1
    1796:	00004097          	auipc	ra,0x4
    179a:	0be080e7          	jalr	190(ra) # 5854 <exit>
    if(exec("echo", echoargv) < 0){
    179e:	fc040593          	addi	a1,s0,-64
    17a2:	00005517          	auipc	a0,0x5
    17a6:	a0e50513          	addi	a0,a0,-1522 # 61b0 <malloc+0x4ee>
    17aa:	00004097          	auipc	ra,0x4
    17ae:	0e2080e7          	jalr	226(ra) # 588c <exec>
    17b2:	02054163          	bltz	a0,17d4 <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    17b6:	fdc40513          	addi	a0,s0,-36
    17ba:	00004097          	auipc	ra,0x4
    17be:	0a2080e7          	jalr	162(ra) # 585c <wait>
    17c2:	02951763          	bne	a0,s1,17f0 <exectest+0x118>
  if(xstatus != 0)
    17c6:	fdc42503          	lw	a0,-36(s0)
    17ca:	cd0d                	beqz	a0,1804 <exectest+0x12c>
    exit(xstatus);
    17cc:	00004097          	auipc	ra,0x4
    17d0:	088080e7          	jalr	136(ra) # 5854 <exit>
      printf("%s: exec echo failed\n", s);
    17d4:	85ca                	mv	a1,s2
    17d6:	00005517          	auipc	a0,0x5
    17da:	0e250513          	addi	a0,a0,226 # 68b8 <malloc+0xbf6>
    17de:	00004097          	auipc	ra,0x4
    17e2:	426080e7          	jalr	1062(ra) # 5c04 <printf>
      exit(1);
    17e6:	4505                	li	a0,1
    17e8:	00004097          	auipc	ra,0x4
    17ec:	06c080e7          	jalr	108(ra) # 5854 <exit>
    printf("%s: wait failed!\n", s);
    17f0:	85ca                	mv	a1,s2
    17f2:	00005517          	auipc	a0,0x5
    17f6:	0de50513          	addi	a0,a0,222 # 68d0 <malloc+0xc0e>
    17fa:	00004097          	auipc	ra,0x4
    17fe:	40a080e7          	jalr	1034(ra) # 5c04 <printf>
    1802:	b7d1                	j	17c6 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    1804:	4581                	li	a1,0
    1806:	00005517          	auipc	a0,0x5
    180a:	08250513          	addi	a0,a0,130 # 6888 <malloc+0xbc6>
    180e:	00004097          	auipc	ra,0x4
    1812:	086080e7          	jalr	134(ra) # 5894 <open>
  if(fd < 0) {
    1816:	02054a63          	bltz	a0,184a <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    181a:	4609                	li	a2,2
    181c:	fb840593          	addi	a1,s0,-72
    1820:	00004097          	auipc	ra,0x4
    1824:	04c080e7          	jalr	76(ra) # 586c <read>
    1828:	4789                	li	a5,2
    182a:	02f50e63          	beq	a0,a5,1866 <exectest+0x18e>
    printf("%s: read failed\n", s);
    182e:	85ca                	mv	a1,s2
    1830:	00005517          	auipc	a0,0x5
    1834:	0d050513          	addi	a0,a0,208 # 6900 <malloc+0xc3e>
    1838:	00004097          	auipc	ra,0x4
    183c:	3cc080e7          	jalr	972(ra) # 5c04 <printf>
    exit(1);
    1840:	4505                	li	a0,1
    1842:	00004097          	auipc	ra,0x4
    1846:	012080e7          	jalr	18(ra) # 5854 <exit>
    printf("%s: open failed\n", s);
    184a:	85ca                	mv	a1,s2
    184c:	00005517          	auipc	a0,0x5
    1850:	09c50513          	addi	a0,a0,156 # 68e8 <malloc+0xc26>
    1854:	00004097          	auipc	ra,0x4
    1858:	3b0080e7          	jalr	944(ra) # 5c04 <printf>
    exit(1);
    185c:	4505                	li	a0,1
    185e:	00004097          	auipc	ra,0x4
    1862:	ff6080e7          	jalr	-10(ra) # 5854 <exit>
  unlink("echo-ok");
    1866:	00005517          	auipc	a0,0x5
    186a:	02250513          	addi	a0,a0,34 # 6888 <malloc+0xbc6>
    186e:	00004097          	auipc	ra,0x4
    1872:	036080e7          	jalr	54(ra) # 58a4 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1876:	fb844703          	lbu	a4,-72(s0)
    187a:	04f00793          	li	a5,79
    187e:	00f71863          	bne	a4,a5,188e <exectest+0x1b6>
    1882:	fb944703          	lbu	a4,-71(s0)
    1886:	04b00793          	li	a5,75
    188a:	02f70063          	beq	a4,a5,18aa <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    188e:	85ca                	mv	a1,s2
    1890:	00005517          	auipc	a0,0x5
    1894:	08850513          	addi	a0,a0,136 # 6918 <malloc+0xc56>
    1898:	00004097          	auipc	ra,0x4
    189c:	36c080e7          	jalr	876(ra) # 5c04 <printf>
    exit(1);
    18a0:	4505                	li	a0,1
    18a2:	00004097          	auipc	ra,0x4
    18a6:	fb2080e7          	jalr	-78(ra) # 5854 <exit>
    exit(0);
    18aa:	4501                	li	a0,0
    18ac:	00004097          	auipc	ra,0x4
    18b0:	fa8080e7          	jalr	-88(ra) # 5854 <exit>

00000000000018b4 <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(char *s)
{
    18b4:	7179                	addi	sp,sp,-48
    18b6:	f406                	sd	ra,40(sp)
    18b8:	f022                	sd	s0,32(sp)
    18ba:	ec26                	sd	s1,24(sp)
    18bc:	1800                	addi	s0,sp,48
    18be:	84aa                	mv	s1,a0
  int pid, fd, xstatus;

  unlink("bigarg-ok");
    18c0:	00005517          	auipc	a0,0x5
    18c4:	07050513          	addi	a0,a0,112 # 6930 <malloc+0xc6e>
    18c8:	00004097          	auipc	ra,0x4
    18cc:	fdc080e7          	jalr	-36(ra) # 58a4 <unlink>
  pid = fork();
    18d0:	00004097          	auipc	ra,0x4
    18d4:	f7c080e7          	jalr	-132(ra) # 584c <fork>
  if(pid == 0){
    18d8:	c121                	beqz	a0,1918 <bigargtest+0x64>
    args[MAXARG-1] = 0;
    exec("echo", args);
    fd = open("bigarg-ok", O_CREATE);
    close(fd);
    exit(0);
  } else if(pid < 0){
    18da:	0a054063          	bltz	a0,197a <bigargtest+0xc6>
    printf("%s: bigargtest: fork failed\n", s);
    exit(1);
  }
  
  wait(&xstatus);
    18de:	fdc40513          	addi	a0,s0,-36
    18e2:	00004097          	auipc	ra,0x4
    18e6:	f7a080e7          	jalr	-134(ra) # 585c <wait>
  if(xstatus != 0)
    18ea:	fdc42503          	lw	a0,-36(s0)
    18ee:	e545                	bnez	a0,1996 <bigargtest+0xe2>
    exit(xstatus);
  fd = open("bigarg-ok", 0);
    18f0:	4581                	li	a1,0
    18f2:	00005517          	auipc	a0,0x5
    18f6:	03e50513          	addi	a0,a0,62 # 6930 <malloc+0xc6e>
    18fa:	00004097          	auipc	ra,0x4
    18fe:	f9a080e7          	jalr	-102(ra) # 5894 <open>
  if(fd < 0){
    1902:	08054e63          	bltz	a0,199e <bigargtest+0xea>
    printf("%s: bigarg test failed!\n", s);
    exit(1);
  }
  close(fd);
    1906:	00004097          	auipc	ra,0x4
    190a:	f76080e7          	jalr	-138(ra) # 587c <close>
}
    190e:	70a2                	ld	ra,40(sp)
    1910:	7402                	ld	s0,32(sp)
    1912:	64e2                	ld	s1,24(sp)
    1914:	6145                	addi	sp,sp,48
    1916:	8082                	ret
    1918:	00007797          	auipc	a5,0x7
    191c:	ac078793          	addi	a5,a5,-1344 # 83d8 <args.1>
    1920:	00007697          	auipc	a3,0x7
    1924:	bb068693          	addi	a3,a3,-1104 # 84d0 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    1928:	00005717          	auipc	a4,0x5
    192c:	01870713          	addi	a4,a4,24 # 6940 <malloc+0xc7e>
    1930:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    1932:	07a1                	addi	a5,a5,8
    1934:	fed79ee3          	bne	a5,a3,1930 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    1938:	00007597          	auipc	a1,0x7
    193c:	aa058593          	addi	a1,a1,-1376 # 83d8 <args.1>
    1940:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    1944:	00005517          	auipc	a0,0x5
    1948:	86c50513          	addi	a0,a0,-1940 # 61b0 <malloc+0x4ee>
    194c:	00004097          	auipc	ra,0x4
    1950:	f40080e7          	jalr	-192(ra) # 588c <exec>
    fd = open("bigarg-ok", O_CREATE);
    1954:	20000593          	li	a1,512
    1958:	00005517          	auipc	a0,0x5
    195c:	fd850513          	addi	a0,a0,-40 # 6930 <malloc+0xc6e>
    1960:	00004097          	auipc	ra,0x4
    1964:	f34080e7          	jalr	-204(ra) # 5894 <open>
    close(fd);
    1968:	00004097          	auipc	ra,0x4
    196c:	f14080e7          	jalr	-236(ra) # 587c <close>
    exit(0);
    1970:	4501                	li	a0,0
    1972:	00004097          	auipc	ra,0x4
    1976:	ee2080e7          	jalr	-286(ra) # 5854 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    197a:	85a6                	mv	a1,s1
    197c:	00005517          	auipc	a0,0x5
    1980:	0a450513          	addi	a0,a0,164 # 6a20 <malloc+0xd5e>
    1984:	00004097          	auipc	ra,0x4
    1988:	280080e7          	jalr	640(ra) # 5c04 <printf>
    exit(1);
    198c:	4505                	li	a0,1
    198e:	00004097          	auipc	ra,0x4
    1992:	ec6080e7          	jalr	-314(ra) # 5854 <exit>
    exit(xstatus);
    1996:	00004097          	auipc	ra,0x4
    199a:	ebe080e7          	jalr	-322(ra) # 5854 <exit>
    printf("%s: bigarg test failed!\n", s);
    199e:	85a6                	mv	a1,s1
    19a0:	00005517          	auipc	a0,0x5
    19a4:	0a050513          	addi	a0,a0,160 # 6a40 <malloc+0xd7e>
    19a8:	00004097          	auipc	ra,0x4
    19ac:	25c080e7          	jalr	604(ra) # 5c04 <printf>
    exit(1);
    19b0:	4505                	li	a0,1
    19b2:	00004097          	auipc	ra,0x4
    19b6:	ea2080e7          	jalr	-350(ra) # 5854 <exit>

00000000000019ba <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    19ba:	7179                	addi	sp,sp,-48
    19bc:	f406                	sd	ra,40(sp)
    19be:	f022                	sd	s0,32(sp)
    19c0:	ec26                	sd	s1,24(sp)
    19c2:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    19c4:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    19c8:	00007497          	auipc	s1,0x7
    19cc:	9f04b483          	ld	s1,-1552(s1) # 83b8 <__SDATA_BEGIN__>
    19d0:	fd840593          	addi	a1,s0,-40
    19d4:	8526                	mv	a0,s1
    19d6:	00004097          	auipc	ra,0x4
    19da:	eb6080e7          	jalr	-330(ra) # 588c <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    19de:	8526                	mv	a0,s1
    19e0:	00004097          	auipc	ra,0x4
    19e4:	e84080e7          	jalr	-380(ra) # 5864 <pipe>

  exit(0);
    19e8:	4501                	li	a0,0
    19ea:	00004097          	auipc	ra,0x4
    19ee:	e6a080e7          	jalr	-406(ra) # 5854 <exit>

00000000000019f2 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    19f2:	7139                	addi	sp,sp,-64
    19f4:	fc06                	sd	ra,56(sp)
    19f6:	f822                	sd	s0,48(sp)
    19f8:	f426                	sd	s1,40(sp)
    19fa:	f04a                	sd	s2,32(sp)
    19fc:	ec4e                	sd	s3,24(sp)
    19fe:	0080                	addi	s0,sp,64
    1a00:	64b1                	lui	s1,0xc
    1a02:	35048493          	addi	s1,s1,848 # c350 <buf+0x760>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1a06:	597d                	li	s2,-1
    1a08:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    1a0c:	00004997          	auipc	s3,0x4
    1a10:	7a498993          	addi	s3,s3,1956 # 61b0 <malloc+0x4ee>
    argv[0] = (char*)0xffffffff;
    1a14:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1a18:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1a1c:	fc040593          	addi	a1,s0,-64
    1a20:	854e                	mv	a0,s3
    1a22:	00004097          	auipc	ra,0x4
    1a26:	e6a080e7          	jalr	-406(ra) # 588c <exec>
  for(int i = 0; i < 50000; i++){
    1a2a:	34fd                	addiw	s1,s1,-1
    1a2c:	f4e5                	bnez	s1,1a14 <badarg+0x22>
  }
  
  exit(0);
    1a2e:	4501                	li	a0,0
    1a30:	00004097          	auipc	ra,0x4
    1a34:	e24080e7          	jalr	-476(ra) # 5854 <exit>

0000000000001a38 <copyinstr3>:
{
    1a38:	7179                	addi	sp,sp,-48
    1a3a:	f406                	sd	ra,40(sp)
    1a3c:	f022                	sd	s0,32(sp)
    1a3e:	ec26                	sd	s1,24(sp)
    1a40:	1800                	addi	s0,sp,48
  sbrk(8192);
    1a42:	6509                	lui	a0,0x2
    1a44:	00004097          	auipc	ra,0x4
    1a48:	e98080e7          	jalr	-360(ra) # 58dc <sbrk>
  uint64 top = (uint64) sbrk(0);
    1a4c:	4501                	li	a0,0
    1a4e:	00004097          	auipc	ra,0x4
    1a52:	e8e080e7          	jalr	-370(ra) # 58dc <sbrk>
  if((top % PGSIZE) != 0){
    1a56:	03451793          	slli	a5,a0,0x34
    1a5a:	e3c9                	bnez	a5,1adc <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    1a5c:	4501                	li	a0,0
    1a5e:	00004097          	auipc	ra,0x4
    1a62:	e7e080e7          	jalr	-386(ra) # 58dc <sbrk>
  if(top % PGSIZE){
    1a66:	03451793          	slli	a5,a0,0x34
    1a6a:	e3d9                	bnez	a5,1af0 <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    1a6c:	fff50493          	addi	s1,a0,-1 # 1fff <fourteen+0xe5>
  *b = 'x';
    1a70:	07800793          	li	a5,120
    1a74:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    1a78:	8526                	mv	a0,s1
    1a7a:	00004097          	auipc	ra,0x4
    1a7e:	e2a080e7          	jalr	-470(ra) # 58a4 <unlink>
  if(ret != -1){
    1a82:	57fd                	li	a5,-1
    1a84:	08f51363          	bne	a0,a5,1b0a <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    1a88:	20100593          	li	a1,513
    1a8c:	8526                	mv	a0,s1
    1a8e:	00004097          	auipc	ra,0x4
    1a92:	e06080e7          	jalr	-506(ra) # 5894 <open>
  if(fd != -1){
    1a96:	57fd                	li	a5,-1
    1a98:	08f51863          	bne	a0,a5,1b28 <copyinstr3+0xf0>
  ret = link(b, b);
    1a9c:	85a6                	mv	a1,s1
    1a9e:	8526                	mv	a0,s1
    1aa0:	00004097          	auipc	ra,0x4
    1aa4:	e14080e7          	jalr	-492(ra) # 58b4 <link>
  if(ret != -1){
    1aa8:	57fd                	li	a5,-1
    1aaa:	08f51e63          	bne	a0,a5,1b46 <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    1aae:	00006797          	auipc	a5,0x6
    1ab2:	aaa78793          	addi	a5,a5,-1366 # 7558 <malloc+0x1896>
    1ab6:	fcf43823          	sd	a5,-48(s0)
    1aba:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    1abe:	fd040593          	addi	a1,s0,-48
    1ac2:	8526                	mv	a0,s1
    1ac4:	00004097          	auipc	ra,0x4
    1ac8:	dc8080e7          	jalr	-568(ra) # 588c <exec>
  if(ret != -1){
    1acc:	57fd                	li	a5,-1
    1ace:	08f51c63          	bne	a0,a5,1b66 <copyinstr3+0x12e>
}
    1ad2:	70a2                	ld	ra,40(sp)
    1ad4:	7402                	ld	s0,32(sp)
    1ad6:	64e2                	ld	s1,24(sp)
    1ad8:	6145                	addi	sp,sp,48
    1ada:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    1adc:	0347d513          	srli	a0,a5,0x34
    1ae0:	6785                	lui	a5,0x1
    1ae2:	40a7853b          	subw	a0,a5,a0
    1ae6:	00004097          	auipc	ra,0x4
    1aea:	df6080e7          	jalr	-522(ra) # 58dc <sbrk>
    1aee:	b7bd                	j	1a5c <copyinstr3+0x24>
    printf("oops\n");
    1af0:	00005517          	auipc	a0,0x5
    1af4:	f7050513          	addi	a0,a0,-144 # 6a60 <malloc+0xd9e>
    1af8:	00004097          	auipc	ra,0x4
    1afc:	10c080e7          	jalr	268(ra) # 5c04 <printf>
    exit(1);
    1b00:	4505                	li	a0,1
    1b02:	00004097          	auipc	ra,0x4
    1b06:	d52080e7          	jalr	-686(ra) # 5854 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    1b0a:	862a                	mv	a2,a0
    1b0c:	85a6                	mv	a1,s1
    1b0e:	00005517          	auipc	a0,0x5
    1b12:	c9250513          	addi	a0,a0,-878 # 67a0 <malloc+0xade>
    1b16:	00004097          	auipc	ra,0x4
    1b1a:	0ee080e7          	jalr	238(ra) # 5c04 <printf>
    exit(1);
    1b1e:	4505                	li	a0,1
    1b20:	00004097          	auipc	ra,0x4
    1b24:	d34080e7          	jalr	-716(ra) # 5854 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1b28:	862a                	mv	a2,a0
    1b2a:	85a6                	mv	a1,s1
    1b2c:	00005517          	auipc	a0,0x5
    1b30:	c9450513          	addi	a0,a0,-876 # 67c0 <malloc+0xafe>
    1b34:	00004097          	auipc	ra,0x4
    1b38:	0d0080e7          	jalr	208(ra) # 5c04 <printf>
    exit(1);
    1b3c:	4505                	li	a0,1
    1b3e:	00004097          	auipc	ra,0x4
    1b42:	d16080e7          	jalr	-746(ra) # 5854 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1b46:	86aa                	mv	a3,a0
    1b48:	8626                	mv	a2,s1
    1b4a:	85a6                	mv	a1,s1
    1b4c:	00005517          	auipc	a0,0x5
    1b50:	c9450513          	addi	a0,a0,-876 # 67e0 <malloc+0xb1e>
    1b54:	00004097          	auipc	ra,0x4
    1b58:	0b0080e7          	jalr	176(ra) # 5c04 <printf>
    exit(1);
    1b5c:	4505                	li	a0,1
    1b5e:	00004097          	auipc	ra,0x4
    1b62:	cf6080e7          	jalr	-778(ra) # 5854 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1b66:	567d                	li	a2,-1
    1b68:	85a6                	mv	a1,s1
    1b6a:	00005517          	auipc	a0,0x5
    1b6e:	c9e50513          	addi	a0,a0,-866 # 6808 <malloc+0xb46>
    1b72:	00004097          	auipc	ra,0x4
    1b76:	092080e7          	jalr	146(ra) # 5c04 <printf>
    exit(1);
    1b7a:	4505                	li	a0,1
    1b7c:	00004097          	auipc	ra,0x4
    1b80:	cd8080e7          	jalr	-808(ra) # 5854 <exit>

0000000000001b84 <rwsbrk>:
{
    1b84:	1101                	addi	sp,sp,-32
    1b86:	ec06                	sd	ra,24(sp)
    1b88:	e822                	sd	s0,16(sp)
    1b8a:	e426                	sd	s1,8(sp)
    1b8c:	e04a                	sd	s2,0(sp)
    1b8e:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    1b90:	6509                	lui	a0,0x2
    1b92:	00004097          	auipc	ra,0x4
    1b96:	d4a080e7          	jalr	-694(ra) # 58dc <sbrk>
  if(a == 0xffffffffffffffffLL) {
    1b9a:	57fd                	li	a5,-1
    1b9c:	06f50363          	beq	a0,a5,1c02 <rwsbrk+0x7e>
    1ba0:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    1ba2:	7579                	lui	a0,0xffffe
    1ba4:	00004097          	auipc	ra,0x4
    1ba8:	d38080e7          	jalr	-712(ra) # 58dc <sbrk>
    1bac:	57fd                	li	a5,-1
    1bae:	06f50763          	beq	a0,a5,1c1c <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    1bb2:	20100593          	li	a1,513
    1bb6:	00004517          	auipc	a0,0x4
    1bba:	27250513          	addi	a0,a0,626 # 5e28 <malloc+0x166>
    1bbe:	00004097          	auipc	ra,0x4
    1bc2:	cd6080e7          	jalr	-810(ra) # 5894 <open>
    1bc6:	892a                	mv	s2,a0
  if(fd < 0){
    1bc8:	06054763          	bltz	a0,1c36 <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    1bcc:	6505                	lui	a0,0x1
    1bce:	94aa                	add	s1,s1,a0
    1bd0:	40000613          	li	a2,1024
    1bd4:	85a6                	mv	a1,s1
    1bd6:	854a                	mv	a0,s2
    1bd8:	00004097          	auipc	ra,0x4
    1bdc:	c9c080e7          	jalr	-868(ra) # 5874 <write>
    1be0:	862a                	mv	a2,a0
  if(n >= 0){
    1be2:	06054763          	bltz	a0,1c50 <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    1be6:	85a6                	mv	a1,s1
    1be8:	00005517          	auipc	a0,0x5
    1bec:	ed050513          	addi	a0,a0,-304 # 6ab8 <malloc+0xdf6>
    1bf0:	00004097          	auipc	ra,0x4
    1bf4:	014080e7          	jalr	20(ra) # 5c04 <printf>
    exit(1);
    1bf8:	4505                	li	a0,1
    1bfa:	00004097          	auipc	ra,0x4
    1bfe:	c5a080e7          	jalr	-934(ra) # 5854 <exit>
    printf("sbrk(rwsbrk) failed\n");
    1c02:	00005517          	auipc	a0,0x5
    1c06:	e6650513          	addi	a0,a0,-410 # 6a68 <malloc+0xda6>
    1c0a:	00004097          	auipc	ra,0x4
    1c0e:	ffa080e7          	jalr	-6(ra) # 5c04 <printf>
    exit(1);
    1c12:	4505                	li	a0,1
    1c14:	00004097          	auipc	ra,0x4
    1c18:	c40080e7          	jalr	-960(ra) # 5854 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    1c1c:	00005517          	auipc	a0,0x5
    1c20:	e6450513          	addi	a0,a0,-412 # 6a80 <malloc+0xdbe>
    1c24:	00004097          	auipc	ra,0x4
    1c28:	fe0080e7          	jalr	-32(ra) # 5c04 <printf>
    exit(1);
    1c2c:	4505                	li	a0,1
    1c2e:	00004097          	auipc	ra,0x4
    1c32:	c26080e7          	jalr	-986(ra) # 5854 <exit>
    printf("open(rwsbrk) failed\n");
    1c36:	00005517          	auipc	a0,0x5
    1c3a:	e6a50513          	addi	a0,a0,-406 # 6aa0 <malloc+0xdde>
    1c3e:	00004097          	auipc	ra,0x4
    1c42:	fc6080e7          	jalr	-58(ra) # 5c04 <printf>
    exit(1);
    1c46:	4505                	li	a0,1
    1c48:	00004097          	auipc	ra,0x4
    1c4c:	c0c080e7          	jalr	-1012(ra) # 5854 <exit>
  close(fd);
    1c50:	854a                	mv	a0,s2
    1c52:	00004097          	auipc	ra,0x4
    1c56:	c2a080e7          	jalr	-982(ra) # 587c <close>
  unlink("rwsbrk");
    1c5a:	00004517          	auipc	a0,0x4
    1c5e:	1ce50513          	addi	a0,a0,462 # 5e28 <malloc+0x166>
    1c62:	00004097          	auipc	ra,0x4
    1c66:	c42080e7          	jalr	-958(ra) # 58a4 <unlink>
  fd = open("README", O_RDONLY);
    1c6a:	4581                	li	a1,0
    1c6c:	00004517          	auipc	a0,0x4
    1c70:	6ec50513          	addi	a0,a0,1772 # 6358 <malloc+0x696>
    1c74:	00004097          	auipc	ra,0x4
    1c78:	c20080e7          	jalr	-992(ra) # 5894 <open>
    1c7c:	892a                	mv	s2,a0
  if(fd < 0){
    1c7e:	02054963          	bltz	a0,1cb0 <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    1c82:	4629                	li	a2,10
    1c84:	85a6                	mv	a1,s1
    1c86:	00004097          	auipc	ra,0x4
    1c8a:	be6080e7          	jalr	-1050(ra) # 586c <read>
    1c8e:	862a                	mv	a2,a0
  if(n >= 0){
    1c90:	02054d63          	bltz	a0,1cca <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    1c94:	85a6                	mv	a1,s1
    1c96:	00005517          	auipc	a0,0x5
    1c9a:	e5250513          	addi	a0,a0,-430 # 6ae8 <malloc+0xe26>
    1c9e:	00004097          	auipc	ra,0x4
    1ca2:	f66080e7          	jalr	-154(ra) # 5c04 <printf>
    exit(1);
    1ca6:	4505                	li	a0,1
    1ca8:	00004097          	auipc	ra,0x4
    1cac:	bac080e7          	jalr	-1108(ra) # 5854 <exit>
    printf("open(rwsbrk) failed\n");
    1cb0:	00005517          	auipc	a0,0x5
    1cb4:	df050513          	addi	a0,a0,-528 # 6aa0 <malloc+0xdde>
    1cb8:	00004097          	auipc	ra,0x4
    1cbc:	f4c080e7          	jalr	-180(ra) # 5c04 <printf>
    exit(1);
    1cc0:	4505                	li	a0,1
    1cc2:	00004097          	auipc	ra,0x4
    1cc6:	b92080e7          	jalr	-1134(ra) # 5854 <exit>
  close(fd);
    1cca:	854a                	mv	a0,s2
    1ccc:	00004097          	auipc	ra,0x4
    1cd0:	bb0080e7          	jalr	-1104(ra) # 587c <close>
  exit(0);
    1cd4:	4501                	li	a0,0
    1cd6:	00004097          	auipc	ra,0x4
    1cda:	b7e080e7          	jalr	-1154(ra) # 5854 <exit>

0000000000001cde <sbrkarg>:
{
    1cde:	7179                	addi	sp,sp,-48
    1ce0:	f406                	sd	ra,40(sp)
    1ce2:	f022                	sd	s0,32(sp)
    1ce4:	ec26                	sd	s1,24(sp)
    1ce6:	e84a                	sd	s2,16(sp)
    1ce8:	e44e                	sd	s3,8(sp)
    1cea:	1800                	addi	s0,sp,48
    1cec:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    1cee:	6505                	lui	a0,0x1
    1cf0:	00004097          	auipc	ra,0x4
    1cf4:	bec080e7          	jalr	-1044(ra) # 58dc <sbrk>
    1cf8:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    1cfa:	20100593          	li	a1,513
    1cfe:	00005517          	auipc	a0,0x5
    1d02:	e1250513          	addi	a0,a0,-494 # 6b10 <malloc+0xe4e>
    1d06:	00004097          	auipc	ra,0x4
    1d0a:	b8e080e7          	jalr	-1138(ra) # 5894 <open>
    1d0e:	84aa                	mv	s1,a0
  unlink("sbrk");
    1d10:	00005517          	auipc	a0,0x5
    1d14:	e0050513          	addi	a0,a0,-512 # 6b10 <malloc+0xe4e>
    1d18:	00004097          	auipc	ra,0x4
    1d1c:	b8c080e7          	jalr	-1140(ra) # 58a4 <unlink>
  if(fd < 0)  {
    1d20:	0404c163          	bltz	s1,1d62 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    1d24:	6605                	lui	a2,0x1
    1d26:	85ca                	mv	a1,s2
    1d28:	8526                	mv	a0,s1
    1d2a:	00004097          	auipc	ra,0x4
    1d2e:	b4a080e7          	jalr	-1206(ra) # 5874 <write>
    1d32:	04054663          	bltz	a0,1d7e <sbrkarg+0xa0>
  close(fd);
    1d36:	8526                	mv	a0,s1
    1d38:	00004097          	auipc	ra,0x4
    1d3c:	b44080e7          	jalr	-1212(ra) # 587c <close>
  a = sbrk(PGSIZE);
    1d40:	6505                	lui	a0,0x1
    1d42:	00004097          	auipc	ra,0x4
    1d46:	b9a080e7          	jalr	-1126(ra) # 58dc <sbrk>
  if(pipe((int *) a) != 0){
    1d4a:	00004097          	auipc	ra,0x4
    1d4e:	b1a080e7          	jalr	-1254(ra) # 5864 <pipe>
    1d52:	e521                	bnez	a0,1d9a <sbrkarg+0xbc>
}
    1d54:	70a2                	ld	ra,40(sp)
    1d56:	7402                	ld	s0,32(sp)
    1d58:	64e2                	ld	s1,24(sp)
    1d5a:	6942                	ld	s2,16(sp)
    1d5c:	69a2                	ld	s3,8(sp)
    1d5e:	6145                	addi	sp,sp,48
    1d60:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    1d62:	85ce                	mv	a1,s3
    1d64:	00005517          	auipc	a0,0x5
    1d68:	db450513          	addi	a0,a0,-588 # 6b18 <malloc+0xe56>
    1d6c:	00004097          	auipc	ra,0x4
    1d70:	e98080e7          	jalr	-360(ra) # 5c04 <printf>
    exit(1);
    1d74:	4505                	li	a0,1
    1d76:	00004097          	auipc	ra,0x4
    1d7a:	ade080e7          	jalr	-1314(ra) # 5854 <exit>
    printf("%s: write sbrk failed\n", s);
    1d7e:	85ce                	mv	a1,s3
    1d80:	00005517          	auipc	a0,0x5
    1d84:	db050513          	addi	a0,a0,-592 # 6b30 <malloc+0xe6e>
    1d88:	00004097          	auipc	ra,0x4
    1d8c:	e7c080e7          	jalr	-388(ra) # 5c04 <printf>
    exit(1);
    1d90:	4505                	li	a0,1
    1d92:	00004097          	auipc	ra,0x4
    1d96:	ac2080e7          	jalr	-1342(ra) # 5854 <exit>
    printf("%s: pipe() failed\n", s);
    1d9a:	85ce                	mv	a1,s3
    1d9c:	00004517          	auipc	a0,0x4
    1da0:	6fc50513          	addi	a0,a0,1788 # 6498 <malloc+0x7d6>
    1da4:	00004097          	auipc	ra,0x4
    1da8:	e60080e7          	jalr	-416(ra) # 5c04 <printf>
    exit(1);
    1dac:	4505                	li	a0,1
    1dae:	00004097          	auipc	ra,0x4
    1db2:	aa6080e7          	jalr	-1370(ra) # 5854 <exit>

0000000000001db6 <argptest>:
{
    1db6:	1101                	addi	sp,sp,-32
    1db8:	ec06                	sd	ra,24(sp)
    1dba:	e822                	sd	s0,16(sp)
    1dbc:	e426                	sd	s1,8(sp)
    1dbe:	e04a                	sd	s2,0(sp)
    1dc0:	1000                	addi	s0,sp,32
    1dc2:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    1dc4:	4581                	li	a1,0
    1dc6:	00005517          	auipc	a0,0x5
    1dca:	d8250513          	addi	a0,a0,-638 # 6b48 <malloc+0xe86>
    1dce:	00004097          	auipc	ra,0x4
    1dd2:	ac6080e7          	jalr	-1338(ra) # 5894 <open>
  if (fd < 0) {
    1dd6:	02054b63          	bltz	a0,1e0c <argptest+0x56>
    1dda:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    1ddc:	4501                	li	a0,0
    1dde:	00004097          	auipc	ra,0x4
    1de2:	afe080e7          	jalr	-1282(ra) # 58dc <sbrk>
    1de6:	567d                	li	a2,-1
    1de8:	fff50593          	addi	a1,a0,-1
    1dec:	8526                	mv	a0,s1
    1dee:	00004097          	auipc	ra,0x4
    1df2:	a7e080e7          	jalr	-1410(ra) # 586c <read>
  close(fd);
    1df6:	8526                	mv	a0,s1
    1df8:	00004097          	auipc	ra,0x4
    1dfc:	a84080e7          	jalr	-1404(ra) # 587c <close>
}
    1e00:	60e2                	ld	ra,24(sp)
    1e02:	6442                	ld	s0,16(sp)
    1e04:	64a2                	ld	s1,8(sp)
    1e06:	6902                	ld	s2,0(sp)
    1e08:	6105                	addi	sp,sp,32
    1e0a:	8082                	ret
    printf("%s: open failed\n", s);
    1e0c:	85ca                	mv	a1,s2
    1e0e:	00005517          	auipc	a0,0x5
    1e12:	ada50513          	addi	a0,a0,-1318 # 68e8 <malloc+0xc26>
    1e16:	00004097          	auipc	ra,0x4
    1e1a:	dee080e7          	jalr	-530(ra) # 5c04 <printf>
    exit(1);
    1e1e:	4505                	li	a0,1
    1e20:	00004097          	auipc	ra,0x4
    1e24:	a34080e7          	jalr	-1484(ra) # 5854 <exit>

0000000000001e28 <openiputtest>:
{
    1e28:	7179                	addi	sp,sp,-48
    1e2a:	f406                	sd	ra,40(sp)
    1e2c:	f022                	sd	s0,32(sp)
    1e2e:	ec26                	sd	s1,24(sp)
    1e30:	1800                	addi	s0,sp,48
    1e32:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    1e34:	00005517          	auipc	a0,0x5
    1e38:	d1c50513          	addi	a0,a0,-740 # 6b50 <malloc+0xe8e>
    1e3c:	00004097          	auipc	ra,0x4
    1e40:	a80080e7          	jalr	-1408(ra) # 58bc <mkdir>
    1e44:	04054263          	bltz	a0,1e88 <openiputtest+0x60>
  pid = fork();
    1e48:	00004097          	auipc	ra,0x4
    1e4c:	a04080e7          	jalr	-1532(ra) # 584c <fork>
  if(pid < 0){
    1e50:	04054a63          	bltz	a0,1ea4 <openiputtest+0x7c>
  if(pid == 0){
    1e54:	e93d                	bnez	a0,1eca <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    1e56:	4589                	li	a1,2
    1e58:	00005517          	auipc	a0,0x5
    1e5c:	cf850513          	addi	a0,a0,-776 # 6b50 <malloc+0xe8e>
    1e60:	00004097          	auipc	ra,0x4
    1e64:	a34080e7          	jalr	-1484(ra) # 5894 <open>
    if(fd >= 0){
    1e68:	04054c63          	bltz	a0,1ec0 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    1e6c:	85a6                	mv	a1,s1
    1e6e:	00005517          	auipc	a0,0x5
    1e72:	d0250513          	addi	a0,a0,-766 # 6b70 <malloc+0xeae>
    1e76:	00004097          	auipc	ra,0x4
    1e7a:	d8e080e7          	jalr	-626(ra) # 5c04 <printf>
      exit(1);
    1e7e:	4505                	li	a0,1
    1e80:	00004097          	auipc	ra,0x4
    1e84:	9d4080e7          	jalr	-1580(ra) # 5854 <exit>
    printf("%s: mkdir oidir failed\n", s);
    1e88:	85a6                	mv	a1,s1
    1e8a:	00005517          	auipc	a0,0x5
    1e8e:	cce50513          	addi	a0,a0,-818 # 6b58 <malloc+0xe96>
    1e92:	00004097          	auipc	ra,0x4
    1e96:	d72080e7          	jalr	-654(ra) # 5c04 <printf>
    exit(1);
    1e9a:	4505                	li	a0,1
    1e9c:	00004097          	auipc	ra,0x4
    1ea0:	9b8080e7          	jalr	-1608(ra) # 5854 <exit>
    printf("%s: fork failed\n", s);
    1ea4:	85a6                	mv	a1,s1
    1ea6:	00004517          	auipc	a0,0x4
    1eaa:	19250513          	addi	a0,a0,402 # 6038 <malloc+0x376>
    1eae:	00004097          	auipc	ra,0x4
    1eb2:	d56080e7          	jalr	-682(ra) # 5c04 <printf>
    exit(1);
    1eb6:	4505                	li	a0,1
    1eb8:	00004097          	auipc	ra,0x4
    1ebc:	99c080e7          	jalr	-1636(ra) # 5854 <exit>
    exit(0);
    1ec0:	4501                	li	a0,0
    1ec2:	00004097          	auipc	ra,0x4
    1ec6:	992080e7          	jalr	-1646(ra) # 5854 <exit>
  sleep(1);
    1eca:	4505                	li	a0,1
    1ecc:	00004097          	auipc	ra,0x4
    1ed0:	a18080e7          	jalr	-1512(ra) # 58e4 <sleep>
  if(unlink("oidir") != 0){
    1ed4:	00005517          	auipc	a0,0x5
    1ed8:	c7c50513          	addi	a0,a0,-900 # 6b50 <malloc+0xe8e>
    1edc:	00004097          	auipc	ra,0x4
    1ee0:	9c8080e7          	jalr	-1592(ra) # 58a4 <unlink>
    1ee4:	cd19                	beqz	a0,1f02 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    1ee6:	85a6                	mv	a1,s1
    1ee8:	00005517          	auipc	a0,0x5
    1eec:	cb050513          	addi	a0,a0,-848 # 6b98 <malloc+0xed6>
    1ef0:	00004097          	auipc	ra,0x4
    1ef4:	d14080e7          	jalr	-748(ra) # 5c04 <printf>
    exit(1);
    1ef8:	4505                	li	a0,1
    1efa:	00004097          	auipc	ra,0x4
    1efe:	95a080e7          	jalr	-1702(ra) # 5854 <exit>
  wait(&xstatus);
    1f02:	fdc40513          	addi	a0,s0,-36
    1f06:	00004097          	auipc	ra,0x4
    1f0a:	956080e7          	jalr	-1706(ra) # 585c <wait>
  exit(xstatus);
    1f0e:	fdc42503          	lw	a0,-36(s0)
    1f12:	00004097          	auipc	ra,0x4
    1f16:	942080e7          	jalr	-1726(ra) # 5854 <exit>

0000000000001f1a <fourteen>:
{
    1f1a:	1101                	addi	sp,sp,-32
    1f1c:	ec06                	sd	ra,24(sp)
    1f1e:	e822                	sd	s0,16(sp)
    1f20:	e426                	sd	s1,8(sp)
    1f22:	1000                	addi	s0,sp,32
    1f24:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    1f26:	00005517          	auipc	a0,0x5
    1f2a:	e5a50513          	addi	a0,a0,-422 # 6d80 <malloc+0x10be>
    1f2e:	00004097          	auipc	ra,0x4
    1f32:	98e080e7          	jalr	-1650(ra) # 58bc <mkdir>
    1f36:	e165                	bnez	a0,2016 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    1f38:	00005517          	auipc	a0,0x5
    1f3c:	ca050513          	addi	a0,a0,-864 # 6bd8 <malloc+0xf16>
    1f40:	00004097          	auipc	ra,0x4
    1f44:	97c080e7          	jalr	-1668(ra) # 58bc <mkdir>
    1f48:	e56d                	bnez	a0,2032 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    1f4a:	20000593          	li	a1,512
    1f4e:	00005517          	auipc	a0,0x5
    1f52:	ce250513          	addi	a0,a0,-798 # 6c30 <malloc+0xf6e>
    1f56:	00004097          	auipc	ra,0x4
    1f5a:	93e080e7          	jalr	-1730(ra) # 5894 <open>
  if(fd < 0){
    1f5e:	0e054863          	bltz	a0,204e <fourteen+0x134>
  close(fd);
    1f62:	00004097          	auipc	ra,0x4
    1f66:	91a080e7          	jalr	-1766(ra) # 587c <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    1f6a:	4581                	li	a1,0
    1f6c:	00005517          	auipc	a0,0x5
    1f70:	d3c50513          	addi	a0,a0,-708 # 6ca8 <malloc+0xfe6>
    1f74:	00004097          	auipc	ra,0x4
    1f78:	920080e7          	jalr	-1760(ra) # 5894 <open>
  if(fd < 0){
    1f7c:	0e054763          	bltz	a0,206a <fourteen+0x150>
  close(fd);
    1f80:	00004097          	auipc	ra,0x4
    1f84:	8fc080e7          	jalr	-1796(ra) # 587c <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    1f88:	00005517          	auipc	a0,0x5
    1f8c:	d9050513          	addi	a0,a0,-624 # 6d18 <malloc+0x1056>
    1f90:	00004097          	auipc	ra,0x4
    1f94:	92c080e7          	jalr	-1748(ra) # 58bc <mkdir>
    1f98:	c57d                	beqz	a0,2086 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    1f9a:	00005517          	auipc	a0,0x5
    1f9e:	dd650513          	addi	a0,a0,-554 # 6d70 <malloc+0x10ae>
    1fa2:	00004097          	auipc	ra,0x4
    1fa6:	91a080e7          	jalr	-1766(ra) # 58bc <mkdir>
    1faa:	cd65                	beqz	a0,20a2 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    1fac:	00005517          	auipc	a0,0x5
    1fb0:	dc450513          	addi	a0,a0,-572 # 6d70 <malloc+0x10ae>
    1fb4:	00004097          	auipc	ra,0x4
    1fb8:	8f0080e7          	jalr	-1808(ra) # 58a4 <unlink>
  unlink("12345678901234/12345678901234");
    1fbc:	00005517          	auipc	a0,0x5
    1fc0:	d5c50513          	addi	a0,a0,-676 # 6d18 <malloc+0x1056>
    1fc4:	00004097          	auipc	ra,0x4
    1fc8:	8e0080e7          	jalr	-1824(ra) # 58a4 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    1fcc:	00005517          	auipc	a0,0x5
    1fd0:	cdc50513          	addi	a0,a0,-804 # 6ca8 <malloc+0xfe6>
    1fd4:	00004097          	auipc	ra,0x4
    1fd8:	8d0080e7          	jalr	-1840(ra) # 58a4 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    1fdc:	00005517          	auipc	a0,0x5
    1fe0:	c5450513          	addi	a0,a0,-940 # 6c30 <malloc+0xf6e>
    1fe4:	00004097          	auipc	ra,0x4
    1fe8:	8c0080e7          	jalr	-1856(ra) # 58a4 <unlink>
  unlink("12345678901234/123456789012345");
    1fec:	00005517          	auipc	a0,0x5
    1ff0:	bec50513          	addi	a0,a0,-1044 # 6bd8 <malloc+0xf16>
    1ff4:	00004097          	auipc	ra,0x4
    1ff8:	8b0080e7          	jalr	-1872(ra) # 58a4 <unlink>
  unlink("12345678901234");
    1ffc:	00005517          	auipc	a0,0x5
    2000:	d8450513          	addi	a0,a0,-636 # 6d80 <malloc+0x10be>
    2004:	00004097          	auipc	ra,0x4
    2008:	8a0080e7          	jalr	-1888(ra) # 58a4 <unlink>
}
    200c:	60e2                	ld	ra,24(sp)
    200e:	6442                	ld	s0,16(sp)
    2010:	64a2                	ld	s1,8(sp)
    2012:	6105                	addi	sp,sp,32
    2014:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2016:	85a6                	mv	a1,s1
    2018:	00005517          	auipc	a0,0x5
    201c:	b9850513          	addi	a0,a0,-1128 # 6bb0 <malloc+0xeee>
    2020:	00004097          	auipc	ra,0x4
    2024:	be4080e7          	jalr	-1052(ra) # 5c04 <printf>
    exit(1);
    2028:	4505                	li	a0,1
    202a:	00004097          	auipc	ra,0x4
    202e:	82a080e7          	jalr	-2006(ra) # 5854 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2032:	85a6                	mv	a1,s1
    2034:	00005517          	auipc	a0,0x5
    2038:	bc450513          	addi	a0,a0,-1084 # 6bf8 <malloc+0xf36>
    203c:	00004097          	auipc	ra,0x4
    2040:	bc8080e7          	jalr	-1080(ra) # 5c04 <printf>
    exit(1);
    2044:	4505                	li	a0,1
    2046:	00004097          	auipc	ra,0x4
    204a:	80e080e7          	jalr	-2034(ra) # 5854 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    204e:	85a6                	mv	a1,s1
    2050:	00005517          	auipc	a0,0x5
    2054:	c1050513          	addi	a0,a0,-1008 # 6c60 <malloc+0xf9e>
    2058:	00004097          	auipc	ra,0x4
    205c:	bac080e7          	jalr	-1108(ra) # 5c04 <printf>
    exit(1);
    2060:	4505                	li	a0,1
    2062:	00003097          	auipc	ra,0x3
    2066:	7f2080e7          	jalr	2034(ra) # 5854 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    206a:	85a6                	mv	a1,s1
    206c:	00005517          	auipc	a0,0x5
    2070:	c6c50513          	addi	a0,a0,-916 # 6cd8 <malloc+0x1016>
    2074:	00004097          	auipc	ra,0x4
    2078:	b90080e7          	jalr	-1136(ra) # 5c04 <printf>
    exit(1);
    207c:	4505                	li	a0,1
    207e:	00003097          	auipc	ra,0x3
    2082:	7d6080e7          	jalr	2006(ra) # 5854 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2086:	85a6                	mv	a1,s1
    2088:	00005517          	auipc	a0,0x5
    208c:	cb050513          	addi	a0,a0,-848 # 6d38 <malloc+0x1076>
    2090:	00004097          	auipc	ra,0x4
    2094:	b74080e7          	jalr	-1164(ra) # 5c04 <printf>
    exit(1);
    2098:	4505                	li	a0,1
    209a:	00003097          	auipc	ra,0x3
    209e:	7ba080e7          	jalr	1978(ra) # 5854 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    20a2:	85a6                	mv	a1,s1
    20a4:	00005517          	auipc	a0,0x5
    20a8:	cec50513          	addi	a0,a0,-788 # 6d90 <malloc+0x10ce>
    20ac:	00004097          	auipc	ra,0x4
    20b0:	b58080e7          	jalr	-1192(ra) # 5c04 <printf>
    exit(1);
    20b4:	4505                	li	a0,1
    20b6:	00003097          	auipc	ra,0x3
    20ba:	79e080e7          	jalr	1950(ra) # 5854 <exit>

00000000000020be <iputtest>:
{
    20be:	1101                	addi	sp,sp,-32
    20c0:	ec06                	sd	ra,24(sp)
    20c2:	e822                	sd	s0,16(sp)
    20c4:	e426                	sd	s1,8(sp)
    20c6:	1000                	addi	s0,sp,32
    20c8:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    20ca:	00005517          	auipc	a0,0x5
    20ce:	cfe50513          	addi	a0,a0,-770 # 6dc8 <malloc+0x1106>
    20d2:	00003097          	auipc	ra,0x3
    20d6:	7ea080e7          	jalr	2026(ra) # 58bc <mkdir>
    20da:	04054563          	bltz	a0,2124 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    20de:	00005517          	auipc	a0,0x5
    20e2:	cea50513          	addi	a0,a0,-790 # 6dc8 <malloc+0x1106>
    20e6:	00003097          	auipc	ra,0x3
    20ea:	7de080e7          	jalr	2014(ra) # 58c4 <chdir>
    20ee:	04054963          	bltz	a0,2140 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    20f2:	00005517          	auipc	a0,0x5
    20f6:	d1650513          	addi	a0,a0,-746 # 6e08 <malloc+0x1146>
    20fa:	00003097          	auipc	ra,0x3
    20fe:	7aa080e7          	jalr	1962(ra) # 58a4 <unlink>
    2102:	04054d63          	bltz	a0,215c <iputtest+0x9e>
  if(chdir("/") < 0){
    2106:	00005517          	auipc	a0,0x5
    210a:	d3250513          	addi	a0,a0,-718 # 6e38 <malloc+0x1176>
    210e:	00003097          	auipc	ra,0x3
    2112:	7b6080e7          	jalr	1974(ra) # 58c4 <chdir>
    2116:	06054163          	bltz	a0,2178 <iputtest+0xba>
}
    211a:	60e2                	ld	ra,24(sp)
    211c:	6442                	ld	s0,16(sp)
    211e:	64a2                	ld	s1,8(sp)
    2120:	6105                	addi	sp,sp,32
    2122:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2124:	85a6                	mv	a1,s1
    2126:	00005517          	auipc	a0,0x5
    212a:	caa50513          	addi	a0,a0,-854 # 6dd0 <malloc+0x110e>
    212e:	00004097          	auipc	ra,0x4
    2132:	ad6080e7          	jalr	-1322(ra) # 5c04 <printf>
    exit(1);
    2136:	4505                	li	a0,1
    2138:	00003097          	auipc	ra,0x3
    213c:	71c080e7          	jalr	1820(ra) # 5854 <exit>
    printf("%s: chdir iputdir failed\n", s);
    2140:	85a6                	mv	a1,s1
    2142:	00005517          	auipc	a0,0x5
    2146:	ca650513          	addi	a0,a0,-858 # 6de8 <malloc+0x1126>
    214a:	00004097          	auipc	ra,0x4
    214e:	aba080e7          	jalr	-1350(ra) # 5c04 <printf>
    exit(1);
    2152:	4505                	li	a0,1
    2154:	00003097          	auipc	ra,0x3
    2158:	700080e7          	jalr	1792(ra) # 5854 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    215c:	85a6                	mv	a1,s1
    215e:	00005517          	auipc	a0,0x5
    2162:	cba50513          	addi	a0,a0,-838 # 6e18 <malloc+0x1156>
    2166:	00004097          	auipc	ra,0x4
    216a:	a9e080e7          	jalr	-1378(ra) # 5c04 <printf>
    exit(1);
    216e:	4505                	li	a0,1
    2170:	00003097          	auipc	ra,0x3
    2174:	6e4080e7          	jalr	1764(ra) # 5854 <exit>
    printf("%s: chdir / failed\n", s);
    2178:	85a6                	mv	a1,s1
    217a:	00005517          	auipc	a0,0x5
    217e:	cc650513          	addi	a0,a0,-826 # 6e40 <malloc+0x117e>
    2182:	00004097          	auipc	ra,0x4
    2186:	a82080e7          	jalr	-1406(ra) # 5c04 <printf>
    exit(1);
    218a:	4505                	li	a0,1
    218c:	00003097          	auipc	ra,0x3
    2190:	6c8080e7          	jalr	1736(ra) # 5854 <exit>

0000000000002194 <exitiputtest>:
{
    2194:	7179                	addi	sp,sp,-48
    2196:	f406                	sd	ra,40(sp)
    2198:	f022                	sd	s0,32(sp)
    219a:	ec26                	sd	s1,24(sp)
    219c:	1800                	addi	s0,sp,48
    219e:	84aa                	mv	s1,a0
  pid = fork();
    21a0:	00003097          	auipc	ra,0x3
    21a4:	6ac080e7          	jalr	1708(ra) # 584c <fork>
  if(pid < 0){
    21a8:	04054663          	bltz	a0,21f4 <exitiputtest+0x60>
  if(pid == 0){
    21ac:	ed45                	bnez	a0,2264 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    21ae:	00005517          	auipc	a0,0x5
    21b2:	c1a50513          	addi	a0,a0,-998 # 6dc8 <malloc+0x1106>
    21b6:	00003097          	auipc	ra,0x3
    21ba:	706080e7          	jalr	1798(ra) # 58bc <mkdir>
    21be:	04054963          	bltz	a0,2210 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    21c2:	00005517          	auipc	a0,0x5
    21c6:	c0650513          	addi	a0,a0,-1018 # 6dc8 <malloc+0x1106>
    21ca:	00003097          	auipc	ra,0x3
    21ce:	6fa080e7          	jalr	1786(ra) # 58c4 <chdir>
    21d2:	04054d63          	bltz	a0,222c <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    21d6:	00005517          	auipc	a0,0x5
    21da:	c3250513          	addi	a0,a0,-974 # 6e08 <malloc+0x1146>
    21de:	00003097          	auipc	ra,0x3
    21e2:	6c6080e7          	jalr	1734(ra) # 58a4 <unlink>
    21e6:	06054163          	bltz	a0,2248 <exitiputtest+0xb4>
    exit(0);
    21ea:	4501                	li	a0,0
    21ec:	00003097          	auipc	ra,0x3
    21f0:	668080e7          	jalr	1640(ra) # 5854 <exit>
    printf("%s: fork failed\n", s);
    21f4:	85a6                	mv	a1,s1
    21f6:	00004517          	auipc	a0,0x4
    21fa:	e4250513          	addi	a0,a0,-446 # 6038 <malloc+0x376>
    21fe:	00004097          	auipc	ra,0x4
    2202:	a06080e7          	jalr	-1530(ra) # 5c04 <printf>
    exit(1);
    2206:	4505                	li	a0,1
    2208:	00003097          	auipc	ra,0x3
    220c:	64c080e7          	jalr	1612(ra) # 5854 <exit>
      printf("%s: mkdir failed\n", s);
    2210:	85a6                	mv	a1,s1
    2212:	00005517          	auipc	a0,0x5
    2216:	bbe50513          	addi	a0,a0,-1090 # 6dd0 <malloc+0x110e>
    221a:	00004097          	auipc	ra,0x4
    221e:	9ea080e7          	jalr	-1558(ra) # 5c04 <printf>
      exit(1);
    2222:	4505                	li	a0,1
    2224:	00003097          	auipc	ra,0x3
    2228:	630080e7          	jalr	1584(ra) # 5854 <exit>
      printf("%s: child chdir failed\n", s);
    222c:	85a6                	mv	a1,s1
    222e:	00005517          	auipc	a0,0x5
    2232:	c2a50513          	addi	a0,a0,-982 # 6e58 <malloc+0x1196>
    2236:	00004097          	auipc	ra,0x4
    223a:	9ce080e7          	jalr	-1586(ra) # 5c04 <printf>
      exit(1);
    223e:	4505                	li	a0,1
    2240:	00003097          	auipc	ra,0x3
    2244:	614080e7          	jalr	1556(ra) # 5854 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2248:	85a6                	mv	a1,s1
    224a:	00005517          	auipc	a0,0x5
    224e:	bce50513          	addi	a0,a0,-1074 # 6e18 <malloc+0x1156>
    2252:	00004097          	auipc	ra,0x4
    2256:	9b2080e7          	jalr	-1614(ra) # 5c04 <printf>
      exit(1);
    225a:	4505                	li	a0,1
    225c:	00003097          	auipc	ra,0x3
    2260:	5f8080e7          	jalr	1528(ra) # 5854 <exit>
  wait(&xstatus);
    2264:	fdc40513          	addi	a0,s0,-36
    2268:	00003097          	auipc	ra,0x3
    226c:	5f4080e7          	jalr	1524(ra) # 585c <wait>
  exit(xstatus);
    2270:	fdc42503          	lw	a0,-36(s0)
    2274:	00003097          	auipc	ra,0x3
    2278:	5e0080e7          	jalr	1504(ra) # 5854 <exit>

000000000000227c <dirtest>:
{
    227c:	1101                	addi	sp,sp,-32
    227e:	ec06                	sd	ra,24(sp)
    2280:	e822                	sd	s0,16(sp)
    2282:	e426                	sd	s1,8(sp)
    2284:	1000                	addi	s0,sp,32
    2286:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2288:	00005517          	auipc	a0,0x5
    228c:	be850513          	addi	a0,a0,-1048 # 6e70 <malloc+0x11ae>
    2290:	00003097          	auipc	ra,0x3
    2294:	62c080e7          	jalr	1580(ra) # 58bc <mkdir>
    2298:	04054563          	bltz	a0,22e2 <dirtest+0x66>
  if(chdir("dir0") < 0){
    229c:	00005517          	auipc	a0,0x5
    22a0:	bd450513          	addi	a0,a0,-1068 # 6e70 <malloc+0x11ae>
    22a4:	00003097          	auipc	ra,0x3
    22a8:	620080e7          	jalr	1568(ra) # 58c4 <chdir>
    22ac:	04054963          	bltz	a0,22fe <dirtest+0x82>
  if(chdir("..") < 0){
    22b0:	00005517          	auipc	a0,0x5
    22b4:	be050513          	addi	a0,a0,-1056 # 6e90 <malloc+0x11ce>
    22b8:	00003097          	auipc	ra,0x3
    22bc:	60c080e7          	jalr	1548(ra) # 58c4 <chdir>
    22c0:	04054d63          	bltz	a0,231a <dirtest+0x9e>
  if(unlink("dir0") < 0){
    22c4:	00005517          	auipc	a0,0x5
    22c8:	bac50513          	addi	a0,a0,-1108 # 6e70 <malloc+0x11ae>
    22cc:	00003097          	auipc	ra,0x3
    22d0:	5d8080e7          	jalr	1496(ra) # 58a4 <unlink>
    22d4:	06054163          	bltz	a0,2336 <dirtest+0xba>
}
    22d8:	60e2                	ld	ra,24(sp)
    22da:	6442                	ld	s0,16(sp)
    22dc:	64a2                	ld	s1,8(sp)
    22de:	6105                	addi	sp,sp,32
    22e0:	8082                	ret
    printf("%s: mkdir failed\n", s);
    22e2:	85a6                	mv	a1,s1
    22e4:	00005517          	auipc	a0,0x5
    22e8:	aec50513          	addi	a0,a0,-1300 # 6dd0 <malloc+0x110e>
    22ec:	00004097          	auipc	ra,0x4
    22f0:	918080e7          	jalr	-1768(ra) # 5c04 <printf>
    exit(1);
    22f4:	4505                	li	a0,1
    22f6:	00003097          	auipc	ra,0x3
    22fa:	55e080e7          	jalr	1374(ra) # 5854 <exit>
    printf("%s: chdir dir0 failed\n", s);
    22fe:	85a6                	mv	a1,s1
    2300:	00005517          	auipc	a0,0x5
    2304:	b7850513          	addi	a0,a0,-1160 # 6e78 <malloc+0x11b6>
    2308:	00004097          	auipc	ra,0x4
    230c:	8fc080e7          	jalr	-1796(ra) # 5c04 <printf>
    exit(1);
    2310:	4505                	li	a0,1
    2312:	00003097          	auipc	ra,0x3
    2316:	542080e7          	jalr	1346(ra) # 5854 <exit>
    printf("%s: chdir .. failed\n", s);
    231a:	85a6                	mv	a1,s1
    231c:	00005517          	auipc	a0,0x5
    2320:	b7c50513          	addi	a0,a0,-1156 # 6e98 <malloc+0x11d6>
    2324:	00004097          	auipc	ra,0x4
    2328:	8e0080e7          	jalr	-1824(ra) # 5c04 <printf>
    exit(1);
    232c:	4505                	li	a0,1
    232e:	00003097          	auipc	ra,0x3
    2332:	526080e7          	jalr	1318(ra) # 5854 <exit>
    printf("%s: unlink dir0 failed\n", s);
    2336:	85a6                	mv	a1,s1
    2338:	00005517          	auipc	a0,0x5
    233c:	b7850513          	addi	a0,a0,-1160 # 6eb0 <malloc+0x11ee>
    2340:	00004097          	auipc	ra,0x4
    2344:	8c4080e7          	jalr	-1852(ra) # 5c04 <printf>
    exit(1);
    2348:	4505                	li	a0,1
    234a:	00003097          	auipc	ra,0x3
    234e:	50a080e7          	jalr	1290(ra) # 5854 <exit>

0000000000002352 <subdir>:
{
    2352:	1101                	addi	sp,sp,-32
    2354:	ec06                	sd	ra,24(sp)
    2356:	e822                	sd	s0,16(sp)
    2358:	e426                	sd	s1,8(sp)
    235a:	e04a                	sd	s2,0(sp)
    235c:	1000                	addi	s0,sp,32
    235e:	892a                	mv	s2,a0
  unlink("ff");
    2360:	00005517          	auipc	a0,0x5
    2364:	c9850513          	addi	a0,a0,-872 # 6ff8 <malloc+0x1336>
    2368:	00003097          	auipc	ra,0x3
    236c:	53c080e7          	jalr	1340(ra) # 58a4 <unlink>
  if(mkdir("dd") != 0){
    2370:	00005517          	auipc	a0,0x5
    2374:	b5850513          	addi	a0,a0,-1192 # 6ec8 <malloc+0x1206>
    2378:	00003097          	auipc	ra,0x3
    237c:	544080e7          	jalr	1348(ra) # 58bc <mkdir>
    2380:	38051663          	bnez	a0,270c <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2384:	20200593          	li	a1,514
    2388:	00005517          	auipc	a0,0x5
    238c:	b6050513          	addi	a0,a0,-1184 # 6ee8 <malloc+0x1226>
    2390:	00003097          	auipc	ra,0x3
    2394:	504080e7          	jalr	1284(ra) # 5894 <open>
    2398:	84aa                	mv	s1,a0
  if(fd < 0){
    239a:	38054763          	bltz	a0,2728 <subdir+0x3d6>
  write(fd, "ff", 2);
    239e:	4609                	li	a2,2
    23a0:	00005597          	auipc	a1,0x5
    23a4:	c5858593          	addi	a1,a1,-936 # 6ff8 <malloc+0x1336>
    23a8:	00003097          	auipc	ra,0x3
    23ac:	4cc080e7          	jalr	1228(ra) # 5874 <write>
  close(fd);
    23b0:	8526                	mv	a0,s1
    23b2:	00003097          	auipc	ra,0x3
    23b6:	4ca080e7          	jalr	1226(ra) # 587c <close>
  if(unlink("dd") >= 0){
    23ba:	00005517          	auipc	a0,0x5
    23be:	b0e50513          	addi	a0,a0,-1266 # 6ec8 <malloc+0x1206>
    23c2:	00003097          	auipc	ra,0x3
    23c6:	4e2080e7          	jalr	1250(ra) # 58a4 <unlink>
    23ca:	36055d63          	bgez	a0,2744 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    23ce:	00005517          	auipc	a0,0x5
    23d2:	b7250513          	addi	a0,a0,-1166 # 6f40 <malloc+0x127e>
    23d6:	00003097          	auipc	ra,0x3
    23da:	4e6080e7          	jalr	1254(ra) # 58bc <mkdir>
    23de:	38051163          	bnez	a0,2760 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    23e2:	20200593          	li	a1,514
    23e6:	00005517          	auipc	a0,0x5
    23ea:	b8250513          	addi	a0,a0,-1150 # 6f68 <malloc+0x12a6>
    23ee:	00003097          	auipc	ra,0x3
    23f2:	4a6080e7          	jalr	1190(ra) # 5894 <open>
    23f6:	84aa                	mv	s1,a0
  if(fd < 0){
    23f8:	38054263          	bltz	a0,277c <subdir+0x42a>
  write(fd, "FF", 2);
    23fc:	4609                	li	a2,2
    23fe:	00005597          	auipc	a1,0x5
    2402:	b9a58593          	addi	a1,a1,-1126 # 6f98 <malloc+0x12d6>
    2406:	00003097          	auipc	ra,0x3
    240a:	46e080e7          	jalr	1134(ra) # 5874 <write>
  close(fd);
    240e:	8526                	mv	a0,s1
    2410:	00003097          	auipc	ra,0x3
    2414:	46c080e7          	jalr	1132(ra) # 587c <close>
  fd = open("dd/dd/../ff", 0);
    2418:	4581                	li	a1,0
    241a:	00005517          	auipc	a0,0x5
    241e:	b8650513          	addi	a0,a0,-1146 # 6fa0 <malloc+0x12de>
    2422:	00003097          	auipc	ra,0x3
    2426:	472080e7          	jalr	1138(ra) # 5894 <open>
    242a:	84aa                	mv	s1,a0
  if(fd < 0){
    242c:	36054663          	bltz	a0,2798 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    2430:	660d                	lui	a2,0x3
    2432:	00009597          	auipc	a1,0x9
    2436:	7be58593          	addi	a1,a1,1982 # bbf0 <buf>
    243a:	00003097          	auipc	ra,0x3
    243e:	432080e7          	jalr	1074(ra) # 586c <read>
  if(cc != 2 || buf[0] != 'f'){
    2442:	4789                	li	a5,2
    2444:	36f51863          	bne	a0,a5,27b4 <subdir+0x462>
    2448:	00009717          	auipc	a4,0x9
    244c:	7a874703          	lbu	a4,1960(a4) # bbf0 <buf>
    2450:	06600793          	li	a5,102
    2454:	36f71063          	bne	a4,a5,27b4 <subdir+0x462>
  close(fd);
    2458:	8526                	mv	a0,s1
    245a:	00003097          	auipc	ra,0x3
    245e:	422080e7          	jalr	1058(ra) # 587c <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2462:	00005597          	auipc	a1,0x5
    2466:	b8e58593          	addi	a1,a1,-1138 # 6ff0 <malloc+0x132e>
    246a:	00005517          	auipc	a0,0x5
    246e:	afe50513          	addi	a0,a0,-1282 # 6f68 <malloc+0x12a6>
    2472:	00003097          	auipc	ra,0x3
    2476:	442080e7          	jalr	1090(ra) # 58b4 <link>
    247a:	34051b63          	bnez	a0,27d0 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    247e:	00005517          	auipc	a0,0x5
    2482:	aea50513          	addi	a0,a0,-1302 # 6f68 <malloc+0x12a6>
    2486:	00003097          	auipc	ra,0x3
    248a:	41e080e7          	jalr	1054(ra) # 58a4 <unlink>
    248e:	34051f63          	bnez	a0,27ec <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2492:	4581                	li	a1,0
    2494:	00005517          	auipc	a0,0x5
    2498:	ad450513          	addi	a0,a0,-1324 # 6f68 <malloc+0x12a6>
    249c:	00003097          	auipc	ra,0x3
    24a0:	3f8080e7          	jalr	1016(ra) # 5894 <open>
    24a4:	36055263          	bgez	a0,2808 <subdir+0x4b6>
  if(chdir("dd") != 0){
    24a8:	00005517          	auipc	a0,0x5
    24ac:	a2050513          	addi	a0,a0,-1504 # 6ec8 <malloc+0x1206>
    24b0:	00003097          	auipc	ra,0x3
    24b4:	414080e7          	jalr	1044(ra) # 58c4 <chdir>
    24b8:	36051663          	bnez	a0,2824 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    24bc:	00005517          	auipc	a0,0x5
    24c0:	bcc50513          	addi	a0,a0,-1076 # 7088 <malloc+0x13c6>
    24c4:	00003097          	auipc	ra,0x3
    24c8:	400080e7          	jalr	1024(ra) # 58c4 <chdir>
    24cc:	36051a63          	bnez	a0,2840 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    24d0:	00005517          	auipc	a0,0x5
    24d4:	be850513          	addi	a0,a0,-1048 # 70b8 <malloc+0x13f6>
    24d8:	00003097          	auipc	ra,0x3
    24dc:	3ec080e7          	jalr	1004(ra) # 58c4 <chdir>
    24e0:	36051e63          	bnez	a0,285c <subdir+0x50a>
  if(chdir("./..") != 0){
    24e4:	00005517          	auipc	a0,0x5
    24e8:	c0450513          	addi	a0,a0,-1020 # 70e8 <malloc+0x1426>
    24ec:	00003097          	auipc	ra,0x3
    24f0:	3d8080e7          	jalr	984(ra) # 58c4 <chdir>
    24f4:	38051263          	bnez	a0,2878 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    24f8:	4581                	li	a1,0
    24fa:	00005517          	auipc	a0,0x5
    24fe:	af650513          	addi	a0,a0,-1290 # 6ff0 <malloc+0x132e>
    2502:	00003097          	auipc	ra,0x3
    2506:	392080e7          	jalr	914(ra) # 5894 <open>
    250a:	84aa                	mv	s1,a0
  if(fd < 0){
    250c:	38054463          	bltz	a0,2894 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    2510:	660d                	lui	a2,0x3
    2512:	00009597          	auipc	a1,0x9
    2516:	6de58593          	addi	a1,a1,1758 # bbf0 <buf>
    251a:	00003097          	auipc	ra,0x3
    251e:	352080e7          	jalr	850(ra) # 586c <read>
    2522:	4789                	li	a5,2
    2524:	38f51663          	bne	a0,a5,28b0 <subdir+0x55e>
  close(fd);
    2528:	8526                	mv	a0,s1
    252a:	00003097          	auipc	ra,0x3
    252e:	352080e7          	jalr	850(ra) # 587c <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2532:	4581                	li	a1,0
    2534:	00005517          	auipc	a0,0x5
    2538:	a3450513          	addi	a0,a0,-1484 # 6f68 <malloc+0x12a6>
    253c:	00003097          	auipc	ra,0x3
    2540:	358080e7          	jalr	856(ra) # 5894 <open>
    2544:	38055463          	bgez	a0,28cc <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    2548:	20200593          	li	a1,514
    254c:	00005517          	auipc	a0,0x5
    2550:	c2c50513          	addi	a0,a0,-980 # 7178 <malloc+0x14b6>
    2554:	00003097          	auipc	ra,0x3
    2558:	340080e7          	jalr	832(ra) # 5894 <open>
    255c:	38055663          	bgez	a0,28e8 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    2560:	20200593          	li	a1,514
    2564:	00005517          	auipc	a0,0x5
    2568:	c4450513          	addi	a0,a0,-956 # 71a8 <malloc+0x14e6>
    256c:	00003097          	auipc	ra,0x3
    2570:	328080e7          	jalr	808(ra) # 5894 <open>
    2574:	38055863          	bgez	a0,2904 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    2578:	20000593          	li	a1,512
    257c:	00005517          	auipc	a0,0x5
    2580:	94c50513          	addi	a0,a0,-1716 # 6ec8 <malloc+0x1206>
    2584:	00003097          	auipc	ra,0x3
    2588:	310080e7          	jalr	784(ra) # 5894 <open>
    258c:	38055a63          	bgez	a0,2920 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    2590:	4589                	li	a1,2
    2592:	00005517          	auipc	a0,0x5
    2596:	93650513          	addi	a0,a0,-1738 # 6ec8 <malloc+0x1206>
    259a:	00003097          	auipc	ra,0x3
    259e:	2fa080e7          	jalr	762(ra) # 5894 <open>
    25a2:	38055d63          	bgez	a0,293c <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    25a6:	4585                	li	a1,1
    25a8:	00005517          	auipc	a0,0x5
    25ac:	92050513          	addi	a0,a0,-1760 # 6ec8 <malloc+0x1206>
    25b0:	00003097          	auipc	ra,0x3
    25b4:	2e4080e7          	jalr	740(ra) # 5894 <open>
    25b8:	3a055063          	bgez	a0,2958 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    25bc:	00005597          	auipc	a1,0x5
    25c0:	c7c58593          	addi	a1,a1,-900 # 7238 <malloc+0x1576>
    25c4:	00005517          	auipc	a0,0x5
    25c8:	bb450513          	addi	a0,a0,-1100 # 7178 <malloc+0x14b6>
    25cc:	00003097          	auipc	ra,0x3
    25d0:	2e8080e7          	jalr	744(ra) # 58b4 <link>
    25d4:	3a050063          	beqz	a0,2974 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    25d8:	00005597          	auipc	a1,0x5
    25dc:	c6058593          	addi	a1,a1,-928 # 7238 <malloc+0x1576>
    25e0:	00005517          	auipc	a0,0x5
    25e4:	bc850513          	addi	a0,a0,-1080 # 71a8 <malloc+0x14e6>
    25e8:	00003097          	auipc	ra,0x3
    25ec:	2cc080e7          	jalr	716(ra) # 58b4 <link>
    25f0:	3a050063          	beqz	a0,2990 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    25f4:	00005597          	auipc	a1,0x5
    25f8:	9fc58593          	addi	a1,a1,-1540 # 6ff0 <malloc+0x132e>
    25fc:	00005517          	auipc	a0,0x5
    2600:	8ec50513          	addi	a0,a0,-1812 # 6ee8 <malloc+0x1226>
    2604:	00003097          	auipc	ra,0x3
    2608:	2b0080e7          	jalr	688(ra) # 58b4 <link>
    260c:	3a050063          	beqz	a0,29ac <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    2610:	00005517          	auipc	a0,0x5
    2614:	b6850513          	addi	a0,a0,-1176 # 7178 <malloc+0x14b6>
    2618:	00003097          	auipc	ra,0x3
    261c:	2a4080e7          	jalr	676(ra) # 58bc <mkdir>
    2620:	3a050463          	beqz	a0,29c8 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    2624:	00005517          	auipc	a0,0x5
    2628:	b8450513          	addi	a0,a0,-1148 # 71a8 <malloc+0x14e6>
    262c:	00003097          	auipc	ra,0x3
    2630:	290080e7          	jalr	656(ra) # 58bc <mkdir>
    2634:	3a050863          	beqz	a0,29e4 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    2638:	00005517          	auipc	a0,0x5
    263c:	9b850513          	addi	a0,a0,-1608 # 6ff0 <malloc+0x132e>
    2640:	00003097          	auipc	ra,0x3
    2644:	27c080e7          	jalr	636(ra) # 58bc <mkdir>
    2648:	3a050c63          	beqz	a0,2a00 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    264c:	00005517          	auipc	a0,0x5
    2650:	b5c50513          	addi	a0,a0,-1188 # 71a8 <malloc+0x14e6>
    2654:	00003097          	auipc	ra,0x3
    2658:	250080e7          	jalr	592(ra) # 58a4 <unlink>
    265c:	3c050063          	beqz	a0,2a1c <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    2660:	00005517          	auipc	a0,0x5
    2664:	b1850513          	addi	a0,a0,-1256 # 7178 <malloc+0x14b6>
    2668:	00003097          	auipc	ra,0x3
    266c:	23c080e7          	jalr	572(ra) # 58a4 <unlink>
    2670:	3c050463          	beqz	a0,2a38 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    2674:	00005517          	auipc	a0,0x5
    2678:	87450513          	addi	a0,a0,-1932 # 6ee8 <malloc+0x1226>
    267c:	00003097          	auipc	ra,0x3
    2680:	248080e7          	jalr	584(ra) # 58c4 <chdir>
    2684:	3c050863          	beqz	a0,2a54 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    2688:	00005517          	auipc	a0,0x5
    268c:	d0050513          	addi	a0,a0,-768 # 7388 <malloc+0x16c6>
    2690:	00003097          	auipc	ra,0x3
    2694:	234080e7          	jalr	564(ra) # 58c4 <chdir>
    2698:	3c050c63          	beqz	a0,2a70 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    269c:	00005517          	auipc	a0,0x5
    26a0:	95450513          	addi	a0,a0,-1708 # 6ff0 <malloc+0x132e>
    26a4:	00003097          	auipc	ra,0x3
    26a8:	200080e7          	jalr	512(ra) # 58a4 <unlink>
    26ac:	3e051063          	bnez	a0,2a8c <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    26b0:	00005517          	auipc	a0,0x5
    26b4:	83850513          	addi	a0,a0,-1992 # 6ee8 <malloc+0x1226>
    26b8:	00003097          	auipc	ra,0x3
    26bc:	1ec080e7          	jalr	492(ra) # 58a4 <unlink>
    26c0:	3e051463          	bnez	a0,2aa8 <subdir+0x756>
  if(unlink("dd") == 0){
    26c4:	00005517          	auipc	a0,0x5
    26c8:	80450513          	addi	a0,a0,-2044 # 6ec8 <malloc+0x1206>
    26cc:	00003097          	auipc	ra,0x3
    26d0:	1d8080e7          	jalr	472(ra) # 58a4 <unlink>
    26d4:	3e050863          	beqz	a0,2ac4 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    26d8:	00005517          	auipc	a0,0x5
    26dc:	d2050513          	addi	a0,a0,-736 # 73f8 <malloc+0x1736>
    26e0:	00003097          	auipc	ra,0x3
    26e4:	1c4080e7          	jalr	452(ra) # 58a4 <unlink>
    26e8:	3e054c63          	bltz	a0,2ae0 <subdir+0x78e>
  if(unlink("dd") < 0){
    26ec:	00004517          	auipc	a0,0x4
    26f0:	7dc50513          	addi	a0,a0,2012 # 6ec8 <malloc+0x1206>
    26f4:	00003097          	auipc	ra,0x3
    26f8:	1b0080e7          	jalr	432(ra) # 58a4 <unlink>
    26fc:	40054063          	bltz	a0,2afc <subdir+0x7aa>
}
    2700:	60e2                	ld	ra,24(sp)
    2702:	6442                	ld	s0,16(sp)
    2704:	64a2                	ld	s1,8(sp)
    2706:	6902                	ld	s2,0(sp)
    2708:	6105                	addi	sp,sp,32
    270a:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    270c:	85ca                	mv	a1,s2
    270e:	00004517          	auipc	a0,0x4
    2712:	7c250513          	addi	a0,a0,1986 # 6ed0 <malloc+0x120e>
    2716:	00003097          	auipc	ra,0x3
    271a:	4ee080e7          	jalr	1262(ra) # 5c04 <printf>
    exit(1);
    271e:	4505                	li	a0,1
    2720:	00003097          	auipc	ra,0x3
    2724:	134080e7          	jalr	308(ra) # 5854 <exit>
    printf("%s: create dd/ff failed\n", s);
    2728:	85ca                	mv	a1,s2
    272a:	00004517          	auipc	a0,0x4
    272e:	7c650513          	addi	a0,a0,1990 # 6ef0 <malloc+0x122e>
    2732:	00003097          	auipc	ra,0x3
    2736:	4d2080e7          	jalr	1234(ra) # 5c04 <printf>
    exit(1);
    273a:	4505                	li	a0,1
    273c:	00003097          	auipc	ra,0x3
    2740:	118080e7          	jalr	280(ra) # 5854 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    2744:	85ca                	mv	a1,s2
    2746:	00004517          	auipc	a0,0x4
    274a:	7ca50513          	addi	a0,a0,1994 # 6f10 <malloc+0x124e>
    274e:	00003097          	auipc	ra,0x3
    2752:	4b6080e7          	jalr	1206(ra) # 5c04 <printf>
    exit(1);
    2756:	4505                	li	a0,1
    2758:	00003097          	auipc	ra,0x3
    275c:	0fc080e7          	jalr	252(ra) # 5854 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    2760:	85ca                	mv	a1,s2
    2762:	00004517          	auipc	a0,0x4
    2766:	7e650513          	addi	a0,a0,2022 # 6f48 <malloc+0x1286>
    276a:	00003097          	auipc	ra,0x3
    276e:	49a080e7          	jalr	1178(ra) # 5c04 <printf>
    exit(1);
    2772:	4505                	li	a0,1
    2774:	00003097          	auipc	ra,0x3
    2778:	0e0080e7          	jalr	224(ra) # 5854 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    277c:	85ca                	mv	a1,s2
    277e:	00004517          	auipc	a0,0x4
    2782:	7fa50513          	addi	a0,a0,2042 # 6f78 <malloc+0x12b6>
    2786:	00003097          	auipc	ra,0x3
    278a:	47e080e7          	jalr	1150(ra) # 5c04 <printf>
    exit(1);
    278e:	4505                	li	a0,1
    2790:	00003097          	auipc	ra,0x3
    2794:	0c4080e7          	jalr	196(ra) # 5854 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    2798:	85ca                	mv	a1,s2
    279a:	00005517          	auipc	a0,0x5
    279e:	81650513          	addi	a0,a0,-2026 # 6fb0 <malloc+0x12ee>
    27a2:	00003097          	auipc	ra,0x3
    27a6:	462080e7          	jalr	1122(ra) # 5c04 <printf>
    exit(1);
    27aa:	4505                	li	a0,1
    27ac:	00003097          	auipc	ra,0x3
    27b0:	0a8080e7          	jalr	168(ra) # 5854 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    27b4:	85ca                	mv	a1,s2
    27b6:	00005517          	auipc	a0,0x5
    27ba:	81a50513          	addi	a0,a0,-2022 # 6fd0 <malloc+0x130e>
    27be:	00003097          	auipc	ra,0x3
    27c2:	446080e7          	jalr	1094(ra) # 5c04 <printf>
    exit(1);
    27c6:	4505                	li	a0,1
    27c8:	00003097          	auipc	ra,0x3
    27cc:	08c080e7          	jalr	140(ra) # 5854 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    27d0:	85ca                	mv	a1,s2
    27d2:	00005517          	auipc	a0,0x5
    27d6:	82e50513          	addi	a0,a0,-2002 # 7000 <malloc+0x133e>
    27da:	00003097          	auipc	ra,0x3
    27de:	42a080e7          	jalr	1066(ra) # 5c04 <printf>
    exit(1);
    27e2:	4505                	li	a0,1
    27e4:	00003097          	auipc	ra,0x3
    27e8:	070080e7          	jalr	112(ra) # 5854 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    27ec:	85ca                	mv	a1,s2
    27ee:	00005517          	auipc	a0,0x5
    27f2:	83a50513          	addi	a0,a0,-1990 # 7028 <malloc+0x1366>
    27f6:	00003097          	auipc	ra,0x3
    27fa:	40e080e7          	jalr	1038(ra) # 5c04 <printf>
    exit(1);
    27fe:	4505                	li	a0,1
    2800:	00003097          	auipc	ra,0x3
    2804:	054080e7          	jalr	84(ra) # 5854 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    2808:	85ca                	mv	a1,s2
    280a:	00005517          	auipc	a0,0x5
    280e:	83e50513          	addi	a0,a0,-1986 # 7048 <malloc+0x1386>
    2812:	00003097          	auipc	ra,0x3
    2816:	3f2080e7          	jalr	1010(ra) # 5c04 <printf>
    exit(1);
    281a:	4505                	li	a0,1
    281c:	00003097          	auipc	ra,0x3
    2820:	038080e7          	jalr	56(ra) # 5854 <exit>
    printf("%s: chdir dd failed\n", s);
    2824:	85ca                	mv	a1,s2
    2826:	00005517          	auipc	a0,0x5
    282a:	84a50513          	addi	a0,a0,-1974 # 7070 <malloc+0x13ae>
    282e:	00003097          	auipc	ra,0x3
    2832:	3d6080e7          	jalr	982(ra) # 5c04 <printf>
    exit(1);
    2836:	4505                	li	a0,1
    2838:	00003097          	auipc	ra,0x3
    283c:	01c080e7          	jalr	28(ra) # 5854 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    2840:	85ca                	mv	a1,s2
    2842:	00005517          	auipc	a0,0x5
    2846:	85650513          	addi	a0,a0,-1962 # 7098 <malloc+0x13d6>
    284a:	00003097          	auipc	ra,0x3
    284e:	3ba080e7          	jalr	954(ra) # 5c04 <printf>
    exit(1);
    2852:	4505                	li	a0,1
    2854:	00003097          	auipc	ra,0x3
    2858:	000080e7          	jalr	ra # 5854 <exit>
    printf("chdir dd/../../dd failed\n", s);
    285c:	85ca                	mv	a1,s2
    285e:	00005517          	auipc	a0,0x5
    2862:	86a50513          	addi	a0,a0,-1942 # 70c8 <malloc+0x1406>
    2866:	00003097          	auipc	ra,0x3
    286a:	39e080e7          	jalr	926(ra) # 5c04 <printf>
    exit(1);
    286e:	4505                	li	a0,1
    2870:	00003097          	auipc	ra,0x3
    2874:	fe4080e7          	jalr	-28(ra) # 5854 <exit>
    printf("%s: chdir ./.. failed\n", s);
    2878:	85ca                	mv	a1,s2
    287a:	00005517          	auipc	a0,0x5
    287e:	87650513          	addi	a0,a0,-1930 # 70f0 <malloc+0x142e>
    2882:	00003097          	auipc	ra,0x3
    2886:	382080e7          	jalr	898(ra) # 5c04 <printf>
    exit(1);
    288a:	4505                	li	a0,1
    288c:	00003097          	auipc	ra,0x3
    2890:	fc8080e7          	jalr	-56(ra) # 5854 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    2894:	85ca                	mv	a1,s2
    2896:	00005517          	auipc	a0,0x5
    289a:	87250513          	addi	a0,a0,-1934 # 7108 <malloc+0x1446>
    289e:	00003097          	auipc	ra,0x3
    28a2:	366080e7          	jalr	870(ra) # 5c04 <printf>
    exit(1);
    28a6:	4505                	li	a0,1
    28a8:	00003097          	auipc	ra,0x3
    28ac:	fac080e7          	jalr	-84(ra) # 5854 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    28b0:	85ca                	mv	a1,s2
    28b2:	00005517          	auipc	a0,0x5
    28b6:	87650513          	addi	a0,a0,-1930 # 7128 <malloc+0x1466>
    28ba:	00003097          	auipc	ra,0x3
    28be:	34a080e7          	jalr	842(ra) # 5c04 <printf>
    exit(1);
    28c2:	4505                	li	a0,1
    28c4:	00003097          	auipc	ra,0x3
    28c8:	f90080e7          	jalr	-112(ra) # 5854 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    28cc:	85ca                	mv	a1,s2
    28ce:	00005517          	auipc	a0,0x5
    28d2:	87a50513          	addi	a0,a0,-1926 # 7148 <malloc+0x1486>
    28d6:	00003097          	auipc	ra,0x3
    28da:	32e080e7          	jalr	814(ra) # 5c04 <printf>
    exit(1);
    28de:	4505                	li	a0,1
    28e0:	00003097          	auipc	ra,0x3
    28e4:	f74080e7          	jalr	-140(ra) # 5854 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    28e8:	85ca                	mv	a1,s2
    28ea:	00005517          	auipc	a0,0x5
    28ee:	89e50513          	addi	a0,a0,-1890 # 7188 <malloc+0x14c6>
    28f2:	00003097          	auipc	ra,0x3
    28f6:	312080e7          	jalr	786(ra) # 5c04 <printf>
    exit(1);
    28fa:	4505                	li	a0,1
    28fc:	00003097          	auipc	ra,0x3
    2900:	f58080e7          	jalr	-168(ra) # 5854 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    2904:	85ca                	mv	a1,s2
    2906:	00005517          	auipc	a0,0x5
    290a:	8b250513          	addi	a0,a0,-1870 # 71b8 <malloc+0x14f6>
    290e:	00003097          	auipc	ra,0x3
    2912:	2f6080e7          	jalr	758(ra) # 5c04 <printf>
    exit(1);
    2916:	4505                	li	a0,1
    2918:	00003097          	auipc	ra,0x3
    291c:	f3c080e7          	jalr	-196(ra) # 5854 <exit>
    printf("%s: create dd succeeded!\n", s);
    2920:	85ca                	mv	a1,s2
    2922:	00005517          	auipc	a0,0x5
    2926:	8b650513          	addi	a0,a0,-1866 # 71d8 <malloc+0x1516>
    292a:	00003097          	auipc	ra,0x3
    292e:	2da080e7          	jalr	730(ra) # 5c04 <printf>
    exit(1);
    2932:	4505                	li	a0,1
    2934:	00003097          	auipc	ra,0x3
    2938:	f20080e7          	jalr	-224(ra) # 5854 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    293c:	85ca                	mv	a1,s2
    293e:	00005517          	auipc	a0,0x5
    2942:	8ba50513          	addi	a0,a0,-1862 # 71f8 <malloc+0x1536>
    2946:	00003097          	auipc	ra,0x3
    294a:	2be080e7          	jalr	702(ra) # 5c04 <printf>
    exit(1);
    294e:	4505                	li	a0,1
    2950:	00003097          	auipc	ra,0x3
    2954:	f04080e7          	jalr	-252(ra) # 5854 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    2958:	85ca                	mv	a1,s2
    295a:	00005517          	auipc	a0,0x5
    295e:	8be50513          	addi	a0,a0,-1858 # 7218 <malloc+0x1556>
    2962:	00003097          	auipc	ra,0x3
    2966:	2a2080e7          	jalr	674(ra) # 5c04 <printf>
    exit(1);
    296a:	4505                	li	a0,1
    296c:	00003097          	auipc	ra,0x3
    2970:	ee8080e7          	jalr	-280(ra) # 5854 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    2974:	85ca                	mv	a1,s2
    2976:	00005517          	auipc	a0,0x5
    297a:	8d250513          	addi	a0,a0,-1838 # 7248 <malloc+0x1586>
    297e:	00003097          	auipc	ra,0x3
    2982:	286080e7          	jalr	646(ra) # 5c04 <printf>
    exit(1);
    2986:	4505                	li	a0,1
    2988:	00003097          	auipc	ra,0x3
    298c:	ecc080e7          	jalr	-308(ra) # 5854 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    2990:	85ca                	mv	a1,s2
    2992:	00005517          	auipc	a0,0x5
    2996:	8de50513          	addi	a0,a0,-1826 # 7270 <malloc+0x15ae>
    299a:	00003097          	auipc	ra,0x3
    299e:	26a080e7          	jalr	618(ra) # 5c04 <printf>
    exit(1);
    29a2:	4505                	li	a0,1
    29a4:	00003097          	auipc	ra,0x3
    29a8:	eb0080e7          	jalr	-336(ra) # 5854 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    29ac:	85ca                	mv	a1,s2
    29ae:	00005517          	auipc	a0,0x5
    29b2:	8ea50513          	addi	a0,a0,-1814 # 7298 <malloc+0x15d6>
    29b6:	00003097          	auipc	ra,0x3
    29ba:	24e080e7          	jalr	590(ra) # 5c04 <printf>
    exit(1);
    29be:	4505                	li	a0,1
    29c0:	00003097          	auipc	ra,0x3
    29c4:	e94080e7          	jalr	-364(ra) # 5854 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    29c8:	85ca                	mv	a1,s2
    29ca:	00005517          	auipc	a0,0x5
    29ce:	8f650513          	addi	a0,a0,-1802 # 72c0 <malloc+0x15fe>
    29d2:	00003097          	auipc	ra,0x3
    29d6:	232080e7          	jalr	562(ra) # 5c04 <printf>
    exit(1);
    29da:	4505                	li	a0,1
    29dc:	00003097          	auipc	ra,0x3
    29e0:	e78080e7          	jalr	-392(ra) # 5854 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    29e4:	85ca                	mv	a1,s2
    29e6:	00005517          	auipc	a0,0x5
    29ea:	8fa50513          	addi	a0,a0,-1798 # 72e0 <malloc+0x161e>
    29ee:	00003097          	auipc	ra,0x3
    29f2:	216080e7          	jalr	534(ra) # 5c04 <printf>
    exit(1);
    29f6:	4505                	li	a0,1
    29f8:	00003097          	auipc	ra,0x3
    29fc:	e5c080e7          	jalr	-420(ra) # 5854 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    2a00:	85ca                	mv	a1,s2
    2a02:	00005517          	auipc	a0,0x5
    2a06:	8fe50513          	addi	a0,a0,-1794 # 7300 <malloc+0x163e>
    2a0a:	00003097          	auipc	ra,0x3
    2a0e:	1fa080e7          	jalr	506(ra) # 5c04 <printf>
    exit(1);
    2a12:	4505                	li	a0,1
    2a14:	00003097          	auipc	ra,0x3
    2a18:	e40080e7          	jalr	-448(ra) # 5854 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    2a1c:	85ca                	mv	a1,s2
    2a1e:	00005517          	auipc	a0,0x5
    2a22:	90a50513          	addi	a0,a0,-1782 # 7328 <malloc+0x1666>
    2a26:	00003097          	auipc	ra,0x3
    2a2a:	1de080e7          	jalr	478(ra) # 5c04 <printf>
    exit(1);
    2a2e:	4505                	li	a0,1
    2a30:	00003097          	auipc	ra,0x3
    2a34:	e24080e7          	jalr	-476(ra) # 5854 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    2a38:	85ca                	mv	a1,s2
    2a3a:	00005517          	auipc	a0,0x5
    2a3e:	90e50513          	addi	a0,a0,-1778 # 7348 <malloc+0x1686>
    2a42:	00003097          	auipc	ra,0x3
    2a46:	1c2080e7          	jalr	450(ra) # 5c04 <printf>
    exit(1);
    2a4a:	4505                	li	a0,1
    2a4c:	00003097          	auipc	ra,0x3
    2a50:	e08080e7          	jalr	-504(ra) # 5854 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    2a54:	85ca                	mv	a1,s2
    2a56:	00005517          	auipc	a0,0x5
    2a5a:	91250513          	addi	a0,a0,-1774 # 7368 <malloc+0x16a6>
    2a5e:	00003097          	auipc	ra,0x3
    2a62:	1a6080e7          	jalr	422(ra) # 5c04 <printf>
    exit(1);
    2a66:	4505                	li	a0,1
    2a68:	00003097          	auipc	ra,0x3
    2a6c:	dec080e7          	jalr	-532(ra) # 5854 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    2a70:	85ca                	mv	a1,s2
    2a72:	00005517          	auipc	a0,0x5
    2a76:	91e50513          	addi	a0,a0,-1762 # 7390 <malloc+0x16ce>
    2a7a:	00003097          	auipc	ra,0x3
    2a7e:	18a080e7          	jalr	394(ra) # 5c04 <printf>
    exit(1);
    2a82:	4505                	li	a0,1
    2a84:	00003097          	auipc	ra,0x3
    2a88:	dd0080e7          	jalr	-560(ra) # 5854 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    2a8c:	85ca                	mv	a1,s2
    2a8e:	00004517          	auipc	a0,0x4
    2a92:	59a50513          	addi	a0,a0,1434 # 7028 <malloc+0x1366>
    2a96:	00003097          	auipc	ra,0x3
    2a9a:	16e080e7          	jalr	366(ra) # 5c04 <printf>
    exit(1);
    2a9e:	4505                	li	a0,1
    2aa0:	00003097          	auipc	ra,0x3
    2aa4:	db4080e7          	jalr	-588(ra) # 5854 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    2aa8:	85ca                	mv	a1,s2
    2aaa:	00005517          	auipc	a0,0x5
    2aae:	90650513          	addi	a0,a0,-1786 # 73b0 <malloc+0x16ee>
    2ab2:	00003097          	auipc	ra,0x3
    2ab6:	152080e7          	jalr	338(ra) # 5c04 <printf>
    exit(1);
    2aba:	4505                	li	a0,1
    2abc:	00003097          	auipc	ra,0x3
    2ac0:	d98080e7          	jalr	-616(ra) # 5854 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    2ac4:	85ca                	mv	a1,s2
    2ac6:	00005517          	auipc	a0,0x5
    2aca:	90a50513          	addi	a0,a0,-1782 # 73d0 <malloc+0x170e>
    2ace:	00003097          	auipc	ra,0x3
    2ad2:	136080e7          	jalr	310(ra) # 5c04 <printf>
    exit(1);
    2ad6:	4505                	li	a0,1
    2ad8:	00003097          	auipc	ra,0x3
    2adc:	d7c080e7          	jalr	-644(ra) # 5854 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    2ae0:	85ca                	mv	a1,s2
    2ae2:	00005517          	auipc	a0,0x5
    2ae6:	91e50513          	addi	a0,a0,-1762 # 7400 <malloc+0x173e>
    2aea:	00003097          	auipc	ra,0x3
    2aee:	11a080e7          	jalr	282(ra) # 5c04 <printf>
    exit(1);
    2af2:	4505                	li	a0,1
    2af4:	00003097          	auipc	ra,0x3
    2af8:	d60080e7          	jalr	-672(ra) # 5854 <exit>
    printf("%s: unlink dd failed\n", s);
    2afc:	85ca                	mv	a1,s2
    2afe:	00005517          	auipc	a0,0x5
    2b02:	92250513          	addi	a0,a0,-1758 # 7420 <malloc+0x175e>
    2b06:	00003097          	auipc	ra,0x3
    2b0a:	0fe080e7          	jalr	254(ra) # 5c04 <printf>
    exit(1);
    2b0e:	4505                	li	a0,1
    2b10:	00003097          	auipc	ra,0x3
    2b14:	d44080e7          	jalr	-700(ra) # 5854 <exit>

0000000000002b18 <rmdot>:
{
    2b18:	1101                	addi	sp,sp,-32
    2b1a:	ec06                	sd	ra,24(sp)
    2b1c:	e822                	sd	s0,16(sp)
    2b1e:	e426                	sd	s1,8(sp)
    2b20:	1000                	addi	s0,sp,32
    2b22:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    2b24:	00005517          	auipc	a0,0x5
    2b28:	91450513          	addi	a0,a0,-1772 # 7438 <malloc+0x1776>
    2b2c:	00003097          	auipc	ra,0x3
    2b30:	d90080e7          	jalr	-624(ra) # 58bc <mkdir>
    2b34:	e549                	bnez	a0,2bbe <rmdot+0xa6>
  if(chdir("dots") != 0){
    2b36:	00005517          	auipc	a0,0x5
    2b3a:	90250513          	addi	a0,a0,-1790 # 7438 <malloc+0x1776>
    2b3e:	00003097          	auipc	ra,0x3
    2b42:	d86080e7          	jalr	-634(ra) # 58c4 <chdir>
    2b46:	e951                	bnez	a0,2bda <rmdot+0xc2>
  if(unlink(".") == 0){
    2b48:	00004517          	auipc	a0,0x4
    2b4c:	c0050513          	addi	a0,a0,-1024 # 6748 <malloc+0xa86>
    2b50:	00003097          	auipc	ra,0x3
    2b54:	d54080e7          	jalr	-684(ra) # 58a4 <unlink>
    2b58:	cd59                	beqz	a0,2bf6 <rmdot+0xde>
  if(unlink("..") == 0){
    2b5a:	00004517          	auipc	a0,0x4
    2b5e:	33650513          	addi	a0,a0,822 # 6e90 <malloc+0x11ce>
    2b62:	00003097          	auipc	ra,0x3
    2b66:	d42080e7          	jalr	-702(ra) # 58a4 <unlink>
    2b6a:	c545                	beqz	a0,2c12 <rmdot+0xfa>
  if(chdir("/") != 0){
    2b6c:	00004517          	auipc	a0,0x4
    2b70:	2cc50513          	addi	a0,a0,716 # 6e38 <malloc+0x1176>
    2b74:	00003097          	auipc	ra,0x3
    2b78:	d50080e7          	jalr	-688(ra) # 58c4 <chdir>
    2b7c:	e94d                	bnez	a0,2c2e <rmdot+0x116>
  if(unlink("dots/.") == 0){
    2b7e:	00005517          	auipc	a0,0x5
    2b82:	92250513          	addi	a0,a0,-1758 # 74a0 <malloc+0x17de>
    2b86:	00003097          	auipc	ra,0x3
    2b8a:	d1e080e7          	jalr	-738(ra) # 58a4 <unlink>
    2b8e:	cd55                	beqz	a0,2c4a <rmdot+0x132>
  if(unlink("dots/..") == 0){
    2b90:	00005517          	auipc	a0,0x5
    2b94:	93850513          	addi	a0,a0,-1736 # 74c8 <malloc+0x1806>
    2b98:	00003097          	auipc	ra,0x3
    2b9c:	d0c080e7          	jalr	-756(ra) # 58a4 <unlink>
    2ba0:	c179                	beqz	a0,2c66 <rmdot+0x14e>
  if(unlink("dots") != 0){
    2ba2:	00005517          	auipc	a0,0x5
    2ba6:	89650513          	addi	a0,a0,-1898 # 7438 <malloc+0x1776>
    2baa:	00003097          	auipc	ra,0x3
    2bae:	cfa080e7          	jalr	-774(ra) # 58a4 <unlink>
    2bb2:	e961                	bnez	a0,2c82 <rmdot+0x16a>
}
    2bb4:	60e2                	ld	ra,24(sp)
    2bb6:	6442                	ld	s0,16(sp)
    2bb8:	64a2                	ld	s1,8(sp)
    2bba:	6105                	addi	sp,sp,32
    2bbc:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    2bbe:	85a6                	mv	a1,s1
    2bc0:	00005517          	auipc	a0,0x5
    2bc4:	88050513          	addi	a0,a0,-1920 # 7440 <malloc+0x177e>
    2bc8:	00003097          	auipc	ra,0x3
    2bcc:	03c080e7          	jalr	60(ra) # 5c04 <printf>
    exit(1);
    2bd0:	4505                	li	a0,1
    2bd2:	00003097          	auipc	ra,0x3
    2bd6:	c82080e7          	jalr	-894(ra) # 5854 <exit>
    printf("%s: chdir dots failed\n", s);
    2bda:	85a6                	mv	a1,s1
    2bdc:	00005517          	auipc	a0,0x5
    2be0:	87c50513          	addi	a0,a0,-1924 # 7458 <malloc+0x1796>
    2be4:	00003097          	auipc	ra,0x3
    2be8:	020080e7          	jalr	32(ra) # 5c04 <printf>
    exit(1);
    2bec:	4505                	li	a0,1
    2bee:	00003097          	auipc	ra,0x3
    2bf2:	c66080e7          	jalr	-922(ra) # 5854 <exit>
    printf("%s: rm . worked!\n", s);
    2bf6:	85a6                	mv	a1,s1
    2bf8:	00005517          	auipc	a0,0x5
    2bfc:	87850513          	addi	a0,a0,-1928 # 7470 <malloc+0x17ae>
    2c00:	00003097          	auipc	ra,0x3
    2c04:	004080e7          	jalr	4(ra) # 5c04 <printf>
    exit(1);
    2c08:	4505                	li	a0,1
    2c0a:	00003097          	auipc	ra,0x3
    2c0e:	c4a080e7          	jalr	-950(ra) # 5854 <exit>
    printf("%s: rm .. worked!\n", s);
    2c12:	85a6                	mv	a1,s1
    2c14:	00005517          	auipc	a0,0x5
    2c18:	87450513          	addi	a0,a0,-1932 # 7488 <malloc+0x17c6>
    2c1c:	00003097          	auipc	ra,0x3
    2c20:	fe8080e7          	jalr	-24(ra) # 5c04 <printf>
    exit(1);
    2c24:	4505                	li	a0,1
    2c26:	00003097          	auipc	ra,0x3
    2c2a:	c2e080e7          	jalr	-978(ra) # 5854 <exit>
    printf("%s: chdir / failed\n", s);
    2c2e:	85a6                	mv	a1,s1
    2c30:	00004517          	auipc	a0,0x4
    2c34:	21050513          	addi	a0,a0,528 # 6e40 <malloc+0x117e>
    2c38:	00003097          	auipc	ra,0x3
    2c3c:	fcc080e7          	jalr	-52(ra) # 5c04 <printf>
    exit(1);
    2c40:	4505                	li	a0,1
    2c42:	00003097          	auipc	ra,0x3
    2c46:	c12080e7          	jalr	-1006(ra) # 5854 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    2c4a:	85a6                	mv	a1,s1
    2c4c:	00005517          	auipc	a0,0x5
    2c50:	85c50513          	addi	a0,a0,-1956 # 74a8 <malloc+0x17e6>
    2c54:	00003097          	auipc	ra,0x3
    2c58:	fb0080e7          	jalr	-80(ra) # 5c04 <printf>
    exit(1);
    2c5c:	4505                	li	a0,1
    2c5e:	00003097          	auipc	ra,0x3
    2c62:	bf6080e7          	jalr	-1034(ra) # 5854 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    2c66:	85a6                	mv	a1,s1
    2c68:	00005517          	auipc	a0,0x5
    2c6c:	86850513          	addi	a0,a0,-1944 # 74d0 <malloc+0x180e>
    2c70:	00003097          	auipc	ra,0x3
    2c74:	f94080e7          	jalr	-108(ra) # 5c04 <printf>
    exit(1);
    2c78:	4505                	li	a0,1
    2c7a:	00003097          	auipc	ra,0x3
    2c7e:	bda080e7          	jalr	-1062(ra) # 5854 <exit>
    printf("%s: unlink dots failed!\n", s);
    2c82:	85a6                	mv	a1,s1
    2c84:	00005517          	auipc	a0,0x5
    2c88:	86c50513          	addi	a0,a0,-1940 # 74f0 <malloc+0x182e>
    2c8c:	00003097          	auipc	ra,0x3
    2c90:	f78080e7          	jalr	-136(ra) # 5c04 <printf>
    exit(1);
    2c94:	4505                	li	a0,1
    2c96:	00003097          	auipc	ra,0x3
    2c9a:	bbe080e7          	jalr	-1090(ra) # 5854 <exit>

0000000000002c9e <dirfile>:
{
    2c9e:	1101                	addi	sp,sp,-32
    2ca0:	ec06                	sd	ra,24(sp)
    2ca2:	e822                	sd	s0,16(sp)
    2ca4:	e426                	sd	s1,8(sp)
    2ca6:	e04a                	sd	s2,0(sp)
    2ca8:	1000                	addi	s0,sp,32
    2caa:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    2cac:	20000593          	li	a1,512
    2cb0:	00003517          	auipc	a0,0x3
    2cb4:	30850513          	addi	a0,a0,776 # 5fb8 <malloc+0x2f6>
    2cb8:	00003097          	auipc	ra,0x3
    2cbc:	bdc080e7          	jalr	-1060(ra) # 5894 <open>
  if(fd < 0){
    2cc0:	0e054d63          	bltz	a0,2dba <dirfile+0x11c>
  close(fd);
    2cc4:	00003097          	auipc	ra,0x3
    2cc8:	bb8080e7          	jalr	-1096(ra) # 587c <close>
  if(chdir("dirfile") == 0){
    2ccc:	00003517          	auipc	a0,0x3
    2cd0:	2ec50513          	addi	a0,a0,748 # 5fb8 <malloc+0x2f6>
    2cd4:	00003097          	auipc	ra,0x3
    2cd8:	bf0080e7          	jalr	-1040(ra) # 58c4 <chdir>
    2cdc:	cd6d                	beqz	a0,2dd6 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    2cde:	4581                	li	a1,0
    2ce0:	00005517          	auipc	a0,0x5
    2ce4:	87050513          	addi	a0,a0,-1936 # 7550 <malloc+0x188e>
    2ce8:	00003097          	auipc	ra,0x3
    2cec:	bac080e7          	jalr	-1108(ra) # 5894 <open>
  if(fd >= 0){
    2cf0:	10055163          	bgez	a0,2df2 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    2cf4:	20000593          	li	a1,512
    2cf8:	00005517          	auipc	a0,0x5
    2cfc:	85850513          	addi	a0,a0,-1960 # 7550 <malloc+0x188e>
    2d00:	00003097          	auipc	ra,0x3
    2d04:	b94080e7          	jalr	-1132(ra) # 5894 <open>
  if(fd >= 0){
    2d08:	10055363          	bgez	a0,2e0e <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    2d0c:	00005517          	auipc	a0,0x5
    2d10:	84450513          	addi	a0,a0,-1980 # 7550 <malloc+0x188e>
    2d14:	00003097          	auipc	ra,0x3
    2d18:	ba8080e7          	jalr	-1112(ra) # 58bc <mkdir>
    2d1c:	10050763          	beqz	a0,2e2a <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    2d20:	00005517          	auipc	a0,0x5
    2d24:	83050513          	addi	a0,a0,-2000 # 7550 <malloc+0x188e>
    2d28:	00003097          	auipc	ra,0x3
    2d2c:	b7c080e7          	jalr	-1156(ra) # 58a4 <unlink>
    2d30:	10050b63          	beqz	a0,2e46 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    2d34:	00005597          	auipc	a1,0x5
    2d38:	81c58593          	addi	a1,a1,-2020 # 7550 <malloc+0x188e>
    2d3c:	00003517          	auipc	a0,0x3
    2d40:	61c50513          	addi	a0,a0,1564 # 6358 <malloc+0x696>
    2d44:	00003097          	auipc	ra,0x3
    2d48:	b70080e7          	jalr	-1168(ra) # 58b4 <link>
    2d4c:	10050b63          	beqz	a0,2e62 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    2d50:	00003517          	auipc	a0,0x3
    2d54:	26850513          	addi	a0,a0,616 # 5fb8 <malloc+0x2f6>
    2d58:	00003097          	auipc	ra,0x3
    2d5c:	b4c080e7          	jalr	-1204(ra) # 58a4 <unlink>
    2d60:	10051f63          	bnez	a0,2e7e <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    2d64:	4589                	li	a1,2
    2d66:	00004517          	auipc	a0,0x4
    2d6a:	9e250513          	addi	a0,a0,-1566 # 6748 <malloc+0xa86>
    2d6e:	00003097          	auipc	ra,0x3
    2d72:	b26080e7          	jalr	-1242(ra) # 5894 <open>
  if(fd >= 0){
    2d76:	12055263          	bgez	a0,2e9a <dirfile+0x1fc>
  fd = open(".", 0);
    2d7a:	4581                	li	a1,0
    2d7c:	00004517          	auipc	a0,0x4
    2d80:	9cc50513          	addi	a0,a0,-1588 # 6748 <malloc+0xa86>
    2d84:	00003097          	auipc	ra,0x3
    2d88:	b10080e7          	jalr	-1264(ra) # 5894 <open>
    2d8c:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    2d8e:	4605                	li	a2,1
    2d90:	00003597          	auipc	a1,0x3
    2d94:	49058593          	addi	a1,a1,1168 # 6220 <malloc+0x55e>
    2d98:	00003097          	auipc	ra,0x3
    2d9c:	adc080e7          	jalr	-1316(ra) # 5874 <write>
    2da0:	10a04b63          	bgtz	a0,2eb6 <dirfile+0x218>
  close(fd);
    2da4:	8526                	mv	a0,s1
    2da6:	00003097          	auipc	ra,0x3
    2daa:	ad6080e7          	jalr	-1322(ra) # 587c <close>
}
    2dae:	60e2                	ld	ra,24(sp)
    2db0:	6442                	ld	s0,16(sp)
    2db2:	64a2                	ld	s1,8(sp)
    2db4:	6902                	ld	s2,0(sp)
    2db6:	6105                	addi	sp,sp,32
    2db8:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    2dba:	85ca                	mv	a1,s2
    2dbc:	00004517          	auipc	a0,0x4
    2dc0:	75450513          	addi	a0,a0,1876 # 7510 <malloc+0x184e>
    2dc4:	00003097          	auipc	ra,0x3
    2dc8:	e40080e7          	jalr	-448(ra) # 5c04 <printf>
    exit(1);
    2dcc:	4505                	li	a0,1
    2dce:	00003097          	auipc	ra,0x3
    2dd2:	a86080e7          	jalr	-1402(ra) # 5854 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    2dd6:	85ca                	mv	a1,s2
    2dd8:	00004517          	auipc	a0,0x4
    2ddc:	75850513          	addi	a0,a0,1880 # 7530 <malloc+0x186e>
    2de0:	00003097          	auipc	ra,0x3
    2de4:	e24080e7          	jalr	-476(ra) # 5c04 <printf>
    exit(1);
    2de8:	4505                	li	a0,1
    2dea:	00003097          	auipc	ra,0x3
    2dee:	a6a080e7          	jalr	-1430(ra) # 5854 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    2df2:	85ca                	mv	a1,s2
    2df4:	00004517          	auipc	a0,0x4
    2df8:	76c50513          	addi	a0,a0,1900 # 7560 <malloc+0x189e>
    2dfc:	00003097          	auipc	ra,0x3
    2e00:	e08080e7          	jalr	-504(ra) # 5c04 <printf>
    exit(1);
    2e04:	4505                	li	a0,1
    2e06:	00003097          	auipc	ra,0x3
    2e0a:	a4e080e7          	jalr	-1458(ra) # 5854 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    2e0e:	85ca                	mv	a1,s2
    2e10:	00004517          	auipc	a0,0x4
    2e14:	75050513          	addi	a0,a0,1872 # 7560 <malloc+0x189e>
    2e18:	00003097          	auipc	ra,0x3
    2e1c:	dec080e7          	jalr	-532(ra) # 5c04 <printf>
    exit(1);
    2e20:	4505                	li	a0,1
    2e22:	00003097          	auipc	ra,0x3
    2e26:	a32080e7          	jalr	-1486(ra) # 5854 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    2e2a:	85ca                	mv	a1,s2
    2e2c:	00004517          	auipc	a0,0x4
    2e30:	75c50513          	addi	a0,a0,1884 # 7588 <malloc+0x18c6>
    2e34:	00003097          	auipc	ra,0x3
    2e38:	dd0080e7          	jalr	-560(ra) # 5c04 <printf>
    exit(1);
    2e3c:	4505                	li	a0,1
    2e3e:	00003097          	auipc	ra,0x3
    2e42:	a16080e7          	jalr	-1514(ra) # 5854 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    2e46:	85ca                	mv	a1,s2
    2e48:	00004517          	auipc	a0,0x4
    2e4c:	76850513          	addi	a0,a0,1896 # 75b0 <malloc+0x18ee>
    2e50:	00003097          	auipc	ra,0x3
    2e54:	db4080e7          	jalr	-588(ra) # 5c04 <printf>
    exit(1);
    2e58:	4505                	li	a0,1
    2e5a:	00003097          	auipc	ra,0x3
    2e5e:	9fa080e7          	jalr	-1542(ra) # 5854 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    2e62:	85ca                	mv	a1,s2
    2e64:	00004517          	auipc	a0,0x4
    2e68:	77450513          	addi	a0,a0,1908 # 75d8 <malloc+0x1916>
    2e6c:	00003097          	auipc	ra,0x3
    2e70:	d98080e7          	jalr	-616(ra) # 5c04 <printf>
    exit(1);
    2e74:	4505                	li	a0,1
    2e76:	00003097          	auipc	ra,0x3
    2e7a:	9de080e7          	jalr	-1570(ra) # 5854 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    2e7e:	85ca                	mv	a1,s2
    2e80:	00004517          	auipc	a0,0x4
    2e84:	78050513          	addi	a0,a0,1920 # 7600 <malloc+0x193e>
    2e88:	00003097          	auipc	ra,0x3
    2e8c:	d7c080e7          	jalr	-644(ra) # 5c04 <printf>
    exit(1);
    2e90:	4505                	li	a0,1
    2e92:	00003097          	auipc	ra,0x3
    2e96:	9c2080e7          	jalr	-1598(ra) # 5854 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    2e9a:	85ca                	mv	a1,s2
    2e9c:	00004517          	auipc	a0,0x4
    2ea0:	78450513          	addi	a0,a0,1924 # 7620 <malloc+0x195e>
    2ea4:	00003097          	auipc	ra,0x3
    2ea8:	d60080e7          	jalr	-672(ra) # 5c04 <printf>
    exit(1);
    2eac:	4505                	li	a0,1
    2eae:	00003097          	auipc	ra,0x3
    2eb2:	9a6080e7          	jalr	-1626(ra) # 5854 <exit>
    printf("%s: write . succeeded!\n", s);
    2eb6:	85ca                	mv	a1,s2
    2eb8:	00004517          	auipc	a0,0x4
    2ebc:	79050513          	addi	a0,a0,1936 # 7648 <malloc+0x1986>
    2ec0:	00003097          	auipc	ra,0x3
    2ec4:	d44080e7          	jalr	-700(ra) # 5c04 <printf>
    exit(1);
    2ec8:	4505                	li	a0,1
    2eca:	00003097          	auipc	ra,0x3
    2ece:	98a080e7          	jalr	-1654(ra) # 5854 <exit>

0000000000002ed2 <reparent>:
{
    2ed2:	7179                	addi	sp,sp,-48
    2ed4:	f406                	sd	ra,40(sp)
    2ed6:	f022                	sd	s0,32(sp)
    2ed8:	ec26                	sd	s1,24(sp)
    2eda:	e84a                	sd	s2,16(sp)
    2edc:	e44e                	sd	s3,8(sp)
    2ede:	e052                	sd	s4,0(sp)
    2ee0:	1800                	addi	s0,sp,48
    2ee2:	89aa                	mv	s3,a0
  int master_pid = getpid();
    2ee4:	00003097          	auipc	ra,0x3
    2ee8:	9f0080e7          	jalr	-1552(ra) # 58d4 <getpid>
    2eec:	8a2a                	mv	s4,a0
    2eee:	0c800913          	li	s2,200
    int pid = fork();
    2ef2:	00003097          	auipc	ra,0x3
    2ef6:	95a080e7          	jalr	-1702(ra) # 584c <fork>
    2efa:	84aa                	mv	s1,a0
    if(pid < 0){
    2efc:	02054263          	bltz	a0,2f20 <reparent+0x4e>
    if(pid){
    2f00:	cd21                	beqz	a0,2f58 <reparent+0x86>
      if(wait(0) != pid){
    2f02:	4501                	li	a0,0
    2f04:	00003097          	auipc	ra,0x3
    2f08:	958080e7          	jalr	-1704(ra) # 585c <wait>
    2f0c:	02951863          	bne	a0,s1,2f3c <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    2f10:	397d                	addiw	s2,s2,-1
    2f12:	fe0910e3          	bnez	s2,2ef2 <reparent+0x20>
  exit(0);
    2f16:	4501                	li	a0,0
    2f18:	00003097          	auipc	ra,0x3
    2f1c:	93c080e7          	jalr	-1732(ra) # 5854 <exit>
      printf("%s: fork failed\n", s);
    2f20:	85ce                	mv	a1,s3
    2f22:	00003517          	auipc	a0,0x3
    2f26:	11650513          	addi	a0,a0,278 # 6038 <malloc+0x376>
    2f2a:	00003097          	auipc	ra,0x3
    2f2e:	cda080e7          	jalr	-806(ra) # 5c04 <printf>
      exit(1);
    2f32:	4505                	li	a0,1
    2f34:	00003097          	auipc	ra,0x3
    2f38:	920080e7          	jalr	-1760(ra) # 5854 <exit>
        printf("%s: wait wrong pid\n", s);
    2f3c:	85ce                	mv	a1,s3
    2f3e:	00003517          	auipc	a0,0x3
    2f42:	11250513          	addi	a0,a0,274 # 6050 <malloc+0x38e>
    2f46:	00003097          	auipc	ra,0x3
    2f4a:	cbe080e7          	jalr	-834(ra) # 5c04 <printf>
        exit(1);
    2f4e:	4505                	li	a0,1
    2f50:	00003097          	auipc	ra,0x3
    2f54:	904080e7          	jalr	-1788(ra) # 5854 <exit>
      int pid2 = fork();
    2f58:	00003097          	auipc	ra,0x3
    2f5c:	8f4080e7          	jalr	-1804(ra) # 584c <fork>
      if(pid2 < 0){
    2f60:	00054763          	bltz	a0,2f6e <reparent+0x9c>
      exit(0);
    2f64:	4501                	li	a0,0
    2f66:	00003097          	auipc	ra,0x3
    2f6a:	8ee080e7          	jalr	-1810(ra) # 5854 <exit>
        kill(master_pid, SIGKILL);
    2f6e:	45a5                	li	a1,9
    2f70:	8552                	mv	a0,s4
    2f72:	00003097          	auipc	ra,0x3
    2f76:	912080e7          	jalr	-1774(ra) # 5884 <kill>
        exit(1);
    2f7a:	4505                	li	a0,1
    2f7c:	00003097          	auipc	ra,0x3
    2f80:	8d8080e7          	jalr	-1832(ra) # 5854 <exit>

0000000000002f84 <fourfiles>:
{
    2f84:	7171                	addi	sp,sp,-176
    2f86:	f506                	sd	ra,168(sp)
    2f88:	f122                	sd	s0,160(sp)
    2f8a:	ed26                	sd	s1,152(sp)
    2f8c:	e94a                	sd	s2,144(sp)
    2f8e:	e54e                	sd	s3,136(sp)
    2f90:	e152                	sd	s4,128(sp)
    2f92:	fcd6                	sd	s5,120(sp)
    2f94:	f8da                	sd	s6,112(sp)
    2f96:	f4de                	sd	s7,104(sp)
    2f98:	f0e2                	sd	s8,96(sp)
    2f9a:	ece6                	sd	s9,88(sp)
    2f9c:	e8ea                	sd	s10,80(sp)
    2f9e:	e4ee                	sd	s11,72(sp)
    2fa0:	1900                	addi	s0,sp,176
    2fa2:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    2fa6:	00003797          	auipc	a5,0x3
    2faa:	e0278793          	addi	a5,a5,-510 # 5da8 <malloc+0xe6>
    2fae:	f6f43823          	sd	a5,-144(s0)
    2fb2:	00003797          	auipc	a5,0x3
    2fb6:	dfe78793          	addi	a5,a5,-514 # 5db0 <malloc+0xee>
    2fba:	f6f43c23          	sd	a5,-136(s0)
    2fbe:	00003797          	auipc	a5,0x3
    2fc2:	dfa78793          	addi	a5,a5,-518 # 5db8 <malloc+0xf6>
    2fc6:	f8f43023          	sd	a5,-128(s0)
    2fca:	00003797          	auipc	a5,0x3
    2fce:	df678793          	addi	a5,a5,-522 # 5dc0 <malloc+0xfe>
    2fd2:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    2fd6:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    2fda:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    2fdc:	4481                	li	s1,0
    2fde:	4a11                	li	s4,4
    fname = names[pi];
    2fe0:	00093983          	ld	s3,0(s2)
    unlink(fname);
    2fe4:	854e                	mv	a0,s3
    2fe6:	00003097          	auipc	ra,0x3
    2fea:	8be080e7          	jalr	-1858(ra) # 58a4 <unlink>
    pid = fork();
    2fee:	00003097          	auipc	ra,0x3
    2ff2:	85e080e7          	jalr	-1954(ra) # 584c <fork>
    if(pid < 0){
    2ff6:	04054463          	bltz	a0,303e <fourfiles+0xba>
    if(pid == 0){
    2ffa:	c12d                	beqz	a0,305c <fourfiles+0xd8>
  for(pi = 0; pi < NCHILD; pi++){
    2ffc:	2485                	addiw	s1,s1,1
    2ffe:	0921                	addi	s2,s2,8
    3000:	ff4490e3          	bne	s1,s4,2fe0 <fourfiles+0x5c>
    3004:	4491                	li	s1,4
    wait(&xstatus);
    3006:	f6c40513          	addi	a0,s0,-148
    300a:	00003097          	auipc	ra,0x3
    300e:	852080e7          	jalr	-1966(ra) # 585c <wait>
    if(xstatus != 0)
    3012:	f6c42b03          	lw	s6,-148(s0)
    3016:	0c0b1e63          	bnez	s6,30f2 <fourfiles+0x16e>
  for(pi = 0; pi < NCHILD; pi++){
    301a:	34fd                	addiw	s1,s1,-1
    301c:	f4ed                	bnez	s1,3006 <fourfiles+0x82>
    301e:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    3022:	00009a17          	auipc	s4,0x9
    3026:	bcea0a13          	addi	s4,s4,-1074 # bbf0 <buf>
    302a:	00009a97          	auipc	s5,0x9
    302e:	bc7a8a93          	addi	s5,s5,-1081 # bbf1 <buf+0x1>
    if(total != N*SZ){
    3032:	6d85                	lui	s11,0x1
    3034:	770d8d93          	addi	s11,s11,1904 # 1770 <exectest+0x98>
  for(i = 0; i < NCHILD; i++){
    3038:	03400d13          	li	s10,52
    303c:	aa1d                	j	3172 <fourfiles+0x1ee>
      printf("fork failed\n", s);
    303e:	f5843583          	ld	a1,-168(s0)
    3042:	00004517          	auipc	a0,0x4
    3046:	9ee50513          	addi	a0,a0,-1554 # 6a30 <malloc+0xd6e>
    304a:	00003097          	auipc	ra,0x3
    304e:	bba080e7          	jalr	-1094(ra) # 5c04 <printf>
      exit(1);
    3052:	4505                	li	a0,1
    3054:	00003097          	auipc	ra,0x3
    3058:	800080e7          	jalr	-2048(ra) # 5854 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    305c:	20200593          	li	a1,514
    3060:	854e                	mv	a0,s3
    3062:	00003097          	auipc	ra,0x3
    3066:	832080e7          	jalr	-1998(ra) # 5894 <open>
    306a:	892a                	mv	s2,a0
      if(fd < 0){
    306c:	04054763          	bltz	a0,30ba <fourfiles+0x136>
      memset(buf, '0'+pi, SZ);
    3070:	1f400613          	li	a2,500
    3074:	0304859b          	addiw	a1,s1,48
    3078:	00009517          	auipc	a0,0x9
    307c:	b7850513          	addi	a0,a0,-1160 # bbf0 <buf>
    3080:	00002097          	auipc	ra,0x2
    3084:	5d8080e7          	jalr	1496(ra) # 5658 <memset>
    3088:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    308a:	00009997          	auipc	s3,0x9
    308e:	b6698993          	addi	s3,s3,-1178 # bbf0 <buf>
    3092:	1f400613          	li	a2,500
    3096:	85ce                	mv	a1,s3
    3098:	854a                	mv	a0,s2
    309a:	00002097          	auipc	ra,0x2
    309e:	7da080e7          	jalr	2010(ra) # 5874 <write>
    30a2:	85aa                	mv	a1,a0
    30a4:	1f400793          	li	a5,500
    30a8:	02f51863          	bne	a0,a5,30d8 <fourfiles+0x154>
      for(i = 0; i < N; i++){
    30ac:	34fd                	addiw	s1,s1,-1
    30ae:	f0f5                	bnez	s1,3092 <fourfiles+0x10e>
      exit(0);
    30b0:	4501                	li	a0,0
    30b2:	00002097          	auipc	ra,0x2
    30b6:	7a2080e7          	jalr	1954(ra) # 5854 <exit>
        printf("create failed\n", s);
    30ba:	f5843583          	ld	a1,-168(s0)
    30be:	00004517          	auipc	a0,0x4
    30c2:	5a250513          	addi	a0,a0,1442 # 7660 <malloc+0x199e>
    30c6:	00003097          	auipc	ra,0x3
    30ca:	b3e080e7          	jalr	-1218(ra) # 5c04 <printf>
        exit(1);
    30ce:	4505                	li	a0,1
    30d0:	00002097          	auipc	ra,0x2
    30d4:	784080e7          	jalr	1924(ra) # 5854 <exit>
          printf("write failed %d\n", n);
    30d8:	00004517          	auipc	a0,0x4
    30dc:	59850513          	addi	a0,a0,1432 # 7670 <malloc+0x19ae>
    30e0:	00003097          	auipc	ra,0x3
    30e4:	b24080e7          	jalr	-1244(ra) # 5c04 <printf>
          exit(1);
    30e8:	4505                	li	a0,1
    30ea:	00002097          	auipc	ra,0x2
    30ee:	76a080e7          	jalr	1898(ra) # 5854 <exit>
      exit(xstatus);
    30f2:	855a                	mv	a0,s6
    30f4:	00002097          	auipc	ra,0x2
    30f8:	760080e7          	jalr	1888(ra) # 5854 <exit>
          printf("wrong char\n", s);
    30fc:	f5843583          	ld	a1,-168(s0)
    3100:	00004517          	auipc	a0,0x4
    3104:	58850513          	addi	a0,a0,1416 # 7688 <malloc+0x19c6>
    3108:	00003097          	auipc	ra,0x3
    310c:	afc080e7          	jalr	-1284(ra) # 5c04 <printf>
          exit(1);
    3110:	4505                	li	a0,1
    3112:	00002097          	auipc	ra,0x2
    3116:	742080e7          	jalr	1858(ra) # 5854 <exit>
      total += n;
    311a:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    311e:	660d                	lui	a2,0x3
    3120:	85d2                	mv	a1,s4
    3122:	854e                	mv	a0,s3
    3124:	00002097          	auipc	ra,0x2
    3128:	748080e7          	jalr	1864(ra) # 586c <read>
    312c:	02a05363          	blez	a0,3152 <fourfiles+0x1ce>
    3130:	00009797          	auipc	a5,0x9
    3134:	ac078793          	addi	a5,a5,-1344 # bbf0 <buf>
    3138:	fff5069b          	addiw	a3,a0,-1
    313c:	1682                	slli	a3,a3,0x20
    313e:	9281                	srli	a3,a3,0x20
    3140:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    3142:	0007c703          	lbu	a4,0(a5)
    3146:	fa971be3          	bne	a4,s1,30fc <fourfiles+0x178>
      for(j = 0; j < n; j++){
    314a:	0785                	addi	a5,a5,1
    314c:	fed79be3          	bne	a5,a3,3142 <fourfiles+0x1be>
    3150:	b7e9                	j	311a <fourfiles+0x196>
    close(fd);
    3152:	854e                	mv	a0,s3
    3154:	00002097          	auipc	ra,0x2
    3158:	728080e7          	jalr	1832(ra) # 587c <close>
    if(total != N*SZ){
    315c:	03b91863          	bne	s2,s11,318c <fourfiles+0x208>
    unlink(fname);
    3160:	8566                	mv	a0,s9
    3162:	00002097          	auipc	ra,0x2
    3166:	742080e7          	jalr	1858(ra) # 58a4 <unlink>
  for(i = 0; i < NCHILD; i++){
    316a:	0c21                	addi	s8,s8,8
    316c:	2b85                	addiw	s7,s7,1
    316e:	03ab8d63          	beq	s7,s10,31a8 <fourfiles+0x224>
    fname = names[i];
    3172:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    3176:	4581                	li	a1,0
    3178:	8566                	mv	a0,s9
    317a:	00002097          	auipc	ra,0x2
    317e:	71a080e7          	jalr	1818(ra) # 5894 <open>
    3182:	89aa                	mv	s3,a0
    total = 0;
    3184:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    3186:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    318a:	bf51                	j	311e <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    318c:	85ca                	mv	a1,s2
    318e:	00004517          	auipc	a0,0x4
    3192:	50a50513          	addi	a0,a0,1290 # 7698 <malloc+0x19d6>
    3196:	00003097          	auipc	ra,0x3
    319a:	a6e080e7          	jalr	-1426(ra) # 5c04 <printf>
      exit(1);
    319e:	4505                	li	a0,1
    31a0:	00002097          	auipc	ra,0x2
    31a4:	6b4080e7          	jalr	1716(ra) # 5854 <exit>
}
    31a8:	70aa                	ld	ra,168(sp)
    31aa:	740a                	ld	s0,160(sp)
    31ac:	64ea                	ld	s1,152(sp)
    31ae:	694a                	ld	s2,144(sp)
    31b0:	69aa                	ld	s3,136(sp)
    31b2:	6a0a                	ld	s4,128(sp)
    31b4:	7ae6                	ld	s5,120(sp)
    31b6:	7b46                	ld	s6,112(sp)
    31b8:	7ba6                	ld	s7,104(sp)
    31ba:	7c06                	ld	s8,96(sp)
    31bc:	6ce6                	ld	s9,88(sp)
    31be:	6d46                	ld	s10,80(sp)
    31c0:	6da6                	ld	s11,72(sp)
    31c2:	614d                	addi	sp,sp,176
    31c4:	8082                	ret

00000000000031c6 <bigfile>:
{
    31c6:	7139                	addi	sp,sp,-64
    31c8:	fc06                	sd	ra,56(sp)
    31ca:	f822                	sd	s0,48(sp)
    31cc:	f426                	sd	s1,40(sp)
    31ce:	f04a                	sd	s2,32(sp)
    31d0:	ec4e                	sd	s3,24(sp)
    31d2:	e852                	sd	s4,16(sp)
    31d4:	e456                	sd	s5,8(sp)
    31d6:	0080                	addi	s0,sp,64
    31d8:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    31da:	00004517          	auipc	a0,0x4
    31de:	4d650513          	addi	a0,a0,1238 # 76b0 <malloc+0x19ee>
    31e2:	00002097          	auipc	ra,0x2
    31e6:	6c2080e7          	jalr	1730(ra) # 58a4 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    31ea:	20200593          	li	a1,514
    31ee:	00004517          	auipc	a0,0x4
    31f2:	4c250513          	addi	a0,a0,1218 # 76b0 <malloc+0x19ee>
    31f6:	00002097          	auipc	ra,0x2
    31fa:	69e080e7          	jalr	1694(ra) # 5894 <open>
    31fe:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    3200:	4481                	li	s1,0
    memset(buf, i, SZ);
    3202:	00009917          	auipc	s2,0x9
    3206:	9ee90913          	addi	s2,s2,-1554 # bbf0 <buf>
  for(i = 0; i < N; i++){
    320a:	4a51                	li	s4,20
  if(fd < 0){
    320c:	0a054063          	bltz	a0,32ac <bigfile+0xe6>
    memset(buf, i, SZ);
    3210:	25800613          	li	a2,600
    3214:	85a6                	mv	a1,s1
    3216:	854a                	mv	a0,s2
    3218:	00002097          	auipc	ra,0x2
    321c:	440080e7          	jalr	1088(ra) # 5658 <memset>
    if(write(fd, buf, SZ) != SZ){
    3220:	25800613          	li	a2,600
    3224:	85ca                	mv	a1,s2
    3226:	854e                	mv	a0,s3
    3228:	00002097          	auipc	ra,0x2
    322c:	64c080e7          	jalr	1612(ra) # 5874 <write>
    3230:	25800793          	li	a5,600
    3234:	08f51a63          	bne	a0,a5,32c8 <bigfile+0x102>
  for(i = 0; i < N; i++){
    3238:	2485                	addiw	s1,s1,1
    323a:	fd449be3          	bne	s1,s4,3210 <bigfile+0x4a>
  close(fd);
    323e:	854e                	mv	a0,s3
    3240:	00002097          	auipc	ra,0x2
    3244:	63c080e7          	jalr	1596(ra) # 587c <close>
  fd = open("bigfile.dat", 0);
    3248:	4581                	li	a1,0
    324a:	00004517          	auipc	a0,0x4
    324e:	46650513          	addi	a0,a0,1126 # 76b0 <malloc+0x19ee>
    3252:	00002097          	auipc	ra,0x2
    3256:	642080e7          	jalr	1602(ra) # 5894 <open>
    325a:	8a2a                	mv	s4,a0
  total = 0;
    325c:	4981                	li	s3,0
  for(i = 0; ; i++){
    325e:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    3260:	00009917          	auipc	s2,0x9
    3264:	99090913          	addi	s2,s2,-1648 # bbf0 <buf>
  if(fd < 0){
    3268:	06054e63          	bltz	a0,32e4 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    326c:	12c00613          	li	a2,300
    3270:	85ca                	mv	a1,s2
    3272:	8552                	mv	a0,s4
    3274:	00002097          	auipc	ra,0x2
    3278:	5f8080e7          	jalr	1528(ra) # 586c <read>
    if(cc < 0){
    327c:	08054263          	bltz	a0,3300 <bigfile+0x13a>
    if(cc == 0)
    3280:	c971                	beqz	a0,3354 <bigfile+0x18e>
    if(cc != SZ/2){
    3282:	12c00793          	li	a5,300
    3286:	08f51b63          	bne	a0,a5,331c <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    328a:	01f4d79b          	srliw	a5,s1,0x1f
    328e:	9fa5                	addw	a5,a5,s1
    3290:	4017d79b          	sraiw	a5,a5,0x1
    3294:	00094703          	lbu	a4,0(s2)
    3298:	0af71063          	bne	a4,a5,3338 <bigfile+0x172>
    329c:	12b94703          	lbu	a4,299(s2)
    32a0:	08f71c63          	bne	a4,a5,3338 <bigfile+0x172>
    total += cc;
    32a4:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    32a8:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    32aa:	b7c9                	j	326c <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    32ac:	85d6                	mv	a1,s5
    32ae:	00004517          	auipc	a0,0x4
    32b2:	41250513          	addi	a0,a0,1042 # 76c0 <malloc+0x19fe>
    32b6:	00003097          	auipc	ra,0x3
    32ba:	94e080e7          	jalr	-1714(ra) # 5c04 <printf>
    exit(1);
    32be:	4505                	li	a0,1
    32c0:	00002097          	auipc	ra,0x2
    32c4:	594080e7          	jalr	1428(ra) # 5854 <exit>
      printf("%s: write bigfile failed\n", s);
    32c8:	85d6                	mv	a1,s5
    32ca:	00004517          	auipc	a0,0x4
    32ce:	41650513          	addi	a0,a0,1046 # 76e0 <malloc+0x1a1e>
    32d2:	00003097          	auipc	ra,0x3
    32d6:	932080e7          	jalr	-1742(ra) # 5c04 <printf>
      exit(1);
    32da:	4505                	li	a0,1
    32dc:	00002097          	auipc	ra,0x2
    32e0:	578080e7          	jalr	1400(ra) # 5854 <exit>
    printf("%s: cannot open bigfile\n", s);
    32e4:	85d6                	mv	a1,s5
    32e6:	00004517          	auipc	a0,0x4
    32ea:	41a50513          	addi	a0,a0,1050 # 7700 <malloc+0x1a3e>
    32ee:	00003097          	auipc	ra,0x3
    32f2:	916080e7          	jalr	-1770(ra) # 5c04 <printf>
    exit(1);
    32f6:	4505                	li	a0,1
    32f8:	00002097          	auipc	ra,0x2
    32fc:	55c080e7          	jalr	1372(ra) # 5854 <exit>
      printf("%s: read bigfile failed\n", s);
    3300:	85d6                	mv	a1,s5
    3302:	00004517          	auipc	a0,0x4
    3306:	41e50513          	addi	a0,a0,1054 # 7720 <malloc+0x1a5e>
    330a:	00003097          	auipc	ra,0x3
    330e:	8fa080e7          	jalr	-1798(ra) # 5c04 <printf>
      exit(1);
    3312:	4505                	li	a0,1
    3314:	00002097          	auipc	ra,0x2
    3318:	540080e7          	jalr	1344(ra) # 5854 <exit>
      printf("%s: short read bigfile\n", s);
    331c:	85d6                	mv	a1,s5
    331e:	00004517          	auipc	a0,0x4
    3322:	42250513          	addi	a0,a0,1058 # 7740 <malloc+0x1a7e>
    3326:	00003097          	auipc	ra,0x3
    332a:	8de080e7          	jalr	-1826(ra) # 5c04 <printf>
      exit(1);
    332e:	4505                	li	a0,1
    3330:	00002097          	auipc	ra,0x2
    3334:	524080e7          	jalr	1316(ra) # 5854 <exit>
      printf("%s: read bigfile wrong data\n", s);
    3338:	85d6                	mv	a1,s5
    333a:	00004517          	auipc	a0,0x4
    333e:	41e50513          	addi	a0,a0,1054 # 7758 <malloc+0x1a96>
    3342:	00003097          	auipc	ra,0x3
    3346:	8c2080e7          	jalr	-1854(ra) # 5c04 <printf>
      exit(1);
    334a:	4505                	li	a0,1
    334c:	00002097          	auipc	ra,0x2
    3350:	508080e7          	jalr	1288(ra) # 5854 <exit>
  close(fd);
    3354:	8552                	mv	a0,s4
    3356:	00002097          	auipc	ra,0x2
    335a:	526080e7          	jalr	1318(ra) # 587c <close>
  if(total != N*SZ){
    335e:	678d                	lui	a5,0x3
    3360:	ee078793          	addi	a5,a5,-288 # 2ee0 <reparent+0xe>
    3364:	02f99363          	bne	s3,a5,338a <bigfile+0x1c4>
  unlink("bigfile.dat");
    3368:	00004517          	auipc	a0,0x4
    336c:	34850513          	addi	a0,a0,840 # 76b0 <malloc+0x19ee>
    3370:	00002097          	auipc	ra,0x2
    3374:	534080e7          	jalr	1332(ra) # 58a4 <unlink>
}
    3378:	70e2                	ld	ra,56(sp)
    337a:	7442                	ld	s0,48(sp)
    337c:	74a2                	ld	s1,40(sp)
    337e:	7902                	ld	s2,32(sp)
    3380:	69e2                	ld	s3,24(sp)
    3382:	6a42                	ld	s4,16(sp)
    3384:	6aa2                	ld	s5,8(sp)
    3386:	6121                	addi	sp,sp,64
    3388:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    338a:	85d6                	mv	a1,s5
    338c:	00004517          	auipc	a0,0x4
    3390:	3ec50513          	addi	a0,a0,1004 # 7778 <malloc+0x1ab6>
    3394:	00003097          	auipc	ra,0x3
    3398:	870080e7          	jalr	-1936(ra) # 5c04 <printf>
    exit(1);
    339c:	4505                	li	a0,1
    339e:	00002097          	auipc	ra,0x2
    33a2:	4b6080e7          	jalr	1206(ra) # 5854 <exit>

00000000000033a6 <truncate3>:
{
    33a6:	7159                	addi	sp,sp,-112
    33a8:	f486                	sd	ra,104(sp)
    33aa:	f0a2                	sd	s0,96(sp)
    33ac:	eca6                	sd	s1,88(sp)
    33ae:	e8ca                	sd	s2,80(sp)
    33b0:	e4ce                	sd	s3,72(sp)
    33b2:	e0d2                	sd	s4,64(sp)
    33b4:	fc56                	sd	s5,56(sp)
    33b6:	1880                	addi	s0,sp,112
    33b8:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    33ba:	60100593          	li	a1,1537
    33be:	00003517          	auipc	a0,0x3
    33c2:	e4a50513          	addi	a0,a0,-438 # 6208 <malloc+0x546>
    33c6:	00002097          	auipc	ra,0x2
    33ca:	4ce080e7          	jalr	1230(ra) # 5894 <open>
    33ce:	00002097          	auipc	ra,0x2
    33d2:	4ae080e7          	jalr	1198(ra) # 587c <close>
  pid = fork();
    33d6:	00002097          	auipc	ra,0x2
    33da:	476080e7          	jalr	1142(ra) # 584c <fork>
  if(pid < 0){
    33de:	08054063          	bltz	a0,345e <truncate3+0xb8>
  if(pid == 0){
    33e2:	e969                	bnez	a0,34b4 <truncate3+0x10e>
    33e4:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    33e8:	00003a17          	auipc	s4,0x3
    33ec:	e20a0a13          	addi	s4,s4,-480 # 6208 <malloc+0x546>
      int n = write(fd, "1234567890", 10);
    33f0:	00004a97          	auipc	s5,0x4
    33f4:	3a8a8a93          	addi	s5,s5,936 # 7798 <malloc+0x1ad6>
      int fd = open("truncfile", O_WRONLY);
    33f8:	4585                	li	a1,1
    33fa:	8552                	mv	a0,s4
    33fc:	00002097          	auipc	ra,0x2
    3400:	498080e7          	jalr	1176(ra) # 5894 <open>
    3404:	84aa                	mv	s1,a0
      if(fd < 0){
    3406:	06054a63          	bltz	a0,347a <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    340a:	4629                	li	a2,10
    340c:	85d6                	mv	a1,s5
    340e:	00002097          	auipc	ra,0x2
    3412:	466080e7          	jalr	1126(ra) # 5874 <write>
      if(n != 10){
    3416:	47a9                	li	a5,10
    3418:	06f51f63          	bne	a0,a5,3496 <truncate3+0xf0>
      close(fd);
    341c:	8526                	mv	a0,s1
    341e:	00002097          	auipc	ra,0x2
    3422:	45e080e7          	jalr	1118(ra) # 587c <close>
      fd = open("truncfile", O_RDONLY);
    3426:	4581                	li	a1,0
    3428:	8552                	mv	a0,s4
    342a:	00002097          	auipc	ra,0x2
    342e:	46a080e7          	jalr	1130(ra) # 5894 <open>
    3432:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    3434:	02000613          	li	a2,32
    3438:	f9840593          	addi	a1,s0,-104
    343c:	00002097          	auipc	ra,0x2
    3440:	430080e7          	jalr	1072(ra) # 586c <read>
      close(fd);
    3444:	8526                	mv	a0,s1
    3446:	00002097          	auipc	ra,0x2
    344a:	436080e7          	jalr	1078(ra) # 587c <close>
    for(int i = 0; i < 100; i++){
    344e:	39fd                	addiw	s3,s3,-1
    3450:	fa0994e3          	bnez	s3,33f8 <truncate3+0x52>
    exit(0);
    3454:	4501                	li	a0,0
    3456:	00002097          	auipc	ra,0x2
    345a:	3fe080e7          	jalr	1022(ra) # 5854 <exit>
    printf("%s: fork failed\n", s);
    345e:	85ca                	mv	a1,s2
    3460:	00003517          	auipc	a0,0x3
    3464:	bd850513          	addi	a0,a0,-1064 # 6038 <malloc+0x376>
    3468:	00002097          	auipc	ra,0x2
    346c:	79c080e7          	jalr	1948(ra) # 5c04 <printf>
    exit(1);
    3470:	4505                	li	a0,1
    3472:	00002097          	auipc	ra,0x2
    3476:	3e2080e7          	jalr	994(ra) # 5854 <exit>
        printf("%s: open failed\n", s);
    347a:	85ca                	mv	a1,s2
    347c:	00003517          	auipc	a0,0x3
    3480:	46c50513          	addi	a0,a0,1132 # 68e8 <malloc+0xc26>
    3484:	00002097          	auipc	ra,0x2
    3488:	780080e7          	jalr	1920(ra) # 5c04 <printf>
        exit(1);
    348c:	4505                	li	a0,1
    348e:	00002097          	auipc	ra,0x2
    3492:	3c6080e7          	jalr	966(ra) # 5854 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    3496:	862a                	mv	a2,a0
    3498:	85ca                	mv	a1,s2
    349a:	00004517          	auipc	a0,0x4
    349e:	30e50513          	addi	a0,a0,782 # 77a8 <malloc+0x1ae6>
    34a2:	00002097          	auipc	ra,0x2
    34a6:	762080e7          	jalr	1890(ra) # 5c04 <printf>
        exit(1);
    34aa:	4505                	li	a0,1
    34ac:	00002097          	auipc	ra,0x2
    34b0:	3a8080e7          	jalr	936(ra) # 5854 <exit>
    34b4:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    34b8:	00003a17          	auipc	s4,0x3
    34bc:	d50a0a13          	addi	s4,s4,-688 # 6208 <malloc+0x546>
    int n = write(fd, "xxx", 3);
    34c0:	00004a97          	auipc	s5,0x4
    34c4:	308a8a93          	addi	s5,s5,776 # 77c8 <malloc+0x1b06>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    34c8:	60100593          	li	a1,1537
    34cc:	8552                	mv	a0,s4
    34ce:	00002097          	auipc	ra,0x2
    34d2:	3c6080e7          	jalr	966(ra) # 5894 <open>
    34d6:	84aa                	mv	s1,a0
    if(fd < 0){
    34d8:	04054763          	bltz	a0,3526 <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    34dc:	460d                	li	a2,3
    34de:	85d6                	mv	a1,s5
    34e0:	00002097          	auipc	ra,0x2
    34e4:	394080e7          	jalr	916(ra) # 5874 <write>
    if(n != 3){
    34e8:	478d                	li	a5,3
    34ea:	04f51c63          	bne	a0,a5,3542 <truncate3+0x19c>
    close(fd);
    34ee:	8526                	mv	a0,s1
    34f0:	00002097          	auipc	ra,0x2
    34f4:	38c080e7          	jalr	908(ra) # 587c <close>
  for(int i = 0; i < 150; i++){
    34f8:	39fd                	addiw	s3,s3,-1
    34fa:	fc0997e3          	bnez	s3,34c8 <truncate3+0x122>
  wait(&xstatus);
    34fe:	fbc40513          	addi	a0,s0,-68
    3502:	00002097          	auipc	ra,0x2
    3506:	35a080e7          	jalr	858(ra) # 585c <wait>
  unlink("truncfile");
    350a:	00003517          	auipc	a0,0x3
    350e:	cfe50513          	addi	a0,a0,-770 # 6208 <malloc+0x546>
    3512:	00002097          	auipc	ra,0x2
    3516:	392080e7          	jalr	914(ra) # 58a4 <unlink>
  exit(xstatus);
    351a:	fbc42503          	lw	a0,-68(s0)
    351e:	00002097          	auipc	ra,0x2
    3522:	336080e7          	jalr	822(ra) # 5854 <exit>
      printf("%s: open failed\n", s);
    3526:	85ca                	mv	a1,s2
    3528:	00003517          	auipc	a0,0x3
    352c:	3c050513          	addi	a0,a0,960 # 68e8 <malloc+0xc26>
    3530:	00002097          	auipc	ra,0x2
    3534:	6d4080e7          	jalr	1748(ra) # 5c04 <printf>
      exit(1);
    3538:	4505                	li	a0,1
    353a:	00002097          	auipc	ra,0x2
    353e:	31a080e7          	jalr	794(ra) # 5854 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    3542:	862a                	mv	a2,a0
    3544:	85ca                	mv	a1,s2
    3546:	00004517          	auipc	a0,0x4
    354a:	28a50513          	addi	a0,a0,650 # 77d0 <malloc+0x1b0e>
    354e:	00002097          	auipc	ra,0x2
    3552:	6b6080e7          	jalr	1718(ra) # 5c04 <printf>
      exit(1);
    3556:	4505                	li	a0,1
    3558:	00002097          	auipc	ra,0x2
    355c:	2fc080e7          	jalr	764(ra) # 5854 <exit>

0000000000003560 <writetest>:
{
    3560:	7139                	addi	sp,sp,-64
    3562:	fc06                	sd	ra,56(sp)
    3564:	f822                	sd	s0,48(sp)
    3566:	f426                	sd	s1,40(sp)
    3568:	f04a                	sd	s2,32(sp)
    356a:	ec4e                	sd	s3,24(sp)
    356c:	e852                	sd	s4,16(sp)
    356e:	e456                	sd	s5,8(sp)
    3570:	e05a                	sd	s6,0(sp)
    3572:	0080                	addi	s0,sp,64
    3574:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
    3576:	20200593          	li	a1,514
    357a:	00004517          	auipc	a0,0x4
    357e:	27650513          	addi	a0,a0,630 # 77f0 <malloc+0x1b2e>
    3582:	00002097          	auipc	ra,0x2
    3586:	312080e7          	jalr	786(ra) # 5894 <open>
  if(fd < 0){
    358a:	0a054d63          	bltz	a0,3644 <writetest+0xe4>
    358e:	892a                	mv	s2,a0
    3590:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
    3592:	00004997          	auipc	s3,0x4
    3596:	28698993          	addi	s3,s3,646 # 7818 <malloc+0x1b56>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
    359a:	00004a97          	auipc	s5,0x4
    359e:	2b6a8a93          	addi	s5,s5,694 # 7850 <malloc+0x1b8e>
  for(i = 0; i < N; i++){
    35a2:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
    35a6:	4629                	li	a2,10
    35a8:	85ce                	mv	a1,s3
    35aa:	854a                	mv	a0,s2
    35ac:	00002097          	auipc	ra,0x2
    35b0:	2c8080e7          	jalr	712(ra) # 5874 <write>
    35b4:	47a9                	li	a5,10
    35b6:	0af51563          	bne	a0,a5,3660 <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
    35ba:	4629                	li	a2,10
    35bc:	85d6                	mv	a1,s5
    35be:	854a                	mv	a0,s2
    35c0:	00002097          	auipc	ra,0x2
    35c4:	2b4080e7          	jalr	692(ra) # 5874 <write>
    35c8:	47a9                	li	a5,10
    35ca:	0af51a63          	bne	a0,a5,367e <writetest+0x11e>
  for(i = 0; i < N; i++){
    35ce:	2485                	addiw	s1,s1,1
    35d0:	fd449be3          	bne	s1,s4,35a6 <writetest+0x46>
  close(fd);
    35d4:	854a                	mv	a0,s2
    35d6:	00002097          	auipc	ra,0x2
    35da:	2a6080e7          	jalr	678(ra) # 587c <close>
  fd = open("small", O_RDONLY);
    35de:	4581                	li	a1,0
    35e0:	00004517          	auipc	a0,0x4
    35e4:	21050513          	addi	a0,a0,528 # 77f0 <malloc+0x1b2e>
    35e8:	00002097          	auipc	ra,0x2
    35ec:	2ac080e7          	jalr	684(ra) # 5894 <open>
    35f0:	84aa                	mv	s1,a0
  if(fd < 0){
    35f2:	0a054563          	bltz	a0,369c <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
    35f6:	7d000613          	li	a2,2000
    35fa:	00008597          	auipc	a1,0x8
    35fe:	5f658593          	addi	a1,a1,1526 # bbf0 <buf>
    3602:	00002097          	auipc	ra,0x2
    3606:	26a080e7          	jalr	618(ra) # 586c <read>
  if(i != N*SZ*2){
    360a:	7d000793          	li	a5,2000
    360e:	0af51563          	bne	a0,a5,36b8 <writetest+0x158>
  close(fd);
    3612:	8526                	mv	a0,s1
    3614:	00002097          	auipc	ra,0x2
    3618:	268080e7          	jalr	616(ra) # 587c <close>
  if(unlink("small") < 0){
    361c:	00004517          	auipc	a0,0x4
    3620:	1d450513          	addi	a0,a0,468 # 77f0 <malloc+0x1b2e>
    3624:	00002097          	auipc	ra,0x2
    3628:	280080e7          	jalr	640(ra) # 58a4 <unlink>
    362c:	0a054463          	bltz	a0,36d4 <writetest+0x174>
}
    3630:	70e2                	ld	ra,56(sp)
    3632:	7442                	ld	s0,48(sp)
    3634:	74a2                	ld	s1,40(sp)
    3636:	7902                	ld	s2,32(sp)
    3638:	69e2                	ld	s3,24(sp)
    363a:	6a42                	ld	s4,16(sp)
    363c:	6aa2                	ld	s5,8(sp)
    363e:	6b02                	ld	s6,0(sp)
    3640:	6121                	addi	sp,sp,64
    3642:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
    3644:	85da                	mv	a1,s6
    3646:	00004517          	auipc	a0,0x4
    364a:	1b250513          	addi	a0,a0,434 # 77f8 <malloc+0x1b36>
    364e:	00002097          	auipc	ra,0x2
    3652:	5b6080e7          	jalr	1462(ra) # 5c04 <printf>
    exit(1);
    3656:	4505                	li	a0,1
    3658:	00002097          	auipc	ra,0x2
    365c:	1fc080e7          	jalr	508(ra) # 5854 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
    3660:	8626                	mv	a2,s1
    3662:	85da                	mv	a1,s6
    3664:	00004517          	auipc	a0,0x4
    3668:	1c450513          	addi	a0,a0,452 # 7828 <malloc+0x1b66>
    366c:	00002097          	auipc	ra,0x2
    3670:	598080e7          	jalr	1432(ra) # 5c04 <printf>
      exit(1);
    3674:	4505                	li	a0,1
    3676:	00002097          	auipc	ra,0x2
    367a:	1de080e7          	jalr	478(ra) # 5854 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
    367e:	8626                	mv	a2,s1
    3680:	85da                	mv	a1,s6
    3682:	00004517          	auipc	a0,0x4
    3686:	1de50513          	addi	a0,a0,478 # 7860 <malloc+0x1b9e>
    368a:	00002097          	auipc	ra,0x2
    368e:	57a080e7          	jalr	1402(ra) # 5c04 <printf>
      exit(1);
    3692:	4505                	li	a0,1
    3694:	00002097          	auipc	ra,0x2
    3698:	1c0080e7          	jalr	448(ra) # 5854 <exit>
    printf("%s: error: open small failed!\n", s);
    369c:	85da                	mv	a1,s6
    369e:	00004517          	auipc	a0,0x4
    36a2:	1ea50513          	addi	a0,a0,490 # 7888 <malloc+0x1bc6>
    36a6:	00002097          	auipc	ra,0x2
    36aa:	55e080e7          	jalr	1374(ra) # 5c04 <printf>
    exit(1);
    36ae:	4505                	li	a0,1
    36b0:	00002097          	auipc	ra,0x2
    36b4:	1a4080e7          	jalr	420(ra) # 5854 <exit>
    printf("%s: read failed\n", s);
    36b8:	85da                	mv	a1,s6
    36ba:	00003517          	auipc	a0,0x3
    36be:	24650513          	addi	a0,a0,582 # 6900 <malloc+0xc3e>
    36c2:	00002097          	auipc	ra,0x2
    36c6:	542080e7          	jalr	1346(ra) # 5c04 <printf>
    exit(1);
    36ca:	4505                	li	a0,1
    36cc:	00002097          	auipc	ra,0x2
    36d0:	188080e7          	jalr	392(ra) # 5854 <exit>
    printf("%s: unlink small failed\n", s);
    36d4:	85da                	mv	a1,s6
    36d6:	00004517          	auipc	a0,0x4
    36da:	1d250513          	addi	a0,a0,466 # 78a8 <malloc+0x1be6>
    36de:	00002097          	auipc	ra,0x2
    36e2:	526080e7          	jalr	1318(ra) # 5c04 <printf>
    exit(1);
    36e6:	4505                	li	a0,1
    36e8:	00002097          	auipc	ra,0x2
    36ec:	16c080e7          	jalr	364(ra) # 5854 <exit>

00000000000036f0 <writebig>:
{
    36f0:	7139                	addi	sp,sp,-64
    36f2:	fc06                	sd	ra,56(sp)
    36f4:	f822                	sd	s0,48(sp)
    36f6:	f426                	sd	s1,40(sp)
    36f8:	f04a                	sd	s2,32(sp)
    36fa:	ec4e                	sd	s3,24(sp)
    36fc:	e852                	sd	s4,16(sp)
    36fe:	e456                	sd	s5,8(sp)
    3700:	0080                	addi	s0,sp,64
    3702:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
    3704:	20200593          	li	a1,514
    3708:	00004517          	auipc	a0,0x4
    370c:	1c050513          	addi	a0,a0,448 # 78c8 <malloc+0x1c06>
    3710:	00002097          	auipc	ra,0x2
    3714:	184080e7          	jalr	388(ra) # 5894 <open>
    3718:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
    371a:	4481                	li	s1,0
    ((int*)buf)[0] = i;
    371c:	00008917          	auipc	s2,0x8
    3720:	4d490913          	addi	s2,s2,1236 # bbf0 <buf>
  for(i = 0; i < MAXFILE; i++){
    3724:	10c00a13          	li	s4,268
  if(fd < 0){
    3728:	06054c63          	bltz	a0,37a0 <writebig+0xb0>
    ((int*)buf)[0] = i;
    372c:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
    3730:	40000613          	li	a2,1024
    3734:	85ca                	mv	a1,s2
    3736:	854e                	mv	a0,s3
    3738:	00002097          	auipc	ra,0x2
    373c:	13c080e7          	jalr	316(ra) # 5874 <write>
    3740:	40000793          	li	a5,1024
    3744:	06f51c63          	bne	a0,a5,37bc <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
    3748:	2485                	addiw	s1,s1,1
    374a:	ff4491e3          	bne	s1,s4,372c <writebig+0x3c>
  close(fd);
    374e:	854e                	mv	a0,s3
    3750:	00002097          	auipc	ra,0x2
    3754:	12c080e7          	jalr	300(ra) # 587c <close>
  fd = open("big", O_RDONLY);
    3758:	4581                	li	a1,0
    375a:	00004517          	auipc	a0,0x4
    375e:	16e50513          	addi	a0,a0,366 # 78c8 <malloc+0x1c06>
    3762:	00002097          	auipc	ra,0x2
    3766:	132080e7          	jalr	306(ra) # 5894 <open>
    376a:	89aa                	mv	s3,a0
  n = 0;
    376c:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
    376e:	00008917          	auipc	s2,0x8
    3772:	48290913          	addi	s2,s2,1154 # bbf0 <buf>
  if(fd < 0){
    3776:	06054263          	bltz	a0,37da <writebig+0xea>
    i = read(fd, buf, BSIZE);
    377a:	40000613          	li	a2,1024
    377e:	85ca                	mv	a1,s2
    3780:	854e                	mv	a0,s3
    3782:	00002097          	auipc	ra,0x2
    3786:	0ea080e7          	jalr	234(ra) # 586c <read>
    if(i == 0){
    378a:	c535                	beqz	a0,37f6 <writebig+0x106>
    } else if(i != BSIZE){
    378c:	40000793          	li	a5,1024
    3790:	0af51f63          	bne	a0,a5,384e <writebig+0x15e>
    if(((int*)buf)[0] != n){
    3794:	00092683          	lw	a3,0(s2)
    3798:	0c969a63          	bne	a3,s1,386c <writebig+0x17c>
    n++;
    379c:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
    379e:	bff1                	j	377a <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
    37a0:	85d6                	mv	a1,s5
    37a2:	00004517          	auipc	a0,0x4
    37a6:	12e50513          	addi	a0,a0,302 # 78d0 <malloc+0x1c0e>
    37aa:	00002097          	auipc	ra,0x2
    37ae:	45a080e7          	jalr	1114(ra) # 5c04 <printf>
    exit(1);
    37b2:	4505                	li	a0,1
    37b4:	00002097          	auipc	ra,0x2
    37b8:	0a0080e7          	jalr	160(ra) # 5854 <exit>
      printf("%s: error: write big file failed\n", s, i);
    37bc:	8626                	mv	a2,s1
    37be:	85d6                	mv	a1,s5
    37c0:	00004517          	auipc	a0,0x4
    37c4:	13050513          	addi	a0,a0,304 # 78f0 <malloc+0x1c2e>
    37c8:	00002097          	auipc	ra,0x2
    37cc:	43c080e7          	jalr	1084(ra) # 5c04 <printf>
      exit(1);
    37d0:	4505                	li	a0,1
    37d2:	00002097          	auipc	ra,0x2
    37d6:	082080e7          	jalr	130(ra) # 5854 <exit>
    printf("%s: error: open big failed!\n", s);
    37da:	85d6                	mv	a1,s5
    37dc:	00004517          	auipc	a0,0x4
    37e0:	13c50513          	addi	a0,a0,316 # 7918 <malloc+0x1c56>
    37e4:	00002097          	auipc	ra,0x2
    37e8:	420080e7          	jalr	1056(ra) # 5c04 <printf>
    exit(1);
    37ec:	4505                	li	a0,1
    37ee:	00002097          	auipc	ra,0x2
    37f2:	066080e7          	jalr	102(ra) # 5854 <exit>
      if(n == MAXFILE - 1){
    37f6:	10b00793          	li	a5,267
    37fa:	02f48a63          	beq	s1,a5,382e <writebig+0x13e>
  close(fd);
    37fe:	854e                	mv	a0,s3
    3800:	00002097          	auipc	ra,0x2
    3804:	07c080e7          	jalr	124(ra) # 587c <close>
  if(unlink("big") < 0){
    3808:	00004517          	auipc	a0,0x4
    380c:	0c050513          	addi	a0,a0,192 # 78c8 <malloc+0x1c06>
    3810:	00002097          	auipc	ra,0x2
    3814:	094080e7          	jalr	148(ra) # 58a4 <unlink>
    3818:	06054963          	bltz	a0,388a <writebig+0x19a>
}
    381c:	70e2                	ld	ra,56(sp)
    381e:	7442                	ld	s0,48(sp)
    3820:	74a2                	ld	s1,40(sp)
    3822:	7902                	ld	s2,32(sp)
    3824:	69e2                	ld	s3,24(sp)
    3826:	6a42                	ld	s4,16(sp)
    3828:	6aa2                	ld	s5,8(sp)
    382a:	6121                	addi	sp,sp,64
    382c:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
    382e:	10b00613          	li	a2,267
    3832:	85d6                	mv	a1,s5
    3834:	00004517          	auipc	a0,0x4
    3838:	10450513          	addi	a0,a0,260 # 7938 <malloc+0x1c76>
    383c:	00002097          	auipc	ra,0x2
    3840:	3c8080e7          	jalr	968(ra) # 5c04 <printf>
        exit(1);
    3844:	4505                	li	a0,1
    3846:	00002097          	auipc	ra,0x2
    384a:	00e080e7          	jalr	14(ra) # 5854 <exit>
      printf("%s: read failed %d\n", s, i);
    384e:	862a                	mv	a2,a0
    3850:	85d6                	mv	a1,s5
    3852:	00004517          	auipc	a0,0x4
    3856:	10e50513          	addi	a0,a0,270 # 7960 <malloc+0x1c9e>
    385a:	00002097          	auipc	ra,0x2
    385e:	3aa080e7          	jalr	938(ra) # 5c04 <printf>
      exit(1);
    3862:	4505                	li	a0,1
    3864:	00002097          	auipc	ra,0x2
    3868:	ff0080e7          	jalr	-16(ra) # 5854 <exit>
      printf("%s: read content of block %d is %d\n", s,
    386c:	8626                	mv	a2,s1
    386e:	85d6                	mv	a1,s5
    3870:	00004517          	auipc	a0,0x4
    3874:	10850513          	addi	a0,a0,264 # 7978 <malloc+0x1cb6>
    3878:	00002097          	auipc	ra,0x2
    387c:	38c080e7          	jalr	908(ra) # 5c04 <printf>
      exit(1);
    3880:	4505                	li	a0,1
    3882:	00002097          	auipc	ra,0x2
    3886:	fd2080e7          	jalr	-46(ra) # 5854 <exit>
    printf("%s: unlink big failed\n", s);
    388a:	85d6                	mv	a1,s5
    388c:	00004517          	auipc	a0,0x4
    3890:	11450513          	addi	a0,a0,276 # 79a0 <malloc+0x1cde>
    3894:	00002097          	auipc	ra,0x2
    3898:	370080e7          	jalr	880(ra) # 5c04 <printf>
    exit(1);
    389c:	4505                	li	a0,1
    389e:	00002097          	auipc	ra,0x2
    38a2:	fb6080e7          	jalr	-74(ra) # 5854 <exit>

00000000000038a6 <createtest>:
{
    38a6:	7179                	addi	sp,sp,-48
    38a8:	f406                	sd	ra,40(sp)
    38aa:	f022                	sd	s0,32(sp)
    38ac:	ec26                	sd	s1,24(sp)
    38ae:	e84a                	sd	s2,16(sp)
    38b0:	1800                	addi	s0,sp,48
  name[0] = 'a';
    38b2:	06100793          	li	a5,97
    38b6:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
    38ba:	fc040d23          	sb	zero,-38(s0)
    38be:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
    38c2:	06400913          	li	s2,100
    name[1] = '0' + i;
    38c6:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
    38ca:	20200593          	li	a1,514
    38ce:	fd840513          	addi	a0,s0,-40
    38d2:	00002097          	auipc	ra,0x2
    38d6:	fc2080e7          	jalr	-62(ra) # 5894 <open>
    close(fd);
    38da:	00002097          	auipc	ra,0x2
    38de:	fa2080e7          	jalr	-94(ra) # 587c <close>
  for(i = 0; i < N; i++){
    38e2:	2485                	addiw	s1,s1,1
    38e4:	0ff4f493          	andi	s1,s1,255
    38e8:	fd249fe3          	bne	s1,s2,38c6 <createtest+0x20>
  name[0] = 'a';
    38ec:	06100793          	li	a5,97
    38f0:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
    38f4:	fc040d23          	sb	zero,-38(s0)
    38f8:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
    38fc:	06400913          	li	s2,100
    name[1] = '0' + i;
    3900:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
    3904:	fd840513          	addi	a0,s0,-40
    3908:	00002097          	auipc	ra,0x2
    390c:	f9c080e7          	jalr	-100(ra) # 58a4 <unlink>
  for(i = 0; i < N; i++){
    3910:	2485                	addiw	s1,s1,1
    3912:	0ff4f493          	andi	s1,s1,255
    3916:	ff2495e3          	bne	s1,s2,3900 <createtest+0x5a>
}
    391a:	70a2                	ld	ra,40(sp)
    391c:	7402                	ld	s0,32(sp)
    391e:	64e2                	ld	s1,24(sp)
    3920:	6942                	ld	s2,16(sp)
    3922:	6145                	addi	sp,sp,48
    3924:	8082                	ret

0000000000003926 <killstatus>:
{
    3926:	7139                	addi	sp,sp,-64
    3928:	fc06                	sd	ra,56(sp)
    392a:	f822                	sd	s0,48(sp)
    392c:	f426                	sd	s1,40(sp)
    392e:	f04a                	sd	s2,32(sp)
    3930:	ec4e                	sd	s3,24(sp)
    3932:	e852                	sd	s4,16(sp)
    3934:	0080                	addi	s0,sp,64
    3936:	8a2a                	mv	s4,a0
    3938:	06400913          	li	s2,100
    if(xst != -1) {
    393c:	59fd                	li	s3,-1
    int pid1 = fork();
    393e:	00002097          	auipc	ra,0x2
    3942:	f0e080e7          	jalr	-242(ra) # 584c <fork>
    3946:	84aa                	mv	s1,a0
    if(pid1 < 0){
    3948:	04054063          	bltz	a0,3988 <killstatus+0x62>
    if(pid1 == 0){
    394c:	cd21                	beqz	a0,39a4 <killstatus+0x7e>
    sleep(1);
    394e:	4505                	li	a0,1
    3950:	00002097          	auipc	ra,0x2
    3954:	f94080e7          	jalr	-108(ra) # 58e4 <sleep>
    kill(pid1, SIGKILL);
    3958:	45a5                	li	a1,9
    395a:	8526                	mv	a0,s1
    395c:	00002097          	auipc	ra,0x2
    3960:	f28080e7          	jalr	-216(ra) # 5884 <kill>
    wait(&xst);
    3964:	fcc40513          	addi	a0,s0,-52
    3968:	00002097          	auipc	ra,0x2
    396c:	ef4080e7          	jalr	-268(ra) # 585c <wait>
    if(xst != -1) {
    3970:	fcc42783          	lw	a5,-52(s0)
    3974:	03379d63          	bne	a5,s3,39ae <killstatus+0x88>
  for(int i = 0; i < 100; i++){
    3978:	397d                	addiw	s2,s2,-1
    397a:	fc0912e3          	bnez	s2,393e <killstatus+0x18>
  exit(0);
    397e:	4501                	li	a0,0
    3980:	00002097          	auipc	ra,0x2
    3984:	ed4080e7          	jalr	-300(ra) # 5854 <exit>
      printf("%s: fork failed\n", s);
    3988:	85d2                	mv	a1,s4
    398a:	00002517          	auipc	a0,0x2
    398e:	6ae50513          	addi	a0,a0,1710 # 6038 <malloc+0x376>
    3992:	00002097          	auipc	ra,0x2
    3996:	272080e7          	jalr	626(ra) # 5c04 <printf>
      exit(1);
    399a:	4505                	li	a0,1
    399c:	00002097          	auipc	ra,0x2
    39a0:	eb8080e7          	jalr	-328(ra) # 5854 <exit>
        getpid();
    39a4:	00002097          	auipc	ra,0x2
    39a8:	f30080e7          	jalr	-208(ra) # 58d4 <getpid>
      while(1) {
    39ac:	bfe5                	j	39a4 <killstatus+0x7e>
       printf("%s: status should be -1\n", s);
    39ae:	85d2                	mv	a1,s4
    39b0:	00004517          	auipc	a0,0x4
    39b4:	00850513          	addi	a0,a0,8 # 79b8 <malloc+0x1cf6>
    39b8:	00002097          	auipc	ra,0x2
    39bc:	24c080e7          	jalr	588(ra) # 5c04 <printf>
       exit(1);
    39c0:	4505                	li	a0,1
    39c2:	00002097          	auipc	ra,0x2
    39c6:	e92080e7          	jalr	-366(ra) # 5854 <exit>

00000000000039ca <reparent2>:
{
    39ca:	1101                	addi	sp,sp,-32
    39cc:	ec06                	sd	ra,24(sp)
    39ce:	e822                	sd	s0,16(sp)
    39d0:	e426                	sd	s1,8(sp)
    39d2:	1000                	addi	s0,sp,32
    39d4:	32000493          	li	s1,800
    int pid1 = fork();
    39d8:	00002097          	auipc	ra,0x2
    39dc:	e74080e7          	jalr	-396(ra) # 584c <fork>
    if(pid1 < 0){
    39e0:	00054f63          	bltz	a0,39fe <reparent2+0x34>
    if(pid1 == 0){
    39e4:	c915                	beqz	a0,3a18 <reparent2+0x4e>
    wait(0);
    39e6:	4501                	li	a0,0
    39e8:	00002097          	auipc	ra,0x2
    39ec:	e74080e7          	jalr	-396(ra) # 585c <wait>
  for(int i = 0; i < 800; i++){
    39f0:	34fd                	addiw	s1,s1,-1
    39f2:	f0fd                	bnez	s1,39d8 <reparent2+0xe>
  exit(0);
    39f4:	4501                	li	a0,0
    39f6:	00002097          	auipc	ra,0x2
    39fa:	e5e080e7          	jalr	-418(ra) # 5854 <exit>
      printf("fork failed\n");
    39fe:	00003517          	auipc	a0,0x3
    3a02:	03250513          	addi	a0,a0,50 # 6a30 <malloc+0xd6e>
    3a06:	00002097          	auipc	ra,0x2
    3a0a:	1fe080e7          	jalr	510(ra) # 5c04 <printf>
      exit(1);
    3a0e:	4505                	li	a0,1
    3a10:	00002097          	auipc	ra,0x2
    3a14:	e44080e7          	jalr	-444(ra) # 5854 <exit>
      fork();
    3a18:	00002097          	auipc	ra,0x2
    3a1c:	e34080e7          	jalr	-460(ra) # 584c <fork>
      fork();
    3a20:	00002097          	auipc	ra,0x2
    3a24:	e2c080e7          	jalr	-468(ra) # 584c <fork>
      exit(0);
    3a28:	4501                	li	a0,0
    3a2a:	00002097          	auipc	ra,0x2
    3a2e:	e2a080e7          	jalr	-470(ra) # 5854 <exit>

0000000000003a32 <mem>:
{
    3a32:	7139                	addi	sp,sp,-64
    3a34:	fc06                	sd	ra,56(sp)
    3a36:	f822                	sd	s0,48(sp)
    3a38:	f426                	sd	s1,40(sp)
    3a3a:	f04a                	sd	s2,32(sp)
    3a3c:	ec4e                	sd	s3,24(sp)
    3a3e:	0080                	addi	s0,sp,64
    3a40:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    3a42:	00002097          	auipc	ra,0x2
    3a46:	e0a080e7          	jalr	-502(ra) # 584c <fork>
    m1 = 0;
    3a4a:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    3a4c:	6909                	lui	s2,0x2
    3a4e:	71190913          	addi	s2,s2,1809 # 2711 <subdir+0x3bf>
  if((pid = fork()) == 0){
    3a52:	c115                	beqz	a0,3a76 <mem+0x44>
    wait(&xstatus);
    3a54:	fcc40513          	addi	a0,s0,-52
    3a58:	00002097          	auipc	ra,0x2
    3a5c:	e04080e7          	jalr	-508(ra) # 585c <wait>
    if(xstatus == -1){
    3a60:	fcc42503          	lw	a0,-52(s0)
    3a64:	57fd                	li	a5,-1
    3a66:	06f50363          	beq	a0,a5,3acc <mem+0x9a>
    exit(xstatus);
    3a6a:	00002097          	auipc	ra,0x2
    3a6e:	dea080e7          	jalr	-534(ra) # 5854 <exit>
      *(char**)m2 = m1;
    3a72:	e104                	sd	s1,0(a0)
      m1 = m2;
    3a74:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    3a76:	854a                	mv	a0,s2
    3a78:	00002097          	auipc	ra,0x2
    3a7c:	24a080e7          	jalr	586(ra) # 5cc2 <malloc>
    3a80:	f96d                	bnez	a0,3a72 <mem+0x40>
    while(m1){
    3a82:	c881                	beqz	s1,3a92 <mem+0x60>
      m2 = *(char**)m1;
    3a84:	8526                	mv	a0,s1
    3a86:	6084                	ld	s1,0(s1)
      free(m1);
    3a88:	00002097          	auipc	ra,0x2
    3a8c:	1b2080e7          	jalr	434(ra) # 5c3a <free>
    while(m1){
    3a90:	f8f5                	bnez	s1,3a84 <mem+0x52>
    m1 = malloc(1024*20);
    3a92:	6515                	lui	a0,0x5
    3a94:	00002097          	auipc	ra,0x2
    3a98:	22e080e7          	jalr	558(ra) # 5cc2 <malloc>
    if(m1 == 0){
    3a9c:	c911                	beqz	a0,3ab0 <mem+0x7e>
    free(m1);
    3a9e:	00002097          	auipc	ra,0x2
    3aa2:	19c080e7          	jalr	412(ra) # 5c3a <free>
    exit(0);
    3aa6:	4501                	li	a0,0
    3aa8:	00002097          	auipc	ra,0x2
    3aac:	dac080e7          	jalr	-596(ra) # 5854 <exit>
      printf("couldn't allocate mem?!!\n", s);
    3ab0:	85ce                	mv	a1,s3
    3ab2:	00004517          	auipc	a0,0x4
    3ab6:	f2650513          	addi	a0,a0,-218 # 79d8 <malloc+0x1d16>
    3aba:	00002097          	auipc	ra,0x2
    3abe:	14a080e7          	jalr	330(ra) # 5c04 <printf>
      exit(1);
    3ac2:	4505                	li	a0,1
    3ac4:	00002097          	auipc	ra,0x2
    3ac8:	d90080e7          	jalr	-624(ra) # 5854 <exit>
      exit(0);
    3acc:	4501                	li	a0,0
    3ace:	00002097          	auipc	ra,0x2
    3ad2:	d86080e7          	jalr	-634(ra) # 5854 <exit>

0000000000003ad6 <sharedfd>:
{
    3ad6:	7159                	addi	sp,sp,-112
    3ad8:	f486                	sd	ra,104(sp)
    3ada:	f0a2                	sd	s0,96(sp)
    3adc:	eca6                	sd	s1,88(sp)
    3ade:	e8ca                	sd	s2,80(sp)
    3ae0:	e4ce                	sd	s3,72(sp)
    3ae2:	e0d2                	sd	s4,64(sp)
    3ae4:	fc56                	sd	s5,56(sp)
    3ae6:	f85a                	sd	s6,48(sp)
    3ae8:	f45e                	sd	s7,40(sp)
    3aea:	1880                	addi	s0,sp,112
    3aec:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    3aee:	00004517          	auipc	a0,0x4
    3af2:	f0a50513          	addi	a0,a0,-246 # 79f8 <malloc+0x1d36>
    3af6:	00002097          	auipc	ra,0x2
    3afa:	dae080e7          	jalr	-594(ra) # 58a4 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    3afe:	20200593          	li	a1,514
    3b02:	00004517          	auipc	a0,0x4
    3b06:	ef650513          	addi	a0,a0,-266 # 79f8 <malloc+0x1d36>
    3b0a:	00002097          	auipc	ra,0x2
    3b0e:	d8a080e7          	jalr	-630(ra) # 5894 <open>
  if(fd < 0){
    3b12:	04054a63          	bltz	a0,3b66 <sharedfd+0x90>
    3b16:	892a                	mv	s2,a0
  pid = fork();
    3b18:	00002097          	auipc	ra,0x2
    3b1c:	d34080e7          	jalr	-716(ra) # 584c <fork>
    3b20:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    3b22:	06300593          	li	a1,99
    3b26:	c119                	beqz	a0,3b2c <sharedfd+0x56>
    3b28:	07000593          	li	a1,112
    3b2c:	4629                	li	a2,10
    3b2e:	fa040513          	addi	a0,s0,-96
    3b32:	00002097          	auipc	ra,0x2
    3b36:	b26080e7          	jalr	-1242(ra) # 5658 <memset>
    3b3a:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    3b3e:	4629                	li	a2,10
    3b40:	fa040593          	addi	a1,s0,-96
    3b44:	854a                	mv	a0,s2
    3b46:	00002097          	auipc	ra,0x2
    3b4a:	d2e080e7          	jalr	-722(ra) # 5874 <write>
    3b4e:	47a9                	li	a5,10
    3b50:	02f51963          	bne	a0,a5,3b82 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    3b54:	34fd                	addiw	s1,s1,-1
    3b56:	f4e5                	bnez	s1,3b3e <sharedfd+0x68>
  if(pid == 0) {
    3b58:	04099363          	bnez	s3,3b9e <sharedfd+0xc8>
    exit(0);
    3b5c:	4501                	li	a0,0
    3b5e:	00002097          	auipc	ra,0x2
    3b62:	cf6080e7          	jalr	-778(ra) # 5854 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    3b66:	85d2                	mv	a1,s4
    3b68:	00004517          	auipc	a0,0x4
    3b6c:	ea050513          	addi	a0,a0,-352 # 7a08 <malloc+0x1d46>
    3b70:	00002097          	auipc	ra,0x2
    3b74:	094080e7          	jalr	148(ra) # 5c04 <printf>
    exit(1);
    3b78:	4505                	li	a0,1
    3b7a:	00002097          	auipc	ra,0x2
    3b7e:	cda080e7          	jalr	-806(ra) # 5854 <exit>
      printf("%s: write sharedfd failed\n", s);
    3b82:	85d2                	mv	a1,s4
    3b84:	00004517          	auipc	a0,0x4
    3b88:	eac50513          	addi	a0,a0,-340 # 7a30 <malloc+0x1d6e>
    3b8c:	00002097          	auipc	ra,0x2
    3b90:	078080e7          	jalr	120(ra) # 5c04 <printf>
      exit(1);
    3b94:	4505                	li	a0,1
    3b96:	00002097          	auipc	ra,0x2
    3b9a:	cbe080e7          	jalr	-834(ra) # 5854 <exit>
    wait(&xstatus);
    3b9e:	f9c40513          	addi	a0,s0,-100
    3ba2:	00002097          	auipc	ra,0x2
    3ba6:	cba080e7          	jalr	-838(ra) # 585c <wait>
    if(xstatus != 0)
    3baa:	f9c42983          	lw	s3,-100(s0)
    3bae:	00098763          	beqz	s3,3bbc <sharedfd+0xe6>
      exit(xstatus);
    3bb2:	854e                	mv	a0,s3
    3bb4:	00002097          	auipc	ra,0x2
    3bb8:	ca0080e7          	jalr	-864(ra) # 5854 <exit>
  close(fd);
    3bbc:	854a                	mv	a0,s2
    3bbe:	00002097          	auipc	ra,0x2
    3bc2:	cbe080e7          	jalr	-834(ra) # 587c <close>
  fd = open("sharedfd", 0);
    3bc6:	4581                	li	a1,0
    3bc8:	00004517          	auipc	a0,0x4
    3bcc:	e3050513          	addi	a0,a0,-464 # 79f8 <malloc+0x1d36>
    3bd0:	00002097          	auipc	ra,0x2
    3bd4:	cc4080e7          	jalr	-828(ra) # 5894 <open>
    3bd8:	8baa                	mv	s7,a0
  nc = np = 0;
    3bda:	8ace                	mv	s5,s3
  if(fd < 0){
    3bdc:	02054563          	bltz	a0,3c06 <sharedfd+0x130>
    3be0:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    3be4:	06300493          	li	s1,99
      if(buf[i] == 'p')
    3be8:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    3bec:	4629                	li	a2,10
    3bee:	fa040593          	addi	a1,s0,-96
    3bf2:	855e                	mv	a0,s7
    3bf4:	00002097          	auipc	ra,0x2
    3bf8:	c78080e7          	jalr	-904(ra) # 586c <read>
    3bfc:	02a05f63          	blez	a0,3c3a <sharedfd+0x164>
    3c00:	fa040793          	addi	a5,s0,-96
    3c04:	a01d                	j	3c2a <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    3c06:	85d2                	mv	a1,s4
    3c08:	00004517          	auipc	a0,0x4
    3c0c:	e4850513          	addi	a0,a0,-440 # 7a50 <malloc+0x1d8e>
    3c10:	00002097          	auipc	ra,0x2
    3c14:	ff4080e7          	jalr	-12(ra) # 5c04 <printf>
    exit(1);
    3c18:	4505                	li	a0,1
    3c1a:	00002097          	auipc	ra,0x2
    3c1e:	c3a080e7          	jalr	-966(ra) # 5854 <exit>
        nc++;
    3c22:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    3c24:	0785                	addi	a5,a5,1
    3c26:	fd2783e3          	beq	a5,s2,3bec <sharedfd+0x116>
      if(buf[i] == 'c')
    3c2a:	0007c703          	lbu	a4,0(a5)
    3c2e:	fe970ae3          	beq	a4,s1,3c22 <sharedfd+0x14c>
      if(buf[i] == 'p')
    3c32:	ff6719e3          	bne	a4,s6,3c24 <sharedfd+0x14e>
        np++;
    3c36:	2a85                	addiw	s5,s5,1
    3c38:	b7f5                	j	3c24 <sharedfd+0x14e>
  close(fd);
    3c3a:	855e                	mv	a0,s7
    3c3c:	00002097          	auipc	ra,0x2
    3c40:	c40080e7          	jalr	-960(ra) # 587c <close>
  unlink("sharedfd");
    3c44:	00004517          	auipc	a0,0x4
    3c48:	db450513          	addi	a0,a0,-588 # 79f8 <malloc+0x1d36>
    3c4c:	00002097          	auipc	ra,0x2
    3c50:	c58080e7          	jalr	-936(ra) # 58a4 <unlink>
  if(nc == N*SZ && np == N*SZ){
    3c54:	6789                	lui	a5,0x2
    3c56:	71078793          	addi	a5,a5,1808 # 2710 <subdir+0x3be>
    3c5a:	00f99763          	bne	s3,a5,3c68 <sharedfd+0x192>
    3c5e:	6789                	lui	a5,0x2
    3c60:	71078793          	addi	a5,a5,1808 # 2710 <subdir+0x3be>
    3c64:	02fa8063          	beq	s5,a5,3c84 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    3c68:	85d2                	mv	a1,s4
    3c6a:	00004517          	auipc	a0,0x4
    3c6e:	e0e50513          	addi	a0,a0,-498 # 7a78 <malloc+0x1db6>
    3c72:	00002097          	auipc	ra,0x2
    3c76:	f92080e7          	jalr	-110(ra) # 5c04 <printf>
    exit(1);
    3c7a:	4505                	li	a0,1
    3c7c:	00002097          	auipc	ra,0x2
    3c80:	bd8080e7          	jalr	-1064(ra) # 5854 <exit>
    exit(0);
    3c84:	4501                	li	a0,0
    3c86:	00002097          	auipc	ra,0x2
    3c8a:	bce080e7          	jalr	-1074(ra) # 5854 <exit>

0000000000003c8e <createdelete>:
{
    3c8e:	7175                	addi	sp,sp,-144
    3c90:	e506                	sd	ra,136(sp)
    3c92:	e122                	sd	s0,128(sp)
    3c94:	fca6                	sd	s1,120(sp)
    3c96:	f8ca                	sd	s2,112(sp)
    3c98:	f4ce                	sd	s3,104(sp)
    3c9a:	f0d2                	sd	s4,96(sp)
    3c9c:	ecd6                	sd	s5,88(sp)
    3c9e:	e8da                	sd	s6,80(sp)
    3ca0:	e4de                	sd	s7,72(sp)
    3ca2:	e0e2                	sd	s8,64(sp)
    3ca4:	fc66                	sd	s9,56(sp)
    3ca6:	0900                	addi	s0,sp,144
    3ca8:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    3caa:	4901                	li	s2,0
    3cac:	4991                	li	s3,4
    pid = fork();
    3cae:	00002097          	auipc	ra,0x2
    3cb2:	b9e080e7          	jalr	-1122(ra) # 584c <fork>
    3cb6:	84aa                	mv	s1,a0
    if(pid < 0){
    3cb8:	02054f63          	bltz	a0,3cf6 <createdelete+0x68>
    if(pid == 0){
    3cbc:	c939                	beqz	a0,3d12 <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    3cbe:	2905                	addiw	s2,s2,1
    3cc0:	ff3917e3          	bne	s2,s3,3cae <createdelete+0x20>
    3cc4:	4491                	li	s1,4
    wait(&xstatus);
    3cc6:	f7c40513          	addi	a0,s0,-132
    3cca:	00002097          	auipc	ra,0x2
    3cce:	b92080e7          	jalr	-1134(ra) # 585c <wait>
    if(xstatus != 0)
    3cd2:	f7c42903          	lw	s2,-132(s0)
    3cd6:	0e091263          	bnez	s2,3dba <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    3cda:	34fd                	addiw	s1,s1,-1
    3cdc:	f4ed                	bnez	s1,3cc6 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    3cde:	f8040123          	sb	zero,-126(s0)
    3ce2:	03000993          	li	s3,48
    3ce6:	5a7d                	li	s4,-1
    3ce8:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    3cec:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    3cee:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    3cf0:	07400a93          	li	s5,116
    3cf4:	a29d                	j	3e5a <createdelete+0x1cc>
      printf("fork failed\n", s);
    3cf6:	85e6                	mv	a1,s9
    3cf8:	00003517          	auipc	a0,0x3
    3cfc:	d3850513          	addi	a0,a0,-712 # 6a30 <malloc+0xd6e>
    3d00:	00002097          	auipc	ra,0x2
    3d04:	f04080e7          	jalr	-252(ra) # 5c04 <printf>
      exit(1);
    3d08:	4505                	li	a0,1
    3d0a:	00002097          	auipc	ra,0x2
    3d0e:	b4a080e7          	jalr	-1206(ra) # 5854 <exit>
      name[0] = 'p' + pi;
    3d12:	0709091b          	addiw	s2,s2,112
    3d16:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    3d1a:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    3d1e:	4951                	li	s2,20
    3d20:	a015                	j	3d44 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    3d22:	85e6                	mv	a1,s9
    3d24:	00003517          	auipc	a0,0x3
    3d28:	b6c50513          	addi	a0,a0,-1172 # 6890 <malloc+0xbce>
    3d2c:	00002097          	auipc	ra,0x2
    3d30:	ed8080e7          	jalr	-296(ra) # 5c04 <printf>
          exit(1);
    3d34:	4505                	li	a0,1
    3d36:	00002097          	auipc	ra,0x2
    3d3a:	b1e080e7          	jalr	-1250(ra) # 5854 <exit>
      for(i = 0; i < N; i++){
    3d3e:	2485                	addiw	s1,s1,1
    3d40:	07248863          	beq	s1,s2,3db0 <createdelete+0x122>
        name[1] = '0' + i;
    3d44:	0304879b          	addiw	a5,s1,48
    3d48:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    3d4c:	20200593          	li	a1,514
    3d50:	f8040513          	addi	a0,s0,-128
    3d54:	00002097          	auipc	ra,0x2
    3d58:	b40080e7          	jalr	-1216(ra) # 5894 <open>
        if(fd < 0){
    3d5c:	fc0543e3          	bltz	a0,3d22 <createdelete+0x94>
        close(fd);
    3d60:	00002097          	auipc	ra,0x2
    3d64:	b1c080e7          	jalr	-1252(ra) # 587c <close>
        if(i > 0 && (i % 2 ) == 0){
    3d68:	fc905be3          	blez	s1,3d3e <createdelete+0xb0>
    3d6c:	0014f793          	andi	a5,s1,1
    3d70:	f7f9                	bnez	a5,3d3e <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    3d72:	01f4d79b          	srliw	a5,s1,0x1f
    3d76:	9fa5                	addw	a5,a5,s1
    3d78:	4017d79b          	sraiw	a5,a5,0x1
    3d7c:	0307879b          	addiw	a5,a5,48
    3d80:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    3d84:	f8040513          	addi	a0,s0,-128
    3d88:	00002097          	auipc	ra,0x2
    3d8c:	b1c080e7          	jalr	-1252(ra) # 58a4 <unlink>
    3d90:	fa0557e3          	bgez	a0,3d3e <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    3d94:	85e6                	mv	a1,s9
    3d96:	00003517          	auipc	a0,0x3
    3d9a:	e0250513          	addi	a0,a0,-510 # 6b98 <malloc+0xed6>
    3d9e:	00002097          	auipc	ra,0x2
    3da2:	e66080e7          	jalr	-410(ra) # 5c04 <printf>
            exit(1);
    3da6:	4505                	li	a0,1
    3da8:	00002097          	auipc	ra,0x2
    3dac:	aac080e7          	jalr	-1364(ra) # 5854 <exit>
      exit(0);
    3db0:	4501                	li	a0,0
    3db2:	00002097          	auipc	ra,0x2
    3db6:	aa2080e7          	jalr	-1374(ra) # 5854 <exit>
      exit(1);
    3dba:	4505                	li	a0,1
    3dbc:	00002097          	auipc	ra,0x2
    3dc0:	a98080e7          	jalr	-1384(ra) # 5854 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    3dc4:	f8040613          	addi	a2,s0,-128
    3dc8:	85e6                	mv	a1,s9
    3dca:	00004517          	auipc	a0,0x4
    3dce:	cc650513          	addi	a0,a0,-826 # 7a90 <malloc+0x1dce>
    3dd2:	00002097          	auipc	ra,0x2
    3dd6:	e32080e7          	jalr	-462(ra) # 5c04 <printf>
        exit(1);
    3dda:	4505                	li	a0,1
    3ddc:	00002097          	auipc	ra,0x2
    3de0:	a78080e7          	jalr	-1416(ra) # 5854 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    3de4:	054b7163          	bgeu	s6,s4,3e26 <createdelete+0x198>
      if(fd >= 0)
    3de8:	02055a63          	bgez	a0,3e1c <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    3dec:	2485                	addiw	s1,s1,1
    3dee:	0ff4f493          	andi	s1,s1,255
    3df2:	05548c63          	beq	s1,s5,3e4a <createdelete+0x1bc>
      name[0] = 'p' + pi;
    3df6:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    3dfa:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    3dfe:	4581                	li	a1,0
    3e00:	f8040513          	addi	a0,s0,-128
    3e04:	00002097          	auipc	ra,0x2
    3e08:	a90080e7          	jalr	-1392(ra) # 5894 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    3e0c:	00090463          	beqz	s2,3e14 <createdelete+0x186>
    3e10:	fd2bdae3          	bge	s7,s2,3de4 <createdelete+0x156>
    3e14:	fa0548e3          	bltz	a0,3dc4 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    3e18:	014b7963          	bgeu	s6,s4,3e2a <createdelete+0x19c>
        close(fd);
    3e1c:	00002097          	auipc	ra,0x2
    3e20:	a60080e7          	jalr	-1440(ra) # 587c <close>
    3e24:	b7e1                	j	3dec <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    3e26:	fc0543e3          	bltz	a0,3dec <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    3e2a:	f8040613          	addi	a2,s0,-128
    3e2e:	85e6                	mv	a1,s9
    3e30:	00004517          	auipc	a0,0x4
    3e34:	c8850513          	addi	a0,a0,-888 # 7ab8 <malloc+0x1df6>
    3e38:	00002097          	auipc	ra,0x2
    3e3c:	dcc080e7          	jalr	-564(ra) # 5c04 <printf>
        exit(1);
    3e40:	4505                	li	a0,1
    3e42:	00002097          	auipc	ra,0x2
    3e46:	a12080e7          	jalr	-1518(ra) # 5854 <exit>
  for(i = 0; i < N; i++){
    3e4a:	2905                	addiw	s2,s2,1
    3e4c:	2a05                	addiw	s4,s4,1
    3e4e:	2985                	addiw	s3,s3,1
    3e50:	0ff9f993          	andi	s3,s3,255
    3e54:	47d1                	li	a5,20
    3e56:	02f90a63          	beq	s2,a5,3e8a <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    3e5a:	84e2                	mv	s1,s8
    3e5c:	bf69                	j	3df6 <createdelete+0x168>
  for(i = 0; i < N; i++){
    3e5e:	2905                	addiw	s2,s2,1
    3e60:	0ff97913          	andi	s2,s2,255
    3e64:	2985                	addiw	s3,s3,1
    3e66:	0ff9f993          	andi	s3,s3,255
    3e6a:	03490863          	beq	s2,s4,3e9a <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    3e6e:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    3e70:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    3e74:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    3e78:	f8040513          	addi	a0,s0,-128
    3e7c:	00002097          	auipc	ra,0x2
    3e80:	a28080e7          	jalr	-1496(ra) # 58a4 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    3e84:	34fd                	addiw	s1,s1,-1
    3e86:	f4ed                	bnez	s1,3e70 <createdelete+0x1e2>
    3e88:	bfd9                	j	3e5e <createdelete+0x1d0>
    3e8a:	03000993          	li	s3,48
    3e8e:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    3e92:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    3e94:	08400a13          	li	s4,132
    3e98:	bfd9                	j	3e6e <createdelete+0x1e0>
}
    3e9a:	60aa                	ld	ra,136(sp)
    3e9c:	640a                	ld	s0,128(sp)
    3e9e:	74e6                	ld	s1,120(sp)
    3ea0:	7946                	ld	s2,112(sp)
    3ea2:	79a6                	ld	s3,104(sp)
    3ea4:	7a06                	ld	s4,96(sp)
    3ea6:	6ae6                	ld	s5,88(sp)
    3ea8:	6b46                	ld	s6,80(sp)
    3eaa:	6ba6                	ld	s7,72(sp)
    3eac:	6c06                	ld	s8,64(sp)
    3eae:	7ce2                	ld	s9,56(sp)
    3eb0:	6149                	addi	sp,sp,144
    3eb2:	8082                	ret

0000000000003eb4 <concreate>:
{
    3eb4:	7135                	addi	sp,sp,-160
    3eb6:	ed06                	sd	ra,152(sp)
    3eb8:	e922                	sd	s0,144(sp)
    3eba:	e526                	sd	s1,136(sp)
    3ebc:	e14a                	sd	s2,128(sp)
    3ebe:	fcce                	sd	s3,120(sp)
    3ec0:	f8d2                	sd	s4,112(sp)
    3ec2:	f4d6                	sd	s5,104(sp)
    3ec4:	f0da                	sd	s6,96(sp)
    3ec6:	ecde                	sd	s7,88(sp)
    3ec8:	1100                	addi	s0,sp,160
    3eca:	89aa                	mv	s3,a0
  file[0] = 'C';
    3ecc:	04300793          	li	a5,67
    3ed0:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    3ed4:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    3ed8:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    3eda:	4b0d                	li	s6,3
    3edc:	4a85                	li	s5,1
      link("C0", file);
    3ede:	00004b97          	auipc	s7,0x4
    3ee2:	c02b8b93          	addi	s7,s7,-1022 # 7ae0 <malloc+0x1e1e>
  for(i = 0; i < N; i++){
    3ee6:	02800a13          	li	s4,40
    3eea:	acc1                	j	41ba <concreate+0x306>
      link("C0", file);
    3eec:	fa840593          	addi	a1,s0,-88
    3ef0:	855e                	mv	a0,s7
    3ef2:	00002097          	auipc	ra,0x2
    3ef6:	9c2080e7          	jalr	-1598(ra) # 58b4 <link>
    if(pid == 0) {
    3efa:	a45d                	j	41a0 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    3efc:	4795                	li	a5,5
    3efe:	02f9693b          	remw	s2,s2,a5
    3f02:	4785                	li	a5,1
    3f04:	02f90b63          	beq	s2,a5,3f3a <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    3f08:	20200593          	li	a1,514
    3f0c:	fa840513          	addi	a0,s0,-88
    3f10:	00002097          	auipc	ra,0x2
    3f14:	984080e7          	jalr	-1660(ra) # 5894 <open>
      if(fd < 0){
    3f18:	26055b63          	bgez	a0,418e <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    3f1c:	fa840593          	addi	a1,s0,-88
    3f20:	00004517          	auipc	a0,0x4
    3f24:	bc850513          	addi	a0,a0,-1080 # 7ae8 <malloc+0x1e26>
    3f28:	00002097          	auipc	ra,0x2
    3f2c:	cdc080e7          	jalr	-804(ra) # 5c04 <printf>
        exit(1);
    3f30:	4505                	li	a0,1
    3f32:	00002097          	auipc	ra,0x2
    3f36:	922080e7          	jalr	-1758(ra) # 5854 <exit>
      link("C0", file);
    3f3a:	fa840593          	addi	a1,s0,-88
    3f3e:	00004517          	auipc	a0,0x4
    3f42:	ba250513          	addi	a0,a0,-1118 # 7ae0 <malloc+0x1e1e>
    3f46:	00002097          	auipc	ra,0x2
    3f4a:	96e080e7          	jalr	-1682(ra) # 58b4 <link>
      exit(0);
    3f4e:	4501                	li	a0,0
    3f50:	00002097          	auipc	ra,0x2
    3f54:	904080e7          	jalr	-1788(ra) # 5854 <exit>
        exit(1);
    3f58:	4505                	li	a0,1
    3f5a:	00002097          	auipc	ra,0x2
    3f5e:	8fa080e7          	jalr	-1798(ra) # 5854 <exit>
  memset(fa, 0, sizeof(fa));
    3f62:	02800613          	li	a2,40
    3f66:	4581                	li	a1,0
    3f68:	f8040513          	addi	a0,s0,-128
    3f6c:	00001097          	auipc	ra,0x1
    3f70:	6ec080e7          	jalr	1772(ra) # 5658 <memset>
  fd = open(".", 0);
    3f74:	4581                	li	a1,0
    3f76:	00002517          	auipc	a0,0x2
    3f7a:	7d250513          	addi	a0,a0,2002 # 6748 <malloc+0xa86>
    3f7e:	00002097          	auipc	ra,0x2
    3f82:	916080e7          	jalr	-1770(ra) # 5894 <open>
    3f86:	892a                	mv	s2,a0
  n = 0;
    3f88:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    3f8a:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    3f8e:	02700b13          	li	s6,39
      fa[i] = 1;
    3f92:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    3f94:	4641                	li	a2,16
    3f96:	f7040593          	addi	a1,s0,-144
    3f9a:	854a                	mv	a0,s2
    3f9c:	00002097          	auipc	ra,0x2
    3fa0:	8d0080e7          	jalr	-1840(ra) # 586c <read>
    3fa4:	08a05163          	blez	a0,4026 <concreate+0x172>
    if(de.inum == 0)
    3fa8:	f7045783          	lhu	a5,-144(s0)
    3fac:	d7e5                	beqz	a5,3f94 <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    3fae:	f7244783          	lbu	a5,-142(s0)
    3fb2:	ff4791e3          	bne	a5,s4,3f94 <concreate+0xe0>
    3fb6:	f7444783          	lbu	a5,-140(s0)
    3fba:	ffe9                	bnez	a5,3f94 <concreate+0xe0>
      i = de.name[1] - '0';
    3fbc:	f7344783          	lbu	a5,-141(s0)
    3fc0:	fd07879b          	addiw	a5,a5,-48
    3fc4:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    3fc8:	00eb6f63          	bltu	s6,a4,3fe6 <concreate+0x132>
      if(fa[i]){
    3fcc:	fb040793          	addi	a5,s0,-80
    3fd0:	97ba                	add	a5,a5,a4
    3fd2:	fd07c783          	lbu	a5,-48(a5)
    3fd6:	eb85                	bnez	a5,4006 <concreate+0x152>
      fa[i] = 1;
    3fd8:	fb040793          	addi	a5,s0,-80
    3fdc:	973e                	add	a4,a4,a5
    3fde:	fd770823          	sb	s7,-48(a4)
      n++;
    3fe2:	2a85                	addiw	s5,s5,1
    3fe4:	bf45                	j	3f94 <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    3fe6:	f7240613          	addi	a2,s0,-142
    3fea:	85ce                	mv	a1,s3
    3fec:	00004517          	auipc	a0,0x4
    3ff0:	b1c50513          	addi	a0,a0,-1252 # 7b08 <malloc+0x1e46>
    3ff4:	00002097          	auipc	ra,0x2
    3ff8:	c10080e7          	jalr	-1008(ra) # 5c04 <printf>
        exit(1);
    3ffc:	4505                	li	a0,1
    3ffe:	00002097          	auipc	ra,0x2
    4002:	856080e7          	jalr	-1962(ra) # 5854 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    4006:	f7240613          	addi	a2,s0,-142
    400a:	85ce                	mv	a1,s3
    400c:	00004517          	auipc	a0,0x4
    4010:	b1c50513          	addi	a0,a0,-1252 # 7b28 <malloc+0x1e66>
    4014:	00002097          	auipc	ra,0x2
    4018:	bf0080e7          	jalr	-1040(ra) # 5c04 <printf>
        exit(1);
    401c:	4505                	li	a0,1
    401e:	00002097          	auipc	ra,0x2
    4022:	836080e7          	jalr	-1994(ra) # 5854 <exit>
  close(fd);
    4026:	854a                	mv	a0,s2
    4028:	00002097          	auipc	ra,0x2
    402c:	854080e7          	jalr	-1964(ra) # 587c <close>
  if(n != N){
    4030:	02800793          	li	a5,40
    4034:	00fa9763          	bne	s5,a5,4042 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    4038:	4a8d                	li	s5,3
    403a:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    403c:	02800a13          	li	s4,40
    4040:	a8c9                	j	4112 <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    4042:	85ce                	mv	a1,s3
    4044:	00004517          	auipc	a0,0x4
    4048:	b0c50513          	addi	a0,a0,-1268 # 7b50 <malloc+0x1e8e>
    404c:	00002097          	auipc	ra,0x2
    4050:	bb8080e7          	jalr	-1096(ra) # 5c04 <printf>
    exit(1);
    4054:	4505                	li	a0,1
    4056:	00001097          	auipc	ra,0x1
    405a:	7fe080e7          	jalr	2046(ra) # 5854 <exit>
      printf("%s: fork failed\n", s);
    405e:	85ce                	mv	a1,s3
    4060:	00002517          	auipc	a0,0x2
    4064:	fd850513          	addi	a0,a0,-40 # 6038 <malloc+0x376>
    4068:	00002097          	auipc	ra,0x2
    406c:	b9c080e7          	jalr	-1124(ra) # 5c04 <printf>
      exit(1);
    4070:	4505                	li	a0,1
    4072:	00001097          	auipc	ra,0x1
    4076:	7e2080e7          	jalr	2018(ra) # 5854 <exit>
      close(open(file, 0));
    407a:	4581                	li	a1,0
    407c:	fa840513          	addi	a0,s0,-88
    4080:	00002097          	auipc	ra,0x2
    4084:	814080e7          	jalr	-2028(ra) # 5894 <open>
    4088:	00001097          	auipc	ra,0x1
    408c:	7f4080e7          	jalr	2036(ra) # 587c <close>
      close(open(file, 0));
    4090:	4581                	li	a1,0
    4092:	fa840513          	addi	a0,s0,-88
    4096:	00001097          	auipc	ra,0x1
    409a:	7fe080e7          	jalr	2046(ra) # 5894 <open>
    409e:	00001097          	auipc	ra,0x1
    40a2:	7de080e7          	jalr	2014(ra) # 587c <close>
      close(open(file, 0));
    40a6:	4581                	li	a1,0
    40a8:	fa840513          	addi	a0,s0,-88
    40ac:	00001097          	auipc	ra,0x1
    40b0:	7e8080e7          	jalr	2024(ra) # 5894 <open>
    40b4:	00001097          	auipc	ra,0x1
    40b8:	7c8080e7          	jalr	1992(ra) # 587c <close>
      close(open(file, 0));
    40bc:	4581                	li	a1,0
    40be:	fa840513          	addi	a0,s0,-88
    40c2:	00001097          	auipc	ra,0x1
    40c6:	7d2080e7          	jalr	2002(ra) # 5894 <open>
    40ca:	00001097          	auipc	ra,0x1
    40ce:	7b2080e7          	jalr	1970(ra) # 587c <close>
      close(open(file, 0));
    40d2:	4581                	li	a1,0
    40d4:	fa840513          	addi	a0,s0,-88
    40d8:	00001097          	auipc	ra,0x1
    40dc:	7bc080e7          	jalr	1980(ra) # 5894 <open>
    40e0:	00001097          	auipc	ra,0x1
    40e4:	79c080e7          	jalr	1948(ra) # 587c <close>
      close(open(file, 0));
    40e8:	4581                	li	a1,0
    40ea:	fa840513          	addi	a0,s0,-88
    40ee:	00001097          	auipc	ra,0x1
    40f2:	7a6080e7          	jalr	1958(ra) # 5894 <open>
    40f6:	00001097          	auipc	ra,0x1
    40fa:	786080e7          	jalr	1926(ra) # 587c <close>
    if(pid == 0)
    40fe:	08090363          	beqz	s2,4184 <concreate+0x2d0>
      wait(0);
    4102:	4501                	li	a0,0
    4104:	00001097          	auipc	ra,0x1
    4108:	758080e7          	jalr	1880(ra) # 585c <wait>
  for(i = 0; i < N; i++){
    410c:	2485                	addiw	s1,s1,1
    410e:	0f448563          	beq	s1,s4,41f8 <concreate+0x344>
    file[1] = '0' + i;
    4112:	0304879b          	addiw	a5,s1,48
    4116:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    411a:	00001097          	auipc	ra,0x1
    411e:	732080e7          	jalr	1842(ra) # 584c <fork>
    4122:	892a                	mv	s2,a0
    if(pid < 0){
    4124:	f2054de3          	bltz	a0,405e <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    4128:	0354e73b          	remw	a4,s1,s5
    412c:	00a767b3          	or	a5,a4,a0
    4130:	2781                	sext.w	a5,a5
    4132:	d7a1                	beqz	a5,407a <concreate+0x1c6>
    4134:	01671363          	bne	a4,s6,413a <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    4138:	f129                	bnez	a0,407a <concreate+0x1c6>
      unlink(file);
    413a:	fa840513          	addi	a0,s0,-88
    413e:	00001097          	auipc	ra,0x1
    4142:	766080e7          	jalr	1894(ra) # 58a4 <unlink>
      unlink(file);
    4146:	fa840513          	addi	a0,s0,-88
    414a:	00001097          	auipc	ra,0x1
    414e:	75a080e7          	jalr	1882(ra) # 58a4 <unlink>
      unlink(file);
    4152:	fa840513          	addi	a0,s0,-88
    4156:	00001097          	auipc	ra,0x1
    415a:	74e080e7          	jalr	1870(ra) # 58a4 <unlink>
      unlink(file);
    415e:	fa840513          	addi	a0,s0,-88
    4162:	00001097          	auipc	ra,0x1
    4166:	742080e7          	jalr	1858(ra) # 58a4 <unlink>
      unlink(file);
    416a:	fa840513          	addi	a0,s0,-88
    416e:	00001097          	auipc	ra,0x1
    4172:	736080e7          	jalr	1846(ra) # 58a4 <unlink>
      unlink(file);
    4176:	fa840513          	addi	a0,s0,-88
    417a:	00001097          	auipc	ra,0x1
    417e:	72a080e7          	jalr	1834(ra) # 58a4 <unlink>
    4182:	bfb5                	j	40fe <concreate+0x24a>
      exit(0);
    4184:	4501                	li	a0,0
    4186:	00001097          	auipc	ra,0x1
    418a:	6ce080e7          	jalr	1742(ra) # 5854 <exit>
      close(fd);
    418e:	00001097          	auipc	ra,0x1
    4192:	6ee080e7          	jalr	1774(ra) # 587c <close>
    if(pid == 0) {
    4196:	bb65                	j	3f4e <concreate+0x9a>
      close(fd);
    4198:	00001097          	auipc	ra,0x1
    419c:	6e4080e7          	jalr	1764(ra) # 587c <close>
      wait(&xstatus);
    41a0:	f6c40513          	addi	a0,s0,-148
    41a4:	00001097          	auipc	ra,0x1
    41a8:	6b8080e7          	jalr	1720(ra) # 585c <wait>
      if(xstatus != 0)
    41ac:	f6c42483          	lw	s1,-148(s0)
    41b0:	da0494e3          	bnez	s1,3f58 <concreate+0xa4>
  for(i = 0; i < N; i++){
    41b4:	2905                	addiw	s2,s2,1
    41b6:	db4906e3          	beq	s2,s4,3f62 <concreate+0xae>
    file[1] = '0' + i;
    41ba:	0309079b          	addiw	a5,s2,48
    41be:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    41c2:	fa840513          	addi	a0,s0,-88
    41c6:	00001097          	auipc	ra,0x1
    41ca:	6de080e7          	jalr	1758(ra) # 58a4 <unlink>
    pid = fork();
    41ce:	00001097          	auipc	ra,0x1
    41d2:	67e080e7          	jalr	1662(ra) # 584c <fork>
    if(pid && (i % 3) == 1){
    41d6:	d20503e3          	beqz	a0,3efc <concreate+0x48>
    41da:	036967bb          	remw	a5,s2,s6
    41de:	d15787e3          	beq	a5,s5,3eec <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    41e2:	20200593          	li	a1,514
    41e6:	fa840513          	addi	a0,s0,-88
    41ea:	00001097          	auipc	ra,0x1
    41ee:	6aa080e7          	jalr	1706(ra) # 5894 <open>
      if(fd < 0){
    41f2:	fa0553e3          	bgez	a0,4198 <concreate+0x2e4>
    41f6:	b31d                	j	3f1c <concreate+0x68>
}
    41f8:	60ea                	ld	ra,152(sp)
    41fa:	644a                	ld	s0,144(sp)
    41fc:	64aa                	ld	s1,136(sp)
    41fe:	690a                	ld	s2,128(sp)
    4200:	79e6                	ld	s3,120(sp)
    4202:	7a46                	ld	s4,112(sp)
    4204:	7aa6                	ld	s5,104(sp)
    4206:	7b06                	ld	s6,96(sp)
    4208:	6be6                	ld	s7,88(sp)
    420a:	610d                	addi	sp,sp,160
    420c:	8082                	ret

000000000000420e <linkunlink>:
{
    420e:	711d                	addi	sp,sp,-96
    4210:	ec86                	sd	ra,88(sp)
    4212:	e8a2                	sd	s0,80(sp)
    4214:	e4a6                	sd	s1,72(sp)
    4216:	e0ca                	sd	s2,64(sp)
    4218:	fc4e                	sd	s3,56(sp)
    421a:	f852                	sd	s4,48(sp)
    421c:	f456                	sd	s5,40(sp)
    421e:	f05a                	sd	s6,32(sp)
    4220:	ec5e                	sd	s7,24(sp)
    4222:	e862                	sd	s8,16(sp)
    4224:	e466                	sd	s9,8(sp)
    4226:	1080                	addi	s0,sp,96
    4228:	84aa                	mv	s1,a0
  unlink("x");
    422a:	00002517          	auipc	a0,0x2
    422e:	ff650513          	addi	a0,a0,-10 # 6220 <malloc+0x55e>
    4232:	00001097          	auipc	ra,0x1
    4236:	672080e7          	jalr	1650(ra) # 58a4 <unlink>
  pid = fork();
    423a:	00001097          	auipc	ra,0x1
    423e:	612080e7          	jalr	1554(ra) # 584c <fork>
  if(pid < 0){
    4242:	02054b63          	bltz	a0,4278 <linkunlink+0x6a>
    4246:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    4248:	4c85                	li	s9,1
    424a:	e119                	bnez	a0,4250 <linkunlink+0x42>
    424c:	06100c93          	li	s9,97
    4250:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    4254:	41c659b7          	lui	s3,0x41c65
    4258:	e6d9899b          	addiw	s3,s3,-403
    425c:	690d                	lui	s2,0x3
    425e:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    4262:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    4264:	4b05                	li	s6,1
      unlink("x");
    4266:	00002a97          	auipc	s5,0x2
    426a:	fbaa8a93          	addi	s5,s5,-70 # 6220 <malloc+0x55e>
      link("cat", "x");
    426e:	00004b97          	auipc	s7,0x4
    4272:	91ab8b93          	addi	s7,s7,-1766 # 7b88 <malloc+0x1ec6>
    4276:	a825                	j	42ae <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    4278:	85a6                	mv	a1,s1
    427a:	00002517          	auipc	a0,0x2
    427e:	dbe50513          	addi	a0,a0,-578 # 6038 <malloc+0x376>
    4282:	00002097          	auipc	ra,0x2
    4286:	982080e7          	jalr	-1662(ra) # 5c04 <printf>
    exit(1);
    428a:	4505                	li	a0,1
    428c:	00001097          	auipc	ra,0x1
    4290:	5c8080e7          	jalr	1480(ra) # 5854 <exit>
      close(open("x", O_RDWR | O_CREATE));
    4294:	20200593          	li	a1,514
    4298:	8556                	mv	a0,s5
    429a:	00001097          	auipc	ra,0x1
    429e:	5fa080e7          	jalr	1530(ra) # 5894 <open>
    42a2:	00001097          	auipc	ra,0x1
    42a6:	5da080e7          	jalr	1498(ra) # 587c <close>
  for(i = 0; i < 100; i++){
    42aa:	34fd                	addiw	s1,s1,-1
    42ac:	c88d                	beqz	s1,42de <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    42ae:	033c87bb          	mulw	a5,s9,s3
    42b2:	012787bb          	addw	a5,a5,s2
    42b6:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    42ba:	0347f7bb          	remuw	a5,a5,s4
    42be:	dbf9                	beqz	a5,4294 <linkunlink+0x86>
    } else if((x % 3) == 1){
    42c0:	01678863          	beq	a5,s6,42d0 <linkunlink+0xc2>
      unlink("x");
    42c4:	8556                	mv	a0,s5
    42c6:	00001097          	auipc	ra,0x1
    42ca:	5de080e7          	jalr	1502(ra) # 58a4 <unlink>
    42ce:	bff1                	j	42aa <linkunlink+0x9c>
      link("cat", "x");
    42d0:	85d6                	mv	a1,s5
    42d2:	855e                	mv	a0,s7
    42d4:	00001097          	auipc	ra,0x1
    42d8:	5e0080e7          	jalr	1504(ra) # 58b4 <link>
    42dc:	b7f9                	j	42aa <linkunlink+0x9c>
  if(pid)
    42de:	020c0463          	beqz	s8,4306 <linkunlink+0xf8>
    wait(0);
    42e2:	4501                	li	a0,0
    42e4:	00001097          	auipc	ra,0x1
    42e8:	578080e7          	jalr	1400(ra) # 585c <wait>
}
    42ec:	60e6                	ld	ra,88(sp)
    42ee:	6446                	ld	s0,80(sp)
    42f0:	64a6                	ld	s1,72(sp)
    42f2:	6906                	ld	s2,64(sp)
    42f4:	79e2                	ld	s3,56(sp)
    42f6:	7a42                	ld	s4,48(sp)
    42f8:	7aa2                	ld	s5,40(sp)
    42fa:	7b02                	ld	s6,32(sp)
    42fc:	6be2                	ld	s7,24(sp)
    42fe:	6c42                	ld	s8,16(sp)
    4300:	6ca2                	ld	s9,8(sp)
    4302:	6125                	addi	sp,sp,96
    4304:	8082                	ret
    exit(0);
    4306:	4501                	li	a0,0
    4308:	00001097          	auipc	ra,0x1
    430c:	54c080e7          	jalr	1356(ra) # 5854 <exit>

0000000000004310 <bigdir>:
{
    4310:	715d                	addi	sp,sp,-80
    4312:	e486                	sd	ra,72(sp)
    4314:	e0a2                	sd	s0,64(sp)
    4316:	fc26                	sd	s1,56(sp)
    4318:	f84a                	sd	s2,48(sp)
    431a:	f44e                	sd	s3,40(sp)
    431c:	f052                	sd	s4,32(sp)
    431e:	ec56                	sd	s5,24(sp)
    4320:	e85a                	sd	s6,16(sp)
    4322:	0880                	addi	s0,sp,80
    4324:	89aa                	mv	s3,a0
  unlink("bd");
    4326:	00004517          	auipc	a0,0x4
    432a:	86a50513          	addi	a0,a0,-1942 # 7b90 <malloc+0x1ece>
    432e:	00001097          	auipc	ra,0x1
    4332:	576080e7          	jalr	1398(ra) # 58a4 <unlink>
  fd = open("bd", O_CREATE);
    4336:	20000593          	li	a1,512
    433a:	00004517          	auipc	a0,0x4
    433e:	85650513          	addi	a0,a0,-1962 # 7b90 <malloc+0x1ece>
    4342:	00001097          	auipc	ra,0x1
    4346:	552080e7          	jalr	1362(ra) # 5894 <open>
  if(fd < 0){
    434a:	0c054963          	bltz	a0,441c <bigdir+0x10c>
  close(fd);
    434e:	00001097          	auipc	ra,0x1
    4352:	52e080e7          	jalr	1326(ra) # 587c <close>
  for(i = 0; i < N; i++){
    4356:	4901                	li	s2,0
    name[0] = 'x';
    4358:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
    435c:	00004a17          	auipc	s4,0x4
    4360:	834a0a13          	addi	s4,s4,-1996 # 7b90 <malloc+0x1ece>
  for(i = 0; i < N; i++){
    4364:	1f400b13          	li	s6,500
    name[0] = 'x';
    4368:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
    436c:	41f9579b          	sraiw	a5,s2,0x1f
    4370:	01a7d71b          	srliw	a4,a5,0x1a
    4374:	012707bb          	addw	a5,a4,s2
    4378:	4067d69b          	sraiw	a3,a5,0x6
    437c:	0306869b          	addiw	a3,a3,48
    4380:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    4384:	03f7f793          	andi	a5,a5,63
    4388:	9f99                	subw	a5,a5,a4
    438a:	0307879b          	addiw	a5,a5,48
    438e:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    4392:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    4396:	fb040593          	addi	a1,s0,-80
    439a:	8552                	mv	a0,s4
    439c:	00001097          	auipc	ra,0x1
    43a0:	518080e7          	jalr	1304(ra) # 58b4 <link>
    43a4:	84aa                	mv	s1,a0
    43a6:	e949                	bnez	a0,4438 <bigdir+0x128>
  for(i = 0; i < N; i++){
    43a8:	2905                	addiw	s2,s2,1
    43aa:	fb691fe3          	bne	s2,s6,4368 <bigdir+0x58>
  unlink("bd");
    43ae:	00003517          	auipc	a0,0x3
    43b2:	7e250513          	addi	a0,a0,2018 # 7b90 <malloc+0x1ece>
    43b6:	00001097          	auipc	ra,0x1
    43ba:	4ee080e7          	jalr	1262(ra) # 58a4 <unlink>
    name[0] = 'x';
    43be:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    43c2:	1f400a13          	li	s4,500
    name[0] = 'x';
    43c6:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    43ca:	41f4d79b          	sraiw	a5,s1,0x1f
    43ce:	01a7d71b          	srliw	a4,a5,0x1a
    43d2:	009707bb          	addw	a5,a4,s1
    43d6:	4067d69b          	sraiw	a3,a5,0x6
    43da:	0306869b          	addiw	a3,a3,48
    43de:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    43e2:	03f7f793          	andi	a5,a5,63
    43e6:	9f99                	subw	a5,a5,a4
    43e8:	0307879b          	addiw	a5,a5,48
    43ec:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    43f0:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    43f4:	fb040513          	addi	a0,s0,-80
    43f8:	00001097          	auipc	ra,0x1
    43fc:	4ac080e7          	jalr	1196(ra) # 58a4 <unlink>
    4400:	ed21                	bnez	a0,4458 <bigdir+0x148>
  for(i = 0; i < N; i++){
    4402:	2485                	addiw	s1,s1,1
    4404:	fd4491e3          	bne	s1,s4,43c6 <bigdir+0xb6>
}
    4408:	60a6                	ld	ra,72(sp)
    440a:	6406                	ld	s0,64(sp)
    440c:	74e2                	ld	s1,56(sp)
    440e:	7942                	ld	s2,48(sp)
    4410:	79a2                	ld	s3,40(sp)
    4412:	7a02                	ld	s4,32(sp)
    4414:	6ae2                	ld	s5,24(sp)
    4416:	6b42                	ld	s6,16(sp)
    4418:	6161                	addi	sp,sp,80
    441a:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    441c:	85ce                	mv	a1,s3
    441e:	00003517          	auipc	a0,0x3
    4422:	77a50513          	addi	a0,a0,1914 # 7b98 <malloc+0x1ed6>
    4426:	00001097          	auipc	ra,0x1
    442a:	7de080e7          	jalr	2014(ra) # 5c04 <printf>
    exit(1);
    442e:	4505                	li	a0,1
    4430:	00001097          	auipc	ra,0x1
    4434:	424080e7          	jalr	1060(ra) # 5854 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    4438:	fb040613          	addi	a2,s0,-80
    443c:	85ce                	mv	a1,s3
    443e:	00003517          	auipc	a0,0x3
    4442:	77a50513          	addi	a0,a0,1914 # 7bb8 <malloc+0x1ef6>
    4446:	00001097          	auipc	ra,0x1
    444a:	7be080e7          	jalr	1982(ra) # 5c04 <printf>
      exit(1);
    444e:	4505                	li	a0,1
    4450:	00001097          	auipc	ra,0x1
    4454:	404080e7          	jalr	1028(ra) # 5854 <exit>
      printf("%s: bigdir unlink failed", s);
    4458:	85ce                	mv	a1,s3
    445a:	00003517          	auipc	a0,0x3
    445e:	77e50513          	addi	a0,a0,1918 # 7bd8 <malloc+0x1f16>
    4462:	00001097          	auipc	ra,0x1
    4466:	7a2080e7          	jalr	1954(ra) # 5c04 <printf>
      exit(1);
    446a:	4505                	li	a0,1
    446c:	00001097          	auipc	ra,0x1
    4470:	3e8080e7          	jalr	1000(ra) # 5854 <exit>

0000000000004474 <manywrites>:
{
    4474:	711d                	addi	sp,sp,-96
    4476:	ec86                	sd	ra,88(sp)
    4478:	e8a2                	sd	s0,80(sp)
    447a:	e4a6                	sd	s1,72(sp)
    447c:	e0ca                	sd	s2,64(sp)
    447e:	fc4e                	sd	s3,56(sp)
    4480:	f852                	sd	s4,48(sp)
    4482:	f456                	sd	s5,40(sp)
    4484:	f05a                	sd	s6,32(sp)
    4486:	ec5e                	sd	s7,24(sp)
    4488:	1080                	addi	s0,sp,96
    448a:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    448c:	4981                	li	s3,0
    448e:	4911                	li	s2,4
    int pid = fork();
    4490:	00001097          	auipc	ra,0x1
    4494:	3bc080e7          	jalr	956(ra) # 584c <fork>
    4498:	84aa                	mv	s1,a0
    if(pid < 0){
    449a:	02054963          	bltz	a0,44cc <manywrites+0x58>
    if(pid == 0){
    449e:	c521                	beqz	a0,44e6 <manywrites+0x72>
  for(int ci = 0; ci < nchildren; ci++){
    44a0:	2985                	addiw	s3,s3,1
    44a2:	ff2997e3          	bne	s3,s2,4490 <manywrites+0x1c>
    44a6:	4491                	li	s1,4
    int st = 0;
    44a8:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    44ac:	fa840513          	addi	a0,s0,-88
    44b0:	00001097          	auipc	ra,0x1
    44b4:	3ac080e7          	jalr	940(ra) # 585c <wait>
    if(st != 0)
    44b8:	fa842503          	lw	a0,-88(s0)
    44bc:	ed6d                	bnez	a0,45b6 <manywrites+0x142>
  for(int ci = 0; ci < nchildren; ci++){
    44be:	34fd                	addiw	s1,s1,-1
    44c0:	f4e5                	bnez	s1,44a8 <manywrites+0x34>
  exit(0);
    44c2:	4501                	li	a0,0
    44c4:	00001097          	auipc	ra,0x1
    44c8:	390080e7          	jalr	912(ra) # 5854 <exit>
      printf("fork failed\n");
    44cc:	00002517          	auipc	a0,0x2
    44d0:	56450513          	addi	a0,a0,1380 # 6a30 <malloc+0xd6e>
    44d4:	00001097          	auipc	ra,0x1
    44d8:	730080e7          	jalr	1840(ra) # 5c04 <printf>
      exit(1);
    44dc:	4505                	li	a0,1
    44de:	00001097          	auipc	ra,0x1
    44e2:	376080e7          	jalr	886(ra) # 5854 <exit>
      name[0] = 'b';
    44e6:	06200793          	li	a5,98
    44ea:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    44ee:	0619879b          	addiw	a5,s3,97
    44f2:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    44f6:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    44fa:	fa840513          	addi	a0,s0,-88
    44fe:	00001097          	auipc	ra,0x1
    4502:	3a6080e7          	jalr	934(ra) # 58a4 <unlink>
    4506:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    4508:	00007b17          	auipc	s6,0x7
    450c:	6e8b0b13          	addi	s6,s6,1768 # bbf0 <buf>
        for(int i = 0; i < ci+1; i++){
    4510:	8a26                	mv	s4,s1
    4512:	0209ce63          	bltz	s3,454e <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    4516:	20200593          	li	a1,514
    451a:	fa840513          	addi	a0,s0,-88
    451e:	00001097          	auipc	ra,0x1
    4522:	376080e7          	jalr	886(ra) # 5894 <open>
    4526:	892a                	mv	s2,a0
          if(fd < 0){
    4528:	04054763          	bltz	a0,4576 <manywrites+0x102>
          int cc = write(fd, buf, sz);
    452c:	660d                	lui	a2,0x3
    452e:	85da                	mv	a1,s6
    4530:	00001097          	auipc	ra,0x1
    4534:	344080e7          	jalr	836(ra) # 5874 <write>
          if(cc != sz){
    4538:	678d                	lui	a5,0x3
    453a:	04f51e63          	bne	a0,a5,4596 <manywrites+0x122>
          close(fd);
    453e:	854a                	mv	a0,s2
    4540:	00001097          	auipc	ra,0x1
    4544:	33c080e7          	jalr	828(ra) # 587c <close>
        for(int i = 0; i < ci+1; i++){
    4548:	2a05                	addiw	s4,s4,1
    454a:	fd49d6e3          	bge	s3,s4,4516 <manywrites+0xa2>
        unlink(name);
    454e:	fa840513          	addi	a0,s0,-88
    4552:	00001097          	auipc	ra,0x1
    4556:	352080e7          	jalr	850(ra) # 58a4 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    455a:	3bfd                	addiw	s7,s7,-1
    455c:	fa0b9ae3          	bnez	s7,4510 <manywrites+0x9c>
      unlink(name);
    4560:	fa840513          	addi	a0,s0,-88
    4564:	00001097          	auipc	ra,0x1
    4568:	340080e7          	jalr	832(ra) # 58a4 <unlink>
      exit(0);
    456c:	4501                	li	a0,0
    456e:	00001097          	auipc	ra,0x1
    4572:	2e6080e7          	jalr	742(ra) # 5854 <exit>
            printf("%s: cannot create %s\n", s, name);
    4576:	fa840613          	addi	a2,s0,-88
    457a:	85d6                	mv	a1,s5
    457c:	00003517          	auipc	a0,0x3
    4580:	67c50513          	addi	a0,a0,1660 # 7bf8 <malloc+0x1f36>
    4584:	00001097          	auipc	ra,0x1
    4588:	680080e7          	jalr	1664(ra) # 5c04 <printf>
            exit(1);
    458c:	4505                	li	a0,1
    458e:	00001097          	auipc	ra,0x1
    4592:	2c6080e7          	jalr	710(ra) # 5854 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    4596:	86aa                	mv	a3,a0
    4598:	660d                	lui	a2,0x3
    459a:	85d6                	mv	a1,s5
    459c:	00002517          	auipc	a0,0x2
    45a0:	ce450513          	addi	a0,a0,-796 # 6280 <malloc+0x5be>
    45a4:	00001097          	auipc	ra,0x1
    45a8:	660080e7          	jalr	1632(ra) # 5c04 <printf>
            exit(1);
    45ac:	4505                	li	a0,1
    45ae:	00001097          	auipc	ra,0x1
    45b2:	2a6080e7          	jalr	678(ra) # 5854 <exit>
      exit(st);
    45b6:	00001097          	auipc	ra,0x1
    45ba:	29e080e7          	jalr	670(ra) # 5854 <exit>

00000000000045be <iref>:
{
    45be:	7139                	addi	sp,sp,-64
    45c0:	fc06                	sd	ra,56(sp)
    45c2:	f822                	sd	s0,48(sp)
    45c4:	f426                	sd	s1,40(sp)
    45c6:	f04a                	sd	s2,32(sp)
    45c8:	ec4e                	sd	s3,24(sp)
    45ca:	e852                	sd	s4,16(sp)
    45cc:	e456                	sd	s5,8(sp)
    45ce:	e05a                	sd	s6,0(sp)
    45d0:	0080                	addi	s0,sp,64
    45d2:	8b2a                	mv	s6,a0
    45d4:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    45d8:	00003a17          	auipc	s4,0x3
    45dc:	638a0a13          	addi	s4,s4,1592 # 7c10 <malloc+0x1f4e>
    mkdir("");
    45e0:	00003497          	auipc	s1,0x3
    45e4:	b9048493          	addi	s1,s1,-1136 # 7170 <malloc+0x14ae>
    link("README", "");
    45e8:	00002a97          	auipc	s5,0x2
    45ec:	d70a8a93          	addi	s5,s5,-656 # 6358 <malloc+0x696>
    fd = open("xx", O_CREATE);
    45f0:	00003997          	auipc	s3,0x3
    45f4:	f6898993          	addi	s3,s3,-152 # 7558 <malloc+0x1896>
    45f8:	a891                	j	464c <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    45fa:	85da                	mv	a1,s6
    45fc:	00003517          	auipc	a0,0x3
    4600:	61c50513          	addi	a0,a0,1564 # 7c18 <malloc+0x1f56>
    4604:	00001097          	auipc	ra,0x1
    4608:	600080e7          	jalr	1536(ra) # 5c04 <printf>
      exit(1);
    460c:	4505                	li	a0,1
    460e:	00001097          	auipc	ra,0x1
    4612:	246080e7          	jalr	582(ra) # 5854 <exit>
      printf("%s: chdir irefd failed\n", s);
    4616:	85da                	mv	a1,s6
    4618:	00003517          	auipc	a0,0x3
    461c:	61850513          	addi	a0,a0,1560 # 7c30 <malloc+0x1f6e>
    4620:	00001097          	auipc	ra,0x1
    4624:	5e4080e7          	jalr	1508(ra) # 5c04 <printf>
      exit(1);
    4628:	4505                	li	a0,1
    462a:	00001097          	auipc	ra,0x1
    462e:	22a080e7          	jalr	554(ra) # 5854 <exit>
      close(fd);
    4632:	00001097          	auipc	ra,0x1
    4636:	24a080e7          	jalr	586(ra) # 587c <close>
    463a:	a889                	j	468c <iref+0xce>
    unlink("xx");
    463c:	854e                	mv	a0,s3
    463e:	00001097          	auipc	ra,0x1
    4642:	266080e7          	jalr	614(ra) # 58a4 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    4646:	397d                	addiw	s2,s2,-1
    4648:	06090063          	beqz	s2,46a8 <iref+0xea>
    if(mkdir("irefd") != 0){
    464c:	8552                	mv	a0,s4
    464e:	00001097          	auipc	ra,0x1
    4652:	26e080e7          	jalr	622(ra) # 58bc <mkdir>
    4656:	f155                	bnez	a0,45fa <iref+0x3c>
    if(chdir("irefd") != 0){
    4658:	8552                	mv	a0,s4
    465a:	00001097          	auipc	ra,0x1
    465e:	26a080e7          	jalr	618(ra) # 58c4 <chdir>
    4662:	f955                	bnez	a0,4616 <iref+0x58>
    mkdir("");
    4664:	8526                	mv	a0,s1
    4666:	00001097          	auipc	ra,0x1
    466a:	256080e7          	jalr	598(ra) # 58bc <mkdir>
    link("README", "");
    466e:	85a6                	mv	a1,s1
    4670:	8556                	mv	a0,s5
    4672:	00001097          	auipc	ra,0x1
    4676:	242080e7          	jalr	578(ra) # 58b4 <link>
    fd = open("", O_CREATE);
    467a:	20000593          	li	a1,512
    467e:	8526                	mv	a0,s1
    4680:	00001097          	auipc	ra,0x1
    4684:	214080e7          	jalr	532(ra) # 5894 <open>
    if(fd >= 0)
    4688:	fa0555e3          	bgez	a0,4632 <iref+0x74>
    fd = open("xx", O_CREATE);
    468c:	20000593          	li	a1,512
    4690:	854e                	mv	a0,s3
    4692:	00001097          	auipc	ra,0x1
    4696:	202080e7          	jalr	514(ra) # 5894 <open>
    if(fd >= 0)
    469a:	fa0541e3          	bltz	a0,463c <iref+0x7e>
      close(fd);
    469e:	00001097          	auipc	ra,0x1
    46a2:	1de080e7          	jalr	478(ra) # 587c <close>
    46a6:	bf59                	j	463c <iref+0x7e>
    46a8:	03300493          	li	s1,51
    chdir("..");
    46ac:	00002997          	auipc	s3,0x2
    46b0:	7e498993          	addi	s3,s3,2020 # 6e90 <malloc+0x11ce>
    unlink("irefd");
    46b4:	00003917          	auipc	s2,0x3
    46b8:	55c90913          	addi	s2,s2,1372 # 7c10 <malloc+0x1f4e>
    chdir("..");
    46bc:	854e                	mv	a0,s3
    46be:	00001097          	auipc	ra,0x1
    46c2:	206080e7          	jalr	518(ra) # 58c4 <chdir>
    unlink("irefd");
    46c6:	854a                	mv	a0,s2
    46c8:	00001097          	auipc	ra,0x1
    46cc:	1dc080e7          	jalr	476(ra) # 58a4 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    46d0:	34fd                	addiw	s1,s1,-1
    46d2:	f4ed                	bnez	s1,46bc <iref+0xfe>
  chdir("/");
    46d4:	00002517          	auipc	a0,0x2
    46d8:	76450513          	addi	a0,a0,1892 # 6e38 <malloc+0x1176>
    46dc:	00001097          	auipc	ra,0x1
    46e0:	1e8080e7          	jalr	488(ra) # 58c4 <chdir>
}
    46e4:	70e2                	ld	ra,56(sp)
    46e6:	7442                	ld	s0,48(sp)
    46e8:	74a2                	ld	s1,40(sp)
    46ea:	7902                	ld	s2,32(sp)
    46ec:	69e2                	ld	s3,24(sp)
    46ee:	6a42                	ld	s4,16(sp)
    46f0:	6aa2                	ld	s5,8(sp)
    46f2:	6b02                	ld	s6,0(sp)
    46f4:	6121                	addi	sp,sp,64
    46f6:	8082                	ret

00000000000046f8 <sbrkbasic>:
{
    46f8:	7139                	addi	sp,sp,-64
    46fa:	fc06                	sd	ra,56(sp)
    46fc:	f822                	sd	s0,48(sp)
    46fe:	f426                	sd	s1,40(sp)
    4700:	f04a                	sd	s2,32(sp)
    4702:	ec4e                	sd	s3,24(sp)
    4704:	e852                	sd	s4,16(sp)
    4706:	0080                	addi	s0,sp,64
    4708:	8a2a                	mv	s4,a0
  pid = fork();
    470a:	00001097          	auipc	ra,0x1
    470e:	142080e7          	jalr	322(ra) # 584c <fork>
  if(pid < 0){
    4712:	02054c63          	bltz	a0,474a <sbrkbasic+0x52>
  if(pid == 0){
    4716:	ed21                	bnez	a0,476e <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    4718:	40000537          	lui	a0,0x40000
    471c:	00001097          	auipc	ra,0x1
    4720:	1c0080e7          	jalr	448(ra) # 58dc <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    4724:	57fd                	li	a5,-1
    4726:	02f50f63          	beq	a0,a5,4764 <sbrkbasic+0x6c>
    for(b = a; b < a+TOOMUCH; b += 4096){
    472a:	400007b7          	lui	a5,0x40000
    472e:	97aa                	add	a5,a5,a0
      *b = 99;
    4730:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    4734:	6705                	lui	a4,0x1
      *b = 99;
    4736:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff1400>
    for(b = a; b < a+TOOMUCH; b += 4096){
    473a:	953a                	add	a0,a0,a4
    473c:	fef51de3          	bne	a0,a5,4736 <sbrkbasic+0x3e>
    exit(1);
    4740:	4505                	li	a0,1
    4742:	00001097          	auipc	ra,0x1
    4746:	112080e7          	jalr	274(ra) # 5854 <exit>
    printf("fork failed in sbrkbasic\n");
    474a:	00003517          	auipc	a0,0x3
    474e:	4fe50513          	addi	a0,a0,1278 # 7c48 <malloc+0x1f86>
    4752:	00001097          	auipc	ra,0x1
    4756:	4b2080e7          	jalr	1202(ra) # 5c04 <printf>
    exit(1);
    475a:	4505                	li	a0,1
    475c:	00001097          	auipc	ra,0x1
    4760:	0f8080e7          	jalr	248(ra) # 5854 <exit>
      exit(0);
    4764:	4501                	li	a0,0
    4766:	00001097          	auipc	ra,0x1
    476a:	0ee080e7          	jalr	238(ra) # 5854 <exit>
  wait(&xstatus);
    476e:	fcc40513          	addi	a0,s0,-52
    4772:	00001097          	auipc	ra,0x1
    4776:	0ea080e7          	jalr	234(ra) # 585c <wait>
  if(xstatus == 1){
    477a:	fcc42703          	lw	a4,-52(s0)
    477e:	4785                	li	a5,1
    4780:	00f70d63          	beq	a4,a5,479a <sbrkbasic+0xa2>
  a = sbrk(0);
    4784:	4501                	li	a0,0
    4786:	00001097          	auipc	ra,0x1
    478a:	156080e7          	jalr	342(ra) # 58dc <sbrk>
    478e:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    4790:	4901                	li	s2,0
    4792:	6985                	lui	s3,0x1
    4794:	38898993          	addi	s3,s3,904 # 1388 <linktest+0x160>
    4798:	a005                	j	47b8 <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
    479a:	85d2                	mv	a1,s4
    479c:	00003517          	auipc	a0,0x3
    47a0:	4cc50513          	addi	a0,a0,1228 # 7c68 <malloc+0x1fa6>
    47a4:	00001097          	auipc	ra,0x1
    47a8:	460080e7          	jalr	1120(ra) # 5c04 <printf>
    exit(1);
    47ac:	4505                	li	a0,1
    47ae:	00001097          	auipc	ra,0x1
    47b2:	0a6080e7          	jalr	166(ra) # 5854 <exit>
    a = b + 1;
    47b6:	84be                	mv	s1,a5
    b = sbrk(1);
    47b8:	4505                	li	a0,1
    47ba:	00001097          	auipc	ra,0x1
    47be:	122080e7          	jalr	290(ra) # 58dc <sbrk>
    if(b != a){
    47c2:	04951c63          	bne	a0,s1,481a <sbrkbasic+0x122>
    *b = 1;
    47c6:	4785                	li	a5,1
    47c8:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    47cc:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    47d0:	2905                	addiw	s2,s2,1
    47d2:	ff3912e3          	bne	s2,s3,47b6 <sbrkbasic+0xbe>
  pid = fork();
    47d6:	00001097          	auipc	ra,0x1
    47da:	076080e7          	jalr	118(ra) # 584c <fork>
    47de:	892a                	mv	s2,a0
  if(pid < 0){
    47e0:	04054d63          	bltz	a0,483a <sbrkbasic+0x142>
  c = sbrk(1);
    47e4:	4505                	li	a0,1
    47e6:	00001097          	auipc	ra,0x1
    47ea:	0f6080e7          	jalr	246(ra) # 58dc <sbrk>
  c = sbrk(1);
    47ee:	4505                	li	a0,1
    47f0:	00001097          	auipc	ra,0x1
    47f4:	0ec080e7          	jalr	236(ra) # 58dc <sbrk>
  if(c != a + 1){
    47f8:	0489                	addi	s1,s1,2
    47fa:	04a48e63          	beq	s1,a0,4856 <sbrkbasic+0x15e>
    printf("%s: sbrk test failed post-fork\n", s);
    47fe:	85d2                	mv	a1,s4
    4800:	00003517          	auipc	a0,0x3
    4804:	4c850513          	addi	a0,a0,1224 # 7cc8 <malloc+0x2006>
    4808:	00001097          	auipc	ra,0x1
    480c:	3fc080e7          	jalr	1020(ra) # 5c04 <printf>
    exit(1);
    4810:	4505                	li	a0,1
    4812:	00001097          	auipc	ra,0x1
    4816:	042080e7          	jalr	66(ra) # 5854 <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    481a:	86aa                	mv	a3,a0
    481c:	8626                	mv	a2,s1
    481e:	85ca                	mv	a1,s2
    4820:	00003517          	auipc	a0,0x3
    4824:	46850513          	addi	a0,a0,1128 # 7c88 <malloc+0x1fc6>
    4828:	00001097          	auipc	ra,0x1
    482c:	3dc080e7          	jalr	988(ra) # 5c04 <printf>
      exit(1);
    4830:	4505                	li	a0,1
    4832:	00001097          	auipc	ra,0x1
    4836:	022080e7          	jalr	34(ra) # 5854 <exit>
    printf("%s: sbrk test fork failed\n", s);
    483a:	85d2                	mv	a1,s4
    483c:	00003517          	auipc	a0,0x3
    4840:	46c50513          	addi	a0,a0,1132 # 7ca8 <malloc+0x1fe6>
    4844:	00001097          	auipc	ra,0x1
    4848:	3c0080e7          	jalr	960(ra) # 5c04 <printf>
    exit(1);
    484c:	4505                	li	a0,1
    484e:	00001097          	auipc	ra,0x1
    4852:	006080e7          	jalr	6(ra) # 5854 <exit>
  if(pid == 0)
    4856:	00091763          	bnez	s2,4864 <sbrkbasic+0x16c>
    exit(0);
    485a:	4501                	li	a0,0
    485c:	00001097          	auipc	ra,0x1
    4860:	ff8080e7          	jalr	-8(ra) # 5854 <exit>
  wait(&xstatus);
    4864:	fcc40513          	addi	a0,s0,-52
    4868:	00001097          	auipc	ra,0x1
    486c:	ff4080e7          	jalr	-12(ra) # 585c <wait>
  exit(xstatus);
    4870:	fcc42503          	lw	a0,-52(s0)
    4874:	00001097          	auipc	ra,0x1
    4878:	fe0080e7          	jalr	-32(ra) # 5854 <exit>

000000000000487c <sbrkmuch>:
{
    487c:	7179                	addi	sp,sp,-48
    487e:	f406                	sd	ra,40(sp)
    4880:	f022                	sd	s0,32(sp)
    4882:	ec26                	sd	s1,24(sp)
    4884:	e84a                	sd	s2,16(sp)
    4886:	e44e                	sd	s3,8(sp)
    4888:	e052                	sd	s4,0(sp)
    488a:	1800                	addi	s0,sp,48
    488c:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    488e:	4501                	li	a0,0
    4890:	00001097          	auipc	ra,0x1
    4894:	04c080e7          	jalr	76(ra) # 58dc <sbrk>
    4898:	892a                	mv	s2,a0
  a = sbrk(0);
    489a:	4501                	li	a0,0
    489c:	00001097          	auipc	ra,0x1
    48a0:	040080e7          	jalr	64(ra) # 58dc <sbrk>
    48a4:	84aa                	mv	s1,a0
  p = sbrk(amt);
    48a6:	06400537          	lui	a0,0x6400
    48aa:	9d05                	subw	a0,a0,s1
    48ac:	00001097          	auipc	ra,0x1
    48b0:	030080e7          	jalr	48(ra) # 58dc <sbrk>
  if (p != a) {
    48b4:	0ca49863          	bne	s1,a0,4984 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    48b8:	4501                	li	a0,0
    48ba:	00001097          	auipc	ra,0x1
    48be:	022080e7          	jalr	34(ra) # 58dc <sbrk>
    48c2:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    48c4:	00a4f963          	bgeu	s1,a0,48d6 <sbrkmuch+0x5a>
    *pp = 1;
    48c8:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    48ca:	6705                	lui	a4,0x1
    *pp = 1;
    48cc:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    48d0:	94ba                	add	s1,s1,a4
    48d2:	fef4ede3          	bltu	s1,a5,48cc <sbrkmuch+0x50>
  *lastaddr = 99;
    48d6:	064007b7          	lui	a5,0x6400
    48da:	06300713          	li	a4,99
    48de:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f13ff>
  a = sbrk(0);
    48e2:	4501                	li	a0,0
    48e4:	00001097          	auipc	ra,0x1
    48e8:	ff8080e7          	jalr	-8(ra) # 58dc <sbrk>
    48ec:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    48ee:	757d                	lui	a0,0xfffff
    48f0:	00001097          	auipc	ra,0x1
    48f4:	fec080e7          	jalr	-20(ra) # 58dc <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    48f8:	57fd                	li	a5,-1
    48fa:	0af50363          	beq	a0,a5,49a0 <sbrkmuch+0x124>
  c = sbrk(0);
    48fe:	4501                	li	a0,0
    4900:	00001097          	auipc	ra,0x1
    4904:	fdc080e7          	jalr	-36(ra) # 58dc <sbrk>
  if(c != a - PGSIZE){
    4908:	77fd                	lui	a5,0xfffff
    490a:	97a6                	add	a5,a5,s1
    490c:	0af51863          	bne	a0,a5,49bc <sbrkmuch+0x140>
  a = sbrk(0);
    4910:	4501                	li	a0,0
    4912:	00001097          	auipc	ra,0x1
    4916:	fca080e7          	jalr	-54(ra) # 58dc <sbrk>
    491a:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    491c:	6505                	lui	a0,0x1
    491e:	00001097          	auipc	ra,0x1
    4922:	fbe080e7          	jalr	-66(ra) # 58dc <sbrk>
    4926:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    4928:	0aa49a63          	bne	s1,a0,49dc <sbrkmuch+0x160>
    492c:	4501                	li	a0,0
    492e:	00001097          	auipc	ra,0x1
    4932:	fae080e7          	jalr	-82(ra) # 58dc <sbrk>
    4936:	6785                	lui	a5,0x1
    4938:	97a6                	add	a5,a5,s1
    493a:	0af51163          	bne	a0,a5,49dc <sbrkmuch+0x160>
  if(*lastaddr == 99){
    493e:	064007b7          	lui	a5,0x6400
    4942:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f13ff>
    4946:	06300793          	li	a5,99
    494a:	0af70963          	beq	a4,a5,49fc <sbrkmuch+0x180>
  a = sbrk(0);
    494e:	4501                	li	a0,0
    4950:	00001097          	auipc	ra,0x1
    4954:	f8c080e7          	jalr	-116(ra) # 58dc <sbrk>
    4958:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    495a:	4501                	li	a0,0
    495c:	00001097          	auipc	ra,0x1
    4960:	f80080e7          	jalr	-128(ra) # 58dc <sbrk>
    4964:	40a9053b          	subw	a0,s2,a0
    4968:	00001097          	auipc	ra,0x1
    496c:	f74080e7          	jalr	-140(ra) # 58dc <sbrk>
  if(c != a){
    4970:	0aa49463          	bne	s1,a0,4a18 <sbrkmuch+0x19c>
}
    4974:	70a2                	ld	ra,40(sp)
    4976:	7402                	ld	s0,32(sp)
    4978:	64e2                	ld	s1,24(sp)
    497a:	6942                	ld	s2,16(sp)
    497c:	69a2                	ld	s3,8(sp)
    497e:	6a02                	ld	s4,0(sp)
    4980:	6145                	addi	sp,sp,48
    4982:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    4984:	85ce                	mv	a1,s3
    4986:	00003517          	auipc	a0,0x3
    498a:	36250513          	addi	a0,a0,866 # 7ce8 <malloc+0x2026>
    498e:	00001097          	auipc	ra,0x1
    4992:	276080e7          	jalr	630(ra) # 5c04 <printf>
    exit(1);
    4996:	4505                	li	a0,1
    4998:	00001097          	auipc	ra,0x1
    499c:	ebc080e7          	jalr	-324(ra) # 5854 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    49a0:	85ce                	mv	a1,s3
    49a2:	00003517          	auipc	a0,0x3
    49a6:	38e50513          	addi	a0,a0,910 # 7d30 <malloc+0x206e>
    49aa:	00001097          	auipc	ra,0x1
    49ae:	25a080e7          	jalr	602(ra) # 5c04 <printf>
    exit(1);
    49b2:	4505                	li	a0,1
    49b4:	00001097          	auipc	ra,0x1
    49b8:	ea0080e7          	jalr	-352(ra) # 5854 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    49bc:	86aa                	mv	a3,a0
    49be:	8626                	mv	a2,s1
    49c0:	85ce                	mv	a1,s3
    49c2:	00003517          	auipc	a0,0x3
    49c6:	38e50513          	addi	a0,a0,910 # 7d50 <malloc+0x208e>
    49ca:	00001097          	auipc	ra,0x1
    49ce:	23a080e7          	jalr	570(ra) # 5c04 <printf>
    exit(1);
    49d2:	4505                	li	a0,1
    49d4:	00001097          	auipc	ra,0x1
    49d8:	e80080e7          	jalr	-384(ra) # 5854 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    49dc:	86d2                	mv	a3,s4
    49de:	8626                	mv	a2,s1
    49e0:	85ce                	mv	a1,s3
    49e2:	00003517          	auipc	a0,0x3
    49e6:	3ae50513          	addi	a0,a0,942 # 7d90 <malloc+0x20ce>
    49ea:	00001097          	auipc	ra,0x1
    49ee:	21a080e7          	jalr	538(ra) # 5c04 <printf>
    exit(1);
    49f2:	4505                	li	a0,1
    49f4:	00001097          	auipc	ra,0x1
    49f8:	e60080e7          	jalr	-416(ra) # 5854 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    49fc:	85ce                	mv	a1,s3
    49fe:	00003517          	auipc	a0,0x3
    4a02:	3c250513          	addi	a0,a0,962 # 7dc0 <malloc+0x20fe>
    4a06:	00001097          	auipc	ra,0x1
    4a0a:	1fe080e7          	jalr	510(ra) # 5c04 <printf>
    exit(1);
    4a0e:	4505                	li	a0,1
    4a10:	00001097          	auipc	ra,0x1
    4a14:	e44080e7          	jalr	-444(ra) # 5854 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    4a18:	86aa                	mv	a3,a0
    4a1a:	8626                	mv	a2,s1
    4a1c:	85ce                	mv	a1,s3
    4a1e:	00003517          	auipc	a0,0x3
    4a22:	3da50513          	addi	a0,a0,986 # 7df8 <malloc+0x2136>
    4a26:	00001097          	auipc	ra,0x1
    4a2a:	1de080e7          	jalr	478(ra) # 5c04 <printf>
    exit(1);
    4a2e:	4505                	li	a0,1
    4a30:	00001097          	auipc	ra,0x1
    4a34:	e24080e7          	jalr	-476(ra) # 5854 <exit>

0000000000004a38 <kernmem>:
{
    4a38:	715d                	addi	sp,sp,-80
    4a3a:	e486                	sd	ra,72(sp)
    4a3c:	e0a2                	sd	s0,64(sp)
    4a3e:	fc26                	sd	s1,56(sp)
    4a40:	f84a                	sd	s2,48(sp)
    4a42:	f44e                	sd	s3,40(sp)
    4a44:	f052                	sd	s4,32(sp)
    4a46:	ec56                	sd	s5,24(sp)
    4a48:	0880                	addi	s0,sp,80
    4a4a:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    4a4c:	4485                	li	s1,1
    4a4e:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    4a50:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    4a52:	69b1                	lui	s3,0xc
    4a54:	35098993          	addi	s3,s3,848 # c350 <buf+0x760>
    4a58:	1003d937          	lui	s2,0x1003d
    4a5c:	090e                	slli	s2,s2,0x3
    4a5e:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002e880>
    pid = fork();
    4a62:	00001097          	auipc	ra,0x1
    4a66:	dea080e7          	jalr	-534(ra) # 584c <fork>
    if(pid < 0){
    4a6a:	02054963          	bltz	a0,4a9c <kernmem+0x64>
    if(pid == 0){
    4a6e:	c529                	beqz	a0,4ab8 <kernmem+0x80>
    wait(&xstatus);
    4a70:	fbc40513          	addi	a0,s0,-68
    4a74:	00001097          	auipc	ra,0x1
    4a78:	de8080e7          	jalr	-536(ra) # 585c <wait>
    if(xstatus != -1)  // did kernel kill child?
    4a7c:	fbc42783          	lw	a5,-68(s0)
    4a80:	05579d63          	bne	a5,s5,4ada <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    4a84:	94ce                	add	s1,s1,s3
    4a86:	fd249ee3          	bne	s1,s2,4a62 <kernmem+0x2a>
}
    4a8a:	60a6                	ld	ra,72(sp)
    4a8c:	6406                	ld	s0,64(sp)
    4a8e:	74e2                	ld	s1,56(sp)
    4a90:	7942                	ld	s2,48(sp)
    4a92:	79a2                	ld	s3,40(sp)
    4a94:	7a02                	ld	s4,32(sp)
    4a96:	6ae2                	ld	s5,24(sp)
    4a98:	6161                	addi	sp,sp,80
    4a9a:	8082                	ret
      printf("%s: fork failed\n", s);
    4a9c:	85d2                	mv	a1,s4
    4a9e:	00001517          	auipc	a0,0x1
    4aa2:	59a50513          	addi	a0,a0,1434 # 6038 <malloc+0x376>
    4aa6:	00001097          	auipc	ra,0x1
    4aaa:	15e080e7          	jalr	350(ra) # 5c04 <printf>
      exit(1);
    4aae:	4505                	li	a0,1
    4ab0:	00001097          	auipc	ra,0x1
    4ab4:	da4080e7          	jalr	-604(ra) # 5854 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    4ab8:	0004c683          	lbu	a3,0(s1)
    4abc:	8626                	mv	a2,s1
    4abe:	85d2                	mv	a1,s4
    4ac0:	00003517          	auipc	a0,0x3
    4ac4:	36050513          	addi	a0,a0,864 # 7e20 <malloc+0x215e>
    4ac8:	00001097          	auipc	ra,0x1
    4acc:	13c080e7          	jalr	316(ra) # 5c04 <printf>
      exit(1);
    4ad0:	4505                	li	a0,1
    4ad2:	00001097          	auipc	ra,0x1
    4ad6:	d82080e7          	jalr	-638(ra) # 5854 <exit>
      exit(1);
    4ada:	4505                	li	a0,1
    4adc:	00001097          	auipc	ra,0x1
    4ae0:	d78080e7          	jalr	-648(ra) # 5854 <exit>

0000000000004ae4 <sbrkfail>:
{
    4ae4:	7119                	addi	sp,sp,-128
    4ae6:	fc86                	sd	ra,120(sp)
    4ae8:	f8a2                	sd	s0,112(sp)
    4aea:	f4a6                	sd	s1,104(sp)
    4aec:	f0ca                	sd	s2,96(sp)
    4aee:	ecce                	sd	s3,88(sp)
    4af0:	e8d2                	sd	s4,80(sp)
    4af2:	e4d6                	sd	s5,72(sp)
    4af4:	0100                	addi	s0,sp,128
    4af6:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    4af8:	fb040513          	addi	a0,s0,-80
    4afc:	00001097          	auipc	ra,0x1
    4b00:	d68080e7          	jalr	-664(ra) # 5864 <pipe>
    4b04:	e901                	bnez	a0,4b14 <sbrkfail+0x30>
    4b06:	f8040493          	addi	s1,s0,-128
    4b0a:	fa840993          	addi	s3,s0,-88
    4b0e:	8926                	mv	s2,s1
    if(pids[i] != -1)
    4b10:	5a7d                	li	s4,-1
    4b12:	a085                	j	4b72 <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    4b14:	85d6                	mv	a1,s5
    4b16:	00002517          	auipc	a0,0x2
    4b1a:	98250513          	addi	a0,a0,-1662 # 6498 <malloc+0x7d6>
    4b1e:	00001097          	auipc	ra,0x1
    4b22:	0e6080e7          	jalr	230(ra) # 5c04 <printf>
    exit(1);
    4b26:	4505                	li	a0,1
    4b28:	00001097          	auipc	ra,0x1
    4b2c:	d2c080e7          	jalr	-724(ra) # 5854 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    4b30:	00001097          	auipc	ra,0x1
    4b34:	dac080e7          	jalr	-596(ra) # 58dc <sbrk>
    4b38:	064007b7          	lui	a5,0x6400
    4b3c:	40a7853b          	subw	a0,a5,a0
    4b40:	00001097          	auipc	ra,0x1
    4b44:	d9c080e7          	jalr	-612(ra) # 58dc <sbrk>
      write(fds[1], "x", 1);
    4b48:	4605                	li	a2,1
    4b4a:	00001597          	auipc	a1,0x1
    4b4e:	6d658593          	addi	a1,a1,1750 # 6220 <malloc+0x55e>
    4b52:	fb442503          	lw	a0,-76(s0)
    4b56:	00001097          	auipc	ra,0x1
    4b5a:	d1e080e7          	jalr	-738(ra) # 5874 <write>
      for(;;) sleep(1000);
    4b5e:	3e800513          	li	a0,1000
    4b62:	00001097          	auipc	ra,0x1
    4b66:	d82080e7          	jalr	-638(ra) # 58e4 <sleep>
    4b6a:	bfd5                	j	4b5e <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4b6c:	0911                	addi	s2,s2,4
    4b6e:	03390563          	beq	s2,s3,4b98 <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    4b72:	00001097          	auipc	ra,0x1
    4b76:	cda080e7          	jalr	-806(ra) # 584c <fork>
    4b7a:	00a92023          	sw	a0,0(s2)
    4b7e:	d94d                	beqz	a0,4b30 <sbrkfail+0x4c>
    if(pids[i] != -1)
    4b80:	ff4506e3          	beq	a0,s4,4b6c <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    4b84:	4605                	li	a2,1
    4b86:	faf40593          	addi	a1,s0,-81
    4b8a:	fb042503          	lw	a0,-80(s0)
    4b8e:	00001097          	auipc	ra,0x1
    4b92:	cde080e7          	jalr	-802(ra) # 586c <read>
    4b96:	bfd9                	j	4b6c <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    4b98:	6505                	lui	a0,0x1
    4b9a:	00001097          	auipc	ra,0x1
    4b9e:	d42080e7          	jalr	-702(ra) # 58dc <sbrk>
    4ba2:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    4ba4:	597d                	li	s2,-1
    4ba6:	a021                	j	4bae <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4ba8:	0491                	addi	s1,s1,4
    4baa:	03348063          	beq	s1,s3,4bca <sbrkfail+0xe6>
    if(pids[i] == -1)
    4bae:	4088                	lw	a0,0(s1)
    4bb0:	ff250ce3          	beq	a0,s2,4ba8 <sbrkfail+0xc4>
    kill(pids[i], SIGKILL);
    4bb4:	45a5                	li	a1,9
    4bb6:	00001097          	auipc	ra,0x1
    4bba:	cce080e7          	jalr	-818(ra) # 5884 <kill>
    wait(0);
    4bbe:	4501                	li	a0,0
    4bc0:	00001097          	auipc	ra,0x1
    4bc4:	c9c080e7          	jalr	-868(ra) # 585c <wait>
    4bc8:	b7c5                	j	4ba8 <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    4bca:	57fd                	li	a5,-1
    4bcc:	04fa0163          	beq	s4,a5,4c0e <sbrkfail+0x12a>
  pid = fork();
    4bd0:	00001097          	auipc	ra,0x1
    4bd4:	c7c080e7          	jalr	-900(ra) # 584c <fork>
    4bd8:	84aa                	mv	s1,a0
  if(pid < 0){
    4bda:	04054863          	bltz	a0,4c2a <sbrkfail+0x146>
  if(pid == 0){
    4bde:	c525                	beqz	a0,4c46 <sbrkfail+0x162>
  wait(&xstatus);
    4be0:	fbc40513          	addi	a0,s0,-68
    4be4:	00001097          	auipc	ra,0x1
    4be8:	c78080e7          	jalr	-904(ra) # 585c <wait>
  if(xstatus != -1 && xstatus != 2)
    4bec:	fbc42783          	lw	a5,-68(s0)
    4bf0:	577d                	li	a4,-1
    4bf2:	00e78563          	beq	a5,a4,4bfc <sbrkfail+0x118>
    4bf6:	4709                	li	a4,2
    4bf8:	08e79d63          	bne	a5,a4,4c92 <sbrkfail+0x1ae>
}
    4bfc:	70e6                	ld	ra,120(sp)
    4bfe:	7446                	ld	s0,112(sp)
    4c00:	74a6                	ld	s1,104(sp)
    4c02:	7906                	ld	s2,96(sp)
    4c04:	69e6                	ld	s3,88(sp)
    4c06:	6a46                	ld	s4,80(sp)
    4c08:	6aa6                	ld	s5,72(sp)
    4c0a:	6109                	addi	sp,sp,128
    4c0c:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    4c0e:	85d6                	mv	a1,s5
    4c10:	00003517          	auipc	a0,0x3
    4c14:	23050513          	addi	a0,a0,560 # 7e40 <malloc+0x217e>
    4c18:	00001097          	auipc	ra,0x1
    4c1c:	fec080e7          	jalr	-20(ra) # 5c04 <printf>
    exit(1);
    4c20:	4505                	li	a0,1
    4c22:	00001097          	auipc	ra,0x1
    4c26:	c32080e7          	jalr	-974(ra) # 5854 <exit>
    printf("%s: fork failed\n", s);
    4c2a:	85d6                	mv	a1,s5
    4c2c:	00001517          	auipc	a0,0x1
    4c30:	40c50513          	addi	a0,a0,1036 # 6038 <malloc+0x376>
    4c34:	00001097          	auipc	ra,0x1
    4c38:	fd0080e7          	jalr	-48(ra) # 5c04 <printf>
    exit(1);
    4c3c:	4505                	li	a0,1
    4c3e:	00001097          	auipc	ra,0x1
    4c42:	c16080e7          	jalr	-1002(ra) # 5854 <exit>
    a = sbrk(0);
    4c46:	4501                	li	a0,0
    4c48:	00001097          	auipc	ra,0x1
    4c4c:	c94080e7          	jalr	-876(ra) # 58dc <sbrk>
    4c50:	892a                	mv	s2,a0
    sbrk(10*BIG);
    4c52:	3e800537          	lui	a0,0x3e800
    4c56:	00001097          	auipc	ra,0x1
    4c5a:	c86080e7          	jalr	-890(ra) # 58dc <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4c5e:	87ca                	mv	a5,s2
    4c60:	3e800737          	lui	a4,0x3e800
    4c64:	993a                	add	s2,s2,a4
    4c66:	6705                	lui	a4,0x1
      n += *(a+i);
    4c68:	0007c683          	lbu	a3,0(a5) # 6400000 <__BSS_END__+0x63f1400>
    4c6c:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4c6e:	97ba                	add	a5,a5,a4
    4c70:	ff279ce3          	bne	a5,s2,4c68 <sbrkfail+0x184>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    4c74:	8626                	mv	a2,s1
    4c76:	85d6                	mv	a1,s5
    4c78:	00003517          	auipc	a0,0x3
    4c7c:	1e850513          	addi	a0,a0,488 # 7e60 <malloc+0x219e>
    4c80:	00001097          	auipc	ra,0x1
    4c84:	f84080e7          	jalr	-124(ra) # 5c04 <printf>
    exit(1);
    4c88:	4505                	li	a0,1
    4c8a:	00001097          	auipc	ra,0x1
    4c8e:	bca080e7          	jalr	-1078(ra) # 5854 <exit>
    exit(1);
    4c92:	4505                	li	a0,1
    4c94:	00001097          	auipc	ra,0x1
    4c98:	bc0080e7          	jalr	-1088(ra) # 5854 <exit>

0000000000004c9c <fsfull>:
{
    4c9c:	7171                	addi	sp,sp,-176
    4c9e:	f506                	sd	ra,168(sp)
    4ca0:	f122                	sd	s0,160(sp)
    4ca2:	ed26                	sd	s1,152(sp)
    4ca4:	e94a                	sd	s2,144(sp)
    4ca6:	e54e                	sd	s3,136(sp)
    4ca8:	e152                	sd	s4,128(sp)
    4caa:	fcd6                	sd	s5,120(sp)
    4cac:	f8da                	sd	s6,112(sp)
    4cae:	f4de                	sd	s7,104(sp)
    4cb0:	f0e2                	sd	s8,96(sp)
    4cb2:	ece6                	sd	s9,88(sp)
    4cb4:	e8ea                	sd	s10,80(sp)
    4cb6:	e4ee                	sd	s11,72(sp)
    4cb8:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4cba:	00003517          	auipc	a0,0x3
    4cbe:	1d650513          	addi	a0,a0,470 # 7e90 <malloc+0x21ce>
    4cc2:	00001097          	auipc	ra,0x1
    4cc6:	f42080e7          	jalr	-190(ra) # 5c04 <printf>
  for(nfiles = 0; ; nfiles++){
    4cca:	4481                	li	s1,0
    name[0] = 'f';
    4ccc:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4cd0:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4cd4:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4cd8:	4b29                	li	s6,10
    printf("writing %s\n", name);
    4cda:	00003c97          	auipc	s9,0x3
    4cde:	1c6c8c93          	addi	s9,s9,454 # 7ea0 <malloc+0x21de>
    int total = 0;
    4ce2:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4ce4:	00007a17          	auipc	s4,0x7
    4ce8:	f0ca0a13          	addi	s4,s4,-244 # bbf0 <buf>
    name[0] = 'f';
    4cec:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4cf0:	0384c7bb          	divw	a5,s1,s8
    4cf4:	0307879b          	addiw	a5,a5,48
    4cf8:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4cfc:	0384e7bb          	remw	a5,s1,s8
    4d00:	0377c7bb          	divw	a5,a5,s7
    4d04:	0307879b          	addiw	a5,a5,48
    4d08:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4d0c:	0374e7bb          	remw	a5,s1,s7
    4d10:	0367c7bb          	divw	a5,a5,s6
    4d14:	0307879b          	addiw	a5,a5,48
    4d18:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4d1c:	0364e7bb          	remw	a5,s1,s6
    4d20:	0307879b          	addiw	a5,a5,48
    4d24:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4d28:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4d2c:	f5040593          	addi	a1,s0,-176
    4d30:	8566                	mv	a0,s9
    4d32:	00001097          	auipc	ra,0x1
    4d36:	ed2080e7          	jalr	-302(ra) # 5c04 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4d3a:	20200593          	li	a1,514
    4d3e:	f5040513          	addi	a0,s0,-176
    4d42:	00001097          	auipc	ra,0x1
    4d46:	b52080e7          	jalr	-1198(ra) # 5894 <open>
    4d4a:	892a                	mv	s2,a0
    if(fd < 0){
    4d4c:	0a055663          	bgez	a0,4df8 <fsfull+0x15c>
      printf("open %s failed\n", name);
    4d50:	f5040593          	addi	a1,s0,-176
    4d54:	00003517          	auipc	a0,0x3
    4d58:	15c50513          	addi	a0,a0,348 # 7eb0 <malloc+0x21ee>
    4d5c:	00001097          	auipc	ra,0x1
    4d60:	ea8080e7          	jalr	-344(ra) # 5c04 <printf>
  while(nfiles >= 0){
    4d64:	0604c363          	bltz	s1,4dca <fsfull+0x12e>
    name[0] = 'f';
    4d68:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4d6c:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4d70:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4d74:	4929                	li	s2,10
  while(nfiles >= 0){
    4d76:	5afd                	li	s5,-1
    name[0] = 'f';
    4d78:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4d7c:	0344c7bb          	divw	a5,s1,s4
    4d80:	0307879b          	addiw	a5,a5,48
    4d84:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4d88:	0344e7bb          	remw	a5,s1,s4
    4d8c:	0337c7bb          	divw	a5,a5,s3
    4d90:	0307879b          	addiw	a5,a5,48
    4d94:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4d98:	0334e7bb          	remw	a5,s1,s3
    4d9c:	0327c7bb          	divw	a5,a5,s2
    4da0:	0307879b          	addiw	a5,a5,48
    4da4:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4da8:	0324e7bb          	remw	a5,s1,s2
    4dac:	0307879b          	addiw	a5,a5,48
    4db0:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4db4:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4db8:	f5040513          	addi	a0,s0,-176
    4dbc:	00001097          	auipc	ra,0x1
    4dc0:	ae8080e7          	jalr	-1304(ra) # 58a4 <unlink>
    nfiles--;
    4dc4:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4dc6:	fb5499e3          	bne	s1,s5,4d78 <fsfull+0xdc>
  printf("fsfull test finished\n");
    4dca:	00003517          	auipc	a0,0x3
    4dce:	10650513          	addi	a0,a0,262 # 7ed0 <malloc+0x220e>
    4dd2:	00001097          	auipc	ra,0x1
    4dd6:	e32080e7          	jalr	-462(ra) # 5c04 <printf>
}
    4dda:	70aa                	ld	ra,168(sp)
    4ddc:	740a                	ld	s0,160(sp)
    4dde:	64ea                	ld	s1,152(sp)
    4de0:	694a                	ld	s2,144(sp)
    4de2:	69aa                	ld	s3,136(sp)
    4de4:	6a0a                	ld	s4,128(sp)
    4de6:	7ae6                	ld	s5,120(sp)
    4de8:	7b46                	ld	s6,112(sp)
    4dea:	7ba6                	ld	s7,104(sp)
    4dec:	7c06                	ld	s8,96(sp)
    4dee:	6ce6                	ld	s9,88(sp)
    4df0:	6d46                	ld	s10,80(sp)
    4df2:	6da6                	ld	s11,72(sp)
    4df4:	614d                	addi	sp,sp,176
    4df6:	8082                	ret
    int total = 0;
    4df8:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4dfa:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4dfe:	40000613          	li	a2,1024
    4e02:	85d2                	mv	a1,s4
    4e04:	854a                	mv	a0,s2
    4e06:	00001097          	auipc	ra,0x1
    4e0a:	a6e080e7          	jalr	-1426(ra) # 5874 <write>
      if(cc < BSIZE)
    4e0e:	00aad563          	bge	s5,a0,4e18 <fsfull+0x17c>
      total += cc;
    4e12:	00a989bb          	addw	s3,s3,a0
    while(1){
    4e16:	b7e5                	j	4dfe <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    4e18:	85ce                	mv	a1,s3
    4e1a:	00003517          	auipc	a0,0x3
    4e1e:	0a650513          	addi	a0,a0,166 # 7ec0 <malloc+0x21fe>
    4e22:	00001097          	auipc	ra,0x1
    4e26:	de2080e7          	jalr	-542(ra) # 5c04 <printf>
    close(fd);
    4e2a:	854a                	mv	a0,s2
    4e2c:	00001097          	auipc	ra,0x1
    4e30:	a50080e7          	jalr	-1456(ra) # 587c <close>
    if(total == 0)
    4e34:	f20988e3          	beqz	s3,4d64 <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4e38:	2485                	addiw	s1,s1,1
    4e3a:	bd4d                	j	4cec <fsfull+0x50>

0000000000004e3c <rand>:
{
    4e3c:	1141                	addi	sp,sp,-16
    4e3e:	e422                	sd	s0,8(sp)
    4e40:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4e42:	00003717          	auipc	a4,0x3
    4e46:	57e70713          	addi	a4,a4,1406 # 83c0 <randstate>
    4e4a:	6308                	ld	a0,0(a4)
    4e4c:	001967b7          	lui	a5,0x196
    4e50:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x187a0d>
    4e54:	02f50533          	mul	a0,a0,a5
    4e58:	3c6ef7b7          	lui	a5,0x3c6ef
    4e5c:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e075f>
    4e60:	953e                	add	a0,a0,a5
    4e62:	e308                	sd	a0,0(a4)
}
    4e64:	2501                	sext.w	a0,a0
    4e66:	6422                	ld	s0,8(sp)
    4e68:	0141                	addi	sp,sp,16
    4e6a:	8082                	ret

0000000000004e6c <stacktest>:
{
    4e6c:	7179                	addi	sp,sp,-48
    4e6e:	f406                	sd	ra,40(sp)
    4e70:	f022                	sd	s0,32(sp)
    4e72:	ec26                	sd	s1,24(sp)
    4e74:	1800                	addi	s0,sp,48
    4e76:	84aa                	mv	s1,a0
  pid = fork();
    4e78:	00001097          	auipc	ra,0x1
    4e7c:	9d4080e7          	jalr	-1580(ra) # 584c <fork>
  if(pid == 0) {
    4e80:	c115                	beqz	a0,4ea4 <stacktest+0x38>
  } else if(pid < 0){
    4e82:	04054463          	bltz	a0,4eca <stacktest+0x5e>
  wait(&xstatus);
    4e86:	fdc40513          	addi	a0,s0,-36
    4e8a:	00001097          	auipc	ra,0x1
    4e8e:	9d2080e7          	jalr	-1582(ra) # 585c <wait>
  if(xstatus == -1)  // kernel killed child?
    4e92:	fdc42503          	lw	a0,-36(s0)
    4e96:	57fd                	li	a5,-1
    4e98:	04f50763          	beq	a0,a5,4ee6 <stacktest+0x7a>
    exit(xstatus);
    4e9c:	00001097          	auipc	ra,0x1
    4ea0:	9b8080e7          	jalr	-1608(ra) # 5854 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    4ea4:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    4ea6:	77fd                	lui	a5,0xfffff
    4ea8:	97ba                	add	a5,a5,a4
    4eaa:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff0400>
    4eae:	85a6                	mv	a1,s1
    4eb0:	00003517          	auipc	a0,0x3
    4eb4:	03850513          	addi	a0,a0,56 # 7ee8 <malloc+0x2226>
    4eb8:	00001097          	auipc	ra,0x1
    4ebc:	d4c080e7          	jalr	-692(ra) # 5c04 <printf>
    exit(1);
    4ec0:	4505                	li	a0,1
    4ec2:	00001097          	auipc	ra,0x1
    4ec6:	992080e7          	jalr	-1646(ra) # 5854 <exit>
    printf("%s: fork failed\n", s);
    4eca:	85a6                	mv	a1,s1
    4ecc:	00001517          	auipc	a0,0x1
    4ed0:	16c50513          	addi	a0,a0,364 # 6038 <malloc+0x376>
    4ed4:	00001097          	auipc	ra,0x1
    4ed8:	d30080e7          	jalr	-720(ra) # 5c04 <printf>
    exit(1);
    4edc:	4505                	li	a0,1
    4ede:	00001097          	auipc	ra,0x1
    4ee2:	976080e7          	jalr	-1674(ra) # 5854 <exit>
    exit(0);
    4ee6:	4501                	li	a0,0
    4ee8:	00001097          	auipc	ra,0x1
    4eec:	96c080e7          	jalr	-1684(ra) # 5854 <exit>

0000000000004ef0 <sbrkbugs>:
{
    4ef0:	1141                	addi	sp,sp,-16
    4ef2:	e406                	sd	ra,8(sp)
    4ef4:	e022                	sd	s0,0(sp)
    4ef6:	0800                	addi	s0,sp,16
  int pid = fork();
    4ef8:	00001097          	auipc	ra,0x1
    4efc:	954080e7          	jalr	-1708(ra) # 584c <fork>
  if(pid < 0){
    4f00:	02054263          	bltz	a0,4f24 <sbrkbugs+0x34>
  if(pid == 0){
    4f04:	ed0d                	bnez	a0,4f3e <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    4f06:	00001097          	auipc	ra,0x1
    4f0a:	9d6080e7          	jalr	-1578(ra) # 58dc <sbrk>
    sbrk(-sz);
    4f0e:	40a0053b          	negw	a0,a0
    4f12:	00001097          	auipc	ra,0x1
    4f16:	9ca080e7          	jalr	-1590(ra) # 58dc <sbrk>
    exit(0);
    4f1a:	4501                	li	a0,0
    4f1c:	00001097          	auipc	ra,0x1
    4f20:	938080e7          	jalr	-1736(ra) # 5854 <exit>
    printf("fork failed\n");
    4f24:	00002517          	auipc	a0,0x2
    4f28:	b0c50513          	addi	a0,a0,-1268 # 6a30 <malloc+0xd6e>
    4f2c:	00001097          	auipc	ra,0x1
    4f30:	cd8080e7          	jalr	-808(ra) # 5c04 <printf>
    exit(1);
    4f34:	4505                	li	a0,1
    4f36:	00001097          	auipc	ra,0x1
    4f3a:	91e080e7          	jalr	-1762(ra) # 5854 <exit>
  wait(0);
    4f3e:	4501                	li	a0,0
    4f40:	00001097          	auipc	ra,0x1
    4f44:	91c080e7          	jalr	-1764(ra) # 585c <wait>
  pid = fork();
    4f48:	00001097          	auipc	ra,0x1
    4f4c:	904080e7          	jalr	-1788(ra) # 584c <fork>
  if(pid < 0){
    4f50:	02054563          	bltz	a0,4f7a <sbrkbugs+0x8a>
  if(pid == 0){
    4f54:	e121                	bnez	a0,4f94 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    4f56:	00001097          	auipc	ra,0x1
    4f5a:	986080e7          	jalr	-1658(ra) # 58dc <sbrk>
    sbrk(-(sz - 3500));
    4f5e:	6785                	lui	a5,0x1
    4f60:	dac7879b          	addiw	a5,a5,-596
    4f64:	40a7853b          	subw	a0,a5,a0
    4f68:	00001097          	auipc	ra,0x1
    4f6c:	974080e7          	jalr	-1676(ra) # 58dc <sbrk>
    exit(0);
    4f70:	4501                	li	a0,0
    4f72:	00001097          	auipc	ra,0x1
    4f76:	8e2080e7          	jalr	-1822(ra) # 5854 <exit>
    printf("fork failed\n");
    4f7a:	00002517          	auipc	a0,0x2
    4f7e:	ab650513          	addi	a0,a0,-1354 # 6a30 <malloc+0xd6e>
    4f82:	00001097          	auipc	ra,0x1
    4f86:	c82080e7          	jalr	-894(ra) # 5c04 <printf>
    exit(1);
    4f8a:	4505                	li	a0,1
    4f8c:	00001097          	auipc	ra,0x1
    4f90:	8c8080e7          	jalr	-1848(ra) # 5854 <exit>
  wait(0);
    4f94:	4501                	li	a0,0
    4f96:	00001097          	auipc	ra,0x1
    4f9a:	8c6080e7          	jalr	-1850(ra) # 585c <wait>
  pid = fork();
    4f9e:	00001097          	auipc	ra,0x1
    4fa2:	8ae080e7          	jalr	-1874(ra) # 584c <fork>
  if(pid < 0){
    4fa6:	02054a63          	bltz	a0,4fda <sbrkbugs+0xea>
  if(pid == 0){
    4faa:	e529                	bnez	a0,4ff4 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    4fac:	00001097          	auipc	ra,0x1
    4fb0:	930080e7          	jalr	-1744(ra) # 58dc <sbrk>
    4fb4:	67ad                	lui	a5,0xb
    4fb6:	8007879b          	addiw	a5,a5,-2048
    4fba:	40a7853b          	subw	a0,a5,a0
    4fbe:	00001097          	auipc	ra,0x1
    4fc2:	91e080e7          	jalr	-1762(ra) # 58dc <sbrk>
    sbrk(-10);
    4fc6:	5559                	li	a0,-10
    4fc8:	00001097          	auipc	ra,0x1
    4fcc:	914080e7          	jalr	-1772(ra) # 58dc <sbrk>
    exit(0);
    4fd0:	4501                	li	a0,0
    4fd2:	00001097          	auipc	ra,0x1
    4fd6:	882080e7          	jalr	-1918(ra) # 5854 <exit>
    printf("fork failed\n");
    4fda:	00002517          	auipc	a0,0x2
    4fde:	a5650513          	addi	a0,a0,-1450 # 6a30 <malloc+0xd6e>
    4fe2:	00001097          	auipc	ra,0x1
    4fe6:	c22080e7          	jalr	-990(ra) # 5c04 <printf>
    exit(1);
    4fea:	4505                	li	a0,1
    4fec:	00001097          	auipc	ra,0x1
    4ff0:	868080e7          	jalr	-1944(ra) # 5854 <exit>
  wait(0);
    4ff4:	4501                	li	a0,0
    4ff6:	00001097          	auipc	ra,0x1
    4ffa:	866080e7          	jalr	-1946(ra) # 585c <wait>
  exit(0);
    4ffe:	4501                	li	a0,0
    5000:	00001097          	auipc	ra,0x1
    5004:	854080e7          	jalr	-1964(ra) # 5854 <exit>

0000000000005008 <badwrite>:
{
    5008:	7179                	addi	sp,sp,-48
    500a:	f406                	sd	ra,40(sp)
    500c:	f022                	sd	s0,32(sp)
    500e:	ec26                	sd	s1,24(sp)
    5010:	e84a                	sd	s2,16(sp)
    5012:	e44e                	sd	s3,8(sp)
    5014:	e052                	sd	s4,0(sp)
    5016:	1800                	addi	s0,sp,48
  unlink("junk");
    5018:	00003517          	auipc	a0,0x3
    501c:	ef850513          	addi	a0,a0,-264 # 7f10 <malloc+0x224e>
    5020:	00001097          	auipc	ra,0x1
    5024:	884080e7          	jalr	-1916(ra) # 58a4 <unlink>
    5028:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    502c:	00003997          	auipc	s3,0x3
    5030:	ee498993          	addi	s3,s3,-284 # 7f10 <malloc+0x224e>
    write(fd, (char*)0xffffffffffL, 1);
    5034:	5a7d                	li	s4,-1
    5036:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    503a:	20100593          	li	a1,513
    503e:	854e                	mv	a0,s3
    5040:	00001097          	auipc	ra,0x1
    5044:	854080e7          	jalr	-1964(ra) # 5894 <open>
    5048:	84aa                	mv	s1,a0
    if(fd < 0){
    504a:	06054b63          	bltz	a0,50c0 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    504e:	4605                	li	a2,1
    5050:	85d2                	mv	a1,s4
    5052:	00001097          	auipc	ra,0x1
    5056:	822080e7          	jalr	-2014(ra) # 5874 <write>
    close(fd);
    505a:	8526                	mv	a0,s1
    505c:	00001097          	auipc	ra,0x1
    5060:	820080e7          	jalr	-2016(ra) # 587c <close>
    unlink("junk");
    5064:	854e                	mv	a0,s3
    5066:	00001097          	auipc	ra,0x1
    506a:	83e080e7          	jalr	-1986(ra) # 58a4 <unlink>
  for(int i = 0; i < assumed_free; i++){
    506e:	397d                	addiw	s2,s2,-1
    5070:	fc0915e3          	bnez	s2,503a <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    5074:	20100593          	li	a1,513
    5078:	00003517          	auipc	a0,0x3
    507c:	e9850513          	addi	a0,a0,-360 # 7f10 <malloc+0x224e>
    5080:	00001097          	auipc	ra,0x1
    5084:	814080e7          	jalr	-2028(ra) # 5894 <open>
    5088:	84aa                	mv	s1,a0
  if(fd < 0){
    508a:	04054863          	bltz	a0,50da <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    508e:	4605                	li	a2,1
    5090:	00001597          	auipc	a1,0x1
    5094:	19058593          	addi	a1,a1,400 # 6220 <malloc+0x55e>
    5098:	00000097          	auipc	ra,0x0
    509c:	7dc080e7          	jalr	2012(ra) # 5874 <write>
    50a0:	4785                	li	a5,1
    50a2:	04f50963          	beq	a0,a5,50f4 <badwrite+0xec>
    printf("write failed\n");
    50a6:	00003517          	auipc	a0,0x3
    50aa:	e8a50513          	addi	a0,a0,-374 # 7f30 <malloc+0x226e>
    50ae:	00001097          	auipc	ra,0x1
    50b2:	b56080e7          	jalr	-1194(ra) # 5c04 <printf>
    exit(1);
    50b6:	4505                	li	a0,1
    50b8:	00000097          	auipc	ra,0x0
    50bc:	79c080e7          	jalr	1948(ra) # 5854 <exit>
      printf("open junk failed\n");
    50c0:	00003517          	auipc	a0,0x3
    50c4:	e5850513          	addi	a0,a0,-424 # 7f18 <malloc+0x2256>
    50c8:	00001097          	auipc	ra,0x1
    50cc:	b3c080e7          	jalr	-1220(ra) # 5c04 <printf>
      exit(1);
    50d0:	4505                	li	a0,1
    50d2:	00000097          	auipc	ra,0x0
    50d6:	782080e7          	jalr	1922(ra) # 5854 <exit>
    printf("open junk failed\n");
    50da:	00003517          	auipc	a0,0x3
    50de:	e3e50513          	addi	a0,a0,-450 # 7f18 <malloc+0x2256>
    50e2:	00001097          	auipc	ra,0x1
    50e6:	b22080e7          	jalr	-1246(ra) # 5c04 <printf>
    exit(1);
    50ea:	4505                	li	a0,1
    50ec:	00000097          	auipc	ra,0x0
    50f0:	768080e7          	jalr	1896(ra) # 5854 <exit>
  close(fd);
    50f4:	8526                	mv	a0,s1
    50f6:	00000097          	auipc	ra,0x0
    50fa:	786080e7          	jalr	1926(ra) # 587c <close>
  unlink("junk");
    50fe:	00003517          	auipc	a0,0x3
    5102:	e1250513          	addi	a0,a0,-494 # 7f10 <malloc+0x224e>
    5106:	00000097          	auipc	ra,0x0
    510a:	79e080e7          	jalr	1950(ra) # 58a4 <unlink>
  exit(0);
    510e:	4501                	li	a0,0
    5110:	00000097          	auipc	ra,0x0
    5114:	744080e7          	jalr	1860(ra) # 5854 <exit>

0000000000005118 <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    5118:	715d                	addi	sp,sp,-80
    511a:	e486                	sd	ra,72(sp)
    511c:	e0a2                	sd	s0,64(sp)
    511e:	fc26                	sd	s1,56(sp)
    5120:	f84a                	sd	s2,48(sp)
    5122:	f44e                	sd	s3,40(sp)
    5124:	f052                	sd	s4,32(sp)
    5126:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    5128:	4901                	li	s2,0
    512a:	49bd                	li	s3,15
    int pid = fork();
    512c:	00000097          	auipc	ra,0x0
    5130:	720080e7          	jalr	1824(ra) # 584c <fork>
    5134:	84aa                	mv	s1,a0
    if(pid < 0){
    5136:	02054063          	bltz	a0,5156 <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    513a:	c91d                	beqz	a0,5170 <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    513c:	4501                	li	a0,0
    513e:	00000097          	auipc	ra,0x0
    5142:	71e080e7          	jalr	1822(ra) # 585c <wait>
  for(int avail = 0; avail < 15; avail++){
    5146:	2905                	addiw	s2,s2,1
    5148:	ff3912e3          	bne	s2,s3,512c <execout+0x14>
    }
  }

  exit(0);
    514c:	4501                	li	a0,0
    514e:	00000097          	auipc	ra,0x0
    5152:	706080e7          	jalr	1798(ra) # 5854 <exit>
      printf("fork failed\n");
    5156:	00002517          	auipc	a0,0x2
    515a:	8da50513          	addi	a0,a0,-1830 # 6a30 <malloc+0xd6e>
    515e:	00001097          	auipc	ra,0x1
    5162:	aa6080e7          	jalr	-1370(ra) # 5c04 <printf>
      exit(1);
    5166:	4505                	li	a0,1
    5168:	00000097          	auipc	ra,0x0
    516c:	6ec080e7          	jalr	1772(ra) # 5854 <exit>
        if(a == 0xffffffffffffffffLL)
    5170:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    5172:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    5174:	6505                	lui	a0,0x1
    5176:	00000097          	auipc	ra,0x0
    517a:	766080e7          	jalr	1894(ra) # 58dc <sbrk>
        if(a == 0xffffffffffffffffLL)
    517e:	01350763          	beq	a0,s3,518c <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    5182:	6785                	lui	a5,0x1
    5184:	953e                	add	a0,a0,a5
    5186:	ff450fa3          	sb	s4,-1(a0) # fff <preempt+0x137>
      while(1){
    518a:	b7ed                	j	5174 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    518c:	01205a63          	blez	s2,51a0 <execout+0x88>
        sbrk(-4096);
    5190:	757d                	lui	a0,0xfffff
    5192:	00000097          	auipc	ra,0x0
    5196:	74a080e7          	jalr	1866(ra) # 58dc <sbrk>
      for(int i = 0; i < avail; i++)
    519a:	2485                	addiw	s1,s1,1
    519c:	ff249ae3          	bne	s1,s2,5190 <execout+0x78>
      close(1);
    51a0:	4505                	li	a0,1
    51a2:	00000097          	auipc	ra,0x0
    51a6:	6da080e7          	jalr	1754(ra) # 587c <close>
      char *args[] = { "echo", "x", 0 };
    51aa:	00001517          	auipc	a0,0x1
    51ae:	00650513          	addi	a0,a0,6 # 61b0 <malloc+0x4ee>
    51b2:	faa43c23          	sd	a0,-72(s0)
    51b6:	00001797          	auipc	a5,0x1
    51ba:	06a78793          	addi	a5,a5,106 # 6220 <malloc+0x55e>
    51be:	fcf43023          	sd	a5,-64(s0)
    51c2:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    51c6:	fb840593          	addi	a1,s0,-72
    51ca:	00000097          	auipc	ra,0x0
    51ce:	6c2080e7          	jalr	1730(ra) # 588c <exec>
      exit(0);
    51d2:	4501                	li	a0,0
    51d4:	00000097          	auipc	ra,0x0
    51d8:	680080e7          	jalr	1664(ra) # 5854 <exit>

00000000000051dc <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    51dc:	7139                	addi	sp,sp,-64
    51de:	fc06                	sd	ra,56(sp)
    51e0:	f822                	sd	s0,48(sp)
    51e2:	f426                	sd	s1,40(sp)
    51e4:	f04a                	sd	s2,32(sp)
    51e6:	ec4e                	sd	s3,24(sp)
    51e8:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    51ea:	fc840513          	addi	a0,s0,-56
    51ee:	00000097          	auipc	ra,0x0
    51f2:	676080e7          	jalr	1654(ra) # 5864 <pipe>
    51f6:	06054763          	bltz	a0,5264 <countfree+0x88>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    51fa:	00000097          	auipc	ra,0x0
    51fe:	652080e7          	jalr	1618(ra) # 584c <fork>

  if(pid < 0){
    5202:	06054e63          	bltz	a0,527e <countfree+0xa2>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    5206:	ed51                	bnez	a0,52a2 <countfree+0xc6>
    close(fds[0]);
    5208:	fc842503          	lw	a0,-56(s0)
    520c:	00000097          	auipc	ra,0x0
    5210:	670080e7          	jalr	1648(ra) # 587c <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    5214:	597d                	li	s2,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    5216:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    5218:	00001997          	auipc	s3,0x1
    521c:	00898993          	addi	s3,s3,8 # 6220 <malloc+0x55e>
      uint64 a = (uint64) sbrk(4096);
    5220:	6505                	lui	a0,0x1
    5222:	00000097          	auipc	ra,0x0
    5226:	6ba080e7          	jalr	1722(ra) # 58dc <sbrk>
      if(a == 0xffffffffffffffff){
    522a:	07250763          	beq	a0,s2,5298 <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    522e:	6785                	lui	a5,0x1
    5230:	953e                	add	a0,a0,a5
    5232:	fe950fa3          	sb	s1,-1(a0) # fff <preempt+0x137>
      if(write(fds[1], "x", 1) != 1){
    5236:	8626                	mv	a2,s1
    5238:	85ce                	mv	a1,s3
    523a:	fcc42503          	lw	a0,-52(s0)
    523e:	00000097          	auipc	ra,0x0
    5242:	636080e7          	jalr	1590(ra) # 5874 <write>
    5246:	fc950de3          	beq	a0,s1,5220 <countfree+0x44>
        printf("write() failed in countfree()\n");
    524a:	00003517          	auipc	a0,0x3
    524e:	d3650513          	addi	a0,a0,-714 # 7f80 <malloc+0x22be>
    5252:	00001097          	auipc	ra,0x1
    5256:	9b2080e7          	jalr	-1614(ra) # 5c04 <printf>
        exit(1);
    525a:	4505                	li	a0,1
    525c:	00000097          	auipc	ra,0x0
    5260:	5f8080e7          	jalr	1528(ra) # 5854 <exit>
    printf("pipe() failed in countfree()\n");
    5264:	00003517          	auipc	a0,0x3
    5268:	cdc50513          	addi	a0,a0,-804 # 7f40 <malloc+0x227e>
    526c:	00001097          	auipc	ra,0x1
    5270:	998080e7          	jalr	-1640(ra) # 5c04 <printf>
    exit(1);
    5274:	4505                	li	a0,1
    5276:	00000097          	auipc	ra,0x0
    527a:	5de080e7          	jalr	1502(ra) # 5854 <exit>
    printf("fork failed in countfree()\n");
    527e:	00003517          	auipc	a0,0x3
    5282:	ce250513          	addi	a0,a0,-798 # 7f60 <malloc+0x229e>
    5286:	00001097          	auipc	ra,0x1
    528a:	97e080e7          	jalr	-1666(ra) # 5c04 <printf>
    exit(1);
    528e:	4505                	li	a0,1
    5290:	00000097          	auipc	ra,0x0
    5294:	5c4080e7          	jalr	1476(ra) # 5854 <exit>
      }
    }

    exit(0);
    5298:	4501                	li	a0,0
    529a:	00000097          	auipc	ra,0x0
    529e:	5ba080e7          	jalr	1466(ra) # 5854 <exit>
  }

  close(fds[1]);
    52a2:	fcc42503          	lw	a0,-52(s0)
    52a6:	00000097          	auipc	ra,0x0
    52aa:	5d6080e7          	jalr	1494(ra) # 587c <close>

  int n = 0;
    52ae:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    52b0:	4605                	li	a2,1
    52b2:	fc740593          	addi	a1,s0,-57
    52b6:	fc842503          	lw	a0,-56(s0)
    52ba:	00000097          	auipc	ra,0x0
    52be:	5b2080e7          	jalr	1458(ra) # 586c <read>
    if(cc < 0){
    52c2:	00054563          	bltz	a0,52cc <countfree+0xf0>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    52c6:	c105                	beqz	a0,52e6 <countfree+0x10a>
      break;
    n += 1;
    52c8:	2485                	addiw	s1,s1,1
  while(1){
    52ca:	b7dd                	j	52b0 <countfree+0xd4>
      printf("read() failed in countfree()\n");
    52cc:	00003517          	auipc	a0,0x3
    52d0:	cd450513          	addi	a0,a0,-812 # 7fa0 <malloc+0x22de>
    52d4:	00001097          	auipc	ra,0x1
    52d8:	930080e7          	jalr	-1744(ra) # 5c04 <printf>
      exit(1);
    52dc:	4505                	li	a0,1
    52de:	00000097          	auipc	ra,0x0
    52e2:	576080e7          	jalr	1398(ra) # 5854 <exit>
  }

  close(fds[0]);
    52e6:	fc842503          	lw	a0,-56(s0)
    52ea:	00000097          	auipc	ra,0x0
    52ee:	592080e7          	jalr	1426(ra) # 587c <close>
  wait((int*)0);
    52f2:	4501                	li	a0,0
    52f4:	00000097          	auipc	ra,0x0
    52f8:	568080e7          	jalr	1384(ra) # 585c <wait>
  
  return n;
}
    52fc:	8526                	mv	a0,s1
    52fe:	70e2                	ld	ra,56(sp)
    5300:	7442                	ld	s0,48(sp)
    5302:	74a2                	ld	s1,40(sp)
    5304:	7902                	ld	s2,32(sp)
    5306:	69e2                	ld	s3,24(sp)
    5308:	6121                	addi	sp,sp,64
    530a:	8082                	ret

000000000000530c <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    530c:	7179                	addi	sp,sp,-48
    530e:	f406                	sd	ra,40(sp)
    5310:	f022                	sd	s0,32(sp)
    5312:	ec26                	sd	s1,24(sp)
    5314:	e84a                	sd	s2,16(sp)
    5316:	1800                	addi	s0,sp,48
    5318:	84aa                	mv	s1,a0
    531a:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    531c:	00003517          	auipc	a0,0x3
    5320:	ca450513          	addi	a0,a0,-860 # 7fc0 <malloc+0x22fe>
    5324:	00001097          	auipc	ra,0x1
    5328:	8e0080e7          	jalr	-1824(ra) # 5c04 <printf>
  if((pid = fork()) < 0) {
    532c:	00000097          	auipc	ra,0x0
    5330:	520080e7          	jalr	1312(ra) # 584c <fork>
    5334:	02054e63          	bltz	a0,5370 <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    5338:	c929                	beqz	a0,538a <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    533a:	fdc40513          	addi	a0,s0,-36
    533e:	00000097          	auipc	ra,0x0
    5342:	51e080e7          	jalr	1310(ra) # 585c <wait>
    if(xstatus != 0) 
    5346:	fdc42783          	lw	a5,-36(s0)
    534a:	c7b9                	beqz	a5,5398 <run+0x8c>
      printf("FAILED\n");
    534c:	00003517          	auipc	a0,0x3
    5350:	c9c50513          	addi	a0,a0,-868 # 7fe8 <malloc+0x2326>
    5354:	00001097          	auipc	ra,0x1
    5358:	8b0080e7          	jalr	-1872(ra) # 5c04 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    535c:	fdc42503          	lw	a0,-36(s0)
  }
}
    5360:	00153513          	seqz	a0,a0
    5364:	70a2                	ld	ra,40(sp)
    5366:	7402                	ld	s0,32(sp)
    5368:	64e2                	ld	s1,24(sp)
    536a:	6942                	ld	s2,16(sp)
    536c:	6145                	addi	sp,sp,48
    536e:	8082                	ret
    printf("runtest: fork error\n");
    5370:	00003517          	auipc	a0,0x3
    5374:	c6050513          	addi	a0,a0,-928 # 7fd0 <malloc+0x230e>
    5378:	00001097          	auipc	ra,0x1
    537c:	88c080e7          	jalr	-1908(ra) # 5c04 <printf>
    exit(1);
    5380:	4505                	li	a0,1
    5382:	00000097          	auipc	ra,0x0
    5386:	4d2080e7          	jalr	1234(ra) # 5854 <exit>
    f(s);
    538a:	854a                	mv	a0,s2
    538c:	9482                	jalr	s1
    exit(0);
    538e:	4501                	li	a0,0
    5390:	00000097          	auipc	ra,0x0
    5394:	4c4080e7          	jalr	1220(ra) # 5854 <exit>
      printf("OK\n");
    5398:	00003517          	auipc	a0,0x3
    539c:	c5850513          	addi	a0,a0,-936 # 7ff0 <malloc+0x232e>
    53a0:	00001097          	auipc	ra,0x1
    53a4:	864080e7          	jalr	-1948(ra) # 5c04 <printf>
    53a8:	bf55                	j	535c <run+0x50>

00000000000053aa <main>:

int
main(int argc, char *argv[])
{
    53aa:	d3010113          	addi	sp,sp,-720
    53ae:	2c113423          	sd	ra,712(sp)
    53b2:	2c813023          	sd	s0,704(sp)
    53b6:	2a913c23          	sd	s1,696(sp)
    53ba:	2b213823          	sd	s2,688(sp)
    53be:	2b313423          	sd	s3,680(sp)
    53c2:	2b413023          	sd	s4,672(sp)
    53c6:	29513c23          	sd	s5,664(sp)
    53ca:	29613823          	sd	s6,656(sp)
    53ce:	0d80                	addi	s0,sp,720
    53d0:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    53d2:	4789                	li	a5,2
    53d4:	08f50b63          	beq	a0,a5,546a <main+0xc0>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    53d8:	4785                	li	a5,1
  char *justone = 0;
    53da:	4901                	li	s2,0
  } else if(argc > 1){
    53dc:	0ca7c563          	blt	a5,a0,54a6 <main+0xfc>
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    53e0:	00003797          	auipc	a5,0x3
    53e4:	d2878793          	addi	a5,a5,-728 # 8108 <malloc+0x2446>
    53e8:	d3040713          	addi	a4,s0,-720
    53ec:	00003817          	auipc	a6,0x3
    53f0:	f9c80813          	addi	a6,a6,-100 # 8388 <malloc+0x26c6>
    53f4:	6388                	ld	a0,0(a5)
    53f6:	678c                	ld	a1,8(a5)
    53f8:	6b90                	ld	a2,16(a5)
    53fa:	6f94                	ld	a3,24(a5)
    53fc:	e308                	sd	a0,0(a4)
    53fe:	e70c                	sd	a1,8(a4)
    5400:	eb10                	sd	a2,16(a4)
    5402:	ef14                	sd	a3,24(a4)
    5404:	02078793          	addi	a5,a5,32
    5408:	02070713          	addi	a4,a4,32
    540c:	ff0794e3          	bne	a5,a6,53f4 <main+0x4a>
    5410:	6394                	ld	a3,0(a5)
    5412:	679c                	ld	a5,8(a5)
    5414:	e314                	sd	a3,0(a4)
    5416:	e71c                	sd	a5,8(a4)
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    5418:	00003517          	auipc	a0,0x3
    541c:	c9050513          	addi	a0,a0,-880 # 80a8 <malloc+0x23e6>
    5420:	00000097          	auipc	ra,0x0
    5424:	7e4080e7          	jalr	2020(ra) # 5c04 <printf>
  int free0 = countfree();
    5428:	00000097          	auipc	ra,0x0
    542c:	db4080e7          	jalr	-588(ra) # 51dc <countfree>
    5430:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    5432:	d3843503          	ld	a0,-712(s0)
    5436:	d3040493          	addi	s1,s0,-720
  int fail = 0;
    543a:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    543c:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    543e:	e55d                	bnez	a0,54ec <main+0x142>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    5440:	00000097          	auipc	ra,0x0
    5444:	d9c080e7          	jalr	-612(ra) # 51dc <countfree>
    5448:	85aa                	mv	a1,a0
    544a:	0f455163          	bge	a0,s4,552c <main+0x182>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    544e:	8652                	mv	a2,s4
    5450:	00003517          	auipc	a0,0x3
    5454:	c1050513          	addi	a0,a0,-1008 # 8060 <malloc+0x239e>
    5458:	00000097          	auipc	ra,0x0
    545c:	7ac080e7          	jalr	1964(ra) # 5c04 <printf>
    exit(1);
    5460:	4505                	li	a0,1
    5462:	00000097          	auipc	ra,0x0
    5466:	3f2080e7          	jalr	1010(ra) # 5854 <exit>
    546a:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    546c:	00003597          	auipc	a1,0x3
    5470:	b8c58593          	addi	a1,a1,-1140 # 7ff8 <malloc+0x2336>
    5474:	6488                	ld	a0,8(s1)
    5476:	00000097          	auipc	ra,0x0
    547a:	18c080e7          	jalr	396(ra) # 5602 <strcmp>
    547e:	10050563          	beqz	a0,5588 <main+0x1de>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    5482:	00003597          	auipc	a1,0x3
    5486:	c5e58593          	addi	a1,a1,-930 # 80e0 <malloc+0x241e>
    548a:	6488                	ld	a0,8(s1)
    548c:	00000097          	auipc	ra,0x0
    5490:	176080e7          	jalr	374(ra) # 5602 <strcmp>
    5494:	c97d                	beqz	a0,558a <main+0x1e0>
  } else if(argc == 2 && argv[1][0] != '-'){
    5496:	0084b903          	ld	s2,8(s1)
    549a:	00094703          	lbu	a4,0(s2)
    549e:	02d00793          	li	a5,45
    54a2:	f2f71fe3          	bne	a4,a5,53e0 <main+0x36>
    printf("Usage: usertests [-c] [testname]\n");
    54a6:	00003517          	auipc	a0,0x3
    54aa:	b5a50513          	addi	a0,a0,-1190 # 8000 <malloc+0x233e>
    54ae:	00000097          	auipc	ra,0x0
    54b2:	756080e7          	jalr	1878(ra) # 5c04 <printf>
    exit(1);
    54b6:	4505                	li	a0,1
    54b8:	00000097          	auipc	ra,0x0
    54bc:	39c080e7          	jalr	924(ra) # 5854 <exit>
          exit(1);
    54c0:	4505                	li	a0,1
    54c2:	00000097          	auipc	ra,0x0
    54c6:	392080e7          	jalr	914(ra) # 5854 <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    54ca:	40a905bb          	subw	a1,s2,a0
    54ce:	855a                	mv	a0,s6
    54d0:	00000097          	auipc	ra,0x0
    54d4:	734080e7          	jalr	1844(ra) # 5c04 <printf>
        if(continuous != 2)
    54d8:	09498463          	beq	s3,s4,5560 <main+0x1b6>
          exit(1);
    54dc:	4505                	li	a0,1
    54de:	00000097          	auipc	ra,0x0
    54e2:	376080e7          	jalr	886(ra) # 5854 <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    54e6:	04c1                	addi	s1,s1,16
    54e8:	6488                	ld	a0,8(s1)
    54ea:	c115                	beqz	a0,550e <main+0x164>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    54ec:	00090863          	beqz	s2,54fc <main+0x152>
    54f0:	85ca                	mv	a1,s2
    54f2:	00000097          	auipc	ra,0x0
    54f6:	110080e7          	jalr	272(ra) # 5602 <strcmp>
    54fa:	f575                	bnez	a0,54e6 <main+0x13c>
      if(!run(t->f, t->s))
    54fc:	648c                	ld	a1,8(s1)
    54fe:	6088                	ld	a0,0(s1)
    5500:	00000097          	auipc	ra,0x0
    5504:	e0c080e7          	jalr	-500(ra) # 530c <run>
    5508:	fd79                	bnez	a0,54e6 <main+0x13c>
        fail = 1;
    550a:	89d6                	mv	s3,s5
    550c:	bfe9                	j	54e6 <main+0x13c>
  if(fail){
    550e:	f20989e3          	beqz	s3,5440 <main+0x96>
    printf("SOME TESTS FAILED\n");
    5512:	00003517          	auipc	a0,0x3
    5516:	b3650513          	addi	a0,a0,-1226 # 8048 <malloc+0x2386>
    551a:	00000097          	auipc	ra,0x0
    551e:	6ea080e7          	jalr	1770(ra) # 5c04 <printf>
    exit(1);
    5522:	4505                	li	a0,1
    5524:	00000097          	auipc	ra,0x0
    5528:	330080e7          	jalr	816(ra) # 5854 <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    552c:	00003517          	auipc	a0,0x3
    5530:	b6450513          	addi	a0,a0,-1180 # 8090 <malloc+0x23ce>
    5534:	00000097          	auipc	ra,0x0
    5538:	6d0080e7          	jalr	1744(ra) # 5c04 <printf>
    exit(0);
    553c:	4501                	li	a0,0
    553e:	00000097          	auipc	ra,0x0
    5542:	316080e7          	jalr	790(ra) # 5854 <exit>
        printf("SOME TESTS FAILED\n");
    5546:	8556                	mv	a0,s5
    5548:	00000097          	auipc	ra,0x0
    554c:	6bc080e7          	jalr	1724(ra) # 5c04 <printf>
        if(continuous != 2)
    5550:	f74998e3          	bne	s3,s4,54c0 <main+0x116>
      int free1 = countfree();
    5554:	00000097          	auipc	ra,0x0
    5558:	c88080e7          	jalr	-888(ra) # 51dc <countfree>
      if(free1 < free0){
    555c:	f72547e3          	blt	a0,s2,54ca <main+0x120>
      int free0 = countfree();
    5560:	00000097          	auipc	ra,0x0
    5564:	c7c080e7          	jalr	-900(ra) # 51dc <countfree>
    5568:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    556a:	d3843583          	ld	a1,-712(s0)
    556e:	d1fd                	beqz	a1,5554 <main+0x1aa>
    5570:	d3040493          	addi	s1,s0,-720
        if(!run(t->f, t->s)){
    5574:	6088                	ld	a0,0(s1)
    5576:	00000097          	auipc	ra,0x0
    557a:	d96080e7          	jalr	-618(ra) # 530c <run>
    557e:	d561                	beqz	a0,5546 <main+0x19c>
      for (struct test *t = tests; t->s != 0; t++) {
    5580:	04c1                	addi	s1,s1,16
    5582:	648c                	ld	a1,8(s1)
    5584:	f9e5                	bnez	a1,5574 <main+0x1ca>
    5586:	b7f9                	j	5554 <main+0x1aa>
    continuous = 1;
    5588:	4985                	li	s3,1
  } tests[] = {
    558a:	00003797          	auipc	a5,0x3
    558e:	b7e78793          	addi	a5,a5,-1154 # 8108 <malloc+0x2446>
    5592:	d3040713          	addi	a4,s0,-720
    5596:	00003817          	auipc	a6,0x3
    559a:	df280813          	addi	a6,a6,-526 # 8388 <malloc+0x26c6>
    559e:	6388                	ld	a0,0(a5)
    55a0:	678c                	ld	a1,8(a5)
    55a2:	6b90                	ld	a2,16(a5)
    55a4:	6f94                	ld	a3,24(a5)
    55a6:	e308                	sd	a0,0(a4)
    55a8:	e70c                	sd	a1,8(a4)
    55aa:	eb10                	sd	a2,16(a4)
    55ac:	ef14                	sd	a3,24(a4)
    55ae:	02078793          	addi	a5,a5,32
    55b2:	02070713          	addi	a4,a4,32
    55b6:	ff0794e3          	bne	a5,a6,559e <main+0x1f4>
    55ba:	6394                	ld	a3,0(a5)
    55bc:	679c                	ld	a5,8(a5)
    55be:	e314                	sd	a3,0(a4)
    55c0:	e71c                	sd	a5,8(a4)
    printf("continuous usertests starting\n");
    55c2:	00003517          	auipc	a0,0x3
    55c6:	afe50513          	addi	a0,a0,-1282 # 80c0 <malloc+0x23fe>
    55ca:	00000097          	auipc	ra,0x0
    55ce:	63a080e7          	jalr	1594(ra) # 5c04 <printf>
        printf("SOME TESTS FAILED\n");
    55d2:	00003a97          	auipc	s5,0x3
    55d6:	a76a8a93          	addi	s5,s5,-1418 # 8048 <malloc+0x2386>
        if(continuous != 2)
    55da:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    55dc:	00003b17          	auipc	s6,0x3
    55e0:	a4cb0b13          	addi	s6,s6,-1460 # 8028 <malloc+0x2366>
    55e4:	bfb5                	j	5560 <main+0x1b6>

00000000000055e6 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    55e6:	1141                	addi	sp,sp,-16
    55e8:	e422                	sd	s0,8(sp)
    55ea:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    55ec:	87aa                	mv	a5,a0
    55ee:	0585                	addi	a1,a1,1
    55f0:	0785                	addi	a5,a5,1
    55f2:	fff5c703          	lbu	a4,-1(a1)
    55f6:	fee78fa3          	sb	a4,-1(a5)
    55fa:	fb75                	bnez	a4,55ee <strcpy+0x8>
    ;
  return os;
}
    55fc:	6422                	ld	s0,8(sp)
    55fe:	0141                	addi	sp,sp,16
    5600:	8082                	ret

0000000000005602 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    5602:	1141                	addi	sp,sp,-16
    5604:	e422                	sd	s0,8(sp)
    5606:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    5608:	00054783          	lbu	a5,0(a0)
    560c:	cb91                	beqz	a5,5620 <strcmp+0x1e>
    560e:	0005c703          	lbu	a4,0(a1)
    5612:	00f71763          	bne	a4,a5,5620 <strcmp+0x1e>
    p++, q++;
    5616:	0505                	addi	a0,a0,1
    5618:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    561a:	00054783          	lbu	a5,0(a0)
    561e:	fbe5                	bnez	a5,560e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    5620:	0005c503          	lbu	a0,0(a1)
}
    5624:	40a7853b          	subw	a0,a5,a0
    5628:	6422                	ld	s0,8(sp)
    562a:	0141                	addi	sp,sp,16
    562c:	8082                	ret

000000000000562e <strlen>:

uint
strlen(const char *s)
{
    562e:	1141                	addi	sp,sp,-16
    5630:	e422                	sd	s0,8(sp)
    5632:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    5634:	00054783          	lbu	a5,0(a0)
    5638:	cf91                	beqz	a5,5654 <strlen+0x26>
    563a:	0505                	addi	a0,a0,1
    563c:	87aa                	mv	a5,a0
    563e:	4685                	li	a3,1
    5640:	9e89                	subw	a3,a3,a0
    5642:	00f6853b          	addw	a0,a3,a5
    5646:	0785                	addi	a5,a5,1
    5648:	fff7c703          	lbu	a4,-1(a5)
    564c:	fb7d                	bnez	a4,5642 <strlen+0x14>
    ;
  return n;
}
    564e:	6422                	ld	s0,8(sp)
    5650:	0141                	addi	sp,sp,16
    5652:	8082                	ret
  for(n = 0; s[n]; n++)
    5654:	4501                	li	a0,0
    5656:	bfe5                	j	564e <strlen+0x20>

0000000000005658 <memset>:

void*
memset(void *dst, int c, uint n)
{
    5658:	1141                	addi	sp,sp,-16
    565a:	e422                	sd	s0,8(sp)
    565c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    565e:	ca19                	beqz	a2,5674 <memset+0x1c>
    5660:	87aa                	mv	a5,a0
    5662:	1602                	slli	a2,a2,0x20
    5664:	9201                	srli	a2,a2,0x20
    5666:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    566a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    566e:	0785                	addi	a5,a5,1
    5670:	fee79de3          	bne	a5,a4,566a <memset+0x12>
  }
  return dst;
}
    5674:	6422                	ld	s0,8(sp)
    5676:	0141                	addi	sp,sp,16
    5678:	8082                	ret

000000000000567a <strchr>:

char*
strchr(const char *s, char c)
{
    567a:	1141                	addi	sp,sp,-16
    567c:	e422                	sd	s0,8(sp)
    567e:	0800                	addi	s0,sp,16
  for(; *s; s++)
    5680:	00054783          	lbu	a5,0(a0)
    5684:	cb99                	beqz	a5,569a <strchr+0x20>
    if(*s == c)
    5686:	00f58763          	beq	a1,a5,5694 <strchr+0x1a>
  for(; *s; s++)
    568a:	0505                	addi	a0,a0,1
    568c:	00054783          	lbu	a5,0(a0)
    5690:	fbfd                	bnez	a5,5686 <strchr+0xc>
      return (char*)s;
  return 0;
    5692:	4501                	li	a0,0
}
    5694:	6422                	ld	s0,8(sp)
    5696:	0141                	addi	sp,sp,16
    5698:	8082                	ret
  return 0;
    569a:	4501                	li	a0,0
    569c:	bfe5                	j	5694 <strchr+0x1a>

000000000000569e <gets>:

char*
gets(char *buf, int max)
{
    569e:	711d                	addi	sp,sp,-96
    56a0:	ec86                	sd	ra,88(sp)
    56a2:	e8a2                	sd	s0,80(sp)
    56a4:	e4a6                	sd	s1,72(sp)
    56a6:	e0ca                	sd	s2,64(sp)
    56a8:	fc4e                	sd	s3,56(sp)
    56aa:	f852                	sd	s4,48(sp)
    56ac:	f456                	sd	s5,40(sp)
    56ae:	f05a                	sd	s6,32(sp)
    56b0:	ec5e                	sd	s7,24(sp)
    56b2:	1080                	addi	s0,sp,96
    56b4:	8baa                	mv	s7,a0
    56b6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    56b8:	892a                	mv	s2,a0
    56ba:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    56bc:	4aa9                	li	s5,10
    56be:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    56c0:	89a6                	mv	s3,s1
    56c2:	2485                	addiw	s1,s1,1
    56c4:	0344d863          	bge	s1,s4,56f4 <gets+0x56>
    cc = read(0, &c, 1);
    56c8:	4605                	li	a2,1
    56ca:	faf40593          	addi	a1,s0,-81
    56ce:	4501                	li	a0,0
    56d0:	00000097          	auipc	ra,0x0
    56d4:	19c080e7          	jalr	412(ra) # 586c <read>
    if(cc < 1)
    56d8:	00a05e63          	blez	a0,56f4 <gets+0x56>
    buf[i++] = c;
    56dc:	faf44783          	lbu	a5,-81(s0)
    56e0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    56e4:	01578763          	beq	a5,s5,56f2 <gets+0x54>
    56e8:	0905                	addi	s2,s2,1
    56ea:	fd679be3          	bne	a5,s6,56c0 <gets+0x22>
  for(i=0; i+1 < max; ){
    56ee:	89a6                	mv	s3,s1
    56f0:	a011                	j	56f4 <gets+0x56>
    56f2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    56f4:	99de                	add	s3,s3,s7
    56f6:	00098023          	sb	zero,0(s3)
  return buf;
}
    56fa:	855e                	mv	a0,s7
    56fc:	60e6                	ld	ra,88(sp)
    56fe:	6446                	ld	s0,80(sp)
    5700:	64a6                	ld	s1,72(sp)
    5702:	6906                	ld	s2,64(sp)
    5704:	79e2                	ld	s3,56(sp)
    5706:	7a42                	ld	s4,48(sp)
    5708:	7aa2                	ld	s5,40(sp)
    570a:	7b02                	ld	s6,32(sp)
    570c:	6be2                	ld	s7,24(sp)
    570e:	6125                	addi	sp,sp,96
    5710:	8082                	ret

0000000000005712 <stat>:

int
stat(const char *n, struct stat *st)
{
    5712:	1101                	addi	sp,sp,-32
    5714:	ec06                	sd	ra,24(sp)
    5716:	e822                	sd	s0,16(sp)
    5718:	e426                	sd	s1,8(sp)
    571a:	e04a                	sd	s2,0(sp)
    571c:	1000                	addi	s0,sp,32
    571e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    5720:	4581                	li	a1,0
    5722:	00000097          	auipc	ra,0x0
    5726:	172080e7          	jalr	370(ra) # 5894 <open>
  if(fd < 0)
    572a:	02054563          	bltz	a0,5754 <stat+0x42>
    572e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5730:	85ca                	mv	a1,s2
    5732:	00000097          	auipc	ra,0x0
    5736:	17a080e7          	jalr	378(ra) # 58ac <fstat>
    573a:	892a                	mv	s2,a0
  close(fd);
    573c:	8526                	mv	a0,s1
    573e:	00000097          	auipc	ra,0x0
    5742:	13e080e7          	jalr	318(ra) # 587c <close>
  return r;
}
    5746:	854a                	mv	a0,s2
    5748:	60e2                	ld	ra,24(sp)
    574a:	6442                	ld	s0,16(sp)
    574c:	64a2                	ld	s1,8(sp)
    574e:	6902                	ld	s2,0(sp)
    5750:	6105                	addi	sp,sp,32
    5752:	8082                	ret
    return -1;
    5754:	597d                	li	s2,-1
    5756:	bfc5                	j	5746 <stat+0x34>

0000000000005758 <atoi>:

int
atoi(const char *s)
{
    5758:	1141                	addi	sp,sp,-16
    575a:	e422                	sd	s0,8(sp)
    575c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    575e:	00054603          	lbu	a2,0(a0)
    5762:	fd06079b          	addiw	a5,a2,-48
    5766:	0ff7f793          	andi	a5,a5,255
    576a:	4725                	li	a4,9
    576c:	02f76963          	bltu	a4,a5,579e <atoi+0x46>
    5770:	86aa                	mv	a3,a0
  n = 0;
    5772:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    5774:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    5776:	0685                	addi	a3,a3,1
    5778:	0025179b          	slliw	a5,a0,0x2
    577c:	9fa9                	addw	a5,a5,a0
    577e:	0017979b          	slliw	a5,a5,0x1
    5782:	9fb1                	addw	a5,a5,a2
    5784:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5788:	0006c603          	lbu	a2,0(a3)
    578c:	fd06071b          	addiw	a4,a2,-48
    5790:	0ff77713          	andi	a4,a4,255
    5794:	fee5f1e3          	bgeu	a1,a4,5776 <atoi+0x1e>
  return n;
}
    5798:	6422                	ld	s0,8(sp)
    579a:	0141                	addi	sp,sp,16
    579c:	8082                	ret
  n = 0;
    579e:	4501                	li	a0,0
    57a0:	bfe5                	j	5798 <atoi+0x40>

00000000000057a2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    57a2:	1141                	addi	sp,sp,-16
    57a4:	e422                	sd	s0,8(sp)
    57a6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    57a8:	02b57463          	bgeu	a0,a1,57d0 <memmove+0x2e>
    while(n-- > 0)
    57ac:	00c05f63          	blez	a2,57ca <memmove+0x28>
    57b0:	1602                	slli	a2,a2,0x20
    57b2:	9201                	srli	a2,a2,0x20
    57b4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    57b8:	872a                	mv	a4,a0
      *dst++ = *src++;
    57ba:	0585                	addi	a1,a1,1
    57bc:	0705                	addi	a4,a4,1
    57be:	fff5c683          	lbu	a3,-1(a1)
    57c2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    57c6:	fee79ae3          	bne	a5,a4,57ba <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    57ca:	6422                	ld	s0,8(sp)
    57cc:	0141                	addi	sp,sp,16
    57ce:	8082                	ret
    dst += n;
    57d0:	00c50733          	add	a4,a0,a2
    src += n;
    57d4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    57d6:	fec05ae3          	blez	a2,57ca <memmove+0x28>
    57da:	fff6079b          	addiw	a5,a2,-1
    57de:	1782                	slli	a5,a5,0x20
    57e0:	9381                	srli	a5,a5,0x20
    57e2:	fff7c793          	not	a5,a5
    57e6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    57e8:	15fd                	addi	a1,a1,-1
    57ea:	177d                	addi	a4,a4,-1
    57ec:	0005c683          	lbu	a3,0(a1)
    57f0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    57f4:	fee79ae3          	bne	a5,a4,57e8 <memmove+0x46>
    57f8:	bfc9                	j	57ca <memmove+0x28>

00000000000057fa <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    57fa:	1141                	addi	sp,sp,-16
    57fc:	e422                	sd	s0,8(sp)
    57fe:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5800:	ca05                	beqz	a2,5830 <memcmp+0x36>
    5802:	fff6069b          	addiw	a3,a2,-1
    5806:	1682                	slli	a3,a3,0x20
    5808:	9281                	srli	a3,a3,0x20
    580a:	0685                	addi	a3,a3,1
    580c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    580e:	00054783          	lbu	a5,0(a0)
    5812:	0005c703          	lbu	a4,0(a1)
    5816:	00e79863          	bne	a5,a4,5826 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    581a:	0505                	addi	a0,a0,1
    p2++;
    581c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    581e:	fed518e3          	bne	a0,a3,580e <memcmp+0x14>
  }
  return 0;
    5822:	4501                	li	a0,0
    5824:	a019                	j	582a <memcmp+0x30>
      return *p1 - *p2;
    5826:	40e7853b          	subw	a0,a5,a4
}
    582a:	6422                	ld	s0,8(sp)
    582c:	0141                	addi	sp,sp,16
    582e:	8082                	ret
  return 0;
    5830:	4501                	li	a0,0
    5832:	bfe5                	j	582a <memcmp+0x30>

0000000000005834 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    5834:	1141                	addi	sp,sp,-16
    5836:	e406                	sd	ra,8(sp)
    5838:	e022                	sd	s0,0(sp)
    583a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    583c:	00000097          	auipc	ra,0x0
    5840:	f66080e7          	jalr	-154(ra) # 57a2 <memmove>
}
    5844:	60a2                	ld	ra,8(sp)
    5846:	6402                	ld	s0,0(sp)
    5848:	0141                	addi	sp,sp,16
    584a:	8082                	ret

000000000000584c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    584c:	4885                	li	a7,1
 ecall
    584e:	00000073          	ecall
 ret
    5852:	8082                	ret

0000000000005854 <exit>:
.global exit
exit:
 li a7, SYS_exit
    5854:	4889                	li	a7,2
 ecall
    5856:	00000073          	ecall
 ret
    585a:	8082                	ret

000000000000585c <wait>:
.global wait
wait:
 li a7, SYS_wait
    585c:	488d                	li	a7,3
 ecall
    585e:	00000073          	ecall
 ret
    5862:	8082                	ret

0000000000005864 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5864:	4891                	li	a7,4
 ecall
    5866:	00000073          	ecall
 ret
    586a:	8082                	ret

000000000000586c <read>:
.global read
read:
 li a7, SYS_read
    586c:	4895                	li	a7,5
 ecall
    586e:	00000073          	ecall
 ret
    5872:	8082                	ret

0000000000005874 <write>:
.global write
write:
 li a7, SYS_write
    5874:	48c1                	li	a7,16
 ecall
    5876:	00000073          	ecall
 ret
    587a:	8082                	ret

000000000000587c <close>:
.global close
close:
 li a7, SYS_close
    587c:	48d5                	li	a7,21
 ecall
    587e:	00000073          	ecall
 ret
    5882:	8082                	ret

0000000000005884 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5884:	4899                	li	a7,6
 ecall
    5886:	00000073          	ecall
 ret
    588a:	8082                	ret

000000000000588c <exec>:
.global exec
exec:
 li a7, SYS_exec
    588c:	489d                	li	a7,7
 ecall
    588e:	00000073          	ecall
 ret
    5892:	8082                	ret

0000000000005894 <open>:
.global open
open:
 li a7, SYS_open
    5894:	48bd                	li	a7,15
 ecall
    5896:	00000073          	ecall
 ret
    589a:	8082                	ret

000000000000589c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    589c:	48c5                	li	a7,17
 ecall
    589e:	00000073          	ecall
 ret
    58a2:	8082                	ret

00000000000058a4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    58a4:	48c9                	li	a7,18
 ecall
    58a6:	00000073          	ecall
 ret
    58aa:	8082                	ret

00000000000058ac <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    58ac:	48a1                	li	a7,8
 ecall
    58ae:	00000073          	ecall
 ret
    58b2:	8082                	ret

00000000000058b4 <link>:
.global link
link:
 li a7, SYS_link
    58b4:	48cd                	li	a7,19
 ecall
    58b6:	00000073          	ecall
 ret
    58ba:	8082                	ret

00000000000058bc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    58bc:	48d1                	li	a7,20
 ecall
    58be:	00000073          	ecall
 ret
    58c2:	8082                	ret

00000000000058c4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    58c4:	48a5                	li	a7,9
 ecall
    58c6:	00000073          	ecall
 ret
    58ca:	8082                	ret

00000000000058cc <dup>:
.global dup
dup:
 li a7, SYS_dup
    58cc:	48a9                	li	a7,10
 ecall
    58ce:	00000073          	ecall
 ret
    58d2:	8082                	ret

00000000000058d4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    58d4:	48ad                	li	a7,11
 ecall
    58d6:	00000073          	ecall
 ret
    58da:	8082                	ret

00000000000058dc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    58dc:	48b1                	li	a7,12
 ecall
    58de:	00000073          	ecall
 ret
    58e2:	8082                	ret

00000000000058e4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    58e4:	48b5                	li	a7,13
 ecall
    58e6:	00000073          	ecall
 ret
    58ea:	8082                	ret

00000000000058ec <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    58ec:	48b9                	li	a7,14
 ecall
    58ee:	00000073          	ecall
 ret
    58f2:	8082                	ret

00000000000058f4 <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
    58f4:	48d9                	li	a7,22
 ecall
    58f6:	00000073          	ecall
 ret
    58fa:	8082                	ret

00000000000058fc <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
    58fc:	48dd                	li	a7,23
 ecall
    58fe:	00000073          	ecall
 ret
    5902:	8082                	ret

0000000000005904 <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
    5904:	48e1                	li	a7,24
 ecall
    5906:	00000073          	ecall
 ret
    590a:	8082                	ret

000000000000590c <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
    590c:	48e5                	li	a7,25
 ecall
    590e:	00000073          	ecall
 ret
    5912:	8082                	ret

0000000000005914 <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
    5914:	48e9                	li	a7,26
 ecall
    5916:	00000073          	ecall
 ret
    591a:	8082                	ret

000000000000591c <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
    591c:	48ed                	li	a7,27
 ecall
    591e:	00000073          	ecall
 ret
    5922:	8082                	ret

0000000000005924 <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
    5924:	48f1                	li	a7,28
 ecall
    5926:	00000073          	ecall
 ret
    592a:	8082                	ret

000000000000592c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    592c:	1101                	addi	sp,sp,-32
    592e:	ec06                	sd	ra,24(sp)
    5930:	e822                	sd	s0,16(sp)
    5932:	1000                	addi	s0,sp,32
    5934:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5938:	4605                	li	a2,1
    593a:	fef40593          	addi	a1,s0,-17
    593e:	00000097          	auipc	ra,0x0
    5942:	f36080e7          	jalr	-202(ra) # 5874 <write>
}
    5946:	60e2                	ld	ra,24(sp)
    5948:	6442                	ld	s0,16(sp)
    594a:	6105                	addi	sp,sp,32
    594c:	8082                	ret

000000000000594e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    594e:	7139                	addi	sp,sp,-64
    5950:	fc06                	sd	ra,56(sp)
    5952:	f822                	sd	s0,48(sp)
    5954:	f426                	sd	s1,40(sp)
    5956:	f04a                	sd	s2,32(sp)
    5958:	ec4e                	sd	s3,24(sp)
    595a:	0080                	addi	s0,sp,64
    595c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    595e:	c299                	beqz	a3,5964 <printint+0x16>
    5960:	0805c863          	bltz	a1,59f0 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    5964:	2581                	sext.w	a1,a1
  neg = 0;
    5966:	4881                	li	a7,0
    5968:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    596c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    596e:	2601                	sext.w	a2,a2
    5970:	00003517          	auipc	a0,0x3
    5974:	a3050513          	addi	a0,a0,-1488 # 83a0 <digits>
    5978:	883a                	mv	a6,a4
    597a:	2705                	addiw	a4,a4,1
    597c:	02c5f7bb          	remuw	a5,a1,a2
    5980:	1782                	slli	a5,a5,0x20
    5982:	9381                	srli	a5,a5,0x20
    5984:	97aa                	add	a5,a5,a0
    5986:	0007c783          	lbu	a5,0(a5)
    598a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    598e:	0005879b          	sext.w	a5,a1
    5992:	02c5d5bb          	divuw	a1,a1,a2
    5996:	0685                	addi	a3,a3,1
    5998:	fec7f0e3          	bgeu	a5,a2,5978 <printint+0x2a>
  if(neg)
    599c:	00088b63          	beqz	a7,59b2 <printint+0x64>
    buf[i++] = '-';
    59a0:	fd040793          	addi	a5,s0,-48
    59a4:	973e                	add	a4,a4,a5
    59a6:	02d00793          	li	a5,45
    59aa:	fef70823          	sb	a5,-16(a4)
    59ae:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    59b2:	02e05863          	blez	a4,59e2 <printint+0x94>
    59b6:	fc040793          	addi	a5,s0,-64
    59ba:	00e78933          	add	s2,a5,a4
    59be:	fff78993          	addi	s3,a5,-1
    59c2:	99ba                	add	s3,s3,a4
    59c4:	377d                	addiw	a4,a4,-1
    59c6:	1702                	slli	a4,a4,0x20
    59c8:	9301                	srli	a4,a4,0x20
    59ca:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    59ce:	fff94583          	lbu	a1,-1(s2)
    59d2:	8526                	mv	a0,s1
    59d4:	00000097          	auipc	ra,0x0
    59d8:	f58080e7          	jalr	-168(ra) # 592c <putc>
  while(--i >= 0)
    59dc:	197d                	addi	s2,s2,-1
    59de:	ff3918e3          	bne	s2,s3,59ce <printint+0x80>
}
    59e2:	70e2                	ld	ra,56(sp)
    59e4:	7442                	ld	s0,48(sp)
    59e6:	74a2                	ld	s1,40(sp)
    59e8:	7902                	ld	s2,32(sp)
    59ea:	69e2                	ld	s3,24(sp)
    59ec:	6121                	addi	sp,sp,64
    59ee:	8082                	ret
    x = -xx;
    59f0:	40b005bb          	negw	a1,a1
    neg = 1;
    59f4:	4885                	li	a7,1
    x = -xx;
    59f6:	bf8d                	j	5968 <printint+0x1a>

00000000000059f8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    59f8:	7119                	addi	sp,sp,-128
    59fa:	fc86                	sd	ra,120(sp)
    59fc:	f8a2                	sd	s0,112(sp)
    59fe:	f4a6                	sd	s1,104(sp)
    5a00:	f0ca                	sd	s2,96(sp)
    5a02:	ecce                	sd	s3,88(sp)
    5a04:	e8d2                	sd	s4,80(sp)
    5a06:	e4d6                	sd	s5,72(sp)
    5a08:	e0da                	sd	s6,64(sp)
    5a0a:	fc5e                	sd	s7,56(sp)
    5a0c:	f862                	sd	s8,48(sp)
    5a0e:	f466                	sd	s9,40(sp)
    5a10:	f06a                	sd	s10,32(sp)
    5a12:	ec6e                	sd	s11,24(sp)
    5a14:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    5a16:	0005c903          	lbu	s2,0(a1)
    5a1a:	18090f63          	beqz	s2,5bb8 <vprintf+0x1c0>
    5a1e:	8aaa                	mv	s5,a0
    5a20:	8b32                	mv	s6,a2
    5a22:	00158493          	addi	s1,a1,1
  state = 0;
    5a26:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    5a28:	02500a13          	li	s4,37
      if(c == 'd'){
    5a2c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    5a30:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    5a34:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    5a38:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5a3c:	00003b97          	auipc	s7,0x3
    5a40:	964b8b93          	addi	s7,s7,-1692 # 83a0 <digits>
    5a44:	a839                	j	5a62 <vprintf+0x6a>
        putc(fd, c);
    5a46:	85ca                	mv	a1,s2
    5a48:	8556                	mv	a0,s5
    5a4a:	00000097          	auipc	ra,0x0
    5a4e:	ee2080e7          	jalr	-286(ra) # 592c <putc>
    5a52:	a019                	j	5a58 <vprintf+0x60>
    } else if(state == '%'){
    5a54:	01498f63          	beq	s3,s4,5a72 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    5a58:	0485                	addi	s1,s1,1
    5a5a:	fff4c903          	lbu	s2,-1(s1)
    5a5e:	14090d63          	beqz	s2,5bb8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    5a62:	0009079b          	sext.w	a5,s2
    if(state == 0){
    5a66:	fe0997e3          	bnez	s3,5a54 <vprintf+0x5c>
      if(c == '%'){
    5a6a:	fd479ee3          	bne	a5,s4,5a46 <vprintf+0x4e>
        state = '%';
    5a6e:	89be                	mv	s3,a5
    5a70:	b7e5                	j	5a58 <vprintf+0x60>
      if(c == 'd'){
    5a72:	05878063          	beq	a5,s8,5ab2 <vprintf+0xba>
      } else if(c == 'l') {
    5a76:	05978c63          	beq	a5,s9,5ace <vprintf+0xd6>
      } else if(c == 'x') {
    5a7a:	07a78863          	beq	a5,s10,5aea <vprintf+0xf2>
      } else if(c == 'p') {
    5a7e:	09b78463          	beq	a5,s11,5b06 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    5a82:	07300713          	li	a4,115
    5a86:	0ce78663          	beq	a5,a4,5b52 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    5a8a:	06300713          	li	a4,99
    5a8e:	0ee78e63          	beq	a5,a4,5b8a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    5a92:	11478863          	beq	a5,s4,5ba2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    5a96:	85d2                	mv	a1,s4
    5a98:	8556                	mv	a0,s5
    5a9a:	00000097          	auipc	ra,0x0
    5a9e:	e92080e7          	jalr	-366(ra) # 592c <putc>
        putc(fd, c);
    5aa2:	85ca                	mv	a1,s2
    5aa4:	8556                	mv	a0,s5
    5aa6:	00000097          	auipc	ra,0x0
    5aaa:	e86080e7          	jalr	-378(ra) # 592c <putc>
      }
      state = 0;
    5aae:	4981                	li	s3,0
    5ab0:	b765                	j	5a58 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5ab2:	008b0913          	addi	s2,s6,8
    5ab6:	4685                	li	a3,1
    5ab8:	4629                	li	a2,10
    5aba:	000b2583          	lw	a1,0(s6)
    5abe:	8556                	mv	a0,s5
    5ac0:	00000097          	auipc	ra,0x0
    5ac4:	e8e080e7          	jalr	-370(ra) # 594e <printint>
    5ac8:	8b4a                	mv	s6,s2
      state = 0;
    5aca:	4981                	li	s3,0
    5acc:	b771                	j	5a58 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5ace:	008b0913          	addi	s2,s6,8
    5ad2:	4681                	li	a3,0
    5ad4:	4629                	li	a2,10
    5ad6:	000b2583          	lw	a1,0(s6)
    5ada:	8556                	mv	a0,s5
    5adc:	00000097          	auipc	ra,0x0
    5ae0:	e72080e7          	jalr	-398(ra) # 594e <printint>
    5ae4:	8b4a                	mv	s6,s2
      state = 0;
    5ae6:	4981                	li	s3,0
    5ae8:	bf85                	j	5a58 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5aea:	008b0913          	addi	s2,s6,8
    5aee:	4681                	li	a3,0
    5af0:	4641                	li	a2,16
    5af2:	000b2583          	lw	a1,0(s6)
    5af6:	8556                	mv	a0,s5
    5af8:	00000097          	auipc	ra,0x0
    5afc:	e56080e7          	jalr	-426(ra) # 594e <printint>
    5b00:	8b4a                	mv	s6,s2
      state = 0;
    5b02:	4981                	li	s3,0
    5b04:	bf91                	j	5a58 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5b06:	008b0793          	addi	a5,s6,8
    5b0a:	f8f43423          	sd	a5,-120(s0)
    5b0e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5b12:	03000593          	li	a1,48
    5b16:	8556                	mv	a0,s5
    5b18:	00000097          	auipc	ra,0x0
    5b1c:	e14080e7          	jalr	-492(ra) # 592c <putc>
  putc(fd, 'x');
    5b20:	85ea                	mv	a1,s10
    5b22:	8556                	mv	a0,s5
    5b24:	00000097          	auipc	ra,0x0
    5b28:	e08080e7          	jalr	-504(ra) # 592c <putc>
    5b2c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5b2e:	03c9d793          	srli	a5,s3,0x3c
    5b32:	97de                	add	a5,a5,s7
    5b34:	0007c583          	lbu	a1,0(a5)
    5b38:	8556                	mv	a0,s5
    5b3a:	00000097          	auipc	ra,0x0
    5b3e:	df2080e7          	jalr	-526(ra) # 592c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5b42:	0992                	slli	s3,s3,0x4
    5b44:	397d                	addiw	s2,s2,-1
    5b46:	fe0914e3          	bnez	s2,5b2e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    5b4a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5b4e:	4981                	li	s3,0
    5b50:	b721                	j	5a58 <vprintf+0x60>
        s = va_arg(ap, char*);
    5b52:	008b0993          	addi	s3,s6,8
    5b56:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    5b5a:	02090163          	beqz	s2,5b7c <vprintf+0x184>
        while(*s != 0){
    5b5e:	00094583          	lbu	a1,0(s2)
    5b62:	c9a1                	beqz	a1,5bb2 <vprintf+0x1ba>
          putc(fd, *s);
    5b64:	8556                	mv	a0,s5
    5b66:	00000097          	auipc	ra,0x0
    5b6a:	dc6080e7          	jalr	-570(ra) # 592c <putc>
          s++;
    5b6e:	0905                	addi	s2,s2,1
        while(*s != 0){
    5b70:	00094583          	lbu	a1,0(s2)
    5b74:	f9e5                	bnez	a1,5b64 <vprintf+0x16c>
        s = va_arg(ap, char*);
    5b76:	8b4e                	mv	s6,s3
      state = 0;
    5b78:	4981                	li	s3,0
    5b7a:	bdf9                	j	5a58 <vprintf+0x60>
          s = "(null)";
    5b7c:	00003917          	auipc	s2,0x3
    5b80:	81c90913          	addi	s2,s2,-2020 # 8398 <malloc+0x26d6>
        while(*s != 0){
    5b84:	02800593          	li	a1,40
    5b88:	bff1                	j	5b64 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    5b8a:	008b0913          	addi	s2,s6,8
    5b8e:	000b4583          	lbu	a1,0(s6)
    5b92:	8556                	mv	a0,s5
    5b94:	00000097          	auipc	ra,0x0
    5b98:	d98080e7          	jalr	-616(ra) # 592c <putc>
    5b9c:	8b4a                	mv	s6,s2
      state = 0;
    5b9e:	4981                	li	s3,0
    5ba0:	bd65                	j	5a58 <vprintf+0x60>
        putc(fd, c);
    5ba2:	85d2                	mv	a1,s4
    5ba4:	8556                	mv	a0,s5
    5ba6:	00000097          	auipc	ra,0x0
    5baa:	d86080e7          	jalr	-634(ra) # 592c <putc>
      state = 0;
    5bae:	4981                	li	s3,0
    5bb0:	b565                	j	5a58 <vprintf+0x60>
        s = va_arg(ap, char*);
    5bb2:	8b4e                	mv	s6,s3
      state = 0;
    5bb4:	4981                	li	s3,0
    5bb6:	b54d                	j	5a58 <vprintf+0x60>
    }
  }
}
    5bb8:	70e6                	ld	ra,120(sp)
    5bba:	7446                	ld	s0,112(sp)
    5bbc:	74a6                	ld	s1,104(sp)
    5bbe:	7906                	ld	s2,96(sp)
    5bc0:	69e6                	ld	s3,88(sp)
    5bc2:	6a46                	ld	s4,80(sp)
    5bc4:	6aa6                	ld	s5,72(sp)
    5bc6:	6b06                	ld	s6,64(sp)
    5bc8:	7be2                	ld	s7,56(sp)
    5bca:	7c42                	ld	s8,48(sp)
    5bcc:	7ca2                	ld	s9,40(sp)
    5bce:	7d02                	ld	s10,32(sp)
    5bd0:	6de2                	ld	s11,24(sp)
    5bd2:	6109                	addi	sp,sp,128
    5bd4:	8082                	ret

0000000000005bd6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5bd6:	715d                	addi	sp,sp,-80
    5bd8:	ec06                	sd	ra,24(sp)
    5bda:	e822                	sd	s0,16(sp)
    5bdc:	1000                	addi	s0,sp,32
    5bde:	e010                	sd	a2,0(s0)
    5be0:	e414                	sd	a3,8(s0)
    5be2:	e818                	sd	a4,16(s0)
    5be4:	ec1c                	sd	a5,24(s0)
    5be6:	03043023          	sd	a6,32(s0)
    5bea:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5bee:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5bf2:	8622                	mv	a2,s0
    5bf4:	00000097          	auipc	ra,0x0
    5bf8:	e04080e7          	jalr	-508(ra) # 59f8 <vprintf>
}
    5bfc:	60e2                	ld	ra,24(sp)
    5bfe:	6442                	ld	s0,16(sp)
    5c00:	6161                	addi	sp,sp,80
    5c02:	8082                	ret

0000000000005c04 <printf>:

void
printf(const char *fmt, ...)
{
    5c04:	711d                	addi	sp,sp,-96
    5c06:	ec06                	sd	ra,24(sp)
    5c08:	e822                	sd	s0,16(sp)
    5c0a:	1000                	addi	s0,sp,32
    5c0c:	e40c                	sd	a1,8(s0)
    5c0e:	e810                	sd	a2,16(s0)
    5c10:	ec14                	sd	a3,24(s0)
    5c12:	f018                	sd	a4,32(s0)
    5c14:	f41c                	sd	a5,40(s0)
    5c16:	03043823          	sd	a6,48(s0)
    5c1a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5c1e:	00840613          	addi	a2,s0,8
    5c22:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5c26:	85aa                	mv	a1,a0
    5c28:	4505                	li	a0,1
    5c2a:	00000097          	auipc	ra,0x0
    5c2e:	dce080e7          	jalr	-562(ra) # 59f8 <vprintf>
}
    5c32:	60e2                	ld	ra,24(sp)
    5c34:	6442                	ld	s0,16(sp)
    5c36:	6125                	addi	sp,sp,96
    5c38:	8082                	ret

0000000000005c3a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5c3a:	1141                	addi	sp,sp,-16
    5c3c:	e422                	sd	s0,8(sp)
    5c3e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5c40:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5c44:	00002797          	auipc	a5,0x2
    5c48:	78c7b783          	ld	a5,1932(a5) # 83d0 <freep>
    5c4c:	a805                	j	5c7c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5c4e:	4618                	lw	a4,8(a2)
    5c50:	9db9                	addw	a1,a1,a4
    5c52:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5c56:	6398                	ld	a4,0(a5)
    5c58:	6318                	ld	a4,0(a4)
    5c5a:	fee53823          	sd	a4,-16(a0)
    5c5e:	a091                	j	5ca2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5c60:	ff852703          	lw	a4,-8(a0)
    5c64:	9e39                	addw	a2,a2,a4
    5c66:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    5c68:	ff053703          	ld	a4,-16(a0)
    5c6c:	e398                	sd	a4,0(a5)
    5c6e:	a099                	j	5cb4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5c70:	6398                	ld	a4,0(a5)
    5c72:	00e7e463          	bltu	a5,a4,5c7a <free+0x40>
    5c76:	00e6ea63          	bltu	a3,a4,5c8a <free+0x50>
{
    5c7a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5c7c:	fed7fae3          	bgeu	a5,a3,5c70 <free+0x36>
    5c80:	6398                	ld	a4,0(a5)
    5c82:	00e6e463          	bltu	a3,a4,5c8a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5c86:	fee7eae3          	bltu	a5,a4,5c7a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    5c8a:	ff852583          	lw	a1,-8(a0)
    5c8e:	6390                	ld	a2,0(a5)
    5c90:	02059813          	slli	a6,a1,0x20
    5c94:	01c85713          	srli	a4,a6,0x1c
    5c98:	9736                	add	a4,a4,a3
    5c9a:	fae60ae3          	beq	a2,a4,5c4e <free+0x14>
    bp->s.ptr = p->s.ptr;
    5c9e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5ca2:	4790                	lw	a2,8(a5)
    5ca4:	02061593          	slli	a1,a2,0x20
    5ca8:	01c5d713          	srli	a4,a1,0x1c
    5cac:	973e                	add	a4,a4,a5
    5cae:	fae689e3          	beq	a3,a4,5c60 <free+0x26>
  } else
    p->s.ptr = bp;
    5cb2:	e394                	sd	a3,0(a5)
  freep = p;
    5cb4:	00002717          	auipc	a4,0x2
    5cb8:	70f73e23          	sd	a5,1820(a4) # 83d0 <freep>
}
    5cbc:	6422                	ld	s0,8(sp)
    5cbe:	0141                	addi	sp,sp,16
    5cc0:	8082                	ret

0000000000005cc2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5cc2:	7139                	addi	sp,sp,-64
    5cc4:	fc06                	sd	ra,56(sp)
    5cc6:	f822                	sd	s0,48(sp)
    5cc8:	f426                	sd	s1,40(sp)
    5cca:	f04a                	sd	s2,32(sp)
    5ccc:	ec4e                	sd	s3,24(sp)
    5cce:	e852                	sd	s4,16(sp)
    5cd0:	e456                	sd	s5,8(sp)
    5cd2:	e05a                	sd	s6,0(sp)
    5cd4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5cd6:	02051493          	slli	s1,a0,0x20
    5cda:	9081                	srli	s1,s1,0x20
    5cdc:	04bd                	addi	s1,s1,15
    5cde:	8091                	srli	s1,s1,0x4
    5ce0:	0014899b          	addiw	s3,s1,1
    5ce4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5ce6:	00002517          	auipc	a0,0x2
    5cea:	6ea53503          	ld	a0,1770(a0) # 83d0 <freep>
    5cee:	c515                	beqz	a0,5d1a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5cf0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5cf2:	4798                	lw	a4,8(a5)
    5cf4:	02977f63          	bgeu	a4,s1,5d32 <malloc+0x70>
    5cf8:	8a4e                	mv	s4,s3
    5cfa:	0009871b          	sext.w	a4,s3
    5cfe:	6685                	lui	a3,0x1
    5d00:	00d77363          	bgeu	a4,a3,5d06 <malloc+0x44>
    5d04:	6a05                	lui	s4,0x1
    5d06:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5d0a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5d0e:	00002917          	auipc	s2,0x2
    5d12:	6c290913          	addi	s2,s2,1730 # 83d0 <freep>
  if(p == (char*)-1)
    5d16:	5afd                	li	s5,-1
    5d18:	a895                	j	5d8c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    5d1a:	00009797          	auipc	a5,0x9
    5d1e:	ed678793          	addi	a5,a5,-298 # ebf0 <base>
    5d22:	00002717          	auipc	a4,0x2
    5d26:	6af73723          	sd	a5,1710(a4) # 83d0 <freep>
    5d2a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5d2c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5d30:	b7e1                	j	5cf8 <malloc+0x36>
      if(p->s.size == nunits)
    5d32:	02e48c63          	beq	s1,a4,5d6a <malloc+0xa8>
        p->s.size -= nunits;
    5d36:	4137073b          	subw	a4,a4,s3
    5d3a:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5d3c:	02071693          	slli	a3,a4,0x20
    5d40:	01c6d713          	srli	a4,a3,0x1c
    5d44:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5d46:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5d4a:	00002717          	auipc	a4,0x2
    5d4e:	68a73323          	sd	a0,1670(a4) # 83d0 <freep>
      return (void*)(p + 1);
    5d52:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5d56:	70e2                	ld	ra,56(sp)
    5d58:	7442                	ld	s0,48(sp)
    5d5a:	74a2                	ld	s1,40(sp)
    5d5c:	7902                	ld	s2,32(sp)
    5d5e:	69e2                	ld	s3,24(sp)
    5d60:	6a42                	ld	s4,16(sp)
    5d62:	6aa2                	ld	s5,8(sp)
    5d64:	6b02                	ld	s6,0(sp)
    5d66:	6121                	addi	sp,sp,64
    5d68:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5d6a:	6398                	ld	a4,0(a5)
    5d6c:	e118                	sd	a4,0(a0)
    5d6e:	bff1                	j	5d4a <malloc+0x88>
  hp->s.size = nu;
    5d70:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    5d74:	0541                	addi	a0,a0,16
    5d76:	00000097          	auipc	ra,0x0
    5d7a:	ec4080e7          	jalr	-316(ra) # 5c3a <free>
  return freep;
    5d7e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    5d82:	d971                	beqz	a0,5d56 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5d84:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5d86:	4798                	lw	a4,8(a5)
    5d88:	fa9775e3          	bgeu	a4,s1,5d32 <malloc+0x70>
    if(p == freep)
    5d8c:	00093703          	ld	a4,0(s2)
    5d90:	853e                	mv	a0,a5
    5d92:	fef719e3          	bne	a4,a5,5d84 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    5d96:	8552                	mv	a0,s4
    5d98:	00000097          	auipc	ra,0x0
    5d9c:	b44080e7          	jalr	-1212(ra) # 58dc <sbrk>
  if(p == (char*)-1)
    5da0:	fd5518e3          	bne	a0,s5,5d70 <malloc+0xae>
        return 0;
    5da4:	4501                	li	a0,0
    5da6:	bf45                	j	5d56 <malloc+0x94>
