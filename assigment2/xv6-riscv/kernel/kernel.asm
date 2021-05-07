
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	18010113          	addi	sp,sp,384 # 8000a180 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	0000a717          	auipc	a4,0xa
    80000056:	fee70713          	addi	a4,a4,-18 # 8000a040 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00007797          	auipc	a5,0x7
    80000068:	0cc78793          	addi	a5,a5,204 # 80007130 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffbb7ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	0de78793          	addi	a5,a5,222 # 8000118c <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  timerinit();
    800000d8:	00000097          	auipc	ra,0x0
    800000dc:	f44080e7          	jalr	-188(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000e0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e8:	30200073          	mret
}
    800000ec:	60a2                	ld	ra,8(sp)
    800000ee:	6402                	ld	s0,0(sp)
    800000f0:	0141                	addi	sp,sp,16
    800000f2:	8082                	ret

00000000800000f4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000f4:	715d                	addi	sp,sp,-80
    800000f6:	e486                	sd	ra,72(sp)
    800000f8:	e0a2                	sd	s0,64(sp)
    800000fa:	fc26                	sd	s1,56(sp)
    800000fc:	f84a                	sd	s2,48(sp)
    800000fe:	f44e                	sd	s3,40(sp)
    80000100:	f052                	sd	s4,32(sp)
    80000102:	ec56                	sd	s5,24(sp)
    80000104:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000106:	04c05663          	blez	a2,80000152 <consolewrite+0x5e>
    8000010a:	8a2a                	mv	s4,a0
    8000010c:	84ae                	mv	s1,a1
    8000010e:	89b2                	mv	s3,a2
    80000110:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000112:	5afd                	li	s5,-1
    80000114:	4685                	li	a3,1
    80000116:	8626                	mv	a2,s1
    80000118:	85d2                	mv	a1,s4
    8000011a:	fbf40513          	addi	a0,s0,-65
    8000011e:	00003097          	auipc	ra,0x3
    80000122:	b7c080e7          	jalr	-1156(ra) # 80002c9a <either_copyin>
    80000126:	01550c63          	beq	a0,s5,8000013e <consolewrite+0x4a>
      break;
    uartputc(c);
    8000012a:	fbf44503          	lbu	a0,-65(s0)
    8000012e:	00000097          	auipc	ra,0x0
    80000132:	77e080e7          	jalr	1918(ra) # 800008ac <uartputc>
  for(i = 0; i < n; i++){
    80000136:	2905                	addiw	s2,s2,1
    80000138:	0485                	addi	s1,s1,1
    8000013a:	fd299de3          	bne	s3,s2,80000114 <consolewrite+0x20>
  }

  return i;
}
    8000013e:	854a                	mv	a0,s2
    80000140:	60a6                	ld	ra,72(sp)
    80000142:	6406                	ld	s0,64(sp)
    80000144:	74e2                	ld	s1,56(sp)
    80000146:	7942                	ld	s2,48(sp)
    80000148:	79a2                	ld	s3,40(sp)
    8000014a:	7a02                	ld	s4,32(sp)
    8000014c:	6ae2                	ld	s5,24(sp)
    8000014e:	6161                	addi	sp,sp,80
    80000150:	8082                	ret
  for(i = 0; i < n; i++){
    80000152:	4901                	li	s2,0
    80000154:	b7ed                	j	8000013e <consolewrite+0x4a>

0000000080000156 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000156:	7159                	addi	sp,sp,-112
    80000158:	f486                	sd	ra,104(sp)
    8000015a:	f0a2                	sd	s0,96(sp)
    8000015c:	eca6                	sd	s1,88(sp)
    8000015e:	e8ca                	sd	s2,80(sp)
    80000160:	e4ce                	sd	s3,72(sp)
    80000162:	e0d2                	sd	s4,64(sp)
    80000164:	fc56                	sd	s5,56(sp)
    80000166:	f85a                	sd	s6,48(sp)
    80000168:	f45e                	sd	s7,40(sp)
    8000016a:	f062                	sd	s8,32(sp)
    8000016c:	ec66                	sd	s9,24(sp)
    8000016e:	e86a                	sd	s10,16(sp)
    80000170:	1880                	addi	s0,sp,112
    80000172:	8b2a                	mv	s6,a0
    80000174:	8aae                	mv	s5,a1
    80000176:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000178:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000017c:	00012517          	auipc	a0,0x12
    80000180:	00450513          	addi	a0,a0,4 # 80012180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	a84080e7          	jalr	-1404(ra) # 80000c08 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00012497          	auipc	s1,0x12
    80000190:	ff448493          	addi	s1,s1,-12 # 80012180 <cons>
      if(myproc()->killed==1){
    80000194:	4905                	li	s2,1
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000196:	00012997          	auipc	s3,0x12
    8000019a:	08298993          	addi	s3,s3,130 # 80012218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    8000019e:	4c11                	li	s8,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001a0:	5cfd                	li	s9,-1
  while(n > 0){
    800001a2:	07405a63          	blez	s4,80000216 <consoleread+0xc0>
    while(cons.r == cons.w){
    800001a6:	0984a783          	lw	a5,152(s1)
    800001aa:	09c4a703          	lw	a4,156(s1)
    800001ae:	02f71563          	bne	a4,a5,800001d8 <consoleread+0x82>
      if(myproc()->killed==1){
    800001b2:	00002097          	auipc	ra,0x2
    800001b6:	bcc080e7          	jalr	-1076(ra) # 80001d7e <myproc>
    800001ba:	4d5c                	lw	a5,28(a0)
    800001bc:	07278863          	beq	a5,s2,8000022c <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001c0:	85a6                	mv	a1,s1
    800001c2:	854e                	mv	a0,s3
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	530080e7          	jalr	1328(ra) # 800026f4 <sleep>
    while(cons.r == cons.w){
    800001cc:	0984a783          	lw	a5,152(s1)
    800001d0:	09c4a703          	lw	a4,156(s1)
    800001d4:	fcf70fe3          	beq	a4,a5,800001b2 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001d8:	0017871b          	addiw	a4,a5,1
    800001dc:	08e4ac23          	sw	a4,152(s1)
    800001e0:	07f7f713          	andi	a4,a5,127
    800001e4:	9726                	add	a4,a4,s1
    800001e6:	01874703          	lbu	a4,24(a4)
    800001ea:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800001ee:	078d0663          	beq	s10,s8,8000025a <consoleread+0x104>
    cbuf = c;
    800001f2:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001f6:	86ca                	mv	a3,s2
    800001f8:	f9f40613          	addi	a2,s0,-97
    800001fc:	85d6                	mv	a1,s5
    800001fe:	855a                	mv	a0,s6
    80000200:	00003097          	auipc	ra,0x3
    80000204:	a44080e7          	jalr	-1468(ra) # 80002c44 <either_copyout>
    80000208:	01950763          	beq	a0,s9,80000216 <consoleread+0xc0>
      break;

    dst++;
    8000020c:	0a85                	addi	s5,s5,1
    --n;
    8000020e:	3a7d                	addiw	s4,s4,-1

    if(c == '\n'){
    80000210:	47a9                	li	a5,10
    80000212:	f8fd18e3          	bne	s10,a5,800001a2 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000216:	00012517          	auipc	a0,0x12
    8000021a:	f6a50513          	addi	a0,a0,-150 # 80012180 <cons>
    8000021e:	00001097          	auipc	ra,0x1
    80000222:	ac0080e7          	jalr	-1344(ra) # 80000cde <release>

  return target - n;
    80000226:	414b853b          	subw	a0,s7,s4
    8000022a:	a811                	j	8000023e <consoleread+0xe8>
        release(&cons.lock);
    8000022c:	00012517          	auipc	a0,0x12
    80000230:	f5450513          	addi	a0,a0,-172 # 80012180 <cons>
    80000234:	00001097          	auipc	ra,0x1
    80000238:	aaa080e7          	jalr	-1366(ra) # 80000cde <release>
        return -1;
    8000023c:	557d                	li	a0,-1
}
    8000023e:	70a6                	ld	ra,104(sp)
    80000240:	7406                	ld	s0,96(sp)
    80000242:	64e6                	ld	s1,88(sp)
    80000244:	6946                	ld	s2,80(sp)
    80000246:	69a6                	ld	s3,72(sp)
    80000248:	6a06                	ld	s4,64(sp)
    8000024a:	7ae2                	ld	s5,56(sp)
    8000024c:	7b42                	ld	s6,48(sp)
    8000024e:	7ba2                	ld	s7,40(sp)
    80000250:	7c02                	ld	s8,32(sp)
    80000252:	6ce2                	ld	s9,24(sp)
    80000254:	6d42                	ld	s10,16(sp)
    80000256:	6165                	addi	sp,sp,112
    80000258:	8082                	ret
      if(n < target){
    8000025a:	000a071b          	sext.w	a4,s4
    8000025e:	fb777ce3          	bgeu	a4,s7,80000216 <consoleread+0xc0>
        cons.r--;
    80000262:	00012717          	auipc	a4,0x12
    80000266:	faf72b23          	sw	a5,-74(a4) # 80012218 <cons+0x98>
    8000026a:	b775                	j	80000216 <consoleread+0xc0>

000000008000026c <consputc>:
{
    8000026c:	1141                	addi	sp,sp,-16
    8000026e:	e406                	sd	ra,8(sp)
    80000270:	e022                	sd	s0,0(sp)
    80000272:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000274:	10000793          	li	a5,256
    80000278:	00f50a63          	beq	a0,a5,8000028c <consputc+0x20>
    uartputc_sync(c);
    8000027c:	00000097          	auipc	ra,0x0
    80000280:	55e080e7          	jalr	1374(ra) # 800007da <uartputc_sync>
}
    80000284:	60a2                	ld	ra,8(sp)
    80000286:	6402                	ld	s0,0(sp)
    80000288:	0141                	addi	sp,sp,16
    8000028a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000028c:	4521                	li	a0,8
    8000028e:	00000097          	auipc	ra,0x0
    80000292:	54c080e7          	jalr	1356(ra) # 800007da <uartputc_sync>
    80000296:	02000513          	li	a0,32
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	540080e7          	jalr	1344(ra) # 800007da <uartputc_sync>
    800002a2:	4521                	li	a0,8
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	536080e7          	jalr	1334(ra) # 800007da <uartputc_sync>
    800002ac:	bfe1                	j	80000284 <consputc+0x18>

00000000800002ae <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ae:	1101                	addi	sp,sp,-32
    800002b0:	ec06                	sd	ra,24(sp)
    800002b2:	e822                	sd	s0,16(sp)
    800002b4:	e426                	sd	s1,8(sp)
    800002b6:	e04a                	sd	s2,0(sp)
    800002b8:	1000                	addi	s0,sp,32
    800002ba:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002bc:	00012517          	auipc	a0,0x12
    800002c0:	ec450513          	addi	a0,a0,-316 # 80012180 <cons>
    800002c4:	00001097          	auipc	ra,0x1
    800002c8:	944080e7          	jalr	-1724(ra) # 80000c08 <acquire>

  switch(c){
    800002cc:	47d5                	li	a5,21
    800002ce:	0af48663          	beq	s1,a5,8000037a <consoleintr+0xcc>
    800002d2:	0297ca63          	blt	a5,s1,80000306 <consoleintr+0x58>
    800002d6:	47a1                	li	a5,8
    800002d8:	0ef48763          	beq	s1,a5,800003c6 <consoleintr+0x118>
    800002dc:	47c1                	li	a5,16
    800002de:	10f49a63          	bne	s1,a5,800003f2 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002e2:	00003097          	auipc	ra,0x3
    800002e6:	a0e080e7          	jalr	-1522(ra) # 80002cf0 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ea:	00012517          	auipc	a0,0x12
    800002ee:	e9650513          	addi	a0,a0,-362 # 80012180 <cons>
    800002f2:	00001097          	auipc	ra,0x1
    800002f6:	9ec080e7          	jalr	-1556(ra) # 80000cde <release>
}
    800002fa:	60e2                	ld	ra,24(sp)
    800002fc:	6442                	ld	s0,16(sp)
    800002fe:	64a2                	ld	s1,8(sp)
    80000300:	6902                	ld	s2,0(sp)
    80000302:	6105                	addi	sp,sp,32
    80000304:	8082                	ret
  switch(c){
    80000306:	07f00793          	li	a5,127
    8000030a:	0af48e63          	beq	s1,a5,800003c6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    8000030e:	00012717          	auipc	a4,0x12
    80000312:	e7270713          	addi	a4,a4,-398 # 80012180 <cons>
    80000316:	0a072783          	lw	a5,160(a4)
    8000031a:	09872703          	lw	a4,152(a4)
    8000031e:	9f99                	subw	a5,a5,a4
    80000320:	07f00713          	li	a4,127
    80000324:	fcf763e3          	bltu	a4,a5,800002ea <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000328:	47b5                	li	a5,13
    8000032a:	0cf48763          	beq	s1,a5,800003f8 <consoleintr+0x14a>
      consputc(c);
    8000032e:	8526                	mv	a0,s1
    80000330:	00000097          	auipc	ra,0x0
    80000334:	f3c080e7          	jalr	-196(ra) # 8000026c <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000338:	00012797          	auipc	a5,0x12
    8000033c:	e4878793          	addi	a5,a5,-440 # 80012180 <cons>
    80000340:	0a07a703          	lw	a4,160(a5)
    80000344:	0017069b          	addiw	a3,a4,1
    80000348:	0006861b          	sext.w	a2,a3
    8000034c:	0ad7a023          	sw	a3,160(a5)
    80000350:	07f77713          	andi	a4,a4,127
    80000354:	97ba                	add	a5,a5,a4
    80000356:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000035a:	47a9                	li	a5,10
    8000035c:	0cf48563          	beq	s1,a5,80000426 <consoleintr+0x178>
    80000360:	4791                	li	a5,4
    80000362:	0cf48263          	beq	s1,a5,80000426 <consoleintr+0x178>
    80000366:	00012797          	auipc	a5,0x12
    8000036a:	eb27a783          	lw	a5,-334(a5) # 80012218 <cons+0x98>
    8000036e:	0807879b          	addiw	a5,a5,128
    80000372:	f6f61ce3          	bne	a2,a5,800002ea <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000376:	863e                	mv	a2,a5
    80000378:	a07d                	j	80000426 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000037a:	00012717          	auipc	a4,0x12
    8000037e:	e0670713          	addi	a4,a4,-506 # 80012180 <cons>
    80000382:	0a072783          	lw	a5,160(a4)
    80000386:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000038a:	00012497          	auipc	s1,0x12
    8000038e:	df648493          	addi	s1,s1,-522 # 80012180 <cons>
    while(cons.e != cons.w &&
    80000392:	4929                	li	s2,10
    80000394:	f4f70be3          	beq	a4,a5,800002ea <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80000398:	37fd                	addiw	a5,a5,-1
    8000039a:	07f7f713          	andi	a4,a5,127
    8000039e:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003a0:	01874703          	lbu	a4,24(a4)
    800003a4:	f52703e3          	beq	a4,s2,800002ea <consoleintr+0x3c>
      cons.e--;
    800003a8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003ac:	10000513          	li	a0,256
    800003b0:	00000097          	auipc	ra,0x0
    800003b4:	ebc080e7          	jalr	-324(ra) # 8000026c <consputc>
    while(cons.e != cons.w &&
    800003b8:	0a04a783          	lw	a5,160(s1)
    800003bc:	09c4a703          	lw	a4,156(s1)
    800003c0:	fcf71ce3          	bne	a4,a5,80000398 <consoleintr+0xea>
    800003c4:	b71d                	j	800002ea <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003c6:	00012717          	auipc	a4,0x12
    800003ca:	dba70713          	addi	a4,a4,-582 # 80012180 <cons>
    800003ce:	0a072783          	lw	a5,160(a4)
    800003d2:	09c72703          	lw	a4,156(a4)
    800003d6:	f0f70ae3          	beq	a4,a5,800002ea <consoleintr+0x3c>
      cons.e--;
    800003da:	37fd                	addiw	a5,a5,-1
    800003dc:	00012717          	auipc	a4,0x12
    800003e0:	e4f72223          	sw	a5,-444(a4) # 80012220 <cons+0xa0>
      consputc(BACKSPACE);
    800003e4:	10000513          	li	a0,256
    800003e8:	00000097          	auipc	ra,0x0
    800003ec:	e84080e7          	jalr	-380(ra) # 8000026c <consputc>
    800003f0:	bded                	j	800002ea <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003f2:	ee048ce3          	beqz	s1,800002ea <consoleintr+0x3c>
    800003f6:	bf21                	j	8000030e <consoleintr+0x60>
      consputc(c);
    800003f8:	4529                	li	a0,10
    800003fa:	00000097          	auipc	ra,0x0
    800003fe:	e72080e7          	jalr	-398(ra) # 8000026c <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000402:	00012797          	auipc	a5,0x12
    80000406:	d7e78793          	addi	a5,a5,-642 # 80012180 <cons>
    8000040a:	0a07a703          	lw	a4,160(a5)
    8000040e:	0017069b          	addiw	a3,a4,1
    80000412:	0006861b          	sext.w	a2,a3
    80000416:	0ad7a023          	sw	a3,160(a5)
    8000041a:	07f77713          	andi	a4,a4,127
    8000041e:	97ba                	add	a5,a5,a4
    80000420:	4729                	li	a4,10
    80000422:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000426:	00012797          	auipc	a5,0x12
    8000042a:	dec7ab23          	sw	a2,-522(a5) # 8001221c <cons+0x9c>
        wakeup(&cons.r);
    8000042e:	00012517          	auipc	a0,0x12
    80000432:	dea50513          	addi	a0,a0,-534 # 80012218 <cons+0x98>
    80000436:	00002097          	auipc	ra,0x2
    8000043a:	448080e7          	jalr	1096(ra) # 8000287e <wakeup>
    8000043e:	b575                	j	800002ea <consoleintr+0x3c>

0000000080000440 <consoleinit>:

void
consoleinit(void)
{
    80000440:	1141                	addi	sp,sp,-16
    80000442:	e406                	sd	ra,8(sp)
    80000444:	e022                	sd	s0,0(sp)
    80000446:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000448:	00009597          	auipc	a1,0x9
    8000044c:	bd858593          	addi	a1,a1,-1064 # 80009020 <etext+0x20>
    80000450:	00012517          	auipc	a0,0x12
    80000454:	d3050513          	addi	a0,a0,-720 # 80012180 <cons>
    80000458:	00000097          	auipc	ra,0x0
    8000045c:	6de080e7          	jalr	1758(ra) # 80000b36 <initlock>

  uartinit();
    80000460:	00000097          	auipc	ra,0x0
    80000464:	32a080e7          	jalr	810(ra) # 8000078a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000468:	0003f797          	auipc	a5,0x3f
    8000046c:	b0878793          	addi	a5,a5,-1272 # 8003ef70 <devsw>
    80000470:	00000717          	auipc	a4,0x0
    80000474:	ce670713          	addi	a4,a4,-794 # 80000156 <consoleread>
    80000478:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000047a:	00000717          	auipc	a4,0x0
    8000047e:	c7a70713          	addi	a4,a4,-902 # 800000f4 <consolewrite>
    80000482:	ef98                	sd	a4,24(a5)
}
    80000484:	60a2                	ld	ra,8(sp)
    80000486:	6402                	ld	s0,0(sp)
    80000488:	0141                	addi	sp,sp,16
    8000048a:	8082                	ret

000000008000048c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000048c:	7179                	addi	sp,sp,-48
    8000048e:	f406                	sd	ra,40(sp)
    80000490:	f022                	sd	s0,32(sp)
    80000492:	ec26                	sd	s1,24(sp)
    80000494:	e84a                	sd	s2,16(sp)
    80000496:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80000498:	c219                	beqz	a2,8000049e <printint+0x12>
    8000049a:	08054663          	bltz	a0,80000526 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    8000049e:	2501                	sext.w	a0,a0
    800004a0:	4881                	li	a7,0
    800004a2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004a6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004a8:	2581                	sext.w	a1,a1
    800004aa:	00009617          	auipc	a2,0x9
    800004ae:	ba660613          	addi	a2,a2,-1114 # 80009050 <digits>
    800004b2:	883a                	mv	a6,a4
    800004b4:	2705                	addiw	a4,a4,1
    800004b6:	02b577bb          	remuw	a5,a0,a1
    800004ba:	1782                	slli	a5,a5,0x20
    800004bc:	9381                	srli	a5,a5,0x20
    800004be:	97b2                	add	a5,a5,a2
    800004c0:	0007c783          	lbu	a5,0(a5)
    800004c4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004c8:	0005079b          	sext.w	a5,a0
    800004cc:	02b5553b          	divuw	a0,a0,a1
    800004d0:	0685                	addi	a3,a3,1
    800004d2:	feb7f0e3          	bgeu	a5,a1,800004b2 <printint+0x26>

  if(sign)
    800004d6:	00088b63          	beqz	a7,800004ec <printint+0x60>
    buf[i++] = '-';
    800004da:	fe040793          	addi	a5,s0,-32
    800004de:	973e                	add	a4,a4,a5
    800004e0:	02d00793          	li	a5,45
    800004e4:	fef70823          	sb	a5,-16(a4)
    800004e8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004ec:	02e05763          	blez	a4,8000051a <printint+0x8e>
    800004f0:	fd040793          	addi	a5,s0,-48
    800004f4:	00e784b3          	add	s1,a5,a4
    800004f8:	fff78913          	addi	s2,a5,-1
    800004fc:	993a                	add	s2,s2,a4
    800004fe:	377d                	addiw	a4,a4,-1
    80000500:	1702                	slli	a4,a4,0x20
    80000502:	9301                	srli	a4,a4,0x20
    80000504:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000508:	fff4c503          	lbu	a0,-1(s1)
    8000050c:	00000097          	auipc	ra,0x0
    80000510:	d60080e7          	jalr	-672(ra) # 8000026c <consputc>
  while(--i >= 0)
    80000514:	14fd                	addi	s1,s1,-1
    80000516:	ff2499e3          	bne	s1,s2,80000508 <printint+0x7c>
}
    8000051a:	70a2                	ld	ra,40(sp)
    8000051c:	7402                	ld	s0,32(sp)
    8000051e:	64e2                	ld	s1,24(sp)
    80000520:	6942                	ld	s2,16(sp)
    80000522:	6145                	addi	sp,sp,48
    80000524:	8082                	ret
    x = -xx;
    80000526:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000052a:	4885                	li	a7,1
    x = -xx;
    8000052c:	bf9d                	j	800004a2 <printint+0x16>

000000008000052e <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000052e:	1101                	addi	sp,sp,-32
    80000530:	ec06                	sd	ra,24(sp)
    80000532:	e822                	sd	s0,16(sp)
    80000534:	e426                	sd	s1,8(sp)
    80000536:	1000                	addi	s0,sp,32
    80000538:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000053a:	00012797          	auipc	a5,0x12
    8000053e:	d007a323          	sw	zero,-762(a5) # 80012240 <pr+0x18>
  printf("panic: ");
    80000542:	00009517          	auipc	a0,0x9
    80000546:	ae650513          	addi	a0,a0,-1306 # 80009028 <etext+0x28>
    8000054a:	00000097          	auipc	ra,0x0
    8000054e:	02e080e7          	jalr	46(ra) # 80000578 <printf>
  printf(s);
    80000552:	8526                	mv	a0,s1
    80000554:	00000097          	auipc	ra,0x0
    80000558:	024080e7          	jalr	36(ra) # 80000578 <printf>
  printf("\n");
    8000055c:	00009517          	auipc	a0,0x9
    80000560:	b5c50513          	addi	a0,a0,-1188 # 800090b8 <digits+0x68>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	014080e7          	jalr	20(ra) # 80000578 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000056c:	4785                	li	a5,1
    8000056e:	0000a717          	auipc	a4,0xa
    80000572:	a8f72923          	sw	a5,-1390(a4) # 8000a000 <panicked>
  for(;;)
    80000576:	a001                	j	80000576 <panic+0x48>

0000000080000578 <printf>:
{
    80000578:	7131                	addi	sp,sp,-192
    8000057a:	fc86                	sd	ra,120(sp)
    8000057c:	f8a2                	sd	s0,112(sp)
    8000057e:	f4a6                	sd	s1,104(sp)
    80000580:	f0ca                	sd	s2,96(sp)
    80000582:	ecce                	sd	s3,88(sp)
    80000584:	e8d2                	sd	s4,80(sp)
    80000586:	e4d6                	sd	s5,72(sp)
    80000588:	e0da                	sd	s6,64(sp)
    8000058a:	fc5e                	sd	s7,56(sp)
    8000058c:	f862                	sd	s8,48(sp)
    8000058e:	f466                	sd	s9,40(sp)
    80000590:	f06a                	sd	s10,32(sp)
    80000592:	ec6e                	sd	s11,24(sp)
    80000594:	0100                	addi	s0,sp,128
    80000596:	8a2a                	mv	s4,a0
    80000598:	e40c                	sd	a1,8(s0)
    8000059a:	e810                	sd	a2,16(s0)
    8000059c:	ec14                	sd	a3,24(s0)
    8000059e:	f018                	sd	a4,32(s0)
    800005a0:	f41c                	sd	a5,40(s0)
    800005a2:	03043823          	sd	a6,48(s0)
    800005a6:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005aa:	00012d97          	auipc	s11,0x12
    800005ae:	c96dad83          	lw	s11,-874(s11) # 80012240 <pr+0x18>
  if(locking)
    800005b2:	020d9b63          	bnez	s11,800005e8 <printf+0x70>
  if (fmt == 0)
    800005b6:	040a0263          	beqz	s4,800005fa <printf+0x82>
  va_start(ap, fmt);
    800005ba:	00840793          	addi	a5,s0,8
    800005be:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005c2:	000a4503          	lbu	a0,0(s4)
    800005c6:	14050f63          	beqz	a0,80000724 <printf+0x1ac>
    800005ca:	4981                	li	s3,0
    if(c != '%'){
    800005cc:	02500a93          	li	s5,37
    switch(c){
    800005d0:	07000b93          	li	s7,112
  consputc('x');
    800005d4:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005d6:	00009b17          	auipc	s6,0x9
    800005da:	a7ab0b13          	addi	s6,s6,-1414 # 80009050 <digits>
    switch(c){
    800005de:	07300c93          	li	s9,115
    800005e2:	06400c13          	li	s8,100
    800005e6:	a82d                	j	80000620 <printf+0xa8>
    acquire(&pr.lock);
    800005e8:	00012517          	auipc	a0,0x12
    800005ec:	c4050513          	addi	a0,a0,-960 # 80012228 <pr>
    800005f0:	00000097          	auipc	ra,0x0
    800005f4:	618080e7          	jalr	1560(ra) # 80000c08 <acquire>
    800005f8:	bf7d                	j	800005b6 <printf+0x3e>
    panic("null fmt");
    800005fa:	00009517          	auipc	a0,0x9
    800005fe:	a3e50513          	addi	a0,a0,-1474 # 80009038 <etext+0x38>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	f2c080e7          	jalr	-212(ra) # 8000052e <panic>
      consputc(c);
    8000060a:	00000097          	auipc	ra,0x0
    8000060e:	c62080e7          	jalr	-926(ra) # 8000026c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000612:	2985                	addiw	s3,s3,1
    80000614:	013a07b3          	add	a5,s4,s3
    80000618:	0007c503          	lbu	a0,0(a5)
    8000061c:	10050463          	beqz	a0,80000724 <printf+0x1ac>
    if(c != '%'){
    80000620:	ff5515e3          	bne	a0,s5,8000060a <printf+0x92>
    c = fmt[++i] & 0xff;
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c783          	lbu	a5,0(a5)
    8000062e:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000632:	cbed                	beqz	a5,80000724 <printf+0x1ac>
    switch(c){
    80000634:	05778a63          	beq	a5,s7,80000688 <printf+0x110>
    80000638:	02fbf663          	bgeu	s7,a5,80000664 <printf+0xec>
    8000063c:	09978863          	beq	a5,s9,800006cc <printf+0x154>
    80000640:	07800713          	li	a4,120
    80000644:	0ce79563          	bne	a5,a4,8000070e <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000648:	f8843783          	ld	a5,-120(s0)
    8000064c:	00878713          	addi	a4,a5,8
    80000650:	f8e43423          	sd	a4,-120(s0)
    80000654:	4605                	li	a2,1
    80000656:	85ea                	mv	a1,s10
    80000658:	4388                	lw	a0,0(a5)
    8000065a:	00000097          	auipc	ra,0x0
    8000065e:	e32080e7          	jalr	-462(ra) # 8000048c <printint>
      break;
    80000662:	bf45                	j	80000612 <printf+0x9a>
    switch(c){
    80000664:	09578f63          	beq	a5,s5,80000702 <printf+0x18a>
    80000668:	0b879363          	bne	a5,s8,8000070e <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000066c:	f8843783          	ld	a5,-120(s0)
    80000670:	00878713          	addi	a4,a5,8
    80000674:	f8e43423          	sd	a4,-120(s0)
    80000678:	4605                	li	a2,1
    8000067a:	45a9                	li	a1,10
    8000067c:	4388                	lw	a0,0(a5)
    8000067e:	00000097          	auipc	ra,0x0
    80000682:	e0e080e7          	jalr	-498(ra) # 8000048c <printint>
      break;
    80000686:	b771                	j	80000612 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000688:	f8843783          	ld	a5,-120(s0)
    8000068c:	00878713          	addi	a4,a5,8
    80000690:	f8e43423          	sd	a4,-120(s0)
    80000694:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80000698:	03000513          	li	a0,48
    8000069c:	00000097          	auipc	ra,0x0
    800006a0:	bd0080e7          	jalr	-1072(ra) # 8000026c <consputc>
  consputc('x');
    800006a4:	07800513          	li	a0,120
    800006a8:	00000097          	auipc	ra,0x0
    800006ac:	bc4080e7          	jalr	-1084(ra) # 8000026c <consputc>
    800006b0:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006b2:	03c95793          	srli	a5,s2,0x3c
    800006b6:	97da                	add	a5,a5,s6
    800006b8:	0007c503          	lbu	a0,0(a5)
    800006bc:	00000097          	auipc	ra,0x0
    800006c0:	bb0080e7          	jalr	-1104(ra) # 8000026c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006c4:	0912                	slli	s2,s2,0x4
    800006c6:	34fd                	addiw	s1,s1,-1
    800006c8:	f4ed                	bnez	s1,800006b2 <printf+0x13a>
    800006ca:	b7a1                	j	80000612 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006cc:	f8843783          	ld	a5,-120(s0)
    800006d0:	00878713          	addi	a4,a5,8
    800006d4:	f8e43423          	sd	a4,-120(s0)
    800006d8:	6384                	ld	s1,0(a5)
    800006da:	cc89                	beqz	s1,800006f4 <printf+0x17c>
      for(; *s; s++)
    800006dc:	0004c503          	lbu	a0,0(s1)
    800006e0:	d90d                	beqz	a0,80000612 <printf+0x9a>
        consputc(*s);
    800006e2:	00000097          	auipc	ra,0x0
    800006e6:	b8a080e7          	jalr	-1142(ra) # 8000026c <consputc>
      for(; *s; s++)
    800006ea:	0485                	addi	s1,s1,1
    800006ec:	0004c503          	lbu	a0,0(s1)
    800006f0:	f96d                	bnez	a0,800006e2 <printf+0x16a>
    800006f2:	b705                	j	80000612 <printf+0x9a>
        s = "(null)";
    800006f4:	00009497          	auipc	s1,0x9
    800006f8:	93c48493          	addi	s1,s1,-1732 # 80009030 <etext+0x30>
      for(; *s; s++)
    800006fc:	02800513          	li	a0,40
    80000700:	b7cd                	j	800006e2 <printf+0x16a>
      consputc('%');
    80000702:	8556                	mv	a0,s5
    80000704:	00000097          	auipc	ra,0x0
    80000708:	b68080e7          	jalr	-1176(ra) # 8000026c <consputc>
      break;
    8000070c:	b719                	j	80000612 <printf+0x9a>
      consputc('%');
    8000070e:	8556                	mv	a0,s5
    80000710:	00000097          	auipc	ra,0x0
    80000714:	b5c080e7          	jalr	-1188(ra) # 8000026c <consputc>
      consputc(c);
    80000718:	8526                	mv	a0,s1
    8000071a:	00000097          	auipc	ra,0x0
    8000071e:	b52080e7          	jalr	-1198(ra) # 8000026c <consputc>
      break;
    80000722:	bdc5                	j	80000612 <printf+0x9a>
  if(locking)
    80000724:	020d9163          	bnez	s11,80000746 <printf+0x1ce>
}
    80000728:	70e6                	ld	ra,120(sp)
    8000072a:	7446                	ld	s0,112(sp)
    8000072c:	74a6                	ld	s1,104(sp)
    8000072e:	7906                	ld	s2,96(sp)
    80000730:	69e6                	ld	s3,88(sp)
    80000732:	6a46                	ld	s4,80(sp)
    80000734:	6aa6                	ld	s5,72(sp)
    80000736:	6b06                	ld	s6,64(sp)
    80000738:	7be2                	ld	s7,56(sp)
    8000073a:	7c42                	ld	s8,48(sp)
    8000073c:	7ca2                	ld	s9,40(sp)
    8000073e:	7d02                	ld	s10,32(sp)
    80000740:	6de2                	ld	s11,24(sp)
    80000742:	6129                	addi	sp,sp,192
    80000744:	8082                	ret
    release(&pr.lock);
    80000746:	00012517          	auipc	a0,0x12
    8000074a:	ae250513          	addi	a0,a0,-1310 # 80012228 <pr>
    8000074e:	00000097          	auipc	ra,0x0
    80000752:	590080e7          	jalr	1424(ra) # 80000cde <release>
}
    80000756:	bfc9                	j	80000728 <printf+0x1b0>

0000000080000758 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000758:	1101                	addi	sp,sp,-32
    8000075a:	ec06                	sd	ra,24(sp)
    8000075c:	e822                	sd	s0,16(sp)
    8000075e:	e426                	sd	s1,8(sp)
    80000760:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000762:	00012497          	auipc	s1,0x12
    80000766:	ac648493          	addi	s1,s1,-1338 # 80012228 <pr>
    8000076a:	00009597          	auipc	a1,0x9
    8000076e:	8de58593          	addi	a1,a1,-1826 # 80009048 <etext+0x48>
    80000772:	8526                	mv	a0,s1
    80000774:	00000097          	auipc	ra,0x0
    80000778:	3c2080e7          	jalr	962(ra) # 80000b36 <initlock>
  pr.locking = 1;
    8000077c:	4785                	li	a5,1
    8000077e:	cc9c                	sw	a5,24(s1)
}
    80000780:	60e2                	ld	ra,24(sp)
    80000782:	6442                	ld	s0,16(sp)
    80000784:	64a2                	ld	s1,8(sp)
    80000786:	6105                	addi	sp,sp,32
    80000788:	8082                	ret

000000008000078a <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000078a:	1141                	addi	sp,sp,-16
    8000078c:	e406                	sd	ra,8(sp)
    8000078e:	e022                	sd	s0,0(sp)
    80000790:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000792:	100007b7          	lui	a5,0x10000
    80000796:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000079a:	f8000713          	li	a4,-128
    8000079e:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007a2:	470d                	li	a4,3
    800007a4:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007a8:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007ac:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007b0:	469d                	li	a3,7
    800007b2:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007b6:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ba:	00009597          	auipc	a1,0x9
    800007be:	8ae58593          	addi	a1,a1,-1874 # 80009068 <digits+0x18>
    800007c2:	00012517          	auipc	a0,0x12
    800007c6:	a8650513          	addi	a0,a0,-1402 # 80012248 <uart_tx_lock>
    800007ca:	00000097          	auipc	ra,0x0
    800007ce:	36c080e7          	jalr	876(ra) # 80000b36 <initlock>
}
    800007d2:	60a2                	ld	ra,8(sp)
    800007d4:	6402                	ld	s0,0(sp)
    800007d6:	0141                	addi	sp,sp,16
    800007d8:	8082                	ret

00000000800007da <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007da:	1101                	addi	sp,sp,-32
    800007dc:	ec06                	sd	ra,24(sp)
    800007de:	e822                	sd	s0,16(sp)
    800007e0:	e426                	sd	s1,8(sp)
    800007e2:	1000                	addi	s0,sp,32
    800007e4:	84aa                	mv	s1,a0
  push_off();
    800007e6:	00000097          	auipc	ra,0x0
    800007ea:	3d6080e7          	jalr	982(ra) # 80000bbc <push_off>

  if(panicked){
    800007ee:	0000a797          	auipc	a5,0xa
    800007f2:	8127a783          	lw	a5,-2030(a5) # 8000a000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007f6:	10000737          	lui	a4,0x10000
  if(panicked){
    800007fa:	c391                	beqz	a5,800007fe <uartputc_sync+0x24>
    for(;;)
    800007fc:	a001                	j	800007fc <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007fe:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000802:	0207f793          	andi	a5,a5,32
    80000806:	dfe5                	beqz	a5,800007fe <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000808:	0ff4f513          	andi	a0,s1,255
    8000080c:	100007b7          	lui	a5,0x10000
    80000810:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000814:	00000097          	auipc	ra,0x0
    80000818:	46a080e7          	jalr	1130(ra) # 80000c7e <pop_off>
}
    8000081c:	60e2                	ld	ra,24(sp)
    8000081e:	6442                	ld	s0,16(sp)
    80000820:	64a2                	ld	s1,8(sp)
    80000822:	6105                	addi	sp,sp,32
    80000824:	8082                	ret

0000000080000826 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000826:	00009797          	auipc	a5,0x9
    8000082a:	7e27b783          	ld	a5,2018(a5) # 8000a008 <uart_tx_r>
    8000082e:	00009717          	auipc	a4,0x9
    80000832:	7e273703          	ld	a4,2018(a4) # 8000a010 <uart_tx_w>
    80000836:	06f70a63          	beq	a4,a5,800008aa <uartstart+0x84>
{
    8000083a:	7139                	addi	sp,sp,-64
    8000083c:	fc06                	sd	ra,56(sp)
    8000083e:	f822                	sd	s0,48(sp)
    80000840:	f426                	sd	s1,40(sp)
    80000842:	f04a                	sd	s2,32(sp)
    80000844:	ec4e                	sd	s3,24(sp)
    80000846:	e852                	sd	s4,16(sp)
    80000848:	e456                	sd	s5,8(sp)
    8000084a:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000084c:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000850:	00012a17          	auipc	s4,0x12
    80000854:	9f8a0a13          	addi	s4,s4,-1544 # 80012248 <uart_tx_lock>
    uart_tx_r += 1;
    80000858:	00009497          	auipc	s1,0x9
    8000085c:	7b048493          	addi	s1,s1,1968 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000860:	00009997          	auipc	s3,0x9
    80000864:	7b098993          	addi	s3,s3,1968 # 8000a010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000868:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000086c:	02077713          	andi	a4,a4,32
    80000870:	c705                	beqz	a4,80000898 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000872:	01f7f713          	andi	a4,a5,31
    80000876:	9752                	add	a4,a4,s4
    80000878:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000087c:	0785                	addi	a5,a5,1
    8000087e:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000880:	8526                	mv	a0,s1
    80000882:	00002097          	auipc	ra,0x2
    80000886:	ffc080e7          	jalr	-4(ra) # 8000287e <wakeup>
    
    WriteReg(THR, c);
    8000088a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000088e:	609c                	ld	a5,0(s1)
    80000890:	0009b703          	ld	a4,0(s3)
    80000894:	fcf71ae3          	bne	a4,a5,80000868 <uartstart+0x42>
  }
}
    80000898:	70e2                	ld	ra,56(sp)
    8000089a:	7442                	ld	s0,48(sp)
    8000089c:	74a2                	ld	s1,40(sp)
    8000089e:	7902                	ld	s2,32(sp)
    800008a0:	69e2                	ld	s3,24(sp)
    800008a2:	6a42                	ld	s4,16(sp)
    800008a4:	6aa2                	ld	s5,8(sp)
    800008a6:	6121                	addi	sp,sp,64
    800008a8:	8082                	ret
    800008aa:	8082                	ret

00000000800008ac <uartputc>:
{
    800008ac:	7179                	addi	sp,sp,-48
    800008ae:	f406                	sd	ra,40(sp)
    800008b0:	f022                	sd	s0,32(sp)
    800008b2:	ec26                	sd	s1,24(sp)
    800008b4:	e84a                	sd	s2,16(sp)
    800008b6:	e44e                	sd	s3,8(sp)
    800008b8:	e052                	sd	s4,0(sp)
    800008ba:	1800                	addi	s0,sp,48
    800008bc:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008be:	00012517          	auipc	a0,0x12
    800008c2:	98a50513          	addi	a0,a0,-1654 # 80012248 <uart_tx_lock>
    800008c6:	00000097          	auipc	ra,0x0
    800008ca:	342080e7          	jalr	834(ra) # 80000c08 <acquire>
  if(panicked){
    800008ce:	00009797          	auipc	a5,0x9
    800008d2:	7327a783          	lw	a5,1842(a5) # 8000a000 <panicked>
    800008d6:	c391                	beqz	a5,800008da <uartputc+0x2e>
    for(;;)
    800008d8:	a001                	j	800008d8 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008da:	00009717          	auipc	a4,0x9
    800008de:	73673703          	ld	a4,1846(a4) # 8000a010 <uart_tx_w>
    800008e2:	00009797          	auipc	a5,0x9
    800008e6:	7267b783          	ld	a5,1830(a5) # 8000a008 <uart_tx_r>
    800008ea:	02078793          	addi	a5,a5,32
    800008ee:	02e79b63          	bne	a5,a4,80000924 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008f2:	00012997          	auipc	s3,0x12
    800008f6:	95698993          	addi	s3,s3,-1706 # 80012248 <uart_tx_lock>
    800008fa:	00009497          	auipc	s1,0x9
    800008fe:	70e48493          	addi	s1,s1,1806 # 8000a008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000902:	00009917          	auipc	s2,0x9
    80000906:	70e90913          	addi	s2,s2,1806 # 8000a010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000090a:	85ce                	mv	a1,s3
    8000090c:	8526                	mv	a0,s1
    8000090e:	00002097          	auipc	ra,0x2
    80000912:	de6080e7          	jalr	-538(ra) # 800026f4 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000916:	00093703          	ld	a4,0(s2)
    8000091a:	609c                	ld	a5,0(s1)
    8000091c:	02078793          	addi	a5,a5,32
    80000920:	fee785e3          	beq	a5,a4,8000090a <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000924:	00012497          	auipc	s1,0x12
    80000928:	92448493          	addi	s1,s1,-1756 # 80012248 <uart_tx_lock>
    8000092c:	01f77793          	andi	a5,a4,31
    80000930:	97a6                	add	a5,a5,s1
    80000932:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000936:	0705                	addi	a4,a4,1
    80000938:	00009797          	auipc	a5,0x9
    8000093c:	6ce7bc23          	sd	a4,1752(a5) # 8000a010 <uart_tx_w>
      uartstart();
    80000940:	00000097          	auipc	ra,0x0
    80000944:	ee6080e7          	jalr	-282(ra) # 80000826 <uartstart>
      release(&uart_tx_lock);
    80000948:	8526                	mv	a0,s1
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	394080e7          	jalr	916(ra) # 80000cde <release>
}
    80000952:	70a2                	ld	ra,40(sp)
    80000954:	7402                	ld	s0,32(sp)
    80000956:	64e2                	ld	s1,24(sp)
    80000958:	6942                	ld	s2,16(sp)
    8000095a:	69a2                	ld	s3,8(sp)
    8000095c:	6a02                	ld	s4,0(sp)
    8000095e:	6145                	addi	sp,sp,48
    80000960:	8082                	ret

0000000080000962 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000962:	1141                	addi	sp,sp,-16
    80000964:	e422                	sd	s0,8(sp)
    80000966:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000968:	100007b7          	lui	a5,0x10000
    8000096c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000970:	8b85                	andi	a5,a5,1
    80000972:	cb91                	beqz	a5,80000986 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000974:	100007b7          	lui	a5,0x10000
    80000978:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    8000097c:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    80000980:	6422                	ld	s0,8(sp)
    80000982:	0141                	addi	sp,sp,16
    80000984:	8082                	ret
    return -1;
    80000986:	557d                	li	a0,-1
    80000988:	bfe5                	j	80000980 <uartgetc+0x1e>

000000008000098a <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    8000098a:	1101                	addi	sp,sp,-32
    8000098c:	ec06                	sd	ra,24(sp)
    8000098e:	e822                	sd	s0,16(sp)
    80000990:	e426                	sd	s1,8(sp)
    80000992:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000994:	54fd                	li	s1,-1
    80000996:	a029                	j	800009a0 <uartintr+0x16>
      break;
    consoleintr(c);
    80000998:	00000097          	auipc	ra,0x0
    8000099c:	916080e7          	jalr	-1770(ra) # 800002ae <consoleintr>
    int c = uartgetc();
    800009a0:	00000097          	auipc	ra,0x0
    800009a4:	fc2080e7          	jalr	-62(ra) # 80000962 <uartgetc>
    if(c == -1)
    800009a8:	fe9518e3          	bne	a0,s1,80000998 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ac:	00012497          	auipc	s1,0x12
    800009b0:	89c48493          	addi	s1,s1,-1892 # 80012248 <uart_tx_lock>
    800009b4:	8526                	mv	a0,s1
    800009b6:	00000097          	auipc	ra,0x0
    800009ba:	252080e7          	jalr	594(ra) # 80000c08 <acquire>
  uartstart();
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	e68080e7          	jalr	-408(ra) # 80000826 <uartstart>
  release(&uart_tx_lock);
    800009c6:	8526                	mv	a0,s1
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	316080e7          	jalr	790(ra) # 80000cde <release>
}
    800009d0:	60e2                	ld	ra,24(sp)
    800009d2:	6442                	ld	s0,16(sp)
    800009d4:	64a2                	ld	s1,8(sp)
    800009d6:	6105                	addi	sp,sp,32
    800009d8:	8082                	ret

00000000800009da <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009da:	1101                	addi	sp,sp,-32
    800009dc:	ec06                	sd	ra,24(sp)
    800009de:	e822                	sd	s0,16(sp)
    800009e0:	e426                	sd	s1,8(sp)
    800009e2:	e04a                	sd	s2,0(sp)
    800009e4:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009e6:	03451793          	slli	a5,a0,0x34
    800009ea:	ebb9                	bnez	a5,80000a40 <kfree+0x66>
    800009ec:	84aa                	mv	s1,a0
    800009ee:	00042797          	auipc	a5,0x42
    800009f2:	61278793          	addi	a5,a5,1554 # 80043000 <end>
    800009f6:	04f56563          	bltu	a0,a5,80000a40 <kfree+0x66>
    800009fa:	47c5                	li	a5,17
    800009fc:	07ee                	slli	a5,a5,0x1b
    800009fe:	04f57163          	bgeu	a0,a5,80000a40 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a02:	6605                	lui	a2,0x1
    80000a04:	4585                	li	a1,1
    80000a06:	00000097          	auipc	ra,0x0
    80000a0a:	5d8080e7          	jalr	1496(ra) # 80000fde <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a0e:	00012917          	auipc	s2,0x12
    80000a12:	87290913          	addi	s2,s2,-1934 # 80012280 <kmem>
    80000a16:	854a                	mv	a0,s2
    80000a18:	00000097          	auipc	ra,0x0
    80000a1c:	1f0080e7          	jalr	496(ra) # 80000c08 <acquire>
  r->next = kmem.freelist;
    80000a20:	01893783          	ld	a5,24(s2)
    80000a24:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a26:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a2a:	854a                	mv	a0,s2
    80000a2c:	00000097          	auipc	ra,0x0
    80000a30:	2b2080e7          	jalr	690(ra) # 80000cde <release>
}
    80000a34:	60e2                	ld	ra,24(sp)
    80000a36:	6442                	ld	s0,16(sp)
    80000a38:	64a2                	ld	s1,8(sp)
    80000a3a:	6902                	ld	s2,0(sp)
    80000a3c:	6105                	addi	sp,sp,32
    80000a3e:	8082                	ret
    panic("kfree");
    80000a40:	00008517          	auipc	a0,0x8
    80000a44:	63050513          	addi	a0,a0,1584 # 80009070 <digits+0x20>
    80000a48:	00000097          	auipc	ra,0x0
    80000a4c:	ae6080e7          	jalr	-1306(ra) # 8000052e <panic>

0000000080000a50 <freerange>:
{
    80000a50:	7179                	addi	sp,sp,-48
    80000a52:	f406                	sd	ra,40(sp)
    80000a54:	f022                	sd	s0,32(sp)
    80000a56:	ec26                	sd	s1,24(sp)
    80000a58:	e84a                	sd	s2,16(sp)
    80000a5a:	e44e                	sd	s3,8(sp)
    80000a5c:	e052                	sd	s4,0(sp)
    80000a5e:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a60:	6785                	lui	a5,0x1
    80000a62:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a66:	94aa                	add	s1,s1,a0
    80000a68:	757d                	lui	a0,0xfffff
    80000a6a:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a6c:	94be                	add	s1,s1,a5
    80000a6e:	0095ee63          	bltu	a1,s1,80000a8a <freerange+0x3a>
    80000a72:	892e                	mv	s2,a1
    kfree(p);
    80000a74:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a76:	6985                	lui	s3,0x1
    kfree(p);
    80000a78:	01448533          	add	a0,s1,s4
    80000a7c:	00000097          	auipc	ra,0x0
    80000a80:	f5e080e7          	jalr	-162(ra) # 800009da <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a84:	94ce                	add	s1,s1,s3
    80000a86:	fe9979e3          	bgeu	s2,s1,80000a78 <freerange+0x28>
}
    80000a8a:	70a2                	ld	ra,40(sp)
    80000a8c:	7402                	ld	s0,32(sp)
    80000a8e:	64e2                	ld	s1,24(sp)
    80000a90:	6942                	ld	s2,16(sp)
    80000a92:	69a2                	ld	s3,8(sp)
    80000a94:	6a02                	ld	s4,0(sp)
    80000a96:	6145                	addi	sp,sp,48
    80000a98:	8082                	ret

0000000080000a9a <kinit>:
{
    80000a9a:	1141                	addi	sp,sp,-16
    80000a9c:	e406                	sd	ra,8(sp)
    80000a9e:	e022                	sd	s0,0(sp)
    80000aa0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aa2:	00008597          	auipc	a1,0x8
    80000aa6:	5d658593          	addi	a1,a1,1494 # 80009078 <digits+0x28>
    80000aaa:	00011517          	auipc	a0,0x11
    80000aae:	7d650513          	addi	a0,a0,2006 # 80012280 <kmem>
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	084080e7          	jalr	132(ra) # 80000b36 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aba:	45c5                	li	a1,17
    80000abc:	05ee                	slli	a1,a1,0x1b
    80000abe:	00042517          	auipc	a0,0x42
    80000ac2:	54250513          	addi	a0,a0,1346 # 80043000 <end>
    80000ac6:	00000097          	auipc	ra,0x0
    80000aca:	f8a080e7          	jalr	-118(ra) # 80000a50 <freerange>
}
    80000ace:	60a2                	ld	ra,8(sp)
    80000ad0:	6402                	ld	s0,0(sp)
    80000ad2:	0141                	addi	sp,sp,16
    80000ad4:	8082                	ret

0000000080000ad6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ad6:	1101                	addi	sp,sp,-32
    80000ad8:	ec06                	sd	ra,24(sp)
    80000ada:	e822                	sd	s0,16(sp)
    80000adc:	e426                	sd	s1,8(sp)
    80000ade:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000ae0:	00011497          	auipc	s1,0x11
    80000ae4:	7a048493          	addi	s1,s1,1952 # 80012280 <kmem>
    80000ae8:	8526                	mv	a0,s1
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	11e080e7          	jalr	286(ra) # 80000c08 <acquire>
  r = kmem.freelist;
    80000af2:	6c84                	ld	s1,24(s1)
  if(r)
    80000af4:	c885                	beqz	s1,80000b24 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000af6:	609c                	ld	a5,0(s1)
    80000af8:	00011517          	auipc	a0,0x11
    80000afc:	78850513          	addi	a0,a0,1928 # 80012280 <kmem>
    80000b00:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b02:	00000097          	auipc	ra,0x0
    80000b06:	1dc080e7          	jalr	476(ra) # 80000cde <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b0a:	6605                	lui	a2,0x1
    80000b0c:	4595                	li	a1,5
    80000b0e:	8526                	mv	a0,s1
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	4ce080e7          	jalr	1230(ra) # 80000fde <memset>
  return (void*)r;
}
    80000b18:	8526                	mv	a0,s1
    80000b1a:	60e2                	ld	ra,24(sp)
    80000b1c:	6442                	ld	s0,16(sp)
    80000b1e:	64a2                	ld	s1,8(sp)
    80000b20:	6105                	addi	sp,sp,32
    80000b22:	8082                	ret
  release(&kmem.lock);
    80000b24:	00011517          	auipc	a0,0x11
    80000b28:	75c50513          	addi	a0,a0,1884 # 80012280 <kmem>
    80000b2c:	00000097          	auipc	ra,0x0
    80000b30:	1b2080e7          	jalr	434(ra) # 80000cde <release>
  if(r)
    80000b34:	b7d5                	j	80000b18 <kalloc+0x42>

0000000080000b36 <initlock>:
      
struct bsemaphore bsemaphores[MAX_BSEM];

void
initlock(struct spinlock *lk, char *name)
{
    80000b36:	1141                	addi	sp,sp,-16
    80000b38:	e422                	sd	s0,8(sp)
    80000b3a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b3c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b3e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b42:	00053823          	sd	zero,16(a0)
}
    80000b46:	6422                	ld	s0,8(sp)
    80000b48:	0141                	addi	sp,sp,16
    80000b4a:	8082                	ret

0000000080000b4c <initsemaphores>:

void
initsemaphores(){
    80000b4c:	1141                	addi	sp,sp,-16
    80000b4e:	e422                	sd	s0,8(sp)
    80000b50:	0800                	addi	s0,sp,16
  struct bsemaphore *sem;
  for(sem =bsemaphores; sem<&bsemaphores[MAX_BSEM];sem++){
    80000b52:	00011797          	auipc	a5,0x11
    80000b56:	74e78793          	addi	a5,a5,1870 # 800122a0 <bsemaphores>
    sem->state = SUNUSED;
    sem->s = 1;
    80000b5a:	4605                	li	a2,1
  lk->name = name;
    80000b5c:	00008697          	auipc	a3,0x8
    80000b60:	52468693          	addi	a3,a3,1316 # 80009080 <digits+0x30>
  for(sem =bsemaphores; sem<&bsemaphores[MAX_BSEM];sem++){
    80000b64:	00013717          	auipc	a4,0x13
    80000b68:	b3c70713          	addi	a4,a4,-1220 # 800136a0 <pid_lock>
    sem->state = SUNUSED;
    80000b6c:	0007ae23          	sw	zero,28(a5)
    sem->s = 1;
    80000b70:	cf90                	sw	a2,24(a5)
    sem->waiting = 0;
    80000b72:	0207a023          	sw	zero,32(a5)
  lk->name = name;
    80000b76:	e794                	sd	a3,8(a5)
  lk->locked = 0;
    80000b78:	0007a023          	sw	zero,0(a5)
  lk->cpu = 0;
    80000b7c:	0007b823          	sd	zero,16(a5)
  for(sem =bsemaphores; sem<&bsemaphores[MAX_BSEM];sem++){
    80000b80:	02878793          	addi	a5,a5,40
    80000b84:	fee794e3          	bne	a5,a4,80000b6c <initsemaphores+0x20>
    initlock(&sem->s_lock,"lock");
  }
}
    80000b88:	6422                	ld	s0,8(sp)
    80000b8a:	0141                	addi	sp,sp,16
    80000b8c:	8082                	ret

0000000080000b8e <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8e:	411c                	lw	a5,0(a0)
    80000b90:	e399                	bnez	a5,80000b96 <holding+0x8>
    80000b92:	4501                	li	a0,0
  return r;
}
    80000b94:	8082                	ret
{
    80000b96:	1101                	addi	sp,sp,-32
    80000b98:	ec06                	sd	ra,24(sp)
    80000b9a:	e822                	sd	s0,16(sp)
    80000b9c:	e426                	sd	s1,8(sp)
    80000b9e:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000ba0:	6904                	ld	s1,16(a0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	1b8080e7          	jalr	440(ra) # 80001d5a <mycpu>
    80000baa:	40a48533          	sub	a0,s1,a0
    80000bae:	00153513          	seqz	a0,a0
}
    80000bb2:	60e2                	ld	ra,24(sp)
    80000bb4:	6442                	ld	s0,16(sp)
    80000bb6:	64a2                	ld	s1,8(sp)
    80000bb8:	6105                	addi	sp,sp,32
    80000bba:	8082                	ret

0000000080000bbc <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bbc:	1101                	addi	sp,sp,-32
    80000bbe:	ec06                	sd	ra,24(sp)
    80000bc0:	e822                	sd	s0,16(sp)
    80000bc2:	e426                	sd	s1,8(sp)
    80000bc4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bc6:	100024f3          	csrr	s1,sstatus
    80000bca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bce:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bd0:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bd4:	00001097          	auipc	ra,0x1
    80000bd8:	186080e7          	jalr	390(ra) # 80001d5a <mycpu>
    80000bdc:	5d3c                	lw	a5,120(a0)
    80000bde:	cf89                	beqz	a5,80000bf8 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000be0:	00001097          	auipc	ra,0x1
    80000be4:	17a080e7          	jalr	378(ra) # 80001d5a <mycpu>
    80000be8:	5d3c                	lw	a5,120(a0)
    80000bea:	2785                	addiw	a5,a5,1
    80000bec:	dd3c                	sw	a5,120(a0)
}
    80000bee:	60e2                	ld	ra,24(sp)
    80000bf0:	6442                	ld	s0,16(sp)
    80000bf2:	64a2                	ld	s1,8(sp)
    80000bf4:	6105                	addi	sp,sp,32
    80000bf6:	8082                	ret
    mycpu()->intena = old;
    80000bf8:	00001097          	auipc	ra,0x1
    80000bfc:	162080e7          	jalr	354(ra) # 80001d5a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c00:	8085                	srli	s1,s1,0x1
    80000c02:	8885                	andi	s1,s1,1
    80000c04:	dd64                	sw	s1,124(a0)
    80000c06:	bfe9                	j	80000be0 <push_off+0x24>

0000000080000c08 <acquire>:
acquire(struct spinlock *lk){
    80000c08:	1101                	addi	sp,sp,-32
    80000c0a:	ec06                	sd	ra,24(sp)
    80000c0c:	e822                	sd	s0,16(sp)
    80000c0e:	e426                	sd	s1,8(sp)
    80000c10:	1000                	addi	s0,sp,32
    80000c12:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c14:	00000097          	auipc	ra,0x0
    80000c18:	fa8080e7          	jalr	-88(ra) # 80000bbc <push_off>
  if(holding(lk)){
    80000c1c:	8526                	mv	a0,s1
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	f70080e7          	jalr	-144(ra) # 80000b8e <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c26:	4705                	li	a4,1
  if(holding(lk)){
    80000c28:	e115                	bnez	a0,80000c4c <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c2a:	87ba                	mv	a5,a4
    80000c2c:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c30:	2781                	sext.w	a5,a5
    80000c32:	ffe5                	bnez	a5,80000c2a <acquire+0x22>
  __sync_synchronize();
    80000c34:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c38:	00001097          	auipc	ra,0x1
    80000c3c:	122080e7          	jalr	290(ra) # 80001d5a <mycpu>
    80000c40:	e888                	sd	a0,16(s1)
}
    80000c42:	60e2                	ld	ra,24(sp)
    80000c44:	6442                	ld	s0,16(sp)
    80000c46:	64a2                	ld	s1,8(sp)
    80000c48:	6105                	addi	sp,sp,32
    80000c4a:	8082                	ret
    printf("pid=%d tid=%d tried to lock when already holding\n",lk->cpu->proc->pid,mykthread()->tid);//TODO delete
    80000c4c:	689c                	ld	a5,16(s1)
    80000c4e:	639c                	ld	a5,0(a5)
    80000c50:	53c4                	lw	s1,36(a5)
    80000c52:	00001097          	auipc	ra,0x1
    80000c56:	16c080e7          	jalr	364(ra) # 80001dbe <mykthread>
    80000c5a:	5910                	lw	a2,48(a0)
    80000c5c:	85a6                	mv	a1,s1
    80000c5e:	00008517          	auipc	a0,0x8
    80000c62:	42a50513          	addi	a0,a0,1066 # 80009088 <digits+0x38>
    80000c66:	00000097          	auipc	ra,0x0
    80000c6a:	912080e7          	jalr	-1774(ra) # 80000578 <printf>
    panic("acquire");
    80000c6e:	00008517          	auipc	a0,0x8
    80000c72:	45250513          	addi	a0,a0,1106 # 800090c0 <digits+0x70>
    80000c76:	00000097          	auipc	ra,0x0
    80000c7a:	8b8080e7          	jalr	-1864(ra) # 8000052e <panic>

0000000080000c7e <pop_off>:

void
pop_off(void)
{
    80000c7e:	1141                	addi	sp,sp,-16
    80000c80:	e406                	sd	ra,8(sp)
    80000c82:	e022                	sd	s0,0(sp)
    80000c84:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c86:	00001097          	auipc	ra,0x1
    80000c8a:	0d4080e7          	jalr	212(ra) # 80001d5a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c8e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c92:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c94:	e78d                	bnez	a5,80000cbe <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c96:	5d3c                	lw	a5,120(a0)
    80000c98:	02f05b63          	blez	a5,80000cce <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c9c:	37fd                	addiw	a5,a5,-1
    80000c9e:	0007871b          	sext.w	a4,a5
    80000ca2:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000ca4:	eb09                	bnez	a4,80000cb6 <pop_off+0x38>
    80000ca6:	5d7c                	lw	a5,124(a0)
    80000ca8:	c799                	beqz	a5,80000cb6 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000caa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cae:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cb2:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cb6:	60a2                	ld	ra,8(sp)
    80000cb8:	6402                	ld	s0,0(sp)
    80000cba:	0141                	addi	sp,sp,16
    80000cbc:	8082                	ret
    panic("pop_off - interruptible");
    80000cbe:	00008517          	auipc	a0,0x8
    80000cc2:	40a50513          	addi	a0,a0,1034 # 800090c8 <digits+0x78>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	868080e7          	jalr	-1944(ra) # 8000052e <panic>
    panic("pop_off");
    80000cce:	00008517          	auipc	a0,0x8
    80000cd2:	41250513          	addi	a0,a0,1042 # 800090e0 <digits+0x90>
    80000cd6:	00000097          	auipc	ra,0x0
    80000cda:	858080e7          	jalr	-1960(ra) # 8000052e <panic>

0000000080000cde <release>:
{
    80000cde:	1101                	addi	sp,sp,-32
    80000ce0:	ec06                	sd	ra,24(sp)
    80000ce2:	e822                	sd	s0,16(sp)
    80000ce4:	e426                	sd	s1,8(sp)
    80000ce6:	1000                	addi	s0,sp,32
    80000ce8:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cea:	00000097          	auipc	ra,0x0
    80000cee:	ea4080e7          	jalr	-348(ra) # 80000b8e <holding>
    80000cf2:	c115                	beqz	a0,80000d16 <release+0x38>
  lk->cpu = 0;
    80000cf4:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cf8:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cfc:	0f50000f          	fence	iorw,ow
    80000d00:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d04:	00000097          	auipc	ra,0x0
    80000d08:	f7a080e7          	jalr	-134(ra) # 80000c7e <pop_off>
}
    80000d0c:	60e2                	ld	ra,24(sp)
    80000d0e:	6442                	ld	s0,16(sp)
    80000d10:	64a2                	ld	s1,8(sp)
    80000d12:	6105                	addi	sp,sp,32
    80000d14:	8082                	ret
    panic("release");
    80000d16:	00008517          	auipc	a0,0x8
    80000d1a:	3d250513          	addi	a0,a0,978 # 800090e8 <digits+0x98>
    80000d1e:	00000097          	auipc	ra,0x0
    80000d22:	810080e7          	jalr	-2032(ra) # 8000052e <panic>

0000000080000d26 <bsem_alloc>:
/////////// bsemaphore/////////////// 

// Allocates a new binary semaphore and returns its descriptor(-1 if failure). You are not
// restricted on the binary semaphore internal structure, but the newly allocated binary
// semaphore should be in unlocked state.
int bsem_alloc(){
    80000d26:	1101                	addi	sp,sp,-32
    80000d28:	ec06                	sd	ra,24(sp)
    80000d2a:	e822                	sd	s0,16(sp)
    80000d2c:	e426                	sd	s1,8(sp)
    80000d2e:	e04a                	sd	s2,0(sp)
    80000d30:	1000                	addi	s0,sp,32
  
  struct bsemaphore *sem;
  for(sem =bsemaphores; sem<&bsemaphores[MAX_BSEM];sem++){
    80000d32:	00011497          	auipc	s1,0x11
    80000d36:	56e48493          	addi	s1,s1,1390 # 800122a0 <bsemaphores>
    80000d3a:	00013917          	auipc	s2,0x13
    80000d3e:	96690913          	addi	s2,s2,-1690 # 800136a0 <pid_lock>
    acquire(&sem->s_lock);
    80000d42:	8526                	mv	a0,s1
    80000d44:	00000097          	auipc	ra,0x0
    80000d48:	ec4080e7          	jalr	-316(ra) # 80000c08 <acquire>
    if(sem->state == SUNUSED)
    80000d4c:	4cdc                	lw	a5,28(s1)
    80000d4e:	c395                	beqz	a5,80000d72 <bsem_alloc+0x4c>
      goto found;
    release(&sem->s_lock);
    80000d50:	8526                	mv	a0,s1
    80000d52:	00000097          	auipc	ra,0x0
    80000d56:	f8c080e7          	jalr	-116(ra) # 80000cde <release>
  for(sem =bsemaphores; sem<&bsemaphores[MAX_BSEM];sem++){
    80000d5a:	02848493          	addi	s1,s1,40
    80000d5e:	ff2492e3          	bne	s1,s2,80000d42 <bsem_alloc+0x1c>
  }
  panic("Semaphore BOMB");
    80000d62:	00008517          	auipc	a0,0x8
    80000d66:	38e50513          	addi	a0,a0,910 # 800090f0 <digits+0xa0>
    80000d6a:	fffff097          	auipc	ra,0xfffff
    80000d6e:	7c4080e7          	jalr	1988(ra) # 8000052e <panic>

  // found free semaphore
  found:
  sem->state=SUSED;
    80000d72:	4785                	li	a5,1
    80000d74:	ccdc                	sw	a5,28(s1)
  sem->s=1;
    80000d76:	cc9c                	sw	a5,24(s1)
  sem->waiting=0;
    80000d78:	0204a023          	sw	zero,32(s1)
  release(&sem->s_lock);
    80000d7c:	8526                	mv	a0,s1
    80000d7e:	00000097          	auipc	ra,0x0
    80000d82:	f60080e7          	jalr	-160(ra) # 80000cde <release>

  return (int)(sem - bsemaphores);
    80000d86:	00011517          	auipc	a0,0x11
    80000d8a:	51a50513          	addi	a0,a0,1306 # 800122a0 <bsemaphores>
    80000d8e:	40a48533          	sub	a0,s1,a0
    80000d92:	850d                	srai	a0,a0,0x3
    80000d94:	00008797          	auipc	a5,0x8
    80000d98:	26c7b783          	ld	a5,620(a5) # 80009000 <etext>
    80000d9c:	02f5053b          	mulw	a0,a0,a5
  
}
    80000da0:	60e2                	ld	ra,24(sp)
    80000da2:	6442                	ld	s0,16(sp)
    80000da4:	64a2                	ld	s1,8(sp)
    80000da6:	6902                	ld	s2,0(sp)
    80000da8:	6105                	addi	sp,sp,32
    80000daa:	8082                	ret

0000000080000dac <bsem_free>:

// Call the free function with the semaphore down
void
bsem_free(int sem_index){
    80000dac:	1101                	addi	sp,sp,-32
    80000dae:	ec06                	sd	ra,24(sp)
    80000db0:	e822                	sd	s0,16(sp)
    80000db2:	e426                	sd	s1,8(sp)
    80000db4:	e04a                	sd	s2,0(sp)
    80000db6:	1000                	addi	s0,sp,32
  if(sem_index<0 || sem_index > MAX_BSEM)
    80000db8:	08000793          	li	a5,128
    80000dbc:	06a7e563          	bltu	a5,a0,80000e26 <bsem_free+0x7a>
    80000dc0:	892a                	mv	s2,a0
    panic("fudge you give me bad index in bsem_down");

  struct bsemaphore *bsem = &bsemaphores[sem_index];
  acquire(&bsem->s_lock);
    80000dc2:	00251493          	slli	s1,a0,0x2
    80000dc6:	94aa                	add	s1,s1,a0
    80000dc8:	048e                	slli	s1,s1,0x3
    80000dca:	00011797          	auipc	a5,0x11
    80000dce:	4d678793          	addi	a5,a5,1238 # 800122a0 <bsemaphores>
    80000dd2:	94be                	add	s1,s1,a5
    80000dd4:	8526                	mv	a0,s1
    80000dd6:	00000097          	auipc	ra,0x0
    80000dda:	e32080e7          	jalr	-462(ra) # 80000c08 <acquire>
  if(bsem->state == SUNUSED ){
    80000dde:	4cdc                	lw	a5,28(s1)
    80000de0:	cbb9                	beqz	a5,80000e36 <bsem_free+0x8a>
    release(&bsem->s_lock);
    panic("fack semaphore is not alloced in bsem_down");
  }
  if(bsem->waiting > 0)
    80000de2:	00291793          	slli	a5,s2,0x2
    80000de6:	97ca                	add	a5,a5,s2
    80000de8:	078e                	slli	a5,a5,0x3
    80000dea:	00011717          	auipc	a4,0x11
    80000dee:	4b670713          	addi	a4,a4,1206 # 800122a0 <bsemaphores>
    80000df2:	97ba                	add	a5,a5,a4
    80000df4:	539c                	lw	a5,32(a5)
    80000df6:	04f04d63          	bgtz	a5,80000e50 <bsem_free+0xa4>

  // if(bsem->s == 0)
  //   panic("tried to free bsem when it is locked!");

  
  bsem->state = SUNUSED;
    80000dfa:	00291793          	slli	a5,s2,0x2
    80000dfe:	993e                	add	s2,s2,a5
    80000e00:	090e                	slli	s2,s2,0x3
    80000e02:	00011797          	auipc	a5,0x11
    80000e06:	49e78793          	addi	a5,a5,1182 # 800122a0 <bsemaphores>
    80000e0a:	993e                	add	s2,s2,a5
    80000e0c:	00092e23          	sw	zero,28(s2)
  release(&bsem->s_lock);
    80000e10:	8526                	mv	a0,s1
    80000e12:	00000097          	auipc	ra,0x0
    80000e16:	ecc080e7          	jalr	-308(ra) # 80000cde <release>
}
    80000e1a:	60e2                	ld	ra,24(sp)
    80000e1c:	6442                	ld	s0,16(sp)
    80000e1e:	64a2                	ld	s1,8(sp)
    80000e20:	6902                	ld	s2,0(sp)
    80000e22:	6105                	addi	sp,sp,32
    80000e24:	8082                	ret
    panic("fudge you give me bad index in bsem_down");
    80000e26:	00008517          	auipc	a0,0x8
    80000e2a:	2da50513          	addi	a0,a0,730 # 80009100 <digits+0xb0>
    80000e2e:	fffff097          	auipc	ra,0xfffff
    80000e32:	700080e7          	jalr	1792(ra) # 8000052e <panic>
    release(&bsem->s_lock);
    80000e36:	8526                	mv	a0,s1
    80000e38:	00000097          	auipc	ra,0x0
    80000e3c:	ea6080e7          	jalr	-346(ra) # 80000cde <release>
    panic("fack semaphore is not alloced in bsem_down");
    80000e40:	00008517          	auipc	a0,0x8
    80000e44:	2f050513          	addi	a0,a0,752 # 80009130 <digits+0xe0>
    80000e48:	fffff097          	auipc	ra,0xfffff
    80000e4c:	6e6080e7          	jalr	1766(ra) # 8000052e <panic>
    panic("tried to bsem_free when threads are blocked");
    80000e50:	00008517          	auipc	a0,0x8
    80000e54:	31050513          	addi	a0,a0,784 # 80009160 <digits+0x110>
    80000e58:	fffff097          	auipc	ra,0xfffff
    80000e5c:	6d6080e7          	jalr	1750(ra) # 8000052e <panic>

0000000080000e60 <bsem_down>:

// Attempt to acquire (lock) the semaphore, in case that it is already acquired (locked),
// block the current thread until it is unlocked and then acquire it./
void
bsem_down(int sem_index){
    80000e60:	7179                	addi	sp,sp,-48
    80000e62:	f406                	sd	ra,40(sp)
    80000e64:	f022                	sd	s0,32(sp)
    80000e66:	ec26                	sd	s1,24(sp)
    80000e68:	e84a                	sd	s2,16(sp)
    80000e6a:	e44e                	sd	s3,8(sp)
    80000e6c:	1800                	addi	s0,sp,48
  if(sem_index<0 || sem_index > MAX_BSEM)
    80000e6e:	08000793          	li	a5,128
    80000e72:	0aa7e063          	bltu	a5,a0,80000f12 <bsem_down+0xb2>
    80000e76:	89aa                	mv	s3,a0
    panic("fudge you give me bad index in bsem_down");

  struct bsemaphore *bsem = &bsemaphores[sem_index];
    80000e78:	00251493          	slli	s1,a0,0x2
    80000e7c:	94aa                	add	s1,s1,a0
    80000e7e:	048e                	slli	s1,s1,0x3
    80000e80:	00011797          	auipc	a5,0x11
    80000e84:	42078793          	addi	a5,a5,1056 # 800122a0 <bsemaphores>
    80000e88:	94be                	add	s1,s1,a5
  acquire(&bsem->s_lock);
    80000e8a:	8526                	mv	a0,s1
    80000e8c:	00000097          	auipc	ra,0x0
    80000e90:	d7c080e7          	jalr	-644(ra) # 80000c08 <acquire>
  if(bsem->state == SUNUSED ){
    80000e94:	4cdc                	lw	a5,28(s1)
    80000e96:	c7d1                	beqz	a5,80000f22 <bsem_down+0xc2>
    release(&bsem->s_lock);
    panic("fack semaphore is not alloced in bsem_down");
  }

  bsem->waiting++;
    80000e98:	00299793          	slli	a5,s3,0x2
    80000e9c:	97ce                	add	a5,a5,s3
    80000e9e:	00379713          	slli	a4,a5,0x3
    80000ea2:	00011797          	auipc	a5,0x11
    80000ea6:	3fe78793          	addi	a5,a5,1022 # 800122a0 <bsemaphores>
    80000eaa:	97ba                	add	a5,a5,a4
    80000eac:	5398                	lw	a4,32(a5)
    80000eae:	2705                	addiw	a4,a4,1
    80000eb0:	d398                	sw	a4,32(a5)
  while(bsem->s == 0){// sleep until semaphore is unlocked
    80000eb2:	4f9c                	lw	a5,24(a5)
    80000eb4:	e785                	bnez	a5,80000edc <bsem_down+0x7c>
    80000eb6:	00299913          	slli	s2,s3,0x2
    80000eba:	994e                	add	s2,s2,s3
    80000ebc:	00391793          	slli	a5,s2,0x3
    80000ec0:	00011917          	auipc	s2,0x11
    80000ec4:	3e090913          	addi	s2,s2,992 # 800122a0 <bsemaphores>
    80000ec8:	993e                	add	s2,s2,a5
    sleep(bsem, &bsem->s_lock);
    80000eca:	85a6                	mv	a1,s1
    80000ecc:	8526                	mv	a0,s1
    80000ece:	00002097          	auipc	ra,0x2
    80000ed2:	826080e7          	jalr	-2010(ra) # 800026f4 <sleep>
  while(bsem->s == 0){// sleep until semaphore is unlocked
    80000ed6:	01892783          	lw	a5,24(s2)
    80000eda:	dbe5                	beqz	a5,80000eca <bsem_down+0x6a>
  }
  bsem->waiting--;
    80000edc:	00011697          	auipc	a3,0x11
    80000ee0:	3c468693          	addi	a3,a3,964 # 800122a0 <bsemaphores>
    80000ee4:	00299793          	slli	a5,s3,0x2
    80000ee8:	01378733          	add	a4,a5,s3
    80000eec:	070e                	slli	a4,a4,0x3
    80000eee:	9736                	add	a4,a4,a3
    80000ef0:	5310                	lw	a2,32(a4)
    80000ef2:	367d                	addiw	a2,a2,-1
    80000ef4:	d310                	sw	a2,32(a4)

  bsem->s = 0;
    80000ef6:	00072c23          	sw	zero,24(a4)
  release(&bsem->s_lock);
    80000efa:	8526                	mv	a0,s1
    80000efc:	00000097          	auipc	ra,0x0
    80000f00:	de2080e7          	jalr	-542(ra) # 80000cde <release>
}
    80000f04:	70a2                	ld	ra,40(sp)
    80000f06:	7402                	ld	s0,32(sp)
    80000f08:	64e2                	ld	s1,24(sp)
    80000f0a:	6942                	ld	s2,16(sp)
    80000f0c:	69a2                	ld	s3,8(sp)
    80000f0e:	6145                	addi	sp,sp,48
    80000f10:	8082                	ret
    panic("fudge you give me bad index in bsem_down");
    80000f12:	00008517          	auipc	a0,0x8
    80000f16:	1ee50513          	addi	a0,a0,494 # 80009100 <digits+0xb0>
    80000f1a:	fffff097          	auipc	ra,0xfffff
    80000f1e:	614080e7          	jalr	1556(ra) # 8000052e <panic>
    release(&bsem->s_lock);
    80000f22:	8526                	mv	a0,s1
    80000f24:	00000097          	auipc	ra,0x0
    80000f28:	dba080e7          	jalr	-582(ra) # 80000cde <release>
    panic("fack semaphore is not alloced in bsem_down");
    80000f2c:	00008517          	auipc	a0,0x8
    80000f30:	20450513          	addi	a0,a0,516 # 80009130 <digits+0xe0>
    80000f34:	fffff097          	auipc	ra,0xfffff
    80000f38:	5fa080e7          	jalr	1530(ra) # 8000052e <panic>

0000000080000f3c <bsem_up>:

void bsem_up(int sem_index){
    80000f3c:	1101                	addi	sp,sp,-32
    80000f3e:	ec06                	sd	ra,24(sp)
    80000f40:	e822                	sd	s0,16(sp)
    80000f42:	e426                	sd	s1,8(sp)
    80000f44:	e04a                	sd	s2,0(sp)
    80000f46:	1000                	addi	s0,sp,32
  if(sem_index<0 || sem_index > MAX_BSEM)
    80000f48:	08000793          	li	a5,128
    80000f4c:	04a7ee63          	bltu	a5,a0,80000fa8 <bsem_up+0x6c>
    80000f50:	892a                	mv	s2,a0
    panic("fudge you give me bad index in bsem_down");

  struct bsemaphore *bsem = &bsemaphores[sem_index];
    80000f52:	00251493          	slli	s1,a0,0x2
    80000f56:	94aa                	add	s1,s1,a0
    80000f58:	048e                	slli	s1,s1,0x3
    80000f5a:	00011797          	auipc	a5,0x11
    80000f5e:	34678793          	addi	a5,a5,838 # 800122a0 <bsemaphores>
    80000f62:	94be                	add	s1,s1,a5
  acquire(&bsem->s_lock);
    80000f64:	8526                	mv	a0,s1
    80000f66:	00000097          	auipc	ra,0x0
    80000f6a:	ca2080e7          	jalr	-862(ra) # 80000c08 <acquire>
  if(bsem->state == SUNUSED ){
    80000f6e:	4cdc                	lw	a5,28(s1)
    80000f70:	c7a1                	beqz	a5,80000fb8 <bsem_up+0x7c>
    release(&bsem->s_lock);
    panic("fack semaphore is not alloced in bsem_down");
  }
  bsem->s++;
    80000f72:	00011697          	auipc	a3,0x11
    80000f76:	32e68693          	addi	a3,a3,814 # 800122a0 <bsemaphores>
    80000f7a:	00291793          	slli	a5,s2,0x2
    80000f7e:	01278733          	add	a4,a5,s2
    80000f82:	070e                	slli	a4,a4,0x3
    80000f84:	9736                	add	a4,a4,a3
    80000f86:	4f10                	lw	a2,24(a4)
    80000f88:	2605                	addiw	a2,a2,1
    80000f8a:	cf10                	sw	a2,24(a4)

  if(bsem->waiting > 0)
    80000f8c:	531c                	lw	a5,32(a4)
    80000f8e:	04f04263          	bgtz	a5,80000fd2 <bsem_up+0x96>
    wakeup(bsem);
  
  release(&bsem->s_lock);
    80000f92:	8526                	mv	a0,s1
    80000f94:	00000097          	auipc	ra,0x0
    80000f98:	d4a080e7          	jalr	-694(ra) # 80000cde <release>
}
    80000f9c:	60e2                	ld	ra,24(sp)
    80000f9e:	6442                	ld	s0,16(sp)
    80000fa0:	64a2                	ld	s1,8(sp)
    80000fa2:	6902                	ld	s2,0(sp)
    80000fa4:	6105                	addi	sp,sp,32
    80000fa6:	8082                	ret
    panic("fudge you give me bad index in bsem_down");
    80000fa8:	00008517          	auipc	a0,0x8
    80000fac:	15850513          	addi	a0,a0,344 # 80009100 <digits+0xb0>
    80000fb0:	fffff097          	auipc	ra,0xfffff
    80000fb4:	57e080e7          	jalr	1406(ra) # 8000052e <panic>
    release(&bsem->s_lock);
    80000fb8:	8526                	mv	a0,s1
    80000fba:	00000097          	auipc	ra,0x0
    80000fbe:	d24080e7          	jalr	-732(ra) # 80000cde <release>
    panic("fack semaphore is not alloced in bsem_down");
    80000fc2:	00008517          	auipc	a0,0x8
    80000fc6:	16e50513          	addi	a0,a0,366 # 80009130 <digits+0xe0>
    80000fca:	fffff097          	auipc	ra,0xfffff
    80000fce:	564080e7          	jalr	1380(ra) # 8000052e <panic>
    wakeup(bsem);
    80000fd2:	8526                	mv	a0,s1
    80000fd4:	00002097          	auipc	ra,0x2
    80000fd8:	8aa080e7          	jalr	-1878(ra) # 8000287e <wakeup>
    80000fdc:	bf5d                	j	80000f92 <bsem_up+0x56>

0000000080000fde <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000fde:	1141                	addi	sp,sp,-16
    80000fe0:	e422                	sd	s0,8(sp)
    80000fe2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000fe4:	ca19                	beqz	a2,80000ffa <memset+0x1c>
    80000fe6:	87aa                	mv	a5,a0
    80000fe8:	1602                	slli	a2,a2,0x20
    80000fea:	9201                	srli	a2,a2,0x20
    80000fec:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ff0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ff4:	0785                	addi	a5,a5,1
    80000ff6:	fee79de3          	bne	a5,a4,80000ff0 <memset+0x12>
  }
  return dst;
}
    80000ffa:	6422                	ld	s0,8(sp)
    80000ffc:	0141                	addi	sp,sp,16
    80000ffe:	8082                	ret

0000000080001000 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80001000:	1141                	addi	sp,sp,-16
    80001002:	e422                	sd	s0,8(sp)
    80001004:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80001006:	ca05                	beqz	a2,80001036 <memcmp+0x36>
    80001008:	fff6069b          	addiw	a3,a2,-1
    8000100c:	1682                	slli	a3,a3,0x20
    8000100e:	9281                	srli	a3,a3,0x20
    80001010:	0685                	addi	a3,a3,1
    80001012:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80001014:	00054783          	lbu	a5,0(a0)
    80001018:	0005c703          	lbu	a4,0(a1)
    8000101c:	00e79863          	bne	a5,a4,8000102c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80001020:	0505                	addi	a0,a0,1
    80001022:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80001024:	fed518e3          	bne	a0,a3,80001014 <memcmp+0x14>
  }

  return 0;
    80001028:	4501                	li	a0,0
    8000102a:	a019                	j	80001030 <memcmp+0x30>
      return *s1 - *s2;
    8000102c:	40e7853b          	subw	a0,a5,a4
}
    80001030:	6422                	ld	s0,8(sp)
    80001032:	0141                	addi	sp,sp,16
    80001034:	8082                	ret
  return 0;
    80001036:	4501                	li	a0,0
    80001038:	bfe5                	j	80001030 <memcmp+0x30>

000000008000103a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    8000103a:	1141                	addi	sp,sp,-16
    8000103c:	e422                	sd	s0,8(sp)
    8000103e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80001040:	02a5e563          	bltu	a1,a0,8000106a <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80001044:	fff6069b          	addiw	a3,a2,-1
    80001048:	ce11                	beqz	a2,80001064 <memmove+0x2a>
    8000104a:	1682                	slli	a3,a3,0x20
    8000104c:	9281                	srli	a3,a3,0x20
    8000104e:	0685                	addi	a3,a3,1
    80001050:	96ae                	add	a3,a3,a1
    80001052:	87aa                	mv	a5,a0
      *d++ = *s++;
    80001054:	0585                	addi	a1,a1,1
    80001056:	0785                	addi	a5,a5,1
    80001058:	fff5c703          	lbu	a4,-1(a1)
    8000105c:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80001060:	fed59ae3          	bne	a1,a3,80001054 <memmove+0x1a>

  return dst;
}
    80001064:	6422                	ld	s0,8(sp)
    80001066:	0141                	addi	sp,sp,16
    80001068:	8082                	ret
  if(s < d && s + n > d){
    8000106a:	02061713          	slli	a4,a2,0x20
    8000106e:	9301                	srli	a4,a4,0x20
    80001070:	00e587b3          	add	a5,a1,a4
    80001074:	fcf578e3          	bgeu	a0,a5,80001044 <memmove+0xa>
    d += n;
    80001078:	972a                	add	a4,a4,a0
    while(n-- > 0)
    8000107a:	fff6069b          	addiw	a3,a2,-1
    8000107e:	d27d                	beqz	a2,80001064 <memmove+0x2a>
    80001080:	02069613          	slli	a2,a3,0x20
    80001084:	9201                	srli	a2,a2,0x20
    80001086:	fff64613          	not	a2,a2
    8000108a:	963e                	add	a2,a2,a5
      *--d = *--s;
    8000108c:	17fd                	addi	a5,a5,-1
    8000108e:	177d                	addi	a4,a4,-1
    80001090:	0007c683          	lbu	a3,0(a5)
    80001094:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80001098:	fef61ae3          	bne	a2,a5,8000108c <memmove+0x52>
    8000109c:	b7e1                	j	80001064 <memmove+0x2a>

000000008000109e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    8000109e:	1141                	addi	sp,sp,-16
    800010a0:	e406                	sd	ra,8(sp)
    800010a2:	e022                	sd	s0,0(sp)
    800010a4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    800010a6:	00000097          	auipc	ra,0x0
    800010aa:	f94080e7          	jalr	-108(ra) # 8000103a <memmove>
}
    800010ae:	60a2                	ld	ra,8(sp)
    800010b0:	6402                	ld	s0,0(sp)
    800010b2:	0141                	addi	sp,sp,16
    800010b4:	8082                	ret

00000000800010b6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    800010b6:	1141                	addi	sp,sp,-16
    800010b8:	e422                	sd	s0,8(sp)
    800010ba:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    800010bc:	ce11                	beqz	a2,800010d8 <strncmp+0x22>
    800010be:	00054783          	lbu	a5,0(a0)
    800010c2:	cf89                	beqz	a5,800010dc <strncmp+0x26>
    800010c4:	0005c703          	lbu	a4,0(a1)
    800010c8:	00f71a63          	bne	a4,a5,800010dc <strncmp+0x26>
    n--, p++, q++;
    800010cc:	367d                	addiw	a2,a2,-1
    800010ce:	0505                	addi	a0,a0,1
    800010d0:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    800010d2:	f675                	bnez	a2,800010be <strncmp+0x8>
  if(n == 0)
    return 0;
    800010d4:	4501                	li	a0,0
    800010d6:	a809                	j	800010e8 <strncmp+0x32>
    800010d8:	4501                	li	a0,0
    800010da:	a039                	j	800010e8 <strncmp+0x32>
  if(n == 0)
    800010dc:	ca09                	beqz	a2,800010ee <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    800010de:	00054503          	lbu	a0,0(a0)
    800010e2:	0005c783          	lbu	a5,0(a1)
    800010e6:	9d1d                	subw	a0,a0,a5
}
    800010e8:	6422                	ld	s0,8(sp)
    800010ea:	0141                	addi	sp,sp,16
    800010ec:	8082                	ret
    return 0;
    800010ee:	4501                	li	a0,0
    800010f0:	bfe5                	j	800010e8 <strncmp+0x32>

00000000800010f2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800010f2:	1141                	addi	sp,sp,-16
    800010f4:	e422                	sd	s0,8(sp)
    800010f6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800010f8:	872a                	mv	a4,a0
    800010fa:	8832                	mv	a6,a2
    800010fc:	367d                	addiw	a2,a2,-1
    800010fe:	01005963          	blez	a6,80001110 <strncpy+0x1e>
    80001102:	0705                	addi	a4,a4,1
    80001104:	0005c783          	lbu	a5,0(a1)
    80001108:	fef70fa3          	sb	a5,-1(a4)
    8000110c:	0585                	addi	a1,a1,1
    8000110e:	f7f5                	bnez	a5,800010fa <strncpy+0x8>
    ;
  while(n-- > 0)
    80001110:	86ba                	mv	a3,a4
    80001112:	00c05c63          	blez	a2,8000112a <strncpy+0x38>
    *s++ = 0;
    80001116:	0685                	addi	a3,a3,1
    80001118:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    8000111c:	fff6c793          	not	a5,a3
    80001120:	9fb9                	addw	a5,a5,a4
    80001122:	010787bb          	addw	a5,a5,a6
    80001126:	fef048e3          	bgtz	a5,80001116 <strncpy+0x24>
  return os;
}
    8000112a:	6422                	ld	s0,8(sp)
    8000112c:	0141                	addi	sp,sp,16
    8000112e:	8082                	ret

0000000080001130 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80001130:	1141                	addi	sp,sp,-16
    80001132:	e422                	sd	s0,8(sp)
    80001134:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80001136:	02c05363          	blez	a2,8000115c <safestrcpy+0x2c>
    8000113a:	fff6069b          	addiw	a3,a2,-1
    8000113e:	1682                	slli	a3,a3,0x20
    80001140:	9281                	srli	a3,a3,0x20
    80001142:	96ae                	add	a3,a3,a1
    80001144:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80001146:	00d58963          	beq	a1,a3,80001158 <safestrcpy+0x28>
    8000114a:	0585                	addi	a1,a1,1
    8000114c:	0785                	addi	a5,a5,1
    8000114e:	fff5c703          	lbu	a4,-1(a1)
    80001152:	fee78fa3          	sb	a4,-1(a5)
    80001156:	fb65                	bnez	a4,80001146 <safestrcpy+0x16>
    ;
  *s = 0;
    80001158:	00078023          	sb	zero,0(a5)
  return os;
}
    8000115c:	6422                	ld	s0,8(sp)
    8000115e:	0141                	addi	sp,sp,16
    80001160:	8082                	ret

0000000080001162 <strlen>:

int
strlen(const char *s)
{
    80001162:	1141                	addi	sp,sp,-16
    80001164:	e422                	sd	s0,8(sp)
    80001166:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80001168:	00054783          	lbu	a5,0(a0)
    8000116c:	cf91                	beqz	a5,80001188 <strlen+0x26>
    8000116e:	0505                	addi	a0,a0,1
    80001170:	87aa                	mv	a5,a0
    80001172:	4685                	li	a3,1
    80001174:	9e89                	subw	a3,a3,a0
    80001176:	00f6853b          	addw	a0,a3,a5
    8000117a:	0785                	addi	a5,a5,1
    8000117c:	fff7c703          	lbu	a4,-1(a5)
    80001180:	fb7d                	bnez	a4,80001176 <strlen+0x14>
    ;
  return n;
}
    80001182:	6422                	ld	s0,8(sp)
    80001184:	0141                	addi	sp,sp,16
    80001186:	8082                	ret
  for(n = 0; s[n]; n++)
    80001188:	4501                	li	a0,0
    8000118a:	bfe5                	j	80001182 <strlen+0x20>

000000008000118c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    8000118c:	1141                	addi	sp,sp,-16
    8000118e:	e406                	sd	ra,8(sp)
    80001190:	e022                	sd	s0,0(sp)
    80001192:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80001194:	00001097          	auipc	ra,0x1
    80001198:	bb6080e7          	jalr	-1098(ra) # 80001d4a <cpuid>

    initsemaphores(); //init semaphores array

    started = 1;
  } else {
    while(started == 0)
    8000119c:	00009717          	auipc	a4,0x9
    800011a0:	e7c70713          	addi	a4,a4,-388 # 8000a018 <started>
  if(cpuid() == 0){
    800011a4:	c139                	beqz	a0,800011ea <main+0x5e>
    while(started == 0)
    800011a6:	431c                	lw	a5,0(a4)
    800011a8:	2781                	sext.w	a5,a5
    800011aa:	dff5                	beqz	a5,800011a6 <main+0x1a>
      ;
    __sync_synchronize();
    800011ac:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    800011b0:	00001097          	auipc	ra,0x1
    800011b4:	b9a080e7          	jalr	-1126(ra) # 80001d4a <cpuid>
    800011b8:	85aa                	mv	a1,a0
    800011ba:	00008517          	auipc	a0,0x8
    800011be:	fee50513          	addi	a0,a0,-18 # 800091a8 <digits+0x158>
    800011c2:	fffff097          	auipc	ra,0xfffff
    800011c6:	3b6080e7          	jalr	950(ra) # 80000578 <printf>
    kvminithart();    // turn on paging
    800011ca:	00000097          	auipc	ra,0x0
    800011ce:	0e0080e7          	jalr	224(ra) # 800012aa <kvminithart>
    trapinithart();   // install kernel trap vector
    800011d2:	00002097          	auipc	ra,0x2
    800011d6:	360080e7          	jalr	864(ra) # 80003532 <trapinithart>

    plicinithart();   // ask PLIC for device interrupts
    800011da:	00006097          	auipc	ra,0x6
    800011de:	f96080e7          	jalr	-106(ra) # 80007170 <plicinithart>
  }

  scheduler();        
    800011e2:	00001097          	auipc	ra,0x1
    800011e6:	2d6080e7          	jalr	726(ra) # 800024b8 <scheduler>
    consoleinit();
    800011ea:	fffff097          	auipc	ra,0xfffff
    800011ee:	256080e7          	jalr	598(ra) # 80000440 <consoleinit>
    printfinit();
    800011f2:	fffff097          	auipc	ra,0xfffff
    800011f6:	566080e7          	jalr	1382(ra) # 80000758 <printfinit>
    printf("\n");
    800011fa:	00008517          	auipc	a0,0x8
    800011fe:	ebe50513          	addi	a0,a0,-322 # 800090b8 <digits+0x68>
    80001202:	fffff097          	auipc	ra,0xfffff
    80001206:	376080e7          	jalr	886(ra) # 80000578 <printf>
    printf("xv6 kernel is booting\n");
    8000120a:	00008517          	auipc	a0,0x8
    8000120e:	f8650513          	addi	a0,a0,-122 # 80009190 <digits+0x140>
    80001212:	fffff097          	auipc	ra,0xfffff
    80001216:	366080e7          	jalr	870(ra) # 80000578 <printf>
    printf("\n");
    8000121a:	00008517          	auipc	a0,0x8
    8000121e:	e9e50513          	addi	a0,a0,-354 # 800090b8 <digits+0x68>
    80001222:	fffff097          	auipc	ra,0xfffff
    80001226:	356080e7          	jalr	854(ra) # 80000578 <printf>
    kinit();         // physical page allocator
    8000122a:	00000097          	auipc	ra,0x0
    8000122e:	870080e7          	jalr	-1936(ra) # 80000a9a <kinit>
    kvminit();       // create kernel page table
    80001232:	00000097          	auipc	ra,0x0
    80001236:	318080e7          	jalr	792(ra) # 8000154a <kvminit>
    kvminithart();   // turn on paging
    8000123a:	00000097          	auipc	ra,0x0
    8000123e:	070080e7          	jalr	112(ra) # 800012aa <kvminithart>
    procinit();      // process table
    80001242:	00001097          	auipc	ra,0x1
    80001246:	9da080e7          	jalr	-1574(ra) # 80001c1c <procinit>
    trapinit();      // trap vectors
    8000124a:	00002097          	auipc	ra,0x2
    8000124e:	2c0080e7          	jalr	704(ra) # 8000350a <trapinit>
    trapinithart();  // install kernel trap vector
    80001252:	00002097          	auipc	ra,0x2
    80001256:	2e0080e7          	jalr	736(ra) # 80003532 <trapinithart>
    plicinit();      // set up interrupt controller
    8000125a:	00006097          	auipc	ra,0x6
    8000125e:	f00080e7          	jalr	-256(ra) # 8000715a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001262:	00006097          	auipc	ra,0x6
    80001266:	f0e080e7          	jalr	-242(ra) # 80007170 <plicinithart>
    binit();         // buffer cache
    8000126a:	00003097          	auipc	ra,0x3
    8000126e:	030080e7          	jalr	48(ra) # 8000429a <binit>
    iinit();         // inode cache
    80001272:	00003097          	auipc	ra,0x3
    80001276:	6c2080e7          	jalr	1730(ra) # 80004934 <iinit>
    fileinit();      // file table
    8000127a:	00004097          	auipc	ra,0x4
    8000127e:	66e080e7          	jalr	1646(ra) # 800058e8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001282:	00006097          	auipc	ra,0x6
    80001286:	010080e7          	jalr	16(ra) # 80007292 <virtio_disk_init>
    userinit();      // first user process
    8000128a:	00001097          	auipc	ra,0x1
    8000128e:	f74080e7          	jalr	-140(ra) # 800021fe <userinit>
    __sync_synchronize();
    80001292:	0ff0000f          	fence
    initsemaphores(); //init semaphores array
    80001296:	00000097          	auipc	ra,0x0
    8000129a:	8b6080e7          	jalr	-1866(ra) # 80000b4c <initsemaphores>
    started = 1;
    8000129e:	4785                	li	a5,1
    800012a0:	00009717          	auipc	a4,0x9
    800012a4:	d6f72c23          	sw	a5,-648(a4) # 8000a018 <started>
    800012a8:	bf2d                	j	800011e2 <main+0x56>

00000000800012aa <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    800012aa:	1141                	addi	sp,sp,-16
    800012ac:	e422                	sd	s0,8(sp)
    800012ae:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    800012b0:	00009797          	auipc	a5,0x9
    800012b4:	d707b783          	ld	a5,-656(a5) # 8000a020 <kernel_pagetable>
    800012b8:	83b1                	srli	a5,a5,0xc
    800012ba:	577d                	li	a4,-1
    800012bc:	177e                	slli	a4,a4,0x3f
    800012be:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    800012c0:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800012c4:	12000073          	sfence.vma
  sfence_vma();
}
    800012c8:	6422                	ld	s0,8(sp)
    800012ca:	0141                	addi	sp,sp,16
    800012cc:	8082                	ret

00000000800012ce <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800012ce:	7139                	addi	sp,sp,-64
    800012d0:	fc06                	sd	ra,56(sp)
    800012d2:	f822                	sd	s0,48(sp)
    800012d4:	f426                	sd	s1,40(sp)
    800012d6:	f04a                	sd	s2,32(sp)
    800012d8:	ec4e                	sd	s3,24(sp)
    800012da:	e852                	sd	s4,16(sp)
    800012dc:	e456                	sd	s5,8(sp)
    800012de:	e05a                	sd	s6,0(sp)
    800012e0:	0080                	addi	s0,sp,64
    800012e2:	84aa                	mv	s1,a0
    800012e4:	89ae                	mv	s3,a1
    800012e6:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800012e8:	57fd                	li	a5,-1
    800012ea:	83e9                	srli	a5,a5,0x1a
    800012ec:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800012ee:	4b31                	li	s6,12
  if(va >= MAXVA)
    800012f0:	04b7f263          	bgeu	a5,a1,80001334 <walk+0x66>
    panic("walk");
    800012f4:	00008517          	auipc	a0,0x8
    800012f8:	ecc50513          	addi	a0,a0,-308 # 800091c0 <digits+0x170>
    800012fc:	fffff097          	auipc	ra,0xfffff
    80001300:	232080e7          	jalr	562(ra) # 8000052e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001304:	060a8663          	beqz	s5,80001370 <walk+0xa2>
    80001308:	fffff097          	auipc	ra,0xfffff
    8000130c:	7ce080e7          	jalr	1998(ra) # 80000ad6 <kalloc>
    80001310:	84aa                	mv	s1,a0
    80001312:	c529                	beqz	a0,8000135c <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001314:	6605                	lui	a2,0x1
    80001316:	4581                	li	a1,0
    80001318:	00000097          	auipc	ra,0x0
    8000131c:	cc6080e7          	jalr	-826(ra) # 80000fde <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001320:	00c4d793          	srli	a5,s1,0xc
    80001324:	07aa                	slli	a5,a5,0xa
    80001326:	0017e793          	ori	a5,a5,1
    8000132a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000132e:	3a5d                	addiw	s4,s4,-9
    80001330:	036a0063          	beq	s4,s6,80001350 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001334:	0149d933          	srl	s2,s3,s4
    80001338:	1ff97913          	andi	s2,s2,511
    8000133c:	090e                	slli	s2,s2,0x3
    8000133e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001340:	00093483          	ld	s1,0(s2)
    80001344:	0014f793          	andi	a5,s1,1
    80001348:	dfd5                	beqz	a5,80001304 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000134a:	80a9                	srli	s1,s1,0xa
    8000134c:	04b2                	slli	s1,s1,0xc
    8000134e:	b7c5                	j	8000132e <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001350:	00c9d513          	srli	a0,s3,0xc
    80001354:	1ff57513          	andi	a0,a0,511
    80001358:	050e                	slli	a0,a0,0x3
    8000135a:	9526                	add	a0,a0,s1
}
    8000135c:	70e2                	ld	ra,56(sp)
    8000135e:	7442                	ld	s0,48(sp)
    80001360:	74a2                	ld	s1,40(sp)
    80001362:	7902                	ld	s2,32(sp)
    80001364:	69e2                	ld	s3,24(sp)
    80001366:	6a42                	ld	s4,16(sp)
    80001368:	6aa2                	ld	s5,8(sp)
    8000136a:	6b02                	ld	s6,0(sp)
    8000136c:	6121                	addi	sp,sp,64
    8000136e:	8082                	ret
        return 0;
    80001370:	4501                	li	a0,0
    80001372:	b7ed                	j	8000135c <walk+0x8e>

0000000080001374 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001374:	57fd                	li	a5,-1
    80001376:	83e9                	srli	a5,a5,0x1a
    80001378:	00b7f463          	bgeu	a5,a1,80001380 <walkaddr+0xc>
    return 0;
    8000137c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000137e:	8082                	ret
{
    80001380:	1141                	addi	sp,sp,-16
    80001382:	e406                	sd	ra,8(sp)
    80001384:	e022                	sd	s0,0(sp)
    80001386:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001388:	4601                	li	a2,0
    8000138a:	00000097          	auipc	ra,0x0
    8000138e:	f44080e7          	jalr	-188(ra) # 800012ce <walk>
  if(pte == 0)
    80001392:	c105                	beqz	a0,800013b2 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001394:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001396:	0117f693          	andi	a3,a5,17
    8000139a:	4745                	li	a4,17
    return 0;
    8000139c:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000139e:	00e68663          	beq	a3,a4,800013aa <walkaddr+0x36>
}
    800013a2:	60a2                	ld	ra,8(sp)
    800013a4:	6402                	ld	s0,0(sp)
    800013a6:	0141                	addi	sp,sp,16
    800013a8:	8082                	ret
  pa = PTE2PA(*pte);
    800013aa:	00a7d513          	srli	a0,a5,0xa
    800013ae:	0532                	slli	a0,a0,0xc
  return pa;
    800013b0:	bfcd                	j	800013a2 <walkaddr+0x2e>
    return 0;
    800013b2:	4501                	li	a0,0
    800013b4:	b7fd                	j	800013a2 <walkaddr+0x2e>

00000000800013b6 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800013b6:	715d                	addi	sp,sp,-80
    800013b8:	e486                	sd	ra,72(sp)
    800013ba:	e0a2                	sd	s0,64(sp)
    800013bc:	fc26                	sd	s1,56(sp)
    800013be:	f84a                	sd	s2,48(sp)
    800013c0:	f44e                	sd	s3,40(sp)
    800013c2:	f052                	sd	s4,32(sp)
    800013c4:	ec56                	sd	s5,24(sp)
    800013c6:	e85a                	sd	s6,16(sp)
    800013c8:	e45e                	sd	s7,8(sp)
    800013ca:	0880                	addi	s0,sp,80
    800013cc:	8aaa                	mv	s5,a0
    800013ce:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800013d0:	777d                	lui	a4,0xfffff
    800013d2:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800013d6:	167d                	addi	a2,a2,-1
    800013d8:	00b609b3          	add	s3,a2,a1
    800013dc:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800013e0:	893e                	mv	s2,a5
    800013e2:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800013e6:	6b85                	lui	s7,0x1
    800013e8:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800013ec:	4605                	li	a2,1
    800013ee:	85ca                	mv	a1,s2
    800013f0:	8556                	mv	a0,s5
    800013f2:	00000097          	auipc	ra,0x0
    800013f6:	edc080e7          	jalr	-292(ra) # 800012ce <walk>
    800013fa:	c51d                	beqz	a0,80001428 <mappages+0x72>
    if(*pte & PTE_V)
    800013fc:	611c                	ld	a5,0(a0)
    800013fe:	8b85                	andi	a5,a5,1
    80001400:	ef81                	bnez	a5,80001418 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001402:	80b1                	srli	s1,s1,0xc
    80001404:	04aa                	slli	s1,s1,0xa
    80001406:	0164e4b3          	or	s1,s1,s6
    8000140a:	0014e493          	ori	s1,s1,1
    8000140e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001410:	03390863          	beq	s2,s3,80001440 <mappages+0x8a>
    a += PGSIZE;
    80001414:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001416:	bfc9                	j	800013e8 <mappages+0x32>
      panic("remap");
    80001418:	00008517          	auipc	a0,0x8
    8000141c:	db050513          	addi	a0,a0,-592 # 800091c8 <digits+0x178>
    80001420:	fffff097          	auipc	ra,0xfffff
    80001424:	10e080e7          	jalr	270(ra) # 8000052e <panic>
      return -1;
    80001428:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000142a:	60a6                	ld	ra,72(sp)
    8000142c:	6406                	ld	s0,64(sp)
    8000142e:	74e2                	ld	s1,56(sp)
    80001430:	7942                	ld	s2,48(sp)
    80001432:	79a2                	ld	s3,40(sp)
    80001434:	7a02                	ld	s4,32(sp)
    80001436:	6ae2                	ld	s5,24(sp)
    80001438:	6b42                	ld	s6,16(sp)
    8000143a:	6ba2                	ld	s7,8(sp)
    8000143c:	6161                	addi	sp,sp,80
    8000143e:	8082                	ret
  return 0;
    80001440:	4501                	li	a0,0
    80001442:	b7e5                	j	8000142a <mappages+0x74>

0000000080001444 <kvmmap>:
{
    80001444:	1141                	addi	sp,sp,-16
    80001446:	e406                	sd	ra,8(sp)
    80001448:	e022                	sd	s0,0(sp)
    8000144a:	0800                	addi	s0,sp,16
    8000144c:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000144e:	86b2                	mv	a3,a2
    80001450:	863e                	mv	a2,a5
    80001452:	00000097          	auipc	ra,0x0
    80001456:	f64080e7          	jalr	-156(ra) # 800013b6 <mappages>
    8000145a:	e509                	bnez	a0,80001464 <kvmmap+0x20>
}
    8000145c:	60a2                	ld	ra,8(sp)
    8000145e:	6402                	ld	s0,0(sp)
    80001460:	0141                	addi	sp,sp,16
    80001462:	8082                	ret
    panic("kvmmap");
    80001464:	00008517          	auipc	a0,0x8
    80001468:	d6c50513          	addi	a0,a0,-660 # 800091d0 <digits+0x180>
    8000146c:	fffff097          	auipc	ra,0xfffff
    80001470:	0c2080e7          	jalr	194(ra) # 8000052e <panic>

0000000080001474 <kvmmake>:
{
    80001474:	1101                	addi	sp,sp,-32
    80001476:	ec06                	sd	ra,24(sp)
    80001478:	e822                	sd	s0,16(sp)
    8000147a:	e426                	sd	s1,8(sp)
    8000147c:	e04a                	sd	s2,0(sp)
    8000147e:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001480:	fffff097          	auipc	ra,0xfffff
    80001484:	656080e7          	jalr	1622(ra) # 80000ad6 <kalloc>
    80001488:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000148a:	6605                	lui	a2,0x1
    8000148c:	4581                	li	a1,0
    8000148e:	00000097          	auipc	ra,0x0
    80001492:	b50080e7          	jalr	-1200(ra) # 80000fde <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001496:	4719                	li	a4,6
    80001498:	6685                	lui	a3,0x1
    8000149a:	10000637          	lui	a2,0x10000
    8000149e:	100005b7          	lui	a1,0x10000
    800014a2:	8526                	mv	a0,s1
    800014a4:	00000097          	auipc	ra,0x0
    800014a8:	fa0080e7          	jalr	-96(ra) # 80001444 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800014ac:	4719                	li	a4,6
    800014ae:	6685                	lui	a3,0x1
    800014b0:	10001637          	lui	a2,0x10001
    800014b4:	100015b7          	lui	a1,0x10001
    800014b8:	8526                	mv	a0,s1
    800014ba:	00000097          	auipc	ra,0x0
    800014be:	f8a080e7          	jalr	-118(ra) # 80001444 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800014c2:	4719                	li	a4,6
    800014c4:	004006b7          	lui	a3,0x400
    800014c8:	0c000637          	lui	a2,0xc000
    800014cc:	0c0005b7          	lui	a1,0xc000
    800014d0:	8526                	mv	a0,s1
    800014d2:	00000097          	auipc	ra,0x0
    800014d6:	f72080e7          	jalr	-142(ra) # 80001444 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800014da:	00008917          	auipc	s2,0x8
    800014de:	b2690913          	addi	s2,s2,-1242 # 80009000 <etext>
    800014e2:	4729                	li	a4,10
    800014e4:	80008697          	auipc	a3,0x80008
    800014e8:	b1c68693          	addi	a3,a3,-1252 # 9000 <_entry-0x7fff7000>
    800014ec:	4605                	li	a2,1
    800014ee:	067e                	slli	a2,a2,0x1f
    800014f0:	85b2                	mv	a1,a2
    800014f2:	8526                	mv	a0,s1
    800014f4:	00000097          	auipc	ra,0x0
    800014f8:	f50080e7          	jalr	-176(ra) # 80001444 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800014fc:	4719                	li	a4,6
    800014fe:	46c5                	li	a3,17
    80001500:	06ee                	slli	a3,a3,0x1b
    80001502:	412686b3          	sub	a3,a3,s2
    80001506:	864a                	mv	a2,s2
    80001508:	85ca                	mv	a1,s2
    8000150a:	8526                	mv	a0,s1
    8000150c:	00000097          	auipc	ra,0x0
    80001510:	f38080e7          	jalr	-200(ra) # 80001444 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001514:	4729                	li	a4,10
    80001516:	6685                	lui	a3,0x1
    80001518:	00007617          	auipc	a2,0x7
    8000151c:	ae860613          	addi	a2,a2,-1304 # 80008000 <_trampoline>
    80001520:	040005b7          	lui	a1,0x4000
    80001524:	15fd                	addi	a1,a1,-1
    80001526:	05b2                	slli	a1,a1,0xc
    80001528:	8526                	mv	a0,s1
    8000152a:	00000097          	auipc	ra,0x0
    8000152e:	f1a080e7          	jalr	-230(ra) # 80001444 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001532:	8526                	mv	a0,s1
    80001534:	00000097          	auipc	ra,0x0
    80001538:	600080e7          	jalr	1536(ra) # 80001b34 <proc_mapstacks>
}
    8000153c:	8526                	mv	a0,s1
    8000153e:	60e2                	ld	ra,24(sp)
    80001540:	6442                	ld	s0,16(sp)
    80001542:	64a2                	ld	s1,8(sp)
    80001544:	6902                	ld	s2,0(sp)
    80001546:	6105                	addi	sp,sp,32
    80001548:	8082                	ret

000000008000154a <kvminit>:
{
    8000154a:	1141                	addi	sp,sp,-16
    8000154c:	e406                	sd	ra,8(sp)
    8000154e:	e022                	sd	s0,0(sp)
    80001550:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001552:	00000097          	auipc	ra,0x0
    80001556:	f22080e7          	jalr	-222(ra) # 80001474 <kvmmake>
    8000155a:	00009797          	auipc	a5,0x9
    8000155e:	aca7b323          	sd	a0,-1338(a5) # 8000a020 <kernel_pagetable>
}
    80001562:	60a2                	ld	ra,8(sp)
    80001564:	6402                	ld	s0,0(sp)
    80001566:	0141                	addi	sp,sp,16
    80001568:	8082                	ret

000000008000156a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000156a:	715d                	addi	sp,sp,-80
    8000156c:	e486                	sd	ra,72(sp)
    8000156e:	e0a2                	sd	s0,64(sp)
    80001570:	fc26                	sd	s1,56(sp)
    80001572:	f84a                	sd	s2,48(sp)
    80001574:	f44e                	sd	s3,40(sp)
    80001576:	f052                	sd	s4,32(sp)
    80001578:	ec56                	sd	s5,24(sp)
    8000157a:	e85a                	sd	s6,16(sp)
    8000157c:	e45e                	sd	s7,8(sp)
    8000157e:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001580:	03459793          	slli	a5,a1,0x34
    80001584:	e795                	bnez	a5,800015b0 <uvmunmap+0x46>
    80001586:	8a2a                	mv	s4,a0
    80001588:	892e                	mv	s2,a1
    8000158a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000158c:	0632                	slli	a2,a2,0xc
    8000158e:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001592:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001594:	6b05                	lui	s6,0x1
    80001596:	0735e263          	bltu	a1,s3,800015fa <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000159a:	60a6                	ld	ra,72(sp)
    8000159c:	6406                	ld	s0,64(sp)
    8000159e:	74e2                	ld	s1,56(sp)
    800015a0:	7942                	ld	s2,48(sp)
    800015a2:	79a2                	ld	s3,40(sp)
    800015a4:	7a02                	ld	s4,32(sp)
    800015a6:	6ae2                	ld	s5,24(sp)
    800015a8:	6b42                	ld	s6,16(sp)
    800015aa:	6ba2                	ld	s7,8(sp)
    800015ac:	6161                	addi	sp,sp,80
    800015ae:	8082                	ret
    panic("uvmunmap: not aligned");
    800015b0:	00008517          	auipc	a0,0x8
    800015b4:	c2850513          	addi	a0,a0,-984 # 800091d8 <digits+0x188>
    800015b8:	fffff097          	auipc	ra,0xfffff
    800015bc:	f76080e7          	jalr	-138(ra) # 8000052e <panic>
      panic("uvmunmap: walk");
    800015c0:	00008517          	auipc	a0,0x8
    800015c4:	c3050513          	addi	a0,a0,-976 # 800091f0 <digits+0x1a0>
    800015c8:	fffff097          	auipc	ra,0xfffff
    800015cc:	f66080e7          	jalr	-154(ra) # 8000052e <panic>
      panic("uvmunmap: not mapped");
    800015d0:	00008517          	auipc	a0,0x8
    800015d4:	c3050513          	addi	a0,a0,-976 # 80009200 <digits+0x1b0>
    800015d8:	fffff097          	auipc	ra,0xfffff
    800015dc:	f56080e7          	jalr	-170(ra) # 8000052e <panic>
      panic("uvmunmap: not a leaf");
    800015e0:	00008517          	auipc	a0,0x8
    800015e4:	c3850513          	addi	a0,a0,-968 # 80009218 <digits+0x1c8>
    800015e8:	fffff097          	auipc	ra,0xfffff
    800015ec:	f46080e7          	jalr	-186(ra) # 8000052e <panic>
    *pte = 0;
    800015f0:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800015f4:	995a                	add	s2,s2,s6
    800015f6:	fb3972e3          	bgeu	s2,s3,8000159a <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800015fa:	4601                	li	a2,0
    800015fc:	85ca                	mv	a1,s2
    800015fe:	8552                	mv	a0,s4
    80001600:	00000097          	auipc	ra,0x0
    80001604:	cce080e7          	jalr	-818(ra) # 800012ce <walk>
    80001608:	84aa                	mv	s1,a0
    8000160a:	d95d                	beqz	a0,800015c0 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000160c:	6108                	ld	a0,0(a0)
    8000160e:	00157793          	andi	a5,a0,1
    80001612:	dfdd                	beqz	a5,800015d0 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001614:	3ff57793          	andi	a5,a0,1023
    80001618:	fd7784e3          	beq	a5,s7,800015e0 <uvmunmap+0x76>
    if(do_free){
    8000161c:	fc0a8ae3          	beqz	s5,800015f0 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001620:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001622:	0532                	slli	a0,a0,0xc
    80001624:	fffff097          	auipc	ra,0xfffff
    80001628:	3b6080e7          	jalr	950(ra) # 800009da <kfree>
    8000162c:	b7d1                	j	800015f0 <uvmunmap+0x86>

000000008000162e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000162e:	1101                	addi	sp,sp,-32
    80001630:	ec06                	sd	ra,24(sp)
    80001632:	e822                	sd	s0,16(sp)
    80001634:	e426                	sd	s1,8(sp)
    80001636:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001638:	fffff097          	auipc	ra,0xfffff
    8000163c:	49e080e7          	jalr	1182(ra) # 80000ad6 <kalloc>
    80001640:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001642:	c519                	beqz	a0,80001650 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001644:	6605                	lui	a2,0x1
    80001646:	4581                	li	a1,0
    80001648:	00000097          	auipc	ra,0x0
    8000164c:	996080e7          	jalr	-1642(ra) # 80000fde <memset>
  return pagetable;
}
    80001650:	8526                	mv	a0,s1
    80001652:	60e2                	ld	ra,24(sp)
    80001654:	6442                	ld	s0,16(sp)
    80001656:	64a2                	ld	s1,8(sp)
    80001658:	6105                	addi	sp,sp,32
    8000165a:	8082                	ret

000000008000165c <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000165c:	7179                	addi	sp,sp,-48
    8000165e:	f406                	sd	ra,40(sp)
    80001660:	f022                	sd	s0,32(sp)
    80001662:	ec26                	sd	s1,24(sp)
    80001664:	e84a                	sd	s2,16(sp)
    80001666:	e44e                	sd	s3,8(sp)
    80001668:	e052                	sd	s4,0(sp)
    8000166a:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000166c:	6785                	lui	a5,0x1
    8000166e:	04f67863          	bgeu	a2,a5,800016be <uvminit+0x62>
    80001672:	8a2a                	mv	s4,a0
    80001674:	89ae                	mv	s3,a1
    80001676:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001678:	fffff097          	auipc	ra,0xfffff
    8000167c:	45e080e7          	jalr	1118(ra) # 80000ad6 <kalloc>
    80001680:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001682:	6605                	lui	a2,0x1
    80001684:	4581                	li	a1,0
    80001686:	00000097          	auipc	ra,0x0
    8000168a:	958080e7          	jalr	-1704(ra) # 80000fde <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000168e:	4779                	li	a4,30
    80001690:	86ca                	mv	a3,s2
    80001692:	6605                	lui	a2,0x1
    80001694:	4581                	li	a1,0
    80001696:	8552                	mv	a0,s4
    80001698:	00000097          	auipc	ra,0x0
    8000169c:	d1e080e7          	jalr	-738(ra) # 800013b6 <mappages>
  memmove(mem, src, sz);
    800016a0:	8626                	mv	a2,s1
    800016a2:	85ce                	mv	a1,s3
    800016a4:	854a                	mv	a0,s2
    800016a6:	00000097          	auipc	ra,0x0
    800016aa:	994080e7          	jalr	-1644(ra) # 8000103a <memmove>
}
    800016ae:	70a2                	ld	ra,40(sp)
    800016b0:	7402                	ld	s0,32(sp)
    800016b2:	64e2                	ld	s1,24(sp)
    800016b4:	6942                	ld	s2,16(sp)
    800016b6:	69a2                	ld	s3,8(sp)
    800016b8:	6a02                	ld	s4,0(sp)
    800016ba:	6145                	addi	sp,sp,48
    800016bc:	8082                	ret
    panic("inituvm: more than a page");
    800016be:	00008517          	auipc	a0,0x8
    800016c2:	b7250513          	addi	a0,a0,-1166 # 80009230 <digits+0x1e0>
    800016c6:	fffff097          	auipc	ra,0xfffff
    800016ca:	e68080e7          	jalr	-408(ra) # 8000052e <panic>

00000000800016ce <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800016ce:	1101                	addi	sp,sp,-32
    800016d0:	ec06                	sd	ra,24(sp)
    800016d2:	e822                	sd	s0,16(sp)
    800016d4:	e426                	sd	s1,8(sp)
    800016d6:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800016d8:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800016da:	00b67d63          	bgeu	a2,a1,800016f4 <uvmdealloc+0x26>
    800016de:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800016e0:	6785                	lui	a5,0x1
    800016e2:	17fd                	addi	a5,a5,-1
    800016e4:	00f60733          	add	a4,a2,a5
    800016e8:	767d                	lui	a2,0xfffff
    800016ea:	8f71                	and	a4,a4,a2
    800016ec:	97ae                	add	a5,a5,a1
    800016ee:	8ff1                	and	a5,a5,a2
    800016f0:	00f76863          	bltu	a4,a5,80001700 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800016f4:	8526                	mv	a0,s1
    800016f6:	60e2                	ld	ra,24(sp)
    800016f8:	6442                	ld	s0,16(sp)
    800016fa:	64a2                	ld	s1,8(sp)
    800016fc:	6105                	addi	sp,sp,32
    800016fe:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001700:	8f99                	sub	a5,a5,a4
    80001702:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001704:	4685                	li	a3,1
    80001706:	0007861b          	sext.w	a2,a5
    8000170a:	85ba                	mv	a1,a4
    8000170c:	00000097          	auipc	ra,0x0
    80001710:	e5e080e7          	jalr	-418(ra) # 8000156a <uvmunmap>
    80001714:	b7c5                	j	800016f4 <uvmdealloc+0x26>

0000000080001716 <uvmalloc>:
  if(newsz < oldsz)
    80001716:	0ab66163          	bltu	a2,a1,800017b8 <uvmalloc+0xa2>
{
    8000171a:	7139                	addi	sp,sp,-64
    8000171c:	fc06                	sd	ra,56(sp)
    8000171e:	f822                	sd	s0,48(sp)
    80001720:	f426                	sd	s1,40(sp)
    80001722:	f04a                	sd	s2,32(sp)
    80001724:	ec4e                	sd	s3,24(sp)
    80001726:	e852                	sd	s4,16(sp)
    80001728:	e456                	sd	s5,8(sp)
    8000172a:	0080                	addi	s0,sp,64
    8000172c:	8aaa                	mv	s5,a0
    8000172e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001730:	6985                	lui	s3,0x1
    80001732:	19fd                	addi	s3,s3,-1
    80001734:	95ce                	add	a1,a1,s3
    80001736:	79fd                	lui	s3,0xfffff
    80001738:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000173c:	08c9f063          	bgeu	s3,a2,800017bc <uvmalloc+0xa6>
    80001740:	894e                	mv	s2,s3
    mem = kalloc();
    80001742:	fffff097          	auipc	ra,0xfffff
    80001746:	394080e7          	jalr	916(ra) # 80000ad6 <kalloc>
    8000174a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000174c:	c51d                	beqz	a0,8000177a <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000174e:	6605                	lui	a2,0x1
    80001750:	4581                	li	a1,0
    80001752:	00000097          	auipc	ra,0x0
    80001756:	88c080e7          	jalr	-1908(ra) # 80000fde <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000175a:	4779                	li	a4,30
    8000175c:	86a6                	mv	a3,s1
    8000175e:	6605                	lui	a2,0x1
    80001760:	85ca                	mv	a1,s2
    80001762:	8556                	mv	a0,s5
    80001764:	00000097          	auipc	ra,0x0
    80001768:	c52080e7          	jalr	-942(ra) # 800013b6 <mappages>
    8000176c:	e905                	bnez	a0,8000179c <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000176e:	6785                	lui	a5,0x1
    80001770:	993e                	add	s2,s2,a5
    80001772:	fd4968e3          	bltu	s2,s4,80001742 <uvmalloc+0x2c>
  return newsz;
    80001776:	8552                	mv	a0,s4
    80001778:	a809                	j	8000178a <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000177a:	864e                	mv	a2,s3
    8000177c:	85ca                	mv	a1,s2
    8000177e:	8556                	mv	a0,s5
    80001780:	00000097          	auipc	ra,0x0
    80001784:	f4e080e7          	jalr	-178(ra) # 800016ce <uvmdealloc>
      return 0;
    80001788:	4501                	li	a0,0
}
    8000178a:	70e2                	ld	ra,56(sp)
    8000178c:	7442                	ld	s0,48(sp)
    8000178e:	74a2                	ld	s1,40(sp)
    80001790:	7902                	ld	s2,32(sp)
    80001792:	69e2                	ld	s3,24(sp)
    80001794:	6a42                	ld	s4,16(sp)
    80001796:	6aa2                	ld	s5,8(sp)
    80001798:	6121                	addi	sp,sp,64
    8000179a:	8082                	ret
      kfree(mem);
    8000179c:	8526                	mv	a0,s1
    8000179e:	fffff097          	auipc	ra,0xfffff
    800017a2:	23c080e7          	jalr	572(ra) # 800009da <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800017a6:	864e                	mv	a2,s3
    800017a8:	85ca                	mv	a1,s2
    800017aa:	8556                	mv	a0,s5
    800017ac:	00000097          	auipc	ra,0x0
    800017b0:	f22080e7          	jalr	-222(ra) # 800016ce <uvmdealloc>
      return 0;
    800017b4:	4501                	li	a0,0
    800017b6:	bfd1                	j	8000178a <uvmalloc+0x74>
    return oldsz;
    800017b8:	852e                	mv	a0,a1
}
    800017ba:	8082                	ret
  return newsz;
    800017bc:	8532                	mv	a0,a2
    800017be:	b7f1                	j	8000178a <uvmalloc+0x74>

00000000800017c0 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800017c0:	7179                	addi	sp,sp,-48
    800017c2:	f406                	sd	ra,40(sp)
    800017c4:	f022                	sd	s0,32(sp)
    800017c6:	ec26                	sd	s1,24(sp)
    800017c8:	e84a                	sd	s2,16(sp)
    800017ca:	e44e                	sd	s3,8(sp)
    800017cc:	e052                	sd	s4,0(sp)
    800017ce:	1800                	addi	s0,sp,48
    800017d0:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800017d2:	84aa                	mv	s1,a0
    800017d4:	6905                	lui	s2,0x1
    800017d6:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800017d8:	4985                	li	s3,1
    800017da:	a821                	j	800017f2 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800017dc:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800017de:	0532                	slli	a0,a0,0xc
    800017e0:	00000097          	auipc	ra,0x0
    800017e4:	fe0080e7          	jalr	-32(ra) # 800017c0 <freewalk>
      pagetable[i] = 0;
    800017e8:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800017ec:	04a1                	addi	s1,s1,8
    800017ee:	03248163          	beq	s1,s2,80001810 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800017f2:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800017f4:	00f57793          	andi	a5,a0,15
    800017f8:	ff3782e3          	beq	a5,s3,800017dc <freewalk+0x1c>
    } else if(pte & PTE_V){
    800017fc:	8905                	andi	a0,a0,1
    800017fe:	d57d                	beqz	a0,800017ec <freewalk+0x2c>
      panic("freewalk: leaf");
    80001800:	00008517          	auipc	a0,0x8
    80001804:	a5050513          	addi	a0,a0,-1456 # 80009250 <digits+0x200>
    80001808:	fffff097          	auipc	ra,0xfffff
    8000180c:	d26080e7          	jalr	-730(ra) # 8000052e <panic>
    }
  }
  kfree((void*)pagetable);
    80001810:	8552                	mv	a0,s4
    80001812:	fffff097          	auipc	ra,0xfffff
    80001816:	1c8080e7          	jalr	456(ra) # 800009da <kfree>
}
    8000181a:	70a2                	ld	ra,40(sp)
    8000181c:	7402                	ld	s0,32(sp)
    8000181e:	64e2                	ld	s1,24(sp)
    80001820:	6942                	ld	s2,16(sp)
    80001822:	69a2                	ld	s3,8(sp)
    80001824:	6a02                	ld	s4,0(sp)
    80001826:	6145                	addi	sp,sp,48
    80001828:	8082                	ret

000000008000182a <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000182a:	1101                	addi	sp,sp,-32
    8000182c:	ec06                	sd	ra,24(sp)
    8000182e:	e822                	sd	s0,16(sp)
    80001830:	e426                	sd	s1,8(sp)
    80001832:	1000                	addi	s0,sp,32
    80001834:	84aa                	mv	s1,a0
  if(sz > 0)
    80001836:	e999                	bnez	a1,8000184c <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001838:	8526                	mv	a0,s1
    8000183a:	00000097          	auipc	ra,0x0
    8000183e:	f86080e7          	jalr	-122(ra) # 800017c0 <freewalk>
}
    80001842:	60e2                	ld	ra,24(sp)
    80001844:	6442                	ld	s0,16(sp)
    80001846:	64a2                	ld	s1,8(sp)
    80001848:	6105                	addi	sp,sp,32
    8000184a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000184c:	6605                	lui	a2,0x1
    8000184e:	167d                	addi	a2,a2,-1
    80001850:	962e                	add	a2,a2,a1
    80001852:	4685                	li	a3,1
    80001854:	8231                	srli	a2,a2,0xc
    80001856:	4581                	li	a1,0
    80001858:	00000097          	auipc	ra,0x0
    8000185c:	d12080e7          	jalr	-750(ra) # 8000156a <uvmunmap>
    80001860:	bfe1                	j	80001838 <uvmfree+0xe>

0000000080001862 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001862:	c679                	beqz	a2,80001930 <uvmcopy+0xce>
{
    80001864:	715d                	addi	sp,sp,-80
    80001866:	e486                	sd	ra,72(sp)
    80001868:	e0a2                	sd	s0,64(sp)
    8000186a:	fc26                	sd	s1,56(sp)
    8000186c:	f84a                	sd	s2,48(sp)
    8000186e:	f44e                	sd	s3,40(sp)
    80001870:	f052                	sd	s4,32(sp)
    80001872:	ec56                	sd	s5,24(sp)
    80001874:	e85a                	sd	s6,16(sp)
    80001876:	e45e                	sd	s7,8(sp)
    80001878:	0880                	addi	s0,sp,80
    8000187a:	8b2a                	mv	s6,a0
    8000187c:	8aae                	mv	s5,a1
    8000187e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001880:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001882:	4601                	li	a2,0
    80001884:	85ce                	mv	a1,s3
    80001886:	855a                	mv	a0,s6
    80001888:	00000097          	auipc	ra,0x0
    8000188c:	a46080e7          	jalr	-1466(ra) # 800012ce <walk>
    80001890:	c531                	beqz	a0,800018dc <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001892:	6118                	ld	a4,0(a0)
    80001894:	00177793          	andi	a5,a4,1
    80001898:	cbb1                	beqz	a5,800018ec <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000189a:	00a75593          	srli	a1,a4,0xa
    8000189e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800018a2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800018a6:	fffff097          	auipc	ra,0xfffff
    800018aa:	230080e7          	jalr	560(ra) # 80000ad6 <kalloc>
    800018ae:	892a                	mv	s2,a0
    800018b0:	c939                	beqz	a0,80001906 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800018b2:	6605                	lui	a2,0x1
    800018b4:	85de                	mv	a1,s7
    800018b6:	fffff097          	auipc	ra,0xfffff
    800018ba:	784080e7          	jalr	1924(ra) # 8000103a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800018be:	8726                	mv	a4,s1
    800018c0:	86ca                	mv	a3,s2
    800018c2:	6605                	lui	a2,0x1
    800018c4:	85ce                	mv	a1,s3
    800018c6:	8556                	mv	a0,s5
    800018c8:	00000097          	auipc	ra,0x0
    800018cc:	aee080e7          	jalr	-1298(ra) # 800013b6 <mappages>
    800018d0:	e515                	bnez	a0,800018fc <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800018d2:	6785                	lui	a5,0x1
    800018d4:	99be                	add	s3,s3,a5
    800018d6:	fb49e6e3          	bltu	s3,s4,80001882 <uvmcopy+0x20>
    800018da:	a081                	j	8000191a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800018dc:	00008517          	auipc	a0,0x8
    800018e0:	98450513          	addi	a0,a0,-1660 # 80009260 <digits+0x210>
    800018e4:	fffff097          	auipc	ra,0xfffff
    800018e8:	c4a080e7          	jalr	-950(ra) # 8000052e <panic>
      panic("uvmcopy: page not present");
    800018ec:	00008517          	auipc	a0,0x8
    800018f0:	99450513          	addi	a0,a0,-1644 # 80009280 <digits+0x230>
    800018f4:	fffff097          	auipc	ra,0xfffff
    800018f8:	c3a080e7          	jalr	-966(ra) # 8000052e <panic>
      kfree(mem);
    800018fc:	854a                	mv	a0,s2
    800018fe:	fffff097          	auipc	ra,0xfffff
    80001902:	0dc080e7          	jalr	220(ra) # 800009da <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001906:	4685                	li	a3,1
    80001908:	00c9d613          	srli	a2,s3,0xc
    8000190c:	4581                	li	a1,0
    8000190e:	8556                	mv	a0,s5
    80001910:	00000097          	auipc	ra,0x0
    80001914:	c5a080e7          	jalr	-934(ra) # 8000156a <uvmunmap>
  return -1;
    80001918:	557d                	li	a0,-1
}
    8000191a:	60a6                	ld	ra,72(sp)
    8000191c:	6406                	ld	s0,64(sp)
    8000191e:	74e2                	ld	s1,56(sp)
    80001920:	7942                	ld	s2,48(sp)
    80001922:	79a2                	ld	s3,40(sp)
    80001924:	7a02                	ld	s4,32(sp)
    80001926:	6ae2                	ld	s5,24(sp)
    80001928:	6b42                	ld	s6,16(sp)
    8000192a:	6ba2                	ld	s7,8(sp)
    8000192c:	6161                	addi	sp,sp,80
    8000192e:	8082                	ret
  return 0;
    80001930:	4501                	li	a0,0
}
    80001932:	8082                	ret

0000000080001934 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001934:	1141                	addi	sp,sp,-16
    80001936:	e406                	sd	ra,8(sp)
    80001938:	e022                	sd	s0,0(sp)
    8000193a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000193c:	4601                	li	a2,0
    8000193e:	00000097          	auipc	ra,0x0
    80001942:	990080e7          	jalr	-1648(ra) # 800012ce <walk>
  if(pte == 0)
    80001946:	c901                	beqz	a0,80001956 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001948:	611c                	ld	a5,0(a0)
    8000194a:	9bbd                	andi	a5,a5,-17
    8000194c:	e11c                	sd	a5,0(a0)
}
    8000194e:	60a2                	ld	ra,8(sp)
    80001950:	6402                	ld	s0,0(sp)
    80001952:	0141                	addi	sp,sp,16
    80001954:	8082                	ret
    panic("uvmclear");
    80001956:	00008517          	auipc	a0,0x8
    8000195a:	94a50513          	addi	a0,a0,-1718 # 800092a0 <digits+0x250>
    8000195e:	fffff097          	auipc	ra,0xfffff
    80001962:	bd0080e7          	jalr	-1072(ra) # 8000052e <panic>

0000000080001966 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001966:	c6bd                	beqz	a3,800019d4 <copyout+0x6e>
{
    80001968:	715d                	addi	sp,sp,-80
    8000196a:	e486                	sd	ra,72(sp)
    8000196c:	e0a2                	sd	s0,64(sp)
    8000196e:	fc26                	sd	s1,56(sp)
    80001970:	f84a                	sd	s2,48(sp)
    80001972:	f44e                	sd	s3,40(sp)
    80001974:	f052                	sd	s4,32(sp)
    80001976:	ec56                	sd	s5,24(sp)
    80001978:	e85a                	sd	s6,16(sp)
    8000197a:	e45e                	sd	s7,8(sp)
    8000197c:	e062                	sd	s8,0(sp)
    8000197e:	0880                	addi	s0,sp,80
    80001980:	8b2a                	mv	s6,a0
    80001982:	8c2e                	mv	s8,a1
    80001984:	8a32                	mv	s4,a2
    80001986:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001988:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000198a:	6a85                	lui	s5,0x1
    8000198c:	a015                	j	800019b0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000198e:	9562                	add	a0,a0,s8
    80001990:	0004861b          	sext.w	a2,s1
    80001994:	85d2                	mv	a1,s4
    80001996:	41250533          	sub	a0,a0,s2
    8000199a:	fffff097          	auipc	ra,0xfffff
    8000199e:	6a0080e7          	jalr	1696(ra) # 8000103a <memmove>

    len -= n;
    800019a2:	409989b3          	sub	s3,s3,s1
    src += n;
    800019a6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800019a8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800019ac:	02098263          	beqz	s3,800019d0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800019b0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800019b4:	85ca                	mv	a1,s2
    800019b6:	855a                	mv	a0,s6
    800019b8:	00000097          	auipc	ra,0x0
    800019bc:	9bc080e7          	jalr	-1604(ra) # 80001374 <walkaddr>
    if(pa0 == 0)
    800019c0:	cd01                	beqz	a0,800019d8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800019c2:	418904b3          	sub	s1,s2,s8
    800019c6:	94d6                	add	s1,s1,s5
    if(n > len)
    800019c8:	fc99f3e3          	bgeu	s3,s1,8000198e <copyout+0x28>
    800019cc:	84ce                	mv	s1,s3
    800019ce:	b7c1                	j	8000198e <copyout+0x28>
  }
  return 0;
    800019d0:	4501                	li	a0,0
    800019d2:	a021                	j	800019da <copyout+0x74>
    800019d4:	4501                	li	a0,0
}
    800019d6:	8082                	ret
      return -1;
    800019d8:	557d                	li	a0,-1
}
    800019da:	60a6                	ld	ra,72(sp)
    800019dc:	6406                	ld	s0,64(sp)
    800019de:	74e2                	ld	s1,56(sp)
    800019e0:	7942                	ld	s2,48(sp)
    800019e2:	79a2                	ld	s3,40(sp)
    800019e4:	7a02                	ld	s4,32(sp)
    800019e6:	6ae2                	ld	s5,24(sp)
    800019e8:	6b42                	ld	s6,16(sp)
    800019ea:	6ba2                	ld	s7,8(sp)
    800019ec:	6c02                	ld	s8,0(sp)
    800019ee:	6161                	addi	sp,sp,80
    800019f0:	8082                	ret

00000000800019f2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800019f2:	caa5                	beqz	a3,80001a62 <copyin+0x70>
{
    800019f4:	715d                	addi	sp,sp,-80
    800019f6:	e486                	sd	ra,72(sp)
    800019f8:	e0a2                	sd	s0,64(sp)
    800019fa:	fc26                	sd	s1,56(sp)
    800019fc:	f84a                	sd	s2,48(sp)
    800019fe:	f44e                	sd	s3,40(sp)
    80001a00:	f052                	sd	s4,32(sp)
    80001a02:	ec56                	sd	s5,24(sp)
    80001a04:	e85a                	sd	s6,16(sp)
    80001a06:	e45e                	sd	s7,8(sp)
    80001a08:	e062                	sd	s8,0(sp)
    80001a0a:	0880                	addi	s0,sp,80
    80001a0c:	8b2a                	mv	s6,a0
    80001a0e:	8a2e                	mv	s4,a1
    80001a10:	8c32                	mv	s8,a2
    80001a12:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001a14:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001a16:	6a85                	lui	s5,0x1
    80001a18:	a01d                	j	80001a3e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001a1a:	018505b3          	add	a1,a0,s8
    80001a1e:	0004861b          	sext.w	a2,s1
    80001a22:	412585b3          	sub	a1,a1,s2
    80001a26:	8552                	mv	a0,s4
    80001a28:	fffff097          	auipc	ra,0xfffff
    80001a2c:	612080e7          	jalr	1554(ra) # 8000103a <memmove>

    len -= n;
    80001a30:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001a34:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001a36:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001a3a:	02098263          	beqz	s3,80001a5e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001a3e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001a42:	85ca                	mv	a1,s2
    80001a44:	855a                	mv	a0,s6
    80001a46:	00000097          	auipc	ra,0x0
    80001a4a:	92e080e7          	jalr	-1746(ra) # 80001374 <walkaddr>
    if(pa0 == 0)
    80001a4e:	cd01                	beqz	a0,80001a66 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001a50:	418904b3          	sub	s1,s2,s8
    80001a54:	94d6                	add	s1,s1,s5
    if(n > len)
    80001a56:	fc99f2e3          	bgeu	s3,s1,80001a1a <copyin+0x28>
    80001a5a:	84ce                	mv	s1,s3
    80001a5c:	bf7d                	j	80001a1a <copyin+0x28>
  }
  return 0;
    80001a5e:	4501                	li	a0,0
    80001a60:	a021                	j	80001a68 <copyin+0x76>
    80001a62:	4501                	li	a0,0
}
    80001a64:	8082                	ret
      return -1;
    80001a66:	557d                	li	a0,-1
}
    80001a68:	60a6                	ld	ra,72(sp)
    80001a6a:	6406                	ld	s0,64(sp)
    80001a6c:	74e2                	ld	s1,56(sp)
    80001a6e:	7942                	ld	s2,48(sp)
    80001a70:	79a2                	ld	s3,40(sp)
    80001a72:	7a02                	ld	s4,32(sp)
    80001a74:	6ae2                	ld	s5,24(sp)
    80001a76:	6b42                	ld	s6,16(sp)
    80001a78:	6ba2                	ld	s7,8(sp)
    80001a7a:	6c02                	ld	s8,0(sp)
    80001a7c:	6161                	addi	sp,sp,80
    80001a7e:	8082                	ret

0000000080001a80 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001a80:	c6c5                	beqz	a3,80001b28 <copyinstr+0xa8>
{
    80001a82:	715d                	addi	sp,sp,-80
    80001a84:	e486                	sd	ra,72(sp)
    80001a86:	e0a2                	sd	s0,64(sp)
    80001a88:	fc26                	sd	s1,56(sp)
    80001a8a:	f84a                	sd	s2,48(sp)
    80001a8c:	f44e                	sd	s3,40(sp)
    80001a8e:	f052                	sd	s4,32(sp)
    80001a90:	ec56                	sd	s5,24(sp)
    80001a92:	e85a                	sd	s6,16(sp)
    80001a94:	e45e                	sd	s7,8(sp)
    80001a96:	0880                	addi	s0,sp,80
    80001a98:	8a2a                	mv	s4,a0
    80001a9a:	8b2e                	mv	s6,a1
    80001a9c:	8bb2                	mv	s7,a2
    80001a9e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001aa0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001aa2:	6985                	lui	s3,0x1
    80001aa4:	a035                	j	80001ad0 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001aa6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001aaa:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001aac:	0017b793          	seqz	a5,a5
    80001ab0:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001ab4:	60a6                	ld	ra,72(sp)
    80001ab6:	6406                	ld	s0,64(sp)
    80001ab8:	74e2                	ld	s1,56(sp)
    80001aba:	7942                	ld	s2,48(sp)
    80001abc:	79a2                	ld	s3,40(sp)
    80001abe:	7a02                	ld	s4,32(sp)
    80001ac0:	6ae2                	ld	s5,24(sp)
    80001ac2:	6b42                	ld	s6,16(sp)
    80001ac4:	6ba2                	ld	s7,8(sp)
    80001ac6:	6161                	addi	sp,sp,80
    80001ac8:	8082                	ret
    srcva = va0 + PGSIZE;
    80001aca:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001ace:	c8a9                	beqz	s1,80001b20 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001ad0:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001ad4:	85ca                	mv	a1,s2
    80001ad6:	8552                	mv	a0,s4
    80001ad8:	00000097          	auipc	ra,0x0
    80001adc:	89c080e7          	jalr	-1892(ra) # 80001374 <walkaddr>
    if(pa0 == 0)
    80001ae0:	c131                	beqz	a0,80001b24 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001ae2:	41790833          	sub	a6,s2,s7
    80001ae6:	984e                	add	a6,a6,s3
    if(n > max)
    80001ae8:	0104f363          	bgeu	s1,a6,80001aee <copyinstr+0x6e>
    80001aec:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001aee:	955e                	add	a0,a0,s7
    80001af0:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001af4:	fc080be3          	beqz	a6,80001aca <copyinstr+0x4a>
    80001af8:	985a                	add	a6,a6,s6
    80001afa:	87da                	mv	a5,s6
      if(*p == '\0'){
    80001afc:	41650633          	sub	a2,a0,s6
    80001b00:	14fd                	addi	s1,s1,-1
    80001b02:	9b26                	add	s6,s6,s1
    80001b04:	00f60733          	add	a4,a2,a5
    80001b08:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffbc000>
    80001b0c:	df49                	beqz	a4,80001aa6 <copyinstr+0x26>
        *dst = *p;
    80001b0e:	00e78023          	sb	a4,0(a5)
      --max;
    80001b12:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001b16:	0785                	addi	a5,a5,1
    while(n > 0){
    80001b18:	ff0796e3          	bne	a5,a6,80001b04 <copyinstr+0x84>
      dst++;
    80001b1c:	8b42                	mv	s6,a6
    80001b1e:	b775                	j	80001aca <copyinstr+0x4a>
    80001b20:	4781                	li	a5,0
    80001b22:	b769                	j	80001aac <copyinstr+0x2c>
      return -1;
    80001b24:	557d                	li	a0,-1
    80001b26:	b779                	j	80001ab4 <copyinstr+0x34>
  int got_null = 0;
    80001b28:	4781                	li	a5,0
  if(got_null){
    80001b2a:	0017b793          	seqz	a5,a5
    80001b2e:	40f00533          	neg	a0,a5
}
    80001b32:	8082                	ret

0000000080001b34 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001b34:	711d                	addi	sp,sp,-96
    80001b36:	ec86                	sd	ra,88(sp)
    80001b38:	e8a2                	sd	s0,80(sp)
    80001b3a:	e4a6                	sd	s1,72(sp)
    80001b3c:	e0ca                	sd	s2,64(sp)
    80001b3e:	fc4e                	sd	s3,56(sp)
    80001b40:	f852                	sd	s4,48(sp)
    80001b42:	f456                	sd	s5,40(sp)
    80001b44:	f05a                	sd	s6,32(sp)
    80001b46:	ec5e                	sd	s7,24(sp)
    80001b48:	e862                	sd	s8,16(sp)
    80001b4a:	e466                	sd	s9,8(sp)
    80001b4c:	e06a                	sd	s10,0(sp)
    80001b4e:	1080                	addi	s0,sp,96
    80001b50:	8b2a                	mv	s6,a0
  struct proc *p;
  struct kthread *t;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001b52:	00013997          	auipc	s3,0x13
    80001b56:	81e98993          	addi	s3,s3,-2018 # 80014370 <proc+0x848>
    80001b5a:	00034d17          	auipc	s10,0x34
    80001b5e:	a16d0d13          	addi	s10,s10,-1514 # 80035570 <bcache+0x830>
    int proc_index= (int)(p-proc);
    80001b62:	7c7d                	lui	s8,0xfffff
    80001b64:	7b8c0c13          	addi	s8,s8,1976 # fffffffffffff7b8 <end+0xffffffff7ffbc7b8>
    80001b68:	00007c97          	auipc	s9,0x7
    80001b6c:	4a0cbc83          	ld	s9,1184(s9) # 80009008 <etext+0x8>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      int thread_index = (int)(t-p->kthreads);
    80001b70:	00007b97          	auipc	s7,0x7
    80001b74:	4a0b8b93          	addi	s7,s7,1184 # 80009010 <etext+0x10>
      uint64 va = KSTACK( proc_index * NTHREAD + thread_index);
    80001b78:	04000ab7          	lui	s5,0x4000
    80001b7c:	1afd                	addi	s5,s5,-1
    80001b7e:	0ab2                	slli	s5,s5,0xc
    80001b80:	a839                	j	80001b9e <proc_mapstacks+0x6a>
        panic("kalloc");
    80001b82:	00007517          	auipc	a0,0x7
    80001b86:	72e50513          	addi	a0,a0,1838 # 800092b0 <digits+0x260>
    80001b8a:	fffff097          	auipc	ra,0xfffff
    80001b8e:	9a4080e7          	jalr	-1628(ra) # 8000052e <panic>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b92:	6785                	lui	a5,0x1
    80001b94:	84878793          	addi	a5,a5,-1976 # 848 <_entry-0x7ffff7b8>
    80001b98:	99be                	add	s3,s3,a5
    80001b9a:	07a98363          	beq	s3,s10,80001c00 <proc_mapstacks+0xcc>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001b9e:	a4098a13          	addi	s4,s3,-1472
    int proc_index= (int)(p-proc);
    80001ba2:	01898933          	add	s2,s3,s8
    80001ba6:	00012797          	auipc	a5,0x12
    80001baa:	f8278793          	addi	a5,a5,-126 # 80013b28 <proc>
    80001bae:	40f90933          	sub	s2,s2,a5
    80001bb2:	40395913          	srai	s2,s2,0x3
    80001bb6:	03990933          	mul	s2,s2,s9
    80001bba:	0039191b          	slliw	s2,s2,0x3
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001bbe:	84d2                	mv	s1,s4
      char *pa = kalloc();
    80001bc0:	fffff097          	auipc	ra,0xfffff
    80001bc4:	f16080e7          	jalr	-234(ra) # 80000ad6 <kalloc>
    80001bc8:	862a                	mv	a2,a0
      if(pa == 0)
    80001bca:	dd45                	beqz	a0,80001b82 <proc_mapstacks+0x4e>
      int thread_index = (int)(t-p->kthreads);
    80001bcc:	414485b3          	sub	a1,s1,s4
    80001bd0:	858d                	srai	a1,a1,0x3
    80001bd2:	000bb783          	ld	a5,0(s7)
    80001bd6:	02f585b3          	mul	a1,a1,a5
      uint64 va = KSTACK( proc_index * NTHREAD + thread_index);
    80001bda:	012585bb          	addw	a1,a1,s2
    80001bde:	2585                	addiw	a1,a1,1
    80001be0:	00d5959b          	slliw	a1,a1,0xd
      kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001be4:	4719                	li	a4,6
    80001be6:	6685                	lui	a3,0x1
    80001be8:	40ba85b3          	sub	a1,s5,a1
    80001bec:	855a                	mv	a0,s6
    80001bee:	00000097          	auipc	ra,0x0
    80001bf2:	856080e7          	jalr	-1962(ra) # 80001444 <kvmmap>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001bf6:	0b848493          	addi	s1,s1,184
    80001bfa:	fd3493e3          	bne	s1,s3,80001bc0 <proc_mapstacks+0x8c>
    80001bfe:	bf51                	j	80001b92 <proc_mapstacks+0x5e>
    }
  }
}
    80001c00:	60e6                	ld	ra,88(sp)
    80001c02:	6446                	ld	s0,80(sp)
    80001c04:	64a6                	ld	s1,72(sp)
    80001c06:	6906                	ld	s2,64(sp)
    80001c08:	79e2                	ld	s3,56(sp)
    80001c0a:	7a42                	ld	s4,48(sp)
    80001c0c:	7aa2                	ld	s5,40(sp)
    80001c0e:	7b02                	ld	s6,32(sp)
    80001c10:	6be2                	ld	s7,24(sp)
    80001c12:	6c42                	ld	s8,16(sp)
    80001c14:	6ca2                	ld	s9,8(sp)
    80001c16:	6d02                	ld	s10,0(sp)
    80001c18:	6125                	addi	sp,sp,96
    80001c1a:	8082                	ret

0000000080001c1c <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    80001c1c:	7159                	addi	sp,sp,-112
    80001c1e:	f486                	sd	ra,104(sp)
    80001c20:	f0a2                	sd	s0,96(sp)
    80001c22:	eca6                	sd	s1,88(sp)
    80001c24:	e8ca                	sd	s2,80(sp)
    80001c26:	e4ce                	sd	s3,72(sp)
    80001c28:	e0d2                	sd	s4,64(sp)
    80001c2a:	fc56                	sd	s5,56(sp)
    80001c2c:	f85a                	sd	s6,48(sp)
    80001c2e:	f45e                	sd	s7,40(sp)
    80001c30:	f062                	sd	s8,32(sp)
    80001c32:	ec66                	sd	s9,24(sp)
    80001c34:	e86a                	sd	s10,16(sp)
    80001c36:	e46e                	sd	s11,8(sp)
    80001c38:	1880                	addi	s0,sp,112
  struct proc *p;
  struct kthread *t;
  
  initlock(&pid_lock, "nextpid");
    80001c3a:	00007597          	auipc	a1,0x7
    80001c3e:	67e58593          	addi	a1,a1,1662 # 800092b8 <digits+0x268>
    80001c42:	00012517          	auipc	a0,0x12
    80001c46:	a5e50513          	addi	a0,a0,-1442 # 800136a0 <pid_lock>
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	eec080e7          	jalr	-276(ra) # 80000b36 <initlock>
  initlock(&tid_lock,"nexttid");
    80001c52:	00007597          	auipc	a1,0x7
    80001c56:	66e58593          	addi	a1,a1,1646 # 800092c0 <digits+0x270>
    80001c5a:	00012517          	auipc	a0,0x12
    80001c5e:	a5e50513          	addi	a0,a0,-1442 # 800136b8 <tid_lock>
    80001c62:	fffff097          	auipc	ra,0xfffff
    80001c66:	ed4080e7          	jalr	-300(ra) # 80000b36 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001c6a:	00007597          	auipc	a1,0x7
    80001c6e:	65e58593          	addi	a1,a1,1630 # 800092c8 <digits+0x278>
    80001c72:	00012517          	auipc	a0,0x12
    80001c76:	a5e50513          	addi	a0,a0,-1442 # 800136d0 <wait_lock>
    80001c7a:	fffff097          	auipc	ra,0xfffff
    80001c7e:	ebc080e7          	jalr	-324(ra) # 80000b36 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {      
    80001c82:	00012997          	auipc	s3,0x12
    80001c86:	6ee98993          	addi	s3,s3,1774 # 80014370 <proc+0x848>
    80001c8a:	00012c17          	auipc	s8,0x12
    80001c8e:	e9ec0c13          	addi	s8,s8,-354 # 80013b28 <proc>
      initlock(&p->lock, "proc");
      // p->kstack = KSTACK((int) (p - proc));
      int proc_index= (int)(p-proc);
    80001c92:	8de2                	mv	s11,s8
    80001c94:	00007d17          	auipc	s10,0x7
    80001c98:	374d0d13          	addi	s10,s10,884 # 80009008 <etext+0x8>
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
        initlock(&t->lock, "thread");
    80001c9c:	00007b97          	auipc	s7,0x7
    80001ca0:	644b8b93          	addi	s7,s7,1604 # 800092e0 <digits+0x290>
        int thread_index = (int)(t-p->kthreads);
    80001ca4:	00007b17          	auipc	s6,0x7
    80001ca8:	36cb0b13          	addi	s6,s6,876 # 80009010 <etext+0x10>
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    80001cac:	04000ab7          	lui	s5,0x4000
    80001cb0:	1afd                	addi	s5,s5,-1
    80001cb2:	0ab2                	slli	s5,s5,0xc
  for(p = proc; p < &proc[NPROC]; p++) {      
    80001cb4:	6c85                	lui	s9,0x1
    80001cb6:	848c8c93          	addi	s9,s9,-1976 # 848 <_entry-0x7ffff7b8>
    80001cba:	a809                	j	80001ccc <procinit+0xb0>
    80001cbc:	9c66                	add	s8,s8,s9
    80001cbe:	99e6                	add	s3,s3,s9
    80001cc0:	00033797          	auipc	a5,0x33
    80001cc4:	06878793          	addi	a5,a5,104 # 80034d28 <tickslock>
    80001cc8:	06fc0263          	beq	s8,a5,80001d2c <procinit+0x110>
      initlock(&p->lock, "proc");
    80001ccc:	00007597          	auipc	a1,0x7
    80001cd0:	60c58593          	addi	a1,a1,1548 # 800092d8 <digits+0x288>
    80001cd4:	8562                	mv	a0,s8
    80001cd6:	fffff097          	auipc	ra,0xfffff
    80001cda:	e60080e7          	jalr	-416(ra) # 80000b36 <initlock>
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001cde:	288c0a13          	addi	s4,s8,648
      int proc_index= (int)(p-proc);
    80001ce2:	41bc0933          	sub	s2,s8,s11
    80001ce6:	40395913          	srai	s2,s2,0x3
    80001cea:	000d3783          	ld	a5,0(s10)
    80001cee:	02f90933          	mul	s2,s2,a5
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    80001cf2:	0039191b          	slliw	s2,s2,0x3
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001cf6:	84d2                	mv	s1,s4
        initlock(&t->lock, "thread");
    80001cf8:	85de                	mv	a1,s7
    80001cfa:	8526                	mv	a0,s1
    80001cfc:	fffff097          	auipc	ra,0xfffff
    80001d00:	e3a080e7          	jalr	-454(ra) # 80000b36 <initlock>
        int thread_index = (int)(t-p->kthreads);
    80001d04:	414487b3          	sub	a5,s1,s4
    80001d08:	878d                	srai	a5,a5,0x3
    80001d0a:	000b3703          	ld	a4,0(s6)
    80001d0e:	02e787b3          	mul	a5,a5,a4
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    80001d12:	012787bb          	addw	a5,a5,s2
    80001d16:	2785                	addiw	a5,a5,1
    80001d18:	00d7979b          	slliw	a5,a5,0xd
    80001d1c:	40fa87b3          	sub	a5,s5,a5
    80001d20:	fc9c                	sd	a5,56(s1)
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001d22:	0b848493          	addi	s1,s1,184
    80001d26:	fd3499e3          	bne	s1,s3,80001cf8 <procinit+0xdc>
    80001d2a:	bf49                	j	80001cbc <procinit+0xa0>
      }
  }
}
    80001d2c:	70a6                	ld	ra,104(sp)
    80001d2e:	7406                	ld	s0,96(sp)
    80001d30:	64e6                	ld	s1,88(sp)
    80001d32:	6946                	ld	s2,80(sp)
    80001d34:	69a6                	ld	s3,72(sp)
    80001d36:	6a06                	ld	s4,64(sp)
    80001d38:	7ae2                	ld	s5,56(sp)
    80001d3a:	7b42                	ld	s6,48(sp)
    80001d3c:	7ba2                	ld	s7,40(sp)
    80001d3e:	7c02                	ld	s8,32(sp)
    80001d40:	6ce2                	ld	s9,24(sp)
    80001d42:	6d42                	ld	s10,16(sp)
    80001d44:	6da2                	ld	s11,8(sp)
    80001d46:	6165                	addi	sp,sp,112
    80001d48:	8082                	ret

0000000080001d4a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001d4a:	1141                	addi	sp,sp,-16
    80001d4c:	e422                	sd	s0,8(sp)
    80001d4e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001d50:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001d52:	2501                	sext.w	a0,a0
    80001d54:	6422                	ld	s0,8(sp)
    80001d56:	0141                	addi	sp,sp,16
    80001d58:	8082                	ret

0000000080001d5a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001d5a:	1141                	addi	sp,sp,-16
    80001d5c:	e422                	sd	s0,8(sp)
    80001d5e:	0800                	addi	s0,sp,16
    80001d60:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001d62:	0007851b          	sext.w	a0,a5
    80001d66:	00451793          	slli	a5,a0,0x4
    80001d6a:	97aa                	add	a5,a5,a0
    80001d6c:	078e                	slli	a5,a5,0x3
  return c;
}
    80001d6e:	00012517          	auipc	a0,0x12
    80001d72:	97a50513          	addi	a0,a0,-1670 # 800136e8 <cpus>
    80001d76:	953e                	add	a0,a0,a5
    80001d78:	6422                	ld	s0,8(sp)
    80001d7a:	0141                	addi	sp,sp,16
    80001d7c:	8082                	ret

0000000080001d7e <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001d7e:	1101                	addi	sp,sp,-32
    80001d80:	ec06                	sd	ra,24(sp)
    80001d82:	e822                	sd	s0,16(sp)
    80001d84:	e426                	sd	s1,8(sp)
    80001d86:	1000                	addi	s0,sp,32
  push_off();
    80001d88:	fffff097          	auipc	ra,0xfffff
    80001d8c:	e34080e7          	jalr	-460(ra) # 80000bbc <push_off>
    80001d90:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001d92:	0007871b          	sext.w	a4,a5
    80001d96:	00471793          	slli	a5,a4,0x4
    80001d9a:	97ba                	add	a5,a5,a4
    80001d9c:	078e                	slli	a5,a5,0x3
    80001d9e:	00012717          	auipc	a4,0x12
    80001da2:	90270713          	addi	a4,a4,-1790 # 800136a0 <pid_lock>
    80001da6:	97ba                	add	a5,a5,a4
    80001da8:	67a4                	ld	s1,72(a5)
  pop_off();
    80001daa:	fffff097          	auipc	ra,0xfffff
    80001dae:	ed4080e7          	jalr	-300(ra) # 80000c7e <pop_off>
  return p;
}//
    80001db2:	8526                	mv	a0,s1
    80001db4:	60e2                	ld	ra,24(sp)
    80001db6:	6442                	ld	s0,16(sp)
    80001db8:	64a2                	ld	s1,8(sp)
    80001dba:	6105                	addi	sp,sp,32
    80001dbc:	8082                	ret

0000000080001dbe <mykthread>:

struct kthread*
mykthread(void){
    80001dbe:	1101                	addi	sp,sp,-32
    80001dc0:	ec06                	sd	ra,24(sp)
    80001dc2:	e822                	sd	s0,16(sp)
    80001dc4:	e426                	sd	s1,8(sp)
    80001dc6:	1000                	addi	s0,sp,32
  push_off();
    80001dc8:	fffff097          	auipc	ra,0xfffff
    80001dcc:	df4080e7          	jalr	-524(ra) # 80000bbc <push_off>
    80001dd0:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct kthread *t=c->kthread;
    80001dd2:	0007871b          	sext.w	a4,a5
    80001dd6:	00471793          	slli	a5,a4,0x4
    80001dda:	97ba                	add	a5,a5,a4
    80001ddc:	078e                	slli	a5,a5,0x3
    80001dde:	00012717          	auipc	a4,0x12
    80001de2:	8c270713          	addi	a4,a4,-1854 # 800136a0 <pid_lock>
    80001de6:	97ba                	add	a5,a5,a4
    80001de8:	67e4                	ld	s1,200(a5)
  pop_off();
    80001dea:	fffff097          	auipc	ra,0xfffff
    80001dee:	e94080e7          	jalr	-364(ra) # 80000c7e <pop_off>
  return t;  
}
    80001df2:	8526                	mv	a0,s1
    80001df4:	60e2                	ld	ra,24(sp)
    80001df6:	6442                	ld	s0,16(sp)
    80001df8:	64a2                	ld	s1,8(sp)
    80001dfa:	6105                	addi	sp,sp,32
    80001dfc:	8082                	ret

0000000080001dfe <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001dfe:	1141                	addi	sp,sp,-16
    80001e00:	e406                	sd	ra,8(sp)
    80001e02:	e022                	sd	s0,0(sp)
    80001e04:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  // release(&myproc()->lock);

  release(&mykthread()->lock);    // TODO: check if this change is good
    80001e06:	00000097          	auipc	ra,0x0
    80001e0a:	fb8080e7          	jalr	-72(ra) # 80001dbe <mykthread>
    80001e0e:	fffff097          	auipc	ra,0xfffff
    80001e12:	ed0080e7          	jalr	-304(ra) # 80000cde <release>

  if (first) {
    80001e16:	00008797          	auipc	a5,0x8
    80001e1a:	c3a7a783          	lw	a5,-966(a5) # 80009a50 <first.1>
    80001e1e:	eb89                	bnez	a5,80001e30 <forkret+0x32>
    fsinit(ROOTDEV);
  }
  // printf("ffret%d\n",myproc()->pid);//TODO delete


  usertrapret();
    80001e20:	00002097          	auipc	ra,0x2
    80001e24:	9e4080e7          	jalr	-1564(ra) # 80003804 <usertrapret>
}
    80001e28:	60a2                	ld	ra,8(sp)
    80001e2a:	6402                	ld	s0,0(sp)
    80001e2c:	0141                	addi	sp,sp,16
    80001e2e:	8082                	ret
    first = 0;
    80001e30:	00008797          	auipc	a5,0x8
    80001e34:	c207a023          	sw	zero,-992(a5) # 80009a50 <first.1>
    fsinit(ROOTDEV);
    80001e38:	4505                	li	a0,1
    80001e3a:	00003097          	auipc	ra,0x3
    80001e3e:	a7a080e7          	jalr	-1414(ra) # 800048b4 <fsinit>
    80001e42:	bff9                	j	80001e20 <forkret+0x22>

0000000080001e44 <allocpid>:
allocpid() {
    80001e44:	1101                	addi	sp,sp,-32
    80001e46:	ec06                	sd	ra,24(sp)
    80001e48:	e822                	sd	s0,16(sp)
    80001e4a:	e426                	sd	s1,8(sp)
    80001e4c:	e04a                	sd	s2,0(sp)
    80001e4e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001e50:	00012917          	auipc	s2,0x12
    80001e54:	85090913          	addi	s2,s2,-1968 # 800136a0 <pid_lock>
    80001e58:	854a                	mv	a0,s2
    80001e5a:	fffff097          	auipc	ra,0xfffff
    80001e5e:	dae080e7          	jalr	-594(ra) # 80000c08 <acquire>
  pid = nextpid;
    80001e62:	00008797          	auipc	a5,0x8
    80001e66:	bf678793          	addi	a5,a5,-1034 # 80009a58 <nextpid>
    80001e6a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001e6c:	0014871b          	addiw	a4,s1,1
    80001e70:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001e72:	854a                	mv	a0,s2
    80001e74:	fffff097          	auipc	ra,0xfffff
    80001e78:	e6a080e7          	jalr	-406(ra) # 80000cde <release>
}
    80001e7c:	8526                	mv	a0,s1
    80001e7e:	60e2                	ld	ra,24(sp)
    80001e80:	6442                	ld	s0,16(sp)
    80001e82:	64a2                	ld	s1,8(sp)
    80001e84:	6902                	ld	s2,0(sp)
    80001e86:	6105                	addi	sp,sp,32
    80001e88:	8082                	ret

0000000080001e8a <alloctid>:
alloctid() {
    80001e8a:	1101                	addi	sp,sp,-32
    80001e8c:	ec06                	sd	ra,24(sp)
    80001e8e:	e822                	sd	s0,16(sp)
    80001e90:	e426                	sd	s1,8(sp)
    80001e92:	e04a                	sd	s2,0(sp)
    80001e94:	1000                	addi	s0,sp,32
  acquire(&tid_lock);
    80001e96:	00012917          	auipc	s2,0x12
    80001e9a:	82290913          	addi	s2,s2,-2014 # 800136b8 <tid_lock>
    80001e9e:	854a                	mv	a0,s2
    80001ea0:	fffff097          	auipc	ra,0xfffff
    80001ea4:	d68080e7          	jalr	-664(ra) # 80000c08 <acquire>
  tid = nexttid;
    80001ea8:	00008797          	auipc	a5,0x8
    80001eac:	bac78793          	addi	a5,a5,-1108 # 80009a54 <nexttid>
    80001eb0:	4384                	lw	s1,0(a5)
  nexttid = nexttid + 1;
    80001eb2:	0014871b          	addiw	a4,s1,1
    80001eb6:	c398                	sw	a4,0(a5)
  release(&tid_lock);
    80001eb8:	854a                	mv	a0,s2
    80001eba:	fffff097          	auipc	ra,0xfffff
    80001ebe:	e24080e7          	jalr	-476(ra) # 80000cde <release>
}
    80001ec2:	8526                	mv	a0,s1
    80001ec4:	60e2                	ld	ra,24(sp)
    80001ec6:	6442                	ld	s0,16(sp)
    80001ec8:	64a2                	ld	s1,8(sp)
    80001eca:	6902                	ld	s2,0(sp)
    80001ecc:	6105                	addi	sp,sp,32
    80001ece:	8082                	ret

0000000080001ed0 <init_thread>:
init_thread(struct kthread *t){
    80001ed0:	1101                	addi	sp,sp,-32
    80001ed2:	ec06                	sd	ra,24(sp)
    80001ed4:	e822                	sd	s0,16(sp)
    80001ed6:	e426                	sd	s1,8(sp)
    80001ed8:	1000                	addi	s0,sp,32
    80001eda:	84aa                	mv	s1,a0
  t->state = TUSED;
    80001edc:	4785                	li	a5,1
    80001ede:	cd1c                	sw	a5,24(a0)
  t->tid = alloctid();  
    80001ee0:	00000097          	auipc	ra,0x0
    80001ee4:	faa080e7          	jalr	-86(ra) # 80001e8a <alloctid>
    80001ee8:	d888                	sw	a0,48(s1)
  memset(&(t->context), 0, sizeof(t->context));
    80001eea:	07000613          	li	a2,112
    80001eee:	4581                	li	a1,0
    80001ef0:	04848513          	addi	a0,s1,72
    80001ef4:	fffff097          	auipc	ra,0xfffff
    80001ef8:	0ea080e7          	jalr	234(ra) # 80000fde <memset>
  t->context.ra = (uint64)forkret;
    80001efc:	00000797          	auipc	a5,0x0
    80001f00:	f0278793          	addi	a5,a5,-254 # 80001dfe <forkret>
    80001f04:	e4bc                	sd	a5,72(s1)
  t->context.sp = t->kstack + PGSIZE;
    80001f06:	7c9c                	ld	a5,56(s1)
    80001f08:	6705                	lui	a4,0x1
    80001f0a:	97ba                	add	a5,a5,a4
    80001f0c:	e8bc                	sd	a5,80(s1)
}
    80001f0e:	4501                	li	a0,0
    80001f10:	60e2                	ld	ra,24(sp)
    80001f12:	6442                	ld	s0,16(sp)
    80001f14:	64a2                	ld	s1,8(sp)
    80001f16:	6105                	addi	sp,sp,32
    80001f18:	8082                	ret

0000000080001f1a <proc_pagetable>:
{
    80001f1a:	1101                	addi	sp,sp,-32
    80001f1c:	ec06                	sd	ra,24(sp)
    80001f1e:	e822                	sd	s0,16(sp)
    80001f20:	e426                	sd	s1,8(sp)
    80001f22:	e04a                	sd	s2,0(sp)
    80001f24:	1000                	addi	s0,sp,32
    80001f26:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	706080e7          	jalr	1798(ra) # 8000162e <uvmcreate>
    80001f30:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001f32:	c121                	beqz	a0,80001f72 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001f34:	4729                	li	a4,10
    80001f36:	00006697          	auipc	a3,0x6
    80001f3a:	0ca68693          	addi	a3,a3,202 # 80008000 <_trampoline>
    80001f3e:	6605                	lui	a2,0x1
    80001f40:	040005b7          	lui	a1,0x4000
    80001f44:	15fd                	addi	a1,a1,-1
    80001f46:	05b2                	slli	a1,a1,0xc
    80001f48:	fffff097          	auipc	ra,0xfffff
    80001f4c:	46e080e7          	jalr	1134(ra) # 800013b6 <mappages>
    80001f50:	02054863          	bltz	a0,80001f80 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001f54:	4719                	li	a4,6
    80001f56:	04893683          	ld	a3,72(s2)
    80001f5a:	6605                	lui	a2,0x1
    80001f5c:	020005b7          	lui	a1,0x2000
    80001f60:	15fd                	addi	a1,a1,-1
    80001f62:	05b6                	slli	a1,a1,0xd
    80001f64:	8526                	mv	a0,s1
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	450080e7          	jalr	1104(ra) # 800013b6 <mappages>
    80001f6e:	02054163          	bltz	a0,80001f90 <proc_pagetable+0x76>
}
    80001f72:	8526                	mv	a0,s1
    80001f74:	60e2                	ld	ra,24(sp)
    80001f76:	6442                	ld	s0,16(sp)
    80001f78:	64a2                	ld	s1,8(sp)
    80001f7a:	6902                	ld	s2,0(sp)
    80001f7c:	6105                	addi	sp,sp,32
    80001f7e:	8082                	ret
    uvmfree(pagetable, 0);
    80001f80:	4581                	li	a1,0
    80001f82:	8526                	mv	a0,s1
    80001f84:	00000097          	auipc	ra,0x0
    80001f88:	8a6080e7          	jalr	-1882(ra) # 8000182a <uvmfree>
    return 0;
    80001f8c:	4481                	li	s1,0
    80001f8e:	b7d5                	j	80001f72 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001f90:	4681                	li	a3,0
    80001f92:	4605                	li	a2,1
    80001f94:	040005b7          	lui	a1,0x4000
    80001f98:	15fd                	addi	a1,a1,-1
    80001f9a:	05b2                	slli	a1,a1,0xc
    80001f9c:	8526                	mv	a0,s1
    80001f9e:	fffff097          	auipc	ra,0xfffff
    80001fa2:	5cc080e7          	jalr	1484(ra) # 8000156a <uvmunmap>
    uvmfree(pagetable, 0);
    80001fa6:	4581                	li	a1,0
    80001fa8:	8526                	mv	a0,s1
    80001faa:	00000097          	auipc	ra,0x0
    80001fae:	880080e7          	jalr	-1920(ra) # 8000182a <uvmfree>
    return 0;
    80001fb2:	4481                	li	s1,0
    80001fb4:	bf7d                	j	80001f72 <proc_pagetable+0x58>

0000000080001fb6 <proc_freepagetable>:
{
    80001fb6:	1101                	addi	sp,sp,-32
    80001fb8:	ec06                	sd	ra,24(sp)
    80001fba:	e822                	sd	s0,16(sp)
    80001fbc:	e426                	sd	s1,8(sp)
    80001fbe:	e04a                	sd	s2,0(sp)
    80001fc0:	1000                	addi	s0,sp,32
    80001fc2:	84aa                	mv	s1,a0
    80001fc4:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001fc6:	4681                	li	a3,0
    80001fc8:	4605                	li	a2,1
    80001fca:	040005b7          	lui	a1,0x4000
    80001fce:	15fd                	addi	a1,a1,-1
    80001fd0:	05b2                	slli	a1,a1,0xc
    80001fd2:	fffff097          	auipc	ra,0xfffff
    80001fd6:	598080e7          	jalr	1432(ra) # 8000156a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001fda:	4681                	li	a3,0
    80001fdc:	4605                	li	a2,1
    80001fde:	020005b7          	lui	a1,0x2000
    80001fe2:	15fd                	addi	a1,a1,-1
    80001fe4:	05b6                	slli	a1,a1,0xd
    80001fe6:	8526                	mv	a0,s1
    80001fe8:	fffff097          	auipc	ra,0xfffff
    80001fec:	582080e7          	jalr	1410(ra) # 8000156a <uvmunmap>
  uvmfree(pagetable, sz);
    80001ff0:	85ca                	mv	a1,s2
    80001ff2:	8526                	mv	a0,s1
    80001ff4:	00000097          	auipc	ra,0x0
    80001ff8:	836080e7          	jalr	-1994(ra) # 8000182a <uvmfree>
}
    80001ffc:	60e2                	ld	ra,24(sp)
    80001ffe:	6442                	ld	s0,16(sp)
    80002000:	64a2                	ld	s1,8(sp)
    80002002:	6902                	ld	s2,0(sp)
    80002004:	6105                	addi	sp,sp,32
    80002006:	8082                	ret

0000000080002008 <freeproc>:
{
    80002008:	7179                	addi	sp,sp,-48
    8000200a:	f406                	sd	ra,40(sp)
    8000200c:	f022                	sd	s0,32(sp)
    8000200e:	ec26                	sd	s1,24(sp)
    80002010:	e84a                	sd	s2,16(sp)
    80002012:	e44e                	sd	s3,8(sp)
    80002014:	1800                	addi	s0,sp,48
    80002016:	892a                	mv	s2,a0
   if(p->threads_tf_start)
    80002018:	6528                	ld	a0,72(a0)
    8000201a:	c509                	beqz	a0,80002024 <freeproc+0x1c>
    kfree((void*)p->threads_tf_start);
    8000201c:	fffff097          	auipc	ra,0xfffff
    80002020:	9be080e7          	jalr	-1602(ra) # 800009da <kfree>
   p->threads_tf_start = 0;
    80002024:	04093423          	sd	zero,72(s2)
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80002028:	28890493          	addi	s1,s2,648
    8000202c:	6985                	lui	s3,0x1
    8000202e:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002032:	99ca                	add	s3,s3,s2
    acquire(&t->lock);
    80002034:	8526                	mv	a0,s1
    80002036:	fffff097          	auipc	ra,0xfffff
    8000203a:	bd2080e7          	jalr	-1070(ra) # 80000c08 <acquire>
  t->tid = 0;
    8000203e:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80002042:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80002046:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    8000204a:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    8000204e:	0004ac23          	sw	zero,24(s1)
    release(&t->lock);
    80002052:	8526                	mv	a0,s1
    80002054:	fffff097          	auipc	ra,0xfffff
    80002058:	c8a080e7          	jalr	-886(ra) # 80000cde <release>
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    8000205c:	0b848493          	addi	s1,s1,184
    80002060:	fc999ae3          	bne	s3,s1,80002034 <freeproc+0x2c>
  p->user_trapframe_backup = 0;
    80002064:	26093c23          	sd	zero,632(s2)
  if(p->pagetable)
    80002068:	04093503          	ld	a0,64(s2)
    8000206c:	c519                	beqz	a0,8000207a <freeproc+0x72>
    proc_freepagetable(p->pagetable, p->sz);
    8000206e:	03893583          	ld	a1,56(s2)
    80002072:	00000097          	auipc	ra,0x0
    80002076:	f44080e7          	jalr	-188(ra) # 80001fb6 <proc_freepagetable>
  p->pagetable = 0;
    8000207a:	04093023          	sd	zero,64(s2)
  p->sz = 0;
    8000207e:	02093c23          	sd	zero,56(s2)
  p->pid = 0;
    80002082:	02092223          	sw	zero,36(s2)
  p->parent = 0;
    80002086:	02093823          	sd	zero,48(s2)
  p->name[0] = 0;
    8000208a:	0c090c23          	sb	zero,216(s2)
  p->killed = 0;
    8000208e:	00092e23          	sw	zero,28(s2)
  p->xstate = 0;
    80002092:	02092023          	sw	zero,32(s2)
  p->active_threads = 0;
    80002096:	02092423          	sw	zero,40(s2)
  p->state = UNUSED;
    8000209a:	00092c23          	sw	zero,24(s2)
}
    8000209e:	70a2                	ld	ra,40(sp)
    800020a0:	7402                	ld	s0,32(sp)
    800020a2:	64e2                	ld	s1,24(sp)
    800020a4:	6942                	ld	s2,16(sp)
    800020a6:	69a2                	ld	s3,8(sp)
    800020a8:	6145                	addi	sp,sp,48
    800020aa:	8082                	ret

00000000800020ac <allocproc>:
{
    800020ac:	7179                	addi	sp,sp,-48
    800020ae:	f406                	sd	ra,40(sp)
    800020b0:	f022                	sd	s0,32(sp)
    800020b2:	ec26                	sd	s1,24(sp)
    800020b4:	e84a                	sd	s2,16(sp)
    800020b6:	e44e                	sd	s3,8(sp)
    800020b8:	e052                	sd	s4,0(sp)
    800020ba:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    800020bc:	00012497          	auipc	s1,0x12
    800020c0:	a6c48493          	addi	s1,s1,-1428 # 80013b28 <proc>
    800020c4:	6985                	lui	s3,0x1
    800020c6:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    800020ca:	00033a17          	auipc	s4,0x33
    800020ce:	c5ea0a13          	addi	s4,s4,-930 # 80034d28 <tickslock>
    acquire(&p->lock);
    800020d2:	8926                	mv	s2,s1
    800020d4:	8526                	mv	a0,s1
    800020d6:	fffff097          	auipc	ra,0xfffff
    800020da:	b32080e7          	jalr	-1230(ra) # 80000c08 <acquire>
    if(p->state == UNUSED) {
    800020de:	4c9c                	lw	a5,24(s1)
    800020e0:	cb99                	beqz	a5,800020f6 <allocproc+0x4a>
      release(&p->lock);
    800020e2:	8526                	mv	a0,s1
    800020e4:	fffff097          	auipc	ra,0xfffff
    800020e8:	bfa080e7          	jalr	-1030(ra) # 80000cde <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020ec:	94ce                	add	s1,s1,s3
    800020ee:	ff4492e3          	bne	s1,s4,800020d2 <allocproc+0x26>
  return 0;
    800020f2:	4481                	li	s1,0
    800020f4:	a845                	j	800021a4 <allocproc+0xf8>
  p->pid = allocpid();
    800020f6:	00000097          	auipc	ra,0x0
    800020fa:	d4e080e7          	jalr	-690(ra) # 80001e44 <allocpid>
    800020fe:	d0c8                	sw	a0,36(s1)
  p->state = USED;
    80002100:	4785                	li	a5,1
    80002102:	cc9c                	sw	a5,24(s1)
  if((p->threads_tf_start =kalloc()) == 0){
    80002104:	fffff097          	auipc	ra,0xfffff
    80002108:	9d2080e7          	jalr	-1582(ra) # 80000ad6 <kalloc>
    8000210c:	89aa                	mv	s3,a0
    8000210e:	e4a8                	sd	a0,72(s1)
    80002110:	0f848713          	addi	a4,s1,248
    80002114:	1f848793          	addi	a5,s1,504
    80002118:	27848693          	addi	a3,s1,632
    8000211c:	cd49                	beqz	a0,800021b6 <allocproc+0x10a>
    p->signal_handlers[i] = SIG_DFL;
    8000211e:	00073023          	sd	zero,0(a4) # 1000 <_entry-0x7ffff000>
    p->handlers_sigmasks[i] = 0;
    80002122:	0007a023          	sw	zero,0(a5)
  for(int i=0;i<32;i++){
    80002126:	0721                	addi	a4,a4,8
    80002128:	0791                	addi	a5,a5,4
    8000212a:	fed79ae3          	bne	a5,a3,8000211e <allocproc+0x72>
  p->signal_mask= 0;
    8000212e:	0e04a623          	sw	zero,236(s1)
  p->pending_signals = 0;
    80002132:	0e04a423          	sw	zero,232(s1)
  p->active_threads=1;
    80002136:	4785                	li	a5,1
    80002138:	d49c                	sw	a5,40(s1)
  p->signal_mask_backup = 0;
    8000213a:	0e04a823          	sw	zero,240(s1)
  p->handling_user_sig_flag = 0;
    8000213e:	2804a023          	sw	zero,640(s1)
  p->handling_sig_flag=0;
    80002142:	2804a223          	sw	zero,644(s1)
  p->pagetable = proc_pagetable(p);
    80002146:	8526                	mv	a0,s1
    80002148:	00000097          	auipc	ra,0x0
    8000214c:	dd2080e7          	jalr	-558(ra) # 80001f1a <proc_pagetable>
    80002150:	89aa                	mv	s3,a0
    80002152:	e0a8                	sd	a0,64(s1)
  if(p->pagetable == 0){
    80002154:	cd2d                	beqz	a0,800021ce <allocproc+0x122>
    80002156:	2a048793          	addi	a5,s1,672
    8000215a:	64b8                	ld	a4,72(s1)
    8000215c:	6685                	lui	a3,0x1
    8000215e:	86068693          	addi	a3,a3,-1952 # 860 <_entry-0x7ffff7a0>
    80002162:	9936                	add	s2,s2,a3
    t->tid=-1;
    80002164:	56fd                	li	a3,-1
    t->state=TUNUSED;
    80002166:	0007a023          	sw	zero,0(a5)
    t->chan=0;
    8000216a:	0007b423          	sd	zero,8(a5)
    t->tid=-1;
    8000216e:	cf94                	sw	a3,24(a5)
    t->trapframe = (struct trapframe *)p->threads_tf_start + i;     
    80002170:	f798                	sd	a4,40(a5)
    t->killed = 0;
    80002172:	0007a823          	sw	zero,16(a5)
    t->frozen = 0;
    80002176:	0007ae23          	sw	zero,28(a5)
  for(int i=0;i<NTHREAD;i++){
    8000217a:	0b878793          	addi	a5,a5,184
    8000217e:	12070713          	addi	a4,a4,288
    80002182:	ff2792e3          	bne	a5,s2,80002166 <allocproc+0xba>
  struct kthread *t= &p->kthreads[0];
    80002186:	28848913          	addi	s2,s1,648
  acquire(&t->lock);
    8000218a:	854a                	mv	a0,s2
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	a7c080e7          	jalr	-1412(ra) # 80000c08 <acquire>
  if(init_thread(t) == -1){
    80002194:	854a                	mv	a0,s2
    80002196:	00000097          	auipc	ra,0x0
    8000219a:	d3a080e7          	jalr	-710(ra) # 80001ed0 <init_thread>
    8000219e:	57fd                	li	a5,-1
    800021a0:	04f50363          	beq	a0,a5,800021e6 <allocproc+0x13a>
}
    800021a4:	8526                	mv	a0,s1
    800021a6:	70a2                	ld	ra,40(sp)
    800021a8:	7402                	ld	s0,32(sp)
    800021aa:	64e2                	ld	s1,24(sp)
    800021ac:	6942                	ld	s2,16(sp)
    800021ae:	69a2                	ld	s3,8(sp)
    800021b0:	6a02                	ld	s4,0(sp)
    800021b2:	6145                	addi	sp,sp,48
    800021b4:	8082                	ret
    freeproc(p);
    800021b6:	8526                	mv	a0,s1
    800021b8:	00000097          	auipc	ra,0x0
    800021bc:	e50080e7          	jalr	-432(ra) # 80002008 <freeproc>
    release(&p->lock);
    800021c0:	8526                	mv	a0,s1
    800021c2:	fffff097          	auipc	ra,0xfffff
    800021c6:	b1c080e7          	jalr	-1252(ra) # 80000cde <release>
    return 0;
    800021ca:	84ce                	mv	s1,s3
    800021cc:	bfe1                	j	800021a4 <allocproc+0xf8>
    freeproc(p);
    800021ce:	8526                	mv	a0,s1
    800021d0:	00000097          	auipc	ra,0x0
    800021d4:	e38080e7          	jalr	-456(ra) # 80002008 <freeproc>
    release(&p->lock);
    800021d8:	8526                	mv	a0,s1
    800021da:	fffff097          	auipc	ra,0xfffff
    800021de:	b04080e7          	jalr	-1276(ra) # 80000cde <release>
    return 0;
    800021e2:	84ce                	mv	s1,s3
    800021e4:	b7c1                	j	800021a4 <allocproc+0xf8>
    freeproc(p);
    800021e6:	8526                	mv	a0,s1
    800021e8:	00000097          	auipc	ra,0x0
    800021ec:	e20080e7          	jalr	-480(ra) # 80002008 <freeproc>
    release(&p->lock);  
    800021f0:	8526                	mv	a0,s1
    800021f2:	fffff097          	auipc	ra,0xfffff
    800021f6:	aec080e7          	jalr	-1300(ra) # 80000cde <release>
    return 0;
    800021fa:	4481                	li	s1,0
    800021fc:	b765                	j	800021a4 <allocproc+0xf8>

00000000800021fe <userinit>:
{
    800021fe:	1101                	addi	sp,sp,-32
    80002200:	ec06                	sd	ra,24(sp)
    80002202:	e822                	sd	s0,16(sp)
    80002204:	e426                	sd	s1,8(sp)
    80002206:	1000                	addi	s0,sp,32
  p = allocproc();
    80002208:	00000097          	auipc	ra,0x0
    8000220c:	ea4080e7          	jalr	-348(ra) # 800020ac <allocproc>
    80002210:	84aa                	mv	s1,a0
  initproc = p;
    80002212:	00008797          	auipc	a5,0x8
    80002216:	e0a7bb23          	sd	a0,-490(a5) # 8000a028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    8000221a:	03400613          	li	a2,52
    8000221e:	00008597          	auipc	a1,0x8
    80002222:	84258593          	addi	a1,a1,-1982 # 80009a60 <initcode>
    80002226:	6128                	ld	a0,64(a0)
    80002228:	fffff097          	auipc	ra,0xfffff
    8000222c:	434080e7          	jalr	1076(ra) # 8000165c <uvminit>
  p->sz = PGSIZE;
    80002230:	6785                	lui	a5,0x1
    80002232:	fc9c                	sd	a5,56(s1)
  t->trapframe->epc = 0;      // user program counter
    80002234:	2c84b703          	ld	a4,712(s1)
    80002238:	00073c23          	sd	zero,24(a4)
  t->trapframe->sp = PGSIZE;  // user stack pointer
    8000223c:	2c84b703          	ld	a4,712(s1)
    80002240:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80002242:	4641                	li	a2,16
    80002244:	00007597          	auipc	a1,0x7
    80002248:	0a458593          	addi	a1,a1,164 # 800092e8 <digits+0x298>
    8000224c:	0d848513          	addi	a0,s1,216
    80002250:	fffff097          	auipc	ra,0xfffff
    80002254:	ee0080e7          	jalr	-288(ra) # 80001130 <safestrcpy>
  p->cwd = namei("/");
    80002258:	00007517          	auipc	a0,0x7
    8000225c:	0a050513          	addi	a0,a0,160 # 800092f8 <digits+0x2a8>
    80002260:	00003097          	auipc	ra,0x3
    80002264:	080080e7          	jalr	128(ra) # 800052e0 <namei>
    80002268:	e8e8                	sd	a0,208(s1)
  p->state = RUNNABLE;
    8000226a:	4789                	li	a5,2
    8000226c:	cc9c                	sw	a5,24(s1)
  t->state = TRUNNABLE;
    8000226e:	478d                	li	a5,3
    80002270:	2af4a023          	sw	a5,672(s1)
  release(&p->lock);
    80002274:	8526                	mv	a0,s1
    80002276:	fffff097          	auipc	ra,0xfffff
    8000227a:	a68080e7          	jalr	-1432(ra) # 80000cde <release>
  release(&p->kthreads[0].lock);////////////////////////////////////////////////////////////////check
    8000227e:	28848513          	addi	a0,s1,648
    80002282:	fffff097          	auipc	ra,0xfffff
    80002286:	a5c080e7          	jalr	-1444(ra) # 80000cde <release>
}
    8000228a:	60e2                	ld	ra,24(sp)
    8000228c:	6442                	ld	s0,16(sp)
    8000228e:	64a2                	ld	s1,8(sp)
    80002290:	6105                	addi	sp,sp,32
    80002292:	8082                	ret

0000000080002294 <growproc>:
{
    80002294:	1101                	addi	sp,sp,-32
    80002296:	ec06                	sd	ra,24(sp)
    80002298:	e822                	sd	s0,16(sp)
    8000229a:	e426                	sd	s1,8(sp)
    8000229c:	e04a                	sd	s2,0(sp)
    8000229e:	1000                	addi	s0,sp,32
    800022a0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800022a2:	00000097          	auipc	ra,0x0
    800022a6:	adc080e7          	jalr	-1316(ra) # 80001d7e <myproc>
    800022aa:	892a                	mv	s2,a0
  sz = p->sz;
    800022ac:	7d0c                	ld	a1,56(a0)
    800022ae:	0005861b          	sext.w	a2,a1
  if(n > 0){
    800022b2:	00904f63          	bgtz	s1,800022d0 <growproc+0x3c>
  } else if(n < 0){
    800022b6:	0204cc63          	bltz	s1,800022ee <growproc+0x5a>
  p->sz = sz;
    800022ba:	1602                	slli	a2,a2,0x20
    800022bc:	9201                	srli	a2,a2,0x20
    800022be:	02c93c23          	sd	a2,56(s2)
  return 0;
    800022c2:	4501                	li	a0,0
}
    800022c4:	60e2                	ld	ra,24(sp)
    800022c6:	6442                	ld	s0,16(sp)
    800022c8:	64a2                	ld	s1,8(sp)
    800022ca:	6902                	ld	s2,0(sp)
    800022cc:	6105                	addi	sp,sp,32
    800022ce:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    800022d0:	9e25                	addw	a2,a2,s1
    800022d2:	1602                	slli	a2,a2,0x20
    800022d4:	9201                	srli	a2,a2,0x20
    800022d6:	1582                	slli	a1,a1,0x20
    800022d8:	9181                	srli	a1,a1,0x20
    800022da:	6128                	ld	a0,64(a0)
    800022dc:	fffff097          	auipc	ra,0xfffff
    800022e0:	43a080e7          	jalr	1082(ra) # 80001716 <uvmalloc>
    800022e4:	0005061b          	sext.w	a2,a0
    800022e8:	fa69                	bnez	a2,800022ba <growproc+0x26>
      return -1;
    800022ea:	557d                	li	a0,-1
    800022ec:	bfe1                	j	800022c4 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800022ee:	9e25                	addw	a2,a2,s1
    800022f0:	1602                	slli	a2,a2,0x20
    800022f2:	9201                	srli	a2,a2,0x20
    800022f4:	1582                	slli	a1,a1,0x20
    800022f6:	9181                	srli	a1,a1,0x20
    800022f8:	6128                	ld	a0,64(a0)
    800022fa:	fffff097          	auipc	ra,0xfffff
    800022fe:	3d4080e7          	jalr	980(ra) # 800016ce <uvmdealloc>
    80002302:	0005061b          	sext.w	a2,a0
    80002306:	bf55                	j	800022ba <growproc+0x26>

0000000080002308 <fork>:
{
    80002308:	7139                	addi	sp,sp,-64
    8000230a:	fc06                	sd	ra,56(sp)
    8000230c:	f822                	sd	s0,48(sp)
    8000230e:	f426                	sd	s1,40(sp)
    80002310:	f04a                	sd	s2,32(sp)
    80002312:	ec4e                	sd	s3,24(sp)
    80002314:	e852                	sd	s4,16(sp)
    80002316:	e456                	sd	s5,8(sp)
    80002318:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000231a:	00000097          	auipc	ra,0x0
    8000231e:	a64080e7          	jalr	-1436(ra) # 80001d7e <myproc>
    80002322:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    80002324:	00000097          	auipc	ra,0x0
    80002328:	a9a080e7          	jalr	-1382(ra) # 80001dbe <mykthread>
    8000232c:	84aa                	mv	s1,a0
  if((np = allocproc()) == 0){//////////////////////////////////////////////////check  lock p and t
    8000232e:	00000097          	auipc	ra,0x0
    80002332:	d7e080e7          	jalr	-642(ra) # 800020ac <allocproc>
    80002336:	16050f63          	beqz	a0,800024b4 <fork+0x1ac>
    8000233a:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000233c:	0389b603          	ld	a2,56(s3)
    80002340:	612c                	ld	a1,64(a0)
    80002342:	0409b503          	ld	a0,64(s3)
    80002346:	fffff097          	auipc	ra,0xfffff
    8000234a:	51c080e7          	jalr	1308(ra) # 80001862 <uvmcopy>
    8000234e:	06054763          	bltz	a0,800023bc <fork+0xb4>
  np->sz = p->sz;
    80002352:	0389b783          	ld	a5,56(s3)
    80002356:	02f93c23          	sd	a5,56(s2)
  acquire(&wait_lock);/////////////////////////////////////////////////////////////////check
    8000235a:	00011517          	auipc	a0,0x11
    8000235e:	37650513          	addi	a0,a0,886 # 800136d0 <wait_lock>
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	8a6080e7          	jalr	-1882(ra) # 80000c08 <acquire>
  *(np_first_thread->trapframe) = *(t->trapframe);
    8000236a:	60b4                	ld	a3,64(s1)
    8000236c:	87b6                	mv	a5,a3
    8000236e:	2c893703          	ld	a4,712(s2)
    80002372:	12068693          	addi	a3,a3,288
    80002376:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000237a:	6788                	ld	a0,8(a5)
    8000237c:	6b8c                	ld	a1,16(a5)
    8000237e:	6f90                	ld	a2,24(a5)
    80002380:	01073023          	sd	a6,0(a4)
    80002384:	e708                	sd	a0,8(a4)
    80002386:	eb0c                	sd	a1,16(a4)
    80002388:	ef10                	sd	a2,24(a4)
    8000238a:	02078793          	addi	a5,a5,32
    8000238e:	02070713          	addi	a4,a4,32
    80002392:	fed792e3          	bne	a5,a3,80002376 <fork+0x6e>
  np_first_thread->trapframe->a0 = 0;  // TODO: change reading the ret value from proc a0 to thread a0
    80002396:	2c893783          	ld	a5,712(s2)
    8000239a:	0607b823          	sd	zero,112(a5)
  release(&wait_lock);////////////////////////////////////////////////////////////////check
    8000239e:	00011517          	auipc	a0,0x11
    800023a2:	33250513          	addi	a0,a0,818 # 800136d0 <wait_lock>
    800023a6:	fffff097          	auipc	ra,0xfffff
    800023aa:	938080e7          	jalr	-1736(ra) # 80000cde <release>
  for(i = 0; i < NOFILE; i++)
    800023ae:	05098493          	addi	s1,s3,80
    800023b2:	05090a13          	addi	s4,s2,80
    800023b6:	0d098a93          	addi	s5,s3,208
    800023ba:	a00d                	j	800023dc <fork+0xd4>
    freeproc(np);
    800023bc:	854a                	mv	a0,s2
    800023be:	00000097          	auipc	ra,0x0
    800023c2:	c4a080e7          	jalr	-950(ra) # 80002008 <freeproc>
    release(&np->lock);
    800023c6:	854a                	mv	a0,s2
    800023c8:	fffff097          	auipc	ra,0xfffff
    800023cc:	916080e7          	jalr	-1770(ra) # 80000cde <release>
    return -1;
    800023d0:	5a7d                	li	s4,-1
    800023d2:	a0f9                	j	800024a0 <fork+0x198>
  for(i = 0; i < NOFILE; i++)
    800023d4:	04a1                	addi	s1,s1,8
    800023d6:	0a21                	addi	s4,s4,8
    800023d8:	01548b63          	beq	s1,s5,800023ee <fork+0xe6>
    if(p->ofile[i])
    800023dc:	6088                	ld	a0,0(s1)
    800023de:	d97d                	beqz	a0,800023d4 <fork+0xcc>
      np->ofile[i] = filedup(p->ofile[i]);
    800023e0:	00003097          	auipc	ra,0x3
    800023e4:	59a080e7          	jalr	1434(ra) # 8000597a <filedup>
    800023e8:	00aa3023          	sd	a0,0(s4)
    800023ec:	b7e5                	j	800023d4 <fork+0xcc>
  np->cwd = idup(p->cwd);
    800023ee:	0d09b503          	ld	a0,208(s3)
    800023f2:	00002097          	auipc	ra,0x2
    800023f6:	6fc080e7          	jalr	1788(ra) # 80004aee <idup>
    800023fa:	0ca93823          	sd	a0,208(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800023fe:	4641                	li	a2,16
    80002400:	0d898593          	addi	a1,s3,216
    80002404:	0d890513          	addi	a0,s2,216
    80002408:	fffff097          	auipc	ra,0xfffff
    8000240c:	d28080e7          	jalr	-728(ra) # 80001130 <safestrcpy>
  np->signal_mask = p->signal_mask;
    80002410:	0ec9a783          	lw	a5,236(s3)
    80002414:	0ef92623          	sw	a5,236(s2)
  for(int i=0;i<32;i++){
    80002418:	0f898693          	addi	a3,s3,248
    8000241c:	0f890713          	addi	a4,s2,248
  np->signal_mask = p->signal_mask;
    80002420:	1f800793          	li	a5,504
  for(int i=0;i<32;i++){
    80002424:	27800513          	li	a0,632
    np->signal_handlers[i] = p->signal_handlers[i];
    80002428:	6290                	ld	a2,0(a3)
    8000242a:	e310                	sd	a2,0(a4)
    np->handlers_sigmasks[i] = p->handlers_sigmasks[i];
    8000242c:	00f98633          	add	a2,s3,a5
    80002430:	420c                	lw	a1,0(a2)
    80002432:	00f90633          	add	a2,s2,a5
    80002436:	c20c                	sw	a1,0(a2)
  for(int i=0;i<32;i++){
    80002438:	06a1                	addi	a3,a3,8
    8000243a:	0721                	addi	a4,a4,8
    8000243c:	0791                	addi	a5,a5,4
    8000243e:	fea795e3          	bne	a5,a0,80002428 <fork+0x120>
  np-> pending_signals=0;
    80002442:	0e092423          	sw	zero,232(s2)
  pid = np->pid;
    80002446:	02492a03          	lw	s4,36(s2)
  release(&np->lock);
    8000244a:	854a                	mv	a0,s2
    8000244c:	fffff097          	auipc	ra,0xfffff
    80002450:	892080e7          	jalr	-1902(ra) # 80000cde <release>
  acquire(&wait_lock);
    80002454:	00011497          	auipc	s1,0x11
    80002458:	27c48493          	addi	s1,s1,636 # 800136d0 <wait_lock>
    8000245c:	8526                	mv	a0,s1
    8000245e:	ffffe097          	auipc	ra,0xffffe
    80002462:	7aa080e7          	jalr	1962(ra) # 80000c08 <acquire>
  np->parent = p;
    80002466:	03393823          	sd	s3,48(s2)
  release(&wait_lock);
    8000246a:	8526                	mv	a0,s1
    8000246c:	fffff097          	auipc	ra,0xfffff
    80002470:	872080e7          	jalr	-1934(ra) # 80000cde <release>
  acquire(&np->lock);
    80002474:	854a                	mv	a0,s2
    80002476:	ffffe097          	auipc	ra,0xffffe
    8000247a:	792080e7          	jalr	1938(ra) # 80000c08 <acquire>
  np->state = RUNNABLE;   
    8000247e:	4789                	li	a5,2
    80002480:	00f92c23          	sw	a5,24(s2)
  np_first_thread->state = TRUNNABLE;
    80002484:	478d                	li	a5,3
    80002486:	2af92023          	sw	a5,672(s2)
  release(&np_first_thread->lock);
    8000248a:	28890513          	addi	a0,s2,648
    8000248e:	fffff097          	auipc	ra,0xfffff
    80002492:	850080e7          	jalr	-1968(ra) # 80000cde <release>
  release(&np->lock);
    80002496:	854a                	mv	a0,s2
    80002498:	fffff097          	auipc	ra,0xfffff
    8000249c:	846080e7          	jalr	-1978(ra) # 80000cde <release>
}
    800024a0:	8552                	mv	a0,s4
    800024a2:	70e2                	ld	ra,56(sp)
    800024a4:	7442                	ld	s0,48(sp)
    800024a6:	74a2                	ld	s1,40(sp)
    800024a8:	7902                	ld	s2,32(sp)
    800024aa:	69e2                	ld	s3,24(sp)
    800024ac:	6a42                	ld	s4,16(sp)
    800024ae:	6aa2                	ld	s5,8(sp)
    800024b0:	6121                	addi	sp,sp,64
    800024b2:	8082                	ret
    return -1;
    800024b4:	5a7d                	li	s4,-1
    800024b6:	b7ed                	j	800024a0 <fork+0x198>

00000000800024b8 <scheduler>:
{
    800024b8:	711d                	addi	sp,sp,-96
    800024ba:	ec86                	sd	ra,88(sp)
    800024bc:	e8a2                	sd	s0,80(sp)
    800024be:	e4a6                	sd	s1,72(sp)
    800024c0:	e0ca                	sd	s2,64(sp)
    800024c2:	fc4e                	sd	s3,56(sp)
    800024c4:	f852                	sd	s4,48(sp)
    800024c6:	f456                	sd	s5,40(sp)
    800024c8:	f05a                	sd	s6,32(sp)
    800024ca:	ec5e                	sd	s7,24(sp)
    800024cc:	e862                	sd	s8,16(sp)
    800024ce:	e466                	sd	s9,8(sp)
    800024d0:	1080                	addi	s0,sp,96
    800024d2:	8792                	mv	a5,tp
  int id = r_tp();
    800024d4:	2781                	sext.w	a5,a5
  c->proc = 0;
    800024d6:	00479713          	slli	a4,a5,0x4
    800024da:	00f706b3          	add	a3,a4,a5
    800024de:	00369613          	slli	a2,a3,0x3
    800024e2:	00011697          	auipc	a3,0x11
    800024e6:	1be68693          	addi	a3,a3,446 # 800136a0 <pid_lock>
    800024ea:	96b2                	add	a3,a3,a2
    800024ec:	0406b423          	sd	zero,72(a3)
  c->kthread=0;
    800024f0:	0c06b423          	sd	zero,200(a3)
            swtch(&c->context, &t->context);
    800024f4:	00011717          	auipc	a4,0x11
    800024f8:	1fc70713          	addi	a4,a4,508 # 800136f0 <cpus+0x8>
    800024fc:	00e60bb3          	add	s7,a2,a4
            c->proc = p;
    80002500:	8b36                	mv	s6,a3
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002502:	6a85                	lui	s5,0x1
    80002504:	848a8a93          	addi	s5,s5,-1976 # 848 <_entry-0x7ffff7b8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002508:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000250c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002510:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002514:	00011917          	auipc	s2,0x11
    80002518:	61490913          	addi	s2,s2,1556 # 80013b28 <proc>
    8000251c:	a8a9                	j	80002576 <scheduler+0xbe>
          release(&t->lock);
    8000251e:	8526                	mv	a0,s1
    80002520:	ffffe097          	auipc	ra,0xffffe
    80002524:	7be080e7          	jalr	1982(ra) # 80000cde <release>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002528:	0b848493          	addi	s1,s1,184
    8000252c:	03348e63          	beq	s1,s3,80002568 <scheduler+0xb0>
          acquire(&t->lock);
    80002530:	8526                	mv	a0,s1
    80002532:	ffffe097          	auipc	ra,0xffffe
    80002536:	6d6080e7          	jalr	1750(ra) # 80000c08 <acquire>
          if(t->state == TRUNNABLE && !t->frozen) {          
    8000253a:	4c9c                	lw	a5,24(s1)
    8000253c:	ff4791e3          	bne	a5,s4,8000251e <scheduler+0x66>
    80002540:	58dc                	lw	a5,52(s1)
    80002542:	fff1                	bnez	a5,8000251e <scheduler+0x66>
            t->state = TRUNNING;
    80002544:	0194ac23          	sw	s9,24(s1)
            c->proc = p;
    80002548:	052b3423          	sd	s2,72(s6)
            c->kthread = t;
    8000254c:	0c9b3423          	sd	s1,200(s6)
            swtch(&c->context, &t->context);
    80002550:	04848593          	addi	a1,s1,72
    80002554:	855e                	mv	a0,s7
    80002556:	00001097          	auipc	ra,0x1
    8000255a:	f4a080e7          	jalr	-182(ra) # 800034a0 <swtch>
            c->proc = 0;
    8000255e:	040b3423          	sd	zero,72(s6)
            c->kthread=0;
    80002562:	0c0b3423          	sd	zero,200(s6)
    80002566:	bf65                	j	8000251e <scheduler+0x66>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002568:	9956                	add	s2,s2,s5
    8000256a:	00032797          	auipc	a5,0x32
    8000256e:	7be78793          	addi	a5,a5,1982 # 80034d28 <tickslock>
    80002572:	f8f90be3          	beq	s2,a5,80002508 <scheduler+0x50>
      if(p->state == RUNNABLE) {
    80002576:	01892703          	lw	a4,24(s2)
    8000257a:	4789                	li	a5,2
    8000257c:	fef716e3          	bne	a4,a5,80002568 <scheduler+0xb0>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002580:	28890493          	addi	s1,s2,648
          if(t->state == TRUNNABLE && !t->frozen) {          
    80002584:	4a0d                	li	s4,3
            t->state = TRUNNING;
    80002586:	4c91                	li	s9,4
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002588:	015909b3          	add	s3,s2,s5
    8000258c:	b755                	j	80002530 <scheduler+0x78>

000000008000258e <sched>:
{
    8000258e:	7179                	addi	sp,sp,-48
    80002590:	f406                	sd	ra,40(sp)
    80002592:	f022                	sd	s0,32(sp)
    80002594:	ec26                	sd	s1,24(sp)
    80002596:	e84a                	sd	s2,16(sp)
    80002598:	e44e                	sd	s3,8(sp)
    8000259a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000259c:	fffff097          	auipc	ra,0xfffff
    800025a0:	7e2080e7          	jalr	2018(ra) # 80001d7e <myproc>
    800025a4:	892a                	mv	s2,a0
  struct kthread *t=mykthread();
    800025a6:	00000097          	auipc	ra,0x0
    800025aa:	818080e7          	jalr	-2024(ra) # 80001dbe <mykthread>
    800025ae:	84aa                	mv	s1,a0
  if(!holding(&t->lock))
    800025b0:	ffffe097          	auipc	ra,0xffffe
    800025b4:	5de080e7          	jalr	1502(ra) # 80000b8e <holding>
    800025b8:	c959                	beqz	a0,8000264e <sched+0xc0>
  asm volatile("mv %0, tp" : "=r" (x) );
    800025ba:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800025bc:	0007871b          	sext.w	a4,a5
    800025c0:	00471793          	slli	a5,a4,0x4
    800025c4:	97ba                	add	a5,a5,a4
    800025c6:	078e                	slli	a5,a5,0x3
    800025c8:	00011717          	auipc	a4,0x11
    800025cc:	0d870713          	addi	a4,a4,216 # 800136a0 <pid_lock>
    800025d0:	97ba                	add	a5,a5,a4
    800025d2:	0c07a703          	lw	a4,192(a5)
    800025d6:	4785                	li	a5,1
    800025d8:	08f71363          	bne	a4,a5,8000265e <sched+0xd0>
  if(t->state == TRUNNING){
    800025dc:	4c98                	lw	a4,24(s1)
    800025de:	4791                	li	a5,4
    800025e0:	08f70763          	beq	a4,a5,8000266e <sched+0xe0>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025e4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800025e8:	8b89                	andi	a5,a5,2
  if(intr_get())
    800025ea:	efdd                	bnez	a5,800026a8 <sched+0x11a>
  asm volatile("mv %0, tp" : "=r" (x) );
    800025ec:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800025ee:	00011917          	auipc	s2,0x11
    800025f2:	0b290913          	addi	s2,s2,178 # 800136a0 <pid_lock>
    800025f6:	0007871b          	sext.w	a4,a5
    800025fa:	00471793          	slli	a5,a4,0x4
    800025fe:	97ba                	add	a5,a5,a4
    80002600:	078e                	slli	a5,a5,0x3
    80002602:	97ca                	add	a5,a5,s2
    80002604:	0c47a983          	lw	s3,196(a5)
    80002608:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    8000260a:	0007859b          	sext.w	a1,a5
    8000260e:	00459793          	slli	a5,a1,0x4
    80002612:	97ae                	add	a5,a5,a1
    80002614:	078e                	slli	a5,a5,0x3
    80002616:	00011597          	auipc	a1,0x11
    8000261a:	0da58593          	addi	a1,a1,218 # 800136f0 <cpus+0x8>
    8000261e:	95be                	add	a1,a1,a5
    80002620:	04848513          	addi	a0,s1,72
    80002624:	00001097          	auipc	ra,0x1
    80002628:	e7c080e7          	jalr	-388(ra) # 800034a0 <swtch>
    8000262c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000262e:	0007871b          	sext.w	a4,a5
    80002632:	00471793          	slli	a5,a4,0x4
    80002636:	97ba                	add	a5,a5,a4
    80002638:	078e                	slli	a5,a5,0x3
    8000263a:	97ca                	add	a5,a5,s2
    8000263c:	0d37a223          	sw	s3,196(a5)
}
    80002640:	70a2                	ld	ra,40(sp)
    80002642:	7402                	ld	s0,32(sp)
    80002644:	64e2                	ld	s1,24(sp)
    80002646:	6942                	ld	s2,16(sp)
    80002648:	69a2                	ld	s3,8(sp)
    8000264a:	6145                	addi	sp,sp,48
    8000264c:	8082                	ret
    panic("sched t->lock");
    8000264e:	00007517          	auipc	a0,0x7
    80002652:	cb250513          	addi	a0,a0,-846 # 80009300 <digits+0x2b0>
    80002656:	ffffe097          	auipc	ra,0xffffe
    8000265a:	ed8080e7          	jalr	-296(ra) # 8000052e <panic>
    panic("sched locks");
    8000265e:	00007517          	auipc	a0,0x7
    80002662:	cb250513          	addi	a0,a0,-846 # 80009310 <digits+0x2c0>
    80002666:	ffffe097          	auipc	ra,0xffffe
    8000266a:	ec8080e7          	jalr	-312(ra) # 8000052e <panic>
              int proc_index= (int)(p-proc);// TODO delete
    8000266e:	00011797          	auipc	a5,0x11
    80002672:	4ba78793          	addi	a5,a5,1210 # 80013b28 <proc>
    80002676:	40f907b3          	sub	a5,s2,a5
    8000267a:	878d                	srai	a5,a5,0x3
    printf("sched%d\n",proc_index);
    8000267c:	00007597          	auipc	a1,0x7
    80002680:	98c5b583          	ld	a1,-1652(a1) # 80009008 <etext+0x8>
    80002684:	02b785bb          	mulw	a1,a5,a1
    80002688:	00007517          	auipc	a0,0x7
    8000268c:	c9850513          	addi	a0,a0,-872 # 80009320 <digits+0x2d0>
    80002690:	ffffe097          	auipc	ra,0xffffe
    80002694:	ee8080e7          	jalr	-280(ra) # 80000578 <printf>
    panic("sched running");
    80002698:	00007517          	auipc	a0,0x7
    8000269c:	c9850513          	addi	a0,a0,-872 # 80009330 <digits+0x2e0>
    800026a0:	ffffe097          	auipc	ra,0xffffe
    800026a4:	e8e080e7          	jalr	-370(ra) # 8000052e <panic>
    panic("sched interruptible");
    800026a8:	00007517          	auipc	a0,0x7
    800026ac:	c9850513          	addi	a0,a0,-872 # 80009340 <digits+0x2f0>
    800026b0:	ffffe097          	auipc	ra,0xffffe
    800026b4:	e7e080e7          	jalr	-386(ra) # 8000052e <panic>

00000000800026b8 <yield>:
{
    800026b8:	1101                	addi	sp,sp,-32
    800026ba:	ec06                	sd	ra,24(sp)
    800026bc:	e822                	sd	s0,16(sp)
    800026be:	e426                	sd	s1,8(sp)
    800026c0:	1000                	addi	s0,sp,32
  struct kthread *t =mykthread();
    800026c2:	fffff097          	auipc	ra,0xfffff
    800026c6:	6fc080e7          	jalr	1788(ra) # 80001dbe <mykthread>
    800026ca:	84aa                	mv	s1,a0
  acquire(&t->lock);
    800026cc:	ffffe097          	auipc	ra,0xffffe
    800026d0:	53c080e7          	jalr	1340(ra) # 80000c08 <acquire>
  t->state = TRUNNABLE;
    800026d4:	478d                	li	a5,3
    800026d6:	cc9c                	sw	a5,24(s1)
  sched();
    800026d8:	00000097          	auipc	ra,0x0
    800026dc:	eb6080e7          	jalr	-330(ra) # 8000258e <sched>
  release(&t->lock);
    800026e0:	8526                	mv	a0,s1
    800026e2:	ffffe097          	auipc	ra,0xffffe
    800026e6:	5fc080e7          	jalr	1532(ra) # 80000cde <release>
}
    800026ea:	60e2                	ld	ra,24(sp)
    800026ec:	6442                	ld	s0,16(sp)
    800026ee:	64a2                	ld	s1,8(sp)
    800026f0:	6105                	addi	sp,sp,32
    800026f2:	8082                	ret

00000000800026f4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800026f4:	7179                	addi	sp,sp,-48
    800026f6:	f406                	sd	ra,40(sp)
    800026f8:	f022                	sd	s0,32(sp)
    800026fa:	ec26                	sd	s1,24(sp)
    800026fc:	e84a                	sd	s2,16(sp)
    800026fe:	e44e                	sd	s3,8(sp)
    80002700:	1800                	addi	s0,sp,48
    80002702:	89aa                	mv	s3,a0
    80002704:	892e                	mv	s2,a1
  struct kthread *t=mykthread();
    80002706:	fffff097          	auipc	ra,0xfffff
    8000270a:	6b8080e7          	jalr	1720(ra) # 80001dbe <mykthread>
    8000270e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&t->lock);  //DOC: sleeplock1
    80002710:	ffffe097          	auipc	ra,0xffffe
    80002714:	4f8080e7          	jalr	1272(ra) # 80000c08 <acquire>
  release(lk);
    80002718:	854a                	mv	a0,s2
    8000271a:	ffffe097          	auipc	ra,0xffffe
    8000271e:	5c4080e7          	jalr	1476(ra) # 80000cde <release>

  // Go to sleep.
  t->chan = chan;
    80002722:	0334b023          	sd	s3,32(s1)
  t->state = TSLEEPING;
    80002726:	4789                	li	a5,2
    80002728:	cc9c                	sw	a5,24(s1)

  sched();
    8000272a:	00000097          	auipc	ra,0x0
    8000272e:	e64080e7          	jalr	-412(ra) # 8000258e <sched>

  // Tidy up.
  t->chan = 0;
    80002732:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&t->lock);
    80002736:	8526                	mv	a0,s1
    80002738:	ffffe097          	auipc	ra,0xffffe
    8000273c:	5a6080e7          	jalr	1446(ra) # 80000cde <release>

  acquire(lk);
    80002740:	854a                	mv	a0,s2
    80002742:	ffffe097          	auipc	ra,0xffffe
    80002746:	4c6080e7          	jalr	1222(ra) # 80000c08 <acquire>
}
    8000274a:	70a2                	ld	ra,40(sp)
    8000274c:	7402                	ld	s0,32(sp)
    8000274e:	64e2                	ld	s1,24(sp)
    80002750:	6942                	ld	s2,16(sp)
    80002752:	69a2                	ld	s3,8(sp)
    80002754:	6145                	addi	sp,sp,48
    80002756:	8082                	ret

0000000080002758 <wait>:
{
    80002758:	715d                	addi	sp,sp,-80
    8000275a:	e486                	sd	ra,72(sp)
    8000275c:	e0a2                	sd	s0,64(sp)
    8000275e:	fc26                	sd	s1,56(sp)
    80002760:	f84a                	sd	s2,48(sp)
    80002762:	f44e                	sd	s3,40(sp)
    80002764:	f052                	sd	s4,32(sp)
    80002766:	ec56                	sd	s5,24(sp)
    80002768:	e85a                	sd	s6,16(sp)
    8000276a:	e45e                	sd	s7,8(sp)
    8000276c:	0880                	addi	s0,sp,80
    8000276e:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002770:	fffff097          	auipc	ra,0xfffff
    80002774:	60e080e7          	jalr	1550(ra) # 80001d7e <myproc>
    80002778:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000277a:	00011517          	auipc	a0,0x11
    8000277e:	f5650513          	addi	a0,a0,-170 # 800136d0 <wait_lock>
    80002782:	ffffe097          	auipc	ra,0xffffe
    80002786:	486080e7          	jalr	1158(ra) # 80000c08 <acquire>
        if(np->state == ZOMBIE){
    8000278a:	4b0d                	li	s6,3
        havekids = 1;
    8000278c:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000278e:	6985                	lui	s3,0x1
    80002790:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002794:	00032a17          	auipc	s4,0x32
    80002798:	594a0a13          	addi	s4,s4,1428 # 80034d28 <tickslock>
    havekids = 0;
    8000279c:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    8000279e:	00011497          	auipc	s1,0x11
    800027a2:	38a48493          	addi	s1,s1,906 # 80013b28 <proc>
    800027a6:	a0b5                	j	80002812 <wait+0xba>
          pid = np->pid;
    800027a8:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800027ac:	000b8e63          	beqz	s7,800027c8 <wait+0x70>
    800027b0:	4691                	li	a3,4
    800027b2:	02048613          	addi	a2,s1,32
    800027b6:	85de                	mv	a1,s7
    800027b8:	04093503          	ld	a0,64(s2)
    800027bc:	fffff097          	auipc	ra,0xfffff
    800027c0:	1aa080e7          	jalr	426(ra) # 80001966 <copyout>
    800027c4:	02054563          	bltz	a0,800027ee <wait+0x96>
          freeproc(np);
    800027c8:	8526                	mv	a0,s1
    800027ca:	00000097          	auipc	ra,0x0
    800027ce:	83e080e7          	jalr	-1986(ra) # 80002008 <freeproc>
          release(&np->lock);
    800027d2:	8526                	mv	a0,s1
    800027d4:	ffffe097          	auipc	ra,0xffffe
    800027d8:	50a080e7          	jalr	1290(ra) # 80000cde <release>
          release(&wait_lock);
    800027dc:	00011517          	auipc	a0,0x11
    800027e0:	ef450513          	addi	a0,a0,-268 # 800136d0 <wait_lock>
    800027e4:	ffffe097          	auipc	ra,0xffffe
    800027e8:	4fa080e7          	jalr	1274(ra) # 80000cde <release>
          return pid;
    800027ec:	a09d                	j	80002852 <wait+0xfa>
            release(&np->lock);
    800027ee:	8526                	mv	a0,s1
    800027f0:	ffffe097          	auipc	ra,0xffffe
    800027f4:	4ee080e7          	jalr	1262(ra) # 80000cde <release>
            release(&wait_lock);
    800027f8:	00011517          	auipc	a0,0x11
    800027fc:	ed850513          	addi	a0,a0,-296 # 800136d0 <wait_lock>
    80002800:	ffffe097          	auipc	ra,0xffffe
    80002804:	4de080e7          	jalr	1246(ra) # 80000cde <release>
            return -1;
    80002808:	59fd                	li	s3,-1
    8000280a:	a0a1                	j	80002852 <wait+0xfa>
    for(np = proc; np < &proc[NPROC]; np++){
    8000280c:	94ce                	add	s1,s1,s3
    8000280e:	03448463          	beq	s1,s4,80002836 <wait+0xde>
      if(np->parent == p){
    80002812:	789c                	ld	a5,48(s1)
    80002814:	ff279ce3          	bne	a5,s2,8000280c <wait+0xb4>
        acquire(&np->lock);
    80002818:	8526                	mv	a0,s1
    8000281a:	ffffe097          	auipc	ra,0xffffe
    8000281e:	3ee080e7          	jalr	1006(ra) # 80000c08 <acquire>
        if(np->state == ZOMBIE){
    80002822:	4c9c                	lw	a5,24(s1)
    80002824:	f96782e3          	beq	a5,s6,800027a8 <wait+0x50>
        release(&np->lock);
    80002828:	8526                	mv	a0,s1
    8000282a:	ffffe097          	auipc	ra,0xffffe
    8000282e:	4b4080e7          	jalr	1204(ra) # 80000cde <release>
        havekids = 1;
    80002832:	8756                	mv	a4,s5
    80002834:	bfe1                	j	8000280c <wait+0xb4>
    if(!havekids || p->killed==1){
    80002836:	c709                	beqz	a4,80002840 <wait+0xe8>
    80002838:	01c92783          	lw	a5,28(s2)
    8000283c:	03579763          	bne	a5,s5,8000286a <wait+0x112>
      release(&wait_lock);
    80002840:	00011517          	auipc	a0,0x11
    80002844:	e9050513          	addi	a0,a0,-368 # 800136d0 <wait_lock>
    80002848:	ffffe097          	auipc	ra,0xffffe
    8000284c:	496080e7          	jalr	1174(ra) # 80000cde <release>
      return -1;
    80002850:	59fd                	li	s3,-1
}
    80002852:	854e                	mv	a0,s3
    80002854:	60a6                	ld	ra,72(sp)
    80002856:	6406                	ld	s0,64(sp)
    80002858:	74e2                	ld	s1,56(sp)
    8000285a:	7942                	ld	s2,48(sp)
    8000285c:	79a2                	ld	s3,40(sp)
    8000285e:	7a02                	ld	s4,32(sp)
    80002860:	6ae2                	ld	s5,24(sp)
    80002862:	6b42                	ld	s6,16(sp)
    80002864:	6ba2                	ld	s7,8(sp)
    80002866:	6161                	addi	sp,sp,80
    80002868:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000286a:	00011597          	auipc	a1,0x11
    8000286e:	e6658593          	addi	a1,a1,-410 # 800136d0 <wait_lock>
    80002872:	854a                	mv	a0,s2
    80002874:	00000097          	auipc	ra,0x0
    80002878:	e80080e7          	jalr	-384(ra) # 800026f4 <sleep>
    havekids = 0;
    8000287c:	b705                	j	8000279c <wait+0x44>

000000008000287e <wakeup>:
// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
// returns true if someone was waiting, else false
int
wakeup(void *chan)
{
    8000287e:	7159                	addi	sp,sp,-112
    80002880:	f486                	sd	ra,104(sp)
    80002882:	f0a2                	sd	s0,96(sp)
    80002884:	eca6                	sd	s1,88(sp)
    80002886:	e8ca                	sd	s2,80(sp)
    80002888:	e4ce                	sd	s3,72(sp)
    8000288a:	e0d2                	sd	s4,64(sp)
    8000288c:	fc56                	sd	s5,56(sp)
    8000288e:	f85a                	sd	s6,48(sp)
    80002890:	f45e                	sd	s7,40(sp)
    80002892:	f062                	sd	s8,32(sp)
    80002894:	ec66                	sd	s9,24(sp)
    80002896:	e86a                	sd	s10,16(sp)
    80002898:	e46e                	sd	s11,8(sp)
    8000289a:	1880                	addi	s0,sp,112
    8000289c:	8baa                	mv	s7,a0
  struct proc *p;
  struct kthread *t;
  struct kthread *my_t = mykthread();
    8000289e:	fffff097          	auipc	ra,0xfffff
    800028a2:	520080e7          	jalr	1312(ra) # 80001dbe <mykthread>
    800028a6:	8a2a                	mv	s4,a0
  int waited = 0;


  for(p = proc; p < &proc[NPROC]; p++) {
    800028a8:	00011917          	auipc	s2,0x11
    800028ac:	50890913          	addi	s2,s2,1288 # 80013db0 <proc+0x288>
    800028b0:	00032b17          	auipc	s6,0x32
    800028b4:	700b0b13          	addi	s6,s6,1792 # 80034fb0 <bcache+0x270>
  int waited = 0;
    800028b8:	4c01                	li	s8,0
    // acquire(&p->lock);
    if(p->state == RUNNABLE){
    800028ba:	4989                	li	s3,2
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
        if(t != my_t){
          acquire(&t->lock);
          if(t->state == TSLEEPING && t->chan == chan) {
            t->state = TRUNNABLE;
    800028bc:	4d0d                	li	s10,3
            waited = 1;
    800028be:	4c85                	li	s9,1
  for(p = proc; p < &proc[NPROC]; p++) {
    800028c0:	6a85                	lui	s5,0x1
    800028c2:	848a8a93          	addi	s5,s5,-1976 # 848 <_entry-0x7ffff7b8>
    800028c6:	a835                	j	80002902 <wakeup+0x84>
          }
          release(&t->lock);
    800028c8:	8526                	mv	a0,s1
    800028ca:	ffffe097          	auipc	ra,0xffffe
    800028ce:	414080e7          	jalr	1044(ra) # 80000cde <release>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800028d2:	0b848493          	addi	s1,s1,184
    800028d6:	03b48363          	beq	s1,s11,800028fc <wakeup+0x7e>
        if(t != my_t){
    800028da:	fe9a0ce3          	beq	s4,s1,800028d2 <wakeup+0x54>
          acquire(&t->lock);
    800028de:	8526                	mv	a0,s1
    800028e0:	ffffe097          	auipc	ra,0xffffe
    800028e4:	328080e7          	jalr	808(ra) # 80000c08 <acquire>
          if(t->state == TSLEEPING && t->chan == chan) {
    800028e8:	4c9c                	lw	a5,24(s1)
    800028ea:	fd379fe3          	bne	a5,s3,800028c8 <wakeup+0x4a>
    800028ee:	709c                	ld	a5,32(s1)
    800028f0:	fd779ce3          	bne	a5,s7,800028c8 <wakeup+0x4a>
            t->state = TRUNNABLE;
    800028f4:	01a4ac23          	sw	s10,24(s1)
            waited = 1;
    800028f8:	8c66                	mv	s8,s9
    800028fa:	b7f9                	j	800028c8 <wakeup+0x4a>
  for(p = proc; p < &proc[NPROC]; p++) {
    800028fc:	9956                	add	s2,s2,s5
    800028fe:	012b0a63          	beq	s6,s2,80002912 <wakeup+0x94>
    if(p->state == RUNNABLE){
    80002902:	84ca                	mv	s1,s2
    80002904:	d9092783          	lw	a5,-624(s2)
    80002908:	ff379ae3          	bne	a5,s3,800028fc <wakeup+0x7e>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    8000290c:	5c090d93          	addi	s11,s2,1472
    80002910:	b7e9                	j	800028da <wakeup+0x5c>
      }
    }
  }

  return waited;
}
    80002912:	8562                	mv	a0,s8
    80002914:	70a6                	ld	ra,104(sp)
    80002916:	7406                	ld	s0,96(sp)
    80002918:	64e6                	ld	s1,88(sp)
    8000291a:	6946                	ld	s2,80(sp)
    8000291c:	69a6                	ld	s3,72(sp)
    8000291e:	6a06                	ld	s4,64(sp)
    80002920:	7ae2                	ld	s5,56(sp)
    80002922:	7b42                	ld	s6,48(sp)
    80002924:	7ba2                	ld	s7,40(sp)
    80002926:	7c02                	ld	s8,32(sp)
    80002928:	6ce2                	ld	s9,24(sp)
    8000292a:	6d42                	ld	s10,16(sp)
    8000292c:	6da2                	ld	s11,8(sp)
    8000292e:	6165                	addi	sp,sp,112
    80002930:	8082                	ret

0000000080002932 <reparent>:
{
    80002932:	7139                	addi	sp,sp,-64
    80002934:	fc06                	sd	ra,56(sp)
    80002936:	f822                	sd	s0,48(sp)
    80002938:	f426                	sd	s1,40(sp)
    8000293a:	f04a                	sd	s2,32(sp)
    8000293c:	ec4e                	sd	s3,24(sp)
    8000293e:	e852                	sd	s4,16(sp)
    80002940:	e456                	sd	s5,8(sp)
    80002942:	0080                	addi	s0,sp,64
    80002944:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002946:	00011497          	auipc	s1,0x11
    8000294a:	1e248493          	addi	s1,s1,482 # 80013b28 <proc>
      pp->parent = initproc;
    8000294e:	00007a97          	auipc	s5,0x7
    80002952:	6daa8a93          	addi	s5,s5,1754 # 8000a028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002956:	6905                	lui	s2,0x1
    80002958:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    8000295c:	00032a17          	auipc	s4,0x32
    80002960:	3cca0a13          	addi	s4,s4,972 # 80034d28 <tickslock>
    80002964:	a021                	j	8000296c <reparent+0x3a>
    80002966:	94ca                	add	s1,s1,s2
    80002968:	01448d63          	beq	s1,s4,80002982 <reparent+0x50>
    if(pp->parent == p){
    8000296c:	789c                	ld	a5,48(s1)
    8000296e:	ff379ce3          	bne	a5,s3,80002966 <reparent+0x34>
      pp->parent = initproc;
    80002972:	000ab503          	ld	a0,0(s5)
    80002976:	f888                	sd	a0,48(s1)
      wakeup(initproc);
    80002978:	00000097          	auipc	ra,0x0
    8000297c:	f06080e7          	jalr	-250(ra) # 8000287e <wakeup>
    80002980:	b7dd                	j	80002966 <reparent+0x34>
}
    80002982:	70e2                	ld	ra,56(sp)
    80002984:	7442                	ld	s0,48(sp)
    80002986:	74a2                	ld	s1,40(sp)
    80002988:	7902                	ld	s2,32(sp)
    8000298a:	69e2                	ld	s3,24(sp)
    8000298c:	6a42                	ld	s4,16(sp)
    8000298e:	6aa2                	ld	s5,8(sp)
    80002990:	6121                	addi	sp,sp,64
    80002992:	8082                	ret

0000000080002994 <exit_proccess>:
{
    80002994:	7139                	addi	sp,sp,-64
    80002996:	fc06                	sd	ra,56(sp)
    80002998:	f822                	sd	s0,48(sp)
    8000299a:	f426                	sd	s1,40(sp)
    8000299c:	f04a                	sd	s2,32(sp)
    8000299e:	ec4e                	sd	s3,24(sp)
    800029a0:	e852                	sd	s4,16(sp)
    800029a2:	e456                	sd	s5,8(sp)
    800029a4:	e05a                	sd	s6,0(sp)
    800029a6:	0080                	addi	s0,sp,64
    800029a8:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800029aa:	fffff097          	auipc	ra,0xfffff
    800029ae:	3d4080e7          	jalr	980(ra) # 80001d7e <myproc>
    800029b2:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    800029b4:	fffff097          	auipc	ra,0xfffff
    800029b8:	40a080e7          	jalr	1034(ra) # 80001dbe <mykthread>
    800029bc:	8aaa                	mv	s5,a0
  int proc_index= (int)(p-proc);// TODO delete
    800029be:	00011797          	auipc	a5,0x11
    800029c2:	16a78793          	addi	a5,a5,362 # 80013b28 <proc>
    800029c6:	40f987b3          	sub	a5,s3,a5
    800029ca:	878d                	srai	a5,a5,0x3
    800029cc:	00006a17          	auipc	s4,0x6
    800029d0:	63ca3a03          	ld	s4,1596(s4) # 80009008 <etext+0x8>
    800029d4:	03478a3b          	mulw	s4,a5,s4
  if(p == initproc)
    800029d8:	00007797          	auipc	a5,0x7
    800029dc:	6507b783          	ld	a5,1616(a5) # 8000a028 <initproc>
    800029e0:	05098493          	addi	s1,s3,80
    800029e4:	0d098913          	addi	s2,s3,208
    800029e8:	03379363          	bne	a5,s3,80002a0e <exit_proccess+0x7a>
    panic("init exiting");
    800029ec:	00007517          	auipc	a0,0x7
    800029f0:	96c50513          	addi	a0,a0,-1684 # 80009358 <digits+0x308>
    800029f4:	ffffe097          	auipc	ra,0xffffe
    800029f8:	b3a080e7          	jalr	-1222(ra) # 8000052e <panic>
      fileclose(f);
    800029fc:	00003097          	auipc	ra,0x3
    80002a00:	fd0080e7          	jalr	-48(ra) # 800059cc <fileclose>
      p->ofile[fd] = 0;
    80002a04:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002a08:	04a1                	addi	s1,s1,8
    80002a0a:	01248563          	beq	s1,s2,80002a14 <exit_proccess+0x80>
    if(p->ofile[fd]){
    80002a0e:	6088                	ld	a0,0(s1)
    80002a10:	f575                	bnez	a0,800029fc <exit_proccess+0x68>
    80002a12:	bfdd                	j	80002a08 <exit_proccess+0x74>
  begin_op();
    80002a14:	00003097          	auipc	ra,0x3
    80002a18:	aec080e7          	jalr	-1300(ra) # 80005500 <begin_op>
  iput(p->cwd);
    80002a1c:	0d09b503          	ld	a0,208(s3)
    80002a20:	00002097          	auipc	ra,0x2
    80002a24:	2c6080e7          	jalr	710(ra) # 80004ce6 <iput>
  end_op();
    80002a28:	00003097          	auipc	ra,0x3
    80002a2c:	b58080e7          	jalr	-1192(ra) # 80005580 <end_op>
  p->cwd = 0;
    80002a30:	0c09b823          	sd	zero,208(s3)
  acquire(&wait_lock);
    80002a34:	00011497          	auipc	s1,0x11
    80002a38:	c9c48493          	addi	s1,s1,-868 # 800136d0 <wait_lock>
    80002a3c:	8526                	mv	a0,s1
    80002a3e:	ffffe097          	auipc	ra,0xffffe
    80002a42:	1ca080e7          	jalr	458(ra) # 80000c08 <acquire>
  reparent(p);
    80002a46:	854e                	mv	a0,s3
    80002a48:	00000097          	auipc	ra,0x0
    80002a4c:	eea080e7          	jalr	-278(ra) # 80002932 <reparent>
  wakeup(p->parent);
    80002a50:	0309b503          	ld	a0,48(s3)
    80002a54:	00000097          	auipc	ra,0x0
    80002a58:	e2a080e7          	jalr	-470(ra) # 8000287e <wakeup>
  acquire(&p->lock);
    80002a5c:	854e                	mv	a0,s3
    80002a5e:	ffffe097          	auipc	ra,0xffffe
    80002a62:	1aa080e7          	jalr	426(ra) # 80000c08 <acquire>
  p->xstate = status;
    80002a66:	0369a023          	sw	s6,32(s3)
  p->state = ZOMBIE;
    80002a6a:	478d                	li	a5,3
    80002a6c:	00f9ac23          	sw	a5,24(s3)
  t->state=TZOMBIE;
    80002a70:	4795                	li	a5,5
    80002a72:	00faac23          	sw	a5,24(s5)
  release(&wait_lock);
    80002a76:	8526                	mv	a0,s1
    80002a78:	ffffe097          	auipc	ra,0xffffe
    80002a7c:	266080e7          	jalr	614(ra) # 80000cde <release>
  acquire(&t->lock);
    80002a80:	8556                	mv	a0,s5
    80002a82:	ffffe097          	auipc	ra,0xffffe
    80002a86:	186080e7          	jalr	390(ra) # 80000c08 <acquire>
  release(&p->lock);// ze po achav :) 
    80002a8a:	854e                	mv	a0,s3
    80002a8c:	ffffe097          	auipc	ra,0xffffe
    80002a90:	252080e7          	jalr	594(ra) # 80000cde <release>
  sched();
    80002a94:	00000097          	auipc	ra,0x0
    80002a98:	afa080e7          	jalr	-1286(ra) # 8000258e <sched>
  printf("zombie exit %d\n",proc_index);
    80002a9c:	85d2                	mv	a1,s4
    80002a9e:	00007517          	auipc	a0,0x7
    80002aa2:	8ca50513          	addi	a0,a0,-1846 # 80009368 <digits+0x318>
    80002aa6:	ffffe097          	auipc	ra,0xffffe
    80002aaa:	ad2080e7          	jalr	-1326(ra) # 80000578 <printf>
  panic("zombie exit");
    80002aae:	00007517          	auipc	a0,0x7
    80002ab2:	8ca50513          	addi	a0,a0,-1846 # 80009378 <digits+0x328>
    80002ab6:	ffffe097          	auipc	ra,0xffffe
    80002aba:	a78080e7          	jalr	-1416(ra) # 8000052e <panic>

0000000080002abe <kthread_exit>:
kthread_exit(int status){
    80002abe:	7179                	addi	sp,sp,-48
    80002ac0:	f406                	sd	ra,40(sp)
    80002ac2:	f022                	sd	s0,32(sp)
    80002ac4:	ec26                	sd	s1,24(sp)
    80002ac6:	e84a                	sd	s2,16(sp)
    80002ac8:	e44e                	sd	s3,8(sp)
    80002aca:	e052                	sd	s4,0(sp)
    80002acc:	1800                	addi	s0,sp,48
    80002ace:	89aa                	mv	s3,a0
  struct proc *p = myproc(); 
    80002ad0:	fffff097          	auipc	ra,0xfffff
    80002ad4:	2ae080e7          	jalr	686(ra) # 80001d7e <myproc>
    80002ad8:	892a                	mv	s2,a0
  struct kthread *t=mykthread();
    80002ada:	fffff097          	auipc	ra,0xfffff
    80002ade:	2e4080e7          	jalr	740(ra) # 80001dbe <mykthread>
    80002ae2:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002ae4:	854a                	mv	a0,s2
    80002ae6:	ffffe097          	auipc	ra,0xffffe
    80002aea:	122080e7          	jalr	290(ra) # 80000c08 <acquire>
  p->active_threads--;
    80002aee:	02892783          	lw	a5,40(s2)
    80002af2:	37fd                	addiw	a5,a5,-1
    80002af4:	00078a1b          	sext.w	s4,a5
    80002af8:	02f92423          	sw	a5,40(s2)
  release(&p->lock);
    80002afc:	854a                	mv	a0,s2
    80002afe:	ffffe097          	auipc	ra,0xffffe
    80002b02:	1e0080e7          	jalr	480(ra) # 80000cde <release>
  acquire(&t->lock);
    80002b06:	8526                	mv	a0,s1
    80002b08:	ffffe097          	auipc	ra,0xffffe
    80002b0c:	100080e7          	jalr	256(ra) # 80000c08 <acquire>
  t->xstate = status;
    80002b10:	0334a623          	sw	s3,44(s1)
  t->state  = TZOMBIE;
    80002b14:	4795                	li	a5,5
    80002b16:	cc9c                	sw	a5,24(s1)
  release(&t->lock);
    80002b18:	8526                	mv	a0,s1
    80002b1a:	ffffe097          	auipc	ra,0xffffe
    80002b1e:	1c4080e7          	jalr	452(ra) # 80000cde <release>
  wakeup(t);
    80002b22:	8526                	mv	a0,s1
    80002b24:	00000097          	auipc	ra,0x0
    80002b28:	d5a080e7          	jalr	-678(ra) # 8000287e <wakeup>
  if(curr_active_threads==0){
    80002b2c:	000a1763          	bnez	s4,80002b3a <kthread_exit+0x7c>
    exit_proccess(status);
    80002b30:	854e                	mv	a0,s3
    80002b32:	00000097          	auipc	ra,0x0
    80002b36:	e62080e7          	jalr	-414(ra) # 80002994 <exit_proccess>
    acquire(&t->lock);
    80002b3a:	8526                	mv	a0,s1
    80002b3c:	ffffe097          	auipc	ra,0xffffe
    80002b40:	0cc080e7          	jalr	204(ra) # 80000c08 <acquire>
    sched();
    80002b44:	00000097          	auipc	ra,0x0
    80002b48:	a4a080e7          	jalr	-1462(ra) # 8000258e <sched>
    panic("zombie thread exit");
    80002b4c:	00007517          	auipc	a0,0x7
    80002b50:	83c50513          	addi	a0,a0,-1988 # 80009388 <digits+0x338>
    80002b54:	ffffe097          	auipc	ra,0xffffe
    80002b58:	9da080e7          	jalr	-1574(ra) # 8000052e <panic>

0000000080002b5c <exit>:
exit(int status){
    80002b5c:	7139                	addi	sp,sp,-64
    80002b5e:	fc06                	sd	ra,56(sp)
    80002b60:	f822                	sd	s0,48(sp)
    80002b62:	f426                	sd	s1,40(sp)
    80002b64:	f04a                	sd	s2,32(sp)
    80002b66:	ec4e                	sd	s3,24(sp)
    80002b68:	e852                	sd	s4,16(sp)
    80002b6a:	e456                	sd	s5,8(sp)
    80002b6c:	e05a                	sd	s6,0(sp)
    80002b6e:	0080                	addi	s0,sp,64
    80002b70:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    80002b72:	fffff097          	auipc	ra,0xfffff
    80002b76:	20c080e7          	jalr	524(ra) # 80001d7e <myproc>
    80002b7a:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80002b7c:	fffff097          	auipc	ra,0xfffff
    80002b80:	242080e7          	jalr	578(ra) # 80001dbe <mykthread>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002b84:	28890493          	addi	s1,s2,648
    80002b88:	6505                	lui	a0,0x1
    80002b8a:	84850513          	addi	a0,a0,-1976 # 848 <_entry-0x7ffff7b8>
    80002b8e:	992a                	add	s2,s2,a0
    t->killed = 1;
    80002b90:	4a05                	li	s4,1
    if(t->state == TSLEEPING)
    80002b92:	4989                	li	s3,2
      t->state = TRUNNABLE;
    80002b94:	4b0d                	li	s6,3
    80002b96:	a811                	j	80002baa <exit+0x4e>
    release(&t->lock);
    80002b98:	8526                	mv	a0,s1
    80002b9a:	ffffe097          	auipc	ra,0xffffe
    80002b9e:	144080e7          	jalr	324(ra) # 80000cde <release>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002ba2:	0b848493          	addi	s1,s1,184
    80002ba6:	00990f63          	beq	s2,s1,80002bc4 <exit+0x68>
    acquire(&t->lock);
    80002baa:	8526                	mv	a0,s1
    80002bac:	ffffe097          	auipc	ra,0xffffe
    80002bb0:	05c080e7          	jalr	92(ra) # 80000c08 <acquire>
    t->killed = 1;
    80002bb4:	0344a423          	sw	s4,40(s1)
    if(t->state == TSLEEPING)
    80002bb8:	4c9c                	lw	a5,24(s1)
    80002bba:	fd379fe3          	bne	a5,s3,80002b98 <exit+0x3c>
      t->state = TRUNNABLE;
    80002bbe:	0164ac23          	sw	s6,24(s1)
    80002bc2:	bfd9                	j	80002b98 <exit+0x3c>
  kthread_exit(status);
    80002bc4:	8556                	mv	a0,s5
    80002bc6:	00000097          	auipc	ra,0x0
    80002bca:	ef8080e7          	jalr	-264(ra) # 80002abe <kthread_exit>

0000000080002bce <sig_stop>:
//   return -1;
// }

int
sig_stop(int pid)//TODO delete if not used
{
    80002bce:	7179                	addi	sp,sp,-48
    80002bd0:	f406                	sd	ra,40(sp)
    80002bd2:	f022                	sd	s0,32(sp)
    80002bd4:	ec26                	sd	s1,24(sp)
    80002bd6:	e84a                	sd	s2,16(sp)
    80002bd8:	e44e                	sd	s3,8(sp)
    80002bda:	e052                	sd	s4,0(sp)
    80002bdc:	1800                	addi	s0,sp,48
    80002bde:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002be0:	00011497          	auipc	s1,0x11
    80002be4:	f4848493          	addi	s1,s1,-184 # 80013b28 <proc>
    80002be8:	6985                	lui	s3,0x1
    80002bea:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002bee:	00032a17          	auipc	s4,0x32
    80002bf2:	13aa0a13          	addi	s4,s4,314 # 80034d28 <tickslock>
    acquire(&p->lock);
    80002bf6:	8526                	mv	a0,s1
    80002bf8:	ffffe097          	auipc	ra,0xffffe
    80002bfc:	010080e7          	jalr	16(ra) # 80000c08 <acquire>
    if(p->pid == pid){
    80002c00:	50dc                	lw	a5,36(s1)
    80002c02:	01278c63          	beq	a5,s2,80002c1a <sig_stop+0x4c>
      p->pending_signals|=(1<<SIGSTOP);

      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002c06:	8526                	mv	a0,s1
    80002c08:	ffffe097          	auipc	ra,0xffffe
    80002c0c:	0d6080e7          	jalr	214(ra) # 80000cde <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002c10:	94ce                	add	s1,s1,s3
    80002c12:	ff4492e3          	bne	s1,s4,80002bf6 <sig_stop+0x28>
  }
  return -1;
    80002c16:	557d                	li	a0,-1
    80002c18:	a831                	j	80002c34 <sig_stop+0x66>
      p->pending_signals|=(1<<SIGSTOP);
    80002c1a:	0e84a783          	lw	a5,232(s1)
    80002c1e:	00020737          	lui	a4,0x20
    80002c22:	8fd9                	or	a5,a5,a4
    80002c24:	0ef4a423          	sw	a5,232(s1)
      release(&p->lock);
    80002c28:	8526                	mv	a0,s1
    80002c2a:	ffffe097          	auipc	ra,0xffffe
    80002c2e:	0b4080e7          	jalr	180(ra) # 80000cde <release>
      return 0;
    80002c32:	4501                	li	a0,0
}
    80002c34:	70a2                	ld	ra,40(sp)
    80002c36:	7402                	ld	s0,32(sp)
    80002c38:	64e2                	ld	s1,24(sp)
    80002c3a:	6942                	ld	s2,16(sp)
    80002c3c:	69a2                	ld	s3,8(sp)
    80002c3e:	6a02                	ld	s4,0(sp)
    80002c40:	6145                	addi	sp,sp,48
    80002c42:	8082                	ret

0000000080002c44 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002c44:	7179                	addi	sp,sp,-48
    80002c46:	f406                	sd	ra,40(sp)
    80002c48:	f022                	sd	s0,32(sp)
    80002c4a:	ec26                	sd	s1,24(sp)
    80002c4c:	e84a                	sd	s2,16(sp)
    80002c4e:	e44e                	sd	s3,8(sp)
    80002c50:	e052                	sd	s4,0(sp)
    80002c52:	1800                	addi	s0,sp,48
    80002c54:	84aa                	mv	s1,a0
    80002c56:	892e                	mv	s2,a1
    80002c58:	89b2                	mv	s3,a2
    80002c5a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002c5c:	fffff097          	auipc	ra,0xfffff
    80002c60:	122080e7          	jalr	290(ra) # 80001d7e <myproc>
  if(user_dst){
    80002c64:	c08d                	beqz	s1,80002c86 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002c66:	86d2                	mv	a3,s4
    80002c68:	864e                	mv	a2,s3
    80002c6a:	85ca                	mv	a1,s2
    80002c6c:	6128                	ld	a0,64(a0)
    80002c6e:	fffff097          	auipc	ra,0xfffff
    80002c72:	cf8080e7          	jalr	-776(ra) # 80001966 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002c76:	70a2                	ld	ra,40(sp)
    80002c78:	7402                	ld	s0,32(sp)
    80002c7a:	64e2                	ld	s1,24(sp)
    80002c7c:	6942                	ld	s2,16(sp)
    80002c7e:	69a2                	ld	s3,8(sp)
    80002c80:	6a02                	ld	s4,0(sp)
    80002c82:	6145                	addi	sp,sp,48
    80002c84:	8082                	ret
    memmove((char *)dst, src, len);
    80002c86:	000a061b          	sext.w	a2,s4
    80002c8a:	85ce                	mv	a1,s3
    80002c8c:	854a                	mv	a0,s2
    80002c8e:	ffffe097          	auipc	ra,0xffffe
    80002c92:	3ac080e7          	jalr	940(ra) # 8000103a <memmove>
    return 0;
    80002c96:	8526                	mv	a0,s1
    80002c98:	bff9                	j	80002c76 <either_copyout+0x32>

0000000080002c9a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002c9a:	7179                	addi	sp,sp,-48
    80002c9c:	f406                	sd	ra,40(sp)
    80002c9e:	f022                	sd	s0,32(sp)
    80002ca0:	ec26                	sd	s1,24(sp)
    80002ca2:	e84a                	sd	s2,16(sp)
    80002ca4:	e44e                	sd	s3,8(sp)
    80002ca6:	e052                	sd	s4,0(sp)
    80002ca8:	1800                	addi	s0,sp,48
    80002caa:	892a                	mv	s2,a0
    80002cac:	84ae                	mv	s1,a1
    80002cae:	89b2                	mv	s3,a2
    80002cb0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002cb2:	fffff097          	auipc	ra,0xfffff
    80002cb6:	0cc080e7          	jalr	204(ra) # 80001d7e <myproc>
  if(user_src){
    80002cba:	c08d                	beqz	s1,80002cdc <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002cbc:	86d2                	mv	a3,s4
    80002cbe:	864e                	mv	a2,s3
    80002cc0:	85ca                	mv	a1,s2
    80002cc2:	6128                	ld	a0,64(a0)
    80002cc4:	fffff097          	auipc	ra,0xfffff
    80002cc8:	d2e080e7          	jalr	-722(ra) # 800019f2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002ccc:	70a2                	ld	ra,40(sp)
    80002cce:	7402                	ld	s0,32(sp)
    80002cd0:	64e2                	ld	s1,24(sp)
    80002cd2:	6942                	ld	s2,16(sp)
    80002cd4:	69a2                	ld	s3,8(sp)
    80002cd6:	6a02                	ld	s4,0(sp)
    80002cd8:	6145                	addi	sp,sp,48
    80002cda:	8082                	ret
    memmove(dst, (char*)src, len);
    80002cdc:	000a061b          	sext.w	a2,s4
    80002ce0:	85ce                	mv	a1,s3
    80002ce2:	854a                	mv	a0,s2
    80002ce4:	ffffe097          	auipc	ra,0xffffe
    80002ce8:	356080e7          	jalr	854(ra) # 8000103a <memmove>
    return 0;
    80002cec:	8526                	mv	a0,s1
    80002cee:	bff9                	j	80002ccc <either_copyin+0x32>

0000000080002cf0 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002cf0:	715d                	addi	sp,sp,-80
    80002cf2:	e486                	sd	ra,72(sp)
    80002cf4:	e0a2                	sd	s0,64(sp)
    80002cf6:	fc26                	sd	s1,56(sp)
    80002cf8:	f84a                	sd	s2,48(sp)
    80002cfa:	f44e                	sd	s3,40(sp)
    80002cfc:	f052                	sd	s4,32(sp)
    80002cfe:	ec56                	sd	s5,24(sp)
    80002d00:	e85a                	sd	s6,16(sp)
    80002d02:	e45e                	sd	s7,8(sp)
    80002d04:	e062                	sd	s8,0(sp)
    80002d06:	0880                	addi	s0,sp,80


  struct proc *p;
  char *state;

  printf("\n");
    80002d08:	00006517          	auipc	a0,0x6
    80002d0c:	3b050513          	addi	a0,a0,944 # 800090b8 <digits+0x68>
    80002d10:	ffffe097          	auipc	ra,0xffffe
    80002d14:	868080e7          	jalr	-1944(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002d18:	00011497          	auipc	s1,0x11
    80002d1c:	ee848493          	addi	s1,s1,-280 # 80013c00 <proc+0xd8>
    80002d20:	00032997          	auipc	s3,0x32
    80002d24:	0e098993          	addi	s3,s3,224 # 80034e00 <bcache+0xc0>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002d28:	4b8d                	li	s7,3
      state = states[p->state];
    else
      state = "???";
    80002d2a:	00006a17          	auipc	s4,0x6
    80002d2e:	676a0a13          	addi	s4,s4,1654 # 800093a0 <digits+0x350>
    printf("%d %s %s", p->pid, state, p->name);
    80002d32:	00006b17          	auipc	s6,0x6
    80002d36:	676b0b13          	addi	s6,s6,1654 # 800093a8 <digits+0x358>
    printf("\n");
    80002d3a:	00006a97          	auipc	s5,0x6
    80002d3e:	37ea8a93          	addi	s5,s5,894 # 800090b8 <digits+0x68>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002d42:	00006c17          	auipc	s8,0x6
    80002d46:	726c0c13          	addi	s8,s8,1830 # 80009468 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80002d4a:	6905                	lui	s2,0x1
    80002d4c:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80002d50:	a005                	j	80002d70 <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    80002d52:	f4c6a583          	lw	a1,-180(a3)
    80002d56:	855a                	mv	a0,s6
    80002d58:	ffffe097          	auipc	ra,0xffffe
    80002d5c:	820080e7          	jalr	-2016(ra) # 80000578 <printf>
    printf("\n");
    80002d60:	8556                	mv	a0,s5
    80002d62:	ffffe097          	auipc	ra,0xffffe
    80002d66:	816080e7          	jalr	-2026(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002d6a:	94ca                	add	s1,s1,s2
    80002d6c:	03348263          	beq	s1,s3,80002d90 <procdump+0xa0>
    if(p->state == UNUSED)
    80002d70:	86a6                	mv	a3,s1
    80002d72:	f404a783          	lw	a5,-192(s1)
    80002d76:	dbf5                	beqz	a5,80002d6a <procdump+0x7a>
      state = "???";
    80002d78:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002d7a:	fcfbece3          	bltu	s7,a5,80002d52 <procdump+0x62>
    80002d7e:	02079713          	slli	a4,a5,0x20
    80002d82:	01d75793          	srli	a5,a4,0x1d
    80002d86:	97e2                	add	a5,a5,s8
    80002d88:	6390                	ld	a2,0(a5)
    80002d8a:	f661                	bnez	a2,80002d52 <procdump+0x62>
      state = "???";
    80002d8c:	8652                	mv	a2,s4
    80002d8e:	b7d1                	j	80002d52 <procdump+0x62>
  }
}
    80002d90:	60a6                	ld	ra,72(sp)
    80002d92:	6406                	ld	s0,64(sp)
    80002d94:	74e2                	ld	s1,56(sp)
    80002d96:	7942                	ld	s2,48(sp)
    80002d98:	79a2                	ld	s3,40(sp)
    80002d9a:	7a02                	ld	s4,32(sp)
    80002d9c:	6ae2                	ld	s5,24(sp)
    80002d9e:	6b42                	ld	s6,16(sp)
    80002da0:	6ba2                	ld	s7,8(sp)
    80002da2:	6c02                	ld	s8,0(sp)
    80002da4:	6161                	addi	sp,sp,80
    80002da6:	8082                	ret

0000000080002da8 <is_valid_sigmask>:

int 
is_valid_sigmask(int sigmask){
    80002da8:	1141                	addi	sp,sp,-16
    80002daa:	e422                	sd	s0,8(sp)
    80002dac:	0800                	addi	s0,sp,16
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002dae:	000207b7          	lui	a5,0x20
    80002db2:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002db6:	8d7d                	and	a0,a0,a5
    return 0;
  return 1;
}
    80002db8:	00153513          	seqz	a0,a0
    80002dbc:	6422                	ld	s0,8(sp)
    80002dbe:	0141                	addi	sp,sp,16
    80002dc0:	8082                	ret

0000000080002dc2 <sigprocmask>:

uint
sigprocmask(uint new_procmask){
    80002dc2:	7179                	addi	sp,sp,-48
    80002dc4:	f406                	sd	ra,40(sp)
    80002dc6:	f022                	sd	s0,32(sp)
    80002dc8:	ec26                	sd	s1,24(sp)
    80002dca:	e84a                	sd	s2,16(sp)
    80002dcc:	e44e                	sd	s3,8(sp)
    80002dce:	1800                	addi	s0,sp,48
    80002dd0:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002dd2:	fffff097          	auipc	ra,0xfffff
    80002dd6:	fac080e7          	jalr	-84(ra) # 80001d7e <myproc>
  if(is_valid_sigmask(new_procmask) == 0)
    80002dda:	000207b7          	lui	a5,0x20
    80002dde:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002de2:	00f977b3          	and	a5,s2,a5
    return -1;
    80002de6:	59fd                	li	s3,-1
  if(is_valid_sigmask(new_procmask) == 0)
    80002de8:	ef99                	bnez	a5,80002e06 <sigprocmask+0x44>
    80002dea:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002dec:	ffffe097          	auipc	ra,0xffffe
    80002df0:	e1c080e7          	jalr	-484(ra) # 80000c08 <acquire>
  int old_procmask = p->signal_mask;
    80002df4:	0ec4a983          	lw	s3,236(s1)
  p->signal_mask = new_procmask;
    80002df8:	0f24a623          	sw	s2,236(s1)
  release(&p->lock);
    80002dfc:	8526                	mv	a0,s1
    80002dfe:	ffffe097          	auipc	ra,0xffffe
    80002e02:	ee0080e7          	jalr	-288(ra) # 80000cde <release>
  
  return old_procmask;
}
    80002e06:	854e                	mv	a0,s3
    80002e08:	70a2                	ld	ra,40(sp)
    80002e0a:	7402                	ld	s0,32(sp)
    80002e0c:	64e2                	ld	s1,24(sp)
    80002e0e:	6942                	ld	s2,16(sp)
    80002e10:	69a2                	ld	s3,8(sp)
    80002e12:	6145                	addi	sp,sp,48
    80002e14:	8082                	ret

0000000080002e16 <sigaction>:

 
int 
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
  
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002e16:	0005079b          	sext.w	a5,a0
    80002e1a:	477d                	li	a4,31
    80002e1c:	0cf76a63          	bltu	a4,a5,80002ef0 <sigaction+0xda>
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
    80002e20:	7139                	addi	sp,sp,-64
    80002e22:	fc06                	sd	ra,56(sp)
    80002e24:	f822                	sd	s0,48(sp)
    80002e26:	f426                	sd	s1,40(sp)
    80002e28:	f04a                	sd	s2,32(sp)
    80002e2a:	ec4e                	sd	s3,24(sp)
    80002e2c:	e852                	sd	s4,16(sp)
    80002e2e:	0080                	addi	s0,sp,64
    80002e30:	84aa                	mv	s1,a0
    80002e32:	89ae                	mv	s3,a1
    80002e34:	8a32                	mv	s4,a2
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002e36:	37dd                	addiw	a5,a5,-9
    80002e38:	9bdd                	andi	a5,a5,-9
    80002e3a:	2781                	sext.w	a5,a5
    80002e3c:	cfc5                	beqz	a5,80002ef4 <sigaction+0xde>
    80002e3e:	cdcd                	beqz	a1,80002ef8 <sigaction+0xe2>
    return -1;
  struct proc *p = myproc();
    80002e40:	fffff097          	auipc	ra,0xfffff
    80002e44:	f3e080e7          	jalr	-194(ra) # 80001d7e <myproc>
    80002e48:	892a                	mv	s2,a0

  uint new_mask;
  copyin(p->pagetable, (char *)&new_mask, (uint64)&act->sigmask, sizeof(act->sigmask));
    80002e4a:	4691                	li	a3,4
    80002e4c:	00898613          	addi	a2,s3,8
    80002e50:	fcc40593          	addi	a1,s0,-52
    80002e54:	6128                	ld	a0,64(a0)
    80002e56:	fffff097          	auipc	ra,0xfffff
    80002e5a:	b9c080e7          	jalr	-1124(ra) # 800019f2 <copyin>
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002e5e:	fcc42703          	lw	a4,-52(s0)

  if(is_valid_sigmask(new_mask) == 0)
    80002e62:	000207b7          	lui	a5,0x20
    80002e66:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002e6a:	8ff9                	and	a5,a5,a4
    80002e6c:	ebc1                	bnez	a5,80002efc <sigaction+0xe6>
    return -1;
  acquire(&p->lock);
    80002e6e:	854a                	mv	a0,s2
    80002e70:	ffffe097          	auipc	ra,0xffffe
    80002e74:	d98080e7          	jalr	-616(ra) # 80000c08 <acquire>

  if(oldact!=0){
    80002e78:	020a0b63          	beqz	s4,80002eae <sigaction+0x98>
    copyout(p->pagetable, (uint64)&oldact->sa_handler, (char *)&p->signal_handlers[signum], sizeof(act->sa_handler));
    80002e7c:	01f48613          	addi	a2,s1,31
    80002e80:	060e                	slli	a2,a2,0x3
    80002e82:	46a1                	li	a3,8
    80002e84:	964a                	add	a2,a2,s2
    80002e86:	85d2                	mv	a1,s4
    80002e88:	04093503          	ld	a0,64(s2)
    80002e8c:	fffff097          	auipc	ra,0xfffff
    80002e90:	ada080e7          	jalr	-1318(ra) # 80001966 <copyout>
    copyout(p->pagetable, (uint64)&oldact->sigmask, (char *)&p->handlers_sigmasks[signum], sizeof(uint));
    80002e94:	07e48613          	addi	a2,s1,126
    80002e98:	060a                	slli	a2,a2,0x2
    80002e9a:	4691                	li	a3,4
    80002e9c:	964a                	add	a2,a2,s2
    80002e9e:	008a0593          	addi	a1,s4,8
    80002ea2:	04093503          	ld	a0,64(s2)
    80002ea6:	fffff097          	auipc	ra,0xfffff
    80002eaa:	ac0080e7          	jalr	-1344(ra) # 80001966 <copyout>
  }

  p->handlers_sigmasks[signum]=new_mask;
    80002eae:	07c48793          	addi	a5,s1,124
    80002eb2:	078a                	slli	a5,a5,0x2
    80002eb4:	97ca                	add	a5,a5,s2
    80002eb6:	fcc42703          	lw	a4,-52(s0)
    80002eba:	c798                	sw	a4,8(a5)
  copyin(p->pagetable, (char *)&p->signal_handlers[signum], (uint64)&act->sa_handler, sizeof(act->sa_handler));
    80002ebc:	04fd                	addi	s1,s1,31
    80002ebe:	048e                	slli	s1,s1,0x3
    80002ec0:	46a1                	li	a3,8
    80002ec2:	864e                	mv	a2,s3
    80002ec4:	009905b3          	add	a1,s2,s1
    80002ec8:	04093503          	ld	a0,64(s2)
    80002ecc:	fffff097          	auipc	ra,0xfffff
    80002ed0:	b26080e7          	jalr	-1242(ra) # 800019f2 <copyin>

  release(&p->lock);
    80002ed4:	854a                	mv	a0,s2
    80002ed6:	ffffe097          	auipc	ra,0xffffe
    80002eda:	e08080e7          	jalr	-504(ra) # 80000cde <release>



  return 0;
    80002ede:	4501                	li	a0,0
}
    80002ee0:	70e2                	ld	ra,56(sp)
    80002ee2:	7442                	ld	s0,48(sp)
    80002ee4:	74a2                	ld	s1,40(sp)
    80002ee6:	7902                	ld	s2,32(sp)
    80002ee8:	69e2                	ld	s3,24(sp)
    80002eea:	6a42                	ld	s4,16(sp)
    80002eec:	6121                	addi	sp,sp,64
    80002eee:	8082                	ret
    return -1;
    80002ef0:	557d                	li	a0,-1
}
    80002ef2:	8082                	ret
    return -1;
    80002ef4:	557d                	li	a0,-1
    80002ef6:	b7ed                	j	80002ee0 <sigaction+0xca>
    80002ef8:	557d                	li	a0,-1
    80002efa:	b7dd                	j	80002ee0 <sigaction+0xca>
    return -1;
    80002efc:	557d                	li	a0,-1
    80002efe:	b7cd                	j	80002ee0 <sigaction+0xca>

0000000080002f00 <sigret>:

void 
sigret(void){
    80002f00:	1101                	addi	sp,sp,-32
    80002f02:	ec06                	sd	ra,24(sp)
    80002f04:	e822                	sd	s0,16(sp)
    80002f06:	e426                	sd	s1,8(sp)
    80002f08:	e04a                	sd	s2,0(sp)
    80002f0a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002f0c:	fffff097          	auipc	ra,0xfffff
    80002f10:	e72080e7          	jalr	-398(ra) # 80001d7e <myproc>
    80002f14:	84aa                	mv	s1,a0
  struct kthread *t=mykthread();
    80002f16:	fffff097          	auipc	ra,0xfffff
    80002f1a:	ea8080e7          	jalr	-344(ra) # 80001dbe <mykthread>
    80002f1e:	892a                	mv	s2,a0

  copyin(p->pagetable, (char *)t->trapframe, (uint64)p->user_trapframe_backup, sizeof(struct trapframe));
    80002f20:	12000693          	li	a3,288
    80002f24:	2784b603          	ld	a2,632(s1)
    80002f28:	612c                	ld	a1,64(a0)
    80002f2a:	60a8                	ld	a0,64(s1)
    80002f2c:	fffff097          	auipc	ra,0xfffff
    80002f30:	ac6080e7          	jalr	-1338(ra) # 800019f2 <copyin>

  // restore user stack pointer
  acquire(&p->lock);
    80002f34:	8526                	mv	a0,s1
    80002f36:	ffffe097          	auipc	ra,0xffffe
    80002f3a:	cd2080e7          	jalr	-814(ra) # 80000c08 <acquire>
  // TODO maybe we will need to also lock the kthread lock
  t->trapframe->sp += sizeof(struct trapframe);
    80002f3e:	04093703          	ld	a4,64(s2)
    80002f42:	7b1c                	ld	a5,48(a4)
    80002f44:	12078793          	addi	a5,a5,288
    80002f48:	fb1c                	sd	a5,48(a4)

  p->signal_mask = p->signal_mask_backup;
    80002f4a:	0f04a783          	lw	a5,240(s1)
    80002f4e:	0ef4a623          	sw	a5,236(s1)
  
  // Allow user signal handler since we finished handling the current
  p->handling_user_sig_flag = 0;
    80002f52:	2804a023          	sw	zero,640(s1)
  // Allow other thread to react to signals
  p->handling_sig_flag = 0;
    80002f56:	2804a223          	sw	zero,644(s1)
  release(&p->lock);
    80002f5a:	8526                	mv	a0,s1
    80002f5c:	ffffe097          	auipc	ra,0xffffe
    80002f60:	d82080e7          	jalr	-638(ra) # 80000cde <release>
}
    80002f64:	60e2                	ld	ra,24(sp)
    80002f66:	6442                	ld	s0,16(sp)
    80002f68:	64a2                	ld	s1,8(sp)
    80002f6a:	6902                	ld	s2,0(sp)
    80002f6c:	6105                	addi	sp,sp,32
    80002f6e:	8082                	ret

0000000080002f70 <turn_on_bit>:

// we call turn on and turn off when holding p->lock
void
turn_on_bit(struct proc* p, int signum){
    80002f70:	1141                	addi	sp,sp,-16
    80002f72:	e422                	sd	s0,8(sp)
    80002f74:	0800                	addi	s0,sp,16
  if(!(p->pending_signals & (1 << signum)))
    80002f76:	0e852703          	lw	a4,232(a0)
    80002f7a:	4785                	li	a5,1
    80002f7c:	00b795bb          	sllw	a1,a5,a1
    80002f80:	00b777b3          	and	a5,a4,a1
    80002f84:	2781                	sext.w	a5,a5
    80002f86:	e781                	bnez	a5,80002f8e <turn_on_bit+0x1e>
    p->pending_signals ^= (1 << signum);  
    80002f88:	8db9                	xor	a1,a1,a4
    80002f8a:	0eb52423          	sw	a1,232(a0)
}
    80002f8e:	6422                	ld	s0,8(sp)
    80002f90:	0141                	addi	sp,sp,16
    80002f92:	8082                	ret

0000000080002f94 <kill>:
{
    80002f94:	7139                	addi	sp,sp,-64
    80002f96:	fc06                	sd	ra,56(sp)
    80002f98:	f822                	sd	s0,48(sp)
    80002f9a:	f426                	sd	s1,40(sp)
    80002f9c:	f04a                	sd	s2,32(sp)
    80002f9e:	ec4e                	sd	s3,24(sp)
    80002fa0:	e852                	sd	s4,16(sp)
    80002fa2:	e456                	sd	s5,8(sp)
    80002fa4:	0080                	addi	s0,sp,64
    80002fa6:	892a                	mv	s2,a0
    80002fa8:	8aae                	mv	s5,a1
  for(p = proc; p < &proc[NPROC]; p++){
    80002faa:	00011497          	auipc	s1,0x11
    80002fae:	b7e48493          	addi	s1,s1,-1154 # 80013b28 <proc>
    80002fb2:	6985                	lui	s3,0x1
    80002fb4:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002fb8:	00032a17          	auipc	s4,0x32
    80002fbc:	d70a0a13          	addi	s4,s4,-656 # 80034d28 <tickslock>
    acquire(&p->lock);
    80002fc0:	8526                	mv	a0,s1
    80002fc2:	ffffe097          	auipc	ra,0xffffe
    80002fc6:	c46080e7          	jalr	-954(ra) # 80000c08 <acquire>
    if(p->pid == pid){
    80002fca:	50dc                	lw	a5,36(s1)
    80002fcc:	01278c63          	beq	a5,s2,80002fe4 <kill+0x50>
    release(&p->lock);
    80002fd0:	8526                	mv	a0,s1
    80002fd2:	ffffe097          	auipc	ra,0xffffe
    80002fd6:	d0c080e7          	jalr	-756(ra) # 80000cde <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002fda:	94ce                	add	s1,s1,s3
    80002fdc:	ff4492e3          	bne	s1,s4,80002fc0 <kill+0x2c>
  return -1;
    80002fe0:	557d                	li	a0,-1
    80002fe2:	a051                	j	80003066 <kill+0xd2>
      if(p->state != RUNNABLE){
    80002fe4:	4c98                	lw	a4,24(s1)
    80002fe6:	4789                	li	a5,2
    80002fe8:	06f71963          	bne	a4,a5,8000305a <kill+0xc6>
      if(p->signal_handlers[signum] == (void*)SIG_IGN){
    80002fec:	01ea8793          	addi	a5,s5,30
    80002ff0:	078e                	slli	a5,a5,0x3
    80002ff2:	97a6                	add	a5,a5,s1
    80002ff4:	6798                	ld	a4,8(a5)
    80002ff6:	4785                	li	a5,1
    80002ff8:	08f70063          	beq	a4,a5,80003078 <kill+0xe4>
      turn_on_bit(p,signum);
    80002ffc:	85d6                	mv	a1,s5
    80002ffe:	8526                	mv	a0,s1
    80003000:	00000097          	auipc	ra,0x0
    80003004:	f70080e7          	jalr	-144(ra) # 80002f70 <turn_on_bit>
      release(&p->lock);
    80003008:	8526                	mv	a0,s1
    8000300a:	ffffe097          	auipc	ra,0xffffe
    8000300e:	cd4080e7          	jalr	-812(ra) # 80000cde <release>
      if(signum == SIGKILL){
    80003012:	47a5                	li	a5,9
      return 0;
    80003014:	4501                	li	a0,0
      if(signum == SIGKILL){
    80003016:	04fa9863          	bne	s5,a5,80003066 <kill+0xd2>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    8000301a:	28848913          	addi	s2,s1,648
    8000301e:	6785                	lui	a5,0x1
    80003020:	84878793          	addi	a5,a5,-1976 # 848 <_entry-0x7ffff7b8>
    80003024:	94be                	add	s1,s1,a5
          if(t->state == TRUNNABLE){
    80003026:	498d                	li	s3,3
            if(t->state == TSLEEPING){
    80003028:	4a09                	li	s4,2
          if(t->state == TRUNNABLE){
    8000302a:	01892783          	lw	a5,24(s2)
    8000302e:	07378663          	beq	a5,s3,8000309a <kill+0x106>
            acquire(&t->lock);
    80003032:	854a                	mv	a0,s2
    80003034:	ffffe097          	auipc	ra,0xffffe
    80003038:	bd4080e7          	jalr	-1068(ra) # 80000c08 <acquire>
            if(t->state == TSLEEPING){
    8000303c:	01892783          	lw	a5,24(s2)
    80003040:	05478363          	beq	a5,s4,80003086 <kill+0xf2>
            release(&t->lock);
    80003044:	854a                	mv	a0,s2
    80003046:	ffffe097          	auipc	ra,0xffffe
    8000304a:	c98080e7          	jalr	-872(ra) # 80000cde <release>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    8000304e:	0b890913          	addi	s2,s2,184
    80003052:	fc991ce3          	bne	s2,s1,8000302a <kill+0x96>
      return 0;
    80003056:	4501                	li	a0,0
    80003058:	a039                	j	80003066 <kill+0xd2>
        release(&p->lock);
    8000305a:	8526                	mv	a0,s1
    8000305c:	ffffe097          	auipc	ra,0xffffe
    80003060:	c82080e7          	jalr	-894(ra) # 80000cde <release>
        return -1;
    80003064:	557d                	li	a0,-1
}
    80003066:	70e2                	ld	ra,56(sp)
    80003068:	7442                	ld	s0,48(sp)
    8000306a:	74a2                	ld	s1,40(sp)
    8000306c:	7902                	ld	s2,32(sp)
    8000306e:	69e2                	ld	s3,24(sp)
    80003070:	6a42                	ld	s4,16(sp)
    80003072:	6aa2                	ld	s5,8(sp)
    80003074:	6121                	addi	sp,sp,64
    80003076:	8082                	ret
        release(&p->lock);
    80003078:	8526                	mv	a0,s1
    8000307a:	ffffe097          	auipc	ra,0xffffe
    8000307e:	c64080e7          	jalr	-924(ra) # 80000cde <release>
        return 1;
    80003082:	4505                	li	a0,1
    80003084:	b7cd                	j	80003066 <kill+0xd2>
              t->state = TRUNNABLE;
    80003086:	478d                	li	a5,3
    80003088:	00f92c23          	sw	a5,24(s2)
              release(&t->lock);
    8000308c:	854a                	mv	a0,s2
    8000308e:	ffffe097          	auipc	ra,0xffffe
    80003092:	c50080e7          	jalr	-944(ra) # 80000cde <release>
      return 0;
    80003096:	4501                	li	a0,0
              break;
    80003098:	b7f9                	j	80003066 <kill+0xd2>
      return 0;
    8000309a:	4501                	li	a0,0
    8000309c:	b7e9                	j	80003066 <kill+0xd2>

000000008000309e <turn_off_bit>:

void
turn_off_bit(struct proc* p, int signum){
    8000309e:	1141                	addi	sp,sp,-16
    800030a0:	e422                	sd	s0,8(sp)
    800030a2:	0800                	addi	s0,sp,16
  if(p->pending_signals & (1 << signum))
    800030a4:	0e852703          	lw	a4,232(a0)
    800030a8:	4785                	li	a5,1
    800030aa:	00b795bb          	sllw	a1,a5,a1
    800030ae:	00b777b3          	and	a5,a4,a1
    800030b2:	2781                	sext.w	a5,a5
    800030b4:	c781                	beqz	a5,800030bc <turn_off_bit+0x1e>
    p->pending_signals ^= (1 << signum);  
    800030b6:	8db9                	xor	a1,a1,a4
    800030b8:	0eb52423          	sw	a1,232(a0)
}
    800030bc:	6422                	ld	s0,8(sp)
    800030be:	0141                	addi	sp,sp,16
    800030c0:	8082                	ret

00000000800030c2 <kthread_create>:

int kthread_create(void (*start_func)(), void *stack){
    800030c2:	7139                	addi	sp,sp,-64
    800030c4:	fc06                	sd	ra,56(sp)
    800030c6:	f822                	sd	s0,48(sp)
    800030c8:	f426                	sd	s1,40(sp)
    800030ca:	f04a                	sd	s2,32(sp)
    800030cc:	ec4e                	sd	s3,24(sp)
    800030ce:	e852                	sd	s4,16(sp)
    800030d0:	e456                	sd	s5,8(sp)
    800030d2:	e05a                	sd	s6,0(sp)
    800030d4:	0080                	addi	s0,sp,64
    800030d6:	8b2a                	mv	s6,a0
    800030d8:	8aae                	mv	s5,a1
  struct proc *p = myproc();
    800030da:	fffff097          	auipc	ra,0xfffff
    800030de:	ca4080e7          	jalr	-860(ra) # 80001d7e <myproc>
    800030e2:	8a2a                	mv	s4,a0
  struct kthread *curr_t = mykthread();
    800030e4:	fffff097          	auipc	ra,0xfffff
    800030e8:	cda080e7          	jalr	-806(ra) # 80001dbe <mykthread>
    800030ec:	89aa                	mv	s3,a0
  struct kthread *other_t;

  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    800030ee:	288a0493          	addi	s1,s4,648
    800030f2:	6905                	lui	s2,0x1
    800030f4:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    800030f8:	9952                	add	s2,s2,s4
    800030fa:	a861                	j	80003192 <kthread_create+0xd0>
  t->tid = 0;
    800030fc:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80003100:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80003104:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80003108:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    8000310c:	0004ac23          	sw	zero,24(s1)

    if(curr_t != other_t){
      acquire(&other_t->lock);
      if(other_t->state == TUNUSED){
          freethread(other_t);  // free memory in case this thread entry was previously used
          init_thread(other_t);
    80003110:	8526                	mv	a0,s1
    80003112:	fffff097          	auipc	ra,0xfffff
    80003116:	dbe080e7          	jalr	-578(ra) # 80001ed0 <init_thread>
          
          
          *(other_t->trapframe) = *(curr_t->trapframe);
    8000311a:	0409b683          	ld	a3,64(s3)
    8000311e:	87b6                	mv	a5,a3
    80003120:	60b8                	ld	a4,64(s1)
    80003122:	12068693          	addi	a3,a3,288
    80003126:	0007b803          	ld	a6,0(a5)
    8000312a:	6788                	ld	a0,8(a5)
    8000312c:	6b8c                	ld	a1,16(a5)
    8000312e:	6f90                	ld	a2,24(a5)
    80003130:	01073023          	sd	a6,0(a4) # 20000 <_entry-0x7ffe0000>
    80003134:	e708                	sd	a0,8(a4)
    80003136:	eb0c                	sd	a1,16(a4)
    80003138:	ef10                	sd	a2,24(a4)
    8000313a:	02078793          	addi	a5,a5,32
    8000313e:	02070713          	addi	a4,a4,32
    80003142:	fed792e3          	bne	a5,a3,80003126 <kthread_create+0x64>
          other_t->trapframe->sp = (uint64)stack + MAX_STACK_SIZE-16;
    80003146:	60b8                	ld	a4,64(s1)
    80003148:	6785                	lui	a5,0x1
    8000314a:	f9078793          	addi	a5,a5,-112 # f90 <_entry-0x7ffff070>
    8000314e:	9abe                	add	s5,s5,a5
    80003150:	03573823          	sd	s5,48(a4)

          other_t->trapframe->epc = (uint64)start_func;
    80003154:	60bc                	ld	a5,64(s1)
    80003156:	0167bc23          	sd	s6,24(a5)
          release(&other_t->lock);
    8000315a:	8526                	mv	a0,s1
    8000315c:	ffffe097          	auipc	ra,0xffffe
    80003160:	b82080e7          	jalr	-1150(ra) # 80000cde <release>
          acquire(&p->lock);
    80003164:	8552                	mv	a0,s4
    80003166:	ffffe097          	auipc	ra,0xffffe
    8000316a:	aa2080e7          	jalr	-1374(ra) # 80000c08 <acquire>
          p->active_threads++;
    8000316e:	028a2783          	lw	a5,40(s4)
    80003172:	2785                	addiw	a5,a5,1
    80003174:	02fa2423          	sw	a5,40(s4)
          release(&p->lock);
    80003178:	8552                	mv	a0,s4
    8000317a:	ffffe097          	auipc	ra,0xffffe
    8000317e:	b64080e7          	jalr	-1180(ra) # 80000cde <release>
          other_t->state = TRUNNABLE;
    80003182:	478d                	li	a5,3
    80003184:	cc9c                	sw	a5,24(s1)
          return other_t->tid;
    80003186:	5888                	lw	a0,48(s1)
    80003188:	a02d                	j	800031b2 <kthread_create+0xf0>
  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    8000318a:	0b848493          	addi	s1,s1,184
    8000318e:	02990163          	beq	s2,s1,800031b0 <kthread_create+0xee>
    if(curr_t != other_t){
    80003192:	fe998ce3          	beq	s3,s1,8000318a <kthread_create+0xc8>
      acquire(&other_t->lock);
    80003196:	8526                	mv	a0,s1
    80003198:	ffffe097          	auipc	ra,0xffffe
    8000319c:	a70080e7          	jalr	-1424(ra) # 80000c08 <acquire>
      if(other_t->state == TUNUSED){
    800031a0:	4c9c                	lw	a5,24(s1)
    800031a2:	dfa9                	beqz	a5,800030fc <kthread_create+0x3a>
      }
      release(&other_t->lock);
    800031a4:	8526                	mv	a0,s1
    800031a6:	ffffe097          	auipc	ra,0xffffe
    800031aa:	b38080e7          	jalr	-1224(ra) # 80000cde <release>
    800031ae:	bff1                	j	8000318a <kthread_create+0xc8>
    }
  }
  return -1;
    800031b0:	557d                	li	a0,-1
}
    800031b2:	70e2                	ld	ra,56(sp)
    800031b4:	7442                	ld	s0,48(sp)
    800031b6:	74a2                	ld	s1,40(sp)
    800031b8:	7902                	ld	s2,32(sp)
    800031ba:	69e2                	ld	s3,24(sp)
    800031bc:	6a42                	ld	s4,16(sp)
    800031be:	6aa2                	ld	s5,8(sp)
    800031c0:	6b02                	ld	s6,0(sp)
    800031c2:	6121                	addi	sp,sp,64
    800031c4:	8082                	ret

00000000800031c6 <kthread_join>:



int
kthread_join(int thread_id, int* status){
    800031c6:	715d                	addi	sp,sp,-80
    800031c8:	e486                	sd	ra,72(sp)
    800031ca:	e0a2                	sd	s0,64(sp)
    800031cc:	fc26                	sd	s1,56(sp)
    800031ce:	f84a                	sd	s2,48(sp)
    800031d0:	f44e                	sd	s3,40(sp)
    800031d2:	f052                	sd	s4,32(sp)
    800031d4:	ec56                	sd	s5,24(sp)
    800031d6:	e85a                	sd	s6,16(sp)
    800031d8:	e45e                	sd	s7,8(sp)
    800031da:	0880                	addi	s0,sp,80
    800031dc:	8a2a                	mv	s4,a0
    800031de:	8b2e                	mv	s6,a1
  struct kthread *nt;
  struct proc *p = myproc();
    800031e0:	fffff097          	auipc	ra,0xfffff
    800031e4:	b9e080e7          	jalr	-1122(ra) # 80001d7e <myproc>
    800031e8:	8aaa                	mv	s5,a0
  struct kthread *t = mykthread();
    800031ea:	fffff097          	auipc	ra,0xfffff
    800031ee:	bd4080e7          	jalr	-1068(ra) # 80001dbe <mykthread>



  if(thread_id == t->tid)
    800031f2:	591c                	lw	a5,48(a0)
    800031f4:	17478a63          	beq	a5,s4,80003368 <kthread_join+0x1a2>
    800031f8:	89aa                	mv	s3,a0
    return -1;
  acquire(&wait_lock);
    800031fa:	00010517          	auipc	a0,0x10
    800031fe:	4d650513          	addi	a0,a0,1238 # 800136d0 <wait_lock>
    80003202:	ffffe097          	auipc	ra,0xffffe
    80003206:	a06080e7          	jalr	-1530(ra) # 80000c08 <acquire>
  // Search for thread in the procces threads array
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){
    8000320a:	288a8913          	addi	s2,s5,648
    8000320e:	6485                	lui	s1,0x1
    80003210:	84848493          	addi	s1,s1,-1976 # 848 <_entry-0x7ffff7b8>
    80003214:	94d6                	add	s1,s1,s5
    80003216:	a039                	j	80003224 <kthread_join+0x5e>
    80003218:	84ca                	mv	s1,s2
    8000321a:	a825                	j	80003252 <kthread_join+0x8c>
    8000321c:	0b890913          	addi	s2,s2,184
    80003220:	02990363          	beq	s2,s1,80003246 <kthread_join+0x80>
    if(nt != t){
    80003224:	ff298ce3          	beq	s3,s2,8000321c <kthread_join+0x56>
      acquire(&nt->lock);
    80003228:	854a                	mv	a0,s2
    8000322a:	ffffe097          	auipc	ra,0xffffe
    8000322e:	9de080e7          	jalr	-1570(ra) # 80000c08 <acquire>

      if(nt->tid == thread_id){
    80003232:	03092783          	lw	a5,48(s2)
    80003236:	ff4781e3          	beq	a5,s4,80003218 <kthread_join+0x52>
        //found target thread 
        goto found;
      }
      release(&nt->lock);
    8000323a:	854a                	mv	a0,s2
    8000323c:	ffffe097          	auipc	ra,0xffffe
    80003240:	aa2080e7          	jalr	-1374(ra) # 80000cde <release>
    80003244:	bfe1                	j	8000321c <kthread_join+0x56>
    }
  }

  if(nt->tid != thread_id){
    80003246:	6785                	lui	a5,0x1
    80003248:	97d6                	add	a5,a5,s5
    8000324a:	8787a783          	lw	a5,-1928(a5) # 878 <_entry-0x7ffff788>
    8000324e:	09479c63          	bne	a5,s4,800032e6 <kthread_join+0x120>
  found:
  // printf("%d:join to %d\n",p->pid,thread_id);  // TODO delete
  // Wait for thread to terminate
  // still holding nt lock
  for(;;){
      if(nt->state==TZOMBIE){
    80003252:	4c9c                	lw	a5,24(s1)
    80003254:	4715                	li	a4,5
    80003256:	04e78163          	beq	a5,a4,80003298 <kthread_join+0xd2>
      release(&nt->lock);
      release(&wait_lock);
      return -1;
    }
    release(&nt->lock);
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    8000325a:	00010b97          	auipc	s7,0x10
    8000325e:	476b8b93          	addi	s7,s7,1142 # 800136d0 <wait_lock>
      if(nt->state==TZOMBIE){
    80003262:	4915                	li	s2,5
      else if(nt->state==TUNUSED){ // in case someone already free that thread
    80003264:	cbd5                	beqz	a5,80003318 <kthread_join+0x152>
    if(t->killed || nt->tid!=thread_id){
    80003266:	0289a783          	lw	a5,40(s3)
    8000326a:	e3e5                	bnez	a5,8000334a <kthread_join+0x184>
    8000326c:	589c                	lw	a5,48(s1)
    8000326e:	0d479e63          	bne	a5,s4,8000334a <kthread_join+0x184>
    release(&nt->lock);
    80003272:	8526                	mv	a0,s1
    80003274:	ffffe097          	auipc	ra,0xffffe
    80003278:	a6a080e7          	jalr	-1430(ra) # 80000cde <release>
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    8000327c:	85de                	mv	a1,s7
    8000327e:	8526                	mv	a0,s1
    80003280:	fffff097          	auipc	ra,0xfffff
    80003284:	474080e7          	jalr	1140(ra) # 800026f4 <sleep>
    acquire(&nt->lock);
    80003288:	8526                	mv	a0,s1
    8000328a:	ffffe097          	auipc	ra,0xffffe
    8000328e:	97e080e7          	jalr	-1666(ra) # 80000c08 <acquire>
      if(nt->state==TZOMBIE){
    80003292:	4c9c                	lw	a5,24(s1)
    80003294:	fd2798e3          	bne	a5,s2,80003264 <kthread_join+0x9e>
        if(status != 0 && copyout(p->pagetable, (uint64)status, (char *)&nt->xstate,sizeof(nt->xstate)) < 0) {
    80003298:	000b0e63          	beqz	s6,800032b4 <kthread_join+0xee>
    8000329c:	4691                	li	a3,4
    8000329e:	02c48613          	addi	a2,s1,44
    800032a2:	85da                	mv	a1,s6
    800032a4:	040ab503          	ld	a0,64(s5)
    800032a8:	ffffe097          	auipc	ra,0xffffe
    800032ac:	6be080e7          	jalr	1726(ra) # 80001966 <copyout>
    800032b0:	04054563          	bltz	a0,800032fa <kthread_join+0x134>
  t->tid = 0;
    800032b4:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    800032b8:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    800032bc:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    800032c0:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    800032c4:	0004ac23          	sw	zero,24(s1)
        release(&nt->lock);
    800032c8:	8526                	mv	a0,s1
    800032ca:	ffffe097          	auipc	ra,0xffffe
    800032ce:	a14080e7          	jalr	-1516(ra) # 80000cde <release>
        release(&wait_lock);  //  successfull join     
    800032d2:	00010517          	auipc	a0,0x10
    800032d6:	3fe50513          	addi	a0,a0,1022 # 800136d0 <wait_lock>
    800032da:	ffffe097          	auipc	ra,0xffffe
    800032de:	a04080e7          	jalr	-1532(ra) # 80000cde <release>
        return 0;
    800032e2:	4501                	li	a0,0
    800032e4:	a059                	j	8000336a <kthread_join+0x1a4>
    release(&wait_lock);
    800032e6:	00010517          	auipc	a0,0x10
    800032ea:	3ea50513          	addi	a0,a0,1002 # 800136d0 <wait_lock>
    800032ee:	ffffe097          	auipc	ra,0xffffe
    800032f2:	9f0080e7          	jalr	-1552(ra) # 80000cde <release>
    return -1;
    800032f6:	557d                	li	a0,-1
    800032f8:	a88d                	j	8000336a <kthread_join+0x1a4>
           release(&nt->lock);
    800032fa:	8526                	mv	a0,s1
    800032fc:	ffffe097          	auipc	ra,0xffffe
    80003300:	9e2080e7          	jalr	-1566(ra) # 80000cde <release>
           release(&wait_lock);
    80003304:	00010517          	auipc	a0,0x10
    80003308:	3cc50513          	addi	a0,a0,972 # 800136d0 <wait_lock>
    8000330c:	ffffe097          	auipc	ra,0xffffe
    80003310:	9d2080e7          	jalr	-1582(ra) # 80000cde <release>
           return -1;                   
    80003314:	557d                	li	a0,-1
    80003316:	a891                	j	8000336a <kthread_join+0x1a4>
  t->tid = 0;
    80003318:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    8000331c:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80003320:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80003324:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80003328:	0004ac23          	sw	zero,24(s1)
        release(&nt->lock);
    8000332c:	8526                	mv	a0,s1
    8000332e:	ffffe097          	auipc	ra,0xffffe
    80003332:	9b0080e7          	jalr	-1616(ra) # 80000cde <release>
        release(&wait_lock);  //  successfull join
    80003336:	00010517          	auipc	a0,0x10
    8000333a:	39a50513          	addi	a0,a0,922 # 800136d0 <wait_lock>
    8000333e:	ffffe097          	auipc	ra,0xffffe
    80003342:	9a0080e7          	jalr	-1632(ra) # 80000cde <release>
        return 1; //thread already exited
    80003346:	4505                	li	a0,1
    80003348:	a00d                	j	8000336a <kthread_join+0x1a4>
      release(&nt->lock);
    8000334a:	8526                	mv	a0,s1
    8000334c:	ffffe097          	auipc	ra,0xffffe
    80003350:	992080e7          	jalr	-1646(ra) # 80000cde <release>
      release(&wait_lock);
    80003354:	00010517          	auipc	a0,0x10
    80003358:	37c50513          	addi	a0,a0,892 # 800136d0 <wait_lock>
    8000335c:	ffffe097          	auipc	ra,0xffffe
    80003360:	982080e7          	jalr	-1662(ra) # 80000cde <release>
      return -1;
    80003364:	557d                	li	a0,-1
    80003366:	a011                	j	8000336a <kthread_join+0x1a4>
    return -1;
    80003368:	557d                	li	a0,-1
  }
}
    8000336a:	60a6                	ld	ra,72(sp)
    8000336c:	6406                	ld	s0,64(sp)
    8000336e:	74e2                	ld	s1,56(sp)
    80003370:	7942                	ld	s2,48(sp)
    80003372:	79a2                	ld	s3,40(sp)
    80003374:	7a02                	ld	s4,32(sp)
    80003376:	6ae2                	ld	s5,24(sp)
    80003378:	6b42                	ld	s6,16(sp)
    8000337a:	6ba2                	ld	s7,8(sp)
    8000337c:	6161                	addi	sp,sp,80
    8000337e:	8082                	ret

0000000080003380 <kthread_join_all>:

int
kthread_join_all(){
    80003380:	7179                	addi	sp,sp,-48
    80003382:	f406                	sd	ra,40(sp)
    80003384:	f022                	sd	s0,32(sp)
    80003386:	ec26                	sd	s1,24(sp)
    80003388:	e84a                	sd	s2,16(sp)
    8000338a:	e44e                	sd	s3,8(sp)
    8000338c:	e052                	sd	s4,0(sp)
    8000338e:	1800                	addi	s0,sp,48
  struct proc *p=myproc();
    80003390:	fffff097          	auipc	ra,0xfffff
    80003394:	9ee080e7          	jalr	-1554(ra) # 80001d7e <myproc>
    80003398:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    8000339a:	fffff097          	auipc	ra,0xfffff
    8000339e:	a24080e7          	jalr	-1500(ra) # 80001dbe <mykthread>
    800033a2:	8a2a                	mv	s4,a0
  struct kthread *nt;
  int res = 1;
  for(nt = p->kthreads; nt < &p->kthreads[NTHREAD]; nt++){
    800033a4:	28898493          	addi	s1,s3,648
    800033a8:	6505                	lui	a0,0x1
    800033aa:	84850513          	addi	a0,a0,-1976 # 848 <_entry-0x7ffff7b8>
    800033ae:	99aa                	add	s3,s3,a0
  int res = 1;
    800033b0:	4905                	li	s2,1
    800033b2:	a029                	j	800033bc <kthread_join_all+0x3c>
  for(nt = p->kthreads; nt < &p->kthreads[NTHREAD]; nt++){
    800033b4:	0b848493          	addi	s1,s1,184
    800033b8:	00998e63          	beq	s3,s1,800033d4 <kthread_join_all+0x54>
    if(nt != t){
    800033bc:	fe9a0ce3          	beq	s4,s1,800033b4 <kthread_join_all+0x34>
      res &= kthread_join(nt->tid,0);
    800033c0:	4581                	li	a1,0
    800033c2:	5888                	lw	a0,48(s1)
    800033c4:	00000097          	auipc	ra,0x0
    800033c8:	e02080e7          	jalr	-510(ra) # 800031c6 <kthread_join>
    800033cc:	01257933          	and	s2,a0,s2
    800033d0:	2901                	sext.w	s2,s2
    800033d2:	b7cd                	j	800033b4 <kthread_join_all+0x34>
    }
  }

  return res;
}
    800033d4:	854a                	mv	a0,s2
    800033d6:	70a2                	ld	ra,40(sp)
    800033d8:	7402                	ld	s0,32(sp)
    800033da:	64e2                	ld	s1,24(sp)
    800033dc:	6942                	ld	s2,16(sp)
    800033de:	69a2                	ld	s3,8(sp)
    800033e0:	6a02                	ld	s4,0(sp)
    800033e2:	6145                	addi	sp,sp,48
    800033e4:	8082                	ret

00000000800033e6 <printTF>:


void 
printTF(struct kthread *t){//function for debuging, TODO delete
    800033e6:	7175                	addi	sp,sp,-144
    800033e8:	e506                	sd	ra,136(sp)
    800033ea:	e122                	sd	s0,128(sp)
    800033ec:	fca6                	sd	s1,120(sp)
    800033ee:	0900                	addi	s0,sp,144
    800033f0:	84aa                	mv	s1,a0
  printf("**************tid=%d*****************\n",t->tid);
    800033f2:	590c                	lw	a1,48(a0)
    800033f4:	00006517          	auipc	a0,0x6
    800033f8:	fc450513          	addi	a0,a0,-60 # 800093b8 <digits+0x368>
    800033fc:	ffffd097          	auipc	ra,0xffffd
    80003400:	17c080e7          	jalr	380(ra) # 80000578 <printf>
  // printf("t->tf->epc = %p\n",t->trapframe->epc);
  // printf("t->tf->ra = %p\n",t->trapframe->ra);
  // printf("t->tf->kernel_sp = %p\n",t->trapframe->kernel_sp);
  printf("t->kstack = %p\n",t->kstack);
    80003404:	7c8c                	ld	a1,56(s1)
    80003406:	00006517          	auipc	a0,0x6
    8000340a:	fda50513          	addi	a0,a0,-38 # 800093e0 <digits+0x390>
    8000340e:	ffffd097          	auipc	ra,0xffffd
    80003412:	16a080e7          	jalr	362(ra) # 80000578 <printf>
  printf("t->context = %p\n",t->context);
    80003416:	04848793          	addi	a5,s1,72
    8000341a:	f7040713          	addi	a4,s0,-144
    8000341e:	0a848693          	addi	a3,s1,168
    80003422:	0007b803          	ld	a6,0(a5)
    80003426:	6788                	ld	a0,8(a5)
    80003428:	6b8c                	ld	a1,16(a5)
    8000342a:	6f90                	ld	a2,24(a5)
    8000342c:	01073023          	sd	a6,0(a4)
    80003430:	e708                	sd	a0,8(a4)
    80003432:	eb0c                	sd	a1,16(a4)
    80003434:	ef10                	sd	a2,24(a4)
    80003436:	02078793          	addi	a5,a5,32
    8000343a:	02070713          	addi	a4,a4,32
    8000343e:	fed792e3          	bne	a5,a3,80003422 <printTF+0x3c>
    80003442:	6394                	ld	a3,0(a5)
    80003444:	679c                	ld	a5,8(a5)
    80003446:	e314                	sd	a3,0(a4)
    80003448:	e71c                	sd	a5,8(a4)
    8000344a:	f7040593          	addi	a1,s0,-144
    8000344e:	00006517          	auipc	a0,0x6
    80003452:	fa250513          	addi	a0,a0,-94 # 800093f0 <digits+0x3a0>
    80003456:	ffffd097          	auipc	ra,0xffffd
    8000345a:	122080e7          	jalr	290(ra) # 80000578 <printf>
  printf("t->tf->sp = %p\n",t->trapframe->sp);
    8000345e:	60bc                	ld	a5,64(s1)
    80003460:	7b8c                	ld	a1,48(a5)
    80003462:	00006517          	auipc	a0,0x6
    80003466:	fa650513          	addi	a0,a0,-90 # 80009408 <digits+0x3b8>
    8000346a:	ffffd097          	auipc	ra,0xffffd
    8000346e:	10e080e7          	jalr	270(ra) # 80000578 <printf>
  printf("t->state = %d\n",t->state);
    80003472:	4c8c                	lw	a1,24(s1)
    80003474:	00006517          	auipc	a0,0x6
    80003478:	fa450513          	addi	a0,a0,-92 # 80009418 <digits+0x3c8>
    8000347c:	ffffd097          	auipc	ra,0xffffd
    80003480:	0fc080e7          	jalr	252(ra) # 80000578 <printf>
  printf("**************************************\n",t->tid);
    80003484:	588c                	lw	a1,48(s1)
    80003486:	00006517          	auipc	a0,0x6
    8000348a:	fa250513          	addi	a0,a0,-94 # 80009428 <digits+0x3d8>
    8000348e:	ffffd097          	auipc	ra,0xffffd
    80003492:	0ea080e7          	jalr	234(ra) # 80000578 <printf>

    80003496:	60aa                	ld	ra,136(sp)
    80003498:	640a                	ld	s0,128(sp)
    8000349a:	74e6                	ld	s1,120(sp)
    8000349c:	6149                	addi	sp,sp,144
    8000349e:	8082                	ret

00000000800034a0 <swtch>:
    800034a0:	00153023          	sd	ra,0(a0)
    800034a4:	00253423          	sd	sp,8(a0)
    800034a8:	e900                	sd	s0,16(a0)
    800034aa:	ed04                	sd	s1,24(a0)
    800034ac:	03253023          	sd	s2,32(a0)
    800034b0:	03353423          	sd	s3,40(a0)
    800034b4:	03453823          	sd	s4,48(a0)
    800034b8:	03553c23          	sd	s5,56(a0)
    800034bc:	05653023          	sd	s6,64(a0)
    800034c0:	05753423          	sd	s7,72(a0)
    800034c4:	05853823          	sd	s8,80(a0)
    800034c8:	05953c23          	sd	s9,88(a0)
    800034cc:	07a53023          	sd	s10,96(a0)
    800034d0:	07b53423          	sd	s11,104(a0)
    800034d4:	0005b083          	ld	ra,0(a1)
    800034d8:	0085b103          	ld	sp,8(a1)
    800034dc:	6980                	ld	s0,16(a1)
    800034de:	6d84                	ld	s1,24(a1)
    800034e0:	0205b903          	ld	s2,32(a1)
    800034e4:	0285b983          	ld	s3,40(a1)
    800034e8:	0305ba03          	ld	s4,48(a1)
    800034ec:	0385ba83          	ld	s5,56(a1)
    800034f0:	0405bb03          	ld	s6,64(a1)
    800034f4:	0485bb83          	ld	s7,72(a1)
    800034f8:	0505bc03          	ld	s8,80(a1)
    800034fc:	0585bc83          	ld	s9,88(a1)
    80003500:	0605bd03          	ld	s10,96(a1)
    80003504:	0685bd83          	ld	s11,104(a1)
    80003508:	8082                	ret

000000008000350a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000350a:	1141                	addi	sp,sp,-16
    8000350c:	e406                	sd	ra,8(sp)
    8000350e:	e022                	sd	s0,0(sp)
    80003510:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80003512:	00006597          	auipc	a1,0x6
    80003516:	f7658593          	addi	a1,a1,-138 # 80009488 <states.0+0x20>
    8000351a:	00032517          	auipc	a0,0x32
    8000351e:	80e50513          	addi	a0,a0,-2034 # 80034d28 <tickslock>
    80003522:	ffffd097          	auipc	ra,0xffffd
    80003526:	614080e7          	jalr	1556(ra) # 80000b36 <initlock>
}
    8000352a:	60a2                	ld	ra,8(sp)
    8000352c:	6402                	ld	s0,0(sp)
    8000352e:	0141                	addi	sp,sp,16
    80003530:	8082                	ret

0000000080003532 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80003532:	1141                	addi	sp,sp,-16
    80003534:	e422                	sd	s0,8(sp)
    80003536:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003538:	00004797          	auipc	a5,0x4
    8000353c:	b6878793          	addi	a5,a5,-1176 # 800070a0 <kernelvec>
    80003540:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80003544:	6422                	ld	s0,8(sp)
    80003546:	0141                	addi	sp,sp,16
    80003548:	8082                	ret

000000008000354a <check_should_cont>:
}

int 
check_should_cont(struct proc *p){
  for(int i=0;i<32;i++){
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && (((uint64)p->signal_handlers[i] == SIGCONT) || 
    8000354a:	0e852303          	lw	t1,232(a0)
    8000354e:	0f850813          	addi	a6,a0,248
    80003552:	4685                	li	a3,1
    80003554:	4701                	li	a4,0
    80003556:	4885                	li	a7,1
  for(int i=0;i<32;i++){
    80003558:	4e7d                	li	t3,31
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && (((uint64)p->signal_handlers[i] == SIGCONT) || 
    8000355a:	4ecd                	li	t4,19
    8000355c:	a801                	j	8000356c <check_should_cont+0x22>
  for(int i=0;i<32;i++){
    8000355e:	0006879b          	sext.w	a5,a3
    80003562:	04fe4663          	blt	t3,a5,800035ae <check_should_cont+0x64>
    80003566:	2705                	addiw	a4,a4,1
    80003568:	2685                	addiw	a3,a3,1
    8000356a:	0821                	addi	a6,a6,8
    8000356c:	0007059b          	sext.w	a1,a4
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && (((uint64)p->signal_handlers[i] == SIGCONT) || 
    80003570:	00e8963b          	sllw	a2,a7,a4
    80003574:	00c377b3          	and	a5,t1,a2
    80003578:	2781                	sext.w	a5,a5
    8000357a:	d3f5                	beqz	a5,8000355e <check_should_cont+0x14>
    8000357c:	0ec52783          	lw	a5,236(a0)
    80003580:	8ff1                	and	a5,a5,a2
    80003582:	2781                	sext.w	a5,a5
    80003584:	ffe9                	bnez	a5,8000355e <check_should_cont+0x14>
    80003586:	00083783          	ld	a5,0(a6)
    8000358a:	01d78563          	beq	a5,t4,80003594 <check_should_cont+0x4a>
    8000358e:	fdd598e3          	bne	a1,t4,8000355e <check_should_cont+0x14>
          (i == SIGCONT && p->signal_handlers[i] == SIG_DFL))){
    80003592:	fbf1                	bnez	a5,80003566 <check_should_cont+0x1c>
check_should_cont(struct proc *p){
    80003594:	1141                	addi	sp,sp,-16
    80003596:	e406                	sd	ra,8(sp)
    80003598:	e022                	sd	s0,0(sp)
    8000359a:	0800                	addi	s0,sp,16
        turn_off_bit(p, i);
    8000359c:	00000097          	auipc	ra,0x0
    800035a0:	b02080e7          	jalr	-1278(ra) # 8000309e <turn_off_bit>
        return 1;
    800035a4:	4505                	li	a0,1
      }
  }
  return 0;
}
    800035a6:	60a2                	ld	ra,8(sp)
    800035a8:	6402                	ld	s0,0(sp)
    800035aa:	0141                	addi	sp,sp,16
    800035ac:	8082                	ret
  return 0;
    800035ae:	4501                	li	a0,0
}
    800035b0:	8082                	ret

00000000800035b2 <handle_stop>:



void
handle_stop(struct proc* p){
    800035b2:	7139                	addi	sp,sp,-64
    800035b4:	fc06                	sd	ra,56(sp)
    800035b6:	f822                	sd	s0,48(sp)
    800035b8:	f426                	sd	s1,40(sp)
    800035ba:	f04a                	sd	s2,32(sp)
    800035bc:	ec4e                	sd	s3,24(sp)
    800035be:	e852                	sd	s4,16(sp)
    800035c0:	e456                	sd	s5,8(sp)
    800035c2:	e05a                	sd	s6,0(sp)
    800035c4:	0080                	addi	s0,sp,64
    800035c6:	89aa                	mv	s3,a0

  struct kthread *t;
  struct kthread *curr_t = mykthread();
    800035c8:	ffffe097          	auipc	ra,0xffffe
    800035cc:	7f6080e7          	jalr	2038(ra) # 80001dbe <mykthread>
    800035d0:	8aaa                	mv	s5,a0


  // Make all other threads belong to the same procces freeze 
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800035d2:	28898493          	addi	s1,s3,648
    800035d6:	6a05                	lui	s4,0x1
    800035d8:	848a0a13          	addi	s4,s4,-1976 # 848 <_entry-0x7ffff7b8>
    800035dc:	9a4e                	add	s4,s4,s3
    800035de:	8926                	mv	s2,s1
    if(t!=curr_t){
      acquire(&t->lock);
      t->frozen=1;
    800035e0:	4b05                	li	s6,1
    800035e2:	a029                	j	800035ec <handle_stop+0x3a>
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800035e4:	0b890913          	addi	s2,s2,184
    800035e8:	03490163          	beq	s2,s4,8000360a <handle_stop+0x58>
    if(t!=curr_t){
    800035ec:	ff2a8ce3          	beq	s5,s2,800035e4 <handle_stop+0x32>
      acquire(&t->lock);
    800035f0:	854a                	mv	a0,s2
    800035f2:	ffffd097          	auipc	ra,0xffffd
    800035f6:	616080e7          	jalr	1558(ra) # 80000c08 <acquire>
      t->frozen=1;
    800035fa:	03692a23          	sw	s6,52(s2)
      release(&t->lock);
    800035fe:	854a                	mv	a0,s2
    80003600:	ffffd097          	auipc	ra,0xffffd
    80003604:	6de080e7          	jalr	1758(ra) # 80000cde <release>
    80003608:	bff1                	j	800035e4 <handle_stop+0x32>
    }
  }
  int should_cont = check_should_cont(p);
    8000360a:	854e                	mv	a0,s3
    8000360c:	00000097          	auipc	ra,0x0
    80003610:	f3e080e7          	jalr	-194(ra) # 8000354a <check_should_cont>
  
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    80003614:	0e89a783          	lw	a5,232(s3)
    80003618:	2007f793          	andi	a5,a5,512
    8000361c:	e795                	bnez	a5,80003648 <handle_stop+0x96>
    8000361e:	e50d                	bnez	a0,80003648 <handle_stop+0x96>
    
    yield();
    80003620:	fffff097          	auipc	ra,0xfffff
    80003624:	098080e7          	jalr	152(ra) # 800026b8 <yield>
    should_cont = check_should_cont(p);  
    80003628:	854e                	mv	a0,s3
    8000362a:	00000097          	auipc	ra,0x0
    8000362e:	f20080e7          	jalr	-224(ra) # 8000354a <check_should_cont>
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    80003632:	0e89a783          	lw	a5,232(s3)
    80003636:	2007f793          	andi	a5,a5,512
    8000363a:	e799                	bnez	a5,80003648 <handle_stop+0x96>
    8000363c:	d175                	beqz	a0,80003620 <handle_stop+0x6e>
    8000363e:	a029                	j	80003648 <handle_stop+0x96>
    
  }

  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    80003640:	0b848493          	addi	s1,s1,184
    80003644:	03448163          	beq	s1,s4,80003666 <handle_stop+0xb4>
    if(t!=curr_t){
    80003648:	fe9a8ce3          	beq	s5,s1,80003640 <handle_stop+0x8e>
      acquire(&t->lock);
    8000364c:	8526                	mv	a0,s1
    8000364e:	ffffd097          	auipc	ra,0xffffd
    80003652:	5ba080e7          	jalr	1466(ra) # 80000c08 <acquire>
      t->frozen=0;
    80003656:	0204aa23          	sw	zero,52(s1)
      release(&t->lock);
    8000365a:	8526                	mv	a0,s1
    8000365c:	ffffd097          	auipc	ra,0xffffd
    80003660:	682080e7          	jalr	1666(ra) # 80000cde <release>
    80003664:	bff1                	j	80003640 <handle_stop+0x8e>
    }
  }
  if(p->pending_signals&1<<SIGKILL)
    80003666:	0e89a783          	lw	a5,232(s3)
    8000366a:	2007f793          	andi	a5,a5,512
    8000366e:	c781                	beqz	a5,80003676 <handle_stop+0xc4>
    p->killed=1;
    80003670:	4785                	li	a5,1
    80003672:	00f9ae23          	sw	a5,28(s3)
}
    80003676:	70e2                	ld	ra,56(sp)
    80003678:	7442                	ld	s0,48(sp)
    8000367a:	74a2                	ld	s1,40(sp)
    8000367c:	7902                	ld	s2,32(sp)
    8000367e:	69e2                	ld	s3,24(sp)
    80003680:	6a42                	ld	s4,16(sp)
    80003682:	6aa2                	ld	s5,8(sp)
    80003684:	6b02                	ld	s6,0(sp)
    80003686:	6121                	addi	sp,sp,64
    80003688:	8082                	ret

000000008000368a <check_pending_signals>:

void 
check_pending_signals(struct proc* p){
    8000368a:	711d                	addi	sp,sp,-96
    8000368c:	ec86                	sd	ra,88(sp)
    8000368e:	e8a2                	sd	s0,80(sp)
    80003690:	e4a6                	sd	s1,72(sp)
    80003692:	e0ca                	sd	s2,64(sp)
    80003694:	fc4e                	sd	s3,56(sp)
    80003696:	f852                	sd	s4,48(sp)
    80003698:	f456                	sd	s5,40(sp)
    8000369a:	f05a                	sd	s6,32(sp)
    8000369c:	ec5e                	sd	s7,24(sp)
    8000369e:	e862                	sd	s8,16(sp)
    800036a0:	e466                	sd	s9,8(sp)
    800036a2:	e06a                	sd	s10,0(sp)
    800036a4:	1080                	addi	s0,sp,96
    800036a6:	89aa                	mv	s3,a0
  // if(p->pid==4){
    
  //   if(p->pending_signals & (1<<SIGSTOP))
  //     printf("recieved stop sig\n");
  // }
  struct kthread *t= mykthread();
    800036a8:	ffffe097          	auipc	ra,0xffffe
    800036ac:	716080e7          	jalr	1814(ra) # 80001dbe <mykthread>
    800036b0:	8caa                	mv	s9,a0
  for(int sig_num=0;sig_num<32;sig_num++){
    800036b2:	0f898913          	addi	s2,s3,248
    800036b6:	4481                	li	s1,0
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    800036b8:	4a05                	li	s4,1
            p->killed = 1;
            release(&p->lock);
        }
      }

      else if(act.sa_handler==(void*)SIGKILL){
    800036ba:	4c25                	li	s8,9
        p->killed=1;
      }else if(act.sa_handler==(void*)SIGSTOP){
    800036bc:	4b45                	li	s6,17
        handle_stop(p);
      }      
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    800036be:	4b85                	li	s7,1
        switch (sig_num)
    800036c0:	4d4d                	li	s10,19
  for(int sig_num=0;sig_num<32;sig_num++){
    800036c2:	02000a93          	li	s5,32
    800036c6:	a0a1                	j	8000370e <check_pending_signals+0x84>
        switch (sig_num)
    800036c8:	03648163          	beq	s1,s6,800036ea <check_pending_signals+0x60>
    800036cc:	03a48763          	beq	s1,s10,800036fa <check_pending_signals+0x70>
            acquire(&p->lock);
    800036d0:	854e                	mv	a0,s3
    800036d2:	ffffd097          	auipc	ra,0xffffd
    800036d6:	536080e7          	jalr	1334(ra) # 80000c08 <acquire>
            p->killed = 1;
    800036da:	0179ae23          	sw	s7,28(s3)
            release(&p->lock);
    800036de:	854e                	mv	a0,s3
    800036e0:	ffffd097          	auipc	ra,0xffffd
    800036e4:	5fe080e7          	jalr	1534(ra) # 80000cde <release>
    800036e8:	a809                	j	800036fa <check_pending_signals+0x70>
            handle_stop(p);
    800036ea:	854e                	mv	a0,s3
    800036ec:	00000097          	auipc	ra,0x0
    800036f0:	ec6080e7          	jalr	-314(ra) # 800035b2 <handle_stop>
            break;
    800036f4:	a019                	j	800036fa <check_pending_signals+0x70>
        p->killed=1;
    800036f6:	0179ae23          	sw	s7,28(s3)
        turn_off_bit(p, sig_num);

        return;
      }

      turn_off_bit(p, sig_num);            
    800036fa:	85a6                	mv	a1,s1
    800036fc:	854e                	mv	a0,s3
    800036fe:	00000097          	auipc	ra,0x0
    80003702:	9a0080e7          	jalr	-1632(ra) # 8000309e <turn_off_bit>
  for(int sig_num=0;sig_num<32;sig_num++){
    80003706:	2485                	addiw	s1,s1,1
    80003708:	0921                	addi	s2,s2,8
    8000370a:	0d548963          	beq	s1,s5,800037dc <check_pending_signals+0x152>
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    8000370e:	009a173b          	sllw	a4,s4,s1
    80003712:	0e89a783          	lw	a5,232(s3)
    80003716:	8ff9                	and	a5,a5,a4
    80003718:	2781                	sext.w	a5,a5
    8000371a:	d7f5                	beqz	a5,80003706 <check_pending_signals+0x7c>
    8000371c:	0ec9a783          	lw	a5,236(s3)
    80003720:	8f7d                	and	a4,a4,a5
    80003722:	2701                	sext.w	a4,a4
    80003724:	f36d                	bnez	a4,80003706 <check_pending_signals+0x7c>
      act.sa_handler = p->signal_handlers[sig_num];
    80003726:	00093703          	ld	a4,0(s2)
      if(act.sa_handler == (void*)SIG_DFL){
    8000372a:	df59                	beqz	a4,800036c8 <check_pending_signals+0x3e>
      else if(act.sa_handler==(void*)SIGKILL){
    8000372c:	fd8705e3          	beq	a4,s8,800036f6 <check_pending_signals+0x6c>
      }else if(act.sa_handler==(void*)SIGSTOP){
    80003730:	0d670463          	beq	a4,s6,800037f8 <check_pending_signals+0x16e>
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    80003734:	fd7703e3          	beq	a4,s7,800036fa <check_pending_signals+0x70>
    80003738:	2809a703          	lw	a4,640(s3)
    8000373c:	ff5d                	bnez	a4,800036fa <check_pending_signals+0x70>
      act.sigmask = p->handlers_sigmasks[sig_num];
    8000373e:	07c48713          	addi	a4,s1,124
    80003742:	070a                	slli	a4,a4,0x2
    80003744:	974e                	add	a4,a4,s3
    80003746:	4718                	lw	a4,8(a4)
        p->handling_user_sig_flag = 1;
    80003748:	4685                	li	a3,1
    8000374a:	28d9a023          	sw	a3,640(s3)
        p->signal_mask_backup = p->signal_mask;
    8000374e:	0ef9a823          	sw	a5,240(s3)
        p->signal_mask= p->handlers_sigmasks[sig_num];
    80003752:	0ee9a623          	sw	a4,236(s3)
        t->trapframe->sp -= sizeof(struct trapframe);
    80003756:	040cb703          	ld	a4,64(s9)
    8000375a:	7b1c                	ld	a5,48(a4)
    8000375c:	ee078793          	addi	a5,a5,-288
    80003760:	fb1c                	sd	a5,48(a4)
        p->user_trapframe_backup = (struct trapframe* )(t->trapframe->sp);
    80003762:	040cb783          	ld	a5,64(s9)
    80003766:	7b8c                	ld	a1,48(a5)
    80003768:	26b9bc23          	sd	a1,632(s3)
        copyout(p->pagetable, (uint64)p->user_trapframe_backup, (char *)t->trapframe, sizeof(struct trapframe));
    8000376c:	12000693          	li	a3,288
    80003770:	040cb603          	ld	a2,64(s9)
    80003774:	0409b503          	ld	a0,64(s3)
    80003778:	ffffe097          	auipc	ra,0xffffe
    8000377c:	1ee080e7          	jalr	494(ra) # 80001966 <copyout>
        uint64 size = (uint64)&end_sigret - (uint64)&call_sigret;
    80003780:	00004697          	auipc	a3,0x4
    80003784:	fb068693          	addi	a3,a3,-80 # 80007730 <end_sigret>
    80003788:	00004617          	auipc	a2,0x4
    8000378c:	fa060613          	addi	a2,a2,-96 # 80007728 <call_sigret>
        t->trapframe->sp -= size;
    80003790:	040cb703          	ld	a4,64(s9)
    80003794:	40d605b3          	sub	a1,a2,a3
    80003798:	7b1c                	ld	a5,48(a4)
    8000379a:	97ae                	add	a5,a5,a1
    8000379c:	fb1c                	sd	a5,48(a4)
        copyout(p->pagetable, (uint64)t->trapframe->sp, (char *)&call_sigret, size);
    8000379e:	040cb783          	ld	a5,64(s9)
    800037a2:	8e91                	sub	a3,a3,a2
    800037a4:	7b8c                	ld	a1,48(a5)
    800037a6:	0409b503          	ld	a0,64(s3)
    800037aa:	ffffe097          	auipc	ra,0xffffe
    800037ae:	1bc080e7          	jalr	444(ra) # 80001966 <copyout>
        t->trapframe->a0 = sig_num;
    800037b2:	040cb783          	ld	a5,64(s9)
    800037b6:	fba4                	sd	s1,112(a5)
        t->trapframe->ra = t->trapframe->sp;
    800037b8:	040cb783          	ld	a5,64(s9)
    800037bc:	7b98                	ld	a4,48(a5)
    800037be:	f798                	sd	a4,40(a5)
        t->trapframe->epc = (uint64)p->signal_handlers[sig_num];
    800037c0:	040cb703          	ld	a4,64(s9)
    800037c4:	01e48793          	addi	a5,s1,30
    800037c8:	078e                	slli	a5,a5,0x3
    800037ca:	97ce                	add	a5,a5,s3
    800037cc:	679c                	ld	a5,8(a5)
    800037ce:	ef1c                	sd	a5,24(a4)
        turn_off_bit(p, sig_num);
    800037d0:	85a6                	mv	a1,s1
    800037d2:	854e                	mv	a0,s3
    800037d4:	00000097          	auipc	ra,0x0
    800037d8:	8ca080e7          	jalr	-1846(ra) # 8000309e <turn_off_bit>
    }
  }
}
    800037dc:	60e6                	ld	ra,88(sp)
    800037de:	6446                	ld	s0,80(sp)
    800037e0:	64a6                	ld	s1,72(sp)
    800037e2:	6906                	ld	s2,64(sp)
    800037e4:	79e2                	ld	s3,56(sp)
    800037e6:	7a42                	ld	s4,48(sp)
    800037e8:	7aa2                	ld	s5,40(sp)
    800037ea:	7b02                	ld	s6,32(sp)
    800037ec:	6be2                	ld	s7,24(sp)
    800037ee:	6c42                	ld	s8,16(sp)
    800037f0:	6ca2                	ld	s9,8(sp)
    800037f2:	6d02                	ld	s10,0(sp)
    800037f4:	6125                	addi	sp,sp,96
    800037f6:	8082                	ret
        handle_stop(p);
    800037f8:	854e                	mv	a0,s3
    800037fa:	00000097          	auipc	ra,0x0
    800037fe:	db8080e7          	jalr	-584(ra) # 800035b2 <handle_stop>
    80003802:	bde5                	j	800036fa <check_pending_signals+0x70>

0000000080003804 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80003804:	1101                	addi	sp,sp,-32
    80003806:	ec06                	sd	ra,24(sp)
    80003808:	e822                	sd	s0,16(sp)
    8000380a:	e426                	sd	s1,8(sp)
    8000380c:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000380e:	ffffe097          	auipc	ra,0xffffe
    80003812:	570080e7          	jalr	1392(ra) # 80001d7e <myproc>
    80003816:	84aa                	mv	s1,a0
  struct kthread *t = mykthread();
    80003818:	ffffe097          	auipc	ra,0xffffe
    8000381c:	5a6080e7          	jalr	1446(ra) # 80001dbe <mykthread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003820:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80003824:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003826:	10079073          	csrw	sstatus,a5

  intr_off();
  

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    8000382a:	00004617          	auipc	a2,0x4
    8000382e:	7d660613          	addi	a2,a2,2006 # 80008000 <_trampoline>
    80003832:	00004697          	auipc	a3,0x4
    80003836:	7ce68693          	addi	a3,a3,1998 # 80008000 <_trampoline>
    8000383a:	8e91                	sub	a3,a3,a2
    8000383c:	040007b7          	lui	a5,0x4000
    80003840:	17fd                	addi	a5,a5,-1
    80003842:	07b2                	slli	a5,a5,0xc
    80003844:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003846:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  t->trapframe->kernel_satp = r_satp();         // kernel page table
    8000384a:	6138                	ld	a4,64(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000384c:	180026f3          	csrr	a3,satp
    80003850:	e314                	sd	a3,0(a4)
  t->trapframe->kernel_sp = t->kstack + PGSIZE; // process's kernel stack
    80003852:	6138                	ld	a4,64(a0)
    80003854:	7d14                	ld	a3,56(a0)
    80003856:	6585                	lui	a1,0x1
    80003858:	96ae                	add	a3,a3,a1
    8000385a:	e714                	sd	a3,8(a4)
  t->trapframe->kernel_trap = (uint64)usertrap;
    8000385c:	6138                	ld	a4,64(a0)
    8000385e:	00000697          	auipc	a3,0x0
    80003862:	15868693          	addi	a3,a3,344 # 800039b6 <usertrap>
    80003866:	eb14                	sd	a3,16(a4)
  t->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80003868:	6138                	ld	a4,64(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000386a:	8692                	mv	a3,tp
    8000386c:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000386e:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80003872:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80003876:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000387a:	10069073          	csrw	sstatus,a3
  w_sstatus(x);
  

  // set S Exception Program Counter to the saved user pc.
  w_sepc(t->trapframe->epc);
    8000387e:	6138                	ld	a4,64(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003880:	6f18                	ld	a4,24(a4)
    80003882:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80003886:	60ac                	ld	a1,64(s1)
    80003888:	81b1                	srli	a1,a1,0xc
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
 
 
  int thread_ind = (int)(t - p->kthreads);
    8000388a:	28848493          	addi	s1,s1,648
    8000388e:	8d05                	sub	a0,a0,s1
    80003890:	850d                	srai	a0,a0,0x3




  ((void (*)(uint64,uint64))fn)(TRAPFRAME + (uint64)(thread_ind * sizeof(struct trapframe)), satp);
    80003892:	00005717          	auipc	a4,0x5
    80003896:	77e73703          	ld	a4,1918(a4) # 80009010 <etext+0x10>
    8000389a:	02e5053b          	mulw	a0,a0,a4
    8000389e:	00351693          	slli	a3,a0,0x3
    800038a2:	9536                	add	a0,a0,a3
    800038a4:	0516                	slli	a0,a0,0x5
    800038a6:	020006b7          	lui	a3,0x2000
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    800038aa:	00004717          	auipc	a4,0x4
    800038ae:	7e670713          	addi	a4,a4,2022 # 80008090 <userret>
    800038b2:	8f11                	sub	a4,a4,a2
    800038b4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME + (uint64)(thread_ind * sizeof(struct trapframe)), satp);
    800038b6:	577d                	li	a4,-1
    800038b8:	177e                	slli	a4,a4,0x3f
    800038ba:	8dd9                	or	a1,a1,a4
    800038bc:	16fd                	addi	a3,a3,-1
    800038be:	06b6                	slli	a3,a3,0xd
    800038c0:	9536                	add	a0,a0,a3
    800038c2:	9782                	jalr	a5

}
    800038c4:	60e2                	ld	ra,24(sp)
    800038c6:	6442                	ld	s0,16(sp)
    800038c8:	64a2                	ld	s1,8(sp)
    800038ca:	6105                	addi	sp,sp,32
    800038cc:	8082                	ret

00000000800038ce <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800038ce:	1101                	addi	sp,sp,-32
    800038d0:	ec06                	sd	ra,24(sp)
    800038d2:	e822                	sd	s0,16(sp)
    800038d4:	e426                	sd	s1,8(sp)
    800038d6:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800038d8:	00031497          	auipc	s1,0x31
    800038dc:	45048493          	addi	s1,s1,1104 # 80034d28 <tickslock>
    800038e0:	8526                	mv	a0,s1
    800038e2:	ffffd097          	auipc	ra,0xffffd
    800038e6:	326080e7          	jalr	806(ra) # 80000c08 <acquire>
  ticks++;
    800038ea:	00006517          	auipc	a0,0x6
    800038ee:	74650513          	addi	a0,a0,1862 # 8000a030 <ticks>
    800038f2:	411c                	lw	a5,0(a0)
    800038f4:	2785                	addiw	a5,a5,1
    800038f6:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800038f8:	fffff097          	auipc	ra,0xfffff
    800038fc:	f86080e7          	jalr	-122(ra) # 8000287e <wakeup>
  release(&tickslock);
    80003900:	8526                	mv	a0,s1
    80003902:	ffffd097          	auipc	ra,0xffffd
    80003906:	3dc080e7          	jalr	988(ra) # 80000cde <release>
}
    8000390a:	60e2                	ld	ra,24(sp)
    8000390c:	6442                	ld	s0,16(sp)
    8000390e:	64a2                	ld	s1,8(sp)
    80003910:	6105                	addi	sp,sp,32
    80003912:	8082                	ret

0000000080003914 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80003914:	1101                	addi	sp,sp,-32
    80003916:	ec06                	sd	ra,24(sp)
    80003918:	e822                	sd	s0,16(sp)
    8000391a:	e426                	sd	s1,8(sp)
    8000391c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000391e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80003922:	00074d63          	bltz	a4,8000393c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80003926:	57fd                	li	a5,-1
    80003928:	17fe                	slli	a5,a5,0x3f
    8000392a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000392c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000392e:	06f70363          	beq	a4,a5,80003994 <devintr+0x80>
  }
}
    80003932:	60e2                	ld	ra,24(sp)
    80003934:	6442                	ld	s0,16(sp)
    80003936:	64a2                	ld	s1,8(sp)
    80003938:	6105                	addi	sp,sp,32
    8000393a:	8082                	ret
     (scause & 0xff) == 9){
    8000393c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80003940:	46a5                	li	a3,9
    80003942:	fed792e3          	bne	a5,a3,80003926 <devintr+0x12>
    int irq = plic_claim();
    80003946:	00004097          	auipc	ra,0x4
    8000394a:	862080e7          	jalr	-1950(ra) # 800071a8 <plic_claim>
    8000394e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80003950:	47a9                	li	a5,10
    80003952:	02f50763          	beq	a0,a5,80003980 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80003956:	4785                	li	a5,1
    80003958:	02f50963          	beq	a0,a5,8000398a <devintr+0x76>
    return 1;
    8000395c:	4505                	li	a0,1
    } else if(irq){
    8000395e:	d8f1                	beqz	s1,80003932 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80003960:	85a6                	mv	a1,s1
    80003962:	00006517          	auipc	a0,0x6
    80003966:	b2e50513          	addi	a0,a0,-1234 # 80009490 <states.0+0x28>
    8000396a:	ffffd097          	auipc	ra,0xffffd
    8000396e:	c0e080e7          	jalr	-1010(ra) # 80000578 <printf>
      plic_complete(irq);
    80003972:	8526                	mv	a0,s1
    80003974:	00004097          	auipc	ra,0x4
    80003978:	858080e7          	jalr	-1960(ra) # 800071cc <plic_complete>
    return 1;
    8000397c:	4505                	li	a0,1
    8000397e:	bf55                	j	80003932 <devintr+0x1e>
      uartintr();
    80003980:	ffffd097          	auipc	ra,0xffffd
    80003984:	00a080e7          	jalr	10(ra) # 8000098a <uartintr>
    80003988:	b7ed                	j	80003972 <devintr+0x5e>
      virtio_disk_intr();
    8000398a:	00004097          	auipc	ra,0x4
    8000398e:	cd4080e7          	jalr	-812(ra) # 8000765e <virtio_disk_intr>
    80003992:	b7c5                	j	80003972 <devintr+0x5e>
    if(cpuid() == 0){
    80003994:	ffffe097          	auipc	ra,0xffffe
    80003998:	3b6080e7          	jalr	950(ra) # 80001d4a <cpuid>
    8000399c:	c901                	beqz	a0,800039ac <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000399e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800039a2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800039a4:	14479073          	csrw	sip,a5
    return 2;
    800039a8:	4509                	li	a0,2
    800039aa:	b761                	j	80003932 <devintr+0x1e>
      clockintr();
    800039ac:	00000097          	auipc	ra,0x0
    800039b0:	f22080e7          	jalr	-222(ra) # 800038ce <clockintr>
    800039b4:	b7ed                	j	8000399e <devintr+0x8a>

00000000800039b6 <usertrap>:
{
    800039b6:	1101                	addi	sp,sp,-32
    800039b8:	ec06                	sd	ra,24(sp)
    800039ba:	e822                	sd	s0,16(sp)
    800039bc:	e426                	sd	s1,8(sp)
    800039be:	e04a                	sd	s2,0(sp)
    800039c0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800039c2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800039c6:	1007f793          	andi	a5,a5,256
    800039ca:	e3dd                	bnez	a5,80003a70 <usertrap+0xba>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800039cc:	00003797          	auipc	a5,0x3
    800039d0:	6d478793          	addi	a5,a5,1748 # 800070a0 <kernelvec>
    800039d4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800039d8:	ffffe097          	auipc	ra,0xffffe
    800039dc:	3a6080e7          	jalr	934(ra) # 80001d7e <myproc>
    800039e0:	84aa                	mv	s1,a0
  struct kthread *t = mykthread();
    800039e2:	ffffe097          	auipc	ra,0xffffe
    800039e6:	3dc080e7          	jalr	988(ra) # 80001dbe <mykthread>
    800039ea:	892a                	mv	s2,a0
  t->trapframe->epc = r_sepc();
    800039ec:	613c                	ld	a5,64(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800039ee:	14102773          	csrr	a4,sepc
    800039f2:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800039f4:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800039f8:	47a1                	li	a5,8
    800039fa:	08f71f63          	bne	a4,a5,80003a98 <usertrap+0xe2>
    if(t->killed == 1)
    800039fe:	5518                	lw	a4,40(a0)
    80003a00:	4785                	li	a5,1
    80003a02:	06f70f63          	beq	a4,a5,80003a80 <usertrap+0xca>
    else if(p->killed)
    80003a06:	4cdc                	lw	a5,28(s1)
    80003a08:	e3d1                	bnez	a5,80003a8c <usertrap+0xd6>
    t->trapframe->epc += 4;
    80003a0a:	04093703          	ld	a4,64(s2)
    80003a0e:	6f1c                	ld	a5,24(a4)
    80003a10:	0791                	addi	a5,a5,4
    80003a12:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003a14:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003a18:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003a1c:	10079073          	csrw	sstatus,a5
    syscall();
    80003a20:	00000097          	auipc	ra,0x0
    80003a24:	382080e7          	jalr	898(ra) # 80003da2 <syscall>
  if(holding(&p->lock))
    80003a28:	8526                	mv	a0,s1
    80003a2a:	ffffd097          	auipc	ra,0xffffd
    80003a2e:	164080e7          	jalr	356(ra) # 80000b8e <holding>
    80003a32:	e95d                	bnez	a0,80003ae8 <usertrap+0x132>
  acquire(&p->lock);
    80003a34:	8526                	mv	a0,s1
    80003a36:	ffffd097          	auipc	ra,0xffffd
    80003a3a:	1d2080e7          	jalr	466(ra) # 80000c08 <acquire>
  if(!p->handling_sig_flag){
    80003a3e:	2844a783          	lw	a5,644(s1)
    80003a42:	cfc5                	beqz	a5,80003afa <usertrap+0x144>
  release(&p->lock);
    80003a44:	8526                	mv	a0,s1
    80003a46:	ffffd097          	auipc	ra,0xffffd
    80003a4a:	298080e7          	jalr	664(ra) # 80000cde <release>
  if(t->killed == 1)
    80003a4e:	02892703          	lw	a4,40(s2)
    80003a52:	4785                	li	a5,1
    80003a54:	0cf70863          	beq	a4,a5,80003b24 <usertrap+0x16e>
  else if(p->killed)
    80003a58:	4cdc                	lw	a5,28(s1)
    80003a5a:	ebf9                	bnez	a5,80003b30 <usertrap+0x17a>
  usertrapret();
    80003a5c:	00000097          	auipc	ra,0x0
    80003a60:	da8080e7          	jalr	-600(ra) # 80003804 <usertrapret>
}
    80003a64:	60e2                	ld	ra,24(sp)
    80003a66:	6442                	ld	s0,16(sp)
    80003a68:	64a2                	ld	s1,8(sp)
    80003a6a:	6902                	ld	s2,0(sp)
    80003a6c:	6105                	addi	sp,sp,32
    80003a6e:	8082                	ret
    panic("usertrap: not from user mode");
    80003a70:	00006517          	auipc	a0,0x6
    80003a74:	a4050513          	addi	a0,a0,-1472 # 800094b0 <states.0+0x48>
    80003a78:	ffffd097          	auipc	ra,0xffffd
    80003a7c:	ab6080e7          	jalr	-1354(ra) # 8000052e <panic>
      kthread_exit(-1); // Kill current thread
    80003a80:	557d                	li	a0,-1
    80003a82:	fffff097          	auipc	ra,0xfffff
    80003a86:	03c080e7          	jalr	60(ra) # 80002abe <kthread_exit>
    80003a8a:	b741                	j	80003a0a <usertrap+0x54>
      exit(-1); // Kill the hole procces
    80003a8c:	557d                	li	a0,-1
    80003a8e:	fffff097          	auipc	ra,0xfffff
    80003a92:	0ce080e7          	jalr	206(ra) # 80002b5c <exit>
    80003a96:	bf95                	j	80003a0a <usertrap+0x54>
  else if((which_dev = devintr()) != 0)
    80003a98:	00000097          	auipc	ra,0x0
    80003a9c:	e7c080e7          	jalr	-388(ra) # 80003914 <devintr>
    80003aa0:	c909                	beqz	a0,80003ab2 <usertrap+0xfc>
  if(which_dev == 2)
    80003aa2:	4789                	li	a5,2
    80003aa4:	f8f512e3          	bne	a0,a5,80003a28 <usertrap+0x72>
    yield();
    80003aa8:	fffff097          	auipc	ra,0xfffff
    80003aac:	c10080e7          	jalr	-1008(ra) # 800026b8 <yield>
    80003ab0:	bfa5                	j	80003a28 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003ab2:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80003ab6:	50d0                	lw	a2,36(s1)
    80003ab8:	00006517          	auipc	a0,0x6
    80003abc:	a1850513          	addi	a0,a0,-1512 # 800094d0 <states.0+0x68>
    80003ac0:	ffffd097          	auipc	ra,0xffffd
    80003ac4:	ab8080e7          	jalr	-1352(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003ac8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003acc:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003ad0:	00006517          	auipc	a0,0x6
    80003ad4:	a3050513          	addi	a0,a0,-1488 # 80009500 <states.0+0x98>
    80003ad8:	ffffd097          	auipc	ra,0xffffd
    80003adc:	aa0080e7          	jalr	-1376(ra) # 80000578 <printf>
    t->killed = 1;
    80003ae0:	4785                	li	a5,1
    80003ae2:	02f92423          	sw	a5,40(s2)
  if(which_dev == 2)
    80003ae6:	b789                	j	80003a28 <usertrap+0x72>
    printf("fuck i am holding the lock in usertrap\n");   // TODO : delete
    80003ae8:	00006517          	auipc	a0,0x6
    80003aec:	a3850513          	addi	a0,a0,-1480 # 80009520 <states.0+0xb8>
    80003af0:	ffffd097          	auipc	ra,0xffffd
    80003af4:	a88080e7          	jalr	-1400(ra) # 80000578 <printf>
    80003af8:	bf35                	j	80003a34 <usertrap+0x7e>
    p->handling_sig_flag = 1;
    80003afa:	4785                	li	a5,1
    80003afc:	28f4a223          	sw	a5,644(s1)
    release(&p->lock);
    80003b00:	8526                	mv	a0,s1
    80003b02:	ffffd097          	auipc	ra,0xffffd
    80003b06:	1dc080e7          	jalr	476(ra) # 80000cde <release>
    check_pending_signals(p);
    80003b0a:	8526                	mv	a0,s1
    80003b0c:	00000097          	auipc	ra,0x0
    80003b10:	b7e080e7          	jalr	-1154(ra) # 8000368a <check_pending_signals>
    acquire(&p->lock);
    80003b14:	8526                	mv	a0,s1
    80003b16:	ffffd097          	auipc	ra,0xffffd
    80003b1a:	0f2080e7          	jalr	242(ra) # 80000c08 <acquire>
    p->handling_sig_flag = 0;
    80003b1e:	2804a223          	sw	zero,644(s1)
    80003b22:	b70d                	j	80003a44 <usertrap+0x8e>
    kthread_exit(-1); // Kill current thread
    80003b24:	557d                	li	a0,-1
    80003b26:	fffff097          	auipc	ra,0xfffff
    80003b2a:	f98080e7          	jalr	-104(ra) # 80002abe <kthread_exit>
    80003b2e:	b73d                	j	80003a5c <usertrap+0xa6>
    exit(-1); // Kill the hole procces
    80003b30:	557d                	li	a0,-1
    80003b32:	fffff097          	auipc	ra,0xfffff
    80003b36:	02a080e7          	jalr	42(ra) # 80002b5c <exit>
    80003b3a:	b70d                	j	80003a5c <usertrap+0xa6>

0000000080003b3c <kerneltrap>:
{
    80003b3c:	7179                	addi	sp,sp,-48
    80003b3e:	f406                	sd	ra,40(sp)
    80003b40:	f022                	sd	s0,32(sp)
    80003b42:	ec26                	sd	s1,24(sp)
    80003b44:	e84a                	sd	s2,16(sp)
    80003b46:	e44e                	sd	s3,8(sp)
    80003b48:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003b4a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003b4e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003b52:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003b56:	1004f793          	andi	a5,s1,256
    80003b5a:	cb85                	beqz	a5,80003b8a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003b5c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003b60:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80003b62:	ef85                	bnez	a5,80003b9a <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80003b64:	00000097          	auipc	ra,0x0
    80003b68:	db0080e7          	jalr	-592(ra) # 80003914 <devintr>
    80003b6c:	cd1d                	beqz	a0,80003baa <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    80003b6e:	4789                	li	a5,2
    80003b70:	08f50763          	beq	a0,a5,80003bfe <kerneltrap+0xc2>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003b74:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003b78:	10049073          	csrw	sstatus,s1
}
    80003b7c:	70a2                	ld	ra,40(sp)
    80003b7e:	7402                	ld	s0,32(sp)
    80003b80:	64e2                	ld	s1,24(sp)
    80003b82:	6942                	ld	s2,16(sp)
    80003b84:	69a2                	ld	s3,8(sp)
    80003b86:	6145                	addi	sp,sp,48
    80003b88:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003b8a:	00006517          	auipc	a0,0x6
    80003b8e:	9be50513          	addi	a0,a0,-1602 # 80009548 <states.0+0xe0>
    80003b92:	ffffd097          	auipc	ra,0xffffd
    80003b96:	99c080e7          	jalr	-1636(ra) # 8000052e <panic>
    panic("kerneltrap: interrupts enabled");
    80003b9a:	00006517          	auipc	a0,0x6
    80003b9e:	9d650513          	addi	a0,a0,-1578 # 80009570 <states.0+0x108>
    80003ba2:	ffffd097          	auipc	ra,0xffffd
    80003ba6:	98c080e7          	jalr	-1652(ra) # 8000052e <panic>
    printf("proc %d recieved kernel trap\n",myproc()->pid);
    80003baa:	ffffe097          	auipc	ra,0xffffe
    80003bae:	1d4080e7          	jalr	468(ra) # 80001d7e <myproc>
    80003bb2:	514c                	lw	a1,36(a0)
    80003bb4:	00006517          	auipc	a0,0x6
    80003bb8:	9dc50513          	addi	a0,a0,-1572 # 80009590 <states.0+0x128>
    80003bbc:	ffffd097          	auipc	ra,0xffffd
    80003bc0:	9bc080e7          	jalr	-1604(ra) # 80000578 <printf>
    printf("scause %p\n", scause);
    80003bc4:	85ce                	mv	a1,s3
    80003bc6:	00006517          	auipc	a0,0x6
    80003bca:	9ea50513          	addi	a0,a0,-1558 # 800095b0 <states.0+0x148>
    80003bce:	ffffd097          	auipc	ra,0xffffd
    80003bd2:	9aa080e7          	jalr	-1622(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003bd6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003bda:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003bde:	00006517          	auipc	a0,0x6
    80003be2:	9e250513          	addi	a0,a0,-1566 # 800095c0 <states.0+0x158>
    80003be6:	ffffd097          	auipc	ra,0xffffd
    80003bea:	992080e7          	jalr	-1646(ra) # 80000578 <printf>
    panic("kerneltrap");
    80003bee:	00006517          	auipc	a0,0x6
    80003bf2:	9ea50513          	addi	a0,a0,-1558 # 800095d8 <states.0+0x170>
    80003bf6:	ffffd097          	auipc	ra,0xffffd
    80003bfa:	938080e7          	jalr	-1736(ra) # 8000052e <panic>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    80003bfe:	ffffe097          	auipc	ra,0xffffe
    80003c02:	180080e7          	jalr	384(ra) # 80001d7e <myproc>
    80003c06:	d53d                	beqz	a0,80003b74 <kerneltrap+0x38>
    80003c08:	ffffe097          	auipc	ra,0xffffe
    80003c0c:	1b6080e7          	jalr	438(ra) # 80001dbe <mykthread>
    80003c10:	d135                	beqz	a0,80003b74 <kerneltrap+0x38>
    80003c12:	ffffe097          	auipc	ra,0xffffe
    80003c16:	1ac080e7          	jalr	428(ra) # 80001dbe <mykthread>
    80003c1a:	4d18                	lw	a4,24(a0)
    80003c1c:	4791                	li	a5,4
    80003c1e:	f4f71be3          	bne	a4,a5,80003b74 <kerneltrap+0x38>
    yield();
    80003c22:	fffff097          	auipc	ra,0xfffff
    80003c26:	a96080e7          	jalr	-1386(ra) # 800026b8 <yield>
    80003c2a:	b7a9                	j	80003b74 <kerneltrap+0x38>

0000000080003c2c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80003c2c:	1101                	addi	sp,sp,-32
    80003c2e:	ec06                	sd	ra,24(sp)
    80003c30:	e822                	sd	s0,16(sp)
    80003c32:	e426                	sd	s1,8(sp)
    80003c34:	1000                	addi	s0,sp,32
    80003c36:	84aa                	mv	s1,a0

  struct kthread *t = mykthread();
    80003c38:	ffffe097          	auipc	ra,0xffffe
    80003c3c:	186080e7          	jalr	390(ra) # 80001dbe <mykthread>
  switch (n) {
    80003c40:	4795                	li	a5,5
    80003c42:	0497e163          	bltu	a5,s1,80003c84 <argraw+0x58>
    80003c46:	048a                	slli	s1,s1,0x2
    80003c48:	00006717          	auipc	a4,0x6
    80003c4c:	9c870713          	addi	a4,a4,-1592 # 80009610 <states.0+0x1a8>
    80003c50:	94ba                	add	s1,s1,a4
    80003c52:	409c                	lw	a5,0(s1)
    80003c54:	97ba                	add	a5,a5,a4
    80003c56:	8782                	jr	a5
  case 0:
    return t->trapframe->a0;
    80003c58:	613c                	ld	a5,64(a0)
    80003c5a:	7ba8                	ld	a0,112(a5)
  case 5:
    return t->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003c5c:	60e2                	ld	ra,24(sp)
    80003c5e:	6442                	ld	s0,16(sp)
    80003c60:	64a2                	ld	s1,8(sp)
    80003c62:	6105                	addi	sp,sp,32
    80003c64:	8082                	ret
    return t->trapframe->a1;
    80003c66:	613c                	ld	a5,64(a0)
    80003c68:	7fa8                	ld	a0,120(a5)
    80003c6a:	bfcd                	j	80003c5c <argraw+0x30>
    return t->trapframe->a2;
    80003c6c:	613c                	ld	a5,64(a0)
    80003c6e:	63c8                	ld	a0,128(a5)
    80003c70:	b7f5                	j	80003c5c <argraw+0x30>
    return t->trapframe->a3;
    80003c72:	613c                	ld	a5,64(a0)
    80003c74:	67c8                	ld	a0,136(a5)
    80003c76:	b7dd                	j	80003c5c <argraw+0x30>
    return t->trapframe->a4;
    80003c78:	613c                	ld	a5,64(a0)
    80003c7a:	6bc8                	ld	a0,144(a5)
    80003c7c:	b7c5                	j	80003c5c <argraw+0x30>
    return t->trapframe->a5;
    80003c7e:	613c                	ld	a5,64(a0)
    80003c80:	6fc8                	ld	a0,152(a5)
    80003c82:	bfe9                	j	80003c5c <argraw+0x30>
  panic("argraw");
    80003c84:	00006517          	auipc	a0,0x6
    80003c88:	96450513          	addi	a0,a0,-1692 # 800095e8 <states.0+0x180>
    80003c8c:	ffffd097          	auipc	ra,0xffffd
    80003c90:	8a2080e7          	jalr	-1886(ra) # 8000052e <panic>

0000000080003c94 <fetchaddr>:
{
    80003c94:	1101                	addi	sp,sp,-32
    80003c96:	ec06                	sd	ra,24(sp)
    80003c98:	e822                	sd	s0,16(sp)
    80003c9a:	e426                	sd	s1,8(sp)
    80003c9c:	e04a                	sd	s2,0(sp)
    80003c9e:	1000                	addi	s0,sp,32
    80003ca0:	84aa                	mv	s1,a0
    80003ca2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003ca4:	ffffe097          	auipc	ra,0xffffe
    80003ca8:	0da080e7          	jalr	218(ra) # 80001d7e <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003cac:	7d1c                	ld	a5,56(a0)
    80003cae:	02f4f863          	bgeu	s1,a5,80003cde <fetchaddr+0x4a>
    80003cb2:	00848713          	addi	a4,s1,8
    80003cb6:	02e7e663          	bltu	a5,a4,80003ce2 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003cba:	46a1                	li	a3,8
    80003cbc:	8626                	mv	a2,s1
    80003cbe:	85ca                	mv	a1,s2
    80003cc0:	6128                	ld	a0,64(a0)
    80003cc2:	ffffe097          	auipc	ra,0xffffe
    80003cc6:	d30080e7          	jalr	-720(ra) # 800019f2 <copyin>
    80003cca:	00a03533          	snez	a0,a0
    80003cce:	40a00533          	neg	a0,a0
}
    80003cd2:	60e2                	ld	ra,24(sp)
    80003cd4:	6442                	ld	s0,16(sp)
    80003cd6:	64a2                	ld	s1,8(sp)
    80003cd8:	6902                	ld	s2,0(sp)
    80003cda:	6105                	addi	sp,sp,32
    80003cdc:	8082                	ret
    return -1;
    80003cde:	557d                	li	a0,-1
    80003ce0:	bfcd                	j	80003cd2 <fetchaddr+0x3e>
    80003ce2:	557d                	li	a0,-1
    80003ce4:	b7fd                	j	80003cd2 <fetchaddr+0x3e>

0000000080003ce6 <fetchstr>:
{
    80003ce6:	7179                	addi	sp,sp,-48
    80003ce8:	f406                	sd	ra,40(sp)
    80003cea:	f022                	sd	s0,32(sp)
    80003cec:	ec26                	sd	s1,24(sp)
    80003cee:	e84a                	sd	s2,16(sp)
    80003cf0:	e44e                	sd	s3,8(sp)
    80003cf2:	1800                	addi	s0,sp,48
    80003cf4:	892a                	mv	s2,a0
    80003cf6:	84ae                	mv	s1,a1
    80003cf8:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80003cfa:	ffffe097          	auipc	ra,0xffffe
    80003cfe:	084080e7          	jalr	132(ra) # 80001d7e <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80003d02:	86ce                	mv	a3,s3
    80003d04:	864a                	mv	a2,s2
    80003d06:	85a6                	mv	a1,s1
    80003d08:	6128                	ld	a0,64(a0)
    80003d0a:	ffffe097          	auipc	ra,0xffffe
    80003d0e:	d76080e7          	jalr	-650(ra) # 80001a80 <copyinstr>
  if(err < 0)
    80003d12:	00054763          	bltz	a0,80003d20 <fetchstr+0x3a>
  return strlen(buf);
    80003d16:	8526                	mv	a0,s1
    80003d18:	ffffd097          	auipc	ra,0xffffd
    80003d1c:	44a080e7          	jalr	1098(ra) # 80001162 <strlen>
}
    80003d20:	70a2                	ld	ra,40(sp)
    80003d22:	7402                	ld	s0,32(sp)
    80003d24:	64e2                	ld	s1,24(sp)
    80003d26:	6942                	ld	s2,16(sp)
    80003d28:	69a2                	ld	s3,8(sp)
    80003d2a:	6145                	addi	sp,sp,48
    80003d2c:	8082                	ret

0000000080003d2e <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003d2e:	1101                	addi	sp,sp,-32
    80003d30:	ec06                	sd	ra,24(sp)
    80003d32:	e822                	sd	s0,16(sp)
    80003d34:	e426                	sd	s1,8(sp)
    80003d36:	1000                	addi	s0,sp,32
    80003d38:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003d3a:	00000097          	auipc	ra,0x0
    80003d3e:	ef2080e7          	jalr	-270(ra) # 80003c2c <argraw>
    80003d42:	c088                	sw	a0,0(s1)
  return 0;
}
    80003d44:	4501                	li	a0,0
    80003d46:	60e2                	ld	ra,24(sp)
    80003d48:	6442                	ld	s0,16(sp)
    80003d4a:	64a2                	ld	s1,8(sp)
    80003d4c:	6105                	addi	sp,sp,32
    80003d4e:	8082                	ret

0000000080003d50 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003d50:	1101                	addi	sp,sp,-32
    80003d52:	ec06                	sd	ra,24(sp)
    80003d54:	e822                	sd	s0,16(sp)
    80003d56:	e426                	sd	s1,8(sp)
    80003d58:	1000                	addi	s0,sp,32
    80003d5a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003d5c:	00000097          	auipc	ra,0x0
    80003d60:	ed0080e7          	jalr	-304(ra) # 80003c2c <argraw>
    80003d64:	e088                	sd	a0,0(s1)
  return 0;
}
    80003d66:	4501                	li	a0,0
    80003d68:	60e2                	ld	ra,24(sp)
    80003d6a:	6442                	ld	s0,16(sp)
    80003d6c:	64a2                	ld	s1,8(sp)
    80003d6e:	6105                	addi	sp,sp,32
    80003d70:	8082                	ret

0000000080003d72 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003d72:	1101                	addi	sp,sp,-32
    80003d74:	ec06                	sd	ra,24(sp)
    80003d76:	e822                	sd	s0,16(sp)
    80003d78:	e426                	sd	s1,8(sp)
    80003d7a:	e04a                	sd	s2,0(sp)
    80003d7c:	1000                	addi	s0,sp,32
    80003d7e:	84ae                	mv	s1,a1
    80003d80:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003d82:	00000097          	auipc	ra,0x0
    80003d86:	eaa080e7          	jalr	-342(ra) # 80003c2c <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003d8a:	864a                	mv	a2,s2
    80003d8c:	85a6                	mv	a1,s1
    80003d8e:	00000097          	auipc	ra,0x0
    80003d92:	f58080e7          	jalr	-168(ra) # 80003ce6 <fetchstr>
}
    80003d96:	60e2                	ld	ra,24(sp)
    80003d98:	6442                	ld	s0,16(sp)
    80003d9a:	64a2                	ld	s1,8(sp)
    80003d9c:	6902                	ld	s2,0(sp)
    80003d9e:	6105                	addi	sp,sp,32
    80003da0:	8082                	ret

0000000080003da2 <syscall>:
[SYS_bsem_up] sys_bsem_up
};

void
syscall(void)
{
    80003da2:	7179                	addi	sp,sp,-48
    80003da4:	f406                	sd	ra,40(sp)
    80003da6:	f022                	sd	s0,32(sp)
    80003da8:	ec26                	sd	s1,24(sp)
    80003daa:	e84a                	sd	s2,16(sp)
    80003dac:	e44e                	sd	s3,8(sp)
    80003dae:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80003db0:	ffffe097          	auipc	ra,0xffffe
    80003db4:	fce080e7          	jalr	-50(ra) # 80001d7e <myproc>
    80003db8:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80003dba:	ffffe097          	auipc	ra,0xffffe
    80003dbe:	004080e7          	jalr	4(ra) # 80001dbe <mykthread>
    80003dc2:	84aa                	mv	s1,a0

  num = t->trapframe->a7;
    80003dc4:	04053983          	ld	s3,64(a0)
    80003dc8:	0a89b783          	ld	a5,168(s3)
    80003dcc:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003dd0:	37fd                	addiw	a5,a5,-1
    80003dd2:	477d                	li	a4,31
    80003dd4:	00f76f63          	bltu	a4,a5,80003df2 <syscall+0x50>
    80003dd8:	00369713          	slli	a4,a3,0x3
    80003ddc:	00006797          	auipc	a5,0x6
    80003de0:	84c78793          	addi	a5,a5,-1972 # 80009628 <syscalls>
    80003de4:	97ba                	add	a5,a5,a4
    80003de6:	639c                	ld	a5,0(a5)
    80003de8:	c789                	beqz	a5,80003df2 <syscall+0x50>
    t->trapframe->a0 = syscalls[num]();
    80003dea:	9782                	jalr	a5
    80003dec:	06a9b823          	sd	a0,112(s3)
    80003df0:	a005                	j	80003e10 <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003df2:	0d890613          	addi	a2,s2,216
    80003df6:	02492583          	lw	a1,36(s2)
    80003dfa:	00005517          	auipc	a0,0x5
    80003dfe:	7f650513          	addi	a0,a0,2038 # 800095f0 <states.0+0x188>
    80003e02:	ffffc097          	auipc	ra,0xffffc
    80003e06:	776080e7          	jalr	1910(ra) # 80000578 <printf>
            p->pid, p->name, num);
    t->trapframe->a0 = -1;
    80003e0a:	60bc                	ld	a5,64(s1)
    80003e0c:	577d                	li	a4,-1
    80003e0e:	fbb8                	sd	a4,112(a5)
  }
}
    80003e10:	70a2                	ld	ra,40(sp)
    80003e12:	7402                	ld	s0,32(sp)
    80003e14:	64e2                	ld	s1,24(sp)
    80003e16:	6942                	ld	s2,16(sp)
    80003e18:	69a2                	ld	s3,8(sp)
    80003e1a:	6145                	addi	sp,sp,48
    80003e1c:	8082                	ret

0000000080003e1e <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003e1e:	1101                	addi	sp,sp,-32
    80003e20:	ec06                	sd	ra,24(sp)
    80003e22:	e822                	sd	s0,16(sp)
    80003e24:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003e26:	fec40593          	addi	a1,s0,-20
    80003e2a:	4501                	li	a0,0
    80003e2c:	00000097          	auipc	ra,0x0
    80003e30:	f02080e7          	jalr	-254(ra) # 80003d2e <argint>
    return -1;
    80003e34:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003e36:	00054963          	bltz	a0,80003e48 <sys_exit+0x2a>
  exit(n);
    80003e3a:	fec42503          	lw	a0,-20(s0)
    80003e3e:	fffff097          	auipc	ra,0xfffff
    80003e42:	d1e080e7          	jalr	-738(ra) # 80002b5c <exit>
  return 0;  // not reached
    80003e46:	4781                	li	a5,0
}
    80003e48:	853e                	mv	a0,a5
    80003e4a:	60e2                	ld	ra,24(sp)
    80003e4c:	6442                	ld	s0,16(sp)
    80003e4e:	6105                	addi	sp,sp,32
    80003e50:	8082                	ret

0000000080003e52 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003e52:	1141                	addi	sp,sp,-16
    80003e54:	e406                	sd	ra,8(sp)
    80003e56:	e022                	sd	s0,0(sp)
    80003e58:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003e5a:	ffffe097          	auipc	ra,0xffffe
    80003e5e:	f24080e7          	jalr	-220(ra) # 80001d7e <myproc>
}
    80003e62:	5148                	lw	a0,36(a0)
    80003e64:	60a2                	ld	ra,8(sp)
    80003e66:	6402                	ld	s0,0(sp)
    80003e68:	0141                	addi	sp,sp,16
    80003e6a:	8082                	ret

0000000080003e6c <sys_fork>:

uint64
sys_fork(void)
{
    80003e6c:	1141                	addi	sp,sp,-16
    80003e6e:	e406                	sd	ra,8(sp)
    80003e70:	e022                	sd	s0,0(sp)
    80003e72:	0800                	addi	s0,sp,16
  return fork();
    80003e74:	ffffe097          	auipc	ra,0xffffe
    80003e78:	494080e7          	jalr	1172(ra) # 80002308 <fork>
}
    80003e7c:	60a2                	ld	ra,8(sp)
    80003e7e:	6402                	ld	s0,0(sp)
    80003e80:	0141                	addi	sp,sp,16
    80003e82:	8082                	ret

0000000080003e84 <sys_wait>:

uint64
sys_wait(void)
{
    80003e84:	1101                	addi	sp,sp,-32
    80003e86:	ec06                	sd	ra,24(sp)
    80003e88:	e822                	sd	s0,16(sp)
    80003e8a:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003e8c:	fe840593          	addi	a1,s0,-24
    80003e90:	4501                	li	a0,0
    80003e92:	00000097          	auipc	ra,0x0
    80003e96:	ebe080e7          	jalr	-322(ra) # 80003d50 <argaddr>
    80003e9a:	87aa                	mv	a5,a0
    return -1;
    80003e9c:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003e9e:	0007c863          	bltz	a5,80003eae <sys_wait+0x2a>
  return wait(p);
    80003ea2:	fe843503          	ld	a0,-24(s0)
    80003ea6:	fffff097          	auipc	ra,0xfffff
    80003eaa:	8b2080e7          	jalr	-1870(ra) # 80002758 <wait>
}
    80003eae:	60e2                	ld	ra,24(sp)
    80003eb0:	6442                	ld	s0,16(sp)
    80003eb2:	6105                	addi	sp,sp,32
    80003eb4:	8082                	ret

0000000080003eb6 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003eb6:	7179                	addi	sp,sp,-48
    80003eb8:	f406                	sd	ra,40(sp)
    80003eba:	f022                	sd	s0,32(sp)
    80003ebc:	ec26                	sd	s1,24(sp)
    80003ebe:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003ec0:	fdc40593          	addi	a1,s0,-36
    80003ec4:	4501                	li	a0,0
    80003ec6:	00000097          	auipc	ra,0x0
    80003eca:	e68080e7          	jalr	-408(ra) # 80003d2e <argint>
    return -1;
    80003ece:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003ed0:	00054f63          	bltz	a0,80003eee <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003ed4:	ffffe097          	auipc	ra,0xffffe
    80003ed8:	eaa080e7          	jalr	-342(ra) # 80001d7e <myproc>
    80003edc:	5d04                	lw	s1,56(a0)
  if(growproc(n) < 0)
    80003ede:	fdc42503          	lw	a0,-36(s0)
    80003ee2:	ffffe097          	auipc	ra,0xffffe
    80003ee6:	3b2080e7          	jalr	946(ra) # 80002294 <growproc>
    80003eea:	00054863          	bltz	a0,80003efa <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003eee:	8526                	mv	a0,s1
    80003ef0:	70a2                	ld	ra,40(sp)
    80003ef2:	7402                	ld	s0,32(sp)
    80003ef4:	64e2                	ld	s1,24(sp)
    80003ef6:	6145                	addi	sp,sp,48
    80003ef8:	8082                	ret
    return -1;
    80003efa:	54fd                	li	s1,-1
    80003efc:	bfcd                	j	80003eee <sys_sbrk+0x38>

0000000080003efe <sys_sleep>:

uint64
sys_sleep(void)
{
    80003efe:	7139                	addi	sp,sp,-64
    80003f00:	fc06                	sd	ra,56(sp)
    80003f02:	f822                	sd	s0,48(sp)
    80003f04:	f426                	sd	s1,40(sp)
    80003f06:	f04a                	sd	s2,32(sp)
    80003f08:	ec4e                	sd	s3,24(sp)
    80003f0a:	e852                	sd	s4,16(sp)
    80003f0c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003f0e:	fcc40593          	addi	a1,s0,-52
    80003f12:	4501                	li	a0,0
    80003f14:	00000097          	auipc	ra,0x0
    80003f18:	e1a080e7          	jalr	-486(ra) # 80003d2e <argint>
    return -1;
    80003f1c:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003f1e:	06054763          	bltz	a0,80003f8c <sys_sleep+0x8e>
  acquire(&tickslock);
    80003f22:	00031517          	auipc	a0,0x31
    80003f26:	e0650513          	addi	a0,a0,-506 # 80034d28 <tickslock>
    80003f2a:	ffffd097          	auipc	ra,0xffffd
    80003f2e:	cde080e7          	jalr	-802(ra) # 80000c08 <acquire>
  ticks0 = ticks;
    80003f32:	00006997          	auipc	s3,0x6
    80003f36:	0fe9a983          	lw	s3,254(s3) # 8000a030 <ticks>
  while(ticks - ticks0 < n){
    80003f3a:	fcc42783          	lw	a5,-52(s0)
    80003f3e:	cf95                	beqz	a5,80003f7a <sys_sleep+0x7c>
    if(myproc()->killed==1){
    80003f40:	4905                	li	s2,1
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003f42:	00031a17          	auipc	s4,0x31
    80003f46:	de6a0a13          	addi	s4,s4,-538 # 80034d28 <tickslock>
    80003f4a:	00006497          	auipc	s1,0x6
    80003f4e:	0e648493          	addi	s1,s1,230 # 8000a030 <ticks>
    if(myproc()->killed==1){
    80003f52:	ffffe097          	auipc	ra,0xffffe
    80003f56:	e2c080e7          	jalr	-468(ra) # 80001d7e <myproc>
    80003f5a:	4d5c                	lw	a5,28(a0)
    80003f5c:	05278163          	beq	a5,s2,80003f9e <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    80003f60:	85d2                	mv	a1,s4
    80003f62:	8526                	mv	a0,s1
    80003f64:	ffffe097          	auipc	ra,0xffffe
    80003f68:	790080e7          	jalr	1936(ra) # 800026f4 <sleep>
  while(ticks - ticks0 < n){
    80003f6c:	409c                	lw	a5,0(s1)
    80003f6e:	413787bb          	subw	a5,a5,s3
    80003f72:	fcc42703          	lw	a4,-52(s0)
    80003f76:	fce7eee3          	bltu	a5,a4,80003f52 <sys_sleep+0x54>
  }
  release(&tickslock);
    80003f7a:	00031517          	auipc	a0,0x31
    80003f7e:	dae50513          	addi	a0,a0,-594 # 80034d28 <tickslock>
    80003f82:	ffffd097          	auipc	ra,0xffffd
    80003f86:	d5c080e7          	jalr	-676(ra) # 80000cde <release>
  return 0;
    80003f8a:	4781                	li	a5,0
}
    80003f8c:	853e                	mv	a0,a5
    80003f8e:	70e2                	ld	ra,56(sp)
    80003f90:	7442                	ld	s0,48(sp)
    80003f92:	74a2                	ld	s1,40(sp)
    80003f94:	7902                	ld	s2,32(sp)
    80003f96:	69e2                	ld	s3,24(sp)
    80003f98:	6a42                	ld	s4,16(sp)
    80003f9a:	6121                	addi	sp,sp,64
    80003f9c:	8082                	ret
      release(&tickslock);
    80003f9e:	00031517          	auipc	a0,0x31
    80003fa2:	d8a50513          	addi	a0,a0,-630 # 80034d28 <tickslock>
    80003fa6:	ffffd097          	auipc	ra,0xffffd
    80003faa:	d38080e7          	jalr	-712(ra) # 80000cde <release>
      return -1;
    80003fae:	57fd                	li	a5,-1
    80003fb0:	bff1                	j	80003f8c <sys_sleep+0x8e>

0000000080003fb2 <sys_kill>:

uint64
sys_kill(void)
{
    80003fb2:	1101                	addi	sp,sp,-32
    80003fb4:	ec06                	sd	ra,24(sp)
    80003fb6:	e822                	sd	s0,16(sp)
    80003fb8:	1000                	addi	s0,sp,32
  int pid;
  int signum;

  if(argint(0, &pid) < 0)
    80003fba:	fec40593          	addi	a1,s0,-20
    80003fbe:	4501                	li	a0,0
    80003fc0:	00000097          	auipc	ra,0x0
    80003fc4:	d6e080e7          	jalr	-658(ra) # 80003d2e <argint>
    80003fc8:	87aa                	mv	a5,a0
    return -1;
    80003fca:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003fcc:	0207c963          	bltz	a5,80003ffe <sys_kill+0x4c>
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003fd0:	fe840593          	addi	a1,s0,-24
    80003fd4:	4505                	li	a0,1
    80003fd6:	00000097          	auipc	ra,0x0
    80003fda:	d58080e7          	jalr	-680(ra) # 80003d2e <argint>
    80003fde:	02054463          	bltz	a0,80004006 <sys_kill+0x54>
    80003fe2:	fe842583          	lw	a1,-24(s0)
    80003fe6:	0005871b          	sext.w	a4,a1
    80003fea:	47fd                	li	a5,31
    return -1;
    80003fec:	557d                	li	a0,-1
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003fee:	00e7e863          	bltu	a5,a4,80003ffe <sys_kill+0x4c>
  return kill(pid, signum);
    80003ff2:	fec42503          	lw	a0,-20(s0)
    80003ff6:	fffff097          	auipc	ra,0xfffff
    80003ffa:	f9e080e7          	jalr	-98(ra) # 80002f94 <kill>
}
    80003ffe:	60e2                	ld	ra,24(sp)
    80004000:	6442                	ld	s0,16(sp)
    80004002:	6105                	addi	sp,sp,32
    80004004:	8082                	ret
    return -1;
    80004006:	557d                	li	a0,-1
    80004008:	bfdd                	j	80003ffe <sys_kill+0x4c>

000000008000400a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000400a:	1101                	addi	sp,sp,-32
    8000400c:	ec06                	sd	ra,24(sp)
    8000400e:	e822                	sd	s0,16(sp)
    80004010:	e426                	sd	s1,8(sp)
    80004012:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80004014:	00031517          	auipc	a0,0x31
    80004018:	d1450513          	addi	a0,a0,-748 # 80034d28 <tickslock>
    8000401c:	ffffd097          	auipc	ra,0xffffd
    80004020:	bec080e7          	jalr	-1044(ra) # 80000c08 <acquire>
  xticks = ticks;
    80004024:	00006497          	auipc	s1,0x6
    80004028:	00c4a483          	lw	s1,12(s1) # 8000a030 <ticks>
  release(&tickslock);
    8000402c:	00031517          	auipc	a0,0x31
    80004030:	cfc50513          	addi	a0,a0,-772 # 80034d28 <tickslock>
    80004034:	ffffd097          	auipc	ra,0xffffd
    80004038:	caa080e7          	jalr	-854(ra) # 80000cde <release>
  return xticks;
}
    8000403c:	02049513          	slli	a0,s1,0x20
    80004040:	9101                	srli	a0,a0,0x20
    80004042:	60e2                	ld	ra,24(sp)
    80004044:	6442                	ld	s0,16(sp)
    80004046:	64a2                	ld	s1,8(sp)
    80004048:	6105                	addi	sp,sp,32
    8000404a:	8082                	ret

000000008000404c <sys_sigprocmask>:

uint64
sys_sigprocmask(void)
{
    8000404c:	1101                	addi	sp,sp,-32
    8000404e:	ec06                	sd	ra,24(sp)
    80004050:	e822                	sd	s0,16(sp)
    80004052:	1000                	addi	s0,sp,32
  int sigmask;

  if(argint(0, &sigmask) < 0)
    80004054:	fec40593          	addi	a1,s0,-20
    80004058:	4501                	li	a0,0
    8000405a:	00000097          	auipc	ra,0x0
    8000405e:	cd4080e7          	jalr	-812(ra) # 80003d2e <argint>
    80004062:	87aa                	mv	a5,a0
    return -1;
    80004064:	557d                	li	a0,-1
  if(argint(0, &sigmask) < 0)
    80004066:	0007ca63          	bltz	a5,8000407a <sys_sigprocmask+0x2e>
  return sigprocmask((uint)sigmask);
    8000406a:	fec42503          	lw	a0,-20(s0)
    8000406e:	fffff097          	auipc	ra,0xfffff
    80004072:	d54080e7          	jalr	-684(ra) # 80002dc2 <sigprocmask>
    80004076:	1502                	slli	a0,a0,0x20
    80004078:	9101                	srli	a0,a0,0x20
}
    8000407a:	60e2                	ld	ra,24(sp)
    8000407c:	6442                	ld	s0,16(sp)
    8000407e:	6105                	addi	sp,sp,32
    80004080:	8082                	ret

0000000080004082 <sys_sigaction>:

uint64
sys_sigaction(void)
{
    80004082:	7179                	addi	sp,sp,-48
    80004084:	f406                	sd	ra,40(sp)
    80004086:	f022                	sd	s0,32(sp)
    80004088:	1800                	addi	s0,sp,48
  int signum;
  uint64 newact;
  uint64 oldact;
  
  if(argint(0, &signum) < 0)
    8000408a:	fec40593          	addi	a1,s0,-20
    8000408e:	4501                	li	a0,0
    80004090:	00000097          	auipc	ra,0x0
    80004094:	c9e080e7          	jalr	-866(ra) # 80003d2e <argint>
    return -1;
    80004098:	57fd                	li	a5,-1
  if(argint(0, &signum) < 0)
    8000409a:	04054163          	bltz	a0,800040dc <sys_sigaction+0x5a>
  if(argaddr(1, &newact) < 0)
    8000409e:	fe040593          	addi	a1,s0,-32
    800040a2:	4505                	li	a0,1
    800040a4:	00000097          	auipc	ra,0x0
    800040a8:	cac080e7          	jalr	-852(ra) # 80003d50 <argaddr>
    return -1;
    800040ac:	57fd                	li	a5,-1
  if(argaddr(1, &newact) < 0)
    800040ae:	02054763          	bltz	a0,800040dc <sys_sigaction+0x5a>
  if(argaddr(2, &oldact) < 0)
    800040b2:	fd840593          	addi	a1,s0,-40
    800040b6:	4509                	li	a0,2
    800040b8:	00000097          	auipc	ra,0x0
    800040bc:	c98080e7          	jalr	-872(ra) # 80003d50 <argaddr>
    return -1;
    800040c0:	57fd                	li	a5,-1
  if(argaddr(2, &oldact) < 0)
    800040c2:	00054d63          	bltz	a0,800040dc <sys_sigaction+0x5a>

  return sigaction(signum,(struct sigaction*)newact, (struct sigaction*)oldact);
    800040c6:	fd843603          	ld	a2,-40(s0)
    800040ca:	fe043583          	ld	a1,-32(s0)
    800040ce:	fec42503          	lw	a0,-20(s0)
    800040d2:	fffff097          	auipc	ra,0xfffff
    800040d6:	d44080e7          	jalr	-700(ra) # 80002e16 <sigaction>
    800040da:	87aa                	mv	a5,a0
  
}
    800040dc:	853e                	mv	a0,a5
    800040de:	70a2                	ld	ra,40(sp)
    800040e0:	7402                	ld	s0,32(sp)
    800040e2:	6145                	addi	sp,sp,48
    800040e4:	8082                	ret

00000000800040e6 <sys_sigret>:
uint64
sys_sigret(void)
{
    800040e6:	1141                	addi	sp,sp,-16
    800040e8:	e406                	sd	ra,8(sp)
    800040ea:	e022                	sd	s0,0(sp)
    800040ec:	0800                	addi	s0,sp,16
  sigret();
    800040ee:	fffff097          	auipc	ra,0xfffff
    800040f2:	e12080e7          	jalr	-494(ra) # 80002f00 <sigret>
  return 0;
}
    800040f6:	4501                	li	a0,0
    800040f8:	60a2                	ld	ra,8(sp)
    800040fa:	6402                	ld	s0,0(sp)
    800040fc:	0141                	addi	sp,sp,16
    800040fe:	8082                	ret

0000000080004100 <sys_kthread_create>:

uint64
sys_kthread_create(void)
{
    80004100:	1101                	addi	sp,sp,-32
    80004102:	ec06                	sd	ra,24(sp)
    80004104:	e822                	sd	s0,16(sp)
    80004106:	1000                	addi	s0,sp,32
  uint64 start_func;
  uint64 stack;
  if(argaddr(0, &start_func) < 0)
    80004108:	fe840593          	addi	a1,s0,-24
    8000410c:	4501                	li	a0,0
    8000410e:	00000097          	auipc	ra,0x0
    80004112:	c42080e7          	jalr	-958(ra) # 80003d50 <argaddr>
    return -1;
    80004116:	57fd                	li	a5,-1
  if(argaddr(0, &start_func) < 0)
    80004118:	02054563          	bltz	a0,80004142 <sys_kthread_create+0x42>
  if(argaddr(1, &stack) < 0) 
    8000411c:	fe040593          	addi	a1,s0,-32
    80004120:	4505                	li	a0,1
    80004122:	00000097          	auipc	ra,0x0
    80004126:	c2e080e7          	jalr	-978(ra) # 80003d50 <argaddr>
    return -1;
    8000412a:	57fd                	li	a5,-1
  if(argaddr(1, &stack) < 0) 
    8000412c:	00054b63          	bltz	a0,80004142 <sys_kthread_create+0x42>
  return kthread_create((void*)start_func, (void *)stack);
    80004130:	fe043583          	ld	a1,-32(s0)
    80004134:	fe843503          	ld	a0,-24(s0)
    80004138:	fffff097          	auipc	ra,0xfffff
    8000413c:	f8a080e7          	jalr	-118(ra) # 800030c2 <kthread_create>
    80004140:	87aa                	mv	a5,a0
}
    80004142:	853e                	mv	a0,a5
    80004144:	60e2                	ld	ra,24(sp)
    80004146:	6442                	ld	s0,16(sp)
    80004148:	6105                	addi	sp,sp,32
    8000414a:	8082                	ret

000000008000414c <sys_kthread_id>:

uint64
sys_kthread_id(void){
    8000414c:	1141                	addi	sp,sp,-16
    8000414e:	e406                	sd	ra,8(sp)
    80004150:	e022                	sd	s0,0(sp)
    80004152:	0800                	addi	s0,sp,16
  return mykthread()->tid;
    80004154:	ffffe097          	auipc	ra,0xffffe
    80004158:	c6a080e7          	jalr	-918(ra) # 80001dbe <mykthread>
}
    8000415c:	5908                	lw	a0,48(a0)
    8000415e:	60a2                	ld	ra,8(sp)
    80004160:	6402                	ld	s0,0(sp)
    80004162:	0141                	addi	sp,sp,16
    80004164:	8082                	ret

0000000080004166 <sys_kthread_exit>:

uint64
sys_kthread_exit(void){
    80004166:	1101                	addi	sp,sp,-32
    80004168:	ec06                	sd	ra,24(sp)
    8000416a:	e822                	sd	s0,16(sp)
    8000416c:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    8000416e:	fec40593          	addi	a1,s0,-20
    80004172:	4501                	li	a0,0
    80004174:	00000097          	auipc	ra,0x0
    80004178:	bba080e7          	jalr	-1094(ra) # 80003d2e <argint>
    return -1;
    8000417c:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    8000417e:	00054963          	bltz	a0,80004190 <sys_kthread_exit+0x2a>
  kthread_exit(n);
    80004182:	fec42503          	lw	a0,-20(s0)
    80004186:	fffff097          	auipc	ra,0xfffff
    8000418a:	938080e7          	jalr	-1736(ra) # 80002abe <kthread_exit>
  
  return 0;  // not reached
    8000418e:	4781                	li	a5,0
}
    80004190:	853e                	mv	a0,a5
    80004192:	60e2                	ld	ra,24(sp)
    80004194:	6442                	ld	s0,16(sp)
    80004196:	6105                	addi	sp,sp,32
    80004198:	8082                	ret

000000008000419a <sys_kthread_join>:

uint64 
sys_kthread_join(void){
    8000419a:	1101                	addi	sp,sp,-32
    8000419c:	ec06                	sd	ra,24(sp)
    8000419e:	e822                	sd	s0,16(sp)
    800041a0:	1000                	addi	s0,sp,32
  int thread_id;
  uint64 status;
  if(argint(0, &thread_id) < 0)
    800041a2:	fec40593          	addi	a1,s0,-20
    800041a6:	4501                	li	a0,0
    800041a8:	00000097          	auipc	ra,0x0
    800041ac:	b86080e7          	jalr	-1146(ra) # 80003d2e <argint>
    return -1;
    800041b0:	57fd                	li	a5,-1
  if(argint(0, &thread_id) < 0)
    800041b2:	02054563          	bltz	a0,800041dc <sys_kthread_join+0x42>
  if(argaddr(1, &status) < 0)
    800041b6:	fe040593          	addi	a1,s0,-32
    800041ba:	4505                	li	a0,1
    800041bc:	00000097          	auipc	ra,0x0
    800041c0:	b94080e7          	jalr	-1132(ra) # 80003d50 <argaddr>
    return -1;
    800041c4:	57fd                	li	a5,-1
  if(argaddr(1, &status) < 0)
    800041c6:	00054b63          	bltz	a0,800041dc <sys_kthread_join+0x42>
  
  return kthread_join(thread_id, (int *)status);
    800041ca:	fe043583          	ld	a1,-32(s0)
    800041ce:	fec42503          	lw	a0,-20(s0)
    800041d2:	fffff097          	auipc	ra,0xfffff
    800041d6:	ff4080e7          	jalr	-12(ra) # 800031c6 <kthread_join>
    800041da:	87aa                	mv	a5,a0
}
    800041dc:	853e                	mv	a0,a5
    800041de:	60e2                	ld	ra,24(sp)
    800041e0:	6442                	ld	s0,16(sp)
    800041e2:	6105                	addi	sp,sp,32
    800041e4:	8082                	ret

00000000800041e6 <sys_bsem_alloc>:




uint64 
sys_bsem_alloc(void){
    800041e6:	1141                	addi	sp,sp,-16
    800041e8:	e406                	sd	ra,8(sp)
    800041ea:	e022                	sd	s0,0(sp)
    800041ec:	0800                	addi	s0,sp,16
  return bsem_alloc();
    800041ee:	ffffd097          	auipc	ra,0xffffd
    800041f2:	b38080e7          	jalr	-1224(ra) # 80000d26 <bsem_alloc>
}
    800041f6:	60a2                	ld	ra,8(sp)
    800041f8:	6402                	ld	s0,0(sp)
    800041fa:	0141                	addi	sp,sp,16
    800041fc:	8082                	ret

00000000800041fe <sys_bsem_free>:

uint64 
sys_bsem_free(void){
    800041fe:	1101                	addi	sp,sp,-32
    80004200:	ec06                	sd	ra,24(sp)
    80004202:	e822                	sd	s0,16(sp)
    80004204:	1000                	addi	s0,sp,32
  int sem;
  if(argint(0, &sem) < 0)
    80004206:	fec40593          	addi	a1,s0,-20
    8000420a:	4501                	li	a0,0
    8000420c:	00000097          	auipc	ra,0x0
    80004210:	b22080e7          	jalr	-1246(ra) # 80003d2e <argint>
    return -1;
    80004214:	57fd                	li	a5,-1
  if(argint(0, &sem) < 0)
    80004216:	00054963          	bltz	a0,80004228 <sys_bsem_free+0x2a>
  bsem_free(sem);
    8000421a:	fec42503          	lw	a0,-20(s0)
    8000421e:	ffffd097          	auipc	ra,0xffffd
    80004222:	b8e080e7          	jalr	-1138(ra) # 80000dac <bsem_free>
  return 0;
    80004226:	4781                	li	a5,0
}
    80004228:	853e                	mv	a0,a5
    8000422a:	60e2                	ld	ra,24(sp)
    8000422c:	6442                	ld	s0,16(sp)
    8000422e:	6105                	addi	sp,sp,32
    80004230:	8082                	ret

0000000080004232 <sys_bsem_down>:

uint64 
sys_bsem_down(void){
    80004232:	1101                	addi	sp,sp,-32
    80004234:	ec06                	sd	ra,24(sp)
    80004236:	e822                	sd	s0,16(sp)
    80004238:	1000                	addi	s0,sp,32
  int sem;
  if(argint(0, &sem) < 0)
    8000423a:	fec40593          	addi	a1,s0,-20
    8000423e:	4501                	li	a0,0
    80004240:	00000097          	auipc	ra,0x0
    80004244:	aee080e7          	jalr	-1298(ra) # 80003d2e <argint>
    return -1;
    80004248:	57fd                	li	a5,-1
  if(argint(0, &sem) < 0)
    8000424a:	00054963          	bltz	a0,8000425c <sys_bsem_down+0x2a>
  bsem_down(sem);
    8000424e:	fec42503          	lw	a0,-20(s0)
    80004252:	ffffd097          	auipc	ra,0xffffd
    80004256:	c0e080e7          	jalr	-1010(ra) # 80000e60 <bsem_down>
  return 0;
    8000425a:	4781                	li	a5,0
}
    8000425c:	853e                	mv	a0,a5
    8000425e:	60e2                	ld	ra,24(sp)
    80004260:	6442                	ld	s0,16(sp)
    80004262:	6105                	addi	sp,sp,32
    80004264:	8082                	ret

0000000080004266 <sys_bsem_up>:

uint64 
sys_bsem_up(void){
    80004266:	1101                	addi	sp,sp,-32
    80004268:	ec06                	sd	ra,24(sp)
    8000426a:	e822                	sd	s0,16(sp)
    8000426c:	1000                	addi	s0,sp,32
  int sem;
  if(argint(0, &sem) < 0)
    8000426e:	fec40593          	addi	a1,s0,-20
    80004272:	4501                	li	a0,0
    80004274:	00000097          	auipc	ra,0x0
    80004278:	aba080e7          	jalr	-1350(ra) # 80003d2e <argint>
    return -1;
    8000427c:	57fd                	li	a5,-1
  if(argint(0, &sem) < 0)
    8000427e:	00054963          	bltz	a0,80004290 <sys_bsem_up+0x2a>
      
  bsem_up(sem);
    80004282:	fec42503          	lw	a0,-20(s0)
    80004286:	ffffd097          	auipc	ra,0xffffd
    8000428a:	cb6080e7          	jalr	-842(ra) # 80000f3c <bsem_up>
  return 0;
    8000428e:	4781                	li	a5,0
}
    80004290:	853e                	mv	a0,a5
    80004292:	60e2                	ld	ra,24(sp)
    80004294:	6442                	ld	s0,16(sp)
    80004296:	6105                	addi	sp,sp,32
    80004298:	8082                	ret

000000008000429a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000429a:	7179                	addi	sp,sp,-48
    8000429c:	f406                	sd	ra,40(sp)
    8000429e:	f022                	sd	s0,32(sp)
    800042a0:	ec26                	sd	s1,24(sp)
    800042a2:	e84a                	sd	s2,16(sp)
    800042a4:	e44e                	sd	s3,8(sp)
    800042a6:	e052                	sd	s4,0(sp)
    800042a8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800042aa:	00005597          	auipc	a1,0x5
    800042ae:	48658593          	addi	a1,a1,1158 # 80009730 <syscalls+0x108>
    800042b2:	00031517          	auipc	a0,0x31
    800042b6:	a8e50513          	addi	a0,a0,-1394 # 80034d40 <bcache>
    800042ba:	ffffd097          	auipc	ra,0xffffd
    800042be:	87c080e7          	jalr	-1924(ra) # 80000b36 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800042c2:	00039797          	auipc	a5,0x39
    800042c6:	a7e78793          	addi	a5,a5,-1410 # 8003cd40 <bcache+0x8000>
    800042ca:	00039717          	auipc	a4,0x39
    800042ce:	cde70713          	addi	a4,a4,-802 # 8003cfa8 <bcache+0x8268>
    800042d2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800042d6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800042da:	00031497          	auipc	s1,0x31
    800042de:	a7e48493          	addi	s1,s1,-1410 # 80034d58 <bcache+0x18>
    b->next = bcache.head.next;
    800042e2:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800042e4:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800042e6:	00005a17          	auipc	s4,0x5
    800042ea:	452a0a13          	addi	s4,s4,1106 # 80009738 <syscalls+0x110>
    b->next = bcache.head.next;
    800042ee:	2b893783          	ld	a5,696(s2)
    800042f2:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800042f4:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800042f8:	85d2                	mv	a1,s4
    800042fa:	01048513          	addi	a0,s1,16
    800042fe:	00001097          	auipc	ra,0x1
    80004302:	4c0080e7          	jalr	1216(ra) # 800057be <initsleeplock>
    bcache.head.next->prev = b;
    80004306:	2b893783          	ld	a5,696(s2)
    8000430a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000430c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80004310:	45848493          	addi	s1,s1,1112
    80004314:	fd349de3          	bne	s1,s3,800042ee <binit+0x54>
  }
}
    80004318:	70a2                	ld	ra,40(sp)
    8000431a:	7402                	ld	s0,32(sp)
    8000431c:	64e2                	ld	s1,24(sp)
    8000431e:	6942                	ld	s2,16(sp)
    80004320:	69a2                	ld	s3,8(sp)
    80004322:	6a02                	ld	s4,0(sp)
    80004324:	6145                	addi	sp,sp,48
    80004326:	8082                	ret

0000000080004328 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80004328:	7179                	addi	sp,sp,-48
    8000432a:	f406                	sd	ra,40(sp)
    8000432c:	f022                	sd	s0,32(sp)
    8000432e:	ec26                	sd	s1,24(sp)
    80004330:	e84a                	sd	s2,16(sp)
    80004332:	e44e                	sd	s3,8(sp)
    80004334:	1800                	addi	s0,sp,48
    80004336:	892a                	mv	s2,a0
    80004338:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000433a:	00031517          	auipc	a0,0x31
    8000433e:	a0650513          	addi	a0,a0,-1530 # 80034d40 <bcache>
    80004342:	ffffd097          	auipc	ra,0xffffd
    80004346:	8c6080e7          	jalr	-1850(ra) # 80000c08 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000434a:	00039497          	auipc	s1,0x39
    8000434e:	cae4b483          	ld	s1,-850(s1) # 8003cff8 <bcache+0x82b8>
    80004352:	00039797          	auipc	a5,0x39
    80004356:	c5678793          	addi	a5,a5,-938 # 8003cfa8 <bcache+0x8268>
    8000435a:	02f48f63          	beq	s1,a5,80004398 <bread+0x70>
    8000435e:	873e                	mv	a4,a5
    80004360:	a021                	j	80004368 <bread+0x40>
    80004362:	68a4                	ld	s1,80(s1)
    80004364:	02e48a63          	beq	s1,a4,80004398 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80004368:	449c                	lw	a5,8(s1)
    8000436a:	ff279ce3          	bne	a5,s2,80004362 <bread+0x3a>
    8000436e:	44dc                	lw	a5,12(s1)
    80004370:	ff3799e3          	bne	a5,s3,80004362 <bread+0x3a>
      b->refcnt++;
    80004374:	40bc                	lw	a5,64(s1)
    80004376:	2785                	addiw	a5,a5,1
    80004378:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000437a:	00031517          	auipc	a0,0x31
    8000437e:	9c650513          	addi	a0,a0,-1594 # 80034d40 <bcache>
    80004382:	ffffd097          	auipc	ra,0xffffd
    80004386:	95c080e7          	jalr	-1700(ra) # 80000cde <release>
      acquiresleep(&b->lock);
    8000438a:	01048513          	addi	a0,s1,16
    8000438e:	00001097          	auipc	ra,0x1
    80004392:	46a080e7          	jalr	1130(ra) # 800057f8 <acquiresleep>
      return b;
    80004396:	a8b9                	j	800043f4 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80004398:	00039497          	auipc	s1,0x39
    8000439c:	c584b483          	ld	s1,-936(s1) # 8003cff0 <bcache+0x82b0>
    800043a0:	00039797          	auipc	a5,0x39
    800043a4:	c0878793          	addi	a5,a5,-1016 # 8003cfa8 <bcache+0x8268>
    800043a8:	00f48863          	beq	s1,a5,800043b8 <bread+0x90>
    800043ac:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800043ae:	40bc                	lw	a5,64(s1)
    800043b0:	cf81                	beqz	a5,800043c8 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800043b2:	64a4                	ld	s1,72(s1)
    800043b4:	fee49de3          	bne	s1,a4,800043ae <bread+0x86>
  panic("bget: no buffers");
    800043b8:	00005517          	auipc	a0,0x5
    800043bc:	38850513          	addi	a0,a0,904 # 80009740 <syscalls+0x118>
    800043c0:	ffffc097          	auipc	ra,0xffffc
    800043c4:	16e080e7          	jalr	366(ra) # 8000052e <panic>
      b->dev = dev;
    800043c8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800043cc:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800043d0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800043d4:	4785                	li	a5,1
    800043d6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800043d8:	00031517          	auipc	a0,0x31
    800043dc:	96850513          	addi	a0,a0,-1688 # 80034d40 <bcache>
    800043e0:	ffffd097          	auipc	ra,0xffffd
    800043e4:	8fe080e7          	jalr	-1794(ra) # 80000cde <release>
      acquiresleep(&b->lock);
    800043e8:	01048513          	addi	a0,s1,16
    800043ec:	00001097          	auipc	ra,0x1
    800043f0:	40c080e7          	jalr	1036(ra) # 800057f8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800043f4:	409c                	lw	a5,0(s1)
    800043f6:	cb89                	beqz	a5,80004408 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800043f8:	8526                	mv	a0,s1
    800043fa:	70a2                	ld	ra,40(sp)
    800043fc:	7402                	ld	s0,32(sp)
    800043fe:	64e2                	ld	s1,24(sp)
    80004400:	6942                	ld	s2,16(sp)
    80004402:	69a2                	ld	s3,8(sp)
    80004404:	6145                	addi	sp,sp,48
    80004406:	8082                	ret
    virtio_disk_rw(b, 0);
    80004408:	4581                	li	a1,0
    8000440a:	8526                	mv	a0,s1
    8000440c:	00003097          	auipc	ra,0x3
    80004410:	fca080e7          	jalr	-54(ra) # 800073d6 <virtio_disk_rw>
    b->valid = 1;
    80004414:	4785                	li	a5,1
    80004416:	c09c                	sw	a5,0(s1)
  return b;
    80004418:	b7c5                	j	800043f8 <bread+0xd0>

000000008000441a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000441a:	1101                	addi	sp,sp,-32
    8000441c:	ec06                	sd	ra,24(sp)
    8000441e:	e822                	sd	s0,16(sp)
    80004420:	e426                	sd	s1,8(sp)
    80004422:	1000                	addi	s0,sp,32
    80004424:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80004426:	0541                	addi	a0,a0,16
    80004428:	00001097          	auipc	ra,0x1
    8000442c:	46a080e7          	jalr	1130(ra) # 80005892 <holdingsleep>
    80004430:	cd01                	beqz	a0,80004448 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80004432:	4585                	li	a1,1
    80004434:	8526                	mv	a0,s1
    80004436:	00003097          	auipc	ra,0x3
    8000443a:	fa0080e7          	jalr	-96(ra) # 800073d6 <virtio_disk_rw>
}
    8000443e:	60e2                	ld	ra,24(sp)
    80004440:	6442                	ld	s0,16(sp)
    80004442:	64a2                	ld	s1,8(sp)
    80004444:	6105                	addi	sp,sp,32
    80004446:	8082                	ret
    panic("bwrite");
    80004448:	00005517          	auipc	a0,0x5
    8000444c:	31050513          	addi	a0,a0,784 # 80009758 <syscalls+0x130>
    80004450:	ffffc097          	auipc	ra,0xffffc
    80004454:	0de080e7          	jalr	222(ra) # 8000052e <panic>

0000000080004458 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80004458:	1101                	addi	sp,sp,-32
    8000445a:	ec06                	sd	ra,24(sp)
    8000445c:	e822                	sd	s0,16(sp)
    8000445e:	e426                	sd	s1,8(sp)
    80004460:	e04a                	sd	s2,0(sp)
    80004462:	1000                	addi	s0,sp,32
    80004464:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80004466:	01050913          	addi	s2,a0,16
    8000446a:	854a                	mv	a0,s2
    8000446c:	00001097          	auipc	ra,0x1
    80004470:	426080e7          	jalr	1062(ra) # 80005892 <holdingsleep>
    80004474:	c92d                	beqz	a0,800044e6 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80004476:	854a                	mv	a0,s2
    80004478:	00001097          	auipc	ra,0x1
    8000447c:	3d6080e7          	jalr	982(ra) # 8000584e <releasesleep>

  acquire(&bcache.lock);
    80004480:	00031517          	auipc	a0,0x31
    80004484:	8c050513          	addi	a0,a0,-1856 # 80034d40 <bcache>
    80004488:	ffffc097          	auipc	ra,0xffffc
    8000448c:	780080e7          	jalr	1920(ra) # 80000c08 <acquire>
  b->refcnt--;
    80004490:	40bc                	lw	a5,64(s1)
    80004492:	37fd                	addiw	a5,a5,-1
    80004494:	0007871b          	sext.w	a4,a5
    80004498:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000449a:	eb05                	bnez	a4,800044ca <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000449c:	68bc                	ld	a5,80(s1)
    8000449e:	64b8                	ld	a4,72(s1)
    800044a0:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800044a2:	64bc                	ld	a5,72(s1)
    800044a4:	68b8                	ld	a4,80(s1)
    800044a6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800044a8:	00039797          	auipc	a5,0x39
    800044ac:	89878793          	addi	a5,a5,-1896 # 8003cd40 <bcache+0x8000>
    800044b0:	2b87b703          	ld	a4,696(a5)
    800044b4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800044b6:	00039717          	auipc	a4,0x39
    800044ba:	af270713          	addi	a4,a4,-1294 # 8003cfa8 <bcache+0x8268>
    800044be:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800044c0:	2b87b703          	ld	a4,696(a5)
    800044c4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800044c6:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800044ca:	00031517          	auipc	a0,0x31
    800044ce:	87650513          	addi	a0,a0,-1930 # 80034d40 <bcache>
    800044d2:	ffffd097          	auipc	ra,0xffffd
    800044d6:	80c080e7          	jalr	-2036(ra) # 80000cde <release>
}
    800044da:	60e2                	ld	ra,24(sp)
    800044dc:	6442                	ld	s0,16(sp)
    800044de:	64a2                	ld	s1,8(sp)
    800044e0:	6902                	ld	s2,0(sp)
    800044e2:	6105                	addi	sp,sp,32
    800044e4:	8082                	ret
    panic("brelse");
    800044e6:	00005517          	auipc	a0,0x5
    800044ea:	27a50513          	addi	a0,a0,634 # 80009760 <syscalls+0x138>
    800044ee:	ffffc097          	auipc	ra,0xffffc
    800044f2:	040080e7          	jalr	64(ra) # 8000052e <panic>

00000000800044f6 <bpin>:

void
bpin(struct buf *b) {
    800044f6:	1101                	addi	sp,sp,-32
    800044f8:	ec06                	sd	ra,24(sp)
    800044fa:	e822                	sd	s0,16(sp)
    800044fc:	e426                	sd	s1,8(sp)
    800044fe:	1000                	addi	s0,sp,32
    80004500:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004502:	00031517          	auipc	a0,0x31
    80004506:	83e50513          	addi	a0,a0,-1986 # 80034d40 <bcache>
    8000450a:	ffffc097          	auipc	ra,0xffffc
    8000450e:	6fe080e7          	jalr	1790(ra) # 80000c08 <acquire>
  b->refcnt++;
    80004512:	40bc                	lw	a5,64(s1)
    80004514:	2785                	addiw	a5,a5,1
    80004516:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004518:	00031517          	auipc	a0,0x31
    8000451c:	82850513          	addi	a0,a0,-2008 # 80034d40 <bcache>
    80004520:	ffffc097          	auipc	ra,0xffffc
    80004524:	7be080e7          	jalr	1982(ra) # 80000cde <release>
}
    80004528:	60e2                	ld	ra,24(sp)
    8000452a:	6442                	ld	s0,16(sp)
    8000452c:	64a2                	ld	s1,8(sp)
    8000452e:	6105                	addi	sp,sp,32
    80004530:	8082                	ret

0000000080004532 <bunpin>:

void
bunpin(struct buf *b) {
    80004532:	1101                	addi	sp,sp,-32
    80004534:	ec06                	sd	ra,24(sp)
    80004536:	e822                	sd	s0,16(sp)
    80004538:	e426                	sd	s1,8(sp)
    8000453a:	1000                	addi	s0,sp,32
    8000453c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000453e:	00031517          	auipc	a0,0x31
    80004542:	80250513          	addi	a0,a0,-2046 # 80034d40 <bcache>
    80004546:	ffffc097          	auipc	ra,0xffffc
    8000454a:	6c2080e7          	jalr	1730(ra) # 80000c08 <acquire>
  b->refcnt--;
    8000454e:	40bc                	lw	a5,64(s1)
    80004550:	37fd                	addiw	a5,a5,-1
    80004552:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004554:	00030517          	auipc	a0,0x30
    80004558:	7ec50513          	addi	a0,a0,2028 # 80034d40 <bcache>
    8000455c:	ffffc097          	auipc	ra,0xffffc
    80004560:	782080e7          	jalr	1922(ra) # 80000cde <release>
}
    80004564:	60e2                	ld	ra,24(sp)
    80004566:	6442                	ld	s0,16(sp)
    80004568:	64a2                	ld	s1,8(sp)
    8000456a:	6105                	addi	sp,sp,32
    8000456c:	8082                	ret

000000008000456e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000456e:	1101                	addi	sp,sp,-32
    80004570:	ec06                	sd	ra,24(sp)
    80004572:	e822                	sd	s0,16(sp)
    80004574:	e426                	sd	s1,8(sp)
    80004576:	e04a                	sd	s2,0(sp)
    80004578:	1000                	addi	s0,sp,32
    8000457a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000457c:	00d5d59b          	srliw	a1,a1,0xd
    80004580:	00039797          	auipc	a5,0x39
    80004584:	e9c7a783          	lw	a5,-356(a5) # 8003d41c <sb+0x1c>
    80004588:	9dbd                	addw	a1,a1,a5
    8000458a:	00000097          	auipc	ra,0x0
    8000458e:	d9e080e7          	jalr	-610(ra) # 80004328 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80004592:	0074f713          	andi	a4,s1,7
    80004596:	4785                	li	a5,1
    80004598:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000459c:	14ce                	slli	s1,s1,0x33
    8000459e:	90d9                	srli	s1,s1,0x36
    800045a0:	00950733          	add	a4,a0,s1
    800045a4:	05874703          	lbu	a4,88(a4)
    800045a8:	00e7f6b3          	and	a3,a5,a4
    800045ac:	c69d                	beqz	a3,800045da <bfree+0x6c>
    800045ae:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800045b0:	94aa                	add	s1,s1,a0
    800045b2:	fff7c793          	not	a5,a5
    800045b6:	8ff9                	and	a5,a5,a4
    800045b8:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800045bc:	00001097          	auipc	ra,0x1
    800045c0:	11c080e7          	jalr	284(ra) # 800056d8 <log_write>
  brelse(bp);
    800045c4:	854a                	mv	a0,s2
    800045c6:	00000097          	auipc	ra,0x0
    800045ca:	e92080e7          	jalr	-366(ra) # 80004458 <brelse>
}
    800045ce:	60e2                	ld	ra,24(sp)
    800045d0:	6442                	ld	s0,16(sp)
    800045d2:	64a2                	ld	s1,8(sp)
    800045d4:	6902                	ld	s2,0(sp)
    800045d6:	6105                	addi	sp,sp,32
    800045d8:	8082                	ret
    panic("freeing free block");
    800045da:	00005517          	auipc	a0,0x5
    800045de:	18e50513          	addi	a0,a0,398 # 80009768 <syscalls+0x140>
    800045e2:	ffffc097          	auipc	ra,0xffffc
    800045e6:	f4c080e7          	jalr	-180(ra) # 8000052e <panic>

00000000800045ea <balloc>:
{
    800045ea:	711d                	addi	sp,sp,-96
    800045ec:	ec86                	sd	ra,88(sp)
    800045ee:	e8a2                	sd	s0,80(sp)
    800045f0:	e4a6                	sd	s1,72(sp)
    800045f2:	e0ca                	sd	s2,64(sp)
    800045f4:	fc4e                	sd	s3,56(sp)
    800045f6:	f852                	sd	s4,48(sp)
    800045f8:	f456                	sd	s5,40(sp)
    800045fa:	f05a                	sd	s6,32(sp)
    800045fc:	ec5e                	sd	s7,24(sp)
    800045fe:	e862                	sd	s8,16(sp)
    80004600:	e466                	sd	s9,8(sp)
    80004602:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80004604:	00039797          	auipc	a5,0x39
    80004608:	e007a783          	lw	a5,-512(a5) # 8003d404 <sb+0x4>
    8000460c:	cbd1                	beqz	a5,800046a0 <balloc+0xb6>
    8000460e:	8baa                	mv	s7,a0
    80004610:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80004612:	00039b17          	auipc	s6,0x39
    80004616:	deeb0b13          	addi	s6,s6,-530 # 8003d400 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000461a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000461c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000461e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80004620:	6c89                	lui	s9,0x2
    80004622:	a831                	j	8000463e <balloc+0x54>
    brelse(bp);
    80004624:	854a                	mv	a0,s2
    80004626:	00000097          	auipc	ra,0x0
    8000462a:	e32080e7          	jalr	-462(ra) # 80004458 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000462e:	015c87bb          	addw	a5,s9,s5
    80004632:	00078a9b          	sext.w	s5,a5
    80004636:	004b2703          	lw	a4,4(s6)
    8000463a:	06eaf363          	bgeu	s5,a4,800046a0 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000463e:	41fad79b          	sraiw	a5,s5,0x1f
    80004642:	0137d79b          	srliw	a5,a5,0x13
    80004646:	015787bb          	addw	a5,a5,s5
    8000464a:	40d7d79b          	sraiw	a5,a5,0xd
    8000464e:	01cb2583          	lw	a1,28(s6)
    80004652:	9dbd                	addw	a1,a1,a5
    80004654:	855e                	mv	a0,s7
    80004656:	00000097          	auipc	ra,0x0
    8000465a:	cd2080e7          	jalr	-814(ra) # 80004328 <bread>
    8000465e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004660:	004b2503          	lw	a0,4(s6)
    80004664:	000a849b          	sext.w	s1,s5
    80004668:	8662                	mv	a2,s8
    8000466a:	faa4fde3          	bgeu	s1,a0,80004624 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000466e:	41f6579b          	sraiw	a5,a2,0x1f
    80004672:	01d7d69b          	srliw	a3,a5,0x1d
    80004676:	00c6873b          	addw	a4,a3,a2
    8000467a:	00777793          	andi	a5,a4,7
    8000467e:	9f95                	subw	a5,a5,a3
    80004680:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80004684:	4037571b          	sraiw	a4,a4,0x3
    80004688:	00e906b3          	add	a3,s2,a4
    8000468c:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    80004690:	00d7f5b3          	and	a1,a5,a3
    80004694:	cd91                	beqz	a1,800046b0 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004696:	2605                	addiw	a2,a2,1
    80004698:	2485                	addiw	s1,s1,1
    8000469a:	fd4618e3          	bne	a2,s4,8000466a <balloc+0x80>
    8000469e:	b759                	j	80004624 <balloc+0x3a>
  panic("balloc: out of blocks");
    800046a0:	00005517          	auipc	a0,0x5
    800046a4:	0e050513          	addi	a0,a0,224 # 80009780 <syscalls+0x158>
    800046a8:	ffffc097          	auipc	ra,0xffffc
    800046ac:	e86080e7          	jalr	-378(ra) # 8000052e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800046b0:	974a                	add	a4,a4,s2
    800046b2:	8fd5                	or	a5,a5,a3
    800046b4:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800046b8:	854a                	mv	a0,s2
    800046ba:	00001097          	auipc	ra,0x1
    800046be:	01e080e7          	jalr	30(ra) # 800056d8 <log_write>
        brelse(bp);
    800046c2:	854a                	mv	a0,s2
    800046c4:	00000097          	auipc	ra,0x0
    800046c8:	d94080e7          	jalr	-620(ra) # 80004458 <brelse>
  bp = bread(dev, bno);
    800046cc:	85a6                	mv	a1,s1
    800046ce:	855e                	mv	a0,s7
    800046d0:	00000097          	auipc	ra,0x0
    800046d4:	c58080e7          	jalr	-936(ra) # 80004328 <bread>
    800046d8:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800046da:	40000613          	li	a2,1024
    800046de:	4581                	li	a1,0
    800046e0:	05850513          	addi	a0,a0,88
    800046e4:	ffffd097          	auipc	ra,0xffffd
    800046e8:	8fa080e7          	jalr	-1798(ra) # 80000fde <memset>
  log_write(bp);
    800046ec:	854a                	mv	a0,s2
    800046ee:	00001097          	auipc	ra,0x1
    800046f2:	fea080e7          	jalr	-22(ra) # 800056d8 <log_write>
  brelse(bp);
    800046f6:	854a                	mv	a0,s2
    800046f8:	00000097          	auipc	ra,0x0
    800046fc:	d60080e7          	jalr	-672(ra) # 80004458 <brelse>
}
    80004700:	8526                	mv	a0,s1
    80004702:	60e6                	ld	ra,88(sp)
    80004704:	6446                	ld	s0,80(sp)
    80004706:	64a6                	ld	s1,72(sp)
    80004708:	6906                	ld	s2,64(sp)
    8000470a:	79e2                	ld	s3,56(sp)
    8000470c:	7a42                	ld	s4,48(sp)
    8000470e:	7aa2                	ld	s5,40(sp)
    80004710:	7b02                	ld	s6,32(sp)
    80004712:	6be2                	ld	s7,24(sp)
    80004714:	6c42                	ld	s8,16(sp)
    80004716:	6ca2                	ld	s9,8(sp)
    80004718:	6125                	addi	sp,sp,96
    8000471a:	8082                	ret

000000008000471c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000471c:	7179                	addi	sp,sp,-48
    8000471e:	f406                	sd	ra,40(sp)
    80004720:	f022                	sd	s0,32(sp)
    80004722:	ec26                	sd	s1,24(sp)
    80004724:	e84a                	sd	s2,16(sp)
    80004726:	e44e                	sd	s3,8(sp)
    80004728:	e052                	sd	s4,0(sp)
    8000472a:	1800                	addi	s0,sp,48
    8000472c:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000472e:	47ad                	li	a5,11
    80004730:	04b7fe63          	bgeu	a5,a1,8000478c <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80004734:	ff45849b          	addiw	s1,a1,-12
    80004738:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000473c:	0ff00793          	li	a5,255
    80004740:	0ae7e463          	bltu	a5,a4,800047e8 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80004744:	08052583          	lw	a1,128(a0)
    80004748:	c5b5                	beqz	a1,800047b4 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000474a:	00092503          	lw	a0,0(s2)
    8000474e:	00000097          	auipc	ra,0x0
    80004752:	bda080e7          	jalr	-1062(ra) # 80004328 <bread>
    80004756:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80004758:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000475c:	02049713          	slli	a4,s1,0x20
    80004760:	01e75593          	srli	a1,a4,0x1e
    80004764:	00b784b3          	add	s1,a5,a1
    80004768:	0004a983          	lw	s3,0(s1)
    8000476c:	04098e63          	beqz	s3,800047c8 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80004770:	8552                	mv	a0,s4
    80004772:	00000097          	auipc	ra,0x0
    80004776:	ce6080e7          	jalr	-794(ra) # 80004458 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000477a:	854e                	mv	a0,s3
    8000477c:	70a2                	ld	ra,40(sp)
    8000477e:	7402                	ld	s0,32(sp)
    80004780:	64e2                	ld	s1,24(sp)
    80004782:	6942                	ld	s2,16(sp)
    80004784:	69a2                	ld	s3,8(sp)
    80004786:	6a02                	ld	s4,0(sp)
    80004788:	6145                	addi	sp,sp,48
    8000478a:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000478c:	02059793          	slli	a5,a1,0x20
    80004790:	01e7d593          	srli	a1,a5,0x1e
    80004794:	00b504b3          	add	s1,a0,a1
    80004798:	0504a983          	lw	s3,80(s1)
    8000479c:	fc099fe3          	bnez	s3,8000477a <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800047a0:	4108                	lw	a0,0(a0)
    800047a2:	00000097          	auipc	ra,0x0
    800047a6:	e48080e7          	jalr	-440(ra) # 800045ea <balloc>
    800047aa:	0005099b          	sext.w	s3,a0
    800047ae:	0534a823          	sw	s3,80(s1)
    800047b2:	b7e1                	j	8000477a <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800047b4:	4108                	lw	a0,0(a0)
    800047b6:	00000097          	auipc	ra,0x0
    800047ba:	e34080e7          	jalr	-460(ra) # 800045ea <balloc>
    800047be:	0005059b          	sext.w	a1,a0
    800047c2:	08b92023          	sw	a1,128(s2)
    800047c6:	b751                	j	8000474a <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800047c8:	00092503          	lw	a0,0(s2)
    800047cc:	00000097          	auipc	ra,0x0
    800047d0:	e1e080e7          	jalr	-482(ra) # 800045ea <balloc>
    800047d4:	0005099b          	sext.w	s3,a0
    800047d8:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800047dc:	8552                	mv	a0,s4
    800047de:	00001097          	auipc	ra,0x1
    800047e2:	efa080e7          	jalr	-262(ra) # 800056d8 <log_write>
    800047e6:	b769                	j	80004770 <bmap+0x54>
  panic("bmap: out of range");
    800047e8:	00005517          	auipc	a0,0x5
    800047ec:	fb050513          	addi	a0,a0,-80 # 80009798 <syscalls+0x170>
    800047f0:	ffffc097          	auipc	ra,0xffffc
    800047f4:	d3e080e7          	jalr	-706(ra) # 8000052e <panic>

00000000800047f8 <iget>:
{
    800047f8:	7179                	addi	sp,sp,-48
    800047fa:	f406                	sd	ra,40(sp)
    800047fc:	f022                	sd	s0,32(sp)
    800047fe:	ec26                	sd	s1,24(sp)
    80004800:	e84a                	sd	s2,16(sp)
    80004802:	e44e                	sd	s3,8(sp)
    80004804:	e052                	sd	s4,0(sp)
    80004806:	1800                	addi	s0,sp,48
    80004808:	89aa                	mv	s3,a0
    8000480a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000480c:	00039517          	auipc	a0,0x39
    80004810:	c1450513          	addi	a0,a0,-1004 # 8003d420 <itable>
    80004814:	ffffc097          	auipc	ra,0xffffc
    80004818:	3f4080e7          	jalr	1012(ra) # 80000c08 <acquire>
  empty = 0;
    8000481c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000481e:	00039497          	auipc	s1,0x39
    80004822:	c1a48493          	addi	s1,s1,-998 # 8003d438 <itable+0x18>
    80004826:	0003a697          	auipc	a3,0x3a
    8000482a:	6a268693          	addi	a3,a3,1698 # 8003eec8 <log>
    8000482e:	a039                	j	8000483c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004830:	02090b63          	beqz	s2,80004866 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004834:	08848493          	addi	s1,s1,136
    80004838:	02d48a63          	beq	s1,a3,8000486c <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000483c:	449c                	lw	a5,8(s1)
    8000483e:	fef059e3          	blez	a5,80004830 <iget+0x38>
    80004842:	4098                	lw	a4,0(s1)
    80004844:	ff3716e3          	bne	a4,s3,80004830 <iget+0x38>
    80004848:	40d8                	lw	a4,4(s1)
    8000484a:	ff4713e3          	bne	a4,s4,80004830 <iget+0x38>
      ip->ref++;
    8000484e:	2785                	addiw	a5,a5,1
    80004850:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80004852:	00039517          	auipc	a0,0x39
    80004856:	bce50513          	addi	a0,a0,-1074 # 8003d420 <itable>
    8000485a:	ffffc097          	auipc	ra,0xffffc
    8000485e:	484080e7          	jalr	1156(ra) # 80000cde <release>
      return ip;
    80004862:	8926                	mv	s2,s1
    80004864:	a03d                	j	80004892 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004866:	f7f9                	bnez	a5,80004834 <iget+0x3c>
    80004868:	8926                	mv	s2,s1
    8000486a:	b7e9                	j	80004834 <iget+0x3c>
  if(empty == 0)
    8000486c:	02090c63          	beqz	s2,800048a4 <iget+0xac>
  ip->dev = dev;
    80004870:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80004874:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80004878:	4785                	li	a5,1
    8000487a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000487e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80004882:	00039517          	auipc	a0,0x39
    80004886:	b9e50513          	addi	a0,a0,-1122 # 8003d420 <itable>
    8000488a:	ffffc097          	auipc	ra,0xffffc
    8000488e:	454080e7          	jalr	1108(ra) # 80000cde <release>
}
    80004892:	854a                	mv	a0,s2
    80004894:	70a2                	ld	ra,40(sp)
    80004896:	7402                	ld	s0,32(sp)
    80004898:	64e2                	ld	s1,24(sp)
    8000489a:	6942                	ld	s2,16(sp)
    8000489c:	69a2                	ld	s3,8(sp)
    8000489e:	6a02                	ld	s4,0(sp)
    800048a0:	6145                	addi	sp,sp,48
    800048a2:	8082                	ret
    panic("iget: no inodes");
    800048a4:	00005517          	auipc	a0,0x5
    800048a8:	f0c50513          	addi	a0,a0,-244 # 800097b0 <syscalls+0x188>
    800048ac:	ffffc097          	auipc	ra,0xffffc
    800048b0:	c82080e7          	jalr	-894(ra) # 8000052e <panic>

00000000800048b4 <fsinit>:
fsinit(int dev) {
    800048b4:	7179                	addi	sp,sp,-48
    800048b6:	f406                	sd	ra,40(sp)
    800048b8:	f022                	sd	s0,32(sp)
    800048ba:	ec26                	sd	s1,24(sp)
    800048bc:	e84a                	sd	s2,16(sp)
    800048be:	e44e                	sd	s3,8(sp)
    800048c0:	1800                	addi	s0,sp,48
    800048c2:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800048c4:	4585                	li	a1,1
    800048c6:	00000097          	auipc	ra,0x0
    800048ca:	a62080e7          	jalr	-1438(ra) # 80004328 <bread>
    800048ce:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800048d0:	00039997          	auipc	s3,0x39
    800048d4:	b3098993          	addi	s3,s3,-1232 # 8003d400 <sb>
    800048d8:	02000613          	li	a2,32
    800048dc:	05850593          	addi	a1,a0,88
    800048e0:	854e                	mv	a0,s3
    800048e2:	ffffc097          	auipc	ra,0xffffc
    800048e6:	758080e7          	jalr	1880(ra) # 8000103a <memmove>
  brelse(bp);
    800048ea:	8526                	mv	a0,s1
    800048ec:	00000097          	auipc	ra,0x0
    800048f0:	b6c080e7          	jalr	-1172(ra) # 80004458 <brelse>
  if(sb.magic != FSMAGIC)
    800048f4:	0009a703          	lw	a4,0(s3)
    800048f8:	102037b7          	lui	a5,0x10203
    800048fc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80004900:	02f71263          	bne	a4,a5,80004924 <fsinit+0x70>
  initlog(dev, &sb);
    80004904:	00039597          	auipc	a1,0x39
    80004908:	afc58593          	addi	a1,a1,-1284 # 8003d400 <sb>
    8000490c:	854a                	mv	a0,s2
    8000490e:	00001097          	auipc	ra,0x1
    80004912:	b4c080e7          	jalr	-1204(ra) # 8000545a <initlog>
}
    80004916:	70a2                	ld	ra,40(sp)
    80004918:	7402                	ld	s0,32(sp)
    8000491a:	64e2                	ld	s1,24(sp)
    8000491c:	6942                	ld	s2,16(sp)
    8000491e:	69a2                	ld	s3,8(sp)
    80004920:	6145                	addi	sp,sp,48
    80004922:	8082                	ret
    panic("invalid file system");
    80004924:	00005517          	auipc	a0,0x5
    80004928:	e9c50513          	addi	a0,a0,-356 # 800097c0 <syscalls+0x198>
    8000492c:	ffffc097          	auipc	ra,0xffffc
    80004930:	c02080e7          	jalr	-1022(ra) # 8000052e <panic>

0000000080004934 <iinit>:
{
    80004934:	7179                	addi	sp,sp,-48
    80004936:	f406                	sd	ra,40(sp)
    80004938:	f022                	sd	s0,32(sp)
    8000493a:	ec26                	sd	s1,24(sp)
    8000493c:	e84a                	sd	s2,16(sp)
    8000493e:	e44e                	sd	s3,8(sp)
    80004940:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80004942:	00005597          	auipc	a1,0x5
    80004946:	e9658593          	addi	a1,a1,-362 # 800097d8 <syscalls+0x1b0>
    8000494a:	00039517          	auipc	a0,0x39
    8000494e:	ad650513          	addi	a0,a0,-1322 # 8003d420 <itable>
    80004952:	ffffc097          	auipc	ra,0xffffc
    80004956:	1e4080e7          	jalr	484(ra) # 80000b36 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000495a:	00039497          	auipc	s1,0x39
    8000495e:	aee48493          	addi	s1,s1,-1298 # 8003d448 <itable+0x28>
    80004962:	0003a997          	auipc	s3,0x3a
    80004966:	57698993          	addi	s3,s3,1398 # 8003eed8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000496a:	00005917          	auipc	s2,0x5
    8000496e:	e7690913          	addi	s2,s2,-394 # 800097e0 <syscalls+0x1b8>
    80004972:	85ca                	mv	a1,s2
    80004974:	8526                	mv	a0,s1
    80004976:	00001097          	auipc	ra,0x1
    8000497a:	e48080e7          	jalr	-440(ra) # 800057be <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000497e:	08848493          	addi	s1,s1,136
    80004982:	ff3498e3          	bne	s1,s3,80004972 <iinit+0x3e>
}
    80004986:	70a2                	ld	ra,40(sp)
    80004988:	7402                	ld	s0,32(sp)
    8000498a:	64e2                	ld	s1,24(sp)
    8000498c:	6942                	ld	s2,16(sp)
    8000498e:	69a2                	ld	s3,8(sp)
    80004990:	6145                	addi	sp,sp,48
    80004992:	8082                	ret

0000000080004994 <ialloc>:
{
    80004994:	715d                	addi	sp,sp,-80
    80004996:	e486                	sd	ra,72(sp)
    80004998:	e0a2                	sd	s0,64(sp)
    8000499a:	fc26                	sd	s1,56(sp)
    8000499c:	f84a                	sd	s2,48(sp)
    8000499e:	f44e                	sd	s3,40(sp)
    800049a0:	f052                	sd	s4,32(sp)
    800049a2:	ec56                	sd	s5,24(sp)
    800049a4:	e85a                	sd	s6,16(sp)
    800049a6:	e45e                	sd	s7,8(sp)
    800049a8:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800049aa:	00039717          	auipc	a4,0x39
    800049ae:	a6272703          	lw	a4,-1438(a4) # 8003d40c <sb+0xc>
    800049b2:	4785                	li	a5,1
    800049b4:	04e7fa63          	bgeu	a5,a4,80004a08 <ialloc+0x74>
    800049b8:	8aaa                	mv	s5,a0
    800049ba:	8bae                	mv	s7,a1
    800049bc:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800049be:	00039a17          	auipc	s4,0x39
    800049c2:	a42a0a13          	addi	s4,s4,-1470 # 8003d400 <sb>
    800049c6:	00048b1b          	sext.w	s6,s1
    800049ca:	0044d793          	srli	a5,s1,0x4
    800049ce:	018a2583          	lw	a1,24(s4)
    800049d2:	9dbd                	addw	a1,a1,a5
    800049d4:	8556                	mv	a0,s5
    800049d6:	00000097          	auipc	ra,0x0
    800049da:	952080e7          	jalr	-1710(ra) # 80004328 <bread>
    800049de:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800049e0:	05850993          	addi	s3,a0,88
    800049e4:	00f4f793          	andi	a5,s1,15
    800049e8:	079a                	slli	a5,a5,0x6
    800049ea:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800049ec:	00099783          	lh	a5,0(s3)
    800049f0:	c785                	beqz	a5,80004a18 <ialloc+0x84>
    brelse(bp);
    800049f2:	00000097          	auipc	ra,0x0
    800049f6:	a66080e7          	jalr	-1434(ra) # 80004458 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800049fa:	0485                	addi	s1,s1,1
    800049fc:	00ca2703          	lw	a4,12(s4)
    80004a00:	0004879b          	sext.w	a5,s1
    80004a04:	fce7e1e3          	bltu	a5,a4,800049c6 <ialloc+0x32>
  panic("ialloc: no inodes");
    80004a08:	00005517          	auipc	a0,0x5
    80004a0c:	de050513          	addi	a0,a0,-544 # 800097e8 <syscalls+0x1c0>
    80004a10:	ffffc097          	auipc	ra,0xffffc
    80004a14:	b1e080e7          	jalr	-1250(ra) # 8000052e <panic>
      memset(dip, 0, sizeof(*dip));
    80004a18:	04000613          	li	a2,64
    80004a1c:	4581                	li	a1,0
    80004a1e:	854e                	mv	a0,s3
    80004a20:	ffffc097          	auipc	ra,0xffffc
    80004a24:	5be080e7          	jalr	1470(ra) # 80000fde <memset>
      dip->type = type;
    80004a28:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004a2c:	854a                	mv	a0,s2
    80004a2e:	00001097          	auipc	ra,0x1
    80004a32:	caa080e7          	jalr	-854(ra) # 800056d8 <log_write>
      brelse(bp);
    80004a36:	854a                	mv	a0,s2
    80004a38:	00000097          	auipc	ra,0x0
    80004a3c:	a20080e7          	jalr	-1504(ra) # 80004458 <brelse>
      return iget(dev, inum);
    80004a40:	85da                	mv	a1,s6
    80004a42:	8556                	mv	a0,s5
    80004a44:	00000097          	auipc	ra,0x0
    80004a48:	db4080e7          	jalr	-588(ra) # 800047f8 <iget>
}
    80004a4c:	60a6                	ld	ra,72(sp)
    80004a4e:	6406                	ld	s0,64(sp)
    80004a50:	74e2                	ld	s1,56(sp)
    80004a52:	7942                	ld	s2,48(sp)
    80004a54:	79a2                	ld	s3,40(sp)
    80004a56:	7a02                	ld	s4,32(sp)
    80004a58:	6ae2                	ld	s5,24(sp)
    80004a5a:	6b42                	ld	s6,16(sp)
    80004a5c:	6ba2                	ld	s7,8(sp)
    80004a5e:	6161                	addi	sp,sp,80
    80004a60:	8082                	ret

0000000080004a62 <iupdate>:
{
    80004a62:	1101                	addi	sp,sp,-32
    80004a64:	ec06                	sd	ra,24(sp)
    80004a66:	e822                	sd	s0,16(sp)
    80004a68:	e426                	sd	s1,8(sp)
    80004a6a:	e04a                	sd	s2,0(sp)
    80004a6c:	1000                	addi	s0,sp,32
    80004a6e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004a70:	415c                	lw	a5,4(a0)
    80004a72:	0047d79b          	srliw	a5,a5,0x4
    80004a76:	00039597          	auipc	a1,0x39
    80004a7a:	9a25a583          	lw	a1,-1630(a1) # 8003d418 <sb+0x18>
    80004a7e:	9dbd                	addw	a1,a1,a5
    80004a80:	4108                	lw	a0,0(a0)
    80004a82:	00000097          	auipc	ra,0x0
    80004a86:	8a6080e7          	jalr	-1882(ra) # 80004328 <bread>
    80004a8a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004a8c:	05850793          	addi	a5,a0,88
    80004a90:	40c8                	lw	a0,4(s1)
    80004a92:	893d                	andi	a0,a0,15
    80004a94:	051a                	slli	a0,a0,0x6
    80004a96:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80004a98:	04449703          	lh	a4,68(s1)
    80004a9c:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80004aa0:	04649703          	lh	a4,70(s1)
    80004aa4:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80004aa8:	04849703          	lh	a4,72(s1)
    80004aac:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80004ab0:	04a49703          	lh	a4,74(s1)
    80004ab4:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80004ab8:	44f8                	lw	a4,76(s1)
    80004aba:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80004abc:	03400613          	li	a2,52
    80004ac0:	05048593          	addi	a1,s1,80
    80004ac4:	0531                	addi	a0,a0,12
    80004ac6:	ffffc097          	auipc	ra,0xffffc
    80004aca:	574080e7          	jalr	1396(ra) # 8000103a <memmove>
  log_write(bp);
    80004ace:	854a                	mv	a0,s2
    80004ad0:	00001097          	auipc	ra,0x1
    80004ad4:	c08080e7          	jalr	-1016(ra) # 800056d8 <log_write>
  brelse(bp);
    80004ad8:	854a                	mv	a0,s2
    80004ada:	00000097          	auipc	ra,0x0
    80004ade:	97e080e7          	jalr	-1666(ra) # 80004458 <brelse>
}
    80004ae2:	60e2                	ld	ra,24(sp)
    80004ae4:	6442                	ld	s0,16(sp)
    80004ae6:	64a2                	ld	s1,8(sp)
    80004ae8:	6902                	ld	s2,0(sp)
    80004aea:	6105                	addi	sp,sp,32
    80004aec:	8082                	ret

0000000080004aee <idup>:
{
    80004aee:	1101                	addi	sp,sp,-32
    80004af0:	ec06                	sd	ra,24(sp)
    80004af2:	e822                	sd	s0,16(sp)
    80004af4:	e426                	sd	s1,8(sp)
    80004af6:	1000                	addi	s0,sp,32
    80004af8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004afa:	00039517          	auipc	a0,0x39
    80004afe:	92650513          	addi	a0,a0,-1754 # 8003d420 <itable>
    80004b02:	ffffc097          	auipc	ra,0xffffc
    80004b06:	106080e7          	jalr	262(ra) # 80000c08 <acquire>
  ip->ref++;
    80004b0a:	449c                	lw	a5,8(s1)
    80004b0c:	2785                	addiw	a5,a5,1
    80004b0e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004b10:	00039517          	auipc	a0,0x39
    80004b14:	91050513          	addi	a0,a0,-1776 # 8003d420 <itable>
    80004b18:	ffffc097          	auipc	ra,0xffffc
    80004b1c:	1c6080e7          	jalr	454(ra) # 80000cde <release>
}
    80004b20:	8526                	mv	a0,s1
    80004b22:	60e2                	ld	ra,24(sp)
    80004b24:	6442                	ld	s0,16(sp)
    80004b26:	64a2                	ld	s1,8(sp)
    80004b28:	6105                	addi	sp,sp,32
    80004b2a:	8082                	ret

0000000080004b2c <ilock>:
{
    80004b2c:	1101                	addi	sp,sp,-32
    80004b2e:	ec06                	sd	ra,24(sp)
    80004b30:	e822                	sd	s0,16(sp)
    80004b32:	e426                	sd	s1,8(sp)
    80004b34:	e04a                	sd	s2,0(sp)
    80004b36:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004b38:	c115                	beqz	a0,80004b5c <ilock+0x30>
    80004b3a:	84aa                	mv	s1,a0
    80004b3c:	451c                	lw	a5,8(a0)
    80004b3e:	00f05f63          	blez	a5,80004b5c <ilock+0x30>
  acquiresleep(&ip->lock);
    80004b42:	0541                	addi	a0,a0,16
    80004b44:	00001097          	auipc	ra,0x1
    80004b48:	cb4080e7          	jalr	-844(ra) # 800057f8 <acquiresleep>
  if(ip->valid == 0){
    80004b4c:	40bc                	lw	a5,64(s1)
    80004b4e:	cf99                	beqz	a5,80004b6c <ilock+0x40>
}
    80004b50:	60e2                	ld	ra,24(sp)
    80004b52:	6442                	ld	s0,16(sp)
    80004b54:	64a2                	ld	s1,8(sp)
    80004b56:	6902                	ld	s2,0(sp)
    80004b58:	6105                	addi	sp,sp,32
    80004b5a:	8082                	ret
    panic("ilock");
    80004b5c:	00005517          	auipc	a0,0x5
    80004b60:	ca450513          	addi	a0,a0,-860 # 80009800 <syscalls+0x1d8>
    80004b64:	ffffc097          	auipc	ra,0xffffc
    80004b68:	9ca080e7          	jalr	-1590(ra) # 8000052e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004b6c:	40dc                	lw	a5,4(s1)
    80004b6e:	0047d79b          	srliw	a5,a5,0x4
    80004b72:	00039597          	auipc	a1,0x39
    80004b76:	8a65a583          	lw	a1,-1882(a1) # 8003d418 <sb+0x18>
    80004b7a:	9dbd                	addw	a1,a1,a5
    80004b7c:	4088                	lw	a0,0(s1)
    80004b7e:	fffff097          	auipc	ra,0xfffff
    80004b82:	7aa080e7          	jalr	1962(ra) # 80004328 <bread>
    80004b86:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80004b88:	05850593          	addi	a1,a0,88
    80004b8c:	40dc                	lw	a5,4(s1)
    80004b8e:	8bbd                	andi	a5,a5,15
    80004b90:	079a                	slli	a5,a5,0x6
    80004b92:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80004b94:	00059783          	lh	a5,0(a1)
    80004b98:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80004b9c:	00259783          	lh	a5,2(a1)
    80004ba0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80004ba4:	00459783          	lh	a5,4(a1)
    80004ba8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80004bac:	00659783          	lh	a5,6(a1)
    80004bb0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80004bb4:	459c                	lw	a5,8(a1)
    80004bb6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80004bb8:	03400613          	li	a2,52
    80004bbc:	05b1                	addi	a1,a1,12
    80004bbe:	05048513          	addi	a0,s1,80
    80004bc2:	ffffc097          	auipc	ra,0xffffc
    80004bc6:	478080e7          	jalr	1144(ra) # 8000103a <memmove>
    brelse(bp);
    80004bca:	854a                	mv	a0,s2
    80004bcc:	00000097          	auipc	ra,0x0
    80004bd0:	88c080e7          	jalr	-1908(ra) # 80004458 <brelse>
    ip->valid = 1;
    80004bd4:	4785                	li	a5,1
    80004bd6:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004bd8:	04449783          	lh	a5,68(s1)
    80004bdc:	fbb5                	bnez	a5,80004b50 <ilock+0x24>
      panic("ilock: no type");
    80004bde:	00005517          	auipc	a0,0x5
    80004be2:	c2a50513          	addi	a0,a0,-982 # 80009808 <syscalls+0x1e0>
    80004be6:	ffffc097          	auipc	ra,0xffffc
    80004bea:	948080e7          	jalr	-1720(ra) # 8000052e <panic>

0000000080004bee <iunlock>:
{
    80004bee:	1101                	addi	sp,sp,-32
    80004bf0:	ec06                	sd	ra,24(sp)
    80004bf2:	e822                	sd	s0,16(sp)
    80004bf4:	e426                	sd	s1,8(sp)
    80004bf6:	e04a                	sd	s2,0(sp)
    80004bf8:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004bfa:	c905                	beqz	a0,80004c2a <iunlock+0x3c>
    80004bfc:	84aa                	mv	s1,a0
    80004bfe:	01050913          	addi	s2,a0,16
    80004c02:	854a                	mv	a0,s2
    80004c04:	00001097          	auipc	ra,0x1
    80004c08:	c8e080e7          	jalr	-882(ra) # 80005892 <holdingsleep>
    80004c0c:	cd19                	beqz	a0,80004c2a <iunlock+0x3c>
    80004c0e:	449c                	lw	a5,8(s1)
    80004c10:	00f05d63          	blez	a5,80004c2a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80004c14:	854a                	mv	a0,s2
    80004c16:	00001097          	auipc	ra,0x1
    80004c1a:	c38080e7          	jalr	-968(ra) # 8000584e <releasesleep>
}
    80004c1e:	60e2                	ld	ra,24(sp)
    80004c20:	6442                	ld	s0,16(sp)
    80004c22:	64a2                	ld	s1,8(sp)
    80004c24:	6902                	ld	s2,0(sp)
    80004c26:	6105                	addi	sp,sp,32
    80004c28:	8082                	ret
    panic("iunlock");
    80004c2a:	00005517          	auipc	a0,0x5
    80004c2e:	bee50513          	addi	a0,a0,-1042 # 80009818 <syscalls+0x1f0>
    80004c32:	ffffc097          	auipc	ra,0xffffc
    80004c36:	8fc080e7          	jalr	-1796(ra) # 8000052e <panic>

0000000080004c3a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004c3a:	7179                	addi	sp,sp,-48
    80004c3c:	f406                	sd	ra,40(sp)
    80004c3e:	f022                	sd	s0,32(sp)
    80004c40:	ec26                	sd	s1,24(sp)
    80004c42:	e84a                	sd	s2,16(sp)
    80004c44:	e44e                	sd	s3,8(sp)
    80004c46:	e052                	sd	s4,0(sp)
    80004c48:	1800                	addi	s0,sp,48
    80004c4a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004c4c:	05050493          	addi	s1,a0,80
    80004c50:	08050913          	addi	s2,a0,128
    80004c54:	a021                	j	80004c5c <itrunc+0x22>
    80004c56:	0491                	addi	s1,s1,4
    80004c58:	01248d63          	beq	s1,s2,80004c72 <itrunc+0x38>
    if(ip->addrs[i]){
    80004c5c:	408c                	lw	a1,0(s1)
    80004c5e:	dde5                	beqz	a1,80004c56 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80004c60:	0009a503          	lw	a0,0(s3)
    80004c64:	00000097          	auipc	ra,0x0
    80004c68:	90a080e7          	jalr	-1782(ra) # 8000456e <bfree>
      ip->addrs[i] = 0;
    80004c6c:	0004a023          	sw	zero,0(s1)
    80004c70:	b7dd                	j	80004c56 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004c72:	0809a583          	lw	a1,128(s3)
    80004c76:	e185                	bnez	a1,80004c96 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80004c78:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80004c7c:	854e                	mv	a0,s3
    80004c7e:	00000097          	auipc	ra,0x0
    80004c82:	de4080e7          	jalr	-540(ra) # 80004a62 <iupdate>
}
    80004c86:	70a2                	ld	ra,40(sp)
    80004c88:	7402                	ld	s0,32(sp)
    80004c8a:	64e2                	ld	s1,24(sp)
    80004c8c:	6942                	ld	s2,16(sp)
    80004c8e:	69a2                	ld	s3,8(sp)
    80004c90:	6a02                	ld	s4,0(sp)
    80004c92:	6145                	addi	sp,sp,48
    80004c94:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004c96:	0009a503          	lw	a0,0(s3)
    80004c9a:	fffff097          	auipc	ra,0xfffff
    80004c9e:	68e080e7          	jalr	1678(ra) # 80004328 <bread>
    80004ca2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004ca4:	05850493          	addi	s1,a0,88
    80004ca8:	45850913          	addi	s2,a0,1112
    80004cac:	a021                	j	80004cb4 <itrunc+0x7a>
    80004cae:	0491                	addi	s1,s1,4
    80004cb0:	01248b63          	beq	s1,s2,80004cc6 <itrunc+0x8c>
      if(a[j])
    80004cb4:	408c                	lw	a1,0(s1)
    80004cb6:	dde5                	beqz	a1,80004cae <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80004cb8:	0009a503          	lw	a0,0(s3)
    80004cbc:	00000097          	auipc	ra,0x0
    80004cc0:	8b2080e7          	jalr	-1870(ra) # 8000456e <bfree>
    80004cc4:	b7ed                	j	80004cae <itrunc+0x74>
    brelse(bp);
    80004cc6:	8552                	mv	a0,s4
    80004cc8:	fffff097          	auipc	ra,0xfffff
    80004ccc:	790080e7          	jalr	1936(ra) # 80004458 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80004cd0:	0809a583          	lw	a1,128(s3)
    80004cd4:	0009a503          	lw	a0,0(s3)
    80004cd8:	00000097          	auipc	ra,0x0
    80004cdc:	896080e7          	jalr	-1898(ra) # 8000456e <bfree>
    ip->addrs[NDIRECT] = 0;
    80004ce0:	0809a023          	sw	zero,128(s3)
    80004ce4:	bf51                	j	80004c78 <itrunc+0x3e>

0000000080004ce6 <iput>:
{
    80004ce6:	1101                	addi	sp,sp,-32
    80004ce8:	ec06                	sd	ra,24(sp)
    80004cea:	e822                	sd	s0,16(sp)
    80004cec:	e426                	sd	s1,8(sp)
    80004cee:	e04a                	sd	s2,0(sp)
    80004cf0:	1000                	addi	s0,sp,32
    80004cf2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004cf4:	00038517          	auipc	a0,0x38
    80004cf8:	72c50513          	addi	a0,a0,1836 # 8003d420 <itable>
    80004cfc:	ffffc097          	auipc	ra,0xffffc
    80004d00:	f0c080e7          	jalr	-244(ra) # 80000c08 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004d04:	4498                	lw	a4,8(s1)
    80004d06:	4785                	li	a5,1
    80004d08:	02f70363          	beq	a4,a5,80004d2e <iput+0x48>
  ip->ref--;
    80004d0c:	449c                	lw	a5,8(s1)
    80004d0e:	37fd                	addiw	a5,a5,-1
    80004d10:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004d12:	00038517          	auipc	a0,0x38
    80004d16:	70e50513          	addi	a0,a0,1806 # 8003d420 <itable>
    80004d1a:	ffffc097          	auipc	ra,0xffffc
    80004d1e:	fc4080e7          	jalr	-60(ra) # 80000cde <release>
}
    80004d22:	60e2                	ld	ra,24(sp)
    80004d24:	6442                	ld	s0,16(sp)
    80004d26:	64a2                	ld	s1,8(sp)
    80004d28:	6902                	ld	s2,0(sp)
    80004d2a:	6105                	addi	sp,sp,32
    80004d2c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004d2e:	40bc                	lw	a5,64(s1)
    80004d30:	dff1                	beqz	a5,80004d0c <iput+0x26>
    80004d32:	04a49783          	lh	a5,74(s1)
    80004d36:	fbf9                	bnez	a5,80004d0c <iput+0x26>
    acquiresleep(&ip->lock);
    80004d38:	01048913          	addi	s2,s1,16
    80004d3c:	854a                	mv	a0,s2
    80004d3e:	00001097          	auipc	ra,0x1
    80004d42:	aba080e7          	jalr	-1350(ra) # 800057f8 <acquiresleep>
    release(&itable.lock);
    80004d46:	00038517          	auipc	a0,0x38
    80004d4a:	6da50513          	addi	a0,a0,1754 # 8003d420 <itable>
    80004d4e:	ffffc097          	auipc	ra,0xffffc
    80004d52:	f90080e7          	jalr	-112(ra) # 80000cde <release>
    itrunc(ip);
    80004d56:	8526                	mv	a0,s1
    80004d58:	00000097          	auipc	ra,0x0
    80004d5c:	ee2080e7          	jalr	-286(ra) # 80004c3a <itrunc>
    ip->type = 0;
    80004d60:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004d64:	8526                	mv	a0,s1
    80004d66:	00000097          	auipc	ra,0x0
    80004d6a:	cfc080e7          	jalr	-772(ra) # 80004a62 <iupdate>
    ip->valid = 0;
    80004d6e:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004d72:	854a                	mv	a0,s2
    80004d74:	00001097          	auipc	ra,0x1
    80004d78:	ada080e7          	jalr	-1318(ra) # 8000584e <releasesleep>
    acquire(&itable.lock);
    80004d7c:	00038517          	auipc	a0,0x38
    80004d80:	6a450513          	addi	a0,a0,1700 # 8003d420 <itable>
    80004d84:	ffffc097          	auipc	ra,0xffffc
    80004d88:	e84080e7          	jalr	-380(ra) # 80000c08 <acquire>
    80004d8c:	b741                	j	80004d0c <iput+0x26>

0000000080004d8e <iunlockput>:
{
    80004d8e:	1101                	addi	sp,sp,-32
    80004d90:	ec06                	sd	ra,24(sp)
    80004d92:	e822                	sd	s0,16(sp)
    80004d94:	e426                	sd	s1,8(sp)
    80004d96:	1000                	addi	s0,sp,32
    80004d98:	84aa                	mv	s1,a0
  iunlock(ip);
    80004d9a:	00000097          	auipc	ra,0x0
    80004d9e:	e54080e7          	jalr	-428(ra) # 80004bee <iunlock>
  iput(ip);
    80004da2:	8526                	mv	a0,s1
    80004da4:	00000097          	auipc	ra,0x0
    80004da8:	f42080e7          	jalr	-190(ra) # 80004ce6 <iput>
}
    80004dac:	60e2                	ld	ra,24(sp)
    80004dae:	6442                	ld	s0,16(sp)
    80004db0:	64a2                	ld	s1,8(sp)
    80004db2:	6105                	addi	sp,sp,32
    80004db4:	8082                	ret

0000000080004db6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80004db6:	1141                	addi	sp,sp,-16
    80004db8:	e422                	sd	s0,8(sp)
    80004dba:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80004dbc:	411c                	lw	a5,0(a0)
    80004dbe:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80004dc0:	415c                	lw	a5,4(a0)
    80004dc2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80004dc4:	04451783          	lh	a5,68(a0)
    80004dc8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004dcc:	04a51783          	lh	a5,74(a0)
    80004dd0:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004dd4:	04c56783          	lwu	a5,76(a0)
    80004dd8:	e99c                	sd	a5,16(a1)
}
    80004dda:	6422                	ld	s0,8(sp)
    80004ddc:	0141                	addi	sp,sp,16
    80004dde:	8082                	ret

0000000080004de0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004de0:	457c                	lw	a5,76(a0)
    80004de2:	0ed7e963          	bltu	a5,a3,80004ed4 <readi+0xf4>
{
    80004de6:	7159                	addi	sp,sp,-112
    80004de8:	f486                	sd	ra,104(sp)
    80004dea:	f0a2                	sd	s0,96(sp)
    80004dec:	eca6                	sd	s1,88(sp)
    80004dee:	e8ca                	sd	s2,80(sp)
    80004df0:	e4ce                	sd	s3,72(sp)
    80004df2:	e0d2                	sd	s4,64(sp)
    80004df4:	fc56                	sd	s5,56(sp)
    80004df6:	f85a                	sd	s6,48(sp)
    80004df8:	f45e                	sd	s7,40(sp)
    80004dfa:	f062                	sd	s8,32(sp)
    80004dfc:	ec66                	sd	s9,24(sp)
    80004dfe:	e86a                	sd	s10,16(sp)
    80004e00:	e46e                	sd	s11,8(sp)
    80004e02:	1880                	addi	s0,sp,112
    80004e04:	8baa                	mv	s7,a0
    80004e06:	8c2e                	mv	s8,a1
    80004e08:	8ab2                	mv	s5,a2
    80004e0a:	84b6                	mv	s1,a3
    80004e0c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004e0e:	9f35                	addw	a4,a4,a3
    return 0;
    80004e10:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004e12:	0ad76063          	bltu	a4,a3,80004eb2 <readi+0xd2>
  if(off + n > ip->size)
    80004e16:	00e7f463          	bgeu	a5,a4,80004e1e <readi+0x3e>
    n = ip->size - off;
    80004e1a:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004e1e:	0a0b0963          	beqz	s6,80004ed0 <readi+0xf0>
    80004e22:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004e24:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004e28:	5cfd                	li	s9,-1
    80004e2a:	a82d                	j	80004e64 <readi+0x84>
    80004e2c:	020a1d93          	slli	s11,s4,0x20
    80004e30:	020ddd93          	srli	s11,s11,0x20
    80004e34:	05890793          	addi	a5,s2,88
    80004e38:	86ee                	mv	a3,s11
    80004e3a:	963e                	add	a2,a2,a5
    80004e3c:	85d6                	mv	a1,s5
    80004e3e:	8562                	mv	a0,s8
    80004e40:	ffffe097          	auipc	ra,0xffffe
    80004e44:	e04080e7          	jalr	-508(ra) # 80002c44 <either_copyout>
    80004e48:	05950d63          	beq	a0,s9,80004ea2 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004e4c:	854a                	mv	a0,s2
    80004e4e:	fffff097          	auipc	ra,0xfffff
    80004e52:	60a080e7          	jalr	1546(ra) # 80004458 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004e56:	013a09bb          	addw	s3,s4,s3
    80004e5a:	009a04bb          	addw	s1,s4,s1
    80004e5e:	9aee                	add	s5,s5,s11
    80004e60:	0569f763          	bgeu	s3,s6,80004eae <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004e64:	000ba903          	lw	s2,0(s7)
    80004e68:	00a4d59b          	srliw	a1,s1,0xa
    80004e6c:	855e                	mv	a0,s7
    80004e6e:	00000097          	auipc	ra,0x0
    80004e72:	8ae080e7          	jalr	-1874(ra) # 8000471c <bmap>
    80004e76:	0005059b          	sext.w	a1,a0
    80004e7a:	854a                	mv	a0,s2
    80004e7c:	fffff097          	auipc	ra,0xfffff
    80004e80:	4ac080e7          	jalr	1196(ra) # 80004328 <bread>
    80004e84:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004e86:	3ff4f613          	andi	a2,s1,1023
    80004e8a:	40cd07bb          	subw	a5,s10,a2
    80004e8e:	413b073b          	subw	a4,s6,s3
    80004e92:	8a3e                	mv	s4,a5
    80004e94:	2781                	sext.w	a5,a5
    80004e96:	0007069b          	sext.w	a3,a4
    80004e9a:	f8f6f9e3          	bgeu	a3,a5,80004e2c <readi+0x4c>
    80004e9e:	8a3a                	mv	s4,a4
    80004ea0:	b771                	j	80004e2c <readi+0x4c>
      brelse(bp);
    80004ea2:	854a                	mv	a0,s2
    80004ea4:	fffff097          	auipc	ra,0xfffff
    80004ea8:	5b4080e7          	jalr	1460(ra) # 80004458 <brelse>
      tot = -1;
    80004eac:	59fd                	li	s3,-1
  }
  return tot;
    80004eae:	0009851b          	sext.w	a0,s3
}
    80004eb2:	70a6                	ld	ra,104(sp)
    80004eb4:	7406                	ld	s0,96(sp)
    80004eb6:	64e6                	ld	s1,88(sp)
    80004eb8:	6946                	ld	s2,80(sp)
    80004eba:	69a6                	ld	s3,72(sp)
    80004ebc:	6a06                	ld	s4,64(sp)
    80004ebe:	7ae2                	ld	s5,56(sp)
    80004ec0:	7b42                	ld	s6,48(sp)
    80004ec2:	7ba2                	ld	s7,40(sp)
    80004ec4:	7c02                	ld	s8,32(sp)
    80004ec6:	6ce2                	ld	s9,24(sp)
    80004ec8:	6d42                	ld	s10,16(sp)
    80004eca:	6da2                	ld	s11,8(sp)
    80004ecc:	6165                	addi	sp,sp,112
    80004ece:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004ed0:	89da                	mv	s3,s6
    80004ed2:	bff1                	j	80004eae <readi+0xce>
    return 0;
    80004ed4:	4501                	li	a0,0
}
    80004ed6:	8082                	ret

0000000080004ed8 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004ed8:	457c                	lw	a5,76(a0)
    80004eda:	10d7e863          	bltu	a5,a3,80004fea <writei+0x112>
{
    80004ede:	7159                	addi	sp,sp,-112
    80004ee0:	f486                	sd	ra,104(sp)
    80004ee2:	f0a2                	sd	s0,96(sp)
    80004ee4:	eca6                	sd	s1,88(sp)
    80004ee6:	e8ca                	sd	s2,80(sp)
    80004ee8:	e4ce                	sd	s3,72(sp)
    80004eea:	e0d2                	sd	s4,64(sp)
    80004eec:	fc56                	sd	s5,56(sp)
    80004eee:	f85a                	sd	s6,48(sp)
    80004ef0:	f45e                	sd	s7,40(sp)
    80004ef2:	f062                	sd	s8,32(sp)
    80004ef4:	ec66                	sd	s9,24(sp)
    80004ef6:	e86a                	sd	s10,16(sp)
    80004ef8:	e46e                	sd	s11,8(sp)
    80004efa:	1880                	addi	s0,sp,112
    80004efc:	8b2a                	mv	s6,a0
    80004efe:	8c2e                	mv	s8,a1
    80004f00:	8ab2                	mv	s5,a2
    80004f02:	8936                	mv	s2,a3
    80004f04:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004f06:	00e687bb          	addw	a5,a3,a4
    80004f0a:	0ed7e263          	bltu	a5,a3,80004fee <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004f0e:	00043737          	lui	a4,0x43
    80004f12:	0ef76063          	bltu	a4,a5,80004ff2 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004f16:	0c0b8863          	beqz	s7,80004fe6 <writei+0x10e>
    80004f1a:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004f1c:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004f20:	5cfd                	li	s9,-1
    80004f22:	a091                	j	80004f66 <writei+0x8e>
    80004f24:	02099d93          	slli	s11,s3,0x20
    80004f28:	020ddd93          	srli	s11,s11,0x20
    80004f2c:	05848793          	addi	a5,s1,88
    80004f30:	86ee                	mv	a3,s11
    80004f32:	8656                	mv	a2,s5
    80004f34:	85e2                	mv	a1,s8
    80004f36:	953e                	add	a0,a0,a5
    80004f38:	ffffe097          	auipc	ra,0xffffe
    80004f3c:	d62080e7          	jalr	-670(ra) # 80002c9a <either_copyin>
    80004f40:	07950263          	beq	a0,s9,80004fa4 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004f44:	8526                	mv	a0,s1
    80004f46:	00000097          	auipc	ra,0x0
    80004f4a:	792080e7          	jalr	1938(ra) # 800056d8 <log_write>
    brelse(bp);
    80004f4e:	8526                	mv	a0,s1
    80004f50:	fffff097          	auipc	ra,0xfffff
    80004f54:	508080e7          	jalr	1288(ra) # 80004458 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004f58:	01498a3b          	addw	s4,s3,s4
    80004f5c:	0129893b          	addw	s2,s3,s2
    80004f60:	9aee                	add	s5,s5,s11
    80004f62:	057a7663          	bgeu	s4,s7,80004fae <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004f66:	000b2483          	lw	s1,0(s6)
    80004f6a:	00a9559b          	srliw	a1,s2,0xa
    80004f6e:	855a                	mv	a0,s6
    80004f70:	fffff097          	auipc	ra,0xfffff
    80004f74:	7ac080e7          	jalr	1964(ra) # 8000471c <bmap>
    80004f78:	0005059b          	sext.w	a1,a0
    80004f7c:	8526                	mv	a0,s1
    80004f7e:	fffff097          	auipc	ra,0xfffff
    80004f82:	3aa080e7          	jalr	938(ra) # 80004328 <bread>
    80004f86:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004f88:	3ff97513          	andi	a0,s2,1023
    80004f8c:	40ad07bb          	subw	a5,s10,a0
    80004f90:	414b873b          	subw	a4,s7,s4
    80004f94:	89be                	mv	s3,a5
    80004f96:	2781                	sext.w	a5,a5
    80004f98:	0007069b          	sext.w	a3,a4
    80004f9c:	f8f6f4e3          	bgeu	a3,a5,80004f24 <writei+0x4c>
    80004fa0:	89ba                	mv	s3,a4
    80004fa2:	b749                	j	80004f24 <writei+0x4c>
      brelse(bp);
    80004fa4:	8526                	mv	a0,s1
    80004fa6:	fffff097          	auipc	ra,0xfffff
    80004faa:	4b2080e7          	jalr	1202(ra) # 80004458 <brelse>
  }

  if(off > ip->size)
    80004fae:	04cb2783          	lw	a5,76(s6)
    80004fb2:	0127f463          	bgeu	a5,s2,80004fba <writei+0xe2>
    ip->size = off;
    80004fb6:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004fba:	855a                	mv	a0,s6
    80004fbc:	00000097          	auipc	ra,0x0
    80004fc0:	aa6080e7          	jalr	-1370(ra) # 80004a62 <iupdate>

  return tot;
    80004fc4:	000a051b          	sext.w	a0,s4
}
    80004fc8:	70a6                	ld	ra,104(sp)
    80004fca:	7406                	ld	s0,96(sp)
    80004fcc:	64e6                	ld	s1,88(sp)
    80004fce:	6946                	ld	s2,80(sp)
    80004fd0:	69a6                	ld	s3,72(sp)
    80004fd2:	6a06                	ld	s4,64(sp)
    80004fd4:	7ae2                	ld	s5,56(sp)
    80004fd6:	7b42                	ld	s6,48(sp)
    80004fd8:	7ba2                	ld	s7,40(sp)
    80004fda:	7c02                	ld	s8,32(sp)
    80004fdc:	6ce2                	ld	s9,24(sp)
    80004fde:	6d42                	ld	s10,16(sp)
    80004fe0:	6da2                	ld	s11,8(sp)
    80004fe2:	6165                	addi	sp,sp,112
    80004fe4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004fe6:	8a5e                	mv	s4,s7
    80004fe8:	bfc9                	j	80004fba <writei+0xe2>
    return -1;
    80004fea:	557d                	li	a0,-1
}
    80004fec:	8082                	ret
    return -1;
    80004fee:	557d                	li	a0,-1
    80004ff0:	bfe1                	j	80004fc8 <writei+0xf0>
    return -1;
    80004ff2:	557d                	li	a0,-1
    80004ff4:	bfd1                	j	80004fc8 <writei+0xf0>

0000000080004ff6 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004ff6:	1141                	addi	sp,sp,-16
    80004ff8:	e406                	sd	ra,8(sp)
    80004ffa:	e022                	sd	s0,0(sp)
    80004ffc:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004ffe:	4639                	li	a2,14
    80005000:	ffffc097          	auipc	ra,0xffffc
    80005004:	0b6080e7          	jalr	182(ra) # 800010b6 <strncmp>
}
    80005008:	60a2                	ld	ra,8(sp)
    8000500a:	6402                	ld	s0,0(sp)
    8000500c:	0141                	addi	sp,sp,16
    8000500e:	8082                	ret

0000000080005010 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80005010:	7139                	addi	sp,sp,-64
    80005012:	fc06                	sd	ra,56(sp)
    80005014:	f822                	sd	s0,48(sp)
    80005016:	f426                	sd	s1,40(sp)
    80005018:	f04a                	sd	s2,32(sp)
    8000501a:	ec4e                	sd	s3,24(sp)
    8000501c:	e852                	sd	s4,16(sp)
    8000501e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80005020:	04451703          	lh	a4,68(a0)
    80005024:	4785                	li	a5,1
    80005026:	00f71a63          	bne	a4,a5,8000503a <dirlookup+0x2a>
    8000502a:	892a                	mv	s2,a0
    8000502c:	89ae                	mv	s3,a1
    8000502e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80005030:	457c                	lw	a5,76(a0)
    80005032:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80005034:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005036:	e79d                	bnez	a5,80005064 <dirlookup+0x54>
    80005038:	a8a5                	j	800050b0 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000503a:	00004517          	auipc	a0,0x4
    8000503e:	7e650513          	addi	a0,a0,2022 # 80009820 <syscalls+0x1f8>
    80005042:	ffffb097          	auipc	ra,0xffffb
    80005046:	4ec080e7          	jalr	1260(ra) # 8000052e <panic>
      panic("dirlookup read");
    8000504a:	00004517          	auipc	a0,0x4
    8000504e:	7ee50513          	addi	a0,a0,2030 # 80009838 <syscalls+0x210>
    80005052:	ffffb097          	auipc	ra,0xffffb
    80005056:	4dc080e7          	jalr	1244(ra) # 8000052e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000505a:	24c1                	addiw	s1,s1,16
    8000505c:	04c92783          	lw	a5,76(s2)
    80005060:	04f4f763          	bgeu	s1,a5,800050ae <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005064:	4741                	li	a4,16
    80005066:	86a6                	mv	a3,s1
    80005068:	fc040613          	addi	a2,s0,-64
    8000506c:	4581                	li	a1,0
    8000506e:	854a                	mv	a0,s2
    80005070:	00000097          	auipc	ra,0x0
    80005074:	d70080e7          	jalr	-656(ra) # 80004de0 <readi>
    80005078:	47c1                	li	a5,16
    8000507a:	fcf518e3          	bne	a0,a5,8000504a <dirlookup+0x3a>
    if(de.inum == 0)
    8000507e:	fc045783          	lhu	a5,-64(s0)
    80005082:	dfe1                	beqz	a5,8000505a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80005084:	fc240593          	addi	a1,s0,-62
    80005088:	854e                	mv	a0,s3
    8000508a:	00000097          	auipc	ra,0x0
    8000508e:	f6c080e7          	jalr	-148(ra) # 80004ff6 <namecmp>
    80005092:	f561                	bnez	a0,8000505a <dirlookup+0x4a>
      if(poff)
    80005094:	000a0463          	beqz	s4,8000509c <dirlookup+0x8c>
        *poff = off;
    80005098:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000509c:	fc045583          	lhu	a1,-64(s0)
    800050a0:	00092503          	lw	a0,0(s2)
    800050a4:	fffff097          	auipc	ra,0xfffff
    800050a8:	754080e7          	jalr	1876(ra) # 800047f8 <iget>
    800050ac:	a011                	j	800050b0 <dirlookup+0xa0>
  return 0;
    800050ae:	4501                	li	a0,0
}
    800050b0:	70e2                	ld	ra,56(sp)
    800050b2:	7442                	ld	s0,48(sp)
    800050b4:	74a2                	ld	s1,40(sp)
    800050b6:	7902                	ld	s2,32(sp)
    800050b8:	69e2                	ld	s3,24(sp)
    800050ba:	6a42                	ld	s4,16(sp)
    800050bc:	6121                	addi	sp,sp,64
    800050be:	8082                	ret

00000000800050c0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800050c0:	711d                	addi	sp,sp,-96
    800050c2:	ec86                	sd	ra,88(sp)
    800050c4:	e8a2                	sd	s0,80(sp)
    800050c6:	e4a6                	sd	s1,72(sp)
    800050c8:	e0ca                	sd	s2,64(sp)
    800050ca:	fc4e                	sd	s3,56(sp)
    800050cc:	f852                	sd	s4,48(sp)
    800050ce:	f456                	sd	s5,40(sp)
    800050d0:	f05a                	sd	s6,32(sp)
    800050d2:	ec5e                	sd	s7,24(sp)
    800050d4:	e862                	sd	s8,16(sp)
    800050d6:	e466                	sd	s9,8(sp)
    800050d8:	1080                	addi	s0,sp,96
    800050da:	84aa                	mv	s1,a0
    800050dc:	8aae                	mv	s5,a1
    800050de:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    800050e0:	00054703          	lbu	a4,0(a0)
    800050e4:	02f00793          	li	a5,47
    800050e8:	02f70263          	beq	a4,a5,8000510c <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800050ec:	ffffd097          	auipc	ra,0xffffd
    800050f0:	c92080e7          	jalr	-878(ra) # 80001d7e <myproc>
    800050f4:	6968                	ld	a0,208(a0)
    800050f6:	00000097          	auipc	ra,0x0
    800050fa:	9f8080e7          	jalr	-1544(ra) # 80004aee <idup>
    800050fe:	89aa                	mv	s3,a0
  while(*path == '/')
    80005100:	02f00913          	li	s2,47
  len = path - s;
    80005104:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80005106:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80005108:	4b85                	li	s7,1
    8000510a:	a865                	j	800051c2 <namex+0x102>
    ip = iget(ROOTDEV, ROOTINO);
    8000510c:	4585                	li	a1,1
    8000510e:	4505                	li	a0,1
    80005110:	fffff097          	auipc	ra,0xfffff
    80005114:	6e8080e7          	jalr	1768(ra) # 800047f8 <iget>
    80005118:	89aa                	mv	s3,a0
    8000511a:	b7dd                	j	80005100 <namex+0x40>
      iunlockput(ip);
    8000511c:	854e                	mv	a0,s3
    8000511e:	00000097          	auipc	ra,0x0
    80005122:	c70080e7          	jalr	-912(ra) # 80004d8e <iunlockput>
      return 0;
    80005126:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80005128:	854e                	mv	a0,s3
    8000512a:	60e6                	ld	ra,88(sp)
    8000512c:	6446                	ld	s0,80(sp)
    8000512e:	64a6                	ld	s1,72(sp)
    80005130:	6906                	ld	s2,64(sp)
    80005132:	79e2                	ld	s3,56(sp)
    80005134:	7a42                	ld	s4,48(sp)
    80005136:	7aa2                	ld	s5,40(sp)
    80005138:	7b02                	ld	s6,32(sp)
    8000513a:	6be2                	ld	s7,24(sp)
    8000513c:	6c42                	ld	s8,16(sp)
    8000513e:	6ca2                	ld	s9,8(sp)
    80005140:	6125                	addi	sp,sp,96
    80005142:	8082                	ret
      iunlock(ip);
    80005144:	854e                	mv	a0,s3
    80005146:	00000097          	auipc	ra,0x0
    8000514a:	aa8080e7          	jalr	-1368(ra) # 80004bee <iunlock>
      return ip;
    8000514e:	bfe9                	j	80005128 <namex+0x68>
      iunlockput(ip);
    80005150:	854e                	mv	a0,s3
    80005152:	00000097          	auipc	ra,0x0
    80005156:	c3c080e7          	jalr	-964(ra) # 80004d8e <iunlockput>
      return 0;
    8000515a:	89e6                	mv	s3,s9
    8000515c:	b7f1                	j	80005128 <namex+0x68>
  len = path - s;
    8000515e:	40b48633          	sub	a2,s1,a1
    80005162:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80005166:	099c5463          	bge	s8,s9,800051ee <namex+0x12e>
    memmove(name, s, DIRSIZ);
    8000516a:	4639                	li	a2,14
    8000516c:	8552                	mv	a0,s4
    8000516e:	ffffc097          	auipc	ra,0xffffc
    80005172:	ecc080e7          	jalr	-308(ra) # 8000103a <memmove>
  while(*path == '/')
    80005176:	0004c783          	lbu	a5,0(s1)
    8000517a:	01279763          	bne	a5,s2,80005188 <namex+0xc8>
    path++;
    8000517e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80005180:	0004c783          	lbu	a5,0(s1)
    80005184:	ff278de3          	beq	a5,s2,8000517e <namex+0xbe>
    ilock(ip);
    80005188:	854e                	mv	a0,s3
    8000518a:	00000097          	auipc	ra,0x0
    8000518e:	9a2080e7          	jalr	-1630(ra) # 80004b2c <ilock>
    if(ip->type != T_DIR){
    80005192:	04499783          	lh	a5,68(s3)
    80005196:	f97793e3          	bne	a5,s7,8000511c <namex+0x5c>
    if(nameiparent && *path == '\0'){
    8000519a:	000a8563          	beqz	s5,800051a4 <namex+0xe4>
    8000519e:	0004c783          	lbu	a5,0(s1)
    800051a2:	d3cd                	beqz	a5,80005144 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    800051a4:	865a                	mv	a2,s6
    800051a6:	85d2                	mv	a1,s4
    800051a8:	854e                	mv	a0,s3
    800051aa:	00000097          	auipc	ra,0x0
    800051ae:	e66080e7          	jalr	-410(ra) # 80005010 <dirlookup>
    800051b2:	8caa                	mv	s9,a0
    800051b4:	dd51                	beqz	a0,80005150 <namex+0x90>
    iunlockput(ip);
    800051b6:	854e                	mv	a0,s3
    800051b8:	00000097          	auipc	ra,0x0
    800051bc:	bd6080e7          	jalr	-1066(ra) # 80004d8e <iunlockput>
    ip = next;
    800051c0:	89e6                	mv	s3,s9
  while(*path == '/')
    800051c2:	0004c783          	lbu	a5,0(s1)
    800051c6:	05279763          	bne	a5,s2,80005214 <namex+0x154>
    path++;
    800051ca:	0485                	addi	s1,s1,1
  while(*path == '/')
    800051cc:	0004c783          	lbu	a5,0(s1)
    800051d0:	ff278de3          	beq	a5,s2,800051ca <namex+0x10a>
  if(*path == 0)
    800051d4:	c79d                	beqz	a5,80005202 <namex+0x142>
    path++;
    800051d6:	85a6                	mv	a1,s1
  len = path - s;
    800051d8:	8cda                	mv	s9,s6
    800051da:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    800051dc:	01278963          	beq	a5,s2,800051ee <namex+0x12e>
    800051e0:	dfbd                	beqz	a5,8000515e <namex+0x9e>
    path++;
    800051e2:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    800051e4:	0004c783          	lbu	a5,0(s1)
    800051e8:	ff279ce3          	bne	a5,s2,800051e0 <namex+0x120>
    800051ec:	bf8d                	j	8000515e <namex+0x9e>
    memmove(name, s, len);
    800051ee:	2601                	sext.w	a2,a2
    800051f0:	8552                	mv	a0,s4
    800051f2:	ffffc097          	auipc	ra,0xffffc
    800051f6:	e48080e7          	jalr	-440(ra) # 8000103a <memmove>
    name[len] = 0;
    800051fa:	9cd2                	add	s9,s9,s4
    800051fc:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80005200:	bf9d                	j	80005176 <namex+0xb6>
  if(nameiparent){
    80005202:	f20a83e3          	beqz	s5,80005128 <namex+0x68>
    iput(ip);
    80005206:	854e                	mv	a0,s3
    80005208:	00000097          	auipc	ra,0x0
    8000520c:	ade080e7          	jalr	-1314(ra) # 80004ce6 <iput>
    return 0;
    80005210:	4981                	li	s3,0
    80005212:	bf19                	j	80005128 <namex+0x68>
  if(*path == 0)
    80005214:	d7fd                	beqz	a5,80005202 <namex+0x142>
  while(*path != '/' && *path != 0)
    80005216:	0004c783          	lbu	a5,0(s1)
    8000521a:	85a6                	mv	a1,s1
    8000521c:	b7d1                	j	800051e0 <namex+0x120>

000000008000521e <dirlink>:
{
    8000521e:	7139                	addi	sp,sp,-64
    80005220:	fc06                	sd	ra,56(sp)
    80005222:	f822                	sd	s0,48(sp)
    80005224:	f426                	sd	s1,40(sp)
    80005226:	f04a                	sd	s2,32(sp)
    80005228:	ec4e                	sd	s3,24(sp)
    8000522a:	e852                	sd	s4,16(sp)
    8000522c:	0080                	addi	s0,sp,64
    8000522e:	892a                	mv	s2,a0
    80005230:	8a2e                	mv	s4,a1
    80005232:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80005234:	4601                	li	a2,0
    80005236:	00000097          	auipc	ra,0x0
    8000523a:	dda080e7          	jalr	-550(ra) # 80005010 <dirlookup>
    8000523e:	e93d                	bnez	a0,800052b4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005240:	04c92483          	lw	s1,76(s2)
    80005244:	c49d                	beqz	s1,80005272 <dirlink+0x54>
    80005246:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005248:	4741                	li	a4,16
    8000524a:	86a6                	mv	a3,s1
    8000524c:	fc040613          	addi	a2,s0,-64
    80005250:	4581                	li	a1,0
    80005252:	854a                	mv	a0,s2
    80005254:	00000097          	auipc	ra,0x0
    80005258:	b8c080e7          	jalr	-1140(ra) # 80004de0 <readi>
    8000525c:	47c1                	li	a5,16
    8000525e:	06f51163          	bne	a0,a5,800052c0 <dirlink+0xa2>
    if(de.inum == 0)
    80005262:	fc045783          	lhu	a5,-64(s0)
    80005266:	c791                	beqz	a5,80005272 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005268:	24c1                	addiw	s1,s1,16
    8000526a:	04c92783          	lw	a5,76(s2)
    8000526e:	fcf4ede3          	bltu	s1,a5,80005248 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80005272:	4639                	li	a2,14
    80005274:	85d2                	mv	a1,s4
    80005276:	fc240513          	addi	a0,s0,-62
    8000527a:	ffffc097          	auipc	ra,0xffffc
    8000527e:	e78080e7          	jalr	-392(ra) # 800010f2 <strncpy>
  de.inum = inum;
    80005282:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005286:	4741                	li	a4,16
    80005288:	86a6                	mv	a3,s1
    8000528a:	fc040613          	addi	a2,s0,-64
    8000528e:	4581                	li	a1,0
    80005290:	854a                	mv	a0,s2
    80005292:	00000097          	auipc	ra,0x0
    80005296:	c46080e7          	jalr	-954(ra) # 80004ed8 <writei>
    8000529a:	872a                	mv	a4,a0
    8000529c:	47c1                	li	a5,16
  return 0;
    8000529e:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800052a0:	02f71863          	bne	a4,a5,800052d0 <dirlink+0xb2>
}
    800052a4:	70e2                	ld	ra,56(sp)
    800052a6:	7442                	ld	s0,48(sp)
    800052a8:	74a2                	ld	s1,40(sp)
    800052aa:	7902                	ld	s2,32(sp)
    800052ac:	69e2                	ld	s3,24(sp)
    800052ae:	6a42                	ld	s4,16(sp)
    800052b0:	6121                	addi	sp,sp,64
    800052b2:	8082                	ret
    iput(ip);
    800052b4:	00000097          	auipc	ra,0x0
    800052b8:	a32080e7          	jalr	-1486(ra) # 80004ce6 <iput>
    return -1;
    800052bc:	557d                	li	a0,-1
    800052be:	b7dd                	j	800052a4 <dirlink+0x86>
      panic("dirlink read");
    800052c0:	00004517          	auipc	a0,0x4
    800052c4:	58850513          	addi	a0,a0,1416 # 80009848 <syscalls+0x220>
    800052c8:	ffffb097          	auipc	ra,0xffffb
    800052cc:	266080e7          	jalr	614(ra) # 8000052e <panic>
    panic("dirlink");
    800052d0:	00004517          	auipc	a0,0x4
    800052d4:	68850513          	addi	a0,a0,1672 # 80009958 <syscalls+0x330>
    800052d8:	ffffb097          	auipc	ra,0xffffb
    800052dc:	256080e7          	jalr	598(ra) # 8000052e <panic>

00000000800052e0 <namei>:

struct inode*
namei(char *path)
{
    800052e0:	1101                	addi	sp,sp,-32
    800052e2:	ec06                	sd	ra,24(sp)
    800052e4:	e822                	sd	s0,16(sp)
    800052e6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800052e8:	fe040613          	addi	a2,s0,-32
    800052ec:	4581                	li	a1,0
    800052ee:	00000097          	auipc	ra,0x0
    800052f2:	dd2080e7          	jalr	-558(ra) # 800050c0 <namex>
}
    800052f6:	60e2                	ld	ra,24(sp)
    800052f8:	6442                	ld	s0,16(sp)
    800052fa:	6105                	addi	sp,sp,32
    800052fc:	8082                	ret

00000000800052fe <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800052fe:	1141                	addi	sp,sp,-16
    80005300:	e406                	sd	ra,8(sp)
    80005302:	e022                	sd	s0,0(sp)
    80005304:	0800                	addi	s0,sp,16
    80005306:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80005308:	4585                	li	a1,1
    8000530a:	00000097          	auipc	ra,0x0
    8000530e:	db6080e7          	jalr	-586(ra) # 800050c0 <namex>
}
    80005312:	60a2                	ld	ra,8(sp)
    80005314:	6402                	ld	s0,0(sp)
    80005316:	0141                	addi	sp,sp,16
    80005318:	8082                	ret

000000008000531a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000531a:	1101                	addi	sp,sp,-32
    8000531c:	ec06                	sd	ra,24(sp)
    8000531e:	e822                	sd	s0,16(sp)
    80005320:	e426                	sd	s1,8(sp)
    80005322:	e04a                	sd	s2,0(sp)
    80005324:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80005326:	0003a917          	auipc	s2,0x3a
    8000532a:	ba290913          	addi	s2,s2,-1118 # 8003eec8 <log>
    8000532e:	01892583          	lw	a1,24(s2)
    80005332:	02892503          	lw	a0,40(s2)
    80005336:	fffff097          	auipc	ra,0xfffff
    8000533a:	ff2080e7          	jalr	-14(ra) # 80004328 <bread>
    8000533e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80005340:	02c92683          	lw	a3,44(s2)
    80005344:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80005346:	02d05863          	blez	a3,80005376 <write_head+0x5c>
    8000534a:	0003a797          	auipc	a5,0x3a
    8000534e:	bae78793          	addi	a5,a5,-1106 # 8003eef8 <log+0x30>
    80005352:	05c50713          	addi	a4,a0,92
    80005356:	36fd                	addiw	a3,a3,-1
    80005358:	02069613          	slli	a2,a3,0x20
    8000535c:	01e65693          	srli	a3,a2,0x1e
    80005360:	0003a617          	auipc	a2,0x3a
    80005364:	b9c60613          	addi	a2,a2,-1124 # 8003eefc <log+0x34>
    80005368:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000536a:	4390                	lw	a2,0(a5)
    8000536c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000536e:	0791                	addi	a5,a5,4
    80005370:	0711                	addi	a4,a4,4
    80005372:	fed79ce3          	bne	a5,a3,8000536a <write_head+0x50>
  }
  bwrite(buf);
    80005376:	8526                	mv	a0,s1
    80005378:	fffff097          	auipc	ra,0xfffff
    8000537c:	0a2080e7          	jalr	162(ra) # 8000441a <bwrite>
  brelse(buf);
    80005380:	8526                	mv	a0,s1
    80005382:	fffff097          	auipc	ra,0xfffff
    80005386:	0d6080e7          	jalr	214(ra) # 80004458 <brelse>
}
    8000538a:	60e2                	ld	ra,24(sp)
    8000538c:	6442                	ld	s0,16(sp)
    8000538e:	64a2                	ld	s1,8(sp)
    80005390:	6902                	ld	s2,0(sp)
    80005392:	6105                	addi	sp,sp,32
    80005394:	8082                	ret

0000000080005396 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80005396:	0003a797          	auipc	a5,0x3a
    8000539a:	b5e7a783          	lw	a5,-1186(a5) # 8003eef4 <log+0x2c>
    8000539e:	0af05d63          	blez	a5,80005458 <install_trans+0xc2>
{
    800053a2:	7139                	addi	sp,sp,-64
    800053a4:	fc06                	sd	ra,56(sp)
    800053a6:	f822                	sd	s0,48(sp)
    800053a8:	f426                	sd	s1,40(sp)
    800053aa:	f04a                	sd	s2,32(sp)
    800053ac:	ec4e                	sd	s3,24(sp)
    800053ae:	e852                	sd	s4,16(sp)
    800053b0:	e456                	sd	s5,8(sp)
    800053b2:	e05a                	sd	s6,0(sp)
    800053b4:	0080                	addi	s0,sp,64
    800053b6:	8b2a                	mv	s6,a0
    800053b8:	0003aa97          	auipc	s5,0x3a
    800053bc:	b40a8a93          	addi	s5,s5,-1216 # 8003eef8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800053c0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800053c2:	0003a997          	auipc	s3,0x3a
    800053c6:	b0698993          	addi	s3,s3,-1274 # 8003eec8 <log>
    800053ca:	a00d                	j	800053ec <install_trans+0x56>
    brelse(lbuf);
    800053cc:	854a                	mv	a0,s2
    800053ce:	fffff097          	auipc	ra,0xfffff
    800053d2:	08a080e7          	jalr	138(ra) # 80004458 <brelse>
    brelse(dbuf);
    800053d6:	8526                	mv	a0,s1
    800053d8:	fffff097          	auipc	ra,0xfffff
    800053dc:	080080e7          	jalr	128(ra) # 80004458 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800053e0:	2a05                	addiw	s4,s4,1
    800053e2:	0a91                	addi	s5,s5,4
    800053e4:	02c9a783          	lw	a5,44(s3)
    800053e8:	04fa5e63          	bge	s4,a5,80005444 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800053ec:	0189a583          	lw	a1,24(s3)
    800053f0:	014585bb          	addw	a1,a1,s4
    800053f4:	2585                	addiw	a1,a1,1
    800053f6:	0289a503          	lw	a0,40(s3)
    800053fa:	fffff097          	auipc	ra,0xfffff
    800053fe:	f2e080e7          	jalr	-210(ra) # 80004328 <bread>
    80005402:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80005404:	000aa583          	lw	a1,0(s5)
    80005408:	0289a503          	lw	a0,40(s3)
    8000540c:	fffff097          	auipc	ra,0xfffff
    80005410:	f1c080e7          	jalr	-228(ra) # 80004328 <bread>
    80005414:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80005416:	40000613          	li	a2,1024
    8000541a:	05890593          	addi	a1,s2,88
    8000541e:	05850513          	addi	a0,a0,88
    80005422:	ffffc097          	auipc	ra,0xffffc
    80005426:	c18080e7          	jalr	-1000(ra) # 8000103a <memmove>
    bwrite(dbuf);  // write dst to disk
    8000542a:	8526                	mv	a0,s1
    8000542c:	fffff097          	auipc	ra,0xfffff
    80005430:	fee080e7          	jalr	-18(ra) # 8000441a <bwrite>
    if(recovering == 0)
    80005434:	f80b1ce3          	bnez	s6,800053cc <install_trans+0x36>
      bunpin(dbuf);
    80005438:	8526                	mv	a0,s1
    8000543a:	fffff097          	auipc	ra,0xfffff
    8000543e:	0f8080e7          	jalr	248(ra) # 80004532 <bunpin>
    80005442:	b769                	j	800053cc <install_trans+0x36>
}
    80005444:	70e2                	ld	ra,56(sp)
    80005446:	7442                	ld	s0,48(sp)
    80005448:	74a2                	ld	s1,40(sp)
    8000544a:	7902                	ld	s2,32(sp)
    8000544c:	69e2                	ld	s3,24(sp)
    8000544e:	6a42                	ld	s4,16(sp)
    80005450:	6aa2                	ld	s5,8(sp)
    80005452:	6b02                	ld	s6,0(sp)
    80005454:	6121                	addi	sp,sp,64
    80005456:	8082                	ret
    80005458:	8082                	ret

000000008000545a <initlog>:
{
    8000545a:	7179                	addi	sp,sp,-48
    8000545c:	f406                	sd	ra,40(sp)
    8000545e:	f022                	sd	s0,32(sp)
    80005460:	ec26                	sd	s1,24(sp)
    80005462:	e84a                	sd	s2,16(sp)
    80005464:	e44e                	sd	s3,8(sp)
    80005466:	1800                	addi	s0,sp,48
    80005468:	892a                	mv	s2,a0
    8000546a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000546c:	0003a497          	auipc	s1,0x3a
    80005470:	a5c48493          	addi	s1,s1,-1444 # 8003eec8 <log>
    80005474:	00004597          	auipc	a1,0x4
    80005478:	3e458593          	addi	a1,a1,996 # 80009858 <syscalls+0x230>
    8000547c:	8526                	mv	a0,s1
    8000547e:	ffffb097          	auipc	ra,0xffffb
    80005482:	6b8080e7          	jalr	1720(ra) # 80000b36 <initlock>
  log.start = sb->logstart;
    80005486:	0149a583          	lw	a1,20(s3)
    8000548a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000548c:	0109a783          	lw	a5,16(s3)
    80005490:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80005492:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80005496:	854a                	mv	a0,s2
    80005498:	fffff097          	auipc	ra,0xfffff
    8000549c:	e90080e7          	jalr	-368(ra) # 80004328 <bread>
  log.lh.n = lh->n;
    800054a0:	4d34                	lw	a3,88(a0)
    800054a2:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800054a4:	02d05663          	blez	a3,800054d0 <initlog+0x76>
    800054a8:	05c50793          	addi	a5,a0,92
    800054ac:	0003a717          	auipc	a4,0x3a
    800054b0:	a4c70713          	addi	a4,a4,-1460 # 8003eef8 <log+0x30>
    800054b4:	36fd                	addiw	a3,a3,-1
    800054b6:	02069613          	slli	a2,a3,0x20
    800054ba:	01e65693          	srli	a3,a2,0x1e
    800054be:	06050613          	addi	a2,a0,96
    800054c2:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800054c4:	4390                	lw	a2,0(a5)
    800054c6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800054c8:	0791                	addi	a5,a5,4
    800054ca:	0711                	addi	a4,a4,4
    800054cc:	fed79ce3          	bne	a5,a3,800054c4 <initlog+0x6a>
  brelse(buf);
    800054d0:	fffff097          	auipc	ra,0xfffff
    800054d4:	f88080e7          	jalr	-120(ra) # 80004458 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800054d8:	4505                	li	a0,1
    800054da:	00000097          	auipc	ra,0x0
    800054de:	ebc080e7          	jalr	-324(ra) # 80005396 <install_trans>
  log.lh.n = 0;
    800054e2:	0003a797          	auipc	a5,0x3a
    800054e6:	a007a923          	sw	zero,-1518(a5) # 8003eef4 <log+0x2c>
  write_head(); // clear the log
    800054ea:	00000097          	auipc	ra,0x0
    800054ee:	e30080e7          	jalr	-464(ra) # 8000531a <write_head>
}
    800054f2:	70a2                	ld	ra,40(sp)
    800054f4:	7402                	ld	s0,32(sp)
    800054f6:	64e2                	ld	s1,24(sp)
    800054f8:	6942                	ld	s2,16(sp)
    800054fa:	69a2                	ld	s3,8(sp)
    800054fc:	6145                	addi	sp,sp,48
    800054fe:	8082                	ret

0000000080005500 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80005500:	1101                	addi	sp,sp,-32
    80005502:	ec06                	sd	ra,24(sp)
    80005504:	e822                	sd	s0,16(sp)
    80005506:	e426                	sd	s1,8(sp)
    80005508:	e04a                	sd	s2,0(sp)
    8000550a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000550c:	0003a517          	auipc	a0,0x3a
    80005510:	9bc50513          	addi	a0,a0,-1604 # 8003eec8 <log>
    80005514:	ffffb097          	auipc	ra,0xffffb
    80005518:	6f4080e7          	jalr	1780(ra) # 80000c08 <acquire>
  while(1){
    if(log.committing){
    8000551c:	0003a497          	auipc	s1,0x3a
    80005520:	9ac48493          	addi	s1,s1,-1620 # 8003eec8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80005524:	4979                	li	s2,30
    80005526:	a039                	j	80005534 <begin_op+0x34>
      sleep(&log, &log.lock);
    80005528:	85a6                	mv	a1,s1
    8000552a:	8526                	mv	a0,s1
    8000552c:	ffffd097          	auipc	ra,0xffffd
    80005530:	1c8080e7          	jalr	456(ra) # 800026f4 <sleep>
    if(log.committing){
    80005534:	50dc                	lw	a5,36(s1)
    80005536:	fbed                	bnez	a5,80005528 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80005538:	509c                	lw	a5,32(s1)
    8000553a:	0017871b          	addiw	a4,a5,1
    8000553e:	0007069b          	sext.w	a3,a4
    80005542:	0027179b          	slliw	a5,a4,0x2
    80005546:	9fb9                	addw	a5,a5,a4
    80005548:	0017979b          	slliw	a5,a5,0x1
    8000554c:	54d8                	lw	a4,44(s1)
    8000554e:	9fb9                	addw	a5,a5,a4
    80005550:	00f95963          	bge	s2,a5,80005562 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80005554:	85a6                	mv	a1,s1
    80005556:	8526                	mv	a0,s1
    80005558:	ffffd097          	auipc	ra,0xffffd
    8000555c:	19c080e7          	jalr	412(ra) # 800026f4 <sleep>
    80005560:	bfd1                	j	80005534 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80005562:	0003a517          	auipc	a0,0x3a
    80005566:	96650513          	addi	a0,a0,-1690 # 8003eec8 <log>
    8000556a:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000556c:	ffffb097          	auipc	ra,0xffffb
    80005570:	772080e7          	jalr	1906(ra) # 80000cde <release>
      break;
    }
  }
}
    80005574:	60e2                	ld	ra,24(sp)
    80005576:	6442                	ld	s0,16(sp)
    80005578:	64a2                	ld	s1,8(sp)
    8000557a:	6902                	ld	s2,0(sp)
    8000557c:	6105                	addi	sp,sp,32
    8000557e:	8082                	ret

0000000080005580 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80005580:	7139                	addi	sp,sp,-64
    80005582:	fc06                	sd	ra,56(sp)
    80005584:	f822                	sd	s0,48(sp)
    80005586:	f426                	sd	s1,40(sp)
    80005588:	f04a                	sd	s2,32(sp)
    8000558a:	ec4e                	sd	s3,24(sp)
    8000558c:	e852                	sd	s4,16(sp)
    8000558e:	e456                	sd	s5,8(sp)
    80005590:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80005592:	0003a497          	auipc	s1,0x3a
    80005596:	93648493          	addi	s1,s1,-1738 # 8003eec8 <log>
    8000559a:	8526                	mv	a0,s1
    8000559c:	ffffb097          	auipc	ra,0xffffb
    800055a0:	66c080e7          	jalr	1644(ra) # 80000c08 <acquire>
  log.outstanding -= 1;
    800055a4:	509c                	lw	a5,32(s1)
    800055a6:	37fd                	addiw	a5,a5,-1
    800055a8:	0007891b          	sext.w	s2,a5
    800055ac:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800055ae:	50dc                	lw	a5,36(s1)
    800055b0:	e7b9                	bnez	a5,800055fe <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800055b2:	04091e63          	bnez	s2,8000560e <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800055b6:	0003a497          	auipc	s1,0x3a
    800055ba:	91248493          	addi	s1,s1,-1774 # 8003eec8 <log>
    800055be:	4785                	li	a5,1
    800055c0:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800055c2:	8526                	mv	a0,s1
    800055c4:	ffffb097          	auipc	ra,0xffffb
    800055c8:	71a080e7          	jalr	1818(ra) # 80000cde <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800055cc:	54dc                	lw	a5,44(s1)
    800055ce:	06f04763          	bgtz	a5,8000563c <end_op+0xbc>
    acquire(&log.lock);
    800055d2:	0003a497          	auipc	s1,0x3a
    800055d6:	8f648493          	addi	s1,s1,-1802 # 8003eec8 <log>
    800055da:	8526                	mv	a0,s1
    800055dc:	ffffb097          	auipc	ra,0xffffb
    800055e0:	62c080e7          	jalr	1580(ra) # 80000c08 <acquire>
    log.committing = 0;
    800055e4:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800055e8:	8526                	mv	a0,s1
    800055ea:	ffffd097          	auipc	ra,0xffffd
    800055ee:	294080e7          	jalr	660(ra) # 8000287e <wakeup>
    release(&log.lock);
    800055f2:	8526                	mv	a0,s1
    800055f4:	ffffb097          	auipc	ra,0xffffb
    800055f8:	6ea080e7          	jalr	1770(ra) # 80000cde <release>
}
    800055fc:	a03d                	j	8000562a <end_op+0xaa>
    panic("log.committing");
    800055fe:	00004517          	auipc	a0,0x4
    80005602:	26250513          	addi	a0,a0,610 # 80009860 <syscalls+0x238>
    80005606:	ffffb097          	auipc	ra,0xffffb
    8000560a:	f28080e7          	jalr	-216(ra) # 8000052e <panic>
    wakeup(&log);
    8000560e:	0003a497          	auipc	s1,0x3a
    80005612:	8ba48493          	addi	s1,s1,-1862 # 8003eec8 <log>
    80005616:	8526                	mv	a0,s1
    80005618:	ffffd097          	auipc	ra,0xffffd
    8000561c:	266080e7          	jalr	614(ra) # 8000287e <wakeup>
  release(&log.lock);
    80005620:	8526                	mv	a0,s1
    80005622:	ffffb097          	auipc	ra,0xffffb
    80005626:	6bc080e7          	jalr	1724(ra) # 80000cde <release>
}
    8000562a:	70e2                	ld	ra,56(sp)
    8000562c:	7442                	ld	s0,48(sp)
    8000562e:	74a2                	ld	s1,40(sp)
    80005630:	7902                	ld	s2,32(sp)
    80005632:	69e2                	ld	s3,24(sp)
    80005634:	6a42                	ld	s4,16(sp)
    80005636:	6aa2                	ld	s5,8(sp)
    80005638:	6121                	addi	sp,sp,64
    8000563a:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000563c:	0003aa97          	auipc	s5,0x3a
    80005640:	8bca8a93          	addi	s5,s5,-1860 # 8003eef8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80005644:	0003aa17          	auipc	s4,0x3a
    80005648:	884a0a13          	addi	s4,s4,-1916 # 8003eec8 <log>
    8000564c:	018a2583          	lw	a1,24(s4)
    80005650:	012585bb          	addw	a1,a1,s2
    80005654:	2585                	addiw	a1,a1,1
    80005656:	028a2503          	lw	a0,40(s4)
    8000565a:	fffff097          	auipc	ra,0xfffff
    8000565e:	cce080e7          	jalr	-818(ra) # 80004328 <bread>
    80005662:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80005664:	000aa583          	lw	a1,0(s5)
    80005668:	028a2503          	lw	a0,40(s4)
    8000566c:	fffff097          	auipc	ra,0xfffff
    80005670:	cbc080e7          	jalr	-836(ra) # 80004328 <bread>
    80005674:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80005676:	40000613          	li	a2,1024
    8000567a:	05850593          	addi	a1,a0,88
    8000567e:	05848513          	addi	a0,s1,88
    80005682:	ffffc097          	auipc	ra,0xffffc
    80005686:	9b8080e7          	jalr	-1608(ra) # 8000103a <memmove>
    bwrite(to);  // write the log
    8000568a:	8526                	mv	a0,s1
    8000568c:	fffff097          	auipc	ra,0xfffff
    80005690:	d8e080e7          	jalr	-626(ra) # 8000441a <bwrite>
    brelse(from);
    80005694:	854e                	mv	a0,s3
    80005696:	fffff097          	auipc	ra,0xfffff
    8000569a:	dc2080e7          	jalr	-574(ra) # 80004458 <brelse>
    brelse(to);
    8000569e:	8526                	mv	a0,s1
    800056a0:	fffff097          	auipc	ra,0xfffff
    800056a4:	db8080e7          	jalr	-584(ra) # 80004458 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800056a8:	2905                	addiw	s2,s2,1
    800056aa:	0a91                	addi	s5,s5,4
    800056ac:	02ca2783          	lw	a5,44(s4)
    800056b0:	f8f94ee3          	blt	s2,a5,8000564c <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800056b4:	00000097          	auipc	ra,0x0
    800056b8:	c66080e7          	jalr	-922(ra) # 8000531a <write_head>
    install_trans(0); // Now install writes to home locations
    800056bc:	4501                	li	a0,0
    800056be:	00000097          	auipc	ra,0x0
    800056c2:	cd8080e7          	jalr	-808(ra) # 80005396 <install_trans>
    log.lh.n = 0;
    800056c6:	0003a797          	auipc	a5,0x3a
    800056ca:	8207a723          	sw	zero,-2002(a5) # 8003eef4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800056ce:	00000097          	auipc	ra,0x0
    800056d2:	c4c080e7          	jalr	-948(ra) # 8000531a <write_head>
    800056d6:	bdf5                	j	800055d2 <end_op+0x52>

00000000800056d8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800056d8:	1101                	addi	sp,sp,-32
    800056da:	ec06                	sd	ra,24(sp)
    800056dc:	e822                	sd	s0,16(sp)
    800056de:	e426                	sd	s1,8(sp)
    800056e0:	e04a                	sd	s2,0(sp)
    800056e2:	1000                	addi	s0,sp,32
    800056e4:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800056e6:	00039917          	auipc	s2,0x39
    800056ea:	7e290913          	addi	s2,s2,2018 # 8003eec8 <log>
    800056ee:	854a                	mv	a0,s2
    800056f0:	ffffb097          	auipc	ra,0xffffb
    800056f4:	518080e7          	jalr	1304(ra) # 80000c08 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800056f8:	02c92603          	lw	a2,44(s2)
    800056fc:	47f5                	li	a5,29
    800056fe:	06c7c563          	blt	a5,a2,80005768 <log_write+0x90>
    80005702:	00039797          	auipc	a5,0x39
    80005706:	7e27a783          	lw	a5,2018(a5) # 8003eee4 <log+0x1c>
    8000570a:	37fd                	addiw	a5,a5,-1
    8000570c:	04f65e63          	bge	a2,a5,80005768 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80005710:	00039797          	auipc	a5,0x39
    80005714:	7d87a783          	lw	a5,2008(a5) # 8003eee8 <log+0x20>
    80005718:	06f05063          	blez	a5,80005778 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000571c:	4781                	li	a5,0
    8000571e:	06c05563          	blez	a2,80005788 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80005722:	44cc                	lw	a1,12(s1)
    80005724:	00039717          	auipc	a4,0x39
    80005728:	7d470713          	addi	a4,a4,2004 # 8003eef8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000572c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000572e:	4314                	lw	a3,0(a4)
    80005730:	04b68c63          	beq	a3,a1,80005788 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80005734:	2785                	addiw	a5,a5,1
    80005736:	0711                	addi	a4,a4,4
    80005738:	fef61be3          	bne	a2,a5,8000572e <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000573c:	0621                	addi	a2,a2,8
    8000573e:	060a                	slli	a2,a2,0x2
    80005740:	00039797          	auipc	a5,0x39
    80005744:	78878793          	addi	a5,a5,1928 # 8003eec8 <log>
    80005748:	963e                	add	a2,a2,a5
    8000574a:	44dc                	lw	a5,12(s1)
    8000574c:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000574e:	8526                	mv	a0,s1
    80005750:	fffff097          	auipc	ra,0xfffff
    80005754:	da6080e7          	jalr	-602(ra) # 800044f6 <bpin>
    log.lh.n++;
    80005758:	00039717          	auipc	a4,0x39
    8000575c:	77070713          	addi	a4,a4,1904 # 8003eec8 <log>
    80005760:	575c                	lw	a5,44(a4)
    80005762:	2785                	addiw	a5,a5,1
    80005764:	d75c                	sw	a5,44(a4)
    80005766:	a835                	j	800057a2 <log_write+0xca>
    panic("too big a transaction");
    80005768:	00004517          	auipc	a0,0x4
    8000576c:	10850513          	addi	a0,a0,264 # 80009870 <syscalls+0x248>
    80005770:	ffffb097          	auipc	ra,0xffffb
    80005774:	dbe080e7          	jalr	-578(ra) # 8000052e <panic>
    panic("log_write outside of trans");
    80005778:	00004517          	auipc	a0,0x4
    8000577c:	11050513          	addi	a0,a0,272 # 80009888 <syscalls+0x260>
    80005780:	ffffb097          	auipc	ra,0xffffb
    80005784:	dae080e7          	jalr	-594(ra) # 8000052e <panic>
  log.lh.block[i] = b->blockno;
    80005788:	00878713          	addi	a4,a5,8
    8000578c:	00271693          	slli	a3,a4,0x2
    80005790:	00039717          	auipc	a4,0x39
    80005794:	73870713          	addi	a4,a4,1848 # 8003eec8 <log>
    80005798:	9736                	add	a4,a4,a3
    8000579a:	44d4                	lw	a3,12(s1)
    8000579c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000579e:	faf608e3          	beq	a2,a5,8000574e <log_write+0x76>
  }
  release(&log.lock);
    800057a2:	00039517          	auipc	a0,0x39
    800057a6:	72650513          	addi	a0,a0,1830 # 8003eec8 <log>
    800057aa:	ffffb097          	auipc	ra,0xffffb
    800057ae:	534080e7          	jalr	1332(ra) # 80000cde <release>
}
    800057b2:	60e2                	ld	ra,24(sp)
    800057b4:	6442                	ld	s0,16(sp)
    800057b6:	64a2                	ld	s1,8(sp)
    800057b8:	6902                	ld	s2,0(sp)
    800057ba:	6105                	addi	sp,sp,32
    800057bc:	8082                	ret

00000000800057be <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800057be:	1101                	addi	sp,sp,-32
    800057c0:	ec06                	sd	ra,24(sp)
    800057c2:	e822                	sd	s0,16(sp)
    800057c4:	e426                	sd	s1,8(sp)
    800057c6:	e04a                	sd	s2,0(sp)
    800057c8:	1000                	addi	s0,sp,32
    800057ca:	84aa                	mv	s1,a0
    800057cc:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800057ce:	00004597          	auipc	a1,0x4
    800057d2:	0da58593          	addi	a1,a1,218 # 800098a8 <syscalls+0x280>
    800057d6:	0521                	addi	a0,a0,8
    800057d8:	ffffb097          	auipc	ra,0xffffb
    800057dc:	35e080e7          	jalr	862(ra) # 80000b36 <initlock>
  lk->name = name;
    800057e0:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800057e4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800057e8:	0204a423          	sw	zero,40(s1)
}
    800057ec:	60e2                	ld	ra,24(sp)
    800057ee:	6442                	ld	s0,16(sp)
    800057f0:	64a2                	ld	s1,8(sp)
    800057f2:	6902                	ld	s2,0(sp)
    800057f4:	6105                	addi	sp,sp,32
    800057f6:	8082                	ret

00000000800057f8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800057f8:	1101                	addi	sp,sp,-32
    800057fa:	ec06                	sd	ra,24(sp)
    800057fc:	e822                	sd	s0,16(sp)
    800057fe:	e426                	sd	s1,8(sp)
    80005800:	e04a                	sd	s2,0(sp)
    80005802:	1000                	addi	s0,sp,32
    80005804:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005806:	00850913          	addi	s2,a0,8
    8000580a:	854a                	mv	a0,s2
    8000580c:	ffffb097          	auipc	ra,0xffffb
    80005810:	3fc080e7          	jalr	1020(ra) # 80000c08 <acquire>
  while (lk->locked) {
    80005814:	409c                	lw	a5,0(s1)
    80005816:	cb89                	beqz	a5,80005828 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80005818:	85ca                	mv	a1,s2
    8000581a:	8526                	mv	a0,s1
    8000581c:	ffffd097          	auipc	ra,0xffffd
    80005820:	ed8080e7          	jalr	-296(ra) # 800026f4 <sleep>
  while (lk->locked) {
    80005824:	409c                	lw	a5,0(s1)
    80005826:	fbed                	bnez	a5,80005818 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80005828:	4785                	li	a5,1
    8000582a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000582c:	ffffc097          	auipc	ra,0xffffc
    80005830:	552080e7          	jalr	1362(ra) # 80001d7e <myproc>
    80005834:	515c                	lw	a5,36(a0)
    80005836:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80005838:	854a                	mv	a0,s2
    8000583a:	ffffb097          	auipc	ra,0xffffb
    8000583e:	4a4080e7          	jalr	1188(ra) # 80000cde <release>
}
    80005842:	60e2                	ld	ra,24(sp)
    80005844:	6442                	ld	s0,16(sp)
    80005846:	64a2                	ld	s1,8(sp)
    80005848:	6902                	ld	s2,0(sp)
    8000584a:	6105                	addi	sp,sp,32
    8000584c:	8082                	ret

000000008000584e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000584e:	1101                	addi	sp,sp,-32
    80005850:	ec06                	sd	ra,24(sp)
    80005852:	e822                	sd	s0,16(sp)
    80005854:	e426                	sd	s1,8(sp)
    80005856:	e04a                	sd	s2,0(sp)
    80005858:	1000                	addi	s0,sp,32
    8000585a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000585c:	00850913          	addi	s2,a0,8
    80005860:	854a                	mv	a0,s2
    80005862:	ffffb097          	auipc	ra,0xffffb
    80005866:	3a6080e7          	jalr	934(ra) # 80000c08 <acquire>
  lk->locked = 0;
    8000586a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000586e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80005872:	8526                	mv	a0,s1
    80005874:	ffffd097          	auipc	ra,0xffffd
    80005878:	00a080e7          	jalr	10(ra) # 8000287e <wakeup>
  release(&lk->lk);
    8000587c:	854a                	mv	a0,s2
    8000587e:	ffffb097          	auipc	ra,0xffffb
    80005882:	460080e7          	jalr	1120(ra) # 80000cde <release>
}
    80005886:	60e2                	ld	ra,24(sp)
    80005888:	6442                	ld	s0,16(sp)
    8000588a:	64a2                	ld	s1,8(sp)
    8000588c:	6902                	ld	s2,0(sp)
    8000588e:	6105                	addi	sp,sp,32
    80005890:	8082                	ret

0000000080005892 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80005892:	7179                	addi	sp,sp,-48
    80005894:	f406                	sd	ra,40(sp)
    80005896:	f022                	sd	s0,32(sp)
    80005898:	ec26                	sd	s1,24(sp)
    8000589a:	e84a                	sd	s2,16(sp)
    8000589c:	e44e                	sd	s3,8(sp)
    8000589e:	1800                	addi	s0,sp,48
    800058a0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800058a2:	00850913          	addi	s2,a0,8
    800058a6:	854a                	mv	a0,s2
    800058a8:	ffffb097          	auipc	ra,0xffffb
    800058ac:	360080e7          	jalr	864(ra) # 80000c08 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800058b0:	409c                	lw	a5,0(s1)
    800058b2:	ef99                	bnez	a5,800058d0 <holdingsleep+0x3e>
    800058b4:	4481                	li	s1,0
  release(&lk->lk);
    800058b6:	854a                	mv	a0,s2
    800058b8:	ffffb097          	auipc	ra,0xffffb
    800058bc:	426080e7          	jalr	1062(ra) # 80000cde <release>
  return r;
}
    800058c0:	8526                	mv	a0,s1
    800058c2:	70a2                	ld	ra,40(sp)
    800058c4:	7402                	ld	s0,32(sp)
    800058c6:	64e2                	ld	s1,24(sp)
    800058c8:	6942                	ld	s2,16(sp)
    800058ca:	69a2                	ld	s3,8(sp)
    800058cc:	6145                	addi	sp,sp,48
    800058ce:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800058d0:	0284a983          	lw	s3,40(s1)
    800058d4:	ffffc097          	auipc	ra,0xffffc
    800058d8:	4aa080e7          	jalr	1194(ra) # 80001d7e <myproc>
    800058dc:	5144                	lw	s1,36(a0)
    800058de:	413484b3          	sub	s1,s1,s3
    800058e2:	0014b493          	seqz	s1,s1
    800058e6:	bfc1                	j	800058b6 <holdingsleep+0x24>

00000000800058e8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800058e8:	1141                	addi	sp,sp,-16
    800058ea:	e406                	sd	ra,8(sp)
    800058ec:	e022                	sd	s0,0(sp)
    800058ee:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800058f0:	00004597          	auipc	a1,0x4
    800058f4:	fc858593          	addi	a1,a1,-56 # 800098b8 <syscalls+0x290>
    800058f8:	00039517          	auipc	a0,0x39
    800058fc:	71850513          	addi	a0,a0,1816 # 8003f010 <ftable>
    80005900:	ffffb097          	auipc	ra,0xffffb
    80005904:	236080e7          	jalr	566(ra) # 80000b36 <initlock>
}
    80005908:	60a2                	ld	ra,8(sp)
    8000590a:	6402                	ld	s0,0(sp)
    8000590c:	0141                	addi	sp,sp,16
    8000590e:	8082                	ret

0000000080005910 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80005910:	1101                	addi	sp,sp,-32
    80005912:	ec06                	sd	ra,24(sp)
    80005914:	e822                	sd	s0,16(sp)
    80005916:	e426                	sd	s1,8(sp)
    80005918:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000591a:	00039517          	auipc	a0,0x39
    8000591e:	6f650513          	addi	a0,a0,1782 # 8003f010 <ftable>
    80005922:	ffffb097          	auipc	ra,0xffffb
    80005926:	2e6080e7          	jalr	742(ra) # 80000c08 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000592a:	00039497          	auipc	s1,0x39
    8000592e:	6fe48493          	addi	s1,s1,1790 # 8003f028 <ftable+0x18>
    80005932:	0003a717          	auipc	a4,0x3a
    80005936:	69670713          	addi	a4,a4,1686 # 8003ffc8 <ftable+0xfb8>
    if(f->ref == 0){
    8000593a:	40dc                	lw	a5,4(s1)
    8000593c:	cf99                	beqz	a5,8000595a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000593e:	02848493          	addi	s1,s1,40
    80005942:	fee49ce3          	bne	s1,a4,8000593a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005946:	00039517          	auipc	a0,0x39
    8000594a:	6ca50513          	addi	a0,a0,1738 # 8003f010 <ftable>
    8000594e:	ffffb097          	auipc	ra,0xffffb
    80005952:	390080e7          	jalr	912(ra) # 80000cde <release>
  return 0;
    80005956:	4481                	li	s1,0
    80005958:	a819                	j	8000596e <filealloc+0x5e>
      f->ref = 1;
    8000595a:	4785                	li	a5,1
    8000595c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000595e:	00039517          	auipc	a0,0x39
    80005962:	6b250513          	addi	a0,a0,1714 # 8003f010 <ftable>
    80005966:	ffffb097          	auipc	ra,0xffffb
    8000596a:	378080e7          	jalr	888(ra) # 80000cde <release>
}
    8000596e:	8526                	mv	a0,s1
    80005970:	60e2                	ld	ra,24(sp)
    80005972:	6442                	ld	s0,16(sp)
    80005974:	64a2                	ld	s1,8(sp)
    80005976:	6105                	addi	sp,sp,32
    80005978:	8082                	ret

000000008000597a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000597a:	1101                	addi	sp,sp,-32
    8000597c:	ec06                	sd	ra,24(sp)
    8000597e:	e822                	sd	s0,16(sp)
    80005980:	e426                	sd	s1,8(sp)
    80005982:	1000                	addi	s0,sp,32
    80005984:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005986:	00039517          	auipc	a0,0x39
    8000598a:	68a50513          	addi	a0,a0,1674 # 8003f010 <ftable>
    8000598e:	ffffb097          	auipc	ra,0xffffb
    80005992:	27a080e7          	jalr	634(ra) # 80000c08 <acquire>
  if(f->ref < 1)
    80005996:	40dc                	lw	a5,4(s1)
    80005998:	02f05263          	blez	a5,800059bc <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000599c:	2785                	addiw	a5,a5,1
    8000599e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800059a0:	00039517          	auipc	a0,0x39
    800059a4:	67050513          	addi	a0,a0,1648 # 8003f010 <ftable>
    800059a8:	ffffb097          	auipc	ra,0xffffb
    800059ac:	336080e7          	jalr	822(ra) # 80000cde <release>
  return f;
}
    800059b0:	8526                	mv	a0,s1
    800059b2:	60e2                	ld	ra,24(sp)
    800059b4:	6442                	ld	s0,16(sp)
    800059b6:	64a2                	ld	s1,8(sp)
    800059b8:	6105                	addi	sp,sp,32
    800059ba:	8082                	ret
    panic("filedup");
    800059bc:	00004517          	auipc	a0,0x4
    800059c0:	f0450513          	addi	a0,a0,-252 # 800098c0 <syscalls+0x298>
    800059c4:	ffffb097          	auipc	ra,0xffffb
    800059c8:	b6a080e7          	jalr	-1174(ra) # 8000052e <panic>

00000000800059cc <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800059cc:	7139                	addi	sp,sp,-64
    800059ce:	fc06                	sd	ra,56(sp)
    800059d0:	f822                	sd	s0,48(sp)
    800059d2:	f426                	sd	s1,40(sp)
    800059d4:	f04a                	sd	s2,32(sp)
    800059d6:	ec4e                	sd	s3,24(sp)
    800059d8:	e852                	sd	s4,16(sp)
    800059da:	e456                	sd	s5,8(sp)
    800059dc:	0080                	addi	s0,sp,64
    800059de:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800059e0:	00039517          	auipc	a0,0x39
    800059e4:	63050513          	addi	a0,a0,1584 # 8003f010 <ftable>
    800059e8:	ffffb097          	auipc	ra,0xffffb
    800059ec:	220080e7          	jalr	544(ra) # 80000c08 <acquire>
  if(f->ref < 1)
    800059f0:	40dc                	lw	a5,4(s1)
    800059f2:	06f05163          	blez	a5,80005a54 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800059f6:	37fd                	addiw	a5,a5,-1
    800059f8:	0007871b          	sext.w	a4,a5
    800059fc:	c0dc                	sw	a5,4(s1)
    800059fe:	06e04363          	bgtz	a4,80005a64 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80005a02:	0004a903          	lw	s2,0(s1)
    80005a06:	0094ca83          	lbu	s5,9(s1)
    80005a0a:	0104ba03          	ld	s4,16(s1)
    80005a0e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80005a12:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005a16:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005a1a:	00039517          	auipc	a0,0x39
    80005a1e:	5f650513          	addi	a0,a0,1526 # 8003f010 <ftable>
    80005a22:	ffffb097          	auipc	ra,0xffffb
    80005a26:	2bc080e7          	jalr	700(ra) # 80000cde <release>

  if(ff.type == FD_PIPE){
    80005a2a:	4785                	li	a5,1
    80005a2c:	04f90d63          	beq	s2,a5,80005a86 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80005a30:	3979                	addiw	s2,s2,-2
    80005a32:	4785                	li	a5,1
    80005a34:	0527e063          	bltu	a5,s2,80005a74 <fileclose+0xa8>
    begin_op();
    80005a38:	00000097          	auipc	ra,0x0
    80005a3c:	ac8080e7          	jalr	-1336(ra) # 80005500 <begin_op>
    iput(ff.ip);
    80005a40:	854e                	mv	a0,s3
    80005a42:	fffff097          	auipc	ra,0xfffff
    80005a46:	2a4080e7          	jalr	676(ra) # 80004ce6 <iput>
    end_op();
    80005a4a:	00000097          	auipc	ra,0x0
    80005a4e:	b36080e7          	jalr	-1226(ra) # 80005580 <end_op>
    80005a52:	a00d                	j	80005a74 <fileclose+0xa8>
    panic("fileclose");
    80005a54:	00004517          	auipc	a0,0x4
    80005a58:	e7450513          	addi	a0,a0,-396 # 800098c8 <syscalls+0x2a0>
    80005a5c:	ffffb097          	auipc	ra,0xffffb
    80005a60:	ad2080e7          	jalr	-1326(ra) # 8000052e <panic>
    release(&ftable.lock);
    80005a64:	00039517          	auipc	a0,0x39
    80005a68:	5ac50513          	addi	a0,a0,1452 # 8003f010 <ftable>
    80005a6c:	ffffb097          	auipc	ra,0xffffb
    80005a70:	272080e7          	jalr	626(ra) # 80000cde <release>
  }
}
    80005a74:	70e2                	ld	ra,56(sp)
    80005a76:	7442                	ld	s0,48(sp)
    80005a78:	74a2                	ld	s1,40(sp)
    80005a7a:	7902                	ld	s2,32(sp)
    80005a7c:	69e2                	ld	s3,24(sp)
    80005a7e:	6a42                	ld	s4,16(sp)
    80005a80:	6aa2                	ld	s5,8(sp)
    80005a82:	6121                	addi	sp,sp,64
    80005a84:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005a86:	85d6                	mv	a1,s5
    80005a88:	8552                	mv	a0,s4
    80005a8a:	00000097          	auipc	ra,0x0
    80005a8e:	34c080e7          	jalr	844(ra) # 80005dd6 <pipeclose>
    80005a92:	b7cd                	j	80005a74 <fileclose+0xa8>

0000000080005a94 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005a94:	715d                	addi	sp,sp,-80
    80005a96:	e486                	sd	ra,72(sp)
    80005a98:	e0a2                	sd	s0,64(sp)
    80005a9a:	fc26                	sd	s1,56(sp)
    80005a9c:	f84a                	sd	s2,48(sp)
    80005a9e:	f44e                	sd	s3,40(sp)
    80005aa0:	0880                	addi	s0,sp,80
    80005aa2:	84aa                	mv	s1,a0
    80005aa4:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005aa6:	ffffc097          	auipc	ra,0xffffc
    80005aaa:	2d8080e7          	jalr	728(ra) # 80001d7e <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005aae:	409c                	lw	a5,0(s1)
    80005ab0:	37f9                	addiw	a5,a5,-2
    80005ab2:	4705                	li	a4,1
    80005ab4:	04f76763          	bltu	a4,a5,80005b02 <filestat+0x6e>
    80005ab8:	892a                	mv	s2,a0
    ilock(f->ip);
    80005aba:	6c88                	ld	a0,24(s1)
    80005abc:	fffff097          	auipc	ra,0xfffff
    80005ac0:	070080e7          	jalr	112(ra) # 80004b2c <ilock>
    stati(f->ip, &st);
    80005ac4:	fb840593          	addi	a1,s0,-72
    80005ac8:	6c88                	ld	a0,24(s1)
    80005aca:	fffff097          	auipc	ra,0xfffff
    80005ace:	2ec080e7          	jalr	748(ra) # 80004db6 <stati>
    iunlock(f->ip);
    80005ad2:	6c88                	ld	a0,24(s1)
    80005ad4:	fffff097          	auipc	ra,0xfffff
    80005ad8:	11a080e7          	jalr	282(ra) # 80004bee <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005adc:	46e1                	li	a3,24
    80005ade:	fb840613          	addi	a2,s0,-72
    80005ae2:	85ce                	mv	a1,s3
    80005ae4:	04093503          	ld	a0,64(s2)
    80005ae8:	ffffc097          	auipc	ra,0xffffc
    80005aec:	e7e080e7          	jalr	-386(ra) # 80001966 <copyout>
    80005af0:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80005af4:	60a6                	ld	ra,72(sp)
    80005af6:	6406                	ld	s0,64(sp)
    80005af8:	74e2                	ld	s1,56(sp)
    80005afa:	7942                	ld	s2,48(sp)
    80005afc:	79a2                	ld	s3,40(sp)
    80005afe:	6161                	addi	sp,sp,80
    80005b00:	8082                	ret
  return -1;
    80005b02:	557d                	li	a0,-1
    80005b04:	bfc5                	j	80005af4 <filestat+0x60>

0000000080005b06 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005b06:	7179                	addi	sp,sp,-48
    80005b08:	f406                	sd	ra,40(sp)
    80005b0a:	f022                	sd	s0,32(sp)
    80005b0c:	ec26                	sd	s1,24(sp)
    80005b0e:	e84a                	sd	s2,16(sp)
    80005b10:	e44e                	sd	s3,8(sp)
    80005b12:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005b14:	00854783          	lbu	a5,8(a0)
    80005b18:	c3d5                	beqz	a5,80005bbc <fileread+0xb6>
    80005b1a:	84aa                	mv	s1,a0
    80005b1c:	89ae                	mv	s3,a1
    80005b1e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005b20:	411c                	lw	a5,0(a0)
    80005b22:	4705                	li	a4,1
    80005b24:	04e78963          	beq	a5,a4,80005b76 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005b28:	470d                	li	a4,3
    80005b2a:	04e78d63          	beq	a5,a4,80005b84 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005b2e:	4709                	li	a4,2
    80005b30:	06e79e63          	bne	a5,a4,80005bac <fileread+0xa6>
    ilock(f->ip);
    80005b34:	6d08                	ld	a0,24(a0)
    80005b36:	fffff097          	auipc	ra,0xfffff
    80005b3a:	ff6080e7          	jalr	-10(ra) # 80004b2c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005b3e:	874a                	mv	a4,s2
    80005b40:	5094                	lw	a3,32(s1)
    80005b42:	864e                	mv	a2,s3
    80005b44:	4585                	li	a1,1
    80005b46:	6c88                	ld	a0,24(s1)
    80005b48:	fffff097          	auipc	ra,0xfffff
    80005b4c:	298080e7          	jalr	664(ra) # 80004de0 <readi>
    80005b50:	892a                	mv	s2,a0
    80005b52:	00a05563          	blez	a0,80005b5c <fileread+0x56>
      f->off += r;
    80005b56:	509c                	lw	a5,32(s1)
    80005b58:	9fa9                	addw	a5,a5,a0
    80005b5a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005b5c:	6c88                	ld	a0,24(s1)
    80005b5e:	fffff097          	auipc	ra,0xfffff
    80005b62:	090080e7          	jalr	144(ra) # 80004bee <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005b66:	854a                	mv	a0,s2
    80005b68:	70a2                	ld	ra,40(sp)
    80005b6a:	7402                	ld	s0,32(sp)
    80005b6c:	64e2                	ld	s1,24(sp)
    80005b6e:	6942                	ld	s2,16(sp)
    80005b70:	69a2                	ld	s3,8(sp)
    80005b72:	6145                	addi	sp,sp,48
    80005b74:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005b76:	6908                	ld	a0,16(a0)
    80005b78:	00000097          	auipc	ra,0x0
    80005b7c:	3c8080e7          	jalr	968(ra) # 80005f40 <piperead>
    80005b80:	892a                	mv	s2,a0
    80005b82:	b7d5                	j	80005b66 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005b84:	02451783          	lh	a5,36(a0)
    80005b88:	03079693          	slli	a3,a5,0x30
    80005b8c:	92c1                	srli	a3,a3,0x30
    80005b8e:	4725                	li	a4,9
    80005b90:	02d76863          	bltu	a4,a3,80005bc0 <fileread+0xba>
    80005b94:	0792                	slli	a5,a5,0x4
    80005b96:	00039717          	auipc	a4,0x39
    80005b9a:	3da70713          	addi	a4,a4,986 # 8003ef70 <devsw>
    80005b9e:	97ba                	add	a5,a5,a4
    80005ba0:	639c                	ld	a5,0(a5)
    80005ba2:	c38d                	beqz	a5,80005bc4 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005ba4:	4505                	li	a0,1
    80005ba6:	9782                	jalr	a5
    80005ba8:	892a                	mv	s2,a0
    80005baa:	bf75                	j	80005b66 <fileread+0x60>
    panic("fileread");
    80005bac:	00004517          	auipc	a0,0x4
    80005bb0:	d2c50513          	addi	a0,a0,-724 # 800098d8 <syscalls+0x2b0>
    80005bb4:	ffffb097          	auipc	ra,0xffffb
    80005bb8:	97a080e7          	jalr	-1670(ra) # 8000052e <panic>
    return -1;
    80005bbc:	597d                	li	s2,-1
    80005bbe:	b765                	j	80005b66 <fileread+0x60>
      return -1;
    80005bc0:	597d                	li	s2,-1
    80005bc2:	b755                	j	80005b66 <fileread+0x60>
    80005bc4:	597d                	li	s2,-1
    80005bc6:	b745                	j	80005b66 <fileread+0x60>

0000000080005bc8 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80005bc8:	715d                	addi	sp,sp,-80
    80005bca:	e486                	sd	ra,72(sp)
    80005bcc:	e0a2                	sd	s0,64(sp)
    80005bce:	fc26                	sd	s1,56(sp)
    80005bd0:	f84a                	sd	s2,48(sp)
    80005bd2:	f44e                	sd	s3,40(sp)
    80005bd4:	f052                	sd	s4,32(sp)
    80005bd6:	ec56                	sd	s5,24(sp)
    80005bd8:	e85a                	sd	s6,16(sp)
    80005bda:	e45e                	sd	s7,8(sp)
    80005bdc:	e062                	sd	s8,0(sp)
    80005bde:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80005be0:	00954783          	lbu	a5,9(a0)
    80005be4:	10078663          	beqz	a5,80005cf0 <filewrite+0x128>
    80005be8:	892a                	mv	s2,a0
    80005bea:	8aae                	mv	s5,a1
    80005bec:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005bee:	411c                	lw	a5,0(a0)
    80005bf0:	4705                	li	a4,1
    80005bf2:	02e78263          	beq	a5,a4,80005c16 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005bf6:	470d                	li	a4,3
    80005bf8:	02e78663          	beq	a5,a4,80005c24 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005bfc:	4709                	li	a4,2
    80005bfe:	0ee79163          	bne	a5,a4,80005ce0 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80005c02:	0ac05d63          	blez	a2,80005cbc <filewrite+0xf4>
    int i = 0;
    80005c06:	4981                	li	s3,0
    80005c08:	6b05                	lui	s6,0x1
    80005c0a:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005c0e:	6b85                	lui	s7,0x1
    80005c10:	c00b8b9b          	addiw	s7,s7,-1024
    80005c14:	a861                	j	80005cac <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005c16:	6908                	ld	a0,16(a0)
    80005c18:	00000097          	auipc	ra,0x0
    80005c1c:	22e080e7          	jalr	558(ra) # 80005e46 <pipewrite>
    80005c20:	8a2a                	mv	s4,a0
    80005c22:	a045                	j	80005cc2 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005c24:	02451783          	lh	a5,36(a0)
    80005c28:	03079693          	slli	a3,a5,0x30
    80005c2c:	92c1                	srli	a3,a3,0x30
    80005c2e:	4725                	li	a4,9
    80005c30:	0cd76263          	bltu	a4,a3,80005cf4 <filewrite+0x12c>
    80005c34:	0792                	slli	a5,a5,0x4
    80005c36:	00039717          	auipc	a4,0x39
    80005c3a:	33a70713          	addi	a4,a4,826 # 8003ef70 <devsw>
    80005c3e:	97ba                	add	a5,a5,a4
    80005c40:	679c                	ld	a5,8(a5)
    80005c42:	cbdd                	beqz	a5,80005cf8 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005c44:	4505                	li	a0,1
    80005c46:	9782                	jalr	a5
    80005c48:	8a2a                	mv	s4,a0
    80005c4a:	a8a5                	j	80005cc2 <filewrite+0xfa>
    80005c4c:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005c50:	00000097          	auipc	ra,0x0
    80005c54:	8b0080e7          	jalr	-1872(ra) # 80005500 <begin_op>
      ilock(f->ip);
    80005c58:	01893503          	ld	a0,24(s2)
    80005c5c:	fffff097          	auipc	ra,0xfffff
    80005c60:	ed0080e7          	jalr	-304(ra) # 80004b2c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005c64:	8762                	mv	a4,s8
    80005c66:	02092683          	lw	a3,32(s2)
    80005c6a:	01598633          	add	a2,s3,s5
    80005c6e:	4585                	li	a1,1
    80005c70:	01893503          	ld	a0,24(s2)
    80005c74:	fffff097          	auipc	ra,0xfffff
    80005c78:	264080e7          	jalr	612(ra) # 80004ed8 <writei>
    80005c7c:	84aa                	mv	s1,a0
    80005c7e:	00a05763          	blez	a0,80005c8c <filewrite+0xc4>
        f->off += r;
    80005c82:	02092783          	lw	a5,32(s2)
    80005c86:	9fa9                	addw	a5,a5,a0
    80005c88:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80005c8c:	01893503          	ld	a0,24(s2)
    80005c90:	fffff097          	auipc	ra,0xfffff
    80005c94:	f5e080e7          	jalr	-162(ra) # 80004bee <iunlock>
      end_op();
    80005c98:	00000097          	auipc	ra,0x0
    80005c9c:	8e8080e7          	jalr	-1816(ra) # 80005580 <end_op>

      if(r != n1){
    80005ca0:	009c1f63          	bne	s8,s1,80005cbe <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005ca4:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80005ca8:	0149db63          	bge	s3,s4,80005cbe <filewrite+0xf6>
      int n1 = n - i;
    80005cac:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80005cb0:	84be                	mv	s1,a5
    80005cb2:	2781                	sext.w	a5,a5
    80005cb4:	f8fb5ce3          	bge	s6,a5,80005c4c <filewrite+0x84>
    80005cb8:	84de                	mv	s1,s7
    80005cba:	bf49                	j	80005c4c <filewrite+0x84>
    int i = 0;
    80005cbc:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80005cbe:	013a1f63          	bne	s4,s3,80005cdc <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005cc2:	8552                	mv	a0,s4
    80005cc4:	60a6                	ld	ra,72(sp)
    80005cc6:	6406                	ld	s0,64(sp)
    80005cc8:	74e2                	ld	s1,56(sp)
    80005cca:	7942                	ld	s2,48(sp)
    80005ccc:	79a2                	ld	s3,40(sp)
    80005cce:	7a02                	ld	s4,32(sp)
    80005cd0:	6ae2                	ld	s5,24(sp)
    80005cd2:	6b42                	ld	s6,16(sp)
    80005cd4:	6ba2                	ld	s7,8(sp)
    80005cd6:	6c02                	ld	s8,0(sp)
    80005cd8:	6161                	addi	sp,sp,80
    80005cda:	8082                	ret
    ret = (i == n ? n : -1);
    80005cdc:	5a7d                	li	s4,-1
    80005cde:	b7d5                	j	80005cc2 <filewrite+0xfa>
    panic("filewrite");
    80005ce0:	00004517          	auipc	a0,0x4
    80005ce4:	c0850513          	addi	a0,a0,-1016 # 800098e8 <syscalls+0x2c0>
    80005ce8:	ffffb097          	auipc	ra,0xffffb
    80005cec:	846080e7          	jalr	-1978(ra) # 8000052e <panic>
    return -1;
    80005cf0:	5a7d                	li	s4,-1
    80005cf2:	bfc1                	j	80005cc2 <filewrite+0xfa>
      return -1;
    80005cf4:	5a7d                	li	s4,-1
    80005cf6:	b7f1                	j	80005cc2 <filewrite+0xfa>
    80005cf8:	5a7d                	li	s4,-1
    80005cfa:	b7e1                	j	80005cc2 <filewrite+0xfa>

0000000080005cfc <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005cfc:	7179                	addi	sp,sp,-48
    80005cfe:	f406                	sd	ra,40(sp)
    80005d00:	f022                	sd	s0,32(sp)
    80005d02:	ec26                	sd	s1,24(sp)
    80005d04:	e84a                	sd	s2,16(sp)
    80005d06:	e44e                	sd	s3,8(sp)
    80005d08:	e052                	sd	s4,0(sp)
    80005d0a:	1800                	addi	s0,sp,48
    80005d0c:	84aa                	mv	s1,a0
    80005d0e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005d10:	0005b023          	sd	zero,0(a1)
    80005d14:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005d18:	00000097          	auipc	ra,0x0
    80005d1c:	bf8080e7          	jalr	-1032(ra) # 80005910 <filealloc>
    80005d20:	e088                	sd	a0,0(s1)
    80005d22:	c551                	beqz	a0,80005dae <pipealloc+0xb2>
    80005d24:	00000097          	auipc	ra,0x0
    80005d28:	bec080e7          	jalr	-1044(ra) # 80005910 <filealloc>
    80005d2c:	00aa3023          	sd	a0,0(s4)
    80005d30:	c92d                	beqz	a0,80005da2 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005d32:	ffffb097          	auipc	ra,0xffffb
    80005d36:	da4080e7          	jalr	-604(ra) # 80000ad6 <kalloc>
    80005d3a:	892a                	mv	s2,a0
    80005d3c:	c125                	beqz	a0,80005d9c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005d3e:	4985                	li	s3,1
    80005d40:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005d44:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005d48:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005d4c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005d50:	00004597          	auipc	a1,0x4
    80005d54:	ba858593          	addi	a1,a1,-1112 # 800098f8 <syscalls+0x2d0>
    80005d58:	ffffb097          	auipc	ra,0xffffb
    80005d5c:	dde080e7          	jalr	-546(ra) # 80000b36 <initlock>
  (*f0)->type = FD_PIPE;
    80005d60:	609c                	ld	a5,0(s1)
    80005d62:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005d66:	609c                	ld	a5,0(s1)
    80005d68:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005d6c:	609c                	ld	a5,0(s1)
    80005d6e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005d72:	609c                	ld	a5,0(s1)
    80005d74:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005d78:	000a3783          	ld	a5,0(s4)
    80005d7c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005d80:	000a3783          	ld	a5,0(s4)
    80005d84:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005d88:	000a3783          	ld	a5,0(s4)
    80005d8c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005d90:	000a3783          	ld	a5,0(s4)
    80005d94:	0127b823          	sd	s2,16(a5)
  return 0;
    80005d98:	4501                	li	a0,0
    80005d9a:	a025                	j	80005dc2 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005d9c:	6088                	ld	a0,0(s1)
    80005d9e:	e501                	bnez	a0,80005da6 <pipealloc+0xaa>
    80005da0:	a039                	j	80005dae <pipealloc+0xb2>
    80005da2:	6088                	ld	a0,0(s1)
    80005da4:	c51d                	beqz	a0,80005dd2 <pipealloc+0xd6>
    fileclose(*f0);
    80005da6:	00000097          	auipc	ra,0x0
    80005daa:	c26080e7          	jalr	-986(ra) # 800059cc <fileclose>
  if(*f1)
    80005dae:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80005db2:	557d                	li	a0,-1
  if(*f1)
    80005db4:	c799                	beqz	a5,80005dc2 <pipealloc+0xc6>
    fileclose(*f1);
    80005db6:	853e                	mv	a0,a5
    80005db8:	00000097          	auipc	ra,0x0
    80005dbc:	c14080e7          	jalr	-1004(ra) # 800059cc <fileclose>
  return -1;
    80005dc0:	557d                	li	a0,-1
}
    80005dc2:	70a2                	ld	ra,40(sp)
    80005dc4:	7402                	ld	s0,32(sp)
    80005dc6:	64e2                	ld	s1,24(sp)
    80005dc8:	6942                	ld	s2,16(sp)
    80005dca:	69a2                	ld	s3,8(sp)
    80005dcc:	6a02                	ld	s4,0(sp)
    80005dce:	6145                	addi	sp,sp,48
    80005dd0:	8082                	ret
  return -1;
    80005dd2:	557d                	li	a0,-1
    80005dd4:	b7fd                	j	80005dc2 <pipealloc+0xc6>

0000000080005dd6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005dd6:	1101                	addi	sp,sp,-32
    80005dd8:	ec06                	sd	ra,24(sp)
    80005dda:	e822                	sd	s0,16(sp)
    80005ddc:	e426                	sd	s1,8(sp)
    80005dde:	e04a                	sd	s2,0(sp)
    80005de0:	1000                	addi	s0,sp,32
    80005de2:	84aa                	mv	s1,a0
    80005de4:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005de6:	ffffb097          	auipc	ra,0xffffb
    80005dea:	e22080e7          	jalr	-478(ra) # 80000c08 <acquire>
  if(writable){
    80005dee:	02090d63          	beqz	s2,80005e28 <pipeclose+0x52>
    pi->writeopen = 0;
    80005df2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005df6:	21848513          	addi	a0,s1,536
    80005dfa:	ffffd097          	auipc	ra,0xffffd
    80005dfe:	a84080e7          	jalr	-1404(ra) # 8000287e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005e02:	2204b783          	ld	a5,544(s1)
    80005e06:	eb95                	bnez	a5,80005e3a <pipeclose+0x64>
    release(&pi->lock);
    80005e08:	8526                	mv	a0,s1
    80005e0a:	ffffb097          	auipc	ra,0xffffb
    80005e0e:	ed4080e7          	jalr	-300(ra) # 80000cde <release>
    kfree((char*)pi);
    80005e12:	8526                	mv	a0,s1
    80005e14:	ffffb097          	auipc	ra,0xffffb
    80005e18:	bc6080e7          	jalr	-1082(ra) # 800009da <kfree>
  } else
    release(&pi->lock);
}
    80005e1c:	60e2                	ld	ra,24(sp)
    80005e1e:	6442                	ld	s0,16(sp)
    80005e20:	64a2                	ld	s1,8(sp)
    80005e22:	6902                	ld	s2,0(sp)
    80005e24:	6105                	addi	sp,sp,32
    80005e26:	8082                	ret
    pi->readopen = 0;
    80005e28:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005e2c:	21c48513          	addi	a0,s1,540
    80005e30:	ffffd097          	auipc	ra,0xffffd
    80005e34:	a4e080e7          	jalr	-1458(ra) # 8000287e <wakeup>
    80005e38:	b7e9                	j	80005e02 <pipeclose+0x2c>
    release(&pi->lock);
    80005e3a:	8526                	mv	a0,s1
    80005e3c:	ffffb097          	auipc	ra,0xffffb
    80005e40:	ea2080e7          	jalr	-350(ra) # 80000cde <release>
}
    80005e44:	bfe1                	j	80005e1c <pipeclose+0x46>

0000000080005e46 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005e46:	7159                	addi	sp,sp,-112
    80005e48:	f486                	sd	ra,104(sp)
    80005e4a:	f0a2                	sd	s0,96(sp)
    80005e4c:	eca6                	sd	s1,88(sp)
    80005e4e:	e8ca                	sd	s2,80(sp)
    80005e50:	e4ce                	sd	s3,72(sp)
    80005e52:	e0d2                	sd	s4,64(sp)
    80005e54:	fc56                	sd	s5,56(sp)
    80005e56:	f85a                	sd	s6,48(sp)
    80005e58:	f45e                	sd	s7,40(sp)
    80005e5a:	f062                	sd	s8,32(sp)
    80005e5c:	ec66                	sd	s9,24(sp)
    80005e5e:	1880                	addi	s0,sp,112
    80005e60:	84aa                	mv	s1,a0
    80005e62:	8b2e                	mv	s6,a1
    80005e64:	8ab2                	mv	s5,a2
  int i = 0;
  struct proc *pr = myproc();
    80005e66:	ffffc097          	auipc	ra,0xffffc
    80005e6a:	f18080e7          	jalr	-232(ra) # 80001d7e <myproc>
    80005e6e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005e70:	8526                	mv	a0,s1
    80005e72:	ffffb097          	auipc	ra,0xffffb
    80005e76:	d96080e7          	jalr	-618(ra) # 80000c08 <acquire>
  while(i < n){
    80005e7a:	0b505663          	blez	s5,80005f26 <pipewrite+0xe0>
  int i = 0;
    80005e7e:	4901                	li	s2,0
    if(pi->readopen == 0 || pr->killed==1){
    80005e80:	4a05                	li	s4,1
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005e82:	5bfd                	li	s7,-1
      wakeup(&pi->nread);
    80005e84:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005e88:	21c48c13          	addi	s8,s1,540
    80005e8c:	a091                	j	80005ed0 <pipewrite+0x8a>
      release(&pi->lock);
    80005e8e:	8526                	mv	a0,s1
    80005e90:	ffffb097          	auipc	ra,0xffffb
    80005e94:	e4e080e7          	jalr	-434(ra) # 80000cde <release>
      return -1;
    80005e98:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005e9a:	854a                	mv	a0,s2
    80005e9c:	70a6                	ld	ra,104(sp)
    80005e9e:	7406                	ld	s0,96(sp)
    80005ea0:	64e6                	ld	s1,88(sp)
    80005ea2:	6946                	ld	s2,80(sp)
    80005ea4:	69a6                	ld	s3,72(sp)
    80005ea6:	6a06                	ld	s4,64(sp)
    80005ea8:	7ae2                	ld	s5,56(sp)
    80005eaa:	7b42                	ld	s6,48(sp)
    80005eac:	7ba2                	ld	s7,40(sp)
    80005eae:	7c02                	ld	s8,32(sp)
    80005eb0:	6ce2                	ld	s9,24(sp)
    80005eb2:	6165                	addi	sp,sp,112
    80005eb4:	8082                	ret
      wakeup(&pi->nread);
    80005eb6:	8566                	mv	a0,s9
    80005eb8:	ffffd097          	auipc	ra,0xffffd
    80005ebc:	9c6080e7          	jalr	-1594(ra) # 8000287e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005ec0:	85a6                	mv	a1,s1
    80005ec2:	8562                	mv	a0,s8
    80005ec4:	ffffd097          	auipc	ra,0xffffd
    80005ec8:	830080e7          	jalr	-2000(ra) # 800026f4 <sleep>
  while(i < n){
    80005ecc:	05595e63          	bge	s2,s5,80005f28 <pipewrite+0xe2>
    if(pi->readopen == 0 || pr->killed==1){
    80005ed0:	2204a783          	lw	a5,544(s1)
    80005ed4:	dfcd                	beqz	a5,80005e8e <pipewrite+0x48>
    80005ed6:	01c9a783          	lw	a5,28(s3)
    80005eda:	fb478ae3          	beq	a5,s4,80005e8e <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005ede:	2184a783          	lw	a5,536(s1)
    80005ee2:	21c4a703          	lw	a4,540(s1)
    80005ee6:	2007879b          	addiw	a5,a5,512
    80005eea:	fcf706e3          	beq	a4,a5,80005eb6 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005eee:	86d2                	mv	a3,s4
    80005ef0:	01690633          	add	a2,s2,s6
    80005ef4:	f9f40593          	addi	a1,s0,-97
    80005ef8:	0409b503          	ld	a0,64(s3)
    80005efc:	ffffc097          	auipc	ra,0xffffc
    80005f00:	af6080e7          	jalr	-1290(ra) # 800019f2 <copyin>
    80005f04:	03750263          	beq	a0,s7,80005f28 <pipewrite+0xe2>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005f08:	21c4a783          	lw	a5,540(s1)
    80005f0c:	0017871b          	addiw	a4,a5,1
    80005f10:	20e4ae23          	sw	a4,540(s1)
    80005f14:	1ff7f793          	andi	a5,a5,511
    80005f18:	97a6                	add	a5,a5,s1
    80005f1a:	f9f44703          	lbu	a4,-97(s0)
    80005f1e:	00e78c23          	sb	a4,24(a5)
      i++;
    80005f22:	2905                	addiw	s2,s2,1
    80005f24:	b765                	j	80005ecc <pipewrite+0x86>
  int i = 0;
    80005f26:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005f28:	21848513          	addi	a0,s1,536
    80005f2c:	ffffd097          	auipc	ra,0xffffd
    80005f30:	952080e7          	jalr	-1710(ra) # 8000287e <wakeup>
  release(&pi->lock);
    80005f34:	8526                	mv	a0,s1
    80005f36:	ffffb097          	auipc	ra,0xffffb
    80005f3a:	da8080e7          	jalr	-600(ra) # 80000cde <release>
  return i;
    80005f3e:	bfb1                	j	80005e9a <pipewrite+0x54>

0000000080005f40 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005f40:	715d                	addi	sp,sp,-80
    80005f42:	e486                	sd	ra,72(sp)
    80005f44:	e0a2                	sd	s0,64(sp)
    80005f46:	fc26                	sd	s1,56(sp)
    80005f48:	f84a                	sd	s2,48(sp)
    80005f4a:	f44e                	sd	s3,40(sp)
    80005f4c:	f052                	sd	s4,32(sp)
    80005f4e:	ec56                	sd	s5,24(sp)
    80005f50:	e85a                	sd	s6,16(sp)
    80005f52:	0880                	addi	s0,sp,80
    80005f54:	84aa                	mv	s1,a0
    80005f56:	892e                	mv	s2,a1
    80005f58:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005f5a:	ffffc097          	auipc	ra,0xffffc
    80005f5e:	e24080e7          	jalr	-476(ra) # 80001d7e <myproc>
    80005f62:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005f64:	8526                	mv	a0,s1
    80005f66:	ffffb097          	auipc	ra,0xffffb
    80005f6a:	ca2080e7          	jalr	-862(ra) # 80000c08 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005f6e:	2184a703          	lw	a4,536(s1)
    80005f72:	21c4a783          	lw	a5,540(s1)
    if(pr->killed==1){
    80005f76:	4985                	li	s3,1
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005f78:	21848b13          	addi	s6,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005f7c:	02f71563          	bne	a4,a5,80005fa6 <piperead+0x66>
    80005f80:	2244a783          	lw	a5,548(s1)
    80005f84:	c38d                	beqz	a5,80005fa6 <piperead+0x66>
    if(pr->killed==1){
    80005f86:	01ca2783          	lw	a5,28(s4)
    80005f8a:	09378963          	beq	a5,s3,8000601c <piperead+0xdc>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005f8e:	85a6                	mv	a1,s1
    80005f90:	855a                	mv	a0,s6
    80005f92:	ffffc097          	auipc	ra,0xffffc
    80005f96:	762080e7          	jalr	1890(ra) # 800026f4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005f9a:	2184a703          	lw	a4,536(s1)
    80005f9e:	21c4a783          	lw	a5,540(s1)
    80005fa2:	fcf70fe3          	beq	a4,a5,80005f80 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005fa6:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005fa8:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005faa:	05505363          	blez	s5,80005ff0 <piperead+0xb0>
    if(pi->nread == pi->nwrite)
    80005fae:	2184a783          	lw	a5,536(s1)
    80005fb2:	21c4a703          	lw	a4,540(s1)
    80005fb6:	02f70d63          	beq	a4,a5,80005ff0 <piperead+0xb0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005fba:	0017871b          	addiw	a4,a5,1
    80005fbe:	20e4ac23          	sw	a4,536(s1)
    80005fc2:	1ff7f793          	andi	a5,a5,511
    80005fc6:	97a6                	add	a5,a5,s1
    80005fc8:	0187c783          	lbu	a5,24(a5)
    80005fcc:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005fd0:	4685                	li	a3,1
    80005fd2:	fbf40613          	addi	a2,s0,-65
    80005fd6:	85ca                	mv	a1,s2
    80005fd8:	040a3503          	ld	a0,64(s4)
    80005fdc:	ffffc097          	auipc	ra,0xffffc
    80005fe0:	98a080e7          	jalr	-1654(ra) # 80001966 <copyout>
    80005fe4:	01650663          	beq	a0,s6,80005ff0 <piperead+0xb0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005fe8:	2985                	addiw	s3,s3,1
    80005fea:	0905                	addi	s2,s2,1
    80005fec:	fd3a91e3          	bne	s5,s3,80005fae <piperead+0x6e>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005ff0:	21c48513          	addi	a0,s1,540
    80005ff4:	ffffd097          	auipc	ra,0xffffd
    80005ff8:	88a080e7          	jalr	-1910(ra) # 8000287e <wakeup>
  release(&pi->lock);
    80005ffc:	8526                	mv	a0,s1
    80005ffe:	ffffb097          	auipc	ra,0xffffb
    80006002:	ce0080e7          	jalr	-800(ra) # 80000cde <release>
  return i;
}
    80006006:	854e                	mv	a0,s3
    80006008:	60a6                	ld	ra,72(sp)
    8000600a:	6406                	ld	s0,64(sp)
    8000600c:	74e2                	ld	s1,56(sp)
    8000600e:	7942                	ld	s2,48(sp)
    80006010:	79a2                	ld	s3,40(sp)
    80006012:	7a02                	ld	s4,32(sp)
    80006014:	6ae2                	ld	s5,24(sp)
    80006016:	6b42                	ld	s6,16(sp)
    80006018:	6161                	addi	sp,sp,80
    8000601a:	8082                	ret
      release(&pi->lock);
    8000601c:	8526                	mv	a0,s1
    8000601e:	ffffb097          	auipc	ra,0xffffb
    80006022:	cc0080e7          	jalr	-832(ra) # 80000cde <release>
      return -1;
    80006026:	59fd                	li	s3,-1
    80006028:	bff9                	j	80006006 <piperead+0xc6>

000000008000602a <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    8000602a:	dd010113          	addi	sp,sp,-560
    8000602e:	22113423          	sd	ra,552(sp)
    80006032:	22813023          	sd	s0,544(sp)
    80006036:	20913c23          	sd	s1,536(sp)
    8000603a:	21213823          	sd	s2,528(sp)
    8000603e:	21313423          	sd	s3,520(sp)
    80006042:	21413023          	sd	s4,512(sp)
    80006046:	ffd6                	sd	s5,504(sp)
    80006048:	fbda                	sd	s6,496(sp)
    8000604a:	f7de                	sd	s7,488(sp)
    8000604c:	f3e2                	sd	s8,480(sp)
    8000604e:	efe6                	sd	s9,472(sp)
    80006050:	ebea                	sd	s10,464(sp)
    80006052:	e7ee                	sd	s11,456(sp)
    80006054:	1c00                	addi	s0,sp,560
    80006056:	dea43823          	sd	a0,-528(s0)
    8000605a:	deb43023          	sd	a1,-544(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000605e:	ffffc097          	auipc	ra,0xffffc
    80006062:	d20080e7          	jalr	-736(ra) # 80001d7e <myproc>
    80006066:	89aa                	mv	s3,a0

  struct kthread *t = mykthread();
    80006068:	ffffc097          	auipc	ra,0xffffc
    8000606c:	d56080e7          	jalr	-682(ra) # 80001dbe <mykthread>
    80006070:	8b2a                	mv	s6,a0
  struct kthread *nt;


  // Kill all process threads 
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){ 
    80006072:	28898493          	addi	s1,s3,648
    80006076:	6905                	lui	s2,0x1
    80006078:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    8000607c:	994e                	add	s2,s2,s3
    if(nt!=t && nt->state!=TUNUSED){
      acquire(&nt->lock);
      nt->killed=1;
    8000607e:	4a85                	li	s5,1
      if(nt->state == TSLEEPING){
    80006080:	4a09                	li	s4,2
        nt->state = TRUNNABLE;
    80006082:	4b8d                	li	s7,3
    80006084:	a811                	j	80006098 <exec+0x6e>
      }
      release(&nt->lock);  
    80006086:	8526                	mv	a0,s1
    80006088:	ffffb097          	auipc	ra,0xffffb
    8000608c:	c56080e7          	jalr	-938(ra) # 80000cde <release>
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){ 
    80006090:	0b848493          	addi	s1,s1,184
    80006094:	03248363          	beq	s1,s2,800060ba <exec+0x90>
    if(nt!=t && nt->state!=TUNUSED){
    80006098:	fe9b0ce3          	beq	s6,s1,80006090 <exec+0x66>
    8000609c:	4c9c                	lw	a5,24(s1)
    8000609e:	dbed                	beqz	a5,80006090 <exec+0x66>
      acquire(&nt->lock);
    800060a0:	8526                	mv	a0,s1
    800060a2:	ffffb097          	auipc	ra,0xffffb
    800060a6:	b66080e7          	jalr	-1178(ra) # 80000c08 <acquire>
      nt->killed=1;
    800060aa:	0354a423          	sw	s5,40(s1)
      if(nt->state == TSLEEPING){
    800060ae:	4c9c                	lw	a5,24(s1)
    800060b0:	fd479be3          	bne	a5,s4,80006086 <exec+0x5c>
        nt->state = TRUNNABLE;
    800060b4:	0174ac23          	sw	s7,24(s1)
    800060b8:	b7f9                	j	80006086 <exec+0x5c>
    }
  }

  // Wait for all threads to terminate
  kthread_join_all();
    800060ba:	ffffd097          	auipc	ra,0xffffd
    800060be:	2c6080e7          	jalr	710(ra) # 80003380 <kthread_join_all>
    
  begin_op();
    800060c2:	fffff097          	auipc	ra,0xfffff
    800060c6:	43e080e7          	jalr	1086(ra) # 80005500 <begin_op>

  if((ip = namei(path)) == 0){
    800060ca:	df043503          	ld	a0,-528(s0)
    800060ce:	fffff097          	auipc	ra,0xfffff
    800060d2:	212080e7          	jalr	530(ra) # 800052e0 <namei>
    800060d6:	8aaa                	mv	s5,a0
    800060d8:	cd25                	beqz	a0,80006150 <exec+0x126>
    end_op();
    return -1;
  }
  ilock(ip);
    800060da:	fffff097          	auipc	ra,0xfffff
    800060de:	a52080e7          	jalr	-1454(ra) # 80004b2c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800060e2:	04000713          	li	a4,64
    800060e6:	4681                	li	a3,0
    800060e8:	e4840613          	addi	a2,s0,-440
    800060ec:	4581                	li	a1,0
    800060ee:	8556                	mv	a0,s5
    800060f0:	fffff097          	auipc	ra,0xfffff
    800060f4:	cf0080e7          	jalr	-784(ra) # 80004de0 <readi>
    800060f8:	04000793          	li	a5,64
    800060fc:	00f51a63          	bne	a0,a5,80006110 <exec+0xe6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80006100:	e4842703          	lw	a4,-440(s0)
    80006104:	464c47b7          	lui	a5,0x464c4
    80006108:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000610c:	04f70863          	beq	a4,a5,8000615c <exec+0x132>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80006110:	8556                	mv	a0,s5
    80006112:	fffff097          	auipc	ra,0xfffff
    80006116:	c7c080e7          	jalr	-900(ra) # 80004d8e <iunlockput>
    end_op();
    8000611a:	fffff097          	auipc	ra,0xfffff
    8000611e:	466080e7          	jalr	1126(ra) # 80005580 <end_op>
  }
  return -1;
    80006122:	557d                	li	a0,-1
}
    80006124:	22813083          	ld	ra,552(sp)
    80006128:	22013403          	ld	s0,544(sp)
    8000612c:	21813483          	ld	s1,536(sp)
    80006130:	21013903          	ld	s2,528(sp)
    80006134:	20813983          	ld	s3,520(sp)
    80006138:	20013a03          	ld	s4,512(sp)
    8000613c:	7afe                	ld	s5,504(sp)
    8000613e:	7b5e                	ld	s6,496(sp)
    80006140:	7bbe                	ld	s7,488(sp)
    80006142:	7c1e                	ld	s8,480(sp)
    80006144:	6cfe                	ld	s9,472(sp)
    80006146:	6d5e                	ld	s10,464(sp)
    80006148:	6dbe                	ld	s11,456(sp)
    8000614a:	23010113          	addi	sp,sp,560
    8000614e:	8082                	ret
    end_op();
    80006150:	fffff097          	auipc	ra,0xfffff
    80006154:	430080e7          	jalr	1072(ra) # 80005580 <end_op>
    return -1;
    80006158:	557d                	li	a0,-1
    8000615a:	b7e9                	j	80006124 <exec+0xfa>
  if((pagetable = proc_pagetable(p)) == 0)
    8000615c:	854e                	mv	a0,s3
    8000615e:	ffffc097          	auipc	ra,0xffffc
    80006162:	dbc080e7          	jalr	-580(ra) # 80001f1a <proc_pagetable>
    80006166:	e0a43423          	sd	a0,-504(s0)
    8000616a:	d15d                	beqz	a0,80006110 <exec+0xe6>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000616c:	e6842783          	lw	a5,-408(s0)
    80006170:	e8045703          	lhu	a4,-384(s0)
    80006174:	c73d                	beqz	a4,800061e2 <exec+0x1b8>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80006176:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006178:	e0043023          	sd	zero,-512(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000617c:	6a05                	lui	s4,0x1
    8000617e:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80006182:	dce43c23          	sd	a4,-552(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80006186:	6d85                	lui	s11,0x1
    80006188:	7d7d                	lui	s10,0xfffff
    8000618a:	a4b5                	j	800063f6 <exec+0x3cc>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000618c:	00003517          	auipc	a0,0x3
    80006190:	77450513          	addi	a0,a0,1908 # 80009900 <syscalls+0x2d8>
    80006194:	ffffa097          	auipc	ra,0xffffa
    80006198:	39a080e7          	jalr	922(ra) # 8000052e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000619c:	874a                	mv	a4,s2
    8000619e:	009c86bb          	addw	a3,s9,s1
    800061a2:	4581                	li	a1,0
    800061a4:	8556                	mv	a0,s5
    800061a6:	fffff097          	auipc	ra,0xfffff
    800061aa:	c3a080e7          	jalr	-966(ra) # 80004de0 <readi>
    800061ae:	2501                	sext.w	a0,a0
    800061b0:	1ea91263          	bne	s2,a0,80006394 <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    800061b4:	009d84bb          	addw	s1,s11,s1
    800061b8:	013d09bb          	addw	s3,s10,s3
    800061bc:	2174fd63          	bgeu	s1,s7,800063d6 <exec+0x3ac>
    pa = walkaddr(pagetable, va + i);
    800061c0:	02049593          	slli	a1,s1,0x20
    800061c4:	9181                	srli	a1,a1,0x20
    800061c6:	95e2                	add	a1,a1,s8
    800061c8:	e0843503          	ld	a0,-504(s0)
    800061cc:	ffffb097          	auipc	ra,0xffffb
    800061d0:	1a8080e7          	jalr	424(ra) # 80001374 <walkaddr>
    800061d4:	862a                	mv	a2,a0
    if(pa == 0)
    800061d6:	d95d                	beqz	a0,8000618c <exec+0x162>
      n = PGSIZE;
    800061d8:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800061da:	fd49f1e3          	bgeu	s3,s4,8000619c <exec+0x172>
      n = sz - i;
    800061de:	894e                	mv	s2,s3
    800061e0:	bf75                	j	8000619c <exec+0x172>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800061e2:	4481                	li	s1,0
  iunlockput(ip);
    800061e4:	8556                	mv	a0,s5
    800061e6:	fffff097          	auipc	ra,0xfffff
    800061ea:	ba8080e7          	jalr	-1112(ra) # 80004d8e <iunlockput>
  end_op();
    800061ee:	fffff097          	auipc	ra,0xfffff
    800061f2:	392080e7          	jalr	914(ra) # 80005580 <end_op>
  p = myproc();
    800061f6:	ffffc097          	auipc	ra,0xffffc
    800061fa:	b88080e7          	jalr	-1144(ra) # 80001d7e <myproc>
    800061fe:	8a2a                	mv	s4,a0
  uint64 oldsz = p->sz;
    80006200:	03853d03          	ld	s10,56(a0)
  sz = PGROUNDUP(sz);
    80006204:	6785                	lui	a5,0x1
    80006206:	17fd                	addi	a5,a5,-1
    80006208:	94be                	add	s1,s1,a5
    8000620a:	77fd                	lui	a5,0xfffff
    8000620c:	8fe5                	and	a5,a5,s1
    8000620e:	def43423          	sd	a5,-536(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80006212:	6609                	lui	a2,0x2
    80006214:	963e                	add	a2,a2,a5
    80006216:	85be                	mv	a1,a5
    80006218:	e0843483          	ld	s1,-504(s0)
    8000621c:	8526                	mv	a0,s1
    8000621e:	ffffb097          	auipc	ra,0xffffb
    80006222:	4f8080e7          	jalr	1272(ra) # 80001716 <uvmalloc>
    80006226:	8caa                	mv	s9,a0
  ip = 0;
    80006228:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    8000622a:	16050563          	beqz	a0,80006394 <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000622e:	75f9                	lui	a1,0xffffe
    80006230:	95aa                	add	a1,a1,a0
    80006232:	8526                	mv	a0,s1
    80006234:	ffffb097          	auipc	ra,0xffffb
    80006238:	700080e7          	jalr	1792(ra) # 80001934 <uvmclear>
  stackbase = sp - PGSIZE;
    8000623c:	7bfd                	lui	s7,0xfffff
    8000623e:	9be6                	add	s7,s7,s9
  for(argc = 0; argv[argc]; argc++) {
    80006240:	de043783          	ld	a5,-544(s0)
    80006244:	6388                	ld	a0,0(a5)
    80006246:	c92d                	beqz	a0,800062b8 <exec+0x28e>
    80006248:	e8840993          	addi	s3,s0,-376
    8000624c:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80006250:	8966                	mv	s2,s9
  for(argc = 0; argv[argc]; argc++) {
    80006252:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80006254:	ffffb097          	auipc	ra,0xffffb
    80006258:	f0e080e7          	jalr	-242(ra) # 80001162 <strlen>
    8000625c:	0015079b          	addiw	a5,a0,1
    80006260:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80006264:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80006268:	15796b63          	bltu	s2,s7,800063be <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000626c:	de043d83          	ld	s11,-544(s0)
    80006270:	000dba83          	ld	s5,0(s11) # 1000 <_entry-0x7ffff000>
    80006274:	8556                	mv	a0,s5
    80006276:	ffffb097          	auipc	ra,0xffffb
    8000627a:	eec080e7          	jalr	-276(ra) # 80001162 <strlen>
    8000627e:	0015069b          	addiw	a3,a0,1
    80006282:	8656                	mv	a2,s5
    80006284:	85ca                	mv	a1,s2
    80006286:	e0843503          	ld	a0,-504(s0)
    8000628a:	ffffb097          	auipc	ra,0xffffb
    8000628e:	6dc080e7          	jalr	1756(ra) # 80001966 <copyout>
    80006292:	12054a63          	bltz	a0,800063c6 <exec+0x39c>
    ustack[argc] = sp;
    80006296:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000629a:	0485                	addi	s1,s1,1
    8000629c:	008d8793          	addi	a5,s11,8
    800062a0:	def43023          	sd	a5,-544(s0)
    800062a4:	008db503          	ld	a0,8(s11)
    800062a8:	c911                	beqz	a0,800062bc <exec+0x292>
    if(argc >= MAXARG)
    800062aa:	09a1                	addi	s3,s3,8
    800062ac:	fb3c14e3          	bne	s8,s3,80006254 <exec+0x22a>
  sz = sz1;
    800062b0:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800062b4:	4a81                	li	s5,0
    800062b6:	a8f9                	j	80006394 <exec+0x36a>
  sp = sz;
    800062b8:	8966                	mv	s2,s9
  for(argc = 0; argv[argc]; argc++) {
    800062ba:	4481                	li	s1,0
  ustack[argc] = 0;
    800062bc:	00349793          	slli	a5,s1,0x3
    800062c0:	f9040713          	addi	a4,s0,-112
    800062c4:	97ba                	add	a5,a5,a4
    800062c6:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffbbef8>
  sp -= (argc+1) * sizeof(uint64);
    800062ca:	00148693          	addi	a3,s1,1
    800062ce:	068e                	slli	a3,a3,0x3
    800062d0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800062d4:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800062d8:	01797663          	bgeu	s2,s7,800062e4 <exec+0x2ba>
  sz = sz1;
    800062dc:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800062e0:	4a81                	li	s5,0
    800062e2:	a84d                	j	80006394 <exec+0x36a>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800062e4:	e8840613          	addi	a2,s0,-376
    800062e8:	85ca                	mv	a1,s2
    800062ea:	e0843503          	ld	a0,-504(s0)
    800062ee:	ffffb097          	auipc	ra,0xffffb
    800062f2:	678080e7          	jalr	1656(ra) # 80001966 <copyout>
    800062f6:	0c054c63          	bltz	a0,800063ce <exec+0x3a4>
  t->trapframe->a1 = sp;
    800062fa:	040b3783          	ld	a5,64(s6)
    800062fe:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80006302:	df043783          	ld	a5,-528(s0)
    80006306:	0007c703          	lbu	a4,0(a5)
    8000630a:	cf11                	beqz	a4,80006326 <exec+0x2fc>
    8000630c:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000630e:	02f00693          	li	a3,47
    80006312:	a039                	j	80006320 <exec+0x2f6>
      last = s+1;
    80006314:	def43823          	sd	a5,-528(s0)
  for(last=s=path; *s; s++)
    80006318:	0785                	addi	a5,a5,1
    8000631a:	fff7c703          	lbu	a4,-1(a5)
    8000631e:	c701                	beqz	a4,80006326 <exec+0x2fc>
    if(*s == '/')
    80006320:	fed71ce3          	bne	a4,a3,80006318 <exec+0x2ee>
    80006324:	bfc5                	j	80006314 <exec+0x2ea>
  safestrcpy(p->name, last, sizeof(p->name));
    80006326:	4641                	li	a2,16
    80006328:	df043583          	ld	a1,-528(s0)
    8000632c:	0d8a0513          	addi	a0,s4,216
    80006330:	ffffb097          	auipc	ra,0xffffb
    80006334:	e00080e7          	jalr	-512(ra) # 80001130 <safestrcpy>
  for(int i=0; i<32; i++){
    80006338:	0f8a0793          	addi	a5,s4,248
    8000633c:	1f8a0713          	addi	a4,s4,504
    80006340:	85ba                	mv	a1,a4
    if(!((p->signal_handlers[i]) == (void*)SIG_IGN)){
    80006342:	4605                	li	a2,1
    80006344:	a029                	j	8000634e <exec+0x324>
  for(int i=0; i<32; i++){
    80006346:	07a1                	addi	a5,a5,8
    80006348:	0711                	addi	a4,a4,4
    8000634a:	00f58a63          	beq	a1,a5,8000635e <exec+0x334>
    if(!((p->signal_handlers[i]) == (void*)SIG_IGN)){
    8000634e:	6394                	ld	a3,0(a5)
    80006350:	fec68be3          	beq	a3,a2,80006346 <exec+0x31c>
        p->signal_handlers[i]=SIG_DFL;
    80006354:	0007b023          	sd	zero,0(a5)
        p->handlers_sigmasks[i]=0;   
    80006358:	00072023          	sw	zero,0(a4)
    8000635c:	b7ed                	j	80006346 <exec+0x31c>
  oldpagetable = p->pagetable;
    8000635e:	040a3503          	ld	a0,64(s4)
  p->pagetable = pagetable;
    80006362:	e0843783          	ld	a5,-504(s0)
    80006366:	04fa3023          	sd	a5,64(s4)
  p->sz = sz;
    8000636a:	039a3c23          	sd	s9,56(s4)
  t->trapframe->epc = elf.entry;  // initial program counter = main
    8000636e:	040b3783          	ld	a5,64(s6)
    80006372:	e6043703          	ld	a4,-416(s0)
    80006376:	ef98                	sd	a4,24(a5)
  t->trapframe->sp = sp; // initial stack pointer
    80006378:	040b3783          	ld	a5,64(s6)
    8000637c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80006380:	85ea                	mv	a1,s10
    80006382:	ffffc097          	auipc	ra,0xffffc
    80006386:	c34080e7          	jalr	-972(ra) # 80001fb6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000638a:	0004851b          	sext.w	a0,s1
    8000638e:	bb59                	j	80006124 <exec+0xfa>
    80006390:	de943423          	sd	s1,-536(s0)
    proc_freepagetable(pagetable, sz);
    80006394:	de843583          	ld	a1,-536(s0)
    80006398:	e0843503          	ld	a0,-504(s0)
    8000639c:	ffffc097          	auipc	ra,0xffffc
    800063a0:	c1a080e7          	jalr	-998(ra) # 80001fb6 <proc_freepagetable>
  if(ip){
    800063a4:	d60a96e3          	bnez	s5,80006110 <exec+0xe6>
  return -1;
    800063a8:	557d                	li	a0,-1
    800063aa:	bbad                	j	80006124 <exec+0xfa>
    800063ac:	de943423          	sd	s1,-536(s0)
    800063b0:	b7d5                	j	80006394 <exec+0x36a>
    800063b2:	de943423          	sd	s1,-536(s0)
    800063b6:	bff9                	j	80006394 <exec+0x36a>
    800063b8:	de943423          	sd	s1,-536(s0)
    800063bc:	bfe1                	j	80006394 <exec+0x36a>
  sz = sz1;
    800063be:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800063c2:	4a81                	li	s5,0
    800063c4:	bfc1                	j	80006394 <exec+0x36a>
  sz = sz1;
    800063c6:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800063ca:	4a81                	li	s5,0
    800063cc:	b7e1                	j	80006394 <exec+0x36a>
  sz = sz1;
    800063ce:	df943423          	sd	s9,-536(s0)
  ip = 0;
    800063d2:	4a81                	li	s5,0
    800063d4:	b7c1                	j	80006394 <exec+0x36a>
    sz = sz1;
    800063d6:	de843483          	ld	s1,-536(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800063da:	e0043783          	ld	a5,-512(s0)
    800063de:	0017869b          	addiw	a3,a5,1
    800063e2:	e0d43023          	sd	a3,-512(s0)
    800063e6:	df843783          	ld	a5,-520(s0)
    800063ea:	0387879b          	addiw	a5,a5,56
    800063ee:	e8045703          	lhu	a4,-384(s0)
    800063f2:	dee6d9e3          	bge	a3,a4,800061e4 <exec+0x1ba>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800063f6:	2781                	sext.w	a5,a5
    800063f8:	def43c23          	sd	a5,-520(s0)
    800063fc:	03800713          	li	a4,56
    80006400:	86be                	mv	a3,a5
    80006402:	e1040613          	addi	a2,s0,-496
    80006406:	4581                	li	a1,0
    80006408:	8556                	mv	a0,s5
    8000640a:	fffff097          	auipc	ra,0xfffff
    8000640e:	9d6080e7          	jalr	-1578(ra) # 80004de0 <readi>
    80006412:	03800793          	li	a5,56
    80006416:	f6f51de3          	bne	a0,a5,80006390 <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    8000641a:	e1042783          	lw	a5,-496(s0)
    8000641e:	4705                	li	a4,1
    80006420:	fae79de3          	bne	a5,a4,800063da <exec+0x3b0>
    if(ph.memsz < ph.filesz)
    80006424:	e3843603          	ld	a2,-456(s0)
    80006428:	e3043783          	ld	a5,-464(s0)
    8000642c:	f8f660e3          	bltu	a2,a5,800063ac <exec+0x382>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80006430:	e2043783          	ld	a5,-480(s0)
    80006434:	963e                	add	a2,a2,a5
    80006436:	f6f66ee3          	bltu	a2,a5,800063b2 <exec+0x388>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000643a:	85a6                	mv	a1,s1
    8000643c:	e0843503          	ld	a0,-504(s0)
    80006440:	ffffb097          	auipc	ra,0xffffb
    80006444:	2d6080e7          	jalr	726(ra) # 80001716 <uvmalloc>
    80006448:	dea43423          	sd	a0,-536(s0)
    8000644c:	d535                	beqz	a0,800063b8 <exec+0x38e>
    if(ph.vaddr % PGSIZE != 0)
    8000644e:	e2043c03          	ld	s8,-480(s0)
    80006452:	dd843783          	ld	a5,-552(s0)
    80006456:	00fc77b3          	and	a5,s8,a5
    8000645a:	ff8d                	bnez	a5,80006394 <exec+0x36a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000645c:	e1842c83          	lw	s9,-488(s0)
    80006460:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80006464:	f60b89e3          	beqz	s7,800063d6 <exec+0x3ac>
    80006468:	89de                	mv	s3,s7
    8000646a:	4481                	li	s1,0
    8000646c:	bb91                	j	800061c0 <exec+0x196>

000000008000646e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000646e:	7179                	addi	sp,sp,-48
    80006470:	f406                	sd	ra,40(sp)
    80006472:	f022                	sd	s0,32(sp)
    80006474:	ec26                	sd	s1,24(sp)
    80006476:	e84a                	sd	s2,16(sp)
    80006478:	1800                	addi	s0,sp,48
    8000647a:	892e                	mv	s2,a1
    8000647c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000647e:	fdc40593          	addi	a1,s0,-36
    80006482:	ffffe097          	auipc	ra,0xffffe
    80006486:	8ac080e7          	jalr	-1876(ra) # 80003d2e <argint>
    8000648a:	04054063          	bltz	a0,800064ca <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000648e:	fdc42703          	lw	a4,-36(s0)
    80006492:	47bd                	li	a5,15
    80006494:	02e7ed63          	bltu	a5,a4,800064ce <argfd+0x60>
    80006498:	ffffc097          	auipc	ra,0xffffc
    8000649c:	8e6080e7          	jalr	-1818(ra) # 80001d7e <myproc>
    800064a0:	fdc42703          	lw	a4,-36(s0)
    800064a4:	00a70793          	addi	a5,a4,10
    800064a8:	078e                	slli	a5,a5,0x3
    800064aa:	953e                	add	a0,a0,a5
    800064ac:	611c                	ld	a5,0(a0)
    800064ae:	c395                	beqz	a5,800064d2 <argfd+0x64>
    return -1;
  if(pfd)
    800064b0:	00090463          	beqz	s2,800064b8 <argfd+0x4a>
    *pfd = fd;
    800064b4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800064b8:	4501                	li	a0,0
  if(pf)
    800064ba:	c091                	beqz	s1,800064be <argfd+0x50>
    *pf = f;
    800064bc:	e09c                	sd	a5,0(s1)
}
    800064be:	70a2                	ld	ra,40(sp)
    800064c0:	7402                	ld	s0,32(sp)
    800064c2:	64e2                	ld	s1,24(sp)
    800064c4:	6942                	ld	s2,16(sp)
    800064c6:	6145                	addi	sp,sp,48
    800064c8:	8082                	ret
    return -1;
    800064ca:	557d                	li	a0,-1
    800064cc:	bfcd                	j	800064be <argfd+0x50>
    return -1;
    800064ce:	557d                	li	a0,-1
    800064d0:	b7fd                	j	800064be <argfd+0x50>
    800064d2:	557d                	li	a0,-1
    800064d4:	b7ed                	j	800064be <argfd+0x50>

00000000800064d6 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800064d6:	1101                	addi	sp,sp,-32
    800064d8:	ec06                	sd	ra,24(sp)
    800064da:	e822                	sd	s0,16(sp)
    800064dc:	e426                	sd	s1,8(sp)
    800064de:	1000                	addi	s0,sp,32
    800064e0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800064e2:	ffffc097          	auipc	ra,0xffffc
    800064e6:	89c080e7          	jalr	-1892(ra) # 80001d7e <myproc>
    800064ea:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800064ec:	05050793          	addi	a5,a0,80
    800064f0:	4501                	li	a0,0
    800064f2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800064f4:	6398                	ld	a4,0(a5)
    800064f6:	cb19                	beqz	a4,8000650c <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800064f8:	2505                	addiw	a0,a0,1
    800064fa:	07a1                	addi	a5,a5,8
    800064fc:	fed51ce3          	bne	a0,a3,800064f4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80006500:	557d                	li	a0,-1
}
    80006502:	60e2                	ld	ra,24(sp)
    80006504:	6442                	ld	s0,16(sp)
    80006506:	64a2                	ld	s1,8(sp)
    80006508:	6105                	addi	sp,sp,32
    8000650a:	8082                	ret
      p->ofile[fd] = f;
    8000650c:	00a50793          	addi	a5,a0,10
    80006510:	078e                	slli	a5,a5,0x3
    80006512:	963e                	add	a2,a2,a5
    80006514:	e204                	sd	s1,0(a2)
      return fd;
    80006516:	b7f5                	j	80006502 <fdalloc+0x2c>

0000000080006518 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80006518:	715d                	addi	sp,sp,-80
    8000651a:	e486                	sd	ra,72(sp)
    8000651c:	e0a2                	sd	s0,64(sp)
    8000651e:	fc26                	sd	s1,56(sp)
    80006520:	f84a                	sd	s2,48(sp)
    80006522:	f44e                	sd	s3,40(sp)
    80006524:	f052                	sd	s4,32(sp)
    80006526:	ec56                	sd	s5,24(sp)
    80006528:	0880                	addi	s0,sp,80
    8000652a:	89ae                	mv	s3,a1
    8000652c:	8ab2                	mv	s5,a2
    8000652e:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80006530:	fb040593          	addi	a1,s0,-80
    80006534:	fffff097          	auipc	ra,0xfffff
    80006538:	dca080e7          	jalr	-566(ra) # 800052fe <nameiparent>
    8000653c:	892a                	mv	s2,a0
    8000653e:	12050e63          	beqz	a0,8000667a <create+0x162>
    return 0;

  ilock(dp);
    80006542:	ffffe097          	auipc	ra,0xffffe
    80006546:	5ea080e7          	jalr	1514(ra) # 80004b2c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000654a:	4601                	li	a2,0
    8000654c:	fb040593          	addi	a1,s0,-80
    80006550:	854a                	mv	a0,s2
    80006552:	fffff097          	auipc	ra,0xfffff
    80006556:	abe080e7          	jalr	-1346(ra) # 80005010 <dirlookup>
    8000655a:	84aa                	mv	s1,a0
    8000655c:	c921                	beqz	a0,800065ac <create+0x94>
    iunlockput(dp);
    8000655e:	854a                	mv	a0,s2
    80006560:	fffff097          	auipc	ra,0xfffff
    80006564:	82e080e7          	jalr	-2002(ra) # 80004d8e <iunlockput>
    ilock(ip);
    80006568:	8526                	mv	a0,s1
    8000656a:	ffffe097          	auipc	ra,0xffffe
    8000656e:	5c2080e7          	jalr	1474(ra) # 80004b2c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80006572:	2981                	sext.w	s3,s3
    80006574:	4789                	li	a5,2
    80006576:	02f99463          	bne	s3,a5,8000659e <create+0x86>
    8000657a:	0444d783          	lhu	a5,68(s1)
    8000657e:	37f9                	addiw	a5,a5,-2
    80006580:	17c2                	slli	a5,a5,0x30
    80006582:	93c1                	srli	a5,a5,0x30
    80006584:	4705                	li	a4,1
    80006586:	00f76c63          	bltu	a4,a5,8000659e <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000658a:	8526                	mv	a0,s1
    8000658c:	60a6                	ld	ra,72(sp)
    8000658e:	6406                	ld	s0,64(sp)
    80006590:	74e2                	ld	s1,56(sp)
    80006592:	7942                	ld	s2,48(sp)
    80006594:	79a2                	ld	s3,40(sp)
    80006596:	7a02                	ld	s4,32(sp)
    80006598:	6ae2                	ld	s5,24(sp)
    8000659a:	6161                	addi	sp,sp,80
    8000659c:	8082                	ret
    iunlockput(ip);
    8000659e:	8526                	mv	a0,s1
    800065a0:	ffffe097          	auipc	ra,0xffffe
    800065a4:	7ee080e7          	jalr	2030(ra) # 80004d8e <iunlockput>
    return 0;
    800065a8:	4481                	li	s1,0
    800065aa:	b7c5                	j	8000658a <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800065ac:	85ce                	mv	a1,s3
    800065ae:	00092503          	lw	a0,0(s2)
    800065b2:	ffffe097          	auipc	ra,0xffffe
    800065b6:	3e2080e7          	jalr	994(ra) # 80004994 <ialloc>
    800065ba:	84aa                	mv	s1,a0
    800065bc:	c521                	beqz	a0,80006604 <create+0xec>
  ilock(ip);
    800065be:	ffffe097          	auipc	ra,0xffffe
    800065c2:	56e080e7          	jalr	1390(ra) # 80004b2c <ilock>
  ip->major = major;
    800065c6:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800065ca:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800065ce:	4a05                	li	s4,1
    800065d0:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800065d4:	8526                	mv	a0,s1
    800065d6:	ffffe097          	auipc	ra,0xffffe
    800065da:	48c080e7          	jalr	1164(ra) # 80004a62 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800065de:	2981                	sext.w	s3,s3
    800065e0:	03498a63          	beq	s3,s4,80006614 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800065e4:	40d0                	lw	a2,4(s1)
    800065e6:	fb040593          	addi	a1,s0,-80
    800065ea:	854a                	mv	a0,s2
    800065ec:	fffff097          	auipc	ra,0xfffff
    800065f0:	c32080e7          	jalr	-974(ra) # 8000521e <dirlink>
    800065f4:	06054b63          	bltz	a0,8000666a <create+0x152>
  iunlockput(dp);
    800065f8:	854a                	mv	a0,s2
    800065fa:	ffffe097          	auipc	ra,0xffffe
    800065fe:	794080e7          	jalr	1940(ra) # 80004d8e <iunlockput>
  return ip;
    80006602:	b761                	j	8000658a <create+0x72>
    panic("create: ialloc");
    80006604:	00003517          	auipc	a0,0x3
    80006608:	31c50513          	addi	a0,a0,796 # 80009920 <syscalls+0x2f8>
    8000660c:	ffffa097          	auipc	ra,0xffffa
    80006610:	f22080e7          	jalr	-222(ra) # 8000052e <panic>
    dp->nlink++;  // for ".."
    80006614:	04a95783          	lhu	a5,74(s2)
    80006618:	2785                	addiw	a5,a5,1
    8000661a:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    8000661e:	854a                	mv	a0,s2
    80006620:	ffffe097          	auipc	ra,0xffffe
    80006624:	442080e7          	jalr	1090(ra) # 80004a62 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80006628:	40d0                	lw	a2,4(s1)
    8000662a:	00003597          	auipc	a1,0x3
    8000662e:	30658593          	addi	a1,a1,774 # 80009930 <syscalls+0x308>
    80006632:	8526                	mv	a0,s1
    80006634:	fffff097          	auipc	ra,0xfffff
    80006638:	bea080e7          	jalr	-1046(ra) # 8000521e <dirlink>
    8000663c:	00054f63          	bltz	a0,8000665a <create+0x142>
    80006640:	00492603          	lw	a2,4(s2)
    80006644:	00003597          	auipc	a1,0x3
    80006648:	2f458593          	addi	a1,a1,756 # 80009938 <syscalls+0x310>
    8000664c:	8526                	mv	a0,s1
    8000664e:	fffff097          	auipc	ra,0xfffff
    80006652:	bd0080e7          	jalr	-1072(ra) # 8000521e <dirlink>
    80006656:	f80557e3          	bgez	a0,800065e4 <create+0xcc>
      panic("create dots");
    8000665a:	00003517          	auipc	a0,0x3
    8000665e:	2e650513          	addi	a0,a0,742 # 80009940 <syscalls+0x318>
    80006662:	ffffa097          	auipc	ra,0xffffa
    80006666:	ecc080e7          	jalr	-308(ra) # 8000052e <panic>
    panic("create: dirlink");
    8000666a:	00003517          	auipc	a0,0x3
    8000666e:	2e650513          	addi	a0,a0,742 # 80009950 <syscalls+0x328>
    80006672:	ffffa097          	auipc	ra,0xffffa
    80006676:	ebc080e7          	jalr	-324(ra) # 8000052e <panic>
    return 0;
    8000667a:	84aa                	mv	s1,a0
    8000667c:	b739                	j	8000658a <create+0x72>

000000008000667e <sys_dup>:
{
    8000667e:	7179                	addi	sp,sp,-48
    80006680:	f406                	sd	ra,40(sp)
    80006682:	f022                	sd	s0,32(sp)
    80006684:	ec26                	sd	s1,24(sp)
    80006686:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80006688:	fd840613          	addi	a2,s0,-40
    8000668c:	4581                	li	a1,0
    8000668e:	4501                	li	a0,0
    80006690:	00000097          	auipc	ra,0x0
    80006694:	dde080e7          	jalr	-546(ra) # 8000646e <argfd>
    return -1;
    80006698:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000669a:	02054363          	bltz	a0,800066c0 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000669e:	fd843503          	ld	a0,-40(s0)
    800066a2:	00000097          	auipc	ra,0x0
    800066a6:	e34080e7          	jalr	-460(ra) # 800064d6 <fdalloc>
    800066aa:	84aa                	mv	s1,a0
    return -1;
    800066ac:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800066ae:	00054963          	bltz	a0,800066c0 <sys_dup+0x42>
  filedup(f);
    800066b2:	fd843503          	ld	a0,-40(s0)
    800066b6:	fffff097          	auipc	ra,0xfffff
    800066ba:	2c4080e7          	jalr	708(ra) # 8000597a <filedup>
  return fd;
    800066be:	87a6                	mv	a5,s1
}
    800066c0:	853e                	mv	a0,a5
    800066c2:	70a2                	ld	ra,40(sp)
    800066c4:	7402                	ld	s0,32(sp)
    800066c6:	64e2                	ld	s1,24(sp)
    800066c8:	6145                	addi	sp,sp,48
    800066ca:	8082                	ret

00000000800066cc <sys_read>:
{
    800066cc:	7179                	addi	sp,sp,-48
    800066ce:	f406                	sd	ra,40(sp)
    800066d0:	f022                	sd	s0,32(sp)
    800066d2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800066d4:	fe840613          	addi	a2,s0,-24
    800066d8:	4581                	li	a1,0
    800066da:	4501                	li	a0,0
    800066dc:	00000097          	auipc	ra,0x0
    800066e0:	d92080e7          	jalr	-622(ra) # 8000646e <argfd>
    return -1;
    800066e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800066e6:	04054163          	bltz	a0,80006728 <sys_read+0x5c>
    800066ea:	fe440593          	addi	a1,s0,-28
    800066ee:	4509                	li	a0,2
    800066f0:	ffffd097          	auipc	ra,0xffffd
    800066f4:	63e080e7          	jalr	1598(ra) # 80003d2e <argint>
    return -1;
    800066f8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800066fa:	02054763          	bltz	a0,80006728 <sys_read+0x5c>
    800066fe:	fd840593          	addi	a1,s0,-40
    80006702:	4505                	li	a0,1
    80006704:	ffffd097          	auipc	ra,0xffffd
    80006708:	64c080e7          	jalr	1612(ra) # 80003d50 <argaddr>
    return -1;
    8000670c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000670e:	00054d63          	bltz	a0,80006728 <sys_read+0x5c>
  return fileread(f, p, n);
    80006712:	fe442603          	lw	a2,-28(s0)
    80006716:	fd843583          	ld	a1,-40(s0)
    8000671a:	fe843503          	ld	a0,-24(s0)
    8000671e:	fffff097          	auipc	ra,0xfffff
    80006722:	3e8080e7          	jalr	1000(ra) # 80005b06 <fileread>
    80006726:	87aa                	mv	a5,a0
}
    80006728:	853e                	mv	a0,a5
    8000672a:	70a2                	ld	ra,40(sp)
    8000672c:	7402                	ld	s0,32(sp)
    8000672e:	6145                	addi	sp,sp,48
    80006730:	8082                	ret

0000000080006732 <sys_write>:
{
    80006732:	7179                	addi	sp,sp,-48
    80006734:	f406                	sd	ra,40(sp)
    80006736:	f022                	sd	s0,32(sp)
    80006738:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000673a:	fe840613          	addi	a2,s0,-24
    8000673e:	4581                	li	a1,0
    80006740:	4501                	li	a0,0
    80006742:	00000097          	auipc	ra,0x0
    80006746:	d2c080e7          	jalr	-724(ra) # 8000646e <argfd>
    return -1;
    8000674a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000674c:	04054163          	bltz	a0,8000678e <sys_write+0x5c>
    80006750:	fe440593          	addi	a1,s0,-28
    80006754:	4509                	li	a0,2
    80006756:	ffffd097          	auipc	ra,0xffffd
    8000675a:	5d8080e7          	jalr	1496(ra) # 80003d2e <argint>
    return -1;
    8000675e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006760:	02054763          	bltz	a0,8000678e <sys_write+0x5c>
    80006764:	fd840593          	addi	a1,s0,-40
    80006768:	4505                	li	a0,1
    8000676a:	ffffd097          	auipc	ra,0xffffd
    8000676e:	5e6080e7          	jalr	1510(ra) # 80003d50 <argaddr>
    return -1;
    80006772:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006774:	00054d63          	bltz	a0,8000678e <sys_write+0x5c>
  return filewrite(f, p, n);
    80006778:	fe442603          	lw	a2,-28(s0)
    8000677c:	fd843583          	ld	a1,-40(s0)
    80006780:	fe843503          	ld	a0,-24(s0)
    80006784:	fffff097          	auipc	ra,0xfffff
    80006788:	444080e7          	jalr	1092(ra) # 80005bc8 <filewrite>
    8000678c:	87aa                	mv	a5,a0
}
    8000678e:	853e                	mv	a0,a5
    80006790:	70a2                	ld	ra,40(sp)
    80006792:	7402                	ld	s0,32(sp)
    80006794:	6145                	addi	sp,sp,48
    80006796:	8082                	ret

0000000080006798 <sys_close>:
{
    80006798:	1101                	addi	sp,sp,-32
    8000679a:	ec06                	sd	ra,24(sp)
    8000679c:	e822                	sd	s0,16(sp)
    8000679e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800067a0:	fe040613          	addi	a2,s0,-32
    800067a4:	fec40593          	addi	a1,s0,-20
    800067a8:	4501                	li	a0,0
    800067aa:	00000097          	auipc	ra,0x0
    800067ae:	cc4080e7          	jalr	-828(ra) # 8000646e <argfd>
    return -1;
    800067b2:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800067b4:	02054463          	bltz	a0,800067dc <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800067b8:	ffffb097          	auipc	ra,0xffffb
    800067bc:	5c6080e7          	jalr	1478(ra) # 80001d7e <myproc>
    800067c0:	fec42783          	lw	a5,-20(s0)
    800067c4:	07a9                	addi	a5,a5,10
    800067c6:	078e                	slli	a5,a5,0x3
    800067c8:	97aa                	add	a5,a5,a0
    800067ca:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800067ce:	fe043503          	ld	a0,-32(s0)
    800067d2:	fffff097          	auipc	ra,0xfffff
    800067d6:	1fa080e7          	jalr	506(ra) # 800059cc <fileclose>
  return 0;
    800067da:	4781                	li	a5,0
}
    800067dc:	853e                	mv	a0,a5
    800067de:	60e2                	ld	ra,24(sp)
    800067e0:	6442                	ld	s0,16(sp)
    800067e2:	6105                	addi	sp,sp,32
    800067e4:	8082                	ret

00000000800067e6 <sys_fstat>:
{
    800067e6:	1101                	addi	sp,sp,-32
    800067e8:	ec06                	sd	ra,24(sp)
    800067ea:	e822                	sd	s0,16(sp)
    800067ec:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800067ee:	fe840613          	addi	a2,s0,-24
    800067f2:	4581                	li	a1,0
    800067f4:	4501                	li	a0,0
    800067f6:	00000097          	auipc	ra,0x0
    800067fa:	c78080e7          	jalr	-904(ra) # 8000646e <argfd>
    return -1;
    800067fe:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006800:	02054563          	bltz	a0,8000682a <sys_fstat+0x44>
    80006804:	fe040593          	addi	a1,s0,-32
    80006808:	4505                	li	a0,1
    8000680a:	ffffd097          	auipc	ra,0xffffd
    8000680e:	546080e7          	jalr	1350(ra) # 80003d50 <argaddr>
    return -1;
    80006812:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006814:	00054b63          	bltz	a0,8000682a <sys_fstat+0x44>
  return filestat(f, st);
    80006818:	fe043583          	ld	a1,-32(s0)
    8000681c:	fe843503          	ld	a0,-24(s0)
    80006820:	fffff097          	auipc	ra,0xfffff
    80006824:	274080e7          	jalr	628(ra) # 80005a94 <filestat>
    80006828:	87aa                	mv	a5,a0
}
    8000682a:	853e                	mv	a0,a5
    8000682c:	60e2                	ld	ra,24(sp)
    8000682e:	6442                	ld	s0,16(sp)
    80006830:	6105                	addi	sp,sp,32
    80006832:	8082                	ret

0000000080006834 <sys_link>:
{
    80006834:	7169                	addi	sp,sp,-304
    80006836:	f606                	sd	ra,296(sp)
    80006838:	f222                	sd	s0,288(sp)
    8000683a:	ee26                	sd	s1,280(sp)
    8000683c:	ea4a                	sd	s2,272(sp)
    8000683e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006840:	08000613          	li	a2,128
    80006844:	ed040593          	addi	a1,s0,-304
    80006848:	4501                	li	a0,0
    8000684a:	ffffd097          	auipc	ra,0xffffd
    8000684e:	528080e7          	jalr	1320(ra) # 80003d72 <argstr>
    return -1;
    80006852:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80006854:	10054e63          	bltz	a0,80006970 <sys_link+0x13c>
    80006858:	08000613          	li	a2,128
    8000685c:	f5040593          	addi	a1,s0,-176
    80006860:	4505                	li	a0,1
    80006862:	ffffd097          	auipc	ra,0xffffd
    80006866:	510080e7          	jalr	1296(ra) # 80003d72 <argstr>
    return -1;
    8000686a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000686c:	10054263          	bltz	a0,80006970 <sys_link+0x13c>
  begin_op();
    80006870:	fffff097          	auipc	ra,0xfffff
    80006874:	c90080e7          	jalr	-880(ra) # 80005500 <begin_op>
  if((ip = namei(old)) == 0){
    80006878:	ed040513          	addi	a0,s0,-304
    8000687c:	fffff097          	auipc	ra,0xfffff
    80006880:	a64080e7          	jalr	-1436(ra) # 800052e0 <namei>
    80006884:	84aa                	mv	s1,a0
    80006886:	c551                	beqz	a0,80006912 <sys_link+0xde>
  ilock(ip);
    80006888:	ffffe097          	auipc	ra,0xffffe
    8000688c:	2a4080e7          	jalr	676(ra) # 80004b2c <ilock>
  if(ip->type == T_DIR){
    80006890:	04449703          	lh	a4,68(s1)
    80006894:	4785                	li	a5,1
    80006896:	08f70463          	beq	a4,a5,8000691e <sys_link+0xea>
  ip->nlink++;
    8000689a:	04a4d783          	lhu	a5,74(s1)
    8000689e:	2785                	addiw	a5,a5,1
    800068a0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800068a4:	8526                	mv	a0,s1
    800068a6:	ffffe097          	auipc	ra,0xffffe
    800068aa:	1bc080e7          	jalr	444(ra) # 80004a62 <iupdate>
  iunlock(ip);
    800068ae:	8526                	mv	a0,s1
    800068b0:	ffffe097          	auipc	ra,0xffffe
    800068b4:	33e080e7          	jalr	830(ra) # 80004bee <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800068b8:	fd040593          	addi	a1,s0,-48
    800068bc:	f5040513          	addi	a0,s0,-176
    800068c0:	fffff097          	auipc	ra,0xfffff
    800068c4:	a3e080e7          	jalr	-1474(ra) # 800052fe <nameiparent>
    800068c8:	892a                	mv	s2,a0
    800068ca:	c935                	beqz	a0,8000693e <sys_link+0x10a>
  ilock(dp);
    800068cc:	ffffe097          	auipc	ra,0xffffe
    800068d0:	260080e7          	jalr	608(ra) # 80004b2c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800068d4:	00092703          	lw	a4,0(s2)
    800068d8:	409c                	lw	a5,0(s1)
    800068da:	04f71d63          	bne	a4,a5,80006934 <sys_link+0x100>
    800068de:	40d0                	lw	a2,4(s1)
    800068e0:	fd040593          	addi	a1,s0,-48
    800068e4:	854a                	mv	a0,s2
    800068e6:	fffff097          	auipc	ra,0xfffff
    800068ea:	938080e7          	jalr	-1736(ra) # 8000521e <dirlink>
    800068ee:	04054363          	bltz	a0,80006934 <sys_link+0x100>
  iunlockput(dp);
    800068f2:	854a                	mv	a0,s2
    800068f4:	ffffe097          	auipc	ra,0xffffe
    800068f8:	49a080e7          	jalr	1178(ra) # 80004d8e <iunlockput>
  iput(ip);
    800068fc:	8526                	mv	a0,s1
    800068fe:	ffffe097          	auipc	ra,0xffffe
    80006902:	3e8080e7          	jalr	1000(ra) # 80004ce6 <iput>
  end_op();
    80006906:	fffff097          	auipc	ra,0xfffff
    8000690a:	c7a080e7          	jalr	-902(ra) # 80005580 <end_op>
  return 0;
    8000690e:	4781                	li	a5,0
    80006910:	a085                	j	80006970 <sys_link+0x13c>
    end_op();
    80006912:	fffff097          	auipc	ra,0xfffff
    80006916:	c6e080e7          	jalr	-914(ra) # 80005580 <end_op>
    return -1;
    8000691a:	57fd                	li	a5,-1
    8000691c:	a891                	j	80006970 <sys_link+0x13c>
    iunlockput(ip);
    8000691e:	8526                	mv	a0,s1
    80006920:	ffffe097          	auipc	ra,0xffffe
    80006924:	46e080e7          	jalr	1134(ra) # 80004d8e <iunlockput>
    end_op();
    80006928:	fffff097          	auipc	ra,0xfffff
    8000692c:	c58080e7          	jalr	-936(ra) # 80005580 <end_op>
    return -1;
    80006930:	57fd                	li	a5,-1
    80006932:	a83d                	j	80006970 <sys_link+0x13c>
    iunlockput(dp);
    80006934:	854a                	mv	a0,s2
    80006936:	ffffe097          	auipc	ra,0xffffe
    8000693a:	458080e7          	jalr	1112(ra) # 80004d8e <iunlockput>
  ilock(ip);
    8000693e:	8526                	mv	a0,s1
    80006940:	ffffe097          	auipc	ra,0xffffe
    80006944:	1ec080e7          	jalr	492(ra) # 80004b2c <ilock>
  ip->nlink--;
    80006948:	04a4d783          	lhu	a5,74(s1)
    8000694c:	37fd                	addiw	a5,a5,-1
    8000694e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006952:	8526                	mv	a0,s1
    80006954:	ffffe097          	auipc	ra,0xffffe
    80006958:	10e080e7          	jalr	270(ra) # 80004a62 <iupdate>
  iunlockput(ip);
    8000695c:	8526                	mv	a0,s1
    8000695e:	ffffe097          	auipc	ra,0xffffe
    80006962:	430080e7          	jalr	1072(ra) # 80004d8e <iunlockput>
  end_op();
    80006966:	fffff097          	auipc	ra,0xfffff
    8000696a:	c1a080e7          	jalr	-998(ra) # 80005580 <end_op>
  return -1;
    8000696e:	57fd                	li	a5,-1
}
    80006970:	853e                	mv	a0,a5
    80006972:	70b2                	ld	ra,296(sp)
    80006974:	7412                	ld	s0,288(sp)
    80006976:	64f2                	ld	s1,280(sp)
    80006978:	6952                	ld	s2,272(sp)
    8000697a:	6155                	addi	sp,sp,304
    8000697c:	8082                	ret

000000008000697e <sys_unlink>:
{
    8000697e:	7151                	addi	sp,sp,-240
    80006980:	f586                	sd	ra,232(sp)
    80006982:	f1a2                	sd	s0,224(sp)
    80006984:	eda6                	sd	s1,216(sp)
    80006986:	e9ca                	sd	s2,208(sp)
    80006988:	e5ce                	sd	s3,200(sp)
    8000698a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000698c:	08000613          	li	a2,128
    80006990:	f3040593          	addi	a1,s0,-208
    80006994:	4501                	li	a0,0
    80006996:	ffffd097          	auipc	ra,0xffffd
    8000699a:	3dc080e7          	jalr	988(ra) # 80003d72 <argstr>
    8000699e:	18054163          	bltz	a0,80006b20 <sys_unlink+0x1a2>
  begin_op();
    800069a2:	fffff097          	auipc	ra,0xfffff
    800069a6:	b5e080e7          	jalr	-1186(ra) # 80005500 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800069aa:	fb040593          	addi	a1,s0,-80
    800069ae:	f3040513          	addi	a0,s0,-208
    800069b2:	fffff097          	auipc	ra,0xfffff
    800069b6:	94c080e7          	jalr	-1716(ra) # 800052fe <nameiparent>
    800069ba:	84aa                	mv	s1,a0
    800069bc:	c979                	beqz	a0,80006a92 <sys_unlink+0x114>
  ilock(dp);
    800069be:	ffffe097          	auipc	ra,0xffffe
    800069c2:	16e080e7          	jalr	366(ra) # 80004b2c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800069c6:	00003597          	auipc	a1,0x3
    800069ca:	f6a58593          	addi	a1,a1,-150 # 80009930 <syscalls+0x308>
    800069ce:	fb040513          	addi	a0,s0,-80
    800069d2:	ffffe097          	auipc	ra,0xffffe
    800069d6:	624080e7          	jalr	1572(ra) # 80004ff6 <namecmp>
    800069da:	14050a63          	beqz	a0,80006b2e <sys_unlink+0x1b0>
    800069de:	00003597          	auipc	a1,0x3
    800069e2:	f5a58593          	addi	a1,a1,-166 # 80009938 <syscalls+0x310>
    800069e6:	fb040513          	addi	a0,s0,-80
    800069ea:	ffffe097          	auipc	ra,0xffffe
    800069ee:	60c080e7          	jalr	1548(ra) # 80004ff6 <namecmp>
    800069f2:	12050e63          	beqz	a0,80006b2e <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800069f6:	f2c40613          	addi	a2,s0,-212
    800069fa:	fb040593          	addi	a1,s0,-80
    800069fe:	8526                	mv	a0,s1
    80006a00:	ffffe097          	auipc	ra,0xffffe
    80006a04:	610080e7          	jalr	1552(ra) # 80005010 <dirlookup>
    80006a08:	892a                	mv	s2,a0
    80006a0a:	12050263          	beqz	a0,80006b2e <sys_unlink+0x1b0>
  ilock(ip);
    80006a0e:	ffffe097          	auipc	ra,0xffffe
    80006a12:	11e080e7          	jalr	286(ra) # 80004b2c <ilock>
  if(ip->nlink < 1)
    80006a16:	04a91783          	lh	a5,74(s2)
    80006a1a:	08f05263          	blez	a5,80006a9e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006a1e:	04491703          	lh	a4,68(s2)
    80006a22:	4785                	li	a5,1
    80006a24:	08f70563          	beq	a4,a5,80006aae <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80006a28:	4641                	li	a2,16
    80006a2a:	4581                	li	a1,0
    80006a2c:	fc040513          	addi	a0,s0,-64
    80006a30:	ffffa097          	auipc	ra,0xffffa
    80006a34:	5ae080e7          	jalr	1454(ra) # 80000fde <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006a38:	4741                	li	a4,16
    80006a3a:	f2c42683          	lw	a3,-212(s0)
    80006a3e:	fc040613          	addi	a2,s0,-64
    80006a42:	4581                	li	a1,0
    80006a44:	8526                	mv	a0,s1
    80006a46:	ffffe097          	auipc	ra,0xffffe
    80006a4a:	492080e7          	jalr	1170(ra) # 80004ed8 <writei>
    80006a4e:	47c1                	li	a5,16
    80006a50:	0af51563          	bne	a0,a5,80006afa <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80006a54:	04491703          	lh	a4,68(s2)
    80006a58:	4785                	li	a5,1
    80006a5a:	0af70863          	beq	a4,a5,80006b0a <sys_unlink+0x18c>
  iunlockput(dp);
    80006a5e:	8526                	mv	a0,s1
    80006a60:	ffffe097          	auipc	ra,0xffffe
    80006a64:	32e080e7          	jalr	814(ra) # 80004d8e <iunlockput>
  ip->nlink--;
    80006a68:	04a95783          	lhu	a5,74(s2)
    80006a6c:	37fd                	addiw	a5,a5,-1
    80006a6e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80006a72:	854a                	mv	a0,s2
    80006a74:	ffffe097          	auipc	ra,0xffffe
    80006a78:	fee080e7          	jalr	-18(ra) # 80004a62 <iupdate>
  iunlockput(ip);
    80006a7c:	854a                	mv	a0,s2
    80006a7e:	ffffe097          	auipc	ra,0xffffe
    80006a82:	310080e7          	jalr	784(ra) # 80004d8e <iunlockput>
  end_op();
    80006a86:	fffff097          	auipc	ra,0xfffff
    80006a8a:	afa080e7          	jalr	-1286(ra) # 80005580 <end_op>
  return 0;
    80006a8e:	4501                	li	a0,0
    80006a90:	a84d                	j	80006b42 <sys_unlink+0x1c4>
    end_op();
    80006a92:	fffff097          	auipc	ra,0xfffff
    80006a96:	aee080e7          	jalr	-1298(ra) # 80005580 <end_op>
    return -1;
    80006a9a:	557d                	li	a0,-1
    80006a9c:	a05d                	j	80006b42 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80006a9e:	00003517          	auipc	a0,0x3
    80006aa2:	ec250513          	addi	a0,a0,-318 # 80009960 <syscalls+0x338>
    80006aa6:	ffffa097          	auipc	ra,0xffffa
    80006aaa:	a88080e7          	jalr	-1400(ra) # 8000052e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006aae:	04c92703          	lw	a4,76(s2)
    80006ab2:	02000793          	li	a5,32
    80006ab6:	f6e7f9e3          	bgeu	a5,a4,80006a28 <sys_unlink+0xaa>
    80006aba:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006abe:	4741                	li	a4,16
    80006ac0:	86ce                	mv	a3,s3
    80006ac2:	f1840613          	addi	a2,s0,-232
    80006ac6:	4581                	li	a1,0
    80006ac8:	854a                	mv	a0,s2
    80006aca:	ffffe097          	auipc	ra,0xffffe
    80006ace:	316080e7          	jalr	790(ra) # 80004de0 <readi>
    80006ad2:	47c1                	li	a5,16
    80006ad4:	00f51b63          	bne	a0,a5,80006aea <sys_unlink+0x16c>
    if(de.inum != 0)
    80006ad8:	f1845783          	lhu	a5,-232(s0)
    80006adc:	e7a1                	bnez	a5,80006b24 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006ade:	29c1                	addiw	s3,s3,16
    80006ae0:	04c92783          	lw	a5,76(s2)
    80006ae4:	fcf9ede3          	bltu	s3,a5,80006abe <sys_unlink+0x140>
    80006ae8:	b781                	j	80006a28 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80006aea:	00003517          	auipc	a0,0x3
    80006aee:	e8e50513          	addi	a0,a0,-370 # 80009978 <syscalls+0x350>
    80006af2:	ffffa097          	auipc	ra,0xffffa
    80006af6:	a3c080e7          	jalr	-1476(ra) # 8000052e <panic>
    panic("unlink: writei");
    80006afa:	00003517          	auipc	a0,0x3
    80006afe:	e9650513          	addi	a0,a0,-362 # 80009990 <syscalls+0x368>
    80006b02:	ffffa097          	auipc	ra,0xffffa
    80006b06:	a2c080e7          	jalr	-1492(ra) # 8000052e <panic>
    dp->nlink--;
    80006b0a:	04a4d783          	lhu	a5,74(s1)
    80006b0e:	37fd                	addiw	a5,a5,-1
    80006b10:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80006b14:	8526                	mv	a0,s1
    80006b16:	ffffe097          	auipc	ra,0xffffe
    80006b1a:	f4c080e7          	jalr	-180(ra) # 80004a62 <iupdate>
    80006b1e:	b781                	j	80006a5e <sys_unlink+0xe0>
    return -1;
    80006b20:	557d                	li	a0,-1
    80006b22:	a005                	j	80006b42 <sys_unlink+0x1c4>
    iunlockput(ip);
    80006b24:	854a                	mv	a0,s2
    80006b26:	ffffe097          	auipc	ra,0xffffe
    80006b2a:	268080e7          	jalr	616(ra) # 80004d8e <iunlockput>
  iunlockput(dp);
    80006b2e:	8526                	mv	a0,s1
    80006b30:	ffffe097          	auipc	ra,0xffffe
    80006b34:	25e080e7          	jalr	606(ra) # 80004d8e <iunlockput>
  end_op();
    80006b38:	fffff097          	auipc	ra,0xfffff
    80006b3c:	a48080e7          	jalr	-1464(ra) # 80005580 <end_op>
  return -1;
    80006b40:	557d                	li	a0,-1
}
    80006b42:	70ae                	ld	ra,232(sp)
    80006b44:	740e                	ld	s0,224(sp)
    80006b46:	64ee                	ld	s1,216(sp)
    80006b48:	694e                	ld	s2,208(sp)
    80006b4a:	69ae                	ld	s3,200(sp)
    80006b4c:	616d                	addi	sp,sp,240
    80006b4e:	8082                	ret

0000000080006b50 <sys_open>:

uint64
sys_open(void)
{
    80006b50:	7131                	addi	sp,sp,-192
    80006b52:	fd06                	sd	ra,184(sp)
    80006b54:	f922                	sd	s0,176(sp)
    80006b56:	f526                	sd	s1,168(sp)
    80006b58:	f14a                	sd	s2,160(sp)
    80006b5a:	ed4e                	sd	s3,152(sp)
    80006b5c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006b5e:	08000613          	li	a2,128
    80006b62:	f5040593          	addi	a1,s0,-176
    80006b66:	4501                	li	a0,0
    80006b68:	ffffd097          	auipc	ra,0xffffd
    80006b6c:	20a080e7          	jalr	522(ra) # 80003d72 <argstr>
    return -1;
    80006b70:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006b72:	0c054163          	bltz	a0,80006c34 <sys_open+0xe4>
    80006b76:	f4c40593          	addi	a1,s0,-180
    80006b7a:	4505                	li	a0,1
    80006b7c:	ffffd097          	auipc	ra,0xffffd
    80006b80:	1b2080e7          	jalr	434(ra) # 80003d2e <argint>
    80006b84:	0a054863          	bltz	a0,80006c34 <sys_open+0xe4>

  begin_op();
    80006b88:	fffff097          	auipc	ra,0xfffff
    80006b8c:	978080e7          	jalr	-1672(ra) # 80005500 <begin_op>

  if(omode & O_CREATE){
    80006b90:	f4c42783          	lw	a5,-180(s0)
    80006b94:	2007f793          	andi	a5,a5,512
    80006b98:	cbdd                	beqz	a5,80006c4e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80006b9a:	4681                	li	a3,0
    80006b9c:	4601                	li	a2,0
    80006b9e:	4589                	li	a1,2
    80006ba0:	f5040513          	addi	a0,s0,-176
    80006ba4:	00000097          	auipc	ra,0x0
    80006ba8:	974080e7          	jalr	-1676(ra) # 80006518 <create>
    80006bac:	892a                	mv	s2,a0
    if(ip == 0){
    80006bae:	c959                	beqz	a0,80006c44 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80006bb0:	04491703          	lh	a4,68(s2)
    80006bb4:	478d                	li	a5,3
    80006bb6:	00f71763          	bne	a4,a5,80006bc4 <sys_open+0x74>
    80006bba:	04695703          	lhu	a4,70(s2)
    80006bbe:	47a5                	li	a5,9
    80006bc0:	0ce7ec63          	bltu	a5,a4,80006c98 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80006bc4:	fffff097          	auipc	ra,0xfffff
    80006bc8:	d4c080e7          	jalr	-692(ra) # 80005910 <filealloc>
    80006bcc:	89aa                	mv	s3,a0
    80006bce:	10050263          	beqz	a0,80006cd2 <sys_open+0x182>
    80006bd2:	00000097          	auipc	ra,0x0
    80006bd6:	904080e7          	jalr	-1788(ra) # 800064d6 <fdalloc>
    80006bda:	84aa                	mv	s1,a0
    80006bdc:	0e054663          	bltz	a0,80006cc8 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80006be0:	04491703          	lh	a4,68(s2)
    80006be4:	478d                	li	a5,3
    80006be6:	0cf70463          	beq	a4,a5,80006cae <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006bea:	4789                	li	a5,2
    80006bec:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80006bf0:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80006bf4:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80006bf8:	f4c42783          	lw	a5,-180(s0)
    80006bfc:	0017c713          	xori	a4,a5,1
    80006c00:	8b05                	andi	a4,a4,1
    80006c02:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006c06:	0037f713          	andi	a4,a5,3
    80006c0a:	00e03733          	snez	a4,a4
    80006c0e:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006c12:	4007f793          	andi	a5,a5,1024
    80006c16:	c791                	beqz	a5,80006c22 <sys_open+0xd2>
    80006c18:	04491703          	lh	a4,68(s2)
    80006c1c:	4789                	li	a5,2
    80006c1e:	08f70f63          	beq	a4,a5,80006cbc <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006c22:	854a                	mv	a0,s2
    80006c24:	ffffe097          	auipc	ra,0xffffe
    80006c28:	fca080e7          	jalr	-54(ra) # 80004bee <iunlock>
  end_op();
    80006c2c:	fffff097          	auipc	ra,0xfffff
    80006c30:	954080e7          	jalr	-1708(ra) # 80005580 <end_op>

  return fd;
}
    80006c34:	8526                	mv	a0,s1
    80006c36:	70ea                	ld	ra,184(sp)
    80006c38:	744a                	ld	s0,176(sp)
    80006c3a:	74aa                	ld	s1,168(sp)
    80006c3c:	790a                	ld	s2,160(sp)
    80006c3e:	69ea                	ld	s3,152(sp)
    80006c40:	6129                	addi	sp,sp,192
    80006c42:	8082                	ret
      end_op();
    80006c44:	fffff097          	auipc	ra,0xfffff
    80006c48:	93c080e7          	jalr	-1732(ra) # 80005580 <end_op>
      return -1;
    80006c4c:	b7e5                	j	80006c34 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80006c4e:	f5040513          	addi	a0,s0,-176
    80006c52:	ffffe097          	auipc	ra,0xffffe
    80006c56:	68e080e7          	jalr	1678(ra) # 800052e0 <namei>
    80006c5a:	892a                	mv	s2,a0
    80006c5c:	c905                	beqz	a0,80006c8c <sys_open+0x13c>
    ilock(ip);
    80006c5e:	ffffe097          	auipc	ra,0xffffe
    80006c62:	ece080e7          	jalr	-306(ra) # 80004b2c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80006c66:	04491703          	lh	a4,68(s2)
    80006c6a:	4785                	li	a5,1
    80006c6c:	f4f712e3          	bne	a4,a5,80006bb0 <sys_open+0x60>
    80006c70:	f4c42783          	lw	a5,-180(s0)
    80006c74:	dba1                	beqz	a5,80006bc4 <sys_open+0x74>
      iunlockput(ip);
    80006c76:	854a                	mv	a0,s2
    80006c78:	ffffe097          	auipc	ra,0xffffe
    80006c7c:	116080e7          	jalr	278(ra) # 80004d8e <iunlockput>
      end_op();
    80006c80:	fffff097          	auipc	ra,0xfffff
    80006c84:	900080e7          	jalr	-1792(ra) # 80005580 <end_op>
      return -1;
    80006c88:	54fd                	li	s1,-1
    80006c8a:	b76d                	j	80006c34 <sys_open+0xe4>
      end_op();
    80006c8c:	fffff097          	auipc	ra,0xfffff
    80006c90:	8f4080e7          	jalr	-1804(ra) # 80005580 <end_op>
      return -1;
    80006c94:	54fd                	li	s1,-1
    80006c96:	bf79                	j	80006c34 <sys_open+0xe4>
    iunlockput(ip);
    80006c98:	854a                	mv	a0,s2
    80006c9a:	ffffe097          	auipc	ra,0xffffe
    80006c9e:	0f4080e7          	jalr	244(ra) # 80004d8e <iunlockput>
    end_op();
    80006ca2:	fffff097          	auipc	ra,0xfffff
    80006ca6:	8de080e7          	jalr	-1826(ra) # 80005580 <end_op>
    return -1;
    80006caa:	54fd                	li	s1,-1
    80006cac:	b761                	j	80006c34 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80006cae:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80006cb2:	04691783          	lh	a5,70(s2)
    80006cb6:	02f99223          	sh	a5,36(s3)
    80006cba:	bf2d                	j	80006bf4 <sys_open+0xa4>
    itrunc(ip);
    80006cbc:	854a                	mv	a0,s2
    80006cbe:	ffffe097          	auipc	ra,0xffffe
    80006cc2:	f7c080e7          	jalr	-132(ra) # 80004c3a <itrunc>
    80006cc6:	bfb1                	j	80006c22 <sys_open+0xd2>
      fileclose(f);
    80006cc8:	854e                	mv	a0,s3
    80006cca:	fffff097          	auipc	ra,0xfffff
    80006cce:	d02080e7          	jalr	-766(ra) # 800059cc <fileclose>
    iunlockput(ip);
    80006cd2:	854a                	mv	a0,s2
    80006cd4:	ffffe097          	auipc	ra,0xffffe
    80006cd8:	0ba080e7          	jalr	186(ra) # 80004d8e <iunlockput>
    end_op();
    80006cdc:	fffff097          	auipc	ra,0xfffff
    80006ce0:	8a4080e7          	jalr	-1884(ra) # 80005580 <end_op>
    return -1;
    80006ce4:	54fd                	li	s1,-1
    80006ce6:	b7b9                	j	80006c34 <sys_open+0xe4>

0000000080006ce8 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006ce8:	7175                	addi	sp,sp,-144
    80006cea:	e506                	sd	ra,136(sp)
    80006cec:	e122                	sd	s0,128(sp)
    80006cee:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006cf0:	fffff097          	auipc	ra,0xfffff
    80006cf4:	810080e7          	jalr	-2032(ra) # 80005500 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006cf8:	08000613          	li	a2,128
    80006cfc:	f7040593          	addi	a1,s0,-144
    80006d00:	4501                	li	a0,0
    80006d02:	ffffd097          	auipc	ra,0xffffd
    80006d06:	070080e7          	jalr	112(ra) # 80003d72 <argstr>
    80006d0a:	02054963          	bltz	a0,80006d3c <sys_mkdir+0x54>
    80006d0e:	4681                	li	a3,0
    80006d10:	4601                	li	a2,0
    80006d12:	4585                	li	a1,1
    80006d14:	f7040513          	addi	a0,s0,-144
    80006d18:	00000097          	auipc	ra,0x0
    80006d1c:	800080e7          	jalr	-2048(ra) # 80006518 <create>
    80006d20:	cd11                	beqz	a0,80006d3c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006d22:	ffffe097          	auipc	ra,0xffffe
    80006d26:	06c080e7          	jalr	108(ra) # 80004d8e <iunlockput>
  end_op();
    80006d2a:	fffff097          	auipc	ra,0xfffff
    80006d2e:	856080e7          	jalr	-1962(ra) # 80005580 <end_op>
  return 0;
    80006d32:	4501                	li	a0,0
}
    80006d34:	60aa                	ld	ra,136(sp)
    80006d36:	640a                	ld	s0,128(sp)
    80006d38:	6149                	addi	sp,sp,144
    80006d3a:	8082                	ret
    end_op();
    80006d3c:	fffff097          	auipc	ra,0xfffff
    80006d40:	844080e7          	jalr	-1980(ra) # 80005580 <end_op>
    return -1;
    80006d44:	557d                	li	a0,-1
    80006d46:	b7fd                	j	80006d34 <sys_mkdir+0x4c>

0000000080006d48 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006d48:	7135                	addi	sp,sp,-160
    80006d4a:	ed06                	sd	ra,152(sp)
    80006d4c:	e922                	sd	s0,144(sp)
    80006d4e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006d50:	ffffe097          	auipc	ra,0xffffe
    80006d54:	7b0080e7          	jalr	1968(ra) # 80005500 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006d58:	08000613          	li	a2,128
    80006d5c:	f7040593          	addi	a1,s0,-144
    80006d60:	4501                	li	a0,0
    80006d62:	ffffd097          	auipc	ra,0xffffd
    80006d66:	010080e7          	jalr	16(ra) # 80003d72 <argstr>
    80006d6a:	04054a63          	bltz	a0,80006dbe <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80006d6e:	f6c40593          	addi	a1,s0,-148
    80006d72:	4505                	li	a0,1
    80006d74:	ffffd097          	auipc	ra,0xffffd
    80006d78:	fba080e7          	jalr	-70(ra) # 80003d2e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006d7c:	04054163          	bltz	a0,80006dbe <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80006d80:	f6840593          	addi	a1,s0,-152
    80006d84:	4509                	li	a0,2
    80006d86:	ffffd097          	auipc	ra,0xffffd
    80006d8a:	fa8080e7          	jalr	-88(ra) # 80003d2e <argint>
     argint(1, &major) < 0 ||
    80006d8e:	02054863          	bltz	a0,80006dbe <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006d92:	f6841683          	lh	a3,-152(s0)
    80006d96:	f6c41603          	lh	a2,-148(s0)
    80006d9a:	458d                	li	a1,3
    80006d9c:	f7040513          	addi	a0,s0,-144
    80006da0:	fffff097          	auipc	ra,0xfffff
    80006da4:	778080e7          	jalr	1912(ra) # 80006518 <create>
     argint(2, &minor) < 0 ||
    80006da8:	c919                	beqz	a0,80006dbe <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006daa:	ffffe097          	auipc	ra,0xffffe
    80006dae:	fe4080e7          	jalr	-28(ra) # 80004d8e <iunlockput>
  end_op();
    80006db2:	ffffe097          	auipc	ra,0xffffe
    80006db6:	7ce080e7          	jalr	1998(ra) # 80005580 <end_op>
  return 0;
    80006dba:	4501                	li	a0,0
    80006dbc:	a031                	j	80006dc8 <sys_mknod+0x80>
    end_op();
    80006dbe:	ffffe097          	auipc	ra,0xffffe
    80006dc2:	7c2080e7          	jalr	1986(ra) # 80005580 <end_op>
    return -1;
    80006dc6:	557d                	li	a0,-1
}
    80006dc8:	60ea                	ld	ra,152(sp)
    80006dca:	644a                	ld	s0,144(sp)
    80006dcc:	610d                	addi	sp,sp,160
    80006dce:	8082                	ret

0000000080006dd0 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006dd0:	7135                	addi	sp,sp,-160
    80006dd2:	ed06                	sd	ra,152(sp)
    80006dd4:	e922                	sd	s0,144(sp)
    80006dd6:	e526                	sd	s1,136(sp)
    80006dd8:	e14a                	sd	s2,128(sp)
    80006dda:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006ddc:	ffffb097          	auipc	ra,0xffffb
    80006de0:	fa2080e7          	jalr	-94(ra) # 80001d7e <myproc>
    80006de4:	892a                	mv	s2,a0
  
  begin_op();
    80006de6:	ffffe097          	auipc	ra,0xffffe
    80006dea:	71a080e7          	jalr	1818(ra) # 80005500 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006dee:	08000613          	li	a2,128
    80006df2:	f6040593          	addi	a1,s0,-160
    80006df6:	4501                	li	a0,0
    80006df8:	ffffd097          	auipc	ra,0xffffd
    80006dfc:	f7a080e7          	jalr	-134(ra) # 80003d72 <argstr>
    80006e00:	04054b63          	bltz	a0,80006e56 <sys_chdir+0x86>
    80006e04:	f6040513          	addi	a0,s0,-160
    80006e08:	ffffe097          	auipc	ra,0xffffe
    80006e0c:	4d8080e7          	jalr	1240(ra) # 800052e0 <namei>
    80006e10:	84aa                	mv	s1,a0
    80006e12:	c131                	beqz	a0,80006e56 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006e14:	ffffe097          	auipc	ra,0xffffe
    80006e18:	d18080e7          	jalr	-744(ra) # 80004b2c <ilock>
  if(ip->type != T_DIR){
    80006e1c:	04449703          	lh	a4,68(s1)
    80006e20:	4785                	li	a5,1
    80006e22:	04f71063          	bne	a4,a5,80006e62 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006e26:	8526                	mv	a0,s1
    80006e28:	ffffe097          	auipc	ra,0xffffe
    80006e2c:	dc6080e7          	jalr	-570(ra) # 80004bee <iunlock>
  iput(p->cwd);
    80006e30:	0d093503          	ld	a0,208(s2)
    80006e34:	ffffe097          	auipc	ra,0xffffe
    80006e38:	eb2080e7          	jalr	-334(ra) # 80004ce6 <iput>
  end_op();
    80006e3c:	ffffe097          	auipc	ra,0xffffe
    80006e40:	744080e7          	jalr	1860(ra) # 80005580 <end_op>
  p->cwd = ip;
    80006e44:	0c993823          	sd	s1,208(s2)
  return 0;
    80006e48:	4501                	li	a0,0
}
    80006e4a:	60ea                	ld	ra,152(sp)
    80006e4c:	644a                	ld	s0,144(sp)
    80006e4e:	64aa                	ld	s1,136(sp)
    80006e50:	690a                	ld	s2,128(sp)
    80006e52:	610d                	addi	sp,sp,160
    80006e54:	8082                	ret
    end_op();
    80006e56:	ffffe097          	auipc	ra,0xffffe
    80006e5a:	72a080e7          	jalr	1834(ra) # 80005580 <end_op>
    return -1;
    80006e5e:	557d                	li	a0,-1
    80006e60:	b7ed                	j	80006e4a <sys_chdir+0x7a>
    iunlockput(ip);
    80006e62:	8526                	mv	a0,s1
    80006e64:	ffffe097          	auipc	ra,0xffffe
    80006e68:	f2a080e7          	jalr	-214(ra) # 80004d8e <iunlockput>
    end_op();
    80006e6c:	ffffe097          	auipc	ra,0xffffe
    80006e70:	714080e7          	jalr	1812(ra) # 80005580 <end_op>
    return -1;
    80006e74:	557d                	li	a0,-1
    80006e76:	bfd1                	j	80006e4a <sys_chdir+0x7a>

0000000080006e78 <sys_exec>:

uint64
sys_exec(void)
{
    80006e78:	7145                	addi	sp,sp,-464
    80006e7a:	e786                	sd	ra,456(sp)
    80006e7c:	e3a2                	sd	s0,448(sp)
    80006e7e:	ff26                	sd	s1,440(sp)
    80006e80:	fb4a                	sd	s2,432(sp)
    80006e82:	f74e                	sd	s3,424(sp)
    80006e84:	f352                	sd	s4,416(sp)
    80006e86:	ef56                	sd	s5,408(sp)
    80006e88:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006e8a:	08000613          	li	a2,128
    80006e8e:	f4040593          	addi	a1,s0,-192
    80006e92:	4501                	li	a0,0
    80006e94:	ffffd097          	auipc	ra,0xffffd
    80006e98:	ede080e7          	jalr	-290(ra) # 80003d72 <argstr>
    return -1;
    80006e9c:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006e9e:	0c054a63          	bltz	a0,80006f72 <sys_exec+0xfa>
    80006ea2:	e3840593          	addi	a1,s0,-456
    80006ea6:	4505                	li	a0,1
    80006ea8:	ffffd097          	auipc	ra,0xffffd
    80006eac:	ea8080e7          	jalr	-344(ra) # 80003d50 <argaddr>
    80006eb0:	0c054163          	bltz	a0,80006f72 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006eb4:	10000613          	li	a2,256
    80006eb8:	4581                	li	a1,0
    80006eba:	e4040513          	addi	a0,s0,-448
    80006ebe:	ffffa097          	auipc	ra,0xffffa
    80006ec2:	120080e7          	jalr	288(ra) # 80000fde <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006ec6:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006eca:	89a6                	mv	s3,s1
    80006ecc:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006ece:	02000a13          	li	s4,32
    80006ed2:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006ed6:	00391793          	slli	a5,s2,0x3
    80006eda:	e3040593          	addi	a1,s0,-464
    80006ede:	e3843503          	ld	a0,-456(s0)
    80006ee2:	953e                	add	a0,a0,a5
    80006ee4:	ffffd097          	auipc	ra,0xffffd
    80006ee8:	db0080e7          	jalr	-592(ra) # 80003c94 <fetchaddr>
    80006eec:	02054a63          	bltz	a0,80006f20 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006ef0:	e3043783          	ld	a5,-464(s0)
    80006ef4:	c3b9                	beqz	a5,80006f3a <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006ef6:	ffffa097          	auipc	ra,0xffffa
    80006efa:	be0080e7          	jalr	-1056(ra) # 80000ad6 <kalloc>
    80006efe:	85aa                	mv	a1,a0
    80006f00:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006f04:	cd11                	beqz	a0,80006f20 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006f06:	6605                	lui	a2,0x1
    80006f08:	e3043503          	ld	a0,-464(s0)
    80006f0c:	ffffd097          	auipc	ra,0xffffd
    80006f10:	dda080e7          	jalr	-550(ra) # 80003ce6 <fetchstr>
    80006f14:	00054663          	bltz	a0,80006f20 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006f18:	0905                	addi	s2,s2,1
    80006f1a:	09a1                	addi	s3,s3,8
    80006f1c:	fb491be3          	bne	s2,s4,80006ed2 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006f20:	10048913          	addi	s2,s1,256
    80006f24:	6088                	ld	a0,0(s1)
    80006f26:	c529                	beqz	a0,80006f70 <sys_exec+0xf8>
    kfree(argv[i]);
    80006f28:	ffffa097          	auipc	ra,0xffffa
    80006f2c:	ab2080e7          	jalr	-1358(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006f30:	04a1                	addi	s1,s1,8
    80006f32:	ff2499e3          	bne	s1,s2,80006f24 <sys_exec+0xac>
  return -1;
    80006f36:	597d                	li	s2,-1
    80006f38:	a82d                	j	80006f72 <sys_exec+0xfa>
      argv[i] = 0;
    80006f3a:	0a8e                	slli	s5,s5,0x3
    80006f3c:	fc040793          	addi	a5,s0,-64
    80006f40:	9abe                	add	s5,s5,a5
    80006f42:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006f46:	e4040593          	addi	a1,s0,-448
    80006f4a:	f4040513          	addi	a0,s0,-192
    80006f4e:	fffff097          	auipc	ra,0xfffff
    80006f52:	0dc080e7          	jalr	220(ra) # 8000602a <exec>
    80006f56:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006f58:	10048993          	addi	s3,s1,256
    80006f5c:	6088                	ld	a0,0(s1)
    80006f5e:	c911                	beqz	a0,80006f72 <sys_exec+0xfa>
    kfree(argv[i]);
    80006f60:	ffffa097          	auipc	ra,0xffffa
    80006f64:	a7a080e7          	jalr	-1414(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006f68:	04a1                	addi	s1,s1,8
    80006f6a:	ff3499e3          	bne	s1,s3,80006f5c <sys_exec+0xe4>
    80006f6e:	a011                	j	80006f72 <sys_exec+0xfa>
  return -1;
    80006f70:	597d                	li	s2,-1
}
    80006f72:	854a                	mv	a0,s2
    80006f74:	60be                	ld	ra,456(sp)
    80006f76:	641e                	ld	s0,448(sp)
    80006f78:	74fa                	ld	s1,440(sp)
    80006f7a:	795a                	ld	s2,432(sp)
    80006f7c:	79ba                	ld	s3,424(sp)
    80006f7e:	7a1a                	ld	s4,416(sp)
    80006f80:	6afa                	ld	s5,408(sp)
    80006f82:	6179                	addi	sp,sp,464
    80006f84:	8082                	ret

0000000080006f86 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006f86:	7139                	addi	sp,sp,-64
    80006f88:	fc06                	sd	ra,56(sp)
    80006f8a:	f822                	sd	s0,48(sp)
    80006f8c:	f426                	sd	s1,40(sp)
    80006f8e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006f90:	ffffb097          	auipc	ra,0xffffb
    80006f94:	dee080e7          	jalr	-530(ra) # 80001d7e <myproc>
    80006f98:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006f9a:	fd840593          	addi	a1,s0,-40
    80006f9e:	4501                	li	a0,0
    80006fa0:	ffffd097          	auipc	ra,0xffffd
    80006fa4:	db0080e7          	jalr	-592(ra) # 80003d50 <argaddr>
    return -1;
    80006fa8:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006faa:	0e054063          	bltz	a0,8000708a <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006fae:	fc840593          	addi	a1,s0,-56
    80006fb2:	fd040513          	addi	a0,s0,-48
    80006fb6:	fffff097          	auipc	ra,0xfffff
    80006fba:	d46080e7          	jalr	-698(ra) # 80005cfc <pipealloc>
    return -1;
    80006fbe:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006fc0:	0c054563          	bltz	a0,8000708a <sys_pipe+0x104>
  fd0 = -1;
    80006fc4:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006fc8:	fd043503          	ld	a0,-48(s0)
    80006fcc:	fffff097          	auipc	ra,0xfffff
    80006fd0:	50a080e7          	jalr	1290(ra) # 800064d6 <fdalloc>
    80006fd4:	fca42223          	sw	a0,-60(s0)
    80006fd8:	08054c63          	bltz	a0,80007070 <sys_pipe+0xea>
    80006fdc:	fc843503          	ld	a0,-56(s0)
    80006fe0:	fffff097          	auipc	ra,0xfffff
    80006fe4:	4f6080e7          	jalr	1270(ra) # 800064d6 <fdalloc>
    80006fe8:	fca42023          	sw	a0,-64(s0)
    80006fec:	06054863          	bltz	a0,8000705c <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006ff0:	4691                	li	a3,4
    80006ff2:	fc440613          	addi	a2,s0,-60
    80006ff6:	fd843583          	ld	a1,-40(s0)
    80006ffa:	60a8                	ld	a0,64(s1)
    80006ffc:	ffffb097          	auipc	ra,0xffffb
    80007000:	96a080e7          	jalr	-1686(ra) # 80001966 <copyout>
    80007004:	02054063          	bltz	a0,80007024 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80007008:	4691                	li	a3,4
    8000700a:	fc040613          	addi	a2,s0,-64
    8000700e:	fd843583          	ld	a1,-40(s0)
    80007012:	0591                	addi	a1,a1,4
    80007014:	60a8                	ld	a0,64(s1)
    80007016:	ffffb097          	auipc	ra,0xffffb
    8000701a:	950080e7          	jalr	-1712(ra) # 80001966 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000701e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80007020:	06055563          	bgez	a0,8000708a <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80007024:	fc442783          	lw	a5,-60(s0)
    80007028:	07a9                	addi	a5,a5,10
    8000702a:	078e                	slli	a5,a5,0x3
    8000702c:	97a6                	add	a5,a5,s1
    8000702e:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80007032:	fc042503          	lw	a0,-64(s0)
    80007036:	0529                	addi	a0,a0,10
    80007038:	050e                	slli	a0,a0,0x3
    8000703a:	9526                	add	a0,a0,s1
    8000703c:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80007040:	fd043503          	ld	a0,-48(s0)
    80007044:	fffff097          	auipc	ra,0xfffff
    80007048:	988080e7          	jalr	-1656(ra) # 800059cc <fileclose>
    fileclose(wf);
    8000704c:	fc843503          	ld	a0,-56(s0)
    80007050:	fffff097          	auipc	ra,0xfffff
    80007054:	97c080e7          	jalr	-1668(ra) # 800059cc <fileclose>
    return -1;
    80007058:	57fd                	li	a5,-1
    8000705a:	a805                	j	8000708a <sys_pipe+0x104>
    if(fd0 >= 0)
    8000705c:	fc442783          	lw	a5,-60(s0)
    80007060:	0007c863          	bltz	a5,80007070 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80007064:	00a78513          	addi	a0,a5,10
    80007068:	050e                	slli	a0,a0,0x3
    8000706a:	9526                	add	a0,a0,s1
    8000706c:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80007070:	fd043503          	ld	a0,-48(s0)
    80007074:	fffff097          	auipc	ra,0xfffff
    80007078:	958080e7          	jalr	-1704(ra) # 800059cc <fileclose>
    fileclose(wf);
    8000707c:	fc843503          	ld	a0,-56(s0)
    80007080:	fffff097          	auipc	ra,0xfffff
    80007084:	94c080e7          	jalr	-1716(ra) # 800059cc <fileclose>
    return -1;
    80007088:	57fd                	li	a5,-1
}
    8000708a:	853e                	mv	a0,a5
    8000708c:	70e2                	ld	ra,56(sp)
    8000708e:	7442                	ld	s0,48(sp)
    80007090:	74a2                	ld	s1,40(sp)
    80007092:	6121                	addi	sp,sp,64
    80007094:	8082                	ret
	...

00000000800070a0 <kernelvec>:
    800070a0:	7111                	addi	sp,sp,-256
    800070a2:	e006                	sd	ra,0(sp)
    800070a4:	e40a                	sd	sp,8(sp)
    800070a6:	e80e                	sd	gp,16(sp)
    800070a8:	ec12                	sd	tp,24(sp)
    800070aa:	f016                	sd	t0,32(sp)
    800070ac:	f41a                	sd	t1,40(sp)
    800070ae:	f81e                	sd	t2,48(sp)
    800070b0:	fc22                	sd	s0,56(sp)
    800070b2:	e0a6                	sd	s1,64(sp)
    800070b4:	e4aa                	sd	a0,72(sp)
    800070b6:	e8ae                	sd	a1,80(sp)
    800070b8:	ecb2                	sd	a2,88(sp)
    800070ba:	f0b6                	sd	a3,96(sp)
    800070bc:	f4ba                	sd	a4,104(sp)
    800070be:	f8be                	sd	a5,112(sp)
    800070c0:	fcc2                	sd	a6,120(sp)
    800070c2:	e146                	sd	a7,128(sp)
    800070c4:	e54a                	sd	s2,136(sp)
    800070c6:	e94e                	sd	s3,144(sp)
    800070c8:	ed52                	sd	s4,152(sp)
    800070ca:	f156                	sd	s5,160(sp)
    800070cc:	f55a                	sd	s6,168(sp)
    800070ce:	f95e                	sd	s7,176(sp)
    800070d0:	fd62                	sd	s8,184(sp)
    800070d2:	e1e6                	sd	s9,192(sp)
    800070d4:	e5ea                	sd	s10,200(sp)
    800070d6:	e9ee                	sd	s11,208(sp)
    800070d8:	edf2                	sd	t3,216(sp)
    800070da:	f1f6                	sd	t4,224(sp)
    800070dc:	f5fa                	sd	t5,232(sp)
    800070de:	f9fe                	sd	t6,240(sp)
    800070e0:	a5dfc0ef          	jal	ra,80003b3c <kerneltrap>
    800070e4:	6082                	ld	ra,0(sp)
    800070e6:	6122                	ld	sp,8(sp)
    800070e8:	61c2                	ld	gp,16(sp)
    800070ea:	7282                	ld	t0,32(sp)
    800070ec:	7322                	ld	t1,40(sp)
    800070ee:	73c2                	ld	t2,48(sp)
    800070f0:	7462                	ld	s0,56(sp)
    800070f2:	6486                	ld	s1,64(sp)
    800070f4:	6526                	ld	a0,72(sp)
    800070f6:	65c6                	ld	a1,80(sp)
    800070f8:	6666                	ld	a2,88(sp)
    800070fa:	7686                	ld	a3,96(sp)
    800070fc:	7726                	ld	a4,104(sp)
    800070fe:	77c6                	ld	a5,112(sp)
    80007100:	7866                	ld	a6,120(sp)
    80007102:	688a                	ld	a7,128(sp)
    80007104:	692a                	ld	s2,136(sp)
    80007106:	69ca                	ld	s3,144(sp)
    80007108:	6a6a                	ld	s4,152(sp)
    8000710a:	7a8a                	ld	s5,160(sp)
    8000710c:	7b2a                	ld	s6,168(sp)
    8000710e:	7bca                	ld	s7,176(sp)
    80007110:	7c6a                	ld	s8,184(sp)
    80007112:	6c8e                	ld	s9,192(sp)
    80007114:	6d2e                	ld	s10,200(sp)
    80007116:	6dce                	ld	s11,208(sp)
    80007118:	6e6e                	ld	t3,216(sp)
    8000711a:	7e8e                	ld	t4,224(sp)
    8000711c:	7f2e                	ld	t5,232(sp)
    8000711e:	7fce                	ld	t6,240(sp)
    80007120:	6111                	addi	sp,sp,256
    80007122:	10200073          	sret
    80007126:	00000013          	nop
    8000712a:	00000013          	nop
    8000712e:	0001                	nop

0000000080007130 <timervec>:
    80007130:	34051573          	csrrw	a0,mscratch,a0
    80007134:	e10c                	sd	a1,0(a0)
    80007136:	e510                	sd	a2,8(a0)
    80007138:	e914                	sd	a3,16(a0)
    8000713a:	6d0c                	ld	a1,24(a0)
    8000713c:	7110                	ld	a2,32(a0)
    8000713e:	6194                	ld	a3,0(a1)
    80007140:	96b2                	add	a3,a3,a2
    80007142:	e194                	sd	a3,0(a1)
    80007144:	4589                	li	a1,2
    80007146:	14459073          	csrw	sip,a1
    8000714a:	6914                	ld	a3,16(a0)
    8000714c:	6510                	ld	a2,8(a0)
    8000714e:	610c                	ld	a1,0(a0)
    80007150:	34051573          	csrrw	a0,mscratch,a0
    80007154:	30200073          	mret
	...

000000008000715a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000715a:	1141                	addi	sp,sp,-16
    8000715c:	e422                	sd	s0,8(sp)
    8000715e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80007160:	0c0007b7          	lui	a5,0xc000
    80007164:	4705                	li	a4,1
    80007166:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80007168:	c3d8                	sw	a4,4(a5)
}
    8000716a:	6422                	ld	s0,8(sp)
    8000716c:	0141                	addi	sp,sp,16
    8000716e:	8082                	ret

0000000080007170 <plicinithart>:

void
plicinithart(void)
{
    80007170:	1141                	addi	sp,sp,-16
    80007172:	e406                	sd	ra,8(sp)
    80007174:	e022                	sd	s0,0(sp)
    80007176:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80007178:	ffffb097          	auipc	ra,0xffffb
    8000717c:	bd2080e7          	jalr	-1070(ra) # 80001d4a <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80007180:	0085171b          	slliw	a4,a0,0x8
    80007184:	0c0027b7          	lui	a5,0xc002
    80007188:	97ba                	add	a5,a5,a4
    8000718a:	40200713          	li	a4,1026
    8000718e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80007192:	00d5151b          	slliw	a0,a0,0xd
    80007196:	0c2017b7          	lui	a5,0xc201
    8000719a:	953e                	add	a0,a0,a5
    8000719c:	00052023          	sw	zero,0(a0)
}
    800071a0:	60a2                	ld	ra,8(sp)
    800071a2:	6402                	ld	s0,0(sp)
    800071a4:	0141                	addi	sp,sp,16
    800071a6:	8082                	ret

00000000800071a8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800071a8:	1141                	addi	sp,sp,-16
    800071aa:	e406                	sd	ra,8(sp)
    800071ac:	e022                	sd	s0,0(sp)
    800071ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800071b0:	ffffb097          	auipc	ra,0xffffb
    800071b4:	b9a080e7          	jalr	-1126(ra) # 80001d4a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800071b8:	00d5179b          	slliw	a5,a0,0xd
    800071bc:	0c201537          	lui	a0,0xc201
    800071c0:	953e                	add	a0,a0,a5
  return irq;
}
    800071c2:	4148                	lw	a0,4(a0)
    800071c4:	60a2                	ld	ra,8(sp)
    800071c6:	6402                	ld	s0,0(sp)
    800071c8:	0141                	addi	sp,sp,16
    800071ca:	8082                	ret

00000000800071cc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800071cc:	1101                	addi	sp,sp,-32
    800071ce:	ec06                	sd	ra,24(sp)
    800071d0:	e822                	sd	s0,16(sp)
    800071d2:	e426                	sd	s1,8(sp)
    800071d4:	1000                	addi	s0,sp,32
    800071d6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800071d8:	ffffb097          	auipc	ra,0xffffb
    800071dc:	b72080e7          	jalr	-1166(ra) # 80001d4a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800071e0:	00d5151b          	slliw	a0,a0,0xd
    800071e4:	0c2017b7          	lui	a5,0xc201
    800071e8:	97aa                	add	a5,a5,a0
    800071ea:	c3c4                	sw	s1,4(a5)
}
    800071ec:	60e2                	ld	ra,24(sp)
    800071ee:	6442                	ld	s0,16(sp)
    800071f0:	64a2                	ld	s1,8(sp)
    800071f2:	6105                	addi	sp,sp,32
    800071f4:	8082                	ret

00000000800071f6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800071f6:	1141                	addi	sp,sp,-16
    800071f8:	e406                	sd	ra,8(sp)
    800071fa:	e022                	sd	s0,0(sp)
    800071fc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800071fe:	479d                	li	a5,7
    80007200:	06a7c963          	blt	a5,a0,80007272 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80007204:	00039797          	auipc	a5,0x39
    80007208:	dfc78793          	addi	a5,a5,-516 # 80040000 <disk>
    8000720c:	00a78733          	add	a4,a5,a0
    80007210:	6789                	lui	a5,0x2
    80007212:	97ba                	add	a5,a5,a4
    80007214:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80007218:	e7ad                	bnez	a5,80007282 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000721a:	00451793          	slli	a5,a0,0x4
    8000721e:	0003b717          	auipc	a4,0x3b
    80007222:	de270713          	addi	a4,a4,-542 # 80042000 <disk+0x2000>
    80007226:	6314                	ld	a3,0(a4)
    80007228:	96be                	add	a3,a3,a5
    8000722a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000722e:	6314                	ld	a3,0(a4)
    80007230:	96be                	add	a3,a3,a5
    80007232:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80007236:	6314                	ld	a3,0(a4)
    80007238:	96be                	add	a3,a3,a5
    8000723a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000723e:	6318                	ld	a4,0(a4)
    80007240:	97ba                	add	a5,a5,a4
    80007242:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80007246:	00039797          	auipc	a5,0x39
    8000724a:	dba78793          	addi	a5,a5,-582 # 80040000 <disk>
    8000724e:	97aa                	add	a5,a5,a0
    80007250:	6509                	lui	a0,0x2
    80007252:	953e                	add	a0,a0,a5
    80007254:	4785                	li	a5,1
    80007256:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000725a:	0003b517          	auipc	a0,0x3b
    8000725e:	dbe50513          	addi	a0,a0,-578 # 80042018 <disk+0x2018>
    80007262:	ffffb097          	auipc	ra,0xffffb
    80007266:	61c080e7          	jalr	1564(ra) # 8000287e <wakeup>
}
    8000726a:	60a2                	ld	ra,8(sp)
    8000726c:	6402                	ld	s0,0(sp)
    8000726e:	0141                	addi	sp,sp,16
    80007270:	8082                	ret
    panic("free_desc 1");
    80007272:	00002517          	auipc	a0,0x2
    80007276:	72e50513          	addi	a0,a0,1838 # 800099a0 <syscalls+0x378>
    8000727a:	ffff9097          	auipc	ra,0xffff9
    8000727e:	2b4080e7          	jalr	692(ra) # 8000052e <panic>
    panic("free_desc 2");
    80007282:	00002517          	auipc	a0,0x2
    80007286:	72e50513          	addi	a0,a0,1838 # 800099b0 <syscalls+0x388>
    8000728a:	ffff9097          	auipc	ra,0xffff9
    8000728e:	2a4080e7          	jalr	676(ra) # 8000052e <panic>

0000000080007292 <virtio_disk_init>:
{
    80007292:	1101                	addi	sp,sp,-32
    80007294:	ec06                	sd	ra,24(sp)
    80007296:	e822                	sd	s0,16(sp)
    80007298:	e426                	sd	s1,8(sp)
    8000729a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000729c:	00002597          	auipc	a1,0x2
    800072a0:	72458593          	addi	a1,a1,1828 # 800099c0 <syscalls+0x398>
    800072a4:	0003b517          	auipc	a0,0x3b
    800072a8:	e8450513          	addi	a0,a0,-380 # 80042128 <disk+0x2128>
    800072ac:	ffffa097          	auipc	ra,0xffffa
    800072b0:	88a080e7          	jalr	-1910(ra) # 80000b36 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800072b4:	100017b7          	lui	a5,0x10001
    800072b8:	4398                	lw	a4,0(a5)
    800072ba:	2701                	sext.w	a4,a4
    800072bc:	747277b7          	lui	a5,0x74727
    800072c0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800072c4:	0ef71163          	bne	a4,a5,800073a6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800072c8:	100017b7          	lui	a5,0x10001
    800072cc:	43dc                	lw	a5,4(a5)
    800072ce:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800072d0:	4705                	li	a4,1
    800072d2:	0ce79a63          	bne	a5,a4,800073a6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800072d6:	100017b7          	lui	a5,0x10001
    800072da:	479c                	lw	a5,8(a5)
    800072dc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800072de:	4709                	li	a4,2
    800072e0:	0ce79363          	bne	a5,a4,800073a6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800072e4:	100017b7          	lui	a5,0x10001
    800072e8:	47d8                	lw	a4,12(a5)
    800072ea:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800072ec:	554d47b7          	lui	a5,0x554d4
    800072f0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800072f4:	0af71963          	bne	a4,a5,800073a6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800072f8:	100017b7          	lui	a5,0x10001
    800072fc:	4705                	li	a4,1
    800072fe:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007300:	470d                	li	a4,3
    80007302:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80007304:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80007306:	c7ffe737          	lui	a4,0xc7ffe
    8000730a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fbb75f>
    8000730e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80007310:	2701                	sext.w	a4,a4
    80007312:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007314:	472d                	li	a4,11
    80007316:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80007318:	473d                	li	a4,15
    8000731a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    8000731c:	6705                	lui	a4,0x1
    8000731e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80007320:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80007324:	5bdc                	lw	a5,52(a5)
    80007326:	2781                	sext.w	a5,a5
  if(max == 0)
    80007328:	c7d9                	beqz	a5,800073b6 <virtio_disk_init+0x124>
  if(max < NUM)
    8000732a:	471d                	li	a4,7
    8000732c:	08f77d63          	bgeu	a4,a5,800073c6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80007330:	100014b7          	lui	s1,0x10001
    80007334:	47a1                	li	a5,8
    80007336:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80007338:	6609                	lui	a2,0x2
    8000733a:	4581                	li	a1,0
    8000733c:	00039517          	auipc	a0,0x39
    80007340:	cc450513          	addi	a0,a0,-828 # 80040000 <disk>
    80007344:	ffffa097          	auipc	ra,0xffffa
    80007348:	c9a080e7          	jalr	-870(ra) # 80000fde <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000734c:	00039717          	auipc	a4,0x39
    80007350:	cb470713          	addi	a4,a4,-844 # 80040000 <disk>
    80007354:	00c75793          	srli	a5,a4,0xc
    80007358:	2781                	sext.w	a5,a5
    8000735a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000735c:	0003b797          	auipc	a5,0x3b
    80007360:	ca478793          	addi	a5,a5,-860 # 80042000 <disk+0x2000>
    80007364:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80007366:	00039717          	auipc	a4,0x39
    8000736a:	d1a70713          	addi	a4,a4,-742 # 80040080 <disk+0x80>
    8000736e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80007370:	0003a717          	auipc	a4,0x3a
    80007374:	c9070713          	addi	a4,a4,-880 # 80041000 <disk+0x1000>
    80007378:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000737a:	4705                	li	a4,1
    8000737c:	00e78c23          	sb	a4,24(a5)
    80007380:	00e78ca3          	sb	a4,25(a5)
    80007384:	00e78d23          	sb	a4,26(a5)
    80007388:	00e78da3          	sb	a4,27(a5)
    8000738c:	00e78e23          	sb	a4,28(a5)
    80007390:	00e78ea3          	sb	a4,29(a5)
    80007394:	00e78f23          	sb	a4,30(a5)
    80007398:	00e78fa3          	sb	a4,31(a5)
}
    8000739c:	60e2                	ld	ra,24(sp)
    8000739e:	6442                	ld	s0,16(sp)
    800073a0:	64a2                	ld	s1,8(sp)
    800073a2:	6105                	addi	sp,sp,32
    800073a4:	8082                	ret
    panic("could not find virtio disk");
    800073a6:	00002517          	auipc	a0,0x2
    800073aa:	62a50513          	addi	a0,a0,1578 # 800099d0 <syscalls+0x3a8>
    800073ae:	ffff9097          	auipc	ra,0xffff9
    800073b2:	180080e7          	jalr	384(ra) # 8000052e <panic>
    panic("virtio disk has no queue 0");
    800073b6:	00002517          	auipc	a0,0x2
    800073ba:	63a50513          	addi	a0,a0,1594 # 800099f0 <syscalls+0x3c8>
    800073be:	ffff9097          	auipc	ra,0xffff9
    800073c2:	170080e7          	jalr	368(ra) # 8000052e <panic>
    panic("virtio disk max queue too short");
    800073c6:	00002517          	auipc	a0,0x2
    800073ca:	64a50513          	addi	a0,a0,1610 # 80009a10 <syscalls+0x3e8>
    800073ce:	ffff9097          	auipc	ra,0xffff9
    800073d2:	160080e7          	jalr	352(ra) # 8000052e <panic>

00000000800073d6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800073d6:	7119                	addi	sp,sp,-128
    800073d8:	fc86                	sd	ra,120(sp)
    800073da:	f8a2                	sd	s0,112(sp)
    800073dc:	f4a6                	sd	s1,104(sp)
    800073de:	f0ca                	sd	s2,96(sp)
    800073e0:	ecce                	sd	s3,88(sp)
    800073e2:	e8d2                	sd	s4,80(sp)
    800073e4:	e4d6                	sd	s5,72(sp)
    800073e6:	e0da                	sd	s6,64(sp)
    800073e8:	fc5e                	sd	s7,56(sp)
    800073ea:	f862                	sd	s8,48(sp)
    800073ec:	f466                	sd	s9,40(sp)
    800073ee:	f06a                	sd	s10,32(sp)
    800073f0:	ec6e                	sd	s11,24(sp)
    800073f2:	0100                	addi	s0,sp,128
    800073f4:	8aaa                	mv	s5,a0
    800073f6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800073f8:	00c52c83          	lw	s9,12(a0)
    800073fc:	001c9c9b          	slliw	s9,s9,0x1
    80007400:	1c82                	slli	s9,s9,0x20
    80007402:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80007406:	0003b517          	auipc	a0,0x3b
    8000740a:	d2250513          	addi	a0,a0,-734 # 80042128 <disk+0x2128>
    8000740e:	ffff9097          	auipc	ra,0xffff9
    80007412:	7fa080e7          	jalr	2042(ra) # 80000c08 <acquire>
  for(int i = 0; i < 3; i++){
    80007416:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80007418:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000741a:	00039c17          	auipc	s8,0x39
    8000741e:	be6c0c13          	addi	s8,s8,-1050 # 80040000 <disk>
    80007422:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80007424:	4b0d                	li	s6,3
    80007426:	a0ad                	j	80007490 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80007428:	00fc0733          	add	a4,s8,a5
    8000742c:	975e                	add	a4,a4,s7
    8000742e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80007432:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80007434:	0207c563          	bltz	a5,8000745e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80007438:	2905                	addiw	s2,s2,1
    8000743a:	0611                	addi	a2,a2,4
    8000743c:	19690d63          	beq	s2,s6,800075d6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80007440:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80007442:	0003b717          	auipc	a4,0x3b
    80007446:	bd670713          	addi	a4,a4,-1066 # 80042018 <disk+0x2018>
    8000744a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000744c:	00074683          	lbu	a3,0(a4)
    80007450:	fee1                	bnez	a3,80007428 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80007452:	2785                	addiw	a5,a5,1
    80007454:	0705                	addi	a4,a4,1
    80007456:	fe979be3          	bne	a5,s1,8000744c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000745a:	57fd                	li	a5,-1
    8000745c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000745e:	01205d63          	blez	s2,80007478 <virtio_disk_rw+0xa2>
    80007462:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80007464:	000a2503          	lw	a0,0(s4)
    80007468:	00000097          	auipc	ra,0x0
    8000746c:	d8e080e7          	jalr	-626(ra) # 800071f6 <free_desc>
      for(int j = 0; j < i; j++)
    80007470:	2d85                	addiw	s11,s11,1
    80007472:	0a11                	addi	s4,s4,4
    80007474:	ffb918e3          	bne	s2,s11,80007464 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80007478:	0003b597          	auipc	a1,0x3b
    8000747c:	cb058593          	addi	a1,a1,-848 # 80042128 <disk+0x2128>
    80007480:	0003b517          	auipc	a0,0x3b
    80007484:	b9850513          	addi	a0,a0,-1128 # 80042018 <disk+0x2018>
    80007488:	ffffb097          	auipc	ra,0xffffb
    8000748c:	26c080e7          	jalr	620(ra) # 800026f4 <sleep>
  for(int i = 0; i < 3; i++){
    80007490:	f8040a13          	addi	s4,s0,-128
{
    80007494:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80007496:	894e                	mv	s2,s3
    80007498:	b765                	j	80007440 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000749a:	0003b697          	auipc	a3,0x3b
    8000749e:	b666b683          	ld	a3,-1178(a3) # 80042000 <disk+0x2000>
    800074a2:	96ba                	add	a3,a3,a4
    800074a4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800074a8:	00039817          	auipc	a6,0x39
    800074ac:	b5880813          	addi	a6,a6,-1192 # 80040000 <disk>
    800074b0:	0003b697          	auipc	a3,0x3b
    800074b4:	b5068693          	addi	a3,a3,-1200 # 80042000 <disk+0x2000>
    800074b8:	6290                	ld	a2,0(a3)
    800074ba:	963a                	add	a2,a2,a4
    800074bc:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800074c0:	0015e593          	ori	a1,a1,1
    800074c4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800074c8:	f8842603          	lw	a2,-120(s0)
    800074cc:	628c                	ld	a1,0(a3)
    800074ce:	972e                	add	a4,a4,a1
    800074d0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800074d4:	20050593          	addi	a1,a0,512
    800074d8:	0592                	slli	a1,a1,0x4
    800074da:	95c2                	add	a1,a1,a6
    800074dc:	577d                	li	a4,-1
    800074de:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800074e2:	00461713          	slli	a4,a2,0x4
    800074e6:	6290                	ld	a2,0(a3)
    800074e8:	963a                	add	a2,a2,a4
    800074ea:	03078793          	addi	a5,a5,48
    800074ee:	97c2                	add	a5,a5,a6
    800074f0:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    800074f2:	629c                	ld	a5,0(a3)
    800074f4:	97ba                	add	a5,a5,a4
    800074f6:	4605                	li	a2,1
    800074f8:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800074fa:	629c                	ld	a5,0(a3)
    800074fc:	97ba                	add	a5,a5,a4
    800074fe:	4809                	li	a6,2
    80007500:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80007504:	629c                	ld	a5,0(a3)
    80007506:	973e                	add	a4,a4,a5
    80007508:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000750c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80007510:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80007514:	6698                	ld	a4,8(a3)
    80007516:	00275783          	lhu	a5,2(a4)
    8000751a:	8b9d                	andi	a5,a5,7
    8000751c:	0786                	slli	a5,a5,0x1
    8000751e:	97ba                	add	a5,a5,a4
    80007520:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80007524:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80007528:	6698                	ld	a4,8(a3)
    8000752a:	00275783          	lhu	a5,2(a4)
    8000752e:	2785                	addiw	a5,a5,1
    80007530:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80007534:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80007538:	100017b7          	lui	a5,0x10001
    8000753c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80007540:	004aa783          	lw	a5,4(s5)
    80007544:	02c79163          	bne	a5,a2,80007566 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80007548:	0003b917          	auipc	s2,0x3b
    8000754c:	be090913          	addi	s2,s2,-1056 # 80042128 <disk+0x2128>
  while(b->disk == 1) {
    80007550:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80007552:	85ca                	mv	a1,s2
    80007554:	8556                	mv	a0,s5
    80007556:	ffffb097          	auipc	ra,0xffffb
    8000755a:	19e080e7          	jalr	414(ra) # 800026f4 <sleep>
  while(b->disk == 1) {
    8000755e:	004aa783          	lw	a5,4(s5)
    80007562:	fe9788e3          	beq	a5,s1,80007552 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80007566:	f8042903          	lw	s2,-128(s0)
    8000756a:	20090793          	addi	a5,s2,512
    8000756e:	00479713          	slli	a4,a5,0x4
    80007572:	00039797          	auipc	a5,0x39
    80007576:	a8e78793          	addi	a5,a5,-1394 # 80040000 <disk>
    8000757a:	97ba                	add	a5,a5,a4
    8000757c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80007580:	0003b997          	auipc	s3,0x3b
    80007584:	a8098993          	addi	s3,s3,-1408 # 80042000 <disk+0x2000>
    80007588:	00491713          	slli	a4,s2,0x4
    8000758c:	0009b783          	ld	a5,0(s3)
    80007590:	97ba                	add	a5,a5,a4
    80007592:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80007596:	854a                	mv	a0,s2
    80007598:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000759c:	00000097          	auipc	ra,0x0
    800075a0:	c5a080e7          	jalr	-934(ra) # 800071f6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800075a4:	8885                	andi	s1,s1,1
    800075a6:	f0ed                	bnez	s1,80007588 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800075a8:	0003b517          	auipc	a0,0x3b
    800075ac:	b8050513          	addi	a0,a0,-1152 # 80042128 <disk+0x2128>
    800075b0:	ffff9097          	auipc	ra,0xffff9
    800075b4:	72e080e7          	jalr	1838(ra) # 80000cde <release>
}
    800075b8:	70e6                	ld	ra,120(sp)
    800075ba:	7446                	ld	s0,112(sp)
    800075bc:	74a6                	ld	s1,104(sp)
    800075be:	7906                	ld	s2,96(sp)
    800075c0:	69e6                	ld	s3,88(sp)
    800075c2:	6a46                	ld	s4,80(sp)
    800075c4:	6aa6                	ld	s5,72(sp)
    800075c6:	6b06                	ld	s6,64(sp)
    800075c8:	7be2                	ld	s7,56(sp)
    800075ca:	7c42                	ld	s8,48(sp)
    800075cc:	7ca2                	ld	s9,40(sp)
    800075ce:	7d02                	ld	s10,32(sp)
    800075d0:	6de2                	ld	s11,24(sp)
    800075d2:	6109                	addi	sp,sp,128
    800075d4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800075d6:	f8042503          	lw	a0,-128(s0)
    800075da:	20050793          	addi	a5,a0,512
    800075de:	0792                	slli	a5,a5,0x4
  if(write)
    800075e0:	00039817          	auipc	a6,0x39
    800075e4:	a2080813          	addi	a6,a6,-1504 # 80040000 <disk>
    800075e8:	00f80733          	add	a4,a6,a5
    800075ec:	01a036b3          	snez	a3,s10
    800075f0:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    800075f4:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800075f8:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800075fc:	7679                	lui	a2,0xffffe
    800075fe:	963e                	add	a2,a2,a5
    80007600:	0003b697          	auipc	a3,0x3b
    80007604:	a0068693          	addi	a3,a3,-1536 # 80042000 <disk+0x2000>
    80007608:	6298                	ld	a4,0(a3)
    8000760a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000760c:	0a878593          	addi	a1,a5,168
    80007610:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007612:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80007614:	6298                	ld	a4,0(a3)
    80007616:	9732                	add	a4,a4,a2
    80007618:	45c1                	li	a1,16
    8000761a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000761c:	6298                	ld	a4,0(a3)
    8000761e:	9732                	add	a4,a4,a2
    80007620:	4585                	li	a1,1
    80007622:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80007626:	f8442703          	lw	a4,-124(s0)
    8000762a:	628c                	ld	a1,0(a3)
    8000762c:	962e                	add	a2,a2,a1
    8000762e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffbb00e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80007632:	0712                	slli	a4,a4,0x4
    80007634:	6290                	ld	a2,0(a3)
    80007636:	963a                	add	a2,a2,a4
    80007638:	058a8593          	addi	a1,s5,88
    8000763c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000763e:	6294                	ld	a3,0(a3)
    80007640:	96ba                	add	a3,a3,a4
    80007642:	40000613          	li	a2,1024
    80007646:	c690                	sw	a2,8(a3)
  if(write)
    80007648:	e40d19e3          	bnez	s10,8000749a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000764c:	0003b697          	auipc	a3,0x3b
    80007650:	9b46b683          	ld	a3,-1612(a3) # 80042000 <disk+0x2000>
    80007654:	96ba                	add	a3,a3,a4
    80007656:	4609                	li	a2,2
    80007658:	00c69623          	sh	a2,12(a3)
    8000765c:	b5b1                	j	800074a8 <virtio_disk_rw+0xd2>

000000008000765e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000765e:	1101                	addi	sp,sp,-32
    80007660:	ec06                	sd	ra,24(sp)
    80007662:	e822                	sd	s0,16(sp)
    80007664:	e426                	sd	s1,8(sp)
    80007666:	e04a                	sd	s2,0(sp)
    80007668:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000766a:	0003b517          	auipc	a0,0x3b
    8000766e:	abe50513          	addi	a0,a0,-1346 # 80042128 <disk+0x2128>
    80007672:	ffff9097          	auipc	ra,0xffff9
    80007676:	596080e7          	jalr	1430(ra) # 80000c08 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000767a:	10001737          	lui	a4,0x10001
    8000767e:	533c                	lw	a5,96(a4)
    80007680:	8b8d                	andi	a5,a5,3
    80007682:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80007684:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80007688:	0003b797          	auipc	a5,0x3b
    8000768c:	97878793          	addi	a5,a5,-1672 # 80042000 <disk+0x2000>
    80007690:	6b94                	ld	a3,16(a5)
    80007692:	0207d703          	lhu	a4,32(a5)
    80007696:	0026d783          	lhu	a5,2(a3)
    8000769a:	06f70163          	beq	a4,a5,800076fc <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000769e:	00039917          	auipc	s2,0x39
    800076a2:	96290913          	addi	s2,s2,-1694 # 80040000 <disk>
    800076a6:	0003b497          	auipc	s1,0x3b
    800076aa:	95a48493          	addi	s1,s1,-1702 # 80042000 <disk+0x2000>
    __sync_synchronize();
    800076ae:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800076b2:	6898                	ld	a4,16(s1)
    800076b4:	0204d783          	lhu	a5,32(s1)
    800076b8:	8b9d                	andi	a5,a5,7
    800076ba:	078e                	slli	a5,a5,0x3
    800076bc:	97ba                	add	a5,a5,a4
    800076be:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800076c0:	20078713          	addi	a4,a5,512
    800076c4:	0712                	slli	a4,a4,0x4
    800076c6:	974a                	add	a4,a4,s2
    800076c8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800076cc:	e731                	bnez	a4,80007718 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800076ce:	20078793          	addi	a5,a5,512
    800076d2:	0792                	slli	a5,a5,0x4
    800076d4:	97ca                	add	a5,a5,s2
    800076d6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    800076d8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800076dc:	ffffb097          	auipc	ra,0xffffb
    800076e0:	1a2080e7          	jalr	418(ra) # 8000287e <wakeup>

    disk.used_idx += 1;
    800076e4:	0204d783          	lhu	a5,32(s1)
    800076e8:	2785                	addiw	a5,a5,1
    800076ea:	17c2                	slli	a5,a5,0x30
    800076ec:	93c1                	srli	a5,a5,0x30
    800076ee:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800076f2:	6898                	ld	a4,16(s1)
    800076f4:	00275703          	lhu	a4,2(a4)
    800076f8:	faf71be3          	bne	a4,a5,800076ae <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800076fc:	0003b517          	auipc	a0,0x3b
    80007700:	a2c50513          	addi	a0,a0,-1492 # 80042128 <disk+0x2128>
    80007704:	ffff9097          	auipc	ra,0xffff9
    80007708:	5da080e7          	jalr	1498(ra) # 80000cde <release>
}
    8000770c:	60e2                	ld	ra,24(sp)
    8000770e:	6442                	ld	s0,16(sp)
    80007710:	64a2                	ld	s1,8(sp)
    80007712:	6902                	ld	s2,0(sp)
    80007714:	6105                	addi	sp,sp,32
    80007716:	8082                	ret
      panic("virtio_disk_intr status");
    80007718:	00002517          	auipc	a0,0x2
    8000771c:	31850513          	addi	a0,a0,792 # 80009a30 <syscalls+0x408>
    80007720:	ffff9097          	auipc	ra,0xffff9
    80007724:	e0e080e7          	jalr	-498(ra) # 8000052e <panic>

0000000080007728 <call_sigret>:
    80007728:	48e1                	li	a7,24
    8000772a:	00000073          	ecall
    8000772e:	8082                	ret

0000000080007730 <end_sigret>:
	...

0000000080008000 <_trampoline>:
    80008000:	14051573          	csrrw	a0,sscratch,a0
    80008004:	02153423          	sd	ra,40(a0)
    80008008:	02253823          	sd	sp,48(a0)
    8000800c:	02353c23          	sd	gp,56(a0)
    80008010:	04453023          	sd	tp,64(a0)
    80008014:	04553423          	sd	t0,72(a0)
    80008018:	04653823          	sd	t1,80(a0)
    8000801c:	04753c23          	sd	t2,88(a0)
    80008020:	f120                	sd	s0,96(a0)
    80008022:	f524                	sd	s1,104(a0)
    80008024:	fd2c                	sd	a1,120(a0)
    80008026:	e150                	sd	a2,128(a0)
    80008028:	e554                	sd	a3,136(a0)
    8000802a:	e958                	sd	a4,144(a0)
    8000802c:	ed5c                	sd	a5,152(a0)
    8000802e:	0b053023          	sd	a6,160(a0)
    80008032:	0b153423          	sd	a7,168(a0)
    80008036:	0b253823          	sd	s2,176(a0)
    8000803a:	0b353c23          	sd	s3,184(a0)
    8000803e:	0d453023          	sd	s4,192(a0)
    80008042:	0d553423          	sd	s5,200(a0)
    80008046:	0d653823          	sd	s6,208(a0)
    8000804a:	0d753c23          	sd	s7,216(a0)
    8000804e:	0f853023          	sd	s8,224(a0)
    80008052:	0f953423          	sd	s9,232(a0)
    80008056:	0fa53823          	sd	s10,240(a0)
    8000805a:	0fb53c23          	sd	s11,248(a0)
    8000805e:	11c53023          	sd	t3,256(a0)
    80008062:	11d53423          	sd	t4,264(a0)
    80008066:	11e53823          	sd	t5,272(a0)
    8000806a:	11f53c23          	sd	t6,280(a0)
    8000806e:	140022f3          	csrr	t0,sscratch
    80008072:	06553823          	sd	t0,112(a0)
    80008076:	00853103          	ld	sp,8(a0)
    8000807a:	02053203          	ld	tp,32(a0)
    8000807e:	01053283          	ld	t0,16(a0)
    80008082:	00053303          	ld	t1,0(a0)
    80008086:	18031073          	csrw	satp,t1
    8000808a:	12000073          	sfence.vma
    8000808e:	8282                	jr	t0

0000000080008090 <userret>:
    80008090:	18059073          	csrw	satp,a1
    80008094:	12000073          	sfence.vma
    80008098:	07053283          	ld	t0,112(a0)
    8000809c:	14029073          	csrw	sscratch,t0
    800080a0:	02853083          	ld	ra,40(a0)
    800080a4:	03053103          	ld	sp,48(a0)
    800080a8:	03853183          	ld	gp,56(a0)
    800080ac:	04053203          	ld	tp,64(a0)
    800080b0:	04853283          	ld	t0,72(a0)
    800080b4:	05053303          	ld	t1,80(a0)
    800080b8:	05853383          	ld	t2,88(a0)
    800080bc:	7120                	ld	s0,96(a0)
    800080be:	7524                	ld	s1,104(a0)
    800080c0:	7d2c                	ld	a1,120(a0)
    800080c2:	6150                	ld	a2,128(a0)
    800080c4:	6554                	ld	a3,136(a0)
    800080c6:	6958                	ld	a4,144(a0)
    800080c8:	6d5c                	ld	a5,152(a0)
    800080ca:	0a053803          	ld	a6,160(a0)
    800080ce:	0a853883          	ld	a7,168(a0)
    800080d2:	0b053903          	ld	s2,176(a0)
    800080d6:	0b853983          	ld	s3,184(a0)
    800080da:	0c053a03          	ld	s4,192(a0)
    800080de:	0c853a83          	ld	s5,200(a0)
    800080e2:	0d053b03          	ld	s6,208(a0)
    800080e6:	0d853b83          	ld	s7,216(a0)
    800080ea:	0e053c03          	ld	s8,224(a0)
    800080ee:	0e853c83          	ld	s9,232(a0)
    800080f2:	0f053d03          	ld	s10,240(a0)
    800080f6:	0f853d83          	ld	s11,248(a0)
    800080fa:	10053e03          	ld	t3,256(a0)
    800080fe:	10853e83          	ld	t4,264(a0)
    80008102:	11053f03          	ld	t5,272(a0)
    80008106:	11853f83          	ld	t6,280(a0)
    8000810a:	14051573          	csrrw	a0,sscratch,a0
    8000810e:	10200073          	sret
	...
