
user/_signaltest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <sig_handler>:
};



void
sig_handler(int signum){
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
    char st[3] = "wap";
   8:	6799                	lui	a5,0x6
   a:	17778793          	addi	a5,a5,375 # 6177 <__global_pointer$+0x4c26>
   e:	fef41423          	sh	a5,-24(s0)
  12:	07000793          	li	a5,112
  16:	fef40523          	sb	a5,-22(s0)
    write(1, st, 3);
  1a:	460d                	li	a2,3
  1c:	fe840593          	addi	a1,s0,-24
  20:	4505                	li	a0,1
  22:	00000097          	auipc	ra,0x0
  26:	5b6080e7          	jalr	1462(ra) # 5d8 <write>
    return;
}
  2a:	60e2                	ld	ra,24(sp)
  2c:	6442                	ld	s0,16(sp)
  2e:	6105                	addi	sp,sp,32
  30:	8082                	ret

0000000000000032 <test_sigkill>:

void 
test_sigkill(){//
  32:	1101                	addi	sp,sp,-32
  34:	ec06                	sd	ra,24(sp)
  36:	e822                	sd	s0,16(sp)
  38:	e426                	sd	s1,8(sp)
  3a:	e04a                	sd	s2,0(sp)
  3c:	1000                	addi	s0,sp,32
   int pid = fork();
  3e:	00000097          	auipc	ra,0x0
  42:	572080e7          	jalr	1394(ra) # 5b0 <fork>
    if(pid==0){
  46:	e905                	bnez	a0,76 <test_sigkill+0x44>
        sleep(5);
  48:	4515                	li	a0,5
  4a:	00000097          	auipc	ra,0x0
  4e:	5fe080e7          	jalr	1534(ra) # 648 <sleep>
  52:	44f9                	li	s1,30
        for(int i=0;i<30;i++)
            printf("about to get killed\n");
  54:	00001917          	auipc	s2,0x1
  58:	a9c90913          	addi	s2,s2,-1380 # af0 <malloc+0xea>
  5c:	854a                	mv	a0,s2
  5e:	00001097          	auipc	ra,0x1
  62:	8ea080e7          	jalr	-1814(ra) # 948 <printf>
        for(int i=0;i<30;i++)
  66:	34fd                	addiw	s1,s1,-1
  68:	f8f5                	bnez	s1,5c <test_sigkill+0x2a>
        wait(0);
        printf("parent: child is dead\n");
        sleep(10);
        exit(0);
    }
}
  6a:	60e2                	ld	ra,24(sp)
  6c:	6442                	ld	s0,16(sp)
  6e:	64a2                	ld	s1,8(sp)
  70:	6902                	ld	s2,0(sp)
  72:	6105                	addi	sp,sp,32
  74:	8082                	ret
  76:	84aa                	mv	s1,a0
        printf("parent send signal to to kill child\n");
  78:	00001517          	auipc	a0,0x1
  7c:	a9050513          	addi	a0,a0,-1392 # b08 <malloc+0x102>
  80:	00001097          	auipc	ra,0x1
  84:	8c8080e7          	jalr	-1848(ra) # 948 <printf>
        printf("kill ret= %d\n",kill(pid, SIGKILL));
  88:	45a5                	li	a1,9
  8a:	8526                	mv	a0,s1
  8c:	00000097          	auipc	ra,0x0
  90:	55c080e7          	jalr	1372(ra) # 5e8 <kill>
  94:	85aa                	mv	a1,a0
  96:	00001517          	auipc	a0,0x1
  9a:	a9a50513          	addi	a0,a0,-1382 # b30 <malloc+0x12a>
  9e:	00001097          	auipc	ra,0x1
  a2:	8aa080e7          	jalr	-1878(ra) # 948 <printf>
        printf("parent wait for child\n");
  a6:	00001517          	auipc	a0,0x1
  aa:	a9a50513          	addi	a0,a0,-1382 # b40 <malloc+0x13a>
  ae:	00001097          	auipc	ra,0x1
  b2:	89a080e7          	jalr	-1894(ra) # 948 <printf>
        wait(0);
  b6:	4501                	li	a0,0
  b8:	00000097          	auipc	ra,0x0
  bc:	508080e7          	jalr	1288(ra) # 5c0 <wait>
        printf("parent: child is dead\n");
  c0:	00001517          	auipc	a0,0x1
  c4:	a9850513          	addi	a0,a0,-1384 # b58 <malloc+0x152>
  c8:	00001097          	auipc	ra,0x1
  cc:	880080e7          	jalr	-1920(ra) # 948 <printf>
        sleep(10);
  d0:	4529                	li	a0,10
  d2:	00000097          	auipc	ra,0x0
  d6:	576080e7          	jalr	1398(ra) # 648 <sleep>
        exit(0);
  da:	4501                	li	a0,0
  dc:	00000097          	auipc	ra,0x0
  e0:	4dc080e7          	jalr	1244(ra) # 5b8 <exit>

00000000000000e4 <test_stop_cont>:

void
test_stop_cont(){
  e4:	1101                	addi	sp,sp,-32
  e6:	ec06                	sd	ra,24(sp)
  e8:	e822                	sd	s0,16(sp)
  ea:	e426                	sd	s1,8(sp)
  ec:	e04a                	sd	s2,0(sp)
  ee:	1000                	addi	s0,sp,32
    int pid = fork();
  f0:	00000097          	auipc	ra,0x0
  f4:	4c0080e7          	jalr	1216(ra) # 5b0 <fork>
    if(pid==0){
  f8:	e505                	bnez	a0,120 <test_stop_cont+0x3c>
  fa:	06400493          	li	s1,100
        for(int i=0;i<100;i++)
            printf("child..\n ");
  fe:	00001917          	auipc	s2,0x1
 102:	a7290913          	addi	s2,s2,-1422 # b70 <malloc+0x16a>
 106:	854a                	mv	a0,s2
 108:	00001097          	auipc	ra,0x1
 10c:	840080e7          	jalr	-1984(ra) # 948 <printf>
        for(int i=0;i<100;i++)
 110:	34fd                	addiw	s1,s1,-1
 112:	f8f5                	bnez	s1,106 <test_stop_cont+0x22>
        sleep(10);
        exit(0);
    }
    

}
 114:	60e2                	ld	ra,24(sp)
 116:	6442                	ld	s0,16(sp)
 118:	64a2                	ld	s1,8(sp)
 11a:	6902                	ld	s2,0(sp)
 11c:	6105                	addi	sp,sp,32
 11e:	8082                	ret
 120:	84aa                	mv	s1,a0
        printf("sigstop ret= %d\n",kill(pid, SIGSTOP));
 122:	45c5                	li	a1,17
 124:	00000097          	auipc	ra,0x0
 128:	4c4080e7          	jalr	1220(ra) # 5e8 <kill>
 12c:	85aa                	mv	a1,a0
 12e:	00001517          	auipc	a0,0x1
 132:	a5250513          	addi	a0,a0,-1454 # b80 <malloc+0x17a>
 136:	00001097          	auipc	ra,0x1
 13a:	812080e7          	jalr	-2030(ra) # 948 <printf>
        sleep(5);
 13e:	4515                	li	a0,5
 140:	00000097          	auipc	ra,0x0
 144:	508080e7          	jalr	1288(ra) # 648 <sleep>
        printf("sigstop ret= %d\n",kill(pid, SIGCONT));
 148:	45cd                	li	a1,19
 14a:	8526                	mv	a0,s1
 14c:	00000097          	auipc	ra,0x0
 150:	49c080e7          	jalr	1180(ra) # 5e8 <kill>
 154:	85aa                	mv	a1,a0
 156:	00001517          	auipc	a0,0x1
 15a:	a2a50513          	addi	a0,a0,-1494 # b80 <malloc+0x17a>
 15e:	00000097          	auipc	ra,0x0
 162:	7ea080e7          	jalr	2026(ra) # 948 <printf>
        sleep(10);
 166:	4529                	li	a0,10
 168:	00000097          	auipc	ra,0x0
 16c:	4e0080e7          	jalr	1248(ra) # 648 <sleep>
        exit(0);
 170:	4501                	li	a0,0
 172:	00000097          	auipc	ra,0x0
 176:	446080e7          	jalr	1094(ra) # 5b8 <exit>

000000000000017a <test_usersig>:
void 
test_usersig(){//
 17a:	7179                	addi	sp,sp,-48
 17c:	f406                	sd	ra,40(sp)
 17e:	f022                	sd	s0,32(sp)
 180:	1800                	addi	s0,sp,48
   int pid = fork();
 182:	00000097          	auipc	ra,0x0
 186:	42e080e7          	jalr	1070(ra) # 5b0 <fork>
    if(pid==0){
 18a:	e515                	bnez	a0,1b6 <test_usersig+0x3c>
        struct sigaction act;
        act.sa_handler = &sig_handler;
 18c:	00000797          	auipc	a5,0x0
 190:	e7478793          	addi	a5,a5,-396 # 0 <sig_handler>
 194:	fcf43823          	sd	a5,-48(s0)
        act.sigmask = 0;
 198:	fc042c23          	sw	zero,-40(s0)
        struct sigaction oldact;
        sigaction(3,&act,&oldact);
 19c:	fe040613          	addi	a2,s0,-32
 1a0:	fd040593          	addi	a1,s0,-48
 1a4:	450d                	li	a0,3
 1a6:	00000097          	auipc	ra,0x0
 1aa:	4ba080e7          	jalr	1210(ra) # 660 <sigaction>
    }
    else{
      sleep(10);

    }
}
 1ae:	70a2                	ld	ra,40(sp)
 1b0:	7402                	ld	s0,32(sp)
 1b2:	6145                	addi	sp,sp,48
 1b4:	8082                	ret
      sleep(10);
 1b6:	4529                	li	a0,10
 1b8:	00000097          	auipc	ra,0x0
 1bc:	490080e7          	jalr	1168(ra) # 648 <sleep>
}
 1c0:	b7fd                	j	1ae <test_usersig+0x34>

00000000000001c2 <test_block>:
void 
test_block(){//parent block 22 child block 23 
 1c2:	1101                	addi	sp,sp,-32
 1c4:	ec06                	sd	ra,24(sp)
 1c6:	e822                	sd	s0,16(sp)
 1c8:	e426                	sd	s1,8(sp)
 1ca:	e04a                	sd	s2,0(sp)
 1cc:	1000                	addi	s0,sp,32
//          child get both signal and need do block the both

    int signum1=22;
    int signum2=23;
    int ans=sigprocmask(1<<signum1);
 1ce:	00400537          	lui	a0,0x400
 1d2:	00000097          	auipc	ra,0x0
 1d6:	486080e7          	jalr	1158(ra) # 658 <sigprocmask>
    printf("got %d from calling to sigprocmask\n",ans);
 1da:	0005059b          	sext.w	a1,a0
 1de:	00001517          	auipc	a0,0x1
 1e2:	9ba50513          	addi	a0,a0,-1606 # b98 <malloc+0x192>
 1e6:	00000097          	auipc	ra,0x0
 1ea:	762080e7          	jalr	1890(ra) # 948 <printf>
    int pid=fork();
 1ee:	00000097          	auipc	ra,0x0
 1f2:	3c2080e7          	jalr	962(ra) # 5b0 <fork>
    if(pid==0){
 1f6:	e139                	bnez	a0,23c <test_block+0x7a>
        ans=sigprocmask(1<<signum2);
 1f8:	00800537          	lui	a0,0x800
 1fc:	00000097          	auipc	ra,0x0
 200:	45c080e7          	jalr	1116(ra) # 658 <sigprocmask>
        printf("child got %d from calling to sigprocmask\n",ans);
 204:	0005059b          	sext.w	a1,a0
 208:	00001517          	auipc	a0,0x1
 20c:	9b850513          	addi	a0,a0,-1608 # bc0 <malloc+0x1ba>
 210:	00000097          	auipc	ra,0x0
 214:	738080e7          	jalr	1848(ra) # 948 <printf>
        sleep(3);
 218:	450d                	li	a0,3
 21a:	00000097          	auipc	ra,0x0
 21e:	42e080e7          	jalr	1070(ra) # 648 <sleep>
 222:	44a9                	li	s1,10
        for(int i=0;i<10;i++){
            printf("child blocking signal :-)\n");
 224:	00001917          	auipc	s2,0x1
 228:	9cc90913          	addi	s2,s2,-1588 # bf0 <malloc+0x1ea>
 22c:	854a                	mv	a0,s2
 22e:	00000097          	auipc	ra,0x0
 232:	71a080e7          	jalr	1818(ra) # 948 <printf>
        for(int i=0;i<10;i++){
 236:	34fd                	addiw	s1,s1,-1
 238:	f8f5                	bnez	s1,22c <test_block+0x6a>
 23a:	a099                	j	280 <test_block+0xbe>
 23c:	84aa                	mv	s1,a0
        }

    }else{
        sleep(1);//wait for child to block sig
 23e:	4505                	li	a0,1
 240:	00000097          	auipc	ra,0x0
 244:	408080e7          	jalr	1032(ra) # 648 <sleep>
        kill(pid,signum1);
 248:	45d9                	li	a1,22
 24a:	8526                	mv	a0,s1
 24c:	00000097          	auipc	ra,0x0
 250:	39c080e7          	jalr	924(ra) # 5e8 <kill>
        printf("parent: sent signal 22 to child ->child shuld block\n");
 254:	00001517          	auipc	a0,0x1
 258:	9bc50513          	addi	a0,a0,-1604 # c10 <malloc+0x20a>
 25c:	00000097          	auipc	ra,0x0
 260:	6ec080e7          	jalr	1772(ra) # 948 <printf>
        kill(pid,signum2);
 264:	45dd                	li	a1,23
 266:	8526                	mv	a0,s1
 268:	00000097          	auipc	ra,0x0
 26c:	380080e7          	jalr	896(ra) # 5e8 <kill>
        printf("parent: sent signal 23 to child ->child shuld block\n");
 270:	00001517          	auipc	a0,0x1
 274:	9d850513          	addi	a0,a0,-1576 # c48 <malloc+0x242>
 278:	00000097          	auipc	ra,0x0
 27c:	6d0080e7          	jalr	1744(ra) # 948 <printf>

    }
}
 280:	60e2                	ld	ra,24(sp)
 282:	6442                	ld	s0,16(sp)
 284:	64a2                	ld	s1,8(sp)
 286:	6902                	ld	s2,0(sp)
 288:	6105                	addi	sp,sp,32
 28a:	8082                	ret

000000000000028c <test_ignore>:

void 
test_ignore(){
 28c:	7139                	addi	sp,sp,-64
 28e:	fc06                	sd	ra,56(sp)
 290:	f822                	sd	s0,48(sp)
 292:	f426                	sd	s1,40(sp)
 294:	f04a                	sd	s2,32(sp)
 296:	0080                	addi	s0,sp,64
    int pid= fork();
 298:	00000097          	auipc	ra,0x0
 29c:	318080e7          	jalr	792(ra) # 5b0 <fork>
    int signum=22;
    if(pid==0){
 2a0:	ed31                	bnez	a0,2fc <test_ignore+0x70>
        struct sigaction newAct;
        struct sigaction oldAct;
        newAct.sigmask = 0;
 2a2:	fc042423          	sw	zero,-56(s0)
        newAct.sa_handler=(void*)SIG_IGN;
 2a6:	4785                	li	a5,1
 2a8:	fcf43023          	sd	a5,-64(s0)
        int ans=sigaction(signum,&newAct,&oldAct);
 2ac:	fd040613          	addi	a2,s0,-48
 2b0:	fc040593          	addi	a1,s0,-64
 2b4:	4559                	li	a0,22
 2b6:	00000097          	auipc	ra,0x0
 2ba:	3aa080e7          	jalr	938(ra) # 660 <sigaction>
 2be:	85aa                	mv	a1,a0
        printf("ans from sigaction %d, old act returned is: mask= %d address= %d",ans,oldAct.sigmask,(int)oldAct.sa_handler);
 2c0:	fd042683          	lw	a3,-48(s0)
 2c4:	fd842603          	lw	a2,-40(s0)
 2c8:	00001517          	auipc	a0,0x1
 2cc:	9b850513          	addi	a0,a0,-1608 # c80 <malloc+0x27a>
 2d0:	00000097          	auipc	ra,0x0
 2d4:	678080e7          	jalr	1656(ra) # 948 <printf>
        
        sleep(6);
 2d8:	4519                	li	a0,6
 2da:	00000097          	auipc	ra,0x0
 2de:	36e080e7          	jalr	878(ra) # 648 <sleep>
 2e2:	44a9                	li	s1,10
        for(int i=0;i<10;i++){
            printf("child ignoring signal :-)\n");
 2e4:	00001917          	auipc	s2,0x1
 2e8:	9e490913          	addi	s2,s2,-1564 # cc8 <malloc+0x2c2>
 2ec:	854a                	mv	a0,s2
 2ee:	00000097          	auipc	ra,0x0
 2f2:	65a080e7          	jalr	1626(ra) # 948 <printf>
        for(int i=0;i<10;i++){
 2f6:	34fd                	addiw	s1,s1,-1
 2f8:	f8f5                	bnez	s1,2ec <test_ignore+0x60>
 2fa:	a829                	j	314 <test_ignore+0x88>
 2fc:	84aa                	mv	s1,a0
        }
    }else{
        sleep(5);
 2fe:	4515                	li	a0,5
 300:	00000097          	auipc	ra,0x0
 304:	348080e7          	jalr	840(ra) # 648 <sleep>
        kill(pid,signum);
 308:	45d9                	li	a1,22
 30a:	8526                	mv	a0,s1
 30c:	00000097          	auipc	ra,0x0
 310:	2dc080e7          	jalr	732(ra) # 5e8 <kill>

    }
}
 314:	70e2                	ld	ra,56(sp)
 316:	7442                	ld	s0,48(sp)
 318:	74a2                	ld	s1,40(sp)
 31a:	7902                	ld	s2,32(sp)
 31c:	6121                	addi	sp,sp,64
 31e:	8082                	ret

0000000000000320 <main>:



int main(){
 320:	1141                	addi	sp,sp,-16
 322:	e406                	sd	ra,8(sp)
 324:	e022                	sd	s0,0(sp)
 326:	0800                	addi	s0,sp,16
    // printf("-----------------------------test_sigkill-----------------------------\n");
    // test_sigkill();

     printf("-----------------------------test_stop_cont_sig-----------------------------\n");
 328:	00001517          	auipc	a0,0x1
 32c:	9c050513          	addi	a0,a0,-1600 # ce8 <malloc+0x2e2>
 330:	00000097          	auipc	ra,0x0
 334:	618080e7          	jalr	1560(ra) # 948 <printf>
    test_stop_cont();
 338:	00000097          	auipc	ra,0x0
 33c:	dac080e7          	jalr	-596(ra) # e4 <test_stop_cont>
    // printf("-----------------------------test_block-----------------------------\n");
    // test_block();
    // printf("-----------------------------test_ignore-----------------------------\n");
    // test_ignore();
    return 0;
 340:	4501                	li	a0,0
 342:	60a2                	ld	ra,8(sp)
 344:	6402                	ld	s0,0(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret

000000000000034a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 34a:	1141                	addi	sp,sp,-16
 34c:	e422                	sd	s0,8(sp)
 34e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 350:	87aa                	mv	a5,a0
 352:	0585                	addi	a1,a1,1
 354:	0785                	addi	a5,a5,1
 356:	fff5c703          	lbu	a4,-1(a1)
 35a:	fee78fa3          	sb	a4,-1(a5)
 35e:	fb75                	bnez	a4,352 <strcpy+0x8>
    ;
  return os;
}
 360:	6422                	ld	s0,8(sp)
 362:	0141                	addi	sp,sp,16
 364:	8082                	ret

0000000000000366 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 366:	1141                	addi	sp,sp,-16
 368:	e422                	sd	s0,8(sp)
 36a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 36c:	00054783          	lbu	a5,0(a0)
 370:	cb91                	beqz	a5,384 <strcmp+0x1e>
 372:	0005c703          	lbu	a4,0(a1)
 376:	00f71763          	bne	a4,a5,384 <strcmp+0x1e>
    p++, q++;
 37a:	0505                	addi	a0,a0,1
 37c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 37e:	00054783          	lbu	a5,0(a0)
 382:	fbe5                	bnez	a5,372 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 384:	0005c503          	lbu	a0,0(a1)
}
 388:	40a7853b          	subw	a0,a5,a0
 38c:	6422                	ld	s0,8(sp)
 38e:	0141                	addi	sp,sp,16
 390:	8082                	ret

0000000000000392 <strlen>:

uint
strlen(const char *s)
{
 392:	1141                	addi	sp,sp,-16
 394:	e422                	sd	s0,8(sp)
 396:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 398:	00054783          	lbu	a5,0(a0)
 39c:	cf91                	beqz	a5,3b8 <strlen+0x26>
 39e:	0505                	addi	a0,a0,1
 3a0:	87aa                	mv	a5,a0
 3a2:	4685                	li	a3,1
 3a4:	9e89                	subw	a3,a3,a0
 3a6:	00f6853b          	addw	a0,a3,a5
 3aa:	0785                	addi	a5,a5,1
 3ac:	fff7c703          	lbu	a4,-1(a5)
 3b0:	fb7d                	bnez	a4,3a6 <strlen+0x14>
    ;
  return n;
}
 3b2:	6422                	ld	s0,8(sp)
 3b4:	0141                	addi	sp,sp,16
 3b6:	8082                	ret
  for(n = 0; s[n]; n++)
 3b8:	4501                	li	a0,0
 3ba:	bfe5                	j	3b2 <strlen+0x20>

00000000000003bc <memset>:

void*
memset(void *dst, int c, uint n)
{
 3bc:	1141                	addi	sp,sp,-16
 3be:	e422                	sd	s0,8(sp)
 3c0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3c2:	ca19                	beqz	a2,3d8 <memset+0x1c>
 3c4:	87aa                	mv	a5,a0
 3c6:	1602                	slli	a2,a2,0x20
 3c8:	9201                	srli	a2,a2,0x20
 3ca:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 3ce:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3d2:	0785                	addi	a5,a5,1
 3d4:	fee79de3          	bne	a5,a4,3ce <memset+0x12>
  }
  return dst;
}
 3d8:	6422                	ld	s0,8(sp)
 3da:	0141                	addi	sp,sp,16
 3dc:	8082                	ret

00000000000003de <strchr>:

char*
strchr(const char *s, char c)
{
 3de:	1141                	addi	sp,sp,-16
 3e0:	e422                	sd	s0,8(sp)
 3e2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3e4:	00054783          	lbu	a5,0(a0)
 3e8:	cb99                	beqz	a5,3fe <strchr+0x20>
    if(*s == c)
 3ea:	00f58763          	beq	a1,a5,3f8 <strchr+0x1a>
  for(; *s; s++)
 3ee:	0505                	addi	a0,a0,1
 3f0:	00054783          	lbu	a5,0(a0)
 3f4:	fbfd                	bnez	a5,3ea <strchr+0xc>
      return (char*)s;
  return 0;
 3f6:	4501                	li	a0,0
}
 3f8:	6422                	ld	s0,8(sp)
 3fa:	0141                	addi	sp,sp,16
 3fc:	8082                	ret
  return 0;
 3fe:	4501                	li	a0,0
 400:	bfe5                	j	3f8 <strchr+0x1a>

0000000000000402 <gets>:

char*
gets(char *buf, int max)
{
 402:	711d                	addi	sp,sp,-96
 404:	ec86                	sd	ra,88(sp)
 406:	e8a2                	sd	s0,80(sp)
 408:	e4a6                	sd	s1,72(sp)
 40a:	e0ca                	sd	s2,64(sp)
 40c:	fc4e                	sd	s3,56(sp)
 40e:	f852                	sd	s4,48(sp)
 410:	f456                	sd	s5,40(sp)
 412:	f05a                	sd	s6,32(sp)
 414:	ec5e                	sd	s7,24(sp)
 416:	1080                	addi	s0,sp,96
 418:	8baa                	mv	s7,a0
 41a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 41c:	892a                	mv	s2,a0
 41e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 420:	4aa9                	li	s5,10
 422:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 424:	89a6                	mv	s3,s1
 426:	2485                	addiw	s1,s1,1
 428:	0344d863          	bge	s1,s4,458 <gets+0x56>
    cc = read(0, &c, 1);
 42c:	4605                	li	a2,1
 42e:	faf40593          	addi	a1,s0,-81
 432:	4501                	li	a0,0
 434:	00000097          	auipc	ra,0x0
 438:	19c080e7          	jalr	412(ra) # 5d0 <read>
    if(cc < 1)
 43c:	00a05e63          	blez	a0,458 <gets+0x56>
    buf[i++] = c;
 440:	faf44783          	lbu	a5,-81(s0)
 444:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 448:	01578763          	beq	a5,s5,456 <gets+0x54>
 44c:	0905                	addi	s2,s2,1
 44e:	fd679be3          	bne	a5,s6,424 <gets+0x22>
  for(i=0; i+1 < max; ){
 452:	89a6                	mv	s3,s1
 454:	a011                	j	458 <gets+0x56>
 456:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 458:	99de                	add	s3,s3,s7
 45a:	00098023          	sb	zero,0(s3)
  return buf;
}
 45e:	855e                	mv	a0,s7
 460:	60e6                	ld	ra,88(sp)
 462:	6446                	ld	s0,80(sp)
 464:	64a6                	ld	s1,72(sp)
 466:	6906                	ld	s2,64(sp)
 468:	79e2                	ld	s3,56(sp)
 46a:	7a42                	ld	s4,48(sp)
 46c:	7aa2                	ld	s5,40(sp)
 46e:	7b02                	ld	s6,32(sp)
 470:	6be2                	ld	s7,24(sp)
 472:	6125                	addi	sp,sp,96
 474:	8082                	ret

0000000000000476 <stat>:

int
stat(const char *n, struct stat *st)
{
 476:	1101                	addi	sp,sp,-32
 478:	ec06                	sd	ra,24(sp)
 47a:	e822                	sd	s0,16(sp)
 47c:	e426                	sd	s1,8(sp)
 47e:	e04a                	sd	s2,0(sp)
 480:	1000                	addi	s0,sp,32
 482:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 484:	4581                	li	a1,0
 486:	00000097          	auipc	ra,0x0
 48a:	172080e7          	jalr	370(ra) # 5f8 <open>
  if(fd < 0)
 48e:	02054563          	bltz	a0,4b8 <stat+0x42>
 492:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 494:	85ca                	mv	a1,s2
 496:	00000097          	auipc	ra,0x0
 49a:	17a080e7          	jalr	378(ra) # 610 <fstat>
 49e:	892a                	mv	s2,a0
  close(fd);
 4a0:	8526                	mv	a0,s1
 4a2:	00000097          	auipc	ra,0x0
 4a6:	13e080e7          	jalr	318(ra) # 5e0 <close>
  return r;
}
 4aa:	854a                	mv	a0,s2
 4ac:	60e2                	ld	ra,24(sp)
 4ae:	6442                	ld	s0,16(sp)
 4b0:	64a2                	ld	s1,8(sp)
 4b2:	6902                	ld	s2,0(sp)
 4b4:	6105                	addi	sp,sp,32
 4b6:	8082                	ret
    return -1;
 4b8:	597d                	li	s2,-1
 4ba:	bfc5                	j	4aa <stat+0x34>

00000000000004bc <atoi>:

int
atoi(const char *s)
{
 4bc:	1141                	addi	sp,sp,-16
 4be:	e422                	sd	s0,8(sp)
 4c0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4c2:	00054603          	lbu	a2,0(a0)
 4c6:	fd06079b          	addiw	a5,a2,-48
 4ca:	0ff7f793          	andi	a5,a5,255
 4ce:	4725                	li	a4,9
 4d0:	02f76963          	bltu	a4,a5,502 <atoi+0x46>
 4d4:	86aa                	mv	a3,a0
  n = 0;
 4d6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 4d8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 4da:	0685                	addi	a3,a3,1
 4dc:	0025179b          	slliw	a5,a0,0x2
 4e0:	9fa9                	addw	a5,a5,a0
 4e2:	0017979b          	slliw	a5,a5,0x1
 4e6:	9fb1                	addw	a5,a5,a2
 4e8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4ec:	0006c603          	lbu	a2,0(a3)
 4f0:	fd06071b          	addiw	a4,a2,-48
 4f4:	0ff77713          	andi	a4,a4,255
 4f8:	fee5f1e3          	bgeu	a1,a4,4da <atoi+0x1e>
  return n;
}
 4fc:	6422                	ld	s0,8(sp)
 4fe:	0141                	addi	sp,sp,16
 500:	8082                	ret
  n = 0;
 502:	4501                	li	a0,0
 504:	bfe5                	j	4fc <atoi+0x40>

0000000000000506 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 506:	1141                	addi	sp,sp,-16
 508:	e422                	sd	s0,8(sp)
 50a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 50c:	02b57463          	bgeu	a0,a1,534 <memmove+0x2e>
    while(n-- > 0)
 510:	00c05f63          	blez	a2,52e <memmove+0x28>
 514:	1602                	slli	a2,a2,0x20
 516:	9201                	srli	a2,a2,0x20
 518:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 51c:	872a                	mv	a4,a0
      *dst++ = *src++;
 51e:	0585                	addi	a1,a1,1
 520:	0705                	addi	a4,a4,1
 522:	fff5c683          	lbu	a3,-1(a1)
 526:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 52a:	fee79ae3          	bne	a5,a4,51e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 52e:	6422                	ld	s0,8(sp)
 530:	0141                	addi	sp,sp,16
 532:	8082                	ret
    dst += n;
 534:	00c50733          	add	a4,a0,a2
    src += n;
 538:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 53a:	fec05ae3          	blez	a2,52e <memmove+0x28>
 53e:	fff6079b          	addiw	a5,a2,-1
 542:	1782                	slli	a5,a5,0x20
 544:	9381                	srli	a5,a5,0x20
 546:	fff7c793          	not	a5,a5
 54a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 54c:	15fd                	addi	a1,a1,-1
 54e:	177d                	addi	a4,a4,-1
 550:	0005c683          	lbu	a3,0(a1)
 554:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 558:	fee79ae3          	bne	a5,a4,54c <memmove+0x46>
 55c:	bfc9                	j	52e <memmove+0x28>

000000000000055e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 55e:	1141                	addi	sp,sp,-16
 560:	e422                	sd	s0,8(sp)
 562:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 564:	ca05                	beqz	a2,594 <memcmp+0x36>
 566:	fff6069b          	addiw	a3,a2,-1
 56a:	1682                	slli	a3,a3,0x20
 56c:	9281                	srli	a3,a3,0x20
 56e:	0685                	addi	a3,a3,1
 570:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 572:	00054783          	lbu	a5,0(a0)
 576:	0005c703          	lbu	a4,0(a1)
 57a:	00e79863          	bne	a5,a4,58a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 57e:	0505                	addi	a0,a0,1
    p2++;
 580:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 582:	fed518e3          	bne	a0,a3,572 <memcmp+0x14>
  }
  return 0;
 586:	4501                	li	a0,0
 588:	a019                	j	58e <memcmp+0x30>
      return *p1 - *p2;
 58a:	40e7853b          	subw	a0,a5,a4
}
 58e:	6422                	ld	s0,8(sp)
 590:	0141                	addi	sp,sp,16
 592:	8082                	ret
  return 0;
 594:	4501                	li	a0,0
 596:	bfe5                	j	58e <memcmp+0x30>

0000000000000598 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 598:	1141                	addi	sp,sp,-16
 59a:	e406                	sd	ra,8(sp)
 59c:	e022                	sd	s0,0(sp)
 59e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 5a0:	00000097          	auipc	ra,0x0
 5a4:	f66080e7          	jalr	-154(ra) # 506 <memmove>
}
 5a8:	60a2                	ld	ra,8(sp)
 5aa:	6402                	ld	s0,0(sp)
 5ac:	0141                	addi	sp,sp,16
 5ae:	8082                	ret

00000000000005b0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5b0:	4885                	li	a7,1
 ecall
 5b2:	00000073          	ecall
 ret
 5b6:	8082                	ret

00000000000005b8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 5b8:	4889                	li	a7,2
 ecall
 5ba:	00000073          	ecall
 ret
 5be:	8082                	ret

00000000000005c0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5c0:	488d                	li	a7,3
 ecall
 5c2:	00000073          	ecall
 ret
 5c6:	8082                	ret

00000000000005c8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5c8:	4891                	li	a7,4
 ecall
 5ca:	00000073          	ecall
 ret
 5ce:	8082                	ret

00000000000005d0 <read>:
.global read
read:
 li a7, SYS_read
 5d0:	4895                	li	a7,5
 ecall
 5d2:	00000073          	ecall
 ret
 5d6:	8082                	ret

00000000000005d8 <write>:
.global write
write:
 li a7, SYS_write
 5d8:	48c1                	li	a7,16
 ecall
 5da:	00000073          	ecall
 ret
 5de:	8082                	ret

00000000000005e0 <close>:
.global close
close:
 li a7, SYS_close
 5e0:	48d5                	li	a7,21
 ecall
 5e2:	00000073          	ecall
 ret
 5e6:	8082                	ret

00000000000005e8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 5e8:	4899                	li	a7,6
 ecall
 5ea:	00000073          	ecall
 ret
 5ee:	8082                	ret

00000000000005f0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5f0:	489d                	li	a7,7
 ecall
 5f2:	00000073          	ecall
 ret
 5f6:	8082                	ret

00000000000005f8 <open>:
.global open
open:
 li a7, SYS_open
 5f8:	48bd                	li	a7,15
 ecall
 5fa:	00000073          	ecall
 ret
 5fe:	8082                	ret

0000000000000600 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 600:	48c5                	li	a7,17
 ecall
 602:	00000073          	ecall
 ret
 606:	8082                	ret

0000000000000608 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 608:	48c9                	li	a7,18
 ecall
 60a:	00000073          	ecall
 ret
 60e:	8082                	ret

0000000000000610 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 610:	48a1                	li	a7,8
 ecall
 612:	00000073          	ecall
 ret
 616:	8082                	ret

0000000000000618 <link>:
.global link
link:
 li a7, SYS_link
 618:	48cd                	li	a7,19
 ecall
 61a:	00000073          	ecall
 ret
 61e:	8082                	ret

0000000000000620 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 620:	48d1                	li	a7,20
 ecall
 622:	00000073          	ecall
 ret
 626:	8082                	ret

0000000000000628 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 628:	48a5                	li	a7,9
 ecall
 62a:	00000073          	ecall
 ret
 62e:	8082                	ret

0000000000000630 <dup>:
.global dup
dup:
 li a7, SYS_dup
 630:	48a9                	li	a7,10
 ecall
 632:	00000073          	ecall
 ret
 636:	8082                	ret

0000000000000638 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 638:	48ad                	li	a7,11
 ecall
 63a:	00000073          	ecall
 ret
 63e:	8082                	ret

0000000000000640 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 640:	48b1                	li	a7,12
 ecall
 642:	00000073          	ecall
 ret
 646:	8082                	ret

0000000000000648 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 648:	48b5                	li	a7,13
 ecall
 64a:	00000073          	ecall
 ret
 64e:	8082                	ret

0000000000000650 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 650:	48b9                	li	a7,14
 ecall
 652:	00000073          	ecall
 ret
 656:	8082                	ret

0000000000000658 <sigprocmask>:
.global sigprocmask
sigprocmask:
 li a7, SYS_sigprocmask
 658:	48d9                	li	a7,22
 ecall
 65a:	00000073          	ecall
 ret
 65e:	8082                	ret

0000000000000660 <sigaction>:
.global sigaction
sigaction:
 li a7, SYS_sigaction
 660:	48dd                	li	a7,23
 ecall
 662:	00000073          	ecall
 ret
 666:	8082                	ret

0000000000000668 <sigret>:
.global sigret
sigret:
 li a7, SYS_sigret
 668:	48e1                	li	a7,24
 ecall
 66a:	00000073          	ecall
 ret
 66e:	8082                	ret

0000000000000670 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 670:	1101                	addi	sp,sp,-32
 672:	ec06                	sd	ra,24(sp)
 674:	e822                	sd	s0,16(sp)
 676:	1000                	addi	s0,sp,32
 678:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 67c:	4605                	li	a2,1
 67e:	fef40593          	addi	a1,s0,-17
 682:	00000097          	auipc	ra,0x0
 686:	f56080e7          	jalr	-170(ra) # 5d8 <write>
}
 68a:	60e2                	ld	ra,24(sp)
 68c:	6442                	ld	s0,16(sp)
 68e:	6105                	addi	sp,sp,32
 690:	8082                	ret

0000000000000692 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 692:	7139                	addi	sp,sp,-64
 694:	fc06                	sd	ra,56(sp)
 696:	f822                	sd	s0,48(sp)
 698:	f426                	sd	s1,40(sp)
 69a:	f04a                	sd	s2,32(sp)
 69c:	ec4e                	sd	s3,24(sp)
 69e:	0080                	addi	s0,sp,64
 6a0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 6a2:	c299                	beqz	a3,6a8 <printint+0x16>
 6a4:	0805c863          	bltz	a1,734 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 6a8:	2581                	sext.w	a1,a1
  neg = 0;
 6aa:	4881                	li	a7,0
 6ac:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 6b0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 6b2:	2601                	sext.w	a2,a2
 6b4:	00000517          	auipc	a0,0x0
 6b8:	68c50513          	addi	a0,a0,1676 # d40 <digits>
 6bc:	883a                	mv	a6,a4
 6be:	2705                	addiw	a4,a4,1
 6c0:	02c5f7bb          	remuw	a5,a1,a2
 6c4:	1782                	slli	a5,a5,0x20
 6c6:	9381                	srli	a5,a5,0x20
 6c8:	97aa                	add	a5,a5,a0
 6ca:	0007c783          	lbu	a5,0(a5)
 6ce:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6d2:	0005879b          	sext.w	a5,a1
 6d6:	02c5d5bb          	divuw	a1,a1,a2
 6da:	0685                	addi	a3,a3,1
 6dc:	fec7f0e3          	bgeu	a5,a2,6bc <printint+0x2a>
  if(neg)
 6e0:	00088b63          	beqz	a7,6f6 <printint+0x64>
    buf[i++] = '-';
 6e4:	fd040793          	addi	a5,s0,-48
 6e8:	973e                	add	a4,a4,a5
 6ea:	02d00793          	li	a5,45
 6ee:	fef70823          	sb	a5,-16(a4)
 6f2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6f6:	02e05863          	blez	a4,726 <printint+0x94>
 6fa:	fc040793          	addi	a5,s0,-64
 6fe:	00e78933          	add	s2,a5,a4
 702:	fff78993          	addi	s3,a5,-1
 706:	99ba                	add	s3,s3,a4
 708:	377d                	addiw	a4,a4,-1
 70a:	1702                	slli	a4,a4,0x20
 70c:	9301                	srli	a4,a4,0x20
 70e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 712:	fff94583          	lbu	a1,-1(s2)
 716:	8526                	mv	a0,s1
 718:	00000097          	auipc	ra,0x0
 71c:	f58080e7          	jalr	-168(ra) # 670 <putc>
  while(--i >= 0)
 720:	197d                	addi	s2,s2,-1
 722:	ff3918e3          	bne	s2,s3,712 <printint+0x80>
}
 726:	70e2                	ld	ra,56(sp)
 728:	7442                	ld	s0,48(sp)
 72a:	74a2                	ld	s1,40(sp)
 72c:	7902                	ld	s2,32(sp)
 72e:	69e2                	ld	s3,24(sp)
 730:	6121                	addi	sp,sp,64
 732:	8082                	ret
    x = -xx;
 734:	40b005bb          	negw	a1,a1
    neg = 1;
 738:	4885                	li	a7,1
    x = -xx;
 73a:	bf8d                	j	6ac <printint+0x1a>

000000000000073c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 73c:	7119                	addi	sp,sp,-128
 73e:	fc86                	sd	ra,120(sp)
 740:	f8a2                	sd	s0,112(sp)
 742:	f4a6                	sd	s1,104(sp)
 744:	f0ca                	sd	s2,96(sp)
 746:	ecce                	sd	s3,88(sp)
 748:	e8d2                	sd	s4,80(sp)
 74a:	e4d6                	sd	s5,72(sp)
 74c:	e0da                	sd	s6,64(sp)
 74e:	fc5e                	sd	s7,56(sp)
 750:	f862                	sd	s8,48(sp)
 752:	f466                	sd	s9,40(sp)
 754:	f06a                	sd	s10,32(sp)
 756:	ec6e                	sd	s11,24(sp)
 758:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 75a:	0005c903          	lbu	s2,0(a1)
 75e:	18090f63          	beqz	s2,8fc <vprintf+0x1c0>
 762:	8aaa                	mv	s5,a0
 764:	8b32                	mv	s6,a2
 766:	00158493          	addi	s1,a1,1
  state = 0;
 76a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 76c:	02500a13          	li	s4,37
      if(c == 'd'){
 770:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 774:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 778:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 77c:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 780:	00000b97          	auipc	s7,0x0
 784:	5c0b8b93          	addi	s7,s7,1472 # d40 <digits>
 788:	a839                	j	7a6 <vprintf+0x6a>
        putc(fd, c);
 78a:	85ca                	mv	a1,s2
 78c:	8556                	mv	a0,s5
 78e:	00000097          	auipc	ra,0x0
 792:	ee2080e7          	jalr	-286(ra) # 670 <putc>
 796:	a019                	j	79c <vprintf+0x60>
    } else if(state == '%'){
 798:	01498f63          	beq	s3,s4,7b6 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 79c:	0485                	addi	s1,s1,1
 79e:	fff4c903          	lbu	s2,-1(s1)
 7a2:	14090d63          	beqz	s2,8fc <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 7a6:	0009079b          	sext.w	a5,s2
    if(state == 0){
 7aa:	fe0997e3          	bnez	s3,798 <vprintf+0x5c>
      if(c == '%'){
 7ae:	fd479ee3          	bne	a5,s4,78a <vprintf+0x4e>
        state = '%';
 7b2:	89be                	mv	s3,a5
 7b4:	b7e5                	j	79c <vprintf+0x60>
      if(c == 'd'){
 7b6:	05878063          	beq	a5,s8,7f6 <vprintf+0xba>
      } else if(c == 'l') {
 7ba:	05978c63          	beq	a5,s9,812 <vprintf+0xd6>
      } else if(c == 'x') {
 7be:	07a78863          	beq	a5,s10,82e <vprintf+0xf2>
      } else if(c == 'p') {
 7c2:	09b78463          	beq	a5,s11,84a <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 7c6:	07300713          	li	a4,115
 7ca:	0ce78663          	beq	a5,a4,896 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7ce:	06300713          	li	a4,99
 7d2:	0ee78e63          	beq	a5,a4,8ce <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7d6:	11478863          	beq	a5,s4,8e6 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7da:	85d2                	mv	a1,s4
 7dc:	8556                	mv	a0,s5
 7de:	00000097          	auipc	ra,0x0
 7e2:	e92080e7          	jalr	-366(ra) # 670 <putc>
        putc(fd, c);
 7e6:	85ca                	mv	a1,s2
 7e8:	8556                	mv	a0,s5
 7ea:	00000097          	auipc	ra,0x0
 7ee:	e86080e7          	jalr	-378(ra) # 670 <putc>
      }
      state = 0;
 7f2:	4981                	li	s3,0
 7f4:	b765                	j	79c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7f6:	008b0913          	addi	s2,s6,8
 7fa:	4685                	li	a3,1
 7fc:	4629                	li	a2,10
 7fe:	000b2583          	lw	a1,0(s6)
 802:	8556                	mv	a0,s5
 804:	00000097          	auipc	ra,0x0
 808:	e8e080e7          	jalr	-370(ra) # 692 <printint>
 80c:	8b4a                	mv	s6,s2
      state = 0;
 80e:	4981                	li	s3,0
 810:	b771                	j	79c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 812:	008b0913          	addi	s2,s6,8
 816:	4681                	li	a3,0
 818:	4629                	li	a2,10
 81a:	000b2583          	lw	a1,0(s6)
 81e:	8556                	mv	a0,s5
 820:	00000097          	auipc	ra,0x0
 824:	e72080e7          	jalr	-398(ra) # 692 <printint>
 828:	8b4a                	mv	s6,s2
      state = 0;
 82a:	4981                	li	s3,0
 82c:	bf85                	j	79c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 82e:	008b0913          	addi	s2,s6,8
 832:	4681                	li	a3,0
 834:	4641                	li	a2,16
 836:	000b2583          	lw	a1,0(s6)
 83a:	8556                	mv	a0,s5
 83c:	00000097          	auipc	ra,0x0
 840:	e56080e7          	jalr	-426(ra) # 692 <printint>
 844:	8b4a                	mv	s6,s2
      state = 0;
 846:	4981                	li	s3,0
 848:	bf91                	j	79c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 84a:	008b0793          	addi	a5,s6,8
 84e:	f8f43423          	sd	a5,-120(s0)
 852:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 856:	03000593          	li	a1,48
 85a:	8556                	mv	a0,s5
 85c:	00000097          	auipc	ra,0x0
 860:	e14080e7          	jalr	-492(ra) # 670 <putc>
  putc(fd, 'x');
 864:	85ea                	mv	a1,s10
 866:	8556                	mv	a0,s5
 868:	00000097          	auipc	ra,0x0
 86c:	e08080e7          	jalr	-504(ra) # 670 <putc>
 870:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 872:	03c9d793          	srli	a5,s3,0x3c
 876:	97de                	add	a5,a5,s7
 878:	0007c583          	lbu	a1,0(a5)
 87c:	8556                	mv	a0,s5
 87e:	00000097          	auipc	ra,0x0
 882:	df2080e7          	jalr	-526(ra) # 670 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 886:	0992                	slli	s3,s3,0x4
 888:	397d                	addiw	s2,s2,-1
 88a:	fe0914e3          	bnez	s2,872 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 88e:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 892:	4981                	li	s3,0
 894:	b721                	j	79c <vprintf+0x60>
        s = va_arg(ap, char*);
 896:	008b0993          	addi	s3,s6,8
 89a:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 89e:	02090163          	beqz	s2,8c0 <vprintf+0x184>
        while(*s != 0){
 8a2:	00094583          	lbu	a1,0(s2)
 8a6:	c9a1                	beqz	a1,8f6 <vprintf+0x1ba>
          putc(fd, *s);
 8a8:	8556                	mv	a0,s5
 8aa:	00000097          	auipc	ra,0x0
 8ae:	dc6080e7          	jalr	-570(ra) # 670 <putc>
          s++;
 8b2:	0905                	addi	s2,s2,1
        while(*s != 0){
 8b4:	00094583          	lbu	a1,0(s2)
 8b8:	f9e5                	bnez	a1,8a8 <vprintf+0x16c>
        s = va_arg(ap, char*);
 8ba:	8b4e                	mv	s6,s3
      state = 0;
 8bc:	4981                	li	s3,0
 8be:	bdf9                	j	79c <vprintf+0x60>
          s = "(null)";
 8c0:	00000917          	auipc	s2,0x0
 8c4:	47890913          	addi	s2,s2,1144 # d38 <malloc+0x332>
        while(*s != 0){
 8c8:	02800593          	li	a1,40
 8cc:	bff1                	j	8a8 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 8ce:	008b0913          	addi	s2,s6,8
 8d2:	000b4583          	lbu	a1,0(s6)
 8d6:	8556                	mv	a0,s5
 8d8:	00000097          	auipc	ra,0x0
 8dc:	d98080e7          	jalr	-616(ra) # 670 <putc>
 8e0:	8b4a                	mv	s6,s2
      state = 0;
 8e2:	4981                	li	s3,0
 8e4:	bd65                	j	79c <vprintf+0x60>
        putc(fd, c);
 8e6:	85d2                	mv	a1,s4
 8e8:	8556                	mv	a0,s5
 8ea:	00000097          	auipc	ra,0x0
 8ee:	d86080e7          	jalr	-634(ra) # 670 <putc>
      state = 0;
 8f2:	4981                	li	s3,0
 8f4:	b565                	j	79c <vprintf+0x60>
        s = va_arg(ap, char*);
 8f6:	8b4e                	mv	s6,s3
      state = 0;
 8f8:	4981                	li	s3,0
 8fa:	b54d                	j	79c <vprintf+0x60>
    }
  }
}
 8fc:	70e6                	ld	ra,120(sp)
 8fe:	7446                	ld	s0,112(sp)
 900:	74a6                	ld	s1,104(sp)
 902:	7906                	ld	s2,96(sp)
 904:	69e6                	ld	s3,88(sp)
 906:	6a46                	ld	s4,80(sp)
 908:	6aa6                	ld	s5,72(sp)
 90a:	6b06                	ld	s6,64(sp)
 90c:	7be2                	ld	s7,56(sp)
 90e:	7c42                	ld	s8,48(sp)
 910:	7ca2                	ld	s9,40(sp)
 912:	7d02                	ld	s10,32(sp)
 914:	6de2                	ld	s11,24(sp)
 916:	6109                	addi	sp,sp,128
 918:	8082                	ret

000000000000091a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 91a:	715d                	addi	sp,sp,-80
 91c:	ec06                	sd	ra,24(sp)
 91e:	e822                	sd	s0,16(sp)
 920:	1000                	addi	s0,sp,32
 922:	e010                	sd	a2,0(s0)
 924:	e414                	sd	a3,8(s0)
 926:	e818                	sd	a4,16(s0)
 928:	ec1c                	sd	a5,24(s0)
 92a:	03043023          	sd	a6,32(s0)
 92e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 932:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 936:	8622                	mv	a2,s0
 938:	00000097          	auipc	ra,0x0
 93c:	e04080e7          	jalr	-508(ra) # 73c <vprintf>
}
 940:	60e2                	ld	ra,24(sp)
 942:	6442                	ld	s0,16(sp)
 944:	6161                	addi	sp,sp,80
 946:	8082                	ret

0000000000000948 <printf>:

void
printf(const char *fmt, ...)
{
 948:	711d                	addi	sp,sp,-96
 94a:	ec06                	sd	ra,24(sp)
 94c:	e822                	sd	s0,16(sp)
 94e:	1000                	addi	s0,sp,32
 950:	e40c                	sd	a1,8(s0)
 952:	e810                	sd	a2,16(s0)
 954:	ec14                	sd	a3,24(s0)
 956:	f018                	sd	a4,32(s0)
 958:	f41c                	sd	a5,40(s0)
 95a:	03043823          	sd	a6,48(s0)
 95e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 962:	00840613          	addi	a2,s0,8
 966:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 96a:	85aa                	mv	a1,a0
 96c:	4505                	li	a0,1
 96e:	00000097          	auipc	ra,0x0
 972:	dce080e7          	jalr	-562(ra) # 73c <vprintf>
}
 976:	60e2                	ld	ra,24(sp)
 978:	6442                	ld	s0,16(sp)
 97a:	6125                	addi	sp,sp,96
 97c:	8082                	ret

000000000000097e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 97e:	1141                	addi	sp,sp,-16
 980:	e422                	sd	s0,8(sp)
 982:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 984:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 988:	00000797          	auipc	a5,0x0
 98c:	3d07b783          	ld	a5,976(a5) # d58 <freep>
 990:	a805                	j	9c0 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 992:	4618                	lw	a4,8(a2)
 994:	9db9                	addw	a1,a1,a4
 996:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 99a:	6398                	ld	a4,0(a5)
 99c:	6318                	ld	a4,0(a4)
 99e:	fee53823          	sd	a4,-16(a0)
 9a2:	a091                	j	9e6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9a4:	ff852703          	lw	a4,-8(a0)
 9a8:	9e39                	addw	a2,a2,a4
 9aa:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 9ac:	ff053703          	ld	a4,-16(a0)
 9b0:	e398                	sd	a4,0(a5)
 9b2:	a099                	j	9f8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9b4:	6398                	ld	a4,0(a5)
 9b6:	00e7e463          	bltu	a5,a4,9be <free+0x40>
 9ba:	00e6ea63          	bltu	a3,a4,9ce <free+0x50>
{
 9be:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9c0:	fed7fae3          	bgeu	a5,a3,9b4 <free+0x36>
 9c4:	6398                	ld	a4,0(a5)
 9c6:	00e6e463          	bltu	a3,a4,9ce <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9ca:	fee7eae3          	bltu	a5,a4,9be <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9ce:	ff852583          	lw	a1,-8(a0)
 9d2:	6390                	ld	a2,0(a5)
 9d4:	02059813          	slli	a6,a1,0x20
 9d8:	01c85713          	srli	a4,a6,0x1c
 9dc:	9736                	add	a4,a4,a3
 9de:	fae60ae3          	beq	a2,a4,992 <free+0x14>
    bp->s.ptr = p->s.ptr;
 9e2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9e6:	4790                	lw	a2,8(a5)
 9e8:	02061593          	slli	a1,a2,0x20
 9ec:	01c5d713          	srli	a4,a1,0x1c
 9f0:	973e                	add	a4,a4,a5
 9f2:	fae689e3          	beq	a3,a4,9a4 <free+0x26>
  } else
    p->s.ptr = bp;
 9f6:	e394                	sd	a3,0(a5)
  freep = p;
 9f8:	00000717          	auipc	a4,0x0
 9fc:	36f73023          	sd	a5,864(a4) # d58 <freep>
}
 a00:	6422                	ld	s0,8(sp)
 a02:	0141                	addi	sp,sp,16
 a04:	8082                	ret

0000000000000a06 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a06:	7139                	addi	sp,sp,-64
 a08:	fc06                	sd	ra,56(sp)
 a0a:	f822                	sd	s0,48(sp)
 a0c:	f426                	sd	s1,40(sp)
 a0e:	f04a                	sd	s2,32(sp)
 a10:	ec4e                	sd	s3,24(sp)
 a12:	e852                	sd	s4,16(sp)
 a14:	e456                	sd	s5,8(sp)
 a16:	e05a                	sd	s6,0(sp)
 a18:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a1a:	02051493          	slli	s1,a0,0x20
 a1e:	9081                	srli	s1,s1,0x20
 a20:	04bd                	addi	s1,s1,15
 a22:	8091                	srli	s1,s1,0x4
 a24:	0014899b          	addiw	s3,s1,1
 a28:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a2a:	00000517          	auipc	a0,0x0
 a2e:	32e53503          	ld	a0,814(a0) # d58 <freep>
 a32:	c515                	beqz	a0,a5e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a34:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a36:	4798                	lw	a4,8(a5)
 a38:	02977f63          	bgeu	a4,s1,a76 <malloc+0x70>
 a3c:	8a4e                	mv	s4,s3
 a3e:	0009871b          	sext.w	a4,s3
 a42:	6685                	lui	a3,0x1
 a44:	00d77363          	bgeu	a4,a3,a4a <malloc+0x44>
 a48:	6a05                	lui	s4,0x1
 a4a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a4e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a52:	00000917          	auipc	s2,0x0
 a56:	30690913          	addi	s2,s2,774 # d58 <freep>
  if(p == (char*)-1)
 a5a:	5afd                	li	s5,-1
 a5c:	a895                	j	ad0 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 a5e:	00000797          	auipc	a5,0x0
 a62:	30278793          	addi	a5,a5,770 # d60 <base>
 a66:	00000717          	auipc	a4,0x0
 a6a:	2ef73923          	sd	a5,754(a4) # d58 <freep>
 a6e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a70:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a74:	b7e1                	j	a3c <malloc+0x36>
      if(p->s.size == nunits)
 a76:	02e48c63          	beq	s1,a4,aae <malloc+0xa8>
        p->s.size -= nunits;
 a7a:	4137073b          	subw	a4,a4,s3
 a7e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a80:	02071693          	slli	a3,a4,0x20
 a84:	01c6d713          	srli	a4,a3,0x1c
 a88:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a8a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a8e:	00000717          	auipc	a4,0x0
 a92:	2ca73523          	sd	a0,714(a4) # d58 <freep>
      return (void*)(p + 1);
 a96:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a9a:	70e2                	ld	ra,56(sp)
 a9c:	7442                	ld	s0,48(sp)
 a9e:	74a2                	ld	s1,40(sp)
 aa0:	7902                	ld	s2,32(sp)
 aa2:	69e2                	ld	s3,24(sp)
 aa4:	6a42                	ld	s4,16(sp)
 aa6:	6aa2                	ld	s5,8(sp)
 aa8:	6b02                	ld	s6,0(sp)
 aaa:	6121                	addi	sp,sp,64
 aac:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 aae:	6398                	ld	a4,0(a5)
 ab0:	e118                	sd	a4,0(a0)
 ab2:	bff1                	j	a8e <malloc+0x88>
  hp->s.size = nu;
 ab4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 ab8:	0541                	addi	a0,a0,16
 aba:	00000097          	auipc	ra,0x0
 abe:	ec4080e7          	jalr	-316(ra) # 97e <free>
  return freep;
 ac2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ac6:	d971                	beqz	a0,a9a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ac8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 aca:	4798                	lw	a4,8(a5)
 acc:	fa9775e3          	bgeu	a4,s1,a76 <malloc+0x70>
    if(p == freep)
 ad0:	00093703          	ld	a4,0(s2)
 ad4:	853e                	mv	a0,a5
 ad6:	fef719e3          	bne	a4,a5,ac8 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 ada:	8552                	mv	a0,s4
 adc:	00000097          	auipc	ra,0x0
 ae0:	b64080e7          	jalr	-1180(ra) # 640 <sbrk>
  if(p == (char*)-1)
 ae4:	fd5518e3          	bne	a0,s5,ab4 <malloc+0xae>
        return 0;
 ae8:	4501                	li	a0,0
 aea:	bf45                	j	a9a <malloc+0x94>
