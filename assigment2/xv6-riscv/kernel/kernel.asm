
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
    80000068:	cfc78793          	addi	a5,a5,-772 # 80006d60 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffbc7ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	de478793          	addi	a5,a5,-540 # 80000e92 <main>
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
    80000122:	86a080e7          	jalr	-1942(ra) # 80002988 <either_copyin>
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
    80000188:	a42080e7          	jalr	-1470(ra) # 80000bc6 <acquire>
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
    800001b6:	8ca080e7          	jalr	-1846(ra) # 80001a7c <myproc>
    800001ba:	4d5c                	lw	a5,28(a0)
    800001bc:	07278863          	beq	a5,s2,8000022c <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001c0:	85a6                	mv	a1,s1
    800001c2:	854e                	mv	a0,s3
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	22e080e7          	jalr	558(ra) # 800023f2 <sleep>
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
    80000200:	00002097          	auipc	ra,0x2
    80000204:	732080e7          	jalr	1842(ra) # 80002932 <either_copyout>
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
    80000222:	a7e080e7          	jalr	-1410(ra) # 80000c9c <release>

  return target - n;
    80000226:	414b853b          	subw	a0,s7,s4
    8000022a:	a811                	j	8000023e <consoleread+0xe8>
        release(&cons.lock);
    8000022c:	00012517          	auipc	a0,0x12
    80000230:	f5450513          	addi	a0,a0,-172 # 80012180 <cons>
    80000234:	00001097          	auipc	ra,0x1
    80000238:	a68080e7          	jalr	-1432(ra) # 80000c9c <release>
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
    800002c8:	902080e7          	jalr	-1790(ra) # 80000bc6 <acquire>

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
    800002e2:	00002097          	auipc	ra,0x2
    800002e6:	6fc080e7          	jalr	1788(ra) # 800029de <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ea:	00012517          	auipc	a0,0x12
    800002ee:	e9650513          	addi	a0,a0,-362 # 80012180 <cons>
    800002f2:	00001097          	auipc	ra,0x1
    800002f6:	9aa080e7          	jalr	-1622(ra) # 80000c9c <release>
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
    8000043a:	146080e7          	jalr	326(ra) # 8000257c <wakeup>
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
    8000044c:	bc858593          	addi	a1,a1,-1080 # 80009010 <etext+0x10>
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
    80000468:	0003d797          	auipc	a5,0x3d
    8000046c:	70878793          	addi	a5,a5,1800 # 8003db70 <devsw>
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
    800004ae:	b9660613          	addi	a2,a2,-1130 # 80009040 <digits>
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
    80000546:	ad650513          	addi	a0,a0,-1322 # 80009018 <etext+0x18>
    8000054a:	00000097          	auipc	ra,0x0
    8000054e:	02e080e7          	jalr	46(ra) # 80000578 <printf>
  printf(s);
    80000552:	8526                	mv	a0,s1
    80000554:	00000097          	auipc	ra,0x0
    80000558:	024080e7          	jalr	36(ra) # 80000578 <printf>
  printf("\n");
    8000055c:	00009517          	auipc	a0,0x9
    80000560:	b4450513          	addi	a0,a0,-1212 # 800090a0 <digits+0x60>
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
    800005da:	a6ab0b13          	addi	s6,s6,-1430 # 80009040 <digits>
    switch(c){
    800005de:	07300c93          	li	s9,115
    800005e2:	06400c13          	li	s8,100
    800005e6:	a82d                	j	80000620 <printf+0xa8>
    acquire(&pr.lock);
    800005e8:	00012517          	auipc	a0,0x12
    800005ec:	c4050513          	addi	a0,a0,-960 # 80012228 <pr>
    800005f0:	00000097          	auipc	ra,0x0
    800005f4:	5d6080e7          	jalr	1494(ra) # 80000bc6 <acquire>
    800005f8:	bf7d                	j	800005b6 <printf+0x3e>
    panic("null fmt");
    800005fa:	00009517          	auipc	a0,0x9
    800005fe:	a2e50513          	addi	a0,a0,-1490 # 80009028 <etext+0x28>
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
    800006f8:	92c48493          	addi	s1,s1,-1748 # 80009020 <etext+0x20>
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
    80000752:	54e080e7          	jalr	1358(ra) # 80000c9c <release>
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
    8000076e:	8ce58593          	addi	a1,a1,-1842 # 80009038 <etext+0x38>
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
    800007be:	89e58593          	addi	a1,a1,-1890 # 80009058 <digits+0x18>
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
    800007ea:	394080e7          	jalr	916(ra) # 80000b7a <push_off>

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
    80000818:	428080e7          	jalr	1064(ra) # 80000c3c <pop_off>
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
    80000886:	cfa080e7          	jalr	-774(ra) # 8000257c <wakeup>
    
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
    800008ca:	300080e7          	jalr	768(ra) # 80000bc6 <acquire>
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
    80000912:	ae4080e7          	jalr	-1308(ra) # 800023f2 <sleep>
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
    8000094e:	352080e7          	jalr	850(ra) # 80000c9c <release>
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
    800009ba:	210080e7          	jalr	528(ra) # 80000bc6 <acquire>
  uartstart();
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	e68080e7          	jalr	-408(ra) # 80000826 <uartstart>
  release(&uart_tx_lock);
    800009c6:	8526                	mv	a0,s1
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	2d4080e7          	jalr	724(ra) # 80000c9c <release>
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
    800009ee:	00041797          	auipc	a5,0x41
    800009f2:	61278793          	addi	a5,a5,1554 # 80042000 <end>
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
    80000a0a:	2de080e7          	jalr	734(ra) # 80000ce4 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a0e:	00012917          	auipc	s2,0x12
    80000a12:	87290913          	addi	s2,s2,-1934 # 80012280 <kmem>
    80000a16:	854a                	mv	a0,s2
    80000a18:	00000097          	auipc	ra,0x0
    80000a1c:	1ae080e7          	jalr	430(ra) # 80000bc6 <acquire>
  r->next = kmem.freelist;
    80000a20:	01893783          	ld	a5,24(s2)
    80000a24:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a26:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a2a:	854a                	mv	a0,s2
    80000a2c:	00000097          	auipc	ra,0x0
    80000a30:	270080e7          	jalr	624(ra) # 80000c9c <release>
}
    80000a34:	60e2                	ld	ra,24(sp)
    80000a36:	6442                	ld	s0,16(sp)
    80000a38:	64a2                	ld	s1,8(sp)
    80000a3a:	6902                	ld	s2,0(sp)
    80000a3c:	6105                	addi	sp,sp,32
    80000a3e:	8082                	ret
    panic("kfree");
    80000a40:	00008517          	auipc	a0,0x8
    80000a44:	62050513          	addi	a0,a0,1568 # 80009060 <digits+0x20>
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
    80000aa6:	5c658593          	addi	a1,a1,1478 # 80009068 <digits+0x28>
    80000aaa:	00011517          	auipc	a0,0x11
    80000aae:	7d650513          	addi	a0,a0,2006 # 80012280 <kmem>
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	084080e7          	jalr	132(ra) # 80000b36 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aba:	45c5                	li	a1,17
    80000abc:	05ee                	slli	a1,a1,0x1b
    80000abe:	00041517          	auipc	a0,0x41
    80000ac2:	54250513          	addi	a0,a0,1346 # 80042000 <end>
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
    80000aee:	0dc080e7          	jalr	220(ra) # 80000bc6 <acquire>
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
    80000b06:	19a080e7          	jalr	410(ra) # 80000c9c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b0a:	6605                	lui	a2,0x1
    80000b0c:	4595                	li	a1,5
    80000b0e:	8526                	mv	a0,s1
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	1d4080e7          	jalr	468(ra) # 80000ce4 <memset>
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
    80000b30:	170080e7          	jalr	368(ra) # 80000c9c <release>
  if(r)
    80000b34:	b7d5                	j	80000b18 <kalloc+0x42>

0000000080000b36 <initlock>:
#include "proc.h"
#include "defs.h"

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

0000000080000b4c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b4c:	411c                	lw	a5,0(a0)
    80000b4e:	e399                	bnez	a5,80000b54 <holding+0x8>
    80000b50:	4501                	li	a0,0
  return r;
}
    80000b52:	8082                	ret
{
    80000b54:	1101                	addi	sp,sp,-32
    80000b56:	ec06                	sd	ra,24(sp)
    80000b58:	e822                	sd	s0,16(sp)
    80000b5a:	e426                	sd	s1,8(sp)
    80000b5c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b5e:	6904                	ld	s1,16(a0)
    80000b60:	00001097          	auipc	ra,0x1
    80000b64:	ef8080e7          	jalr	-264(ra) # 80001a58 <mycpu>
    80000b68:	40a48533          	sub	a0,s1,a0
    80000b6c:	00153513          	seqz	a0,a0
}
    80000b70:	60e2                	ld	ra,24(sp)
    80000b72:	6442                	ld	s0,16(sp)
    80000b74:	64a2                	ld	s1,8(sp)
    80000b76:	6105                	addi	sp,sp,32
    80000b78:	8082                	ret

0000000080000b7a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b7a:	1101                	addi	sp,sp,-32
    80000b7c:	ec06                	sd	ra,24(sp)
    80000b7e:	e822                	sd	s0,16(sp)
    80000b80:	e426                	sd	s1,8(sp)
    80000b82:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b84:	100024f3          	csrr	s1,sstatus
    80000b88:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b8c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b8e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b92:	00001097          	auipc	ra,0x1
    80000b96:	ec6080e7          	jalr	-314(ra) # 80001a58 <mycpu>
    80000b9a:	5d3c                	lw	a5,120(a0)
    80000b9c:	cf89                	beqz	a5,80000bb6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	eba080e7          	jalr	-326(ra) # 80001a58 <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	2785                	addiw	a5,a5,1
    80000baa:	dd3c                	sw	a5,120(a0)
}
    80000bac:	60e2                	ld	ra,24(sp)
    80000bae:	6442                	ld	s0,16(sp)
    80000bb0:	64a2                	ld	s1,8(sp)
    80000bb2:	6105                	addi	sp,sp,32
    80000bb4:	8082                	ret
    mycpu()->intena = old;
    80000bb6:	00001097          	auipc	ra,0x1
    80000bba:	ea2080e7          	jalr	-350(ra) # 80001a58 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bbe:	8085                	srli	s1,s1,0x1
    80000bc0:	8885                	andi	s1,s1,1
    80000bc2:	dd64                	sw	s1,124(a0)
    80000bc4:	bfe9                	j	80000b9e <push_off+0x24>

0000000080000bc6 <acquire>:
acquire(struct spinlock *lk){
    80000bc6:	1101                	addi	sp,sp,-32
    80000bc8:	ec06                	sd	ra,24(sp)
    80000bca:	e822                	sd	s0,16(sp)
    80000bcc:	e426                	sd	s1,8(sp)
    80000bce:	1000                	addi	s0,sp,32
    80000bd0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bd2:	00000097          	auipc	ra,0x0
    80000bd6:	fa8080e7          	jalr	-88(ra) # 80000b7a <push_off>
  if(holding(lk)){
    80000bda:	8526                	mv	a0,s1
    80000bdc:	00000097          	auipc	ra,0x0
    80000be0:	f70080e7          	jalr	-144(ra) # 80000b4c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be4:	4705                	li	a4,1
  if(holding(lk)){
    80000be6:	e115                	bnez	a0,80000c0a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000be8:	87ba                	mv	a5,a4
    80000bea:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bee:	2781                	sext.w	a5,a5
    80000bf0:	ffe5                	bnez	a5,80000be8 <acquire+0x22>
  __sync_synchronize();
    80000bf2:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bf6:	00001097          	auipc	ra,0x1
    80000bfa:	e62080e7          	jalr	-414(ra) # 80001a58 <mycpu>
    80000bfe:	e888                	sd	a0,16(s1)
}
    80000c00:	60e2                	ld	ra,24(sp)
    80000c02:	6442                	ld	s0,16(sp)
    80000c04:	64a2                	ld	s1,8(sp)
    80000c06:	6105                	addi	sp,sp,32
    80000c08:	8082                	ret
    printf("pid=%d tid=%d tried to lock when already holding\n",lk->cpu->proc->pid,mykthread()->tid);//TODO delete
    80000c0a:	689c                	ld	a5,16(s1)
    80000c0c:	639c                	ld	a5,0(a5)
    80000c0e:	53c4                	lw	s1,36(a5)
    80000c10:	00001097          	auipc	ra,0x1
    80000c14:	eac080e7          	jalr	-340(ra) # 80001abc <mykthread>
    80000c18:	5910                	lw	a2,48(a0)
    80000c1a:	85a6                	mv	a1,s1
    80000c1c:	00008517          	auipc	a0,0x8
    80000c20:	45450513          	addi	a0,a0,1108 # 80009070 <digits+0x30>
    80000c24:	00000097          	auipc	ra,0x0
    80000c28:	954080e7          	jalr	-1708(ra) # 80000578 <printf>
    panic("acquire");
    80000c2c:	00008517          	auipc	a0,0x8
    80000c30:	47c50513          	addi	a0,a0,1148 # 800090a8 <digits+0x68>
    80000c34:	00000097          	auipc	ra,0x0
    80000c38:	8fa080e7          	jalr	-1798(ra) # 8000052e <panic>

0000000080000c3c <pop_off>:

void
pop_off(void)
{
    80000c3c:	1141                	addi	sp,sp,-16
    80000c3e:	e406                	sd	ra,8(sp)
    80000c40:	e022                	sd	s0,0(sp)
    80000c42:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c44:	00001097          	auipc	ra,0x1
    80000c48:	e14080e7          	jalr	-492(ra) # 80001a58 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c4c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c50:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c52:	e78d                	bnez	a5,80000c7c <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c54:	5d3c                	lw	a5,120(a0)
    80000c56:	02f05b63          	blez	a5,80000c8c <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c5a:	37fd                	addiw	a5,a5,-1
    80000c5c:	0007871b          	sext.w	a4,a5
    80000c60:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c62:	eb09                	bnez	a4,80000c74 <pop_off+0x38>
    80000c64:	5d7c                	lw	a5,124(a0)
    80000c66:	c799                	beqz	a5,80000c74 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c68:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c6c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c70:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c74:	60a2                	ld	ra,8(sp)
    80000c76:	6402                	ld	s0,0(sp)
    80000c78:	0141                	addi	sp,sp,16
    80000c7a:	8082                	ret
    panic("pop_off - interruptible");
    80000c7c:	00008517          	auipc	a0,0x8
    80000c80:	43450513          	addi	a0,a0,1076 # 800090b0 <digits+0x70>
    80000c84:	00000097          	auipc	ra,0x0
    80000c88:	8aa080e7          	jalr	-1878(ra) # 8000052e <panic>
    panic("pop_off");
    80000c8c:	00008517          	auipc	a0,0x8
    80000c90:	43c50513          	addi	a0,a0,1084 # 800090c8 <digits+0x88>
    80000c94:	00000097          	auipc	ra,0x0
    80000c98:	89a080e7          	jalr	-1894(ra) # 8000052e <panic>

0000000080000c9c <release>:
{
    80000c9c:	1101                	addi	sp,sp,-32
    80000c9e:	ec06                	sd	ra,24(sp)
    80000ca0:	e822                	sd	s0,16(sp)
    80000ca2:	e426                	sd	s1,8(sp)
    80000ca4:	1000                	addi	s0,sp,32
    80000ca6:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000ca8:	00000097          	auipc	ra,0x0
    80000cac:	ea4080e7          	jalr	-348(ra) # 80000b4c <holding>
    80000cb0:	c115                	beqz	a0,80000cd4 <release+0x38>
  lk->cpu = 0;
    80000cb2:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000cb6:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cba:	0f50000f          	fence	iorw,ow
    80000cbe:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cc2:	00000097          	auipc	ra,0x0
    80000cc6:	f7a080e7          	jalr	-134(ra) # 80000c3c <pop_off>
}
    80000cca:	60e2                	ld	ra,24(sp)
    80000ccc:	6442                	ld	s0,16(sp)
    80000cce:	64a2                	ld	s1,8(sp)
    80000cd0:	6105                	addi	sp,sp,32
    80000cd2:	8082                	ret
    panic("release");
    80000cd4:	00008517          	auipc	a0,0x8
    80000cd8:	3fc50513          	addi	a0,a0,1020 # 800090d0 <digits+0x90>
    80000cdc:	00000097          	auipc	ra,0x0
    80000ce0:	852080e7          	jalr	-1966(ra) # 8000052e <panic>

0000000080000ce4 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000ce4:	1141                	addi	sp,sp,-16
    80000ce6:	e422                	sd	s0,8(sp)
    80000ce8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cea:	ca19                	beqz	a2,80000d00 <memset+0x1c>
    80000cec:	87aa                	mv	a5,a0
    80000cee:	1602                	slli	a2,a2,0x20
    80000cf0:	9201                	srli	a2,a2,0x20
    80000cf2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cf6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cfa:	0785                	addi	a5,a5,1
    80000cfc:	fee79de3          	bne	a5,a4,80000cf6 <memset+0x12>
  }
  return dst;
}
    80000d00:	6422                	ld	s0,8(sp)
    80000d02:	0141                	addi	sp,sp,16
    80000d04:	8082                	ret

0000000080000d06 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d06:	1141                	addi	sp,sp,-16
    80000d08:	e422                	sd	s0,8(sp)
    80000d0a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d0c:	ca05                	beqz	a2,80000d3c <memcmp+0x36>
    80000d0e:	fff6069b          	addiw	a3,a2,-1
    80000d12:	1682                	slli	a3,a3,0x20
    80000d14:	9281                	srli	a3,a3,0x20
    80000d16:	0685                	addi	a3,a3,1
    80000d18:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d1a:	00054783          	lbu	a5,0(a0)
    80000d1e:	0005c703          	lbu	a4,0(a1)
    80000d22:	00e79863          	bne	a5,a4,80000d32 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d26:	0505                	addi	a0,a0,1
    80000d28:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d2a:	fed518e3          	bne	a0,a3,80000d1a <memcmp+0x14>
  }

  return 0;
    80000d2e:	4501                	li	a0,0
    80000d30:	a019                	j	80000d36 <memcmp+0x30>
      return *s1 - *s2;
    80000d32:	40e7853b          	subw	a0,a5,a4
}
    80000d36:	6422                	ld	s0,8(sp)
    80000d38:	0141                	addi	sp,sp,16
    80000d3a:	8082                	ret
  return 0;
    80000d3c:	4501                	li	a0,0
    80000d3e:	bfe5                	j	80000d36 <memcmp+0x30>

0000000080000d40 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d40:	1141                	addi	sp,sp,-16
    80000d42:	e422                	sd	s0,8(sp)
    80000d44:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d46:	02a5e563          	bltu	a1,a0,80000d70 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d4a:	fff6069b          	addiw	a3,a2,-1
    80000d4e:	ce11                	beqz	a2,80000d6a <memmove+0x2a>
    80000d50:	1682                	slli	a3,a3,0x20
    80000d52:	9281                	srli	a3,a3,0x20
    80000d54:	0685                	addi	a3,a3,1
    80000d56:	96ae                	add	a3,a3,a1
    80000d58:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d5a:	0585                	addi	a1,a1,1
    80000d5c:	0785                	addi	a5,a5,1
    80000d5e:	fff5c703          	lbu	a4,-1(a1)
    80000d62:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d66:	fed59ae3          	bne	a1,a3,80000d5a <memmove+0x1a>

  return dst;
}
    80000d6a:	6422                	ld	s0,8(sp)
    80000d6c:	0141                	addi	sp,sp,16
    80000d6e:	8082                	ret
  if(s < d && s + n > d){
    80000d70:	02061713          	slli	a4,a2,0x20
    80000d74:	9301                	srli	a4,a4,0x20
    80000d76:	00e587b3          	add	a5,a1,a4
    80000d7a:	fcf578e3          	bgeu	a0,a5,80000d4a <memmove+0xa>
    d += n;
    80000d7e:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d80:	fff6069b          	addiw	a3,a2,-1
    80000d84:	d27d                	beqz	a2,80000d6a <memmove+0x2a>
    80000d86:	02069613          	slli	a2,a3,0x20
    80000d8a:	9201                	srli	a2,a2,0x20
    80000d8c:	fff64613          	not	a2,a2
    80000d90:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d92:	17fd                	addi	a5,a5,-1
    80000d94:	177d                	addi	a4,a4,-1
    80000d96:	0007c683          	lbu	a3,0(a5)
    80000d9a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000d9e:	fef61ae3          	bne	a2,a5,80000d92 <memmove+0x52>
    80000da2:	b7e1                	j	80000d6a <memmove+0x2a>

0000000080000da4 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000da4:	1141                	addi	sp,sp,-16
    80000da6:	e406                	sd	ra,8(sp)
    80000da8:	e022                	sd	s0,0(sp)
    80000daa:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000dac:	00000097          	auipc	ra,0x0
    80000db0:	f94080e7          	jalr	-108(ra) # 80000d40 <memmove>
}
    80000db4:	60a2                	ld	ra,8(sp)
    80000db6:	6402                	ld	s0,0(sp)
    80000db8:	0141                	addi	sp,sp,16
    80000dba:	8082                	ret

0000000080000dbc <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dbc:	1141                	addi	sp,sp,-16
    80000dbe:	e422                	sd	s0,8(sp)
    80000dc0:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000dc2:	ce11                	beqz	a2,80000dde <strncmp+0x22>
    80000dc4:	00054783          	lbu	a5,0(a0)
    80000dc8:	cf89                	beqz	a5,80000de2 <strncmp+0x26>
    80000dca:	0005c703          	lbu	a4,0(a1)
    80000dce:	00f71a63          	bne	a4,a5,80000de2 <strncmp+0x26>
    n--, p++, q++;
    80000dd2:	367d                	addiw	a2,a2,-1
    80000dd4:	0505                	addi	a0,a0,1
    80000dd6:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dd8:	f675                	bnez	a2,80000dc4 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	a809                	j	80000dee <strncmp+0x32>
    80000dde:	4501                	li	a0,0
    80000de0:	a039                	j	80000dee <strncmp+0x32>
  if(n == 0)
    80000de2:	ca09                	beqz	a2,80000df4 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000de4:	00054503          	lbu	a0,0(a0)
    80000de8:	0005c783          	lbu	a5,0(a1)
    80000dec:	9d1d                	subw	a0,a0,a5
}
    80000dee:	6422                	ld	s0,8(sp)
    80000df0:	0141                	addi	sp,sp,16
    80000df2:	8082                	ret
    return 0;
    80000df4:	4501                	li	a0,0
    80000df6:	bfe5                	j	80000dee <strncmp+0x32>

0000000080000df8 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000df8:	1141                	addi	sp,sp,-16
    80000dfa:	e422                	sd	s0,8(sp)
    80000dfc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dfe:	872a                	mv	a4,a0
    80000e00:	8832                	mv	a6,a2
    80000e02:	367d                	addiw	a2,a2,-1
    80000e04:	01005963          	blez	a6,80000e16 <strncpy+0x1e>
    80000e08:	0705                	addi	a4,a4,1
    80000e0a:	0005c783          	lbu	a5,0(a1)
    80000e0e:	fef70fa3          	sb	a5,-1(a4)
    80000e12:	0585                	addi	a1,a1,1
    80000e14:	f7f5                	bnez	a5,80000e00 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e16:	86ba                	mv	a3,a4
    80000e18:	00c05c63          	blez	a2,80000e30 <strncpy+0x38>
    *s++ = 0;
    80000e1c:	0685                	addi	a3,a3,1
    80000e1e:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e22:	fff6c793          	not	a5,a3
    80000e26:	9fb9                	addw	a5,a5,a4
    80000e28:	010787bb          	addw	a5,a5,a6
    80000e2c:	fef048e3          	bgtz	a5,80000e1c <strncpy+0x24>
  return os;
}
    80000e30:	6422                	ld	s0,8(sp)
    80000e32:	0141                	addi	sp,sp,16
    80000e34:	8082                	ret

0000000080000e36 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e36:	1141                	addi	sp,sp,-16
    80000e38:	e422                	sd	s0,8(sp)
    80000e3a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e3c:	02c05363          	blez	a2,80000e62 <safestrcpy+0x2c>
    80000e40:	fff6069b          	addiw	a3,a2,-1
    80000e44:	1682                	slli	a3,a3,0x20
    80000e46:	9281                	srli	a3,a3,0x20
    80000e48:	96ae                	add	a3,a3,a1
    80000e4a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e4c:	00d58963          	beq	a1,a3,80000e5e <safestrcpy+0x28>
    80000e50:	0585                	addi	a1,a1,1
    80000e52:	0785                	addi	a5,a5,1
    80000e54:	fff5c703          	lbu	a4,-1(a1)
    80000e58:	fee78fa3          	sb	a4,-1(a5)
    80000e5c:	fb65                	bnez	a4,80000e4c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e5e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e62:	6422                	ld	s0,8(sp)
    80000e64:	0141                	addi	sp,sp,16
    80000e66:	8082                	ret

0000000080000e68 <strlen>:

int
strlen(const char *s)
{
    80000e68:	1141                	addi	sp,sp,-16
    80000e6a:	e422                	sd	s0,8(sp)
    80000e6c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e6e:	00054783          	lbu	a5,0(a0)
    80000e72:	cf91                	beqz	a5,80000e8e <strlen+0x26>
    80000e74:	0505                	addi	a0,a0,1
    80000e76:	87aa                	mv	a5,a0
    80000e78:	4685                	li	a3,1
    80000e7a:	9e89                	subw	a3,a3,a0
    80000e7c:	00f6853b          	addw	a0,a3,a5
    80000e80:	0785                	addi	a5,a5,1
    80000e82:	fff7c703          	lbu	a4,-1(a5)
    80000e86:	fb7d                	bnez	a4,80000e7c <strlen+0x14>
    ;
  return n;
}
    80000e88:	6422                	ld	s0,8(sp)
    80000e8a:	0141                	addi	sp,sp,16
    80000e8c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e8e:	4501                	li	a0,0
    80000e90:	bfe5                	j	80000e88 <strlen+0x20>

0000000080000e92 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e92:	1141                	addi	sp,sp,-16
    80000e94:	e406                	sd	ra,8(sp)
    80000e96:	e022                	sd	s0,0(sp)
    80000e98:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e9a:	00001097          	auipc	ra,0x1
    80000e9e:	bae080e7          	jalr	-1106(ra) # 80001a48 <cpuid>
    userinit();      // first user process
    __sync_synchronize();

    started = 1;
  } else {
    while(started == 0)
    80000ea2:	00009717          	auipc	a4,0x9
    80000ea6:	17670713          	addi	a4,a4,374 # 8000a018 <started>
  if(cpuid() == 0){
    80000eaa:	c139                	beqz	a0,80000ef0 <main+0x5e>
    while(started == 0)
    80000eac:	431c                	lw	a5,0(a4)
    80000eae:	2781                	sext.w	a5,a5
    80000eb0:	dff5                	beqz	a5,80000eac <main+0x1a>
      ;
    __sync_synchronize();
    80000eb2:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eb6:	00001097          	auipc	ra,0x1
    80000eba:	b92080e7          	jalr	-1134(ra) # 80001a48 <cpuid>
    80000ebe:	85aa                	mv	a1,a0
    80000ec0:	00008517          	auipc	a0,0x8
    80000ec4:	23050513          	addi	a0,a0,560 # 800090f0 <digits+0xb0>
    80000ec8:	fffff097          	auipc	ra,0xfffff
    80000ecc:	6b0080e7          	jalr	1712(ra) # 80000578 <printf>
    kvminithart();    // turn on paging
    80000ed0:	00000097          	auipc	ra,0x0
    80000ed4:	0d8080e7          	jalr	216(ra) # 80000fa8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ed8:	00002097          	auipc	ra,0x2
    80000edc:	348080e7          	jalr	840(ra) # 80003220 <trapinithart>

    plicinithart();   // ask PLIC for device interrupts
    80000ee0:	00006097          	auipc	ra,0x6
    80000ee4:	ec0080e7          	jalr	-320(ra) # 80006da0 <plicinithart>
  }

  scheduler();        
    80000ee8:	00001097          	auipc	ra,0x1
    80000eec:	2ce080e7          	jalr	718(ra) # 800021b6 <scheduler>
    consoleinit();
    80000ef0:	fffff097          	auipc	ra,0xfffff
    80000ef4:	550080e7          	jalr	1360(ra) # 80000440 <consoleinit>
    printfinit();
    80000ef8:	00000097          	auipc	ra,0x0
    80000efc:	860080e7          	jalr	-1952(ra) # 80000758 <printfinit>
    printf("\n");
    80000f00:	00008517          	auipc	a0,0x8
    80000f04:	1a050513          	addi	a0,a0,416 # 800090a0 <digits+0x60>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	670080e7          	jalr	1648(ra) # 80000578 <printf>
    printf("xv6 kernel is booting\n");
    80000f10:	00008517          	auipc	a0,0x8
    80000f14:	1c850513          	addi	a0,a0,456 # 800090d8 <digits+0x98>
    80000f18:	fffff097          	auipc	ra,0xfffff
    80000f1c:	660080e7          	jalr	1632(ra) # 80000578 <printf>
    printf("\n");
    80000f20:	00008517          	auipc	a0,0x8
    80000f24:	18050513          	addi	a0,a0,384 # 800090a0 <digits+0x60>
    80000f28:	fffff097          	auipc	ra,0xfffff
    80000f2c:	650080e7          	jalr	1616(ra) # 80000578 <printf>
    kinit();         // physical page allocator
    80000f30:	00000097          	auipc	ra,0x0
    80000f34:	b6a080e7          	jalr	-1174(ra) # 80000a9a <kinit>
    kvminit();       // create kernel page table
    80000f38:	00000097          	auipc	ra,0x0
    80000f3c:	310080e7          	jalr	784(ra) # 80001248 <kvminit>
    kvminithart();   // turn on paging
    80000f40:	00000097          	auipc	ra,0x0
    80000f44:	068080e7          	jalr	104(ra) # 80000fa8 <kvminithart>
    procinit();      // process table
    80000f48:	00001097          	auipc	ra,0x1
    80000f4c:	9d2080e7          	jalr	-1582(ra) # 8000191a <procinit>
    trapinit();      // trap vectors
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	2a8080e7          	jalr	680(ra) # 800031f8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	2c8080e7          	jalr	712(ra) # 80003220 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f60:	00006097          	auipc	ra,0x6
    80000f64:	e2a080e7          	jalr	-470(ra) # 80006d8a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f68:	00006097          	auipc	ra,0x6
    80000f6c:	e38080e7          	jalr	-456(ra) # 80006da0 <plicinithart>
    binit();         // buffer cache
    80000f70:	00003097          	auipc	ra,0x3
    80000f74:	f64080e7          	jalr	-156(ra) # 80003ed4 <binit>
    iinit();         // inode cache
    80000f78:	00003097          	auipc	ra,0x3
    80000f7c:	5f6080e7          	jalr	1526(ra) # 8000456e <iinit>
    fileinit();      // file table
    80000f80:	00004097          	auipc	ra,0x4
    80000f84:	5a2080e7          	jalr	1442(ra) # 80005522 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f88:	00006097          	auipc	ra,0x6
    80000f8c:	f3a080e7          	jalr	-198(ra) # 80006ec2 <virtio_disk_init>
    userinit();      // first user process
    80000f90:	00001097          	auipc	ra,0x1
    80000f94:	f6c080e7          	jalr	-148(ra) # 80001efc <userinit>
    __sync_synchronize();
    80000f98:	0ff0000f          	fence
    started = 1;
    80000f9c:	4785                	li	a5,1
    80000f9e:	00009717          	auipc	a4,0x9
    80000fa2:	06f72d23          	sw	a5,122(a4) # 8000a018 <started>
    80000fa6:	b789                	j	80000ee8 <main+0x56>

0000000080000fa8 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fa8:	1141                	addi	sp,sp,-16
    80000faa:	e422                	sd	s0,8(sp)
    80000fac:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fae:	00009797          	auipc	a5,0x9
    80000fb2:	0727b783          	ld	a5,114(a5) # 8000a020 <kernel_pagetable>
    80000fb6:	83b1                	srli	a5,a5,0xc
    80000fb8:	577d                	li	a4,-1
    80000fba:	177e                	slli	a4,a4,0x3f
    80000fbc:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fbe:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fc2:	12000073          	sfence.vma
  sfence_vma();
}
    80000fc6:	6422                	ld	s0,8(sp)
    80000fc8:	0141                	addi	sp,sp,16
    80000fca:	8082                	ret

0000000080000fcc <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fcc:	7139                	addi	sp,sp,-64
    80000fce:	fc06                	sd	ra,56(sp)
    80000fd0:	f822                	sd	s0,48(sp)
    80000fd2:	f426                	sd	s1,40(sp)
    80000fd4:	f04a                	sd	s2,32(sp)
    80000fd6:	ec4e                	sd	s3,24(sp)
    80000fd8:	e852                	sd	s4,16(sp)
    80000fda:	e456                	sd	s5,8(sp)
    80000fdc:	e05a                	sd	s6,0(sp)
    80000fde:	0080                	addi	s0,sp,64
    80000fe0:	84aa                	mv	s1,a0
    80000fe2:	89ae                	mv	s3,a1
    80000fe4:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fe6:	57fd                	li	a5,-1
    80000fe8:	83e9                	srli	a5,a5,0x1a
    80000fea:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fec:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fee:	04b7f263          	bgeu	a5,a1,80001032 <walk+0x66>
    panic("walk");
    80000ff2:	00008517          	auipc	a0,0x8
    80000ff6:	11650513          	addi	a0,a0,278 # 80009108 <digits+0xc8>
    80000ffa:	fffff097          	auipc	ra,0xfffff
    80000ffe:	534080e7          	jalr	1332(ra) # 8000052e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001002:	060a8663          	beqz	s5,8000106e <walk+0xa2>
    80001006:	00000097          	auipc	ra,0x0
    8000100a:	ad0080e7          	jalr	-1328(ra) # 80000ad6 <kalloc>
    8000100e:	84aa                	mv	s1,a0
    80001010:	c529                	beqz	a0,8000105a <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001012:	6605                	lui	a2,0x1
    80001014:	4581                	li	a1,0
    80001016:	00000097          	auipc	ra,0x0
    8000101a:	cce080e7          	jalr	-818(ra) # 80000ce4 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000101e:	00c4d793          	srli	a5,s1,0xc
    80001022:	07aa                	slli	a5,a5,0xa
    80001024:	0017e793          	ori	a5,a5,1
    80001028:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000102c:	3a5d                	addiw	s4,s4,-9
    8000102e:	036a0063          	beq	s4,s6,8000104e <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001032:	0149d933          	srl	s2,s3,s4
    80001036:	1ff97913          	andi	s2,s2,511
    8000103a:	090e                	slli	s2,s2,0x3
    8000103c:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000103e:	00093483          	ld	s1,0(s2)
    80001042:	0014f793          	andi	a5,s1,1
    80001046:	dfd5                	beqz	a5,80001002 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001048:	80a9                	srli	s1,s1,0xa
    8000104a:	04b2                	slli	s1,s1,0xc
    8000104c:	b7c5                	j	8000102c <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000104e:	00c9d513          	srli	a0,s3,0xc
    80001052:	1ff57513          	andi	a0,a0,511
    80001056:	050e                	slli	a0,a0,0x3
    80001058:	9526                	add	a0,a0,s1
}
    8000105a:	70e2                	ld	ra,56(sp)
    8000105c:	7442                	ld	s0,48(sp)
    8000105e:	74a2                	ld	s1,40(sp)
    80001060:	7902                	ld	s2,32(sp)
    80001062:	69e2                	ld	s3,24(sp)
    80001064:	6a42                	ld	s4,16(sp)
    80001066:	6aa2                	ld	s5,8(sp)
    80001068:	6b02                	ld	s6,0(sp)
    8000106a:	6121                	addi	sp,sp,64
    8000106c:	8082                	ret
        return 0;
    8000106e:	4501                	li	a0,0
    80001070:	b7ed                	j	8000105a <walk+0x8e>

0000000080001072 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001072:	57fd                	li	a5,-1
    80001074:	83e9                	srli	a5,a5,0x1a
    80001076:	00b7f463          	bgeu	a5,a1,8000107e <walkaddr+0xc>
    return 0;
    8000107a:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000107c:	8082                	ret
{
    8000107e:	1141                	addi	sp,sp,-16
    80001080:	e406                	sd	ra,8(sp)
    80001082:	e022                	sd	s0,0(sp)
    80001084:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001086:	4601                	li	a2,0
    80001088:	00000097          	auipc	ra,0x0
    8000108c:	f44080e7          	jalr	-188(ra) # 80000fcc <walk>
  if(pte == 0)
    80001090:	c105                	beqz	a0,800010b0 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001092:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001094:	0117f693          	andi	a3,a5,17
    80001098:	4745                	li	a4,17
    return 0;
    8000109a:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000109c:	00e68663          	beq	a3,a4,800010a8 <walkaddr+0x36>
}
    800010a0:	60a2                	ld	ra,8(sp)
    800010a2:	6402                	ld	s0,0(sp)
    800010a4:	0141                	addi	sp,sp,16
    800010a6:	8082                	ret
  pa = PTE2PA(*pte);
    800010a8:	00a7d513          	srli	a0,a5,0xa
    800010ac:	0532                	slli	a0,a0,0xc
  return pa;
    800010ae:	bfcd                	j	800010a0 <walkaddr+0x2e>
    return 0;
    800010b0:	4501                	li	a0,0
    800010b2:	b7fd                	j	800010a0 <walkaddr+0x2e>

00000000800010b4 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010b4:	715d                	addi	sp,sp,-80
    800010b6:	e486                	sd	ra,72(sp)
    800010b8:	e0a2                	sd	s0,64(sp)
    800010ba:	fc26                	sd	s1,56(sp)
    800010bc:	f84a                	sd	s2,48(sp)
    800010be:	f44e                	sd	s3,40(sp)
    800010c0:	f052                	sd	s4,32(sp)
    800010c2:	ec56                	sd	s5,24(sp)
    800010c4:	e85a                	sd	s6,16(sp)
    800010c6:	e45e                	sd	s7,8(sp)
    800010c8:	0880                	addi	s0,sp,80
    800010ca:	8aaa                	mv	s5,a0
    800010cc:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010ce:	777d                	lui	a4,0xfffff
    800010d0:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010d4:	167d                	addi	a2,a2,-1
    800010d6:	00b609b3          	add	s3,a2,a1
    800010da:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010de:	893e                	mv	s2,a5
    800010e0:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010e4:	6b85                	lui	s7,0x1
    800010e6:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010ea:	4605                	li	a2,1
    800010ec:	85ca                	mv	a1,s2
    800010ee:	8556                	mv	a0,s5
    800010f0:	00000097          	auipc	ra,0x0
    800010f4:	edc080e7          	jalr	-292(ra) # 80000fcc <walk>
    800010f8:	c51d                	beqz	a0,80001126 <mappages+0x72>
    if(*pte & PTE_V)
    800010fa:	611c                	ld	a5,0(a0)
    800010fc:	8b85                	andi	a5,a5,1
    800010fe:	ef81                	bnez	a5,80001116 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001100:	80b1                	srli	s1,s1,0xc
    80001102:	04aa                	slli	s1,s1,0xa
    80001104:	0164e4b3          	or	s1,s1,s6
    80001108:	0014e493          	ori	s1,s1,1
    8000110c:	e104                	sd	s1,0(a0)
    if(a == last)
    8000110e:	03390863          	beq	s2,s3,8000113e <mappages+0x8a>
    a += PGSIZE;
    80001112:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001114:	bfc9                	j	800010e6 <mappages+0x32>
      panic("remap");
    80001116:	00008517          	auipc	a0,0x8
    8000111a:	ffa50513          	addi	a0,a0,-6 # 80009110 <digits+0xd0>
    8000111e:	fffff097          	auipc	ra,0xfffff
    80001122:	410080e7          	jalr	1040(ra) # 8000052e <panic>
      return -1;
    80001126:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001128:	60a6                	ld	ra,72(sp)
    8000112a:	6406                	ld	s0,64(sp)
    8000112c:	74e2                	ld	s1,56(sp)
    8000112e:	7942                	ld	s2,48(sp)
    80001130:	79a2                	ld	s3,40(sp)
    80001132:	7a02                	ld	s4,32(sp)
    80001134:	6ae2                	ld	s5,24(sp)
    80001136:	6b42                	ld	s6,16(sp)
    80001138:	6ba2                	ld	s7,8(sp)
    8000113a:	6161                	addi	sp,sp,80
    8000113c:	8082                	ret
  return 0;
    8000113e:	4501                	li	a0,0
    80001140:	b7e5                	j	80001128 <mappages+0x74>

0000000080001142 <kvmmap>:
{
    80001142:	1141                	addi	sp,sp,-16
    80001144:	e406                	sd	ra,8(sp)
    80001146:	e022                	sd	s0,0(sp)
    80001148:	0800                	addi	s0,sp,16
    8000114a:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000114c:	86b2                	mv	a3,a2
    8000114e:	863e                	mv	a2,a5
    80001150:	00000097          	auipc	ra,0x0
    80001154:	f64080e7          	jalr	-156(ra) # 800010b4 <mappages>
    80001158:	e509                	bnez	a0,80001162 <kvmmap+0x20>
}
    8000115a:	60a2                	ld	ra,8(sp)
    8000115c:	6402                	ld	s0,0(sp)
    8000115e:	0141                	addi	sp,sp,16
    80001160:	8082                	ret
    panic("kvmmap");
    80001162:	00008517          	auipc	a0,0x8
    80001166:	fb650513          	addi	a0,a0,-74 # 80009118 <digits+0xd8>
    8000116a:	fffff097          	auipc	ra,0xfffff
    8000116e:	3c4080e7          	jalr	964(ra) # 8000052e <panic>

0000000080001172 <kvmmake>:
{
    80001172:	1101                	addi	sp,sp,-32
    80001174:	ec06                	sd	ra,24(sp)
    80001176:	e822                	sd	s0,16(sp)
    80001178:	e426                	sd	s1,8(sp)
    8000117a:	e04a                	sd	s2,0(sp)
    8000117c:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117e:	00000097          	auipc	ra,0x0
    80001182:	958080e7          	jalr	-1704(ra) # 80000ad6 <kalloc>
    80001186:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001188:	6605                	lui	a2,0x1
    8000118a:	4581                	li	a1,0
    8000118c:	00000097          	auipc	ra,0x0
    80001190:	b58080e7          	jalr	-1192(ra) # 80000ce4 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001194:	4719                	li	a4,6
    80001196:	6685                	lui	a3,0x1
    80001198:	10000637          	lui	a2,0x10000
    8000119c:	100005b7          	lui	a1,0x10000
    800011a0:	8526                	mv	a0,s1
    800011a2:	00000097          	auipc	ra,0x0
    800011a6:	fa0080e7          	jalr	-96(ra) # 80001142 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011aa:	4719                	li	a4,6
    800011ac:	6685                	lui	a3,0x1
    800011ae:	10001637          	lui	a2,0x10001
    800011b2:	100015b7          	lui	a1,0x10001
    800011b6:	8526                	mv	a0,s1
    800011b8:	00000097          	auipc	ra,0x0
    800011bc:	f8a080e7          	jalr	-118(ra) # 80001142 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011c0:	4719                	li	a4,6
    800011c2:	004006b7          	lui	a3,0x400
    800011c6:	0c000637          	lui	a2,0xc000
    800011ca:	0c0005b7          	lui	a1,0xc000
    800011ce:	8526                	mv	a0,s1
    800011d0:	00000097          	auipc	ra,0x0
    800011d4:	f72080e7          	jalr	-142(ra) # 80001142 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d8:	00008917          	auipc	s2,0x8
    800011dc:	e2890913          	addi	s2,s2,-472 # 80009000 <etext>
    800011e0:	4729                	li	a4,10
    800011e2:	80008697          	auipc	a3,0x80008
    800011e6:	e1e68693          	addi	a3,a3,-482 # 9000 <_entry-0x7fff7000>
    800011ea:	4605                	li	a2,1
    800011ec:	067e                	slli	a2,a2,0x1f
    800011ee:	85b2                	mv	a1,a2
    800011f0:	8526                	mv	a0,s1
    800011f2:	00000097          	auipc	ra,0x0
    800011f6:	f50080e7          	jalr	-176(ra) # 80001142 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011fa:	4719                	li	a4,6
    800011fc:	46c5                	li	a3,17
    800011fe:	06ee                	slli	a3,a3,0x1b
    80001200:	412686b3          	sub	a3,a3,s2
    80001204:	864a                	mv	a2,s2
    80001206:	85ca                	mv	a1,s2
    80001208:	8526                	mv	a0,s1
    8000120a:	00000097          	auipc	ra,0x0
    8000120e:	f38080e7          	jalr	-200(ra) # 80001142 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001212:	4729                	li	a4,10
    80001214:	6685                	lui	a3,0x1
    80001216:	00007617          	auipc	a2,0x7
    8000121a:	dea60613          	addi	a2,a2,-534 # 80008000 <_trampoline>
    8000121e:	040005b7          	lui	a1,0x4000
    80001222:	15fd                	addi	a1,a1,-1
    80001224:	05b2                	slli	a1,a1,0xc
    80001226:	8526                	mv	a0,s1
    80001228:	00000097          	auipc	ra,0x0
    8000122c:	f1a080e7          	jalr	-230(ra) # 80001142 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001230:	8526                	mv	a0,s1
    80001232:	00000097          	auipc	ra,0x0
    80001236:	600080e7          	jalr	1536(ra) # 80001832 <proc_mapstacks>
}
    8000123a:	8526                	mv	a0,s1
    8000123c:	60e2                	ld	ra,24(sp)
    8000123e:	6442                	ld	s0,16(sp)
    80001240:	64a2                	ld	s1,8(sp)
    80001242:	6902                	ld	s2,0(sp)
    80001244:	6105                	addi	sp,sp,32
    80001246:	8082                	ret

0000000080001248 <kvminit>:
{
    80001248:	1141                	addi	sp,sp,-16
    8000124a:	e406                	sd	ra,8(sp)
    8000124c:	e022                	sd	s0,0(sp)
    8000124e:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001250:	00000097          	auipc	ra,0x0
    80001254:	f22080e7          	jalr	-222(ra) # 80001172 <kvmmake>
    80001258:	00009797          	auipc	a5,0x9
    8000125c:	dca7b423          	sd	a0,-568(a5) # 8000a020 <kernel_pagetable>
}
    80001260:	60a2                	ld	ra,8(sp)
    80001262:	6402                	ld	s0,0(sp)
    80001264:	0141                	addi	sp,sp,16
    80001266:	8082                	ret

0000000080001268 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001268:	715d                	addi	sp,sp,-80
    8000126a:	e486                	sd	ra,72(sp)
    8000126c:	e0a2                	sd	s0,64(sp)
    8000126e:	fc26                	sd	s1,56(sp)
    80001270:	f84a                	sd	s2,48(sp)
    80001272:	f44e                	sd	s3,40(sp)
    80001274:	f052                	sd	s4,32(sp)
    80001276:	ec56                	sd	s5,24(sp)
    80001278:	e85a                	sd	s6,16(sp)
    8000127a:	e45e                	sd	s7,8(sp)
    8000127c:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127e:	03459793          	slli	a5,a1,0x34
    80001282:	e795                	bnez	a5,800012ae <uvmunmap+0x46>
    80001284:	8a2a                	mv	s4,a0
    80001286:	892e                	mv	s2,a1
    80001288:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128a:	0632                	slli	a2,a2,0xc
    8000128c:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001290:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001292:	6b05                	lui	s6,0x1
    80001294:	0735e263          	bltu	a1,s3,800012f8 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001298:	60a6                	ld	ra,72(sp)
    8000129a:	6406                	ld	s0,64(sp)
    8000129c:	74e2                	ld	s1,56(sp)
    8000129e:	7942                	ld	s2,48(sp)
    800012a0:	79a2                	ld	s3,40(sp)
    800012a2:	7a02                	ld	s4,32(sp)
    800012a4:	6ae2                	ld	s5,24(sp)
    800012a6:	6b42                	ld	s6,16(sp)
    800012a8:	6ba2                	ld	s7,8(sp)
    800012aa:	6161                	addi	sp,sp,80
    800012ac:	8082                	ret
    panic("uvmunmap: not aligned");
    800012ae:	00008517          	auipc	a0,0x8
    800012b2:	e7250513          	addi	a0,a0,-398 # 80009120 <digits+0xe0>
    800012b6:	fffff097          	auipc	ra,0xfffff
    800012ba:	278080e7          	jalr	632(ra) # 8000052e <panic>
      panic("uvmunmap: walk");
    800012be:	00008517          	auipc	a0,0x8
    800012c2:	e7a50513          	addi	a0,a0,-390 # 80009138 <digits+0xf8>
    800012c6:	fffff097          	auipc	ra,0xfffff
    800012ca:	268080e7          	jalr	616(ra) # 8000052e <panic>
      panic("uvmunmap: not mapped");
    800012ce:	00008517          	auipc	a0,0x8
    800012d2:	e7a50513          	addi	a0,a0,-390 # 80009148 <digits+0x108>
    800012d6:	fffff097          	auipc	ra,0xfffff
    800012da:	258080e7          	jalr	600(ra) # 8000052e <panic>
      panic("uvmunmap: not a leaf");
    800012de:	00008517          	auipc	a0,0x8
    800012e2:	e8250513          	addi	a0,a0,-382 # 80009160 <digits+0x120>
    800012e6:	fffff097          	auipc	ra,0xfffff
    800012ea:	248080e7          	jalr	584(ra) # 8000052e <panic>
    *pte = 0;
    800012ee:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012f2:	995a                	add	s2,s2,s6
    800012f4:	fb3972e3          	bgeu	s2,s3,80001298 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f8:	4601                	li	a2,0
    800012fa:	85ca                	mv	a1,s2
    800012fc:	8552                	mv	a0,s4
    800012fe:	00000097          	auipc	ra,0x0
    80001302:	cce080e7          	jalr	-818(ra) # 80000fcc <walk>
    80001306:	84aa                	mv	s1,a0
    80001308:	d95d                	beqz	a0,800012be <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000130a:	6108                	ld	a0,0(a0)
    8000130c:	00157793          	andi	a5,a0,1
    80001310:	dfdd                	beqz	a5,800012ce <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001312:	3ff57793          	andi	a5,a0,1023
    80001316:	fd7784e3          	beq	a5,s7,800012de <uvmunmap+0x76>
    if(do_free){
    8000131a:	fc0a8ae3          	beqz	s5,800012ee <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131e:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001320:	0532                	slli	a0,a0,0xc
    80001322:	fffff097          	auipc	ra,0xfffff
    80001326:	6b8080e7          	jalr	1720(ra) # 800009da <kfree>
    8000132a:	b7d1                	j	800012ee <uvmunmap+0x86>

000000008000132c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000132c:	1101                	addi	sp,sp,-32
    8000132e:	ec06                	sd	ra,24(sp)
    80001330:	e822                	sd	s0,16(sp)
    80001332:	e426                	sd	s1,8(sp)
    80001334:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001336:	fffff097          	auipc	ra,0xfffff
    8000133a:	7a0080e7          	jalr	1952(ra) # 80000ad6 <kalloc>
    8000133e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001340:	c519                	beqz	a0,8000134e <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001342:	6605                	lui	a2,0x1
    80001344:	4581                	li	a1,0
    80001346:	00000097          	auipc	ra,0x0
    8000134a:	99e080e7          	jalr	-1634(ra) # 80000ce4 <memset>
  return pagetable;
}
    8000134e:	8526                	mv	a0,s1
    80001350:	60e2                	ld	ra,24(sp)
    80001352:	6442                	ld	s0,16(sp)
    80001354:	64a2                	ld	s1,8(sp)
    80001356:	6105                	addi	sp,sp,32
    80001358:	8082                	ret

000000008000135a <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000135a:	7179                	addi	sp,sp,-48
    8000135c:	f406                	sd	ra,40(sp)
    8000135e:	f022                	sd	s0,32(sp)
    80001360:	ec26                	sd	s1,24(sp)
    80001362:	e84a                	sd	s2,16(sp)
    80001364:	e44e                	sd	s3,8(sp)
    80001366:	e052                	sd	s4,0(sp)
    80001368:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000136a:	6785                	lui	a5,0x1
    8000136c:	04f67863          	bgeu	a2,a5,800013bc <uvminit+0x62>
    80001370:	8a2a                	mv	s4,a0
    80001372:	89ae                	mv	s3,a1
    80001374:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001376:	fffff097          	auipc	ra,0xfffff
    8000137a:	760080e7          	jalr	1888(ra) # 80000ad6 <kalloc>
    8000137e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001380:	6605                	lui	a2,0x1
    80001382:	4581                	li	a1,0
    80001384:	00000097          	auipc	ra,0x0
    80001388:	960080e7          	jalr	-1696(ra) # 80000ce4 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000138c:	4779                	li	a4,30
    8000138e:	86ca                	mv	a3,s2
    80001390:	6605                	lui	a2,0x1
    80001392:	4581                	li	a1,0
    80001394:	8552                	mv	a0,s4
    80001396:	00000097          	auipc	ra,0x0
    8000139a:	d1e080e7          	jalr	-738(ra) # 800010b4 <mappages>
  memmove(mem, src, sz);
    8000139e:	8626                	mv	a2,s1
    800013a0:	85ce                	mv	a1,s3
    800013a2:	854a                	mv	a0,s2
    800013a4:	00000097          	auipc	ra,0x0
    800013a8:	99c080e7          	jalr	-1636(ra) # 80000d40 <memmove>
}
    800013ac:	70a2                	ld	ra,40(sp)
    800013ae:	7402                	ld	s0,32(sp)
    800013b0:	64e2                	ld	s1,24(sp)
    800013b2:	6942                	ld	s2,16(sp)
    800013b4:	69a2                	ld	s3,8(sp)
    800013b6:	6a02                	ld	s4,0(sp)
    800013b8:	6145                	addi	sp,sp,48
    800013ba:	8082                	ret
    panic("inituvm: more than a page");
    800013bc:	00008517          	auipc	a0,0x8
    800013c0:	dbc50513          	addi	a0,a0,-580 # 80009178 <digits+0x138>
    800013c4:	fffff097          	auipc	ra,0xfffff
    800013c8:	16a080e7          	jalr	362(ra) # 8000052e <panic>

00000000800013cc <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013cc:	1101                	addi	sp,sp,-32
    800013ce:	ec06                	sd	ra,24(sp)
    800013d0:	e822                	sd	s0,16(sp)
    800013d2:	e426                	sd	s1,8(sp)
    800013d4:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d6:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d8:	00b67d63          	bgeu	a2,a1,800013f2 <uvmdealloc+0x26>
    800013dc:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013de:	6785                	lui	a5,0x1
    800013e0:	17fd                	addi	a5,a5,-1
    800013e2:	00f60733          	add	a4,a2,a5
    800013e6:	767d                	lui	a2,0xfffff
    800013e8:	8f71                	and	a4,a4,a2
    800013ea:	97ae                	add	a5,a5,a1
    800013ec:	8ff1                	and	a5,a5,a2
    800013ee:	00f76863          	bltu	a4,a5,800013fe <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013f2:	8526                	mv	a0,s1
    800013f4:	60e2                	ld	ra,24(sp)
    800013f6:	6442                	ld	s0,16(sp)
    800013f8:	64a2                	ld	s1,8(sp)
    800013fa:	6105                	addi	sp,sp,32
    800013fc:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fe:	8f99                	sub	a5,a5,a4
    80001400:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001402:	4685                	li	a3,1
    80001404:	0007861b          	sext.w	a2,a5
    80001408:	85ba                	mv	a1,a4
    8000140a:	00000097          	auipc	ra,0x0
    8000140e:	e5e080e7          	jalr	-418(ra) # 80001268 <uvmunmap>
    80001412:	b7c5                	j	800013f2 <uvmdealloc+0x26>

0000000080001414 <uvmalloc>:
  if(newsz < oldsz)
    80001414:	0ab66163          	bltu	a2,a1,800014b6 <uvmalloc+0xa2>
{
    80001418:	7139                	addi	sp,sp,-64
    8000141a:	fc06                	sd	ra,56(sp)
    8000141c:	f822                	sd	s0,48(sp)
    8000141e:	f426                	sd	s1,40(sp)
    80001420:	f04a                	sd	s2,32(sp)
    80001422:	ec4e                	sd	s3,24(sp)
    80001424:	e852                	sd	s4,16(sp)
    80001426:	e456                	sd	s5,8(sp)
    80001428:	0080                	addi	s0,sp,64
    8000142a:	8aaa                	mv	s5,a0
    8000142c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142e:	6985                	lui	s3,0x1
    80001430:	19fd                	addi	s3,s3,-1
    80001432:	95ce                	add	a1,a1,s3
    80001434:	79fd                	lui	s3,0xfffff
    80001436:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000143a:	08c9f063          	bgeu	s3,a2,800014ba <uvmalloc+0xa6>
    8000143e:	894e                	mv	s2,s3
    mem = kalloc();
    80001440:	fffff097          	auipc	ra,0xfffff
    80001444:	696080e7          	jalr	1686(ra) # 80000ad6 <kalloc>
    80001448:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144a:	c51d                	beqz	a0,80001478 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000144c:	6605                	lui	a2,0x1
    8000144e:	4581                	li	a1,0
    80001450:	00000097          	auipc	ra,0x0
    80001454:	894080e7          	jalr	-1900(ra) # 80000ce4 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001458:	4779                	li	a4,30
    8000145a:	86a6                	mv	a3,s1
    8000145c:	6605                	lui	a2,0x1
    8000145e:	85ca                	mv	a1,s2
    80001460:	8556                	mv	a0,s5
    80001462:	00000097          	auipc	ra,0x0
    80001466:	c52080e7          	jalr	-942(ra) # 800010b4 <mappages>
    8000146a:	e905                	bnez	a0,8000149a <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146c:	6785                	lui	a5,0x1
    8000146e:	993e                	add	s2,s2,a5
    80001470:	fd4968e3          	bltu	s2,s4,80001440 <uvmalloc+0x2c>
  return newsz;
    80001474:	8552                	mv	a0,s4
    80001476:	a809                	j	80001488 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001478:	864e                	mv	a2,s3
    8000147a:	85ca                	mv	a1,s2
    8000147c:	8556                	mv	a0,s5
    8000147e:	00000097          	auipc	ra,0x0
    80001482:	f4e080e7          	jalr	-178(ra) # 800013cc <uvmdealloc>
      return 0;
    80001486:	4501                	li	a0,0
}
    80001488:	70e2                	ld	ra,56(sp)
    8000148a:	7442                	ld	s0,48(sp)
    8000148c:	74a2                	ld	s1,40(sp)
    8000148e:	7902                	ld	s2,32(sp)
    80001490:	69e2                	ld	s3,24(sp)
    80001492:	6a42                	ld	s4,16(sp)
    80001494:	6aa2                	ld	s5,8(sp)
    80001496:	6121                	addi	sp,sp,64
    80001498:	8082                	ret
      kfree(mem);
    8000149a:	8526                	mv	a0,s1
    8000149c:	fffff097          	auipc	ra,0xfffff
    800014a0:	53e080e7          	jalr	1342(ra) # 800009da <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a4:	864e                	mv	a2,s3
    800014a6:	85ca                	mv	a1,s2
    800014a8:	8556                	mv	a0,s5
    800014aa:	00000097          	auipc	ra,0x0
    800014ae:	f22080e7          	jalr	-222(ra) # 800013cc <uvmdealloc>
      return 0;
    800014b2:	4501                	li	a0,0
    800014b4:	bfd1                	j	80001488 <uvmalloc+0x74>
    return oldsz;
    800014b6:	852e                	mv	a0,a1
}
    800014b8:	8082                	ret
  return newsz;
    800014ba:	8532                	mv	a0,a2
    800014bc:	b7f1                	j	80001488 <uvmalloc+0x74>

00000000800014be <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014be:	7179                	addi	sp,sp,-48
    800014c0:	f406                	sd	ra,40(sp)
    800014c2:	f022                	sd	s0,32(sp)
    800014c4:	ec26                	sd	s1,24(sp)
    800014c6:	e84a                	sd	s2,16(sp)
    800014c8:	e44e                	sd	s3,8(sp)
    800014ca:	e052                	sd	s4,0(sp)
    800014cc:	1800                	addi	s0,sp,48
    800014ce:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d0:	84aa                	mv	s1,a0
    800014d2:	6905                	lui	s2,0x1
    800014d4:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014d6:	4985                	li	s3,1
    800014d8:	a821                	j	800014f0 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014da:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014dc:	0532                	slli	a0,a0,0xc
    800014de:	00000097          	auipc	ra,0x0
    800014e2:	fe0080e7          	jalr	-32(ra) # 800014be <freewalk>
      pagetable[i] = 0;
    800014e6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ea:	04a1                	addi	s1,s1,8
    800014ec:	03248163          	beq	s1,s2,8000150e <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014f0:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f2:	00f57793          	andi	a5,a0,15
    800014f6:	ff3782e3          	beq	a5,s3,800014da <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fa:	8905                	andi	a0,a0,1
    800014fc:	d57d                	beqz	a0,800014ea <freewalk+0x2c>
      panic("freewalk: leaf");
    800014fe:	00008517          	auipc	a0,0x8
    80001502:	c9a50513          	addi	a0,a0,-870 # 80009198 <digits+0x158>
    80001506:	fffff097          	auipc	ra,0xfffff
    8000150a:	028080e7          	jalr	40(ra) # 8000052e <panic>
    }
  }
  kfree((void*)pagetable);
    8000150e:	8552                	mv	a0,s4
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	4ca080e7          	jalr	1226(ra) # 800009da <kfree>
}
    80001518:	70a2                	ld	ra,40(sp)
    8000151a:	7402                	ld	s0,32(sp)
    8000151c:	64e2                	ld	s1,24(sp)
    8000151e:	6942                	ld	s2,16(sp)
    80001520:	69a2                	ld	s3,8(sp)
    80001522:	6a02                	ld	s4,0(sp)
    80001524:	6145                	addi	sp,sp,48
    80001526:	8082                	ret

0000000080001528 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001528:	1101                	addi	sp,sp,-32
    8000152a:	ec06                	sd	ra,24(sp)
    8000152c:	e822                	sd	s0,16(sp)
    8000152e:	e426                	sd	s1,8(sp)
    80001530:	1000                	addi	s0,sp,32
    80001532:	84aa                	mv	s1,a0
  if(sz > 0)
    80001534:	e999                	bnez	a1,8000154a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001536:	8526                	mv	a0,s1
    80001538:	00000097          	auipc	ra,0x0
    8000153c:	f86080e7          	jalr	-122(ra) # 800014be <freewalk>
}
    80001540:	60e2                	ld	ra,24(sp)
    80001542:	6442                	ld	s0,16(sp)
    80001544:	64a2                	ld	s1,8(sp)
    80001546:	6105                	addi	sp,sp,32
    80001548:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154a:	6605                	lui	a2,0x1
    8000154c:	167d                	addi	a2,a2,-1
    8000154e:	962e                	add	a2,a2,a1
    80001550:	4685                	li	a3,1
    80001552:	8231                	srli	a2,a2,0xc
    80001554:	4581                	li	a1,0
    80001556:	00000097          	auipc	ra,0x0
    8000155a:	d12080e7          	jalr	-750(ra) # 80001268 <uvmunmap>
    8000155e:	bfe1                	j	80001536 <uvmfree+0xe>

0000000080001560 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001560:	c679                	beqz	a2,8000162e <uvmcopy+0xce>
{
    80001562:	715d                	addi	sp,sp,-80
    80001564:	e486                	sd	ra,72(sp)
    80001566:	e0a2                	sd	s0,64(sp)
    80001568:	fc26                	sd	s1,56(sp)
    8000156a:	f84a                	sd	s2,48(sp)
    8000156c:	f44e                	sd	s3,40(sp)
    8000156e:	f052                	sd	s4,32(sp)
    80001570:	ec56                	sd	s5,24(sp)
    80001572:	e85a                	sd	s6,16(sp)
    80001574:	e45e                	sd	s7,8(sp)
    80001576:	0880                	addi	s0,sp,80
    80001578:	8b2a                	mv	s6,a0
    8000157a:	8aae                	mv	s5,a1
    8000157c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000157e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001580:	4601                	li	a2,0
    80001582:	85ce                	mv	a1,s3
    80001584:	855a                	mv	a0,s6
    80001586:	00000097          	auipc	ra,0x0
    8000158a:	a46080e7          	jalr	-1466(ra) # 80000fcc <walk>
    8000158e:	c531                	beqz	a0,800015da <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001590:	6118                	ld	a4,0(a0)
    80001592:	00177793          	andi	a5,a4,1
    80001596:	cbb1                	beqz	a5,800015ea <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001598:	00a75593          	srli	a1,a4,0xa
    8000159c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a0:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a4:	fffff097          	auipc	ra,0xfffff
    800015a8:	532080e7          	jalr	1330(ra) # 80000ad6 <kalloc>
    800015ac:	892a                	mv	s2,a0
    800015ae:	c939                	beqz	a0,80001604 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b0:	6605                	lui	a2,0x1
    800015b2:	85de                	mv	a1,s7
    800015b4:	fffff097          	auipc	ra,0xfffff
    800015b8:	78c080e7          	jalr	1932(ra) # 80000d40 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015bc:	8726                	mv	a4,s1
    800015be:	86ca                	mv	a3,s2
    800015c0:	6605                	lui	a2,0x1
    800015c2:	85ce                	mv	a1,s3
    800015c4:	8556                	mv	a0,s5
    800015c6:	00000097          	auipc	ra,0x0
    800015ca:	aee080e7          	jalr	-1298(ra) # 800010b4 <mappages>
    800015ce:	e515                	bnez	a0,800015fa <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d0:	6785                	lui	a5,0x1
    800015d2:	99be                	add	s3,s3,a5
    800015d4:	fb49e6e3          	bltu	s3,s4,80001580 <uvmcopy+0x20>
    800015d8:	a081                	j	80001618 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015da:	00008517          	auipc	a0,0x8
    800015de:	bce50513          	addi	a0,a0,-1074 # 800091a8 <digits+0x168>
    800015e2:	fffff097          	auipc	ra,0xfffff
    800015e6:	f4c080e7          	jalr	-180(ra) # 8000052e <panic>
      panic("uvmcopy: page not present");
    800015ea:	00008517          	auipc	a0,0x8
    800015ee:	bde50513          	addi	a0,a0,-1058 # 800091c8 <digits+0x188>
    800015f2:	fffff097          	auipc	ra,0xfffff
    800015f6:	f3c080e7          	jalr	-196(ra) # 8000052e <panic>
      kfree(mem);
    800015fa:	854a                	mv	a0,s2
    800015fc:	fffff097          	auipc	ra,0xfffff
    80001600:	3de080e7          	jalr	990(ra) # 800009da <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001604:	4685                	li	a3,1
    80001606:	00c9d613          	srli	a2,s3,0xc
    8000160a:	4581                	li	a1,0
    8000160c:	8556                	mv	a0,s5
    8000160e:	00000097          	auipc	ra,0x0
    80001612:	c5a080e7          	jalr	-934(ra) # 80001268 <uvmunmap>
  return -1;
    80001616:	557d                	li	a0,-1
}
    80001618:	60a6                	ld	ra,72(sp)
    8000161a:	6406                	ld	s0,64(sp)
    8000161c:	74e2                	ld	s1,56(sp)
    8000161e:	7942                	ld	s2,48(sp)
    80001620:	79a2                	ld	s3,40(sp)
    80001622:	7a02                	ld	s4,32(sp)
    80001624:	6ae2                	ld	s5,24(sp)
    80001626:	6b42                	ld	s6,16(sp)
    80001628:	6ba2                	ld	s7,8(sp)
    8000162a:	6161                	addi	sp,sp,80
    8000162c:	8082                	ret
  return 0;
    8000162e:	4501                	li	a0,0
}
    80001630:	8082                	ret

0000000080001632 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001632:	1141                	addi	sp,sp,-16
    80001634:	e406                	sd	ra,8(sp)
    80001636:	e022                	sd	s0,0(sp)
    80001638:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163a:	4601                	li	a2,0
    8000163c:	00000097          	auipc	ra,0x0
    80001640:	990080e7          	jalr	-1648(ra) # 80000fcc <walk>
  if(pte == 0)
    80001644:	c901                	beqz	a0,80001654 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001646:	611c                	ld	a5,0(a0)
    80001648:	9bbd                	andi	a5,a5,-17
    8000164a:	e11c                	sd	a5,0(a0)
}
    8000164c:	60a2                	ld	ra,8(sp)
    8000164e:	6402                	ld	s0,0(sp)
    80001650:	0141                	addi	sp,sp,16
    80001652:	8082                	ret
    panic("uvmclear");
    80001654:	00008517          	auipc	a0,0x8
    80001658:	b9450513          	addi	a0,a0,-1132 # 800091e8 <digits+0x1a8>
    8000165c:	fffff097          	auipc	ra,0xfffff
    80001660:	ed2080e7          	jalr	-302(ra) # 8000052e <panic>

0000000080001664 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001664:	c6bd                	beqz	a3,800016d2 <copyout+0x6e>
{
    80001666:	715d                	addi	sp,sp,-80
    80001668:	e486                	sd	ra,72(sp)
    8000166a:	e0a2                	sd	s0,64(sp)
    8000166c:	fc26                	sd	s1,56(sp)
    8000166e:	f84a                	sd	s2,48(sp)
    80001670:	f44e                	sd	s3,40(sp)
    80001672:	f052                	sd	s4,32(sp)
    80001674:	ec56                	sd	s5,24(sp)
    80001676:	e85a                	sd	s6,16(sp)
    80001678:	e45e                	sd	s7,8(sp)
    8000167a:	e062                	sd	s8,0(sp)
    8000167c:	0880                	addi	s0,sp,80
    8000167e:	8b2a                	mv	s6,a0
    80001680:	8c2e                	mv	s8,a1
    80001682:	8a32                	mv	s4,a2
    80001684:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001686:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001688:	6a85                	lui	s5,0x1
    8000168a:	a015                	j	800016ae <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168c:	9562                	add	a0,a0,s8
    8000168e:	0004861b          	sext.w	a2,s1
    80001692:	85d2                	mv	a1,s4
    80001694:	41250533          	sub	a0,a0,s2
    80001698:	fffff097          	auipc	ra,0xfffff
    8000169c:	6a8080e7          	jalr	1704(ra) # 80000d40 <memmove>

    len -= n;
    800016a0:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a4:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016a6:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016aa:	02098263          	beqz	s3,800016ce <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016ae:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b2:	85ca                	mv	a1,s2
    800016b4:	855a                	mv	a0,s6
    800016b6:	00000097          	auipc	ra,0x0
    800016ba:	9bc080e7          	jalr	-1604(ra) # 80001072 <walkaddr>
    if(pa0 == 0)
    800016be:	cd01                	beqz	a0,800016d6 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c0:	418904b3          	sub	s1,s2,s8
    800016c4:	94d6                	add	s1,s1,s5
    if(n > len)
    800016c6:	fc99f3e3          	bgeu	s3,s1,8000168c <copyout+0x28>
    800016ca:	84ce                	mv	s1,s3
    800016cc:	b7c1                	j	8000168c <copyout+0x28>
  }
  return 0;
    800016ce:	4501                	li	a0,0
    800016d0:	a021                	j	800016d8 <copyout+0x74>
    800016d2:	4501                	li	a0,0
}
    800016d4:	8082                	ret
      return -1;
    800016d6:	557d                	li	a0,-1
}
    800016d8:	60a6                	ld	ra,72(sp)
    800016da:	6406                	ld	s0,64(sp)
    800016dc:	74e2                	ld	s1,56(sp)
    800016de:	7942                	ld	s2,48(sp)
    800016e0:	79a2                	ld	s3,40(sp)
    800016e2:	7a02                	ld	s4,32(sp)
    800016e4:	6ae2                	ld	s5,24(sp)
    800016e6:	6b42                	ld	s6,16(sp)
    800016e8:	6ba2                	ld	s7,8(sp)
    800016ea:	6c02                	ld	s8,0(sp)
    800016ec:	6161                	addi	sp,sp,80
    800016ee:	8082                	ret

00000000800016f0 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f0:	caa5                	beqz	a3,80001760 <copyin+0x70>
{
    800016f2:	715d                	addi	sp,sp,-80
    800016f4:	e486                	sd	ra,72(sp)
    800016f6:	e0a2                	sd	s0,64(sp)
    800016f8:	fc26                	sd	s1,56(sp)
    800016fa:	f84a                	sd	s2,48(sp)
    800016fc:	f44e                	sd	s3,40(sp)
    800016fe:	f052                	sd	s4,32(sp)
    80001700:	ec56                	sd	s5,24(sp)
    80001702:	e85a                	sd	s6,16(sp)
    80001704:	e45e                	sd	s7,8(sp)
    80001706:	e062                	sd	s8,0(sp)
    80001708:	0880                	addi	s0,sp,80
    8000170a:	8b2a                	mv	s6,a0
    8000170c:	8a2e                	mv	s4,a1
    8000170e:	8c32                	mv	s8,a2
    80001710:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001712:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001714:	6a85                	lui	s5,0x1
    80001716:	a01d                	j	8000173c <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001718:	018505b3          	add	a1,a0,s8
    8000171c:	0004861b          	sext.w	a2,s1
    80001720:	412585b3          	sub	a1,a1,s2
    80001724:	8552                	mv	a0,s4
    80001726:	fffff097          	auipc	ra,0xfffff
    8000172a:	61a080e7          	jalr	1562(ra) # 80000d40 <memmove>

    len -= n;
    8000172e:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001732:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001734:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001738:	02098263          	beqz	s3,8000175c <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000173c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001740:	85ca                	mv	a1,s2
    80001742:	855a                	mv	a0,s6
    80001744:	00000097          	auipc	ra,0x0
    80001748:	92e080e7          	jalr	-1746(ra) # 80001072 <walkaddr>
    if(pa0 == 0)
    8000174c:	cd01                	beqz	a0,80001764 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000174e:	418904b3          	sub	s1,s2,s8
    80001752:	94d6                	add	s1,s1,s5
    if(n > len)
    80001754:	fc99f2e3          	bgeu	s3,s1,80001718 <copyin+0x28>
    80001758:	84ce                	mv	s1,s3
    8000175a:	bf7d                	j	80001718 <copyin+0x28>
  }
  return 0;
    8000175c:	4501                	li	a0,0
    8000175e:	a021                	j	80001766 <copyin+0x76>
    80001760:	4501                	li	a0,0
}
    80001762:	8082                	ret
      return -1;
    80001764:	557d                	li	a0,-1
}
    80001766:	60a6                	ld	ra,72(sp)
    80001768:	6406                	ld	s0,64(sp)
    8000176a:	74e2                	ld	s1,56(sp)
    8000176c:	7942                	ld	s2,48(sp)
    8000176e:	79a2                	ld	s3,40(sp)
    80001770:	7a02                	ld	s4,32(sp)
    80001772:	6ae2                	ld	s5,24(sp)
    80001774:	6b42                	ld	s6,16(sp)
    80001776:	6ba2                	ld	s7,8(sp)
    80001778:	6c02                	ld	s8,0(sp)
    8000177a:	6161                	addi	sp,sp,80
    8000177c:	8082                	ret

000000008000177e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000177e:	c6c5                	beqz	a3,80001826 <copyinstr+0xa8>
{
    80001780:	715d                	addi	sp,sp,-80
    80001782:	e486                	sd	ra,72(sp)
    80001784:	e0a2                	sd	s0,64(sp)
    80001786:	fc26                	sd	s1,56(sp)
    80001788:	f84a                	sd	s2,48(sp)
    8000178a:	f44e                	sd	s3,40(sp)
    8000178c:	f052                	sd	s4,32(sp)
    8000178e:	ec56                	sd	s5,24(sp)
    80001790:	e85a                	sd	s6,16(sp)
    80001792:	e45e                	sd	s7,8(sp)
    80001794:	0880                	addi	s0,sp,80
    80001796:	8a2a                	mv	s4,a0
    80001798:	8b2e                	mv	s6,a1
    8000179a:	8bb2                	mv	s7,a2
    8000179c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000179e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a0:	6985                	lui	s3,0x1
    800017a2:	a035                	j	800017ce <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017a8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017aa:	0017b793          	seqz	a5,a5
    800017ae:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b2:	60a6                	ld	ra,72(sp)
    800017b4:	6406                	ld	s0,64(sp)
    800017b6:	74e2                	ld	s1,56(sp)
    800017b8:	7942                	ld	s2,48(sp)
    800017ba:	79a2                	ld	s3,40(sp)
    800017bc:	7a02                	ld	s4,32(sp)
    800017be:	6ae2                	ld	s5,24(sp)
    800017c0:	6b42                	ld	s6,16(sp)
    800017c2:	6ba2                	ld	s7,8(sp)
    800017c4:	6161                	addi	sp,sp,80
    800017c6:	8082                	ret
    srcva = va0 + PGSIZE;
    800017c8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017cc:	c8a9                	beqz	s1,8000181e <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017ce:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d2:	85ca                	mv	a1,s2
    800017d4:	8552                	mv	a0,s4
    800017d6:	00000097          	auipc	ra,0x0
    800017da:	89c080e7          	jalr	-1892(ra) # 80001072 <walkaddr>
    if(pa0 == 0)
    800017de:	c131                	beqz	a0,80001822 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017e0:	41790833          	sub	a6,s2,s7
    800017e4:	984e                	add	a6,a6,s3
    if(n > max)
    800017e6:	0104f363          	bgeu	s1,a6,800017ec <copyinstr+0x6e>
    800017ea:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017ec:	955e                	add	a0,a0,s7
    800017ee:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f2:	fc080be3          	beqz	a6,800017c8 <copyinstr+0x4a>
    800017f6:	985a                	add	a6,a6,s6
    800017f8:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fa:	41650633          	sub	a2,a0,s6
    800017fe:	14fd                	addi	s1,s1,-1
    80001800:	9b26                	add	s6,s6,s1
    80001802:	00f60733          	add	a4,a2,a5
    80001806:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffbd000>
    8000180a:	df49                	beqz	a4,800017a4 <copyinstr+0x26>
        *dst = *p;
    8000180c:	00e78023          	sb	a4,0(a5)
      --max;
    80001810:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001814:	0785                	addi	a5,a5,1
    while(n > 0){
    80001816:	ff0796e3          	bne	a5,a6,80001802 <copyinstr+0x84>
      dst++;
    8000181a:	8b42                	mv	s6,a6
    8000181c:	b775                	j	800017c8 <copyinstr+0x4a>
    8000181e:	4781                	li	a5,0
    80001820:	b769                	j	800017aa <copyinstr+0x2c>
      return -1;
    80001822:	557d                	li	a0,-1
    80001824:	b779                	j	800017b2 <copyinstr+0x34>
  int got_null = 0;
    80001826:	4781                	li	a5,0
  if(got_null){
    80001828:	0017b793          	seqz	a5,a5
    8000182c:	40f00533          	neg	a0,a5
}
    80001830:	8082                	ret

0000000080001832 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001832:	711d                	addi	sp,sp,-96
    80001834:	ec86                	sd	ra,88(sp)
    80001836:	e8a2                	sd	s0,80(sp)
    80001838:	e4a6                	sd	s1,72(sp)
    8000183a:	e0ca                	sd	s2,64(sp)
    8000183c:	fc4e                	sd	s3,56(sp)
    8000183e:	f852                	sd	s4,48(sp)
    80001840:	f456                	sd	s5,40(sp)
    80001842:	f05a                	sd	s6,32(sp)
    80001844:	ec5e                	sd	s7,24(sp)
    80001846:	e862                	sd	s8,16(sp)
    80001848:	e466                	sd	s9,8(sp)
    8000184a:	e06a                	sd	s10,0(sp)
    8000184c:	1080                	addi	s0,sp,96
    8000184e:	8b2a                	mv	s6,a0
  struct proc *p;
  struct kthread *t;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001850:	00011997          	auipc	s3,0x11
    80001854:	72098993          	addi	s3,s3,1824 # 80012f70 <proc+0x848>
    80001858:	00033d17          	auipc	s10,0x33
    8000185c:	918d0d13          	addi	s10,s10,-1768 # 80034170 <bcache+0x830>
    int proc_index= (int)(p-proc);
    80001860:	7c7d                	lui	s8,0xfffff
    80001862:	7b8c0c13          	addi	s8,s8,1976 # fffffffffffff7b8 <end+0xffffffff7ffbd7b8>
    80001866:	00007c97          	auipc	s9,0x7
    8000186a:	79acbc83          	ld	s9,1946(s9) # 80009000 <etext>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      int thread_index = (int)(t-p->kthreads);
    8000186e:	00007b97          	auipc	s7,0x7
    80001872:	79ab8b93          	addi	s7,s7,1946 # 80009008 <etext+0x8>
      uint64 va = KSTACK( proc_index * NTHREAD + thread_index);
    80001876:	04000ab7          	lui	s5,0x4000
    8000187a:	1afd                	addi	s5,s5,-1
    8000187c:	0ab2                	slli	s5,s5,0xc
    8000187e:	a839                	j	8000189c <proc_mapstacks+0x6a>
        panic("kalloc");
    80001880:	00008517          	auipc	a0,0x8
    80001884:	97850513          	addi	a0,a0,-1672 # 800091f8 <digits+0x1b8>
    80001888:	fffff097          	auipc	ra,0xfffff
    8000188c:	ca6080e7          	jalr	-858(ra) # 8000052e <panic>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001890:	6785                	lui	a5,0x1
    80001892:	84878793          	addi	a5,a5,-1976 # 848 <_entry-0x7ffff7b8>
    80001896:	99be                	add	s3,s3,a5
    80001898:	07a98363          	beq	s3,s10,800018fe <proc_mapstacks+0xcc>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    8000189c:	a4098a13          	addi	s4,s3,-1472
    int proc_index= (int)(p-proc);
    800018a0:	01898933          	add	s2,s3,s8
    800018a4:	00011797          	auipc	a5,0x11
    800018a8:	e8478793          	addi	a5,a5,-380 # 80012728 <proc>
    800018ac:	40f90933          	sub	s2,s2,a5
    800018b0:	40395913          	srai	s2,s2,0x3
    800018b4:	03990933          	mul	s2,s2,s9
    800018b8:	0039191b          	slliw	s2,s2,0x3
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    800018bc:	84d2                	mv	s1,s4
      char *pa = kalloc();
    800018be:	fffff097          	auipc	ra,0xfffff
    800018c2:	218080e7          	jalr	536(ra) # 80000ad6 <kalloc>
    800018c6:	862a                	mv	a2,a0
      if(pa == 0)
    800018c8:	dd45                	beqz	a0,80001880 <proc_mapstacks+0x4e>
      int thread_index = (int)(t-p->kthreads);
    800018ca:	414485b3          	sub	a1,s1,s4
    800018ce:	858d                	srai	a1,a1,0x3
    800018d0:	000bb783          	ld	a5,0(s7)
    800018d4:	02f585b3          	mul	a1,a1,a5
      uint64 va = KSTACK( proc_index * NTHREAD + thread_index);
    800018d8:	012585bb          	addw	a1,a1,s2
    800018dc:	2585                	addiw	a1,a1,1
    800018de:	00d5959b          	slliw	a1,a1,0xd
      kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018e2:	4719                	li	a4,6
    800018e4:	6685                	lui	a3,0x1
    800018e6:	40ba85b3          	sub	a1,s5,a1
    800018ea:	855a                	mv	a0,s6
    800018ec:	00000097          	auipc	ra,0x0
    800018f0:	856080e7          	jalr	-1962(ra) # 80001142 <kvmmap>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    800018f4:	0b848493          	addi	s1,s1,184
    800018f8:	fd3493e3          	bne	s1,s3,800018be <proc_mapstacks+0x8c>
    800018fc:	bf51                	j	80001890 <proc_mapstacks+0x5e>
    }
  }
}
    800018fe:	60e6                	ld	ra,88(sp)
    80001900:	6446                	ld	s0,80(sp)
    80001902:	64a6                	ld	s1,72(sp)
    80001904:	6906                	ld	s2,64(sp)
    80001906:	79e2                	ld	s3,56(sp)
    80001908:	7a42                	ld	s4,48(sp)
    8000190a:	7aa2                	ld	s5,40(sp)
    8000190c:	7b02                	ld	s6,32(sp)
    8000190e:	6be2                	ld	s7,24(sp)
    80001910:	6c42                	ld	s8,16(sp)
    80001912:	6ca2                	ld	s9,8(sp)
    80001914:	6d02                	ld	s10,0(sp)
    80001916:	6125                	addi	sp,sp,96
    80001918:	8082                	ret

000000008000191a <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    8000191a:	7159                	addi	sp,sp,-112
    8000191c:	f486                	sd	ra,104(sp)
    8000191e:	f0a2                	sd	s0,96(sp)
    80001920:	eca6                	sd	s1,88(sp)
    80001922:	e8ca                	sd	s2,80(sp)
    80001924:	e4ce                	sd	s3,72(sp)
    80001926:	e0d2                	sd	s4,64(sp)
    80001928:	fc56                	sd	s5,56(sp)
    8000192a:	f85a                	sd	s6,48(sp)
    8000192c:	f45e                	sd	s7,40(sp)
    8000192e:	f062                	sd	s8,32(sp)
    80001930:	ec66                	sd	s9,24(sp)
    80001932:	e86a                	sd	s10,16(sp)
    80001934:	e46e                	sd	s11,8(sp)
    80001936:	1880                	addi	s0,sp,112
  struct proc *p;
  struct kthread *t;
  
  initlock(&pid_lock, "nextpid");
    80001938:	00008597          	auipc	a1,0x8
    8000193c:	8c858593          	addi	a1,a1,-1848 # 80009200 <digits+0x1c0>
    80001940:	00011517          	auipc	a0,0x11
    80001944:	96050513          	addi	a0,a0,-1696 # 800122a0 <pid_lock>
    80001948:	fffff097          	auipc	ra,0xfffff
    8000194c:	1ee080e7          	jalr	494(ra) # 80000b36 <initlock>
  initlock(&tid_lock,"nexttid");
    80001950:	00008597          	auipc	a1,0x8
    80001954:	8b858593          	addi	a1,a1,-1864 # 80009208 <digits+0x1c8>
    80001958:	00011517          	auipc	a0,0x11
    8000195c:	96050513          	addi	a0,a0,-1696 # 800122b8 <tid_lock>
    80001960:	fffff097          	auipc	ra,0xfffff
    80001964:	1d6080e7          	jalr	470(ra) # 80000b36 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001968:	00008597          	auipc	a1,0x8
    8000196c:	8a858593          	addi	a1,a1,-1880 # 80009210 <digits+0x1d0>
    80001970:	00011517          	auipc	a0,0x11
    80001974:	96050513          	addi	a0,a0,-1696 # 800122d0 <wait_lock>
    80001978:	fffff097          	auipc	ra,0xfffff
    8000197c:	1be080e7          	jalr	446(ra) # 80000b36 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {      
    80001980:	00011997          	auipc	s3,0x11
    80001984:	5f098993          	addi	s3,s3,1520 # 80012f70 <proc+0x848>
    80001988:	00011c17          	auipc	s8,0x11
    8000198c:	da0c0c13          	addi	s8,s8,-608 # 80012728 <proc>
      initlock(&p->lock, "proc");
      // p->kstack = KSTACK((int) (p - proc));
      int proc_index= (int)(p-proc);
    80001990:	8de2                	mv	s11,s8
    80001992:	00007d17          	auipc	s10,0x7
    80001996:	66ed0d13          	addi	s10,s10,1646 # 80009000 <etext>
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
        initlock(&t->lock, "thread");
    8000199a:	00008b97          	auipc	s7,0x8
    8000199e:	88eb8b93          	addi	s7,s7,-1906 # 80009228 <digits+0x1e8>
        int thread_index = (int)(t-p->kthreads);
    800019a2:	00007b17          	auipc	s6,0x7
    800019a6:	666b0b13          	addi	s6,s6,1638 # 80009008 <etext+0x8>
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    800019aa:	04000ab7          	lui	s5,0x4000
    800019ae:	1afd                	addi	s5,s5,-1
    800019b0:	0ab2                	slli	s5,s5,0xc
  for(p = proc; p < &proc[NPROC]; p++) {      
    800019b2:	6c85                	lui	s9,0x1
    800019b4:	848c8c93          	addi	s9,s9,-1976 # 848 <_entry-0x7ffff7b8>
    800019b8:	a809                	j	800019ca <procinit+0xb0>
    800019ba:	9c66                	add	s8,s8,s9
    800019bc:	99e6                	add	s3,s3,s9
    800019be:	00032797          	auipc	a5,0x32
    800019c2:	f6a78793          	addi	a5,a5,-150 # 80033928 <tickslock>
    800019c6:	06fc0263          	beq	s8,a5,80001a2a <procinit+0x110>
      initlock(&p->lock, "proc");
    800019ca:	00008597          	auipc	a1,0x8
    800019ce:	85658593          	addi	a1,a1,-1962 # 80009220 <digits+0x1e0>
    800019d2:	8562                	mv	a0,s8
    800019d4:	fffff097          	auipc	ra,0xfffff
    800019d8:	162080e7          	jalr	354(ra) # 80000b36 <initlock>
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    800019dc:	288c0a13          	addi	s4,s8,648
      int proc_index= (int)(p-proc);
    800019e0:	41bc0933          	sub	s2,s8,s11
    800019e4:	40395913          	srai	s2,s2,0x3
    800019e8:	000d3783          	ld	a5,0(s10)
    800019ec:	02f90933          	mul	s2,s2,a5
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    800019f0:	0039191b          	slliw	s2,s2,0x3
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    800019f4:	84d2                	mv	s1,s4
        initlock(&t->lock, "thread");
    800019f6:	85de                	mv	a1,s7
    800019f8:	8526                	mv	a0,s1
    800019fa:	fffff097          	auipc	ra,0xfffff
    800019fe:	13c080e7          	jalr	316(ra) # 80000b36 <initlock>
        int thread_index = (int)(t-p->kthreads);
    80001a02:	414487b3          	sub	a5,s1,s4
    80001a06:	878d                	srai	a5,a5,0x3
    80001a08:	000b3703          	ld	a4,0(s6)
    80001a0c:	02e787b3          	mul	a5,a5,a4
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    80001a10:	012787bb          	addw	a5,a5,s2
    80001a14:	2785                	addiw	a5,a5,1
    80001a16:	00d7979b          	slliw	a5,a5,0xd
    80001a1a:	40fa87b3          	sub	a5,s5,a5
    80001a1e:	fc9c                	sd	a5,56(s1)
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001a20:	0b848493          	addi	s1,s1,184
    80001a24:	fd3499e3          	bne	s1,s3,800019f6 <procinit+0xdc>
    80001a28:	bf49                	j	800019ba <procinit+0xa0>
      }
  }
}
    80001a2a:	70a6                	ld	ra,104(sp)
    80001a2c:	7406                	ld	s0,96(sp)
    80001a2e:	64e6                	ld	s1,88(sp)
    80001a30:	6946                	ld	s2,80(sp)
    80001a32:	69a6                	ld	s3,72(sp)
    80001a34:	6a06                	ld	s4,64(sp)
    80001a36:	7ae2                	ld	s5,56(sp)
    80001a38:	7b42                	ld	s6,48(sp)
    80001a3a:	7ba2                	ld	s7,40(sp)
    80001a3c:	7c02                	ld	s8,32(sp)
    80001a3e:	6ce2                	ld	s9,24(sp)
    80001a40:	6d42                	ld	s10,16(sp)
    80001a42:	6da2                	ld	s11,8(sp)
    80001a44:	6165                	addi	sp,sp,112
    80001a46:	8082                	ret

0000000080001a48 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a48:	1141                	addi	sp,sp,-16
    80001a4a:	e422                	sd	s0,8(sp)
    80001a4c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a4e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a50:	2501                	sext.w	a0,a0
    80001a52:	6422                	ld	s0,8(sp)
    80001a54:	0141                	addi	sp,sp,16
    80001a56:	8082                	ret

0000000080001a58 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001a58:	1141                	addi	sp,sp,-16
    80001a5a:	e422                	sd	s0,8(sp)
    80001a5c:	0800                	addi	s0,sp,16
    80001a5e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a60:	0007851b          	sext.w	a0,a5
    80001a64:	00451793          	slli	a5,a0,0x4
    80001a68:	97aa                	add	a5,a5,a0
    80001a6a:	078e                	slli	a5,a5,0x3
  return c;
}
    80001a6c:	00011517          	auipc	a0,0x11
    80001a70:	87c50513          	addi	a0,a0,-1924 # 800122e8 <cpus>
    80001a74:	953e                	add	a0,a0,a5
    80001a76:	6422                	ld	s0,8(sp)
    80001a78:	0141                	addi	sp,sp,16
    80001a7a:	8082                	ret

0000000080001a7c <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001a7c:	1101                	addi	sp,sp,-32
    80001a7e:	ec06                	sd	ra,24(sp)
    80001a80:	e822                	sd	s0,16(sp)
    80001a82:	e426                	sd	s1,8(sp)
    80001a84:	1000                	addi	s0,sp,32
  push_off();
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	0f4080e7          	jalr	244(ra) # 80000b7a <push_off>
    80001a8e:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a90:	0007871b          	sext.w	a4,a5
    80001a94:	00471793          	slli	a5,a4,0x4
    80001a98:	97ba                	add	a5,a5,a4
    80001a9a:	078e                	slli	a5,a5,0x3
    80001a9c:	00011717          	auipc	a4,0x11
    80001aa0:	80470713          	addi	a4,a4,-2044 # 800122a0 <pid_lock>
    80001aa4:	97ba                	add	a5,a5,a4
    80001aa6:	67a4                	ld	s1,72(a5)
  pop_off();
    80001aa8:	fffff097          	auipc	ra,0xfffff
    80001aac:	194080e7          	jalr	404(ra) # 80000c3c <pop_off>
  return p;
}//
    80001ab0:	8526                	mv	a0,s1
    80001ab2:	60e2                	ld	ra,24(sp)
    80001ab4:	6442                	ld	s0,16(sp)
    80001ab6:	64a2                	ld	s1,8(sp)
    80001ab8:	6105                	addi	sp,sp,32
    80001aba:	8082                	ret

0000000080001abc <mykthread>:

struct kthread*
mykthread(void){
    80001abc:	1101                	addi	sp,sp,-32
    80001abe:	ec06                	sd	ra,24(sp)
    80001ac0:	e822                	sd	s0,16(sp)
    80001ac2:	e426                	sd	s1,8(sp)
    80001ac4:	1000                	addi	s0,sp,32
  push_off();
    80001ac6:	fffff097          	auipc	ra,0xfffff
    80001aca:	0b4080e7          	jalr	180(ra) # 80000b7a <push_off>
    80001ace:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct kthread *t=c->kthread;
    80001ad0:	0007871b          	sext.w	a4,a5
    80001ad4:	00471793          	slli	a5,a4,0x4
    80001ad8:	97ba                	add	a5,a5,a4
    80001ada:	078e                	slli	a5,a5,0x3
    80001adc:	00010717          	auipc	a4,0x10
    80001ae0:	7c470713          	addi	a4,a4,1988 # 800122a0 <pid_lock>
    80001ae4:	97ba                	add	a5,a5,a4
    80001ae6:	67e4                	ld	s1,200(a5)
  pop_off();
    80001ae8:	fffff097          	auipc	ra,0xfffff
    80001aec:	154080e7          	jalr	340(ra) # 80000c3c <pop_off>
  return t;  
}
    80001af0:	8526                	mv	a0,s1
    80001af2:	60e2                	ld	ra,24(sp)
    80001af4:	6442                	ld	s0,16(sp)
    80001af6:	64a2                	ld	s1,8(sp)
    80001af8:	6105                	addi	sp,sp,32
    80001afa:	8082                	ret

0000000080001afc <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001afc:	1141                	addi	sp,sp,-16
    80001afe:	e406                	sd	ra,8(sp)
    80001b00:	e022                	sd	s0,0(sp)
    80001b02:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  // release(&myproc()->lock);

  release(&mykthread()->lock);    // TODO: check if this change is good
    80001b04:	00000097          	auipc	ra,0x0
    80001b08:	fb8080e7          	jalr	-72(ra) # 80001abc <mykthread>
    80001b0c:	fffff097          	auipc	ra,0xfffff
    80001b10:	190080e7          	jalr	400(ra) # 80000c9c <release>

  if (first) {
    80001b14:	00008797          	auipc	a5,0x8
    80001b18:	e5c7a783          	lw	a5,-420(a5) # 80009970 <first.1>
    80001b1c:	eb89                	bnez	a5,80001b2e <forkret+0x32>
    fsinit(ROOTDEV);
  }
  // printf("ffret%d\n",myproc()->pid);//TODO delete


  usertrapret();
    80001b1e:	00002097          	auipc	ra,0x2
    80001b22:	9d4080e7          	jalr	-1580(ra) # 800034f2 <usertrapret>
}
    80001b26:	60a2                	ld	ra,8(sp)
    80001b28:	6402                	ld	s0,0(sp)
    80001b2a:	0141                	addi	sp,sp,16
    80001b2c:	8082                	ret
    first = 0;
    80001b2e:	00008797          	auipc	a5,0x8
    80001b32:	e407a123          	sw	zero,-446(a5) # 80009970 <first.1>
    fsinit(ROOTDEV);
    80001b36:	4505                	li	a0,1
    80001b38:	00003097          	auipc	ra,0x3
    80001b3c:	9b6080e7          	jalr	-1610(ra) # 800044ee <fsinit>
    80001b40:	bff9                	j	80001b1e <forkret+0x22>

0000000080001b42 <allocpid>:
allocpid() {
    80001b42:	1101                	addi	sp,sp,-32
    80001b44:	ec06                	sd	ra,24(sp)
    80001b46:	e822                	sd	s0,16(sp)
    80001b48:	e426                	sd	s1,8(sp)
    80001b4a:	e04a                	sd	s2,0(sp)
    80001b4c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b4e:	00010917          	auipc	s2,0x10
    80001b52:	75290913          	addi	s2,s2,1874 # 800122a0 <pid_lock>
    80001b56:	854a                	mv	a0,s2
    80001b58:	fffff097          	auipc	ra,0xfffff
    80001b5c:	06e080e7          	jalr	110(ra) # 80000bc6 <acquire>
  pid = nextpid;
    80001b60:	00008797          	auipc	a5,0x8
    80001b64:	e1878793          	addi	a5,a5,-488 # 80009978 <nextpid>
    80001b68:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b6a:	0014871b          	addiw	a4,s1,1
    80001b6e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b70:	854a                	mv	a0,s2
    80001b72:	fffff097          	auipc	ra,0xfffff
    80001b76:	12a080e7          	jalr	298(ra) # 80000c9c <release>
}
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	60e2                	ld	ra,24(sp)
    80001b7e:	6442                	ld	s0,16(sp)
    80001b80:	64a2                	ld	s1,8(sp)
    80001b82:	6902                	ld	s2,0(sp)
    80001b84:	6105                	addi	sp,sp,32
    80001b86:	8082                	ret

0000000080001b88 <alloctid>:
alloctid() {
    80001b88:	1101                	addi	sp,sp,-32
    80001b8a:	ec06                	sd	ra,24(sp)
    80001b8c:	e822                	sd	s0,16(sp)
    80001b8e:	e426                	sd	s1,8(sp)
    80001b90:	e04a                	sd	s2,0(sp)
    80001b92:	1000                	addi	s0,sp,32
  acquire(&tid_lock);
    80001b94:	00010917          	auipc	s2,0x10
    80001b98:	72490913          	addi	s2,s2,1828 # 800122b8 <tid_lock>
    80001b9c:	854a                	mv	a0,s2
    80001b9e:	fffff097          	auipc	ra,0xfffff
    80001ba2:	028080e7          	jalr	40(ra) # 80000bc6 <acquire>
  tid = nexttid;
    80001ba6:	00008797          	auipc	a5,0x8
    80001baa:	dce78793          	addi	a5,a5,-562 # 80009974 <nexttid>
    80001bae:	4384                	lw	s1,0(a5)
  nexttid = nexttid + 1;
    80001bb0:	0014871b          	addiw	a4,s1,1
    80001bb4:	c398                	sw	a4,0(a5)
  release(&tid_lock);
    80001bb6:	854a                	mv	a0,s2
    80001bb8:	fffff097          	auipc	ra,0xfffff
    80001bbc:	0e4080e7          	jalr	228(ra) # 80000c9c <release>
}
    80001bc0:	8526                	mv	a0,s1
    80001bc2:	60e2                	ld	ra,24(sp)
    80001bc4:	6442                	ld	s0,16(sp)
    80001bc6:	64a2                	ld	s1,8(sp)
    80001bc8:	6902                	ld	s2,0(sp)
    80001bca:	6105                	addi	sp,sp,32
    80001bcc:	8082                	ret

0000000080001bce <init_thread>:
init_thread(struct kthread *t){
    80001bce:	1101                	addi	sp,sp,-32
    80001bd0:	ec06                	sd	ra,24(sp)
    80001bd2:	e822                	sd	s0,16(sp)
    80001bd4:	e426                	sd	s1,8(sp)
    80001bd6:	1000                	addi	s0,sp,32
    80001bd8:	84aa                	mv	s1,a0
  t->state = TUSED;
    80001bda:	4785                	li	a5,1
    80001bdc:	cd1c                	sw	a5,24(a0)
  t->tid = alloctid();  
    80001bde:	00000097          	auipc	ra,0x0
    80001be2:	faa080e7          	jalr	-86(ra) # 80001b88 <alloctid>
    80001be6:	d888                	sw	a0,48(s1)
  memset(&(t->context), 0, sizeof(t->context));
    80001be8:	07000613          	li	a2,112
    80001bec:	4581                	li	a1,0
    80001bee:	04848513          	addi	a0,s1,72
    80001bf2:	fffff097          	auipc	ra,0xfffff
    80001bf6:	0f2080e7          	jalr	242(ra) # 80000ce4 <memset>
  t->context.ra = (uint64)forkret;
    80001bfa:	00000797          	auipc	a5,0x0
    80001bfe:	f0278793          	addi	a5,a5,-254 # 80001afc <forkret>
    80001c02:	e4bc                	sd	a5,72(s1)
  t->context.sp = t->kstack + PGSIZE;
    80001c04:	7c9c                	ld	a5,56(s1)
    80001c06:	6705                	lui	a4,0x1
    80001c08:	97ba                	add	a5,a5,a4
    80001c0a:	e8bc                	sd	a5,80(s1)
}
    80001c0c:	4501                	li	a0,0
    80001c0e:	60e2                	ld	ra,24(sp)
    80001c10:	6442                	ld	s0,16(sp)
    80001c12:	64a2                	ld	s1,8(sp)
    80001c14:	6105                	addi	sp,sp,32
    80001c16:	8082                	ret

0000000080001c18 <proc_pagetable>:
{
    80001c18:	1101                	addi	sp,sp,-32
    80001c1a:	ec06                	sd	ra,24(sp)
    80001c1c:	e822                	sd	s0,16(sp)
    80001c1e:	e426                	sd	s1,8(sp)
    80001c20:	e04a                	sd	s2,0(sp)
    80001c22:	1000                	addi	s0,sp,32
    80001c24:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c26:	fffff097          	auipc	ra,0xfffff
    80001c2a:	706080e7          	jalr	1798(ra) # 8000132c <uvmcreate>
    80001c2e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001c30:	c121                	beqz	a0,80001c70 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c32:	4729                	li	a4,10
    80001c34:	00006697          	auipc	a3,0x6
    80001c38:	3cc68693          	addi	a3,a3,972 # 80008000 <_trampoline>
    80001c3c:	6605                	lui	a2,0x1
    80001c3e:	040005b7          	lui	a1,0x4000
    80001c42:	15fd                	addi	a1,a1,-1
    80001c44:	05b2                	slli	a1,a1,0xc
    80001c46:	fffff097          	auipc	ra,0xfffff
    80001c4a:	46e080e7          	jalr	1134(ra) # 800010b4 <mappages>
    80001c4e:	02054863          	bltz	a0,80001c7e <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c52:	4719                	li	a4,6
    80001c54:	04893683          	ld	a3,72(s2)
    80001c58:	6605                	lui	a2,0x1
    80001c5a:	020005b7          	lui	a1,0x2000
    80001c5e:	15fd                	addi	a1,a1,-1
    80001c60:	05b6                	slli	a1,a1,0xd
    80001c62:	8526                	mv	a0,s1
    80001c64:	fffff097          	auipc	ra,0xfffff
    80001c68:	450080e7          	jalr	1104(ra) # 800010b4 <mappages>
    80001c6c:	02054163          	bltz	a0,80001c8e <proc_pagetable+0x76>
}
    80001c70:	8526                	mv	a0,s1
    80001c72:	60e2                	ld	ra,24(sp)
    80001c74:	6442                	ld	s0,16(sp)
    80001c76:	64a2                	ld	s1,8(sp)
    80001c78:	6902                	ld	s2,0(sp)
    80001c7a:	6105                	addi	sp,sp,32
    80001c7c:	8082                	ret
    uvmfree(pagetable, 0);
    80001c7e:	4581                	li	a1,0
    80001c80:	8526                	mv	a0,s1
    80001c82:	00000097          	auipc	ra,0x0
    80001c86:	8a6080e7          	jalr	-1882(ra) # 80001528 <uvmfree>
    return 0;
    80001c8a:	4481                	li	s1,0
    80001c8c:	b7d5                	j	80001c70 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c8e:	4681                	li	a3,0
    80001c90:	4605                	li	a2,1
    80001c92:	040005b7          	lui	a1,0x4000
    80001c96:	15fd                	addi	a1,a1,-1
    80001c98:	05b2                	slli	a1,a1,0xc
    80001c9a:	8526                	mv	a0,s1
    80001c9c:	fffff097          	auipc	ra,0xfffff
    80001ca0:	5cc080e7          	jalr	1484(ra) # 80001268 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ca4:	4581                	li	a1,0
    80001ca6:	8526                	mv	a0,s1
    80001ca8:	00000097          	auipc	ra,0x0
    80001cac:	880080e7          	jalr	-1920(ra) # 80001528 <uvmfree>
    return 0;
    80001cb0:	4481                	li	s1,0
    80001cb2:	bf7d                	j	80001c70 <proc_pagetable+0x58>

0000000080001cb4 <proc_freepagetable>:
{
    80001cb4:	1101                	addi	sp,sp,-32
    80001cb6:	ec06                	sd	ra,24(sp)
    80001cb8:	e822                	sd	s0,16(sp)
    80001cba:	e426                	sd	s1,8(sp)
    80001cbc:	e04a                	sd	s2,0(sp)
    80001cbe:	1000                	addi	s0,sp,32
    80001cc0:	84aa                	mv	s1,a0
    80001cc2:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cc4:	4681                	li	a3,0
    80001cc6:	4605                	li	a2,1
    80001cc8:	040005b7          	lui	a1,0x4000
    80001ccc:	15fd                	addi	a1,a1,-1
    80001cce:	05b2                	slli	a1,a1,0xc
    80001cd0:	fffff097          	auipc	ra,0xfffff
    80001cd4:	598080e7          	jalr	1432(ra) # 80001268 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001cd8:	4681                	li	a3,0
    80001cda:	4605                	li	a2,1
    80001cdc:	020005b7          	lui	a1,0x2000
    80001ce0:	15fd                	addi	a1,a1,-1
    80001ce2:	05b6                	slli	a1,a1,0xd
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	fffff097          	auipc	ra,0xfffff
    80001cea:	582080e7          	jalr	1410(ra) # 80001268 <uvmunmap>
  uvmfree(pagetable, sz);
    80001cee:	85ca                	mv	a1,s2
    80001cf0:	8526                	mv	a0,s1
    80001cf2:	00000097          	auipc	ra,0x0
    80001cf6:	836080e7          	jalr	-1994(ra) # 80001528 <uvmfree>
}
    80001cfa:	60e2                	ld	ra,24(sp)
    80001cfc:	6442                	ld	s0,16(sp)
    80001cfe:	64a2                	ld	s1,8(sp)
    80001d00:	6902                	ld	s2,0(sp)
    80001d02:	6105                	addi	sp,sp,32
    80001d04:	8082                	ret

0000000080001d06 <freeproc>:
{
    80001d06:	7179                	addi	sp,sp,-48
    80001d08:	f406                	sd	ra,40(sp)
    80001d0a:	f022                	sd	s0,32(sp)
    80001d0c:	ec26                	sd	s1,24(sp)
    80001d0e:	e84a                	sd	s2,16(sp)
    80001d10:	e44e                	sd	s3,8(sp)
    80001d12:	1800                	addi	s0,sp,48
    80001d14:	892a                	mv	s2,a0
   if(p->threads_tf_start)
    80001d16:	6528                	ld	a0,72(a0)
    80001d18:	c509                	beqz	a0,80001d22 <freeproc+0x1c>
    kfree((void*)p->threads_tf_start);
    80001d1a:	fffff097          	auipc	ra,0xfffff
    80001d1e:	cc0080e7          	jalr	-832(ra) # 800009da <kfree>
   p->threads_tf_start = 0;
    80001d22:	04093423          	sd	zero,72(s2)
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001d26:	28890493          	addi	s1,s2,648
    80001d2a:	6985                	lui	s3,0x1
    80001d2c:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80001d30:	99ca                	add	s3,s3,s2
    acquire(&t->lock);
    80001d32:	8526                	mv	a0,s1
    80001d34:	fffff097          	auipc	ra,0xfffff
    80001d38:	e92080e7          	jalr	-366(ra) # 80000bc6 <acquire>
  t->tid = 0;
    80001d3c:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80001d40:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80001d44:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80001d48:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80001d4c:	0004ac23          	sw	zero,24(s1)
    release(&t->lock);
    80001d50:	8526                	mv	a0,s1
    80001d52:	fffff097          	auipc	ra,0xfffff
    80001d56:	f4a080e7          	jalr	-182(ra) # 80000c9c <release>
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001d5a:	0b848493          	addi	s1,s1,184
    80001d5e:	fc999ae3          	bne	s3,s1,80001d32 <freeproc+0x2c>
  p->user_trapframe_backup = 0;
    80001d62:	26093c23          	sd	zero,632(s2)
  if(p->pagetable)
    80001d66:	04093503          	ld	a0,64(s2)
    80001d6a:	c519                	beqz	a0,80001d78 <freeproc+0x72>
    proc_freepagetable(p->pagetable, p->sz);
    80001d6c:	03893583          	ld	a1,56(s2)
    80001d70:	00000097          	auipc	ra,0x0
    80001d74:	f44080e7          	jalr	-188(ra) # 80001cb4 <proc_freepagetable>
  p->pagetable = 0;
    80001d78:	04093023          	sd	zero,64(s2)
  p->sz = 0;
    80001d7c:	02093c23          	sd	zero,56(s2)
  p->pid = 0;
    80001d80:	02092223          	sw	zero,36(s2)
  p->parent = 0;
    80001d84:	02093823          	sd	zero,48(s2)
  p->name[0] = 0;
    80001d88:	0c090c23          	sb	zero,216(s2)
  p->killed = 0;
    80001d8c:	00092e23          	sw	zero,28(s2)
  p->xstate = 0;
    80001d90:	02092023          	sw	zero,32(s2)
  p->active_threads = 0;
    80001d94:	02092423          	sw	zero,40(s2)
  p->state = UNUSED;
    80001d98:	00092c23          	sw	zero,24(s2)
}
    80001d9c:	70a2                	ld	ra,40(sp)
    80001d9e:	7402                	ld	s0,32(sp)
    80001da0:	64e2                	ld	s1,24(sp)
    80001da2:	6942                	ld	s2,16(sp)
    80001da4:	69a2                	ld	s3,8(sp)
    80001da6:	6145                	addi	sp,sp,48
    80001da8:	8082                	ret

0000000080001daa <allocproc>:
{
    80001daa:	7179                	addi	sp,sp,-48
    80001dac:	f406                	sd	ra,40(sp)
    80001dae:	f022                	sd	s0,32(sp)
    80001db0:	ec26                	sd	s1,24(sp)
    80001db2:	e84a                	sd	s2,16(sp)
    80001db4:	e44e                	sd	s3,8(sp)
    80001db6:	e052                	sd	s4,0(sp)
    80001db8:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dba:	00011497          	auipc	s1,0x11
    80001dbe:	96e48493          	addi	s1,s1,-1682 # 80012728 <proc>
    80001dc2:	6985                	lui	s3,0x1
    80001dc4:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80001dc8:	00032a17          	auipc	s4,0x32
    80001dcc:	b60a0a13          	addi	s4,s4,-1184 # 80033928 <tickslock>
    acquire(&p->lock);
    80001dd0:	8926                	mv	s2,s1
    80001dd2:	8526                	mv	a0,s1
    80001dd4:	fffff097          	auipc	ra,0xfffff
    80001dd8:	df2080e7          	jalr	-526(ra) # 80000bc6 <acquire>
    if(p->state == UNUSED) {
    80001ddc:	4c9c                	lw	a5,24(s1)
    80001dde:	cb99                	beqz	a5,80001df4 <allocproc+0x4a>
      release(&p->lock);
    80001de0:	8526                	mv	a0,s1
    80001de2:	fffff097          	auipc	ra,0xfffff
    80001de6:	eba080e7          	jalr	-326(ra) # 80000c9c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dea:	94ce                	add	s1,s1,s3
    80001dec:	ff4492e3          	bne	s1,s4,80001dd0 <allocproc+0x26>
  return 0;
    80001df0:	4481                	li	s1,0
    80001df2:	a845                	j	80001ea2 <allocproc+0xf8>
  p->pid = allocpid();
    80001df4:	00000097          	auipc	ra,0x0
    80001df8:	d4e080e7          	jalr	-690(ra) # 80001b42 <allocpid>
    80001dfc:	d0c8                	sw	a0,36(s1)
  p->state = USED;
    80001dfe:	4785                	li	a5,1
    80001e00:	cc9c                	sw	a5,24(s1)
  if((p->threads_tf_start =kalloc()) == 0){
    80001e02:	fffff097          	auipc	ra,0xfffff
    80001e06:	cd4080e7          	jalr	-812(ra) # 80000ad6 <kalloc>
    80001e0a:	89aa                	mv	s3,a0
    80001e0c:	e4a8                	sd	a0,72(s1)
    80001e0e:	0f848713          	addi	a4,s1,248
    80001e12:	1f848793          	addi	a5,s1,504
    80001e16:	27848693          	addi	a3,s1,632
    80001e1a:	cd49                	beqz	a0,80001eb4 <allocproc+0x10a>
    p->signal_handlers[i] = SIG_DFL;
    80001e1c:	00073023          	sd	zero,0(a4) # 1000 <_entry-0x7ffff000>
    p->handlers_sigmasks[i] = 0;
    80001e20:	0007a023          	sw	zero,0(a5)
  for(int i=0;i<32;i++){
    80001e24:	0721                	addi	a4,a4,8
    80001e26:	0791                	addi	a5,a5,4
    80001e28:	fed79ae3          	bne	a5,a3,80001e1c <allocproc+0x72>
  p->signal_mask= 0;
    80001e2c:	0e04a623          	sw	zero,236(s1)
  p->pending_signals = 0;
    80001e30:	0e04a423          	sw	zero,232(s1)
  p->active_threads=1;
    80001e34:	4785                	li	a5,1
    80001e36:	d49c                	sw	a5,40(s1)
  p->signal_mask_backup = 0;
    80001e38:	0e04a823          	sw	zero,240(s1)
  p->handling_user_sig_flag = 0;
    80001e3c:	2804a023          	sw	zero,640(s1)
  p->handling_sig_flag=0;
    80001e40:	2804a223          	sw	zero,644(s1)
  p->pagetable = proc_pagetable(p);
    80001e44:	8526                	mv	a0,s1
    80001e46:	00000097          	auipc	ra,0x0
    80001e4a:	dd2080e7          	jalr	-558(ra) # 80001c18 <proc_pagetable>
    80001e4e:	89aa                	mv	s3,a0
    80001e50:	e0a8                	sd	a0,64(s1)
  if(p->pagetable == 0){
    80001e52:	cd2d                	beqz	a0,80001ecc <allocproc+0x122>
    80001e54:	2a048793          	addi	a5,s1,672
    80001e58:	64b8                	ld	a4,72(s1)
    80001e5a:	6685                	lui	a3,0x1
    80001e5c:	86068693          	addi	a3,a3,-1952 # 860 <_entry-0x7ffff7a0>
    80001e60:	9936                	add	s2,s2,a3
    t->tid=-1;
    80001e62:	56fd                	li	a3,-1
    t->state=TUNUSED;
    80001e64:	0007a023          	sw	zero,0(a5)
    t->chan=0;
    80001e68:	0007b423          	sd	zero,8(a5)
    t->tid=-1;
    80001e6c:	cf94                	sw	a3,24(a5)
    t->trapframe = (struct trapframe *)p->threads_tf_start + i;     
    80001e6e:	f798                	sd	a4,40(a5)
    t->killed = 0;
    80001e70:	0007a823          	sw	zero,16(a5)
    t->frozen = 0;
    80001e74:	0007ae23          	sw	zero,28(a5)
  for(int i=0;i<NTHREAD;i++){
    80001e78:	0b878793          	addi	a5,a5,184
    80001e7c:	12070713          	addi	a4,a4,288
    80001e80:	ff2792e3          	bne	a5,s2,80001e64 <allocproc+0xba>
  struct kthread *t= &p->kthreads[0];
    80001e84:	28848913          	addi	s2,s1,648
  acquire(&t->lock);
    80001e88:	854a                	mv	a0,s2
    80001e8a:	fffff097          	auipc	ra,0xfffff
    80001e8e:	d3c080e7          	jalr	-708(ra) # 80000bc6 <acquire>
  if(init_thread(t) == -1){
    80001e92:	854a                	mv	a0,s2
    80001e94:	00000097          	auipc	ra,0x0
    80001e98:	d3a080e7          	jalr	-710(ra) # 80001bce <init_thread>
    80001e9c:	57fd                	li	a5,-1
    80001e9e:	04f50363          	beq	a0,a5,80001ee4 <allocproc+0x13a>
}
    80001ea2:	8526                	mv	a0,s1
    80001ea4:	70a2                	ld	ra,40(sp)
    80001ea6:	7402                	ld	s0,32(sp)
    80001ea8:	64e2                	ld	s1,24(sp)
    80001eaa:	6942                	ld	s2,16(sp)
    80001eac:	69a2                	ld	s3,8(sp)
    80001eae:	6a02                	ld	s4,0(sp)
    80001eb0:	6145                	addi	sp,sp,48
    80001eb2:	8082                	ret
    freeproc(p);
    80001eb4:	8526                	mv	a0,s1
    80001eb6:	00000097          	auipc	ra,0x0
    80001eba:	e50080e7          	jalr	-432(ra) # 80001d06 <freeproc>
    release(&p->lock);
    80001ebe:	8526                	mv	a0,s1
    80001ec0:	fffff097          	auipc	ra,0xfffff
    80001ec4:	ddc080e7          	jalr	-548(ra) # 80000c9c <release>
    return 0;
    80001ec8:	84ce                	mv	s1,s3
    80001eca:	bfe1                	j	80001ea2 <allocproc+0xf8>
    freeproc(p);
    80001ecc:	8526                	mv	a0,s1
    80001ece:	00000097          	auipc	ra,0x0
    80001ed2:	e38080e7          	jalr	-456(ra) # 80001d06 <freeproc>
    release(&p->lock);
    80001ed6:	8526                	mv	a0,s1
    80001ed8:	fffff097          	auipc	ra,0xfffff
    80001edc:	dc4080e7          	jalr	-572(ra) # 80000c9c <release>
    return 0;
    80001ee0:	84ce                	mv	s1,s3
    80001ee2:	b7c1                	j	80001ea2 <allocproc+0xf8>
    freeproc(p);
    80001ee4:	8526                	mv	a0,s1
    80001ee6:	00000097          	auipc	ra,0x0
    80001eea:	e20080e7          	jalr	-480(ra) # 80001d06 <freeproc>
    release(&p->lock);  
    80001eee:	8526                	mv	a0,s1
    80001ef0:	fffff097          	auipc	ra,0xfffff
    80001ef4:	dac080e7          	jalr	-596(ra) # 80000c9c <release>
    return 0;
    80001ef8:	4481                	li	s1,0
    80001efa:	b765                	j	80001ea2 <allocproc+0xf8>

0000000080001efc <userinit>:
{
    80001efc:	1101                	addi	sp,sp,-32
    80001efe:	ec06                	sd	ra,24(sp)
    80001f00:	e822                	sd	s0,16(sp)
    80001f02:	e426                	sd	s1,8(sp)
    80001f04:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f06:	00000097          	auipc	ra,0x0
    80001f0a:	ea4080e7          	jalr	-348(ra) # 80001daa <allocproc>
    80001f0e:	84aa                	mv	s1,a0
  initproc = p;
    80001f10:	00008797          	auipc	a5,0x8
    80001f14:	10a7bc23          	sd	a0,280(a5) # 8000a028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001f18:	03400613          	li	a2,52
    80001f1c:	00008597          	auipc	a1,0x8
    80001f20:	a6458593          	addi	a1,a1,-1436 # 80009980 <initcode>
    80001f24:	6128                	ld	a0,64(a0)
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	434080e7          	jalr	1076(ra) # 8000135a <uvminit>
  p->sz = PGSIZE;
    80001f2e:	6785                	lui	a5,0x1
    80001f30:	fc9c                	sd	a5,56(s1)
  t->trapframe->epc = 0;      // user program counter
    80001f32:	2c84b703          	ld	a4,712(s1)
    80001f36:	00073c23          	sd	zero,24(a4)
  t->trapframe->sp = PGSIZE;  // user stack pointer
    80001f3a:	2c84b703          	ld	a4,712(s1)
    80001f3e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f40:	4641                	li	a2,16
    80001f42:	00007597          	auipc	a1,0x7
    80001f46:	2ee58593          	addi	a1,a1,750 # 80009230 <digits+0x1f0>
    80001f4a:	0d848513          	addi	a0,s1,216
    80001f4e:	fffff097          	auipc	ra,0xfffff
    80001f52:	ee8080e7          	jalr	-280(ra) # 80000e36 <safestrcpy>
  p->cwd = namei("/");
    80001f56:	00007517          	auipc	a0,0x7
    80001f5a:	2ea50513          	addi	a0,a0,746 # 80009240 <digits+0x200>
    80001f5e:	00003097          	auipc	ra,0x3
    80001f62:	fbc080e7          	jalr	-68(ra) # 80004f1a <namei>
    80001f66:	e8e8                	sd	a0,208(s1)
  p->state = RUNNABLE;
    80001f68:	4789                	li	a5,2
    80001f6a:	cc9c                	sw	a5,24(s1)
  t->state = TRUNNABLE;
    80001f6c:	478d                	li	a5,3
    80001f6e:	2af4a023          	sw	a5,672(s1)
  release(&p->lock);
    80001f72:	8526                	mv	a0,s1
    80001f74:	fffff097          	auipc	ra,0xfffff
    80001f78:	d28080e7          	jalr	-728(ra) # 80000c9c <release>
  release(&p->kthreads[0].lock);////////////////////////////////////////////////////////////////check
    80001f7c:	28848513          	addi	a0,s1,648
    80001f80:	fffff097          	auipc	ra,0xfffff
    80001f84:	d1c080e7          	jalr	-740(ra) # 80000c9c <release>
}
    80001f88:	60e2                	ld	ra,24(sp)
    80001f8a:	6442                	ld	s0,16(sp)
    80001f8c:	64a2                	ld	s1,8(sp)
    80001f8e:	6105                	addi	sp,sp,32
    80001f90:	8082                	ret

0000000080001f92 <growproc>:
{
    80001f92:	1101                	addi	sp,sp,-32
    80001f94:	ec06                	sd	ra,24(sp)
    80001f96:	e822                	sd	s0,16(sp)
    80001f98:	e426                	sd	s1,8(sp)
    80001f9a:	e04a                	sd	s2,0(sp)
    80001f9c:	1000                	addi	s0,sp,32
    80001f9e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001fa0:	00000097          	auipc	ra,0x0
    80001fa4:	adc080e7          	jalr	-1316(ra) # 80001a7c <myproc>
    80001fa8:	892a                	mv	s2,a0
  sz = p->sz;
    80001faa:	7d0c                	ld	a1,56(a0)
    80001fac:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001fb0:	00904f63          	bgtz	s1,80001fce <growproc+0x3c>
  } else if(n < 0){
    80001fb4:	0204cc63          	bltz	s1,80001fec <growproc+0x5a>
  p->sz = sz;
    80001fb8:	1602                	slli	a2,a2,0x20
    80001fba:	9201                	srli	a2,a2,0x20
    80001fbc:	02c93c23          	sd	a2,56(s2)
  return 0;
    80001fc0:	4501                	li	a0,0
}
    80001fc2:	60e2                	ld	ra,24(sp)
    80001fc4:	6442                	ld	s0,16(sp)
    80001fc6:	64a2                	ld	s1,8(sp)
    80001fc8:	6902                	ld	s2,0(sp)
    80001fca:	6105                	addi	sp,sp,32
    80001fcc:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001fce:	9e25                	addw	a2,a2,s1
    80001fd0:	1602                	slli	a2,a2,0x20
    80001fd2:	9201                	srli	a2,a2,0x20
    80001fd4:	1582                	slli	a1,a1,0x20
    80001fd6:	9181                	srli	a1,a1,0x20
    80001fd8:	6128                	ld	a0,64(a0)
    80001fda:	fffff097          	auipc	ra,0xfffff
    80001fde:	43a080e7          	jalr	1082(ra) # 80001414 <uvmalloc>
    80001fe2:	0005061b          	sext.w	a2,a0
    80001fe6:	fa69                	bnez	a2,80001fb8 <growproc+0x26>
      return -1;
    80001fe8:	557d                	li	a0,-1
    80001fea:	bfe1                	j	80001fc2 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001fec:	9e25                	addw	a2,a2,s1
    80001fee:	1602                	slli	a2,a2,0x20
    80001ff0:	9201                	srli	a2,a2,0x20
    80001ff2:	1582                	slli	a1,a1,0x20
    80001ff4:	9181                	srli	a1,a1,0x20
    80001ff6:	6128                	ld	a0,64(a0)
    80001ff8:	fffff097          	auipc	ra,0xfffff
    80001ffc:	3d4080e7          	jalr	980(ra) # 800013cc <uvmdealloc>
    80002000:	0005061b          	sext.w	a2,a0
    80002004:	bf55                	j	80001fb8 <growproc+0x26>

0000000080002006 <fork>:
{
    80002006:	7139                	addi	sp,sp,-64
    80002008:	fc06                	sd	ra,56(sp)
    8000200a:	f822                	sd	s0,48(sp)
    8000200c:	f426                	sd	s1,40(sp)
    8000200e:	f04a                	sd	s2,32(sp)
    80002010:	ec4e                	sd	s3,24(sp)
    80002012:	e852                	sd	s4,16(sp)
    80002014:	e456                	sd	s5,8(sp)
    80002016:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002018:	00000097          	auipc	ra,0x0
    8000201c:	a64080e7          	jalr	-1436(ra) # 80001a7c <myproc>
    80002020:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    80002022:	00000097          	auipc	ra,0x0
    80002026:	a9a080e7          	jalr	-1382(ra) # 80001abc <mykthread>
    8000202a:	84aa                	mv	s1,a0
  if((np = allocproc()) == 0){//////////////////////////////////////////////////check  lock p and t
    8000202c:	00000097          	auipc	ra,0x0
    80002030:	d7e080e7          	jalr	-642(ra) # 80001daa <allocproc>
    80002034:	16050f63          	beqz	a0,800021b2 <fork+0x1ac>
    80002038:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000203a:	0389b603          	ld	a2,56(s3)
    8000203e:	612c                	ld	a1,64(a0)
    80002040:	0409b503          	ld	a0,64(s3)
    80002044:	fffff097          	auipc	ra,0xfffff
    80002048:	51c080e7          	jalr	1308(ra) # 80001560 <uvmcopy>
    8000204c:	06054763          	bltz	a0,800020ba <fork+0xb4>
  np->sz = p->sz;
    80002050:	0389b783          	ld	a5,56(s3)
    80002054:	02f93c23          	sd	a5,56(s2)
  acquire(&wait_lock);/////////////////////////////////////////////////////////////////check
    80002058:	00010517          	auipc	a0,0x10
    8000205c:	27850513          	addi	a0,a0,632 # 800122d0 <wait_lock>
    80002060:	fffff097          	auipc	ra,0xfffff
    80002064:	b66080e7          	jalr	-1178(ra) # 80000bc6 <acquire>
  *(np_first_thread->trapframe) = *(t->trapframe);
    80002068:	60b4                	ld	a3,64(s1)
    8000206a:	87b6                	mv	a5,a3
    8000206c:	2c893703          	ld	a4,712(s2)
    80002070:	12068693          	addi	a3,a3,288
    80002074:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80002078:	6788                	ld	a0,8(a5)
    8000207a:	6b8c                	ld	a1,16(a5)
    8000207c:	6f90                	ld	a2,24(a5)
    8000207e:	01073023          	sd	a6,0(a4)
    80002082:	e708                	sd	a0,8(a4)
    80002084:	eb0c                	sd	a1,16(a4)
    80002086:	ef10                	sd	a2,24(a4)
    80002088:	02078793          	addi	a5,a5,32
    8000208c:	02070713          	addi	a4,a4,32
    80002090:	fed792e3          	bne	a5,a3,80002074 <fork+0x6e>
  np_first_thread->trapframe->a0 = 0;  // TODO: change reading the ret value from proc a0 to thread a0
    80002094:	2c893783          	ld	a5,712(s2)
    80002098:	0607b823          	sd	zero,112(a5)
  release(&wait_lock);////////////////////////////////////////////////////////////////check
    8000209c:	00010517          	auipc	a0,0x10
    800020a0:	23450513          	addi	a0,a0,564 # 800122d0 <wait_lock>
    800020a4:	fffff097          	auipc	ra,0xfffff
    800020a8:	bf8080e7          	jalr	-1032(ra) # 80000c9c <release>
  for(i = 0; i < NOFILE; i++)
    800020ac:	05098493          	addi	s1,s3,80
    800020b0:	05090a13          	addi	s4,s2,80
    800020b4:	0d098a93          	addi	s5,s3,208
    800020b8:	a00d                	j	800020da <fork+0xd4>
    freeproc(np);
    800020ba:	854a                	mv	a0,s2
    800020bc:	00000097          	auipc	ra,0x0
    800020c0:	c4a080e7          	jalr	-950(ra) # 80001d06 <freeproc>
    release(&np->lock);
    800020c4:	854a                	mv	a0,s2
    800020c6:	fffff097          	auipc	ra,0xfffff
    800020ca:	bd6080e7          	jalr	-1066(ra) # 80000c9c <release>
    return -1;
    800020ce:	5a7d                	li	s4,-1
    800020d0:	a0f9                	j	8000219e <fork+0x198>
  for(i = 0; i < NOFILE; i++)
    800020d2:	04a1                	addi	s1,s1,8
    800020d4:	0a21                	addi	s4,s4,8
    800020d6:	01548b63          	beq	s1,s5,800020ec <fork+0xe6>
    if(p->ofile[i])
    800020da:	6088                	ld	a0,0(s1)
    800020dc:	d97d                	beqz	a0,800020d2 <fork+0xcc>
      np->ofile[i] = filedup(p->ofile[i]);
    800020de:	00003097          	auipc	ra,0x3
    800020e2:	4d6080e7          	jalr	1238(ra) # 800055b4 <filedup>
    800020e6:	00aa3023          	sd	a0,0(s4)
    800020ea:	b7e5                	j	800020d2 <fork+0xcc>
  np->cwd = idup(p->cwd);
    800020ec:	0d09b503          	ld	a0,208(s3)
    800020f0:	00002097          	auipc	ra,0x2
    800020f4:	638080e7          	jalr	1592(ra) # 80004728 <idup>
    800020f8:	0ca93823          	sd	a0,208(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020fc:	4641                	li	a2,16
    800020fe:	0d898593          	addi	a1,s3,216
    80002102:	0d890513          	addi	a0,s2,216
    80002106:	fffff097          	auipc	ra,0xfffff
    8000210a:	d30080e7          	jalr	-720(ra) # 80000e36 <safestrcpy>
  np->signal_mask = p->signal_mask;
    8000210e:	0ec9a783          	lw	a5,236(s3)
    80002112:	0ef92623          	sw	a5,236(s2)
  for(int i=0;i<32;i++){
    80002116:	0f898693          	addi	a3,s3,248
    8000211a:	0f890713          	addi	a4,s2,248
  np->signal_mask = p->signal_mask;
    8000211e:	1f800793          	li	a5,504
  for(int i=0;i<32;i++){
    80002122:	27800513          	li	a0,632
    np->signal_handlers[i] = p->signal_handlers[i];
    80002126:	6290                	ld	a2,0(a3)
    80002128:	e310                	sd	a2,0(a4)
    np->handlers_sigmasks[i] = p->handlers_sigmasks[i];
    8000212a:	00f98633          	add	a2,s3,a5
    8000212e:	420c                	lw	a1,0(a2)
    80002130:	00f90633          	add	a2,s2,a5
    80002134:	c20c                	sw	a1,0(a2)
  for(int i=0;i<32;i++){
    80002136:	06a1                	addi	a3,a3,8
    80002138:	0721                	addi	a4,a4,8
    8000213a:	0791                	addi	a5,a5,4
    8000213c:	fea795e3          	bne	a5,a0,80002126 <fork+0x120>
  np-> pending_signals=0;
    80002140:	0e092423          	sw	zero,232(s2)
  pid = np->pid;
    80002144:	02492a03          	lw	s4,36(s2)
  release(&np->lock);
    80002148:	854a                	mv	a0,s2
    8000214a:	fffff097          	auipc	ra,0xfffff
    8000214e:	b52080e7          	jalr	-1198(ra) # 80000c9c <release>
  acquire(&wait_lock);
    80002152:	00010497          	auipc	s1,0x10
    80002156:	17e48493          	addi	s1,s1,382 # 800122d0 <wait_lock>
    8000215a:	8526                	mv	a0,s1
    8000215c:	fffff097          	auipc	ra,0xfffff
    80002160:	a6a080e7          	jalr	-1430(ra) # 80000bc6 <acquire>
  np->parent = p;
    80002164:	03393823          	sd	s3,48(s2)
  release(&wait_lock);
    80002168:	8526                	mv	a0,s1
    8000216a:	fffff097          	auipc	ra,0xfffff
    8000216e:	b32080e7          	jalr	-1230(ra) # 80000c9c <release>
  acquire(&np->lock);
    80002172:	854a                	mv	a0,s2
    80002174:	fffff097          	auipc	ra,0xfffff
    80002178:	a52080e7          	jalr	-1454(ra) # 80000bc6 <acquire>
  np->state = RUNNABLE;   
    8000217c:	4789                	li	a5,2
    8000217e:	00f92c23          	sw	a5,24(s2)
  np_first_thread->state = TRUNNABLE;
    80002182:	478d                	li	a5,3
    80002184:	2af92023          	sw	a5,672(s2)
  release(&np_first_thread->lock);
    80002188:	28890513          	addi	a0,s2,648
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	b10080e7          	jalr	-1264(ra) # 80000c9c <release>
  release(&np->lock);
    80002194:	854a                	mv	a0,s2
    80002196:	fffff097          	auipc	ra,0xfffff
    8000219a:	b06080e7          	jalr	-1274(ra) # 80000c9c <release>
}
    8000219e:	8552                	mv	a0,s4
    800021a0:	70e2                	ld	ra,56(sp)
    800021a2:	7442                	ld	s0,48(sp)
    800021a4:	74a2                	ld	s1,40(sp)
    800021a6:	7902                	ld	s2,32(sp)
    800021a8:	69e2                	ld	s3,24(sp)
    800021aa:	6a42                	ld	s4,16(sp)
    800021ac:	6aa2                	ld	s5,8(sp)
    800021ae:	6121                	addi	sp,sp,64
    800021b0:	8082                	ret
    return -1;
    800021b2:	5a7d                	li	s4,-1
    800021b4:	b7ed                	j	8000219e <fork+0x198>

00000000800021b6 <scheduler>:
{
    800021b6:	711d                	addi	sp,sp,-96
    800021b8:	ec86                	sd	ra,88(sp)
    800021ba:	e8a2                	sd	s0,80(sp)
    800021bc:	e4a6                	sd	s1,72(sp)
    800021be:	e0ca                	sd	s2,64(sp)
    800021c0:	fc4e                	sd	s3,56(sp)
    800021c2:	f852                	sd	s4,48(sp)
    800021c4:	f456                	sd	s5,40(sp)
    800021c6:	f05a                	sd	s6,32(sp)
    800021c8:	ec5e                	sd	s7,24(sp)
    800021ca:	e862                	sd	s8,16(sp)
    800021cc:	e466                	sd	s9,8(sp)
    800021ce:	1080                	addi	s0,sp,96
    800021d0:	8792                	mv	a5,tp
  int id = r_tp();
    800021d2:	2781                	sext.w	a5,a5
  c->proc = 0;
    800021d4:	00479713          	slli	a4,a5,0x4
    800021d8:	00f706b3          	add	a3,a4,a5
    800021dc:	00369613          	slli	a2,a3,0x3
    800021e0:	00010697          	auipc	a3,0x10
    800021e4:	0c068693          	addi	a3,a3,192 # 800122a0 <pid_lock>
    800021e8:	96b2                	add	a3,a3,a2
    800021ea:	0406b423          	sd	zero,72(a3)
  c->kthread=0;
    800021ee:	0c06b423          	sd	zero,200(a3)
            swtch(&c->context, &t->context);
    800021f2:	00010717          	auipc	a4,0x10
    800021f6:	0fe70713          	addi	a4,a4,254 # 800122f0 <cpus+0x8>
    800021fa:	00e60bb3          	add	s7,a2,a4
            c->proc = p;
    800021fe:	8b36                	mv	s6,a3
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002200:	6a85                	lui	s5,0x1
    80002202:	848a8a93          	addi	s5,s5,-1976 # 848 <_entry-0x7ffff7b8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002206:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000220a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000220e:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002212:	00010917          	auipc	s2,0x10
    80002216:	51690913          	addi	s2,s2,1302 # 80012728 <proc>
    8000221a:	a8a9                	j	80002274 <scheduler+0xbe>
          release(&t->lock);
    8000221c:	8526                	mv	a0,s1
    8000221e:	fffff097          	auipc	ra,0xfffff
    80002222:	a7e080e7          	jalr	-1410(ra) # 80000c9c <release>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002226:	0b848493          	addi	s1,s1,184
    8000222a:	03348e63          	beq	s1,s3,80002266 <scheduler+0xb0>
          acquire(&t->lock);
    8000222e:	8526                	mv	a0,s1
    80002230:	fffff097          	auipc	ra,0xfffff
    80002234:	996080e7          	jalr	-1642(ra) # 80000bc6 <acquire>
          if(t->state == TRUNNABLE && !t->frozen) {          
    80002238:	4c9c                	lw	a5,24(s1)
    8000223a:	ff4791e3          	bne	a5,s4,8000221c <scheduler+0x66>
    8000223e:	58dc                	lw	a5,52(s1)
    80002240:	fff1                	bnez	a5,8000221c <scheduler+0x66>
            t->state = TRUNNING;
    80002242:	0194ac23          	sw	s9,24(s1)
            c->proc = p;
    80002246:	052b3423          	sd	s2,72(s6)
            c->kthread = t;
    8000224a:	0c9b3423          	sd	s1,200(s6)
            swtch(&c->context, &t->context);
    8000224e:	04848593          	addi	a1,s1,72
    80002252:	855e                	mv	a0,s7
    80002254:	00001097          	auipc	ra,0x1
    80002258:	f3a080e7          	jalr	-198(ra) # 8000318e <swtch>
            c->proc = 0;
    8000225c:	040b3423          	sd	zero,72(s6)
            c->kthread=0;
    80002260:	0c0b3423          	sd	zero,200(s6)
    80002264:	bf65                	j	8000221c <scheduler+0x66>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002266:	9956                	add	s2,s2,s5
    80002268:	00031797          	auipc	a5,0x31
    8000226c:	6c078793          	addi	a5,a5,1728 # 80033928 <tickslock>
    80002270:	f8f90be3          	beq	s2,a5,80002206 <scheduler+0x50>
      if(p->state == RUNNABLE) {
    80002274:	01892703          	lw	a4,24(s2)
    80002278:	4789                	li	a5,2
    8000227a:	fef716e3          	bne	a4,a5,80002266 <scheduler+0xb0>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    8000227e:	28890493          	addi	s1,s2,648
          if(t->state == TRUNNABLE && !t->frozen) {          
    80002282:	4a0d                	li	s4,3
            t->state = TRUNNING;
    80002284:	4c91                	li	s9,4
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002286:	015909b3          	add	s3,s2,s5
    8000228a:	b755                	j	8000222e <scheduler+0x78>

000000008000228c <sched>:
{
    8000228c:	7179                	addi	sp,sp,-48
    8000228e:	f406                	sd	ra,40(sp)
    80002290:	f022                	sd	s0,32(sp)
    80002292:	ec26                	sd	s1,24(sp)
    80002294:	e84a                	sd	s2,16(sp)
    80002296:	e44e                	sd	s3,8(sp)
    80002298:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000229a:	fffff097          	auipc	ra,0xfffff
    8000229e:	7e2080e7          	jalr	2018(ra) # 80001a7c <myproc>
    800022a2:	892a                	mv	s2,a0
  struct kthread *t=mykthread();
    800022a4:	00000097          	auipc	ra,0x0
    800022a8:	818080e7          	jalr	-2024(ra) # 80001abc <mykthread>
    800022ac:	84aa                	mv	s1,a0
  if(!holding(&t->lock))
    800022ae:	fffff097          	auipc	ra,0xfffff
    800022b2:	89e080e7          	jalr	-1890(ra) # 80000b4c <holding>
    800022b6:	c959                	beqz	a0,8000234c <sched+0xc0>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022b8:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800022ba:	0007871b          	sext.w	a4,a5
    800022be:	00471793          	slli	a5,a4,0x4
    800022c2:	97ba                	add	a5,a5,a4
    800022c4:	078e                	slli	a5,a5,0x3
    800022c6:	00010717          	auipc	a4,0x10
    800022ca:	fda70713          	addi	a4,a4,-38 # 800122a0 <pid_lock>
    800022ce:	97ba                	add	a5,a5,a4
    800022d0:	0c07a703          	lw	a4,192(a5)
    800022d4:	4785                	li	a5,1
    800022d6:	08f71363          	bne	a4,a5,8000235c <sched+0xd0>
  if(t->state == TRUNNING){
    800022da:	4c98                	lw	a4,24(s1)
    800022dc:	4791                	li	a5,4
    800022de:	08f70763          	beq	a4,a5,8000236c <sched+0xe0>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022e2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800022e6:	8b89                	andi	a5,a5,2
  if(intr_get())
    800022e8:	efdd                	bnez	a5,800023a6 <sched+0x11a>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022ea:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800022ec:	00010917          	auipc	s2,0x10
    800022f0:	fb490913          	addi	s2,s2,-76 # 800122a0 <pid_lock>
    800022f4:	0007871b          	sext.w	a4,a5
    800022f8:	00471793          	slli	a5,a4,0x4
    800022fc:	97ba                	add	a5,a5,a4
    800022fe:	078e                	slli	a5,a5,0x3
    80002300:	97ca                	add	a5,a5,s2
    80002302:	0c47a983          	lw	s3,196(a5)
    80002306:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    80002308:	0007859b          	sext.w	a1,a5
    8000230c:	00459793          	slli	a5,a1,0x4
    80002310:	97ae                	add	a5,a5,a1
    80002312:	078e                	slli	a5,a5,0x3
    80002314:	00010597          	auipc	a1,0x10
    80002318:	fdc58593          	addi	a1,a1,-36 # 800122f0 <cpus+0x8>
    8000231c:	95be                	add	a1,a1,a5
    8000231e:	04848513          	addi	a0,s1,72
    80002322:	00001097          	auipc	ra,0x1
    80002326:	e6c080e7          	jalr	-404(ra) # 8000318e <swtch>
    8000232a:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000232c:	0007871b          	sext.w	a4,a5
    80002330:	00471793          	slli	a5,a4,0x4
    80002334:	97ba                	add	a5,a5,a4
    80002336:	078e                	slli	a5,a5,0x3
    80002338:	97ca                	add	a5,a5,s2
    8000233a:	0d37a223          	sw	s3,196(a5)
}
    8000233e:	70a2                	ld	ra,40(sp)
    80002340:	7402                	ld	s0,32(sp)
    80002342:	64e2                	ld	s1,24(sp)
    80002344:	6942                	ld	s2,16(sp)
    80002346:	69a2                	ld	s3,8(sp)
    80002348:	6145                	addi	sp,sp,48
    8000234a:	8082                	ret
    panic("sched t->lock");
    8000234c:	00007517          	auipc	a0,0x7
    80002350:	efc50513          	addi	a0,a0,-260 # 80009248 <digits+0x208>
    80002354:	ffffe097          	auipc	ra,0xffffe
    80002358:	1da080e7          	jalr	474(ra) # 8000052e <panic>
    panic("sched locks");
    8000235c:	00007517          	auipc	a0,0x7
    80002360:	efc50513          	addi	a0,a0,-260 # 80009258 <digits+0x218>
    80002364:	ffffe097          	auipc	ra,0xffffe
    80002368:	1ca080e7          	jalr	458(ra) # 8000052e <panic>
              int proc_index= (int)(p-proc);// TODO delete
    8000236c:	00010797          	auipc	a5,0x10
    80002370:	3bc78793          	addi	a5,a5,956 # 80012728 <proc>
    80002374:	40f907b3          	sub	a5,s2,a5
    80002378:	878d                	srai	a5,a5,0x3
    printf("sched%d\n",proc_index);
    8000237a:	00007597          	auipc	a1,0x7
    8000237e:	c865b583          	ld	a1,-890(a1) # 80009000 <etext>
    80002382:	02b785bb          	mulw	a1,a5,a1
    80002386:	00007517          	auipc	a0,0x7
    8000238a:	ee250513          	addi	a0,a0,-286 # 80009268 <digits+0x228>
    8000238e:	ffffe097          	auipc	ra,0xffffe
    80002392:	1ea080e7          	jalr	490(ra) # 80000578 <printf>
    panic("sched running");
    80002396:	00007517          	auipc	a0,0x7
    8000239a:	ee250513          	addi	a0,a0,-286 # 80009278 <digits+0x238>
    8000239e:	ffffe097          	auipc	ra,0xffffe
    800023a2:	190080e7          	jalr	400(ra) # 8000052e <panic>
    panic("sched interruptible");
    800023a6:	00007517          	auipc	a0,0x7
    800023aa:	ee250513          	addi	a0,a0,-286 # 80009288 <digits+0x248>
    800023ae:	ffffe097          	auipc	ra,0xffffe
    800023b2:	180080e7          	jalr	384(ra) # 8000052e <panic>

00000000800023b6 <yield>:
{
    800023b6:	1101                	addi	sp,sp,-32
    800023b8:	ec06                	sd	ra,24(sp)
    800023ba:	e822                	sd	s0,16(sp)
    800023bc:	e426                	sd	s1,8(sp)
    800023be:	1000                	addi	s0,sp,32
  struct kthread *t =mykthread();
    800023c0:	fffff097          	auipc	ra,0xfffff
    800023c4:	6fc080e7          	jalr	1788(ra) # 80001abc <mykthread>
    800023c8:	84aa                	mv	s1,a0
  acquire(&t->lock);
    800023ca:	ffffe097          	auipc	ra,0xffffe
    800023ce:	7fc080e7          	jalr	2044(ra) # 80000bc6 <acquire>
  t->state = TRUNNABLE;
    800023d2:	478d                	li	a5,3
    800023d4:	cc9c                	sw	a5,24(s1)
  sched();
    800023d6:	00000097          	auipc	ra,0x0
    800023da:	eb6080e7          	jalr	-330(ra) # 8000228c <sched>
  release(&t->lock);
    800023de:	8526                	mv	a0,s1
    800023e0:	fffff097          	auipc	ra,0xfffff
    800023e4:	8bc080e7          	jalr	-1860(ra) # 80000c9c <release>
}
    800023e8:	60e2                	ld	ra,24(sp)
    800023ea:	6442                	ld	s0,16(sp)
    800023ec:	64a2                	ld	s1,8(sp)
    800023ee:	6105                	addi	sp,sp,32
    800023f0:	8082                	ret

00000000800023f2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800023f2:	7179                	addi	sp,sp,-48
    800023f4:	f406                	sd	ra,40(sp)
    800023f6:	f022                	sd	s0,32(sp)
    800023f8:	ec26                	sd	s1,24(sp)
    800023fa:	e84a                	sd	s2,16(sp)
    800023fc:	e44e                	sd	s3,8(sp)
    800023fe:	1800                	addi	s0,sp,48
    80002400:	89aa                	mv	s3,a0
    80002402:	892e                	mv	s2,a1
  struct kthread *t=mykthread();
    80002404:	fffff097          	auipc	ra,0xfffff
    80002408:	6b8080e7          	jalr	1720(ra) # 80001abc <mykthread>
    8000240c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&t->lock);  //DOC: sleeplock1
    8000240e:	ffffe097          	auipc	ra,0xffffe
    80002412:	7b8080e7          	jalr	1976(ra) # 80000bc6 <acquire>
  release(lk);
    80002416:	854a                	mv	a0,s2
    80002418:	fffff097          	auipc	ra,0xfffff
    8000241c:	884080e7          	jalr	-1916(ra) # 80000c9c <release>

  // Go to sleep.
  t->chan = chan;
    80002420:	0334b023          	sd	s3,32(s1)
  t->state = TSLEEPING;
    80002424:	4789                	li	a5,2
    80002426:	cc9c                	sw	a5,24(s1)

  sched();
    80002428:	00000097          	auipc	ra,0x0
    8000242c:	e64080e7          	jalr	-412(ra) # 8000228c <sched>

  // Tidy up.
  t->chan = 0;
    80002430:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&t->lock);
    80002434:	8526                	mv	a0,s1
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	866080e7          	jalr	-1946(ra) # 80000c9c <release>

  acquire(lk);
    8000243e:	854a                	mv	a0,s2
    80002440:	ffffe097          	auipc	ra,0xffffe
    80002444:	786080e7          	jalr	1926(ra) # 80000bc6 <acquire>
}
    80002448:	70a2                	ld	ra,40(sp)
    8000244a:	7402                	ld	s0,32(sp)
    8000244c:	64e2                	ld	s1,24(sp)
    8000244e:	6942                	ld	s2,16(sp)
    80002450:	69a2                	ld	s3,8(sp)
    80002452:	6145                	addi	sp,sp,48
    80002454:	8082                	ret

0000000080002456 <wait>:
{
    80002456:	715d                	addi	sp,sp,-80
    80002458:	e486                	sd	ra,72(sp)
    8000245a:	e0a2                	sd	s0,64(sp)
    8000245c:	fc26                	sd	s1,56(sp)
    8000245e:	f84a                	sd	s2,48(sp)
    80002460:	f44e                	sd	s3,40(sp)
    80002462:	f052                	sd	s4,32(sp)
    80002464:	ec56                	sd	s5,24(sp)
    80002466:	e85a                	sd	s6,16(sp)
    80002468:	e45e                	sd	s7,8(sp)
    8000246a:	0880                	addi	s0,sp,80
    8000246c:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    8000246e:	fffff097          	auipc	ra,0xfffff
    80002472:	60e080e7          	jalr	1550(ra) # 80001a7c <myproc>
    80002476:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002478:	00010517          	auipc	a0,0x10
    8000247c:	e5850513          	addi	a0,a0,-424 # 800122d0 <wait_lock>
    80002480:	ffffe097          	auipc	ra,0xffffe
    80002484:	746080e7          	jalr	1862(ra) # 80000bc6 <acquire>
        if(np->state == ZOMBIE){
    80002488:	4b0d                	li	s6,3
        havekids = 1;
    8000248a:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000248c:	6985                	lui	s3,0x1
    8000248e:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002492:	00031a17          	auipc	s4,0x31
    80002496:	496a0a13          	addi	s4,s4,1174 # 80033928 <tickslock>
    havekids = 0;
    8000249a:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    8000249c:	00010497          	auipc	s1,0x10
    800024a0:	28c48493          	addi	s1,s1,652 # 80012728 <proc>
    800024a4:	a0b5                	j	80002510 <wait+0xba>
          pid = np->pid;
    800024a6:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800024aa:	000b8e63          	beqz	s7,800024c6 <wait+0x70>
    800024ae:	4691                	li	a3,4
    800024b0:	02048613          	addi	a2,s1,32
    800024b4:	85de                	mv	a1,s7
    800024b6:	04093503          	ld	a0,64(s2)
    800024ba:	fffff097          	auipc	ra,0xfffff
    800024be:	1aa080e7          	jalr	426(ra) # 80001664 <copyout>
    800024c2:	02054563          	bltz	a0,800024ec <wait+0x96>
          freeproc(np);
    800024c6:	8526                	mv	a0,s1
    800024c8:	00000097          	auipc	ra,0x0
    800024cc:	83e080e7          	jalr	-1986(ra) # 80001d06 <freeproc>
          release(&np->lock);
    800024d0:	8526                	mv	a0,s1
    800024d2:	ffffe097          	auipc	ra,0xffffe
    800024d6:	7ca080e7          	jalr	1994(ra) # 80000c9c <release>
          release(&wait_lock);
    800024da:	00010517          	auipc	a0,0x10
    800024de:	df650513          	addi	a0,a0,-522 # 800122d0 <wait_lock>
    800024e2:	ffffe097          	auipc	ra,0xffffe
    800024e6:	7ba080e7          	jalr	1978(ra) # 80000c9c <release>
          return pid;
    800024ea:	a09d                	j	80002550 <wait+0xfa>
            release(&np->lock);
    800024ec:	8526                	mv	a0,s1
    800024ee:	ffffe097          	auipc	ra,0xffffe
    800024f2:	7ae080e7          	jalr	1966(ra) # 80000c9c <release>
            release(&wait_lock);
    800024f6:	00010517          	auipc	a0,0x10
    800024fa:	dda50513          	addi	a0,a0,-550 # 800122d0 <wait_lock>
    800024fe:	ffffe097          	auipc	ra,0xffffe
    80002502:	79e080e7          	jalr	1950(ra) # 80000c9c <release>
            return -1;
    80002506:	59fd                	li	s3,-1
    80002508:	a0a1                	j	80002550 <wait+0xfa>
    for(np = proc; np < &proc[NPROC]; np++){
    8000250a:	94ce                	add	s1,s1,s3
    8000250c:	03448463          	beq	s1,s4,80002534 <wait+0xde>
      if(np->parent == p){
    80002510:	789c                	ld	a5,48(s1)
    80002512:	ff279ce3          	bne	a5,s2,8000250a <wait+0xb4>
        acquire(&np->lock);
    80002516:	8526                	mv	a0,s1
    80002518:	ffffe097          	auipc	ra,0xffffe
    8000251c:	6ae080e7          	jalr	1710(ra) # 80000bc6 <acquire>
        if(np->state == ZOMBIE){
    80002520:	4c9c                	lw	a5,24(s1)
    80002522:	f96782e3          	beq	a5,s6,800024a6 <wait+0x50>
        release(&np->lock);
    80002526:	8526                	mv	a0,s1
    80002528:	ffffe097          	auipc	ra,0xffffe
    8000252c:	774080e7          	jalr	1908(ra) # 80000c9c <release>
        havekids = 1;
    80002530:	8756                	mv	a4,s5
    80002532:	bfe1                	j	8000250a <wait+0xb4>
    if(!havekids || p->killed==1){
    80002534:	c709                	beqz	a4,8000253e <wait+0xe8>
    80002536:	01c92783          	lw	a5,28(s2)
    8000253a:	03579763          	bne	a5,s5,80002568 <wait+0x112>
      release(&wait_lock);
    8000253e:	00010517          	auipc	a0,0x10
    80002542:	d9250513          	addi	a0,a0,-622 # 800122d0 <wait_lock>
    80002546:	ffffe097          	auipc	ra,0xffffe
    8000254a:	756080e7          	jalr	1878(ra) # 80000c9c <release>
      return -1;
    8000254e:	59fd                	li	s3,-1
}
    80002550:	854e                	mv	a0,s3
    80002552:	60a6                	ld	ra,72(sp)
    80002554:	6406                	ld	s0,64(sp)
    80002556:	74e2                	ld	s1,56(sp)
    80002558:	7942                	ld	s2,48(sp)
    8000255a:	79a2                	ld	s3,40(sp)
    8000255c:	7a02                	ld	s4,32(sp)
    8000255e:	6ae2                	ld	s5,24(sp)
    80002560:	6b42                	ld	s6,16(sp)
    80002562:	6ba2                	ld	s7,8(sp)
    80002564:	6161                	addi	sp,sp,80
    80002566:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002568:	00010597          	auipc	a1,0x10
    8000256c:	d6858593          	addi	a1,a1,-664 # 800122d0 <wait_lock>
    80002570:	854a                	mv	a0,s2
    80002572:	00000097          	auipc	ra,0x0
    80002576:	e80080e7          	jalr	-384(ra) # 800023f2 <sleep>
    havekids = 0;
    8000257a:	b705                	j	8000249a <wait+0x44>

000000008000257c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000257c:	711d                	addi	sp,sp,-96
    8000257e:	ec86                	sd	ra,88(sp)
    80002580:	e8a2                	sd	s0,80(sp)
    80002582:	e4a6                	sd	s1,72(sp)
    80002584:	e0ca                	sd	s2,64(sp)
    80002586:	fc4e                	sd	s3,56(sp)
    80002588:	f852                	sd	s4,48(sp)
    8000258a:	f456                	sd	s5,40(sp)
    8000258c:	f05a                	sd	s6,32(sp)
    8000258e:	ec5e                	sd	s7,24(sp)
    80002590:	e862                	sd	s8,16(sp)
    80002592:	e466                	sd	s9,8(sp)
    80002594:	1080                	addi	s0,sp,96
    80002596:	8c2a                	mv	s8,a0
  struct proc *p;
  struct kthread *t;
  struct kthread *my_t = mykthread();
    80002598:	fffff097          	auipc	ra,0xfffff
    8000259c:	524080e7          	jalr	1316(ra) # 80001abc <mykthread>
    800025a0:	8aaa                	mv	s5,a0

  for(p = proc; p < &proc[NPROC]; p++) {
    800025a2:	00010917          	auipc	s2,0x10
    800025a6:	40e90913          	addi	s2,s2,1038 # 800129b0 <proc+0x288>
    800025aa:	00031b97          	auipc	s7,0x31
    800025ae:	606b8b93          	addi	s7,s7,1542 # 80033bb0 <bcache+0x270>
    // acquire(&p->lock);
    if(p->state == RUNNABLE){
    800025b2:	4989                	li	s3,2
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
        if(t != my_t){
          acquire(&t->lock);
          if(t->state == TSLEEPING && t->chan == chan) {
            t->state = TRUNNABLE;
    800025b4:	4c8d                	li	s9,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800025b6:	6b05                	lui	s6,0x1
    800025b8:	848b0b13          	addi	s6,s6,-1976 # 848 <_entry-0x7ffff7b8>
    800025bc:	a82d                	j	800025f6 <wakeup+0x7a>
          }
          release(&t->lock);
    800025be:	8526                	mv	a0,s1
    800025c0:	ffffe097          	auipc	ra,0xffffe
    800025c4:	6dc080e7          	jalr	1756(ra) # 80000c9c <release>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800025c8:	0b848493          	addi	s1,s1,184
    800025cc:	03448263          	beq	s1,s4,800025f0 <wakeup+0x74>
        if(t != my_t){
    800025d0:	fe9a8ce3          	beq	s5,s1,800025c8 <wakeup+0x4c>
          acquire(&t->lock);
    800025d4:	8526                	mv	a0,s1
    800025d6:	ffffe097          	auipc	ra,0xffffe
    800025da:	5f0080e7          	jalr	1520(ra) # 80000bc6 <acquire>
          if(t->state == TSLEEPING && t->chan == chan) {
    800025de:	4c9c                	lw	a5,24(s1)
    800025e0:	fd379fe3          	bne	a5,s3,800025be <wakeup+0x42>
    800025e4:	709c                	ld	a5,32(s1)
    800025e6:	fd879ce3          	bne	a5,s8,800025be <wakeup+0x42>
            t->state = TRUNNABLE;
    800025ea:	0194ac23          	sw	s9,24(s1)
    800025ee:	bfc1                	j	800025be <wakeup+0x42>
  for(p = proc; p < &proc[NPROC]; p++) {
    800025f0:	995a                	add	s2,s2,s6
    800025f2:	01790a63          	beq	s2,s7,80002606 <wakeup+0x8a>
    if(p->state == RUNNABLE){
    800025f6:	84ca                	mv	s1,s2
    800025f8:	d9092783          	lw	a5,-624(s2)
    800025fc:	ff379ae3          	bne	a5,s3,800025f0 <wakeup+0x74>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    80002600:	5c090a13          	addi	s4,s2,1472
    80002604:	b7f1                	j	800025d0 <wakeup+0x54>
        }
      }
    }
    // release(&p->lock);
  }
}
    80002606:	60e6                	ld	ra,88(sp)
    80002608:	6446                	ld	s0,80(sp)
    8000260a:	64a6                	ld	s1,72(sp)
    8000260c:	6906                	ld	s2,64(sp)
    8000260e:	79e2                	ld	s3,56(sp)
    80002610:	7a42                	ld	s4,48(sp)
    80002612:	7aa2                	ld	s5,40(sp)
    80002614:	7b02                	ld	s6,32(sp)
    80002616:	6be2                	ld	s7,24(sp)
    80002618:	6c42                	ld	s8,16(sp)
    8000261a:	6ca2                	ld	s9,8(sp)
    8000261c:	6125                	addi	sp,sp,96
    8000261e:	8082                	ret

0000000080002620 <reparent>:
{
    80002620:	7139                	addi	sp,sp,-64
    80002622:	fc06                	sd	ra,56(sp)
    80002624:	f822                	sd	s0,48(sp)
    80002626:	f426                	sd	s1,40(sp)
    80002628:	f04a                	sd	s2,32(sp)
    8000262a:	ec4e                	sd	s3,24(sp)
    8000262c:	e852                	sd	s4,16(sp)
    8000262e:	e456                	sd	s5,8(sp)
    80002630:	0080                	addi	s0,sp,64
    80002632:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002634:	00010497          	auipc	s1,0x10
    80002638:	0f448493          	addi	s1,s1,244 # 80012728 <proc>
      pp->parent = initproc;
    8000263c:	00008a97          	auipc	s5,0x8
    80002640:	9eca8a93          	addi	s5,s5,-1556 # 8000a028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002644:	6905                	lui	s2,0x1
    80002646:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    8000264a:	00031a17          	auipc	s4,0x31
    8000264e:	2dea0a13          	addi	s4,s4,734 # 80033928 <tickslock>
    80002652:	a021                	j	8000265a <reparent+0x3a>
    80002654:	94ca                	add	s1,s1,s2
    80002656:	01448d63          	beq	s1,s4,80002670 <reparent+0x50>
    if(pp->parent == p){
    8000265a:	789c                	ld	a5,48(s1)
    8000265c:	ff379ce3          	bne	a5,s3,80002654 <reparent+0x34>
      pp->parent = initproc;
    80002660:	000ab503          	ld	a0,0(s5)
    80002664:	f888                	sd	a0,48(s1)
      wakeup(initproc);
    80002666:	00000097          	auipc	ra,0x0
    8000266a:	f16080e7          	jalr	-234(ra) # 8000257c <wakeup>
    8000266e:	b7dd                	j	80002654 <reparent+0x34>
}
    80002670:	70e2                	ld	ra,56(sp)
    80002672:	7442                	ld	s0,48(sp)
    80002674:	74a2                	ld	s1,40(sp)
    80002676:	7902                	ld	s2,32(sp)
    80002678:	69e2                	ld	s3,24(sp)
    8000267a:	6a42                	ld	s4,16(sp)
    8000267c:	6aa2                	ld	s5,8(sp)
    8000267e:	6121                	addi	sp,sp,64
    80002680:	8082                	ret

0000000080002682 <exit_proccess>:
{
    80002682:	7139                	addi	sp,sp,-64
    80002684:	fc06                	sd	ra,56(sp)
    80002686:	f822                	sd	s0,48(sp)
    80002688:	f426                	sd	s1,40(sp)
    8000268a:	f04a                	sd	s2,32(sp)
    8000268c:	ec4e                	sd	s3,24(sp)
    8000268e:	e852                	sd	s4,16(sp)
    80002690:	e456                	sd	s5,8(sp)
    80002692:	e05a                	sd	s6,0(sp)
    80002694:	0080                	addi	s0,sp,64
    80002696:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002698:	fffff097          	auipc	ra,0xfffff
    8000269c:	3e4080e7          	jalr	996(ra) # 80001a7c <myproc>
    800026a0:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    800026a2:	fffff097          	auipc	ra,0xfffff
    800026a6:	41a080e7          	jalr	1050(ra) # 80001abc <mykthread>
    800026aa:	8aaa                	mv	s5,a0
  int proc_index= (int)(p-proc);// TODO delete
    800026ac:	00010797          	auipc	a5,0x10
    800026b0:	07c78793          	addi	a5,a5,124 # 80012728 <proc>
    800026b4:	40f987b3          	sub	a5,s3,a5
    800026b8:	878d                	srai	a5,a5,0x3
    800026ba:	00007a17          	auipc	s4,0x7
    800026be:	946a3a03          	ld	s4,-1722(s4) # 80009000 <etext>
    800026c2:	03478a3b          	mulw	s4,a5,s4
  if(p == initproc)
    800026c6:	00008797          	auipc	a5,0x8
    800026ca:	9627b783          	ld	a5,-1694(a5) # 8000a028 <initproc>
    800026ce:	05098493          	addi	s1,s3,80
    800026d2:	0d098913          	addi	s2,s3,208
    800026d6:	03379363          	bne	a5,s3,800026fc <exit_proccess+0x7a>
    panic("init exiting");
    800026da:	00007517          	auipc	a0,0x7
    800026de:	bc650513          	addi	a0,a0,-1082 # 800092a0 <digits+0x260>
    800026e2:	ffffe097          	auipc	ra,0xffffe
    800026e6:	e4c080e7          	jalr	-436(ra) # 8000052e <panic>
      fileclose(f);
    800026ea:	00003097          	auipc	ra,0x3
    800026ee:	f1c080e7          	jalr	-228(ra) # 80005606 <fileclose>
      p->ofile[fd] = 0;
    800026f2:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800026f6:	04a1                	addi	s1,s1,8
    800026f8:	01248563          	beq	s1,s2,80002702 <exit_proccess+0x80>
    if(p->ofile[fd]){
    800026fc:	6088                	ld	a0,0(s1)
    800026fe:	f575                	bnez	a0,800026ea <exit_proccess+0x68>
    80002700:	bfdd                	j	800026f6 <exit_proccess+0x74>
  begin_op();
    80002702:	00003097          	auipc	ra,0x3
    80002706:	a38080e7          	jalr	-1480(ra) # 8000513a <begin_op>
  iput(p->cwd);
    8000270a:	0d09b503          	ld	a0,208(s3)
    8000270e:	00002097          	auipc	ra,0x2
    80002712:	212080e7          	jalr	530(ra) # 80004920 <iput>
  end_op();
    80002716:	00003097          	auipc	ra,0x3
    8000271a:	aa4080e7          	jalr	-1372(ra) # 800051ba <end_op>
  p->cwd = 0;
    8000271e:	0c09b823          	sd	zero,208(s3)
  acquire(&wait_lock);
    80002722:	00010497          	auipc	s1,0x10
    80002726:	bae48493          	addi	s1,s1,-1106 # 800122d0 <wait_lock>
    8000272a:	8526                	mv	a0,s1
    8000272c:	ffffe097          	auipc	ra,0xffffe
    80002730:	49a080e7          	jalr	1178(ra) # 80000bc6 <acquire>
  reparent(p);
    80002734:	854e                	mv	a0,s3
    80002736:	00000097          	auipc	ra,0x0
    8000273a:	eea080e7          	jalr	-278(ra) # 80002620 <reparent>
  wakeup(p->parent);
    8000273e:	0309b503          	ld	a0,48(s3)
    80002742:	00000097          	auipc	ra,0x0
    80002746:	e3a080e7          	jalr	-454(ra) # 8000257c <wakeup>
  acquire(&p->lock);
    8000274a:	854e                	mv	a0,s3
    8000274c:	ffffe097          	auipc	ra,0xffffe
    80002750:	47a080e7          	jalr	1146(ra) # 80000bc6 <acquire>
  p->xstate = status;
    80002754:	0369a023          	sw	s6,32(s3)
  p->state = ZOMBIE;
    80002758:	478d                	li	a5,3
    8000275a:	00f9ac23          	sw	a5,24(s3)
  t->state=TZOMBIE;
    8000275e:	4795                	li	a5,5
    80002760:	00faac23          	sw	a5,24(s5)
  release(&wait_lock);
    80002764:	8526                	mv	a0,s1
    80002766:	ffffe097          	auipc	ra,0xffffe
    8000276a:	536080e7          	jalr	1334(ra) # 80000c9c <release>
  acquire(&t->lock);
    8000276e:	8556                	mv	a0,s5
    80002770:	ffffe097          	auipc	ra,0xffffe
    80002774:	456080e7          	jalr	1110(ra) # 80000bc6 <acquire>
  release(&p->lock);// ze po achav :) 
    80002778:	854e                	mv	a0,s3
    8000277a:	ffffe097          	auipc	ra,0xffffe
    8000277e:	522080e7          	jalr	1314(ra) # 80000c9c <release>
  sched();
    80002782:	00000097          	auipc	ra,0x0
    80002786:	b0a080e7          	jalr	-1270(ra) # 8000228c <sched>
  printf("zombie exit %d\n",proc_index);
    8000278a:	85d2                	mv	a1,s4
    8000278c:	00007517          	auipc	a0,0x7
    80002790:	b2450513          	addi	a0,a0,-1244 # 800092b0 <digits+0x270>
    80002794:	ffffe097          	auipc	ra,0xffffe
    80002798:	de4080e7          	jalr	-540(ra) # 80000578 <printf>
  panic("zombie exit");
    8000279c:	00007517          	auipc	a0,0x7
    800027a0:	b2450513          	addi	a0,a0,-1244 # 800092c0 <digits+0x280>
    800027a4:	ffffe097          	auipc	ra,0xffffe
    800027a8:	d8a080e7          	jalr	-630(ra) # 8000052e <panic>

00000000800027ac <kthread_exit>:
kthread_exit(int status){
    800027ac:	7179                	addi	sp,sp,-48
    800027ae:	f406                	sd	ra,40(sp)
    800027b0:	f022                	sd	s0,32(sp)
    800027b2:	ec26                	sd	s1,24(sp)
    800027b4:	e84a                	sd	s2,16(sp)
    800027b6:	e44e                	sd	s3,8(sp)
    800027b8:	e052                	sd	s4,0(sp)
    800027ba:	1800                	addi	s0,sp,48
    800027bc:	89aa                	mv	s3,a0
  struct proc *p = myproc(); 
    800027be:	fffff097          	auipc	ra,0xfffff
    800027c2:	2be080e7          	jalr	702(ra) # 80001a7c <myproc>
    800027c6:	892a                	mv	s2,a0
  struct kthread *t=mykthread();
    800027c8:	fffff097          	auipc	ra,0xfffff
    800027cc:	2f4080e7          	jalr	756(ra) # 80001abc <mykthread>
    800027d0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800027d2:	854a                	mv	a0,s2
    800027d4:	ffffe097          	auipc	ra,0xffffe
    800027d8:	3f2080e7          	jalr	1010(ra) # 80000bc6 <acquire>
  p->active_threads--;
    800027dc:	02892783          	lw	a5,40(s2)
    800027e0:	37fd                	addiw	a5,a5,-1
    800027e2:	00078a1b          	sext.w	s4,a5
    800027e6:	02f92423          	sw	a5,40(s2)
  release(&p->lock);
    800027ea:	854a                	mv	a0,s2
    800027ec:	ffffe097          	auipc	ra,0xffffe
    800027f0:	4b0080e7          	jalr	1200(ra) # 80000c9c <release>
  acquire(&t->lock);
    800027f4:	8526                	mv	a0,s1
    800027f6:	ffffe097          	auipc	ra,0xffffe
    800027fa:	3d0080e7          	jalr	976(ra) # 80000bc6 <acquire>
  t->xstate = status;
    800027fe:	0334a623          	sw	s3,44(s1)
  t->state  = TZOMBIE;
    80002802:	4795                	li	a5,5
    80002804:	cc9c                	sw	a5,24(s1)
  release(&t->lock);
    80002806:	8526                	mv	a0,s1
    80002808:	ffffe097          	auipc	ra,0xffffe
    8000280c:	494080e7          	jalr	1172(ra) # 80000c9c <release>
  wakeup(t);
    80002810:	8526                	mv	a0,s1
    80002812:	00000097          	auipc	ra,0x0
    80002816:	d6a080e7          	jalr	-662(ra) # 8000257c <wakeup>
  if(curr_active_threads==0){
    8000281a:	000a1763          	bnez	s4,80002828 <kthread_exit+0x7c>
    exit_proccess(status);
    8000281e:	854e                	mv	a0,s3
    80002820:	00000097          	auipc	ra,0x0
    80002824:	e62080e7          	jalr	-414(ra) # 80002682 <exit_proccess>
    acquire(&t->lock);
    80002828:	8526                	mv	a0,s1
    8000282a:	ffffe097          	auipc	ra,0xffffe
    8000282e:	39c080e7          	jalr	924(ra) # 80000bc6 <acquire>
    sched();
    80002832:	00000097          	auipc	ra,0x0
    80002836:	a5a080e7          	jalr	-1446(ra) # 8000228c <sched>
    panic("zombie thread exit");
    8000283a:	00007517          	auipc	a0,0x7
    8000283e:	a9650513          	addi	a0,a0,-1386 # 800092d0 <digits+0x290>
    80002842:	ffffe097          	auipc	ra,0xffffe
    80002846:	cec080e7          	jalr	-788(ra) # 8000052e <panic>

000000008000284a <exit>:
exit(int status){
    8000284a:	7139                	addi	sp,sp,-64
    8000284c:	fc06                	sd	ra,56(sp)
    8000284e:	f822                	sd	s0,48(sp)
    80002850:	f426                	sd	s1,40(sp)
    80002852:	f04a                	sd	s2,32(sp)
    80002854:	ec4e                	sd	s3,24(sp)
    80002856:	e852                	sd	s4,16(sp)
    80002858:	e456                	sd	s5,8(sp)
    8000285a:	e05a                	sd	s6,0(sp)
    8000285c:	0080                	addi	s0,sp,64
    8000285e:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    80002860:	fffff097          	auipc	ra,0xfffff
    80002864:	21c080e7          	jalr	540(ra) # 80001a7c <myproc>
    80002868:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    8000286a:	fffff097          	auipc	ra,0xfffff
    8000286e:	252080e7          	jalr	594(ra) # 80001abc <mykthread>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002872:	28890493          	addi	s1,s2,648
    80002876:	6505                	lui	a0,0x1
    80002878:	84850513          	addi	a0,a0,-1976 # 848 <_entry-0x7ffff7b8>
    8000287c:	992a                	add	s2,s2,a0
    t->killed = 1;
    8000287e:	4a05                	li	s4,1
    if(t->state == TSLEEPING)
    80002880:	4989                	li	s3,2
      t->state = TRUNNABLE;
    80002882:	4b0d                	li	s6,3
    80002884:	a811                	j	80002898 <exit+0x4e>
    release(&t->lock);
    80002886:	8526                	mv	a0,s1
    80002888:	ffffe097          	auipc	ra,0xffffe
    8000288c:	414080e7          	jalr	1044(ra) # 80000c9c <release>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002890:	0b848493          	addi	s1,s1,184
    80002894:	00990f63          	beq	s2,s1,800028b2 <exit+0x68>
    acquire(&t->lock);
    80002898:	8526                	mv	a0,s1
    8000289a:	ffffe097          	auipc	ra,0xffffe
    8000289e:	32c080e7          	jalr	812(ra) # 80000bc6 <acquire>
    t->killed = 1;
    800028a2:	0344a423          	sw	s4,40(s1)
    if(t->state == TSLEEPING)
    800028a6:	4c9c                	lw	a5,24(s1)
    800028a8:	fd379fe3          	bne	a5,s3,80002886 <exit+0x3c>
      t->state = TRUNNABLE;
    800028ac:	0164ac23          	sw	s6,24(s1)
    800028b0:	bfd9                	j	80002886 <exit+0x3c>
  kthread_exit(status);
    800028b2:	8556                	mv	a0,s5
    800028b4:	00000097          	auipc	ra,0x0
    800028b8:	ef8080e7          	jalr	-264(ra) # 800027ac <kthread_exit>

00000000800028bc <sig_stop>:
//   return -1;
// }

int
sig_stop(int pid)//TODO delete if not used
{
    800028bc:	7179                	addi	sp,sp,-48
    800028be:	f406                	sd	ra,40(sp)
    800028c0:	f022                	sd	s0,32(sp)
    800028c2:	ec26                	sd	s1,24(sp)
    800028c4:	e84a                	sd	s2,16(sp)
    800028c6:	e44e                	sd	s3,8(sp)
    800028c8:	e052                	sd	s4,0(sp)
    800028ca:	1800                	addi	s0,sp,48
    800028cc:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800028ce:	00010497          	auipc	s1,0x10
    800028d2:	e5a48493          	addi	s1,s1,-422 # 80012728 <proc>
    800028d6:	6985                	lui	s3,0x1
    800028d8:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    800028dc:	00031a17          	auipc	s4,0x31
    800028e0:	04ca0a13          	addi	s4,s4,76 # 80033928 <tickslock>
    acquire(&p->lock);
    800028e4:	8526                	mv	a0,s1
    800028e6:	ffffe097          	auipc	ra,0xffffe
    800028ea:	2e0080e7          	jalr	736(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    800028ee:	50dc                	lw	a5,36(s1)
    800028f0:	01278c63          	beq	a5,s2,80002908 <sig_stop+0x4c>
      p->pending_signals|=(1<<SIGSTOP);

      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800028f4:	8526                	mv	a0,s1
    800028f6:	ffffe097          	auipc	ra,0xffffe
    800028fa:	3a6080e7          	jalr	934(ra) # 80000c9c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800028fe:	94ce                	add	s1,s1,s3
    80002900:	ff4492e3          	bne	s1,s4,800028e4 <sig_stop+0x28>
  }
  return -1;
    80002904:	557d                	li	a0,-1
    80002906:	a831                	j	80002922 <sig_stop+0x66>
      p->pending_signals|=(1<<SIGSTOP);
    80002908:	0e84a783          	lw	a5,232(s1)
    8000290c:	00020737          	lui	a4,0x20
    80002910:	8fd9                	or	a5,a5,a4
    80002912:	0ef4a423          	sw	a5,232(s1)
      release(&p->lock);
    80002916:	8526                	mv	a0,s1
    80002918:	ffffe097          	auipc	ra,0xffffe
    8000291c:	384080e7          	jalr	900(ra) # 80000c9c <release>
      return 0;
    80002920:	4501                	li	a0,0
}
    80002922:	70a2                	ld	ra,40(sp)
    80002924:	7402                	ld	s0,32(sp)
    80002926:	64e2                	ld	s1,24(sp)
    80002928:	6942                	ld	s2,16(sp)
    8000292a:	69a2                	ld	s3,8(sp)
    8000292c:	6a02                	ld	s4,0(sp)
    8000292e:	6145                	addi	sp,sp,48
    80002930:	8082                	ret

0000000080002932 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002932:	7179                	addi	sp,sp,-48
    80002934:	f406                	sd	ra,40(sp)
    80002936:	f022                	sd	s0,32(sp)
    80002938:	ec26                	sd	s1,24(sp)
    8000293a:	e84a                	sd	s2,16(sp)
    8000293c:	e44e                	sd	s3,8(sp)
    8000293e:	e052                	sd	s4,0(sp)
    80002940:	1800                	addi	s0,sp,48
    80002942:	84aa                	mv	s1,a0
    80002944:	892e                	mv	s2,a1
    80002946:	89b2                	mv	s3,a2
    80002948:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000294a:	fffff097          	auipc	ra,0xfffff
    8000294e:	132080e7          	jalr	306(ra) # 80001a7c <myproc>
  if(user_dst){
    80002952:	c08d                	beqz	s1,80002974 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002954:	86d2                	mv	a3,s4
    80002956:	864e                	mv	a2,s3
    80002958:	85ca                	mv	a1,s2
    8000295a:	6128                	ld	a0,64(a0)
    8000295c:	fffff097          	auipc	ra,0xfffff
    80002960:	d08080e7          	jalr	-760(ra) # 80001664 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002964:	70a2                	ld	ra,40(sp)
    80002966:	7402                	ld	s0,32(sp)
    80002968:	64e2                	ld	s1,24(sp)
    8000296a:	6942                	ld	s2,16(sp)
    8000296c:	69a2                	ld	s3,8(sp)
    8000296e:	6a02                	ld	s4,0(sp)
    80002970:	6145                	addi	sp,sp,48
    80002972:	8082                	ret
    memmove((char *)dst, src, len);
    80002974:	000a061b          	sext.w	a2,s4
    80002978:	85ce                	mv	a1,s3
    8000297a:	854a                	mv	a0,s2
    8000297c:	ffffe097          	auipc	ra,0xffffe
    80002980:	3c4080e7          	jalr	964(ra) # 80000d40 <memmove>
    return 0;
    80002984:	8526                	mv	a0,s1
    80002986:	bff9                	j	80002964 <either_copyout+0x32>

0000000080002988 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002988:	7179                	addi	sp,sp,-48
    8000298a:	f406                	sd	ra,40(sp)
    8000298c:	f022                	sd	s0,32(sp)
    8000298e:	ec26                	sd	s1,24(sp)
    80002990:	e84a                	sd	s2,16(sp)
    80002992:	e44e                	sd	s3,8(sp)
    80002994:	e052                	sd	s4,0(sp)
    80002996:	1800                	addi	s0,sp,48
    80002998:	892a                	mv	s2,a0
    8000299a:	84ae                	mv	s1,a1
    8000299c:	89b2                	mv	s3,a2
    8000299e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800029a0:	fffff097          	auipc	ra,0xfffff
    800029a4:	0dc080e7          	jalr	220(ra) # 80001a7c <myproc>
  if(user_src){
    800029a8:	c08d                	beqz	s1,800029ca <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800029aa:	86d2                	mv	a3,s4
    800029ac:	864e                	mv	a2,s3
    800029ae:	85ca                	mv	a1,s2
    800029b0:	6128                	ld	a0,64(a0)
    800029b2:	fffff097          	auipc	ra,0xfffff
    800029b6:	d3e080e7          	jalr	-706(ra) # 800016f0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800029ba:	70a2                	ld	ra,40(sp)
    800029bc:	7402                	ld	s0,32(sp)
    800029be:	64e2                	ld	s1,24(sp)
    800029c0:	6942                	ld	s2,16(sp)
    800029c2:	69a2                	ld	s3,8(sp)
    800029c4:	6a02                	ld	s4,0(sp)
    800029c6:	6145                	addi	sp,sp,48
    800029c8:	8082                	ret
    memmove(dst, (char*)src, len);
    800029ca:	000a061b          	sext.w	a2,s4
    800029ce:	85ce                	mv	a1,s3
    800029d0:	854a                	mv	a0,s2
    800029d2:	ffffe097          	auipc	ra,0xffffe
    800029d6:	36e080e7          	jalr	878(ra) # 80000d40 <memmove>
    return 0;
    800029da:	8526                	mv	a0,s1
    800029dc:	bff9                	j	800029ba <either_copyin+0x32>

00000000800029de <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800029de:	715d                	addi	sp,sp,-80
    800029e0:	e486                	sd	ra,72(sp)
    800029e2:	e0a2                	sd	s0,64(sp)
    800029e4:	fc26                	sd	s1,56(sp)
    800029e6:	f84a                	sd	s2,48(sp)
    800029e8:	f44e                	sd	s3,40(sp)
    800029ea:	f052                	sd	s4,32(sp)
    800029ec:	ec56                	sd	s5,24(sp)
    800029ee:	e85a                	sd	s6,16(sp)
    800029f0:	e45e                	sd	s7,8(sp)
    800029f2:	e062                	sd	s8,0(sp)
    800029f4:	0880                	addi	s0,sp,80


  struct proc *p;
  char *state;

  printf("\n");
    800029f6:	00006517          	auipc	a0,0x6
    800029fa:	6aa50513          	addi	a0,a0,1706 # 800090a0 <digits+0x60>
    800029fe:	ffffe097          	auipc	ra,0xffffe
    80002a02:	b7a080e7          	jalr	-1158(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002a06:	00010497          	auipc	s1,0x10
    80002a0a:	dfa48493          	addi	s1,s1,-518 # 80012800 <proc+0xd8>
    80002a0e:	00031997          	auipc	s3,0x31
    80002a12:	ff298993          	addi	s3,s3,-14 # 80033a00 <bcache+0xc0>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a16:	4b8d                	li	s7,3
      state = states[p->state];
    else
      state = "???";
    80002a18:	00007a17          	auipc	s4,0x7
    80002a1c:	8d0a0a13          	addi	s4,s4,-1840 # 800092e8 <digits+0x2a8>
    printf("%d %s %s", p->pid, state, p->name);
    80002a20:	00007b17          	auipc	s6,0x7
    80002a24:	8d0b0b13          	addi	s6,s6,-1840 # 800092f0 <digits+0x2b0>
    printf("\n");
    80002a28:	00006a97          	auipc	s5,0x6
    80002a2c:	678a8a93          	addi	s5,s5,1656 # 800090a0 <digits+0x60>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a30:	00007c17          	auipc	s8,0x7
    80002a34:	980c0c13          	addi	s8,s8,-1664 # 800093b0 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80002a38:	6905                	lui	s2,0x1
    80002a3a:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80002a3e:	a005                	j	80002a5e <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    80002a40:	f4c6a583          	lw	a1,-180(a3)
    80002a44:	855a                	mv	a0,s6
    80002a46:	ffffe097          	auipc	ra,0xffffe
    80002a4a:	b32080e7          	jalr	-1230(ra) # 80000578 <printf>
    printf("\n");
    80002a4e:	8556                	mv	a0,s5
    80002a50:	ffffe097          	auipc	ra,0xffffe
    80002a54:	b28080e7          	jalr	-1240(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002a58:	94ca                	add	s1,s1,s2
    80002a5a:	03348263          	beq	s1,s3,80002a7e <procdump+0xa0>
    if(p->state == UNUSED)
    80002a5e:	86a6                	mv	a3,s1
    80002a60:	f404a783          	lw	a5,-192(s1)
    80002a64:	dbf5                	beqz	a5,80002a58 <procdump+0x7a>
      state = "???";
    80002a66:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a68:	fcfbece3          	bltu	s7,a5,80002a40 <procdump+0x62>
    80002a6c:	02079713          	slli	a4,a5,0x20
    80002a70:	01d75793          	srli	a5,a4,0x1d
    80002a74:	97e2                	add	a5,a5,s8
    80002a76:	6390                	ld	a2,0(a5)
    80002a78:	f661                	bnez	a2,80002a40 <procdump+0x62>
      state = "???";
    80002a7a:	8652                	mv	a2,s4
    80002a7c:	b7d1                	j	80002a40 <procdump+0x62>
  }
}
    80002a7e:	60a6                	ld	ra,72(sp)
    80002a80:	6406                	ld	s0,64(sp)
    80002a82:	74e2                	ld	s1,56(sp)
    80002a84:	7942                	ld	s2,48(sp)
    80002a86:	79a2                	ld	s3,40(sp)
    80002a88:	7a02                	ld	s4,32(sp)
    80002a8a:	6ae2                	ld	s5,24(sp)
    80002a8c:	6b42                	ld	s6,16(sp)
    80002a8e:	6ba2                	ld	s7,8(sp)
    80002a90:	6c02                	ld	s8,0(sp)
    80002a92:	6161                	addi	sp,sp,80
    80002a94:	8082                	ret

0000000080002a96 <is_valid_sigmask>:

int 
is_valid_sigmask(int sigmask){
    80002a96:	1141                	addi	sp,sp,-16
    80002a98:	e422                	sd	s0,8(sp)
    80002a9a:	0800                	addi	s0,sp,16
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002a9c:	000207b7          	lui	a5,0x20
    80002aa0:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002aa4:	8d7d                	and	a0,a0,a5
    return 0;
  return 1;
}
    80002aa6:	00153513          	seqz	a0,a0
    80002aaa:	6422                	ld	s0,8(sp)
    80002aac:	0141                	addi	sp,sp,16
    80002aae:	8082                	ret

0000000080002ab0 <sigprocmask>:

uint
sigprocmask(uint new_procmask){
    80002ab0:	7179                	addi	sp,sp,-48
    80002ab2:	f406                	sd	ra,40(sp)
    80002ab4:	f022                	sd	s0,32(sp)
    80002ab6:	ec26                	sd	s1,24(sp)
    80002ab8:	e84a                	sd	s2,16(sp)
    80002aba:	e44e                	sd	s3,8(sp)
    80002abc:	1800                	addi	s0,sp,48
    80002abe:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002ac0:	fffff097          	auipc	ra,0xfffff
    80002ac4:	fbc080e7          	jalr	-68(ra) # 80001a7c <myproc>
  if(is_valid_sigmask(new_procmask) == 0)
    80002ac8:	000207b7          	lui	a5,0x20
    80002acc:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002ad0:	00f977b3          	and	a5,s2,a5
    return -1;
    80002ad4:	59fd                	li	s3,-1
  if(is_valid_sigmask(new_procmask) == 0)
    80002ad6:	ef99                	bnez	a5,80002af4 <sigprocmask+0x44>
    80002ad8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002ada:	ffffe097          	auipc	ra,0xffffe
    80002ade:	0ec080e7          	jalr	236(ra) # 80000bc6 <acquire>
  int old_procmask = p->signal_mask;
    80002ae2:	0ec4a983          	lw	s3,236(s1)
  p->signal_mask = new_procmask;
    80002ae6:	0f24a623          	sw	s2,236(s1)
  release(&p->lock);
    80002aea:	8526                	mv	a0,s1
    80002aec:	ffffe097          	auipc	ra,0xffffe
    80002af0:	1b0080e7          	jalr	432(ra) # 80000c9c <release>
  
  return old_procmask;
}
    80002af4:	854e                	mv	a0,s3
    80002af6:	70a2                	ld	ra,40(sp)
    80002af8:	7402                	ld	s0,32(sp)
    80002afa:	64e2                	ld	s1,24(sp)
    80002afc:	6942                	ld	s2,16(sp)
    80002afe:	69a2                	ld	s3,8(sp)
    80002b00:	6145                	addi	sp,sp,48
    80002b02:	8082                	ret

0000000080002b04 <sigaction>:

 
int 
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
  
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002b04:	0005079b          	sext.w	a5,a0
    80002b08:	477d                	li	a4,31
    80002b0a:	0cf76a63          	bltu	a4,a5,80002bde <sigaction+0xda>
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
    80002b0e:	7139                	addi	sp,sp,-64
    80002b10:	fc06                	sd	ra,56(sp)
    80002b12:	f822                	sd	s0,48(sp)
    80002b14:	f426                	sd	s1,40(sp)
    80002b16:	f04a                	sd	s2,32(sp)
    80002b18:	ec4e                	sd	s3,24(sp)
    80002b1a:	e852                	sd	s4,16(sp)
    80002b1c:	0080                	addi	s0,sp,64
    80002b1e:	84aa                	mv	s1,a0
    80002b20:	89ae                	mv	s3,a1
    80002b22:	8a32                	mv	s4,a2
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002b24:	37dd                	addiw	a5,a5,-9
    80002b26:	9bdd                	andi	a5,a5,-9
    80002b28:	2781                	sext.w	a5,a5
    80002b2a:	cfc5                	beqz	a5,80002be2 <sigaction+0xde>
    80002b2c:	cdcd                	beqz	a1,80002be6 <sigaction+0xe2>
    return -1;
  struct proc *p = myproc();
    80002b2e:	fffff097          	auipc	ra,0xfffff
    80002b32:	f4e080e7          	jalr	-178(ra) # 80001a7c <myproc>
    80002b36:	892a                	mv	s2,a0

  uint new_mask;
  copyin(p->pagetable, (char *)&new_mask, (uint64)&act->sigmask, sizeof(act->sigmask));
    80002b38:	4691                	li	a3,4
    80002b3a:	00898613          	addi	a2,s3,8
    80002b3e:	fcc40593          	addi	a1,s0,-52
    80002b42:	6128                	ld	a0,64(a0)
    80002b44:	fffff097          	auipc	ra,0xfffff
    80002b48:	bac080e7          	jalr	-1108(ra) # 800016f0 <copyin>
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002b4c:	fcc42703          	lw	a4,-52(s0)

  if(is_valid_sigmask(new_mask) == 0)
    80002b50:	000207b7          	lui	a5,0x20
    80002b54:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002b58:	8ff9                	and	a5,a5,a4
    80002b5a:	ebc1                	bnez	a5,80002bea <sigaction+0xe6>
    return -1;
  acquire(&p->lock);
    80002b5c:	854a                	mv	a0,s2
    80002b5e:	ffffe097          	auipc	ra,0xffffe
    80002b62:	068080e7          	jalr	104(ra) # 80000bc6 <acquire>

  if(oldact!=0){
    80002b66:	020a0b63          	beqz	s4,80002b9c <sigaction+0x98>
    copyout(p->pagetable, (uint64)&oldact->sa_handler, (char *)&p->signal_handlers[signum], sizeof(act->sa_handler));
    80002b6a:	01f48613          	addi	a2,s1,31
    80002b6e:	060e                	slli	a2,a2,0x3
    80002b70:	46a1                	li	a3,8
    80002b72:	964a                	add	a2,a2,s2
    80002b74:	85d2                	mv	a1,s4
    80002b76:	04093503          	ld	a0,64(s2)
    80002b7a:	fffff097          	auipc	ra,0xfffff
    80002b7e:	aea080e7          	jalr	-1302(ra) # 80001664 <copyout>
    copyout(p->pagetable, (uint64)&oldact->sigmask, (char *)&p->handlers_sigmasks[signum], sizeof(uint));
    80002b82:	07e48613          	addi	a2,s1,126
    80002b86:	060a                	slli	a2,a2,0x2
    80002b88:	4691                	li	a3,4
    80002b8a:	964a                	add	a2,a2,s2
    80002b8c:	008a0593          	addi	a1,s4,8
    80002b90:	04093503          	ld	a0,64(s2)
    80002b94:	fffff097          	auipc	ra,0xfffff
    80002b98:	ad0080e7          	jalr	-1328(ra) # 80001664 <copyout>
  }

  p->handlers_sigmasks[signum]=new_mask;
    80002b9c:	07c48793          	addi	a5,s1,124
    80002ba0:	078a                	slli	a5,a5,0x2
    80002ba2:	97ca                	add	a5,a5,s2
    80002ba4:	fcc42703          	lw	a4,-52(s0)
    80002ba8:	c798                	sw	a4,8(a5)
  copyin(p->pagetable, (char *)&p->signal_handlers[signum], (uint64)&act->sa_handler, sizeof(act->sa_handler));
    80002baa:	04fd                	addi	s1,s1,31
    80002bac:	048e                	slli	s1,s1,0x3
    80002bae:	46a1                	li	a3,8
    80002bb0:	864e                	mv	a2,s3
    80002bb2:	009905b3          	add	a1,s2,s1
    80002bb6:	04093503          	ld	a0,64(s2)
    80002bba:	fffff097          	auipc	ra,0xfffff
    80002bbe:	b36080e7          	jalr	-1226(ra) # 800016f0 <copyin>

  release(&p->lock);
    80002bc2:	854a                	mv	a0,s2
    80002bc4:	ffffe097          	auipc	ra,0xffffe
    80002bc8:	0d8080e7          	jalr	216(ra) # 80000c9c <release>



  return 0;
    80002bcc:	4501                	li	a0,0
}
    80002bce:	70e2                	ld	ra,56(sp)
    80002bd0:	7442                	ld	s0,48(sp)
    80002bd2:	74a2                	ld	s1,40(sp)
    80002bd4:	7902                	ld	s2,32(sp)
    80002bd6:	69e2                	ld	s3,24(sp)
    80002bd8:	6a42                	ld	s4,16(sp)
    80002bda:	6121                	addi	sp,sp,64
    80002bdc:	8082                	ret
    return -1;
    80002bde:	557d                	li	a0,-1
}
    80002be0:	8082                	ret
    return -1;
    80002be2:	557d                	li	a0,-1
    80002be4:	b7ed                	j	80002bce <sigaction+0xca>
    80002be6:	557d                	li	a0,-1
    80002be8:	b7dd                	j	80002bce <sigaction+0xca>
    return -1;
    80002bea:	557d                	li	a0,-1
    80002bec:	b7cd                	j	80002bce <sigaction+0xca>

0000000080002bee <sigret>:

void 
sigret(void){
    80002bee:	1101                	addi	sp,sp,-32
    80002bf0:	ec06                	sd	ra,24(sp)
    80002bf2:	e822                	sd	s0,16(sp)
    80002bf4:	e426                	sd	s1,8(sp)
    80002bf6:	e04a                	sd	s2,0(sp)
    80002bf8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002bfa:	fffff097          	auipc	ra,0xfffff
    80002bfe:	e82080e7          	jalr	-382(ra) # 80001a7c <myproc>
    80002c02:	84aa                	mv	s1,a0
  struct kthread *t=mykthread();
    80002c04:	fffff097          	auipc	ra,0xfffff
    80002c08:	eb8080e7          	jalr	-328(ra) # 80001abc <mykthread>
    80002c0c:	892a                	mv	s2,a0

  copyin(p->pagetable, (char *)t->trapframe, (uint64)p->user_trapframe_backup, sizeof(struct trapframe));
    80002c0e:	12000693          	li	a3,288
    80002c12:	2784b603          	ld	a2,632(s1)
    80002c16:	612c                	ld	a1,64(a0)
    80002c18:	60a8                	ld	a0,64(s1)
    80002c1a:	fffff097          	auipc	ra,0xfffff
    80002c1e:	ad6080e7          	jalr	-1322(ra) # 800016f0 <copyin>

  // restore user stack pointer
  acquire(&p->lock);
    80002c22:	8526                	mv	a0,s1
    80002c24:	ffffe097          	auipc	ra,0xffffe
    80002c28:	fa2080e7          	jalr	-94(ra) # 80000bc6 <acquire>
  // TODO maybe we will need to also lock the kthread lock
  t->trapframe->sp += sizeof(struct trapframe);
    80002c2c:	04093703          	ld	a4,64(s2)
    80002c30:	7b1c                	ld	a5,48(a4)
    80002c32:	12078793          	addi	a5,a5,288
    80002c36:	fb1c                	sd	a5,48(a4)

  p->signal_mask = p->signal_mask_backup;
    80002c38:	0f04a783          	lw	a5,240(s1)
    80002c3c:	0ef4a623          	sw	a5,236(s1)
  
  // Allow user signal handler since we finished handling the current
  p->handling_user_sig_flag = 0;
    80002c40:	2804a023          	sw	zero,640(s1)
  // Allow other thread to react to signals
  p->handling_sig_flag = 0;
    80002c44:	2804a223          	sw	zero,644(s1)
  release(&p->lock);
    80002c48:	8526                	mv	a0,s1
    80002c4a:	ffffe097          	auipc	ra,0xffffe
    80002c4e:	052080e7          	jalr	82(ra) # 80000c9c <release>
}
    80002c52:	60e2                	ld	ra,24(sp)
    80002c54:	6442                	ld	s0,16(sp)
    80002c56:	64a2                	ld	s1,8(sp)
    80002c58:	6902                	ld	s2,0(sp)
    80002c5a:	6105                	addi	sp,sp,32
    80002c5c:	8082                	ret

0000000080002c5e <turn_on_bit>:

// we call turn on and turn off when holding p->lock
void
turn_on_bit(struct proc* p, int signum){
    80002c5e:	1141                	addi	sp,sp,-16
    80002c60:	e422                	sd	s0,8(sp)
    80002c62:	0800                	addi	s0,sp,16
  if(!(p->pending_signals & (1 << signum)))
    80002c64:	0e852703          	lw	a4,232(a0)
    80002c68:	4785                	li	a5,1
    80002c6a:	00b795bb          	sllw	a1,a5,a1
    80002c6e:	00b777b3          	and	a5,a4,a1
    80002c72:	2781                	sext.w	a5,a5
    80002c74:	e781                	bnez	a5,80002c7c <turn_on_bit+0x1e>
    p->pending_signals ^= (1 << signum);  
    80002c76:	8db9                	xor	a1,a1,a4
    80002c78:	0eb52423          	sw	a1,232(a0)
}
    80002c7c:	6422                	ld	s0,8(sp)
    80002c7e:	0141                	addi	sp,sp,16
    80002c80:	8082                	ret

0000000080002c82 <kill>:
{
    80002c82:	7139                	addi	sp,sp,-64
    80002c84:	fc06                	sd	ra,56(sp)
    80002c86:	f822                	sd	s0,48(sp)
    80002c88:	f426                	sd	s1,40(sp)
    80002c8a:	f04a                	sd	s2,32(sp)
    80002c8c:	ec4e                	sd	s3,24(sp)
    80002c8e:	e852                	sd	s4,16(sp)
    80002c90:	e456                	sd	s5,8(sp)
    80002c92:	0080                	addi	s0,sp,64
    80002c94:	892a                	mv	s2,a0
    80002c96:	8aae                	mv	s5,a1
  for(p = proc; p < &proc[NPROC]; p++){
    80002c98:	00010497          	auipc	s1,0x10
    80002c9c:	a9048493          	addi	s1,s1,-1392 # 80012728 <proc>
    80002ca0:	6985                	lui	s3,0x1
    80002ca2:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002ca6:	00031a17          	auipc	s4,0x31
    80002caa:	c82a0a13          	addi	s4,s4,-894 # 80033928 <tickslock>
    acquire(&p->lock);
    80002cae:	8526                	mv	a0,s1
    80002cb0:	ffffe097          	auipc	ra,0xffffe
    80002cb4:	f16080e7          	jalr	-234(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    80002cb8:	50dc                	lw	a5,36(s1)
    80002cba:	01278c63          	beq	a5,s2,80002cd2 <kill+0x50>
    release(&p->lock);
    80002cbe:	8526                	mv	a0,s1
    80002cc0:	ffffe097          	auipc	ra,0xffffe
    80002cc4:	fdc080e7          	jalr	-36(ra) # 80000c9c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002cc8:	94ce                	add	s1,s1,s3
    80002cca:	ff4492e3          	bne	s1,s4,80002cae <kill+0x2c>
  return -1;
    80002cce:	557d                	li	a0,-1
    80002cd0:	a051                	j	80002d54 <kill+0xd2>
      if(p->state != RUNNABLE){
    80002cd2:	4c98                	lw	a4,24(s1)
    80002cd4:	4789                	li	a5,2
    80002cd6:	06f71963          	bne	a4,a5,80002d48 <kill+0xc6>
      if(p->signal_handlers[signum] == (void*)SIG_IGN){
    80002cda:	01ea8793          	addi	a5,s5,30
    80002cde:	078e                	slli	a5,a5,0x3
    80002ce0:	97a6                	add	a5,a5,s1
    80002ce2:	6798                	ld	a4,8(a5)
    80002ce4:	4785                	li	a5,1
    80002ce6:	08f70063          	beq	a4,a5,80002d66 <kill+0xe4>
      turn_on_bit(p,signum);
    80002cea:	85d6                	mv	a1,s5
    80002cec:	8526                	mv	a0,s1
    80002cee:	00000097          	auipc	ra,0x0
    80002cf2:	f70080e7          	jalr	-144(ra) # 80002c5e <turn_on_bit>
      release(&p->lock);
    80002cf6:	8526                	mv	a0,s1
    80002cf8:	ffffe097          	auipc	ra,0xffffe
    80002cfc:	fa4080e7          	jalr	-92(ra) # 80000c9c <release>
      if(signum == SIGKILL){
    80002d00:	47a5                	li	a5,9
      return 0;
    80002d02:	4501                	li	a0,0
      if(signum == SIGKILL){
    80002d04:	04fa9863          	bne	s5,a5,80002d54 <kill+0xd2>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002d08:	28848913          	addi	s2,s1,648
    80002d0c:	6785                	lui	a5,0x1
    80002d0e:	84878793          	addi	a5,a5,-1976 # 848 <_entry-0x7ffff7b8>
    80002d12:	94be                	add	s1,s1,a5
          if(t->state == TRUNNABLE){
    80002d14:	498d                	li	s3,3
            if(t->state == TSLEEPING){
    80002d16:	4a09                	li	s4,2
          if(t->state == TRUNNABLE){
    80002d18:	01892783          	lw	a5,24(s2)
    80002d1c:	07378663          	beq	a5,s3,80002d88 <kill+0x106>
            acquire(&t->lock);
    80002d20:	854a                	mv	a0,s2
    80002d22:	ffffe097          	auipc	ra,0xffffe
    80002d26:	ea4080e7          	jalr	-348(ra) # 80000bc6 <acquire>
            if(t->state == TSLEEPING){
    80002d2a:	01892783          	lw	a5,24(s2)
    80002d2e:	05478363          	beq	a5,s4,80002d74 <kill+0xf2>
            release(&t->lock);
    80002d32:	854a                	mv	a0,s2
    80002d34:	ffffe097          	auipc	ra,0xffffe
    80002d38:	f68080e7          	jalr	-152(ra) # 80000c9c <release>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002d3c:	0b890913          	addi	s2,s2,184
    80002d40:	fc991ce3          	bne	s2,s1,80002d18 <kill+0x96>
      return 0;
    80002d44:	4501                	li	a0,0
    80002d46:	a039                	j	80002d54 <kill+0xd2>
        release(&p->lock);
    80002d48:	8526                	mv	a0,s1
    80002d4a:	ffffe097          	auipc	ra,0xffffe
    80002d4e:	f52080e7          	jalr	-174(ra) # 80000c9c <release>
        return -1;
    80002d52:	557d                	li	a0,-1
}
    80002d54:	70e2                	ld	ra,56(sp)
    80002d56:	7442                	ld	s0,48(sp)
    80002d58:	74a2                	ld	s1,40(sp)
    80002d5a:	7902                	ld	s2,32(sp)
    80002d5c:	69e2                	ld	s3,24(sp)
    80002d5e:	6a42                	ld	s4,16(sp)
    80002d60:	6aa2                	ld	s5,8(sp)
    80002d62:	6121                	addi	sp,sp,64
    80002d64:	8082                	ret
        release(&p->lock);
    80002d66:	8526                	mv	a0,s1
    80002d68:	ffffe097          	auipc	ra,0xffffe
    80002d6c:	f34080e7          	jalr	-204(ra) # 80000c9c <release>
        return 1;
    80002d70:	4505                	li	a0,1
    80002d72:	b7cd                	j	80002d54 <kill+0xd2>
              t->state = TRUNNABLE;
    80002d74:	478d                	li	a5,3
    80002d76:	00f92c23          	sw	a5,24(s2)
              release(&t->lock);
    80002d7a:	854a                	mv	a0,s2
    80002d7c:	ffffe097          	auipc	ra,0xffffe
    80002d80:	f20080e7          	jalr	-224(ra) # 80000c9c <release>
      return 0;
    80002d84:	4501                	li	a0,0
              break;
    80002d86:	b7f9                	j	80002d54 <kill+0xd2>
      return 0;
    80002d88:	4501                	li	a0,0
    80002d8a:	b7e9                	j	80002d54 <kill+0xd2>

0000000080002d8c <turn_off_bit>:

void
turn_off_bit(struct proc* p, int signum){
    80002d8c:	1141                	addi	sp,sp,-16
    80002d8e:	e422                	sd	s0,8(sp)
    80002d90:	0800                	addi	s0,sp,16
  if(p->pending_signals & (1 << signum))
    80002d92:	0e852703          	lw	a4,232(a0)
    80002d96:	4785                	li	a5,1
    80002d98:	00b795bb          	sllw	a1,a5,a1
    80002d9c:	00b777b3          	and	a5,a4,a1
    80002da0:	2781                	sext.w	a5,a5
    80002da2:	c781                	beqz	a5,80002daa <turn_off_bit+0x1e>
    p->pending_signals ^= (1 << signum);  
    80002da4:	8db9                	xor	a1,a1,a4
    80002da6:	0eb52423          	sw	a1,232(a0)
}
    80002daa:	6422                	ld	s0,8(sp)
    80002dac:	0141                	addi	sp,sp,16
    80002dae:	8082                	ret

0000000080002db0 <kthread_create>:

int kthread_create(void (*start_func)(), void *stack){
    80002db0:	7139                	addi	sp,sp,-64
    80002db2:	fc06                	sd	ra,56(sp)
    80002db4:	f822                	sd	s0,48(sp)
    80002db6:	f426                	sd	s1,40(sp)
    80002db8:	f04a                	sd	s2,32(sp)
    80002dba:	ec4e                	sd	s3,24(sp)
    80002dbc:	e852                	sd	s4,16(sp)
    80002dbe:	e456                	sd	s5,8(sp)
    80002dc0:	e05a                	sd	s6,0(sp)
    80002dc2:	0080                	addi	s0,sp,64
    80002dc4:	8b2a                	mv	s6,a0
    80002dc6:	8aae                	mv	s5,a1
  struct proc *p = myproc();
    80002dc8:	fffff097          	auipc	ra,0xfffff
    80002dcc:	cb4080e7          	jalr	-844(ra) # 80001a7c <myproc>
    80002dd0:	8a2a                	mv	s4,a0
  struct kthread *curr_t = mykthread();
    80002dd2:	fffff097          	auipc	ra,0xfffff
    80002dd6:	cea080e7          	jalr	-790(ra) # 80001abc <mykthread>
    80002dda:	89aa                	mv	s3,a0
  struct kthread *other_t;

  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    80002ddc:	288a0493          	addi	s1,s4,648
    80002de0:	6905                	lui	s2,0x1
    80002de2:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80002de6:	9952                	add	s2,s2,s4
    80002de8:	a861                	j	80002e80 <kthread_create+0xd0>
  t->tid = 0;
    80002dea:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80002dee:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80002df2:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80002df6:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80002dfa:	0004ac23          	sw	zero,24(s1)

    if(curr_t != other_t){
      acquire(&other_t->lock);
      if(other_t->state == TUNUSED){
          freethread(other_t);  // free memory in case this thread entry was previously used
          init_thread(other_t);
    80002dfe:	8526                	mv	a0,s1
    80002e00:	fffff097          	auipc	ra,0xfffff
    80002e04:	dce080e7          	jalr	-562(ra) # 80001bce <init_thread>
          
          
          *(other_t->trapframe) = *(curr_t->trapframe);
    80002e08:	0409b683          	ld	a3,64(s3)
    80002e0c:	87b6                	mv	a5,a3
    80002e0e:	60b8                	ld	a4,64(s1)
    80002e10:	12068693          	addi	a3,a3,288
    80002e14:	0007b803          	ld	a6,0(a5)
    80002e18:	6788                	ld	a0,8(a5)
    80002e1a:	6b8c                	ld	a1,16(a5)
    80002e1c:	6f90                	ld	a2,24(a5)
    80002e1e:	01073023          	sd	a6,0(a4) # 20000 <_entry-0x7ffe0000>
    80002e22:	e708                	sd	a0,8(a4)
    80002e24:	eb0c                	sd	a1,16(a4)
    80002e26:	ef10                	sd	a2,24(a4)
    80002e28:	02078793          	addi	a5,a5,32
    80002e2c:	02070713          	addi	a4,a4,32
    80002e30:	fed792e3          	bne	a5,a3,80002e14 <kthread_create+0x64>
          other_t->trapframe->sp = (uint64)stack + MAX_STACK_SIZE-16;
    80002e34:	60b8                	ld	a4,64(s1)
    80002e36:	6785                	lui	a5,0x1
    80002e38:	f9078793          	addi	a5,a5,-112 # f90 <_entry-0x7ffff070>
    80002e3c:	9abe                	add	s5,s5,a5
    80002e3e:	03573823          	sd	s5,48(a4)

          other_t->trapframe->epc = (uint64)start_func;
    80002e42:	60bc                	ld	a5,64(s1)
    80002e44:	0167bc23          	sd	s6,24(a5)
          release(&other_t->lock);
    80002e48:	8526                	mv	a0,s1
    80002e4a:	ffffe097          	auipc	ra,0xffffe
    80002e4e:	e52080e7          	jalr	-430(ra) # 80000c9c <release>
          acquire(&p->lock);
    80002e52:	8552                	mv	a0,s4
    80002e54:	ffffe097          	auipc	ra,0xffffe
    80002e58:	d72080e7          	jalr	-654(ra) # 80000bc6 <acquire>
          p->active_threads++;
    80002e5c:	028a2783          	lw	a5,40(s4)
    80002e60:	2785                	addiw	a5,a5,1
    80002e62:	02fa2423          	sw	a5,40(s4)
          release(&p->lock);
    80002e66:	8552                	mv	a0,s4
    80002e68:	ffffe097          	auipc	ra,0xffffe
    80002e6c:	e34080e7          	jalr	-460(ra) # 80000c9c <release>
          other_t->state = TRUNNABLE;
    80002e70:	478d                	li	a5,3
    80002e72:	cc9c                	sw	a5,24(s1)
          return other_t->tid;
    80002e74:	5888                	lw	a0,48(s1)
    80002e76:	a02d                	j	80002ea0 <kthread_create+0xf0>
  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    80002e78:	0b848493          	addi	s1,s1,184
    80002e7c:	02990163          	beq	s2,s1,80002e9e <kthread_create+0xee>
    if(curr_t != other_t){
    80002e80:	fe998ce3          	beq	s3,s1,80002e78 <kthread_create+0xc8>
      acquire(&other_t->lock);
    80002e84:	8526                	mv	a0,s1
    80002e86:	ffffe097          	auipc	ra,0xffffe
    80002e8a:	d40080e7          	jalr	-704(ra) # 80000bc6 <acquire>
      if(other_t->state == TUNUSED){
    80002e8e:	4c9c                	lw	a5,24(s1)
    80002e90:	dfa9                	beqz	a5,80002dea <kthread_create+0x3a>
      }
      release(&other_t->lock);
    80002e92:	8526                	mv	a0,s1
    80002e94:	ffffe097          	auipc	ra,0xffffe
    80002e98:	e08080e7          	jalr	-504(ra) # 80000c9c <release>
    80002e9c:	bff1                	j	80002e78 <kthread_create+0xc8>
    }
  }
  return -1;
    80002e9e:	557d                	li	a0,-1
}
    80002ea0:	70e2                	ld	ra,56(sp)
    80002ea2:	7442                	ld	s0,48(sp)
    80002ea4:	74a2                	ld	s1,40(sp)
    80002ea6:	7902                	ld	s2,32(sp)
    80002ea8:	69e2                	ld	s3,24(sp)
    80002eaa:	6a42                	ld	s4,16(sp)
    80002eac:	6aa2                	ld	s5,8(sp)
    80002eae:	6b02                	ld	s6,0(sp)
    80002eb0:	6121                	addi	sp,sp,64
    80002eb2:	8082                	ret

0000000080002eb4 <kthread_join>:



int
kthread_join(int thread_id, int* status){
    80002eb4:	715d                	addi	sp,sp,-80
    80002eb6:	e486                	sd	ra,72(sp)
    80002eb8:	e0a2                	sd	s0,64(sp)
    80002eba:	fc26                	sd	s1,56(sp)
    80002ebc:	f84a                	sd	s2,48(sp)
    80002ebe:	f44e                	sd	s3,40(sp)
    80002ec0:	f052                	sd	s4,32(sp)
    80002ec2:	ec56                	sd	s5,24(sp)
    80002ec4:	e85a                	sd	s6,16(sp)
    80002ec6:	e45e                	sd	s7,8(sp)
    80002ec8:	0880                	addi	s0,sp,80
    80002eca:	8a2a                	mv	s4,a0
    80002ecc:	8b2e                	mv	s6,a1
  struct kthread *nt;
  struct proc *p = myproc();
    80002ece:	fffff097          	auipc	ra,0xfffff
    80002ed2:	bae080e7          	jalr	-1106(ra) # 80001a7c <myproc>
    80002ed6:	8aaa                	mv	s5,a0
  struct kthread *t = mykthread();
    80002ed8:	fffff097          	auipc	ra,0xfffff
    80002edc:	be4080e7          	jalr	-1052(ra) # 80001abc <mykthread>



  if(thread_id == t->tid)
    80002ee0:	591c                	lw	a5,48(a0)
    80002ee2:	17478a63          	beq	a5,s4,80003056 <kthread_join+0x1a2>
    80002ee6:	89aa                	mv	s3,a0
    return -1;
  acquire(&wait_lock);
    80002ee8:	0000f517          	auipc	a0,0xf
    80002eec:	3e850513          	addi	a0,a0,1000 # 800122d0 <wait_lock>
    80002ef0:	ffffe097          	auipc	ra,0xffffe
    80002ef4:	cd6080e7          	jalr	-810(ra) # 80000bc6 <acquire>
  // Search for thread in the procces threads array
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){
    80002ef8:	288a8913          	addi	s2,s5,648
    80002efc:	6485                	lui	s1,0x1
    80002efe:	84848493          	addi	s1,s1,-1976 # 848 <_entry-0x7ffff7b8>
    80002f02:	94d6                	add	s1,s1,s5
    80002f04:	a039                	j	80002f12 <kthread_join+0x5e>
    80002f06:	84ca                	mv	s1,s2
    80002f08:	a825                	j	80002f40 <kthread_join+0x8c>
    80002f0a:	0b890913          	addi	s2,s2,184
    80002f0e:	02990363          	beq	s2,s1,80002f34 <kthread_join+0x80>
    if(nt != t){
    80002f12:	ff298ce3          	beq	s3,s2,80002f0a <kthread_join+0x56>
      acquire(&nt->lock);
    80002f16:	854a                	mv	a0,s2
    80002f18:	ffffe097          	auipc	ra,0xffffe
    80002f1c:	cae080e7          	jalr	-850(ra) # 80000bc6 <acquire>

      if(nt->tid == thread_id){
    80002f20:	03092783          	lw	a5,48(s2)
    80002f24:	ff4781e3          	beq	a5,s4,80002f06 <kthread_join+0x52>
        //found target thread 
        goto found;
      }
      release(&nt->lock);
    80002f28:	854a                	mv	a0,s2
    80002f2a:	ffffe097          	auipc	ra,0xffffe
    80002f2e:	d72080e7          	jalr	-654(ra) # 80000c9c <release>
    80002f32:	bfe1                	j	80002f0a <kthread_join+0x56>
    }
  }

  if(nt->tid != thread_id){
    80002f34:	6785                	lui	a5,0x1
    80002f36:	97d6                	add	a5,a5,s5
    80002f38:	8787a783          	lw	a5,-1928(a5) # 878 <_entry-0x7ffff788>
    80002f3c:	09479c63          	bne	a5,s4,80002fd4 <kthread_join+0x120>
  found:
  // printf("%d:join to %d\n",p->pid,thread_id);  // TODO delete
  // Wait for thread to terminate
  // still holding nt lock
  for(;;){
      if(nt->state==TZOMBIE){
    80002f40:	4c9c                	lw	a5,24(s1)
    80002f42:	4715                	li	a4,5
    80002f44:	04e78163          	beq	a5,a4,80002f86 <kthread_join+0xd2>
      release(&nt->lock);
      release(&wait_lock);
      return -1;
    }
    release(&nt->lock);
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    80002f48:	0000fb97          	auipc	s7,0xf
    80002f4c:	388b8b93          	addi	s7,s7,904 # 800122d0 <wait_lock>
      if(nt->state==TZOMBIE){
    80002f50:	4915                	li	s2,5
      else if(nt->state==TUNUSED){ // in case someone already free that thread
    80002f52:	cbd5                	beqz	a5,80003006 <kthread_join+0x152>
    if(t->killed || nt->tid!=thread_id){
    80002f54:	0289a783          	lw	a5,40(s3)
    80002f58:	e3e5                	bnez	a5,80003038 <kthread_join+0x184>
    80002f5a:	589c                	lw	a5,48(s1)
    80002f5c:	0d479e63          	bne	a5,s4,80003038 <kthread_join+0x184>
    release(&nt->lock);
    80002f60:	8526                	mv	a0,s1
    80002f62:	ffffe097          	auipc	ra,0xffffe
    80002f66:	d3a080e7          	jalr	-710(ra) # 80000c9c <release>
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    80002f6a:	85de                	mv	a1,s7
    80002f6c:	8526                	mv	a0,s1
    80002f6e:	fffff097          	auipc	ra,0xfffff
    80002f72:	484080e7          	jalr	1156(ra) # 800023f2 <sleep>
    acquire(&nt->lock);
    80002f76:	8526                	mv	a0,s1
    80002f78:	ffffe097          	auipc	ra,0xffffe
    80002f7c:	c4e080e7          	jalr	-946(ra) # 80000bc6 <acquire>
      if(nt->state==TZOMBIE){
    80002f80:	4c9c                	lw	a5,24(s1)
    80002f82:	fd2798e3          	bne	a5,s2,80002f52 <kthread_join+0x9e>
        if(status != 0 && copyout(p->pagetable, (uint64)status, (char *)&nt->xstate,sizeof(nt->xstate)) < 0) {
    80002f86:	000b0e63          	beqz	s6,80002fa2 <kthread_join+0xee>
    80002f8a:	4691                	li	a3,4
    80002f8c:	02c48613          	addi	a2,s1,44
    80002f90:	85da                	mv	a1,s6
    80002f92:	040ab503          	ld	a0,64(s5)
    80002f96:	ffffe097          	auipc	ra,0xffffe
    80002f9a:	6ce080e7          	jalr	1742(ra) # 80001664 <copyout>
    80002f9e:	04054563          	bltz	a0,80002fe8 <kthread_join+0x134>
  t->tid = 0;
    80002fa2:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80002fa6:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80002faa:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80002fae:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80002fb2:	0004ac23          	sw	zero,24(s1)
        release(&nt->lock);
    80002fb6:	8526                	mv	a0,s1
    80002fb8:	ffffe097          	auipc	ra,0xffffe
    80002fbc:	ce4080e7          	jalr	-796(ra) # 80000c9c <release>
        release(&wait_lock);  //  successfull join     
    80002fc0:	0000f517          	auipc	a0,0xf
    80002fc4:	31050513          	addi	a0,a0,784 # 800122d0 <wait_lock>
    80002fc8:	ffffe097          	auipc	ra,0xffffe
    80002fcc:	cd4080e7          	jalr	-812(ra) # 80000c9c <release>
        return 0;
    80002fd0:	4501                	li	a0,0
    80002fd2:	a059                	j	80003058 <kthread_join+0x1a4>
    release(&wait_lock);
    80002fd4:	0000f517          	auipc	a0,0xf
    80002fd8:	2fc50513          	addi	a0,a0,764 # 800122d0 <wait_lock>
    80002fdc:	ffffe097          	auipc	ra,0xffffe
    80002fe0:	cc0080e7          	jalr	-832(ra) # 80000c9c <release>
    return -1;
    80002fe4:	557d                	li	a0,-1
    80002fe6:	a88d                	j	80003058 <kthread_join+0x1a4>
           release(&nt->lock);
    80002fe8:	8526                	mv	a0,s1
    80002fea:	ffffe097          	auipc	ra,0xffffe
    80002fee:	cb2080e7          	jalr	-846(ra) # 80000c9c <release>
           release(&wait_lock);
    80002ff2:	0000f517          	auipc	a0,0xf
    80002ff6:	2de50513          	addi	a0,a0,734 # 800122d0 <wait_lock>
    80002ffa:	ffffe097          	auipc	ra,0xffffe
    80002ffe:	ca2080e7          	jalr	-862(ra) # 80000c9c <release>
           return -1;                   
    80003002:	557d                	li	a0,-1
    80003004:	a891                	j	80003058 <kthread_join+0x1a4>
  t->tid = 0;
    80003006:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    8000300a:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    8000300e:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80003012:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80003016:	0004ac23          	sw	zero,24(s1)
        release(&nt->lock);
    8000301a:	8526                	mv	a0,s1
    8000301c:	ffffe097          	auipc	ra,0xffffe
    80003020:	c80080e7          	jalr	-896(ra) # 80000c9c <release>
        release(&wait_lock);  //  successfull join
    80003024:	0000f517          	auipc	a0,0xf
    80003028:	2ac50513          	addi	a0,a0,684 # 800122d0 <wait_lock>
    8000302c:	ffffe097          	auipc	ra,0xffffe
    80003030:	c70080e7          	jalr	-912(ra) # 80000c9c <release>
        return 1; //thread already exited
    80003034:	4505                	li	a0,1
    80003036:	a00d                	j	80003058 <kthread_join+0x1a4>
      release(&nt->lock);
    80003038:	8526                	mv	a0,s1
    8000303a:	ffffe097          	auipc	ra,0xffffe
    8000303e:	c62080e7          	jalr	-926(ra) # 80000c9c <release>
      release(&wait_lock);
    80003042:	0000f517          	auipc	a0,0xf
    80003046:	28e50513          	addi	a0,a0,654 # 800122d0 <wait_lock>
    8000304a:	ffffe097          	auipc	ra,0xffffe
    8000304e:	c52080e7          	jalr	-942(ra) # 80000c9c <release>
      return -1;
    80003052:	557d                	li	a0,-1
    80003054:	a011                	j	80003058 <kthread_join+0x1a4>
    return -1;
    80003056:	557d                	li	a0,-1
  }
}
    80003058:	60a6                	ld	ra,72(sp)
    8000305a:	6406                	ld	s0,64(sp)
    8000305c:	74e2                	ld	s1,56(sp)
    8000305e:	7942                	ld	s2,48(sp)
    80003060:	79a2                	ld	s3,40(sp)
    80003062:	7a02                	ld	s4,32(sp)
    80003064:	6ae2                	ld	s5,24(sp)
    80003066:	6b42                	ld	s6,16(sp)
    80003068:	6ba2                	ld	s7,8(sp)
    8000306a:	6161                	addi	sp,sp,80
    8000306c:	8082                	ret

000000008000306e <kthread_join_all>:

int
kthread_join_all(){
    8000306e:	7179                	addi	sp,sp,-48
    80003070:	f406                	sd	ra,40(sp)
    80003072:	f022                	sd	s0,32(sp)
    80003074:	ec26                	sd	s1,24(sp)
    80003076:	e84a                	sd	s2,16(sp)
    80003078:	e44e                	sd	s3,8(sp)
    8000307a:	e052                	sd	s4,0(sp)
    8000307c:	1800                	addi	s0,sp,48
  struct proc *p=myproc();
    8000307e:	fffff097          	auipc	ra,0xfffff
    80003082:	9fe080e7          	jalr	-1538(ra) # 80001a7c <myproc>
    80003086:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    80003088:	fffff097          	auipc	ra,0xfffff
    8000308c:	a34080e7          	jalr	-1484(ra) # 80001abc <mykthread>
    80003090:	8a2a                	mv	s4,a0
  struct kthread *nt;
  int res = 1;
  for(nt = p->kthreads; nt < &p->kthreads[NTHREAD]; nt++){
    80003092:	28898493          	addi	s1,s3,648
    80003096:	6505                	lui	a0,0x1
    80003098:	84850513          	addi	a0,a0,-1976 # 848 <_entry-0x7ffff7b8>
    8000309c:	99aa                	add	s3,s3,a0
  int res = 1;
    8000309e:	4905                	li	s2,1
    800030a0:	a029                	j	800030aa <kthread_join_all+0x3c>
  for(nt = p->kthreads; nt < &p->kthreads[NTHREAD]; nt++){
    800030a2:	0b848493          	addi	s1,s1,184
    800030a6:	00998e63          	beq	s3,s1,800030c2 <kthread_join_all+0x54>
    if(nt != t){
    800030aa:	fe9a0ce3          	beq	s4,s1,800030a2 <kthread_join_all+0x34>
      res &= kthread_join(nt->tid,0);
    800030ae:	4581                	li	a1,0
    800030b0:	5888                	lw	a0,48(s1)
    800030b2:	00000097          	auipc	ra,0x0
    800030b6:	e02080e7          	jalr	-510(ra) # 80002eb4 <kthread_join>
    800030ba:	01257933          	and	s2,a0,s2
    800030be:	2901                	sext.w	s2,s2
    800030c0:	b7cd                	j	800030a2 <kthread_join_all+0x34>
    }
  }

  return res;
}
    800030c2:	854a                	mv	a0,s2
    800030c4:	70a2                	ld	ra,40(sp)
    800030c6:	7402                	ld	s0,32(sp)
    800030c8:	64e2                	ld	s1,24(sp)
    800030ca:	6942                	ld	s2,16(sp)
    800030cc:	69a2                	ld	s3,8(sp)
    800030ce:	6a02                	ld	s4,0(sp)
    800030d0:	6145                	addi	sp,sp,48
    800030d2:	8082                	ret

00000000800030d4 <printTF>:


void 
printTF(struct kthread *t){//function for debuging, TODO delete
    800030d4:	7175                	addi	sp,sp,-144
    800030d6:	e506                	sd	ra,136(sp)
    800030d8:	e122                	sd	s0,128(sp)
    800030da:	fca6                	sd	s1,120(sp)
    800030dc:	0900                	addi	s0,sp,144
    800030de:	84aa                	mv	s1,a0
  printf("**************tid=%d*****************\n",t->tid);
    800030e0:	590c                	lw	a1,48(a0)
    800030e2:	00006517          	auipc	a0,0x6
    800030e6:	21e50513          	addi	a0,a0,542 # 80009300 <digits+0x2c0>
    800030ea:	ffffd097          	auipc	ra,0xffffd
    800030ee:	48e080e7          	jalr	1166(ra) # 80000578 <printf>
  // printf("t->tf->epc = %p\n",t->trapframe->epc);
  // printf("t->tf->ra = %p\n",t->trapframe->ra);
  // printf("t->tf->kernel_sp = %p\n",t->trapframe->kernel_sp);
  printf("t->kstack = %p\n",t->kstack);
    800030f2:	7c8c                	ld	a1,56(s1)
    800030f4:	00006517          	auipc	a0,0x6
    800030f8:	23450513          	addi	a0,a0,564 # 80009328 <digits+0x2e8>
    800030fc:	ffffd097          	auipc	ra,0xffffd
    80003100:	47c080e7          	jalr	1148(ra) # 80000578 <printf>
  printf("t->context = %p\n",t->context);
    80003104:	04848793          	addi	a5,s1,72
    80003108:	f7040713          	addi	a4,s0,-144
    8000310c:	0a848693          	addi	a3,s1,168
    80003110:	0007b803          	ld	a6,0(a5)
    80003114:	6788                	ld	a0,8(a5)
    80003116:	6b8c                	ld	a1,16(a5)
    80003118:	6f90                	ld	a2,24(a5)
    8000311a:	01073023          	sd	a6,0(a4)
    8000311e:	e708                	sd	a0,8(a4)
    80003120:	eb0c                	sd	a1,16(a4)
    80003122:	ef10                	sd	a2,24(a4)
    80003124:	02078793          	addi	a5,a5,32
    80003128:	02070713          	addi	a4,a4,32
    8000312c:	fed792e3          	bne	a5,a3,80003110 <printTF+0x3c>
    80003130:	6394                	ld	a3,0(a5)
    80003132:	679c                	ld	a5,8(a5)
    80003134:	e314                	sd	a3,0(a4)
    80003136:	e71c                	sd	a5,8(a4)
    80003138:	f7040593          	addi	a1,s0,-144
    8000313c:	00006517          	auipc	a0,0x6
    80003140:	1fc50513          	addi	a0,a0,508 # 80009338 <digits+0x2f8>
    80003144:	ffffd097          	auipc	ra,0xffffd
    80003148:	434080e7          	jalr	1076(ra) # 80000578 <printf>
  printf("t->tf->sp = %p\n",t->trapframe->sp);
    8000314c:	60bc                	ld	a5,64(s1)
    8000314e:	7b8c                	ld	a1,48(a5)
    80003150:	00006517          	auipc	a0,0x6
    80003154:	20050513          	addi	a0,a0,512 # 80009350 <digits+0x310>
    80003158:	ffffd097          	auipc	ra,0xffffd
    8000315c:	420080e7          	jalr	1056(ra) # 80000578 <printf>
  printf("t->state = %d\n",t->state);
    80003160:	4c8c                	lw	a1,24(s1)
    80003162:	00006517          	auipc	a0,0x6
    80003166:	1fe50513          	addi	a0,a0,510 # 80009360 <digits+0x320>
    8000316a:	ffffd097          	auipc	ra,0xffffd
    8000316e:	40e080e7          	jalr	1038(ra) # 80000578 <printf>
  printf("**************************************\n",t->tid);
    80003172:	588c                	lw	a1,48(s1)
    80003174:	00006517          	auipc	a0,0x6
    80003178:	1fc50513          	addi	a0,a0,508 # 80009370 <digits+0x330>
    8000317c:	ffffd097          	auipc	ra,0xffffd
    80003180:	3fc080e7          	jalr	1020(ra) # 80000578 <printf>

    80003184:	60aa                	ld	ra,136(sp)
    80003186:	640a                	ld	s0,128(sp)
    80003188:	74e6                	ld	s1,120(sp)
    8000318a:	6149                	addi	sp,sp,144
    8000318c:	8082                	ret

000000008000318e <swtch>:
    8000318e:	00153023          	sd	ra,0(a0)
    80003192:	00253423          	sd	sp,8(a0)
    80003196:	e900                	sd	s0,16(a0)
    80003198:	ed04                	sd	s1,24(a0)
    8000319a:	03253023          	sd	s2,32(a0)
    8000319e:	03353423          	sd	s3,40(a0)
    800031a2:	03453823          	sd	s4,48(a0)
    800031a6:	03553c23          	sd	s5,56(a0)
    800031aa:	05653023          	sd	s6,64(a0)
    800031ae:	05753423          	sd	s7,72(a0)
    800031b2:	05853823          	sd	s8,80(a0)
    800031b6:	05953c23          	sd	s9,88(a0)
    800031ba:	07a53023          	sd	s10,96(a0)
    800031be:	07b53423          	sd	s11,104(a0)
    800031c2:	0005b083          	ld	ra,0(a1)
    800031c6:	0085b103          	ld	sp,8(a1)
    800031ca:	6980                	ld	s0,16(a1)
    800031cc:	6d84                	ld	s1,24(a1)
    800031ce:	0205b903          	ld	s2,32(a1)
    800031d2:	0285b983          	ld	s3,40(a1)
    800031d6:	0305ba03          	ld	s4,48(a1)
    800031da:	0385ba83          	ld	s5,56(a1)
    800031de:	0405bb03          	ld	s6,64(a1)
    800031e2:	0485bb83          	ld	s7,72(a1)
    800031e6:	0505bc03          	ld	s8,80(a1)
    800031ea:	0585bc83          	ld	s9,88(a1)
    800031ee:	0605bd03          	ld	s10,96(a1)
    800031f2:	0685bd83          	ld	s11,104(a1)
    800031f6:	8082                	ret

00000000800031f8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800031f8:	1141                	addi	sp,sp,-16
    800031fa:	e406                	sd	ra,8(sp)
    800031fc:	e022                	sd	s0,0(sp)
    800031fe:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80003200:	00006597          	auipc	a1,0x6
    80003204:	1d058593          	addi	a1,a1,464 # 800093d0 <states.0+0x20>
    80003208:	00030517          	auipc	a0,0x30
    8000320c:	72050513          	addi	a0,a0,1824 # 80033928 <tickslock>
    80003210:	ffffe097          	auipc	ra,0xffffe
    80003214:	926080e7          	jalr	-1754(ra) # 80000b36 <initlock>
}
    80003218:	60a2                	ld	ra,8(sp)
    8000321a:	6402                	ld	s0,0(sp)
    8000321c:	0141                	addi	sp,sp,16
    8000321e:	8082                	ret

0000000080003220 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80003220:	1141                	addi	sp,sp,-16
    80003222:	e422                	sd	s0,8(sp)
    80003224:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003226:	00004797          	auipc	a5,0x4
    8000322a:	aaa78793          	addi	a5,a5,-1366 # 80006cd0 <kernelvec>
    8000322e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80003232:	6422                	ld	s0,8(sp)
    80003234:	0141                	addi	sp,sp,16
    80003236:	8082                	ret

0000000080003238 <check_should_cont>:
}

int 
check_should_cont(struct proc *p){
  for(int i=0;i<32;i++){
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && (((uint64)p->signal_handlers[i] == SIGCONT) || 
    80003238:	0e852303          	lw	t1,232(a0)
    8000323c:	0f850813          	addi	a6,a0,248
    80003240:	4685                	li	a3,1
    80003242:	4701                	li	a4,0
    80003244:	4885                	li	a7,1
  for(int i=0;i<32;i++){
    80003246:	4e7d                	li	t3,31
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && (((uint64)p->signal_handlers[i] == SIGCONT) || 
    80003248:	4ecd                	li	t4,19
    8000324a:	a801                	j	8000325a <check_should_cont+0x22>
  for(int i=0;i<32;i++){
    8000324c:	0006879b          	sext.w	a5,a3
    80003250:	04fe4663          	blt	t3,a5,8000329c <check_should_cont+0x64>
    80003254:	2705                	addiw	a4,a4,1
    80003256:	2685                	addiw	a3,a3,1
    80003258:	0821                	addi	a6,a6,8
    8000325a:	0007059b          	sext.w	a1,a4
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && (((uint64)p->signal_handlers[i] == SIGCONT) || 
    8000325e:	00e8963b          	sllw	a2,a7,a4
    80003262:	00c377b3          	and	a5,t1,a2
    80003266:	2781                	sext.w	a5,a5
    80003268:	d3f5                	beqz	a5,8000324c <check_should_cont+0x14>
    8000326a:	0ec52783          	lw	a5,236(a0)
    8000326e:	8ff1                	and	a5,a5,a2
    80003270:	2781                	sext.w	a5,a5
    80003272:	ffe9                	bnez	a5,8000324c <check_should_cont+0x14>
    80003274:	00083783          	ld	a5,0(a6)
    80003278:	01d78563          	beq	a5,t4,80003282 <check_should_cont+0x4a>
    8000327c:	fdd598e3          	bne	a1,t4,8000324c <check_should_cont+0x14>
          (i == SIGCONT && p->signal_handlers[i] == SIG_DFL))){
    80003280:	fbf1                	bnez	a5,80003254 <check_should_cont+0x1c>
check_should_cont(struct proc *p){
    80003282:	1141                	addi	sp,sp,-16
    80003284:	e406                	sd	ra,8(sp)
    80003286:	e022                	sd	s0,0(sp)
    80003288:	0800                	addi	s0,sp,16
        turn_off_bit(p, i);
    8000328a:	00000097          	auipc	ra,0x0
    8000328e:	b02080e7          	jalr	-1278(ra) # 80002d8c <turn_off_bit>
        return 1;
    80003292:	4505                	li	a0,1
      }
  }
  return 0;
}
    80003294:	60a2                	ld	ra,8(sp)
    80003296:	6402                	ld	s0,0(sp)
    80003298:	0141                	addi	sp,sp,16
    8000329a:	8082                	ret
  return 0;
    8000329c:	4501                	li	a0,0
}
    8000329e:	8082                	ret

00000000800032a0 <handle_stop>:



void
handle_stop(struct proc* p){
    800032a0:	7139                	addi	sp,sp,-64
    800032a2:	fc06                	sd	ra,56(sp)
    800032a4:	f822                	sd	s0,48(sp)
    800032a6:	f426                	sd	s1,40(sp)
    800032a8:	f04a                	sd	s2,32(sp)
    800032aa:	ec4e                	sd	s3,24(sp)
    800032ac:	e852                	sd	s4,16(sp)
    800032ae:	e456                	sd	s5,8(sp)
    800032b0:	e05a                	sd	s6,0(sp)
    800032b2:	0080                	addi	s0,sp,64
    800032b4:	89aa                	mv	s3,a0

  struct kthread *t;
  struct kthread *curr_t = mykthread();
    800032b6:	fffff097          	auipc	ra,0xfffff
    800032ba:	806080e7          	jalr	-2042(ra) # 80001abc <mykthread>
    800032be:	8aaa                	mv	s5,a0


  // Make all other threads belong to the same procces freeze 
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800032c0:	28898493          	addi	s1,s3,648
    800032c4:	6a05                	lui	s4,0x1
    800032c6:	848a0a13          	addi	s4,s4,-1976 # 848 <_entry-0x7ffff7b8>
    800032ca:	9a4e                	add	s4,s4,s3
    800032cc:	8926                	mv	s2,s1
    if(t!=curr_t){
      acquire(&t->lock);
      t->frozen=1;
    800032ce:	4b05                	li	s6,1
    800032d0:	a029                	j	800032da <handle_stop+0x3a>
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800032d2:	0b890913          	addi	s2,s2,184
    800032d6:	03490163          	beq	s2,s4,800032f8 <handle_stop+0x58>
    if(t!=curr_t){
    800032da:	ff2a8ce3          	beq	s5,s2,800032d2 <handle_stop+0x32>
      acquire(&t->lock);
    800032de:	854a                	mv	a0,s2
    800032e0:	ffffe097          	auipc	ra,0xffffe
    800032e4:	8e6080e7          	jalr	-1818(ra) # 80000bc6 <acquire>
      t->frozen=1;
    800032e8:	03692a23          	sw	s6,52(s2)
      release(&t->lock);
    800032ec:	854a                	mv	a0,s2
    800032ee:	ffffe097          	auipc	ra,0xffffe
    800032f2:	9ae080e7          	jalr	-1618(ra) # 80000c9c <release>
    800032f6:	bff1                	j	800032d2 <handle_stop+0x32>
    }
  }
  int should_cont = check_should_cont(p);
    800032f8:	854e                	mv	a0,s3
    800032fa:	00000097          	auipc	ra,0x0
    800032fe:	f3e080e7          	jalr	-194(ra) # 80003238 <check_should_cont>
  
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    80003302:	0e89a783          	lw	a5,232(s3)
    80003306:	2007f793          	andi	a5,a5,512
    8000330a:	e795                	bnez	a5,80003336 <handle_stop+0x96>
    8000330c:	e50d                	bnez	a0,80003336 <handle_stop+0x96>
    
    yield();
    8000330e:	fffff097          	auipc	ra,0xfffff
    80003312:	0a8080e7          	jalr	168(ra) # 800023b6 <yield>
    should_cont = check_should_cont(p);  
    80003316:	854e                	mv	a0,s3
    80003318:	00000097          	auipc	ra,0x0
    8000331c:	f20080e7          	jalr	-224(ra) # 80003238 <check_should_cont>
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    80003320:	0e89a783          	lw	a5,232(s3)
    80003324:	2007f793          	andi	a5,a5,512
    80003328:	e799                	bnez	a5,80003336 <handle_stop+0x96>
    8000332a:	d175                	beqz	a0,8000330e <handle_stop+0x6e>
    8000332c:	a029                	j	80003336 <handle_stop+0x96>
    
  }

  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    8000332e:	0b848493          	addi	s1,s1,184
    80003332:	03448163          	beq	s1,s4,80003354 <handle_stop+0xb4>
    if(t!=curr_t){
    80003336:	fe9a8ce3          	beq	s5,s1,8000332e <handle_stop+0x8e>
      acquire(&t->lock);
    8000333a:	8526                	mv	a0,s1
    8000333c:	ffffe097          	auipc	ra,0xffffe
    80003340:	88a080e7          	jalr	-1910(ra) # 80000bc6 <acquire>
      t->frozen=0;
    80003344:	0204aa23          	sw	zero,52(s1)
      release(&t->lock);
    80003348:	8526                	mv	a0,s1
    8000334a:	ffffe097          	auipc	ra,0xffffe
    8000334e:	952080e7          	jalr	-1710(ra) # 80000c9c <release>
    80003352:	bff1                	j	8000332e <handle_stop+0x8e>
    }
  }
  if(p->pending_signals&1<<SIGKILL)
    80003354:	0e89a783          	lw	a5,232(s3)
    80003358:	2007f793          	andi	a5,a5,512
    8000335c:	c781                	beqz	a5,80003364 <handle_stop+0xc4>
    p->killed=1;
    8000335e:	4785                	li	a5,1
    80003360:	00f9ae23          	sw	a5,28(s3)
}
    80003364:	70e2                	ld	ra,56(sp)
    80003366:	7442                	ld	s0,48(sp)
    80003368:	74a2                	ld	s1,40(sp)
    8000336a:	7902                	ld	s2,32(sp)
    8000336c:	69e2                	ld	s3,24(sp)
    8000336e:	6a42                	ld	s4,16(sp)
    80003370:	6aa2                	ld	s5,8(sp)
    80003372:	6b02                	ld	s6,0(sp)
    80003374:	6121                	addi	sp,sp,64
    80003376:	8082                	ret

0000000080003378 <check_pending_signals>:

void 
check_pending_signals(struct proc* p){
    80003378:	711d                	addi	sp,sp,-96
    8000337a:	ec86                	sd	ra,88(sp)
    8000337c:	e8a2                	sd	s0,80(sp)
    8000337e:	e4a6                	sd	s1,72(sp)
    80003380:	e0ca                	sd	s2,64(sp)
    80003382:	fc4e                	sd	s3,56(sp)
    80003384:	f852                	sd	s4,48(sp)
    80003386:	f456                	sd	s5,40(sp)
    80003388:	f05a                	sd	s6,32(sp)
    8000338a:	ec5e                	sd	s7,24(sp)
    8000338c:	e862                	sd	s8,16(sp)
    8000338e:	e466                	sd	s9,8(sp)
    80003390:	e06a                	sd	s10,0(sp)
    80003392:	1080                	addi	s0,sp,96
    80003394:	89aa                	mv	s3,a0
  // if(p->pid==4){
    
  //   if(p->pending_signals & (1<<SIGSTOP))
  //     printf("recieved stop sig\n");
  // }
  struct kthread *t= mykthread();
    80003396:	ffffe097          	auipc	ra,0xffffe
    8000339a:	726080e7          	jalr	1830(ra) # 80001abc <mykthread>
    8000339e:	8caa                	mv	s9,a0
  for(int sig_num=0;sig_num<32;sig_num++){
    800033a0:	0f898913          	addi	s2,s3,248
    800033a4:	4481                	li	s1,0
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    800033a6:	4a05                	li	s4,1
            p->killed = 1;
            release(&p->lock);
        }
      }

      else if(act.sa_handler==(void*)SIGKILL){
    800033a8:	4c25                	li	s8,9
        p->killed=1;
      }else if(act.sa_handler==(void*)SIGSTOP){
    800033aa:	4b45                	li	s6,17
        handle_stop(p);
      }      
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    800033ac:	4b85                	li	s7,1
        switch (sig_num)
    800033ae:	4d4d                	li	s10,19
  for(int sig_num=0;sig_num<32;sig_num++){
    800033b0:	02000a93          	li	s5,32
    800033b4:	a0a1                	j	800033fc <check_pending_signals+0x84>
        switch (sig_num)
    800033b6:	03648163          	beq	s1,s6,800033d8 <check_pending_signals+0x60>
    800033ba:	03a48763          	beq	s1,s10,800033e8 <check_pending_signals+0x70>
            acquire(&p->lock);
    800033be:	854e                	mv	a0,s3
    800033c0:	ffffe097          	auipc	ra,0xffffe
    800033c4:	806080e7          	jalr	-2042(ra) # 80000bc6 <acquire>
            p->killed = 1;
    800033c8:	0179ae23          	sw	s7,28(s3)
            release(&p->lock);
    800033cc:	854e                	mv	a0,s3
    800033ce:	ffffe097          	auipc	ra,0xffffe
    800033d2:	8ce080e7          	jalr	-1842(ra) # 80000c9c <release>
    800033d6:	a809                	j	800033e8 <check_pending_signals+0x70>
            handle_stop(p);
    800033d8:	854e                	mv	a0,s3
    800033da:	00000097          	auipc	ra,0x0
    800033de:	ec6080e7          	jalr	-314(ra) # 800032a0 <handle_stop>
            break;
    800033e2:	a019                	j	800033e8 <check_pending_signals+0x70>
        p->killed=1;
    800033e4:	0179ae23          	sw	s7,28(s3)
        turn_off_bit(p, sig_num);

        return;
      }

      turn_off_bit(p, sig_num);            
    800033e8:	85a6                	mv	a1,s1
    800033ea:	854e                	mv	a0,s3
    800033ec:	00000097          	auipc	ra,0x0
    800033f0:	9a0080e7          	jalr	-1632(ra) # 80002d8c <turn_off_bit>
  for(int sig_num=0;sig_num<32;sig_num++){
    800033f4:	2485                	addiw	s1,s1,1
    800033f6:	0921                	addi	s2,s2,8
    800033f8:	0d548963          	beq	s1,s5,800034ca <check_pending_signals+0x152>
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    800033fc:	009a173b          	sllw	a4,s4,s1
    80003400:	0e89a783          	lw	a5,232(s3)
    80003404:	8ff9                	and	a5,a5,a4
    80003406:	2781                	sext.w	a5,a5
    80003408:	d7f5                	beqz	a5,800033f4 <check_pending_signals+0x7c>
    8000340a:	0ec9a783          	lw	a5,236(s3)
    8000340e:	8f7d                	and	a4,a4,a5
    80003410:	2701                	sext.w	a4,a4
    80003412:	f36d                	bnez	a4,800033f4 <check_pending_signals+0x7c>
      act.sa_handler = p->signal_handlers[sig_num];
    80003414:	00093703          	ld	a4,0(s2)
      if(act.sa_handler == (void*)SIG_DFL){
    80003418:	df59                	beqz	a4,800033b6 <check_pending_signals+0x3e>
      else if(act.sa_handler==(void*)SIGKILL){
    8000341a:	fd8705e3          	beq	a4,s8,800033e4 <check_pending_signals+0x6c>
      }else if(act.sa_handler==(void*)SIGSTOP){
    8000341e:	0d670463          	beq	a4,s6,800034e6 <check_pending_signals+0x16e>
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    80003422:	fd7703e3          	beq	a4,s7,800033e8 <check_pending_signals+0x70>
    80003426:	2809a703          	lw	a4,640(s3)
    8000342a:	ff5d                	bnez	a4,800033e8 <check_pending_signals+0x70>
      act.sigmask = p->handlers_sigmasks[sig_num];
    8000342c:	07c48713          	addi	a4,s1,124
    80003430:	070a                	slli	a4,a4,0x2
    80003432:	974e                	add	a4,a4,s3
    80003434:	4718                	lw	a4,8(a4)
        p->handling_user_sig_flag = 1;
    80003436:	4685                	li	a3,1
    80003438:	28d9a023          	sw	a3,640(s3)
        p->signal_mask_backup = p->signal_mask;
    8000343c:	0ef9a823          	sw	a5,240(s3)
        p->signal_mask= p->handlers_sigmasks[sig_num];
    80003440:	0ee9a623          	sw	a4,236(s3)
        t->trapframe->sp -= sizeof(struct trapframe);
    80003444:	040cb703          	ld	a4,64(s9)
    80003448:	7b1c                	ld	a5,48(a4)
    8000344a:	ee078793          	addi	a5,a5,-288
    8000344e:	fb1c                	sd	a5,48(a4)
        p->user_trapframe_backup = (struct trapframe* )(t->trapframe->sp);
    80003450:	040cb783          	ld	a5,64(s9)
    80003454:	7b8c                	ld	a1,48(a5)
    80003456:	26b9bc23          	sd	a1,632(s3)
        copyout(p->pagetable, (uint64)p->user_trapframe_backup, (char *)t->trapframe, sizeof(struct trapframe));
    8000345a:	12000693          	li	a3,288
    8000345e:	040cb603          	ld	a2,64(s9)
    80003462:	0409b503          	ld	a0,64(s3)
    80003466:	ffffe097          	auipc	ra,0xffffe
    8000346a:	1fe080e7          	jalr	510(ra) # 80001664 <copyout>
        uint64 size = (uint64)&end_sigret - (uint64)&call_sigret;
    8000346e:	00004697          	auipc	a3,0x4
    80003472:	ef268693          	addi	a3,a3,-270 # 80007360 <end_sigret>
    80003476:	00004617          	auipc	a2,0x4
    8000347a:	ee260613          	addi	a2,a2,-286 # 80007358 <call_sigret>
        t->trapframe->sp -= size;
    8000347e:	040cb703          	ld	a4,64(s9)
    80003482:	40d605b3          	sub	a1,a2,a3
    80003486:	7b1c                	ld	a5,48(a4)
    80003488:	97ae                	add	a5,a5,a1
    8000348a:	fb1c                	sd	a5,48(a4)
        copyout(p->pagetable, (uint64)t->trapframe->sp, (char *)&call_sigret, size);
    8000348c:	040cb783          	ld	a5,64(s9)
    80003490:	8e91                	sub	a3,a3,a2
    80003492:	7b8c                	ld	a1,48(a5)
    80003494:	0409b503          	ld	a0,64(s3)
    80003498:	ffffe097          	auipc	ra,0xffffe
    8000349c:	1cc080e7          	jalr	460(ra) # 80001664 <copyout>
        t->trapframe->a0 = sig_num;
    800034a0:	040cb783          	ld	a5,64(s9)
    800034a4:	fba4                	sd	s1,112(a5)
        t->trapframe->ra = t->trapframe->sp;
    800034a6:	040cb783          	ld	a5,64(s9)
    800034aa:	7b98                	ld	a4,48(a5)
    800034ac:	f798                	sd	a4,40(a5)
        t->trapframe->epc = (uint64)p->signal_handlers[sig_num];
    800034ae:	040cb703          	ld	a4,64(s9)
    800034b2:	01e48793          	addi	a5,s1,30
    800034b6:	078e                	slli	a5,a5,0x3
    800034b8:	97ce                	add	a5,a5,s3
    800034ba:	679c                	ld	a5,8(a5)
    800034bc:	ef1c                	sd	a5,24(a4)
        turn_off_bit(p, sig_num);
    800034be:	85a6                	mv	a1,s1
    800034c0:	854e                	mv	a0,s3
    800034c2:	00000097          	auipc	ra,0x0
    800034c6:	8ca080e7          	jalr	-1846(ra) # 80002d8c <turn_off_bit>
    }
  }
}
    800034ca:	60e6                	ld	ra,88(sp)
    800034cc:	6446                	ld	s0,80(sp)
    800034ce:	64a6                	ld	s1,72(sp)
    800034d0:	6906                	ld	s2,64(sp)
    800034d2:	79e2                	ld	s3,56(sp)
    800034d4:	7a42                	ld	s4,48(sp)
    800034d6:	7aa2                	ld	s5,40(sp)
    800034d8:	7b02                	ld	s6,32(sp)
    800034da:	6be2                	ld	s7,24(sp)
    800034dc:	6c42                	ld	s8,16(sp)
    800034de:	6ca2                	ld	s9,8(sp)
    800034e0:	6d02                	ld	s10,0(sp)
    800034e2:	6125                	addi	sp,sp,96
    800034e4:	8082                	ret
        handle_stop(p);
    800034e6:	854e                	mv	a0,s3
    800034e8:	00000097          	auipc	ra,0x0
    800034ec:	db8080e7          	jalr	-584(ra) # 800032a0 <handle_stop>
    800034f0:	bde5                	j	800033e8 <check_pending_signals+0x70>

00000000800034f2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800034f2:	1101                	addi	sp,sp,-32
    800034f4:	ec06                	sd	ra,24(sp)
    800034f6:	e822                	sd	s0,16(sp)
    800034f8:	e426                	sd	s1,8(sp)
    800034fa:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800034fc:	ffffe097          	auipc	ra,0xffffe
    80003500:	580080e7          	jalr	1408(ra) # 80001a7c <myproc>
    80003504:	84aa                	mv	s1,a0
  struct kthread *t = mykthread();
    80003506:	ffffe097          	auipc	ra,0xffffe
    8000350a:	5b6080e7          	jalr	1462(ra) # 80001abc <mykthread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000350e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80003512:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003514:	10079073          	csrw	sstatus,a5

  intr_off();
  

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80003518:	00005617          	auipc	a2,0x5
    8000351c:	ae860613          	addi	a2,a2,-1304 # 80008000 <_trampoline>
    80003520:	00005697          	auipc	a3,0x5
    80003524:	ae068693          	addi	a3,a3,-1312 # 80008000 <_trampoline>
    80003528:	8e91                	sub	a3,a3,a2
    8000352a:	040007b7          	lui	a5,0x4000
    8000352e:	17fd                	addi	a5,a5,-1
    80003530:	07b2                	slli	a5,a5,0xc
    80003532:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003534:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  t->trapframe->kernel_satp = r_satp();         // kernel page table
    80003538:	6138                	ld	a4,64(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000353a:	180026f3          	csrr	a3,satp
    8000353e:	e314                	sd	a3,0(a4)
  t->trapframe->kernel_sp = t->kstack + PGSIZE; // process's kernel stack
    80003540:	6138                	ld	a4,64(a0)
    80003542:	7d14                	ld	a3,56(a0)
    80003544:	6585                	lui	a1,0x1
    80003546:	96ae                	add	a3,a3,a1
    80003548:	e714                	sd	a3,8(a4)
  t->trapframe->kernel_trap = (uint64)usertrap;
    8000354a:	6138                	ld	a4,64(a0)
    8000354c:	00000697          	auipc	a3,0x0
    80003550:	15868693          	addi	a3,a3,344 # 800036a4 <usertrap>
    80003554:	eb14                	sd	a3,16(a4)
  t->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80003556:	6138                	ld	a4,64(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80003558:	8692                	mv	a3,tp
    8000355a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000355c:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80003560:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80003564:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003568:	10069073          	csrw	sstatus,a3
  w_sstatus(x);
  

  // set S Exception Program Counter to the saved user pc.
  w_sepc(t->trapframe->epc);
    8000356c:	6138                	ld	a4,64(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000356e:	6f18                	ld	a4,24(a4)
    80003570:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80003574:	60ac                	ld	a1,64(s1)
    80003576:	81b1                	srli	a1,a1,0xc
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
 
 
  int thread_ind = (int)(t - p->kthreads);
    80003578:	28848493          	addi	s1,s1,648
    8000357c:	8d05                	sub	a0,a0,s1
    8000357e:	850d                	srai	a0,a0,0x3




  ((void (*)(uint64,uint64))fn)(TRAPFRAME + (uint64)(thread_ind * sizeof(struct trapframe)), satp);
    80003580:	00006717          	auipc	a4,0x6
    80003584:	a8873703          	ld	a4,-1400(a4) # 80009008 <etext+0x8>
    80003588:	02e5053b          	mulw	a0,a0,a4
    8000358c:	00351693          	slli	a3,a0,0x3
    80003590:	9536                	add	a0,a0,a3
    80003592:	0516                	slli	a0,a0,0x5
    80003594:	020006b7          	lui	a3,0x2000
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80003598:	00005717          	auipc	a4,0x5
    8000359c:	af870713          	addi	a4,a4,-1288 # 80008090 <userret>
    800035a0:	8f11                	sub	a4,a4,a2
    800035a2:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME + (uint64)(thread_ind * sizeof(struct trapframe)), satp);
    800035a4:	577d                	li	a4,-1
    800035a6:	177e                	slli	a4,a4,0x3f
    800035a8:	8dd9                	or	a1,a1,a4
    800035aa:	16fd                	addi	a3,a3,-1
    800035ac:	06b6                	slli	a3,a3,0xd
    800035ae:	9536                	add	a0,a0,a3
    800035b0:	9782                	jalr	a5

}
    800035b2:	60e2                	ld	ra,24(sp)
    800035b4:	6442                	ld	s0,16(sp)
    800035b6:	64a2                	ld	s1,8(sp)
    800035b8:	6105                	addi	sp,sp,32
    800035ba:	8082                	ret

00000000800035bc <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800035bc:	1101                	addi	sp,sp,-32
    800035be:	ec06                	sd	ra,24(sp)
    800035c0:	e822                	sd	s0,16(sp)
    800035c2:	e426                	sd	s1,8(sp)
    800035c4:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800035c6:	00030497          	auipc	s1,0x30
    800035ca:	36248493          	addi	s1,s1,866 # 80033928 <tickslock>
    800035ce:	8526                	mv	a0,s1
    800035d0:	ffffd097          	auipc	ra,0xffffd
    800035d4:	5f6080e7          	jalr	1526(ra) # 80000bc6 <acquire>
  ticks++;
    800035d8:	00007517          	auipc	a0,0x7
    800035dc:	a5850513          	addi	a0,a0,-1448 # 8000a030 <ticks>
    800035e0:	411c                	lw	a5,0(a0)
    800035e2:	2785                	addiw	a5,a5,1
    800035e4:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800035e6:	fffff097          	auipc	ra,0xfffff
    800035ea:	f96080e7          	jalr	-106(ra) # 8000257c <wakeup>
  release(&tickslock);
    800035ee:	8526                	mv	a0,s1
    800035f0:	ffffd097          	auipc	ra,0xffffd
    800035f4:	6ac080e7          	jalr	1708(ra) # 80000c9c <release>
}
    800035f8:	60e2                	ld	ra,24(sp)
    800035fa:	6442                	ld	s0,16(sp)
    800035fc:	64a2                	ld	s1,8(sp)
    800035fe:	6105                	addi	sp,sp,32
    80003600:	8082                	ret

0000000080003602 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80003602:	1101                	addi	sp,sp,-32
    80003604:	ec06                	sd	ra,24(sp)
    80003606:	e822                	sd	s0,16(sp)
    80003608:	e426                	sd	s1,8(sp)
    8000360a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000360c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80003610:	00074d63          	bltz	a4,8000362a <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80003614:	57fd                	li	a5,-1
    80003616:	17fe                	slli	a5,a5,0x3f
    80003618:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000361a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000361c:	06f70363          	beq	a4,a5,80003682 <devintr+0x80>
  }
}
    80003620:	60e2                	ld	ra,24(sp)
    80003622:	6442                	ld	s0,16(sp)
    80003624:	64a2                	ld	s1,8(sp)
    80003626:	6105                	addi	sp,sp,32
    80003628:	8082                	ret
     (scause & 0xff) == 9){
    8000362a:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    8000362e:	46a5                	li	a3,9
    80003630:	fed792e3          	bne	a5,a3,80003614 <devintr+0x12>
    int irq = plic_claim();
    80003634:	00003097          	auipc	ra,0x3
    80003638:	7a4080e7          	jalr	1956(ra) # 80006dd8 <plic_claim>
    8000363c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000363e:	47a9                	li	a5,10
    80003640:	02f50763          	beq	a0,a5,8000366e <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80003644:	4785                	li	a5,1
    80003646:	02f50963          	beq	a0,a5,80003678 <devintr+0x76>
    return 1;
    8000364a:	4505                	li	a0,1
    } else if(irq){
    8000364c:	d8f1                	beqz	s1,80003620 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000364e:	85a6                	mv	a1,s1
    80003650:	00006517          	auipc	a0,0x6
    80003654:	d8850513          	addi	a0,a0,-632 # 800093d8 <states.0+0x28>
    80003658:	ffffd097          	auipc	ra,0xffffd
    8000365c:	f20080e7          	jalr	-224(ra) # 80000578 <printf>
      plic_complete(irq);
    80003660:	8526                	mv	a0,s1
    80003662:	00003097          	auipc	ra,0x3
    80003666:	79a080e7          	jalr	1946(ra) # 80006dfc <plic_complete>
    return 1;
    8000366a:	4505                	li	a0,1
    8000366c:	bf55                	j	80003620 <devintr+0x1e>
      uartintr();
    8000366e:	ffffd097          	auipc	ra,0xffffd
    80003672:	31c080e7          	jalr	796(ra) # 8000098a <uartintr>
    80003676:	b7ed                	j	80003660 <devintr+0x5e>
      virtio_disk_intr();
    80003678:	00004097          	auipc	ra,0x4
    8000367c:	c16080e7          	jalr	-1002(ra) # 8000728e <virtio_disk_intr>
    80003680:	b7c5                	j	80003660 <devintr+0x5e>
    if(cpuid() == 0){
    80003682:	ffffe097          	auipc	ra,0xffffe
    80003686:	3c6080e7          	jalr	966(ra) # 80001a48 <cpuid>
    8000368a:	c901                	beqz	a0,8000369a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000368c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80003690:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80003692:	14479073          	csrw	sip,a5
    return 2;
    80003696:	4509                	li	a0,2
    80003698:	b761                	j	80003620 <devintr+0x1e>
      clockintr();
    8000369a:	00000097          	auipc	ra,0x0
    8000369e:	f22080e7          	jalr	-222(ra) # 800035bc <clockintr>
    800036a2:	b7ed                	j	8000368c <devintr+0x8a>

00000000800036a4 <usertrap>:
{
    800036a4:	1101                	addi	sp,sp,-32
    800036a6:	ec06                	sd	ra,24(sp)
    800036a8:	e822                	sd	s0,16(sp)
    800036aa:	e426                	sd	s1,8(sp)
    800036ac:	e04a                	sd	s2,0(sp)
    800036ae:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800036b0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800036b4:	1007f793          	andi	a5,a5,256
    800036b8:	e3dd                	bnez	a5,8000375e <usertrap+0xba>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800036ba:	00003797          	auipc	a5,0x3
    800036be:	61678793          	addi	a5,a5,1558 # 80006cd0 <kernelvec>
    800036c2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800036c6:	ffffe097          	auipc	ra,0xffffe
    800036ca:	3b6080e7          	jalr	950(ra) # 80001a7c <myproc>
    800036ce:	84aa                	mv	s1,a0
  struct kthread *t = mykthread();
    800036d0:	ffffe097          	auipc	ra,0xffffe
    800036d4:	3ec080e7          	jalr	1004(ra) # 80001abc <mykthread>
    800036d8:	892a                	mv	s2,a0
  t->trapframe->epc = r_sepc();
    800036da:	613c                	ld	a5,64(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800036dc:	14102773          	csrr	a4,sepc
    800036e0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800036e2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800036e6:	47a1                	li	a5,8
    800036e8:	08f71f63          	bne	a4,a5,80003786 <usertrap+0xe2>
    if(t->killed == 1)
    800036ec:	5518                	lw	a4,40(a0)
    800036ee:	4785                	li	a5,1
    800036f0:	06f70f63          	beq	a4,a5,8000376e <usertrap+0xca>
    else if(p->killed)
    800036f4:	4cdc                	lw	a5,28(s1)
    800036f6:	e3d1                	bnez	a5,8000377a <usertrap+0xd6>
    t->trapframe->epc += 4;
    800036f8:	04093703          	ld	a4,64(s2)
    800036fc:	6f1c                	ld	a5,24(a4)
    800036fe:	0791                	addi	a5,a5,4
    80003700:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003702:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003706:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000370a:	10079073          	csrw	sstatus,a5
    syscall();
    8000370e:	00000097          	auipc	ra,0x0
    80003712:	382080e7          	jalr	898(ra) # 80003a90 <syscall>
  if(holding(&p->lock))
    80003716:	8526                	mv	a0,s1
    80003718:	ffffd097          	auipc	ra,0xffffd
    8000371c:	434080e7          	jalr	1076(ra) # 80000b4c <holding>
    80003720:	e95d                	bnez	a0,800037d6 <usertrap+0x132>
  acquire(&p->lock);
    80003722:	8526                	mv	a0,s1
    80003724:	ffffd097          	auipc	ra,0xffffd
    80003728:	4a2080e7          	jalr	1186(ra) # 80000bc6 <acquire>
  if(!p->handling_sig_flag){
    8000372c:	2844a783          	lw	a5,644(s1)
    80003730:	cfc5                	beqz	a5,800037e8 <usertrap+0x144>
  release(&p->lock);
    80003732:	8526                	mv	a0,s1
    80003734:	ffffd097          	auipc	ra,0xffffd
    80003738:	568080e7          	jalr	1384(ra) # 80000c9c <release>
  if(t->killed == 1)
    8000373c:	02892703          	lw	a4,40(s2)
    80003740:	4785                	li	a5,1
    80003742:	0cf70863          	beq	a4,a5,80003812 <usertrap+0x16e>
  else if(p->killed)
    80003746:	4cdc                	lw	a5,28(s1)
    80003748:	ebf9                	bnez	a5,8000381e <usertrap+0x17a>
  usertrapret();
    8000374a:	00000097          	auipc	ra,0x0
    8000374e:	da8080e7          	jalr	-600(ra) # 800034f2 <usertrapret>
}
    80003752:	60e2                	ld	ra,24(sp)
    80003754:	6442                	ld	s0,16(sp)
    80003756:	64a2                	ld	s1,8(sp)
    80003758:	6902                	ld	s2,0(sp)
    8000375a:	6105                	addi	sp,sp,32
    8000375c:	8082                	ret
    panic("usertrap: not from user mode");
    8000375e:	00006517          	auipc	a0,0x6
    80003762:	c9a50513          	addi	a0,a0,-870 # 800093f8 <states.0+0x48>
    80003766:	ffffd097          	auipc	ra,0xffffd
    8000376a:	dc8080e7          	jalr	-568(ra) # 8000052e <panic>
      kthread_exit(-1); // Kill current thread
    8000376e:	557d                	li	a0,-1
    80003770:	fffff097          	auipc	ra,0xfffff
    80003774:	03c080e7          	jalr	60(ra) # 800027ac <kthread_exit>
    80003778:	b741                	j	800036f8 <usertrap+0x54>
      exit(-1); // Kill the hole procces
    8000377a:	557d                	li	a0,-1
    8000377c:	fffff097          	auipc	ra,0xfffff
    80003780:	0ce080e7          	jalr	206(ra) # 8000284a <exit>
    80003784:	bf95                	j	800036f8 <usertrap+0x54>
  else if((which_dev = devintr()) != 0)
    80003786:	00000097          	auipc	ra,0x0
    8000378a:	e7c080e7          	jalr	-388(ra) # 80003602 <devintr>
    8000378e:	c909                	beqz	a0,800037a0 <usertrap+0xfc>
  if(which_dev == 2)
    80003790:	4789                	li	a5,2
    80003792:	f8f512e3          	bne	a0,a5,80003716 <usertrap+0x72>
    yield();
    80003796:	fffff097          	auipc	ra,0xfffff
    8000379a:	c20080e7          	jalr	-992(ra) # 800023b6 <yield>
    8000379e:	bfa5                	j	80003716 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800037a0:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800037a4:	50d0                	lw	a2,36(s1)
    800037a6:	00006517          	auipc	a0,0x6
    800037aa:	c7250513          	addi	a0,a0,-910 # 80009418 <states.0+0x68>
    800037ae:	ffffd097          	auipc	ra,0xffffd
    800037b2:	dca080e7          	jalr	-566(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800037b6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800037ba:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800037be:	00006517          	auipc	a0,0x6
    800037c2:	c8a50513          	addi	a0,a0,-886 # 80009448 <states.0+0x98>
    800037c6:	ffffd097          	auipc	ra,0xffffd
    800037ca:	db2080e7          	jalr	-590(ra) # 80000578 <printf>
    t->killed = 1;
    800037ce:	4785                	li	a5,1
    800037d0:	02f92423          	sw	a5,40(s2)
  if(which_dev == 2)
    800037d4:	b789                	j	80003716 <usertrap+0x72>
    printf("fuck i am holding the lock in usertrap\n");   // TODO : delete
    800037d6:	00006517          	auipc	a0,0x6
    800037da:	c9250513          	addi	a0,a0,-878 # 80009468 <states.0+0xb8>
    800037de:	ffffd097          	auipc	ra,0xffffd
    800037e2:	d9a080e7          	jalr	-614(ra) # 80000578 <printf>
    800037e6:	bf35                	j	80003722 <usertrap+0x7e>
    p->handling_sig_flag = 1;
    800037e8:	4785                	li	a5,1
    800037ea:	28f4a223          	sw	a5,644(s1)
    release(&p->lock);
    800037ee:	8526                	mv	a0,s1
    800037f0:	ffffd097          	auipc	ra,0xffffd
    800037f4:	4ac080e7          	jalr	1196(ra) # 80000c9c <release>
    check_pending_signals(p);
    800037f8:	8526                	mv	a0,s1
    800037fa:	00000097          	auipc	ra,0x0
    800037fe:	b7e080e7          	jalr	-1154(ra) # 80003378 <check_pending_signals>
    acquire(&p->lock);
    80003802:	8526                	mv	a0,s1
    80003804:	ffffd097          	auipc	ra,0xffffd
    80003808:	3c2080e7          	jalr	962(ra) # 80000bc6 <acquire>
    p->handling_sig_flag = 0;
    8000380c:	2804a223          	sw	zero,644(s1)
    80003810:	b70d                	j	80003732 <usertrap+0x8e>
    kthread_exit(-1); // Kill current thread
    80003812:	557d                	li	a0,-1
    80003814:	fffff097          	auipc	ra,0xfffff
    80003818:	f98080e7          	jalr	-104(ra) # 800027ac <kthread_exit>
    8000381c:	b73d                	j	8000374a <usertrap+0xa6>
    exit(-1); // Kill the hole procces
    8000381e:	557d                	li	a0,-1
    80003820:	fffff097          	auipc	ra,0xfffff
    80003824:	02a080e7          	jalr	42(ra) # 8000284a <exit>
    80003828:	b70d                	j	8000374a <usertrap+0xa6>

000000008000382a <kerneltrap>:
{
    8000382a:	7179                	addi	sp,sp,-48
    8000382c:	f406                	sd	ra,40(sp)
    8000382e:	f022                	sd	s0,32(sp)
    80003830:	ec26                	sd	s1,24(sp)
    80003832:	e84a                	sd	s2,16(sp)
    80003834:	e44e                	sd	s3,8(sp)
    80003836:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003838:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000383c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003840:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003844:	1004f793          	andi	a5,s1,256
    80003848:	cb85                	beqz	a5,80003878 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000384a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000384e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80003850:	ef85                	bnez	a5,80003888 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80003852:	00000097          	auipc	ra,0x0
    80003856:	db0080e7          	jalr	-592(ra) # 80003602 <devintr>
    8000385a:	cd1d                	beqz	a0,80003898 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    8000385c:	4789                	li	a5,2
    8000385e:	08f50763          	beq	a0,a5,800038ec <kerneltrap+0xc2>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003862:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003866:	10049073          	csrw	sstatus,s1
}
    8000386a:	70a2                	ld	ra,40(sp)
    8000386c:	7402                	ld	s0,32(sp)
    8000386e:	64e2                	ld	s1,24(sp)
    80003870:	6942                	ld	s2,16(sp)
    80003872:	69a2                	ld	s3,8(sp)
    80003874:	6145                	addi	sp,sp,48
    80003876:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003878:	00006517          	auipc	a0,0x6
    8000387c:	c1850513          	addi	a0,a0,-1000 # 80009490 <states.0+0xe0>
    80003880:	ffffd097          	auipc	ra,0xffffd
    80003884:	cae080e7          	jalr	-850(ra) # 8000052e <panic>
    panic("kerneltrap: interrupts enabled");
    80003888:	00006517          	auipc	a0,0x6
    8000388c:	c3050513          	addi	a0,a0,-976 # 800094b8 <states.0+0x108>
    80003890:	ffffd097          	auipc	ra,0xffffd
    80003894:	c9e080e7          	jalr	-866(ra) # 8000052e <panic>
    printf("proc %d recieved kernel trap\n",myproc()->pid);
    80003898:	ffffe097          	auipc	ra,0xffffe
    8000389c:	1e4080e7          	jalr	484(ra) # 80001a7c <myproc>
    800038a0:	514c                	lw	a1,36(a0)
    800038a2:	00006517          	auipc	a0,0x6
    800038a6:	c3650513          	addi	a0,a0,-970 # 800094d8 <states.0+0x128>
    800038aa:	ffffd097          	auipc	ra,0xffffd
    800038ae:	cce080e7          	jalr	-818(ra) # 80000578 <printf>
    printf("scause %p\n", scause);
    800038b2:	85ce                	mv	a1,s3
    800038b4:	00006517          	auipc	a0,0x6
    800038b8:	c4450513          	addi	a0,a0,-956 # 800094f8 <states.0+0x148>
    800038bc:	ffffd097          	auipc	ra,0xffffd
    800038c0:	cbc080e7          	jalr	-836(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800038c4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800038c8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800038cc:	00006517          	auipc	a0,0x6
    800038d0:	c3c50513          	addi	a0,a0,-964 # 80009508 <states.0+0x158>
    800038d4:	ffffd097          	auipc	ra,0xffffd
    800038d8:	ca4080e7          	jalr	-860(ra) # 80000578 <printf>
    panic("kerneltrap");
    800038dc:	00006517          	auipc	a0,0x6
    800038e0:	c4450513          	addi	a0,a0,-956 # 80009520 <states.0+0x170>
    800038e4:	ffffd097          	auipc	ra,0xffffd
    800038e8:	c4a080e7          	jalr	-950(ra) # 8000052e <panic>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    800038ec:	ffffe097          	auipc	ra,0xffffe
    800038f0:	190080e7          	jalr	400(ra) # 80001a7c <myproc>
    800038f4:	d53d                	beqz	a0,80003862 <kerneltrap+0x38>
    800038f6:	ffffe097          	auipc	ra,0xffffe
    800038fa:	1c6080e7          	jalr	454(ra) # 80001abc <mykthread>
    800038fe:	d135                	beqz	a0,80003862 <kerneltrap+0x38>
    80003900:	ffffe097          	auipc	ra,0xffffe
    80003904:	1bc080e7          	jalr	444(ra) # 80001abc <mykthread>
    80003908:	4d18                	lw	a4,24(a0)
    8000390a:	4791                	li	a5,4
    8000390c:	f4f71be3          	bne	a4,a5,80003862 <kerneltrap+0x38>
    yield();
    80003910:	fffff097          	auipc	ra,0xfffff
    80003914:	aa6080e7          	jalr	-1370(ra) # 800023b6 <yield>
    80003918:	b7a9                	j	80003862 <kerneltrap+0x38>

000000008000391a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000391a:	1101                	addi	sp,sp,-32
    8000391c:	ec06                	sd	ra,24(sp)
    8000391e:	e822                	sd	s0,16(sp)
    80003920:	e426                	sd	s1,8(sp)
    80003922:	1000                	addi	s0,sp,32
    80003924:	84aa                	mv	s1,a0

  struct kthread *t = mykthread();
    80003926:	ffffe097          	auipc	ra,0xffffe
    8000392a:	196080e7          	jalr	406(ra) # 80001abc <mykthread>
  switch (n) {
    8000392e:	4795                	li	a5,5
    80003930:	0497e163          	bltu	a5,s1,80003972 <argraw+0x58>
    80003934:	048a                	slli	s1,s1,0x2
    80003936:	00006717          	auipc	a4,0x6
    8000393a:	c2270713          	addi	a4,a4,-990 # 80009558 <states.0+0x1a8>
    8000393e:	94ba                	add	s1,s1,a4
    80003940:	409c                	lw	a5,0(s1)
    80003942:	97ba                	add	a5,a5,a4
    80003944:	8782                	jr	a5
  case 0:
    return t->trapframe->a0;
    80003946:	613c                	ld	a5,64(a0)
    80003948:	7ba8                	ld	a0,112(a5)
  case 5:
    return t->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000394a:	60e2                	ld	ra,24(sp)
    8000394c:	6442                	ld	s0,16(sp)
    8000394e:	64a2                	ld	s1,8(sp)
    80003950:	6105                	addi	sp,sp,32
    80003952:	8082                	ret
    return t->trapframe->a1;
    80003954:	613c                	ld	a5,64(a0)
    80003956:	7fa8                	ld	a0,120(a5)
    80003958:	bfcd                	j	8000394a <argraw+0x30>
    return t->trapframe->a2;
    8000395a:	613c                	ld	a5,64(a0)
    8000395c:	63c8                	ld	a0,128(a5)
    8000395e:	b7f5                	j	8000394a <argraw+0x30>
    return t->trapframe->a3;
    80003960:	613c                	ld	a5,64(a0)
    80003962:	67c8                	ld	a0,136(a5)
    80003964:	b7dd                	j	8000394a <argraw+0x30>
    return t->trapframe->a4;
    80003966:	613c                	ld	a5,64(a0)
    80003968:	6bc8                	ld	a0,144(a5)
    8000396a:	b7c5                	j	8000394a <argraw+0x30>
    return t->trapframe->a5;
    8000396c:	613c                	ld	a5,64(a0)
    8000396e:	6fc8                	ld	a0,152(a5)
    80003970:	bfe9                	j	8000394a <argraw+0x30>
  panic("argraw");
    80003972:	00006517          	auipc	a0,0x6
    80003976:	bbe50513          	addi	a0,a0,-1090 # 80009530 <states.0+0x180>
    8000397a:	ffffd097          	auipc	ra,0xffffd
    8000397e:	bb4080e7          	jalr	-1100(ra) # 8000052e <panic>

0000000080003982 <fetchaddr>:
{
    80003982:	1101                	addi	sp,sp,-32
    80003984:	ec06                	sd	ra,24(sp)
    80003986:	e822                	sd	s0,16(sp)
    80003988:	e426                	sd	s1,8(sp)
    8000398a:	e04a                	sd	s2,0(sp)
    8000398c:	1000                	addi	s0,sp,32
    8000398e:	84aa                	mv	s1,a0
    80003990:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80003992:	ffffe097          	auipc	ra,0xffffe
    80003996:	0ea080e7          	jalr	234(ra) # 80001a7c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    8000399a:	7d1c                	ld	a5,56(a0)
    8000399c:	02f4f863          	bgeu	s1,a5,800039cc <fetchaddr+0x4a>
    800039a0:	00848713          	addi	a4,s1,8
    800039a4:	02e7e663          	bltu	a5,a4,800039d0 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800039a8:	46a1                	li	a3,8
    800039aa:	8626                	mv	a2,s1
    800039ac:	85ca                	mv	a1,s2
    800039ae:	6128                	ld	a0,64(a0)
    800039b0:	ffffe097          	auipc	ra,0xffffe
    800039b4:	d40080e7          	jalr	-704(ra) # 800016f0 <copyin>
    800039b8:	00a03533          	snez	a0,a0
    800039bc:	40a00533          	neg	a0,a0
}
    800039c0:	60e2                	ld	ra,24(sp)
    800039c2:	6442                	ld	s0,16(sp)
    800039c4:	64a2                	ld	s1,8(sp)
    800039c6:	6902                	ld	s2,0(sp)
    800039c8:	6105                	addi	sp,sp,32
    800039ca:	8082                	ret
    return -1;
    800039cc:	557d                	li	a0,-1
    800039ce:	bfcd                	j	800039c0 <fetchaddr+0x3e>
    800039d0:	557d                	li	a0,-1
    800039d2:	b7fd                	j	800039c0 <fetchaddr+0x3e>

00000000800039d4 <fetchstr>:
{
    800039d4:	7179                	addi	sp,sp,-48
    800039d6:	f406                	sd	ra,40(sp)
    800039d8:	f022                	sd	s0,32(sp)
    800039da:	ec26                	sd	s1,24(sp)
    800039dc:	e84a                	sd	s2,16(sp)
    800039de:	e44e                	sd	s3,8(sp)
    800039e0:	1800                	addi	s0,sp,48
    800039e2:	892a                	mv	s2,a0
    800039e4:	84ae                	mv	s1,a1
    800039e6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800039e8:	ffffe097          	auipc	ra,0xffffe
    800039ec:	094080e7          	jalr	148(ra) # 80001a7c <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    800039f0:	86ce                	mv	a3,s3
    800039f2:	864a                	mv	a2,s2
    800039f4:	85a6                	mv	a1,s1
    800039f6:	6128                	ld	a0,64(a0)
    800039f8:	ffffe097          	auipc	ra,0xffffe
    800039fc:	d86080e7          	jalr	-634(ra) # 8000177e <copyinstr>
  if(err < 0)
    80003a00:	00054763          	bltz	a0,80003a0e <fetchstr+0x3a>
  return strlen(buf);
    80003a04:	8526                	mv	a0,s1
    80003a06:	ffffd097          	auipc	ra,0xffffd
    80003a0a:	462080e7          	jalr	1122(ra) # 80000e68 <strlen>
}
    80003a0e:	70a2                	ld	ra,40(sp)
    80003a10:	7402                	ld	s0,32(sp)
    80003a12:	64e2                	ld	s1,24(sp)
    80003a14:	6942                	ld	s2,16(sp)
    80003a16:	69a2                	ld	s3,8(sp)
    80003a18:	6145                	addi	sp,sp,48
    80003a1a:	8082                	ret

0000000080003a1c <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80003a1c:	1101                	addi	sp,sp,-32
    80003a1e:	ec06                	sd	ra,24(sp)
    80003a20:	e822                	sd	s0,16(sp)
    80003a22:	e426                	sd	s1,8(sp)
    80003a24:	1000                	addi	s0,sp,32
    80003a26:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003a28:	00000097          	auipc	ra,0x0
    80003a2c:	ef2080e7          	jalr	-270(ra) # 8000391a <argraw>
    80003a30:	c088                	sw	a0,0(s1)
  return 0;
}
    80003a32:	4501                	li	a0,0
    80003a34:	60e2                	ld	ra,24(sp)
    80003a36:	6442                	ld	s0,16(sp)
    80003a38:	64a2                	ld	s1,8(sp)
    80003a3a:	6105                	addi	sp,sp,32
    80003a3c:	8082                	ret

0000000080003a3e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80003a3e:	1101                	addi	sp,sp,-32
    80003a40:	ec06                	sd	ra,24(sp)
    80003a42:	e822                	sd	s0,16(sp)
    80003a44:	e426                	sd	s1,8(sp)
    80003a46:	1000                	addi	s0,sp,32
    80003a48:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003a4a:	00000097          	auipc	ra,0x0
    80003a4e:	ed0080e7          	jalr	-304(ra) # 8000391a <argraw>
    80003a52:	e088                	sd	a0,0(s1)
  return 0;
}
    80003a54:	4501                	li	a0,0
    80003a56:	60e2                	ld	ra,24(sp)
    80003a58:	6442                	ld	s0,16(sp)
    80003a5a:	64a2                	ld	s1,8(sp)
    80003a5c:	6105                	addi	sp,sp,32
    80003a5e:	8082                	ret

0000000080003a60 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80003a60:	1101                	addi	sp,sp,-32
    80003a62:	ec06                	sd	ra,24(sp)
    80003a64:	e822                	sd	s0,16(sp)
    80003a66:	e426                	sd	s1,8(sp)
    80003a68:	e04a                	sd	s2,0(sp)
    80003a6a:	1000                	addi	s0,sp,32
    80003a6c:	84ae                	mv	s1,a1
    80003a6e:	8932                	mv	s2,a2
  *ip = argraw(n);
    80003a70:	00000097          	auipc	ra,0x0
    80003a74:	eaa080e7          	jalr	-342(ra) # 8000391a <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003a78:	864a                	mv	a2,s2
    80003a7a:	85a6                	mv	a1,s1
    80003a7c:	00000097          	auipc	ra,0x0
    80003a80:	f58080e7          	jalr	-168(ra) # 800039d4 <fetchstr>
}
    80003a84:	60e2                	ld	ra,24(sp)
    80003a86:	6442                	ld	s0,16(sp)
    80003a88:	64a2                	ld	s1,8(sp)
    80003a8a:	6902                	ld	s2,0(sp)
    80003a8c:	6105                	addi	sp,sp,32
    80003a8e:	8082                	ret

0000000080003a90 <syscall>:
[SYS_kthread_join] sys_kthread_join,
};

void
syscall(void)
{
    80003a90:	7179                	addi	sp,sp,-48
    80003a92:	f406                	sd	ra,40(sp)
    80003a94:	f022                	sd	s0,32(sp)
    80003a96:	ec26                	sd	s1,24(sp)
    80003a98:	e84a                	sd	s2,16(sp)
    80003a9a:	e44e                	sd	s3,8(sp)
    80003a9c:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80003a9e:	ffffe097          	auipc	ra,0xffffe
    80003aa2:	fde080e7          	jalr	-34(ra) # 80001a7c <myproc>
    80003aa6:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80003aa8:	ffffe097          	auipc	ra,0xffffe
    80003aac:	014080e7          	jalr	20(ra) # 80001abc <mykthread>
    80003ab0:	84aa                	mv	s1,a0

  num = t->trapframe->a7;
    80003ab2:	04053983          	ld	s3,64(a0)
    80003ab6:	0a89b783          	ld	a5,168(s3)
    80003aba:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80003abe:	37fd                	addiw	a5,a5,-1
    80003ac0:	476d                	li	a4,27
    80003ac2:	00f76f63          	bltu	a4,a5,80003ae0 <syscall+0x50>
    80003ac6:	00369713          	slli	a4,a3,0x3
    80003aca:	00006797          	auipc	a5,0x6
    80003ace:	aa678793          	addi	a5,a5,-1370 # 80009570 <syscalls>
    80003ad2:	97ba                	add	a5,a5,a4
    80003ad4:	639c                	ld	a5,0(a5)
    80003ad6:	c789                	beqz	a5,80003ae0 <syscall+0x50>
    t->trapframe->a0 = syscalls[num]();
    80003ad8:	9782                	jalr	a5
    80003ada:	06a9b823          	sd	a0,112(s3)
    80003ade:	a005                	j	80003afe <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80003ae0:	0d890613          	addi	a2,s2,216
    80003ae4:	02492583          	lw	a1,36(s2)
    80003ae8:	00006517          	auipc	a0,0x6
    80003aec:	a5050513          	addi	a0,a0,-1456 # 80009538 <states.0+0x188>
    80003af0:	ffffd097          	auipc	ra,0xffffd
    80003af4:	a88080e7          	jalr	-1400(ra) # 80000578 <printf>
            p->pid, p->name, num);
    t->trapframe->a0 = -1;
    80003af8:	60bc                	ld	a5,64(s1)
    80003afa:	577d                	li	a4,-1
    80003afc:	fbb8                	sd	a4,112(a5)
  }
}
    80003afe:	70a2                	ld	ra,40(sp)
    80003b00:	7402                	ld	s0,32(sp)
    80003b02:	64e2                	ld	s1,24(sp)
    80003b04:	6942                	ld	s2,16(sp)
    80003b06:	69a2                	ld	s3,8(sp)
    80003b08:	6145                	addi	sp,sp,48
    80003b0a:	8082                	ret

0000000080003b0c <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003b0c:	1101                	addi	sp,sp,-32
    80003b0e:	ec06                	sd	ra,24(sp)
    80003b10:	e822                	sd	s0,16(sp)
    80003b12:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003b14:	fec40593          	addi	a1,s0,-20
    80003b18:	4501                	li	a0,0
    80003b1a:	00000097          	auipc	ra,0x0
    80003b1e:	f02080e7          	jalr	-254(ra) # 80003a1c <argint>
    return -1;
    80003b22:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003b24:	00054963          	bltz	a0,80003b36 <sys_exit+0x2a>
  exit(n);
    80003b28:	fec42503          	lw	a0,-20(s0)
    80003b2c:	fffff097          	auipc	ra,0xfffff
    80003b30:	d1e080e7          	jalr	-738(ra) # 8000284a <exit>
  return 0;  // not reached
    80003b34:	4781                	li	a5,0
}
    80003b36:	853e                	mv	a0,a5
    80003b38:	60e2                	ld	ra,24(sp)
    80003b3a:	6442                	ld	s0,16(sp)
    80003b3c:	6105                	addi	sp,sp,32
    80003b3e:	8082                	ret

0000000080003b40 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003b40:	1141                	addi	sp,sp,-16
    80003b42:	e406                	sd	ra,8(sp)
    80003b44:	e022                	sd	s0,0(sp)
    80003b46:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003b48:	ffffe097          	auipc	ra,0xffffe
    80003b4c:	f34080e7          	jalr	-204(ra) # 80001a7c <myproc>
}
    80003b50:	5148                	lw	a0,36(a0)
    80003b52:	60a2                	ld	ra,8(sp)
    80003b54:	6402                	ld	s0,0(sp)
    80003b56:	0141                	addi	sp,sp,16
    80003b58:	8082                	ret

0000000080003b5a <sys_fork>:

uint64
sys_fork(void)
{
    80003b5a:	1141                	addi	sp,sp,-16
    80003b5c:	e406                	sd	ra,8(sp)
    80003b5e:	e022                	sd	s0,0(sp)
    80003b60:	0800                	addi	s0,sp,16
  return fork();
    80003b62:	ffffe097          	auipc	ra,0xffffe
    80003b66:	4a4080e7          	jalr	1188(ra) # 80002006 <fork>
}
    80003b6a:	60a2                	ld	ra,8(sp)
    80003b6c:	6402                	ld	s0,0(sp)
    80003b6e:	0141                	addi	sp,sp,16
    80003b70:	8082                	ret

0000000080003b72 <sys_wait>:

uint64
sys_wait(void)
{
    80003b72:	1101                	addi	sp,sp,-32
    80003b74:	ec06                	sd	ra,24(sp)
    80003b76:	e822                	sd	s0,16(sp)
    80003b78:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003b7a:	fe840593          	addi	a1,s0,-24
    80003b7e:	4501                	li	a0,0
    80003b80:	00000097          	auipc	ra,0x0
    80003b84:	ebe080e7          	jalr	-322(ra) # 80003a3e <argaddr>
    80003b88:	87aa                	mv	a5,a0
    return -1;
    80003b8a:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003b8c:	0007c863          	bltz	a5,80003b9c <sys_wait+0x2a>
  return wait(p);
    80003b90:	fe843503          	ld	a0,-24(s0)
    80003b94:	fffff097          	auipc	ra,0xfffff
    80003b98:	8c2080e7          	jalr	-1854(ra) # 80002456 <wait>
}
    80003b9c:	60e2                	ld	ra,24(sp)
    80003b9e:	6442                	ld	s0,16(sp)
    80003ba0:	6105                	addi	sp,sp,32
    80003ba2:	8082                	ret

0000000080003ba4 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003ba4:	7179                	addi	sp,sp,-48
    80003ba6:	f406                	sd	ra,40(sp)
    80003ba8:	f022                	sd	s0,32(sp)
    80003baa:	ec26                	sd	s1,24(sp)
    80003bac:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003bae:	fdc40593          	addi	a1,s0,-36
    80003bb2:	4501                	li	a0,0
    80003bb4:	00000097          	auipc	ra,0x0
    80003bb8:	e68080e7          	jalr	-408(ra) # 80003a1c <argint>
    return -1;
    80003bbc:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003bbe:	00054f63          	bltz	a0,80003bdc <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003bc2:	ffffe097          	auipc	ra,0xffffe
    80003bc6:	eba080e7          	jalr	-326(ra) # 80001a7c <myproc>
    80003bca:	5d04                	lw	s1,56(a0)
  if(growproc(n) < 0)
    80003bcc:	fdc42503          	lw	a0,-36(s0)
    80003bd0:	ffffe097          	auipc	ra,0xffffe
    80003bd4:	3c2080e7          	jalr	962(ra) # 80001f92 <growproc>
    80003bd8:	00054863          	bltz	a0,80003be8 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003bdc:	8526                	mv	a0,s1
    80003bde:	70a2                	ld	ra,40(sp)
    80003be0:	7402                	ld	s0,32(sp)
    80003be2:	64e2                	ld	s1,24(sp)
    80003be4:	6145                	addi	sp,sp,48
    80003be6:	8082                	ret
    return -1;
    80003be8:	54fd                	li	s1,-1
    80003bea:	bfcd                	j	80003bdc <sys_sbrk+0x38>

0000000080003bec <sys_sleep>:

uint64
sys_sleep(void)
{
    80003bec:	7139                	addi	sp,sp,-64
    80003bee:	fc06                	sd	ra,56(sp)
    80003bf0:	f822                	sd	s0,48(sp)
    80003bf2:	f426                	sd	s1,40(sp)
    80003bf4:	f04a                	sd	s2,32(sp)
    80003bf6:	ec4e                	sd	s3,24(sp)
    80003bf8:	e852                	sd	s4,16(sp)
    80003bfa:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003bfc:	fcc40593          	addi	a1,s0,-52
    80003c00:	4501                	li	a0,0
    80003c02:	00000097          	auipc	ra,0x0
    80003c06:	e1a080e7          	jalr	-486(ra) # 80003a1c <argint>
    return -1;
    80003c0a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003c0c:	06054763          	bltz	a0,80003c7a <sys_sleep+0x8e>
  acquire(&tickslock);
    80003c10:	00030517          	auipc	a0,0x30
    80003c14:	d1850513          	addi	a0,a0,-744 # 80033928 <tickslock>
    80003c18:	ffffd097          	auipc	ra,0xffffd
    80003c1c:	fae080e7          	jalr	-82(ra) # 80000bc6 <acquire>
  ticks0 = ticks;
    80003c20:	00006997          	auipc	s3,0x6
    80003c24:	4109a983          	lw	s3,1040(s3) # 8000a030 <ticks>
  while(ticks - ticks0 < n){
    80003c28:	fcc42783          	lw	a5,-52(s0)
    80003c2c:	cf95                	beqz	a5,80003c68 <sys_sleep+0x7c>
    if(myproc()->killed==1){
    80003c2e:	4905                	li	s2,1
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003c30:	00030a17          	auipc	s4,0x30
    80003c34:	cf8a0a13          	addi	s4,s4,-776 # 80033928 <tickslock>
    80003c38:	00006497          	auipc	s1,0x6
    80003c3c:	3f848493          	addi	s1,s1,1016 # 8000a030 <ticks>
    if(myproc()->killed==1){
    80003c40:	ffffe097          	auipc	ra,0xffffe
    80003c44:	e3c080e7          	jalr	-452(ra) # 80001a7c <myproc>
    80003c48:	4d5c                	lw	a5,28(a0)
    80003c4a:	05278163          	beq	a5,s2,80003c8c <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    80003c4e:	85d2                	mv	a1,s4
    80003c50:	8526                	mv	a0,s1
    80003c52:	ffffe097          	auipc	ra,0xffffe
    80003c56:	7a0080e7          	jalr	1952(ra) # 800023f2 <sleep>
  while(ticks - ticks0 < n){
    80003c5a:	409c                	lw	a5,0(s1)
    80003c5c:	413787bb          	subw	a5,a5,s3
    80003c60:	fcc42703          	lw	a4,-52(s0)
    80003c64:	fce7eee3          	bltu	a5,a4,80003c40 <sys_sleep+0x54>
  }
  release(&tickslock);
    80003c68:	00030517          	auipc	a0,0x30
    80003c6c:	cc050513          	addi	a0,a0,-832 # 80033928 <tickslock>
    80003c70:	ffffd097          	auipc	ra,0xffffd
    80003c74:	02c080e7          	jalr	44(ra) # 80000c9c <release>
  return 0;
    80003c78:	4781                	li	a5,0
}
    80003c7a:	853e                	mv	a0,a5
    80003c7c:	70e2                	ld	ra,56(sp)
    80003c7e:	7442                	ld	s0,48(sp)
    80003c80:	74a2                	ld	s1,40(sp)
    80003c82:	7902                	ld	s2,32(sp)
    80003c84:	69e2                	ld	s3,24(sp)
    80003c86:	6a42                	ld	s4,16(sp)
    80003c88:	6121                	addi	sp,sp,64
    80003c8a:	8082                	ret
      release(&tickslock);
    80003c8c:	00030517          	auipc	a0,0x30
    80003c90:	c9c50513          	addi	a0,a0,-868 # 80033928 <tickslock>
    80003c94:	ffffd097          	auipc	ra,0xffffd
    80003c98:	008080e7          	jalr	8(ra) # 80000c9c <release>
      return -1;
    80003c9c:	57fd                	li	a5,-1
    80003c9e:	bff1                	j	80003c7a <sys_sleep+0x8e>

0000000080003ca0 <sys_kill>:

uint64
sys_kill(void)
{
    80003ca0:	1101                	addi	sp,sp,-32
    80003ca2:	ec06                	sd	ra,24(sp)
    80003ca4:	e822                	sd	s0,16(sp)
    80003ca6:	1000                	addi	s0,sp,32
  int pid;
  int signum;

  if(argint(0, &pid) < 0)
    80003ca8:	fec40593          	addi	a1,s0,-20
    80003cac:	4501                	li	a0,0
    80003cae:	00000097          	auipc	ra,0x0
    80003cb2:	d6e080e7          	jalr	-658(ra) # 80003a1c <argint>
    80003cb6:	87aa                	mv	a5,a0
    return -1;
    80003cb8:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003cba:	0207c963          	bltz	a5,80003cec <sys_kill+0x4c>
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003cbe:	fe840593          	addi	a1,s0,-24
    80003cc2:	4505                	li	a0,1
    80003cc4:	00000097          	auipc	ra,0x0
    80003cc8:	d58080e7          	jalr	-680(ra) # 80003a1c <argint>
    80003ccc:	02054463          	bltz	a0,80003cf4 <sys_kill+0x54>
    80003cd0:	fe842583          	lw	a1,-24(s0)
    80003cd4:	0005871b          	sext.w	a4,a1
    80003cd8:	47fd                	li	a5,31
    return -1;
    80003cda:	557d                	li	a0,-1
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003cdc:	00e7e863          	bltu	a5,a4,80003cec <sys_kill+0x4c>
  return kill(pid, signum);
    80003ce0:	fec42503          	lw	a0,-20(s0)
    80003ce4:	fffff097          	auipc	ra,0xfffff
    80003ce8:	f9e080e7          	jalr	-98(ra) # 80002c82 <kill>
}
    80003cec:	60e2                	ld	ra,24(sp)
    80003cee:	6442                	ld	s0,16(sp)
    80003cf0:	6105                	addi	sp,sp,32
    80003cf2:	8082                	ret
    return -1;
    80003cf4:	557d                	li	a0,-1
    80003cf6:	bfdd                	j	80003cec <sys_kill+0x4c>

0000000080003cf8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003cf8:	1101                	addi	sp,sp,-32
    80003cfa:	ec06                	sd	ra,24(sp)
    80003cfc:	e822                	sd	s0,16(sp)
    80003cfe:	e426                	sd	s1,8(sp)
    80003d00:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003d02:	00030517          	auipc	a0,0x30
    80003d06:	c2650513          	addi	a0,a0,-986 # 80033928 <tickslock>
    80003d0a:	ffffd097          	auipc	ra,0xffffd
    80003d0e:	ebc080e7          	jalr	-324(ra) # 80000bc6 <acquire>
  xticks = ticks;
    80003d12:	00006497          	auipc	s1,0x6
    80003d16:	31e4a483          	lw	s1,798(s1) # 8000a030 <ticks>
  release(&tickslock);
    80003d1a:	00030517          	auipc	a0,0x30
    80003d1e:	c0e50513          	addi	a0,a0,-1010 # 80033928 <tickslock>
    80003d22:	ffffd097          	auipc	ra,0xffffd
    80003d26:	f7a080e7          	jalr	-134(ra) # 80000c9c <release>
  return xticks;
}
    80003d2a:	02049513          	slli	a0,s1,0x20
    80003d2e:	9101                	srli	a0,a0,0x20
    80003d30:	60e2                	ld	ra,24(sp)
    80003d32:	6442                	ld	s0,16(sp)
    80003d34:	64a2                	ld	s1,8(sp)
    80003d36:	6105                	addi	sp,sp,32
    80003d38:	8082                	ret

0000000080003d3a <sys_sigprocmask>:

uint64
sys_sigprocmask(void)
{
    80003d3a:	1101                	addi	sp,sp,-32
    80003d3c:	ec06                	sd	ra,24(sp)
    80003d3e:	e822                	sd	s0,16(sp)
    80003d40:	1000                	addi	s0,sp,32
  int sigmask;

  if(argint(0, &sigmask) < 0)
    80003d42:	fec40593          	addi	a1,s0,-20
    80003d46:	4501                	li	a0,0
    80003d48:	00000097          	auipc	ra,0x0
    80003d4c:	cd4080e7          	jalr	-812(ra) # 80003a1c <argint>
    80003d50:	87aa                	mv	a5,a0
    return -1;
    80003d52:	557d                	li	a0,-1
  if(argint(0, &sigmask) < 0)
    80003d54:	0007ca63          	bltz	a5,80003d68 <sys_sigprocmask+0x2e>
  return sigprocmask((uint)sigmask);
    80003d58:	fec42503          	lw	a0,-20(s0)
    80003d5c:	fffff097          	auipc	ra,0xfffff
    80003d60:	d54080e7          	jalr	-684(ra) # 80002ab0 <sigprocmask>
    80003d64:	1502                	slli	a0,a0,0x20
    80003d66:	9101                	srli	a0,a0,0x20
}
    80003d68:	60e2                	ld	ra,24(sp)
    80003d6a:	6442                	ld	s0,16(sp)
    80003d6c:	6105                	addi	sp,sp,32
    80003d6e:	8082                	ret

0000000080003d70 <sys_sigaction>:

uint64
sys_sigaction(void)
{
    80003d70:	7179                	addi	sp,sp,-48
    80003d72:	f406                	sd	ra,40(sp)
    80003d74:	f022                	sd	s0,32(sp)
    80003d76:	1800                	addi	s0,sp,48
  int signum;
  uint64 newact;
  uint64 oldact;
  
  if(argint(0, &signum) < 0)
    80003d78:	fec40593          	addi	a1,s0,-20
    80003d7c:	4501                	li	a0,0
    80003d7e:	00000097          	auipc	ra,0x0
    80003d82:	c9e080e7          	jalr	-866(ra) # 80003a1c <argint>
    return -1;
    80003d86:	57fd                	li	a5,-1
  if(argint(0, &signum) < 0)
    80003d88:	04054163          	bltz	a0,80003dca <sys_sigaction+0x5a>
  if(argaddr(1, &newact) < 0)
    80003d8c:	fe040593          	addi	a1,s0,-32
    80003d90:	4505                	li	a0,1
    80003d92:	00000097          	auipc	ra,0x0
    80003d96:	cac080e7          	jalr	-852(ra) # 80003a3e <argaddr>
    return -1;
    80003d9a:	57fd                	li	a5,-1
  if(argaddr(1, &newact) < 0)
    80003d9c:	02054763          	bltz	a0,80003dca <sys_sigaction+0x5a>
  if(argaddr(2, &oldact) < 0)
    80003da0:	fd840593          	addi	a1,s0,-40
    80003da4:	4509                	li	a0,2
    80003da6:	00000097          	auipc	ra,0x0
    80003daa:	c98080e7          	jalr	-872(ra) # 80003a3e <argaddr>
    return -1;
    80003dae:	57fd                	li	a5,-1
  if(argaddr(2, &oldact) < 0)
    80003db0:	00054d63          	bltz	a0,80003dca <sys_sigaction+0x5a>

  return sigaction(signum,(struct sigaction*)newact, (struct sigaction*)oldact);
    80003db4:	fd843603          	ld	a2,-40(s0)
    80003db8:	fe043583          	ld	a1,-32(s0)
    80003dbc:	fec42503          	lw	a0,-20(s0)
    80003dc0:	fffff097          	auipc	ra,0xfffff
    80003dc4:	d44080e7          	jalr	-700(ra) # 80002b04 <sigaction>
    80003dc8:	87aa                	mv	a5,a0
  
}
    80003dca:	853e                	mv	a0,a5
    80003dcc:	70a2                	ld	ra,40(sp)
    80003dce:	7402                	ld	s0,32(sp)
    80003dd0:	6145                	addi	sp,sp,48
    80003dd2:	8082                	ret

0000000080003dd4 <sys_sigret>:
uint64
sys_sigret(void)
{
    80003dd4:	1141                	addi	sp,sp,-16
    80003dd6:	e406                	sd	ra,8(sp)
    80003dd8:	e022                	sd	s0,0(sp)
    80003dda:	0800                	addi	s0,sp,16
  sigret();
    80003ddc:	fffff097          	auipc	ra,0xfffff
    80003de0:	e12080e7          	jalr	-494(ra) # 80002bee <sigret>
  return 0;
}
    80003de4:	4501                	li	a0,0
    80003de6:	60a2                	ld	ra,8(sp)
    80003de8:	6402                	ld	s0,0(sp)
    80003dea:	0141                	addi	sp,sp,16
    80003dec:	8082                	ret

0000000080003dee <sys_kthread_create>:

uint64
sys_kthread_create(void)
{
    80003dee:	1101                	addi	sp,sp,-32
    80003df0:	ec06                	sd	ra,24(sp)
    80003df2:	e822                	sd	s0,16(sp)
    80003df4:	1000                	addi	s0,sp,32
  uint64 start_func;
  uint64 stack;
  if(argaddr(0, &start_func) < 0)
    80003df6:	fe840593          	addi	a1,s0,-24
    80003dfa:	4501                	li	a0,0
    80003dfc:	00000097          	auipc	ra,0x0
    80003e00:	c42080e7          	jalr	-958(ra) # 80003a3e <argaddr>
    return -1;
    80003e04:	57fd                	li	a5,-1
  if(argaddr(0, &start_func) < 0)
    80003e06:	02054563          	bltz	a0,80003e30 <sys_kthread_create+0x42>
  if(argaddr(1, &stack) < 0) 
    80003e0a:	fe040593          	addi	a1,s0,-32
    80003e0e:	4505                	li	a0,1
    80003e10:	00000097          	auipc	ra,0x0
    80003e14:	c2e080e7          	jalr	-978(ra) # 80003a3e <argaddr>
    return -1;
    80003e18:	57fd                	li	a5,-1
  if(argaddr(1, &stack) < 0) 
    80003e1a:	00054b63          	bltz	a0,80003e30 <sys_kthread_create+0x42>
  return kthread_create((void*)start_func, (void *)stack);
    80003e1e:	fe043583          	ld	a1,-32(s0)
    80003e22:	fe843503          	ld	a0,-24(s0)
    80003e26:	fffff097          	auipc	ra,0xfffff
    80003e2a:	f8a080e7          	jalr	-118(ra) # 80002db0 <kthread_create>
    80003e2e:	87aa                	mv	a5,a0
}
    80003e30:	853e                	mv	a0,a5
    80003e32:	60e2                	ld	ra,24(sp)
    80003e34:	6442                	ld	s0,16(sp)
    80003e36:	6105                	addi	sp,sp,32
    80003e38:	8082                	ret

0000000080003e3a <sys_kthread_id>:

uint64
sys_kthread_id(void){
    80003e3a:	1141                	addi	sp,sp,-16
    80003e3c:	e406                	sd	ra,8(sp)
    80003e3e:	e022                	sd	s0,0(sp)
    80003e40:	0800                	addi	s0,sp,16
  return mykthread()->tid;
    80003e42:	ffffe097          	auipc	ra,0xffffe
    80003e46:	c7a080e7          	jalr	-902(ra) # 80001abc <mykthread>
}
    80003e4a:	5908                	lw	a0,48(a0)
    80003e4c:	60a2                	ld	ra,8(sp)
    80003e4e:	6402                	ld	s0,0(sp)
    80003e50:	0141                	addi	sp,sp,16
    80003e52:	8082                	ret

0000000080003e54 <sys_kthread_exit>:

uint64
sys_kthread_exit(void){
    80003e54:	1101                	addi	sp,sp,-32
    80003e56:	ec06                	sd	ra,24(sp)
    80003e58:	e822                	sd	s0,16(sp)
    80003e5a:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003e5c:	fec40593          	addi	a1,s0,-20
    80003e60:	4501                	li	a0,0
    80003e62:	00000097          	auipc	ra,0x0
    80003e66:	bba080e7          	jalr	-1094(ra) # 80003a1c <argint>
    return -1;
    80003e6a:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003e6c:	00054963          	bltz	a0,80003e7e <sys_kthread_exit+0x2a>
  kthread_exit(n);
    80003e70:	fec42503          	lw	a0,-20(s0)
    80003e74:	fffff097          	auipc	ra,0xfffff
    80003e78:	938080e7          	jalr	-1736(ra) # 800027ac <kthread_exit>
  
  return 0;  // not reached
    80003e7c:	4781                	li	a5,0
}
    80003e7e:	853e                	mv	a0,a5
    80003e80:	60e2                	ld	ra,24(sp)
    80003e82:	6442                	ld	s0,16(sp)
    80003e84:	6105                	addi	sp,sp,32
    80003e86:	8082                	ret

0000000080003e88 <sys_kthread_join>:

uint64 
sys_kthread_join(){
    80003e88:	1101                	addi	sp,sp,-32
    80003e8a:	ec06                	sd	ra,24(sp)
    80003e8c:	e822                	sd	s0,16(sp)
    80003e8e:	1000                	addi	s0,sp,32
  int thread_id;
  uint64 status;
  if(argint(0, &thread_id) < 0)
    80003e90:	fec40593          	addi	a1,s0,-20
    80003e94:	4501                	li	a0,0
    80003e96:	00000097          	auipc	ra,0x0
    80003e9a:	b86080e7          	jalr	-1146(ra) # 80003a1c <argint>
    return -1;
    80003e9e:	57fd                	li	a5,-1
  if(argint(0, &thread_id) < 0)
    80003ea0:	02054563          	bltz	a0,80003eca <sys_kthread_join+0x42>
  if(argaddr(1, &status) < 0)
    80003ea4:	fe040593          	addi	a1,s0,-32
    80003ea8:	4505                	li	a0,1
    80003eaa:	00000097          	auipc	ra,0x0
    80003eae:	b94080e7          	jalr	-1132(ra) # 80003a3e <argaddr>
    return -1;
    80003eb2:	57fd                	li	a5,-1
  if(argaddr(1, &status) < 0)
    80003eb4:	00054b63          	bltz	a0,80003eca <sys_kthread_join+0x42>
  
  return kthread_join(thread_id, (int *)status);
    80003eb8:	fe043583          	ld	a1,-32(s0)
    80003ebc:	fec42503          	lw	a0,-20(s0)
    80003ec0:	fffff097          	auipc	ra,0xfffff
    80003ec4:	ff4080e7          	jalr	-12(ra) # 80002eb4 <kthread_join>
    80003ec8:	87aa                	mv	a5,a0
    80003eca:	853e                	mv	a0,a5
    80003ecc:	60e2                	ld	ra,24(sp)
    80003ece:	6442                	ld	s0,16(sp)
    80003ed0:	6105                	addi	sp,sp,32
    80003ed2:	8082                	ret

0000000080003ed4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003ed4:	7179                	addi	sp,sp,-48
    80003ed6:	f406                	sd	ra,40(sp)
    80003ed8:	f022                	sd	s0,32(sp)
    80003eda:	ec26                	sd	s1,24(sp)
    80003edc:	e84a                	sd	s2,16(sp)
    80003ede:	e44e                	sd	s3,8(sp)
    80003ee0:	e052                	sd	s4,0(sp)
    80003ee2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003ee4:	00005597          	auipc	a1,0x5
    80003ee8:	77458593          	addi	a1,a1,1908 # 80009658 <syscalls+0xe8>
    80003eec:	00030517          	auipc	a0,0x30
    80003ef0:	a5450513          	addi	a0,a0,-1452 # 80033940 <bcache>
    80003ef4:	ffffd097          	auipc	ra,0xffffd
    80003ef8:	c42080e7          	jalr	-958(ra) # 80000b36 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003efc:	00038797          	auipc	a5,0x38
    80003f00:	a4478793          	addi	a5,a5,-1468 # 8003b940 <bcache+0x8000>
    80003f04:	00038717          	auipc	a4,0x38
    80003f08:	ca470713          	addi	a4,a4,-860 # 8003bba8 <bcache+0x8268>
    80003f0c:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003f10:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003f14:	00030497          	auipc	s1,0x30
    80003f18:	a4448493          	addi	s1,s1,-1468 # 80033958 <bcache+0x18>
    b->next = bcache.head.next;
    80003f1c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003f1e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003f20:	00005a17          	auipc	s4,0x5
    80003f24:	740a0a13          	addi	s4,s4,1856 # 80009660 <syscalls+0xf0>
    b->next = bcache.head.next;
    80003f28:	2b893783          	ld	a5,696(s2)
    80003f2c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003f2e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003f32:	85d2                	mv	a1,s4
    80003f34:	01048513          	addi	a0,s1,16
    80003f38:	00001097          	auipc	ra,0x1
    80003f3c:	4c0080e7          	jalr	1216(ra) # 800053f8 <initsleeplock>
    bcache.head.next->prev = b;
    80003f40:	2b893783          	ld	a5,696(s2)
    80003f44:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003f46:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003f4a:	45848493          	addi	s1,s1,1112
    80003f4e:	fd349de3          	bne	s1,s3,80003f28 <binit+0x54>
  }
}
    80003f52:	70a2                	ld	ra,40(sp)
    80003f54:	7402                	ld	s0,32(sp)
    80003f56:	64e2                	ld	s1,24(sp)
    80003f58:	6942                	ld	s2,16(sp)
    80003f5a:	69a2                	ld	s3,8(sp)
    80003f5c:	6a02                	ld	s4,0(sp)
    80003f5e:	6145                	addi	sp,sp,48
    80003f60:	8082                	ret

0000000080003f62 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003f62:	7179                	addi	sp,sp,-48
    80003f64:	f406                	sd	ra,40(sp)
    80003f66:	f022                	sd	s0,32(sp)
    80003f68:	ec26                	sd	s1,24(sp)
    80003f6a:	e84a                	sd	s2,16(sp)
    80003f6c:	e44e                	sd	s3,8(sp)
    80003f6e:	1800                	addi	s0,sp,48
    80003f70:	892a                	mv	s2,a0
    80003f72:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003f74:	00030517          	auipc	a0,0x30
    80003f78:	9cc50513          	addi	a0,a0,-1588 # 80033940 <bcache>
    80003f7c:	ffffd097          	auipc	ra,0xffffd
    80003f80:	c4a080e7          	jalr	-950(ra) # 80000bc6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003f84:	00038497          	auipc	s1,0x38
    80003f88:	c744b483          	ld	s1,-908(s1) # 8003bbf8 <bcache+0x82b8>
    80003f8c:	00038797          	auipc	a5,0x38
    80003f90:	c1c78793          	addi	a5,a5,-996 # 8003bba8 <bcache+0x8268>
    80003f94:	02f48f63          	beq	s1,a5,80003fd2 <bread+0x70>
    80003f98:	873e                	mv	a4,a5
    80003f9a:	a021                	j	80003fa2 <bread+0x40>
    80003f9c:	68a4                	ld	s1,80(s1)
    80003f9e:	02e48a63          	beq	s1,a4,80003fd2 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003fa2:	449c                	lw	a5,8(s1)
    80003fa4:	ff279ce3          	bne	a5,s2,80003f9c <bread+0x3a>
    80003fa8:	44dc                	lw	a5,12(s1)
    80003faa:	ff3799e3          	bne	a5,s3,80003f9c <bread+0x3a>
      b->refcnt++;
    80003fae:	40bc                	lw	a5,64(s1)
    80003fb0:	2785                	addiw	a5,a5,1
    80003fb2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003fb4:	00030517          	auipc	a0,0x30
    80003fb8:	98c50513          	addi	a0,a0,-1652 # 80033940 <bcache>
    80003fbc:	ffffd097          	auipc	ra,0xffffd
    80003fc0:	ce0080e7          	jalr	-800(ra) # 80000c9c <release>
      acquiresleep(&b->lock);
    80003fc4:	01048513          	addi	a0,s1,16
    80003fc8:	00001097          	auipc	ra,0x1
    80003fcc:	46a080e7          	jalr	1130(ra) # 80005432 <acquiresleep>
      return b;
    80003fd0:	a8b9                	j	8000402e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003fd2:	00038497          	auipc	s1,0x38
    80003fd6:	c1e4b483          	ld	s1,-994(s1) # 8003bbf0 <bcache+0x82b0>
    80003fda:	00038797          	auipc	a5,0x38
    80003fde:	bce78793          	addi	a5,a5,-1074 # 8003bba8 <bcache+0x8268>
    80003fe2:	00f48863          	beq	s1,a5,80003ff2 <bread+0x90>
    80003fe6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003fe8:	40bc                	lw	a5,64(s1)
    80003fea:	cf81                	beqz	a5,80004002 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003fec:	64a4                	ld	s1,72(s1)
    80003fee:	fee49de3          	bne	s1,a4,80003fe8 <bread+0x86>
  panic("bget: no buffers");
    80003ff2:	00005517          	auipc	a0,0x5
    80003ff6:	67650513          	addi	a0,a0,1654 # 80009668 <syscalls+0xf8>
    80003ffa:	ffffc097          	auipc	ra,0xffffc
    80003ffe:	534080e7          	jalr	1332(ra) # 8000052e <panic>
      b->dev = dev;
    80004002:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80004006:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000400a:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000400e:	4785                	li	a5,1
    80004010:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80004012:	00030517          	auipc	a0,0x30
    80004016:	92e50513          	addi	a0,a0,-1746 # 80033940 <bcache>
    8000401a:	ffffd097          	auipc	ra,0xffffd
    8000401e:	c82080e7          	jalr	-894(ra) # 80000c9c <release>
      acquiresleep(&b->lock);
    80004022:	01048513          	addi	a0,s1,16
    80004026:	00001097          	auipc	ra,0x1
    8000402a:	40c080e7          	jalr	1036(ra) # 80005432 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000402e:	409c                	lw	a5,0(s1)
    80004030:	cb89                	beqz	a5,80004042 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80004032:	8526                	mv	a0,s1
    80004034:	70a2                	ld	ra,40(sp)
    80004036:	7402                	ld	s0,32(sp)
    80004038:	64e2                	ld	s1,24(sp)
    8000403a:	6942                	ld	s2,16(sp)
    8000403c:	69a2                	ld	s3,8(sp)
    8000403e:	6145                	addi	sp,sp,48
    80004040:	8082                	ret
    virtio_disk_rw(b, 0);
    80004042:	4581                	li	a1,0
    80004044:	8526                	mv	a0,s1
    80004046:	00003097          	auipc	ra,0x3
    8000404a:	fc0080e7          	jalr	-64(ra) # 80007006 <virtio_disk_rw>
    b->valid = 1;
    8000404e:	4785                	li	a5,1
    80004050:	c09c                	sw	a5,0(s1)
  return b;
    80004052:	b7c5                	j	80004032 <bread+0xd0>

0000000080004054 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80004054:	1101                	addi	sp,sp,-32
    80004056:	ec06                	sd	ra,24(sp)
    80004058:	e822                	sd	s0,16(sp)
    8000405a:	e426                	sd	s1,8(sp)
    8000405c:	1000                	addi	s0,sp,32
    8000405e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80004060:	0541                	addi	a0,a0,16
    80004062:	00001097          	auipc	ra,0x1
    80004066:	46a080e7          	jalr	1130(ra) # 800054cc <holdingsleep>
    8000406a:	cd01                	beqz	a0,80004082 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000406c:	4585                	li	a1,1
    8000406e:	8526                	mv	a0,s1
    80004070:	00003097          	auipc	ra,0x3
    80004074:	f96080e7          	jalr	-106(ra) # 80007006 <virtio_disk_rw>
}
    80004078:	60e2                	ld	ra,24(sp)
    8000407a:	6442                	ld	s0,16(sp)
    8000407c:	64a2                	ld	s1,8(sp)
    8000407e:	6105                	addi	sp,sp,32
    80004080:	8082                	ret
    panic("bwrite");
    80004082:	00005517          	auipc	a0,0x5
    80004086:	5fe50513          	addi	a0,a0,1534 # 80009680 <syscalls+0x110>
    8000408a:	ffffc097          	auipc	ra,0xffffc
    8000408e:	4a4080e7          	jalr	1188(ra) # 8000052e <panic>

0000000080004092 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80004092:	1101                	addi	sp,sp,-32
    80004094:	ec06                	sd	ra,24(sp)
    80004096:	e822                	sd	s0,16(sp)
    80004098:	e426                	sd	s1,8(sp)
    8000409a:	e04a                	sd	s2,0(sp)
    8000409c:	1000                	addi	s0,sp,32
    8000409e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800040a0:	01050913          	addi	s2,a0,16
    800040a4:	854a                	mv	a0,s2
    800040a6:	00001097          	auipc	ra,0x1
    800040aa:	426080e7          	jalr	1062(ra) # 800054cc <holdingsleep>
    800040ae:	c92d                	beqz	a0,80004120 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800040b0:	854a                	mv	a0,s2
    800040b2:	00001097          	auipc	ra,0x1
    800040b6:	3d6080e7          	jalr	982(ra) # 80005488 <releasesleep>

  acquire(&bcache.lock);
    800040ba:	00030517          	auipc	a0,0x30
    800040be:	88650513          	addi	a0,a0,-1914 # 80033940 <bcache>
    800040c2:	ffffd097          	auipc	ra,0xffffd
    800040c6:	b04080e7          	jalr	-1276(ra) # 80000bc6 <acquire>
  b->refcnt--;
    800040ca:	40bc                	lw	a5,64(s1)
    800040cc:	37fd                	addiw	a5,a5,-1
    800040ce:	0007871b          	sext.w	a4,a5
    800040d2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800040d4:	eb05                	bnez	a4,80004104 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800040d6:	68bc                	ld	a5,80(s1)
    800040d8:	64b8                	ld	a4,72(s1)
    800040da:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800040dc:	64bc                	ld	a5,72(s1)
    800040de:	68b8                	ld	a4,80(s1)
    800040e0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800040e2:	00038797          	auipc	a5,0x38
    800040e6:	85e78793          	addi	a5,a5,-1954 # 8003b940 <bcache+0x8000>
    800040ea:	2b87b703          	ld	a4,696(a5)
    800040ee:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800040f0:	00038717          	auipc	a4,0x38
    800040f4:	ab870713          	addi	a4,a4,-1352 # 8003bba8 <bcache+0x8268>
    800040f8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800040fa:	2b87b703          	ld	a4,696(a5)
    800040fe:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80004100:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80004104:	00030517          	auipc	a0,0x30
    80004108:	83c50513          	addi	a0,a0,-1988 # 80033940 <bcache>
    8000410c:	ffffd097          	auipc	ra,0xffffd
    80004110:	b90080e7          	jalr	-1136(ra) # 80000c9c <release>
}
    80004114:	60e2                	ld	ra,24(sp)
    80004116:	6442                	ld	s0,16(sp)
    80004118:	64a2                	ld	s1,8(sp)
    8000411a:	6902                	ld	s2,0(sp)
    8000411c:	6105                	addi	sp,sp,32
    8000411e:	8082                	ret
    panic("brelse");
    80004120:	00005517          	auipc	a0,0x5
    80004124:	56850513          	addi	a0,a0,1384 # 80009688 <syscalls+0x118>
    80004128:	ffffc097          	auipc	ra,0xffffc
    8000412c:	406080e7          	jalr	1030(ra) # 8000052e <panic>

0000000080004130 <bpin>:

void
bpin(struct buf *b) {
    80004130:	1101                	addi	sp,sp,-32
    80004132:	ec06                	sd	ra,24(sp)
    80004134:	e822                	sd	s0,16(sp)
    80004136:	e426                	sd	s1,8(sp)
    80004138:	1000                	addi	s0,sp,32
    8000413a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000413c:	00030517          	auipc	a0,0x30
    80004140:	80450513          	addi	a0,a0,-2044 # 80033940 <bcache>
    80004144:	ffffd097          	auipc	ra,0xffffd
    80004148:	a82080e7          	jalr	-1406(ra) # 80000bc6 <acquire>
  b->refcnt++;
    8000414c:	40bc                	lw	a5,64(s1)
    8000414e:	2785                	addiw	a5,a5,1
    80004150:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004152:	0002f517          	auipc	a0,0x2f
    80004156:	7ee50513          	addi	a0,a0,2030 # 80033940 <bcache>
    8000415a:	ffffd097          	auipc	ra,0xffffd
    8000415e:	b42080e7          	jalr	-1214(ra) # 80000c9c <release>
}
    80004162:	60e2                	ld	ra,24(sp)
    80004164:	6442                	ld	s0,16(sp)
    80004166:	64a2                	ld	s1,8(sp)
    80004168:	6105                	addi	sp,sp,32
    8000416a:	8082                	ret

000000008000416c <bunpin>:

void
bunpin(struct buf *b) {
    8000416c:	1101                	addi	sp,sp,-32
    8000416e:	ec06                	sd	ra,24(sp)
    80004170:	e822                	sd	s0,16(sp)
    80004172:	e426                	sd	s1,8(sp)
    80004174:	1000                	addi	s0,sp,32
    80004176:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004178:	0002f517          	auipc	a0,0x2f
    8000417c:	7c850513          	addi	a0,a0,1992 # 80033940 <bcache>
    80004180:	ffffd097          	auipc	ra,0xffffd
    80004184:	a46080e7          	jalr	-1466(ra) # 80000bc6 <acquire>
  b->refcnt--;
    80004188:	40bc                	lw	a5,64(s1)
    8000418a:	37fd                	addiw	a5,a5,-1
    8000418c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000418e:	0002f517          	auipc	a0,0x2f
    80004192:	7b250513          	addi	a0,a0,1970 # 80033940 <bcache>
    80004196:	ffffd097          	auipc	ra,0xffffd
    8000419a:	b06080e7          	jalr	-1274(ra) # 80000c9c <release>
}
    8000419e:	60e2                	ld	ra,24(sp)
    800041a0:	6442                	ld	s0,16(sp)
    800041a2:	64a2                	ld	s1,8(sp)
    800041a4:	6105                	addi	sp,sp,32
    800041a6:	8082                	ret

00000000800041a8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800041a8:	1101                	addi	sp,sp,-32
    800041aa:	ec06                	sd	ra,24(sp)
    800041ac:	e822                	sd	s0,16(sp)
    800041ae:	e426                	sd	s1,8(sp)
    800041b0:	e04a                	sd	s2,0(sp)
    800041b2:	1000                	addi	s0,sp,32
    800041b4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800041b6:	00d5d59b          	srliw	a1,a1,0xd
    800041ba:	00038797          	auipc	a5,0x38
    800041be:	e627a783          	lw	a5,-414(a5) # 8003c01c <sb+0x1c>
    800041c2:	9dbd                	addw	a1,a1,a5
    800041c4:	00000097          	auipc	ra,0x0
    800041c8:	d9e080e7          	jalr	-610(ra) # 80003f62 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800041cc:	0074f713          	andi	a4,s1,7
    800041d0:	4785                	li	a5,1
    800041d2:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800041d6:	14ce                	slli	s1,s1,0x33
    800041d8:	90d9                	srli	s1,s1,0x36
    800041da:	00950733          	add	a4,a0,s1
    800041de:	05874703          	lbu	a4,88(a4)
    800041e2:	00e7f6b3          	and	a3,a5,a4
    800041e6:	c69d                	beqz	a3,80004214 <bfree+0x6c>
    800041e8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800041ea:	94aa                	add	s1,s1,a0
    800041ec:	fff7c793          	not	a5,a5
    800041f0:	8ff9                	and	a5,a5,a4
    800041f2:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800041f6:	00001097          	auipc	ra,0x1
    800041fa:	11c080e7          	jalr	284(ra) # 80005312 <log_write>
  brelse(bp);
    800041fe:	854a                	mv	a0,s2
    80004200:	00000097          	auipc	ra,0x0
    80004204:	e92080e7          	jalr	-366(ra) # 80004092 <brelse>
}
    80004208:	60e2                	ld	ra,24(sp)
    8000420a:	6442                	ld	s0,16(sp)
    8000420c:	64a2                	ld	s1,8(sp)
    8000420e:	6902                	ld	s2,0(sp)
    80004210:	6105                	addi	sp,sp,32
    80004212:	8082                	ret
    panic("freeing free block");
    80004214:	00005517          	auipc	a0,0x5
    80004218:	47c50513          	addi	a0,a0,1148 # 80009690 <syscalls+0x120>
    8000421c:	ffffc097          	auipc	ra,0xffffc
    80004220:	312080e7          	jalr	786(ra) # 8000052e <panic>

0000000080004224 <balloc>:
{
    80004224:	711d                	addi	sp,sp,-96
    80004226:	ec86                	sd	ra,88(sp)
    80004228:	e8a2                	sd	s0,80(sp)
    8000422a:	e4a6                	sd	s1,72(sp)
    8000422c:	e0ca                	sd	s2,64(sp)
    8000422e:	fc4e                	sd	s3,56(sp)
    80004230:	f852                	sd	s4,48(sp)
    80004232:	f456                	sd	s5,40(sp)
    80004234:	f05a                	sd	s6,32(sp)
    80004236:	ec5e                	sd	s7,24(sp)
    80004238:	e862                	sd	s8,16(sp)
    8000423a:	e466                	sd	s9,8(sp)
    8000423c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000423e:	00038797          	auipc	a5,0x38
    80004242:	dc67a783          	lw	a5,-570(a5) # 8003c004 <sb+0x4>
    80004246:	cbd1                	beqz	a5,800042da <balloc+0xb6>
    80004248:	8baa                	mv	s7,a0
    8000424a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000424c:	00038b17          	auipc	s6,0x38
    80004250:	db4b0b13          	addi	s6,s6,-588 # 8003c000 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004254:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80004256:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004258:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000425a:	6c89                	lui	s9,0x2
    8000425c:	a831                	j	80004278 <balloc+0x54>
    brelse(bp);
    8000425e:	854a                	mv	a0,s2
    80004260:	00000097          	auipc	ra,0x0
    80004264:	e32080e7          	jalr	-462(ra) # 80004092 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80004268:	015c87bb          	addw	a5,s9,s5
    8000426c:	00078a9b          	sext.w	s5,a5
    80004270:	004b2703          	lw	a4,4(s6)
    80004274:	06eaf363          	bgeu	s5,a4,800042da <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80004278:	41fad79b          	sraiw	a5,s5,0x1f
    8000427c:	0137d79b          	srliw	a5,a5,0x13
    80004280:	015787bb          	addw	a5,a5,s5
    80004284:	40d7d79b          	sraiw	a5,a5,0xd
    80004288:	01cb2583          	lw	a1,28(s6)
    8000428c:	9dbd                	addw	a1,a1,a5
    8000428e:	855e                	mv	a0,s7
    80004290:	00000097          	auipc	ra,0x0
    80004294:	cd2080e7          	jalr	-814(ra) # 80003f62 <bread>
    80004298:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000429a:	004b2503          	lw	a0,4(s6)
    8000429e:	000a849b          	sext.w	s1,s5
    800042a2:	8662                	mv	a2,s8
    800042a4:	faa4fde3          	bgeu	s1,a0,8000425e <balloc+0x3a>
      m = 1 << (bi % 8);
    800042a8:	41f6579b          	sraiw	a5,a2,0x1f
    800042ac:	01d7d69b          	srliw	a3,a5,0x1d
    800042b0:	00c6873b          	addw	a4,a3,a2
    800042b4:	00777793          	andi	a5,a4,7
    800042b8:	9f95                	subw	a5,a5,a3
    800042ba:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800042be:	4037571b          	sraiw	a4,a4,0x3
    800042c2:	00e906b3          	add	a3,s2,a4
    800042c6:	0586c683          	lbu	a3,88(a3) # 2000058 <_entry-0x7dffffa8>
    800042ca:	00d7f5b3          	and	a1,a5,a3
    800042ce:	cd91                	beqz	a1,800042ea <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800042d0:	2605                	addiw	a2,a2,1
    800042d2:	2485                	addiw	s1,s1,1
    800042d4:	fd4618e3          	bne	a2,s4,800042a4 <balloc+0x80>
    800042d8:	b759                	j	8000425e <balloc+0x3a>
  panic("balloc: out of blocks");
    800042da:	00005517          	auipc	a0,0x5
    800042de:	3ce50513          	addi	a0,a0,974 # 800096a8 <syscalls+0x138>
    800042e2:	ffffc097          	auipc	ra,0xffffc
    800042e6:	24c080e7          	jalr	588(ra) # 8000052e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800042ea:	974a                	add	a4,a4,s2
    800042ec:	8fd5                	or	a5,a5,a3
    800042ee:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800042f2:	854a                	mv	a0,s2
    800042f4:	00001097          	auipc	ra,0x1
    800042f8:	01e080e7          	jalr	30(ra) # 80005312 <log_write>
        brelse(bp);
    800042fc:	854a                	mv	a0,s2
    800042fe:	00000097          	auipc	ra,0x0
    80004302:	d94080e7          	jalr	-620(ra) # 80004092 <brelse>
  bp = bread(dev, bno);
    80004306:	85a6                	mv	a1,s1
    80004308:	855e                	mv	a0,s7
    8000430a:	00000097          	auipc	ra,0x0
    8000430e:	c58080e7          	jalr	-936(ra) # 80003f62 <bread>
    80004312:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80004314:	40000613          	li	a2,1024
    80004318:	4581                	li	a1,0
    8000431a:	05850513          	addi	a0,a0,88
    8000431e:	ffffd097          	auipc	ra,0xffffd
    80004322:	9c6080e7          	jalr	-1594(ra) # 80000ce4 <memset>
  log_write(bp);
    80004326:	854a                	mv	a0,s2
    80004328:	00001097          	auipc	ra,0x1
    8000432c:	fea080e7          	jalr	-22(ra) # 80005312 <log_write>
  brelse(bp);
    80004330:	854a                	mv	a0,s2
    80004332:	00000097          	auipc	ra,0x0
    80004336:	d60080e7          	jalr	-672(ra) # 80004092 <brelse>
}
    8000433a:	8526                	mv	a0,s1
    8000433c:	60e6                	ld	ra,88(sp)
    8000433e:	6446                	ld	s0,80(sp)
    80004340:	64a6                	ld	s1,72(sp)
    80004342:	6906                	ld	s2,64(sp)
    80004344:	79e2                	ld	s3,56(sp)
    80004346:	7a42                	ld	s4,48(sp)
    80004348:	7aa2                	ld	s5,40(sp)
    8000434a:	7b02                	ld	s6,32(sp)
    8000434c:	6be2                	ld	s7,24(sp)
    8000434e:	6c42                	ld	s8,16(sp)
    80004350:	6ca2                	ld	s9,8(sp)
    80004352:	6125                	addi	sp,sp,96
    80004354:	8082                	ret

0000000080004356 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80004356:	7179                	addi	sp,sp,-48
    80004358:	f406                	sd	ra,40(sp)
    8000435a:	f022                	sd	s0,32(sp)
    8000435c:	ec26                	sd	s1,24(sp)
    8000435e:	e84a                	sd	s2,16(sp)
    80004360:	e44e                	sd	s3,8(sp)
    80004362:	e052                	sd	s4,0(sp)
    80004364:	1800                	addi	s0,sp,48
    80004366:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80004368:	47ad                	li	a5,11
    8000436a:	04b7fe63          	bgeu	a5,a1,800043c6 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000436e:	ff45849b          	addiw	s1,a1,-12
    80004372:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80004376:	0ff00793          	li	a5,255
    8000437a:	0ae7e463          	bltu	a5,a4,80004422 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000437e:	08052583          	lw	a1,128(a0)
    80004382:	c5b5                	beqz	a1,800043ee <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80004384:	00092503          	lw	a0,0(s2)
    80004388:	00000097          	auipc	ra,0x0
    8000438c:	bda080e7          	jalr	-1062(ra) # 80003f62 <bread>
    80004390:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80004392:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80004396:	02049713          	slli	a4,s1,0x20
    8000439a:	01e75593          	srli	a1,a4,0x1e
    8000439e:	00b784b3          	add	s1,a5,a1
    800043a2:	0004a983          	lw	s3,0(s1)
    800043a6:	04098e63          	beqz	s3,80004402 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800043aa:	8552                	mv	a0,s4
    800043ac:	00000097          	auipc	ra,0x0
    800043b0:	ce6080e7          	jalr	-794(ra) # 80004092 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800043b4:	854e                	mv	a0,s3
    800043b6:	70a2                	ld	ra,40(sp)
    800043b8:	7402                	ld	s0,32(sp)
    800043ba:	64e2                	ld	s1,24(sp)
    800043bc:	6942                	ld	s2,16(sp)
    800043be:	69a2                	ld	s3,8(sp)
    800043c0:	6a02                	ld	s4,0(sp)
    800043c2:	6145                	addi	sp,sp,48
    800043c4:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800043c6:	02059793          	slli	a5,a1,0x20
    800043ca:	01e7d593          	srli	a1,a5,0x1e
    800043ce:	00b504b3          	add	s1,a0,a1
    800043d2:	0504a983          	lw	s3,80(s1)
    800043d6:	fc099fe3          	bnez	s3,800043b4 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800043da:	4108                	lw	a0,0(a0)
    800043dc:	00000097          	auipc	ra,0x0
    800043e0:	e48080e7          	jalr	-440(ra) # 80004224 <balloc>
    800043e4:	0005099b          	sext.w	s3,a0
    800043e8:	0534a823          	sw	s3,80(s1)
    800043ec:	b7e1                	j	800043b4 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800043ee:	4108                	lw	a0,0(a0)
    800043f0:	00000097          	auipc	ra,0x0
    800043f4:	e34080e7          	jalr	-460(ra) # 80004224 <balloc>
    800043f8:	0005059b          	sext.w	a1,a0
    800043fc:	08b92023          	sw	a1,128(s2)
    80004400:	b751                	j	80004384 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80004402:	00092503          	lw	a0,0(s2)
    80004406:	00000097          	auipc	ra,0x0
    8000440a:	e1e080e7          	jalr	-482(ra) # 80004224 <balloc>
    8000440e:	0005099b          	sext.w	s3,a0
    80004412:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80004416:	8552                	mv	a0,s4
    80004418:	00001097          	auipc	ra,0x1
    8000441c:	efa080e7          	jalr	-262(ra) # 80005312 <log_write>
    80004420:	b769                	j	800043aa <bmap+0x54>
  panic("bmap: out of range");
    80004422:	00005517          	auipc	a0,0x5
    80004426:	29e50513          	addi	a0,a0,670 # 800096c0 <syscalls+0x150>
    8000442a:	ffffc097          	auipc	ra,0xffffc
    8000442e:	104080e7          	jalr	260(ra) # 8000052e <panic>

0000000080004432 <iget>:
{
    80004432:	7179                	addi	sp,sp,-48
    80004434:	f406                	sd	ra,40(sp)
    80004436:	f022                	sd	s0,32(sp)
    80004438:	ec26                	sd	s1,24(sp)
    8000443a:	e84a                	sd	s2,16(sp)
    8000443c:	e44e                	sd	s3,8(sp)
    8000443e:	e052                	sd	s4,0(sp)
    80004440:	1800                	addi	s0,sp,48
    80004442:	89aa                	mv	s3,a0
    80004444:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80004446:	00038517          	auipc	a0,0x38
    8000444a:	bda50513          	addi	a0,a0,-1062 # 8003c020 <itable>
    8000444e:	ffffc097          	auipc	ra,0xffffc
    80004452:	778080e7          	jalr	1912(ra) # 80000bc6 <acquire>
  empty = 0;
    80004456:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004458:	00038497          	auipc	s1,0x38
    8000445c:	be048493          	addi	s1,s1,-1056 # 8003c038 <itable+0x18>
    80004460:	00039697          	auipc	a3,0x39
    80004464:	66868693          	addi	a3,a3,1640 # 8003dac8 <log>
    80004468:	a039                	j	80004476 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000446a:	02090b63          	beqz	s2,800044a0 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000446e:	08848493          	addi	s1,s1,136
    80004472:	02d48a63          	beq	s1,a3,800044a6 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80004476:	449c                	lw	a5,8(s1)
    80004478:	fef059e3          	blez	a5,8000446a <iget+0x38>
    8000447c:	4098                	lw	a4,0(s1)
    8000447e:	ff3716e3          	bne	a4,s3,8000446a <iget+0x38>
    80004482:	40d8                	lw	a4,4(s1)
    80004484:	ff4713e3          	bne	a4,s4,8000446a <iget+0x38>
      ip->ref++;
    80004488:	2785                	addiw	a5,a5,1
    8000448a:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000448c:	00038517          	auipc	a0,0x38
    80004490:	b9450513          	addi	a0,a0,-1132 # 8003c020 <itable>
    80004494:	ffffd097          	auipc	ra,0xffffd
    80004498:	808080e7          	jalr	-2040(ra) # 80000c9c <release>
      return ip;
    8000449c:	8926                	mv	s2,s1
    8000449e:	a03d                	j	800044cc <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800044a0:	f7f9                	bnez	a5,8000446e <iget+0x3c>
    800044a2:	8926                	mv	s2,s1
    800044a4:	b7e9                	j	8000446e <iget+0x3c>
  if(empty == 0)
    800044a6:	02090c63          	beqz	s2,800044de <iget+0xac>
  ip->dev = dev;
    800044aa:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800044ae:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800044b2:	4785                	li	a5,1
    800044b4:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800044b8:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800044bc:	00038517          	auipc	a0,0x38
    800044c0:	b6450513          	addi	a0,a0,-1180 # 8003c020 <itable>
    800044c4:	ffffc097          	auipc	ra,0xffffc
    800044c8:	7d8080e7          	jalr	2008(ra) # 80000c9c <release>
}
    800044cc:	854a                	mv	a0,s2
    800044ce:	70a2                	ld	ra,40(sp)
    800044d0:	7402                	ld	s0,32(sp)
    800044d2:	64e2                	ld	s1,24(sp)
    800044d4:	6942                	ld	s2,16(sp)
    800044d6:	69a2                	ld	s3,8(sp)
    800044d8:	6a02                	ld	s4,0(sp)
    800044da:	6145                	addi	sp,sp,48
    800044dc:	8082                	ret
    panic("iget: no inodes");
    800044de:	00005517          	auipc	a0,0x5
    800044e2:	1fa50513          	addi	a0,a0,506 # 800096d8 <syscalls+0x168>
    800044e6:	ffffc097          	auipc	ra,0xffffc
    800044ea:	048080e7          	jalr	72(ra) # 8000052e <panic>

00000000800044ee <fsinit>:
fsinit(int dev) {
    800044ee:	7179                	addi	sp,sp,-48
    800044f0:	f406                	sd	ra,40(sp)
    800044f2:	f022                	sd	s0,32(sp)
    800044f4:	ec26                	sd	s1,24(sp)
    800044f6:	e84a                	sd	s2,16(sp)
    800044f8:	e44e                	sd	s3,8(sp)
    800044fa:	1800                	addi	s0,sp,48
    800044fc:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800044fe:	4585                	li	a1,1
    80004500:	00000097          	auipc	ra,0x0
    80004504:	a62080e7          	jalr	-1438(ra) # 80003f62 <bread>
    80004508:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000450a:	00038997          	auipc	s3,0x38
    8000450e:	af698993          	addi	s3,s3,-1290 # 8003c000 <sb>
    80004512:	02000613          	li	a2,32
    80004516:	05850593          	addi	a1,a0,88
    8000451a:	854e                	mv	a0,s3
    8000451c:	ffffd097          	auipc	ra,0xffffd
    80004520:	824080e7          	jalr	-2012(ra) # 80000d40 <memmove>
  brelse(bp);
    80004524:	8526                	mv	a0,s1
    80004526:	00000097          	auipc	ra,0x0
    8000452a:	b6c080e7          	jalr	-1172(ra) # 80004092 <brelse>
  if(sb.magic != FSMAGIC)
    8000452e:	0009a703          	lw	a4,0(s3)
    80004532:	102037b7          	lui	a5,0x10203
    80004536:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000453a:	02f71263          	bne	a4,a5,8000455e <fsinit+0x70>
  initlog(dev, &sb);
    8000453e:	00038597          	auipc	a1,0x38
    80004542:	ac258593          	addi	a1,a1,-1342 # 8003c000 <sb>
    80004546:	854a                	mv	a0,s2
    80004548:	00001097          	auipc	ra,0x1
    8000454c:	b4c080e7          	jalr	-1204(ra) # 80005094 <initlog>
}
    80004550:	70a2                	ld	ra,40(sp)
    80004552:	7402                	ld	s0,32(sp)
    80004554:	64e2                	ld	s1,24(sp)
    80004556:	6942                	ld	s2,16(sp)
    80004558:	69a2                	ld	s3,8(sp)
    8000455a:	6145                	addi	sp,sp,48
    8000455c:	8082                	ret
    panic("invalid file system");
    8000455e:	00005517          	auipc	a0,0x5
    80004562:	18a50513          	addi	a0,a0,394 # 800096e8 <syscalls+0x178>
    80004566:	ffffc097          	auipc	ra,0xffffc
    8000456a:	fc8080e7          	jalr	-56(ra) # 8000052e <panic>

000000008000456e <iinit>:
{
    8000456e:	7179                	addi	sp,sp,-48
    80004570:	f406                	sd	ra,40(sp)
    80004572:	f022                	sd	s0,32(sp)
    80004574:	ec26                	sd	s1,24(sp)
    80004576:	e84a                	sd	s2,16(sp)
    80004578:	e44e                	sd	s3,8(sp)
    8000457a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000457c:	00005597          	auipc	a1,0x5
    80004580:	18458593          	addi	a1,a1,388 # 80009700 <syscalls+0x190>
    80004584:	00038517          	auipc	a0,0x38
    80004588:	a9c50513          	addi	a0,a0,-1380 # 8003c020 <itable>
    8000458c:	ffffc097          	auipc	ra,0xffffc
    80004590:	5aa080e7          	jalr	1450(ra) # 80000b36 <initlock>
  for(i = 0; i < NINODE; i++) {
    80004594:	00038497          	auipc	s1,0x38
    80004598:	ab448493          	addi	s1,s1,-1356 # 8003c048 <itable+0x28>
    8000459c:	00039997          	auipc	s3,0x39
    800045a0:	53c98993          	addi	s3,s3,1340 # 8003dad8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800045a4:	00005917          	auipc	s2,0x5
    800045a8:	16490913          	addi	s2,s2,356 # 80009708 <syscalls+0x198>
    800045ac:	85ca                	mv	a1,s2
    800045ae:	8526                	mv	a0,s1
    800045b0:	00001097          	auipc	ra,0x1
    800045b4:	e48080e7          	jalr	-440(ra) # 800053f8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800045b8:	08848493          	addi	s1,s1,136
    800045bc:	ff3498e3          	bne	s1,s3,800045ac <iinit+0x3e>
}
    800045c0:	70a2                	ld	ra,40(sp)
    800045c2:	7402                	ld	s0,32(sp)
    800045c4:	64e2                	ld	s1,24(sp)
    800045c6:	6942                	ld	s2,16(sp)
    800045c8:	69a2                	ld	s3,8(sp)
    800045ca:	6145                	addi	sp,sp,48
    800045cc:	8082                	ret

00000000800045ce <ialloc>:
{
    800045ce:	715d                	addi	sp,sp,-80
    800045d0:	e486                	sd	ra,72(sp)
    800045d2:	e0a2                	sd	s0,64(sp)
    800045d4:	fc26                	sd	s1,56(sp)
    800045d6:	f84a                	sd	s2,48(sp)
    800045d8:	f44e                	sd	s3,40(sp)
    800045da:	f052                	sd	s4,32(sp)
    800045dc:	ec56                	sd	s5,24(sp)
    800045de:	e85a                	sd	s6,16(sp)
    800045e0:	e45e                	sd	s7,8(sp)
    800045e2:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800045e4:	00038717          	auipc	a4,0x38
    800045e8:	a2872703          	lw	a4,-1496(a4) # 8003c00c <sb+0xc>
    800045ec:	4785                	li	a5,1
    800045ee:	04e7fa63          	bgeu	a5,a4,80004642 <ialloc+0x74>
    800045f2:	8aaa                	mv	s5,a0
    800045f4:	8bae                	mv	s7,a1
    800045f6:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800045f8:	00038a17          	auipc	s4,0x38
    800045fc:	a08a0a13          	addi	s4,s4,-1528 # 8003c000 <sb>
    80004600:	00048b1b          	sext.w	s6,s1
    80004604:	0044d793          	srli	a5,s1,0x4
    80004608:	018a2583          	lw	a1,24(s4)
    8000460c:	9dbd                	addw	a1,a1,a5
    8000460e:	8556                	mv	a0,s5
    80004610:	00000097          	auipc	ra,0x0
    80004614:	952080e7          	jalr	-1710(ra) # 80003f62 <bread>
    80004618:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000461a:	05850993          	addi	s3,a0,88
    8000461e:	00f4f793          	andi	a5,s1,15
    80004622:	079a                	slli	a5,a5,0x6
    80004624:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80004626:	00099783          	lh	a5,0(s3)
    8000462a:	c785                	beqz	a5,80004652 <ialloc+0x84>
    brelse(bp);
    8000462c:	00000097          	auipc	ra,0x0
    80004630:	a66080e7          	jalr	-1434(ra) # 80004092 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80004634:	0485                	addi	s1,s1,1
    80004636:	00ca2703          	lw	a4,12(s4)
    8000463a:	0004879b          	sext.w	a5,s1
    8000463e:	fce7e1e3          	bltu	a5,a4,80004600 <ialloc+0x32>
  panic("ialloc: no inodes");
    80004642:	00005517          	auipc	a0,0x5
    80004646:	0ce50513          	addi	a0,a0,206 # 80009710 <syscalls+0x1a0>
    8000464a:	ffffc097          	auipc	ra,0xffffc
    8000464e:	ee4080e7          	jalr	-284(ra) # 8000052e <panic>
      memset(dip, 0, sizeof(*dip));
    80004652:	04000613          	li	a2,64
    80004656:	4581                	li	a1,0
    80004658:	854e                	mv	a0,s3
    8000465a:	ffffc097          	auipc	ra,0xffffc
    8000465e:	68a080e7          	jalr	1674(ra) # 80000ce4 <memset>
      dip->type = type;
    80004662:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80004666:	854a                	mv	a0,s2
    80004668:	00001097          	auipc	ra,0x1
    8000466c:	caa080e7          	jalr	-854(ra) # 80005312 <log_write>
      brelse(bp);
    80004670:	854a                	mv	a0,s2
    80004672:	00000097          	auipc	ra,0x0
    80004676:	a20080e7          	jalr	-1504(ra) # 80004092 <brelse>
      return iget(dev, inum);
    8000467a:	85da                	mv	a1,s6
    8000467c:	8556                	mv	a0,s5
    8000467e:	00000097          	auipc	ra,0x0
    80004682:	db4080e7          	jalr	-588(ra) # 80004432 <iget>
}
    80004686:	60a6                	ld	ra,72(sp)
    80004688:	6406                	ld	s0,64(sp)
    8000468a:	74e2                	ld	s1,56(sp)
    8000468c:	7942                	ld	s2,48(sp)
    8000468e:	79a2                	ld	s3,40(sp)
    80004690:	7a02                	ld	s4,32(sp)
    80004692:	6ae2                	ld	s5,24(sp)
    80004694:	6b42                	ld	s6,16(sp)
    80004696:	6ba2                	ld	s7,8(sp)
    80004698:	6161                	addi	sp,sp,80
    8000469a:	8082                	ret

000000008000469c <iupdate>:
{
    8000469c:	1101                	addi	sp,sp,-32
    8000469e:	ec06                	sd	ra,24(sp)
    800046a0:	e822                	sd	s0,16(sp)
    800046a2:	e426                	sd	s1,8(sp)
    800046a4:	e04a                	sd	s2,0(sp)
    800046a6:	1000                	addi	s0,sp,32
    800046a8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800046aa:	415c                	lw	a5,4(a0)
    800046ac:	0047d79b          	srliw	a5,a5,0x4
    800046b0:	00038597          	auipc	a1,0x38
    800046b4:	9685a583          	lw	a1,-1688(a1) # 8003c018 <sb+0x18>
    800046b8:	9dbd                	addw	a1,a1,a5
    800046ba:	4108                	lw	a0,0(a0)
    800046bc:	00000097          	auipc	ra,0x0
    800046c0:	8a6080e7          	jalr	-1882(ra) # 80003f62 <bread>
    800046c4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800046c6:	05850793          	addi	a5,a0,88
    800046ca:	40c8                	lw	a0,4(s1)
    800046cc:	893d                	andi	a0,a0,15
    800046ce:	051a                	slli	a0,a0,0x6
    800046d0:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800046d2:	04449703          	lh	a4,68(s1)
    800046d6:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800046da:	04649703          	lh	a4,70(s1)
    800046de:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800046e2:	04849703          	lh	a4,72(s1)
    800046e6:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800046ea:	04a49703          	lh	a4,74(s1)
    800046ee:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800046f2:	44f8                	lw	a4,76(s1)
    800046f4:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800046f6:	03400613          	li	a2,52
    800046fa:	05048593          	addi	a1,s1,80
    800046fe:	0531                	addi	a0,a0,12
    80004700:	ffffc097          	auipc	ra,0xffffc
    80004704:	640080e7          	jalr	1600(ra) # 80000d40 <memmove>
  log_write(bp);
    80004708:	854a                	mv	a0,s2
    8000470a:	00001097          	auipc	ra,0x1
    8000470e:	c08080e7          	jalr	-1016(ra) # 80005312 <log_write>
  brelse(bp);
    80004712:	854a                	mv	a0,s2
    80004714:	00000097          	auipc	ra,0x0
    80004718:	97e080e7          	jalr	-1666(ra) # 80004092 <brelse>
}
    8000471c:	60e2                	ld	ra,24(sp)
    8000471e:	6442                	ld	s0,16(sp)
    80004720:	64a2                	ld	s1,8(sp)
    80004722:	6902                	ld	s2,0(sp)
    80004724:	6105                	addi	sp,sp,32
    80004726:	8082                	ret

0000000080004728 <idup>:
{
    80004728:	1101                	addi	sp,sp,-32
    8000472a:	ec06                	sd	ra,24(sp)
    8000472c:	e822                	sd	s0,16(sp)
    8000472e:	e426                	sd	s1,8(sp)
    80004730:	1000                	addi	s0,sp,32
    80004732:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80004734:	00038517          	auipc	a0,0x38
    80004738:	8ec50513          	addi	a0,a0,-1812 # 8003c020 <itable>
    8000473c:	ffffc097          	auipc	ra,0xffffc
    80004740:	48a080e7          	jalr	1162(ra) # 80000bc6 <acquire>
  ip->ref++;
    80004744:	449c                	lw	a5,8(s1)
    80004746:	2785                	addiw	a5,a5,1
    80004748:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000474a:	00038517          	auipc	a0,0x38
    8000474e:	8d650513          	addi	a0,a0,-1834 # 8003c020 <itable>
    80004752:	ffffc097          	auipc	ra,0xffffc
    80004756:	54a080e7          	jalr	1354(ra) # 80000c9c <release>
}
    8000475a:	8526                	mv	a0,s1
    8000475c:	60e2                	ld	ra,24(sp)
    8000475e:	6442                	ld	s0,16(sp)
    80004760:	64a2                	ld	s1,8(sp)
    80004762:	6105                	addi	sp,sp,32
    80004764:	8082                	ret

0000000080004766 <ilock>:
{
    80004766:	1101                	addi	sp,sp,-32
    80004768:	ec06                	sd	ra,24(sp)
    8000476a:	e822                	sd	s0,16(sp)
    8000476c:	e426                	sd	s1,8(sp)
    8000476e:	e04a                	sd	s2,0(sp)
    80004770:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80004772:	c115                	beqz	a0,80004796 <ilock+0x30>
    80004774:	84aa                	mv	s1,a0
    80004776:	451c                	lw	a5,8(a0)
    80004778:	00f05f63          	blez	a5,80004796 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000477c:	0541                	addi	a0,a0,16
    8000477e:	00001097          	auipc	ra,0x1
    80004782:	cb4080e7          	jalr	-844(ra) # 80005432 <acquiresleep>
  if(ip->valid == 0){
    80004786:	40bc                	lw	a5,64(s1)
    80004788:	cf99                	beqz	a5,800047a6 <ilock+0x40>
}
    8000478a:	60e2                	ld	ra,24(sp)
    8000478c:	6442                	ld	s0,16(sp)
    8000478e:	64a2                	ld	s1,8(sp)
    80004790:	6902                	ld	s2,0(sp)
    80004792:	6105                	addi	sp,sp,32
    80004794:	8082                	ret
    panic("ilock");
    80004796:	00005517          	auipc	a0,0x5
    8000479a:	f9250513          	addi	a0,a0,-110 # 80009728 <syscalls+0x1b8>
    8000479e:	ffffc097          	auipc	ra,0xffffc
    800047a2:	d90080e7          	jalr	-624(ra) # 8000052e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800047a6:	40dc                	lw	a5,4(s1)
    800047a8:	0047d79b          	srliw	a5,a5,0x4
    800047ac:	00038597          	auipc	a1,0x38
    800047b0:	86c5a583          	lw	a1,-1940(a1) # 8003c018 <sb+0x18>
    800047b4:	9dbd                	addw	a1,a1,a5
    800047b6:	4088                	lw	a0,0(s1)
    800047b8:	fffff097          	auipc	ra,0xfffff
    800047bc:	7aa080e7          	jalr	1962(ra) # 80003f62 <bread>
    800047c0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800047c2:	05850593          	addi	a1,a0,88
    800047c6:	40dc                	lw	a5,4(s1)
    800047c8:	8bbd                	andi	a5,a5,15
    800047ca:	079a                	slli	a5,a5,0x6
    800047cc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800047ce:	00059783          	lh	a5,0(a1)
    800047d2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800047d6:	00259783          	lh	a5,2(a1)
    800047da:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800047de:	00459783          	lh	a5,4(a1)
    800047e2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800047e6:	00659783          	lh	a5,6(a1)
    800047ea:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800047ee:	459c                	lw	a5,8(a1)
    800047f0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800047f2:	03400613          	li	a2,52
    800047f6:	05b1                	addi	a1,a1,12
    800047f8:	05048513          	addi	a0,s1,80
    800047fc:	ffffc097          	auipc	ra,0xffffc
    80004800:	544080e7          	jalr	1348(ra) # 80000d40 <memmove>
    brelse(bp);
    80004804:	854a                	mv	a0,s2
    80004806:	00000097          	auipc	ra,0x0
    8000480a:	88c080e7          	jalr	-1908(ra) # 80004092 <brelse>
    ip->valid = 1;
    8000480e:	4785                	li	a5,1
    80004810:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80004812:	04449783          	lh	a5,68(s1)
    80004816:	fbb5                	bnez	a5,8000478a <ilock+0x24>
      panic("ilock: no type");
    80004818:	00005517          	auipc	a0,0x5
    8000481c:	f1850513          	addi	a0,a0,-232 # 80009730 <syscalls+0x1c0>
    80004820:	ffffc097          	auipc	ra,0xffffc
    80004824:	d0e080e7          	jalr	-754(ra) # 8000052e <panic>

0000000080004828 <iunlock>:
{
    80004828:	1101                	addi	sp,sp,-32
    8000482a:	ec06                	sd	ra,24(sp)
    8000482c:	e822                	sd	s0,16(sp)
    8000482e:	e426                	sd	s1,8(sp)
    80004830:	e04a                	sd	s2,0(sp)
    80004832:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80004834:	c905                	beqz	a0,80004864 <iunlock+0x3c>
    80004836:	84aa                	mv	s1,a0
    80004838:	01050913          	addi	s2,a0,16
    8000483c:	854a                	mv	a0,s2
    8000483e:	00001097          	auipc	ra,0x1
    80004842:	c8e080e7          	jalr	-882(ra) # 800054cc <holdingsleep>
    80004846:	cd19                	beqz	a0,80004864 <iunlock+0x3c>
    80004848:	449c                	lw	a5,8(s1)
    8000484a:	00f05d63          	blez	a5,80004864 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000484e:	854a                	mv	a0,s2
    80004850:	00001097          	auipc	ra,0x1
    80004854:	c38080e7          	jalr	-968(ra) # 80005488 <releasesleep>
}
    80004858:	60e2                	ld	ra,24(sp)
    8000485a:	6442                	ld	s0,16(sp)
    8000485c:	64a2                	ld	s1,8(sp)
    8000485e:	6902                	ld	s2,0(sp)
    80004860:	6105                	addi	sp,sp,32
    80004862:	8082                	ret
    panic("iunlock");
    80004864:	00005517          	auipc	a0,0x5
    80004868:	edc50513          	addi	a0,a0,-292 # 80009740 <syscalls+0x1d0>
    8000486c:	ffffc097          	auipc	ra,0xffffc
    80004870:	cc2080e7          	jalr	-830(ra) # 8000052e <panic>

0000000080004874 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80004874:	7179                	addi	sp,sp,-48
    80004876:	f406                	sd	ra,40(sp)
    80004878:	f022                	sd	s0,32(sp)
    8000487a:	ec26                	sd	s1,24(sp)
    8000487c:	e84a                	sd	s2,16(sp)
    8000487e:	e44e                	sd	s3,8(sp)
    80004880:	e052                	sd	s4,0(sp)
    80004882:	1800                	addi	s0,sp,48
    80004884:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80004886:	05050493          	addi	s1,a0,80
    8000488a:	08050913          	addi	s2,a0,128
    8000488e:	a021                	j	80004896 <itrunc+0x22>
    80004890:	0491                	addi	s1,s1,4
    80004892:	01248d63          	beq	s1,s2,800048ac <itrunc+0x38>
    if(ip->addrs[i]){
    80004896:	408c                	lw	a1,0(s1)
    80004898:	dde5                	beqz	a1,80004890 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000489a:	0009a503          	lw	a0,0(s3)
    8000489e:	00000097          	auipc	ra,0x0
    800048a2:	90a080e7          	jalr	-1782(ra) # 800041a8 <bfree>
      ip->addrs[i] = 0;
    800048a6:	0004a023          	sw	zero,0(s1)
    800048aa:	b7dd                	j	80004890 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800048ac:	0809a583          	lw	a1,128(s3)
    800048b0:	e185                	bnez	a1,800048d0 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800048b2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800048b6:	854e                	mv	a0,s3
    800048b8:	00000097          	auipc	ra,0x0
    800048bc:	de4080e7          	jalr	-540(ra) # 8000469c <iupdate>
}
    800048c0:	70a2                	ld	ra,40(sp)
    800048c2:	7402                	ld	s0,32(sp)
    800048c4:	64e2                	ld	s1,24(sp)
    800048c6:	6942                	ld	s2,16(sp)
    800048c8:	69a2                	ld	s3,8(sp)
    800048ca:	6a02                	ld	s4,0(sp)
    800048cc:	6145                	addi	sp,sp,48
    800048ce:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800048d0:	0009a503          	lw	a0,0(s3)
    800048d4:	fffff097          	auipc	ra,0xfffff
    800048d8:	68e080e7          	jalr	1678(ra) # 80003f62 <bread>
    800048dc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800048de:	05850493          	addi	s1,a0,88
    800048e2:	45850913          	addi	s2,a0,1112
    800048e6:	a021                	j	800048ee <itrunc+0x7a>
    800048e8:	0491                	addi	s1,s1,4
    800048ea:	01248b63          	beq	s1,s2,80004900 <itrunc+0x8c>
      if(a[j])
    800048ee:	408c                	lw	a1,0(s1)
    800048f0:	dde5                	beqz	a1,800048e8 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800048f2:	0009a503          	lw	a0,0(s3)
    800048f6:	00000097          	auipc	ra,0x0
    800048fa:	8b2080e7          	jalr	-1870(ra) # 800041a8 <bfree>
    800048fe:	b7ed                	j	800048e8 <itrunc+0x74>
    brelse(bp);
    80004900:	8552                	mv	a0,s4
    80004902:	fffff097          	auipc	ra,0xfffff
    80004906:	790080e7          	jalr	1936(ra) # 80004092 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000490a:	0809a583          	lw	a1,128(s3)
    8000490e:	0009a503          	lw	a0,0(s3)
    80004912:	00000097          	auipc	ra,0x0
    80004916:	896080e7          	jalr	-1898(ra) # 800041a8 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000491a:	0809a023          	sw	zero,128(s3)
    8000491e:	bf51                	j	800048b2 <itrunc+0x3e>

0000000080004920 <iput>:
{
    80004920:	1101                	addi	sp,sp,-32
    80004922:	ec06                	sd	ra,24(sp)
    80004924:	e822                	sd	s0,16(sp)
    80004926:	e426                	sd	s1,8(sp)
    80004928:	e04a                	sd	s2,0(sp)
    8000492a:	1000                	addi	s0,sp,32
    8000492c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000492e:	00037517          	auipc	a0,0x37
    80004932:	6f250513          	addi	a0,a0,1778 # 8003c020 <itable>
    80004936:	ffffc097          	auipc	ra,0xffffc
    8000493a:	290080e7          	jalr	656(ra) # 80000bc6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000493e:	4498                	lw	a4,8(s1)
    80004940:	4785                	li	a5,1
    80004942:	02f70363          	beq	a4,a5,80004968 <iput+0x48>
  ip->ref--;
    80004946:	449c                	lw	a5,8(s1)
    80004948:	37fd                	addiw	a5,a5,-1
    8000494a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000494c:	00037517          	auipc	a0,0x37
    80004950:	6d450513          	addi	a0,a0,1748 # 8003c020 <itable>
    80004954:	ffffc097          	auipc	ra,0xffffc
    80004958:	348080e7          	jalr	840(ra) # 80000c9c <release>
}
    8000495c:	60e2                	ld	ra,24(sp)
    8000495e:	6442                	ld	s0,16(sp)
    80004960:	64a2                	ld	s1,8(sp)
    80004962:	6902                	ld	s2,0(sp)
    80004964:	6105                	addi	sp,sp,32
    80004966:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004968:	40bc                	lw	a5,64(s1)
    8000496a:	dff1                	beqz	a5,80004946 <iput+0x26>
    8000496c:	04a49783          	lh	a5,74(s1)
    80004970:	fbf9                	bnez	a5,80004946 <iput+0x26>
    acquiresleep(&ip->lock);
    80004972:	01048913          	addi	s2,s1,16
    80004976:	854a                	mv	a0,s2
    80004978:	00001097          	auipc	ra,0x1
    8000497c:	aba080e7          	jalr	-1350(ra) # 80005432 <acquiresleep>
    release(&itable.lock);
    80004980:	00037517          	auipc	a0,0x37
    80004984:	6a050513          	addi	a0,a0,1696 # 8003c020 <itable>
    80004988:	ffffc097          	auipc	ra,0xffffc
    8000498c:	314080e7          	jalr	788(ra) # 80000c9c <release>
    itrunc(ip);
    80004990:	8526                	mv	a0,s1
    80004992:	00000097          	auipc	ra,0x0
    80004996:	ee2080e7          	jalr	-286(ra) # 80004874 <itrunc>
    ip->type = 0;
    8000499a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000499e:	8526                	mv	a0,s1
    800049a0:	00000097          	auipc	ra,0x0
    800049a4:	cfc080e7          	jalr	-772(ra) # 8000469c <iupdate>
    ip->valid = 0;
    800049a8:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800049ac:	854a                	mv	a0,s2
    800049ae:	00001097          	auipc	ra,0x1
    800049b2:	ada080e7          	jalr	-1318(ra) # 80005488 <releasesleep>
    acquire(&itable.lock);
    800049b6:	00037517          	auipc	a0,0x37
    800049ba:	66a50513          	addi	a0,a0,1642 # 8003c020 <itable>
    800049be:	ffffc097          	auipc	ra,0xffffc
    800049c2:	208080e7          	jalr	520(ra) # 80000bc6 <acquire>
    800049c6:	b741                	j	80004946 <iput+0x26>

00000000800049c8 <iunlockput>:
{
    800049c8:	1101                	addi	sp,sp,-32
    800049ca:	ec06                	sd	ra,24(sp)
    800049cc:	e822                	sd	s0,16(sp)
    800049ce:	e426                	sd	s1,8(sp)
    800049d0:	1000                	addi	s0,sp,32
    800049d2:	84aa                	mv	s1,a0
  iunlock(ip);
    800049d4:	00000097          	auipc	ra,0x0
    800049d8:	e54080e7          	jalr	-428(ra) # 80004828 <iunlock>
  iput(ip);
    800049dc:	8526                	mv	a0,s1
    800049de:	00000097          	auipc	ra,0x0
    800049e2:	f42080e7          	jalr	-190(ra) # 80004920 <iput>
}
    800049e6:	60e2                	ld	ra,24(sp)
    800049e8:	6442                	ld	s0,16(sp)
    800049ea:	64a2                	ld	s1,8(sp)
    800049ec:	6105                	addi	sp,sp,32
    800049ee:	8082                	ret

00000000800049f0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800049f0:	1141                	addi	sp,sp,-16
    800049f2:	e422                	sd	s0,8(sp)
    800049f4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800049f6:	411c                	lw	a5,0(a0)
    800049f8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800049fa:	415c                	lw	a5,4(a0)
    800049fc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800049fe:	04451783          	lh	a5,68(a0)
    80004a02:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80004a06:	04a51783          	lh	a5,74(a0)
    80004a0a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80004a0e:	04c56783          	lwu	a5,76(a0)
    80004a12:	e99c                	sd	a5,16(a1)
}
    80004a14:	6422                	ld	s0,8(sp)
    80004a16:	0141                	addi	sp,sp,16
    80004a18:	8082                	ret

0000000080004a1a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004a1a:	457c                	lw	a5,76(a0)
    80004a1c:	0ed7e963          	bltu	a5,a3,80004b0e <readi+0xf4>
{
    80004a20:	7159                	addi	sp,sp,-112
    80004a22:	f486                	sd	ra,104(sp)
    80004a24:	f0a2                	sd	s0,96(sp)
    80004a26:	eca6                	sd	s1,88(sp)
    80004a28:	e8ca                	sd	s2,80(sp)
    80004a2a:	e4ce                	sd	s3,72(sp)
    80004a2c:	e0d2                	sd	s4,64(sp)
    80004a2e:	fc56                	sd	s5,56(sp)
    80004a30:	f85a                	sd	s6,48(sp)
    80004a32:	f45e                	sd	s7,40(sp)
    80004a34:	f062                	sd	s8,32(sp)
    80004a36:	ec66                	sd	s9,24(sp)
    80004a38:	e86a                	sd	s10,16(sp)
    80004a3a:	e46e                	sd	s11,8(sp)
    80004a3c:	1880                	addi	s0,sp,112
    80004a3e:	8baa                	mv	s7,a0
    80004a40:	8c2e                	mv	s8,a1
    80004a42:	8ab2                	mv	s5,a2
    80004a44:	84b6                	mv	s1,a3
    80004a46:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004a48:	9f35                	addw	a4,a4,a3
    return 0;
    80004a4a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004a4c:	0ad76063          	bltu	a4,a3,80004aec <readi+0xd2>
  if(off + n > ip->size)
    80004a50:	00e7f463          	bgeu	a5,a4,80004a58 <readi+0x3e>
    n = ip->size - off;
    80004a54:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004a58:	0a0b0963          	beqz	s6,80004b0a <readi+0xf0>
    80004a5c:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004a5e:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80004a62:	5cfd                	li	s9,-1
    80004a64:	a82d                	j	80004a9e <readi+0x84>
    80004a66:	020a1d93          	slli	s11,s4,0x20
    80004a6a:	020ddd93          	srli	s11,s11,0x20
    80004a6e:	05890793          	addi	a5,s2,88
    80004a72:	86ee                	mv	a3,s11
    80004a74:	963e                	add	a2,a2,a5
    80004a76:	85d6                	mv	a1,s5
    80004a78:	8562                	mv	a0,s8
    80004a7a:	ffffe097          	auipc	ra,0xffffe
    80004a7e:	eb8080e7          	jalr	-328(ra) # 80002932 <either_copyout>
    80004a82:	05950d63          	beq	a0,s9,80004adc <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004a86:	854a                	mv	a0,s2
    80004a88:	fffff097          	auipc	ra,0xfffff
    80004a8c:	60a080e7          	jalr	1546(ra) # 80004092 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004a90:	013a09bb          	addw	s3,s4,s3
    80004a94:	009a04bb          	addw	s1,s4,s1
    80004a98:	9aee                	add	s5,s5,s11
    80004a9a:	0569f763          	bgeu	s3,s6,80004ae8 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004a9e:	000ba903          	lw	s2,0(s7)
    80004aa2:	00a4d59b          	srliw	a1,s1,0xa
    80004aa6:	855e                	mv	a0,s7
    80004aa8:	00000097          	auipc	ra,0x0
    80004aac:	8ae080e7          	jalr	-1874(ra) # 80004356 <bmap>
    80004ab0:	0005059b          	sext.w	a1,a0
    80004ab4:	854a                	mv	a0,s2
    80004ab6:	fffff097          	auipc	ra,0xfffff
    80004aba:	4ac080e7          	jalr	1196(ra) # 80003f62 <bread>
    80004abe:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004ac0:	3ff4f613          	andi	a2,s1,1023
    80004ac4:	40cd07bb          	subw	a5,s10,a2
    80004ac8:	413b073b          	subw	a4,s6,s3
    80004acc:	8a3e                	mv	s4,a5
    80004ace:	2781                	sext.w	a5,a5
    80004ad0:	0007069b          	sext.w	a3,a4
    80004ad4:	f8f6f9e3          	bgeu	a3,a5,80004a66 <readi+0x4c>
    80004ad8:	8a3a                	mv	s4,a4
    80004ada:	b771                	j	80004a66 <readi+0x4c>
      brelse(bp);
    80004adc:	854a                	mv	a0,s2
    80004ade:	fffff097          	auipc	ra,0xfffff
    80004ae2:	5b4080e7          	jalr	1460(ra) # 80004092 <brelse>
      tot = -1;
    80004ae6:	59fd                	li	s3,-1
  }
  return tot;
    80004ae8:	0009851b          	sext.w	a0,s3
}
    80004aec:	70a6                	ld	ra,104(sp)
    80004aee:	7406                	ld	s0,96(sp)
    80004af0:	64e6                	ld	s1,88(sp)
    80004af2:	6946                	ld	s2,80(sp)
    80004af4:	69a6                	ld	s3,72(sp)
    80004af6:	6a06                	ld	s4,64(sp)
    80004af8:	7ae2                	ld	s5,56(sp)
    80004afa:	7b42                	ld	s6,48(sp)
    80004afc:	7ba2                	ld	s7,40(sp)
    80004afe:	7c02                	ld	s8,32(sp)
    80004b00:	6ce2                	ld	s9,24(sp)
    80004b02:	6d42                	ld	s10,16(sp)
    80004b04:	6da2                	ld	s11,8(sp)
    80004b06:	6165                	addi	sp,sp,112
    80004b08:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004b0a:	89da                	mv	s3,s6
    80004b0c:	bff1                	j	80004ae8 <readi+0xce>
    return 0;
    80004b0e:	4501                	li	a0,0
}
    80004b10:	8082                	ret

0000000080004b12 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80004b12:	457c                	lw	a5,76(a0)
    80004b14:	10d7e863          	bltu	a5,a3,80004c24 <writei+0x112>
{
    80004b18:	7159                	addi	sp,sp,-112
    80004b1a:	f486                	sd	ra,104(sp)
    80004b1c:	f0a2                	sd	s0,96(sp)
    80004b1e:	eca6                	sd	s1,88(sp)
    80004b20:	e8ca                	sd	s2,80(sp)
    80004b22:	e4ce                	sd	s3,72(sp)
    80004b24:	e0d2                	sd	s4,64(sp)
    80004b26:	fc56                	sd	s5,56(sp)
    80004b28:	f85a                	sd	s6,48(sp)
    80004b2a:	f45e                	sd	s7,40(sp)
    80004b2c:	f062                	sd	s8,32(sp)
    80004b2e:	ec66                	sd	s9,24(sp)
    80004b30:	e86a                	sd	s10,16(sp)
    80004b32:	e46e                	sd	s11,8(sp)
    80004b34:	1880                	addi	s0,sp,112
    80004b36:	8b2a                	mv	s6,a0
    80004b38:	8c2e                	mv	s8,a1
    80004b3a:	8ab2                	mv	s5,a2
    80004b3c:	8936                	mv	s2,a3
    80004b3e:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80004b40:	00e687bb          	addw	a5,a3,a4
    80004b44:	0ed7e263          	bltu	a5,a3,80004c28 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004b48:	00043737          	lui	a4,0x43
    80004b4c:	0ef76063          	bltu	a4,a5,80004c2c <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004b50:	0c0b8863          	beqz	s7,80004c20 <writei+0x10e>
    80004b54:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004b56:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004b5a:	5cfd                	li	s9,-1
    80004b5c:	a091                	j	80004ba0 <writei+0x8e>
    80004b5e:	02099d93          	slli	s11,s3,0x20
    80004b62:	020ddd93          	srli	s11,s11,0x20
    80004b66:	05848793          	addi	a5,s1,88
    80004b6a:	86ee                	mv	a3,s11
    80004b6c:	8656                	mv	a2,s5
    80004b6e:	85e2                	mv	a1,s8
    80004b70:	953e                	add	a0,a0,a5
    80004b72:	ffffe097          	auipc	ra,0xffffe
    80004b76:	e16080e7          	jalr	-490(ra) # 80002988 <either_copyin>
    80004b7a:	07950263          	beq	a0,s9,80004bde <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004b7e:	8526                	mv	a0,s1
    80004b80:	00000097          	auipc	ra,0x0
    80004b84:	792080e7          	jalr	1938(ra) # 80005312 <log_write>
    brelse(bp);
    80004b88:	8526                	mv	a0,s1
    80004b8a:	fffff097          	auipc	ra,0xfffff
    80004b8e:	508080e7          	jalr	1288(ra) # 80004092 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004b92:	01498a3b          	addw	s4,s3,s4
    80004b96:	0129893b          	addw	s2,s3,s2
    80004b9a:	9aee                	add	s5,s5,s11
    80004b9c:	057a7663          	bgeu	s4,s7,80004be8 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004ba0:	000b2483          	lw	s1,0(s6)
    80004ba4:	00a9559b          	srliw	a1,s2,0xa
    80004ba8:	855a                	mv	a0,s6
    80004baa:	fffff097          	auipc	ra,0xfffff
    80004bae:	7ac080e7          	jalr	1964(ra) # 80004356 <bmap>
    80004bb2:	0005059b          	sext.w	a1,a0
    80004bb6:	8526                	mv	a0,s1
    80004bb8:	fffff097          	auipc	ra,0xfffff
    80004bbc:	3aa080e7          	jalr	938(ra) # 80003f62 <bread>
    80004bc0:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004bc2:	3ff97513          	andi	a0,s2,1023
    80004bc6:	40ad07bb          	subw	a5,s10,a0
    80004bca:	414b873b          	subw	a4,s7,s4
    80004bce:	89be                	mv	s3,a5
    80004bd0:	2781                	sext.w	a5,a5
    80004bd2:	0007069b          	sext.w	a3,a4
    80004bd6:	f8f6f4e3          	bgeu	a3,a5,80004b5e <writei+0x4c>
    80004bda:	89ba                	mv	s3,a4
    80004bdc:	b749                	j	80004b5e <writei+0x4c>
      brelse(bp);
    80004bde:	8526                	mv	a0,s1
    80004be0:	fffff097          	auipc	ra,0xfffff
    80004be4:	4b2080e7          	jalr	1202(ra) # 80004092 <brelse>
  }

  if(off > ip->size)
    80004be8:	04cb2783          	lw	a5,76(s6)
    80004bec:	0127f463          	bgeu	a5,s2,80004bf4 <writei+0xe2>
    ip->size = off;
    80004bf0:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004bf4:	855a                	mv	a0,s6
    80004bf6:	00000097          	auipc	ra,0x0
    80004bfa:	aa6080e7          	jalr	-1370(ra) # 8000469c <iupdate>

  return tot;
    80004bfe:	000a051b          	sext.w	a0,s4
}
    80004c02:	70a6                	ld	ra,104(sp)
    80004c04:	7406                	ld	s0,96(sp)
    80004c06:	64e6                	ld	s1,88(sp)
    80004c08:	6946                	ld	s2,80(sp)
    80004c0a:	69a6                	ld	s3,72(sp)
    80004c0c:	6a06                	ld	s4,64(sp)
    80004c0e:	7ae2                	ld	s5,56(sp)
    80004c10:	7b42                	ld	s6,48(sp)
    80004c12:	7ba2                	ld	s7,40(sp)
    80004c14:	7c02                	ld	s8,32(sp)
    80004c16:	6ce2                	ld	s9,24(sp)
    80004c18:	6d42                	ld	s10,16(sp)
    80004c1a:	6da2                	ld	s11,8(sp)
    80004c1c:	6165                	addi	sp,sp,112
    80004c1e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004c20:	8a5e                	mv	s4,s7
    80004c22:	bfc9                	j	80004bf4 <writei+0xe2>
    return -1;
    80004c24:	557d                	li	a0,-1
}
    80004c26:	8082                	ret
    return -1;
    80004c28:	557d                	li	a0,-1
    80004c2a:	bfe1                	j	80004c02 <writei+0xf0>
    return -1;
    80004c2c:	557d                	li	a0,-1
    80004c2e:	bfd1                	j	80004c02 <writei+0xf0>

0000000080004c30 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004c30:	1141                	addi	sp,sp,-16
    80004c32:	e406                	sd	ra,8(sp)
    80004c34:	e022                	sd	s0,0(sp)
    80004c36:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004c38:	4639                	li	a2,14
    80004c3a:	ffffc097          	auipc	ra,0xffffc
    80004c3e:	182080e7          	jalr	386(ra) # 80000dbc <strncmp>
}
    80004c42:	60a2                	ld	ra,8(sp)
    80004c44:	6402                	ld	s0,0(sp)
    80004c46:	0141                	addi	sp,sp,16
    80004c48:	8082                	ret

0000000080004c4a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004c4a:	7139                	addi	sp,sp,-64
    80004c4c:	fc06                	sd	ra,56(sp)
    80004c4e:	f822                	sd	s0,48(sp)
    80004c50:	f426                	sd	s1,40(sp)
    80004c52:	f04a                	sd	s2,32(sp)
    80004c54:	ec4e                	sd	s3,24(sp)
    80004c56:	e852                	sd	s4,16(sp)
    80004c58:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004c5a:	04451703          	lh	a4,68(a0)
    80004c5e:	4785                	li	a5,1
    80004c60:	00f71a63          	bne	a4,a5,80004c74 <dirlookup+0x2a>
    80004c64:	892a                	mv	s2,a0
    80004c66:	89ae                	mv	s3,a1
    80004c68:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004c6a:	457c                	lw	a5,76(a0)
    80004c6c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004c6e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004c70:	e79d                	bnez	a5,80004c9e <dirlookup+0x54>
    80004c72:	a8a5                	j	80004cea <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004c74:	00005517          	auipc	a0,0x5
    80004c78:	ad450513          	addi	a0,a0,-1324 # 80009748 <syscalls+0x1d8>
    80004c7c:	ffffc097          	auipc	ra,0xffffc
    80004c80:	8b2080e7          	jalr	-1870(ra) # 8000052e <panic>
      panic("dirlookup read");
    80004c84:	00005517          	auipc	a0,0x5
    80004c88:	adc50513          	addi	a0,a0,-1316 # 80009760 <syscalls+0x1f0>
    80004c8c:	ffffc097          	auipc	ra,0xffffc
    80004c90:	8a2080e7          	jalr	-1886(ra) # 8000052e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004c94:	24c1                	addiw	s1,s1,16
    80004c96:	04c92783          	lw	a5,76(s2)
    80004c9a:	04f4f763          	bgeu	s1,a5,80004ce8 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004c9e:	4741                	li	a4,16
    80004ca0:	86a6                	mv	a3,s1
    80004ca2:	fc040613          	addi	a2,s0,-64
    80004ca6:	4581                	li	a1,0
    80004ca8:	854a                	mv	a0,s2
    80004caa:	00000097          	auipc	ra,0x0
    80004cae:	d70080e7          	jalr	-656(ra) # 80004a1a <readi>
    80004cb2:	47c1                	li	a5,16
    80004cb4:	fcf518e3          	bne	a0,a5,80004c84 <dirlookup+0x3a>
    if(de.inum == 0)
    80004cb8:	fc045783          	lhu	a5,-64(s0)
    80004cbc:	dfe1                	beqz	a5,80004c94 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004cbe:	fc240593          	addi	a1,s0,-62
    80004cc2:	854e                	mv	a0,s3
    80004cc4:	00000097          	auipc	ra,0x0
    80004cc8:	f6c080e7          	jalr	-148(ra) # 80004c30 <namecmp>
    80004ccc:	f561                	bnez	a0,80004c94 <dirlookup+0x4a>
      if(poff)
    80004cce:	000a0463          	beqz	s4,80004cd6 <dirlookup+0x8c>
        *poff = off;
    80004cd2:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004cd6:	fc045583          	lhu	a1,-64(s0)
    80004cda:	00092503          	lw	a0,0(s2)
    80004cde:	fffff097          	auipc	ra,0xfffff
    80004ce2:	754080e7          	jalr	1876(ra) # 80004432 <iget>
    80004ce6:	a011                	j	80004cea <dirlookup+0xa0>
  return 0;
    80004ce8:	4501                	li	a0,0
}
    80004cea:	70e2                	ld	ra,56(sp)
    80004cec:	7442                	ld	s0,48(sp)
    80004cee:	74a2                	ld	s1,40(sp)
    80004cf0:	7902                	ld	s2,32(sp)
    80004cf2:	69e2                	ld	s3,24(sp)
    80004cf4:	6a42                	ld	s4,16(sp)
    80004cf6:	6121                	addi	sp,sp,64
    80004cf8:	8082                	ret

0000000080004cfa <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004cfa:	711d                	addi	sp,sp,-96
    80004cfc:	ec86                	sd	ra,88(sp)
    80004cfe:	e8a2                	sd	s0,80(sp)
    80004d00:	e4a6                	sd	s1,72(sp)
    80004d02:	e0ca                	sd	s2,64(sp)
    80004d04:	fc4e                	sd	s3,56(sp)
    80004d06:	f852                	sd	s4,48(sp)
    80004d08:	f456                	sd	s5,40(sp)
    80004d0a:	f05a                	sd	s6,32(sp)
    80004d0c:	ec5e                	sd	s7,24(sp)
    80004d0e:	e862                	sd	s8,16(sp)
    80004d10:	e466                	sd	s9,8(sp)
    80004d12:	1080                	addi	s0,sp,96
    80004d14:	84aa                	mv	s1,a0
    80004d16:	8aae                	mv	s5,a1
    80004d18:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004d1a:	00054703          	lbu	a4,0(a0)
    80004d1e:	02f00793          	li	a5,47
    80004d22:	02f70263          	beq	a4,a5,80004d46 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004d26:	ffffd097          	auipc	ra,0xffffd
    80004d2a:	d56080e7          	jalr	-682(ra) # 80001a7c <myproc>
    80004d2e:	6968                	ld	a0,208(a0)
    80004d30:	00000097          	auipc	ra,0x0
    80004d34:	9f8080e7          	jalr	-1544(ra) # 80004728 <idup>
    80004d38:	89aa                	mv	s3,a0
  while(*path == '/')
    80004d3a:	02f00913          	li	s2,47
  len = path - s;
    80004d3e:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004d40:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004d42:	4b85                	li	s7,1
    80004d44:	a865                	j	80004dfc <namex+0x102>
    ip = iget(ROOTDEV, ROOTINO);
    80004d46:	4585                	li	a1,1
    80004d48:	4505                	li	a0,1
    80004d4a:	fffff097          	auipc	ra,0xfffff
    80004d4e:	6e8080e7          	jalr	1768(ra) # 80004432 <iget>
    80004d52:	89aa                	mv	s3,a0
    80004d54:	b7dd                	j	80004d3a <namex+0x40>
      iunlockput(ip);
    80004d56:	854e                	mv	a0,s3
    80004d58:	00000097          	auipc	ra,0x0
    80004d5c:	c70080e7          	jalr	-912(ra) # 800049c8 <iunlockput>
      return 0;
    80004d60:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004d62:	854e                	mv	a0,s3
    80004d64:	60e6                	ld	ra,88(sp)
    80004d66:	6446                	ld	s0,80(sp)
    80004d68:	64a6                	ld	s1,72(sp)
    80004d6a:	6906                	ld	s2,64(sp)
    80004d6c:	79e2                	ld	s3,56(sp)
    80004d6e:	7a42                	ld	s4,48(sp)
    80004d70:	7aa2                	ld	s5,40(sp)
    80004d72:	7b02                	ld	s6,32(sp)
    80004d74:	6be2                	ld	s7,24(sp)
    80004d76:	6c42                	ld	s8,16(sp)
    80004d78:	6ca2                	ld	s9,8(sp)
    80004d7a:	6125                	addi	sp,sp,96
    80004d7c:	8082                	ret
      iunlock(ip);
    80004d7e:	854e                	mv	a0,s3
    80004d80:	00000097          	auipc	ra,0x0
    80004d84:	aa8080e7          	jalr	-1368(ra) # 80004828 <iunlock>
      return ip;
    80004d88:	bfe9                	j	80004d62 <namex+0x68>
      iunlockput(ip);
    80004d8a:	854e                	mv	a0,s3
    80004d8c:	00000097          	auipc	ra,0x0
    80004d90:	c3c080e7          	jalr	-964(ra) # 800049c8 <iunlockput>
      return 0;
    80004d94:	89e6                	mv	s3,s9
    80004d96:	b7f1                	j	80004d62 <namex+0x68>
  len = path - s;
    80004d98:	40b48633          	sub	a2,s1,a1
    80004d9c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004da0:	099c5463          	bge	s8,s9,80004e28 <namex+0x12e>
    memmove(name, s, DIRSIZ);
    80004da4:	4639                	li	a2,14
    80004da6:	8552                	mv	a0,s4
    80004da8:	ffffc097          	auipc	ra,0xffffc
    80004dac:	f98080e7          	jalr	-104(ra) # 80000d40 <memmove>
  while(*path == '/')
    80004db0:	0004c783          	lbu	a5,0(s1)
    80004db4:	01279763          	bne	a5,s2,80004dc2 <namex+0xc8>
    path++;
    80004db8:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004dba:	0004c783          	lbu	a5,0(s1)
    80004dbe:	ff278de3          	beq	a5,s2,80004db8 <namex+0xbe>
    ilock(ip);
    80004dc2:	854e                	mv	a0,s3
    80004dc4:	00000097          	auipc	ra,0x0
    80004dc8:	9a2080e7          	jalr	-1630(ra) # 80004766 <ilock>
    if(ip->type != T_DIR){
    80004dcc:	04499783          	lh	a5,68(s3)
    80004dd0:	f97793e3          	bne	a5,s7,80004d56 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004dd4:	000a8563          	beqz	s5,80004dde <namex+0xe4>
    80004dd8:	0004c783          	lbu	a5,0(s1)
    80004ddc:	d3cd                	beqz	a5,80004d7e <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004dde:	865a                	mv	a2,s6
    80004de0:	85d2                	mv	a1,s4
    80004de2:	854e                	mv	a0,s3
    80004de4:	00000097          	auipc	ra,0x0
    80004de8:	e66080e7          	jalr	-410(ra) # 80004c4a <dirlookup>
    80004dec:	8caa                	mv	s9,a0
    80004dee:	dd51                	beqz	a0,80004d8a <namex+0x90>
    iunlockput(ip);
    80004df0:	854e                	mv	a0,s3
    80004df2:	00000097          	auipc	ra,0x0
    80004df6:	bd6080e7          	jalr	-1066(ra) # 800049c8 <iunlockput>
    ip = next;
    80004dfa:	89e6                	mv	s3,s9
  while(*path == '/')
    80004dfc:	0004c783          	lbu	a5,0(s1)
    80004e00:	05279763          	bne	a5,s2,80004e4e <namex+0x154>
    path++;
    80004e04:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004e06:	0004c783          	lbu	a5,0(s1)
    80004e0a:	ff278de3          	beq	a5,s2,80004e04 <namex+0x10a>
  if(*path == 0)
    80004e0e:	c79d                	beqz	a5,80004e3c <namex+0x142>
    path++;
    80004e10:	85a6                	mv	a1,s1
  len = path - s;
    80004e12:	8cda                	mv	s9,s6
    80004e14:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004e16:	01278963          	beq	a5,s2,80004e28 <namex+0x12e>
    80004e1a:	dfbd                	beqz	a5,80004d98 <namex+0x9e>
    path++;
    80004e1c:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004e1e:	0004c783          	lbu	a5,0(s1)
    80004e22:	ff279ce3          	bne	a5,s2,80004e1a <namex+0x120>
    80004e26:	bf8d                	j	80004d98 <namex+0x9e>
    memmove(name, s, len);
    80004e28:	2601                	sext.w	a2,a2
    80004e2a:	8552                	mv	a0,s4
    80004e2c:	ffffc097          	auipc	ra,0xffffc
    80004e30:	f14080e7          	jalr	-236(ra) # 80000d40 <memmove>
    name[len] = 0;
    80004e34:	9cd2                	add	s9,s9,s4
    80004e36:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004e3a:	bf9d                	j	80004db0 <namex+0xb6>
  if(nameiparent){
    80004e3c:	f20a83e3          	beqz	s5,80004d62 <namex+0x68>
    iput(ip);
    80004e40:	854e                	mv	a0,s3
    80004e42:	00000097          	auipc	ra,0x0
    80004e46:	ade080e7          	jalr	-1314(ra) # 80004920 <iput>
    return 0;
    80004e4a:	4981                	li	s3,0
    80004e4c:	bf19                	j	80004d62 <namex+0x68>
  if(*path == 0)
    80004e4e:	d7fd                	beqz	a5,80004e3c <namex+0x142>
  while(*path != '/' && *path != 0)
    80004e50:	0004c783          	lbu	a5,0(s1)
    80004e54:	85a6                	mv	a1,s1
    80004e56:	b7d1                	j	80004e1a <namex+0x120>

0000000080004e58 <dirlink>:
{
    80004e58:	7139                	addi	sp,sp,-64
    80004e5a:	fc06                	sd	ra,56(sp)
    80004e5c:	f822                	sd	s0,48(sp)
    80004e5e:	f426                	sd	s1,40(sp)
    80004e60:	f04a                	sd	s2,32(sp)
    80004e62:	ec4e                	sd	s3,24(sp)
    80004e64:	e852                	sd	s4,16(sp)
    80004e66:	0080                	addi	s0,sp,64
    80004e68:	892a                	mv	s2,a0
    80004e6a:	8a2e                	mv	s4,a1
    80004e6c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004e6e:	4601                	li	a2,0
    80004e70:	00000097          	auipc	ra,0x0
    80004e74:	dda080e7          	jalr	-550(ra) # 80004c4a <dirlookup>
    80004e78:	e93d                	bnez	a0,80004eee <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004e7a:	04c92483          	lw	s1,76(s2)
    80004e7e:	c49d                	beqz	s1,80004eac <dirlink+0x54>
    80004e80:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004e82:	4741                	li	a4,16
    80004e84:	86a6                	mv	a3,s1
    80004e86:	fc040613          	addi	a2,s0,-64
    80004e8a:	4581                	li	a1,0
    80004e8c:	854a                	mv	a0,s2
    80004e8e:	00000097          	auipc	ra,0x0
    80004e92:	b8c080e7          	jalr	-1140(ra) # 80004a1a <readi>
    80004e96:	47c1                	li	a5,16
    80004e98:	06f51163          	bne	a0,a5,80004efa <dirlink+0xa2>
    if(de.inum == 0)
    80004e9c:	fc045783          	lhu	a5,-64(s0)
    80004ea0:	c791                	beqz	a5,80004eac <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004ea2:	24c1                	addiw	s1,s1,16
    80004ea4:	04c92783          	lw	a5,76(s2)
    80004ea8:	fcf4ede3          	bltu	s1,a5,80004e82 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004eac:	4639                	li	a2,14
    80004eae:	85d2                	mv	a1,s4
    80004eb0:	fc240513          	addi	a0,s0,-62
    80004eb4:	ffffc097          	auipc	ra,0xffffc
    80004eb8:	f44080e7          	jalr	-188(ra) # 80000df8 <strncpy>
  de.inum = inum;
    80004ebc:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ec0:	4741                	li	a4,16
    80004ec2:	86a6                	mv	a3,s1
    80004ec4:	fc040613          	addi	a2,s0,-64
    80004ec8:	4581                	li	a1,0
    80004eca:	854a                	mv	a0,s2
    80004ecc:	00000097          	auipc	ra,0x0
    80004ed0:	c46080e7          	jalr	-954(ra) # 80004b12 <writei>
    80004ed4:	872a                	mv	a4,a0
    80004ed6:	47c1                	li	a5,16
  return 0;
    80004ed8:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004eda:	02f71863          	bne	a4,a5,80004f0a <dirlink+0xb2>
}
    80004ede:	70e2                	ld	ra,56(sp)
    80004ee0:	7442                	ld	s0,48(sp)
    80004ee2:	74a2                	ld	s1,40(sp)
    80004ee4:	7902                	ld	s2,32(sp)
    80004ee6:	69e2                	ld	s3,24(sp)
    80004ee8:	6a42                	ld	s4,16(sp)
    80004eea:	6121                	addi	sp,sp,64
    80004eec:	8082                	ret
    iput(ip);
    80004eee:	00000097          	auipc	ra,0x0
    80004ef2:	a32080e7          	jalr	-1486(ra) # 80004920 <iput>
    return -1;
    80004ef6:	557d                	li	a0,-1
    80004ef8:	b7dd                	j	80004ede <dirlink+0x86>
      panic("dirlink read");
    80004efa:	00005517          	auipc	a0,0x5
    80004efe:	87650513          	addi	a0,a0,-1930 # 80009770 <syscalls+0x200>
    80004f02:	ffffb097          	auipc	ra,0xffffb
    80004f06:	62c080e7          	jalr	1580(ra) # 8000052e <panic>
    panic("dirlink");
    80004f0a:	00005517          	auipc	a0,0x5
    80004f0e:	97650513          	addi	a0,a0,-1674 # 80009880 <syscalls+0x310>
    80004f12:	ffffb097          	auipc	ra,0xffffb
    80004f16:	61c080e7          	jalr	1564(ra) # 8000052e <panic>

0000000080004f1a <namei>:

struct inode*
namei(char *path)
{
    80004f1a:	1101                	addi	sp,sp,-32
    80004f1c:	ec06                	sd	ra,24(sp)
    80004f1e:	e822                	sd	s0,16(sp)
    80004f20:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004f22:	fe040613          	addi	a2,s0,-32
    80004f26:	4581                	li	a1,0
    80004f28:	00000097          	auipc	ra,0x0
    80004f2c:	dd2080e7          	jalr	-558(ra) # 80004cfa <namex>
}
    80004f30:	60e2                	ld	ra,24(sp)
    80004f32:	6442                	ld	s0,16(sp)
    80004f34:	6105                	addi	sp,sp,32
    80004f36:	8082                	ret

0000000080004f38 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004f38:	1141                	addi	sp,sp,-16
    80004f3a:	e406                	sd	ra,8(sp)
    80004f3c:	e022                	sd	s0,0(sp)
    80004f3e:	0800                	addi	s0,sp,16
    80004f40:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004f42:	4585                	li	a1,1
    80004f44:	00000097          	auipc	ra,0x0
    80004f48:	db6080e7          	jalr	-586(ra) # 80004cfa <namex>
}
    80004f4c:	60a2                	ld	ra,8(sp)
    80004f4e:	6402                	ld	s0,0(sp)
    80004f50:	0141                	addi	sp,sp,16
    80004f52:	8082                	ret

0000000080004f54 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004f54:	1101                	addi	sp,sp,-32
    80004f56:	ec06                	sd	ra,24(sp)
    80004f58:	e822                	sd	s0,16(sp)
    80004f5a:	e426                	sd	s1,8(sp)
    80004f5c:	e04a                	sd	s2,0(sp)
    80004f5e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004f60:	00039917          	auipc	s2,0x39
    80004f64:	b6890913          	addi	s2,s2,-1176 # 8003dac8 <log>
    80004f68:	01892583          	lw	a1,24(s2)
    80004f6c:	02892503          	lw	a0,40(s2)
    80004f70:	fffff097          	auipc	ra,0xfffff
    80004f74:	ff2080e7          	jalr	-14(ra) # 80003f62 <bread>
    80004f78:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004f7a:	02c92683          	lw	a3,44(s2)
    80004f7e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004f80:	02d05863          	blez	a3,80004fb0 <write_head+0x5c>
    80004f84:	00039797          	auipc	a5,0x39
    80004f88:	b7478793          	addi	a5,a5,-1164 # 8003daf8 <log+0x30>
    80004f8c:	05c50713          	addi	a4,a0,92
    80004f90:	36fd                	addiw	a3,a3,-1
    80004f92:	02069613          	slli	a2,a3,0x20
    80004f96:	01e65693          	srli	a3,a2,0x1e
    80004f9a:	00039617          	auipc	a2,0x39
    80004f9e:	b6260613          	addi	a2,a2,-1182 # 8003dafc <log+0x34>
    80004fa2:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004fa4:	4390                	lw	a2,0(a5)
    80004fa6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004fa8:	0791                	addi	a5,a5,4
    80004faa:	0711                	addi	a4,a4,4
    80004fac:	fed79ce3          	bne	a5,a3,80004fa4 <write_head+0x50>
  }
  bwrite(buf);
    80004fb0:	8526                	mv	a0,s1
    80004fb2:	fffff097          	auipc	ra,0xfffff
    80004fb6:	0a2080e7          	jalr	162(ra) # 80004054 <bwrite>
  brelse(buf);
    80004fba:	8526                	mv	a0,s1
    80004fbc:	fffff097          	auipc	ra,0xfffff
    80004fc0:	0d6080e7          	jalr	214(ra) # 80004092 <brelse>
}
    80004fc4:	60e2                	ld	ra,24(sp)
    80004fc6:	6442                	ld	s0,16(sp)
    80004fc8:	64a2                	ld	s1,8(sp)
    80004fca:	6902                	ld	s2,0(sp)
    80004fcc:	6105                	addi	sp,sp,32
    80004fce:	8082                	ret

0000000080004fd0 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004fd0:	00039797          	auipc	a5,0x39
    80004fd4:	b247a783          	lw	a5,-1244(a5) # 8003daf4 <log+0x2c>
    80004fd8:	0af05d63          	blez	a5,80005092 <install_trans+0xc2>
{
    80004fdc:	7139                	addi	sp,sp,-64
    80004fde:	fc06                	sd	ra,56(sp)
    80004fe0:	f822                	sd	s0,48(sp)
    80004fe2:	f426                	sd	s1,40(sp)
    80004fe4:	f04a                	sd	s2,32(sp)
    80004fe6:	ec4e                	sd	s3,24(sp)
    80004fe8:	e852                	sd	s4,16(sp)
    80004fea:	e456                	sd	s5,8(sp)
    80004fec:	e05a                	sd	s6,0(sp)
    80004fee:	0080                	addi	s0,sp,64
    80004ff0:	8b2a                	mv	s6,a0
    80004ff2:	00039a97          	auipc	s5,0x39
    80004ff6:	b06a8a93          	addi	s5,s5,-1274 # 8003daf8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004ffa:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004ffc:	00039997          	auipc	s3,0x39
    80005000:	acc98993          	addi	s3,s3,-1332 # 8003dac8 <log>
    80005004:	a00d                	j	80005026 <install_trans+0x56>
    brelse(lbuf);
    80005006:	854a                	mv	a0,s2
    80005008:	fffff097          	auipc	ra,0xfffff
    8000500c:	08a080e7          	jalr	138(ra) # 80004092 <brelse>
    brelse(dbuf);
    80005010:	8526                	mv	a0,s1
    80005012:	fffff097          	auipc	ra,0xfffff
    80005016:	080080e7          	jalr	128(ra) # 80004092 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000501a:	2a05                	addiw	s4,s4,1
    8000501c:	0a91                	addi	s5,s5,4
    8000501e:	02c9a783          	lw	a5,44(s3)
    80005022:	04fa5e63          	bge	s4,a5,8000507e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80005026:	0189a583          	lw	a1,24(s3)
    8000502a:	014585bb          	addw	a1,a1,s4
    8000502e:	2585                	addiw	a1,a1,1
    80005030:	0289a503          	lw	a0,40(s3)
    80005034:	fffff097          	auipc	ra,0xfffff
    80005038:	f2e080e7          	jalr	-210(ra) # 80003f62 <bread>
    8000503c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000503e:	000aa583          	lw	a1,0(s5)
    80005042:	0289a503          	lw	a0,40(s3)
    80005046:	fffff097          	auipc	ra,0xfffff
    8000504a:	f1c080e7          	jalr	-228(ra) # 80003f62 <bread>
    8000504e:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80005050:	40000613          	li	a2,1024
    80005054:	05890593          	addi	a1,s2,88
    80005058:	05850513          	addi	a0,a0,88
    8000505c:	ffffc097          	auipc	ra,0xffffc
    80005060:	ce4080e7          	jalr	-796(ra) # 80000d40 <memmove>
    bwrite(dbuf);  // write dst to disk
    80005064:	8526                	mv	a0,s1
    80005066:	fffff097          	auipc	ra,0xfffff
    8000506a:	fee080e7          	jalr	-18(ra) # 80004054 <bwrite>
    if(recovering == 0)
    8000506e:	f80b1ce3          	bnez	s6,80005006 <install_trans+0x36>
      bunpin(dbuf);
    80005072:	8526                	mv	a0,s1
    80005074:	fffff097          	auipc	ra,0xfffff
    80005078:	0f8080e7          	jalr	248(ra) # 8000416c <bunpin>
    8000507c:	b769                	j	80005006 <install_trans+0x36>
}
    8000507e:	70e2                	ld	ra,56(sp)
    80005080:	7442                	ld	s0,48(sp)
    80005082:	74a2                	ld	s1,40(sp)
    80005084:	7902                	ld	s2,32(sp)
    80005086:	69e2                	ld	s3,24(sp)
    80005088:	6a42                	ld	s4,16(sp)
    8000508a:	6aa2                	ld	s5,8(sp)
    8000508c:	6b02                	ld	s6,0(sp)
    8000508e:	6121                	addi	sp,sp,64
    80005090:	8082                	ret
    80005092:	8082                	ret

0000000080005094 <initlog>:
{
    80005094:	7179                	addi	sp,sp,-48
    80005096:	f406                	sd	ra,40(sp)
    80005098:	f022                	sd	s0,32(sp)
    8000509a:	ec26                	sd	s1,24(sp)
    8000509c:	e84a                	sd	s2,16(sp)
    8000509e:	e44e                	sd	s3,8(sp)
    800050a0:	1800                	addi	s0,sp,48
    800050a2:	892a                	mv	s2,a0
    800050a4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800050a6:	00039497          	auipc	s1,0x39
    800050aa:	a2248493          	addi	s1,s1,-1502 # 8003dac8 <log>
    800050ae:	00004597          	auipc	a1,0x4
    800050b2:	6d258593          	addi	a1,a1,1746 # 80009780 <syscalls+0x210>
    800050b6:	8526                	mv	a0,s1
    800050b8:	ffffc097          	auipc	ra,0xffffc
    800050bc:	a7e080e7          	jalr	-1410(ra) # 80000b36 <initlock>
  log.start = sb->logstart;
    800050c0:	0149a583          	lw	a1,20(s3)
    800050c4:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800050c6:	0109a783          	lw	a5,16(s3)
    800050ca:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800050cc:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800050d0:	854a                	mv	a0,s2
    800050d2:	fffff097          	auipc	ra,0xfffff
    800050d6:	e90080e7          	jalr	-368(ra) # 80003f62 <bread>
  log.lh.n = lh->n;
    800050da:	4d34                	lw	a3,88(a0)
    800050dc:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800050de:	02d05663          	blez	a3,8000510a <initlog+0x76>
    800050e2:	05c50793          	addi	a5,a0,92
    800050e6:	00039717          	auipc	a4,0x39
    800050ea:	a1270713          	addi	a4,a4,-1518 # 8003daf8 <log+0x30>
    800050ee:	36fd                	addiw	a3,a3,-1
    800050f0:	02069613          	slli	a2,a3,0x20
    800050f4:	01e65693          	srli	a3,a2,0x1e
    800050f8:	06050613          	addi	a2,a0,96
    800050fc:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800050fe:	4390                	lw	a2,0(a5)
    80005100:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80005102:	0791                	addi	a5,a5,4
    80005104:	0711                	addi	a4,a4,4
    80005106:	fed79ce3          	bne	a5,a3,800050fe <initlog+0x6a>
  brelse(buf);
    8000510a:	fffff097          	auipc	ra,0xfffff
    8000510e:	f88080e7          	jalr	-120(ra) # 80004092 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80005112:	4505                	li	a0,1
    80005114:	00000097          	auipc	ra,0x0
    80005118:	ebc080e7          	jalr	-324(ra) # 80004fd0 <install_trans>
  log.lh.n = 0;
    8000511c:	00039797          	auipc	a5,0x39
    80005120:	9c07ac23          	sw	zero,-1576(a5) # 8003daf4 <log+0x2c>
  write_head(); // clear the log
    80005124:	00000097          	auipc	ra,0x0
    80005128:	e30080e7          	jalr	-464(ra) # 80004f54 <write_head>
}
    8000512c:	70a2                	ld	ra,40(sp)
    8000512e:	7402                	ld	s0,32(sp)
    80005130:	64e2                	ld	s1,24(sp)
    80005132:	6942                	ld	s2,16(sp)
    80005134:	69a2                	ld	s3,8(sp)
    80005136:	6145                	addi	sp,sp,48
    80005138:	8082                	ret

000000008000513a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000513a:	1101                	addi	sp,sp,-32
    8000513c:	ec06                	sd	ra,24(sp)
    8000513e:	e822                	sd	s0,16(sp)
    80005140:	e426                	sd	s1,8(sp)
    80005142:	e04a                	sd	s2,0(sp)
    80005144:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80005146:	00039517          	auipc	a0,0x39
    8000514a:	98250513          	addi	a0,a0,-1662 # 8003dac8 <log>
    8000514e:	ffffc097          	auipc	ra,0xffffc
    80005152:	a78080e7          	jalr	-1416(ra) # 80000bc6 <acquire>
  while(1){
    if(log.committing){
    80005156:	00039497          	auipc	s1,0x39
    8000515a:	97248493          	addi	s1,s1,-1678 # 8003dac8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000515e:	4979                	li	s2,30
    80005160:	a039                	j	8000516e <begin_op+0x34>
      sleep(&log, &log.lock);
    80005162:	85a6                	mv	a1,s1
    80005164:	8526                	mv	a0,s1
    80005166:	ffffd097          	auipc	ra,0xffffd
    8000516a:	28c080e7          	jalr	652(ra) # 800023f2 <sleep>
    if(log.committing){
    8000516e:	50dc                	lw	a5,36(s1)
    80005170:	fbed                	bnez	a5,80005162 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80005172:	509c                	lw	a5,32(s1)
    80005174:	0017871b          	addiw	a4,a5,1
    80005178:	0007069b          	sext.w	a3,a4
    8000517c:	0027179b          	slliw	a5,a4,0x2
    80005180:	9fb9                	addw	a5,a5,a4
    80005182:	0017979b          	slliw	a5,a5,0x1
    80005186:	54d8                	lw	a4,44(s1)
    80005188:	9fb9                	addw	a5,a5,a4
    8000518a:	00f95963          	bge	s2,a5,8000519c <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000518e:	85a6                	mv	a1,s1
    80005190:	8526                	mv	a0,s1
    80005192:	ffffd097          	auipc	ra,0xffffd
    80005196:	260080e7          	jalr	608(ra) # 800023f2 <sleep>
    8000519a:	bfd1                	j	8000516e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000519c:	00039517          	auipc	a0,0x39
    800051a0:	92c50513          	addi	a0,a0,-1748 # 8003dac8 <log>
    800051a4:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800051a6:	ffffc097          	auipc	ra,0xffffc
    800051aa:	af6080e7          	jalr	-1290(ra) # 80000c9c <release>
      break;
    }
  }
}
    800051ae:	60e2                	ld	ra,24(sp)
    800051b0:	6442                	ld	s0,16(sp)
    800051b2:	64a2                	ld	s1,8(sp)
    800051b4:	6902                	ld	s2,0(sp)
    800051b6:	6105                	addi	sp,sp,32
    800051b8:	8082                	ret

00000000800051ba <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800051ba:	7139                	addi	sp,sp,-64
    800051bc:	fc06                	sd	ra,56(sp)
    800051be:	f822                	sd	s0,48(sp)
    800051c0:	f426                	sd	s1,40(sp)
    800051c2:	f04a                	sd	s2,32(sp)
    800051c4:	ec4e                	sd	s3,24(sp)
    800051c6:	e852                	sd	s4,16(sp)
    800051c8:	e456                	sd	s5,8(sp)
    800051ca:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800051cc:	00039497          	auipc	s1,0x39
    800051d0:	8fc48493          	addi	s1,s1,-1796 # 8003dac8 <log>
    800051d4:	8526                	mv	a0,s1
    800051d6:	ffffc097          	auipc	ra,0xffffc
    800051da:	9f0080e7          	jalr	-1552(ra) # 80000bc6 <acquire>
  log.outstanding -= 1;
    800051de:	509c                	lw	a5,32(s1)
    800051e0:	37fd                	addiw	a5,a5,-1
    800051e2:	0007891b          	sext.w	s2,a5
    800051e6:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800051e8:	50dc                	lw	a5,36(s1)
    800051ea:	e7b9                	bnez	a5,80005238 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800051ec:	04091e63          	bnez	s2,80005248 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800051f0:	00039497          	auipc	s1,0x39
    800051f4:	8d848493          	addi	s1,s1,-1832 # 8003dac8 <log>
    800051f8:	4785                	li	a5,1
    800051fa:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800051fc:	8526                	mv	a0,s1
    800051fe:	ffffc097          	auipc	ra,0xffffc
    80005202:	a9e080e7          	jalr	-1378(ra) # 80000c9c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80005206:	54dc                	lw	a5,44(s1)
    80005208:	06f04763          	bgtz	a5,80005276 <end_op+0xbc>
    acquire(&log.lock);
    8000520c:	00039497          	auipc	s1,0x39
    80005210:	8bc48493          	addi	s1,s1,-1860 # 8003dac8 <log>
    80005214:	8526                	mv	a0,s1
    80005216:	ffffc097          	auipc	ra,0xffffc
    8000521a:	9b0080e7          	jalr	-1616(ra) # 80000bc6 <acquire>
    log.committing = 0;
    8000521e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80005222:	8526                	mv	a0,s1
    80005224:	ffffd097          	auipc	ra,0xffffd
    80005228:	358080e7          	jalr	856(ra) # 8000257c <wakeup>
    release(&log.lock);
    8000522c:	8526                	mv	a0,s1
    8000522e:	ffffc097          	auipc	ra,0xffffc
    80005232:	a6e080e7          	jalr	-1426(ra) # 80000c9c <release>
}
    80005236:	a03d                	j	80005264 <end_op+0xaa>
    panic("log.committing");
    80005238:	00004517          	auipc	a0,0x4
    8000523c:	55050513          	addi	a0,a0,1360 # 80009788 <syscalls+0x218>
    80005240:	ffffb097          	auipc	ra,0xffffb
    80005244:	2ee080e7          	jalr	750(ra) # 8000052e <panic>
    wakeup(&log);
    80005248:	00039497          	auipc	s1,0x39
    8000524c:	88048493          	addi	s1,s1,-1920 # 8003dac8 <log>
    80005250:	8526                	mv	a0,s1
    80005252:	ffffd097          	auipc	ra,0xffffd
    80005256:	32a080e7          	jalr	810(ra) # 8000257c <wakeup>
  release(&log.lock);
    8000525a:	8526                	mv	a0,s1
    8000525c:	ffffc097          	auipc	ra,0xffffc
    80005260:	a40080e7          	jalr	-1472(ra) # 80000c9c <release>
}
    80005264:	70e2                	ld	ra,56(sp)
    80005266:	7442                	ld	s0,48(sp)
    80005268:	74a2                	ld	s1,40(sp)
    8000526a:	7902                	ld	s2,32(sp)
    8000526c:	69e2                	ld	s3,24(sp)
    8000526e:	6a42                	ld	s4,16(sp)
    80005270:	6aa2                	ld	s5,8(sp)
    80005272:	6121                	addi	sp,sp,64
    80005274:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80005276:	00039a97          	auipc	s5,0x39
    8000527a:	882a8a93          	addi	s5,s5,-1918 # 8003daf8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000527e:	00039a17          	auipc	s4,0x39
    80005282:	84aa0a13          	addi	s4,s4,-1974 # 8003dac8 <log>
    80005286:	018a2583          	lw	a1,24(s4)
    8000528a:	012585bb          	addw	a1,a1,s2
    8000528e:	2585                	addiw	a1,a1,1
    80005290:	028a2503          	lw	a0,40(s4)
    80005294:	fffff097          	auipc	ra,0xfffff
    80005298:	cce080e7          	jalr	-818(ra) # 80003f62 <bread>
    8000529c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000529e:	000aa583          	lw	a1,0(s5)
    800052a2:	028a2503          	lw	a0,40(s4)
    800052a6:	fffff097          	auipc	ra,0xfffff
    800052aa:	cbc080e7          	jalr	-836(ra) # 80003f62 <bread>
    800052ae:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800052b0:	40000613          	li	a2,1024
    800052b4:	05850593          	addi	a1,a0,88
    800052b8:	05848513          	addi	a0,s1,88
    800052bc:	ffffc097          	auipc	ra,0xffffc
    800052c0:	a84080e7          	jalr	-1404(ra) # 80000d40 <memmove>
    bwrite(to);  // write the log
    800052c4:	8526                	mv	a0,s1
    800052c6:	fffff097          	auipc	ra,0xfffff
    800052ca:	d8e080e7          	jalr	-626(ra) # 80004054 <bwrite>
    brelse(from);
    800052ce:	854e                	mv	a0,s3
    800052d0:	fffff097          	auipc	ra,0xfffff
    800052d4:	dc2080e7          	jalr	-574(ra) # 80004092 <brelse>
    brelse(to);
    800052d8:	8526                	mv	a0,s1
    800052da:	fffff097          	auipc	ra,0xfffff
    800052de:	db8080e7          	jalr	-584(ra) # 80004092 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800052e2:	2905                	addiw	s2,s2,1
    800052e4:	0a91                	addi	s5,s5,4
    800052e6:	02ca2783          	lw	a5,44(s4)
    800052ea:	f8f94ee3          	blt	s2,a5,80005286 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800052ee:	00000097          	auipc	ra,0x0
    800052f2:	c66080e7          	jalr	-922(ra) # 80004f54 <write_head>
    install_trans(0); // Now install writes to home locations
    800052f6:	4501                	li	a0,0
    800052f8:	00000097          	auipc	ra,0x0
    800052fc:	cd8080e7          	jalr	-808(ra) # 80004fd0 <install_trans>
    log.lh.n = 0;
    80005300:	00038797          	auipc	a5,0x38
    80005304:	7e07aa23          	sw	zero,2036(a5) # 8003daf4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80005308:	00000097          	auipc	ra,0x0
    8000530c:	c4c080e7          	jalr	-948(ra) # 80004f54 <write_head>
    80005310:	bdf5                	j	8000520c <end_op+0x52>

0000000080005312 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80005312:	1101                	addi	sp,sp,-32
    80005314:	ec06                	sd	ra,24(sp)
    80005316:	e822                	sd	s0,16(sp)
    80005318:	e426                	sd	s1,8(sp)
    8000531a:	e04a                	sd	s2,0(sp)
    8000531c:	1000                	addi	s0,sp,32
    8000531e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80005320:	00038917          	auipc	s2,0x38
    80005324:	7a890913          	addi	s2,s2,1960 # 8003dac8 <log>
    80005328:	854a                	mv	a0,s2
    8000532a:	ffffc097          	auipc	ra,0xffffc
    8000532e:	89c080e7          	jalr	-1892(ra) # 80000bc6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80005332:	02c92603          	lw	a2,44(s2)
    80005336:	47f5                	li	a5,29
    80005338:	06c7c563          	blt	a5,a2,800053a2 <log_write+0x90>
    8000533c:	00038797          	auipc	a5,0x38
    80005340:	7a87a783          	lw	a5,1960(a5) # 8003dae4 <log+0x1c>
    80005344:	37fd                	addiw	a5,a5,-1
    80005346:	04f65e63          	bge	a2,a5,800053a2 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000534a:	00038797          	auipc	a5,0x38
    8000534e:	79e7a783          	lw	a5,1950(a5) # 8003dae8 <log+0x20>
    80005352:	06f05063          	blez	a5,800053b2 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80005356:	4781                	li	a5,0
    80005358:	06c05563          	blez	a2,800053c2 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000535c:	44cc                	lw	a1,12(s1)
    8000535e:	00038717          	auipc	a4,0x38
    80005362:	79a70713          	addi	a4,a4,1946 # 8003daf8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80005366:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80005368:	4314                	lw	a3,0(a4)
    8000536a:	04b68c63          	beq	a3,a1,800053c2 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000536e:	2785                	addiw	a5,a5,1
    80005370:	0711                	addi	a4,a4,4
    80005372:	fef61be3          	bne	a2,a5,80005368 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80005376:	0621                	addi	a2,a2,8
    80005378:	060a                	slli	a2,a2,0x2
    8000537a:	00038797          	auipc	a5,0x38
    8000537e:	74e78793          	addi	a5,a5,1870 # 8003dac8 <log>
    80005382:	963e                	add	a2,a2,a5
    80005384:	44dc                	lw	a5,12(s1)
    80005386:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80005388:	8526                	mv	a0,s1
    8000538a:	fffff097          	auipc	ra,0xfffff
    8000538e:	da6080e7          	jalr	-602(ra) # 80004130 <bpin>
    log.lh.n++;
    80005392:	00038717          	auipc	a4,0x38
    80005396:	73670713          	addi	a4,a4,1846 # 8003dac8 <log>
    8000539a:	575c                	lw	a5,44(a4)
    8000539c:	2785                	addiw	a5,a5,1
    8000539e:	d75c                	sw	a5,44(a4)
    800053a0:	a835                	j	800053dc <log_write+0xca>
    panic("too big a transaction");
    800053a2:	00004517          	auipc	a0,0x4
    800053a6:	3f650513          	addi	a0,a0,1014 # 80009798 <syscalls+0x228>
    800053aa:	ffffb097          	auipc	ra,0xffffb
    800053ae:	184080e7          	jalr	388(ra) # 8000052e <panic>
    panic("log_write outside of trans");
    800053b2:	00004517          	auipc	a0,0x4
    800053b6:	3fe50513          	addi	a0,a0,1022 # 800097b0 <syscalls+0x240>
    800053ba:	ffffb097          	auipc	ra,0xffffb
    800053be:	174080e7          	jalr	372(ra) # 8000052e <panic>
  log.lh.block[i] = b->blockno;
    800053c2:	00878713          	addi	a4,a5,8
    800053c6:	00271693          	slli	a3,a4,0x2
    800053ca:	00038717          	auipc	a4,0x38
    800053ce:	6fe70713          	addi	a4,a4,1790 # 8003dac8 <log>
    800053d2:	9736                	add	a4,a4,a3
    800053d4:	44d4                	lw	a3,12(s1)
    800053d6:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800053d8:	faf608e3          	beq	a2,a5,80005388 <log_write+0x76>
  }
  release(&log.lock);
    800053dc:	00038517          	auipc	a0,0x38
    800053e0:	6ec50513          	addi	a0,a0,1772 # 8003dac8 <log>
    800053e4:	ffffc097          	auipc	ra,0xffffc
    800053e8:	8b8080e7          	jalr	-1864(ra) # 80000c9c <release>
}
    800053ec:	60e2                	ld	ra,24(sp)
    800053ee:	6442                	ld	s0,16(sp)
    800053f0:	64a2                	ld	s1,8(sp)
    800053f2:	6902                	ld	s2,0(sp)
    800053f4:	6105                	addi	sp,sp,32
    800053f6:	8082                	ret

00000000800053f8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800053f8:	1101                	addi	sp,sp,-32
    800053fa:	ec06                	sd	ra,24(sp)
    800053fc:	e822                	sd	s0,16(sp)
    800053fe:	e426                	sd	s1,8(sp)
    80005400:	e04a                	sd	s2,0(sp)
    80005402:	1000                	addi	s0,sp,32
    80005404:	84aa                	mv	s1,a0
    80005406:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80005408:	00004597          	auipc	a1,0x4
    8000540c:	3c858593          	addi	a1,a1,968 # 800097d0 <syscalls+0x260>
    80005410:	0521                	addi	a0,a0,8
    80005412:	ffffb097          	auipc	ra,0xffffb
    80005416:	724080e7          	jalr	1828(ra) # 80000b36 <initlock>
  lk->name = name;
    8000541a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000541e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005422:	0204a423          	sw	zero,40(s1)
}
    80005426:	60e2                	ld	ra,24(sp)
    80005428:	6442                	ld	s0,16(sp)
    8000542a:	64a2                	ld	s1,8(sp)
    8000542c:	6902                	ld	s2,0(sp)
    8000542e:	6105                	addi	sp,sp,32
    80005430:	8082                	ret

0000000080005432 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80005432:	1101                	addi	sp,sp,-32
    80005434:	ec06                	sd	ra,24(sp)
    80005436:	e822                	sd	s0,16(sp)
    80005438:	e426                	sd	s1,8(sp)
    8000543a:	e04a                	sd	s2,0(sp)
    8000543c:	1000                	addi	s0,sp,32
    8000543e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005440:	00850913          	addi	s2,a0,8
    80005444:	854a                	mv	a0,s2
    80005446:	ffffb097          	auipc	ra,0xffffb
    8000544a:	780080e7          	jalr	1920(ra) # 80000bc6 <acquire>
  while (lk->locked) {
    8000544e:	409c                	lw	a5,0(s1)
    80005450:	cb89                	beqz	a5,80005462 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80005452:	85ca                	mv	a1,s2
    80005454:	8526                	mv	a0,s1
    80005456:	ffffd097          	auipc	ra,0xffffd
    8000545a:	f9c080e7          	jalr	-100(ra) # 800023f2 <sleep>
  while (lk->locked) {
    8000545e:	409c                	lw	a5,0(s1)
    80005460:	fbed                	bnez	a5,80005452 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80005462:	4785                	li	a5,1
    80005464:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80005466:	ffffc097          	auipc	ra,0xffffc
    8000546a:	616080e7          	jalr	1558(ra) # 80001a7c <myproc>
    8000546e:	515c                	lw	a5,36(a0)
    80005470:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80005472:	854a                	mv	a0,s2
    80005474:	ffffc097          	auipc	ra,0xffffc
    80005478:	828080e7          	jalr	-2008(ra) # 80000c9c <release>
}
    8000547c:	60e2                	ld	ra,24(sp)
    8000547e:	6442                	ld	s0,16(sp)
    80005480:	64a2                	ld	s1,8(sp)
    80005482:	6902                	ld	s2,0(sp)
    80005484:	6105                	addi	sp,sp,32
    80005486:	8082                	ret

0000000080005488 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005488:	1101                	addi	sp,sp,-32
    8000548a:	ec06                	sd	ra,24(sp)
    8000548c:	e822                	sd	s0,16(sp)
    8000548e:	e426                	sd	s1,8(sp)
    80005490:	e04a                	sd	s2,0(sp)
    80005492:	1000                	addi	s0,sp,32
    80005494:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80005496:	00850913          	addi	s2,a0,8
    8000549a:	854a                	mv	a0,s2
    8000549c:	ffffb097          	auipc	ra,0xffffb
    800054a0:	72a080e7          	jalr	1834(ra) # 80000bc6 <acquire>
  lk->locked = 0;
    800054a4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800054a8:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800054ac:	8526                	mv	a0,s1
    800054ae:	ffffd097          	auipc	ra,0xffffd
    800054b2:	0ce080e7          	jalr	206(ra) # 8000257c <wakeup>
  release(&lk->lk);
    800054b6:	854a                	mv	a0,s2
    800054b8:	ffffb097          	auipc	ra,0xffffb
    800054bc:	7e4080e7          	jalr	2020(ra) # 80000c9c <release>
}
    800054c0:	60e2                	ld	ra,24(sp)
    800054c2:	6442                	ld	s0,16(sp)
    800054c4:	64a2                	ld	s1,8(sp)
    800054c6:	6902                	ld	s2,0(sp)
    800054c8:	6105                	addi	sp,sp,32
    800054ca:	8082                	ret

00000000800054cc <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800054cc:	7179                	addi	sp,sp,-48
    800054ce:	f406                	sd	ra,40(sp)
    800054d0:	f022                	sd	s0,32(sp)
    800054d2:	ec26                	sd	s1,24(sp)
    800054d4:	e84a                	sd	s2,16(sp)
    800054d6:	e44e                	sd	s3,8(sp)
    800054d8:	1800                	addi	s0,sp,48
    800054da:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800054dc:	00850913          	addi	s2,a0,8
    800054e0:	854a                	mv	a0,s2
    800054e2:	ffffb097          	auipc	ra,0xffffb
    800054e6:	6e4080e7          	jalr	1764(ra) # 80000bc6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800054ea:	409c                	lw	a5,0(s1)
    800054ec:	ef99                	bnez	a5,8000550a <holdingsleep+0x3e>
    800054ee:	4481                	li	s1,0
  release(&lk->lk);
    800054f0:	854a                	mv	a0,s2
    800054f2:	ffffb097          	auipc	ra,0xffffb
    800054f6:	7aa080e7          	jalr	1962(ra) # 80000c9c <release>
  return r;
}
    800054fa:	8526                	mv	a0,s1
    800054fc:	70a2                	ld	ra,40(sp)
    800054fe:	7402                	ld	s0,32(sp)
    80005500:	64e2                	ld	s1,24(sp)
    80005502:	6942                	ld	s2,16(sp)
    80005504:	69a2                	ld	s3,8(sp)
    80005506:	6145                	addi	sp,sp,48
    80005508:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000550a:	0284a983          	lw	s3,40(s1)
    8000550e:	ffffc097          	auipc	ra,0xffffc
    80005512:	56e080e7          	jalr	1390(ra) # 80001a7c <myproc>
    80005516:	5144                	lw	s1,36(a0)
    80005518:	413484b3          	sub	s1,s1,s3
    8000551c:	0014b493          	seqz	s1,s1
    80005520:	bfc1                	j	800054f0 <holdingsleep+0x24>

0000000080005522 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80005522:	1141                	addi	sp,sp,-16
    80005524:	e406                	sd	ra,8(sp)
    80005526:	e022                	sd	s0,0(sp)
    80005528:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000552a:	00004597          	auipc	a1,0x4
    8000552e:	2b658593          	addi	a1,a1,694 # 800097e0 <syscalls+0x270>
    80005532:	00038517          	auipc	a0,0x38
    80005536:	6de50513          	addi	a0,a0,1758 # 8003dc10 <ftable>
    8000553a:	ffffb097          	auipc	ra,0xffffb
    8000553e:	5fc080e7          	jalr	1532(ra) # 80000b36 <initlock>
}
    80005542:	60a2                	ld	ra,8(sp)
    80005544:	6402                	ld	s0,0(sp)
    80005546:	0141                	addi	sp,sp,16
    80005548:	8082                	ret

000000008000554a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000554a:	1101                	addi	sp,sp,-32
    8000554c:	ec06                	sd	ra,24(sp)
    8000554e:	e822                	sd	s0,16(sp)
    80005550:	e426                	sd	s1,8(sp)
    80005552:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80005554:	00038517          	auipc	a0,0x38
    80005558:	6bc50513          	addi	a0,a0,1724 # 8003dc10 <ftable>
    8000555c:	ffffb097          	auipc	ra,0xffffb
    80005560:	66a080e7          	jalr	1642(ra) # 80000bc6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005564:	00038497          	auipc	s1,0x38
    80005568:	6c448493          	addi	s1,s1,1732 # 8003dc28 <ftable+0x18>
    8000556c:	00039717          	auipc	a4,0x39
    80005570:	65c70713          	addi	a4,a4,1628 # 8003ebc8 <ftable+0xfb8>
    if(f->ref == 0){
    80005574:	40dc                	lw	a5,4(s1)
    80005576:	cf99                	beqz	a5,80005594 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005578:	02848493          	addi	s1,s1,40
    8000557c:	fee49ce3          	bne	s1,a4,80005574 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005580:	00038517          	auipc	a0,0x38
    80005584:	69050513          	addi	a0,a0,1680 # 8003dc10 <ftable>
    80005588:	ffffb097          	auipc	ra,0xffffb
    8000558c:	714080e7          	jalr	1812(ra) # 80000c9c <release>
  return 0;
    80005590:	4481                	li	s1,0
    80005592:	a819                	j	800055a8 <filealloc+0x5e>
      f->ref = 1;
    80005594:	4785                	li	a5,1
    80005596:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80005598:	00038517          	auipc	a0,0x38
    8000559c:	67850513          	addi	a0,a0,1656 # 8003dc10 <ftable>
    800055a0:	ffffb097          	auipc	ra,0xffffb
    800055a4:	6fc080e7          	jalr	1788(ra) # 80000c9c <release>
}
    800055a8:	8526                	mv	a0,s1
    800055aa:	60e2                	ld	ra,24(sp)
    800055ac:	6442                	ld	s0,16(sp)
    800055ae:	64a2                	ld	s1,8(sp)
    800055b0:	6105                	addi	sp,sp,32
    800055b2:	8082                	ret

00000000800055b4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800055b4:	1101                	addi	sp,sp,-32
    800055b6:	ec06                	sd	ra,24(sp)
    800055b8:	e822                	sd	s0,16(sp)
    800055ba:	e426                	sd	s1,8(sp)
    800055bc:	1000                	addi	s0,sp,32
    800055be:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800055c0:	00038517          	auipc	a0,0x38
    800055c4:	65050513          	addi	a0,a0,1616 # 8003dc10 <ftable>
    800055c8:	ffffb097          	auipc	ra,0xffffb
    800055cc:	5fe080e7          	jalr	1534(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    800055d0:	40dc                	lw	a5,4(s1)
    800055d2:	02f05263          	blez	a5,800055f6 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800055d6:	2785                	addiw	a5,a5,1
    800055d8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800055da:	00038517          	auipc	a0,0x38
    800055de:	63650513          	addi	a0,a0,1590 # 8003dc10 <ftable>
    800055e2:	ffffb097          	auipc	ra,0xffffb
    800055e6:	6ba080e7          	jalr	1722(ra) # 80000c9c <release>
  return f;
}
    800055ea:	8526                	mv	a0,s1
    800055ec:	60e2                	ld	ra,24(sp)
    800055ee:	6442                	ld	s0,16(sp)
    800055f0:	64a2                	ld	s1,8(sp)
    800055f2:	6105                	addi	sp,sp,32
    800055f4:	8082                	ret
    panic("filedup");
    800055f6:	00004517          	auipc	a0,0x4
    800055fa:	1f250513          	addi	a0,a0,498 # 800097e8 <syscalls+0x278>
    800055fe:	ffffb097          	auipc	ra,0xffffb
    80005602:	f30080e7          	jalr	-208(ra) # 8000052e <panic>

0000000080005606 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80005606:	7139                	addi	sp,sp,-64
    80005608:	fc06                	sd	ra,56(sp)
    8000560a:	f822                	sd	s0,48(sp)
    8000560c:	f426                	sd	s1,40(sp)
    8000560e:	f04a                	sd	s2,32(sp)
    80005610:	ec4e                	sd	s3,24(sp)
    80005612:	e852                	sd	s4,16(sp)
    80005614:	e456                	sd	s5,8(sp)
    80005616:	0080                	addi	s0,sp,64
    80005618:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000561a:	00038517          	auipc	a0,0x38
    8000561e:	5f650513          	addi	a0,a0,1526 # 8003dc10 <ftable>
    80005622:	ffffb097          	auipc	ra,0xffffb
    80005626:	5a4080e7          	jalr	1444(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    8000562a:	40dc                	lw	a5,4(s1)
    8000562c:	06f05163          	blez	a5,8000568e <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80005630:	37fd                	addiw	a5,a5,-1
    80005632:	0007871b          	sext.w	a4,a5
    80005636:	c0dc                	sw	a5,4(s1)
    80005638:	06e04363          	bgtz	a4,8000569e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000563c:	0004a903          	lw	s2,0(s1)
    80005640:	0094ca83          	lbu	s5,9(s1)
    80005644:	0104ba03          	ld	s4,16(s1)
    80005648:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000564c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005650:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80005654:	00038517          	auipc	a0,0x38
    80005658:	5bc50513          	addi	a0,a0,1468 # 8003dc10 <ftable>
    8000565c:	ffffb097          	auipc	ra,0xffffb
    80005660:	640080e7          	jalr	1600(ra) # 80000c9c <release>

  if(ff.type == FD_PIPE){
    80005664:	4785                	li	a5,1
    80005666:	04f90d63          	beq	s2,a5,800056c0 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000566a:	3979                	addiw	s2,s2,-2
    8000566c:	4785                	li	a5,1
    8000566e:	0527e063          	bltu	a5,s2,800056ae <fileclose+0xa8>
    begin_op();
    80005672:	00000097          	auipc	ra,0x0
    80005676:	ac8080e7          	jalr	-1336(ra) # 8000513a <begin_op>
    iput(ff.ip);
    8000567a:	854e                	mv	a0,s3
    8000567c:	fffff097          	auipc	ra,0xfffff
    80005680:	2a4080e7          	jalr	676(ra) # 80004920 <iput>
    end_op();
    80005684:	00000097          	auipc	ra,0x0
    80005688:	b36080e7          	jalr	-1226(ra) # 800051ba <end_op>
    8000568c:	a00d                	j	800056ae <fileclose+0xa8>
    panic("fileclose");
    8000568e:	00004517          	auipc	a0,0x4
    80005692:	16250513          	addi	a0,a0,354 # 800097f0 <syscalls+0x280>
    80005696:	ffffb097          	auipc	ra,0xffffb
    8000569a:	e98080e7          	jalr	-360(ra) # 8000052e <panic>
    release(&ftable.lock);
    8000569e:	00038517          	auipc	a0,0x38
    800056a2:	57250513          	addi	a0,a0,1394 # 8003dc10 <ftable>
    800056a6:	ffffb097          	auipc	ra,0xffffb
    800056aa:	5f6080e7          	jalr	1526(ra) # 80000c9c <release>
  }
}
    800056ae:	70e2                	ld	ra,56(sp)
    800056b0:	7442                	ld	s0,48(sp)
    800056b2:	74a2                	ld	s1,40(sp)
    800056b4:	7902                	ld	s2,32(sp)
    800056b6:	69e2                	ld	s3,24(sp)
    800056b8:	6a42                	ld	s4,16(sp)
    800056ba:	6aa2                	ld	s5,8(sp)
    800056bc:	6121                	addi	sp,sp,64
    800056be:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800056c0:	85d6                	mv	a1,s5
    800056c2:	8552                	mv	a0,s4
    800056c4:	00000097          	auipc	ra,0x0
    800056c8:	34c080e7          	jalr	844(ra) # 80005a10 <pipeclose>
    800056cc:	b7cd                	j	800056ae <fileclose+0xa8>

00000000800056ce <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800056ce:	715d                	addi	sp,sp,-80
    800056d0:	e486                	sd	ra,72(sp)
    800056d2:	e0a2                	sd	s0,64(sp)
    800056d4:	fc26                	sd	s1,56(sp)
    800056d6:	f84a                	sd	s2,48(sp)
    800056d8:	f44e                	sd	s3,40(sp)
    800056da:	0880                	addi	s0,sp,80
    800056dc:	84aa                	mv	s1,a0
    800056de:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800056e0:	ffffc097          	auipc	ra,0xffffc
    800056e4:	39c080e7          	jalr	924(ra) # 80001a7c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800056e8:	409c                	lw	a5,0(s1)
    800056ea:	37f9                	addiw	a5,a5,-2
    800056ec:	4705                	li	a4,1
    800056ee:	04f76763          	bltu	a4,a5,8000573c <filestat+0x6e>
    800056f2:	892a                	mv	s2,a0
    ilock(f->ip);
    800056f4:	6c88                	ld	a0,24(s1)
    800056f6:	fffff097          	auipc	ra,0xfffff
    800056fa:	070080e7          	jalr	112(ra) # 80004766 <ilock>
    stati(f->ip, &st);
    800056fe:	fb840593          	addi	a1,s0,-72
    80005702:	6c88                	ld	a0,24(s1)
    80005704:	fffff097          	auipc	ra,0xfffff
    80005708:	2ec080e7          	jalr	748(ra) # 800049f0 <stati>
    iunlock(f->ip);
    8000570c:	6c88                	ld	a0,24(s1)
    8000570e:	fffff097          	auipc	ra,0xfffff
    80005712:	11a080e7          	jalr	282(ra) # 80004828 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005716:	46e1                	li	a3,24
    80005718:	fb840613          	addi	a2,s0,-72
    8000571c:	85ce                	mv	a1,s3
    8000571e:	04093503          	ld	a0,64(s2)
    80005722:	ffffc097          	auipc	ra,0xffffc
    80005726:	f42080e7          	jalr	-190(ra) # 80001664 <copyout>
    8000572a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000572e:	60a6                	ld	ra,72(sp)
    80005730:	6406                	ld	s0,64(sp)
    80005732:	74e2                	ld	s1,56(sp)
    80005734:	7942                	ld	s2,48(sp)
    80005736:	79a2                	ld	s3,40(sp)
    80005738:	6161                	addi	sp,sp,80
    8000573a:	8082                	ret
  return -1;
    8000573c:	557d                	li	a0,-1
    8000573e:	bfc5                	j	8000572e <filestat+0x60>

0000000080005740 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80005740:	7179                	addi	sp,sp,-48
    80005742:	f406                	sd	ra,40(sp)
    80005744:	f022                	sd	s0,32(sp)
    80005746:	ec26                	sd	s1,24(sp)
    80005748:	e84a                	sd	s2,16(sp)
    8000574a:	e44e                	sd	s3,8(sp)
    8000574c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000574e:	00854783          	lbu	a5,8(a0)
    80005752:	c3d5                	beqz	a5,800057f6 <fileread+0xb6>
    80005754:	84aa                	mv	s1,a0
    80005756:	89ae                	mv	s3,a1
    80005758:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000575a:	411c                	lw	a5,0(a0)
    8000575c:	4705                	li	a4,1
    8000575e:	04e78963          	beq	a5,a4,800057b0 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005762:	470d                	li	a4,3
    80005764:	04e78d63          	beq	a5,a4,800057be <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005768:	4709                	li	a4,2
    8000576a:	06e79e63          	bne	a5,a4,800057e6 <fileread+0xa6>
    ilock(f->ip);
    8000576e:	6d08                	ld	a0,24(a0)
    80005770:	fffff097          	auipc	ra,0xfffff
    80005774:	ff6080e7          	jalr	-10(ra) # 80004766 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005778:	874a                	mv	a4,s2
    8000577a:	5094                	lw	a3,32(s1)
    8000577c:	864e                	mv	a2,s3
    8000577e:	4585                	li	a1,1
    80005780:	6c88                	ld	a0,24(s1)
    80005782:	fffff097          	auipc	ra,0xfffff
    80005786:	298080e7          	jalr	664(ra) # 80004a1a <readi>
    8000578a:	892a                	mv	s2,a0
    8000578c:	00a05563          	blez	a0,80005796 <fileread+0x56>
      f->off += r;
    80005790:	509c                	lw	a5,32(s1)
    80005792:	9fa9                	addw	a5,a5,a0
    80005794:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80005796:	6c88                	ld	a0,24(s1)
    80005798:	fffff097          	auipc	ra,0xfffff
    8000579c:	090080e7          	jalr	144(ra) # 80004828 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800057a0:	854a                	mv	a0,s2
    800057a2:	70a2                	ld	ra,40(sp)
    800057a4:	7402                	ld	s0,32(sp)
    800057a6:	64e2                	ld	s1,24(sp)
    800057a8:	6942                	ld	s2,16(sp)
    800057aa:	69a2                	ld	s3,8(sp)
    800057ac:	6145                	addi	sp,sp,48
    800057ae:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800057b0:	6908                	ld	a0,16(a0)
    800057b2:	00000097          	auipc	ra,0x0
    800057b6:	3c8080e7          	jalr	968(ra) # 80005b7a <piperead>
    800057ba:	892a                	mv	s2,a0
    800057bc:	b7d5                	j	800057a0 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800057be:	02451783          	lh	a5,36(a0)
    800057c2:	03079693          	slli	a3,a5,0x30
    800057c6:	92c1                	srli	a3,a3,0x30
    800057c8:	4725                	li	a4,9
    800057ca:	02d76863          	bltu	a4,a3,800057fa <fileread+0xba>
    800057ce:	0792                	slli	a5,a5,0x4
    800057d0:	00038717          	auipc	a4,0x38
    800057d4:	3a070713          	addi	a4,a4,928 # 8003db70 <devsw>
    800057d8:	97ba                	add	a5,a5,a4
    800057da:	639c                	ld	a5,0(a5)
    800057dc:	c38d                	beqz	a5,800057fe <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800057de:	4505                	li	a0,1
    800057e0:	9782                	jalr	a5
    800057e2:	892a                	mv	s2,a0
    800057e4:	bf75                	j	800057a0 <fileread+0x60>
    panic("fileread");
    800057e6:	00004517          	auipc	a0,0x4
    800057ea:	01a50513          	addi	a0,a0,26 # 80009800 <syscalls+0x290>
    800057ee:	ffffb097          	auipc	ra,0xffffb
    800057f2:	d40080e7          	jalr	-704(ra) # 8000052e <panic>
    return -1;
    800057f6:	597d                	li	s2,-1
    800057f8:	b765                	j	800057a0 <fileread+0x60>
      return -1;
    800057fa:	597d                	li	s2,-1
    800057fc:	b755                	j	800057a0 <fileread+0x60>
    800057fe:	597d                	li	s2,-1
    80005800:	b745                	j	800057a0 <fileread+0x60>

0000000080005802 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80005802:	715d                	addi	sp,sp,-80
    80005804:	e486                	sd	ra,72(sp)
    80005806:	e0a2                	sd	s0,64(sp)
    80005808:	fc26                	sd	s1,56(sp)
    8000580a:	f84a                	sd	s2,48(sp)
    8000580c:	f44e                	sd	s3,40(sp)
    8000580e:	f052                	sd	s4,32(sp)
    80005810:	ec56                	sd	s5,24(sp)
    80005812:	e85a                	sd	s6,16(sp)
    80005814:	e45e                	sd	s7,8(sp)
    80005816:	e062                	sd	s8,0(sp)
    80005818:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000581a:	00954783          	lbu	a5,9(a0)
    8000581e:	10078663          	beqz	a5,8000592a <filewrite+0x128>
    80005822:	892a                	mv	s2,a0
    80005824:	8aae                	mv	s5,a1
    80005826:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80005828:	411c                	lw	a5,0(a0)
    8000582a:	4705                	li	a4,1
    8000582c:	02e78263          	beq	a5,a4,80005850 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005830:	470d                	li	a4,3
    80005832:	02e78663          	beq	a5,a4,8000585e <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80005836:	4709                	li	a4,2
    80005838:	0ee79163          	bne	a5,a4,8000591a <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000583c:	0ac05d63          	blez	a2,800058f6 <filewrite+0xf4>
    int i = 0;
    80005840:	4981                	li	s3,0
    80005842:	6b05                	lui	s6,0x1
    80005844:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005848:	6b85                	lui	s7,0x1
    8000584a:	c00b8b9b          	addiw	s7,s7,-1024
    8000584e:	a861                	j	800058e6 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005850:	6908                	ld	a0,16(a0)
    80005852:	00000097          	auipc	ra,0x0
    80005856:	22e080e7          	jalr	558(ra) # 80005a80 <pipewrite>
    8000585a:	8a2a                	mv	s4,a0
    8000585c:	a045                	j	800058fc <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000585e:	02451783          	lh	a5,36(a0)
    80005862:	03079693          	slli	a3,a5,0x30
    80005866:	92c1                	srli	a3,a3,0x30
    80005868:	4725                	li	a4,9
    8000586a:	0cd76263          	bltu	a4,a3,8000592e <filewrite+0x12c>
    8000586e:	0792                	slli	a5,a5,0x4
    80005870:	00038717          	auipc	a4,0x38
    80005874:	30070713          	addi	a4,a4,768 # 8003db70 <devsw>
    80005878:	97ba                	add	a5,a5,a4
    8000587a:	679c                	ld	a5,8(a5)
    8000587c:	cbdd                	beqz	a5,80005932 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    8000587e:	4505                	li	a0,1
    80005880:	9782                	jalr	a5
    80005882:	8a2a                	mv	s4,a0
    80005884:	a8a5                	j	800058fc <filewrite+0xfa>
    80005886:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000588a:	00000097          	auipc	ra,0x0
    8000588e:	8b0080e7          	jalr	-1872(ra) # 8000513a <begin_op>
      ilock(f->ip);
    80005892:	01893503          	ld	a0,24(s2)
    80005896:	fffff097          	auipc	ra,0xfffff
    8000589a:	ed0080e7          	jalr	-304(ra) # 80004766 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000589e:	8762                	mv	a4,s8
    800058a0:	02092683          	lw	a3,32(s2)
    800058a4:	01598633          	add	a2,s3,s5
    800058a8:	4585                	li	a1,1
    800058aa:	01893503          	ld	a0,24(s2)
    800058ae:	fffff097          	auipc	ra,0xfffff
    800058b2:	264080e7          	jalr	612(ra) # 80004b12 <writei>
    800058b6:	84aa                	mv	s1,a0
    800058b8:	00a05763          	blez	a0,800058c6 <filewrite+0xc4>
        f->off += r;
    800058bc:	02092783          	lw	a5,32(s2)
    800058c0:	9fa9                	addw	a5,a5,a0
    800058c2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800058c6:	01893503          	ld	a0,24(s2)
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	f5e080e7          	jalr	-162(ra) # 80004828 <iunlock>
      end_op();
    800058d2:	00000097          	auipc	ra,0x0
    800058d6:	8e8080e7          	jalr	-1816(ra) # 800051ba <end_op>

      if(r != n1){
    800058da:	009c1f63          	bne	s8,s1,800058f8 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    800058de:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800058e2:	0149db63          	bge	s3,s4,800058f8 <filewrite+0xf6>
      int n1 = n - i;
    800058e6:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800058ea:	84be                	mv	s1,a5
    800058ec:	2781                	sext.w	a5,a5
    800058ee:	f8fb5ce3          	bge	s6,a5,80005886 <filewrite+0x84>
    800058f2:	84de                	mv	s1,s7
    800058f4:	bf49                	j	80005886 <filewrite+0x84>
    int i = 0;
    800058f6:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800058f8:	013a1f63          	bne	s4,s3,80005916 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800058fc:	8552                	mv	a0,s4
    800058fe:	60a6                	ld	ra,72(sp)
    80005900:	6406                	ld	s0,64(sp)
    80005902:	74e2                	ld	s1,56(sp)
    80005904:	7942                	ld	s2,48(sp)
    80005906:	79a2                	ld	s3,40(sp)
    80005908:	7a02                	ld	s4,32(sp)
    8000590a:	6ae2                	ld	s5,24(sp)
    8000590c:	6b42                	ld	s6,16(sp)
    8000590e:	6ba2                	ld	s7,8(sp)
    80005910:	6c02                	ld	s8,0(sp)
    80005912:	6161                	addi	sp,sp,80
    80005914:	8082                	ret
    ret = (i == n ? n : -1);
    80005916:	5a7d                	li	s4,-1
    80005918:	b7d5                	j	800058fc <filewrite+0xfa>
    panic("filewrite");
    8000591a:	00004517          	auipc	a0,0x4
    8000591e:	ef650513          	addi	a0,a0,-266 # 80009810 <syscalls+0x2a0>
    80005922:	ffffb097          	auipc	ra,0xffffb
    80005926:	c0c080e7          	jalr	-1012(ra) # 8000052e <panic>
    return -1;
    8000592a:	5a7d                	li	s4,-1
    8000592c:	bfc1                	j	800058fc <filewrite+0xfa>
      return -1;
    8000592e:	5a7d                	li	s4,-1
    80005930:	b7f1                	j	800058fc <filewrite+0xfa>
    80005932:	5a7d                	li	s4,-1
    80005934:	b7e1                	j	800058fc <filewrite+0xfa>

0000000080005936 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80005936:	7179                	addi	sp,sp,-48
    80005938:	f406                	sd	ra,40(sp)
    8000593a:	f022                	sd	s0,32(sp)
    8000593c:	ec26                	sd	s1,24(sp)
    8000593e:	e84a                	sd	s2,16(sp)
    80005940:	e44e                	sd	s3,8(sp)
    80005942:	e052                	sd	s4,0(sp)
    80005944:	1800                	addi	s0,sp,48
    80005946:	84aa                	mv	s1,a0
    80005948:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000594a:	0005b023          	sd	zero,0(a1)
    8000594e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005952:	00000097          	auipc	ra,0x0
    80005956:	bf8080e7          	jalr	-1032(ra) # 8000554a <filealloc>
    8000595a:	e088                	sd	a0,0(s1)
    8000595c:	c551                	beqz	a0,800059e8 <pipealloc+0xb2>
    8000595e:	00000097          	auipc	ra,0x0
    80005962:	bec080e7          	jalr	-1044(ra) # 8000554a <filealloc>
    80005966:	00aa3023          	sd	a0,0(s4)
    8000596a:	c92d                	beqz	a0,800059dc <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000596c:	ffffb097          	auipc	ra,0xffffb
    80005970:	16a080e7          	jalr	362(ra) # 80000ad6 <kalloc>
    80005974:	892a                	mv	s2,a0
    80005976:	c125                	beqz	a0,800059d6 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005978:	4985                	li	s3,1
    8000597a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000597e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005982:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005986:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000598a:	00004597          	auipc	a1,0x4
    8000598e:	e9658593          	addi	a1,a1,-362 # 80009820 <syscalls+0x2b0>
    80005992:	ffffb097          	auipc	ra,0xffffb
    80005996:	1a4080e7          	jalr	420(ra) # 80000b36 <initlock>
  (*f0)->type = FD_PIPE;
    8000599a:	609c                	ld	a5,0(s1)
    8000599c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800059a0:	609c                	ld	a5,0(s1)
    800059a2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800059a6:	609c                	ld	a5,0(s1)
    800059a8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800059ac:	609c                	ld	a5,0(s1)
    800059ae:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800059b2:	000a3783          	ld	a5,0(s4)
    800059b6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800059ba:	000a3783          	ld	a5,0(s4)
    800059be:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800059c2:	000a3783          	ld	a5,0(s4)
    800059c6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800059ca:	000a3783          	ld	a5,0(s4)
    800059ce:	0127b823          	sd	s2,16(a5)
  return 0;
    800059d2:	4501                	li	a0,0
    800059d4:	a025                	j	800059fc <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800059d6:	6088                	ld	a0,0(s1)
    800059d8:	e501                	bnez	a0,800059e0 <pipealloc+0xaa>
    800059da:	a039                	j	800059e8 <pipealloc+0xb2>
    800059dc:	6088                	ld	a0,0(s1)
    800059de:	c51d                	beqz	a0,80005a0c <pipealloc+0xd6>
    fileclose(*f0);
    800059e0:	00000097          	auipc	ra,0x0
    800059e4:	c26080e7          	jalr	-986(ra) # 80005606 <fileclose>
  if(*f1)
    800059e8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800059ec:	557d                	li	a0,-1
  if(*f1)
    800059ee:	c799                	beqz	a5,800059fc <pipealloc+0xc6>
    fileclose(*f1);
    800059f0:	853e                	mv	a0,a5
    800059f2:	00000097          	auipc	ra,0x0
    800059f6:	c14080e7          	jalr	-1004(ra) # 80005606 <fileclose>
  return -1;
    800059fa:	557d                	li	a0,-1
}
    800059fc:	70a2                	ld	ra,40(sp)
    800059fe:	7402                	ld	s0,32(sp)
    80005a00:	64e2                	ld	s1,24(sp)
    80005a02:	6942                	ld	s2,16(sp)
    80005a04:	69a2                	ld	s3,8(sp)
    80005a06:	6a02                	ld	s4,0(sp)
    80005a08:	6145                	addi	sp,sp,48
    80005a0a:	8082                	ret
  return -1;
    80005a0c:	557d                	li	a0,-1
    80005a0e:	b7fd                	j	800059fc <pipealloc+0xc6>

0000000080005a10 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80005a10:	1101                	addi	sp,sp,-32
    80005a12:	ec06                	sd	ra,24(sp)
    80005a14:	e822                	sd	s0,16(sp)
    80005a16:	e426                	sd	s1,8(sp)
    80005a18:	e04a                	sd	s2,0(sp)
    80005a1a:	1000                	addi	s0,sp,32
    80005a1c:	84aa                	mv	s1,a0
    80005a1e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80005a20:	ffffb097          	auipc	ra,0xffffb
    80005a24:	1a6080e7          	jalr	422(ra) # 80000bc6 <acquire>
  if(writable){
    80005a28:	02090d63          	beqz	s2,80005a62 <pipeclose+0x52>
    pi->writeopen = 0;
    80005a2c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80005a30:	21848513          	addi	a0,s1,536
    80005a34:	ffffd097          	auipc	ra,0xffffd
    80005a38:	b48080e7          	jalr	-1208(ra) # 8000257c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80005a3c:	2204b783          	ld	a5,544(s1)
    80005a40:	eb95                	bnez	a5,80005a74 <pipeclose+0x64>
    release(&pi->lock);
    80005a42:	8526                	mv	a0,s1
    80005a44:	ffffb097          	auipc	ra,0xffffb
    80005a48:	258080e7          	jalr	600(ra) # 80000c9c <release>
    kfree((char*)pi);
    80005a4c:	8526                	mv	a0,s1
    80005a4e:	ffffb097          	auipc	ra,0xffffb
    80005a52:	f8c080e7          	jalr	-116(ra) # 800009da <kfree>
  } else
    release(&pi->lock);
}
    80005a56:	60e2                	ld	ra,24(sp)
    80005a58:	6442                	ld	s0,16(sp)
    80005a5a:	64a2                	ld	s1,8(sp)
    80005a5c:	6902                	ld	s2,0(sp)
    80005a5e:	6105                	addi	sp,sp,32
    80005a60:	8082                	ret
    pi->readopen = 0;
    80005a62:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005a66:	21c48513          	addi	a0,s1,540
    80005a6a:	ffffd097          	auipc	ra,0xffffd
    80005a6e:	b12080e7          	jalr	-1262(ra) # 8000257c <wakeup>
    80005a72:	b7e9                	j	80005a3c <pipeclose+0x2c>
    release(&pi->lock);
    80005a74:	8526                	mv	a0,s1
    80005a76:	ffffb097          	auipc	ra,0xffffb
    80005a7a:	226080e7          	jalr	550(ra) # 80000c9c <release>
}
    80005a7e:	bfe1                	j	80005a56 <pipeclose+0x46>

0000000080005a80 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005a80:	7159                	addi	sp,sp,-112
    80005a82:	f486                	sd	ra,104(sp)
    80005a84:	f0a2                	sd	s0,96(sp)
    80005a86:	eca6                	sd	s1,88(sp)
    80005a88:	e8ca                	sd	s2,80(sp)
    80005a8a:	e4ce                	sd	s3,72(sp)
    80005a8c:	e0d2                	sd	s4,64(sp)
    80005a8e:	fc56                	sd	s5,56(sp)
    80005a90:	f85a                	sd	s6,48(sp)
    80005a92:	f45e                	sd	s7,40(sp)
    80005a94:	f062                	sd	s8,32(sp)
    80005a96:	ec66                	sd	s9,24(sp)
    80005a98:	1880                	addi	s0,sp,112
    80005a9a:	84aa                	mv	s1,a0
    80005a9c:	8b2e                	mv	s6,a1
    80005a9e:	8ab2                	mv	s5,a2
  int i = 0;
  struct proc *pr = myproc();
    80005aa0:	ffffc097          	auipc	ra,0xffffc
    80005aa4:	fdc080e7          	jalr	-36(ra) # 80001a7c <myproc>
    80005aa8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005aaa:	8526                	mv	a0,s1
    80005aac:	ffffb097          	auipc	ra,0xffffb
    80005ab0:	11a080e7          	jalr	282(ra) # 80000bc6 <acquire>
  while(i < n){
    80005ab4:	0b505663          	blez	s5,80005b60 <pipewrite+0xe0>
  int i = 0;
    80005ab8:	4901                	li	s2,0
    if(pi->readopen == 0 || pr->killed==1){
    80005aba:	4a05                	li	s4,1
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005abc:	5bfd                	li	s7,-1
      wakeup(&pi->nread);
    80005abe:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005ac2:	21c48c13          	addi	s8,s1,540
    80005ac6:	a091                	j	80005b0a <pipewrite+0x8a>
      release(&pi->lock);
    80005ac8:	8526                	mv	a0,s1
    80005aca:	ffffb097          	auipc	ra,0xffffb
    80005ace:	1d2080e7          	jalr	466(ra) # 80000c9c <release>
      return -1;
    80005ad2:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005ad4:	854a                	mv	a0,s2
    80005ad6:	70a6                	ld	ra,104(sp)
    80005ad8:	7406                	ld	s0,96(sp)
    80005ada:	64e6                	ld	s1,88(sp)
    80005adc:	6946                	ld	s2,80(sp)
    80005ade:	69a6                	ld	s3,72(sp)
    80005ae0:	6a06                	ld	s4,64(sp)
    80005ae2:	7ae2                	ld	s5,56(sp)
    80005ae4:	7b42                	ld	s6,48(sp)
    80005ae6:	7ba2                	ld	s7,40(sp)
    80005ae8:	7c02                	ld	s8,32(sp)
    80005aea:	6ce2                	ld	s9,24(sp)
    80005aec:	6165                	addi	sp,sp,112
    80005aee:	8082                	ret
      wakeup(&pi->nread);
    80005af0:	8566                	mv	a0,s9
    80005af2:	ffffd097          	auipc	ra,0xffffd
    80005af6:	a8a080e7          	jalr	-1398(ra) # 8000257c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80005afa:	85a6                	mv	a1,s1
    80005afc:	8562                	mv	a0,s8
    80005afe:	ffffd097          	auipc	ra,0xffffd
    80005b02:	8f4080e7          	jalr	-1804(ra) # 800023f2 <sleep>
  while(i < n){
    80005b06:	05595e63          	bge	s2,s5,80005b62 <pipewrite+0xe2>
    if(pi->readopen == 0 || pr->killed==1){
    80005b0a:	2204a783          	lw	a5,544(s1)
    80005b0e:	dfcd                	beqz	a5,80005ac8 <pipewrite+0x48>
    80005b10:	01c9a783          	lw	a5,28(s3)
    80005b14:	fb478ae3          	beq	a5,s4,80005ac8 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005b18:	2184a783          	lw	a5,536(s1)
    80005b1c:	21c4a703          	lw	a4,540(s1)
    80005b20:	2007879b          	addiw	a5,a5,512
    80005b24:	fcf706e3          	beq	a4,a5,80005af0 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005b28:	86d2                	mv	a3,s4
    80005b2a:	01690633          	add	a2,s2,s6
    80005b2e:	f9f40593          	addi	a1,s0,-97
    80005b32:	0409b503          	ld	a0,64(s3)
    80005b36:	ffffc097          	auipc	ra,0xffffc
    80005b3a:	bba080e7          	jalr	-1094(ra) # 800016f0 <copyin>
    80005b3e:	03750263          	beq	a0,s7,80005b62 <pipewrite+0xe2>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005b42:	21c4a783          	lw	a5,540(s1)
    80005b46:	0017871b          	addiw	a4,a5,1
    80005b4a:	20e4ae23          	sw	a4,540(s1)
    80005b4e:	1ff7f793          	andi	a5,a5,511
    80005b52:	97a6                	add	a5,a5,s1
    80005b54:	f9f44703          	lbu	a4,-97(s0)
    80005b58:	00e78c23          	sb	a4,24(a5)
      i++;
    80005b5c:	2905                	addiw	s2,s2,1
    80005b5e:	b765                	j	80005b06 <pipewrite+0x86>
  int i = 0;
    80005b60:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005b62:	21848513          	addi	a0,s1,536
    80005b66:	ffffd097          	auipc	ra,0xffffd
    80005b6a:	a16080e7          	jalr	-1514(ra) # 8000257c <wakeup>
  release(&pi->lock);
    80005b6e:	8526                	mv	a0,s1
    80005b70:	ffffb097          	auipc	ra,0xffffb
    80005b74:	12c080e7          	jalr	300(ra) # 80000c9c <release>
  return i;
    80005b78:	bfb1                	j	80005ad4 <pipewrite+0x54>

0000000080005b7a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005b7a:	715d                	addi	sp,sp,-80
    80005b7c:	e486                	sd	ra,72(sp)
    80005b7e:	e0a2                	sd	s0,64(sp)
    80005b80:	fc26                	sd	s1,56(sp)
    80005b82:	f84a                	sd	s2,48(sp)
    80005b84:	f44e                	sd	s3,40(sp)
    80005b86:	f052                	sd	s4,32(sp)
    80005b88:	ec56                	sd	s5,24(sp)
    80005b8a:	e85a                	sd	s6,16(sp)
    80005b8c:	0880                	addi	s0,sp,80
    80005b8e:	84aa                	mv	s1,a0
    80005b90:	892e                	mv	s2,a1
    80005b92:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005b94:	ffffc097          	auipc	ra,0xffffc
    80005b98:	ee8080e7          	jalr	-280(ra) # 80001a7c <myproc>
    80005b9c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005b9e:	8526                	mv	a0,s1
    80005ba0:	ffffb097          	auipc	ra,0xffffb
    80005ba4:	026080e7          	jalr	38(ra) # 80000bc6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005ba8:	2184a703          	lw	a4,536(s1)
    80005bac:	21c4a783          	lw	a5,540(s1)
    if(pr->killed==1){
    80005bb0:	4985                	li	s3,1
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005bb2:	21848b13          	addi	s6,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005bb6:	02f71563          	bne	a4,a5,80005be0 <piperead+0x66>
    80005bba:	2244a783          	lw	a5,548(s1)
    80005bbe:	c38d                	beqz	a5,80005be0 <piperead+0x66>
    if(pr->killed==1){
    80005bc0:	01ca2783          	lw	a5,28(s4)
    80005bc4:	09378963          	beq	a5,s3,80005c56 <piperead+0xdc>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005bc8:	85a6                	mv	a1,s1
    80005bca:	855a                	mv	a0,s6
    80005bcc:	ffffd097          	auipc	ra,0xffffd
    80005bd0:	826080e7          	jalr	-2010(ra) # 800023f2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005bd4:	2184a703          	lw	a4,536(s1)
    80005bd8:	21c4a783          	lw	a5,540(s1)
    80005bdc:	fcf70fe3          	beq	a4,a5,80005bba <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005be0:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005be2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005be4:	05505363          	blez	s5,80005c2a <piperead+0xb0>
    if(pi->nread == pi->nwrite)
    80005be8:	2184a783          	lw	a5,536(s1)
    80005bec:	21c4a703          	lw	a4,540(s1)
    80005bf0:	02f70d63          	beq	a4,a5,80005c2a <piperead+0xb0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005bf4:	0017871b          	addiw	a4,a5,1
    80005bf8:	20e4ac23          	sw	a4,536(s1)
    80005bfc:	1ff7f793          	andi	a5,a5,511
    80005c00:	97a6                	add	a5,a5,s1
    80005c02:	0187c783          	lbu	a5,24(a5)
    80005c06:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005c0a:	4685                	li	a3,1
    80005c0c:	fbf40613          	addi	a2,s0,-65
    80005c10:	85ca                	mv	a1,s2
    80005c12:	040a3503          	ld	a0,64(s4)
    80005c16:	ffffc097          	auipc	ra,0xffffc
    80005c1a:	a4e080e7          	jalr	-1458(ra) # 80001664 <copyout>
    80005c1e:	01650663          	beq	a0,s6,80005c2a <piperead+0xb0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005c22:	2985                	addiw	s3,s3,1
    80005c24:	0905                	addi	s2,s2,1
    80005c26:	fd3a91e3          	bne	s5,s3,80005be8 <piperead+0x6e>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005c2a:	21c48513          	addi	a0,s1,540
    80005c2e:	ffffd097          	auipc	ra,0xffffd
    80005c32:	94e080e7          	jalr	-1714(ra) # 8000257c <wakeup>
  release(&pi->lock);
    80005c36:	8526                	mv	a0,s1
    80005c38:	ffffb097          	auipc	ra,0xffffb
    80005c3c:	064080e7          	jalr	100(ra) # 80000c9c <release>
  return i;
}
    80005c40:	854e                	mv	a0,s3
    80005c42:	60a6                	ld	ra,72(sp)
    80005c44:	6406                	ld	s0,64(sp)
    80005c46:	74e2                	ld	s1,56(sp)
    80005c48:	7942                	ld	s2,48(sp)
    80005c4a:	79a2                	ld	s3,40(sp)
    80005c4c:	7a02                	ld	s4,32(sp)
    80005c4e:	6ae2                	ld	s5,24(sp)
    80005c50:	6b42                	ld	s6,16(sp)
    80005c52:	6161                	addi	sp,sp,80
    80005c54:	8082                	ret
      release(&pi->lock);
    80005c56:	8526                	mv	a0,s1
    80005c58:	ffffb097          	auipc	ra,0xffffb
    80005c5c:	044080e7          	jalr	68(ra) # 80000c9c <release>
      return -1;
    80005c60:	59fd                	li	s3,-1
    80005c62:	bff9                	j	80005c40 <piperead+0xc6>

0000000080005c64 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005c64:	dd010113          	addi	sp,sp,-560
    80005c68:	22113423          	sd	ra,552(sp)
    80005c6c:	22813023          	sd	s0,544(sp)
    80005c70:	20913c23          	sd	s1,536(sp)
    80005c74:	21213823          	sd	s2,528(sp)
    80005c78:	21313423          	sd	s3,520(sp)
    80005c7c:	21413023          	sd	s4,512(sp)
    80005c80:	ffd6                	sd	s5,504(sp)
    80005c82:	fbda                	sd	s6,496(sp)
    80005c84:	f7de                	sd	s7,488(sp)
    80005c86:	f3e2                	sd	s8,480(sp)
    80005c88:	efe6                	sd	s9,472(sp)
    80005c8a:	ebea                	sd	s10,464(sp)
    80005c8c:	e7ee                	sd	s11,456(sp)
    80005c8e:	1c00                	addi	s0,sp,560
    80005c90:	dea43823          	sd	a0,-528(s0)
    80005c94:	deb43023          	sd	a1,-544(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005c98:	ffffc097          	auipc	ra,0xffffc
    80005c9c:	de4080e7          	jalr	-540(ra) # 80001a7c <myproc>
    80005ca0:	89aa                	mv	s3,a0

  struct kthread *t = mykthread();
    80005ca2:	ffffc097          	auipc	ra,0xffffc
    80005ca6:	e1a080e7          	jalr	-486(ra) # 80001abc <mykthread>
    80005caa:	8b2a                	mv	s6,a0
  struct kthread *nt;


  // Kill all process threads 
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){ 
    80005cac:	28898493          	addi	s1,s3,648
    80005cb0:	6905                	lui	s2,0x1
    80005cb2:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80005cb6:	994e                	add	s2,s2,s3
    if(nt!=t && nt->state!=TUNUSED){
      acquire(&nt->lock);
      nt->killed=1;
    80005cb8:	4a85                	li	s5,1
      if(nt->state == TSLEEPING){
    80005cba:	4a09                	li	s4,2
        nt->state = TRUNNABLE;
    80005cbc:	4b8d                	li	s7,3
    80005cbe:	a811                	j	80005cd2 <exec+0x6e>
      }
      release(&nt->lock);  
    80005cc0:	8526                	mv	a0,s1
    80005cc2:	ffffb097          	auipc	ra,0xffffb
    80005cc6:	fda080e7          	jalr	-38(ra) # 80000c9c <release>
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];nt++){ 
    80005cca:	0b848493          	addi	s1,s1,184
    80005cce:	03248363          	beq	s1,s2,80005cf4 <exec+0x90>
    if(nt!=t && nt->state!=TUNUSED){
    80005cd2:	fe9b0ce3          	beq	s6,s1,80005cca <exec+0x66>
    80005cd6:	4c9c                	lw	a5,24(s1)
    80005cd8:	dbed                	beqz	a5,80005cca <exec+0x66>
      acquire(&nt->lock);
    80005cda:	8526                	mv	a0,s1
    80005cdc:	ffffb097          	auipc	ra,0xffffb
    80005ce0:	eea080e7          	jalr	-278(ra) # 80000bc6 <acquire>
      nt->killed=1;
    80005ce4:	0354a423          	sw	s5,40(s1)
      if(nt->state == TSLEEPING){
    80005ce8:	4c9c                	lw	a5,24(s1)
    80005cea:	fd479be3          	bne	a5,s4,80005cc0 <exec+0x5c>
        nt->state = TRUNNABLE;
    80005cee:	0174ac23          	sw	s7,24(s1)
    80005cf2:	b7f9                	j	80005cc0 <exec+0x5c>
    }
  }

  // Wait for all threads to terminate
  kthread_join_all();
    80005cf4:	ffffd097          	auipc	ra,0xffffd
    80005cf8:	37a080e7          	jalr	890(ra) # 8000306e <kthread_join_all>
    
  begin_op();
    80005cfc:	fffff097          	auipc	ra,0xfffff
    80005d00:	43e080e7          	jalr	1086(ra) # 8000513a <begin_op>

  if((ip = namei(path)) == 0){
    80005d04:	df043503          	ld	a0,-528(s0)
    80005d08:	fffff097          	auipc	ra,0xfffff
    80005d0c:	212080e7          	jalr	530(ra) # 80004f1a <namei>
    80005d10:	8aaa                	mv	s5,a0
    80005d12:	cd25                	beqz	a0,80005d8a <exec+0x126>
    end_op();
    return -1;
  }
  ilock(ip);
    80005d14:	fffff097          	auipc	ra,0xfffff
    80005d18:	a52080e7          	jalr	-1454(ra) # 80004766 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80005d1c:	04000713          	li	a4,64
    80005d20:	4681                	li	a3,0
    80005d22:	e4840613          	addi	a2,s0,-440
    80005d26:	4581                	li	a1,0
    80005d28:	8556                	mv	a0,s5
    80005d2a:	fffff097          	auipc	ra,0xfffff
    80005d2e:	cf0080e7          	jalr	-784(ra) # 80004a1a <readi>
    80005d32:	04000793          	li	a5,64
    80005d36:	00f51a63          	bne	a0,a5,80005d4a <exec+0xe6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80005d3a:	e4842703          	lw	a4,-440(s0)
    80005d3e:	464c47b7          	lui	a5,0x464c4
    80005d42:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005d46:	04f70863          	beq	a4,a5,80005d96 <exec+0x132>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005d4a:	8556                	mv	a0,s5
    80005d4c:	fffff097          	auipc	ra,0xfffff
    80005d50:	c7c080e7          	jalr	-900(ra) # 800049c8 <iunlockput>
    end_op();
    80005d54:	fffff097          	auipc	ra,0xfffff
    80005d58:	466080e7          	jalr	1126(ra) # 800051ba <end_op>
  }
  return -1;
    80005d5c:	557d                	li	a0,-1
}
    80005d5e:	22813083          	ld	ra,552(sp)
    80005d62:	22013403          	ld	s0,544(sp)
    80005d66:	21813483          	ld	s1,536(sp)
    80005d6a:	21013903          	ld	s2,528(sp)
    80005d6e:	20813983          	ld	s3,520(sp)
    80005d72:	20013a03          	ld	s4,512(sp)
    80005d76:	7afe                	ld	s5,504(sp)
    80005d78:	7b5e                	ld	s6,496(sp)
    80005d7a:	7bbe                	ld	s7,488(sp)
    80005d7c:	7c1e                	ld	s8,480(sp)
    80005d7e:	6cfe                	ld	s9,472(sp)
    80005d80:	6d5e                	ld	s10,464(sp)
    80005d82:	6dbe                	ld	s11,456(sp)
    80005d84:	23010113          	addi	sp,sp,560
    80005d88:	8082                	ret
    end_op();
    80005d8a:	fffff097          	auipc	ra,0xfffff
    80005d8e:	430080e7          	jalr	1072(ra) # 800051ba <end_op>
    return -1;
    80005d92:	557d                	li	a0,-1
    80005d94:	b7e9                	j	80005d5e <exec+0xfa>
  if((pagetable = proc_pagetable(p)) == 0)
    80005d96:	854e                	mv	a0,s3
    80005d98:	ffffc097          	auipc	ra,0xffffc
    80005d9c:	e80080e7          	jalr	-384(ra) # 80001c18 <proc_pagetable>
    80005da0:	e0a43423          	sd	a0,-504(s0)
    80005da4:	d15d                	beqz	a0,80005d4a <exec+0xe6>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005da6:	e6842783          	lw	a5,-408(s0)
    80005daa:	e8045703          	lhu	a4,-384(s0)
    80005dae:	c73d                	beqz	a4,80005e1c <exec+0x1b8>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005db0:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005db2:	e0043023          	sd	zero,-512(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005db6:	6a05                	lui	s4,0x1
    80005db8:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005dbc:	dce43c23          	sd	a4,-552(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005dc0:	6d85                	lui	s11,0x1
    80005dc2:	7d7d                	lui	s10,0xfffff
    80005dc4:	a4b5                	j	80006030 <exec+0x3cc>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005dc6:	00004517          	auipc	a0,0x4
    80005dca:	a6250513          	addi	a0,a0,-1438 # 80009828 <syscalls+0x2b8>
    80005dce:	ffffa097          	auipc	ra,0xffffa
    80005dd2:	760080e7          	jalr	1888(ra) # 8000052e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005dd6:	874a                	mv	a4,s2
    80005dd8:	009c86bb          	addw	a3,s9,s1
    80005ddc:	4581                	li	a1,0
    80005dde:	8556                	mv	a0,s5
    80005de0:	fffff097          	auipc	ra,0xfffff
    80005de4:	c3a080e7          	jalr	-966(ra) # 80004a1a <readi>
    80005de8:	2501                	sext.w	a0,a0
    80005dea:	1ea91263          	bne	s2,a0,80005fce <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80005dee:	009d84bb          	addw	s1,s11,s1
    80005df2:	013d09bb          	addw	s3,s10,s3
    80005df6:	2174fd63          	bgeu	s1,s7,80006010 <exec+0x3ac>
    pa = walkaddr(pagetable, va + i);
    80005dfa:	02049593          	slli	a1,s1,0x20
    80005dfe:	9181                	srli	a1,a1,0x20
    80005e00:	95e2                	add	a1,a1,s8
    80005e02:	e0843503          	ld	a0,-504(s0)
    80005e06:	ffffb097          	auipc	ra,0xffffb
    80005e0a:	26c080e7          	jalr	620(ra) # 80001072 <walkaddr>
    80005e0e:	862a                	mv	a2,a0
    if(pa == 0)
    80005e10:	d95d                	beqz	a0,80005dc6 <exec+0x162>
      n = PGSIZE;
    80005e12:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80005e14:	fd49f1e3          	bgeu	s3,s4,80005dd6 <exec+0x172>
      n = sz - i;
    80005e18:	894e                	mv	s2,s3
    80005e1a:	bf75                	j	80005dd6 <exec+0x172>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005e1c:	4481                	li	s1,0
  iunlockput(ip);
    80005e1e:	8556                	mv	a0,s5
    80005e20:	fffff097          	auipc	ra,0xfffff
    80005e24:	ba8080e7          	jalr	-1112(ra) # 800049c8 <iunlockput>
  end_op();
    80005e28:	fffff097          	auipc	ra,0xfffff
    80005e2c:	392080e7          	jalr	914(ra) # 800051ba <end_op>
  p = myproc();
    80005e30:	ffffc097          	auipc	ra,0xffffc
    80005e34:	c4c080e7          	jalr	-948(ra) # 80001a7c <myproc>
    80005e38:	8a2a                	mv	s4,a0
  uint64 oldsz = p->sz;
    80005e3a:	03853d03          	ld	s10,56(a0)
  sz = PGROUNDUP(sz);
    80005e3e:	6785                	lui	a5,0x1
    80005e40:	17fd                	addi	a5,a5,-1
    80005e42:	94be                	add	s1,s1,a5
    80005e44:	77fd                	lui	a5,0xfffff
    80005e46:	8fe5                	and	a5,a5,s1
    80005e48:	def43423          	sd	a5,-536(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005e4c:	6609                	lui	a2,0x2
    80005e4e:	963e                	add	a2,a2,a5
    80005e50:	85be                	mv	a1,a5
    80005e52:	e0843483          	ld	s1,-504(s0)
    80005e56:	8526                	mv	a0,s1
    80005e58:	ffffb097          	auipc	ra,0xffffb
    80005e5c:	5bc080e7          	jalr	1468(ra) # 80001414 <uvmalloc>
    80005e60:	8caa                	mv	s9,a0
  ip = 0;
    80005e62:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005e64:	16050563          	beqz	a0,80005fce <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005e68:	75f9                	lui	a1,0xffffe
    80005e6a:	95aa                	add	a1,a1,a0
    80005e6c:	8526                	mv	a0,s1
    80005e6e:	ffffb097          	auipc	ra,0xffffb
    80005e72:	7c4080e7          	jalr	1988(ra) # 80001632 <uvmclear>
  stackbase = sp - PGSIZE;
    80005e76:	7bfd                	lui	s7,0xfffff
    80005e78:	9be6                	add	s7,s7,s9
  for(argc = 0; argv[argc]; argc++) {
    80005e7a:	de043783          	ld	a5,-544(s0)
    80005e7e:	6388                	ld	a0,0(a5)
    80005e80:	c92d                	beqz	a0,80005ef2 <exec+0x28e>
    80005e82:	e8840993          	addi	s3,s0,-376
    80005e86:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80005e8a:	8966                	mv	s2,s9
  for(argc = 0; argv[argc]; argc++) {
    80005e8c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005e8e:	ffffb097          	auipc	ra,0xffffb
    80005e92:	fda080e7          	jalr	-38(ra) # 80000e68 <strlen>
    80005e96:	0015079b          	addiw	a5,a0,1
    80005e9a:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005e9e:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005ea2:	15796b63          	bltu	s2,s7,80005ff8 <exec+0x394>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005ea6:	de043d83          	ld	s11,-544(s0)
    80005eaa:	000dba83          	ld	s5,0(s11) # 1000 <_entry-0x7ffff000>
    80005eae:	8556                	mv	a0,s5
    80005eb0:	ffffb097          	auipc	ra,0xffffb
    80005eb4:	fb8080e7          	jalr	-72(ra) # 80000e68 <strlen>
    80005eb8:	0015069b          	addiw	a3,a0,1
    80005ebc:	8656                	mv	a2,s5
    80005ebe:	85ca                	mv	a1,s2
    80005ec0:	e0843503          	ld	a0,-504(s0)
    80005ec4:	ffffb097          	auipc	ra,0xffffb
    80005ec8:	7a0080e7          	jalr	1952(ra) # 80001664 <copyout>
    80005ecc:	12054a63          	bltz	a0,80006000 <exec+0x39c>
    ustack[argc] = sp;
    80005ed0:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005ed4:	0485                	addi	s1,s1,1
    80005ed6:	008d8793          	addi	a5,s11,8
    80005eda:	def43023          	sd	a5,-544(s0)
    80005ede:	008db503          	ld	a0,8(s11)
    80005ee2:	c911                	beqz	a0,80005ef6 <exec+0x292>
    if(argc >= MAXARG)
    80005ee4:	09a1                	addi	s3,s3,8
    80005ee6:	fb3c14e3          	bne	s8,s3,80005e8e <exec+0x22a>
  sz = sz1;
    80005eea:	df943423          	sd	s9,-536(s0)
  ip = 0;
    80005eee:	4a81                	li	s5,0
    80005ef0:	a8f9                	j	80005fce <exec+0x36a>
  sp = sz;
    80005ef2:	8966                	mv	s2,s9
  for(argc = 0; argv[argc]; argc++) {
    80005ef4:	4481                	li	s1,0
  ustack[argc] = 0;
    80005ef6:	00349793          	slli	a5,s1,0x3
    80005efa:	f9040713          	addi	a4,s0,-112
    80005efe:	97ba                	add	a5,a5,a4
    80005f00:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffbcef8>
  sp -= (argc+1) * sizeof(uint64);
    80005f04:	00148693          	addi	a3,s1,1
    80005f08:	068e                	slli	a3,a3,0x3
    80005f0a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005f0e:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005f12:	01797663          	bgeu	s2,s7,80005f1e <exec+0x2ba>
  sz = sz1;
    80005f16:	df943423          	sd	s9,-536(s0)
  ip = 0;
    80005f1a:	4a81                	li	s5,0
    80005f1c:	a84d                	j	80005fce <exec+0x36a>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005f1e:	e8840613          	addi	a2,s0,-376
    80005f22:	85ca                	mv	a1,s2
    80005f24:	e0843503          	ld	a0,-504(s0)
    80005f28:	ffffb097          	auipc	ra,0xffffb
    80005f2c:	73c080e7          	jalr	1852(ra) # 80001664 <copyout>
    80005f30:	0c054c63          	bltz	a0,80006008 <exec+0x3a4>
  t->trapframe->a1 = sp;
    80005f34:	040b3783          	ld	a5,64(s6)
    80005f38:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005f3c:	df043783          	ld	a5,-528(s0)
    80005f40:	0007c703          	lbu	a4,0(a5)
    80005f44:	cf11                	beqz	a4,80005f60 <exec+0x2fc>
    80005f46:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005f48:	02f00693          	li	a3,47
    80005f4c:	a039                	j	80005f5a <exec+0x2f6>
      last = s+1;
    80005f4e:	def43823          	sd	a5,-528(s0)
  for(last=s=path; *s; s++)
    80005f52:	0785                	addi	a5,a5,1
    80005f54:	fff7c703          	lbu	a4,-1(a5)
    80005f58:	c701                	beqz	a4,80005f60 <exec+0x2fc>
    if(*s == '/')
    80005f5a:	fed71ce3          	bne	a4,a3,80005f52 <exec+0x2ee>
    80005f5e:	bfc5                	j	80005f4e <exec+0x2ea>
  safestrcpy(p->name, last, sizeof(p->name));
    80005f60:	4641                	li	a2,16
    80005f62:	df043583          	ld	a1,-528(s0)
    80005f66:	0d8a0513          	addi	a0,s4,216
    80005f6a:	ffffb097          	auipc	ra,0xffffb
    80005f6e:	ecc080e7          	jalr	-308(ra) # 80000e36 <safestrcpy>
  for(int i=0; i<32; i++){
    80005f72:	0f8a0793          	addi	a5,s4,248
    80005f76:	1f8a0713          	addi	a4,s4,504
    80005f7a:	85ba                	mv	a1,a4
    if(!((p->signal_handlers[i]) == (void*)SIG_IGN)){
    80005f7c:	4605                	li	a2,1
    80005f7e:	a029                	j	80005f88 <exec+0x324>
  for(int i=0; i<32; i++){
    80005f80:	07a1                	addi	a5,a5,8
    80005f82:	0711                	addi	a4,a4,4
    80005f84:	00f58a63          	beq	a1,a5,80005f98 <exec+0x334>
    if(!((p->signal_handlers[i]) == (void*)SIG_IGN)){
    80005f88:	6394                	ld	a3,0(a5)
    80005f8a:	fec68be3          	beq	a3,a2,80005f80 <exec+0x31c>
        p->signal_handlers[i]=SIG_DFL;
    80005f8e:	0007b023          	sd	zero,0(a5)
        p->handlers_sigmasks[i]=0;   
    80005f92:	00072023          	sw	zero,0(a4)
    80005f96:	b7ed                	j	80005f80 <exec+0x31c>
  oldpagetable = p->pagetable;
    80005f98:	040a3503          	ld	a0,64(s4)
  p->pagetable = pagetable;
    80005f9c:	e0843783          	ld	a5,-504(s0)
    80005fa0:	04fa3023          	sd	a5,64(s4)
  p->sz = sz;
    80005fa4:	039a3c23          	sd	s9,56(s4)
  t->trapframe->epc = elf.entry;  // initial program counter = main
    80005fa8:	040b3783          	ld	a5,64(s6)
    80005fac:	e6043703          	ld	a4,-416(s0)
    80005fb0:	ef98                	sd	a4,24(a5)
  t->trapframe->sp = sp; // initial stack pointer
    80005fb2:	040b3783          	ld	a5,64(s6)
    80005fb6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005fba:	85ea                	mv	a1,s10
    80005fbc:	ffffc097          	auipc	ra,0xffffc
    80005fc0:	cf8080e7          	jalr	-776(ra) # 80001cb4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005fc4:	0004851b          	sext.w	a0,s1
    80005fc8:	bb59                	j	80005d5e <exec+0xfa>
    80005fca:	de943423          	sd	s1,-536(s0)
    proc_freepagetable(pagetable, sz);
    80005fce:	de843583          	ld	a1,-536(s0)
    80005fd2:	e0843503          	ld	a0,-504(s0)
    80005fd6:	ffffc097          	auipc	ra,0xffffc
    80005fda:	cde080e7          	jalr	-802(ra) # 80001cb4 <proc_freepagetable>
  if(ip){
    80005fde:	d60a96e3          	bnez	s5,80005d4a <exec+0xe6>
  return -1;
    80005fe2:	557d                	li	a0,-1
    80005fe4:	bbad                	j	80005d5e <exec+0xfa>
    80005fe6:	de943423          	sd	s1,-536(s0)
    80005fea:	b7d5                	j	80005fce <exec+0x36a>
    80005fec:	de943423          	sd	s1,-536(s0)
    80005ff0:	bff9                	j	80005fce <exec+0x36a>
    80005ff2:	de943423          	sd	s1,-536(s0)
    80005ff6:	bfe1                	j	80005fce <exec+0x36a>
  sz = sz1;
    80005ff8:	df943423          	sd	s9,-536(s0)
  ip = 0;
    80005ffc:	4a81                	li	s5,0
    80005ffe:	bfc1                	j	80005fce <exec+0x36a>
  sz = sz1;
    80006000:	df943423          	sd	s9,-536(s0)
  ip = 0;
    80006004:	4a81                	li	s5,0
    80006006:	b7e1                	j	80005fce <exec+0x36a>
  sz = sz1;
    80006008:	df943423          	sd	s9,-536(s0)
  ip = 0;
    8000600c:	4a81                	li	s5,0
    8000600e:	b7c1                	j	80005fce <exec+0x36a>
    sz = sz1;
    80006010:	de843483          	ld	s1,-536(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006014:	e0043783          	ld	a5,-512(s0)
    80006018:	0017869b          	addiw	a3,a5,1
    8000601c:	e0d43023          	sd	a3,-512(s0)
    80006020:	df843783          	ld	a5,-520(s0)
    80006024:	0387879b          	addiw	a5,a5,56
    80006028:	e8045703          	lhu	a4,-384(s0)
    8000602c:	dee6d9e3          	bge	a3,a4,80005e1e <exec+0x1ba>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80006030:	2781                	sext.w	a5,a5
    80006032:	def43c23          	sd	a5,-520(s0)
    80006036:	03800713          	li	a4,56
    8000603a:	86be                	mv	a3,a5
    8000603c:	e1040613          	addi	a2,s0,-496
    80006040:	4581                	li	a1,0
    80006042:	8556                	mv	a0,s5
    80006044:	fffff097          	auipc	ra,0xfffff
    80006048:	9d6080e7          	jalr	-1578(ra) # 80004a1a <readi>
    8000604c:	03800793          	li	a5,56
    80006050:	f6f51de3          	bne	a0,a5,80005fca <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80006054:	e1042783          	lw	a5,-496(s0)
    80006058:	4705                	li	a4,1
    8000605a:	fae79de3          	bne	a5,a4,80006014 <exec+0x3b0>
    if(ph.memsz < ph.filesz)
    8000605e:	e3843603          	ld	a2,-456(s0)
    80006062:	e3043783          	ld	a5,-464(s0)
    80006066:	f8f660e3          	bltu	a2,a5,80005fe6 <exec+0x382>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000606a:	e2043783          	ld	a5,-480(s0)
    8000606e:	963e                	add	a2,a2,a5
    80006070:	f6f66ee3          	bltu	a2,a5,80005fec <exec+0x388>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80006074:	85a6                	mv	a1,s1
    80006076:	e0843503          	ld	a0,-504(s0)
    8000607a:	ffffb097          	auipc	ra,0xffffb
    8000607e:	39a080e7          	jalr	922(ra) # 80001414 <uvmalloc>
    80006082:	dea43423          	sd	a0,-536(s0)
    80006086:	d535                	beqz	a0,80005ff2 <exec+0x38e>
    if(ph.vaddr % PGSIZE != 0)
    80006088:	e2043c03          	ld	s8,-480(s0)
    8000608c:	dd843783          	ld	a5,-552(s0)
    80006090:	00fc77b3          	and	a5,s8,a5
    80006094:	ff8d                	bnez	a5,80005fce <exec+0x36a>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80006096:	e1842c83          	lw	s9,-488(s0)
    8000609a:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000609e:	f60b89e3          	beqz	s7,80006010 <exec+0x3ac>
    800060a2:	89de                	mv	s3,s7
    800060a4:	4481                	li	s1,0
    800060a6:	bb91                	j	80005dfa <exec+0x196>

00000000800060a8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800060a8:	7179                	addi	sp,sp,-48
    800060aa:	f406                	sd	ra,40(sp)
    800060ac:	f022                	sd	s0,32(sp)
    800060ae:	ec26                	sd	s1,24(sp)
    800060b0:	e84a                	sd	s2,16(sp)
    800060b2:	1800                	addi	s0,sp,48
    800060b4:	892e                	mv	s2,a1
    800060b6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800060b8:	fdc40593          	addi	a1,s0,-36
    800060bc:	ffffe097          	auipc	ra,0xffffe
    800060c0:	960080e7          	jalr	-1696(ra) # 80003a1c <argint>
    800060c4:	04054063          	bltz	a0,80006104 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800060c8:	fdc42703          	lw	a4,-36(s0)
    800060cc:	47bd                	li	a5,15
    800060ce:	02e7ed63          	bltu	a5,a4,80006108 <argfd+0x60>
    800060d2:	ffffc097          	auipc	ra,0xffffc
    800060d6:	9aa080e7          	jalr	-1622(ra) # 80001a7c <myproc>
    800060da:	fdc42703          	lw	a4,-36(s0)
    800060de:	00a70793          	addi	a5,a4,10
    800060e2:	078e                	slli	a5,a5,0x3
    800060e4:	953e                	add	a0,a0,a5
    800060e6:	611c                	ld	a5,0(a0)
    800060e8:	c395                	beqz	a5,8000610c <argfd+0x64>
    return -1;
  if(pfd)
    800060ea:	00090463          	beqz	s2,800060f2 <argfd+0x4a>
    *pfd = fd;
    800060ee:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800060f2:	4501                	li	a0,0
  if(pf)
    800060f4:	c091                	beqz	s1,800060f8 <argfd+0x50>
    *pf = f;
    800060f6:	e09c                	sd	a5,0(s1)
}
    800060f8:	70a2                	ld	ra,40(sp)
    800060fa:	7402                	ld	s0,32(sp)
    800060fc:	64e2                	ld	s1,24(sp)
    800060fe:	6942                	ld	s2,16(sp)
    80006100:	6145                	addi	sp,sp,48
    80006102:	8082                	ret
    return -1;
    80006104:	557d                	li	a0,-1
    80006106:	bfcd                	j	800060f8 <argfd+0x50>
    return -1;
    80006108:	557d                	li	a0,-1
    8000610a:	b7fd                	j	800060f8 <argfd+0x50>
    8000610c:	557d                	li	a0,-1
    8000610e:	b7ed                	j	800060f8 <argfd+0x50>

0000000080006110 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80006110:	1101                	addi	sp,sp,-32
    80006112:	ec06                	sd	ra,24(sp)
    80006114:	e822                	sd	s0,16(sp)
    80006116:	e426                	sd	s1,8(sp)
    80006118:	1000                	addi	s0,sp,32
    8000611a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000611c:	ffffc097          	auipc	ra,0xffffc
    80006120:	960080e7          	jalr	-1696(ra) # 80001a7c <myproc>
    80006124:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80006126:	05050793          	addi	a5,a0,80
    8000612a:	4501                	li	a0,0
    8000612c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000612e:	6398                	ld	a4,0(a5)
    80006130:	cb19                	beqz	a4,80006146 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80006132:	2505                	addiw	a0,a0,1
    80006134:	07a1                	addi	a5,a5,8
    80006136:	fed51ce3          	bne	a0,a3,8000612e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000613a:	557d                	li	a0,-1
}
    8000613c:	60e2                	ld	ra,24(sp)
    8000613e:	6442                	ld	s0,16(sp)
    80006140:	64a2                	ld	s1,8(sp)
    80006142:	6105                	addi	sp,sp,32
    80006144:	8082                	ret
      p->ofile[fd] = f;
    80006146:	00a50793          	addi	a5,a0,10
    8000614a:	078e                	slli	a5,a5,0x3
    8000614c:	963e                	add	a2,a2,a5
    8000614e:	e204                	sd	s1,0(a2)
      return fd;
    80006150:	b7f5                	j	8000613c <fdalloc+0x2c>

0000000080006152 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80006152:	715d                	addi	sp,sp,-80
    80006154:	e486                	sd	ra,72(sp)
    80006156:	e0a2                	sd	s0,64(sp)
    80006158:	fc26                	sd	s1,56(sp)
    8000615a:	f84a                	sd	s2,48(sp)
    8000615c:	f44e                	sd	s3,40(sp)
    8000615e:	f052                	sd	s4,32(sp)
    80006160:	ec56                	sd	s5,24(sp)
    80006162:	0880                	addi	s0,sp,80
    80006164:	89ae                	mv	s3,a1
    80006166:	8ab2                	mv	s5,a2
    80006168:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000616a:	fb040593          	addi	a1,s0,-80
    8000616e:	fffff097          	auipc	ra,0xfffff
    80006172:	dca080e7          	jalr	-566(ra) # 80004f38 <nameiparent>
    80006176:	892a                	mv	s2,a0
    80006178:	12050e63          	beqz	a0,800062b4 <create+0x162>
    return 0;

  ilock(dp);
    8000617c:	ffffe097          	auipc	ra,0xffffe
    80006180:	5ea080e7          	jalr	1514(ra) # 80004766 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80006184:	4601                	li	a2,0
    80006186:	fb040593          	addi	a1,s0,-80
    8000618a:	854a                	mv	a0,s2
    8000618c:	fffff097          	auipc	ra,0xfffff
    80006190:	abe080e7          	jalr	-1346(ra) # 80004c4a <dirlookup>
    80006194:	84aa                	mv	s1,a0
    80006196:	c921                	beqz	a0,800061e6 <create+0x94>
    iunlockput(dp);
    80006198:	854a                	mv	a0,s2
    8000619a:	fffff097          	auipc	ra,0xfffff
    8000619e:	82e080e7          	jalr	-2002(ra) # 800049c8 <iunlockput>
    ilock(ip);
    800061a2:	8526                	mv	a0,s1
    800061a4:	ffffe097          	auipc	ra,0xffffe
    800061a8:	5c2080e7          	jalr	1474(ra) # 80004766 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800061ac:	2981                	sext.w	s3,s3
    800061ae:	4789                	li	a5,2
    800061b0:	02f99463          	bne	s3,a5,800061d8 <create+0x86>
    800061b4:	0444d783          	lhu	a5,68(s1)
    800061b8:	37f9                	addiw	a5,a5,-2
    800061ba:	17c2                	slli	a5,a5,0x30
    800061bc:	93c1                	srli	a5,a5,0x30
    800061be:	4705                	li	a4,1
    800061c0:	00f76c63          	bltu	a4,a5,800061d8 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800061c4:	8526                	mv	a0,s1
    800061c6:	60a6                	ld	ra,72(sp)
    800061c8:	6406                	ld	s0,64(sp)
    800061ca:	74e2                	ld	s1,56(sp)
    800061cc:	7942                	ld	s2,48(sp)
    800061ce:	79a2                	ld	s3,40(sp)
    800061d0:	7a02                	ld	s4,32(sp)
    800061d2:	6ae2                	ld	s5,24(sp)
    800061d4:	6161                	addi	sp,sp,80
    800061d6:	8082                	ret
    iunlockput(ip);
    800061d8:	8526                	mv	a0,s1
    800061da:	ffffe097          	auipc	ra,0xffffe
    800061de:	7ee080e7          	jalr	2030(ra) # 800049c8 <iunlockput>
    return 0;
    800061e2:	4481                	li	s1,0
    800061e4:	b7c5                	j	800061c4 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800061e6:	85ce                	mv	a1,s3
    800061e8:	00092503          	lw	a0,0(s2)
    800061ec:	ffffe097          	auipc	ra,0xffffe
    800061f0:	3e2080e7          	jalr	994(ra) # 800045ce <ialloc>
    800061f4:	84aa                	mv	s1,a0
    800061f6:	c521                	beqz	a0,8000623e <create+0xec>
  ilock(ip);
    800061f8:	ffffe097          	auipc	ra,0xffffe
    800061fc:	56e080e7          	jalr	1390(ra) # 80004766 <ilock>
  ip->major = major;
    80006200:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80006204:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80006208:	4a05                	li	s4,1
    8000620a:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    8000620e:	8526                	mv	a0,s1
    80006210:	ffffe097          	auipc	ra,0xffffe
    80006214:	48c080e7          	jalr	1164(ra) # 8000469c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80006218:	2981                	sext.w	s3,s3
    8000621a:	03498a63          	beq	s3,s4,8000624e <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000621e:	40d0                	lw	a2,4(s1)
    80006220:	fb040593          	addi	a1,s0,-80
    80006224:	854a                	mv	a0,s2
    80006226:	fffff097          	auipc	ra,0xfffff
    8000622a:	c32080e7          	jalr	-974(ra) # 80004e58 <dirlink>
    8000622e:	06054b63          	bltz	a0,800062a4 <create+0x152>
  iunlockput(dp);
    80006232:	854a                	mv	a0,s2
    80006234:	ffffe097          	auipc	ra,0xffffe
    80006238:	794080e7          	jalr	1940(ra) # 800049c8 <iunlockput>
  return ip;
    8000623c:	b761                	j	800061c4 <create+0x72>
    panic("create: ialloc");
    8000623e:	00003517          	auipc	a0,0x3
    80006242:	60a50513          	addi	a0,a0,1546 # 80009848 <syscalls+0x2d8>
    80006246:	ffffa097          	auipc	ra,0xffffa
    8000624a:	2e8080e7          	jalr	744(ra) # 8000052e <panic>
    dp->nlink++;  // for ".."
    8000624e:	04a95783          	lhu	a5,74(s2)
    80006252:	2785                	addiw	a5,a5,1
    80006254:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80006258:	854a                	mv	a0,s2
    8000625a:	ffffe097          	auipc	ra,0xffffe
    8000625e:	442080e7          	jalr	1090(ra) # 8000469c <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80006262:	40d0                	lw	a2,4(s1)
    80006264:	00003597          	auipc	a1,0x3
    80006268:	5f458593          	addi	a1,a1,1524 # 80009858 <syscalls+0x2e8>
    8000626c:	8526                	mv	a0,s1
    8000626e:	fffff097          	auipc	ra,0xfffff
    80006272:	bea080e7          	jalr	-1046(ra) # 80004e58 <dirlink>
    80006276:	00054f63          	bltz	a0,80006294 <create+0x142>
    8000627a:	00492603          	lw	a2,4(s2)
    8000627e:	00003597          	auipc	a1,0x3
    80006282:	5e258593          	addi	a1,a1,1506 # 80009860 <syscalls+0x2f0>
    80006286:	8526                	mv	a0,s1
    80006288:	fffff097          	auipc	ra,0xfffff
    8000628c:	bd0080e7          	jalr	-1072(ra) # 80004e58 <dirlink>
    80006290:	f80557e3          	bgez	a0,8000621e <create+0xcc>
      panic("create dots");
    80006294:	00003517          	auipc	a0,0x3
    80006298:	5d450513          	addi	a0,a0,1492 # 80009868 <syscalls+0x2f8>
    8000629c:	ffffa097          	auipc	ra,0xffffa
    800062a0:	292080e7          	jalr	658(ra) # 8000052e <panic>
    panic("create: dirlink");
    800062a4:	00003517          	auipc	a0,0x3
    800062a8:	5d450513          	addi	a0,a0,1492 # 80009878 <syscalls+0x308>
    800062ac:	ffffa097          	auipc	ra,0xffffa
    800062b0:	282080e7          	jalr	642(ra) # 8000052e <panic>
    return 0;
    800062b4:	84aa                	mv	s1,a0
    800062b6:	b739                	j	800061c4 <create+0x72>

00000000800062b8 <sys_dup>:
{
    800062b8:	7179                	addi	sp,sp,-48
    800062ba:	f406                	sd	ra,40(sp)
    800062bc:	f022                	sd	s0,32(sp)
    800062be:	ec26                	sd	s1,24(sp)
    800062c0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800062c2:	fd840613          	addi	a2,s0,-40
    800062c6:	4581                	li	a1,0
    800062c8:	4501                	li	a0,0
    800062ca:	00000097          	auipc	ra,0x0
    800062ce:	dde080e7          	jalr	-546(ra) # 800060a8 <argfd>
    return -1;
    800062d2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800062d4:	02054363          	bltz	a0,800062fa <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    800062d8:	fd843503          	ld	a0,-40(s0)
    800062dc:	00000097          	auipc	ra,0x0
    800062e0:	e34080e7          	jalr	-460(ra) # 80006110 <fdalloc>
    800062e4:	84aa                	mv	s1,a0
    return -1;
    800062e6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800062e8:	00054963          	bltz	a0,800062fa <sys_dup+0x42>
  filedup(f);
    800062ec:	fd843503          	ld	a0,-40(s0)
    800062f0:	fffff097          	auipc	ra,0xfffff
    800062f4:	2c4080e7          	jalr	708(ra) # 800055b4 <filedup>
  return fd;
    800062f8:	87a6                	mv	a5,s1
}
    800062fa:	853e                	mv	a0,a5
    800062fc:	70a2                	ld	ra,40(sp)
    800062fe:	7402                	ld	s0,32(sp)
    80006300:	64e2                	ld	s1,24(sp)
    80006302:	6145                	addi	sp,sp,48
    80006304:	8082                	ret

0000000080006306 <sys_read>:
{
    80006306:	7179                	addi	sp,sp,-48
    80006308:	f406                	sd	ra,40(sp)
    8000630a:	f022                	sd	s0,32(sp)
    8000630c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000630e:	fe840613          	addi	a2,s0,-24
    80006312:	4581                	li	a1,0
    80006314:	4501                	li	a0,0
    80006316:	00000097          	auipc	ra,0x0
    8000631a:	d92080e7          	jalr	-622(ra) # 800060a8 <argfd>
    return -1;
    8000631e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006320:	04054163          	bltz	a0,80006362 <sys_read+0x5c>
    80006324:	fe440593          	addi	a1,s0,-28
    80006328:	4509                	li	a0,2
    8000632a:	ffffd097          	auipc	ra,0xffffd
    8000632e:	6f2080e7          	jalr	1778(ra) # 80003a1c <argint>
    return -1;
    80006332:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006334:	02054763          	bltz	a0,80006362 <sys_read+0x5c>
    80006338:	fd840593          	addi	a1,s0,-40
    8000633c:	4505                	li	a0,1
    8000633e:	ffffd097          	auipc	ra,0xffffd
    80006342:	700080e7          	jalr	1792(ra) # 80003a3e <argaddr>
    return -1;
    80006346:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006348:	00054d63          	bltz	a0,80006362 <sys_read+0x5c>
  return fileread(f, p, n);
    8000634c:	fe442603          	lw	a2,-28(s0)
    80006350:	fd843583          	ld	a1,-40(s0)
    80006354:	fe843503          	ld	a0,-24(s0)
    80006358:	fffff097          	auipc	ra,0xfffff
    8000635c:	3e8080e7          	jalr	1000(ra) # 80005740 <fileread>
    80006360:	87aa                	mv	a5,a0
}
    80006362:	853e                	mv	a0,a5
    80006364:	70a2                	ld	ra,40(sp)
    80006366:	7402                	ld	s0,32(sp)
    80006368:	6145                	addi	sp,sp,48
    8000636a:	8082                	ret

000000008000636c <sys_write>:
{
    8000636c:	7179                	addi	sp,sp,-48
    8000636e:	f406                	sd	ra,40(sp)
    80006370:	f022                	sd	s0,32(sp)
    80006372:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006374:	fe840613          	addi	a2,s0,-24
    80006378:	4581                	li	a1,0
    8000637a:	4501                	li	a0,0
    8000637c:	00000097          	auipc	ra,0x0
    80006380:	d2c080e7          	jalr	-724(ra) # 800060a8 <argfd>
    return -1;
    80006384:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80006386:	04054163          	bltz	a0,800063c8 <sys_write+0x5c>
    8000638a:	fe440593          	addi	a1,s0,-28
    8000638e:	4509                	li	a0,2
    80006390:	ffffd097          	auipc	ra,0xffffd
    80006394:	68c080e7          	jalr	1676(ra) # 80003a1c <argint>
    return -1;
    80006398:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000639a:	02054763          	bltz	a0,800063c8 <sys_write+0x5c>
    8000639e:	fd840593          	addi	a1,s0,-40
    800063a2:	4505                	li	a0,1
    800063a4:	ffffd097          	auipc	ra,0xffffd
    800063a8:	69a080e7          	jalr	1690(ra) # 80003a3e <argaddr>
    return -1;
    800063ac:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800063ae:	00054d63          	bltz	a0,800063c8 <sys_write+0x5c>
  return filewrite(f, p, n);
    800063b2:	fe442603          	lw	a2,-28(s0)
    800063b6:	fd843583          	ld	a1,-40(s0)
    800063ba:	fe843503          	ld	a0,-24(s0)
    800063be:	fffff097          	auipc	ra,0xfffff
    800063c2:	444080e7          	jalr	1092(ra) # 80005802 <filewrite>
    800063c6:	87aa                	mv	a5,a0
}
    800063c8:	853e                	mv	a0,a5
    800063ca:	70a2                	ld	ra,40(sp)
    800063cc:	7402                	ld	s0,32(sp)
    800063ce:	6145                	addi	sp,sp,48
    800063d0:	8082                	ret

00000000800063d2 <sys_close>:
{
    800063d2:	1101                	addi	sp,sp,-32
    800063d4:	ec06                	sd	ra,24(sp)
    800063d6:	e822                	sd	s0,16(sp)
    800063d8:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800063da:	fe040613          	addi	a2,s0,-32
    800063de:	fec40593          	addi	a1,s0,-20
    800063e2:	4501                	li	a0,0
    800063e4:	00000097          	auipc	ra,0x0
    800063e8:	cc4080e7          	jalr	-828(ra) # 800060a8 <argfd>
    return -1;
    800063ec:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800063ee:	02054463          	bltz	a0,80006416 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800063f2:	ffffb097          	auipc	ra,0xffffb
    800063f6:	68a080e7          	jalr	1674(ra) # 80001a7c <myproc>
    800063fa:	fec42783          	lw	a5,-20(s0)
    800063fe:	07a9                	addi	a5,a5,10
    80006400:	078e                	slli	a5,a5,0x3
    80006402:	97aa                	add	a5,a5,a0
    80006404:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80006408:	fe043503          	ld	a0,-32(s0)
    8000640c:	fffff097          	auipc	ra,0xfffff
    80006410:	1fa080e7          	jalr	506(ra) # 80005606 <fileclose>
  return 0;
    80006414:	4781                	li	a5,0
}
    80006416:	853e                	mv	a0,a5
    80006418:	60e2                	ld	ra,24(sp)
    8000641a:	6442                	ld	s0,16(sp)
    8000641c:	6105                	addi	sp,sp,32
    8000641e:	8082                	ret

0000000080006420 <sys_fstat>:
{
    80006420:	1101                	addi	sp,sp,-32
    80006422:	ec06                	sd	ra,24(sp)
    80006424:	e822                	sd	s0,16(sp)
    80006426:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80006428:	fe840613          	addi	a2,s0,-24
    8000642c:	4581                	li	a1,0
    8000642e:	4501                	li	a0,0
    80006430:	00000097          	auipc	ra,0x0
    80006434:	c78080e7          	jalr	-904(ra) # 800060a8 <argfd>
    return -1;
    80006438:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000643a:	02054563          	bltz	a0,80006464 <sys_fstat+0x44>
    8000643e:	fe040593          	addi	a1,s0,-32
    80006442:	4505                	li	a0,1
    80006444:	ffffd097          	auipc	ra,0xffffd
    80006448:	5fa080e7          	jalr	1530(ra) # 80003a3e <argaddr>
    return -1;
    8000644c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000644e:	00054b63          	bltz	a0,80006464 <sys_fstat+0x44>
  return filestat(f, st);
    80006452:	fe043583          	ld	a1,-32(s0)
    80006456:	fe843503          	ld	a0,-24(s0)
    8000645a:	fffff097          	auipc	ra,0xfffff
    8000645e:	274080e7          	jalr	628(ra) # 800056ce <filestat>
    80006462:	87aa                	mv	a5,a0
}
    80006464:	853e                	mv	a0,a5
    80006466:	60e2                	ld	ra,24(sp)
    80006468:	6442                	ld	s0,16(sp)
    8000646a:	6105                	addi	sp,sp,32
    8000646c:	8082                	ret

000000008000646e <sys_link>:
{
    8000646e:	7169                	addi	sp,sp,-304
    80006470:	f606                	sd	ra,296(sp)
    80006472:	f222                	sd	s0,288(sp)
    80006474:	ee26                	sd	s1,280(sp)
    80006476:	ea4a                	sd	s2,272(sp)
    80006478:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000647a:	08000613          	li	a2,128
    8000647e:	ed040593          	addi	a1,s0,-304
    80006482:	4501                	li	a0,0
    80006484:	ffffd097          	auipc	ra,0xffffd
    80006488:	5dc080e7          	jalr	1500(ra) # 80003a60 <argstr>
    return -1;
    8000648c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000648e:	10054e63          	bltz	a0,800065aa <sys_link+0x13c>
    80006492:	08000613          	li	a2,128
    80006496:	f5040593          	addi	a1,s0,-176
    8000649a:	4505                	li	a0,1
    8000649c:	ffffd097          	auipc	ra,0xffffd
    800064a0:	5c4080e7          	jalr	1476(ra) # 80003a60 <argstr>
    return -1;
    800064a4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800064a6:	10054263          	bltz	a0,800065aa <sys_link+0x13c>
  begin_op();
    800064aa:	fffff097          	auipc	ra,0xfffff
    800064ae:	c90080e7          	jalr	-880(ra) # 8000513a <begin_op>
  if((ip = namei(old)) == 0){
    800064b2:	ed040513          	addi	a0,s0,-304
    800064b6:	fffff097          	auipc	ra,0xfffff
    800064ba:	a64080e7          	jalr	-1436(ra) # 80004f1a <namei>
    800064be:	84aa                	mv	s1,a0
    800064c0:	c551                	beqz	a0,8000654c <sys_link+0xde>
  ilock(ip);
    800064c2:	ffffe097          	auipc	ra,0xffffe
    800064c6:	2a4080e7          	jalr	676(ra) # 80004766 <ilock>
  if(ip->type == T_DIR){
    800064ca:	04449703          	lh	a4,68(s1)
    800064ce:	4785                	li	a5,1
    800064d0:	08f70463          	beq	a4,a5,80006558 <sys_link+0xea>
  ip->nlink++;
    800064d4:	04a4d783          	lhu	a5,74(s1)
    800064d8:	2785                	addiw	a5,a5,1
    800064da:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800064de:	8526                	mv	a0,s1
    800064e0:	ffffe097          	auipc	ra,0xffffe
    800064e4:	1bc080e7          	jalr	444(ra) # 8000469c <iupdate>
  iunlock(ip);
    800064e8:	8526                	mv	a0,s1
    800064ea:	ffffe097          	auipc	ra,0xffffe
    800064ee:	33e080e7          	jalr	830(ra) # 80004828 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800064f2:	fd040593          	addi	a1,s0,-48
    800064f6:	f5040513          	addi	a0,s0,-176
    800064fa:	fffff097          	auipc	ra,0xfffff
    800064fe:	a3e080e7          	jalr	-1474(ra) # 80004f38 <nameiparent>
    80006502:	892a                	mv	s2,a0
    80006504:	c935                	beqz	a0,80006578 <sys_link+0x10a>
  ilock(dp);
    80006506:	ffffe097          	auipc	ra,0xffffe
    8000650a:	260080e7          	jalr	608(ra) # 80004766 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000650e:	00092703          	lw	a4,0(s2)
    80006512:	409c                	lw	a5,0(s1)
    80006514:	04f71d63          	bne	a4,a5,8000656e <sys_link+0x100>
    80006518:	40d0                	lw	a2,4(s1)
    8000651a:	fd040593          	addi	a1,s0,-48
    8000651e:	854a                	mv	a0,s2
    80006520:	fffff097          	auipc	ra,0xfffff
    80006524:	938080e7          	jalr	-1736(ra) # 80004e58 <dirlink>
    80006528:	04054363          	bltz	a0,8000656e <sys_link+0x100>
  iunlockput(dp);
    8000652c:	854a                	mv	a0,s2
    8000652e:	ffffe097          	auipc	ra,0xffffe
    80006532:	49a080e7          	jalr	1178(ra) # 800049c8 <iunlockput>
  iput(ip);
    80006536:	8526                	mv	a0,s1
    80006538:	ffffe097          	auipc	ra,0xffffe
    8000653c:	3e8080e7          	jalr	1000(ra) # 80004920 <iput>
  end_op();
    80006540:	fffff097          	auipc	ra,0xfffff
    80006544:	c7a080e7          	jalr	-902(ra) # 800051ba <end_op>
  return 0;
    80006548:	4781                	li	a5,0
    8000654a:	a085                	j	800065aa <sys_link+0x13c>
    end_op();
    8000654c:	fffff097          	auipc	ra,0xfffff
    80006550:	c6e080e7          	jalr	-914(ra) # 800051ba <end_op>
    return -1;
    80006554:	57fd                	li	a5,-1
    80006556:	a891                	j	800065aa <sys_link+0x13c>
    iunlockput(ip);
    80006558:	8526                	mv	a0,s1
    8000655a:	ffffe097          	auipc	ra,0xffffe
    8000655e:	46e080e7          	jalr	1134(ra) # 800049c8 <iunlockput>
    end_op();
    80006562:	fffff097          	auipc	ra,0xfffff
    80006566:	c58080e7          	jalr	-936(ra) # 800051ba <end_op>
    return -1;
    8000656a:	57fd                	li	a5,-1
    8000656c:	a83d                	j	800065aa <sys_link+0x13c>
    iunlockput(dp);
    8000656e:	854a                	mv	a0,s2
    80006570:	ffffe097          	auipc	ra,0xffffe
    80006574:	458080e7          	jalr	1112(ra) # 800049c8 <iunlockput>
  ilock(ip);
    80006578:	8526                	mv	a0,s1
    8000657a:	ffffe097          	auipc	ra,0xffffe
    8000657e:	1ec080e7          	jalr	492(ra) # 80004766 <ilock>
  ip->nlink--;
    80006582:	04a4d783          	lhu	a5,74(s1)
    80006586:	37fd                	addiw	a5,a5,-1
    80006588:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000658c:	8526                	mv	a0,s1
    8000658e:	ffffe097          	auipc	ra,0xffffe
    80006592:	10e080e7          	jalr	270(ra) # 8000469c <iupdate>
  iunlockput(ip);
    80006596:	8526                	mv	a0,s1
    80006598:	ffffe097          	auipc	ra,0xffffe
    8000659c:	430080e7          	jalr	1072(ra) # 800049c8 <iunlockput>
  end_op();
    800065a0:	fffff097          	auipc	ra,0xfffff
    800065a4:	c1a080e7          	jalr	-998(ra) # 800051ba <end_op>
  return -1;
    800065a8:	57fd                	li	a5,-1
}
    800065aa:	853e                	mv	a0,a5
    800065ac:	70b2                	ld	ra,296(sp)
    800065ae:	7412                	ld	s0,288(sp)
    800065b0:	64f2                	ld	s1,280(sp)
    800065b2:	6952                	ld	s2,272(sp)
    800065b4:	6155                	addi	sp,sp,304
    800065b6:	8082                	ret

00000000800065b8 <sys_unlink>:
{
    800065b8:	7151                	addi	sp,sp,-240
    800065ba:	f586                	sd	ra,232(sp)
    800065bc:	f1a2                	sd	s0,224(sp)
    800065be:	eda6                	sd	s1,216(sp)
    800065c0:	e9ca                	sd	s2,208(sp)
    800065c2:	e5ce                	sd	s3,200(sp)
    800065c4:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800065c6:	08000613          	li	a2,128
    800065ca:	f3040593          	addi	a1,s0,-208
    800065ce:	4501                	li	a0,0
    800065d0:	ffffd097          	auipc	ra,0xffffd
    800065d4:	490080e7          	jalr	1168(ra) # 80003a60 <argstr>
    800065d8:	18054163          	bltz	a0,8000675a <sys_unlink+0x1a2>
  begin_op();
    800065dc:	fffff097          	auipc	ra,0xfffff
    800065e0:	b5e080e7          	jalr	-1186(ra) # 8000513a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800065e4:	fb040593          	addi	a1,s0,-80
    800065e8:	f3040513          	addi	a0,s0,-208
    800065ec:	fffff097          	auipc	ra,0xfffff
    800065f0:	94c080e7          	jalr	-1716(ra) # 80004f38 <nameiparent>
    800065f4:	84aa                	mv	s1,a0
    800065f6:	c979                	beqz	a0,800066cc <sys_unlink+0x114>
  ilock(dp);
    800065f8:	ffffe097          	auipc	ra,0xffffe
    800065fc:	16e080e7          	jalr	366(ra) # 80004766 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80006600:	00003597          	auipc	a1,0x3
    80006604:	25858593          	addi	a1,a1,600 # 80009858 <syscalls+0x2e8>
    80006608:	fb040513          	addi	a0,s0,-80
    8000660c:	ffffe097          	auipc	ra,0xffffe
    80006610:	624080e7          	jalr	1572(ra) # 80004c30 <namecmp>
    80006614:	14050a63          	beqz	a0,80006768 <sys_unlink+0x1b0>
    80006618:	00003597          	auipc	a1,0x3
    8000661c:	24858593          	addi	a1,a1,584 # 80009860 <syscalls+0x2f0>
    80006620:	fb040513          	addi	a0,s0,-80
    80006624:	ffffe097          	auipc	ra,0xffffe
    80006628:	60c080e7          	jalr	1548(ra) # 80004c30 <namecmp>
    8000662c:	12050e63          	beqz	a0,80006768 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80006630:	f2c40613          	addi	a2,s0,-212
    80006634:	fb040593          	addi	a1,s0,-80
    80006638:	8526                	mv	a0,s1
    8000663a:	ffffe097          	auipc	ra,0xffffe
    8000663e:	610080e7          	jalr	1552(ra) # 80004c4a <dirlookup>
    80006642:	892a                	mv	s2,a0
    80006644:	12050263          	beqz	a0,80006768 <sys_unlink+0x1b0>
  ilock(ip);
    80006648:	ffffe097          	auipc	ra,0xffffe
    8000664c:	11e080e7          	jalr	286(ra) # 80004766 <ilock>
  if(ip->nlink < 1)
    80006650:	04a91783          	lh	a5,74(s2)
    80006654:	08f05263          	blez	a5,800066d8 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006658:	04491703          	lh	a4,68(s2)
    8000665c:	4785                	li	a5,1
    8000665e:	08f70563          	beq	a4,a5,800066e8 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80006662:	4641                	li	a2,16
    80006664:	4581                	li	a1,0
    80006666:	fc040513          	addi	a0,s0,-64
    8000666a:	ffffa097          	auipc	ra,0xffffa
    8000666e:	67a080e7          	jalr	1658(ra) # 80000ce4 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80006672:	4741                	li	a4,16
    80006674:	f2c42683          	lw	a3,-212(s0)
    80006678:	fc040613          	addi	a2,s0,-64
    8000667c:	4581                	li	a1,0
    8000667e:	8526                	mv	a0,s1
    80006680:	ffffe097          	auipc	ra,0xffffe
    80006684:	492080e7          	jalr	1170(ra) # 80004b12 <writei>
    80006688:	47c1                	li	a5,16
    8000668a:	0af51563          	bne	a0,a5,80006734 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000668e:	04491703          	lh	a4,68(s2)
    80006692:	4785                	li	a5,1
    80006694:	0af70863          	beq	a4,a5,80006744 <sys_unlink+0x18c>
  iunlockput(dp);
    80006698:	8526                	mv	a0,s1
    8000669a:	ffffe097          	auipc	ra,0xffffe
    8000669e:	32e080e7          	jalr	814(ra) # 800049c8 <iunlockput>
  ip->nlink--;
    800066a2:	04a95783          	lhu	a5,74(s2)
    800066a6:	37fd                	addiw	a5,a5,-1
    800066a8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800066ac:	854a                	mv	a0,s2
    800066ae:	ffffe097          	auipc	ra,0xffffe
    800066b2:	fee080e7          	jalr	-18(ra) # 8000469c <iupdate>
  iunlockput(ip);
    800066b6:	854a                	mv	a0,s2
    800066b8:	ffffe097          	auipc	ra,0xffffe
    800066bc:	310080e7          	jalr	784(ra) # 800049c8 <iunlockput>
  end_op();
    800066c0:	fffff097          	auipc	ra,0xfffff
    800066c4:	afa080e7          	jalr	-1286(ra) # 800051ba <end_op>
  return 0;
    800066c8:	4501                	li	a0,0
    800066ca:	a84d                	j	8000677c <sys_unlink+0x1c4>
    end_op();
    800066cc:	fffff097          	auipc	ra,0xfffff
    800066d0:	aee080e7          	jalr	-1298(ra) # 800051ba <end_op>
    return -1;
    800066d4:	557d                	li	a0,-1
    800066d6:	a05d                	j	8000677c <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800066d8:	00003517          	auipc	a0,0x3
    800066dc:	1b050513          	addi	a0,a0,432 # 80009888 <syscalls+0x318>
    800066e0:	ffffa097          	auipc	ra,0xffffa
    800066e4:	e4e080e7          	jalr	-434(ra) # 8000052e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800066e8:	04c92703          	lw	a4,76(s2)
    800066ec:	02000793          	li	a5,32
    800066f0:	f6e7f9e3          	bgeu	a5,a4,80006662 <sys_unlink+0xaa>
    800066f4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800066f8:	4741                	li	a4,16
    800066fa:	86ce                	mv	a3,s3
    800066fc:	f1840613          	addi	a2,s0,-232
    80006700:	4581                	li	a1,0
    80006702:	854a                	mv	a0,s2
    80006704:	ffffe097          	auipc	ra,0xffffe
    80006708:	316080e7          	jalr	790(ra) # 80004a1a <readi>
    8000670c:	47c1                	li	a5,16
    8000670e:	00f51b63          	bne	a0,a5,80006724 <sys_unlink+0x16c>
    if(de.inum != 0)
    80006712:	f1845783          	lhu	a5,-232(s0)
    80006716:	e7a1                	bnez	a5,8000675e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80006718:	29c1                	addiw	s3,s3,16
    8000671a:	04c92783          	lw	a5,76(s2)
    8000671e:	fcf9ede3          	bltu	s3,a5,800066f8 <sys_unlink+0x140>
    80006722:	b781                	j	80006662 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80006724:	00003517          	auipc	a0,0x3
    80006728:	17c50513          	addi	a0,a0,380 # 800098a0 <syscalls+0x330>
    8000672c:	ffffa097          	auipc	ra,0xffffa
    80006730:	e02080e7          	jalr	-510(ra) # 8000052e <panic>
    panic("unlink: writei");
    80006734:	00003517          	auipc	a0,0x3
    80006738:	18450513          	addi	a0,a0,388 # 800098b8 <syscalls+0x348>
    8000673c:	ffffa097          	auipc	ra,0xffffa
    80006740:	df2080e7          	jalr	-526(ra) # 8000052e <panic>
    dp->nlink--;
    80006744:	04a4d783          	lhu	a5,74(s1)
    80006748:	37fd                	addiw	a5,a5,-1
    8000674a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000674e:	8526                	mv	a0,s1
    80006750:	ffffe097          	auipc	ra,0xffffe
    80006754:	f4c080e7          	jalr	-180(ra) # 8000469c <iupdate>
    80006758:	b781                	j	80006698 <sys_unlink+0xe0>
    return -1;
    8000675a:	557d                	li	a0,-1
    8000675c:	a005                	j	8000677c <sys_unlink+0x1c4>
    iunlockput(ip);
    8000675e:	854a                	mv	a0,s2
    80006760:	ffffe097          	auipc	ra,0xffffe
    80006764:	268080e7          	jalr	616(ra) # 800049c8 <iunlockput>
  iunlockput(dp);
    80006768:	8526                	mv	a0,s1
    8000676a:	ffffe097          	auipc	ra,0xffffe
    8000676e:	25e080e7          	jalr	606(ra) # 800049c8 <iunlockput>
  end_op();
    80006772:	fffff097          	auipc	ra,0xfffff
    80006776:	a48080e7          	jalr	-1464(ra) # 800051ba <end_op>
  return -1;
    8000677a:	557d                	li	a0,-1
}
    8000677c:	70ae                	ld	ra,232(sp)
    8000677e:	740e                	ld	s0,224(sp)
    80006780:	64ee                	ld	s1,216(sp)
    80006782:	694e                	ld	s2,208(sp)
    80006784:	69ae                	ld	s3,200(sp)
    80006786:	616d                	addi	sp,sp,240
    80006788:	8082                	ret

000000008000678a <sys_open>:

uint64
sys_open(void)
{
    8000678a:	7131                	addi	sp,sp,-192
    8000678c:	fd06                	sd	ra,184(sp)
    8000678e:	f922                	sd	s0,176(sp)
    80006790:	f526                	sd	s1,168(sp)
    80006792:	f14a                	sd	s2,160(sp)
    80006794:	ed4e                	sd	s3,152(sp)
    80006796:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006798:	08000613          	li	a2,128
    8000679c:	f5040593          	addi	a1,s0,-176
    800067a0:	4501                	li	a0,0
    800067a2:	ffffd097          	auipc	ra,0xffffd
    800067a6:	2be080e7          	jalr	702(ra) # 80003a60 <argstr>
    return -1;
    800067aa:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800067ac:	0c054163          	bltz	a0,8000686e <sys_open+0xe4>
    800067b0:	f4c40593          	addi	a1,s0,-180
    800067b4:	4505                	li	a0,1
    800067b6:	ffffd097          	auipc	ra,0xffffd
    800067ba:	266080e7          	jalr	614(ra) # 80003a1c <argint>
    800067be:	0a054863          	bltz	a0,8000686e <sys_open+0xe4>

  begin_op();
    800067c2:	fffff097          	auipc	ra,0xfffff
    800067c6:	978080e7          	jalr	-1672(ra) # 8000513a <begin_op>

  if(omode & O_CREATE){
    800067ca:	f4c42783          	lw	a5,-180(s0)
    800067ce:	2007f793          	andi	a5,a5,512
    800067d2:	cbdd                	beqz	a5,80006888 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800067d4:	4681                	li	a3,0
    800067d6:	4601                	li	a2,0
    800067d8:	4589                	li	a1,2
    800067da:	f5040513          	addi	a0,s0,-176
    800067de:	00000097          	auipc	ra,0x0
    800067e2:	974080e7          	jalr	-1676(ra) # 80006152 <create>
    800067e6:	892a                	mv	s2,a0
    if(ip == 0){
    800067e8:	c959                	beqz	a0,8000687e <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800067ea:	04491703          	lh	a4,68(s2)
    800067ee:	478d                	li	a5,3
    800067f0:	00f71763          	bne	a4,a5,800067fe <sys_open+0x74>
    800067f4:	04695703          	lhu	a4,70(s2)
    800067f8:	47a5                	li	a5,9
    800067fa:	0ce7ec63          	bltu	a5,a4,800068d2 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800067fe:	fffff097          	auipc	ra,0xfffff
    80006802:	d4c080e7          	jalr	-692(ra) # 8000554a <filealloc>
    80006806:	89aa                	mv	s3,a0
    80006808:	10050263          	beqz	a0,8000690c <sys_open+0x182>
    8000680c:	00000097          	auipc	ra,0x0
    80006810:	904080e7          	jalr	-1788(ra) # 80006110 <fdalloc>
    80006814:	84aa                	mv	s1,a0
    80006816:	0e054663          	bltz	a0,80006902 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000681a:	04491703          	lh	a4,68(s2)
    8000681e:	478d                	li	a5,3
    80006820:	0cf70463          	beq	a4,a5,800068e8 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006824:	4789                	li	a5,2
    80006826:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000682a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000682e:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80006832:	f4c42783          	lw	a5,-180(s0)
    80006836:	0017c713          	xori	a4,a5,1
    8000683a:	8b05                	andi	a4,a4,1
    8000683c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80006840:	0037f713          	andi	a4,a5,3
    80006844:	00e03733          	snez	a4,a4
    80006848:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000684c:	4007f793          	andi	a5,a5,1024
    80006850:	c791                	beqz	a5,8000685c <sys_open+0xd2>
    80006852:	04491703          	lh	a4,68(s2)
    80006856:	4789                	li	a5,2
    80006858:	08f70f63          	beq	a4,a5,800068f6 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000685c:	854a                	mv	a0,s2
    8000685e:	ffffe097          	auipc	ra,0xffffe
    80006862:	fca080e7          	jalr	-54(ra) # 80004828 <iunlock>
  end_op();
    80006866:	fffff097          	auipc	ra,0xfffff
    8000686a:	954080e7          	jalr	-1708(ra) # 800051ba <end_op>

  return fd;
}
    8000686e:	8526                	mv	a0,s1
    80006870:	70ea                	ld	ra,184(sp)
    80006872:	744a                	ld	s0,176(sp)
    80006874:	74aa                	ld	s1,168(sp)
    80006876:	790a                	ld	s2,160(sp)
    80006878:	69ea                	ld	s3,152(sp)
    8000687a:	6129                	addi	sp,sp,192
    8000687c:	8082                	ret
      end_op();
    8000687e:	fffff097          	auipc	ra,0xfffff
    80006882:	93c080e7          	jalr	-1732(ra) # 800051ba <end_op>
      return -1;
    80006886:	b7e5                	j	8000686e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80006888:	f5040513          	addi	a0,s0,-176
    8000688c:	ffffe097          	auipc	ra,0xffffe
    80006890:	68e080e7          	jalr	1678(ra) # 80004f1a <namei>
    80006894:	892a                	mv	s2,a0
    80006896:	c905                	beqz	a0,800068c6 <sys_open+0x13c>
    ilock(ip);
    80006898:	ffffe097          	auipc	ra,0xffffe
    8000689c:	ece080e7          	jalr	-306(ra) # 80004766 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800068a0:	04491703          	lh	a4,68(s2)
    800068a4:	4785                	li	a5,1
    800068a6:	f4f712e3          	bne	a4,a5,800067ea <sys_open+0x60>
    800068aa:	f4c42783          	lw	a5,-180(s0)
    800068ae:	dba1                	beqz	a5,800067fe <sys_open+0x74>
      iunlockput(ip);
    800068b0:	854a                	mv	a0,s2
    800068b2:	ffffe097          	auipc	ra,0xffffe
    800068b6:	116080e7          	jalr	278(ra) # 800049c8 <iunlockput>
      end_op();
    800068ba:	fffff097          	auipc	ra,0xfffff
    800068be:	900080e7          	jalr	-1792(ra) # 800051ba <end_op>
      return -1;
    800068c2:	54fd                	li	s1,-1
    800068c4:	b76d                	j	8000686e <sys_open+0xe4>
      end_op();
    800068c6:	fffff097          	auipc	ra,0xfffff
    800068ca:	8f4080e7          	jalr	-1804(ra) # 800051ba <end_op>
      return -1;
    800068ce:	54fd                	li	s1,-1
    800068d0:	bf79                	j	8000686e <sys_open+0xe4>
    iunlockput(ip);
    800068d2:	854a                	mv	a0,s2
    800068d4:	ffffe097          	auipc	ra,0xffffe
    800068d8:	0f4080e7          	jalr	244(ra) # 800049c8 <iunlockput>
    end_op();
    800068dc:	fffff097          	auipc	ra,0xfffff
    800068e0:	8de080e7          	jalr	-1826(ra) # 800051ba <end_op>
    return -1;
    800068e4:	54fd                	li	s1,-1
    800068e6:	b761                	j	8000686e <sys_open+0xe4>
    f->type = FD_DEVICE;
    800068e8:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800068ec:	04691783          	lh	a5,70(s2)
    800068f0:	02f99223          	sh	a5,36(s3)
    800068f4:	bf2d                	j	8000682e <sys_open+0xa4>
    itrunc(ip);
    800068f6:	854a                	mv	a0,s2
    800068f8:	ffffe097          	auipc	ra,0xffffe
    800068fc:	f7c080e7          	jalr	-132(ra) # 80004874 <itrunc>
    80006900:	bfb1                	j	8000685c <sys_open+0xd2>
      fileclose(f);
    80006902:	854e                	mv	a0,s3
    80006904:	fffff097          	auipc	ra,0xfffff
    80006908:	d02080e7          	jalr	-766(ra) # 80005606 <fileclose>
    iunlockput(ip);
    8000690c:	854a                	mv	a0,s2
    8000690e:	ffffe097          	auipc	ra,0xffffe
    80006912:	0ba080e7          	jalr	186(ra) # 800049c8 <iunlockput>
    end_op();
    80006916:	fffff097          	auipc	ra,0xfffff
    8000691a:	8a4080e7          	jalr	-1884(ra) # 800051ba <end_op>
    return -1;
    8000691e:	54fd                	li	s1,-1
    80006920:	b7b9                	j	8000686e <sys_open+0xe4>

0000000080006922 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80006922:	7175                	addi	sp,sp,-144
    80006924:	e506                	sd	ra,136(sp)
    80006926:	e122                	sd	s0,128(sp)
    80006928:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000692a:	fffff097          	auipc	ra,0xfffff
    8000692e:	810080e7          	jalr	-2032(ra) # 8000513a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80006932:	08000613          	li	a2,128
    80006936:	f7040593          	addi	a1,s0,-144
    8000693a:	4501                	li	a0,0
    8000693c:	ffffd097          	auipc	ra,0xffffd
    80006940:	124080e7          	jalr	292(ra) # 80003a60 <argstr>
    80006944:	02054963          	bltz	a0,80006976 <sys_mkdir+0x54>
    80006948:	4681                	li	a3,0
    8000694a:	4601                	li	a2,0
    8000694c:	4585                	li	a1,1
    8000694e:	f7040513          	addi	a0,s0,-144
    80006952:	00000097          	auipc	ra,0x0
    80006956:	800080e7          	jalr	-2048(ra) # 80006152 <create>
    8000695a:	cd11                	beqz	a0,80006976 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000695c:	ffffe097          	auipc	ra,0xffffe
    80006960:	06c080e7          	jalr	108(ra) # 800049c8 <iunlockput>
  end_op();
    80006964:	fffff097          	auipc	ra,0xfffff
    80006968:	856080e7          	jalr	-1962(ra) # 800051ba <end_op>
  return 0;
    8000696c:	4501                	li	a0,0
}
    8000696e:	60aa                	ld	ra,136(sp)
    80006970:	640a                	ld	s0,128(sp)
    80006972:	6149                	addi	sp,sp,144
    80006974:	8082                	ret
    end_op();
    80006976:	fffff097          	auipc	ra,0xfffff
    8000697a:	844080e7          	jalr	-1980(ra) # 800051ba <end_op>
    return -1;
    8000697e:	557d                	li	a0,-1
    80006980:	b7fd                	j	8000696e <sys_mkdir+0x4c>

0000000080006982 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006982:	7135                	addi	sp,sp,-160
    80006984:	ed06                	sd	ra,152(sp)
    80006986:	e922                	sd	s0,144(sp)
    80006988:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000698a:	ffffe097          	auipc	ra,0xffffe
    8000698e:	7b0080e7          	jalr	1968(ra) # 8000513a <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006992:	08000613          	li	a2,128
    80006996:	f7040593          	addi	a1,s0,-144
    8000699a:	4501                	li	a0,0
    8000699c:	ffffd097          	auipc	ra,0xffffd
    800069a0:	0c4080e7          	jalr	196(ra) # 80003a60 <argstr>
    800069a4:	04054a63          	bltz	a0,800069f8 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800069a8:	f6c40593          	addi	a1,s0,-148
    800069ac:	4505                	li	a0,1
    800069ae:	ffffd097          	auipc	ra,0xffffd
    800069b2:	06e080e7          	jalr	110(ra) # 80003a1c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800069b6:	04054163          	bltz	a0,800069f8 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800069ba:	f6840593          	addi	a1,s0,-152
    800069be:	4509                	li	a0,2
    800069c0:	ffffd097          	auipc	ra,0xffffd
    800069c4:	05c080e7          	jalr	92(ra) # 80003a1c <argint>
     argint(1, &major) < 0 ||
    800069c8:	02054863          	bltz	a0,800069f8 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800069cc:	f6841683          	lh	a3,-152(s0)
    800069d0:	f6c41603          	lh	a2,-148(s0)
    800069d4:	458d                	li	a1,3
    800069d6:	f7040513          	addi	a0,s0,-144
    800069da:	fffff097          	auipc	ra,0xfffff
    800069de:	778080e7          	jalr	1912(ra) # 80006152 <create>
     argint(2, &minor) < 0 ||
    800069e2:	c919                	beqz	a0,800069f8 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800069e4:	ffffe097          	auipc	ra,0xffffe
    800069e8:	fe4080e7          	jalr	-28(ra) # 800049c8 <iunlockput>
  end_op();
    800069ec:	ffffe097          	auipc	ra,0xffffe
    800069f0:	7ce080e7          	jalr	1998(ra) # 800051ba <end_op>
  return 0;
    800069f4:	4501                	li	a0,0
    800069f6:	a031                	j	80006a02 <sys_mknod+0x80>
    end_op();
    800069f8:	ffffe097          	auipc	ra,0xffffe
    800069fc:	7c2080e7          	jalr	1986(ra) # 800051ba <end_op>
    return -1;
    80006a00:	557d                	li	a0,-1
}
    80006a02:	60ea                	ld	ra,152(sp)
    80006a04:	644a                	ld	s0,144(sp)
    80006a06:	610d                	addi	sp,sp,160
    80006a08:	8082                	ret

0000000080006a0a <sys_chdir>:

uint64
sys_chdir(void)
{
    80006a0a:	7135                	addi	sp,sp,-160
    80006a0c:	ed06                	sd	ra,152(sp)
    80006a0e:	e922                	sd	s0,144(sp)
    80006a10:	e526                	sd	s1,136(sp)
    80006a12:	e14a                	sd	s2,128(sp)
    80006a14:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006a16:	ffffb097          	auipc	ra,0xffffb
    80006a1a:	066080e7          	jalr	102(ra) # 80001a7c <myproc>
    80006a1e:	892a                	mv	s2,a0
  
  begin_op();
    80006a20:	ffffe097          	auipc	ra,0xffffe
    80006a24:	71a080e7          	jalr	1818(ra) # 8000513a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006a28:	08000613          	li	a2,128
    80006a2c:	f6040593          	addi	a1,s0,-160
    80006a30:	4501                	li	a0,0
    80006a32:	ffffd097          	auipc	ra,0xffffd
    80006a36:	02e080e7          	jalr	46(ra) # 80003a60 <argstr>
    80006a3a:	04054b63          	bltz	a0,80006a90 <sys_chdir+0x86>
    80006a3e:	f6040513          	addi	a0,s0,-160
    80006a42:	ffffe097          	auipc	ra,0xffffe
    80006a46:	4d8080e7          	jalr	1240(ra) # 80004f1a <namei>
    80006a4a:	84aa                	mv	s1,a0
    80006a4c:	c131                	beqz	a0,80006a90 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006a4e:	ffffe097          	auipc	ra,0xffffe
    80006a52:	d18080e7          	jalr	-744(ra) # 80004766 <ilock>
  if(ip->type != T_DIR){
    80006a56:	04449703          	lh	a4,68(s1)
    80006a5a:	4785                	li	a5,1
    80006a5c:	04f71063          	bne	a4,a5,80006a9c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006a60:	8526                	mv	a0,s1
    80006a62:	ffffe097          	auipc	ra,0xffffe
    80006a66:	dc6080e7          	jalr	-570(ra) # 80004828 <iunlock>
  iput(p->cwd);
    80006a6a:	0d093503          	ld	a0,208(s2)
    80006a6e:	ffffe097          	auipc	ra,0xffffe
    80006a72:	eb2080e7          	jalr	-334(ra) # 80004920 <iput>
  end_op();
    80006a76:	ffffe097          	auipc	ra,0xffffe
    80006a7a:	744080e7          	jalr	1860(ra) # 800051ba <end_op>
  p->cwd = ip;
    80006a7e:	0c993823          	sd	s1,208(s2)
  return 0;
    80006a82:	4501                	li	a0,0
}
    80006a84:	60ea                	ld	ra,152(sp)
    80006a86:	644a                	ld	s0,144(sp)
    80006a88:	64aa                	ld	s1,136(sp)
    80006a8a:	690a                	ld	s2,128(sp)
    80006a8c:	610d                	addi	sp,sp,160
    80006a8e:	8082                	ret
    end_op();
    80006a90:	ffffe097          	auipc	ra,0xffffe
    80006a94:	72a080e7          	jalr	1834(ra) # 800051ba <end_op>
    return -1;
    80006a98:	557d                	li	a0,-1
    80006a9a:	b7ed                	j	80006a84 <sys_chdir+0x7a>
    iunlockput(ip);
    80006a9c:	8526                	mv	a0,s1
    80006a9e:	ffffe097          	auipc	ra,0xffffe
    80006aa2:	f2a080e7          	jalr	-214(ra) # 800049c8 <iunlockput>
    end_op();
    80006aa6:	ffffe097          	auipc	ra,0xffffe
    80006aaa:	714080e7          	jalr	1812(ra) # 800051ba <end_op>
    return -1;
    80006aae:	557d                	li	a0,-1
    80006ab0:	bfd1                	j	80006a84 <sys_chdir+0x7a>

0000000080006ab2 <sys_exec>:

uint64
sys_exec(void)
{
    80006ab2:	7145                	addi	sp,sp,-464
    80006ab4:	e786                	sd	ra,456(sp)
    80006ab6:	e3a2                	sd	s0,448(sp)
    80006ab8:	ff26                	sd	s1,440(sp)
    80006aba:	fb4a                	sd	s2,432(sp)
    80006abc:	f74e                	sd	s3,424(sp)
    80006abe:	f352                	sd	s4,416(sp)
    80006ac0:	ef56                	sd	s5,408(sp)
    80006ac2:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006ac4:	08000613          	li	a2,128
    80006ac8:	f4040593          	addi	a1,s0,-192
    80006acc:	4501                	li	a0,0
    80006ace:	ffffd097          	auipc	ra,0xffffd
    80006ad2:	f92080e7          	jalr	-110(ra) # 80003a60 <argstr>
    return -1;
    80006ad6:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80006ad8:	0c054a63          	bltz	a0,80006bac <sys_exec+0xfa>
    80006adc:	e3840593          	addi	a1,s0,-456
    80006ae0:	4505                	li	a0,1
    80006ae2:	ffffd097          	auipc	ra,0xffffd
    80006ae6:	f5c080e7          	jalr	-164(ra) # 80003a3e <argaddr>
    80006aea:	0c054163          	bltz	a0,80006bac <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80006aee:	10000613          	li	a2,256
    80006af2:	4581                	li	a1,0
    80006af4:	e4040513          	addi	a0,s0,-448
    80006af8:	ffffa097          	auipc	ra,0xffffa
    80006afc:	1ec080e7          	jalr	492(ra) # 80000ce4 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006b00:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80006b04:	89a6                	mv	s3,s1
    80006b06:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006b08:	02000a13          	li	s4,32
    80006b0c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006b10:	00391793          	slli	a5,s2,0x3
    80006b14:	e3040593          	addi	a1,s0,-464
    80006b18:	e3843503          	ld	a0,-456(s0)
    80006b1c:	953e                	add	a0,a0,a5
    80006b1e:	ffffd097          	auipc	ra,0xffffd
    80006b22:	e64080e7          	jalr	-412(ra) # 80003982 <fetchaddr>
    80006b26:	02054a63          	bltz	a0,80006b5a <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006b2a:	e3043783          	ld	a5,-464(s0)
    80006b2e:	c3b9                	beqz	a5,80006b74 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006b30:	ffffa097          	auipc	ra,0xffffa
    80006b34:	fa6080e7          	jalr	-90(ra) # 80000ad6 <kalloc>
    80006b38:	85aa                	mv	a1,a0
    80006b3a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006b3e:	cd11                	beqz	a0,80006b5a <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006b40:	6605                	lui	a2,0x1
    80006b42:	e3043503          	ld	a0,-464(s0)
    80006b46:	ffffd097          	auipc	ra,0xffffd
    80006b4a:	e8e080e7          	jalr	-370(ra) # 800039d4 <fetchstr>
    80006b4e:	00054663          	bltz	a0,80006b5a <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80006b52:	0905                	addi	s2,s2,1
    80006b54:	09a1                	addi	s3,s3,8
    80006b56:	fb491be3          	bne	s2,s4,80006b0c <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006b5a:	10048913          	addi	s2,s1,256
    80006b5e:	6088                	ld	a0,0(s1)
    80006b60:	c529                	beqz	a0,80006baa <sys_exec+0xf8>
    kfree(argv[i]);
    80006b62:	ffffa097          	auipc	ra,0xffffa
    80006b66:	e78080e7          	jalr	-392(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006b6a:	04a1                	addi	s1,s1,8
    80006b6c:	ff2499e3          	bne	s1,s2,80006b5e <sys_exec+0xac>
  return -1;
    80006b70:	597d                	li	s2,-1
    80006b72:	a82d                	j	80006bac <sys_exec+0xfa>
      argv[i] = 0;
    80006b74:	0a8e                	slli	s5,s5,0x3
    80006b76:	fc040793          	addi	a5,s0,-64
    80006b7a:	9abe                	add	s5,s5,a5
    80006b7c:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80006b80:	e4040593          	addi	a1,s0,-448
    80006b84:	f4040513          	addi	a0,s0,-192
    80006b88:	fffff097          	auipc	ra,0xfffff
    80006b8c:	0dc080e7          	jalr	220(ra) # 80005c64 <exec>
    80006b90:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006b92:	10048993          	addi	s3,s1,256
    80006b96:	6088                	ld	a0,0(s1)
    80006b98:	c911                	beqz	a0,80006bac <sys_exec+0xfa>
    kfree(argv[i]);
    80006b9a:	ffffa097          	auipc	ra,0xffffa
    80006b9e:	e40080e7          	jalr	-448(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006ba2:	04a1                	addi	s1,s1,8
    80006ba4:	ff3499e3          	bne	s1,s3,80006b96 <sys_exec+0xe4>
    80006ba8:	a011                	j	80006bac <sys_exec+0xfa>
  return -1;
    80006baa:	597d                	li	s2,-1
}
    80006bac:	854a                	mv	a0,s2
    80006bae:	60be                	ld	ra,456(sp)
    80006bb0:	641e                	ld	s0,448(sp)
    80006bb2:	74fa                	ld	s1,440(sp)
    80006bb4:	795a                	ld	s2,432(sp)
    80006bb6:	79ba                	ld	s3,424(sp)
    80006bb8:	7a1a                	ld	s4,416(sp)
    80006bba:	6afa                	ld	s5,408(sp)
    80006bbc:	6179                	addi	sp,sp,464
    80006bbe:	8082                	ret

0000000080006bc0 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006bc0:	7139                	addi	sp,sp,-64
    80006bc2:	fc06                	sd	ra,56(sp)
    80006bc4:	f822                	sd	s0,48(sp)
    80006bc6:	f426                	sd	s1,40(sp)
    80006bc8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006bca:	ffffb097          	auipc	ra,0xffffb
    80006bce:	eb2080e7          	jalr	-334(ra) # 80001a7c <myproc>
    80006bd2:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80006bd4:	fd840593          	addi	a1,s0,-40
    80006bd8:	4501                	li	a0,0
    80006bda:	ffffd097          	auipc	ra,0xffffd
    80006bde:	e64080e7          	jalr	-412(ra) # 80003a3e <argaddr>
    return -1;
    80006be2:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80006be4:	0e054063          	bltz	a0,80006cc4 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80006be8:	fc840593          	addi	a1,s0,-56
    80006bec:	fd040513          	addi	a0,s0,-48
    80006bf0:	fffff097          	auipc	ra,0xfffff
    80006bf4:	d46080e7          	jalr	-698(ra) # 80005936 <pipealloc>
    return -1;
    80006bf8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80006bfa:	0c054563          	bltz	a0,80006cc4 <sys_pipe+0x104>
  fd0 = -1;
    80006bfe:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006c02:	fd043503          	ld	a0,-48(s0)
    80006c06:	fffff097          	auipc	ra,0xfffff
    80006c0a:	50a080e7          	jalr	1290(ra) # 80006110 <fdalloc>
    80006c0e:	fca42223          	sw	a0,-60(s0)
    80006c12:	08054c63          	bltz	a0,80006caa <sys_pipe+0xea>
    80006c16:	fc843503          	ld	a0,-56(s0)
    80006c1a:	fffff097          	auipc	ra,0xfffff
    80006c1e:	4f6080e7          	jalr	1270(ra) # 80006110 <fdalloc>
    80006c22:	fca42023          	sw	a0,-64(s0)
    80006c26:	06054863          	bltz	a0,80006c96 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006c2a:	4691                	li	a3,4
    80006c2c:	fc440613          	addi	a2,s0,-60
    80006c30:	fd843583          	ld	a1,-40(s0)
    80006c34:	60a8                	ld	a0,64(s1)
    80006c36:	ffffb097          	auipc	ra,0xffffb
    80006c3a:	a2e080e7          	jalr	-1490(ra) # 80001664 <copyout>
    80006c3e:	02054063          	bltz	a0,80006c5e <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006c42:	4691                	li	a3,4
    80006c44:	fc040613          	addi	a2,s0,-64
    80006c48:	fd843583          	ld	a1,-40(s0)
    80006c4c:	0591                	addi	a1,a1,4
    80006c4e:	60a8                	ld	a0,64(s1)
    80006c50:	ffffb097          	auipc	ra,0xffffb
    80006c54:	a14080e7          	jalr	-1516(ra) # 80001664 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006c58:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006c5a:	06055563          	bgez	a0,80006cc4 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80006c5e:	fc442783          	lw	a5,-60(s0)
    80006c62:	07a9                	addi	a5,a5,10
    80006c64:	078e                	slli	a5,a5,0x3
    80006c66:	97a6                	add	a5,a5,s1
    80006c68:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006c6c:	fc042503          	lw	a0,-64(s0)
    80006c70:	0529                	addi	a0,a0,10
    80006c72:	050e                	slli	a0,a0,0x3
    80006c74:	9526                	add	a0,a0,s1
    80006c76:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006c7a:	fd043503          	ld	a0,-48(s0)
    80006c7e:	fffff097          	auipc	ra,0xfffff
    80006c82:	988080e7          	jalr	-1656(ra) # 80005606 <fileclose>
    fileclose(wf);
    80006c86:	fc843503          	ld	a0,-56(s0)
    80006c8a:	fffff097          	auipc	ra,0xfffff
    80006c8e:	97c080e7          	jalr	-1668(ra) # 80005606 <fileclose>
    return -1;
    80006c92:	57fd                	li	a5,-1
    80006c94:	a805                	j	80006cc4 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006c96:	fc442783          	lw	a5,-60(s0)
    80006c9a:	0007c863          	bltz	a5,80006caa <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80006c9e:	00a78513          	addi	a0,a5,10
    80006ca2:	050e                	slli	a0,a0,0x3
    80006ca4:	9526                	add	a0,a0,s1
    80006ca6:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006caa:	fd043503          	ld	a0,-48(s0)
    80006cae:	fffff097          	auipc	ra,0xfffff
    80006cb2:	958080e7          	jalr	-1704(ra) # 80005606 <fileclose>
    fileclose(wf);
    80006cb6:	fc843503          	ld	a0,-56(s0)
    80006cba:	fffff097          	auipc	ra,0xfffff
    80006cbe:	94c080e7          	jalr	-1716(ra) # 80005606 <fileclose>
    return -1;
    80006cc2:	57fd                	li	a5,-1
}
    80006cc4:	853e                	mv	a0,a5
    80006cc6:	70e2                	ld	ra,56(sp)
    80006cc8:	7442                	ld	s0,48(sp)
    80006cca:	74a2                	ld	s1,40(sp)
    80006ccc:	6121                	addi	sp,sp,64
    80006cce:	8082                	ret

0000000080006cd0 <kernelvec>:
    80006cd0:	7111                	addi	sp,sp,-256
    80006cd2:	e006                	sd	ra,0(sp)
    80006cd4:	e40a                	sd	sp,8(sp)
    80006cd6:	e80e                	sd	gp,16(sp)
    80006cd8:	ec12                	sd	tp,24(sp)
    80006cda:	f016                	sd	t0,32(sp)
    80006cdc:	f41a                	sd	t1,40(sp)
    80006cde:	f81e                	sd	t2,48(sp)
    80006ce0:	fc22                	sd	s0,56(sp)
    80006ce2:	e0a6                	sd	s1,64(sp)
    80006ce4:	e4aa                	sd	a0,72(sp)
    80006ce6:	e8ae                	sd	a1,80(sp)
    80006ce8:	ecb2                	sd	a2,88(sp)
    80006cea:	f0b6                	sd	a3,96(sp)
    80006cec:	f4ba                	sd	a4,104(sp)
    80006cee:	f8be                	sd	a5,112(sp)
    80006cf0:	fcc2                	sd	a6,120(sp)
    80006cf2:	e146                	sd	a7,128(sp)
    80006cf4:	e54a                	sd	s2,136(sp)
    80006cf6:	e94e                	sd	s3,144(sp)
    80006cf8:	ed52                	sd	s4,152(sp)
    80006cfa:	f156                	sd	s5,160(sp)
    80006cfc:	f55a                	sd	s6,168(sp)
    80006cfe:	f95e                	sd	s7,176(sp)
    80006d00:	fd62                	sd	s8,184(sp)
    80006d02:	e1e6                	sd	s9,192(sp)
    80006d04:	e5ea                	sd	s10,200(sp)
    80006d06:	e9ee                	sd	s11,208(sp)
    80006d08:	edf2                	sd	t3,216(sp)
    80006d0a:	f1f6                	sd	t4,224(sp)
    80006d0c:	f5fa                	sd	t5,232(sp)
    80006d0e:	f9fe                	sd	t6,240(sp)
    80006d10:	b1bfc0ef          	jal	ra,8000382a <kerneltrap>
    80006d14:	6082                	ld	ra,0(sp)
    80006d16:	6122                	ld	sp,8(sp)
    80006d18:	61c2                	ld	gp,16(sp)
    80006d1a:	7282                	ld	t0,32(sp)
    80006d1c:	7322                	ld	t1,40(sp)
    80006d1e:	73c2                	ld	t2,48(sp)
    80006d20:	7462                	ld	s0,56(sp)
    80006d22:	6486                	ld	s1,64(sp)
    80006d24:	6526                	ld	a0,72(sp)
    80006d26:	65c6                	ld	a1,80(sp)
    80006d28:	6666                	ld	a2,88(sp)
    80006d2a:	7686                	ld	a3,96(sp)
    80006d2c:	7726                	ld	a4,104(sp)
    80006d2e:	77c6                	ld	a5,112(sp)
    80006d30:	7866                	ld	a6,120(sp)
    80006d32:	688a                	ld	a7,128(sp)
    80006d34:	692a                	ld	s2,136(sp)
    80006d36:	69ca                	ld	s3,144(sp)
    80006d38:	6a6a                	ld	s4,152(sp)
    80006d3a:	7a8a                	ld	s5,160(sp)
    80006d3c:	7b2a                	ld	s6,168(sp)
    80006d3e:	7bca                	ld	s7,176(sp)
    80006d40:	7c6a                	ld	s8,184(sp)
    80006d42:	6c8e                	ld	s9,192(sp)
    80006d44:	6d2e                	ld	s10,200(sp)
    80006d46:	6dce                	ld	s11,208(sp)
    80006d48:	6e6e                	ld	t3,216(sp)
    80006d4a:	7e8e                	ld	t4,224(sp)
    80006d4c:	7f2e                	ld	t5,232(sp)
    80006d4e:	7fce                	ld	t6,240(sp)
    80006d50:	6111                	addi	sp,sp,256
    80006d52:	10200073          	sret
    80006d56:	00000013          	nop
    80006d5a:	00000013          	nop
    80006d5e:	0001                	nop

0000000080006d60 <timervec>:
    80006d60:	34051573          	csrrw	a0,mscratch,a0
    80006d64:	e10c                	sd	a1,0(a0)
    80006d66:	e510                	sd	a2,8(a0)
    80006d68:	e914                	sd	a3,16(a0)
    80006d6a:	6d0c                	ld	a1,24(a0)
    80006d6c:	7110                	ld	a2,32(a0)
    80006d6e:	6194                	ld	a3,0(a1)
    80006d70:	96b2                	add	a3,a3,a2
    80006d72:	e194                	sd	a3,0(a1)
    80006d74:	4589                	li	a1,2
    80006d76:	14459073          	csrw	sip,a1
    80006d7a:	6914                	ld	a3,16(a0)
    80006d7c:	6510                	ld	a2,8(a0)
    80006d7e:	610c                	ld	a1,0(a0)
    80006d80:	34051573          	csrrw	a0,mscratch,a0
    80006d84:	30200073          	mret
	...

0000000080006d8a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80006d8a:	1141                	addi	sp,sp,-16
    80006d8c:	e422                	sd	s0,8(sp)
    80006d8e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006d90:	0c0007b7          	lui	a5,0xc000
    80006d94:	4705                	li	a4,1
    80006d96:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006d98:	c3d8                	sw	a4,4(a5)
}
    80006d9a:	6422                	ld	s0,8(sp)
    80006d9c:	0141                	addi	sp,sp,16
    80006d9e:	8082                	ret

0000000080006da0 <plicinithart>:

void
plicinithart(void)
{
    80006da0:	1141                	addi	sp,sp,-16
    80006da2:	e406                	sd	ra,8(sp)
    80006da4:	e022                	sd	s0,0(sp)
    80006da6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006da8:	ffffb097          	auipc	ra,0xffffb
    80006dac:	ca0080e7          	jalr	-864(ra) # 80001a48 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006db0:	0085171b          	slliw	a4,a0,0x8
    80006db4:	0c0027b7          	lui	a5,0xc002
    80006db8:	97ba                	add	a5,a5,a4
    80006dba:	40200713          	li	a4,1026
    80006dbe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006dc2:	00d5151b          	slliw	a0,a0,0xd
    80006dc6:	0c2017b7          	lui	a5,0xc201
    80006dca:	953e                	add	a0,a0,a5
    80006dcc:	00052023          	sw	zero,0(a0)
}
    80006dd0:	60a2                	ld	ra,8(sp)
    80006dd2:	6402                	ld	s0,0(sp)
    80006dd4:	0141                	addi	sp,sp,16
    80006dd6:	8082                	ret

0000000080006dd8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006dd8:	1141                	addi	sp,sp,-16
    80006dda:	e406                	sd	ra,8(sp)
    80006ddc:	e022                	sd	s0,0(sp)
    80006dde:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006de0:	ffffb097          	auipc	ra,0xffffb
    80006de4:	c68080e7          	jalr	-920(ra) # 80001a48 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006de8:	00d5179b          	slliw	a5,a0,0xd
    80006dec:	0c201537          	lui	a0,0xc201
    80006df0:	953e                	add	a0,a0,a5
  return irq;
}
    80006df2:	4148                	lw	a0,4(a0)
    80006df4:	60a2                	ld	ra,8(sp)
    80006df6:	6402                	ld	s0,0(sp)
    80006df8:	0141                	addi	sp,sp,16
    80006dfa:	8082                	ret

0000000080006dfc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80006dfc:	1101                	addi	sp,sp,-32
    80006dfe:	ec06                	sd	ra,24(sp)
    80006e00:	e822                	sd	s0,16(sp)
    80006e02:	e426                	sd	s1,8(sp)
    80006e04:	1000                	addi	s0,sp,32
    80006e06:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006e08:	ffffb097          	auipc	ra,0xffffb
    80006e0c:	c40080e7          	jalr	-960(ra) # 80001a48 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006e10:	00d5151b          	slliw	a0,a0,0xd
    80006e14:	0c2017b7          	lui	a5,0xc201
    80006e18:	97aa                	add	a5,a5,a0
    80006e1a:	c3c4                	sw	s1,4(a5)
}
    80006e1c:	60e2                	ld	ra,24(sp)
    80006e1e:	6442                	ld	s0,16(sp)
    80006e20:	64a2                	ld	s1,8(sp)
    80006e22:	6105                	addi	sp,sp,32
    80006e24:	8082                	ret

0000000080006e26 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006e26:	1141                	addi	sp,sp,-16
    80006e28:	e406                	sd	ra,8(sp)
    80006e2a:	e022                	sd	s0,0(sp)
    80006e2c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80006e2e:	479d                	li	a5,7
    80006e30:	06a7c963          	blt	a5,a0,80006ea2 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006e34:	00038797          	auipc	a5,0x38
    80006e38:	1cc78793          	addi	a5,a5,460 # 8003f000 <disk>
    80006e3c:	00a78733          	add	a4,a5,a0
    80006e40:	6789                	lui	a5,0x2
    80006e42:	97ba                	add	a5,a5,a4
    80006e44:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006e48:	e7ad                	bnez	a5,80006eb2 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006e4a:	00451793          	slli	a5,a0,0x4
    80006e4e:	0003a717          	auipc	a4,0x3a
    80006e52:	1b270713          	addi	a4,a4,434 # 80041000 <disk+0x2000>
    80006e56:	6314                	ld	a3,0(a4)
    80006e58:	96be                	add	a3,a3,a5
    80006e5a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80006e5e:	6314                	ld	a3,0(a4)
    80006e60:	96be                	add	a3,a3,a5
    80006e62:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006e66:	6314                	ld	a3,0(a4)
    80006e68:	96be                	add	a3,a3,a5
    80006e6a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80006e6e:	6318                	ld	a4,0(a4)
    80006e70:	97ba                	add	a5,a5,a4
    80006e72:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006e76:	00038797          	auipc	a5,0x38
    80006e7a:	18a78793          	addi	a5,a5,394 # 8003f000 <disk>
    80006e7e:	97aa                	add	a5,a5,a0
    80006e80:	6509                	lui	a0,0x2
    80006e82:	953e                	add	a0,a0,a5
    80006e84:	4785                	li	a5,1
    80006e86:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80006e8a:	0003a517          	auipc	a0,0x3a
    80006e8e:	18e50513          	addi	a0,a0,398 # 80041018 <disk+0x2018>
    80006e92:	ffffb097          	auipc	ra,0xffffb
    80006e96:	6ea080e7          	jalr	1770(ra) # 8000257c <wakeup>
}
    80006e9a:	60a2                	ld	ra,8(sp)
    80006e9c:	6402                	ld	s0,0(sp)
    80006e9e:	0141                	addi	sp,sp,16
    80006ea0:	8082                	ret
    panic("free_desc 1");
    80006ea2:	00003517          	auipc	a0,0x3
    80006ea6:	a2650513          	addi	a0,a0,-1498 # 800098c8 <syscalls+0x358>
    80006eaa:	ffff9097          	auipc	ra,0xffff9
    80006eae:	684080e7          	jalr	1668(ra) # 8000052e <panic>
    panic("free_desc 2");
    80006eb2:	00003517          	auipc	a0,0x3
    80006eb6:	a2650513          	addi	a0,a0,-1498 # 800098d8 <syscalls+0x368>
    80006eba:	ffff9097          	auipc	ra,0xffff9
    80006ebe:	674080e7          	jalr	1652(ra) # 8000052e <panic>

0000000080006ec2 <virtio_disk_init>:
{
    80006ec2:	1101                	addi	sp,sp,-32
    80006ec4:	ec06                	sd	ra,24(sp)
    80006ec6:	e822                	sd	s0,16(sp)
    80006ec8:	e426                	sd	s1,8(sp)
    80006eca:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006ecc:	00003597          	auipc	a1,0x3
    80006ed0:	a1c58593          	addi	a1,a1,-1508 # 800098e8 <syscalls+0x378>
    80006ed4:	0003a517          	auipc	a0,0x3a
    80006ed8:	25450513          	addi	a0,a0,596 # 80041128 <disk+0x2128>
    80006edc:	ffffa097          	auipc	ra,0xffffa
    80006ee0:	c5a080e7          	jalr	-934(ra) # 80000b36 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006ee4:	100017b7          	lui	a5,0x10001
    80006ee8:	4398                	lw	a4,0(a5)
    80006eea:	2701                	sext.w	a4,a4
    80006eec:	747277b7          	lui	a5,0x74727
    80006ef0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006ef4:	0ef71163          	bne	a4,a5,80006fd6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006ef8:	100017b7          	lui	a5,0x10001
    80006efc:	43dc                	lw	a5,4(a5)
    80006efe:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006f00:	4705                	li	a4,1
    80006f02:	0ce79a63          	bne	a5,a4,80006fd6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006f06:	100017b7          	lui	a5,0x10001
    80006f0a:	479c                	lw	a5,8(a5)
    80006f0c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006f0e:	4709                	li	a4,2
    80006f10:	0ce79363          	bne	a5,a4,80006fd6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006f14:	100017b7          	lui	a5,0x10001
    80006f18:	47d8                	lw	a4,12(a5)
    80006f1a:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006f1c:	554d47b7          	lui	a5,0x554d4
    80006f20:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006f24:	0af71963          	bne	a4,a5,80006fd6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006f28:	100017b7          	lui	a5,0x10001
    80006f2c:	4705                	li	a4,1
    80006f2e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006f30:	470d                	li	a4,3
    80006f32:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006f34:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006f36:	c7ffe737          	lui	a4,0xc7ffe
    80006f3a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fbc75f>
    80006f3e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006f40:	2701                	sext.w	a4,a4
    80006f42:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006f44:	472d                	li	a4,11
    80006f46:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006f48:	473d                	li	a4,15
    80006f4a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006f4c:	6705                	lui	a4,0x1
    80006f4e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006f50:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006f54:	5bdc                	lw	a5,52(a5)
    80006f56:	2781                	sext.w	a5,a5
  if(max == 0)
    80006f58:	c7d9                	beqz	a5,80006fe6 <virtio_disk_init+0x124>
  if(max < NUM)
    80006f5a:	471d                	li	a4,7
    80006f5c:	08f77d63          	bgeu	a4,a5,80006ff6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006f60:	100014b7          	lui	s1,0x10001
    80006f64:	47a1                	li	a5,8
    80006f66:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006f68:	6609                	lui	a2,0x2
    80006f6a:	4581                	li	a1,0
    80006f6c:	00038517          	auipc	a0,0x38
    80006f70:	09450513          	addi	a0,a0,148 # 8003f000 <disk>
    80006f74:	ffffa097          	auipc	ra,0xffffa
    80006f78:	d70080e7          	jalr	-656(ra) # 80000ce4 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006f7c:	00038717          	auipc	a4,0x38
    80006f80:	08470713          	addi	a4,a4,132 # 8003f000 <disk>
    80006f84:	00c75793          	srli	a5,a4,0xc
    80006f88:	2781                	sext.w	a5,a5
    80006f8a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006f8c:	0003a797          	auipc	a5,0x3a
    80006f90:	07478793          	addi	a5,a5,116 # 80041000 <disk+0x2000>
    80006f94:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006f96:	00038717          	auipc	a4,0x38
    80006f9a:	0ea70713          	addi	a4,a4,234 # 8003f080 <disk+0x80>
    80006f9e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006fa0:	00039717          	auipc	a4,0x39
    80006fa4:	06070713          	addi	a4,a4,96 # 80040000 <disk+0x1000>
    80006fa8:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006faa:	4705                	li	a4,1
    80006fac:	00e78c23          	sb	a4,24(a5)
    80006fb0:	00e78ca3          	sb	a4,25(a5)
    80006fb4:	00e78d23          	sb	a4,26(a5)
    80006fb8:	00e78da3          	sb	a4,27(a5)
    80006fbc:	00e78e23          	sb	a4,28(a5)
    80006fc0:	00e78ea3          	sb	a4,29(a5)
    80006fc4:	00e78f23          	sb	a4,30(a5)
    80006fc8:	00e78fa3          	sb	a4,31(a5)
}
    80006fcc:	60e2                	ld	ra,24(sp)
    80006fce:	6442                	ld	s0,16(sp)
    80006fd0:	64a2                	ld	s1,8(sp)
    80006fd2:	6105                	addi	sp,sp,32
    80006fd4:	8082                	ret
    panic("could not find virtio disk");
    80006fd6:	00003517          	auipc	a0,0x3
    80006fda:	92250513          	addi	a0,a0,-1758 # 800098f8 <syscalls+0x388>
    80006fde:	ffff9097          	auipc	ra,0xffff9
    80006fe2:	550080e7          	jalr	1360(ra) # 8000052e <panic>
    panic("virtio disk has no queue 0");
    80006fe6:	00003517          	auipc	a0,0x3
    80006fea:	93250513          	addi	a0,a0,-1742 # 80009918 <syscalls+0x3a8>
    80006fee:	ffff9097          	auipc	ra,0xffff9
    80006ff2:	540080e7          	jalr	1344(ra) # 8000052e <panic>
    panic("virtio disk max queue too short");
    80006ff6:	00003517          	auipc	a0,0x3
    80006ffa:	94250513          	addi	a0,a0,-1726 # 80009938 <syscalls+0x3c8>
    80006ffe:	ffff9097          	auipc	ra,0xffff9
    80007002:	530080e7          	jalr	1328(ra) # 8000052e <panic>

0000000080007006 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80007006:	7119                	addi	sp,sp,-128
    80007008:	fc86                	sd	ra,120(sp)
    8000700a:	f8a2                	sd	s0,112(sp)
    8000700c:	f4a6                	sd	s1,104(sp)
    8000700e:	f0ca                	sd	s2,96(sp)
    80007010:	ecce                	sd	s3,88(sp)
    80007012:	e8d2                	sd	s4,80(sp)
    80007014:	e4d6                	sd	s5,72(sp)
    80007016:	e0da                	sd	s6,64(sp)
    80007018:	fc5e                	sd	s7,56(sp)
    8000701a:	f862                	sd	s8,48(sp)
    8000701c:	f466                	sd	s9,40(sp)
    8000701e:	f06a                	sd	s10,32(sp)
    80007020:	ec6e                	sd	s11,24(sp)
    80007022:	0100                	addi	s0,sp,128
    80007024:	8aaa                	mv	s5,a0
    80007026:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80007028:	00c52c83          	lw	s9,12(a0)
    8000702c:	001c9c9b          	slliw	s9,s9,0x1
    80007030:	1c82                	slli	s9,s9,0x20
    80007032:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80007036:	0003a517          	auipc	a0,0x3a
    8000703a:	0f250513          	addi	a0,a0,242 # 80041128 <disk+0x2128>
    8000703e:	ffffa097          	auipc	ra,0xffffa
    80007042:	b88080e7          	jalr	-1144(ra) # 80000bc6 <acquire>
  for(int i = 0; i < 3; i++){
    80007046:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80007048:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000704a:	00038c17          	auipc	s8,0x38
    8000704e:	fb6c0c13          	addi	s8,s8,-74 # 8003f000 <disk>
    80007052:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80007054:	4b0d                	li	s6,3
    80007056:	a0ad                	j	800070c0 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80007058:	00fc0733          	add	a4,s8,a5
    8000705c:	975e                	add	a4,a4,s7
    8000705e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80007062:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80007064:	0207c563          	bltz	a5,8000708e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80007068:	2905                	addiw	s2,s2,1
    8000706a:	0611                	addi	a2,a2,4
    8000706c:	19690d63          	beq	s2,s6,80007206 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80007070:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80007072:	0003a717          	auipc	a4,0x3a
    80007076:	fa670713          	addi	a4,a4,-90 # 80041018 <disk+0x2018>
    8000707a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000707c:	00074683          	lbu	a3,0(a4)
    80007080:	fee1                	bnez	a3,80007058 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80007082:	2785                	addiw	a5,a5,1
    80007084:	0705                	addi	a4,a4,1
    80007086:	fe979be3          	bne	a5,s1,8000707c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000708a:	57fd                	li	a5,-1
    8000708c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000708e:	01205d63          	blez	s2,800070a8 <virtio_disk_rw+0xa2>
    80007092:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80007094:	000a2503          	lw	a0,0(s4)
    80007098:	00000097          	auipc	ra,0x0
    8000709c:	d8e080e7          	jalr	-626(ra) # 80006e26 <free_desc>
      for(int j = 0; j < i; j++)
    800070a0:	2d85                	addiw	s11,s11,1
    800070a2:	0a11                	addi	s4,s4,4
    800070a4:	ffb918e3          	bne	s2,s11,80007094 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800070a8:	0003a597          	auipc	a1,0x3a
    800070ac:	08058593          	addi	a1,a1,128 # 80041128 <disk+0x2128>
    800070b0:	0003a517          	auipc	a0,0x3a
    800070b4:	f6850513          	addi	a0,a0,-152 # 80041018 <disk+0x2018>
    800070b8:	ffffb097          	auipc	ra,0xffffb
    800070bc:	33a080e7          	jalr	826(ra) # 800023f2 <sleep>
  for(int i = 0; i < 3; i++){
    800070c0:	f8040a13          	addi	s4,s0,-128
{
    800070c4:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800070c6:	894e                	mv	s2,s3
    800070c8:	b765                	j	80007070 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800070ca:	0003a697          	auipc	a3,0x3a
    800070ce:	f366b683          	ld	a3,-202(a3) # 80041000 <disk+0x2000>
    800070d2:	96ba                	add	a3,a3,a4
    800070d4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800070d8:	00038817          	auipc	a6,0x38
    800070dc:	f2880813          	addi	a6,a6,-216 # 8003f000 <disk>
    800070e0:	0003a697          	auipc	a3,0x3a
    800070e4:	f2068693          	addi	a3,a3,-224 # 80041000 <disk+0x2000>
    800070e8:	6290                	ld	a2,0(a3)
    800070ea:	963a                	add	a2,a2,a4
    800070ec:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    800070f0:	0015e593          	ori	a1,a1,1
    800070f4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800070f8:	f8842603          	lw	a2,-120(s0)
    800070fc:	628c                	ld	a1,0(a3)
    800070fe:	972e                	add	a4,a4,a1
    80007100:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80007104:	20050593          	addi	a1,a0,512
    80007108:	0592                	slli	a1,a1,0x4
    8000710a:	95c2                	add	a1,a1,a6
    8000710c:	577d                	li	a4,-1
    8000710e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80007112:	00461713          	slli	a4,a2,0x4
    80007116:	6290                	ld	a2,0(a3)
    80007118:	963a                	add	a2,a2,a4
    8000711a:	03078793          	addi	a5,a5,48
    8000711e:	97c2                	add	a5,a5,a6
    80007120:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80007122:	629c                	ld	a5,0(a3)
    80007124:	97ba                	add	a5,a5,a4
    80007126:	4605                	li	a2,1
    80007128:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000712a:	629c                	ld	a5,0(a3)
    8000712c:	97ba                	add	a5,a5,a4
    8000712e:	4809                	li	a6,2
    80007130:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80007134:	629c                	ld	a5,0(a3)
    80007136:	973e                	add	a4,a4,a5
    80007138:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000713c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80007140:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80007144:	6698                	ld	a4,8(a3)
    80007146:	00275783          	lhu	a5,2(a4)
    8000714a:	8b9d                	andi	a5,a5,7
    8000714c:	0786                	slli	a5,a5,0x1
    8000714e:	97ba                	add	a5,a5,a4
    80007150:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80007154:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80007158:	6698                	ld	a4,8(a3)
    8000715a:	00275783          	lhu	a5,2(a4)
    8000715e:	2785                	addiw	a5,a5,1
    80007160:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80007164:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80007168:	100017b7          	lui	a5,0x10001
    8000716c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80007170:	004aa783          	lw	a5,4(s5)
    80007174:	02c79163          	bne	a5,a2,80007196 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80007178:	0003a917          	auipc	s2,0x3a
    8000717c:	fb090913          	addi	s2,s2,-80 # 80041128 <disk+0x2128>
  while(b->disk == 1) {
    80007180:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80007182:	85ca                	mv	a1,s2
    80007184:	8556                	mv	a0,s5
    80007186:	ffffb097          	auipc	ra,0xffffb
    8000718a:	26c080e7          	jalr	620(ra) # 800023f2 <sleep>
  while(b->disk == 1) {
    8000718e:	004aa783          	lw	a5,4(s5)
    80007192:	fe9788e3          	beq	a5,s1,80007182 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80007196:	f8042903          	lw	s2,-128(s0)
    8000719a:	20090793          	addi	a5,s2,512
    8000719e:	00479713          	slli	a4,a5,0x4
    800071a2:	00038797          	auipc	a5,0x38
    800071a6:	e5e78793          	addi	a5,a5,-418 # 8003f000 <disk>
    800071aa:	97ba                	add	a5,a5,a4
    800071ac:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800071b0:	0003a997          	auipc	s3,0x3a
    800071b4:	e5098993          	addi	s3,s3,-432 # 80041000 <disk+0x2000>
    800071b8:	00491713          	slli	a4,s2,0x4
    800071bc:	0009b783          	ld	a5,0(s3)
    800071c0:	97ba                	add	a5,a5,a4
    800071c2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800071c6:	854a                	mv	a0,s2
    800071c8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800071cc:	00000097          	auipc	ra,0x0
    800071d0:	c5a080e7          	jalr	-934(ra) # 80006e26 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800071d4:	8885                	andi	s1,s1,1
    800071d6:	f0ed                	bnez	s1,800071b8 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800071d8:	0003a517          	auipc	a0,0x3a
    800071dc:	f5050513          	addi	a0,a0,-176 # 80041128 <disk+0x2128>
    800071e0:	ffffa097          	auipc	ra,0xffffa
    800071e4:	abc080e7          	jalr	-1348(ra) # 80000c9c <release>
}
    800071e8:	70e6                	ld	ra,120(sp)
    800071ea:	7446                	ld	s0,112(sp)
    800071ec:	74a6                	ld	s1,104(sp)
    800071ee:	7906                	ld	s2,96(sp)
    800071f0:	69e6                	ld	s3,88(sp)
    800071f2:	6a46                	ld	s4,80(sp)
    800071f4:	6aa6                	ld	s5,72(sp)
    800071f6:	6b06                	ld	s6,64(sp)
    800071f8:	7be2                	ld	s7,56(sp)
    800071fa:	7c42                	ld	s8,48(sp)
    800071fc:	7ca2                	ld	s9,40(sp)
    800071fe:	7d02                	ld	s10,32(sp)
    80007200:	6de2                	ld	s11,24(sp)
    80007202:	6109                	addi	sp,sp,128
    80007204:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80007206:	f8042503          	lw	a0,-128(s0)
    8000720a:	20050793          	addi	a5,a0,512
    8000720e:	0792                	slli	a5,a5,0x4
  if(write)
    80007210:	00038817          	auipc	a6,0x38
    80007214:	df080813          	addi	a6,a6,-528 # 8003f000 <disk>
    80007218:	00f80733          	add	a4,a6,a5
    8000721c:	01a036b3          	snez	a3,s10
    80007220:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80007224:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80007228:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    8000722c:	7679                	lui	a2,0xffffe
    8000722e:	963e                	add	a2,a2,a5
    80007230:	0003a697          	auipc	a3,0x3a
    80007234:	dd068693          	addi	a3,a3,-560 # 80041000 <disk+0x2000>
    80007238:	6298                	ld	a4,0(a3)
    8000723a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000723c:	0a878593          	addi	a1,a5,168
    80007240:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80007242:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80007244:	6298                	ld	a4,0(a3)
    80007246:	9732                	add	a4,a4,a2
    80007248:	45c1                	li	a1,16
    8000724a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    8000724c:	6298                	ld	a4,0(a3)
    8000724e:	9732                	add	a4,a4,a2
    80007250:	4585                	li	a1,1
    80007252:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80007256:	f8442703          	lw	a4,-124(s0)
    8000725a:	628c                	ld	a1,0(a3)
    8000725c:	962e                	add	a2,a2,a1
    8000725e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffbc00e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80007262:	0712                	slli	a4,a4,0x4
    80007264:	6290                	ld	a2,0(a3)
    80007266:	963a                	add	a2,a2,a4
    80007268:	058a8593          	addi	a1,s5,88
    8000726c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000726e:	6294                	ld	a3,0(a3)
    80007270:	96ba                	add	a3,a3,a4
    80007272:	40000613          	li	a2,1024
    80007276:	c690                	sw	a2,8(a3)
  if(write)
    80007278:	e40d19e3          	bnez	s10,800070ca <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000727c:	0003a697          	auipc	a3,0x3a
    80007280:	d846b683          	ld	a3,-636(a3) # 80041000 <disk+0x2000>
    80007284:	96ba                	add	a3,a3,a4
    80007286:	4609                	li	a2,2
    80007288:	00c69623          	sh	a2,12(a3)
    8000728c:	b5b1                	j	800070d8 <virtio_disk_rw+0xd2>

000000008000728e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000728e:	1101                	addi	sp,sp,-32
    80007290:	ec06                	sd	ra,24(sp)
    80007292:	e822                	sd	s0,16(sp)
    80007294:	e426                	sd	s1,8(sp)
    80007296:	e04a                	sd	s2,0(sp)
    80007298:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000729a:	0003a517          	auipc	a0,0x3a
    8000729e:	e8e50513          	addi	a0,a0,-370 # 80041128 <disk+0x2128>
    800072a2:	ffffa097          	auipc	ra,0xffffa
    800072a6:	924080e7          	jalr	-1756(ra) # 80000bc6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800072aa:	10001737          	lui	a4,0x10001
    800072ae:	533c                	lw	a5,96(a4)
    800072b0:	8b8d                	andi	a5,a5,3
    800072b2:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800072b4:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800072b8:	0003a797          	auipc	a5,0x3a
    800072bc:	d4878793          	addi	a5,a5,-696 # 80041000 <disk+0x2000>
    800072c0:	6b94                	ld	a3,16(a5)
    800072c2:	0207d703          	lhu	a4,32(a5)
    800072c6:	0026d783          	lhu	a5,2(a3)
    800072ca:	06f70163          	beq	a4,a5,8000732c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800072ce:	00038917          	auipc	s2,0x38
    800072d2:	d3290913          	addi	s2,s2,-718 # 8003f000 <disk>
    800072d6:	0003a497          	auipc	s1,0x3a
    800072da:	d2a48493          	addi	s1,s1,-726 # 80041000 <disk+0x2000>
    __sync_synchronize();
    800072de:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800072e2:	6898                	ld	a4,16(s1)
    800072e4:	0204d783          	lhu	a5,32(s1)
    800072e8:	8b9d                	andi	a5,a5,7
    800072ea:	078e                	slli	a5,a5,0x3
    800072ec:	97ba                	add	a5,a5,a4
    800072ee:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800072f0:	20078713          	addi	a4,a5,512
    800072f4:	0712                	slli	a4,a4,0x4
    800072f6:	974a                	add	a4,a4,s2
    800072f8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800072fc:	e731                	bnez	a4,80007348 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800072fe:	20078793          	addi	a5,a5,512
    80007302:	0792                	slli	a5,a5,0x4
    80007304:	97ca                	add	a5,a5,s2
    80007306:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80007308:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000730c:	ffffb097          	auipc	ra,0xffffb
    80007310:	270080e7          	jalr	624(ra) # 8000257c <wakeup>

    disk.used_idx += 1;
    80007314:	0204d783          	lhu	a5,32(s1)
    80007318:	2785                	addiw	a5,a5,1
    8000731a:	17c2                	slli	a5,a5,0x30
    8000731c:	93c1                	srli	a5,a5,0x30
    8000731e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80007322:	6898                	ld	a4,16(s1)
    80007324:	00275703          	lhu	a4,2(a4)
    80007328:	faf71be3          	bne	a4,a5,800072de <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000732c:	0003a517          	auipc	a0,0x3a
    80007330:	dfc50513          	addi	a0,a0,-516 # 80041128 <disk+0x2128>
    80007334:	ffffa097          	auipc	ra,0xffffa
    80007338:	968080e7          	jalr	-1688(ra) # 80000c9c <release>
}
    8000733c:	60e2                	ld	ra,24(sp)
    8000733e:	6442                	ld	s0,16(sp)
    80007340:	64a2                	ld	s1,8(sp)
    80007342:	6902                	ld	s2,0(sp)
    80007344:	6105                	addi	sp,sp,32
    80007346:	8082                	ret
      panic("virtio_disk_intr status");
    80007348:	00002517          	auipc	a0,0x2
    8000734c:	61050513          	addi	a0,a0,1552 # 80009958 <syscalls+0x3e8>
    80007350:	ffff9097          	auipc	ra,0xffff9
    80007354:	1de080e7          	jalr	478(ra) # 8000052e <panic>

0000000080007358 <call_sigret>:
    80007358:	48e1                	li	a7,24
    8000735a:	00000073          	ecall
    8000735e:	8082                	ret

0000000080007360 <end_sigret>:
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
