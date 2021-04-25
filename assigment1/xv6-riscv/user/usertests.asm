
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	1141                	addi	sp,sp,-16
       2:	e406                	sd	ra,8(sp)
       4:	e022                	sd	s0,0(sp)
       6:	0800                	addi	s0,sp,16
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };

  for(int ai = 0; ai < 2; ai++){
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
       8:	20100593          	li	a1,513
       c:	4505                	li	a0,1
       e:	057e                	slli	a0,a0,0x1f
      10:	00005097          	auipc	ra,0x5
      14:	6ce080e7          	jalr	1742(ra) # 56de <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00005097          	auipc	ra,0x5
      26:	6bc080e7          	jalr	1724(ra) # 56de <open>
    uint64 addr = addrs[ai];
      2a:	55fd                	li	a1,-1
    if(fd >= 0){
      2c:	00055863          	bgez	a0,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", addr, fd);
      exit(1);
    }
  }
}
      30:	60a2                	ld	ra,8(sp)
      32:	6402                	ld	s0,0(sp)
      34:	0141                	addi	sp,sp,16
      36:	8082                	ret
    uint64 addr = addrs[ai];
      38:	4585                	li	a1,1
      3a:	05fe                	slli	a1,a1,0x1f
      printf("open(%p) returned %d, not -1\n", addr, fd);
      3c:	862a                	mv	a2,a0
      3e:	00006517          	auipc	a0,0x6
      42:	eb250513          	addi	a0,a0,-334 # 5ef0 <malloc+0x404>
      46:	00006097          	auipc	ra,0x6
      4a:	9e8080e7          	jalr	-1560(ra) # 5a2e <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00005097          	auipc	ra,0x5
      54:	64e080e7          	jalr	1614(ra) # 569e <exit>

0000000000000058 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      58:	00009797          	auipc	a5,0x9
      5c:	3e878793          	addi	a5,a5,1000 # 9440 <uninit>
      60:	0000c697          	auipc	a3,0xc
      64:	af068693          	addi	a3,a3,-1296 # bb50 <buf>
    if(uninit[i] != '\0'){
      68:	0007c703          	lbu	a4,0(a5)
      6c:	e709                	bnez	a4,76 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      6e:	0785                	addi	a5,a5,1
      70:	fed79ce3          	bne	a5,a3,68 <bsstest+0x10>
      74:	8082                	ret
{
      76:	1141                	addi	sp,sp,-16
      78:	e406                	sd	ra,8(sp)
      7a:	e022                	sd	s0,0(sp)
      7c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      7e:	85aa                	mv	a1,a0
      80:	00006517          	auipc	a0,0x6
      84:	e9050513          	addi	a0,a0,-368 # 5f10 <malloc+0x424>
      88:	00006097          	auipc	ra,0x6
      8c:	9a6080e7          	jalr	-1626(ra) # 5a2e <printf>
      exit(1);
      90:	4505                	li	a0,1
      92:	00005097          	auipc	ra,0x5
      96:	60c080e7          	jalr	1548(ra) # 569e <exit>

000000000000009a <opentest>:
{
      9a:	1101                	addi	sp,sp,-32
      9c:	ec06                	sd	ra,24(sp)
      9e:	e822                	sd	s0,16(sp)
      a0:	e426                	sd	s1,8(sp)
      a2:	1000                	addi	s0,sp,32
      a4:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      a6:	4581                	li	a1,0
      a8:	00006517          	auipc	a0,0x6
      ac:	e8050513          	addi	a0,a0,-384 # 5f28 <malloc+0x43c>
      b0:	00005097          	auipc	ra,0x5
      b4:	62e080e7          	jalr	1582(ra) # 56de <open>
  if(fd < 0){
      b8:	02054663          	bltz	a0,e4 <opentest+0x4a>
  close(fd);
      bc:	00005097          	auipc	ra,0x5
      c0:	60a080e7          	jalr	1546(ra) # 56c6 <close>
  fd = open("doesnotexist", 0);
      c4:	4581                	li	a1,0
      c6:	00006517          	auipc	a0,0x6
      ca:	e8250513          	addi	a0,a0,-382 # 5f48 <malloc+0x45c>
      ce:	00005097          	auipc	ra,0x5
      d2:	610080e7          	jalr	1552(ra) # 56de <open>
  if(fd >= 0){
      d6:	02055563          	bgez	a0,100 <opentest+0x66>
}
      da:	60e2                	ld	ra,24(sp)
      dc:	6442                	ld	s0,16(sp)
      de:	64a2                	ld	s1,8(sp)
      e0:	6105                	addi	sp,sp,32
      e2:	8082                	ret
    printf("%s: open echo failed!\n", s);
      e4:	85a6                	mv	a1,s1
      e6:	00006517          	auipc	a0,0x6
      ea:	e4a50513          	addi	a0,a0,-438 # 5f30 <malloc+0x444>
      ee:	00006097          	auipc	ra,0x6
      f2:	940080e7          	jalr	-1728(ra) # 5a2e <printf>
    exit(1);
      f6:	4505                	li	a0,1
      f8:	00005097          	auipc	ra,0x5
      fc:	5a6080e7          	jalr	1446(ra) # 569e <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     100:	85a6                	mv	a1,s1
     102:	00006517          	auipc	a0,0x6
     106:	e5650513          	addi	a0,a0,-426 # 5f58 <malloc+0x46c>
     10a:	00006097          	auipc	ra,0x6
     10e:	924080e7          	jalr	-1756(ra) # 5a2e <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	00005097          	auipc	ra,0x5
     118:	58a080e7          	jalr	1418(ra) # 569e <exit>

000000000000011c <truncate2>:
{
     11c:	7179                	addi	sp,sp,-48
     11e:	f406                	sd	ra,40(sp)
     120:	f022                	sd	s0,32(sp)
     122:	ec26                	sd	s1,24(sp)
     124:	e84a                	sd	s2,16(sp)
     126:	e44e                	sd	s3,8(sp)
     128:	1800                	addi	s0,sp,48
     12a:	89aa                	mv	s3,a0
  unlink("truncfile");
     12c:	00006517          	auipc	a0,0x6
     130:	e5450513          	addi	a0,a0,-428 # 5f80 <malloc+0x494>
     134:	00005097          	auipc	ra,0x5
     138:	5ba080e7          	jalr	1466(ra) # 56ee <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     13c:	60100593          	li	a1,1537
     140:	00006517          	auipc	a0,0x6
     144:	e4050513          	addi	a0,a0,-448 # 5f80 <malloc+0x494>
     148:	00005097          	auipc	ra,0x5
     14c:	596080e7          	jalr	1430(ra) # 56de <open>
     150:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     152:	4611                	li	a2,4
     154:	00006597          	auipc	a1,0x6
     158:	e3c58593          	addi	a1,a1,-452 # 5f90 <malloc+0x4a4>
     15c:	00005097          	auipc	ra,0x5
     160:	562080e7          	jalr	1378(ra) # 56be <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     164:	40100593          	li	a1,1025
     168:	00006517          	auipc	a0,0x6
     16c:	e1850513          	addi	a0,a0,-488 # 5f80 <malloc+0x494>
     170:	00005097          	auipc	ra,0x5
     174:	56e080e7          	jalr	1390(ra) # 56de <open>
     178:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     17a:	4605                	li	a2,1
     17c:	00006597          	auipc	a1,0x6
     180:	e1c58593          	addi	a1,a1,-484 # 5f98 <malloc+0x4ac>
     184:	8526                	mv	a0,s1
     186:	00005097          	auipc	ra,0x5
     18a:	538080e7          	jalr	1336(ra) # 56be <write>
  if(n != -1){
     18e:	57fd                	li	a5,-1
     190:	02f51b63          	bne	a0,a5,1c6 <truncate2+0xaa>
  unlink("truncfile");
     194:	00006517          	auipc	a0,0x6
     198:	dec50513          	addi	a0,a0,-532 # 5f80 <malloc+0x494>
     19c:	00005097          	auipc	ra,0x5
     1a0:	552080e7          	jalr	1362(ra) # 56ee <unlink>
  close(fd1);
     1a4:	8526                	mv	a0,s1
     1a6:	00005097          	auipc	ra,0x5
     1aa:	520080e7          	jalr	1312(ra) # 56c6 <close>
  close(fd2);
     1ae:	854a                	mv	a0,s2
     1b0:	00005097          	auipc	ra,0x5
     1b4:	516080e7          	jalr	1302(ra) # 56c6 <close>
}
     1b8:	70a2                	ld	ra,40(sp)
     1ba:	7402                	ld	s0,32(sp)
     1bc:	64e2                	ld	s1,24(sp)
     1be:	6942                	ld	s2,16(sp)
     1c0:	69a2                	ld	s3,8(sp)
     1c2:	6145                	addi	sp,sp,48
     1c4:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1c6:	862a                	mv	a2,a0
     1c8:	85ce                	mv	a1,s3
     1ca:	00006517          	auipc	a0,0x6
     1ce:	dd650513          	addi	a0,a0,-554 # 5fa0 <malloc+0x4b4>
     1d2:	00006097          	auipc	ra,0x6
     1d6:	85c080e7          	jalr	-1956(ra) # 5a2e <printf>
    exit(1);
     1da:	4505                	li	a0,1
     1dc:	00005097          	auipc	ra,0x5
     1e0:	4c2080e7          	jalr	1218(ra) # 569e <exit>

00000000000001e4 <createtest>:
{
     1e4:	7179                	addi	sp,sp,-48
     1e6:	f406                	sd	ra,40(sp)
     1e8:	f022                	sd	s0,32(sp)
     1ea:	ec26                	sd	s1,24(sp)
     1ec:	e84a                	sd	s2,16(sp)
     1ee:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1f0:	06100793          	li	a5,97
     1f4:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1f8:	fc040d23          	sb	zero,-38(s0)
     1fc:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     200:	06400913          	li	s2,100
    name[1] = '0' + i;
     204:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     208:	20200593          	li	a1,514
     20c:	fd840513          	addi	a0,s0,-40
     210:	00005097          	auipc	ra,0x5
     214:	4ce080e7          	jalr	1230(ra) # 56de <open>
    close(fd);
     218:	00005097          	auipc	ra,0x5
     21c:	4ae080e7          	jalr	1198(ra) # 56c6 <close>
  for(i = 0; i < N; i++){
     220:	2485                	addiw	s1,s1,1
     222:	0ff4f493          	andi	s1,s1,255
     226:	fd249fe3          	bne	s1,s2,204 <createtest+0x20>
  name[0] = 'a';
     22a:	06100793          	li	a5,97
     22e:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     232:	fc040d23          	sb	zero,-38(s0)
     236:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     23a:	06400913          	li	s2,100
    name[1] = '0' + i;
     23e:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     242:	fd840513          	addi	a0,s0,-40
     246:	00005097          	auipc	ra,0x5
     24a:	4a8080e7          	jalr	1192(ra) # 56ee <unlink>
  for(i = 0; i < N; i++){
     24e:	2485                	addiw	s1,s1,1
     250:	0ff4f493          	andi	s1,s1,255
     254:	ff2495e3          	bne	s1,s2,23e <createtest+0x5a>
}
     258:	70a2                	ld	ra,40(sp)
     25a:	7402                	ld	s0,32(sp)
     25c:	64e2                	ld	s1,24(sp)
     25e:	6942                	ld	s2,16(sp)
     260:	6145                	addi	sp,sp,48
     262:	8082                	ret

0000000000000264 <bigwrite>:
{
     264:	715d                	addi	sp,sp,-80
     266:	e486                	sd	ra,72(sp)
     268:	e0a2                	sd	s0,64(sp)
     26a:	fc26                	sd	s1,56(sp)
     26c:	f84a                	sd	s2,48(sp)
     26e:	f44e                	sd	s3,40(sp)
     270:	f052                	sd	s4,32(sp)
     272:	ec56                	sd	s5,24(sp)
     274:	e85a                	sd	s6,16(sp)
     276:	e45e                	sd	s7,8(sp)
     278:	0880                	addi	s0,sp,80
     27a:	8baa                	mv	s7,a0
  unlink("bigwrite");
     27c:	00006517          	auipc	a0,0x6
     280:	b2c50513          	addi	a0,a0,-1236 # 5da8 <malloc+0x2bc>
     284:	00005097          	auipc	ra,0x5
     288:	46a080e7          	jalr	1130(ra) # 56ee <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     28c:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     290:	00006a97          	auipc	s5,0x6
     294:	b18a8a93          	addi	s5,s5,-1256 # 5da8 <malloc+0x2bc>
      int cc = write(fd, buf, sz);
     298:	0000ca17          	auipc	s4,0xc
     29c:	8b8a0a13          	addi	s4,s4,-1864 # bb50 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a0:	6b0d                	lui	s6,0x3
     2a2:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x173>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2a6:	20200593          	li	a1,514
     2aa:	8556                	mv	a0,s5
     2ac:	00005097          	auipc	ra,0x5
     2b0:	432080e7          	jalr	1074(ra) # 56de <open>
     2b4:	892a                	mv	s2,a0
    if(fd < 0){
     2b6:	04054d63          	bltz	a0,310 <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2ba:	8626                	mv	a2,s1
     2bc:	85d2                	mv	a1,s4
     2be:	00005097          	auipc	ra,0x5
     2c2:	400080e7          	jalr	1024(ra) # 56be <write>
     2c6:	89aa                	mv	s3,a0
      if(cc != sz){
     2c8:	06a49463          	bne	s1,a0,330 <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2cc:	8626                	mv	a2,s1
     2ce:	85d2                	mv	a1,s4
     2d0:	854a                	mv	a0,s2
     2d2:	00005097          	auipc	ra,0x5
     2d6:	3ec080e7          	jalr	1004(ra) # 56be <write>
      if(cc != sz){
     2da:	04951963          	bne	a0,s1,32c <bigwrite+0xc8>
    close(fd);
     2de:	854a                	mv	a0,s2
     2e0:	00005097          	auipc	ra,0x5
     2e4:	3e6080e7          	jalr	998(ra) # 56c6 <close>
    unlink("bigwrite");
     2e8:	8556                	mv	a0,s5
     2ea:	00005097          	auipc	ra,0x5
     2ee:	404080e7          	jalr	1028(ra) # 56ee <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2f2:	1d74849b          	addiw	s1,s1,471
     2f6:	fb6498e3          	bne	s1,s6,2a6 <bigwrite+0x42>
}
     2fa:	60a6                	ld	ra,72(sp)
     2fc:	6406                	ld	s0,64(sp)
     2fe:	74e2                	ld	s1,56(sp)
     300:	7942                	ld	s2,48(sp)
     302:	79a2                	ld	s3,40(sp)
     304:	7a02                	ld	s4,32(sp)
     306:	6ae2                	ld	s5,24(sp)
     308:	6b42                	ld	s6,16(sp)
     30a:	6ba2                	ld	s7,8(sp)
     30c:	6161                	addi	sp,sp,80
     30e:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     310:	85de                	mv	a1,s7
     312:	00006517          	auipc	a0,0x6
     316:	cb650513          	addi	a0,a0,-842 # 5fc8 <malloc+0x4dc>
     31a:	00005097          	auipc	ra,0x5
     31e:	714080e7          	jalr	1812(ra) # 5a2e <printf>
      exit(1);
     322:	4505                	li	a0,1
     324:	00005097          	auipc	ra,0x5
     328:	37a080e7          	jalr	890(ra) # 569e <exit>
     32c:	84ce                	mv	s1,s3
      int cc = write(fd, buf, sz);
     32e:	89aa                	mv	s3,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     330:	86ce                	mv	a3,s3
     332:	8626                	mv	a2,s1
     334:	85de                	mv	a1,s7
     336:	00006517          	auipc	a0,0x6
     33a:	cb250513          	addi	a0,a0,-846 # 5fe8 <malloc+0x4fc>
     33e:	00005097          	auipc	ra,0x5
     342:	6f0080e7          	jalr	1776(ra) # 5a2e <printf>
        exit(1);
     346:	4505                	li	a0,1
     348:	00005097          	auipc	ra,0x5
     34c:	356080e7          	jalr	854(ra) # 569e <exit>

0000000000000350 <copyin>:
{
     350:	715d                	addi	sp,sp,-80
     352:	e486                	sd	ra,72(sp)
     354:	e0a2                	sd	s0,64(sp)
     356:	fc26                	sd	s1,56(sp)
     358:	f84a                	sd	s2,48(sp)
     35a:	f44e                	sd	s3,40(sp)
     35c:	f052                	sd	s4,32(sp)
     35e:	0880                	addi	s0,sp,80
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     360:	4785                	li	a5,1
     362:	07fe                	slli	a5,a5,0x1f
     364:	fcf43023          	sd	a5,-64(s0)
     368:	57fd                	li	a5,-1
     36a:	fcf43423          	sd	a5,-56(s0)
  for(int ai = 0; ai < 2; ai++){
     36e:	fc040913          	addi	s2,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     372:	00006a17          	auipc	s4,0x6
     376:	c8ea0a13          	addi	s4,s4,-882 # 6000 <malloc+0x514>
    uint64 addr = addrs[ai];
     37a:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     37e:	20100593          	li	a1,513
     382:	8552                	mv	a0,s4
     384:	00005097          	auipc	ra,0x5
     388:	35a080e7          	jalr	858(ra) # 56de <open>
     38c:	84aa                	mv	s1,a0
    if(fd < 0){
     38e:	08054863          	bltz	a0,41e <copyin+0xce>
    int n = write(fd, (void*)addr, 8192);
     392:	6609                	lui	a2,0x2
     394:	85ce                	mv	a1,s3
     396:	00005097          	auipc	ra,0x5
     39a:	328080e7          	jalr	808(ra) # 56be <write>
    if(n >= 0){
     39e:	08055d63          	bgez	a0,438 <copyin+0xe8>
    close(fd);
     3a2:	8526                	mv	a0,s1
     3a4:	00005097          	auipc	ra,0x5
     3a8:	322080e7          	jalr	802(ra) # 56c6 <close>
    unlink("copyin1");
     3ac:	8552                	mv	a0,s4
     3ae:	00005097          	auipc	ra,0x5
     3b2:	340080e7          	jalr	832(ra) # 56ee <unlink>
    n = write(1, (char*)addr, 8192);
     3b6:	6609                	lui	a2,0x2
     3b8:	85ce                	mv	a1,s3
     3ba:	4505                	li	a0,1
     3bc:	00005097          	auipc	ra,0x5
     3c0:	302080e7          	jalr	770(ra) # 56be <write>
    if(n > 0){
     3c4:	08a04963          	bgtz	a0,456 <copyin+0x106>
    if(pipe(fds) < 0){
     3c8:	fb840513          	addi	a0,s0,-72
     3cc:	00005097          	auipc	ra,0x5
     3d0:	2e2080e7          	jalr	738(ra) # 56ae <pipe>
     3d4:	0a054063          	bltz	a0,474 <copyin+0x124>
    n = write(fds[1], (char*)addr, 8192);
     3d8:	6609                	lui	a2,0x2
     3da:	85ce                	mv	a1,s3
     3dc:	fbc42503          	lw	a0,-68(s0)
     3e0:	00005097          	auipc	ra,0x5
     3e4:	2de080e7          	jalr	734(ra) # 56be <write>
    if(n > 0){
     3e8:	0aa04363          	bgtz	a0,48e <copyin+0x13e>
    close(fds[0]);
     3ec:	fb842503          	lw	a0,-72(s0)
     3f0:	00005097          	auipc	ra,0x5
     3f4:	2d6080e7          	jalr	726(ra) # 56c6 <close>
    close(fds[1]);
     3f8:	fbc42503          	lw	a0,-68(s0)
     3fc:	00005097          	auipc	ra,0x5
     400:	2ca080e7          	jalr	714(ra) # 56c6 <close>
  for(int ai = 0; ai < 2; ai++){
     404:	0921                	addi	s2,s2,8
     406:	fd040793          	addi	a5,s0,-48
     40a:	f6f918e3          	bne	s2,a5,37a <copyin+0x2a>
}
     40e:	60a6                	ld	ra,72(sp)
     410:	6406                	ld	s0,64(sp)
     412:	74e2                	ld	s1,56(sp)
     414:	7942                	ld	s2,48(sp)
     416:	79a2                	ld	s3,40(sp)
     418:	7a02                	ld	s4,32(sp)
     41a:	6161                	addi	sp,sp,80
     41c:	8082                	ret
      printf("open(copyin1) failed\n");
     41e:	00006517          	auipc	a0,0x6
     422:	bea50513          	addi	a0,a0,-1046 # 6008 <malloc+0x51c>
     426:	00005097          	auipc	ra,0x5
     42a:	608080e7          	jalr	1544(ra) # 5a2e <printf>
      exit(1);
     42e:	4505                	li	a0,1
     430:	00005097          	auipc	ra,0x5
     434:	26e080e7          	jalr	622(ra) # 569e <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     438:	862a                	mv	a2,a0
     43a:	85ce                	mv	a1,s3
     43c:	00006517          	auipc	a0,0x6
     440:	be450513          	addi	a0,a0,-1052 # 6020 <malloc+0x534>
     444:	00005097          	auipc	ra,0x5
     448:	5ea080e7          	jalr	1514(ra) # 5a2e <printf>
      exit(1);
     44c:	4505                	li	a0,1
     44e:	00005097          	auipc	ra,0x5
     452:	250080e7          	jalr	592(ra) # 569e <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     456:	862a                	mv	a2,a0
     458:	85ce                	mv	a1,s3
     45a:	00006517          	auipc	a0,0x6
     45e:	bf650513          	addi	a0,a0,-1034 # 6050 <malloc+0x564>
     462:	00005097          	auipc	ra,0x5
     466:	5cc080e7          	jalr	1484(ra) # 5a2e <printf>
      exit(1);
     46a:	4505                	li	a0,1
     46c:	00005097          	auipc	ra,0x5
     470:	232080e7          	jalr	562(ra) # 569e <exit>
      printf("pipe() failed\n");
     474:	00006517          	auipc	a0,0x6
     478:	c0c50513          	addi	a0,a0,-1012 # 6080 <malloc+0x594>
     47c:	00005097          	auipc	ra,0x5
     480:	5b2080e7          	jalr	1458(ra) # 5a2e <printf>
      exit(1);
     484:	4505                	li	a0,1
     486:	00005097          	auipc	ra,0x5
     48a:	218080e7          	jalr	536(ra) # 569e <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     48e:	862a                	mv	a2,a0
     490:	85ce                	mv	a1,s3
     492:	00006517          	auipc	a0,0x6
     496:	bfe50513          	addi	a0,a0,-1026 # 6090 <malloc+0x5a4>
     49a:	00005097          	auipc	ra,0x5
     49e:	594080e7          	jalr	1428(ra) # 5a2e <printf>
      exit(1);
     4a2:	4505                	li	a0,1
     4a4:	00005097          	auipc	ra,0x5
     4a8:	1fa080e7          	jalr	506(ra) # 569e <exit>

00000000000004ac <copyout>:
{
     4ac:	711d                	addi	sp,sp,-96
     4ae:	ec86                	sd	ra,88(sp)
     4b0:	e8a2                	sd	s0,80(sp)
     4b2:	e4a6                	sd	s1,72(sp)
     4b4:	e0ca                	sd	s2,64(sp)
     4b6:	fc4e                	sd	s3,56(sp)
     4b8:	f852                	sd	s4,48(sp)
     4ba:	f456                	sd	s5,40(sp)
     4bc:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     4be:	4785                	li	a5,1
     4c0:	07fe                	slli	a5,a5,0x1f
     4c2:	faf43823          	sd	a5,-80(s0)
     4c6:	57fd                	li	a5,-1
     4c8:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     4cc:	fb040913          	addi	s2,s0,-80
    int fd = open("README", 0);
     4d0:	00006a17          	auipc	s4,0x6
     4d4:	bf0a0a13          	addi	s4,s4,-1040 # 60c0 <malloc+0x5d4>
    n = write(fds[1], "x", 1);
     4d8:	00006a97          	auipc	s5,0x6
     4dc:	ac0a8a93          	addi	s5,s5,-1344 # 5f98 <malloc+0x4ac>
    uint64 addr = addrs[ai];
     4e0:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     4e4:	4581                	li	a1,0
     4e6:	8552                	mv	a0,s4
     4e8:	00005097          	auipc	ra,0x5
     4ec:	1f6080e7          	jalr	502(ra) # 56de <open>
     4f0:	84aa                	mv	s1,a0
    if(fd < 0){
     4f2:	08054663          	bltz	a0,57e <copyout+0xd2>
    int n = read(fd, (void*)addr, 8192);
     4f6:	6609                	lui	a2,0x2
     4f8:	85ce                	mv	a1,s3
     4fa:	00005097          	auipc	ra,0x5
     4fe:	1bc080e7          	jalr	444(ra) # 56b6 <read>
    if(n > 0){
     502:	08a04b63          	bgtz	a0,598 <copyout+0xec>
    close(fd);
     506:	8526                	mv	a0,s1
     508:	00005097          	auipc	ra,0x5
     50c:	1be080e7          	jalr	446(ra) # 56c6 <close>
    if(pipe(fds) < 0){
     510:	fa840513          	addi	a0,s0,-88
     514:	00005097          	auipc	ra,0x5
     518:	19a080e7          	jalr	410(ra) # 56ae <pipe>
     51c:	08054d63          	bltz	a0,5b6 <copyout+0x10a>
    n = write(fds[1], "x", 1);
     520:	4605                	li	a2,1
     522:	85d6                	mv	a1,s5
     524:	fac42503          	lw	a0,-84(s0)
     528:	00005097          	auipc	ra,0x5
     52c:	196080e7          	jalr	406(ra) # 56be <write>
    if(n != 1){
     530:	4785                	li	a5,1
     532:	08f51f63          	bne	a0,a5,5d0 <copyout+0x124>
    n = read(fds[0], (void*)addr, 8192);
     536:	6609                	lui	a2,0x2
     538:	85ce                	mv	a1,s3
     53a:	fa842503          	lw	a0,-88(s0)
     53e:	00005097          	auipc	ra,0x5
     542:	178080e7          	jalr	376(ra) # 56b6 <read>
    if(n > 0){
     546:	0aa04263          	bgtz	a0,5ea <copyout+0x13e>
    close(fds[0]);
     54a:	fa842503          	lw	a0,-88(s0)
     54e:	00005097          	auipc	ra,0x5
     552:	178080e7          	jalr	376(ra) # 56c6 <close>
    close(fds[1]);
     556:	fac42503          	lw	a0,-84(s0)
     55a:	00005097          	auipc	ra,0x5
     55e:	16c080e7          	jalr	364(ra) # 56c6 <close>
  for(int ai = 0; ai < 2; ai++){
     562:	0921                	addi	s2,s2,8
     564:	fc040793          	addi	a5,s0,-64
     568:	f6f91ce3          	bne	s2,a5,4e0 <copyout+0x34>
}
     56c:	60e6                	ld	ra,88(sp)
     56e:	6446                	ld	s0,80(sp)
     570:	64a6                	ld	s1,72(sp)
     572:	6906                	ld	s2,64(sp)
     574:	79e2                	ld	s3,56(sp)
     576:	7a42                	ld	s4,48(sp)
     578:	7aa2                	ld	s5,40(sp)
     57a:	6125                	addi	sp,sp,96
     57c:	8082                	ret
      printf("open(README) failed\n");
     57e:	00006517          	auipc	a0,0x6
     582:	b4a50513          	addi	a0,a0,-1206 # 60c8 <malloc+0x5dc>
     586:	00005097          	auipc	ra,0x5
     58a:	4a8080e7          	jalr	1192(ra) # 5a2e <printf>
      exit(1);
     58e:	4505                	li	a0,1
     590:	00005097          	auipc	ra,0x5
     594:	10e080e7          	jalr	270(ra) # 569e <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     598:	862a                	mv	a2,a0
     59a:	85ce                	mv	a1,s3
     59c:	00006517          	auipc	a0,0x6
     5a0:	b4450513          	addi	a0,a0,-1212 # 60e0 <malloc+0x5f4>
     5a4:	00005097          	auipc	ra,0x5
     5a8:	48a080e7          	jalr	1162(ra) # 5a2e <printf>
      exit(1);
     5ac:	4505                	li	a0,1
     5ae:	00005097          	auipc	ra,0x5
     5b2:	0f0080e7          	jalr	240(ra) # 569e <exit>
      printf("pipe() failed\n");
     5b6:	00006517          	auipc	a0,0x6
     5ba:	aca50513          	addi	a0,a0,-1334 # 6080 <malloc+0x594>
     5be:	00005097          	auipc	ra,0x5
     5c2:	470080e7          	jalr	1136(ra) # 5a2e <printf>
      exit(1);
     5c6:	4505                	li	a0,1
     5c8:	00005097          	auipc	ra,0x5
     5cc:	0d6080e7          	jalr	214(ra) # 569e <exit>
      printf("pipe write failed\n");
     5d0:	00006517          	auipc	a0,0x6
     5d4:	b4050513          	addi	a0,a0,-1216 # 6110 <malloc+0x624>
     5d8:	00005097          	auipc	ra,0x5
     5dc:	456080e7          	jalr	1110(ra) # 5a2e <printf>
      exit(1);
     5e0:	4505                	li	a0,1
     5e2:	00005097          	auipc	ra,0x5
     5e6:	0bc080e7          	jalr	188(ra) # 569e <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5ea:	862a                	mv	a2,a0
     5ec:	85ce                	mv	a1,s3
     5ee:	00006517          	auipc	a0,0x6
     5f2:	b3a50513          	addi	a0,a0,-1222 # 6128 <malloc+0x63c>
     5f6:	00005097          	auipc	ra,0x5
     5fa:	438080e7          	jalr	1080(ra) # 5a2e <printf>
      exit(1);
     5fe:	4505                	li	a0,1
     600:	00005097          	auipc	ra,0x5
     604:	09e080e7          	jalr	158(ra) # 569e <exit>

0000000000000608 <truncate1>:
{
     608:	711d                	addi	sp,sp,-96
     60a:	ec86                	sd	ra,88(sp)
     60c:	e8a2                	sd	s0,80(sp)
     60e:	e4a6                	sd	s1,72(sp)
     610:	e0ca                	sd	s2,64(sp)
     612:	fc4e                	sd	s3,56(sp)
     614:	f852                	sd	s4,48(sp)
     616:	f456                	sd	s5,40(sp)
     618:	1080                	addi	s0,sp,96
     61a:	8aaa                	mv	s5,a0
  unlink("truncfile");
     61c:	00006517          	auipc	a0,0x6
     620:	96450513          	addi	a0,a0,-1692 # 5f80 <malloc+0x494>
     624:	00005097          	auipc	ra,0x5
     628:	0ca080e7          	jalr	202(ra) # 56ee <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     62c:	60100593          	li	a1,1537
     630:	00006517          	auipc	a0,0x6
     634:	95050513          	addi	a0,a0,-1712 # 5f80 <malloc+0x494>
     638:	00005097          	auipc	ra,0x5
     63c:	0a6080e7          	jalr	166(ra) # 56de <open>
     640:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     642:	4611                	li	a2,4
     644:	00006597          	auipc	a1,0x6
     648:	94c58593          	addi	a1,a1,-1716 # 5f90 <malloc+0x4a4>
     64c:	00005097          	auipc	ra,0x5
     650:	072080e7          	jalr	114(ra) # 56be <write>
  close(fd1);
     654:	8526                	mv	a0,s1
     656:	00005097          	auipc	ra,0x5
     65a:	070080e7          	jalr	112(ra) # 56c6 <close>
  int fd2 = open("truncfile", O_RDONLY);
     65e:	4581                	li	a1,0
     660:	00006517          	auipc	a0,0x6
     664:	92050513          	addi	a0,a0,-1760 # 5f80 <malloc+0x494>
     668:	00005097          	auipc	ra,0x5
     66c:	076080e7          	jalr	118(ra) # 56de <open>
     670:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     672:	02000613          	li	a2,32
     676:	fa040593          	addi	a1,s0,-96
     67a:	00005097          	auipc	ra,0x5
     67e:	03c080e7          	jalr	60(ra) # 56b6 <read>
  if(n != 4){
     682:	4791                	li	a5,4
     684:	0cf51e63          	bne	a0,a5,760 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     688:	40100593          	li	a1,1025
     68c:	00006517          	auipc	a0,0x6
     690:	8f450513          	addi	a0,a0,-1804 # 5f80 <malloc+0x494>
     694:	00005097          	auipc	ra,0x5
     698:	04a080e7          	jalr	74(ra) # 56de <open>
     69c:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     69e:	4581                	li	a1,0
     6a0:	00006517          	auipc	a0,0x6
     6a4:	8e050513          	addi	a0,a0,-1824 # 5f80 <malloc+0x494>
     6a8:	00005097          	auipc	ra,0x5
     6ac:	036080e7          	jalr	54(ra) # 56de <open>
     6b0:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     6b2:	02000613          	li	a2,32
     6b6:	fa040593          	addi	a1,s0,-96
     6ba:	00005097          	auipc	ra,0x5
     6be:	ffc080e7          	jalr	-4(ra) # 56b6 <read>
     6c2:	8a2a                	mv	s4,a0
  if(n != 0){
     6c4:	ed4d                	bnez	a0,77e <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     6c6:	02000613          	li	a2,32
     6ca:	fa040593          	addi	a1,s0,-96
     6ce:	8526                	mv	a0,s1
     6d0:	00005097          	auipc	ra,0x5
     6d4:	fe6080e7          	jalr	-26(ra) # 56b6 <read>
     6d8:	8a2a                	mv	s4,a0
  if(n != 0){
     6da:	e971                	bnez	a0,7ae <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     6dc:	4619                	li	a2,6
     6de:	00006597          	auipc	a1,0x6
     6e2:	ada58593          	addi	a1,a1,-1318 # 61b8 <malloc+0x6cc>
     6e6:	854e                	mv	a0,s3
     6e8:	00005097          	auipc	ra,0x5
     6ec:	fd6080e7          	jalr	-42(ra) # 56be <write>
  n = read(fd3, buf, sizeof(buf));
     6f0:	02000613          	li	a2,32
     6f4:	fa040593          	addi	a1,s0,-96
     6f8:	854a                	mv	a0,s2
     6fa:	00005097          	auipc	ra,0x5
     6fe:	fbc080e7          	jalr	-68(ra) # 56b6 <read>
  if(n != 6){
     702:	4799                	li	a5,6
     704:	0cf51d63          	bne	a0,a5,7de <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     708:	02000613          	li	a2,32
     70c:	fa040593          	addi	a1,s0,-96
     710:	8526                	mv	a0,s1
     712:	00005097          	auipc	ra,0x5
     716:	fa4080e7          	jalr	-92(ra) # 56b6 <read>
  if(n != 2){
     71a:	4789                	li	a5,2
     71c:	0ef51063          	bne	a0,a5,7fc <truncate1+0x1f4>
  unlink("truncfile");
     720:	00006517          	auipc	a0,0x6
     724:	86050513          	addi	a0,a0,-1952 # 5f80 <malloc+0x494>
     728:	00005097          	auipc	ra,0x5
     72c:	fc6080e7          	jalr	-58(ra) # 56ee <unlink>
  close(fd1);
     730:	854e                	mv	a0,s3
     732:	00005097          	auipc	ra,0x5
     736:	f94080e7          	jalr	-108(ra) # 56c6 <close>
  close(fd2);
     73a:	8526                	mv	a0,s1
     73c:	00005097          	auipc	ra,0x5
     740:	f8a080e7          	jalr	-118(ra) # 56c6 <close>
  close(fd3);
     744:	854a                	mv	a0,s2
     746:	00005097          	auipc	ra,0x5
     74a:	f80080e7          	jalr	-128(ra) # 56c6 <close>
}
     74e:	60e6                	ld	ra,88(sp)
     750:	6446                	ld	s0,80(sp)
     752:	64a6                	ld	s1,72(sp)
     754:	6906                	ld	s2,64(sp)
     756:	79e2                	ld	s3,56(sp)
     758:	7a42                	ld	s4,48(sp)
     75a:	7aa2                	ld	s5,40(sp)
     75c:	6125                	addi	sp,sp,96
     75e:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     760:	862a                	mv	a2,a0
     762:	85d6                	mv	a1,s5
     764:	00006517          	auipc	a0,0x6
     768:	9f450513          	addi	a0,a0,-1548 # 6158 <malloc+0x66c>
     76c:	00005097          	auipc	ra,0x5
     770:	2c2080e7          	jalr	706(ra) # 5a2e <printf>
    exit(1);
     774:	4505                	li	a0,1
     776:	00005097          	auipc	ra,0x5
     77a:	f28080e7          	jalr	-216(ra) # 569e <exit>
    printf("aaa fd3=%d\n", fd3);
     77e:	85ca                	mv	a1,s2
     780:	00006517          	auipc	a0,0x6
     784:	9f850513          	addi	a0,a0,-1544 # 6178 <malloc+0x68c>
     788:	00005097          	auipc	ra,0x5
     78c:	2a6080e7          	jalr	678(ra) # 5a2e <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     790:	8652                	mv	a2,s4
     792:	85d6                	mv	a1,s5
     794:	00006517          	auipc	a0,0x6
     798:	9f450513          	addi	a0,a0,-1548 # 6188 <malloc+0x69c>
     79c:	00005097          	auipc	ra,0x5
     7a0:	292080e7          	jalr	658(ra) # 5a2e <printf>
    exit(1);
     7a4:	4505                	li	a0,1
     7a6:	00005097          	auipc	ra,0x5
     7aa:	ef8080e7          	jalr	-264(ra) # 569e <exit>
    printf("bbb fd2=%d\n", fd2);
     7ae:	85a6                	mv	a1,s1
     7b0:	00006517          	auipc	a0,0x6
     7b4:	9f850513          	addi	a0,a0,-1544 # 61a8 <malloc+0x6bc>
     7b8:	00005097          	auipc	ra,0x5
     7bc:	276080e7          	jalr	630(ra) # 5a2e <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7c0:	8652                	mv	a2,s4
     7c2:	85d6                	mv	a1,s5
     7c4:	00006517          	auipc	a0,0x6
     7c8:	9c450513          	addi	a0,a0,-1596 # 6188 <malloc+0x69c>
     7cc:	00005097          	auipc	ra,0x5
     7d0:	262080e7          	jalr	610(ra) # 5a2e <printf>
    exit(1);
     7d4:	4505                	li	a0,1
     7d6:	00005097          	auipc	ra,0x5
     7da:	ec8080e7          	jalr	-312(ra) # 569e <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     7de:	862a                	mv	a2,a0
     7e0:	85d6                	mv	a1,s5
     7e2:	00006517          	auipc	a0,0x6
     7e6:	9de50513          	addi	a0,a0,-1570 # 61c0 <malloc+0x6d4>
     7ea:	00005097          	auipc	ra,0x5
     7ee:	244080e7          	jalr	580(ra) # 5a2e <printf>
    exit(1);
     7f2:	4505                	li	a0,1
     7f4:	00005097          	auipc	ra,0x5
     7f8:	eaa080e7          	jalr	-342(ra) # 569e <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     7fc:	862a                	mv	a2,a0
     7fe:	85d6                	mv	a1,s5
     800:	00006517          	auipc	a0,0x6
     804:	9e050513          	addi	a0,a0,-1568 # 61e0 <malloc+0x6f4>
     808:	00005097          	auipc	ra,0x5
     80c:	226080e7          	jalr	550(ra) # 5a2e <printf>
    exit(1);
     810:	4505                	li	a0,1
     812:	00005097          	auipc	ra,0x5
     816:	e8c080e7          	jalr	-372(ra) # 569e <exit>

000000000000081a <writetest>:
{
     81a:	7139                	addi	sp,sp,-64
     81c:	fc06                	sd	ra,56(sp)
     81e:	f822                	sd	s0,48(sp)
     820:	f426                	sd	s1,40(sp)
     822:	f04a                	sd	s2,32(sp)
     824:	ec4e                	sd	s3,24(sp)
     826:	e852                	sd	s4,16(sp)
     828:	e456                	sd	s5,8(sp)
     82a:	e05a                	sd	s6,0(sp)
     82c:	0080                	addi	s0,sp,64
     82e:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     830:	20200593          	li	a1,514
     834:	00006517          	auipc	a0,0x6
     838:	9cc50513          	addi	a0,a0,-1588 # 6200 <malloc+0x714>
     83c:	00005097          	auipc	ra,0x5
     840:	ea2080e7          	jalr	-350(ra) # 56de <open>
  if(fd < 0){
     844:	0a054d63          	bltz	a0,8fe <writetest+0xe4>
     848:	892a                	mv	s2,a0
     84a:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     84c:	00006997          	auipc	s3,0x6
     850:	9dc98993          	addi	s3,s3,-1572 # 6228 <malloc+0x73c>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     854:	00006a97          	auipc	s5,0x6
     858:	a0ca8a93          	addi	s5,s5,-1524 # 6260 <malloc+0x774>
  for(i = 0; i < N; i++){
     85c:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     860:	4629                	li	a2,10
     862:	85ce                	mv	a1,s3
     864:	854a                	mv	a0,s2
     866:	00005097          	auipc	ra,0x5
     86a:	e58080e7          	jalr	-424(ra) # 56be <write>
     86e:	47a9                	li	a5,10
     870:	0af51563          	bne	a0,a5,91a <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     874:	4629                	li	a2,10
     876:	85d6                	mv	a1,s5
     878:	854a                	mv	a0,s2
     87a:	00005097          	auipc	ra,0x5
     87e:	e44080e7          	jalr	-444(ra) # 56be <write>
     882:	47a9                	li	a5,10
     884:	0af51a63          	bne	a0,a5,938 <writetest+0x11e>
  for(i = 0; i < N; i++){
     888:	2485                	addiw	s1,s1,1
     88a:	fd449be3          	bne	s1,s4,860 <writetest+0x46>
  close(fd);
     88e:	854a                	mv	a0,s2
     890:	00005097          	auipc	ra,0x5
     894:	e36080e7          	jalr	-458(ra) # 56c6 <close>
  fd = open("small", O_RDONLY);
     898:	4581                	li	a1,0
     89a:	00006517          	auipc	a0,0x6
     89e:	96650513          	addi	a0,a0,-1690 # 6200 <malloc+0x714>
     8a2:	00005097          	auipc	ra,0x5
     8a6:	e3c080e7          	jalr	-452(ra) # 56de <open>
     8aa:	84aa                	mv	s1,a0
  if(fd < 0){
     8ac:	0a054563          	bltz	a0,956 <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     8b0:	7d000613          	li	a2,2000
     8b4:	0000b597          	auipc	a1,0xb
     8b8:	29c58593          	addi	a1,a1,668 # bb50 <buf>
     8bc:	00005097          	auipc	ra,0x5
     8c0:	dfa080e7          	jalr	-518(ra) # 56b6 <read>
  if(i != N*SZ*2){
     8c4:	7d000793          	li	a5,2000
     8c8:	0af51563          	bne	a0,a5,972 <writetest+0x158>
  close(fd);
     8cc:	8526                	mv	a0,s1
     8ce:	00005097          	auipc	ra,0x5
     8d2:	df8080e7          	jalr	-520(ra) # 56c6 <close>
  if(unlink("small") < 0){
     8d6:	00006517          	auipc	a0,0x6
     8da:	92a50513          	addi	a0,a0,-1750 # 6200 <malloc+0x714>
     8de:	00005097          	auipc	ra,0x5
     8e2:	e10080e7          	jalr	-496(ra) # 56ee <unlink>
     8e6:	0a054463          	bltz	a0,98e <writetest+0x174>
}
     8ea:	70e2                	ld	ra,56(sp)
     8ec:	7442                	ld	s0,48(sp)
     8ee:	74a2                	ld	s1,40(sp)
     8f0:	7902                	ld	s2,32(sp)
     8f2:	69e2                	ld	s3,24(sp)
     8f4:	6a42                	ld	s4,16(sp)
     8f6:	6aa2                	ld	s5,8(sp)
     8f8:	6b02                	ld	s6,0(sp)
     8fa:	6121                	addi	sp,sp,64
     8fc:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     8fe:	85da                	mv	a1,s6
     900:	00006517          	auipc	a0,0x6
     904:	90850513          	addi	a0,a0,-1784 # 6208 <malloc+0x71c>
     908:	00005097          	auipc	ra,0x5
     90c:	126080e7          	jalr	294(ra) # 5a2e <printf>
    exit(1);
     910:	4505                	li	a0,1
     912:	00005097          	auipc	ra,0x5
     916:	d8c080e7          	jalr	-628(ra) # 569e <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     91a:	8626                	mv	a2,s1
     91c:	85da                	mv	a1,s6
     91e:	00006517          	auipc	a0,0x6
     922:	91a50513          	addi	a0,a0,-1766 # 6238 <malloc+0x74c>
     926:	00005097          	auipc	ra,0x5
     92a:	108080e7          	jalr	264(ra) # 5a2e <printf>
      exit(1);
     92e:	4505                	li	a0,1
     930:	00005097          	auipc	ra,0x5
     934:	d6e080e7          	jalr	-658(ra) # 569e <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     938:	8626                	mv	a2,s1
     93a:	85da                	mv	a1,s6
     93c:	00006517          	auipc	a0,0x6
     940:	93450513          	addi	a0,a0,-1740 # 6270 <malloc+0x784>
     944:	00005097          	auipc	ra,0x5
     948:	0ea080e7          	jalr	234(ra) # 5a2e <printf>
      exit(1);
     94c:	4505                	li	a0,1
     94e:	00005097          	auipc	ra,0x5
     952:	d50080e7          	jalr	-688(ra) # 569e <exit>
    printf("%s: error: open small failed!\n", s);
     956:	85da                	mv	a1,s6
     958:	00006517          	auipc	a0,0x6
     95c:	94050513          	addi	a0,a0,-1728 # 6298 <malloc+0x7ac>
     960:	00005097          	auipc	ra,0x5
     964:	0ce080e7          	jalr	206(ra) # 5a2e <printf>
    exit(1);
     968:	4505                	li	a0,1
     96a:	00005097          	auipc	ra,0x5
     96e:	d34080e7          	jalr	-716(ra) # 569e <exit>
    printf("%s: read failed\n", s);
     972:	85da                	mv	a1,s6
     974:	00006517          	auipc	a0,0x6
     978:	94450513          	addi	a0,a0,-1724 # 62b8 <malloc+0x7cc>
     97c:	00005097          	auipc	ra,0x5
     980:	0b2080e7          	jalr	178(ra) # 5a2e <printf>
    exit(1);
     984:	4505                	li	a0,1
     986:	00005097          	auipc	ra,0x5
     98a:	d18080e7          	jalr	-744(ra) # 569e <exit>
    printf("%s: unlink small failed\n", s);
     98e:	85da                	mv	a1,s6
     990:	00006517          	auipc	a0,0x6
     994:	94050513          	addi	a0,a0,-1728 # 62d0 <malloc+0x7e4>
     998:	00005097          	auipc	ra,0x5
     99c:	096080e7          	jalr	150(ra) # 5a2e <printf>
    exit(1);
     9a0:	4505                	li	a0,1
     9a2:	00005097          	auipc	ra,0x5
     9a6:	cfc080e7          	jalr	-772(ra) # 569e <exit>

00000000000009aa <writebig>:
{
     9aa:	7139                	addi	sp,sp,-64
     9ac:	fc06                	sd	ra,56(sp)
     9ae:	f822                	sd	s0,48(sp)
     9b0:	f426                	sd	s1,40(sp)
     9b2:	f04a                	sd	s2,32(sp)
     9b4:	ec4e                	sd	s3,24(sp)
     9b6:	e852                	sd	s4,16(sp)
     9b8:	e456                	sd	s5,8(sp)
     9ba:	0080                	addi	s0,sp,64
     9bc:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9be:	20200593          	li	a1,514
     9c2:	00006517          	auipc	a0,0x6
     9c6:	92e50513          	addi	a0,a0,-1746 # 62f0 <malloc+0x804>
     9ca:	00005097          	auipc	ra,0x5
     9ce:	d14080e7          	jalr	-748(ra) # 56de <open>
     9d2:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9d4:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9d6:	0000b917          	auipc	s2,0xb
     9da:	17a90913          	addi	s2,s2,378 # bb50 <buf>
  for(i = 0; i < MAXFILE; i++){
     9de:	10c00a13          	li	s4,268
  if(fd < 0){
     9e2:	06054c63          	bltz	a0,a5a <writebig+0xb0>
    ((int*)buf)[0] = i;
     9e6:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9ea:	40000613          	li	a2,1024
     9ee:	85ca                	mv	a1,s2
     9f0:	854e                	mv	a0,s3
     9f2:	00005097          	auipc	ra,0x5
     9f6:	ccc080e7          	jalr	-820(ra) # 56be <write>
     9fa:	40000793          	li	a5,1024
     9fe:	06f51c63          	bne	a0,a5,a76 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     a02:	2485                	addiw	s1,s1,1
     a04:	ff4491e3          	bne	s1,s4,9e6 <writebig+0x3c>
  close(fd);
     a08:	854e                	mv	a0,s3
     a0a:	00005097          	auipc	ra,0x5
     a0e:	cbc080e7          	jalr	-836(ra) # 56c6 <close>
  fd = open("big", O_RDONLY);
     a12:	4581                	li	a1,0
     a14:	00006517          	auipc	a0,0x6
     a18:	8dc50513          	addi	a0,a0,-1828 # 62f0 <malloc+0x804>
     a1c:	00005097          	auipc	ra,0x5
     a20:	cc2080e7          	jalr	-830(ra) # 56de <open>
     a24:	89aa                	mv	s3,a0
  n = 0;
     a26:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a28:	0000b917          	auipc	s2,0xb
     a2c:	12890913          	addi	s2,s2,296 # bb50 <buf>
  if(fd < 0){
     a30:	06054263          	bltz	a0,a94 <writebig+0xea>
    i = read(fd, buf, BSIZE);
     a34:	40000613          	li	a2,1024
     a38:	85ca                	mv	a1,s2
     a3a:	854e                	mv	a0,s3
     a3c:	00005097          	auipc	ra,0x5
     a40:	c7a080e7          	jalr	-902(ra) # 56b6 <read>
    if(i == 0){
     a44:	c535                	beqz	a0,ab0 <writebig+0x106>
    } else if(i != BSIZE){
     a46:	40000793          	li	a5,1024
     a4a:	0af51f63          	bne	a0,a5,b08 <writebig+0x15e>
    if(((int*)buf)[0] != n){
     a4e:	00092683          	lw	a3,0(s2)
     a52:	0c969a63          	bne	a3,s1,b26 <writebig+0x17c>
    n++;
     a56:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a58:	bff1                	j	a34 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     a5a:	85d6                	mv	a1,s5
     a5c:	00006517          	auipc	a0,0x6
     a60:	89c50513          	addi	a0,a0,-1892 # 62f8 <malloc+0x80c>
     a64:	00005097          	auipc	ra,0x5
     a68:	fca080e7          	jalr	-54(ra) # 5a2e <printf>
    exit(1);
     a6c:	4505                	li	a0,1
     a6e:	00005097          	auipc	ra,0x5
     a72:	c30080e7          	jalr	-976(ra) # 569e <exit>
      printf("%s: error: write big file failed\n", s, i);
     a76:	8626                	mv	a2,s1
     a78:	85d6                	mv	a1,s5
     a7a:	00006517          	auipc	a0,0x6
     a7e:	89e50513          	addi	a0,a0,-1890 # 6318 <malloc+0x82c>
     a82:	00005097          	auipc	ra,0x5
     a86:	fac080e7          	jalr	-84(ra) # 5a2e <printf>
      exit(1);
     a8a:	4505                	li	a0,1
     a8c:	00005097          	auipc	ra,0x5
     a90:	c12080e7          	jalr	-1006(ra) # 569e <exit>
    printf("%s: error: open big failed!\n", s);
     a94:	85d6                	mv	a1,s5
     a96:	00006517          	auipc	a0,0x6
     a9a:	8aa50513          	addi	a0,a0,-1878 # 6340 <malloc+0x854>
     a9e:	00005097          	auipc	ra,0x5
     aa2:	f90080e7          	jalr	-112(ra) # 5a2e <printf>
    exit(1);
     aa6:	4505                	li	a0,1
     aa8:	00005097          	auipc	ra,0x5
     aac:	bf6080e7          	jalr	-1034(ra) # 569e <exit>
      if(n == MAXFILE - 1){
     ab0:	10b00793          	li	a5,267
     ab4:	02f48a63          	beq	s1,a5,ae8 <writebig+0x13e>
  close(fd);
     ab8:	854e                	mv	a0,s3
     aba:	00005097          	auipc	ra,0x5
     abe:	c0c080e7          	jalr	-1012(ra) # 56c6 <close>
  if(unlink("big") < 0){
     ac2:	00006517          	auipc	a0,0x6
     ac6:	82e50513          	addi	a0,a0,-2002 # 62f0 <malloc+0x804>
     aca:	00005097          	auipc	ra,0x5
     ace:	c24080e7          	jalr	-988(ra) # 56ee <unlink>
     ad2:	06054963          	bltz	a0,b44 <writebig+0x19a>
}
     ad6:	70e2                	ld	ra,56(sp)
     ad8:	7442                	ld	s0,48(sp)
     ada:	74a2                	ld	s1,40(sp)
     adc:	7902                	ld	s2,32(sp)
     ade:	69e2                	ld	s3,24(sp)
     ae0:	6a42                	ld	s4,16(sp)
     ae2:	6aa2                	ld	s5,8(sp)
     ae4:	6121                	addi	sp,sp,64
     ae6:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     ae8:	10b00613          	li	a2,267
     aec:	85d6                	mv	a1,s5
     aee:	00006517          	auipc	a0,0x6
     af2:	87250513          	addi	a0,a0,-1934 # 6360 <malloc+0x874>
     af6:	00005097          	auipc	ra,0x5
     afa:	f38080e7          	jalr	-200(ra) # 5a2e <printf>
        exit(1);
     afe:	4505                	li	a0,1
     b00:	00005097          	auipc	ra,0x5
     b04:	b9e080e7          	jalr	-1122(ra) # 569e <exit>
      printf("%s: read failed %d\n", s, i);
     b08:	862a                	mv	a2,a0
     b0a:	85d6                	mv	a1,s5
     b0c:	00006517          	auipc	a0,0x6
     b10:	87c50513          	addi	a0,a0,-1924 # 6388 <malloc+0x89c>
     b14:	00005097          	auipc	ra,0x5
     b18:	f1a080e7          	jalr	-230(ra) # 5a2e <printf>
      exit(1);
     b1c:	4505                	li	a0,1
     b1e:	00005097          	auipc	ra,0x5
     b22:	b80080e7          	jalr	-1152(ra) # 569e <exit>
      printf("%s: read content of block %d is %d\n", s,
     b26:	8626                	mv	a2,s1
     b28:	85d6                	mv	a1,s5
     b2a:	00006517          	auipc	a0,0x6
     b2e:	87650513          	addi	a0,a0,-1930 # 63a0 <malloc+0x8b4>
     b32:	00005097          	auipc	ra,0x5
     b36:	efc080e7          	jalr	-260(ra) # 5a2e <printf>
      exit(1);
     b3a:	4505                	li	a0,1
     b3c:	00005097          	auipc	ra,0x5
     b40:	b62080e7          	jalr	-1182(ra) # 569e <exit>
    printf("%s: unlink big failed\n", s);
     b44:	85d6                	mv	a1,s5
     b46:	00006517          	auipc	a0,0x6
     b4a:	88250513          	addi	a0,a0,-1918 # 63c8 <malloc+0x8dc>
     b4e:	00005097          	auipc	ra,0x5
     b52:	ee0080e7          	jalr	-288(ra) # 5a2e <printf>
    exit(1);
     b56:	4505                	li	a0,1
     b58:	00005097          	auipc	ra,0x5
     b5c:	b46080e7          	jalr	-1210(ra) # 569e <exit>

0000000000000b60 <unlinkread>:
{
     b60:	7179                	addi	sp,sp,-48
     b62:	f406                	sd	ra,40(sp)
     b64:	f022                	sd	s0,32(sp)
     b66:	ec26                	sd	s1,24(sp)
     b68:	e84a                	sd	s2,16(sp)
     b6a:	e44e                	sd	s3,8(sp)
     b6c:	1800                	addi	s0,sp,48
     b6e:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b70:	20200593          	li	a1,514
     b74:	00005517          	auipc	a0,0x5
     b78:	1c450513          	addi	a0,a0,452 # 5d38 <malloc+0x24c>
     b7c:	00005097          	auipc	ra,0x5
     b80:	b62080e7          	jalr	-1182(ra) # 56de <open>
  if(fd < 0){
     b84:	0e054563          	bltz	a0,c6e <unlinkread+0x10e>
     b88:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b8a:	4615                	li	a2,5
     b8c:	00006597          	auipc	a1,0x6
     b90:	87458593          	addi	a1,a1,-1932 # 6400 <malloc+0x914>
     b94:	00005097          	auipc	ra,0x5
     b98:	b2a080e7          	jalr	-1238(ra) # 56be <write>
  close(fd);
     b9c:	8526                	mv	a0,s1
     b9e:	00005097          	auipc	ra,0x5
     ba2:	b28080e7          	jalr	-1240(ra) # 56c6 <close>
  fd = open("unlinkread", O_RDWR);
     ba6:	4589                	li	a1,2
     ba8:	00005517          	auipc	a0,0x5
     bac:	19050513          	addi	a0,a0,400 # 5d38 <malloc+0x24c>
     bb0:	00005097          	auipc	ra,0x5
     bb4:	b2e080e7          	jalr	-1234(ra) # 56de <open>
     bb8:	84aa                	mv	s1,a0
  if(fd < 0){
     bba:	0c054863          	bltz	a0,c8a <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     bbe:	00005517          	auipc	a0,0x5
     bc2:	17a50513          	addi	a0,a0,378 # 5d38 <malloc+0x24c>
     bc6:	00005097          	auipc	ra,0x5
     bca:	b28080e7          	jalr	-1240(ra) # 56ee <unlink>
     bce:	ed61                	bnez	a0,ca6 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     bd0:	20200593          	li	a1,514
     bd4:	00005517          	auipc	a0,0x5
     bd8:	16450513          	addi	a0,a0,356 # 5d38 <malloc+0x24c>
     bdc:	00005097          	auipc	ra,0x5
     be0:	b02080e7          	jalr	-1278(ra) # 56de <open>
     be4:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     be6:	460d                	li	a2,3
     be8:	00006597          	auipc	a1,0x6
     bec:	86058593          	addi	a1,a1,-1952 # 6448 <malloc+0x95c>
     bf0:	00005097          	auipc	ra,0x5
     bf4:	ace080e7          	jalr	-1330(ra) # 56be <write>
  close(fd1);
     bf8:	854a                	mv	a0,s2
     bfa:	00005097          	auipc	ra,0x5
     bfe:	acc080e7          	jalr	-1332(ra) # 56c6 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     c02:	660d                	lui	a2,0x3
     c04:	0000b597          	auipc	a1,0xb
     c08:	f4c58593          	addi	a1,a1,-180 # bb50 <buf>
     c0c:	8526                	mv	a0,s1
     c0e:	00005097          	auipc	ra,0x5
     c12:	aa8080e7          	jalr	-1368(ra) # 56b6 <read>
     c16:	4795                	li	a5,5
     c18:	0af51563          	bne	a0,a5,cc2 <unlinkread+0x162>
  if(buf[0] != 'h'){
     c1c:	0000b717          	auipc	a4,0xb
     c20:	f3474703          	lbu	a4,-204(a4) # bb50 <buf>
     c24:	06800793          	li	a5,104
     c28:	0af71b63          	bne	a4,a5,cde <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     c2c:	4629                	li	a2,10
     c2e:	0000b597          	auipc	a1,0xb
     c32:	f2258593          	addi	a1,a1,-222 # bb50 <buf>
     c36:	8526                	mv	a0,s1
     c38:	00005097          	auipc	ra,0x5
     c3c:	a86080e7          	jalr	-1402(ra) # 56be <write>
     c40:	47a9                	li	a5,10
     c42:	0af51c63          	bne	a0,a5,cfa <unlinkread+0x19a>
  close(fd);
     c46:	8526                	mv	a0,s1
     c48:	00005097          	auipc	ra,0x5
     c4c:	a7e080e7          	jalr	-1410(ra) # 56c6 <close>
  unlink("unlinkread");
     c50:	00005517          	auipc	a0,0x5
     c54:	0e850513          	addi	a0,a0,232 # 5d38 <malloc+0x24c>
     c58:	00005097          	auipc	ra,0x5
     c5c:	a96080e7          	jalr	-1386(ra) # 56ee <unlink>
}
     c60:	70a2                	ld	ra,40(sp)
     c62:	7402                	ld	s0,32(sp)
     c64:	64e2                	ld	s1,24(sp)
     c66:	6942                	ld	s2,16(sp)
     c68:	69a2                	ld	s3,8(sp)
     c6a:	6145                	addi	sp,sp,48
     c6c:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c6e:	85ce                	mv	a1,s3
     c70:	00005517          	auipc	a0,0x5
     c74:	77050513          	addi	a0,a0,1904 # 63e0 <malloc+0x8f4>
     c78:	00005097          	auipc	ra,0x5
     c7c:	db6080e7          	jalr	-586(ra) # 5a2e <printf>
    exit(1);
     c80:	4505                	li	a0,1
     c82:	00005097          	auipc	ra,0x5
     c86:	a1c080e7          	jalr	-1508(ra) # 569e <exit>
    printf("%s: open unlinkread failed\n", s);
     c8a:	85ce                	mv	a1,s3
     c8c:	00005517          	auipc	a0,0x5
     c90:	77c50513          	addi	a0,a0,1916 # 6408 <malloc+0x91c>
     c94:	00005097          	auipc	ra,0x5
     c98:	d9a080e7          	jalr	-614(ra) # 5a2e <printf>
    exit(1);
     c9c:	4505                	li	a0,1
     c9e:	00005097          	auipc	ra,0x5
     ca2:	a00080e7          	jalr	-1536(ra) # 569e <exit>
    printf("%s: unlink unlinkread failed\n", s);
     ca6:	85ce                	mv	a1,s3
     ca8:	00005517          	auipc	a0,0x5
     cac:	78050513          	addi	a0,a0,1920 # 6428 <malloc+0x93c>
     cb0:	00005097          	auipc	ra,0x5
     cb4:	d7e080e7          	jalr	-642(ra) # 5a2e <printf>
    exit(1);
     cb8:	4505                	li	a0,1
     cba:	00005097          	auipc	ra,0x5
     cbe:	9e4080e7          	jalr	-1564(ra) # 569e <exit>
    printf("%s: unlinkread read failed", s);
     cc2:	85ce                	mv	a1,s3
     cc4:	00005517          	auipc	a0,0x5
     cc8:	78c50513          	addi	a0,a0,1932 # 6450 <malloc+0x964>
     ccc:	00005097          	auipc	ra,0x5
     cd0:	d62080e7          	jalr	-670(ra) # 5a2e <printf>
    exit(1);
     cd4:	4505                	li	a0,1
     cd6:	00005097          	auipc	ra,0x5
     cda:	9c8080e7          	jalr	-1592(ra) # 569e <exit>
    printf("%s: unlinkread wrong data\n", s);
     cde:	85ce                	mv	a1,s3
     ce0:	00005517          	auipc	a0,0x5
     ce4:	79050513          	addi	a0,a0,1936 # 6470 <malloc+0x984>
     ce8:	00005097          	auipc	ra,0x5
     cec:	d46080e7          	jalr	-698(ra) # 5a2e <printf>
    exit(1);
     cf0:	4505                	li	a0,1
     cf2:	00005097          	auipc	ra,0x5
     cf6:	9ac080e7          	jalr	-1620(ra) # 569e <exit>
    printf("%s: unlinkread write failed\n", s);
     cfa:	85ce                	mv	a1,s3
     cfc:	00005517          	auipc	a0,0x5
     d00:	79450513          	addi	a0,a0,1940 # 6490 <malloc+0x9a4>
     d04:	00005097          	auipc	ra,0x5
     d08:	d2a080e7          	jalr	-726(ra) # 5a2e <printf>
    exit(1);
     d0c:	4505                	li	a0,1
     d0e:	00005097          	auipc	ra,0x5
     d12:	990080e7          	jalr	-1648(ra) # 569e <exit>

0000000000000d16 <linktest>:
{
     d16:	1101                	addi	sp,sp,-32
     d18:	ec06                	sd	ra,24(sp)
     d1a:	e822                	sd	s0,16(sp)
     d1c:	e426                	sd	s1,8(sp)
     d1e:	e04a                	sd	s2,0(sp)
     d20:	1000                	addi	s0,sp,32
     d22:	892a                	mv	s2,a0
  unlink("lf1");
     d24:	00005517          	auipc	a0,0x5
     d28:	78c50513          	addi	a0,a0,1932 # 64b0 <malloc+0x9c4>
     d2c:	00005097          	auipc	ra,0x5
     d30:	9c2080e7          	jalr	-1598(ra) # 56ee <unlink>
  unlink("lf2");
     d34:	00005517          	auipc	a0,0x5
     d38:	78450513          	addi	a0,a0,1924 # 64b8 <malloc+0x9cc>
     d3c:	00005097          	auipc	ra,0x5
     d40:	9b2080e7          	jalr	-1614(ra) # 56ee <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     d44:	20200593          	li	a1,514
     d48:	00005517          	auipc	a0,0x5
     d4c:	76850513          	addi	a0,a0,1896 # 64b0 <malloc+0x9c4>
     d50:	00005097          	auipc	ra,0x5
     d54:	98e080e7          	jalr	-1650(ra) # 56de <open>
  if(fd < 0){
     d58:	10054763          	bltz	a0,e66 <linktest+0x150>
     d5c:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     d5e:	4615                	li	a2,5
     d60:	00005597          	auipc	a1,0x5
     d64:	6a058593          	addi	a1,a1,1696 # 6400 <malloc+0x914>
     d68:	00005097          	auipc	ra,0x5
     d6c:	956080e7          	jalr	-1706(ra) # 56be <write>
     d70:	4795                	li	a5,5
     d72:	10f51863          	bne	a0,a5,e82 <linktest+0x16c>
  close(fd);
     d76:	8526                	mv	a0,s1
     d78:	00005097          	auipc	ra,0x5
     d7c:	94e080e7          	jalr	-1714(ra) # 56c6 <close>
  if(link("lf1", "lf2") < 0){
     d80:	00005597          	auipc	a1,0x5
     d84:	73858593          	addi	a1,a1,1848 # 64b8 <malloc+0x9cc>
     d88:	00005517          	auipc	a0,0x5
     d8c:	72850513          	addi	a0,a0,1832 # 64b0 <malloc+0x9c4>
     d90:	00005097          	auipc	ra,0x5
     d94:	96e080e7          	jalr	-1682(ra) # 56fe <link>
     d98:	10054363          	bltz	a0,e9e <linktest+0x188>
  unlink("lf1");
     d9c:	00005517          	auipc	a0,0x5
     da0:	71450513          	addi	a0,a0,1812 # 64b0 <malloc+0x9c4>
     da4:	00005097          	auipc	ra,0x5
     da8:	94a080e7          	jalr	-1718(ra) # 56ee <unlink>
  if(open("lf1", 0) >= 0){
     dac:	4581                	li	a1,0
     dae:	00005517          	auipc	a0,0x5
     db2:	70250513          	addi	a0,a0,1794 # 64b0 <malloc+0x9c4>
     db6:	00005097          	auipc	ra,0x5
     dba:	928080e7          	jalr	-1752(ra) # 56de <open>
     dbe:	0e055e63          	bgez	a0,eba <linktest+0x1a4>
  fd = open("lf2", 0);
     dc2:	4581                	li	a1,0
     dc4:	00005517          	auipc	a0,0x5
     dc8:	6f450513          	addi	a0,a0,1780 # 64b8 <malloc+0x9cc>
     dcc:	00005097          	auipc	ra,0x5
     dd0:	912080e7          	jalr	-1774(ra) # 56de <open>
     dd4:	84aa                	mv	s1,a0
  if(fd < 0){
     dd6:	10054063          	bltz	a0,ed6 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     dda:	660d                	lui	a2,0x3
     ddc:	0000b597          	auipc	a1,0xb
     de0:	d7458593          	addi	a1,a1,-652 # bb50 <buf>
     de4:	00005097          	auipc	ra,0x5
     de8:	8d2080e7          	jalr	-1838(ra) # 56b6 <read>
     dec:	4795                	li	a5,5
     dee:	10f51263          	bne	a0,a5,ef2 <linktest+0x1dc>
  close(fd);
     df2:	8526                	mv	a0,s1
     df4:	00005097          	auipc	ra,0x5
     df8:	8d2080e7          	jalr	-1838(ra) # 56c6 <close>
  if(link("lf2", "lf2") >= 0){
     dfc:	00005597          	auipc	a1,0x5
     e00:	6bc58593          	addi	a1,a1,1724 # 64b8 <malloc+0x9cc>
     e04:	852e                	mv	a0,a1
     e06:	00005097          	auipc	ra,0x5
     e0a:	8f8080e7          	jalr	-1800(ra) # 56fe <link>
     e0e:	10055063          	bgez	a0,f0e <linktest+0x1f8>
  unlink("lf2");
     e12:	00005517          	auipc	a0,0x5
     e16:	6a650513          	addi	a0,a0,1702 # 64b8 <malloc+0x9cc>
     e1a:	00005097          	auipc	ra,0x5
     e1e:	8d4080e7          	jalr	-1836(ra) # 56ee <unlink>
  if(link("lf2", "lf1") >= 0){
     e22:	00005597          	auipc	a1,0x5
     e26:	68e58593          	addi	a1,a1,1678 # 64b0 <malloc+0x9c4>
     e2a:	00005517          	auipc	a0,0x5
     e2e:	68e50513          	addi	a0,a0,1678 # 64b8 <malloc+0x9cc>
     e32:	00005097          	auipc	ra,0x5
     e36:	8cc080e7          	jalr	-1844(ra) # 56fe <link>
     e3a:	0e055863          	bgez	a0,f2a <linktest+0x214>
  if(link(".", "lf1") >= 0){
     e3e:	00005597          	auipc	a1,0x5
     e42:	67258593          	addi	a1,a1,1650 # 64b0 <malloc+0x9c4>
     e46:	00005517          	auipc	a0,0x5
     e4a:	77a50513          	addi	a0,a0,1914 # 65c0 <malloc+0xad4>
     e4e:	00005097          	auipc	ra,0x5
     e52:	8b0080e7          	jalr	-1872(ra) # 56fe <link>
     e56:	0e055863          	bgez	a0,f46 <linktest+0x230>
}
     e5a:	60e2                	ld	ra,24(sp)
     e5c:	6442                	ld	s0,16(sp)
     e5e:	64a2                	ld	s1,8(sp)
     e60:	6902                	ld	s2,0(sp)
     e62:	6105                	addi	sp,sp,32
     e64:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     e66:	85ca                	mv	a1,s2
     e68:	00005517          	auipc	a0,0x5
     e6c:	65850513          	addi	a0,a0,1624 # 64c0 <malloc+0x9d4>
     e70:	00005097          	auipc	ra,0x5
     e74:	bbe080e7          	jalr	-1090(ra) # 5a2e <printf>
    exit(1);
     e78:	4505                	li	a0,1
     e7a:	00005097          	auipc	ra,0x5
     e7e:	824080e7          	jalr	-2012(ra) # 569e <exit>
    printf("%s: write lf1 failed\n", s);
     e82:	85ca                	mv	a1,s2
     e84:	00005517          	auipc	a0,0x5
     e88:	65450513          	addi	a0,a0,1620 # 64d8 <malloc+0x9ec>
     e8c:	00005097          	auipc	ra,0x5
     e90:	ba2080e7          	jalr	-1118(ra) # 5a2e <printf>
    exit(1);
     e94:	4505                	li	a0,1
     e96:	00005097          	auipc	ra,0x5
     e9a:	808080e7          	jalr	-2040(ra) # 569e <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     e9e:	85ca                	mv	a1,s2
     ea0:	00005517          	auipc	a0,0x5
     ea4:	65050513          	addi	a0,a0,1616 # 64f0 <malloc+0xa04>
     ea8:	00005097          	auipc	ra,0x5
     eac:	b86080e7          	jalr	-1146(ra) # 5a2e <printf>
    exit(1);
     eb0:	4505                	li	a0,1
     eb2:	00004097          	auipc	ra,0x4
     eb6:	7ec080e7          	jalr	2028(ra) # 569e <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     eba:	85ca                	mv	a1,s2
     ebc:	00005517          	auipc	a0,0x5
     ec0:	65450513          	addi	a0,a0,1620 # 6510 <malloc+0xa24>
     ec4:	00005097          	auipc	ra,0x5
     ec8:	b6a080e7          	jalr	-1174(ra) # 5a2e <printf>
    exit(1);
     ecc:	4505                	li	a0,1
     ece:	00004097          	auipc	ra,0x4
     ed2:	7d0080e7          	jalr	2000(ra) # 569e <exit>
    printf("%s: open lf2 failed\n", s);
     ed6:	85ca                	mv	a1,s2
     ed8:	00005517          	auipc	a0,0x5
     edc:	66850513          	addi	a0,a0,1640 # 6540 <malloc+0xa54>
     ee0:	00005097          	auipc	ra,0x5
     ee4:	b4e080e7          	jalr	-1202(ra) # 5a2e <printf>
    exit(1);
     ee8:	4505                	li	a0,1
     eea:	00004097          	auipc	ra,0x4
     eee:	7b4080e7          	jalr	1972(ra) # 569e <exit>
    printf("%s: read lf2 failed\n", s);
     ef2:	85ca                	mv	a1,s2
     ef4:	00005517          	auipc	a0,0x5
     ef8:	66450513          	addi	a0,a0,1636 # 6558 <malloc+0xa6c>
     efc:	00005097          	auipc	ra,0x5
     f00:	b32080e7          	jalr	-1230(ra) # 5a2e <printf>
    exit(1);
     f04:	4505                	li	a0,1
     f06:	00004097          	auipc	ra,0x4
     f0a:	798080e7          	jalr	1944(ra) # 569e <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     f0e:	85ca                	mv	a1,s2
     f10:	00005517          	auipc	a0,0x5
     f14:	66050513          	addi	a0,a0,1632 # 6570 <malloc+0xa84>
     f18:	00005097          	auipc	ra,0x5
     f1c:	b16080e7          	jalr	-1258(ra) # 5a2e <printf>
    exit(1);
     f20:	4505                	li	a0,1
     f22:	00004097          	auipc	ra,0x4
     f26:	77c080e7          	jalr	1916(ra) # 569e <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
     f2a:	85ca                	mv	a1,s2
     f2c:	00005517          	auipc	a0,0x5
     f30:	66c50513          	addi	a0,a0,1644 # 6598 <malloc+0xaac>
     f34:	00005097          	auipc	ra,0x5
     f38:	afa080e7          	jalr	-1286(ra) # 5a2e <printf>
    exit(1);
     f3c:	4505                	li	a0,1
     f3e:	00004097          	auipc	ra,0x4
     f42:	760080e7          	jalr	1888(ra) # 569e <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     f46:	85ca                	mv	a1,s2
     f48:	00005517          	auipc	a0,0x5
     f4c:	68050513          	addi	a0,a0,1664 # 65c8 <malloc+0xadc>
     f50:	00005097          	auipc	ra,0x5
     f54:	ade080e7          	jalr	-1314(ra) # 5a2e <printf>
    exit(1);
     f58:	4505                	li	a0,1
     f5a:	00004097          	auipc	ra,0x4
     f5e:	744080e7          	jalr	1860(ra) # 569e <exit>

0000000000000f62 <bigdir>:
{
     f62:	715d                	addi	sp,sp,-80
     f64:	e486                	sd	ra,72(sp)
     f66:	e0a2                	sd	s0,64(sp)
     f68:	fc26                	sd	s1,56(sp)
     f6a:	f84a                	sd	s2,48(sp)
     f6c:	f44e                	sd	s3,40(sp)
     f6e:	f052                	sd	s4,32(sp)
     f70:	ec56                	sd	s5,24(sp)
     f72:	e85a                	sd	s6,16(sp)
     f74:	0880                	addi	s0,sp,80
     f76:	89aa                	mv	s3,a0
  unlink("bd");
     f78:	00005517          	auipc	a0,0x5
     f7c:	67050513          	addi	a0,a0,1648 # 65e8 <malloc+0xafc>
     f80:	00004097          	auipc	ra,0x4
     f84:	76e080e7          	jalr	1902(ra) # 56ee <unlink>
  fd = open("bd", O_CREATE);
     f88:	20000593          	li	a1,512
     f8c:	00005517          	auipc	a0,0x5
     f90:	65c50513          	addi	a0,a0,1628 # 65e8 <malloc+0xafc>
     f94:	00004097          	auipc	ra,0x4
     f98:	74a080e7          	jalr	1866(ra) # 56de <open>
  if(fd < 0){
     f9c:	0c054963          	bltz	a0,106e <bigdir+0x10c>
  close(fd);
     fa0:	00004097          	auipc	ra,0x4
     fa4:	726080e7          	jalr	1830(ra) # 56c6 <close>
  for(i = 0; i < N; i++){
     fa8:	4901                	li	s2,0
    name[0] = 'x';
     faa:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     fae:	00005a17          	auipc	s4,0x5
     fb2:	63aa0a13          	addi	s4,s4,1594 # 65e8 <malloc+0xafc>
  for(i = 0; i < N; i++){
     fb6:	1f400b13          	li	s6,500
    name[0] = 'x';
     fba:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     fbe:	41f9579b          	sraiw	a5,s2,0x1f
     fc2:	01a7d71b          	srliw	a4,a5,0x1a
     fc6:	012707bb          	addw	a5,a4,s2
     fca:	4067d69b          	sraiw	a3,a5,0x6
     fce:	0306869b          	addiw	a3,a3,48
     fd2:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     fd6:	03f7f793          	andi	a5,a5,63
     fda:	9f99                	subw	a5,a5,a4
     fdc:	0307879b          	addiw	a5,a5,48
     fe0:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     fe4:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     fe8:	fb040593          	addi	a1,s0,-80
     fec:	8552                	mv	a0,s4
     fee:	00004097          	auipc	ra,0x4
     ff2:	710080e7          	jalr	1808(ra) # 56fe <link>
     ff6:	84aa                	mv	s1,a0
     ff8:	e949                	bnez	a0,108a <bigdir+0x128>
  for(i = 0; i < N; i++){
     ffa:	2905                	addiw	s2,s2,1
     ffc:	fb691fe3          	bne	s2,s6,fba <bigdir+0x58>
  unlink("bd");
    1000:	00005517          	auipc	a0,0x5
    1004:	5e850513          	addi	a0,a0,1512 # 65e8 <malloc+0xafc>
    1008:	00004097          	auipc	ra,0x4
    100c:	6e6080e7          	jalr	1766(ra) # 56ee <unlink>
    name[0] = 'x';
    1010:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    1014:	1f400a13          	li	s4,500
    name[0] = 'x';
    1018:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    101c:	41f4d79b          	sraiw	a5,s1,0x1f
    1020:	01a7d71b          	srliw	a4,a5,0x1a
    1024:	009707bb          	addw	a5,a4,s1
    1028:	4067d69b          	sraiw	a3,a5,0x6
    102c:	0306869b          	addiw	a3,a3,48
    1030:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1034:	03f7f793          	andi	a5,a5,63
    1038:	9f99                	subw	a5,a5,a4
    103a:	0307879b          	addiw	a5,a5,48
    103e:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1042:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    1046:	fb040513          	addi	a0,s0,-80
    104a:	00004097          	auipc	ra,0x4
    104e:	6a4080e7          	jalr	1700(ra) # 56ee <unlink>
    1052:	ed21                	bnez	a0,10aa <bigdir+0x148>
  for(i = 0; i < N; i++){
    1054:	2485                	addiw	s1,s1,1
    1056:	fd4491e3          	bne	s1,s4,1018 <bigdir+0xb6>
}
    105a:	60a6                	ld	ra,72(sp)
    105c:	6406                	ld	s0,64(sp)
    105e:	74e2                	ld	s1,56(sp)
    1060:	7942                	ld	s2,48(sp)
    1062:	79a2                	ld	s3,40(sp)
    1064:	7a02                	ld	s4,32(sp)
    1066:	6ae2                	ld	s5,24(sp)
    1068:	6b42                	ld	s6,16(sp)
    106a:	6161                	addi	sp,sp,80
    106c:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    106e:	85ce                	mv	a1,s3
    1070:	00005517          	auipc	a0,0x5
    1074:	58050513          	addi	a0,a0,1408 # 65f0 <malloc+0xb04>
    1078:	00005097          	auipc	ra,0x5
    107c:	9b6080e7          	jalr	-1610(ra) # 5a2e <printf>
    exit(1);
    1080:	4505                	li	a0,1
    1082:	00004097          	auipc	ra,0x4
    1086:	61c080e7          	jalr	1564(ra) # 569e <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    108a:	fb040613          	addi	a2,s0,-80
    108e:	85ce                	mv	a1,s3
    1090:	00005517          	auipc	a0,0x5
    1094:	58050513          	addi	a0,a0,1408 # 6610 <malloc+0xb24>
    1098:	00005097          	auipc	ra,0x5
    109c:	996080e7          	jalr	-1642(ra) # 5a2e <printf>
      exit(1);
    10a0:	4505                	li	a0,1
    10a2:	00004097          	auipc	ra,0x4
    10a6:	5fc080e7          	jalr	1532(ra) # 569e <exit>
      printf("%s: bigdir unlink failed", s);
    10aa:	85ce                	mv	a1,s3
    10ac:	00005517          	auipc	a0,0x5
    10b0:	58450513          	addi	a0,a0,1412 # 6630 <malloc+0xb44>
    10b4:	00005097          	auipc	ra,0x5
    10b8:	97a080e7          	jalr	-1670(ra) # 5a2e <printf>
      exit(1);
    10bc:	4505                	li	a0,1
    10be:	00004097          	auipc	ra,0x4
    10c2:	5e0080e7          	jalr	1504(ra) # 569e <exit>

00000000000010c6 <validatetest>:
{
    10c6:	7139                	addi	sp,sp,-64
    10c8:	fc06                	sd	ra,56(sp)
    10ca:	f822                	sd	s0,48(sp)
    10cc:	f426                	sd	s1,40(sp)
    10ce:	f04a                	sd	s2,32(sp)
    10d0:	ec4e                	sd	s3,24(sp)
    10d2:	e852                	sd	s4,16(sp)
    10d4:	e456                	sd	s5,8(sp)
    10d6:	e05a                	sd	s6,0(sp)
    10d8:	0080                	addi	s0,sp,64
    10da:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10dc:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    10de:	00005997          	auipc	s3,0x5
    10e2:	57298993          	addi	s3,s3,1394 # 6650 <malloc+0xb64>
    10e6:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10e8:	6a85                	lui	s5,0x1
    10ea:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    10ee:	85a6                	mv	a1,s1
    10f0:	854e                	mv	a0,s3
    10f2:	00004097          	auipc	ra,0x4
    10f6:	60c080e7          	jalr	1548(ra) # 56fe <link>
    10fa:	01251f63          	bne	a0,s2,1118 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10fe:	94d6                	add	s1,s1,s5
    1100:	ff4497e3          	bne	s1,s4,10ee <validatetest+0x28>
}
    1104:	70e2                	ld	ra,56(sp)
    1106:	7442                	ld	s0,48(sp)
    1108:	74a2                	ld	s1,40(sp)
    110a:	7902                	ld	s2,32(sp)
    110c:	69e2                	ld	s3,24(sp)
    110e:	6a42                	ld	s4,16(sp)
    1110:	6aa2                	ld	s5,8(sp)
    1112:	6b02                	ld	s6,0(sp)
    1114:	6121                	addi	sp,sp,64
    1116:	8082                	ret
      printf("%s: link should not succeed\n", s);
    1118:	85da                	mv	a1,s6
    111a:	00005517          	auipc	a0,0x5
    111e:	54650513          	addi	a0,a0,1350 # 6660 <malloc+0xb74>
    1122:	00005097          	auipc	ra,0x5
    1126:	90c080e7          	jalr	-1780(ra) # 5a2e <printf>
      exit(1);
    112a:	4505                	li	a0,1
    112c:	00004097          	auipc	ra,0x4
    1130:	572080e7          	jalr	1394(ra) # 569e <exit>

0000000000001134 <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    1134:	7179                	addi	sp,sp,-48
    1136:	f406                	sd	ra,40(sp)
    1138:	f022                	sd	s0,32(sp)
    113a:	ec26                	sd	s1,24(sp)
    113c:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    113e:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1142:	00007497          	auipc	s1,0x7
    1146:	1de4b483          	ld	s1,478(s1) # 8320 <__SDATA_BEGIN__>
    114a:	fd840593          	addi	a1,s0,-40
    114e:	8526                	mv	a0,s1
    1150:	00004097          	auipc	ra,0x4
    1154:	586080e7          	jalr	1414(ra) # 56d6 <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    1158:	8526                	mv	a0,s1
    115a:	00004097          	auipc	ra,0x4
    115e:	554080e7          	jalr	1364(ra) # 56ae <pipe>

  exit(0);
    1162:	4501                	li	a0,0
    1164:	00004097          	auipc	ra,0x4
    1168:	53a080e7          	jalr	1338(ra) # 569e <exit>

000000000000116c <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    116c:	7139                	addi	sp,sp,-64
    116e:	fc06                	sd	ra,56(sp)
    1170:	f822                	sd	s0,48(sp)
    1172:	f426                	sd	s1,40(sp)
    1174:	f04a                	sd	s2,32(sp)
    1176:	ec4e                	sd	s3,24(sp)
    1178:	0080                	addi	s0,sp,64
    117a:	64b1                	lui	s1,0xc
    117c:	35048493          	addi	s1,s1,848 # c350 <buf+0x800>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1180:	597d                	li	s2,-1
    1182:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    1186:	00005997          	auipc	s3,0x5
    118a:	da298993          	addi	s3,s3,-606 # 5f28 <malloc+0x43c>
    argv[0] = (char*)0xffffffff;
    118e:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1192:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    1196:	fc040593          	addi	a1,s0,-64
    119a:	854e                	mv	a0,s3
    119c:	00004097          	auipc	ra,0x4
    11a0:	53a080e7          	jalr	1338(ra) # 56d6 <exec>
  for(int i = 0; i < 50000; i++){
    11a4:	34fd                	addiw	s1,s1,-1
    11a6:	f4e5                	bnez	s1,118e <badarg+0x22>
  }
  
  exit(0);
    11a8:	4501                	li	a0,0
    11aa:	00004097          	auipc	ra,0x4
    11ae:	4f4080e7          	jalr	1268(ra) # 569e <exit>

00000000000011b2 <copyinstr2>:
{
    11b2:	7155                	addi	sp,sp,-208
    11b4:	e586                	sd	ra,200(sp)
    11b6:	e1a2                	sd	s0,192(sp)
    11b8:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    11ba:	f6840793          	addi	a5,s0,-152
    11be:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    11c2:	07800713          	li	a4,120
    11c6:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    11ca:	0785                	addi	a5,a5,1
    11cc:	fed79de3          	bne	a5,a3,11c6 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    11d0:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    11d4:	f6840513          	addi	a0,s0,-152
    11d8:	00004097          	auipc	ra,0x4
    11dc:	516080e7          	jalr	1302(ra) # 56ee <unlink>
  if(ret != -1){
    11e0:	57fd                	li	a5,-1
    11e2:	0ef51063          	bne	a0,a5,12c2 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    11e6:	20100593          	li	a1,513
    11ea:	f6840513          	addi	a0,s0,-152
    11ee:	00004097          	auipc	ra,0x4
    11f2:	4f0080e7          	jalr	1264(ra) # 56de <open>
  if(fd != -1){
    11f6:	57fd                	li	a5,-1
    11f8:	0ef51563          	bne	a0,a5,12e2 <copyinstr2+0x130>
  ret = link(b, b);
    11fc:	f6840593          	addi	a1,s0,-152
    1200:	852e                	mv	a0,a1
    1202:	00004097          	auipc	ra,0x4
    1206:	4fc080e7          	jalr	1276(ra) # 56fe <link>
  if(ret != -1){
    120a:	57fd                	li	a5,-1
    120c:	0ef51b63          	bne	a0,a5,1302 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    1210:	00006797          	auipc	a5,0x6
    1214:	62078793          	addi	a5,a5,1568 # 7830 <malloc+0x1d44>
    1218:	f4f43c23          	sd	a5,-168(s0)
    121c:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1220:	f5840593          	addi	a1,s0,-168
    1224:	f6840513          	addi	a0,s0,-152
    1228:	00004097          	auipc	ra,0x4
    122c:	4ae080e7          	jalr	1198(ra) # 56d6 <exec>
  if(ret != -1){
    1230:	57fd                	li	a5,-1
    1232:	0ef51963          	bne	a0,a5,1324 <copyinstr2+0x172>
  int pid = fork();
    1236:	00004097          	auipc	ra,0x4
    123a:	460080e7          	jalr	1120(ra) # 5696 <fork>
  if(pid < 0){
    123e:	10054363          	bltz	a0,1344 <copyinstr2+0x192>
  if(pid == 0){
    1242:	12051463          	bnez	a0,136a <copyinstr2+0x1b8>
    1246:	00007797          	auipc	a5,0x7
    124a:	1f278793          	addi	a5,a5,498 # 8438 <big.0>
    124e:	00008697          	auipc	a3,0x8
    1252:	1ea68693          	addi	a3,a3,490 # 9438 <__global_pointer$+0x918>
      big[i] = 'x';
    1256:	07800713          	li	a4,120
    125a:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    125e:	0785                	addi	a5,a5,1
    1260:	fed79de3          	bne	a5,a3,125a <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1264:	00008797          	auipc	a5,0x8
    1268:	1c078a23          	sb	zero,468(a5) # 9438 <__global_pointer$+0x918>
    char *args2[] = { big, big, big, 0 };
    126c:	00007797          	auipc	a5,0x7
    1270:	cd478793          	addi	a5,a5,-812 # 7f40 <malloc+0x2454>
    1274:	6390                	ld	a2,0(a5)
    1276:	6794                	ld	a3,8(a5)
    1278:	6b98                	ld	a4,16(a5)
    127a:	6f9c                	ld	a5,24(a5)
    127c:	f2c43823          	sd	a2,-208(s0)
    1280:	f2d43c23          	sd	a3,-200(s0)
    1284:	f4e43023          	sd	a4,-192(s0)
    1288:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    128c:	f3040593          	addi	a1,s0,-208
    1290:	00005517          	auipc	a0,0x5
    1294:	c9850513          	addi	a0,a0,-872 # 5f28 <malloc+0x43c>
    1298:	00004097          	auipc	ra,0x4
    129c:	43e080e7          	jalr	1086(ra) # 56d6 <exec>
    if(ret != -1){
    12a0:	57fd                	li	a5,-1
    12a2:	0af50e63          	beq	a0,a5,135e <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    12a6:	55fd                	li	a1,-1
    12a8:	00005517          	auipc	a0,0x5
    12ac:	46050513          	addi	a0,a0,1120 # 6708 <malloc+0xc1c>
    12b0:	00004097          	auipc	ra,0x4
    12b4:	77e080e7          	jalr	1918(ra) # 5a2e <printf>
      exit(1);
    12b8:	4505                	li	a0,1
    12ba:	00004097          	auipc	ra,0x4
    12be:	3e4080e7          	jalr	996(ra) # 569e <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    12c2:	862a                	mv	a2,a0
    12c4:	f6840593          	addi	a1,s0,-152
    12c8:	00005517          	auipc	a0,0x5
    12cc:	3b850513          	addi	a0,a0,952 # 6680 <malloc+0xb94>
    12d0:	00004097          	auipc	ra,0x4
    12d4:	75e080e7          	jalr	1886(ra) # 5a2e <printf>
    exit(1);
    12d8:	4505                	li	a0,1
    12da:	00004097          	auipc	ra,0x4
    12de:	3c4080e7          	jalr	964(ra) # 569e <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    12e2:	862a                	mv	a2,a0
    12e4:	f6840593          	addi	a1,s0,-152
    12e8:	00005517          	auipc	a0,0x5
    12ec:	3b850513          	addi	a0,a0,952 # 66a0 <malloc+0xbb4>
    12f0:	00004097          	auipc	ra,0x4
    12f4:	73e080e7          	jalr	1854(ra) # 5a2e <printf>
    exit(1);
    12f8:	4505                	li	a0,1
    12fa:	00004097          	auipc	ra,0x4
    12fe:	3a4080e7          	jalr	932(ra) # 569e <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1302:	86aa                	mv	a3,a0
    1304:	f6840613          	addi	a2,s0,-152
    1308:	85b2                	mv	a1,a2
    130a:	00005517          	auipc	a0,0x5
    130e:	3b650513          	addi	a0,a0,950 # 66c0 <malloc+0xbd4>
    1312:	00004097          	auipc	ra,0x4
    1316:	71c080e7          	jalr	1820(ra) # 5a2e <printf>
    exit(1);
    131a:	4505                	li	a0,1
    131c:	00004097          	auipc	ra,0x4
    1320:	382080e7          	jalr	898(ra) # 569e <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1324:	567d                	li	a2,-1
    1326:	f6840593          	addi	a1,s0,-152
    132a:	00005517          	auipc	a0,0x5
    132e:	3be50513          	addi	a0,a0,958 # 66e8 <malloc+0xbfc>
    1332:	00004097          	auipc	ra,0x4
    1336:	6fc080e7          	jalr	1788(ra) # 5a2e <printf>
    exit(1);
    133a:	4505                	li	a0,1
    133c:	00004097          	auipc	ra,0x4
    1340:	362080e7          	jalr	866(ra) # 569e <exit>
    printf("fork failed\n");
    1344:	00006517          	auipc	a0,0x6
    1348:	82450513          	addi	a0,a0,-2012 # 6b68 <malloc+0x107c>
    134c:	00004097          	auipc	ra,0x4
    1350:	6e2080e7          	jalr	1762(ra) # 5a2e <printf>
    exit(1);
    1354:	4505                	li	a0,1
    1356:	00004097          	auipc	ra,0x4
    135a:	348080e7          	jalr	840(ra) # 569e <exit>
    exit(747); // OK
    135e:	2eb00513          	li	a0,747
    1362:	00004097          	auipc	ra,0x4
    1366:	33c080e7          	jalr	828(ra) # 569e <exit>
  int st = 0;
    136a:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    136e:	f5440513          	addi	a0,s0,-172
    1372:	00004097          	auipc	ra,0x4
    1376:	334080e7          	jalr	820(ra) # 56a6 <wait>
  if(st != 747){
    137a:	f5442703          	lw	a4,-172(s0)
    137e:	2eb00793          	li	a5,747
    1382:	00f71663          	bne	a4,a5,138e <copyinstr2+0x1dc>
}
    1386:	60ae                	ld	ra,200(sp)
    1388:	640e                	ld	s0,192(sp)
    138a:	6169                	addi	sp,sp,208
    138c:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    138e:	00005517          	auipc	a0,0x5
    1392:	3a250513          	addi	a0,a0,930 # 6730 <malloc+0xc44>
    1396:	00004097          	auipc	ra,0x4
    139a:	698080e7          	jalr	1688(ra) # 5a2e <printf>
    exit(1);
    139e:	4505                	li	a0,1
    13a0:	00004097          	auipc	ra,0x4
    13a4:	2fe080e7          	jalr	766(ra) # 569e <exit>

00000000000013a8 <truncate3>:
{
    13a8:	7159                	addi	sp,sp,-112
    13aa:	f486                	sd	ra,104(sp)
    13ac:	f0a2                	sd	s0,96(sp)
    13ae:	eca6                	sd	s1,88(sp)
    13b0:	e8ca                	sd	s2,80(sp)
    13b2:	e4ce                	sd	s3,72(sp)
    13b4:	e0d2                	sd	s4,64(sp)
    13b6:	fc56                	sd	s5,56(sp)
    13b8:	1880                	addi	s0,sp,112
    13ba:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    13bc:	60100593          	li	a1,1537
    13c0:	00005517          	auipc	a0,0x5
    13c4:	bc050513          	addi	a0,a0,-1088 # 5f80 <malloc+0x494>
    13c8:	00004097          	auipc	ra,0x4
    13cc:	316080e7          	jalr	790(ra) # 56de <open>
    13d0:	00004097          	auipc	ra,0x4
    13d4:	2f6080e7          	jalr	758(ra) # 56c6 <close>
  pid = fork();
    13d8:	00004097          	auipc	ra,0x4
    13dc:	2be080e7          	jalr	702(ra) # 5696 <fork>
  if(pid < 0){
    13e0:	08054063          	bltz	a0,1460 <truncate3+0xb8>
  if(pid == 0){
    13e4:	e969                	bnez	a0,14b6 <truncate3+0x10e>
    13e6:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    13ea:	00005a17          	auipc	s4,0x5
    13ee:	b96a0a13          	addi	s4,s4,-1130 # 5f80 <malloc+0x494>
      int n = write(fd, "1234567890", 10);
    13f2:	00005a97          	auipc	s5,0x5
    13f6:	39ea8a93          	addi	s5,s5,926 # 6790 <malloc+0xca4>
      int fd = open("truncfile", O_WRONLY);
    13fa:	4585                	li	a1,1
    13fc:	8552                	mv	a0,s4
    13fe:	00004097          	auipc	ra,0x4
    1402:	2e0080e7          	jalr	736(ra) # 56de <open>
    1406:	84aa                	mv	s1,a0
      if(fd < 0){
    1408:	06054a63          	bltz	a0,147c <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    140c:	4629                	li	a2,10
    140e:	85d6                	mv	a1,s5
    1410:	00004097          	auipc	ra,0x4
    1414:	2ae080e7          	jalr	686(ra) # 56be <write>
      if(n != 10){
    1418:	47a9                	li	a5,10
    141a:	06f51f63          	bne	a0,a5,1498 <truncate3+0xf0>
      close(fd);
    141e:	8526                	mv	a0,s1
    1420:	00004097          	auipc	ra,0x4
    1424:	2a6080e7          	jalr	678(ra) # 56c6 <close>
      fd = open("truncfile", O_RDONLY);
    1428:	4581                	li	a1,0
    142a:	8552                	mv	a0,s4
    142c:	00004097          	auipc	ra,0x4
    1430:	2b2080e7          	jalr	690(ra) # 56de <open>
    1434:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    1436:	02000613          	li	a2,32
    143a:	f9840593          	addi	a1,s0,-104
    143e:	00004097          	auipc	ra,0x4
    1442:	278080e7          	jalr	632(ra) # 56b6 <read>
      close(fd);
    1446:	8526                	mv	a0,s1
    1448:	00004097          	auipc	ra,0x4
    144c:	27e080e7          	jalr	638(ra) # 56c6 <close>
    for(int i = 0; i < 100; i++){
    1450:	39fd                	addiw	s3,s3,-1
    1452:	fa0994e3          	bnez	s3,13fa <truncate3+0x52>
    exit(0);
    1456:	4501                	li	a0,0
    1458:	00004097          	auipc	ra,0x4
    145c:	246080e7          	jalr	582(ra) # 569e <exit>
    printf("%s: fork failed\n", s);
    1460:	85ca                	mv	a1,s2
    1462:	00005517          	auipc	a0,0x5
    1466:	2fe50513          	addi	a0,a0,766 # 6760 <malloc+0xc74>
    146a:	00004097          	auipc	ra,0x4
    146e:	5c4080e7          	jalr	1476(ra) # 5a2e <printf>
    exit(1);
    1472:	4505                	li	a0,1
    1474:	00004097          	auipc	ra,0x4
    1478:	22a080e7          	jalr	554(ra) # 569e <exit>
        printf("%s: open failed\n", s);
    147c:	85ca                	mv	a1,s2
    147e:	00005517          	auipc	a0,0x5
    1482:	2fa50513          	addi	a0,a0,762 # 6778 <malloc+0xc8c>
    1486:	00004097          	auipc	ra,0x4
    148a:	5a8080e7          	jalr	1448(ra) # 5a2e <printf>
        exit(1);
    148e:	4505                	li	a0,1
    1490:	00004097          	auipc	ra,0x4
    1494:	20e080e7          	jalr	526(ra) # 569e <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    1498:	862a                	mv	a2,a0
    149a:	85ca                	mv	a1,s2
    149c:	00005517          	auipc	a0,0x5
    14a0:	30450513          	addi	a0,a0,772 # 67a0 <malloc+0xcb4>
    14a4:	00004097          	auipc	ra,0x4
    14a8:	58a080e7          	jalr	1418(ra) # 5a2e <printf>
        exit(1);
    14ac:	4505                	li	a0,1
    14ae:	00004097          	auipc	ra,0x4
    14b2:	1f0080e7          	jalr	496(ra) # 569e <exit>
    14b6:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14ba:	00005a17          	auipc	s4,0x5
    14be:	ac6a0a13          	addi	s4,s4,-1338 # 5f80 <malloc+0x494>
    int n = write(fd, "xxx", 3);
    14c2:	00005a97          	auipc	s5,0x5
    14c6:	2fea8a93          	addi	s5,s5,766 # 67c0 <malloc+0xcd4>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14ca:	60100593          	li	a1,1537
    14ce:	8552                	mv	a0,s4
    14d0:	00004097          	auipc	ra,0x4
    14d4:	20e080e7          	jalr	526(ra) # 56de <open>
    14d8:	84aa                	mv	s1,a0
    if(fd < 0){
    14da:	04054763          	bltz	a0,1528 <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    14de:	460d                	li	a2,3
    14e0:	85d6                	mv	a1,s5
    14e2:	00004097          	auipc	ra,0x4
    14e6:	1dc080e7          	jalr	476(ra) # 56be <write>
    if(n != 3){
    14ea:	478d                	li	a5,3
    14ec:	04f51c63          	bne	a0,a5,1544 <truncate3+0x19c>
    close(fd);
    14f0:	8526                	mv	a0,s1
    14f2:	00004097          	auipc	ra,0x4
    14f6:	1d4080e7          	jalr	468(ra) # 56c6 <close>
  for(int i = 0; i < 150; i++){
    14fa:	39fd                	addiw	s3,s3,-1
    14fc:	fc0997e3          	bnez	s3,14ca <truncate3+0x122>
  wait(&xstatus);
    1500:	fbc40513          	addi	a0,s0,-68
    1504:	00004097          	auipc	ra,0x4
    1508:	1a2080e7          	jalr	418(ra) # 56a6 <wait>
  unlink("truncfile");
    150c:	00005517          	auipc	a0,0x5
    1510:	a7450513          	addi	a0,a0,-1420 # 5f80 <malloc+0x494>
    1514:	00004097          	auipc	ra,0x4
    1518:	1da080e7          	jalr	474(ra) # 56ee <unlink>
  exit(xstatus);
    151c:	fbc42503          	lw	a0,-68(s0)
    1520:	00004097          	auipc	ra,0x4
    1524:	17e080e7          	jalr	382(ra) # 569e <exit>
      printf("%s: open failed\n", s);
    1528:	85ca                	mv	a1,s2
    152a:	00005517          	auipc	a0,0x5
    152e:	24e50513          	addi	a0,a0,590 # 6778 <malloc+0xc8c>
    1532:	00004097          	auipc	ra,0x4
    1536:	4fc080e7          	jalr	1276(ra) # 5a2e <printf>
      exit(1);
    153a:	4505                	li	a0,1
    153c:	00004097          	auipc	ra,0x4
    1540:	162080e7          	jalr	354(ra) # 569e <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1544:	862a                	mv	a2,a0
    1546:	85ca                	mv	a1,s2
    1548:	00005517          	auipc	a0,0x5
    154c:	28050513          	addi	a0,a0,640 # 67c8 <malloc+0xcdc>
    1550:	00004097          	auipc	ra,0x4
    1554:	4de080e7          	jalr	1246(ra) # 5a2e <printf>
      exit(1);
    1558:	4505                	li	a0,1
    155a:	00004097          	auipc	ra,0x4
    155e:	144080e7          	jalr	324(ra) # 569e <exit>

0000000000001562 <exectest>:
{
    1562:	715d                	addi	sp,sp,-80
    1564:	e486                	sd	ra,72(sp)
    1566:	e0a2                	sd	s0,64(sp)
    1568:	fc26                	sd	s1,56(sp)
    156a:	f84a                	sd	s2,48(sp)
    156c:	0880                	addi	s0,sp,80
    156e:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1570:	00005797          	auipc	a5,0x5
    1574:	9b878793          	addi	a5,a5,-1608 # 5f28 <malloc+0x43c>
    1578:	fcf43023          	sd	a5,-64(s0)
    157c:	00005797          	auipc	a5,0x5
    1580:	26c78793          	addi	a5,a5,620 # 67e8 <malloc+0xcfc>
    1584:	fcf43423          	sd	a5,-56(s0)
    1588:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    158c:	00005517          	auipc	a0,0x5
    1590:	26450513          	addi	a0,a0,612 # 67f0 <malloc+0xd04>
    1594:	00004097          	auipc	ra,0x4
    1598:	15a080e7          	jalr	346(ra) # 56ee <unlink>
  pid = fork();
    159c:	00004097          	auipc	ra,0x4
    15a0:	0fa080e7          	jalr	250(ra) # 5696 <fork>
  if(pid < 0) {
    15a4:	04054663          	bltz	a0,15f0 <exectest+0x8e>
    15a8:	84aa                	mv	s1,a0
  if(pid == 0) {
    15aa:	e959                	bnez	a0,1640 <exectest+0xde>
    close(1);
    15ac:	4505                	li	a0,1
    15ae:	00004097          	auipc	ra,0x4
    15b2:	118080e7          	jalr	280(ra) # 56c6 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    15b6:	20100593          	li	a1,513
    15ba:	00005517          	auipc	a0,0x5
    15be:	23650513          	addi	a0,a0,566 # 67f0 <malloc+0xd04>
    15c2:	00004097          	auipc	ra,0x4
    15c6:	11c080e7          	jalr	284(ra) # 56de <open>
    if(fd < 0) {
    15ca:	04054163          	bltz	a0,160c <exectest+0xaa>
    if(fd != 1) {
    15ce:	4785                	li	a5,1
    15d0:	04f50c63          	beq	a0,a5,1628 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    15d4:	85ca                	mv	a1,s2
    15d6:	00005517          	auipc	a0,0x5
    15da:	23a50513          	addi	a0,a0,570 # 6810 <malloc+0xd24>
    15de:	00004097          	auipc	ra,0x4
    15e2:	450080e7          	jalr	1104(ra) # 5a2e <printf>
      exit(1);
    15e6:	4505                	li	a0,1
    15e8:	00004097          	auipc	ra,0x4
    15ec:	0b6080e7          	jalr	182(ra) # 569e <exit>
     printf("%s: fork failed\n", s);
    15f0:	85ca                	mv	a1,s2
    15f2:	00005517          	auipc	a0,0x5
    15f6:	16e50513          	addi	a0,a0,366 # 6760 <malloc+0xc74>
    15fa:	00004097          	auipc	ra,0x4
    15fe:	434080e7          	jalr	1076(ra) # 5a2e <printf>
     exit(1);
    1602:	4505                	li	a0,1
    1604:	00004097          	auipc	ra,0x4
    1608:	09a080e7          	jalr	154(ra) # 569e <exit>
      printf("%s: create failed\n", s);
    160c:	85ca                	mv	a1,s2
    160e:	00005517          	auipc	a0,0x5
    1612:	1ea50513          	addi	a0,a0,490 # 67f8 <malloc+0xd0c>
    1616:	00004097          	auipc	ra,0x4
    161a:	418080e7          	jalr	1048(ra) # 5a2e <printf>
      exit(1);
    161e:	4505                	li	a0,1
    1620:	00004097          	auipc	ra,0x4
    1624:	07e080e7          	jalr	126(ra) # 569e <exit>
    if(exec("echo", echoargv) < 0){
    1628:	fc040593          	addi	a1,s0,-64
    162c:	00005517          	auipc	a0,0x5
    1630:	8fc50513          	addi	a0,a0,-1796 # 5f28 <malloc+0x43c>
    1634:	00004097          	auipc	ra,0x4
    1638:	0a2080e7          	jalr	162(ra) # 56d6 <exec>
    163c:	02054163          	bltz	a0,165e <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1640:	fdc40513          	addi	a0,s0,-36
    1644:	00004097          	auipc	ra,0x4
    1648:	062080e7          	jalr	98(ra) # 56a6 <wait>
    164c:	02951763          	bne	a0,s1,167a <exectest+0x118>
  if(xstatus != 0)
    1650:	fdc42503          	lw	a0,-36(s0)
    1654:	cd0d                	beqz	a0,168e <exectest+0x12c>
    exit(xstatus);
    1656:	00004097          	auipc	ra,0x4
    165a:	048080e7          	jalr	72(ra) # 569e <exit>
      printf("%s: exec echo failed\n", s);
    165e:	85ca                	mv	a1,s2
    1660:	00005517          	auipc	a0,0x5
    1664:	1c050513          	addi	a0,a0,448 # 6820 <malloc+0xd34>
    1668:	00004097          	auipc	ra,0x4
    166c:	3c6080e7          	jalr	966(ra) # 5a2e <printf>
      exit(1);
    1670:	4505                	li	a0,1
    1672:	00004097          	auipc	ra,0x4
    1676:	02c080e7          	jalr	44(ra) # 569e <exit>
    printf("%s: wait failed!\n", s);
    167a:	85ca                	mv	a1,s2
    167c:	00005517          	auipc	a0,0x5
    1680:	1bc50513          	addi	a0,a0,444 # 6838 <malloc+0xd4c>
    1684:	00004097          	auipc	ra,0x4
    1688:	3aa080e7          	jalr	938(ra) # 5a2e <printf>
    168c:	b7d1                	j	1650 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    168e:	4581                	li	a1,0
    1690:	00005517          	auipc	a0,0x5
    1694:	16050513          	addi	a0,a0,352 # 67f0 <malloc+0xd04>
    1698:	00004097          	auipc	ra,0x4
    169c:	046080e7          	jalr	70(ra) # 56de <open>
  if(fd < 0) {
    16a0:	02054a63          	bltz	a0,16d4 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    16a4:	4609                	li	a2,2
    16a6:	fb840593          	addi	a1,s0,-72
    16aa:	00004097          	auipc	ra,0x4
    16ae:	00c080e7          	jalr	12(ra) # 56b6 <read>
    16b2:	4789                	li	a5,2
    16b4:	02f50e63          	beq	a0,a5,16f0 <exectest+0x18e>
    printf("%s: read failed\n", s);
    16b8:	85ca                	mv	a1,s2
    16ba:	00005517          	auipc	a0,0x5
    16be:	bfe50513          	addi	a0,a0,-1026 # 62b8 <malloc+0x7cc>
    16c2:	00004097          	auipc	ra,0x4
    16c6:	36c080e7          	jalr	876(ra) # 5a2e <printf>
    exit(1);
    16ca:	4505                	li	a0,1
    16cc:	00004097          	auipc	ra,0x4
    16d0:	fd2080e7          	jalr	-46(ra) # 569e <exit>
    printf("%s: open failed\n", s);
    16d4:	85ca                	mv	a1,s2
    16d6:	00005517          	auipc	a0,0x5
    16da:	0a250513          	addi	a0,a0,162 # 6778 <malloc+0xc8c>
    16de:	00004097          	auipc	ra,0x4
    16e2:	350080e7          	jalr	848(ra) # 5a2e <printf>
    exit(1);
    16e6:	4505                	li	a0,1
    16e8:	00004097          	auipc	ra,0x4
    16ec:	fb6080e7          	jalr	-74(ra) # 569e <exit>
  unlink("echo-ok");
    16f0:	00005517          	auipc	a0,0x5
    16f4:	10050513          	addi	a0,a0,256 # 67f0 <malloc+0xd04>
    16f8:	00004097          	auipc	ra,0x4
    16fc:	ff6080e7          	jalr	-10(ra) # 56ee <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1700:	fb844703          	lbu	a4,-72(s0)
    1704:	04f00793          	li	a5,79
    1708:	00f71863          	bne	a4,a5,1718 <exectest+0x1b6>
    170c:	fb944703          	lbu	a4,-71(s0)
    1710:	04b00793          	li	a5,75
    1714:	02f70063          	beq	a4,a5,1734 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    1718:	85ca                	mv	a1,s2
    171a:	00005517          	auipc	a0,0x5
    171e:	13650513          	addi	a0,a0,310 # 6850 <malloc+0xd64>
    1722:	00004097          	auipc	ra,0x4
    1726:	30c080e7          	jalr	780(ra) # 5a2e <printf>
    exit(1);
    172a:	4505                	li	a0,1
    172c:	00004097          	auipc	ra,0x4
    1730:	f72080e7          	jalr	-142(ra) # 569e <exit>
    exit(0);
    1734:	4501                	li	a0,0
    1736:	00004097          	auipc	ra,0x4
    173a:	f68080e7          	jalr	-152(ra) # 569e <exit>

000000000000173e <pipe1>:
{
    173e:	711d                	addi	sp,sp,-96
    1740:	ec86                	sd	ra,88(sp)
    1742:	e8a2                	sd	s0,80(sp)
    1744:	e4a6                	sd	s1,72(sp)
    1746:	e0ca                	sd	s2,64(sp)
    1748:	fc4e                	sd	s3,56(sp)
    174a:	f852                	sd	s4,48(sp)
    174c:	f456                	sd	s5,40(sp)
    174e:	f05a                	sd	s6,32(sp)
    1750:	ec5e                	sd	s7,24(sp)
    1752:	1080                	addi	s0,sp,96
    1754:	892a                	mv	s2,a0
  if(pipe(fds) != 0){
    1756:	fa840513          	addi	a0,s0,-88
    175a:	00004097          	auipc	ra,0x4
    175e:	f54080e7          	jalr	-172(ra) # 56ae <pipe>
    1762:	ed25                	bnez	a0,17da <pipe1+0x9c>
    1764:	84aa                	mv	s1,a0
  pid = fork();
    1766:	00004097          	auipc	ra,0x4
    176a:	f30080e7          	jalr	-208(ra) # 5696 <fork>
    176e:	8a2a                	mv	s4,a0
  if(pid == 0){
    1770:	c159                	beqz	a0,17f6 <pipe1+0xb8>
  } else if(pid > 0){
    1772:	16a05e63          	blez	a0,18ee <pipe1+0x1b0>
    close(fds[1]);
    1776:	fac42503          	lw	a0,-84(s0)
    177a:	00004097          	auipc	ra,0x4
    177e:	f4c080e7          	jalr	-180(ra) # 56c6 <close>
    total = 0;
    1782:	8a26                	mv	s4,s1
    cc = 1;
    1784:	4985                	li	s3,1
    while((n = read(fds[0], buf, cc)) > 0){
    1786:	0000aa97          	auipc	s5,0xa
    178a:	3caa8a93          	addi	s5,s5,970 # bb50 <buf>
      if(cc > sizeof(buf))
    178e:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    1790:	864e                	mv	a2,s3
    1792:	85d6                	mv	a1,s5
    1794:	fa842503          	lw	a0,-88(s0)
    1798:	00004097          	auipc	ra,0x4
    179c:	f1e080e7          	jalr	-226(ra) # 56b6 <read>
    17a0:	10a05263          	blez	a0,18a4 <pipe1+0x166>
      for(i = 0; i < n; i++){
    17a4:	0000a717          	auipc	a4,0xa
    17a8:	3ac70713          	addi	a4,a4,940 # bb50 <buf>
    17ac:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17b0:	00074683          	lbu	a3,0(a4)
    17b4:	0ff4f793          	andi	a5,s1,255
    17b8:	2485                	addiw	s1,s1,1
    17ba:	0cf69163          	bne	a3,a5,187c <pipe1+0x13e>
      for(i = 0; i < n; i++){
    17be:	0705                	addi	a4,a4,1
    17c0:	fec498e3          	bne	s1,a2,17b0 <pipe1+0x72>
      total += n;
    17c4:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    17c8:	0019979b          	slliw	a5,s3,0x1
    17cc:	0007899b          	sext.w	s3,a5
      if(cc > sizeof(buf))
    17d0:	013b7363          	bgeu	s6,s3,17d6 <pipe1+0x98>
        cc = sizeof(buf);
    17d4:	89da                	mv	s3,s6
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17d6:	84b2                	mv	s1,a2
    17d8:	bf65                	j	1790 <pipe1+0x52>
    printf("%s: pipe() failed\n", s);
    17da:	85ca                	mv	a1,s2
    17dc:	00005517          	auipc	a0,0x5
    17e0:	08c50513          	addi	a0,a0,140 # 6868 <malloc+0xd7c>
    17e4:	00004097          	auipc	ra,0x4
    17e8:	24a080e7          	jalr	586(ra) # 5a2e <printf>
    exit(1);
    17ec:	4505                	li	a0,1
    17ee:	00004097          	auipc	ra,0x4
    17f2:	eb0080e7          	jalr	-336(ra) # 569e <exit>
    close(fds[0]);
    17f6:	fa842503          	lw	a0,-88(s0)
    17fa:	00004097          	auipc	ra,0x4
    17fe:	ecc080e7          	jalr	-308(ra) # 56c6 <close>
    for(n = 0; n < N; n++){
    1802:	0000ab17          	auipc	s6,0xa
    1806:	34eb0b13          	addi	s6,s6,846 # bb50 <buf>
    180a:	416004bb          	negw	s1,s6
    180e:	0ff4f493          	andi	s1,s1,255
    1812:	409b0993          	addi	s3,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    1816:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1818:	6a85                	lui	s5,0x1
    181a:	42da8a93          	addi	s5,s5,1069 # 142d <truncate3+0x85>
{
    181e:	87da                	mv	a5,s6
        buf[i] = seq++;
    1820:	0097873b          	addw	a4,a5,s1
    1824:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1828:	0785                	addi	a5,a5,1
    182a:	fef99be3          	bne	s3,a5,1820 <pipe1+0xe2>
        buf[i] = seq++;
    182e:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    1832:	40900613          	li	a2,1033
    1836:	85de                	mv	a1,s7
    1838:	fac42503          	lw	a0,-84(s0)
    183c:	00004097          	auipc	ra,0x4
    1840:	e82080e7          	jalr	-382(ra) # 56be <write>
    1844:	40900793          	li	a5,1033
    1848:	00f51c63          	bne	a0,a5,1860 <pipe1+0x122>
    for(n = 0; n < N; n++){
    184c:	24a5                	addiw	s1,s1,9
    184e:	0ff4f493          	andi	s1,s1,255
    1852:	fd5a16e3          	bne	s4,s5,181e <pipe1+0xe0>
    exit(0);
    1856:	4501                	li	a0,0
    1858:	00004097          	auipc	ra,0x4
    185c:	e46080e7          	jalr	-442(ra) # 569e <exit>
        printf("%s: pipe1 oops 1\n", s);
    1860:	85ca                	mv	a1,s2
    1862:	00005517          	auipc	a0,0x5
    1866:	01e50513          	addi	a0,a0,30 # 6880 <malloc+0xd94>
    186a:	00004097          	auipc	ra,0x4
    186e:	1c4080e7          	jalr	452(ra) # 5a2e <printf>
        exit(1);
    1872:	4505                	li	a0,1
    1874:	00004097          	auipc	ra,0x4
    1878:	e2a080e7          	jalr	-470(ra) # 569e <exit>
          printf("%s: pipe1 oops 2\n", s);
    187c:	85ca                	mv	a1,s2
    187e:	00005517          	auipc	a0,0x5
    1882:	01a50513          	addi	a0,a0,26 # 6898 <malloc+0xdac>
    1886:	00004097          	auipc	ra,0x4
    188a:	1a8080e7          	jalr	424(ra) # 5a2e <printf>
}
    188e:	60e6                	ld	ra,88(sp)
    1890:	6446                	ld	s0,80(sp)
    1892:	64a6                	ld	s1,72(sp)
    1894:	6906                	ld	s2,64(sp)
    1896:	79e2                	ld	s3,56(sp)
    1898:	7a42                	ld	s4,48(sp)
    189a:	7aa2                	ld	s5,40(sp)
    189c:	7b02                	ld	s6,32(sp)
    189e:	6be2                	ld	s7,24(sp)
    18a0:	6125                	addi	sp,sp,96
    18a2:	8082                	ret
    if(total != N * SZ){
    18a4:	6785                	lui	a5,0x1
    18a6:	42d78793          	addi	a5,a5,1069 # 142d <truncate3+0x85>
    18aa:	02fa0063          	beq	s4,a5,18ca <pipe1+0x18c>
      printf("%s: pipe1 oops 3 total %d\n", total);
    18ae:	85d2                	mv	a1,s4
    18b0:	00005517          	auipc	a0,0x5
    18b4:	00050513          	mv	a0,a0
    18b8:	00004097          	auipc	ra,0x4
    18bc:	176080e7          	jalr	374(ra) # 5a2e <printf>
      exit(1);
    18c0:	4505                	li	a0,1
    18c2:	00004097          	auipc	ra,0x4
    18c6:	ddc080e7          	jalr	-548(ra) # 569e <exit>
    close(fds[0]);
    18ca:	fa842503          	lw	a0,-88(s0)
    18ce:	00004097          	auipc	ra,0x4
    18d2:	df8080e7          	jalr	-520(ra) # 56c6 <close>
    wait(&xstatus);
    18d6:	fa440513          	addi	a0,s0,-92
    18da:	00004097          	auipc	ra,0x4
    18de:	dcc080e7          	jalr	-564(ra) # 56a6 <wait>
    exit(xstatus);
    18e2:	fa442503          	lw	a0,-92(s0)
    18e6:	00004097          	auipc	ra,0x4
    18ea:	db8080e7          	jalr	-584(ra) # 569e <exit>
    printf("%s: fork() failed\n", s);
    18ee:	85ca                	mv	a1,s2
    18f0:	00005517          	auipc	a0,0x5
    18f4:	fe050513          	addi	a0,a0,-32 # 68d0 <malloc+0xde4>
    18f8:	00004097          	auipc	ra,0x4
    18fc:	136080e7          	jalr	310(ra) # 5a2e <printf>
    exit(1);
    1900:	4505                	li	a0,1
    1902:	00004097          	auipc	ra,0x4
    1906:	d9c080e7          	jalr	-612(ra) # 569e <exit>

000000000000190a <exitwait>:
{
    190a:	7139                	addi	sp,sp,-64
    190c:	fc06                	sd	ra,56(sp)
    190e:	f822                	sd	s0,48(sp)
    1910:	f426                	sd	s1,40(sp)
    1912:	f04a                	sd	s2,32(sp)
    1914:	ec4e                	sd	s3,24(sp)
    1916:	e852                	sd	s4,16(sp)
    1918:	0080                	addi	s0,sp,64
    191a:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    191c:	4901                	li	s2,0
    191e:	06400993          	li	s3,100
    pid = fork();
    1922:	00004097          	auipc	ra,0x4
    1926:	d74080e7          	jalr	-652(ra) # 5696 <fork>
    192a:	84aa                	mv	s1,a0
    if(pid < 0){
    192c:	02054a63          	bltz	a0,1960 <exitwait+0x56>
    if(pid){
    1930:	c151                	beqz	a0,19b4 <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1932:	fcc40513          	addi	a0,s0,-52
    1936:	00004097          	auipc	ra,0x4
    193a:	d70080e7          	jalr	-656(ra) # 56a6 <wait>
    193e:	02951f63          	bne	a0,s1,197c <exitwait+0x72>
      if(i != xstate) {
    1942:	fcc42783          	lw	a5,-52(s0)
    1946:	05279963          	bne	a5,s2,1998 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    194a:	2905                	addiw	s2,s2,1
    194c:	fd391be3          	bne	s2,s3,1922 <exitwait+0x18>
}
    1950:	70e2                	ld	ra,56(sp)
    1952:	7442                	ld	s0,48(sp)
    1954:	74a2                	ld	s1,40(sp)
    1956:	7902                	ld	s2,32(sp)
    1958:	69e2                	ld	s3,24(sp)
    195a:	6a42                	ld	s4,16(sp)
    195c:	6121                	addi	sp,sp,64
    195e:	8082                	ret
      printf("%s: fork failed\n", s);
    1960:	85d2                	mv	a1,s4
    1962:	00005517          	auipc	a0,0x5
    1966:	dfe50513          	addi	a0,a0,-514 # 6760 <malloc+0xc74>
    196a:	00004097          	auipc	ra,0x4
    196e:	0c4080e7          	jalr	196(ra) # 5a2e <printf>
      exit(1);
    1972:	4505                	li	a0,1
    1974:	00004097          	auipc	ra,0x4
    1978:	d2a080e7          	jalr	-726(ra) # 569e <exit>
        printf("%s: wait wrong pid\n", s);
    197c:	85d2                	mv	a1,s4
    197e:	00005517          	auipc	a0,0x5
    1982:	f6a50513          	addi	a0,a0,-150 # 68e8 <malloc+0xdfc>
    1986:	00004097          	auipc	ra,0x4
    198a:	0a8080e7          	jalr	168(ra) # 5a2e <printf>
        exit(1);
    198e:	4505                	li	a0,1
    1990:	00004097          	auipc	ra,0x4
    1994:	d0e080e7          	jalr	-754(ra) # 569e <exit>
        printf("%s: wait wrong exit status\n", s);
    1998:	85d2                	mv	a1,s4
    199a:	00005517          	auipc	a0,0x5
    199e:	f6650513          	addi	a0,a0,-154 # 6900 <malloc+0xe14>
    19a2:	00004097          	auipc	ra,0x4
    19a6:	08c080e7          	jalr	140(ra) # 5a2e <printf>
        exit(1);
    19aa:	4505                	li	a0,1
    19ac:	00004097          	auipc	ra,0x4
    19b0:	cf2080e7          	jalr	-782(ra) # 569e <exit>
      exit(i);
    19b4:	854a                	mv	a0,s2
    19b6:	00004097          	auipc	ra,0x4
    19ba:	ce8080e7          	jalr	-792(ra) # 569e <exit>

00000000000019be <twochildren>:
{
    19be:	1101                	addi	sp,sp,-32
    19c0:	ec06                	sd	ra,24(sp)
    19c2:	e822                	sd	s0,16(sp)
    19c4:	e426                	sd	s1,8(sp)
    19c6:	e04a                	sd	s2,0(sp)
    19c8:	1000                	addi	s0,sp,32
    19ca:	892a                	mv	s2,a0
    19cc:	3e800493          	li	s1,1000
    int pid1 = fork();
    19d0:	00004097          	auipc	ra,0x4
    19d4:	cc6080e7          	jalr	-826(ra) # 5696 <fork>
    if(pid1 < 0){
    19d8:	02054c63          	bltz	a0,1a10 <twochildren+0x52>
    if(pid1 == 0){
    19dc:	c921                	beqz	a0,1a2c <twochildren+0x6e>
      int pid2 = fork();
    19de:	00004097          	auipc	ra,0x4
    19e2:	cb8080e7          	jalr	-840(ra) # 5696 <fork>
      if(pid2 < 0){
    19e6:	04054763          	bltz	a0,1a34 <twochildren+0x76>
      if(pid2 == 0){
    19ea:	c13d                	beqz	a0,1a50 <twochildren+0x92>
        wait(0);
    19ec:	4501                	li	a0,0
    19ee:	00004097          	auipc	ra,0x4
    19f2:	cb8080e7          	jalr	-840(ra) # 56a6 <wait>
        wait(0);
    19f6:	4501                	li	a0,0
    19f8:	00004097          	auipc	ra,0x4
    19fc:	cae080e7          	jalr	-850(ra) # 56a6 <wait>
  for(int i = 0; i < 1000; i++){
    1a00:	34fd                	addiw	s1,s1,-1
    1a02:	f4f9                	bnez	s1,19d0 <twochildren+0x12>
}
    1a04:	60e2                	ld	ra,24(sp)
    1a06:	6442                	ld	s0,16(sp)
    1a08:	64a2                	ld	s1,8(sp)
    1a0a:	6902                	ld	s2,0(sp)
    1a0c:	6105                	addi	sp,sp,32
    1a0e:	8082                	ret
      printf("%s: fork failed\n", s);
    1a10:	85ca                	mv	a1,s2
    1a12:	00005517          	auipc	a0,0x5
    1a16:	d4e50513          	addi	a0,a0,-690 # 6760 <malloc+0xc74>
    1a1a:	00004097          	auipc	ra,0x4
    1a1e:	014080e7          	jalr	20(ra) # 5a2e <printf>
      exit(1);
    1a22:	4505                	li	a0,1
    1a24:	00004097          	auipc	ra,0x4
    1a28:	c7a080e7          	jalr	-902(ra) # 569e <exit>
      exit(0);
    1a2c:	00004097          	auipc	ra,0x4
    1a30:	c72080e7          	jalr	-910(ra) # 569e <exit>
        printf("%s: fork failed\n", s);
    1a34:	85ca                	mv	a1,s2
    1a36:	00005517          	auipc	a0,0x5
    1a3a:	d2a50513          	addi	a0,a0,-726 # 6760 <malloc+0xc74>
    1a3e:	00004097          	auipc	ra,0x4
    1a42:	ff0080e7          	jalr	-16(ra) # 5a2e <printf>
        exit(1);
    1a46:	4505                	li	a0,1
    1a48:	00004097          	auipc	ra,0x4
    1a4c:	c56080e7          	jalr	-938(ra) # 569e <exit>
        exit(0);
    1a50:	00004097          	auipc	ra,0x4
    1a54:	c4e080e7          	jalr	-946(ra) # 569e <exit>

0000000000001a58 <forkfork>:
{
    1a58:	7179                	addi	sp,sp,-48
    1a5a:	f406                	sd	ra,40(sp)
    1a5c:	f022                	sd	s0,32(sp)
    1a5e:	ec26                	sd	s1,24(sp)
    1a60:	1800                	addi	s0,sp,48
    1a62:	84aa                	mv	s1,a0
    int pid = fork();
    1a64:	00004097          	auipc	ra,0x4
    1a68:	c32080e7          	jalr	-974(ra) # 5696 <fork>
    if(pid < 0){
    1a6c:	04054163          	bltz	a0,1aae <forkfork+0x56>
    if(pid == 0){
    1a70:	cd29                	beqz	a0,1aca <forkfork+0x72>
    int pid = fork();
    1a72:	00004097          	auipc	ra,0x4
    1a76:	c24080e7          	jalr	-988(ra) # 5696 <fork>
    if(pid < 0){
    1a7a:	02054a63          	bltz	a0,1aae <forkfork+0x56>
    if(pid == 0){
    1a7e:	c531                	beqz	a0,1aca <forkfork+0x72>
    wait(&xstatus);
    1a80:	fdc40513          	addi	a0,s0,-36
    1a84:	00004097          	auipc	ra,0x4
    1a88:	c22080e7          	jalr	-990(ra) # 56a6 <wait>
    if(xstatus != 0) {
    1a8c:	fdc42783          	lw	a5,-36(s0)
    1a90:	ebbd                	bnez	a5,1b06 <forkfork+0xae>
    wait(&xstatus);
    1a92:	fdc40513          	addi	a0,s0,-36
    1a96:	00004097          	auipc	ra,0x4
    1a9a:	c10080e7          	jalr	-1008(ra) # 56a6 <wait>
    if(xstatus != 0) {
    1a9e:	fdc42783          	lw	a5,-36(s0)
    1aa2:	e3b5                	bnez	a5,1b06 <forkfork+0xae>
}
    1aa4:	70a2                	ld	ra,40(sp)
    1aa6:	7402                	ld	s0,32(sp)
    1aa8:	64e2                	ld	s1,24(sp)
    1aaa:	6145                	addi	sp,sp,48
    1aac:	8082                	ret
      printf("%s: fork failed", s);
    1aae:	85a6                	mv	a1,s1
    1ab0:	00005517          	auipc	a0,0x5
    1ab4:	e7050513          	addi	a0,a0,-400 # 6920 <malloc+0xe34>
    1ab8:	00004097          	auipc	ra,0x4
    1abc:	f76080e7          	jalr	-138(ra) # 5a2e <printf>
      exit(1);
    1ac0:	4505                	li	a0,1
    1ac2:	00004097          	auipc	ra,0x4
    1ac6:	bdc080e7          	jalr	-1060(ra) # 569e <exit>
{
    1aca:	0c800493          	li	s1,200
        int pid1 = fork();
    1ace:	00004097          	auipc	ra,0x4
    1ad2:	bc8080e7          	jalr	-1080(ra) # 5696 <fork>
        if(pid1 < 0){
    1ad6:	00054f63          	bltz	a0,1af4 <forkfork+0x9c>
        if(pid1 == 0){
    1ada:	c115                	beqz	a0,1afe <forkfork+0xa6>
        wait(0);
    1adc:	4501                	li	a0,0
    1ade:	00004097          	auipc	ra,0x4
    1ae2:	bc8080e7          	jalr	-1080(ra) # 56a6 <wait>
      for(int j = 0; j < 200; j++){
    1ae6:	34fd                	addiw	s1,s1,-1
    1ae8:	f0fd                	bnez	s1,1ace <forkfork+0x76>
      exit(0);
    1aea:	4501                	li	a0,0
    1aec:	00004097          	auipc	ra,0x4
    1af0:	bb2080e7          	jalr	-1102(ra) # 569e <exit>
          exit(1);
    1af4:	4505                	li	a0,1
    1af6:	00004097          	auipc	ra,0x4
    1afa:	ba8080e7          	jalr	-1112(ra) # 569e <exit>
          exit(0);
    1afe:	00004097          	auipc	ra,0x4
    1b02:	ba0080e7          	jalr	-1120(ra) # 569e <exit>
      printf("%s: fork in child failed", s);
    1b06:	85a6                	mv	a1,s1
    1b08:	00005517          	auipc	a0,0x5
    1b0c:	e2850513          	addi	a0,a0,-472 # 6930 <malloc+0xe44>
    1b10:	00004097          	auipc	ra,0x4
    1b14:	f1e080e7          	jalr	-226(ra) # 5a2e <printf>
      exit(1);
    1b18:	4505                	li	a0,1
    1b1a:	00004097          	auipc	ra,0x4
    1b1e:	b84080e7          	jalr	-1148(ra) # 569e <exit>

0000000000001b22 <reparent2>:
{
    1b22:	1101                	addi	sp,sp,-32
    1b24:	ec06                	sd	ra,24(sp)
    1b26:	e822                	sd	s0,16(sp)
    1b28:	e426                	sd	s1,8(sp)
    1b2a:	1000                	addi	s0,sp,32
    1b2c:	32000493          	li	s1,800
    int pid1 = fork();
    1b30:	00004097          	auipc	ra,0x4
    1b34:	b66080e7          	jalr	-1178(ra) # 5696 <fork>
    if(pid1 < 0){
    1b38:	00054f63          	bltz	a0,1b56 <reparent2+0x34>
    if(pid1 == 0){
    1b3c:	c915                	beqz	a0,1b70 <reparent2+0x4e>
    wait(0);
    1b3e:	4501                	li	a0,0
    1b40:	00004097          	auipc	ra,0x4
    1b44:	b66080e7          	jalr	-1178(ra) # 56a6 <wait>
  for(int i = 0; i < 800; i++){
    1b48:	34fd                	addiw	s1,s1,-1
    1b4a:	f0fd                	bnez	s1,1b30 <reparent2+0xe>
  exit(0);
    1b4c:	4501                	li	a0,0
    1b4e:	00004097          	auipc	ra,0x4
    1b52:	b50080e7          	jalr	-1200(ra) # 569e <exit>
      printf("fork failed\n");
    1b56:	00005517          	auipc	a0,0x5
    1b5a:	01250513          	addi	a0,a0,18 # 6b68 <malloc+0x107c>
    1b5e:	00004097          	auipc	ra,0x4
    1b62:	ed0080e7          	jalr	-304(ra) # 5a2e <printf>
      exit(1);
    1b66:	4505                	li	a0,1
    1b68:	00004097          	auipc	ra,0x4
    1b6c:	b36080e7          	jalr	-1226(ra) # 569e <exit>
      fork();
    1b70:	00004097          	auipc	ra,0x4
    1b74:	b26080e7          	jalr	-1242(ra) # 5696 <fork>
      fork();
    1b78:	00004097          	auipc	ra,0x4
    1b7c:	b1e080e7          	jalr	-1250(ra) # 5696 <fork>
      exit(0);
    1b80:	4501                	li	a0,0
    1b82:	00004097          	auipc	ra,0x4
    1b86:	b1c080e7          	jalr	-1252(ra) # 569e <exit>

0000000000001b8a <createdelete>:
{
    1b8a:	7175                	addi	sp,sp,-144
    1b8c:	e506                	sd	ra,136(sp)
    1b8e:	e122                	sd	s0,128(sp)
    1b90:	fca6                	sd	s1,120(sp)
    1b92:	f8ca                	sd	s2,112(sp)
    1b94:	f4ce                	sd	s3,104(sp)
    1b96:	f0d2                	sd	s4,96(sp)
    1b98:	ecd6                	sd	s5,88(sp)
    1b9a:	e8da                	sd	s6,80(sp)
    1b9c:	e4de                	sd	s7,72(sp)
    1b9e:	e0e2                	sd	s8,64(sp)
    1ba0:	fc66                	sd	s9,56(sp)
    1ba2:	0900                	addi	s0,sp,144
    1ba4:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1ba6:	4901                	li	s2,0
    1ba8:	4991                	li	s3,4
    pid = fork();
    1baa:	00004097          	auipc	ra,0x4
    1bae:	aec080e7          	jalr	-1300(ra) # 5696 <fork>
    1bb2:	84aa                	mv	s1,a0
    if(pid < 0){
    1bb4:	02054f63          	bltz	a0,1bf2 <createdelete+0x68>
    if(pid == 0){
    1bb8:	c939                	beqz	a0,1c0e <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1bba:	2905                	addiw	s2,s2,1
    1bbc:	ff3917e3          	bne	s2,s3,1baa <createdelete+0x20>
    1bc0:	4491                	li	s1,4
    wait(&xstatus);
    1bc2:	f7c40513          	addi	a0,s0,-132
    1bc6:	00004097          	auipc	ra,0x4
    1bca:	ae0080e7          	jalr	-1312(ra) # 56a6 <wait>
    if(xstatus != 0)
    1bce:	f7c42903          	lw	s2,-132(s0)
    1bd2:	0e091263          	bnez	s2,1cb6 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1bd6:	34fd                	addiw	s1,s1,-1
    1bd8:	f4ed                	bnez	s1,1bc2 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1bda:	f8040123          	sb	zero,-126(s0)
    1bde:	03000993          	li	s3,48
    1be2:	5a7d                	li	s4,-1
    1be4:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1be8:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1bea:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1bec:	07400a93          	li	s5,116
    1bf0:	a29d                	j	1d56 <createdelete+0x1cc>
      printf("fork failed\n", s);
    1bf2:	85e6                	mv	a1,s9
    1bf4:	00005517          	auipc	a0,0x5
    1bf8:	f7450513          	addi	a0,a0,-140 # 6b68 <malloc+0x107c>
    1bfc:	00004097          	auipc	ra,0x4
    1c00:	e32080e7          	jalr	-462(ra) # 5a2e <printf>
      exit(1);
    1c04:	4505                	li	a0,1
    1c06:	00004097          	auipc	ra,0x4
    1c0a:	a98080e7          	jalr	-1384(ra) # 569e <exit>
      name[0] = 'p' + pi;
    1c0e:	0709091b          	addiw	s2,s2,112
    1c12:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1c16:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1c1a:	4951                	li	s2,20
    1c1c:	a015                	j	1c40 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1c1e:	85e6                	mv	a1,s9
    1c20:	00005517          	auipc	a0,0x5
    1c24:	bd850513          	addi	a0,a0,-1064 # 67f8 <malloc+0xd0c>
    1c28:	00004097          	auipc	ra,0x4
    1c2c:	e06080e7          	jalr	-506(ra) # 5a2e <printf>
          exit(1);
    1c30:	4505                	li	a0,1
    1c32:	00004097          	auipc	ra,0x4
    1c36:	a6c080e7          	jalr	-1428(ra) # 569e <exit>
      for(i = 0; i < N; i++){
    1c3a:	2485                	addiw	s1,s1,1
    1c3c:	07248863          	beq	s1,s2,1cac <createdelete+0x122>
        name[1] = '0' + i;
    1c40:	0304879b          	addiw	a5,s1,48
    1c44:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1c48:	20200593          	li	a1,514
    1c4c:	f8040513          	addi	a0,s0,-128
    1c50:	00004097          	auipc	ra,0x4
    1c54:	a8e080e7          	jalr	-1394(ra) # 56de <open>
        if(fd < 0){
    1c58:	fc0543e3          	bltz	a0,1c1e <createdelete+0x94>
        close(fd);
    1c5c:	00004097          	auipc	ra,0x4
    1c60:	a6a080e7          	jalr	-1430(ra) # 56c6 <close>
        if(i > 0 && (i % 2 ) == 0){
    1c64:	fc905be3          	blez	s1,1c3a <createdelete+0xb0>
    1c68:	0014f793          	andi	a5,s1,1
    1c6c:	f7f9                	bnez	a5,1c3a <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1c6e:	01f4d79b          	srliw	a5,s1,0x1f
    1c72:	9fa5                	addw	a5,a5,s1
    1c74:	4017d79b          	sraiw	a5,a5,0x1
    1c78:	0307879b          	addiw	a5,a5,48
    1c7c:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1c80:	f8040513          	addi	a0,s0,-128
    1c84:	00004097          	auipc	ra,0x4
    1c88:	a6a080e7          	jalr	-1430(ra) # 56ee <unlink>
    1c8c:	fa0557e3          	bgez	a0,1c3a <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1c90:	85e6                	mv	a1,s9
    1c92:	00005517          	auipc	a0,0x5
    1c96:	cbe50513          	addi	a0,a0,-834 # 6950 <malloc+0xe64>
    1c9a:	00004097          	auipc	ra,0x4
    1c9e:	d94080e7          	jalr	-620(ra) # 5a2e <printf>
            exit(1);
    1ca2:	4505                	li	a0,1
    1ca4:	00004097          	auipc	ra,0x4
    1ca8:	9fa080e7          	jalr	-1542(ra) # 569e <exit>
      exit(0);
    1cac:	4501                	li	a0,0
    1cae:	00004097          	auipc	ra,0x4
    1cb2:	9f0080e7          	jalr	-1552(ra) # 569e <exit>
      exit(1);
    1cb6:	4505                	li	a0,1
    1cb8:	00004097          	auipc	ra,0x4
    1cbc:	9e6080e7          	jalr	-1562(ra) # 569e <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1cc0:	f8040613          	addi	a2,s0,-128
    1cc4:	85e6                	mv	a1,s9
    1cc6:	00005517          	auipc	a0,0x5
    1cca:	ca250513          	addi	a0,a0,-862 # 6968 <malloc+0xe7c>
    1cce:	00004097          	auipc	ra,0x4
    1cd2:	d60080e7          	jalr	-672(ra) # 5a2e <printf>
        exit(1);
    1cd6:	4505                	li	a0,1
    1cd8:	00004097          	auipc	ra,0x4
    1cdc:	9c6080e7          	jalr	-1594(ra) # 569e <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1ce0:	054b7163          	bgeu	s6,s4,1d22 <createdelete+0x198>
      if(fd >= 0)
    1ce4:	02055a63          	bgez	a0,1d18 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1ce8:	2485                	addiw	s1,s1,1
    1cea:	0ff4f493          	andi	s1,s1,255
    1cee:	05548c63          	beq	s1,s5,1d46 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1cf2:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1cf6:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1cfa:	4581                	li	a1,0
    1cfc:	f8040513          	addi	a0,s0,-128
    1d00:	00004097          	auipc	ra,0x4
    1d04:	9de080e7          	jalr	-1570(ra) # 56de <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1d08:	00090463          	beqz	s2,1d10 <createdelete+0x186>
    1d0c:	fd2bdae3          	bge	s7,s2,1ce0 <createdelete+0x156>
    1d10:	fa0548e3          	bltz	a0,1cc0 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d14:	014b7963          	bgeu	s6,s4,1d26 <createdelete+0x19c>
        close(fd);
    1d18:	00004097          	auipc	ra,0x4
    1d1c:	9ae080e7          	jalr	-1618(ra) # 56c6 <close>
    1d20:	b7e1                	j	1ce8 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d22:	fc0543e3          	bltz	a0,1ce8 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1d26:	f8040613          	addi	a2,s0,-128
    1d2a:	85e6                	mv	a1,s9
    1d2c:	00005517          	auipc	a0,0x5
    1d30:	c6450513          	addi	a0,a0,-924 # 6990 <malloc+0xea4>
    1d34:	00004097          	auipc	ra,0x4
    1d38:	cfa080e7          	jalr	-774(ra) # 5a2e <printf>
        exit(1);
    1d3c:	4505                	li	a0,1
    1d3e:	00004097          	auipc	ra,0x4
    1d42:	960080e7          	jalr	-1696(ra) # 569e <exit>
  for(i = 0; i < N; i++){
    1d46:	2905                	addiw	s2,s2,1
    1d48:	2a05                	addiw	s4,s4,1
    1d4a:	2985                	addiw	s3,s3,1
    1d4c:	0ff9f993          	andi	s3,s3,255
    1d50:	47d1                	li	a5,20
    1d52:	02f90a63          	beq	s2,a5,1d86 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1d56:	84e2                	mv	s1,s8
    1d58:	bf69                	j	1cf2 <createdelete+0x168>
  for(i = 0; i < N; i++){
    1d5a:	2905                	addiw	s2,s2,1
    1d5c:	0ff97913          	andi	s2,s2,255
    1d60:	2985                	addiw	s3,s3,1
    1d62:	0ff9f993          	andi	s3,s3,255
    1d66:	03490863          	beq	s2,s4,1d96 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1d6a:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1d6c:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1d70:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1d74:	f8040513          	addi	a0,s0,-128
    1d78:	00004097          	auipc	ra,0x4
    1d7c:	976080e7          	jalr	-1674(ra) # 56ee <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1d80:	34fd                	addiw	s1,s1,-1
    1d82:	f4ed                	bnez	s1,1d6c <createdelete+0x1e2>
    1d84:	bfd9                	j	1d5a <createdelete+0x1d0>
    1d86:	03000993          	li	s3,48
    1d8a:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1d8e:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1d90:	08400a13          	li	s4,132
    1d94:	bfd9                	j	1d6a <createdelete+0x1e0>
}
    1d96:	60aa                	ld	ra,136(sp)
    1d98:	640a                	ld	s0,128(sp)
    1d9a:	74e6                	ld	s1,120(sp)
    1d9c:	7946                	ld	s2,112(sp)
    1d9e:	79a6                	ld	s3,104(sp)
    1da0:	7a06                	ld	s4,96(sp)
    1da2:	6ae6                	ld	s5,88(sp)
    1da4:	6b46                	ld	s6,80(sp)
    1da6:	6ba6                	ld	s7,72(sp)
    1da8:	6c06                	ld	s8,64(sp)
    1daa:	7ce2                	ld	s9,56(sp)
    1dac:	6149                	addi	sp,sp,144
    1dae:	8082                	ret

0000000000001db0 <linkunlink>:
{
    1db0:	711d                	addi	sp,sp,-96
    1db2:	ec86                	sd	ra,88(sp)
    1db4:	e8a2                	sd	s0,80(sp)
    1db6:	e4a6                	sd	s1,72(sp)
    1db8:	e0ca                	sd	s2,64(sp)
    1dba:	fc4e                	sd	s3,56(sp)
    1dbc:	f852                	sd	s4,48(sp)
    1dbe:	f456                	sd	s5,40(sp)
    1dc0:	f05a                	sd	s6,32(sp)
    1dc2:	ec5e                	sd	s7,24(sp)
    1dc4:	e862                	sd	s8,16(sp)
    1dc6:	e466                	sd	s9,8(sp)
    1dc8:	1080                	addi	s0,sp,96
    1dca:	84aa                	mv	s1,a0
  unlink("x");
    1dcc:	00004517          	auipc	a0,0x4
    1dd0:	1cc50513          	addi	a0,a0,460 # 5f98 <malloc+0x4ac>
    1dd4:	00004097          	auipc	ra,0x4
    1dd8:	91a080e7          	jalr	-1766(ra) # 56ee <unlink>
  pid = fork();
    1ddc:	00004097          	auipc	ra,0x4
    1de0:	8ba080e7          	jalr	-1862(ra) # 5696 <fork>
  if(pid < 0){
    1de4:	02054b63          	bltz	a0,1e1a <linkunlink+0x6a>
    1de8:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1dea:	4c85                	li	s9,1
    1dec:	e119                	bnez	a0,1df2 <linkunlink+0x42>
    1dee:	06100c93          	li	s9,97
    1df2:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1df6:	41c659b7          	lui	s3,0x41c65
    1dfa:	e6d9899b          	addiw	s3,s3,-403
    1dfe:	690d                	lui	s2,0x3
    1e00:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1e04:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1e06:	4b05                	li	s6,1
      unlink("x");
    1e08:	00004a97          	auipc	s5,0x4
    1e0c:	190a8a93          	addi	s5,s5,400 # 5f98 <malloc+0x4ac>
      link("cat", "x");
    1e10:	00005b97          	auipc	s7,0x5
    1e14:	ba8b8b93          	addi	s7,s7,-1112 # 69b8 <malloc+0xecc>
    1e18:	a825                	j	1e50 <linkunlink+0xa0>
    printf("%s: fork failed\n", s);
    1e1a:	85a6                	mv	a1,s1
    1e1c:	00005517          	auipc	a0,0x5
    1e20:	94450513          	addi	a0,a0,-1724 # 6760 <malloc+0xc74>
    1e24:	00004097          	auipc	ra,0x4
    1e28:	c0a080e7          	jalr	-1014(ra) # 5a2e <printf>
    exit(1);
    1e2c:	4505                	li	a0,1
    1e2e:	00004097          	auipc	ra,0x4
    1e32:	870080e7          	jalr	-1936(ra) # 569e <exit>
      close(open("x", O_RDWR | O_CREATE));
    1e36:	20200593          	li	a1,514
    1e3a:	8556                	mv	a0,s5
    1e3c:	00004097          	auipc	ra,0x4
    1e40:	8a2080e7          	jalr	-1886(ra) # 56de <open>
    1e44:	00004097          	auipc	ra,0x4
    1e48:	882080e7          	jalr	-1918(ra) # 56c6 <close>
  for(i = 0; i < 100; i++){
    1e4c:	34fd                	addiw	s1,s1,-1
    1e4e:	c88d                	beqz	s1,1e80 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1e50:	033c87bb          	mulw	a5,s9,s3
    1e54:	012787bb          	addw	a5,a5,s2
    1e58:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1e5c:	0347f7bb          	remuw	a5,a5,s4
    1e60:	dbf9                	beqz	a5,1e36 <linkunlink+0x86>
    } else if((x % 3) == 1){
    1e62:	01678863          	beq	a5,s6,1e72 <linkunlink+0xc2>
      unlink("x");
    1e66:	8556                	mv	a0,s5
    1e68:	00004097          	auipc	ra,0x4
    1e6c:	886080e7          	jalr	-1914(ra) # 56ee <unlink>
    1e70:	bff1                	j	1e4c <linkunlink+0x9c>
      link("cat", "x");
    1e72:	85d6                	mv	a1,s5
    1e74:	855e                	mv	a0,s7
    1e76:	00004097          	auipc	ra,0x4
    1e7a:	888080e7          	jalr	-1912(ra) # 56fe <link>
    1e7e:	b7f9                	j	1e4c <linkunlink+0x9c>
  if(pid)
    1e80:	020c0463          	beqz	s8,1ea8 <linkunlink+0xf8>
    wait(0);
    1e84:	4501                	li	a0,0
    1e86:	00004097          	auipc	ra,0x4
    1e8a:	820080e7          	jalr	-2016(ra) # 56a6 <wait>
}
    1e8e:	60e6                	ld	ra,88(sp)
    1e90:	6446                	ld	s0,80(sp)
    1e92:	64a6                	ld	s1,72(sp)
    1e94:	6906                	ld	s2,64(sp)
    1e96:	79e2                	ld	s3,56(sp)
    1e98:	7a42                	ld	s4,48(sp)
    1e9a:	7aa2                	ld	s5,40(sp)
    1e9c:	7b02                	ld	s6,32(sp)
    1e9e:	6be2                	ld	s7,24(sp)
    1ea0:	6c42                	ld	s8,16(sp)
    1ea2:	6ca2                	ld	s9,8(sp)
    1ea4:	6125                	addi	sp,sp,96
    1ea6:	8082                	ret
    exit(0);
    1ea8:	4501                	li	a0,0
    1eaa:	00003097          	auipc	ra,0x3
    1eae:	7f4080e7          	jalr	2036(ra) # 569e <exit>

0000000000001eb2 <manywrites>:
{
    1eb2:	711d                	addi	sp,sp,-96
    1eb4:	ec86                	sd	ra,88(sp)
    1eb6:	e8a2                	sd	s0,80(sp)
    1eb8:	e4a6                	sd	s1,72(sp)
    1eba:	e0ca                	sd	s2,64(sp)
    1ebc:	fc4e                	sd	s3,56(sp)
    1ebe:	f852                	sd	s4,48(sp)
    1ec0:	f456                	sd	s5,40(sp)
    1ec2:	f05a                	sd	s6,32(sp)
    1ec4:	ec5e                	sd	s7,24(sp)
    1ec6:	1080                	addi	s0,sp,96
    1ec8:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    1eca:	4981                	li	s3,0
    1ecc:	4911                	li	s2,4
    int pid = fork();
    1ece:	00003097          	auipc	ra,0x3
    1ed2:	7c8080e7          	jalr	1992(ra) # 5696 <fork>
    1ed6:	84aa                	mv	s1,a0
    if(pid < 0){
    1ed8:	02054963          	bltz	a0,1f0a <manywrites+0x58>
    if(pid == 0){
    1edc:	c521                	beqz	a0,1f24 <manywrites+0x72>
  for(int ci = 0; ci < nchildren; ci++){
    1ede:	2985                	addiw	s3,s3,1
    1ee0:	ff2997e3          	bne	s3,s2,1ece <manywrites+0x1c>
    1ee4:	4491                	li	s1,4
    int st = 0;
    1ee6:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    1eea:	fa840513          	addi	a0,s0,-88
    1eee:	00003097          	auipc	ra,0x3
    1ef2:	7b8080e7          	jalr	1976(ra) # 56a6 <wait>
    if(st != 0)
    1ef6:	fa842503          	lw	a0,-88(s0)
    1efa:	ed6d                	bnez	a0,1ff4 <manywrites+0x142>
  for(int ci = 0; ci < nchildren; ci++){
    1efc:	34fd                	addiw	s1,s1,-1
    1efe:	f4e5                	bnez	s1,1ee6 <manywrites+0x34>
  exit(0);
    1f00:	4501                	li	a0,0
    1f02:	00003097          	auipc	ra,0x3
    1f06:	79c080e7          	jalr	1948(ra) # 569e <exit>
      printf("fork failed\n");
    1f0a:	00005517          	auipc	a0,0x5
    1f0e:	c5e50513          	addi	a0,a0,-930 # 6b68 <malloc+0x107c>
    1f12:	00004097          	auipc	ra,0x4
    1f16:	b1c080e7          	jalr	-1252(ra) # 5a2e <printf>
      exit(1);
    1f1a:	4505                	li	a0,1
    1f1c:	00003097          	auipc	ra,0x3
    1f20:	782080e7          	jalr	1922(ra) # 569e <exit>
      name[0] = 'b';
    1f24:	06200793          	li	a5,98
    1f28:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    1f2c:	0619879b          	addiw	a5,s3,97
    1f30:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    1f34:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    1f38:	fa840513          	addi	a0,s0,-88
    1f3c:	00003097          	auipc	ra,0x3
    1f40:	7b2080e7          	jalr	1970(ra) # 56ee <unlink>
    1f44:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    1f46:	0000ab17          	auipc	s6,0xa
    1f4a:	c0ab0b13          	addi	s6,s6,-1014 # bb50 <buf>
        for(int i = 0; i < ci+1; i++){
    1f4e:	8a26                	mv	s4,s1
    1f50:	0209ce63          	bltz	s3,1f8c <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    1f54:	20200593          	li	a1,514
    1f58:	fa840513          	addi	a0,s0,-88
    1f5c:	00003097          	auipc	ra,0x3
    1f60:	782080e7          	jalr	1922(ra) # 56de <open>
    1f64:	892a                	mv	s2,a0
          if(fd < 0){
    1f66:	04054763          	bltz	a0,1fb4 <manywrites+0x102>
          int cc = write(fd, buf, sz);
    1f6a:	660d                	lui	a2,0x3
    1f6c:	85da                	mv	a1,s6
    1f6e:	00003097          	auipc	ra,0x3
    1f72:	750080e7          	jalr	1872(ra) # 56be <write>
          if(cc != sz){
    1f76:	678d                	lui	a5,0x3
    1f78:	04f51e63          	bne	a0,a5,1fd4 <manywrites+0x122>
          close(fd);
    1f7c:	854a                	mv	a0,s2
    1f7e:	00003097          	auipc	ra,0x3
    1f82:	748080e7          	jalr	1864(ra) # 56c6 <close>
        for(int i = 0; i < ci+1; i++){
    1f86:	2a05                	addiw	s4,s4,1
    1f88:	fd49d6e3          	bge	s3,s4,1f54 <manywrites+0xa2>
        unlink(name);
    1f8c:	fa840513          	addi	a0,s0,-88
    1f90:	00003097          	auipc	ra,0x3
    1f94:	75e080e7          	jalr	1886(ra) # 56ee <unlink>
      for(int iters = 0; iters < howmany; iters++){
    1f98:	3bfd                	addiw	s7,s7,-1
    1f9a:	fa0b9ae3          	bnez	s7,1f4e <manywrites+0x9c>
      unlink(name);
    1f9e:	fa840513          	addi	a0,s0,-88
    1fa2:	00003097          	auipc	ra,0x3
    1fa6:	74c080e7          	jalr	1868(ra) # 56ee <unlink>
      exit(0);
    1faa:	4501                	li	a0,0
    1fac:	00003097          	auipc	ra,0x3
    1fb0:	6f2080e7          	jalr	1778(ra) # 569e <exit>
            printf("%s: cannot create %s\n", s, name);
    1fb4:	fa840613          	addi	a2,s0,-88
    1fb8:	85d6                	mv	a1,s5
    1fba:	00005517          	auipc	a0,0x5
    1fbe:	a0650513          	addi	a0,a0,-1530 # 69c0 <malloc+0xed4>
    1fc2:	00004097          	auipc	ra,0x4
    1fc6:	a6c080e7          	jalr	-1428(ra) # 5a2e <printf>
            exit(1);
    1fca:	4505                	li	a0,1
    1fcc:	00003097          	auipc	ra,0x3
    1fd0:	6d2080e7          	jalr	1746(ra) # 569e <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    1fd4:	86aa                	mv	a3,a0
    1fd6:	660d                	lui	a2,0x3
    1fd8:	85d6                	mv	a1,s5
    1fda:	00004517          	auipc	a0,0x4
    1fde:	00e50513          	addi	a0,a0,14 # 5fe8 <malloc+0x4fc>
    1fe2:	00004097          	auipc	ra,0x4
    1fe6:	a4c080e7          	jalr	-1460(ra) # 5a2e <printf>
            exit(1);
    1fea:	4505                	li	a0,1
    1fec:	00003097          	auipc	ra,0x3
    1ff0:	6b2080e7          	jalr	1714(ra) # 569e <exit>
      exit(st);
    1ff4:	00003097          	auipc	ra,0x3
    1ff8:	6aa080e7          	jalr	1706(ra) # 569e <exit>

0000000000001ffc <forktest>:
{
    1ffc:	7179                	addi	sp,sp,-48
    1ffe:	f406                	sd	ra,40(sp)
    2000:	f022                	sd	s0,32(sp)
    2002:	ec26                	sd	s1,24(sp)
    2004:	e84a                	sd	s2,16(sp)
    2006:	e44e                	sd	s3,8(sp)
    2008:	1800                	addi	s0,sp,48
    200a:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    200c:	4481                	li	s1,0
    200e:	3e800913          	li	s2,1000
    pid = fork();
    2012:	00003097          	auipc	ra,0x3
    2016:	684080e7          	jalr	1668(ra) # 5696 <fork>
    if(pid < 0)
    201a:	02054863          	bltz	a0,204a <forktest+0x4e>
    if(pid == 0)
    201e:	c115                	beqz	a0,2042 <forktest+0x46>
  for(n=0; n<N; n++){
    2020:	2485                	addiw	s1,s1,1
    2022:	ff2498e3          	bne	s1,s2,2012 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    2026:	85ce                	mv	a1,s3
    2028:	00005517          	auipc	a0,0x5
    202c:	9c850513          	addi	a0,a0,-1592 # 69f0 <malloc+0xf04>
    2030:	00004097          	auipc	ra,0x4
    2034:	9fe080e7          	jalr	-1538(ra) # 5a2e <printf>
    exit(1);
    2038:	4505                	li	a0,1
    203a:	00003097          	auipc	ra,0x3
    203e:	664080e7          	jalr	1636(ra) # 569e <exit>
      exit(0);
    2042:	00003097          	auipc	ra,0x3
    2046:	65c080e7          	jalr	1628(ra) # 569e <exit>
  if (n == 0) {
    204a:	cc9d                	beqz	s1,2088 <forktest+0x8c>
  if(n == N){
    204c:	3e800793          	li	a5,1000
    2050:	fcf48be3          	beq	s1,a5,2026 <forktest+0x2a>
  for(; n > 0; n--){
    2054:	00905b63          	blez	s1,206a <forktest+0x6e>
    if(wait(0) < 0){
    2058:	4501                	li	a0,0
    205a:	00003097          	auipc	ra,0x3
    205e:	64c080e7          	jalr	1612(ra) # 56a6 <wait>
    2062:	04054163          	bltz	a0,20a4 <forktest+0xa8>
  for(; n > 0; n--){
    2066:	34fd                	addiw	s1,s1,-1
    2068:	f8e5                	bnez	s1,2058 <forktest+0x5c>
  if(wait(0) != -1){
    206a:	4501                	li	a0,0
    206c:	00003097          	auipc	ra,0x3
    2070:	63a080e7          	jalr	1594(ra) # 56a6 <wait>
    2074:	57fd                	li	a5,-1
    2076:	04f51563          	bne	a0,a5,20c0 <forktest+0xc4>
}
    207a:	70a2                	ld	ra,40(sp)
    207c:	7402                	ld	s0,32(sp)
    207e:	64e2                	ld	s1,24(sp)
    2080:	6942                	ld	s2,16(sp)
    2082:	69a2                	ld	s3,8(sp)
    2084:	6145                	addi	sp,sp,48
    2086:	8082                	ret
    printf("%s: no fork at all!\n", s);
    2088:	85ce                	mv	a1,s3
    208a:	00005517          	auipc	a0,0x5
    208e:	94e50513          	addi	a0,a0,-1714 # 69d8 <malloc+0xeec>
    2092:	00004097          	auipc	ra,0x4
    2096:	99c080e7          	jalr	-1636(ra) # 5a2e <printf>
    exit(1);
    209a:	4505                	li	a0,1
    209c:	00003097          	auipc	ra,0x3
    20a0:	602080e7          	jalr	1538(ra) # 569e <exit>
      printf("%s: wait stopped early\n", s);
    20a4:	85ce                	mv	a1,s3
    20a6:	00005517          	auipc	a0,0x5
    20aa:	97250513          	addi	a0,a0,-1678 # 6a18 <malloc+0xf2c>
    20ae:	00004097          	auipc	ra,0x4
    20b2:	980080e7          	jalr	-1664(ra) # 5a2e <printf>
      exit(1);
    20b6:	4505                	li	a0,1
    20b8:	00003097          	auipc	ra,0x3
    20bc:	5e6080e7          	jalr	1510(ra) # 569e <exit>
    printf("%s: wait got too many\n", s);
    20c0:	85ce                	mv	a1,s3
    20c2:	00005517          	auipc	a0,0x5
    20c6:	96e50513          	addi	a0,a0,-1682 # 6a30 <malloc+0xf44>
    20ca:	00004097          	auipc	ra,0x4
    20ce:	964080e7          	jalr	-1692(ra) # 5a2e <printf>
    exit(1);
    20d2:	4505                	li	a0,1
    20d4:	00003097          	auipc	ra,0x3
    20d8:	5ca080e7          	jalr	1482(ra) # 569e <exit>

00000000000020dc <kernmem>:
{
    20dc:	715d                	addi	sp,sp,-80
    20de:	e486                	sd	ra,72(sp)
    20e0:	e0a2                	sd	s0,64(sp)
    20e2:	fc26                	sd	s1,56(sp)
    20e4:	f84a                	sd	s2,48(sp)
    20e6:	f44e                	sd	s3,40(sp)
    20e8:	f052                	sd	s4,32(sp)
    20ea:	ec56                	sd	s5,24(sp)
    20ec:	0880                	addi	s0,sp,80
    20ee:	8a2a                	mv	s4,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    20f0:	4485                	li	s1,1
    20f2:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    20f4:	5afd                	li	s5,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    20f6:	69b1                	lui	s3,0xc
    20f8:	35098993          	addi	s3,s3,848 # c350 <buf+0x800>
    20fc:	1003d937          	lui	s2,0x1003d
    2100:	090e                	slli	s2,s2,0x3
    2102:	48090913          	addi	s2,s2,1152 # 1003d480 <__BSS_END__+0x1002e920>
    pid = fork();
    2106:	00003097          	auipc	ra,0x3
    210a:	590080e7          	jalr	1424(ra) # 5696 <fork>
    if(pid < 0){
    210e:	02054963          	bltz	a0,2140 <kernmem+0x64>
    if(pid == 0){
    2112:	c529                	beqz	a0,215c <kernmem+0x80>
    wait(&xstatus);
    2114:	fbc40513          	addi	a0,s0,-68
    2118:	00003097          	auipc	ra,0x3
    211c:	58e080e7          	jalr	1422(ra) # 56a6 <wait>
    if(xstatus != -1)  // did kernel kill child?
    2120:	fbc42783          	lw	a5,-68(s0)
    2124:	05579d63          	bne	a5,s5,217e <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2128:	94ce                	add	s1,s1,s3
    212a:	fd249ee3          	bne	s1,s2,2106 <kernmem+0x2a>
}
    212e:	60a6                	ld	ra,72(sp)
    2130:	6406                	ld	s0,64(sp)
    2132:	74e2                	ld	s1,56(sp)
    2134:	7942                	ld	s2,48(sp)
    2136:	79a2                	ld	s3,40(sp)
    2138:	7a02                	ld	s4,32(sp)
    213a:	6ae2                	ld	s5,24(sp)
    213c:	6161                	addi	sp,sp,80
    213e:	8082                	ret
      printf("%s: fork failed\n", s);
    2140:	85d2                	mv	a1,s4
    2142:	00004517          	auipc	a0,0x4
    2146:	61e50513          	addi	a0,a0,1566 # 6760 <malloc+0xc74>
    214a:	00004097          	auipc	ra,0x4
    214e:	8e4080e7          	jalr	-1820(ra) # 5a2e <printf>
      exit(1);
    2152:	4505                	li	a0,1
    2154:	00003097          	auipc	ra,0x3
    2158:	54a080e7          	jalr	1354(ra) # 569e <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    215c:	0004c683          	lbu	a3,0(s1)
    2160:	8626                	mv	a2,s1
    2162:	85d2                	mv	a1,s4
    2164:	00005517          	auipc	a0,0x5
    2168:	8e450513          	addi	a0,a0,-1820 # 6a48 <malloc+0xf5c>
    216c:	00004097          	auipc	ra,0x4
    2170:	8c2080e7          	jalr	-1854(ra) # 5a2e <printf>
      exit(1);
    2174:	4505                	li	a0,1
    2176:	00003097          	auipc	ra,0x3
    217a:	528080e7          	jalr	1320(ra) # 569e <exit>
      exit(1);
    217e:	4505                	li	a0,1
    2180:	00003097          	auipc	ra,0x3
    2184:	51e080e7          	jalr	1310(ra) # 569e <exit>

0000000000002188 <bigargtest>:
{
    2188:	7179                	addi	sp,sp,-48
    218a:	f406                	sd	ra,40(sp)
    218c:	f022                	sd	s0,32(sp)
    218e:	ec26                	sd	s1,24(sp)
    2190:	1800                	addi	s0,sp,48
    2192:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    2194:	00005517          	auipc	a0,0x5
    2198:	8d450513          	addi	a0,a0,-1836 # 6a68 <malloc+0xf7c>
    219c:	00003097          	auipc	ra,0x3
    21a0:	552080e7          	jalr	1362(ra) # 56ee <unlink>
  pid = fork();
    21a4:	00003097          	auipc	ra,0x3
    21a8:	4f2080e7          	jalr	1266(ra) # 5696 <fork>
  if(pid == 0){
    21ac:	c121                	beqz	a0,21ec <bigargtest+0x64>
  } else if(pid < 0){
    21ae:	0a054063          	bltz	a0,224e <bigargtest+0xc6>
  wait(&xstatus);
    21b2:	fdc40513          	addi	a0,s0,-36
    21b6:	00003097          	auipc	ra,0x3
    21ba:	4f0080e7          	jalr	1264(ra) # 56a6 <wait>
  if(xstatus != 0)
    21be:	fdc42503          	lw	a0,-36(s0)
    21c2:	e545                	bnez	a0,226a <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    21c4:	4581                	li	a1,0
    21c6:	00005517          	auipc	a0,0x5
    21ca:	8a250513          	addi	a0,a0,-1886 # 6a68 <malloc+0xf7c>
    21ce:	00003097          	auipc	ra,0x3
    21d2:	510080e7          	jalr	1296(ra) # 56de <open>
  if(fd < 0){
    21d6:	08054e63          	bltz	a0,2272 <bigargtest+0xea>
  close(fd);
    21da:	00003097          	auipc	ra,0x3
    21de:	4ec080e7          	jalr	1260(ra) # 56c6 <close>
}
    21e2:	70a2                	ld	ra,40(sp)
    21e4:	7402                	ld	s0,32(sp)
    21e6:	64e2                	ld	s1,24(sp)
    21e8:	6145                	addi	sp,sp,48
    21ea:	8082                	ret
    21ec:	00006797          	auipc	a5,0x6
    21f0:	14c78793          	addi	a5,a5,332 # 8338 <args.1>
    21f4:	00006697          	auipc	a3,0x6
    21f8:	23c68693          	addi	a3,a3,572 # 8430 <args.1+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    21fc:	00005717          	auipc	a4,0x5
    2200:	87c70713          	addi	a4,a4,-1924 # 6a78 <malloc+0xf8c>
    2204:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    2206:	07a1                	addi	a5,a5,8
    2208:	fed79ee3          	bne	a5,a3,2204 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    220c:	00006597          	auipc	a1,0x6
    2210:	12c58593          	addi	a1,a1,300 # 8338 <args.1>
    2214:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    2218:	00004517          	auipc	a0,0x4
    221c:	d1050513          	addi	a0,a0,-752 # 5f28 <malloc+0x43c>
    2220:	00003097          	auipc	ra,0x3
    2224:	4b6080e7          	jalr	1206(ra) # 56d6 <exec>
    fd = open("bigarg-ok", O_CREATE);
    2228:	20000593          	li	a1,512
    222c:	00005517          	auipc	a0,0x5
    2230:	83c50513          	addi	a0,a0,-1988 # 6a68 <malloc+0xf7c>
    2234:	00003097          	auipc	ra,0x3
    2238:	4aa080e7          	jalr	1194(ra) # 56de <open>
    close(fd);
    223c:	00003097          	auipc	ra,0x3
    2240:	48a080e7          	jalr	1162(ra) # 56c6 <close>
    exit(0);
    2244:	4501                	li	a0,0
    2246:	00003097          	auipc	ra,0x3
    224a:	458080e7          	jalr	1112(ra) # 569e <exit>
    printf("%s: bigargtest: fork failed\n", s);
    224e:	85a6                	mv	a1,s1
    2250:	00005517          	auipc	a0,0x5
    2254:	90850513          	addi	a0,a0,-1784 # 6b58 <malloc+0x106c>
    2258:	00003097          	auipc	ra,0x3
    225c:	7d6080e7          	jalr	2006(ra) # 5a2e <printf>
    exit(1);
    2260:	4505                	li	a0,1
    2262:	00003097          	auipc	ra,0x3
    2266:	43c080e7          	jalr	1084(ra) # 569e <exit>
    exit(xstatus);
    226a:	00003097          	auipc	ra,0x3
    226e:	434080e7          	jalr	1076(ra) # 569e <exit>
    printf("%s: bigarg test failed!\n", s);
    2272:	85a6                	mv	a1,s1
    2274:	00005517          	auipc	a0,0x5
    2278:	90450513          	addi	a0,a0,-1788 # 6b78 <malloc+0x108c>
    227c:	00003097          	auipc	ra,0x3
    2280:	7b2080e7          	jalr	1970(ra) # 5a2e <printf>
    exit(1);
    2284:	4505                	li	a0,1
    2286:	00003097          	auipc	ra,0x3
    228a:	418080e7          	jalr	1048(ra) # 569e <exit>

000000000000228e <stacktest>:
{
    228e:	7179                	addi	sp,sp,-48
    2290:	f406                	sd	ra,40(sp)
    2292:	f022                	sd	s0,32(sp)
    2294:	ec26                	sd	s1,24(sp)
    2296:	1800                	addi	s0,sp,48
    2298:	84aa                	mv	s1,a0
  pid = fork();
    229a:	00003097          	auipc	ra,0x3
    229e:	3fc080e7          	jalr	1020(ra) # 5696 <fork>
  if(pid == 0) {
    22a2:	c115                	beqz	a0,22c6 <stacktest+0x38>
  } else if(pid < 0){
    22a4:	04054463          	bltz	a0,22ec <stacktest+0x5e>
  wait(&xstatus);
    22a8:	fdc40513          	addi	a0,s0,-36
    22ac:	00003097          	auipc	ra,0x3
    22b0:	3fa080e7          	jalr	1018(ra) # 56a6 <wait>
  if(xstatus == -1)  // kernel killed child?
    22b4:	fdc42503          	lw	a0,-36(s0)
    22b8:	57fd                	li	a5,-1
    22ba:	04f50763          	beq	a0,a5,2308 <stacktest+0x7a>
    exit(xstatus);
    22be:	00003097          	auipc	ra,0x3
    22c2:	3e0080e7          	jalr	992(ra) # 569e <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    22c6:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    22c8:	77fd                	lui	a5,0xfffff
    22ca:	97ba                	add	a5,a5,a4
    22cc:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <__BSS_END__+0xffffffffffff04a0>
    22d0:	85a6                	mv	a1,s1
    22d2:	00005517          	auipc	a0,0x5
    22d6:	8c650513          	addi	a0,a0,-1850 # 6b98 <malloc+0x10ac>
    22da:	00003097          	auipc	ra,0x3
    22de:	754080e7          	jalr	1876(ra) # 5a2e <printf>
    exit(1);
    22e2:	4505                	li	a0,1
    22e4:	00003097          	auipc	ra,0x3
    22e8:	3ba080e7          	jalr	954(ra) # 569e <exit>
    printf("%s: fork failed\n", s);
    22ec:	85a6                	mv	a1,s1
    22ee:	00004517          	auipc	a0,0x4
    22f2:	47250513          	addi	a0,a0,1138 # 6760 <malloc+0xc74>
    22f6:	00003097          	auipc	ra,0x3
    22fa:	738080e7          	jalr	1848(ra) # 5a2e <printf>
    exit(1);
    22fe:	4505                	li	a0,1
    2300:	00003097          	auipc	ra,0x3
    2304:	39e080e7          	jalr	926(ra) # 569e <exit>
    exit(0);
    2308:	4501                	li	a0,0
    230a:	00003097          	auipc	ra,0x3
    230e:	394080e7          	jalr	916(ra) # 569e <exit>

0000000000002312 <copyinstr3>:
{
    2312:	7179                	addi	sp,sp,-48
    2314:	f406                	sd	ra,40(sp)
    2316:	f022                	sd	s0,32(sp)
    2318:	ec26                	sd	s1,24(sp)
    231a:	1800                	addi	s0,sp,48
  sbrk(8192);
    231c:	6509                	lui	a0,0x2
    231e:	00003097          	auipc	ra,0x3
    2322:	408080e7          	jalr	1032(ra) # 5726 <sbrk>
  uint64 top = (uint64) sbrk(0);
    2326:	4501                	li	a0,0
    2328:	00003097          	auipc	ra,0x3
    232c:	3fe080e7          	jalr	1022(ra) # 5726 <sbrk>
  if((top % PGSIZE) != 0){
    2330:	03451793          	slli	a5,a0,0x34
    2334:	e3c9                	bnez	a5,23b6 <copyinstr3+0xa4>
  top = (uint64) sbrk(0);
    2336:	4501                	li	a0,0
    2338:	00003097          	auipc	ra,0x3
    233c:	3ee080e7          	jalr	1006(ra) # 5726 <sbrk>
  if(top % PGSIZE){
    2340:	03451793          	slli	a5,a0,0x34
    2344:	e3d9                	bnez	a5,23ca <copyinstr3+0xb8>
  char *b = (char *) (top - 1);
    2346:	fff50493          	addi	s1,a0,-1 # 1fff <forktest+0x3>
  *b = 'x';
    234a:	07800793          	li	a5,120
    234e:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    2352:	8526                	mv	a0,s1
    2354:	00003097          	auipc	ra,0x3
    2358:	39a080e7          	jalr	922(ra) # 56ee <unlink>
  if(ret != -1){
    235c:	57fd                	li	a5,-1
    235e:	08f51363          	bne	a0,a5,23e4 <copyinstr3+0xd2>
  int fd = open(b, O_CREATE | O_WRONLY);
    2362:	20100593          	li	a1,513
    2366:	8526                	mv	a0,s1
    2368:	00003097          	auipc	ra,0x3
    236c:	376080e7          	jalr	886(ra) # 56de <open>
  if(fd != -1){
    2370:	57fd                	li	a5,-1
    2372:	08f51863          	bne	a0,a5,2402 <copyinstr3+0xf0>
  ret = link(b, b);
    2376:	85a6                	mv	a1,s1
    2378:	8526                	mv	a0,s1
    237a:	00003097          	auipc	ra,0x3
    237e:	384080e7          	jalr	900(ra) # 56fe <link>
  if(ret != -1){
    2382:	57fd                	li	a5,-1
    2384:	08f51e63          	bne	a0,a5,2420 <copyinstr3+0x10e>
  char *args[] = { "xx", 0 };
    2388:	00005797          	auipc	a5,0x5
    238c:	4a878793          	addi	a5,a5,1192 # 7830 <malloc+0x1d44>
    2390:	fcf43823          	sd	a5,-48(s0)
    2394:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    2398:	fd040593          	addi	a1,s0,-48
    239c:	8526                	mv	a0,s1
    239e:	00003097          	auipc	ra,0x3
    23a2:	338080e7          	jalr	824(ra) # 56d6 <exec>
  if(ret != -1){
    23a6:	57fd                	li	a5,-1
    23a8:	08f51c63          	bne	a0,a5,2440 <copyinstr3+0x12e>
}
    23ac:	70a2                	ld	ra,40(sp)
    23ae:	7402                	ld	s0,32(sp)
    23b0:	64e2                	ld	s1,24(sp)
    23b2:	6145                	addi	sp,sp,48
    23b4:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    23b6:	0347d513          	srli	a0,a5,0x34
    23ba:	6785                	lui	a5,0x1
    23bc:	40a7853b          	subw	a0,a5,a0
    23c0:	00003097          	auipc	ra,0x3
    23c4:	366080e7          	jalr	870(ra) # 5726 <sbrk>
    23c8:	b7bd                	j	2336 <copyinstr3+0x24>
    printf("oops\n");
    23ca:	00004517          	auipc	a0,0x4
    23ce:	7f650513          	addi	a0,a0,2038 # 6bc0 <malloc+0x10d4>
    23d2:	00003097          	auipc	ra,0x3
    23d6:	65c080e7          	jalr	1628(ra) # 5a2e <printf>
    exit(1);
    23da:	4505                	li	a0,1
    23dc:	00003097          	auipc	ra,0x3
    23e0:	2c2080e7          	jalr	706(ra) # 569e <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    23e4:	862a                	mv	a2,a0
    23e6:	85a6                	mv	a1,s1
    23e8:	00004517          	auipc	a0,0x4
    23ec:	29850513          	addi	a0,a0,664 # 6680 <malloc+0xb94>
    23f0:	00003097          	auipc	ra,0x3
    23f4:	63e080e7          	jalr	1598(ra) # 5a2e <printf>
    exit(1);
    23f8:	4505                	li	a0,1
    23fa:	00003097          	auipc	ra,0x3
    23fe:	2a4080e7          	jalr	676(ra) # 569e <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    2402:	862a                	mv	a2,a0
    2404:	85a6                	mv	a1,s1
    2406:	00004517          	auipc	a0,0x4
    240a:	29a50513          	addi	a0,a0,666 # 66a0 <malloc+0xbb4>
    240e:	00003097          	auipc	ra,0x3
    2412:	620080e7          	jalr	1568(ra) # 5a2e <printf>
    exit(1);
    2416:	4505                	li	a0,1
    2418:	00003097          	auipc	ra,0x3
    241c:	286080e7          	jalr	646(ra) # 569e <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    2420:	86aa                	mv	a3,a0
    2422:	8626                	mv	a2,s1
    2424:	85a6                	mv	a1,s1
    2426:	00004517          	auipc	a0,0x4
    242a:	29a50513          	addi	a0,a0,666 # 66c0 <malloc+0xbd4>
    242e:	00003097          	auipc	ra,0x3
    2432:	600080e7          	jalr	1536(ra) # 5a2e <printf>
    exit(1);
    2436:	4505                	li	a0,1
    2438:	00003097          	auipc	ra,0x3
    243c:	266080e7          	jalr	614(ra) # 569e <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    2440:	567d                	li	a2,-1
    2442:	85a6                	mv	a1,s1
    2444:	00004517          	auipc	a0,0x4
    2448:	2a450513          	addi	a0,a0,676 # 66e8 <malloc+0xbfc>
    244c:	00003097          	auipc	ra,0x3
    2450:	5e2080e7          	jalr	1506(ra) # 5a2e <printf>
    exit(1);
    2454:	4505                	li	a0,1
    2456:	00003097          	auipc	ra,0x3
    245a:	248080e7          	jalr	584(ra) # 569e <exit>

000000000000245e <rwsbrk>:
{
    245e:	1101                	addi	sp,sp,-32
    2460:	ec06                	sd	ra,24(sp)
    2462:	e822                	sd	s0,16(sp)
    2464:	e426                	sd	s1,8(sp)
    2466:	e04a                	sd	s2,0(sp)
    2468:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    246a:	6509                	lui	a0,0x2
    246c:	00003097          	auipc	ra,0x3
    2470:	2ba080e7          	jalr	698(ra) # 5726 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    2474:	57fd                	li	a5,-1
    2476:	06f50363          	beq	a0,a5,24dc <rwsbrk+0x7e>
    247a:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    247c:	7579                	lui	a0,0xffffe
    247e:	00003097          	auipc	ra,0x3
    2482:	2a8080e7          	jalr	680(ra) # 5726 <sbrk>
    2486:	57fd                	li	a5,-1
    2488:	06f50763          	beq	a0,a5,24f6 <rwsbrk+0x98>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    248c:	20100593          	li	a1,513
    2490:	00003517          	auipc	a0,0x3
    2494:	7c050513          	addi	a0,a0,1984 # 5c50 <malloc+0x164>
    2498:	00003097          	auipc	ra,0x3
    249c:	246080e7          	jalr	582(ra) # 56de <open>
    24a0:	892a                	mv	s2,a0
  if(fd < 0){
    24a2:	06054763          	bltz	a0,2510 <rwsbrk+0xb2>
  n = write(fd, (void*)(a+4096), 1024);
    24a6:	6505                	lui	a0,0x1
    24a8:	94aa                	add	s1,s1,a0
    24aa:	40000613          	li	a2,1024
    24ae:	85a6                	mv	a1,s1
    24b0:	854a                	mv	a0,s2
    24b2:	00003097          	auipc	ra,0x3
    24b6:	20c080e7          	jalr	524(ra) # 56be <write>
    24ba:	862a                	mv	a2,a0
  if(n >= 0){
    24bc:	06054763          	bltz	a0,252a <rwsbrk+0xcc>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    24c0:	85a6                	mv	a1,s1
    24c2:	00004517          	auipc	a0,0x4
    24c6:	75650513          	addi	a0,a0,1878 # 6c18 <malloc+0x112c>
    24ca:	00003097          	auipc	ra,0x3
    24ce:	564080e7          	jalr	1380(ra) # 5a2e <printf>
    exit(1);
    24d2:	4505                	li	a0,1
    24d4:	00003097          	auipc	ra,0x3
    24d8:	1ca080e7          	jalr	458(ra) # 569e <exit>
    printf("sbrk(rwsbrk) failed\n");
    24dc:	00004517          	auipc	a0,0x4
    24e0:	6ec50513          	addi	a0,a0,1772 # 6bc8 <malloc+0x10dc>
    24e4:	00003097          	auipc	ra,0x3
    24e8:	54a080e7          	jalr	1354(ra) # 5a2e <printf>
    exit(1);
    24ec:	4505                	li	a0,1
    24ee:	00003097          	auipc	ra,0x3
    24f2:	1b0080e7          	jalr	432(ra) # 569e <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    24f6:	00004517          	auipc	a0,0x4
    24fa:	6ea50513          	addi	a0,a0,1770 # 6be0 <malloc+0x10f4>
    24fe:	00003097          	auipc	ra,0x3
    2502:	530080e7          	jalr	1328(ra) # 5a2e <printf>
    exit(1);
    2506:	4505                	li	a0,1
    2508:	00003097          	auipc	ra,0x3
    250c:	196080e7          	jalr	406(ra) # 569e <exit>
    printf("open(rwsbrk) failed\n");
    2510:	00004517          	auipc	a0,0x4
    2514:	6f050513          	addi	a0,a0,1776 # 6c00 <malloc+0x1114>
    2518:	00003097          	auipc	ra,0x3
    251c:	516080e7          	jalr	1302(ra) # 5a2e <printf>
    exit(1);
    2520:	4505                	li	a0,1
    2522:	00003097          	auipc	ra,0x3
    2526:	17c080e7          	jalr	380(ra) # 569e <exit>
  close(fd);
    252a:	854a                	mv	a0,s2
    252c:	00003097          	auipc	ra,0x3
    2530:	19a080e7          	jalr	410(ra) # 56c6 <close>
  unlink("rwsbrk");
    2534:	00003517          	auipc	a0,0x3
    2538:	71c50513          	addi	a0,a0,1820 # 5c50 <malloc+0x164>
    253c:	00003097          	auipc	ra,0x3
    2540:	1b2080e7          	jalr	434(ra) # 56ee <unlink>
  fd = open("README", O_RDONLY);
    2544:	4581                	li	a1,0
    2546:	00004517          	auipc	a0,0x4
    254a:	b7a50513          	addi	a0,a0,-1158 # 60c0 <malloc+0x5d4>
    254e:	00003097          	auipc	ra,0x3
    2552:	190080e7          	jalr	400(ra) # 56de <open>
    2556:	892a                	mv	s2,a0
  if(fd < 0){
    2558:	02054963          	bltz	a0,258a <rwsbrk+0x12c>
  n = read(fd, (void*)(a+4096), 10);
    255c:	4629                	li	a2,10
    255e:	85a6                	mv	a1,s1
    2560:	00003097          	auipc	ra,0x3
    2564:	156080e7          	jalr	342(ra) # 56b6 <read>
    2568:	862a                	mv	a2,a0
  if(n >= 0){
    256a:	02054d63          	bltz	a0,25a4 <rwsbrk+0x146>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    256e:	85a6                	mv	a1,s1
    2570:	00004517          	auipc	a0,0x4
    2574:	6d850513          	addi	a0,a0,1752 # 6c48 <malloc+0x115c>
    2578:	00003097          	auipc	ra,0x3
    257c:	4b6080e7          	jalr	1206(ra) # 5a2e <printf>
    exit(1);
    2580:	4505                	li	a0,1
    2582:	00003097          	auipc	ra,0x3
    2586:	11c080e7          	jalr	284(ra) # 569e <exit>
    printf("open(rwsbrk) failed\n");
    258a:	00004517          	auipc	a0,0x4
    258e:	67650513          	addi	a0,a0,1654 # 6c00 <malloc+0x1114>
    2592:	00003097          	auipc	ra,0x3
    2596:	49c080e7          	jalr	1180(ra) # 5a2e <printf>
    exit(1);
    259a:	4505                	li	a0,1
    259c:	00003097          	auipc	ra,0x3
    25a0:	102080e7          	jalr	258(ra) # 569e <exit>
  close(fd);
    25a4:	854a                	mv	a0,s2
    25a6:	00003097          	auipc	ra,0x3
    25aa:	120080e7          	jalr	288(ra) # 56c6 <close>
  exit(0);
    25ae:	4501                	li	a0,0
    25b0:	00003097          	auipc	ra,0x3
    25b4:	0ee080e7          	jalr	238(ra) # 569e <exit>

00000000000025b8 <sbrkbasic>:
{
    25b8:	7139                	addi	sp,sp,-64
    25ba:	fc06                	sd	ra,56(sp)
    25bc:	f822                	sd	s0,48(sp)
    25be:	f426                	sd	s1,40(sp)
    25c0:	f04a                	sd	s2,32(sp)
    25c2:	ec4e                	sd	s3,24(sp)
    25c4:	e852                	sd	s4,16(sp)
    25c6:	0080                	addi	s0,sp,64
    25c8:	8a2a                	mv	s4,a0
  pid = fork();
    25ca:	00003097          	auipc	ra,0x3
    25ce:	0cc080e7          	jalr	204(ra) # 5696 <fork>
  if(pid < 0){
    25d2:	02054c63          	bltz	a0,260a <sbrkbasic+0x52>
  if(pid == 0){
    25d6:	ed21                	bnez	a0,262e <sbrkbasic+0x76>
    a = sbrk(TOOMUCH);
    25d8:	40000537          	lui	a0,0x40000
    25dc:	00003097          	auipc	ra,0x3
    25e0:	14a080e7          	jalr	330(ra) # 5726 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    25e4:	57fd                	li	a5,-1
    25e6:	02f50f63          	beq	a0,a5,2624 <sbrkbasic+0x6c>
    for(b = a; b < a+TOOMUCH; b += 4096){
    25ea:	400007b7          	lui	a5,0x40000
    25ee:	97aa                	add	a5,a5,a0
      *b = 99;
    25f0:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    25f4:	6705                	lui	a4,0x1
      *b = 99;
    25f6:	00d50023          	sb	a3,0(a0) # 40000000 <__BSS_END__+0x3fff14a0>
    for(b = a; b < a+TOOMUCH; b += 4096){
    25fa:	953a                	add	a0,a0,a4
    25fc:	fef51de3          	bne	a0,a5,25f6 <sbrkbasic+0x3e>
    exit(1);
    2600:	4505                	li	a0,1
    2602:	00003097          	auipc	ra,0x3
    2606:	09c080e7          	jalr	156(ra) # 569e <exit>
    printf("fork failed in sbrkbasic\n");
    260a:	00004517          	auipc	a0,0x4
    260e:	66650513          	addi	a0,a0,1638 # 6c70 <malloc+0x1184>
    2612:	00003097          	auipc	ra,0x3
    2616:	41c080e7          	jalr	1052(ra) # 5a2e <printf>
    exit(1);
    261a:	4505                	li	a0,1
    261c:	00003097          	auipc	ra,0x3
    2620:	082080e7          	jalr	130(ra) # 569e <exit>
      exit(0);
    2624:	4501                	li	a0,0
    2626:	00003097          	auipc	ra,0x3
    262a:	078080e7          	jalr	120(ra) # 569e <exit>
  wait(&xstatus);
    262e:	fcc40513          	addi	a0,s0,-52
    2632:	00003097          	auipc	ra,0x3
    2636:	074080e7          	jalr	116(ra) # 56a6 <wait>
  if(xstatus == 1){
    263a:	fcc42703          	lw	a4,-52(s0)
    263e:	4785                	li	a5,1
    2640:	00f70d63          	beq	a4,a5,265a <sbrkbasic+0xa2>
  a = sbrk(0);
    2644:	4501                	li	a0,0
    2646:	00003097          	auipc	ra,0x3
    264a:	0e0080e7          	jalr	224(ra) # 5726 <sbrk>
    264e:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    2650:	4901                	li	s2,0
    2652:	6985                	lui	s3,0x1
    2654:	38898993          	addi	s3,s3,904 # 1388 <copyinstr2+0x1d6>
    2658:	a005                	j	2678 <sbrkbasic+0xc0>
    printf("%s: too much memory allocated!\n", s);
    265a:	85d2                	mv	a1,s4
    265c:	00004517          	auipc	a0,0x4
    2660:	63450513          	addi	a0,a0,1588 # 6c90 <malloc+0x11a4>
    2664:	00003097          	auipc	ra,0x3
    2668:	3ca080e7          	jalr	970(ra) # 5a2e <printf>
    exit(1);
    266c:	4505                	li	a0,1
    266e:	00003097          	auipc	ra,0x3
    2672:	030080e7          	jalr	48(ra) # 569e <exit>
    a = b + 1;
    2676:	84be                	mv	s1,a5
    b = sbrk(1);
    2678:	4505                	li	a0,1
    267a:	00003097          	auipc	ra,0x3
    267e:	0ac080e7          	jalr	172(ra) # 5726 <sbrk>
    if(b != a){
    2682:	04951c63          	bne	a0,s1,26da <sbrkbasic+0x122>
    *b = 1;
    2686:	4785                	li	a5,1
    2688:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    268c:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    2690:	2905                	addiw	s2,s2,1
    2692:	ff3912e3          	bne	s2,s3,2676 <sbrkbasic+0xbe>
  pid = fork();
    2696:	00003097          	auipc	ra,0x3
    269a:	000080e7          	jalr	ra # 5696 <fork>
    269e:	892a                	mv	s2,a0
  if(pid < 0){
    26a0:	04054d63          	bltz	a0,26fa <sbrkbasic+0x142>
  c = sbrk(1);
    26a4:	4505                	li	a0,1
    26a6:	00003097          	auipc	ra,0x3
    26aa:	080080e7          	jalr	128(ra) # 5726 <sbrk>
  c = sbrk(1);
    26ae:	4505                	li	a0,1
    26b0:	00003097          	auipc	ra,0x3
    26b4:	076080e7          	jalr	118(ra) # 5726 <sbrk>
  if(c != a + 1){
    26b8:	0489                	addi	s1,s1,2
    26ba:	04a48e63          	beq	s1,a0,2716 <sbrkbasic+0x15e>
    printf("%s: sbrk test failed post-fork\n", s);
    26be:	85d2                	mv	a1,s4
    26c0:	00004517          	auipc	a0,0x4
    26c4:	63050513          	addi	a0,a0,1584 # 6cf0 <malloc+0x1204>
    26c8:	00003097          	auipc	ra,0x3
    26cc:	366080e7          	jalr	870(ra) # 5a2e <printf>
    exit(1);
    26d0:	4505                	li	a0,1
    26d2:	00003097          	auipc	ra,0x3
    26d6:	fcc080e7          	jalr	-52(ra) # 569e <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    26da:	86aa                	mv	a3,a0
    26dc:	8626                	mv	a2,s1
    26de:	85ca                	mv	a1,s2
    26e0:	00004517          	auipc	a0,0x4
    26e4:	5d050513          	addi	a0,a0,1488 # 6cb0 <malloc+0x11c4>
    26e8:	00003097          	auipc	ra,0x3
    26ec:	346080e7          	jalr	838(ra) # 5a2e <printf>
      exit(1);
    26f0:	4505                	li	a0,1
    26f2:	00003097          	auipc	ra,0x3
    26f6:	fac080e7          	jalr	-84(ra) # 569e <exit>
    printf("%s: sbrk test fork failed\n", s);
    26fa:	85d2                	mv	a1,s4
    26fc:	00004517          	auipc	a0,0x4
    2700:	5d450513          	addi	a0,a0,1492 # 6cd0 <malloc+0x11e4>
    2704:	00003097          	auipc	ra,0x3
    2708:	32a080e7          	jalr	810(ra) # 5a2e <printf>
    exit(1);
    270c:	4505                	li	a0,1
    270e:	00003097          	auipc	ra,0x3
    2712:	f90080e7          	jalr	-112(ra) # 569e <exit>
  if(pid == 0)
    2716:	00091763          	bnez	s2,2724 <sbrkbasic+0x16c>
    exit(0);
    271a:	4501                	li	a0,0
    271c:	00003097          	auipc	ra,0x3
    2720:	f82080e7          	jalr	-126(ra) # 569e <exit>
  wait(&xstatus);
    2724:	fcc40513          	addi	a0,s0,-52
    2728:	00003097          	auipc	ra,0x3
    272c:	f7e080e7          	jalr	-130(ra) # 56a6 <wait>
  exit(xstatus);
    2730:	fcc42503          	lw	a0,-52(s0)
    2734:	00003097          	auipc	ra,0x3
    2738:	f6a080e7          	jalr	-150(ra) # 569e <exit>

000000000000273c <sbrkmuch>:
{
    273c:	7179                	addi	sp,sp,-48
    273e:	f406                	sd	ra,40(sp)
    2740:	f022                	sd	s0,32(sp)
    2742:	ec26                	sd	s1,24(sp)
    2744:	e84a                	sd	s2,16(sp)
    2746:	e44e                	sd	s3,8(sp)
    2748:	e052                	sd	s4,0(sp)
    274a:	1800                	addi	s0,sp,48
    274c:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    274e:	4501                	li	a0,0
    2750:	00003097          	auipc	ra,0x3
    2754:	fd6080e7          	jalr	-42(ra) # 5726 <sbrk>
    2758:	892a                	mv	s2,a0
  a = sbrk(0);
    275a:	4501                	li	a0,0
    275c:	00003097          	auipc	ra,0x3
    2760:	fca080e7          	jalr	-54(ra) # 5726 <sbrk>
    2764:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2766:	06400537          	lui	a0,0x6400
    276a:	9d05                	subw	a0,a0,s1
    276c:	00003097          	auipc	ra,0x3
    2770:	fba080e7          	jalr	-70(ra) # 5726 <sbrk>
  if (p != a) {
    2774:	0ca49863          	bne	s1,a0,2844 <sbrkmuch+0x108>
  char *eee = sbrk(0);
    2778:	4501                	li	a0,0
    277a:	00003097          	auipc	ra,0x3
    277e:	fac080e7          	jalr	-84(ra) # 5726 <sbrk>
    2782:	87aa                	mv	a5,a0
  for(char *pp = a; pp < eee; pp += 4096)
    2784:	00a4f963          	bgeu	s1,a0,2796 <sbrkmuch+0x5a>
    *pp = 1;
    2788:	4685                	li	a3,1
  for(char *pp = a; pp < eee; pp += 4096)
    278a:	6705                	lui	a4,0x1
    *pp = 1;
    278c:	00d48023          	sb	a3,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    2790:	94ba                	add	s1,s1,a4
    2792:	fef4ede3          	bltu	s1,a5,278c <sbrkmuch+0x50>
  *lastaddr = 99;
    2796:	064007b7          	lui	a5,0x6400
    279a:	06300713          	li	a4,99
    279e:	fee78fa3          	sb	a4,-1(a5) # 63fffff <__BSS_END__+0x63f149f>
  a = sbrk(0);
    27a2:	4501                	li	a0,0
    27a4:	00003097          	auipc	ra,0x3
    27a8:	f82080e7          	jalr	-126(ra) # 5726 <sbrk>
    27ac:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    27ae:	757d                	lui	a0,0xfffff
    27b0:	00003097          	auipc	ra,0x3
    27b4:	f76080e7          	jalr	-138(ra) # 5726 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    27b8:	57fd                	li	a5,-1
    27ba:	0af50363          	beq	a0,a5,2860 <sbrkmuch+0x124>
  c = sbrk(0);
    27be:	4501                	li	a0,0
    27c0:	00003097          	auipc	ra,0x3
    27c4:	f66080e7          	jalr	-154(ra) # 5726 <sbrk>
  if(c != a - PGSIZE){
    27c8:	77fd                	lui	a5,0xfffff
    27ca:	97a6                	add	a5,a5,s1
    27cc:	0af51863          	bne	a0,a5,287c <sbrkmuch+0x140>
  a = sbrk(0);
    27d0:	4501                	li	a0,0
    27d2:	00003097          	auipc	ra,0x3
    27d6:	f54080e7          	jalr	-172(ra) # 5726 <sbrk>
    27da:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    27dc:	6505                	lui	a0,0x1
    27de:	00003097          	auipc	ra,0x3
    27e2:	f48080e7          	jalr	-184(ra) # 5726 <sbrk>
    27e6:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    27e8:	0aa49a63          	bne	s1,a0,289c <sbrkmuch+0x160>
    27ec:	4501                	li	a0,0
    27ee:	00003097          	auipc	ra,0x3
    27f2:	f38080e7          	jalr	-200(ra) # 5726 <sbrk>
    27f6:	6785                	lui	a5,0x1
    27f8:	97a6                	add	a5,a5,s1
    27fa:	0af51163          	bne	a0,a5,289c <sbrkmuch+0x160>
  if(*lastaddr == 99){
    27fe:	064007b7          	lui	a5,0x6400
    2802:	fff7c703          	lbu	a4,-1(a5) # 63fffff <__BSS_END__+0x63f149f>
    2806:	06300793          	li	a5,99
    280a:	0af70963          	beq	a4,a5,28bc <sbrkmuch+0x180>
  a = sbrk(0);
    280e:	4501                	li	a0,0
    2810:	00003097          	auipc	ra,0x3
    2814:	f16080e7          	jalr	-234(ra) # 5726 <sbrk>
    2818:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    281a:	4501                	li	a0,0
    281c:	00003097          	auipc	ra,0x3
    2820:	f0a080e7          	jalr	-246(ra) # 5726 <sbrk>
    2824:	40a9053b          	subw	a0,s2,a0
    2828:	00003097          	auipc	ra,0x3
    282c:	efe080e7          	jalr	-258(ra) # 5726 <sbrk>
  if(c != a){
    2830:	0aa49463          	bne	s1,a0,28d8 <sbrkmuch+0x19c>
}
    2834:	70a2                	ld	ra,40(sp)
    2836:	7402                	ld	s0,32(sp)
    2838:	64e2                	ld	s1,24(sp)
    283a:	6942                	ld	s2,16(sp)
    283c:	69a2                	ld	s3,8(sp)
    283e:	6a02                	ld	s4,0(sp)
    2840:	6145                	addi	sp,sp,48
    2842:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2844:	85ce                	mv	a1,s3
    2846:	00004517          	auipc	a0,0x4
    284a:	4ca50513          	addi	a0,a0,1226 # 6d10 <malloc+0x1224>
    284e:	00003097          	auipc	ra,0x3
    2852:	1e0080e7          	jalr	480(ra) # 5a2e <printf>
    exit(1);
    2856:	4505                	li	a0,1
    2858:	00003097          	auipc	ra,0x3
    285c:	e46080e7          	jalr	-442(ra) # 569e <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2860:	85ce                	mv	a1,s3
    2862:	00004517          	auipc	a0,0x4
    2866:	4f650513          	addi	a0,a0,1270 # 6d58 <malloc+0x126c>
    286a:	00003097          	auipc	ra,0x3
    286e:	1c4080e7          	jalr	452(ra) # 5a2e <printf>
    exit(1);
    2872:	4505                	li	a0,1
    2874:	00003097          	auipc	ra,0x3
    2878:	e2a080e7          	jalr	-470(ra) # 569e <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    287c:	86aa                	mv	a3,a0
    287e:	8626                	mv	a2,s1
    2880:	85ce                	mv	a1,s3
    2882:	00004517          	auipc	a0,0x4
    2886:	4f650513          	addi	a0,a0,1270 # 6d78 <malloc+0x128c>
    288a:	00003097          	auipc	ra,0x3
    288e:	1a4080e7          	jalr	420(ra) # 5a2e <printf>
    exit(1);
    2892:	4505                	li	a0,1
    2894:	00003097          	auipc	ra,0x3
    2898:	e0a080e7          	jalr	-502(ra) # 569e <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    289c:	86d2                	mv	a3,s4
    289e:	8626                	mv	a2,s1
    28a0:	85ce                	mv	a1,s3
    28a2:	00004517          	auipc	a0,0x4
    28a6:	51650513          	addi	a0,a0,1302 # 6db8 <malloc+0x12cc>
    28aa:	00003097          	auipc	ra,0x3
    28ae:	184080e7          	jalr	388(ra) # 5a2e <printf>
    exit(1);
    28b2:	4505                	li	a0,1
    28b4:	00003097          	auipc	ra,0x3
    28b8:	dea080e7          	jalr	-534(ra) # 569e <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    28bc:	85ce                	mv	a1,s3
    28be:	00004517          	auipc	a0,0x4
    28c2:	52a50513          	addi	a0,a0,1322 # 6de8 <malloc+0x12fc>
    28c6:	00003097          	auipc	ra,0x3
    28ca:	168080e7          	jalr	360(ra) # 5a2e <printf>
    exit(1);
    28ce:	4505                	li	a0,1
    28d0:	00003097          	auipc	ra,0x3
    28d4:	dce080e7          	jalr	-562(ra) # 569e <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    28d8:	86aa                	mv	a3,a0
    28da:	8626                	mv	a2,s1
    28dc:	85ce                	mv	a1,s3
    28de:	00004517          	auipc	a0,0x4
    28e2:	54250513          	addi	a0,a0,1346 # 6e20 <malloc+0x1334>
    28e6:	00003097          	auipc	ra,0x3
    28ea:	148080e7          	jalr	328(ra) # 5a2e <printf>
    exit(1);
    28ee:	4505                	li	a0,1
    28f0:	00003097          	auipc	ra,0x3
    28f4:	dae080e7          	jalr	-594(ra) # 569e <exit>

00000000000028f8 <sbrkarg>:
{
    28f8:	7179                	addi	sp,sp,-48
    28fa:	f406                	sd	ra,40(sp)
    28fc:	f022                	sd	s0,32(sp)
    28fe:	ec26                	sd	s1,24(sp)
    2900:	e84a                	sd	s2,16(sp)
    2902:	e44e                	sd	s3,8(sp)
    2904:	1800                	addi	s0,sp,48
    2906:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2908:	6505                	lui	a0,0x1
    290a:	00003097          	auipc	ra,0x3
    290e:	e1c080e7          	jalr	-484(ra) # 5726 <sbrk>
    2912:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2914:	20100593          	li	a1,513
    2918:	00004517          	auipc	a0,0x4
    291c:	53050513          	addi	a0,a0,1328 # 6e48 <malloc+0x135c>
    2920:	00003097          	auipc	ra,0x3
    2924:	dbe080e7          	jalr	-578(ra) # 56de <open>
    2928:	84aa                	mv	s1,a0
  unlink("sbrk");
    292a:	00004517          	auipc	a0,0x4
    292e:	51e50513          	addi	a0,a0,1310 # 6e48 <malloc+0x135c>
    2932:	00003097          	auipc	ra,0x3
    2936:	dbc080e7          	jalr	-580(ra) # 56ee <unlink>
  if(fd < 0)  {
    293a:	0404c163          	bltz	s1,297c <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    293e:	6605                	lui	a2,0x1
    2940:	85ca                	mv	a1,s2
    2942:	8526                	mv	a0,s1
    2944:	00003097          	auipc	ra,0x3
    2948:	d7a080e7          	jalr	-646(ra) # 56be <write>
    294c:	04054663          	bltz	a0,2998 <sbrkarg+0xa0>
  close(fd);
    2950:	8526                	mv	a0,s1
    2952:	00003097          	auipc	ra,0x3
    2956:	d74080e7          	jalr	-652(ra) # 56c6 <close>
  a = sbrk(PGSIZE);
    295a:	6505                	lui	a0,0x1
    295c:	00003097          	auipc	ra,0x3
    2960:	dca080e7          	jalr	-566(ra) # 5726 <sbrk>
  if(pipe((int *) a) != 0){
    2964:	00003097          	auipc	ra,0x3
    2968:	d4a080e7          	jalr	-694(ra) # 56ae <pipe>
    296c:	e521                	bnez	a0,29b4 <sbrkarg+0xbc>
}
    296e:	70a2                	ld	ra,40(sp)
    2970:	7402                	ld	s0,32(sp)
    2972:	64e2                	ld	s1,24(sp)
    2974:	6942                	ld	s2,16(sp)
    2976:	69a2                	ld	s3,8(sp)
    2978:	6145                	addi	sp,sp,48
    297a:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    297c:	85ce                	mv	a1,s3
    297e:	00004517          	auipc	a0,0x4
    2982:	4d250513          	addi	a0,a0,1234 # 6e50 <malloc+0x1364>
    2986:	00003097          	auipc	ra,0x3
    298a:	0a8080e7          	jalr	168(ra) # 5a2e <printf>
    exit(1);
    298e:	4505                	li	a0,1
    2990:	00003097          	auipc	ra,0x3
    2994:	d0e080e7          	jalr	-754(ra) # 569e <exit>
    printf("%s: write sbrk failed\n", s);
    2998:	85ce                	mv	a1,s3
    299a:	00004517          	auipc	a0,0x4
    299e:	4ce50513          	addi	a0,a0,1230 # 6e68 <malloc+0x137c>
    29a2:	00003097          	auipc	ra,0x3
    29a6:	08c080e7          	jalr	140(ra) # 5a2e <printf>
    exit(1);
    29aa:	4505                	li	a0,1
    29ac:	00003097          	auipc	ra,0x3
    29b0:	cf2080e7          	jalr	-782(ra) # 569e <exit>
    printf("%s: pipe() failed\n", s);
    29b4:	85ce                	mv	a1,s3
    29b6:	00004517          	auipc	a0,0x4
    29ba:	eb250513          	addi	a0,a0,-334 # 6868 <malloc+0xd7c>
    29be:	00003097          	auipc	ra,0x3
    29c2:	070080e7          	jalr	112(ra) # 5a2e <printf>
    exit(1);
    29c6:	4505                	li	a0,1
    29c8:	00003097          	auipc	ra,0x3
    29cc:	cd6080e7          	jalr	-810(ra) # 569e <exit>

00000000000029d0 <argptest>:
{
    29d0:	1101                	addi	sp,sp,-32
    29d2:	ec06                	sd	ra,24(sp)
    29d4:	e822                	sd	s0,16(sp)
    29d6:	e426                	sd	s1,8(sp)
    29d8:	e04a                	sd	s2,0(sp)
    29da:	1000                	addi	s0,sp,32
    29dc:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    29de:	4581                	li	a1,0
    29e0:	00004517          	auipc	a0,0x4
    29e4:	4a050513          	addi	a0,a0,1184 # 6e80 <malloc+0x1394>
    29e8:	00003097          	auipc	ra,0x3
    29ec:	cf6080e7          	jalr	-778(ra) # 56de <open>
  if (fd < 0) {
    29f0:	02054b63          	bltz	a0,2a26 <argptest+0x56>
    29f4:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    29f6:	4501                	li	a0,0
    29f8:	00003097          	auipc	ra,0x3
    29fc:	d2e080e7          	jalr	-722(ra) # 5726 <sbrk>
    2a00:	567d                	li	a2,-1
    2a02:	fff50593          	addi	a1,a0,-1
    2a06:	8526                	mv	a0,s1
    2a08:	00003097          	auipc	ra,0x3
    2a0c:	cae080e7          	jalr	-850(ra) # 56b6 <read>
  close(fd);
    2a10:	8526                	mv	a0,s1
    2a12:	00003097          	auipc	ra,0x3
    2a16:	cb4080e7          	jalr	-844(ra) # 56c6 <close>
}
    2a1a:	60e2                	ld	ra,24(sp)
    2a1c:	6442                	ld	s0,16(sp)
    2a1e:	64a2                	ld	s1,8(sp)
    2a20:	6902                	ld	s2,0(sp)
    2a22:	6105                	addi	sp,sp,32
    2a24:	8082                	ret
    printf("%s: open failed\n", s);
    2a26:	85ca                	mv	a1,s2
    2a28:	00004517          	auipc	a0,0x4
    2a2c:	d5050513          	addi	a0,a0,-688 # 6778 <malloc+0xc8c>
    2a30:	00003097          	auipc	ra,0x3
    2a34:	ffe080e7          	jalr	-2(ra) # 5a2e <printf>
    exit(1);
    2a38:	4505                	li	a0,1
    2a3a:	00003097          	auipc	ra,0x3
    2a3e:	c64080e7          	jalr	-924(ra) # 569e <exit>

0000000000002a42 <sbrkbugs>:
{
    2a42:	1141                	addi	sp,sp,-16
    2a44:	e406                	sd	ra,8(sp)
    2a46:	e022                	sd	s0,0(sp)
    2a48:	0800                	addi	s0,sp,16
  int pid = fork();
    2a4a:	00003097          	auipc	ra,0x3
    2a4e:	c4c080e7          	jalr	-948(ra) # 5696 <fork>
  if(pid < 0){
    2a52:	02054263          	bltz	a0,2a76 <sbrkbugs+0x34>
  if(pid == 0){
    2a56:	ed0d                	bnez	a0,2a90 <sbrkbugs+0x4e>
    int sz = (uint64) sbrk(0);
    2a58:	00003097          	auipc	ra,0x3
    2a5c:	cce080e7          	jalr	-818(ra) # 5726 <sbrk>
    sbrk(-sz);
    2a60:	40a0053b          	negw	a0,a0
    2a64:	00003097          	auipc	ra,0x3
    2a68:	cc2080e7          	jalr	-830(ra) # 5726 <sbrk>
    exit(0);
    2a6c:	4501                	li	a0,0
    2a6e:	00003097          	auipc	ra,0x3
    2a72:	c30080e7          	jalr	-976(ra) # 569e <exit>
    printf("fork failed\n");
    2a76:	00004517          	auipc	a0,0x4
    2a7a:	0f250513          	addi	a0,a0,242 # 6b68 <malloc+0x107c>
    2a7e:	00003097          	auipc	ra,0x3
    2a82:	fb0080e7          	jalr	-80(ra) # 5a2e <printf>
    exit(1);
    2a86:	4505                	li	a0,1
    2a88:	00003097          	auipc	ra,0x3
    2a8c:	c16080e7          	jalr	-1002(ra) # 569e <exit>
  wait(0);
    2a90:	4501                	li	a0,0
    2a92:	00003097          	auipc	ra,0x3
    2a96:	c14080e7          	jalr	-1004(ra) # 56a6 <wait>
  pid = fork();
    2a9a:	00003097          	auipc	ra,0x3
    2a9e:	bfc080e7          	jalr	-1028(ra) # 5696 <fork>
  if(pid < 0){
    2aa2:	02054563          	bltz	a0,2acc <sbrkbugs+0x8a>
  if(pid == 0){
    2aa6:	e121                	bnez	a0,2ae6 <sbrkbugs+0xa4>
    int sz = (uint64) sbrk(0);
    2aa8:	00003097          	auipc	ra,0x3
    2aac:	c7e080e7          	jalr	-898(ra) # 5726 <sbrk>
    sbrk(-(sz - 3500));
    2ab0:	6785                	lui	a5,0x1
    2ab2:	dac7879b          	addiw	a5,a5,-596
    2ab6:	40a7853b          	subw	a0,a5,a0
    2aba:	00003097          	auipc	ra,0x3
    2abe:	c6c080e7          	jalr	-916(ra) # 5726 <sbrk>
    exit(0);
    2ac2:	4501                	li	a0,0
    2ac4:	00003097          	auipc	ra,0x3
    2ac8:	bda080e7          	jalr	-1062(ra) # 569e <exit>
    printf("fork failed\n");
    2acc:	00004517          	auipc	a0,0x4
    2ad0:	09c50513          	addi	a0,a0,156 # 6b68 <malloc+0x107c>
    2ad4:	00003097          	auipc	ra,0x3
    2ad8:	f5a080e7          	jalr	-166(ra) # 5a2e <printf>
    exit(1);
    2adc:	4505                	li	a0,1
    2ade:	00003097          	auipc	ra,0x3
    2ae2:	bc0080e7          	jalr	-1088(ra) # 569e <exit>
  wait(0);
    2ae6:	4501                	li	a0,0
    2ae8:	00003097          	auipc	ra,0x3
    2aec:	bbe080e7          	jalr	-1090(ra) # 56a6 <wait>
  pid = fork();
    2af0:	00003097          	auipc	ra,0x3
    2af4:	ba6080e7          	jalr	-1114(ra) # 5696 <fork>
  if(pid < 0){
    2af8:	02054a63          	bltz	a0,2b2c <sbrkbugs+0xea>
  if(pid == 0){
    2afc:	e529                	bnez	a0,2b46 <sbrkbugs+0x104>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2afe:	00003097          	auipc	ra,0x3
    2b02:	c28080e7          	jalr	-984(ra) # 5726 <sbrk>
    2b06:	67ad                	lui	a5,0xb
    2b08:	8007879b          	addiw	a5,a5,-2048
    2b0c:	40a7853b          	subw	a0,a5,a0
    2b10:	00003097          	auipc	ra,0x3
    2b14:	c16080e7          	jalr	-1002(ra) # 5726 <sbrk>
    sbrk(-10);
    2b18:	5559                	li	a0,-10
    2b1a:	00003097          	auipc	ra,0x3
    2b1e:	c0c080e7          	jalr	-1012(ra) # 5726 <sbrk>
    exit(0);
    2b22:	4501                	li	a0,0
    2b24:	00003097          	auipc	ra,0x3
    2b28:	b7a080e7          	jalr	-1158(ra) # 569e <exit>
    printf("fork failed\n");
    2b2c:	00004517          	auipc	a0,0x4
    2b30:	03c50513          	addi	a0,a0,60 # 6b68 <malloc+0x107c>
    2b34:	00003097          	auipc	ra,0x3
    2b38:	efa080e7          	jalr	-262(ra) # 5a2e <printf>
    exit(1);
    2b3c:	4505                	li	a0,1
    2b3e:	00003097          	auipc	ra,0x3
    2b42:	b60080e7          	jalr	-1184(ra) # 569e <exit>
  wait(0);
    2b46:	4501                	li	a0,0
    2b48:	00003097          	auipc	ra,0x3
    2b4c:	b5e080e7          	jalr	-1186(ra) # 56a6 <wait>
  exit(0);
    2b50:	4501                	li	a0,0
    2b52:	00003097          	auipc	ra,0x3
    2b56:	b4c080e7          	jalr	-1204(ra) # 569e <exit>

0000000000002b5a <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    2b5a:	715d                	addi	sp,sp,-80
    2b5c:	e486                	sd	ra,72(sp)
    2b5e:	e0a2                	sd	s0,64(sp)
    2b60:	fc26                	sd	s1,56(sp)
    2b62:	f84a                	sd	s2,48(sp)
    2b64:	f44e                	sd	s3,40(sp)
    2b66:	f052                	sd	s4,32(sp)
    2b68:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2b6a:	4901                	li	s2,0
    2b6c:	49bd                	li	s3,15
    int pid = fork();
    2b6e:	00003097          	auipc	ra,0x3
    2b72:	b28080e7          	jalr	-1240(ra) # 5696 <fork>
    2b76:	84aa                	mv	s1,a0
    if(pid < 0){
    2b78:	02054063          	bltz	a0,2b98 <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    2b7c:	c91d                	beqz	a0,2bb2 <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    2b7e:	4501                	li	a0,0
    2b80:	00003097          	auipc	ra,0x3
    2b84:	b26080e7          	jalr	-1242(ra) # 56a6 <wait>
  for(int avail = 0; avail < 15; avail++){
    2b88:	2905                	addiw	s2,s2,1
    2b8a:	ff3912e3          	bne	s2,s3,2b6e <execout+0x14>
    }
  }

  exit(0);
    2b8e:	4501                	li	a0,0
    2b90:	00003097          	auipc	ra,0x3
    2b94:	b0e080e7          	jalr	-1266(ra) # 569e <exit>
      printf("fork failed\n");
    2b98:	00004517          	auipc	a0,0x4
    2b9c:	fd050513          	addi	a0,a0,-48 # 6b68 <malloc+0x107c>
    2ba0:	00003097          	auipc	ra,0x3
    2ba4:	e8e080e7          	jalr	-370(ra) # 5a2e <printf>
      exit(1);
    2ba8:	4505                	li	a0,1
    2baa:	00003097          	auipc	ra,0x3
    2bae:	af4080e7          	jalr	-1292(ra) # 569e <exit>
        if(a == 0xffffffffffffffffLL)
    2bb2:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2bb4:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2bb6:	6505                	lui	a0,0x1
    2bb8:	00003097          	auipc	ra,0x3
    2bbc:	b6e080e7          	jalr	-1170(ra) # 5726 <sbrk>
        if(a == 0xffffffffffffffffLL)
    2bc0:	01350763          	beq	a0,s3,2bce <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2bc4:	6785                	lui	a5,0x1
    2bc6:	953e                	add	a0,a0,a5
    2bc8:	ff450fa3          	sb	s4,-1(a0) # fff <bigdir+0x9d>
      while(1){
    2bcc:	b7ed                	j	2bb6 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2bce:	01205a63          	blez	s2,2be2 <execout+0x88>
        sbrk(-4096);
    2bd2:	757d                	lui	a0,0xfffff
    2bd4:	00003097          	auipc	ra,0x3
    2bd8:	b52080e7          	jalr	-1198(ra) # 5726 <sbrk>
      for(int i = 0; i < avail; i++)
    2bdc:	2485                	addiw	s1,s1,1
    2bde:	ff249ae3          	bne	s1,s2,2bd2 <execout+0x78>
      close(1);
    2be2:	4505                	li	a0,1
    2be4:	00003097          	auipc	ra,0x3
    2be8:	ae2080e7          	jalr	-1310(ra) # 56c6 <close>
      char *args[] = { "echo", "x", 0 };
    2bec:	00003517          	auipc	a0,0x3
    2bf0:	33c50513          	addi	a0,a0,828 # 5f28 <malloc+0x43c>
    2bf4:	faa43c23          	sd	a0,-72(s0)
    2bf8:	00003797          	auipc	a5,0x3
    2bfc:	3a078793          	addi	a5,a5,928 # 5f98 <malloc+0x4ac>
    2c00:	fcf43023          	sd	a5,-64(s0)
    2c04:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2c08:	fb840593          	addi	a1,s0,-72
    2c0c:	00003097          	auipc	ra,0x3
    2c10:	aca080e7          	jalr	-1334(ra) # 56d6 <exec>
      exit(0);
    2c14:	4501                	li	a0,0
    2c16:	00003097          	auipc	ra,0x3
    2c1a:	a88080e7          	jalr	-1400(ra) # 569e <exit>

0000000000002c1e <fourteen>:
{
    2c1e:	1101                	addi	sp,sp,-32
    2c20:	ec06                	sd	ra,24(sp)
    2c22:	e822                	sd	s0,16(sp)
    2c24:	e426                	sd	s1,8(sp)
    2c26:	1000                	addi	s0,sp,32
    2c28:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2c2a:	00004517          	auipc	a0,0x4
    2c2e:	42e50513          	addi	a0,a0,1070 # 7058 <malloc+0x156c>
    2c32:	00003097          	auipc	ra,0x3
    2c36:	ad4080e7          	jalr	-1324(ra) # 5706 <mkdir>
    2c3a:	e165                	bnez	a0,2d1a <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    2c3c:	00004517          	auipc	a0,0x4
    2c40:	27450513          	addi	a0,a0,628 # 6eb0 <malloc+0x13c4>
    2c44:	00003097          	auipc	ra,0x3
    2c48:	ac2080e7          	jalr	-1342(ra) # 5706 <mkdir>
    2c4c:	e56d                	bnez	a0,2d36 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2c4e:	20000593          	li	a1,512
    2c52:	00004517          	auipc	a0,0x4
    2c56:	2b650513          	addi	a0,a0,694 # 6f08 <malloc+0x141c>
    2c5a:	00003097          	auipc	ra,0x3
    2c5e:	a84080e7          	jalr	-1404(ra) # 56de <open>
  if(fd < 0){
    2c62:	0e054863          	bltz	a0,2d52 <fourteen+0x134>
  close(fd);
    2c66:	00003097          	auipc	ra,0x3
    2c6a:	a60080e7          	jalr	-1440(ra) # 56c6 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2c6e:	4581                	li	a1,0
    2c70:	00004517          	auipc	a0,0x4
    2c74:	31050513          	addi	a0,a0,784 # 6f80 <malloc+0x1494>
    2c78:	00003097          	auipc	ra,0x3
    2c7c:	a66080e7          	jalr	-1434(ra) # 56de <open>
  if(fd < 0){
    2c80:	0e054763          	bltz	a0,2d6e <fourteen+0x150>
  close(fd);
    2c84:	00003097          	auipc	ra,0x3
    2c88:	a42080e7          	jalr	-1470(ra) # 56c6 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    2c8c:	00004517          	auipc	a0,0x4
    2c90:	36450513          	addi	a0,a0,868 # 6ff0 <malloc+0x1504>
    2c94:	00003097          	auipc	ra,0x3
    2c98:	a72080e7          	jalr	-1422(ra) # 5706 <mkdir>
    2c9c:	c57d                	beqz	a0,2d8a <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    2c9e:	00004517          	auipc	a0,0x4
    2ca2:	3aa50513          	addi	a0,a0,938 # 7048 <malloc+0x155c>
    2ca6:	00003097          	auipc	ra,0x3
    2caa:	a60080e7          	jalr	-1440(ra) # 5706 <mkdir>
    2cae:	cd65                	beqz	a0,2da6 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    2cb0:	00004517          	auipc	a0,0x4
    2cb4:	39850513          	addi	a0,a0,920 # 7048 <malloc+0x155c>
    2cb8:	00003097          	auipc	ra,0x3
    2cbc:	a36080e7          	jalr	-1482(ra) # 56ee <unlink>
  unlink("12345678901234/12345678901234");
    2cc0:	00004517          	auipc	a0,0x4
    2cc4:	33050513          	addi	a0,a0,816 # 6ff0 <malloc+0x1504>
    2cc8:	00003097          	auipc	ra,0x3
    2ccc:	a26080e7          	jalr	-1498(ra) # 56ee <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2cd0:	00004517          	auipc	a0,0x4
    2cd4:	2b050513          	addi	a0,a0,688 # 6f80 <malloc+0x1494>
    2cd8:	00003097          	auipc	ra,0x3
    2cdc:	a16080e7          	jalr	-1514(ra) # 56ee <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2ce0:	00004517          	auipc	a0,0x4
    2ce4:	22850513          	addi	a0,a0,552 # 6f08 <malloc+0x141c>
    2ce8:	00003097          	auipc	ra,0x3
    2cec:	a06080e7          	jalr	-1530(ra) # 56ee <unlink>
  unlink("12345678901234/123456789012345");
    2cf0:	00004517          	auipc	a0,0x4
    2cf4:	1c050513          	addi	a0,a0,448 # 6eb0 <malloc+0x13c4>
    2cf8:	00003097          	auipc	ra,0x3
    2cfc:	9f6080e7          	jalr	-1546(ra) # 56ee <unlink>
  unlink("12345678901234");
    2d00:	00004517          	auipc	a0,0x4
    2d04:	35850513          	addi	a0,a0,856 # 7058 <malloc+0x156c>
    2d08:	00003097          	auipc	ra,0x3
    2d0c:	9e6080e7          	jalr	-1562(ra) # 56ee <unlink>
}
    2d10:	60e2                	ld	ra,24(sp)
    2d12:	6442                	ld	s0,16(sp)
    2d14:	64a2                	ld	s1,8(sp)
    2d16:	6105                	addi	sp,sp,32
    2d18:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2d1a:	85a6                	mv	a1,s1
    2d1c:	00004517          	auipc	a0,0x4
    2d20:	16c50513          	addi	a0,a0,364 # 6e88 <malloc+0x139c>
    2d24:	00003097          	auipc	ra,0x3
    2d28:	d0a080e7          	jalr	-758(ra) # 5a2e <printf>
    exit(1);
    2d2c:	4505                	li	a0,1
    2d2e:	00003097          	auipc	ra,0x3
    2d32:	970080e7          	jalr	-1680(ra) # 569e <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2d36:	85a6                	mv	a1,s1
    2d38:	00004517          	auipc	a0,0x4
    2d3c:	19850513          	addi	a0,a0,408 # 6ed0 <malloc+0x13e4>
    2d40:	00003097          	auipc	ra,0x3
    2d44:	cee080e7          	jalr	-786(ra) # 5a2e <printf>
    exit(1);
    2d48:	4505                	li	a0,1
    2d4a:	00003097          	auipc	ra,0x3
    2d4e:	954080e7          	jalr	-1708(ra) # 569e <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2d52:	85a6                	mv	a1,s1
    2d54:	00004517          	auipc	a0,0x4
    2d58:	1e450513          	addi	a0,a0,484 # 6f38 <malloc+0x144c>
    2d5c:	00003097          	auipc	ra,0x3
    2d60:	cd2080e7          	jalr	-814(ra) # 5a2e <printf>
    exit(1);
    2d64:	4505                	li	a0,1
    2d66:	00003097          	auipc	ra,0x3
    2d6a:	938080e7          	jalr	-1736(ra) # 569e <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2d6e:	85a6                	mv	a1,s1
    2d70:	00004517          	auipc	a0,0x4
    2d74:	24050513          	addi	a0,a0,576 # 6fb0 <malloc+0x14c4>
    2d78:	00003097          	auipc	ra,0x3
    2d7c:	cb6080e7          	jalr	-842(ra) # 5a2e <printf>
    exit(1);
    2d80:	4505                	li	a0,1
    2d82:	00003097          	auipc	ra,0x3
    2d86:	91c080e7          	jalr	-1764(ra) # 569e <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2d8a:	85a6                	mv	a1,s1
    2d8c:	00004517          	auipc	a0,0x4
    2d90:	28450513          	addi	a0,a0,644 # 7010 <malloc+0x1524>
    2d94:	00003097          	auipc	ra,0x3
    2d98:	c9a080e7          	jalr	-870(ra) # 5a2e <printf>
    exit(1);
    2d9c:	4505                	li	a0,1
    2d9e:	00003097          	auipc	ra,0x3
    2da2:	900080e7          	jalr	-1792(ra) # 569e <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2da6:	85a6                	mv	a1,s1
    2da8:	00004517          	auipc	a0,0x4
    2dac:	2c050513          	addi	a0,a0,704 # 7068 <malloc+0x157c>
    2db0:	00003097          	auipc	ra,0x3
    2db4:	c7e080e7          	jalr	-898(ra) # 5a2e <printf>
    exit(1);
    2db8:	4505                	li	a0,1
    2dba:	00003097          	auipc	ra,0x3
    2dbe:	8e4080e7          	jalr	-1820(ra) # 569e <exit>

0000000000002dc2 <iputtest>:
{
    2dc2:	1101                	addi	sp,sp,-32
    2dc4:	ec06                	sd	ra,24(sp)
    2dc6:	e822                	sd	s0,16(sp)
    2dc8:	e426                	sd	s1,8(sp)
    2dca:	1000                	addi	s0,sp,32
    2dcc:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2dce:	00004517          	auipc	a0,0x4
    2dd2:	2d250513          	addi	a0,a0,722 # 70a0 <malloc+0x15b4>
    2dd6:	00003097          	auipc	ra,0x3
    2dda:	930080e7          	jalr	-1744(ra) # 5706 <mkdir>
    2dde:	04054563          	bltz	a0,2e28 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    2de2:	00004517          	auipc	a0,0x4
    2de6:	2be50513          	addi	a0,a0,702 # 70a0 <malloc+0x15b4>
    2dea:	00003097          	auipc	ra,0x3
    2dee:	924080e7          	jalr	-1756(ra) # 570e <chdir>
    2df2:	04054963          	bltz	a0,2e44 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2df6:	00004517          	auipc	a0,0x4
    2dfa:	2ea50513          	addi	a0,a0,746 # 70e0 <malloc+0x15f4>
    2dfe:	00003097          	auipc	ra,0x3
    2e02:	8f0080e7          	jalr	-1808(ra) # 56ee <unlink>
    2e06:	04054d63          	bltz	a0,2e60 <iputtest+0x9e>
  if(chdir("/") < 0){
    2e0a:	00004517          	auipc	a0,0x4
    2e0e:	30650513          	addi	a0,a0,774 # 7110 <malloc+0x1624>
    2e12:	00003097          	auipc	ra,0x3
    2e16:	8fc080e7          	jalr	-1796(ra) # 570e <chdir>
    2e1a:	06054163          	bltz	a0,2e7c <iputtest+0xba>
}
    2e1e:	60e2                	ld	ra,24(sp)
    2e20:	6442                	ld	s0,16(sp)
    2e22:	64a2                	ld	s1,8(sp)
    2e24:	6105                	addi	sp,sp,32
    2e26:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2e28:	85a6                	mv	a1,s1
    2e2a:	00004517          	auipc	a0,0x4
    2e2e:	27e50513          	addi	a0,a0,638 # 70a8 <malloc+0x15bc>
    2e32:	00003097          	auipc	ra,0x3
    2e36:	bfc080e7          	jalr	-1028(ra) # 5a2e <printf>
    exit(1);
    2e3a:	4505                	li	a0,1
    2e3c:	00003097          	auipc	ra,0x3
    2e40:	862080e7          	jalr	-1950(ra) # 569e <exit>
    printf("%s: chdir iputdir failed\n", s);
    2e44:	85a6                	mv	a1,s1
    2e46:	00004517          	auipc	a0,0x4
    2e4a:	27a50513          	addi	a0,a0,634 # 70c0 <malloc+0x15d4>
    2e4e:	00003097          	auipc	ra,0x3
    2e52:	be0080e7          	jalr	-1056(ra) # 5a2e <printf>
    exit(1);
    2e56:	4505                	li	a0,1
    2e58:	00003097          	auipc	ra,0x3
    2e5c:	846080e7          	jalr	-1978(ra) # 569e <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2e60:	85a6                	mv	a1,s1
    2e62:	00004517          	auipc	a0,0x4
    2e66:	28e50513          	addi	a0,a0,654 # 70f0 <malloc+0x1604>
    2e6a:	00003097          	auipc	ra,0x3
    2e6e:	bc4080e7          	jalr	-1084(ra) # 5a2e <printf>
    exit(1);
    2e72:	4505                	li	a0,1
    2e74:	00003097          	auipc	ra,0x3
    2e78:	82a080e7          	jalr	-2006(ra) # 569e <exit>
    printf("%s: chdir / failed\n", s);
    2e7c:	85a6                	mv	a1,s1
    2e7e:	00004517          	auipc	a0,0x4
    2e82:	29a50513          	addi	a0,a0,666 # 7118 <malloc+0x162c>
    2e86:	00003097          	auipc	ra,0x3
    2e8a:	ba8080e7          	jalr	-1112(ra) # 5a2e <printf>
    exit(1);
    2e8e:	4505                	li	a0,1
    2e90:	00003097          	auipc	ra,0x3
    2e94:	80e080e7          	jalr	-2034(ra) # 569e <exit>

0000000000002e98 <exitiputtest>:
{
    2e98:	7179                	addi	sp,sp,-48
    2e9a:	f406                	sd	ra,40(sp)
    2e9c:	f022                	sd	s0,32(sp)
    2e9e:	ec26                	sd	s1,24(sp)
    2ea0:	1800                	addi	s0,sp,48
    2ea2:	84aa                	mv	s1,a0
  pid = fork();
    2ea4:	00002097          	auipc	ra,0x2
    2ea8:	7f2080e7          	jalr	2034(ra) # 5696 <fork>
  if(pid < 0){
    2eac:	04054663          	bltz	a0,2ef8 <exitiputtest+0x60>
  if(pid == 0){
    2eb0:	ed45                	bnez	a0,2f68 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    2eb2:	00004517          	auipc	a0,0x4
    2eb6:	1ee50513          	addi	a0,a0,494 # 70a0 <malloc+0x15b4>
    2eba:	00003097          	auipc	ra,0x3
    2ebe:	84c080e7          	jalr	-1972(ra) # 5706 <mkdir>
    2ec2:	04054963          	bltz	a0,2f14 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    2ec6:	00004517          	auipc	a0,0x4
    2eca:	1da50513          	addi	a0,a0,474 # 70a0 <malloc+0x15b4>
    2ece:	00003097          	auipc	ra,0x3
    2ed2:	840080e7          	jalr	-1984(ra) # 570e <chdir>
    2ed6:	04054d63          	bltz	a0,2f30 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    2eda:	00004517          	auipc	a0,0x4
    2ede:	20650513          	addi	a0,a0,518 # 70e0 <malloc+0x15f4>
    2ee2:	00003097          	auipc	ra,0x3
    2ee6:	80c080e7          	jalr	-2036(ra) # 56ee <unlink>
    2eea:	06054163          	bltz	a0,2f4c <exitiputtest+0xb4>
    exit(0);
    2eee:	4501                	li	a0,0
    2ef0:	00002097          	auipc	ra,0x2
    2ef4:	7ae080e7          	jalr	1966(ra) # 569e <exit>
    printf("%s: fork failed\n", s);
    2ef8:	85a6                	mv	a1,s1
    2efa:	00004517          	auipc	a0,0x4
    2efe:	86650513          	addi	a0,a0,-1946 # 6760 <malloc+0xc74>
    2f02:	00003097          	auipc	ra,0x3
    2f06:	b2c080e7          	jalr	-1236(ra) # 5a2e <printf>
    exit(1);
    2f0a:	4505                	li	a0,1
    2f0c:	00002097          	auipc	ra,0x2
    2f10:	792080e7          	jalr	1938(ra) # 569e <exit>
      printf("%s: mkdir failed\n", s);
    2f14:	85a6                	mv	a1,s1
    2f16:	00004517          	auipc	a0,0x4
    2f1a:	19250513          	addi	a0,a0,402 # 70a8 <malloc+0x15bc>
    2f1e:	00003097          	auipc	ra,0x3
    2f22:	b10080e7          	jalr	-1264(ra) # 5a2e <printf>
      exit(1);
    2f26:	4505                	li	a0,1
    2f28:	00002097          	auipc	ra,0x2
    2f2c:	776080e7          	jalr	1910(ra) # 569e <exit>
      printf("%s: child chdir failed\n", s);
    2f30:	85a6                	mv	a1,s1
    2f32:	00004517          	auipc	a0,0x4
    2f36:	1fe50513          	addi	a0,a0,510 # 7130 <malloc+0x1644>
    2f3a:	00003097          	auipc	ra,0x3
    2f3e:	af4080e7          	jalr	-1292(ra) # 5a2e <printf>
      exit(1);
    2f42:	4505                	li	a0,1
    2f44:	00002097          	auipc	ra,0x2
    2f48:	75a080e7          	jalr	1882(ra) # 569e <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2f4c:	85a6                	mv	a1,s1
    2f4e:	00004517          	auipc	a0,0x4
    2f52:	1a250513          	addi	a0,a0,418 # 70f0 <malloc+0x1604>
    2f56:	00003097          	auipc	ra,0x3
    2f5a:	ad8080e7          	jalr	-1320(ra) # 5a2e <printf>
      exit(1);
    2f5e:	4505                	li	a0,1
    2f60:	00002097          	auipc	ra,0x2
    2f64:	73e080e7          	jalr	1854(ra) # 569e <exit>
  wait(&xstatus);
    2f68:	fdc40513          	addi	a0,s0,-36
    2f6c:	00002097          	auipc	ra,0x2
    2f70:	73a080e7          	jalr	1850(ra) # 56a6 <wait>
  exit(xstatus);
    2f74:	fdc42503          	lw	a0,-36(s0)
    2f78:	00002097          	auipc	ra,0x2
    2f7c:	726080e7          	jalr	1830(ra) # 569e <exit>

0000000000002f80 <dirtest>:
{
    2f80:	1101                	addi	sp,sp,-32
    2f82:	ec06                	sd	ra,24(sp)
    2f84:	e822                	sd	s0,16(sp)
    2f86:	e426                	sd	s1,8(sp)
    2f88:	1000                	addi	s0,sp,32
    2f8a:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2f8c:	00004517          	auipc	a0,0x4
    2f90:	1bc50513          	addi	a0,a0,444 # 7148 <malloc+0x165c>
    2f94:	00002097          	auipc	ra,0x2
    2f98:	772080e7          	jalr	1906(ra) # 5706 <mkdir>
    2f9c:	04054563          	bltz	a0,2fe6 <dirtest+0x66>
  if(chdir("dir0") < 0){
    2fa0:	00004517          	auipc	a0,0x4
    2fa4:	1a850513          	addi	a0,a0,424 # 7148 <malloc+0x165c>
    2fa8:	00002097          	auipc	ra,0x2
    2fac:	766080e7          	jalr	1894(ra) # 570e <chdir>
    2fb0:	04054963          	bltz	a0,3002 <dirtest+0x82>
  if(chdir("..") < 0){
    2fb4:	00004517          	auipc	a0,0x4
    2fb8:	1b450513          	addi	a0,a0,436 # 7168 <malloc+0x167c>
    2fbc:	00002097          	auipc	ra,0x2
    2fc0:	752080e7          	jalr	1874(ra) # 570e <chdir>
    2fc4:	04054d63          	bltz	a0,301e <dirtest+0x9e>
  if(unlink("dir0") < 0){
    2fc8:	00004517          	auipc	a0,0x4
    2fcc:	18050513          	addi	a0,a0,384 # 7148 <malloc+0x165c>
    2fd0:	00002097          	auipc	ra,0x2
    2fd4:	71e080e7          	jalr	1822(ra) # 56ee <unlink>
    2fd8:	06054163          	bltz	a0,303a <dirtest+0xba>
}
    2fdc:	60e2                	ld	ra,24(sp)
    2fde:	6442                	ld	s0,16(sp)
    2fe0:	64a2                	ld	s1,8(sp)
    2fe2:	6105                	addi	sp,sp,32
    2fe4:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2fe6:	85a6                	mv	a1,s1
    2fe8:	00004517          	auipc	a0,0x4
    2fec:	0c050513          	addi	a0,a0,192 # 70a8 <malloc+0x15bc>
    2ff0:	00003097          	auipc	ra,0x3
    2ff4:	a3e080e7          	jalr	-1474(ra) # 5a2e <printf>
    exit(1);
    2ff8:	4505                	li	a0,1
    2ffa:	00002097          	auipc	ra,0x2
    2ffe:	6a4080e7          	jalr	1700(ra) # 569e <exit>
    printf("%s: chdir dir0 failed\n", s);
    3002:	85a6                	mv	a1,s1
    3004:	00004517          	auipc	a0,0x4
    3008:	14c50513          	addi	a0,a0,332 # 7150 <malloc+0x1664>
    300c:	00003097          	auipc	ra,0x3
    3010:	a22080e7          	jalr	-1502(ra) # 5a2e <printf>
    exit(1);
    3014:	4505                	li	a0,1
    3016:	00002097          	auipc	ra,0x2
    301a:	688080e7          	jalr	1672(ra) # 569e <exit>
    printf("%s: chdir .. failed\n", s);
    301e:	85a6                	mv	a1,s1
    3020:	00004517          	auipc	a0,0x4
    3024:	15050513          	addi	a0,a0,336 # 7170 <malloc+0x1684>
    3028:	00003097          	auipc	ra,0x3
    302c:	a06080e7          	jalr	-1530(ra) # 5a2e <printf>
    exit(1);
    3030:	4505                	li	a0,1
    3032:	00002097          	auipc	ra,0x2
    3036:	66c080e7          	jalr	1644(ra) # 569e <exit>
    printf("%s: unlink dir0 failed\n", s);
    303a:	85a6                	mv	a1,s1
    303c:	00004517          	auipc	a0,0x4
    3040:	14c50513          	addi	a0,a0,332 # 7188 <malloc+0x169c>
    3044:	00003097          	auipc	ra,0x3
    3048:	9ea080e7          	jalr	-1558(ra) # 5a2e <printf>
    exit(1);
    304c:	4505                	li	a0,1
    304e:	00002097          	auipc	ra,0x2
    3052:	650080e7          	jalr	1616(ra) # 569e <exit>

0000000000003056 <subdir>:
{
    3056:	1101                	addi	sp,sp,-32
    3058:	ec06                	sd	ra,24(sp)
    305a:	e822                	sd	s0,16(sp)
    305c:	e426                	sd	s1,8(sp)
    305e:	e04a                	sd	s2,0(sp)
    3060:	1000                	addi	s0,sp,32
    3062:	892a                	mv	s2,a0
  unlink("ff");
    3064:	00004517          	auipc	a0,0x4
    3068:	26c50513          	addi	a0,a0,620 # 72d0 <malloc+0x17e4>
    306c:	00002097          	auipc	ra,0x2
    3070:	682080e7          	jalr	1666(ra) # 56ee <unlink>
  if(mkdir("dd") != 0){
    3074:	00004517          	auipc	a0,0x4
    3078:	12c50513          	addi	a0,a0,300 # 71a0 <malloc+0x16b4>
    307c:	00002097          	auipc	ra,0x2
    3080:	68a080e7          	jalr	1674(ra) # 5706 <mkdir>
    3084:	38051663          	bnez	a0,3410 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    3088:	20200593          	li	a1,514
    308c:	00004517          	auipc	a0,0x4
    3090:	13450513          	addi	a0,a0,308 # 71c0 <malloc+0x16d4>
    3094:	00002097          	auipc	ra,0x2
    3098:	64a080e7          	jalr	1610(ra) # 56de <open>
    309c:	84aa                	mv	s1,a0
  if(fd < 0){
    309e:	38054763          	bltz	a0,342c <subdir+0x3d6>
  write(fd, "ff", 2);
    30a2:	4609                	li	a2,2
    30a4:	00004597          	auipc	a1,0x4
    30a8:	22c58593          	addi	a1,a1,556 # 72d0 <malloc+0x17e4>
    30ac:	00002097          	auipc	ra,0x2
    30b0:	612080e7          	jalr	1554(ra) # 56be <write>
  close(fd);
    30b4:	8526                	mv	a0,s1
    30b6:	00002097          	auipc	ra,0x2
    30ba:	610080e7          	jalr	1552(ra) # 56c6 <close>
  if(unlink("dd") >= 0){
    30be:	00004517          	auipc	a0,0x4
    30c2:	0e250513          	addi	a0,a0,226 # 71a0 <malloc+0x16b4>
    30c6:	00002097          	auipc	ra,0x2
    30ca:	628080e7          	jalr	1576(ra) # 56ee <unlink>
    30ce:	36055d63          	bgez	a0,3448 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    30d2:	00004517          	auipc	a0,0x4
    30d6:	14650513          	addi	a0,a0,326 # 7218 <malloc+0x172c>
    30da:	00002097          	auipc	ra,0x2
    30de:	62c080e7          	jalr	1580(ra) # 5706 <mkdir>
    30e2:	38051163          	bnez	a0,3464 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    30e6:	20200593          	li	a1,514
    30ea:	00004517          	auipc	a0,0x4
    30ee:	15650513          	addi	a0,a0,342 # 7240 <malloc+0x1754>
    30f2:	00002097          	auipc	ra,0x2
    30f6:	5ec080e7          	jalr	1516(ra) # 56de <open>
    30fa:	84aa                	mv	s1,a0
  if(fd < 0){
    30fc:	38054263          	bltz	a0,3480 <subdir+0x42a>
  write(fd, "FF", 2);
    3100:	4609                	li	a2,2
    3102:	00004597          	auipc	a1,0x4
    3106:	16e58593          	addi	a1,a1,366 # 7270 <malloc+0x1784>
    310a:	00002097          	auipc	ra,0x2
    310e:	5b4080e7          	jalr	1460(ra) # 56be <write>
  close(fd);
    3112:	8526                	mv	a0,s1
    3114:	00002097          	auipc	ra,0x2
    3118:	5b2080e7          	jalr	1458(ra) # 56c6 <close>
  fd = open("dd/dd/../ff", 0);
    311c:	4581                	li	a1,0
    311e:	00004517          	auipc	a0,0x4
    3122:	15a50513          	addi	a0,a0,346 # 7278 <malloc+0x178c>
    3126:	00002097          	auipc	ra,0x2
    312a:	5b8080e7          	jalr	1464(ra) # 56de <open>
    312e:	84aa                	mv	s1,a0
  if(fd < 0){
    3130:	36054663          	bltz	a0,349c <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    3134:	660d                	lui	a2,0x3
    3136:	00009597          	auipc	a1,0x9
    313a:	a1a58593          	addi	a1,a1,-1510 # bb50 <buf>
    313e:	00002097          	auipc	ra,0x2
    3142:	578080e7          	jalr	1400(ra) # 56b6 <read>
  if(cc != 2 || buf[0] != 'f'){
    3146:	4789                	li	a5,2
    3148:	36f51863          	bne	a0,a5,34b8 <subdir+0x462>
    314c:	00009717          	auipc	a4,0x9
    3150:	a0474703          	lbu	a4,-1532(a4) # bb50 <buf>
    3154:	06600793          	li	a5,102
    3158:	36f71063          	bne	a4,a5,34b8 <subdir+0x462>
  close(fd);
    315c:	8526                	mv	a0,s1
    315e:	00002097          	auipc	ra,0x2
    3162:	568080e7          	jalr	1384(ra) # 56c6 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    3166:	00004597          	auipc	a1,0x4
    316a:	16258593          	addi	a1,a1,354 # 72c8 <malloc+0x17dc>
    316e:	00004517          	auipc	a0,0x4
    3172:	0d250513          	addi	a0,a0,210 # 7240 <malloc+0x1754>
    3176:	00002097          	auipc	ra,0x2
    317a:	588080e7          	jalr	1416(ra) # 56fe <link>
    317e:	34051b63          	bnez	a0,34d4 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    3182:	00004517          	auipc	a0,0x4
    3186:	0be50513          	addi	a0,a0,190 # 7240 <malloc+0x1754>
    318a:	00002097          	auipc	ra,0x2
    318e:	564080e7          	jalr	1380(ra) # 56ee <unlink>
    3192:	34051f63          	bnez	a0,34f0 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3196:	4581                	li	a1,0
    3198:	00004517          	auipc	a0,0x4
    319c:	0a850513          	addi	a0,a0,168 # 7240 <malloc+0x1754>
    31a0:	00002097          	auipc	ra,0x2
    31a4:	53e080e7          	jalr	1342(ra) # 56de <open>
    31a8:	36055263          	bgez	a0,350c <subdir+0x4b6>
  if(chdir("dd") != 0){
    31ac:	00004517          	auipc	a0,0x4
    31b0:	ff450513          	addi	a0,a0,-12 # 71a0 <malloc+0x16b4>
    31b4:	00002097          	auipc	ra,0x2
    31b8:	55a080e7          	jalr	1370(ra) # 570e <chdir>
    31bc:	36051663          	bnez	a0,3528 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    31c0:	00004517          	auipc	a0,0x4
    31c4:	1a050513          	addi	a0,a0,416 # 7360 <malloc+0x1874>
    31c8:	00002097          	auipc	ra,0x2
    31cc:	546080e7          	jalr	1350(ra) # 570e <chdir>
    31d0:	36051a63          	bnez	a0,3544 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    31d4:	00004517          	auipc	a0,0x4
    31d8:	1bc50513          	addi	a0,a0,444 # 7390 <malloc+0x18a4>
    31dc:	00002097          	auipc	ra,0x2
    31e0:	532080e7          	jalr	1330(ra) # 570e <chdir>
    31e4:	36051e63          	bnez	a0,3560 <subdir+0x50a>
  if(chdir("./..") != 0){
    31e8:	00004517          	auipc	a0,0x4
    31ec:	1d850513          	addi	a0,a0,472 # 73c0 <malloc+0x18d4>
    31f0:	00002097          	auipc	ra,0x2
    31f4:	51e080e7          	jalr	1310(ra) # 570e <chdir>
    31f8:	38051263          	bnez	a0,357c <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    31fc:	4581                	li	a1,0
    31fe:	00004517          	auipc	a0,0x4
    3202:	0ca50513          	addi	a0,a0,202 # 72c8 <malloc+0x17dc>
    3206:	00002097          	auipc	ra,0x2
    320a:	4d8080e7          	jalr	1240(ra) # 56de <open>
    320e:	84aa                	mv	s1,a0
  if(fd < 0){
    3210:	38054463          	bltz	a0,3598 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    3214:	660d                	lui	a2,0x3
    3216:	00009597          	auipc	a1,0x9
    321a:	93a58593          	addi	a1,a1,-1734 # bb50 <buf>
    321e:	00002097          	auipc	ra,0x2
    3222:	498080e7          	jalr	1176(ra) # 56b6 <read>
    3226:	4789                	li	a5,2
    3228:	38f51663          	bne	a0,a5,35b4 <subdir+0x55e>
  close(fd);
    322c:	8526                	mv	a0,s1
    322e:	00002097          	auipc	ra,0x2
    3232:	498080e7          	jalr	1176(ra) # 56c6 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3236:	4581                	li	a1,0
    3238:	00004517          	auipc	a0,0x4
    323c:	00850513          	addi	a0,a0,8 # 7240 <malloc+0x1754>
    3240:	00002097          	auipc	ra,0x2
    3244:	49e080e7          	jalr	1182(ra) # 56de <open>
    3248:	38055463          	bgez	a0,35d0 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    324c:	20200593          	li	a1,514
    3250:	00004517          	auipc	a0,0x4
    3254:	20050513          	addi	a0,a0,512 # 7450 <malloc+0x1964>
    3258:	00002097          	auipc	ra,0x2
    325c:	486080e7          	jalr	1158(ra) # 56de <open>
    3260:	38055663          	bgez	a0,35ec <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    3264:	20200593          	li	a1,514
    3268:	00004517          	auipc	a0,0x4
    326c:	21850513          	addi	a0,a0,536 # 7480 <malloc+0x1994>
    3270:	00002097          	auipc	ra,0x2
    3274:	46e080e7          	jalr	1134(ra) # 56de <open>
    3278:	38055863          	bgez	a0,3608 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    327c:	20000593          	li	a1,512
    3280:	00004517          	auipc	a0,0x4
    3284:	f2050513          	addi	a0,a0,-224 # 71a0 <malloc+0x16b4>
    3288:	00002097          	auipc	ra,0x2
    328c:	456080e7          	jalr	1110(ra) # 56de <open>
    3290:	38055a63          	bgez	a0,3624 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    3294:	4589                	li	a1,2
    3296:	00004517          	auipc	a0,0x4
    329a:	f0a50513          	addi	a0,a0,-246 # 71a0 <malloc+0x16b4>
    329e:	00002097          	auipc	ra,0x2
    32a2:	440080e7          	jalr	1088(ra) # 56de <open>
    32a6:	38055d63          	bgez	a0,3640 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    32aa:	4585                	li	a1,1
    32ac:	00004517          	auipc	a0,0x4
    32b0:	ef450513          	addi	a0,a0,-268 # 71a0 <malloc+0x16b4>
    32b4:	00002097          	auipc	ra,0x2
    32b8:	42a080e7          	jalr	1066(ra) # 56de <open>
    32bc:	3a055063          	bgez	a0,365c <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    32c0:	00004597          	auipc	a1,0x4
    32c4:	25058593          	addi	a1,a1,592 # 7510 <malloc+0x1a24>
    32c8:	00004517          	auipc	a0,0x4
    32cc:	18850513          	addi	a0,a0,392 # 7450 <malloc+0x1964>
    32d0:	00002097          	auipc	ra,0x2
    32d4:	42e080e7          	jalr	1070(ra) # 56fe <link>
    32d8:	3a050063          	beqz	a0,3678 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    32dc:	00004597          	auipc	a1,0x4
    32e0:	23458593          	addi	a1,a1,564 # 7510 <malloc+0x1a24>
    32e4:	00004517          	auipc	a0,0x4
    32e8:	19c50513          	addi	a0,a0,412 # 7480 <malloc+0x1994>
    32ec:	00002097          	auipc	ra,0x2
    32f0:	412080e7          	jalr	1042(ra) # 56fe <link>
    32f4:	3a050063          	beqz	a0,3694 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    32f8:	00004597          	auipc	a1,0x4
    32fc:	fd058593          	addi	a1,a1,-48 # 72c8 <malloc+0x17dc>
    3300:	00004517          	auipc	a0,0x4
    3304:	ec050513          	addi	a0,a0,-320 # 71c0 <malloc+0x16d4>
    3308:	00002097          	auipc	ra,0x2
    330c:	3f6080e7          	jalr	1014(ra) # 56fe <link>
    3310:	3a050063          	beqz	a0,36b0 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    3314:	00004517          	auipc	a0,0x4
    3318:	13c50513          	addi	a0,a0,316 # 7450 <malloc+0x1964>
    331c:	00002097          	auipc	ra,0x2
    3320:	3ea080e7          	jalr	1002(ra) # 5706 <mkdir>
    3324:	3a050463          	beqz	a0,36cc <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    3328:	00004517          	auipc	a0,0x4
    332c:	15850513          	addi	a0,a0,344 # 7480 <malloc+0x1994>
    3330:	00002097          	auipc	ra,0x2
    3334:	3d6080e7          	jalr	982(ra) # 5706 <mkdir>
    3338:	3a050863          	beqz	a0,36e8 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    333c:	00004517          	auipc	a0,0x4
    3340:	f8c50513          	addi	a0,a0,-116 # 72c8 <malloc+0x17dc>
    3344:	00002097          	auipc	ra,0x2
    3348:	3c2080e7          	jalr	962(ra) # 5706 <mkdir>
    334c:	3a050c63          	beqz	a0,3704 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    3350:	00004517          	auipc	a0,0x4
    3354:	13050513          	addi	a0,a0,304 # 7480 <malloc+0x1994>
    3358:	00002097          	auipc	ra,0x2
    335c:	396080e7          	jalr	918(ra) # 56ee <unlink>
    3360:	3c050063          	beqz	a0,3720 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    3364:	00004517          	auipc	a0,0x4
    3368:	0ec50513          	addi	a0,a0,236 # 7450 <malloc+0x1964>
    336c:	00002097          	auipc	ra,0x2
    3370:	382080e7          	jalr	898(ra) # 56ee <unlink>
    3374:	3c050463          	beqz	a0,373c <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    3378:	00004517          	auipc	a0,0x4
    337c:	e4850513          	addi	a0,a0,-440 # 71c0 <malloc+0x16d4>
    3380:	00002097          	auipc	ra,0x2
    3384:	38e080e7          	jalr	910(ra) # 570e <chdir>
    3388:	3c050863          	beqz	a0,3758 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    338c:	00004517          	auipc	a0,0x4
    3390:	2d450513          	addi	a0,a0,724 # 7660 <malloc+0x1b74>
    3394:	00002097          	auipc	ra,0x2
    3398:	37a080e7          	jalr	890(ra) # 570e <chdir>
    339c:	3c050c63          	beqz	a0,3774 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    33a0:	00004517          	auipc	a0,0x4
    33a4:	f2850513          	addi	a0,a0,-216 # 72c8 <malloc+0x17dc>
    33a8:	00002097          	auipc	ra,0x2
    33ac:	346080e7          	jalr	838(ra) # 56ee <unlink>
    33b0:	3e051063          	bnez	a0,3790 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    33b4:	00004517          	auipc	a0,0x4
    33b8:	e0c50513          	addi	a0,a0,-500 # 71c0 <malloc+0x16d4>
    33bc:	00002097          	auipc	ra,0x2
    33c0:	332080e7          	jalr	818(ra) # 56ee <unlink>
    33c4:	3e051463          	bnez	a0,37ac <subdir+0x756>
  if(unlink("dd") == 0){
    33c8:	00004517          	auipc	a0,0x4
    33cc:	dd850513          	addi	a0,a0,-552 # 71a0 <malloc+0x16b4>
    33d0:	00002097          	auipc	ra,0x2
    33d4:	31e080e7          	jalr	798(ra) # 56ee <unlink>
    33d8:	3e050863          	beqz	a0,37c8 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    33dc:	00004517          	auipc	a0,0x4
    33e0:	2f450513          	addi	a0,a0,756 # 76d0 <malloc+0x1be4>
    33e4:	00002097          	auipc	ra,0x2
    33e8:	30a080e7          	jalr	778(ra) # 56ee <unlink>
    33ec:	3e054c63          	bltz	a0,37e4 <subdir+0x78e>
  if(unlink("dd") < 0){
    33f0:	00004517          	auipc	a0,0x4
    33f4:	db050513          	addi	a0,a0,-592 # 71a0 <malloc+0x16b4>
    33f8:	00002097          	auipc	ra,0x2
    33fc:	2f6080e7          	jalr	758(ra) # 56ee <unlink>
    3400:	40054063          	bltz	a0,3800 <subdir+0x7aa>
}
    3404:	60e2                	ld	ra,24(sp)
    3406:	6442                	ld	s0,16(sp)
    3408:	64a2                	ld	s1,8(sp)
    340a:	6902                	ld	s2,0(sp)
    340c:	6105                	addi	sp,sp,32
    340e:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    3410:	85ca                	mv	a1,s2
    3412:	00004517          	auipc	a0,0x4
    3416:	d9650513          	addi	a0,a0,-618 # 71a8 <malloc+0x16bc>
    341a:	00002097          	auipc	ra,0x2
    341e:	614080e7          	jalr	1556(ra) # 5a2e <printf>
    exit(1);
    3422:	4505                	li	a0,1
    3424:	00002097          	auipc	ra,0x2
    3428:	27a080e7          	jalr	634(ra) # 569e <exit>
    printf("%s: create dd/ff failed\n", s);
    342c:	85ca                	mv	a1,s2
    342e:	00004517          	auipc	a0,0x4
    3432:	d9a50513          	addi	a0,a0,-614 # 71c8 <malloc+0x16dc>
    3436:	00002097          	auipc	ra,0x2
    343a:	5f8080e7          	jalr	1528(ra) # 5a2e <printf>
    exit(1);
    343e:	4505                	li	a0,1
    3440:	00002097          	auipc	ra,0x2
    3444:	25e080e7          	jalr	606(ra) # 569e <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3448:	85ca                	mv	a1,s2
    344a:	00004517          	auipc	a0,0x4
    344e:	d9e50513          	addi	a0,a0,-610 # 71e8 <malloc+0x16fc>
    3452:	00002097          	auipc	ra,0x2
    3456:	5dc080e7          	jalr	1500(ra) # 5a2e <printf>
    exit(1);
    345a:	4505                	li	a0,1
    345c:	00002097          	auipc	ra,0x2
    3460:	242080e7          	jalr	578(ra) # 569e <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3464:	85ca                	mv	a1,s2
    3466:	00004517          	auipc	a0,0x4
    346a:	dba50513          	addi	a0,a0,-582 # 7220 <malloc+0x1734>
    346e:	00002097          	auipc	ra,0x2
    3472:	5c0080e7          	jalr	1472(ra) # 5a2e <printf>
    exit(1);
    3476:	4505                	li	a0,1
    3478:	00002097          	auipc	ra,0x2
    347c:	226080e7          	jalr	550(ra) # 569e <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3480:	85ca                	mv	a1,s2
    3482:	00004517          	auipc	a0,0x4
    3486:	dce50513          	addi	a0,a0,-562 # 7250 <malloc+0x1764>
    348a:	00002097          	auipc	ra,0x2
    348e:	5a4080e7          	jalr	1444(ra) # 5a2e <printf>
    exit(1);
    3492:	4505                	li	a0,1
    3494:	00002097          	auipc	ra,0x2
    3498:	20a080e7          	jalr	522(ra) # 569e <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    349c:	85ca                	mv	a1,s2
    349e:	00004517          	auipc	a0,0x4
    34a2:	dea50513          	addi	a0,a0,-534 # 7288 <malloc+0x179c>
    34a6:	00002097          	auipc	ra,0x2
    34aa:	588080e7          	jalr	1416(ra) # 5a2e <printf>
    exit(1);
    34ae:	4505                	li	a0,1
    34b0:	00002097          	auipc	ra,0x2
    34b4:	1ee080e7          	jalr	494(ra) # 569e <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    34b8:	85ca                	mv	a1,s2
    34ba:	00004517          	auipc	a0,0x4
    34be:	dee50513          	addi	a0,a0,-530 # 72a8 <malloc+0x17bc>
    34c2:	00002097          	auipc	ra,0x2
    34c6:	56c080e7          	jalr	1388(ra) # 5a2e <printf>
    exit(1);
    34ca:	4505                	li	a0,1
    34cc:	00002097          	auipc	ra,0x2
    34d0:	1d2080e7          	jalr	466(ra) # 569e <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    34d4:	85ca                	mv	a1,s2
    34d6:	00004517          	auipc	a0,0x4
    34da:	e0250513          	addi	a0,a0,-510 # 72d8 <malloc+0x17ec>
    34de:	00002097          	auipc	ra,0x2
    34e2:	550080e7          	jalr	1360(ra) # 5a2e <printf>
    exit(1);
    34e6:	4505                	li	a0,1
    34e8:	00002097          	auipc	ra,0x2
    34ec:	1b6080e7          	jalr	438(ra) # 569e <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    34f0:	85ca                	mv	a1,s2
    34f2:	00004517          	auipc	a0,0x4
    34f6:	e0e50513          	addi	a0,a0,-498 # 7300 <malloc+0x1814>
    34fa:	00002097          	auipc	ra,0x2
    34fe:	534080e7          	jalr	1332(ra) # 5a2e <printf>
    exit(1);
    3502:	4505                	li	a0,1
    3504:	00002097          	auipc	ra,0x2
    3508:	19a080e7          	jalr	410(ra) # 569e <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    350c:	85ca                	mv	a1,s2
    350e:	00004517          	auipc	a0,0x4
    3512:	e1250513          	addi	a0,a0,-494 # 7320 <malloc+0x1834>
    3516:	00002097          	auipc	ra,0x2
    351a:	518080e7          	jalr	1304(ra) # 5a2e <printf>
    exit(1);
    351e:	4505                	li	a0,1
    3520:	00002097          	auipc	ra,0x2
    3524:	17e080e7          	jalr	382(ra) # 569e <exit>
    printf("%s: chdir dd failed\n", s);
    3528:	85ca                	mv	a1,s2
    352a:	00004517          	auipc	a0,0x4
    352e:	e1e50513          	addi	a0,a0,-482 # 7348 <malloc+0x185c>
    3532:	00002097          	auipc	ra,0x2
    3536:	4fc080e7          	jalr	1276(ra) # 5a2e <printf>
    exit(1);
    353a:	4505                	li	a0,1
    353c:	00002097          	auipc	ra,0x2
    3540:	162080e7          	jalr	354(ra) # 569e <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3544:	85ca                	mv	a1,s2
    3546:	00004517          	auipc	a0,0x4
    354a:	e2a50513          	addi	a0,a0,-470 # 7370 <malloc+0x1884>
    354e:	00002097          	auipc	ra,0x2
    3552:	4e0080e7          	jalr	1248(ra) # 5a2e <printf>
    exit(1);
    3556:	4505                	li	a0,1
    3558:	00002097          	auipc	ra,0x2
    355c:	146080e7          	jalr	326(ra) # 569e <exit>
    printf("chdir dd/../../dd failed\n", s);
    3560:	85ca                	mv	a1,s2
    3562:	00004517          	auipc	a0,0x4
    3566:	e3e50513          	addi	a0,a0,-450 # 73a0 <malloc+0x18b4>
    356a:	00002097          	auipc	ra,0x2
    356e:	4c4080e7          	jalr	1220(ra) # 5a2e <printf>
    exit(1);
    3572:	4505                	li	a0,1
    3574:	00002097          	auipc	ra,0x2
    3578:	12a080e7          	jalr	298(ra) # 569e <exit>
    printf("%s: chdir ./.. failed\n", s);
    357c:	85ca                	mv	a1,s2
    357e:	00004517          	auipc	a0,0x4
    3582:	e4a50513          	addi	a0,a0,-438 # 73c8 <malloc+0x18dc>
    3586:	00002097          	auipc	ra,0x2
    358a:	4a8080e7          	jalr	1192(ra) # 5a2e <printf>
    exit(1);
    358e:	4505                	li	a0,1
    3590:	00002097          	auipc	ra,0x2
    3594:	10e080e7          	jalr	270(ra) # 569e <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    3598:	85ca                	mv	a1,s2
    359a:	00004517          	auipc	a0,0x4
    359e:	e4650513          	addi	a0,a0,-442 # 73e0 <malloc+0x18f4>
    35a2:	00002097          	auipc	ra,0x2
    35a6:	48c080e7          	jalr	1164(ra) # 5a2e <printf>
    exit(1);
    35aa:	4505                	li	a0,1
    35ac:	00002097          	auipc	ra,0x2
    35b0:	0f2080e7          	jalr	242(ra) # 569e <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    35b4:	85ca                	mv	a1,s2
    35b6:	00004517          	auipc	a0,0x4
    35ba:	e4a50513          	addi	a0,a0,-438 # 7400 <malloc+0x1914>
    35be:	00002097          	auipc	ra,0x2
    35c2:	470080e7          	jalr	1136(ra) # 5a2e <printf>
    exit(1);
    35c6:	4505                	li	a0,1
    35c8:	00002097          	auipc	ra,0x2
    35cc:	0d6080e7          	jalr	214(ra) # 569e <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    35d0:	85ca                	mv	a1,s2
    35d2:	00004517          	auipc	a0,0x4
    35d6:	e4e50513          	addi	a0,a0,-434 # 7420 <malloc+0x1934>
    35da:	00002097          	auipc	ra,0x2
    35de:	454080e7          	jalr	1108(ra) # 5a2e <printf>
    exit(1);
    35e2:	4505                	li	a0,1
    35e4:	00002097          	auipc	ra,0x2
    35e8:	0ba080e7          	jalr	186(ra) # 569e <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    35ec:	85ca                	mv	a1,s2
    35ee:	00004517          	auipc	a0,0x4
    35f2:	e7250513          	addi	a0,a0,-398 # 7460 <malloc+0x1974>
    35f6:	00002097          	auipc	ra,0x2
    35fa:	438080e7          	jalr	1080(ra) # 5a2e <printf>
    exit(1);
    35fe:	4505                	li	a0,1
    3600:	00002097          	auipc	ra,0x2
    3604:	09e080e7          	jalr	158(ra) # 569e <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3608:	85ca                	mv	a1,s2
    360a:	00004517          	auipc	a0,0x4
    360e:	e8650513          	addi	a0,a0,-378 # 7490 <malloc+0x19a4>
    3612:	00002097          	auipc	ra,0x2
    3616:	41c080e7          	jalr	1052(ra) # 5a2e <printf>
    exit(1);
    361a:	4505                	li	a0,1
    361c:	00002097          	auipc	ra,0x2
    3620:	082080e7          	jalr	130(ra) # 569e <exit>
    printf("%s: create dd succeeded!\n", s);
    3624:	85ca                	mv	a1,s2
    3626:	00004517          	auipc	a0,0x4
    362a:	e8a50513          	addi	a0,a0,-374 # 74b0 <malloc+0x19c4>
    362e:	00002097          	auipc	ra,0x2
    3632:	400080e7          	jalr	1024(ra) # 5a2e <printf>
    exit(1);
    3636:	4505                	li	a0,1
    3638:	00002097          	auipc	ra,0x2
    363c:	066080e7          	jalr	102(ra) # 569e <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3640:	85ca                	mv	a1,s2
    3642:	00004517          	auipc	a0,0x4
    3646:	e8e50513          	addi	a0,a0,-370 # 74d0 <malloc+0x19e4>
    364a:	00002097          	auipc	ra,0x2
    364e:	3e4080e7          	jalr	996(ra) # 5a2e <printf>
    exit(1);
    3652:	4505                	li	a0,1
    3654:	00002097          	auipc	ra,0x2
    3658:	04a080e7          	jalr	74(ra) # 569e <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    365c:	85ca                	mv	a1,s2
    365e:	00004517          	auipc	a0,0x4
    3662:	e9250513          	addi	a0,a0,-366 # 74f0 <malloc+0x1a04>
    3666:	00002097          	auipc	ra,0x2
    366a:	3c8080e7          	jalr	968(ra) # 5a2e <printf>
    exit(1);
    366e:	4505                	li	a0,1
    3670:	00002097          	auipc	ra,0x2
    3674:	02e080e7          	jalr	46(ra) # 569e <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3678:	85ca                	mv	a1,s2
    367a:	00004517          	auipc	a0,0x4
    367e:	ea650513          	addi	a0,a0,-346 # 7520 <malloc+0x1a34>
    3682:	00002097          	auipc	ra,0x2
    3686:	3ac080e7          	jalr	940(ra) # 5a2e <printf>
    exit(1);
    368a:	4505                	li	a0,1
    368c:	00002097          	auipc	ra,0x2
    3690:	012080e7          	jalr	18(ra) # 569e <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3694:	85ca                	mv	a1,s2
    3696:	00004517          	auipc	a0,0x4
    369a:	eb250513          	addi	a0,a0,-334 # 7548 <malloc+0x1a5c>
    369e:	00002097          	auipc	ra,0x2
    36a2:	390080e7          	jalr	912(ra) # 5a2e <printf>
    exit(1);
    36a6:	4505                	li	a0,1
    36a8:	00002097          	auipc	ra,0x2
    36ac:	ff6080e7          	jalr	-10(ra) # 569e <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    36b0:	85ca                	mv	a1,s2
    36b2:	00004517          	auipc	a0,0x4
    36b6:	ebe50513          	addi	a0,a0,-322 # 7570 <malloc+0x1a84>
    36ba:	00002097          	auipc	ra,0x2
    36be:	374080e7          	jalr	884(ra) # 5a2e <printf>
    exit(1);
    36c2:	4505                	li	a0,1
    36c4:	00002097          	auipc	ra,0x2
    36c8:	fda080e7          	jalr	-38(ra) # 569e <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    36cc:	85ca                	mv	a1,s2
    36ce:	00004517          	auipc	a0,0x4
    36d2:	eca50513          	addi	a0,a0,-310 # 7598 <malloc+0x1aac>
    36d6:	00002097          	auipc	ra,0x2
    36da:	358080e7          	jalr	856(ra) # 5a2e <printf>
    exit(1);
    36de:	4505                	li	a0,1
    36e0:	00002097          	auipc	ra,0x2
    36e4:	fbe080e7          	jalr	-66(ra) # 569e <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    36e8:	85ca                	mv	a1,s2
    36ea:	00004517          	auipc	a0,0x4
    36ee:	ece50513          	addi	a0,a0,-306 # 75b8 <malloc+0x1acc>
    36f2:	00002097          	auipc	ra,0x2
    36f6:	33c080e7          	jalr	828(ra) # 5a2e <printf>
    exit(1);
    36fa:	4505                	li	a0,1
    36fc:	00002097          	auipc	ra,0x2
    3700:	fa2080e7          	jalr	-94(ra) # 569e <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3704:	85ca                	mv	a1,s2
    3706:	00004517          	auipc	a0,0x4
    370a:	ed250513          	addi	a0,a0,-302 # 75d8 <malloc+0x1aec>
    370e:	00002097          	auipc	ra,0x2
    3712:	320080e7          	jalr	800(ra) # 5a2e <printf>
    exit(1);
    3716:	4505                	li	a0,1
    3718:	00002097          	auipc	ra,0x2
    371c:	f86080e7          	jalr	-122(ra) # 569e <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3720:	85ca                	mv	a1,s2
    3722:	00004517          	auipc	a0,0x4
    3726:	ede50513          	addi	a0,a0,-290 # 7600 <malloc+0x1b14>
    372a:	00002097          	auipc	ra,0x2
    372e:	304080e7          	jalr	772(ra) # 5a2e <printf>
    exit(1);
    3732:	4505                	li	a0,1
    3734:	00002097          	auipc	ra,0x2
    3738:	f6a080e7          	jalr	-150(ra) # 569e <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    373c:	85ca                	mv	a1,s2
    373e:	00004517          	auipc	a0,0x4
    3742:	ee250513          	addi	a0,a0,-286 # 7620 <malloc+0x1b34>
    3746:	00002097          	auipc	ra,0x2
    374a:	2e8080e7          	jalr	744(ra) # 5a2e <printf>
    exit(1);
    374e:	4505                	li	a0,1
    3750:	00002097          	auipc	ra,0x2
    3754:	f4e080e7          	jalr	-178(ra) # 569e <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3758:	85ca                	mv	a1,s2
    375a:	00004517          	auipc	a0,0x4
    375e:	ee650513          	addi	a0,a0,-282 # 7640 <malloc+0x1b54>
    3762:	00002097          	auipc	ra,0x2
    3766:	2cc080e7          	jalr	716(ra) # 5a2e <printf>
    exit(1);
    376a:	4505                	li	a0,1
    376c:	00002097          	auipc	ra,0x2
    3770:	f32080e7          	jalr	-206(ra) # 569e <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3774:	85ca                	mv	a1,s2
    3776:	00004517          	auipc	a0,0x4
    377a:	ef250513          	addi	a0,a0,-270 # 7668 <malloc+0x1b7c>
    377e:	00002097          	auipc	ra,0x2
    3782:	2b0080e7          	jalr	688(ra) # 5a2e <printf>
    exit(1);
    3786:	4505                	li	a0,1
    3788:	00002097          	auipc	ra,0x2
    378c:	f16080e7          	jalr	-234(ra) # 569e <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3790:	85ca                	mv	a1,s2
    3792:	00004517          	auipc	a0,0x4
    3796:	b6e50513          	addi	a0,a0,-1170 # 7300 <malloc+0x1814>
    379a:	00002097          	auipc	ra,0x2
    379e:	294080e7          	jalr	660(ra) # 5a2e <printf>
    exit(1);
    37a2:	4505                	li	a0,1
    37a4:	00002097          	auipc	ra,0x2
    37a8:	efa080e7          	jalr	-262(ra) # 569e <exit>
    printf("%s: unlink dd/ff failed\n", s);
    37ac:	85ca                	mv	a1,s2
    37ae:	00004517          	auipc	a0,0x4
    37b2:	eda50513          	addi	a0,a0,-294 # 7688 <malloc+0x1b9c>
    37b6:	00002097          	auipc	ra,0x2
    37ba:	278080e7          	jalr	632(ra) # 5a2e <printf>
    exit(1);
    37be:	4505                	li	a0,1
    37c0:	00002097          	auipc	ra,0x2
    37c4:	ede080e7          	jalr	-290(ra) # 569e <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    37c8:	85ca                	mv	a1,s2
    37ca:	00004517          	auipc	a0,0x4
    37ce:	ede50513          	addi	a0,a0,-290 # 76a8 <malloc+0x1bbc>
    37d2:	00002097          	auipc	ra,0x2
    37d6:	25c080e7          	jalr	604(ra) # 5a2e <printf>
    exit(1);
    37da:	4505                	li	a0,1
    37dc:	00002097          	auipc	ra,0x2
    37e0:	ec2080e7          	jalr	-318(ra) # 569e <exit>
    printf("%s: unlink dd/dd failed\n", s);
    37e4:	85ca                	mv	a1,s2
    37e6:	00004517          	auipc	a0,0x4
    37ea:	ef250513          	addi	a0,a0,-270 # 76d8 <malloc+0x1bec>
    37ee:	00002097          	auipc	ra,0x2
    37f2:	240080e7          	jalr	576(ra) # 5a2e <printf>
    exit(1);
    37f6:	4505                	li	a0,1
    37f8:	00002097          	auipc	ra,0x2
    37fc:	ea6080e7          	jalr	-346(ra) # 569e <exit>
    printf("%s: unlink dd failed\n", s);
    3800:	85ca                	mv	a1,s2
    3802:	00004517          	auipc	a0,0x4
    3806:	ef650513          	addi	a0,a0,-266 # 76f8 <malloc+0x1c0c>
    380a:	00002097          	auipc	ra,0x2
    380e:	224080e7          	jalr	548(ra) # 5a2e <printf>
    exit(1);
    3812:	4505                	li	a0,1
    3814:	00002097          	auipc	ra,0x2
    3818:	e8a080e7          	jalr	-374(ra) # 569e <exit>

000000000000381c <rmdot>:
{
    381c:	1101                	addi	sp,sp,-32
    381e:	ec06                	sd	ra,24(sp)
    3820:	e822                	sd	s0,16(sp)
    3822:	e426                	sd	s1,8(sp)
    3824:	1000                	addi	s0,sp,32
    3826:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    3828:	00004517          	auipc	a0,0x4
    382c:	ee850513          	addi	a0,a0,-280 # 7710 <malloc+0x1c24>
    3830:	00002097          	auipc	ra,0x2
    3834:	ed6080e7          	jalr	-298(ra) # 5706 <mkdir>
    3838:	e549                	bnez	a0,38c2 <rmdot+0xa6>
  if(chdir("dots") != 0){
    383a:	00004517          	auipc	a0,0x4
    383e:	ed650513          	addi	a0,a0,-298 # 7710 <malloc+0x1c24>
    3842:	00002097          	auipc	ra,0x2
    3846:	ecc080e7          	jalr	-308(ra) # 570e <chdir>
    384a:	e951                	bnez	a0,38de <rmdot+0xc2>
  if(unlink(".") == 0){
    384c:	00003517          	auipc	a0,0x3
    3850:	d7450513          	addi	a0,a0,-652 # 65c0 <malloc+0xad4>
    3854:	00002097          	auipc	ra,0x2
    3858:	e9a080e7          	jalr	-358(ra) # 56ee <unlink>
    385c:	cd59                	beqz	a0,38fa <rmdot+0xde>
  if(unlink("..") == 0){
    385e:	00004517          	auipc	a0,0x4
    3862:	90a50513          	addi	a0,a0,-1782 # 7168 <malloc+0x167c>
    3866:	00002097          	auipc	ra,0x2
    386a:	e88080e7          	jalr	-376(ra) # 56ee <unlink>
    386e:	c545                	beqz	a0,3916 <rmdot+0xfa>
  if(chdir("/") != 0){
    3870:	00004517          	auipc	a0,0x4
    3874:	8a050513          	addi	a0,a0,-1888 # 7110 <malloc+0x1624>
    3878:	00002097          	auipc	ra,0x2
    387c:	e96080e7          	jalr	-362(ra) # 570e <chdir>
    3880:	e94d                	bnez	a0,3932 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3882:	00004517          	auipc	a0,0x4
    3886:	ef650513          	addi	a0,a0,-266 # 7778 <malloc+0x1c8c>
    388a:	00002097          	auipc	ra,0x2
    388e:	e64080e7          	jalr	-412(ra) # 56ee <unlink>
    3892:	cd55                	beqz	a0,394e <rmdot+0x132>
  if(unlink("dots/..") == 0){
    3894:	00004517          	auipc	a0,0x4
    3898:	f0c50513          	addi	a0,a0,-244 # 77a0 <malloc+0x1cb4>
    389c:	00002097          	auipc	ra,0x2
    38a0:	e52080e7          	jalr	-430(ra) # 56ee <unlink>
    38a4:	c179                	beqz	a0,396a <rmdot+0x14e>
  if(unlink("dots") != 0){
    38a6:	00004517          	auipc	a0,0x4
    38aa:	e6a50513          	addi	a0,a0,-406 # 7710 <malloc+0x1c24>
    38ae:	00002097          	auipc	ra,0x2
    38b2:	e40080e7          	jalr	-448(ra) # 56ee <unlink>
    38b6:	e961                	bnez	a0,3986 <rmdot+0x16a>
}
    38b8:	60e2                	ld	ra,24(sp)
    38ba:	6442                	ld	s0,16(sp)
    38bc:	64a2                	ld	s1,8(sp)
    38be:	6105                	addi	sp,sp,32
    38c0:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    38c2:	85a6                	mv	a1,s1
    38c4:	00004517          	auipc	a0,0x4
    38c8:	e5450513          	addi	a0,a0,-428 # 7718 <malloc+0x1c2c>
    38cc:	00002097          	auipc	ra,0x2
    38d0:	162080e7          	jalr	354(ra) # 5a2e <printf>
    exit(1);
    38d4:	4505                	li	a0,1
    38d6:	00002097          	auipc	ra,0x2
    38da:	dc8080e7          	jalr	-568(ra) # 569e <exit>
    printf("%s: chdir dots failed\n", s);
    38de:	85a6                	mv	a1,s1
    38e0:	00004517          	auipc	a0,0x4
    38e4:	e5050513          	addi	a0,a0,-432 # 7730 <malloc+0x1c44>
    38e8:	00002097          	auipc	ra,0x2
    38ec:	146080e7          	jalr	326(ra) # 5a2e <printf>
    exit(1);
    38f0:	4505                	li	a0,1
    38f2:	00002097          	auipc	ra,0x2
    38f6:	dac080e7          	jalr	-596(ra) # 569e <exit>
    printf("%s: rm . worked!\n", s);
    38fa:	85a6                	mv	a1,s1
    38fc:	00004517          	auipc	a0,0x4
    3900:	e4c50513          	addi	a0,a0,-436 # 7748 <malloc+0x1c5c>
    3904:	00002097          	auipc	ra,0x2
    3908:	12a080e7          	jalr	298(ra) # 5a2e <printf>
    exit(1);
    390c:	4505                	li	a0,1
    390e:	00002097          	auipc	ra,0x2
    3912:	d90080e7          	jalr	-624(ra) # 569e <exit>
    printf("%s: rm .. worked!\n", s);
    3916:	85a6                	mv	a1,s1
    3918:	00004517          	auipc	a0,0x4
    391c:	e4850513          	addi	a0,a0,-440 # 7760 <malloc+0x1c74>
    3920:	00002097          	auipc	ra,0x2
    3924:	10e080e7          	jalr	270(ra) # 5a2e <printf>
    exit(1);
    3928:	4505                	li	a0,1
    392a:	00002097          	auipc	ra,0x2
    392e:	d74080e7          	jalr	-652(ra) # 569e <exit>
    printf("%s: chdir / failed\n", s);
    3932:	85a6                	mv	a1,s1
    3934:	00003517          	auipc	a0,0x3
    3938:	7e450513          	addi	a0,a0,2020 # 7118 <malloc+0x162c>
    393c:	00002097          	auipc	ra,0x2
    3940:	0f2080e7          	jalr	242(ra) # 5a2e <printf>
    exit(1);
    3944:	4505                	li	a0,1
    3946:	00002097          	auipc	ra,0x2
    394a:	d58080e7          	jalr	-680(ra) # 569e <exit>
    printf("%s: unlink dots/. worked!\n", s);
    394e:	85a6                	mv	a1,s1
    3950:	00004517          	auipc	a0,0x4
    3954:	e3050513          	addi	a0,a0,-464 # 7780 <malloc+0x1c94>
    3958:	00002097          	auipc	ra,0x2
    395c:	0d6080e7          	jalr	214(ra) # 5a2e <printf>
    exit(1);
    3960:	4505                	li	a0,1
    3962:	00002097          	auipc	ra,0x2
    3966:	d3c080e7          	jalr	-708(ra) # 569e <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    396a:	85a6                	mv	a1,s1
    396c:	00004517          	auipc	a0,0x4
    3970:	e3c50513          	addi	a0,a0,-452 # 77a8 <malloc+0x1cbc>
    3974:	00002097          	auipc	ra,0x2
    3978:	0ba080e7          	jalr	186(ra) # 5a2e <printf>
    exit(1);
    397c:	4505                	li	a0,1
    397e:	00002097          	auipc	ra,0x2
    3982:	d20080e7          	jalr	-736(ra) # 569e <exit>
    printf("%s: unlink dots failed!\n", s);
    3986:	85a6                	mv	a1,s1
    3988:	00004517          	auipc	a0,0x4
    398c:	e4050513          	addi	a0,a0,-448 # 77c8 <malloc+0x1cdc>
    3990:	00002097          	auipc	ra,0x2
    3994:	09e080e7          	jalr	158(ra) # 5a2e <printf>
    exit(1);
    3998:	4505                	li	a0,1
    399a:	00002097          	auipc	ra,0x2
    399e:	d04080e7          	jalr	-764(ra) # 569e <exit>

00000000000039a2 <dirfile>:
{
    39a2:	1101                	addi	sp,sp,-32
    39a4:	ec06                	sd	ra,24(sp)
    39a6:	e822                	sd	s0,16(sp)
    39a8:	e426                	sd	s1,8(sp)
    39aa:	e04a                	sd	s2,0(sp)
    39ac:	1000                	addi	s0,sp,32
    39ae:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    39b0:	20000593          	li	a1,512
    39b4:	00002517          	auipc	a0,0x2
    39b8:	51450513          	addi	a0,a0,1300 # 5ec8 <malloc+0x3dc>
    39bc:	00002097          	auipc	ra,0x2
    39c0:	d22080e7          	jalr	-734(ra) # 56de <open>
  if(fd < 0){
    39c4:	0e054d63          	bltz	a0,3abe <dirfile+0x11c>
  close(fd);
    39c8:	00002097          	auipc	ra,0x2
    39cc:	cfe080e7          	jalr	-770(ra) # 56c6 <close>
  if(chdir("dirfile") == 0){
    39d0:	00002517          	auipc	a0,0x2
    39d4:	4f850513          	addi	a0,a0,1272 # 5ec8 <malloc+0x3dc>
    39d8:	00002097          	auipc	ra,0x2
    39dc:	d36080e7          	jalr	-714(ra) # 570e <chdir>
    39e0:	cd6d                	beqz	a0,3ada <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    39e2:	4581                	li	a1,0
    39e4:	00004517          	auipc	a0,0x4
    39e8:	e4450513          	addi	a0,a0,-444 # 7828 <malloc+0x1d3c>
    39ec:	00002097          	auipc	ra,0x2
    39f0:	cf2080e7          	jalr	-782(ra) # 56de <open>
  if(fd >= 0){
    39f4:	10055163          	bgez	a0,3af6 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    39f8:	20000593          	li	a1,512
    39fc:	00004517          	auipc	a0,0x4
    3a00:	e2c50513          	addi	a0,a0,-468 # 7828 <malloc+0x1d3c>
    3a04:	00002097          	auipc	ra,0x2
    3a08:	cda080e7          	jalr	-806(ra) # 56de <open>
  if(fd >= 0){
    3a0c:	10055363          	bgez	a0,3b12 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    3a10:	00004517          	auipc	a0,0x4
    3a14:	e1850513          	addi	a0,a0,-488 # 7828 <malloc+0x1d3c>
    3a18:	00002097          	auipc	ra,0x2
    3a1c:	cee080e7          	jalr	-786(ra) # 5706 <mkdir>
    3a20:	10050763          	beqz	a0,3b2e <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    3a24:	00004517          	auipc	a0,0x4
    3a28:	e0450513          	addi	a0,a0,-508 # 7828 <malloc+0x1d3c>
    3a2c:	00002097          	auipc	ra,0x2
    3a30:	cc2080e7          	jalr	-830(ra) # 56ee <unlink>
    3a34:	10050b63          	beqz	a0,3b4a <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    3a38:	00004597          	auipc	a1,0x4
    3a3c:	df058593          	addi	a1,a1,-528 # 7828 <malloc+0x1d3c>
    3a40:	00002517          	auipc	a0,0x2
    3a44:	68050513          	addi	a0,a0,1664 # 60c0 <malloc+0x5d4>
    3a48:	00002097          	auipc	ra,0x2
    3a4c:	cb6080e7          	jalr	-842(ra) # 56fe <link>
    3a50:	10050b63          	beqz	a0,3b66 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    3a54:	00002517          	auipc	a0,0x2
    3a58:	47450513          	addi	a0,a0,1140 # 5ec8 <malloc+0x3dc>
    3a5c:	00002097          	auipc	ra,0x2
    3a60:	c92080e7          	jalr	-878(ra) # 56ee <unlink>
    3a64:	10051f63          	bnez	a0,3b82 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3a68:	4589                	li	a1,2
    3a6a:	00003517          	auipc	a0,0x3
    3a6e:	b5650513          	addi	a0,a0,-1194 # 65c0 <malloc+0xad4>
    3a72:	00002097          	auipc	ra,0x2
    3a76:	c6c080e7          	jalr	-916(ra) # 56de <open>
  if(fd >= 0){
    3a7a:	12055263          	bgez	a0,3b9e <dirfile+0x1fc>
  fd = open(".", 0);
    3a7e:	4581                	li	a1,0
    3a80:	00003517          	auipc	a0,0x3
    3a84:	b4050513          	addi	a0,a0,-1216 # 65c0 <malloc+0xad4>
    3a88:	00002097          	auipc	ra,0x2
    3a8c:	c56080e7          	jalr	-938(ra) # 56de <open>
    3a90:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    3a92:	4605                	li	a2,1
    3a94:	00002597          	auipc	a1,0x2
    3a98:	50458593          	addi	a1,a1,1284 # 5f98 <malloc+0x4ac>
    3a9c:	00002097          	auipc	ra,0x2
    3aa0:	c22080e7          	jalr	-990(ra) # 56be <write>
    3aa4:	10a04b63          	bgtz	a0,3bba <dirfile+0x218>
  close(fd);
    3aa8:	8526                	mv	a0,s1
    3aaa:	00002097          	auipc	ra,0x2
    3aae:	c1c080e7          	jalr	-996(ra) # 56c6 <close>
}
    3ab2:	60e2                	ld	ra,24(sp)
    3ab4:	6442                	ld	s0,16(sp)
    3ab6:	64a2                	ld	s1,8(sp)
    3ab8:	6902                	ld	s2,0(sp)
    3aba:	6105                	addi	sp,sp,32
    3abc:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    3abe:	85ca                	mv	a1,s2
    3ac0:	00004517          	auipc	a0,0x4
    3ac4:	d2850513          	addi	a0,a0,-728 # 77e8 <malloc+0x1cfc>
    3ac8:	00002097          	auipc	ra,0x2
    3acc:	f66080e7          	jalr	-154(ra) # 5a2e <printf>
    exit(1);
    3ad0:	4505                	li	a0,1
    3ad2:	00002097          	auipc	ra,0x2
    3ad6:	bcc080e7          	jalr	-1076(ra) # 569e <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    3ada:	85ca                	mv	a1,s2
    3adc:	00004517          	auipc	a0,0x4
    3ae0:	d2c50513          	addi	a0,a0,-724 # 7808 <malloc+0x1d1c>
    3ae4:	00002097          	auipc	ra,0x2
    3ae8:	f4a080e7          	jalr	-182(ra) # 5a2e <printf>
    exit(1);
    3aec:	4505                	li	a0,1
    3aee:	00002097          	auipc	ra,0x2
    3af2:	bb0080e7          	jalr	-1104(ra) # 569e <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3af6:	85ca                	mv	a1,s2
    3af8:	00004517          	auipc	a0,0x4
    3afc:	d4050513          	addi	a0,a0,-704 # 7838 <malloc+0x1d4c>
    3b00:	00002097          	auipc	ra,0x2
    3b04:	f2e080e7          	jalr	-210(ra) # 5a2e <printf>
    exit(1);
    3b08:	4505                	li	a0,1
    3b0a:	00002097          	auipc	ra,0x2
    3b0e:	b94080e7          	jalr	-1132(ra) # 569e <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3b12:	85ca                	mv	a1,s2
    3b14:	00004517          	auipc	a0,0x4
    3b18:	d2450513          	addi	a0,a0,-732 # 7838 <malloc+0x1d4c>
    3b1c:	00002097          	auipc	ra,0x2
    3b20:	f12080e7          	jalr	-238(ra) # 5a2e <printf>
    exit(1);
    3b24:	4505                	li	a0,1
    3b26:	00002097          	auipc	ra,0x2
    3b2a:	b78080e7          	jalr	-1160(ra) # 569e <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    3b2e:	85ca                	mv	a1,s2
    3b30:	00004517          	auipc	a0,0x4
    3b34:	d3050513          	addi	a0,a0,-720 # 7860 <malloc+0x1d74>
    3b38:	00002097          	auipc	ra,0x2
    3b3c:	ef6080e7          	jalr	-266(ra) # 5a2e <printf>
    exit(1);
    3b40:	4505                	li	a0,1
    3b42:	00002097          	auipc	ra,0x2
    3b46:	b5c080e7          	jalr	-1188(ra) # 569e <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3b4a:	85ca                	mv	a1,s2
    3b4c:	00004517          	auipc	a0,0x4
    3b50:	d3c50513          	addi	a0,a0,-708 # 7888 <malloc+0x1d9c>
    3b54:	00002097          	auipc	ra,0x2
    3b58:	eda080e7          	jalr	-294(ra) # 5a2e <printf>
    exit(1);
    3b5c:	4505                	li	a0,1
    3b5e:	00002097          	auipc	ra,0x2
    3b62:	b40080e7          	jalr	-1216(ra) # 569e <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3b66:	85ca                	mv	a1,s2
    3b68:	00004517          	auipc	a0,0x4
    3b6c:	d4850513          	addi	a0,a0,-696 # 78b0 <malloc+0x1dc4>
    3b70:	00002097          	auipc	ra,0x2
    3b74:	ebe080e7          	jalr	-322(ra) # 5a2e <printf>
    exit(1);
    3b78:	4505                	li	a0,1
    3b7a:	00002097          	auipc	ra,0x2
    3b7e:	b24080e7          	jalr	-1244(ra) # 569e <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3b82:	85ca                	mv	a1,s2
    3b84:	00004517          	auipc	a0,0x4
    3b88:	d5450513          	addi	a0,a0,-684 # 78d8 <malloc+0x1dec>
    3b8c:	00002097          	auipc	ra,0x2
    3b90:	ea2080e7          	jalr	-350(ra) # 5a2e <printf>
    exit(1);
    3b94:	4505                	li	a0,1
    3b96:	00002097          	auipc	ra,0x2
    3b9a:	b08080e7          	jalr	-1272(ra) # 569e <exit>
    printf("%s: open . for writing succeeded!\n", s);
    3b9e:	85ca                	mv	a1,s2
    3ba0:	00004517          	auipc	a0,0x4
    3ba4:	d5850513          	addi	a0,a0,-680 # 78f8 <malloc+0x1e0c>
    3ba8:	00002097          	auipc	ra,0x2
    3bac:	e86080e7          	jalr	-378(ra) # 5a2e <printf>
    exit(1);
    3bb0:	4505                	li	a0,1
    3bb2:	00002097          	auipc	ra,0x2
    3bb6:	aec080e7          	jalr	-1300(ra) # 569e <exit>
    printf("%s: write . succeeded!\n", s);
    3bba:	85ca                	mv	a1,s2
    3bbc:	00004517          	auipc	a0,0x4
    3bc0:	d6450513          	addi	a0,a0,-668 # 7920 <malloc+0x1e34>
    3bc4:	00002097          	auipc	ra,0x2
    3bc8:	e6a080e7          	jalr	-406(ra) # 5a2e <printf>
    exit(1);
    3bcc:	4505                	li	a0,1
    3bce:	00002097          	auipc	ra,0x2
    3bd2:	ad0080e7          	jalr	-1328(ra) # 569e <exit>

0000000000003bd6 <iref>:
{
    3bd6:	7139                	addi	sp,sp,-64
    3bd8:	fc06                	sd	ra,56(sp)
    3bda:	f822                	sd	s0,48(sp)
    3bdc:	f426                	sd	s1,40(sp)
    3bde:	f04a                	sd	s2,32(sp)
    3be0:	ec4e                	sd	s3,24(sp)
    3be2:	e852                	sd	s4,16(sp)
    3be4:	e456                	sd	s5,8(sp)
    3be6:	e05a                	sd	s6,0(sp)
    3be8:	0080                	addi	s0,sp,64
    3bea:	8b2a                	mv	s6,a0
    3bec:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    3bf0:	00004a17          	auipc	s4,0x4
    3bf4:	d48a0a13          	addi	s4,s4,-696 # 7938 <malloc+0x1e4c>
    mkdir("");
    3bf8:	00004497          	auipc	s1,0x4
    3bfc:	85048493          	addi	s1,s1,-1968 # 7448 <malloc+0x195c>
    link("README", "");
    3c00:	00002a97          	auipc	s5,0x2
    3c04:	4c0a8a93          	addi	s5,s5,1216 # 60c0 <malloc+0x5d4>
    fd = open("xx", O_CREATE);
    3c08:	00004997          	auipc	s3,0x4
    3c0c:	c2898993          	addi	s3,s3,-984 # 7830 <malloc+0x1d44>
    3c10:	a891                	j	3c64 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    3c12:	85da                	mv	a1,s6
    3c14:	00004517          	auipc	a0,0x4
    3c18:	d2c50513          	addi	a0,a0,-724 # 7940 <malloc+0x1e54>
    3c1c:	00002097          	auipc	ra,0x2
    3c20:	e12080e7          	jalr	-494(ra) # 5a2e <printf>
      exit(1);
    3c24:	4505                	li	a0,1
    3c26:	00002097          	auipc	ra,0x2
    3c2a:	a78080e7          	jalr	-1416(ra) # 569e <exit>
      printf("%s: chdir irefd failed\n", s);
    3c2e:	85da                	mv	a1,s6
    3c30:	00004517          	auipc	a0,0x4
    3c34:	d2850513          	addi	a0,a0,-728 # 7958 <malloc+0x1e6c>
    3c38:	00002097          	auipc	ra,0x2
    3c3c:	df6080e7          	jalr	-522(ra) # 5a2e <printf>
      exit(1);
    3c40:	4505                	li	a0,1
    3c42:	00002097          	auipc	ra,0x2
    3c46:	a5c080e7          	jalr	-1444(ra) # 569e <exit>
      close(fd);
    3c4a:	00002097          	auipc	ra,0x2
    3c4e:	a7c080e7          	jalr	-1412(ra) # 56c6 <close>
    3c52:	a889                	j	3ca4 <iref+0xce>
    unlink("xx");
    3c54:	854e                	mv	a0,s3
    3c56:	00002097          	auipc	ra,0x2
    3c5a:	a98080e7          	jalr	-1384(ra) # 56ee <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3c5e:	397d                	addiw	s2,s2,-1
    3c60:	06090063          	beqz	s2,3cc0 <iref+0xea>
    if(mkdir("irefd") != 0){
    3c64:	8552                	mv	a0,s4
    3c66:	00002097          	auipc	ra,0x2
    3c6a:	aa0080e7          	jalr	-1376(ra) # 5706 <mkdir>
    3c6e:	f155                	bnez	a0,3c12 <iref+0x3c>
    if(chdir("irefd") != 0){
    3c70:	8552                	mv	a0,s4
    3c72:	00002097          	auipc	ra,0x2
    3c76:	a9c080e7          	jalr	-1380(ra) # 570e <chdir>
    3c7a:	f955                	bnez	a0,3c2e <iref+0x58>
    mkdir("");
    3c7c:	8526                	mv	a0,s1
    3c7e:	00002097          	auipc	ra,0x2
    3c82:	a88080e7          	jalr	-1400(ra) # 5706 <mkdir>
    link("README", "");
    3c86:	85a6                	mv	a1,s1
    3c88:	8556                	mv	a0,s5
    3c8a:	00002097          	auipc	ra,0x2
    3c8e:	a74080e7          	jalr	-1420(ra) # 56fe <link>
    fd = open("", O_CREATE);
    3c92:	20000593          	li	a1,512
    3c96:	8526                	mv	a0,s1
    3c98:	00002097          	auipc	ra,0x2
    3c9c:	a46080e7          	jalr	-1466(ra) # 56de <open>
    if(fd >= 0)
    3ca0:	fa0555e3          	bgez	a0,3c4a <iref+0x74>
    fd = open("xx", O_CREATE);
    3ca4:	20000593          	li	a1,512
    3ca8:	854e                	mv	a0,s3
    3caa:	00002097          	auipc	ra,0x2
    3cae:	a34080e7          	jalr	-1484(ra) # 56de <open>
    if(fd >= 0)
    3cb2:	fa0541e3          	bltz	a0,3c54 <iref+0x7e>
      close(fd);
    3cb6:	00002097          	auipc	ra,0x2
    3cba:	a10080e7          	jalr	-1520(ra) # 56c6 <close>
    3cbe:	bf59                	j	3c54 <iref+0x7e>
    3cc0:	03300493          	li	s1,51
    chdir("..");
    3cc4:	00003997          	auipc	s3,0x3
    3cc8:	4a498993          	addi	s3,s3,1188 # 7168 <malloc+0x167c>
    unlink("irefd");
    3ccc:	00004917          	auipc	s2,0x4
    3cd0:	c6c90913          	addi	s2,s2,-916 # 7938 <malloc+0x1e4c>
    chdir("..");
    3cd4:	854e                	mv	a0,s3
    3cd6:	00002097          	auipc	ra,0x2
    3cda:	a38080e7          	jalr	-1480(ra) # 570e <chdir>
    unlink("irefd");
    3cde:	854a                	mv	a0,s2
    3ce0:	00002097          	auipc	ra,0x2
    3ce4:	a0e080e7          	jalr	-1522(ra) # 56ee <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3ce8:	34fd                	addiw	s1,s1,-1
    3cea:	f4ed                	bnez	s1,3cd4 <iref+0xfe>
  chdir("/");
    3cec:	00003517          	auipc	a0,0x3
    3cf0:	42450513          	addi	a0,a0,1060 # 7110 <malloc+0x1624>
    3cf4:	00002097          	auipc	ra,0x2
    3cf8:	a1a080e7          	jalr	-1510(ra) # 570e <chdir>
}
    3cfc:	70e2                	ld	ra,56(sp)
    3cfe:	7442                	ld	s0,48(sp)
    3d00:	74a2                	ld	s1,40(sp)
    3d02:	7902                	ld	s2,32(sp)
    3d04:	69e2                	ld	s3,24(sp)
    3d06:	6a42                	ld	s4,16(sp)
    3d08:	6aa2                	ld	s5,8(sp)
    3d0a:	6b02                	ld	s6,0(sp)
    3d0c:	6121                	addi	sp,sp,64
    3d0e:	8082                	ret

0000000000003d10 <openiputtest>:
{
    3d10:	7179                	addi	sp,sp,-48
    3d12:	f406                	sd	ra,40(sp)
    3d14:	f022                	sd	s0,32(sp)
    3d16:	ec26                	sd	s1,24(sp)
    3d18:	1800                	addi	s0,sp,48
    3d1a:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    3d1c:	00004517          	auipc	a0,0x4
    3d20:	c5450513          	addi	a0,a0,-940 # 7970 <malloc+0x1e84>
    3d24:	00002097          	auipc	ra,0x2
    3d28:	9e2080e7          	jalr	-1566(ra) # 5706 <mkdir>
    3d2c:	04054263          	bltz	a0,3d70 <openiputtest+0x60>
  pid = fork();
    3d30:	00002097          	auipc	ra,0x2
    3d34:	966080e7          	jalr	-1690(ra) # 5696 <fork>
  if(pid < 0){
    3d38:	04054a63          	bltz	a0,3d8c <openiputtest+0x7c>
  if(pid == 0){
    3d3c:	e93d                	bnez	a0,3db2 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    3d3e:	4589                	li	a1,2
    3d40:	00004517          	auipc	a0,0x4
    3d44:	c3050513          	addi	a0,a0,-976 # 7970 <malloc+0x1e84>
    3d48:	00002097          	auipc	ra,0x2
    3d4c:	996080e7          	jalr	-1642(ra) # 56de <open>
    if(fd >= 0){
    3d50:	04054c63          	bltz	a0,3da8 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    3d54:	85a6                	mv	a1,s1
    3d56:	00004517          	auipc	a0,0x4
    3d5a:	c3a50513          	addi	a0,a0,-966 # 7990 <malloc+0x1ea4>
    3d5e:	00002097          	auipc	ra,0x2
    3d62:	cd0080e7          	jalr	-816(ra) # 5a2e <printf>
      exit(1);
    3d66:	4505                	li	a0,1
    3d68:	00002097          	auipc	ra,0x2
    3d6c:	936080e7          	jalr	-1738(ra) # 569e <exit>
    printf("%s: mkdir oidir failed\n", s);
    3d70:	85a6                	mv	a1,s1
    3d72:	00004517          	auipc	a0,0x4
    3d76:	c0650513          	addi	a0,a0,-1018 # 7978 <malloc+0x1e8c>
    3d7a:	00002097          	auipc	ra,0x2
    3d7e:	cb4080e7          	jalr	-844(ra) # 5a2e <printf>
    exit(1);
    3d82:	4505                	li	a0,1
    3d84:	00002097          	auipc	ra,0x2
    3d88:	91a080e7          	jalr	-1766(ra) # 569e <exit>
    printf("%s: fork failed\n", s);
    3d8c:	85a6                	mv	a1,s1
    3d8e:	00003517          	auipc	a0,0x3
    3d92:	9d250513          	addi	a0,a0,-1582 # 6760 <malloc+0xc74>
    3d96:	00002097          	auipc	ra,0x2
    3d9a:	c98080e7          	jalr	-872(ra) # 5a2e <printf>
    exit(1);
    3d9e:	4505                	li	a0,1
    3da0:	00002097          	auipc	ra,0x2
    3da4:	8fe080e7          	jalr	-1794(ra) # 569e <exit>
    exit(0);
    3da8:	4501                	li	a0,0
    3daa:	00002097          	auipc	ra,0x2
    3dae:	8f4080e7          	jalr	-1804(ra) # 569e <exit>
  sleep(1);
    3db2:	4505                	li	a0,1
    3db4:	00002097          	auipc	ra,0x2
    3db8:	97a080e7          	jalr	-1670(ra) # 572e <sleep>
  if(unlink("oidir") != 0){
    3dbc:	00004517          	auipc	a0,0x4
    3dc0:	bb450513          	addi	a0,a0,-1100 # 7970 <malloc+0x1e84>
    3dc4:	00002097          	auipc	ra,0x2
    3dc8:	92a080e7          	jalr	-1750(ra) # 56ee <unlink>
    3dcc:	cd19                	beqz	a0,3dea <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    3dce:	85a6                	mv	a1,s1
    3dd0:	00003517          	auipc	a0,0x3
    3dd4:	b8050513          	addi	a0,a0,-1152 # 6950 <malloc+0xe64>
    3dd8:	00002097          	auipc	ra,0x2
    3ddc:	c56080e7          	jalr	-938(ra) # 5a2e <printf>
    exit(1);
    3de0:	4505                	li	a0,1
    3de2:	00002097          	auipc	ra,0x2
    3de6:	8bc080e7          	jalr	-1860(ra) # 569e <exit>
  wait(&xstatus);
    3dea:	fdc40513          	addi	a0,s0,-36
    3dee:	00002097          	auipc	ra,0x2
    3df2:	8b8080e7          	jalr	-1864(ra) # 56a6 <wait>
  exit(xstatus);
    3df6:	fdc42503          	lw	a0,-36(s0)
    3dfa:	00002097          	auipc	ra,0x2
    3dfe:	8a4080e7          	jalr	-1884(ra) # 569e <exit>

0000000000003e02 <forkforkfork>:
{
    3e02:	1101                	addi	sp,sp,-32
    3e04:	ec06                	sd	ra,24(sp)
    3e06:	e822                	sd	s0,16(sp)
    3e08:	e426                	sd	s1,8(sp)
    3e0a:	1000                	addi	s0,sp,32
    3e0c:	84aa                	mv	s1,a0
  unlink("stopforking");
    3e0e:	00004517          	auipc	a0,0x4
    3e12:	baa50513          	addi	a0,a0,-1110 # 79b8 <malloc+0x1ecc>
    3e16:	00002097          	auipc	ra,0x2
    3e1a:	8d8080e7          	jalr	-1832(ra) # 56ee <unlink>
  int pid = fork();
    3e1e:	00002097          	auipc	ra,0x2
    3e22:	878080e7          	jalr	-1928(ra) # 5696 <fork>
  if(pid < 0){
    3e26:	04054563          	bltz	a0,3e70 <forkforkfork+0x6e>
  if(pid == 0){
    3e2a:	c12d                	beqz	a0,3e8c <forkforkfork+0x8a>
  sleep(20); // two seconds
    3e2c:	4551                	li	a0,20
    3e2e:	00002097          	auipc	ra,0x2
    3e32:	900080e7          	jalr	-1792(ra) # 572e <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3e36:	20200593          	li	a1,514
    3e3a:	00004517          	auipc	a0,0x4
    3e3e:	b7e50513          	addi	a0,a0,-1154 # 79b8 <malloc+0x1ecc>
    3e42:	00002097          	auipc	ra,0x2
    3e46:	89c080e7          	jalr	-1892(ra) # 56de <open>
    3e4a:	00002097          	auipc	ra,0x2
    3e4e:	87c080e7          	jalr	-1924(ra) # 56c6 <close>
  wait(0);
    3e52:	4501                	li	a0,0
    3e54:	00002097          	auipc	ra,0x2
    3e58:	852080e7          	jalr	-1966(ra) # 56a6 <wait>
  sleep(10); // one second
    3e5c:	4529                	li	a0,10
    3e5e:	00002097          	auipc	ra,0x2
    3e62:	8d0080e7          	jalr	-1840(ra) # 572e <sleep>
}
    3e66:	60e2                	ld	ra,24(sp)
    3e68:	6442                	ld	s0,16(sp)
    3e6a:	64a2                	ld	s1,8(sp)
    3e6c:	6105                	addi	sp,sp,32
    3e6e:	8082                	ret
    printf("%s: fork failed", s);
    3e70:	85a6                	mv	a1,s1
    3e72:	00003517          	auipc	a0,0x3
    3e76:	aae50513          	addi	a0,a0,-1362 # 6920 <malloc+0xe34>
    3e7a:	00002097          	auipc	ra,0x2
    3e7e:	bb4080e7          	jalr	-1100(ra) # 5a2e <printf>
    exit(1);
    3e82:	4505                	li	a0,1
    3e84:	00002097          	auipc	ra,0x2
    3e88:	81a080e7          	jalr	-2022(ra) # 569e <exit>
      int fd = open("stopforking", 0);
    3e8c:	00004497          	auipc	s1,0x4
    3e90:	b2c48493          	addi	s1,s1,-1236 # 79b8 <malloc+0x1ecc>
    3e94:	4581                	li	a1,0
    3e96:	8526                	mv	a0,s1
    3e98:	00002097          	auipc	ra,0x2
    3e9c:	846080e7          	jalr	-1978(ra) # 56de <open>
      if(fd >= 0){
    3ea0:	02055463          	bgez	a0,3ec8 <forkforkfork+0xc6>
      if(fork() < 0){
    3ea4:	00001097          	auipc	ra,0x1
    3ea8:	7f2080e7          	jalr	2034(ra) # 5696 <fork>
    3eac:	fe0554e3          	bgez	a0,3e94 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    3eb0:	20200593          	li	a1,514
    3eb4:	8526                	mv	a0,s1
    3eb6:	00002097          	auipc	ra,0x2
    3eba:	828080e7          	jalr	-2008(ra) # 56de <open>
    3ebe:	00002097          	auipc	ra,0x2
    3ec2:	808080e7          	jalr	-2040(ra) # 56c6 <close>
    3ec6:	b7f9                	j	3e94 <forkforkfork+0x92>
        exit(0);
    3ec8:	4501                	li	a0,0
    3eca:	00001097          	auipc	ra,0x1
    3ece:	7d4080e7          	jalr	2004(ra) # 569e <exit>

0000000000003ed2 <reparent>:
{
    3ed2:	7179                	addi	sp,sp,-48
    3ed4:	f406                	sd	ra,40(sp)
    3ed6:	f022                	sd	s0,32(sp)
    3ed8:	ec26                	sd	s1,24(sp)
    3eda:	e84a                	sd	s2,16(sp)
    3edc:	e44e                	sd	s3,8(sp)
    3ede:	e052                	sd	s4,0(sp)
    3ee0:	1800                	addi	s0,sp,48
    3ee2:	89aa                	mv	s3,a0
  int master_pid = getpid();
    3ee4:	00002097          	auipc	ra,0x2
    3ee8:	83a080e7          	jalr	-1990(ra) # 571e <getpid>
    3eec:	8a2a                	mv	s4,a0
    3eee:	0c800913          	li	s2,200
    int pid = fork();
    3ef2:	00001097          	auipc	ra,0x1
    3ef6:	7a4080e7          	jalr	1956(ra) # 5696 <fork>
    3efa:	84aa                	mv	s1,a0
    if(pid < 0){
    3efc:	02054263          	bltz	a0,3f20 <reparent+0x4e>
    if(pid){
    3f00:	cd21                	beqz	a0,3f58 <reparent+0x86>
      if(wait(0) != pid){
    3f02:	4501                	li	a0,0
    3f04:	00001097          	auipc	ra,0x1
    3f08:	7a2080e7          	jalr	1954(ra) # 56a6 <wait>
    3f0c:	02951863          	bne	a0,s1,3f3c <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    3f10:	397d                	addiw	s2,s2,-1
    3f12:	fe0910e3          	bnez	s2,3ef2 <reparent+0x20>
  exit(0);
    3f16:	4501                	li	a0,0
    3f18:	00001097          	auipc	ra,0x1
    3f1c:	786080e7          	jalr	1926(ra) # 569e <exit>
      printf("%s: fork failed\n", s);
    3f20:	85ce                	mv	a1,s3
    3f22:	00003517          	auipc	a0,0x3
    3f26:	83e50513          	addi	a0,a0,-1986 # 6760 <malloc+0xc74>
    3f2a:	00002097          	auipc	ra,0x2
    3f2e:	b04080e7          	jalr	-1276(ra) # 5a2e <printf>
      exit(1);
    3f32:	4505                	li	a0,1
    3f34:	00001097          	auipc	ra,0x1
    3f38:	76a080e7          	jalr	1898(ra) # 569e <exit>
        printf("%s: wait wrong pid\n", s);
    3f3c:	85ce                	mv	a1,s3
    3f3e:	00003517          	auipc	a0,0x3
    3f42:	9aa50513          	addi	a0,a0,-1622 # 68e8 <malloc+0xdfc>
    3f46:	00002097          	auipc	ra,0x2
    3f4a:	ae8080e7          	jalr	-1304(ra) # 5a2e <printf>
        exit(1);
    3f4e:	4505                	li	a0,1
    3f50:	00001097          	auipc	ra,0x1
    3f54:	74e080e7          	jalr	1870(ra) # 569e <exit>
      int pid2 = fork();
    3f58:	00001097          	auipc	ra,0x1
    3f5c:	73e080e7          	jalr	1854(ra) # 5696 <fork>
      if(pid2 < 0){
    3f60:	00054763          	bltz	a0,3f6e <reparent+0x9c>
      exit(0);
    3f64:	4501                	li	a0,0
    3f66:	00001097          	auipc	ra,0x1
    3f6a:	738080e7          	jalr	1848(ra) # 569e <exit>
        kill(master_pid);
    3f6e:	8552                	mv	a0,s4
    3f70:	00001097          	auipc	ra,0x1
    3f74:	75e080e7          	jalr	1886(ra) # 56ce <kill>
        exit(1);
    3f78:	4505                	li	a0,1
    3f7a:	00001097          	auipc	ra,0x1
    3f7e:	724080e7          	jalr	1828(ra) # 569e <exit>

0000000000003f82 <sbrkfail>:
{
    3f82:	7119                	addi	sp,sp,-128
    3f84:	fc86                	sd	ra,120(sp)
    3f86:	f8a2                	sd	s0,112(sp)
    3f88:	f4a6                	sd	s1,104(sp)
    3f8a:	f0ca                	sd	s2,96(sp)
    3f8c:	ecce                	sd	s3,88(sp)
    3f8e:	e8d2                	sd	s4,80(sp)
    3f90:	e4d6                	sd	s5,72(sp)
    3f92:	0100                	addi	s0,sp,128
    3f94:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    3f96:	fb040513          	addi	a0,s0,-80
    3f9a:	00001097          	auipc	ra,0x1
    3f9e:	714080e7          	jalr	1812(ra) # 56ae <pipe>
    3fa2:	e901                	bnez	a0,3fb2 <sbrkfail+0x30>
    3fa4:	f8040493          	addi	s1,s0,-128
    3fa8:	fa840993          	addi	s3,s0,-88
    3fac:	8926                	mv	s2,s1
    if(pids[i] != -1)
    3fae:	5a7d                	li	s4,-1
    3fb0:	a085                	j	4010 <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    3fb2:	85d6                	mv	a1,s5
    3fb4:	00003517          	auipc	a0,0x3
    3fb8:	8b450513          	addi	a0,a0,-1868 # 6868 <malloc+0xd7c>
    3fbc:	00002097          	auipc	ra,0x2
    3fc0:	a72080e7          	jalr	-1422(ra) # 5a2e <printf>
    exit(1);
    3fc4:	4505                	li	a0,1
    3fc6:	00001097          	auipc	ra,0x1
    3fca:	6d8080e7          	jalr	1752(ra) # 569e <exit>
      sbrk(BIG - (uint64)sbrk(0));
    3fce:	00001097          	auipc	ra,0x1
    3fd2:	758080e7          	jalr	1880(ra) # 5726 <sbrk>
    3fd6:	064007b7          	lui	a5,0x6400
    3fda:	40a7853b          	subw	a0,a5,a0
    3fde:	00001097          	auipc	ra,0x1
    3fe2:	748080e7          	jalr	1864(ra) # 5726 <sbrk>
      write(fds[1], "x", 1);
    3fe6:	4605                	li	a2,1
    3fe8:	00002597          	auipc	a1,0x2
    3fec:	fb058593          	addi	a1,a1,-80 # 5f98 <malloc+0x4ac>
    3ff0:	fb442503          	lw	a0,-76(s0)
    3ff4:	00001097          	auipc	ra,0x1
    3ff8:	6ca080e7          	jalr	1738(ra) # 56be <write>
      for(;;) sleep(1000);
    3ffc:	3e800513          	li	a0,1000
    4000:	00001097          	auipc	ra,0x1
    4004:	72e080e7          	jalr	1838(ra) # 572e <sleep>
    4008:	bfd5                	j	3ffc <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    400a:	0911                	addi	s2,s2,4
    400c:	03390563          	beq	s2,s3,4036 <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    4010:	00001097          	auipc	ra,0x1
    4014:	686080e7          	jalr	1670(ra) # 5696 <fork>
    4018:	00a92023          	sw	a0,0(s2)
    401c:	d94d                	beqz	a0,3fce <sbrkfail+0x4c>
    if(pids[i] != -1)
    401e:	ff4506e3          	beq	a0,s4,400a <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    4022:	4605                	li	a2,1
    4024:	faf40593          	addi	a1,s0,-81
    4028:	fb042503          	lw	a0,-80(s0)
    402c:	00001097          	auipc	ra,0x1
    4030:	68a080e7          	jalr	1674(ra) # 56b6 <read>
    4034:	bfd9                	j	400a <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    4036:	6505                	lui	a0,0x1
    4038:	00001097          	auipc	ra,0x1
    403c:	6ee080e7          	jalr	1774(ra) # 5726 <sbrk>
    4040:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    4042:	597d                	li	s2,-1
    4044:	a021                	j	404c <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4046:	0491                	addi	s1,s1,4
    4048:	01348f63          	beq	s1,s3,4066 <sbrkfail+0xe4>
    if(pids[i] == -1)
    404c:	4088                	lw	a0,0(s1)
    404e:	ff250ce3          	beq	a0,s2,4046 <sbrkfail+0xc4>
    kill(pids[i]);
    4052:	00001097          	auipc	ra,0x1
    4056:	67c080e7          	jalr	1660(ra) # 56ce <kill>
    wait(0);
    405a:	4501                	li	a0,0
    405c:	00001097          	auipc	ra,0x1
    4060:	64a080e7          	jalr	1610(ra) # 56a6 <wait>
    4064:	b7cd                	j	4046 <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    4066:	57fd                	li	a5,-1
    4068:	04fa0163          	beq	s4,a5,40aa <sbrkfail+0x128>
  pid = fork();
    406c:	00001097          	auipc	ra,0x1
    4070:	62a080e7          	jalr	1578(ra) # 5696 <fork>
    4074:	84aa                	mv	s1,a0
  if(pid < 0){
    4076:	04054863          	bltz	a0,40c6 <sbrkfail+0x144>
  if(pid == 0){
    407a:	c525                	beqz	a0,40e2 <sbrkfail+0x160>
  wait(&xstatus);
    407c:	fbc40513          	addi	a0,s0,-68
    4080:	00001097          	auipc	ra,0x1
    4084:	626080e7          	jalr	1574(ra) # 56a6 <wait>
  if(xstatus != -1 && xstatus != 2)
    4088:	fbc42783          	lw	a5,-68(s0)
    408c:	577d                	li	a4,-1
    408e:	00e78563          	beq	a5,a4,4098 <sbrkfail+0x116>
    4092:	4709                	li	a4,2
    4094:	08e79d63          	bne	a5,a4,412e <sbrkfail+0x1ac>
}
    4098:	70e6                	ld	ra,120(sp)
    409a:	7446                	ld	s0,112(sp)
    409c:	74a6                	ld	s1,104(sp)
    409e:	7906                	ld	s2,96(sp)
    40a0:	69e6                	ld	s3,88(sp)
    40a2:	6a46                	ld	s4,80(sp)
    40a4:	6aa6                	ld	s5,72(sp)
    40a6:	6109                	addi	sp,sp,128
    40a8:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    40aa:	85d6                	mv	a1,s5
    40ac:	00004517          	auipc	a0,0x4
    40b0:	91c50513          	addi	a0,a0,-1764 # 79c8 <malloc+0x1edc>
    40b4:	00002097          	auipc	ra,0x2
    40b8:	97a080e7          	jalr	-1670(ra) # 5a2e <printf>
    exit(1);
    40bc:	4505                	li	a0,1
    40be:	00001097          	auipc	ra,0x1
    40c2:	5e0080e7          	jalr	1504(ra) # 569e <exit>
    printf("%s: fork failed\n", s);
    40c6:	85d6                	mv	a1,s5
    40c8:	00002517          	auipc	a0,0x2
    40cc:	69850513          	addi	a0,a0,1688 # 6760 <malloc+0xc74>
    40d0:	00002097          	auipc	ra,0x2
    40d4:	95e080e7          	jalr	-1698(ra) # 5a2e <printf>
    exit(1);
    40d8:	4505                	li	a0,1
    40da:	00001097          	auipc	ra,0x1
    40de:	5c4080e7          	jalr	1476(ra) # 569e <exit>
    a = sbrk(0);
    40e2:	4501                	li	a0,0
    40e4:	00001097          	auipc	ra,0x1
    40e8:	642080e7          	jalr	1602(ra) # 5726 <sbrk>
    40ec:	892a                	mv	s2,a0
    sbrk(10*BIG);
    40ee:	3e800537          	lui	a0,0x3e800
    40f2:	00001097          	auipc	ra,0x1
    40f6:	634080e7          	jalr	1588(ra) # 5726 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    40fa:	87ca                	mv	a5,s2
    40fc:	3e800737          	lui	a4,0x3e800
    4100:	993a                	add	s2,s2,a4
    4102:	6705                	lui	a4,0x1
      n += *(a+i);
    4104:	0007c683          	lbu	a3,0(a5) # 6400000 <__BSS_END__+0x63f14a0>
    4108:	9cb5                	addw	s1,s1,a3
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    410a:	97ba                	add	a5,a5,a4
    410c:	ff279ce3          	bne	a5,s2,4104 <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    4110:	8626                	mv	a2,s1
    4112:	85d6                	mv	a1,s5
    4114:	00004517          	auipc	a0,0x4
    4118:	8d450513          	addi	a0,a0,-1836 # 79e8 <malloc+0x1efc>
    411c:	00002097          	auipc	ra,0x2
    4120:	912080e7          	jalr	-1774(ra) # 5a2e <printf>
    exit(1);
    4124:	4505                	li	a0,1
    4126:	00001097          	auipc	ra,0x1
    412a:	578080e7          	jalr	1400(ra) # 569e <exit>
    exit(1);
    412e:	4505                	li	a0,1
    4130:	00001097          	auipc	ra,0x1
    4134:	56e080e7          	jalr	1390(ra) # 569e <exit>

0000000000004138 <mem>:
{
    4138:	7139                	addi	sp,sp,-64
    413a:	fc06                	sd	ra,56(sp)
    413c:	f822                	sd	s0,48(sp)
    413e:	f426                	sd	s1,40(sp)
    4140:	f04a                	sd	s2,32(sp)
    4142:	ec4e                	sd	s3,24(sp)
    4144:	0080                	addi	s0,sp,64
    4146:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    4148:	00001097          	auipc	ra,0x1
    414c:	54e080e7          	jalr	1358(ra) # 5696 <fork>
    m1 = 0;
    4150:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    4152:	6909                	lui	s2,0x2
    4154:	71190913          	addi	s2,s2,1809 # 2711 <sbrkbasic+0x159>
  if((pid = fork()) == 0){
    4158:	c115                	beqz	a0,417c <mem+0x44>
    wait(&xstatus);
    415a:	fcc40513          	addi	a0,s0,-52
    415e:	00001097          	auipc	ra,0x1
    4162:	548080e7          	jalr	1352(ra) # 56a6 <wait>
    if(xstatus == -1){
    4166:	fcc42503          	lw	a0,-52(s0)
    416a:	57fd                	li	a5,-1
    416c:	06f50363          	beq	a0,a5,41d2 <mem+0x9a>
    exit(xstatus);
    4170:	00001097          	auipc	ra,0x1
    4174:	52e080e7          	jalr	1326(ra) # 569e <exit>
      *(char**)m2 = m1;
    4178:	e104                	sd	s1,0(a0)
      m1 = m2;
    417a:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    417c:	854a                	mv	a0,s2
    417e:	00002097          	auipc	ra,0x2
    4182:	96e080e7          	jalr	-1682(ra) # 5aec <malloc>
    4186:	f96d                	bnez	a0,4178 <mem+0x40>
    while(m1){
    4188:	c881                	beqz	s1,4198 <mem+0x60>
      m2 = *(char**)m1;
    418a:	8526                	mv	a0,s1
    418c:	6084                	ld	s1,0(s1)
      free(m1);
    418e:	00002097          	auipc	ra,0x2
    4192:	8d6080e7          	jalr	-1834(ra) # 5a64 <free>
    while(m1){
    4196:	f8f5                	bnez	s1,418a <mem+0x52>
    m1 = malloc(1024*20);
    4198:	6515                	lui	a0,0x5
    419a:	00002097          	auipc	ra,0x2
    419e:	952080e7          	jalr	-1710(ra) # 5aec <malloc>
    if(m1 == 0){
    41a2:	c911                	beqz	a0,41b6 <mem+0x7e>
    free(m1);
    41a4:	00002097          	auipc	ra,0x2
    41a8:	8c0080e7          	jalr	-1856(ra) # 5a64 <free>
    exit(0);
    41ac:	4501                	li	a0,0
    41ae:	00001097          	auipc	ra,0x1
    41b2:	4f0080e7          	jalr	1264(ra) # 569e <exit>
      printf("couldn't allocate mem?!!\n", s);
    41b6:	85ce                	mv	a1,s3
    41b8:	00004517          	auipc	a0,0x4
    41bc:	86050513          	addi	a0,a0,-1952 # 7a18 <malloc+0x1f2c>
    41c0:	00002097          	auipc	ra,0x2
    41c4:	86e080e7          	jalr	-1938(ra) # 5a2e <printf>
      exit(1);
    41c8:	4505                	li	a0,1
    41ca:	00001097          	auipc	ra,0x1
    41ce:	4d4080e7          	jalr	1236(ra) # 569e <exit>
      exit(0);
    41d2:	4501                	li	a0,0
    41d4:	00001097          	auipc	ra,0x1
    41d8:	4ca080e7          	jalr	1226(ra) # 569e <exit>

00000000000041dc <sharedfd>:
{
    41dc:	7159                	addi	sp,sp,-112
    41de:	f486                	sd	ra,104(sp)
    41e0:	f0a2                	sd	s0,96(sp)
    41e2:	eca6                	sd	s1,88(sp)
    41e4:	e8ca                	sd	s2,80(sp)
    41e6:	e4ce                	sd	s3,72(sp)
    41e8:	e0d2                	sd	s4,64(sp)
    41ea:	fc56                	sd	s5,56(sp)
    41ec:	f85a                	sd	s6,48(sp)
    41ee:	f45e                	sd	s7,40(sp)
    41f0:	1880                	addi	s0,sp,112
    41f2:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    41f4:	00002517          	auipc	a0,0x2
    41f8:	b7c50513          	addi	a0,a0,-1156 # 5d70 <malloc+0x284>
    41fc:	00001097          	auipc	ra,0x1
    4200:	4f2080e7          	jalr	1266(ra) # 56ee <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    4204:	20200593          	li	a1,514
    4208:	00002517          	auipc	a0,0x2
    420c:	b6850513          	addi	a0,a0,-1176 # 5d70 <malloc+0x284>
    4210:	00001097          	auipc	ra,0x1
    4214:	4ce080e7          	jalr	1230(ra) # 56de <open>
  if(fd < 0){
    4218:	04054a63          	bltz	a0,426c <sharedfd+0x90>
    421c:	892a                	mv	s2,a0
  pid = fork();
    421e:	00001097          	auipc	ra,0x1
    4222:	478080e7          	jalr	1144(ra) # 5696 <fork>
    4226:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    4228:	06300593          	li	a1,99
    422c:	c119                	beqz	a0,4232 <sharedfd+0x56>
    422e:	07000593          	li	a1,112
    4232:	4629                	li	a2,10
    4234:	fa040513          	addi	a0,s0,-96
    4238:	00001097          	auipc	ra,0x1
    423c:	26a080e7          	jalr	618(ra) # 54a2 <memset>
    4240:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    4244:	4629                	li	a2,10
    4246:	fa040593          	addi	a1,s0,-96
    424a:	854a                	mv	a0,s2
    424c:	00001097          	auipc	ra,0x1
    4250:	472080e7          	jalr	1138(ra) # 56be <write>
    4254:	47a9                	li	a5,10
    4256:	02f51963          	bne	a0,a5,4288 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    425a:	34fd                	addiw	s1,s1,-1
    425c:	f4e5                	bnez	s1,4244 <sharedfd+0x68>
  if(pid == 0) {
    425e:	04099363          	bnez	s3,42a4 <sharedfd+0xc8>
    exit(0);
    4262:	4501                	li	a0,0
    4264:	00001097          	auipc	ra,0x1
    4268:	43a080e7          	jalr	1082(ra) # 569e <exit>
    printf("%s: cannot open sharedfd for writing", s);
    426c:	85d2                	mv	a1,s4
    426e:	00003517          	auipc	a0,0x3
    4272:	7ca50513          	addi	a0,a0,1994 # 7a38 <malloc+0x1f4c>
    4276:	00001097          	auipc	ra,0x1
    427a:	7b8080e7          	jalr	1976(ra) # 5a2e <printf>
    exit(1);
    427e:	4505                	li	a0,1
    4280:	00001097          	auipc	ra,0x1
    4284:	41e080e7          	jalr	1054(ra) # 569e <exit>
      printf("%s: write sharedfd failed\n", s);
    4288:	85d2                	mv	a1,s4
    428a:	00003517          	auipc	a0,0x3
    428e:	7d650513          	addi	a0,a0,2006 # 7a60 <malloc+0x1f74>
    4292:	00001097          	auipc	ra,0x1
    4296:	79c080e7          	jalr	1948(ra) # 5a2e <printf>
      exit(1);
    429a:	4505                	li	a0,1
    429c:	00001097          	auipc	ra,0x1
    42a0:	402080e7          	jalr	1026(ra) # 569e <exit>
    wait(&xstatus);
    42a4:	f9c40513          	addi	a0,s0,-100
    42a8:	00001097          	auipc	ra,0x1
    42ac:	3fe080e7          	jalr	1022(ra) # 56a6 <wait>
    if(xstatus != 0)
    42b0:	f9c42983          	lw	s3,-100(s0)
    42b4:	00098763          	beqz	s3,42c2 <sharedfd+0xe6>
      exit(xstatus);
    42b8:	854e                	mv	a0,s3
    42ba:	00001097          	auipc	ra,0x1
    42be:	3e4080e7          	jalr	996(ra) # 569e <exit>
  close(fd);
    42c2:	854a                	mv	a0,s2
    42c4:	00001097          	auipc	ra,0x1
    42c8:	402080e7          	jalr	1026(ra) # 56c6 <close>
  fd = open("sharedfd", 0);
    42cc:	4581                	li	a1,0
    42ce:	00002517          	auipc	a0,0x2
    42d2:	aa250513          	addi	a0,a0,-1374 # 5d70 <malloc+0x284>
    42d6:	00001097          	auipc	ra,0x1
    42da:	408080e7          	jalr	1032(ra) # 56de <open>
    42de:	8baa                	mv	s7,a0
  nc = np = 0;
    42e0:	8ace                	mv	s5,s3
  if(fd < 0){
    42e2:	02054563          	bltz	a0,430c <sharedfd+0x130>
    42e6:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    42ea:	06300493          	li	s1,99
      if(buf[i] == 'p')
    42ee:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    42f2:	4629                	li	a2,10
    42f4:	fa040593          	addi	a1,s0,-96
    42f8:	855e                	mv	a0,s7
    42fa:	00001097          	auipc	ra,0x1
    42fe:	3bc080e7          	jalr	956(ra) # 56b6 <read>
    4302:	02a05f63          	blez	a0,4340 <sharedfd+0x164>
    4306:	fa040793          	addi	a5,s0,-96
    430a:	a01d                	j	4330 <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    430c:	85d2                	mv	a1,s4
    430e:	00003517          	auipc	a0,0x3
    4312:	77250513          	addi	a0,a0,1906 # 7a80 <malloc+0x1f94>
    4316:	00001097          	auipc	ra,0x1
    431a:	718080e7          	jalr	1816(ra) # 5a2e <printf>
    exit(1);
    431e:	4505                	li	a0,1
    4320:	00001097          	auipc	ra,0x1
    4324:	37e080e7          	jalr	894(ra) # 569e <exit>
        nc++;
    4328:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    432a:	0785                	addi	a5,a5,1
    432c:	fd2783e3          	beq	a5,s2,42f2 <sharedfd+0x116>
      if(buf[i] == 'c')
    4330:	0007c703          	lbu	a4,0(a5)
    4334:	fe970ae3          	beq	a4,s1,4328 <sharedfd+0x14c>
      if(buf[i] == 'p')
    4338:	ff6719e3          	bne	a4,s6,432a <sharedfd+0x14e>
        np++;
    433c:	2a85                	addiw	s5,s5,1
    433e:	b7f5                	j	432a <sharedfd+0x14e>
  close(fd);
    4340:	855e                	mv	a0,s7
    4342:	00001097          	auipc	ra,0x1
    4346:	384080e7          	jalr	900(ra) # 56c6 <close>
  unlink("sharedfd");
    434a:	00002517          	auipc	a0,0x2
    434e:	a2650513          	addi	a0,a0,-1498 # 5d70 <malloc+0x284>
    4352:	00001097          	auipc	ra,0x1
    4356:	39c080e7          	jalr	924(ra) # 56ee <unlink>
  if(nc == N*SZ && np == N*SZ){
    435a:	6789                	lui	a5,0x2
    435c:	71078793          	addi	a5,a5,1808 # 2710 <sbrkbasic+0x158>
    4360:	00f99763          	bne	s3,a5,436e <sharedfd+0x192>
    4364:	6789                	lui	a5,0x2
    4366:	71078793          	addi	a5,a5,1808 # 2710 <sbrkbasic+0x158>
    436a:	02fa8063          	beq	s5,a5,438a <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    436e:	85d2                	mv	a1,s4
    4370:	00003517          	auipc	a0,0x3
    4374:	73850513          	addi	a0,a0,1848 # 7aa8 <malloc+0x1fbc>
    4378:	00001097          	auipc	ra,0x1
    437c:	6b6080e7          	jalr	1718(ra) # 5a2e <printf>
    exit(1);
    4380:	4505                	li	a0,1
    4382:	00001097          	auipc	ra,0x1
    4386:	31c080e7          	jalr	796(ra) # 569e <exit>
    exit(0);
    438a:	4501                	li	a0,0
    438c:	00001097          	auipc	ra,0x1
    4390:	312080e7          	jalr	786(ra) # 569e <exit>

0000000000004394 <fourfiles>:
{
    4394:	7171                	addi	sp,sp,-176
    4396:	f506                	sd	ra,168(sp)
    4398:	f122                	sd	s0,160(sp)
    439a:	ed26                	sd	s1,152(sp)
    439c:	e94a                	sd	s2,144(sp)
    439e:	e54e                	sd	s3,136(sp)
    43a0:	e152                	sd	s4,128(sp)
    43a2:	fcd6                	sd	s5,120(sp)
    43a4:	f8da                	sd	s6,112(sp)
    43a6:	f4de                	sd	s7,104(sp)
    43a8:	f0e2                	sd	s8,96(sp)
    43aa:	ece6                	sd	s9,88(sp)
    43ac:	e8ea                	sd	s10,80(sp)
    43ae:	e4ee                	sd	s11,72(sp)
    43b0:	1900                	addi	s0,sp,176
    43b2:	f4a43c23          	sd	a0,-168(s0)
  char *names[] = { "f0", "f1", "f2", "f3" };
    43b6:	00002797          	auipc	a5,0x2
    43ba:	82278793          	addi	a5,a5,-2014 # 5bd8 <malloc+0xec>
    43be:	f6f43823          	sd	a5,-144(s0)
    43c2:	00002797          	auipc	a5,0x2
    43c6:	81e78793          	addi	a5,a5,-2018 # 5be0 <malloc+0xf4>
    43ca:	f6f43c23          	sd	a5,-136(s0)
    43ce:	00002797          	auipc	a5,0x2
    43d2:	81a78793          	addi	a5,a5,-2022 # 5be8 <malloc+0xfc>
    43d6:	f8f43023          	sd	a5,-128(s0)
    43da:	00002797          	auipc	a5,0x2
    43de:	81678793          	addi	a5,a5,-2026 # 5bf0 <malloc+0x104>
    43e2:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    43e6:	f7040c13          	addi	s8,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    43ea:	8962                	mv	s2,s8
  for(pi = 0; pi < NCHILD; pi++){
    43ec:	4481                	li	s1,0
    43ee:	4a11                	li	s4,4
    fname = names[pi];
    43f0:	00093983          	ld	s3,0(s2)
    unlink(fname);
    43f4:	854e                	mv	a0,s3
    43f6:	00001097          	auipc	ra,0x1
    43fa:	2f8080e7          	jalr	760(ra) # 56ee <unlink>
    pid = fork();
    43fe:	00001097          	auipc	ra,0x1
    4402:	298080e7          	jalr	664(ra) # 5696 <fork>
    if(pid < 0){
    4406:	04054463          	bltz	a0,444e <fourfiles+0xba>
    if(pid == 0){
    440a:	c12d                	beqz	a0,446c <fourfiles+0xd8>
  for(pi = 0; pi < NCHILD; pi++){
    440c:	2485                	addiw	s1,s1,1
    440e:	0921                	addi	s2,s2,8
    4410:	ff4490e3          	bne	s1,s4,43f0 <fourfiles+0x5c>
    4414:	4491                	li	s1,4
    wait(&xstatus);
    4416:	f6c40513          	addi	a0,s0,-148
    441a:	00001097          	auipc	ra,0x1
    441e:	28c080e7          	jalr	652(ra) # 56a6 <wait>
    if(xstatus != 0)
    4422:	f6c42b03          	lw	s6,-148(s0)
    4426:	0c0b1e63          	bnez	s6,4502 <fourfiles+0x16e>
  for(pi = 0; pi < NCHILD; pi++){
    442a:	34fd                	addiw	s1,s1,-1
    442c:	f4ed                	bnez	s1,4416 <fourfiles+0x82>
    442e:	03000b93          	li	s7,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4432:	00007a17          	auipc	s4,0x7
    4436:	71ea0a13          	addi	s4,s4,1822 # bb50 <buf>
    443a:	00007a97          	auipc	s5,0x7
    443e:	717a8a93          	addi	s5,s5,1815 # bb51 <buf+0x1>
    if(total != N*SZ){
    4442:	6d85                	lui	s11,0x1
    4444:	770d8d93          	addi	s11,s11,1904 # 1770 <pipe1+0x32>
  for(i = 0; i < NCHILD; i++){
    4448:	03400d13          	li	s10,52
    444c:	aa1d                	j	4582 <fourfiles+0x1ee>
      printf("fork failed\n", s);
    444e:	f5843583          	ld	a1,-168(s0)
    4452:	00002517          	auipc	a0,0x2
    4456:	71650513          	addi	a0,a0,1814 # 6b68 <malloc+0x107c>
    445a:	00001097          	auipc	ra,0x1
    445e:	5d4080e7          	jalr	1492(ra) # 5a2e <printf>
      exit(1);
    4462:	4505                	li	a0,1
    4464:	00001097          	auipc	ra,0x1
    4468:	23a080e7          	jalr	570(ra) # 569e <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    446c:	20200593          	li	a1,514
    4470:	854e                	mv	a0,s3
    4472:	00001097          	auipc	ra,0x1
    4476:	26c080e7          	jalr	620(ra) # 56de <open>
    447a:	892a                	mv	s2,a0
      if(fd < 0){
    447c:	04054763          	bltz	a0,44ca <fourfiles+0x136>
      memset(buf, '0'+pi, SZ);
    4480:	1f400613          	li	a2,500
    4484:	0304859b          	addiw	a1,s1,48
    4488:	00007517          	auipc	a0,0x7
    448c:	6c850513          	addi	a0,a0,1736 # bb50 <buf>
    4490:	00001097          	auipc	ra,0x1
    4494:	012080e7          	jalr	18(ra) # 54a2 <memset>
    4498:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    449a:	00007997          	auipc	s3,0x7
    449e:	6b698993          	addi	s3,s3,1718 # bb50 <buf>
    44a2:	1f400613          	li	a2,500
    44a6:	85ce                	mv	a1,s3
    44a8:	854a                	mv	a0,s2
    44aa:	00001097          	auipc	ra,0x1
    44ae:	214080e7          	jalr	532(ra) # 56be <write>
    44b2:	85aa                	mv	a1,a0
    44b4:	1f400793          	li	a5,500
    44b8:	02f51863          	bne	a0,a5,44e8 <fourfiles+0x154>
      for(i = 0; i < N; i++){
    44bc:	34fd                	addiw	s1,s1,-1
    44be:	f0f5                	bnez	s1,44a2 <fourfiles+0x10e>
      exit(0);
    44c0:	4501                	li	a0,0
    44c2:	00001097          	auipc	ra,0x1
    44c6:	1dc080e7          	jalr	476(ra) # 569e <exit>
        printf("create failed\n", s);
    44ca:	f5843583          	ld	a1,-168(s0)
    44ce:	00003517          	auipc	a0,0x3
    44d2:	5f250513          	addi	a0,a0,1522 # 7ac0 <malloc+0x1fd4>
    44d6:	00001097          	auipc	ra,0x1
    44da:	558080e7          	jalr	1368(ra) # 5a2e <printf>
        exit(1);
    44de:	4505                	li	a0,1
    44e0:	00001097          	auipc	ra,0x1
    44e4:	1be080e7          	jalr	446(ra) # 569e <exit>
          printf("write failed %d\n", n);
    44e8:	00003517          	auipc	a0,0x3
    44ec:	5e850513          	addi	a0,a0,1512 # 7ad0 <malloc+0x1fe4>
    44f0:	00001097          	auipc	ra,0x1
    44f4:	53e080e7          	jalr	1342(ra) # 5a2e <printf>
          exit(1);
    44f8:	4505                	li	a0,1
    44fa:	00001097          	auipc	ra,0x1
    44fe:	1a4080e7          	jalr	420(ra) # 569e <exit>
      exit(xstatus);
    4502:	855a                	mv	a0,s6
    4504:	00001097          	auipc	ra,0x1
    4508:	19a080e7          	jalr	410(ra) # 569e <exit>
          printf("wrong char\n", s);
    450c:	f5843583          	ld	a1,-168(s0)
    4510:	00003517          	auipc	a0,0x3
    4514:	5d850513          	addi	a0,a0,1496 # 7ae8 <malloc+0x1ffc>
    4518:	00001097          	auipc	ra,0x1
    451c:	516080e7          	jalr	1302(ra) # 5a2e <printf>
          exit(1);
    4520:	4505                	li	a0,1
    4522:	00001097          	auipc	ra,0x1
    4526:	17c080e7          	jalr	380(ra) # 569e <exit>
      total += n;
    452a:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    452e:	660d                	lui	a2,0x3
    4530:	85d2                	mv	a1,s4
    4532:	854e                	mv	a0,s3
    4534:	00001097          	auipc	ra,0x1
    4538:	182080e7          	jalr	386(ra) # 56b6 <read>
    453c:	02a05363          	blez	a0,4562 <fourfiles+0x1ce>
    4540:	00007797          	auipc	a5,0x7
    4544:	61078793          	addi	a5,a5,1552 # bb50 <buf>
    4548:	fff5069b          	addiw	a3,a0,-1
    454c:	1682                	slli	a3,a3,0x20
    454e:	9281                	srli	a3,a3,0x20
    4550:	96d6                	add	a3,a3,s5
        if(buf[j] != '0'+i){
    4552:	0007c703          	lbu	a4,0(a5)
    4556:	fa971be3          	bne	a4,s1,450c <fourfiles+0x178>
      for(j = 0; j < n; j++){
    455a:	0785                	addi	a5,a5,1
    455c:	fed79be3          	bne	a5,a3,4552 <fourfiles+0x1be>
    4560:	b7e9                	j	452a <fourfiles+0x196>
    close(fd);
    4562:	854e                	mv	a0,s3
    4564:	00001097          	auipc	ra,0x1
    4568:	162080e7          	jalr	354(ra) # 56c6 <close>
    if(total != N*SZ){
    456c:	03b91863          	bne	s2,s11,459c <fourfiles+0x208>
    unlink(fname);
    4570:	8566                	mv	a0,s9
    4572:	00001097          	auipc	ra,0x1
    4576:	17c080e7          	jalr	380(ra) # 56ee <unlink>
  for(i = 0; i < NCHILD; i++){
    457a:	0c21                	addi	s8,s8,8
    457c:	2b85                	addiw	s7,s7,1
    457e:	03ab8d63          	beq	s7,s10,45b8 <fourfiles+0x224>
    fname = names[i];
    4582:	000c3c83          	ld	s9,0(s8)
    fd = open(fname, 0);
    4586:	4581                	li	a1,0
    4588:	8566                	mv	a0,s9
    458a:	00001097          	auipc	ra,0x1
    458e:	154080e7          	jalr	340(ra) # 56de <open>
    4592:	89aa                	mv	s3,a0
    total = 0;
    4594:	895a                	mv	s2,s6
        if(buf[j] != '0'+i){
    4596:	000b849b          	sext.w	s1,s7
    while((n = read(fd, buf, sizeof(buf))) > 0){
    459a:	bf51                	j	452e <fourfiles+0x19a>
      printf("wrong length %d\n", total);
    459c:	85ca                	mv	a1,s2
    459e:	00003517          	auipc	a0,0x3
    45a2:	55a50513          	addi	a0,a0,1370 # 7af8 <malloc+0x200c>
    45a6:	00001097          	auipc	ra,0x1
    45aa:	488080e7          	jalr	1160(ra) # 5a2e <printf>
      exit(1);
    45ae:	4505                	li	a0,1
    45b0:	00001097          	auipc	ra,0x1
    45b4:	0ee080e7          	jalr	238(ra) # 569e <exit>
}
    45b8:	70aa                	ld	ra,168(sp)
    45ba:	740a                	ld	s0,160(sp)
    45bc:	64ea                	ld	s1,152(sp)
    45be:	694a                	ld	s2,144(sp)
    45c0:	69aa                	ld	s3,136(sp)
    45c2:	6a0a                	ld	s4,128(sp)
    45c4:	7ae6                	ld	s5,120(sp)
    45c6:	7b46                	ld	s6,112(sp)
    45c8:	7ba6                	ld	s7,104(sp)
    45ca:	7c06                	ld	s8,96(sp)
    45cc:	6ce6                	ld	s9,88(sp)
    45ce:	6d46                	ld	s10,80(sp)
    45d0:	6da6                	ld	s11,72(sp)
    45d2:	614d                	addi	sp,sp,176
    45d4:	8082                	ret

00000000000045d6 <concreate>:
{
    45d6:	7135                	addi	sp,sp,-160
    45d8:	ed06                	sd	ra,152(sp)
    45da:	e922                	sd	s0,144(sp)
    45dc:	e526                	sd	s1,136(sp)
    45de:	e14a                	sd	s2,128(sp)
    45e0:	fcce                	sd	s3,120(sp)
    45e2:	f8d2                	sd	s4,112(sp)
    45e4:	f4d6                	sd	s5,104(sp)
    45e6:	f0da                	sd	s6,96(sp)
    45e8:	ecde                	sd	s7,88(sp)
    45ea:	1100                	addi	s0,sp,160
    45ec:	89aa                	mv	s3,a0
  file[0] = 'C';
    45ee:	04300793          	li	a5,67
    45f2:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    45f6:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    45fa:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    45fc:	4b0d                	li	s6,3
    45fe:	4a85                	li	s5,1
      link("C0", file);
    4600:	00003b97          	auipc	s7,0x3
    4604:	510b8b93          	addi	s7,s7,1296 # 7b10 <malloc+0x2024>
  for(i = 0; i < N; i++){
    4608:	02800a13          	li	s4,40
    460c:	acc1                	j	48dc <concreate+0x306>
      link("C0", file);
    460e:	fa840593          	addi	a1,s0,-88
    4612:	855e                	mv	a0,s7
    4614:	00001097          	auipc	ra,0x1
    4618:	0ea080e7          	jalr	234(ra) # 56fe <link>
    if(pid == 0) {
    461c:	a45d                	j	48c2 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    461e:	4795                	li	a5,5
    4620:	02f9693b          	remw	s2,s2,a5
    4624:	4785                	li	a5,1
    4626:	02f90b63          	beq	s2,a5,465c <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    462a:	20200593          	li	a1,514
    462e:	fa840513          	addi	a0,s0,-88
    4632:	00001097          	auipc	ra,0x1
    4636:	0ac080e7          	jalr	172(ra) # 56de <open>
      if(fd < 0){
    463a:	26055b63          	bgez	a0,48b0 <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    463e:	fa840593          	addi	a1,s0,-88
    4642:	00003517          	auipc	a0,0x3
    4646:	4d650513          	addi	a0,a0,1238 # 7b18 <malloc+0x202c>
    464a:	00001097          	auipc	ra,0x1
    464e:	3e4080e7          	jalr	996(ra) # 5a2e <printf>
        exit(1);
    4652:	4505                	li	a0,1
    4654:	00001097          	auipc	ra,0x1
    4658:	04a080e7          	jalr	74(ra) # 569e <exit>
      link("C0", file);
    465c:	fa840593          	addi	a1,s0,-88
    4660:	00003517          	auipc	a0,0x3
    4664:	4b050513          	addi	a0,a0,1200 # 7b10 <malloc+0x2024>
    4668:	00001097          	auipc	ra,0x1
    466c:	096080e7          	jalr	150(ra) # 56fe <link>
      exit(0);
    4670:	4501                	li	a0,0
    4672:	00001097          	auipc	ra,0x1
    4676:	02c080e7          	jalr	44(ra) # 569e <exit>
        exit(1);
    467a:	4505                	li	a0,1
    467c:	00001097          	auipc	ra,0x1
    4680:	022080e7          	jalr	34(ra) # 569e <exit>
  memset(fa, 0, sizeof(fa));
    4684:	02800613          	li	a2,40
    4688:	4581                	li	a1,0
    468a:	f8040513          	addi	a0,s0,-128
    468e:	00001097          	auipc	ra,0x1
    4692:	e14080e7          	jalr	-492(ra) # 54a2 <memset>
  fd = open(".", 0);
    4696:	4581                	li	a1,0
    4698:	00002517          	auipc	a0,0x2
    469c:	f2850513          	addi	a0,a0,-216 # 65c0 <malloc+0xad4>
    46a0:	00001097          	auipc	ra,0x1
    46a4:	03e080e7          	jalr	62(ra) # 56de <open>
    46a8:	892a                	mv	s2,a0
  n = 0;
    46aa:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    46ac:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    46b0:	02700b13          	li	s6,39
      fa[i] = 1;
    46b4:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    46b6:	4641                	li	a2,16
    46b8:	f7040593          	addi	a1,s0,-144
    46bc:	854a                	mv	a0,s2
    46be:	00001097          	auipc	ra,0x1
    46c2:	ff8080e7          	jalr	-8(ra) # 56b6 <read>
    46c6:	08a05163          	blez	a0,4748 <concreate+0x172>
    if(de.inum == 0)
    46ca:	f7045783          	lhu	a5,-144(s0)
    46ce:	d7e5                	beqz	a5,46b6 <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    46d0:	f7244783          	lbu	a5,-142(s0)
    46d4:	ff4791e3          	bne	a5,s4,46b6 <concreate+0xe0>
    46d8:	f7444783          	lbu	a5,-140(s0)
    46dc:	ffe9                	bnez	a5,46b6 <concreate+0xe0>
      i = de.name[1] - '0';
    46de:	f7344783          	lbu	a5,-141(s0)
    46e2:	fd07879b          	addiw	a5,a5,-48
    46e6:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    46ea:	00eb6f63          	bltu	s6,a4,4708 <concreate+0x132>
      if(fa[i]){
    46ee:	fb040793          	addi	a5,s0,-80
    46f2:	97ba                	add	a5,a5,a4
    46f4:	fd07c783          	lbu	a5,-48(a5)
    46f8:	eb85                	bnez	a5,4728 <concreate+0x152>
      fa[i] = 1;
    46fa:	fb040793          	addi	a5,s0,-80
    46fe:	973e                	add	a4,a4,a5
    4700:	fd770823          	sb	s7,-48(a4) # fd0 <bigdir+0x6e>
      n++;
    4704:	2a85                	addiw	s5,s5,1
    4706:	bf45                	j	46b6 <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    4708:	f7240613          	addi	a2,s0,-142
    470c:	85ce                	mv	a1,s3
    470e:	00003517          	auipc	a0,0x3
    4712:	42a50513          	addi	a0,a0,1066 # 7b38 <malloc+0x204c>
    4716:	00001097          	auipc	ra,0x1
    471a:	318080e7          	jalr	792(ra) # 5a2e <printf>
        exit(1);
    471e:	4505                	li	a0,1
    4720:	00001097          	auipc	ra,0x1
    4724:	f7e080e7          	jalr	-130(ra) # 569e <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    4728:	f7240613          	addi	a2,s0,-142
    472c:	85ce                	mv	a1,s3
    472e:	00003517          	auipc	a0,0x3
    4732:	42a50513          	addi	a0,a0,1066 # 7b58 <malloc+0x206c>
    4736:	00001097          	auipc	ra,0x1
    473a:	2f8080e7          	jalr	760(ra) # 5a2e <printf>
        exit(1);
    473e:	4505                	li	a0,1
    4740:	00001097          	auipc	ra,0x1
    4744:	f5e080e7          	jalr	-162(ra) # 569e <exit>
  close(fd);
    4748:	854a                	mv	a0,s2
    474a:	00001097          	auipc	ra,0x1
    474e:	f7c080e7          	jalr	-132(ra) # 56c6 <close>
  if(n != N){
    4752:	02800793          	li	a5,40
    4756:	00fa9763          	bne	s5,a5,4764 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    475a:	4a8d                	li	s5,3
    475c:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    475e:	02800a13          	li	s4,40
    4762:	a8c9                	j	4834 <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    4764:	85ce                	mv	a1,s3
    4766:	00003517          	auipc	a0,0x3
    476a:	41a50513          	addi	a0,a0,1050 # 7b80 <malloc+0x2094>
    476e:	00001097          	auipc	ra,0x1
    4772:	2c0080e7          	jalr	704(ra) # 5a2e <printf>
    exit(1);
    4776:	4505                	li	a0,1
    4778:	00001097          	auipc	ra,0x1
    477c:	f26080e7          	jalr	-218(ra) # 569e <exit>
      printf("%s: fork failed\n", s);
    4780:	85ce                	mv	a1,s3
    4782:	00002517          	auipc	a0,0x2
    4786:	fde50513          	addi	a0,a0,-34 # 6760 <malloc+0xc74>
    478a:	00001097          	auipc	ra,0x1
    478e:	2a4080e7          	jalr	676(ra) # 5a2e <printf>
      exit(1);
    4792:	4505                	li	a0,1
    4794:	00001097          	auipc	ra,0x1
    4798:	f0a080e7          	jalr	-246(ra) # 569e <exit>
      close(open(file, 0));
    479c:	4581                	li	a1,0
    479e:	fa840513          	addi	a0,s0,-88
    47a2:	00001097          	auipc	ra,0x1
    47a6:	f3c080e7          	jalr	-196(ra) # 56de <open>
    47aa:	00001097          	auipc	ra,0x1
    47ae:	f1c080e7          	jalr	-228(ra) # 56c6 <close>
      close(open(file, 0));
    47b2:	4581                	li	a1,0
    47b4:	fa840513          	addi	a0,s0,-88
    47b8:	00001097          	auipc	ra,0x1
    47bc:	f26080e7          	jalr	-218(ra) # 56de <open>
    47c0:	00001097          	auipc	ra,0x1
    47c4:	f06080e7          	jalr	-250(ra) # 56c6 <close>
      close(open(file, 0));
    47c8:	4581                	li	a1,0
    47ca:	fa840513          	addi	a0,s0,-88
    47ce:	00001097          	auipc	ra,0x1
    47d2:	f10080e7          	jalr	-240(ra) # 56de <open>
    47d6:	00001097          	auipc	ra,0x1
    47da:	ef0080e7          	jalr	-272(ra) # 56c6 <close>
      close(open(file, 0));
    47de:	4581                	li	a1,0
    47e0:	fa840513          	addi	a0,s0,-88
    47e4:	00001097          	auipc	ra,0x1
    47e8:	efa080e7          	jalr	-262(ra) # 56de <open>
    47ec:	00001097          	auipc	ra,0x1
    47f0:	eda080e7          	jalr	-294(ra) # 56c6 <close>
      close(open(file, 0));
    47f4:	4581                	li	a1,0
    47f6:	fa840513          	addi	a0,s0,-88
    47fa:	00001097          	auipc	ra,0x1
    47fe:	ee4080e7          	jalr	-284(ra) # 56de <open>
    4802:	00001097          	auipc	ra,0x1
    4806:	ec4080e7          	jalr	-316(ra) # 56c6 <close>
      close(open(file, 0));
    480a:	4581                	li	a1,0
    480c:	fa840513          	addi	a0,s0,-88
    4810:	00001097          	auipc	ra,0x1
    4814:	ece080e7          	jalr	-306(ra) # 56de <open>
    4818:	00001097          	auipc	ra,0x1
    481c:	eae080e7          	jalr	-338(ra) # 56c6 <close>
    if(pid == 0)
    4820:	08090363          	beqz	s2,48a6 <concreate+0x2d0>
      wait(0);
    4824:	4501                	li	a0,0
    4826:	00001097          	auipc	ra,0x1
    482a:	e80080e7          	jalr	-384(ra) # 56a6 <wait>
  for(i = 0; i < N; i++){
    482e:	2485                	addiw	s1,s1,1
    4830:	0f448563          	beq	s1,s4,491a <concreate+0x344>
    file[1] = '0' + i;
    4834:	0304879b          	addiw	a5,s1,48
    4838:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    483c:	00001097          	auipc	ra,0x1
    4840:	e5a080e7          	jalr	-422(ra) # 5696 <fork>
    4844:	892a                	mv	s2,a0
    if(pid < 0){
    4846:	f2054de3          	bltz	a0,4780 <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    484a:	0354e73b          	remw	a4,s1,s5
    484e:	00a767b3          	or	a5,a4,a0
    4852:	2781                	sext.w	a5,a5
    4854:	d7a1                	beqz	a5,479c <concreate+0x1c6>
    4856:	01671363          	bne	a4,s6,485c <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    485a:	f129                	bnez	a0,479c <concreate+0x1c6>
      unlink(file);
    485c:	fa840513          	addi	a0,s0,-88
    4860:	00001097          	auipc	ra,0x1
    4864:	e8e080e7          	jalr	-370(ra) # 56ee <unlink>
      unlink(file);
    4868:	fa840513          	addi	a0,s0,-88
    486c:	00001097          	auipc	ra,0x1
    4870:	e82080e7          	jalr	-382(ra) # 56ee <unlink>
      unlink(file);
    4874:	fa840513          	addi	a0,s0,-88
    4878:	00001097          	auipc	ra,0x1
    487c:	e76080e7          	jalr	-394(ra) # 56ee <unlink>
      unlink(file);
    4880:	fa840513          	addi	a0,s0,-88
    4884:	00001097          	auipc	ra,0x1
    4888:	e6a080e7          	jalr	-406(ra) # 56ee <unlink>
      unlink(file);
    488c:	fa840513          	addi	a0,s0,-88
    4890:	00001097          	auipc	ra,0x1
    4894:	e5e080e7          	jalr	-418(ra) # 56ee <unlink>
      unlink(file);
    4898:	fa840513          	addi	a0,s0,-88
    489c:	00001097          	auipc	ra,0x1
    48a0:	e52080e7          	jalr	-430(ra) # 56ee <unlink>
    48a4:	bfb5                	j	4820 <concreate+0x24a>
      exit(0);
    48a6:	4501                	li	a0,0
    48a8:	00001097          	auipc	ra,0x1
    48ac:	df6080e7          	jalr	-522(ra) # 569e <exit>
      close(fd);
    48b0:	00001097          	auipc	ra,0x1
    48b4:	e16080e7          	jalr	-490(ra) # 56c6 <close>
    if(pid == 0) {
    48b8:	bb65                	j	4670 <concreate+0x9a>
      close(fd);
    48ba:	00001097          	auipc	ra,0x1
    48be:	e0c080e7          	jalr	-500(ra) # 56c6 <close>
      wait(&xstatus);
    48c2:	f6c40513          	addi	a0,s0,-148
    48c6:	00001097          	auipc	ra,0x1
    48ca:	de0080e7          	jalr	-544(ra) # 56a6 <wait>
      if(xstatus != 0)
    48ce:	f6c42483          	lw	s1,-148(s0)
    48d2:	da0494e3          	bnez	s1,467a <concreate+0xa4>
  for(i = 0; i < N; i++){
    48d6:	2905                	addiw	s2,s2,1
    48d8:	db4906e3          	beq	s2,s4,4684 <concreate+0xae>
    file[1] = '0' + i;
    48dc:	0309079b          	addiw	a5,s2,48
    48e0:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    48e4:	fa840513          	addi	a0,s0,-88
    48e8:	00001097          	auipc	ra,0x1
    48ec:	e06080e7          	jalr	-506(ra) # 56ee <unlink>
    pid = fork();
    48f0:	00001097          	auipc	ra,0x1
    48f4:	da6080e7          	jalr	-602(ra) # 5696 <fork>
    if(pid && (i % 3) == 1){
    48f8:	d20503e3          	beqz	a0,461e <concreate+0x48>
    48fc:	036967bb          	remw	a5,s2,s6
    4900:	d15787e3          	beq	a5,s5,460e <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    4904:	20200593          	li	a1,514
    4908:	fa840513          	addi	a0,s0,-88
    490c:	00001097          	auipc	ra,0x1
    4910:	dd2080e7          	jalr	-558(ra) # 56de <open>
      if(fd < 0){
    4914:	fa0553e3          	bgez	a0,48ba <concreate+0x2e4>
    4918:	b31d                	j	463e <concreate+0x68>
}
    491a:	60ea                	ld	ra,152(sp)
    491c:	644a                	ld	s0,144(sp)
    491e:	64aa                	ld	s1,136(sp)
    4920:	690a                	ld	s2,128(sp)
    4922:	79e6                	ld	s3,120(sp)
    4924:	7a46                	ld	s4,112(sp)
    4926:	7aa6                	ld	s5,104(sp)
    4928:	7b06                	ld	s6,96(sp)
    492a:	6be6                	ld	s7,88(sp)
    492c:	610d                	addi	sp,sp,160
    492e:	8082                	ret

0000000000004930 <bigfile>:
{
    4930:	7139                	addi	sp,sp,-64
    4932:	fc06                	sd	ra,56(sp)
    4934:	f822                	sd	s0,48(sp)
    4936:	f426                	sd	s1,40(sp)
    4938:	f04a                	sd	s2,32(sp)
    493a:	ec4e                	sd	s3,24(sp)
    493c:	e852                	sd	s4,16(sp)
    493e:	e456                	sd	s5,8(sp)
    4940:	0080                	addi	s0,sp,64
    4942:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    4944:	00003517          	auipc	a0,0x3
    4948:	27450513          	addi	a0,a0,628 # 7bb8 <malloc+0x20cc>
    494c:	00001097          	auipc	ra,0x1
    4950:	da2080e7          	jalr	-606(ra) # 56ee <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    4954:	20200593          	li	a1,514
    4958:	00003517          	auipc	a0,0x3
    495c:	26050513          	addi	a0,a0,608 # 7bb8 <malloc+0x20cc>
    4960:	00001097          	auipc	ra,0x1
    4964:	d7e080e7          	jalr	-642(ra) # 56de <open>
    4968:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    496a:	4481                	li	s1,0
    memset(buf, i, SZ);
    496c:	00007917          	auipc	s2,0x7
    4970:	1e490913          	addi	s2,s2,484 # bb50 <buf>
  for(i = 0; i < N; i++){
    4974:	4a51                	li	s4,20
  if(fd < 0){
    4976:	0a054063          	bltz	a0,4a16 <bigfile+0xe6>
    memset(buf, i, SZ);
    497a:	25800613          	li	a2,600
    497e:	85a6                	mv	a1,s1
    4980:	854a                	mv	a0,s2
    4982:	00001097          	auipc	ra,0x1
    4986:	b20080e7          	jalr	-1248(ra) # 54a2 <memset>
    if(write(fd, buf, SZ) != SZ){
    498a:	25800613          	li	a2,600
    498e:	85ca                	mv	a1,s2
    4990:	854e                	mv	a0,s3
    4992:	00001097          	auipc	ra,0x1
    4996:	d2c080e7          	jalr	-724(ra) # 56be <write>
    499a:	25800793          	li	a5,600
    499e:	08f51a63          	bne	a0,a5,4a32 <bigfile+0x102>
  for(i = 0; i < N; i++){
    49a2:	2485                	addiw	s1,s1,1
    49a4:	fd449be3          	bne	s1,s4,497a <bigfile+0x4a>
  close(fd);
    49a8:	854e                	mv	a0,s3
    49aa:	00001097          	auipc	ra,0x1
    49ae:	d1c080e7          	jalr	-740(ra) # 56c6 <close>
  fd = open("bigfile.dat", 0);
    49b2:	4581                	li	a1,0
    49b4:	00003517          	auipc	a0,0x3
    49b8:	20450513          	addi	a0,a0,516 # 7bb8 <malloc+0x20cc>
    49bc:	00001097          	auipc	ra,0x1
    49c0:	d22080e7          	jalr	-734(ra) # 56de <open>
    49c4:	8a2a                	mv	s4,a0
  total = 0;
    49c6:	4981                	li	s3,0
  for(i = 0; ; i++){
    49c8:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    49ca:	00007917          	auipc	s2,0x7
    49ce:	18690913          	addi	s2,s2,390 # bb50 <buf>
  if(fd < 0){
    49d2:	06054e63          	bltz	a0,4a4e <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    49d6:	12c00613          	li	a2,300
    49da:	85ca                	mv	a1,s2
    49dc:	8552                	mv	a0,s4
    49de:	00001097          	auipc	ra,0x1
    49e2:	cd8080e7          	jalr	-808(ra) # 56b6 <read>
    if(cc < 0){
    49e6:	08054263          	bltz	a0,4a6a <bigfile+0x13a>
    if(cc == 0)
    49ea:	c971                	beqz	a0,4abe <bigfile+0x18e>
    if(cc != SZ/2){
    49ec:	12c00793          	li	a5,300
    49f0:	08f51b63          	bne	a0,a5,4a86 <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    49f4:	01f4d79b          	srliw	a5,s1,0x1f
    49f8:	9fa5                	addw	a5,a5,s1
    49fa:	4017d79b          	sraiw	a5,a5,0x1
    49fe:	00094703          	lbu	a4,0(s2)
    4a02:	0af71063          	bne	a4,a5,4aa2 <bigfile+0x172>
    4a06:	12b94703          	lbu	a4,299(s2)
    4a0a:	08f71c63          	bne	a4,a5,4aa2 <bigfile+0x172>
    total += cc;
    4a0e:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    4a12:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    4a14:	b7c9                	j	49d6 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    4a16:	85d6                	mv	a1,s5
    4a18:	00003517          	auipc	a0,0x3
    4a1c:	1b050513          	addi	a0,a0,432 # 7bc8 <malloc+0x20dc>
    4a20:	00001097          	auipc	ra,0x1
    4a24:	00e080e7          	jalr	14(ra) # 5a2e <printf>
    exit(1);
    4a28:	4505                	li	a0,1
    4a2a:	00001097          	auipc	ra,0x1
    4a2e:	c74080e7          	jalr	-908(ra) # 569e <exit>
      printf("%s: write bigfile failed\n", s);
    4a32:	85d6                	mv	a1,s5
    4a34:	00003517          	auipc	a0,0x3
    4a38:	1b450513          	addi	a0,a0,436 # 7be8 <malloc+0x20fc>
    4a3c:	00001097          	auipc	ra,0x1
    4a40:	ff2080e7          	jalr	-14(ra) # 5a2e <printf>
      exit(1);
    4a44:	4505                	li	a0,1
    4a46:	00001097          	auipc	ra,0x1
    4a4a:	c58080e7          	jalr	-936(ra) # 569e <exit>
    printf("%s: cannot open bigfile\n", s);
    4a4e:	85d6                	mv	a1,s5
    4a50:	00003517          	auipc	a0,0x3
    4a54:	1b850513          	addi	a0,a0,440 # 7c08 <malloc+0x211c>
    4a58:	00001097          	auipc	ra,0x1
    4a5c:	fd6080e7          	jalr	-42(ra) # 5a2e <printf>
    exit(1);
    4a60:	4505                	li	a0,1
    4a62:	00001097          	auipc	ra,0x1
    4a66:	c3c080e7          	jalr	-964(ra) # 569e <exit>
      printf("%s: read bigfile failed\n", s);
    4a6a:	85d6                	mv	a1,s5
    4a6c:	00003517          	auipc	a0,0x3
    4a70:	1bc50513          	addi	a0,a0,444 # 7c28 <malloc+0x213c>
    4a74:	00001097          	auipc	ra,0x1
    4a78:	fba080e7          	jalr	-70(ra) # 5a2e <printf>
      exit(1);
    4a7c:	4505                	li	a0,1
    4a7e:	00001097          	auipc	ra,0x1
    4a82:	c20080e7          	jalr	-992(ra) # 569e <exit>
      printf("%s: short read bigfile\n", s);
    4a86:	85d6                	mv	a1,s5
    4a88:	00003517          	auipc	a0,0x3
    4a8c:	1c050513          	addi	a0,a0,448 # 7c48 <malloc+0x215c>
    4a90:	00001097          	auipc	ra,0x1
    4a94:	f9e080e7          	jalr	-98(ra) # 5a2e <printf>
      exit(1);
    4a98:	4505                	li	a0,1
    4a9a:	00001097          	auipc	ra,0x1
    4a9e:	c04080e7          	jalr	-1020(ra) # 569e <exit>
      printf("%s: read bigfile wrong data\n", s);
    4aa2:	85d6                	mv	a1,s5
    4aa4:	00003517          	auipc	a0,0x3
    4aa8:	1bc50513          	addi	a0,a0,444 # 7c60 <malloc+0x2174>
    4aac:	00001097          	auipc	ra,0x1
    4ab0:	f82080e7          	jalr	-126(ra) # 5a2e <printf>
      exit(1);
    4ab4:	4505                	li	a0,1
    4ab6:	00001097          	auipc	ra,0x1
    4aba:	be8080e7          	jalr	-1048(ra) # 569e <exit>
  close(fd);
    4abe:	8552                	mv	a0,s4
    4ac0:	00001097          	auipc	ra,0x1
    4ac4:	c06080e7          	jalr	-1018(ra) # 56c6 <close>
  if(total != N*SZ){
    4ac8:	678d                	lui	a5,0x3
    4aca:	ee078793          	addi	a5,a5,-288 # 2ee0 <exitiputtest+0x48>
    4ace:	02f99363          	bne	s3,a5,4af4 <bigfile+0x1c4>
  unlink("bigfile.dat");
    4ad2:	00003517          	auipc	a0,0x3
    4ad6:	0e650513          	addi	a0,a0,230 # 7bb8 <malloc+0x20cc>
    4ada:	00001097          	auipc	ra,0x1
    4ade:	c14080e7          	jalr	-1004(ra) # 56ee <unlink>
}
    4ae2:	70e2                	ld	ra,56(sp)
    4ae4:	7442                	ld	s0,48(sp)
    4ae6:	74a2                	ld	s1,40(sp)
    4ae8:	7902                	ld	s2,32(sp)
    4aea:	69e2                	ld	s3,24(sp)
    4aec:	6a42                	ld	s4,16(sp)
    4aee:	6aa2                	ld	s5,8(sp)
    4af0:	6121                	addi	sp,sp,64
    4af2:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4af4:	85d6                	mv	a1,s5
    4af6:	00003517          	auipc	a0,0x3
    4afa:	18a50513          	addi	a0,a0,394 # 7c80 <malloc+0x2194>
    4afe:	00001097          	auipc	ra,0x1
    4b02:	f30080e7          	jalr	-208(ra) # 5a2e <printf>
    exit(1);
    4b06:	4505                	li	a0,1
    4b08:	00001097          	auipc	ra,0x1
    4b0c:	b96080e7          	jalr	-1130(ra) # 569e <exit>

0000000000004b10 <killstatus>:
{
    4b10:	7139                	addi	sp,sp,-64
    4b12:	fc06                	sd	ra,56(sp)
    4b14:	f822                	sd	s0,48(sp)
    4b16:	f426                	sd	s1,40(sp)
    4b18:	f04a                	sd	s2,32(sp)
    4b1a:	ec4e                	sd	s3,24(sp)
    4b1c:	e852                	sd	s4,16(sp)
    4b1e:	0080                	addi	s0,sp,64
    4b20:	8a2a                	mv	s4,a0
    4b22:	06400913          	li	s2,100
    if(xst != -1) {
    4b26:	59fd                	li	s3,-1
    int pid1 = fork();
    4b28:	00001097          	auipc	ra,0x1
    4b2c:	b6e080e7          	jalr	-1170(ra) # 5696 <fork>
    4b30:	84aa                	mv	s1,a0
    if(pid1 < 0){
    4b32:	02054f63          	bltz	a0,4b70 <killstatus+0x60>
    if(pid1 == 0){
    4b36:	c939                	beqz	a0,4b8c <killstatus+0x7c>
    sleep(1);
    4b38:	4505                	li	a0,1
    4b3a:	00001097          	auipc	ra,0x1
    4b3e:	bf4080e7          	jalr	-1036(ra) # 572e <sleep>
    kill(pid1);
    4b42:	8526                	mv	a0,s1
    4b44:	00001097          	auipc	ra,0x1
    4b48:	b8a080e7          	jalr	-1142(ra) # 56ce <kill>
    wait(&xst);
    4b4c:	fcc40513          	addi	a0,s0,-52
    4b50:	00001097          	auipc	ra,0x1
    4b54:	b56080e7          	jalr	-1194(ra) # 56a6 <wait>
    if(xst != -1) {
    4b58:	fcc42783          	lw	a5,-52(s0)
    4b5c:	03379d63          	bne	a5,s3,4b96 <killstatus+0x86>
  for(int i = 0; i < 100; i++){
    4b60:	397d                	addiw	s2,s2,-1
    4b62:	fc0913e3          	bnez	s2,4b28 <killstatus+0x18>
  exit(0);
    4b66:	4501                	li	a0,0
    4b68:	00001097          	auipc	ra,0x1
    4b6c:	b36080e7          	jalr	-1226(ra) # 569e <exit>
      printf("%s: fork failed\n", s);
    4b70:	85d2                	mv	a1,s4
    4b72:	00002517          	auipc	a0,0x2
    4b76:	bee50513          	addi	a0,a0,-1042 # 6760 <malloc+0xc74>
    4b7a:	00001097          	auipc	ra,0x1
    4b7e:	eb4080e7          	jalr	-332(ra) # 5a2e <printf>
      exit(1);
    4b82:	4505                	li	a0,1
    4b84:	00001097          	auipc	ra,0x1
    4b88:	b1a080e7          	jalr	-1254(ra) # 569e <exit>
        getpid();
    4b8c:	00001097          	auipc	ra,0x1
    4b90:	b92080e7          	jalr	-1134(ra) # 571e <getpid>
      while(1) {
    4b94:	bfe5                	j	4b8c <killstatus+0x7c>
       printf("%s: status should be -1\n", s);
    4b96:	85d2                	mv	a1,s4
    4b98:	00003517          	auipc	a0,0x3
    4b9c:	10850513          	addi	a0,a0,264 # 7ca0 <malloc+0x21b4>
    4ba0:	00001097          	auipc	ra,0x1
    4ba4:	e8e080e7          	jalr	-370(ra) # 5a2e <printf>
       exit(1);
    4ba8:	4505                	li	a0,1
    4baa:	00001097          	auipc	ra,0x1
    4bae:	af4080e7          	jalr	-1292(ra) # 569e <exit>

0000000000004bb2 <preempt>:
{
    4bb2:	7139                	addi	sp,sp,-64
    4bb4:	fc06                	sd	ra,56(sp)
    4bb6:	f822                	sd	s0,48(sp)
    4bb8:	f426                	sd	s1,40(sp)
    4bba:	f04a                	sd	s2,32(sp)
    4bbc:	ec4e                	sd	s3,24(sp)
    4bbe:	e852                	sd	s4,16(sp)
    4bc0:	0080                	addi	s0,sp,64
    4bc2:	892a                	mv	s2,a0
  pid1 = fork();
    4bc4:	00001097          	auipc	ra,0x1
    4bc8:	ad2080e7          	jalr	-1326(ra) # 5696 <fork>
  if(pid1 < 0) {
    4bcc:	00054563          	bltz	a0,4bd6 <preempt+0x24>
    4bd0:	84aa                	mv	s1,a0
  if(pid1 == 0)
    4bd2:	e105                	bnez	a0,4bf2 <preempt+0x40>
    for(;;)
    4bd4:	a001                	j	4bd4 <preempt+0x22>
    printf("%s: fork failed", s);
    4bd6:	85ca                	mv	a1,s2
    4bd8:	00002517          	auipc	a0,0x2
    4bdc:	d4850513          	addi	a0,a0,-696 # 6920 <malloc+0xe34>
    4be0:	00001097          	auipc	ra,0x1
    4be4:	e4e080e7          	jalr	-434(ra) # 5a2e <printf>
    exit(1);
    4be8:	4505                	li	a0,1
    4bea:	00001097          	auipc	ra,0x1
    4bee:	ab4080e7          	jalr	-1356(ra) # 569e <exit>
  pid2 = fork();
    4bf2:	00001097          	auipc	ra,0x1
    4bf6:	aa4080e7          	jalr	-1372(ra) # 5696 <fork>
    4bfa:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    4bfc:	00054463          	bltz	a0,4c04 <preempt+0x52>
  if(pid2 == 0)
    4c00:	e105                	bnez	a0,4c20 <preempt+0x6e>
    for(;;)
    4c02:	a001                	j	4c02 <preempt+0x50>
    printf("%s: fork failed\n", s);
    4c04:	85ca                	mv	a1,s2
    4c06:	00002517          	auipc	a0,0x2
    4c0a:	b5a50513          	addi	a0,a0,-1190 # 6760 <malloc+0xc74>
    4c0e:	00001097          	auipc	ra,0x1
    4c12:	e20080e7          	jalr	-480(ra) # 5a2e <printf>
    exit(1);
    4c16:	4505                	li	a0,1
    4c18:	00001097          	auipc	ra,0x1
    4c1c:	a86080e7          	jalr	-1402(ra) # 569e <exit>
  pipe(pfds);
    4c20:	fc840513          	addi	a0,s0,-56
    4c24:	00001097          	auipc	ra,0x1
    4c28:	a8a080e7          	jalr	-1398(ra) # 56ae <pipe>
  pid3 = fork();
    4c2c:	00001097          	auipc	ra,0x1
    4c30:	a6a080e7          	jalr	-1430(ra) # 5696 <fork>
    4c34:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    4c36:	02054e63          	bltz	a0,4c72 <preempt+0xc0>
  if(pid3 == 0){
    4c3a:	e525                	bnez	a0,4ca2 <preempt+0xf0>
    close(pfds[0]);
    4c3c:	fc842503          	lw	a0,-56(s0)
    4c40:	00001097          	auipc	ra,0x1
    4c44:	a86080e7          	jalr	-1402(ra) # 56c6 <close>
    if(write(pfds[1], "x", 1) != 1)
    4c48:	4605                	li	a2,1
    4c4a:	00001597          	auipc	a1,0x1
    4c4e:	34e58593          	addi	a1,a1,846 # 5f98 <malloc+0x4ac>
    4c52:	fcc42503          	lw	a0,-52(s0)
    4c56:	00001097          	auipc	ra,0x1
    4c5a:	a68080e7          	jalr	-1432(ra) # 56be <write>
    4c5e:	4785                	li	a5,1
    4c60:	02f51763          	bne	a0,a5,4c8e <preempt+0xdc>
    close(pfds[1]);
    4c64:	fcc42503          	lw	a0,-52(s0)
    4c68:	00001097          	auipc	ra,0x1
    4c6c:	a5e080e7          	jalr	-1442(ra) # 56c6 <close>
    for(;;)
    4c70:	a001                	j	4c70 <preempt+0xbe>
     printf("%s: fork failed\n", s);
    4c72:	85ca                	mv	a1,s2
    4c74:	00002517          	auipc	a0,0x2
    4c78:	aec50513          	addi	a0,a0,-1300 # 6760 <malloc+0xc74>
    4c7c:	00001097          	auipc	ra,0x1
    4c80:	db2080e7          	jalr	-590(ra) # 5a2e <printf>
     exit(1);
    4c84:	4505                	li	a0,1
    4c86:	00001097          	auipc	ra,0x1
    4c8a:	a18080e7          	jalr	-1512(ra) # 569e <exit>
      printf("%s: preempt write error", s);
    4c8e:	85ca                	mv	a1,s2
    4c90:	00003517          	auipc	a0,0x3
    4c94:	03050513          	addi	a0,a0,48 # 7cc0 <malloc+0x21d4>
    4c98:	00001097          	auipc	ra,0x1
    4c9c:	d96080e7          	jalr	-618(ra) # 5a2e <printf>
    4ca0:	b7d1                	j	4c64 <preempt+0xb2>
  close(pfds[1]);
    4ca2:	fcc42503          	lw	a0,-52(s0)
    4ca6:	00001097          	auipc	ra,0x1
    4caa:	a20080e7          	jalr	-1504(ra) # 56c6 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    4cae:	660d                	lui	a2,0x3
    4cb0:	00007597          	auipc	a1,0x7
    4cb4:	ea058593          	addi	a1,a1,-352 # bb50 <buf>
    4cb8:	fc842503          	lw	a0,-56(s0)
    4cbc:	00001097          	auipc	ra,0x1
    4cc0:	9fa080e7          	jalr	-1542(ra) # 56b6 <read>
    4cc4:	4785                	li	a5,1
    4cc6:	02f50363          	beq	a0,a5,4cec <preempt+0x13a>
    printf("%s: preempt read error", s);
    4cca:	85ca                	mv	a1,s2
    4ccc:	00003517          	auipc	a0,0x3
    4cd0:	00c50513          	addi	a0,a0,12 # 7cd8 <malloc+0x21ec>
    4cd4:	00001097          	auipc	ra,0x1
    4cd8:	d5a080e7          	jalr	-678(ra) # 5a2e <printf>
}
    4cdc:	70e2                	ld	ra,56(sp)
    4cde:	7442                	ld	s0,48(sp)
    4ce0:	74a2                	ld	s1,40(sp)
    4ce2:	7902                	ld	s2,32(sp)
    4ce4:	69e2                	ld	s3,24(sp)
    4ce6:	6a42                	ld	s4,16(sp)
    4ce8:	6121                	addi	sp,sp,64
    4cea:	8082                	ret
  close(pfds[0]);
    4cec:	fc842503          	lw	a0,-56(s0)
    4cf0:	00001097          	auipc	ra,0x1
    4cf4:	9d6080e7          	jalr	-1578(ra) # 56c6 <close>
  printf("kill... ");
    4cf8:	00003517          	auipc	a0,0x3
    4cfc:	ff850513          	addi	a0,a0,-8 # 7cf0 <malloc+0x2204>
    4d00:	00001097          	auipc	ra,0x1
    4d04:	d2e080e7          	jalr	-722(ra) # 5a2e <printf>
  kill(pid1);
    4d08:	8526                	mv	a0,s1
    4d0a:	00001097          	auipc	ra,0x1
    4d0e:	9c4080e7          	jalr	-1596(ra) # 56ce <kill>
  kill(pid2);
    4d12:	854e                	mv	a0,s3
    4d14:	00001097          	auipc	ra,0x1
    4d18:	9ba080e7          	jalr	-1606(ra) # 56ce <kill>
  kill(pid3);
    4d1c:	8552                	mv	a0,s4
    4d1e:	00001097          	auipc	ra,0x1
    4d22:	9b0080e7          	jalr	-1616(ra) # 56ce <kill>
  printf("wait... ");
    4d26:	00003517          	auipc	a0,0x3
    4d2a:	fda50513          	addi	a0,a0,-38 # 7d00 <malloc+0x2214>
    4d2e:	00001097          	auipc	ra,0x1
    4d32:	d00080e7          	jalr	-768(ra) # 5a2e <printf>
  wait(0);
    4d36:	4501                	li	a0,0
    4d38:	00001097          	auipc	ra,0x1
    4d3c:	96e080e7          	jalr	-1682(ra) # 56a6 <wait>
  wait(0);
    4d40:	4501                	li	a0,0
    4d42:	00001097          	auipc	ra,0x1
    4d46:	964080e7          	jalr	-1692(ra) # 56a6 <wait>
  wait(0);
    4d4a:	4501                	li	a0,0
    4d4c:	00001097          	auipc	ra,0x1
    4d50:	95a080e7          	jalr	-1702(ra) # 56a6 <wait>
    4d54:	b761                	j	4cdc <preempt+0x12a>

0000000000004d56 <fsfull>:
{
    4d56:	7171                	addi	sp,sp,-176
    4d58:	f506                	sd	ra,168(sp)
    4d5a:	f122                	sd	s0,160(sp)
    4d5c:	ed26                	sd	s1,152(sp)
    4d5e:	e94a                	sd	s2,144(sp)
    4d60:	e54e                	sd	s3,136(sp)
    4d62:	e152                	sd	s4,128(sp)
    4d64:	fcd6                	sd	s5,120(sp)
    4d66:	f8da                	sd	s6,112(sp)
    4d68:	f4de                	sd	s7,104(sp)
    4d6a:	f0e2                	sd	s8,96(sp)
    4d6c:	ece6                	sd	s9,88(sp)
    4d6e:	e8ea                	sd	s10,80(sp)
    4d70:	e4ee                	sd	s11,72(sp)
    4d72:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4d74:	00003517          	auipc	a0,0x3
    4d78:	f9c50513          	addi	a0,a0,-100 # 7d10 <malloc+0x2224>
    4d7c:	00001097          	auipc	ra,0x1
    4d80:	cb2080e7          	jalr	-846(ra) # 5a2e <printf>
  for(nfiles = 0; ; nfiles++){
    4d84:	4481                	li	s1,0
    name[0] = 'f';
    4d86:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4d8a:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4d8e:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4d92:	4b29                	li	s6,10
    printf("writing %s\n", name);
    4d94:	00003c97          	auipc	s9,0x3
    4d98:	f8cc8c93          	addi	s9,s9,-116 # 7d20 <malloc+0x2234>
    int total = 0;
    4d9c:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4d9e:	00007a17          	auipc	s4,0x7
    4da2:	db2a0a13          	addi	s4,s4,-590 # bb50 <buf>
    name[0] = 'f';
    4da6:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4daa:	0384c7bb          	divw	a5,s1,s8
    4dae:	0307879b          	addiw	a5,a5,48
    4db2:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4db6:	0384e7bb          	remw	a5,s1,s8
    4dba:	0377c7bb          	divw	a5,a5,s7
    4dbe:	0307879b          	addiw	a5,a5,48
    4dc2:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4dc6:	0374e7bb          	remw	a5,s1,s7
    4dca:	0367c7bb          	divw	a5,a5,s6
    4dce:	0307879b          	addiw	a5,a5,48
    4dd2:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4dd6:	0364e7bb          	remw	a5,s1,s6
    4dda:	0307879b          	addiw	a5,a5,48
    4dde:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4de2:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4de6:	f5040593          	addi	a1,s0,-176
    4dea:	8566                	mv	a0,s9
    4dec:	00001097          	auipc	ra,0x1
    4df0:	c42080e7          	jalr	-958(ra) # 5a2e <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4df4:	20200593          	li	a1,514
    4df8:	f5040513          	addi	a0,s0,-176
    4dfc:	00001097          	auipc	ra,0x1
    4e00:	8e2080e7          	jalr	-1822(ra) # 56de <open>
    4e04:	892a                	mv	s2,a0
    if(fd < 0){
    4e06:	0a055663          	bgez	a0,4eb2 <fsfull+0x15c>
      printf("open %s failed\n", name);
    4e0a:	f5040593          	addi	a1,s0,-176
    4e0e:	00003517          	auipc	a0,0x3
    4e12:	f2250513          	addi	a0,a0,-222 # 7d30 <malloc+0x2244>
    4e16:	00001097          	auipc	ra,0x1
    4e1a:	c18080e7          	jalr	-1000(ra) # 5a2e <printf>
  while(nfiles >= 0){
    4e1e:	0604c363          	bltz	s1,4e84 <fsfull+0x12e>
    name[0] = 'f';
    4e22:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4e26:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4e2a:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4e2e:	4929                	li	s2,10
  while(nfiles >= 0){
    4e30:	5afd                	li	s5,-1
    name[0] = 'f';
    4e32:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4e36:	0344c7bb          	divw	a5,s1,s4
    4e3a:	0307879b          	addiw	a5,a5,48
    4e3e:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4e42:	0344e7bb          	remw	a5,s1,s4
    4e46:	0337c7bb          	divw	a5,a5,s3
    4e4a:	0307879b          	addiw	a5,a5,48
    4e4e:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4e52:	0334e7bb          	remw	a5,s1,s3
    4e56:	0327c7bb          	divw	a5,a5,s2
    4e5a:	0307879b          	addiw	a5,a5,48
    4e5e:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4e62:	0324e7bb          	remw	a5,s1,s2
    4e66:	0307879b          	addiw	a5,a5,48
    4e6a:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4e6e:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4e72:	f5040513          	addi	a0,s0,-176
    4e76:	00001097          	auipc	ra,0x1
    4e7a:	878080e7          	jalr	-1928(ra) # 56ee <unlink>
    nfiles--;
    4e7e:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4e80:	fb5499e3          	bne	s1,s5,4e32 <fsfull+0xdc>
  printf("fsfull test finished\n");
    4e84:	00003517          	auipc	a0,0x3
    4e88:	ecc50513          	addi	a0,a0,-308 # 7d50 <malloc+0x2264>
    4e8c:	00001097          	auipc	ra,0x1
    4e90:	ba2080e7          	jalr	-1118(ra) # 5a2e <printf>
}
    4e94:	70aa                	ld	ra,168(sp)
    4e96:	740a                	ld	s0,160(sp)
    4e98:	64ea                	ld	s1,152(sp)
    4e9a:	694a                	ld	s2,144(sp)
    4e9c:	69aa                	ld	s3,136(sp)
    4e9e:	6a0a                	ld	s4,128(sp)
    4ea0:	7ae6                	ld	s5,120(sp)
    4ea2:	7b46                	ld	s6,112(sp)
    4ea4:	7ba6                	ld	s7,104(sp)
    4ea6:	7c06                	ld	s8,96(sp)
    4ea8:	6ce6                	ld	s9,88(sp)
    4eaa:	6d46                	ld	s10,80(sp)
    4eac:	6da6                	ld	s11,72(sp)
    4eae:	614d                	addi	sp,sp,176
    4eb0:	8082                	ret
    int total = 0;
    4eb2:	89ee                	mv	s3,s11
      if(cc < BSIZE)
    4eb4:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4eb8:	40000613          	li	a2,1024
    4ebc:	85d2                	mv	a1,s4
    4ebe:	854a                	mv	a0,s2
    4ec0:	00000097          	auipc	ra,0x0
    4ec4:	7fe080e7          	jalr	2046(ra) # 56be <write>
      if(cc < BSIZE)
    4ec8:	00aad563          	bge	s5,a0,4ed2 <fsfull+0x17c>
      total += cc;
    4ecc:	00a989bb          	addw	s3,s3,a0
    while(1){
    4ed0:	b7e5                	j	4eb8 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    4ed2:	85ce                	mv	a1,s3
    4ed4:	00003517          	auipc	a0,0x3
    4ed8:	e6c50513          	addi	a0,a0,-404 # 7d40 <malloc+0x2254>
    4edc:	00001097          	auipc	ra,0x1
    4ee0:	b52080e7          	jalr	-1198(ra) # 5a2e <printf>
    close(fd);
    4ee4:	854a                	mv	a0,s2
    4ee6:	00000097          	auipc	ra,0x0
    4eea:	7e0080e7          	jalr	2016(ra) # 56c6 <close>
    if(total == 0)
    4eee:	f20988e3          	beqz	s3,4e1e <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4ef2:	2485                	addiw	s1,s1,1
    4ef4:	bd4d                	j	4da6 <fsfull+0x50>

0000000000004ef6 <rand>:
{
    4ef6:	1141                	addi	sp,sp,-16
    4ef8:	e422                	sd	s0,8(sp)
    4efa:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4efc:	00003717          	auipc	a4,0x3
    4f00:	42c70713          	addi	a4,a4,1068 # 8328 <randstate>
    4f04:	6308                	ld	a0,0(a4)
    4f06:	001967b7          	lui	a5,0x196
    4f0a:	60d78793          	addi	a5,a5,1549 # 19660d <__BSS_END__+0x187aad>
    4f0e:	02f50533          	mul	a0,a0,a5
    4f12:	3c6ef7b7          	lui	a5,0x3c6ef
    4f16:	35f78793          	addi	a5,a5,863 # 3c6ef35f <__BSS_END__+0x3c6e07ff>
    4f1a:	953e                	add	a0,a0,a5
    4f1c:	e308                	sd	a0,0(a4)
}
    4f1e:	2501                	sext.w	a0,a0
    4f20:	6422                	ld	s0,8(sp)
    4f22:	0141                	addi	sp,sp,16
    4f24:	8082                	ret

0000000000004f26 <badwrite>:
{
    4f26:	7179                	addi	sp,sp,-48
    4f28:	f406                	sd	ra,40(sp)
    4f2a:	f022                	sd	s0,32(sp)
    4f2c:	ec26                	sd	s1,24(sp)
    4f2e:	e84a                	sd	s2,16(sp)
    4f30:	e44e                	sd	s3,8(sp)
    4f32:	e052                	sd	s4,0(sp)
    4f34:	1800                	addi	s0,sp,48
  unlink("junk");
    4f36:	00003517          	auipc	a0,0x3
    4f3a:	e3250513          	addi	a0,a0,-462 # 7d68 <malloc+0x227c>
    4f3e:	00000097          	auipc	ra,0x0
    4f42:	7b0080e7          	jalr	1968(ra) # 56ee <unlink>
    4f46:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    4f4a:	00003997          	auipc	s3,0x3
    4f4e:	e1e98993          	addi	s3,s3,-482 # 7d68 <malloc+0x227c>
    write(fd, (char*)0xffffffffffL, 1);
    4f52:	5a7d                	li	s4,-1
    4f54:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    4f58:	20100593          	li	a1,513
    4f5c:	854e                	mv	a0,s3
    4f5e:	00000097          	auipc	ra,0x0
    4f62:	780080e7          	jalr	1920(ra) # 56de <open>
    4f66:	84aa                	mv	s1,a0
    if(fd < 0){
    4f68:	06054b63          	bltz	a0,4fde <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    4f6c:	4605                	li	a2,1
    4f6e:	85d2                	mv	a1,s4
    4f70:	00000097          	auipc	ra,0x0
    4f74:	74e080e7          	jalr	1870(ra) # 56be <write>
    close(fd);
    4f78:	8526                	mv	a0,s1
    4f7a:	00000097          	auipc	ra,0x0
    4f7e:	74c080e7          	jalr	1868(ra) # 56c6 <close>
    unlink("junk");
    4f82:	854e                	mv	a0,s3
    4f84:	00000097          	auipc	ra,0x0
    4f88:	76a080e7          	jalr	1898(ra) # 56ee <unlink>
  for(int i = 0; i < assumed_free; i++){
    4f8c:	397d                	addiw	s2,s2,-1
    4f8e:	fc0915e3          	bnez	s2,4f58 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    4f92:	20100593          	li	a1,513
    4f96:	00003517          	auipc	a0,0x3
    4f9a:	dd250513          	addi	a0,a0,-558 # 7d68 <malloc+0x227c>
    4f9e:	00000097          	auipc	ra,0x0
    4fa2:	740080e7          	jalr	1856(ra) # 56de <open>
    4fa6:	84aa                	mv	s1,a0
  if(fd < 0){
    4fa8:	04054863          	bltz	a0,4ff8 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    4fac:	4605                	li	a2,1
    4fae:	00001597          	auipc	a1,0x1
    4fb2:	fea58593          	addi	a1,a1,-22 # 5f98 <malloc+0x4ac>
    4fb6:	00000097          	auipc	ra,0x0
    4fba:	708080e7          	jalr	1800(ra) # 56be <write>
    4fbe:	4785                	li	a5,1
    4fc0:	04f50963          	beq	a0,a5,5012 <badwrite+0xec>
    printf("write failed\n");
    4fc4:	00003517          	auipc	a0,0x3
    4fc8:	dc450513          	addi	a0,a0,-572 # 7d88 <malloc+0x229c>
    4fcc:	00001097          	auipc	ra,0x1
    4fd0:	a62080e7          	jalr	-1438(ra) # 5a2e <printf>
    exit(1);
    4fd4:	4505                	li	a0,1
    4fd6:	00000097          	auipc	ra,0x0
    4fda:	6c8080e7          	jalr	1736(ra) # 569e <exit>
      printf("open junk failed\n");
    4fde:	00003517          	auipc	a0,0x3
    4fe2:	d9250513          	addi	a0,a0,-622 # 7d70 <malloc+0x2284>
    4fe6:	00001097          	auipc	ra,0x1
    4fea:	a48080e7          	jalr	-1464(ra) # 5a2e <printf>
      exit(1);
    4fee:	4505                	li	a0,1
    4ff0:	00000097          	auipc	ra,0x0
    4ff4:	6ae080e7          	jalr	1710(ra) # 569e <exit>
    printf("open junk failed\n");
    4ff8:	00003517          	auipc	a0,0x3
    4ffc:	d7850513          	addi	a0,a0,-648 # 7d70 <malloc+0x2284>
    5000:	00001097          	auipc	ra,0x1
    5004:	a2e080e7          	jalr	-1490(ra) # 5a2e <printf>
    exit(1);
    5008:	4505                	li	a0,1
    500a:	00000097          	auipc	ra,0x0
    500e:	694080e7          	jalr	1684(ra) # 569e <exit>
  close(fd);
    5012:	8526                	mv	a0,s1
    5014:	00000097          	auipc	ra,0x0
    5018:	6b2080e7          	jalr	1714(ra) # 56c6 <close>
  unlink("junk");
    501c:	00003517          	auipc	a0,0x3
    5020:	d4c50513          	addi	a0,a0,-692 # 7d68 <malloc+0x227c>
    5024:	00000097          	auipc	ra,0x0
    5028:	6ca080e7          	jalr	1738(ra) # 56ee <unlink>
  exit(0);
    502c:	4501                	li	a0,0
    502e:	00000097          	auipc	ra,0x0
    5032:	670080e7          	jalr	1648(ra) # 569e <exit>

0000000000005036 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    5036:	7139                	addi	sp,sp,-64
    5038:	fc06                	sd	ra,56(sp)
    503a:	f822                	sd	s0,48(sp)
    503c:	f426                	sd	s1,40(sp)
    503e:	f04a                	sd	s2,32(sp)
    5040:	ec4e                	sd	s3,24(sp)
    5042:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    5044:	fc840513          	addi	a0,s0,-56
    5048:	00000097          	auipc	ra,0x0
    504c:	666080e7          	jalr	1638(ra) # 56ae <pipe>
    5050:	06054763          	bltz	a0,50be <countfree+0x88>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    5054:	00000097          	auipc	ra,0x0
    5058:	642080e7          	jalr	1602(ra) # 5696 <fork>

  if(pid < 0){
    505c:	06054e63          	bltz	a0,50d8 <countfree+0xa2>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    5060:	ed51                	bnez	a0,50fc <countfree+0xc6>
    close(fds[0]);
    5062:	fc842503          	lw	a0,-56(s0)
    5066:	00000097          	auipc	ra,0x0
    506a:	660080e7          	jalr	1632(ra) # 56c6 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    506e:	597d                	li	s2,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    5070:	4485                	li	s1,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    5072:	00001997          	auipc	s3,0x1
    5076:	f2698993          	addi	s3,s3,-218 # 5f98 <malloc+0x4ac>
      uint64 a = (uint64) sbrk(4096);
    507a:	6505                	lui	a0,0x1
    507c:	00000097          	auipc	ra,0x0
    5080:	6aa080e7          	jalr	1706(ra) # 5726 <sbrk>
      if(a == 0xffffffffffffffff){
    5084:	07250763          	beq	a0,s2,50f2 <countfree+0xbc>
      *(char *)(a + 4096 - 1) = 1;
    5088:	6785                	lui	a5,0x1
    508a:	953e                	add	a0,a0,a5
    508c:	fe950fa3          	sb	s1,-1(a0) # fff <bigdir+0x9d>
      if(write(fds[1], "x", 1) != 1){
    5090:	8626                	mv	a2,s1
    5092:	85ce                	mv	a1,s3
    5094:	fcc42503          	lw	a0,-52(s0)
    5098:	00000097          	auipc	ra,0x0
    509c:	626080e7          	jalr	1574(ra) # 56be <write>
    50a0:	fc950de3          	beq	a0,s1,507a <countfree+0x44>
        printf("write() failed in countfree()\n");
    50a4:	00003517          	auipc	a0,0x3
    50a8:	d3450513          	addi	a0,a0,-716 # 7dd8 <malloc+0x22ec>
    50ac:	00001097          	auipc	ra,0x1
    50b0:	982080e7          	jalr	-1662(ra) # 5a2e <printf>
        exit(1);
    50b4:	4505                	li	a0,1
    50b6:	00000097          	auipc	ra,0x0
    50ba:	5e8080e7          	jalr	1512(ra) # 569e <exit>
    printf("pipe() failed in countfree()\n");
    50be:	00003517          	auipc	a0,0x3
    50c2:	cda50513          	addi	a0,a0,-806 # 7d98 <malloc+0x22ac>
    50c6:	00001097          	auipc	ra,0x1
    50ca:	968080e7          	jalr	-1688(ra) # 5a2e <printf>
    exit(1);
    50ce:	4505                	li	a0,1
    50d0:	00000097          	auipc	ra,0x0
    50d4:	5ce080e7          	jalr	1486(ra) # 569e <exit>
    printf("fork failed in countfree()\n");
    50d8:	00003517          	auipc	a0,0x3
    50dc:	ce050513          	addi	a0,a0,-800 # 7db8 <malloc+0x22cc>
    50e0:	00001097          	auipc	ra,0x1
    50e4:	94e080e7          	jalr	-1714(ra) # 5a2e <printf>
    exit(1);
    50e8:	4505                	li	a0,1
    50ea:	00000097          	auipc	ra,0x0
    50ee:	5b4080e7          	jalr	1460(ra) # 569e <exit>
      }
    }

    exit(0);
    50f2:	4501                	li	a0,0
    50f4:	00000097          	auipc	ra,0x0
    50f8:	5aa080e7          	jalr	1450(ra) # 569e <exit>
  }

  close(fds[1]);
    50fc:	fcc42503          	lw	a0,-52(s0)
    5100:	00000097          	auipc	ra,0x0
    5104:	5c6080e7          	jalr	1478(ra) # 56c6 <close>

  int n = 0;
    5108:	4481                	li	s1,0
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    510a:	4605                	li	a2,1
    510c:	fc740593          	addi	a1,s0,-57
    5110:	fc842503          	lw	a0,-56(s0)
    5114:	00000097          	auipc	ra,0x0
    5118:	5a2080e7          	jalr	1442(ra) # 56b6 <read>
    if(cc < 0){
    511c:	00054563          	bltz	a0,5126 <countfree+0xf0>
      printf("read() failed in countfree()\n");
      exit(1);
    }
    if(cc == 0)
    5120:	c105                	beqz	a0,5140 <countfree+0x10a>
      break;
    n += 1;
    5122:	2485                	addiw	s1,s1,1
  while(1){
    5124:	b7dd                	j	510a <countfree+0xd4>
      printf("read() failed in countfree()\n");
    5126:	00003517          	auipc	a0,0x3
    512a:	cd250513          	addi	a0,a0,-814 # 7df8 <malloc+0x230c>
    512e:	00001097          	auipc	ra,0x1
    5132:	900080e7          	jalr	-1792(ra) # 5a2e <printf>
      exit(1);
    5136:	4505                	li	a0,1
    5138:	00000097          	auipc	ra,0x0
    513c:	566080e7          	jalr	1382(ra) # 569e <exit>
  }

  close(fds[0]);
    5140:	fc842503          	lw	a0,-56(s0)
    5144:	00000097          	auipc	ra,0x0
    5148:	582080e7          	jalr	1410(ra) # 56c6 <close>
  wait((int*)0);
    514c:	4501                	li	a0,0
    514e:	00000097          	auipc	ra,0x0
    5152:	558080e7          	jalr	1368(ra) # 56a6 <wait>
  
  return n;
}
    5156:	8526                	mv	a0,s1
    5158:	70e2                	ld	ra,56(sp)
    515a:	7442                	ld	s0,48(sp)
    515c:	74a2                	ld	s1,40(sp)
    515e:	7902                	ld	s2,32(sp)
    5160:	69e2                	ld	s3,24(sp)
    5162:	6121                	addi	sp,sp,64
    5164:	8082                	ret

0000000000005166 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    5166:	7179                	addi	sp,sp,-48
    5168:	f406                	sd	ra,40(sp)
    516a:	f022                	sd	s0,32(sp)
    516c:	ec26                	sd	s1,24(sp)
    516e:	e84a                	sd	s2,16(sp)
    5170:	1800                	addi	s0,sp,48
    5172:	84aa                	mv	s1,a0
    5174:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    5176:	00003517          	auipc	a0,0x3
    517a:	ca250513          	addi	a0,a0,-862 # 7e18 <malloc+0x232c>
    517e:	00001097          	auipc	ra,0x1
    5182:	8b0080e7          	jalr	-1872(ra) # 5a2e <printf>
  if((pid = fork()) < 0) {
    5186:	00000097          	auipc	ra,0x0
    518a:	510080e7          	jalr	1296(ra) # 5696 <fork>
    518e:	02054e63          	bltz	a0,51ca <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    5192:	c929                	beqz	a0,51e4 <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    5194:	fdc40513          	addi	a0,s0,-36
    5198:	00000097          	auipc	ra,0x0
    519c:	50e080e7          	jalr	1294(ra) # 56a6 <wait>
    if(xstatus != 0) 
    51a0:	fdc42783          	lw	a5,-36(s0)
    51a4:	c7b9                	beqz	a5,51f2 <run+0x8c>
      printf("FAILED\n");
    51a6:	00003517          	auipc	a0,0x3
    51aa:	c9a50513          	addi	a0,a0,-870 # 7e40 <malloc+0x2354>
    51ae:	00001097          	auipc	ra,0x1
    51b2:	880080e7          	jalr	-1920(ra) # 5a2e <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    51b6:	fdc42503          	lw	a0,-36(s0)
  }
}
    51ba:	00153513          	seqz	a0,a0
    51be:	70a2                	ld	ra,40(sp)
    51c0:	7402                	ld	s0,32(sp)
    51c2:	64e2                	ld	s1,24(sp)
    51c4:	6942                	ld	s2,16(sp)
    51c6:	6145                	addi	sp,sp,48
    51c8:	8082                	ret
    printf("runtest: fork error\n");
    51ca:	00003517          	auipc	a0,0x3
    51ce:	c5e50513          	addi	a0,a0,-930 # 7e28 <malloc+0x233c>
    51d2:	00001097          	auipc	ra,0x1
    51d6:	85c080e7          	jalr	-1956(ra) # 5a2e <printf>
    exit(1);
    51da:	4505                	li	a0,1
    51dc:	00000097          	auipc	ra,0x0
    51e0:	4c2080e7          	jalr	1218(ra) # 569e <exit>
    f(s);
    51e4:	854a                	mv	a0,s2
    51e6:	9482                	jalr	s1
    exit(0);
    51e8:	4501                	li	a0,0
    51ea:	00000097          	auipc	ra,0x0
    51ee:	4b4080e7          	jalr	1204(ra) # 569e <exit>
      printf("OK\n");
    51f2:	00003517          	auipc	a0,0x3
    51f6:	c5650513          	addi	a0,a0,-938 # 7e48 <malloc+0x235c>
    51fa:	00001097          	auipc	ra,0x1
    51fe:	834080e7          	jalr	-1996(ra) # 5a2e <printf>
    5202:	bf55                	j	51b6 <run+0x50>

0000000000005204 <main>:

int
main(int argc, char *argv[])
{
    5204:	c2010113          	addi	sp,sp,-992
    5208:	3c113c23          	sd	ra,984(sp)
    520c:	3c813823          	sd	s0,976(sp)
    5210:	3c913423          	sd	s1,968(sp)
    5214:	3d213023          	sd	s2,960(sp)
    5218:	3b313c23          	sd	s3,952(sp)
    521c:	3b413823          	sd	s4,944(sp)
    5220:	3b513423          	sd	s5,936(sp)
    5224:	3b613023          	sd	s6,928(sp)
    5228:	1780                	addi	s0,sp,992
    522a:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    522c:	4789                	li	a5,2
    522e:	08f50763          	beq	a0,a5,52bc <main+0xb8>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    5232:	4785                	li	a5,1
  char *justone = 0;
    5234:	4901                	li	s2,0
  } else if(argc > 1){
    5236:	0ca7c163          	blt	a5,a0,52f8 <main+0xf4>
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    523a:	00003797          	auipc	a5,0x3
    523e:	d2678793          	addi	a5,a5,-730 # 7f60 <malloc+0x2474>
    5242:	c2040713          	addi	a4,s0,-992
    5246:	00003817          	auipc	a6,0x3
    524a:	0ba80813          	addi	a6,a6,186 # 8300 <malloc+0x2814>
    524e:	6388                	ld	a0,0(a5)
    5250:	678c                	ld	a1,8(a5)
    5252:	6b90                	ld	a2,16(a5)
    5254:	6f94                	ld	a3,24(a5)
    5256:	e308                	sd	a0,0(a4)
    5258:	e70c                	sd	a1,8(a4)
    525a:	eb10                	sd	a2,16(a4)
    525c:	ef14                	sd	a3,24(a4)
    525e:	02078793          	addi	a5,a5,32
    5262:	02070713          	addi	a4,a4,32
    5266:	ff0794e3          	bne	a5,a6,524e <main+0x4a>
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    526a:	00003517          	auipc	a0,0x3
    526e:	c9650513          	addi	a0,a0,-874 # 7f00 <malloc+0x2414>
    5272:	00000097          	auipc	ra,0x0
    5276:	7bc080e7          	jalr	1980(ra) # 5a2e <printf>
  int free0 = countfree();
    527a:	00000097          	auipc	ra,0x0
    527e:	dbc080e7          	jalr	-580(ra) # 5036 <countfree>
    5282:	8a2a                	mv	s4,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    5284:	c2843503          	ld	a0,-984(s0)
    5288:	c2040493          	addi	s1,s0,-992
  int fail = 0;
    528c:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    528e:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    5290:	e55d                	bnez	a0,533e <main+0x13a>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    5292:	00000097          	auipc	ra,0x0
    5296:	da4080e7          	jalr	-604(ra) # 5036 <countfree>
    529a:	85aa                	mv	a1,a0
    529c:	0f455163          	bge	a0,s4,537e <main+0x17a>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    52a0:	8652                	mv	a2,s4
    52a2:	00003517          	auipc	a0,0x3
    52a6:	c1650513          	addi	a0,a0,-1002 # 7eb8 <malloc+0x23cc>
    52aa:	00000097          	auipc	ra,0x0
    52ae:	784080e7          	jalr	1924(ra) # 5a2e <printf>
    exit(1);
    52b2:	4505                	li	a0,1
    52b4:	00000097          	auipc	ra,0x0
    52b8:	3ea080e7          	jalr	1002(ra) # 569e <exit>
    52bc:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    52be:	00003597          	auipc	a1,0x3
    52c2:	b9258593          	addi	a1,a1,-1134 # 7e50 <malloc+0x2364>
    52c6:	6488                	ld	a0,8(s1)
    52c8:	00000097          	auipc	ra,0x0
    52cc:	184080e7          	jalr	388(ra) # 544c <strcmp>
    52d0:	10050563          	beqz	a0,53da <main+0x1d6>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    52d4:	00003597          	auipc	a1,0x3
    52d8:	c6458593          	addi	a1,a1,-924 # 7f38 <malloc+0x244c>
    52dc:	6488                	ld	a0,8(s1)
    52de:	00000097          	auipc	ra,0x0
    52e2:	16e080e7          	jalr	366(ra) # 544c <strcmp>
    52e6:	c97d                	beqz	a0,53dc <main+0x1d8>
  } else if(argc == 2 && argv[1][0] != '-'){
    52e8:	0084b903          	ld	s2,8(s1)
    52ec:	00094703          	lbu	a4,0(s2)
    52f0:	02d00793          	li	a5,45
    52f4:	f4f713e3          	bne	a4,a5,523a <main+0x36>
    printf("Usage: usertests [-c] [testname]\n");
    52f8:	00003517          	auipc	a0,0x3
    52fc:	b6050513          	addi	a0,a0,-1184 # 7e58 <malloc+0x236c>
    5300:	00000097          	auipc	ra,0x0
    5304:	72e080e7          	jalr	1838(ra) # 5a2e <printf>
    exit(1);
    5308:	4505                	li	a0,1
    530a:	00000097          	auipc	ra,0x0
    530e:	394080e7          	jalr	916(ra) # 569e <exit>
          exit(1);
    5312:	4505                	li	a0,1
    5314:	00000097          	auipc	ra,0x0
    5318:	38a080e7          	jalr	906(ra) # 569e <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    531c:	40a905bb          	subw	a1,s2,a0
    5320:	855a                	mv	a0,s6
    5322:	00000097          	auipc	ra,0x0
    5326:	70c080e7          	jalr	1804(ra) # 5a2e <printf>
        if(continuous != 2)
    532a:	09498463          	beq	s3,s4,53b2 <main+0x1ae>
          exit(1);
    532e:	4505                	li	a0,1
    5330:	00000097          	auipc	ra,0x0
    5334:	36e080e7          	jalr	878(ra) # 569e <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    5338:	04c1                	addi	s1,s1,16
    533a:	6488                	ld	a0,8(s1)
    533c:	c115                	beqz	a0,5360 <main+0x15c>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    533e:	00090863          	beqz	s2,534e <main+0x14a>
    5342:	85ca                	mv	a1,s2
    5344:	00000097          	auipc	ra,0x0
    5348:	108080e7          	jalr	264(ra) # 544c <strcmp>
    534c:	f575                	bnez	a0,5338 <main+0x134>
      if(!run(t->f, t->s))
    534e:	648c                	ld	a1,8(s1)
    5350:	6088                	ld	a0,0(s1)
    5352:	00000097          	auipc	ra,0x0
    5356:	e14080e7          	jalr	-492(ra) # 5166 <run>
    535a:	fd79                	bnez	a0,5338 <main+0x134>
        fail = 1;
    535c:	89d6                	mv	s3,s5
    535e:	bfe9                	j	5338 <main+0x134>
  if(fail){
    5360:	f20989e3          	beqz	s3,5292 <main+0x8e>
    printf("SOME TESTS FAILED\n");
    5364:	00003517          	auipc	a0,0x3
    5368:	b3c50513          	addi	a0,a0,-1220 # 7ea0 <malloc+0x23b4>
    536c:	00000097          	auipc	ra,0x0
    5370:	6c2080e7          	jalr	1730(ra) # 5a2e <printf>
    exit(1);
    5374:	4505                	li	a0,1
    5376:	00000097          	auipc	ra,0x0
    537a:	328080e7          	jalr	808(ra) # 569e <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    537e:	00003517          	auipc	a0,0x3
    5382:	b6a50513          	addi	a0,a0,-1174 # 7ee8 <malloc+0x23fc>
    5386:	00000097          	auipc	ra,0x0
    538a:	6a8080e7          	jalr	1704(ra) # 5a2e <printf>
    exit(0);
    538e:	4501                	li	a0,0
    5390:	00000097          	auipc	ra,0x0
    5394:	30e080e7          	jalr	782(ra) # 569e <exit>
        printf("SOME TESTS FAILED\n");
    5398:	8556                	mv	a0,s5
    539a:	00000097          	auipc	ra,0x0
    539e:	694080e7          	jalr	1684(ra) # 5a2e <printf>
        if(continuous != 2)
    53a2:	f74998e3          	bne	s3,s4,5312 <main+0x10e>
      int free1 = countfree();
    53a6:	00000097          	auipc	ra,0x0
    53aa:	c90080e7          	jalr	-880(ra) # 5036 <countfree>
      if(free1 < free0){
    53ae:	f72547e3          	blt	a0,s2,531c <main+0x118>
      int free0 = countfree();
    53b2:	00000097          	auipc	ra,0x0
    53b6:	c84080e7          	jalr	-892(ra) # 5036 <countfree>
    53ba:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    53bc:	c2843583          	ld	a1,-984(s0)
    53c0:	d1fd                	beqz	a1,53a6 <main+0x1a2>
    53c2:	c2040493          	addi	s1,s0,-992
        if(!run(t->f, t->s)){
    53c6:	6088                	ld	a0,0(s1)
    53c8:	00000097          	auipc	ra,0x0
    53cc:	d9e080e7          	jalr	-610(ra) # 5166 <run>
    53d0:	d561                	beqz	a0,5398 <main+0x194>
      for (struct test *t = tests; t->s != 0; t++) {
    53d2:	04c1                	addi	s1,s1,16
    53d4:	648c                	ld	a1,8(s1)
    53d6:	f9e5                	bnez	a1,53c6 <main+0x1c2>
    53d8:	b7f9                	j	53a6 <main+0x1a2>
    continuous = 1;
    53da:	4985                	li	s3,1
  } tests[] = {
    53dc:	00003797          	auipc	a5,0x3
    53e0:	b8478793          	addi	a5,a5,-1148 # 7f60 <malloc+0x2474>
    53e4:	c2040713          	addi	a4,s0,-992
    53e8:	00003817          	auipc	a6,0x3
    53ec:	f1880813          	addi	a6,a6,-232 # 8300 <malloc+0x2814>
    53f0:	6388                	ld	a0,0(a5)
    53f2:	678c                	ld	a1,8(a5)
    53f4:	6b90                	ld	a2,16(a5)
    53f6:	6f94                	ld	a3,24(a5)
    53f8:	e308                	sd	a0,0(a4)
    53fa:	e70c                	sd	a1,8(a4)
    53fc:	eb10                	sd	a2,16(a4)
    53fe:	ef14                	sd	a3,24(a4)
    5400:	02078793          	addi	a5,a5,32
    5404:	02070713          	addi	a4,a4,32
    5408:	ff0794e3          	bne	a5,a6,53f0 <main+0x1ec>
    printf("continuous usertests starting\n");
    540c:	00003517          	auipc	a0,0x3
    5410:	b0c50513          	addi	a0,a0,-1268 # 7f18 <malloc+0x242c>
    5414:	00000097          	auipc	ra,0x0
    5418:	61a080e7          	jalr	1562(ra) # 5a2e <printf>
        printf("SOME TESTS FAILED\n");
    541c:	00003a97          	auipc	s5,0x3
    5420:	a84a8a93          	addi	s5,s5,-1404 # 7ea0 <malloc+0x23b4>
        if(continuous != 2)
    5424:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5426:	00003b17          	auipc	s6,0x3
    542a:	a5ab0b13          	addi	s6,s6,-1446 # 7e80 <malloc+0x2394>
    542e:	b751                	j	53b2 <main+0x1ae>

0000000000005430 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    5430:	1141                	addi	sp,sp,-16
    5432:	e422                	sd	s0,8(sp)
    5434:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    5436:	87aa                	mv	a5,a0
    5438:	0585                	addi	a1,a1,1
    543a:	0785                	addi	a5,a5,1
    543c:	fff5c703          	lbu	a4,-1(a1)
    5440:	fee78fa3          	sb	a4,-1(a5)
    5444:	fb75                	bnez	a4,5438 <strcpy+0x8>
    ;
  return os;
}
    5446:	6422                	ld	s0,8(sp)
    5448:	0141                	addi	sp,sp,16
    544a:	8082                	ret

000000000000544c <strcmp>:

int
strcmp(const char *p, const char *q)
{
    544c:	1141                	addi	sp,sp,-16
    544e:	e422                	sd	s0,8(sp)
    5450:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    5452:	00054783          	lbu	a5,0(a0)
    5456:	cb91                	beqz	a5,546a <strcmp+0x1e>
    5458:	0005c703          	lbu	a4,0(a1)
    545c:	00f71763          	bne	a4,a5,546a <strcmp+0x1e>
    p++, q++;
    5460:	0505                	addi	a0,a0,1
    5462:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    5464:	00054783          	lbu	a5,0(a0)
    5468:	fbe5                	bnez	a5,5458 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    546a:	0005c503          	lbu	a0,0(a1)
}
    546e:	40a7853b          	subw	a0,a5,a0
    5472:	6422                	ld	s0,8(sp)
    5474:	0141                	addi	sp,sp,16
    5476:	8082                	ret

0000000000005478 <strlen>:

uint
strlen(const char *s)
{
    5478:	1141                	addi	sp,sp,-16
    547a:	e422                	sd	s0,8(sp)
    547c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    547e:	00054783          	lbu	a5,0(a0)
    5482:	cf91                	beqz	a5,549e <strlen+0x26>
    5484:	0505                	addi	a0,a0,1
    5486:	87aa                	mv	a5,a0
    5488:	4685                	li	a3,1
    548a:	9e89                	subw	a3,a3,a0
    548c:	00f6853b          	addw	a0,a3,a5
    5490:	0785                	addi	a5,a5,1
    5492:	fff7c703          	lbu	a4,-1(a5)
    5496:	fb7d                	bnez	a4,548c <strlen+0x14>
    ;
  return n;
}
    5498:	6422                	ld	s0,8(sp)
    549a:	0141                	addi	sp,sp,16
    549c:	8082                	ret
  for(n = 0; s[n]; n++)
    549e:	4501                	li	a0,0
    54a0:	bfe5                	j	5498 <strlen+0x20>

00000000000054a2 <memset>:

void*
memset(void *dst, int c, uint n)
{
    54a2:	1141                	addi	sp,sp,-16
    54a4:	e422                	sd	s0,8(sp)
    54a6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    54a8:	ca19                	beqz	a2,54be <memset+0x1c>
    54aa:	87aa                	mv	a5,a0
    54ac:	1602                	slli	a2,a2,0x20
    54ae:	9201                	srli	a2,a2,0x20
    54b0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    54b4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    54b8:	0785                	addi	a5,a5,1
    54ba:	fee79de3          	bne	a5,a4,54b4 <memset+0x12>
  }
  return dst;
}
    54be:	6422                	ld	s0,8(sp)
    54c0:	0141                	addi	sp,sp,16
    54c2:	8082                	ret

00000000000054c4 <strchr>:

char*
strchr(const char *s, char c)
{
    54c4:	1141                	addi	sp,sp,-16
    54c6:	e422                	sd	s0,8(sp)
    54c8:	0800                	addi	s0,sp,16
  for(; *s; s++)
    54ca:	00054783          	lbu	a5,0(a0)
    54ce:	cb99                	beqz	a5,54e4 <strchr+0x20>
    if(*s == c)
    54d0:	00f58763          	beq	a1,a5,54de <strchr+0x1a>
  for(; *s; s++)
    54d4:	0505                	addi	a0,a0,1
    54d6:	00054783          	lbu	a5,0(a0)
    54da:	fbfd                	bnez	a5,54d0 <strchr+0xc>
      return (char*)s;
  return 0;
    54dc:	4501                	li	a0,0
}
    54de:	6422                	ld	s0,8(sp)
    54e0:	0141                	addi	sp,sp,16
    54e2:	8082                	ret
  return 0;
    54e4:	4501                	li	a0,0
    54e6:	bfe5                	j	54de <strchr+0x1a>

00000000000054e8 <gets>:

char*
gets(char *buf, int max)
{
    54e8:	711d                	addi	sp,sp,-96
    54ea:	ec86                	sd	ra,88(sp)
    54ec:	e8a2                	sd	s0,80(sp)
    54ee:	e4a6                	sd	s1,72(sp)
    54f0:	e0ca                	sd	s2,64(sp)
    54f2:	fc4e                	sd	s3,56(sp)
    54f4:	f852                	sd	s4,48(sp)
    54f6:	f456                	sd	s5,40(sp)
    54f8:	f05a                	sd	s6,32(sp)
    54fa:	ec5e                	sd	s7,24(sp)
    54fc:	1080                	addi	s0,sp,96
    54fe:	8baa                	mv	s7,a0
    5500:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    5502:	892a                	mv	s2,a0
    5504:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5506:	4aa9                	li	s5,10
    5508:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    550a:	89a6                	mv	s3,s1
    550c:	2485                	addiw	s1,s1,1
    550e:	0344d863          	bge	s1,s4,553e <gets+0x56>
    cc = read(0, &c, 1);
    5512:	4605                	li	a2,1
    5514:	faf40593          	addi	a1,s0,-81
    5518:	4501                	li	a0,0
    551a:	00000097          	auipc	ra,0x0
    551e:	19c080e7          	jalr	412(ra) # 56b6 <read>
    if(cc < 1)
    5522:	00a05e63          	blez	a0,553e <gets+0x56>
    buf[i++] = c;
    5526:	faf44783          	lbu	a5,-81(s0)
    552a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    552e:	01578763          	beq	a5,s5,553c <gets+0x54>
    5532:	0905                	addi	s2,s2,1
    5534:	fd679be3          	bne	a5,s6,550a <gets+0x22>
  for(i=0; i+1 < max; ){
    5538:	89a6                	mv	s3,s1
    553a:	a011                	j	553e <gets+0x56>
    553c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    553e:	99de                	add	s3,s3,s7
    5540:	00098023          	sb	zero,0(s3)
  return buf;
}
    5544:	855e                	mv	a0,s7
    5546:	60e6                	ld	ra,88(sp)
    5548:	6446                	ld	s0,80(sp)
    554a:	64a6                	ld	s1,72(sp)
    554c:	6906                	ld	s2,64(sp)
    554e:	79e2                	ld	s3,56(sp)
    5550:	7a42                	ld	s4,48(sp)
    5552:	7aa2                	ld	s5,40(sp)
    5554:	7b02                	ld	s6,32(sp)
    5556:	6be2                	ld	s7,24(sp)
    5558:	6125                	addi	sp,sp,96
    555a:	8082                	ret

000000000000555c <stat>:

int
stat(const char *n, struct stat *st)
{
    555c:	1101                	addi	sp,sp,-32
    555e:	ec06                	sd	ra,24(sp)
    5560:	e822                	sd	s0,16(sp)
    5562:	e426                	sd	s1,8(sp)
    5564:	e04a                	sd	s2,0(sp)
    5566:	1000                	addi	s0,sp,32
    5568:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    556a:	4581                	li	a1,0
    556c:	00000097          	auipc	ra,0x0
    5570:	172080e7          	jalr	370(ra) # 56de <open>
  if(fd < 0)
    5574:	02054563          	bltz	a0,559e <stat+0x42>
    5578:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    557a:	85ca                	mv	a1,s2
    557c:	00000097          	auipc	ra,0x0
    5580:	17a080e7          	jalr	378(ra) # 56f6 <fstat>
    5584:	892a                	mv	s2,a0
  close(fd);
    5586:	8526                	mv	a0,s1
    5588:	00000097          	auipc	ra,0x0
    558c:	13e080e7          	jalr	318(ra) # 56c6 <close>
  return r;
}
    5590:	854a                	mv	a0,s2
    5592:	60e2                	ld	ra,24(sp)
    5594:	6442                	ld	s0,16(sp)
    5596:	64a2                	ld	s1,8(sp)
    5598:	6902                	ld	s2,0(sp)
    559a:	6105                	addi	sp,sp,32
    559c:	8082                	ret
    return -1;
    559e:	597d                	li	s2,-1
    55a0:	bfc5                	j	5590 <stat+0x34>

00000000000055a2 <atoi>:

int
atoi(const char *s)
{
    55a2:	1141                	addi	sp,sp,-16
    55a4:	e422                	sd	s0,8(sp)
    55a6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    55a8:	00054603          	lbu	a2,0(a0)
    55ac:	fd06079b          	addiw	a5,a2,-48
    55b0:	0ff7f793          	andi	a5,a5,255
    55b4:	4725                	li	a4,9
    55b6:	02f76963          	bltu	a4,a5,55e8 <atoi+0x46>
    55ba:	86aa                	mv	a3,a0
  n = 0;
    55bc:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    55be:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    55c0:	0685                	addi	a3,a3,1
    55c2:	0025179b          	slliw	a5,a0,0x2
    55c6:	9fa9                	addw	a5,a5,a0
    55c8:	0017979b          	slliw	a5,a5,0x1
    55cc:	9fb1                	addw	a5,a5,a2
    55ce:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    55d2:	0006c603          	lbu	a2,0(a3)
    55d6:	fd06071b          	addiw	a4,a2,-48
    55da:	0ff77713          	andi	a4,a4,255
    55de:	fee5f1e3          	bgeu	a1,a4,55c0 <atoi+0x1e>
  return n;
}
    55e2:	6422                	ld	s0,8(sp)
    55e4:	0141                	addi	sp,sp,16
    55e6:	8082                	ret
  n = 0;
    55e8:	4501                	li	a0,0
    55ea:	bfe5                	j	55e2 <atoi+0x40>

00000000000055ec <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    55ec:	1141                	addi	sp,sp,-16
    55ee:	e422                	sd	s0,8(sp)
    55f0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    55f2:	02b57463          	bgeu	a0,a1,561a <memmove+0x2e>
    while(n-- > 0)
    55f6:	00c05f63          	blez	a2,5614 <memmove+0x28>
    55fa:	1602                	slli	a2,a2,0x20
    55fc:	9201                	srli	a2,a2,0x20
    55fe:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    5602:	872a                	mv	a4,a0
      *dst++ = *src++;
    5604:	0585                	addi	a1,a1,1
    5606:	0705                	addi	a4,a4,1
    5608:	fff5c683          	lbu	a3,-1(a1)
    560c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    5610:	fee79ae3          	bne	a5,a4,5604 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5614:	6422                	ld	s0,8(sp)
    5616:	0141                	addi	sp,sp,16
    5618:	8082                	ret
    dst += n;
    561a:	00c50733          	add	a4,a0,a2
    src += n;
    561e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    5620:	fec05ae3          	blez	a2,5614 <memmove+0x28>
    5624:	fff6079b          	addiw	a5,a2,-1
    5628:	1782                	slli	a5,a5,0x20
    562a:	9381                	srli	a5,a5,0x20
    562c:	fff7c793          	not	a5,a5
    5630:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    5632:	15fd                	addi	a1,a1,-1
    5634:	177d                	addi	a4,a4,-1
    5636:	0005c683          	lbu	a3,0(a1)
    563a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    563e:	fee79ae3          	bne	a5,a4,5632 <memmove+0x46>
    5642:	bfc9                	j	5614 <memmove+0x28>

0000000000005644 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    5644:	1141                	addi	sp,sp,-16
    5646:	e422                	sd	s0,8(sp)
    5648:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    564a:	ca05                	beqz	a2,567a <memcmp+0x36>
    564c:	fff6069b          	addiw	a3,a2,-1
    5650:	1682                	slli	a3,a3,0x20
    5652:	9281                	srli	a3,a3,0x20
    5654:	0685                	addi	a3,a3,1
    5656:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    5658:	00054783          	lbu	a5,0(a0)
    565c:	0005c703          	lbu	a4,0(a1)
    5660:	00e79863          	bne	a5,a4,5670 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    5664:	0505                	addi	a0,a0,1
    p2++;
    5666:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    5668:	fed518e3          	bne	a0,a3,5658 <memcmp+0x14>
  }
  return 0;
    566c:	4501                	li	a0,0
    566e:	a019                	j	5674 <memcmp+0x30>
      return *p1 - *p2;
    5670:	40e7853b          	subw	a0,a5,a4
}
    5674:	6422                	ld	s0,8(sp)
    5676:	0141                	addi	sp,sp,16
    5678:	8082                	ret
  return 0;
    567a:	4501                	li	a0,0
    567c:	bfe5                	j	5674 <memcmp+0x30>

000000000000567e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    567e:	1141                	addi	sp,sp,-16
    5680:	e406                	sd	ra,8(sp)
    5682:	e022                	sd	s0,0(sp)
    5684:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5686:	00000097          	auipc	ra,0x0
    568a:	f66080e7          	jalr	-154(ra) # 55ec <memmove>
}
    568e:	60a2                	ld	ra,8(sp)
    5690:	6402                	ld	s0,0(sp)
    5692:	0141                	addi	sp,sp,16
    5694:	8082                	ret

0000000000005696 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5696:	4885                	li	a7,1
 ecall
    5698:	00000073          	ecall
 ret
    569c:	8082                	ret

000000000000569e <exit>:
.global exit
exit:
 li a7, SYS_exit
    569e:	4889                	li	a7,2
 ecall
    56a0:	00000073          	ecall
 ret
    56a4:	8082                	ret

00000000000056a6 <wait>:
.global wait
wait:
 li a7, SYS_wait
    56a6:	488d                	li	a7,3
 ecall
    56a8:	00000073          	ecall
 ret
    56ac:	8082                	ret

00000000000056ae <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    56ae:	4891                	li	a7,4
 ecall
    56b0:	00000073          	ecall
 ret
    56b4:	8082                	ret

00000000000056b6 <read>:
.global read
read:
 li a7, SYS_read
    56b6:	4895                	li	a7,5
 ecall
    56b8:	00000073          	ecall
 ret
    56bc:	8082                	ret

00000000000056be <write>:
.global write
write:
 li a7, SYS_write
    56be:	48c1                	li	a7,16
 ecall
    56c0:	00000073          	ecall
 ret
    56c4:	8082                	ret

00000000000056c6 <close>:
.global close
close:
 li a7, SYS_close
    56c6:	48d5                	li	a7,21
 ecall
    56c8:	00000073          	ecall
 ret
    56cc:	8082                	ret

00000000000056ce <kill>:
.global kill
kill:
 li a7, SYS_kill
    56ce:	4899                	li	a7,6
 ecall
    56d0:	00000073          	ecall
 ret
    56d4:	8082                	ret

00000000000056d6 <exec>:
.global exec
exec:
 li a7, SYS_exec
    56d6:	489d                	li	a7,7
 ecall
    56d8:	00000073          	ecall
 ret
    56dc:	8082                	ret

00000000000056de <open>:
.global open
open:
 li a7, SYS_open
    56de:	48bd                	li	a7,15
 ecall
    56e0:	00000073          	ecall
 ret
    56e4:	8082                	ret

00000000000056e6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    56e6:	48c5                	li	a7,17
 ecall
    56e8:	00000073          	ecall
 ret
    56ec:	8082                	ret

00000000000056ee <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    56ee:	48c9                	li	a7,18
 ecall
    56f0:	00000073          	ecall
 ret
    56f4:	8082                	ret

00000000000056f6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    56f6:	48a1                	li	a7,8
 ecall
    56f8:	00000073          	ecall
 ret
    56fc:	8082                	ret

00000000000056fe <link>:
.global link
link:
 li a7, SYS_link
    56fe:	48cd                	li	a7,19
 ecall
    5700:	00000073          	ecall
 ret
    5704:	8082                	ret

0000000000005706 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5706:	48d1                	li	a7,20
 ecall
    5708:	00000073          	ecall
 ret
    570c:	8082                	ret

000000000000570e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    570e:	48a5                	li	a7,9
 ecall
    5710:	00000073          	ecall
 ret
    5714:	8082                	ret

0000000000005716 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5716:	48a9                	li	a7,10
 ecall
    5718:	00000073          	ecall
 ret
    571c:	8082                	ret

000000000000571e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    571e:	48ad                	li	a7,11
 ecall
    5720:	00000073          	ecall
 ret
    5724:	8082                	ret

0000000000005726 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    5726:	48b1                	li	a7,12
 ecall
    5728:	00000073          	ecall
 ret
    572c:	8082                	ret

000000000000572e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    572e:	48b5                	li	a7,13
 ecall
    5730:	00000073          	ecall
 ret
    5734:	8082                	ret

0000000000005736 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    5736:	48b9                	li	a7,14
 ecall
    5738:	00000073          	ecall
 ret
    573c:	8082                	ret

000000000000573e <trace>:
.global trace
trace:
 li a7, SYS_trace
    573e:	48d9                	li	a7,22
 ecall
    5740:	00000073          	ecall
 ret
    5744:	8082                	ret

0000000000005746 <wait_stat>:
.global wait_stat
wait_stat:
 li a7, SYS_wait_stat
    5746:	48dd                	li	a7,23
 ecall
    5748:	00000073          	ecall
 ret
    574c:	8082                	ret

000000000000574e <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
    574e:	48e1                	li	a7,24
 ecall
    5750:	00000073          	ecall
 ret
    5754:	8082                	ret

0000000000005756 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    5756:	1101                	addi	sp,sp,-32
    5758:	ec06                	sd	ra,24(sp)
    575a:	e822                	sd	s0,16(sp)
    575c:	1000                	addi	s0,sp,32
    575e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5762:	4605                	li	a2,1
    5764:	fef40593          	addi	a1,s0,-17
    5768:	00000097          	auipc	ra,0x0
    576c:	f56080e7          	jalr	-170(ra) # 56be <write>
}
    5770:	60e2                	ld	ra,24(sp)
    5772:	6442                	ld	s0,16(sp)
    5774:	6105                	addi	sp,sp,32
    5776:	8082                	ret

0000000000005778 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    5778:	7139                	addi	sp,sp,-64
    577a:	fc06                	sd	ra,56(sp)
    577c:	f822                	sd	s0,48(sp)
    577e:	f426                	sd	s1,40(sp)
    5780:	f04a                	sd	s2,32(sp)
    5782:	ec4e                	sd	s3,24(sp)
    5784:	0080                	addi	s0,sp,64
    5786:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    5788:	c299                	beqz	a3,578e <printint+0x16>
    578a:	0805c863          	bltz	a1,581a <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    578e:	2581                	sext.w	a1,a1
  neg = 0;
    5790:	4881                	li	a7,0
    5792:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    5796:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    5798:	2601                	sext.w	a2,a2
    579a:	00003517          	auipc	a0,0x3
    579e:	b6e50513          	addi	a0,a0,-1170 # 8308 <digits>
    57a2:	883a                	mv	a6,a4
    57a4:	2705                	addiw	a4,a4,1
    57a6:	02c5f7bb          	remuw	a5,a1,a2
    57aa:	1782                	slli	a5,a5,0x20
    57ac:	9381                	srli	a5,a5,0x20
    57ae:	97aa                	add	a5,a5,a0
    57b0:	0007c783          	lbu	a5,0(a5)
    57b4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    57b8:	0005879b          	sext.w	a5,a1
    57bc:	02c5d5bb          	divuw	a1,a1,a2
    57c0:	0685                	addi	a3,a3,1
    57c2:	fec7f0e3          	bgeu	a5,a2,57a2 <printint+0x2a>
  if(neg)
    57c6:	00088b63          	beqz	a7,57dc <printint+0x64>
    buf[i++] = '-';
    57ca:	fd040793          	addi	a5,s0,-48
    57ce:	973e                	add	a4,a4,a5
    57d0:	02d00793          	li	a5,45
    57d4:	fef70823          	sb	a5,-16(a4)
    57d8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    57dc:	02e05863          	blez	a4,580c <printint+0x94>
    57e0:	fc040793          	addi	a5,s0,-64
    57e4:	00e78933          	add	s2,a5,a4
    57e8:	fff78993          	addi	s3,a5,-1
    57ec:	99ba                	add	s3,s3,a4
    57ee:	377d                	addiw	a4,a4,-1
    57f0:	1702                	slli	a4,a4,0x20
    57f2:	9301                	srli	a4,a4,0x20
    57f4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    57f8:	fff94583          	lbu	a1,-1(s2)
    57fc:	8526                	mv	a0,s1
    57fe:	00000097          	auipc	ra,0x0
    5802:	f58080e7          	jalr	-168(ra) # 5756 <putc>
  while(--i >= 0)
    5806:	197d                	addi	s2,s2,-1
    5808:	ff3918e3          	bne	s2,s3,57f8 <printint+0x80>
}
    580c:	70e2                	ld	ra,56(sp)
    580e:	7442                	ld	s0,48(sp)
    5810:	74a2                	ld	s1,40(sp)
    5812:	7902                	ld	s2,32(sp)
    5814:	69e2                	ld	s3,24(sp)
    5816:	6121                	addi	sp,sp,64
    5818:	8082                	ret
    x = -xx;
    581a:	40b005bb          	negw	a1,a1
    neg = 1;
    581e:	4885                	li	a7,1
    x = -xx;
    5820:	bf8d                	j	5792 <printint+0x1a>

0000000000005822 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    5822:	7119                	addi	sp,sp,-128
    5824:	fc86                	sd	ra,120(sp)
    5826:	f8a2                	sd	s0,112(sp)
    5828:	f4a6                	sd	s1,104(sp)
    582a:	f0ca                	sd	s2,96(sp)
    582c:	ecce                	sd	s3,88(sp)
    582e:	e8d2                	sd	s4,80(sp)
    5830:	e4d6                	sd	s5,72(sp)
    5832:	e0da                	sd	s6,64(sp)
    5834:	fc5e                	sd	s7,56(sp)
    5836:	f862                	sd	s8,48(sp)
    5838:	f466                	sd	s9,40(sp)
    583a:	f06a                	sd	s10,32(sp)
    583c:	ec6e                	sd	s11,24(sp)
    583e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    5840:	0005c903          	lbu	s2,0(a1)
    5844:	18090f63          	beqz	s2,59e2 <vprintf+0x1c0>
    5848:	8aaa                	mv	s5,a0
    584a:	8b32                	mv	s6,a2
    584c:	00158493          	addi	s1,a1,1
  state = 0;
    5850:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    5852:	02500a13          	li	s4,37
      if(c == 'd'){
    5856:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    585a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    585e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    5862:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5866:	00003b97          	auipc	s7,0x3
    586a:	aa2b8b93          	addi	s7,s7,-1374 # 8308 <digits>
    586e:	a839                	j	588c <vprintf+0x6a>
        putc(fd, c);
    5870:	85ca                	mv	a1,s2
    5872:	8556                	mv	a0,s5
    5874:	00000097          	auipc	ra,0x0
    5878:	ee2080e7          	jalr	-286(ra) # 5756 <putc>
    587c:	a019                	j	5882 <vprintf+0x60>
    } else if(state == '%'){
    587e:	01498f63          	beq	s3,s4,589c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    5882:	0485                	addi	s1,s1,1
    5884:	fff4c903          	lbu	s2,-1(s1)
    5888:	14090d63          	beqz	s2,59e2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    588c:	0009079b          	sext.w	a5,s2
    if(state == 0){
    5890:	fe0997e3          	bnez	s3,587e <vprintf+0x5c>
      if(c == '%'){
    5894:	fd479ee3          	bne	a5,s4,5870 <vprintf+0x4e>
        state = '%';
    5898:	89be                	mv	s3,a5
    589a:	b7e5                	j	5882 <vprintf+0x60>
      if(c == 'd'){
    589c:	05878063          	beq	a5,s8,58dc <vprintf+0xba>
      } else if(c == 'l') {
    58a0:	05978c63          	beq	a5,s9,58f8 <vprintf+0xd6>
      } else if(c == 'x') {
    58a4:	07a78863          	beq	a5,s10,5914 <vprintf+0xf2>
      } else if(c == 'p') {
    58a8:	09b78463          	beq	a5,s11,5930 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    58ac:	07300713          	li	a4,115
    58b0:	0ce78663          	beq	a5,a4,597c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    58b4:	06300713          	li	a4,99
    58b8:	0ee78e63          	beq	a5,a4,59b4 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    58bc:	11478863          	beq	a5,s4,59cc <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    58c0:	85d2                	mv	a1,s4
    58c2:	8556                	mv	a0,s5
    58c4:	00000097          	auipc	ra,0x0
    58c8:	e92080e7          	jalr	-366(ra) # 5756 <putc>
        putc(fd, c);
    58cc:	85ca                	mv	a1,s2
    58ce:	8556                	mv	a0,s5
    58d0:	00000097          	auipc	ra,0x0
    58d4:	e86080e7          	jalr	-378(ra) # 5756 <putc>
      }
      state = 0;
    58d8:	4981                	li	s3,0
    58da:	b765                	j	5882 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    58dc:	008b0913          	addi	s2,s6,8
    58e0:	4685                	li	a3,1
    58e2:	4629                	li	a2,10
    58e4:	000b2583          	lw	a1,0(s6)
    58e8:	8556                	mv	a0,s5
    58ea:	00000097          	auipc	ra,0x0
    58ee:	e8e080e7          	jalr	-370(ra) # 5778 <printint>
    58f2:	8b4a                	mv	s6,s2
      state = 0;
    58f4:	4981                	li	s3,0
    58f6:	b771                	j	5882 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    58f8:	008b0913          	addi	s2,s6,8
    58fc:	4681                	li	a3,0
    58fe:	4629                	li	a2,10
    5900:	000b2583          	lw	a1,0(s6)
    5904:	8556                	mv	a0,s5
    5906:	00000097          	auipc	ra,0x0
    590a:	e72080e7          	jalr	-398(ra) # 5778 <printint>
    590e:	8b4a                	mv	s6,s2
      state = 0;
    5910:	4981                	li	s3,0
    5912:	bf85                	j	5882 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    5914:	008b0913          	addi	s2,s6,8
    5918:	4681                	li	a3,0
    591a:	4641                	li	a2,16
    591c:	000b2583          	lw	a1,0(s6)
    5920:	8556                	mv	a0,s5
    5922:	00000097          	auipc	ra,0x0
    5926:	e56080e7          	jalr	-426(ra) # 5778 <printint>
    592a:	8b4a                	mv	s6,s2
      state = 0;
    592c:	4981                	li	s3,0
    592e:	bf91                	j	5882 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5930:	008b0793          	addi	a5,s6,8
    5934:	f8f43423          	sd	a5,-120(s0)
    5938:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    593c:	03000593          	li	a1,48
    5940:	8556                	mv	a0,s5
    5942:	00000097          	auipc	ra,0x0
    5946:	e14080e7          	jalr	-492(ra) # 5756 <putc>
  putc(fd, 'x');
    594a:	85ea                	mv	a1,s10
    594c:	8556                	mv	a0,s5
    594e:	00000097          	auipc	ra,0x0
    5952:	e08080e7          	jalr	-504(ra) # 5756 <putc>
    5956:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5958:	03c9d793          	srli	a5,s3,0x3c
    595c:	97de                	add	a5,a5,s7
    595e:	0007c583          	lbu	a1,0(a5)
    5962:	8556                	mv	a0,s5
    5964:	00000097          	auipc	ra,0x0
    5968:	df2080e7          	jalr	-526(ra) # 5756 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    596c:	0992                	slli	s3,s3,0x4
    596e:	397d                	addiw	s2,s2,-1
    5970:	fe0914e3          	bnez	s2,5958 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    5974:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5978:	4981                	li	s3,0
    597a:	b721                	j	5882 <vprintf+0x60>
        s = va_arg(ap, char*);
    597c:	008b0993          	addi	s3,s6,8
    5980:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    5984:	02090163          	beqz	s2,59a6 <vprintf+0x184>
        while(*s != 0){
    5988:	00094583          	lbu	a1,0(s2)
    598c:	c9a1                	beqz	a1,59dc <vprintf+0x1ba>
          putc(fd, *s);
    598e:	8556                	mv	a0,s5
    5990:	00000097          	auipc	ra,0x0
    5994:	dc6080e7          	jalr	-570(ra) # 5756 <putc>
          s++;
    5998:	0905                	addi	s2,s2,1
        while(*s != 0){
    599a:	00094583          	lbu	a1,0(s2)
    599e:	f9e5                	bnez	a1,598e <vprintf+0x16c>
        s = va_arg(ap, char*);
    59a0:	8b4e                	mv	s6,s3
      state = 0;
    59a2:	4981                	li	s3,0
    59a4:	bdf9                	j	5882 <vprintf+0x60>
          s = "(null)";
    59a6:	00003917          	auipc	s2,0x3
    59aa:	95a90913          	addi	s2,s2,-1702 # 8300 <malloc+0x2814>
        while(*s != 0){
    59ae:	02800593          	li	a1,40
    59b2:	bff1                	j	598e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    59b4:	008b0913          	addi	s2,s6,8
    59b8:	000b4583          	lbu	a1,0(s6)
    59bc:	8556                	mv	a0,s5
    59be:	00000097          	auipc	ra,0x0
    59c2:	d98080e7          	jalr	-616(ra) # 5756 <putc>
    59c6:	8b4a                	mv	s6,s2
      state = 0;
    59c8:	4981                	li	s3,0
    59ca:	bd65                	j	5882 <vprintf+0x60>
        putc(fd, c);
    59cc:	85d2                	mv	a1,s4
    59ce:	8556                	mv	a0,s5
    59d0:	00000097          	auipc	ra,0x0
    59d4:	d86080e7          	jalr	-634(ra) # 5756 <putc>
      state = 0;
    59d8:	4981                	li	s3,0
    59da:	b565                	j	5882 <vprintf+0x60>
        s = va_arg(ap, char*);
    59dc:	8b4e                	mv	s6,s3
      state = 0;
    59de:	4981                	li	s3,0
    59e0:	b54d                	j	5882 <vprintf+0x60>
    }
  }
}
    59e2:	70e6                	ld	ra,120(sp)
    59e4:	7446                	ld	s0,112(sp)
    59e6:	74a6                	ld	s1,104(sp)
    59e8:	7906                	ld	s2,96(sp)
    59ea:	69e6                	ld	s3,88(sp)
    59ec:	6a46                	ld	s4,80(sp)
    59ee:	6aa6                	ld	s5,72(sp)
    59f0:	6b06                	ld	s6,64(sp)
    59f2:	7be2                	ld	s7,56(sp)
    59f4:	7c42                	ld	s8,48(sp)
    59f6:	7ca2                	ld	s9,40(sp)
    59f8:	7d02                	ld	s10,32(sp)
    59fa:	6de2                	ld	s11,24(sp)
    59fc:	6109                	addi	sp,sp,128
    59fe:	8082                	ret

0000000000005a00 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5a00:	715d                	addi	sp,sp,-80
    5a02:	ec06                	sd	ra,24(sp)
    5a04:	e822                	sd	s0,16(sp)
    5a06:	1000                	addi	s0,sp,32
    5a08:	e010                	sd	a2,0(s0)
    5a0a:	e414                	sd	a3,8(s0)
    5a0c:	e818                	sd	a4,16(s0)
    5a0e:	ec1c                	sd	a5,24(s0)
    5a10:	03043023          	sd	a6,32(s0)
    5a14:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    5a18:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5a1c:	8622                	mv	a2,s0
    5a1e:	00000097          	auipc	ra,0x0
    5a22:	e04080e7          	jalr	-508(ra) # 5822 <vprintf>
}
    5a26:	60e2                	ld	ra,24(sp)
    5a28:	6442                	ld	s0,16(sp)
    5a2a:	6161                	addi	sp,sp,80
    5a2c:	8082                	ret

0000000000005a2e <printf>:

void
printf(const char *fmt, ...)
{
    5a2e:	711d                	addi	sp,sp,-96
    5a30:	ec06                	sd	ra,24(sp)
    5a32:	e822                	sd	s0,16(sp)
    5a34:	1000                	addi	s0,sp,32
    5a36:	e40c                	sd	a1,8(s0)
    5a38:	e810                	sd	a2,16(s0)
    5a3a:	ec14                	sd	a3,24(s0)
    5a3c:	f018                	sd	a4,32(s0)
    5a3e:	f41c                	sd	a5,40(s0)
    5a40:	03043823          	sd	a6,48(s0)
    5a44:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5a48:	00840613          	addi	a2,s0,8
    5a4c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5a50:	85aa                	mv	a1,a0
    5a52:	4505                	li	a0,1
    5a54:	00000097          	auipc	ra,0x0
    5a58:	dce080e7          	jalr	-562(ra) # 5822 <vprintf>
}
    5a5c:	60e2                	ld	ra,24(sp)
    5a5e:	6442                	ld	s0,16(sp)
    5a60:	6125                	addi	sp,sp,96
    5a62:	8082                	ret

0000000000005a64 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5a64:	1141                	addi	sp,sp,-16
    5a66:	e422                	sd	s0,8(sp)
    5a68:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5a6a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5a6e:	00003797          	auipc	a5,0x3
    5a72:	8c27b783          	ld	a5,-1854(a5) # 8330 <freep>
    5a76:	a805                	j	5aa6 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5a78:	4618                	lw	a4,8(a2)
    5a7a:	9db9                	addw	a1,a1,a4
    5a7c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5a80:	6398                	ld	a4,0(a5)
    5a82:	6318                	ld	a4,0(a4)
    5a84:	fee53823          	sd	a4,-16(a0)
    5a88:	a091                	j	5acc <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5a8a:	ff852703          	lw	a4,-8(a0)
    5a8e:	9e39                	addw	a2,a2,a4
    5a90:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    5a92:	ff053703          	ld	a4,-16(a0)
    5a96:	e398                	sd	a4,0(a5)
    5a98:	a099                	j	5ade <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5a9a:	6398                	ld	a4,0(a5)
    5a9c:	00e7e463          	bltu	a5,a4,5aa4 <free+0x40>
    5aa0:	00e6ea63          	bltu	a3,a4,5ab4 <free+0x50>
{
    5aa4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5aa6:	fed7fae3          	bgeu	a5,a3,5a9a <free+0x36>
    5aaa:	6398                	ld	a4,0(a5)
    5aac:	00e6e463          	bltu	a3,a4,5ab4 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5ab0:	fee7eae3          	bltu	a5,a4,5aa4 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    5ab4:	ff852583          	lw	a1,-8(a0)
    5ab8:	6390                	ld	a2,0(a5)
    5aba:	02059813          	slli	a6,a1,0x20
    5abe:	01c85713          	srli	a4,a6,0x1c
    5ac2:	9736                	add	a4,a4,a3
    5ac4:	fae60ae3          	beq	a2,a4,5a78 <free+0x14>
    bp->s.ptr = p->s.ptr;
    5ac8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5acc:	4790                	lw	a2,8(a5)
    5ace:	02061593          	slli	a1,a2,0x20
    5ad2:	01c5d713          	srli	a4,a1,0x1c
    5ad6:	973e                	add	a4,a4,a5
    5ad8:	fae689e3          	beq	a3,a4,5a8a <free+0x26>
  } else
    p->s.ptr = bp;
    5adc:	e394                	sd	a3,0(a5)
  freep = p;
    5ade:	00003717          	auipc	a4,0x3
    5ae2:	84f73923          	sd	a5,-1966(a4) # 8330 <freep>
}
    5ae6:	6422                	ld	s0,8(sp)
    5ae8:	0141                	addi	sp,sp,16
    5aea:	8082                	ret

0000000000005aec <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5aec:	7139                	addi	sp,sp,-64
    5aee:	fc06                	sd	ra,56(sp)
    5af0:	f822                	sd	s0,48(sp)
    5af2:	f426                	sd	s1,40(sp)
    5af4:	f04a                	sd	s2,32(sp)
    5af6:	ec4e                	sd	s3,24(sp)
    5af8:	e852                	sd	s4,16(sp)
    5afa:	e456                	sd	s5,8(sp)
    5afc:	e05a                	sd	s6,0(sp)
    5afe:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5b00:	02051493          	slli	s1,a0,0x20
    5b04:	9081                	srli	s1,s1,0x20
    5b06:	04bd                	addi	s1,s1,15
    5b08:	8091                	srli	s1,s1,0x4
    5b0a:	0014899b          	addiw	s3,s1,1
    5b0e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    5b10:	00003517          	auipc	a0,0x3
    5b14:	82053503          	ld	a0,-2016(a0) # 8330 <freep>
    5b18:	c515                	beqz	a0,5b44 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5b1a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5b1c:	4798                	lw	a4,8(a5)
    5b1e:	02977f63          	bgeu	a4,s1,5b5c <malloc+0x70>
    5b22:	8a4e                	mv	s4,s3
    5b24:	0009871b          	sext.w	a4,s3
    5b28:	6685                	lui	a3,0x1
    5b2a:	00d77363          	bgeu	a4,a3,5b30 <malloc+0x44>
    5b2e:	6a05                	lui	s4,0x1
    5b30:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    5b34:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5b38:	00002917          	auipc	s2,0x2
    5b3c:	7f890913          	addi	s2,s2,2040 # 8330 <freep>
  if(p == (char*)-1)
    5b40:	5afd                	li	s5,-1
    5b42:	a895                	j	5bb6 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    5b44:	00009797          	auipc	a5,0x9
    5b48:	00c78793          	addi	a5,a5,12 # eb50 <base>
    5b4c:	00002717          	auipc	a4,0x2
    5b50:	7ef73223          	sd	a5,2020(a4) # 8330 <freep>
    5b54:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5b56:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5b5a:	b7e1                	j	5b22 <malloc+0x36>
      if(p->s.size == nunits)
    5b5c:	02e48c63          	beq	s1,a4,5b94 <malloc+0xa8>
        p->s.size -= nunits;
    5b60:	4137073b          	subw	a4,a4,s3
    5b64:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5b66:	02071693          	slli	a3,a4,0x20
    5b6a:	01c6d713          	srli	a4,a3,0x1c
    5b6e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5b70:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5b74:	00002717          	auipc	a4,0x2
    5b78:	7aa73e23          	sd	a0,1980(a4) # 8330 <freep>
      return (void*)(p + 1);
    5b7c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5b80:	70e2                	ld	ra,56(sp)
    5b82:	7442                	ld	s0,48(sp)
    5b84:	74a2                	ld	s1,40(sp)
    5b86:	7902                	ld	s2,32(sp)
    5b88:	69e2                	ld	s3,24(sp)
    5b8a:	6a42                	ld	s4,16(sp)
    5b8c:	6aa2                	ld	s5,8(sp)
    5b8e:	6b02                	ld	s6,0(sp)
    5b90:	6121                	addi	sp,sp,64
    5b92:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5b94:	6398                	ld	a4,0(a5)
    5b96:	e118                	sd	a4,0(a0)
    5b98:	bff1                	j	5b74 <malloc+0x88>
  hp->s.size = nu;
    5b9a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    5b9e:	0541                	addi	a0,a0,16
    5ba0:	00000097          	auipc	ra,0x0
    5ba4:	ec4080e7          	jalr	-316(ra) # 5a64 <free>
  return freep;
    5ba8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    5bac:	d971                	beqz	a0,5b80 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5bae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5bb0:	4798                	lw	a4,8(a5)
    5bb2:	fa9775e3          	bgeu	a4,s1,5b5c <malloc+0x70>
    if(p == freep)
    5bb6:	00093703          	ld	a4,0(s2)
    5bba:	853e                	mv	a0,a5
    5bbc:	fef719e3          	bne	a4,a5,5bae <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    5bc0:	8552                	mv	a0,s4
    5bc2:	00000097          	auipc	ra,0x0
    5bc6:	b64080e7          	jalr	-1180(ra) # 5726 <sbrk>
  if(p == (char*)-1)
    5bca:	fd5518e3          	bne	a0,s5,5b9a <malloc+0xae>
        return 0;
    5bce:	4501                	li	a0,0
    5bd0:	bf45                	j	5b80 <malloc+0x94>
