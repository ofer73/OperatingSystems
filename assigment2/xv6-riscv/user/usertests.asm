
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
       e:	38f72723          	sw	a5,910(a4) # 8398 <wait_sig>
    printf("Received sigtest\n");
      12:	00006517          	auipc	a0,0x6
      16:	f9e50513          	addi	a0,a0,-98 # 5fb0 <malloc+0x2fe>
      1a:	00006097          	auipc	ra,0x6
      1e:	bda080e7          	jalr	-1062(ra) # 5bf4 <printf>
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
      36:	f9650513          	addi	a0,a0,-106 # 5fc8 <malloc+0x316>
      3a:	00006097          	auipc	ra,0x6
      3e:	bba080e7          	jalr	-1094(ra) # 5bf4 <printf>
    kthread_exit(0);
      42:	4501                	li	a0,0
      44:	00006097          	auipc	ra,0x6
      48:	8c8080e7          	jalr	-1848(ra) # 590c <kthread_exit>
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
      58:	45c78793          	addi	a5,a5,1116 # 94b0 <uninit>
      5c:	0000c697          	auipc	a3,0xc
      60:	b6468693          	addi	a3,a3,-1180 # bbc0 <buf>
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
      80:	f6450513          	addi	a0,a0,-156 # 5fe0 <malloc+0x32e>
      84:	00006097          	auipc	ra,0x6
      88:	b70080e7          	jalr	-1168(ra) # 5bf4 <printf>
      exit(1);
      8c:	4505                	li	a0,1
      8e:	00005097          	auipc	ra,0x5
      92:	7b6080e7          	jalr	1974(ra) # 5844 <exit>

0000000000000096 <exitwait>:
{
      96:	7139                	addi	sp,sp,-64
      98:	fc06                	sd	ra,56(sp)
      9a:	f822                	sd	s0,48(sp)
      9c:	f426                	sd	s1,40(sp)
      9e:	f04a                	sd	s2,32(sp)
      a0:	ec4e                	sd	s3,24(sp)
      a2:	e852                	sd	s4,16(sp)
      a4:	0080                	addi	s0,sp,64
      a6:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
      a8:	4901                	li	s2,0
      aa:	06400993          	li	s3,100
    pid = fork();
      ae:	00005097          	auipc	ra,0x5
      b2:	78e080e7          	jalr	1934(ra) # 583c <fork>
      b6:	84aa                	mv	s1,a0
    if(pid < 0){
      b8:	02054a63          	bltz	a0,ec <exitwait+0x56>
    if(pid){
      bc:	c151                	beqz	a0,140 <exitwait+0xaa>
      if(wait(&xstate) != pid){
      be:	fcc40513          	addi	a0,s0,-52
      c2:	00005097          	auipc	ra,0x5
      c6:	78a080e7          	jalr	1930(ra) # 584c <wait>
      ca:	02951f63          	bne	a0,s1,108 <exitwait+0x72>
      if(i != xstate) {
      ce:	fcc42783          	lw	a5,-52(s0)
      d2:	05279963          	bne	a5,s2,124 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
      d6:	2905                	addiw	s2,s2,1
      d8:	fd391be3          	bne	s2,s3,ae <exitwait+0x18>
}
      dc:	70e2                	ld	ra,56(sp)
      de:	7442                	ld	s0,48(sp)
      e0:	74a2                	ld	s1,40(sp)
      e2:	7902                	ld	s2,32(sp)
      e4:	69e2                	ld	s3,24(sp)
      e6:	6a42                	ld	s4,16(sp)
      e8:	6121                	addi	sp,sp,64
      ea:	8082                	ret
      printf("%s: fork failed\n", s);
      ec:	85d2                	mv	a1,s4
      ee:	00006517          	auipc	a0,0x6
      f2:	f0a50513          	addi	a0,a0,-246 # 5ff8 <malloc+0x346>
      f6:	00006097          	auipc	ra,0x6
      fa:	afe080e7          	jalr	-1282(ra) # 5bf4 <printf>
      exit(1);
      fe:	4505                	li	a0,1
     100:	00005097          	auipc	ra,0x5
     104:	744080e7          	jalr	1860(ra) # 5844 <exit>
        printf("%s: wait wrong pid\n", s);
     108:	85d2                	mv	a1,s4
     10a:	00006517          	auipc	a0,0x6
     10e:	f0650513          	addi	a0,a0,-250 # 6010 <malloc+0x35e>
     112:	00006097          	auipc	ra,0x6
     116:	ae2080e7          	jalr	-1310(ra) # 5bf4 <printf>
        exit(1);
     11a:	4505                	li	a0,1
     11c:	00005097          	auipc	ra,0x5
     120:	728080e7          	jalr	1832(ra) # 5844 <exit>
        printf("%s: wait wrong exit status\n", s);
     124:	85d2                	mv	a1,s4
     126:	00006517          	auipc	a0,0x6
     12a:	f0250513          	addi	a0,a0,-254 # 6028 <malloc+0x376>
     12e:	00006097          	auipc	ra,0x6
     132:	ac6080e7          	jalr	-1338(ra) # 5bf4 <printf>
        exit(1);
     136:	4505                	li	a0,1
     138:	00005097          	auipc	ra,0x5
     13c:	70c080e7          	jalr	1804(ra) # 5844 <exit>
      exit(i);
     140:	854a                	mv	a0,s2
     142:	00005097          	auipc	ra,0x5
     146:	702080e7          	jalr	1794(ra) # 5844 <exit>

000000000000014a <twochildren>:
{
     14a:	1101                	addi	sp,sp,-32
     14c:	ec06                	sd	ra,24(sp)
     14e:	e822                	sd	s0,16(sp)
     150:	e426                	sd	s1,8(sp)
     152:	e04a                	sd	s2,0(sp)
     154:	1000                	addi	s0,sp,32
     156:	892a                	mv	s2,a0
     158:	3e800493          	li	s1,1000
    int pid1 = fork();
     15c:	00005097          	auipc	ra,0x5
     160:	6e0080e7          	jalr	1760(ra) # 583c <fork>
    if(pid1 < 0){
     164:	02054c63          	bltz	a0,19c <twochildren+0x52>
    if(pid1 == 0){
     168:	c921                	beqz	a0,1b8 <twochildren+0x6e>
      int pid2 = fork();
     16a:	00005097          	auipc	ra,0x5
     16e:	6d2080e7          	jalr	1746(ra) # 583c <fork>
      if(pid2 < 0){
     172:	04054763          	bltz	a0,1c0 <twochildren+0x76>
      if(pid2 == 0){
     176:	c13d                	beqz	a0,1dc <twochildren+0x92>
        wait(0);
     178:	4501                	li	a0,0
     17a:	00005097          	auipc	ra,0x5
     17e:	6d2080e7          	jalr	1746(ra) # 584c <wait>
        wait(0);
     182:	4501                	li	a0,0
     184:	00005097          	auipc	ra,0x5
     188:	6c8080e7          	jalr	1736(ra) # 584c <wait>
  for(int i = 0; i < 1000; i++){
     18c:	34fd                	addiw	s1,s1,-1
     18e:	f4f9                	bnez	s1,15c <twochildren+0x12>
}
     190:	60e2                	ld	ra,24(sp)
     192:	6442                	ld	s0,16(sp)
     194:	64a2                	ld	s1,8(sp)
     196:	6902                	ld	s2,0(sp)
     198:	6105                	addi	sp,sp,32
     19a:	8082                	ret
      printf("%s: fork failed\n", s);
     19c:	85ca                	mv	a1,s2
     19e:	00006517          	auipc	a0,0x6
     1a2:	e5a50513          	addi	a0,a0,-422 # 5ff8 <malloc+0x346>
     1a6:	00006097          	auipc	ra,0x6
     1aa:	a4e080e7          	jalr	-1458(ra) # 5bf4 <printf>
      exit(1);
     1ae:	4505                	li	a0,1
     1b0:	00005097          	auipc	ra,0x5
     1b4:	694080e7          	jalr	1684(ra) # 5844 <exit>
      exit(0);
     1b8:	00005097          	auipc	ra,0x5
     1bc:	68c080e7          	jalr	1676(ra) # 5844 <exit>
        printf("%s: fork failed\n", s);
     1c0:	85ca                	mv	a1,s2
     1c2:	00006517          	auipc	a0,0x6
     1c6:	e3650513          	addi	a0,a0,-458 # 5ff8 <malloc+0x346>
     1ca:	00006097          	auipc	ra,0x6
     1ce:	a2a080e7          	jalr	-1494(ra) # 5bf4 <printf>
        exit(1);
     1d2:	4505                	li	a0,1
     1d4:	00005097          	auipc	ra,0x5
     1d8:	670080e7          	jalr	1648(ra) # 5844 <exit>
        exit(0);
     1dc:	00005097          	auipc	ra,0x5
     1e0:	668080e7          	jalr	1640(ra) # 5844 <exit>

00000000000001e4 <forkfork>:
{
     1e4:	7179                	addi	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	1800                	addi	s0,sp,48
     1ee:	84aa                	mv	s1,a0
    int pid = fork();
     1f0:	00005097          	auipc	ra,0x5
     1f4:	64c080e7          	jalr	1612(ra) # 583c <fork>
    if(pid < 0){
     1f8:	04054163          	bltz	a0,23a <forkfork+0x56>
    if(pid == 0){
     1fc:	cd29                	beqz	a0,256 <forkfork+0x72>
    int pid = fork();
     1fe:	00005097          	auipc	ra,0x5
     202:	63e080e7          	jalr	1598(ra) # 583c <fork>
    if(pid < 0){
     206:	02054a63          	bltz	a0,23a <forkfork+0x56>
    if(pid == 0){
     20a:	c531                	beqz	a0,256 <forkfork+0x72>
    wait(&xstatus);
     20c:	fdc40513          	addi	a0,s0,-36
     210:	00005097          	auipc	ra,0x5
     214:	63c080e7          	jalr	1596(ra) # 584c <wait>
    if(xstatus != 0) {
     218:	fdc42783          	lw	a5,-36(s0)
     21c:	ebbd                	bnez	a5,292 <forkfork+0xae>
    wait(&xstatus);
     21e:	fdc40513          	addi	a0,s0,-36
     222:	00005097          	auipc	ra,0x5
     226:	62a080e7          	jalr	1578(ra) # 584c <wait>
    if(xstatus != 0) {
     22a:	fdc42783          	lw	a5,-36(s0)
     22e:	e3b5                	bnez	a5,292 <forkfork+0xae>
}
     230:	70a2                	ld	ra,40(sp)
     232:	7402                	ld	s0,32(sp)
     234:	64e2                	ld	s1,24(sp)
     236:	6145                	addi	sp,sp,48
     238:	8082                	ret
      printf("%s: fork failed", s);
     23a:	85a6                	mv	a1,s1
     23c:	00006517          	auipc	a0,0x6
     240:	e0c50513          	addi	a0,a0,-500 # 6048 <malloc+0x396>
     244:	00006097          	auipc	ra,0x6
     248:	9b0080e7          	jalr	-1616(ra) # 5bf4 <printf>
      exit(1);
     24c:	4505                	li	a0,1
     24e:	00005097          	auipc	ra,0x5
     252:	5f6080e7          	jalr	1526(ra) # 5844 <exit>
{
     256:	0c800493          	li	s1,200
        int pid1 = fork();
     25a:	00005097          	auipc	ra,0x5
     25e:	5e2080e7          	jalr	1506(ra) # 583c <fork>
        if(pid1 < 0){
     262:	00054f63          	bltz	a0,280 <forkfork+0x9c>
        if(pid1 == 0){
     266:	c115                	beqz	a0,28a <forkfork+0xa6>
        wait(0);
     268:	4501                	li	a0,0
     26a:	00005097          	auipc	ra,0x5
     26e:	5e2080e7          	jalr	1506(ra) # 584c <wait>
      for(int j = 0; j < 200; j++){
     272:	34fd                	addiw	s1,s1,-1
     274:	f0fd                	bnez	s1,25a <forkfork+0x76>
      exit(0);
     276:	4501                	li	a0,0
     278:	00005097          	auipc	ra,0x5
     27c:	5cc080e7          	jalr	1484(ra) # 5844 <exit>
          exit(1);
     280:	4505                	li	a0,1
     282:	00005097          	auipc	ra,0x5
     286:	5c2080e7          	jalr	1474(ra) # 5844 <exit>
          exit(0);
     28a:	00005097          	auipc	ra,0x5
     28e:	5ba080e7          	jalr	1466(ra) # 5844 <exit>
      printf("%s: fork in child failed", s);
     292:	85a6                	mv	a1,s1
     294:	00006517          	auipc	a0,0x6
     298:	dc450513          	addi	a0,a0,-572 # 6058 <malloc+0x3a6>
     29c:	00006097          	auipc	ra,0x6
     2a0:	958080e7          	jalr	-1704(ra) # 5bf4 <printf>
      exit(1);
     2a4:	4505                	li	a0,1
     2a6:	00005097          	auipc	ra,0x5
     2aa:	59e080e7          	jalr	1438(ra) # 5844 <exit>

00000000000002ae <forktest>:
{
     2ae:	7179                	addi	sp,sp,-48
     2b0:	f406                	sd	ra,40(sp)
     2b2:	f022                	sd	s0,32(sp)
     2b4:	ec26                	sd	s1,24(sp)
     2b6:	e84a                	sd	s2,16(sp)
     2b8:	e44e                	sd	s3,8(sp)
     2ba:	1800                	addi	s0,sp,48
     2bc:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
     2be:	4481                	li	s1,0
     2c0:	3e800913          	li	s2,1000
    pid = fork();
     2c4:	00005097          	auipc	ra,0x5
     2c8:	578080e7          	jalr	1400(ra) # 583c <fork>
    if(pid < 0)
     2cc:	02054863          	bltz	a0,2fc <forktest+0x4e>
    if(pid == 0)
     2d0:	c115                	beqz	a0,2f4 <forktest+0x46>
  for(n=0; n<N; n++){
     2d2:	2485                	addiw	s1,s1,1
     2d4:	ff2498e3          	bne	s1,s2,2c4 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
     2d8:	85ce                	mv	a1,s3
     2da:	00006517          	auipc	a0,0x6
     2de:	db650513          	addi	a0,a0,-586 # 6090 <malloc+0x3de>
     2e2:	00006097          	auipc	ra,0x6
     2e6:	912080e7          	jalr	-1774(ra) # 5bf4 <printf>
    exit(1);
     2ea:	4505                	li	a0,1
     2ec:	00005097          	auipc	ra,0x5
     2f0:	558080e7          	jalr	1368(ra) # 5844 <exit>
      exit(0);
     2f4:	00005097          	auipc	ra,0x5
     2f8:	550080e7          	jalr	1360(ra) # 5844 <exit>
  if (n == 0) {
     2fc:	cc9d                	beqz	s1,33a <forktest+0x8c>
  if(n == N){
     2fe:	3e800793          	li	a5,1000
     302:	fcf48be3          	beq	s1,a5,2d8 <forktest+0x2a>
  for(; n > 0; n--){
     306:	00905b63          	blez	s1,31c <forktest+0x6e>
    if(wait(0) < 0){
     30a:	4501                	li	a0,0
     30c:	00005097          	auipc	ra,0x5
     310:	540080e7          	jalr	1344(ra) # 584c <wait>
     314:	04054163          	bltz	a0,356 <forktest+0xa8>
  for(; n > 0; n--){
     318:	34fd                	addiw	s1,s1,-1
     31a:	f8e5                	bnez	s1,30a <forktest+0x5c>
  if(wait(0) != -1){
     31c:	4501                	li	a0,0
     31e:	00005097          	auipc	ra,0x5
     322:	52e080e7          	jalr	1326(ra) # 584c <wait>
     326:	57fd                	li	a5,-1
     328:	04f51563          	bne	a0,a5,372 <forktest+0xc4>
}
     32c:	70a2                	ld	ra,40(sp)
     32e:	7402                	ld	s0,32(sp)
     330:	64e2                	ld	s1,24(sp)
     332:	6942                	ld	s2,16(sp)
     334:	69a2                	ld	s3,8(sp)
     336:	6145                	addi	sp,sp,48
     338:	8082                	ret
    printf("%s: no fork at all!\n", s);
     33a:	85ce                	mv	a1,s3
     33c:	00006517          	auipc	a0,0x6
     340:	d3c50513          	addi	a0,a0,-708 # 6078 <malloc+0x3c6>
     344:	00006097          	auipc	ra,0x6
     348:	8b0080e7          	jalr	-1872(ra) # 5bf4 <printf>
    exit(1);
     34c:	4505                	li	a0,1
     34e:	00005097          	auipc	ra,0x5
     352:	4f6080e7          	jalr	1270(ra) # 5844 <exit>
      printf("%s: wait stopped early\n", s);
     356:	85ce                	mv	a1,s3
     358:	00006517          	auipc	a0,0x6
     35c:	d6050513          	addi	a0,a0,-672 # 60b8 <malloc+0x406>
     360:	00006097          	auipc	ra,0x6
     364:	894080e7          	jalr	-1900(ra) # 5bf4 <printf>
      exit(1);
     368:	4505                	li	a0,1
     36a:	00005097          	auipc	ra,0x5
     36e:	4da080e7          	jalr	1242(ra) # 5844 <exit>
    printf("%s: wait got too many\n", s);
     372:	85ce                	mv	a1,s3
     374:	00006517          	auipc	a0,0x6
     378:	d5c50513          	addi	a0,a0,-676 # 60d0 <malloc+0x41e>
     37c:	00006097          	auipc	ra,0x6
     380:	878080e7          	jalr	-1928(ra) # 5bf4 <printf>
    exit(1);
     384:	4505                	li	a0,1
     386:	00005097          	auipc	ra,0x5
     38a:	4be080e7          	jalr	1214(ra) # 5844 <exit>

000000000000038e <thread_test>:
void thread_test(char *s){
     38e:	7179                	addi	sp,sp,-48
     390:	f406                	sd	ra,40(sp)
     392:	f022                	sd	s0,32(sp)
     394:	ec26                	sd	s1,24(sp)
     396:	e84a                	sd	s2,16(sp)
     398:	1800                	addi	s0,sp,48
    void* stack = malloc(4000);
     39a:	6505                	lui	a0,0x1
     39c:	fa050513          	addi	a0,a0,-96 # fa0 <preempt+0x17a>
     3a0:	00006097          	auipc	ra,0x6
     3a4:	912080e7          	jalr	-1774(ra) # 5cb2 <malloc>
     3a8:	84aa                	mv	s1,a0
    printf("after malloc\n");
     3aa:	00006517          	auipc	a0,0x6
     3ae:	d3e50513          	addi	a0,a0,-706 # 60e8 <malloc+0x436>
     3b2:	00006097          	auipc	ra,0x6
     3b6:	842080e7          	jalr	-1982(ra) # 5bf4 <printf>
    tid = kthread_create(test_thread, stack);
     3ba:	85a6                	mv	a1,s1
     3bc:	00000517          	auipc	a0,0x0
     3c0:	c6e50513          	addi	a0,a0,-914 # 2a <test_thread>
     3c4:	00005097          	auipc	ra,0x5
     3c8:	538080e7          	jalr	1336(ra) # 58fc <kthread_create>
     3cc:	892a                	mv	s2,a0
    printf("after create \n");
     3ce:	00006517          	auipc	a0,0x6
     3d2:	d2a50513          	addi	a0,a0,-726 # 60f8 <malloc+0x446>
     3d6:	00006097          	auipc	ra,0x6
     3da:	81e080e7          	jalr	-2018(ra) # 5bf4 <printf>
    kthread_join(tid, &status);
     3de:	fdc40593          	addi	a1,s0,-36
     3e2:	854a                	mv	a0,s2
     3e4:	00005097          	auipc	ra,0x5
     3e8:	530080e7          	jalr	1328(ra) # 5914 <kthread_join>
    printf("after kthread\n");
     3ec:	00006517          	auipc	a0,0x6
     3f0:	d1c50513          	addi	a0,a0,-740 # 6108 <malloc+0x456>
     3f4:	00006097          	auipc	ra,0x6
     3f8:	800080e7          	jalr	-2048(ra) # 5bf4 <printf>
    tid = kthread_id();
     3fc:	00005097          	auipc	ra,0x5
     400:	508080e7          	jalr	1288(ra) # 5904 <kthread_id>
     404:	892a                	mv	s2,a0
    free(stack);
     406:	8526                	mv	a0,s1
     408:	00006097          	auipc	ra,0x6
     40c:	822080e7          	jalr	-2014(ra) # 5c2a <free>
    printf("Finished testing threads, main thread id: %d, %d\n", tid,status);
     410:	fdc42603          	lw	a2,-36(s0)
     414:	85ca                	mv	a1,s2
     416:	00006517          	auipc	a0,0x6
     41a:	d0250513          	addi	a0,a0,-766 # 6118 <malloc+0x466>
     41e:	00005097          	auipc	ra,0x5
     422:	7d6080e7          	jalr	2006(ra) # 5bf4 <printf>
}
     426:	70a2                	ld	ra,40(sp)
     428:	7402                	ld	s0,32(sp)
     42a:	64e2                	ld	s1,24(sp)
     42c:	6942                	ld	s2,16(sp)
     42e:	6145                	addi	sp,sp,48
     430:	8082                	ret

0000000000000432 <copyinstr1>:
{
     432:	1141                	addi	sp,sp,-16
     434:	e406                	sd	ra,8(sp)
     436:	e022                	sd	s0,0(sp)
     438:	0800                	addi	s0,sp,16
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
     43a:	20100593          	li	a1,513
     43e:	4505                	li	a0,1
     440:	057e                	slli	a0,a0,0x1f
     442:	00005097          	auipc	ra,0x5
     446:	442080e7          	jalr	1090(ra) # 5884 <open>
    if(fd >= 0){
     44a:	02055063          	bgez	a0,46a <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
     44e:	20100593          	li	a1,513
     452:	557d                	li	a0,-1
     454:	00005097          	auipc	ra,0x5
     458:	430080e7          	jalr	1072(ra) # 5884 <open>
    uint64 addr = addrs[ai];
     45c:	55fd                	li	a1,-1
    if(fd >= 0){
     45e:	00055863          	bgez	a0,46e <copyinstr1+0x3c>
}
     462:	60a2                	ld	ra,8(sp)
     464:	6402                	ld	s0,0(sp)
     466:	0141                	addi	sp,sp,16
     468:	8082                	ret
    uint64 addr = addrs[ai];
     46a:	4585                	li	a1,1
     46c:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
     46e:	862a                	mv	a2,a0
     470:	00006517          	auipc	a0,0x6
     474:	ce050513          	addi	a0,a0,-800 # 6150 <malloc+0x49e>
     478:	00005097          	auipc	ra,0x5
     47c:	77c080e7          	jalr	1916(ra) # 5bf4 <printf>
      exit(1);
     480:	4505                	li	a0,1
     482:	00005097          	auipc	ra,0x5
     486:	3c2080e7          	jalr	962(ra) # 5844 <exit>

000000000000048a <opentest>:
{
     48a:	1101                	addi	sp,sp,-32
     48c:	ec06                	sd	ra,24(sp)
     48e:	e822                	sd	s0,16(sp)
     490:	e426                	sd	s1,8(sp)
     492:	1000                	addi	s0,sp,32
     494:	84aa                	mv	s1,a0
  fd = open("echo", 0);
     496:	4581                	li	a1,0
     498:	00006517          	auipc	a0,0x6
     49c:	cd850513          	addi	a0,a0,-808 # 6170 <malloc+0x4be>
     4a0:	00005097          	auipc	ra,0x5
     4a4:	3e4080e7          	jalr	996(ra) # 5884 <open>
  if(fd < 0){
     4a8:	02054663          	bltz	a0,4d4 <opentest+0x4a>
  close(fd);
     4ac:	00005097          	auipc	ra,0x5
     4b0:	3c0080e7          	jalr	960(ra) # 586c <close>
  fd = open("doesnotexist", 0);
     4b4:	4581                	li	a1,0
     4b6:	00006517          	auipc	a0,0x6
     4ba:	cda50513          	addi	a0,a0,-806 # 6190 <malloc+0x4de>
     4be:	00005097          	auipc	ra,0x5
     4c2:	3c6080e7          	jalr	966(ra) # 5884 <open>
  if(fd >= 0){
     4c6:	02055563          	bgez	a0,4f0 <opentest+0x66>
}
     4ca:	60e2                	ld	ra,24(sp)
     4cc:	6442                	ld	s0,16(sp)
     4ce:	64a2                	ld	s1,8(sp)
     4d0:	6105                	addi	sp,sp,32
     4d2:	8082                	ret
    printf("%s: open echo failed!\n", s);
     4d4:	85a6                	mv	a1,s1
     4d6:	00006517          	auipc	a0,0x6
     4da:	ca250513          	addi	a0,a0,-862 # 6178 <malloc+0x4c6>
     4de:	00005097          	auipc	ra,0x5
     4e2:	716080e7          	jalr	1814(ra) # 5bf4 <printf>
    exit(1);
     4e6:	4505                	li	a0,1
     4e8:	00005097          	auipc	ra,0x5
     4ec:	35c080e7          	jalr	860(ra) # 5844 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     4f0:	85a6                	mv	a1,s1
     4f2:	00006517          	auipc	a0,0x6
     4f6:	cae50513          	addi	a0,a0,-850 # 61a0 <malloc+0x4ee>
     4fa:	00005097          	auipc	ra,0x5
     4fe:	6fa080e7          	jalr	1786(ra) # 5bf4 <printf>
    exit(1);
     502:	4505                	li	a0,1
     504:	00005097          	auipc	ra,0x5
     508:	340080e7          	jalr	832(ra) # 5844 <exit>

000000000000050c <truncate2>:
{
     50c:	7179                	addi	sp,sp,-48
     50e:	f406                	sd	ra,40(sp)
     510:	f022                	sd	s0,32(sp)
     512:	ec26                	sd	s1,24(sp)
     514:	e84a                	sd	s2,16(sp)
     516:	e44e                	sd	s3,8(sp)
     518:	1800                	addi	s0,sp,48
     51a:	89aa                	mv	s3,a0
  unlink("truncfile");
     51c:	00006517          	auipc	a0,0x6
     520:	cac50513          	addi	a0,a0,-852 # 61c8 <malloc+0x516>
     524:	00005097          	auipc	ra,0x5
     528:	370080e7          	jalr	880(ra) # 5894 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     52c:	60100593          	li	a1,1537
     530:	00006517          	auipc	a0,0x6
     534:	c9850513          	addi	a0,a0,-872 # 61c8 <malloc+0x516>
     538:	00005097          	auipc	ra,0x5
     53c:	34c080e7          	jalr	844(ra) # 5884 <open>
     540:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     542:	4611                	li	a2,4
     544:	00006597          	auipc	a1,0x6
     548:	c9458593          	addi	a1,a1,-876 # 61d8 <malloc+0x526>
     54c:	00005097          	auipc	ra,0x5
     550:	318080e7          	jalr	792(ra) # 5864 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     554:	40100593          	li	a1,1025
     558:	00006517          	auipc	a0,0x6
     55c:	c7050513          	addi	a0,a0,-912 # 61c8 <malloc+0x516>
     560:	00005097          	auipc	ra,0x5
     564:	324080e7          	jalr	804(ra) # 5884 <open>
     568:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     56a:	4605                	li	a2,1
     56c:	00006597          	auipc	a1,0x6
     570:	c7458593          	addi	a1,a1,-908 # 61e0 <malloc+0x52e>
     574:	8526                	mv	a0,s1
     576:	00005097          	auipc	ra,0x5
     57a:	2ee080e7          	jalr	750(ra) # 5864 <write>
  if(n != -1){
     57e:	57fd                	li	a5,-1
     580:	02f51b63          	bne	a0,a5,5b6 <truncate2+0xaa>
  unlink("truncfile");
     584:	00006517          	auipc	a0,0x6
     588:	c4450513          	addi	a0,a0,-956 # 61c8 <malloc+0x516>
     58c:	00005097          	auipc	ra,0x5
     590:	308080e7          	jalr	776(ra) # 5894 <unlink>
  close(fd1);
     594:	8526                	mv	a0,s1
     596:	00005097          	auipc	ra,0x5
     59a:	2d6080e7          	jalr	726(ra) # 586c <close>
  close(fd2);
     59e:	854a                	mv	a0,s2
     5a0:	00005097          	auipc	ra,0x5
     5a4:	2cc080e7          	jalr	716(ra) # 586c <close>
}
     5a8:	70a2                	ld	ra,40(sp)
     5aa:	7402                	ld	s0,32(sp)
     5ac:	64e2                	ld	s1,24(sp)
     5ae:	6942                	ld	s2,16(sp)
     5b0:	69a2                	ld	s3,8(sp)
     5b2:	6145                	addi	sp,sp,48
     5b4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     5b6:	862a                	mv	a2,a0
     5b8:	85ce                	mv	a1,s3
     5ba:	00006517          	auipc	a0,0x6
     5be:	c2e50513          	addi	a0,a0,-978 # 61e8 <malloc+0x536>
     5c2:	00005097          	auipc	ra,0x5
     5c6:	632080e7          	jalr	1586(ra) # 5bf4 <printf>
    exit(1);
     5ca:	4505                	li	a0,1
     5cc:	00005097          	auipc	ra,0x5
     5d0:	278080e7          	jalr	632(ra) # 5844 <exit>

00000000000005d4 <forkforkfork>:
{
     5d4:	1101                	addi	sp,sp,-32
     5d6:	ec06                	sd	ra,24(sp)
     5d8:	e822                	sd	s0,16(sp)
     5da:	e426                	sd	s1,8(sp)
     5dc:	1000                	addi	s0,sp,32
     5de:	84aa                	mv	s1,a0
  unlink("stopforking");
     5e0:	00006517          	auipc	a0,0x6
     5e4:	c3050513          	addi	a0,a0,-976 # 6210 <malloc+0x55e>
     5e8:	00005097          	auipc	ra,0x5
     5ec:	2ac080e7          	jalr	684(ra) # 5894 <unlink>
  int pid = fork();
     5f0:	00005097          	auipc	ra,0x5
     5f4:	24c080e7          	jalr	588(ra) # 583c <fork>
  if(pid < 0){
     5f8:	04054563          	bltz	a0,642 <forkforkfork+0x6e>
  if(pid == 0){
     5fc:	c12d                	beqz	a0,65e <forkforkfork+0x8a>
  sleep(20); // two seconds
     5fe:	4551                	li	a0,20
     600:	00005097          	auipc	ra,0x5
     604:	2d4080e7          	jalr	724(ra) # 58d4 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
     608:	20200593          	li	a1,514
     60c:	00006517          	auipc	a0,0x6
     610:	c0450513          	addi	a0,a0,-1020 # 6210 <malloc+0x55e>
     614:	00005097          	auipc	ra,0x5
     618:	270080e7          	jalr	624(ra) # 5884 <open>
     61c:	00005097          	auipc	ra,0x5
     620:	250080e7          	jalr	592(ra) # 586c <close>
  wait(0);
     624:	4501                	li	a0,0
     626:	00005097          	auipc	ra,0x5
     62a:	226080e7          	jalr	550(ra) # 584c <wait>
  sleep(10); // one second
     62e:	4529                	li	a0,10
     630:	00005097          	auipc	ra,0x5
     634:	2a4080e7          	jalr	676(ra) # 58d4 <sleep>
}
     638:	60e2                	ld	ra,24(sp)
     63a:	6442                	ld	s0,16(sp)
     63c:	64a2                	ld	s1,8(sp)
     63e:	6105                	addi	sp,sp,32
     640:	8082                	ret
    printf("%s: fork failed", s);
     642:	85a6                	mv	a1,s1
     644:	00006517          	auipc	a0,0x6
     648:	a0450513          	addi	a0,a0,-1532 # 6048 <malloc+0x396>
     64c:	00005097          	auipc	ra,0x5
     650:	5a8080e7          	jalr	1448(ra) # 5bf4 <printf>
    exit(1);
     654:	4505                	li	a0,1
     656:	00005097          	auipc	ra,0x5
     65a:	1ee080e7          	jalr	494(ra) # 5844 <exit>
      int fd = open("stopforking", 0);
     65e:	00006497          	auipc	s1,0x6
     662:	bb248493          	addi	s1,s1,-1102 # 6210 <malloc+0x55e>
     666:	4581                	li	a1,0
     668:	8526                	mv	a0,s1
     66a:	00005097          	auipc	ra,0x5
     66e:	21a080e7          	jalr	538(ra) # 5884 <open>
      if(fd >= 0){
     672:	02055463          	bgez	a0,69a <forkforkfork+0xc6>
      if(fork() < 0){
     676:	00005097          	auipc	ra,0x5
     67a:	1c6080e7          	jalr	454(ra) # 583c <fork>
     67e:	fe0554e3          	bgez	a0,666 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
     682:	20200593          	li	a1,514
     686:	8526                	mv	a0,s1
     688:	00005097          	auipc	ra,0x5
     68c:	1fc080e7          	jalr	508(ra) # 5884 <open>
     690:	00005097          	auipc	ra,0x5
     694:	1dc080e7          	jalr	476(ra) # 586c <close>
     698:	b7f9                	j	666 <forkforkfork+0x92>
        exit(0);
     69a:	4501                	li	a0,0
     69c:	00005097          	auipc	ra,0x5
     6a0:	1a8080e7          	jalr	424(ra) # 5844 <exit>

00000000000006a4 <bigwrite>:
{
     6a4:	715d                	addi	sp,sp,-80
     6a6:	e486                	sd	ra,72(sp)
     6a8:	e0a2                	sd	s0,64(sp)
     6aa:	fc26                	sd	s1,56(sp)
     6ac:	f84a                	sd	s2,48(sp)
     6ae:	f44e                	sd	s3,40(sp)
     6b0:	f052                	sd	s4,32(sp)
     6b2:	ec56                	sd	s5,24(sp)
     6b4:	e85a                	sd	s6,16(sp)
     6b6:	e45e                	sd	s7,8(sp)
     6b8:	0880                	addi	s0,sp,80
     6ba:	8baa                	mv	s7,a0
  unlink("bigwrite");
     6bc:	00006517          	auipc	a0,0x6
     6c0:	83450513          	addi	a0,a0,-1996 # 5ef0 <malloc+0x23e>
     6c4:	00005097          	auipc	ra,0x5
     6c8:	1d0080e7          	jalr	464(ra) # 5894 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     6cc:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     6d0:	00006a97          	auipc	s5,0x6
     6d4:	820a8a93          	addi	s5,s5,-2016 # 5ef0 <malloc+0x23e>
      int cc = write(fd, buf, sz);
     6d8:	0000ba17          	auipc	s4,0xb
     6dc:	4e8a0a13          	addi	s4,s4,1256 # bbc0 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     6e0:	6b0d                	lui	s6,0x3
     6e2:	1c9b0b13          	addi	s6,s6,457 # 31c9 <bigfile+0xa5>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     6e6:	20200593          	li	a1,514
     6ea:	8556                	mv	a0,s5
     6ec:	00005097          	auipc	ra,0x5
     6f0:	198080e7          	jalr	408(ra) # 5884 <open>
     6f4:	892a                	mv	s2,a0
    if(fd < 0){
     6f6:	04054d63          	bltz	a0,750 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     6fa:	8626                	mv	a2,s1
     6fc:	85d2                	mv	a1,s4
     6fe:	00005097          	auipc	ra,0x5
     702:	166080e7          	jalr	358(ra) # 5864 <write>
     706:	89aa                	mv	s3,a0
      if(cc != sz){
     708:	06a49463          	bne	s1,a0,770 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     70c:	8626                	mv	a2,s1
     70e:	85d2                	mv	a1,s4
     710:	854a                	mv	a0,s2
     712:	00005097          	auipc	ra,0x5
     716:	152080e7          	jalr	338(ra) # 5864 <write>
      if(cc != sz){
     71a:	04951963          	bne	a0,s1,76c <bigwrite+0xc8>
    close(fd);
     71e:	854a                	mv	a0,s2
     720:	00005097          	auipc	ra,0x5
     724:	14c080e7          	jalr	332(ra) # 586c <close>
    unlink("bigwrite");
     728:	8556                	mv	a0,s5
     72a:	00005097          	auipc	ra,0x5
     72e:	16a080e7          	jalr	362(ra) # 5894 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     732:	1d74849b          	addiw	s1,s1,471
     736:	fb6498e3          	bne	s1,s6,6e6 <bigwrite+0x42>
}
     73a:	60a6                	ld	ra,72(sp)
     73c:	6406                	ld	s0,64(sp)
     73e:	74e2                	ld	s1,56(sp)
     740:	7942                	ld	s2,48(sp)
     742:	79a2                	ld	s3,40(sp)
     744:	7a02                	ld	s4,32(sp)
     746:	6ae2                	ld	s5,24(sp)
     748:	6b42                	ld	s6,16(sp)
     74a:	6ba2                	ld	s7,8(sp)
     74c:	6161                	addi	sp,sp,80
     74e:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     750:	85de                	mv	a1,s7
     752:	00006517          	auipc	a0,0x6
     756:	ace50513          	addi	a0,a0,-1330 # 6220 <malloc+0x56e>
     75a:	00005097          	auipc	ra,0x5
     75e:	49a080e7          	jalr	1178(ra) # 5bf4 <printf>
      exit(1);
     762:	4505                	li	a0,1
     764:	00005097          	auipc	ra,0x5
     768:	0e0080e7          	jalr	224(ra) # 5844 <exit>
     76c:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     76e:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     770:	86ce                	mv	a3,s3
     772:	8626                	mv	a2,s1
     774:	85de                	mv	a1,s7
     776:	00006517          	auipc	a0,0x6
     77a:	aca50513          	addi	a0,a0,-1334 # 6240 <malloc+0x58e>
     77e:	00005097          	auipc	ra,0x5
     782:	476080e7          	jalr	1142(ra) # 5bf4 <printf>
        exit(1);
     786:	4505                	li	a0,1
     788:	00005097          	auipc	ra,0x5
     78c:	0bc080e7          	jalr	188(ra) # 5844 <exit>

0000000000000790 <copyin>:
{
     790:	715d                	addi	sp,sp,-80
     792:	e486                	sd	ra,72(sp)
     794:	e0a2                	sd	s0,64(sp)
     796:	fc26                	sd	s1,56(sp)
     798:	f84a                	sd	s2,48(sp)
     79a:	f44e                	sd	s3,40(sp)
     79c:	f052                	sd	s4,32(sp)
     79e:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     7a0:	4785                	li	a5,1
     7a2:	07fe                	slli	a5,a5,0x1f
     7a4:	fcf43023          	sd	a5,-64(s0)
     7a8:	57fd                	li	a5,-1
     7aa:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     7ae:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     7b2:	00006a17          	auipc	s4,0x6
     7b6:	aa6a0a13          	addi	s4,s4,-1370 # 6258 <malloc+0x5a6>
    uint64 addr = addrs[ai];
     7ba:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     7be:	20100593          	li	a1,513
     7c2:	8552                	mv	a0,s4
     7c4:	00005097          	auipc	ra,0x5
     7c8:	0c0080e7          	jalr	192(ra) # 5884 <open>
     7cc:	84aa                	mv	s1,a0
    if(fd < 0){
     7ce:	08054863          	bltz	a0,85e <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     7d2:	6609                	lui	a2,0x2
     7d4:	85ce                	mv	a1,s3
     7d6:	00005097          	auipc	ra,0x5
     7da:	08e080e7          	jalr	142(ra) # 5864 <write>
    if(n >= 0){
     7de:	08055d63          	bgez	a0,878 <copyin+0xe8>
    close(fd);
     7e2:	8526                	mv	a0,s1
     7e4:	00005097          	auipc	ra,0x5
     7e8:	088080e7          	jalr	136(ra) # 586c <close>
    unlink("copyin1");
     7ec:	8552                	mv	a0,s4
     7ee:	00005097          	auipc	ra,0x5
     7f2:	0a6080e7          	jalr	166(ra) # 5894 <unlink>
    n = write(1, (char*)addr, 8192);
     7f6:	6609                	lui	a2,0x2
     7f8:	85ce                	mv	a1,s3
     7fa:	4505                	li	a0,1
     7fc:	00005097          	auipc	ra,0x5
     800:	068080e7          	jalr	104(ra) # 5864 <write>
    if(n > 0){
     804:	08a04963          	bgtz	a0,896 <copyin+0x106>
    if(pipe(fds) < 0){
     808:	fb840513          	addi	a0,s0,-72
     80c:	00005097          	auipc	ra,0x5
     810:	048080e7          	jalr	72(ra) # 5854 <pipe>
     814:	0a054063          	bltz	a0,8b4 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     818:	6609                	lui	a2,0x2
     81a:	85ce                	mv	a1,s3
     81c:	fbc42503          	lw	a0,-68(s0)
     820:	00005097          	auipc	ra,0x5
     824:	044080e7          	jalr	68(ra) # 5864 <write>
    if(n > 0){
     828:	0aa04363          	bgtz	a0,8ce <copyin+0x13e>
    close(fds[0]);
     82c:	fb842503          	lw	a0,-72(s0)
     830:	00005097          	auipc	ra,0x5
     834:	03c080e7          	jalr	60(ra) # 586c <close>
    close(fds[1]);
     838:	fbc42503          	lw	a0,-68(s0)
     83c:	00005097          	auipc	ra,0x5
     840:	030080e7          	jalr	48(ra) # 586c <close>
  for(int ai = 0; ai < 2; ai++){
     844:	0921                	addi	s2,s2,8
     846:	fd040793          	addi	a5,s0,-48
     84a:	f6f918e3          	bne	s2,a5,7ba <copyin+0x2a>
}
     84e:	60a6                	ld	ra,72(sp)
     850:	6406                	ld	s0,64(sp)
     852:	74e2                	ld	s1,56(sp)
     854:	7942                	ld	s2,48(sp)
     856:	79a2                	ld	s3,40(sp)
     858:	7a02                	ld	s4,32(sp)
     85a:	6161                	addi	sp,sp,80
     85c:	8082                	ret
      printf("open(copyin1) failed\n");
     85e:	00006517          	auipc	a0,0x6
     862:	a0250513          	addi	a0,a0,-1534 # 6260 <malloc+0x5ae>
     866:	00005097          	auipc	ra,0x5
     86a:	38e080e7          	jalr	910(ra) # 5bf4 <printf>
      exit(1);
     86e:	4505                	li	a0,1
     870:	00005097          	auipc	ra,0x5
     874:	fd4080e7          	jalr	-44(ra) # 5844 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     878:	862a                	mv	a2,a0
     87a:	85ce                	mv	a1,s3
     87c:	00006517          	auipc	a0,0x6
     880:	9fc50513          	addi	a0,a0,-1540 # 6278 <malloc+0x5c6>
     884:	00005097          	auipc	ra,0x5
     888:	370080e7          	jalr	880(ra) # 5bf4 <printf>
      exit(1);
     88c:	4505                	li	a0,1
     88e:	00005097          	auipc	ra,0x5
     892:	fb6080e7          	jalr	-74(ra) # 5844 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     896:	862a                	mv	a2,a0
     898:	85ce                	mv	a1,s3
     89a:	00006517          	auipc	a0,0x6
     89e:	a0e50513          	addi	a0,a0,-1522 # 62a8 <malloc+0x5f6>
     8a2:	00005097          	auipc	ra,0x5
     8a6:	352080e7          	jalr	850(ra) # 5bf4 <printf>
      exit(1);
     8aa:	4505                	li	a0,1
     8ac:	00005097          	auipc	ra,0x5
     8b0:	f98080e7          	jalr	-104(ra) # 5844 <exit>
      printf("pipe() failed\n");
     8b4:	00006517          	auipc	a0,0x6
     8b8:	a2450513          	addi	a0,a0,-1500 # 62d8 <malloc+0x626>
     8bc:	00005097          	auipc	ra,0x5
     8c0:	338080e7          	jalr	824(ra) # 5bf4 <printf>
      exit(1);
     8c4:	4505                	li	a0,1
     8c6:	00005097          	auipc	ra,0x5
     8ca:	f7e080e7          	jalr	-130(ra) # 5844 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     8ce:	862a                	mv	a2,a0
     8d0:	85ce                	mv	a1,s3
     8d2:	00006517          	auipc	a0,0x6
     8d6:	a1650513          	addi	a0,a0,-1514 # 62e8 <malloc+0x636>
     8da:	00005097          	auipc	ra,0x5
     8de:	31a080e7          	jalr	794(ra) # 5bf4 <printf>
      exit(1);
     8e2:	4505                	li	a0,1
     8e4:	00005097          	auipc	ra,0x5
     8e8:	f60080e7          	jalr	-160(ra) # 5844 <exit>

00000000000008ec <copyout>:
{
     8ec:	711d                	addi	sp,sp,-96
     8ee:	ec86                	sd	ra,88(sp)
     8f0:	e8a2                	sd	s0,80(sp)
     8f2:	e4a6                	sd	s1,72(sp)
     8f4:	e0ca                	sd	s2,64(sp)
     8f6:	fc4e                	sd	s3,56(sp)
     8f8:	f852                	sd	s4,48(sp)
     8fa:	f456                	sd	s5,40(sp)
     8fc:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     8fe:	4785                	li	a5,1
     900:	07fe                	slli	a5,a5,0x1f
     902:	faf43823          	sd	a5,-80(s0)
     906:	57fd                	li	a5,-1
     908:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     90c:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     910:	00006a17          	auipc	s4,0x6
     914:	a08a0a13          	addi	s4,s4,-1528 # 6318 <malloc+0x666>
    n = write(fds[1], "x", 1);
     918:	00006a97          	auipc	s5,0x6
     91c:	8c8a8a93          	addi	s5,s5,-1848 # 61e0 <malloc+0x52e>
    uint64 addr = addrs[ai];
     920:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     924:	4581                	li	a1,0
     926:	8552                	mv	a0,s4
     928:	00005097          	auipc	ra,0x5
     92c:	f5c080e7          	jalr	-164(ra) # 5884 <open>
     930:	84aa                	mv	s1,a0
    if(fd < 0){
     932:	08054663          	bltz	a0,9be <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     936:	6609                	lui	a2,0x2
     938:	85ce                	mv	a1,s3
     93a:	00005097          	auipc	ra,0x5
     93e:	f22080e7          	jalr	-222(ra) # 585c <read>
    if(n > 0){
     942:	08a04b63          	bgtz	a0,9d8 <copyout+0xec>
    close(fd);
     946:	8526                	mv	a0,s1
     948:	00005097          	auipc	ra,0x5
     94c:	f24080e7          	jalr	-220(ra) # 586c <close>
    if(pipe(fds) < 0){
     950:	fa840513          	addi	a0,s0,-88
     954:	00005097          	auipc	ra,0x5
     958:	f00080e7          	jalr	-256(ra) # 5854 <pipe>
     95c:	08054d63          	bltz	a0,9f6 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     960:	4605                	li	a2,1
     962:	85d6                	mv	a1,s5
     964:	fac42503          	lw	a0,-84(s0)
     968:	00005097          	auipc	ra,0x5
     96c:	efc080e7          	jalr	-260(ra) # 5864 <write>
    if(n != 1){
     970:	4785                	li	a5,1
     972:	08f51f63          	bne	a0,a5,a10 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     976:	6609                	lui	a2,0x2
     978:	85ce                	mv	a1,s3
     97a:	fa842503          	lw	a0,-88(s0)
     97e:	00005097          	auipc	ra,0x5
     982:	ede080e7          	jalr	-290(ra) # 585c <read>
    if(n > 0){
     986:	0aa04263          	bgtz	a0,a2a <copyout+0x13e>
    close(fds[0]);
     98a:	fa842503          	lw	a0,-88(s0)
     98e:	00005097          	auipc	ra,0x5
     992:	ede080e7          	jalr	-290(ra) # 586c <close>
    close(fds[1]);
     996:	fac42503          	lw	a0,-84(s0)
     99a:	00005097          	auipc	ra,0x5
     99e:	ed2080e7          	jalr	-302(ra) # 586c <close>
  for(int ai = 0; ai < 2; ai++){
     9a2:	0921                	addi	s2,s2,8
     9a4:	fc040793          	addi	a5,s0,-64
     9a8:	f6f91ce3          	bne	s2,a5,920 <copyout+0x34>
}
     9ac:	60e6                	ld	ra,88(sp)
     9ae:	6446                	ld	s0,80(sp)
     9b0:	64a6                	ld	s1,72(sp)
     9b2:	6906                	ld	s2,64(sp)
     9b4:	79e2                	ld	s3,56(sp)
     9b6:	7a42                	ld	s4,48(sp)
     9b8:	7aa2                	ld	s5,40(sp)
     9ba:	6125                	addi	sp,sp,96
     9bc:	8082                	ret
      printf("open(README) failed\n");
     9be:	00006517          	auipc	a0,0x6
     9c2:	96250513          	addi	a0,a0,-1694 # 6320 <malloc+0x66e>
     9c6:	00005097          	auipc	ra,0x5
     9ca:	22e080e7          	jalr	558(ra) # 5bf4 <printf>
      exit(1);
     9ce:	4505                	li	a0,1
     9d0:	00005097          	auipc	ra,0x5
     9d4:	e74080e7          	jalr	-396(ra) # 5844 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     9d8:	862a                	mv	a2,a0
     9da:	85ce                	mv	a1,s3
     9dc:	00006517          	auipc	a0,0x6
     9e0:	95c50513          	addi	a0,a0,-1700 # 6338 <malloc+0x686>
     9e4:	00005097          	auipc	ra,0x5
     9e8:	210080e7          	jalr	528(ra) # 5bf4 <printf>
      exit(1);
     9ec:	4505                	li	a0,1
     9ee:	00005097          	auipc	ra,0x5
     9f2:	e56080e7          	jalr	-426(ra) # 5844 <exit>
      printf("pipe() failed\n");
     9f6:	00006517          	auipc	a0,0x6
     9fa:	8e250513          	addi	a0,a0,-1822 # 62d8 <malloc+0x626>
     9fe:	00005097          	auipc	ra,0x5
     a02:	1f6080e7          	jalr	502(ra) # 5bf4 <printf>
      exit(1);
     a06:	4505                	li	a0,1
     a08:	00005097          	auipc	ra,0x5
     a0c:	e3c080e7          	jalr	-452(ra) # 5844 <exit>
      printf("pipe write failed\n");
     a10:	00006517          	auipc	a0,0x6
     a14:	95850513          	addi	a0,a0,-1704 # 6368 <malloc+0x6b6>
     a18:	00005097          	auipc	ra,0x5
     a1c:	1dc080e7          	jalr	476(ra) # 5bf4 <printf>
      exit(1);
     a20:	4505                	li	a0,1
     a22:	00005097          	auipc	ra,0x5
     a26:	e22080e7          	jalr	-478(ra) # 5844 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     a2a:	862a                	mv	a2,a0
     a2c:	85ce                	mv	a1,s3
     a2e:	00006517          	auipc	a0,0x6
     a32:	95250513          	addi	a0,a0,-1710 # 6380 <malloc+0x6ce>
     a36:	00005097          	auipc	ra,0x5
     a3a:	1be080e7          	jalr	446(ra) # 5bf4 <printf>
      exit(1);
     a3e:	4505                	li	a0,1
     a40:	00005097          	auipc	ra,0x5
     a44:	e04080e7          	jalr	-508(ra) # 5844 <exit>

0000000000000a48 <truncate1>:
{
     a48:	711d                	addi	sp,sp,-96
     a4a:	ec86                	sd	ra,88(sp)
     a4c:	e8a2                	sd	s0,80(sp)
     a4e:	e4a6                	sd	s1,72(sp)
     a50:	e0ca                	sd	s2,64(sp)
     a52:	fc4e                	sd	s3,56(sp)
     a54:	f852                	sd	s4,48(sp)
     a56:	f456                	sd	s5,40(sp)
     a58:	1080                	addi	s0,sp,96
     a5a:	8aaa                	mv	s5,a0
  unlink("truncfile");
     a5c:	00005517          	auipc	a0,0x5
     a60:	76c50513          	addi	a0,a0,1900 # 61c8 <malloc+0x516>
     a64:	00005097          	auipc	ra,0x5
     a68:	e30080e7          	jalr	-464(ra) # 5894 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     a6c:	60100593          	li	a1,1537
     a70:	00005517          	auipc	a0,0x5
     a74:	75850513          	addi	a0,a0,1880 # 61c8 <malloc+0x516>
     a78:	00005097          	auipc	ra,0x5
     a7c:	e0c080e7          	jalr	-500(ra) # 5884 <open>
     a80:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     a82:	4611                	li	a2,4
     a84:	00005597          	auipc	a1,0x5
     a88:	75458593          	addi	a1,a1,1876 # 61d8 <malloc+0x526>
     a8c:	00005097          	auipc	ra,0x5
     a90:	dd8080e7          	jalr	-552(ra) # 5864 <write>
  close(fd1);
     a94:	8526                	mv	a0,s1
     a96:	00005097          	auipc	ra,0x5
     a9a:	dd6080e7          	jalr	-554(ra) # 586c <close>
  int fd2 = open("truncfile", O_RDONLY);
     a9e:	4581                	li	a1,0
     aa0:	00005517          	auipc	a0,0x5
     aa4:	72850513          	addi	a0,a0,1832 # 61c8 <malloc+0x516>
     aa8:	00005097          	auipc	ra,0x5
     aac:	ddc080e7          	jalr	-548(ra) # 5884 <open>
     ab0:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     ab2:	02000613          	li	a2,32
     ab6:	fa040593          	addi	a1,s0,-96
     aba:	00005097          	auipc	ra,0x5
     abe:	da2080e7          	jalr	-606(ra) # 585c <read>
  if(n != 4){
     ac2:	4791                	li	a5,4
     ac4:	0cf51e63          	bne	a0,a5,ba0 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     ac8:	40100593          	li	a1,1025
     acc:	00005517          	auipc	a0,0x5
     ad0:	6fc50513          	addi	a0,a0,1788 # 61c8 <malloc+0x516>
     ad4:	00005097          	auipc	ra,0x5
     ad8:	db0080e7          	jalr	-592(ra) # 5884 <open>
     adc:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     ade:	4581                	li	a1,0
     ae0:	00005517          	auipc	a0,0x5
     ae4:	6e850513          	addi	a0,a0,1768 # 61c8 <malloc+0x516>
     ae8:	00005097          	auipc	ra,0x5
     aec:	d9c080e7          	jalr	-612(ra) # 5884 <open>
     af0:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     af2:	02000613          	li	a2,32
     af6:	fa040593          	addi	a1,s0,-96
     afa:	00005097          	auipc	ra,0x5
     afe:	d62080e7          	jalr	-670(ra) # 585c <read>
     b02:	8a2a                	mv	s4,a0
  if(n != 0){
     b04:	ed4d                	bnez	a0,bbe <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     b06:	02000613          	li	a2,32
     b0a:	fa040593          	addi	a1,s0,-96
     b0e:	8526                	mv	a0,s1
     b10:	00005097          	auipc	ra,0x5
     b14:	d4c080e7          	jalr	-692(ra) # 585c <read>
     b18:	8a2a                	mv	s4,a0
  if(n != 0){
     b1a:	e971                	bnez	a0,bee <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     b1c:	4619                	li	a2,6
     b1e:	00006597          	auipc	a1,0x6
     b22:	8f258593          	addi	a1,a1,-1806 # 6410 <malloc+0x75e>
     b26:	854e                	mv	a0,s3
     b28:	00005097          	auipc	ra,0x5
     b2c:	d3c080e7          	jalr	-708(ra) # 5864 <write>
  n = read(fd3, buf, sizeof(buf));
     b30:	02000613          	li	a2,32
     b34:	fa040593          	addi	a1,s0,-96
     b38:	854a                	mv	a0,s2
     b3a:	00005097          	auipc	ra,0x5
     b3e:	d22080e7          	jalr	-734(ra) # 585c <read>
  if(n != 6){
     b42:	4799                	li	a5,6
     b44:	0cf51d63          	bne	a0,a5,c1e <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     b48:	02000613          	li	a2,32
     b4c:	fa040593          	addi	a1,s0,-96
     b50:	8526                	mv	a0,s1
     b52:	00005097          	auipc	ra,0x5
     b56:	d0a080e7          	jalr	-758(ra) # 585c <read>
  if(n != 2){
     b5a:	4789                	li	a5,2
     b5c:	0ef51063          	bne	a0,a5,c3c <truncate1+0x1f4>
  unlink("truncfile");
     b60:	00005517          	auipc	a0,0x5
     b64:	66850513          	addi	a0,a0,1640 # 61c8 <malloc+0x516>
     b68:	00005097          	auipc	ra,0x5
     b6c:	d2c080e7          	jalr	-724(ra) # 5894 <unlink>
  close(fd1);
     b70:	854e                	mv	a0,s3
     b72:	00005097          	auipc	ra,0x5
     b76:	cfa080e7          	jalr	-774(ra) # 586c <close>
  close(fd2);
     b7a:	8526                	mv	a0,s1
     b7c:	00005097          	auipc	ra,0x5
     b80:	cf0080e7          	jalr	-784(ra) # 586c <close>
  close(fd3);
     b84:	854a                	mv	a0,s2
     b86:	00005097          	auipc	ra,0x5
     b8a:	ce6080e7          	jalr	-794(ra) # 586c <close>
}
     b8e:	60e6                	ld	ra,88(sp)
     b90:	6446                	ld	s0,80(sp)
     b92:	64a6                	ld	s1,72(sp)
     b94:	6906                	ld	s2,64(sp)
     b96:	79e2                	ld	s3,56(sp)
     b98:	7a42                	ld	s4,48(sp)
     b9a:	7aa2                	ld	s5,40(sp)
     b9c:	6125                	addi	sp,sp,96
     b9e:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     ba0:	862a                	mv	a2,a0
     ba2:	85d6                	mv	a1,s5
     ba4:	00006517          	auipc	a0,0x6
     ba8:	80c50513          	addi	a0,a0,-2036 # 63b0 <malloc+0x6fe>
     bac:	00005097          	auipc	ra,0x5
     bb0:	048080e7          	jalr	72(ra) # 5bf4 <printf>
    exit(1);
     bb4:	4505                	li	a0,1
     bb6:	00005097          	auipc	ra,0x5
     bba:	c8e080e7          	jalr	-882(ra) # 5844 <exit>
    printf("aaa fd3=%d\n", fd3);
     bbe:	85ca                	mv	a1,s2
     bc0:	00006517          	auipc	a0,0x6
     bc4:	81050513          	addi	a0,a0,-2032 # 63d0 <malloc+0x71e>
     bc8:	00005097          	auipc	ra,0x5
     bcc:	02c080e7          	jalr	44(ra) # 5bf4 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     bd0:	8652                	mv	a2,s4
     bd2:	85d6                	mv	a1,s5
     bd4:	00006517          	auipc	a0,0x6
     bd8:	80c50513          	addi	a0,a0,-2036 # 63e0 <malloc+0x72e>
     bdc:	00005097          	auipc	ra,0x5
     be0:	018080e7          	jalr	24(ra) # 5bf4 <printf>
    exit(1);
     be4:	4505                	li	a0,1
     be6:	00005097          	auipc	ra,0x5
     bea:	c5e080e7          	jalr	-930(ra) # 5844 <exit>
    printf("bbb fd2=%d\n", fd2);
     bee:	85a6                	mv	a1,s1
     bf0:	00006517          	auipc	a0,0x6
     bf4:	81050513          	addi	a0,a0,-2032 # 6400 <malloc+0x74e>
     bf8:	00005097          	auipc	ra,0x5
     bfc:	ffc080e7          	jalr	-4(ra) # 5bf4 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     c00:	8652                	mv	a2,s4
     c02:	85d6                	mv	a1,s5
     c04:	00005517          	auipc	a0,0x5
     c08:	7dc50513          	addi	a0,a0,2012 # 63e0 <malloc+0x72e>
     c0c:	00005097          	auipc	ra,0x5
     c10:	fe8080e7          	jalr	-24(ra) # 5bf4 <printf>
    exit(1);
     c14:	4505                	li	a0,1
     c16:	00005097          	auipc	ra,0x5
     c1a:	c2e080e7          	jalr	-978(ra) # 5844 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     c1e:	862a                	mv	a2,a0
     c20:	85d6                	mv	a1,s5
     c22:	00005517          	auipc	a0,0x5
     c26:	7f650513          	addi	a0,a0,2038 # 6418 <malloc+0x766>
     c2a:	00005097          	auipc	ra,0x5
     c2e:	fca080e7          	jalr	-54(ra) # 5bf4 <printf>
    exit(1);
     c32:	4505                	li	a0,1
     c34:	00005097          	auipc	ra,0x5
     c38:	c10080e7          	jalr	-1008(ra) # 5844 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     c3c:	862a                	mv	a2,a0
     c3e:	85d6                	mv	a1,s5
     c40:	00005517          	auipc	a0,0x5
     c44:	7f850513          	addi	a0,a0,2040 # 6438 <malloc+0x786>
     c48:	00005097          	auipc	ra,0x5
     c4c:	fac080e7          	jalr	-84(ra) # 5bf4 <printf>
    exit(1);
     c50:	4505                	li	a0,1
     c52:	00005097          	auipc	ra,0x5
     c56:	bf2080e7          	jalr	-1038(ra) # 5844 <exit>

0000000000000c5a <pipe1>:
{
     c5a:	711d                	addi	sp,sp,-96
     c5c:	ec86                	sd	ra,88(sp)
     c5e:	e8a2                	sd	s0,80(sp)
     c60:	e4a6                	sd	s1,72(sp)
     c62:	e0ca                	sd	s2,64(sp)
     c64:	fc4e                	sd	s3,56(sp)
     c66:	f852                	sd	s4,48(sp)
     c68:	f456                	sd	s5,40(sp)
     c6a:	f05a                	sd	s6,32(sp)
     c6c:	ec5e                	sd	s7,24(sp)
     c6e:	1080                	addi	s0,sp,96
     c70:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
     c72:	fa840513          	addi	a0,s0,-88
     c76:	00005097          	auipc	ra,0x5
     c7a:	bde080e7          	jalr	-1058(ra) # 5854 <pipe>
     c7e:	ed25                	bnez	a0,cf6 <pipe1+0x9c>
     c80:	84aa                	mv	s1,a0
  pid = fork();
     c82:	00005097          	auipc	ra,0x5
     c86:	bba080e7          	jalr	-1094(ra) # 583c <fork>
     c8a:	8a2a                	mv	s4,a0
  if(pid == 0){
     c8c:	c159                	beqz	a0,d12 <pipe1+0xb8>
  } else if(pid > 0){
     c8e:	16a05e63          	blez	a0,e0a <pipe1+0x1b0>
    close(fds[1]);
     c92:	fac42503          	lw	a0,-84(s0)
     c96:	00005097          	auipc	ra,0x5
     c9a:	bd6080e7          	jalr	-1066(ra) # 586c <close>
    total = 0;
     c9e:	8a26                	mv	s4,s1
    cc = 1;
     ca0:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
     ca2:	0000ba97          	auipc	s5,0xb
     ca6:	f1ea8a93          	addi	s5,s5,-226 # bbc0 <buf>
      if(cc > sizeof(buf))
     caa:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
     cac:	864e                	mv	a2,s3
     cae:	85d6                	mv	a1,s5
     cb0:	fa842503          	lw	a0,-88(s0)
     cb4:	00005097          	auipc	ra,0x5
     cb8:	ba8080e7          	jalr	-1112(ra) # 585c <read>
     cbc:	10a05263          	blez	a0,dc0 <pipe1+0x166>
      for(i = 0; i < n; i++){
     cc0:	0000b717          	auipc	a4,0xb
     cc4:	f0070713          	addi	a4,a4,-256 # bbc0 <buf>
     cc8:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     ccc:	00074683          	lbu	a3,0(a4)
     cd0:	0ff4f793          	andi	a5,s1,255
     cd4:	2485                	addiw	s1,s1,1
     cd6:	0cf69163          	bne	a3,a5,d98 <pipe1+0x13e>
      for(i = 0; i < n; i++){
     cda:	0705                	addi	a4,a4,1
     cdc:	fec498e3          	bne	s1,a2,ccc <pipe1+0x72>
      total += n;
     ce0:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
     ce4:	0019979b          	slliw	a5,s3,0x1
     ce8:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
     cec:	013b7363          	bgeu	s6,s3,cf2 <pipe1+0x98>
        cc = sizeof(buf);
     cf0:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     cf2:	84b2                	mv	s1,a2
     cf4:	bf65                	j	cac <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
     cf6:	85ca                	mv	a1,s2
     cf8:	00005517          	auipc	a0,0x5
     cfc:	76050513          	addi	a0,a0,1888 # 6458 <malloc+0x7a6>
     d00:	00005097          	auipc	ra,0x5
     d04:	ef4080e7          	jalr	-268(ra) # 5bf4 <printf>
    exit(1);
     d08:	4505                	li	a0,1
     d0a:	00005097          	auipc	ra,0x5
     d0e:	b3a080e7          	jalr	-1222(ra) # 5844 <exit>
    close(fds[0]);
     d12:	fa842503          	lw	a0,-88(s0)
     d16:	00005097          	auipc	ra,0x5
     d1a:	b56080e7          	jalr	-1194(ra) # 586c <close>
    for(n = 0; n < N; n++){
     d1e:	0000bb17          	auipc	s6,0xb
     d22:	ea2b0b13          	addi	s6,s6,-350 # bbc0 <buf>
     d26:	416004bb          	negw	s1,s6
     d2a:	0ff4f493          	andi	s1,s1,255
     d2e:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
     d32:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
     d34:	6a85                	lui	s5,0x1
     d36:	42da8a93          	addi	s5,s5,1069 # 142d <validatetest+0x5b>
{
     d3a:	87da                	mv	a5,s6
        buf[i] = seq++;
     d3c:	0097873b          	addw	a4,a5,s1
     d40:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
     d44:	0785                	addi	a5,a5,1
     d46:	fef99be3          	bne	s3,a5,d3c <pipe1+0xe2>
        buf[i] = seq++;
     d4a:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
     d4e:	40900613          	li	a2,1033
     d52:	85de                	mv	a1,s7
     d54:	fac42503          	lw	a0,-84(s0)
     d58:	00005097          	auipc	ra,0x5
     d5c:	b0c080e7          	jalr	-1268(ra) # 5864 <write>
     d60:	40900793          	li	a5,1033
     d64:	00f51c63          	bne	a0,a5,d7c <pipe1+0x122>
    for(n = 0; n < N; n++){
     d68:	24a5                	addiw	s1,s1,9
     d6a:	0ff4f493          	andi	s1,s1,255
     d6e:	fd5a16e3          	bne	s4,s5,d3a <pipe1+0xe0>
    exit(0);
     d72:	4501                	li	a0,0
     d74:	00005097          	auipc	ra,0x5
     d78:	ad0080e7          	jalr	-1328(ra) # 5844 <exit>
        printf("%s: pipe1 oops 1\n", s);
     d7c:	85ca                	mv	a1,s2
     d7e:	00005517          	auipc	a0,0x5
     d82:	6f250513          	addi	a0,a0,1778 # 6470 <malloc+0x7be>
     d86:	00005097          	auipc	ra,0x5
     d8a:	e6e080e7          	jalr	-402(ra) # 5bf4 <printf>
        exit(1);
     d8e:	4505                	li	a0,1
     d90:	00005097          	auipc	ra,0x5
     d94:	ab4080e7          	jalr	-1356(ra) # 5844 <exit>
          printf("%s: pipe1 oops 2\n", s);
     d98:	85ca                	mv	a1,s2
     d9a:	00005517          	auipc	a0,0x5
     d9e:	6ee50513          	addi	a0,a0,1774 # 6488 <malloc+0x7d6>
     da2:	00005097          	auipc	ra,0x5
     da6:	e52080e7          	jalr	-430(ra) # 5bf4 <printf>
}
     daa:	60e6                	ld	ra,88(sp)
     dac:	6446                	ld	s0,80(sp)
     dae:	64a6                	ld	s1,72(sp)
     db0:	6906                	ld	s2,64(sp)
     db2:	79e2                	ld	s3,56(sp)
     db4:	7a42                	ld	s4,48(sp)
     db6:	7aa2                	ld	s5,40(sp)
     db8:	7b02                	ld	s6,32(sp)
     dba:	6be2                	ld	s7,24(sp)
     dbc:	6125                	addi	sp,sp,96
     dbe:	8082                	ret
    if(total != N * SZ){
     dc0:	6785                	lui	a5,0x1
     dc2:	42d78793          	addi	a5,a5,1069 # 142d <validatetest+0x5b>
     dc6:	02fa0063          	beq	s4,a5,de6 <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
     dca:	85d2                	mv	a1,s4
     dcc:	00005517          	auipc	a0,0x5
     dd0:	6d450513          	addi	a0,a0,1748 # 64a0 <malloc+0x7ee>
     dd4:	00005097          	auipc	ra,0x5
     dd8:	e20080e7          	jalr	-480(ra) # 5bf4 <printf>
      exit(1);
     ddc:	4505                	li	a0,1
     dde:	00005097          	auipc	ra,0x5
     de2:	a66080e7          	jalr	-1434(ra) # 5844 <exit>
    close(fds[0]);
     de6:	fa842503          	lw	a0,-88(s0)
     dea:	00005097          	auipc	ra,0x5
     dee:	a82080e7          	jalr	-1406(ra) # 586c <close>
    wait(&xstatus);
     df2:	fa440513          	addi	a0,s0,-92
     df6:	00005097          	auipc	ra,0x5
     dfa:	a56080e7          	jalr	-1450(ra) # 584c <wait>
    exit(xstatus);
     dfe:	fa442503          	lw	a0,-92(s0)
     e02:	00005097          	auipc	ra,0x5
     e06:	a42080e7          	jalr	-1470(ra) # 5844 <exit>
    printf("%s: fork() failed\n", s);
     e0a:	85ca                	mv	a1,s2
     e0c:	00005517          	auipc	a0,0x5
     e10:	6b450513          	addi	a0,a0,1716 # 64c0 <malloc+0x80e>
     e14:	00005097          	auipc	ra,0x5
     e18:	de0080e7          	jalr	-544(ra) # 5bf4 <printf>
    exit(1);
     e1c:	4505                	li	a0,1
     e1e:	00005097          	auipc	ra,0x5
     e22:	a26080e7          	jalr	-1498(ra) # 5844 <exit>

0000000000000e26 <preempt>:
{
     e26:	7139                	addi	sp,sp,-64
     e28:	fc06                	sd	ra,56(sp)
     e2a:	f822                	sd	s0,48(sp)
     e2c:	f426                	sd	s1,40(sp)
     e2e:	f04a                	sd	s2,32(sp)
     e30:	ec4e                	sd	s3,24(sp)
     e32:	e852                	sd	s4,16(sp)
     e34:	0080                	addi	s0,sp,64
     e36:	892a                	mv	s2,a0
  pid1 = fork();
     e38:	00005097          	auipc	ra,0x5
     e3c:	a04080e7          	jalr	-1532(ra) # 583c <fork>
  if(pid1 < 0) {
     e40:	00054563          	bltz	a0,e4a <preempt+0x24>
     e44:	84aa                	mv	s1,a0
  if(pid1 == 0)
     e46:	e105                	bnez	a0,e66 <preempt+0x40>
    for(;;)
     e48:	a001                	j	e48 <preempt+0x22>
    printf("%s: fork failed", s);
     e4a:	85ca                	mv	a1,s2
     e4c:	00005517          	auipc	a0,0x5
     e50:	1fc50513          	addi	a0,a0,508 # 6048 <malloc+0x396>
     e54:	00005097          	auipc	ra,0x5
     e58:	da0080e7          	jalr	-608(ra) # 5bf4 <printf>
    exit(1);
     e5c:	4505                	li	a0,1
     e5e:	00005097          	auipc	ra,0x5
     e62:	9e6080e7          	jalr	-1562(ra) # 5844 <exit>
  pid2 = fork();
     e66:	00005097          	auipc	ra,0x5
     e6a:	9d6080e7          	jalr	-1578(ra) # 583c <fork>
     e6e:	89aa                	mv	s3,a0
  if(pid2 < 0) {
     e70:	00054463          	bltz	a0,e78 <preempt+0x52>
  if(pid2 == 0)
     e74:	e105                	bnez	a0,e94 <preempt+0x6e>
    for(;;)
     e76:	a001                	j	e76 <preempt+0x50>
    printf("%s: fork failed\n", s);
     e78:	85ca                	mv	a1,s2
     e7a:	00005517          	auipc	a0,0x5
     e7e:	17e50513          	addi	a0,a0,382 # 5ff8 <malloc+0x346>
     e82:	00005097          	auipc	ra,0x5
     e86:	d72080e7          	jalr	-654(ra) # 5bf4 <printf>
    exit(1);
     e8a:	4505                	li	a0,1
     e8c:	00005097          	auipc	ra,0x5
     e90:	9b8080e7          	jalr	-1608(ra) # 5844 <exit>
  pipe(pfds);
     e94:	fc840513          	addi	a0,s0,-56
     e98:	00005097          	auipc	ra,0x5
     e9c:	9bc080e7          	jalr	-1604(ra) # 5854 <pipe>
  pid3 = fork();
     ea0:	00005097          	auipc	ra,0x5
     ea4:	99c080e7          	jalr	-1636(ra) # 583c <fork>
     ea8:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
     eaa:	02054e63          	bltz	a0,ee6 <preempt+0xc0>
  if(pid3 == 0){
     eae:	e525                	bnez	a0,f16 <preempt+0xf0>
    close(pfds[0]);
     eb0:	fc842503          	lw	a0,-56(s0)
     eb4:	00005097          	auipc	ra,0x5
     eb8:	9b8080e7          	jalr	-1608(ra) # 586c <close>
    if(write(pfds[1], "x", 1) != 1)
     ebc:	4605                	li	a2,1
     ebe:	00005597          	auipc	a1,0x5
     ec2:	32258593          	addi	a1,a1,802 # 61e0 <malloc+0x52e>
     ec6:	fcc42503          	lw	a0,-52(s0)
     eca:	00005097          	auipc	ra,0x5
     ece:	99a080e7          	jalr	-1638(ra) # 5864 <write>
     ed2:	4785                	li	a5,1
     ed4:	02f51763          	bne	a0,a5,f02 <preempt+0xdc>
    close(pfds[1]);
     ed8:	fcc42503          	lw	a0,-52(s0)
     edc:	00005097          	auipc	ra,0x5
     ee0:	990080e7          	jalr	-1648(ra) # 586c <close>
    for(;;)
     ee4:	a001                	j	ee4 <preempt+0xbe>
     printf("%s: fork failed\n", s);
     ee6:	85ca                	mv	a1,s2
     ee8:	00005517          	auipc	a0,0x5
     eec:	11050513          	addi	a0,a0,272 # 5ff8 <malloc+0x346>
     ef0:	00005097          	auipc	ra,0x5
     ef4:	d04080e7          	jalr	-764(ra) # 5bf4 <printf>
     exit(1);
     ef8:	4505                	li	a0,1
     efa:	00005097          	auipc	ra,0x5
     efe:	94a080e7          	jalr	-1718(ra) # 5844 <exit>
      printf("%s: preempt write error", s);
     f02:	85ca                	mv	a1,s2
     f04:	00005517          	auipc	a0,0x5
     f08:	5d450513          	addi	a0,a0,1492 # 64d8 <malloc+0x826>
     f0c:	00005097          	auipc	ra,0x5
     f10:	ce8080e7          	jalr	-792(ra) # 5bf4 <printf>
     f14:	b7d1                	j	ed8 <preempt+0xb2>
  close(pfds[1]);
     f16:	fcc42503          	lw	a0,-52(s0)
     f1a:	00005097          	auipc	ra,0x5
     f1e:	952080e7          	jalr	-1710(ra) # 586c <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
     f22:	660d                	lui	a2,0x3
     f24:	0000b597          	auipc	a1,0xb
     f28:	c9c58593          	addi	a1,a1,-868 # bbc0 <buf>
     f2c:	fc842503          	lw	a0,-56(s0)
     f30:	00005097          	auipc	ra,0x5
     f34:	92c080e7          	jalr	-1748(ra) # 585c <read>
     f38:	4785                	li	a5,1
     f3a:	02f50363          	beq	a0,a5,f60 <preempt+0x13a>
    printf("%s: preempt read error", s);
     f3e:	85ca                	mv	a1,s2
     f40:	00005517          	auipc	a0,0x5
     f44:	5b050513          	addi	a0,a0,1456 # 64f0 <malloc+0x83e>
     f48:	00005097          	auipc	ra,0x5
     f4c:	cac080e7          	jalr	-852(ra) # 5bf4 <printf>
}
     f50:	70e2                	ld	ra,56(sp)
     f52:	7442                	ld	s0,48(sp)
     f54:	74a2                	ld	s1,40(sp)
     f56:	7902                	ld	s2,32(sp)
     f58:	69e2                	ld	s3,24(sp)
     f5a:	6a42                	ld	s4,16(sp)
     f5c:	6121                	addi	sp,sp,64
     f5e:	8082                	ret
  close(pfds[0]);
     f60:	fc842503          	lw	a0,-56(s0)
     f64:	00005097          	auipc	ra,0x5
     f68:	908080e7          	jalr	-1784(ra) # 586c <close>
  printf("kill... ");
     f6c:	00005517          	auipc	a0,0x5
     f70:	59c50513          	addi	a0,a0,1436 # 6508 <malloc+0x856>
     f74:	00005097          	auipc	ra,0x5
     f78:	c80080e7          	jalr	-896(ra) # 5bf4 <printf>
  kill(pid1, SIGKILL);
     f7c:	45a5                	li	a1,9
     f7e:	8526                	mv	a0,s1
     f80:	00005097          	auipc	ra,0x5
     f84:	8f4080e7          	jalr	-1804(ra) # 5874 <kill>
  kill(pid2, SIGKILL);
     f88:	45a5                	li	a1,9
     f8a:	854e                	mv	a0,s3
     f8c:	00005097          	auipc	ra,0x5
     f90:	8e8080e7          	jalr	-1816(ra) # 5874 <kill>
  kill(pid3, SIGKILL);
     f94:	45a5                	li	a1,9
     f96:	8552                	mv	a0,s4
     f98:	00005097          	auipc	ra,0x5
     f9c:	8dc080e7          	jalr	-1828(ra) # 5874 <kill>
  printf("wait... ");
     fa0:	00005517          	auipc	a0,0x5
     fa4:	57850513          	addi	a0,a0,1400 # 6518 <malloc+0x866>
     fa8:	00005097          	auipc	ra,0x5
     fac:	c4c080e7          	jalr	-948(ra) # 5bf4 <printf>
  wait(0);
     fb0:	4501                	li	a0,0
     fb2:	00005097          	auipc	ra,0x5
     fb6:	89a080e7          	jalr	-1894(ra) # 584c <wait>
  wait(0);
     fba:	4501                	li	a0,0
     fbc:	00005097          	auipc	ra,0x5
     fc0:	890080e7          	jalr	-1904(ra) # 584c <wait>
  wait(0);
     fc4:	4501                	li	a0,0
     fc6:	00005097          	auipc	ra,0x5
     fca:	886080e7          	jalr	-1914(ra) # 584c <wait>
     fce:	b749                	j	f50 <preempt+0x12a>

0000000000000fd0 <unlinkread>:
{
     fd0:	7179                	addi	sp,sp,-48
     fd2:	f406                	sd	ra,40(sp)
     fd4:	f022                	sd	s0,32(sp)
     fd6:	ec26                	sd	s1,24(sp)
     fd8:	e84a                	sd	s2,16(sp)
     fda:	e44e                	sd	s3,8(sp)
     fdc:	1800                	addi	s0,sp,48
     fde:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     fe0:	20200593          	li	a1,514
     fe4:	00005517          	auipc	a0,0x5
     fe8:	ebc50513          	addi	a0,a0,-324 # 5ea0 <malloc+0x1ee>
     fec:	00005097          	auipc	ra,0x5
     ff0:	898080e7          	jalr	-1896(ra) # 5884 <open>
  if(fd < 0){
     ff4:	0e054563          	bltz	a0,10de <unlinkread+0x10e>
     ff8:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     ffa:	4615                	li	a2,5
     ffc:	00005597          	auipc	a1,0x5
    1000:	54c58593          	addi	a1,a1,1356 # 6548 <malloc+0x896>
    1004:	00005097          	auipc	ra,0x5
    1008:	860080e7          	jalr	-1952(ra) # 5864 <write>
  close(fd);
    100c:	8526                	mv	a0,s1
    100e:	00005097          	auipc	ra,0x5
    1012:	85e080e7          	jalr	-1954(ra) # 586c <close>
  fd = open("unlinkread", O_RDWR);
    1016:	4589                	li	a1,2
    1018:	00005517          	auipc	a0,0x5
    101c:	e8850513          	addi	a0,a0,-376 # 5ea0 <malloc+0x1ee>
    1020:	00005097          	auipc	ra,0x5
    1024:	864080e7          	jalr	-1948(ra) # 5884 <open>
    1028:	84aa                	mv	s1,a0
  if(fd < 0){
    102a:	0c054863          	bltz	a0,10fa <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
    102e:	00005517          	auipc	a0,0x5
    1032:	e7250513          	addi	a0,a0,-398 # 5ea0 <malloc+0x1ee>
    1036:	00005097          	auipc	ra,0x5
    103a:	85e080e7          	jalr	-1954(ra) # 5894 <unlink>
    103e:	ed61                	bnez	a0,1116 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    1040:	20200593          	li	a1,514
    1044:	00005517          	auipc	a0,0x5
    1048:	e5c50513          	addi	a0,a0,-420 # 5ea0 <malloc+0x1ee>
    104c:	00005097          	auipc	ra,0x5
    1050:	838080e7          	jalr	-1992(ra) # 5884 <open>
    1054:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
    1056:	460d                	li	a2,3
    1058:	00005597          	auipc	a1,0x5
    105c:	53858593          	addi	a1,a1,1336 # 6590 <malloc+0x8de>
    1060:	00005097          	auipc	ra,0x5
    1064:	804080e7          	jalr	-2044(ra) # 5864 <write>
  close(fd1);
    1068:	854a                	mv	a0,s2
    106a:	00005097          	auipc	ra,0x5
    106e:	802080e7          	jalr	-2046(ra) # 586c <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
    1072:	660d                	lui	a2,0x3
    1074:	0000b597          	auipc	a1,0xb
    1078:	b4c58593          	addi	a1,a1,-1204 # bbc0 <buf>
    107c:	8526                	mv	a0,s1
    107e:	00004097          	auipc	ra,0x4
    1082:	7de080e7          	jalr	2014(ra) # 585c <read>
    1086:	4795                	li	a5,5
    1088:	0af51563          	bne	a0,a5,1132 <unlinkread+0x162>
  if(buf[0] != 'h'){
    108c:	0000b717          	auipc	a4,0xb
    1090:	b3474703          	lbu	a4,-1228(a4) # bbc0 <buf>
    1094:	06800793          	li	a5,104
    1098:	0af71b63          	bne	a4,a5,114e <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
    109c:	4629                	li	a2,10
    109e:	0000b597          	auipc	a1,0xb
    10a2:	b2258593          	addi	a1,a1,-1246 # bbc0 <buf>
    10a6:	8526                	mv	a0,s1
    10a8:	00004097          	auipc	ra,0x4
    10ac:	7bc080e7          	jalr	1980(ra) # 5864 <write>
    10b0:	47a9                	li	a5,10
    10b2:	0af51c63          	bne	a0,a5,116a <unlinkread+0x19a>
  close(fd);
    10b6:	8526                	mv	a0,s1
    10b8:	00004097          	auipc	ra,0x4
    10bc:	7b4080e7          	jalr	1972(ra) # 586c <close>
  unlink("unlinkread");
    10c0:	00005517          	auipc	a0,0x5
    10c4:	de050513          	addi	a0,a0,-544 # 5ea0 <malloc+0x1ee>
    10c8:	00004097          	auipc	ra,0x4
    10cc:	7cc080e7          	jalr	1996(ra) # 5894 <unlink>
}
    10d0:	70a2                	ld	ra,40(sp)
    10d2:	7402                	ld	s0,32(sp)
    10d4:	64e2                	ld	s1,24(sp)
    10d6:	6942                	ld	s2,16(sp)
    10d8:	69a2                	ld	s3,8(sp)
    10da:	6145                	addi	sp,sp,48
    10dc:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
    10de:	85ce                	mv	a1,s3
    10e0:	00005517          	auipc	a0,0x5
    10e4:	44850513          	addi	a0,a0,1096 # 6528 <malloc+0x876>
    10e8:	00005097          	auipc	ra,0x5
    10ec:	b0c080e7          	jalr	-1268(ra) # 5bf4 <printf>
    exit(1);
    10f0:	4505                	li	a0,1
    10f2:	00004097          	auipc	ra,0x4
    10f6:	752080e7          	jalr	1874(ra) # 5844 <exit>
    printf("%s: open unlinkread failed\n", s);
    10fa:	85ce                	mv	a1,s3
    10fc:	00005517          	auipc	a0,0x5
    1100:	45450513          	addi	a0,a0,1108 # 6550 <malloc+0x89e>
    1104:	00005097          	auipc	ra,0x5
    1108:	af0080e7          	jalr	-1296(ra) # 5bf4 <printf>
    exit(1);
    110c:	4505                	li	a0,1
    110e:	00004097          	auipc	ra,0x4
    1112:	736080e7          	jalr	1846(ra) # 5844 <exit>
    printf("%s: unlink unlinkread failed\n", s);
    1116:	85ce                	mv	a1,s3
    1118:	00005517          	auipc	a0,0x5
    111c:	45850513          	addi	a0,a0,1112 # 6570 <malloc+0x8be>
    1120:	00005097          	auipc	ra,0x5
    1124:	ad4080e7          	jalr	-1324(ra) # 5bf4 <printf>
    exit(1);
    1128:	4505                	li	a0,1
    112a:	00004097          	auipc	ra,0x4
    112e:	71a080e7          	jalr	1818(ra) # 5844 <exit>
    printf("%s: unlinkread read failed", s);
    1132:	85ce                	mv	a1,s3
    1134:	00005517          	auipc	a0,0x5
    1138:	46450513          	addi	a0,a0,1124 # 6598 <malloc+0x8e6>
    113c:	00005097          	auipc	ra,0x5
    1140:	ab8080e7          	jalr	-1352(ra) # 5bf4 <printf>
    exit(1);
    1144:	4505                	li	a0,1
    1146:	00004097          	auipc	ra,0x4
    114a:	6fe080e7          	jalr	1790(ra) # 5844 <exit>
    printf("%s: unlinkread wrong data\n", s);
    114e:	85ce                	mv	a1,s3
    1150:	00005517          	auipc	a0,0x5
    1154:	46850513          	addi	a0,a0,1128 # 65b8 <malloc+0x906>
    1158:	00005097          	auipc	ra,0x5
    115c:	a9c080e7          	jalr	-1380(ra) # 5bf4 <printf>
    exit(1);
    1160:	4505                	li	a0,1
    1162:	00004097          	auipc	ra,0x4
    1166:	6e2080e7          	jalr	1762(ra) # 5844 <exit>
    printf("%s: unlinkread write failed\n", s);
    116a:	85ce                	mv	a1,s3
    116c:	00005517          	auipc	a0,0x5
    1170:	46c50513          	addi	a0,a0,1132 # 65d8 <malloc+0x926>
    1174:	00005097          	auipc	ra,0x5
    1178:	a80080e7          	jalr	-1408(ra) # 5bf4 <printf>
    exit(1);
    117c:	4505                	li	a0,1
    117e:	00004097          	auipc	ra,0x4
    1182:	6c6080e7          	jalr	1734(ra) # 5844 <exit>

0000000000001186 <linktest>:
{
    1186:	1101                	addi	sp,sp,-32
    1188:	ec06                	sd	ra,24(sp)
    118a:	e822                	sd	s0,16(sp)
    118c:	e426                	sd	s1,8(sp)
    118e:	e04a                	sd	s2,0(sp)
    1190:	1000                	addi	s0,sp,32
    1192:	892a                	mv	s2,a0
  unlink("lf1");
    1194:	00005517          	auipc	a0,0x5
    1198:	46450513          	addi	a0,a0,1124 # 65f8 <malloc+0x946>
    119c:	00004097          	auipc	ra,0x4
    11a0:	6f8080e7          	jalr	1784(ra) # 5894 <unlink>
  unlink("lf2");
    11a4:	00005517          	auipc	a0,0x5
    11a8:	45c50513          	addi	a0,a0,1116 # 6600 <malloc+0x94e>
    11ac:	00004097          	auipc	ra,0x4
    11b0:	6e8080e7          	jalr	1768(ra) # 5894 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
    11b4:	20200593          	li	a1,514
    11b8:	00005517          	auipc	a0,0x5
    11bc:	44050513          	addi	a0,a0,1088 # 65f8 <malloc+0x946>
    11c0:	00004097          	auipc	ra,0x4
    11c4:	6c4080e7          	jalr	1732(ra) # 5884 <open>
  if(fd < 0){
    11c8:	10054763          	bltz	a0,12d6 <linktest+0x150>
    11cc:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
    11ce:	4615                	li	a2,5
    11d0:	00005597          	auipc	a1,0x5
    11d4:	37858593          	addi	a1,a1,888 # 6548 <malloc+0x896>
    11d8:	00004097          	auipc	ra,0x4
    11dc:	68c080e7          	jalr	1676(ra) # 5864 <write>
    11e0:	4795                	li	a5,5
    11e2:	10f51863          	bne	a0,a5,12f2 <linktest+0x16c>
  close(fd);
    11e6:	8526                	mv	a0,s1
    11e8:	00004097          	auipc	ra,0x4
    11ec:	684080e7          	jalr	1668(ra) # 586c <close>
  if(link("lf1", "lf2") < 0){
    11f0:	00005597          	auipc	a1,0x5
    11f4:	41058593          	addi	a1,a1,1040 # 6600 <malloc+0x94e>
    11f8:	00005517          	auipc	a0,0x5
    11fc:	40050513          	addi	a0,a0,1024 # 65f8 <malloc+0x946>
    1200:	00004097          	auipc	ra,0x4
    1204:	6a4080e7          	jalr	1700(ra) # 58a4 <link>
    1208:	10054363          	bltz	a0,130e <linktest+0x188>
  unlink("lf1");
    120c:	00005517          	auipc	a0,0x5
    1210:	3ec50513          	addi	a0,a0,1004 # 65f8 <malloc+0x946>
    1214:	00004097          	auipc	ra,0x4
    1218:	680080e7          	jalr	1664(ra) # 5894 <unlink>
  if(open("lf1", 0) >= 0){
    121c:	4581                	li	a1,0
    121e:	00005517          	auipc	a0,0x5
    1222:	3da50513          	addi	a0,a0,986 # 65f8 <malloc+0x946>
    1226:	00004097          	auipc	ra,0x4
    122a:	65e080e7          	jalr	1630(ra) # 5884 <open>
    122e:	0e055e63          	bgez	a0,132a <linktest+0x1a4>
  fd = open("lf2", 0);
    1232:	4581                	li	a1,0
    1234:	00005517          	auipc	a0,0x5
    1238:	3cc50513          	addi	a0,a0,972 # 6600 <malloc+0x94e>
    123c:	00004097          	auipc	ra,0x4
    1240:	648080e7          	jalr	1608(ra) # 5884 <open>
    1244:	84aa                	mv	s1,a0
  if(fd < 0){
    1246:	10054063          	bltz	a0,1346 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
    124a:	660d                	lui	a2,0x3
    124c:	0000b597          	auipc	a1,0xb
    1250:	97458593          	addi	a1,a1,-1676 # bbc0 <buf>
    1254:	00004097          	auipc	ra,0x4
    1258:	608080e7          	jalr	1544(ra) # 585c <read>
    125c:	4795                	li	a5,5
    125e:	10f51263          	bne	a0,a5,1362 <linktest+0x1dc>
  close(fd);
    1262:	8526                	mv	a0,s1
    1264:	00004097          	auipc	ra,0x4
    1268:	608080e7          	jalr	1544(ra) # 586c <close>
  if(link("lf2", "lf2") >= 0){
    126c:	00005597          	auipc	a1,0x5
    1270:	39458593          	addi	a1,a1,916 # 6600 <malloc+0x94e>
    1274:	852e                	mv	a0,a1
    1276:	00004097          	auipc	ra,0x4
    127a:	62e080e7          	jalr	1582(ra) # 58a4 <link>
    127e:	10055063          	bgez	a0,137e <linktest+0x1f8>
  unlink("lf2");
    1282:	00005517          	auipc	a0,0x5
    1286:	37e50513          	addi	a0,a0,894 # 6600 <malloc+0x94e>
    128a:	00004097          	auipc	ra,0x4
    128e:	60a080e7          	jalr	1546(ra) # 5894 <unlink>
  if(link("lf2", "lf1") >= 0){
    1292:	00005597          	auipc	a1,0x5
    1296:	36658593          	addi	a1,a1,870 # 65f8 <malloc+0x946>
    129a:	00005517          	auipc	a0,0x5
    129e:	36650513          	addi	a0,a0,870 # 6600 <malloc+0x94e>
    12a2:	00004097          	auipc	ra,0x4
    12a6:	602080e7          	jalr	1538(ra) # 58a4 <link>
    12aa:	0e055863          	bgez	a0,139a <linktest+0x214>
  if(link(".", "lf1") >= 0){
    12ae:	00005597          	auipc	a1,0x5
    12b2:	34a58593          	addi	a1,a1,842 # 65f8 <malloc+0x946>
    12b6:	00005517          	auipc	a0,0x5
    12ba:	45250513          	addi	a0,a0,1106 # 6708 <malloc+0xa56>
    12be:	00004097          	auipc	ra,0x4
    12c2:	5e6080e7          	jalr	1510(ra) # 58a4 <link>
    12c6:	0e055863          	bgez	a0,13b6 <linktest+0x230>
}
    12ca:	60e2                	ld	ra,24(sp)
    12cc:	6442                	ld	s0,16(sp)
    12ce:	64a2                	ld	s1,8(sp)
    12d0:	6902                	ld	s2,0(sp)
    12d2:	6105                	addi	sp,sp,32
    12d4:	8082                	ret
    printf("%s: create lf1 failed\n", s);
    12d6:	85ca                	mv	a1,s2
    12d8:	00005517          	auipc	a0,0x5
    12dc:	33050513          	addi	a0,a0,816 # 6608 <malloc+0x956>
    12e0:	00005097          	auipc	ra,0x5
    12e4:	914080e7          	jalr	-1772(ra) # 5bf4 <printf>
    exit(1);
    12e8:	4505                	li	a0,1
    12ea:	00004097          	auipc	ra,0x4
    12ee:	55a080e7          	jalr	1370(ra) # 5844 <exit>
    printf("%s: write lf1 failed\n", s);
    12f2:	85ca                	mv	a1,s2
    12f4:	00005517          	auipc	a0,0x5
    12f8:	32c50513          	addi	a0,a0,812 # 6620 <malloc+0x96e>
    12fc:	00005097          	auipc	ra,0x5
    1300:	8f8080e7          	jalr	-1800(ra) # 5bf4 <printf>
    exit(1);
    1304:	4505                	li	a0,1
    1306:	00004097          	auipc	ra,0x4
    130a:	53e080e7          	jalr	1342(ra) # 5844 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
    130e:	85ca                	mv	a1,s2
    1310:	00005517          	auipc	a0,0x5
    1314:	32850513          	addi	a0,a0,808 # 6638 <malloc+0x986>
    1318:	00005097          	auipc	ra,0x5
    131c:	8dc080e7          	jalr	-1828(ra) # 5bf4 <printf>
    exit(1);
    1320:	4505                	li	a0,1
    1322:	00004097          	auipc	ra,0x4
    1326:	522080e7          	jalr	1314(ra) # 5844 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
    132a:	85ca                	mv	a1,s2
    132c:	00005517          	auipc	a0,0x5
    1330:	32c50513          	addi	a0,a0,812 # 6658 <malloc+0x9a6>
    1334:	00005097          	auipc	ra,0x5
    1338:	8c0080e7          	jalr	-1856(ra) # 5bf4 <printf>
    exit(1);
    133c:	4505                	li	a0,1
    133e:	00004097          	auipc	ra,0x4
    1342:	506080e7          	jalr	1286(ra) # 5844 <exit>
    printf("%s: open lf2 failed\n", s);
    1346:	85ca                	mv	a1,s2
    1348:	00005517          	auipc	a0,0x5
    134c:	34050513          	addi	a0,a0,832 # 6688 <malloc+0x9d6>
    1350:	00005097          	auipc	ra,0x5
    1354:	8a4080e7          	jalr	-1884(ra) # 5bf4 <printf>
    exit(1);
    1358:	4505                	li	a0,1
    135a:	00004097          	auipc	ra,0x4
    135e:	4ea080e7          	jalr	1258(ra) # 5844 <exit>
    printf("%s: read lf2 failed\n", s);
    1362:	85ca                	mv	a1,s2
    1364:	00005517          	auipc	a0,0x5
    1368:	33c50513          	addi	a0,a0,828 # 66a0 <malloc+0x9ee>
    136c:	00005097          	auipc	ra,0x5
    1370:	888080e7          	jalr	-1912(ra) # 5bf4 <printf>
    exit(1);
    1374:	4505                	li	a0,1
    1376:	00004097          	auipc	ra,0x4
    137a:	4ce080e7          	jalr	1230(ra) # 5844 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
    137e:	85ca                	mv	a1,s2
    1380:	00005517          	auipc	a0,0x5
    1384:	33850513          	addi	a0,a0,824 # 66b8 <malloc+0xa06>
    1388:	00005097          	auipc	ra,0x5
    138c:	86c080e7          	jalr	-1940(ra) # 5bf4 <printf>
    exit(1);
    1390:	4505                	li	a0,1
    1392:	00004097          	auipc	ra,0x4
    1396:	4b2080e7          	jalr	1202(ra) # 5844 <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
    139a:	85ca                	mv	a1,s2
    139c:	00005517          	auipc	a0,0x5
    13a0:	34450513          	addi	a0,a0,836 # 66e0 <malloc+0xa2e>
    13a4:	00005097          	auipc	ra,0x5
    13a8:	850080e7          	jalr	-1968(ra) # 5bf4 <printf>
    exit(1);
    13ac:	4505                	li	a0,1
    13ae:	00004097          	auipc	ra,0x4
    13b2:	496080e7          	jalr	1174(ra) # 5844 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
    13b6:	85ca                	mv	a1,s2
    13b8:	00005517          	auipc	a0,0x5
    13bc:	35850513          	addi	a0,a0,856 # 6710 <malloc+0xa5e>
    13c0:	00005097          	auipc	ra,0x5
    13c4:	834080e7          	jalr	-1996(ra) # 5bf4 <printf>
    exit(1);
    13c8:	4505                	li	a0,1
    13ca:	00004097          	auipc	ra,0x4
    13ce:	47a080e7          	jalr	1146(ra) # 5844 <exit>

00000000000013d2 <validatetest>:
{
    13d2:	7139                	addi	sp,sp,-64
    13d4:	fc06                	sd	ra,56(sp)
    13d6:	f822                	sd	s0,48(sp)
    13d8:	f426                	sd	s1,40(sp)
    13da:	f04a                	sd	s2,32(sp)
    13dc:	ec4e                	sd	s3,24(sp)
    13de:	e852                	sd	s4,16(sp)
    13e0:	e456                	sd	s5,8(sp)
    13e2:	e05a                	sd	s6,0(sp)
    13e4:	0080                	addi	s0,sp,64
    13e6:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    13e8:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    13ea:	00005997          	auipc	s3,0x5
    13ee:	34698993          	addi	s3,s3,838 # 6730 <malloc+0xa7e>
    13f2:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    13f4:	6a85                	lui	s5,0x1
    13f6:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    13fa:	85a6                	mv	a1,s1
    13fc:	854e                	mv	a0,s3
    13fe:	00004097          	auipc	ra,0x4
    1402:	4a6080e7          	jalr	1190(ra) # 58a4 <link>
    1406:	01251f63          	bne	a0,s2,1424 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    140a:	94d6                	add	s1,s1,s5
    140c:	ff4497e3          	bne	s1,s4,13fa <validatetest+0x28>
}
    1410:	70e2                	ld	ra,56(sp)
    1412:	7442                	ld	s0,48(sp)
    1414:	74a2                	ld	s1,40(sp)
    1416:	7902                	ld	s2,32(sp)
    1418:	69e2                	ld	s3,24(sp)
    141a:	6a42                	ld	s4,16(sp)
    141c:	6aa2                	ld	s5,8(sp)
    141e:	6b02                	ld	s6,0(sp)
    1420:	6121                	addi	sp,sp,64
    1422:	8082                	ret
      printf("%s: link should not succeed\n", s);
    1424:	85da                	mv	a1,s6
    1426:	00005517          	auipc	a0,0x5
    142a:	31a50513          	addi	a0,a0,794 # 6740 <malloc+0xa8e>
    142e:	00004097          	auipc	ra,0x4
    1432:	7c6080e7          	jalr	1990(ra) # 5bf4 <printf>
      exit(1);
    1436:	4505                	li	a0,1
    1438:	00004097          	auipc	ra,0x4
    143c:	40c080e7          	jalr	1036(ra) # 5844 <exit>

0000000000001440 <copyinstr2>:
{
    1440:	7155                	addi	sp,sp,-208
    1442:	e586                	sd	ra,200(sp)
    1444:	e1a2                	sd	s0,192(sp)
    1446:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    1448:	f6840793          	addi	a5,s0,-152
    144c:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    1450:	07800713          	li	a4,120
    1454:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    1458:	0785                	addi	a5,a5,1
    145a:	fed79de3          	bne	a5,a3,1454 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    145e:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    1462:	f6840513          	addi	a0,s0,-152
    1466:	00004097          	auipc	ra,0x4
    146a:	42e080e7          	jalr	1070(ra) # 5894 <unlink>
  if(ret != -1){
    146e:	57fd                	li	a5,-1
    1470:	0ef51063          	bne	a0,a5,1550 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    1474:	20100593          	li	a1,513
    1478:	f6840513          	addi	a0,s0,-152
    147c:	00004097          	auipc	ra,0x4
    1480:	408080e7          	jalr	1032(ra) # 5884 <open>
  if(fd != -1){
    1484:	57fd                	li	a5,-1
    1486:	0ef51563          	bne	a0,a5,1570 <copyinstr2+0x130>
  ret = link(b, b);
    148a:	f6840593          	addi	a1,s0,-152
    148e:	852e                	mv	a0,a1
    1490:	00004097          	auipc	ra,0x4
    1494:	414080e7          	jalr	1044(ra) # 58a4 <link>
  if(ret != -1){
    1498:	57fd                	li	a5,-1
    149a:	0ef51b63          	bne	a0,a5,1590 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    149e:	00006797          	auipc	a5,0x6
    14a2:	07a78793          	addi	a5,a5,122 # 7518 <malloc+0x1866>
    14a6:	f4f43c23          	sd	a5,-168(s0)
    14aa:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    14ae:	f5840593          	addi	a1,s0,-168
    14b2:	f6840513          	addi	a0,s0,-152
    14b6:	00004097          	auipc	ra,0x4
    14ba:	3c6080e7          	jalr	966(ra) # 587c <exec>
  if(ret != -1){
    14be:	57fd                	li	a5,-1
    14c0:	0ef51963          	bne	a0,a5,15b2 <copyinstr2+0x172>
  int pid = fork();
    14c4:	00004097          	auipc	ra,0x4
    14c8:	378080e7          	jalr	888(ra) # 583c <fork>
  if(pid < 0){
    14cc:	10054363          	bltz	a0,15d2 <copyinstr2+0x192>
  if(pid == 0){
    14d0:	12051463          	bnez	a0,15f8 <copyinstr2+0x1b8>
    14d4:	00007797          	auipc	a5,0x7
    14d8:	fd478793          	addi	a5,a5,-44 # 84a8 <big.0>
    14dc:	00008697          	auipc	a3,0x8
    14e0:	fcc68693          	addi	a3,a3,-52 # 94a8 <__global_pointer$+0x920>
      big[i] = 'x';
    14e4:	07800713          	li	a4,120
    14e8:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    14ec:	0785                	addi	a5,a5,1
    14ee:	fed79de3          	bne	a5,a3,14e8 <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    14f2:	00008797          	auipc	a5,0x8
    14f6:	fa078b23          	sb	zero,-74(a5) # 94a8 <__global_pointer$+0x920>
    char *args2[] = { big, big, big, 0 };
    14fa:	00007797          	auipc	a5,0x7
    14fe:	bce78793          	addi	a5,a5,-1074 # 80c8 <malloc+0x2416>
    1502:	6390                	ld	a2,0(a5)
    1504:	6794                	ld	a3,8(a5)
    1506:	6b98                	ld	a4,16(a5)
    1508:	6f9c                	ld	a5,24(a5)
    150a:	f2c43823          	sd	a2,-208(s0)
    150e:	f2d43c23          	sd	a3,-200(s0)
    1512:	f4e43023          	sd	a4,-192(s0)
    1516:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    151a:	f3040593          	addi	a1,s0,-208
    151e:	00005517          	auipc	a0,0x5
    1522:	c5250513          	addi	a0,a0,-942 # 6170 <malloc+0x4be>
    1526:	00004097          	auipc	ra,0x4
    152a:	356080e7          	jalr	854(ra) # 587c <exec>
    if(ret != -1){
    152e:	57fd                	li	a5,-1
    1530:	0af50e63          	beq	a0,a5,15ec <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    1534:	55fd                	li	a1,-1
    1536:	00005517          	auipc	a0,0x5
    153a:	2b250513          	addi	a0,a0,690 # 67e8 <malloc+0xb36>
    153e:	00004097          	auipc	ra,0x4
    1542:	6b6080e7          	jalr	1718(ra) # 5bf4 <printf>
      exit(1);
    1546:	4505                	li	a0,1
    1548:	00004097          	auipc	ra,0x4
    154c:	2fc080e7          	jalr	764(ra) # 5844 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    1550:	862a                	mv	a2,a0
    1552:	f6840593          	addi	a1,s0,-152
    1556:	00005517          	auipc	a0,0x5
    155a:	20a50513          	addi	a0,a0,522 # 6760 <malloc+0xaae>
    155e:	00004097          	auipc	ra,0x4
    1562:	696080e7          	jalr	1686(ra) # 5bf4 <printf>
    exit(1);
    1566:	4505                	li	a0,1
    1568:	00004097          	auipc	ra,0x4
    156c:	2dc080e7          	jalr	732(ra) # 5844 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1570:	862a                	mv	a2,a0
    1572:	f6840593          	addi	a1,s0,-152
    1576:	00005517          	auipc	a0,0x5
    157a:	20a50513          	addi	a0,a0,522 # 6780 <malloc+0xace>
    157e:	00004097          	auipc	ra,0x4
    1582:	676080e7          	jalr	1654(ra) # 5bf4 <printf>
    exit(1);
    1586:	4505                	li	a0,1
    1588:	00004097          	auipc	ra,0x4
    158c:	2bc080e7          	jalr	700(ra) # 5844 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1590:	86aa                	mv	a3,a0
    1592:	f6840613          	addi	a2,s0,-152
    1596:	85b2                	mv	a1,a2
    1598:	00005517          	auipc	a0,0x5
    159c:	20850513          	addi	a0,a0,520 # 67a0 <malloc+0xaee>
    15a0:	00004097          	auipc	ra,0x4
    15a4:	654080e7          	jalr	1620(ra) # 5bf4 <printf>
    exit(1);
    15a8:	4505                	li	a0,1
    15aa:	00004097          	auipc	ra,0x4
    15ae:	29a080e7          	jalr	666(ra) # 5844 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    15b2:	567d                	li	a2,-1
    15b4:	f6840593          	addi	a1,s0,-152
    15b8:	00005517          	auipc	a0,0x5
    15bc:	21050513          	addi	a0,a0,528 # 67c8 <malloc+0xb16>
    15c0:	00004097          	auipc	ra,0x4
    15c4:	634080e7          	jalr	1588(ra) # 5bf4 <printf>
    exit(1);
    15c8:	4505                	li	a0,1
    15ca:	00004097          	auipc	ra,0x4
    15ce:	27a080e7          	jalr	634(ra) # 5844 <exit>
    printf("fork failed\n");
    15d2:	00005517          	auipc	a0,0x5
    15d6:	41e50513          	addi	a0,a0,1054 # 69f0 <malloc+0xd3e>
    15da:	00004097          	auipc	ra,0x4
    15de:	61a080e7          	jalr	1562(ra) # 5bf4 <printf>
    exit(1);
    15e2:	4505                	li	a0,1
    15e4:	00004097          	auipc	ra,0x4
    15e8:	260080e7          	jalr	608(ra) # 5844 <exit>
    exit(747); // OK
    15ec:	2eb00513          	li	a0,747
    15f0:	00004097          	auipc	ra,0x4
    15f4:	254080e7          	jalr	596(ra) # 5844 <exit>
  int st = 0;
    15f8:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    15fc:	f5440513          	addi	a0,s0,-172
    1600:	00004097          	auipc	ra,0x4
    1604:	24c080e7          	jalr	588(ra) # 584c <wait>
  if(st != 747){
    1608:	f5442703          	lw	a4,-172(s0)
    160c:	2eb00793          	li	a5,747
    1610:	00f71663          	bne	a4,a5,161c <copyinstr2+0x1dc>
}
    1614:	60ae                	ld	ra,200(sp)
    1616:	640e                	ld	s0,192(sp)
    1618:	6169                	addi	sp,sp,208
    161a:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    161c:	00005517          	auipc	a0,0x5
    1620:	1f450513          	addi	a0,a0,500 # 6810 <malloc+0xb5e>
    1624:	00004097          	auipc	ra,0x4
    1628:	5d0080e7          	jalr	1488(ra) # 5bf4 <printf>
    exit(1);
    162c:	4505                	li	a0,1
    162e:	00004097          	auipc	ra,0x4
    1632:	216080e7          	jalr	534(ra) # 5844 <exit>

0000000000001636 <exectest>:
{
    1636:	715d                	addi	sp,sp,-80
    1638:	e486                	sd	ra,72(sp)
    163a:	e0a2                	sd	s0,64(sp)
    163c:	fc26                	sd	s1,56(sp)
    163e:	f84a                	sd	s2,48(sp)
    1640:	0880                	addi	s0,sp,80
    1642:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1644:	00005797          	auipc	a5,0x5
    1648:	b2c78793          	addi	a5,a5,-1236 # 6170 <malloc+0x4be>
    164c:	fcf43023          	sd	a5,-64(s0)
    1650:	00005797          	auipc	a5,0x5
    1654:	1f078793          	addi	a5,a5,496 # 6840 <malloc+0xb8e>
    1658:	fcf43423          	sd	a5,-56(s0)
    165c:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    1660:	00005517          	auipc	a0,0x5
    1664:	1e850513          	addi	a0,a0,488 # 6848 <malloc+0xb96>
    1668:	00004097          	auipc	ra,0x4
    166c:	22c080e7          	jalr	556(ra) # 5894 <unlink>
  pid = fork();
    1670:	00004097          	auipc	ra,0x4
    1674:	1cc080e7          	jalr	460(ra) # 583c <fork>
  if(pid < 0) {
    1678:	04054663          	bltz	a0,16c4 <exectest+0x8e>
    167c:	84aa                	mv	s1,a0
  if(pid == 0) {
    167e:	e959                	bnez	a0,1714 <exectest+0xde>
    close(1);
    1680:	4505                	li	a0,1
    1682:	00004097          	auipc	ra,0x4
    1686:	1ea080e7          	jalr	490(ra) # 586c <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    168a:	20100593          	li	a1,513
    168e:	00005517          	auipc	a0,0x5
    1692:	1ba50513          	addi	a0,a0,442 # 6848 <malloc+0xb96>
    1696:	00004097          	auipc	ra,0x4
    169a:	1ee080e7          	jalr	494(ra) # 5884 <open>
    if(fd < 0) {
    169e:	04054163          	bltz	a0,16e0 <exectest+0xaa>
    if(fd != 1) {
    16a2:	4785                	li	a5,1
    16a4:	04f50c63          	beq	a0,a5,16fc <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    16a8:	85ca                	mv	a1,s2
    16aa:	00005517          	auipc	a0,0x5
    16ae:	1be50513          	addi	a0,a0,446 # 6868 <malloc+0xbb6>
    16b2:	00004097          	auipc	ra,0x4
    16b6:	542080e7          	jalr	1346(ra) # 5bf4 <printf>
      exit(1);
    16ba:	4505                	li	a0,1
    16bc:	00004097          	auipc	ra,0x4
    16c0:	188080e7          	jalr	392(ra) # 5844 <exit>
     printf("%s: fork failed\n", s);
    16c4:	85ca                	mv	a1,s2
    16c6:	00005517          	auipc	a0,0x5
    16ca:	93250513          	addi	a0,a0,-1742 # 5ff8 <malloc+0x346>
    16ce:	00004097          	auipc	ra,0x4
    16d2:	526080e7          	jalr	1318(ra) # 5bf4 <printf>
     exit(1);
    16d6:	4505                	li	a0,1
    16d8:	00004097          	auipc	ra,0x4
    16dc:	16c080e7          	jalr	364(ra) # 5844 <exit>
      printf("%s: create failed\n", s);
    16e0:	85ca                	mv	a1,s2
    16e2:	00005517          	auipc	a0,0x5
    16e6:	16e50513          	addi	a0,a0,366 # 6850 <malloc+0xb9e>
    16ea:	00004097          	auipc	ra,0x4
    16ee:	50a080e7          	jalr	1290(ra) # 5bf4 <printf>
      exit(1);
    16f2:	4505                	li	a0,1
    16f4:	00004097          	auipc	ra,0x4
    16f8:	150080e7          	jalr	336(ra) # 5844 <exit>
    if(exec("echo", echoargv) < 0){
    16fc:	fc040593          	addi	a1,s0,-64
    1700:	00005517          	auipc	a0,0x5
    1704:	a7050513          	addi	a0,a0,-1424 # 6170 <malloc+0x4be>
    1708:	00004097          	auipc	ra,0x4
    170c:	174080e7          	jalr	372(ra) # 587c <exec>
    1710:	02054163          	bltz	a0,1732 <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1714:	fdc40513          	addi	a0,s0,-36
    1718:	00004097          	auipc	ra,0x4
    171c:	134080e7          	jalr	308(ra) # 584c <wait>
    1720:	02951763          	bne	a0,s1,174e <exectest+0x118>
  if(xstatus != 0)
    1724:	fdc42503          	lw	a0,-36(s0)
    1728:	cd0d                	beqz	a0,1762 <exectest+0x12c>
    exit(xstatus);
    172a:	00004097          	auipc	ra,0x4
    172e:	11a080e7          	jalr	282(ra) # 5844 <exit>
      printf("%s: exec echo failed\n", s);
    1732:	85ca                	mv	a1,s2
    1734:	00005517          	auipc	a0,0x5
    1738:	14450513          	addi	a0,a0,324 # 6878 <malloc+0xbc6>
    173c:	00004097          	auipc	ra,0x4
    1740:	4b8080e7          	jalr	1208(ra) # 5bf4 <printf>
      exit(1);
    1744:	4505                	li	a0,1
    1746:	00004097          	auipc	ra,0x4
    174a:	0fe080e7          	jalr	254(ra) # 5844 <exit>
    printf("%s: wait failed!\n", s);
    174e:	85ca                	mv	a1,s2
    1750:	00005517          	auipc	a0,0x5
    1754:	14050513          	addi	a0,a0,320 # 6890 <malloc+0xbde>
    1758:	00004097          	auipc	ra,0x4
    175c:	49c080e7          	jalr	1180(ra) # 5bf4 <printf>
    1760:	b7d1                	j	1724 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    1762:	4581                	li	a1,0
    1764:	00005517          	auipc	a0,0x5
    1768:	0e450513          	addi	a0,a0,228 # 6848 <malloc+0xb96>
    176c:	00004097          	auipc	ra,0x4
    1770:	118080e7          	jalr	280(ra) # 5884 <open>
  if(fd < 0) {
    1774:	02054a63          	bltz	a0,17a8 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    1778:	4609                	li	a2,2
    177a:	fb840593          	addi	a1,s0,-72
    177e:	00004097          	auipc	ra,0x4
    1782:	0de080e7          	jalr	222(ra) # 585c <read>
    1786:	4789                	li	a5,2
    1788:	02f50e63          	beq	a0,a5,17c4 <exectest+0x18e>
    printf("%s: read failed\n", s);
    178c:	85ca                	mv	a1,s2
    178e:	00005517          	auipc	a0,0x5
    1792:	13250513          	addi	a0,a0,306 # 68c0 <malloc+0xc0e>
    1796:	00004097          	auipc	ra,0x4
    179a:	45e080e7          	jalr	1118(ra) # 5bf4 <printf>
    exit(1);
    179e:	4505                	li	a0,1
    17a0:	00004097          	auipc	ra,0x4
    17a4:	0a4080e7          	jalr	164(ra) # 5844 <exit>
    printf("%s: open failed\n", s);
    17a8:	85ca                	mv	a1,s2
    17aa:	00005517          	auipc	a0,0x5
    17ae:	0fe50513          	addi	a0,a0,254 # 68a8 <malloc+0xbf6>
    17b2:	00004097          	auipc	ra,0x4
    17b6:	442080e7          	jalr	1090(ra) # 5bf4 <printf>
    exit(1);
    17ba:	4505                	li	a0,1
    17bc:	00004097          	auipc	ra,0x4
    17c0:	088080e7          	jalr	136(ra) # 5844 <exit>
  unlink("echo-ok");
    17c4:	00005517          	auipc	a0,0x5
    17c8:	08450513          	addi	a0,a0,132 # 6848 <malloc+0xb96>
    17cc:	00004097          	auipc	ra,0x4
    17d0:	0c8080e7          	jalr	200(ra) # 5894 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    17d4:	fb844703          	lbu	a4,-72(s0)
    17d8:	04f00793          	li	a5,79
    17dc:	00f71863          	bne	a4,a5,17ec <exectest+0x1b6>
    17e0:	fb944703          	lbu	a4,-71(s0)
    17e4:	04b00793          	li	a5,75
    17e8:	02f70063          	beq	a4,a5,1808 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    17ec:	85ca                	mv	a1,s2
    17ee:	00005517          	auipc	a0,0x5
    17f2:	0ea50513          	addi	a0,a0,234 # 68d8 <malloc+0xc26>
    17f6:	00004097          	auipc	ra,0x4
    17fa:	3fe080e7          	jalr	1022(ra) # 5bf4 <printf>
    exit(1);
    17fe:	4505                	li	a0,1
    1800:	00004097          	auipc	ra,0x4
    1804:	044080e7          	jalr	68(ra) # 5844 <exit>
    exit(0);
    1808:	4501                	li	a0,0
    180a:	00004097          	auipc	ra,0x4
    180e:	03a080e7          	jalr	58(ra) # 5844 <exit>

0000000000001812 <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(char *s)
{
    1812:	7179                	addi	sp,sp,-48
    1814:	f406                	sd	ra,40(sp)
    1816:	f022                	sd	s0,32(sp)
    1818:	ec26                	sd	s1,24(sp)
    181a:	1800                	addi	s0,sp,48
    181c:	84aa                	mv	s1,a0
  int pid, fd, xstatus;

  unlink("bigarg-ok");
    181e:	00005517          	auipc	a0,0x5
    1822:	0d250513          	addi	a0,a0,210 # 68f0 <malloc+0xc3e>
    1826:	00004097          	auipc	ra,0x4
    182a:	06e080e7          	jalr	110(ra) # 5894 <unlink>
  pid = fork();
    182e:	00004097          	auipc	ra,0x4
    1832:	00e080e7          	jalr	14(ra) # 583c <fork>
  if(pid == 0){
    1836:	c121                	beqz	a0,1876 <bigargtest+0x64>
    args[MAXARG-1] = 0;
    exec("echo", args);
    fd = open("bigarg-ok", O_CREATE);
    close(fd);
    exit(0);
  } else if(pid < 0){
    1838:	0a054063          	bltz	a0,18d8 <bigargtest+0xc6>
    printf("%s: bigargtest: fork failed\n", s);
    exit(1);
  }
  
  wait(&xstatus);
    183c:	fdc40513          	addi	a0,s0,-36
    1840:	00004097          	auipc	ra,0x4
    1844:	00c080e7          	jalr	12(ra) # 584c <wait>
  if(xstatus != 0)
    1848:	fdc42503          	lw	a0,-36(s0)
    184c:	e545                	bnez	a0,18f4 <bigargtest+0xe2>
    exit(xstatus);
  fd = open("bigarg-ok", 0);
    184e:	4581                	li	a1,0
    1850:	00005517          	auipc	a0,0x5
    1854:	0a050513          	addi	a0,a0,160 # 68f0 <malloc+0xc3e>
    1858:	00004097          	auipc	ra,0x4
    185c:	02c080e7          	jalr	44(ra) # 5884 <open>
  if(fd < 0){
    1860:	08054e63          	bltz	a0,18fc <bigargtest+0xea>
    printf("%s: bigarg test failed!\n", s);
    exit(1);
  }
  close(fd);
    1864:	00004097          	auipc	ra,0x4
    1868:	008080e7          	jalr	8(ra) # 586c <close>
}
    186c:	70a2                	ld	ra,40(sp)
    186e:	7402                	ld	s0,32(sp)
    1870:	64e2                	ld	s1,24(sp)
    1872:	6145                	addi	sp,sp,48
    1874:	8082                	ret
    1876:	00007797          	auipc	a5,0x7
    187a:	b3278793          	addi	a5,a5,-1230 # 83a8 <args.1>
    187e:	00007697          	auipc	a3,0x7
    1882:	c2268693          	addi	a3,a3,-990 # 84a0 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    1886:	00005717          	auipc	a4,0x5
    188a:	07a70713          	addi	a4,a4,122 # 6900 <malloc+0xc4e>
    188e:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    1890:	07a1                	addi	a5,a5,8
    1892:	fed79ee3          	bne	a5,a3,188e <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    1896:	00007597          	auipc	a1,0x7
    189a:	b1258593          	addi	a1,a1,-1262 # 83a8 <args.1>
    189e:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    18a2:	00005517          	auipc	a0,0x5
    18a6:	8ce50513          	addi	a0,a0,-1842 # 6170 <malloc+0x4be>
    18aa:	00004097          	auipc	ra,0x4
    18ae:	fd2080e7          	jalr	-46(ra) # 587c <exec>
    fd = open("bigarg-ok", O_CREATE);
    18b2:	20000593          	li	a1,512
    18b6:	00005517          	auipc	a0,0x5
    18ba:	03a50513          	addi	a0,a0,58 # 68f0 <malloc+0xc3e>
    18be:	00004097          	auipc	ra,0x4
    18c2:	fc6080e7          	jalr	-58(ra) # 5884 <open>
    close(fd);
    18c6:	00004097          	auipc	ra,0x4
    18ca:	fa6080e7          	jalr	-90(ra) # 586c <close>
    exit(0);
    18ce:	4501                	li	a0,0
    18d0:	00004097          	auipc	ra,0x4
    18d4:	f74080e7          	jalr	-140(ra) # 5844 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    18d8:	85a6                	mv	a1,s1
    18da:	00005517          	auipc	a0,0x5
    18de:	10650513          	addi	a0,a0,262 # 69e0 <malloc+0xd2e>
    18e2:	00004097          	auipc	ra,0x4
    18e6:	312080e7          	jalr	786(ra) # 5bf4 <printf>
    exit(1);
    18ea:	4505                	li	a0,1
    18ec:	00004097          	auipc	ra,0x4
    18f0:	f58080e7          	jalr	-168(ra) # 5844 <exit>
    exit(xstatus);
    18f4:	00004097          	auipc	ra,0x4
    18f8:	f50080e7          	jalr	-176(ra) # 5844 <exit>
    printf("%s: bigarg test failed!\n", s);
    18fc:	85a6                	mv	a1,s1
    18fe:	00005517          	auipc	a0,0x5
    1902:	10250513          	addi	a0,a0,258 # 6a00 <malloc+0xd4e>
    1906:	00004097          	auipc	ra,0x4
    190a:	2ee080e7          	jalr	750(ra) # 5bf4 <printf>
    exit(1);
    190e:	4505                	li	a0,1
    1910:	00004097          	auipc	ra,0x4
    1914:	f34080e7          	jalr	-204(ra) # 5844 <exit>

0000000000001918 <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    1918:	7179                	addi	sp,sp,-48
    191a:	f406                	sd	ra,40(sp)
    191c:	f022                	sd	s0,32(sp)
    191e:	ec26                	sd	s1,24(sp)
    1920:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    1922:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1926:	00007497          	auipc	s1,0x7
    192a:	a624b483          	ld	s1,-1438(s1) # 8388 <__SDATA_BEGIN__>
    192e:	fd840593          	addi	a1,s0,-40
    1932:	8526                	mv	a0,s1
    1934:	00004097          	auipc	ra,0x4
    1938:	f48080e7          	jalr	-184(ra) # 587c <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    193c:	8526                	mv	a0,s1
    193e:	00004097          	auipc	ra,0x4
    1942:	f16080e7          	jalr	-234(ra) # 5854 <pipe>

  exit(0);
    1946:	4501                	li	a0,0
    1948:	00004097          	auipc	ra,0x4
    194c:	efc080e7          	jalr	-260(ra) # 5844 <exit>

0000000000001950 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    1950:	7139                	addi	sp,sp,-64
    1952:	fc06                	sd	ra,56(sp)
    1954:	f822                	sd	s0,48(sp)
    1956:	f426                	sd	s1,40(sp)
    1958:	f04a                	sd	s2,32(sp)
    195a:	ec4e                	sd	s3,24(sp)
    195c:	0080                	addi	s0,sp,64
    195e:	64b1                	lui	s1,0xc
    1960:	35048493          	addi	s1,s1,848 # c350 <buf+0x790>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1964:	597d                	li	s2,-1
    1966:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    196a:	00005997          	auipc	s3,0x5
    196e:	80698993          	addi	s3,s3,-2042 # 6170 <malloc+0x4be>
    argv[0] = (char*)0xffffffff;
    1972:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1976:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    197a:	fc040593          	addi	a1,s0,-64
    197e:	854e                	mv	a0,s3
    1980:	00004097          	auipc	ra,0x4
    1984:	efc080e7          	jalr	-260(ra) # 587c <exec>
  for(int i = 0; i < 50000; i++){
    1988:	34fd                	addiw	s1,s1,-1
    198a:	f4e5                	bnez	s1,1972 <badarg+0x22>
  }
  
  exit(0);
    198c:	4501                	li	a0,0
    198e:	00004097          	auipc	ra,0x4
    1992:	eb6080e7          	jalr	-330(ra) # 5844 <exit>

0000000000001996 <copyinstr3>:
{
    1996:	7179                	addi	sp,sp,-48
    1998:	f406                	sd	ra,40(sp)
    199a:	f022                	sd	s0,32(sp)
    199c:	ec26                	sd	s1,24(sp)
    199e:	1800                	addi	s0,sp,48
  sbrk(8192);
    19a0:	6509                	lui	a0,0x2
    19a2:	00004097          	auipc	ra,0x4
    19a6:	f2a080e7          	jalr	-214(ra) # 58cc <sbrk>
  uint64 top = (uint64) sbrk(0);
    19aa:	4501                	li	a0,0
    19ac:	00004097          	auipc	ra,0x4
    19b0:	f20080e7          	jalr	-224(ra) # 58cc <sbrk>
  if((top % PGSIZE) != 0){
    19b4:	03451793          	slli	a5,a0,0x34
    19b8:	e3c9                	bnez	a5,1a3a <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    19ba:	4501                	li	a0,0
    19bc:	00004097          	auipc	ra,0x4
    19c0:	f10080e7          	jalr	-240(ra) # 58cc <sbrk>
  if(top % PGSIZE){
    19c4:	03451793          	slli	a5,a0,0x34
    19c8:	e3d9                	bnez	a5,1a4e <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    19ca:	fff50493          	addi	s1,a0,-1 # 1fff <fourteen+0x187>
  *b = 'x';
    19ce:	07800793          	li	a5,120
    19d2:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    19d6:	8526                	mv	a0,s1
    19d8:	00004097          	auipc	ra,0x4
    19dc:	ebc080e7          	jalr	-324(ra) # 5894 <unlink>
  if(ret != -1){
    19e0:	57fd                	li	a5,-1
    19e2:	08f51363          	bne	a0,a5,1a68 <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    19e6:	20100593          	li	a1,513
    19ea:	8526                	mv	a0,s1
    19ec:	00004097          	auipc	ra,0x4
    19f0:	e98080e7          	jalr	-360(ra) # 5884 <open>
  if(fd != -1){
    19f4:	57fd                	li	a5,-1
    19f6:	08f51863          	bne	a0,a5,1a86 <copyinstr3+0xf0>
  ret = link(b, b);
    19fa:	85a6                	mv	a1,s1
    19fc:	8526                	mv	a0,s1
    19fe:	00004097          	auipc	ra,0x4
    1a02:	ea6080e7          	jalr	-346(ra) # 58a4 <link>
  if(ret != -1){
    1a06:	57fd                	li	a5,-1
    1a08:	08f51e63          	bne	a0,a5,1aa4 <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    1a0c:	00006797          	auipc	a5,0x6
    1a10:	b0c78793          	addi	a5,a5,-1268 # 7518 <malloc+0x1866>
    1a14:	fcf43823          	sd	a5,-48(s0)
    1a18:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    1a1c:	fd040593          	addi	a1,s0,-48
    1a20:	8526                	mv	a0,s1
    1a22:	00004097          	auipc	ra,0x4
    1a26:	e5a080e7          	jalr	-422(ra) # 587c <exec>
  if(ret != -1){
    1a2a:	57fd                	li	a5,-1
    1a2c:	08f51c63          	bne	a0,a5,1ac4 <copyinstr3+0x12e>
}
    1a30:	70a2                	ld	ra,40(sp)
    1a32:	7402                	ld	s0,32(sp)
    1a34:	64e2                	ld	s1,24(sp)
    1a36:	6145                	addi	sp,sp,48
    1a38:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    1a3a:	0347d513          	srli	a0,a5,0x34
    1a3e:	6785                	lui	a5,0x1
    1a40:	40a7853b          	subw	a0,a5,a0
    1a44:	00004097          	auipc	ra,0x4
    1a48:	e88080e7          	jalr	-376(ra) # 58cc <sbrk>
    1a4c:	b7bd                	j	19ba <copyinstr3+0x24>
    printf("oops\n");
    1a4e:	00005517          	auipc	a0,0x5
    1a52:	fd250513          	addi	a0,a0,-46 # 6a20 <malloc+0xd6e>
    1a56:	00004097          	auipc	ra,0x4
    1a5a:	19e080e7          	jalr	414(ra) # 5bf4 <printf>
    exit(1);
    1a5e:	4505                	li	a0,1
    1a60:	00004097          	auipc	ra,0x4
    1a64:	de4080e7          	jalr	-540(ra) # 5844 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    1a68:	862a                	mv	a2,a0
    1a6a:	85a6                	mv	a1,s1
    1a6c:	00005517          	auipc	a0,0x5
    1a70:	cf450513          	addi	a0,a0,-780 # 6760 <malloc+0xaae>
    1a74:	00004097          	auipc	ra,0x4
    1a78:	180080e7          	jalr	384(ra) # 5bf4 <printf>
    exit(1);
    1a7c:	4505                	li	a0,1
    1a7e:	00004097          	auipc	ra,0x4
    1a82:	dc6080e7          	jalr	-570(ra) # 5844 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1a86:	862a                	mv	a2,a0
    1a88:	85a6                	mv	a1,s1
    1a8a:	00005517          	auipc	a0,0x5
    1a8e:	cf650513          	addi	a0,a0,-778 # 6780 <malloc+0xace>
    1a92:	00004097          	auipc	ra,0x4
    1a96:	162080e7          	jalr	354(ra) # 5bf4 <printf>
    exit(1);
    1a9a:	4505                	li	a0,1
    1a9c:	00004097          	auipc	ra,0x4
    1aa0:	da8080e7          	jalr	-600(ra) # 5844 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1aa4:	86aa                	mv	a3,a0
    1aa6:	8626                	mv	a2,s1
    1aa8:	85a6                	mv	a1,s1
    1aaa:	00005517          	auipc	a0,0x5
    1aae:	cf650513          	addi	a0,a0,-778 # 67a0 <malloc+0xaee>
    1ab2:	00004097          	auipc	ra,0x4
    1ab6:	142080e7          	jalr	322(ra) # 5bf4 <printf>
    exit(1);
    1aba:	4505                	li	a0,1
    1abc:	00004097          	auipc	ra,0x4
    1ac0:	d88080e7          	jalr	-632(ra) # 5844 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1ac4:	567d                	li	a2,-1
    1ac6:	85a6                	mv	a1,s1
    1ac8:	00005517          	auipc	a0,0x5
    1acc:	d0050513          	addi	a0,a0,-768 # 67c8 <malloc+0xb16>
    1ad0:	00004097          	auipc	ra,0x4
    1ad4:	124080e7          	jalr	292(ra) # 5bf4 <printf>
    exit(1);
    1ad8:	4505                	li	a0,1
    1ada:	00004097          	auipc	ra,0x4
    1ade:	d6a080e7          	jalr	-662(ra) # 5844 <exit>

0000000000001ae2 <rwsbrk>:
{
    1ae2:	1101                	addi	sp,sp,-32
    1ae4:	ec06                	sd	ra,24(sp)
    1ae6:	e822                	sd	s0,16(sp)
    1ae8:	e426                	sd	s1,8(sp)
    1aea:	e04a                	sd	s2,0(sp)
    1aec:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    1aee:	6509                	lui	a0,0x2
    1af0:	00004097          	auipc	ra,0x4
    1af4:	ddc080e7          	jalr	-548(ra) # 58cc <sbrk>
  if(a == 0xffffffffffffffffLL) {
    1af8:	57fd                	li	a5,-1
    1afa:	06f50363          	beq	a0,a5,1b60 <rwsbrk+0x7e>
    1afe:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    1b00:	7579                	lui	a0,0xffffe
    1b02:	00004097          	auipc	ra,0x4
    1b06:	dca080e7          	jalr	-566(ra) # 58cc <sbrk>
    1b0a:	57fd                	li	a5,-1
    1b0c:	06f50763          	beq	a0,a5,1b7a <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    1b10:	20100593          	li	a1,513
    1b14:	00004517          	auipc	a0,0x4
    1b18:	2f450513          	addi	a0,a0,756 # 5e08 <malloc+0x156>
    1b1c:	00004097          	auipc	ra,0x4
    1b20:	d68080e7          	jalr	-664(ra) # 5884 <open>
    1b24:	892a                	mv	s2,a0
  if(fd < 0){
    1b26:	06054763          	bltz	a0,1b94 <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    1b2a:	6505                	lui	a0,0x1
    1b2c:	94aa                	add	s1,s1,a0
    1b2e:	40000613          	li	a2,1024
    1b32:	85a6                	mv	a1,s1
    1b34:	854a                	mv	a0,s2
    1b36:	00004097          	auipc	ra,0x4
    1b3a:	d2e080e7          	jalr	-722(ra) # 5864 <write>
    1b3e:	862a                	mv	a2,a0
  if(n >= 0){
    1b40:	06054763          	bltz	a0,1bae <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    1b44:	85a6                	mv	a1,s1
    1b46:	00005517          	auipc	a0,0x5
    1b4a:	f3250513          	addi	a0,a0,-206 # 6a78 <malloc+0xdc6>
    1b4e:	00004097          	auipc	ra,0x4
    1b52:	0a6080e7          	jalr	166(ra) # 5bf4 <printf>
    exit(1);
    1b56:	4505                	li	a0,1
    1b58:	00004097          	auipc	ra,0x4
    1b5c:	cec080e7          	jalr	-788(ra) # 5844 <exit>
    printf("sbrk(rwsbrk) failed\n");
    1b60:	00005517          	auipc	a0,0x5
    1b64:	ec850513          	addi	a0,a0,-312 # 6a28 <malloc+0xd76>
    1b68:	00004097          	auipc	ra,0x4
    1b6c:	08c080e7          	jalr	140(ra) # 5bf4 <printf>
    exit(1);
    1b70:	4505                	li	a0,1
    1b72:	00004097          	auipc	ra,0x4
    1b76:	cd2080e7          	jalr	-814(ra) # 5844 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    1b7a:	00005517          	auipc	a0,0x5
    1b7e:	ec650513          	addi	a0,a0,-314 # 6a40 <malloc+0xd8e>
    1b82:	00004097          	auipc	ra,0x4
    1b86:	072080e7          	jalr	114(ra) # 5bf4 <printf>
    exit(1);
    1b8a:	4505                	li	a0,1
    1b8c:	00004097          	auipc	ra,0x4
    1b90:	cb8080e7          	jalr	-840(ra) # 5844 <exit>
    printf("open(rwsbrk) failed\n");
    1b94:	00005517          	auipc	a0,0x5
    1b98:	ecc50513          	addi	a0,a0,-308 # 6a60 <malloc+0xdae>
    1b9c:	00004097          	auipc	ra,0x4
    1ba0:	058080e7          	jalr	88(ra) # 5bf4 <printf>
    exit(1);
    1ba4:	4505                	li	a0,1
    1ba6:	00004097          	auipc	ra,0x4
    1baa:	c9e080e7          	jalr	-866(ra) # 5844 <exit>
  close(fd);
    1bae:	854a                	mv	a0,s2
    1bb0:	00004097          	auipc	ra,0x4
    1bb4:	cbc080e7          	jalr	-836(ra) # 586c <close>
  unlink("rwsbrk");
    1bb8:	00004517          	auipc	a0,0x4
    1bbc:	25050513          	addi	a0,a0,592 # 5e08 <malloc+0x156>
    1bc0:	00004097          	auipc	ra,0x4
    1bc4:	cd4080e7          	jalr	-812(ra) # 5894 <unlink>
  fd = open("README", O_RDONLY);
    1bc8:	4581                	li	a1,0
    1bca:	00004517          	auipc	a0,0x4
    1bce:	74e50513          	addi	a0,a0,1870 # 6318 <malloc+0x666>
    1bd2:	00004097          	auipc	ra,0x4
    1bd6:	cb2080e7          	jalr	-846(ra) # 5884 <open>
    1bda:	892a                	mv	s2,a0
  if(fd < 0){
    1bdc:	02054963          	bltz	a0,1c0e <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    1be0:	4629                	li	a2,10
    1be2:	85a6                	mv	a1,s1
    1be4:	00004097          	auipc	ra,0x4
    1be8:	c78080e7          	jalr	-904(ra) # 585c <read>
    1bec:	862a                	mv	a2,a0
  if(n >= 0){
    1bee:	02054d63          	bltz	a0,1c28 <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    1bf2:	85a6                	mv	a1,s1
    1bf4:	00005517          	auipc	a0,0x5
    1bf8:	eb450513          	addi	a0,a0,-332 # 6aa8 <malloc+0xdf6>
    1bfc:	00004097          	auipc	ra,0x4
    1c00:	ff8080e7          	jalr	-8(ra) # 5bf4 <printf>
    exit(1);
    1c04:	4505                	li	a0,1
    1c06:	00004097          	auipc	ra,0x4
    1c0a:	c3e080e7          	jalr	-962(ra) # 5844 <exit>
    printf("open(rwsbrk) failed\n");
    1c0e:	00005517          	auipc	a0,0x5
    1c12:	e5250513          	addi	a0,a0,-430 # 6a60 <malloc+0xdae>
    1c16:	00004097          	auipc	ra,0x4
    1c1a:	fde080e7          	jalr	-34(ra) # 5bf4 <printf>
    exit(1);
    1c1e:	4505                	li	a0,1
    1c20:	00004097          	auipc	ra,0x4
    1c24:	c24080e7          	jalr	-988(ra) # 5844 <exit>
  close(fd);
    1c28:	854a                	mv	a0,s2
    1c2a:	00004097          	auipc	ra,0x4
    1c2e:	c42080e7          	jalr	-958(ra) # 586c <close>
  exit(0);
    1c32:	4501                	li	a0,0
    1c34:	00004097          	auipc	ra,0x4
    1c38:	c10080e7          	jalr	-1008(ra) # 5844 <exit>

0000000000001c3c <sbrkarg>:
{
    1c3c:	7179                	addi	sp,sp,-48
    1c3e:	f406                	sd	ra,40(sp)
    1c40:	f022                	sd	s0,32(sp)
    1c42:	ec26                	sd	s1,24(sp)
    1c44:	e84a                	sd	s2,16(sp)
    1c46:	e44e                	sd	s3,8(sp)
    1c48:	1800                	addi	s0,sp,48
    1c4a:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    1c4c:	6505                	lui	a0,0x1
    1c4e:	00004097          	auipc	ra,0x4
    1c52:	c7e080e7          	jalr	-898(ra) # 58cc <sbrk>
    1c56:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    1c58:	20100593          	li	a1,513
    1c5c:	00005517          	auipc	a0,0x5
    1c60:	e7450513          	addi	a0,a0,-396 # 6ad0 <malloc+0xe1e>
    1c64:	00004097          	auipc	ra,0x4
    1c68:	c20080e7          	jalr	-992(ra) # 5884 <open>
    1c6c:	84aa                	mv	s1,a0
  unlink("sbrk");
    1c6e:	00005517          	auipc	a0,0x5
    1c72:	e6250513          	addi	a0,a0,-414 # 6ad0 <malloc+0xe1e>
    1c76:	00004097          	auipc	ra,0x4
    1c7a:	c1e080e7          	jalr	-994(ra) # 5894 <unlink>
  if(fd < 0)  {
    1c7e:	0404c163          	bltz	s1,1cc0 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    1c82:	6605                	lui	a2,0x1
    1c84:	85ca                	mv	a1,s2
    1c86:	8526                	mv	a0,s1
    1c88:	00004097          	auipc	ra,0x4
    1c8c:	bdc080e7          	jalr	-1060(ra) # 5864 <write>
    1c90:	04054663          	bltz	a0,1cdc <sbrkarg+0xa0>
  close(fd);
    1c94:	8526                	mv	a0,s1
    1c96:	00004097          	auipc	ra,0x4
    1c9a:	bd6080e7          	jalr	-1066(ra) # 586c <close>
  a = sbrk(PGSIZE);
    1c9e:	6505                	lui	a0,0x1
    1ca0:	00004097          	auipc	ra,0x4
    1ca4:	c2c080e7          	jalr	-980(ra) # 58cc <sbrk>
  if(pipe((int *) a) != 0){
    1ca8:	00004097          	auipc	ra,0x4
    1cac:	bac080e7          	jalr	-1108(ra) # 5854 <pipe>
    1cb0:	e521                	bnez	a0,1cf8 <sbrkarg+0xbc>
}
    1cb2:	70a2                	ld	ra,40(sp)
    1cb4:	7402                	ld	s0,32(sp)
    1cb6:	64e2                	ld	s1,24(sp)
    1cb8:	6942                	ld	s2,16(sp)
    1cba:	69a2                	ld	s3,8(sp)
    1cbc:	6145                	addi	sp,sp,48
    1cbe:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    1cc0:	85ce                	mv	a1,s3
    1cc2:	00005517          	auipc	a0,0x5
    1cc6:	e1650513          	addi	a0,a0,-490 # 6ad8 <malloc+0xe26>
    1cca:	00004097          	auipc	ra,0x4
    1cce:	f2a080e7          	jalr	-214(ra) # 5bf4 <printf>
    exit(1);
    1cd2:	4505                	li	a0,1
    1cd4:	00004097          	auipc	ra,0x4
    1cd8:	b70080e7          	jalr	-1168(ra) # 5844 <exit>
    printf("%s: write sbrk failed\n", s);
    1cdc:	85ce                	mv	a1,s3
    1cde:	00005517          	auipc	a0,0x5
    1ce2:	e1250513          	addi	a0,a0,-494 # 6af0 <malloc+0xe3e>
    1ce6:	00004097          	auipc	ra,0x4
    1cea:	f0e080e7          	jalr	-242(ra) # 5bf4 <printf>
    exit(1);
    1cee:	4505                	li	a0,1
    1cf0:	00004097          	auipc	ra,0x4
    1cf4:	b54080e7          	jalr	-1196(ra) # 5844 <exit>
    printf("%s: pipe() failed\n", s);
    1cf8:	85ce                	mv	a1,s3
    1cfa:	00004517          	auipc	a0,0x4
    1cfe:	75e50513          	addi	a0,a0,1886 # 6458 <malloc+0x7a6>
    1d02:	00004097          	auipc	ra,0x4
    1d06:	ef2080e7          	jalr	-270(ra) # 5bf4 <printf>
    exit(1);
    1d0a:	4505                	li	a0,1
    1d0c:	00004097          	auipc	ra,0x4
    1d10:	b38080e7          	jalr	-1224(ra) # 5844 <exit>

0000000000001d14 <argptest>:
{
    1d14:	1101                	addi	sp,sp,-32
    1d16:	ec06                	sd	ra,24(sp)
    1d18:	e822                	sd	s0,16(sp)
    1d1a:	e426                	sd	s1,8(sp)
    1d1c:	e04a                	sd	s2,0(sp)
    1d1e:	1000                	addi	s0,sp,32
    1d20:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    1d22:	4581                	li	a1,0
    1d24:	00005517          	auipc	a0,0x5
    1d28:	de450513          	addi	a0,a0,-540 # 6b08 <malloc+0xe56>
    1d2c:	00004097          	auipc	ra,0x4
    1d30:	b58080e7          	jalr	-1192(ra) # 5884 <open>
  if (fd < 0) {
    1d34:	02054b63          	bltz	a0,1d6a <argptest+0x56>
    1d38:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    1d3a:	4501                	li	a0,0
    1d3c:	00004097          	auipc	ra,0x4
    1d40:	b90080e7          	jalr	-1136(ra) # 58cc <sbrk>
    1d44:	567d                	li	a2,-1
    1d46:	fff50593          	addi	a1,a0,-1
    1d4a:	8526                	mv	a0,s1
    1d4c:	00004097          	auipc	ra,0x4
    1d50:	b10080e7          	jalr	-1264(ra) # 585c <read>
  close(fd);
    1d54:	8526                	mv	a0,s1
    1d56:	00004097          	auipc	ra,0x4
    1d5a:	b16080e7          	jalr	-1258(ra) # 586c <close>
}
    1d5e:	60e2                	ld	ra,24(sp)
    1d60:	6442                	ld	s0,16(sp)
    1d62:	64a2                	ld	s1,8(sp)
    1d64:	6902                	ld	s2,0(sp)
    1d66:	6105                	addi	sp,sp,32
    1d68:	8082                	ret
    printf("%s: open failed\n", s);
    1d6a:	85ca                	mv	a1,s2
    1d6c:	00005517          	auipc	a0,0x5
    1d70:	b3c50513          	addi	a0,a0,-1220 # 68a8 <malloc+0xbf6>
    1d74:	00004097          	auipc	ra,0x4
    1d78:	e80080e7          	jalr	-384(ra) # 5bf4 <printf>
    exit(1);
    1d7c:	4505                	li	a0,1
    1d7e:	00004097          	auipc	ra,0x4
    1d82:	ac6080e7          	jalr	-1338(ra) # 5844 <exit>

0000000000001d86 <openiputtest>:
{
    1d86:	7179                	addi	sp,sp,-48
    1d88:	f406                	sd	ra,40(sp)
    1d8a:	f022                	sd	s0,32(sp)
    1d8c:	ec26                	sd	s1,24(sp)
    1d8e:	1800                	addi	s0,sp,48
    1d90:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    1d92:	00005517          	auipc	a0,0x5
    1d96:	d7e50513          	addi	a0,a0,-642 # 6b10 <malloc+0xe5e>
    1d9a:	00004097          	auipc	ra,0x4
    1d9e:	b12080e7          	jalr	-1262(ra) # 58ac <mkdir>
    1da2:	04054263          	bltz	a0,1de6 <openiputtest+0x60>
  pid = fork();
    1da6:	00004097          	auipc	ra,0x4
    1daa:	a96080e7          	jalr	-1386(ra) # 583c <fork>
  if(pid < 0){
    1dae:	04054a63          	bltz	a0,1e02 <openiputtest+0x7c>
  if(pid == 0){
    1db2:	e93d                	bnez	a0,1e28 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    1db4:	4589                	li	a1,2
    1db6:	00005517          	auipc	a0,0x5
    1dba:	d5a50513          	addi	a0,a0,-678 # 6b10 <malloc+0xe5e>
    1dbe:	00004097          	auipc	ra,0x4
    1dc2:	ac6080e7          	jalr	-1338(ra) # 5884 <open>
    if(fd >= 0){
    1dc6:	04054c63          	bltz	a0,1e1e <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    1dca:	85a6                	mv	a1,s1
    1dcc:	00005517          	auipc	a0,0x5
    1dd0:	d6450513          	addi	a0,a0,-668 # 6b30 <malloc+0xe7e>
    1dd4:	00004097          	auipc	ra,0x4
    1dd8:	e20080e7          	jalr	-480(ra) # 5bf4 <printf>
      exit(1);
    1ddc:	4505                	li	a0,1
    1dde:	00004097          	auipc	ra,0x4
    1de2:	a66080e7          	jalr	-1434(ra) # 5844 <exit>
    printf("%s: mkdir oidir failed\n", s);
    1de6:	85a6                	mv	a1,s1
    1de8:	00005517          	auipc	a0,0x5
    1dec:	d3050513          	addi	a0,a0,-720 # 6b18 <malloc+0xe66>
    1df0:	00004097          	auipc	ra,0x4
    1df4:	e04080e7          	jalr	-508(ra) # 5bf4 <printf>
    exit(1);
    1df8:	4505                	li	a0,1
    1dfa:	00004097          	auipc	ra,0x4
    1dfe:	a4a080e7          	jalr	-1462(ra) # 5844 <exit>
    printf("%s: fork failed\n", s);
    1e02:	85a6                	mv	a1,s1
    1e04:	00004517          	auipc	a0,0x4
    1e08:	1f450513          	addi	a0,a0,500 # 5ff8 <malloc+0x346>
    1e0c:	00004097          	auipc	ra,0x4
    1e10:	de8080e7          	jalr	-536(ra) # 5bf4 <printf>
    exit(1);
    1e14:	4505                	li	a0,1
    1e16:	00004097          	auipc	ra,0x4
    1e1a:	a2e080e7          	jalr	-1490(ra) # 5844 <exit>
    exit(0);
    1e1e:	4501                	li	a0,0
    1e20:	00004097          	auipc	ra,0x4
    1e24:	a24080e7          	jalr	-1500(ra) # 5844 <exit>
  sleep(1);
    1e28:	4505                	li	a0,1
    1e2a:	00004097          	auipc	ra,0x4
    1e2e:	aaa080e7          	jalr	-1366(ra) # 58d4 <sleep>
  if(unlink("oidir") != 0){
    1e32:	00005517          	auipc	a0,0x5
    1e36:	cde50513          	addi	a0,a0,-802 # 6b10 <malloc+0xe5e>
    1e3a:	00004097          	auipc	ra,0x4
    1e3e:	a5a080e7          	jalr	-1446(ra) # 5894 <unlink>
    1e42:	cd19                	beqz	a0,1e60 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    1e44:	85a6                	mv	a1,s1
    1e46:	00005517          	auipc	a0,0x5
    1e4a:	d1250513          	addi	a0,a0,-750 # 6b58 <malloc+0xea6>
    1e4e:	00004097          	auipc	ra,0x4
    1e52:	da6080e7          	jalr	-602(ra) # 5bf4 <printf>
    exit(1);
    1e56:	4505                	li	a0,1
    1e58:	00004097          	auipc	ra,0x4
    1e5c:	9ec080e7          	jalr	-1556(ra) # 5844 <exit>
  wait(&xstatus);
    1e60:	fdc40513          	addi	a0,s0,-36
    1e64:	00004097          	auipc	ra,0x4
    1e68:	9e8080e7          	jalr	-1560(ra) # 584c <wait>
  exit(xstatus);
    1e6c:	fdc42503          	lw	a0,-36(s0)
    1e70:	00004097          	auipc	ra,0x4
    1e74:	9d4080e7          	jalr	-1580(ra) # 5844 <exit>

0000000000001e78 <fourteen>:
{
    1e78:	1101                	addi	sp,sp,-32
    1e7a:	ec06                	sd	ra,24(sp)
    1e7c:	e822                	sd	s0,16(sp)
    1e7e:	e426                	sd	s1,8(sp)
    1e80:	1000                	addi	s0,sp,32
    1e82:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    1e84:	00005517          	auipc	a0,0x5
    1e88:	ebc50513          	addi	a0,a0,-324 # 6d40 <malloc+0x108e>
    1e8c:	00004097          	auipc	ra,0x4
    1e90:	a20080e7          	jalr	-1504(ra) # 58ac <mkdir>
    1e94:	e165                	bnez	a0,1f74 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    1e96:	00005517          	auipc	a0,0x5
    1e9a:	d0250513          	addi	a0,a0,-766 # 6b98 <malloc+0xee6>
    1e9e:	00004097          	auipc	ra,0x4
    1ea2:	a0e080e7          	jalr	-1522(ra) # 58ac <mkdir>
    1ea6:	e56d                	bnez	a0,1f90 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    1ea8:	20000593          	li	a1,512
    1eac:	00005517          	auipc	a0,0x5
    1eb0:	d4450513          	addi	a0,a0,-700 # 6bf0 <malloc+0xf3e>
    1eb4:	00004097          	auipc	ra,0x4
    1eb8:	9d0080e7          	jalr	-1584(ra) # 5884 <open>
  if(fd < 0){
    1ebc:	0e054863          	bltz	a0,1fac <fourteen+0x134>
  close(fd);
    1ec0:	00004097          	auipc	ra,0x4
    1ec4:	9ac080e7          	jalr	-1620(ra) # 586c <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    1ec8:	4581                	li	a1,0
    1eca:	00005517          	auipc	a0,0x5
    1ece:	d9e50513          	addi	a0,a0,-610 # 6c68 <malloc+0xfb6>
    1ed2:	00004097          	auipc	ra,0x4
    1ed6:	9b2080e7          	jalr	-1614(ra) # 5884 <open>
  if(fd < 0){
    1eda:	0e054763          	bltz	a0,1fc8 <fourteen+0x150>
  close(fd);
    1ede:	00004097          	auipc	ra,0x4
    1ee2:	98e080e7          	jalr	-1650(ra) # 586c <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    1ee6:	00005517          	auipc	a0,0x5
    1eea:	df250513          	addi	a0,a0,-526 # 6cd8 <malloc+0x1026>
    1eee:	00004097          	auipc	ra,0x4
    1ef2:	9be080e7          	jalr	-1602(ra) # 58ac <mkdir>
    1ef6:	c57d                	beqz	a0,1fe4 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    1ef8:	00005517          	auipc	a0,0x5
    1efc:	e3850513          	addi	a0,a0,-456 # 6d30 <malloc+0x107e>
    1f00:	00004097          	auipc	ra,0x4
    1f04:	9ac080e7          	jalr	-1620(ra) # 58ac <mkdir>
    1f08:	cd65                	beqz	a0,2000 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    1f0a:	00005517          	auipc	a0,0x5
    1f0e:	e2650513          	addi	a0,a0,-474 # 6d30 <malloc+0x107e>
    1f12:	00004097          	auipc	ra,0x4
    1f16:	982080e7          	jalr	-1662(ra) # 5894 <unlink>
  unlink("12345678901234/12345678901234");
    1f1a:	00005517          	auipc	a0,0x5
    1f1e:	dbe50513          	addi	a0,a0,-578 # 6cd8 <malloc+0x1026>
    1f22:	00004097          	auipc	ra,0x4
    1f26:	972080e7          	jalr	-1678(ra) # 5894 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    1f2a:	00005517          	auipc	a0,0x5
    1f2e:	d3e50513          	addi	a0,a0,-706 # 6c68 <malloc+0xfb6>
    1f32:	00004097          	auipc	ra,0x4
    1f36:	962080e7          	jalr	-1694(ra) # 5894 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    1f3a:	00005517          	auipc	a0,0x5
    1f3e:	cb650513          	addi	a0,a0,-842 # 6bf0 <malloc+0xf3e>
    1f42:	00004097          	auipc	ra,0x4
    1f46:	952080e7          	jalr	-1710(ra) # 5894 <unlink>
  unlink("12345678901234/123456789012345");
    1f4a:	00005517          	auipc	a0,0x5
    1f4e:	c4e50513          	addi	a0,a0,-946 # 6b98 <malloc+0xee6>
    1f52:	00004097          	auipc	ra,0x4
    1f56:	942080e7          	jalr	-1726(ra) # 5894 <unlink>
  unlink("12345678901234");
    1f5a:	00005517          	auipc	a0,0x5
    1f5e:	de650513          	addi	a0,a0,-538 # 6d40 <malloc+0x108e>
    1f62:	00004097          	auipc	ra,0x4
    1f66:	932080e7          	jalr	-1742(ra) # 5894 <unlink>
}
    1f6a:	60e2                	ld	ra,24(sp)
    1f6c:	6442                	ld	s0,16(sp)
    1f6e:	64a2                	ld	s1,8(sp)
    1f70:	6105                	addi	sp,sp,32
    1f72:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    1f74:	85a6                	mv	a1,s1
    1f76:	00005517          	auipc	a0,0x5
    1f7a:	bfa50513          	addi	a0,a0,-1030 # 6b70 <malloc+0xebe>
    1f7e:	00004097          	auipc	ra,0x4
    1f82:	c76080e7          	jalr	-906(ra) # 5bf4 <printf>
    exit(1);
    1f86:	4505                	li	a0,1
    1f88:	00004097          	auipc	ra,0x4
    1f8c:	8bc080e7          	jalr	-1860(ra) # 5844 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    1f90:	85a6                	mv	a1,s1
    1f92:	00005517          	auipc	a0,0x5
    1f96:	c2650513          	addi	a0,a0,-986 # 6bb8 <malloc+0xf06>
    1f9a:	00004097          	auipc	ra,0x4
    1f9e:	c5a080e7          	jalr	-934(ra) # 5bf4 <printf>
    exit(1);
    1fa2:	4505                	li	a0,1
    1fa4:	00004097          	auipc	ra,0x4
    1fa8:	8a0080e7          	jalr	-1888(ra) # 5844 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    1fac:	85a6                	mv	a1,s1
    1fae:	00005517          	auipc	a0,0x5
    1fb2:	c7250513          	addi	a0,a0,-910 # 6c20 <malloc+0xf6e>
    1fb6:	00004097          	auipc	ra,0x4
    1fba:	c3e080e7          	jalr	-962(ra) # 5bf4 <printf>
    exit(1);
    1fbe:	4505                	li	a0,1
    1fc0:	00004097          	auipc	ra,0x4
    1fc4:	884080e7          	jalr	-1916(ra) # 5844 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    1fc8:	85a6                	mv	a1,s1
    1fca:	00005517          	auipc	a0,0x5
    1fce:	cce50513          	addi	a0,a0,-818 # 6c98 <malloc+0xfe6>
    1fd2:	00004097          	auipc	ra,0x4
    1fd6:	c22080e7          	jalr	-990(ra) # 5bf4 <printf>
    exit(1);
    1fda:	4505                	li	a0,1
    1fdc:	00004097          	auipc	ra,0x4
    1fe0:	868080e7          	jalr	-1944(ra) # 5844 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    1fe4:	85a6                	mv	a1,s1
    1fe6:	00005517          	auipc	a0,0x5
    1fea:	d1250513          	addi	a0,a0,-750 # 6cf8 <malloc+0x1046>
    1fee:	00004097          	auipc	ra,0x4
    1ff2:	c06080e7          	jalr	-1018(ra) # 5bf4 <printf>
    exit(1);
    1ff6:	4505                	li	a0,1
    1ff8:	00004097          	auipc	ra,0x4
    1ffc:	84c080e7          	jalr	-1972(ra) # 5844 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2000:	85a6                	mv	a1,s1
    2002:	00005517          	auipc	a0,0x5
    2006:	d4e50513          	addi	a0,a0,-690 # 6d50 <malloc+0x109e>
    200a:	00004097          	auipc	ra,0x4
    200e:	bea080e7          	jalr	-1046(ra) # 5bf4 <printf>
    exit(1);
    2012:	4505                	li	a0,1
    2014:	00004097          	auipc	ra,0x4
    2018:	830080e7          	jalr	-2000(ra) # 5844 <exit>

000000000000201c <iputtest>:
{
    201c:	1101                	addi	sp,sp,-32
    201e:	ec06                	sd	ra,24(sp)
    2020:	e822                	sd	s0,16(sp)
    2022:	e426                	sd	s1,8(sp)
    2024:	1000                	addi	s0,sp,32
    2026:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2028:	00005517          	auipc	a0,0x5
    202c:	d6050513          	addi	a0,a0,-672 # 6d88 <malloc+0x10d6>
    2030:	00004097          	auipc	ra,0x4
    2034:	87c080e7          	jalr	-1924(ra) # 58ac <mkdir>
    2038:	04054563          	bltz	a0,2082 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    203c:	00005517          	auipc	a0,0x5
    2040:	d4c50513          	addi	a0,a0,-692 # 6d88 <malloc+0x10d6>
    2044:	00004097          	auipc	ra,0x4
    2048:	870080e7          	jalr	-1936(ra) # 58b4 <chdir>
    204c:	04054963          	bltz	a0,209e <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2050:	00005517          	auipc	a0,0x5
    2054:	d7850513          	addi	a0,a0,-648 # 6dc8 <malloc+0x1116>
    2058:	00004097          	auipc	ra,0x4
    205c:	83c080e7          	jalr	-1988(ra) # 5894 <unlink>
    2060:	04054d63          	bltz	a0,20ba <iputtest+0x9e>
  if(chdir("/") < 0){
    2064:	00005517          	auipc	a0,0x5
    2068:	d9450513          	addi	a0,a0,-620 # 6df8 <malloc+0x1146>
    206c:	00004097          	auipc	ra,0x4
    2070:	848080e7          	jalr	-1976(ra) # 58b4 <chdir>
    2074:	06054163          	bltz	a0,20d6 <iputtest+0xba>
}
    2078:	60e2                	ld	ra,24(sp)
    207a:	6442                	ld	s0,16(sp)
    207c:	64a2                	ld	s1,8(sp)
    207e:	6105                	addi	sp,sp,32
    2080:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2082:	85a6                	mv	a1,s1
    2084:	00005517          	auipc	a0,0x5
    2088:	d0c50513          	addi	a0,a0,-756 # 6d90 <malloc+0x10de>
    208c:	00004097          	auipc	ra,0x4
    2090:	b68080e7          	jalr	-1176(ra) # 5bf4 <printf>
    exit(1);
    2094:	4505                	li	a0,1
    2096:	00003097          	auipc	ra,0x3
    209a:	7ae080e7          	jalr	1966(ra) # 5844 <exit>
    printf("%s: chdir iputdir failed\n", s);
    209e:	85a6                	mv	a1,s1
    20a0:	00005517          	auipc	a0,0x5
    20a4:	d0850513          	addi	a0,a0,-760 # 6da8 <malloc+0x10f6>
    20a8:	00004097          	auipc	ra,0x4
    20ac:	b4c080e7          	jalr	-1204(ra) # 5bf4 <printf>
    exit(1);
    20b0:	4505                	li	a0,1
    20b2:	00003097          	auipc	ra,0x3
    20b6:	792080e7          	jalr	1938(ra) # 5844 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    20ba:	85a6                	mv	a1,s1
    20bc:	00005517          	auipc	a0,0x5
    20c0:	d1c50513          	addi	a0,a0,-740 # 6dd8 <malloc+0x1126>
    20c4:	00004097          	auipc	ra,0x4
    20c8:	b30080e7          	jalr	-1232(ra) # 5bf4 <printf>
    exit(1);
    20cc:	4505                	li	a0,1
    20ce:	00003097          	auipc	ra,0x3
    20d2:	776080e7          	jalr	1910(ra) # 5844 <exit>
    printf("%s: chdir / failed\n", s);
    20d6:	85a6                	mv	a1,s1
    20d8:	00005517          	auipc	a0,0x5
    20dc:	d2850513          	addi	a0,a0,-728 # 6e00 <malloc+0x114e>
    20e0:	00004097          	auipc	ra,0x4
    20e4:	b14080e7          	jalr	-1260(ra) # 5bf4 <printf>
    exit(1);
    20e8:	4505                	li	a0,1
    20ea:	00003097          	auipc	ra,0x3
    20ee:	75a080e7          	jalr	1882(ra) # 5844 <exit>

00000000000020f2 <exitiputtest>:
{
    20f2:	7179                	addi	sp,sp,-48
    20f4:	f406                	sd	ra,40(sp)
    20f6:	f022                	sd	s0,32(sp)
    20f8:	ec26                	sd	s1,24(sp)
    20fa:	1800                	addi	s0,sp,48
    20fc:	84aa                	mv	s1,a0
  pid = fork();
    20fe:	00003097          	auipc	ra,0x3
    2102:	73e080e7          	jalr	1854(ra) # 583c <fork>
  if(pid < 0){
    2106:	04054663          	bltz	a0,2152 <exitiputtest+0x60>
  if(pid == 0){
    210a:	ed45                	bnez	a0,21c2 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    210c:	00005517          	auipc	a0,0x5
    2110:	c7c50513          	addi	a0,a0,-900 # 6d88 <malloc+0x10d6>
    2114:	00003097          	auipc	ra,0x3
    2118:	798080e7          	jalr	1944(ra) # 58ac <mkdir>
    211c:	04054963          	bltz	a0,216e <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    2120:	00005517          	auipc	a0,0x5
    2124:	c6850513          	addi	a0,a0,-920 # 6d88 <malloc+0x10d6>
    2128:	00003097          	auipc	ra,0x3
    212c:	78c080e7          	jalr	1932(ra) # 58b4 <chdir>
    2130:	04054d63          	bltz	a0,218a <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    2134:	00005517          	auipc	a0,0x5
    2138:	c9450513          	addi	a0,a0,-876 # 6dc8 <malloc+0x1116>
    213c:	00003097          	auipc	ra,0x3
    2140:	758080e7          	jalr	1880(ra) # 5894 <unlink>
    2144:	06054163          	bltz	a0,21a6 <exitiputtest+0xb4>
    exit(0);
    2148:	4501                	li	a0,0
    214a:	00003097          	auipc	ra,0x3
    214e:	6fa080e7          	jalr	1786(ra) # 5844 <exit>
    printf("%s: fork failed\n", s);
    2152:	85a6                	mv	a1,s1
    2154:	00004517          	auipc	a0,0x4
    2158:	ea450513          	addi	a0,a0,-348 # 5ff8 <malloc+0x346>
    215c:	00004097          	auipc	ra,0x4
    2160:	a98080e7          	jalr	-1384(ra) # 5bf4 <printf>
    exit(1);
    2164:	4505                	li	a0,1
    2166:	00003097          	auipc	ra,0x3
    216a:	6de080e7          	jalr	1758(ra) # 5844 <exit>
      printf("%s: mkdir failed\n", s);
    216e:	85a6                	mv	a1,s1
    2170:	00005517          	auipc	a0,0x5
    2174:	c2050513          	addi	a0,a0,-992 # 6d90 <malloc+0x10de>
    2178:	00004097          	auipc	ra,0x4
    217c:	a7c080e7          	jalr	-1412(ra) # 5bf4 <printf>
      exit(1);
    2180:	4505                	li	a0,1
    2182:	00003097          	auipc	ra,0x3
    2186:	6c2080e7          	jalr	1730(ra) # 5844 <exit>
      printf("%s: child chdir failed\n", s);
    218a:	85a6                	mv	a1,s1
    218c:	00005517          	auipc	a0,0x5
    2190:	c8c50513          	addi	a0,a0,-884 # 6e18 <malloc+0x1166>
    2194:	00004097          	auipc	ra,0x4
    2198:	a60080e7          	jalr	-1440(ra) # 5bf4 <printf>
      exit(1);
    219c:	4505                	li	a0,1
    219e:	00003097          	auipc	ra,0x3
    21a2:	6a6080e7          	jalr	1702(ra) # 5844 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    21a6:	85a6                	mv	a1,s1
    21a8:	00005517          	auipc	a0,0x5
    21ac:	c3050513          	addi	a0,a0,-976 # 6dd8 <malloc+0x1126>
    21b0:	00004097          	auipc	ra,0x4
    21b4:	a44080e7          	jalr	-1468(ra) # 5bf4 <printf>
      exit(1);
    21b8:	4505                	li	a0,1
    21ba:	00003097          	auipc	ra,0x3
    21be:	68a080e7          	jalr	1674(ra) # 5844 <exit>
  wait(&xstatus);
    21c2:	fdc40513          	addi	a0,s0,-36
    21c6:	00003097          	auipc	ra,0x3
    21ca:	686080e7          	jalr	1670(ra) # 584c <wait>
  exit(xstatus);
    21ce:	fdc42503          	lw	a0,-36(s0)
    21d2:	00003097          	auipc	ra,0x3
    21d6:	672080e7          	jalr	1650(ra) # 5844 <exit>

00000000000021da <dirtest>:
{
    21da:	1101                	addi	sp,sp,-32
    21dc:	ec06                	sd	ra,24(sp)
    21de:	e822                	sd	s0,16(sp)
    21e0:	e426                	sd	s1,8(sp)
    21e2:	1000                	addi	s0,sp,32
    21e4:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    21e6:	00005517          	auipc	a0,0x5
    21ea:	c4a50513          	addi	a0,a0,-950 # 6e30 <malloc+0x117e>
    21ee:	00003097          	auipc	ra,0x3
    21f2:	6be080e7          	jalr	1726(ra) # 58ac <mkdir>
    21f6:	04054563          	bltz	a0,2240 <dirtest+0x66>
  if(chdir("dir0") < 0){
    21fa:	00005517          	auipc	a0,0x5
    21fe:	c3650513          	addi	a0,a0,-970 # 6e30 <malloc+0x117e>
    2202:	00003097          	auipc	ra,0x3
    2206:	6b2080e7          	jalr	1714(ra) # 58b4 <chdir>
    220a:	04054963          	bltz	a0,225c <dirtest+0x82>
  if(chdir("..") < 0){
    220e:	00005517          	auipc	a0,0x5
    2212:	c4250513          	addi	a0,a0,-958 # 6e50 <malloc+0x119e>
    2216:	00003097          	auipc	ra,0x3
    221a:	69e080e7          	jalr	1694(ra) # 58b4 <chdir>
    221e:	04054d63          	bltz	a0,2278 <dirtest+0x9e>
  if(unlink("dir0") < 0){
    2222:	00005517          	auipc	a0,0x5
    2226:	c0e50513          	addi	a0,a0,-1010 # 6e30 <malloc+0x117e>
    222a:	00003097          	auipc	ra,0x3
    222e:	66a080e7          	jalr	1642(ra) # 5894 <unlink>
    2232:	06054163          	bltz	a0,2294 <dirtest+0xba>
}
    2236:	60e2                	ld	ra,24(sp)
    2238:	6442                	ld	s0,16(sp)
    223a:	64a2                	ld	s1,8(sp)
    223c:	6105                	addi	sp,sp,32
    223e:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2240:	85a6                	mv	a1,s1
    2242:	00005517          	auipc	a0,0x5
    2246:	b4e50513          	addi	a0,a0,-1202 # 6d90 <malloc+0x10de>
    224a:	00004097          	auipc	ra,0x4
    224e:	9aa080e7          	jalr	-1622(ra) # 5bf4 <printf>
    exit(1);
    2252:	4505                	li	a0,1
    2254:	00003097          	auipc	ra,0x3
    2258:	5f0080e7          	jalr	1520(ra) # 5844 <exit>
    printf("%s: chdir dir0 failed\n", s);
    225c:	85a6                	mv	a1,s1
    225e:	00005517          	auipc	a0,0x5
    2262:	bda50513          	addi	a0,a0,-1062 # 6e38 <malloc+0x1186>
    2266:	00004097          	auipc	ra,0x4
    226a:	98e080e7          	jalr	-1650(ra) # 5bf4 <printf>
    exit(1);
    226e:	4505                	li	a0,1
    2270:	00003097          	auipc	ra,0x3
    2274:	5d4080e7          	jalr	1492(ra) # 5844 <exit>
    printf("%s: chdir .. failed\n", s);
    2278:	85a6                	mv	a1,s1
    227a:	00005517          	auipc	a0,0x5
    227e:	bde50513          	addi	a0,a0,-1058 # 6e58 <malloc+0x11a6>
    2282:	00004097          	auipc	ra,0x4
    2286:	972080e7          	jalr	-1678(ra) # 5bf4 <printf>
    exit(1);
    228a:	4505                	li	a0,1
    228c:	00003097          	auipc	ra,0x3
    2290:	5b8080e7          	jalr	1464(ra) # 5844 <exit>
    printf("%s: unlink dir0 failed\n", s);
    2294:	85a6                	mv	a1,s1
    2296:	00005517          	auipc	a0,0x5
    229a:	bda50513          	addi	a0,a0,-1062 # 6e70 <malloc+0x11be>
    229e:	00004097          	auipc	ra,0x4
    22a2:	956080e7          	jalr	-1706(ra) # 5bf4 <printf>
    exit(1);
    22a6:	4505                	li	a0,1
    22a8:	00003097          	auipc	ra,0x3
    22ac:	59c080e7          	jalr	1436(ra) # 5844 <exit>

00000000000022b0 <subdir>:
{
    22b0:	1101                	addi	sp,sp,-32
    22b2:	ec06                	sd	ra,24(sp)
    22b4:	e822                	sd	s0,16(sp)
    22b6:	e426                	sd	s1,8(sp)
    22b8:	e04a                	sd	s2,0(sp)
    22ba:	1000                	addi	s0,sp,32
    22bc:	892a                	mv	s2,a0
  unlink("ff");
    22be:	00005517          	auipc	a0,0x5
    22c2:	cfa50513          	addi	a0,a0,-774 # 6fb8 <malloc+0x1306>
    22c6:	00003097          	auipc	ra,0x3
    22ca:	5ce080e7          	jalr	1486(ra) # 5894 <unlink>
  if(mkdir("dd") != 0){
    22ce:	00005517          	auipc	a0,0x5
    22d2:	bba50513          	addi	a0,a0,-1094 # 6e88 <malloc+0x11d6>
    22d6:	00003097          	auipc	ra,0x3
    22da:	5d6080e7          	jalr	1494(ra) # 58ac <mkdir>
    22de:	38051663          	bnez	a0,266a <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    22e2:	20200593          	li	a1,514
    22e6:	00005517          	auipc	a0,0x5
    22ea:	bc250513          	addi	a0,a0,-1086 # 6ea8 <malloc+0x11f6>
    22ee:	00003097          	auipc	ra,0x3
    22f2:	596080e7          	jalr	1430(ra) # 5884 <open>
    22f6:	84aa                	mv	s1,a0
  if(fd < 0){
    22f8:	38054763          	bltz	a0,2686 <subdir+0x3d6>
  write(fd, "ff", 2);
    22fc:	4609                	li	a2,2
    22fe:	00005597          	auipc	a1,0x5
    2302:	cba58593          	addi	a1,a1,-838 # 6fb8 <malloc+0x1306>
    2306:	00003097          	auipc	ra,0x3
    230a:	55e080e7          	jalr	1374(ra) # 5864 <write>
  close(fd);
    230e:	8526                	mv	a0,s1
    2310:	00003097          	auipc	ra,0x3
    2314:	55c080e7          	jalr	1372(ra) # 586c <close>
  if(unlink("dd") >= 0){
    2318:	00005517          	auipc	a0,0x5
    231c:	b7050513          	addi	a0,a0,-1168 # 6e88 <malloc+0x11d6>
    2320:	00003097          	auipc	ra,0x3
    2324:	574080e7          	jalr	1396(ra) # 5894 <unlink>
    2328:	36055d63          	bgez	a0,26a2 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    232c:	00005517          	auipc	a0,0x5
    2330:	bd450513          	addi	a0,a0,-1068 # 6f00 <malloc+0x124e>
    2334:	00003097          	auipc	ra,0x3
    2338:	578080e7          	jalr	1400(ra) # 58ac <mkdir>
    233c:	38051163          	bnez	a0,26be <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2340:	20200593          	li	a1,514
    2344:	00005517          	auipc	a0,0x5
    2348:	be450513          	addi	a0,a0,-1052 # 6f28 <malloc+0x1276>
    234c:	00003097          	auipc	ra,0x3
    2350:	538080e7          	jalr	1336(ra) # 5884 <open>
    2354:	84aa                	mv	s1,a0
  if(fd < 0){
    2356:	38054263          	bltz	a0,26da <subdir+0x42a>
  write(fd, "FF", 2);
    235a:	4609                	li	a2,2
    235c:	00005597          	auipc	a1,0x5
    2360:	bfc58593          	addi	a1,a1,-1028 # 6f58 <malloc+0x12a6>
    2364:	00003097          	auipc	ra,0x3
    2368:	500080e7          	jalr	1280(ra) # 5864 <write>
  close(fd);
    236c:	8526                	mv	a0,s1
    236e:	00003097          	auipc	ra,0x3
    2372:	4fe080e7          	jalr	1278(ra) # 586c <close>
  fd = open("dd/dd/../ff", 0);
    2376:	4581                	li	a1,0
    2378:	00005517          	auipc	a0,0x5
    237c:	be850513          	addi	a0,a0,-1048 # 6f60 <malloc+0x12ae>
    2380:	00003097          	auipc	ra,0x3
    2384:	504080e7          	jalr	1284(ra) # 5884 <open>
    2388:	84aa                	mv	s1,a0
  if(fd < 0){
    238a:	36054663          	bltz	a0,26f6 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    238e:	660d                	lui	a2,0x3
    2390:	0000a597          	auipc	a1,0xa
    2394:	83058593          	addi	a1,a1,-2000 # bbc0 <buf>
    2398:	00003097          	auipc	ra,0x3
    239c:	4c4080e7          	jalr	1220(ra) # 585c <read>
  if(cc != 2 || buf[0] != 'f'){
    23a0:	4789                	li	a5,2
    23a2:	36f51863          	bne	a0,a5,2712 <subdir+0x462>
    23a6:	0000a717          	auipc	a4,0xa
    23aa:	81a74703          	lbu	a4,-2022(a4) # bbc0 <buf>
    23ae:	06600793          	li	a5,102
    23b2:	36f71063          	bne	a4,a5,2712 <subdir+0x462>
  close(fd);
    23b6:	8526                	mv	a0,s1
    23b8:	00003097          	auipc	ra,0x3
    23bc:	4b4080e7          	jalr	1204(ra) # 586c <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    23c0:	00005597          	auipc	a1,0x5
    23c4:	bf058593          	addi	a1,a1,-1040 # 6fb0 <malloc+0x12fe>
    23c8:	00005517          	auipc	a0,0x5
    23cc:	b6050513          	addi	a0,a0,-1184 # 6f28 <malloc+0x1276>
    23d0:	00003097          	auipc	ra,0x3
    23d4:	4d4080e7          	jalr	1236(ra) # 58a4 <link>
    23d8:	34051b63          	bnez	a0,272e <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    23dc:	00005517          	auipc	a0,0x5
    23e0:	b4c50513          	addi	a0,a0,-1204 # 6f28 <malloc+0x1276>
    23e4:	00003097          	auipc	ra,0x3
    23e8:	4b0080e7          	jalr	1200(ra) # 5894 <unlink>
    23ec:	34051f63          	bnez	a0,274a <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    23f0:	4581                	li	a1,0
    23f2:	00005517          	auipc	a0,0x5
    23f6:	b3650513          	addi	a0,a0,-1226 # 6f28 <malloc+0x1276>
    23fa:	00003097          	auipc	ra,0x3
    23fe:	48a080e7          	jalr	1162(ra) # 5884 <open>
    2402:	36055263          	bgez	a0,2766 <subdir+0x4b6>
  if(chdir("dd") != 0){
    2406:	00005517          	auipc	a0,0x5
    240a:	a8250513          	addi	a0,a0,-1406 # 6e88 <malloc+0x11d6>
    240e:	00003097          	auipc	ra,0x3
    2412:	4a6080e7          	jalr	1190(ra) # 58b4 <chdir>
    2416:	36051663          	bnez	a0,2782 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    241a:	00005517          	auipc	a0,0x5
    241e:	c2e50513          	addi	a0,a0,-978 # 7048 <malloc+0x1396>
    2422:	00003097          	auipc	ra,0x3
    2426:	492080e7          	jalr	1170(ra) # 58b4 <chdir>
    242a:	36051a63          	bnez	a0,279e <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    242e:	00005517          	auipc	a0,0x5
    2432:	c4a50513          	addi	a0,a0,-950 # 7078 <malloc+0x13c6>
    2436:	00003097          	auipc	ra,0x3
    243a:	47e080e7          	jalr	1150(ra) # 58b4 <chdir>
    243e:	36051e63          	bnez	a0,27ba <subdir+0x50a>
  if(chdir("./..") != 0){
    2442:	00005517          	auipc	a0,0x5
    2446:	c6650513          	addi	a0,a0,-922 # 70a8 <malloc+0x13f6>
    244a:	00003097          	auipc	ra,0x3
    244e:	46a080e7          	jalr	1130(ra) # 58b4 <chdir>
    2452:	38051263          	bnez	a0,27d6 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    2456:	4581                	li	a1,0
    2458:	00005517          	auipc	a0,0x5
    245c:	b5850513          	addi	a0,a0,-1192 # 6fb0 <malloc+0x12fe>
    2460:	00003097          	auipc	ra,0x3
    2464:	424080e7          	jalr	1060(ra) # 5884 <open>
    2468:	84aa                	mv	s1,a0
  if(fd < 0){
    246a:	38054463          	bltz	a0,27f2 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    246e:	660d                	lui	a2,0x3
    2470:	00009597          	auipc	a1,0x9
    2474:	75058593          	addi	a1,a1,1872 # bbc0 <buf>
    2478:	00003097          	auipc	ra,0x3
    247c:	3e4080e7          	jalr	996(ra) # 585c <read>
    2480:	4789                	li	a5,2
    2482:	38f51663          	bne	a0,a5,280e <subdir+0x55e>
  close(fd);
    2486:	8526                	mv	a0,s1
    2488:	00003097          	auipc	ra,0x3
    248c:	3e4080e7          	jalr	996(ra) # 586c <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2490:	4581                	li	a1,0
    2492:	00005517          	auipc	a0,0x5
    2496:	a9650513          	addi	a0,a0,-1386 # 6f28 <malloc+0x1276>
    249a:	00003097          	auipc	ra,0x3
    249e:	3ea080e7          	jalr	1002(ra) # 5884 <open>
    24a2:	38055463          	bgez	a0,282a <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    24a6:	20200593          	li	a1,514
    24aa:	00005517          	auipc	a0,0x5
    24ae:	c8e50513          	addi	a0,a0,-882 # 7138 <malloc+0x1486>
    24b2:	00003097          	auipc	ra,0x3
    24b6:	3d2080e7          	jalr	978(ra) # 5884 <open>
    24ba:	38055663          	bgez	a0,2846 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    24be:	20200593          	li	a1,514
    24c2:	00005517          	auipc	a0,0x5
    24c6:	ca650513          	addi	a0,a0,-858 # 7168 <malloc+0x14b6>
    24ca:	00003097          	auipc	ra,0x3
    24ce:	3ba080e7          	jalr	954(ra) # 5884 <open>
    24d2:	38055863          	bgez	a0,2862 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    24d6:	20000593          	li	a1,512
    24da:	00005517          	auipc	a0,0x5
    24de:	9ae50513          	addi	a0,a0,-1618 # 6e88 <malloc+0x11d6>
    24e2:	00003097          	auipc	ra,0x3
    24e6:	3a2080e7          	jalr	930(ra) # 5884 <open>
    24ea:	38055a63          	bgez	a0,287e <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    24ee:	4589                	li	a1,2
    24f0:	00005517          	auipc	a0,0x5
    24f4:	99850513          	addi	a0,a0,-1640 # 6e88 <malloc+0x11d6>
    24f8:	00003097          	auipc	ra,0x3
    24fc:	38c080e7          	jalr	908(ra) # 5884 <open>
    2500:	38055d63          	bgez	a0,289a <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    2504:	4585                	li	a1,1
    2506:	00005517          	auipc	a0,0x5
    250a:	98250513          	addi	a0,a0,-1662 # 6e88 <malloc+0x11d6>
    250e:	00003097          	auipc	ra,0x3
    2512:	376080e7          	jalr	886(ra) # 5884 <open>
    2516:	3a055063          	bgez	a0,28b6 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    251a:	00005597          	auipc	a1,0x5
    251e:	cde58593          	addi	a1,a1,-802 # 71f8 <malloc+0x1546>
    2522:	00005517          	auipc	a0,0x5
    2526:	c1650513          	addi	a0,a0,-1002 # 7138 <malloc+0x1486>
    252a:	00003097          	auipc	ra,0x3
    252e:	37a080e7          	jalr	890(ra) # 58a4 <link>
    2532:	3a050063          	beqz	a0,28d2 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    2536:	00005597          	auipc	a1,0x5
    253a:	cc258593          	addi	a1,a1,-830 # 71f8 <malloc+0x1546>
    253e:	00005517          	auipc	a0,0x5
    2542:	c2a50513          	addi	a0,a0,-982 # 7168 <malloc+0x14b6>
    2546:	00003097          	auipc	ra,0x3
    254a:	35e080e7          	jalr	862(ra) # 58a4 <link>
    254e:	3a050063          	beqz	a0,28ee <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    2552:	00005597          	auipc	a1,0x5
    2556:	a5e58593          	addi	a1,a1,-1442 # 6fb0 <malloc+0x12fe>
    255a:	00005517          	auipc	a0,0x5
    255e:	94e50513          	addi	a0,a0,-1714 # 6ea8 <malloc+0x11f6>
    2562:	00003097          	auipc	ra,0x3
    2566:	342080e7          	jalr	834(ra) # 58a4 <link>
    256a:	3a050063          	beqz	a0,290a <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    256e:	00005517          	auipc	a0,0x5
    2572:	bca50513          	addi	a0,a0,-1078 # 7138 <malloc+0x1486>
    2576:	00003097          	auipc	ra,0x3
    257a:	336080e7          	jalr	822(ra) # 58ac <mkdir>
    257e:	3a050463          	beqz	a0,2926 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    2582:	00005517          	auipc	a0,0x5
    2586:	be650513          	addi	a0,a0,-1050 # 7168 <malloc+0x14b6>
    258a:	00003097          	auipc	ra,0x3
    258e:	322080e7          	jalr	802(ra) # 58ac <mkdir>
    2592:	3a050863          	beqz	a0,2942 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    2596:	00005517          	auipc	a0,0x5
    259a:	a1a50513          	addi	a0,a0,-1510 # 6fb0 <malloc+0x12fe>
    259e:	00003097          	auipc	ra,0x3
    25a2:	30e080e7          	jalr	782(ra) # 58ac <mkdir>
    25a6:	3a050c63          	beqz	a0,295e <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    25aa:	00005517          	auipc	a0,0x5
    25ae:	bbe50513          	addi	a0,a0,-1090 # 7168 <malloc+0x14b6>
    25b2:	00003097          	auipc	ra,0x3
    25b6:	2e2080e7          	jalr	738(ra) # 5894 <unlink>
    25ba:	3c050063          	beqz	a0,297a <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    25be:	00005517          	auipc	a0,0x5
    25c2:	b7a50513          	addi	a0,a0,-1158 # 7138 <malloc+0x1486>
    25c6:	00003097          	auipc	ra,0x3
    25ca:	2ce080e7          	jalr	718(ra) # 5894 <unlink>
    25ce:	3c050463          	beqz	a0,2996 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    25d2:	00005517          	auipc	a0,0x5
    25d6:	8d650513          	addi	a0,a0,-1834 # 6ea8 <malloc+0x11f6>
    25da:	00003097          	auipc	ra,0x3
    25de:	2da080e7          	jalr	730(ra) # 58b4 <chdir>
    25e2:	3c050863          	beqz	a0,29b2 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    25e6:	00005517          	auipc	a0,0x5
    25ea:	d6250513          	addi	a0,a0,-670 # 7348 <malloc+0x1696>
    25ee:	00003097          	auipc	ra,0x3
    25f2:	2c6080e7          	jalr	710(ra) # 58b4 <chdir>
    25f6:	3c050c63          	beqz	a0,29ce <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    25fa:	00005517          	auipc	a0,0x5
    25fe:	9b650513          	addi	a0,a0,-1610 # 6fb0 <malloc+0x12fe>
    2602:	00003097          	auipc	ra,0x3
    2606:	292080e7          	jalr	658(ra) # 5894 <unlink>
    260a:	3e051063          	bnez	a0,29ea <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    260e:	00005517          	auipc	a0,0x5
    2612:	89a50513          	addi	a0,a0,-1894 # 6ea8 <malloc+0x11f6>
    2616:	00003097          	auipc	ra,0x3
    261a:	27e080e7          	jalr	638(ra) # 5894 <unlink>
    261e:	3e051463          	bnez	a0,2a06 <subdir+0x756>
  if(unlink("dd") == 0){
    2622:	00005517          	auipc	a0,0x5
    2626:	86650513          	addi	a0,a0,-1946 # 6e88 <malloc+0x11d6>
    262a:	00003097          	auipc	ra,0x3
    262e:	26a080e7          	jalr	618(ra) # 5894 <unlink>
    2632:	3e050863          	beqz	a0,2a22 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    2636:	00005517          	auipc	a0,0x5
    263a:	d8250513          	addi	a0,a0,-638 # 73b8 <malloc+0x1706>
    263e:	00003097          	auipc	ra,0x3
    2642:	256080e7          	jalr	598(ra) # 5894 <unlink>
    2646:	3e054c63          	bltz	a0,2a3e <subdir+0x78e>
  if(unlink("dd") < 0){
    264a:	00005517          	auipc	a0,0x5
    264e:	83e50513          	addi	a0,a0,-1986 # 6e88 <malloc+0x11d6>
    2652:	00003097          	auipc	ra,0x3
    2656:	242080e7          	jalr	578(ra) # 5894 <unlink>
    265a:	40054063          	bltz	a0,2a5a <subdir+0x7aa>
}
    265e:	60e2                	ld	ra,24(sp)
    2660:	6442                	ld	s0,16(sp)
    2662:	64a2                	ld	s1,8(sp)
    2664:	6902                	ld	s2,0(sp)
    2666:	6105                	addi	sp,sp,32
    2668:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    266a:	85ca                	mv	a1,s2
    266c:	00005517          	auipc	a0,0x5
    2670:	82450513          	addi	a0,a0,-2012 # 6e90 <malloc+0x11de>
    2674:	00003097          	auipc	ra,0x3
    2678:	580080e7          	jalr	1408(ra) # 5bf4 <printf>
    exit(1);
    267c:	4505                	li	a0,1
    267e:	00003097          	auipc	ra,0x3
    2682:	1c6080e7          	jalr	454(ra) # 5844 <exit>
    printf("%s: create dd/ff failed\n", s);
    2686:	85ca                	mv	a1,s2
    2688:	00005517          	auipc	a0,0x5
    268c:	82850513          	addi	a0,a0,-2008 # 6eb0 <malloc+0x11fe>
    2690:	00003097          	auipc	ra,0x3
    2694:	564080e7          	jalr	1380(ra) # 5bf4 <printf>
    exit(1);
    2698:	4505                	li	a0,1
    269a:	00003097          	auipc	ra,0x3
    269e:	1aa080e7          	jalr	426(ra) # 5844 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    26a2:	85ca                	mv	a1,s2
    26a4:	00005517          	auipc	a0,0x5
    26a8:	82c50513          	addi	a0,a0,-2004 # 6ed0 <malloc+0x121e>
    26ac:	00003097          	auipc	ra,0x3
    26b0:	548080e7          	jalr	1352(ra) # 5bf4 <printf>
    exit(1);
    26b4:	4505                	li	a0,1
    26b6:	00003097          	auipc	ra,0x3
    26ba:	18e080e7          	jalr	398(ra) # 5844 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    26be:	85ca                	mv	a1,s2
    26c0:	00005517          	auipc	a0,0x5
    26c4:	84850513          	addi	a0,a0,-1976 # 6f08 <malloc+0x1256>
    26c8:	00003097          	auipc	ra,0x3
    26cc:	52c080e7          	jalr	1324(ra) # 5bf4 <printf>
    exit(1);
    26d0:	4505                	li	a0,1
    26d2:	00003097          	auipc	ra,0x3
    26d6:	172080e7          	jalr	370(ra) # 5844 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    26da:	85ca                	mv	a1,s2
    26dc:	00005517          	auipc	a0,0x5
    26e0:	85c50513          	addi	a0,a0,-1956 # 6f38 <malloc+0x1286>
    26e4:	00003097          	auipc	ra,0x3
    26e8:	510080e7          	jalr	1296(ra) # 5bf4 <printf>
    exit(1);
    26ec:	4505                	li	a0,1
    26ee:	00003097          	auipc	ra,0x3
    26f2:	156080e7          	jalr	342(ra) # 5844 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    26f6:	85ca                	mv	a1,s2
    26f8:	00005517          	auipc	a0,0x5
    26fc:	87850513          	addi	a0,a0,-1928 # 6f70 <malloc+0x12be>
    2700:	00003097          	auipc	ra,0x3
    2704:	4f4080e7          	jalr	1268(ra) # 5bf4 <printf>
    exit(1);
    2708:	4505                	li	a0,1
    270a:	00003097          	auipc	ra,0x3
    270e:	13a080e7          	jalr	314(ra) # 5844 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    2712:	85ca                	mv	a1,s2
    2714:	00005517          	auipc	a0,0x5
    2718:	87c50513          	addi	a0,a0,-1924 # 6f90 <malloc+0x12de>
    271c:	00003097          	auipc	ra,0x3
    2720:	4d8080e7          	jalr	1240(ra) # 5bf4 <printf>
    exit(1);
    2724:	4505                	li	a0,1
    2726:	00003097          	auipc	ra,0x3
    272a:	11e080e7          	jalr	286(ra) # 5844 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    272e:	85ca                	mv	a1,s2
    2730:	00005517          	auipc	a0,0x5
    2734:	89050513          	addi	a0,a0,-1904 # 6fc0 <malloc+0x130e>
    2738:	00003097          	auipc	ra,0x3
    273c:	4bc080e7          	jalr	1212(ra) # 5bf4 <printf>
    exit(1);
    2740:	4505                	li	a0,1
    2742:	00003097          	auipc	ra,0x3
    2746:	102080e7          	jalr	258(ra) # 5844 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    274a:	85ca                	mv	a1,s2
    274c:	00005517          	auipc	a0,0x5
    2750:	89c50513          	addi	a0,a0,-1892 # 6fe8 <malloc+0x1336>
    2754:	00003097          	auipc	ra,0x3
    2758:	4a0080e7          	jalr	1184(ra) # 5bf4 <printf>
    exit(1);
    275c:	4505                	li	a0,1
    275e:	00003097          	auipc	ra,0x3
    2762:	0e6080e7          	jalr	230(ra) # 5844 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    2766:	85ca                	mv	a1,s2
    2768:	00005517          	auipc	a0,0x5
    276c:	8a050513          	addi	a0,a0,-1888 # 7008 <malloc+0x1356>
    2770:	00003097          	auipc	ra,0x3
    2774:	484080e7          	jalr	1156(ra) # 5bf4 <printf>
    exit(1);
    2778:	4505                	li	a0,1
    277a:	00003097          	auipc	ra,0x3
    277e:	0ca080e7          	jalr	202(ra) # 5844 <exit>
    printf("%s: chdir dd failed\n", s);
    2782:	85ca                	mv	a1,s2
    2784:	00005517          	auipc	a0,0x5
    2788:	8ac50513          	addi	a0,a0,-1876 # 7030 <malloc+0x137e>
    278c:	00003097          	auipc	ra,0x3
    2790:	468080e7          	jalr	1128(ra) # 5bf4 <printf>
    exit(1);
    2794:	4505                	li	a0,1
    2796:	00003097          	auipc	ra,0x3
    279a:	0ae080e7          	jalr	174(ra) # 5844 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    279e:	85ca                	mv	a1,s2
    27a0:	00005517          	auipc	a0,0x5
    27a4:	8b850513          	addi	a0,a0,-1864 # 7058 <malloc+0x13a6>
    27a8:	00003097          	auipc	ra,0x3
    27ac:	44c080e7          	jalr	1100(ra) # 5bf4 <printf>
    exit(1);
    27b0:	4505                	li	a0,1
    27b2:	00003097          	auipc	ra,0x3
    27b6:	092080e7          	jalr	146(ra) # 5844 <exit>
    printf("chdir dd/../../dd failed\n", s);
    27ba:	85ca                	mv	a1,s2
    27bc:	00005517          	auipc	a0,0x5
    27c0:	8cc50513          	addi	a0,a0,-1844 # 7088 <malloc+0x13d6>
    27c4:	00003097          	auipc	ra,0x3
    27c8:	430080e7          	jalr	1072(ra) # 5bf4 <printf>
    exit(1);
    27cc:	4505                	li	a0,1
    27ce:	00003097          	auipc	ra,0x3
    27d2:	076080e7          	jalr	118(ra) # 5844 <exit>
    printf("%s: chdir ./.. failed\n", s);
    27d6:	85ca                	mv	a1,s2
    27d8:	00005517          	auipc	a0,0x5
    27dc:	8d850513          	addi	a0,a0,-1832 # 70b0 <malloc+0x13fe>
    27e0:	00003097          	auipc	ra,0x3
    27e4:	414080e7          	jalr	1044(ra) # 5bf4 <printf>
    exit(1);
    27e8:	4505                	li	a0,1
    27ea:	00003097          	auipc	ra,0x3
    27ee:	05a080e7          	jalr	90(ra) # 5844 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    27f2:	85ca                	mv	a1,s2
    27f4:	00005517          	auipc	a0,0x5
    27f8:	8d450513          	addi	a0,a0,-1836 # 70c8 <malloc+0x1416>
    27fc:	00003097          	auipc	ra,0x3
    2800:	3f8080e7          	jalr	1016(ra) # 5bf4 <printf>
    exit(1);
    2804:	4505                	li	a0,1
    2806:	00003097          	auipc	ra,0x3
    280a:	03e080e7          	jalr	62(ra) # 5844 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    280e:	85ca                	mv	a1,s2
    2810:	00005517          	auipc	a0,0x5
    2814:	8d850513          	addi	a0,a0,-1832 # 70e8 <malloc+0x1436>
    2818:	00003097          	auipc	ra,0x3
    281c:	3dc080e7          	jalr	988(ra) # 5bf4 <printf>
    exit(1);
    2820:	4505                	li	a0,1
    2822:	00003097          	auipc	ra,0x3
    2826:	022080e7          	jalr	34(ra) # 5844 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    282a:	85ca                	mv	a1,s2
    282c:	00005517          	auipc	a0,0x5
    2830:	8dc50513          	addi	a0,a0,-1828 # 7108 <malloc+0x1456>
    2834:	00003097          	auipc	ra,0x3
    2838:	3c0080e7          	jalr	960(ra) # 5bf4 <printf>
    exit(1);
    283c:	4505                	li	a0,1
    283e:	00003097          	auipc	ra,0x3
    2842:	006080e7          	jalr	6(ra) # 5844 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    2846:	85ca                	mv	a1,s2
    2848:	00005517          	auipc	a0,0x5
    284c:	90050513          	addi	a0,a0,-1792 # 7148 <malloc+0x1496>
    2850:	00003097          	auipc	ra,0x3
    2854:	3a4080e7          	jalr	932(ra) # 5bf4 <printf>
    exit(1);
    2858:	4505                	li	a0,1
    285a:	00003097          	auipc	ra,0x3
    285e:	fea080e7          	jalr	-22(ra) # 5844 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    2862:	85ca                	mv	a1,s2
    2864:	00005517          	auipc	a0,0x5
    2868:	91450513          	addi	a0,a0,-1772 # 7178 <malloc+0x14c6>
    286c:	00003097          	auipc	ra,0x3
    2870:	388080e7          	jalr	904(ra) # 5bf4 <printf>
    exit(1);
    2874:	4505                	li	a0,1
    2876:	00003097          	auipc	ra,0x3
    287a:	fce080e7          	jalr	-50(ra) # 5844 <exit>
    printf("%s: create dd succeeded!\n", s);
    287e:	85ca                	mv	a1,s2
    2880:	00005517          	auipc	a0,0x5
    2884:	91850513          	addi	a0,a0,-1768 # 7198 <malloc+0x14e6>
    2888:	00003097          	auipc	ra,0x3
    288c:	36c080e7          	jalr	876(ra) # 5bf4 <printf>
    exit(1);
    2890:	4505                	li	a0,1
    2892:	00003097          	auipc	ra,0x3
    2896:	fb2080e7          	jalr	-78(ra) # 5844 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    289a:	85ca                	mv	a1,s2
    289c:	00005517          	auipc	a0,0x5
    28a0:	91c50513          	addi	a0,a0,-1764 # 71b8 <malloc+0x1506>
    28a4:	00003097          	auipc	ra,0x3
    28a8:	350080e7          	jalr	848(ra) # 5bf4 <printf>
    exit(1);
    28ac:	4505                	li	a0,1
    28ae:	00003097          	auipc	ra,0x3
    28b2:	f96080e7          	jalr	-106(ra) # 5844 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    28b6:	85ca                	mv	a1,s2
    28b8:	00005517          	auipc	a0,0x5
    28bc:	92050513          	addi	a0,a0,-1760 # 71d8 <malloc+0x1526>
    28c0:	00003097          	auipc	ra,0x3
    28c4:	334080e7          	jalr	820(ra) # 5bf4 <printf>
    exit(1);
    28c8:	4505                	li	a0,1
    28ca:	00003097          	auipc	ra,0x3
    28ce:	f7a080e7          	jalr	-134(ra) # 5844 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    28d2:	85ca                	mv	a1,s2
    28d4:	00005517          	auipc	a0,0x5
    28d8:	93450513          	addi	a0,a0,-1740 # 7208 <malloc+0x1556>
    28dc:	00003097          	auipc	ra,0x3
    28e0:	318080e7          	jalr	792(ra) # 5bf4 <printf>
    exit(1);
    28e4:	4505                	li	a0,1
    28e6:	00003097          	auipc	ra,0x3
    28ea:	f5e080e7          	jalr	-162(ra) # 5844 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    28ee:	85ca                	mv	a1,s2
    28f0:	00005517          	auipc	a0,0x5
    28f4:	94050513          	addi	a0,a0,-1728 # 7230 <malloc+0x157e>
    28f8:	00003097          	auipc	ra,0x3
    28fc:	2fc080e7          	jalr	764(ra) # 5bf4 <printf>
    exit(1);
    2900:	4505                	li	a0,1
    2902:	00003097          	auipc	ra,0x3
    2906:	f42080e7          	jalr	-190(ra) # 5844 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    290a:	85ca                	mv	a1,s2
    290c:	00005517          	auipc	a0,0x5
    2910:	94c50513          	addi	a0,a0,-1716 # 7258 <malloc+0x15a6>
    2914:	00003097          	auipc	ra,0x3
    2918:	2e0080e7          	jalr	736(ra) # 5bf4 <printf>
    exit(1);
    291c:	4505                	li	a0,1
    291e:	00003097          	auipc	ra,0x3
    2922:	f26080e7          	jalr	-218(ra) # 5844 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    2926:	85ca                	mv	a1,s2
    2928:	00005517          	auipc	a0,0x5
    292c:	95850513          	addi	a0,a0,-1704 # 7280 <malloc+0x15ce>
    2930:	00003097          	auipc	ra,0x3
    2934:	2c4080e7          	jalr	708(ra) # 5bf4 <printf>
    exit(1);
    2938:	4505                	li	a0,1
    293a:	00003097          	auipc	ra,0x3
    293e:	f0a080e7          	jalr	-246(ra) # 5844 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    2942:	85ca                	mv	a1,s2
    2944:	00005517          	auipc	a0,0x5
    2948:	95c50513          	addi	a0,a0,-1700 # 72a0 <malloc+0x15ee>
    294c:	00003097          	auipc	ra,0x3
    2950:	2a8080e7          	jalr	680(ra) # 5bf4 <printf>
    exit(1);
    2954:	4505                	li	a0,1
    2956:	00003097          	auipc	ra,0x3
    295a:	eee080e7          	jalr	-274(ra) # 5844 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    295e:	85ca                	mv	a1,s2
    2960:	00005517          	auipc	a0,0x5
    2964:	96050513          	addi	a0,a0,-1696 # 72c0 <malloc+0x160e>
    2968:	00003097          	auipc	ra,0x3
    296c:	28c080e7          	jalr	652(ra) # 5bf4 <printf>
    exit(1);
    2970:	4505                	li	a0,1
    2972:	00003097          	auipc	ra,0x3
    2976:	ed2080e7          	jalr	-302(ra) # 5844 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    297a:	85ca                	mv	a1,s2
    297c:	00005517          	auipc	a0,0x5
    2980:	96c50513          	addi	a0,a0,-1684 # 72e8 <malloc+0x1636>
    2984:	00003097          	auipc	ra,0x3
    2988:	270080e7          	jalr	624(ra) # 5bf4 <printf>
    exit(1);
    298c:	4505                	li	a0,1
    298e:	00003097          	auipc	ra,0x3
    2992:	eb6080e7          	jalr	-330(ra) # 5844 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    2996:	85ca                	mv	a1,s2
    2998:	00005517          	auipc	a0,0x5
    299c:	97050513          	addi	a0,a0,-1680 # 7308 <malloc+0x1656>
    29a0:	00003097          	auipc	ra,0x3
    29a4:	254080e7          	jalr	596(ra) # 5bf4 <printf>
    exit(1);
    29a8:	4505                	li	a0,1
    29aa:	00003097          	auipc	ra,0x3
    29ae:	e9a080e7          	jalr	-358(ra) # 5844 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    29b2:	85ca                	mv	a1,s2
    29b4:	00005517          	auipc	a0,0x5
    29b8:	97450513          	addi	a0,a0,-1676 # 7328 <malloc+0x1676>
    29bc:	00003097          	auipc	ra,0x3
    29c0:	238080e7          	jalr	568(ra) # 5bf4 <printf>
    exit(1);
    29c4:	4505                	li	a0,1
    29c6:	00003097          	auipc	ra,0x3
    29ca:	e7e080e7          	jalr	-386(ra) # 5844 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    29ce:	85ca                	mv	a1,s2
    29d0:	00005517          	auipc	a0,0x5
    29d4:	98050513          	addi	a0,a0,-1664 # 7350 <malloc+0x169e>
    29d8:	00003097          	auipc	ra,0x3
    29dc:	21c080e7          	jalr	540(ra) # 5bf4 <printf>
    exit(1);
    29e0:	4505                	li	a0,1
    29e2:	00003097          	auipc	ra,0x3
    29e6:	e62080e7          	jalr	-414(ra) # 5844 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    29ea:	85ca                	mv	a1,s2
    29ec:	00004517          	auipc	a0,0x4
    29f0:	5fc50513          	addi	a0,a0,1532 # 6fe8 <malloc+0x1336>
    29f4:	00003097          	auipc	ra,0x3
    29f8:	200080e7          	jalr	512(ra) # 5bf4 <printf>
    exit(1);
    29fc:	4505                	li	a0,1
    29fe:	00003097          	auipc	ra,0x3
    2a02:	e46080e7          	jalr	-442(ra) # 5844 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    2a06:	85ca                	mv	a1,s2
    2a08:	00005517          	auipc	a0,0x5
    2a0c:	96850513          	addi	a0,a0,-1688 # 7370 <malloc+0x16be>
    2a10:	00003097          	auipc	ra,0x3
    2a14:	1e4080e7          	jalr	484(ra) # 5bf4 <printf>
    exit(1);
    2a18:	4505                	li	a0,1
    2a1a:	00003097          	auipc	ra,0x3
    2a1e:	e2a080e7          	jalr	-470(ra) # 5844 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    2a22:	85ca                	mv	a1,s2
    2a24:	00005517          	auipc	a0,0x5
    2a28:	96c50513          	addi	a0,a0,-1684 # 7390 <malloc+0x16de>
    2a2c:	00003097          	auipc	ra,0x3
    2a30:	1c8080e7          	jalr	456(ra) # 5bf4 <printf>
    exit(1);
    2a34:	4505                	li	a0,1
    2a36:	00003097          	auipc	ra,0x3
    2a3a:	e0e080e7          	jalr	-498(ra) # 5844 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    2a3e:	85ca                	mv	a1,s2
    2a40:	00005517          	auipc	a0,0x5
    2a44:	98050513          	addi	a0,a0,-1664 # 73c0 <malloc+0x170e>
    2a48:	00003097          	auipc	ra,0x3
    2a4c:	1ac080e7          	jalr	428(ra) # 5bf4 <printf>
    exit(1);
    2a50:	4505                	li	a0,1
    2a52:	00003097          	auipc	ra,0x3
    2a56:	df2080e7          	jalr	-526(ra) # 5844 <exit>
    printf("%s: unlink dd failed\n", s);
    2a5a:	85ca                	mv	a1,s2
    2a5c:	00005517          	auipc	a0,0x5
    2a60:	98450513          	addi	a0,a0,-1660 # 73e0 <malloc+0x172e>
    2a64:	00003097          	auipc	ra,0x3
    2a68:	190080e7          	jalr	400(ra) # 5bf4 <printf>
    exit(1);
    2a6c:	4505                	li	a0,1
    2a6e:	00003097          	auipc	ra,0x3
    2a72:	dd6080e7          	jalr	-554(ra) # 5844 <exit>

0000000000002a76 <rmdot>:
{
    2a76:	1101                	addi	sp,sp,-32
    2a78:	ec06                	sd	ra,24(sp)
    2a7a:	e822                	sd	s0,16(sp)
    2a7c:	e426                	sd	s1,8(sp)
    2a7e:	1000                	addi	s0,sp,32
    2a80:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    2a82:	00005517          	auipc	a0,0x5
    2a86:	97650513          	addi	a0,a0,-1674 # 73f8 <malloc+0x1746>
    2a8a:	00003097          	auipc	ra,0x3
    2a8e:	e22080e7          	jalr	-478(ra) # 58ac <mkdir>
    2a92:	e549                	bnez	a0,2b1c <rmdot+0xa6>
  if(chdir("dots") != 0){
    2a94:	00005517          	auipc	a0,0x5
    2a98:	96450513          	addi	a0,a0,-1692 # 73f8 <malloc+0x1746>
    2a9c:	00003097          	auipc	ra,0x3
    2aa0:	e18080e7          	jalr	-488(ra) # 58b4 <chdir>
    2aa4:	e951                	bnez	a0,2b38 <rmdot+0xc2>
  if(unlink(".") == 0){
    2aa6:	00004517          	auipc	a0,0x4
    2aaa:	c6250513          	addi	a0,a0,-926 # 6708 <malloc+0xa56>
    2aae:	00003097          	auipc	ra,0x3
    2ab2:	de6080e7          	jalr	-538(ra) # 5894 <unlink>
    2ab6:	cd59                	beqz	a0,2b54 <rmdot+0xde>
  if(unlink("..") == 0){
    2ab8:	00004517          	auipc	a0,0x4
    2abc:	39850513          	addi	a0,a0,920 # 6e50 <malloc+0x119e>
    2ac0:	00003097          	auipc	ra,0x3
    2ac4:	dd4080e7          	jalr	-556(ra) # 5894 <unlink>
    2ac8:	c545                	beqz	a0,2b70 <rmdot+0xfa>
  if(chdir("/") != 0){
    2aca:	00004517          	auipc	a0,0x4
    2ace:	32e50513          	addi	a0,a0,814 # 6df8 <malloc+0x1146>
    2ad2:	00003097          	auipc	ra,0x3
    2ad6:	de2080e7          	jalr	-542(ra) # 58b4 <chdir>
    2ada:	e94d                	bnez	a0,2b8c <rmdot+0x116>
  if(unlink("dots/.") == 0){
    2adc:	00005517          	auipc	a0,0x5
    2ae0:	98450513          	addi	a0,a0,-1660 # 7460 <malloc+0x17ae>
    2ae4:	00003097          	auipc	ra,0x3
    2ae8:	db0080e7          	jalr	-592(ra) # 5894 <unlink>
    2aec:	cd55                	beqz	a0,2ba8 <rmdot+0x132>
  if(unlink("dots/..") == 0){
    2aee:	00005517          	auipc	a0,0x5
    2af2:	99a50513          	addi	a0,a0,-1638 # 7488 <malloc+0x17d6>
    2af6:	00003097          	auipc	ra,0x3
    2afa:	d9e080e7          	jalr	-610(ra) # 5894 <unlink>
    2afe:	c179                	beqz	a0,2bc4 <rmdot+0x14e>
  if(unlink("dots") != 0){
    2b00:	00005517          	auipc	a0,0x5
    2b04:	8f850513          	addi	a0,a0,-1800 # 73f8 <malloc+0x1746>
    2b08:	00003097          	auipc	ra,0x3
    2b0c:	d8c080e7          	jalr	-628(ra) # 5894 <unlink>
    2b10:	e961                	bnez	a0,2be0 <rmdot+0x16a>
}
    2b12:	60e2                	ld	ra,24(sp)
    2b14:	6442                	ld	s0,16(sp)
    2b16:	64a2                	ld	s1,8(sp)
    2b18:	6105                	addi	sp,sp,32
    2b1a:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    2b1c:	85a6                	mv	a1,s1
    2b1e:	00005517          	auipc	a0,0x5
    2b22:	8e250513          	addi	a0,a0,-1822 # 7400 <malloc+0x174e>
    2b26:	00003097          	auipc	ra,0x3
    2b2a:	0ce080e7          	jalr	206(ra) # 5bf4 <printf>
    exit(1);
    2b2e:	4505                	li	a0,1
    2b30:	00003097          	auipc	ra,0x3
    2b34:	d14080e7          	jalr	-748(ra) # 5844 <exit>
    printf("%s: chdir dots failed\n", s);
    2b38:	85a6                	mv	a1,s1
    2b3a:	00005517          	auipc	a0,0x5
    2b3e:	8de50513          	addi	a0,a0,-1826 # 7418 <malloc+0x1766>
    2b42:	00003097          	auipc	ra,0x3
    2b46:	0b2080e7          	jalr	178(ra) # 5bf4 <printf>
    exit(1);
    2b4a:	4505                	li	a0,1
    2b4c:	00003097          	auipc	ra,0x3
    2b50:	cf8080e7          	jalr	-776(ra) # 5844 <exit>
    printf("%s: rm . worked!\n", s);
    2b54:	85a6                	mv	a1,s1
    2b56:	00005517          	auipc	a0,0x5
    2b5a:	8da50513          	addi	a0,a0,-1830 # 7430 <malloc+0x177e>
    2b5e:	00003097          	auipc	ra,0x3
    2b62:	096080e7          	jalr	150(ra) # 5bf4 <printf>
    exit(1);
    2b66:	4505                	li	a0,1
    2b68:	00003097          	auipc	ra,0x3
    2b6c:	cdc080e7          	jalr	-804(ra) # 5844 <exit>
    printf("%s: rm .. worked!\n", s);
    2b70:	85a6                	mv	a1,s1
    2b72:	00005517          	auipc	a0,0x5
    2b76:	8d650513          	addi	a0,a0,-1834 # 7448 <malloc+0x1796>
    2b7a:	00003097          	auipc	ra,0x3
    2b7e:	07a080e7          	jalr	122(ra) # 5bf4 <printf>
    exit(1);
    2b82:	4505                	li	a0,1
    2b84:	00003097          	auipc	ra,0x3
    2b88:	cc0080e7          	jalr	-832(ra) # 5844 <exit>
    printf("%s: chdir / failed\n", s);
    2b8c:	85a6                	mv	a1,s1
    2b8e:	00004517          	auipc	a0,0x4
    2b92:	27250513          	addi	a0,a0,626 # 6e00 <malloc+0x114e>
    2b96:	00003097          	auipc	ra,0x3
    2b9a:	05e080e7          	jalr	94(ra) # 5bf4 <printf>
    exit(1);
    2b9e:	4505                	li	a0,1
    2ba0:	00003097          	auipc	ra,0x3
    2ba4:	ca4080e7          	jalr	-860(ra) # 5844 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    2ba8:	85a6                	mv	a1,s1
    2baa:	00005517          	auipc	a0,0x5
    2bae:	8be50513          	addi	a0,a0,-1858 # 7468 <malloc+0x17b6>
    2bb2:	00003097          	auipc	ra,0x3
    2bb6:	042080e7          	jalr	66(ra) # 5bf4 <printf>
    exit(1);
    2bba:	4505                	li	a0,1
    2bbc:	00003097          	auipc	ra,0x3
    2bc0:	c88080e7          	jalr	-888(ra) # 5844 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    2bc4:	85a6                	mv	a1,s1
    2bc6:	00005517          	auipc	a0,0x5
    2bca:	8ca50513          	addi	a0,a0,-1846 # 7490 <malloc+0x17de>
    2bce:	00003097          	auipc	ra,0x3
    2bd2:	026080e7          	jalr	38(ra) # 5bf4 <printf>
    exit(1);
    2bd6:	4505                	li	a0,1
    2bd8:	00003097          	auipc	ra,0x3
    2bdc:	c6c080e7          	jalr	-916(ra) # 5844 <exit>
    printf("%s: unlink dots failed!\n", s);
    2be0:	85a6                	mv	a1,s1
    2be2:	00005517          	auipc	a0,0x5
    2be6:	8ce50513          	addi	a0,a0,-1842 # 74b0 <malloc+0x17fe>
    2bea:	00003097          	auipc	ra,0x3
    2bee:	00a080e7          	jalr	10(ra) # 5bf4 <printf>
    exit(1);
    2bf2:	4505                	li	a0,1
    2bf4:	00003097          	auipc	ra,0x3
    2bf8:	c50080e7          	jalr	-944(ra) # 5844 <exit>

0000000000002bfc <dirfile>:
{
    2bfc:	1101                	addi	sp,sp,-32
    2bfe:	ec06                	sd	ra,24(sp)
    2c00:	e822                	sd	s0,16(sp)
    2c02:	e426                	sd	s1,8(sp)
    2c04:	e04a                	sd	s2,0(sp)
    2c06:	1000                	addi	s0,sp,32
    2c08:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    2c0a:	20000593          	li	a1,512
    2c0e:	00003517          	auipc	a0,0x3
    2c12:	38a50513          	addi	a0,a0,906 # 5f98 <malloc+0x2e6>
    2c16:	00003097          	auipc	ra,0x3
    2c1a:	c6e080e7          	jalr	-914(ra) # 5884 <open>
  if(fd < 0){
    2c1e:	0e054d63          	bltz	a0,2d18 <dirfile+0x11c>
  close(fd);
    2c22:	00003097          	auipc	ra,0x3
    2c26:	c4a080e7          	jalr	-950(ra) # 586c <close>
  if(chdir("dirfile") == 0){
    2c2a:	00003517          	auipc	a0,0x3
    2c2e:	36e50513          	addi	a0,a0,878 # 5f98 <malloc+0x2e6>
    2c32:	00003097          	auipc	ra,0x3
    2c36:	c82080e7          	jalr	-894(ra) # 58b4 <chdir>
    2c3a:	cd6d                	beqz	a0,2d34 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    2c3c:	4581                	li	a1,0
    2c3e:	00005517          	auipc	a0,0x5
    2c42:	8d250513          	addi	a0,a0,-1838 # 7510 <malloc+0x185e>
    2c46:	00003097          	auipc	ra,0x3
    2c4a:	c3e080e7          	jalr	-962(ra) # 5884 <open>
  if(fd >= 0){
    2c4e:	10055163          	bgez	a0,2d50 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    2c52:	20000593          	li	a1,512
    2c56:	00005517          	auipc	a0,0x5
    2c5a:	8ba50513          	addi	a0,a0,-1862 # 7510 <malloc+0x185e>
    2c5e:	00003097          	auipc	ra,0x3
    2c62:	c26080e7          	jalr	-986(ra) # 5884 <open>
  if(fd >= 0){
    2c66:	10055363          	bgez	a0,2d6c <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    2c6a:	00005517          	auipc	a0,0x5
    2c6e:	8a650513          	addi	a0,a0,-1882 # 7510 <malloc+0x185e>
    2c72:	00003097          	auipc	ra,0x3
    2c76:	c3a080e7          	jalr	-966(ra) # 58ac <mkdir>
    2c7a:	10050763          	beqz	a0,2d88 <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    2c7e:	00005517          	auipc	a0,0x5
    2c82:	89250513          	addi	a0,a0,-1902 # 7510 <malloc+0x185e>
    2c86:	00003097          	auipc	ra,0x3
    2c8a:	c0e080e7          	jalr	-1010(ra) # 5894 <unlink>
    2c8e:	10050b63          	beqz	a0,2da4 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    2c92:	00005597          	auipc	a1,0x5
    2c96:	87e58593          	addi	a1,a1,-1922 # 7510 <malloc+0x185e>
    2c9a:	00003517          	auipc	a0,0x3
    2c9e:	67e50513          	addi	a0,a0,1662 # 6318 <malloc+0x666>
    2ca2:	00003097          	auipc	ra,0x3
    2ca6:	c02080e7          	jalr	-1022(ra) # 58a4 <link>
    2caa:	10050b63          	beqz	a0,2dc0 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    2cae:	00003517          	auipc	a0,0x3
    2cb2:	2ea50513          	addi	a0,a0,746 # 5f98 <malloc+0x2e6>
    2cb6:	00003097          	auipc	ra,0x3
    2cba:	bde080e7          	jalr	-1058(ra) # 5894 <unlink>
    2cbe:	10051f63          	bnez	a0,2ddc <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    2cc2:	4589                	li	a1,2
    2cc4:	00004517          	auipc	a0,0x4
    2cc8:	a4450513          	addi	a0,a0,-1468 # 6708 <malloc+0xa56>
    2ccc:	00003097          	auipc	ra,0x3
    2cd0:	bb8080e7          	jalr	-1096(ra) # 5884 <open>
  if(fd >= 0){
    2cd4:	12055263          	bgez	a0,2df8 <dirfile+0x1fc>
  fd = open(".", 0);
    2cd8:	4581                	li	a1,0
    2cda:	00004517          	auipc	a0,0x4
    2cde:	a2e50513          	addi	a0,a0,-1490 # 6708 <malloc+0xa56>
    2ce2:	00003097          	auipc	ra,0x3
    2ce6:	ba2080e7          	jalr	-1118(ra) # 5884 <open>
    2cea:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    2cec:	4605                	li	a2,1
    2cee:	00003597          	auipc	a1,0x3
    2cf2:	4f258593          	addi	a1,a1,1266 # 61e0 <malloc+0x52e>
    2cf6:	00003097          	auipc	ra,0x3
    2cfa:	b6e080e7          	jalr	-1170(ra) # 5864 <write>
    2cfe:	10a04b63          	bgtz	a0,2e14 <dirfile+0x218>
  close(fd);
    2d02:	8526                	mv	a0,s1
    2d04:	00003097          	auipc	ra,0x3
    2d08:	b68080e7          	jalr	-1176(ra) # 586c <close>
}
    2d0c:	60e2                	ld	ra,24(sp)
    2d0e:	6442                	ld	s0,16(sp)
    2d10:	64a2                	ld	s1,8(sp)
    2d12:	6902                	ld	s2,0(sp)
    2d14:	6105                	addi	sp,sp,32
    2d16:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    2d18:	85ca                	mv	a1,s2
    2d1a:	00004517          	auipc	a0,0x4
    2d1e:	7b650513          	addi	a0,a0,1974 # 74d0 <malloc+0x181e>
    2d22:	00003097          	auipc	ra,0x3
    2d26:	ed2080e7          	jalr	-302(ra) # 5bf4 <printf>
    exit(1);
    2d2a:	4505                	li	a0,1
    2d2c:	00003097          	auipc	ra,0x3
    2d30:	b18080e7          	jalr	-1256(ra) # 5844 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    2d34:	85ca                	mv	a1,s2
    2d36:	00004517          	auipc	a0,0x4
    2d3a:	7ba50513          	addi	a0,a0,1978 # 74f0 <malloc+0x183e>
    2d3e:	00003097          	auipc	ra,0x3
    2d42:	eb6080e7          	jalr	-330(ra) # 5bf4 <printf>
    exit(1);
    2d46:	4505                	li	a0,1
    2d48:	00003097          	auipc	ra,0x3
    2d4c:	afc080e7          	jalr	-1284(ra) # 5844 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    2d50:	85ca                	mv	a1,s2
    2d52:	00004517          	auipc	a0,0x4
    2d56:	7ce50513          	addi	a0,a0,1998 # 7520 <malloc+0x186e>
    2d5a:	00003097          	auipc	ra,0x3
    2d5e:	e9a080e7          	jalr	-358(ra) # 5bf4 <printf>
    exit(1);
    2d62:	4505                	li	a0,1
    2d64:	00003097          	auipc	ra,0x3
    2d68:	ae0080e7          	jalr	-1312(ra) # 5844 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    2d6c:	85ca                	mv	a1,s2
    2d6e:	00004517          	auipc	a0,0x4
    2d72:	7b250513          	addi	a0,a0,1970 # 7520 <malloc+0x186e>
    2d76:	00003097          	auipc	ra,0x3
    2d7a:	e7e080e7          	jalr	-386(ra) # 5bf4 <printf>
    exit(1);
    2d7e:	4505                	li	a0,1
    2d80:	00003097          	auipc	ra,0x3
    2d84:	ac4080e7          	jalr	-1340(ra) # 5844 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    2d88:	85ca                	mv	a1,s2
    2d8a:	00004517          	auipc	a0,0x4
    2d8e:	7be50513          	addi	a0,a0,1982 # 7548 <malloc+0x1896>
    2d92:	00003097          	auipc	ra,0x3
    2d96:	e62080e7          	jalr	-414(ra) # 5bf4 <printf>
    exit(1);
    2d9a:	4505                	li	a0,1
    2d9c:	00003097          	auipc	ra,0x3
    2da0:	aa8080e7          	jalr	-1368(ra) # 5844 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    2da4:	85ca                	mv	a1,s2
    2da6:	00004517          	auipc	a0,0x4
    2daa:	7ca50513          	addi	a0,a0,1994 # 7570 <malloc+0x18be>
    2dae:	00003097          	auipc	ra,0x3
    2db2:	e46080e7          	jalr	-442(ra) # 5bf4 <printf>
    exit(1);
    2db6:	4505                	li	a0,1
    2db8:	00003097          	auipc	ra,0x3
    2dbc:	a8c080e7          	jalr	-1396(ra) # 5844 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    2dc0:	85ca                	mv	a1,s2
    2dc2:	00004517          	auipc	a0,0x4
    2dc6:	7d650513          	addi	a0,a0,2006 # 7598 <malloc+0x18e6>
    2dca:	00003097          	auipc	ra,0x3
    2dce:	e2a080e7          	jalr	-470(ra) # 5bf4 <printf>
    exit(1);
    2dd2:	4505                	li	a0,1
    2dd4:	00003097          	auipc	ra,0x3
    2dd8:	a70080e7          	jalr	-1424(ra) # 5844 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    2ddc:	85ca                	mv	a1,s2
    2dde:	00004517          	auipc	a0,0x4
    2de2:	7e250513          	addi	a0,a0,2018 # 75c0 <malloc+0x190e>
    2de6:	00003097          	auipc	ra,0x3
    2dea:	e0e080e7          	jalr	-498(ra) # 5bf4 <printf>
    exit(1);
    2dee:	4505                	li	a0,1
    2df0:	00003097          	auipc	ra,0x3
    2df4:	a54080e7          	jalr	-1452(ra) # 5844 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    2df8:	85ca                	mv	a1,s2
    2dfa:	00004517          	auipc	a0,0x4
    2dfe:	7e650513          	addi	a0,a0,2022 # 75e0 <malloc+0x192e>
    2e02:	00003097          	auipc	ra,0x3
    2e06:	df2080e7          	jalr	-526(ra) # 5bf4 <printf>
    exit(1);
    2e0a:	4505                	li	a0,1
    2e0c:	00003097          	auipc	ra,0x3
    2e10:	a38080e7          	jalr	-1480(ra) # 5844 <exit>
    printf("%s: write . succeeded!\n", s);
    2e14:	85ca                	mv	a1,s2
    2e16:	00004517          	auipc	a0,0x4
    2e1a:	7f250513          	addi	a0,a0,2034 # 7608 <malloc+0x1956>
    2e1e:	00003097          	auipc	ra,0x3
    2e22:	dd6080e7          	jalr	-554(ra) # 5bf4 <printf>
    exit(1);
    2e26:	4505                	li	a0,1
    2e28:	00003097          	auipc	ra,0x3
    2e2c:	a1c080e7          	jalr	-1508(ra) # 5844 <exit>

0000000000002e30 <reparent>:
{
    2e30:	7179                	addi	sp,sp,-48
    2e32:	f406                	sd	ra,40(sp)
    2e34:	f022                	sd	s0,32(sp)
    2e36:	ec26                	sd	s1,24(sp)
    2e38:	e84a                	sd	s2,16(sp)
    2e3a:	e44e                	sd	s3,8(sp)
    2e3c:	e052                	sd	s4,0(sp)
    2e3e:	1800                	addi	s0,sp,48
    2e40:	89aa                	mv	s3,a0
  int master_pid = getpid();
    2e42:	00003097          	auipc	ra,0x3
    2e46:	a82080e7          	jalr	-1406(ra) # 58c4 <getpid>
    2e4a:	8a2a                	mv	s4,a0
    2e4c:	0c800913          	li	s2,200
    int pid = fork();
    2e50:	00003097          	auipc	ra,0x3
    2e54:	9ec080e7          	jalr	-1556(ra) # 583c <fork>
    2e58:	84aa                	mv	s1,a0
    if(pid < 0){
    2e5a:	02054263          	bltz	a0,2e7e <reparent+0x4e>
    if(pid){
    2e5e:	cd21                	beqz	a0,2eb6 <reparent+0x86>
      if(wait(0) != pid){
    2e60:	4501                	li	a0,0
    2e62:	00003097          	auipc	ra,0x3
    2e66:	9ea080e7          	jalr	-1558(ra) # 584c <wait>
    2e6a:	02951863          	bne	a0,s1,2e9a <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    2e6e:	397d                	addiw	s2,s2,-1
    2e70:	fe0910e3          	bnez	s2,2e50 <reparent+0x20>
  exit(0);
    2e74:	4501                	li	a0,0
    2e76:	00003097          	auipc	ra,0x3
    2e7a:	9ce080e7          	jalr	-1586(ra) # 5844 <exit>
      printf("%s: fork failed\n", s);
    2e7e:	85ce                	mv	a1,s3
    2e80:	00003517          	auipc	a0,0x3
    2e84:	17850513          	addi	a0,a0,376 # 5ff8 <malloc+0x346>
    2e88:	00003097          	auipc	ra,0x3
    2e8c:	d6c080e7          	jalr	-660(ra) # 5bf4 <printf>
      exit(1);
    2e90:	4505                	li	a0,1
    2e92:	00003097          	auipc	ra,0x3
    2e96:	9b2080e7          	jalr	-1614(ra) # 5844 <exit>
        printf("%s: wait wrong pid\n", s);
    2e9a:	85ce                	mv	a1,s3
    2e9c:	00003517          	auipc	a0,0x3
    2ea0:	17450513          	addi	a0,a0,372 # 6010 <malloc+0x35e>
    2ea4:	00003097          	auipc	ra,0x3
    2ea8:	d50080e7          	jalr	-688(ra) # 5bf4 <printf>
        exit(1);
    2eac:	4505                	li	a0,1
    2eae:	00003097          	auipc	ra,0x3
    2eb2:	996080e7          	jalr	-1642(ra) # 5844 <exit>
      int pid2 = fork();
    2eb6:	00003097          	auipc	ra,0x3
    2eba:	986080e7          	jalr	-1658(ra) # 583c <fork>
      if(pid2 < 0){
    2ebe:	00054763          	bltz	a0,2ecc <reparent+0x9c>
      exit(0);
    2ec2:	4501                	li	a0,0
    2ec4:	00003097          	auipc	ra,0x3
    2ec8:	980080e7          	jalr	-1664(ra) # 5844 <exit>
        kill(master_pid, SIGKILL);
    2ecc:	45a5                	li	a1,9
    2ece:	8552                	mv	a0,s4
    2ed0:	00003097          	auipc	ra,0x3
    2ed4:	9a4080e7          	jalr	-1628(ra) # 5874 <kill>
        exit(1);
    2ed8:	4505                	li	a0,1
    2eda:	00003097          	auipc	ra,0x3
    2ede:	96a080e7          	jalr	-1686(ra) # 5844 <exit>

0000000000002ee2 <fourfiles>:
{
    2ee2:	7171                	addi	sp,sp,-176
    2ee4:	f506                	sd	ra,168(sp)
    2ee6:	f122                	sd	s0,160(sp)
    2ee8:	ed26                	sd	s1,152(sp)
    2eea:	e94a                	sd	s2,144(sp)
    2eec:	e54e                	sd	s3,136(sp)
    2eee:	e152                	sd	s4,128(sp)
    2ef0:	fcd6                	sd	s5,120(sp)
    2ef2:	f8da                	sd	s6,112(sp)
    2ef4:	f4de                	sd	s7,104(sp)
    2ef6:	f0e2                	sd	s8,96(sp)
    2ef8:	ece6                	sd	s9,88(sp)
    2efa:	e8ea                	sd	s10,80(sp)
    2efc:	e4ee                	sd	s11,72(sp)
    2efe:	1900                	addi	s0,sp,176
    2f00:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    2f04:	00003797          	auipc	a5,0x3
    2f08:	e9478793          	addi	a5,a5,-364 # 5d98 <malloc+0xe6>
    2f0c:	f6f43823          	sd	a5,-144(s0)
    2f10:	00003797          	auipc	a5,0x3
    2f14:	e9078793          	addi	a5,a5,-368 # 5da0 <malloc+0xee>
    2f18:	f6f43c23          	sd	a5,-136(s0)
    2f1c:	00003797          	auipc	a5,0x3
    2f20:	e8c78793          	addi	a5,a5,-372 # 5da8 <malloc+0xf6>
    2f24:	f8f43023          	sd	a5,-128(s0)
    2f28:	00003797          	auipc	a5,0x3
    2f2c:	e8878793          	addi	a5,a5,-376 # 5db0 <malloc+0xfe>
    2f30:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    2f34:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    2f38:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    2f3a:	4481                	li	s1,0
    2f3c:	4a11                	li	s4,4
    fname = names[pi];
    2f3e:	00093983          	ld	s3,0(s2)
    unlink(fname);
    2f42:	854e                	mv	a0,s3
    2f44:	00003097          	auipc	ra,0x3
    2f48:	950080e7          	jalr	-1712(ra) # 5894 <unlink>
    pid = fork();
    2f4c:	00003097          	auipc	ra,0x3
    2f50:	8f0080e7          	jalr	-1808(ra) # 583c <fork>
    if(pid < 0){
    2f54:	04054463          	bltz	a0,2f9c <fourfiles+0xba>
    if(pid == 0){
    2f58:	c12d                	beqz	a0,2fba <fourfiles+0xd8>
  for(pi = 0; pi < NCHILD; pi++){
    2f5a:	2485                	addiw	s1,s1,1
    2f5c:	0921                	addi	s2,s2,8
    2f5e:	ff4490e3          	bne	s1,s4,2f3e <fourfiles+0x5c>
    2f62:	4491                	li	s1,4
    wait(&xstatus);
    2f64:	f6c40513          	addi	a0,s0,-148
    2f68:	00003097          	auipc	ra,0x3
    2f6c:	8e4080e7          	jalr	-1820(ra) # 584c <wait>
    if(xstatus != 0)
    2f70:	f6c42b03          	lw	s6,-148(s0)
    2f74:	0c0b1e63          	bnez	s6,3050 <fourfiles+0x16e>
  for(pi = 0; pi < NCHILD; pi++){
    2f78:	34fd                	addiw	s1,s1,-1
    2f7a:	f4ed                	bnez	s1,2f64 <fourfiles+0x82>
    2f7c:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    2f80:	00009a17          	auipc	s4,0x9
    2f84:	c40a0a13          	addi	s4,s4,-960 # bbc0 <buf>
    2f88:	00009a97          	auipc	s5,0x9
    2f8c:	c39a8a93          	addi	s5,s5,-967 # bbc1 <buf+0x1>
    if(total != N*SZ){
    2f90:	6d85                	lui	s11,0x1
    2f92:	770d8d93          	addi	s11,s11,1904 # 1770 <exectest+0x13a>
  for(i = 0; i < NCHILD; i++){
    2f96:	03400d13          	li	s10,52
    2f9a:	aa1d                	j	30d0 <fourfiles+0x1ee>
      printf("fork failed\n", s);
    2f9c:	f5843583          	ld	a1,-168(s0)
    2fa0:	00004517          	auipc	a0,0x4
    2fa4:	a5050513          	addi	a0,a0,-1456 # 69f0 <malloc+0xd3e>
    2fa8:	00003097          	auipc	ra,0x3
    2fac:	c4c080e7          	jalr	-948(ra) # 5bf4 <printf>
      exit(1);
    2fb0:	4505                	li	a0,1
    2fb2:	00003097          	auipc	ra,0x3
    2fb6:	892080e7          	jalr	-1902(ra) # 5844 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    2fba:	20200593          	li	a1,514
    2fbe:	854e                	mv	a0,s3
    2fc0:	00003097          	auipc	ra,0x3
    2fc4:	8c4080e7          	jalr	-1852(ra) # 5884 <open>
    2fc8:	892a                	mv	s2,a0
      if(fd < 0){
    2fca:	04054763          	bltz	a0,3018 <fourfiles+0x136>
      memset(buf, '0'+pi, SZ);
    2fce:	1f400613          	li	a2,500
    2fd2:	0304859b          	addiw	a1,s1,48
    2fd6:	00009517          	auipc	a0,0x9
    2fda:	bea50513          	addi	a0,a0,-1046 # bbc0 <buf>
    2fde:	00002097          	auipc	ra,0x2
    2fe2:	66a080e7          	jalr	1642(ra) # 5648 <memset>
    2fe6:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    2fe8:	00009997          	auipc	s3,0x9
    2fec:	bd898993          	addi	s3,s3,-1064 # bbc0 <buf>
    2ff0:	1f400613          	li	a2,500
    2ff4:	85ce                	mv	a1,s3
    2ff6:	854a                	mv	a0,s2
    2ff8:	00003097          	auipc	ra,0x3
    2ffc:	86c080e7          	jalr	-1940(ra) # 5864 <write>
    3000:	85aa                	mv	a1,a0
    3002:	1f400793          	li	a5,500
    3006:	02f51863          	bne	a0,a5,3036 <fourfiles+0x154>
      for(i = 0; i < N; i++){
    300a:	34fd                	addiw	s1,s1,-1
    300c:	f0f5                	bnez	s1,2ff0 <fourfiles+0x10e>
      exit(0);
    300e:	4501                	li	a0,0
    3010:	00003097          	auipc	ra,0x3
    3014:	834080e7          	jalr	-1996(ra) # 5844 <exit>
        printf("create failed\n", s);
    3018:	f5843583          	ld	a1,-168(s0)
    301c:	00004517          	auipc	a0,0x4
    3020:	60450513          	addi	a0,a0,1540 # 7620 <malloc+0x196e>
    3024:	00003097          	auipc	ra,0x3
    3028:	bd0080e7          	jalr	-1072(ra) # 5bf4 <printf>
        exit(1);
    302c:	4505                	li	a0,1
    302e:	00003097          	auipc	ra,0x3
    3032:	816080e7          	jalr	-2026(ra) # 5844 <exit>
          printf("write failed %d\n", n);
    3036:	00004517          	auipc	a0,0x4
    303a:	5fa50513          	addi	a0,a0,1530 # 7630 <malloc+0x197e>
    303e:	00003097          	auipc	ra,0x3
    3042:	bb6080e7          	jalr	-1098(ra) # 5bf4 <printf>
          exit(1);
    3046:	4505                	li	a0,1
    3048:	00002097          	auipc	ra,0x2
    304c:	7fc080e7          	jalr	2044(ra) # 5844 <exit>
      exit(xstatus);
    3050:	855a                	mv	a0,s6
    3052:	00002097          	auipc	ra,0x2
    3056:	7f2080e7          	jalr	2034(ra) # 5844 <exit>
          printf("wrong char\n", s);
    305a:	f5843583          	ld	a1,-168(s0)
    305e:	00004517          	auipc	a0,0x4
    3062:	5ea50513          	addi	a0,a0,1514 # 7648 <malloc+0x1996>
    3066:	00003097          	auipc	ra,0x3
    306a:	b8e080e7          	jalr	-1138(ra) # 5bf4 <printf>
          exit(1);
    306e:	4505                	li	a0,1
    3070:	00002097          	auipc	ra,0x2
    3074:	7d4080e7          	jalr	2004(ra) # 5844 <exit>
      total += n;
    3078:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    307c:	660d                	lui	a2,0x3
    307e:	85d2                	mv	a1,s4
    3080:	854e                	mv	a0,s3
    3082:	00002097          	auipc	ra,0x2
    3086:	7da080e7          	jalr	2010(ra) # 585c <read>
    308a:	02a05363          	blez	a0,30b0 <fourfiles+0x1ce>
    308e:	00009797          	auipc	a5,0x9
    3092:	b3278793          	addi	a5,a5,-1230 # bbc0 <buf>
    3096:	fff5069b          	addiw	a3,a0,-1
    309a:	1682                	slli	a3,a3,0x20
    309c:	9281                	srli	a3,a3,0x20
    309e:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    30a0:	0007c703          	lbu	a4,0(a5)
    30a4:	fa971be3          	bne	a4,s1,305a <fourfiles+0x178>
      for(j = 0; j < n; j++){
    30a8:	0785                	addi	a5,a5,1
    30aa:	fed79be3          	bne	a5,a3,30a0 <fourfiles+0x1be>
    30ae:	b7e9                	j	3078 <fourfiles+0x196>
    close(fd);
    30b0:	854e                	mv	a0,s3
    30b2:	00002097          	auipc	ra,0x2
    30b6:	7ba080e7          	jalr	1978(ra) # 586c <close>
    if(total != N*SZ){
    30ba:	03b91863          	bne	s2,s11,30ea <fourfiles+0x208>
    unlink(fname);
    30be:	8566                	mv	a0,s9
    30c0:	00002097          	auipc	ra,0x2
    30c4:	7d4080e7          	jalr	2004(ra) # 5894 <unlink>
  for(i = 0; i < NCHILD; i++){
    30c8:	0c21                	addi	s8,s8,8
    30ca:	2b85                	addiw	s7,s7,1
    30cc:	03ab8d63          	beq	s7,s10,3106 <fourfiles+0x224>
    fname = names[i];
    30d0:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    30d4:	4581                	li	a1,0
    30d6:	8566                	mv	a0,s9
    30d8:	00002097          	auipc	ra,0x2
    30dc:	7ac080e7          	jalr	1964(ra) # 5884 <open>
    30e0:	89aa                	mv	s3,a0
    total = 0;
    30e2:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    30e4:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    30e8:	bf51                	j	307c <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    30ea:	85ca                	mv	a1,s2
    30ec:	00004517          	auipc	a0,0x4
    30f0:	56c50513          	addi	a0,a0,1388 # 7658 <malloc+0x19a6>
    30f4:	00003097          	auipc	ra,0x3
    30f8:	b00080e7          	jalr	-1280(ra) # 5bf4 <printf>
      exit(1);
    30fc:	4505                	li	a0,1
    30fe:	00002097          	auipc	ra,0x2
    3102:	746080e7          	jalr	1862(ra) # 5844 <exit>
}
    3106:	70aa                	ld	ra,168(sp)
    3108:	740a                	ld	s0,160(sp)
    310a:	64ea                	ld	s1,152(sp)
    310c:	694a                	ld	s2,144(sp)
    310e:	69aa                	ld	s3,136(sp)
    3110:	6a0a                	ld	s4,128(sp)
    3112:	7ae6                	ld	s5,120(sp)
    3114:	7b46                	ld	s6,112(sp)
    3116:	7ba6                	ld	s7,104(sp)
    3118:	7c06                	ld	s8,96(sp)
    311a:	6ce6                	ld	s9,88(sp)
    311c:	6d46                	ld	s10,80(sp)
    311e:	6da6                	ld	s11,72(sp)
    3120:	614d                	addi	sp,sp,176
    3122:	8082                	ret

0000000000003124 <bigfile>:
{
    3124:	7139                	addi	sp,sp,-64
    3126:	fc06                	sd	ra,56(sp)
    3128:	f822                	sd	s0,48(sp)
    312a:	f426                	sd	s1,40(sp)
    312c:	f04a                	sd	s2,32(sp)
    312e:	ec4e                	sd	s3,24(sp)
    3130:	e852                	sd	s4,16(sp)
    3132:	e456                	sd	s5,8(sp)
    3134:	0080                	addi	s0,sp,64
    3136:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    3138:	00004517          	auipc	a0,0x4
    313c:	53850513          	addi	a0,a0,1336 # 7670 <malloc+0x19be>
    3140:	00002097          	auipc	ra,0x2
    3144:	754080e7          	jalr	1876(ra) # 5894 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    3148:	20200593          	li	a1,514
    314c:	00004517          	auipc	a0,0x4
    3150:	52450513          	addi	a0,a0,1316 # 7670 <malloc+0x19be>
    3154:	00002097          	auipc	ra,0x2
    3158:	730080e7          	jalr	1840(ra) # 5884 <open>
    315c:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    315e:	4481                	li	s1,0
    memset(buf, i, SZ);
    3160:	00009917          	auipc	s2,0x9
    3164:	a6090913          	addi	s2,s2,-1440 # bbc0 <buf>
  for(i = 0; i < N; i++){
    3168:	4a51                	li	s4,20
  if(fd < 0){
    316a:	0a054063          	bltz	a0,320a <bigfile+0xe6>
    memset(buf, i, SZ);
    316e:	25800613          	li	a2,600
    3172:	85a6                	mv	a1,s1
    3174:	854a                	mv	a0,s2
    3176:	00002097          	auipc	ra,0x2
    317a:	4d2080e7          	jalr	1234(ra) # 5648 <memset>
    if(write(fd, buf, SZ) != SZ){
    317e:	25800613          	li	a2,600
    3182:	85ca                	mv	a1,s2
    3184:	854e                	mv	a0,s3
    3186:	00002097          	auipc	ra,0x2
    318a:	6de080e7          	jalr	1758(ra) # 5864 <write>
    318e:	25800793          	li	a5,600
    3192:	08f51a63          	bne	a0,a5,3226 <bigfile+0x102>
  for(i = 0; i < N; i++){
    3196:	2485                	addiw	s1,s1,1
    3198:	fd449be3          	bne	s1,s4,316e <bigfile+0x4a>
  close(fd);
    319c:	854e                	mv	a0,s3
    319e:	00002097          	auipc	ra,0x2
    31a2:	6ce080e7          	jalr	1742(ra) # 586c <close>
  fd = open("bigfile.dat", 0);
    31a6:	4581                	li	a1,0
    31a8:	00004517          	auipc	a0,0x4
    31ac:	4c850513          	addi	a0,a0,1224 # 7670 <malloc+0x19be>
    31b0:	00002097          	auipc	ra,0x2
    31b4:	6d4080e7          	jalr	1748(ra) # 5884 <open>
    31b8:	8a2a                	mv	s4,a0
  total = 0;
    31ba:	4981                	li	s3,0
  for(i = 0; ; i++){
    31bc:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    31be:	00009917          	auipc	s2,0x9
    31c2:	a0290913          	addi	s2,s2,-1534 # bbc0 <buf>
  if(fd < 0){
    31c6:	06054e63          	bltz	a0,3242 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    31ca:	12c00613          	li	a2,300
    31ce:	85ca                	mv	a1,s2
    31d0:	8552                	mv	a0,s4
    31d2:	00002097          	auipc	ra,0x2
    31d6:	68a080e7          	jalr	1674(ra) # 585c <read>
    if(cc < 0){
    31da:	08054263          	bltz	a0,325e <bigfile+0x13a>
    if(cc == 0)
    31de:	c971                	beqz	a0,32b2 <bigfile+0x18e>
    if(cc != SZ/2){
    31e0:	12c00793          	li	a5,300
    31e4:	08f51b63          	bne	a0,a5,327a <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    31e8:	01f4d79b          	srliw	a5,s1,0x1f
    31ec:	9fa5                	addw	a5,a5,s1
    31ee:	4017d79b          	sraiw	a5,a5,0x1
    31f2:	00094703          	lbu	a4,0(s2)
    31f6:	0af71063          	bne	a4,a5,3296 <bigfile+0x172>
    31fa:	12b94703          	lbu	a4,299(s2)
    31fe:	08f71c63          	bne	a4,a5,3296 <bigfile+0x172>
    total += cc;
    3202:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    3206:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    3208:	b7c9                	j	31ca <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    320a:	85d6                	mv	a1,s5
    320c:	00004517          	auipc	a0,0x4
    3210:	47450513          	addi	a0,a0,1140 # 7680 <malloc+0x19ce>
    3214:	00003097          	auipc	ra,0x3
    3218:	9e0080e7          	jalr	-1568(ra) # 5bf4 <printf>
    exit(1);
    321c:	4505                	li	a0,1
    321e:	00002097          	auipc	ra,0x2
    3222:	626080e7          	jalr	1574(ra) # 5844 <exit>
      printf("%s: write bigfile failed\n", s);
    3226:	85d6                	mv	a1,s5
    3228:	00004517          	auipc	a0,0x4
    322c:	47850513          	addi	a0,a0,1144 # 76a0 <malloc+0x19ee>
    3230:	00003097          	auipc	ra,0x3
    3234:	9c4080e7          	jalr	-1596(ra) # 5bf4 <printf>
      exit(1);
    3238:	4505                	li	a0,1
    323a:	00002097          	auipc	ra,0x2
    323e:	60a080e7          	jalr	1546(ra) # 5844 <exit>
    printf("%s: cannot open bigfile\n", s);
    3242:	85d6                	mv	a1,s5
    3244:	00004517          	auipc	a0,0x4
    3248:	47c50513          	addi	a0,a0,1148 # 76c0 <malloc+0x1a0e>
    324c:	00003097          	auipc	ra,0x3
    3250:	9a8080e7          	jalr	-1624(ra) # 5bf4 <printf>
    exit(1);
    3254:	4505                	li	a0,1
    3256:	00002097          	auipc	ra,0x2
    325a:	5ee080e7          	jalr	1518(ra) # 5844 <exit>
      printf("%s: read bigfile failed\n", s);
    325e:	85d6                	mv	a1,s5
    3260:	00004517          	auipc	a0,0x4
    3264:	48050513          	addi	a0,a0,1152 # 76e0 <malloc+0x1a2e>
    3268:	00003097          	auipc	ra,0x3
    326c:	98c080e7          	jalr	-1652(ra) # 5bf4 <printf>
      exit(1);
    3270:	4505                	li	a0,1
    3272:	00002097          	auipc	ra,0x2
    3276:	5d2080e7          	jalr	1490(ra) # 5844 <exit>
      printf("%s: short read bigfile\n", s);
    327a:	85d6                	mv	a1,s5
    327c:	00004517          	auipc	a0,0x4
    3280:	48450513          	addi	a0,a0,1156 # 7700 <malloc+0x1a4e>
    3284:	00003097          	auipc	ra,0x3
    3288:	970080e7          	jalr	-1680(ra) # 5bf4 <printf>
      exit(1);
    328c:	4505                	li	a0,1
    328e:	00002097          	auipc	ra,0x2
    3292:	5b6080e7          	jalr	1462(ra) # 5844 <exit>
      printf("%s: read bigfile wrong data\n", s);
    3296:	85d6                	mv	a1,s5
    3298:	00004517          	auipc	a0,0x4
    329c:	48050513          	addi	a0,a0,1152 # 7718 <malloc+0x1a66>
    32a0:	00003097          	auipc	ra,0x3
    32a4:	954080e7          	jalr	-1708(ra) # 5bf4 <printf>
      exit(1);
    32a8:	4505                	li	a0,1
    32aa:	00002097          	auipc	ra,0x2
    32ae:	59a080e7          	jalr	1434(ra) # 5844 <exit>
  close(fd);
    32b2:	8552                	mv	a0,s4
    32b4:	00002097          	auipc	ra,0x2
    32b8:	5b8080e7          	jalr	1464(ra) # 586c <close>
  if(total != N*SZ){
    32bc:	678d                	lui	a5,0x3
    32be:	ee078793          	addi	a5,a5,-288 # 2ee0 <reparent+0xb0>
    32c2:	02f99363          	bne	s3,a5,32e8 <bigfile+0x1c4>
  unlink("bigfile.dat");
    32c6:	00004517          	auipc	a0,0x4
    32ca:	3aa50513          	addi	a0,a0,938 # 7670 <malloc+0x19be>
    32ce:	00002097          	auipc	ra,0x2
    32d2:	5c6080e7          	jalr	1478(ra) # 5894 <unlink>
}
    32d6:	70e2                	ld	ra,56(sp)
    32d8:	7442                	ld	s0,48(sp)
    32da:	74a2                	ld	s1,40(sp)
    32dc:	7902                	ld	s2,32(sp)
    32de:	69e2                	ld	s3,24(sp)
    32e0:	6a42                	ld	s4,16(sp)
    32e2:	6aa2                	ld	s5,8(sp)
    32e4:	6121                	addi	sp,sp,64
    32e6:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    32e8:	85d6                	mv	a1,s5
    32ea:	00004517          	auipc	a0,0x4
    32ee:	44e50513          	addi	a0,a0,1102 # 7738 <malloc+0x1a86>
    32f2:	00003097          	auipc	ra,0x3
    32f6:	902080e7          	jalr	-1790(ra) # 5bf4 <printf>
    exit(1);
    32fa:	4505                	li	a0,1
    32fc:	00002097          	auipc	ra,0x2
    3300:	548080e7          	jalr	1352(ra) # 5844 <exit>

0000000000003304 <signal_test>:
void signal_test(char *s){
    3304:	715d                	addi	sp,sp,-80
    3306:	e486                	sd	ra,72(sp)
    3308:	e0a2                	sd	s0,64(sp)
    330a:	fc26                	sd	s1,56(sp)
    330c:	0880                	addi	s0,sp,80
    struct sigaction act = {test_handler, (uint)(1 << 29)};
    330e:	ffffd797          	auipc	a5,0xffffd
    3312:	cf278793          	addi	a5,a5,-782 # 0 <test_handler>
    3316:	fcf43423          	sd	a5,-56(s0)
    331a:	200007b7          	lui	a5,0x20000
    331e:	fcf42823          	sw	a5,-48(s0)
    sigprocmask(0);
    3322:	4501                	li	a0,0
    3324:	00002097          	auipc	ra,0x2
    3328:	5c0080e7          	jalr	1472(ra) # 58e4 <sigprocmask>
    sigaction(testsig, &act, &old);
    332c:	fb840613          	addi	a2,s0,-72
    3330:	fc840593          	addi	a1,s0,-56
    3334:	453d                	li	a0,15
    3336:	00002097          	auipc	ra,0x2
    333a:	5b6080e7          	jalr	1462(ra) # 58ec <sigaction>
    if((pid = fork()) == 0){
    333e:	00002097          	auipc	ra,0x2
    3342:	4fe080e7          	jalr	1278(ra) # 583c <fork>
    3346:	fca42e23          	sw	a0,-36(s0)
    334a:	c90d                	beqz	a0,337c <signal_test+0x78>
    kill(pid, testsig);
    334c:	45bd                	li	a1,15
    334e:	00002097          	auipc	ra,0x2
    3352:	526080e7          	jalr	1318(ra) # 5874 <kill>
    wait(&pid);
    3356:	fdc40513          	addi	a0,s0,-36
    335a:	00002097          	auipc	ra,0x2
    335e:	4f2080e7          	jalr	1266(ra) # 584c <wait>
    printf("Finished testing signals\n");
    3362:	00004517          	auipc	a0,0x4
    3366:	3f650513          	addi	a0,a0,1014 # 7758 <malloc+0x1aa6>
    336a:	00003097          	auipc	ra,0x3
    336e:	88a080e7          	jalr	-1910(ra) # 5bf4 <printf>
}
    3372:	60a6                	ld	ra,72(sp)
    3374:	6406                	ld	s0,64(sp)
    3376:	74e2                	ld	s1,56(sp)
    3378:	6161                	addi	sp,sp,80
    337a:	8082                	ret
        while(!wait_sig)
    337c:	00005797          	auipc	a5,0x5
    3380:	01c7a783          	lw	a5,28(a5) # 8398 <wait_sig>
    3384:	ef81                	bnez	a5,339c <signal_test+0x98>
    3386:	00005497          	auipc	s1,0x5
    338a:	01248493          	addi	s1,s1,18 # 8398 <wait_sig>
            sleep(1);
    338e:	4505                	li	a0,1
    3390:	00002097          	auipc	ra,0x2
    3394:	544080e7          	jalr	1348(ra) # 58d4 <sleep>
        while(!wait_sig)
    3398:	409c                	lw	a5,0(s1)
    339a:	dbf5                	beqz	a5,338e <signal_test+0x8a>
        exit(0);
    339c:	4501                	li	a0,0
    339e:	00002097          	auipc	ra,0x2
    33a2:	4a6080e7          	jalr	1190(ra) # 5844 <exit>

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
    33c2:	e0a50513          	addi	a0,a0,-502 # 61c8 <malloc+0x516>
    33c6:	00002097          	auipc	ra,0x2
    33ca:	4be080e7          	jalr	1214(ra) # 5884 <open>
    33ce:	00002097          	auipc	ra,0x2
    33d2:	49e080e7          	jalr	1182(ra) # 586c <close>
  pid = fork();
    33d6:	00002097          	auipc	ra,0x2
    33da:	466080e7          	jalr	1126(ra) # 583c <fork>
  if(pid < 0){
    33de:	08054063          	bltz	a0,345e <truncate3+0xb8>
  if(pid == 0){
    33e2:	e969                	bnez	a0,34b4 <truncate3+0x10e>
    33e4:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    33e8:	00003a17          	auipc	s4,0x3
    33ec:	de0a0a13          	addi	s4,s4,-544 # 61c8 <malloc+0x516>
      int n = write(fd, "1234567890", 10);
    33f0:	00004a97          	auipc	s5,0x4
    33f4:	388a8a93          	addi	s5,s5,904 # 7778 <malloc+0x1ac6>
      int fd = open("truncfile", O_WRONLY);
    33f8:	4585                	li	a1,1
    33fa:	8552                	mv	a0,s4
    33fc:	00002097          	auipc	ra,0x2
    3400:	488080e7          	jalr	1160(ra) # 5884 <open>
    3404:	84aa                	mv	s1,a0
      if(fd < 0){
    3406:	06054a63          	bltz	a0,347a <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    340a:	4629                	li	a2,10
    340c:	85d6                	mv	a1,s5
    340e:	00002097          	auipc	ra,0x2
    3412:	456080e7          	jalr	1110(ra) # 5864 <write>
      if(n != 10){
    3416:	47a9                	li	a5,10
    3418:	06f51f63          	bne	a0,a5,3496 <truncate3+0xf0>
      close(fd);
    341c:	8526                	mv	a0,s1
    341e:	00002097          	auipc	ra,0x2
    3422:	44e080e7          	jalr	1102(ra) # 586c <close>
      fd = open("truncfile", O_RDONLY);
    3426:	4581                	li	a1,0
    3428:	8552                	mv	a0,s4
    342a:	00002097          	auipc	ra,0x2
    342e:	45a080e7          	jalr	1114(ra) # 5884 <open>
    3432:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    3434:	02000613          	li	a2,32
    3438:	f9840593          	addi	a1,s0,-104
    343c:	00002097          	auipc	ra,0x2
    3440:	420080e7          	jalr	1056(ra) # 585c <read>
      close(fd);
    3444:	8526                	mv	a0,s1
    3446:	00002097          	auipc	ra,0x2
    344a:	426080e7          	jalr	1062(ra) # 586c <close>
    for(int i = 0; i < 100; i++){
    344e:	39fd                	addiw	s3,s3,-1
    3450:	fa0994e3          	bnez	s3,33f8 <truncate3+0x52>
    exit(0);
    3454:	4501                	li	a0,0
    3456:	00002097          	auipc	ra,0x2
    345a:	3ee080e7          	jalr	1006(ra) # 5844 <exit>
    printf("%s: fork failed\n", s);
    345e:	85ca                	mv	a1,s2
    3460:	00003517          	auipc	a0,0x3
    3464:	b9850513          	addi	a0,a0,-1128 # 5ff8 <malloc+0x346>
    3468:	00002097          	auipc	ra,0x2
    346c:	78c080e7          	jalr	1932(ra) # 5bf4 <printf>
    exit(1);
    3470:	4505                	li	a0,1
    3472:	00002097          	auipc	ra,0x2
    3476:	3d2080e7          	jalr	978(ra) # 5844 <exit>
        printf("%s: open failed\n", s);
    347a:	85ca                	mv	a1,s2
    347c:	00003517          	auipc	a0,0x3
    3480:	42c50513          	addi	a0,a0,1068 # 68a8 <malloc+0xbf6>
    3484:	00002097          	auipc	ra,0x2
    3488:	770080e7          	jalr	1904(ra) # 5bf4 <printf>
        exit(1);
    348c:	4505                	li	a0,1
    348e:	00002097          	auipc	ra,0x2
    3492:	3b6080e7          	jalr	950(ra) # 5844 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    3496:	862a                	mv	a2,a0
    3498:	85ca                	mv	a1,s2
    349a:	00004517          	auipc	a0,0x4
    349e:	2ee50513          	addi	a0,a0,750 # 7788 <malloc+0x1ad6>
    34a2:	00002097          	auipc	ra,0x2
    34a6:	752080e7          	jalr	1874(ra) # 5bf4 <printf>
        exit(1);
    34aa:	4505                	li	a0,1
    34ac:	00002097          	auipc	ra,0x2
    34b0:	398080e7          	jalr	920(ra) # 5844 <exit>
    34b4:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    34b8:	00003a17          	auipc	s4,0x3
    34bc:	d10a0a13          	addi	s4,s4,-752 # 61c8 <malloc+0x516>
    int n = write(fd, "xxx", 3);
    34c0:	00004a97          	auipc	s5,0x4
    34c4:	2e8a8a93          	addi	s5,s5,744 # 77a8 <malloc+0x1af6>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    34c8:	60100593          	li	a1,1537
    34cc:	8552                	mv	a0,s4
    34ce:	00002097          	auipc	ra,0x2
    34d2:	3b6080e7          	jalr	950(ra) # 5884 <open>
    34d6:	84aa                	mv	s1,a0
    if(fd < 0){
    34d8:	04054763          	bltz	a0,3526 <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    34dc:	460d                	li	a2,3
    34de:	85d6                	mv	a1,s5
    34e0:	00002097          	auipc	ra,0x2
    34e4:	384080e7          	jalr	900(ra) # 5864 <write>
    if(n != 3){
    34e8:	478d                	li	a5,3
    34ea:	04f51c63          	bne	a0,a5,3542 <truncate3+0x19c>
    close(fd);
    34ee:	8526                	mv	a0,s1
    34f0:	00002097          	auipc	ra,0x2
    34f4:	37c080e7          	jalr	892(ra) # 586c <close>
  for(int i = 0; i < 150; i++){
    34f8:	39fd                	addiw	s3,s3,-1
    34fa:	fc0997e3          	bnez	s3,34c8 <truncate3+0x122>
  wait(&xstatus);
    34fe:	fbc40513          	addi	a0,s0,-68
    3502:	00002097          	auipc	ra,0x2
    3506:	34a080e7          	jalr	842(ra) # 584c <wait>
  unlink("truncfile");
    350a:	00003517          	auipc	a0,0x3
    350e:	cbe50513          	addi	a0,a0,-834 # 61c8 <malloc+0x516>
    3512:	00002097          	auipc	ra,0x2
    3516:	382080e7          	jalr	898(ra) # 5894 <unlink>
  exit(xstatus);
    351a:	fbc42503          	lw	a0,-68(s0)
    351e:	00002097          	auipc	ra,0x2
    3522:	326080e7          	jalr	806(ra) # 5844 <exit>
      printf("%s: open failed\n", s);
    3526:	85ca                	mv	a1,s2
    3528:	00003517          	auipc	a0,0x3
    352c:	38050513          	addi	a0,a0,896 # 68a8 <malloc+0xbf6>
    3530:	00002097          	auipc	ra,0x2
    3534:	6c4080e7          	jalr	1732(ra) # 5bf4 <printf>
      exit(1);
    3538:	4505                	li	a0,1
    353a:	00002097          	auipc	ra,0x2
    353e:	30a080e7          	jalr	778(ra) # 5844 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    3542:	862a                	mv	a2,a0
    3544:	85ca                	mv	a1,s2
    3546:	00004517          	auipc	a0,0x4
    354a:	26a50513          	addi	a0,a0,618 # 77b0 <malloc+0x1afe>
    354e:	00002097          	auipc	ra,0x2
    3552:	6a6080e7          	jalr	1702(ra) # 5bf4 <printf>
      exit(1);
    3556:	4505                	li	a0,1
    3558:	00002097          	auipc	ra,0x2
    355c:	2ec080e7          	jalr	748(ra) # 5844 <exit>

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
    357e:	25650513          	addi	a0,a0,598 # 77d0 <malloc+0x1b1e>
    3582:	00002097          	auipc	ra,0x2
    3586:	302080e7          	jalr	770(ra) # 5884 <open>
  if(fd < 0){
    358a:	0a054d63          	bltz	a0,3644 <writetest+0xe4>
    358e:	892a                	mv	s2,a0
    3590:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
    3592:	00004997          	auipc	s3,0x4
    3596:	26698993          	addi	s3,s3,614 # 77f8 <malloc+0x1b46>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
    359a:	00004a97          	auipc	s5,0x4
    359e:	296a8a93          	addi	s5,s5,662 # 7830 <malloc+0x1b7e>
  for(i = 0; i < N; i++){
    35a2:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
    35a6:	4629                	li	a2,10
    35a8:	85ce                	mv	a1,s3
    35aa:	854a                	mv	a0,s2
    35ac:	00002097          	auipc	ra,0x2
    35b0:	2b8080e7          	jalr	696(ra) # 5864 <write>
    35b4:	47a9                	li	a5,10
    35b6:	0af51563          	bne	a0,a5,3660 <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
    35ba:	4629                	li	a2,10
    35bc:	85d6                	mv	a1,s5
    35be:	854a                	mv	a0,s2
    35c0:	00002097          	auipc	ra,0x2
    35c4:	2a4080e7          	jalr	676(ra) # 5864 <write>
    35c8:	47a9                	li	a5,10
    35ca:	0af51a63          	bne	a0,a5,367e <writetest+0x11e>
  for(i = 0; i < N; i++){
    35ce:	2485                	addiw	s1,s1,1
    35d0:	fd449be3          	bne	s1,s4,35a6 <writetest+0x46>
  close(fd);
    35d4:	854a                	mv	a0,s2
    35d6:	00002097          	auipc	ra,0x2
    35da:	296080e7          	jalr	662(ra) # 586c <close>
  fd = open("small", O_RDONLY);
    35de:	4581                	li	a1,0
    35e0:	00004517          	auipc	a0,0x4
    35e4:	1f050513          	addi	a0,a0,496 # 77d0 <malloc+0x1b1e>
    35e8:	00002097          	auipc	ra,0x2
    35ec:	29c080e7          	jalr	668(ra) # 5884 <open>
    35f0:	84aa                	mv	s1,a0
  if(fd < 0){
    35f2:	0a054563          	bltz	a0,369c <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
    35f6:	7d000613          	li	a2,2000
    35fa:	00008597          	auipc	a1,0x8
    35fe:	5c658593          	addi	a1,a1,1478 # bbc0 <buf>
    3602:	00002097          	auipc	ra,0x2
    3606:	25a080e7          	jalr	602(ra) # 585c <read>
  if(i != N*SZ*2){
    360a:	7d000793          	li	a5,2000
    360e:	0af51563          	bne	a0,a5,36b8 <writetest+0x158>
  close(fd);
    3612:	8526                	mv	a0,s1
    3614:	00002097          	auipc	ra,0x2
    3618:	258080e7          	jalr	600(ra) # 586c <close>
  if(unlink("small") < 0){
    361c:	00004517          	auipc	a0,0x4
    3620:	1b450513          	addi	a0,a0,436 # 77d0 <malloc+0x1b1e>
    3624:	00002097          	auipc	ra,0x2
    3628:	270080e7          	jalr	624(ra) # 5894 <unlink>
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
    364a:	19250513          	addi	a0,a0,402 # 77d8 <malloc+0x1b26>
    364e:	00002097          	auipc	ra,0x2
    3652:	5a6080e7          	jalr	1446(ra) # 5bf4 <printf>
    exit(1);
    3656:	4505                	li	a0,1
    3658:	00002097          	auipc	ra,0x2
    365c:	1ec080e7          	jalr	492(ra) # 5844 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
    3660:	8626                	mv	a2,s1
    3662:	85da                	mv	a1,s6
    3664:	00004517          	auipc	a0,0x4
    3668:	1a450513          	addi	a0,a0,420 # 7808 <malloc+0x1b56>
    366c:	00002097          	auipc	ra,0x2
    3670:	588080e7          	jalr	1416(ra) # 5bf4 <printf>
      exit(1);
    3674:	4505                	li	a0,1
    3676:	00002097          	auipc	ra,0x2
    367a:	1ce080e7          	jalr	462(ra) # 5844 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
    367e:	8626                	mv	a2,s1
    3680:	85da                	mv	a1,s6
    3682:	00004517          	auipc	a0,0x4
    3686:	1be50513          	addi	a0,a0,446 # 7840 <malloc+0x1b8e>
    368a:	00002097          	auipc	ra,0x2
    368e:	56a080e7          	jalr	1386(ra) # 5bf4 <printf>
      exit(1);
    3692:	4505                	li	a0,1
    3694:	00002097          	auipc	ra,0x2
    3698:	1b0080e7          	jalr	432(ra) # 5844 <exit>
    printf("%s: error: open small failed!\n", s);
    369c:	85da                	mv	a1,s6
    369e:	00004517          	auipc	a0,0x4
    36a2:	1ca50513          	addi	a0,a0,458 # 7868 <malloc+0x1bb6>
    36a6:	00002097          	auipc	ra,0x2
    36aa:	54e080e7          	jalr	1358(ra) # 5bf4 <printf>
    exit(1);
    36ae:	4505                	li	a0,1
    36b0:	00002097          	auipc	ra,0x2
    36b4:	194080e7          	jalr	404(ra) # 5844 <exit>
    printf("%s: read failed\n", s);
    36b8:	85da                	mv	a1,s6
    36ba:	00003517          	auipc	a0,0x3
    36be:	20650513          	addi	a0,a0,518 # 68c0 <malloc+0xc0e>
    36c2:	00002097          	auipc	ra,0x2
    36c6:	532080e7          	jalr	1330(ra) # 5bf4 <printf>
    exit(1);
    36ca:	4505                	li	a0,1
    36cc:	00002097          	auipc	ra,0x2
    36d0:	178080e7          	jalr	376(ra) # 5844 <exit>
    printf("%s: unlink small failed\n", s);
    36d4:	85da                	mv	a1,s6
    36d6:	00004517          	auipc	a0,0x4
    36da:	1b250513          	addi	a0,a0,434 # 7888 <malloc+0x1bd6>
    36de:	00002097          	auipc	ra,0x2
    36e2:	516080e7          	jalr	1302(ra) # 5bf4 <printf>
    exit(1);
    36e6:	4505                	li	a0,1
    36e8:	00002097          	auipc	ra,0x2
    36ec:	15c080e7          	jalr	348(ra) # 5844 <exit>

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
    370c:	1a050513          	addi	a0,a0,416 # 78a8 <malloc+0x1bf6>
    3710:	00002097          	auipc	ra,0x2
    3714:	174080e7          	jalr	372(ra) # 5884 <open>
    3718:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
    371a:	4481                	li	s1,0
    ((int*)buf)[0] = i;
    371c:	00008917          	auipc	s2,0x8
    3720:	4a490913          	addi	s2,s2,1188 # bbc0 <buf>
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
    373c:	12c080e7          	jalr	300(ra) # 5864 <write>
    3740:	40000793          	li	a5,1024
    3744:	06f51c63          	bne	a0,a5,37bc <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
    3748:	2485                	addiw	s1,s1,1
    374a:	ff4491e3          	bne	s1,s4,372c <writebig+0x3c>
  close(fd);
    374e:	854e                	mv	a0,s3
    3750:	00002097          	auipc	ra,0x2
    3754:	11c080e7          	jalr	284(ra) # 586c <close>
  fd = open("big", O_RDONLY);
    3758:	4581                	li	a1,0
    375a:	00004517          	auipc	a0,0x4
    375e:	14e50513          	addi	a0,a0,334 # 78a8 <malloc+0x1bf6>
    3762:	00002097          	auipc	ra,0x2
    3766:	122080e7          	jalr	290(ra) # 5884 <open>
    376a:	89aa                	mv	s3,a0
  n = 0;
    376c:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
    376e:	00008917          	auipc	s2,0x8
    3772:	45290913          	addi	s2,s2,1106 # bbc0 <buf>
  if(fd < 0){
    3776:	06054263          	bltz	a0,37da <writebig+0xea>
    i = read(fd, buf, BSIZE);
    377a:	40000613          	li	a2,1024
    377e:	85ca                	mv	a1,s2
    3780:	854e                	mv	a0,s3
    3782:	00002097          	auipc	ra,0x2
    3786:	0da080e7          	jalr	218(ra) # 585c <read>
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
    37a6:	10e50513          	addi	a0,a0,270 # 78b0 <malloc+0x1bfe>
    37aa:	00002097          	auipc	ra,0x2
    37ae:	44a080e7          	jalr	1098(ra) # 5bf4 <printf>
    exit(1);
    37b2:	4505                	li	a0,1
    37b4:	00002097          	auipc	ra,0x2
    37b8:	090080e7          	jalr	144(ra) # 5844 <exit>
      printf("%s: error: write big file failed\n", s, i);
    37bc:	8626                	mv	a2,s1
    37be:	85d6                	mv	a1,s5
    37c0:	00004517          	auipc	a0,0x4
    37c4:	11050513          	addi	a0,a0,272 # 78d0 <malloc+0x1c1e>
    37c8:	00002097          	auipc	ra,0x2
    37cc:	42c080e7          	jalr	1068(ra) # 5bf4 <printf>
      exit(1);
    37d0:	4505                	li	a0,1
    37d2:	00002097          	auipc	ra,0x2
    37d6:	072080e7          	jalr	114(ra) # 5844 <exit>
    printf("%s: error: open big failed!\n", s);
    37da:	85d6                	mv	a1,s5
    37dc:	00004517          	auipc	a0,0x4
    37e0:	11c50513          	addi	a0,a0,284 # 78f8 <malloc+0x1c46>
    37e4:	00002097          	auipc	ra,0x2
    37e8:	410080e7          	jalr	1040(ra) # 5bf4 <printf>
    exit(1);
    37ec:	4505                	li	a0,1
    37ee:	00002097          	auipc	ra,0x2
    37f2:	056080e7          	jalr	86(ra) # 5844 <exit>
      if(n == MAXFILE - 1){
    37f6:	10b00793          	li	a5,267
    37fa:	02f48a63          	beq	s1,a5,382e <writebig+0x13e>
  close(fd);
    37fe:	854e                	mv	a0,s3
    3800:	00002097          	auipc	ra,0x2
    3804:	06c080e7          	jalr	108(ra) # 586c <close>
  if(unlink("big") < 0){
    3808:	00004517          	auipc	a0,0x4
    380c:	0a050513          	addi	a0,a0,160 # 78a8 <malloc+0x1bf6>
    3810:	00002097          	auipc	ra,0x2
    3814:	084080e7          	jalr	132(ra) # 5894 <unlink>
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
    3838:	0e450513          	addi	a0,a0,228 # 7918 <malloc+0x1c66>
    383c:	00002097          	auipc	ra,0x2
    3840:	3b8080e7          	jalr	952(ra) # 5bf4 <printf>
        exit(1);
    3844:	4505                	li	a0,1
    3846:	00002097          	auipc	ra,0x2
    384a:	ffe080e7          	jalr	-2(ra) # 5844 <exit>
      printf("%s: read failed %d\n", s, i);
    384e:	862a                	mv	a2,a0
    3850:	85d6                	mv	a1,s5
    3852:	00004517          	auipc	a0,0x4
    3856:	0ee50513          	addi	a0,a0,238 # 7940 <malloc+0x1c8e>
    385a:	00002097          	auipc	ra,0x2
    385e:	39a080e7          	jalr	922(ra) # 5bf4 <printf>
      exit(1);
    3862:	4505                	li	a0,1
    3864:	00002097          	auipc	ra,0x2
    3868:	fe0080e7          	jalr	-32(ra) # 5844 <exit>
      printf("%s: read content of block %d is %d\n", s,
    386c:	8626                	mv	a2,s1
    386e:	85d6                	mv	a1,s5
    3870:	00004517          	auipc	a0,0x4
    3874:	0e850513          	addi	a0,a0,232 # 7958 <malloc+0x1ca6>
    3878:	00002097          	auipc	ra,0x2
    387c:	37c080e7          	jalr	892(ra) # 5bf4 <printf>
      exit(1);
    3880:	4505                	li	a0,1
    3882:	00002097          	auipc	ra,0x2
    3886:	fc2080e7          	jalr	-62(ra) # 5844 <exit>
    printf("%s: unlink big failed\n", s);
    388a:	85d6                	mv	a1,s5
    388c:	00004517          	auipc	a0,0x4
    3890:	0f450513          	addi	a0,a0,244 # 7980 <malloc+0x1cce>
    3894:	00002097          	auipc	ra,0x2
    3898:	360080e7          	jalr	864(ra) # 5bf4 <printf>
    exit(1);
    389c:	4505                	li	a0,1
    389e:	00002097          	auipc	ra,0x2
    38a2:	fa6080e7          	jalr	-90(ra) # 5844 <exit>

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
    38d6:	fb2080e7          	jalr	-78(ra) # 5884 <open>
    close(fd);
    38da:	00002097          	auipc	ra,0x2
    38de:	f92080e7          	jalr	-110(ra) # 586c <close>
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
    390c:	f8c080e7          	jalr	-116(ra) # 5894 <unlink>
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
    3942:	efe080e7          	jalr	-258(ra) # 583c <fork>
    3946:	84aa                	mv	s1,a0
    if(pid1 < 0){
    3948:	04054063          	bltz	a0,3988 <killstatus+0x62>
    if(pid1 == 0){
    394c:	cd21                	beqz	a0,39a4 <killstatus+0x7e>
    sleep(1);
    394e:	4505                	li	a0,1
    3950:	00002097          	auipc	ra,0x2
    3954:	f84080e7          	jalr	-124(ra) # 58d4 <sleep>
    kill(pid1, SIGKILL);
    3958:	45a5                	li	a1,9
    395a:	8526                	mv	a0,s1
    395c:	00002097          	auipc	ra,0x2
    3960:	f18080e7          	jalr	-232(ra) # 5874 <kill>
    wait(&xst);
    3964:	fcc40513          	addi	a0,s0,-52
    3968:	00002097          	auipc	ra,0x2
    396c:	ee4080e7          	jalr	-284(ra) # 584c <wait>
    if(xst != -1) {
    3970:	fcc42783          	lw	a5,-52(s0)
    3974:	03379d63          	bne	a5,s3,39ae <killstatus+0x88>
  for(int i = 0; i < 100; i++){
    3978:	397d                	addiw	s2,s2,-1
    397a:	fc0912e3          	bnez	s2,393e <killstatus+0x18>
  exit(0);
    397e:	4501                	li	a0,0
    3980:	00002097          	auipc	ra,0x2
    3984:	ec4080e7          	jalr	-316(ra) # 5844 <exit>
      printf("%s: fork failed\n", s);
    3988:	85d2                	mv	a1,s4
    398a:	00002517          	auipc	a0,0x2
    398e:	66e50513          	addi	a0,a0,1646 # 5ff8 <malloc+0x346>
    3992:	00002097          	auipc	ra,0x2
    3996:	262080e7          	jalr	610(ra) # 5bf4 <printf>
      exit(1);
    399a:	4505                	li	a0,1
    399c:	00002097          	auipc	ra,0x2
    39a0:	ea8080e7          	jalr	-344(ra) # 5844 <exit>
        getpid();
    39a4:	00002097          	auipc	ra,0x2
    39a8:	f20080e7          	jalr	-224(ra) # 58c4 <getpid>
      while(1) {
    39ac:	bfe5                	j	39a4 <killstatus+0x7e>
       printf("%s: status should be -1\n", s);
    39ae:	85d2                	mv	a1,s4
    39b0:	00004517          	auipc	a0,0x4
    39b4:	fe850513          	addi	a0,a0,-24 # 7998 <malloc+0x1ce6>
    39b8:	00002097          	auipc	ra,0x2
    39bc:	23c080e7          	jalr	572(ra) # 5bf4 <printf>
       exit(1);
    39c0:	4505                	li	a0,1
    39c2:	00002097          	auipc	ra,0x2
    39c6:	e82080e7          	jalr	-382(ra) # 5844 <exit>

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
    39dc:	e64080e7          	jalr	-412(ra) # 583c <fork>
    if(pid1 < 0){
    39e0:	00054f63          	bltz	a0,39fe <reparent2+0x34>
    if(pid1 == 0){
    39e4:	c915                	beqz	a0,3a18 <reparent2+0x4e>
    wait(0);
    39e6:	4501                	li	a0,0
    39e8:	00002097          	auipc	ra,0x2
    39ec:	e64080e7          	jalr	-412(ra) # 584c <wait>
  for(int i = 0; i < 800; i++){
    39f0:	34fd                	addiw	s1,s1,-1
    39f2:	f0fd                	bnez	s1,39d8 <reparent2+0xe>
  exit(0);
    39f4:	4501                	li	a0,0
    39f6:	00002097          	auipc	ra,0x2
    39fa:	e4e080e7          	jalr	-434(ra) # 5844 <exit>
      printf("fork failed\n");
    39fe:	00003517          	auipc	a0,0x3
    3a02:	ff250513          	addi	a0,a0,-14 # 69f0 <malloc+0xd3e>
    3a06:	00002097          	auipc	ra,0x2
    3a0a:	1ee080e7          	jalr	494(ra) # 5bf4 <printf>
      exit(1);
    3a0e:	4505                	li	a0,1
    3a10:	00002097          	auipc	ra,0x2
    3a14:	e34080e7          	jalr	-460(ra) # 5844 <exit>
      fork();
    3a18:	00002097          	auipc	ra,0x2
    3a1c:	e24080e7          	jalr	-476(ra) # 583c <fork>
      fork();
    3a20:	00002097          	auipc	ra,0x2
    3a24:	e1c080e7          	jalr	-484(ra) # 583c <fork>
      exit(0);
    3a28:	4501                	li	a0,0
    3a2a:	00002097          	auipc	ra,0x2
    3a2e:	e1a080e7          	jalr	-486(ra) # 5844 <exit>

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
    3a46:	dfa080e7          	jalr	-518(ra) # 583c <fork>
    m1 = 0;
    3a4a:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    3a4c:	6909                	lui	s2,0x2
    3a4e:	71190913          	addi	s2,s2,1809 # 2711 <subdir+0x461>
  if((pid = fork()) == 0){
    3a52:	c115                	beqz	a0,3a76 <mem+0x44>
    wait(&xstatus);
    3a54:	fcc40513          	addi	a0,s0,-52
    3a58:	00002097          	auipc	ra,0x2
    3a5c:	df4080e7          	jalr	-524(ra) # 584c <wait>
    if(xstatus == -1){
    3a60:	fcc42503          	lw	a0,-52(s0)
    3a64:	57fd                	li	a5,-1
    3a66:	06f50363          	beq	a0,a5,3acc <mem+0x9a>
    exit(xstatus);
    3a6a:	00002097          	auipc	ra,0x2
    3a6e:	dda080e7          	jalr	-550(ra) # 5844 <exit>
      *(char**)m2 = m1;
    3a72:	e104                	sd	s1,0(a0)
      m1 = m2;
    3a74:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    3a76:	854a                	mv	a0,s2
    3a78:	00002097          	auipc	ra,0x2
    3a7c:	23a080e7          	jalr	570(ra) # 5cb2 <malloc>
    3a80:	f96d                	bnez	a0,3a72 <mem+0x40>
    while(m1){
    3a82:	c881                	beqz	s1,3a92 <mem+0x60>
      m2 = *(char**)m1;
    3a84:	8526                	mv	a0,s1
    3a86:	6084                	ld	s1,0(s1)
      free(m1);
    3a88:	00002097          	auipc	ra,0x2
    3a8c:	1a2080e7          	jalr	418(ra) # 5c2a <free>
    while(m1){
    3a90:	f8f5                	bnez	s1,3a84 <mem+0x52>
    m1 = malloc(1024*20);
    3a92:	6515                	lui	a0,0x5
    3a94:	00002097          	auipc	ra,0x2
    3a98:	21e080e7          	jalr	542(ra) # 5cb2 <malloc>
    if(m1 == 0){
    3a9c:	c911                	beqz	a0,3ab0 <mem+0x7e>
    free(m1);
    3a9e:	00002097          	auipc	ra,0x2
    3aa2:	18c080e7          	jalr	396(ra) # 5c2a <free>
    exit(0);
    3aa6:	4501                	li	a0,0
    3aa8:	00002097          	auipc	ra,0x2
    3aac:	d9c080e7          	jalr	-612(ra) # 5844 <exit>
      printf("couldn't allocate mem?!!\n", s);
    3ab0:	85ce                	mv	a1,s3
    3ab2:	00004517          	auipc	a0,0x4
    3ab6:	f0650513          	addi	a0,a0,-250 # 79b8 <malloc+0x1d06>
    3aba:	00002097          	auipc	ra,0x2
    3abe:	13a080e7          	jalr	314(ra) # 5bf4 <printf>
      exit(1);
    3ac2:	4505                	li	a0,1
    3ac4:	00002097          	auipc	ra,0x2
    3ac8:	d80080e7          	jalr	-640(ra) # 5844 <exit>
      exit(0);
    3acc:	4501                	li	a0,0
    3ace:	00002097          	auipc	ra,0x2
    3ad2:	d76080e7          	jalr	-650(ra) # 5844 <exit>

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
    3af2:	eea50513          	addi	a0,a0,-278 # 79d8 <malloc+0x1d26>
    3af6:	00002097          	auipc	ra,0x2
    3afa:	d9e080e7          	jalr	-610(ra) # 5894 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    3afe:	20200593          	li	a1,514
    3b02:	00004517          	auipc	a0,0x4
    3b06:	ed650513          	addi	a0,a0,-298 # 79d8 <malloc+0x1d26>
    3b0a:	00002097          	auipc	ra,0x2
    3b0e:	d7a080e7          	jalr	-646(ra) # 5884 <open>
  if(fd < 0){
    3b12:	04054a63          	bltz	a0,3b66 <sharedfd+0x90>
    3b16:	892a                	mv	s2,a0
  pid = fork();
    3b18:	00002097          	auipc	ra,0x2
    3b1c:	d24080e7          	jalr	-732(ra) # 583c <fork>
    3b20:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    3b22:	06300593          	li	a1,99
    3b26:	c119                	beqz	a0,3b2c <sharedfd+0x56>
    3b28:	07000593          	li	a1,112
    3b2c:	4629                	li	a2,10
    3b2e:	fa040513          	addi	a0,s0,-96
    3b32:	00002097          	auipc	ra,0x2
    3b36:	b16080e7          	jalr	-1258(ra) # 5648 <memset>
    3b3a:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    3b3e:	4629                	li	a2,10
    3b40:	fa040593          	addi	a1,s0,-96
    3b44:	854a                	mv	a0,s2
    3b46:	00002097          	auipc	ra,0x2
    3b4a:	d1e080e7          	jalr	-738(ra) # 5864 <write>
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
    3b62:	ce6080e7          	jalr	-794(ra) # 5844 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    3b66:	85d2                	mv	a1,s4
    3b68:	00004517          	auipc	a0,0x4
    3b6c:	e8050513          	addi	a0,a0,-384 # 79e8 <malloc+0x1d36>
    3b70:	00002097          	auipc	ra,0x2
    3b74:	084080e7          	jalr	132(ra) # 5bf4 <printf>
    exit(1);
    3b78:	4505                	li	a0,1
    3b7a:	00002097          	auipc	ra,0x2
    3b7e:	cca080e7          	jalr	-822(ra) # 5844 <exit>
      printf("%s: write sharedfd failed\n", s);
    3b82:	85d2                	mv	a1,s4
    3b84:	00004517          	auipc	a0,0x4
    3b88:	e8c50513          	addi	a0,a0,-372 # 7a10 <malloc+0x1d5e>
    3b8c:	00002097          	auipc	ra,0x2
    3b90:	068080e7          	jalr	104(ra) # 5bf4 <printf>
      exit(1);
    3b94:	4505                	li	a0,1
    3b96:	00002097          	auipc	ra,0x2
    3b9a:	cae080e7          	jalr	-850(ra) # 5844 <exit>
    wait(&xstatus);
    3b9e:	f9c40513          	addi	a0,s0,-100
    3ba2:	00002097          	auipc	ra,0x2
    3ba6:	caa080e7          	jalr	-854(ra) # 584c <wait>
    if(xstatus != 0)
    3baa:	f9c42983          	lw	s3,-100(s0)
    3bae:	00098763          	beqz	s3,3bbc <sharedfd+0xe6>
      exit(xstatus);
    3bb2:	854e                	mv	a0,s3
    3bb4:	00002097          	auipc	ra,0x2
    3bb8:	c90080e7          	jalr	-880(ra) # 5844 <exit>
  close(fd);
    3bbc:	854a                	mv	a0,s2
    3bbe:	00002097          	auipc	ra,0x2
    3bc2:	cae080e7          	jalr	-850(ra) # 586c <close>
  fd = open("sharedfd", 0);
    3bc6:	4581                	li	a1,0
    3bc8:	00004517          	auipc	a0,0x4
    3bcc:	e1050513          	addi	a0,a0,-496 # 79d8 <malloc+0x1d26>
    3bd0:	00002097          	auipc	ra,0x2
    3bd4:	cb4080e7          	jalr	-844(ra) # 5884 <open>
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
    3bf8:	c68080e7          	jalr	-920(ra) # 585c <read>
    3bfc:	02a05f63          	blez	a0,3c3a <sharedfd+0x164>
    3c00:	fa040793          	addi	a5,s0,-96
    3c04:	a01d                	j	3c2a <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    3c06:	85d2                	mv	a1,s4
    3c08:	00004517          	auipc	a0,0x4
    3c0c:	e2850513          	addi	a0,a0,-472 # 7a30 <malloc+0x1d7e>
    3c10:	00002097          	auipc	ra,0x2
    3c14:	fe4080e7          	jalr	-28(ra) # 5bf4 <printf>
    exit(1);
    3c18:	4505                	li	a0,1
    3c1a:	00002097          	auipc	ra,0x2
    3c1e:	c2a080e7          	jalr	-982(ra) # 5844 <exit>
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
    3c40:	c30080e7          	jalr	-976(ra) # 586c <close>
  unlink("sharedfd");
    3c44:	00004517          	auipc	a0,0x4
    3c48:	d9450513          	addi	a0,a0,-620 # 79d8 <malloc+0x1d26>
    3c4c:	00002097          	auipc	ra,0x2
    3c50:	c48080e7          	jalr	-952(ra) # 5894 <unlink>
  if(nc == N*SZ && np == N*SZ){
    3c54:	6789                	lui	a5,0x2
    3c56:	71078793          	addi	a5,a5,1808 # 2710 <subdir+0x460>
    3c5a:	00f99763          	bne	s3,a5,3c68 <sharedfd+0x192>
    3c5e:	6789                	lui	a5,0x2
    3c60:	71078793          	addi	a5,a5,1808 # 2710 <subdir+0x460>
    3c64:	02fa8063          	beq	s5,a5,3c84 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    3c68:	85d2                	mv	a1,s4
    3c6a:	00004517          	auipc	a0,0x4
    3c6e:	dee50513          	addi	a0,a0,-530 # 7a58 <malloc+0x1da6>
    3c72:	00002097          	auipc	ra,0x2
    3c76:	f82080e7          	jalr	-126(ra) # 5bf4 <printf>
    exit(1);
    3c7a:	4505                	li	a0,1
    3c7c:	00002097          	auipc	ra,0x2
    3c80:	bc8080e7          	jalr	-1080(ra) # 5844 <exit>
    exit(0);
    3c84:	4501                	li	a0,0
    3c86:	00002097          	auipc	ra,0x2
    3c8a:	bbe080e7          	jalr	-1090(ra) # 5844 <exit>

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
    3cb2:	b8e080e7          	jalr	-1138(ra) # 583c <fork>
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
    3cce:	b82080e7          	jalr	-1150(ra) # 584c <wait>
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
    3cfc:	cf850513          	addi	a0,a0,-776 # 69f0 <malloc+0xd3e>
    3d00:	00002097          	auipc	ra,0x2
    3d04:	ef4080e7          	jalr	-268(ra) # 5bf4 <printf>
      exit(1);
    3d08:	4505                	li	a0,1
    3d0a:	00002097          	auipc	ra,0x2
    3d0e:	b3a080e7          	jalr	-1222(ra) # 5844 <exit>
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
    3d28:	b2c50513          	addi	a0,a0,-1236 # 6850 <malloc+0xb9e>
    3d2c:	00002097          	auipc	ra,0x2
    3d30:	ec8080e7          	jalr	-312(ra) # 5bf4 <printf>
          exit(1);
    3d34:	4505                	li	a0,1
    3d36:	00002097          	auipc	ra,0x2
    3d3a:	b0e080e7          	jalr	-1266(ra) # 5844 <exit>
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
    3d58:	b30080e7          	jalr	-1232(ra) # 5884 <open>
        if(fd < 0){
    3d5c:	fc0543e3          	bltz	a0,3d22 <createdelete+0x94>
        close(fd);
    3d60:	00002097          	auipc	ra,0x2
    3d64:	b0c080e7          	jalr	-1268(ra) # 586c <close>
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
    3d8c:	b0c080e7          	jalr	-1268(ra) # 5894 <unlink>
    3d90:	fa0557e3          	bgez	a0,3d3e <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    3d94:	85e6                	mv	a1,s9
    3d96:	00003517          	auipc	a0,0x3
    3d9a:	dc250513          	addi	a0,a0,-574 # 6b58 <malloc+0xea6>
    3d9e:	00002097          	auipc	ra,0x2
    3da2:	e56080e7          	jalr	-426(ra) # 5bf4 <printf>
            exit(1);
    3da6:	4505                	li	a0,1
    3da8:	00002097          	auipc	ra,0x2
    3dac:	a9c080e7          	jalr	-1380(ra) # 5844 <exit>
      exit(0);
    3db0:	4501                	li	a0,0
    3db2:	00002097          	auipc	ra,0x2
    3db6:	a92080e7          	jalr	-1390(ra) # 5844 <exit>
      exit(1);
    3dba:	4505                	li	a0,1
    3dbc:	00002097          	auipc	ra,0x2
    3dc0:	a88080e7          	jalr	-1400(ra) # 5844 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    3dc4:	f8040613          	addi	a2,s0,-128
    3dc8:	85e6                	mv	a1,s9
    3dca:	00004517          	auipc	a0,0x4
    3dce:	ca650513          	addi	a0,a0,-858 # 7a70 <malloc+0x1dbe>
    3dd2:	00002097          	auipc	ra,0x2
    3dd6:	e22080e7          	jalr	-478(ra) # 5bf4 <printf>
        exit(1);
    3dda:	4505                	li	a0,1
    3ddc:	00002097          	auipc	ra,0x2
    3de0:	a68080e7          	jalr	-1432(ra) # 5844 <exit>
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
    3e08:	a80080e7          	jalr	-1408(ra) # 5884 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    3e0c:	00090463          	beqz	s2,3e14 <createdelete+0x186>
    3e10:	fd2bdae3          	bge	s7,s2,3de4 <createdelete+0x156>
    3e14:	fa0548e3          	bltz	a0,3dc4 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    3e18:	014b7963          	bgeu	s6,s4,3e2a <createdelete+0x19c>
        close(fd);
    3e1c:	00002097          	auipc	ra,0x2
    3e20:	a50080e7          	jalr	-1456(ra) # 586c <close>
    3e24:	b7e1                	j	3dec <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    3e26:	fc0543e3          	bltz	a0,3dec <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    3e2a:	f8040613          	addi	a2,s0,-128
    3e2e:	85e6                	mv	a1,s9
    3e30:	00004517          	auipc	a0,0x4
    3e34:	c6850513          	addi	a0,a0,-920 # 7a98 <malloc+0x1de6>
    3e38:	00002097          	auipc	ra,0x2
    3e3c:	dbc080e7          	jalr	-580(ra) # 5bf4 <printf>
        exit(1);
    3e40:	4505                	li	a0,1
    3e42:	00002097          	auipc	ra,0x2
    3e46:	a02080e7          	jalr	-1534(ra) # 5844 <exit>
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
    3e80:	a18080e7          	jalr	-1512(ra) # 5894 <unlink>
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
    3ee2:	be2b8b93          	addi	s7,s7,-1054 # 7ac0 <malloc+0x1e0e>
  for(i = 0; i < N; i++){
    3ee6:	02800a13          	li	s4,40
    3eea:	acc1                	j	41ba <concreate+0x306>
      link("C0", file);
    3eec:	fa840593          	addi	a1,s0,-88
    3ef0:	855e                	mv	a0,s7
    3ef2:	00002097          	auipc	ra,0x2
    3ef6:	9b2080e7          	jalr	-1614(ra) # 58a4 <link>
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
    3f14:	974080e7          	jalr	-1676(ra) # 5884 <open>
      if(fd < 0){
    3f18:	26055b63          	bgez	a0,418e <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    3f1c:	fa840593          	addi	a1,s0,-88
    3f20:	00004517          	auipc	a0,0x4
    3f24:	ba850513          	addi	a0,a0,-1112 # 7ac8 <malloc+0x1e16>
    3f28:	00002097          	auipc	ra,0x2
    3f2c:	ccc080e7          	jalr	-820(ra) # 5bf4 <printf>
        exit(1);
    3f30:	4505                	li	a0,1
    3f32:	00002097          	auipc	ra,0x2
    3f36:	912080e7          	jalr	-1774(ra) # 5844 <exit>
      link("C0", file);
    3f3a:	fa840593          	addi	a1,s0,-88
    3f3e:	00004517          	auipc	a0,0x4
    3f42:	b8250513          	addi	a0,a0,-1150 # 7ac0 <malloc+0x1e0e>
    3f46:	00002097          	auipc	ra,0x2
    3f4a:	95e080e7          	jalr	-1698(ra) # 58a4 <link>
      exit(0);
    3f4e:	4501                	li	a0,0
    3f50:	00002097          	auipc	ra,0x2
    3f54:	8f4080e7          	jalr	-1804(ra) # 5844 <exit>
        exit(1);
    3f58:	4505                	li	a0,1
    3f5a:	00002097          	auipc	ra,0x2
    3f5e:	8ea080e7          	jalr	-1814(ra) # 5844 <exit>
  memset(fa, 0, sizeof(fa));
    3f62:	02800613          	li	a2,40
    3f66:	4581                	li	a1,0
    3f68:	f8040513          	addi	a0,s0,-128
    3f6c:	00001097          	auipc	ra,0x1
    3f70:	6dc080e7          	jalr	1756(ra) # 5648 <memset>
  fd = open(".", 0);
    3f74:	4581                	li	a1,0
    3f76:	00002517          	auipc	a0,0x2
    3f7a:	79250513          	addi	a0,a0,1938 # 6708 <malloc+0xa56>
    3f7e:	00002097          	auipc	ra,0x2
    3f82:	906080e7          	jalr	-1786(ra) # 5884 <open>
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
    3fa0:	8c0080e7          	jalr	-1856(ra) # 585c <read>
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
    3ff0:	afc50513          	addi	a0,a0,-1284 # 7ae8 <malloc+0x1e36>
    3ff4:	00002097          	auipc	ra,0x2
    3ff8:	c00080e7          	jalr	-1024(ra) # 5bf4 <printf>
        exit(1);
    3ffc:	4505                	li	a0,1
    3ffe:	00002097          	auipc	ra,0x2
    4002:	846080e7          	jalr	-1978(ra) # 5844 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    4006:	f7240613          	addi	a2,s0,-142
    400a:	85ce                	mv	a1,s3
    400c:	00004517          	auipc	a0,0x4
    4010:	afc50513          	addi	a0,a0,-1284 # 7b08 <malloc+0x1e56>
    4014:	00002097          	auipc	ra,0x2
    4018:	be0080e7          	jalr	-1056(ra) # 5bf4 <printf>
        exit(1);
    401c:	4505                	li	a0,1
    401e:	00002097          	auipc	ra,0x2
    4022:	826080e7          	jalr	-2010(ra) # 5844 <exit>
  close(fd);
    4026:	854a                	mv	a0,s2
    4028:	00002097          	auipc	ra,0x2
    402c:	844080e7          	jalr	-1980(ra) # 586c <close>
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
    4048:	aec50513          	addi	a0,a0,-1300 # 7b30 <malloc+0x1e7e>
    404c:	00002097          	auipc	ra,0x2
    4050:	ba8080e7          	jalr	-1112(ra) # 5bf4 <printf>
    exit(1);
    4054:	4505                	li	a0,1
    4056:	00001097          	auipc	ra,0x1
    405a:	7ee080e7          	jalr	2030(ra) # 5844 <exit>
      printf("%s: fork failed\n", s);
    405e:	85ce                	mv	a1,s3
    4060:	00002517          	auipc	a0,0x2
    4064:	f9850513          	addi	a0,a0,-104 # 5ff8 <malloc+0x346>
    4068:	00002097          	auipc	ra,0x2
    406c:	b8c080e7          	jalr	-1140(ra) # 5bf4 <printf>
      exit(1);
    4070:	4505                	li	a0,1
    4072:	00001097          	auipc	ra,0x1
    4076:	7d2080e7          	jalr	2002(ra) # 5844 <exit>
      close(open(file, 0));
    407a:	4581                	li	a1,0
    407c:	fa840513          	addi	a0,s0,-88
    4080:	00002097          	auipc	ra,0x2
    4084:	804080e7          	jalr	-2044(ra) # 5884 <open>
    4088:	00001097          	auipc	ra,0x1
    408c:	7e4080e7          	jalr	2020(ra) # 586c <close>
      close(open(file, 0));
    4090:	4581                	li	a1,0
    4092:	fa840513          	addi	a0,s0,-88
    4096:	00001097          	auipc	ra,0x1
    409a:	7ee080e7          	jalr	2030(ra) # 5884 <open>
    409e:	00001097          	auipc	ra,0x1
    40a2:	7ce080e7          	jalr	1998(ra) # 586c <close>
      close(open(file, 0));
    40a6:	4581                	li	a1,0
    40a8:	fa840513          	addi	a0,s0,-88
    40ac:	00001097          	auipc	ra,0x1
    40b0:	7d8080e7          	jalr	2008(ra) # 5884 <open>
    40b4:	00001097          	auipc	ra,0x1
    40b8:	7b8080e7          	jalr	1976(ra) # 586c <close>
      close(open(file, 0));
    40bc:	4581                	li	a1,0
    40be:	fa840513          	addi	a0,s0,-88
    40c2:	00001097          	auipc	ra,0x1
    40c6:	7c2080e7          	jalr	1986(ra) # 5884 <open>
    40ca:	00001097          	auipc	ra,0x1
    40ce:	7a2080e7          	jalr	1954(ra) # 586c <close>
      close(open(file, 0));
    40d2:	4581                	li	a1,0
    40d4:	fa840513          	addi	a0,s0,-88
    40d8:	00001097          	auipc	ra,0x1
    40dc:	7ac080e7          	jalr	1964(ra) # 5884 <open>
    40e0:	00001097          	auipc	ra,0x1
    40e4:	78c080e7          	jalr	1932(ra) # 586c <close>
      close(open(file, 0));
    40e8:	4581                	li	a1,0
    40ea:	fa840513          	addi	a0,s0,-88
    40ee:	00001097          	auipc	ra,0x1
    40f2:	796080e7          	jalr	1942(ra) # 5884 <open>
    40f6:	00001097          	auipc	ra,0x1
    40fa:	776080e7          	jalr	1910(ra) # 586c <close>
    if(pid == 0)
    40fe:	08090363          	beqz	s2,4184 <concreate+0x2d0>
      wait(0);
    4102:	4501                	li	a0,0
    4104:	00001097          	auipc	ra,0x1
    4108:	748080e7          	jalr	1864(ra) # 584c <wait>
  for(i = 0; i < N; i++){
    410c:	2485                	addiw	s1,s1,1
    410e:	0f448563          	beq	s1,s4,41f8 <concreate+0x344>
    file[1] = '0' + i;
    4112:	0304879b          	addiw	a5,s1,48
    4116:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    411a:	00001097          	auipc	ra,0x1
    411e:	722080e7          	jalr	1826(ra) # 583c <fork>
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
    4142:	756080e7          	jalr	1878(ra) # 5894 <unlink>
      unlink(file);
    4146:	fa840513          	addi	a0,s0,-88
    414a:	00001097          	auipc	ra,0x1
    414e:	74a080e7          	jalr	1866(ra) # 5894 <unlink>
      unlink(file);
    4152:	fa840513          	addi	a0,s0,-88
    4156:	00001097          	auipc	ra,0x1
    415a:	73e080e7          	jalr	1854(ra) # 5894 <unlink>
      unlink(file);
    415e:	fa840513          	addi	a0,s0,-88
    4162:	00001097          	auipc	ra,0x1
    4166:	732080e7          	jalr	1842(ra) # 5894 <unlink>
      unlink(file);
    416a:	fa840513          	addi	a0,s0,-88
    416e:	00001097          	auipc	ra,0x1
    4172:	726080e7          	jalr	1830(ra) # 5894 <unlink>
      unlink(file);
    4176:	fa840513          	addi	a0,s0,-88
    417a:	00001097          	auipc	ra,0x1
    417e:	71a080e7          	jalr	1818(ra) # 5894 <unlink>
    4182:	bfb5                	j	40fe <concreate+0x24a>
      exit(0);
    4184:	4501                	li	a0,0
    4186:	00001097          	auipc	ra,0x1
    418a:	6be080e7          	jalr	1726(ra) # 5844 <exit>
      close(fd);
    418e:	00001097          	auipc	ra,0x1
    4192:	6de080e7          	jalr	1758(ra) # 586c <close>
    if(pid == 0) {
    4196:	bb65                	j	3f4e <concreate+0x9a>
      close(fd);
    4198:	00001097          	auipc	ra,0x1
    419c:	6d4080e7          	jalr	1748(ra) # 586c <close>
      wait(&xstatus);
    41a0:	f6c40513          	addi	a0,s0,-148
    41a4:	00001097          	auipc	ra,0x1
    41a8:	6a8080e7          	jalr	1704(ra) # 584c <wait>
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
    41ca:	6ce080e7          	jalr	1742(ra) # 5894 <unlink>
    pid = fork();
    41ce:	00001097          	auipc	ra,0x1
    41d2:	66e080e7          	jalr	1646(ra) # 583c <fork>
    if(pid && (i % 3) == 1){
    41d6:	d20503e3          	beqz	a0,3efc <concreate+0x48>
    41da:	036967bb          	remw	a5,s2,s6
    41de:	d15787e3          	beq	a5,s5,3eec <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    41e2:	20200593          	li	a1,514
    41e6:	fa840513          	addi	a0,s0,-88
    41ea:	00001097          	auipc	ra,0x1
    41ee:	69a080e7          	jalr	1690(ra) # 5884 <open>
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
    422e:	fb650513          	addi	a0,a0,-74 # 61e0 <malloc+0x52e>
    4232:	00001097          	auipc	ra,0x1
    4236:	662080e7          	jalr	1634(ra) # 5894 <unlink>
  pid = fork();
    423a:	00001097          	auipc	ra,0x1
    423e:	602080e7          	jalr	1538(ra) # 583c <fork>
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
    426a:	f7aa8a93          	addi	s5,s5,-134 # 61e0 <malloc+0x52e>
      link("cat", "x");
    426e:	00004b97          	auipc	s7,0x4
    4272:	8fab8b93          	addi	s7,s7,-1798 # 7b68 <malloc+0x1eb6>
    4276:	a825                	j	42ae <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    4278:	85a6                	mv	a1,s1
    427a:	00002517          	auipc	a0,0x2
    427e:	d7e50513          	addi	a0,a0,-642 # 5ff8 <malloc+0x346>
    4282:	00002097          	auipc	ra,0x2
    4286:	972080e7          	jalr	-1678(ra) # 5bf4 <printf>
    exit(1);
    428a:	4505                	li	a0,1
    428c:	00001097          	auipc	ra,0x1
    4290:	5b8080e7          	jalr	1464(ra) # 5844 <exit>
      close(open("x", O_RDWR | O_CREATE));
    4294:	20200593          	li	a1,514
    4298:	8556                	mv	a0,s5
    429a:	00001097          	auipc	ra,0x1
    429e:	5ea080e7          	jalr	1514(ra) # 5884 <open>
    42a2:	00001097          	auipc	ra,0x1
    42a6:	5ca080e7          	jalr	1482(ra) # 586c <close>
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
    42ca:	5ce080e7          	jalr	1486(ra) # 5894 <unlink>
    42ce:	bff1                	j	42aa <linkunlink+0x9c>
      link("cat", "x");
    42d0:	85d6                	mv	a1,s5
    42d2:	855e                	mv	a0,s7
    42d4:	00001097          	auipc	ra,0x1
    42d8:	5d0080e7          	jalr	1488(ra) # 58a4 <link>
    42dc:	b7f9                	j	42aa <linkunlink+0x9c>
  if(pid)
    42de:	020c0463          	beqz	s8,4306 <linkunlink+0xf8>
    wait(0);
    42e2:	4501                	li	a0,0
    42e4:	00001097          	auipc	ra,0x1
    42e8:	568080e7          	jalr	1384(ra) # 584c <wait>
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
    430c:	53c080e7          	jalr	1340(ra) # 5844 <exit>

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
    432a:	84a50513          	addi	a0,a0,-1974 # 7b70 <malloc+0x1ebe>
    432e:	00001097          	auipc	ra,0x1
    4332:	566080e7          	jalr	1382(ra) # 5894 <unlink>
  fd = open("bd", O_CREATE);
    4336:	20000593          	li	a1,512
    433a:	00004517          	auipc	a0,0x4
    433e:	83650513          	addi	a0,a0,-1994 # 7b70 <malloc+0x1ebe>
    4342:	00001097          	auipc	ra,0x1
    4346:	542080e7          	jalr	1346(ra) # 5884 <open>
  if(fd < 0){
    434a:	0c054963          	bltz	a0,441c <bigdir+0x10c>
  close(fd);
    434e:	00001097          	auipc	ra,0x1
    4352:	51e080e7          	jalr	1310(ra) # 586c <close>
  for(i = 0; i < N; i++){
    4356:	4901                	li	s2,0
    name[0] = 'x';
    4358:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
    435c:	00004a17          	auipc	s4,0x4
    4360:	814a0a13          	addi	s4,s4,-2028 # 7b70 <malloc+0x1ebe>
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
    43a0:	508080e7          	jalr	1288(ra) # 58a4 <link>
    43a4:	84aa                	mv	s1,a0
    43a6:	e949                	bnez	a0,4438 <bigdir+0x128>
  for(i = 0; i < N; i++){
    43a8:	2905                	addiw	s2,s2,1
    43aa:	fb691fe3          	bne	s2,s6,4368 <bigdir+0x58>
  unlink("bd");
    43ae:	00003517          	auipc	a0,0x3
    43b2:	7c250513          	addi	a0,a0,1986 # 7b70 <malloc+0x1ebe>
    43b6:	00001097          	auipc	ra,0x1
    43ba:	4de080e7          	jalr	1246(ra) # 5894 <unlink>
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
    43fc:	49c080e7          	jalr	1180(ra) # 5894 <unlink>
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
    4422:	75a50513          	addi	a0,a0,1882 # 7b78 <malloc+0x1ec6>
    4426:	00001097          	auipc	ra,0x1
    442a:	7ce080e7          	jalr	1998(ra) # 5bf4 <printf>
    exit(1);
    442e:	4505                	li	a0,1
    4430:	00001097          	auipc	ra,0x1
    4434:	414080e7          	jalr	1044(ra) # 5844 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    4438:	fb040613          	addi	a2,s0,-80
    443c:	85ce                	mv	a1,s3
    443e:	00003517          	auipc	a0,0x3
    4442:	75a50513          	addi	a0,a0,1882 # 7b98 <malloc+0x1ee6>
    4446:	00001097          	auipc	ra,0x1
    444a:	7ae080e7          	jalr	1966(ra) # 5bf4 <printf>
      exit(1);
    444e:	4505                	li	a0,1
    4450:	00001097          	auipc	ra,0x1
    4454:	3f4080e7          	jalr	1012(ra) # 5844 <exit>
      printf("%s: bigdir unlink failed", s);
    4458:	85ce                	mv	a1,s3
    445a:	00003517          	auipc	a0,0x3
    445e:	75e50513          	addi	a0,a0,1886 # 7bb8 <malloc+0x1f06>
    4462:	00001097          	auipc	ra,0x1
    4466:	792080e7          	jalr	1938(ra) # 5bf4 <printf>
      exit(1);
    446a:	4505                	li	a0,1
    446c:	00001097          	auipc	ra,0x1
    4470:	3d8080e7          	jalr	984(ra) # 5844 <exit>

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
    4494:	3ac080e7          	jalr	940(ra) # 583c <fork>
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
    44b4:	39c080e7          	jalr	924(ra) # 584c <wait>
    if(st != 0)
    44b8:	fa842503          	lw	a0,-88(s0)
    44bc:	ed6d                	bnez	a0,45b6 <manywrites+0x142>
  for(int ci = 0; ci < nchildren; ci++){
    44be:	34fd                	addiw	s1,s1,-1
    44c0:	f4e5                	bnez	s1,44a8 <manywrites+0x34>
  exit(0);
    44c2:	4501                	li	a0,0
    44c4:	00001097          	auipc	ra,0x1
    44c8:	380080e7          	jalr	896(ra) # 5844 <exit>
      printf("fork failed\n");
    44cc:	00002517          	auipc	a0,0x2
    44d0:	52450513          	addi	a0,a0,1316 # 69f0 <malloc+0xd3e>
    44d4:	00001097          	auipc	ra,0x1
    44d8:	720080e7          	jalr	1824(ra) # 5bf4 <printf>
      exit(1);
    44dc:	4505                	li	a0,1
    44de:	00001097          	auipc	ra,0x1
    44e2:	366080e7          	jalr	870(ra) # 5844 <exit>
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
    4502:	396080e7          	jalr	918(ra) # 5894 <unlink>
    4506:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    4508:	00007b17          	auipc	s6,0x7
    450c:	6b8b0b13          	addi	s6,s6,1720 # bbc0 <buf>
        for(int i = 0; i < ci+1; i++){
    4510:	8a26                	mv	s4,s1
    4512:	0209ce63          	bltz	s3,454e <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    4516:	20200593          	li	a1,514
    451a:	fa840513          	addi	a0,s0,-88
    451e:	00001097          	auipc	ra,0x1
    4522:	366080e7          	jalr	870(ra) # 5884 <open>
    4526:	892a                	mv	s2,a0
          if(fd < 0){
    4528:	04054763          	bltz	a0,4576 <manywrites+0x102>
          int cc = write(fd, buf, sz);
    452c:	660d                	lui	a2,0x3
    452e:	85da                	mv	a1,s6
    4530:	00001097          	auipc	ra,0x1
    4534:	334080e7          	jalr	820(ra) # 5864 <write>
          if(cc != sz){
    4538:	678d                	lui	a5,0x3
    453a:	04f51e63          	bne	a0,a5,4596 <manywrites+0x122>
          close(fd);
    453e:	854a                	mv	a0,s2
    4540:	00001097          	auipc	ra,0x1
    4544:	32c080e7          	jalr	812(ra) # 586c <close>
        for(int i = 0; i < ci+1; i++){
    4548:	2a05                	addiw	s4,s4,1
    454a:	fd49d6e3          	bge	s3,s4,4516 <manywrites+0xa2>
        unlink(name);
    454e:	fa840513          	addi	a0,s0,-88
    4552:	00001097          	auipc	ra,0x1
    4556:	342080e7          	jalr	834(ra) # 5894 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    455a:	3bfd                	addiw	s7,s7,-1
    455c:	fa0b9ae3          	bnez	s7,4510 <manywrites+0x9c>
      unlink(name);
    4560:	fa840513          	addi	a0,s0,-88
    4564:	00001097          	auipc	ra,0x1
    4568:	330080e7          	jalr	816(ra) # 5894 <unlink>
      exit(0);
    456c:	4501                	li	a0,0
    456e:	00001097          	auipc	ra,0x1
    4572:	2d6080e7          	jalr	726(ra) # 5844 <exit>
            printf("%s: cannot create %s\n", s, name);
    4576:	fa840613          	addi	a2,s0,-88
    457a:	85d6                	mv	a1,s5
    457c:	00003517          	auipc	a0,0x3
    4580:	65c50513          	addi	a0,a0,1628 # 7bd8 <malloc+0x1f26>
    4584:	00001097          	auipc	ra,0x1
    4588:	670080e7          	jalr	1648(ra) # 5bf4 <printf>
            exit(1);
    458c:	4505                	li	a0,1
    458e:	00001097          	auipc	ra,0x1
    4592:	2b6080e7          	jalr	694(ra) # 5844 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    4596:	86aa                	mv	a3,a0
    4598:	660d                	lui	a2,0x3
    459a:	85d6                	mv	a1,s5
    459c:	00002517          	auipc	a0,0x2
    45a0:	ca450513          	addi	a0,a0,-860 # 6240 <malloc+0x58e>
    45a4:	00001097          	auipc	ra,0x1
    45a8:	650080e7          	jalr	1616(ra) # 5bf4 <printf>
            exit(1);
    45ac:	4505                	li	a0,1
    45ae:	00001097          	auipc	ra,0x1
    45b2:	296080e7          	jalr	662(ra) # 5844 <exit>
      exit(st);
    45b6:	00001097          	auipc	ra,0x1
    45ba:	28e080e7          	jalr	654(ra) # 5844 <exit>

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
    45dc:	618a0a13          	addi	s4,s4,1560 # 7bf0 <malloc+0x1f3e>
    mkdir("");
    45e0:	00003497          	auipc	s1,0x3
    45e4:	b5048493          	addi	s1,s1,-1200 # 7130 <malloc+0x147e>
    link("README", "");
    45e8:	00002a97          	auipc	s5,0x2
    45ec:	d30a8a93          	addi	s5,s5,-720 # 6318 <malloc+0x666>
    fd = open("xx", O_CREATE);
    45f0:	00003997          	auipc	s3,0x3
    45f4:	f2898993          	addi	s3,s3,-216 # 7518 <malloc+0x1866>
    45f8:	a891                	j	464c <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    45fa:	85da                	mv	a1,s6
    45fc:	00003517          	auipc	a0,0x3
    4600:	5fc50513          	addi	a0,a0,1532 # 7bf8 <malloc+0x1f46>
    4604:	00001097          	auipc	ra,0x1
    4608:	5f0080e7          	jalr	1520(ra) # 5bf4 <printf>
      exit(1);
    460c:	4505                	li	a0,1
    460e:	00001097          	auipc	ra,0x1
    4612:	236080e7          	jalr	566(ra) # 5844 <exit>
      printf("%s: chdir irefd failed\n", s);
    4616:	85da                	mv	a1,s6
    4618:	00003517          	auipc	a0,0x3
    461c:	5f850513          	addi	a0,a0,1528 # 7c10 <malloc+0x1f5e>
    4620:	00001097          	auipc	ra,0x1
    4624:	5d4080e7          	jalr	1492(ra) # 5bf4 <printf>
      exit(1);
    4628:	4505                	li	a0,1
    462a:	00001097          	auipc	ra,0x1
    462e:	21a080e7          	jalr	538(ra) # 5844 <exit>
      close(fd);
    4632:	00001097          	auipc	ra,0x1
    4636:	23a080e7          	jalr	570(ra) # 586c <close>
    463a:	a889                	j	468c <iref+0xce>
    unlink("xx");
    463c:	854e                	mv	a0,s3
    463e:	00001097          	auipc	ra,0x1
    4642:	256080e7          	jalr	598(ra) # 5894 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    4646:	397d                	addiw	s2,s2,-1
    4648:	06090063          	beqz	s2,46a8 <iref+0xea>
    if(mkdir("irefd") != 0){
    464c:	8552                	mv	a0,s4
    464e:	00001097          	auipc	ra,0x1
    4652:	25e080e7          	jalr	606(ra) # 58ac <mkdir>
    4656:	f155                	bnez	a0,45fa <iref+0x3c>
    if(chdir("irefd") != 0){
    4658:	8552                	mv	a0,s4
    465a:	00001097          	auipc	ra,0x1
    465e:	25a080e7          	jalr	602(ra) # 58b4 <chdir>
    4662:	f955                	bnez	a0,4616 <iref+0x58>
    mkdir("");
    4664:	8526                	mv	a0,s1
    4666:	00001097          	auipc	ra,0x1
    466a:	246080e7          	jalr	582(ra) # 58ac <mkdir>
    link("README", "");
    466e:	85a6                	mv	a1,s1
    4670:	8556                	mv	a0,s5
    4672:	00001097          	auipc	ra,0x1
    4676:	232080e7          	jalr	562(ra) # 58a4 <link>
    fd = open("", O_CREATE);
    467a:	20000593          	li	a1,512
    467e:	8526                	mv	a0,s1
    4680:	00001097          	auipc	ra,0x1
    4684:	204080e7          	jalr	516(ra) # 5884 <open>
    if(fd >= 0)
    4688:	fa0555e3          	bgez	a0,4632 <iref+0x74>
    fd = open("xx", O_CREATE);
    468c:	20000593          	li	a1,512
    4690:	854e                	mv	a0,s3
    4692:	00001097          	auipc	ra,0x1
    4696:	1f2080e7          	jalr	498(ra) # 5884 <open>
    if(fd >= 0)
    469a:	fa0541e3          	bltz	a0,463c <iref+0x7e>
      close(fd);
    469e:	00001097          	auipc	ra,0x1
    46a2:	1ce080e7          	jalr	462(ra) # 586c <close>
    46a6:	bf59                	j	463c <iref+0x7e>
    46a8:	03300493          	li	s1,51
    chdir("..");
    46ac:	00002997          	auipc	s3,0x2
    46b0:	7a498993          	addi	s3,s3,1956 # 6e50 <malloc+0x119e>
    unlink("irefd");
    46b4:	00003917          	auipc	s2,0x3
    46b8:	53c90913          	addi	s2,s2,1340 # 7bf0 <malloc+0x1f3e>
    chdir("..");
    46bc:	854e                	mv	a0,s3
    46be:	00001097          	auipc	ra,0x1
    46c2:	1f6080e7          	jalr	502(ra) # 58b4 <chdir>
    unlink("irefd");
    46c6:	854a                	mv	a0,s2
    46c8:	00001097          	auipc	ra,0x1
    46cc:	1cc080e7          	jalr	460(ra) # 5894 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    46d0:	34fd                	addiw	s1,s1,-1
    46d2:	f4ed                	bnez	s1,46bc <iref+0xfe>
  chdir("/");
    46d4:	00002517          	auipc	a0,0x2
    46d8:	72450513          	addi	a0,a0,1828 # 6df8 <malloc+0x1146>
    46dc:	00001097          	auipc	ra,0x1
    46e0:	1d8080e7          	jalr	472(ra) # 58b4 <chdir>
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
    470e:	132080e7          	jalr	306(ra) # 583c <fork>
  if(pid < 0){
    4712:	02054c63          	bltz	a0,474a <sbrkbasic+0x52>
  if(pid == 0){
    4716:	ed21                	bnez	a0,476e <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    4718:	40000537          	lui	a0,0x40000
    471c:	00001097          	auipc	ra,0x1
    4720:	1b0080e7          	jalr	432(ra) # 58cc <sbrk>
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
    4736:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff1430>
    for(b = a; b < a+TOOMUCH; b += 4096){
    473a:	953a                	add	a0,a0,a4
    473c:	fef51de3          	bne	a0,a5,4736 <sbrkbasic+0x3e>
    exit(1);
    4740:	4505                	li	a0,1
    4742:	00001097          	auipc	ra,0x1
    4746:	102080e7          	jalr	258(ra) # 5844 <exit>
    printf("fork failed in sbrkbasic\n");
    474a:	00003517          	auipc	a0,0x3
    474e:	4de50513          	addi	a0,a0,1246 # 7c28 <malloc+0x1f76>
    4752:	00001097          	auipc	ra,0x1
    4756:	4a2080e7          	jalr	1186(ra) # 5bf4 <printf>
    exit(1);
    475a:	4505                	li	a0,1
    475c:	00001097          	auipc	ra,0x1
    4760:	0e8080e7          	jalr	232(ra) # 5844 <exit>
      exit(0);
    4764:	4501                	li	a0,0
    4766:	00001097          	auipc	ra,0x1
    476a:	0de080e7          	jalr	222(ra) # 5844 <exit>
  wait(&xstatus);
    476e:	fcc40513          	addi	a0,s0,-52
    4772:	00001097          	auipc	ra,0x1
    4776:	0da080e7          	jalr	218(ra) # 584c <wait>
  if(xstatus == 1){
    477a:	fcc42703          	lw	a4,-52(s0)
    477e:	4785                	li	a5,1
    4780:	00f70d63          	beq	a4,a5,479a <sbrkbasic+0xa2>
  a = sbrk(0);
    4784:	4501                	li	a0,0
    4786:	00001097          	auipc	ra,0x1
    478a:	146080e7          	jalr	326(ra) # 58cc <sbrk>
    478e:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    4790:	4901                	li	s2,0
    4792:	6985                	lui	s3,0x1
    4794:	38898993          	addi	s3,s3,904 # 1388 <linktest+0x202>
    4798:	a005                	j	47b8 <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
    479a:	85d2                	mv	a1,s4
    479c:	00003517          	auipc	a0,0x3
    47a0:	4ac50513          	addi	a0,a0,1196 # 7c48 <malloc+0x1f96>
    47a4:	00001097          	auipc	ra,0x1
    47a8:	450080e7          	jalr	1104(ra) # 5bf4 <printf>
    exit(1);
    47ac:	4505                	li	a0,1
    47ae:	00001097          	auipc	ra,0x1
    47b2:	096080e7          	jalr	150(ra) # 5844 <exit>
    a = b + 1;
    47b6:	84be                	mv	s1,a5
    b = sbrk(1);
    47b8:	4505                	li	a0,1
    47ba:	00001097          	auipc	ra,0x1
    47be:	112080e7          	jalr	274(ra) # 58cc <sbrk>
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
    47da:	066080e7          	jalr	102(ra) # 583c <fork>
    47de:	892a                	mv	s2,a0
  if(pid < 0){
    47e0:	04054d63          	bltz	a0,483a <sbrkbasic+0x142>
  c = sbrk(1);
    47e4:	4505                	li	a0,1
    47e6:	00001097          	auipc	ra,0x1
    47ea:	0e6080e7          	jalr	230(ra) # 58cc <sbrk>
  c = sbrk(1);
    47ee:	4505                	li	a0,1
    47f0:	00001097          	auipc	ra,0x1
    47f4:	0dc080e7          	jalr	220(ra) # 58cc <sbrk>
  if(c != a + 1){
    47f8:	0489                	addi	s1,s1,2
    47fa:	04a48e63          	beq	s1,a0,4856 <sbrkbasic+0x15e>
    printf("%s: sbrk test failed post-fork\n", s);
    47fe:	85d2                	mv	a1,s4
    4800:	00003517          	auipc	a0,0x3
    4804:	4a850513          	addi	a0,a0,1192 # 7ca8 <malloc+0x1ff6>
    4808:	00001097          	auipc	ra,0x1
    480c:	3ec080e7          	jalr	1004(ra) # 5bf4 <printf>
    exit(1);
    4810:	4505                	li	a0,1
    4812:	00001097          	auipc	ra,0x1
    4816:	032080e7          	jalr	50(ra) # 5844 <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    481a:	86aa                	mv	a3,a0
    481c:	8626                	mv	a2,s1
    481e:	85ca                	mv	a1,s2
    4820:	00003517          	auipc	a0,0x3
    4824:	44850513          	addi	a0,a0,1096 # 7c68 <malloc+0x1fb6>
    4828:	00001097          	auipc	ra,0x1
    482c:	3cc080e7          	jalr	972(ra) # 5bf4 <printf>
      exit(1);
    4830:	4505                	li	a0,1
    4832:	00001097          	auipc	ra,0x1
    4836:	012080e7          	jalr	18(ra) # 5844 <exit>
    printf("%s: sbrk test fork failed\n", s);
    483a:	85d2                	mv	a1,s4
    483c:	00003517          	auipc	a0,0x3
    4840:	44c50513          	addi	a0,a0,1100 # 7c88 <malloc+0x1fd6>
    4844:	00001097          	auipc	ra,0x1
    4848:	3b0080e7          	jalr	944(ra) # 5bf4 <printf>
    exit(1);
    484c:	4505                	li	a0,1
    484e:	00001097          	auipc	ra,0x1
    4852:	ff6080e7          	jalr	-10(ra) # 5844 <exit>
  if(pid == 0)
    4856:	00091763          	bnez	s2,4864 <sbrkbasic+0x16c>
    exit(0);
    485a:	4501                	li	a0,0
    485c:	00001097          	auipc	ra,0x1
    4860:	fe8080e7          	jalr	-24(ra) # 5844 <exit>
  wait(&xstatus);
    4864:	fcc40513          	addi	a0,s0,-52
    4868:	00001097          	auipc	ra,0x1
    486c:	fe4080e7          	jalr	-28(ra) # 584c <wait>
  exit(xstatus);
    4870:	fcc42503          	lw	a0,-52(s0)
    4874:	00001097          	auipc	ra,0x1
    4878:	fd0080e7          	jalr	-48(ra) # 5844 <exit>

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
    4894:	03c080e7          	jalr	60(ra) # 58cc <sbrk>
    4898:	892a                	mv	s2,a0
  a = sbrk(0);
    489a:	4501                	li	a0,0
    489c:	00001097          	auipc	ra,0x1
    48a0:	030080e7          	jalr	48(ra) # 58cc <sbrk>
    48a4:	84aa                	mv	s1,a0
  p = sbrk(amt);
    48a6:	06400537          	lui	a0,0x6400
    48aa:	9d05                	subw	a0,a0,s1
    48ac:	00001097          	auipc	ra,0x1
    48b0:	020080e7          	jalr	32(ra) # 58cc <sbrk>
  if (p != a) {
    48b4:	0ca49863          	bne	s1,a0,4984 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    48b8:	4501                	li	a0,0
    48ba:	00001097          	auipc	ra,0x1
    48be:	012080e7          	jalr	18(ra) # 58cc <sbrk>
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
    48de:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f142f>
  a = sbrk(0);
    48e2:	4501                	li	a0,0
    48e4:	00001097          	auipc	ra,0x1
    48e8:	fe8080e7          	jalr	-24(ra) # 58cc <sbrk>
    48ec:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    48ee:	757d                	lui	a0,0xfffff
    48f0:	00001097          	auipc	ra,0x1
    48f4:	fdc080e7          	jalr	-36(ra) # 58cc <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    48f8:	57fd                	li	a5,-1
    48fa:	0af50363          	beq	a0,a5,49a0 <sbrkmuch+0x124>
  c = sbrk(0);
    48fe:	4501                	li	a0,0
    4900:	00001097          	auipc	ra,0x1
    4904:	fcc080e7          	jalr	-52(ra) # 58cc <sbrk>
  if(c != a - PGSIZE){
    4908:	77fd                	lui	a5,0xfffff
    490a:	97a6                	add	a5,a5,s1
    490c:	0af51863          	bne	a0,a5,49bc <sbrkmuch+0x140>
  a = sbrk(0);
    4910:	4501                	li	a0,0
    4912:	00001097          	auipc	ra,0x1
    4916:	fba080e7          	jalr	-70(ra) # 58cc <sbrk>
    491a:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    491c:	6505                	lui	a0,0x1
    491e:	00001097          	auipc	ra,0x1
    4922:	fae080e7          	jalr	-82(ra) # 58cc <sbrk>
    4926:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    4928:	0aa49a63          	bne	s1,a0,49dc <sbrkmuch+0x160>
    492c:	4501                	li	a0,0
    492e:	00001097          	auipc	ra,0x1
    4932:	f9e080e7          	jalr	-98(ra) # 58cc <sbrk>
    4936:	6785                	lui	a5,0x1
    4938:	97a6                	add	a5,a5,s1
    493a:	0af51163          	bne	a0,a5,49dc <sbrkmuch+0x160>
  if(*lastaddr == 99){
    493e:	064007b7          	lui	a5,0x6400
    4942:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f142f>
    4946:	06300793          	li	a5,99
    494a:	0af70963          	beq	a4,a5,49fc <sbrkmuch+0x180>
  a = sbrk(0);
    494e:	4501                	li	a0,0
    4950:	00001097          	auipc	ra,0x1
    4954:	f7c080e7          	jalr	-132(ra) # 58cc <sbrk>
    4958:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    495a:	4501                	li	a0,0
    495c:	00001097          	auipc	ra,0x1
    4960:	f70080e7          	jalr	-144(ra) # 58cc <sbrk>
    4964:	40a9053b          	subw	a0,s2,a0
    4968:	00001097          	auipc	ra,0x1
    496c:	f64080e7          	jalr	-156(ra) # 58cc <sbrk>
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
    498a:	34250513          	addi	a0,a0,834 # 7cc8 <malloc+0x2016>
    498e:	00001097          	auipc	ra,0x1
    4992:	266080e7          	jalr	614(ra) # 5bf4 <printf>
    exit(1);
    4996:	4505                	li	a0,1
    4998:	00001097          	auipc	ra,0x1
    499c:	eac080e7          	jalr	-340(ra) # 5844 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    49a0:	85ce                	mv	a1,s3
    49a2:	00003517          	auipc	a0,0x3
    49a6:	36e50513          	addi	a0,a0,878 # 7d10 <malloc+0x205e>
    49aa:	00001097          	auipc	ra,0x1
    49ae:	24a080e7          	jalr	586(ra) # 5bf4 <printf>
    exit(1);
    49b2:	4505                	li	a0,1
    49b4:	00001097          	auipc	ra,0x1
    49b8:	e90080e7          	jalr	-368(ra) # 5844 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    49bc:	86aa                	mv	a3,a0
    49be:	8626                	mv	a2,s1
    49c0:	85ce                	mv	a1,s3
    49c2:	00003517          	auipc	a0,0x3
    49c6:	36e50513          	addi	a0,a0,878 # 7d30 <malloc+0x207e>
    49ca:	00001097          	auipc	ra,0x1
    49ce:	22a080e7          	jalr	554(ra) # 5bf4 <printf>
    exit(1);
    49d2:	4505                	li	a0,1
    49d4:	00001097          	auipc	ra,0x1
    49d8:	e70080e7          	jalr	-400(ra) # 5844 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    49dc:	86d2                	mv	a3,s4
    49de:	8626                	mv	a2,s1
    49e0:	85ce                	mv	a1,s3
    49e2:	00003517          	auipc	a0,0x3
    49e6:	38e50513          	addi	a0,a0,910 # 7d70 <malloc+0x20be>
    49ea:	00001097          	auipc	ra,0x1
    49ee:	20a080e7          	jalr	522(ra) # 5bf4 <printf>
    exit(1);
    49f2:	4505                	li	a0,1
    49f4:	00001097          	auipc	ra,0x1
    49f8:	e50080e7          	jalr	-432(ra) # 5844 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    49fc:	85ce                	mv	a1,s3
    49fe:	00003517          	auipc	a0,0x3
    4a02:	3a250513          	addi	a0,a0,930 # 7da0 <malloc+0x20ee>
    4a06:	00001097          	auipc	ra,0x1
    4a0a:	1ee080e7          	jalr	494(ra) # 5bf4 <printf>
    exit(1);
    4a0e:	4505                	li	a0,1
    4a10:	00001097          	auipc	ra,0x1
    4a14:	e34080e7          	jalr	-460(ra) # 5844 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    4a18:	86aa                	mv	a3,a0
    4a1a:	8626                	mv	a2,s1
    4a1c:	85ce                	mv	a1,s3
    4a1e:	00003517          	auipc	a0,0x3
    4a22:	3ba50513          	addi	a0,a0,954 # 7dd8 <malloc+0x2126>
    4a26:	00001097          	auipc	ra,0x1
    4a2a:	1ce080e7          	jalr	462(ra) # 5bf4 <printf>
    exit(1);
    4a2e:	4505                	li	a0,1
    4a30:	00001097          	auipc	ra,0x1
    4a34:	e14080e7          	jalr	-492(ra) # 5844 <exit>

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
    4a54:	35098993          	addi	s3,s3,848 # c350 <buf+0x790>
    4a58:	1003d937          	lui	s2,0x1003d
    4a5c:	090e                	slli	s2,s2,0x3
    4a5e:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002e8b0>
    pid = fork();
    4a62:	00001097          	auipc	ra,0x1
    4a66:	dda080e7          	jalr	-550(ra) # 583c <fork>
    if(pid < 0){
    4a6a:	02054963          	bltz	a0,4a9c <kernmem+0x64>
    if(pid == 0){
    4a6e:	c529                	beqz	a0,4ab8 <kernmem+0x80>
    wait(&xstatus);
    4a70:	fbc40513          	addi	a0,s0,-68
    4a74:	00001097          	auipc	ra,0x1
    4a78:	dd8080e7          	jalr	-552(ra) # 584c <wait>
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
    4aa2:	55a50513          	addi	a0,a0,1370 # 5ff8 <malloc+0x346>
    4aa6:	00001097          	auipc	ra,0x1
    4aaa:	14e080e7          	jalr	334(ra) # 5bf4 <printf>
      exit(1);
    4aae:	4505                	li	a0,1
    4ab0:	00001097          	auipc	ra,0x1
    4ab4:	d94080e7          	jalr	-620(ra) # 5844 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    4ab8:	0004c683          	lbu	a3,0(s1)
    4abc:	8626                	mv	a2,s1
    4abe:	85d2                	mv	a1,s4
    4ac0:	00003517          	auipc	a0,0x3
    4ac4:	34050513          	addi	a0,a0,832 # 7e00 <malloc+0x214e>
    4ac8:	00001097          	auipc	ra,0x1
    4acc:	12c080e7          	jalr	300(ra) # 5bf4 <printf>
      exit(1);
    4ad0:	4505                	li	a0,1
    4ad2:	00001097          	auipc	ra,0x1
    4ad6:	d72080e7          	jalr	-654(ra) # 5844 <exit>
      exit(1);
    4ada:	4505                	li	a0,1
    4adc:	00001097          	auipc	ra,0x1
    4ae0:	d68080e7          	jalr	-664(ra) # 5844 <exit>

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
    4b00:	d58080e7          	jalr	-680(ra) # 5854 <pipe>
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
    4b1a:	94250513          	addi	a0,a0,-1726 # 6458 <malloc+0x7a6>
    4b1e:	00001097          	auipc	ra,0x1
    4b22:	0d6080e7          	jalr	214(ra) # 5bf4 <printf>
    exit(1);
    4b26:	4505                	li	a0,1
    4b28:	00001097          	auipc	ra,0x1
    4b2c:	d1c080e7          	jalr	-740(ra) # 5844 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    4b30:	00001097          	auipc	ra,0x1
    4b34:	d9c080e7          	jalr	-612(ra) # 58cc <sbrk>
    4b38:	064007b7          	lui	a5,0x6400
    4b3c:	40a7853b          	subw	a0,a5,a0
    4b40:	00001097          	auipc	ra,0x1
    4b44:	d8c080e7          	jalr	-628(ra) # 58cc <sbrk>
      write(fds[1], "x", 1);
    4b48:	4605                	li	a2,1
    4b4a:	00001597          	auipc	a1,0x1
    4b4e:	69658593          	addi	a1,a1,1686 # 61e0 <malloc+0x52e>
    4b52:	fb442503          	lw	a0,-76(s0)
    4b56:	00001097          	auipc	ra,0x1
    4b5a:	d0e080e7          	jalr	-754(ra) # 5864 <write>
      for(;;) sleep(1000);
    4b5e:	3e800513          	li	a0,1000
    4b62:	00001097          	auipc	ra,0x1
    4b66:	d72080e7          	jalr	-654(ra) # 58d4 <sleep>
    4b6a:	bfd5                	j	4b5e <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4b6c:	0911                	addi	s2,s2,4
    4b6e:	03390563          	beq	s2,s3,4b98 <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    4b72:	00001097          	auipc	ra,0x1
    4b76:	cca080e7          	jalr	-822(ra) # 583c <fork>
    4b7a:	00a92023          	sw	a0,0(s2)
    4b7e:	d94d                	beqz	a0,4b30 <sbrkfail+0x4c>
    if(pids[i] != -1)
    4b80:	ff4506e3          	beq	a0,s4,4b6c <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    4b84:	4605                	li	a2,1
    4b86:	faf40593          	addi	a1,s0,-81
    4b8a:	fb042503          	lw	a0,-80(s0)
    4b8e:	00001097          	auipc	ra,0x1
    4b92:	cce080e7          	jalr	-818(ra) # 585c <read>
    4b96:	bfd9                	j	4b6c <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    4b98:	6505                	lui	a0,0x1
    4b9a:	00001097          	auipc	ra,0x1
    4b9e:	d32080e7          	jalr	-718(ra) # 58cc <sbrk>
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
    4bba:	cbe080e7          	jalr	-834(ra) # 5874 <kill>
    wait(0);
    4bbe:	4501                	li	a0,0
    4bc0:	00001097          	auipc	ra,0x1
    4bc4:	c8c080e7          	jalr	-884(ra) # 584c <wait>
    4bc8:	b7c5                	j	4ba8 <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    4bca:	57fd                	li	a5,-1
    4bcc:	04fa0163          	beq	s4,a5,4c0e <sbrkfail+0x12a>
  pid = fork();
    4bd0:	00001097          	auipc	ra,0x1
    4bd4:	c6c080e7          	jalr	-916(ra) # 583c <fork>
    4bd8:	84aa                	mv	s1,a0
  if(pid < 0){
    4bda:	04054863          	bltz	a0,4c2a <sbrkfail+0x146>
  if(pid == 0){
    4bde:	c525                	beqz	a0,4c46 <sbrkfail+0x162>
  wait(&xstatus);
    4be0:	fbc40513          	addi	a0,s0,-68
    4be4:	00001097          	auipc	ra,0x1
    4be8:	c68080e7          	jalr	-920(ra) # 584c <wait>
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
    4c14:	21050513          	addi	a0,a0,528 # 7e20 <malloc+0x216e>
    4c18:	00001097          	auipc	ra,0x1
    4c1c:	fdc080e7          	jalr	-36(ra) # 5bf4 <printf>
    exit(1);
    4c20:	4505                	li	a0,1
    4c22:	00001097          	auipc	ra,0x1
    4c26:	c22080e7          	jalr	-990(ra) # 5844 <exit>
    printf("%s: fork failed\n", s);
    4c2a:	85d6                	mv	a1,s5
    4c2c:	00001517          	auipc	a0,0x1
    4c30:	3cc50513          	addi	a0,a0,972 # 5ff8 <malloc+0x346>
    4c34:	00001097          	auipc	ra,0x1
    4c38:	fc0080e7          	jalr	-64(ra) # 5bf4 <printf>
    exit(1);
    4c3c:	4505                	li	a0,1
    4c3e:	00001097          	auipc	ra,0x1
    4c42:	c06080e7          	jalr	-1018(ra) # 5844 <exit>
    a = sbrk(0);
    4c46:	4501                	li	a0,0
    4c48:	00001097          	auipc	ra,0x1
    4c4c:	c84080e7          	jalr	-892(ra) # 58cc <sbrk>
    4c50:	892a                	mv	s2,a0
    sbrk(10*BIG);
    4c52:	3e800537          	lui	a0,0x3e800
    4c56:	00001097          	auipc	ra,0x1
    4c5a:	c76080e7          	jalr	-906(ra) # 58cc <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4c5e:	87ca                	mv	a5,s2
    4c60:	3e800737          	lui	a4,0x3e800
    4c64:	993a                	add	s2,s2,a4
    4c66:	6705                	lui	a4,0x1
      n += *(a+i);
    4c68:	0007c683          	lbu	a3,0(a5) # 6400000 <__BSS_END__+0x63f1430>
    4c6c:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4c6e:	97ba                	add	a5,a5,a4
    4c70:	ff279ce3          	bne	a5,s2,4c68 <sbrkfail+0x184>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    4c74:	8626                	mv	a2,s1
    4c76:	85d6                	mv	a1,s5
    4c78:	00003517          	auipc	a0,0x3
    4c7c:	1c850513          	addi	a0,a0,456 # 7e40 <malloc+0x218e>
    4c80:	00001097          	auipc	ra,0x1
    4c84:	f74080e7          	jalr	-140(ra) # 5bf4 <printf>
    exit(1);
    4c88:	4505                	li	a0,1
    4c8a:	00001097          	auipc	ra,0x1
    4c8e:	bba080e7          	jalr	-1094(ra) # 5844 <exit>
    exit(1);
    4c92:	4505                	li	a0,1
    4c94:	00001097          	auipc	ra,0x1
    4c98:	bb0080e7          	jalr	-1104(ra) # 5844 <exit>

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
    4cbe:	1b650513          	addi	a0,a0,438 # 7e70 <malloc+0x21be>
    4cc2:	00001097          	auipc	ra,0x1
    4cc6:	f32080e7          	jalr	-206(ra) # 5bf4 <printf>
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
    4cde:	1a6c8c93          	addi	s9,s9,422 # 7e80 <malloc+0x21ce>
    int total = 0;
    4ce2:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4ce4:	00007a17          	auipc	s4,0x7
    4ce8:	edca0a13          	addi	s4,s4,-292 # bbc0 <buf>
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
    4d36:	ec2080e7          	jalr	-318(ra) # 5bf4 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4d3a:	20200593          	li	a1,514
    4d3e:	f5040513          	addi	a0,s0,-176
    4d42:	00001097          	auipc	ra,0x1
    4d46:	b42080e7          	jalr	-1214(ra) # 5884 <open>
    4d4a:	892a                	mv	s2,a0
    if(fd < 0){
    4d4c:	0a055663          	bgez	a0,4df8 <fsfull+0x15c>
      printf("open %s failed\n", name);
    4d50:	f5040593          	addi	a1,s0,-176
    4d54:	00003517          	auipc	a0,0x3
    4d58:	13c50513          	addi	a0,a0,316 # 7e90 <malloc+0x21de>
    4d5c:	00001097          	auipc	ra,0x1
    4d60:	e98080e7          	jalr	-360(ra) # 5bf4 <printf>
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
    4dc0:	ad8080e7          	jalr	-1320(ra) # 5894 <unlink>
    nfiles--;
    4dc4:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4dc6:	fb5499e3          	bne	s1,s5,4d78 <fsfull+0xdc>
  printf("fsfull test finished\n");
    4dca:	00003517          	auipc	a0,0x3
    4dce:	0e650513          	addi	a0,a0,230 # 7eb0 <malloc+0x21fe>
    4dd2:	00001097          	auipc	ra,0x1
    4dd6:	e22080e7          	jalr	-478(ra) # 5bf4 <printf>
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
    4e0a:	a5e080e7          	jalr	-1442(ra) # 5864 <write>
      if(cc < BSIZE)
    4e0e:	00aad563          	bge	s5,a0,4e18 <fsfull+0x17c>
      total += cc;
    4e12:	00a989bb          	addw	s3,s3,a0
    while(1){
    4e16:	b7e5                	j	4dfe <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    4e18:	85ce                	mv	a1,s3
    4e1a:	00003517          	auipc	a0,0x3
    4e1e:	08650513          	addi	a0,a0,134 # 7ea0 <malloc+0x21ee>
    4e22:	00001097          	auipc	ra,0x1
    4e26:	dd2080e7          	jalr	-558(ra) # 5bf4 <printf>
    close(fd);
    4e2a:	854a                	mv	a0,s2
    4e2c:	00001097          	auipc	ra,0x1
    4e30:	a40080e7          	jalr	-1472(ra) # 586c <close>
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
    4e46:	54e70713          	addi	a4,a4,1358 # 8390 <randstate>
    4e4a:	6308                	ld	a0,0(a4)
    4e4c:	001967b7          	lui	a5,0x196
    4e50:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x187a3d>
    4e54:	02f50533          	mul	a0,a0,a5
    4e58:	3c6ef7b7          	lui	a5,0x3c6ef
    4e5c:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e078f>
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
    4e7c:	9c4080e7          	jalr	-1596(ra) # 583c <fork>
  if(pid == 0) {
    4e80:	c115                	beqz	a0,4ea4 <stacktest+0x38>
  } else if(pid < 0){
    4e82:	04054463          	bltz	a0,4eca <stacktest+0x5e>
  wait(&xstatus);
    4e86:	fdc40513          	addi	a0,s0,-36
    4e8a:	00001097          	auipc	ra,0x1
    4e8e:	9c2080e7          	jalr	-1598(ra) # 584c <wait>
  if(xstatus == -1)  // kernel killed child?
    4e92:	fdc42503          	lw	a0,-36(s0)
    4e96:	57fd                	li	a5,-1
    4e98:	04f50763          	beq	a0,a5,4ee6 <stacktest+0x7a>
    exit(xstatus);
    4e9c:	00001097          	auipc	ra,0x1
    4ea0:	9a8080e7          	jalr	-1624(ra) # 5844 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    4ea4:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    4ea6:	77fd                	lui	a5,0xfffff
    4ea8:	97ba                	add	a5,a5,a4
    4eaa:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff0430>
    4eae:	85a6                	mv	a1,s1
    4eb0:	00003517          	auipc	a0,0x3
    4eb4:	01850513          	addi	a0,a0,24 # 7ec8 <malloc+0x2216>
    4eb8:	00001097          	auipc	ra,0x1
    4ebc:	d3c080e7          	jalr	-708(ra) # 5bf4 <printf>
    exit(1);
    4ec0:	4505                	li	a0,1
    4ec2:	00001097          	auipc	ra,0x1
    4ec6:	982080e7          	jalr	-1662(ra) # 5844 <exit>
    printf("%s: fork failed\n", s);
    4eca:	85a6                	mv	a1,s1
    4ecc:	00001517          	auipc	a0,0x1
    4ed0:	12c50513          	addi	a0,a0,300 # 5ff8 <malloc+0x346>
    4ed4:	00001097          	auipc	ra,0x1
    4ed8:	d20080e7          	jalr	-736(ra) # 5bf4 <printf>
    exit(1);
    4edc:	4505                	li	a0,1
    4ede:	00001097          	auipc	ra,0x1
    4ee2:	966080e7          	jalr	-1690(ra) # 5844 <exit>
    exit(0);
    4ee6:	4501                	li	a0,0
    4ee8:	00001097          	auipc	ra,0x1
    4eec:	95c080e7          	jalr	-1700(ra) # 5844 <exit>

0000000000004ef0 <sbrkbugs>:
{
    4ef0:	1141                	addi	sp,sp,-16
    4ef2:	e406                	sd	ra,8(sp)
    4ef4:	e022                	sd	s0,0(sp)
    4ef6:	0800                	addi	s0,sp,16
  int pid = fork();
    4ef8:	00001097          	auipc	ra,0x1
    4efc:	944080e7          	jalr	-1724(ra) # 583c <fork>
  if(pid < 0){
    4f00:	02054263          	bltz	a0,4f24 <sbrkbugs+0x34>
  if(pid == 0){
    4f04:	ed0d                	bnez	a0,4f3e <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    4f06:	00001097          	auipc	ra,0x1
    4f0a:	9c6080e7          	jalr	-1594(ra) # 58cc <sbrk>
    sbrk(-sz);
    4f0e:	40a0053b          	negw	a0,a0
    4f12:	00001097          	auipc	ra,0x1
    4f16:	9ba080e7          	jalr	-1606(ra) # 58cc <sbrk>
    exit(0);
    4f1a:	4501                	li	a0,0
    4f1c:	00001097          	auipc	ra,0x1
    4f20:	928080e7          	jalr	-1752(ra) # 5844 <exit>
    printf("fork failed\n");
    4f24:	00002517          	auipc	a0,0x2
    4f28:	acc50513          	addi	a0,a0,-1332 # 69f0 <malloc+0xd3e>
    4f2c:	00001097          	auipc	ra,0x1
    4f30:	cc8080e7          	jalr	-824(ra) # 5bf4 <printf>
    exit(1);
    4f34:	4505                	li	a0,1
    4f36:	00001097          	auipc	ra,0x1
    4f3a:	90e080e7          	jalr	-1778(ra) # 5844 <exit>
  wait(0);
    4f3e:	4501                	li	a0,0
    4f40:	00001097          	auipc	ra,0x1
    4f44:	90c080e7          	jalr	-1780(ra) # 584c <wait>
  pid = fork();
    4f48:	00001097          	auipc	ra,0x1
    4f4c:	8f4080e7          	jalr	-1804(ra) # 583c <fork>
  if(pid < 0){
    4f50:	02054563          	bltz	a0,4f7a <sbrkbugs+0x8a>
  if(pid == 0){
    4f54:	e121                	bnez	a0,4f94 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    4f56:	00001097          	auipc	ra,0x1
    4f5a:	976080e7          	jalr	-1674(ra) # 58cc <sbrk>
    sbrk(-(sz - 3500));
    4f5e:	6785                	lui	a5,0x1
    4f60:	dac7879b          	addiw	a5,a5,-596
    4f64:	40a7853b          	subw	a0,a5,a0
    4f68:	00001097          	auipc	ra,0x1
    4f6c:	964080e7          	jalr	-1692(ra) # 58cc <sbrk>
    exit(0);
    4f70:	4501                	li	a0,0
    4f72:	00001097          	auipc	ra,0x1
    4f76:	8d2080e7          	jalr	-1838(ra) # 5844 <exit>
    printf("fork failed\n");
    4f7a:	00002517          	auipc	a0,0x2
    4f7e:	a7650513          	addi	a0,a0,-1418 # 69f0 <malloc+0xd3e>
    4f82:	00001097          	auipc	ra,0x1
    4f86:	c72080e7          	jalr	-910(ra) # 5bf4 <printf>
    exit(1);
    4f8a:	4505                	li	a0,1
    4f8c:	00001097          	auipc	ra,0x1
    4f90:	8b8080e7          	jalr	-1864(ra) # 5844 <exit>
  wait(0);
    4f94:	4501                	li	a0,0
    4f96:	00001097          	auipc	ra,0x1
    4f9a:	8b6080e7          	jalr	-1866(ra) # 584c <wait>
  pid = fork();
    4f9e:	00001097          	auipc	ra,0x1
    4fa2:	89e080e7          	jalr	-1890(ra) # 583c <fork>
  if(pid < 0){
    4fa6:	02054a63          	bltz	a0,4fda <sbrkbugs+0xea>
  if(pid == 0){
    4faa:	e529                	bnez	a0,4ff4 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    4fac:	00001097          	auipc	ra,0x1
    4fb0:	920080e7          	jalr	-1760(ra) # 58cc <sbrk>
    4fb4:	67ad                	lui	a5,0xb
    4fb6:	8007879b          	addiw	a5,a5,-2048
    4fba:	40a7853b          	subw	a0,a5,a0
    4fbe:	00001097          	auipc	ra,0x1
    4fc2:	90e080e7          	jalr	-1778(ra) # 58cc <sbrk>
    sbrk(-10);
    4fc6:	5559                	li	a0,-10
    4fc8:	00001097          	auipc	ra,0x1
    4fcc:	904080e7          	jalr	-1788(ra) # 58cc <sbrk>
    exit(0);
    4fd0:	4501                	li	a0,0
    4fd2:	00001097          	auipc	ra,0x1
    4fd6:	872080e7          	jalr	-1934(ra) # 5844 <exit>
    printf("fork failed\n");
    4fda:	00002517          	auipc	a0,0x2
    4fde:	a1650513          	addi	a0,a0,-1514 # 69f0 <malloc+0xd3e>
    4fe2:	00001097          	auipc	ra,0x1
    4fe6:	c12080e7          	jalr	-1006(ra) # 5bf4 <printf>
    exit(1);
    4fea:	4505                	li	a0,1
    4fec:	00001097          	auipc	ra,0x1
    4ff0:	858080e7          	jalr	-1960(ra) # 5844 <exit>
  wait(0);
    4ff4:	4501                	li	a0,0
    4ff6:	00001097          	auipc	ra,0x1
    4ffa:	856080e7          	jalr	-1962(ra) # 584c <wait>
  exit(0);
    4ffe:	4501                	li	a0,0
    5000:	00001097          	auipc	ra,0x1
    5004:	844080e7          	jalr	-1980(ra) # 5844 <exit>

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
    501c:	ed850513          	addi	a0,a0,-296 # 7ef0 <malloc+0x223e>
    5020:	00001097          	auipc	ra,0x1
    5024:	874080e7          	jalr	-1932(ra) # 5894 <unlink>
    5028:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    502c:	00003997          	auipc	s3,0x3
    5030:	ec498993          	addi	s3,s3,-316 # 7ef0 <malloc+0x223e>
    write(fd, (char*)0xffffffffffL, 1);
    5034:	5a7d                	li	s4,-1
    5036:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    503a:	20100593          	li	a1,513
    503e:	854e                	mv	a0,s3
    5040:	00001097          	auipc	ra,0x1
    5044:	844080e7          	jalr	-1980(ra) # 5884 <open>
    5048:	84aa                	mv	s1,a0
    if(fd < 0){
    504a:	06054b63          	bltz	a0,50c0 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    504e:	4605                	li	a2,1
    5050:	85d2                	mv	a1,s4
    5052:	00001097          	auipc	ra,0x1
    5056:	812080e7          	jalr	-2030(ra) # 5864 <write>
    close(fd);
    505a:	8526                	mv	a0,s1
    505c:	00001097          	auipc	ra,0x1
    5060:	810080e7          	jalr	-2032(ra) # 586c <close>
    unlink("junk");
    5064:	854e                	mv	a0,s3
    5066:	00001097          	auipc	ra,0x1
    506a:	82e080e7          	jalr	-2002(ra) # 5894 <unlink>
  for(int i = 0; i < assumed_free; i++){
    506e:	397d                	addiw	s2,s2,-1
    5070:	fc0915e3          	bnez	s2,503a <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    5074:	20100593          	li	a1,513
    5078:	00003517          	auipc	a0,0x3
    507c:	e7850513          	addi	a0,a0,-392 # 7ef0 <malloc+0x223e>
    5080:	00001097          	auipc	ra,0x1
    5084:	804080e7          	jalr	-2044(ra) # 5884 <open>
    5088:	84aa                	mv	s1,a0
  if(fd < 0){
    508a:	04054863          	bltz	a0,50da <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    508e:	4605                	li	a2,1
    5090:	00001597          	auipc	a1,0x1
    5094:	15058593          	addi	a1,a1,336 # 61e0 <malloc+0x52e>
    5098:	00000097          	auipc	ra,0x0
    509c:	7cc080e7          	jalr	1996(ra) # 5864 <write>
    50a0:	4785                	li	a5,1
    50a2:	04f50963          	beq	a0,a5,50f4 <badwrite+0xec>
    printf("write failed\n");
    50a6:	00003517          	auipc	a0,0x3
    50aa:	e6a50513          	addi	a0,a0,-406 # 7f10 <malloc+0x225e>
    50ae:	00001097          	auipc	ra,0x1
    50b2:	b46080e7          	jalr	-1210(ra) # 5bf4 <printf>
    exit(1);
    50b6:	4505                	li	a0,1
    50b8:	00000097          	auipc	ra,0x0
    50bc:	78c080e7          	jalr	1932(ra) # 5844 <exit>
      printf("open junk failed\n");
    50c0:	00003517          	auipc	a0,0x3
    50c4:	e3850513          	addi	a0,a0,-456 # 7ef8 <malloc+0x2246>
    50c8:	00001097          	auipc	ra,0x1
    50cc:	b2c080e7          	jalr	-1236(ra) # 5bf4 <printf>
      exit(1);
    50d0:	4505                	li	a0,1
    50d2:	00000097          	auipc	ra,0x0
    50d6:	772080e7          	jalr	1906(ra) # 5844 <exit>
    printf("open junk failed\n");
    50da:	00003517          	auipc	a0,0x3
    50de:	e1e50513          	addi	a0,a0,-482 # 7ef8 <malloc+0x2246>
    50e2:	00001097          	auipc	ra,0x1
    50e6:	b12080e7          	jalr	-1262(ra) # 5bf4 <printf>
    exit(1);
    50ea:	4505                	li	a0,1
    50ec:	00000097          	auipc	ra,0x0
    50f0:	758080e7          	jalr	1880(ra) # 5844 <exit>
  close(fd);
    50f4:	8526                	mv	a0,s1
    50f6:	00000097          	auipc	ra,0x0
    50fa:	776080e7          	jalr	1910(ra) # 586c <close>
  unlink("junk");
    50fe:	00003517          	auipc	a0,0x3
    5102:	df250513          	addi	a0,a0,-526 # 7ef0 <malloc+0x223e>
    5106:	00000097          	auipc	ra,0x0
    510a:	78e080e7          	jalr	1934(ra) # 5894 <unlink>
  exit(0);
    510e:	4501                	li	a0,0
    5110:	00000097          	auipc	ra,0x0
    5114:	734080e7          	jalr	1844(ra) # 5844 <exit>

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
    5130:	710080e7          	jalr	1808(ra) # 583c <fork>
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
    5142:	70e080e7          	jalr	1806(ra) # 584c <wait>
  for(int avail = 0; avail < 15; avail++){
    5146:	2905                	addiw	s2,s2,1
    5148:	ff3912e3          	bne	s2,s3,512c <execout+0x14>
    }
  }

  exit(0);
    514c:	4501                	li	a0,0
    514e:	00000097          	auipc	ra,0x0
    5152:	6f6080e7          	jalr	1782(ra) # 5844 <exit>
      printf("fork failed\n");
    5156:	00002517          	auipc	a0,0x2
    515a:	89a50513          	addi	a0,a0,-1894 # 69f0 <malloc+0xd3e>
    515e:	00001097          	auipc	ra,0x1
    5162:	a96080e7          	jalr	-1386(ra) # 5bf4 <printf>
      exit(1);
    5166:	4505                	li	a0,1
    5168:	00000097          	auipc	ra,0x0
    516c:	6dc080e7          	jalr	1756(ra) # 5844 <exit>
        if(a == 0xffffffffffffffffLL)
    5170:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    5172:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    5174:	6505                	lui	a0,0x1
    5176:	00000097          	auipc	ra,0x0
    517a:	756080e7          	jalr	1878(ra) # 58cc <sbrk>
        if(a == 0xffffffffffffffffLL)
    517e:	01350763          	beq	a0,s3,518c <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    5182:	6785                	lui	a5,0x1
    5184:	953e                	add	a0,a0,a5
    5186:	ff450fa3          	sb	s4,-1(a0) # fff <unlinkread+0x2f>
      while(1){
    518a:	b7ed                	j	5174 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    518c:	01205a63          	blez	s2,51a0 <execout+0x88>
        sbrk(-4096);
    5190:	757d                	lui	a0,0xfffff
    5192:	00000097          	auipc	ra,0x0
    5196:	73a080e7          	jalr	1850(ra) # 58cc <sbrk>
      for(int i = 0; i < avail; i++)
    519a:	2485                	addiw	s1,s1,1
    519c:	ff249ae3          	bne	s1,s2,5190 <execout+0x78>
      close(1);
    51a0:	4505                	li	a0,1
    51a2:	00000097          	auipc	ra,0x0
    51a6:	6ca080e7          	jalr	1738(ra) # 586c <close>
      char *args[] = { "echo", "x", 0 };
    51aa:	00001517          	auipc	a0,0x1
    51ae:	fc650513          	addi	a0,a0,-58 # 6170 <malloc+0x4be>
    51b2:	faa43c23          	sd	a0,-72(s0)
    51b6:	00001797          	auipc	a5,0x1
    51ba:	02a78793          	addi	a5,a5,42 # 61e0 <malloc+0x52e>
    51be:	fcf43023          	sd	a5,-64(s0)
    51c2:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    51c6:	fb840593          	addi	a1,s0,-72
    51ca:	00000097          	auipc	ra,0x0
    51ce:	6b2080e7          	jalr	1714(ra) # 587c <exec>
      exit(0);
    51d2:	4501                	li	a0,0
    51d4:	00000097          	auipc	ra,0x0
    51d8:	670080e7          	jalr	1648(ra) # 5844 <exit>

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
    51f2:	666080e7          	jalr	1638(ra) # 5854 <pipe>
    51f6:	06054763          	bltz	a0,5264 <countfree+0x88>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    51fa:	00000097          	auipc	ra,0x0
    51fe:	642080e7          	jalr	1602(ra) # 583c <fork>

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
    5210:	660080e7          	jalr	1632(ra) # 586c <close>
    
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
    521c:	fc898993          	addi	s3,s3,-56 # 61e0 <malloc+0x52e>
      uint64 a = (uint64) sbrk(4096);
    5220:	6505                	lui	a0,0x1
    5222:	00000097          	auipc	ra,0x0
    5226:	6aa080e7          	jalr	1706(ra) # 58cc <sbrk>
      if(a == 0xffffffffffffffff){
    522a:	07250763          	beq	a0,s2,5298 <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    522e:	6785                	lui	a5,0x1
    5230:	953e                	add	a0,a0,a5
    5232:	fe950fa3          	sb	s1,-1(a0) # fff <unlinkread+0x2f>
      if(write(fds[1], "x", 1) != 1){
    5236:	8626                	mv	a2,s1
    5238:	85ce                	mv	a1,s3
    523a:	fcc42503          	lw	a0,-52(s0)
    523e:	00000097          	auipc	ra,0x0
    5242:	626080e7          	jalr	1574(ra) # 5864 <write>
    5246:	fc950de3          	beq	a0,s1,5220 <countfree+0x44>
        printf("write() failed in countfree()\n");
    524a:	00003517          	auipc	a0,0x3
    524e:	d1650513          	addi	a0,a0,-746 # 7f60 <malloc+0x22ae>
    5252:	00001097          	auipc	ra,0x1
    5256:	9a2080e7          	jalr	-1630(ra) # 5bf4 <printf>
        exit(1);
    525a:	4505                	li	a0,1
    525c:	00000097          	auipc	ra,0x0
    5260:	5e8080e7          	jalr	1512(ra) # 5844 <exit>
    printf("pipe() failed in countfree()\n");
    5264:	00003517          	auipc	a0,0x3
    5268:	cbc50513          	addi	a0,a0,-836 # 7f20 <malloc+0x226e>
    526c:	00001097          	auipc	ra,0x1
    5270:	988080e7          	jalr	-1656(ra) # 5bf4 <printf>
    exit(1);
    5274:	4505                	li	a0,1
    5276:	00000097          	auipc	ra,0x0
    527a:	5ce080e7          	jalr	1486(ra) # 5844 <exit>
    printf("fork failed in countfree()\n");
    527e:	00003517          	auipc	a0,0x3
    5282:	cc250513          	addi	a0,a0,-830 # 7f40 <malloc+0x228e>
    5286:	00001097          	auipc	ra,0x1
    528a:	96e080e7          	jalr	-1682(ra) # 5bf4 <printf>
    exit(1);
    528e:	4505                	li	a0,1
    5290:	00000097          	auipc	ra,0x0
    5294:	5b4080e7          	jalr	1460(ra) # 5844 <exit>
      }
    }

    exit(0);
    5298:	4501                	li	a0,0
    529a:	00000097          	auipc	ra,0x0
    529e:	5aa080e7          	jalr	1450(ra) # 5844 <exit>
  }

  close(fds[1]);
    52a2:	fcc42503          	lw	a0,-52(s0)
    52a6:	00000097          	auipc	ra,0x0
    52aa:	5c6080e7          	jalr	1478(ra) # 586c <close>

  int n = 0;
    52ae:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    52b0:	4605                	li	a2,1
    52b2:	fc740593          	addi	a1,s0,-57
    52b6:	fc842503          	lw	a0,-56(s0)
    52ba:	00000097          	auipc	ra,0x0
    52be:	5a2080e7          	jalr	1442(ra) # 585c <read>
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
    52d0:	cb450513          	addi	a0,a0,-844 # 7f80 <malloc+0x22ce>
    52d4:	00001097          	auipc	ra,0x1
    52d8:	920080e7          	jalr	-1760(ra) # 5bf4 <printf>
      exit(1);
    52dc:	4505                	li	a0,1
    52de:	00000097          	auipc	ra,0x0
    52e2:	566080e7          	jalr	1382(ra) # 5844 <exit>
  }

  close(fds[0]);
    52e6:	fc842503          	lw	a0,-56(s0)
    52ea:	00000097          	auipc	ra,0x0
    52ee:	582080e7          	jalr	1410(ra) # 586c <close>
  wait((int*)0);
    52f2:	4501                	li	a0,0
    52f4:	00000097          	auipc	ra,0x0
    52f8:	558080e7          	jalr	1368(ra) # 584c <wait>
  
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
    5320:	c8450513          	addi	a0,a0,-892 # 7fa0 <malloc+0x22ee>
    5324:	00001097          	auipc	ra,0x1
    5328:	8d0080e7          	jalr	-1840(ra) # 5bf4 <printf>
  if((pid = fork()) < 0) {
    532c:	00000097          	auipc	ra,0x0
    5330:	510080e7          	jalr	1296(ra) # 583c <fork>
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
    5342:	50e080e7          	jalr	1294(ra) # 584c <wait>
    if(xstatus != 0) 
    5346:	fdc42783          	lw	a5,-36(s0)
    534a:	c7b9                	beqz	a5,5398 <run+0x8c>
      printf("FAILED\n");
    534c:	00003517          	auipc	a0,0x3
    5350:	c7c50513          	addi	a0,a0,-900 # 7fc8 <malloc+0x2316>
    5354:	00001097          	auipc	ra,0x1
    5358:	8a0080e7          	jalr	-1888(ra) # 5bf4 <printf>
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
    5374:	c4050513          	addi	a0,a0,-960 # 7fb0 <malloc+0x22fe>
    5378:	00001097          	auipc	ra,0x1
    537c:	87c080e7          	jalr	-1924(ra) # 5bf4 <printf>
    exit(1);
    5380:	4505                	li	a0,1
    5382:	00000097          	auipc	ra,0x0
    5386:	4c2080e7          	jalr	1218(ra) # 5844 <exit>
    f(s);
    538a:	854a                	mv	a0,s2
    538c:	9482                	jalr	s1
    exit(0);
    538e:	4501                	li	a0,0
    5390:	00000097          	auipc	ra,0x0
    5394:	4b4080e7          	jalr	1204(ra) # 5844 <exit>
      printf("OK\n");
    5398:	00003517          	auipc	a0,0x3
    539c:	c3850513          	addi	a0,a0,-968 # 7fd0 <malloc+0x231e>
    53a0:	00001097          	auipc	ra,0x1
    53a4:	854080e7          	jalr	-1964(ra) # 5bf4 <printf>
    53a8:	bf55                	j	535c <run+0x50>

00000000000053aa <main>:

int
main(int argc, char *argv[])
{
    53aa:	d4010113          	addi	sp,sp,-704
    53ae:	2a113c23          	sd	ra,696(sp)
    53b2:	2a813823          	sd	s0,688(sp)
    53b6:	2a913423          	sd	s1,680(sp)
    53ba:	2b213023          	sd	s2,672(sp)
    53be:	29313c23          	sd	s3,664(sp)
    53c2:	29413823          	sd	s4,656(sp)
    53c6:	29513423          	sd	s5,648(sp)
    53ca:	29613023          	sd	s6,640(sp)
    53ce:	0580                	addi	s0,sp,704
    53d0:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    53d2:	4789                	li	a5,2
    53d4:	08f50763          	beq	a0,a5,5462 <main+0xb8>
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
    53dc:	0ca7c163          	blt	a5,a0,549e <main+0xf4>
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    53e0:	00003797          	auipc	a5,0x3
    53e4:	d0878793          	addi	a5,a5,-760 # 80e8 <malloc+0x2436>
    53e8:	d4040713          	addi	a4,s0,-704
    53ec:	00003817          	auipc	a6,0x3
    53f0:	f7c80813          	addi	a6,a6,-132 # 8368 <malloc+0x26b6>
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
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    5410:	00003517          	auipc	a0,0x3
    5414:	c7850513          	addi	a0,a0,-904 # 8088 <malloc+0x23d6>
    5418:	00000097          	auipc	ra,0x0
    541c:	7dc080e7          	jalr	2012(ra) # 5bf4 <printf>
  int free0 = countfree();
    5420:	00000097          	auipc	ra,0x0
    5424:	dbc080e7          	jalr	-580(ra) # 51dc <countfree>
    5428:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    542a:	d4843503          	ld	a0,-696(s0)
    542e:	d4040493          	addi	s1,s0,-704
  int fail = 0;
    5432:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    5434:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    5436:	e55d                	bnez	a0,54e4 <main+0x13a>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    5438:	00000097          	auipc	ra,0x0
    543c:	da4080e7          	jalr	-604(ra) # 51dc <countfree>
    5440:	85aa                	mv	a1,a0
    5442:	0f455163          	bge	a0,s4,5524 <main+0x17a>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5446:	8652                	mv	a2,s4
    5448:	00003517          	auipc	a0,0x3
    544c:	bf850513          	addi	a0,a0,-1032 # 8040 <malloc+0x238e>
    5450:	00000097          	auipc	ra,0x0
    5454:	7a4080e7          	jalr	1956(ra) # 5bf4 <printf>
    exit(1);
    5458:	4505                	li	a0,1
    545a:	00000097          	auipc	ra,0x0
    545e:	3ea080e7          	jalr	1002(ra) # 5844 <exit>
    5462:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5464:	00003597          	auipc	a1,0x3
    5468:	b7458593          	addi	a1,a1,-1164 # 7fd8 <malloc+0x2326>
    546c:	6488                	ld	a0,8(s1)
    546e:	00000097          	auipc	ra,0x0
    5472:	184080e7          	jalr	388(ra) # 55f2 <strcmp>
    5476:	10050563          	beqz	a0,5580 <main+0x1d6>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    547a:	00003597          	auipc	a1,0x3
    547e:	c4658593          	addi	a1,a1,-954 # 80c0 <malloc+0x240e>
    5482:	6488                	ld	a0,8(s1)
    5484:	00000097          	auipc	ra,0x0
    5488:	16e080e7          	jalr	366(ra) # 55f2 <strcmp>
    548c:	c97d                	beqz	a0,5582 <main+0x1d8>
  } else if(argc == 2 && argv[1][0] != '-'){
    548e:	0084b903          	ld	s2,8(s1)
    5492:	00094703          	lbu	a4,0(s2)
    5496:	02d00793          	li	a5,45
    549a:	f4f713e3          	bne	a4,a5,53e0 <main+0x36>
    printf("Usage: usertests [-c] [testname]\n");
    549e:	00003517          	auipc	a0,0x3
    54a2:	b4250513          	addi	a0,a0,-1214 # 7fe0 <malloc+0x232e>
    54a6:	00000097          	auipc	ra,0x0
    54aa:	74e080e7          	jalr	1870(ra) # 5bf4 <printf>
    exit(1);
    54ae:	4505                	li	a0,1
    54b0:	00000097          	auipc	ra,0x0
    54b4:	394080e7          	jalr	916(ra) # 5844 <exit>
          exit(1);
    54b8:	4505                	li	a0,1
    54ba:	00000097          	auipc	ra,0x0
    54be:	38a080e7          	jalr	906(ra) # 5844 <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    54c2:	40a905bb          	subw	a1,s2,a0
    54c6:	855a                	mv	a0,s6
    54c8:	00000097          	auipc	ra,0x0
    54cc:	72c080e7          	jalr	1836(ra) # 5bf4 <printf>
        if(continuous != 2)
    54d0:	09498463          	beq	s3,s4,5558 <main+0x1ae>
          exit(1);
    54d4:	4505                	li	a0,1
    54d6:	00000097          	auipc	ra,0x0
    54da:	36e080e7          	jalr	878(ra) # 5844 <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    54de:	04c1                	addi	s1,s1,16
    54e0:	6488                	ld	a0,8(s1)
    54e2:	c115                	beqz	a0,5506 <main+0x15c>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    54e4:	00090863          	beqz	s2,54f4 <main+0x14a>
    54e8:	85ca                	mv	a1,s2
    54ea:	00000097          	auipc	ra,0x0
    54ee:	108080e7          	jalr	264(ra) # 55f2 <strcmp>
    54f2:	f575                	bnez	a0,54de <main+0x134>
      if(!run(t->f, t->s))
    54f4:	648c                	ld	a1,8(s1)
    54f6:	6088                	ld	a0,0(s1)
    54f8:	00000097          	auipc	ra,0x0
    54fc:	e14080e7          	jalr	-492(ra) # 530c <run>
    5500:	fd79                	bnez	a0,54de <main+0x134>
        fail = 1;
    5502:	89d6                	mv	s3,s5
    5504:	bfe9                	j	54de <main+0x134>
  if(fail){
    5506:	f20989e3          	beqz	s3,5438 <main+0x8e>
    printf("SOME TESTS FAILED\n");
    550a:	00003517          	auipc	a0,0x3
    550e:	b1e50513          	addi	a0,a0,-1250 # 8028 <malloc+0x2376>
    5512:	00000097          	auipc	ra,0x0
    5516:	6e2080e7          	jalr	1762(ra) # 5bf4 <printf>
    exit(1);
    551a:	4505                	li	a0,1
    551c:	00000097          	auipc	ra,0x0
    5520:	328080e7          	jalr	808(ra) # 5844 <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    5524:	00003517          	auipc	a0,0x3
    5528:	b4c50513          	addi	a0,a0,-1204 # 8070 <malloc+0x23be>
    552c:	00000097          	auipc	ra,0x0
    5530:	6c8080e7          	jalr	1736(ra) # 5bf4 <printf>
    exit(0);
    5534:	4501                	li	a0,0
    5536:	00000097          	auipc	ra,0x0
    553a:	30e080e7          	jalr	782(ra) # 5844 <exit>
        printf("SOME TESTS FAILED\n");
    553e:	8556                	mv	a0,s5
    5540:	00000097          	auipc	ra,0x0
    5544:	6b4080e7          	jalr	1716(ra) # 5bf4 <printf>
        if(continuous != 2)
    5548:	f74998e3          	bne	s3,s4,54b8 <main+0x10e>
      int free1 = countfree();
    554c:	00000097          	auipc	ra,0x0
    5550:	c90080e7          	jalr	-880(ra) # 51dc <countfree>
      if(free1 < free0){
    5554:	f72547e3          	blt	a0,s2,54c2 <main+0x118>
      int free0 = countfree();
    5558:	00000097          	auipc	ra,0x0
    555c:	c84080e7          	jalr	-892(ra) # 51dc <countfree>
    5560:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    5562:	d4843583          	ld	a1,-696(s0)
    5566:	d1fd                	beqz	a1,554c <main+0x1a2>
    5568:	d4040493          	addi	s1,s0,-704
        if(!run(t->f, t->s)){
    556c:	6088                	ld	a0,0(s1)
    556e:	00000097          	auipc	ra,0x0
    5572:	d9e080e7          	jalr	-610(ra) # 530c <run>
    5576:	d561                	beqz	a0,553e <main+0x194>
      for (struct test *t = tests; t->s != 0; t++) {
    5578:	04c1                	addi	s1,s1,16
    557a:	648c                	ld	a1,8(s1)
    557c:	f9e5                	bnez	a1,556c <main+0x1c2>
    557e:	b7f9                	j	554c <main+0x1a2>
    continuous = 1;
    5580:	4985                	li	s3,1
  } tests[] = {
    5582:	00003797          	auipc	a5,0x3
    5586:	b6678793          	addi	a5,a5,-1178 # 80e8 <malloc+0x2436>
    558a:	d4040713          	addi	a4,s0,-704
    558e:	00003817          	auipc	a6,0x3
    5592:	dda80813          	addi	a6,a6,-550 # 8368 <malloc+0x26b6>
    5596:	6388                	ld	a0,0(a5)
    5598:	678c                	ld	a1,8(a5)
    559a:	6b90                	ld	a2,16(a5)
    559c:	6f94                	ld	a3,24(a5)
    559e:	e308                	sd	a0,0(a4)
    55a0:	e70c                	sd	a1,8(a4)
    55a2:	eb10                	sd	a2,16(a4)
    55a4:	ef14                	sd	a3,24(a4)
    55a6:	02078793          	addi	a5,a5,32
    55aa:	02070713          	addi	a4,a4,32
    55ae:	ff0794e3          	bne	a5,a6,5596 <main+0x1ec>
    printf("continuous usertests starting\n");
    55b2:	00003517          	auipc	a0,0x3
    55b6:	aee50513          	addi	a0,a0,-1298 # 80a0 <malloc+0x23ee>
    55ba:	00000097          	auipc	ra,0x0
    55be:	63a080e7          	jalr	1594(ra) # 5bf4 <printf>
        printf("SOME TESTS FAILED\n");
    55c2:	00003a97          	auipc	s5,0x3
    55c6:	a66a8a93          	addi	s5,s5,-1434 # 8028 <malloc+0x2376>
        if(continuous != 2)
    55ca:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    55cc:	00003b17          	auipc	s6,0x3
    55d0:	a3cb0b13          	addi	s6,s6,-1476 # 8008 <malloc+0x2356>
    55d4:	b751                	j	5558 <main+0x1ae>

00000000000055d6 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    55d6:	1141                	addi	sp,sp,-16
    55d8:	e422                	sd	s0,8(sp)
    55da:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    55dc:	87aa                	mv	a5,a0
    55de:	0585                	addi	a1,a1,1
    55e0:	0785                	addi	a5,a5,1
    55e2:	fff5c703          	lbu	a4,-1(a1)
    55e6:	fee78fa3          	sb	a4,-1(a5)
    55ea:	fb75                	bnez	a4,55de <strcpy+0x8>
    ;
  return os;
}
    55ec:	6422                	ld	s0,8(sp)
    55ee:	0141                	addi	sp,sp,16
    55f0:	8082                	ret

00000000000055f2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    55f2:	1141                	addi	sp,sp,-16
    55f4:	e422                	sd	s0,8(sp)
    55f6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    55f8:	00054783          	lbu	a5,0(a0)
    55fc:	cb91                	beqz	a5,5610 <strcmp+0x1e>
    55fe:	0005c703          	lbu	a4,0(a1)
    5602:	00f71763          	bne	a4,a5,5610 <strcmp+0x1e>
    p++, q++;
    5606:	0505                	addi	a0,a0,1
    5608:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    560a:	00054783          	lbu	a5,0(a0)
    560e:	fbe5                	bnez	a5,55fe <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    5610:	0005c503          	lbu	a0,0(a1)
}
    5614:	40a7853b          	subw	a0,a5,a0
    5618:	6422                	ld	s0,8(sp)
    561a:	0141                	addi	sp,sp,16
    561c:	8082                	ret

000000000000561e <strlen>:

uint
strlen(const char *s)
{
    561e:	1141                	addi	sp,sp,-16
    5620:	e422                	sd	s0,8(sp)
    5622:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    5624:	00054783          	lbu	a5,0(a0)
    5628:	cf91                	beqz	a5,5644 <strlen+0x26>
    562a:	0505                	addi	a0,a0,1
    562c:	87aa                	mv	a5,a0
    562e:	4685                	li	a3,1
    5630:	9e89                	subw	a3,a3,a0
    5632:	00f6853b          	addw	a0,a3,a5
    5636:	0785                	addi	a5,a5,1
    5638:	fff7c703          	lbu	a4,-1(a5)
    563c:	fb7d                	bnez	a4,5632 <strlen+0x14>
    ;
  return n;
}
    563e:	6422                	ld	s0,8(sp)
    5640:	0141                	addi	sp,sp,16
    5642:	8082                	ret
  for(n = 0; s[n]; n++)
    5644:	4501                	li	a0,0
    5646:	bfe5                	j	563e <strlen+0x20>

0000000000005648 <memset>:

void*
memset(void *dst, int c, uint n)
{
    5648:	1141                	addi	sp,sp,-16
    564a:	e422                	sd	s0,8(sp)
    564c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    564e:	ca19                	beqz	a2,5664 <memset+0x1c>
    5650:	87aa                	mv	a5,a0
    5652:	1602                	slli	a2,a2,0x20
    5654:	9201                	srli	a2,a2,0x20
    5656:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    565a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    565e:	0785                	addi	a5,a5,1
    5660:	fee79de3          	bne	a5,a4,565a <memset+0x12>
  }
  return dst;
}
    5664:	6422                	ld	s0,8(sp)
    5666:	0141                	addi	sp,sp,16
    5668:	8082                	ret

000000000000566a <strchr>:

char*
strchr(const char *s, char c)
{
    566a:	1141                	addi	sp,sp,-16
    566c:	e422                	sd	s0,8(sp)
    566e:	0800                	addi	s0,sp,16
  for(; *s; s++)
    5670:	00054783          	lbu	a5,0(a0)
    5674:	cb99                	beqz	a5,568a <strchr+0x20>
    if(*s == c)
    5676:	00f58763          	beq	a1,a5,5684 <strchr+0x1a>
  for(; *s; s++)
    567a:	0505                	addi	a0,a0,1
    567c:	00054783          	lbu	a5,0(a0)
    5680:	fbfd                	bnez	a5,5676 <strchr+0xc>
      return (char*)s;
  return 0;
    5682:	4501                	li	a0,0
}
    5684:	6422                	ld	s0,8(sp)
    5686:	0141                	addi	sp,sp,16
    5688:	8082                	ret
  return 0;
    568a:	4501                	li	a0,0
    568c:	bfe5                	j	5684 <strchr+0x1a>

000000000000568e <gets>:

char*
gets(char *buf, int max)
{
    568e:	711d                	addi	sp,sp,-96
    5690:	ec86                	sd	ra,88(sp)
    5692:	e8a2                	sd	s0,80(sp)
    5694:	e4a6                	sd	s1,72(sp)
    5696:	e0ca                	sd	s2,64(sp)
    5698:	fc4e                	sd	s3,56(sp)
    569a:	f852                	sd	s4,48(sp)
    569c:	f456                	sd	s5,40(sp)
    569e:	f05a                	sd	s6,32(sp)
    56a0:	ec5e                	sd	s7,24(sp)
    56a2:	1080                	addi	s0,sp,96
    56a4:	8baa                	mv	s7,a0
    56a6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    56a8:	892a                	mv	s2,a0
    56aa:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    56ac:	4aa9                	li	s5,10
    56ae:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    56b0:	89a6                	mv	s3,s1
    56b2:	2485                	addiw	s1,s1,1
    56b4:	0344d863          	bge	s1,s4,56e4 <gets+0x56>
    cc = read(0, &c, 1);
    56b8:	4605                	li	a2,1
    56ba:	faf40593          	addi	a1,s0,-81
    56be:	4501                	li	a0,0
    56c0:	00000097          	auipc	ra,0x0
    56c4:	19c080e7          	jalr	412(ra) # 585c <read>
    if(cc < 1)
    56c8:	00a05e63          	blez	a0,56e4 <gets+0x56>
    buf[i++] = c;
    56cc:	faf44783          	lbu	a5,-81(s0)
    56d0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    56d4:	01578763          	beq	a5,s5,56e2 <gets+0x54>
    56d8:	0905                	addi	s2,s2,1
    56da:	fd679be3          	bne	a5,s6,56b0 <gets+0x22>
  for(i=0; i+1 < max; ){
    56de:	89a6                	mv	s3,s1
    56e0:	a011                	j	56e4 <gets+0x56>
    56e2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    56e4:	99de                	add	s3,s3,s7
    56e6:	00098023          	sb	zero,0(s3)
  return buf;
}
    56ea:	855e                	mv	a0,s7
    56ec:	60e6                	ld	ra,88(sp)
    56ee:	6446                	ld	s0,80(sp)
    56f0:	64a6                	ld	s1,72(sp)
    56f2:	6906                	ld	s2,64(sp)
    56f4:	79e2                	ld	s3,56(sp)
    56f6:	7a42                	ld	s4,48(sp)
    56f8:	7aa2                	ld	s5,40(sp)
    56fa:	7b02                	ld	s6,32(sp)
    56fc:	6be2                	ld	s7,24(sp)
    56fe:	6125                	addi	sp,sp,96
    5700:	8082                	ret

0000000000005702 <stat>:

int
stat(const char *n, struct stat *st)
{
    5702:	1101                	addi	sp,sp,-32
    5704:	ec06                	sd	ra,24(sp)
    5706:	e822                	sd	s0,16(sp)
    5708:	e426                	sd	s1,8(sp)
    570a:	e04a                	sd	s2,0(sp)
    570c:	1000                	addi	s0,sp,32
    570e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    5710:	4581                	li	a1,0
    5712:	00000097          	auipc	ra,0x0
    5716:	172080e7          	jalr	370(ra) # 5884 <open>
  if(fd < 0)
    571a:	02054563          	bltz	a0,5744 <stat+0x42>
    571e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5720:	85ca                	mv	a1,s2
    5722:	00000097          	auipc	ra,0x0
    5726:	17a080e7          	jalr	378(ra) # 589c <fstat>
    572a:	892a                	mv	s2,a0
  close(fd);
    572c:	8526                	mv	a0,s1
    572e:	00000097          	auipc	ra,0x0
    5732:	13e080e7          	jalr	318(ra) # 586c <close>
  return r;
}
    5736:	854a                	mv	a0,s2
    5738:	60e2                	ld	ra,24(sp)
    573a:	6442                	ld	s0,16(sp)
    573c:	64a2                	ld	s1,8(sp)
    573e:	6902                	ld	s2,0(sp)
    5740:	6105                	addi	sp,sp,32
    5742:	8082                	ret
    return -1;
    5744:	597d                	li	s2,-1
    5746:	bfc5                	j	5736 <stat+0x34>

0000000000005748 <atoi>:

int
atoi(const char *s)
{
    5748:	1141                	addi	sp,sp,-16
    574a:	e422                	sd	s0,8(sp)
    574c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    574e:	00054603          	lbu	a2,0(a0)
    5752:	fd06079b          	addiw	a5,a2,-48
    5756:	0ff7f793          	andi	a5,a5,255
    575a:	4725                	li	a4,9
    575c:	02f76963          	bltu	a4,a5,578e <atoi+0x46>
    5760:	86aa                	mv	a3,a0
  n = 0;
    5762:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    5764:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    5766:	0685                	addi	a3,a3,1
    5768:	0025179b          	slliw	a5,a0,0x2
    576c:	9fa9                	addw	a5,a5,a0
    576e:	0017979b          	slliw	a5,a5,0x1
    5772:	9fb1                	addw	a5,a5,a2
    5774:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5778:	0006c603          	lbu	a2,0(a3)
    577c:	fd06071b          	addiw	a4,a2,-48
    5780:	0ff77713          	andi	a4,a4,255
    5784:	fee5f1e3          	bgeu	a1,a4,5766 <atoi+0x1e>
  return n;
}
    5788:	6422                	ld	s0,8(sp)
    578a:	0141                	addi	sp,sp,16
    578c:	8082                	ret
  n = 0;
    578e:	4501                	li	a0,0
    5790:	bfe5                	j	5788 <atoi+0x40>

0000000000005792 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    5792:	1141                	addi	sp,sp,-16
    5794:	e422                	sd	s0,8(sp)
    5796:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5798:	02b57463          	bgeu	a0,a1,57c0 <memmove+0x2e>
    while(n-- > 0)
    579c:	00c05f63          	blez	a2,57ba <memmove+0x28>
    57a0:	1602                	slli	a2,a2,0x20
    57a2:	9201                	srli	a2,a2,0x20
    57a4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    57a8:	872a                	mv	a4,a0
      *dst++ = *src++;
    57aa:	0585                	addi	a1,a1,1
    57ac:	0705                	addi	a4,a4,1
    57ae:	fff5c683          	lbu	a3,-1(a1)
    57b2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    57b6:	fee79ae3          	bne	a5,a4,57aa <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    57ba:	6422                	ld	s0,8(sp)
    57bc:	0141                	addi	sp,sp,16
    57be:	8082                	ret
    dst += n;
    57c0:	00c50733          	add	a4,a0,a2
    src += n;
    57c4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    57c6:	fec05ae3          	blez	a2,57ba <memmove+0x28>
    57ca:	fff6079b          	addiw	a5,a2,-1
    57ce:	1782                	slli	a5,a5,0x20
    57d0:	9381                	srli	a5,a5,0x20
    57d2:	fff7c793          	not	a5,a5
    57d6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    57d8:	15fd                	addi	a1,a1,-1
    57da:	177d                	addi	a4,a4,-1
    57dc:	0005c683          	lbu	a3,0(a1)
    57e0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    57e4:	fee79ae3          	bne	a5,a4,57d8 <memmove+0x46>
    57e8:	bfc9                	j	57ba <memmove+0x28>

00000000000057ea <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    57ea:	1141                	addi	sp,sp,-16
    57ec:	e422                	sd	s0,8(sp)
    57ee:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    57f0:	ca05                	beqz	a2,5820 <memcmp+0x36>
    57f2:	fff6069b          	addiw	a3,a2,-1
    57f6:	1682                	slli	a3,a3,0x20
    57f8:	9281                	srli	a3,a3,0x20
    57fa:	0685                	addi	a3,a3,1
    57fc:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    57fe:	00054783          	lbu	a5,0(a0)
    5802:	0005c703          	lbu	a4,0(a1)
    5806:	00e79863          	bne	a5,a4,5816 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    580a:	0505                	addi	a0,a0,1
    p2++;
    580c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    580e:	fed518e3          	bne	a0,a3,57fe <memcmp+0x14>
  }
  return 0;
    5812:	4501                	li	a0,0
    5814:	a019                	j	581a <memcmp+0x30>
      return *p1 - *p2;
    5816:	40e7853b          	subw	a0,a5,a4
}
    581a:	6422                	ld	s0,8(sp)
    581c:	0141                	addi	sp,sp,16
    581e:	8082                	ret
  return 0;
    5820:	4501                	li	a0,0
    5822:	bfe5                	j	581a <memcmp+0x30>

0000000000005824 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    5824:	1141                	addi	sp,sp,-16
    5826:	e406                	sd	ra,8(sp)
    5828:	e022                	sd	s0,0(sp)
    582a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    582c:	00000097          	auipc	ra,0x0
    5830:	f66080e7          	jalr	-154(ra) # 5792 <memmove>
}
    5834:	60a2                	ld	ra,8(sp)
    5836:	6402                	ld	s0,0(sp)
    5838:	0141                	addi	sp,sp,16
    583a:	8082                	ret

000000000000583c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    583c:	4885                	li	a7,1
 ecall
    583e:	00000073          	ecall
 ret
    5842:	8082                	ret

0000000000005844 <exit>:
.global exit
exit:
 li a7, SYS_exit
    5844:	4889                	li	a7,2
 ecall
    5846:	00000073          	ecall
 ret
    584a:	8082                	ret

000000000000584c <wait>:
.global wait
wait:
 li a7, SYS_wait
    584c:	488d                	li	a7,3
 ecall
    584e:	00000073          	ecall
 ret
    5852:	8082                	ret

0000000000005854 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5854:	4891                	li	a7,4
 ecall
    5856:	00000073          	ecall
 ret
    585a:	8082                	ret

000000000000585c <read>:
.global read
read:
 li a7, SYS_read
    585c:	4895                	li	a7,5
 ecall
    585e:	00000073          	ecall
 ret
    5862:	8082                	ret

0000000000005864 <write>:
.global write
write:
 li a7, SYS_write
    5864:	48c1                	li	a7,16
 ecall
    5866:	00000073          	ecall
 ret
    586a:	8082                	ret

000000000000586c <close>:
.global close
close:
 li a7, SYS_close
    586c:	48d5                	li	a7,21
 ecall
    586e:	00000073          	ecall
 ret
    5872:	8082                	ret

0000000000005874 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5874:	4899                	li	a7,6
 ecall
    5876:	00000073          	ecall
 ret
    587a:	8082                	ret

000000000000587c <exec>:
.global exec
exec:
 li a7, SYS_exec
    587c:	489d                	li	a7,7
 ecall
    587e:	00000073          	ecall
 ret
    5882:	8082                	ret

0000000000005884 <open>:
.global open
open:
 li a7, SYS_open
    5884:	48bd                	li	a7,15
 ecall
    5886:	00000073          	ecall
 ret
    588a:	8082                	ret

000000000000588c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    588c:	48c5                	li	a7,17
 ecall
    588e:	00000073          	ecall
 ret
    5892:	8082                	ret

0000000000005894 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    5894:	48c9                	li	a7,18
 ecall
    5896:	00000073          	ecall
 ret
    589a:	8082                	ret

000000000000589c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    589c:	48a1                	li	a7,8
 ecall
    589e:	00000073          	ecall
 ret
    58a2:	8082                	ret

00000000000058a4 <link>:
.global link
link:
 li a7, SYS_link
    58a4:	48cd                	li	a7,19
 ecall
    58a6:	00000073          	ecall
 ret
    58aa:	8082                	ret

00000000000058ac <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    58ac:	48d1                	li	a7,20
 ecall
    58ae:	00000073          	ecall
 ret
    58b2:	8082                	ret

00000000000058b4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    58b4:	48a5                	li	a7,9
 ecall
    58b6:	00000073          	ecall
 ret
    58ba:	8082                	ret

00000000000058bc <dup>:
.global dup
dup:
 li a7, SYS_dup
    58bc:	48a9                	li	a7,10
 ecall
    58be:	00000073          	ecall
 ret
    58c2:	8082                	ret

00000000000058c4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    58c4:	48ad                	li	a7,11
 ecall
    58c6:	00000073          	ecall
 ret
    58ca:	8082                	ret

00000000000058cc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    58cc:	48b1                	li	a7,12
 ecall
    58ce:	00000073          	ecall
 ret
    58d2:	8082                	ret

00000000000058d4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    58d4:	48b5                	li	a7,13
 ecall
    58d6:	00000073          	ecall
 ret
    58da:	8082                	ret

00000000000058dc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    58dc:	48b9                	li	a7,14
 ecall
    58de:	00000073          	ecall
 ret
    58e2:	8082                	ret

00000000000058e4 <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
    58e4:	48d9                	li	a7,22
 ecall
    58e6:	00000073          	ecall
 ret
    58ea:	8082                	ret

00000000000058ec <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
    58ec:	48dd                	li	a7,23
 ecall
    58ee:	00000073          	ecall
 ret
    58f2:	8082                	ret

00000000000058f4 <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
    58f4:	48e1                	li	a7,24
 ecall
    58f6:	00000073          	ecall
 ret
    58fa:	8082                	ret

00000000000058fc <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
    58fc:	48e5                	li	a7,25
 ecall
    58fe:	00000073          	ecall
 ret
    5902:	8082                	ret

0000000000005904 <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
    5904:	48e9                	li	a7,26
 ecall
    5906:	00000073          	ecall
 ret
    590a:	8082                	ret

000000000000590c <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
    590c:	48ed                	li	a7,27
 ecall
    590e:	00000073          	ecall
 ret
    5912:	8082                	ret

0000000000005914 <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
    5914:	48f1                	li	a7,28
 ecall
    5916:	00000073          	ecall
 ret
    591a:	8082                	ret

000000000000591c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    591c:	1101                	addi	sp,sp,-32
    591e:	ec06                	sd	ra,24(sp)
    5920:	e822                	sd	s0,16(sp)
    5922:	1000                	addi	s0,sp,32
    5924:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5928:	4605                	li	a2,1
    592a:	fef40593          	addi	a1,s0,-17
    592e:	00000097          	auipc	ra,0x0
    5932:	f36080e7          	jalr	-202(ra) # 5864 <write>
}
    5936:	60e2                	ld	ra,24(sp)
    5938:	6442                	ld	s0,16(sp)
    593a:	6105                	addi	sp,sp,32
    593c:	8082                	ret

000000000000593e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    593e:	7139                	addi	sp,sp,-64
    5940:	fc06                	sd	ra,56(sp)
    5942:	f822                	sd	s0,48(sp)
    5944:	f426                	sd	s1,40(sp)
    5946:	f04a                	sd	s2,32(sp)
    5948:	ec4e                	sd	s3,24(sp)
    594a:	0080                	addi	s0,sp,64
    594c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    594e:	c299                	beqz	a3,5954 <printint+0x16>
    5950:	0805c863          	bltz	a1,59e0 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    5954:	2581                	sext.w	a1,a1
  neg = 0;
    5956:	4881                	li	a7,0
    5958:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    595c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    595e:	2601                	sext.w	a2,a2
    5960:	00003517          	auipc	a0,0x3
    5964:	a1050513          	addi	a0,a0,-1520 # 8370 <digits>
    5968:	883a                	mv	a6,a4
    596a:	2705                	addiw	a4,a4,1
    596c:	02c5f7bb          	remuw	a5,a1,a2
    5970:	1782                	slli	a5,a5,0x20
    5972:	9381                	srli	a5,a5,0x20
    5974:	97aa                	add	a5,a5,a0
    5976:	0007c783          	lbu	a5,0(a5)
    597a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    597e:	0005879b          	sext.w	a5,a1
    5982:	02c5d5bb          	divuw	a1,a1,a2
    5986:	0685                	addi	a3,a3,1
    5988:	fec7f0e3          	bgeu	a5,a2,5968 <printint+0x2a>
  if(neg)
    598c:	00088b63          	beqz	a7,59a2 <printint+0x64>
    buf[i++] = '-';
    5990:	fd040793          	addi	a5,s0,-48
    5994:	973e                	add	a4,a4,a5
    5996:	02d00793          	li	a5,45
    599a:	fef70823          	sb	a5,-16(a4)
    599e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    59a2:	02e05863          	blez	a4,59d2 <printint+0x94>
    59a6:	fc040793          	addi	a5,s0,-64
    59aa:	00e78933          	add	s2,a5,a4
    59ae:	fff78993          	addi	s3,a5,-1
    59b2:	99ba                	add	s3,s3,a4
    59b4:	377d                	addiw	a4,a4,-1
    59b6:	1702                	slli	a4,a4,0x20
    59b8:	9301                	srli	a4,a4,0x20
    59ba:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    59be:	fff94583          	lbu	a1,-1(s2)
    59c2:	8526                	mv	a0,s1
    59c4:	00000097          	auipc	ra,0x0
    59c8:	f58080e7          	jalr	-168(ra) # 591c <putc>
  while(--i >= 0)
    59cc:	197d                	addi	s2,s2,-1
    59ce:	ff3918e3          	bne	s2,s3,59be <printint+0x80>
}
    59d2:	70e2                	ld	ra,56(sp)
    59d4:	7442                	ld	s0,48(sp)
    59d6:	74a2                	ld	s1,40(sp)
    59d8:	7902                	ld	s2,32(sp)
    59da:	69e2                	ld	s3,24(sp)
    59dc:	6121                	addi	sp,sp,64
    59de:	8082                	ret
    x = -xx;
    59e0:	40b005bb          	negw	a1,a1
    neg = 1;
    59e4:	4885                	li	a7,1
    x = -xx;
    59e6:	bf8d                	j	5958 <printint+0x1a>

00000000000059e8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    59e8:	7119                	addi	sp,sp,-128
    59ea:	fc86                	sd	ra,120(sp)
    59ec:	f8a2                	sd	s0,112(sp)
    59ee:	f4a6                	sd	s1,104(sp)
    59f0:	f0ca                	sd	s2,96(sp)
    59f2:	ecce                	sd	s3,88(sp)
    59f4:	e8d2                	sd	s4,80(sp)
    59f6:	e4d6                	sd	s5,72(sp)
    59f8:	e0da                	sd	s6,64(sp)
    59fa:	fc5e                	sd	s7,56(sp)
    59fc:	f862                	sd	s8,48(sp)
    59fe:	f466                	sd	s9,40(sp)
    5a00:	f06a                	sd	s10,32(sp)
    5a02:	ec6e                	sd	s11,24(sp)
    5a04:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    5a06:	0005c903          	lbu	s2,0(a1)
    5a0a:	18090f63          	beqz	s2,5ba8 <vprintf+0x1c0>
    5a0e:	8aaa                	mv	s5,a0
    5a10:	8b32                	mv	s6,a2
    5a12:	00158493          	addi	s1,a1,1
  state = 0;
    5a16:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    5a18:	02500a13          	li	s4,37
      if(c == 'd'){
    5a1c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    5a20:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    5a24:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    5a28:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5a2c:	00003b97          	auipc	s7,0x3
    5a30:	944b8b93          	addi	s7,s7,-1724 # 8370 <digits>
    5a34:	a839                	j	5a52 <vprintf+0x6a>
        putc(fd, c);
    5a36:	85ca                	mv	a1,s2
    5a38:	8556                	mv	a0,s5
    5a3a:	00000097          	auipc	ra,0x0
    5a3e:	ee2080e7          	jalr	-286(ra) # 591c <putc>
    5a42:	a019                	j	5a48 <vprintf+0x60>
    } else if(state == '%'){
    5a44:	01498f63          	beq	s3,s4,5a62 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    5a48:	0485                	addi	s1,s1,1
    5a4a:	fff4c903          	lbu	s2,-1(s1)
    5a4e:	14090d63          	beqz	s2,5ba8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    5a52:	0009079b          	sext.w	a5,s2
    if(state == 0){
    5a56:	fe0997e3          	bnez	s3,5a44 <vprintf+0x5c>
      if(c == '%'){
    5a5a:	fd479ee3          	bne	a5,s4,5a36 <vprintf+0x4e>
        state = '%';
    5a5e:	89be                	mv	s3,a5
    5a60:	b7e5                	j	5a48 <vprintf+0x60>
      if(c == 'd'){
    5a62:	05878063          	beq	a5,s8,5aa2 <vprintf+0xba>
      } else if(c == 'l') {
    5a66:	05978c63          	beq	a5,s9,5abe <vprintf+0xd6>
      } else if(c == 'x') {
    5a6a:	07a78863          	beq	a5,s10,5ada <vprintf+0xf2>
      } else if(c == 'p') {
    5a6e:	09b78463          	beq	a5,s11,5af6 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    5a72:	07300713          	li	a4,115
    5a76:	0ce78663          	beq	a5,a4,5b42 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    5a7a:	06300713          	li	a4,99
    5a7e:	0ee78e63          	beq	a5,a4,5b7a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    5a82:	11478863          	beq	a5,s4,5b92 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    5a86:	85d2                	mv	a1,s4
    5a88:	8556                	mv	a0,s5
    5a8a:	00000097          	auipc	ra,0x0
    5a8e:	e92080e7          	jalr	-366(ra) # 591c <putc>
        putc(fd, c);
    5a92:	85ca                	mv	a1,s2
    5a94:	8556                	mv	a0,s5
    5a96:	00000097          	auipc	ra,0x0
    5a9a:	e86080e7          	jalr	-378(ra) # 591c <putc>
      }
      state = 0;
    5a9e:	4981                	li	s3,0
    5aa0:	b765                	j	5a48 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5aa2:	008b0913          	addi	s2,s6,8
    5aa6:	4685                	li	a3,1
    5aa8:	4629                	li	a2,10
    5aaa:	000b2583          	lw	a1,0(s6)
    5aae:	8556                	mv	a0,s5
    5ab0:	00000097          	auipc	ra,0x0
    5ab4:	e8e080e7          	jalr	-370(ra) # 593e <printint>
    5ab8:	8b4a                	mv	s6,s2
      state = 0;
    5aba:	4981                	li	s3,0
    5abc:	b771                	j	5a48 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5abe:	008b0913          	addi	s2,s6,8
    5ac2:	4681                	li	a3,0
    5ac4:	4629                	li	a2,10
    5ac6:	000b2583          	lw	a1,0(s6)
    5aca:	8556                	mv	a0,s5
    5acc:	00000097          	auipc	ra,0x0
    5ad0:	e72080e7          	jalr	-398(ra) # 593e <printint>
    5ad4:	8b4a                	mv	s6,s2
      state = 0;
    5ad6:	4981                	li	s3,0
    5ad8:	bf85                	j	5a48 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5ada:	008b0913          	addi	s2,s6,8
    5ade:	4681                	li	a3,0
    5ae0:	4641                	li	a2,16
    5ae2:	000b2583          	lw	a1,0(s6)
    5ae6:	8556                	mv	a0,s5
    5ae8:	00000097          	auipc	ra,0x0
    5aec:	e56080e7          	jalr	-426(ra) # 593e <printint>
    5af0:	8b4a                	mv	s6,s2
      state = 0;
    5af2:	4981                	li	s3,0
    5af4:	bf91                	j	5a48 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5af6:	008b0793          	addi	a5,s6,8
    5afa:	f8f43423          	sd	a5,-120(s0)
    5afe:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    5b02:	03000593          	li	a1,48
    5b06:	8556                	mv	a0,s5
    5b08:	00000097          	auipc	ra,0x0
    5b0c:	e14080e7          	jalr	-492(ra) # 591c <putc>
  putc(fd, 'x');
    5b10:	85ea                	mv	a1,s10
    5b12:	8556                	mv	a0,s5
    5b14:	00000097          	auipc	ra,0x0
    5b18:	e08080e7          	jalr	-504(ra) # 591c <putc>
    5b1c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5b1e:	03c9d793          	srli	a5,s3,0x3c
    5b22:	97de                	add	a5,a5,s7
    5b24:	0007c583          	lbu	a1,0(a5)
    5b28:	8556                	mv	a0,s5
    5b2a:	00000097          	auipc	ra,0x0
    5b2e:	df2080e7          	jalr	-526(ra) # 591c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5b32:	0992                	slli	s3,s3,0x4
    5b34:	397d                	addiw	s2,s2,-1
    5b36:	fe0914e3          	bnez	s2,5b1e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    5b3a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5b3e:	4981                	li	s3,0
    5b40:	b721                	j	5a48 <vprintf+0x60>
        s = va_arg(ap, char*);
    5b42:	008b0993          	addi	s3,s6,8
    5b46:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    5b4a:	02090163          	beqz	s2,5b6c <vprintf+0x184>
        while(*s != 0){
    5b4e:	00094583          	lbu	a1,0(s2)
    5b52:	c9a1                	beqz	a1,5ba2 <vprintf+0x1ba>
          putc(fd, *s);
    5b54:	8556                	mv	a0,s5
    5b56:	00000097          	auipc	ra,0x0
    5b5a:	dc6080e7          	jalr	-570(ra) # 591c <putc>
          s++;
    5b5e:	0905                	addi	s2,s2,1
        while(*s != 0){
    5b60:	00094583          	lbu	a1,0(s2)
    5b64:	f9e5                	bnez	a1,5b54 <vprintf+0x16c>
        s = va_arg(ap, char*);
    5b66:	8b4e                	mv	s6,s3
      state = 0;
    5b68:	4981                	li	s3,0
    5b6a:	bdf9                	j	5a48 <vprintf+0x60>
          s = "(null)";
    5b6c:	00002917          	auipc	s2,0x2
    5b70:	7fc90913          	addi	s2,s2,2044 # 8368 <malloc+0x26b6>
        while(*s != 0){
    5b74:	02800593          	li	a1,40
    5b78:	bff1                	j	5b54 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    5b7a:	008b0913          	addi	s2,s6,8
    5b7e:	000b4583          	lbu	a1,0(s6)
    5b82:	8556                	mv	a0,s5
    5b84:	00000097          	auipc	ra,0x0
    5b88:	d98080e7          	jalr	-616(ra) # 591c <putc>
    5b8c:	8b4a                	mv	s6,s2
      state = 0;
    5b8e:	4981                	li	s3,0
    5b90:	bd65                	j	5a48 <vprintf+0x60>
        putc(fd, c);
    5b92:	85d2                	mv	a1,s4
    5b94:	8556                	mv	a0,s5
    5b96:	00000097          	auipc	ra,0x0
    5b9a:	d86080e7          	jalr	-634(ra) # 591c <putc>
      state = 0;
    5b9e:	4981                	li	s3,0
    5ba0:	b565                	j	5a48 <vprintf+0x60>
        s = va_arg(ap, char*);
    5ba2:	8b4e                	mv	s6,s3
      state = 0;
    5ba4:	4981                	li	s3,0
    5ba6:	b54d                	j	5a48 <vprintf+0x60>
    }
  }
}
    5ba8:	70e6                	ld	ra,120(sp)
    5baa:	7446                	ld	s0,112(sp)
    5bac:	74a6                	ld	s1,104(sp)
    5bae:	7906                	ld	s2,96(sp)
    5bb0:	69e6                	ld	s3,88(sp)
    5bb2:	6a46                	ld	s4,80(sp)
    5bb4:	6aa6                	ld	s5,72(sp)
    5bb6:	6b06                	ld	s6,64(sp)
    5bb8:	7be2                	ld	s7,56(sp)
    5bba:	7c42                	ld	s8,48(sp)
    5bbc:	7ca2                	ld	s9,40(sp)
    5bbe:	7d02                	ld	s10,32(sp)
    5bc0:	6de2                	ld	s11,24(sp)
    5bc2:	6109                	addi	sp,sp,128
    5bc4:	8082                	ret

0000000000005bc6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5bc6:	715d                	addi	sp,sp,-80
    5bc8:	ec06                	sd	ra,24(sp)
    5bca:	e822                	sd	s0,16(sp)
    5bcc:	1000                	addi	s0,sp,32
    5bce:	e010                	sd	a2,0(s0)
    5bd0:	e414                	sd	a3,8(s0)
    5bd2:	e818                	sd	a4,16(s0)
    5bd4:	ec1c                	sd	a5,24(s0)
    5bd6:	03043023          	sd	a6,32(s0)
    5bda:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5bde:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5be2:	8622                	mv	a2,s0
    5be4:	00000097          	auipc	ra,0x0
    5be8:	e04080e7          	jalr	-508(ra) # 59e8 <vprintf>
}
    5bec:	60e2                	ld	ra,24(sp)
    5bee:	6442                	ld	s0,16(sp)
    5bf0:	6161                	addi	sp,sp,80
    5bf2:	8082                	ret

0000000000005bf4 <printf>:

void
printf(const char *fmt, ...)
{
    5bf4:	711d                	addi	sp,sp,-96
    5bf6:	ec06                	sd	ra,24(sp)
    5bf8:	e822                	sd	s0,16(sp)
    5bfa:	1000                	addi	s0,sp,32
    5bfc:	e40c                	sd	a1,8(s0)
    5bfe:	e810                	sd	a2,16(s0)
    5c00:	ec14                	sd	a3,24(s0)
    5c02:	f018                	sd	a4,32(s0)
    5c04:	f41c                	sd	a5,40(s0)
    5c06:	03043823          	sd	a6,48(s0)
    5c0a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5c0e:	00840613          	addi	a2,s0,8
    5c12:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5c16:	85aa                	mv	a1,a0
    5c18:	4505                	li	a0,1
    5c1a:	00000097          	auipc	ra,0x0
    5c1e:	dce080e7          	jalr	-562(ra) # 59e8 <vprintf>
}
    5c22:	60e2                	ld	ra,24(sp)
    5c24:	6442                	ld	s0,16(sp)
    5c26:	6125                	addi	sp,sp,96
    5c28:	8082                	ret

0000000000005c2a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5c2a:	1141                	addi	sp,sp,-16
    5c2c:	e422                	sd	s0,8(sp)
    5c2e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5c30:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5c34:	00002797          	auipc	a5,0x2
    5c38:	76c7b783          	ld	a5,1900(a5) # 83a0 <freep>
    5c3c:	a805                	j	5c6c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5c3e:	4618                	lw	a4,8(a2)
    5c40:	9db9                	addw	a1,a1,a4
    5c42:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5c46:	6398                	ld	a4,0(a5)
    5c48:	6318                	ld	a4,0(a4)
    5c4a:	fee53823          	sd	a4,-16(a0)
    5c4e:	a091                	j	5c92 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5c50:	ff852703          	lw	a4,-8(a0)
    5c54:	9e39                	addw	a2,a2,a4
    5c56:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    5c58:	ff053703          	ld	a4,-16(a0)
    5c5c:	e398                	sd	a4,0(a5)
    5c5e:	a099                	j	5ca4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5c60:	6398                	ld	a4,0(a5)
    5c62:	00e7e463          	bltu	a5,a4,5c6a <free+0x40>
    5c66:	00e6ea63          	bltu	a3,a4,5c7a <free+0x50>
{
    5c6a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5c6c:	fed7fae3          	bgeu	a5,a3,5c60 <free+0x36>
    5c70:	6398                	ld	a4,0(a5)
    5c72:	00e6e463          	bltu	a3,a4,5c7a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5c76:	fee7eae3          	bltu	a5,a4,5c6a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    5c7a:	ff852583          	lw	a1,-8(a0)
    5c7e:	6390                	ld	a2,0(a5)
    5c80:	02059813          	slli	a6,a1,0x20
    5c84:	01c85713          	srli	a4,a6,0x1c
    5c88:	9736                	add	a4,a4,a3
    5c8a:	fae60ae3          	beq	a2,a4,5c3e <free+0x14>
    bp->s.ptr = p->s.ptr;
    5c8e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5c92:	4790                	lw	a2,8(a5)
    5c94:	02061593          	slli	a1,a2,0x20
    5c98:	01c5d713          	srli	a4,a1,0x1c
    5c9c:	973e                	add	a4,a4,a5
    5c9e:	fae689e3          	beq	a3,a4,5c50 <free+0x26>
  } else
    p->s.ptr = bp;
    5ca2:	e394                	sd	a3,0(a5)
  freep = p;
    5ca4:	00002717          	auipc	a4,0x2
    5ca8:	6ef73e23          	sd	a5,1788(a4) # 83a0 <freep>
}
    5cac:	6422                	ld	s0,8(sp)
    5cae:	0141                	addi	sp,sp,16
    5cb0:	8082                	ret

0000000000005cb2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5cb2:	7139                	addi	sp,sp,-64
    5cb4:	fc06                	sd	ra,56(sp)
    5cb6:	f822                	sd	s0,48(sp)
    5cb8:	f426                	sd	s1,40(sp)
    5cba:	f04a                	sd	s2,32(sp)
    5cbc:	ec4e                	sd	s3,24(sp)
    5cbe:	e852                	sd	s4,16(sp)
    5cc0:	e456                	sd	s5,8(sp)
    5cc2:	e05a                	sd	s6,0(sp)
    5cc4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5cc6:	02051493          	slli	s1,a0,0x20
    5cca:	9081                	srli	s1,s1,0x20
    5ccc:	04bd                	addi	s1,s1,15
    5cce:	8091                	srli	s1,s1,0x4
    5cd0:	0014899b          	addiw	s3,s1,1
    5cd4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5cd6:	00002517          	auipc	a0,0x2
    5cda:	6ca53503          	ld	a0,1738(a0) # 83a0 <freep>
    5cde:	c515                	beqz	a0,5d0a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5ce0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5ce2:	4798                	lw	a4,8(a5)
    5ce4:	02977f63          	bgeu	a4,s1,5d22 <malloc+0x70>
    5ce8:	8a4e                	mv	s4,s3
    5cea:	0009871b          	sext.w	a4,s3
    5cee:	6685                	lui	a3,0x1
    5cf0:	00d77363          	bgeu	a4,a3,5cf6 <malloc+0x44>
    5cf4:	6a05                	lui	s4,0x1
    5cf6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5cfa:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5cfe:	00002917          	auipc	s2,0x2
    5d02:	6a290913          	addi	s2,s2,1698 # 83a0 <freep>
  if(p == (char*)-1)
    5d06:	5afd                	li	s5,-1
    5d08:	a895                	j	5d7c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    5d0a:	00009797          	auipc	a5,0x9
    5d0e:	eb678793          	addi	a5,a5,-330 # ebc0 <base>
    5d12:	00002717          	auipc	a4,0x2
    5d16:	68f73723          	sd	a5,1678(a4) # 83a0 <freep>
    5d1a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5d1c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5d20:	b7e1                	j	5ce8 <malloc+0x36>
      if(p->s.size == nunits)
    5d22:	02e48c63          	beq	s1,a4,5d5a <malloc+0xa8>
        p->s.size -= nunits;
    5d26:	4137073b          	subw	a4,a4,s3
    5d2a:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5d2c:	02071693          	slli	a3,a4,0x20
    5d30:	01c6d713          	srli	a4,a3,0x1c
    5d34:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5d36:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5d3a:	00002717          	auipc	a4,0x2
    5d3e:	66a73323          	sd	a0,1638(a4) # 83a0 <freep>
      return (void*)(p + 1);
    5d42:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5d46:	70e2                	ld	ra,56(sp)
    5d48:	7442                	ld	s0,48(sp)
    5d4a:	74a2                	ld	s1,40(sp)
    5d4c:	7902                	ld	s2,32(sp)
    5d4e:	69e2                	ld	s3,24(sp)
    5d50:	6a42                	ld	s4,16(sp)
    5d52:	6aa2                	ld	s5,8(sp)
    5d54:	6b02                	ld	s6,0(sp)
    5d56:	6121                	addi	sp,sp,64
    5d58:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5d5a:	6398                	ld	a4,0(a5)
    5d5c:	e118                	sd	a4,0(a0)
    5d5e:	bff1                	j	5d3a <malloc+0x88>
  hp->s.size = nu;
    5d60:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    5d64:	0541                	addi	a0,a0,16
    5d66:	00000097          	auipc	ra,0x0
    5d6a:	ec4080e7          	jalr	-316(ra) # 5c2a <free>
  return freep;
    5d6e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    5d72:	d971                	beqz	a0,5d46 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5d74:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5d76:	4798                	lw	a4,8(a5)
    5d78:	fa9775e3          	bgeu	a4,s1,5d22 <malloc+0x70>
    if(p == freep)
    5d7c:	00093703          	ld	a4,0(s2)
    5d80:	853e                	mv	a0,a5
    5d82:	fef719e3          	bne	a4,a5,5d74 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    5d86:	8552                	mv	a0,s4
    5d88:	00000097          	auipc	ra,0x0
    5d8c:	b44080e7          	jalr	-1212(ra) # 58cc <sbrk>
  if(p == (char*)-1)
    5d90:	fd5518e3          	bne	a0,s5,5d60 <malloc+0xae>
        return 0;
    5d94:	4501                	li	a0,0
    5d96:	bf45                	j	5d46 <malloc+0x94>
