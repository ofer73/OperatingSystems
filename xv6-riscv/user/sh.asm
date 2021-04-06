
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
    exit(0);
}

int
getcmd(char *buf, int nbuf)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
  fprintf(2, "$ ");
      10:	00001597          	auipc	a1,0x1
      14:	3c058593          	addi	a1,a1,960 # 13d0 <malloc+0xe8>
      18:	4509                	li	a0,2
      1a:	00001097          	auipc	ra,0x1
      1e:	1e2080e7          	jalr	482(ra) # 11fc <fprintf>
  memset(buf, 0, nbuf);
      22:	864a                	mv	a2,s2
      24:	4581                	li	a1,0
      26:	8526                	mv	a0,s1
      28:	00001097          	auipc	ra,0x1
      2c:	c76080e7          	jalr	-906(ra) # c9e <memset>
  gets(buf, nbuf);
      30:	85ca                	mv	a1,s2
      32:	8526                	mv	a0,s1
      34:	00001097          	auipc	ra,0x1
      38:	cb0080e7          	jalr	-848(ra) # ce4 <gets>
  if(buf[0] == 0) // EOF
      3c:	0004c503          	lbu	a0,0(s1)
      40:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
      44:	40a00533          	neg	a0,a0
      48:	60e2                	ld	ra,24(sp)
      4a:	6442                	ld	s0,16(sp)
      4c:	64a2                	ld	s1,8(sp)
      4e:	6902                	ld	s2,0(sp)
      50:	6105                	addi	sp,sp,32
      52:	8082                	ret

0000000000000054 <panic>:
  exit(0);
}

void
panic(char *s)
{
      54:	1141                	addi	sp,sp,-16
      56:	e406                	sd	ra,8(sp)
      58:	e022                	sd	s0,0(sp)
      5a:	0800                	addi	s0,sp,16
      5c:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
      5e:	00001597          	auipc	a1,0x1
      62:	37a58593          	addi	a1,a1,890 # 13d8 <malloc+0xf0>
      66:	4509                	li	a0,2
      68:	00001097          	auipc	ra,0x1
      6c:	194080e7          	jalr	404(ra) # 11fc <fprintf>
  exit(1);
      70:	4505                	li	a0,1
      72:	00001097          	auipc	ra,0x1
      76:	e28080e7          	jalr	-472(ra) # e9a <exit>

000000000000007a <fork1>:
}

int
fork1(void)
{
      7a:	1141                	addi	sp,sp,-16
      7c:	e406                	sd	ra,8(sp)
      7e:	e022                	sd	s0,0(sp)
      80:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      82:	00001097          	auipc	ra,0x1
      86:	e10080e7          	jalr	-496(ra) # e92 <fork>
  if(pid == -1)
      8a:	57fd                	li	a5,-1
      8c:	00f50663          	beq	a0,a5,98 <fork1+0x1e>
    panic("fork");
  return pid;
}
      90:	60a2                	ld	ra,8(sp)
      92:	6402                	ld	s0,0(sp)
      94:	0141                	addi	sp,sp,16
      96:	8082                	ret
    panic("fork");
      98:	00001517          	auipc	a0,0x1
      9c:	34850513          	addi	a0,a0,840 # 13e0 <malloc+0xf8>
      a0:	00000097          	auipc	ra,0x0
      a4:	fb4080e7          	jalr	-76(ra) # 54 <panic>

00000000000000a8 <runcmd>:
{
      a8:	7149                	addi	sp,sp,-368
      aa:	f686                	sd	ra,360(sp)
      ac:	f2a2                	sd	s0,352(sp)
      ae:	eea6                	sd	s1,344(sp)
      b0:	eaca                	sd	s2,336(sp)
      b2:	e6ce                	sd	s3,328(sp)
      b4:	e2d2                	sd	s4,320(sp)
      b6:	fe56                	sd	s5,312(sp)
      b8:	fa5a                	sd	s6,304(sp)
      ba:	f65e                	sd	s7,296(sp)
      bc:	f262                	sd	s8,288(sp)
      be:	ee66                	sd	s9,280(sp)
      c0:	1a80                	addi	s0,sp,368
  if(cmd == 0)
      c2:	c10d                	beqz	a0,e4 <runcmd+0x3c>
      c4:	84aa                	mv	s1,a0
  switch(cmd->type){
      c6:	4118                	lw	a4,0(a0)
      c8:	4795                	li	a5,5
      ca:	02e7e263          	bltu	a5,a4,ee <runcmd+0x46>
      ce:	00056783          	lwu	a5,0(a0)
      d2:	078a                	slli	a5,a5,0x2
      d4:	00001717          	auipc	a4,0x1
      d8:	41470713          	addi	a4,a4,1044 # 14e8 <malloc+0x200>
      dc:	97ba                	add	a5,a5,a4
      de:	439c                	lw	a5,0(a5)
      e0:	97ba                	add	a5,a5,a4
      e2:	8782                	jr	a5
    exit(1);
      e4:	4505                	li	a0,1
      e6:	00001097          	auipc	ra,0x1
      ea:	db4080e7          	jalr	-588(ra) # e9a <exit>
      panic("runcmd");
      ee:	00001517          	auipc	a0,0x1
      f2:	2fa50513          	addi	a0,a0,762 # 13e8 <malloc+0x100>
      f6:	00000097          	auipc	ra,0x0
      fa:	f5e080e7          	jalr	-162(ra) # 54 <panic>
      if(ecmd->argv[0] == 0)
      fe:	6508                	ld	a0,8(a0)
     100:	c915                	beqz	a0,134 <runcmd+0x8c>
      int out=exec(ecmd->argv[0], ecmd->argv);
     102:	00848b93          	addi	s7,s1,8
     106:	85de                	mv	a1,s7
     108:	00001097          	auipc	ra,0x1
     10c:	dca080e7          	jalr	-566(ra) # ed2 <exec>
      if(out==-2){
     110:	57f9                	li	a5,-2
     112:	02f50663          	beq	a0,a5,13e <runcmd+0x96>
      fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     116:	6490                	ld	a2,8(s1)
     118:	00001597          	auipc	a1,0x1
     11c:	2e058593          	addi	a1,a1,736 # 13f8 <malloc+0x110>
     120:	4509                	li	a0,2
     122:	00001097          	auipc	ra,0x1
     126:	0da080e7          	jalr	218(ra) # 11fc <fprintf>
    exit(0);
     12a:	4501                	li	a0,0
     12c:	00001097          	auipc	ra,0x1
     130:	d6e080e7          	jalr	-658(ra) # e9a <exit>
        exit(1);
     134:	4505                	li	a0,1
     136:	00001097          	auipc	ra,0x1
     13a:	d64080e7          	jalr	-668(ra) # e9a <exit>
        int fd=open(name,O_RDONLY);
     13e:	4581                	li	a1,0
     140:	00001517          	auipc	a0,0x1
     144:	2b050513          	addi	a0,a0,688 # 13f0 <malloc+0x108>
     148:	00001097          	auipc	ra,0x1
     14c:	d92080e7          	jalr	-622(ra) # eda <open>
     150:	8aaa                	mv	s5,a0
        while(read(fd,&c,1)>0){
     152:	00001a17          	auipc	s4,0x1
     156:	3fea0a13          	addi	s4,s4,1022 # 1550 <PATH>
        int index=0, index_p=0;
     15a:	4981                	li	s3,0
          if(c==':'){
     15c:	03a00b13          	li	s6,58
            if(out!=-2){//secess
     160:	5c79                	li	s8,-2
            index=0;
     162:	4c81                	li	s9,0
        while(read(fd,&c,1)>0){
     164:	a0b1                	j	1b0 <runcmd+0x108>
            PATH[index_p]=':';
     166:	016a0023          	sb	s6,0(s4)
            for(int i=0;i<strlen(ecmd->argv[0]);i++){//copy argv[0]
     16a:	4901                	li	s2,0
     16c:	a829                	j	186 <runcmd+0xde>
                str[index]=ecmd->argv[0][i];
     16e:	649c                	ld	a5,8(s1)
     170:	97ca                	add	a5,a5,s2
     172:	0007c703          	lbu	a4,0(a5)
     176:	012987b3          	add	a5,s3,s2
     17a:	e9840693          	addi	a3,s0,-360
     17e:	97b6                	add	a5,a5,a3
     180:	00e78023          	sb	a4,0(a5)
            for(int i=0;i<strlen(ecmd->argv[0]);i++){//copy argv[0]
     184:	0905                	addi	s2,s2,1
     186:	6488                	ld	a0,8(s1)
     188:	00001097          	auipc	ra,0x1
     18c:	aec080e7          	jalr	-1300(ra) # c74 <strlen>
     190:	2501                	sext.w	a0,a0
     192:	0009079b          	sext.w	a5,s2
     196:	fca7ece3          	bltu	a5,a0,16e <runcmd+0xc6>
            out=exec(str, ecmd->argv);
     19a:	85de                	mv	a1,s7
     19c:	e9840513          	addi	a0,s0,-360
     1a0:	00001097          	auipc	ra,0x1
     1a4:	d32080e7          	jalr	-718(ra) # ed2 <exec>
            if(out!=-2){//secess
     1a8:	03851b63          	bne	a0,s8,1de <runcmd+0x136>
            index=0;
     1ac:	89e6                	mv	s3,s9
     1ae:	0a05                	addi	s4,s4,1
        while(read(fd,&c,1)>0){
     1b0:	4605                	li	a2,1
     1b2:	e9740593          	addi	a1,s0,-361
     1b6:	8556                	mv	a0,s5
     1b8:	00001097          	auipc	ra,0x1
     1bc:	cfa080e7          	jalr	-774(ra) # eb2 <read>
     1c0:	f4a05be3          	blez	a0,116 <runcmd+0x6e>
          if(c==':'){
     1c4:	e9744783          	lbu	a5,-361(s0)
     1c8:	f9678fe3          	beq	a5,s6,166 <runcmd+0xbe>
            str[index]=c;
     1cc:	fa040713          	addi	a4,s0,-96
     1d0:	974e                	add	a4,a4,s3
     1d2:	eef70c23          	sb	a5,-264(a4)
            index++;
     1d6:	2985                	addiw	s3,s3,1
            PATH[index_p]=c;
     1d8:	00fa0023          	sb	a5,0(s4)
            index_p++;
     1dc:	bfc9                	j	1ae <runcmd+0x106>
              fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     1de:	6490                	ld	a2,8(s1)
     1e0:	00001597          	auipc	a1,0x1
     1e4:	21858593          	addi	a1,a1,536 # 13f8 <malloc+0x110>
     1e8:	4509                	li	a0,2
     1ea:	00001097          	auipc	ra,0x1
     1ee:	012080e7          	jalr	18(ra) # 11fc <fprintf>
              break;
     1f2:	b715                	j	116 <runcmd+0x6e>
      close(rcmd->fd);
     1f4:	5148                	lw	a0,36(a0)
     1f6:	00001097          	auipc	ra,0x1
     1fa:	ccc080e7          	jalr	-820(ra) # ec2 <close>
      if(open(rcmd->file, rcmd->mode) < 0){
     1fe:	508c                	lw	a1,32(s1)
     200:	6888                	ld	a0,16(s1)
     202:	00001097          	auipc	ra,0x1
     206:	cd8080e7          	jalr	-808(ra) # eda <open>
     20a:	00054763          	bltz	a0,218 <runcmd+0x170>
      runcmd(rcmd->cmd);
     20e:	6488                	ld	a0,8(s1)
     210:	00000097          	auipc	ra,0x0
     214:	e98080e7          	jalr	-360(ra) # a8 <runcmd>
        fprintf(2, "open %s failed\n", rcmd->file);
     218:	6890                	ld	a2,16(s1)
     21a:	00001597          	auipc	a1,0x1
     21e:	1ee58593          	addi	a1,a1,494 # 1408 <malloc+0x120>
     222:	4509                	li	a0,2
     224:	00001097          	auipc	ra,0x1
     228:	fd8080e7          	jalr	-40(ra) # 11fc <fprintf>
        exit(1);
     22c:	4505                	li	a0,1
     22e:	00001097          	auipc	ra,0x1
     232:	c6c080e7          	jalr	-916(ra) # e9a <exit>
      if(fork1() == 0)
     236:	00000097          	auipc	ra,0x0
     23a:	e44080e7          	jalr	-444(ra) # 7a <fork1>
     23e:	c919                	beqz	a0,254 <runcmd+0x1ac>
      wait(0);
     240:	4501                	li	a0,0
     242:	00001097          	auipc	ra,0x1
     246:	c60080e7          	jalr	-928(ra) # ea2 <wait>
      runcmd(lcmd->right);
     24a:	6888                	ld	a0,16(s1)
     24c:	00000097          	auipc	ra,0x0
     250:	e5c080e7          	jalr	-420(ra) # a8 <runcmd>
        runcmd(lcmd->left);
     254:	6488                	ld	a0,8(s1)
     256:	00000097          	auipc	ra,0x0
     25a:	e52080e7          	jalr	-430(ra) # a8 <runcmd>
      if(pipe(p) < 0)
     25e:	f9840513          	addi	a0,s0,-104
     262:	00001097          	auipc	ra,0x1
     266:	c48080e7          	jalr	-952(ra) # eaa <pipe>
     26a:	04054363          	bltz	a0,2b0 <runcmd+0x208>
      if(fork1() == 0){
     26e:	00000097          	auipc	ra,0x0
     272:	e0c080e7          	jalr	-500(ra) # 7a <fork1>
     276:	c529                	beqz	a0,2c0 <runcmd+0x218>
      if(fork1() == 0){
     278:	00000097          	auipc	ra,0x0
     27c:	e02080e7          	jalr	-510(ra) # 7a <fork1>
     280:	cd25                	beqz	a0,2f8 <runcmd+0x250>
      close(p[0]);
     282:	f9842503          	lw	a0,-104(s0)
     286:	00001097          	auipc	ra,0x1
     28a:	c3c080e7          	jalr	-964(ra) # ec2 <close>
      close(p[1]);
     28e:	f9c42503          	lw	a0,-100(s0)
     292:	00001097          	auipc	ra,0x1
     296:	c30080e7          	jalr	-976(ra) # ec2 <close>
      wait(0);
     29a:	4501                	li	a0,0
     29c:	00001097          	auipc	ra,0x1
     2a0:	c06080e7          	jalr	-1018(ra) # ea2 <wait>
      wait(0);
     2a4:	4501                	li	a0,0
     2a6:	00001097          	auipc	ra,0x1
     2aa:	bfc080e7          	jalr	-1028(ra) # ea2 <wait>
      break;
     2ae:	bdb5                	j	12a <runcmd+0x82>
        panic("pipe");
     2b0:	00001517          	auipc	a0,0x1
     2b4:	16850513          	addi	a0,a0,360 # 1418 <malloc+0x130>
     2b8:	00000097          	auipc	ra,0x0
     2bc:	d9c080e7          	jalr	-612(ra) # 54 <panic>
        close(1);
     2c0:	4505                	li	a0,1
     2c2:	00001097          	auipc	ra,0x1
     2c6:	c00080e7          	jalr	-1024(ra) # ec2 <close>
        dup(p[1]);
     2ca:	f9c42503          	lw	a0,-100(s0)
     2ce:	00001097          	auipc	ra,0x1
     2d2:	c44080e7          	jalr	-956(ra) # f12 <dup>
        close(p[0]);
     2d6:	f9842503          	lw	a0,-104(s0)
     2da:	00001097          	auipc	ra,0x1
     2de:	be8080e7          	jalr	-1048(ra) # ec2 <close>
        close(p[1]);
     2e2:	f9c42503          	lw	a0,-100(s0)
     2e6:	00001097          	auipc	ra,0x1
     2ea:	bdc080e7          	jalr	-1060(ra) # ec2 <close>
        runcmd(pcmd->left);
     2ee:	6488                	ld	a0,8(s1)
     2f0:	00000097          	auipc	ra,0x0
     2f4:	db8080e7          	jalr	-584(ra) # a8 <runcmd>
        close(0);
     2f8:	00001097          	auipc	ra,0x1
     2fc:	bca080e7          	jalr	-1078(ra) # ec2 <close>
        dup(p[0]);
     300:	f9842503          	lw	a0,-104(s0)
     304:	00001097          	auipc	ra,0x1
     308:	c0e080e7          	jalr	-1010(ra) # f12 <dup>
        close(p[0]);
     30c:	f9842503          	lw	a0,-104(s0)
     310:	00001097          	auipc	ra,0x1
     314:	bb2080e7          	jalr	-1102(ra) # ec2 <close>
        close(p[1]);
     318:	f9c42503          	lw	a0,-100(s0)
     31c:	00001097          	auipc	ra,0x1
     320:	ba6080e7          	jalr	-1114(ra) # ec2 <close>
        runcmd(pcmd->right);
     324:	6888                	ld	a0,16(s1)
     326:	00000097          	auipc	ra,0x0
     32a:	d82080e7          	jalr	-638(ra) # a8 <runcmd>
      if(fork1() == 0)
     32e:	00000097          	auipc	ra,0x0
     332:	d4c080e7          	jalr	-692(ra) # 7a <fork1>
     336:	de051ae3          	bnez	a0,12a <runcmd+0x82>
        runcmd(bcmd->cmd);
     33a:	6488                	ld	a0,8(s1)
     33c:	00000097          	auipc	ra,0x0
     340:	d6c080e7          	jalr	-660(ra) # a8 <runcmd>

0000000000000344 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     344:	1101                	addi	sp,sp,-32
     346:	ec06                	sd	ra,24(sp)
     348:	e822                	sd	s0,16(sp)
     34a:	e426                	sd	s1,8(sp)
     34c:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     34e:	0a800513          	li	a0,168
     352:	00001097          	auipc	ra,0x1
     356:	f96080e7          	jalr	-106(ra) # 12e8 <malloc>
     35a:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     35c:	0a800613          	li	a2,168
     360:	4581                	li	a1,0
     362:	00001097          	auipc	ra,0x1
     366:	93c080e7          	jalr	-1732(ra) # c9e <memset>
  cmd->type = EXEC;
     36a:	4785                	li	a5,1
     36c:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     36e:	8526                	mv	a0,s1
     370:	60e2                	ld	ra,24(sp)
     372:	6442                	ld	s0,16(sp)
     374:	64a2                	ld	s1,8(sp)
     376:	6105                	addi	sp,sp,32
     378:	8082                	ret

000000000000037a <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     37a:	7139                	addi	sp,sp,-64
     37c:	fc06                	sd	ra,56(sp)
     37e:	f822                	sd	s0,48(sp)
     380:	f426                	sd	s1,40(sp)
     382:	f04a                	sd	s2,32(sp)
     384:	ec4e                	sd	s3,24(sp)
     386:	e852                	sd	s4,16(sp)
     388:	e456                	sd	s5,8(sp)
     38a:	e05a                	sd	s6,0(sp)
     38c:	0080                	addi	s0,sp,64
     38e:	8b2a                	mv	s6,a0
     390:	8aae                	mv	s5,a1
     392:	8a32                	mv	s4,a2
     394:	89b6                	mv	s3,a3
     396:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     398:	02800513          	li	a0,40
     39c:	00001097          	auipc	ra,0x1
     3a0:	f4c080e7          	jalr	-180(ra) # 12e8 <malloc>
     3a4:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3a6:	02800613          	li	a2,40
     3aa:	4581                	li	a1,0
     3ac:	00001097          	auipc	ra,0x1
     3b0:	8f2080e7          	jalr	-1806(ra) # c9e <memset>
  cmd->type = REDIR;
     3b4:	4789                	li	a5,2
     3b6:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     3b8:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     3bc:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     3c0:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     3c4:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     3c8:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     3cc:	8526                	mv	a0,s1
     3ce:	70e2                	ld	ra,56(sp)
     3d0:	7442                	ld	s0,48(sp)
     3d2:	74a2                	ld	s1,40(sp)
     3d4:	7902                	ld	s2,32(sp)
     3d6:	69e2                	ld	s3,24(sp)
     3d8:	6a42                	ld	s4,16(sp)
     3da:	6aa2                	ld	s5,8(sp)
     3dc:	6b02                	ld	s6,0(sp)
     3de:	6121                	addi	sp,sp,64
     3e0:	8082                	ret

00000000000003e2 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     3e2:	7179                	addi	sp,sp,-48
     3e4:	f406                	sd	ra,40(sp)
     3e6:	f022                	sd	s0,32(sp)
     3e8:	ec26                	sd	s1,24(sp)
     3ea:	e84a                	sd	s2,16(sp)
     3ec:	e44e                	sd	s3,8(sp)
     3ee:	1800                	addi	s0,sp,48
     3f0:	89aa                	mv	s3,a0
     3f2:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3f4:	4561                	li	a0,24
     3f6:	00001097          	auipc	ra,0x1
     3fa:	ef2080e7          	jalr	-270(ra) # 12e8 <malloc>
     3fe:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     400:	4661                	li	a2,24
     402:	4581                	li	a1,0
     404:	00001097          	auipc	ra,0x1
     408:	89a080e7          	jalr	-1894(ra) # c9e <memset>
  cmd->type = PIPE;
     40c:	478d                	li	a5,3
     40e:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     410:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     414:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     418:	8526                	mv	a0,s1
     41a:	70a2                	ld	ra,40(sp)
     41c:	7402                	ld	s0,32(sp)
     41e:	64e2                	ld	s1,24(sp)
     420:	6942                	ld	s2,16(sp)
     422:	69a2                	ld	s3,8(sp)
     424:	6145                	addi	sp,sp,48
     426:	8082                	ret

0000000000000428 <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     428:	7179                	addi	sp,sp,-48
     42a:	f406                	sd	ra,40(sp)
     42c:	f022                	sd	s0,32(sp)
     42e:	ec26                	sd	s1,24(sp)
     430:	e84a                	sd	s2,16(sp)
     432:	e44e                	sd	s3,8(sp)
     434:	1800                	addi	s0,sp,48
     436:	89aa                	mv	s3,a0
     438:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     43a:	4561                	li	a0,24
     43c:	00001097          	auipc	ra,0x1
     440:	eac080e7          	jalr	-340(ra) # 12e8 <malloc>
     444:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     446:	4661                	li	a2,24
     448:	4581                	li	a1,0
     44a:	00001097          	auipc	ra,0x1
     44e:	854080e7          	jalr	-1964(ra) # c9e <memset>
  cmd->type = LIST;
     452:	4791                	li	a5,4
     454:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     456:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     45a:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     45e:	8526                	mv	a0,s1
     460:	70a2                	ld	ra,40(sp)
     462:	7402                	ld	s0,32(sp)
     464:	64e2                	ld	s1,24(sp)
     466:	6942                	ld	s2,16(sp)
     468:	69a2                	ld	s3,8(sp)
     46a:	6145                	addi	sp,sp,48
     46c:	8082                	ret

000000000000046e <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     46e:	1101                	addi	sp,sp,-32
     470:	ec06                	sd	ra,24(sp)
     472:	e822                	sd	s0,16(sp)
     474:	e426                	sd	s1,8(sp)
     476:	e04a                	sd	s2,0(sp)
     478:	1000                	addi	s0,sp,32
     47a:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     47c:	4541                	li	a0,16
     47e:	00001097          	auipc	ra,0x1
     482:	e6a080e7          	jalr	-406(ra) # 12e8 <malloc>
     486:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     488:	4641                	li	a2,16
     48a:	4581                	li	a1,0
     48c:	00001097          	auipc	ra,0x1
     490:	812080e7          	jalr	-2030(ra) # c9e <memset>
  cmd->type = BACK;
     494:	4795                	li	a5,5
     496:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     498:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     49c:	8526                	mv	a0,s1
     49e:	60e2                	ld	ra,24(sp)
     4a0:	6442                	ld	s0,16(sp)
     4a2:	64a2                	ld	s1,8(sp)
     4a4:	6902                	ld	s2,0(sp)
     4a6:	6105                	addi	sp,sp,32
     4a8:	8082                	ret

00000000000004aa <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     4aa:	7139                	addi	sp,sp,-64
     4ac:	fc06                	sd	ra,56(sp)
     4ae:	f822                	sd	s0,48(sp)
     4b0:	f426                	sd	s1,40(sp)
     4b2:	f04a                	sd	s2,32(sp)
     4b4:	ec4e                	sd	s3,24(sp)
     4b6:	e852                	sd	s4,16(sp)
     4b8:	e456                	sd	s5,8(sp)
     4ba:	e05a                	sd	s6,0(sp)
     4bc:	0080                	addi	s0,sp,64
     4be:	8a2a                	mv	s4,a0
     4c0:	892e                	mv	s2,a1
     4c2:	8ab2                	mv	s5,a2
     4c4:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     4c6:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     4c8:	00001997          	auipc	s3,0x1
     4cc:	07898993          	addi	s3,s3,120 # 1540 <whitespace>
     4d0:	00b4fd63          	bgeu	s1,a1,4ea <gettoken+0x40>
     4d4:	0004c583          	lbu	a1,0(s1)
     4d8:	854e                	mv	a0,s3
     4da:	00000097          	auipc	ra,0x0
     4de:	7e6080e7          	jalr	2022(ra) # cc0 <strchr>
     4e2:	c501                	beqz	a0,4ea <gettoken+0x40>
    s++;
     4e4:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     4e6:	fe9917e3          	bne	s2,s1,4d4 <gettoken+0x2a>
  if(q)
     4ea:	000a8463          	beqz	s5,4f2 <gettoken+0x48>
    *q = s;
     4ee:	009ab023          	sd	s1,0(s5)
  ret = *s;
     4f2:	0004c783          	lbu	a5,0(s1)
     4f6:	00078a9b          	sext.w	s5,a5
  switch(*s){
     4fa:	03c00713          	li	a4,60
     4fe:	06f76563          	bltu	a4,a5,568 <gettoken+0xbe>
     502:	03a00713          	li	a4,58
     506:	00f76e63          	bltu	a4,a5,522 <gettoken+0x78>
     50a:	cf89                	beqz	a5,524 <gettoken+0x7a>
     50c:	02600713          	li	a4,38
     510:	00e78963          	beq	a5,a4,522 <gettoken+0x78>
     514:	fd87879b          	addiw	a5,a5,-40
     518:	0ff7f793          	andi	a5,a5,255
     51c:	4705                	li	a4,1
     51e:	06f76c63          	bltu	a4,a5,596 <gettoken+0xec>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     522:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     524:	000b0463          	beqz	s6,52c <gettoken+0x82>
    *eq = s;
     528:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     52c:	00001997          	auipc	s3,0x1
     530:	01498993          	addi	s3,s3,20 # 1540 <whitespace>
     534:	0124fd63          	bgeu	s1,s2,54e <gettoken+0xa4>
     538:	0004c583          	lbu	a1,0(s1)
     53c:	854e                	mv	a0,s3
     53e:	00000097          	auipc	ra,0x0
     542:	782080e7          	jalr	1922(ra) # cc0 <strchr>
     546:	c501                	beqz	a0,54e <gettoken+0xa4>
    s++;
     548:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     54a:	fe9917e3          	bne	s2,s1,538 <gettoken+0x8e>
  *ps = s;
     54e:	009a3023          	sd	s1,0(s4)
  return ret;
}
     552:	8556                	mv	a0,s5
     554:	70e2                	ld	ra,56(sp)
     556:	7442                	ld	s0,48(sp)
     558:	74a2                	ld	s1,40(sp)
     55a:	7902                	ld	s2,32(sp)
     55c:	69e2                	ld	s3,24(sp)
     55e:	6a42                	ld	s4,16(sp)
     560:	6aa2                	ld	s5,8(sp)
     562:	6b02                	ld	s6,0(sp)
     564:	6121                	addi	sp,sp,64
     566:	8082                	ret
  switch(*s){
     568:	03e00713          	li	a4,62
     56c:	02e79163          	bne	a5,a4,58e <gettoken+0xe4>
    s++;
     570:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     574:	0014c703          	lbu	a4,1(s1)
     578:	03e00793          	li	a5,62
      s++;
     57c:	0489                	addi	s1,s1,2
      ret = '+';
     57e:	02b00a93          	li	s5,43
    if(*s == '>'){
     582:	faf701e3          	beq	a4,a5,524 <gettoken+0x7a>
    s++;
     586:	84b6                	mv	s1,a3
  ret = *s;
     588:	03e00a93          	li	s5,62
     58c:	bf61                	j	524 <gettoken+0x7a>
  switch(*s){
     58e:	07c00713          	li	a4,124
     592:	f8e788e3          	beq	a5,a4,522 <gettoken+0x78>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     596:	00001997          	auipc	s3,0x1
     59a:	faa98993          	addi	s3,s3,-86 # 1540 <whitespace>
     59e:	00001a97          	auipc	s5,0x1
     5a2:	f9aa8a93          	addi	s5,s5,-102 # 1538 <symbols>
     5a6:	0324f563          	bgeu	s1,s2,5d0 <gettoken+0x126>
     5aa:	0004c583          	lbu	a1,0(s1)
     5ae:	854e                	mv	a0,s3
     5b0:	00000097          	auipc	ra,0x0
     5b4:	710080e7          	jalr	1808(ra) # cc0 <strchr>
     5b8:	e505                	bnez	a0,5e0 <gettoken+0x136>
     5ba:	0004c583          	lbu	a1,0(s1)
     5be:	8556                	mv	a0,s5
     5c0:	00000097          	auipc	ra,0x0
     5c4:	700080e7          	jalr	1792(ra) # cc0 <strchr>
     5c8:	e909                	bnez	a0,5da <gettoken+0x130>
      s++;
     5ca:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     5cc:	fc991fe3          	bne	s2,s1,5aa <gettoken+0x100>
  if(eq)
     5d0:	06100a93          	li	s5,97
     5d4:	f40b1ae3          	bnez	s6,528 <gettoken+0x7e>
     5d8:	bf9d                	j	54e <gettoken+0xa4>
    ret = 'a';
     5da:	06100a93          	li	s5,97
     5de:	b799                	j	524 <gettoken+0x7a>
     5e0:	06100a93          	li	s5,97
     5e4:	b781                	j	524 <gettoken+0x7a>

00000000000005e6 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     5e6:	7139                	addi	sp,sp,-64
     5e8:	fc06                	sd	ra,56(sp)
     5ea:	f822                	sd	s0,48(sp)
     5ec:	f426                	sd	s1,40(sp)
     5ee:	f04a                	sd	s2,32(sp)
     5f0:	ec4e                	sd	s3,24(sp)
     5f2:	e852                	sd	s4,16(sp)
     5f4:	e456                	sd	s5,8(sp)
     5f6:	0080                	addi	s0,sp,64
     5f8:	8a2a                	mv	s4,a0
     5fa:	892e                	mv	s2,a1
     5fc:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     5fe:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     600:	00001997          	auipc	s3,0x1
     604:	f4098993          	addi	s3,s3,-192 # 1540 <whitespace>
     608:	00b4fd63          	bgeu	s1,a1,622 <peek+0x3c>
     60c:	0004c583          	lbu	a1,0(s1)
     610:	854e                	mv	a0,s3
     612:	00000097          	auipc	ra,0x0
     616:	6ae080e7          	jalr	1710(ra) # cc0 <strchr>
     61a:	c501                	beqz	a0,622 <peek+0x3c>
    s++;
     61c:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     61e:	fe9917e3          	bne	s2,s1,60c <peek+0x26>
  *ps = s;
     622:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     626:	0004c583          	lbu	a1,0(s1)
     62a:	4501                	li	a0,0
     62c:	e991                	bnez	a1,640 <peek+0x5a>
}
     62e:	70e2                	ld	ra,56(sp)
     630:	7442                	ld	s0,48(sp)
     632:	74a2                	ld	s1,40(sp)
     634:	7902                	ld	s2,32(sp)
     636:	69e2                	ld	s3,24(sp)
     638:	6a42                	ld	s4,16(sp)
     63a:	6aa2                	ld	s5,8(sp)
     63c:	6121                	addi	sp,sp,64
     63e:	8082                	ret
  return *s && strchr(toks, *s);
     640:	8556                	mv	a0,s5
     642:	00000097          	auipc	ra,0x0
     646:	67e080e7          	jalr	1662(ra) # cc0 <strchr>
     64a:	00a03533          	snez	a0,a0
     64e:	b7c5                	j	62e <peek+0x48>

0000000000000650 <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     650:	7159                	addi	sp,sp,-112
     652:	f486                	sd	ra,104(sp)
     654:	f0a2                	sd	s0,96(sp)
     656:	eca6                	sd	s1,88(sp)
     658:	e8ca                	sd	s2,80(sp)
     65a:	e4ce                	sd	s3,72(sp)
     65c:	e0d2                	sd	s4,64(sp)
     65e:	fc56                	sd	s5,56(sp)
     660:	f85a                	sd	s6,48(sp)
     662:	f45e                	sd	s7,40(sp)
     664:	f062                	sd	s8,32(sp)
     666:	ec66                	sd	s9,24(sp)
     668:	1880                	addi	s0,sp,112
     66a:	8a2a                	mv	s4,a0
     66c:	89ae                	mv	s3,a1
     66e:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     670:	00001b97          	auipc	s7,0x1
     674:	dd0b8b93          	addi	s7,s7,-560 # 1440 <malloc+0x158>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     678:	06100c13          	li	s8,97
      panic("missing file for redirection");
    switch(tok){
     67c:	03c00c93          	li	s9,60
  while(peek(ps, es, "<>")){
     680:	a02d                	j	6aa <parseredirs+0x5a>
      panic("missing file for redirection");
     682:	00001517          	auipc	a0,0x1
     686:	d9e50513          	addi	a0,a0,-610 # 1420 <malloc+0x138>
     68a:	00000097          	auipc	ra,0x0
     68e:	9ca080e7          	jalr	-1590(ra) # 54 <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     692:	4701                	li	a4,0
     694:	4681                	li	a3,0
     696:	f9043603          	ld	a2,-112(s0)
     69a:	f9843583          	ld	a1,-104(s0)
     69e:	8552                	mv	a0,s4
     6a0:	00000097          	auipc	ra,0x0
     6a4:	cda080e7          	jalr	-806(ra) # 37a <redircmd>
     6a8:	8a2a                	mv	s4,a0
    switch(tok){
     6aa:	03e00b13          	li	s6,62
     6ae:	02b00a93          	li	s5,43
  while(peek(ps, es, "<>")){
     6b2:	865e                	mv	a2,s7
     6b4:	85ca                	mv	a1,s2
     6b6:	854e                	mv	a0,s3
     6b8:	00000097          	auipc	ra,0x0
     6bc:	f2e080e7          	jalr	-210(ra) # 5e6 <peek>
     6c0:	c925                	beqz	a0,730 <parseredirs+0xe0>
    tok = gettoken(ps, es, 0, 0);
     6c2:	4681                	li	a3,0
     6c4:	4601                	li	a2,0
     6c6:	85ca                	mv	a1,s2
     6c8:	854e                	mv	a0,s3
     6ca:	00000097          	auipc	ra,0x0
     6ce:	de0080e7          	jalr	-544(ra) # 4aa <gettoken>
     6d2:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     6d4:	f9040693          	addi	a3,s0,-112
     6d8:	f9840613          	addi	a2,s0,-104
     6dc:	85ca                	mv	a1,s2
     6de:	854e                	mv	a0,s3
     6e0:	00000097          	auipc	ra,0x0
     6e4:	dca080e7          	jalr	-566(ra) # 4aa <gettoken>
     6e8:	f9851de3          	bne	a0,s8,682 <parseredirs+0x32>
    switch(tok){
     6ec:	fb9483e3          	beq	s1,s9,692 <parseredirs+0x42>
     6f0:	03648263          	beq	s1,s6,714 <parseredirs+0xc4>
     6f4:	fb549fe3          	bne	s1,s5,6b2 <parseredirs+0x62>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     6f8:	4705                	li	a4,1
     6fa:	20100693          	li	a3,513
     6fe:	f9043603          	ld	a2,-112(s0)
     702:	f9843583          	ld	a1,-104(s0)
     706:	8552                	mv	a0,s4
     708:	00000097          	auipc	ra,0x0
     70c:	c72080e7          	jalr	-910(ra) # 37a <redircmd>
     710:	8a2a                	mv	s4,a0
      break;
     712:	bf61                	j	6aa <parseredirs+0x5a>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     714:	4705                	li	a4,1
     716:	60100693          	li	a3,1537
     71a:	f9043603          	ld	a2,-112(s0)
     71e:	f9843583          	ld	a1,-104(s0)
     722:	8552                	mv	a0,s4
     724:	00000097          	auipc	ra,0x0
     728:	c56080e7          	jalr	-938(ra) # 37a <redircmd>
     72c:	8a2a                	mv	s4,a0
      break;
     72e:	bfb5                	j	6aa <parseredirs+0x5a>
    }
  }
  return cmd;
}
     730:	8552                	mv	a0,s4
     732:	70a6                	ld	ra,104(sp)
     734:	7406                	ld	s0,96(sp)
     736:	64e6                	ld	s1,88(sp)
     738:	6946                	ld	s2,80(sp)
     73a:	69a6                	ld	s3,72(sp)
     73c:	6a06                	ld	s4,64(sp)
     73e:	7ae2                	ld	s5,56(sp)
     740:	7b42                	ld	s6,48(sp)
     742:	7ba2                	ld	s7,40(sp)
     744:	7c02                	ld	s8,32(sp)
     746:	6ce2                	ld	s9,24(sp)
     748:	6165                	addi	sp,sp,112
     74a:	8082                	ret

000000000000074c <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     74c:	7159                	addi	sp,sp,-112
     74e:	f486                	sd	ra,104(sp)
     750:	f0a2                	sd	s0,96(sp)
     752:	eca6                	sd	s1,88(sp)
     754:	e8ca                	sd	s2,80(sp)
     756:	e4ce                	sd	s3,72(sp)
     758:	e0d2                	sd	s4,64(sp)
     75a:	fc56                	sd	s5,56(sp)
     75c:	f85a                	sd	s6,48(sp)
     75e:	f45e                	sd	s7,40(sp)
     760:	f062                	sd	s8,32(sp)
     762:	ec66                	sd	s9,24(sp)
     764:	1880                	addi	s0,sp,112
     766:	8a2a                	mv	s4,a0
     768:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     76a:	00001617          	auipc	a2,0x1
     76e:	cde60613          	addi	a2,a2,-802 # 1448 <malloc+0x160>
     772:	00000097          	auipc	ra,0x0
     776:	e74080e7          	jalr	-396(ra) # 5e6 <peek>
     77a:	e905                	bnez	a0,7aa <parseexec+0x5e>
     77c:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     77e:	00000097          	auipc	ra,0x0
     782:	bc6080e7          	jalr	-1082(ra) # 344 <execcmd>
     786:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     788:	8656                	mv	a2,s5
     78a:	85d2                	mv	a1,s4
     78c:	00000097          	auipc	ra,0x0
     790:	ec4080e7          	jalr	-316(ra) # 650 <parseredirs>
     794:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     796:	008c0913          	addi	s2,s8,8
     79a:	00001b17          	auipc	s6,0x1
     79e:	cceb0b13          	addi	s6,s6,-818 # 1468 <malloc+0x180>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     7a2:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     7a6:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     7a8:	a0b1                	j	7f4 <parseexec+0xa8>
    return parseblock(ps, es);
     7aa:	85d6                	mv	a1,s5
     7ac:	8552                	mv	a0,s4
     7ae:	00000097          	auipc	ra,0x0
     7b2:	1bc080e7          	jalr	444(ra) # 96a <parseblock>
     7b6:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     7b8:	8526                	mv	a0,s1
     7ba:	70a6                	ld	ra,104(sp)
     7bc:	7406                	ld	s0,96(sp)
     7be:	64e6                	ld	s1,88(sp)
     7c0:	6946                	ld	s2,80(sp)
     7c2:	69a6                	ld	s3,72(sp)
     7c4:	6a06                	ld	s4,64(sp)
     7c6:	7ae2                	ld	s5,56(sp)
     7c8:	7b42                	ld	s6,48(sp)
     7ca:	7ba2                	ld	s7,40(sp)
     7cc:	7c02                	ld	s8,32(sp)
     7ce:	6ce2                	ld	s9,24(sp)
     7d0:	6165                	addi	sp,sp,112
     7d2:	8082                	ret
      panic("syntax");
     7d4:	00001517          	auipc	a0,0x1
     7d8:	c7c50513          	addi	a0,a0,-900 # 1450 <malloc+0x168>
     7dc:	00000097          	auipc	ra,0x0
     7e0:	878080e7          	jalr	-1928(ra) # 54 <panic>
    ret = parseredirs(ret, ps, es);
     7e4:	8656                	mv	a2,s5
     7e6:	85d2                	mv	a1,s4
     7e8:	8526                	mv	a0,s1
     7ea:	00000097          	auipc	ra,0x0
     7ee:	e66080e7          	jalr	-410(ra) # 650 <parseredirs>
     7f2:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     7f4:	865a                	mv	a2,s6
     7f6:	85d6                	mv	a1,s5
     7f8:	8552                	mv	a0,s4
     7fa:	00000097          	auipc	ra,0x0
     7fe:	dec080e7          	jalr	-532(ra) # 5e6 <peek>
     802:	e131                	bnez	a0,846 <parseexec+0xfa>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     804:	f9040693          	addi	a3,s0,-112
     808:	f9840613          	addi	a2,s0,-104
     80c:	85d6                	mv	a1,s5
     80e:	8552                	mv	a0,s4
     810:	00000097          	auipc	ra,0x0
     814:	c9a080e7          	jalr	-870(ra) # 4aa <gettoken>
     818:	c51d                	beqz	a0,846 <parseexec+0xfa>
    if(tok != 'a')
     81a:	fb951de3          	bne	a0,s9,7d4 <parseexec+0x88>
    cmd->argv[argc] = q;
     81e:	f9843783          	ld	a5,-104(s0)
     822:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     826:	f9043783          	ld	a5,-112(s0)
     82a:	04f93823          	sd	a5,80(s2)
    argc++;
     82e:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     830:	0921                	addi	s2,s2,8
     832:	fb7999e3          	bne	s3,s7,7e4 <parseexec+0x98>
      panic("too many args");
     836:	00001517          	auipc	a0,0x1
     83a:	c2250513          	addi	a0,a0,-990 # 1458 <malloc+0x170>
     83e:	00000097          	auipc	ra,0x0
     842:	816080e7          	jalr	-2026(ra) # 54 <panic>
  cmd->argv[argc] = 0;
     846:	098e                	slli	s3,s3,0x3
     848:	99e2                	add	s3,s3,s8
     84a:	0009b423          	sd	zero,8(s3)
  cmd->eargv[argc] = 0;
     84e:	0409bc23          	sd	zero,88(s3)
  return ret;
     852:	b79d                	j	7b8 <parseexec+0x6c>

0000000000000854 <parsepipe>:
{
     854:	7179                	addi	sp,sp,-48
     856:	f406                	sd	ra,40(sp)
     858:	f022                	sd	s0,32(sp)
     85a:	ec26                	sd	s1,24(sp)
     85c:	e84a                	sd	s2,16(sp)
     85e:	e44e                	sd	s3,8(sp)
     860:	1800                	addi	s0,sp,48
     862:	892a                	mv	s2,a0
     864:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     866:	00000097          	auipc	ra,0x0
     86a:	ee6080e7          	jalr	-282(ra) # 74c <parseexec>
     86e:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     870:	00001617          	auipc	a2,0x1
     874:	c0060613          	addi	a2,a2,-1024 # 1470 <malloc+0x188>
     878:	85ce                	mv	a1,s3
     87a:	854a                	mv	a0,s2
     87c:	00000097          	auipc	ra,0x0
     880:	d6a080e7          	jalr	-662(ra) # 5e6 <peek>
     884:	e909                	bnez	a0,896 <parsepipe+0x42>
}
     886:	8526                	mv	a0,s1
     888:	70a2                	ld	ra,40(sp)
     88a:	7402                	ld	s0,32(sp)
     88c:	64e2                	ld	s1,24(sp)
     88e:	6942                	ld	s2,16(sp)
     890:	69a2                	ld	s3,8(sp)
     892:	6145                	addi	sp,sp,48
     894:	8082                	ret
    gettoken(ps, es, 0, 0);
     896:	4681                	li	a3,0
     898:	4601                	li	a2,0
     89a:	85ce                	mv	a1,s3
     89c:	854a                	mv	a0,s2
     89e:	00000097          	auipc	ra,0x0
     8a2:	c0c080e7          	jalr	-1012(ra) # 4aa <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     8a6:	85ce                	mv	a1,s3
     8a8:	854a                	mv	a0,s2
     8aa:	00000097          	auipc	ra,0x0
     8ae:	faa080e7          	jalr	-86(ra) # 854 <parsepipe>
     8b2:	85aa                	mv	a1,a0
     8b4:	8526                	mv	a0,s1
     8b6:	00000097          	auipc	ra,0x0
     8ba:	b2c080e7          	jalr	-1236(ra) # 3e2 <pipecmd>
     8be:	84aa                	mv	s1,a0
  return cmd;
     8c0:	b7d9                	j	886 <parsepipe+0x32>

00000000000008c2 <parseline>:
{
     8c2:	7179                	addi	sp,sp,-48
     8c4:	f406                	sd	ra,40(sp)
     8c6:	f022                	sd	s0,32(sp)
     8c8:	ec26                	sd	s1,24(sp)
     8ca:	e84a                	sd	s2,16(sp)
     8cc:	e44e                	sd	s3,8(sp)
     8ce:	e052                	sd	s4,0(sp)
     8d0:	1800                	addi	s0,sp,48
     8d2:	892a                	mv	s2,a0
     8d4:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     8d6:	00000097          	auipc	ra,0x0
     8da:	f7e080e7          	jalr	-130(ra) # 854 <parsepipe>
     8de:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     8e0:	00001a17          	auipc	s4,0x1
     8e4:	b98a0a13          	addi	s4,s4,-1128 # 1478 <malloc+0x190>
     8e8:	a839                	j	906 <parseline+0x44>
    gettoken(ps, es, 0, 0);
     8ea:	4681                	li	a3,0
     8ec:	4601                	li	a2,0
     8ee:	85ce                	mv	a1,s3
     8f0:	854a                	mv	a0,s2
     8f2:	00000097          	auipc	ra,0x0
     8f6:	bb8080e7          	jalr	-1096(ra) # 4aa <gettoken>
    cmd = backcmd(cmd);
     8fa:	8526                	mv	a0,s1
     8fc:	00000097          	auipc	ra,0x0
     900:	b72080e7          	jalr	-1166(ra) # 46e <backcmd>
     904:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     906:	8652                	mv	a2,s4
     908:	85ce                	mv	a1,s3
     90a:	854a                	mv	a0,s2
     90c:	00000097          	auipc	ra,0x0
     910:	cda080e7          	jalr	-806(ra) # 5e6 <peek>
     914:	f979                	bnez	a0,8ea <parseline+0x28>
  if(peek(ps, es, ";")){
     916:	00001617          	auipc	a2,0x1
     91a:	b6a60613          	addi	a2,a2,-1174 # 1480 <malloc+0x198>
     91e:	85ce                	mv	a1,s3
     920:	854a                	mv	a0,s2
     922:	00000097          	auipc	ra,0x0
     926:	cc4080e7          	jalr	-828(ra) # 5e6 <peek>
     92a:	e911                	bnez	a0,93e <parseline+0x7c>
}
     92c:	8526                	mv	a0,s1
     92e:	70a2                	ld	ra,40(sp)
     930:	7402                	ld	s0,32(sp)
     932:	64e2                	ld	s1,24(sp)
     934:	6942                	ld	s2,16(sp)
     936:	69a2                	ld	s3,8(sp)
     938:	6a02                	ld	s4,0(sp)
     93a:	6145                	addi	sp,sp,48
     93c:	8082                	ret
    gettoken(ps, es, 0, 0);
     93e:	4681                	li	a3,0
     940:	4601                	li	a2,0
     942:	85ce                	mv	a1,s3
     944:	854a                	mv	a0,s2
     946:	00000097          	auipc	ra,0x0
     94a:	b64080e7          	jalr	-1180(ra) # 4aa <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     94e:	85ce                	mv	a1,s3
     950:	854a                	mv	a0,s2
     952:	00000097          	auipc	ra,0x0
     956:	f70080e7          	jalr	-144(ra) # 8c2 <parseline>
     95a:	85aa                	mv	a1,a0
     95c:	8526                	mv	a0,s1
     95e:	00000097          	auipc	ra,0x0
     962:	aca080e7          	jalr	-1334(ra) # 428 <listcmd>
     966:	84aa                	mv	s1,a0
  return cmd;
     968:	b7d1                	j	92c <parseline+0x6a>

000000000000096a <parseblock>:
{
     96a:	7179                	addi	sp,sp,-48
     96c:	f406                	sd	ra,40(sp)
     96e:	f022                	sd	s0,32(sp)
     970:	ec26                	sd	s1,24(sp)
     972:	e84a                	sd	s2,16(sp)
     974:	e44e                	sd	s3,8(sp)
     976:	1800                	addi	s0,sp,48
     978:	84aa                	mv	s1,a0
     97a:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     97c:	00001617          	auipc	a2,0x1
     980:	acc60613          	addi	a2,a2,-1332 # 1448 <malloc+0x160>
     984:	00000097          	auipc	ra,0x0
     988:	c62080e7          	jalr	-926(ra) # 5e6 <peek>
     98c:	c12d                	beqz	a0,9ee <parseblock+0x84>
  gettoken(ps, es, 0, 0);
     98e:	4681                	li	a3,0
     990:	4601                	li	a2,0
     992:	85ca                	mv	a1,s2
     994:	8526                	mv	a0,s1
     996:	00000097          	auipc	ra,0x0
     99a:	b14080e7          	jalr	-1260(ra) # 4aa <gettoken>
  cmd = parseline(ps, es);
     99e:	85ca                	mv	a1,s2
     9a0:	8526                	mv	a0,s1
     9a2:	00000097          	auipc	ra,0x0
     9a6:	f20080e7          	jalr	-224(ra) # 8c2 <parseline>
     9aa:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     9ac:	00001617          	auipc	a2,0x1
     9b0:	aec60613          	addi	a2,a2,-1300 # 1498 <malloc+0x1b0>
     9b4:	85ca                	mv	a1,s2
     9b6:	8526                	mv	a0,s1
     9b8:	00000097          	auipc	ra,0x0
     9bc:	c2e080e7          	jalr	-978(ra) # 5e6 <peek>
     9c0:	cd1d                	beqz	a0,9fe <parseblock+0x94>
  gettoken(ps, es, 0, 0);
     9c2:	4681                	li	a3,0
     9c4:	4601                	li	a2,0
     9c6:	85ca                	mv	a1,s2
     9c8:	8526                	mv	a0,s1
     9ca:	00000097          	auipc	ra,0x0
     9ce:	ae0080e7          	jalr	-1312(ra) # 4aa <gettoken>
  cmd = parseredirs(cmd, ps, es);
     9d2:	864a                	mv	a2,s2
     9d4:	85a6                	mv	a1,s1
     9d6:	854e                	mv	a0,s3
     9d8:	00000097          	auipc	ra,0x0
     9dc:	c78080e7          	jalr	-904(ra) # 650 <parseredirs>
}
     9e0:	70a2                	ld	ra,40(sp)
     9e2:	7402                	ld	s0,32(sp)
     9e4:	64e2                	ld	s1,24(sp)
     9e6:	6942                	ld	s2,16(sp)
     9e8:	69a2                	ld	s3,8(sp)
     9ea:	6145                	addi	sp,sp,48
     9ec:	8082                	ret
    panic("parseblock");
     9ee:	00001517          	auipc	a0,0x1
     9f2:	a9a50513          	addi	a0,a0,-1382 # 1488 <malloc+0x1a0>
     9f6:	fffff097          	auipc	ra,0xfffff
     9fa:	65e080e7          	jalr	1630(ra) # 54 <panic>
    panic("syntax - missing )");
     9fe:	00001517          	auipc	a0,0x1
     a02:	aa250513          	addi	a0,a0,-1374 # 14a0 <malloc+0x1b8>
     a06:	fffff097          	auipc	ra,0xfffff
     a0a:	64e080e7          	jalr	1614(ra) # 54 <panic>

0000000000000a0e <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     a0e:	1101                	addi	sp,sp,-32
     a10:	ec06                	sd	ra,24(sp)
     a12:	e822                	sd	s0,16(sp)
     a14:	e426                	sd	s1,8(sp)
     a16:	1000                	addi	s0,sp,32
     a18:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     a1a:	c521                	beqz	a0,a62 <nulterminate+0x54>
    return 0;

  switch(cmd->type){
     a1c:	4118                	lw	a4,0(a0)
     a1e:	4795                	li	a5,5
     a20:	04e7e163          	bltu	a5,a4,a62 <nulterminate+0x54>
     a24:	00056783          	lwu	a5,0(a0)
     a28:	078a                	slli	a5,a5,0x2
     a2a:	00001717          	auipc	a4,0x1
     a2e:	ad670713          	addi	a4,a4,-1322 # 1500 <malloc+0x218>
     a32:	97ba                	add	a5,a5,a4
     a34:	439c                	lw	a5,0(a5)
     a36:	97ba                	add	a5,a5,a4
     a38:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     a3a:	651c                	ld	a5,8(a0)
     a3c:	c39d                	beqz	a5,a62 <nulterminate+0x54>
     a3e:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     a42:	67b8                	ld	a4,72(a5)
     a44:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     a48:	07a1                	addi	a5,a5,8
     a4a:	ff87b703          	ld	a4,-8(a5)
     a4e:	fb75                	bnez	a4,a42 <nulterminate+0x34>
     a50:	a809                	j	a62 <nulterminate+0x54>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     a52:	6508                	ld	a0,8(a0)
     a54:	00000097          	auipc	ra,0x0
     a58:	fba080e7          	jalr	-70(ra) # a0e <nulterminate>
    *rcmd->efile = 0;
     a5c:	6c9c                	ld	a5,24(s1)
     a5e:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     a62:	8526                	mv	a0,s1
     a64:	60e2                	ld	ra,24(sp)
     a66:	6442                	ld	s0,16(sp)
     a68:	64a2                	ld	s1,8(sp)
     a6a:	6105                	addi	sp,sp,32
     a6c:	8082                	ret
    nulterminate(pcmd->left);
     a6e:	6508                	ld	a0,8(a0)
     a70:	00000097          	auipc	ra,0x0
     a74:	f9e080e7          	jalr	-98(ra) # a0e <nulterminate>
    nulterminate(pcmd->right);
     a78:	6888                	ld	a0,16(s1)
     a7a:	00000097          	auipc	ra,0x0
     a7e:	f94080e7          	jalr	-108(ra) # a0e <nulterminate>
    break;
     a82:	b7c5                	j	a62 <nulterminate+0x54>
    nulterminate(lcmd->left);
     a84:	6508                	ld	a0,8(a0)
     a86:	00000097          	auipc	ra,0x0
     a8a:	f88080e7          	jalr	-120(ra) # a0e <nulterminate>
    nulterminate(lcmd->right);
     a8e:	6888                	ld	a0,16(s1)
     a90:	00000097          	auipc	ra,0x0
     a94:	f7e080e7          	jalr	-130(ra) # a0e <nulterminate>
    break;
     a98:	b7e9                	j	a62 <nulterminate+0x54>
    nulterminate(bcmd->cmd);
     a9a:	6508                	ld	a0,8(a0)
     a9c:	00000097          	auipc	ra,0x0
     aa0:	f72080e7          	jalr	-142(ra) # a0e <nulterminate>
    break;
     aa4:	bf7d                	j	a62 <nulterminate+0x54>

0000000000000aa6 <parsecmd>:
{
     aa6:	7179                	addi	sp,sp,-48
     aa8:	f406                	sd	ra,40(sp)
     aaa:	f022                	sd	s0,32(sp)
     aac:	ec26                	sd	s1,24(sp)
     aae:	e84a                	sd	s2,16(sp)
     ab0:	1800                	addi	s0,sp,48
     ab2:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     ab6:	84aa                	mv	s1,a0
     ab8:	00000097          	auipc	ra,0x0
     abc:	1bc080e7          	jalr	444(ra) # c74 <strlen>
     ac0:	1502                	slli	a0,a0,0x20
     ac2:	9101                	srli	a0,a0,0x20
     ac4:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     ac6:	85a6                	mv	a1,s1
     ac8:	fd840513          	addi	a0,s0,-40
     acc:	00000097          	auipc	ra,0x0
     ad0:	df6080e7          	jalr	-522(ra) # 8c2 <parseline>
     ad4:	892a                	mv	s2,a0
  peek(&s, es, "");
     ad6:	00001617          	auipc	a2,0x1
     ada:	9e260613          	addi	a2,a2,-1566 # 14b8 <malloc+0x1d0>
     ade:	85a6                	mv	a1,s1
     ae0:	fd840513          	addi	a0,s0,-40
     ae4:	00000097          	auipc	ra,0x0
     ae8:	b02080e7          	jalr	-1278(ra) # 5e6 <peek>
  if(s != es){
     aec:	fd843603          	ld	a2,-40(s0)
     af0:	00961e63          	bne	a2,s1,b0c <parsecmd+0x66>
  nulterminate(cmd);
     af4:	854a                	mv	a0,s2
     af6:	00000097          	auipc	ra,0x0
     afa:	f18080e7          	jalr	-232(ra) # a0e <nulterminate>
}
     afe:	854a                	mv	a0,s2
     b00:	70a2                	ld	ra,40(sp)
     b02:	7402                	ld	s0,32(sp)
     b04:	64e2                	ld	s1,24(sp)
     b06:	6942                	ld	s2,16(sp)
     b08:	6145                	addi	sp,sp,48
     b0a:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     b0c:	00001597          	auipc	a1,0x1
     b10:	9b458593          	addi	a1,a1,-1612 # 14c0 <malloc+0x1d8>
     b14:	4509                	li	a0,2
     b16:	00000097          	auipc	ra,0x0
     b1a:	6e6080e7          	jalr	1766(ra) # 11fc <fprintf>
    panic("syntax");
     b1e:	00001517          	auipc	a0,0x1
     b22:	93250513          	addi	a0,a0,-1742 # 1450 <malloc+0x168>
     b26:	fffff097          	auipc	ra,0xfffff
     b2a:	52e080e7          	jalr	1326(ra) # 54 <panic>

0000000000000b2e <main>:
{
     b2e:	7139                	addi	sp,sp,-64
     b30:	fc06                	sd	ra,56(sp)
     b32:	f822                	sd	s0,48(sp)
     b34:	f426                	sd	s1,40(sp)
     b36:	f04a                	sd	s2,32(sp)
     b38:	ec4e                	sd	s3,24(sp)
     b3a:	e852                	sd	s4,16(sp)
     b3c:	e456                	sd	s5,8(sp)
     b3e:	e05a                	sd	s6,0(sp)
     b40:	0080                	addi	s0,sp,64
  while((fd = open("console", O_RDWR)) >= 0){
     b42:	00001497          	auipc	s1,0x1
     b46:	98e48493          	addi	s1,s1,-1650 # 14d0 <malloc+0x1e8>
     b4a:	4589                	li	a1,2
     b4c:	8526                	mv	a0,s1
     b4e:	00000097          	auipc	ra,0x0
     b52:	38c080e7          	jalr	908(ra) # eda <open>
     b56:	00054963          	bltz	a0,b68 <main+0x3a>
    if(fd >= 3){
     b5a:	4789                	li	a5,2
     b5c:	fea7d7e3          	bge	a5,a0,b4a <main+0x1c>
      close(fd);
     b60:	00000097          	auipc	ra,0x0
     b64:	362080e7          	jalr	866(ra) # ec2 <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     b68:	00001917          	auipc	s2,0x1
     b6c:	be890913          	addi	s2,s2,-1048 # 1750 <buf.0>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     b70:	00001497          	auipc	s1,0x1
     b74:	9e048493          	addi	s1,s1,-1568 # 1550 <PATH>
     b78:	06300993          	li	s3,99
     b7c:	02000a13          	li	s4,32
      if(chdir(buf+3) < 0)
     b80:	00001a97          	auipc	s5,0x1
     b84:	bd3a8a93          	addi	s5,s5,-1069 # 1753 <buf.0+0x3>
        fprintf(2, "cannot cd %s\n", buf+3);
     b88:	00001b17          	auipc	s6,0x1
     b8c:	950b0b13          	addi	s6,s6,-1712 # 14d8 <malloc+0x1f0>
     b90:	a819                	j	ba6 <main+0x78>
    if(fork1() == 0)
     b92:	fffff097          	auipc	ra,0xfffff
     b96:	4e8080e7          	jalr	1256(ra) # 7a <fork1>
     b9a:	c925                	beqz	a0,c0a <main+0xdc>
    wait(0);
     b9c:	4501                	li	a0,0
     b9e:	00000097          	auipc	ra,0x0
     ba2:	304080e7          	jalr	772(ra) # ea2 <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     ba6:	06400593          	li	a1,100
     baa:	854a                	mv	a0,s2
     bac:	fffff097          	auipc	ra,0xfffff
     bb0:	454080e7          	jalr	1108(ra) # 0 <getcmd>
     bb4:	06054763          	bltz	a0,c22 <main+0xf4>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     bb8:	2004c783          	lbu	a5,512(s1)
     bbc:	fd379be3          	bne	a5,s3,b92 <main+0x64>
     bc0:	2014c703          	lbu	a4,513(s1)
     bc4:	06400793          	li	a5,100
     bc8:	fcf715e3          	bne	a4,a5,b92 <main+0x64>
     bcc:	2024c783          	lbu	a5,514(s1)
     bd0:	fd4791e3          	bne	a5,s4,b92 <main+0x64>
      buf[strlen(buf)-1] = 0;  // chop \n
     bd4:	854a                	mv	a0,s2
     bd6:	00000097          	auipc	ra,0x0
     bda:	09e080e7          	jalr	158(ra) # c74 <strlen>
     bde:	fff5079b          	addiw	a5,a0,-1
     be2:	1782                	slli	a5,a5,0x20
     be4:	9381                	srli	a5,a5,0x20
     be6:	97a6                	add	a5,a5,s1
     be8:	20078023          	sb	zero,512(a5)
      if(chdir(buf+3) < 0)
     bec:	8556                	mv	a0,s5
     bee:	00000097          	auipc	ra,0x0
     bf2:	31c080e7          	jalr	796(ra) # f0a <chdir>
     bf6:	fa0558e3          	bgez	a0,ba6 <main+0x78>
        fprintf(2, "cannot cd %s\n", buf+3);
     bfa:	8656                	mv	a2,s5
     bfc:	85da                	mv	a1,s6
     bfe:	4509                	li	a0,2
     c00:	00000097          	auipc	ra,0x0
     c04:	5fc080e7          	jalr	1532(ra) # 11fc <fprintf>
     c08:	bf79                	j	ba6 <main+0x78>
      runcmd(parsecmd(buf));
     c0a:	00001517          	auipc	a0,0x1
     c0e:	b4650513          	addi	a0,a0,-1210 # 1750 <buf.0>
     c12:	00000097          	auipc	ra,0x0
     c16:	e94080e7          	jalr	-364(ra) # aa6 <parsecmd>
     c1a:	fffff097          	auipc	ra,0xfffff
     c1e:	48e080e7          	jalr	1166(ra) # a8 <runcmd>
  exit(0);
     c22:	4501                	li	a0,0
     c24:	00000097          	auipc	ra,0x0
     c28:	276080e7          	jalr	630(ra) # e9a <exit>

0000000000000c2c <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     c2c:	1141                	addi	sp,sp,-16
     c2e:	e422                	sd	s0,8(sp)
     c30:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     c32:	87aa                	mv	a5,a0
     c34:	0585                	addi	a1,a1,1
     c36:	0785                	addi	a5,a5,1
     c38:	fff5c703          	lbu	a4,-1(a1)
     c3c:	fee78fa3          	sb	a4,-1(a5)
     c40:	fb75                	bnez	a4,c34 <strcpy+0x8>
    ;
  return os;
}
     c42:	6422                	ld	s0,8(sp)
     c44:	0141                	addi	sp,sp,16
     c46:	8082                	ret

0000000000000c48 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     c48:	1141                	addi	sp,sp,-16
     c4a:	e422                	sd	s0,8(sp)
     c4c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     c4e:	00054783          	lbu	a5,0(a0)
     c52:	cb91                	beqz	a5,c66 <strcmp+0x1e>
     c54:	0005c703          	lbu	a4,0(a1)
     c58:	00f71763          	bne	a4,a5,c66 <strcmp+0x1e>
    p++, q++;
     c5c:	0505                	addi	a0,a0,1
     c5e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     c60:	00054783          	lbu	a5,0(a0)
     c64:	fbe5                	bnez	a5,c54 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     c66:	0005c503          	lbu	a0,0(a1)
}
     c6a:	40a7853b          	subw	a0,a5,a0
     c6e:	6422                	ld	s0,8(sp)
     c70:	0141                	addi	sp,sp,16
     c72:	8082                	ret

0000000000000c74 <strlen>:

uint
strlen(const char *s)
{
     c74:	1141                	addi	sp,sp,-16
     c76:	e422                	sd	s0,8(sp)
     c78:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     c7a:	00054783          	lbu	a5,0(a0)
     c7e:	cf91                	beqz	a5,c9a <strlen+0x26>
     c80:	0505                	addi	a0,a0,1
     c82:	87aa                	mv	a5,a0
     c84:	4685                	li	a3,1
     c86:	9e89                	subw	a3,a3,a0
     c88:	00f6853b          	addw	a0,a3,a5
     c8c:	0785                	addi	a5,a5,1
     c8e:	fff7c703          	lbu	a4,-1(a5)
     c92:	fb7d                	bnez	a4,c88 <strlen+0x14>
    ;
  return n;
}
     c94:	6422                	ld	s0,8(sp)
     c96:	0141                	addi	sp,sp,16
     c98:	8082                	ret
  for(n = 0; s[n]; n++)
     c9a:	4501                	li	a0,0
     c9c:	bfe5                	j	c94 <strlen+0x20>

0000000000000c9e <memset>:

void*
memset(void *dst, int c, uint n)
{
     c9e:	1141                	addi	sp,sp,-16
     ca0:	e422                	sd	s0,8(sp)
     ca2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     ca4:	ca19                	beqz	a2,cba <memset+0x1c>
     ca6:	87aa                	mv	a5,a0
     ca8:	1602                	slli	a2,a2,0x20
     caa:	9201                	srli	a2,a2,0x20
     cac:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     cb0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     cb4:	0785                	addi	a5,a5,1
     cb6:	fee79de3          	bne	a5,a4,cb0 <memset+0x12>
  }
  return dst;
}
     cba:	6422                	ld	s0,8(sp)
     cbc:	0141                	addi	sp,sp,16
     cbe:	8082                	ret

0000000000000cc0 <strchr>:

char*
strchr(const char *s, char c)
{
     cc0:	1141                	addi	sp,sp,-16
     cc2:	e422                	sd	s0,8(sp)
     cc4:	0800                	addi	s0,sp,16
  for(; *s; s++)
     cc6:	00054783          	lbu	a5,0(a0)
     cca:	cb99                	beqz	a5,ce0 <strchr+0x20>
    if(*s == c)
     ccc:	00f58763          	beq	a1,a5,cda <strchr+0x1a>
  for(; *s; s++)
     cd0:	0505                	addi	a0,a0,1
     cd2:	00054783          	lbu	a5,0(a0)
     cd6:	fbfd                	bnez	a5,ccc <strchr+0xc>
      return (char*)s;
  return 0;
     cd8:	4501                	li	a0,0
}
     cda:	6422                	ld	s0,8(sp)
     cdc:	0141                	addi	sp,sp,16
     cde:	8082                	ret
  return 0;
     ce0:	4501                	li	a0,0
     ce2:	bfe5                	j	cda <strchr+0x1a>

0000000000000ce4 <gets>:

char*
gets(char *buf, int max)
{
     ce4:	711d                	addi	sp,sp,-96
     ce6:	ec86                	sd	ra,88(sp)
     ce8:	e8a2                	sd	s0,80(sp)
     cea:	e4a6                	sd	s1,72(sp)
     cec:	e0ca                	sd	s2,64(sp)
     cee:	fc4e                	sd	s3,56(sp)
     cf0:	f852                	sd	s4,48(sp)
     cf2:	f456                	sd	s5,40(sp)
     cf4:	f05a                	sd	s6,32(sp)
     cf6:	ec5e                	sd	s7,24(sp)
     cf8:	1080                	addi	s0,sp,96
     cfa:	8baa                	mv	s7,a0
     cfc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     cfe:	892a                	mv	s2,a0
     d00:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     d02:	4aa9                	li	s5,10
     d04:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     d06:	89a6                	mv	s3,s1
     d08:	2485                	addiw	s1,s1,1
     d0a:	0344d863          	bge	s1,s4,d3a <gets+0x56>
    cc = read(0, &c, 1);
     d0e:	4605                	li	a2,1
     d10:	faf40593          	addi	a1,s0,-81
     d14:	4501                	li	a0,0
     d16:	00000097          	auipc	ra,0x0
     d1a:	19c080e7          	jalr	412(ra) # eb2 <read>
    if(cc < 1)
     d1e:	00a05e63          	blez	a0,d3a <gets+0x56>
    buf[i++] = c;
     d22:	faf44783          	lbu	a5,-81(s0)
     d26:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     d2a:	01578763          	beq	a5,s5,d38 <gets+0x54>
     d2e:	0905                	addi	s2,s2,1
     d30:	fd679be3          	bne	a5,s6,d06 <gets+0x22>
  for(i=0; i+1 < max; ){
     d34:	89a6                	mv	s3,s1
     d36:	a011                	j	d3a <gets+0x56>
     d38:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     d3a:	99de                	add	s3,s3,s7
     d3c:	00098023          	sb	zero,0(s3)
  return buf;
}
     d40:	855e                	mv	a0,s7
     d42:	60e6                	ld	ra,88(sp)
     d44:	6446                	ld	s0,80(sp)
     d46:	64a6                	ld	s1,72(sp)
     d48:	6906                	ld	s2,64(sp)
     d4a:	79e2                	ld	s3,56(sp)
     d4c:	7a42                	ld	s4,48(sp)
     d4e:	7aa2                	ld	s5,40(sp)
     d50:	7b02                	ld	s6,32(sp)
     d52:	6be2                	ld	s7,24(sp)
     d54:	6125                	addi	sp,sp,96
     d56:	8082                	ret

0000000000000d58 <stat>:

int
stat(const char *n, struct stat *st)
{
     d58:	1101                	addi	sp,sp,-32
     d5a:	ec06                	sd	ra,24(sp)
     d5c:	e822                	sd	s0,16(sp)
     d5e:	e426                	sd	s1,8(sp)
     d60:	e04a                	sd	s2,0(sp)
     d62:	1000                	addi	s0,sp,32
     d64:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     d66:	4581                	li	a1,0
     d68:	00000097          	auipc	ra,0x0
     d6c:	172080e7          	jalr	370(ra) # eda <open>
  if(fd < 0)
     d70:	02054563          	bltz	a0,d9a <stat+0x42>
     d74:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     d76:	85ca                	mv	a1,s2
     d78:	00000097          	auipc	ra,0x0
     d7c:	17a080e7          	jalr	378(ra) # ef2 <fstat>
     d80:	892a                	mv	s2,a0
  close(fd);
     d82:	8526                	mv	a0,s1
     d84:	00000097          	auipc	ra,0x0
     d88:	13e080e7          	jalr	318(ra) # ec2 <close>
  return r;
}
     d8c:	854a                	mv	a0,s2
     d8e:	60e2                	ld	ra,24(sp)
     d90:	6442                	ld	s0,16(sp)
     d92:	64a2                	ld	s1,8(sp)
     d94:	6902                	ld	s2,0(sp)
     d96:	6105                	addi	sp,sp,32
     d98:	8082                	ret
    return -1;
     d9a:	597d                	li	s2,-1
     d9c:	bfc5                	j	d8c <stat+0x34>

0000000000000d9e <atoi>:

int
atoi(const char *s)
{
     d9e:	1141                	addi	sp,sp,-16
     da0:	e422                	sd	s0,8(sp)
     da2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     da4:	00054603          	lbu	a2,0(a0)
     da8:	fd06079b          	addiw	a5,a2,-48
     dac:	0ff7f793          	andi	a5,a5,255
     db0:	4725                	li	a4,9
     db2:	02f76963          	bltu	a4,a5,de4 <atoi+0x46>
     db6:	86aa                	mv	a3,a0
  n = 0;
     db8:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     dba:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     dbc:	0685                	addi	a3,a3,1
     dbe:	0025179b          	slliw	a5,a0,0x2
     dc2:	9fa9                	addw	a5,a5,a0
     dc4:	0017979b          	slliw	a5,a5,0x1
     dc8:	9fb1                	addw	a5,a5,a2
     dca:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     dce:	0006c603          	lbu	a2,0(a3)
     dd2:	fd06071b          	addiw	a4,a2,-48
     dd6:	0ff77713          	andi	a4,a4,255
     dda:	fee5f1e3          	bgeu	a1,a4,dbc <atoi+0x1e>
  return n;
}
     dde:	6422                	ld	s0,8(sp)
     de0:	0141                	addi	sp,sp,16
     de2:	8082                	ret
  n = 0;
     de4:	4501                	li	a0,0
     de6:	bfe5                	j	dde <atoi+0x40>

0000000000000de8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     de8:	1141                	addi	sp,sp,-16
     dea:	e422                	sd	s0,8(sp)
     dec:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     dee:	02b57463          	bgeu	a0,a1,e16 <memmove+0x2e>
    while(n-- > 0)
     df2:	00c05f63          	blez	a2,e10 <memmove+0x28>
     df6:	1602                	slli	a2,a2,0x20
     df8:	9201                	srli	a2,a2,0x20
     dfa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     dfe:	872a                	mv	a4,a0
      *dst++ = *src++;
     e00:	0585                	addi	a1,a1,1
     e02:	0705                	addi	a4,a4,1
     e04:	fff5c683          	lbu	a3,-1(a1)
     e08:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     e0c:	fee79ae3          	bne	a5,a4,e00 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     e10:	6422                	ld	s0,8(sp)
     e12:	0141                	addi	sp,sp,16
     e14:	8082                	ret
    dst += n;
     e16:	00c50733          	add	a4,a0,a2
    src += n;
     e1a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     e1c:	fec05ae3          	blez	a2,e10 <memmove+0x28>
     e20:	fff6079b          	addiw	a5,a2,-1
     e24:	1782                	slli	a5,a5,0x20
     e26:	9381                	srli	a5,a5,0x20
     e28:	fff7c793          	not	a5,a5
     e2c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     e2e:	15fd                	addi	a1,a1,-1
     e30:	177d                	addi	a4,a4,-1
     e32:	0005c683          	lbu	a3,0(a1)
     e36:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     e3a:	fee79ae3          	bne	a5,a4,e2e <memmove+0x46>
     e3e:	bfc9                	j	e10 <memmove+0x28>

0000000000000e40 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     e40:	1141                	addi	sp,sp,-16
     e42:	e422                	sd	s0,8(sp)
     e44:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     e46:	ca05                	beqz	a2,e76 <memcmp+0x36>
     e48:	fff6069b          	addiw	a3,a2,-1
     e4c:	1682                	slli	a3,a3,0x20
     e4e:	9281                	srli	a3,a3,0x20
     e50:	0685                	addi	a3,a3,1
     e52:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     e54:	00054783          	lbu	a5,0(a0)
     e58:	0005c703          	lbu	a4,0(a1)
     e5c:	00e79863          	bne	a5,a4,e6c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     e60:	0505                	addi	a0,a0,1
    p2++;
     e62:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     e64:	fed518e3          	bne	a0,a3,e54 <memcmp+0x14>
  }
  return 0;
     e68:	4501                	li	a0,0
     e6a:	a019                	j	e70 <memcmp+0x30>
      return *p1 - *p2;
     e6c:	40e7853b          	subw	a0,a5,a4
}
     e70:	6422                	ld	s0,8(sp)
     e72:	0141                	addi	sp,sp,16
     e74:	8082                	ret
  return 0;
     e76:	4501                	li	a0,0
     e78:	bfe5                	j	e70 <memcmp+0x30>

0000000000000e7a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     e7a:	1141                	addi	sp,sp,-16
     e7c:	e406                	sd	ra,8(sp)
     e7e:	e022                	sd	s0,0(sp)
     e80:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     e82:	00000097          	auipc	ra,0x0
     e86:	f66080e7          	jalr	-154(ra) # de8 <memmove>
}
     e8a:	60a2                	ld	ra,8(sp)
     e8c:	6402                	ld	s0,0(sp)
     e8e:	0141                	addi	sp,sp,16
     e90:	8082                	ret

0000000000000e92 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     e92:	4885                	li	a7,1
 ecall
     e94:	00000073          	ecall
 ret
     e98:	8082                	ret

0000000000000e9a <exit>:
.global exit
exit:
 li a7, SYS_exit
     e9a:	4889                	li	a7,2
 ecall
     e9c:	00000073          	ecall
 ret
     ea0:	8082                	ret

0000000000000ea2 <wait>:
.global wait
wait:
 li a7, SYS_wait
     ea2:	488d                	li	a7,3
 ecall
     ea4:	00000073          	ecall
 ret
     ea8:	8082                	ret

0000000000000eaa <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     eaa:	4891                	li	a7,4
 ecall
     eac:	00000073          	ecall
 ret
     eb0:	8082                	ret

0000000000000eb2 <read>:
.global read
read:
 li a7, SYS_read
     eb2:	4895                	li	a7,5
 ecall
     eb4:	00000073          	ecall
 ret
     eb8:	8082                	ret

0000000000000eba <write>:
.global write
write:
 li a7, SYS_write
     eba:	48c1                	li	a7,16
 ecall
     ebc:	00000073          	ecall
 ret
     ec0:	8082                	ret

0000000000000ec2 <close>:
.global close
close:
 li a7, SYS_close
     ec2:	48d5                	li	a7,21
 ecall
     ec4:	00000073          	ecall
 ret
     ec8:	8082                	ret

0000000000000eca <kill>:
.global kill
kill:
 li a7, SYS_kill
     eca:	4899                	li	a7,6
 ecall
     ecc:	00000073          	ecall
 ret
     ed0:	8082                	ret

0000000000000ed2 <exec>:
.global exec
exec:
 li a7, SYS_exec
     ed2:	489d                	li	a7,7
 ecall
     ed4:	00000073          	ecall
 ret
     ed8:	8082                	ret

0000000000000eda <open>:
.global open
open:
 li a7, SYS_open
     eda:	48bd                	li	a7,15
 ecall
     edc:	00000073          	ecall
 ret
     ee0:	8082                	ret

0000000000000ee2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     ee2:	48c5                	li	a7,17
 ecall
     ee4:	00000073          	ecall
 ret
     ee8:	8082                	ret

0000000000000eea <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     eea:	48c9                	li	a7,18
 ecall
     eec:	00000073          	ecall
 ret
     ef0:	8082                	ret

0000000000000ef2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     ef2:	48a1                	li	a7,8
 ecall
     ef4:	00000073          	ecall
 ret
     ef8:	8082                	ret

0000000000000efa <link>:
.global link
link:
 li a7, SYS_link
     efa:	48cd                	li	a7,19
 ecall
     efc:	00000073          	ecall
 ret
     f00:	8082                	ret

0000000000000f02 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     f02:	48d1                	li	a7,20
 ecall
     f04:	00000073          	ecall
 ret
     f08:	8082                	ret

0000000000000f0a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     f0a:	48a5                	li	a7,9
 ecall
     f0c:	00000073          	ecall
 ret
     f10:	8082                	ret

0000000000000f12 <dup>:
.global dup
dup:
 li a7, SYS_dup
     f12:	48a9                	li	a7,10
 ecall
     f14:	00000073          	ecall
 ret
     f18:	8082                	ret

0000000000000f1a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     f1a:	48ad                	li	a7,11
 ecall
     f1c:	00000073          	ecall
 ret
     f20:	8082                	ret

0000000000000f22 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     f22:	48b1                	li	a7,12
 ecall
     f24:	00000073          	ecall
 ret
     f28:	8082                	ret

0000000000000f2a <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     f2a:	48b5                	li	a7,13
 ecall
     f2c:	00000073          	ecall
 ret
     f30:	8082                	ret

0000000000000f32 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     f32:	48b9                	li	a7,14
 ecall
     f34:	00000073          	ecall
 ret
     f38:	8082                	ret

0000000000000f3a <trace>:
.global trace
trace:
 li a7, SYS_trace
     f3a:	48d9                	li	a7,22
 ecall
     f3c:	00000073          	ecall
 ret
     f40:	8082                	ret

0000000000000f42 <wait_stat>:
.global wait_stat
wait_stat:
 li a7, SYS_wait_stat
     f42:	48dd                	li	a7,23
 ecall
     f44:	00000073          	ecall
 ret
     f48:	8082                	ret

0000000000000f4a <set_priority>:
.global set_priority
set_priority:
 li a7, SYS_set_priority
     f4a:	48e1                	li	a7,24
 ecall
     f4c:	00000073          	ecall
 ret
     f50:	8082                	ret

0000000000000f52 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     f52:	1101                	addi	sp,sp,-32
     f54:	ec06                	sd	ra,24(sp)
     f56:	e822                	sd	s0,16(sp)
     f58:	1000                	addi	s0,sp,32
     f5a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     f5e:	4605                	li	a2,1
     f60:	fef40593          	addi	a1,s0,-17
     f64:	00000097          	auipc	ra,0x0
     f68:	f56080e7          	jalr	-170(ra) # eba <write>
}
     f6c:	60e2                	ld	ra,24(sp)
     f6e:	6442                	ld	s0,16(sp)
     f70:	6105                	addi	sp,sp,32
     f72:	8082                	ret

0000000000000f74 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     f74:	7139                	addi	sp,sp,-64
     f76:	fc06                	sd	ra,56(sp)
     f78:	f822                	sd	s0,48(sp)
     f7a:	f426                	sd	s1,40(sp)
     f7c:	f04a                	sd	s2,32(sp)
     f7e:	ec4e                	sd	s3,24(sp)
     f80:	0080                	addi	s0,sp,64
     f82:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     f84:	c299                	beqz	a3,f8a <printint+0x16>
     f86:	0805c863          	bltz	a1,1016 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     f8a:	2581                	sext.w	a1,a1
  neg = 0;
     f8c:	4881                	li	a7,0
     f8e:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     f92:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     f94:	2601                	sext.w	a2,a2
     f96:	00000517          	auipc	a0,0x0
     f9a:	58a50513          	addi	a0,a0,1418 # 1520 <digits>
     f9e:	883a                	mv	a6,a4
     fa0:	2705                	addiw	a4,a4,1
     fa2:	02c5f7bb          	remuw	a5,a1,a2
     fa6:	1782                	slli	a5,a5,0x20
     fa8:	9381                	srli	a5,a5,0x20
     faa:	97aa                	add	a5,a5,a0
     fac:	0007c783          	lbu	a5,0(a5)
     fb0:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     fb4:	0005879b          	sext.w	a5,a1
     fb8:	02c5d5bb          	divuw	a1,a1,a2
     fbc:	0685                	addi	a3,a3,1
     fbe:	fec7f0e3          	bgeu	a5,a2,f9e <printint+0x2a>
  if(neg)
     fc2:	00088b63          	beqz	a7,fd8 <printint+0x64>
    buf[i++] = '-';
     fc6:	fd040793          	addi	a5,s0,-48
     fca:	973e                	add	a4,a4,a5
     fcc:	02d00793          	li	a5,45
     fd0:	fef70823          	sb	a5,-16(a4)
     fd4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     fd8:	02e05863          	blez	a4,1008 <printint+0x94>
     fdc:	fc040793          	addi	a5,s0,-64
     fe0:	00e78933          	add	s2,a5,a4
     fe4:	fff78993          	addi	s3,a5,-1
     fe8:	99ba                	add	s3,s3,a4
     fea:	377d                	addiw	a4,a4,-1
     fec:	1702                	slli	a4,a4,0x20
     fee:	9301                	srli	a4,a4,0x20
     ff0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     ff4:	fff94583          	lbu	a1,-1(s2)
     ff8:	8526                	mv	a0,s1
     ffa:	00000097          	auipc	ra,0x0
     ffe:	f58080e7          	jalr	-168(ra) # f52 <putc>
  while(--i >= 0)
    1002:	197d                	addi	s2,s2,-1
    1004:	ff3918e3          	bne	s2,s3,ff4 <printint+0x80>
}
    1008:	70e2                	ld	ra,56(sp)
    100a:	7442                	ld	s0,48(sp)
    100c:	74a2                	ld	s1,40(sp)
    100e:	7902                	ld	s2,32(sp)
    1010:	69e2                	ld	s3,24(sp)
    1012:	6121                	addi	sp,sp,64
    1014:	8082                	ret
    x = -xx;
    1016:	40b005bb          	negw	a1,a1
    neg = 1;
    101a:	4885                	li	a7,1
    x = -xx;
    101c:	bf8d                	j	f8e <printint+0x1a>

000000000000101e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    101e:	7119                	addi	sp,sp,-128
    1020:	fc86                	sd	ra,120(sp)
    1022:	f8a2                	sd	s0,112(sp)
    1024:	f4a6                	sd	s1,104(sp)
    1026:	f0ca                	sd	s2,96(sp)
    1028:	ecce                	sd	s3,88(sp)
    102a:	e8d2                	sd	s4,80(sp)
    102c:	e4d6                	sd	s5,72(sp)
    102e:	e0da                	sd	s6,64(sp)
    1030:	fc5e                	sd	s7,56(sp)
    1032:	f862                	sd	s8,48(sp)
    1034:	f466                	sd	s9,40(sp)
    1036:	f06a                	sd	s10,32(sp)
    1038:	ec6e                	sd	s11,24(sp)
    103a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    103c:	0005c903          	lbu	s2,0(a1)
    1040:	18090f63          	beqz	s2,11de <vprintf+0x1c0>
    1044:	8aaa                	mv	s5,a0
    1046:	8b32                	mv	s6,a2
    1048:	00158493          	addi	s1,a1,1
  state = 0;
    104c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    104e:	02500a13          	li	s4,37
      if(c == 'd'){
    1052:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    1056:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    105a:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    105e:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1062:	00000b97          	auipc	s7,0x0
    1066:	4beb8b93          	addi	s7,s7,1214 # 1520 <digits>
    106a:	a839                	j	1088 <vprintf+0x6a>
        putc(fd, c);
    106c:	85ca                	mv	a1,s2
    106e:	8556                	mv	a0,s5
    1070:	00000097          	auipc	ra,0x0
    1074:	ee2080e7          	jalr	-286(ra) # f52 <putc>
    1078:	a019                	j	107e <vprintf+0x60>
    } else if(state == '%'){
    107a:	01498f63          	beq	s3,s4,1098 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    107e:	0485                	addi	s1,s1,1
    1080:	fff4c903          	lbu	s2,-1(s1)
    1084:	14090d63          	beqz	s2,11de <vprintf+0x1c0>
    c = fmt[i] & 0xff;
    1088:	0009079b          	sext.w	a5,s2
    if(state == 0){
    108c:	fe0997e3          	bnez	s3,107a <vprintf+0x5c>
      if(c == '%'){
    1090:	fd479ee3          	bne	a5,s4,106c <vprintf+0x4e>
        state = '%';
    1094:	89be                	mv	s3,a5
    1096:	b7e5                	j	107e <vprintf+0x60>
      if(c == 'd'){
    1098:	05878063          	beq	a5,s8,10d8 <vprintf+0xba>
      } else if(c == 'l') {
    109c:	05978c63          	beq	a5,s9,10f4 <vprintf+0xd6>
      } else if(c == 'x') {
    10a0:	07a78863          	beq	a5,s10,1110 <vprintf+0xf2>
      } else if(c == 'p') {
    10a4:	09b78463          	beq	a5,s11,112c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    10a8:	07300713          	li	a4,115
    10ac:	0ce78663          	beq	a5,a4,1178 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    10b0:	06300713          	li	a4,99
    10b4:	0ee78e63          	beq	a5,a4,11b0 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    10b8:	11478863          	beq	a5,s4,11c8 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    10bc:	85d2                	mv	a1,s4
    10be:	8556                	mv	a0,s5
    10c0:	00000097          	auipc	ra,0x0
    10c4:	e92080e7          	jalr	-366(ra) # f52 <putc>
        putc(fd, c);
    10c8:	85ca                	mv	a1,s2
    10ca:	8556                	mv	a0,s5
    10cc:	00000097          	auipc	ra,0x0
    10d0:	e86080e7          	jalr	-378(ra) # f52 <putc>
      }
      state = 0;
    10d4:	4981                	li	s3,0
    10d6:	b765                	j	107e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    10d8:	008b0913          	addi	s2,s6,8
    10dc:	4685                	li	a3,1
    10de:	4629                	li	a2,10
    10e0:	000b2583          	lw	a1,0(s6)
    10e4:	8556                	mv	a0,s5
    10e6:	00000097          	auipc	ra,0x0
    10ea:	e8e080e7          	jalr	-370(ra) # f74 <printint>
    10ee:	8b4a                	mv	s6,s2
      state = 0;
    10f0:	4981                	li	s3,0
    10f2:	b771                	j	107e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    10f4:	008b0913          	addi	s2,s6,8
    10f8:	4681                	li	a3,0
    10fa:	4629                	li	a2,10
    10fc:	000b2583          	lw	a1,0(s6)
    1100:	8556                	mv	a0,s5
    1102:	00000097          	auipc	ra,0x0
    1106:	e72080e7          	jalr	-398(ra) # f74 <printint>
    110a:	8b4a                	mv	s6,s2
      state = 0;
    110c:	4981                	li	s3,0
    110e:	bf85                	j	107e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    1110:	008b0913          	addi	s2,s6,8
    1114:	4681                	li	a3,0
    1116:	4641                	li	a2,16
    1118:	000b2583          	lw	a1,0(s6)
    111c:	8556                	mv	a0,s5
    111e:	00000097          	auipc	ra,0x0
    1122:	e56080e7          	jalr	-426(ra) # f74 <printint>
    1126:	8b4a                	mv	s6,s2
      state = 0;
    1128:	4981                	li	s3,0
    112a:	bf91                	j	107e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    112c:	008b0793          	addi	a5,s6,8
    1130:	f8f43423          	sd	a5,-120(s0)
    1134:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    1138:	03000593          	li	a1,48
    113c:	8556                	mv	a0,s5
    113e:	00000097          	auipc	ra,0x0
    1142:	e14080e7          	jalr	-492(ra) # f52 <putc>
  putc(fd, 'x');
    1146:	85ea                	mv	a1,s10
    1148:	8556                	mv	a0,s5
    114a:	00000097          	auipc	ra,0x0
    114e:	e08080e7          	jalr	-504(ra) # f52 <putc>
    1152:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1154:	03c9d793          	srli	a5,s3,0x3c
    1158:	97de                	add	a5,a5,s7
    115a:	0007c583          	lbu	a1,0(a5)
    115e:	8556                	mv	a0,s5
    1160:	00000097          	auipc	ra,0x0
    1164:	df2080e7          	jalr	-526(ra) # f52 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    1168:	0992                	slli	s3,s3,0x4
    116a:	397d                	addiw	s2,s2,-1
    116c:	fe0914e3          	bnez	s2,1154 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    1170:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    1174:	4981                	li	s3,0
    1176:	b721                	j	107e <vprintf+0x60>
        s = va_arg(ap, char*);
    1178:	008b0993          	addi	s3,s6,8
    117c:	000b3903          	ld	s2,0(s6)
        if(s == 0)
    1180:	02090163          	beqz	s2,11a2 <vprintf+0x184>
        while(*s != 0){
    1184:	00094583          	lbu	a1,0(s2)
    1188:	c9a1                	beqz	a1,11d8 <vprintf+0x1ba>
          putc(fd, *s);
    118a:	8556                	mv	a0,s5
    118c:	00000097          	auipc	ra,0x0
    1190:	dc6080e7          	jalr	-570(ra) # f52 <putc>
          s++;
    1194:	0905                	addi	s2,s2,1
        while(*s != 0){
    1196:	00094583          	lbu	a1,0(s2)
    119a:	f9e5                	bnez	a1,118a <vprintf+0x16c>
        s = va_arg(ap, char*);
    119c:	8b4e                	mv	s6,s3
      state = 0;
    119e:	4981                	li	s3,0
    11a0:	bdf9                	j	107e <vprintf+0x60>
          s = "(null)";
    11a2:	00000917          	auipc	s2,0x0
    11a6:	37690913          	addi	s2,s2,886 # 1518 <malloc+0x230>
        while(*s != 0){
    11aa:	02800593          	li	a1,40
    11ae:	bff1                	j	118a <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
    11b0:	008b0913          	addi	s2,s6,8
    11b4:	000b4583          	lbu	a1,0(s6)
    11b8:	8556                	mv	a0,s5
    11ba:	00000097          	auipc	ra,0x0
    11be:	d98080e7          	jalr	-616(ra) # f52 <putc>
    11c2:	8b4a                	mv	s6,s2
      state = 0;
    11c4:	4981                	li	s3,0
    11c6:	bd65                	j	107e <vprintf+0x60>
        putc(fd, c);
    11c8:	85d2                	mv	a1,s4
    11ca:	8556                	mv	a0,s5
    11cc:	00000097          	auipc	ra,0x0
    11d0:	d86080e7          	jalr	-634(ra) # f52 <putc>
      state = 0;
    11d4:	4981                	li	s3,0
    11d6:	b565                	j	107e <vprintf+0x60>
        s = va_arg(ap, char*);
    11d8:	8b4e                	mv	s6,s3
      state = 0;
    11da:	4981                	li	s3,0
    11dc:	b54d                	j	107e <vprintf+0x60>
    }
  }
}
    11de:	70e6                	ld	ra,120(sp)
    11e0:	7446                	ld	s0,112(sp)
    11e2:	74a6                	ld	s1,104(sp)
    11e4:	7906                	ld	s2,96(sp)
    11e6:	69e6                	ld	s3,88(sp)
    11e8:	6a46                	ld	s4,80(sp)
    11ea:	6aa6                	ld	s5,72(sp)
    11ec:	6b06                	ld	s6,64(sp)
    11ee:	7be2                	ld	s7,56(sp)
    11f0:	7c42                	ld	s8,48(sp)
    11f2:	7ca2                	ld	s9,40(sp)
    11f4:	7d02                	ld	s10,32(sp)
    11f6:	6de2                	ld	s11,24(sp)
    11f8:	6109                	addi	sp,sp,128
    11fa:	8082                	ret

00000000000011fc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    11fc:	715d                	addi	sp,sp,-80
    11fe:	ec06                	sd	ra,24(sp)
    1200:	e822                	sd	s0,16(sp)
    1202:	1000                	addi	s0,sp,32
    1204:	e010                	sd	a2,0(s0)
    1206:	e414                	sd	a3,8(s0)
    1208:	e818                	sd	a4,16(s0)
    120a:	ec1c                	sd	a5,24(s0)
    120c:	03043023          	sd	a6,32(s0)
    1210:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1214:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1218:	8622                	mv	a2,s0
    121a:	00000097          	auipc	ra,0x0
    121e:	e04080e7          	jalr	-508(ra) # 101e <vprintf>
}
    1222:	60e2                	ld	ra,24(sp)
    1224:	6442                	ld	s0,16(sp)
    1226:	6161                	addi	sp,sp,80
    1228:	8082                	ret

000000000000122a <printf>:

void
printf(const char *fmt, ...)
{
    122a:	711d                	addi	sp,sp,-96
    122c:	ec06                	sd	ra,24(sp)
    122e:	e822                	sd	s0,16(sp)
    1230:	1000                	addi	s0,sp,32
    1232:	e40c                	sd	a1,8(s0)
    1234:	e810                	sd	a2,16(s0)
    1236:	ec14                	sd	a3,24(s0)
    1238:	f018                	sd	a4,32(s0)
    123a:	f41c                	sd	a5,40(s0)
    123c:	03043823          	sd	a6,48(s0)
    1240:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1244:	00840613          	addi	a2,s0,8
    1248:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    124c:	85aa                	mv	a1,a0
    124e:	4505                	li	a0,1
    1250:	00000097          	auipc	ra,0x0
    1254:	dce080e7          	jalr	-562(ra) # 101e <vprintf>
}
    1258:	60e2                	ld	ra,24(sp)
    125a:	6442                	ld	s0,16(sp)
    125c:	6125                	addi	sp,sp,96
    125e:	8082                	ret

0000000000001260 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    1260:	1141                	addi	sp,sp,-16
    1262:	e422                	sd	s0,8(sp)
    1264:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1266:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    126a:	00000797          	auipc	a5,0x0
    126e:	2de7b783          	ld	a5,734(a5) # 1548 <freep>
    1272:	a805                	j	12a2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1274:	4618                	lw	a4,8(a2)
    1276:	9db9                	addw	a1,a1,a4
    1278:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    127c:	6398                	ld	a4,0(a5)
    127e:	6318                	ld	a4,0(a4)
    1280:	fee53823          	sd	a4,-16(a0)
    1284:	a091                	j	12c8 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1286:	ff852703          	lw	a4,-8(a0)
    128a:	9e39                	addw	a2,a2,a4
    128c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    128e:	ff053703          	ld	a4,-16(a0)
    1292:	e398                	sd	a4,0(a5)
    1294:	a099                	j	12da <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1296:	6398                	ld	a4,0(a5)
    1298:	00e7e463          	bltu	a5,a4,12a0 <free+0x40>
    129c:	00e6ea63          	bltu	a3,a4,12b0 <free+0x50>
{
    12a0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    12a2:	fed7fae3          	bgeu	a5,a3,1296 <free+0x36>
    12a6:	6398                	ld	a4,0(a5)
    12a8:	00e6e463          	bltu	a3,a4,12b0 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    12ac:	fee7eae3          	bltu	a5,a4,12a0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    12b0:	ff852583          	lw	a1,-8(a0)
    12b4:	6390                	ld	a2,0(a5)
    12b6:	02059813          	slli	a6,a1,0x20
    12ba:	01c85713          	srli	a4,a6,0x1c
    12be:	9736                	add	a4,a4,a3
    12c0:	fae60ae3          	beq	a2,a4,1274 <free+0x14>
    bp->s.ptr = p->s.ptr;
    12c4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    12c8:	4790                	lw	a2,8(a5)
    12ca:	02061593          	slli	a1,a2,0x20
    12ce:	01c5d713          	srli	a4,a1,0x1c
    12d2:	973e                	add	a4,a4,a5
    12d4:	fae689e3          	beq	a3,a4,1286 <free+0x26>
  } else
    p->s.ptr = bp;
    12d8:	e394                	sd	a3,0(a5)
  freep = p;
    12da:	00000717          	auipc	a4,0x0
    12de:	26f73723          	sd	a5,622(a4) # 1548 <freep>
}
    12e2:	6422                	ld	s0,8(sp)
    12e4:	0141                	addi	sp,sp,16
    12e6:	8082                	ret

00000000000012e8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    12e8:	7139                	addi	sp,sp,-64
    12ea:	fc06                	sd	ra,56(sp)
    12ec:	f822                	sd	s0,48(sp)
    12ee:	f426                	sd	s1,40(sp)
    12f0:	f04a                	sd	s2,32(sp)
    12f2:	ec4e                	sd	s3,24(sp)
    12f4:	e852                	sd	s4,16(sp)
    12f6:	e456                	sd	s5,8(sp)
    12f8:	e05a                	sd	s6,0(sp)
    12fa:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    12fc:	02051493          	slli	s1,a0,0x20
    1300:	9081                	srli	s1,s1,0x20
    1302:	04bd                	addi	s1,s1,15
    1304:	8091                	srli	s1,s1,0x4
    1306:	0014899b          	addiw	s3,s1,1
    130a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    130c:	00000517          	auipc	a0,0x0
    1310:	23c53503          	ld	a0,572(a0) # 1548 <freep>
    1314:	c515                	beqz	a0,1340 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1316:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1318:	4798                	lw	a4,8(a5)
    131a:	02977f63          	bgeu	a4,s1,1358 <malloc+0x70>
    131e:	8a4e                	mv	s4,s3
    1320:	0009871b          	sext.w	a4,s3
    1324:	6685                	lui	a3,0x1
    1326:	00d77363          	bgeu	a4,a3,132c <malloc+0x44>
    132a:	6a05                	lui	s4,0x1
    132c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1330:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    1334:	00000917          	auipc	s2,0x0
    1338:	21490913          	addi	s2,s2,532 # 1548 <freep>
  if(p == (char*)-1)
    133c:	5afd                	li	s5,-1
    133e:	a895                	j	13b2 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    1340:	00000797          	auipc	a5,0x0
    1344:	47878793          	addi	a5,a5,1144 # 17b8 <base>
    1348:	00000717          	auipc	a4,0x0
    134c:	20f73023          	sd	a5,512(a4) # 1548 <freep>
    1350:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1352:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1356:	b7e1                	j	131e <malloc+0x36>
      if(p->s.size == nunits)
    1358:	02e48c63          	beq	s1,a4,1390 <malloc+0xa8>
        p->s.size -= nunits;
    135c:	4137073b          	subw	a4,a4,s3
    1360:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1362:	02071693          	slli	a3,a4,0x20
    1366:	01c6d713          	srli	a4,a3,0x1c
    136a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    136c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1370:	00000717          	auipc	a4,0x0
    1374:	1ca73c23          	sd	a0,472(a4) # 1548 <freep>
      return (void*)(p + 1);
    1378:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    137c:	70e2                	ld	ra,56(sp)
    137e:	7442                	ld	s0,48(sp)
    1380:	74a2                	ld	s1,40(sp)
    1382:	7902                	ld	s2,32(sp)
    1384:	69e2                	ld	s3,24(sp)
    1386:	6a42                	ld	s4,16(sp)
    1388:	6aa2                	ld	s5,8(sp)
    138a:	6b02                	ld	s6,0(sp)
    138c:	6121                	addi	sp,sp,64
    138e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    1390:	6398                	ld	a4,0(a5)
    1392:	e118                	sd	a4,0(a0)
    1394:	bff1                	j	1370 <malloc+0x88>
  hp->s.size = nu;
    1396:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    139a:	0541                	addi	a0,a0,16
    139c:	00000097          	auipc	ra,0x0
    13a0:	ec4080e7          	jalr	-316(ra) # 1260 <free>
  return freep;
    13a4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    13a8:	d971                	beqz	a0,137c <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    13aa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    13ac:	4798                	lw	a4,8(a5)
    13ae:	fa9775e3          	bgeu	a4,s1,1358 <malloc+0x70>
    if(p == freep)
    13b2:	00093703          	ld	a4,0(s2)
    13b6:	853e                	mv	a0,a5
    13b8:	fef719e3          	bne	a4,a5,13aa <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    13bc:	8552                	mv	a0,s4
    13be:	00000097          	auipc	ra,0x0
    13c2:	b64080e7          	jalr	-1180(ra) # f22 <sbrk>
  if(p == (char*)-1)
    13c6:	fd5518e3          	bne	a0,s5,1396 <malloc+0xae>
        return 0;
    13ca:	4501                	li	a0,0
    13cc:	bf45                	j	137c <malloc+0x94>
