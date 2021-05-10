
user/_usertests_threads:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <run_forever>:
void error_exit_core(char *msg, int xstatus) {
  print_test_error(test_name, msg);
  exit(xstatus);
}

void run_forever() {
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
  int i = 0;
  while (1) {
       6:	a001                	j	6 <run_forever+0x6>

0000000000000008 <create_thread_exit_simple_other_thread_func>:
void thread_func_exec_sleep_1_xstatus_98() {
  sleep(1);
  exec(exec_argv[0], exec_argv);
}

void create_thread_exit_simple_other_thread_func() {
       8:	1141                	addi	sp,sp,-16
       a:	e406                	sd	ra,8(sp)
       c:	e022                	sd	s0,0(sp)
       e:	0800                	addi	s0,sp,16
  print("hello from other thread");
  kthread_exit(6);
      10:	4519                	li	a0,6
      12:	00001097          	auipc	ra,0x1
      16:	58c080e7          	jalr	1420(ra) # 159e <kthread_exit>
}
      1a:	60a2                	ld	ra,8(sp)
      1c:	6402                	ld	s0,0(sp)
      1e:	0141                	addi	sp,sp,16
      20:	8082                	ret

0000000000000022 <thread_func_exit_sleep_1_xstatus_98>:
void thread_func_exit_sleep_1_xstatus_98() {
      22:	1141                	addi	sp,sp,-16
      24:	e406                	sd	ra,8(sp)
      26:	e022                	sd	s0,0(sp)
      28:	0800                	addi	s0,sp,16
  sleep(1);
      2a:	4505                	li	a0,1
      2c:	00001097          	auipc	ra,0x1
      30:	53a080e7          	jalr	1338(ra) # 1566 <sleep>
  exit(98);
      34:	06200513          	li	a0,98
      38:	00001097          	auipc	ra,0x1
      3c:	49e080e7          	jalr	1182(ra) # 14d6 <exit>

0000000000000040 <thread_func_sleep_for_1_xstatus_7>:
void thread_func_sleep_for_1_xstatus_7() {
      40:	1141                	addi	sp,sp,-16
      42:	e406                	sd	ra,8(sp)
      44:	e022                	sd	s0,0(sp)
      46:	0800                	addi	s0,sp,16
    int my_tid = kthread_id();
      48:	00001097          	auipc	ra,0x1
      4c:	54e080e7          	jalr	1358(ra) # 1596 <kthread_id>
    sleep(1);
      50:	4505                	li	a0,1
      52:	00001097          	auipc	ra,0x1
      56:	514080e7          	jalr	1300(ra) # 1566 <sleep>
    shared++;
      5a:	00002717          	auipc	a4,0x2
      5e:	2fe70713          	addi	a4,a4,766 # 2358 <shared>
      62:	431c                	lw	a5,0(a4)
      64:	2785                	addiw	a5,a5,1
      66:	c31c                	sw	a5,0(a4)
    kthread_exit(7);
      68:	451d                	li	a0,7
      6a:	00001097          	auipc	ra,0x1
      6e:	534080e7          	jalr	1332(ra) # 159e <kthread_exit>
}
      72:	60a2                	ld	ra,8(sp)
      74:	6402                	ld	s0,0(sp)
      76:	0141                	addi	sp,sp,16
      78:	8082                	ret

000000000000007a <thread_func_exec_sleep_1_xstatus_98>:
void thread_func_exec_sleep_1_xstatus_98() {
      7a:	1141                	addi	sp,sp,-16
      7c:	e406                	sd	ra,8(sp)
      7e:	e022                	sd	s0,0(sp)
      80:	0800                	addi	s0,sp,16
  sleep(1);
      82:	4505                	li	a0,1
      84:	00001097          	auipc	ra,0x1
      88:	4e2080e7          	jalr	1250(ra) # 1566 <sleep>
  exec(exec_argv[0], exec_argv);
      8c:	00002597          	auipc	a1,0x2
      90:	10458593          	addi	a1,a1,260 # 2190 <exec_argv>
      94:	6188                	ld	a0,0(a1)
      96:	00001097          	auipc	ra,0x1
      9a:	478080e7          	jalr	1144(ra) # 150e <exec>
}
      9e:	60a2                	ld	ra,8(sp)
      a0:	6402                	ld	s0,0(sp)
      a2:	0141                	addi	sp,sp,16
      a4:	8082                	ret

00000000000000a6 <thread_func_run_forever>:
void thread_func_run_forever() {
      a6:	1141                	addi	sp,sp,-16
      a8:	e406                	sd	ra,8(sp)
      aa:	e022                	sd	s0,0(sp)
      ac:	0800                	addi	s0,sp,16
  int my_tid = kthread_id();
      ae:	00001097          	auipc	ra,0x1
      b2:	4e8080e7          	jalr	1256(ra) # 1596 <kthread_id>
  while (1) {
      b6:	a001                	j	b6 <thread_func_run_forever+0x10>

00000000000000b8 <print>:
void print(char *fmt, ...) {
      b8:	715d                	addi	sp,sp,-80
      ba:	e422                	sd	s0,8(sp)
      bc:	0800                	addi	s0,sp,16
      be:	e40c                	sd	a1,8(s0)
      c0:	e810                	sd	a2,16(s0)
      c2:	ec14                	sd	a3,24(s0)
      c4:	f018                	sd	a4,32(s0)
      c6:	f41c                	sd	a5,40(s0)
      c8:	03043823          	sd	a6,48(s0)
      cc:	03143c23          	sd	a7,56(s0)
}
      d0:	6422                	ld	s0,8(sp)
      d2:	6161                	addi	sp,sp,80
      d4:	8082                	ret

00000000000000d6 <run>:
int run(struct test *test) {
      d6:	7179                	addi	sp,sp,-48
      d8:	f406                	sd	ra,40(sp)
      da:	f022                	sd	s0,32(sp)
      dc:	ec26                	sd	s1,24(sp)
      de:	e84a                	sd	s2,16(sp)
      e0:	1800                	addi	s0,sp,48
      e2:	892a                	mv	s2,a0
  if (test->repeat_count <= 0) {
      e4:	494c                	lw	a1,20(a0)
      e6:	08b05863          	blez	a1,176 <run+0xa0>
  test_name = test->name;
      ea:	650c                	ld	a1,8(a0)
      ec:	00002797          	auipc	a5,0x2
      f0:	26b7ba23          	sd	a1,628(a5) # 2360 <test_name>
  expected_xstatus = test->expected_exit_status;
      f4:	491c                	lw	a5,16(a0)
      f6:	00002717          	auipc	a4,0x2
      fa:	26f72323          	sw	a5,614(a4) # 235c <expected_xstatus>
  printf("test %s:\n", test->name);
      fe:	00002517          	auipc	a0,0x2
     102:	b0a50513          	addi	a0,a0,-1270 # 1c08 <csem_free+0x94>
     106:	00001097          	auipc	ra,0x1
     10a:	7a2080e7          	jalr	1954(ra) # 18a8 <printf>
  for (int i = 0; i < test->repeat_count; i++) {
     10e:	01492783          	lw	a5,20(s2)
     112:	02f05b63          	blez	a5,148 <run+0x72>
     116:	4481                	li	s1,0
    if((pid = fork()) < 0) {
     118:	00001097          	auipc	ra,0x1
     11c:	3b6080e7          	jalr	950(ra) # 14ce <fork>
     120:	06054663          	bltz	a0,18c <run+0xb6>
    if(pid == 0) {
     124:	c149                	beqz	a0,1a6 <run+0xd0>
      wait(&xstatus);
     126:	fdc40513          	addi	a0,s0,-36
     12a:	00001097          	auipc	ra,0x1
     12e:	3b4080e7          	jalr	948(ra) # 14de <wait>
      if(xstatus != test->expected_exit_status) {
     132:	01092603          	lw	a2,16(s2)
     136:	fdc42583          	lw	a1,-36(s0)
     13a:	08b61063          	bne	a2,a1,1ba <run+0xe4>
  for (int i = 0; i < test->repeat_count; i++) {
     13e:	2485                	addiw	s1,s1,1
     140:	01492783          	lw	a5,20(s2)
     144:	fcf4cae3          	blt	s1,a5,118 <run+0x42>
  test_name = 0;
     148:	00002797          	auipc	a5,0x2
     14c:	2007bc23          	sd	zero,536(a5) # 2360 <test_name>
  expected_xstatus = 0;
     150:	00002797          	auipc	a5,0x2
     154:	2007a623          	sw	zero,524(a5) # 235c <expected_xstatus>
  printf("OK\n");
     158:	00002517          	auipc	a0,0x2
     15c:	b0050513          	addi	a0,a0,-1280 # 1c58 <csem_free+0xe4>
     160:	00001097          	auipc	ra,0x1
     164:	748080e7          	jalr	1864(ra) # 18a8 <printf>
  return 1;
     168:	4505                	li	a0,1
}
     16a:	70a2                	ld	ra,40(sp)
     16c:	7402                	ld	s0,32(sp)
     16e:	64e2                	ld	s1,24(sp)
     170:	6942                	ld	s2,16(sp)
     172:	6145                	addi	sp,sp,48
     174:	8082                	ret
    printf("RUN ERR: invalid repeat count (%d) for test %s. must be a positive value\n", test->repeat_count, test->name);
     176:	6510                	ld	a2,8(a0)
     178:	00002517          	auipc	a0,0x2
     17c:	a4050513          	addi	a0,a0,-1472 # 1bb8 <csem_free+0x44>
     180:	00001097          	auipc	ra,0x1
     184:	728080e7          	jalr	1832(ra) # 18a8 <printf>
    return 0;
     188:	4501                	li	a0,0
     18a:	b7c5                	j	16a <run+0x94>
      printf("runtest: fork error\n");
     18c:	00002517          	auipc	a0,0x2
     190:	a8c50513          	addi	a0,a0,-1396 # 1c18 <csem_free+0xa4>
     194:	00001097          	auipc	ra,0x1
     198:	714080e7          	jalr	1812(ra) # 18a8 <printf>
      exit(1);
     19c:	4505                	li	a0,1
     19e:	00001097          	auipc	ra,0x1
     1a2:	338080e7          	jalr	824(ra) # 14d6 <exit>
      test->f(test->name);
     1a6:	00093783          	ld	a5,0(s2)
     1aa:	00893503          	ld	a0,8(s2)
     1ae:	9782                	jalr	a5
      exit(0);
     1b0:	4501                	li	a0,0
     1b2:	00001097          	auipc	ra,0x1
     1b6:	324080e7          	jalr	804(ra) # 14d6 <exit>
        printf("FAILED with status %d, expected %d\n", xstatus, test->expected_exit_status);
     1ba:	00002517          	auipc	a0,0x2
     1be:	a7650513          	addi	a0,a0,-1418 # 1c30 <csem_free+0xbc>
     1c2:	00001097          	auipc	ra,0x1
     1c6:	6e6080e7          	jalr	1766(ra) # 18a8 <printf>
        return 0;
     1ca:	4501                	li	a0,0
     1cc:	bf79                	j	16a <run+0x94>

00000000000001ce <error_exit_core>:
void error_exit_core(char *msg, int xstatus) {
     1ce:	1101                	addi	sp,sp,-32
     1d0:	ec06                	sd	ra,24(sp)
     1d2:	e822                	sd	s0,16(sp)
     1d4:	e426                	sd	s1,8(sp)
     1d6:	1000                	addi	s0,sp,32
     1d8:	862a                	mv	a2,a0
     1da:	84ae                	mv	s1,a1
  print_test_error(test_name, msg);
     1dc:	00002597          	auipc	a1,0x2
     1e0:	1845b583          	ld	a1,388(a1) # 2360 <test_name>
     1e4:	00002517          	auipc	a0,0x2
     1e8:	a7c50513          	addi	a0,a0,-1412 # 1c60 <csem_free+0xec>
     1ec:	00001097          	auipc	ra,0x1
     1f0:	6bc080e7          	jalr	1724(ra) # 18a8 <printf>
  exit(xstatus);
     1f4:	8526                	mv	a0,s1
     1f6:	00001097          	auipc	ra,0x1
     1fa:	2e0080e7          	jalr	736(ra) # 14d6 <exit>

00000000000001fe <create_thread_exit_simple>:
void create_thread_exit_simple(char *s) {
     1fe:	1141                	addi	sp,sp,-16
     200:	e406                	sd	ra,8(sp)
     202:	e022                	sd	s0,0(sp)
     204:	0800                	addi	s0,sp,16
  void *stack = malloc(STACK_SIZE);
     206:	6505                	lui	a0,0x1
     208:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     20c:	00001097          	auipc	ra,0x1
     210:	75a080e7          	jalr	1882(ra) # 1966 <malloc>
     214:	85aa                	mv	a1,a0
  if (kthread_create(create_thread_exit_simple_other_thread_func, stack) < 0) {
     216:	00000517          	auipc	a0,0x0
     21a:	df250513          	addi	a0,a0,-526 # 8 <create_thread_exit_simple_other_thread_func>
     21e:	00001097          	auipc	ra,0x1
     222:	370080e7          	jalr	880(ra) # 158e <kthread_create>
     226:	00054b63          	bltz	a0,23c <create_thread_exit_simple+0x3e>
    error_exit_core("failed to create a thread", -2);
  }

  print("hello from main thread");
  kthread_exit(-3);
     22a:	5575                	li	a0,-3
     22c:	00001097          	auipc	ra,0x1
     230:	372080e7          	jalr	882(ra) # 159e <kthread_exit>
}
     234:	60a2                	ld	ra,8(sp)
     236:	6402                	ld	s0,0(sp)
     238:	0141                	addi	sp,sp,16
     23a:	8082                	ret
    error_exit_core("failed to create a thread", -2);
     23c:	55f9                	li	a1,-2
     23e:	00002517          	auipc	a0,0x2
     242:	a2a50513          	addi	a0,a0,-1494 # 1c68 <csem_free+0xf4>
     246:	00000097          	auipc	ra,0x0
     24a:	f88080e7          	jalr	-120(ra) # 1ce <error_exit_core>

000000000000024e <kthread_create_simple_func>:

void kthread_create_simple_func(void) {
     24e:	1101                	addi	sp,sp,-32
     250:	ec06                	sd	ra,24(sp)
     252:	e822                	sd	s0,16(sp)
     254:	1000                	addi	s0,sp,32
  char c;
  print("pipes other thread: %d, %d", pipe_fds[0], pipe_fds[1]);
  if (read(pipe_fds[0], &c, 1) != 1) {
     256:	4605                	li	a2,1
     258:	fef40593          	addi	a1,s0,-17
     25c:	00002517          	auipc	a0,0x2
     260:	11452503          	lw	a0,276(a0) # 2370 <pipe_fds>
     264:	00001097          	auipc	ra,0x1
     268:	28a080e7          	jalr	650(ra) # 14ee <read>
     26c:	4785                	li	a5,1
     26e:	02f51a63          	bne	a0,a5,2a2 <kthread_create_simple_func+0x54>
    error_exit_core("pipe read - other thread failed", -2);
  }

  print("hello from other thread");

  if (write(pipe_fds_2[1], "x", 1) < 0) {
     272:	4605                	li	a2,1
     274:	00002597          	auipc	a1,0x2
     278:	a3458593          	addi	a1,a1,-1484 # 1ca8 <csem_free+0x134>
     27c:	00002517          	auipc	a0,0x2
     280:	0f052503          	lw	a0,240(a0) # 236c <pipe_fds_2+0x4>
     284:	00001097          	auipc	ra,0x1
     288:	272080e7          	jalr	626(ra) # 14f6 <write>
     28c:	02054463          	bltz	a0,2b4 <kthread_create_simple_func+0x66>
    error_exit_core("pipe write - other thread failed", -3);
  }

  print("second thread exiting");
  kthread_exit(0);
     290:	4501                	li	a0,0
     292:	00001097          	auipc	ra,0x1
     296:	30c080e7          	jalr	780(ra) # 159e <kthread_exit>
}
     29a:	60e2                	ld	ra,24(sp)
     29c:	6442                	ld	s0,16(sp)
     29e:	6105                	addi	sp,sp,32
     2a0:	8082                	ret
    error_exit_core("pipe read - other thread failed", -2);
     2a2:	55f9                	li	a1,-2
     2a4:	00002517          	auipc	a0,0x2
     2a8:	9e450513          	addi	a0,a0,-1564 # 1c88 <csem_free+0x114>
     2ac:	00000097          	auipc	ra,0x0
     2b0:	f22080e7          	jalr	-222(ra) # 1ce <error_exit_core>
    error_exit_core("pipe write - other thread failed", -3);
     2b4:	55f5                	li	a1,-3
     2b6:	00002517          	auipc	a0,0x2
     2ba:	9fa50513          	addi	a0,a0,-1542 # 1cb0 <csem_free+0x13c>
     2be:	00000097          	auipc	ra,0x0
     2c2:	f10080e7          	jalr	-240(ra) # 1ce <error_exit_core>

00000000000002c6 <kthread_create_simple>:
void kthread_create_simple(char *s) {
     2c6:	1101                	addi	sp,sp,-32
     2c8:	ec06                	sd	ra,24(sp)
     2ca:	e822                	sd	s0,16(sp)
     2cc:	1000                	addi	s0,sp,32
  void *other_thread_user_stack_pointer;
  char c;
  if (pipe(pipe_fds) < 0) {
     2ce:	00002517          	auipc	a0,0x2
     2d2:	0a250513          	addi	a0,a0,162 # 2370 <pipe_fds>
     2d6:	00001097          	auipc	ra,0x1
     2da:	210080e7          	jalr	528(ra) # 14e6 <pipe>
     2de:	08054463          	bltz	a0,366 <kthread_create_simple+0xa0>
    error_exit_core("pipe failed", -4);
  }
  if (pipe(pipe_fds_2) < 0) {
     2e2:	00002517          	auipc	a0,0x2
     2e6:	08650513          	addi	a0,a0,134 # 2368 <pipe_fds_2>
     2ea:	00001097          	auipc	ra,0x1
     2ee:	1fc080e7          	jalr	508(ra) # 14e6 <pipe>
     2f2:	08054363          	bltz	a0,378 <kthread_create_simple+0xb2>
    error_exit_core("pipe 2 failed", -5);
  }
  print("pipes main thread: %d, %d", pipe_fds[0], pipe_fds[1]);
  if ((other_thread_user_stack_pointer = malloc(STACK_SIZE)) < 0) {
     2f6:	6505                	lui	a0,0x1
     2f8:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     2fc:	00001097          	auipc	ra,0x1
     300:	66a080e7          	jalr	1642(ra) # 1966 <malloc>
     304:	85aa                	mv	a1,a0
    error_exit_core("failed to allocate user stack", -6);
  }
  if (kthread_create(kthread_create_simple_func, other_thread_user_stack_pointer) < 0) {
     306:	00000517          	auipc	a0,0x0
     30a:	f4850513          	addi	a0,a0,-184 # 24e <kthread_create_simple_func>
     30e:	00001097          	auipc	ra,0x1
     312:	280080e7          	jalr	640(ra) # 158e <kthread_create>
     316:	06054a63          	bltz	a0,38a <kthread_create_simple+0xc4>
    error_exit_core("creating thread failed", -8);
  }

  if (write(pipe_fds[1], "x", 1) < 0) {
     31a:	4605                	li	a2,1
     31c:	00002597          	auipc	a1,0x2
     320:	98c58593          	addi	a1,a1,-1652 # 1ca8 <csem_free+0x134>
     324:	00002517          	auipc	a0,0x2
     328:	05052503          	lw	a0,80(a0) # 2374 <pipe_fds+0x4>
     32c:	00001097          	auipc	ra,0x1
     330:	1ca080e7          	jalr	458(ra) # 14f6 <write>
     334:	06054463          	bltz	a0,39c <kthread_create_simple+0xd6>
    error_exit_core("pipe write - main thread failed", -9);
  }
  
  print("main thread after write");
  if (read(pipe_fds_2[0], &c, 1) != 1) {
     338:	4605                	li	a2,1
     33a:	fef40593          	addi	a1,s0,-17
     33e:	00002517          	auipc	a0,0x2
     342:	02a52503          	lw	a0,42(a0) # 2368 <pipe_fds_2>
     346:	00001097          	auipc	ra,0x1
     34a:	1a8080e7          	jalr	424(ra) # 14ee <read>
     34e:	4785                	li	a5,1
     350:	04f51f63          	bne	a0,a5,3ae <kthread_create_simple+0xe8>
    error_exit_core("pipe read - main thread failed", -10);
  }
  
  kthread_exit(0);
     354:	4501                	li	a0,0
     356:	00001097          	auipc	ra,0x1
     35a:	248080e7          	jalr	584(ra) # 159e <kthread_exit>
}
     35e:	60e2                	ld	ra,24(sp)
     360:	6442                	ld	s0,16(sp)
     362:	6105                	addi	sp,sp,32
     364:	8082                	ret
    error_exit_core("pipe failed", -4);
     366:	55f1                	li	a1,-4
     368:	00002517          	auipc	a0,0x2
     36c:	97050513          	addi	a0,a0,-1680 # 1cd8 <csem_free+0x164>
     370:	00000097          	auipc	ra,0x0
     374:	e5e080e7          	jalr	-418(ra) # 1ce <error_exit_core>
    error_exit_core("pipe 2 failed", -5);
     378:	55ed                	li	a1,-5
     37a:	00002517          	auipc	a0,0x2
     37e:	96e50513          	addi	a0,a0,-1682 # 1ce8 <csem_free+0x174>
     382:	00000097          	auipc	ra,0x0
     386:	e4c080e7          	jalr	-436(ra) # 1ce <error_exit_core>
    error_exit_core("creating thread failed", -8);
     38a:	55e1                	li	a1,-8
     38c:	00002517          	auipc	a0,0x2
     390:	96c50513          	addi	a0,a0,-1684 # 1cf8 <csem_free+0x184>
     394:	00000097          	auipc	ra,0x0
     398:	e3a080e7          	jalr	-454(ra) # 1ce <error_exit_core>
    error_exit_core("pipe write - main thread failed", -9);
     39c:	55dd                	li	a1,-9
     39e:	00002517          	auipc	a0,0x2
     3a2:	97250513          	addi	a0,a0,-1678 # 1d10 <csem_free+0x19c>
     3a6:	00000097          	auipc	ra,0x0
     3aa:	e28080e7          	jalr	-472(ra) # 1ce <error_exit_core>
    error_exit_core("pipe read - main thread failed", -10);
     3ae:	55d9                	li	a1,-10
     3b0:	00002517          	auipc	a0,0x2
     3b4:	98050513          	addi	a0,a0,-1664 # 1d30 <csem_free+0x1bc>
     3b8:	00000097          	auipc	ra,0x0
     3bc:	e16080e7          	jalr	-490(ra) # 1ce <error_exit_core>

00000000000003c0 <join_simple>:

void join_simple(char *s) {
     3c0:	7179                	addi	sp,sp,-48
     3c2:	f406                	sd	ra,40(sp)
     3c4:	f022                	sd	s0,32(sp)
     3c6:	ec26                	sd	s1,24(sp)
     3c8:	1800                	addi	s0,sp,48
  int other_tid;
  int xstatus;
  void *stack = malloc(STACK_SIZE);
     3ca:	6505                	lui	a0,0x1
     3cc:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     3d0:	00001097          	auipc	ra,0x1
     3d4:	596080e7          	jalr	1430(ra) # 1966 <malloc>
     3d8:	84aa                	mv	s1,a0
  other_tid = kthread_create(thread_func_run_for_5_xstatus_74, stack);
     3da:	85aa                	mv	a1,a0
     3dc:	00001517          	auipc	a0,0x1
     3e0:	cb050513          	addi	a0,a0,-848 # 108c <thread_func_run_for_5_xstatus_74>
     3e4:	00001097          	auipc	ra,0x1
     3e8:	1aa080e7          	jalr	426(ra) # 158e <kthread_create>
  if (other_tid < 0) {
     3ec:	02054963          	bltz	a0,41e <join_simple+0x5e>
    error_exit_core("kthread_create failed", -2);
  }

  print("created thread %d", other_tid);
  if (kthread_join(other_tid, &xstatus) < 0) {
     3f0:	fdc40593          	addi	a1,s0,-36
     3f4:	00001097          	auipc	ra,0x1
     3f8:	1b2080e7          	jalr	434(ra) # 15a6 <kthread_join>
     3fc:	02054a63          	bltz	a0,430 <join_simple+0x70>
    error_exit_core("join failed", -3);
  }

  free(stack);
     400:	8526                	mv	a0,s1
     402:	00001097          	auipc	ra,0x1
     406:	4dc080e7          	jalr	1244(ra) # 18de <free>
  print("joined with thread %d, xstatus: %d", other_tid, xstatus);
  kthread_exit(-3);
     40a:	5575                	li	a0,-3
     40c:	00001097          	auipc	ra,0x1
     410:	192080e7          	jalr	402(ra) # 159e <kthread_exit>
}
     414:	70a2                	ld	ra,40(sp)
     416:	7402                	ld	s0,32(sp)
     418:	64e2                	ld	s1,24(sp)
     41a:	6145                	addi	sp,sp,48
     41c:	8082                	ret
    error_exit_core("kthread_create failed", -2);
     41e:	55f9                	li	a1,-2
     420:	00002517          	auipc	a0,0x2
     424:	93050513          	addi	a0,a0,-1744 # 1d50 <csem_free+0x1dc>
     428:	00000097          	auipc	ra,0x0
     42c:	da6080e7          	jalr	-602(ra) # 1ce <error_exit_core>
    error_exit_core("join failed", -3);
     430:	55f5                	li	a1,-3
     432:	00002517          	auipc	a0,0x2
     436:	93650513          	addi	a0,a0,-1738 # 1d68 <csem_free+0x1f4>
     43a:	00000097          	auipc	ra,0x0
     43e:	d94080e7          	jalr	-620(ra) # 1ce <error_exit_core>

0000000000000442 <join_self>:

void join_self(char *s) {
     442:	7179                	addi	sp,sp,-48
     444:	f406                	sd	ra,40(sp)
     446:	f022                	sd	s0,32(sp)
     448:	ec26                	sd	s1,24(sp)
     44a:	e84a                	sd	s2,16(sp)
     44c:	1800                	addi	s0,sp,48
  int xstatus;
  int other_tid;
  void *stack = malloc(STACK_SIZE);
     44e:	6505                	lui	a0,0x1
     450:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     454:	00001097          	auipc	ra,0x1
     458:	512080e7          	jalr	1298(ra) # 1966 <malloc>
     45c:	84aa                	mv	s1,a0
  int my_tid = kthread_id();
     45e:	00001097          	auipc	ra,0x1
     462:	138080e7          	jalr	312(ra) # 1596 <kthread_id>
     466:	892a                	mv	s2,a0
  print("thread %d started", my_tid);
  other_tid = kthread_create(thread_func_run_for_5_xstatus_74, stack);
     468:	85a6                	mv	a1,s1
     46a:	00001517          	auipc	a0,0x1
     46e:	c2250513          	addi	a0,a0,-990 # 108c <thread_func_run_for_5_xstatus_74>
     472:	00001097          	auipc	ra,0x1
     476:	11c080e7          	jalr	284(ra) # 158e <kthread_create>
  if (other_tid < 0) {
     47a:	04054263          	bltz	a0,4be <join_self+0x7c>
    error_exit_core("kthread_create failed", -2);
  }
  print("created thread %d", other_tid);
  if (kthread_join(other_tid, &xstatus) < 0) {
     47e:	fdc40593          	addi	a1,s0,-36
     482:	00001097          	auipc	ra,0x1
     486:	124080e7          	jalr	292(ra) # 15a6 <kthread_join>
     48a:	04054363          	bltz	a0,4d0 <join_self+0x8e>
    error_exit_core("join failed", -3);
  }
  if (kthread_join(my_tid, &xstatus) == 0) {
     48e:	fdc40593          	addi	a1,s0,-36
     492:	854a                	mv	a0,s2
     494:	00001097          	auipc	ra,0x1
     498:	112080e7          	jalr	274(ra) # 15a6 <kthread_join>
     49c:	c139                	beqz	a0,4e2 <join_self+0xa0>
    error_exit_core("join with self succeeded", -4);
  }
  
  free(stack);
     49e:	8526                	mv	a0,s1
     4a0:	00001097          	auipc	ra,0x1
     4a4:	43e080e7          	jalr	1086(ra) # 18de <free>
  kthread_exit(-7);
     4a8:	5565                	li	a0,-7
     4aa:	00001097          	auipc	ra,0x1
     4ae:	0f4080e7          	jalr	244(ra) # 159e <kthread_exit>
}
     4b2:	70a2                	ld	ra,40(sp)
     4b4:	7402                	ld	s0,32(sp)
     4b6:	64e2                	ld	s1,24(sp)
     4b8:	6942                	ld	s2,16(sp)
     4ba:	6145                	addi	sp,sp,48
     4bc:	8082                	ret
    error_exit_core("kthread_create failed", -2);
     4be:	55f9                	li	a1,-2
     4c0:	00002517          	auipc	a0,0x2
     4c4:	89050513          	addi	a0,a0,-1904 # 1d50 <csem_free+0x1dc>
     4c8:	00000097          	auipc	ra,0x0
     4cc:	d06080e7          	jalr	-762(ra) # 1ce <error_exit_core>
    error_exit_core("join failed", -3);
     4d0:	55f5                	li	a1,-3
     4d2:	00002517          	auipc	a0,0x2
     4d6:	89650513          	addi	a0,a0,-1898 # 1d68 <csem_free+0x1f4>
     4da:	00000097          	auipc	ra,0x0
     4de:	cf4080e7          	jalr	-780(ra) # 1ce <error_exit_core>
    error_exit_core("join with self succeeded", -4);
     4e2:	55f1                	li	a1,-4
     4e4:	00002517          	auipc	a0,0x2
     4e8:	89450513          	addi	a0,a0,-1900 # 1d78 <csem_free+0x204>
     4ec:	00000097          	auipc	ra,0x0
     4f0:	ce2080e7          	jalr	-798(ra) # 1ce <error_exit_core>

00000000000004f4 <exit_multiple_threads>:

void exit_multiple_threads(char *s) {
     4f4:	1141                	addi	sp,sp,-16
     4f6:	e406                	sd	ra,8(sp)
     4f8:	e022                	sd	s0,0(sp)
     4fa:	0800                	addi	s0,sp,16
  int other_tid;
  
  void *stack, *stack2;
  int my_tid = kthread_id();
     4fc:	00001097          	auipc	ra,0x1
     500:	09a080e7          	jalr	154(ra) # 1596 <kthread_id>
  print("thread %d started", my_tid);

  stack = malloc(STACK_SIZE);
     504:	6505                	lui	a0,0x1
     506:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     50a:	00001097          	auipc	ra,0x1
     50e:	45c080e7          	jalr	1116(ra) # 1966 <malloc>
     512:	85aa                	mv	a1,a0
  other_tid = kthread_create(thread_func_run_forever, stack);
     514:	00000517          	auipc	a0,0x0
     518:	b9250513          	addi	a0,a0,-1134 # a6 <thread_func_run_forever>
     51c:	00001097          	auipc	ra,0x1
     520:	072080e7          	jalr	114(ra) # 158e <kthread_create>
  if (other_tid < 0) {
     524:	02054e63          	bltz	a0,560 <exit_multiple_threads+0x6c>
    error_exit("kthread_create failed");
  }
  print("created thread %d", other_tid);
  stack2 = malloc(STACK_SIZE);
     528:	6505                	lui	a0,0x1
     52a:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     52e:	00001097          	auipc	ra,0x1
     532:	438080e7          	jalr	1080(ra) # 1966 <malloc>
     536:	85aa                	mv	a1,a0
  other_tid = kthread_create(thread_func_run_forever, stack2);
     538:	00000517          	auipc	a0,0x0
     53c:	b6e50513          	addi	a0,a0,-1170 # a6 <thread_func_run_forever>
     540:	00001097          	auipc	ra,0x1
     544:	04e080e7          	jalr	78(ra) # 158e <kthread_create>
  if (other_tid < 0) {
     548:	02054563          	bltz	a0,572 <exit_multiple_threads+0x7e>
    error_exit("kthread_create failed");
  }
  print("created thread %d", other_tid);
  sleep(2);
     54c:	4509                	li	a0,2
     54e:	00001097          	auipc	ra,0x1
     552:	018080e7          	jalr	24(ra) # 1566 <sleep>
  print("exiting...");
  
  exit(9);
     556:	4525                	li	a0,9
     558:	00001097          	auipc	ra,0x1
     55c:	f7e080e7          	jalr	-130(ra) # 14d6 <exit>
    error_exit("kthread_create failed");
     560:	55fd                	li	a1,-1
     562:	00001517          	auipc	a0,0x1
     566:	7ee50513          	addi	a0,a0,2030 # 1d50 <csem_free+0x1dc>
     56a:	00000097          	auipc	ra,0x0
     56e:	c64080e7          	jalr	-924(ra) # 1ce <error_exit_core>
    error_exit("kthread_create failed");
     572:	55fd                	li	a1,-1
     574:	00001517          	auipc	a0,0x1
     578:	7dc50513          	addi	a0,a0,2012 # 1d50 <csem_free+0x1dc>
     57c:	00000097          	auipc	ra,0x0
     580:	c52080e7          	jalr	-942(ra) # 1ce <error_exit_core>

0000000000000584 <max_threads_exit>:
}

void max_threads_exit(char *s) {
     584:	7179                	addi	sp,sp,-48
     586:	f406                	sd	ra,40(sp)
     588:	f022                	sd	s0,32(sp)
     58a:	ec26                	sd	s1,24(sp)
     58c:	e84a                	sd	s2,16(sp)
     58e:	e44e                	sd	s3,8(sp)
     590:	1800                	addi	s0,sp,48
  void *stacks[NTHREAD - 1];
  int tids[NTHREAD - 1];
  void *last_stack;
  int my_tid = kthread_id();
     592:	00001097          	auipc	ra,0x1
     596:	004080e7          	jalr	4(ra) # 1596 <kthread_id>
     59a:	449d                	li	s1,7

  print("thread %d started", my_tid);
  for (int i = 0; i < NTHREAD - 1; i++) {
    stacks[i] = malloc(STACK_SIZE);
     59c:	6905                	lui	s2,0x1
     59e:	fa090913          	addi	s2,s2,-96 # fa0 <max_threads_fork+0x74>
    if (stacks[i] < 0) {
      error_exit("malloc failed");
    }
    tids[i] = kthread_create(thread_func_run_forever, stacks[i]);
     5a2:	00000997          	auipc	s3,0x0
     5a6:	b0498993          	addi	s3,s3,-1276 # a6 <thread_func_run_forever>
    stacks[i] = malloc(STACK_SIZE);
     5aa:	854a                	mv	a0,s2
     5ac:	00001097          	auipc	ra,0x1
     5b0:	3ba080e7          	jalr	954(ra) # 1966 <malloc>
     5b4:	85aa                	mv	a1,a0
    tids[i] = kthread_create(thread_func_run_forever, stacks[i]);
     5b6:	854e                	mv	a0,s3
     5b8:	00001097          	auipc	ra,0x1
     5bc:	fd6080e7          	jalr	-42(ra) # 158e <kthread_create>
    if (tids[i] < 0) {
     5c0:	04054063          	bltz	a0,600 <max_threads_exit+0x7c>
  for (int i = 0; i < NTHREAD - 1; i++) {
     5c4:	34fd                	addiw	s1,s1,-1
     5c6:	f0f5                	bnez	s1,5aa <max_threads_exit+0x26>
    }

    print("created thread %d", tids[i]);
  }

  if ((last_stack = malloc(STACK_SIZE)) < 0) {
     5c8:	6505                	lui	a0,0x1
     5ca:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     5ce:	00001097          	auipc	ra,0x1
     5d2:	398080e7          	jalr	920(ra) # 1966 <malloc>
     5d6:	84aa                	mv	s1,a0
    error_exit("last malloc failed");
  }
  if (kthread_create(thread_func_run_forever, last_stack) >= 0) {
     5d8:	85aa                	mv	a1,a0
     5da:	00000517          	auipc	a0,0x0
     5de:	acc50513          	addi	a0,a0,-1332 # a6 <thread_func_run_forever>
     5e2:	00001097          	auipc	ra,0x1
     5e6:	fac080e7          	jalr	-84(ra) # 158e <kthread_create>
     5ea:	02054463          	bltz	a0,612 <max_threads_exit+0x8e>
    error_exit("created too many threads");
     5ee:	55fd                	li	a1,-1
     5f0:	00001517          	auipc	a0,0x1
     5f4:	7a850513          	addi	a0,a0,1960 # 1d98 <csem_free+0x224>
     5f8:	00000097          	auipc	ra,0x0
     5fc:	bd6080e7          	jalr	-1066(ra) # 1ce <error_exit_core>
      error_exit("kthread_create failed");
     600:	55fd                	li	a1,-1
     602:	00001517          	auipc	a0,0x1
     606:	74e50513          	addi	a0,a0,1870 # 1d50 <csem_free+0x1dc>
     60a:	00000097          	auipc	ra,0x0
     60e:	bc4080e7          	jalr	-1084(ra) # 1ce <error_exit_core>
  }
  if (kthread_create(thread_func_run_forever, last_stack) >= 0) {
     612:	85a6                	mv	a1,s1
     614:	00000517          	auipc	a0,0x0
     618:	a9250513          	addi	a0,a0,-1390 # a6 <thread_func_run_forever>
     61c:	00001097          	auipc	ra,0x1
     620:	f72080e7          	jalr	-142(ra) # 158e <kthread_create>
     624:	00054b63          	bltz	a0,63a <max_threads_exit+0xb6>
    error_exit("created too many threads 2");
     628:	55fd                	li	a1,-1
     62a:	00001517          	auipc	a0,0x1
     62e:	78e50513          	addi	a0,a0,1934 # 1db8 <csem_free+0x244>
     632:	00000097          	auipc	ra,0x0
     636:	b9c080e7          	jalr	-1124(ra) # 1ce <error_exit_core>
  }
  free(last_stack);
     63a:	8526                	mv	a0,s1
     63c:	00001097          	auipc	ra,0x1
     640:	2a2080e7          	jalr	674(ra) # 18de <free>
  
  print("going to sleep");
  sleep(5);
     644:	4515                	li	a0,5
     646:	00001097          	auipc	ra,0x1
     64a:	f20080e7          	jalr	-224(ra) # 1566 <sleep>
  print("exiting...");
  exit(8);
     64e:	4521                	li	a0,8
     650:	00001097          	auipc	ra,0x1
     654:	e86080e7          	jalr	-378(ra) # 14d6 <exit>

0000000000000658 <max_threads_exit_they_exit_after_1>:
}

void max_threads_exit_they_exit_after_1(char *s) {
     658:	7179                	addi	sp,sp,-48
     65a:	f406                	sd	ra,40(sp)
     65c:	f022                	sd	s0,32(sp)
     65e:	ec26                	sd	s1,24(sp)
     660:	e84a                	sd	s2,16(sp)
     662:	e44e                	sd	s3,8(sp)
     664:	1800                	addi	s0,sp,48
  void *stacks[NTHREAD - 1];
  int tids[NTHREAD - 1];
  void *last_stack;
  int my_tid = kthread_id();
     666:	00001097          	auipc	ra,0x1
     66a:	f30080e7          	jalr	-208(ra) # 1596 <kthread_id>
     66e:	449d                	li	s1,7

  print("thread %d started", my_tid);
  for (int i = 0; i < NTHREAD - 1; i++) {
    stacks[i] = malloc(STACK_SIZE);
     670:	6905                	lui	s2,0x1
     672:	fa090913          	addi	s2,s2,-96 # fa0 <max_threads_fork+0x74>
    if (stacks[i] < 0) {
      error_exit("malloc failed");
    }
    tids[i] = kthread_create(thread_func_sleep_for_1_xstatus_7, stacks[i]);
     676:	00000997          	auipc	s3,0x0
     67a:	9ca98993          	addi	s3,s3,-1590 # 40 <thread_func_sleep_for_1_xstatus_7>
    stacks[i] = malloc(STACK_SIZE);
     67e:	854a                	mv	a0,s2
     680:	00001097          	auipc	ra,0x1
     684:	2e6080e7          	jalr	742(ra) # 1966 <malloc>
     688:	85aa                	mv	a1,a0
    tids[i] = kthread_create(thread_func_sleep_for_1_xstatus_7, stacks[i]);
     68a:	854e                	mv	a0,s3
     68c:	00001097          	auipc	ra,0x1
     690:	f02080e7          	jalr	-254(ra) # 158e <kthread_create>
    if (tids[i] < 0) {
     694:	04054063          	bltz	a0,6d4 <max_threads_exit_they_exit_after_1+0x7c>
  for (int i = 0; i < NTHREAD - 1; i++) {
     698:	34fd                	addiw	s1,s1,-1
     69a:	f0f5                	bnez	s1,67e <max_threads_exit_they_exit_after_1+0x26>
    }

    print("created thread %d", tids[i]);
  }

  if ((last_stack = malloc(STACK_SIZE)) < 0) {
     69c:	6505                	lui	a0,0x1
     69e:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     6a2:	00001097          	auipc	ra,0x1
     6a6:	2c4080e7          	jalr	708(ra) # 1966 <malloc>
     6aa:	84aa                	mv	s1,a0
    error_exit("last malloc failed");
  }
  if (kthread_create(thread_func_sleep_for_1_xstatus_7, last_stack) >= 0) {
     6ac:	85aa                	mv	a1,a0
     6ae:	00000517          	auipc	a0,0x0
     6b2:	99250513          	addi	a0,a0,-1646 # 40 <thread_func_sleep_for_1_xstatus_7>
     6b6:	00001097          	auipc	ra,0x1
     6ba:	ed8080e7          	jalr	-296(ra) # 158e <kthread_create>
     6be:	02054463          	bltz	a0,6e6 <max_threads_exit_they_exit_after_1+0x8e>
    error_exit("created too many threads");
     6c2:	55fd                	li	a1,-1
     6c4:	00001517          	auipc	a0,0x1
     6c8:	6d450513          	addi	a0,a0,1748 # 1d98 <csem_free+0x224>
     6cc:	00000097          	auipc	ra,0x0
     6d0:	b02080e7          	jalr	-1278(ra) # 1ce <error_exit_core>
      error_exit("kthread_create failed");
     6d4:	55fd                	li	a1,-1
     6d6:	00001517          	auipc	a0,0x1
     6da:	67a50513          	addi	a0,a0,1658 # 1d50 <csem_free+0x1dc>
     6de:	00000097          	auipc	ra,0x0
     6e2:	af0080e7          	jalr	-1296(ra) # 1ce <error_exit_core>
  }
  if (kthread_create(thread_func_sleep_for_1_xstatus_7, last_stack) >= 0) {
     6e6:	85a6                	mv	a1,s1
     6e8:	00000517          	auipc	a0,0x0
     6ec:	95850513          	addi	a0,a0,-1704 # 40 <thread_func_sleep_for_1_xstatus_7>
     6f0:	00001097          	auipc	ra,0x1
     6f4:	e9e080e7          	jalr	-354(ra) # 158e <kthread_create>
     6f8:	00054b63          	bltz	a0,70e <max_threads_exit_they_exit_after_1+0xb6>
    error_exit("created too many threads 2");
     6fc:	55fd                	li	a1,-1
     6fe:	00001517          	auipc	a0,0x1
     702:	6ba50513          	addi	a0,a0,1722 # 1db8 <csem_free+0x244>
     706:	00000097          	auipc	ra,0x0
     70a:	ac8080e7          	jalr	-1336(ra) # 1ce <error_exit_core>
  }
  free(last_stack);
     70e:	8526                	mv	a0,s1
     710:	00001097          	auipc	ra,0x1
     714:	1ce080e7          	jalr	462(ra) # 18de <free>
  
  print("going to sleep");
  sleep(5);
     718:	4515                	li	a0,5
     71a:	00001097          	auipc	ra,0x1
     71e:	e4c080e7          	jalr	-436(ra) # 1566 <sleep>
  print("exiting...");
  exit(8);
     722:	4521                	li	a0,8
     724:	00001097          	auipc	ra,0x1
     728:	db2080e7          	jalr	-590(ra) # 14d6 <exit>

000000000000072c <max_threads_exit_by_created_they_run_forever>:
}

void max_threads_exit_by_created_they_run_forever(char *s) {
     72c:	7139                	addi	sp,sp,-64
     72e:	fc06                	sd	ra,56(sp)
     730:	f822                	sd	s0,48(sp)
     732:	f426                	sd	s1,40(sp)
     734:	f04a                	sd	s2,32(sp)
     736:	ec4e                	sd	s3,24(sp)
     738:	e852                	sd	s4,16(sp)
     73a:	e456                	sd	s5,8(sp)
     73c:	0080                	addi	s0,sp,64
  void *stacks[NTHREAD - 1];
  int tids[NTHREAD - 1];
  void *last_stack;
  int my_tid = kthread_id();
     73e:	00001097          	auipc	ra,0x1
     742:	e58080e7          	jalr	-424(ra) # 1596 <kthread_id>
     746:	4485                	li	s1,1

  print("thread %d started", my_tid);
  for (int i = 0; i < NTHREAD - 1; i++) {
    void (*f)();
    stacks[i] = malloc(STACK_SIZE);
     748:	6985                	lui	s3,0x1
     74a:	fa098993          	addi	s3,s3,-96 # fa0 <max_threads_fork+0x74>
    if (stacks[i] < 0) {
      error_exit("malloc failed");
    }
    if (i == 5) {
     74e:	4919                	li	s2,6
      f = thread_func_exit_sleep_1_xstatus_98;
    }
    else {
      f = run_forever;
    }
    tids[i] = kthread_create(f, stacks[i]);
     750:	00000a97          	auipc	s5,0x0
     754:	8d2a8a93          	addi	s5,s5,-1838 # 22 <thread_func_exit_sleep_1_xstatus_98>
     758:	00000a17          	auipc	s4,0x0
     75c:	8a8a0a13          	addi	s4,s4,-1880 # 0 <run_forever>
     760:	a805                	j	790 <max_threads_exit_by_created_they_run_forever+0x64>
    if (tids[i] < 0) {
      error_exit("kthread_create failed");
     762:	55fd                	li	a1,-1
     764:	00001517          	auipc	a0,0x1
     768:	5ec50513          	addi	a0,a0,1516 # 1d50 <csem_free+0x1dc>
     76c:	00000097          	auipc	ra,0x0
     770:	a62080e7          	jalr	-1438(ra) # 1ce <error_exit_core>
    error_exit("last malloc failed");
  }
  if (kthread_create(thread_func_sleep_for_1_xstatus_7, last_stack) >= 0) {
    error_exit("created too many threads");
  }
  free(last_stack);
     774:	8526                	mv	a0,s1
     776:	00001097          	auipc	ra,0x1
     77a:	168080e7          	jalr	360(ra) # 18de <free>
  while (1) {
     77e:	a001                	j	77e <max_threads_exit_by_created_they_run_forever+0x52>
    tids[i] = kthread_create(f, stacks[i]);
     780:	8556                	mv	a0,s5
     782:	00001097          	auipc	ra,0x1
     786:	e0c080e7          	jalr	-500(ra) # 158e <kthread_create>
    if (tids[i] < 0) {
     78a:	fc054ce3          	bltz	a0,762 <max_threads_exit_by_created_they_run_forever+0x36>
     78e:	2485                	addiw	s1,s1,1
    stacks[i] = malloc(STACK_SIZE);
     790:	854e                	mv	a0,s3
     792:	00001097          	auipc	ra,0x1
     796:	1d4080e7          	jalr	468(ra) # 1966 <malloc>
     79a:	85aa                	mv	a1,a0
    if (i == 5) {
     79c:	ff2482e3          	beq	s1,s2,780 <max_threads_exit_by_created_they_run_forever+0x54>
    tids[i] = kthread_create(f, stacks[i]);
     7a0:	8552                	mv	a0,s4
     7a2:	00001097          	auipc	ra,0x1
     7a6:	dec080e7          	jalr	-532(ra) # 158e <kthread_create>
    if (tids[i] < 0) {
     7aa:	fa054ce3          	bltz	a0,762 <max_threads_exit_by_created_they_run_forever+0x36>
  for (int i = 0; i < NTHREAD - 1; i++) {
     7ae:	0004879b          	sext.w	a5,s1
     7b2:	fcf95ee3          	bge	s2,a5,78e <max_threads_exit_by_created_they_run_forever+0x62>
  if ((last_stack = malloc(STACK_SIZE)) < 0) {
     7b6:	6505                	lui	a0,0x1
     7b8:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     7bc:	00001097          	auipc	ra,0x1
     7c0:	1aa080e7          	jalr	426(ra) # 1966 <malloc>
     7c4:	84aa                	mv	s1,a0
  if (kthread_create(thread_func_sleep_for_1_xstatus_7, last_stack) >= 0) {
     7c6:	85aa                	mv	a1,a0
     7c8:	00000517          	auipc	a0,0x0
     7cc:	87850513          	addi	a0,a0,-1928 # 40 <thread_func_sleep_for_1_xstatus_7>
     7d0:	00001097          	auipc	ra,0x1
     7d4:	dbe080e7          	jalr	-578(ra) # 158e <kthread_create>
     7d8:	f8054ee3          	bltz	a0,774 <max_threads_exit_by_created_they_run_forever+0x48>
    error_exit("created too many threads");
     7dc:	55fd                	li	a1,-1
     7de:	00001517          	auipc	a0,0x1
     7e2:	5ba50513          	addi	a0,a0,1466 # 1d98 <csem_free+0x224>
     7e6:	00000097          	auipc	ra,0x0
     7ea:	9e8080e7          	jalr	-1560(ra) # 1ce <error_exit_core>

00000000000007ee <max_threads_exit_by_created_they_exit_after_1>:
  
  run_forever();
  kthread_exit(8);
}

void max_threads_exit_by_created_they_exit_after_1(char *s) {
     7ee:	7139                	addi	sp,sp,-64
     7f0:	fc06                	sd	ra,56(sp)
     7f2:	f822                	sd	s0,48(sp)
     7f4:	f426                	sd	s1,40(sp)
     7f6:	f04a                	sd	s2,32(sp)
     7f8:	ec4e                	sd	s3,24(sp)
     7fa:	e852                	sd	s4,16(sp)
     7fc:	e456                	sd	s5,8(sp)
     7fe:	0080                	addi	s0,sp,64
  void *stacks[NTHREAD - 1];
  int tids[NTHREAD - 1];
  void *last_stack;
  int my_tid = kthread_id();
     800:	00001097          	auipc	ra,0x1
     804:	d96080e7          	jalr	-618(ra) # 1596 <kthread_id>
     808:	4485                	li	s1,1

  print("thread %d started", my_tid);
  for (int i = 0; i < NTHREAD - 1; i++) {
    void (*f)();
    stacks[i] = malloc(STACK_SIZE);
     80a:	6985                	lui	s3,0x1
     80c:	fa098993          	addi	s3,s3,-96 # fa0 <max_threads_fork+0x74>
    if (stacks[i] < 0) {
      error_exit("malloc failed");
    }
    if (i == 5) {
     810:	4919                	li	s2,6
      f = thread_func_exit_sleep_1_xstatus_98;
    }
    else {
      f = thread_func_sleep_for_1_xstatus_7;
    }
    tids[i] = kthread_create(f, stacks[i]);
     812:	00000a97          	auipc	s5,0x0
     816:	810a8a93          	addi	s5,s5,-2032 # 22 <thread_func_exit_sleep_1_xstatus_98>
     81a:	00000a17          	auipc	s4,0x0
     81e:	826a0a13          	addi	s4,s4,-2010 # 40 <thread_func_sleep_for_1_xstatus_7>
     822:	a81d                	j	858 <max_threads_exit_by_created_they_exit_after_1+0x6a>
    if (tids[i] < 0) {
      error_exit("kthread_create failed");
     824:	55fd                	li	a1,-1
     826:	00001517          	auipc	a0,0x1
     82a:	52a50513          	addi	a0,a0,1322 # 1d50 <csem_free+0x1dc>
     82e:	00000097          	auipc	ra,0x0
     832:	9a0080e7          	jalr	-1632(ra) # 1ce <error_exit_core>

  if ((last_stack = malloc(STACK_SIZE)) < 0) {
    error_exit("last malloc failed");
  }
  if (kthread_create(thread_func_sleep_for_1_xstatus_7, last_stack) >= 0) {
    error_exit("created too many threads");
     836:	55fd                	li	a1,-1
     838:	00001517          	auipc	a0,0x1
     83c:	56050513          	addi	a0,a0,1376 # 1d98 <csem_free+0x224>
     840:	00000097          	auipc	ra,0x0
     844:	98e080e7          	jalr	-1650(ra) # 1ce <error_exit_core>
    tids[i] = kthread_create(f, stacks[i]);
     848:	8556                	mv	a0,s5
     84a:	00001097          	auipc	ra,0x1
     84e:	d44080e7          	jalr	-700(ra) # 158e <kthread_create>
    if (tids[i] < 0) {
     852:	fc0549e3          	bltz	a0,824 <max_threads_exit_by_created_they_exit_after_1+0x36>
     856:	2485                	addiw	s1,s1,1
    stacks[i] = malloc(STACK_SIZE);
     858:	854e                	mv	a0,s3
     85a:	00001097          	auipc	ra,0x1
     85e:	10c080e7          	jalr	268(ra) # 1966 <malloc>
     862:	85aa                	mv	a1,a0
    if (i == 5) {
     864:	ff2482e3          	beq	s1,s2,848 <max_threads_exit_by_created_they_exit_after_1+0x5a>
    tids[i] = kthread_create(f, stacks[i]);
     868:	8552                	mv	a0,s4
     86a:	00001097          	auipc	ra,0x1
     86e:	d24080e7          	jalr	-732(ra) # 158e <kthread_create>
    if (tids[i] < 0) {
     872:	fa0549e3          	bltz	a0,824 <max_threads_exit_by_created_they_exit_after_1+0x36>
  for (int i = 0; i < NTHREAD - 1; i++) {
     876:	0004879b          	sext.w	a5,s1
     87a:	fcf95ee3          	bge	s2,a5,856 <max_threads_exit_by_created_they_exit_after_1+0x68>
  if ((last_stack = malloc(STACK_SIZE)) < 0) {
     87e:	6505                	lui	a0,0x1
     880:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     884:	00001097          	auipc	ra,0x1
     888:	0e2080e7          	jalr	226(ra) # 1966 <malloc>
     88c:	84aa                	mv	s1,a0
  if (kthread_create(thread_func_sleep_for_1_xstatus_7, last_stack) >= 0) {
     88e:	85aa                	mv	a1,a0
     890:	fffff517          	auipc	a0,0xfffff
     894:	7b050513          	addi	a0,a0,1968 # 40 <thread_func_sleep_for_1_xstatus_7>
     898:	00001097          	auipc	ra,0x1
     89c:	cf6080e7          	jalr	-778(ra) # 158e <kthread_create>
     8a0:	f8055be3          	bgez	a0,836 <max_threads_exit_by_created_they_exit_after_1+0x48>
  }
  free(last_stack);
     8a4:	8526                	mv	a0,s1
     8a6:	00001097          	auipc	ra,0x1
     8aa:	038080e7          	jalr	56(ra) # 18de <free>
  
  sleep(1);
     8ae:	4505                	li	a0,1
     8b0:	00001097          	auipc	ra,0x1
     8b4:	cb6080e7          	jalr	-842(ra) # 1566 <sleep>
  kthread_exit(8);
     8b8:	4521                	li	a0,8
     8ba:	00001097          	auipc	ra,0x1
     8be:	ce4080e7          	jalr	-796(ra) # 159e <kthread_exit>
}
     8c2:	70e2                	ld	ra,56(sp)
     8c4:	7442                	ld	s0,48(sp)
     8c6:	74a2                	ld	s1,40(sp)
     8c8:	7902                	ld	s2,32(sp)
     8ca:	69e2                	ld	s3,24(sp)
     8cc:	6a42                	ld	s4,16(sp)
     8ce:	6aa2                	ld	s5,8(sp)
     8d0:	6121                	addi	sp,sp,64
     8d2:	8082                	ret

00000000000008d4 <max_threads_join>:

void max_threads_join(char *s) {
     8d4:	7171                	addi	sp,sp,-176
     8d6:	f506                	sd	ra,168(sp)
     8d8:	f122                	sd	s0,160(sp)
     8da:	ed26                	sd	s1,152(sp)
     8dc:	e94a                	sd	s2,144(sp)
     8de:	e54e                	sd	s3,136(sp)
     8e0:	e152                	sd	s4,128(sp)
     8e2:	fcd6                	sd	s5,120(sp)
     8e4:	f8da                	sd	s6,112(sp)
     8e6:	f4de                	sd	s7,104(sp)
     8e8:	1900                	addi	s0,sp,176
  int tids[NTHREAD - 1];
  void *stacks[NTHREAD - 1];
  for (int i = 0; i < NTHREAD - 1; i++) {
     8ea:	f5840a93          	addi	s5,s0,-168
     8ee:	f9040a13          	addi	s4,s0,-112
     8f2:	8b52                	mv	s6,s4
void max_threads_join(char *s) {
     8f4:	8952                	mv	s2,s4
     8f6:	84d6                	mv	s1,s5
    stacks[i] = malloc(STACK_SIZE);
     8f8:	6985                	lui	s3,0x1
     8fa:	fa098993          	addi	s3,s3,-96 # fa0 <max_threads_fork+0x74>
    if (stacks[i] < 0) {
      error_exit("malloc failed");
    }
    tids[i] = kthread_create(thread_func_sleep_for_1_xstatus_7, stacks[i]);
     8fe:	fffffb97          	auipc	s7,0xfffff
     902:	742b8b93          	addi	s7,s7,1858 # 40 <thread_func_sleep_for_1_xstatus_7>
    stacks[i] = malloc(STACK_SIZE);
     906:	854e                	mv	a0,s3
     908:	00001097          	auipc	ra,0x1
     90c:	05e080e7          	jalr	94(ra) # 1966 <malloc>
     910:	85aa                	mv	a1,a0
     912:	e088                	sd	a0,0(s1)
    tids[i] = kthread_create(thread_func_sleep_for_1_xstatus_7, stacks[i]);
     914:	855e                	mv	a0,s7
     916:	00001097          	auipc	ra,0x1
     91a:	c78080e7          	jalr	-904(ra) # 158e <kthread_create>
     91e:	00a92023          	sw	a0,0(s2)
    if (tids[i] < 0) {
     922:	04054263          	bltz	a0,966 <max_threads_join+0x92>
  for (int i = 0; i < NTHREAD - 1; i++) {
     926:	04a1                	addi	s1,s1,8
     928:	0911                	addi	s2,s2,4
     92a:	fd649ee3          	bne	s1,s6,906 <max_threads_join+0x32>
    }

    print("created thread %d", tids[i]);
  }
  void *stack;
  if ((stack = malloc(STACK_SIZE)) < 0) {
     92e:	6505                	lui	a0,0x1
     930:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     934:	00001097          	auipc	ra,0x1
     938:	032080e7          	jalr	50(ra) # 1966 <malloc>
     93c:	84aa                	mv	s1,a0
    error_exit("last malloc failed");
  }
  if (kthread_create(thread_func_sleep_for_1_xstatus_7, stack) >= 0) {
     93e:	85aa                	mv	a1,a0
     940:	fffff517          	auipc	a0,0xfffff
     944:	70050513          	addi	a0,a0,1792 # 40 <thread_func_sleep_for_1_xstatus_7>
     948:	00001097          	auipc	ra,0x1
     94c:	c46080e7          	jalr	-954(ra) # 158e <kthread_create>
     950:	02054463          	bltz	a0,978 <max_threads_join+0xa4>
    error_exit("created too many threads");
     954:	55fd                	li	a1,-1
     956:	00001517          	auipc	a0,0x1
     95a:	44250513          	addi	a0,a0,1090 # 1d98 <csem_free+0x224>
     95e:	00000097          	auipc	ra,0x0
     962:	870080e7          	jalr	-1936(ra) # 1ce <error_exit_core>
      error_exit("kthread_create failed");
     966:	55fd                	li	a1,-1
     968:	00001517          	auipc	a0,0x1
     96c:	3e850513          	addi	a0,a0,1000 # 1d50 <csem_free+0x1dc>
     970:	00000097          	auipc	ra,0x0
     974:	85e080e7          	jalr	-1954(ra) # 1ce <error_exit_core>
  }
  free(stack);
     978:	8526                	mv	a0,s1
     97a:	00001097          	auipc	ra,0x1
     97e:	f64080e7          	jalr	-156(ra) # 18de <free>

  print("joining the rest...");
  for (int i = 0; i < NTHREAD - 1; i++) {
     982:	01ca0493          	addi	s1,s4,28
      int status;
      if (kthread_join(tids[i], &status) < 0) {
     986:	f5440593          	addi	a1,s0,-172
     98a:	000a2503          	lw	a0,0(s4)
     98e:	00001097          	auipc	ra,0x1
     992:	c18080e7          	jalr	-1000(ra) # 15a6 <kthread_join>
     996:	02054163          	bltz	a0,9b8 <max_threads_join+0xe4>
        error_exit("join failed");
      }
      free(stacks[i]);
     99a:	000ab503          	ld	a0,0(s5)
     99e:	00001097          	auipc	ra,0x1
     9a2:	f40080e7          	jalr	-192(ra) # 18de <free>
  for (int i = 0; i < NTHREAD - 1; i++) {
     9a6:	0a11                	addi	s4,s4,4
     9a8:	0aa1                	addi	s5,s5,8
     9aa:	fc9a1ee3          	bne	s4,s1,986 <max_threads_join+0xb2>
      print("status for %d: %d", tids[i], status);
  }
  print("shared: %d", shared);
  exit(0);
     9ae:	4501                	li	a0,0
     9b0:	00001097          	auipc	ra,0x1
     9b4:	b26080e7          	jalr	-1242(ra) # 14d6 <exit>
        error_exit("join failed");
     9b8:	55fd                	li	a1,-1
     9ba:	00001517          	auipc	a0,0x1
     9be:	3ae50513          	addi	a0,a0,942 # 1d68 <csem_free+0x1f4>
     9c2:	00000097          	auipc	ra,0x0
     9c6:	80c080e7          	jalr	-2036(ra) # 1ce <error_exit_core>

00000000000009ca <max_threads_join_reverse>:
}

void max_threads_join_reverse(char *s) {
     9ca:	7171                	addi	sp,sp,-176
     9cc:	f506                	sd	ra,168(sp)
     9ce:	f122                	sd	s0,160(sp)
     9d0:	ed26                	sd	s1,152(sp)
     9d2:	e94a                	sd	s2,144(sp)
     9d4:	e54e                	sd	s3,136(sp)
     9d6:	e152                	sd	s4,128(sp)
     9d8:	fcd6                	sd	s5,120(sp)
     9da:	f8da                	sd	s6,112(sp)
     9dc:	f4de                	sd	s7,104(sp)
     9de:	1900                	addi	s0,sp,176
  int tids[NTHREAD - 1];
  void *stacks[NTHREAD - 1];
  for (int i = 0; i < NTHREAD - 1; i++) {
     9e0:	f5840a13          	addi	s4,s0,-168
     9e4:	f9040a93          	addi	s5,s0,-112
     9e8:	8b56                	mv	s6,s5
void max_threads_join_reverse(char *s) {
     9ea:	8956                	mv	s2,s5
     9ec:	84d2                	mv	s1,s4
    stacks[i] = malloc(STACK_SIZE);
     9ee:	6985                	lui	s3,0x1
     9f0:	fa098993          	addi	s3,s3,-96 # fa0 <max_threads_fork+0x74>
    if (stacks[i] < 0) {
      error_exit("malloc failed");
    }
    tids[i] = kthread_create(thread_func_sleep_for_1_xstatus_7, stacks[i]);
     9f4:	fffffb97          	auipc	s7,0xfffff
     9f8:	64cb8b93          	addi	s7,s7,1612 # 40 <thread_func_sleep_for_1_xstatus_7>
    stacks[i] = malloc(STACK_SIZE);
     9fc:	854e                	mv	a0,s3
     9fe:	00001097          	auipc	ra,0x1
     a02:	f68080e7          	jalr	-152(ra) # 1966 <malloc>
     a06:	85aa                	mv	a1,a0
     a08:	e088                	sd	a0,0(s1)
    tids[i] = kthread_create(thread_func_sleep_for_1_xstatus_7, stacks[i]);
     a0a:	855e                	mv	a0,s7
     a0c:	00001097          	auipc	ra,0x1
     a10:	b82080e7          	jalr	-1150(ra) # 158e <kthread_create>
     a14:	00a92023          	sw	a0,0(s2)
    if (tids[i] < 0) {
     a18:	04054263          	bltz	a0,a5c <max_threads_join_reverse+0x92>
  for (int i = 0; i < NTHREAD - 1; i++) {
     a1c:	04a1                	addi	s1,s1,8
     a1e:	0911                	addi	s2,s2,4
     a20:	fd649ee3          	bne	s1,s6,9fc <max_threads_join_reverse+0x32>
    }

    print("created thread %d", tids[i]);
  }
  void *stack;
  if ((stack = malloc(STACK_SIZE)) < 0) {
     a24:	6505                	lui	a0,0x1
     a26:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     a2a:	00001097          	auipc	ra,0x1
     a2e:	f3c080e7          	jalr	-196(ra) # 1966 <malloc>
     a32:	84aa                	mv	s1,a0
    error_exit("last malloc failed");
  }
  if (kthread_create(thread_func_sleep_for_1_xstatus_7, stack) >= 0) {
     a34:	85aa                	mv	a1,a0
     a36:	fffff517          	auipc	a0,0xfffff
     a3a:	60a50513          	addi	a0,a0,1546 # 40 <thread_func_sleep_for_1_xstatus_7>
     a3e:	00001097          	auipc	ra,0x1
     a42:	b50080e7          	jalr	-1200(ra) # 158e <kthread_create>
     a46:	02054463          	bltz	a0,a6e <max_threads_join_reverse+0xa4>
    error_exit("created too many threads");
     a4a:	55fd                	li	a1,-1
     a4c:	00001517          	auipc	a0,0x1
     a50:	34c50513          	addi	a0,a0,844 # 1d98 <csem_free+0x224>
     a54:	fffff097          	auipc	ra,0xfffff
     a58:	77a080e7          	jalr	1914(ra) # 1ce <error_exit_core>
      error_exit("kthread_create failed");
     a5c:	55fd                	li	a1,-1
     a5e:	00001517          	auipc	a0,0x1
     a62:	2f250513          	addi	a0,a0,754 # 1d50 <csem_free+0x1dc>
     a66:	fffff097          	auipc	ra,0xfffff
     a6a:	768080e7          	jalr	1896(ra) # 1ce <error_exit_core>
  }
  free(stack);
     a6e:	8526                	mv	a0,s1
     a70:	00001097          	auipc	ra,0x1
     a74:	e6e080e7          	jalr	-402(ra) # 18de <free>

  print("joining the rest...");
  for (int i = NTHREAD - 2; i >= 0; i--) {
     a78:	fc8a0493          	addi	s1,s4,-56
      int status;
      if (kthread_join(tids[i], &status) < 0) {
     a7c:	f5440593          	addi	a1,s0,-172
     a80:	018aa503          	lw	a0,24(s5)
     a84:	00001097          	auipc	ra,0x1
     a88:	b22080e7          	jalr	-1246(ra) # 15a6 <kthread_join>
     a8c:	02054163          	bltz	a0,aae <max_threads_join_reverse+0xe4>
        error_exit("join failed");
      }
      free(stacks[i]);
     a90:	030a3503          	ld	a0,48(s4)
     a94:	00001097          	auipc	ra,0x1
     a98:	e4a080e7          	jalr	-438(ra) # 18de <free>
  for (int i = NTHREAD - 2; i >= 0; i--) {
     a9c:	1af1                	addi	s5,s5,-4
     a9e:	1a61                	addi	s4,s4,-8
     aa0:	fc9a1ee3          	bne	s4,s1,a7c <max_threads_join_reverse+0xb2>
      print("status for %d: %d", tids[i], status);
  }
  print("shared: %d", shared);
  exit(0);
     aa4:	4501                	li	a0,0
     aa6:	00001097          	auipc	ra,0x1
     aaa:	a30080e7          	jalr	-1488(ra) # 14d6 <exit>
        error_exit("join failed");
     aae:	55fd                	li	a1,-1
     ab0:	00001517          	auipc	a0,0x1
     ab4:	2b850513          	addi	a0,a0,696 # 1d68 <csem_free+0x1f4>
     ab8:	fffff097          	auipc	ra,0xfffff
     abc:	716080e7          	jalr	1814(ra) # 1ce <error_exit_core>

0000000000000ac0 <max_threads_exec_simple>:
  test_name = "exec max threads join";
  max_threads_join(test_name);
  exit(6);
}

void max_threads_exec_simple(char *s) {
     ac0:	7179                	addi	sp,sp,-48
     ac2:	f406                	sd	ra,40(sp)
     ac4:	f022                	sd	s0,32(sp)
     ac6:	ec26                	sd	s1,24(sp)
     ac8:	e84a                	sd	s2,16(sp)
     aca:	e44e                	sd	s3,8(sp)
     acc:	1800                	addi	s0,sp,48
  void *stacks[NTHREAD - 1];
  int tids[NTHREAD - 1];
  void *last_stack;
  int my_tid = kthread_id();
     ace:	00001097          	auipc	ra,0x1
     ad2:	ac8080e7          	jalr	-1336(ra) # 1596 <kthread_id>
     ad6:	449d                	li	s1,7

  print("thread %d started", my_tid);
  for (int i = 0; i < NTHREAD - 1; i++) {
    stacks[i] = malloc(STACK_SIZE);
     ad8:	6905                	lui	s2,0x1
     ada:	fa090913          	addi	s2,s2,-96 # fa0 <max_threads_fork+0x74>
    if (stacks[i] < 0) {
      error_exit("malloc failed");
    }
    tids[i] = kthread_create(thread_func_run_forever, stacks[i]);
     ade:	fffff997          	auipc	s3,0xfffff
     ae2:	5c898993          	addi	s3,s3,1480 # a6 <thread_func_run_forever>
    stacks[i] = malloc(STACK_SIZE);
     ae6:	854a                	mv	a0,s2
     ae8:	00001097          	auipc	ra,0x1
     aec:	e7e080e7          	jalr	-386(ra) # 1966 <malloc>
     af0:	85aa                	mv	a1,a0
    tids[i] = kthread_create(thread_func_run_forever, stacks[i]);
     af2:	854e                	mv	a0,s3
     af4:	00001097          	auipc	ra,0x1
     af8:	a9a080e7          	jalr	-1382(ra) # 158e <kthread_create>
    if (tids[i] < 0) {
     afc:	06054f63          	bltz	a0,b7a <max_threads_exec_simple+0xba>
  for (int i = 0; i < NTHREAD - 1; i++) {
     b00:	34fd                	addiw	s1,s1,-1
     b02:	f0f5                	bnez	s1,ae6 <max_threads_exec_simple+0x26>
    }

    print("created thread %d", tids[i]);
  }

  if ((last_stack = malloc(STACK_SIZE)) < 0) {
     b04:	6505                	lui	a0,0x1
     b06:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     b0a:	00001097          	auipc	ra,0x1
     b0e:	e5c080e7          	jalr	-420(ra) # 1966 <malloc>
     b12:	84aa                	mv	s1,a0
    error_exit("last malloc failed");
  }
  if (kthread_create(thread_func_run_forever, last_stack) >= 0) {
     b14:	85aa                	mv	a1,a0
     b16:	fffff517          	auipc	a0,0xfffff
     b1a:	59050513          	addi	a0,a0,1424 # a6 <thread_func_run_forever>
     b1e:	00001097          	auipc	ra,0x1
     b22:	a70080e7          	jalr	-1424(ra) # 158e <kthread_create>
     b26:	06055363          	bgez	a0,b8c <max_threads_exec_simple+0xcc>
    error_exit("created too many threads");
  }
  if (kthread_create(thread_func_run_forever, last_stack) >= 0) {
     b2a:	85a6                	mv	a1,s1
     b2c:	fffff517          	auipc	a0,0xfffff
     b30:	57a50513          	addi	a0,a0,1402 # a6 <thread_func_run_forever>
     b34:	00001097          	auipc	ra,0x1
     b38:	a5a080e7          	jalr	-1446(ra) # 158e <kthread_create>
     b3c:	06055163          	bgez	a0,b9e <max_threads_exec_simple+0xde>
    error_exit("created too many threads 2");
  }
  free(last_stack);
     b40:	8526                	mv	a0,s1
     b42:	00001097          	auipc	ra,0x1
     b46:	d9c080e7          	jalr	-612(ra) # 18de <free>
  
  print("going to sleep");
  sleep(5);
     b4a:	4515                	li	a0,5
     b4c:	00001097          	auipc	ra,0x1
     b50:	a1a080e7          	jalr	-1510(ra) # 1566 <sleep>
  print("exec...");
  exec(exec_simple_argv[0], exec_simple_argv);
     b54:	00001597          	auipc	a1,0x1
     b58:	65458593          	addi	a1,a1,1620 # 21a8 <exec_simple_argv>
     b5c:	00001517          	auipc	a0,0x1
     b60:	64c53503          	ld	a0,1612(a0) # 21a8 <exec_simple_argv>
     b64:	00001097          	auipc	ra,0x1
     b68:	9aa080e7          	jalr	-1622(ra) # 150e <exec>
}
     b6c:	70a2                	ld	ra,40(sp)
     b6e:	7402                	ld	s0,32(sp)
     b70:	64e2                	ld	s1,24(sp)
     b72:	6942                	ld	s2,16(sp)
     b74:	69a2                	ld	s3,8(sp)
     b76:	6145                	addi	sp,sp,48
     b78:	8082                	ret
      error_exit("kthread_create failed");
     b7a:	55fd                	li	a1,-1
     b7c:	00001517          	auipc	a0,0x1
     b80:	1d450513          	addi	a0,a0,468 # 1d50 <csem_free+0x1dc>
     b84:	fffff097          	auipc	ra,0xfffff
     b88:	64a080e7          	jalr	1610(ra) # 1ce <error_exit_core>
    error_exit("created too many threads");
     b8c:	55fd                	li	a1,-1
     b8e:	00001517          	auipc	a0,0x1
     b92:	20a50513          	addi	a0,a0,522 # 1d98 <csem_free+0x224>
     b96:	fffff097          	auipc	ra,0xfffff
     b9a:	638080e7          	jalr	1592(ra) # 1ce <error_exit_core>
    error_exit("created too many threads 2");
     b9e:	55fd                	li	a1,-1
     ba0:	00001517          	auipc	a0,0x1
     ba4:	21850513          	addi	a0,a0,536 # 1db8 <csem_free+0x244>
     ba8:	fffff097          	auipc	ra,0xfffff
     bac:	626080e7          	jalr	1574(ra) # 1ce <error_exit_core>

0000000000000bb0 <max_threads_exec>:

void max_threads_exec(char *s) {
     bb0:	7179                	addi	sp,sp,-48
     bb2:	f406                	sd	ra,40(sp)
     bb4:	f022                	sd	s0,32(sp)
     bb6:	ec26                	sd	s1,24(sp)
     bb8:	e84a                	sd	s2,16(sp)
     bba:	e44e                	sd	s3,8(sp)
     bbc:	1800                	addi	s0,sp,48
  void *stacks[NTHREAD - 1];
  int tids[NTHREAD - 1];
  void *last_stack;
  int my_tid = kthread_id();
     bbe:	00001097          	auipc	ra,0x1
     bc2:	9d8080e7          	jalr	-1576(ra) # 1596 <kthread_id>
     bc6:	449d                	li	s1,7

  print("thread %d started", my_tid);
  for (int i = 0; i < NTHREAD - 1; i++) {
    stacks[i] = malloc(STACK_SIZE);
     bc8:	6905                	lui	s2,0x1
     bca:	fa090913          	addi	s2,s2,-96 # fa0 <max_threads_fork+0x74>
    if (stacks[i] < 0) {
      error_exit("malloc failed");
    }
    tids[i] = kthread_create(thread_func_run_forever, stacks[i]);
     bce:	fffff997          	auipc	s3,0xfffff
     bd2:	4d898993          	addi	s3,s3,1240 # a6 <thread_func_run_forever>
    stacks[i] = malloc(STACK_SIZE);
     bd6:	854a                	mv	a0,s2
     bd8:	00001097          	auipc	ra,0x1
     bdc:	d8e080e7          	jalr	-626(ra) # 1966 <malloc>
     be0:	85aa                	mv	a1,a0
    tids[i] = kthread_create(thread_func_run_forever, stacks[i]);
     be2:	854e                	mv	a0,s3
     be4:	00001097          	auipc	ra,0x1
     be8:	9aa080e7          	jalr	-1622(ra) # 158e <kthread_create>
    if (tids[i] < 0) {
     bec:	06054c63          	bltz	a0,c64 <max_threads_exec+0xb4>
  for (int i = 0; i < NTHREAD - 1; i++) {
     bf0:	34fd                	addiw	s1,s1,-1
     bf2:	f0f5                	bnez	s1,bd6 <max_threads_exec+0x26>
    }

    print("created thread %d", tids[i]);
  }

  if ((last_stack = malloc(STACK_SIZE)) < 0) {
     bf4:	6505                	lui	a0,0x1
     bf6:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     bfa:	00001097          	auipc	ra,0x1
     bfe:	d6c080e7          	jalr	-660(ra) # 1966 <malloc>
     c02:	84aa                	mv	s1,a0
    error_exit("last malloc failed");
  }
  if (kthread_create(thread_func_run_forever, last_stack) >= 0) {
     c04:	85aa                	mv	a1,a0
     c06:	fffff517          	auipc	a0,0xfffff
     c0a:	4a050513          	addi	a0,a0,1184 # a6 <thread_func_run_forever>
     c0e:	00001097          	auipc	ra,0x1
     c12:	980080e7          	jalr	-1664(ra) # 158e <kthread_create>
     c16:	06055063          	bgez	a0,c76 <max_threads_exec+0xc6>
    error_exit("created too many threads");
  }
  if (kthread_create(thread_func_run_forever, last_stack) >= 0) {
     c1a:	85a6                	mv	a1,s1
     c1c:	fffff517          	auipc	a0,0xfffff
     c20:	48a50513          	addi	a0,a0,1162 # a6 <thread_func_run_forever>
     c24:	00001097          	auipc	ra,0x1
     c28:	96a080e7          	jalr	-1686(ra) # 158e <kthread_create>
     c2c:	04055e63          	bgez	a0,c88 <max_threads_exec+0xd8>
    error_exit("created too many threads 2");
  }
  free(last_stack);
     c30:	8526                	mv	a0,s1
     c32:	00001097          	auipc	ra,0x1
     c36:	cac080e7          	jalr	-852(ra) # 18de <free>
  
  print("going to sleep");
  sleep(5);
     c3a:	4515                	li	a0,5
     c3c:	00001097          	auipc	ra,0x1
     c40:	92a080e7          	jalr	-1750(ra) # 1566 <sleep>
  print("exec...");
  exec(exec_argv[0], exec_argv);
     c44:	00001597          	auipc	a1,0x1
     c48:	54c58593          	addi	a1,a1,1356 # 2190 <exec_argv>
     c4c:	6188                	ld	a0,0(a1)
     c4e:	00001097          	auipc	ra,0x1
     c52:	8c0080e7          	jalr	-1856(ra) # 150e <exec>
}
     c56:	70a2                	ld	ra,40(sp)
     c58:	7402                	ld	s0,32(sp)
     c5a:	64e2                	ld	s1,24(sp)
     c5c:	6942                	ld	s2,16(sp)
     c5e:	69a2                	ld	s3,8(sp)
     c60:	6145                	addi	sp,sp,48
     c62:	8082                	ret
      error_exit("kthread_create failed");
     c64:	55fd                	li	a1,-1
     c66:	00001517          	auipc	a0,0x1
     c6a:	0ea50513          	addi	a0,a0,234 # 1d50 <csem_free+0x1dc>
     c6e:	fffff097          	auipc	ra,0xfffff
     c72:	560080e7          	jalr	1376(ra) # 1ce <error_exit_core>
    error_exit("created too many threads");
     c76:	55fd                	li	a1,-1
     c78:	00001517          	auipc	a0,0x1
     c7c:	12050513          	addi	a0,a0,288 # 1d98 <csem_free+0x224>
     c80:	fffff097          	auipc	ra,0xfffff
     c84:	54e080e7          	jalr	1358(ra) # 1ce <error_exit_core>
    error_exit("created too many threads 2");
     c88:	55fd                	li	a1,-1
     c8a:	00001517          	auipc	a0,0x1
     c8e:	12e50513          	addi	a0,a0,302 # 1db8 <csem_free+0x244>
     c92:	fffff097          	auipc	ra,0xfffff
     c96:	53c080e7          	jalr	1340(ra) # 1ce <error_exit_core>

0000000000000c9a <max_threads_exec_they_exit_after_1>:

void max_threads_exec_they_exit_after_1(char *s) {
     c9a:	7179                	addi	sp,sp,-48
     c9c:	f406                	sd	ra,40(sp)
     c9e:	f022                	sd	s0,32(sp)
     ca0:	ec26                	sd	s1,24(sp)
     ca2:	e84a                	sd	s2,16(sp)
     ca4:	e44e                	sd	s3,8(sp)
     ca6:	1800                	addi	s0,sp,48
  void *stacks[NTHREAD - 1];
  int tids[NTHREAD - 1];
  void *last_stack;
  int my_tid = kthread_id();
     ca8:	00001097          	auipc	ra,0x1
     cac:	8ee080e7          	jalr	-1810(ra) # 1596 <kthread_id>
     cb0:	449d                	li	s1,7

  print("thread %d started", my_tid);
  for (int i = 0; i < NTHREAD - 1; i++) {
    stacks[i] = malloc(STACK_SIZE);
     cb2:	6905                	lui	s2,0x1
     cb4:	fa090913          	addi	s2,s2,-96 # fa0 <max_threads_fork+0x74>
    if (stacks[i] < 0) {
      error_exit("malloc failed");
    }
    tids[i] = kthread_create(thread_func_sleep_for_1_xstatus_7, stacks[i]);
     cb8:	fffff997          	auipc	s3,0xfffff
     cbc:	38898993          	addi	s3,s3,904 # 40 <thread_func_sleep_for_1_xstatus_7>
    stacks[i] = malloc(STACK_SIZE);
     cc0:	854a                	mv	a0,s2
     cc2:	00001097          	auipc	ra,0x1
     cc6:	ca4080e7          	jalr	-860(ra) # 1966 <malloc>
     cca:	85aa                	mv	a1,a0
    tids[i] = kthread_create(thread_func_sleep_for_1_xstatus_7, stacks[i]);
     ccc:	854e                	mv	a0,s3
     cce:	00001097          	auipc	ra,0x1
     cd2:	8c0080e7          	jalr	-1856(ra) # 158e <kthread_create>
    if (tids[i] < 0) {
     cd6:	06054c63          	bltz	a0,d4e <max_threads_exec_they_exit_after_1+0xb4>
  for (int i = 0; i < NTHREAD - 1; i++) {
     cda:	34fd                	addiw	s1,s1,-1
     cdc:	f0f5                	bnez	s1,cc0 <max_threads_exec_they_exit_after_1+0x26>
    }

    print("created thread %d", tids[i]);
  }

  if ((last_stack = malloc(STACK_SIZE)) < 0) {
     cde:	6505                	lui	a0,0x1
     ce0:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     ce4:	00001097          	auipc	ra,0x1
     ce8:	c82080e7          	jalr	-894(ra) # 1966 <malloc>
     cec:	84aa                	mv	s1,a0
    error_exit("last malloc failed");
  }
  if (kthread_create(thread_func_sleep_for_1_xstatus_7, last_stack) >= 0) {
     cee:	85aa                	mv	a1,a0
     cf0:	fffff517          	auipc	a0,0xfffff
     cf4:	35050513          	addi	a0,a0,848 # 40 <thread_func_sleep_for_1_xstatus_7>
     cf8:	00001097          	auipc	ra,0x1
     cfc:	896080e7          	jalr	-1898(ra) # 158e <kthread_create>
     d00:	06055063          	bgez	a0,d60 <max_threads_exec_they_exit_after_1+0xc6>
    error_exit("created too many threads");
  }
  if (kthread_create(thread_func_sleep_for_1_xstatus_7, last_stack) >= 0) {
     d04:	85a6                	mv	a1,s1
     d06:	fffff517          	auipc	a0,0xfffff
     d0a:	33a50513          	addi	a0,a0,826 # 40 <thread_func_sleep_for_1_xstatus_7>
     d0e:	00001097          	auipc	ra,0x1
     d12:	880080e7          	jalr	-1920(ra) # 158e <kthread_create>
     d16:	04055e63          	bgez	a0,d72 <max_threads_exec_they_exit_after_1+0xd8>
    error_exit("created too many threads 2");
  }
  free(last_stack);
     d1a:	8526                	mv	a0,s1
     d1c:	00001097          	auipc	ra,0x1
     d20:	bc2080e7          	jalr	-1086(ra) # 18de <free>
  
  print("going to sleep");
  sleep(5);
     d24:	4515                	li	a0,5
     d26:	00001097          	auipc	ra,0x1
     d2a:	840080e7          	jalr	-1984(ra) # 1566 <sleep>
  print("exec...");
  exec(exec_argv[0], exec_argv);
     d2e:	00001597          	auipc	a1,0x1
     d32:	46258593          	addi	a1,a1,1122 # 2190 <exec_argv>
     d36:	6188                	ld	a0,0(a1)
     d38:	00000097          	auipc	ra,0x0
     d3c:	7d6080e7          	jalr	2006(ra) # 150e <exec>
}
     d40:	70a2                	ld	ra,40(sp)
     d42:	7402                	ld	s0,32(sp)
     d44:	64e2                	ld	s1,24(sp)
     d46:	6942                	ld	s2,16(sp)
     d48:	69a2                	ld	s3,8(sp)
     d4a:	6145                	addi	sp,sp,48
     d4c:	8082                	ret
      error_exit("kthread_create failed");
     d4e:	55fd                	li	a1,-1
     d50:	00001517          	auipc	a0,0x1
     d54:	00050513          	mv	a0,a0
     d58:	fffff097          	auipc	ra,0xfffff
     d5c:	476080e7          	jalr	1142(ra) # 1ce <error_exit_core>
    error_exit("created too many threads");
     d60:	55fd                	li	a1,-1
     d62:	00001517          	auipc	a0,0x1
     d66:	03650513          	addi	a0,a0,54 # 1d98 <csem_free+0x224>
     d6a:	fffff097          	auipc	ra,0xfffff
     d6e:	464080e7          	jalr	1124(ra) # 1ce <error_exit_core>
    error_exit("created too many threads 2");
     d72:	55fd                	li	a1,-1
     d74:	00001517          	auipc	a0,0x1
     d78:	04450513          	addi	a0,a0,68 # 1db8 <csem_free+0x244>
     d7c:	fffff097          	auipc	ra,0xfffff
     d80:	452080e7          	jalr	1106(ra) # 1ce <error_exit_core>

0000000000000d84 <max_threads_exec_by_created_they_run_forever>:

void max_threads_exec_by_created_they_run_forever(char *s) {
     d84:	7139                	addi	sp,sp,-64
     d86:	fc06                	sd	ra,56(sp)
     d88:	f822                	sd	s0,48(sp)
     d8a:	f426                	sd	s1,40(sp)
     d8c:	f04a                	sd	s2,32(sp)
     d8e:	ec4e                	sd	s3,24(sp)
     d90:	e852                	sd	s4,16(sp)
     d92:	e456                	sd	s5,8(sp)
     d94:	0080                	addi	s0,sp,64
  void *stacks[NTHREAD - 1];
  int tids[NTHREAD - 1];
  void *last_stack;
  int my_tid = kthread_id();
     d96:	00001097          	auipc	ra,0x1
     d9a:	800080e7          	jalr	-2048(ra) # 1596 <kthread_id>
     d9e:	4485                	li	s1,1

  print("thread %d started", my_tid);
  for (int i = 0; i < NTHREAD - 1; i++) {
    void (*f)();
    stacks[i] = malloc(STACK_SIZE);
     da0:	6985                	lui	s3,0x1
     da2:	fa098993          	addi	s3,s3,-96 # fa0 <max_threads_fork+0x74>
    if (stacks[i] < 0) {
      error_exit("malloc failed");
    }
    if (i == 5) {
     da6:	4919                	li	s2,6
      f = thread_func_exec_sleep_1_xstatus_98;
    }
    else {
      f = run_forever;
    }
    tids[i] = kthread_create(f, stacks[i]);
     da8:	fffffa97          	auipc	s5,0xfffff
     dac:	2d2a8a93          	addi	s5,s5,722 # 7a <thread_func_exec_sleep_1_xstatus_98>
     db0:	fffffa17          	auipc	s4,0xfffff
     db4:	250a0a13          	addi	s4,s4,592 # 0 <run_forever>
     db8:	a805                	j	de8 <max_threads_exec_by_created_they_run_forever+0x64>
    if (tids[i] < 0) {
      error_exit("kthread_create failed");
     dba:	55fd                	li	a1,-1
     dbc:	00001517          	auipc	a0,0x1
     dc0:	f9450513          	addi	a0,a0,-108 # 1d50 <csem_free+0x1dc>
     dc4:	fffff097          	auipc	ra,0xfffff
     dc8:	40a080e7          	jalr	1034(ra) # 1ce <error_exit_core>
    error_exit("last malloc failed");
  }
  if (kthread_create(thread_func_sleep_for_1_xstatus_7, last_stack) >= 0) {
    error_exit("created too many threads");
  }
  free(last_stack);
     dcc:	8526                	mv	a0,s1
     dce:	00001097          	auipc	ra,0x1
     dd2:	b10080e7          	jalr	-1264(ra) # 18de <free>
  while (1) {
     dd6:	a001                	j	dd6 <max_threads_exec_by_created_they_run_forever+0x52>
    tids[i] = kthread_create(f, stacks[i]);
     dd8:	8556                	mv	a0,s5
     dda:	00000097          	auipc	ra,0x0
     dde:	7b4080e7          	jalr	1972(ra) # 158e <kthread_create>
    if (tids[i] < 0) {
     de2:	fc054ce3          	bltz	a0,dba <max_threads_exec_by_created_they_run_forever+0x36>
     de6:	2485                	addiw	s1,s1,1
    stacks[i] = malloc(STACK_SIZE);
     de8:	854e                	mv	a0,s3
     dea:	00001097          	auipc	ra,0x1
     dee:	b7c080e7          	jalr	-1156(ra) # 1966 <malloc>
     df2:	85aa                	mv	a1,a0
    if (i == 5) {
     df4:	ff2482e3          	beq	s1,s2,dd8 <max_threads_exec_by_created_they_run_forever+0x54>
    tids[i] = kthread_create(f, stacks[i]);
     df8:	8552                	mv	a0,s4
     dfa:	00000097          	auipc	ra,0x0
     dfe:	794080e7          	jalr	1940(ra) # 158e <kthread_create>
    if (tids[i] < 0) {
     e02:	fa054ce3          	bltz	a0,dba <max_threads_exec_by_created_they_run_forever+0x36>
  for (int i = 0; i < NTHREAD - 1; i++) {
     e06:	0004879b          	sext.w	a5,s1
     e0a:	fcf95ee3          	bge	s2,a5,de6 <max_threads_exec_by_created_they_run_forever+0x62>
  if ((last_stack = malloc(STACK_SIZE)) < 0) {
     e0e:	6505                	lui	a0,0x1
     e10:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     e14:	00001097          	auipc	ra,0x1
     e18:	b52080e7          	jalr	-1198(ra) # 1966 <malloc>
     e1c:	84aa                	mv	s1,a0
  if (kthread_create(thread_func_sleep_for_1_xstatus_7, last_stack) >= 0) {
     e1e:	85aa                	mv	a1,a0
     e20:	fffff517          	auipc	a0,0xfffff
     e24:	22050513          	addi	a0,a0,544 # 40 <thread_func_sleep_for_1_xstatus_7>
     e28:	00000097          	auipc	ra,0x0
     e2c:	766080e7          	jalr	1894(ra) # 158e <kthread_create>
     e30:	f8054ee3          	bltz	a0,dcc <max_threads_exec_by_created_they_run_forever+0x48>
    error_exit("created too many threads");
     e34:	55fd                	li	a1,-1
     e36:	00001517          	auipc	a0,0x1
     e3a:	f6250513          	addi	a0,a0,-158 # 1d98 <csem_free+0x224>
     e3e:	fffff097          	auipc	ra,0xfffff
     e42:	390080e7          	jalr	912(ra) # 1ce <error_exit_core>

0000000000000e46 <max_threads_exec_by_created_they_exit_after_1>:
  
  run_forever();
  kthread_exit(8);
}

void max_threads_exec_by_created_they_exit_after_1(char *s) {
     e46:	7139                	addi	sp,sp,-64
     e48:	fc06                	sd	ra,56(sp)
     e4a:	f822                	sd	s0,48(sp)
     e4c:	f426                	sd	s1,40(sp)
     e4e:	f04a                	sd	s2,32(sp)
     e50:	ec4e                	sd	s3,24(sp)
     e52:	e852                	sd	s4,16(sp)
     e54:	e456                	sd	s5,8(sp)
     e56:	0080                	addi	s0,sp,64
  void *stacks[NTHREAD - 1];
  int tids[NTHREAD - 1];
  void *last_stack;
  int my_tid = kthread_id();
     e58:	00000097          	auipc	ra,0x0
     e5c:	73e080e7          	jalr	1854(ra) # 1596 <kthread_id>
     e60:	4485                	li	s1,1

  print("thread %d started", my_tid);
  for (int i = 0; i < NTHREAD - 1; i++) {
    void (*f)();
    stacks[i] = malloc(STACK_SIZE);
     e62:	6985                	lui	s3,0x1
     e64:	fa098993          	addi	s3,s3,-96 # fa0 <max_threads_fork+0x74>
    if (stacks[i] < 0) {
      error_exit("malloc failed");
    }
    if (i == 5) {
     e68:	4919                	li	s2,6
      f = thread_func_exec_sleep_1_xstatus_98;
    }
    else {
      f = thread_func_sleep_for_1_xstatus_7;
    }
    tids[i] = kthread_create(f, stacks[i]);
     e6a:	fffffa97          	auipc	s5,0xfffff
     e6e:	210a8a93          	addi	s5,s5,528 # 7a <thread_func_exec_sleep_1_xstatus_98>
     e72:	fffffa17          	auipc	s4,0xfffff
     e76:	1cea0a13          	addi	s4,s4,462 # 40 <thread_func_sleep_for_1_xstatus_7>
     e7a:	a81d                	j	eb0 <max_threads_exec_by_created_they_exit_after_1+0x6a>
    if (tids[i] < 0) {
      error_exit("kthread_create failed");
     e7c:	55fd                	li	a1,-1
     e7e:	00001517          	auipc	a0,0x1
     e82:	ed250513          	addi	a0,a0,-302 # 1d50 <csem_free+0x1dc>
     e86:	fffff097          	auipc	ra,0xfffff
     e8a:	348080e7          	jalr	840(ra) # 1ce <error_exit_core>

  if ((last_stack = malloc(STACK_SIZE)) < 0) {
    error_exit("last malloc failed");
  }
  if (kthread_create(thread_func_sleep_for_1_xstatus_7, last_stack) >= 0) {
    error_exit("created too many threads");
     e8e:	55fd                	li	a1,-1
     e90:	00001517          	auipc	a0,0x1
     e94:	f0850513          	addi	a0,a0,-248 # 1d98 <csem_free+0x224>
     e98:	fffff097          	auipc	ra,0xfffff
     e9c:	336080e7          	jalr	822(ra) # 1ce <error_exit_core>
    tids[i] = kthread_create(f, stacks[i]);
     ea0:	8556                	mv	a0,s5
     ea2:	00000097          	auipc	ra,0x0
     ea6:	6ec080e7          	jalr	1772(ra) # 158e <kthread_create>
    if (tids[i] < 0) {
     eaa:	fc0549e3          	bltz	a0,e7c <max_threads_exec_by_created_they_exit_after_1+0x36>
     eae:	2485                	addiw	s1,s1,1
    stacks[i] = malloc(STACK_SIZE);
     eb0:	854e                	mv	a0,s3
     eb2:	00001097          	auipc	ra,0x1
     eb6:	ab4080e7          	jalr	-1356(ra) # 1966 <malloc>
     eba:	85aa                	mv	a1,a0
    if (i == 5) {
     ebc:	ff2482e3          	beq	s1,s2,ea0 <max_threads_exec_by_created_they_exit_after_1+0x5a>
    tids[i] = kthread_create(f, stacks[i]);
     ec0:	8552                	mv	a0,s4
     ec2:	00000097          	auipc	ra,0x0
     ec6:	6cc080e7          	jalr	1740(ra) # 158e <kthread_create>
    if (tids[i] < 0) {
     eca:	fa0549e3          	bltz	a0,e7c <max_threads_exec_by_created_they_exit_after_1+0x36>
  for (int i = 0; i < NTHREAD - 1; i++) {
     ece:	0004879b          	sext.w	a5,s1
     ed2:	fcf95ee3          	bge	s2,a5,eae <max_threads_exec_by_created_they_exit_after_1+0x68>
  if ((last_stack = malloc(STACK_SIZE)) < 0) {
     ed6:	6505                	lui	a0,0x1
     ed8:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     edc:	00001097          	auipc	ra,0x1
     ee0:	a8a080e7          	jalr	-1398(ra) # 1966 <malloc>
     ee4:	84aa                	mv	s1,a0
  if (kthread_create(thread_func_sleep_for_1_xstatus_7, last_stack) >= 0) {
     ee6:	85aa                	mv	a1,a0
     ee8:	fffff517          	auipc	a0,0xfffff
     eec:	15850513          	addi	a0,a0,344 # 40 <thread_func_sleep_for_1_xstatus_7>
     ef0:	00000097          	auipc	ra,0x0
     ef4:	69e080e7          	jalr	1694(ra) # 158e <kthread_create>
     ef8:	f8055be3          	bgez	a0,e8e <max_threads_exec_by_created_they_exit_after_1+0x48>
  }
  free(last_stack);
     efc:	8526                	mv	a0,s1
     efe:	00001097          	auipc	ra,0x1
     f02:	9e0080e7          	jalr	-1568(ra) # 18de <free>
  
  sleep(1);
     f06:	4505                	li	a0,1
     f08:	00000097          	auipc	ra,0x0
     f0c:	65e080e7          	jalr	1630(ra) # 1566 <sleep>
  kthread_exit(8);
     f10:	4521                	li	a0,8
     f12:	00000097          	auipc	ra,0x0
     f16:	68c080e7          	jalr	1676(ra) # 159e <kthread_exit>
}
     f1a:	70e2                	ld	ra,56(sp)
     f1c:	7442                	ld	s0,48(sp)
     f1e:	74a2                	ld	s1,40(sp)
     f20:	7902                	ld	s2,32(sp)
     f22:	69e2                	ld	s3,24(sp)
     f24:	6a42                	ld	s4,16(sp)
     f26:	6aa2                	ld	s5,8(sp)
     f28:	6121                	addi	sp,sp,64
     f2a:	8082                	ret

0000000000000f2c <max_threads_fork>:

void max_threads_fork(char *s) {
     f2c:	7139                	addi	sp,sp,-64
     f2e:	fc06                	sd	ra,56(sp)
     f30:	f822                	sd	s0,48(sp)
     f32:	f426                	sd	s1,40(sp)
     f34:	f04a                	sd	s2,32(sp)
     f36:	ec4e                	sd	s3,24(sp)
     f38:	0080                	addi	s0,sp,64
  int child_xstatus;
  int child_pid;
  void *stacks[NTHREAD - 1];
  int tids[NTHREAD - 1];
  void *last_stack;
  int my_tid = kthread_id();
     f3a:	00000097          	auipc	ra,0x0
     f3e:	65c080e7          	jalr	1628(ra) # 1596 <kthread_id>
     f42:	449d                	li	s1,7

  print("thread %d started", my_tid);
  for (int i = 0; i < NTHREAD - 1; i++) {
    stacks[i] = malloc(STACK_SIZE);
     f44:	6905                	lui	s2,0x1
     f46:	fa090913          	addi	s2,s2,-96 # fa0 <max_threads_fork+0x74>
    if (stacks[i] < 0) {
      error_exit("malloc failed");
    }
    tids[i] = kthread_create(thread_func_run_forever, stacks[i]);
     f4a:	fffff997          	auipc	s3,0xfffff
     f4e:	15c98993          	addi	s3,s3,348 # a6 <thread_func_run_forever>
    stacks[i] = malloc(STACK_SIZE);
     f52:	854a                	mv	a0,s2
     f54:	00001097          	auipc	ra,0x1
     f58:	a12080e7          	jalr	-1518(ra) # 1966 <malloc>
     f5c:	85aa                	mv	a1,a0
    tids[i] = kthread_create(thread_func_run_forever, stacks[i]);
     f5e:	854e                	mv	a0,s3
     f60:	00000097          	auipc	ra,0x0
     f64:	62e080e7          	jalr	1582(ra) # 158e <kthread_create>
    if (tids[i] < 0) {
     f68:	04054063          	bltz	a0,fa8 <max_threads_fork+0x7c>
  for (int i = 0; i < NTHREAD - 1; i++) {
     f6c:	34fd                	addiw	s1,s1,-1
     f6e:	f0f5                	bnez	s1,f52 <max_threads_fork+0x26>
    }

    print("created thread %d", tids[i]);
  }

  if ((last_stack = malloc(STACK_SIZE)) < 0) {
     f70:	6505                	lui	a0,0x1
     f72:	fa050513          	addi	a0,a0,-96 # fa0 <max_threads_fork+0x74>
     f76:	00001097          	auipc	ra,0x1
     f7a:	9f0080e7          	jalr	-1552(ra) # 1966 <malloc>
     f7e:	84aa                	mv	s1,a0
    error_exit("last malloc failed");
  }
  if (kthread_create(thread_func_run_forever, last_stack) >= 0) {
     f80:	85aa                	mv	a1,a0
     f82:	fffff517          	auipc	a0,0xfffff
     f86:	12450513          	addi	a0,a0,292 # a6 <thread_func_run_forever>
     f8a:	00000097          	auipc	ra,0x0
     f8e:	604080e7          	jalr	1540(ra) # 158e <kthread_create>
     f92:	02054463          	bltz	a0,fba <max_threads_fork+0x8e>
    error_exit("created too many threads");
     f96:	55fd                	li	a1,-1
     f98:	00001517          	auipc	a0,0x1
     f9c:	e0050513          	addi	a0,a0,-512 # 1d98 <csem_free+0x224>
     fa0:	fffff097          	auipc	ra,0xfffff
     fa4:	22e080e7          	jalr	558(ra) # 1ce <error_exit_core>
      error_exit("kthread_create failed");
     fa8:	55fd                	li	a1,-1
     faa:	00001517          	auipc	a0,0x1
     fae:	da650513          	addi	a0,a0,-602 # 1d50 <csem_free+0x1dc>
     fb2:	fffff097          	auipc	ra,0xfffff
     fb6:	21c080e7          	jalr	540(ra) # 1ce <error_exit_core>
  }
  if (kthread_create(thread_func_run_forever, last_stack) >= 0) {
     fba:	85a6                	mv	a1,s1
     fbc:	fffff517          	auipc	a0,0xfffff
     fc0:	0ea50513          	addi	a0,a0,234 # a6 <thread_func_run_forever>
     fc4:	00000097          	auipc	ra,0x0
     fc8:	5ca080e7          	jalr	1482(ra) # 158e <kthread_create>
     fcc:	00054b63          	bltz	a0,fe2 <max_threads_fork+0xb6>
    error_exit("created too many threads 2");
     fd0:	55fd                	li	a1,-1
     fd2:	00001517          	auipc	a0,0x1
     fd6:	de650513          	addi	a0,a0,-538 # 1db8 <csem_free+0x244>
     fda:	fffff097          	auipc	ra,0xfffff
     fde:	1f4080e7          	jalr	500(ra) # 1ce <error_exit_core>
  }
  free(last_stack);
     fe2:	8526                	mv	a0,s1
     fe4:	00001097          	auipc	ra,0x1
     fe8:	8fa080e7          	jalr	-1798(ra) # 18de <free>
  
  print("going to sleep");
  sleep(5);
     fec:	4515                	li	a0,5
     fee:	00000097          	auipc	ra,0x0
     ff2:	578080e7          	jalr	1400(ra) # 1566 <sleep>
  print("forking...");
  child_pid = fork();
     ff6:	00000097          	auipc	ra,0x0
     ffa:	4d8080e7          	jalr	1240(ra) # 14ce <fork>
  if (child_pid < 0) {
     ffe:	00054f63          	bltz	a0,101c <max_threads_fork+0xf0>
    error_exit("fork failed");
  }
  else if (child_pid == 0) {
    1002:	e515                	bnez	a0,102e <max_threads_fork+0x102>
    test_name = "fork max threads join";
    1004:	00001517          	auipc	a0,0x1
    1008:	de450513          	addi	a0,a0,-540 # 1de8 <csem_free+0x274>
    100c:	00001797          	auipc	a5,0x1
    1010:	34a7ba23          	sd	a0,852(a5) # 2360 <test_name>
    max_threads_join(test_name);
    1014:	00000097          	auipc	ra,0x0
    1018:	8c0080e7          	jalr	-1856(ra) # 8d4 <max_threads_join>
    error_exit("fork failed");
    101c:	55fd                	li	a1,-1
    101e:	00001517          	auipc	a0,0x1
    1022:	dba50513          	addi	a0,a0,-582 # 1dd8 <csem_free+0x264>
    1026:	fffff097          	auipc	ra,0xfffff
    102a:	1a8080e7          	jalr	424(ra) # 1ce <error_exit_core>
    exit(9);
  }

  print("waiting...");
  if (wait(&child_xstatus) < 0) {
    102e:	fcc40513          	addi	a0,s0,-52
    1032:	00000097          	auipc	ra,0x0
    1036:	4ac080e7          	jalr	1196(ra) # 14de <wait>
    103a:	00054763          	bltz	a0,1048 <max_threads_fork+0x11c>
    error_exit("wait failed");
  }

  exit(8);
    103e:	4521                	li	a0,8
    1040:	00000097          	auipc	ra,0x0
    1044:	496080e7          	jalr	1174(ra) # 14d6 <exit>
    error_exit("wait failed");
    1048:	55fd                	li	a1,-1
    104a:	00001517          	auipc	a0,0x1
    104e:	db650513          	addi	a0,a0,-586 # 1e00 <csem_free+0x28c>
    1052:	fffff097          	auipc	ra,0xfffff
    1056:	17c080e7          	jalr	380(ra) # 1ce <error_exit_core>

000000000000105a <run_for_core>:
void run_for_core(int ticks) {
    105a:	1101                	addi	sp,sp,-32
    105c:	ec06                	sd	ra,24(sp)
    105e:	e822                	sd	s0,16(sp)
    1060:	e426                	sd	s1,8(sp)
    1062:	e04a                	sd	s2,0(sp)
    1064:	1000                	addi	s0,sp,32
    1066:	892a                	mv	s2,a0
  int t0 = uptime();
    1068:	00000097          	auipc	ra,0x0
    106c:	506080e7          	jalr	1286(ra) # 156e <uptime>
    1070:	84aa                	mv	s1,a0
  while (uptime() - t0 <= ticks) {
    1072:	00000097          	auipc	ra,0x0
    1076:	4fc080e7          	jalr	1276(ra) # 156e <uptime>
    107a:	9d05                	subw	a0,a0,s1
    107c:	fea95be3          	bge	s2,a0,1072 <run_for_core+0x18>
}
    1080:	60e2                	ld	ra,24(sp)
    1082:	6442                	ld	s0,16(sp)
    1084:	64a2                	ld	s1,8(sp)
    1086:	6902                	ld	s2,0(sp)
    1088:	6105                	addi	sp,sp,32
    108a:	8082                	ret

000000000000108c <thread_func_run_for_5_xstatus_74>:
void thread_func_run_for_5_xstatus_74() {
    108c:	1141                	addi	sp,sp,-16
    108e:	e406                	sd	ra,8(sp)
    1090:	e022                	sd	s0,0(sp)
    1092:	0800                	addi	s0,sp,16
  int my_tid = kthread_id();
    1094:	00000097          	auipc	ra,0x0
    1098:	502080e7          	jalr	1282(ra) # 1596 <kthread_id>
    run_for_core(ticks);
    109c:	4515                	li	a0,5
    109e:	00000097          	auipc	ra,0x0
    10a2:	fbc080e7          	jalr	-68(ra) # 105a <run_for_core>
  kthread_exit(74);
    10a6:	04a00513          	li	a0,74
    10aa:	00000097          	auipc	ra,0x0
    10ae:	4f4080e7          	jalr	1268(ra) # 159e <kthread_exit>
}
    10b2:	60a2                	ld	ra,8(sp)
    10b4:	6402                	ld	s0,0(sp)
    10b6:	0141                	addi	sp,sp,16
    10b8:	8082                	ret

00000000000010ba <run_for>:
  if (ticks >= 0) {
    10ba:	00054e63          	bltz	a0,10d6 <run_for+0x1c>
void run_for(int ticks) {
    10be:	1141                	addi	sp,sp,-16
    10c0:	e406                	sd	ra,8(sp)
    10c2:	e022                	sd	s0,0(sp)
    10c4:	0800                	addi	s0,sp,16
    run_for_core(ticks);
    10c6:	00000097          	auipc	ra,0x0
    10ca:	f94080e7          	jalr	-108(ra) # 105a <run_for_core>
}
    10ce:	60a2                	ld	ra,8(sp)
    10d0:	6402                	ld	s0,0(sp)
    10d2:	0141                	addi	sp,sp,16
    10d4:	8082                	ret
  while (1) {
    10d6:	a001                	j	10d6 <run_for+0x1c>

00000000000010d8 <exec_test_simple_func>:
void exec_test_simple_func() {
    10d8:	1141                	addi	sp,sp,-16
    10da:	e406                	sd	ra,8(sp)
    10dc:	e022                	sd	s0,0(sp)
    10de:	0800                	addi	s0,sp,16
  test_name = "exec simple thread create";
    10e0:	00001517          	auipc	a0,0x1
    10e4:	d3050513          	addi	a0,a0,-720 # 1e10 <csem_free+0x29c>
    10e8:	00001797          	auipc	a5,0x1
    10ec:	26a7bc23          	sd	a0,632(a5) # 2360 <test_name>
  create_thread_exit_simple(test_name);
    10f0:	fffff097          	auipc	ra,0xfffff
    10f4:	10e080e7          	jalr	270(ra) # 1fe <create_thread_exit_simple>
  exit(6);
    10f8:	4519                	li	a0,6
    10fa:	00000097          	auipc	ra,0x0
    10fe:	3dc080e7          	jalr	988(ra) # 14d6 <exit>

0000000000001102 <exec_test_func>:
void exec_test_func() {
    1102:	1141                	addi	sp,sp,-16
    1104:	e406                	sd	ra,8(sp)
    1106:	e022                	sd	s0,0(sp)
    1108:	0800                	addi	s0,sp,16
  test_name = "exec max threads join";
    110a:	00001517          	auipc	a0,0x1
    110e:	d2650513          	addi	a0,a0,-730 # 1e30 <csem_free+0x2bc>
    1112:	00001797          	auipc	a5,0x1
    1116:	24a7b723          	sd	a0,590(a5) # 2360 <test_name>
  max_threads_join(test_name);
    111a:	fffff097          	auipc	ra,0xfffff
    111e:	7ba080e7          	jalr	1978(ra) # 8d4 <max_threads_join>

0000000000001122 <find_test_by_name>:
    .expected_exit_status = 8,
    .repeat_count = 3
  },
};

struct test *find_test_by_name(char *name) {
    1122:	7179                	addi	sp,sp,-48
    1124:	f406                	sd	ra,40(sp)
    1126:	f022                	sd	s0,32(sp)
    1128:	ec26                	sd	s1,24(sp)
    112a:	e84a                	sd	s2,16(sp)
    112c:	e44e                	sd	s3,8(sp)
    112e:	1800                	addi	s0,sp,48
    1130:	892a                	mv	s2,a0
  for (struct test *test = tests; test < &tests[sizeof(tests) / sizeof(tests[0])]; test++) {
    1132:	00001497          	auipc	s1,0x1
    1136:	08e48493          	addi	s1,s1,142 # 21c0 <tests>
    113a:	00001997          	auipc	s3,0x1
    113e:	21e98993          	addi	s3,s3,542 # 2358 <shared>
    if (strcmp(test->name, name) == 0) {
    1142:	85ca                	mv	a1,s2
    1144:	6488                	ld	a0,8(s1)
    1146:	00000097          	auipc	ra,0x0
    114a:	13e080e7          	jalr	318(ra) # 1284 <strcmp>
    114e:	c509                	beqz	a0,1158 <find_test_by_name+0x36>
  for (struct test *test = tests; test < &tests[sizeof(tests) / sizeof(tests[0])]; test++) {
    1150:	04e1                	addi	s1,s1,24
    1152:	ff3498e3          	bne	s1,s3,1142 <find_test_by_name+0x20>
      return test;
    }
  }
  return 0;
    1156:	4481                	li	s1,0
}
    1158:	8526                	mv	a0,s1
    115a:	70a2                	ld	ra,40(sp)
    115c:	7402                	ld	s0,32(sp)
    115e:	64e2                	ld	s1,24(sp)
    1160:	6942                	ld	s2,16(sp)
    1162:	69a2                	ld	s3,8(sp)
    1164:	6145                	addi	sp,sp,48
    1166:	8082                	ret

0000000000001168 <main>:

void main(int argc, char *argv[]) {
    1168:	7139                	addi	sp,sp,-64
    116a:	fc06                	sd	ra,56(sp)
    116c:	f822                	sd	s0,48(sp)
    116e:	f426                	sd	s1,40(sp)
    1170:	f04a                	sd	s2,32(sp)
    1172:	ec4e                	sd	s3,24(sp)
    1174:	e852                	sd	s4,16(sp)
    1176:	e456                	sd	s5,8(sp)
    1178:	0080                	addi	s0,sp,64
    117a:	892a                	mv	s2,a0
  int success = 1;
  if (argc == 1) {
    117c:	4785                	li	a5,1
    117e:	02f50163          	beq	a0,a5,11a0 <main+0x38>
    1182:	84ae                	mv	s1,a1
      if (!run(test)) {
        success = 0;
      }
    }
  }
  else if (argc == 2 && strcmp(argv[1], exec_simple_argv[1]) == 0) {
    1184:	4789                	li	a5,2
    1186:	04f50163          	beq	a0,a5,11c8 <main+0x60>
  else if (argc == 2 && strcmp(argv[1], exec_argv[1]) == 0) {
    exec_test_func();
  }
  else {
    // run tests specified by argv
    for (int i = 1; i < argc; i++) {
    118a:	4785                	li	a5,1
    118c:	0ca7d163          	bge	a5,a0,124e <main+0xe6>
    1190:	04a1                	addi	s1,s1,8
        success = 0;
    1192:	4985                	li	s3,1
    1194:	4a05                	li	s4,1
      struct test *test = find_test_by_name(argv[i]);
      if (!test) {
        printf("ERR: could not find test with name %s\n", argv[i]);
    1196:	00001a97          	auipc	s5,0x1
    119a:	cb2a8a93          	addi	s5,s5,-846 # 1e48 <csem_free+0x2d4>
    119e:	a89d                	j	1214 <main+0xac>
    for (struct test *test = tests; test < &tests[sizeof(tests) / sizeof(tests[0])]; test++) {
    11a0:	00001497          	auipc	s1,0x1
    11a4:	02048493          	addi	s1,s1,32 # 21c0 <tests>
    11a8:	00001997          	auipc	s3,0x1
    11ac:	1b098993          	addi	s3,s3,432 # 2358 <shared>
    11b0:	a021                	j	11b8 <main+0x50>
    11b2:	04e1                	addi	s1,s1,24
    11b4:	07348e63          	beq	s1,s3,1230 <main+0xc8>
      if (!run(test)) {
    11b8:	8526                	mv	a0,s1
    11ba:	fffff097          	auipc	ra,0xfffff
    11be:	f1c080e7          	jalr	-228(ra) # d6 <run>
    11c2:	f965                	bnez	a0,11b2 <main+0x4a>
        success = 0;
    11c4:	892a                	mv	s2,a0
    11c6:	b7f5                	j	11b2 <main+0x4a>
  else if (argc == 2 && strcmp(argv[1], exec_simple_argv[1]) == 0) {
    11c8:	00001597          	auipc	a1,0x1
    11cc:	fe85b583          	ld	a1,-24(a1) # 21b0 <exec_simple_argv+0x8>
    11d0:	6488                	ld	a0,8(s1)
    11d2:	00000097          	auipc	ra,0x0
    11d6:	0b2080e7          	jalr	178(ra) # 1284 <strcmp>
    11da:	cd19                	beqz	a0,11f8 <main+0x90>
  else if (argc == 2 && strcmp(argv[1], exec_argv[1]) == 0) {
    11dc:	00001597          	auipc	a1,0x1
    11e0:	fbc5b583          	ld	a1,-68(a1) # 2198 <exec_argv+0x8>
    11e4:	6488                	ld	a0,8(s1)
    11e6:	00000097          	auipc	ra,0x0
    11ea:	09e080e7          	jalr	158(ra) # 1284 <strcmp>
    11ee:	f14d                	bnez	a0,1190 <main+0x28>
    exec_test_func();
    11f0:	00000097          	auipc	ra,0x0
    11f4:	f12080e7          	jalr	-238(ra) # 1102 <exec_test_func>
    exec_test_simple_func();
    11f8:	00000097          	auipc	ra,0x0
    11fc:	ee0080e7          	jalr	-288(ra) # 10d8 <exec_test_simple_func>
        printf("ERR: could not find test with name %s\n", argv[i]);
    1200:	608c                	ld	a1,0(s1)
    1202:	8556                	mv	a0,s5
    1204:	00000097          	auipc	ra,0x0
    1208:	6a4080e7          	jalr	1700(ra) # 18a8 <printf>
    for (int i = 1; i < argc; i++) {
    120c:	2985                	addiw	s3,s3,1
    120e:	04a1                	addi	s1,s1,8
    1210:	0129df63          	bge	s3,s2,122e <main+0xc6>
      struct test *test = find_test_by_name(argv[i]);
    1214:	6088                	ld	a0,0(s1)
    1216:	00000097          	auipc	ra,0x0
    121a:	f0c080e7          	jalr	-244(ra) # 1122 <find_test_by_name>
      if (!test) {
    121e:	d16d                	beqz	a0,1200 <main+0x98>
        continue;
      }
      if (!run(test)) {
    1220:	fffff097          	auipc	ra,0xfffff
    1224:	eb6080e7          	jalr	-330(ra) # d6 <run>
    1228:	f175                	bnez	a0,120c <main+0xa4>
        success = 0;
    122a:	8a2a                	mv	s4,a0
    122c:	b7c5                	j	120c <main+0xa4>
    122e:	8952                	mv	s2,s4
      }
    }
  }

  if (success) {
    1230:	00091f63          	bnez	s2,124e <main+0xe6>
    printf("ALL TESTS PASSED\n");
    exit(0);
  }
  else {
    printf("SOME TESTS FAILED\n");
    1234:	00001517          	auipc	a0,0x1
    1238:	c5450513          	addi	a0,a0,-940 # 1e88 <csem_free+0x314>
    123c:	00000097          	auipc	ra,0x0
    1240:	66c080e7          	jalr	1644(ra) # 18a8 <printf>
    exit(1);
    1244:	4505                	li	a0,1
    1246:	00000097          	auipc	ra,0x0
    124a:	290080e7          	jalr	656(ra) # 14d6 <exit>
    printf("ALL TESTS PASSED\n");
    124e:	00001517          	auipc	a0,0x1
    1252:	c2250513          	addi	a0,a0,-990 # 1e70 <csem_free+0x2fc>
    1256:	00000097          	auipc	ra,0x0
    125a:	652080e7          	jalr	1618(ra) # 18a8 <printf>
    exit(0);
    125e:	4501                	li	a0,0
    1260:	00000097          	auipc	ra,0x0
    1264:	276080e7          	jalr	630(ra) # 14d6 <exit>

0000000000001268 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    1268:	1141                	addi	sp,sp,-16
    126a:	e422                	sd	s0,8(sp)
    126c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    126e:	87aa                	mv	a5,a0
    1270:	0585                	addi	a1,a1,1
    1272:	0785                	addi	a5,a5,1
    1274:	fff5c703          	lbu	a4,-1(a1)
    1278:	fee78fa3          	sb	a4,-1(a5)
    127c:	fb75                	bnez	a4,1270 <strcpy+0x8>
    ;
  return os;
}
    127e:	6422                	ld	s0,8(sp)
    1280:	0141                	addi	sp,sp,16
    1282:	8082                	ret

0000000000001284 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    1284:	1141                	addi	sp,sp,-16
    1286:	e422                	sd	s0,8(sp)
    1288:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    128a:	00054783          	lbu	a5,0(a0)
    128e:	cb91                	beqz	a5,12a2 <strcmp+0x1e>
    1290:	0005c703          	lbu	a4,0(a1)
    1294:	00f71763          	bne	a4,a5,12a2 <strcmp+0x1e>
    p++, q++;
    1298:	0505                	addi	a0,a0,1
    129a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    129c:	00054783          	lbu	a5,0(a0)
    12a0:	fbe5                	bnez	a5,1290 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    12a2:	0005c503          	lbu	a0,0(a1)
}
    12a6:	40a7853b          	subw	a0,a5,a0
    12aa:	6422                	ld	s0,8(sp)
    12ac:	0141                	addi	sp,sp,16
    12ae:	8082                	ret

00000000000012b0 <strlen>:

uint
strlen(const char *s)
{
    12b0:	1141                	addi	sp,sp,-16
    12b2:	e422                	sd	s0,8(sp)
    12b4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    12b6:	00054783          	lbu	a5,0(a0)
    12ba:	cf91                	beqz	a5,12d6 <strlen+0x26>
    12bc:	0505                	addi	a0,a0,1
    12be:	87aa                	mv	a5,a0
    12c0:	4685                	li	a3,1
    12c2:	9e89                	subw	a3,a3,a0
    12c4:	00f6853b          	addw	a0,a3,a5
    12c8:	0785                	addi	a5,a5,1
    12ca:	fff7c703          	lbu	a4,-1(a5)
    12ce:	fb7d                	bnez	a4,12c4 <strlen+0x14>
    ;
  return n;
}
    12d0:	6422                	ld	s0,8(sp)
    12d2:	0141                	addi	sp,sp,16
    12d4:	8082                	ret
  for(n = 0; s[n]; n++)
    12d6:	4501                	li	a0,0
    12d8:	bfe5                	j	12d0 <strlen+0x20>

00000000000012da <memset>:

void*
memset(void *dst, int c, uint n)
{
    12da:	1141                	addi	sp,sp,-16
    12dc:	e422                	sd	s0,8(sp)
    12de:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    12e0:	ca19                	beqz	a2,12f6 <memset+0x1c>
    12e2:	87aa                	mv	a5,a0
    12e4:	1602                	slli	a2,a2,0x20
    12e6:	9201                	srli	a2,a2,0x20
    12e8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    12ec:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    12f0:	0785                	addi	a5,a5,1
    12f2:	fee79de3          	bne	a5,a4,12ec <memset+0x12>
  }
  return dst;
}
    12f6:	6422                	ld	s0,8(sp)
    12f8:	0141                	addi	sp,sp,16
    12fa:	8082                	ret

00000000000012fc <strchr>:

char*
strchr(const char *s, char c)
{
    12fc:	1141                	addi	sp,sp,-16
    12fe:	e422                	sd	s0,8(sp)
    1300:	0800                	addi	s0,sp,16
  for(; *s; s++)
    1302:	00054783          	lbu	a5,0(a0)
    1306:	cb99                	beqz	a5,131c <strchr+0x20>
    if(*s == c)
    1308:	00f58763          	beq	a1,a5,1316 <strchr+0x1a>
  for(; *s; s++)
    130c:	0505                	addi	a0,a0,1
    130e:	00054783          	lbu	a5,0(a0)
    1312:	fbfd                	bnez	a5,1308 <strchr+0xc>
      return (char*)s;
  return 0;
    1314:	4501                	li	a0,0
}
    1316:	6422                	ld	s0,8(sp)
    1318:	0141                	addi	sp,sp,16
    131a:	8082                	ret
  return 0;
    131c:	4501                	li	a0,0
    131e:	bfe5                	j	1316 <strchr+0x1a>

0000000000001320 <gets>:

char*
gets(char *buf, int max)
{
    1320:	711d                	addi	sp,sp,-96
    1322:	ec86                	sd	ra,88(sp)
    1324:	e8a2                	sd	s0,80(sp)
    1326:	e4a6                	sd	s1,72(sp)
    1328:	e0ca                	sd	s2,64(sp)
    132a:	fc4e                	sd	s3,56(sp)
    132c:	f852                	sd	s4,48(sp)
    132e:	f456                	sd	s5,40(sp)
    1330:	f05a                	sd	s6,32(sp)
    1332:	ec5e                	sd	s7,24(sp)
    1334:	1080                	addi	s0,sp,96
    1336:	8baa                	mv	s7,a0
    1338:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    133a:	892a                	mv	s2,a0
    133c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    133e:	4aa9                	li	s5,10
    1340:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    1342:	89a6                	mv	s3,s1
    1344:	2485                	addiw	s1,s1,1
    1346:	0344d863          	bge	s1,s4,1376 <gets+0x56>
    cc = read(0, &c, 1);
    134a:	4605                	li	a2,1
    134c:	faf40593          	addi	a1,s0,-81
    1350:	4501                	li	a0,0
    1352:	00000097          	auipc	ra,0x0
    1356:	19c080e7          	jalr	412(ra) # 14ee <read>
    if(cc < 1)
    135a:	00a05e63          	blez	a0,1376 <gets+0x56>
    buf[i++] = c;
    135e:	faf44783          	lbu	a5,-81(s0)
    1362:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    1366:	01578763          	beq	a5,s5,1374 <gets+0x54>
    136a:	0905                	addi	s2,s2,1
    136c:	fd679be3          	bne	a5,s6,1342 <gets+0x22>
  for(i=0; i+1 < max; ){
    1370:	89a6                	mv	s3,s1
    1372:	a011                	j	1376 <gets+0x56>
    1374:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    1376:	99de                	add	s3,s3,s7
    1378:	00098023          	sb	zero,0(s3)
  return buf;
}
    137c:	855e                	mv	a0,s7
    137e:	60e6                	ld	ra,88(sp)
    1380:	6446                	ld	s0,80(sp)
    1382:	64a6                	ld	s1,72(sp)
    1384:	6906                	ld	s2,64(sp)
    1386:	79e2                	ld	s3,56(sp)
    1388:	7a42                	ld	s4,48(sp)
    138a:	7aa2                	ld	s5,40(sp)
    138c:	7b02                	ld	s6,32(sp)
    138e:	6be2                	ld	s7,24(sp)
    1390:	6125                	addi	sp,sp,96
    1392:	8082                	ret

0000000000001394 <stat>:

int
stat(const char *n, struct stat *st)
{
    1394:	1101                	addi	sp,sp,-32
    1396:	ec06                	sd	ra,24(sp)
    1398:	e822                	sd	s0,16(sp)
    139a:	e426                	sd	s1,8(sp)
    139c:	e04a                	sd	s2,0(sp)
    139e:	1000                	addi	s0,sp,32
    13a0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    13a2:	4581                	li	a1,0
    13a4:	00000097          	auipc	ra,0x0
    13a8:	172080e7          	jalr	370(ra) # 1516 <open>
  if(fd < 0)
    13ac:	02054563          	bltz	a0,13d6 <stat+0x42>
    13b0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    13b2:	85ca                	mv	a1,s2
    13b4:	00000097          	auipc	ra,0x0
    13b8:	17a080e7          	jalr	378(ra) # 152e <fstat>
    13bc:	892a                	mv	s2,a0
  close(fd);
    13be:	8526                	mv	a0,s1
    13c0:	00000097          	auipc	ra,0x0
    13c4:	13e080e7          	jalr	318(ra) # 14fe <close>
  return r;
}
    13c8:	854a                	mv	a0,s2
    13ca:	60e2                	ld	ra,24(sp)
    13cc:	6442                	ld	s0,16(sp)
    13ce:	64a2                	ld	s1,8(sp)
    13d0:	6902                	ld	s2,0(sp)
    13d2:	6105                	addi	sp,sp,32
    13d4:	8082                	ret
    return -1;
    13d6:	597d                	li	s2,-1
    13d8:	bfc5                	j	13c8 <stat+0x34>

00000000000013da <atoi>:

int
atoi(const char *s)
{
    13da:	1141                	addi	sp,sp,-16
    13dc:	e422                	sd	s0,8(sp)
    13de:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    13e0:	00054603          	lbu	a2,0(a0)
    13e4:	fd06079b          	addiw	a5,a2,-48
    13e8:	0ff7f793          	zext.b	a5,a5
    13ec:	4725                	li	a4,9
    13ee:	02f76963          	bltu	a4,a5,1420 <atoi+0x46>
    13f2:	86aa                	mv	a3,a0
  n = 0;
    13f4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    13f6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    13f8:	0685                	addi	a3,a3,1
    13fa:	0025179b          	slliw	a5,a0,0x2
    13fe:	9fa9                	addw	a5,a5,a0
    1400:	0017979b          	slliw	a5,a5,0x1
    1404:	9fb1                	addw	a5,a5,a2
    1406:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    140a:	0006c603          	lbu	a2,0(a3)
    140e:	fd06071b          	addiw	a4,a2,-48
    1412:	0ff77713          	zext.b	a4,a4
    1416:	fee5f1e3          	bgeu	a1,a4,13f8 <atoi+0x1e>
  return n;
}
    141a:	6422                	ld	s0,8(sp)
    141c:	0141                	addi	sp,sp,16
    141e:	8082                	ret
  n = 0;
    1420:	4501                	li	a0,0
    1422:	bfe5                	j	141a <atoi+0x40>

0000000000001424 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    1424:	1141                	addi	sp,sp,-16
    1426:	e422                	sd	s0,8(sp)
    1428:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    142a:	02b57463          	bgeu	a0,a1,1452 <memmove+0x2e>
    while(n-- > 0)
    142e:	00c05f63          	blez	a2,144c <memmove+0x28>
    1432:	1602                	slli	a2,a2,0x20
    1434:	9201                	srli	a2,a2,0x20
    1436:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    143a:	872a                	mv	a4,a0
      *dst++ = *src++;
    143c:	0585                	addi	a1,a1,1
    143e:	0705                	addi	a4,a4,1
    1440:	fff5c683          	lbu	a3,-1(a1)
    1444:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    1448:	fee79ae3          	bne	a5,a4,143c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    144c:	6422                	ld	s0,8(sp)
    144e:	0141                	addi	sp,sp,16
    1450:	8082                	ret
    dst += n;
    1452:	00c50733          	add	a4,a0,a2
    src += n;
    1456:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    1458:	fec05ae3          	blez	a2,144c <memmove+0x28>
    145c:	fff6079b          	addiw	a5,a2,-1
    1460:	1782                	slli	a5,a5,0x20
    1462:	9381                	srli	a5,a5,0x20
    1464:	fff7c793          	not	a5,a5
    1468:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    146a:	15fd                	addi	a1,a1,-1
    146c:	177d                	addi	a4,a4,-1
    146e:	0005c683          	lbu	a3,0(a1)
    1472:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    1476:	fee79ae3          	bne	a5,a4,146a <memmove+0x46>
    147a:	bfc9                	j	144c <memmove+0x28>

000000000000147c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    147c:	1141                	addi	sp,sp,-16
    147e:	e422                	sd	s0,8(sp)
    1480:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    1482:	ca05                	beqz	a2,14b2 <memcmp+0x36>
    1484:	fff6069b          	addiw	a3,a2,-1
    1488:	1682                	slli	a3,a3,0x20
    148a:	9281                	srli	a3,a3,0x20
    148c:	0685                	addi	a3,a3,1
    148e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    1490:	00054783          	lbu	a5,0(a0)
    1494:	0005c703          	lbu	a4,0(a1)
    1498:	00e79863          	bne	a5,a4,14a8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    149c:	0505                	addi	a0,a0,1
    p2++;
    149e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    14a0:	fed518e3          	bne	a0,a3,1490 <memcmp+0x14>
  }
  return 0;
    14a4:	4501                	li	a0,0
    14a6:	a019                	j	14ac <memcmp+0x30>
      return *p1 - *p2;
    14a8:	40e7853b          	subw	a0,a5,a4
}
    14ac:	6422                	ld	s0,8(sp)
    14ae:	0141                	addi	sp,sp,16
    14b0:	8082                	ret
  return 0;
    14b2:	4501                	li	a0,0
    14b4:	bfe5                	j	14ac <memcmp+0x30>

00000000000014b6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    14b6:	1141                	addi	sp,sp,-16
    14b8:	e406                	sd	ra,8(sp)
    14ba:	e022                	sd	s0,0(sp)
    14bc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    14be:	00000097          	auipc	ra,0x0
    14c2:	f66080e7          	jalr	-154(ra) # 1424 <memmove>
}
    14c6:	60a2                	ld	ra,8(sp)
    14c8:	6402                	ld	s0,0(sp)
    14ca:	0141                	addi	sp,sp,16
    14cc:	8082                	ret

00000000000014ce <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    14ce:	4885                	li	a7,1
 ecall
    14d0:	00000073          	ecall
 ret
    14d4:	8082                	ret

00000000000014d6 <exit>:
.global exit
exit:
 li a7, SYS_exit
    14d6:	4889                	li	a7,2
 ecall
    14d8:	00000073          	ecall
 ret
    14dc:	8082                	ret

00000000000014de <wait>:
.global wait
wait:
 li a7, SYS_wait
    14de:	488d                	li	a7,3
 ecall
    14e0:	00000073          	ecall
 ret
    14e4:	8082                	ret

00000000000014e6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    14e6:	4891                	li	a7,4
 ecall
    14e8:	00000073          	ecall
 ret
    14ec:	8082                	ret

00000000000014ee <read>:
.global read
read:
 li a7, SYS_read
    14ee:	4895                	li	a7,5
 ecall
    14f0:	00000073          	ecall
 ret
    14f4:	8082                	ret

00000000000014f6 <write>:
.global write
write:
 li a7, SYS_write
    14f6:	48c1                	li	a7,16
 ecall
    14f8:	00000073          	ecall
 ret
    14fc:	8082                	ret

00000000000014fe <close>:
.global close
close:
 li a7, SYS_close
    14fe:	48d5                	li	a7,21
 ecall
    1500:	00000073          	ecall
 ret
    1504:	8082                	ret

0000000000001506 <kill>:
.global kill
kill:
 li a7, SYS_kill
    1506:	4899                	li	a7,6
 ecall
    1508:	00000073          	ecall
 ret
    150c:	8082                	ret

000000000000150e <exec>:
.global exec
exec:
 li a7, SYS_exec
    150e:	489d                	li	a7,7
 ecall
    1510:	00000073          	ecall
 ret
    1514:	8082                	ret

0000000000001516 <open>:
.global open
open:
 li a7, SYS_open
    1516:	48bd                	li	a7,15
 ecall
    1518:	00000073          	ecall
 ret
    151c:	8082                	ret

000000000000151e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    151e:	48c5                	li	a7,17
 ecall
    1520:	00000073          	ecall
 ret
    1524:	8082                	ret

0000000000001526 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    1526:	48c9                	li	a7,18
 ecall
    1528:	00000073          	ecall
 ret
    152c:	8082                	ret

000000000000152e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    152e:	48a1                	li	a7,8
 ecall
    1530:	00000073          	ecall
 ret
    1534:	8082                	ret

0000000000001536 <link>:
.global link
link:
 li a7, SYS_link
    1536:	48cd                	li	a7,19
 ecall
    1538:	00000073          	ecall
 ret
    153c:	8082                	ret

000000000000153e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    153e:	48d1                	li	a7,20
 ecall
    1540:	00000073          	ecall
 ret
    1544:	8082                	ret

0000000000001546 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    1546:	48a5                	li	a7,9
 ecall
    1548:	00000073          	ecall
 ret
    154c:	8082                	ret

000000000000154e <dup>:
.global dup
dup:
 li a7, SYS_dup
    154e:	48a9                	li	a7,10
 ecall
    1550:	00000073          	ecall
 ret
    1554:	8082                	ret

0000000000001556 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    1556:	48ad                	li	a7,11
 ecall
    1558:	00000073          	ecall
 ret
    155c:	8082                	ret

000000000000155e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    155e:	48b1                	li	a7,12
 ecall
    1560:	00000073          	ecall
 ret
    1564:	8082                	ret

0000000000001566 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    1566:	48b5                	li	a7,13
 ecall
    1568:	00000073          	ecall
 ret
    156c:	8082                	ret

000000000000156e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    156e:	48b9                	li	a7,14
 ecall
    1570:	00000073          	ecall
 ret
    1574:	8082                	ret

0000000000001576 <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
    1576:	48d9                	li	a7,22
 ecall
    1578:	00000073          	ecall
 ret
    157c:	8082                	ret

000000000000157e <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
    157e:	48dd                	li	a7,23
 ecall
    1580:	00000073          	ecall
 ret
    1584:	8082                	ret

0000000000001586 <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
    1586:	48e1                	li	a7,24
 ecall
    1588:	00000073          	ecall
 ret
    158c:	8082                	ret

000000000000158e <kthread_create>:
.global kthread_create
kthread_create:
 li a7, SYS_kthread_create
    158e:	48e5                	li	a7,25
 ecall
    1590:	00000073          	ecall
 ret
    1594:	8082                	ret

0000000000001596 <kthread_id>:
.global kthread_id
kthread_id:
 li a7, SYS_kthread_id
    1596:	48e9                	li	a7,26
 ecall
    1598:	00000073          	ecall
 ret
    159c:	8082                	ret

000000000000159e <kthread_exit>:
.global kthread_exit
kthread_exit:
 li a7, SYS_kthread_exit
    159e:	48ed                	li	a7,27
 ecall
    15a0:	00000073          	ecall
 ret
    15a4:	8082                	ret

00000000000015a6 <kthread_join>:
.global kthread_join
kthread_join:
 li a7, SYS_kthread_join
    15a6:	48f1                	li	a7,28
 ecall
    15a8:	00000073          	ecall
 ret
    15ac:	8082                	ret

00000000000015ae <bsem_alloc>:
.global bsem_alloc
bsem_alloc:
 li a7, SYS_bsem_alloc
    15ae:	48f5                	li	a7,29
 ecall
    15b0:	00000073          	ecall
 ret
    15b4:	8082                	ret

00000000000015b6 <bsem_free>:
.global bsem_free
bsem_free:
 li a7, SYS_bsem_free
    15b6:	48f9                	li	a7,30
 ecall
    15b8:	00000073          	ecall
 ret
    15bc:	8082                	ret

00000000000015be <bsem_down>:
.global bsem_down
bsem_down:
 li a7, SYS_bsem_down
    15be:	48fd                	li	a7,31
 ecall
    15c0:	00000073          	ecall
 ret
    15c4:	8082                	ret

00000000000015c6 <bsem_up>:
.global bsem_up
bsem_up:
 li a7, SYS_bsem_up
    15c6:	02000893          	li	a7,32
 ecall
    15ca:	00000073          	ecall
 ret
    15ce:	8082                	ret

00000000000015d0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    15d0:	1101                	addi	sp,sp,-32
    15d2:	ec06                	sd	ra,24(sp)
    15d4:	e822                	sd	s0,16(sp)
    15d6:	1000                	addi	s0,sp,32
    15d8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    15dc:	4605                	li	a2,1
    15de:	fef40593          	addi	a1,s0,-17
    15e2:	00000097          	auipc	ra,0x0
    15e6:	f14080e7          	jalr	-236(ra) # 14f6 <write>
}
    15ea:	60e2                	ld	ra,24(sp)
    15ec:	6442                	ld	s0,16(sp)
    15ee:	6105                	addi	sp,sp,32
    15f0:	8082                	ret

00000000000015f2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    15f2:	7139                	addi	sp,sp,-64
    15f4:	fc06                	sd	ra,56(sp)
    15f6:	f822                	sd	s0,48(sp)
    15f8:	f426                	sd	s1,40(sp)
    15fa:	f04a                	sd	s2,32(sp)
    15fc:	ec4e                	sd	s3,24(sp)
    15fe:	0080                	addi	s0,sp,64
    1600:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    1602:	c299                	beqz	a3,1608 <printint+0x16>
    1604:	0805c863          	bltz	a1,1694 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    1608:	2581                	sext.w	a1,a1
  neg = 0;
    160a:	4881                	li	a7,0
    160c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
    1610:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
    1612:	2601                	sext.w	a2,a2
    1614:	00001517          	auipc	a0,0x1
    1618:	af450513          	addi	a0,a0,-1292 # 2108 <digits>
    161c:	883a                	mv	a6,a4
    161e:	2705                	addiw	a4,a4,1
    1620:	02c5f7bb          	remuw	a5,a1,a2
    1624:	1782                	slli	a5,a5,0x20
    1626:	9381                	srli	a5,a5,0x20
    1628:	97aa                	add	a5,a5,a0
    162a:	0007c783          	lbu	a5,0(a5)
    162e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
    1632:	0005879b          	sext.w	a5,a1
    1636:	02c5d5bb          	divuw	a1,a1,a2
    163a:	0685                	addi	a3,a3,1
    163c:	fec7f0e3          	bgeu	a5,a2,161c <printint+0x2a>
  if(neg)
    1640:	00088b63          	beqz	a7,1656 <printint+0x64>
    buf[i++] = '-';
    1644:	fd040793          	addi	a5,s0,-48
    1648:	973e                	add	a4,a4,a5
    164a:	02d00793          	li	a5,45
    164e:	fef70823          	sb	a5,-16(a4)
    1652:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    1656:	02e05863          	blez	a4,1686 <printint+0x94>
    165a:	fc040793          	addi	a5,s0,-64
    165e:	00e78933          	add	s2,a5,a4
    1662:	fff78993          	addi	s3,a5,-1
    1666:	99ba                	add	s3,s3,a4
    1668:	377d                	addiw	a4,a4,-1
    166a:	1702                	slli	a4,a4,0x20
    166c:	9301                	srli	a4,a4,0x20
    166e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
    1672:	fff94583          	lbu	a1,-1(s2)
    1676:	8526                	mv	a0,s1
    1678:	00000097          	auipc	ra,0x0
    167c:	f58080e7          	jalr	-168(ra) # 15d0 <putc>
  while(--i >= 0)
    1680:	197d                	addi	s2,s2,-1
    1682:	ff3918e3          	bne	s2,s3,1672 <printint+0x80>
}
    1686:	70e2                	ld	ra,56(sp)
    1688:	7442                	ld	s0,48(sp)
    168a:	74a2                	ld	s1,40(sp)
    168c:	7902                	ld	s2,32(sp)
    168e:	69e2                	ld	s3,24(sp)
    1690:	6121                	addi	sp,sp,64
    1692:	8082                	ret
    x = -xx;
    1694:	40b005bb          	negw	a1,a1
    neg = 1;
    1698:	4885                	li	a7,1
    x = -xx;
    169a:	bf8d                	j	160c <printint+0x1a>

000000000000169c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    169c:	7119                	addi	sp,sp,-128
    169e:	fc86                	sd	ra,120(sp)
    16a0:	f8a2                	sd	s0,112(sp)
    16a2:	f4a6                	sd	s1,104(sp)
    16a4:	f0ca                	sd	s2,96(sp)
    16a6:	ecce                	sd	s3,88(sp)
    16a8:	e8d2                	sd	s4,80(sp)
    16aa:	e4d6                	sd	s5,72(sp)
    16ac:	e0da                	sd	s6,64(sp)
    16ae:	fc5e                	sd	s7,56(sp)
    16b0:	f862                	sd	s8,48(sp)
    16b2:	f466                	sd	s9,40(sp)
    16b4:	f06a                	sd	s10,32(sp)
    16b6:	ec6e                	sd	s11,24(sp)
    16b8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    16ba:	0005c903          	lbu	s2,0(a1)
    16be:	18090f63          	beqz	s2,185c <vprintf+0x1c0>
    16c2:	8aaa                	mv	s5,a0
    16c4:	8b32                	mv	s6,a2
    16c6:	00158493          	addi	s1,a1,1
  state = 0;
    16ca:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    16cc:	02500a13          	li	s4,37
      if(c == 'd'){
    16d0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    16d4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    16d8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    16dc:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    16e0:	00001b97          	auipc	s7,0x1
    16e4:	a28b8b93          	addi	s7,s7,-1496 # 2108 <digits>
    16e8:	a839                	j	1706 <vprintf+0x6a>
        putc(fd, c);
    16ea:	85ca                	mv	a1,s2
    16ec:	8556                	mv	a0,s5
    16ee:	00000097          	auipc	ra,0x0
    16f2:	ee2080e7          	jalr	-286(ra) # 15d0 <putc>
    16f6:	a019                	j	16fc <vprintf+0x60>
    } else if(state == '%'){
    16f8:	01498f63          	beq	s3,s4,1716 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    16fc:	0485                	addi	s1,s1,1
    16fe:	fff4c903          	lbu	s2,-1(s1)
    1702:	14090d63          	beqz	s2,185c <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    1706:	0009079b          	sext.w	a5,s2
    if(state == 0){
    170a:	fe0997e3          	bnez	s3,16f8 <vprintf+0x5c>
      if(c == '%'){
    170e:	fd479ee3          	bne	a5,s4,16ea <vprintf+0x4e>
        state = '%';
    1712:	89be                	mv	s3,a5
    1714:	b7e5                	j	16fc <vprintf+0x60>
      if(c == 'd'){
    1716:	05878063          	beq	a5,s8,1756 <vprintf+0xba>
      } else if(c == 'l') {
    171a:	05978c63          	beq	a5,s9,1772 <vprintf+0xd6>
      } else if(c == 'x') {
    171e:	07a78863          	beq	a5,s10,178e <vprintf+0xf2>
      } else if(c == 'p') {
    1722:	09b78463          	beq	a5,s11,17aa <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    1726:	07300713          	li	a4,115
    172a:	0ce78663          	beq	a5,a4,17f6 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    172e:	06300713          	li	a4,99
    1732:	0ee78e63          	beq	a5,a4,182e <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    1736:	11478863          	beq	a5,s4,1846 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    173a:	85d2                	mv	a1,s4
    173c:	8556                	mv	a0,s5
    173e:	00000097          	auipc	ra,0x0
    1742:	e92080e7          	jalr	-366(ra) # 15d0 <putc>
        putc(fd, c);
    1746:	85ca                	mv	a1,s2
    1748:	8556                	mv	a0,s5
    174a:	00000097          	auipc	ra,0x0
    174e:	e86080e7          	jalr	-378(ra) # 15d0 <putc>
      }
      state = 0;
    1752:	4981                	li	s3,0
    1754:	b765                	j	16fc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    1756:	008b0913          	addi	s2,s6,8
    175a:	4685                	li	a3,1
    175c:	4629                	li	a2,10
    175e:	000b2583          	lw	a1,0(s6)
    1762:	8556                	mv	a0,s5
    1764:	00000097          	auipc	ra,0x0
    1768:	e8e080e7          	jalr	-370(ra) # 15f2 <printint>
    176c:	8b4a                	mv	s6,s2
      state = 0;
    176e:	4981                	li	s3,0
    1770:	b771                	j	16fc <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1772:	008b0913          	addi	s2,s6,8
    1776:	4681                	li	a3,0
    1778:	4629                	li	a2,10
    177a:	000b2583          	lw	a1,0(s6)
    177e:	8556                	mv	a0,s5
    1780:	00000097          	auipc	ra,0x0
    1784:	e72080e7          	jalr	-398(ra) # 15f2 <printint>
    1788:	8b4a                	mv	s6,s2
      state = 0;
    178a:	4981                	li	s3,0
    178c:	bf85                	j	16fc <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    178e:	008b0913          	addi	s2,s6,8
    1792:	4681                	li	a3,0
    1794:	4641                	li	a2,16
    1796:	000b2583          	lw	a1,0(s6)
    179a:	8556                	mv	a0,s5
    179c:	00000097          	auipc	ra,0x0
    17a0:	e56080e7          	jalr	-426(ra) # 15f2 <printint>
    17a4:	8b4a                	mv	s6,s2
      state = 0;
    17a6:	4981                	li	s3,0
    17a8:	bf91                	j	16fc <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    17aa:	008b0793          	addi	a5,s6,8
    17ae:	f8f43423          	sd	a5,-120(s0)
    17b2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    17b6:	03000593          	li	a1,48
    17ba:	8556                	mv	a0,s5
    17bc:	00000097          	auipc	ra,0x0
    17c0:	e14080e7          	jalr	-492(ra) # 15d0 <putc>
  putc(fd, 'x');
    17c4:	85ea                	mv	a1,s10
    17c6:	8556                	mv	a0,s5
    17c8:	00000097          	auipc	ra,0x0
    17cc:	e08080e7          	jalr	-504(ra) # 15d0 <putc>
    17d0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    17d2:	03c9d793          	srli	a5,s3,0x3c
    17d6:	97de                	add	a5,a5,s7
    17d8:	0007c583          	lbu	a1,0(a5)
    17dc:	8556                	mv	a0,s5
    17de:	00000097          	auipc	ra,0x0
    17e2:	df2080e7          	jalr	-526(ra) # 15d0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    17e6:	0992                	slli	s3,s3,0x4
    17e8:	397d                	addiw	s2,s2,-1
    17ea:	fe0914e3          	bnez	s2,17d2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    17ee:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    17f2:	4981                	li	s3,0
    17f4:	b721                	j	16fc <vprintf+0x60>
        s = va_arg(ap, char*);
    17f6:	008b0993          	addi	s3,s6,8
    17fa:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    17fe:	02090163          	beqz	s2,1820 <vprintf+0x184>
        while(*s != 0){
    1802:	00094583          	lbu	a1,0(s2)
    1806:	c9a1                	beqz	a1,1856 <vprintf+0x1ba>
          putc(fd, *s);
    1808:	8556                	mv	a0,s5
    180a:	00000097          	auipc	ra,0x0
    180e:	dc6080e7          	jalr	-570(ra) # 15d0 <putc>
          s++;
    1812:	0905                	addi	s2,s2,1
        while(*s != 0){
    1814:	00094583          	lbu	a1,0(s2)
    1818:	f9e5                	bnez	a1,1808 <vprintf+0x16c>
        s = va_arg(ap, char*);
    181a:	8b4e                	mv	s6,s3
      state = 0;
    181c:	4981                	li	s3,0
    181e:	bdf9                	j	16fc <vprintf+0x60>
          s = "(null)";
    1820:	00001917          	auipc	s2,0x1
    1824:	8e090913          	addi	s2,s2,-1824 # 2100 <csem_free+0x58c>
        while(*s != 0){
    1828:	02800593          	li	a1,40
    182c:	bff1                	j	1808 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    182e:	008b0913          	addi	s2,s6,8
    1832:	000b4583          	lbu	a1,0(s6)
    1836:	8556                	mv	a0,s5
    1838:	00000097          	auipc	ra,0x0
    183c:	d98080e7          	jalr	-616(ra) # 15d0 <putc>
    1840:	8b4a                	mv	s6,s2
      state = 0;
    1842:	4981                	li	s3,0
    1844:	bd65                	j	16fc <vprintf+0x60>
        putc(fd, c);
    1846:	85d2                	mv	a1,s4
    1848:	8556                	mv	a0,s5
    184a:	00000097          	auipc	ra,0x0
    184e:	d86080e7          	jalr	-634(ra) # 15d0 <putc>
      state = 0;
    1852:	4981                	li	s3,0
    1854:	b565                	j	16fc <vprintf+0x60>
        s = va_arg(ap, char*);
    1856:	8b4e                	mv	s6,s3
      state = 0;
    1858:	4981                	li	s3,0
    185a:	b54d                	j	16fc <vprintf+0x60>
    }
  }
}
    185c:	70e6                	ld	ra,120(sp)
    185e:	7446                	ld	s0,112(sp)
    1860:	74a6                	ld	s1,104(sp)
    1862:	7906                	ld	s2,96(sp)
    1864:	69e6                	ld	s3,88(sp)
    1866:	6a46                	ld	s4,80(sp)
    1868:	6aa6                	ld	s5,72(sp)
    186a:	6b06                	ld	s6,64(sp)
    186c:	7be2                	ld	s7,56(sp)
    186e:	7c42                	ld	s8,48(sp)
    1870:	7ca2                	ld	s9,40(sp)
    1872:	7d02                	ld	s10,32(sp)
    1874:	6de2                	ld	s11,24(sp)
    1876:	6109                	addi	sp,sp,128
    1878:	8082                	ret

000000000000187a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    187a:	715d                	addi	sp,sp,-80
    187c:	ec06                	sd	ra,24(sp)
    187e:	e822                	sd	s0,16(sp)
    1880:	1000                	addi	s0,sp,32
    1882:	e010                	sd	a2,0(s0)
    1884:	e414                	sd	a3,8(s0)
    1886:	e818                	sd	a4,16(s0)
    1888:	ec1c                	sd	a5,24(s0)
    188a:	03043023          	sd	a6,32(s0)
    188e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1892:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1896:	8622                	mv	a2,s0
    1898:	00000097          	auipc	ra,0x0
    189c:	e04080e7          	jalr	-508(ra) # 169c <vprintf>
}
    18a0:	60e2                	ld	ra,24(sp)
    18a2:	6442                	ld	s0,16(sp)
    18a4:	6161                	addi	sp,sp,80
    18a6:	8082                	ret

00000000000018a8 <printf>:

void
printf(const char *fmt, ...)
{
    18a8:	711d                	addi	sp,sp,-96
    18aa:	ec06                	sd	ra,24(sp)
    18ac:	e822                	sd	s0,16(sp)
    18ae:	1000                	addi	s0,sp,32
    18b0:	e40c                	sd	a1,8(s0)
    18b2:	e810                	sd	a2,16(s0)
    18b4:	ec14                	sd	a3,24(s0)
    18b6:	f018                	sd	a4,32(s0)
    18b8:	f41c                	sd	a5,40(s0)
    18ba:	03043823          	sd	a6,48(s0)
    18be:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    18c2:	00840613          	addi	a2,s0,8
    18c6:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    18ca:	85aa                	mv	a1,a0
    18cc:	4505                	li	a0,1
    18ce:	00000097          	auipc	ra,0x0
    18d2:	dce080e7          	jalr	-562(ra) # 169c <vprintf>
}
    18d6:	60e2                	ld	ra,24(sp)
    18d8:	6442                	ld	s0,16(sp)
    18da:	6125                	addi	sp,sp,96
    18dc:	8082                	ret

00000000000018de <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    18de:	1141                	addi	sp,sp,-16
    18e0:	e422                	sd	s0,8(sp)
    18e2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    18e4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    18e8:	00001797          	auipc	a5,0x1
    18ec:	a907b783          	ld	a5,-1392(a5) # 2378 <freep>
    18f0:	a805                	j	1920 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    18f2:	4618                	lw	a4,8(a2)
    18f4:	9db9                	addw	a1,a1,a4
    18f6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    18fa:	6398                	ld	a4,0(a5)
    18fc:	6318                	ld	a4,0(a4)
    18fe:	fee53823          	sd	a4,-16(a0)
    1902:	a091                	j	1946 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1904:	ff852703          	lw	a4,-8(a0)
    1908:	9e39                	addw	a2,a2,a4
    190a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    190c:	ff053703          	ld	a4,-16(a0)
    1910:	e398                	sd	a4,0(a5)
    1912:	a099                	j	1958 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1914:	6398                	ld	a4,0(a5)
    1916:	00e7e463          	bltu	a5,a4,191e <free+0x40>
    191a:	00e6ea63          	bltu	a3,a4,192e <free+0x50>
{
    191e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1920:	fed7fae3          	bgeu	a5,a3,1914 <free+0x36>
    1924:	6398                	ld	a4,0(a5)
    1926:	00e6e463          	bltu	a3,a4,192e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    192a:	fee7eae3          	bltu	a5,a4,191e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    192e:	ff852583          	lw	a1,-8(a0)
    1932:	6390                	ld	a2,0(a5)
    1934:	02059813          	slli	a6,a1,0x20
    1938:	01c85713          	srli	a4,a6,0x1c
    193c:	9736                	add	a4,a4,a3
    193e:	fae60ae3          	beq	a2,a4,18f2 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1942:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1946:	4790                	lw	a2,8(a5)
    1948:	02061593          	slli	a1,a2,0x20
    194c:	01c5d713          	srli	a4,a1,0x1c
    1950:	973e                	add	a4,a4,a5
    1952:	fae689e3          	beq	a3,a4,1904 <free+0x26>
  } else
    p->s.ptr = bp;
    1956:	e394                	sd	a3,0(a5)
  freep = p;
    1958:	00001717          	auipc	a4,0x1
    195c:	a2f73023          	sd	a5,-1504(a4) # 2378 <freep>
}
    1960:	6422                	ld	s0,8(sp)
    1962:	0141                	addi	sp,sp,16
    1964:	8082                	ret

0000000000001966 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1966:	7139                	addi	sp,sp,-64
    1968:	fc06                	sd	ra,56(sp)
    196a:	f822                	sd	s0,48(sp)
    196c:	f426                	sd	s1,40(sp)
    196e:	f04a                	sd	s2,32(sp)
    1970:	ec4e                	sd	s3,24(sp)
    1972:	e852                	sd	s4,16(sp)
    1974:	e456                	sd	s5,8(sp)
    1976:	e05a                	sd	s6,0(sp)
    1978:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    197a:	02051493          	slli	s1,a0,0x20
    197e:	9081                	srli	s1,s1,0x20
    1980:	04bd                	addi	s1,s1,15
    1982:	8091                	srli	s1,s1,0x4
    1984:	0014899b          	addiw	s3,s1,1
    1988:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    198a:	00001517          	auipc	a0,0x1
    198e:	9ee53503          	ld	a0,-1554(a0) # 2378 <freep>
    1992:	c515                	beqz	a0,19be <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1994:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1996:	4798                	lw	a4,8(a5)
    1998:	02977f63          	bgeu	a4,s1,19d6 <malloc+0x70>
    199c:	8a4e                	mv	s4,s3
    199e:	0009871b          	sext.w	a4,s3
    19a2:	6685                	lui	a3,0x1
    19a4:	00d77363          	bgeu	a4,a3,19aa <malloc+0x44>
    19a8:	6a05                	lui	s4,0x1
    19aa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    19ae:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    19b2:	00001917          	auipc	s2,0x1
    19b6:	9c690913          	addi	s2,s2,-1594 # 2378 <freep>
  if(p == (char*)-1)
    19ba:	5afd                	li	s5,-1
    19bc:	a895                	j	1a30 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    19be:	00001797          	auipc	a5,0x1
    19c2:	9c278793          	addi	a5,a5,-1598 # 2380 <base>
    19c6:	00001717          	auipc	a4,0x1
    19ca:	9af73923          	sd	a5,-1614(a4) # 2378 <freep>
    19ce:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    19d0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    19d4:	b7e1                	j	199c <malloc+0x36>
      if(p->s.size == nunits)
    19d6:	02e48c63          	beq	s1,a4,1a0e <malloc+0xa8>
        p->s.size -= nunits;
    19da:	4137073b          	subw	a4,a4,s3
    19de:	c798                	sw	a4,8(a5)
        p += p->s.size;
    19e0:	02071693          	slli	a3,a4,0x20
    19e4:	01c6d713          	srli	a4,a3,0x1c
    19e8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    19ea:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    19ee:	00001717          	auipc	a4,0x1
    19f2:	98a73523          	sd	a0,-1654(a4) # 2378 <freep>
      return (void*)(p + 1);
    19f6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    19fa:	70e2                	ld	ra,56(sp)
    19fc:	7442                	ld	s0,48(sp)
    19fe:	74a2                	ld	s1,40(sp)
    1a00:	7902                	ld	s2,32(sp)
    1a02:	69e2                	ld	s3,24(sp)
    1a04:	6a42                	ld	s4,16(sp)
    1a06:	6aa2                	ld	s5,8(sp)
    1a08:	6b02                	ld	s6,0(sp)
    1a0a:	6121                	addi	sp,sp,64
    1a0c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1a0e:	6398                	ld	a4,0(a5)
    1a10:	e118                	sd	a4,0(a0)
    1a12:	bff1                	j	19ee <malloc+0x88>
  hp->s.size = nu;
    1a14:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1a18:	0541                	addi	a0,a0,16
    1a1a:	00000097          	auipc	ra,0x0
    1a1e:	ec4080e7          	jalr	-316(ra) # 18de <free>
  return freep;
    1a22:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1a26:	d971                	beqz	a0,19fa <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1a28:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1a2a:	4798                	lw	a4,8(a5)
    1a2c:	fa9775e3          	bgeu	a4,s1,19d6 <malloc+0x70>
    if(p == freep)
    1a30:	00093703          	ld	a4,0(s2)
    1a34:	853e                	mv	a0,a5
    1a36:	fef719e3          	bne	a4,a5,1a28 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    1a3a:	8552                	mv	a0,s4
    1a3c:	00000097          	auipc	ra,0x0
    1a40:	b22080e7          	jalr	-1246(ra) # 155e <sbrk>
  if(p == (char*)-1)
    1a44:	fd5518e3          	bne	a0,s5,1a14 <malloc+0xae>
        return 0;
    1a48:	4501                	li	a0,0
    1a4a:	bf45                	j	19fa <malloc+0x94>

0000000000001a4c <csem_down>:
#include "Csemaphore.h"

struct counting_semaphore;

void 
csem_down(struct counting_semaphore *sem){
    1a4c:	1101                	addi	sp,sp,-32
    1a4e:	ec06                	sd	ra,24(sp)
    1a50:	e822                	sd	s0,16(sp)
    1a52:	e426                	sd	s1,8(sp)
    1a54:	1000                	addi	s0,sp,32
    if(!sem){
    1a56:	cd29                	beqz	a0,1ab0 <csem_down+0x64>
    1a58:	84aa                	mv	s1,a0
        printf("invalid sem pointer in csem_down\n");
        return;
    }
    
    bsem_down(sem->S1_desc);   //TODO: make sure works
    1a5a:	4108                	lw	a0,0(a0)
    1a5c:	00000097          	auipc	ra,0x0
    1a60:	b62080e7          	jalr	-1182(ra) # 15be <bsem_down>
    sem->waiting++;
    1a64:	44dc                	lw	a5,12(s1)
    1a66:	2785                	addiw	a5,a5,1
    1a68:	c4dc                	sw	a5,12(s1)
    bsem_up(sem->S1_desc);
    1a6a:	4088                	lw	a0,0(s1)
    1a6c:	00000097          	auipc	ra,0x0
    1a70:	b5a080e7          	jalr	-1190(ra) # 15c6 <bsem_up>

    bsem_down(sem->S2_desc);
    1a74:	40c8                	lw	a0,4(s1)
    1a76:	00000097          	auipc	ra,0x0
    1a7a:	b48080e7          	jalr	-1208(ra) # 15be <bsem_down>
    bsem_down(sem->S1_desc);
    1a7e:	4088                	lw	a0,0(s1)
    1a80:	00000097          	auipc	ra,0x0
    1a84:	b3e080e7          	jalr	-1218(ra) # 15be <bsem_down>
    sem->waiting--;
    1a88:	44dc                	lw	a5,12(s1)
    1a8a:	37fd                	addiw	a5,a5,-1
    1a8c:	c4dc                	sw	a5,12(s1)
    sem->value--;
    1a8e:	449c                	lw	a5,8(s1)
    1a90:	37fd                	addiw	a5,a5,-1
    1a92:	0007871b          	sext.w	a4,a5
    1a96:	c49c                	sw	a5,8(s1)
    if(sem->value > 0)
    1a98:	02e04563          	bgtz	a4,1ac2 <csem_down+0x76>
        bsem_up(sem->S2_desc);
    bsem_up(sem->S1_desc);
    1a9c:	4088                	lw	a0,0(s1)
    1a9e:	00000097          	auipc	ra,0x0
    1aa2:	b28080e7          	jalr	-1240(ra) # 15c6 <bsem_up>

}
    1aa6:	60e2                	ld	ra,24(sp)
    1aa8:	6442                	ld	s0,16(sp)
    1aaa:	64a2                	ld	s1,8(sp)
    1aac:	6105                	addi	sp,sp,32
    1aae:	8082                	ret
        printf("invalid sem pointer in csem_down\n");
    1ab0:	00000517          	auipc	a0,0x0
    1ab4:	67050513          	addi	a0,a0,1648 # 2120 <digits+0x18>
    1ab8:	00000097          	auipc	ra,0x0
    1abc:	df0080e7          	jalr	-528(ra) # 18a8 <printf>
        return;
    1ac0:	b7dd                	j	1aa6 <csem_down+0x5a>
        bsem_up(sem->S2_desc);
    1ac2:	40c8                	lw	a0,4(s1)
    1ac4:	00000097          	auipc	ra,0x0
    1ac8:	b02080e7          	jalr	-1278(ra) # 15c6 <bsem_up>
    1acc:	bfc1                	j	1a9c <csem_down+0x50>

0000000000001ace <csem_up>:

void            
csem_up(struct counting_semaphore *sem){
    1ace:	1101                	addi	sp,sp,-32
    1ad0:	ec06                	sd	ra,24(sp)
    1ad2:	e822                	sd	s0,16(sp)
    1ad4:	e426                	sd	s1,8(sp)
    1ad6:	1000                	addi	s0,sp,32
    if(!sem){
    1ad8:	c90d                	beqz	a0,1b0a <csem_up+0x3c>
    1ada:	84aa                	mv	s1,a0
        printf("invalid sem pointer in csem_up\n");
        return;
    }

    bsem_down(sem->S1_desc);
    1adc:	4108                	lw	a0,0(a0)
    1ade:	00000097          	auipc	ra,0x0
    1ae2:	ae0080e7          	jalr	-1312(ra) # 15be <bsem_down>
    sem->value++;
    1ae6:	449c                	lw	a5,8(s1)
    1ae8:	2785                	addiw	a5,a5,1
    1aea:	0007871b          	sext.w	a4,a5
    1aee:	c49c                	sw	a5,8(s1)
    if(sem->value == 1)
    1af0:	4785                	li	a5,1
    1af2:	02f70563          	beq	a4,a5,1b1c <csem_up+0x4e>
        bsem_up(sem->S2_desc);
    bsem_up(sem->S1_desc);
    1af6:	4088                	lw	a0,0(s1)
    1af8:	00000097          	auipc	ra,0x0
    1afc:	ace080e7          	jalr	-1330(ra) # 15c6 <bsem_up>
}
    1b00:	60e2                	ld	ra,24(sp)
    1b02:	6442                	ld	s0,16(sp)
    1b04:	64a2                	ld	s1,8(sp)
    1b06:	6105                	addi	sp,sp,32
    1b08:	8082                	ret
        printf("invalid sem pointer in csem_up\n");
    1b0a:	00000517          	auipc	a0,0x0
    1b0e:	63e50513          	addi	a0,a0,1598 # 2148 <digits+0x40>
    1b12:	00000097          	auipc	ra,0x0
    1b16:	d96080e7          	jalr	-618(ra) # 18a8 <printf>
        return;
    1b1a:	b7dd                	j	1b00 <csem_up+0x32>
        bsem_up(sem->S2_desc);
    1b1c:	40c8                	lw	a0,4(s1)
    1b1e:	00000097          	auipc	ra,0x0
    1b22:	aa8080e7          	jalr	-1368(ra) # 15c6 <bsem_up>
    1b26:	bfc1                	j	1af6 <csem_up+0x28>

0000000000001b28 <csem_alloc>:


int             
csem_alloc(struct counting_semaphore *sem, int initial_value){
    1b28:	1101                	addi	sp,sp,-32
    1b2a:	ec06                	sd	ra,24(sp)
    1b2c:	e822                	sd	s0,16(sp)
    1b2e:	e426                	sd	s1,8(sp)
    1b30:	e04a                	sd	s2,0(sp)
    1b32:	1000                	addi	s0,sp,32
    1b34:	84aa                	mv	s1,a0
    1b36:	892e                	mv	s2,a1
    sem->S1_desc = bsem_alloc();
    1b38:	00000097          	auipc	ra,0x0
    1b3c:	a76080e7          	jalr	-1418(ra) # 15ae <bsem_alloc>
    1b40:	c088                	sw	a0,0(s1)
    sem->S2_desc = bsem_alloc();
    1b42:	00000097          	auipc	ra,0x0
    1b46:	a6c080e7          	jalr	-1428(ra) # 15ae <bsem_alloc>
    1b4a:	c0c8                	sw	a0,4(s1)
    if(sem->S1_desc <0 || sem->S2_desc < 0)
    1b4c:	409c                	lw	a5,0(s1)
    1b4e:	0007cf63          	bltz	a5,1b6c <csem_alloc+0x44>
    1b52:	00054f63          	bltz	a0,1b70 <csem_alloc+0x48>
        return -1;
    sem->value = initial_value;
    1b56:	0124a423          	sw	s2,8(s1)
    sem->waiting = 0;
    1b5a:	0004a623          	sw	zero,12(s1)

    return 0;
    1b5e:	4501                	li	a0,0
}
    1b60:	60e2                	ld	ra,24(sp)
    1b62:	6442                	ld	s0,16(sp)
    1b64:	64a2                	ld	s1,8(sp)
    1b66:	6902                	ld	s2,0(sp)
    1b68:	6105                	addi	sp,sp,32
    1b6a:	8082                	ret
        return -1;
    1b6c:	557d                	li	a0,-1
    1b6e:	bfcd                	j	1b60 <csem_alloc+0x38>
    1b70:	557d                	li	a0,-1
    1b72:	b7fd                	j	1b60 <csem_alloc+0x38>

0000000000001b74 <csem_free>:
void            
csem_free(struct counting_semaphore *sem){
    1b74:	1101                	addi	sp,sp,-32
    1b76:	ec06                	sd	ra,24(sp)
    1b78:	e822                	sd	s0,16(sp)
    1b7a:	e426                	sd	s1,8(sp)
    1b7c:	1000                	addi	s0,sp,32
    if(!sem){
    1b7e:	c10d                	beqz	a0,1ba0 <csem_free+0x2c>
    1b80:	84aa                	mv	s1,a0
        printf("invalid sem pointer in csem_free\n");
        return;
    }

    bsem_free(sem->S1_desc);
    1b82:	4108                	lw	a0,0(a0)
    1b84:	00000097          	auipc	ra,0x0
    1b88:	a32080e7          	jalr	-1486(ra) # 15b6 <bsem_free>
    bsem_free(sem->S2_desc);
    1b8c:	40c8                	lw	a0,4(s1)
    1b8e:	00000097          	auipc	ra,0x0
    1b92:	a28080e7          	jalr	-1496(ra) # 15b6 <bsem_free>

    1b96:	60e2                	ld	ra,24(sp)
    1b98:	6442                	ld	s0,16(sp)
    1b9a:	64a2                	ld	s1,8(sp)
    1b9c:	6105                	addi	sp,sp,32
    1b9e:	8082                	ret
        printf("invalid sem pointer in csem_free\n");
    1ba0:	00000517          	auipc	a0,0x0
    1ba4:	5c850513          	addi	a0,a0,1480 # 2168 <digits+0x60>
    1ba8:	00000097          	auipc	ra,0x0
    1bac:	d00080e7          	jalr	-768(ra) # 18a8 <printf>
        return;
    1bb0:	b7dd                	j	1b96 <csem_free+0x22>
