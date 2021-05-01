
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	18010113          	addi	sp,sp,384 # 80009180 <stack0>
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
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fee70713          	addi	a4,a4,-18 # 80009040 <timer_scratch>
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
    80000064:	00006797          	auipc	a5,0x6
    80000068:	7dc78793          	addi	a5,a5,2012 # 80006840 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffbd7ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dd878793          	addi	a5,a5,-552 # 80000e86 <main>
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
    80000122:	920080e7          	jalr	-1760(ra) # 80002a3e <either_copyin>
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
    8000017c:	00011517          	auipc	a0,0x11
    80000180:	00450513          	addi	a0,a0,4 # 80011180 <cons>
    80000184:	00001097          	auipc	ra,0x1
    80000188:	a42080e7          	jalr	-1470(ra) # 80000bc6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018c:	00011497          	auipc	s1,0x11
    80000190:	ff448493          	addi	s1,s1,-12 # 80011180 <cons>
      if(myproc()->killed==1){
    80000194:	4905                	li	s2,1
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000196:	00011997          	auipc	s3,0x11
    8000019a:	08298993          	addi	s3,s3,130 # 80011218 <cons+0x98>
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
    800001b6:	8ee080e7          	jalr	-1810(ra) # 80001aa0 <myproc>
    800001ba:	4d5c                	lw	a5,28(a0)
    800001bc:	07278863          	beq	a5,s2,8000022c <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001c0:	85a6                	mv	a1,s1
    800001c2:	854e                	mv	a0,s3
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	322080e7          	jalr	802(ra) # 800024e6 <sleep>
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
    80000204:	7e8080e7          	jalr	2024(ra) # 800029e8 <either_copyout>
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
    80000216:	00011517          	auipc	a0,0x11
    8000021a:	f6a50513          	addi	a0,a0,-150 # 80011180 <cons>
    8000021e:	00001097          	auipc	ra,0x1
    80000222:	a72080e7          	jalr	-1422(ra) # 80000c90 <release>

  return target - n;
    80000226:	414b853b          	subw	a0,s7,s4
    8000022a:	a811                	j	8000023e <consoleread+0xe8>
        release(&cons.lock);
    8000022c:	00011517          	auipc	a0,0x11
    80000230:	f5450513          	addi	a0,a0,-172 # 80011180 <cons>
    80000234:	00001097          	auipc	ra,0x1
    80000238:	a5c080e7          	jalr	-1444(ra) # 80000c90 <release>
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
    80000262:	00011717          	auipc	a4,0x11
    80000266:	faf72b23          	sw	a5,-74(a4) # 80011218 <cons+0x98>
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
    800002bc:	00011517          	auipc	a0,0x11
    800002c0:	ec450513          	addi	a0,a0,-316 # 80011180 <cons>
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
    800002e6:	7b2080e7          	jalr	1970(ra) # 80002a94 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ea:	00011517          	auipc	a0,0x11
    800002ee:	e9650513          	addi	a0,a0,-362 # 80011180 <cons>
    800002f2:	00001097          	auipc	ra,0x1
    800002f6:	99e080e7          	jalr	-1634(ra) # 80000c90 <release>
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
    8000030e:	00011717          	auipc	a4,0x11
    80000312:	e7270713          	addi	a4,a4,-398 # 80011180 <cons>
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
    80000338:	00011797          	auipc	a5,0x11
    8000033c:	e4878793          	addi	a5,a5,-440 # 80011180 <cons>
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
    80000366:	00011797          	auipc	a5,0x11
    8000036a:	eb27a783          	lw	a5,-334(a5) # 80011218 <cons+0x98>
    8000036e:	0807879b          	addiw	a5,a5,128
    80000372:	f6f61ce3          	bne	a2,a5,800002ea <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000376:	863e                	mv	a2,a5
    80000378:	a07d                	j	80000426 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000037a:	00011717          	auipc	a4,0x11
    8000037e:	e0670713          	addi	a4,a4,-506 # 80011180 <cons>
    80000382:	0a072783          	lw	a5,160(a4)
    80000386:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000038a:	00011497          	auipc	s1,0x11
    8000038e:	df648493          	addi	s1,s1,-522 # 80011180 <cons>
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
    800003c6:	00011717          	auipc	a4,0x11
    800003ca:	dba70713          	addi	a4,a4,-582 # 80011180 <cons>
    800003ce:	0a072783          	lw	a5,160(a4)
    800003d2:	09c72703          	lw	a4,156(a4)
    800003d6:	f0f70ae3          	beq	a4,a5,800002ea <consoleintr+0x3c>
      cons.e--;
    800003da:	37fd                	addiw	a5,a5,-1
    800003dc:	00011717          	auipc	a4,0x11
    800003e0:	e4f72223          	sw	a5,-444(a4) # 80011220 <cons+0xa0>
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
    80000402:	00011797          	auipc	a5,0x11
    80000406:	d7e78793          	addi	a5,a5,-642 # 80011180 <cons>
    8000040a:	0a07a703          	lw	a4,160(a5)
    8000040e:	0017069b          	addiw	a3,a4,1
    80000412:	0006861b          	sext.w	a2,a3
    80000416:	0ad7a023          	sw	a3,160(a5)
    8000041a:	07f77713          	andi	a4,a4,127
    8000041e:	97ba                	add	a5,a5,a4
    80000420:	4729                	li	a4,10
    80000422:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000426:	00011797          	auipc	a5,0x11
    8000042a:	dec7ab23          	sw	a2,-522(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    8000042e:	00011517          	auipc	a0,0x11
    80000432:	dea50513          	addi	a0,a0,-534 # 80011218 <cons+0x98>
    80000436:	00002097          	auipc	ra,0x2
    8000043a:	23a080e7          	jalr	570(ra) # 80002670 <wakeup>
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
    80000448:	00008597          	auipc	a1,0x8
    8000044c:	bc858593          	addi	a1,a1,-1080 # 80008010 <etext+0x10>
    80000450:	00011517          	auipc	a0,0x11
    80000454:	d3050513          	addi	a0,a0,-720 # 80011180 <cons>
    80000458:	00000097          	auipc	ra,0x0
    8000045c:	6de080e7          	jalr	1758(ra) # 80000b36 <initlock>

  uartinit();
    80000460:	00000097          	auipc	ra,0x0
    80000464:	32a080e7          	jalr	810(ra) # 8000078a <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000468:	0003c797          	auipc	a5,0x3c
    8000046c:	70878793          	addi	a5,a5,1800 # 8003cb70 <devsw>
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
    800004aa:	00008617          	auipc	a2,0x8
    800004ae:	b9660613          	addi	a2,a2,-1130 # 80008040 <digits>
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
    8000053a:	00011797          	auipc	a5,0x11
    8000053e:	d007a323          	sw	zero,-762(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    80000542:	00008517          	auipc	a0,0x8
    80000546:	ad650513          	addi	a0,a0,-1322 # 80008018 <etext+0x18>
    8000054a:	00000097          	auipc	ra,0x0
    8000054e:	02e080e7          	jalr	46(ra) # 80000578 <printf>
  printf(s);
    80000552:	8526                	mv	a0,s1
    80000554:	00000097          	auipc	ra,0x0
    80000558:	024080e7          	jalr	36(ra) # 80000578 <printf>
  printf("\n");
    8000055c:	00008517          	auipc	a0,0x8
    80000560:	dec50513          	addi	a0,a0,-532 # 80008348 <digits+0x308>
    80000564:	00000097          	auipc	ra,0x0
    80000568:	014080e7          	jalr	20(ra) # 80000578 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000056c:	4785                	li	a5,1
    8000056e:	00009717          	auipc	a4,0x9
    80000572:	a8f72923          	sw	a5,-1390(a4) # 80009000 <panicked>
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
    800005aa:	00011d97          	auipc	s11,0x11
    800005ae:	c96dad83          	lw	s11,-874(s11) # 80011240 <pr+0x18>
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
    800005d6:	00008b17          	auipc	s6,0x8
    800005da:	a6ab0b13          	addi	s6,s6,-1430 # 80008040 <digits>
    switch(c){
    800005de:	07300c93          	li	s9,115
    800005e2:	06400c13          	li	s8,100
    800005e6:	a82d                	j	80000620 <printf+0xa8>
    acquire(&pr.lock);
    800005e8:	00011517          	auipc	a0,0x11
    800005ec:	c4050513          	addi	a0,a0,-960 # 80011228 <pr>
    800005f0:	00000097          	auipc	ra,0x0
    800005f4:	5d6080e7          	jalr	1494(ra) # 80000bc6 <acquire>
    800005f8:	bf7d                	j	800005b6 <printf+0x3e>
    panic("null fmt");
    800005fa:	00008517          	auipc	a0,0x8
    800005fe:	a2e50513          	addi	a0,a0,-1490 # 80008028 <etext+0x28>
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
    800006f4:	00008497          	auipc	s1,0x8
    800006f8:	92c48493          	addi	s1,s1,-1748 # 80008020 <etext+0x20>
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
    80000746:	00011517          	auipc	a0,0x11
    8000074a:	ae250513          	addi	a0,a0,-1310 # 80011228 <pr>
    8000074e:	00000097          	auipc	ra,0x0
    80000752:	542080e7          	jalr	1346(ra) # 80000c90 <release>
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
    80000762:	00011497          	auipc	s1,0x11
    80000766:	ac648493          	addi	s1,s1,-1338 # 80011228 <pr>
    8000076a:	00008597          	auipc	a1,0x8
    8000076e:	8ce58593          	addi	a1,a1,-1842 # 80008038 <etext+0x38>
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
    800007ba:	00008597          	auipc	a1,0x8
    800007be:	89e58593          	addi	a1,a1,-1890 # 80008058 <digits+0x18>
    800007c2:	00011517          	auipc	a0,0x11
    800007c6:	a8650513          	addi	a0,a0,-1402 # 80011248 <uart_tx_lock>
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
    800007ee:	00009797          	auipc	a5,0x9
    800007f2:	8127a783          	lw	a5,-2030(a5) # 80009000 <panicked>
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
    80000818:	41c080e7          	jalr	1052(ra) # 80000c30 <pop_off>
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
    80000826:	00008797          	auipc	a5,0x8
    8000082a:	7e27b783          	ld	a5,2018(a5) # 80009008 <uart_tx_r>
    8000082e:	00008717          	auipc	a4,0x8
    80000832:	7e273703          	ld	a4,2018(a4) # 80009010 <uart_tx_w>
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
    80000850:	00011a17          	auipc	s4,0x11
    80000854:	9f8a0a13          	addi	s4,s4,-1544 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000858:	00008497          	auipc	s1,0x8
    8000085c:	7b048493          	addi	s1,s1,1968 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000860:	00008997          	auipc	s3,0x8
    80000864:	7b098993          	addi	s3,s3,1968 # 80009010 <uart_tx_w>
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
    80000886:	dee080e7          	jalr	-530(ra) # 80002670 <wakeup>
    
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
    800008be:	00011517          	auipc	a0,0x11
    800008c2:	98a50513          	addi	a0,a0,-1654 # 80011248 <uart_tx_lock>
    800008c6:	00000097          	auipc	ra,0x0
    800008ca:	300080e7          	jalr	768(ra) # 80000bc6 <acquire>
  if(panicked){
    800008ce:	00008797          	auipc	a5,0x8
    800008d2:	7327a783          	lw	a5,1842(a5) # 80009000 <panicked>
    800008d6:	c391                	beqz	a5,800008da <uartputc+0x2e>
    for(;;)
    800008d8:	a001                	j	800008d8 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008da:	00008717          	auipc	a4,0x8
    800008de:	73673703          	ld	a4,1846(a4) # 80009010 <uart_tx_w>
    800008e2:	00008797          	auipc	a5,0x8
    800008e6:	7267b783          	ld	a5,1830(a5) # 80009008 <uart_tx_r>
    800008ea:	02078793          	addi	a5,a5,32
    800008ee:	02e79b63          	bne	a5,a4,80000924 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    800008f2:	00011997          	auipc	s3,0x11
    800008f6:	95698993          	addi	s3,s3,-1706 # 80011248 <uart_tx_lock>
    800008fa:	00008497          	auipc	s1,0x8
    800008fe:	70e48493          	addi	s1,s1,1806 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000902:	00008917          	auipc	s2,0x8
    80000906:	70e90913          	addi	s2,s2,1806 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000090a:	85ce                	mv	a1,s3
    8000090c:	8526                	mv	a0,s1
    8000090e:	00002097          	auipc	ra,0x2
    80000912:	bd8080e7          	jalr	-1064(ra) # 800024e6 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000916:	00093703          	ld	a4,0(s2)
    8000091a:	609c                	ld	a5,0(s1)
    8000091c:	02078793          	addi	a5,a5,32
    80000920:	fee785e3          	beq	a5,a4,8000090a <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000924:	00011497          	auipc	s1,0x11
    80000928:	92448493          	addi	s1,s1,-1756 # 80011248 <uart_tx_lock>
    8000092c:	01f77793          	andi	a5,a4,31
    80000930:	97a6                	add	a5,a5,s1
    80000932:	01478c23          	sb	s4,24(a5)
      uart_tx_w += 1;
    80000936:	0705                	addi	a4,a4,1
    80000938:	00008797          	auipc	a5,0x8
    8000093c:	6ce7bc23          	sd	a4,1752(a5) # 80009010 <uart_tx_w>
      uartstart();
    80000940:	00000097          	auipc	ra,0x0
    80000944:	ee6080e7          	jalr	-282(ra) # 80000826 <uartstart>
      release(&uart_tx_lock);
    80000948:	8526                	mv	a0,s1
    8000094a:	00000097          	auipc	ra,0x0
    8000094e:	346080e7          	jalr	838(ra) # 80000c90 <release>
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
    800009ac:	00011497          	auipc	s1,0x11
    800009b0:	89c48493          	addi	s1,s1,-1892 # 80011248 <uart_tx_lock>
    800009b4:	8526                	mv	a0,s1
    800009b6:	00000097          	auipc	ra,0x0
    800009ba:	210080e7          	jalr	528(ra) # 80000bc6 <acquire>
  uartstart();
    800009be:	00000097          	auipc	ra,0x0
    800009c2:	e68080e7          	jalr	-408(ra) # 80000826 <uartstart>
  release(&uart_tx_lock);
    800009c6:	8526                	mv	a0,s1
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	2c8080e7          	jalr	712(ra) # 80000c90 <release>
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
    800009ee:	00040797          	auipc	a5,0x40
    800009f2:	61278793          	addi	a5,a5,1554 # 80041000 <end>
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
    80000a0a:	2d2080e7          	jalr	722(ra) # 80000cd8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a0e:	00011917          	auipc	s2,0x11
    80000a12:	87290913          	addi	s2,s2,-1934 # 80011280 <kmem>
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
    80000a30:	264080e7          	jalr	612(ra) # 80000c90 <release>
}
    80000a34:	60e2                	ld	ra,24(sp)
    80000a36:	6442                	ld	s0,16(sp)
    80000a38:	64a2                	ld	s1,8(sp)
    80000a3a:	6902                	ld	s2,0(sp)
    80000a3c:	6105                	addi	sp,sp,32
    80000a3e:	8082                	ret
    panic("kfree");
    80000a40:	00007517          	auipc	a0,0x7
    80000a44:	62050513          	addi	a0,a0,1568 # 80008060 <digits+0x20>
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
    80000aa2:	00007597          	auipc	a1,0x7
    80000aa6:	5c658593          	addi	a1,a1,1478 # 80008068 <digits+0x28>
    80000aaa:	00010517          	auipc	a0,0x10
    80000aae:	7d650513          	addi	a0,a0,2006 # 80011280 <kmem>
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	084080e7          	jalr	132(ra) # 80000b36 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aba:	45c5                	li	a1,17
    80000abc:	05ee                	slli	a1,a1,0x1b
    80000abe:	00040517          	auipc	a0,0x40
    80000ac2:	54250513          	addi	a0,a0,1346 # 80041000 <end>
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
    80000ae0:	00010497          	auipc	s1,0x10
    80000ae4:	7a048493          	addi	s1,s1,1952 # 80011280 <kmem>
    80000ae8:	8526                	mv	a0,s1
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	0dc080e7          	jalr	220(ra) # 80000bc6 <acquire>
  r = kmem.freelist;
    80000af2:	6c84                	ld	s1,24(s1)
  if(r)
    80000af4:	c885                	beqz	s1,80000b24 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000af6:	609c                	ld	a5,0(s1)
    80000af8:	00010517          	auipc	a0,0x10
    80000afc:	78850513          	addi	a0,a0,1928 # 80011280 <kmem>
    80000b00:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b02:	00000097          	auipc	ra,0x0
    80000b06:	18e080e7          	jalr	398(ra) # 80000c90 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b0a:	6605                	lui	a2,0x1
    80000b0c:	4595                	li	a1,5
    80000b0e:	8526                	mv	a0,s1
    80000b10:	00000097          	auipc	ra,0x0
    80000b14:	1c8080e7          	jalr	456(ra) # 80000cd8 <memset>
  return (void*)r;
}
    80000b18:	8526                	mv	a0,s1
    80000b1a:	60e2                	ld	ra,24(sp)
    80000b1c:	6442                	ld	s0,16(sp)
    80000b1e:	64a2                	ld	s1,8(sp)
    80000b20:	6105                	addi	sp,sp,32
    80000b22:	8082                	ret
  release(&kmem.lock);
    80000b24:	00010517          	auipc	a0,0x10
    80000b28:	75c50513          	addi	a0,a0,1884 # 80011280 <kmem>
    80000b2c:	00000097          	auipc	ra,0x0
    80000b30:	164080e7          	jalr	356(ra) # 80000c90 <release>
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
    80000b64:	f1c080e7          	jalr	-228(ra) # 80001a7c <mycpu>
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
    80000b96:	eea080e7          	jalr	-278(ra) # 80001a7c <mycpu>
    80000b9a:	5d3c                	lw	a5,120(a0)
    80000b9c:	cf89                	beqz	a5,80000bb6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	ede080e7          	jalr	-290(ra) # 80001a7c <mycpu>
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
    80000bba:	ec6080e7          	jalr	-314(ra) # 80001a7c <mycpu>
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
    80000bfa:	e86080e7          	jalr	-378(ra) # 80001a7c <mycpu>
    80000bfe:	e888                	sd	a0,16(s1)
}
    80000c00:	60e2                	ld	ra,24(sp)
    80000c02:	6442                	ld	s0,16(sp)
    80000c04:	64a2                	ld	s1,8(sp)
    80000c06:	6105                	addi	sp,sp,32
    80000c08:	8082                	ret
    printf("pid=%d tried to lock when already holding\n",lk->cpu->proc->pid);//TODO delete
    80000c0a:	689c                	ld	a5,16(s1)
    80000c0c:	639c                	ld	a5,0(a5)
    80000c0e:	53cc                	lw	a1,36(a5)
    80000c10:	00007517          	auipc	a0,0x7
    80000c14:	46050513          	addi	a0,a0,1120 # 80008070 <digits+0x30>
    80000c18:	00000097          	auipc	ra,0x0
    80000c1c:	960080e7          	jalr	-1696(ra) # 80000578 <printf>
    panic("acquire");
    80000c20:	00007517          	auipc	a0,0x7
    80000c24:	48050513          	addi	a0,a0,1152 # 800080a0 <digits+0x60>
    80000c28:	00000097          	auipc	ra,0x0
    80000c2c:	906080e7          	jalr	-1786(ra) # 8000052e <panic>

0000000080000c30 <pop_off>:

void
pop_off(void)
{
    80000c30:	1141                	addi	sp,sp,-16
    80000c32:	e406                	sd	ra,8(sp)
    80000c34:	e022                	sd	s0,0(sp)
    80000c36:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c38:	00001097          	auipc	ra,0x1
    80000c3c:	e44080e7          	jalr	-444(ra) # 80001a7c <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c40:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c44:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c46:	e78d                	bnez	a5,80000c70 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c48:	5d3c                	lw	a5,120(a0)
    80000c4a:	02f05b63          	blez	a5,80000c80 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c4e:	37fd                	addiw	a5,a5,-1
    80000c50:	0007871b          	sext.w	a4,a5
    80000c54:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c56:	eb09                	bnez	a4,80000c68 <pop_off+0x38>
    80000c58:	5d7c                	lw	a5,124(a0)
    80000c5a:	c799                	beqz	a5,80000c68 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c5c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c60:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c64:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c68:	60a2                	ld	ra,8(sp)
    80000c6a:	6402                	ld	s0,0(sp)
    80000c6c:	0141                	addi	sp,sp,16
    80000c6e:	8082                	ret
    panic("pop_off - interruptible");
    80000c70:	00007517          	auipc	a0,0x7
    80000c74:	43850513          	addi	a0,a0,1080 # 800080a8 <digits+0x68>
    80000c78:	00000097          	auipc	ra,0x0
    80000c7c:	8b6080e7          	jalr	-1866(ra) # 8000052e <panic>
    panic("pop_off");
    80000c80:	00007517          	auipc	a0,0x7
    80000c84:	44050513          	addi	a0,a0,1088 # 800080c0 <digits+0x80>
    80000c88:	00000097          	auipc	ra,0x0
    80000c8c:	8a6080e7          	jalr	-1882(ra) # 8000052e <panic>

0000000080000c90 <release>:
{
    80000c90:	1101                	addi	sp,sp,-32
    80000c92:	ec06                	sd	ra,24(sp)
    80000c94:	e822                	sd	s0,16(sp)
    80000c96:	e426                	sd	s1,8(sp)
    80000c98:	1000                	addi	s0,sp,32
    80000c9a:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c9c:	00000097          	auipc	ra,0x0
    80000ca0:	eb0080e7          	jalr	-336(ra) # 80000b4c <holding>
    80000ca4:	c115                	beqz	a0,80000cc8 <release+0x38>
  lk->cpu = 0;
    80000ca6:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000caa:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000cae:	0f50000f          	fence	iorw,ow
    80000cb2:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	f7a080e7          	jalr	-134(ra) # 80000c30 <pop_off>
}
    80000cbe:	60e2                	ld	ra,24(sp)
    80000cc0:	6442                	ld	s0,16(sp)
    80000cc2:	64a2                	ld	s1,8(sp)
    80000cc4:	6105                	addi	sp,sp,32
    80000cc6:	8082                	ret
    panic("release");
    80000cc8:	00007517          	auipc	a0,0x7
    80000ccc:	40050513          	addi	a0,a0,1024 # 800080c8 <digits+0x88>
    80000cd0:	00000097          	auipc	ra,0x0
    80000cd4:	85e080e7          	jalr	-1954(ra) # 8000052e <panic>

0000000080000cd8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd8:	1141                	addi	sp,sp,-16
    80000cda:	e422                	sd	s0,8(sp)
    80000cdc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cde:	ca19                	beqz	a2,80000cf4 <memset+0x1c>
    80000ce0:	87aa                	mv	a5,a0
    80000ce2:	1602                	slli	a2,a2,0x20
    80000ce4:	9201                	srli	a2,a2,0x20
    80000ce6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cea:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cee:	0785                	addi	a5,a5,1
    80000cf0:	fee79de3          	bne	a5,a4,80000cea <memset+0x12>
  }
  return dst;
}
    80000cf4:	6422                	ld	s0,8(sp)
    80000cf6:	0141                	addi	sp,sp,16
    80000cf8:	8082                	ret

0000000080000cfa <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cfa:	1141                	addi	sp,sp,-16
    80000cfc:	e422                	sd	s0,8(sp)
    80000cfe:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d00:	ca05                	beqz	a2,80000d30 <memcmp+0x36>
    80000d02:	fff6069b          	addiw	a3,a2,-1
    80000d06:	1682                	slli	a3,a3,0x20
    80000d08:	9281                	srli	a3,a3,0x20
    80000d0a:	0685                	addi	a3,a3,1
    80000d0c:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d0e:	00054783          	lbu	a5,0(a0)
    80000d12:	0005c703          	lbu	a4,0(a1)
    80000d16:	00e79863          	bne	a5,a4,80000d26 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d1a:	0505                	addi	a0,a0,1
    80000d1c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d1e:	fed518e3          	bne	a0,a3,80000d0e <memcmp+0x14>
  }

  return 0;
    80000d22:	4501                	li	a0,0
    80000d24:	a019                	j	80000d2a <memcmp+0x30>
      return *s1 - *s2;
    80000d26:	40e7853b          	subw	a0,a5,a4
}
    80000d2a:	6422                	ld	s0,8(sp)
    80000d2c:	0141                	addi	sp,sp,16
    80000d2e:	8082                	ret
  return 0;
    80000d30:	4501                	li	a0,0
    80000d32:	bfe5                	j	80000d2a <memcmp+0x30>

0000000080000d34 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d34:	1141                	addi	sp,sp,-16
    80000d36:	e422                	sd	s0,8(sp)
    80000d38:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d3a:	02a5e563          	bltu	a1,a0,80000d64 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3e:	fff6069b          	addiw	a3,a2,-1
    80000d42:	ce11                	beqz	a2,80000d5e <memmove+0x2a>
    80000d44:	1682                	slli	a3,a3,0x20
    80000d46:	9281                	srli	a3,a3,0x20
    80000d48:	0685                	addi	a3,a3,1
    80000d4a:	96ae                	add	a3,a3,a1
    80000d4c:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d4e:	0585                	addi	a1,a1,1
    80000d50:	0785                	addi	a5,a5,1
    80000d52:	fff5c703          	lbu	a4,-1(a1)
    80000d56:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d5a:	fed59ae3          	bne	a1,a3,80000d4e <memmove+0x1a>

  return dst;
}
    80000d5e:	6422                	ld	s0,8(sp)
    80000d60:	0141                	addi	sp,sp,16
    80000d62:	8082                	ret
  if(s < d && s + n > d){
    80000d64:	02061713          	slli	a4,a2,0x20
    80000d68:	9301                	srli	a4,a4,0x20
    80000d6a:	00e587b3          	add	a5,a1,a4
    80000d6e:	fcf578e3          	bgeu	a0,a5,80000d3e <memmove+0xa>
    d += n;
    80000d72:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d74:	fff6069b          	addiw	a3,a2,-1
    80000d78:	d27d                	beqz	a2,80000d5e <memmove+0x2a>
    80000d7a:	02069613          	slli	a2,a3,0x20
    80000d7e:	9201                	srli	a2,a2,0x20
    80000d80:	fff64613          	not	a2,a2
    80000d84:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d86:	17fd                	addi	a5,a5,-1
    80000d88:	177d                	addi	a4,a4,-1
    80000d8a:	0007c683          	lbu	a3,0(a5)
    80000d8e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000d92:	fef61ae3          	bne	a2,a5,80000d86 <memmove+0x52>
    80000d96:	b7e1                	j	80000d5e <memmove+0x2a>

0000000080000d98 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d98:	1141                	addi	sp,sp,-16
    80000d9a:	e406                	sd	ra,8(sp)
    80000d9c:	e022                	sd	s0,0(sp)
    80000d9e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000da0:	00000097          	auipc	ra,0x0
    80000da4:	f94080e7          	jalr	-108(ra) # 80000d34 <memmove>
}
    80000da8:	60a2                	ld	ra,8(sp)
    80000daa:	6402                	ld	s0,0(sp)
    80000dac:	0141                	addi	sp,sp,16
    80000dae:	8082                	ret

0000000080000db0 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000db0:	1141                	addi	sp,sp,-16
    80000db2:	e422                	sd	s0,8(sp)
    80000db4:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000db6:	ce11                	beqz	a2,80000dd2 <strncmp+0x22>
    80000db8:	00054783          	lbu	a5,0(a0)
    80000dbc:	cf89                	beqz	a5,80000dd6 <strncmp+0x26>
    80000dbe:	0005c703          	lbu	a4,0(a1)
    80000dc2:	00f71a63          	bne	a4,a5,80000dd6 <strncmp+0x26>
    n--, p++, q++;
    80000dc6:	367d                	addiw	a2,a2,-1
    80000dc8:	0505                	addi	a0,a0,1
    80000dca:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dcc:	f675                	bnez	a2,80000db8 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dce:	4501                	li	a0,0
    80000dd0:	a809                	j	80000de2 <strncmp+0x32>
    80000dd2:	4501                	li	a0,0
    80000dd4:	a039                	j	80000de2 <strncmp+0x32>
  if(n == 0)
    80000dd6:	ca09                	beqz	a2,80000de8 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dd8:	00054503          	lbu	a0,0(a0)
    80000ddc:	0005c783          	lbu	a5,0(a1)
    80000de0:	9d1d                	subw	a0,a0,a5
}
    80000de2:	6422                	ld	s0,8(sp)
    80000de4:	0141                	addi	sp,sp,16
    80000de6:	8082                	ret
    return 0;
    80000de8:	4501                	li	a0,0
    80000dea:	bfe5                	j	80000de2 <strncmp+0x32>

0000000080000dec <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dec:	1141                	addi	sp,sp,-16
    80000dee:	e422                	sd	s0,8(sp)
    80000df0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000df2:	872a                	mv	a4,a0
    80000df4:	8832                	mv	a6,a2
    80000df6:	367d                	addiw	a2,a2,-1
    80000df8:	01005963          	blez	a6,80000e0a <strncpy+0x1e>
    80000dfc:	0705                	addi	a4,a4,1
    80000dfe:	0005c783          	lbu	a5,0(a1)
    80000e02:	fef70fa3          	sb	a5,-1(a4)
    80000e06:	0585                	addi	a1,a1,1
    80000e08:	f7f5                	bnez	a5,80000df4 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e0a:	86ba                	mv	a3,a4
    80000e0c:	00c05c63          	blez	a2,80000e24 <strncpy+0x38>
    *s++ = 0;
    80000e10:	0685                	addi	a3,a3,1
    80000e12:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e16:	fff6c793          	not	a5,a3
    80000e1a:	9fb9                	addw	a5,a5,a4
    80000e1c:	010787bb          	addw	a5,a5,a6
    80000e20:	fef048e3          	bgtz	a5,80000e10 <strncpy+0x24>
  return os;
}
    80000e24:	6422                	ld	s0,8(sp)
    80000e26:	0141                	addi	sp,sp,16
    80000e28:	8082                	ret

0000000080000e2a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e2a:	1141                	addi	sp,sp,-16
    80000e2c:	e422                	sd	s0,8(sp)
    80000e2e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e30:	02c05363          	blez	a2,80000e56 <safestrcpy+0x2c>
    80000e34:	fff6069b          	addiw	a3,a2,-1
    80000e38:	1682                	slli	a3,a3,0x20
    80000e3a:	9281                	srli	a3,a3,0x20
    80000e3c:	96ae                	add	a3,a3,a1
    80000e3e:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e40:	00d58963          	beq	a1,a3,80000e52 <safestrcpy+0x28>
    80000e44:	0585                	addi	a1,a1,1
    80000e46:	0785                	addi	a5,a5,1
    80000e48:	fff5c703          	lbu	a4,-1(a1)
    80000e4c:	fee78fa3          	sb	a4,-1(a5)
    80000e50:	fb65                	bnez	a4,80000e40 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e52:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e56:	6422                	ld	s0,8(sp)
    80000e58:	0141                	addi	sp,sp,16
    80000e5a:	8082                	ret

0000000080000e5c <strlen>:

int
strlen(const char *s)
{
    80000e5c:	1141                	addi	sp,sp,-16
    80000e5e:	e422                	sd	s0,8(sp)
    80000e60:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e62:	00054783          	lbu	a5,0(a0)
    80000e66:	cf91                	beqz	a5,80000e82 <strlen+0x26>
    80000e68:	0505                	addi	a0,a0,1
    80000e6a:	87aa                	mv	a5,a0
    80000e6c:	4685                	li	a3,1
    80000e6e:	9e89                	subw	a3,a3,a0
    80000e70:	00f6853b          	addw	a0,a3,a5
    80000e74:	0785                	addi	a5,a5,1
    80000e76:	fff7c703          	lbu	a4,-1(a5)
    80000e7a:	fb7d                	bnez	a4,80000e70 <strlen+0x14>
    ;
  return n;
}
    80000e7c:	6422                	ld	s0,8(sp)
    80000e7e:	0141                	addi	sp,sp,16
    80000e80:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e82:	4501                	li	a0,0
    80000e84:	bfe5                	j	80000e7c <strlen+0x20>

0000000080000e86 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e86:	1141                	addi	sp,sp,-16
    80000e88:	e406                	sd	ra,8(sp)
    80000e8a:	e022                	sd	s0,0(sp)
    80000e8c:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e8e:	00001097          	auipc	ra,0x1
    80000e92:	bde080e7          	jalr	-1058(ra) # 80001a6c <cpuid>
    userinit();      // first user process
    printf("main -after user init\n");
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e96:	00008717          	auipc	a4,0x8
    80000e9a:	18270713          	addi	a4,a4,386 # 80009018 <started>
  if(cpuid() == 0){
    80000e9e:	c139                	beqz	a0,80000ee4 <main+0x5e>
    while(started == 0)
    80000ea0:	431c                	lw	a5,0(a4)
    80000ea2:	2781                	sext.w	a5,a5
    80000ea4:	dff5                	beqz	a5,80000ea0 <main+0x1a>
      ;
    __sync_synchronize();
    80000ea6:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000eaa:	00001097          	auipc	ra,0x1
    80000eae:	bc2080e7          	jalr	-1086(ra) # 80001a6c <cpuid>
    80000eb2:	85aa                	mv	a1,a0
    80000eb4:	00007517          	auipc	a0,0x7
    80000eb8:	24c50513          	addi	a0,a0,588 # 80008100 <digits+0xc0>
    80000ebc:	fffff097          	auipc	ra,0xfffff
    80000ec0:	6bc080e7          	jalr	1724(ra) # 80000578 <printf>
    kvminithart();    // turn on paging
    80000ec4:	00000097          	auipc	ra,0x0
    80000ec8:	0e8080e7          	jalr	232(ra) # 80000fac <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ecc:	00002097          	auipc	ra,0x2
    80000ed0:	240080e7          	jalr	576(ra) # 8000310c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ed4:	00006097          	auipc	ra,0x6
    80000ed8:	9ac080e7          	jalr	-1620(ra) # 80006880 <plicinithart>
  }

  scheduler();        
    80000edc:	00001097          	auipc	ra,0x1
    80000ee0:	3fa080e7          	jalr	1018(ra) # 800022d6 <scheduler>
    consoleinit();
    80000ee4:	fffff097          	auipc	ra,0xfffff
    80000ee8:	55c080e7          	jalr	1372(ra) # 80000440 <consoleinit>
    printfinit();
    80000eec:	00000097          	auipc	ra,0x0
    80000ef0:	86c080e7          	jalr	-1940(ra) # 80000758 <printfinit>
    printf("\n");
    80000ef4:	00007517          	auipc	a0,0x7
    80000ef8:	45450513          	addi	a0,a0,1108 # 80008348 <digits+0x308>
    80000efc:	fffff097          	auipc	ra,0xfffff
    80000f00:	67c080e7          	jalr	1660(ra) # 80000578 <printf>
    printf("\n");
    80000f04:	00007517          	auipc	a0,0x7
    80000f08:	44450513          	addi	a0,a0,1092 # 80008348 <digits+0x308>
    80000f0c:	fffff097          	auipc	ra,0xfffff
    80000f10:	66c080e7          	jalr	1644(ra) # 80000578 <printf>
    kinit();         // physical page allocator
    80000f14:	00000097          	auipc	ra,0x0
    80000f18:	b86080e7          	jalr	-1146(ra) # 80000a9a <kinit>
    kvminit();       // create kernel page table
    80000f1c:	00000097          	auipc	ra,0x0
    80000f20:	340080e7          	jalr	832(ra) # 8000125c <kvminit>
    kvminithart();   // turn on paging
    80000f24:	00000097          	auipc	ra,0x0
    80000f28:	088080e7          	jalr	136(ra) # 80000fac <kvminithart>
    procinit();      // process table
    80000f2c:	00001097          	auipc	ra,0x1
    80000f30:	a12080e7          	jalr	-1518(ra) # 8000193e <procinit>
    trapinit();      // trap vectors
    80000f34:	00002097          	auipc	ra,0x2
    80000f38:	1b0080e7          	jalr	432(ra) # 800030e4 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3c:	00002097          	auipc	ra,0x2
    80000f40:	1d0080e7          	jalr	464(ra) # 8000310c <trapinithart>
    plicinit();      // set up interrupt controller
    80000f44:	00006097          	auipc	ra,0x6
    80000f48:	926080e7          	jalr	-1754(ra) # 8000686a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4c:	00006097          	auipc	ra,0x6
    80000f50:	934080e7          	jalr	-1740(ra) # 80006880 <plicinithart>
    binit();         // buffer cache
    80000f54:	00003097          	auipc	ra,0x3
    80000f58:	e38080e7          	jalr	-456(ra) # 80003d8c <binit>
    iinit();         // inode cache
    80000f5c:	00003097          	auipc	ra,0x3
    80000f60:	4ca080e7          	jalr	1226(ra) # 80004426 <iinit>
    fileinit();      // file table
    80000f64:	00004097          	auipc	ra,0x4
    80000f68:	476080e7          	jalr	1142(ra) # 800053da <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6c:	00006097          	auipc	ra,0x6
    80000f70:	a36080e7          	jalr	-1482(ra) # 800069a2 <virtio_disk_init>
    printf("main before user init \n");
    80000f74:	00007517          	auipc	a0,0x7
    80000f78:	15c50513          	addi	a0,a0,348 # 800080d0 <digits+0x90>
    80000f7c:	fffff097          	auipc	ra,0xfffff
    80000f80:	5fc080e7          	jalr	1532(ra) # 80000578 <printf>
    userinit();      // first user process
    80000f84:	00001097          	auipc	ra,0x1
    80000f88:	02e080e7          	jalr	46(ra) # 80001fb2 <userinit>
    printf("main -after user init\n");
    80000f8c:	00007517          	auipc	a0,0x7
    80000f90:	15c50513          	addi	a0,a0,348 # 800080e8 <digits+0xa8>
    80000f94:	fffff097          	auipc	ra,0xfffff
    80000f98:	5e4080e7          	jalr	1508(ra) # 80000578 <printf>
    __sync_synchronize();
    80000f9c:	0ff0000f          	fence
    started = 1;
    80000fa0:	4785                	li	a5,1
    80000fa2:	00008717          	auipc	a4,0x8
    80000fa6:	06f72b23          	sw	a5,118(a4) # 80009018 <started>
    80000faa:	bf0d                	j	80000edc <main+0x56>

0000000080000fac <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000fac:	1141                	addi	sp,sp,-16
    80000fae:	e422                	sd	s0,8(sp)
    80000fb0:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fb2:	00008797          	auipc	a5,0x8
    80000fb6:	06e7b783          	ld	a5,110(a5) # 80009020 <kernel_pagetable>
    80000fba:	83b1                	srli	a5,a5,0xc
    80000fbc:	577d                	li	a4,-1
    80000fbe:	177e                	slli	a4,a4,0x3f
    80000fc0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fc2:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fc6:	12000073          	sfence.vma
  sfence_vma();
}
    80000fca:	6422                	ld	s0,8(sp)
    80000fcc:	0141                	addi	sp,sp,16
    80000fce:	8082                	ret

0000000080000fd0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fd0:	7139                	addi	sp,sp,-64
    80000fd2:	fc06                	sd	ra,56(sp)
    80000fd4:	f822                	sd	s0,48(sp)
    80000fd6:	f426                	sd	s1,40(sp)
    80000fd8:	f04a                	sd	s2,32(sp)
    80000fda:	ec4e                	sd	s3,24(sp)
    80000fdc:	e852                	sd	s4,16(sp)
    80000fde:	e456                	sd	s5,8(sp)
    80000fe0:	e05a                	sd	s6,0(sp)
    80000fe2:	0080                	addi	s0,sp,64
    80000fe4:	84aa                	mv	s1,a0
    80000fe6:	89ae                	mv	s3,a1
    80000fe8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fea:	57fd                	li	a5,-1
    80000fec:	83e9                	srli	a5,a5,0x1a
    80000fee:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000ff0:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000ff2:	04b7f263          	bgeu	a5,a1,80001036 <walk+0x66>
    panic("walk");
    80000ff6:	00007517          	auipc	a0,0x7
    80000ffa:	12250513          	addi	a0,a0,290 # 80008118 <digits+0xd8>
    80000ffe:	fffff097          	auipc	ra,0xfffff
    80001002:	530080e7          	jalr	1328(ra) # 8000052e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001006:	060a8663          	beqz	s5,80001072 <walk+0xa2>
    8000100a:	00000097          	auipc	ra,0x0
    8000100e:	acc080e7          	jalr	-1332(ra) # 80000ad6 <kalloc>
    80001012:	84aa                	mv	s1,a0
    80001014:	c529                	beqz	a0,8000105e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001016:	6605                	lui	a2,0x1
    80001018:	4581                	li	a1,0
    8000101a:	00000097          	auipc	ra,0x0
    8000101e:	cbe080e7          	jalr	-834(ra) # 80000cd8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001022:	00c4d793          	srli	a5,s1,0xc
    80001026:	07aa                	slli	a5,a5,0xa
    80001028:	0017e793          	ori	a5,a5,1
    8000102c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001030:	3a5d                	addiw	s4,s4,-9
    80001032:	036a0063          	beq	s4,s6,80001052 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001036:	0149d933          	srl	s2,s3,s4
    8000103a:	1ff97913          	andi	s2,s2,511
    8000103e:	090e                	slli	s2,s2,0x3
    80001040:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001042:	00093483          	ld	s1,0(s2)
    80001046:	0014f793          	andi	a5,s1,1
    8000104a:	dfd5                	beqz	a5,80001006 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000104c:	80a9                	srli	s1,s1,0xa
    8000104e:	04b2                	slli	s1,s1,0xc
    80001050:	b7c5                	j	80001030 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001052:	00c9d513          	srli	a0,s3,0xc
    80001056:	1ff57513          	andi	a0,a0,511
    8000105a:	050e                	slli	a0,a0,0x3
    8000105c:	9526                	add	a0,a0,s1
}
    8000105e:	70e2                	ld	ra,56(sp)
    80001060:	7442                	ld	s0,48(sp)
    80001062:	74a2                	ld	s1,40(sp)
    80001064:	7902                	ld	s2,32(sp)
    80001066:	69e2                	ld	s3,24(sp)
    80001068:	6a42                	ld	s4,16(sp)
    8000106a:	6aa2                	ld	s5,8(sp)
    8000106c:	6b02                	ld	s6,0(sp)
    8000106e:	6121                	addi	sp,sp,64
    80001070:	8082                	ret
        return 0;
    80001072:	4501                	li	a0,0
    80001074:	b7ed                	j	8000105e <walk+0x8e>

0000000080001076 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001076:	57fd                	li	a5,-1
    80001078:	83e9                	srli	a5,a5,0x1a
    8000107a:	00b7f463          	bgeu	a5,a1,80001082 <walkaddr+0xc>
    return 0;
    8000107e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001080:	8082                	ret
{
    80001082:	1141                	addi	sp,sp,-16
    80001084:	e406                	sd	ra,8(sp)
    80001086:	e022                	sd	s0,0(sp)
    80001088:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000108a:	4601                	li	a2,0
    8000108c:	00000097          	auipc	ra,0x0
    80001090:	f44080e7          	jalr	-188(ra) # 80000fd0 <walk>
  if(pte == 0)
    80001094:	c105                	beqz	a0,800010b4 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001096:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001098:	0117f693          	andi	a3,a5,17
    8000109c:	4745                	li	a4,17
    return 0;
    8000109e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010a0:	00e68663          	beq	a3,a4,800010ac <walkaddr+0x36>
}
    800010a4:	60a2                	ld	ra,8(sp)
    800010a6:	6402                	ld	s0,0(sp)
    800010a8:	0141                	addi	sp,sp,16
    800010aa:	8082                	ret
  pa = PTE2PA(*pte);
    800010ac:	00a7d513          	srli	a0,a5,0xa
    800010b0:	0532                	slli	a0,a0,0xc
  return pa;
    800010b2:	bfcd                	j	800010a4 <walkaddr+0x2e>
    return 0;
    800010b4:	4501                	li	a0,0
    800010b6:	b7fd                	j	800010a4 <walkaddr+0x2e>

00000000800010b8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010b8:	715d                	addi	sp,sp,-80
    800010ba:	e486                	sd	ra,72(sp)
    800010bc:	e0a2                	sd	s0,64(sp)
    800010be:	fc26                	sd	s1,56(sp)
    800010c0:	f84a                	sd	s2,48(sp)
    800010c2:	f44e                	sd	s3,40(sp)
    800010c4:	f052                	sd	s4,32(sp)
    800010c6:	ec56                	sd	s5,24(sp)
    800010c8:	e85a                	sd	s6,16(sp)
    800010ca:	e45e                	sd	s7,8(sp)
    800010cc:	0880                	addi	s0,sp,80
    800010ce:	8aaa                	mv	s5,a0
    800010d0:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010d2:	777d                	lui	a4,0xfffff
    800010d4:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010d8:	167d                	addi	a2,a2,-1
    800010da:	00b609b3          	add	s3,a2,a1
    800010de:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010e2:	893e                	mv	s2,a5
    800010e4:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010e8:	6b85                	lui	s7,0x1
    800010ea:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010ee:	4605                	li	a2,1
    800010f0:	85ca                	mv	a1,s2
    800010f2:	8556                	mv	a0,s5
    800010f4:	00000097          	auipc	ra,0x0
    800010f8:	edc080e7          	jalr	-292(ra) # 80000fd0 <walk>
    800010fc:	c51d                	beqz	a0,8000112a <mappages+0x72>
    if(*pte & PTE_V)
    800010fe:	611c                	ld	a5,0(a0)
    80001100:	8b85                	andi	a5,a5,1
    80001102:	ef81                	bnez	a5,8000111a <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001104:	80b1                	srli	s1,s1,0xc
    80001106:	04aa                	slli	s1,s1,0xa
    80001108:	0164e4b3          	or	s1,s1,s6
    8000110c:	0014e493          	ori	s1,s1,1
    80001110:	e104                	sd	s1,0(a0)
    if(a == last)
    80001112:	03390863          	beq	s2,s3,80001142 <mappages+0x8a>
    a += PGSIZE;
    80001116:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001118:	bfc9                	j	800010ea <mappages+0x32>
      panic("remap");
    8000111a:	00007517          	auipc	a0,0x7
    8000111e:	00650513          	addi	a0,a0,6 # 80008120 <digits+0xe0>
    80001122:	fffff097          	auipc	ra,0xfffff
    80001126:	40c080e7          	jalr	1036(ra) # 8000052e <panic>
      return -1;
    8000112a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000112c:	60a6                	ld	ra,72(sp)
    8000112e:	6406                	ld	s0,64(sp)
    80001130:	74e2                	ld	s1,56(sp)
    80001132:	7942                	ld	s2,48(sp)
    80001134:	79a2                	ld	s3,40(sp)
    80001136:	7a02                	ld	s4,32(sp)
    80001138:	6ae2                	ld	s5,24(sp)
    8000113a:	6b42                	ld	s6,16(sp)
    8000113c:	6ba2                	ld	s7,8(sp)
    8000113e:	6161                	addi	sp,sp,80
    80001140:	8082                	ret
  return 0;
    80001142:	4501                	li	a0,0
    80001144:	b7e5                	j	8000112c <mappages+0x74>

0000000080001146 <kvmmap>:
{
    80001146:	1141                	addi	sp,sp,-16
    80001148:	e406                	sd	ra,8(sp)
    8000114a:	e022                	sd	s0,0(sp)
    8000114c:	0800                	addi	s0,sp,16
    8000114e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001150:	86b2                	mv	a3,a2
    80001152:	863e                	mv	a2,a5
    80001154:	00000097          	auipc	ra,0x0
    80001158:	f64080e7          	jalr	-156(ra) # 800010b8 <mappages>
    8000115c:	e509                	bnez	a0,80001166 <kvmmap+0x20>
}
    8000115e:	60a2                	ld	ra,8(sp)
    80001160:	6402                	ld	s0,0(sp)
    80001162:	0141                	addi	sp,sp,16
    80001164:	8082                	ret
    panic("kvmmap");
    80001166:	00007517          	auipc	a0,0x7
    8000116a:	fc250513          	addi	a0,a0,-62 # 80008128 <digits+0xe8>
    8000116e:	fffff097          	auipc	ra,0xfffff
    80001172:	3c0080e7          	jalr	960(ra) # 8000052e <panic>

0000000080001176 <kvmmake>:
{
    80001176:	1101                	addi	sp,sp,-32
    80001178:	ec06                	sd	ra,24(sp)
    8000117a:	e822                	sd	s0,16(sp)
    8000117c:	e426                	sd	s1,8(sp)
    8000117e:	e04a                	sd	s2,0(sp)
    80001180:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001182:	00000097          	auipc	ra,0x0
    80001186:	954080e7          	jalr	-1708(ra) # 80000ad6 <kalloc>
    8000118a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000118c:	6605                	lui	a2,0x1
    8000118e:	4581                	li	a1,0
    80001190:	00000097          	auipc	ra,0x0
    80001194:	b48080e7          	jalr	-1208(ra) # 80000cd8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001198:	4719                	li	a4,6
    8000119a:	6685                	lui	a3,0x1
    8000119c:	10000637          	lui	a2,0x10000
    800011a0:	100005b7          	lui	a1,0x10000
    800011a4:	8526                	mv	a0,s1
    800011a6:	00000097          	auipc	ra,0x0
    800011aa:	fa0080e7          	jalr	-96(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011ae:	4719                	li	a4,6
    800011b0:	6685                	lui	a3,0x1
    800011b2:	10001637          	lui	a2,0x10001
    800011b6:	100015b7          	lui	a1,0x10001
    800011ba:	8526                	mv	a0,s1
    800011bc:	00000097          	auipc	ra,0x0
    800011c0:	f8a080e7          	jalr	-118(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011c4:	4719                	li	a4,6
    800011c6:	004006b7          	lui	a3,0x400
    800011ca:	0c000637          	lui	a2,0xc000
    800011ce:	0c0005b7          	lui	a1,0xc000
    800011d2:	8526                	mv	a0,s1
    800011d4:	00000097          	auipc	ra,0x0
    800011d8:	f72080e7          	jalr	-142(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011dc:	00007917          	auipc	s2,0x7
    800011e0:	e2490913          	addi	s2,s2,-476 # 80008000 <etext>
    800011e4:	4729                	li	a4,10
    800011e6:	80007697          	auipc	a3,0x80007
    800011ea:	e1a68693          	addi	a3,a3,-486 # 8000 <_entry-0x7fff8000>
    800011ee:	4605                	li	a2,1
    800011f0:	067e                	slli	a2,a2,0x1f
    800011f2:	85b2                	mv	a1,a2
    800011f4:	8526                	mv	a0,s1
    800011f6:	00000097          	auipc	ra,0x0
    800011fa:	f50080e7          	jalr	-176(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011fe:	4719                	li	a4,6
    80001200:	46c5                	li	a3,17
    80001202:	06ee                	slli	a3,a3,0x1b
    80001204:	412686b3          	sub	a3,a3,s2
    80001208:	864a                	mv	a2,s2
    8000120a:	85ca                	mv	a1,s2
    8000120c:	8526                	mv	a0,s1
    8000120e:	00000097          	auipc	ra,0x0
    80001212:	f38080e7          	jalr	-200(ra) # 80001146 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001216:	4729                	li	a4,10
    80001218:	6685                	lui	a3,0x1
    8000121a:	00006617          	auipc	a2,0x6
    8000121e:	de660613          	addi	a2,a2,-538 # 80007000 <_trampoline>
    80001222:	040005b7          	lui	a1,0x4000
    80001226:	15fd                	addi	a1,a1,-1
    80001228:	05b2                	slli	a1,a1,0xc
    8000122a:	8526                	mv	a0,s1
    8000122c:	00000097          	auipc	ra,0x0
    80001230:	f1a080e7          	jalr	-230(ra) # 80001146 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001234:	8526                	mv	a0,s1
    80001236:	00000097          	auipc	ra,0x0
    8000123a:	620080e7          	jalr	1568(ra) # 80001856 <proc_mapstacks>
  printf("10\n");
    8000123e:	00007517          	auipc	a0,0x7
    80001242:	ef250513          	addi	a0,a0,-270 # 80008130 <digits+0xf0>
    80001246:	fffff097          	auipc	ra,0xfffff
    8000124a:	332080e7          	jalr	818(ra) # 80000578 <printf>
}
    8000124e:	8526                	mv	a0,s1
    80001250:	60e2                	ld	ra,24(sp)
    80001252:	6442                	ld	s0,16(sp)
    80001254:	64a2                	ld	s1,8(sp)
    80001256:	6902                	ld	s2,0(sp)
    80001258:	6105                	addi	sp,sp,32
    8000125a:	8082                	ret

000000008000125c <kvminit>:
{
    8000125c:	1141                	addi	sp,sp,-16
    8000125e:	e406                	sd	ra,8(sp)
    80001260:	e022                	sd	s0,0(sp)
    80001262:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001264:	00000097          	auipc	ra,0x0
    80001268:	f12080e7          	jalr	-238(ra) # 80001176 <kvmmake>
    8000126c:	00008797          	auipc	a5,0x8
    80001270:	daa7ba23          	sd	a0,-588(a5) # 80009020 <kernel_pagetable>
}
    80001274:	60a2                	ld	ra,8(sp)
    80001276:	6402                	ld	s0,0(sp)
    80001278:	0141                	addi	sp,sp,16
    8000127a:	8082                	ret

000000008000127c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000127c:	715d                	addi	sp,sp,-80
    8000127e:	e486                	sd	ra,72(sp)
    80001280:	e0a2                	sd	s0,64(sp)
    80001282:	fc26                	sd	s1,56(sp)
    80001284:	f84a                	sd	s2,48(sp)
    80001286:	f44e                	sd	s3,40(sp)
    80001288:	f052                	sd	s4,32(sp)
    8000128a:	ec56                	sd	s5,24(sp)
    8000128c:	e85a                	sd	s6,16(sp)
    8000128e:	e45e                	sd	s7,8(sp)
    80001290:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001292:	03459793          	slli	a5,a1,0x34
    80001296:	e795                	bnez	a5,800012c2 <uvmunmap+0x46>
    80001298:	8a2a                	mv	s4,a0
    8000129a:	892e                	mv	s2,a1
    8000129c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000129e:	0632                	slli	a2,a2,0xc
    800012a0:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800012a4:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012a6:	6b05                	lui	s6,0x1
    800012a8:	0735e263          	bltu	a1,s3,8000130c <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800012ac:	60a6                	ld	ra,72(sp)
    800012ae:	6406                	ld	s0,64(sp)
    800012b0:	74e2                	ld	s1,56(sp)
    800012b2:	7942                	ld	s2,48(sp)
    800012b4:	79a2                	ld	s3,40(sp)
    800012b6:	7a02                	ld	s4,32(sp)
    800012b8:	6ae2                	ld	s5,24(sp)
    800012ba:	6b42                	ld	s6,16(sp)
    800012bc:	6ba2                	ld	s7,8(sp)
    800012be:	6161                	addi	sp,sp,80
    800012c0:	8082                	ret
    panic("uvmunmap: not aligned");
    800012c2:	00007517          	auipc	a0,0x7
    800012c6:	e7650513          	addi	a0,a0,-394 # 80008138 <digits+0xf8>
    800012ca:	fffff097          	auipc	ra,0xfffff
    800012ce:	264080e7          	jalr	612(ra) # 8000052e <panic>
      panic("uvmunmap: walk");
    800012d2:	00007517          	auipc	a0,0x7
    800012d6:	e7e50513          	addi	a0,a0,-386 # 80008150 <digits+0x110>
    800012da:	fffff097          	auipc	ra,0xfffff
    800012de:	254080e7          	jalr	596(ra) # 8000052e <panic>
      panic("uvmunmap: not mapped");
    800012e2:	00007517          	auipc	a0,0x7
    800012e6:	e7e50513          	addi	a0,a0,-386 # 80008160 <digits+0x120>
    800012ea:	fffff097          	auipc	ra,0xfffff
    800012ee:	244080e7          	jalr	580(ra) # 8000052e <panic>
      panic("uvmunmap: not a leaf");
    800012f2:	00007517          	auipc	a0,0x7
    800012f6:	e8650513          	addi	a0,a0,-378 # 80008178 <digits+0x138>
    800012fa:	fffff097          	auipc	ra,0xfffff
    800012fe:	234080e7          	jalr	564(ra) # 8000052e <panic>
    *pte = 0;
    80001302:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001306:	995a                	add	s2,s2,s6
    80001308:	fb3972e3          	bgeu	s2,s3,800012ac <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000130c:	4601                	li	a2,0
    8000130e:	85ca                	mv	a1,s2
    80001310:	8552                	mv	a0,s4
    80001312:	00000097          	auipc	ra,0x0
    80001316:	cbe080e7          	jalr	-834(ra) # 80000fd0 <walk>
    8000131a:	84aa                	mv	s1,a0
    8000131c:	d95d                	beqz	a0,800012d2 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    8000131e:	6108                	ld	a0,0(a0)
    80001320:	00157793          	andi	a5,a0,1
    80001324:	dfdd                	beqz	a5,800012e2 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001326:	3ff57793          	andi	a5,a0,1023
    8000132a:	fd7784e3          	beq	a5,s7,800012f2 <uvmunmap+0x76>
    if(do_free){
    8000132e:	fc0a8ae3          	beqz	s5,80001302 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001332:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001334:	0532                	slli	a0,a0,0xc
    80001336:	fffff097          	auipc	ra,0xfffff
    8000133a:	6a4080e7          	jalr	1700(ra) # 800009da <kfree>
    8000133e:	b7d1                	j	80001302 <uvmunmap+0x86>

0000000080001340 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001340:	1101                	addi	sp,sp,-32
    80001342:	ec06                	sd	ra,24(sp)
    80001344:	e822                	sd	s0,16(sp)
    80001346:	e426                	sd	s1,8(sp)
    80001348:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000134a:	fffff097          	auipc	ra,0xfffff
    8000134e:	78c080e7          	jalr	1932(ra) # 80000ad6 <kalloc>
    80001352:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001354:	c519                	beqz	a0,80001362 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001356:	6605                	lui	a2,0x1
    80001358:	4581                	li	a1,0
    8000135a:	00000097          	auipc	ra,0x0
    8000135e:	97e080e7          	jalr	-1666(ra) # 80000cd8 <memset>
  return pagetable;
}
    80001362:	8526                	mv	a0,s1
    80001364:	60e2                	ld	ra,24(sp)
    80001366:	6442                	ld	s0,16(sp)
    80001368:	64a2                	ld	s1,8(sp)
    8000136a:	6105                	addi	sp,sp,32
    8000136c:	8082                	ret

000000008000136e <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000136e:	7179                	addi	sp,sp,-48
    80001370:	f406                	sd	ra,40(sp)
    80001372:	f022                	sd	s0,32(sp)
    80001374:	ec26                	sd	s1,24(sp)
    80001376:	e84a                	sd	s2,16(sp)
    80001378:	e44e                	sd	s3,8(sp)
    8000137a:	e052                	sd	s4,0(sp)
    8000137c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000137e:	6785                	lui	a5,0x1
    80001380:	06f67063          	bgeu	a2,a5,800013e0 <uvminit+0x72>
    80001384:	8a2a                	mv	s4,a0
    80001386:	89ae                	mv	s3,a1
    80001388:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000138a:	fffff097          	auipc	ra,0xfffff
    8000138e:	74c080e7          	jalr	1868(ra) # 80000ad6 <kalloc>
    80001392:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001394:	6605                	lui	a2,0x1
    80001396:	4581                	li	a1,0
    80001398:	00000097          	auipc	ra,0x0
    8000139c:	940080e7          	jalr	-1728(ra) # 80000cd8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800013a0:	4779                	li	a4,30
    800013a2:	86ca                	mv	a3,s2
    800013a4:	6605                	lui	a2,0x1
    800013a6:	4581                	li	a1,0
    800013a8:	8552                	mv	a0,s4
    800013aa:	00000097          	auipc	ra,0x0
    800013ae:	d0e080e7          	jalr	-754(ra) # 800010b8 <mappages>
  printf("after mappages in uvminit\n");
    800013b2:	00007517          	auipc	a0,0x7
    800013b6:	dfe50513          	addi	a0,a0,-514 # 800081b0 <digits+0x170>
    800013ba:	fffff097          	auipc	ra,0xfffff
    800013be:	1be080e7          	jalr	446(ra) # 80000578 <printf>
  memmove(mem, src, sz);
    800013c2:	8626                	mv	a2,s1
    800013c4:	85ce                	mv	a1,s3
    800013c6:	854a                	mv	a0,s2
    800013c8:	00000097          	auipc	ra,0x0
    800013cc:	96c080e7          	jalr	-1684(ra) # 80000d34 <memmove>
}
    800013d0:	70a2                	ld	ra,40(sp)
    800013d2:	7402                	ld	s0,32(sp)
    800013d4:	64e2                	ld	s1,24(sp)
    800013d6:	6942                	ld	s2,16(sp)
    800013d8:	69a2                	ld	s3,8(sp)
    800013da:	6a02                	ld	s4,0(sp)
    800013dc:	6145                	addi	sp,sp,48
    800013de:	8082                	ret
    panic("inituvm: more than a page");
    800013e0:	00007517          	auipc	a0,0x7
    800013e4:	db050513          	addi	a0,a0,-592 # 80008190 <digits+0x150>
    800013e8:	fffff097          	auipc	ra,0xfffff
    800013ec:	146080e7          	jalr	326(ra) # 8000052e <panic>

00000000800013f0 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013f0:	1101                	addi	sp,sp,-32
    800013f2:	ec06                	sd	ra,24(sp)
    800013f4:	e822                	sd	s0,16(sp)
    800013f6:	e426                	sd	s1,8(sp)
    800013f8:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013fa:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013fc:	00b67d63          	bgeu	a2,a1,80001416 <uvmdealloc+0x26>
    80001400:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001402:	6785                	lui	a5,0x1
    80001404:	17fd                	addi	a5,a5,-1
    80001406:	00f60733          	add	a4,a2,a5
    8000140a:	767d                	lui	a2,0xfffff
    8000140c:	8f71                	and	a4,a4,a2
    8000140e:	97ae                	add	a5,a5,a1
    80001410:	8ff1                	and	a5,a5,a2
    80001412:	00f76863          	bltu	a4,a5,80001422 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001416:	8526                	mv	a0,s1
    80001418:	60e2                	ld	ra,24(sp)
    8000141a:	6442                	ld	s0,16(sp)
    8000141c:	64a2                	ld	s1,8(sp)
    8000141e:	6105                	addi	sp,sp,32
    80001420:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001422:	8f99                	sub	a5,a5,a4
    80001424:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001426:	4685                	li	a3,1
    80001428:	0007861b          	sext.w	a2,a5
    8000142c:	85ba                	mv	a1,a4
    8000142e:	00000097          	auipc	ra,0x0
    80001432:	e4e080e7          	jalr	-434(ra) # 8000127c <uvmunmap>
    80001436:	b7c5                	j	80001416 <uvmdealloc+0x26>

0000000080001438 <uvmalloc>:
  if(newsz < oldsz)
    80001438:	0ab66163          	bltu	a2,a1,800014da <uvmalloc+0xa2>
{
    8000143c:	7139                	addi	sp,sp,-64
    8000143e:	fc06                	sd	ra,56(sp)
    80001440:	f822                	sd	s0,48(sp)
    80001442:	f426                	sd	s1,40(sp)
    80001444:	f04a                	sd	s2,32(sp)
    80001446:	ec4e                	sd	s3,24(sp)
    80001448:	e852                	sd	s4,16(sp)
    8000144a:	e456                	sd	s5,8(sp)
    8000144c:	0080                	addi	s0,sp,64
    8000144e:	8aaa                	mv	s5,a0
    80001450:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001452:	6985                	lui	s3,0x1
    80001454:	19fd                	addi	s3,s3,-1
    80001456:	95ce                	add	a1,a1,s3
    80001458:	79fd                	lui	s3,0xfffff
    8000145a:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000145e:	08c9f063          	bgeu	s3,a2,800014de <uvmalloc+0xa6>
    80001462:	894e                	mv	s2,s3
    mem = kalloc();
    80001464:	fffff097          	auipc	ra,0xfffff
    80001468:	672080e7          	jalr	1650(ra) # 80000ad6 <kalloc>
    8000146c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000146e:	c51d                	beqz	a0,8000149c <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001470:	6605                	lui	a2,0x1
    80001472:	4581                	li	a1,0
    80001474:	00000097          	auipc	ra,0x0
    80001478:	864080e7          	jalr	-1948(ra) # 80000cd8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000147c:	4779                	li	a4,30
    8000147e:	86a6                	mv	a3,s1
    80001480:	6605                	lui	a2,0x1
    80001482:	85ca                	mv	a1,s2
    80001484:	8556                	mv	a0,s5
    80001486:	00000097          	auipc	ra,0x0
    8000148a:	c32080e7          	jalr	-974(ra) # 800010b8 <mappages>
    8000148e:	e905                	bnez	a0,800014be <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001490:	6785                	lui	a5,0x1
    80001492:	993e                	add	s2,s2,a5
    80001494:	fd4968e3          	bltu	s2,s4,80001464 <uvmalloc+0x2c>
  return newsz;
    80001498:	8552                	mv	a0,s4
    8000149a:	a809                	j	800014ac <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000149c:	864e                	mv	a2,s3
    8000149e:	85ca                	mv	a1,s2
    800014a0:	8556                	mv	a0,s5
    800014a2:	00000097          	auipc	ra,0x0
    800014a6:	f4e080e7          	jalr	-178(ra) # 800013f0 <uvmdealloc>
      return 0;
    800014aa:	4501                	li	a0,0
}
    800014ac:	70e2                	ld	ra,56(sp)
    800014ae:	7442                	ld	s0,48(sp)
    800014b0:	74a2                	ld	s1,40(sp)
    800014b2:	7902                	ld	s2,32(sp)
    800014b4:	69e2                	ld	s3,24(sp)
    800014b6:	6a42                	ld	s4,16(sp)
    800014b8:	6aa2                	ld	s5,8(sp)
    800014ba:	6121                	addi	sp,sp,64
    800014bc:	8082                	ret
      kfree(mem);
    800014be:	8526                	mv	a0,s1
    800014c0:	fffff097          	auipc	ra,0xfffff
    800014c4:	51a080e7          	jalr	1306(ra) # 800009da <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014c8:	864e                	mv	a2,s3
    800014ca:	85ca                	mv	a1,s2
    800014cc:	8556                	mv	a0,s5
    800014ce:	00000097          	auipc	ra,0x0
    800014d2:	f22080e7          	jalr	-222(ra) # 800013f0 <uvmdealloc>
      return 0;
    800014d6:	4501                	li	a0,0
    800014d8:	bfd1                	j	800014ac <uvmalloc+0x74>
    return oldsz;
    800014da:	852e                	mv	a0,a1
}
    800014dc:	8082                	ret
  return newsz;
    800014de:	8532                	mv	a0,a2
    800014e0:	b7f1                	j	800014ac <uvmalloc+0x74>

00000000800014e2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014e2:	7179                	addi	sp,sp,-48
    800014e4:	f406                	sd	ra,40(sp)
    800014e6:	f022                	sd	s0,32(sp)
    800014e8:	ec26                	sd	s1,24(sp)
    800014ea:	e84a                	sd	s2,16(sp)
    800014ec:	e44e                	sd	s3,8(sp)
    800014ee:	e052                	sd	s4,0(sp)
    800014f0:	1800                	addi	s0,sp,48
    800014f2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014f4:	84aa                	mv	s1,a0
    800014f6:	6905                	lui	s2,0x1
    800014f8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014fa:	4985                	li	s3,1
    800014fc:	a821                	j	80001514 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014fe:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001500:	0532                	slli	a0,a0,0xc
    80001502:	00000097          	auipc	ra,0x0
    80001506:	fe0080e7          	jalr	-32(ra) # 800014e2 <freewalk>
      pagetable[i] = 0;
    8000150a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000150e:	04a1                	addi	s1,s1,8
    80001510:	03248163          	beq	s1,s2,80001532 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80001514:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001516:	00f57793          	andi	a5,a0,15
    8000151a:	ff3782e3          	beq	a5,s3,800014fe <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000151e:	8905                	andi	a0,a0,1
    80001520:	d57d                	beqz	a0,8000150e <freewalk+0x2c>
      panic("freewalk: leaf");
    80001522:	00007517          	auipc	a0,0x7
    80001526:	cae50513          	addi	a0,a0,-850 # 800081d0 <digits+0x190>
    8000152a:	fffff097          	auipc	ra,0xfffff
    8000152e:	004080e7          	jalr	4(ra) # 8000052e <panic>
    }
  }
  kfree((void*)pagetable);
    80001532:	8552                	mv	a0,s4
    80001534:	fffff097          	auipc	ra,0xfffff
    80001538:	4a6080e7          	jalr	1190(ra) # 800009da <kfree>
}
    8000153c:	70a2                	ld	ra,40(sp)
    8000153e:	7402                	ld	s0,32(sp)
    80001540:	64e2                	ld	s1,24(sp)
    80001542:	6942                	ld	s2,16(sp)
    80001544:	69a2                	ld	s3,8(sp)
    80001546:	6a02                	ld	s4,0(sp)
    80001548:	6145                	addi	sp,sp,48
    8000154a:	8082                	ret

000000008000154c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000154c:	1101                	addi	sp,sp,-32
    8000154e:	ec06                	sd	ra,24(sp)
    80001550:	e822                	sd	s0,16(sp)
    80001552:	e426                	sd	s1,8(sp)
    80001554:	1000                	addi	s0,sp,32
    80001556:	84aa                	mv	s1,a0
  if(sz > 0)
    80001558:	e999                	bnez	a1,8000156e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000155a:	8526                	mv	a0,s1
    8000155c:	00000097          	auipc	ra,0x0
    80001560:	f86080e7          	jalr	-122(ra) # 800014e2 <freewalk>
}
    80001564:	60e2                	ld	ra,24(sp)
    80001566:	6442                	ld	s0,16(sp)
    80001568:	64a2                	ld	s1,8(sp)
    8000156a:	6105                	addi	sp,sp,32
    8000156c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000156e:	6605                	lui	a2,0x1
    80001570:	167d                	addi	a2,a2,-1
    80001572:	962e                	add	a2,a2,a1
    80001574:	4685                	li	a3,1
    80001576:	8231                	srli	a2,a2,0xc
    80001578:	4581                	li	a1,0
    8000157a:	00000097          	auipc	ra,0x0
    8000157e:	d02080e7          	jalr	-766(ra) # 8000127c <uvmunmap>
    80001582:	bfe1                	j	8000155a <uvmfree+0xe>

0000000080001584 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001584:	c679                	beqz	a2,80001652 <uvmcopy+0xce>
{
    80001586:	715d                	addi	sp,sp,-80
    80001588:	e486                	sd	ra,72(sp)
    8000158a:	e0a2                	sd	s0,64(sp)
    8000158c:	fc26                	sd	s1,56(sp)
    8000158e:	f84a                	sd	s2,48(sp)
    80001590:	f44e                	sd	s3,40(sp)
    80001592:	f052                	sd	s4,32(sp)
    80001594:	ec56                	sd	s5,24(sp)
    80001596:	e85a                	sd	s6,16(sp)
    80001598:	e45e                	sd	s7,8(sp)
    8000159a:	0880                	addi	s0,sp,80
    8000159c:	8b2a                	mv	s6,a0
    8000159e:	8aae                	mv	s5,a1
    800015a0:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015a2:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    800015a4:	4601                	li	a2,0
    800015a6:	85ce                	mv	a1,s3
    800015a8:	855a                	mv	a0,s6
    800015aa:	00000097          	auipc	ra,0x0
    800015ae:	a26080e7          	jalr	-1498(ra) # 80000fd0 <walk>
    800015b2:	c531                	beqz	a0,800015fe <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015b4:	6118                	ld	a4,0(a0)
    800015b6:	00177793          	andi	a5,a4,1
    800015ba:	cbb1                	beqz	a5,8000160e <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015bc:	00a75593          	srli	a1,a4,0xa
    800015c0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015c4:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015c8:	fffff097          	auipc	ra,0xfffff
    800015cc:	50e080e7          	jalr	1294(ra) # 80000ad6 <kalloc>
    800015d0:	892a                	mv	s2,a0
    800015d2:	c939                	beqz	a0,80001628 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015d4:	6605                	lui	a2,0x1
    800015d6:	85de                	mv	a1,s7
    800015d8:	fffff097          	auipc	ra,0xfffff
    800015dc:	75c080e7          	jalr	1884(ra) # 80000d34 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015e0:	8726                	mv	a4,s1
    800015e2:	86ca                	mv	a3,s2
    800015e4:	6605                	lui	a2,0x1
    800015e6:	85ce                	mv	a1,s3
    800015e8:	8556                	mv	a0,s5
    800015ea:	00000097          	auipc	ra,0x0
    800015ee:	ace080e7          	jalr	-1330(ra) # 800010b8 <mappages>
    800015f2:	e515                	bnez	a0,8000161e <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015f4:	6785                	lui	a5,0x1
    800015f6:	99be                	add	s3,s3,a5
    800015f8:	fb49e6e3          	bltu	s3,s4,800015a4 <uvmcopy+0x20>
    800015fc:	a081                	j	8000163c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015fe:	00007517          	auipc	a0,0x7
    80001602:	be250513          	addi	a0,a0,-1054 # 800081e0 <digits+0x1a0>
    80001606:	fffff097          	auipc	ra,0xfffff
    8000160a:	f28080e7          	jalr	-216(ra) # 8000052e <panic>
      panic("uvmcopy: page not present");
    8000160e:	00007517          	auipc	a0,0x7
    80001612:	bf250513          	addi	a0,a0,-1038 # 80008200 <digits+0x1c0>
    80001616:	fffff097          	auipc	ra,0xfffff
    8000161a:	f18080e7          	jalr	-232(ra) # 8000052e <panic>
      kfree(mem);
    8000161e:	854a                	mv	a0,s2
    80001620:	fffff097          	auipc	ra,0xfffff
    80001624:	3ba080e7          	jalr	954(ra) # 800009da <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001628:	4685                	li	a3,1
    8000162a:	00c9d613          	srli	a2,s3,0xc
    8000162e:	4581                	li	a1,0
    80001630:	8556                	mv	a0,s5
    80001632:	00000097          	auipc	ra,0x0
    80001636:	c4a080e7          	jalr	-950(ra) # 8000127c <uvmunmap>
  return -1;
    8000163a:	557d                	li	a0,-1
}
    8000163c:	60a6                	ld	ra,72(sp)
    8000163e:	6406                	ld	s0,64(sp)
    80001640:	74e2                	ld	s1,56(sp)
    80001642:	7942                	ld	s2,48(sp)
    80001644:	79a2                	ld	s3,40(sp)
    80001646:	7a02                	ld	s4,32(sp)
    80001648:	6ae2                	ld	s5,24(sp)
    8000164a:	6b42                	ld	s6,16(sp)
    8000164c:	6ba2                	ld	s7,8(sp)
    8000164e:	6161                	addi	sp,sp,80
    80001650:	8082                	ret
  return 0;
    80001652:	4501                	li	a0,0
}
    80001654:	8082                	ret

0000000080001656 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001656:	1141                	addi	sp,sp,-16
    80001658:	e406                	sd	ra,8(sp)
    8000165a:	e022                	sd	s0,0(sp)
    8000165c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000165e:	4601                	li	a2,0
    80001660:	00000097          	auipc	ra,0x0
    80001664:	970080e7          	jalr	-1680(ra) # 80000fd0 <walk>
  if(pte == 0)
    80001668:	c901                	beqz	a0,80001678 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000166a:	611c                	ld	a5,0(a0)
    8000166c:	9bbd                	andi	a5,a5,-17
    8000166e:	e11c                	sd	a5,0(a0)
}
    80001670:	60a2                	ld	ra,8(sp)
    80001672:	6402                	ld	s0,0(sp)
    80001674:	0141                	addi	sp,sp,16
    80001676:	8082                	ret
    panic("uvmclear");
    80001678:	00007517          	auipc	a0,0x7
    8000167c:	ba850513          	addi	a0,a0,-1112 # 80008220 <digits+0x1e0>
    80001680:	fffff097          	auipc	ra,0xfffff
    80001684:	eae080e7          	jalr	-338(ra) # 8000052e <panic>

0000000080001688 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001688:	c6bd                	beqz	a3,800016f6 <copyout+0x6e>
{
    8000168a:	715d                	addi	sp,sp,-80
    8000168c:	e486                	sd	ra,72(sp)
    8000168e:	e0a2                	sd	s0,64(sp)
    80001690:	fc26                	sd	s1,56(sp)
    80001692:	f84a                	sd	s2,48(sp)
    80001694:	f44e                	sd	s3,40(sp)
    80001696:	f052                	sd	s4,32(sp)
    80001698:	ec56                	sd	s5,24(sp)
    8000169a:	e85a                	sd	s6,16(sp)
    8000169c:	e45e                	sd	s7,8(sp)
    8000169e:	e062                	sd	s8,0(sp)
    800016a0:	0880                	addi	s0,sp,80
    800016a2:	8b2a                	mv	s6,a0
    800016a4:	8c2e                	mv	s8,a1
    800016a6:	8a32                	mv	s4,a2
    800016a8:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016aa:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    800016ac:	6a85                	lui	s5,0x1
    800016ae:	a015                	j	800016d2 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016b0:	9562                	add	a0,a0,s8
    800016b2:	0004861b          	sext.w	a2,s1
    800016b6:	85d2                	mv	a1,s4
    800016b8:	41250533          	sub	a0,a0,s2
    800016bc:	fffff097          	auipc	ra,0xfffff
    800016c0:	678080e7          	jalr	1656(ra) # 80000d34 <memmove>

    len -= n;
    800016c4:	409989b3          	sub	s3,s3,s1
    src += n;
    800016c8:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ca:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ce:	02098263          	beqz	s3,800016f2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016d2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016d6:	85ca                	mv	a1,s2
    800016d8:	855a                	mv	a0,s6
    800016da:	00000097          	auipc	ra,0x0
    800016de:	99c080e7          	jalr	-1636(ra) # 80001076 <walkaddr>
    if(pa0 == 0)
    800016e2:	cd01                	beqz	a0,800016fa <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016e4:	418904b3          	sub	s1,s2,s8
    800016e8:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ea:	fc99f3e3          	bgeu	s3,s1,800016b0 <copyout+0x28>
    800016ee:	84ce                	mv	s1,s3
    800016f0:	b7c1                	j	800016b0 <copyout+0x28>
  }
  return 0;
    800016f2:	4501                	li	a0,0
    800016f4:	a021                	j	800016fc <copyout+0x74>
    800016f6:	4501                	li	a0,0
}
    800016f8:	8082                	ret
      return -1;
    800016fa:	557d                	li	a0,-1
}
    800016fc:	60a6                	ld	ra,72(sp)
    800016fe:	6406                	ld	s0,64(sp)
    80001700:	74e2                	ld	s1,56(sp)
    80001702:	7942                	ld	s2,48(sp)
    80001704:	79a2                	ld	s3,40(sp)
    80001706:	7a02                	ld	s4,32(sp)
    80001708:	6ae2                	ld	s5,24(sp)
    8000170a:	6b42                	ld	s6,16(sp)
    8000170c:	6ba2                	ld	s7,8(sp)
    8000170e:	6c02                	ld	s8,0(sp)
    80001710:	6161                	addi	sp,sp,80
    80001712:	8082                	ret

0000000080001714 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001714:	caa5                	beqz	a3,80001784 <copyin+0x70>
{
    80001716:	715d                	addi	sp,sp,-80
    80001718:	e486                	sd	ra,72(sp)
    8000171a:	e0a2                	sd	s0,64(sp)
    8000171c:	fc26                	sd	s1,56(sp)
    8000171e:	f84a                	sd	s2,48(sp)
    80001720:	f44e                	sd	s3,40(sp)
    80001722:	f052                	sd	s4,32(sp)
    80001724:	ec56                	sd	s5,24(sp)
    80001726:	e85a                	sd	s6,16(sp)
    80001728:	e45e                	sd	s7,8(sp)
    8000172a:	e062                	sd	s8,0(sp)
    8000172c:	0880                	addi	s0,sp,80
    8000172e:	8b2a                	mv	s6,a0
    80001730:	8a2e                	mv	s4,a1
    80001732:	8c32                	mv	s8,a2
    80001734:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001736:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001738:	6a85                	lui	s5,0x1
    8000173a:	a01d                	j	80001760 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000173c:	018505b3          	add	a1,a0,s8
    80001740:	0004861b          	sext.w	a2,s1
    80001744:	412585b3          	sub	a1,a1,s2
    80001748:	8552                	mv	a0,s4
    8000174a:	fffff097          	auipc	ra,0xfffff
    8000174e:	5ea080e7          	jalr	1514(ra) # 80000d34 <memmove>

    len -= n;
    80001752:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001756:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001758:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000175c:	02098263          	beqz	s3,80001780 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001760:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001764:	85ca                	mv	a1,s2
    80001766:	855a                	mv	a0,s6
    80001768:	00000097          	auipc	ra,0x0
    8000176c:	90e080e7          	jalr	-1778(ra) # 80001076 <walkaddr>
    if(pa0 == 0)
    80001770:	cd01                	beqz	a0,80001788 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001772:	418904b3          	sub	s1,s2,s8
    80001776:	94d6                	add	s1,s1,s5
    if(n > len)
    80001778:	fc99f2e3          	bgeu	s3,s1,8000173c <copyin+0x28>
    8000177c:	84ce                	mv	s1,s3
    8000177e:	bf7d                	j	8000173c <copyin+0x28>
  }
  return 0;
    80001780:	4501                	li	a0,0
    80001782:	a021                	j	8000178a <copyin+0x76>
    80001784:	4501                	li	a0,0
}
    80001786:	8082                	ret
      return -1;
    80001788:	557d                	li	a0,-1
}
    8000178a:	60a6                	ld	ra,72(sp)
    8000178c:	6406                	ld	s0,64(sp)
    8000178e:	74e2                	ld	s1,56(sp)
    80001790:	7942                	ld	s2,48(sp)
    80001792:	79a2                	ld	s3,40(sp)
    80001794:	7a02                	ld	s4,32(sp)
    80001796:	6ae2                	ld	s5,24(sp)
    80001798:	6b42                	ld	s6,16(sp)
    8000179a:	6ba2                	ld	s7,8(sp)
    8000179c:	6c02                	ld	s8,0(sp)
    8000179e:	6161                	addi	sp,sp,80
    800017a0:	8082                	ret

00000000800017a2 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017a2:	c6c5                	beqz	a3,8000184a <copyinstr+0xa8>
{
    800017a4:	715d                	addi	sp,sp,-80
    800017a6:	e486                	sd	ra,72(sp)
    800017a8:	e0a2                	sd	s0,64(sp)
    800017aa:	fc26                	sd	s1,56(sp)
    800017ac:	f84a                	sd	s2,48(sp)
    800017ae:	f44e                	sd	s3,40(sp)
    800017b0:	f052                	sd	s4,32(sp)
    800017b2:	ec56                	sd	s5,24(sp)
    800017b4:	e85a                	sd	s6,16(sp)
    800017b6:	e45e                	sd	s7,8(sp)
    800017b8:	0880                	addi	s0,sp,80
    800017ba:	8a2a                	mv	s4,a0
    800017bc:	8b2e                	mv	s6,a1
    800017be:	8bb2                	mv	s7,a2
    800017c0:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017c2:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017c4:	6985                	lui	s3,0x1
    800017c6:	a035                	j	800017f2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017c8:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017cc:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ce:	0017b793          	seqz	a5,a5
    800017d2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017d6:	60a6                	ld	ra,72(sp)
    800017d8:	6406                	ld	s0,64(sp)
    800017da:	74e2                	ld	s1,56(sp)
    800017dc:	7942                	ld	s2,48(sp)
    800017de:	79a2                	ld	s3,40(sp)
    800017e0:	7a02                	ld	s4,32(sp)
    800017e2:	6ae2                	ld	s5,24(sp)
    800017e4:	6b42                	ld	s6,16(sp)
    800017e6:	6ba2                	ld	s7,8(sp)
    800017e8:	6161                	addi	sp,sp,80
    800017ea:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ec:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017f0:	c8a9                	beqz	s1,80001842 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017f2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017f6:	85ca                	mv	a1,s2
    800017f8:	8552                	mv	a0,s4
    800017fa:	00000097          	auipc	ra,0x0
    800017fe:	87c080e7          	jalr	-1924(ra) # 80001076 <walkaddr>
    if(pa0 == 0)
    80001802:	c131                	beqz	a0,80001846 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001804:	41790833          	sub	a6,s2,s7
    80001808:	984e                	add	a6,a6,s3
    if(n > max)
    8000180a:	0104f363          	bgeu	s1,a6,80001810 <copyinstr+0x6e>
    8000180e:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001810:	955e                	add	a0,a0,s7
    80001812:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001816:	fc080be3          	beqz	a6,800017ec <copyinstr+0x4a>
    8000181a:	985a                	add	a6,a6,s6
    8000181c:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000181e:	41650633          	sub	a2,a0,s6
    80001822:	14fd                	addi	s1,s1,-1
    80001824:	9b26                	add	s6,s6,s1
    80001826:	00f60733          	add	a4,a2,a5
    8000182a:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffbe000>
    8000182e:	df49                	beqz	a4,800017c8 <copyinstr+0x26>
        *dst = *p;
    80001830:	00e78023          	sb	a4,0(a5)
      --max;
    80001834:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001838:	0785                	addi	a5,a5,1
    while(n > 0){
    8000183a:	ff0796e3          	bne	a5,a6,80001826 <copyinstr+0x84>
      dst++;
    8000183e:	8b42                	mv	s6,a6
    80001840:	b775                	j	800017ec <copyinstr+0x4a>
    80001842:	4781                	li	a5,0
    80001844:	b769                	j	800017ce <copyinstr+0x2c>
      return -1;
    80001846:	557d                	li	a0,-1
    80001848:	b779                	j	800017d6 <copyinstr+0x34>
  int got_null = 0;
    8000184a:	4781                	li	a5,0
  if(got_null){
    8000184c:	0017b793          	seqz	a5,a5
    80001850:	40f00533          	neg	a0,a5
}
    80001854:	8082                	ret

0000000080001856 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001856:	711d                	addi	sp,sp,-96
    80001858:	ec86                	sd	ra,88(sp)
    8000185a:	e8a2                	sd	s0,80(sp)
    8000185c:	e4a6                	sd	s1,72(sp)
    8000185e:	e0ca                	sd	s2,64(sp)
    80001860:	fc4e                	sd	s3,56(sp)
    80001862:	f852                	sd	s4,48(sp)
    80001864:	f456                	sd	s5,40(sp)
    80001866:	f05a                	sd	s6,32(sp)
    80001868:	ec5e                	sd	s7,24(sp)
    8000186a:	e862                	sd	s8,16(sp)
    8000186c:	e466                	sd	s9,8(sp)
    8000186e:	e06a                	sd	s10,0(sp)
    80001870:	1080                	addi	s0,sp,96
    80001872:	8b2a                	mv	s6,a0
  struct proc *p;
  struct kthread *t;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001874:	00010997          	auipc	s3,0x10
    80001878:	6fc98993          	addi	s3,s3,1788 # 80011f70 <proc+0x848>
    8000187c:	00032d17          	auipc	s10,0x32
    80001880:	8f4d0d13          	addi	s10,s10,-1804 # 80033170 <bcache+0x830>
    int proc_index= (int)(p-proc);
    80001884:	7c7d                	lui	s8,0xfffff
    80001886:	7b8c0c13          	addi	s8,s8,1976 # fffffffffffff7b8 <end+0xffffffff7ffbe7b8>
    8000188a:	00006c97          	auipc	s9,0x6
    8000188e:	776cbc83          	ld	s9,1910(s9) # 80008000 <etext>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
      char *pa = kalloc();
      if(pa == 0)
        panic("kalloc");
      int thread_index = (int)(t-p->kthreads);
    80001892:	00006b97          	auipc	s7,0x6
    80001896:	776b8b93          	addi	s7,s7,1910 # 80008008 <etext+0x8>
      uint64 va = KSTACK( proc_index * NTHREAD + thread_index);
    8000189a:	04000ab7          	lui	s5,0x4000
    8000189e:	1afd                	addi	s5,s5,-1
    800018a0:	0ab2                	slli	s5,s5,0xc
    800018a2:	a839                	j	800018c0 <proc_mapstacks+0x6a>
        panic("kalloc");
    800018a4:	00007517          	auipc	a0,0x7
    800018a8:	98c50513          	addi	a0,a0,-1652 # 80008230 <digits+0x1f0>
    800018ac:	fffff097          	auipc	ra,0xfffff
    800018b0:	c82080e7          	jalr	-894(ra) # 8000052e <panic>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018b4:	6785                	lui	a5,0x1
    800018b6:	84878793          	addi	a5,a5,-1976 # 848 <_entry-0x7ffff7b8>
    800018ba:	99be                	add	s3,s3,a5
    800018bc:	07a98363          	beq	s3,s10,80001922 <proc_mapstacks+0xcc>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    800018c0:	a4098a13          	addi	s4,s3,-1472
    int proc_index= (int)(p-proc);
    800018c4:	01898933          	add	s2,s3,s8
    800018c8:	00010797          	auipc	a5,0x10
    800018cc:	e6078793          	addi	a5,a5,-416 # 80011728 <proc>
    800018d0:	40f90933          	sub	s2,s2,a5
    800018d4:	40395913          	srai	s2,s2,0x3
    800018d8:	03990933          	mul	s2,s2,s9
    800018dc:	0039191b          	slliw	s2,s2,0x3
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    800018e0:	84d2                	mv	s1,s4
      char *pa = kalloc();
    800018e2:	fffff097          	auipc	ra,0xfffff
    800018e6:	1f4080e7          	jalr	500(ra) # 80000ad6 <kalloc>
    800018ea:	862a                	mv	a2,a0
      if(pa == 0)
    800018ec:	dd45                	beqz	a0,800018a4 <proc_mapstacks+0x4e>
      int thread_index = (int)(t-p->kthreads);
    800018ee:	414485b3          	sub	a1,s1,s4
    800018f2:	858d                	srai	a1,a1,0x3
    800018f4:	000bb783          	ld	a5,0(s7)
    800018f8:	02f585b3          	mul	a1,a1,a5
      uint64 va = KSTACK( proc_index * NTHREAD + thread_index);
    800018fc:	012585bb          	addw	a1,a1,s2
    80001900:	2585                	addiw	a1,a1,1
    80001902:	00d5959b          	slliw	a1,a1,0xd
      kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001906:	4719                	li	a4,6
    80001908:	6685                	lui	a3,0x1
    8000190a:	40ba85b3          	sub	a1,s5,a1
    8000190e:	855a                	mv	a0,s6
    80001910:	00000097          	auipc	ra,0x0
    80001914:	836080e7          	jalr	-1994(ra) # 80001146 <kvmmap>
    for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001918:	0b848493          	addi	s1,s1,184
    8000191c:	fd3493e3          	bne	s1,s3,800018e2 <proc_mapstacks+0x8c>
    80001920:	bf51                	j	800018b4 <proc_mapstacks+0x5e>
    }
  }
}
    80001922:	60e6                	ld	ra,88(sp)
    80001924:	6446                	ld	s0,80(sp)
    80001926:	64a6                	ld	s1,72(sp)
    80001928:	6906                	ld	s2,64(sp)
    8000192a:	79e2                	ld	s3,56(sp)
    8000192c:	7a42                	ld	s4,48(sp)
    8000192e:	7aa2                	ld	s5,40(sp)
    80001930:	7b02                	ld	s6,32(sp)
    80001932:	6be2                	ld	s7,24(sp)
    80001934:	6c42                	ld	s8,16(sp)
    80001936:	6ca2                	ld	s9,8(sp)
    80001938:	6d02                	ld	s10,0(sp)
    8000193a:	6125                	addi	sp,sp,96
    8000193c:	8082                	ret

000000008000193e <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    8000193e:	7159                	addi	sp,sp,-112
    80001940:	f486                	sd	ra,104(sp)
    80001942:	f0a2                	sd	s0,96(sp)
    80001944:	eca6                	sd	s1,88(sp)
    80001946:	e8ca                	sd	s2,80(sp)
    80001948:	e4ce                	sd	s3,72(sp)
    8000194a:	e0d2                	sd	s4,64(sp)
    8000194c:	fc56                	sd	s5,56(sp)
    8000194e:	f85a                	sd	s6,48(sp)
    80001950:	f45e                	sd	s7,40(sp)
    80001952:	f062                	sd	s8,32(sp)
    80001954:	ec66                	sd	s9,24(sp)
    80001956:	e86a                	sd	s10,16(sp)
    80001958:	e46e                	sd	s11,8(sp)
    8000195a:	1880                	addi	s0,sp,112
  struct proc *p;
  struct kthread *t;
  
  initlock(&pid_lock, "nextpid");
    8000195c:	00007597          	auipc	a1,0x7
    80001960:	8dc58593          	addi	a1,a1,-1828 # 80008238 <digits+0x1f8>
    80001964:	00010517          	auipc	a0,0x10
    80001968:	93c50513          	addi	a0,a0,-1732 # 800112a0 <pid_lock>
    8000196c:	fffff097          	auipc	ra,0xfffff
    80001970:	1ca080e7          	jalr	458(ra) # 80000b36 <initlock>
  initlock(&tid_lock,"nexttid");
    80001974:	00007597          	auipc	a1,0x7
    80001978:	8cc58593          	addi	a1,a1,-1844 # 80008240 <digits+0x200>
    8000197c:	00010517          	auipc	a0,0x10
    80001980:	93c50513          	addi	a0,a0,-1732 # 800112b8 <tid_lock>
    80001984:	fffff097          	auipc	ra,0xfffff
    80001988:	1b2080e7          	jalr	434(ra) # 80000b36 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000198c:	00007597          	auipc	a1,0x7
    80001990:	8bc58593          	addi	a1,a1,-1860 # 80008248 <digits+0x208>
    80001994:	00010517          	auipc	a0,0x10
    80001998:	93c50513          	addi	a0,a0,-1732 # 800112d0 <wait_lock>
    8000199c:	fffff097          	auipc	ra,0xfffff
    800019a0:	19a080e7          	jalr	410(ra) # 80000b36 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {      
    800019a4:	00010997          	auipc	s3,0x10
    800019a8:	5cc98993          	addi	s3,s3,1484 # 80011f70 <proc+0x848>
    800019ac:	00010c17          	auipc	s8,0x10
    800019b0:	d7cc0c13          	addi	s8,s8,-644 # 80011728 <proc>
      initlock(&p->lock, "proc");
      // p->kstack = KSTACK((int) (p - proc));
      int proc_index= (int)(p-proc);
    800019b4:	8de2                	mv	s11,s8
    800019b6:	00006d17          	auipc	s10,0x6
    800019ba:	64ad0d13          	addi	s10,s10,1610 # 80008000 <etext>
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
        initlock(&t->lock, "thread");
    800019be:	00007b97          	auipc	s7,0x7
    800019c2:	8a2b8b93          	addi	s7,s7,-1886 # 80008260 <digits+0x220>
        int thread_index = (int)(t-p->kthreads);
    800019c6:	00006b17          	auipc	s6,0x6
    800019ca:	642b0b13          	addi	s6,s6,1602 # 80008008 <etext+0x8>
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    800019ce:	04000ab7          	lui	s5,0x4000
    800019d2:	1afd                	addi	s5,s5,-1
    800019d4:	0ab2                	slli	s5,s5,0xc
  for(p = proc; p < &proc[NPROC]; p++) {      
    800019d6:	6c85                	lui	s9,0x1
    800019d8:	848c8c93          	addi	s9,s9,-1976 # 848 <_entry-0x7ffff7b8>
    800019dc:	a809                	j	800019ee <procinit+0xb0>
    800019de:	9c66                	add	s8,s8,s9
    800019e0:	99e6                	add	s3,s3,s9
    800019e2:	00031797          	auipc	a5,0x31
    800019e6:	f4678793          	addi	a5,a5,-186 # 80032928 <tickslock>
    800019ea:	06fc0263          	beq	s8,a5,80001a4e <procinit+0x110>
      initlock(&p->lock, "proc");
    800019ee:	00007597          	auipc	a1,0x7
    800019f2:	86a58593          	addi	a1,a1,-1942 # 80008258 <digits+0x218>
    800019f6:	8562                	mv	a0,s8
    800019f8:	fffff097          	auipc	ra,0xfffff
    800019fc:	13e080e7          	jalr	318(ra) # 80000b36 <initlock>
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001a00:	288c0a13          	addi	s4,s8,648
      int proc_index= (int)(p-proc);
    80001a04:	41bc0933          	sub	s2,s8,s11
    80001a08:	40395913          	srai	s2,s2,0x3
    80001a0c:	000d3783          	ld	a5,0(s10)
    80001a10:	02f90933          	mul	s2,s2,a5
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    80001a14:	0039191b          	slliw	s2,s2,0x3
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001a18:	84d2                	mv	s1,s4
        initlock(&t->lock, "thread");
    80001a1a:	85de                	mv	a1,s7
    80001a1c:	8526                	mv	a0,s1
    80001a1e:	fffff097          	auipc	ra,0xfffff
    80001a22:	118080e7          	jalr	280(ra) # 80000b36 <initlock>
        int thread_index = (int)(t-p->kthreads);
    80001a26:	414487b3          	sub	a5,s1,s4
    80001a2a:	878d                	srai	a5,a5,0x3
    80001a2c:	000b3703          	ld	a4,0(s6)
    80001a30:	02e787b3          	mul	a5,a5,a4
        t->kstack = KSTACK( proc_index * NTHREAD + thread_index);
    80001a34:	012787bb          	addw	a5,a5,s2
    80001a38:	2785                	addiw	a5,a5,1
    80001a3a:	00d7979b          	slliw	a5,a5,0xd
    80001a3e:	40fa87b3          	sub	a5,s5,a5
    80001a42:	fc9c                	sd	a5,56(s1)
      for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001a44:	0b848493          	addi	s1,s1,184
    80001a48:	fd3499e3          	bne	s1,s3,80001a1a <procinit+0xdc>
    80001a4c:	bf49                	j	800019de <procinit+0xa0>
      }
  }
}
    80001a4e:	70a6                	ld	ra,104(sp)
    80001a50:	7406                	ld	s0,96(sp)
    80001a52:	64e6                	ld	s1,88(sp)
    80001a54:	6946                	ld	s2,80(sp)
    80001a56:	69a6                	ld	s3,72(sp)
    80001a58:	6a06                	ld	s4,64(sp)
    80001a5a:	7ae2                	ld	s5,56(sp)
    80001a5c:	7b42                	ld	s6,48(sp)
    80001a5e:	7ba2                	ld	s7,40(sp)
    80001a60:	7c02                	ld	s8,32(sp)
    80001a62:	6ce2                	ld	s9,24(sp)
    80001a64:	6d42                	ld	s10,16(sp)
    80001a66:	6da2                	ld	s11,8(sp)
    80001a68:	6165                	addi	sp,sp,112
    80001a6a:	8082                	ret

0000000080001a6c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a6c:	1141                	addi	sp,sp,-16
    80001a6e:	e422                	sd	s0,8(sp)
    80001a70:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a72:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001a74:	2501                	sext.w	a0,a0
    80001a76:	6422                	ld	s0,8(sp)
    80001a78:	0141                	addi	sp,sp,16
    80001a7a:	8082                	ret

0000000080001a7c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001a7c:	1141                	addi	sp,sp,-16
    80001a7e:	e422                	sd	s0,8(sp)
    80001a80:	0800                	addi	s0,sp,16
    80001a82:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a84:	0007851b          	sext.w	a0,a5
    80001a88:	00451793          	slli	a5,a0,0x4
    80001a8c:	97aa                	add	a5,a5,a0
    80001a8e:	078e                	slli	a5,a5,0x3
  return c;
}
    80001a90:	00010517          	auipc	a0,0x10
    80001a94:	85850513          	addi	a0,a0,-1960 # 800112e8 <cpus>
    80001a98:	953e                	add	a0,a0,a5
    80001a9a:	6422                	ld	s0,8(sp)
    80001a9c:	0141                	addi	sp,sp,16
    80001a9e:	8082                	ret

0000000080001aa0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001aa0:	1101                	addi	sp,sp,-32
    80001aa2:	ec06                	sd	ra,24(sp)
    80001aa4:	e822                	sd	s0,16(sp)
    80001aa6:	e426                	sd	s1,8(sp)
    80001aa8:	1000                	addi	s0,sp,32
  push_off();
    80001aaa:	fffff097          	auipc	ra,0xfffff
    80001aae:	0d0080e7          	jalr	208(ra) # 80000b7a <push_off>
    80001ab2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001ab4:	0007871b          	sext.w	a4,a5
    80001ab8:	00471793          	slli	a5,a4,0x4
    80001abc:	97ba                	add	a5,a5,a4
    80001abe:	078e                	slli	a5,a5,0x3
    80001ac0:	0000f717          	auipc	a4,0xf
    80001ac4:	7e070713          	addi	a4,a4,2016 # 800112a0 <pid_lock>
    80001ac8:	97ba                	add	a5,a5,a4
    80001aca:	67a4                	ld	s1,72(a5)
  pop_off();
    80001acc:	fffff097          	auipc	ra,0xfffff
    80001ad0:	164080e7          	jalr	356(ra) # 80000c30 <pop_off>
  return p;
}//
    80001ad4:	8526                	mv	a0,s1
    80001ad6:	60e2                	ld	ra,24(sp)
    80001ad8:	6442                	ld	s0,16(sp)
    80001ada:	64a2                	ld	s1,8(sp)
    80001adc:	6105                	addi	sp,sp,32
    80001ade:	8082                	ret

0000000080001ae0 <mykthread>:

struct kthread*
mykthread(void){
    80001ae0:	1101                	addi	sp,sp,-32
    80001ae2:	ec06                	sd	ra,24(sp)
    80001ae4:	e822                	sd	s0,16(sp)
    80001ae6:	e426                	sd	s1,8(sp)
    80001ae8:	1000                	addi	s0,sp,32
  push_off();
    80001aea:	fffff097          	auipc	ra,0xfffff
    80001aee:	090080e7          	jalr	144(ra) # 80000b7a <push_off>
    80001af2:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct kthread *t=c->kthread;
    80001af4:	0007871b          	sext.w	a4,a5
    80001af8:	00471793          	slli	a5,a4,0x4
    80001afc:	97ba                	add	a5,a5,a4
    80001afe:	078e                	slli	a5,a5,0x3
    80001b00:	0000f717          	auipc	a4,0xf
    80001b04:	7a070713          	addi	a4,a4,1952 # 800112a0 <pid_lock>
    80001b08:	97ba                	add	a5,a5,a4
    80001b0a:	67e4                	ld	s1,200(a5)
  pop_off();
    80001b0c:	fffff097          	auipc	ra,0xfffff
    80001b10:	124080e7          	jalr	292(ra) # 80000c30 <pop_off>
  return t;  
}
    80001b14:	8526                	mv	a0,s1
    80001b16:	60e2                	ld	ra,24(sp)
    80001b18:	6442                	ld	s0,16(sp)
    80001b1a:	64a2                	ld	s1,8(sp)
    80001b1c:	6105                	addi	sp,sp,32
    80001b1e:	8082                	ret

0000000080001b20 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001b20:	1141                	addi	sp,sp,-16
    80001b22:	e406                	sd	ra,8(sp)
    80001b24:	e022                	sd	s0,0(sp)
    80001b26:	0800                	addi	s0,sp,16
  // static variables initialized only once
  static int first = 1;

  // Still holding p->lock from scheduler.
  // release(&myproc()->lock);
  release(&mykthread()->lock);    // TODO: check if this change is good
    80001b28:	00000097          	auipc	ra,0x0
    80001b2c:	fb8080e7          	jalr	-72(ra) # 80001ae0 <mykthread>
    80001b30:	fffff097          	auipc	ra,0xfffff
    80001b34:	160080e7          	jalr	352(ra) # 80000c90 <release>

  if (first) {
    80001b38:	00007797          	auipc	a5,0x7
    80001b3c:	e987a783          	lw	a5,-360(a5) # 800089d0 <first.1>
    80001b40:	eb89                	bnez	a5,80001b52 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001b42:	00002097          	auipc	ra,0x2
    80001b46:	89c080e7          	jalr	-1892(ra) # 800033de <usertrapret>
}
    80001b4a:	60a2                	ld	ra,8(sp)
    80001b4c:	6402                	ld	s0,0(sp)
    80001b4e:	0141                	addi	sp,sp,16
    80001b50:	8082                	ret
    first = 0;
    80001b52:	00007797          	auipc	a5,0x7
    80001b56:	e607af23          	sw	zero,-386(a5) # 800089d0 <first.1>
    fsinit(ROOTDEV);
    80001b5a:	4505                	li	a0,1
    80001b5c:	00003097          	auipc	ra,0x3
    80001b60:	84a080e7          	jalr	-1974(ra) # 800043a6 <fsinit>
    80001b64:	bff9                	j	80001b42 <forkret+0x22>

0000000080001b66 <allocpid>:
allocpid() {
    80001b66:	1101                	addi	sp,sp,-32
    80001b68:	ec06                	sd	ra,24(sp)
    80001b6a:	e822                	sd	s0,16(sp)
    80001b6c:	e426                	sd	s1,8(sp)
    80001b6e:	e04a                	sd	s2,0(sp)
    80001b70:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b72:	0000f917          	auipc	s2,0xf
    80001b76:	72e90913          	addi	s2,s2,1838 # 800112a0 <pid_lock>
    80001b7a:	854a                	mv	a0,s2
    80001b7c:	fffff097          	auipc	ra,0xfffff
    80001b80:	04a080e7          	jalr	74(ra) # 80000bc6 <acquire>
  pid = nextpid;
    80001b84:	00007797          	auipc	a5,0x7
    80001b88:	e5478793          	addi	a5,a5,-428 # 800089d8 <nextpid>
    80001b8c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b8e:	0014871b          	addiw	a4,s1,1
    80001b92:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b94:	854a                	mv	a0,s2
    80001b96:	fffff097          	auipc	ra,0xfffff
    80001b9a:	0fa080e7          	jalr	250(ra) # 80000c90 <release>
}
    80001b9e:	8526                	mv	a0,s1
    80001ba0:	60e2                	ld	ra,24(sp)
    80001ba2:	6442                	ld	s0,16(sp)
    80001ba4:	64a2                	ld	s1,8(sp)
    80001ba6:	6902                	ld	s2,0(sp)
    80001ba8:	6105                	addi	sp,sp,32
    80001baa:	8082                	ret

0000000080001bac <alloctid>:
alloctid() {
    80001bac:	1101                	addi	sp,sp,-32
    80001bae:	ec06                	sd	ra,24(sp)
    80001bb0:	e822                	sd	s0,16(sp)
    80001bb2:	e426                	sd	s1,8(sp)
    80001bb4:	e04a                	sd	s2,0(sp)
    80001bb6:	1000                	addi	s0,sp,32
  acquire(&tid_lock);
    80001bb8:	0000f917          	auipc	s2,0xf
    80001bbc:	70090913          	addi	s2,s2,1792 # 800112b8 <tid_lock>
    80001bc0:	854a                	mv	a0,s2
    80001bc2:	fffff097          	auipc	ra,0xfffff
    80001bc6:	004080e7          	jalr	4(ra) # 80000bc6 <acquire>
  tid = nexttid;
    80001bca:	00007797          	auipc	a5,0x7
    80001bce:	e0a78793          	addi	a5,a5,-502 # 800089d4 <nexttid>
    80001bd2:	4384                	lw	s1,0(a5)
  nexttid = nexttid + 1;
    80001bd4:	0014871b          	addiw	a4,s1,1
    80001bd8:	c398                	sw	a4,0(a5)
  release(&tid_lock);
    80001bda:	854a                	mv	a0,s2
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	0b4080e7          	jalr	180(ra) # 80000c90 <release>
}
    80001be4:	8526                	mv	a0,s1
    80001be6:	60e2                	ld	ra,24(sp)
    80001be8:	6442                	ld	s0,16(sp)
    80001bea:	64a2                	ld	s1,8(sp)
    80001bec:	6902                	ld	s2,0(sp)
    80001bee:	6105                	addi	sp,sp,32
    80001bf0:	8082                	ret

0000000080001bf2 <init_thread>:
init_thread(struct kthread *t){
    80001bf2:	1101                	addi	sp,sp,-32
    80001bf4:	ec06                	sd	ra,24(sp)
    80001bf6:	e822                	sd	s0,16(sp)
    80001bf8:	e426                	sd	s1,8(sp)
    80001bfa:	1000                	addi	s0,sp,32
    80001bfc:	84aa                	mv	s1,a0
  t->state = TUSED;
    80001bfe:	4785                	li	a5,1
    80001c00:	cd1c                	sw	a5,24(a0)
  t->tid = alloctid();  
    80001c02:	00000097          	auipc	ra,0x0
    80001c06:	faa080e7          	jalr	-86(ra) # 80001bac <alloctid>
    80001c0a:	d888                	sw	a0,48(s1)
  memset(&(t->context), 0, sizeof(t->context));
    80001c0c:	07000613          	li	a2,112
    80001c10:	4581                	li	a1,0
    80001c12:	04848513          	addi	a0,s1,72
    80001c16:	fffff097          	auipc	ra,0xfffff
    80001c1a:	0c2080e7          	jalr	194(ra) # 80000cd8 <memset>
  t->context.ra = (uint64)forkret;
    80001c1e:	00000797          	auipc	a5,0x0
    80001c22:	f0278793          	addi	a5,a5,-254 # 80001b20 <forkret>
    80001c26:	e4bc                	sd	a5,72(s1)
  t->context.sp = t->kstack + PGSIZE;
    80001c28:	7c9c                	ld	a5,56(s1)
    80001c2a:	6705                	lui	a4,0x1
    80001c2c:	97ba                	add	a5,a5,a4
    80001c2e:	e8bc                	sd	a5,80(s1)
}
    80001c30:	4501                	li	a0,0
    80001c32:	60e2                	ld	ra,24(sp)
    80001c34:	6442                	ld	s0,16(sp)
    80001c36:	64a2                	ld	s1,8(sp)
    80001c38:	6105                	addi	sp,sp,32
    80001c3a:	8082                	ret

0000000080001c3c <proc_pagetable>:
{
    80001c3c:	1101                	addi	sp,sp,-32
    80001c3e:	ec06                	sd	ra,24(sp)
    80001c40:	e822                	sd	s0,16(sp)
    80001c42:	e426                	sd	s1,8(sp)
    80001c44:	e04a                	sd	s2,0(sp)
    80001c46:	1000                	addi	s0,sp,32
    80001c48:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001c4a:	fffff097          	auipc	ra,0xfffff
    80001c4e:	6f6080e7          	jalr	1782(ra) # 80001340 <uvmcreate>
    80001c52:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001c54:	c12d                	beqz	a0,80001cb6 <proc_pagetable+0x7a>
  printf("before mappages\n");
    80001c56:	00006517          	auipc	a0,0x6
    80001c5a:	61250513          	addi	a0,a0,1554 # 80008268 <digits+0x228>
    80001c5e:	fffff097          	auipc	ra,0xfffff
    80001c62:	91a080e7          	jalr	-1766(ra) # 80000578 <printf>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001c66:	4729                	li	a4,10
    80001c68:	00005697          	auipc	a3,0x5
    80001c6c:	39868693          	addi	a3,a3,920 # 80007000 <_trampoline>
    80001c70:	6605                	lui	a2,0x1
    80001c72:	040005b7          	lui	a1,0x4000
    80001c76:	15fd                	addi	a1,a1,-1
    80001c78:	05b2                	slli	a1,a1,0xc
    80001c7a:	8526                	mv	a0,s1
    80001c7c:	fffff097          	auipc	ra,0xfffff
    80001c80:	43c080e7          	jalr	1084(ra) # 800010b8 <mappages>
    80001c84:	04054063          	bltz	a0,80001cc4 <proc_pagetable+0x88>
  printf("after mappages\n");
    80001c88:	00006517          	auipc	a0,0x6
    80001c8c:	5f850513          	addi	a0,a0,1528 # 80008280 <digits+0x240>
    80001c90:	fffff097          	auipc	ra,0xfffff
    80001c94:	8e8080e7          	jalr	-1816(ra) # 80000578 <printf>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001c98:	4719                	li	a4,6
    80001c9a:	04893683          	ld	a3,72(s2)
    80001c9e:	6605                	lui	a2,0x1
    80001ca0:	020005b7          	lui	a1,0x2000
    80001ca4:	15fd                	addi	a1,a1,-1
    80001ca6:	05b6                	slli	a1,a1,0xd
    80001ca8:	8526                	mv	a0,s1
    80001caa:	fffff097          	auipc	ra,0xfffff
    80001cae:	40e080e7          	jalr	1038(ra) # 800010b8 <mappages>
    80001cb2:	02054163          	bltz	a0,80001cd4 <proc_pagetable+0x98>
}
    80001cb6:	8526                	mv	a0,s1
    80001cb8:	60e2                	ld	ra,24(sp)
    80001cba:	6442                	ld	s0,16(sp)
    80001cbc:	64a2                	ld	s1,8(sp)
    80001cbe:	6902                	ld	s2,0(sp)
    80001cc0:	6105                	addi	sp,sp,32
    80001cc2:	8082                	ret
    uvmfree(pagetable, 0);
    80001cc4:	4581                	li	a1,0
    80001cc6:	8526                	mv	a0,s1
    80001cc8:	00000097          	auipc	ra,0x0
    80001ccc:	884080e7          	jalr	-1916(ra) # 8000154c <uvmfree>
    return 0;
    80001cd0:	4481                	li	s1,0
    80001cd2:	b7d5                	j	80001cb6 <proc_pagetable+0x7a>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001cd4:	4681                	li	a3,0
    80001cd6:	4605                	li	a2,1
    80001cd8:	040005b7          	lui	a1,0x4000
    80001cdc:	15fd                	addi	a1,a1,-1
    80001cde:	05b2                	slli	a1,a1,0xc
    80001ce0:	8526                	mv	a0,s1
    80001ce2:	fffff097          	auipc	ra,0xfffff
    80001ce6:	59a080e7          	jalr	1434(ra) # 8000127c <uvmunmap>
    uvmfree(pagetable, 0);
    80001cea:	4581                	li	a1,0
    80001cec:	8526                	mv	a0,s1
    80001cee:	00000097          	auipc	ra,0x0
    80001cf2:	85e080e7          	jalr	-1954(ra) # 8000154c <uvmfree>
    return 0;
    80001cf6:	4481                	li	s1,0
    80001cf8:	bf7d                	j	80001cb6 <proc_pagetable+0x7a>

0000000080001cfa <proc_freepagetable>:
{
    80001cfa:	1101                	addi	sp,sp,-32
    80001cfc:	ec06                	sd	ra,24(sp)
    80001cfe:	e822                	sd	s0,16(sp)
    80001d00:	e426                	sd	s1,8(sp)
    80001d02:	e04a                	sd	s2,0(sp)
    80001d04:	1000                	addi	s0,sp,32
    80001d06:	84aa                	mv	s1,a0
    80001d08:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d0a:	4681                	li	a3,0
    80001d0c:	4605                	li	a2,1
    80001d0e:	040005b7          	lui	a1,0x4000
    80001d12:	15fd                	addi	a1,a1,-1
    80001d14:	05b2                	slli	a1,a1,0xc
    80001d16:	fffff097          	auipc	ra,0xfffff
    80001d1a:	566080e7          	jalr	1382(ra) # 8000127c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d1e:	4681                	li	a3,0
    80001d20:	4605                	li	a2,1
    80001d22:	020005b7          	lui	a1,0x2000
    80001d26:	15fd                	addi	a1,a1,-1
    80001d28:	05b6                	slli	a1,a1,0xd
    80001d2a:	8526                	mv	a0,s1
    80001d2c:	fffff097          	auipc	ra,0xfffff
    80001d30:	550080e7          	jalr	1360(ra) # 8000127c <uvmunmap>
  uvmfree(pagetable, sz);
    80001d34:	85ca                	mv	a1,s2
    80001d36:	8526                	mv	a0,s1
    80001d38:	00000097          	auipc	ra,0x0
    80001d3c:	814080e7          	jalr	-2028(ra) # 8000154c <uvmfree>
}
    80001d40:	60e2                	ld	ra,24(sp)
    80001d42:	6442                	ld	s0,16(sp)
    80001d44:	64a2                	ld	s1,8(sp)
    80001d46:	6902                	ld	s2,0(sp)
    80001d48:	6105                	addi	sp,sp,32
    80001d4a:	8082                	ret

0000000080001d4c <freeproc>:
{
    80001d4c:	7179                	addi	sp,sp,-48
    80001d4e:	f406                	sd	ra,40(sp)
    80001d50:	f022                	sd	s0,32(sp)
    80001d52:	ec26                	sd	s1,24(sp)
    80001d54:	e84a                	sd	s2,16(sp)
    80001d56:	e44e                	sd	s3,8(sp)
    80001d58:	1800                	addi	s0,sp,48
    80001d5a:	892a                	mv	s2,a0
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001d5c:	28850493          	addi	s1,a0,648
    80001d60:	6985                	lui	s3,0x1
    80001d62:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80001d66:	99aa                	add	s3,s3,a0
    80001d68:	a811                	j	80001d7c <freeproc+0x30>
    release(&t->lock);
    80001d6a:	8526                	mv	a0,s1
    80001d6c:	fffff097          	auipc	ra,0xfffff
    80001d70:	f24080e7          	jalr	-220(ra) # 80000c90 <release>
  for(t = p->kthreads; t < &(p->kthreads[NTHREAD]); t++){
    80001d74:	0b848493          	addi	s1,s1,184
    80001d78:	02998463          	beq	s3,s1,80001da0 <freeproc+0x54>
    acquire(&t->lock);
    80001d7c:	8526                	mv	a0,s1
    80001d7e:	fffff097          	auipc	ra,0xfffff
    80001d82:	e48080e7          	jalr	-440(ra) # 80000bc6 <acquire>
    if(t->state != TUNUSED)
    80001d86:	4c9c                	lw	a5,24(s1)
    80001d88:	d3ed                	beqz	a5,80001d6a <freeproc+0x1e>
  t->tid = 0;
    80001d8a:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80001d8e:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80001d92:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80001d96:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80001d9a:	0004ac23          	sw	zero,24(s1)
}
    80001d9e:	b7f1                	j	80001d6a <freeproc+0x1e>
  p->user_trapframe_backup = 0;
    80001da0:	26093c23          	sd	zero,632(s2)
  if(p->pagetable)
    80001da4:	04093503          	ld	a0,64(s2)
    80001da8:	c519                	beqz	a0,80001db6 <freeproc+0x6a>
    proc_freepagetable(p->pagetable, p->sz);
    80001daa:	03893583          	ld	a1,56(s2)
    80001dae:	00000097          	auipc	ra,0x0
    80001db2:	f4c080e7          	jalr	-180(ra) # 80001cfa <proc_freepagetable>
  p->pagetable = 0;
    80001db6:	04093023          	sd	zero,64(s2)
  p->sz = 0;
    80001dba:	02093c23          	sd	zero,56(s2)
  p->pid = 0;
    80001dbe:	02092223          	sw	zero,36(s2)
  p->parent = 0;
    80001dc2:	02093823          	sd	zero,48(s2)
  p->name[0] = 0;
    80001dc6:	0c090c23          	sb	zero,216(s2)
  p->killed = 0;
    80001dca:	00092e23          	sw	zero,28(s2)
  p->xstate = 0;
    80001dce:	02092023          	sw	zero,32(s2)
  p->active_threads = 0;
    80001dd2:	02092423          	sw	zero,40(s2)
  p->state = UNUSED;
    80001dd6:	00092c23          	sw	zero,24(s2)
}
    80001dda:	70a2                	ld	ra,40(sp)
    80001ddc:	7402                	ld	s0,32(sp)
    80001dde:	64e2                	ld	s1,24(sp)
    80001de0:	6942                	ld	s2,16(sp)
    80001de2:	69a2                	ld	s3,8(sp)
    80001de4:	6145                	addi	sp,sp,48
    80001de6:	8082                	ret

0000000080001de8 <allocproc>:
{
    80001de8:	7111                	addi	sp,sp,-256
    80001dea:	fd86                	sd	ra,248(sp)
    80001dec:	f9a2                	sd	s0,240(sp)
    80001dee:	f5a6                	sd	s1,232(sp)
    80001df0:	f1ca                	sd	s2,224(sp)
    80001df2:	edce                	sd	s3,216(sp)
    80001df4:	e9d2                	sd	s4,208(sp)
    80001df6:	e5d6                	sd	s5,200(sp)
    80001df8:	e1da                	sd	s6,192(sp)
    80001dfa:	0200                	addi	s0,sp,256
  for(p = proc; p < &proc[NPROC]; p++) {
    80001dfc:	00010497          	auipc	s1,0x10
    80001e00:	92c48493          	addi	s1,s1,-1748 # 80011728 <proc>
    80001e04:	6985                	lui	s3,0x1
    80001e06:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80001e0a:	00031a17          	auipc	s4,0x31
    80001e0e:	b1ea0a13          	addi	s4,s4,-1250 # 80032928 <tickslock>
    acquire(&p->lock);
    80001e12:	8526                	mv	a0,s1
    80001e14:	fffff097          	auipc	ra,0xfffff
    80001e18:	db2080e7          	jalr	-590(ra) # 80000bc6 <acquire>
    if(p->state == UNUSED) {
    80001e1c:	4c9c                	lw	a5,24(s1)
    80001e1e:	cb99                	beqz	a5,80001e34 <allocproc+0x4c>
      release(&p->lock);
    80001e20:	8526                	mv	a0,s1
    80001e22:	fffff097          	auipc	ra,0xfffff
    80001e26:	e6e080e7          	jalr	-402(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e2a:	94ce                	add	s1,s1,s3
    80001e2c:	ff4493e3          	bne	s1,s4,80001e12 <allocproc+0x2a>
  return 0;
    80001e30:	4481                	li	s1,0
    80001e32:	aa09                	j	80001f44 <allocproc+0x15c>
  p->pid = allocpid();
    80001e34:	00000097          	auipc	ra,0x0
    80001e38:	d32080e7          	jalr	-718(ra) # 80001b66 <allocpid>
    80001e3c:	d0c8                	sw	a0,36(s1)
  p->state = USED;
    80001e3e:	4785                	li	a5,1
    80001e40:	cc9c                	sw	a5,24(s1)
  if((p->threads_tf_start =(void *)kalloc() == 0)){
    80001e42:	fffff097          	auipc	ra,0xfffff
    80001e46:	c94080e7          	jalr	-876(ra) # 80000ad6 <kalloc>
    80001e4a:	89aa                	mv	s3,a0
    80001e4c:	00153593          	seqz	a1,a0
    80001e50:	e4ac                	sd	a1,72(s1)
    80001e52:	10050463          	beqz	a0,80001f5a <allocproc+0x172>
  printf("start of tfs %p \n",p->threads_tf_start);
    80001e56:	00006517          	auipc	a0,0x6
    80001e5a:	43a50513          	addi	a0,a0,1082 # 80008290 <digits+0x250>
    80001e5e:	ffffe097          	auipc	ra,0xffffe
    80001e62:	71a080e7          	jalr	1818(ra) # 80000578 <printf>
  for(int i=0;i<32;i++){
    80001e66:	0f848713          	addi	a4,s1,248
    80001e6a:	1f848793          	addi	a5,s1,504
    80001e6e:	27848693          	addi	a3,s1,632
    p->signal_handlers[i] = SIG_DFL;
    80001e72:	00073023          	sd	zero,0(a4) # 1000 <_entry-0x7ffff000>
    p->handlers_sigmasks[i] = 0;
    80001e76:	0007a023          	sw	zero,0(a5)
  for(int i=0;i<32;i++){
    80001e7a:	0721                	addi	a4,a4,8
    80001e7c:	0791                	addi	a5,a5,4
    80001e7e:	fed79ae3          	bne	a5,a3,80001e72 <allocproc+0x8a>
  p->signal_mask= 0;
    80001e82:	0e04a623          	sw	zero,236(s1)
  p->pending_signals = 0;
    80001e86:	0e04a423          	sw	zero,232(s1)
  p->active_threads=1;
    80001e8a:	4785                	li	a5,1
    80001e8c:	d49c                	sw	a5,40(s1)
  p->signal_mask_backup = 0;
    80001e8e:	0e04a823          	sw	zero,240(s1)
  p->handling_user_sig_flag = 0;
    80001e92:	2804a023          	sw	zero,640(s1)
  p->handling_sig_flag=0;
    80001e96:	2804a223          	sw	zero,644(s1)
  p->pagetable = proc_pagetable(p);
    80001e9a:	8526                	mv	a0,s1
    80001e9c:	00000097          	auipc	ra,0x0
    80001ea0:	da0080e7          	jalr	-608(ra) # 80001c3c <proc_pagetable>
    80001ea4:	8b2a                	mv	s6,a0
    80001ea6:	e0a8                	sd	a0,64(s1)
  if(p->pagetable == 0){
    80001ea8:	4981                	li	s3,0
  for(int i=0;i<NTHREAD;i++){
    80001eaa:	4901                	li	s2,0
    printf("addr of t %d is %p\n",i ,t.trapframe);
    80001eac:	00006a97          	auipc	s5,0x6
    80001eb0:	3fca8a93          	addi	s5,s5,1020 # 800082a8 <digits+0x268>
  for(int i=0;i<NTHREAD;i++){
    80001eb4:	4a21                	li	s4,8
  if(p->pagetable == 0){
    80001eb6:	cd55                	beqz	a0,80001f72 <allocproc+0x18a>
    t.trapframe = (struct trapframe *)p->threads_tf_start + i;     //TODO: check if good or maybe + i*sizeof(struct trapframe)
    80001eb8:	64b0                	ld	a2,72(s1)
    printf("addr of t %d is %p\n",i ,t.trapframe);
    80001eba:	964e                	add	a2,a2,s3
    80001ebc:	85ca                	mv	a1,s2
    80001ebe:	8556                	mv	a0,s5
    80001ec0:	ffffe097          	auipc	ra,0xffffe
    80001ec4:	6b8080e7          	jalr	1720(ra) # 80000578 <printf>
  for(int i=0;i<NTHREAD;i++){
    80001ec8:	2905                	addiw	s2,s2,1
    80001eca:	12098993          	addi	s3,s3,288
    80001ece:	ff4915e3          	bne	s2,s4,80001eb8 <allocproc+0xd0>
  printf("finished thread loop\n");
    80001ed2:	00006517          	auipc	a0,0x6
    80001ed6:	3ee50513          	addi	a0,a0,1006 # 800082c0 <digits+0x280>
    80001eda:	ffffe097          	auipc	ra,0xffffe
    80001ede:	69e080e7          	jalr	1694(ra) # 80000578 <printf>
  struct kthread t= p->kthreads[0];
    80001ee2:	28848793          	addi	a5,s1,648
    80001ee6:	f0840713          	addi	a4,s0,-248
    80001eea:	32848813          	addi	a6,s1,808
    80001eee:	6388                	ld	a0,0(a5)
    80001ef0:	678c                	ld	a1,8(a5)
    80001ef2:	6b90                	ld	a2,16(a5)
    80001ef4:	6f94                	ld	a3,24(a5)
    80001ef6:	e308                	sd	a0,0(a4)
    80001ef8:	e70c                	sd	a1,8(a4)
    80001efa:	eb10                	sd	a2,16(a4)
    80001efc:	ef14                	sd	a3,24(a4)
    80001efe:	02078793          	addi	a5,a5,32
    80001f02:	02070713          	addi	a4,a4,32
    80001f06:	ff0794e3          	bne	a5,a6,80001eee <allocproc+0x106>
    80001f0a:	6390                	ld	a2,0(a5)
    80001f0c:	6794                	ld	a3,8(a5)
    80001f0e:	6b9c                	ld	a5,16(a5)
    80001f10:	e310                	sd	a2,0(a4)
    80001f12:	e714                	sd	a3,8(a4)
    80001f14:	eb1c                	sd	a5,16(a4)
  acquire(&t.lock);
    80001f16:	f0840513          	addi	a0,s0,-248
    80001f1a:	fffff097          	auipc	ra,0xfffff
    80001f1e:	cac080e7          	jalr	-852(ra) # 80000bc6 <acquire>
  if(init_thread(&t) == -1){
    80001f22:	f0840513          	addi	a0,s0,-248
    80001f26:	00000097          	auipc	ra,0x0
    80001f2a:	ccc080e7          	jalr	-820(ra) # 80001bf2 <init_thread>
    80001f2e:	57fd                	li	a5,-1
    80001f30:	04f50d63          	beq	a0,a5,80001f8a <allocproc+0x1a2>
  printf("after allocproc\n");
    80001f34:	00006517          	auipc	a0,0x6
    80001f38:	3c450513          	addi	a0,a0,964 # 800082f8 <digits+0x2b8>
    80001f3c:	ffffe097          	auipc	ra,0xffffe
    80001f40:	63c080e7          	jalr	1596(ra) # 80000578 <printf>
}
    80001f44:	8526                	mv	a0,s1
    80001f46:	70ee                	ld	ra,248(sp)
    80001f48:	744e                	ld	s0,240(sp)
    80001f4a:	74ae                	ld	s1,232(sp)
    80001f4c:	790e                	ld	s2,224(sp)
    80001f4e:	69ee                	ld	s3,216(sp)
    80001f50:	6a4e                	ld	s4,208(sp)
    80001f52:	6aae                	ld	s5,200(sp)
    80001f54:	6b0e                	ld	s6,192(sp)
    80001f56:	6111                	addi	sp,sp,256
    80001f58:	8082                	ret
    freeproc(p);
    80001f5a:	8526                	mv	a0,s1
    80001f5c:	00000097          	auipc	ra,0x0
    80001f60:	df0080e7          	jalr	-528(ra) # 80001d4c <freeproc>
    release(&p->lock);
    80001f64:	8526                	mv	a0,s1
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	d2a080e7          	jalr	-726(ra) # 80000c90 <release>
    return 0;
    80001f6e:	84ce                	mv	s1,s3
    80001f70:	bfd1                	j	80001f44 <allocproc+0x15c>
    freeproc(p);
    80001f72:	8526                	mv	a0,s1
    80001f74:	00000097          	auipc	ra,0x0
    80001f78:	dd8080e7          	jalr	-552(ra) # 80001d4c <freeproc>
    release(&p->lock);
    80001f7c:	8526                	mv	a0,s1
    80001f7e:	fffff097          	auipc	ra,0xfffff
    80001f82:	d12080e7          	jalr	-750(ra) # 80000c90 <release>
    return 0;
    80001f86:	84da                	mv	s1,s6
    80001f88:	bf75                	j	80001f44 <allocproc+0x15c>
    printf("after init_threat failed\n");
    80001f8a:	00006517          	auipc	a0,0x6
    80001f8e:	34e50513          	addi	a0,a0,846 # 800082d8 <digits+0x298>
    80001f92:	ffffe097          	auipc	ra,0xffffe
    80001f96:	5e6080e7          	jalr	1510(ra) # 80000578 <printf>
    freeproc(p);
    80001f9a:	8526                	mv	a0,s1
    80001f9c:	00000097          	auipc	ra,0x0
    80001fa0:	db0080e7          	jalr	-592(ra) # 80001d4c <freeproc>
    release(&p->lock);
    80001fa4:	8526                	mv	a0,s1
    80001fa6:	fffff097          	auipc	ra,0xfffff
    80001faa:	cea080e7          	jalr	-790(ra) # 80000c90 <release>
    return 0;
    80001fae:	4481                	li	s1,0
    80001fb0:	bf51                	j	80001f44 <allocproc+0x15c>

0000000080001fb2 <userinit>:
{
    80001fb2:	1101                	addi	sp,sp,-32
    80001fb4:	ec06                	sd	ra,24(sp)
    80001fb6:	e822                	sd	s0,16(sp)
    80001fb8:	e426                	sd	s1,8(sp)
    80001fba:	e04a                	sd	s2,0(sp)
    80001fbc:	1000                	addi	s0,sp,32
  p = allocproc();
    80001fbe:	00000097          	auipc	ra,0x0
    80001fc2:	e2a080e7          	jalr	-470(ra) # 80001de8 <allocproc>
    80001fc6:	84aa                	mv	s1,a0
  initproc = p;
    80001fc8:	00007797          	auipc	a5,0x7
    80001fcc:	06a7b023          	sd	a0,96(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001fd0:	03400613          	li	a2,52
    80001fd4:	00007597          	auipc	a1,0x7
    80001fd8:	a0c58593          	addi	a1,a1,-1524 # 800089e0 <initcode>
    80001fdc:	6128                	ld	a0,64(a0)
    80001fde:	fffff097          	auipc	ra,0xfffff
    80001fe2:	390080e7          	jalr	912(ra) # 8000136e <uvminit>
  printf("returned from uvminit\n");
    80001fe6:	00006517          	auipc	a0,0x6
    80001fea:	32a50513          	addi	a0,a0,810 # 80008310 <digits+0x2d0>
    80001fee:	ffffe097          	auipc	ra,0xffffe
    80001ff2:	58a080e7          	jalr	1418(ra) # 80000578 <printf>
  p->sz = PGSIZE;
    80001ff6:	6905                	lui	s2,0x1
    80001ff8:	0324bc23          	sd	s2,56(s1)
  printf("after p->sz\n");
    80001ffc:	00006517          	auipc	a0,0x6
    80002000:	32c50513          	addi	a0,a0,812 # 80008328 <digits+0x2e8>
    80002004:	ffffe097          	auipc	ra,0xffffe
    80002008:	574080e7          	jalr	1396(ra) # 80000578 <printf>
  printf("t: %p\n",t);
    8000200c:	28848593          	addi	a1,s1,648
    80002010:	00006517          	auipc	a0,0x6
    80002014:	32850513          	addi	a0,a0,808 # 80008338 <digits+0x2f8>
    80002018:	ffffe097          	auipc	ra,0xffffe
    8000201c:	560080e7          	jalr	1376(ra) # 80000578 <printf>
  printf("tf : %p \n",t->trapframe);
    80002020:	2c84b583          	ld	a1,712(s1)
    80002024:	00006517          	auipc	a0,0x6
    80002028:	31c50513          	addi	a0,a0,796 # 80008340 <digits+0x300>
    8000202c:	ffffe097          	auipc	ra,0xffffe
    80002030:	54c080e7          	jalr	1356(ra) # 80000578 <printf>
  t->trapframe->epc = 0;      // user program counter
    80002034:	2c84b783          	ld	a5,712(s1)
    80002038:	0007bc23          	sd	zero,24(a5)
  t->trapframe->sp = PGSIZE;  // user stack pointer
    8000203c:	2c84b783          	ld	a5,712(s1)
    80002040:	0327b823          	sd	s2,48(a5)
  printf("before strcpy\n");
    80002044:	00006517          	auipc	a0,0x6
    80002048:	30c50513          	addi	a0,a0,780 # 80008350 <digits+0x310>
    8000204c:	ffffe097          	auipc	ra,0xffffe
    80002050:	52c080e7          	jalr	1324(ra) # 80000578 <printf>
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80002054:	4641                	li	a2,16
    80002056:	00006597          	auipc	a1,0x6
    8000205a:	30a58593          	addi	a1,a1,778 # 80008360 <digits+0x320>
    8000205e:	0d848513          	addi	a0,s1,216
    80002062:	fffff097          	auipc	ra,0xfffff
    80002066:	dc8080e7          	jalr	-568(ra) # 80000e2a <safestrcpy>
  printf("after strcpy\n");
    8000206a:	00006517          	auipc	a0,0x6
    8000206e:	30650513          	addi	a0,a0,774 # 80008370 <digits+0x330>
    80002072:	ffffe097          	auipc	ra,0xffffe
    80002076:	506080e7          	jalr	1286(ra) # 80000578 <printf>
  p->cwd = namei("/");
    8000207a:	00006517          	auipc	a0,0x6
    8000207e:	30650513          	addi	a0,a0,774 # 80008380 <digits+0x340>
    80002082:	00003097          	auipc	ra,0x3
    80002086:	d50080e7          	jalr	-688(ra) # 80004dd2 <namei>
    8000208a:	e8e8                	sd	a0,208(s1)
  p->state = RUNNABLE;
    8000208c:	4789                	li	a5,2
    8000208e:	cc9c                	sw	a5,24(s1)
  t->state = TRUNNABLE;
    80002090:	478d                	li	a5,3
    80002092:	2af4a023          	sw	a5,672(s1)
  release(&p->lock);
    80002096:	8526                	mv	a0,s1
    80002098:	fffff097          	auipc	ra,0xfffff
    8000209c:	bf8080e7          	jalr	-1032(ra) # 80000c90 <release>
  printf("after user init\n");
    800020a0:	00006517          	auipc	a0,0x6
    800020a4:	2e850513          	addi	a0,a0,744 # 80008388 <digits+0x348>
    800020a8:	ffffe097          	auipc	ra,0xffffe
    800020ac:	4d0080e7          	jalr	1232(ra) # 80000578 <printf>
}
    800020b0:	60e2                	ld	ra,24(sp)
    800020b2:	6442                	ld	s0,16(sp)
    800020b4:	64a2                	ld	s1,8(sp)
    800020b6:	6902                	ld	s2,0(sp)
    800020b8:	6105                	addi	sp,sp,32
    800020ba:	8082                	ret

00000000800020bc <growproc>:
{
    800020bc:	1101                	addi	sp,sp,-32
    800020be:	ec06                	sd	ra,24(sp)
    800020c0:	e822                	sd	s0,16(sp)
    800020c2:	e426                	sd	s1,8(sp)
    800020c4:	e04a                	sd	s2,0(sp)
    800020c6:	1000                	addi	s0,sp,32
    800020c8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800020ca:	00000097          	auipc	ra,0x0
    800020ce:	9d6080e7          	jalr	-1578(ra) # 80001aa0 <myproc>
    800020d2:	892a                	mv	s2,a0
  sz = p->sz;
    800020d4:	7d0c                	ld	a1,56(a0)
    800020d6:	0005861b          	sext.w	a2,a1
  if(n > 0){
    800020da:	00904f63          	bgtz	s1,800020f8 <growproc+0x3c>
  } else if(n < 0){
    800020de:	0204cc63          	bltz	s1,80002116 <growproc+0x5a>
  p->sz = sz;
    800020e2:	1602                	slli	a2,a2,0x20
    800020e4:	9201                	srli	a2,a2,0x20
    800020e6:	02c93c23          	sd	a2,56(s2) # 1038 <_entry-0x7fffefc8>
  return 0;
    800020ea:	4501                	li	a0,0
}
    800020ec:	60e2                	ld	ra,24(sp)
    800020ee:	6442                	ld	s0,16(sp)
    800020f0:	64a2                	ld	s1,8(sp)
    800020f2:	6902                	ld	s2,0(sp)
    800020f4:	6105                	addi	sp,sp,32
    800020f6:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    800020f8:	9e25                	addw	a2,a2,s1
    800020fa:	1602                	slli	a2,a2,0x20
    800020fc:	9201                	srli	a2,a2,0x20
    800020fe:	1582                	slli	a1,a1,0x20
    80002100:	9181                	srli	a1,a1,0x20
    80002102:	6128                	ld	a0,64(a0)
    80002104:	fffff097          	auipc	ra,0xfffff
    80002108:	334080e7          	jalr	820(ra) # 80001438 <uvmalloc>
    8000210c:	0005061b          	sext.w	a2,a0
    80002110:	fa69                	bnez	a2,800020e2 <growproc+0x26>
      return -1;
    80002112:	557d                	li	a0,-1
    80002114:	bfe1                	j	800020ec <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002116:	9e25                	addw	a2,a2,s1
    80002118:	1602                	slli	a2,a2,0x20
    8000211a:	9201                	srli	a2,a2,0x20
    8000211c:	1582                	slli	a1,a1,0x20
    8000211e:	9181                	srli	a1,a1,0x20
    80002120:	6128                	ld	a0,64(a0)
    80002122:	fffff097          	auipc	ra,0xfffff
    80002126:	2ce080e7          	jalr	718(ra) # 800013f0 <uvmdealloc>
    8000212a:	0005061b          	sext.w	a2,a0
    8000212e:	bf55                	j	800020e2 <growproc+0x26>

0000000080002130 <fork>:
{
    80002130:	7139                	addi	sp,sp,-64
    80002132:	fc06                	sd	ra,56(sp)
    80002134:	f822                	sd	s0,48(sp)
    80002136:	f426                	sd	s1,40(sp)
    80002138:	f04a                	sd	s2,32(sp)
    8000213a:	ec4e                	sd	s3,24(sp)
    8000213c:	e852                	sd	s4,16(sp)
    8000213e:	e456                	sd	s5,8(sp)
    80002140:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002142:	00000097          	auipc	ra,0x0
    80002146:	95e080e7          	jalr	-1698(ra) # 80001aa0 <myproc>
    8000214a:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    8000214c:	00000097          	auipc	ra,0x0
    80002150:	994080e7          	jalr	-1644(ra) # 80001ae0 <mykthread>
    80002154:	84aa                	mv	s1,a0
  if((np = allocproc()) == 0){
    80002156:	00000097          	auipc	ra,0x0
    8000215a:	c92080e7          	jalr	-878(ra) # 80001de8 <allocproc>
    8000215e:	16050a63          	beqz	a0,800022d2 <fork+0x1a2>
    80002162:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002164:	0389b603          	ld	a2,56(s3)
    80002168:	612c                	ld	a1,64(a0)
    8000216a:	0409b503          	ld	a0,64(s3)
    8000216e:	fffff097          	auipc	ra,0xfffff
    80002172:	416080e7          	jalr	1046(ra) # 80001584 <uvmcopy>
    80002176:	04054763          	bltz	a0,800021c4 <fork+0x94>
  np->sz = p->sz;
    8000217a:	0389b783          	ld	a5,56(s3)
    8000217e:	02f93c23          	sd	a5,56(s2)
  *(np_first_thread->trapframe) = *(t->trapframe);
    80002182:	60b4                	ld	a3,64(s1)
    80002184:	87b6                	mv	a5,a3
    80002186:	2c893703          	ld	a4,712(s2)
    8000218a:	12068693          	addi	a3,a3,288
    8000218e:	0007b803          	ld	a6,0(a5)
    80002192:	6788                	ld	a0,8(a5)
    80002194:	6b8c                	ld	a1,16(a5)
    80002196:	6f90                	ld	a2,24(a5)
    80002198:	01073023          	sd	a6,0(a4)
    8000219c:	e708                	sd	a0,8(a4)
    8000219e:	eb0c                	sd	a1,16(a4)
    800021a0:	ef10                	sd	a2,24(a4)
    800021a2:	02078793          	addi	a5,a5,32
    800021a6:	02070713          	addi	a4,a4,32
    800021aa:	fed792e3          	bne	a5,a3,8000218e <fork+0x5e>
  np_first_thread->trapframe->a0 = 0;  // TODO: change reading the ret value from proc a0 to thread a0
    800021ae:	2c893783          	ld	a5,712(s2)
    800021b2:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800021b6:	05098493          	addi	s1,s3,80
    800021ba:	05090a13          	addi	s4,s2,80
    800021be:	0d098a93          	addi	s5,s3,208
    800021c2:	a00d                	j	800021e4 <fork+0xb4>
    freeproc(np);
    800021c4:	854a                	mv	a0,s2
    800021c6:	00000097          	auipc	ra,0x0
    800021ca:	b86080e7          	jalr	-1146(ra) # 80001d4c <freeproc>
    release(&np->lock);
    800021ce:	854a                	mv	a0,s2
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	ac0080e7          	jalr	-1344(ra) # 80000c90 <release>
    return -1;
    800021d8:	5afd                	li	s5,-1
    800021da:	a0d5                	j	800022be <fork+0x18e>
  for(i = 0; i < NOFILE; i++)
    800021dc:	04a1                	addi	s1,s1,8
    800021de:	0a21                	addi	s4,s4,8
    800021e0:	01548b63          	beq	s1,s5,800021f6 <fork+0xc6>
    if(p->ofile[i])
    800021e4:	6088                	ld	a0,0(s1)
    800021e6:	d97d                	beqz	a0,800021dc <fork+0xac>
      np->ofile[i] = filedup(p->ofile[i]);
    800021e8:	00003097          	auipc	ra,0x3
    800021ec:	284080e7          	jalr	644(ra) # 8000546c <filedup>
    800021f0:	00aa3023          	sd	a0,0(s4)
    800021f4:	b7e5                	j	800021dc <fork+0xac>
  np->cwd = idup(p->cwd);
    800021f6:	0d09b503          	ld	a0,208(s3)
    800021fa:	00002097          	auipc	ra,0x2
    800021fe:	3e6080e7          	jalr	998(ra) # 800045e0 <idup>
    80002202:	0ca93823          	sd	a0,208(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002206:	4641                	li	a2,16
    80002208:	0d898593          	addi	a1,s3,216
    8000220c:	0d890513          	addi	a0,s2,216
    80002210:	fffff097          	auipc	ra,0xfffff
    80002214:	c1a080e7          	jalr	-998(ra) # 80000e2a <safestrcpy>
  np->signal_mask = p->signal_mask;
    80002218:	0ec9a783          	lw	a5,236(s3)
    8000221c:	0ef92623          	sw	a5,236(s2)
  for(int i=0;i<32;i++){
    80002220:	0f898693          	addi	a3,s3,248
    80002224:	0f890713          	addi	a4,s2,248
  np->signal_mask = p->signal_mask;
    80002228:	1f800793          	li	a5,504
  for(int i=0;i<32;i++){
    8000222c:	27800513          	li	a0,632
    np->signal_handlers[i] = p->signal_handlers[i];
    80002230:	6290                	ld	a2,0(a3)
    80002232:	e310                	sd	a2,0(a4)
    np->handlers_sigmasks[i] = p->handlers_sigmasks[i];
    80002234:	00f98633          	add	a2,s3,a5
    80002238:	420c                	lw	a1,0(a2)
    8000223a:	00f90633          	add	a2,s2,a5
    8000223e:	c20c                	sw	a1,0(a2)
  for(int i=0;i<32;i++){
    80002240:	06a1                	addi	a3,a3,8
    80002242:	0721                	addi	a4,a4,8
    80002244:	0791                	addi	a5,a5,4
    80002246:	fea795e3          	bne	a5,a0,80002230 <fork+0x100>
  np-> pending_signals=0;
    8000224a:	0e092423          	sw	zero,232(s2)
  pid = np->pid;
    8000224e:	02492a83          	lw	s5,36(s2)
  release(&np_first_thread->lock);
    80002252:	28890493          	addi	s1,s2,648
    80002256:	8526                	mv	a0,s1
    80002258:	fffff097          	auipc	ra,0xfffff
    8000225c:	a38080e7          	jalr	-1480(ra) # 80000c90 <release>
  release(&np->lock);
    80002260:	854a                	mv	a0,s2
    80002262:	fffff097          	auipc	ra,0xfffff
    80002266:	a2e080e7          	jalr	-1490(ra) # 80000c90 <release>
  acquire(&wait_lock);
    8000226a:	0000fa17          	auipc	s4,0xf
    8000226e:	066a0a13          	addi	s4,s4,102 # 800112d0 <wait_lock>
    80002272:	8552                	mv	a0,s4
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	952080e7          	jalr	-1710(ra) # 80000bc6 <acquire>
  np->parent = p;
    8000227c:	03393823          	sd	s3,48(s2)
  release(&wait_lock);
    80002280:	8552                	mv	a0,s4
    80002282:	fffff097          	auipc	ra,0xfffff
    80002286:	a0e080e7          	jalr	-1522(ra) # 80000c90 <release>
  acquire(&np->lock);
    8000228a:	854a                	mv	a0,s2
    8000228c:	fffff097          	auipc	ra,0xfffff
    80002290:	93a080e7          	jalr	-1734(ra) # 80000bc6 <acquire>
  acquire(&np_first_thread->lock);
    80002294:	8526                	mv	a0,s1
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	930080e7          	jalr	-1744(ra) # 80000bc6 <acquire>
  np->state = RUNNABLE;   //TOOD: check if we still need this state or should change
    8000229e:	4789                	li	a5,2
    800022a0:	00f92c23          	sw	a5,24(s2)
  np_first_thread->state = TRUNNABLE;
    800022a4:	478d                	li	a5,3
    800022a6:	2af92023          	sw	a5,672(s2)
  release(&np_first_thread->lock);
    800022aa:	8526                	mv	a0,s1
    800022ac:	fffff097          	auipc	ra,0xfffff
    800022b0:	9e4080e7          	jalr	-1564(ra) # 80000c90 <release>
  release(&np->lock);
    800022b4:	854a                	mv	a0,s2
    800022b6:	fffff097          	auipc	ra,0xfffff
    800022ba:	9da080e7          	jalr	-1574(ra) # 80000c90 <release>
}
    800022be:	8556                	mv	a0,s5
    800022c0:	70e2                	ld	ra,56(sp)
    800022c2:	7442                	ld	s0,48(sp)
    800022c4:	74a2                	ld	s1,40(sp)
    800022c6:	7902                	ld	s2,32(sp)
    800022c8:	69e2                	ld	s3,24(sp)
    800022ca:	6a42                	ld	s4,16(sp)
    800022cc:	6aa2                	ld	s5,8(sp)
    800022ce:	6121                	addi	sp,sp,64
    800022d0:	8082                	ret
    return -1;
    800022d2:	5afd                	li	s5,-1
    800022d4:	b7ed                	j	800022be <fork+0x18e>

00000000800022d6 <scheduler>:
{
    800022d6:	711d                	addi	sp,sp,-96
    800022d8:	ec86                	sd	ra,88(sp)
    800022da:	e8a2                	sd	s0,80(sp)
    800022dc:	e4a6                	sd	s1,72(sp)
    800022de:	e0ca                	sd	s2,64(sp)
    800022e0:	fc4e                	sd	s3,56(sp)
    800022e2:	f852                	sd	s4,48(sp)
    800022e4:	f456                	sd	s5,40(sp)
    800022e6:	f05a                	sd	s6,32(sp)
    800022e8:	ec5e                	sd	s7,24(sp)
    800022ea:	e862                	sd	s8,16(sp)
    800022ec:	e466                	sd	s9,8(sp)
    800022ee:	1080                	addi	s0,sp,96
    800022f0:	8792                	mv	a5,tp
  int id = r_tp();
    800022f2:	2781                	sext.w	a5,a5
  c->proc = 0;
    800022f4:	00479713          	slli	a4,a5,0x4
    800022f8:	00f706b3          	add	a3,a4,a5
    800022fc:	00369613          	slli	a2,a3,0x3
    80002300:	0000f697          	auipc	a3,0xf
    80002304:	fa068693          	addi	a3,a3,-96 # 800112a0 <pid_lock>
    80002308:	96b2                	add	a3,a3,a2
    8000230a:	0406b423          	sd	zero,72(a3)
  c->kthread=0;
    8000230e:	0c06b423          	sd	zero,200(a3)
            swtch(&c->context, &t->context);
    80002312:	0000f717          	auipc	a4,0xf
    80002316:	fde70713          	addi	a4,a4,-34 # 800112f0 <cpus+0x8>
    8000231a:	00e60bb3          	add	s7,a2,a4
            c->proc = p;
    8000231e:	8b36                	mv	s6,a3
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002320:	6a85                	lui	s5,0x1
    80002322:	848a8a93          	addi	s5,s5,-1976 # 848 <_entry-0x7ffff7b8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002326:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000232a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000232e:	10079073          	csrw	sstatus,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002332:	0000f917          	auipc	s2,0xf
    80002336:	3f690913          	addi	s2,s2,1014 # 80011728 <proc>
    8000233a:	a8a9                	j	80002394 <scheduler+0xbe>
          release(&t->lock);
    8000233c:	8526                	mv	a0,s1
    8000233e:	fffff097          	auipc	ra,0xfffff
    80002342:	952080e7          	jalr	-1710(ra) # 80000c90 <release>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002346:	0b848493          	addi	s1,s1,184
    8000234a:	03348e63          	beq	s1,s3,80002386 <scheduler+0xb0>
          acquire(&t->lock);
    8000234e:	8526                	mv	a0,s1
    80002350:	fffff097          	auipc	ra,0xfffff
    80002354:	876080e7          	jalr	-1930(ra) # 80000bc6 <acquire>
          if(t->state == TRUNNABLE && !t->frozen) {
    80002358:	4c9c                	lw	a5,24(s1)
    8000235a:	ff4791e3          	bne	a5,s4,8000233c <scheduler+0x66>
    8000235e:	58dc                	lw	a5,52(s1)
    80002360:	fff1                	bnez	a5,8000233c <scheduler+0x66>
            t->state = TRUNNING;
    80002362:	0194ac23          	sw	s9,24(s1)
            c->proc = p;
    80002366:	052b3423          	sd	s2,72(s6)
            c->kthread = t;
    8000236a:	0c9b3423          	sd	s1,200(s6)
            swtch(&c->context, &t->context);
    8000236e:	04848593          	addi	a1,s1,72
    80002372:	855e                	mv	a0,s7
    80002374:	00001097          	auipc	ra,0x1
    80002378:	d06080e7          	jalr	-762(ra) # 8000307a <swtch>
            c->proc = 0;
    8000237c:	040b3423          	sd	zero,72(s6)
            c->kthread=0;
    80002380:	0c0b3423          	sd	zero,200(s6)
    80002384:	bf65                	j	8000233c <scheduler+0x66>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002386:	9956                	add	s2,s2,s5
    80002388:	00030797          	auipc	a5,0x30
    8000238c:	5a078793          	addi	a5,a5,1440 # 80032928 <tickslock>
    80002390:	f8f90be3          	beq	s2,a5,80002326 <scheduler+0x50>
      if(p->state == RUNNABLE) {
    80002394:	01892703          	lw	a4,24(s2)
    80002398:	4789                	li	a5,2
    8000239a:	fef716e3          	bne	a4,a5,80002386 <scheduler+0xb0>
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    8000239e:	28890493          	addi	s1,s2,648
          if(t->state == TRUNNABLE && !t->frozen) {
    800023a2:	4a0d                	li	s4,3
            t->state = TRUNNING;
    800023a4:	4c91                	li	s9,4
        for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    800023a6:	015909b3          	add	s3,s2,s5
    800023aa:	b755                	j	8000234e <scheduler+0x78>

00000000800023ac <sched>:
{
    800023ac:	7179                	addi	sp,sp,-48
    800023ae:	f406                	sd	ra,40(sp)
    800023b0:	f022                	sd	s0,32(sp)
    800023b2:	ec26                	sd	s1,24(sp)
    800023b4:	e84a                	sd	s2,16(sp)
    800023b6:	e44e                	sd	s3,8(sp)
    800023b8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800023ba:	fffff097          	auipc	ra,0xfffff
    800023be:	6e6080e7          	jalr	1766(ra) # 80001aa0 <myproc>
  struct kthread *t=mykthread();
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	71e080e7          	jalr	1822(ra) # 80001ae0 <mykthread>
    800023ca:	84aa                	mv	s1,a0
  if(!holding(&t->lock))
    800023cc:	ffffe097          	auipc	ra,0xffffe
    800023d0:	780080e7          	jalr	1920(ra) # 80000b4c <holding>
    800023d4:	c959                	beqz	a0,8000246a <sched+0xbe>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023d6:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800023d8:	0007871b          	sext.w	a4,a5
    800023dc:	00471793          	slli	a5,a4,0x4
    800023e0:	97ba                	add	a5,a5,a4
    800023e2:	078e                	slli	a5,a5,0x3
    800023e4:	0000f717          	auipc	a4,0xf
    800023e8:	ebc70713          	addi	a4,a4,-324 # 800112a0 <pid_lock>
    800023ec:	97ba                	add	a5,a5,a4
    800023ee:	0c07a703          	lw	a4,192(a5)
    800023f2:	4785                	li	a5,1
    800023f4:	08f71363          	bne	a4,a5,8000247a <sched+0xce>
  if(t->state == TRUNNING)
    800023f8:	4c98                	lw	a4,24(s1)
    800023fa:	4791                	li	a5,4
    800023fc:	08f70763          	beq	a4,a5,8000248a <sched+0xde>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002400:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002404:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002406:	ebd1                	bnez	a5,8000249a <sched+0xee>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002408:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000240a:	0000f917          	auipc	s2,0xf
    8000240e:	e9690913          	addi	s2,s2,-362 # 800112a0 <pid_lock>
    80002412:	0007871b          	sext.w	a4,a5
    80002416:	00471793          	slli	a5,a4,0x4
    8000241a:	97ba                	add	a5,a5,a4
    8000241c:	078e                	slli	a5,a5,0x3
    8000241e:	97ca                	add	a5,a5,s2
    80002420:	0c47a983          	lw	s3,196(a5)
    80002424:	8792                	mv	a5,tp
  swtch(&t->context, &mycpu()->context);
    80002426:	0007859b          	sext.w	a1,a5
    8000242a:	00459793          	slli	a5,a1,0x4
    8000242e:	97ae                	add	a5,a5,a1
    80002430:	078e                	slli	a5,a5,0x3
    80002432:	0000f597          	auipc	a1,0xf
    80002436:	ebe58593          	addi	a1,a1,-322 # 800112f0 <cpus+0x8>
    8000243a:	95be                	add	a1,a1,a5
    8000243c:	04848513          	addi	a0,s1,72
    80002440:	00001097          	auipc	ra,0x1
    80002444:	c3a080e7          	jalr	-966(ra) # 8000307a <swtch>
    80002448:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000244a:	0007871b          	sext.w	a4,a5
    8000244e:	00471793          	slli	a5,a4,0x4
    80002452:	97ba                	add	a5,a5,a4
    80002454:	078e                	slli	a5,a5,0x3
    80002456:	97ca                	add	a5,a5,s2
    80002458:	0d37a223          	sw	s3,196(a5)
}
    8000245c:	70a2                	ld	ra,40(sp)
    8000245e:	7402                	ld	s0,32(sp)
    80002460:	64e2                	ld	s1,24(sp)
    80002462:	6942                	ld	s2,16(sp)
    80002464:	69a2                	ld	s3,8(sp)
    80002466:	6145                	addi	sp,sp,48
    80002468:	8082                	ret
    panic("sched t->lock");
    8000246a:	00006517          	auipc	a0,0x6
    8000246e:	f3650513          	addi	a0,a0,-202 # 800083a0 <digits+0x360>
    80002472:	ffffe097          	auipc	ra,0xffffe
    80002476:	0bc080e7          	jalr	188(ra) # 8000052e <panic>
    panic("sched locks");
    8000247a:	00006517          	auipc	a0,0x6
    8000247e:	f3650513          	addi	a0,a0,-202 # 800083b0 <digits+0x370>
    80002482:	ffffe097          	auipc	ra,0xffffe
    80002486:	0ac080e7          	jalr	172(ra) # 8000052e <panic>
    panic("sched running");
    8000248a:	00006517          	auipc	a0,0x6
    8000248e:	f3650513          	addi	a0,a0,-202 # 800083c0 <digits+0x380>
    80002492:	ffffe097          	auipc	ra,0xffffe
    80002496:	09c080e7          	jalr	156(ra) # 8000052e <panic>
    panic("sched interruptible");
    8000249a:	00006517          	auipc	a0,0x6
    8000249e:	f3650513          	addi	a0,a0,-202 # 800083d0 <digits+0x390>
    800024a2:	ffffe097          	auipc	ra,0xffffe
    800024a6:	08c080e7          	jalr	140(ra) # 8000052e <panic>

00000000800024aa <yield>:
{
    800024aa:	1101                	addi	sp,sp,-32
    800024ac:	ec06                	sd	ra,24(sp)
    800024ae:	e822                	sd	s0,16(sp)
    800024b0:	e426                	sd	s1,8(sp)
    800024b2:	1000                	addi	s0,sp,32
  struct kthread *t =mykthread();
    800024b4:	fffff097          	auipc	ra,0xfffff
    800024b8:	62c080e7          	jalr	1580(ra) # 80001ae0 <mykthread>
    800024bc:	84aa                	mv	s1,a0
  acquire(&t->lock);
    800024be:	ffffe097          	auipc	ra,0xffffe
    800024c2:	708080e7          	jalr	1800(ra) # 80000bc6 <acquire>
  t->state = TRUNNABLE;
    800024c6:	478d                	li	a5,3
    800024c8:	cc9c                	sw	a5,24(s1)
  sched();
    800024ca:	00000097          	auipc	ra,0x0
    800024ce:	ee2080e7          	jalr	-286(ra) # 800023ac <sched>
  release(&t->lock);
    800024d2:	8526                	mv	a0,s1
    800024d4:	ffffe097          	auipc	ra,0xffffe
    800024d8:	7bc080e7          	jalr	1980(ra) # 80000c90 <release>
}
    800024dc:	60e2                	ld	ra,24(sp)
    800024de:	6442                	ld	s0,16(sp)
    800024e0:	64a2                	ld	s1,8(sp)
    800024e2:	6105                	addi	sp,sp,32
    800024e4:	8082                	ret

00000000800024e6 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800024e6:	7179                	addi	sp,sp,-48
    800024e8:	f406                	sd	ra,40(sp)
    800024ea:	f022                	sd	s0,32(sp)
    800024ec:	ec26                	sd	s1,24(sp)
    800024ee:	e84a                	sd	s2,16(sp)
    800024f0:	e44e                	sd	s3,8(sp)
    800024f2:	1800                	addi	s0,sp,48
    800024f4:	89aa                	mv	s3,a0
    800024f6:	892e                	mv	s2,a1
  // struct proc *p = myproc();
  struct kthread *t=mykthread();
    800024f8:	fffff097          	auipc	ra,0xfffff
    800024fc:	5e8080e7          	jalr	1512(ra) # 80001ae0 <mykthread>
    80002500:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&t->lock);  //DOC: sleeplock1
    80002502:	ffffe097          	auipc	ra,0xffffe
    80002506:	6c4080e7          	jalr	1732(ra) # 80000bc6 <acquire>
  release(lk);
    8000250a:	854a                	mv	a0,s2
    8000250c:	ffffe097          	auipc	ra,0xffffe
    80002510:	784080e7          	jalr	1924(ra) # 80000c90 <release>

  // Go to sleep.
  t->chan = chan;
    80002514:	0334b023          	sd	s3,32(s1)
  t->state = TSLEEPING;
    80002518:	4789                	li	a5,2
    8000251a:	cc9c                	sw	a5,24(s1)

  sched();
    8000251c:	00000097          	auipc	ra,0x0
    80002520:	e90080e7          	jalr	-368(ra) # 800023ac <sched>

  // Tidy up.
  t->chan = 0;
    80002524:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&t->lock);
    80002528:	8526                	mv	a0,s1
    8000252a:	ffffe097          	auipc	ra,0xffffe
    8000252e:	766080e7          	jalr	1894(ra) # 80000c90 <release>
  acquire(lk);
    80002532:	854a                	mv	a0,s2
    80002534:	ffffe097          	auipc	ra,0xffffe
    80002538:	692080e7          	jalr	1682(ra) # 80000bc6 <acquire>
}
    8000253c:	70a2                	ld	ra,40(sp)
    8000253e:	7402                	ld	s0,32(sp)
    80002540:	64e2                	ld	s1,24(sp)
    80002542:	6942                	ld	s2,16(sp)
    80002544:	69a2                	ld	s3,8(sp)
    80002546:	6145                	addi	sp,sp,48
    80002548:	8082                	ret

000000008000254a <wait>:
{
    8000254a:	715d                	addi	sp,sp,-80
    8000254c:	e486                	sd	ra,72(sp)
    8000254e:	e0a2                	sd	s0,64(sp)
    80002550:	fc26                	sd	s1,56(sp)
    80002552:	f84a                	sd	s2,48(sp)
    80002554:	f44e                	sd	s3,40(sp)
    80002556:	f052                	sd	s4,32(sp)
    80002558:	ec56                	sd	s5,24(sp)
    8000255a:	e85a                	sd	s6,16(sp)
    8000255c:	e45e                	sd	s7,8(sp)
    8000255e:	0880                	addi	s0,sp,80
    80002560:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002562:	fffff097          	auipc	ra,0xfffff
    80002566:	53e080e7          	jalr	1342(ra) # 80001aa0 <myproc>
    8000256a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000256c:	0000f517          	auipc	a0,0xf
    80002570:	d6450513          	addi	a0,a0,-668 # 800112d0 <wait_lock>
    80002574:	ffffe097          	auipc	ra,0xffffe
    80002578:	652080e7          	jalr	1618(ra) # 80000bc6 <acquire>
        if(np->state == ZOMBIE){
    8000257c:	4b0d                	li	s6,3
        havekids = 1;
    8000257e:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002580:	6985                	lui	s3,0x1
    80002582:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002586:	00030a17          	auipc	s4,0x30
    8000258a:	3a2a0a13          	addi	s4,s4,930 # 80032928 <tickslock>
    havekids = 0;
    8000258e:	4701                	li	a4,0
    for(np = proc; np < &proc[NPROC]; np++){
    80002590:	0000f497          	auipc	s1,0xf
    80002594:	19848493          	addi	s1,s1,408 # 80011728 <proc>
    80002598:	a0b5                	j	80002604 <wait+0xba>
          pid = np->pid;
    8000259a:	0244a983          	lw	s3,36(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    8000259e:	000b8e63          	beqz	s7,800025ba <wait+0x70>
    800025a2:	4691                	li	a3,4
    800025a4:	02048613          	addi	a2,s1,32
    800025a8:	85de                	mv	a1,s7
    800025aa:	04093503          	ld	a0,64(s2)
    800025ae:	fffff097          	auipc	ra,0xfffff
    800025b2:	0da080e7          	jalr	218(ra) # 80001688 <copyout>
    800025b6:	02054563          	bltz	a0,800025e0 <wait+0x96>
          freeproc(np);
    800025ba:	8526                	mv	a0,s1
    800025bc:	fffff097          	auipc	ra,0xfffff
    800025c0:	790080e7          	jalr	1936(ra) # 80001d4c <freeproc>
          release(&np->lock);
    800025c4:	8526                	mv	a0,s1
    800025c6:	ffffe097          	auipc	ra,0xffffe
    800025ca:	6ca080e7          	jalr	1738(ra) # 80000c90 <release>
          release(&wait_lock);
    800025ce:	0000f517          	auipc	a0,0xf
    800025d2:	d0250513          	addi	a0,a0,-766 # 800112d0 <wait_lock>
    800025d6:	ffffe097          	auipc	ra,0xffffe
    800025da:	6ba080e7          	jalr	1722(ra) # 80000c90 <release>
          return pid;
    800025de:	a09d                	j	80002644 <wait+0xfa>
            release(&np->lock);
    800025e0:	8526                	mv	a0,s1
    800025e2:	ffffe097          	auipc	ra,0xffffe
    800025e6:	6ae080e7          	jalr	1710(ra) # 80000c90 <release>
            release(&wait_lock);
    800025ea:	0000f517          	auipc	a0,0xf
    800025ee:	ce650513          	addi	a0,a0,-794 # 800112d0 <wait_lock>
    800025f2:	ffffe097          	auipc	ra,0xffffe
    800025f6:	69e080e7          	jalr	1694(ra) # 80000c90 <release>
            return -1;
    800025fa:	59fd                	li	s3,-1
    800025fc:	a0a1                	j	80002644 <wait+0xfa>
    for(np = proc; np < &proc[NPROC]; np++){
    800025fe:	94ce                	add	s1,s1,s3
    80002600:	03448463          	beq	s1,s4,80002628 <wait+0xde>
      if(np->parent == p){
    80002604:	789c                	ld	a5,48(s1)
    80002606:	ff279ce3          	bne	a5,s2,800025fe <wait+0xb4>
        acquire(&np->lock);
    8000260a:	8526                	mv	a0,s1
    8000260c:	ffffe097          	auipc	ra,0xffffe
    80002610:	5ba080e7          	jalr	1466(ra) # 80000bc6 <acquire>
        if(np->state == ZOMBIE){
    80002614:	4c9c                	lw	a5,24(s1)
    80002616:	f96782e3          	beq	a5,s6,8000259a <wait+0x50>
        release(&np->lock);
    8000261a:	8526                	mv	a0,s1
    8000261c:	ffffe097          	auipc	ra,0xffffe
    80002620:	674080e7          	jalr	1652(ra) # 80000c90 <release>
        havekids = 1;
    80002624:	8756                	mv	a4,s5
    80002626:	bfe1                	j	800025fe <wait+0xb4>
    if(!havekids || p->killed==1){
    80002628:	c709                	beqz	a4,80002632 <wait+0xe8>
    8000262a:	01c92783          	lw	a5,28(s2)
    8000262e:	03579763          	bne	a5,s5,8000265c <wait+0x112>
      release(&wait_lock);
    80002632:	0000f517          	auipc	a0,0xf
    80002636:	c9e50513          	addi	a0,a0,-866 # 800112d0 <wait_lock>
    8000263a:	ffffe097          	auipc	ra,0xffffe
    8000263e:	656080e7          	jalr	1622(ra) # 80000c90 <release>
      return -1;
    80002642:	59fd                	li	s3,-1
}
    80002644:	854e                	mv	a0,s3
    80002646:	60a6                	ld	ra,72(sp)
    80002648:	6406                	ld	s0,64(sp)
    8000264a:	74e2                	ld	s1,56(sp)
    8000264c:	7942                	ld	s2,48(sp)
    8000264e:	79a2                	ld	s3,40(sp)
    80002650:	7a02                	ld	s4,32(sp)
    80002652:	6ae2                	ld	s5,24(sp)
    80002654:	6b42                	ld	s6,16(sp)
    80002656:	6ba2                	ld	s7,8(sp)
    80002658:	6161                	addi	sp,sp,80
    8000265a:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000265c:	0000f597          	auipc	a1,0xf
    80002660:	c7458593          	addi	a1,a1,-908 # 800112d0 <wait_lock>
    80002664:	854a                	mv	a0,s2
    80002666:	00000097          	auipc	ra,0x0
    8000266a:	e80080e7          	jalr	-384(ra) # 800024e6 <sleep>
    havekids = 0;
    8000266e:	b705                	j	8000258e <wait+0x44>

0000000080002670 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002670:	711d                	addi	sp,sp,-96
    80002672:	ec86                	sd	ra,88(sp)
    80002674:	e8a2                	sd	s0,80(sp)
    80002676:	e4a6                	sd	s1,72(sp)
    80002678:	e0ca                	sd	s2,64(sp)
    8000267a:	fc4e                	sd	s3,56(sp)
    8000267c:	f852                	sd	s4,48(sp)
    8000267e:	f456                	sd	s5,40(sp)
    80002680:	f05a                	sd	s6,32(sp)
    80002682:	ec5e                	sd	s7,24(sp)
    80002684:	e862                	sd	s8,16(sp)
    80002686:	e466                	sd	s9,8(sp)
    80002688:	1080                	addi	s0,sp,96
    8000268a:	8c2a                	mv	s8,a0
  struct proc *p;
  struct kthread *t;
  struct kthread *my_t = mykthread();
    8000268c:	fffff097          	auipc	ra,0xfffff
    80002690:	454080e7          	jalr	1108(ra) # 80001ae0 <mykthread>
    80002694:	8aaa                	mv	s5,a0

  for(p = proc; p < &proc[NPROC]; p++) {
    80002696:	0000f917          	auipc	s2,0xf
    8000269a:	31a90913          	addi	s2,s2,794 # 800119b0 <proc+0x288>
    8000269e:	00030b97          	auipc	s7,0x30
    800026a2:	512b8b93          	addi	s7,s7,1298 # 80032bb0 <bcache+0x270>
    if(p->state == RUNNABLE){
    800026a6:	4989                	li	s3,2
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
        if(t != my_t){
          acquire(&t->lock);
          if(t->state == TSLEEPING && t->chan == chan) {
            t->state = TRUNNABLE;
    800026a8:	4c8d                	li	s9,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800026aa:	6b05                	lui	s6,0x1
    800026ac:	848b0b13          	addi	s6,s6,-1976 # 848 <_entry-0x7ffff7b8>
    800026b0:	a82d                	j	800026ea <wakeup+0x7a>
          }
          release(&t->lock);
    800026b2:	8526                	mv	a0,s1
    800026b4:	ffffe097          	auipc	ra,0xffffe
    800026b8:	5dc080e7          	jalr	1500(ra) # 80000c90 <release>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800026bc:	0b848493          	addi	s1,s1,184
    800026c0:	03448263          	beq	s1,s4,800026e4 <wakeup+0x74>
        if(t != my_t){
    800026c4:	fe9a8ce3          	beq	s5,s1,800026bc <wakeup+0x4c>
          acquire(&t->lock);
    800026c8:	8526                	mv	a0,s1
    800026ca:	ffffe097          	auipc	ra,0xffffe
    800026ce:	4fc080e7          	jalr	1276(ra) # 80000bc6 <acquire>
          if(t->state == TSLEEPING && t->chan == chan) {
    800026d2:	4c9c                	lw	a5,24(s1)
    800026d4:	fd379fe3          	bne	a5,s3,800026b2 <wakeup+0x42>
    800026d8:	709c                	ld	a5,32(s1)
    800026da:	fd879ce3          	bne	a5,s8,800026b2 <wakeup+0x42>
            t->state = TRUNNABLE;
    800026de:	0194ac23          	sw	s9,24(s1)
    800026e2:	bfc1                	j	800026b2 <wakeup+0x42>
  for(p = proc; p < &proc[NPROC]; p++) {
    800026e4:	995a                	add	s2,s2,s6
    800026e6:	01790a63          	beq	s2,s7,800026fa <wakeup+0x8a>
    if(p->state == RUNNABLE){
    800026ea:	84ca                	mv	s1,s2
    800026ec:	d9092783          	lw	a5,-624(s2)
    800026f0:	ff379ae3          	bne	a5,s3,800026e4 <wakeup+0x74>
      for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800026f4:	5c090a13          	addi	s4,s2,1472
    800026f8:	b7f1                	j	800026c4 <wakeup+0x54>
        }
      }
    }
  }
}
    800026fa:	60e6                	ld	ra,88(sp)
    800026fc:	6446                	ld	s0,80(sp)
    800026fe:	64a6                	ld	s1,72(sp)
    80002700:	6906                	ld	s2,64(sp)
    80002702:	79e2                	ld	s3,56(sp)
    80002704:	7a42                	ld	s4,48(sp)
    80002706:	7aa2                	ld	s5,40(sp)
    80002708:	7b02                	ld	s6,32(sp)
    8000270a:	6be2                	ld	s7,24(sp)
    8000270c:	6c42                	ld	s8,16(sp)
    8000270e:	6ca2                	ld	s9,8(sp)
    80002710:	6125                	addi	sp,sp,96
    80002712:	8082                	ret

0000000080002714 <reparent>:
{
    80002714:	7139                	addi	sp,sp,-64
    80002716:	fc06                	sd	ra,56(sp)
    80002718:	f822                	sd	s0,48(sp)
    8000271a:	f426                	sd	s1,40(sp)
    8000271c:	f04a                	sd	s2,32(sp)
    8000271e:	ec4e                	sd	s3,24(sp)
    80002720:	e852                	sd	s4,16(sp)
    80002722:	e456                	sd	s5,8(sp)
    80002724:	0080                	addi	s0,sp,64
    80002726:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002728:	0000f497          	auipc	s1,0xf
    8000272c:	00048493          	mv	s1,s1
      pp->parent = initproc;
    80002730:	00007a97          	auipc	s5,0x7
    80002734:	8f8a8a93          	addi	s5,s5,-1800 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002738:	6905                	lui	s2,0x1
    8000273a:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    8000273e:	00030a17          	auipc	s4,0x30
    80002742:	1eaa0a13          	addi	s4,s4,490 # 80032928 <tickslock>
    80002746:	a021                	j	8000274e <reparent+0x3a>
    80002748:	94ca                	add	s1,s1,s2
    8000274a:	01448d63          	beq	s1,s4,80002764 <reparent+0x50>
    if(pp->parent == p){
    8000274e:	789c                	ld	a5,48(s1)
    80002750:	ff379ce3          	bne	a5,s3,80002748 <reparent+0x34>
      pp->parent = initproc;
    80002754:	000ab503          	ld	a0,0(s5)
    80002758:	f888                	sd	a0,48(s1)
      wakeup(initproc);
    8000275a:	00000097          	auipc	ra,0x0
    8000275e:	f16080e7          	jalr	-234(ra) # 80002670 <wakeup>
    80002762:	b7dd                	j	80002748 <reparent+0x34>
}
    80002764:	70e2                	ld	ra,56(sp)
    80002766:	7442                	ld	s0,48(sp)
    80002768:	74a2                	ld	s1,40(sp)
    8000276a:	7902                	ld	s2,32(sp)
    8000276c:	69e2                	ld	s3,24(sp)
    8000276e:	6a42                	ld	s4,16(sp)
    80002770:	6aa2                	ld	s5,8(sp)
    80002772:	6121                	addi	sp,sp,64
    80002774:	8082                	ret

0000000080002776 <exit_proccess>:
{
    80002776:	7139                	addi	sp,sp,-64
    80002778:	fc06                	sd	ra,56(sp)
    8000277a:	f822                	sd	s0,48(sp)
    8000277c:	f426                	sd	s1,40(sp)
    8000277e:	f04a                	sd	s2,32(sp)
    80002780:	ec4e                	sd	s3,24(sp)
    80002782:	e852                	sd	s4,16(sp)
    80002784:	e456                	sd	s5,8(sp)
    80002786:	0080                	addi	s0,sp,64
    80002788:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    8000278a:	fffff097          	auipc	ra,0xfffff
    8000278e:	316080e7          	jalr	790(ra) # 80001aa0 <myproc>
    80002792:	89aa                	mv	s3,a0
  struct kthread *t = mykthread();
    80002794:	fffff097          	auipc	ra,0xfffff
    80002798:	34c080e7          	jalr	844(ra) # 80001ae0 <mykthread>
    8000279c:	8a2a                	mv	s4,a0
  if(p == initproc)
    8000279e:	00007797          	auipc	a5,0x7
    800027a2:	88a7b783          	ld	a5,-1910(a5) # 80009028 <initproc>
    800027a6:	05098493          	addi	s1,s3,80
    800027aa:	0d098913          	addi	s2,s3,208
    800027ae:	03379363          	bne	a5,s3,800027d4 <exit_proccess+0x5e>
    panic("init exiting");
    800027b2:	00006517          	auipc	a0,0x6
    800027b6:	c3650513          	addi	a0,a0,-970 # 800083e8 <digits+0x3a8>
    800027ba:	ffffe097          	auipc	ra,0xffffe
    800027be:	d74080e7          	jalr	-652(ra) # 8000052e <panic>
      fileclose(f);
    800027c2:	00003097          	auipc	ra,0x3
    800027c6:	cfc080e7          	jalr	-772(ra) # 800054be <fileclose>
      p->ofile[fd] = 0;
    800027ca:	0004b023          	sd	zero,0(s1) # 80011728 <proc>
  for(int fd = 0; fd < NOFILE; fd++){
    800027ce:	04a1                	addi	s1,s1,8
    800027d0:	01248563          	beq	s1,s2,800027da <exit_proccess+0x64>
    if(p->ofile[fd]){
    800027d4:	6088                	ld	a0,0(s1)
    800027d6:	f575                	bnez	a0,800027c2 <exit_proccess+0x4c>
    800027d8:	bfdd                	j	800027ce <exit_proccess+0x58>
  begin_op();
    800027da:	00003097          	auipc	ra,0x3
    800027de:	818080e7          	jalr	-2024(ra) # 80004ff2 <begin_op>
  iput(p->cwd);
    800027e2:	0d09b503          	ld	a0,208(s3)
    800027e6:	00002097          	auipc	ra,0x2
    800027ea:	ff2080e7          	jalr	-14(ra) # 800047d8 <iput>
  end_op();
    800027ee:	00003097          	auipc	ra,0x3
    800027f2:	884080e7          	jalr	-1916(ra) # 80005072 <end_op>
  p->cwd = 0;
    800027f6:	0c09b823          	sd	zero,208(s3)
  acquire(&wait_lock);
    800027fa:	0000f497          	auipc	s1,0xf
    800027fe:	ad648493          	addi	s1,s1,-1322 # 800112d0 <wait_lock>
    80002802:	8526                	mv	a0,s1
    80002804:	ffffe097          	auipc	ra,0xffffe
    80002808:	3c2080e7          	jalr	962(ra) # 80000bc6 <acquire>
  reparent(p);
    8000280c:	854e                	mv	a0,s3
    8000280e:	00000097          	auipc	ra,0x0
    80002812:	f06080e7          	jalr	-250(ra) # 80002714 <reparent>
  wakeup(p->parent);
    80002816:	0309b503          	ld	a0,48(s3)
    8000281a:	00000097          	auipc	ra,0x0
    8000281e:	e56080e7          	jalr	-426(ra) # 80002670 <wakeup>
  acquire(&p->lock);
    80002822:	854e                	mv	a0,s3
    80002824:	ffffe097          	auipc	ra,0xffffe
    80002828:	3a2080e7          	jalr	930(ra) # 80000bc6 <acquire>
  p->xstate = status;
    8000282c:	0359a023          	sw	s5,32(s3)
  p->state = ZOMBIE;
    80002830:	478d                	li	a5,3
    80002832:	00f9ac23          	sw	a5,24(s3)
  release(&p->lock);// we added
    80002836:	854e                	mv	a0,s3
    80002838:	ffffe097          	auipc	ra,0xffffe
    8000283c:	458080e7          	jalr	1112(ra) # 80000c90 <release>
  release(&wait_lock);
    80002840:	8526                	mv	a0,s1
    80002842:	ffffe097          	auipc	ra,0xffffe
    80002846:	44e080e7          	jalr	1102(ra) # 80000c90 <release>
  acquire(&t->lock);
    8000284a:	8552                	mv	a0,s4
    8000284c:	ffffe097          	auipc	ra,0xffffe
    80002850:	37a080e7          	jalr	890(ra) # 80000bc6 <acquire>
  sched();
    80002854:	00000097          	auipc	ra,0x0
    80002858:	b58080e7          	jalr	-1192(ra) # 800023ac <sched>
  panic("zombie exit");
    8000285c:	00006517          	auipc	a0,0x6
    80002860:	b9c50513          	addi	a0,a0,-1124 # 800083f8 <digits+0x3b8>
    80002864:	ffffe097          	auipc	ra,0xffffe
    80002868:	cca080e7          	jalr	-822(ra) # 8000052e <panic>

000000008000286c <kthread_exit>:
kthread_exit(int status){
    8000286c:	7179                	addi	sp,sp,-48
    8000286e:	f406                	sd	ra,40(sp)
    80002870:	f022                	sd	s0,32(sp)
    80002872:	ec26                	sd	s1,24(sp)
    80002874:	e84a                	sd	s2,16(sp)
    80002876:	e44e                	sd	s3,8(sp)
    80002878:	e052                	sd	s4,0(sp)
    8000287a:	1800                	addi	s0,sp,48
    8000287c:	89aa                	mv	s3,a0
  struct proc *p = myproc(); 
    8000287e:	fffff097          	auipc	ra,0xfffff
    80002882:	222080e7          	jalr	546(ra) # 80001aa0 <myproc>
    80002886:	892a                	mv	s2,a0
  struct kthread *t=mykthread();
    80002888:	fffff097          	auipc	ra,0xfffff
    8000288c:	258080e7          	jalr	600(ra) # 80001ae0 <mykthread>
    80002890:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002892:	854a                	mv	a0,s2
    80002894:	ffffe097          	auipc	ra,0xffffe
    80002898:	332080e7          	jalr	818(ra) # 80000bc6 <acquire>
  p->active_threads--;
    8000289c:	02892783          	lw	a5,40(s2)
    800028a0:	37fd                	addiw	a5,a5,-1
    800028a2:	00078a1b          	sext.w	s4,a5
    800028a6:	02f92423          	sw	a5,40(s2)
  release(&p->lock);
    800028aa:	854a                	mv	a0,s2
    800028ac:	ffffe097          	auipc	ra,0xffffe
    800028b0:	3e4080e7          	jalr	996(ra) # 80000c90 <release>
  acquire(&t->lock);
    800028b4:	8526                	mv	a0,s1
    800028b6:	ffffe097          	auipc	ra,0xffffe
    800028ba:	310080e7          	jalr	784(ra) # 80000bc6 <acquire>
  t->xstate = status;
    800028be:	0334a623          	sw	s3,44(s1)
  t->state  = TUNUSED;
    800028c2:	0004ac23          	sw	zero,24(s1)
  wakeup(t);
    800028c6:	8526                	mv	a0,s1
    800028c8:	00000097          	auipc	ra,0x0
    800028cc:	da8080e7          	jalr	-600(ra) # 80002670 <wakeup>
  if(curr_active_threads==0){
    800028d0:	000a1c63          	bnez	s4,800028e8 <kthread_exit+0x7c>
    release(&t->lock);
    800028d4:	8526                	mv	a0,s1
    800028d6:	ffffe097          	auipc	ra,0xffffe
    800028da:	3ba080e7          	jalr	954(ra) # 80000c90 <release>
    exit_proccess(status);
    800028de:	854e                	mv	a0,s3
    800028e0:	00000097          	auipc	ra,0x0
    800028e4:	e96080e7          	jalr	-362(ra) # 80002776 <exit_proccess>
    sched();
    800028e8:	00000097          	auipc	ra,0x0
    800028ec:	ac4080e7          	jalr	-1340(ra) # 800023ac <sched>
    panic("zombie thread exit");
    800028f0:	00006517          	auipc	a0,0x6
    800028f4:	b1850513          	addi	a0,a0,-1256 # 80008408 <digits+0x3c8>
    800028f8:	ffffe097          	auipc	ra,0xffffe
    800028fc:	c36080e7          	jalr	-970(ra) # 8000052e <panic>

0000000080002900 <exit>:
exit(int status){
    80002900:	7139                	addi	sp,sp,-64
    80002902:	fc06                	sd	ra,56(sp)
    80002904:	f822                	sd	s0,48(sp)
    80002906:	f426                	sd	s1,40(sp)
    80002908:	f04a                	sd	s2,32(sp)
    8000290a:	ec4e                	sd	s3,24(sp)
    8000290c:	e852                	sd	s4,16(sp)
    8000290e:	e456                	sd	s5,8(sp)
    80002910:	e05a                	sd	s6,0(sp)
    80002912:	0080                	addi	s0,sp,64
    80002914:	8aaa                	mv	s5,a0
  struct proc *p = myproc();
    80002916:	fffff097          	auipc	ra,0xfffff
    8000291a:	18a080e7          	jalr	394(ra) # 80001aa0 <myproc>
    8000291e:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80002920:	fffff097          	auipc	ra,0xfffff
    80002924:	1c0080e7          	jalr	448(ra) # 80001ae0 <mykthread>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002928:	28890493          	addi	s1,s2,648
    8000292c:	6505                	lui	a0,0x1
    8000292e:	84850513          	addi	a0,a0,-1976 # 848 <_entry-0x7ffff7b8>
    80002932:	992a                	add	s2,s2,a0
    t->killed = 1;
    80002934:	4a05                	li	s4,1
    if(t->state == TSLEEPING)
    80002936:	4989                	li	s3,2
      t->state = TRUNNABLE;
    80002938:	4b0d                	li	s6,3
    8000293a:	a811                	j	8000294e <exit+0x4e>
    release(&t->lock);
    8000293c:	8526                	mv	a0,s1
    8000293e:	ffffe097          	auipc	ra,0xffffe
    80002942:	352080e7          	jalr	850(ra) # 80000c90 <release>
  for(t=p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002946:	0b848493          	addi	s1,s1,184
    8000294a:	00990f63          	beq	s2,s1,80002968 <exit+0x68>
    acquire(&t->lock);
    8000294e:	8526                	mv	a0,s1
    80002950:	ffffe097          	auipc	ra,0xffffe
    80002954:	276080e7          	jalr	630(ra) # 80000bc6 <acquire>
    t->killed = 1;
    80002958:	0344a423          	sw	s4,40(s1)
    if(t->state == TSLEEPING)
    8000295c:	4c9c                	lw	a5,24(s1)
    8000295e:	fd379fe3          	bne	a5,s3,8000293c <exit+0x3c>
      t->state = TRUNNABLE;
    80002962:	0164ac23          	sw	s6,24(s1)
    80002966:	bfd9                	j	8000293c <exit+0x3c>
  kthread_exit(status);
    80002968:	8556                	mv	a0,s5
    8000296a:	00000097          	auipc	ra,0x0
    8000296e:	f02080e7          	jalr	-254(ra) # 8000286c <kthread_exit>

0000000080002972 <sig_stop>:
//   return -1;
// }

int
sig_stop(int pid)//TODO delete if not used
{
    80002972:	7179                	addi	sp,sp,-48
    80002974:	f406                	sd	ra,40(sp)
    80002976:	f022                	sd	s0,32(sp)
    80002978:	ec26                	sd	s1,24(sp)
    8000297a:	e84a                	sd	s2,16(sp)
    8000297c:	e44e                	sd	s3,8(sp)
    8000297e:	e052                	sd	s4,0(sp)
    80002980:	1800                	addi	s0,sp,48
    80002982:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002984:	0000f497          	auipc	s1,0xf
    80002988:	da448493          	addi	s1,s1,-604 # 80011728 <proc>
    8000298c:	6985                	lui	s3,0x1
    8000298e:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002992:	00030a17          	auipc	s4,0x30
    80002996:	f96a0a13          	addi	s4,s4,-106 # 80032928 <tickslock>
    acquire(&p->lock);
    8000299a:	8526                	mv	a0,s1
    8000299c:	ffffe097          	auipc	ra,0xffffe
    800029a0:	22a080e7          	jalr	554(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    800029a4:	50dc                	lw	a5,36(s1)
    800029a6:	01278c63          	beq	a5,s2,800029be <sig_stop+0x4c>
      p->pending_signals|=(1<<SIGSTOP);

      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800029aa:	8526                	mv	a0,s1
    800029ac:	ffffe097          	auipc	ra,0xffffe
    800029b0:	2e4080e7          	jalr	740(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800029b4:	94ce                	add	s1,s1,s3
    800029b6:	ff4492e3          	bne	s1,s4,8000299a <sig_stop+0x28>
  }
  return -1;
    800029ba:	557d                	li	a0,-1
    800029bc:	a831                	j	800029d8 <sig_stop+0x66>
      p->pending_signals|=(1<<SIGSTOP);
    800029be:	0e84a783          	lw	a5,232(s1)
    800029c2:	00020737          	lui	a4,0x20
    800029c6:	8fd9                	or	a5,a5,a4
    800029c8:	0ef4a423          	sw	a5,232(s1)
      release(&p->lock);
    800029cc:	8526                	mv	a0,s1
    800029ce:	ffffe097          	auipc	ra,0xffffe
    800029d2:	2c2080e7          	jalr	706(ra) # 80000c90 <release>
      return 0;
    800029d6:	4501                	li	a0,0
}
    800029d8:	70a2                	ld	ra,40(sp)
    800029da:	7402                	ld	s0,32(sp)
    800029dc:	64e2                	ld	s1,24(sp)
    800029de:	6942                	ld	s2,16(sp)
    800029e0:	69a2                	ld	s3,8(sp)
    800029e2:	6a02                	ld	s4,0(sp)
    800029e4:	6145                	addi	sp,sp,48
    800029e6:	8082                	ret

00000000800029e8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800029e8:	7179                	addi	sp,sp,-48
    800029ea:	f406                	sd	ra,40(sp)
    800029ec:	f022                	sd	s0,32(sp)
    800029ee:	ec26                	sd	s1,24(sp)
    800029f0:	e84a                	sd	s2,16(sp)
    800029f2:	e44e                	sd	s3,8(sp)
    800029f4:	e052                	sd	s4,0(sp)
    800029f6:	1800                	addi	s0,sp,48
    800029f8:	84aa                	mv	s1,a0
    800029fa:	892e                	mv	s2,a1
    800029fc:	89b2                	mv	s3,a2
    800029fe:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a00:	fffff097          	auipc	ra,0xfffff
    80002a04:	0a0080e7          	jalr	160(ra) # 80001aa0 <myproc>
  if(user_dst){
    80002a08:	c08d                	beqz	s1,80002a2a <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002a0a:	86d2                	mv	a3,s4
    80002a0c:	864e                	mv	a2,s3
    80002a0e:	85ca                	mv	a1,s2
    80002a10:	6128                	ld	a0,64(a0)
    80002a12:	fffff097          	auipc	ra,0xfffff
    80002a16:	c76080e7          	jalr	-906(ra) # 80001688 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002a1a:	70a2                	ld	ra,40(sp)
    80002a1c:	7402                	ld	s0,32(sp)
    80002a1e:	64e2                	ld	s1,24(sp)
    80002a20:	6942                	ld	s2,16(sp)
    80002a22:	69a2                	ld	s3,8(sp)
    80002a24:	6a02                	ld	s4,0(sp)
    80002a26:	6145                	addi	sp,sp,48
    80002a28:	8082                	ret
    memmove((char *)dst, src, len);
    80002a2a:	000a061b          	sext.w	a2,s4
    80002a2e:	85ce                	mv	a1,s3
    80002a30:	854a                	mv	a0,s2
    80002a32:	ffffe097          	auipc	ra,0xffffe
    80002a36:	302080e7          	jalr	770(ra) # 80000d34 <memmove>
    return 0;
    80002a3a:	8526                	mv	a0,s1
    80002a3c:	bff9                	j	80002a1a <either_copyout+0x32>

0000000080002a3e <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002a3e:	7179                	addi	sp,sp,-48
    80002a40:	f406                	sd	ra,40(sp)
    80002a42:	f022                	sd	s0,32(sp)
    80002a44:	ec26                	sd	s1,24(sp)
    80002a46:	e84a                	sd	s2,16(sp)
    80002a48:	e44e                	sd	s3,8(sp)
    80002a4a:	e052                	sd	s4,0(sp)
    80002a4c:	1800                	addi	s0,sp,48
    80002a4e:	892a                	mv	s2,a0
    80002a50:	84ae                	mv	s1,a1
    80002a52:	89b2                	mv	s3,a2
    80002a54:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002a56:	fffff097          	auipc	ra,0xfffff
    80002a5a:	04a080e7          	jalr	74(ra) # 80001aa0 <myproc>
  if(user_src){
    80002a5e:	c08d                	beqz	s1,80002a80 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002a60:	86d2                	mv	a3,s4
    80002a62:	864e                	mv	a2,s3
    80002a64:	85ca                	mv	a1,s2
    80002a66:	6128                	ld	a0,64(a0)
    80002a68:	fffff097          	auipc	ra,0xfffff
    80002a6c:	cac080e7          	jalr	-852(ra) # 80001714 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002a70:	70a2                	ld	ra,40(sp)
    80002a72:	7402                	ld	s0,32(sp)
    80002a74:	64e2                	ld	s1,24(sp)
    80002a76:	6942                	ld	s2,16(sp)
    80002a78:	69a2                	ld	s3,8(sp)
    80002a7a:	6a02                	ld	s4,0(sp)
    80002a7c:	6145                	addi	sp,sp,48
    80002a7e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002a80:	000a061b          	sext.w	a2,s4
    80002a84:	85ce                	mv	a1,s3
    80002a86:	854a                	mv	a0,s2
    80002a88:	ffffe097          	auipc	ra,0xffffe
    80002a8c:	2ac080e7          	jalr	684(ra) # 80000d34 <memmove>
    return 0;
    80002a90:	8526                	mv	a0,s1
    80002a92:	bff9                	j	80002a70 <either_copyin+0x32>

0000000080002a94 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002a94:	715d                	addi	sp,sp,-80
    80002a96:	e486                	sd	ra,72(sp)
    80002a98:	e0a2                	sd	s0,64(sp)
    80002a9a:	fc26                	sd	s1,56(sp)
    80002a9c:	f84a                	sd	s2,48(sp)
    80002a9e:	f44e                	sd	s3,40(sp)
    80002aa0:	f052                	sd	s4,32(sp)
    80002aa2:	ec56                	sd	s5,24(sp)
    80002aa4:	e85a                	sd	s6,16(sp)
    80002aa6:	e45e                	sd	s7,8(sp)
    80002aa8:	e062                	sd	s8,0(sp)
    80002aaa:	0880                	addi	s0,sp,80


  struct proc *p;
  char *state;

  printf("\n");
    80002aac:	00006517          	auipc	a0,0x6
    80002ab0:	89c50513          	addi	a0,a0,-1892 # 80008348 <digits+0x308>
    80002ab4:	ffffe097          	auipc	ra,0xffffe
    80002ab8:	ac4080e7          	jalr	-1340(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002abc:	0000f497          	auipc	s1,0xf
    80002ac0:	d4448493          	addi	s1,s1,-700 # 80011800 <proc+0xd8>
    80002ac4:	00030997          	auipc	s3,0x30
    80002ac8:	f3c98993          	addi	s3,s3,-196 # 80032a00 <bcache+0xc0>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002acc:	4b8d                	li	s7,3
      state = states[p->state];
    else
      state = "???";
    80002ace:	00006a17          	auipc	s4,0x6
    80002ad2:	952a0a13          	addi	s4,s4,-1710 # 80008420 <digits+0x3e0>
    printf("%d %s %s", p->pid, state, p->name);
    80002ad6:	00006b17          	auipc	s6,0x6
    80002ada:	952b0b13          	addi	s6,s6,-1710 # 80008428 <digits+0x3e8>
    printf("\n");
    80002ade:	00006a97          	auipc	s5,0x6
    80002ae2:	86aa8a93          	addi	s5,s5,-1942 # 80008348 <digits+0x308>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002ae6:	00006c17          	auipc	s8,0x6
    80002aea:	96ac0c13          	addi	s8,s8,-1686 # 80008450 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80002aee:	6905                	lui	s2,0x1
    80002af0:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80002af4:	a005                	j	80002b14 <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    80002af6:	f4c6a583          	lw	a1,-180(a3)
    80002afa:	855a                	mv	a0,s6
    80002afc:	ffffe097          	auipc	ra,0xffffe
    80002b00:	a7c080e7          	jalr	-1412(ra) # 80000578 <printf>
    printf("\n");
    80002b04:	8556                	mv	a0,s5
    80002b06:	ffffe097          	auipc	ra,0xffffe
    80002b0a:	a72080e7          	jalr	-1422(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002b0e:	94ca                	add	s1,s1,s2
    80002b10:	03348263          	beq	s1,s3,80002b34 <procdump+0xa0>
    if(p->state == UNUSED)
    80002b14:	86a6                	mv	a3,s1
    80002b16:	f404a783          	lw	a5,-192(s1)
    80002b1a:	dbf5                	beqz	a5,80002b0e <procdump+0x7a>
      state = "???";
    80002b1c:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002b1e:	fcfbece3          	bltu	s7,a5,80002af6 <procdump+0x62>
    80002b22:	02079713          	slli	a4,a5,0x20
    80002b26:	01d75793          	srli	a5,a4,0x1d
    80002b2a:	97e2                	add	a5,a5,s8
    80002b2c:	6390                	ld	a2,0(a5)
    80002b2e:	f661                	bnez	a2,80002af6 <procdump+0x62>
      state = "???";
    80002b30:	8652                	mv	a2,s4
    80002b32:	b7d1                	j	80002af6 <procdump+0x62>
  }
}
    80002b34:	60a6                	ld	ra,72(sp)
    80002b36:	6406                	ld	s0,64(sp)
    80002b38:	74e2                	ld	s1,56(sp)
    80002b3a:	7942                	ld	s2,48(sp)
    80002b3c:	79a2                	ld	s3,40(sp)
    80002b3e:	7a02                	ld	s4,32(sp)
    80002b40:	6ae2                	ld	s5,24(sp)
    80002b42:	6b42                	ld	s6,16(sp)
    80002b44:	6ba2                	ld	s7,8(sp)
    80002b46:	6c02                	ld	s8,0(sp)
    80002b48:	6161                	addi	sp,sp,80
    80002b4a:	8082                	ret

0000000080002b4c <is_valid_sigmask>:

int 
is_valid_sigmask(int sigmask){
    80002b4c:	1141                	addi	sp,sp,-16
    80002b4e:	e422                	sd	s0,8(sp)
    80002b50:	0800                	addi	s0,sp,16
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002b52:	000207b7          	lui	a5,0x20
    80002b56:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002b5a:	8d7d                	and	a0,a0,a5
    return 0;
  return 1;
}
    80002b5c:	00153513          	seqz	a0,a0
    80002b60:	6422                	ld	s0,8(sp)
    80002b62:	0141                	addi	sp,sp,16
    80002b64:	8082                	ret

0000000080002b66 <sigprocmask>:

uint
sigprocmask(uint new_procmask){
    80002b66:	7179                	addi	sp,sp,-48
    80002b68:	f406                	sd	ra,40(sp)
    80002b6a:	f022                	sd	s0,32(sp)
    80002b6c:	ec26                	sd	s1,24(sp)
    80002b6e:	e84a                	sd	s2,16(sp)
    80002b70:	e44e                	sd	s3,8(sp)
    80002b72:	1800                	addi	s0,sp,48
    80002b74:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80002b76:	fffff097          	auipc	ra,0xfffff
    80002b7a:	f2a080e7          	jalr	-214(ra) # 80001aa0 <myproc>
  if(is_valid_sigmask(new_procmask) == 0)
    80002b7e:	000207b7          	lui	a5,0x20
    80002b82:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002b86:	00f977b3          	and	a5,s2,a5
    return -1;
    80002b8a:	59fd                	li	s3,-1
  if(is_valid_sigmask(new_procmask) == 0)
    80002b8c:	ef99                	bnez	a5,80002baa <sigprocmask+0x44>
    80002b8e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002b90:	ffffe097          	auipc	ra,0xffffe
    80002b94:	036080e7          	jalr	54(ra) # 80000bc6 <acquire>
  int old_procmask = p->signal_mask;
    80002b98:	0ec4a983          	lw	s3,236(s1)
  p->signal_mask = new_procmask;
    80002b9c:	0f24a623          	sw	s2,236(s1)
  release(&p->lock);
    80002ba0:	8526                	mv	a0,s1
    80002ba2:	ffffe097          	auipc	ra,0xffffe
    80002ba6:	0ee080e7          	jalr	238(ra) # 80000c90 <release>
  
  return old_procmask;
}
    80002baa:	854e                	mv	a0,s3
    80002bac:	70a2                	ld	ra,40(sp)
    80002bae:	7402                	ld	s0,32(sp)
    80002bb0:	64e2                	ld	s1,24(sp)
    80002bb2:	6942                	ld	s2,16(sp)
    80002bb4:	69a2                	ld	s3,8(sp)
    80002bb6:	6145                	addi	sp,sp,48
    80002bb8:	8082                	ret

0000000080002bba <sigaction>:

 
int 
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
  
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002bba:	0005079b          	sext.w	a5,a0
    80002bbe:	477d                	li	a4,31
    80002bc0:	0cf76a63          	bltu	a4,a5,80002c94 <sigaction+0xda>
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
    80002bc4:	7139                	addi	sp,sp,-64
    80002bc6:	fc06                	sd	ra,56(sp)
    80002bc8:	f822                	sd	s0,48(sp)
    80002bca:	f426                	sd	s1,40(sp)
    80002bcc:	f04a                	sd	s2,32(sp)
    80002bce:	ec4e                	sd	s3,24(sp)
    80002bd0:	e852                	sd	s4,16(sp)
    80002bd2:	0080                	addi	s0,sp,64
    80002bd4:	84aa                	mv	s1,a0
    80002bd6:	89ae                	mv	s3,a1
    80002bd8:	8a32                	mv	s4,a2
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP || act==0)
    80002bda:	37dd                	addiw	a5,a5,-9
    80002bdc:	9bdd                	andi	a5,a5,-9
    80002bde:	2781                	sext.w	a5,a5
    80002be0:	cfc5                	beqz	a5,80002c98 <sigaction+0xde>
    80002be2:	cdcd                	beqz	a1,80002c9c <sigaction+0xe2>
    return -1;
  struct proc *p = myproc();
    80002be4:	fffff097          	auipc	ra,0xfffff
    80002be8:	ebc080e7          	jalr	-324(ra) # 80001aa0 <myproc>
    80002bec:	892a                	mv	s2,a0

  uint new_mask;
  copyin(p->pagetable, (char *)&new_mask, (uint64)&act->sigmask, sizeof(act->sigmask));
    80002bee:	4691                	li	a3,4
    80002bf0:	00898613          	addi	a2,s3,8
    80002bf4:	fcc40593          	addi	a1,s0,-52
    80002bf8:	6128                	ld	a0,64(a0)
    80002bfa:	fffff097          	auipc	ra,0xfffff
    80002bfe:	b1a080e7          	jalr	-1254(ra) # 80001714 <copyin>
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002c02:	fcc42703          	lw	a4,-52(s0)

  if(is_valid_sigmask(new_mask) == 0)
    80002c06:	000207b7          	lui	a5,0x20
    80002c0a:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002c0e:	8ff9                	and	a5,a5,a4
    80002c10:	ebc1                	bnez	a5,80002ca0 <sigaction+0xe6>
    return -1;
  acquire(&p->lock);
    80002c12:	854a                	mv	a0,s2
    80002c14:	ffffe097          	auipc	ra,0xffffe
    80002c18:	fb2080e7          	jalr	-78(ra) # 80000bc6 <acquire>

  if(oldact!=0){
    80002c1c:	020a0b63          	beqz	s4,80002c52 <sigaction+0x98>
    copyout(p->pagetable, (uint64)&oldact->sa_handler, (char *)&p->signal_handlers[signum], sizeof(act->sa_handler));
    80002c20:	01f48613          	addi	a2,s1,31
    80002c24:	060e                	slli	a2,a2,0x3
    80002c26:	46a1                	li	a3,8
    80002c28:	964a                	add	a2,a2,s2
    80002c2a:	85d2                	mv	a1,s4
    80002c2c:	04093503          	ld	a0,64(s2)
    80002c30:	fffff097          	auipc	ra,0xfffff
    80002c34:	a58080e7          	jalr	-1448(ra) # 80001688 <copyout>
    copyout(p->pagetable, (uint64)&oldact->sigmask, (char *)&p->handlers_sigmasks[signum], sizeof(uint));
    80002c38:	07e48613          	addi	a2,s1,126
    80002c3c:	060a                	slli	a2,a2,0x2
    80002c3e:	4691                	li	a3,4
    80002c40:	964a                	add	a2,a2,s2
    80002c42:	008a0593          	addi	a1,s4,8
    80002c46:	04093503          	ld	a0,64(s2)
    80002c4a:	fffff097          	auipc	ra,0xfffff
    80002c4e:	a3e080e7          	jalr	-1474(ra) # 80001688 <copyout>
  }

  p->handlers_sigmasks[signum]=new_mask;
    80002c52:	07c48793          	addi	a5,s1,124
    80002c56:	078a                	slli	a5,a5,0x2
    80002c58:	97ca                	add	a5,a5,s2
    80002c5a:	fcc42703          	lw	a4,-52(s0)
    80002c5e:	c798                	sw	a4,8(a5)
  copyin(p->pagetable, (char *)&p->signal_handlers[signum], (uint64)&act->sa_handler, sizeof(act->sa_handler));
    80002c60:	04fd                	addi	s1,s1,31
    80002c62:	048e                	slli	s1,s1,0x3
    80002c64:	46a1                	li	a3,8
    80002c66:	864e                	mv	a2,s3
    80002c68:	009905b3          	add	a1,s2,s1
    80002c6c:	04093503          	ld	a0,64(s2)
    80002c70:	fffff097          	auipc	ra,0xfffff
    80002c74:	aa4080e7          	jalr	-1372(ra) # 80001714 <copyin>

  release(&p->lock);
    80002c78:	854a                	mv	a0,s2
    80002c7a:	ffffe097          	auipc	ra,0xffffe
    80002c7e:	016080e7          	jalr	22(ra) # 80000c90 <release>

  // printf("handler address %p = \n",p->signal_handlers[signum]);
  // printf("h_mask %d  \n",p->handlers_sigmasks[signum]);// TODO delete

  return 0;
    80002c82:	4501                	li	a0,0
}
    80002c84:	70e2                	ld	ra,56(sp)
    80002c86:	7442                	ld	s0,48(sp)
    80002c88:	74a2                	ld	s1,40(sp)
    80002c8a:	7902                	ld	s2,32(sp)
    80002c8c:	69e2                	ld	s3,24(sp)
    80002c8e:	6a42                	ld	s4,16(sp)
    80002c90:	6121                	addi	sp,sp,64
    80002c92:	8082                	ret
    return -1;
    80002c94:	557d                	li	a0,-1
}
    80002c96:	8082                	ret
    return -1;
    80002c98:	557d                	li	a0,-1
    80002c9a:	b7ed                	j	80002c84 <sigaction+0xca>
    80002c9c:	557d                	li	a0,-1
    80002c9e:	b7dd                	j	80002c84 <sigaction+0xca>
    return -1;
    80002ca0:	557d                	li	a0,-1
    80002ca2:	b7cd                	j	80002c84 <sigaction+0xca>

0000000080002ca4 <sigret>:

void 
sigret(void){
    80002ca4:	1101                	addi	sp,sp,-32
    80002ca6:	ec06                	sd	ra,24(sp)
    80002ca8:	e822                	sd	s0,16(sp)
    80002caa:	e426                	sd	s1,8(sp)
    80002cac:	e04a                	sd	s2,0(sp)
    80002cae:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002cb0:	fffff097          	auipc	ra,0xfffff
    80002cb4:	df0080e7          	jalr	-528(ra) # 80001aa0 <myproc>
    80002cb8:	84aa                	mv	s1,a0
  struct kthread *t=mykthread();
    80002cba:	fffff097          	auipc	ra,0xfffff
    80002cbe:	e26080e7          	jalr	-474(ra) # 80001ae0 <mykthread>
    80002cc2:	892a                	mv	s2,a0

  copyin(p->pagetable, (char *)t->trapframe, (uint64)p->user_trapframe_backup, sizeof(struct trapframe));
    80002cc4:	12000693          	li	a3,288
    80002cc8:	2784b603          	ld	a2,632(s1)
    80002ccc:	612c                	ld	a1,64(a0)
    80002cce:	60a8                	ld	a0,64(s1)
    80002cd0:	fffff097          	auipc	ra,0xfffff
    80002cd4:	a44080e7          	jalr	-1468(ra) # 80001714 <copyin>

  // restore user stack pointer
  acquire(&p->lock);
    80002cd8:	8526                	mv	a0,s1
    80002cda:	ffffe097          	auipc	ra,0xffffe
    80002cde:	eec080e7          	jalr	-276(ra) # 80000bc6 <acquire>
  // TODO maybe we will need to also lock the kthread lock
  t->trapframe->sp += sizeof(struct trapframe);
    80002ce2:	04093703          	ld	a4,64(s2)
    80002ce6:	7b1c                	ld	a5,48(a4)
    80002ce8:	12078793          	addi	a5,a5,288
    80002cec:	fb1c                	sd	a5,48(a4)

  p->signal_mask = p->signal_mask_backup;
    80002cee:	0f04a783          	lw	a5,240(s1)
    80002cf2:	0ef4a623          	sw	a5,236(s1)
  
  // Allow user signal handler since we finished handling the current
  p->handling_user_sig_flag = 0;
    80002cf6:	2804a023          	sw	zero,640(s1)
  // Allow other thread to react to signals
  p->handling_sig_flag = 0;
    80002cfa:	2804a223          	sw	zero,644(s1)
  release(&p->lock);
    80002cfe:	8526                	mv	a0,s1
    80002d00:	ffffe097          	auipc	ra,0xffffe
    80002d04:	f90080e7          	jalr	-112(ra) # 80000c90 <release>
}
    80002d08:	60e2                	ld	ra,24(sp)
    80002d0a:	6442                	ld	s0,16(sp)
    80002d0c:	64a2                	ld	s1,8(sp)
    80002d0e:	6902                	ld	s2,0(sp)
    80002d10:	6105                	addi	sp,sp,32
    80002d12:	8082                	ret

0000000080002d14 <turn_on_bit>:

// we call turn on and turn off when holding p->lock
void
turn_on_bit(struct proc* p, int signum){
    80002d14:	1141                	addi	sp,sp,-16
    80002d16:	e422                	sd	s0,8(sp)
    80002d18:	0800                	addi	s0,sp,16
  if(!p->pending_signals & (1 << signum))
    80002d1a:	0e852703          	lw	a4,232(a0)
    80002d1e:	00173793          	seqz	a5,a4
    80002d22:	40b7d7bb          	sraw	a5,a5,a1
    80002d26:	8b85                	andi	a5,a5,1
    80002d28:	c799                	beqz	a5,80002d36 <turn_on_bit+0x22>
    p->pending_signals ^= (1 << signum);  
    80002d2a:	4785                	li	a5,1
    80002d2c:	00b795bb          	sllw	a1,a5,a1
    80002d30:	8f2d                	xor	a4,a4,a1
    80002d32:	0ee52423          	sw	a4,232(a0)
}
    80002d36:	6422                	ld	s0,8(sp)
    80002d38:	0141                	addi	sp,sp,16
    80002d3a:	8082                	ret

0000000080002d3c <kill>:
{
    80002d3c:	7139                	addi	sp,sp,-64
    80002d3e:	fc06                	sd	ra,56(sp)
    80002d40:	f822                	sd	s0,48(sp)
    80002d42:	f426                	sd	s1,40(sp)
    80002d44:	f04a                	sd	s2,32(sp)
    80002d46:	ec4e                	sd	s3,24(sp)
    80002d48:	e852                	sd	s4,16(sp)
    80002d4a:	e456                	sd	s5,8(sp)
    80002d4c:	0080                	addi	s0,sp,64
    80002d4e:	892a                	mv	s2,a0
    80002d50:	8aae                	mv	s5,a1
  for(p = proc; p < &proc[NPROC]; p++){
    80002d52:	0000f497          	auipc	s1,0xf
    80002d56:	9d648493          	addi	s1,s1,-1578 # 80011728 <proc>
    80002d5a:	6985                	lui	s3,0x1
    80002d5c:	84898993          	addi	s3,s3,-1976 # 848 <_entry-0x7ffff7b8>
    80002d60:	00030a17          	auipc	s4,0x30
    80002d64:	bc8a0a13          	addi	s4,s4,-1080 # 80032928 <tickslock>
    acquire(&p->lock);
    80002d68:	8526                	mv	a0,s1
    80002d6a:	ffffe097          	auipc	ra,0xffffe
    80002d6e:	e5c080e7          	jalr	-420(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    80002d72:	50dc                	lw	a5,36(s1)
    80002d74:	01278c63          	beq	a5,s2,80002d8c <kill+0x50>
    release(&p->lock);
    80002d78:	8526                	mv	a0,s1
    80002d7a:	ffffe097          	auipc	ra,0xffffe
    80002d7e:	f16080e7          	jalr	-234(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002d82:	94ce                	add	s1,s1,s3
    80002d84:	ff4492e3          	bne	s1,s4,80002d68 <kill+0x2c>
  return -1;
    80002d88:	557d                	li	a0,-1
    80002d8a:	a825                	j	80002dc2 <kill+0x86>
      if(p->state != RUNNABLE){
    80002d8c:	4c98                	lw	a4,24(s1)
    80002d8e:	4789                	li	a5,2
    80002d90:	04f71263          	bne	a4,a5,80002dd4 <kill+0x98>
      if(p->signal_handlers[signum] == (void*)SIG_IGN){
    80002d94:	01ea8793          	addi	a5,s5,30
    80002d98:	078e                	slli	a5,a5,0x3
    80002d9a:	97a6                	add	a5,a5,s1
    80002d9c:	6798                	ld	a4,8(a5)
    80002d9e:	4785                	li	a5,1
    80002da0:	04f70163          	beq	a4,a5,80002de2 <kill+0xa6>
      turn_on_bit(p,signum);
    80002da4:	85d6                	mv	a1,s5
    80002da6:	8526                	mv	a0,s1
    80002da8:	00000097          	auipc	ra,0x0
    80002dac:	f6c080e7          	jalr	-148(ra) # 80002d14 <turn_on_bit>
      release(&p->lock);
    80002db0:	8526                	mv	a0,s1
    80002db2:	ffffe097          	auipc	ra,0xffffe
    80002db6:	ede080e7          	jalr	-290(ra) # 80000c90 <release>
      if(signum == SIGKILL){
    80002dba:	47a5                	li	a5,9
      return 0;
    80002dbc:	4501                	li	a0,0
      if(signum == SIGKILL){
    80002dbe:	02fa8963          	beq	s5,a5,80002df0 <kill+0xb4>
}
    80002dc2:	70e2                	ld	ra,56(sp)
    80002dc4:	7442                	ld	s0,48(sp)
    80002dc6:	74a2                	ld	s1,40(sp)
    80002dc8:	7902                	ld	s2,32(sp)
    80002dca:	69e2                	ld	s3,24(sp)
    80002dcc:	6a42                	ld	s4,16(sp)
    80002dce:	6aa2                	ld	s5,8(sp)
    80002dd0:	6121                	addi	sp,sp,64
    80002dd2:	8082                	ret
        release(&p->lock);
    80002dd4:	8526                	mv	a0,s1
    80002dd6:	ffffe097          	auipc	ra,0xffffe
    80002dda:	eba080e7          	jalr	-326(ra) # 80000c90 <release>
        return -1;
    80002dde:	557d                	li	a0,-1
    80002de0:	b7cd                	j	80002dc2 <kill+0x86>
        release(&p->lock);
    80002de2:	8526                	mv	a0,s1
    80002de4:	ffffe097          	auipc	ra,0xffffe
    80002de8:	eac080e7          	jalr	-340(ra) # 80000c90 <release>
        return 0;
    80002dec:	4501                	li	a0,0
    80002dee:	bfd1                	j	80002dc2 <kill+0x86>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002df0:	28848913          	addi	s2,s1,648
    80002df4:	6785                	lui	a5,0x1
    80002df6:	84878793          	addi	a5,a5,-1976 # 848 <_entry-0x7ffff7b8>
    80002dfa:	94be                	add	s1,s1,a5
          if(t->state == RUNNABLE){
    80002dfc:	4989                	li	s3,2
    80002dfe:	01892783          	lw	a5,24(s2)
    80002e02:	03378d63          	beq	a5,s3,80002e3c <kill+0x100>
            acquire(&t->lock);
    80002e06:	854a                	mv	a0,s2
    80002e08:	ffffe097          	auipc	ra,0xffffe
    80002e0c:	dbe080e7          	jalr	-578(ra) # 80000bc6 <acquire>
            if(t->state==TSLEEPING){
    80002e10:	01892783          	lw	a5,24(s2)
    80002e14:	01378d63          	beq	a5,s3,80002e2e <kill+0xf2>
            release(&t->lock);
    80002e18:	854a                	mv	a0,s2
    80002e1a:	ffffe097          	auipc	ra,0xffffe
    80002e1e:	e76080e7          	jalr	-394(ra) # 80000c90 <release>
        for(t = p->kthreads; t<&p->kthreads[NTHREAD];t++){
    80002e22:	0b890913          	addi	s2,s2,184
    80002e26:	fc991ce3          	bne	s2,s1,80002dfe <kill+0xc2>
      return 0;
    80002e2a:	4501                	li	a0,0
    80002e2c:	bf59                	j	80002dc2 <kill+0x86>
              release(&t->lock);
    80002e2e:	854a                	mv	a0,s2
    80002e30:	ffffe097          	auipc	ra,0xffffe
    80002e34:	e60080e7          	jalr	-416(ra) # 80000c90 <release>
      return 0;
    80002e38:	4501                	li	a0,0
              break;
    80002e3a:	b761                	j	80002dc2 <kill+0x86>
      return 0;
    80002e3c:	4501                	li	a0,0
    80002e3e:	b751                	j	80002dc2 <kill+0x86>

0000000080002e40 <turn_off_bit>:

void
turn_off_bit(struct proc* p, int signum){
    80002e40:	1141                	addi	sp,sp,-16
    80002e42:	e422                	sd	s0,8(sp)
    80002e44:	0800                	addi	s0,sp,16
  if(p->pending_signals & (1 << signum))
    80002e46:	0e852703          	lw	a4,232(a0)
    80002e4a:	4785                	li	a5,1
    80002e4c:	00b795bb          	sllw	a1,a5,a1
    80002e50:	00b777b3          	and	a5,a4,a1
    80002e54:	2781                	sext.w	a5,a5
    80002e56:	c781                	beqz	a5,80002e5e <turn_off_bit+0x1e>
    p->pending_signals ^= (1 << signum);  
    80002e58:	8db9                	xor	a1,a1,a4
    80002e5a:	0eb52423          	sw	a1,232(a0)
}
    80002e5e:	6422                	ld	s0,8(sp)
    80002e60:	0141                	addi	sp,sp,16
    80002e62:	8082                	ret

0000000080002e64 <kthread_create>:

int kthread_create(void (*start_func)(), void *stack){
    80002e64:	7139                	addi	sp,sp,-64
    80002e66:	fc06                	sd	ra,56(sp)
    80002e68:	f822                	sd	s0,48(sp)
    80002e6a:	f426                	sd	s1,40(sp)
    80002e6c:	f04a                	sd	s2,32(sp)
    80002e6e:	ec4e                	sd	s3,24(sp)
    80002e70:	e852                	sd	s4,16(sp)
    80002e72:	e456                	sd	s5,8(sp)
    80002e74:	e05a                	sd	s6,0(sp)
    80002e76:	0080                	addi	s0,sp,64
    80002e78:	8aaa                	mv	s5,a0
    80002e7a:	8b2e                	mv	s6,a1
  struct proc *p = myproc();
    80002e7c:	fffff097          	auipc	ra,0xfffff
    80002e80:	c24080e7          	jalr	-988(ra) # 80001aa0 <myproc>
    80002e84:	8a2a                	mv	s4,a0
  struct kthread *curr_t = mykthread();
    80002e86:	fffff097          	auipc	ra,0xfffff
    80002e8a:	c5a080e7          	jalr	-934(ra) # 80001ae0 <mykthread>
    80002e8e:	89aa                	mv	s3,a0
  struct kthread *other_t;
  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    80002e90:	288a0493          	addi	s1,s4,648
    80002e94:	6905                	lui	s2,0x1
    80002e96:	84890913          	addi	s2,s2,-1976 # 848 <_entry-0x7ffff7b8>
    80002e9a:	9952                	add	s2,s2,s4
    80002e9c:	a89d                	j	80002f12 <kthread_create+0xae>
  t->tid = 0;
    80002e9e:	0204a823          	sw	zero,48(s1)
  t->chan = 0;
    80002ea2:	0204b023          	sd	zero,32(s1)
  t->killed = 0;
    80002ea6:	0204a423          	sw	zero,40(s1)
  t->xstate = 0;
    80002eaa:	0204a623          	sw	zero,44(s1)
  t->state = TUNUSED;
    80002eae:	0004ac23          	sw	zero,24(s1)
    if(curr_t!=other_t){
      acquire(&other_t->lock);
      if(other_t->state==TUNUSED){
          freethread(other_t);  // free memory in case this thread entry was previously used
          init_thread(other_t);
    80002eb2:	8526                	mv	a0,s1
    80002eb4:	fffff097          	auipc	ra,0xfffff
    80002eb8:	d3e080e7          	jalr	-706(ra) # 80001bf2 <init_thread>
          other_t->trapframe->sp = (uint64)stack;
    80002ebc:	60bc                	ld	a5,64(s1)
    80002ebe:	0367b823          	sd	s6,48(a5)
          other_t->trapframe->epc = (uint64)start_func;
    80002ec2:	60bc                	ld	a5,64(s1)
    80002ec4:	0157bc23          	sd	s5,24(a5)
          release(&other_t->lock);
    80002ec8:	8526                	mv	a0,s1
    80002eca:	ffffe097          	auipc	ra,0xffffe
    80002ece:	dc6080e7          	jalr	-570(ra) # 80000c90 <release>
          acquire(&p->lock);
    80002ed2:	8552                	mv	a0,s4
    80002ed4:	ffffe097          	auipc	ra,0xffffe
    80002ed8:	cf2080e7          	jalr	-782(ra) # 80000bc6 <acquire>
          p->active_threads++;
    80002edc:	028a2783          	lw	a5,40(s4)
    80002ee0:	2785                	addiw	a5,a5,1
    80002ee2:	02fa2423          	sw	a5,40(s4)
          release(&p->lock);
    80002ee6:	8552                	mv	a0,s4
    80002ee8:	ffffe097          	auipc	ra,0xffffe
    80002eec:	da8080e7          	jalr	-600(ra) # 80000c90 <release>
          other_t->state = TRUNNABLE;
    80002ef0:	478d                	li	a5,3
    80002ef2:	cc9c                	sw	a5,24(s1)
      }
      release(&other_t->lock);
    }
  }
  return 1;
}
    80002ef4:	4505                	li	a0,1
    80002ef6:	70e2                	ld	ra,56(sp)
    80002ef8:	7442                	ld	s0,48(sp)
    80002efa:	74a2                	ld	s1,40(sp)
    80002efc:	7902                	ld	s2,32(sp)
    80002efe:	69e2                	ld	s3,24(sp)
    80002f00:	6a42                	ld	s4,16(sp)
    80002f02:	6aa2                	ld	s5,8(sp)
    80002f04:	6b02                	ld	s6,0(sp)
    80002f06:	6121                	addi	sp,sp,64
    80002f08:	8082                	ret
  for(other_t = p->kthreads;other_t<&p->kthreads[NTHREAD];other_t++){
    80002f0a:	0b848493          	addi	s1,s1,184
    80002f0e:	fe9903e3          	beq	s2,s1,80002ef4 <kthread_create+0x90>
    if(curr_t!=other_t){
    80002f12:	fe998ce3          	beq	s3,s1,80002f0a <kthread_create+0xa6>
      acquire(&other_t->lock);
    80002f16:	8526                	mv	a0,s1
    80002f18:	ffffe097          	auipc	ra,0xffffe
    80002f1c:	cae080e7          	jalr	-850(ra) # 80000bc6 <acquire>
      if(other_t->state==TUNUSED){
    80002f20:	4c9c                	lw	a5,24(s1)
    80002f22:	dfb5                	beqz	a5,80002e9e <kthread_create+0x3a>
      release(&other_t->lock);
    80002f24:	8526                	mv	a0,s1
    80002f26:	ffffe097          	auipc	ra,0xffffe
    80002f2a:	d6a080e7          	jalr	-662(ra) # 80000c90 <release>
    80002f2e:	bff1                	j	80002f0a <kthread_create+0xa6>

0000000080002f30 <kthread_join>:



int
kthread_join(int thread_id, int* status){
    80002f30:	7139                	addi	sp,sp,-64
    80002f32:	fc06                	sd	ra,56(sp)
    80002f34:	f822                	sd	s0,48(sp)
    80002f36:	f426                	sd	s1,40(sp)
    80002f38:	f04a                	sd	s2,32(sp)
    80002f3a:	ec4e                	sd	s3,24(sp)
    80002f3c:	e852                	sd	s4,16(sp)
    80002f3e:	e456                	sd	s5,8(sp)
    80002f40:	e05a                	sd	s6,0(sp)
    80002f42:	0080                	addi	s0,sp,64
    80002f44:	8a2a                	mv	s4,a0
    80002f46:	8b2e                	mv	s6,a1
  struct kthread *nt;
  struct proc *p = myproc();
    80002f48:	fffff097          	auipc	ra,0xfffff
    80002f4c:	b58080e7          	jalr	-1192(ra) # 80001aa0 <myproc>
    80002f50:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80002f52:	fffff097          	auipc	ra,0xfffff
    80002f56:	b8e080e7          	jalr	-1138(ra) # 80001ae0 <mykthread>
  if(thread_id == t->tid)
    80002f5a:	591c                	lw	a5,48(a0)
    80002f5c:	11478d63          	beq	a5,s4,80003076 <kthread_join+0x146>
    80002f60:	89aa                	mv	s3,a0
    return -1;
  
  acquire(&wait_lock);
    80002f62:	0000e517          	auipc	a0,0xe
    80002f66:	36e50513          	addi	a0,a0,878 # 800112d0 <wait_lock>
    80002f6a:	ffffe097          	auipc	ra,0xffffe
    80002f6e:	c5c080e7          	jalr	-932(ra) # 80000bc6 <acquire>

  // Search for thread in the procces threads array
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];t++){
    80002f72:	28890493          	addi	s1,s2,648
    acquire(&nt->lock);
    80002f76:	8526                	mv	a0,s1
    80002f78:	ffffe097          	auipc	ra,0xffffe
    80002f7c:	c4e080e7          	jalr	-946(ra) # 80000bc6 <acquire>
    if(nt->tid == thread_id){
    80002f80:	2b892783          	lw	a5,696(s2)
    80002f84:	01478a63          	beq	a5,s4,80002f98 <kthread_join+0x68>
      //found target thread 
      break;
    }
    release(&nt->lock);
    80002f88:	8526                	mv	a0,s1
    80002f8a:	ffffe097          	auipc	ra,0xffffe
    80002f8e:	d06080e7          	jalr	-762(ra) # 80000c90 <release>
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];t++){
    80002f92:	0b898993          	addi	s3,s3,184
    80002f96:	b7c5                	j	80002f76 <kthread_join+0x46>
  }
  
  // Wait for thread to terminate
  // still holding nt lock
  for(;;){
      if(nt->state==TUNUSED){
    80002f98:	2a092783          	lw	a5,672(s2)
      release(&nt->lock);
      release(&wait_lock);
      return -1;
    }
    release(&nt->lock);
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    80002f9c:	0000ea97          	auipc	s5,0xe
    80002fa0:	334a8a93          	addi	s5,s5,820 # 800112d0 <wait_lock>
      if(nt->state==TUNUSED){
    80002fa4:	cb9d                	beqz	a5,80002fda <kthread_join+0xaa>
    if(t->killed || nt->tid!=thread_id){
    80002fa6:	0289a783          	lw	a5,40(s3)
    80002faa:	efd1                	bnez	a5,80003046 <kthread_join+0x116>
    80002fac:	2b892783          	lw	a5,696(s2)
    80002fb0:	09479b63          	bne	a5,s4,80003046 <kthread_join+0x116>
    release(&nt->lock);
    80002fb4:	8526                	mv	a0,s1
    80002fb6:	ffffe097          	auipc	ra,0xffffe
    80002fba:	cda080e7          	jalr	-806(ra) # 80000c90 <release>
    sleep(nt, &wait_lock);  //DOC: wait-sleep
    80002fbe:	85d6                	mv	a1,s5
    80002fc0:	8526                	mv	a0,s1
    80002fc2:	fffff097          	auipc	ra,0xfffff
    80002fc6:	524080e7          	jalr	1316(ra) # 800024e6 <sleep>
    acquire(&nt->lock);
    80002fca:	8526                	mv	a0,s1
    80002fcc:	ffffe097          	auipc	ra,0xffffe
    80002fd0:	bfa080e7          	jalr	-1030(ra) # 80000bc6 <acquire>
      if(nt->state==TUNUSED){
    80002fd4:	2a092783          	lw	a5,672(s2)
    80002fd8:	f7f9                	bnez	a5,80002fa6 <kthread_join+0x76>
        if(status != 0 && copyout(p->pagetable, status, (char *)&nt->xstate,sizeof(nt->xstate)) < 0) {
    80002fda:	000b0e63          	beqz	s6,80002ff6 <kthread_join+0xc6>
    80002fde:	4691                	li	a3,4
    80002fe0:	2b490613          	addi	a2,s2,692
    80002fe4:	85da                	mv	a1,s6
    80002fe6:	04093503          	ld	a0,64(s2)
    80002fea:	ffffe097          	auipc	ra,0xffffe
    80002fee:	69e080e7          	jalr	1694(ra) # 80001688 <copyout>
    80002ff2:	02054b63          	bltz	a0,80003028 <kthread_join+0xf8>
  t->tid = 0;
    80002ff6:	2a092c23          	sw	zero,696(s2)
  t->chan = 0;
    80002ffa:	2a093423          	sd	zero,680(s2)
  t->killed = 0;
    80002ffe:	2a092823          	sw	zero,688(s2)
  t->xstate = 0;
    80003002:	2a092a23          	sw	zero,692(s2)
  t->state = TUNUSED;
    80003006:	2a092023          	sw	zero,672(s2)
        release(&nt->lock);
    8000300a:	8526                	mv	a0,s1
    8000300c:	ffffe097          	auipc	ra,0xffffe
    80003010:	c84080e7          	jalr	-892(ra) # 80000c90 <release>
        release(&wait_lock);
    80003014:	0000e517          	auipc	a0,0xe
    80003018:	2bc50513          	addi	a0,a0,700 # 800112d0 <wait_lock>
    8000301c:	ffffe097          	auipc	ra,0xffffe
    80003020:	c74080e7          	jalr	-908(ra) # 80000c90 <release>
        return 0;
    80003024:	4501                	li	a0,0
    80003026:	a835                	j	80003062 <kthread_join+0x132>
           release(&nt->lock);
    80003028:	8526                	mv	a0,s1
    8000302a:	ffffe097          	auipc	ra,0xffffe
    8000302e:	c66080e7          	jalr	-922(ra) # 80000c90 <release>
           release(&wait_lock);
    80003032:	0000e517          	auipc	a0,0xe
    80003036:	29e50513          	addi	a0,a0,670 # 800112d0 <wait_lock>
    8000303a:	ffffe097          	auipc	ra,0xffffe
    8000303e:	c56080e7          	jalr	-938(ra) # 80000c90 <release>
           return -1;                   
    80003042:	557d                	li	a0,-1
    80003044:	a839                	j	80003062 <kthread_join+0x132>
      release(&nt->lock);
    80003046:	8526                	mv	a0,s1
    80003048:	ffffe097          	auipc	ra,0xffffe
    8000304c:	c48080e7          	jalr	-952(ra) # 80000c90 <release>
      release(&wait_lock);
    80003050:	0000e517          	auipc	a0,0xe
    80003054:	28050513          	addi	a0,a0,640 # 800112d0 <wait_lock>
    80003058:	ffffe097          	auipc	ra,0xffffe
    8000305c:	c38080e7          	jalr	-968(ra) # 80000c90 <release>
      return -1;
    80003060:	557d                	li	a0,-1
  }
}
    80003062:	70e2                	ld	ra,56(sp)
    80003064:	7442                	ld	s0,48(sp)
    80003066:	74a2                	ld	s1,40(sp)
    80003068:	7902                	ld	s2,32(sp)
    8000306a:	69e2                	ld	s3,24(sp)
    8000306c:	6a42                	ld	s4,16(sp)
    8000306e:	6aa2                	ld	s5,8(sp)
    80003070:	6b02                	ld	s6,0(sp)
    80003072:	6121                	addi	sp,sp,64
    80003074:	8082                	ret
    return -1;
    80003076:	557d                	li	a0,-1
    80003078:	b7ed                	j	80003062 <kthread_join+0x132>

000000008000307a <swtch>:
    8000307a:	00153023          	sd	ra,0(a0)
    8000307e:	00253423          	sd	sp,8(a0)
    80003082:	e900                	sd	s0,16(a0)
    80003084:	ed04                	sd	s1,24(a0)
    80003086:	03253023          	sd	s2,32(a0)
    8000308a:	03353423          	sd	s3,40(a0)
    8000308e:	03453823          	sd	s4,48(a0)
    80003092:	03553c23          	sd	s5,56(a0)
    80003096:	05653023          	sd	s6,64(a0)
    8000309a:	05753423          	sd	s7,72(a0)
    8000309e:	05853823          	sd	s8,80(a0)
    800030a2:	05953c23          	sd	s9,88(a0)
    800030a6:	07a53023          	sd	s10,96(a0)
    800030aa:	07b53423          	sd	s11,104(a0)
    800030ae:	0005b083          	ld	ra,0(a1)
    800030b2:	0085b103          	ld	sp,8(a1)
    800030b6:	6980                	ld	s0,16(a1)
    800030b8:	6d84                	ld	s1,24(a1)
    800030ba:	0205b903          	ld	s2,32(a1)
    800030be:	0285b983          	ld	s3,40(a1)
    800030c2:	0305ba03          	ld	s4,48(a1)
    800030c6:	0385ba83          	ld	s5,56(a1)
    800030ca:	0405bb03          	ld	s6,64(a1)
    800030ce:	0485bb83          	ld	s7,72(a1)
    800030d2:	0505bc03          	ld	s8,80(a1)
    800030d6:	0585bc83          	ld	s9,88(a1)
    800030da:	0605bd03          	ld	s10,96(a1)
    800030de:	0685bd83          	ld	s11,104(a1)
    800030e2:	8082                	ret

00000000800030e4 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800030e4:	1141                	addi	sp,sp,-16
    800030e6:	e406                	sd	ra,8(sp)
    800030e8:	e022                	sd	s0,0(sp)
    800030ea:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800030ec:	00005597          	auipc	a1,0x5
    800030f0:	38458593          	addi	a1,a1,900 # 80008470 <states.0+0x20>
    800030f4:	00030517          	auipc	a0,0x30
    800030f8:	83450513          	addi	a0,a0,-1996 # 80032928 <tickslock>
    800030fc:	ffffe097          	auipc	ra,0xffffe
    80003100:	a3a080e7          	jalr	-1478(ra) # 80000b36 <initlock>
}
    80003104:	60a2                	ld	ra,8(sp)
    80003106:	6402                	ld	s0,0(sp)
    80003108:	0141                	addi	sp,sp,16
    8000310a:	8082                	ret

000000008000310c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000310c:	1141                	addi	sp,sp,-16
    8000310e:	e422                	sd	s0,8(sp)
    80003110:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003112:	00003797          	auipc	a5,0x3
    80003116:	69e78793          	addi	a5,a5,1694 # 800067b0 <kernelvec>
    8000311a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000311e:	6422                	ld	s0,8(sp)
    80003120:	0141                	addi	sp,sp,16
    80003122:	8082                	ret

0000000080003124 <check_should_cont>:
}

int 
check_should_cont(struct proc *p){
  for(int i=0;i<32;i++){
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    80003124:	0e852303          	lw	t1,232(a0)
    80003128:	0f850813          	addi	a6,a0,248
    8000312c:	4685                	li	a3,1
    8000312e:	4701                	li	a4,0
    80003130:	4885                	li	a7,1
  for(int i=0;i<32;i++){
    80003132:	4e7d                	li	t3,31
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    80003134:	4ecd                	li	t4,19
    80003136:	a801                	j	80003146 <check_should_cont+0x22>
  for(int i=0;i<32;i++){
    80003138:	0006879b          	sext.w	a5,a3
    8000313c:	04fe4663          	blt	t3,a5,80003188 <check_should_cont+0x64>
    80003140:	2705                	addiw	a4,a4,1
    80003142:	2685                	addiw	a3,a3,1
    80003144:	0821                	addi	a6,a6,8
    80003146:	0007059b          	sext.w	a1,a4
      if((p->pending_signals & (1 << i)) && !(p->signal_mask & (1 << i)) && ((p->signal_handlers[i] == SIGCONT) || 
    8000314a:	00e8963b          	sllw	a2,a7,a4
    8000314e:	00c377b3          	and	a5,t1,a2
    80003152:	2781                	sext.w	a5,a5
    80003154:	d3f5                	beqz	a5,80003138 <check_should_cont+0x14>
    80003156:	0ec52783          	lw	a5,236(a0)
    8000315a:	8ff1                	and	a5,a5,a2
    8000315c:	2781                	sext.w	a5,a5
    8000315e:	ffe9                	bnez	a5,80003138 <check_should_cont+0x14>
    80003160:	00083783          	ld	a5,0(a6)
    80003164:	01d78563          	beq	a5,t4,8000316e <check_should_cont+0x4a>
    80003168:	fdd598e3          	bne	a1,t4,80003138 <check_should_cont+0x14>
          (i == SIGCONT && p->signal_handlers[i] == SIG_DFL))){
    8000316c:	fbf1                	bnez	a5,80003140 <check_should_cont+0x1c>
check_should_cont(struct proc *p){
    8000316e:	1141                	addi	sp,sp,-16
    80003170:	e406                	sd	ra,8(sp)
    80003172:	e022                	sd	s0,0(sp)
    80003174:	0800                	addi	s0,sp,16
        turn_off_bit(p, i);
    80003176:	00000097          	auipc	ra,0x0
    8000317a:	cca080e7          	jalr	-822(ra) # 80002e40 <turn_off_bit>
        return 1;
    8000317e:	4505                	li	a0,1
      }
  }
  return 0;
}
    80003180:	60a2                	ld	ra,8(sp)
    80003182:	6402                	ld	s0,0(sp)
    80003184:	0141                	addi	sp,sp,16
    80003186:	8082                	ret
  return 0;
    80003188:	4501                	li	a0,0
}
    8000318a:	8082                	ret

000000008000318c <handle_stop>:



void
handle_stop(struct proc* p){
    8000318c:	7139                	addi	sp,sp,-64
    8000318e:	fc06                	sd	ra,56(sp)
    80003190:	f822                	sd	s0,48(sp)
    80003192:	f426                	sd	s1,40(sp)
    80003194:	f04a                	sd	s2,32(sp)
    80003196:	ec4e                	sd	s3,24(sp)
    80003198:	e852                	sd	s4,16(sp)
    8000319a:	e456                	sd	s5,8(sp)
    8000319c:	e05a                	sd	s6,0(sp)
    8000319e:	0080                	addi	s0,sp,64
    800031a0:	89aa                	mv	s3,a0
  // p->frozen=1;
  struct kthread *t;
  struct kthread *curr_t = mykthread();
    800031a2:	fffff097          	auipc	ra,0xfffff
    800031a6:	93e080e7          	jalr	-1730(ra) # 80001ae0 <mykthread>
    800031aa:	8aaa                	mv	s5,a0

  // Make all other threads belong to the same procces freeze 
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800031ac:	28898493          	addi	s1,s3,648
    800031b0:	6a05                	lui	s4,0x1
    800031b2:	848a0a13          	addi	s4,s4,-1976 # 848 <_entry-0x7ffff7b8>
    800031b6:	9a4e                	add	s4,s4,s3
    800031b8:	8926                	mv	s2,s1
    if(t!=curr_t){
      acquire(&t->lock);
      t->frozen=1;
    800031ba:	4b05                	li	s6,1
    800031bc:	a029                	j	800031c6 <handle_stop+0x3a>
  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    800031be:	0b890913          	addi	s2,s2,184
    800031c2:	03490163          	beq	s2,s4,800031e4 <handle_stop+0x58>
    if(t!=curr_t){
    800031c6:	ff2a8ce3          	beq	s5,s2,800031be <handle_stop+0x32>
      acquire(&t->lock);
    800031ca:	854a                	mv	a0,s2
    800031cc:	ffffe097          	auipc	ra,0xffffe
    800031d0:	9fa080e7          	jalr	-1542(ra) # 80000bc6 <acquire>
      t->frozen=1;
    800031d4:	03692a23          	sw	s6,52(s2)
      release(&t->lock);
    800031d8:	854a                	mv	a0,s2
    800031da:	ffffe097          	auipc	ra,0xffffe
    800031de:	ab6080e7          	jalr	-1354(ra) # 80000c90 <release>
    800031e2:	bff1                	j	800031be <handle_stop+0x32>
    }
  }
  int should_cont = check_should_cont(p);
    800031e4:	854e                	mv	a0,s3
    800031e6:	00000097          	auipc	ra,0x0
    800031ea:	f3e080e7          	jalr	-194(ra) # 80003124 <check_should_cont>
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    800031ee:	0e89a783          	lw	a5,232(s3)
    800031f2:	2007f793          	andi	a5,a5,512
    800031f6:	e795                	bnez	a5,80003222 <handle_stop+0x96>
    800031f8:	e50d                	bnez	a0,80003222 <handle_stop+0x96>
    // printf("in handle stop, yielding pid=%d \n",p->pid);//TODO delete
    yield();
    800031fa:	fffff097          	auipc	ra,0xfffff
    800031fe:	2b0080e7          	jalr	688(ra) # 800024aa <yield>
    should_cont = check_should_cont(p);  
    80003202:	854e                	mv	a0,s3
    80003204:	00000097          	auipc	ra,0x0
    80003208:	f20080e7          	jalr	-224(ra) # 80003124 <check_should_cont>
  while (!(p->pending_signals & (1<<SIGKILL)) && !should_cont ){     
    8000320c:	0e89a783          	lw	a5,232(s3)
    80003210:	2007f793          	andi	a5,a5,512
    80003214:	e799                	bnez	a5,80003222 <handle_stop+0x96>
    80003216:	d175                	beqz	a0,800031fa <handle_stop+0x6e>
    80003218:	a029                	j	80003222 <handle_stop+0x96>
  }

  for(t = p->kthreads;t<&p->kthreads[NTHREAD];t++){
    8000321a:	0b848493          	addi	s1,s1,184
    8000321e:	03448163          	beq	s1,s4,80003240 <handle_stop+0xb4>
    if(t!=curr_t){
    80003222:	fe9a8ce3          	beq	s5,s1,8000321a <handle_stop+0x8e>
      acquire(&t->lock);
    80003226:	8526                	mv	a0,s1
    80003228:	ffffe097          	auipc	ra,0xffffe
    8000322c:	99e080e7          	jalr	-1634(ra) # 80000bc6 <acquire>
      t->frozen=0;
    80003230:	0204aa23          	sw	zero,52(s1)
      release(&t->lock);
    80003234:	8526                	mv	a0,s1
    80003236:	ffffe097          	auipc	ra,0xffffe
    8000323a:	a5a080e7          	jalr	-1446(ra) # 80000c90 <release>
    8000323e:	bff1                	j	8000321a <handle_stop+0x8e>
    }
  }
  if(p->pending_signals&1<<SIGKILL)
    80003240:	0e89a783          	lw	a5,232(s3)
    80003244:	2007f793          	andi	a5,a5,512
    80003248:	c781                	beqz	a5,80003250 <handle_stop+0xc4>
    p->killed=1;
    8000324a:	4785                	li	a5,1
    8000324c:	00f9ae23          	sw	a5,28(s3)
}
    80003250:	70e2                	ld	ra,56(sp)
    80003252:	7442                	ld	s0,48(sp)
    80003254:	74a2                	ld	s1,40(sp)
    80003256:	7902                	ld	s2,32(sp)
    80003258:	69e2                	ld	s3,24(sp)
    8000325a:	6a42                	ld	s4,16(sp)
    8000325c:	6aa2                	ld	s5,8(sp)
    8000325e:	6b02                	ld	s6,0(sp)
    80003260:	6121                	addi	sp,sp,64
    80003262:	8082                	ret

0000000080003264 <check_pending_signals>:

void 
check_pending_signals(struct proc* p){
    80003264:	711d                	addi	sp,sp,-96
    80003266:	ec86                	sd	ra,88(sp)
    80003268:	e8a2                	sd	s0,80(sp)
    8000326a:	e4a6                	sd	s1,72(sp)
    8000326c:	e0ca                	sd	s2,64(sp)
    8000326e:	fc4e                	sd	s3,56(sp)
    80003270:	f852                	sd	s4,48(sp)
    80003272:	f456                	sd	s5,40(sp)
    80003274:	f05a                	sd	s6,32(sp)
    80003276:	ec5e                	sd	s7,24(sp)
    80003278:	e862                	sd	s8,16(sp)
    8000327a:	e466                	sd	s9,8(sp)
    8000327c:	e06a                	sd	s10,0(sp)
    8000327e:	1080                	addi	s0,sp,96
    80003280:	89aa                	mv	s3,a0
  struct kthread *t= mykthread();
    80003282:	fffff097          	auipc	ra,0xfffff
    80003286:	85e080e7          	jalr	-1954(ra) # 80001ae0 <mykthread>
    8000328a:	8caa                	mv	s9,a0
  for(int sig_num=0;sig_num<32;sig_num++){
    8000328c:	0f898913          	addi	s2,s3,248
    80003290:	4481                	li	s1,0
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    80003292:	4a05                	li	s4,1
            p->killed = 1;
            release(&p->lock);
        }
      }

      else if(act.sa_handler==(void*)SIGKILL){
    80003294:	4c25                	li	s8,9
        p->killed=1;
      }else if(act.sa_handler==(void*)SIGSTOP){
    80003296:	4b45                	li	s6,17
        handle_stop(p);
      }      
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    80003298:	4b85                	li	s7,1
        switch (sig_num)
    8000329a:	4d4d                	li	s10,19
  for(int sig_num=0;sig_num<32;sig_num++){
    8000329c:	02000a93          	li	s5,32
    800032a0:	a0a1                	j	800032e8 <check_pending_signals+0x84>
        switch (sig_num)
    800032a2:	03648163          	beq	s1,s6,800032c4 <check_pending_signals+0x60>
    800032a6:	03a48763          	beq	s1,s10,800032d4 <check_pending_signals+0x70>
            acquire(&p->lock);
    800032aa:	854e                	mv	a0,s3
    800032ac:	ffffe097          	auipc	ra,0xffffe
    800032b0:	91a080e7          	jalr	-1766(ra) # 80000bc6 <acquire>
            p->killed = 1;
    800032b4:	0179ae23          	sw	s7,28(s3)
            release(&p->lock);
    800032b8:	854e                	mv	a0,s3
    800032ba:	ffffe097          	auipc	ra,0xffffe
    800032be:	9d6080e7          	jalr	-1578(ra) # 80000c90 <release>
    800032c2:	a809                	j	800032d4 <check_pending_signals+0x70>
            handle_stop(p);
    800032c4:	854e                	mv	a0,s3
    800032c6:	00000097          	auipc	ra,0x0
    800032ca:	ec6080e7          	jalr	-314(ra) # 8000318c <handle_stop>
            break;
    800032ce:	a019                	j	800032d4 <check_pending_signals+0x70>
        p->killed=1;
    800032d0:	0179ae23          	sw	s7,28(s3)
        turn_off_bit(p, sig_num);

        return;
      }

      turn_off_bit(p, sig_num);            
    800032d4:	85a6                	mv	a1,s1
    800032d6:	854e                	mv	a0,s3
    800032d8:	00000097          	auipc	ra,0x0
    800032dc:	b68080e7          	jalr	-1176(ra) # 80002e40 <turn_off_bit>
  for(int sig_num=0;sig_num<32;sig_num++){
    800032e0:	2485                	addiw	s1,s1,1
    800032e2:	0921                	addi	s2,s2,8
    800032e4:	0d548963          	beq	s1,s5,800033b6 <check_pending_signals+0x152>
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    800032e8:	009a173b          	sllw	a4,s4,s1
    800032ec:	0e89a783          	lw	a5,232(s3)
    800032f0:	8ff9                	and	a5,a5,a4
    800032f2:	2781                	sext.w	a5,a5
    800032f4:	d7f5                	beqz	a5,800032e0 <check_pending_signals+0x7c>
    800032f6:	0ec9a783          	lw	a5,236(s3)
    800032fa:	8f7d                	and	a4,a4,a5
    800032fc:	2701                	sext.w	a4,a4
    800032fe:	f36d                	bnez	a4,800032e0 <check_pending_signals+0x7c>
      act.sa_handler = p->signal_handlers[sig_num];
    80003300:	00093703          	ld	a4,0(s2)
      if(act.sa_handler == (void*)SIG_DFL){
    80003304:	df59                	beqz	a4,800032a2 <check_pending_signals+0x3e>
      else if(act.sa_handler==(void*)SIGKILL){
    80003306:	fd8705e3          	beq	a4,s8,800032d0 <check_pending_signals+0x6c>
      }else if(act.sa_handler==(void*)SIGSTOP){
    8000330a:	0d670463          	beq	a4,s6,800033d2 <check_pending_signals+0x16e>
      else if(act.sa_handler != (void*)SIG_IGN && !p->handling_user_sig_flag){ 
    8000330e:	fd7703e3          	beq	a4,s7,800032d4 <check_pending_signals+0x70>
    80003312:	2809a703          	lw	a4,640(s3)
    80003316:	ff5d                	bnez	a4,800032d4 <check_pending_signals+0x70>
      act.sigmask = p->handlers_sigmasks[sig_num];
    80003318:	07c48713          	addi	a4,s1,124
    8000331c:	070a                	slli	a4,a4,0x2
    8000331e:	974e                	add	a4,a4,s3
    80003320:	4718                	lw	a4,8(a4)
        p->handling_user_sig_flag = 1;
    80003322:	4685                	li	a3,1
    80003324:	28d9a023          	sw	a3,640(s3)
        p->signal_mask_backup = p->signal_mask;
    80003328:	0ef9a823          	sw	a5,240(s3)
        p->signal_mask= p->handlers_sigmasks[sig_num];
    8000332c:	0ee9a623          	sw	a4,236(s3)
        t->trapframe->sp -= sizeof(struct trapframe);
    80003330:	040cb703          	ld	a4,64(s9)
    80003334:	7b1c                	ld	a5,48(a4)
    80003336:	ee078793          	addi	a5,a5,-288
    8000333a:	fb1c                	sd	a5,48(a4)
        p->user_trapframe_backup = (struct trapframe* )(t->trapframe->sp);
    8000333c:	040cb783          	ld	a5,64(s9)
    80003340:	7b8c                	ld	a1,48(a5)
    80003342:	26b9bc23          	sd	a1,632(s3)
        copyout(p->pagetable, (uint64)p->user_trapframe_backup, (char *)t->trapframe, sizeof(struct trapframe));
    80003346:	12000693          	li	a3,288
    8000334a:	040cb603          	ld	a2,64(s9)
    8000334e:	0409b503          	ld	a0,64(s3)
    80003352:	ffffe097          	auipc	ra,0xffffe
    80003356:	336080e7          	jalr	822(ra) # 80001688 <copyout>
        uint64 size = (uint64)&end_sigret - (uint64)&call_sigret;
    8000335a:	00004697          	auipc	a3,0x4
    8000335e:	ae668693          	addi	a3,a3,-1306 # 80006e40 <end_sigret>
    80003362:	00004617          	auipc	a2,0x4
    80003366:	ad660613          	addi	a2,a2,-1322 # 80006e38 <call_sigret>
        t->trapframe->sp -= size;
    8000336a:	040cb703          	ld	a4,64(s9)
    8000336e:	40d605b3          	sub	a1,a2,a3
    80003372:	7b1c                	ld	a5,48(a4)
    80003374:	97ae                	add	a5,a5,a1
    80003376:	fb1c                	sd	a5,48(a4)
        copyout(p->pagetable, (uint64)t->trapframe->sp, (char *)&call_sigret, size);
    80003378:	040cb783          	ld	a5,64(s9)
    8000337c:	8e91                	sub	a3,a3,a2
    8000337e:	7b8c                	ld	a1,48(a5)
    80003380:	0409b503          	ld	a0,64(s3)
    80003384:	ffffe097          	auipc	ra,0xffffe
    80003388:	304080e7          	jalr	772(ra) # 80001688 <copyout>
        t->trapframe->a0 = sig_num;
    8000338c:	040cb783          	ld	a5,64(s9)
    80003390:	fba4                	sd	s1,112(a5)
        t->trapframe->ra = t->trapframe->sp;
    80003392:	040cb783          	ld	a5,64(s9)
    80003396:	7b98                	ld	a4,48(a5)
    80003398:	f798                	sd	a4,40(a5)
        t->trapframe->epc = (uint64)p->signal_handlers[sig_num];
    8000339a:	040cb703          	ld	a4,64(s9)
    8000339e:	01e48793          	addi	a5,s1,30
    800033a2:	078e                	slli	a5,a5,0x3
    800033a4:	97ce                	add	a5,a5,s3
    800033a6:	679c                	ld	a5,8(a5)
    800033a8:	ef1c                	sd	a5,24(a4)
        turn_off_bit(p, sig_num);
    800033aa:	85a6                	mv	a1,s1
    800033ac:	854e                	mv	a0,s3
    800033ae:	00000097          	auipc	ra,0x0
    800033b2:	a92080e7          	jalr	-1390(ra) # 80002e40 <turn_off_bit>
    }
  }
}
    800033b6:	60e6                	ld	ra,88(sp)
    800033b8:	6446                	ld	s0,80(sp)
    800033ba:	64a6                	ld	s1,72(sp)
    800033bc:	6906                	ld	s2,64(sp)
    800033be:	79e2                	ld	s3,56(sp)
    800033c0:	7a42                	ld	s4,48(sp)
    800033c2:	7aa2                	ld	s5,40(sp)
    800033c4:	7b02                	ld	s6,32(sp)
    800033c6:	6be2                	ld	s7,24(sp)
    800033c8:	6c42                	ld	s8,16(sp)
    800033ca:	6ca2                	ld	s9,8(sp)
    800033cc:	6d02                	ld	s10,0(sp)
    800033ce:	6125                	addi	sp,sp,96
    800033d0:	8082                	ret
        handle_stop(p);
    800033d2:	854e                	mv	a0,s3
    800033d4:	00000097          	auipc	ra,0x0
    800033d8:	db8080e7          	jalr	-584(ra) # 8000318c <handle_stop>
    800033dc:	bde5                	j	800032d4 <check_pending_signals+0x70>

00000000800033de <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800033de:	1101                	addi	sp,sp,-32
    800033e0:	ec06                	sd	ra,24(sp)
    800033e2:	e822                	sd	s0,16(sp)
    800033e4:	e426                	sd	s1,8(sp)
    800033e6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800033e8:	ffffe097          	auipc	ra,0xffffe
    800033ec:	6b8080e7          	jalr	1720(ra) # 80001aa0 <myproc>
    800033f0:	84aa                	mv	s1,a0
  struct kthread *t = mykthread();
    800033f2:	ffffe097          	auipc	ra,0xffffe
    800033f6:	6ee080e7          	jalr	1774(ra) # 80001ae0 <mykthread>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800033fa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800033fe:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003400:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80003404:	00004617          	auipc	a2,0x4
    80003408:	bfc60613          	addi	a2,a2,-1028 # 80007000 <_trampoline>
    8000340c:	00004697          	auipc	a3,0x4
    80003410:	bf468693          	addi	a3,a3,-1036 # 80007000 <_trampoline>
    80003414:	8e91                	sub	a3,a3,a2
    80003416:	040007b7          	lui	a5,0x4000
    8000341a:	17fd                	addi	a5,a5,-1
    8000341c:	07b2                	slli	a5,a5,0xc
    8000341e:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003420:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  t->trapframe->kernel_satp = r_satp();         // kernel page table
    80003424:	6138                	ld	a4,64(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80003426:	180026f3          	csrr	a3,satp
    8000342a:	e314                	sd	a3,0(a4)
  t->trapframe->kernel_sp = t->kstack + PGSIZE; // process's kernel stack
    8000342c:	6138                	ld	a4,64(a0)
    8000342e:	7d14                	ld	a3,56(a0)
    80003430:	6585                	lui	a1,0x1
    80003432:	96ae                	add	a3,a3,a1
    80003434:	e714                	sd	a3,8(a4)
  t->trapframe->kernel_trap = (uint64)usertrap;
    80003436:	6138                	ld	a4,64(a0)
    80003438:	00000697          	auipc	a3,0x0
    8000343c:	13a68693          	addi	a3,a3,314 # 80003572 <usertrap>
    80003440:	eb14                	sd	a3,16(a4)
  t->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80003442:	6138                	ld	a4,64(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80003444:	8692                	mv	a3,tp
    80003446:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003448:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000344c:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80003450:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003454:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(t->trapframe->epc);
    80003458:	6138                	ld	a4,64(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000345a:	6f18                	ld	a4,24(a4)
    8000345c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80003460:	60ac                	ld	a1,64(s1)
    80003462:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80003464:	00004717          	auipc	a4,0x4
    80003468:	c2c70713          	addi	a4,a4,-980 # 80007090 <userret>
    8000346c:	8f11                	sub	a4,a4,a2
    8000346e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80003470:	577d                	li	a4,-1
    80003472:	177e                	slli	a4,a4,0x3f
    80003474:	8dd9                	or	a1,a1,a4
    80003476:	02000537          	lui	a0,0x2000
    8000347a:	157d                	addi	a0,a0,-1
    8000347c:	0536                	slli	a0,a0,0xd
    8000347e:	9782                	jalr	a5
}
    80003480:	60e2                	ld	ra,24(sp)
    80003482:	6442                	ld	s0,16(sp)
    80003484:	64a2                	ld	s1,8(sp)
    80003486:	6105                	addi	sp,sp,32
    80003488:	8082                	ret

000000008000348a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000348a:	1101                	addi	sp,sp,-32
    8000348c:	ec06                	sd	ra,24(sp)
    8000348e:	e822                	sd	s0,16(sp)
    80003490:	e426                	sd	s1,8(sp)
    80003492:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80003494:	0002f497          	auipc	s1,0x2f
    80003498:	49448493          	addi	s1,s1,1172 # 80032928 <tickslock>
    8000349c:	8526                	mv	a0,s1
    8000349e:	ffffd097          	auipc	ra,0xffffd
    800034a2:	728080e7          	jalr	1832(ra) # 80000bc6 <acquire>
  ticks++;
    800034a6:	00006517          	auipc	a0,0x6
    800034aa:	b8a50513          	addi	a0,a0,-1142 # 80009030 <ticks>
    800034ae:	411c                	lw	a5,0(a0)
    800034b0:	2785                	addiw	a5,a5,1
    800034b2:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800034b4:	fffff097          	auipc	ra,0xfffff
    800034b8:	1bc080e7          	jalr	444(ra) # 80002670 <wakeup>
  release(&tickslock);
    800034bc:	8526                	mv	a0,s1
    800034be:	ffffd097          	auipc	ra,0xffffd
    800034c2:	7d2080e7          	jalr	2002(ra) # 80000c90 <release>
}
    800034c6:	60e2                	ld	ra,24(sp)
    800034c8:	6442                	ld	s0,16(sp)
    800034ca:	64a2                	ld	s1,8(sp)
    800034cc:	6105                	addi	sp,sp,32
    800034ce:	8082                	ret

00000000800034d0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800034d0:	1101                	addi	sp,sp,-32
    800034d2:	ec06                	sd	ra,24(sp)
    800034d4:	e822                	sd	s0,16(sp)
    800034d6:	e426                	sd	s1,8(sp)
    800034d8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800034da:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800034de:	00074d63          	bltz	a4,800034f8 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800034e2:	57fd                	li	a5,-1
    800034e4:	17fe                	slli	a5,a5,0x3f
    800034e6:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800034e8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800034ea:	06f70363          	beq	a4,a5,80003550 <devintr+0x80>
  }
}
    800034ee:	60e2                	ld	ra,24(sp)
    800034f0:	6442                	ld	s0,16(sp)
    800034f2:	64a2                	ld	s1,8(sp)
    800034f4:	6105                	addi	sp,sp,32
    800034f6:	8082                	ret
     (scause & 0xff) == 9){
    800034f8:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800034fc:	46a5                	li	a3,9
    800034fe:	fed792e3          	bne	a5,a3,800034e2 <devintr+0x12>
    int irq = plic_claim();
    80003502:	00003097          	auipc	ra,0x3
    80003506:	3b6080e7          	jalr	950(ra) # 800068b8 <plic_claim>
    8000350a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000350c:	47a9                	li	a5,10
    8000350e:	02f50763          	beq	a0,a5,8000353c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80003512:	4785                	li	a5,1
    80003514:	02f50963          	beq	a0,a5,80003546 <devintr+0x76>
    return 1;
    80003518:	4505                	li	a0,1
    } else if(irq){
    8000351a:	d8f1                	beqz	s1,800034ee <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000351c:	85a6                	mv	a1,s1
    8000351e:	00005517          	auipc	a0,0x5
    80003522:	f5a50513          	addi	a0,a0,-166 # 80008478 <states.0+0x28>
    80003526:	ffffd097          	auipc	ra,0xffffd
    8000352a:	052080e7          	jalr	82(ra) # 80000578 <printf>
      plic_complete(irq);
    8000352e:	8526                	mv	a0,s1
    80003530:	00003097          	auipc	ra,0x3
    80003534:	3ac080e7          	jalr	940(ra) # 800068dc <plic_complete>
    return 1;
    80003538:	4505                	li	a0,1
    8000353a:	bf55                	j	800034ee <devintr+0x1e>
      uartintr();
    8000353c:	ffffd097          	auipc	ra,0xffffd
    80003540:	44e080e7          	jalr	1102(ra) # 8000098a <uartintr>
    80003544:	b7ed                	j	8000352e <devintr+0x5e>
      virtio_disk_intr();
    80003546:	00004097          	auipc	ra,0x4
    8000354a:	828080e7          	jalr	-2008(ra) # 80006d6e <virtio_disk_intr>
    8000354e:	b7c5                	j	8000352e <devintr+0x5e>
    if(cpuid() == 0){
    80003550:	ffffe097          	auipc	ra,0xffffe
    80003554:	51c080e7          	jalr	1308(ra) # 80001a6c <cpuid>
    80003558:	c901                	beqz	a0,80003568 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000355a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000355e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80003560:	14479073          	csrw	sip,a5
    return 2;
    80003564:	4509                	li	a0,2
    80003566:	b761                	j	800034ee <devintr+0x1e>
      clockintr();
    80003568:	00000097          	auipc	ra,0x0
    8000356c:	f22080e7          	jalr	-222(ra) # 8000348a <clockintr>
    80003570:	b7ed                	j	8000355a <devintr+0x8a>

0000000080003572 <usertrap>:
{
    80003572:	1101                	addi	sp,sp,-32
    80003574:	ec06                	sd	ra,24(sp)
    80003576:	e822                	sd	s0,16(sp)
    80003578:	e426                	sd	s1,8(sp)
    8000357a:	e04a                	sd	s2,0(sp)
    8000357c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000357e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003582:	1007f793          	andi	a5,a5,256
    80003586:	e3dd                	bnez	a5,8000362c <usertrap+0xba>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003588:	00003797          	auipc	a5,0x3
    8000358c:	22878793          	addi	a5,a5,552 # 800067b0 <kernelvec>
    80003590:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80003594:	ffffe097          	auipc	ra,0xffffe
    80003598:	50c080e7          	jalr	1292(ra) # 80001aa0 <myproc>
    8000359c:	84aa                	mv	s1,a0
  struct kthread *t = mykthread();
    8000359e:	ffffe097          	auipc	ra,0xffffe
    800035a2:	542080e7          	jalr	1346(ra) # 80001ae0 <mykthread>
    800035a6:	892a                	mv	s2,a0
  t->trapframe->epc = r_sepc();
    800035a8:	613c                	ld	a5,64(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800035aa:	14102773          	csrr	a4,sepc
    800035ae:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800035b0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800035b4:	47a1                	li	a5,8
    800035b6:	08f71f63          	bne	a4,a5,80003654 <usertrap+0xe2>
    if(t->killed == 1)
    800035ba:	5518                	lw	a4,40(a0)
    800035bc:	4785                	li	a5,1
    800035be:	06f70f63          	beq	a4,a5,8000363c <usertrap+0xca>
    else if(p->killed)
    800035c2:	4cdc                	lw	a5,28(s1)
    800035c4:	e3d1                	bnez	a5,80003648 <usertrap+0xd6>
    t->trapframe->epc += 4;
    800035c6:	04093703          	ld	a4,64(s2)
    800035ca:	6f1c                	ld	a5,24(a4)
    800035cc:	0791                	addi	a5,a5,4
    800035ce:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800035d0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800035d4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800035d8:	10079073          	csrw	sstatus,a5
    syscall();
    800035dc:	00000097          	auipc	ra,0x0
    800035e0:	370080e7          	jalr	880(ra) # 8000394c <syscall>
  if(holding(&p->lock))
    800035e4:	8526                	mv	a0,s1
    800035e6:	ffffd097          	auipc	ra,0xffffd
    800035ea:	566080e7          	jalr	1382(ra) # 80000b4c <holding>
    800035ee:	e95d                	bnez	a0,800036a4 <usertrap+0x132>
  acquire(&p->lock);
    800035f0:	8526                	mv	a0,s1
    800035f2:	ffffd097          	auipc	ra,0xffffd
    800035f6:	5d4080e7          	jalr	1492(ra) # 80000bc6 <acquire>
  if(!p->handling_sig_flag){
    800035fa:	2844a783          	lw	a5,644(s1)
    800035fe:	cfc5                	beqz	a5,800036b6 <usertrap+0x144>
  release(&p->lock);
    80003600:	8526                	mv	a0,s1
    80003602:	ffffd097          	auipc	ra,0xffffd
    80003606:	68e080e7          	jalr	1678(ra) # 80000c90 <release>
  if(t->killed == 1)
    8000360a:	02892703          	lw	a4,40(s2)
    8000360e:	4785                	li	a5,1
    80003610:	0cf70863          	beq	a4,a5,800036e0 <usertrap+0x16e>
  else if(p->killed)
    80003614:	4cdc                	lw	a5,28(s1)
    80003616:	ebf9                	bnez	a5,800036ec <usertrap+0x17a>
  usertrapret();
    80003618:	00000097          	auipc	ra,0x0
    8000361c:	dc6080e7          	jalr	-570(ra) # 800033de <usertrapret>
}
    80003620:	60e2                	ld	ra,24(sp)
    80003622:	6442                	ld	s0,16(sp)
    80003624:	64a2                	ld	s1,8(sp)
    80003626:	6902                	ld	s2,0(sp)
    80003628:	6105                	addi	sp,sp,32
    8000362a:	8082                	ret
    panic("usertrap: not from user mode");
    8000362c:	00005517          	auipc	a0,0x5
    80003630:	e6c50513          	addi	a0,a0,-404 # 80008498 <states.0+0x48>
    80003634:	ffffd097          	auipc	ra,0xffffd
    80003638:	efa080e7          	jalr	-262(ra) # 8000052e <panic>
      kthread_exit(-1); // Kill current thread
    8000363c:	557d                	li	a0,-1
    8000363e:	fffff097          	auipc	ra,0xfffff
    80003642:	22e080e7          	jalr	558(ra) # 8000286c <kthread_exit>
    80003646:	b741                	j	800035c6 <usertrap+0x54>
      exit(-1); // Kill the hole procces
    80003648:	557d                	li	a0,-1
    8000364a:	fffff097          	auipc	ra,0xfffff
    8000364e:	2b6080e7          	jalr	694(ra) # 80002900 <exit>
    80003652:	bf95                	j	800035c6 <usertrap+0x54>
  else if((which_dev = devintr()) != 0)
    80003654:	00000097          	auipc	ra,0x0
    80003658:	e7c080e7          	jalr	-388(ra) # 800034d0 <devintr>
    8000365c:	c909                	beqz	a0,8000366e <usertrap+0xfc>
  if(which_dev == 2)
    8000365e:	4789                	li	a5,2
    80003660:	f8f512e3          	bne	a0,a5,800035e4 <usertrap+0x72>
    yield();
    80003664:	fffff097          	auipc	ra,0xfffff
    80003668:	e46080e7          	jalr	-442(ra) # 800024aa <yield>
    8000366c:	bfa5                	j	800035e4 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000366e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80003672:	50d0                	lw	a2,36(s1)
    80003674:	00005517          	auipc	a0,0x5
    80003678:	e4450513          	addi	a0,a0,-444 # 800084b8 <states.0+0x68>
    8000367c:	ffffd097          	auipc	ra,0xffffd
    80003680:	efc080e7          	jalr	-260(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003684:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003688:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000368c:	00005517          	auipc	a0,0x5
    80003690:	e5c50513          	addi	a0,a0,-420 # 800084e8 <states.0+0x98>
    80003694:	ffffd097          	auipc	ra,0xffffd
    80003698:	ee4080e7          	jalr	-284(ra) # 80000578 <printf>
    t->killed = 1;
    8000369c:	4785                	li	a5,1
    8000369e:	02f92423          	sw	a5,40(s2)
  if(which_dev == 2)
    800036a2:	b789                	j	800035e4 <usertrap+0x72>
    printf("fuck i am holding the lock in usertrap\n");   // TODO : delete
    800036a4:	00005517          	auipc	a0,0x5
    800036a8:	e6450513          	addi	a0,a0,-412 # 80008508 <states.0+0xb8>
    800036ac:	ffffd097          	auipc	ra,0xffffd
    800036b0:	ecc080e7          	jalr	-308(ra) # 80000578 <printf>
    800036b4:	bf35                	j	800035f0 <usertrap+0x7e>
    p->handling_sig_flag = 1;
    800036b6:	4785                	li	a5,1
    800036b8:	28f4a223          	sw	a5,644(s1)
    release(&p->lock);
    800036bc:	8526                	mv	a0,s1
    800036be:	ffffd097          	auipc	ra,0xffffd
    800036c2:	5d2080e7          	jalr	1490(ra) # 80000c90 <release>
    check_pending_signals(p);
    800036c6:	8526                	mv	a0,s1
    800036c8:	00000097          	auipc	ra,0x0
    800036cc:	b9c080e7          	jalr	-1124(ra) # 80003264 <check_pending_signals>
    acquire(&p->lock);
    800036d0:	8526                	mv	a0,s1
    800036d2:	ffffd097          	auipc	ra,0xffffd
    800036d6:	4f4080e7          	jalr	1268(ra) # 80000bc6 <acquire>
    p->handling_sig_flag = 0;
    800036da:	2804a223          	sw	zero,644(s1)
    800036de:	b70d                	j	80003600 <usertrap+0x8e>
    kthread_exit(-1); // Kill current thread
    800036e0:	557d                	li	a0,-1
    800036e2:	fffff097          	auipc	ra,0xfffff
    800036e6:	18a080e7          	jalr	394(ra) # 8000286c <kthread_exit>
    800036ea:	b73d                	j	80003618 <usertrap+0xa6>
    exit(-1); // Kill the hole procces
    800036ec:	557d                	li	a0,-1
    800036ee:	fffff097          	auipc	ra,0xfffff
    800036f2:	212080e7          	jalr	530(ra) # 80002900 <exit>
    800036f6:	b70d                	j	80003618 <usertrap+0xa6>

00000000800036f8 <kerneltrap>:
{
    800036f8:	7179                	addi	sp,sp,-48
    800036fa:	f406                	sd	ra,40(sp)
    800036fc:	f022                	sd	s0,32(sp)
    800036fe:	ec26                	sd	s1,24(sp)
    80003700:	e84a                	sd	s2,16(sp)
    80003702:	e44e                	sd	s3,8(sp)
    80003704:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003706:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000370a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000370e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80003712:	1004f793          	andi	a5,s1,256
    80003716:	cb85                	beqz	a5,80003746 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003718:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000371c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000371e:	ef85                	bnez	a5,80003756 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80003720:	00000097          	auipc	ra,0x0
    80003724:	db0080e7          	jalr	-592(ra) # 800034d0 <devintr>
    80003728:	cd1d                	beqz	a0,80003766 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    8000372a:	4789                	li	a5,2
    8000372c:	06f50a63          	beq	a0,a5,800037a0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003730:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003734:	10049073          	csrw	sstatus,s1
}
    80003738:	70a2                	ld	ra,40(sp)
    8000373a:	7402                	ld	s0,32(sp)
    8000373c:	64e2                	ld	s1,24(sp)
    8000373e:	6942                	ld	s2,16(sp)
    80003740:	69a2                	ld	s3,8(sp)
    80003742:	6145                	addi	sp,sp,48
    80003744:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80003746:	00005517          	auipc	a0,0x5
    8000374a:	dea50513          	addi	a0,a0,-534 # 80008530 <states.0+0xe0>
    8000374e:	ffffd097          	auipc	ra,0xffffd
    80003752:	de0080e7          	jalr	-544(ra) # 8000052e <panic>
    panic("kerneltrap: interrupts enabled");
    80003756:	00005517          	auipc	a0,0x5
    8000375a:	e0250513          	addi	a0,a0,-510 # 80008558 <states.0+0x108>
    8000375e:	ffffd097          	auipc	ra,0xffffd
    80003762:	dd0080e7          	jalr	-560(ra) # 8000052e <panic>
    printf("scause %p\n", scause);
    80003766:	85ce                	mv	a1,s3
    80003768:	00005517          	auipc	a0,0x5
    8000376c:	e1050513          	addi	a0,a0,-496 # 80008578 <states.0+0x128>
    80003770:	ffffd097          	auipc	ra,0xffffd
    80003774:	e08080e7          	jalr	-504(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003778:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000377c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003780:	00005517          	auipc	a0,0x5
    80003784:	e0850513          	addi	a0,a0,-504 # 80008588 <states.0+0x138>
    80003788:	ffffd097          	auipc	ra,0xffffd
    8000378c:	df0080e7          	jalr	-528(ra) # 80000578 <printf>
    panic("kerneltrap");
    80003790:	00005517          	auipc	a0,0x5
    80003794:	e1050513          	addi	a0,a0,-496 # 800085a0 <states.0+0x150>
    80003798:	ffffd097          	auipc	ra,0xffffd
    8000379c:	d96080e7          	jalr	-618(ra) # 8000052e <panic>
  if(which_dev == 2 && myproc() != 0 && mykthread()!=0 && mykthread()->state == TRUNNING)
    800037a0:	ffffe097          	auipc	ra,0xffffe
    800037a4:	300080e7          	jalr	768(ra) # 80001aa0 <myproc>
    800037a8:	d541                	beqz	a0,80003730 <kerneltrap+0x38>
    800037aa:	ffffe097          	auipc	ra,0xffffe
    800037ae:	336080e7          	jalr	822(ra) # 80001ae0 <mykthread>
    800037b2:	dd3d                	beqz	a0,80003730 <kerneltrap+0x38>
    800037b4:	ffffe097          	auipc	ra,0xffffe
    800037b8:	32c080e7          	jalr	812(ra) # 80001ae0 <mykthread>
    800037bc:	4d18                	lw	a4,24(a0)
    800037be:	4791                	li	a5,4
    800037c0:	f6f718e3          	bne	a4,a5,80003730 <kerneltrap+0x38>
    yield();
    800037c4:	fffff097          	auipc	ra,0xfffff
    800037c8:	ce6080e7          	jalr	-794(ra) # 800024aa <yield>
    800037cc:	b795                	j	80003730 <kerneltrap+0x38>

00000000800037ce <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800037ce:	1101                	addi	sp,sp,-32
    800037d0:	ec06                	sd	ra,24(sp)
    800037d2:	e822                	sd	s0,16(sp)
    800037d4:	e426                	sd	s1,8(sp)
    800037d6:	1000                	addi	s0,sp,32
    800037d8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800037da:	ffffe097          	auipc	ra,0xffffe
    800037de:	2c6080e7          	jalr	710(ra) # 80001aa0 <myproc>
  struct kthread *t = mykthread();
    800037e2:	ffffe097          	auipc	ra,0xffffe
    800037e6:	2fe080e7          	jalr	766(ra) # 80001ae0 <mykthread>
  switch (n) {
    800037ea:	4795                	li	a5,5
    800037ec:	0497e163          	bltu	a5,s1,8000382e <argraw+0x60>
    800037f0:	048a                	slli	s1,s1,0x2
    800037f2:	00005717          	auipc	a4,0x5
    800037f6:	de670713          	addi	a4,a4,-538 # 800085d8 <states.0+0x188>
    800037fa:	94ba                	add	s1,s1,a4
    800037fc:	409c                	lw	a5,0(s1)
    800037fe:	97ba                	add	a5,a5,a4
    80003800:	8782                	jr	a5
  case 0:
    return t->trapframe->a0;
    80003802:	613c                	ld	a5,64(a0)
    80003804:	7ba8                	ld	a0,112(a5)
  case 5:
    return t->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80003806:	60e2                	ld	ra,24(sp)
    80003808:	6442                	ld	s0,16(sp)
    8000380a:	64a2                	ld	s1,8(sp)
    8000380c:	6105                	addi	sp,sp,32
    8000380e:	8082                	ret
    return t->trapframe->a1;
    80003810:	613c                	ld	a5,64(a0)
    80003812:	7fa8                	ld	a0,120(a5)
    80003814:	bfcd                	j	80003806 <argraw+0x38>
    return t->trapframe->a2;
    80003816:	613c                	ld	a5,64(a0)
    80003818:	63c8                	ld	a0,128(a5)
    8000381a:	b7f5                	j	80003806 <argraw+0x38>
    return t->trapframe->a3;
    8000381c:	613c                	ld	a5,64(a0)
    8000381e:	67c8                	ld	a0,136(a5)
    80003820:	b7dd                	j	80003806 <argraw+0x38>
    return t->trapframe->a4;
    80003822:	613c                	ld	a5,64(a0)
    80003824:	6bc8                	ld	a0,144(a5)
    80003826:	b7c5                	j	80003806 <argraw+0x38>
    return t->trapframe->a5;
    80003828:	613c                	ld	a5,64(a0)
    8000382a:	6fc8                	ld	a0,152(a5)
    8000382c:	bfe9                	j	80003806 <argraw+0x38>
  panic("argraw");
    8000382e:	00005517          	auipc	a0,0x5
    80003832:	d8250513          	addi	a0,a0,-638 # 800085b0 <states.0+0x160>
    80003836:	ffffd097          	auipc	ra,0xffffd
    8000383a:	cf8080e7          	jalr	-776(ra) # 8000052e <panic>

000000008000383e <fetchaddr>:
{
    8000383e:	1101                	addi	sp,sp,-32
    80003840:	ec06                	sd	ra,24(sp)
    80003842:	e822                	sd	s0,16(sp)
    80003844:	e426                	sd	s1,8(sp)
    80003846:	e04a                	sd	s2,0(sp)
    80003848:	1000                	addi	s0,sp,32
    8000384a:	84aa                	mv	s1,a0
    8000384c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000384e:	ffffe097          	auipc	ra,0xffffe
    80003852:	252080e7          	jalr	594(ra) # 80001aa0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80003856:	7d1c                	ld	a5,56(a0)
    80003858:	02f4f863          	bgeu	s1,a5,80003888 <fetchaddr+0x4a>
    8000385c:	00848713          	addi	a4,s1,8
    80003860:	02e7e663          	bltu	a5,a4,8000388c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80003864:	46a1                	li	a3,8
    80003866:	8626                	mv	a2,s1
    80003868:	85ca                	mv	a1,s2
    8000386a:	6128                	ld	a0,64(a0)
    8000386c:	ffffe097          	auipc	ra,0xffffe
    80003870:	ea8080e7          	jalr	-344(ra) # 80001714 <copyin>
    80003874:	00a03533          	snez	a0,a0
    80003878:	40a00533          	neg	a0,a0
}
    8000387c:	60e2                	ld	ra,24(sp)
    8000387e:	6442                	ld	s0,16(sp)
    80003880:	64a2                	ld	s1,8(sp)
    80003882:	6902                	ld	s2,0(sp)
    80003884:	6105                	addi	sp,sp,32
    80003886:	8082                	ret
    return -1;
    80003888:	557d                	li	a0,-1
    8000388a:	bfcd                	j	8000387c <fetchaddr+0x3e>
    8000388c:	557d                	li	a0,-1
    8000388e:	b7fd                	j	8000387c <fetchaddr+0x3e>

0000000080003890 <fetchstr>:
{
    80003890:	7179                	addi	sp,sp,-48
    80003892:	f406                	sd	ra,40(sp)
    80003894:	f022                	sd	s0,32(sp)
    80003896:	ec26                	sd	s1,24(sp)
    80003898:	e84a                	sd	s2,16(sp)
    8000389a:	e44e                	sd	s3,8(sp)
    8000389c:	1800                	addi	s0,sp,48
    8000389e:	892a                	mv	s2,a0
    800038a0:	84ae                	mv	s1,a1
    800038a2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800038a4:	ffffe097          	auipc	ra,0xffffe
    800038a8:	1fc080e7          	jalr	508(ra) # 80001aa0 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    800038ac:	86ce                	mv	a3,s3
    800038ae:	864a                	mv	a2,s2
    800038b0:	85a6                	mv	a1,s1
    800038b2:	6128                	ld	a0,64(a0)
    800038b4:	ffffe097          	auipc	ra,0xffffe
    800038b8:	eee080e7          	jalr	-274(ra) # 800017a2 <copyinstr>
  if(err < 0)
    800038bc:	00054763          	bltz	a0,800038ca <fetchstr+0x3a>
  return strlen(buf);
    800038c0:	8526                	mv	a0,s1
    800038c2:	ffffd097          	auipc	ra,0xffffd
    800038c6:	59a080e7          	jalr	1434(ra) # 80000e5c <strlen>
}
    800038ca:	70a2                	ld	ra,40(sp)
    800038cc:	7402                	ld	s0,32(sp)
    800038ce:	64e2                	ld	s1,24(sp)
    800038d0:	6942                	ld	s2,16(sp)
    800038d2:	69a2                	ld	s3,8(sp)
    800038d4:	6145                	addi	sp,sp,48
    800038d6:	8082                	ret

00000000800038d8 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    800038d8:	1101                	addi	sp,sp,-32
    800038da:	ec06                	sd	ra,24(sp)
    800038dc:	e822                	sd	s0,16(sp)
    800038de:	e426                	sd	s1,8(sp)
    800038e0:	1000                	addi	s0,sp,32
    800038e2:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800038e4:	00000097          	auipc	ra,0x0
    800038e8:	eea080e7          	jalr	-278(ra) # 800037ce <argraw>
    800038ec:	c088                	sw	a0,0(s1)
  return 0;
}
    800038ee:	4501                	li	a0,0
    800038f0:	60e2                	ld	ra,24(sp)
    800038f2:	6442                	ld	s0,16(sp)
    800038f4:	64a2                	ld	s1,8(sp)
    800038f6:	6105                	addi	sp,sp,32
    800038f8:	8082                	ret

00000000800038fa <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    800038fa:	1101                	addi	sp,sp,-32
    800038fc:	ec06                	sd	ra,24(sp)
    800038fe:	e822                	sd	s0,16(sp)
    80003900:	e426                	sd	s1,8(sp)
    80003902:	1000                	addi	s0,sp,32
    80003904:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80003906:	00000097          	auipc	ra,0x0
    8000390a:	ec8080e7          	jalr	-312(ra) # 800037ce <argraw>
    8000390e:	e088                	sd	a0,0(s1)
  return 0;
}
    80003910:	4501                	li	a0,0
    80003912:	60e2                	ld	ra,24(sp)
    80003914:	6442                	ld	s0,16(sp)
    80003916:	64a2                	ld	s1,8(sp)
    80003918:	6105                	addi	sp,sp,32
    8000391a:	8082                	ret

000000008000391c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000391c:	1101                	addi	sp,sp,-32
    8000391e:	ec06                	sd	ra,24(sp)
    80003920:	e822                	sd	s0,16(sp)
    80003922:	e426                	sd	s1,8(sp)
    80003924:	e04a                	sd	s2,0(sp)
    80003926:	1000                	addi	s0,sp,32
    80003928:	84ae                	mv	s1,a1
    8000392a:	8932                	mv	s2,a2
  *ip = argraw(n);
    8000392c:	00000097          	auipc	ra,0x0
    80003930:	ea2080e7          	jalr	-350(ra) # 800037ce <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80003934:	864a                	mv	a2,s2
    80003936:	85a6                	mv	a1,s1
    80003938:	00000097          	auipc	ra,0x0
    8000393c:	f58080e7          	jalr	-168(ra) # 80003890 <fetchstr>
}
    80003940:	60e2                	ld	ra,24(sp)
    80003942:	6442                	ld	s0,16(sp)
    80003944:	64a2                	ld	s1,8(sp)
    80003946:	6902                	ld	s2,0(sp)
    80003948:	6105                	addi	sp,sp,32
    8000394a:	8082                	ret

000000008000394c <syscall>:
[SYS_kthread_join] sys_kthread_join,
};

void
syscall(void)
{
    8000394c:	7179                	addi	sp,sp,-48
    8000394e:	f406                	sd	ra,40(sp)
    80003950:	f022                	sd	s0,32(sp)
    80003952:	ec26                	sd	s1,24(sp)
    80003954:	e84a                	sd	s2,16(sp)
    80003956:	e44e                	sd	s3,8(sp)
    80003958:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    8000395a:	ffffe097          	auipc	ra,0xffffe
    8000395e:	146080e7          	jalr	326(ra) # 80001aa0 <myproc>
    80003962:	892a                	mv	s2,a0
  struct kthread *t = mykthread();
    80003964:	ffffe097          	auipc	ra,0xffffe
    80003968:	17c080e7          	jalr	380(ra) # 80001ae0 <mykthread>
    8000396c:	84aa                	mv	s1,a0

  num = t->trapframe->a7;
    8000396e:	04053983          	ld	s3,64(a0)
    80003972:	0a89b783          	ld	a5,168(s3)
    80003976:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000397a:	37fd                	addiw	a5,a5,-1
    8000397c:	476d                	li	a4,27
    8000397e:	00f76f63          	bltu	a4,a5,8000399c <syscall+0x50>
    80003982:	00369713          	slli	a4,a3,0x3
    80003986:	00005797          	auipc	a5,0x5
    8000398a:	c6a78793          	addi	a5,a5,-918 # 800085f0 <syscalls>
    8000398e:	97ba                	add	a5,a5,a4
    80003990:	639c                	ld	a5,0(a5)
    80003992:	c789                	beqz	a5,8000399c <syscall+0x50>
    t->trapframe->a0 = syscalls[num]();
    80003994:	9782                	jalr	a5
    80003996:	06a9b823          	sd	a0,112(s3)
    8000399a:	a005                	j	800039ba <syscall+0x6e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000399c:	0d890613          	addi	a2,s2,216
    800039a0:	02492583          	lw	a1,36(s2)
    800039a4:	00005517          	auipc	a0,0x5
    800039a8:	c1450513          	addi	a0,a0,-1004 # 800085b8 <states.0+0x168>
    800039ac:	ffffd097          	auipc	ra,0xffffd
    800039b0:	bcc080e7          	jalr	-1076(ra) # 80000578 <printf>
            p->pid, p->name, num);
    t->trapframe->a0 = -1;
    800039b4:	60bc                	ld	a5,64(s1)
    800039b6:	577d                	li	a4,-1
    800039b8:	fbb8                	sd	a4,112(a5)
  }
}
    800039ba:	70a2                	ld	ra,40(sp)
    800039bc:	7402                	ld	s0,32(sp)
    800039be:	64e2                	ld	s1,24(sp)
    800039c0:	6942                	ld	s2,16(sp)
    800039c2:	69a2                	ld	s3,8(sp)
    800039c4:	6145                	addi	sp,sp,48
    800039c6:	8082                	ret

00000000800039c8 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800039c8:	1101                	addi	sp,sp,-32
    800039ca:	ec06                	sd	ra,24(sp)
    800039cc:	e822                	sd	s0,16(sp)
    800039ce:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800039d0:	fec40593          	addi	a1,s0,-20
    800039d4:	4501                	li	a0,0
    800039d6:	00000097          	auipc	ra,0x0
    800039da:	f02080e7          	jalr	-254(ra) # 800038d8 <argint>
    return -1;
    800039de:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800039e0:	00054963          	bltz	a0,800039f2 <sys_exit+0x2a>
  exit(n);
    800039e4:	fec42503          	lw	a0,-20(s0)
    800039e8:	fffff097          	auipc	ra,0xfffff
    800039ec:	f18080e7          	jalr	-232(ra) # 80002900 <exit>
  return 0;  // not reached
    800039f0:	4781                	li	a5,0
}
    800039f2:	853e                	mv	a0,a5
    800039f4:	60e2                	ld	ra,24(sp)
    800039f6:	6442                	ld	s0,16(sp)
    800039f8:	6105                	addi	sp,sp,32
    800039fa:	8082                	ret

00000000800039fc <sys_getpid>:

uint64
sys_getpid(void)
{
    800039fc:	1141                	addi	sp,sp,-16
    800039fe:	e406                	sd	ra,8(sp)
    80003a00:	e022                	sd	s0,0(sp)
    80003a02:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80003a04:	ffffe097          	auipc	ra,0xffffe
    80003a08:	09c080e7          	jalr	156(ra) # 80001aa0 <myproc>
}
    80003a0c:	5148                	lw	a0,36(a0)
    80003a0e:	60a2                	ld	ra,8(sp)
    80003a10:	6402                	ld	s0,0(sp)
    80003a12:	0141                	addi	sp,sp,16
    80003a14:	8082                	ret

0000000080003a16 <sys_fork>:

uint64
sys_fork(void)
{
    80003a16:	1141                	addi	sp,sp,-16
    80003a18:	e406                	sd	ra,8(sp)
    80003a1a:	e022                	sd	s0,0(sp)
    80003a1c:	0800                	addi	s0,sp,16
  return fork();
    80003a1e:	ffffe097          	auipc	ra,0xffffe
    80003a22:	712080e7          	jalr	1810(ra) # 80002130 <fork>
}
    80003a26:	60a2                	ld	ra,8(sp)
    80003a28:	6402                	ld	s0,0(sp)
    80003a2a:	0141                	addi	sp,sp,16
    80003a2c:	8082                	ret

0000000080003a2e <sys_wait>:

uint64
sys_wait(void)
{
    80003a2e:	1101                	addi	sp,sp,-32
    80003a30:	ec06                	sd	ra,24(sp)
    80003a32:	e822                	sd	s0,16(sp)
    80003a34:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80003a36:	fe840593          	addi	a1,s0,-24
    80003a3a:	4501                	li	a0,0
    80003a3c:	00000097          	auipc	ra,0x0
    80003a40:	ebe080e7          	jalr	-322(ra) # 800038fa <argaddr>
    80003a44:	87aa                	mv	a5,a0
    return -1;
    80003a46:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80003a48:	0007c863          	bltz	a5,80003a58 <sys_wait+0x2a>
  return wait(p);
    80003a4c:	fe843503          	ld	a0,-24(s0)
    80003a50:	fffff097          	auipc	ra,0xfffff
    80003a54:	afa080e7          	jalr	-1286(ra) # 8000254a <wait>
}
    80003a58:	60e2                	ld	ra,24(sp)
    80003a5a:	6442                	ld	s0,16(sp)
    80003a5c:	6105                	addi	sp,sp,32
    80003a5e:	8082                	ret

0000000080003a60 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003a60:	7179                	addi	sp,sp,-48
    80003a62:	f406                	sd	ra,40(sp)
    80003a64:	f022                	sd	s0,32(sp)
    80003a66:	ec26                	sd	s1,24(sp)
    80003a68:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80003a6a:	fdc40593          	addi	a1,s0,-36
    80003a6e:	4501                	li	a0,0
    80003a70:	00000097          	auipc	ra,0x0
    80003a74:	e68080e7          	jalr	-408(ra) # 800038d8 <argint>
    return -1;
    80003a78:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80003a7a:	00054f63          	bltz	a0,80003a98 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80003a7e:	ffffe097          	auipc	ra,0xffffe
    80003a82:	022080e7          	jalr	34(ra) # 80001aa0 <myproc>
    80003a86:	5d04                	lw	s1,56(a0)
  if(growproc(n) < 0)
    80003a88:	fdc42503          	lw	a0,-36(s0)
    80003a8c:	ffffe097          	auipc	ra,0xffffe
    80003a90:	630080e7          	jalr	1584(ra) # 800020bc <growproc>
    80003a94:	00054863          	bltz	a0,80003aa4 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80003a98:	8526                	mv	a0,s1
    80003a9a:	70a2                	ld	ra,40(sp)
    80003a9c:	7402                	ld	s0,32(sp)
    80003a9e:	64e2                	ld	s1,24(sp)
    80003aa0:	6145                	addi	sp,sp,48
    80003aa2:	8082                	ret
    return -1;
    80003aa4:	54fd                	li	s1,-1
    80003aa6:	bfcd                	j	80003a98 <sys_sbrk+0x38>

0000000080003aa8 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003aa8:	7139                	addi	sp,sp,-64
    80003aaa:	fc06                	sd	ra,56(sp)
    80003aac:	f822                	sd	s0,48(sp)
    80003aae:	f426                	sd	s1,40(sp)
    80003ab0:	f04a                	sd	s2,32(sp)
    80003ab2:	ec4e                	sd	s3,24(sp)
    80003ab4:	e852                	sd	s4,16(sp)
    80003ab6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003ab8:	fcc40593          	addi	a1,s0,-52
    80003abc:	4501                	li	a0,0
    80003abe:	00000097          	auipc	ra,0x0
    80003ac2:	e1a080e7          	jalr	-486(ra) # 800038d8 <argint>
    return -1;
    80003ac6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003ac8:	06054763          	bltz	a0,80003b36 <sys_sleep+0x8e>
  acquire(&tickslock);
    80003acc:	0002f517          	auipc	a0,0x2f
    80003ad0:	e5c50513          	addi	a0,a0,-420 # 80032928 <tickslock>
    80003ad4:	ffffd097          	auipc	ra,0xffffd
    80003ad8:	0f2080e7          	jalr	242(ra) # 80000bc6 <acquire>
  ticks0 = ticks;
    80003adc:	00005997          	auipc	s3,0x5
    80003ae0:	5549a983          	lw	s3,1364(s3) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80003ae4:	fcc42783          	lw	a5,-52(s0)
    80003ae8:	cf95                	beqz	a5,80003b24 <sys_sleep+0x7c>
    if(myproc()->killed==1){
    80003aea:	4905                	li	s2,1
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003aec:	0002fa17          	auipc	s4,0x2f
    80003af0:	e3ca0a13          	addi	s4,s4,-452 # 80032928 <tickslock>
    80003af4:	00005497          	auipc	s1,0x5
    80003af8:	53c48493          	addi	s1,s1,1340 # 80009030 <ticks>
    if(myproc()->killed==1){
    80003afc:	ffffe097          	auipc	ra,0xffffe
    80003b00:	fa4080e7          	jalr	-92(ra) # 80001aa0 <myproc>
    80003b04:	4d5c                	lw	a5,28(a0)
    80003b06:	05278163          	beq	a5,s2,80003b48 <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    80003b0a:	85d2                	mv	a1,s4
    80003b0c:	8526                	mv	a0,s1
    80003b0e:	fffff097          	auipc	ra,0xfffff
    80003b12:	9d8080e7          	jalr	-1576(ra) # 800024e6 <sleep>
  while(ticks - ticks0 < n){
    80003b16:	409c                	lw	a5,0(s1)
    80003b18:	413787bb          	subw	a5,a5,s3
    80003b1c:	fcc42703          	lw	a4,-52(s0)
    80003b20:	fce7eee3          	bltu	a5,a4,80003afc <sys_sleep+0x54>
  }
  release(&tickslock);
    80003b24:	0002f517          	auipc	a0,0x2f
    80003b28:	e0450513          	addi	a0,a0,-508 # 80032928 <tickslock>
    80003b2c:	ffffd097          	auipc	ra,0xffffd
    80003b30:	164080e7          	jalr	356(ra) # 80000c90 <release>
  return 0;
    80003b34:	4781                	li	a5,0
}
    80003b36:	853e                	mv	a0,a5
    80003b38:	70e2                	ld	ra,56(sp)
    80003b3a:	7442                	ld	s0,48(sp)
    80003b3c:	74a2                	ld	s1,40(sp)
    80003b3e:	7902                	ld	s2,32(sp)
    80003b40:	69e2                	ld	s3,24(sp)
    80003b42:	6a42                	ld	s4,16(sp)
    80003b44:	6121                	addi	sp,sp,64
    80003b46:	8082                	ret
      release(&tickslock);
    80003b48:	0002f517          	auipc	a0,0x2f
    80003b4c:	de050513          	addi	a0,a0,-544 # 80032928 <tickslock>
    80003b50:	ffffd097          	auipc	ra,0xffffd
    80003b54:	140080e7          	jalr	320(ra) # 80000c90 <release>
      return -1;
    80003b58:	57fd                	li	a5,-1
    80003b5a:	bff1                	j	80003b36 <sys_sleep+0x8e>

0000000080003b5c <sys_kill>:

uint64
sys_kill(void)
{
    80003b5c:	1101                	addi	sp,sp,-32
    80003b5e:	ec06                	sd	ra,24(sp)
    80003b60:	e822                	sd	s0,16(sp)
    80003b62:	1000                	addi	s0,sp,32
  int pid;
  int signum;

  if(argint(0, &pid) < 0)
    80003b64:	fec40593          	addi	a1,s0,-20
    80003b68:	4501                	li	a0,0
    80003b6a:	00000097          	auipc	ra,0x0
    80003b6e:	d6e080e7          	jalr	-658(ra) # 800038d8 <argint>
    80003b72:	87aa                	mv	a5,a0
    return -1;
    80003b74:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80003b76:	0207c963          	bltz	a5,80003ba8 <sys_kill+0x4c>
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003b7a:	fe840593          	addi	a1,s0,-24
    80003b7e:	4505                	li	a0,1
    80003b80:	00000097          	auipc	ra,0x0
    80003b84:	d58080e7          	jalr	-680(ra) # 800038d8 <argint>
    80003b88:	02054463          	bltz	a0,80003bb0 <sys_kill+0x54>
    80003b8c:	fe842583          	lw	a1,-24(s0)
    80003b90:	0005871b          	sext.w	a4,a1
    80003b94:	47fd                	li	a5,31
    return -1;
    80003b96:	557d                	li	a0,-1
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    80003b98:	00e7e863          	bltu	a5,a4,80003ba8 <sys_kill+0x4c>
  return kill(pid, signum);
    80003b9c:	fec42503          	lw	a0,-20(s0)
    80003ba0:	fffff097          	auipc	ra,0xfffff
    80003ba4:	19c080e7          	jalr	412(ra) # 80002d3c <kill>
}
    80003ba8:	60e2                	ld	ra,24(sp)
    80003baa:	6442                	ld	s0,16(sp)
    80003bac:	6105                	addi	sp,sp,32
    80003bae:	8082                	ret
    return -1;
    80003bb0:	557d                	li	a0,-1
    80003bb2:	bfdd                	j	80003ba8 <sys_kill+0x4c>

0000000080003bb4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80003bb4:	1101                	addi	sp,sp,-32
    80003bb6:	ec06                	sd	ra,24(sp)
    80003bb8:	e822                	sd	s0,16(sp)
    80003bba:	e426                	sd	s1,8(sp)
    80003bbc:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003bbe:	0002f517          	auipc	a0,0x2f
    80003bc2:	d6a50513          	addi	a0,a0,-662 # 80032928 <tickslock>
    80003bc6:	ffffd097          	auipc	ra,0xffffd
    80003bca:	000080e7          	jalr	ra # 80000bc6 <acquire>
  xticks = ticks;
    80003bce:	00005497          	auipc	s1,0x5
    80003bd2:	4624a483          	lw	s1,1122(s1) # 80009030 <ticks>
  release(&tickslock);
    80003bd6:	0002f517          	auipc	a0,0x2f
    80003bda:	d5250513          	addi	a0,a0,-686 # 80032928 <tickslock>
    80003bde:	ffffd097          	auipc	ra,0xffffd
    80003be2:	0b2080e7          	jalr	178(ra) # 80000c90 <release>
  return xticks;
}
    80003be6:	02049513          	slli	a0,s1,0x20
    80003bea:	9101                	srli	a0,a0,0x20
    80003bec:	60e2                	ld	ra,24(sp)
    80003bee:	6442                	ld	s0,16(sp)
    80003bf0:	64a2                	ld	s1,8(sp)
    80003bf2:	6105                	addi	sp,sp,32
    80003bf4:	8082                	ret

0000000080003bf6 <sys_sigprocmask>:

uint64
sys_sigprocmask(void)
{
    80003bf6:	1101                	addi	sp,sp,-32
    80003bf8:	ec06                	sd	ra,24(sp)
    80003bfa:	e822                	sd	s0,16(sp)
    80003bfc:	1000                	addi	s0,sp,32
  int sigmask;

  if(argint(0, &sigmask) < 0)
    80003bfe:	fec40593          	addi	a1,s0,-20
    80003c02:	4501                	li	a0,0
    80003c04:	00000097          	auipc	ra,0x0
    80003c08:	cd4080e7          	jalr	-812(ra) # 800038d8 <argint>
    80003c0c:	87aa                	mv	a5,a0
    return -1;
    80003c0e:	557d                	li	a0,-1
  if(argint(0, &sigmask) < 0)
    80003c10:	0007ca63          	bltz	a5,80003c24 <sys_sigprocmask+0x2e>
  return sigprocmask((uint)sigmask);
    80003c14:	fec42503          	lw	a0,-20(s0)
    80003c18:	fffff097          	auipc	ra,0xfffff
    80003c1c:	f4e080e7          	jalr	-178(ra) # 80002b66 <sigprocmask>
    80003c20:	1502                	slli	a0,a0,0x20
    80003c22:	9101                	srli	a0,a0,0x20
}
    80003c24:	60e2                	ld	ra,24(sp)
    80003c26:	6442                	ld	s0,16(sp)
    80003c28:	6105                	addi	sp,sp,32
    80003c2a:	8082                	ret

0000000080003c2c <sys_sigaction>:

uint64
sys_sigaction(void)
{
    80003c2c:	7179                	addi	sp,sp,-48
    80003c2e:	f406                	sd	ra,40(sp)
    80003c30:	f022                	sd	s0,32(sp)
    80003c32:	1800                	addi	s0,sp,48
  int signum;
  uint64 newact;
  uint64 oldact;
  
  if(argint(0, &signum) < 0)
    80003c34:	fec40593          	addi	a1,s0,-20
    80003c38:	4501                	li	a0,0
    80003c3a:	00000097          	auipc	ra,0x0
    80003c3e:	c9e080e7          	jalr	-866(ra) # 800038d8 <argint>
    return -1;
    80003c42:	57fd                	li	a5,-1
  if(argint(0, &signum) < 0)
    80003c44:	04054163          	bltz	a0,80003c86 <sys_sigaction+0x5a>
  if(argaddr(1, &newact) < 0)
    80003c48:	fe040593          	addi	a1,s0,-32
    80003c4c:	4505                	li	a0,1
    80003c4e:	00000097          	auipc	ra,0x0
    80003c52:	cac080e7          	jalr	-852(ra) # 800038fa <argaddr>
    return -1;
    80003c56:	57fd                	li	a5,-1
  if(argaddr(1, &newact) < 0)
    80003c58:	02054763          	bltz	a0,80003c86 <sys_sigaction+0x5a>
  if(argaddr(2, &oldact) < 0)
    80003c5c:	fd840593          	addi	a1,s0,-40
    80003c60:	4509                	li	a0,2
    80003c62:	00000097          	auipc	ra,0x0
    80003c66:	c98080e7          	jalr	-872(ra) # 800038fa <argaddr>
    return -1;
    80003c6a:	57fd                	li	a5,-1
  if(argaddr(2, &oldact) < 0)
    80003c6c:	00054d63          	bltz	a0,80003c86 <sys_sigaction+0x5a>

  return sigaction(signum,newact,oldact);
    80003c70:	fd843603          	ld	a2,-40(s0)
    80003c74:	fe043583          	ld	a1,-32(s0)
    80003c78:	fec42503          	lw	a0,-20(s0)
    80003c7c:	fffff097          	auipc	ra,0xfffff
    80003c80:	f3e080e7          	jalr	-194(ra) # 80002bba <sigaction>
    80003c84:	87aa                	mv	a5,a0
  
}
    80003c86:	853e                	mv	a0,a5
    80003c88:	70a2                	ld	ra,40(sp)
    80003c8a:	7402                	ld	s0,32(sp)
    80003c8c:	6145                	addi	sp,sp,48
    80003c8e:	8082                	ret

0000000080003c90 <sys_sigret>:
uint64
sys_sigret(void)
{
    80003c90:	1141                	addi	sp,sp,-16
    80003c92:	e406                	sd	ra,8(sp)
    80003c94:	e022                	sd	s0,0(sp)
    80003c96:	0800                	addi	s0,sp,16
  sigret();
    80003c98:	fffff097          	auipc	ra,0xfffff
    80003c9c:	00c080e7          	jalr	12(ra) # 80002ca4 <sigret>
  return 0;
}
    80003ca0:	4501                	li	a0,0
    80003ca2:	60a2                	ld	ra,8(sp)
    80003ca4:	6402                	ld	s0,0(sp)
    80003ca6:	0141                	addi	sp,sp,16
    80003ca8:	8082                	ret

0000000080003caa <sys_kthread_create>:

uint64
sys_kthread_create(void)
{
    80003caa:	1101                	addi	sp,sp,-32
    80003cac:	ec06                	sd	ra,24(sp)
    80003cae:	e822                	sd	s0,16(sp)
    80003cb0:	1000                	addi	s0,sp,32
  uint64 start_func;
  uint64 stack;
  if(argaddr(0, &start_func) < 0)
    80003cb2:	fe840593          	addi	a1,s0,-24
    80003cb6:	4501                	li	a0,0
    80003cb8:	00000097          	auipc	ra,0x0
    80003cbc:	c42080e7          	jalr	-958(ra) # 800038fa <argaddr>
    80003cc0:	02054463          	bltz	a0,80003ce8 <sys_kthread_create+0x3e>
    return -1;
  if(argaddr(1, &stack) < 0)
    80003cc4:	fe040593          	addi	a1,s0,-32
    80003cc8:	4505                	li	a0,1
    80003cca:	00000097          	auipc	ra,0x0
    80003cce:	c30080e7          	jalr	-976(ra) # 800038fa <argaddr>
    80003cd2:	00054b63          	bltz	a0,80003ce8 <sys_kthread_create+0x3e>
    return -1;
  kthread_create(start_func,stack);
    80003cd6:	fe043583          	ld	a1,-32(s0)
    80003cda:	fe843503          	ld	a0,-24(s0)
    80003cde:	fffff097          	auipc	ra,0xfffff
    80003ce2:	186080e7          	jalr	390(ra) # 80002e64 <kthread_create>
}
    80003ce6:	a011                	j	80003cea <sys_kthread_create+0x40>
    80003ce8:	557d                	li	a0,-1
    80003cea:	60e2                	ld	ra,24(sp)
    80003cec:	6442                	ld	s0,16(sp)
    80003cee:	6105                	addi	sp,sp,32
    80003cf0:	8082                	ret

0000000080003cf2 <sys_kthread_id>:

uint64
sys_kthread_id(void){
    80003cf2:	1141                	addi	sp,sp,-16
    80003cf4:	e406                	sd	ra,8(sp)
    80003cf6:	e022                	sd	s0,0(sp)
    80003cf8:	0800                	addi	s0,sp,16
  return mykthread()->tid;
    80003cfa:	ffffe097          	auipc	ra,0xffffe
    80003cfe:	de6080e7          	jalr	-538(ra) # 80001ae0 <mykthread>
}
    80003d02:	5908                	lw	a0,48(a0)
    80003d04:	60a2                	ld	ra,8(sp)
    80003d06:	6402                	ld	s0,0(sp)
    80003d08:	0141                	addi	sp,sp,16
    80003d0a:	8082                	ret

0000000080003d0c <sys_kthread_exit>:

uint64
sys_kthread_exit(void){
    80003d0c:	1101                	addi	sp,sp,-32
    80003d0e:	ec06                	sd	ra,24(sp)
    80003d10:	e822                	sd	s0,16(sp)
    80003d12:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80003d14:	fec40593          	addi	a1,s0,-20
    80003d18:	4501                	li	a0,0
    80003d1a:	00000097          	auipc	ra,0x0
    80003d1e:	bbe080e7          	jalr	-1090(ra) # 800038d8 <argint>
    return -1;
    80003d22:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003d24:	00054963          	bltz	a0,80003d36 <sys_kthread_exit+0x2a>
  exit(n);
    80003d28:	fec42503          	lw	a0,-20(s0)
    80003d2c:	fffff097          	auipc	ra,0xfffff
    80003d30:	bd4080e7          	jalr	-1068(ra) # 80002900 <exit>
  
  return 0;  // not reached
    80003d34:	4781                	li	a5,0
}
    80003d36:	853e                	mv	a0,a5
    80003d38:	60e2                	ld	ra,24(sp)
    80003d3a:	6442                	ld	s0,16(sp)
    80003d3c:	6105                	addi	sp,sp,32
    80003d3e:	8082                	ret

0000000080003d40 <sys_kthread_join>:

uint64 
sys_kthread_join(){
    80003d40:	1101                	addi	sp,sp,-32
    80003d42:	ec06                	sd	ra,24(sp)
    80003d44:	e822                	sd	s0,16(sp)
    80003d46:	1000                	addi	s0,sp,32
  int thread_id;
  uint64 status;
  if(argint(0, &thread_id) < 0)
    80003d48:	fec40593          	addi	a1,s0,-20
    80003d4c:	4501                	li	a0,0
    80003d4e:	00000097          	auipc	ra,0x0
    80003d52:	b8a080e7          	jalr	-1142(ra) # 800038d8 <argint>
    return -1;
    80003d56:	57fd                	li	a5,-1
  if(argint(0, &thread_id) < 0)
    80003d58:	02054563          	bltz	a0,80003d82 <sys_kthread_join+0x42>
  if(argaddr(1, &status) < 0)
    80003d5c:	fe040593          	addi	a1,s0,-32
    80003d60:	4505                	li	a0,1
    80003d62:	00000097          	auipc	ra,0x0
    80003d66:	b98080e7          	jalr	-1128(ra) # 800038fa <argaddr>
    return -1;
    80003d6a:	57fd                	li	a5,-1
  if(argaddr(1, &status) < 0)
    80003d6c:	00054b63          	bltz	a0,80003d82 <sys_kthread_join+0x42>
  
  return kthread_join(thread_id, status);
    80003d70:	fe043583          	ld	a1,-32(s0)
    80003d74:	fec42503          	lw	a0,-20(s0)
    80003d78:	fffff097          	auipc	ra,0xfffff
    80003d7c:	1b8080e7          	jalr	440(ra) # 80002f30 <kthread_join>
    80003d80:	87aa                	mv	a5,a0
    80003d82:	853e                	mv	a0,a5
    80003d84:	60e2                	ld	ra,24(sp)
    80003d86:	6442                	ld	s0,16(sp)
    80003d88:	6105                	addi	sp,sp,32
    80003d8a:	8082                	ret

0000000080003d8c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003d8c:	7179                	addi	sp,sp,-48
    80003d8e:	f406                	sd	ra,40(sp)
    80003d90:	f022                	sd	s0,32(sp)
    80003d92:	ec26                	sd	s1,24(sp)
    80003d94:	e84a                	sd	s2,16(sp)
    80003d96:	e44e                	sd	s3,8(sp)
    80003d98:	e052                	sd	s4,0(sp)
    80003d9a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003d9c:	00005597          	auipc	a1,0x5
    80003da0:	93c58593          	addi	a1,a1,-1732 # 800086d8 <syscalls+0xe8>
    80003da4:	0002f517          	auipc	a0,0x2f
    80003da8:	b9c50513          	addi	a0,a0,-1124 # 80032940 <bcache>
    80003dac:	ffffd097          	auipc	ra,0xffffd
    80003db0:	d8a080e7          	jalr	-630(ra) # 80000b36 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003db4:	00037797          	auipc	a5,0x37
    80003db8:	b8c78793          	addi	a5,a5,-1140 # 8003a940 <bcache+0x8000>
    80003dbc:	00037717          	auipc	a4,0x37
    80003dc0:	dec70713          	addi	a4,a4,-532 # 8003aba8 <bcache+0x8268>
    80003dc4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003dc8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003dcc:	0002f497          	auipc	s1,0x2f
    80003dd0:	b8c48493          	addi	s1,s1,-1140 # 80032958 <bcache+0x18>
    b->next = bcache.head.next;
    80003dd4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003dd6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003dd8:	00005a17          	auipc	s4,0x5
    80003ddc:	908a0a13          	addi	s4,s4,-1784 # 800086e0 <syscalls+0xf0>
    b->next = bcache.head.next;
    80003de0:	2b893783          	ld	a5,696(s2)
    80003de4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003de6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003dea:	85d2                	mv	a1,s4
    80003dec:	01048513          	addi	a0,s1,16
    80003df0:	00001097          	auipc	ra,0x1
    80003df4:	4c0080e7          	jalr	1216(ra) # 800052b0 <initsleeplock>
    bcache.head.next->prev = b;
    80003df8:	2b893783          	ld	a5,696(s2)
    80003dfc:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003dfe:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003e02:	45848493          	addi	s1,s1,1112
    80003e06:	fd349de3          	bne	s1,s3,80003de0 <binit+0x54>
  }
}
    80003e0a:	70a2                	ld	ra,40(sp)
    80003e0c:	7402                	ld	s0,32(sp)
    80003e0e:	64e2                	ld	s1,24(sp)
    80003e10:	6942                	ld	s2,16(sp)
    80003e12:	69a2                	ld	s3,8(sp)
    80003e14:	6a02                	ld	s4,0(sp)
    80003e16:	6145                	addi	sp,sp,48
    80003e18:	8082                	ret

0000000080003e1a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003e1a:	7179                	addi	sp,sp,-48
    80003e1c:	f406                	sd	ra,40(sp)
    80003e1e:	f022                	sd	s0,32(sp)
    80003e20:	ec26                	sd	s1,24(sp)
    80003e22:	e84a                	sd	s2,16(sp)
    80003e24:	e44e                	sd	s3,8(sp)
    80003e26:	1800                	addi	s0,sp,48
    80003e28:	892a                	mv	s2,a0
    80003e2a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003e2c:	0002f517          	auipc	a0,0x2f
    80003e30:	b1450513          	addi	a0,a0,-1260 # 80032940 <bcache>
    80003e34:	ffffd097          	auipc	ra,0xffffd
    80003e38:	d92080e7          	jalr	-622(ra) # 80000bc6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003e3c:	00037497          	auipc	s1,0x37
    80003e40:	dbc4b483          	ld	s1,-580(s1) # 8003abf8 <bcache+0x82b8>
    80003e44:	00037797          	auipc	a5,0x37
    80003e48:	d6478793          	addi	a5,a5,-668 # 8003aba8 <bcache+0x8268>
    80003e4c:	02f48f63          	beq	s1,a5,80003e8a <bread+0x70>
    80003e50:	873e                	mv	a4,a5
    80003e52:	a021                	j	80003e5a <bread+0x40>
    80003e54:	68a4                	ld	s1,80(s1)
    80003e56:	02e48a63          	beq	s1,a4,80003e8a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003e5a:	449c                	lw	a5,8(s1)
    80003e5c:	ff279ce3          	bne	a5,s2,80003e54 <bread+0x3a>
    80003e60:	44dc                	lw	a5,12(s1)
    80003e62:	ff3799e3          	bne	a5,s3,80003e54 <bread+0x3a>
      b->refcnt++;
    80003e66:	40bc                	lw	a5,64(s1)
    80003e68:	2785                	addiw	a5,a5,1
    80003e6a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003e6c:	0002f517          	auipc	a0,0x2f
    80003e70:	ad450513          	addi	a0,a0,-1324 # 80032940 <bcache>
    80003e74:	ffffd097          	auipc	ra,0xffffd
    80003e78:	e1c080e7          	jalr	-484(ra) # 80000c90 <release>
      acquiresleep(&b->lock);
    80003e7c:	01048513          	addi	a0,s1,16
    80003e80:	00001097          	auipc	ra,0x1
    80003e84:	46a080e7          	jalr	1130(ra) # 800052ea <acquiresleep>
      return b;
    80003e88:	a8b9                	j	80003ee6 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003e8a:	00037497          	auipc	s1,0x37
    80003e8e:	d664b483          	ld	s1,-666(s1) # 8003abf0 <bcache+0x82b0>
    80003e92:	00037797          	auipc	a5,0x37
    80003e96:	d1678793          	addi	a5,a5,-746 # 8003aba8 <bcache+0x8268>
    80003e9a:	00f48863          	beq	s1,a5,80003eaa <bread+0x90>
    80003e9e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003ea0:	40bc                	lw	a5,64(s1)
    80003ea2:	cf81                	beqz	a5,80003eba <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003ea4:	64a4                	ld	s1,72(s1)
    80003ea6:	fee49de3          	bne	s1,a4,80003ea0 <bread+0x86>
  panic("bget: no buffers");
    80003eaa:	00005517          	auipc	a0,0x5
    80003eae:	83e50513          	addi	a0,a0,-1986 # 800086e8 <syscalls+0xf8>
    80003eb2:	ffffc097          	auipc	ra,0xffffc
    80003eb6:	67c080e7          	jalr	1660(ra) # 8000052e <panic>
      b->dev = dev;
    80003eba:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003ebe:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003ec2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003ec6:	4785                	li	a5,1
    80003ec8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003eca:	0002f517          	auipc	a0,0x2f
    80003ece:	a7650513          	addi	a0,a0,-1418 # 80032940 <bcache>
    80003ed2:	ffffd097          	auipc	ra,0xffffd
    80003ed6:	dbe080e7          	jalr	-578(ra) # 80000c90 <release>
      acquiresleep(&b->lock);
    80003eda:	01048513          	addi	a0,s1,16
    80003ede:	00001097          	auipc	ra,0x1
    80003ee2:	40c080e7          	jalr	1036(ra) # 800052ea <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003ee6:	409c                	lw	a5,0(s1)
    80003ee8:	cb89                	beqz	a5,80003efa <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003eea:	8526                	mv	a0,s1
    80003eec:	70a2                	ld	ra,40(sp)
    80003eee:	7402                	ld	s0,32(sp)
    80003ef0:	64e2                	ld	s1,24(sp)
    80003ef2:	6942                	ld	s2,16(sp)
    80003ef4:	69a2                	ld	s3,8(sp)
    80003ef6:	6145                	addi	sp,sp,48
    80003ef8:	8082                	ret
    virtio_disk_rw(b, 0);
    80003efa:	4581                	li	a1,0
    80003efc:	8526                	mv	a0,s1
    80003efe:	00003097          	auipc	ra,0x3
    80003f02:	be8080e7          	jalr	-1048(ra) # 80006ae6 <virtio_disk_rw>
    b->valid = 1;
    80003f06:	4785                	li	a5,1
    80003f08:	c09c                	sw	a5,0(s1)
  return b;
    80003f0a:	b7c5                	j	80003eea <bread+0xd0>

0000000080003f0c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003f0c:	1101                	addi	sp,sp,-32
    80003f0e:	ec06                	sd	ra,24(sp)
    80003f10:	e822                	sd	s0,16(sp)
    80003f12:	e426                	sd	s1,8(sp)
    80003f14:	1000                	addi	s0,sp,32
    80003f16:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003f18:	0541                	addi	a0,a0,16
    80003f1a:	00001097          	auipc	ra,0x1
    80003f1e:	46a080e7          	jalr	1130(ra) # 80005384 <holdingsleep>
    80003f22:	cd01                	beqz	a0,80003f3a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003f24:	4585                	li	a1,1
    80003f26:	8526                	mv	a0,s1
    80003f28:	00003097          	auipc	ra,0x3
    80003f2c:	bbe080e7          	jalr	-1090(ra) # 80006ae6 <virtio_disk_rw>
}
    80003f30:	60e2                	ld	ra,24(sp)
    80003f32:	6442                	ld	s0,16(sp)
    80003f34:	64a2                	ld	s1,8(sp)
    80003f36:	6105                	addi	sp,sp,32
    80003f38:	8082                	ret
    panic("bwrite");
    80003f3a:	00004517          	auipc	a0,0x4
    80003f3e:	7c650513          	addi	a0,a0,1990 # 80008700 <syscalls+0x110>
    80003f42:	ffffc097          	auipc	ra,0xffffc
    80003f46:	5ec080e7          	jalr	1516(ra) # 8000052e <panic>

0000000080003f4a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003f4a:	1101                	addi	sp,sp,-32
    80003f4c:	ec06                	sd	ra,24(sp)
    80003f4e:	e822                	sd	s0,16(sp)
    80003f50:	e426                	sd	s1,8(sp)
    80003f52:	e04a                	sd	s2,0(sp)
    80003f54:	1000                	addi	s0,sp,32
    80003f56:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003f58:	01050913          	addi	s2,a0,16
    80003f5c:	854a                	mv	a0,s2
    80003f5e:	00001097          	auipc	ra,0x1
    80003f62:	426080e7          	jalr	1062(ra) # 80005384 <holdingsleep>
    80003f66:	c92d                	beqz	a0,80003fd8 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003f68:	854a                	mv	a0,s2
    80003f6a:	00001097          	auipc	ra,0x1
    80003f6e:	3d6080e7          	jalr	982(ra) # 80005340 <releasesleep>

  acquire(&bcache.lock);
    80003f72:	0002f517          	auipc	a0,0x2f
    80003f76:	9ce50513          	addi	a0,a0,-1586 # 80032940 <bcache>
    80003f7a:	ffffd097          	auipc	ra,0xffffd
    80003f7e:	c4c080e7          	jalr	-948(ra) # 80000bc6 <acquire>
  b->refcnt--;
    80003f82:	40bc                	lw	a5,64(s1)
    80003f84:	37fd                	addiw	a5,a5,-1
    80003f86:	0007871b          	sext.w	a4,a5
    80003f8a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003f8c:	eb05                	bnez	a4,80003fbc <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003f8e:	68bc                	ld	a5,80(s1)
    80003f90:	64b8                	ld	a4,72(s1)
    80003f92:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003f94:	64bc                	ld	a5,72(s1)
    80003f96:	68b8                	ld	a4,80(s1)
    80003f98:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003f9a:	00037797          	auipc	a5,0x37
    80003f9e:	9a678793          	addi	a5,a5,-1626 # 8003a940 <bcache+0x8000>
    80003fa2:	2b87b703          	ld	a4,696(a5)
    80003fa6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003fa8:	00037717          	auipc	a4,0x37
    80003fac:	c0070713          	addi	a4,a4,-1024 # 8003aba8 <bcache+0x8268>
    80003fb0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003fb2:	2b87b703          	ld	a4,696(a5)
    80003fb6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003fb8:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003fbc:	0002f517          	auipc	a0,0x2f
    80003fc0:	98450513          	addi	a0,a0,-1660 # 80032940 <bcache>
    80003fc4:	ffffd097          	auipc	ra,0xffffd
    80003fc8:	ccc080e7          	jalr	-820(ra) # 80000c90 <release>
}
    80003fcc:	60e2                	ld	ra,24(sp)
    80003fce:	6442                	ld	s0,16(sp)
    80003fd0:	64a2                	ld	s1,8(sp)
    80003fd2:	6902                	ld	s2,0(sp)
    80003fd4:	6105                	addi	sp,sp,32
    80003fd6:	8082                	ret
    panic("brelse");
    80003fd8:	00004517          	auipc	a0,0x4
    80003fdc:	73050513          	addi	a0,a0,1840 # 80008708 <syscalls+0x118>
    80003fe0:	ffffc097          	auipc	ra,0xffffc
    80003fe4:	54e080e7          	jalr	1358(ra) # 8000052e <panic>

0000000080003fe8 <bpin>:

void
bpin(struct buf *b) {
    80003fe8:	1101                	addi	sp,sp,-32
    80003fea:	ec06                	sd	ra,24(sp)
    80003fec:	e822                	sd	s0,16(sp)
    80003fee:	e426                	sd	s1,8(sp)
    80003ff0:	1000                	addi	s0,sp,32
    80003ff2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003ff4:	0002f517          	auipc	a0,0x2f
    80003ff8:	94c50513          	addi	a0,a0,-1716 # 80032940 <bcache>
    80003ffc:	ffffd097          	auipc	ra,0xffffd
    80004000:	bca080e7          	jalr	-1078(ra) # 80000bc6 <acquire>
  b->refcnt++;
    80004004:	40bc                	lw	a5,64(s1)
    80004006:	2785                	addiw	a5,a5,1
    80004008:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000400a:	0002f517          	auipc	a0,0x2f
    8000400e:	93650513          	addi	a0,a0,-1738 # 80032940 <bcache>
    80004012:	ffffd097          	auipc	ra,0xffffd
    80004016:	c7e080e7          	jalr	-898(ra) # 80000c90 <release>
}
    8000401a:	60e2                	ld	ra,24(sp)
    8000401c:	6442                	ld	s0,16(sp)
    8000401e:	64a2                	ld	s1,8(sp)
    80004020:	6105                	addi	sp,sp,32
    80004022:	8082                	ret

0000000080004024 <bunpin>:

void
bunpin(struct buf *b) {
    80004024:	1101                	addi	sp,sp,-32
    80004026:	ec06                	sd	ra,24(sp)
    80004028:	e822                	sd	s0,16(sp)
    8000402a:	e426                	sd	s1,8(sp)
    8000402c:	1000                	addi	s0,sp,32
    8000402e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80004030:	0002f517          	auipc	a0,0x2f
    80004034:	91050513          	addi	a0,a0,-1776 # 80032940 <bcache>
    80004038:	ffffd097          	auipc	ra,0xffffd
    8000403c:	b8e080e7          	jalr	-1138(ra) # 80000bc6 <acquire>
  b->refcnt--;
    80004040:	40bc                	lw	a5,64(s1)
    80004042:	37fd                	addiw	a5,a5,-1
    80004044:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80004046:	0002f517          	auipc	a0,0x2f
    8000404a:	8fa50513          	addi	a0,a0,-1798 # 80032940 <bcache>
    8000404e:	ffffd097          	auipc	ra,0xffffd
    80004052:	c42080e7          	jalr	-958(ra) # 80000c90 <release>
}
    80004056:	60e2                	ld	ra,24(sp)
    80004058:	6442                	ld	s0,16(sp)
    8000405a:	64a2                	ld	s1,8(sp)
    8000405c:	6105                	addi	sp,sp,32
    8000405e:	8082                	ret

0000000080004060 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80004060:	1101                	addi	sp,sp,-32
    80004062:	ec06                	sd	ra,24(sp)
    80004064:	e822                	sd	s0,16(sp)
    80004066:	e426                	sd	s1,8(sp)
    80004068:	e04a                	sd	s2,0(sp)
    8000406a:	1000                	addi	s0,sp,32
    8000406c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000406e:	00d5d59b          	srliw	a1,a1,0xd
    80004072:	00037797          	auipc	a5,0x37
    80004076:	faa7a783          	lw	a5,-86(a5) # 8003b01c <sb+0x1c>
    8000407a:	9dbd                	addw	a1,a1,a5
    8000407c:	00000097          	auipc	ra,0x0
    80004080:	d9e080e7          	jalr	-610(ra) # 80003e1a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80004084:	0074f713          	andi	a4,s1,7
    80004088:	4785                	li	a5,1
    8000408a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000408e:	14ce                	slli	s1,s1,0x33
    80004090:	90d9                	srli	s1,s1,0x36
    80004092:	00950733          	add	a4,a0,s1
    80004096:	05874703          	lbu	a4,88(a4)
    8000409a:	00e7f6b3          	and	a3,a5,a4
    8000409e:	c69d                	beqz	a3,800040cc <bfree+0x6c>
    800040a0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800040a2:	94aa                	add	s1,s1,a0
    800040a4:	fff7c793          	not	a5,a5
    800040a8:	8ff9                	and	a5,a5,a4
    800040aa:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800040ae:	00001097          	auipc	ra,0x1
    800040b2:	11c080e7          	jalr	284(ra) # 800051ca <log_write>
  brelse(bp);
    800040b6:	854a                	mv	a0,s2
    800040b8:	00000097          	auipc	ra,0x0
    800040bc:	e92080e7          	jalr	-366(ra) # 80003f4a <brelse>
}
    800040c0:	60e2                	ld	ra,24(sp)
    800040c2:	6442                	ld	s0,16(sp)
    800040c4:	64a2                	ld	s1,8(sp)
    800040c6:	6902                	ld	s2,0(sp)
    800040c8:	6105                	addi	sp,sp,32
    800040ca:	8082                	ret
    panic("freeing free block");
    800040cc:	00004517          	auipc	a0,0x4
    800040d0:	64450513          	addi	a0,a0,1604 # 80008710 <syscalls+0x120>
    800040d4:	ffffc097          	auipc	ra,0xffffc
    800040d8:	45a080e7          	jalr	1114(ra) # 8000052e <panic>

00000000800040dc <balloc>:
{
    800040dc:	711d                	addi	sp,sp,-96
    800040de:	ec86                	sd	ra,88(sp)
    800040e0:	e8a2                	sd	s0,80(sp)
    800040e2:	e4a6                	sd	s1,72(sp)
    800040e4:	e0ca                	sd	s2,64(sp)
    800040e6:	fc4e                	sd	s3,56(sp)
    800040e8:	f852                	sd	s4,48(sp)
    800040ea:	f456                	sd	s5,40(sp)
    800040ec:	f05a                	sd	s6,32(sp)
    800040ee:	ec5e                	sd	s7,24(sp)
    800040f0:	e862                	sd	s8,16(sp)
    800040f2:	e466                	sd	s9,8(sp)
    800040f4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800040f6:	00037797          	auipc	a5,0x37
    800040fa:	f0e7a783          	lw	a5,-242(a5) # 8003b004 <sb+0x4>
    800040fe:	cbd1                	beqz	a5,80004192 <balloc+0xb6>
    80004100:	8baa                	mv	s7,a0
    80004102:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80004104:	00037b17          	auipc	s6,0x37
    80004108:	efcb0b13          	addi	s6,s6,-260 # 8003b000 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000410c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000410e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004110:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80004112:	6c89                	lui	s9,0x2
    80004114:	a831                	j	80004130 <balloc+0x54>
    brelse(bp);
    80004116:	854a                	mv	a0,s2
    80004118:	00000097          	auipc	ra,0x0
    8000411c:	e32080e7          	jalr	-462(ra) # 80003f4a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80004120:	015c87bb          	addw	a5,s9,s5
    80004124:	00078a9b          	sext.w	s5,a5
    80004128:	004b2703          	lw	a4,4(s6)
    8000412c:	06eaf363          	bgeu	s5,a4,80004192 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    80004130:	41fad79b          	sraiw	a5,s5,0x1f
    80004134:	0137d79b          	srliw	a5,a5,0x13
    80004138:	015787bb          	addw	a5,a5,s5
    8000413c:	40d7d79b          	sraiw	a5,a5,0xd
    80004140:	01cb2583          	lw	a1,28(s6)
    80004144:	9dbd                	addw	a1,a1,a5
    80004146:	855e                	mv	a0,s7
    80004148:	00000097          	auipc	ra,0x0
    8000414c:	cd2080e7          	jalr	-814(ra) # 80003e1a <bread>
    80004150:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004152:	004b2503          	lw	a0,4(s6)
    80004156:	000a849b          	sext.w	s1,s5
    8000415a:	8662                	mv	a2,s8
    8000415c:	faa4fde3          	bgeu	s1,a0,80004116 <balloc+0x3a>
      m = 1 << (bi % 8);
    80004160:	41f6579b          	sraiw	a5,a2,0x1f
    80004164:	01d7d69b          	srliw	a3,a5,0x1d
    80004168:	00c6873b          	addw	a4,a3,a2
    8000416c:	00777793          	andi	a5,a4,7
    80004170:	9f95                	subw	a5,a5,a3
    80004172:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80004176:	4037571b          	sraiw	a4,a4,0x3
    8000417a:	00e906b3          	add	a3,s2,a4
    8000417e:	0586c683          	lbu	a3,88(a3)
    80004182:	00d7f5b3          	and	a1,a5,a3
    80004186:	cd91                	beqz	a1,800041a2 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004188:	2605                	addiw	a2,a2,1
    8000418a:	2485                	addiw	s1,s1,1
    8000418c:	fd4618e3          	bne	a2,s4,8000415c <balloc+0x80>
    80004190:	b759                	j	80004116 <balloc+0x3a>
  panic("balloc: out of blocks");
    80004192:	00004517          	auipc	a0,0x4
    80004196:	59650513          	addi	a0,a0,1430 # 80008728 <syscalls+0x138>
    8000419a:	ffffc097          	auipc	ra,0xffffc
    8000419e:	394080e7          	jalr	916(ra) # 8000052e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800041a2:	974a                	add	a4,a4,s2
    800041a4:	8fd5                	or	a5,a5,a3
    800041a6:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800041aa:	854a                	mv	a0,s2
    800041ac:	00001097          	auipc	ra,0x1
    800041b0:	01e080e7          	jalr	30(ra) # 800051ca <log_write>
        brelse(bp);
    800041b4:	854a                	mv	a0,s2
    800041b6:	00000097          	auipc	ra,0x0
    800041ba:	d94080e7          	jalr	-620(ra) # 80003f4a <brelse>
  bp = bread(dev, bno);
    800041be:	85a6                	mv	a1,s1
    800041c0:	855e                	mv	a0,s7
    800041c2:	00000097          	auipc	ra,0x0
    800041c6:	c58080e7          	jalr	-936(ra) # 80003e1a <bread>
    800041ca:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800041cc:	40000613          	li	a2,1024
    800041d0:	4581                	li	a1,0
    800041d2:	05850513          	addi	a0,a0,88
    800041d6:	ffffd097          	auipc	ra,0xffffd
    800041da:	b02080e7          	jalr	-1278(ra) # 80000cd8 <memset>
  log_write(bp);
    800041de:	854a                	mv	a0,s2
    800041e0:	00001097          	auipc	ra,0x1
    800041e4:	fea080e7          	jalr	-22(ra) # 800051ca <log_write>
  brelse(bp);
    800041e8:	854a                	mv	a0,s2
    800041ea:	00000097          	auipc	ra,0x0
    800041ee:	d60080e7          	jalr	-672(ra) # 80003f4a <brelse>
}
    800041f2:	8526                	mv	a0,s1
    800041f4:	60e6                	ld	ra,88(sp)
    800041f6:	6446                	ld	s0,80(sp)
    800041f8:	64a6                	ld	s1,72(sp)
    800041fa:	6906                	ld	s2,64(sp)
    800041fc:	79e2                	ld	s3,56(sp)
    800041fe:	7a42                	ld	s4,48(sp)
    80004200:	7aa2                	ld	s5,40(sp)
    80004202:	7b02                	ld	s6,32(sp)
    80004204:	6be2                	ld	s7,24(sp)
    80004206:	6c42                	ld	s8,16(sp)
    80004208:	6ca2                	ld	s9,8(sp)
    8000420a:	6125                	addi	sp,sp,96
    8000420c:	8082                	ret

000000008000420e <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000420e:	7179                	addi	sp,sp,-48
    80004210:	f406                	sd	ra,40(sp)
    80004212:	f022                	sd	s0,32(sp)
    80004214:	ec26                	sd	s1,24(sp)
    80004216:	e84a                	sd	s2,16(sp)
    80004218:	e44e                	sd	s3,8(sp)
    8000421a:	e052                	sd	s4,0(sp)
    8000421c:	1800                	addi	s0,sp,48
    8000421e:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80004220:	47ad                	li	a5,11
    80004222:	04b7fe63          	bgeu	a5,a1,8000427e <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80004226:	ff45849b          	addiw	s1,a1,-12
    8000422a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000422e:	0ff00793          	li	a5,255
    80004232:	0ae7e463          	bltu	a5,a4,800042da <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80004236:	08052583          	lw	a1,128(a0)
    8000423a:	c5b5                	beqz	a1,800042a6 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000423c:	00092503          	lw	a0,0(s2)
    80004240:	00000097          	auipc	ra,0x0
    80004244:	bda080e7          	jalr	-1062(ra) # 80003e1a <bread>
    80004248:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000424a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000424e:	02049713          	slli	a4,s1,0x20
    80004252:	01e75593          	srli	a1,a4,0x1e
    80004256:	00b784b3          	add	s1,a5,a1
    8000425a:	0004a983          	lw	s3,0(s1)
    8000425e:	04098e63          	beqz	s3,800042ba <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80004262:	8552                	mv	a0,s4
    80004264:	00000097          	auipc	ra,0x0
    80004268:	ce6080e7          	jalr	-794(ra) # 80003f4a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000426c:	854e                	mv	a0,s3
    8000426e:	70a2                	ld	ra,40(sp)
    80004270:	7402                	ld	s0,32(sp)
    80004272:	64e2                	ld	s1,24(sp)
    80004274:	6942                	ld	s2,16(sp)
    80004276:	69a2                	ld	s3,8(sp)
    80004278:	6a02                	ld	s4,0(sp)
    8000427a:	6145                	addi	sp,sp,48
    8000427c:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000427e:	02059793          	slli	a5,a1,0x20
    80004282:	01e7d593          	srli	a1,a5,0x1e
    80004286:	00b504b3          	add	s1,a0,a1
    8000428a:	0504a983          	lw	s3,80(s1)
    8000428e:	fc099fe3          	bnez	s3,8000426c <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80004292:	4108                	lw	a0,0(a0)
    80004294:	00000097          	auipc	ra,0x0
    80004298:	e48080e7          	jalr	-440(ra) # 800040dc <balloc>
    8000429c:	0005099b          	sext.w	s3,a0
    800042a0:	0534a823          	sw	s3,80(s1)
    800042a4:	b7e1                	j	8000426c <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800042a6:	4108                	lw	a0,0(a0)
    800042a8:	00000097          	auipc	ra,0x0
    800042ac:	e34080e7          	jalr	-460(ra) # 800040dc <balloc>
    800042b0:	0005059b          	sext.w	a1,a0
    800042b4:	08b92023          	sw	a1,128(s2)
    800042b8:	b751                	j	8000423c <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800042ba:	00092503          	lw	a0,0(s2)
    800042be:	00000097          	auipc	ra,0x0
    800042c2:	e1e080e7          	jalr	-482(ra) # 800040dc <balloc>
    800042c6:	0005099b          	sext.w	s3,a0
    800042ca:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800042ce:	8552                	mv	a0,s4
    800042d0:	00001097          	auipc	ra,0x1
    800042d4:	efa080e7          	jalr	-262(ra) # 800051ca <log_write>
    800042d8:	b769                	j	80004262 <bmap+0x54>
  panic("bmap: out of range");
    800042da:	00004517          	auipc	a0,0x4
    800042de:	46650513          	addi	a0,a0,1126 # 80008740 <syscalls+0x150>
    800042e2:	ffffc097          	auipc	ra,0xffffc
    800042e6:	24c080e7          	jalr	588(ra) # 8000052e <panic>

00000000800042ea <iget>:
{
    800042ea:	7179                	addi	sp,sp,-48
    800042ec:	f406                	sd	ra,40(sp)
    800042ee:	f022                	sd	s0,32(sp)
    800042f0:	ec26                	sd	s1,24(sp)
    800042f2:	e84a                	sd	s2,16(sp)
    800042f4:	e44e                	sd	s3,8(sp)
    800042f6:	e052                	sd	s4,0(sp)
    800042f8:	1800                	addi	s0,sp,48
    800042fa:	89aa                	mv	s3,a0
    800042fc:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800042fe:	00037517          	auipc	a0,0x37
    80004302:	d2250513          	addi	a0,a0,-734 # 8003b020 <itable>
    80004306:	ffffd097          	auipc	ra,0xffffd
    8000430a:	8c0080e7          	jalr	-1856(ra) # 80000bc6 <acquire>
  empty = 0;
    8000430e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004310:	00037497          	auipc	s1,0x37
    80004314:	d2848493          	addi	s1,s1,-728 # 8003b038 <itable+0x18>
    80004318:	00038697          	auipc	a3,0x38
    8000431c:	7b068693          	addi	a3,a3,1968 # 8003cac8 <log>
    80004320:	a039                	j	8000432e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004322:	02090b63          	beqz	s2,80004358 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80004326:	08848493          	addi	s1,s1,136
    8000432a:	02d48a63          	beq	s1,a3,8000435e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000432e:	449c                	lw	a5,8(s1)
    80004330:	fef059e3          	blez	a5,80004322 <iget+0x38>
    80004334:	4098                	lw	a4,0(s1)
    80004336:	ff3716e3          	bne	a4,s3,80004322 <iget+0x38>
    8000433a:	40d8                	lw	a4,4(s1)
    8000433c:	ff4713e3          	bne	a4,s4,80004322 <iget+0x38>
      ip->ref++;
    80004340:	2785                	addiw	a5,a5,1
    80004342:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80004344:	00037517          	auipc	a0,0x37
    80004348:	cdc50513          	addi	a0,a0,-804 # 8003b020 <itable>
    8000434c:	ffffd097          	auipc	ra,0xffffd
    80004350:	944080e7          	jalr	-1724(ra) # 80000c90 <release>
      return ip;
    80004354:	8926                	mv	s2,s1
    80004356:	a03d                	j	80004384 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80004358:	f7f9                	bnez	a5,80004326 <iget+0x3c>
    8000435a:	8926                	mv	s2,s1
    8000435c:	b7e9                	j	80004326 <iget+0x3c>
  if(empty == 0)
    8000435e:	02090c63          	beqz	s2,80004396 <iget+0xac>
  ip->dev = dev;
    80004362:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80004366:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000436a:	4785                	li	a5,1
    8000436c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80004370:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80004374:	00037517          	auipc	a0,0x37
    80004378:	cac50513          	addi	a0,a0,-852 # 8003b020 <itable>
    8000437c:	ffffd097          	auipc	ra,0xffffd
    80004380:	914080e7          	jalr	-1772(ra) # 80000c90 <release>
}
    80004384:	854a                	mv	a0,s2
    80004386:	70a2                	ld	ra,40(sp)
    80004388:	7402                	ld	s0,32(sp)
    8000438a:	64e2                	ld	s1,24(sp)
    8000438c:	6942                	ld	s2,16(sp)
    8000438e:	69a2                	ld	s3,8(sp)
    80004390:	6a02                	ld	s4,0(sp)
    80004392:	6145                	addi	sp,sp,48
    80004394:	8082                	ret
    panic("iget: no inodes");
    80004396:	00004517          	auipc	a0,0x4
    8000439a:	3c250513          	addi	a0,a0,962 # 80008758 <syscalls+0x168>
    8000439e:	ffffc097          	auipc	ra,0xffffc
    800043a2:	190080e7          	jalr	400(ra) # 8000052e <panic>

00000000800043a6 <fsinit>:
fsinit(int dev) {
    800043a6:	7179                	addi	sp,sp,-48
    800043a8:	f406                	sd	ra,40(sp)
    800043aa:	f022                	sd	s0,32(sp)
    800043ac:	ec26                	sd	s1,24(sp)
    800043ae:	e84a                	sd	s2,16(sp)
    800043b0:	e44e                	sd	s3,8(sp)
    800043b2:	1800                	addi	s0,sp,48
    800043b4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800043b6:	4585                	li	a1,1
    800043b8:	00000097          	auipc	ra,0x0
    800043bc:	a62080e7          	jalr	-1438(ra) # 80003e1a <bread>
    800043c0:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800043c2:	00037997          	auipc	s3,0x37
    800043c6:	c3e98993          	addi	s3,s3,-962 # 8003b000 <sb>
    800043ca:	02000613          	li	a2,32
    800043ce:	05850593          	addi	a1,a0,88
    800043d2:	854e                	mv	a0,s3
    800043d4:	ffffd097          	auipc	ra,0xffffd
    800043d8:	960080e7          	jalr	-1696(ra) # 80000d34 <memmove>
  brelse(bp);
    800043dc:	8526                	mv	a0,s1
    800043de:	00000097          	auipc	ra,0x0
    800043e2:	b6c080e7          	jalr	-1172(ra) # 80003f4a <brelse>
  if(sb.magic != FSMAGIC)
    800043e6:	0009a703          	lw	a4,0(s3)
    800043ea:	102037b7          	lui	a5,0x10203
    800043ee:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800043f2:	02f71263          	bne	a4,a5,80004416 <fsinit+0x70>
  initlog(dev, &sb);
    800043f6:	00037597          	auipc	a1,0x37
    800043fa:	c0a58593          	addi	a1,a1,-1014 # 8003b000 <sb>
    800043fe:	854a                	mv	a0,s2
    80004400:	00001097          	auipc	ra,0x1
    80004404:	b4c080e7          	jalr	-1204(ra) # 80004f4c <initlog>
}
    80004408:	70a2                	ld	ra,40(sp)
    8000440a:	7402                	ld	s0,32(sp)
    8000440c:	64e2                	ld	s1,24(sp)
    8000440e:	6942                	ld	s2,16(sp)
    80004410:	69a2                	ld	s3,8(sp)
    80004412:	6145                	addi	sp,sp,48
    80004414:	8082                	ret
    panic("invalid file system");
    80004416:	00004517          	auipc	a0,0x4
    8000441a:	35250513          	addi	a0,a0,850 # 80008768 <syscalls+0x178>
    8000441e:	ffffc097          	auipc	ra,0xffffc
    80004422:	110080e7          	jalr	272(ra) # 8000052e <panic>

0000000080004426 <iinit>:
{
    80004426:	7179                	addi	sp,sp,-48
    80004428:	f406                	sd	ra,40(sp)
    8000442a:	f022                	sd	s0,32(sp)
    8000442c:	ec26                	sd	s1,24(sp)
    8000442e:	e84a                	sd	s2,16(sp)
    80004430:	e44e                	sd	s3,8(sp)
    80004432:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80004434:	00004597          	auipc	a1,0x4
    80004438:	34c58593          	addi	a1,a1,844 # 80008780 <syscalls+0x190>
    8000443c:	00037517          	auipc	a0,0x37
    80004440:	be450513          	addi	a0,a0,-1052 # 8003b020 <itable>
    80004444:	ffffc097          	auipc	ra,0xffffc
    80004448:	6f2080e7          	jalr	1778(ra) # 80000b36 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000444c:	00037497          	auipc	s1,0x37
    80004450:	bfc48493          	addi	s1,s1,-1028 # 8003b048 <itable+0x28>
    80004454:	00038997          	auipc	s3,0x38
    80004458:	68498993          	addi	s3,s3,1668 # 8003cad8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000445c:	00004917          	auipc	s2,0x4
    80004460:	32c90913          	addi	s2,s2,812 # 80008788 <syscalls+0x198>
    80004464:	85ca                	mv	a1,s2
    80004466:	8526                	mv	a0,s1
    80004468:	00001097          	auipc	ra,0x1
    8000446c:	e48080e7          	jalr	-440(ra) # 800052b0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80004470:	08848493          	addi	s1,s1,136
    80004474:	ff3498e3          	bne	s1,s3,80004464 <iinit+0x3e>
}
    80004478:	70a2                	ld	ra,40(sp)
    8000447a:	7402                	ld	s0,32(sp)
    8000447c:	64e2                	ld	s1,24(sp)
    8000447e:	6942                	ld	s2,16(sp)
    80004480:	69a2                	ld	s3,8(sp)
    80004482:	6145                	addi	sp,sp,48
    80004484:	8082                	ret

0000000080004486 <ialloc>:
{
    80004486:	715d                	addi	sp,sp,-80
    80004488:	e486                	sd	ra,72(sp)
    8000448a:	e0a2                	sd	s0,64(sp)
    8000448c:	fc26                	sd	s1,56(sp)
    8000448e:	f84a                	sd	s2,48(sp)
    80004490:	f44e                	sd	s3,40(sp)
    80004492:	f052                	sd	s4,32(sp)
    80004494:	ec56                	sd	s5,24(sp)
    80004496:	e85a                	sd	s6,16(sp)
    80004498:	e45e                	sd	s7,8(sp)
    8000449a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000449c:	00037717          	auipc	a4,0x37
    800044a0:	b7072703          	lw	a4,-1168(a4) # 8003b00c <sb+0xc>
    800044a4:	4785                	li	a5,1
    800044a6:	04e7fa63          	bgeu	a5,a4,800044fa <ialloc+0x74>
    800044aa:	8aaa                	mv	s5,a0
    800044ac:	8bae                	mv	s7,a1
    800044ae:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800044b0:	00037a17          	auipc	s4,0x37
    800044b4:	b50a0a13          	addi	s4,s4,-1200 # 8003b000 <sb>
    800044b8:	00048b1b          	sext.w	s6,s1
    800044bc:	0044d793          	srli	a5,s1,0x4
    800044c0:	018a2583          	lw	a1,24(s4)
    800044c4:	9dbd                	addw	a1,a1,a5
    800044c6:	8556                	mv	a0,s5
    800044c8:	00000097          	auipc	ra,0x0
    800044cc:	952080e7          	jalr	-1710(ra) # 80003e1a <bread>
    800044d0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800044d2:	05850993          	addi	s3,a0,88
    800044d6:	00f4f793          	andi	a5,s1,15
    800044da:	079a                	slli	a5,a5,0x6
    800044dc:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800044de:	00099783          	lh	a5,0(s3)
    800044e2:	c785                	beqz	a5,8000450a <ialloc+0x84>
    brelse(bp);
    800044e4:	00000097          	auipc	ra,0x0
    800044e8:	a66080e7          	jalr	-1434(ra) # 80003f4a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800044ec:	0485                	addi	s1,s1,1
    800044ee:	00ca2703          	lw	a4,12(s4)
    800044f2:	0004879b          	sext.w	a5,s1
    800044f6:	fce7e1e3          	bltu	a5,a4,800044b8 <ialloc+0x32>
  panic("ialloc: no inodes");
    800044fa:	00004517          	auipc	a0,0x4
    800044fe:	29650513          	addi	a0,a0,662 # 80008790 <syscalls+0x1a0>
    80004502:	ffffc097          	auipc	ra,0xffffc
    80004506:	02c080e7          	jalr	44(ra) # 8000052e <panic>
      memset(dip, 0, sizeof(*dip));
    8000450a:	04000613          	li	a2,64
    8000450e:	4581                	li	a1,0
    80004510:	854e                	mv	a0,s3
    80004512:	ffffc097          	auipc	ra,0xffffc
    80004516:	7c6080e7          	jalr	1990(ra) # 80000cd8 <memset>
      dip->type = type;
    8000451a:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000451e:	854a                	mv	a0,s2
    80004520:	00001097          	auipc	ra,0x1
    80004524:	caa080e7          	jalr	-854(ra) # 800051ca <log_write>
      brelse(bp);
    80004528:	854a                	mv	a0,s2
    8000452a:	00000097          	auipc	ra,0x0
    8000452e:	a20080e7          	jalr	-1504(ra) # 80003f4a <brelse>
      return iget(dev, inum);
    80004532:	85da                	mv	a1,s6
    80004534:	8556                	mv	a0,s5
    80004536:	00000097          	auipc	ra,0x0
    8000453a:	db4080e7          	jalr	-588(ra) # 800042ea <iget>
}
    8000453e:	60a6                	ld	ra,72(sp)
    80004540:	6406                	ld	s0,64(sp)
    80004542:	74e2                	ld	s1,56(sp)
    80004544:	7942                	ld	s2,48(sp)
    80004546:	79a2                	ld	s3,40(sp)
    80004548:	7a02                	ld	s4,32(sp)
    8000454a:	6ae2                	ld	s5,24(sp)
    8000454c:	6b42                	ld	s6,16(sp)
    8000454e:	6ba2                	ld	s7,8(sp)
    80004550:	6161                	addi	sp,sp,80
    80004552:	8082                	ret

0000000080004554 <iupdate>:
{
    80004554:	1101                	addi	sp,sp,-32
    80004556:	ec06                	sd	ra,24(sp)
    80004558:	e822                	sd	s0,16(sp)
    8000455a:	e426                	sd	s1,8(sp)
    8000455c:	e04a                	sd	s2,0(sp)
    8000455e:	1000                	addi	s0,sp,32
    80004560:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80004562:	415c                	lw	a5,4(a0)
    80004564:	0047d79b          	srliw	a5,a5,0x4
    80004568:	00037597          	auipc	a1,0x37
    8000456c:	ab05a583          	lw	a1,-1360(a1) # 8003b018 <sb+0x18>
    80004570:	9dbd                	addw	a1,a1,a5
    80004572:	4108                	lw	a0,0(a0)
    80004574:	00000097          	auipc	ra,0x0
    80004578:	8a6080e7          	jalr	-1882(ra) # 80003e1a <bread>
    8000457c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000457e:	05850793          	addi	a5,a0,88
    80004582:	40c8                	lw	a0,4(s1)
    80004584:	893d                	andi	a0,a0,15
    80004586:	051a                	slli	a0,a0,0x6
    80004588:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    8000458a:	04449703          	lh	a4,68(s1)
    8000458e:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80004592:	04649703          	lh	a4,70(s1)
    80004596:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    8000459a:	04849703          	lh	a4,72(s1)
    8000459e:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800045a2:	04a49703          	lh	a4,74(s1)
    800045a6:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800045aa:	44f8                	lw	a4,76(s1)
    800045ac:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800045ae:	03400613          	li	a2,52
    800045b2:	05048593          	addi	a1,s1,80
    800045b6:	0531                	addi	a0,a0,12
    800045b8:	ffffc097          	auipc	ra,0xffffc
    800045bc:	77c080e7          	jalr	1916(ra) # 80000d34 <memmove>
  log_write(bp);
    800045c0:	854a                	mv	a0,s2
    800045c2:	00001097          	auipc	ra,0x1
    800045c6:	c08080e7          	jalr	-1016(ra) # 800051ca <log_write>
  brelse(bp);
    800045ca:	854a                	mv	a0,s2
    800045cc:	00000097          	auipc	ra,0x0
    800045d0:	97e080e7          	jalr	-1666(ra) # 80003f4a <brelse>
}
    800045d4:	60e2                	ld	ra,24(sp)
    800045d6:	6442                	ld	s0,16(sp)
    800045d8:	64a2                	ld	s1,8(sp)
    800045da:	6902                	ld	s2,0(sp)
    800045dc:	6105                	addi	sp,sp,32
    800045de:	8082                	ret

00000000800045e0 <idup>:
{
    800045e0:	1101                	addi	sp,sp,-32
    800045e2:	ec06                	sd	ra,24(sp)
    800045e4:	e822                	sd	s0,16(sp)
    800045e6:	e426                	sd	s1,8(sp)
    800045e8:	1000                	addi	s0,sp,32
    800045ea:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800045ec:	00037517          	auipc	a0,0x37
    800045f0:	a3450513          	addi	a0,a0,-1484 # 8003b020 <itable>
    800045f4:	ffffc097          	auipc	ra,0xffffc
    800045f8:	5d2080e7          	jalr	1490(ra) # 80000bc6 <acquire>
  ip->ref++;
    800045fc:	449c                	lw	a5,8(s1)
    800045fe:	2785                	addiw	a5,a5,1
    80004600:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004602:	00037517          	auipc	a0,0x37
    80004606:	a1e50513          	addi	a0,a0,-1506 # 8003b020 <itable>
    8000460a:	ffffc097          	auipc	ra,0xffffc
    8000460e:	686080e7          	jalr	1670(ra) # 80000c90 <release>
}
    80004612:	8526                	mv	a0,s1
    80004614:	60e2                	ld	ra,24(sp)
    80004616:	6442                	ld	s0,16(sp)
    80004618:	64a2                	ld	s1,8(sp)
    8000461a:	6105                	addi	sp,sp,32
    8000461c:	8082                	ret

000000008000461e <ilock>:
{
    8000461e:	1101                	addi	sp,sp,-32
    80004620:	ec06                	sd	ra,24(sp)
    80004622:	e822                	sd	s0,16(sp)
    80004624:	e426                	sd	s1,8(sp)
    80004626:	e04a                	sd	s2,0(sp)
    80004628:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000462a:	c115                	beqz	a0,8000464e <ilock+0x30>
    8000462c:	84aa                	mv	s1,a0
    8000462e:	451c                	lw	a5,8(a0)
    80004630:	00f05f63          	blez	a5,8000464e <ilock+0x30>
  acquiresleep(&ip->lock);
    80004634:	0541                	addi	a0,a0,16
    80004636:	00001097          	auipc	ra,0x1
    8000463a:	cb4080e7          	jalr	-844(ra) # 800052ea <acquiresleep>
  if(ip->valid == 0){
    8000463e:	40bc                	lw	a5,64(s1)
    80004640:	cf99                	beqz	a5,8000465e <ilock+0x40>
}
    80004642:	60e2                	ld	ra,24(sp)
    80004644:	6442                	ld	s0,16(sp)
    80004646:	64a2                	ld	s1,8(sp)
    80004648:	6902                	ld	s2,0(sp)
    8000464a:	6105                	addi	sp,sp,32
    8000464c:	8082                	ret
    panic("ilock");
    8000464e:	00004517          	auipc	a0,0x4
    80004652:	15a50513          	addi	a0,a0,346 # 800087a8 <syscalls+0x1b8>
    80004656:	ffffc097          	auipc	ra,0xffffc
    8000465a:	ed8080e7          	jalr	-296(ra) # 8000052e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000465e:	40dc                	lw	a5,4(s1)
    80004660:	0047d79b          	srliw	a5,a5,0x4
    80004664:	00037597          	auipc	a1,0x37
    80004668:	9b45a583          	lw	a1,-1612(a1) # 8003b018 <sb+0x18>
    8000466c:	9dbd                	addw	a1,a1,a5
    8000466e:	4088                	lw	a0,0(s1)
    80004670:	fffff097          	auipc	ra,0xfffff
    80004674:	7aa080e7          	jalr	1962(ra) # 80003e1a <bread>
    80004678:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000467a:	05850593          	addi	a1,a0,88
    8000467e:	40dc                	lw	a5,4(s1)
    80004680:	8bbd                	andi	a5,a5,15
    80004682:	079a                	slli	a5,a5,0x6
    80004684:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80004686:	00059783          	lh	a5,0(a1)
    8000468a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000468e:	00259783          	lh	a5,2(a1)
    80004692:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80004696:	00459783          	lh	a5,4(a1)
    8000469a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000469e:	00659783          	lh	a5,6(a1)
    800046a2:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800046a6:	459c                	lw	a5,8(a1)
    800046a8:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800046aa:	03400613          	li	a2,52
    800046ae:	05b1                	addi	a1,a1,12
    800046b0:	05048513          	addi	a0,s1,80
    800046b4:	ffffc097          	auipc	ra,0xffffc
    800046b8:	680080e7          	jalr	1664(ra) # 80000d34 <memmove>
    brelse(bp);
    800046bc:	854a                	mv	a0,s2
    800046be:	00000097          	auipc	ra,0x0
    800046c2:	88c080e7          	jalr	-1908(ra) # 80003f4a <brelse>
    ip->valid = 1;
    800046c6:	4785                	li	a5,1
    800046c8:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800046ca:	04449783          	lh	a5,68(s1)
    800046ce:	fbb5                	bnez	a5,80004642 <ilock+0x24>
      panic("ilock: no type");
    800046d0:	00004517          	auipc	a0,0x4
    800046d4:	0e050513          	addi	a0,a0,224 # 800087b0 <syscalls+0x1c0>
    800046d8:	ffffc097          	auipc	ra,0xffffc
    800046dc:	e56080e7          	jalr	-426(ra) # 8000052e <panic>

00000000800046e0 <iunlock>:
{
    800046e0:	1101                	addi	sp,sp,-32
    800046e2:	ec06                	sd	ra,24(sp)
    800046e4:	e822                	sd	s0,16(sp)
    800046e6:	e426                	sd	s1,8(sp)
    800046e8:	e04a                	sd	s2,0(sp)
    800046ea:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800046ec:	c905                	beqz	a0,8000471c <iunlock+0x3c>
    800046ee:	84aa                	mv	s1,a0
    800046f0:	01050913          	addi	s2,a0,16
    800046f4:	854a                	mv	a0,s2
    800046f6:	00001097          	auipc	ra,0x1
    800046fa:	c8e080e7          	jalr	-882(ra) # 80005384 <holdingsleep>
    800046fe:	cd19                	beqz	a0,8000471c <iunlock+0x3c>
    80004700:	449c                	lw	a5,8(s1)
    80004702:	00f05d63          	blez	a5,8000471c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80004706:	854a                	mv	a0,s2
    80004708:	00001097          	auipc	ra,0x1
    8000470c:	c38080e7          	jalr	-968(ra) # 80005340 <releasesleep>
}
    80004710:	60e2                	ld	ra,24(sp)
    80004712:	6442                	ld	s0,16(sp)
    80004714:	64a2                	ld	s1,8(sp)
    80004716:	6902                	ld	s2,0(sp)
    80004718:	6105                	addi	sp,sp,32
    8000471a:	8082                	ret
    panic("iunlock");
    8000471c:	00004517          	auipc	a0,0x4
    80004720:	0a450513          	addi	a0,a0,164 # 800087c0 <syscalls+0x1d0>
    80004724:	ffffc097          	auipc	ra,0xffffc
    80004728:	e0a080e7          	jalr	-502(ra) # 8000052e <panic>

000000008000472c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000472c:	7179                	addi	sp,sp,-48
    8000472e:	f406                	sd	ra,40(sp)
    80004730:	f022                	sd	s0,32(sp)
    80004732:	ec26                	sd	s1,24(sp)
    80004734:	e84a                	sd	s2,16(sp)
    80004736:	e44e                	sd	s3,8(sp)
    80004738:	e052                	sd	s4,0(sp)
    8000473a:	1800                	addi	s0,sp,48
    8000473c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000473e:	05050493          	addi	s1,a0,80
    80004742:	08050913          	addi	s2,a0,128
    80004746:	a021                	j	8000474e <itrunc+0x22>
    80004748:	0491                	addi	s1,s1,4
    8000474a:	01248d63          	beq	s1,s2,80004764 <itrunc+0x38>
    if(ip->addrs[i]){
    8000474e:	408c                	lw	a1,0(s1)
    80004750:	dde5                	beqz	a1,80004748 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80004752:	0009a503          	lw	a0,0(s3)
    80004756:	00000097          	auipc	ra,0x0
    8000475a:	90a080e7          	jalr	-1782(ra) # 80004060 <bfree>
      ip->addrs[i] = 0;
    8000475e:	0004a023          	sw	zero,0(s1)
    80004762:	b7dd                	j	80004748 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80004764:	0809a583          	lw	a1,128(s3)
    80004768:	e185                	bnez	a1,80004788 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000476a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000476e:	854e                	mv	a0,s3
    80004770:	00000097          	auipc	ra,0x0
    80004774:	de4080e7          	jalr	-540(ra) # 80004554 <iupdate>
}
    80004778:	70a2                	ld	ra,40(sp)
    8000477a:	7402                	ld	s0,32(sp)
    8000477c:	64e2                	ld	s1,24(sp)
    8000477e:	6942                	ld	s2,16(sp)
    80004780:	69a2                	ld	s3,8(sp)
    80004782:	6a02                	ld	s4,0(sp)
    80004784:	6145                	addi	sp,sp,48
    80004786:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80004788:	0009a503          	lw	a0,0(s3)
    8000478c:	fffff097          	auipc	ra,0xfffff
    80004790:	68e080e7          	jalr	1678(ra) # 80003e1a <bread>
    80004794:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80004796:	05850493          	addi	s1,a0,88
    8000479a:	45850913          	addi	s2,a0,1112
    8000479e:	a021                	j	800047a6 <itrunc+0x7a>
    800047a0:	0491                	addi	s1,s1,4
    800047a2:	01248b63          	beq	s1,s2,800047b8 <itrunc+0x8c>
      if(a[j])
    800047a6:	408c                	lw	a1,0(s1)
    800047a8:	dde5                	beqz	a1,800047a0 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800047aa:	0009a503          	lw	a0,0(s3)
    800047ae:	00000097          	auipc	ra,0x0
    800047b2:	8b2080e7          	jalr	-1870(ra) # 80004060 <bfree>
    800047b6:	b7ed                	j	800047a0 <itrunc+0x74>
    brelse(bp);
    800047b8:	8552                	mv	a0,s4
    800047ba:	fffff097          	auipc	ra,0xfffff
    800047be:	790080e7          	jalr	1936(ra) # 80003f4a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800047c2:	0809a583          	lw	a1,128(s3)
    800047c6:	0009a503          	lw	a0,0(s3)
    800047ca:	00000097          	auipc	ra,0x0
    800047ce:	896080e7          	jalr	-1898(ra) # 80004060 <bfree>
    ip->addrs[NDIRECT] = 0;
    800047d2:	0809a023          	sw	zero,128(s3)
    800047d6:	bf51                	j	8000476a <itrunc+0x3e>

00000000800047d8 <iput>:
{
    800047d8:	1101                	addi	sp,sp,-32
    800047da:	ec06                	sd	ra,24(sp)
    800047dc:	e822                	sd	s0,16(sp)
    800047de:	e426                	sd	s1,8(sp)
    800047e0:	e04a                	sd	s2,0(sp)
    800047e2:	1000                	addi	s0,sp,32
    800047e4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800047e6:	00037517          	auipc	a0,0x37
    800047ea:	83a50513          	addi	a0,a0,-1990 # 8003b020 <itable>
    800047ee:	ffffc097          	auipc	ra,0xffffc
    800047f2:	3d8080e7          	jalr	984(ra) # 80000bc6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800047f6:	4498                	lw	a4,8(s1)
    800047f8:	4785                	li	a5,1
    800047fa:	02f70363          	beq	a4,a5,80004820 <iput+0x48>
  ip->ref--;
    800047fe:	449c                	lw	a5,8(s1)
    80004800:	37fd                	addiw	a5,a5,-1
    80004802:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004804:	00037517          	auipc	a0,0x37
    80004808:	81c50513          	addi	a0,a0,-2020 # 8003b020 <itable>
    8000480c:	ffffc097          	auipc	ra,0xffffc
    80004810:	484080e7          	jalr	1156(ra) # 80000c90 <release>
}
    80004814:	60e2                	ld	ra,24(sp)
    80004816:	6442                	ld	s0,16(sp)
    80004818:	64a2                	ld	s1,8(sp)
    8000481a:	6902                	ld	s2,0(sp)
    8000481c:	6105                	addi	sp,sp,32
    8000481e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004820:	40bc                	lw	a5,64(s1)
    80004822:	dff1                	beqz	a5,800047fe <iput+0x26>
    80004824:	04a49783          	lh	a5,74(s1)
    80004828:	fbf9                	bnez	a5,800047fe <iput+0x26>
    acquiresleep(&ip->lock);
    8000482a:	01048913          	addi	s2,s1,16
    8000482e:	854a                	mv	a0,s2
    80004830:	00001097          	auipc	ra,0x1
    80004834:	aba080e7          	jalr	-1350(ra) # 800052ea <acquiresleep>
    release(&itable.lock);
    80004838:	00036517          	auipc	a0,0x36
    8000483c:	7e850513          	addi	a0,a0,2024 # 8003b020 <itable>
    80004840:	ffffc097          	auipc	ra,0xffffc
    80004844:	450080e7          	jalr	1104(ra) # 80000c90 <release>
    itrunc(ip);
    80004848:	8526                	mv	a0,s1
    8000484a:	00000097          	auipc	ra,0x0
    8000484e:	ee2080e7          	jalr	-286(ra) # 8000472c <itrunc>
    ip->type = 0;
    80004852:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80004856:	8526                	mv	a0,s1
    80004858:	00000097          	auipc	ra,0x0
    8000485c:	cfc080e7          	jalr	-772(ra) # 80004554 <iupdate>
    ip->valid = 0;
    80004860:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004864:	854a                	mv	a0,s2
    80004866:	00001097          	auipc	ra,0x1
    8000486a:	ada080e7          	jalr	-1318(ra) # 80005340 <releasesleep>
    acquire(&itable.lock);
    8000486e:	00036517          	auipc	a0,0x36
    80004872:	7b250513          	addi	a0,a0,1970 # 8003b020 <itable>
    80004876:	ffffc097          	auipc	ra,0xffffc
    8000487a:	350080e7          	jalr	848(ra) # 80000bc6 <acquire>
    8000487e:	b741                	j	800047fe <iput+0x26>

0000000080004880 <iunlockput>:
{
    80004880:	1101                	addi	sp,sp,-32
    80004882:	ec06                	sd	ra,24(sp)
    80004884:	e822                	sd	s0,16(sp)
    80004886:	e426                	sd	s1,8(sp)
    80004888:	1000                	addi	s0,sp,32
    8000488a:	84aa                	mv	s1,a0
  iunlock(ip);
    8000488c:	00000097          	auipc	ra,0x0
    80004890:	e54080e7          	jalr	-428(ra) # 800046e0 <iunlock>
  iput(ip);
    80004894:	8526                	mv	a0,s1
    80004896:	00000097          	auipc	ra,0x0
    8000489a:	f42080e7          	jalr	-190(ra) # 800047d8 <iput>
}
    8000489e:	60e2                	ld	ra,24(sp)
    800048a0:	6442                	ld	s0,16(sp)
    800048a2:	64a2                	ld	s1,8(sp)
    800048a4:	6105                	addi	sp,sp,32
    800048a6:	8082                	ret

00000000800048a8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800048a8:	1141                	addi	sp,sp,-16
    800048aa:	e422                	sd	s0,8(sp)
    800048ac:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800048ae:	411c                	lw	a5,0(a0)
    800048b0:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800048b2:	415c                	lw	a5,4(a0)
    800048b4:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800048b6:	04451783          	lh	a5,68(a0)
    800048ba:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800048be:	04a51783          	lh	a5,74(a0)
    800048c2:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800048c6:	04c56783          	lwu	a5,76(a0)
    800048ca:	e99c                	sd	a5,16(a1)
}
    800048cc:	6422                	ld	s0,8(sp)
    800048ce:	0141                	addi	sp,sp,16
    800048d0:	8082                	ret

00000000800048d2 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800048d2:	457c                	lw	a5,76(a0)
    800048d4:	0ed7e963          	bltu	a5,a3,800049c6 <readi+0xf4>
{
    800048d8:	7159                	addi	sp,sp,-112
    800048da:	f486                	sd	ra,104(sp)
    800048dc:	f0a2                	sd	s0,96(sp)
    800048de:	eca6                	sd	s1,88(sp)
    800048e0:	e8ca                	sd	s2,80(sp)
    800048e2:	e4ce                	sd	s3,72(sp)
    800048e4:	e0d2                	sd	s4,64(sp)
    800048e6:	fc56                	sd	s5,56(sp)
    800048e8:	f85a                	sd	s6,48(sp)
    800048ea:	f45e                	sd	s7,40(sp)
    800048ec:	f062                	sd	s8,32(sp)
    800048ee:	ec66                	sd	s9,24(sp)
    800048f0:	e86a                	sd	s10,16(sp)
    800048f2:	e46e                	sd	s11,8(sp)
    800048f4:	1880                	addi	s0,sp,112
    800048f6:	8baa                	mv	s7,a0
    800048f8:	8c2e                	mv	s8,a1
    800048fa:	8ab2                	mv	s5,a2
    800048fc:	84b6                	mv	s1,a3
    800048fe:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80004900:	9f35                	addw	a4,a4,a3
    return 0;
    80004902:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004904:	0ad76063          	bltu	a4,a3,800049a4 <readi+0xd2>
  if(off + n > ip->size)
    80004908:	00e7f463          	bgeu	a5,a4,80004910 <readi+0x3e>
    n = ip->size - off;
    8000490c:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004910:	0a0b0963          	beqz	s6,800049c2 <readi+0xf0>
    80004914:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004916:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000491a:	5cfd                	li	s9,-1
    8000491c:	a82d                	j	80004956 <readi+0x84>
    8000491e:	020a1d93          	slli	s11,s4,0x20
    80004922:	020ddd93          	srli	s11,s11,0x20
    80004926:	05890793          	addi	a5,s2,88
    8000492a:	86ee                	mv	a3,s11
    8000492c:	963e                	add	a2,a2,a5
    8000492e:	85d6                	mv	a1,s5
    80004930:	8562                	mv	a0,s8
    80004932:	ffffe097          	auipc	ra,0xffffe
    80004936:	0b6080e7          	jalr	182(ra) # 800029e8 <either_copyout>
    8000493a:	05950d63          	beq	a0,s9,80004994 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000493e:	854a                	mv	a0,s2
    80004940:	fffff097          	auipc	ra,0xfffff
    80004944:	60a080e7          	jalr	1546(ra) # 80003f4a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004948:	013a09bb          	addw	s3,s4,s3
    8000494c:	009a04bb          	addw	s1,s4,s1
    80004950:	9aee                	add	s5,s5,s11
    80004952:	0569f763          	bgeu	s3,s6,800049a0 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004956:	000ba903          	lw	s2,0(s7)
    8000495a:	00a4d59b          	srliw	a1,s1,0xa
    8000495e:	855e                	mv	a0,s7
    80004960:	00000097          	auipc	ra,0x0
    80004964:	8ae080e7          	jalr	-1874(ra) # 8000420e <bmap>
    80004968:	0005059b          	sext.w	a1,a0
    8000496c:	854a                	mv	a0,s2
    8000496e:	fffff097          	auipc	ra,0xfffff
    80004972:	4ac080e7          	jalr	1196(ra) # 80003e1a <bread>
    80004976:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004978:	3ff4f613          	andi	a2,s1,1023
    8000497c:	40cd07bb          	subw	a5,s10,a2
    80004980:	413b073b          	subw	a4,s6,s3
    80004984:	8a3e                	mv	s4,a5
    80004986:	2781                	sext.w	a5,a5
    80004988:	0007069b          	sext.w	a3,a4
    8000498c:	f8f6f9e3          	bgeu	a3,a5,8000491e <readi+0x4c>
    80004990:	8a3a                	mv	s4,a4
    80004992:	b771                	j	8000491e <readi+0x4c>
      brelse(bp);
    80004994:	854a                	mv	a0,s2
    80004996:	fffff097          	auipc	ra,0xfffff
    8000499a:	5b4080e7          	jalr	1460(ra) # 80003f4a <brelse>
      tot = -1;
    8000499e:	59fd                	li	s3,-1
  }
  return tot;
    800049a0:	0009851b          	sext.w	a0,s3
}
    800049a4:	70a6                	ld	ra,104(sp)
    800049a6:	7406                	ld	s0,96(sp)
    800049a8:	64e6                	ld	s1,88(sp)
    800049aa:	6946                	ld	s2,80(sp)
    800049ac:	69a6                	ld	s3,72(sp)
    800049ae:	6a06                	ld	s4,64(sp)
    800049b0:	7ae2                	ld	s5,56(sp)
    800049b2:	7b42                	ld	s6,48(sp)
    800049b4:	7ba2                	ld	s7,40(sp)
    800049b6:	7c02                	ld	s8,32(sp)
    800049b8:	6ce2                	ld	s9,24(sp)
    800049ba:	6d42                	ld	s10,16(sp)
    800049bc:	6da2                	ld	s11,8(sp)
    800049be:	6165                	addi	sp,sp,112
    800049c0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800049c2:	89da                	mv	s3,s6
    800049c4:	bff1                	j	800049a0 <readi+0xce>
    return 0;
    800049c6:	4501                	li	a0,0
}
    800049c8:	8082                	ret

00000000800049ca <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800049ca:	457c                	lw	a5,76(a0)
    800049cc:	10d7e863          	bltu	a5,a3,80004adc <writei+0x112>
{
    800049d0:	7159                	addi	sp,sp,-112
    800049d2:	f486                	sd	ra,104(sp)
    800049d4:	f0a2                	sd	s0,96(sp)
    800049d6:	eca6                	sd	s1,88(sp)
    800049d8:	e8ca                	sd	s2,80(sp)
    800049da:	e4ce                	sd	s3,72(sp)
    800049dc:	e0d2                	sd	s4,64(sp)
    800049de:	fc56                	sd	s5,56(sp)
    800049e0:	f85a                	sd	s6,48(sp)
    800049e2:	f45e                	sd	s7,40(sp)
    800049e4:	f062                	sd	s8,32(sp)
    800049e6:	ec66                	sd	s9,24(sp)
    800049e8:	e86a                	sd	s10,16(sp)
    800049ea:	e46e                	sd	s11,8(sp)
    800049ec:	1880                	addi	s0,sp,112
    800049ee:	8b2a                	mv	s6,a0
    800049f0:	8c2e                	mv	s8,a1
    800049f2:	8ab2                	mv	s5,a2
    800049f4:	8936                	mv	s2,a3
    800049f6:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    800049f8:	00e687bb          	addw	a5,a3,a4
    800049fc:	0ed7e263          	bltu	a5,a3,80004ae0 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004a00:	00043737          	lui	a4,0x43
    80004a04:	0ef76063          	bltu	a4,a5,80004ae4 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004a08:	0c0b8863          	beqz	s7,80004ad8 <writei+0x10e>
    80004a0c:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80004a0e:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004a12:	5cfd                	li	s9,-1
    80004a14:	a091                	j	80004a58 <writei+0x8e>
    80004a16:	02099d93          	slli	s11,s3,0x20
    80004a1a:	020ddd93          	srli	s11,s11,0x20
    80004a1e:	05848793          	addi	a5,s1,88
    80004a22:	86ee                	mv	a3,s11
    80004a24:	8656                	mv	a2,s5
    80004a26:	85e2                	mv	a1,s8
    80004a28:	953e                	add	a0,a0,a5
    80004a2a:	ffffe097          	auipc	ra,0xffffe
    80004a2e:	014080e7          	jalr	20(ra) # 80002a3e <either_copyin>
    80004a32:	07950263          	beq	a0,s9,80004a96 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004a36:	8526                	mv	a0,s1
    80004a38:	00000097          	auipc	ra,0x0
    80004a3c:	792080e7          	jalr	1938(ra) # 800051ca <log_write>
    brelse(bp);
    80004a40:	8526                	mv	a0,s1
    80004a42:	fffff097          	auipc	ra,0xfffff
    80004a46:	508080e7          	jalr	1288(ra) # 80003f4a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004a4a:	01498a3b          	addw	s4,s3,s4
    80004a4e:	0129893b          	addw	s2,s3,s2
    80004a52:	9aee                	add	s5,s5,s11
    80004a54:	057a7663          	bgeu	s4,s7,80004aa0 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80004a58:	000b2483          	lw	s1,0(s6)
    80004a5c:	00a9559b          	srliw	a1,s2,0xa
    80004a60:	855a                	mv	a0,s6
    80004a62:	fffff097          	auipc	ra,0xfffff
    80004a66:	7ac080e7          	jalr	1964(ra) # 8000420e <bmap>
    80004a6a:	0005059b          	sext.w	a1,a0
    80004a6e:	8526                	mv	a0,s1
    80004a70:	fffff097          	auipc	ra,0xfffff
    80004a74:	3aa080e7          	jalr	938(ra) # 80003e1a <bread>
    80004a78:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80004a7a:	3ff97513          	andi	a0,s2,1023
    80004a7e:	40ad07bb          	subw	a5,s10,a0
    80004a82:	414b873b          	subw	a4,s7,s4
    80004a86:	89be                	mv	s3,a5
    80004a88:	2781                	sext.w	a5,a5
    80004a8a:	0007069b          	sext.w	a3,a4
    80004a8e:	f8f6f4e3          	bgeu	a3,a5,80004a16 <writei+0x4c>
    80004a92:	89ba                	mv	s3,a4
    80004a94:	b749                	j	80004a16 <writei+0x4c>
      brelse(bp);
    80004a96:	8526                	mv	a0,s1
    80004a98:	fffff097          	auipc	ra,0xfffff
    80004a9c:	4b2080e7          	jalr	1202(ra) # 80003f4a <brelse>
  }

  if(off > ip->size)
    80004aa0:	04cb2783          	lw	a5,76(s6)
    80004aa4:	0127f463          	bgeu	a5,s2,80004aac <writei+0xe2>
    ip->size = off;
    80004aa8:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004aac:	855a                	mv	a0,s6
    80004aae:	00000097          	auipc	ra,0x0
    80004ab2:	aa6080e7          	jalr	-1370(ra) # 80004554 <iupdate>

  return tot;
    80004ab6:	000a051b          	sext.w	a0,s4
}
    80004aba:	70a6                	ld	ra,104(sp)
    80004abc:	7406                	ld	s0,96(sp)
    80004abe:	64e6                	ld	s1,88(sp)
    80004ac0:	6946                	ld	s2,80(sp)
    80004ac2:	69a6                	ld	s3,72(sp)
    80004ac4:	6a06                	ld	s4,64(sp)
    80004ac6:	7ae2                	ld	s5,56(sp)
    80004ac8:	7b42                	ld	s6,48(sp)
    80004aca:	7ba2                	ld	s7,40(sp)
    80004acc:	7c02                	ld	s8,32(sp)
    80004ace:	6ce2                	ld	s9,24(sp)
    80004ad0:	6d42                	ld	s10,16(sp)
    80004ad2:	6da2                	ld	s11,8(sp)
    80004ad4:	6165                	addi	sp,sp,112
    80004ad6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004ad8:	8a5e                	mv	s4,s7
    80004ada:	bfc9                	j	80004aac <writei+0xe2>
    return -1;
    80004adc:	557d                	li	a0,-1
}
    80004ade:	8082                	ret
    return -1;
    80004ae0:	557d                	li	a0,-1
    80004ae2:	bfe1                	j	80004aba <writei+0xf0>
    return -1;
    80004ae4:	557d                	li	a0,-1
    80004ae6:	bfd1                	j	80004aba <writei+0xf0>

0000000080004ae8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004ae8:	1141                	addi	sp,sp,-16
    80004aea:	e406                	sd	ra,8(sp)
    80004aec:	e022                	sd	s0,0(sp)
    80004aee:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004af0:	4639                	li	a2,14
    80004af2:	ffffc097          	auipc	ra,0xffffc
    80004af6:	2be080e7          	jalr	702(ra) # 80000db0 <strncmp>
}
    80004afa:	60a2                	ld	ra,8(sp)
    80004afc:	6402                	ld	s0,0(sp)
    80004afe:	0141                	addi	sp,sp,16
    80004b00:	8082                	ret

0000000080004b02 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004b02:	7139                	addi	sp,sp,-64
    80004b04:	fc06                	sd	ra,56(sp)
    80004b06:	f822                	sd	s0,48(sp)
    80004b08:	f426                	sd	s1,40(sp)
    80004b0a:	f04a                	sd	s2,32(sp)
    80004b0c:	ec4e                	sd	s3,24(sp)
    80004b0e:	e852                	sd	s4,16(sp)
    80004b10:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004b12:	04451703          	lh	a4,68(a0)
    80004b16:	4785                	li	a5,1
    80004b18:	00f71a63          	bne	a4,a5,80004b2c <dirlookup+0x2a>
    80004b1c:	892a                	mv	s2,a0
    80004b1e:	89ae                	mv	s3,a1
    80004b20:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004b22:	457c                	lw	a5,76(a0)
    80004b24:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004b26:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004b28:	e79d                	bnez	a5,80004b56 <dirlookup+0x54>
    80004b2a:	a8a5                	j	80004ba2 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004b2c:	00004517          	auipc	a0,0x4
    80004b30:	c9c50513          	addi	a0,a0,-868 # 800087c8 <syscalls+0x1d8>
    80004b34:	ffffc097          	auipc	ra,0xffffc
    80004b38:	9fa080e7          	jalr	-1542(ra) # 8000052e <panic>
      panic("dirlookup read");
    80004b3c:	00004517          	auipc	a0,0x4
    80004b40:	ca450513          	addi	a0,a0,-860 # 800087e0 <syscalls+0x1f0>
    80004b44:	ffffc097          	auipc	ra,0xffffc
    80004b48:	9ea080e7          	jalr	-1558(ra) # 8000052e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004b4c:	24c1                	addiw	s1,s1,16
    80004b4e:	04c92783          	lw	a5,76(s2)
    80004b52:	04f4f763          	bgeu	s1,a5,80004ba0 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004b56:	4741                	li	a4,16
    80004b58:	86a6                	mv	a3,s1
    80004b5a:	fc040613          	addi	a2,s0,-64
    80004b5e:	4581                	li	a1,0
    80004b60:	854a                	mv	a0,s2
    80004b62:	00000097          	auipc	ra,0x0
    80004b66:	d70080e7          	jalr	-656(ra) # 800048d2 <readi>
    80004b6a:	47c1                	li	a5,16
    80004b6c:	fcf518e3          	bne	a0,a5,80004b3c <dirlookup+0x3a>
    if(de.inum == 0)
    80004b70:	fc045783          	lhu	a5,-64(s0)
    80004b74:	dfe1                	beqz	a5,80004b4c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004b76:	fc240593          	addi	a1,s0,-62
    80004b7a:	854e                	mv	a0,s3
    80004b7c:	00000097          	auipc	ra,0x0
    80004b80:	f6c080e7          	jalr	-148(ra) # 80004ae8 <namecmp>
    80004b84:	f561                	bnez	a0,80004b4c <dirlookup+0x4a>
      if(poff)
    80004b86:	000a0463          	beqz	s4,80004b8e <dirlookup+0x8c>
        *poff = off;
    80004b8a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004b8e:	fc045583          	lhu	a1,-64(s0)
    80004b92:	00092503          	lw	a0,0(s2)
    80004b96:	fffff097          	auipc	ra,0xfffff
    80004b9a:	754080e7          	jalr	1876(ra) # 800042ea <iget>
    80004b9e:	a011                	j	80004ba2 <dirlookup+0xa0>
  return 0;
    80004ba0:	4501                	li	a0,0
}
    80004ba2:	70e2                	ld	ra,56(sp)
    80004ba4:	7442                	ld	s0,48(sp)
    80004ba6:	74a2                	ld	s1,40(sp)
    80004ba8:	7902                	ld	s2,32(sp)
    80004baa:	69e2                	ld	s3,24(sp)
    80004bac:	6a42                	ld	s4,16(sp)
    80004bae:	6121                	addi	sp,sp,64
    80004bb0:	8082                	ret

0000000080004bb2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004bb2:	711d                	addi	sp,sp,-96
    80004bb4:	ec86                	sd	ra,88(sp)
    80004bb6:	e8a2                	sd	s0,80(sp)
    80004bb8:	e4a6                	sd	s1,72(sp)
    80004bba:	e0ca                	sd	s2,64(sp)
    80004bbc:	fc4e                	sd	s3,56(sp)
    80004bbe:	f852                	sd	s4,48(sp)
    80004bc0:	f456                	sd	s5,40(sp)
    80004bc2:	f05a                	sd	s6,32(sp)
    80004bc4:	ec5e                	sd	s7,24(sp)
    80004bc6:	e862                	sd	s8,16(sp)
    80004bc8:	e466                	sd	s9,8(sp)
    80004bca:	1080                	addi	s0,sp,96
    80004bcc:	84aa                	mv	s1,a0
    80004bce:	8aae                	mv	s5,a1
    80004bd0:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004bd2:	00054703          	lbu	a4,0(a0)
    80004bd6:	02f00793          	li	a5,47
    80004bda:	02f70263          	beq	a4,a5,80004bfe <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004bde:	ffffd097          	auipc	ra,0xffffd
    80004be2:	ec2080e7          	jalr	-318(ra) # 80001aa0 <myproc>
    80004be6:	6968                	ld	a0,208(a0)
    80004be8:	00000097          	auipc	ra,0x0
    80004bec:	9f8080e7          	jalr	-1544(ra) # 800045e0 <idup>
    80004bf0:	89aa                	mv	s3,a0
  while(*path == '/')
    80004bf2:	02f00913          	li	s2,47
  len = path - s;
    80004bf6:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004bf8:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004bfa:	4b85                	li	s7,1
    80004bfc:	a865                	j	80004cb4 <namex+0x102>
    ip = iget(ROOTDEV, ROOTINO);
    80004bfe:	4585                	li	a1,1
    80004c00:	4505                	li	a0,1
    80004c02:	fffff097          	auipc	ra,0xfffff
    80004c06:	6e8080e7          	jalr	1768(ra) # 800042ea <iget>
    80004c0a:	89aa                	mv	s3,a0
    80004c0c:	b7dd                	j	80004bf2 <namex+0x40>
      iunlockput(ip);
    80004c0e:	854e                	mv	a0,s3
    80004c10:	00000097          	auipc	ra,0x0
    80004c14:	c70080e7          	jalr	-912(ra) # 80004880 <iunlockput>
      return 0;
    80004c18:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004c1a:	854e                	mv	a0,s3
    80004c1c:	60e6                	ld	ra,88(sp)
    80004c1e:	6446                	ld	s0,80(sp)
    80004c20:	64a6                	ld	s1,72(sp)
    80004c22:	6906                	ld	s2,64(sp)
    80004c24:	79e2                	ld	s3,56(sp)
    80004c26:	7a42                	ld	s4,48(sp)
    80004c28:	7aa2                	ld	s5,40(sp)
    80004c2a:	7b02                	ld	s6,32(sp)
    80004c2c:	6be2                	ld	s7,24(sp)
    80004c2e:	6c42                	ld	s8,16(sp)
    80004c30:	6ca2                	ld	s9,8(sp)
    80004c32:	6125                	addi	sp,sp,96
    80004c34:	8082                	ret
      iunlock(ip);
    80004c36:	854e                	mv	a0,s3
    80004c38:	00000097          	auipc	ra,0x0
    80004c3c:	aa8080e7          	jalr	-1368(ra) # 800046e0 <iunlock>
      return ip;
    80004c40:	bfe9                	j	80004c1a <namex+0x68>
      iunlockput(ip);
    80004c42:	854e                	mv	a0,s3
    80004c44:	00000097          	auipc	ra,0x0
    80004c48:	c3c080e7          	jalr	-964(ra) # 80004880 <iunlockput>
      return 0;
    80004c4c:	89e6                	mv	s3,s9
    80004c4e:	b7f1                	j	80004c1a <namex+0x68>
  len = path - s;
    80004c50:	40b48633          	sub	a2,s1,a1
    80004c54:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004c58:	099c5463          	bge	s8,s9,80004ce0 <namex+0x12e>
    memmove(name, s, DIRSIZ);
    80004c5c:	4639                	li	a2,14
    80004c5e:	8552                	mv	a0,s4
    80004c60:	ffffc097          	auipc	ra,0xffffc
    80004c64:	0d4080e7          	jalr	212(ra) # 80000d34 <memmove>
  while(*path == '/')
    80004c68:	0004c783          	lbu	a5,0(s1)
    80004c6c:	01279763          	bne	a5,s2,80004c7a <namex+0xc8>
    path++;
    80004c70:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004c72:	0004c783          	lbu	a5,0(s1)
    80004c76:	ff278de3          	beq	a5,s2,80004c70 <namex+0xbe>
    ilock(ip);
    80004c7a:	854e                	mv	a0,s3
    80004c7c:	00000097          	auipc	ra,0x0
    80004c80:	9a2080e7          	jalr	-1630(ra) # 8000461e <ilock>
    if(ip->type != T_DIR){
    80004c84:	04499783          	lh	a5,68(s3)
    80004c88:	f97793e3          	bne	a5,s7,80004c0e <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004c8c:	000a8563          	beqz	s5,80004c96 <namex+0xe4>
    80004c90:	0004c783          	lbu	a5,0(s1)
    80004c94:	d3cd                	beqz	a5,80004c36 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004c96:	865a                	mv	a2,s6
    80004c98:	85d2                	mv	a1,s4
    80004c9a:	854e                	mv	a0,s3
    80004c9c:	00000097          	auipc	ra,0x0
    80004ca0:	e66080e7          	jalr	-410(ra) # 80004b02 <dirlookup>
    80004ca4:	8caa                	mv	s9,a0
    80004ca6:	dd51                	beqz	a0,80004c42 <namex+0x90>
    iunlockput(ip);
    80004ca8:	854e                	mv	a0,s3
    80004caa:	00000097          	auipc	ra,0x0
    80004cae:	bd6080e7          	jalr	-1066(ra) # 80004880 <iunlockput>
    ip = next;
    80004cb2:	89e6                	mv	s3,s9
  while(*path == '/')
    80004cb4:	0004c783          	lbu	a5,0(s1)
    80004cb8:	05279763          	bne	a5,s2,80004d06 <namex+0x154>
    path++;
    80004cbc:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004cbe:	0004c783          	lbu	a5,0(s1)
    80004cc2:	ff278de3          	beq	a5,s2,80004cbc <namex+0x10a>
  if(*path == 0)
    80004cc6:	c79d                	beqz	a5,80004cf4 <namex+0x142>
    path++;
    80004cc8:	85a6                	mv	a1,s1
  len = path - s;
    80004cca:	8cda                	mv	s9,s6
    80004ccc:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80004cce:	01278963          	beq	a5,s2,80004ce0 <namex+0x12e>
    80004cd2:	dfbd                	beqz	a5,80004c50 <namex+0x9e>
    path++;
    80004cd4:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004cd6:	0004c783          	lbu	a5,0(s1)
    80004cda:	ff279ce3          	bne	a5,s2,80004cd2 <namex+0x120>
    80004cde:	bf8d                	j	80004c50 <namex+0x9e>
    memmove(name, s, len);
    80004ce0:	2601                	sext.w	a2,a2
    80004ce2:	8552                	mv	a0,s4
    80004ce4:	ffffc097          	auipc	ra,0xffffc
    80004ce8:	050080e7          	jalr	80(ra) # 80000d34 <memmove>
    name[len] = 0;
    80004cec:	9cd2                	add	s9,s9,s4
    80004cee:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004cf2:	bf9d                	j	80004c68 <namex+0xb6>
  if(nameiparent){
    80004cf4:	f20a83e3          	beqz	s5,80004c1a <namex+0x68>
    iput(ip);
    80004cf8:	854e                	mv	a0,s3
    80004cfa:	00000097          	auipc	ra,0x0
    80004cfe:	ade080e7          	jalr	-1314(ra) # 800047d8 <iput>
    return 0;
    80004d02:	4981                	li	s3,0
    80004d04:	bf19                	j	80004c1a <namex+0x68>
  if(*path == 0)
    80004d06:	d7fd                	beqz	a5,80004cf4 <namex+0x142>
  while(*path != '/' && *path != 0)
    80004d08:	0004c783          	lbu	a5,0(s1)
    80004d0c:	85a6                	mv	a1,s1
    80004d0e:	b7d1                	j	80004cd2 <namex+0x120>

0000000080004d10 <dirlink>:
{
    80004d10:	7139                	addi	sp,sp,-64
    80004d12:	fc06                	sd	ra,56(sp)
    80004d14:	f822                	sd	s0,48(sp)
    80004d16:	f426                	sd	s1,40(sp)
    80004d18:	f04a                	sd	s2,32(sp)
    80004d1a:	ec4e                	sd	s3,24(sp)
    80004d1c:	e852                	sd	s4,16(sp)
    80004d1e:	0080                	addi	s0,sp,64
    80004d20:	892a                	mv	s2,a0
    80004d22:	8a2e                	mv	s4,a1
    80004d24:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004d26:	4601                	li	a2,0
    80004d28:	00000097          	auipc	ra,0x0
    80004d2c:	dda080e7          	jalr	-550(ra) # 80004b02 <dirlookup>
    80004d30:	e93d                	bnez	a0,80004da6 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004d32:	04c92483          	lw	s1,76(s2)
    80004d36:	c49d                	beqz	s1,80004d64 <dirlink+0x54>
    80004d38:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d3a:	4741                	li	a4,16
    80004d3c:	86a6                	mv	a3,s1
    80004d3e:	fc040613          	addi	a2,s0,-64
    80004d42:	4581                	li	a1,0
    80004d44:	854a                	mv	a0,s2
    80004d46:	00000097          	auipc	ra,0x0
    80004d4a:	b8c080e7          	jalr	-1140(ra) # 800048d2 <readi>
    80004d4e:	47c1                	li	a5,16
    80004d50:	06f51163          	bne	a0,a5,80004db2 <dirlink+0xa2>
    if(de.inum == 0)
    80004d54:	fc045783          	lhu	a5,-64(s0)
    80004d58:	c791                	beqz	a5,80004d64 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004d5a:	24c1                	addiw	s1,s1,16
    80004d5c:	04c92783          	lw	a5,76(s2)
    80004d60:	fcf4ede3          	bltu	s1,a5,80004d3a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004d64:	4639                	li	a2,14
    80004d66:	85d2                	mv	a1,s4
    80004d68:	fc240513          	addi	a0,s0,-62
    80004d6c:	ffffc097          	auipc	ra,0xffffc
    80004d70:	080080e7          	jalr	128(ra) # 80000dec <strncpy>
  de.inum = inum;
    80004d74:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d78:	4741                	li	a4,16
    80004d7a:	86a6                	mv	a3,s1
    80004d7c:	fc040613          	addi	a2,s0,-64
    80004d80:	4581                	li	a1,0
    80004d82:	854a                	mv	a0,s2
    80004d84:	00000097          	auipc	ra,0x0
    80004d88:	c46080e7          	jalr	-954(ra) # 800049ca <writei>
    80004d8c:	872a                	mv	a4,a0
    80004d8e:	47c1                	li	a5,16
  return 0;
    80004d90:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d92:	02f71863          	bne	a4,a5,80004dc2 <dirlink+0xb2>
}
    80004d96:	70e2                	ld	ra,56(sp)
    80004d98:	7442                	ld	s0,48(sp)
    80004d9a:	74a2                	ld	s1,40(sp)
    80004d9c:	7902                	ld	s2,32(sp)
    80004d9e:	69e2                	ld	s3,24(sp)
    80004da0:	6a42                	ld	s4,16(sp)
    80004da2:	6121                	addi	sp,sp,64
    80004da4:	8082                	ret
    iput(ip);
    80004da6:	00000097          	auipc	ra,0x0
    80004daa:	a32080e7          	jalr	-1486(ra) # 800047d8 <iput>
    return -1;
    80004dae:	557d                	li	a0,-1
    80004db0:	b7dd                	j	80004d96 <dirlink+0x86>
      panic("dirlink read");
    80004db2:	00004517          	auipc	a0,0x4
    80004db6:	a3e50513          	addi	a0,a0,-1474 # 800087f0 <syscalls+0x200>
    80004dba:	ffffb097          	auipc	ra,0xffffb
    80004dbe:	774080e7          	jalr	1908(ra) # 8000052e <panic>
    panic("dirlink");
    80004dc2:	00004517          	auipc	a0,0x4
    80004dc6:	b1e50513          	addi	a0,a0,-1250 # 800088e0 <syscalls+0x2f0>
    80004dca:	ffffb097          	auipc	ra,0xffffb
    80004dce:	764080e7          	jalr	1892(ra) # 8000052e <panic>

0000000080004dd2 <namei>:

struct inode*
namei(char *path)
{
    80004dd2:	1101                	addi	sp,sp,-32
    80004dd4:	ec06                	sd	ra,24(sp)
    80004dd6:	e822                	sd	s0,16(sp)
    80004dd8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004dda:	fe040613          	addi	a2,s0,-32
    80004dde:	4581                	li	a1,0
    80004de0:	00000097          	auipc	ra,0x0
    80004de4:	dd2080e7          	jalr	-558(ra) # 80004bb2 <namex>
}
    80004de8:	60e2                	ld	ra,24(sp)
    80004dea:	6442                	ld	s0,16(sp)
    80004dec:	6105                	addi	sp,sp,32
    80004dee:	8082                	ret

0000000080004df0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004df0:	1141                	addi	sp,sp,-16
    80004df2:	e406                	sd	ra,8(sp)
    80004df4:	e022                	sd	s0,0(sp)
    80004df6:	0800                	addi	s0,sp,16
    80004df8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004dfa:	4585                	li	a1,1
    80004dfc:	00000097          	auipc	ra,0x0
    80004e00:	db6080e7          	jalr	-586(ra) # 80004bb2 <namex>
}
    80004e04:	60a2                	ld	ra,8(sp)
    80004e06:	6402                	ld	s0,0(sp)
    80004e08:	0141                	addi	sp,sp,16
    80004e0a:	8082                	ret

0000000080004e0c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004e0c:	1101                	addi	sp,sp,-32
    80004e0e:	ec06                	sd	ra,24(sp)
    80004e10:	e822                	sd	s0,16(sp)
    80004e12:	e426                	sd	s1,8(sp)
    80004e14:	e04a                	sd	s2,0(sp)
    80004e16:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004e18:	00038917          	auipc	s2,0x38
    80004e1c:	cb090913          	addi	s2,s2,-848 # 8003cac8 <log>
    80004e20:	01892583          	lw	a1,24(s2)
    80004e24:	02892503          	lw	a0,40(s2)
    80004e28:	fffff097          	auipc	ra,0xfffff
    80004e2c:	ff2080e7          	jalr	-14(ra) # 80003e1a <bread>
    80004e30:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004e32:	02c92683          	lw	a3,44(s2)
    80004e36:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004e38:	02d05863          	blez	a3,80004e68 <write_head+0x5c>
    80004e3c:	00038797          	auipc	a5,0x38
    80004e40:	cbc78793          	addi	a5,a5,-836 # 8003caf8 <log+0x30>
    80004e44:	05c50713          	addi	a4,a0,92
    80004e48:	36fd                	addiw	a3,a3,-1
    80004e4a:	02069613          	slli	a2,a3,0x20
    80004e4e:	01e65693          	srli	a3,a2,0x1e
    80004e52:	00038617          	auipc	a2,0x38
    80004e56:	caa60613          	addi	a2,a2,-854 # 8003cafc <log+0x34>
    80004e5a:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004e5c:	4390                	lw	a2,0(a5)
    80004e5e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004e60:	0791                	addi	a5,a5,4
    80004e62:	0711                	addi	a4,a4,4
    80004e64:	fed79ce3          	bne	a5,a3,80004e5c <write_head+0x50>
  }
  bwrite(buf);
    80004e68:	8526                	mv	a0,s1
    80004e6a:	fffff097          	auipc	ra,0xfffff
    80004e6e:	0a2080e7          	jalr	162(ra) # 80003f0c <bwrite>
  brelse(buf);
    80004e72:	8526                	mv	a0,s1
    80004e74:	fffff097          	auipc	ra,0xfffff
    80004e78:	0d6080e7          	jalr	214(ra) # 80003f4a <brelse>
}
    80004e7c:	60e2                	ld	ra,24(sp)
    80004e7e:	6442                	ld	s0,16(sp)
    80004e80:	64a2                	ld	s1,8(sp)
    80004e82:	6902                	ld	s2,0(sp)
    80004e84:	6105                	addi	sp,sp,32
    80004e86:	8082                	ret

0000000080004e88 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004e88:	00038797          	auipc	a5,0x38
    80004e8c:	c6c7a783          	lw	a5,-916(a5) # 8003caf4 <log+0x2c>
    80004e90:	0af05d63          	blez	a5,80004f4a <install_trans+0xc2>
{
    80004e94:	7139                	addi	sp,sp,-64
    80004e96:	fc06                	sd	ra,56(sp)
    80004e98:	f822                	sd	s0,48(sp)
    80004e9a:	f426                	sd	s1,40(sp)
    80004e9c:	f04a                	sd	s2,32(sp)
    80004e9e:	ec4e                	sd	s3,24(sp)
    80004ea0:	e852                	sd	s4,16(sp)
    80004ea2:	e456                	sd	s5,8(sp)
    80004ea4:	e05a                	sd	s6,0(sp)
    80004ea6:	0080                	addi	s0,sp,64
    80004ea8:	8b2a                	mv	s6,a0
    80004eaa:	00038a97          	auipc	s5,0x38
    80004eae:	c4ea8a93          	addi	s5,s5,-946 # 8003caf8 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004eb2:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004eb4:	00038997          	auipc	s3,0x38
    80004eb8:	c1498993          	addi	s3,s3,-1004 # 8003cac8 <log>
    80004ebc:	a00d                	j	80004ede <install_trans+0x56>
    brelse(lbuf);
    80004ebe:	854a                	mv	a0,s2
    80004ec0:	fffff097          	auipc	ra,0xfffff
    80004ec4:	08a080e7          	jalr	138(ra) # 80003f4a <brelse>
    brelse(dbuf);
    80004ec8:	8526                	mv	a0,s1
    80004eca:	fffff097          	auipc	ra,0xfffff
    80004ece:	080080e7          	jalr	128(ra) # 80003f4a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004ed2:	2a05                	addiw	s4,s4,1
    80004ed4:	0a91                	addi	s5,s5,4
    80004ed6:	02c9a783          	lw	a5,44(s3)
    80004eda:	04fa5e63          	bge	s4,a5,80004f36 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004ede:	0189a583          	lw	a1,24(s3)
    80004ee2:	014585bb          	addw	a1,a1,s4
    80004ee6:	2585                	addiw	a1,a1,1
    80004ee8:	0289a503          	lw	a0,40(s3)
    80004eec:	fffff097          	auipc	ra,0xfffff
    80004ef0:	f2e080e7          	jalr	-210(ra) # 80003e1a <bread>
    80004ef4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004ef6:	000aa583          	lw	a1,0(s5)
    80004efa:	0289a503          	lw	a0,40(s3)
    80004efe:	fffff097          	auipc	ra,0xfffff
    80004f02:	f1c080e7          	jalr	-228(ra) # 80003e1a <bread>
    80004f06:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004f08:	40000613          	li	a2,1024
    80004f0c:	05890593          	addi	a1,s2,88
    80004f10:	05850513          	addi	a0,a0,88
    80004f14:	ffffc097          	auipc	ra,0xffffc
    80004f18:	e20080e7          	jalr	-480(ra) # 80000d34 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004f1c:	8526                	mv	a0,s1
    80004f1e:	fffff097          	auipc	ra,0xfffff
    80004f22:	fee080e7          	jalr	-18(ra) # 80003f0c <bwrite>
    if(recovering == 0)
    80004f26:	f80b1ce3          	bnez	s6,80004ebe <install_trans+0x36>
      bunpin(dbuf);
    80004f2a:	8526                	mv	a0,s1
    80004f2c:	fffff097          	auipc	ra,0xfffff
    80004f30:	0f8080e7          	jalr	248(ra) # 80004024 <bunpin>
    80004f34:	b769                	j	80004ebe <install_trans+0x36>
}
    80004f36:	70e2                	ld	ra,56(sp)
    80004f38:	7442                	ld	s0,48(sp)
    80004f3a:	74a2                	ld	s1,40(sp)
    80004f3c:	7902                	ld	s2,32(sp)
    80004f3e:	69e2                	ld	s3,24(sp)
    80004f40:	6a42                	ld	s4,16(sp)
    80004f42:	6aa2                	ld	s5,8(sp)
    80004f44:	6b02                	ld	s6,0(sp)
    80004f46:	6121                	addi	sp,sp,64
    80004f48:	8082                	ret
    80004f4a:	8082                	ret

0000000080004f4c <initlog>:
{
    80004f4c:	7179                	addi	sp,sp,-48
    80004f4e:	f406                	sd	ra,40(sp)
    80004f50:	f022                	sd	s0,32(sp)
    80004f52:	ec26                	sd	s1,24(sp)
    80004f54:	e84a                	sd	s2,16(sp)
    80004f56:	e44e                	sd	s3,8(sp)
    80004f58:	1800                	addi	s0,sp,48
    80004f5a:	892a                	mv	s2,a0
    80004f5c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004f5e:	00038497          	auipc	s1,0x38
    80004f62:	b6a48493          	addi	s1,s1,-1174 # 8003cac8 <log>
    80004f66:	00004597          	auipc	a1,0x4
    80004f6a:	89a58593          	addi	a1,a1,-1894 # 80008800 <syscalls+0x210>
    80004f6e:	8526                	mv	a0,s1
    80004f70:	ffffc097          	auipc	ra,0xffffc
    80004f74:	bc6080e7          	jalr	-1082(ra) # 80000b36 <initlock>
  log.start = sb->logstart;
    80004f78:	0149a583          	lw	a1,20(s3)
    80004f7c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004f7e:	0109a783          	lw	a5,16(s3)
    80004f82:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004f84:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004f88:	854a                	mv	a0,s2
    80004f8a:	fffff097          	auipc	ra,0xfffff
    80004f8e:	e90080e7          	jalr	-368(ra) # 80003e1a <bread>
  log.lh.n = lh->n;
    80004f92:	4d34                	lw	a3,88(a0)
    80004f94:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004f96:	02d05663          	blez	a3,80004fc2 <initlog+0x76>
    80004f9a:	05c50793          	addi	a5,a0,92
    80004f9e:	00038717          	auipc	a4,0x38
    80004fa2:	b5a70713          	addi	a4,a4,-1190 # 8003caf8 <log+0x30>
    80004fa6:	36fd                	addiw	a3,a3,-1
    80004fa8:	02069613          	slli	a2,a3,0x20
    80004fac:	01e65693          	srli	a3,a2,0x1e
    80004fb0:	06050613          	addi	a2,a0,96
    80004fb4:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004fb6:	4390                	lw	a2,0(a5)
    80004fb8:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004fba:	0791                	addi	a5,a5,4
    80004fbc:	0711                	addi	a4,a4,4
    80004fbe:	fed79ce3          	bne	a5,a3,80004fb6 <initlog+0x6a>
  brelse(buf);
    80004fc2:	fffff097          	auipc	ra,0xfffff
    80004fc6:	f88080e7          	jalr	-120(ra) # 80003f4a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004fca:	4505                	li	a0,1
    80004fcc:	00000097          	auipc	ra,0x0
    80004fd0:	ebc080e7          	jalr	-324(ra) # 80004e88 <install_trans>
  log.lh.n = 0;
    80004fd4:	00038797          	auipc	a5,0x38
    80004fd8:	b207a023          	sw	zero,-1248(a5) # 8003caf4 <log+0x2c>
  write_head(); // clear the log
    80004fdc:	00000097          	auipc	ra,0x0
    80004fe0:	e30080e7          	jalr	-464(ra) # 80004e0c <write_head>
}
    80004fe4:	70a2                	ld	ra,40(sp)
    80004fe6:	7402                	ld	s0,32(sp)
    80004fe8:	64e2                	ld	s1,24(sp)
    80004fea:	6942                	ld	s2,16(sp)
    80004fec:	69a2                	ld	s3,8(sp)
    80004fee:	6145                	addi	sp,sp,48
    80004ff0:	8082                	ret

0000000080004ff2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004ff2:	1101                	addi	sp,sp,-32
    80004ff4:	ec06                	sd	ra,24(sp)
    80004ff6:	e822                	sd	s0,16(sp)
    80004ff8:	e426                	sd	s1,8(sp)
    80004ffa:	e04a                	sd	s2,0(sp)
    80004ffc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004ffe:	00038517          	auipc	a0,0x38
    80005002:	aca50513          	addi	a0,a0,-1334 # 8003cac8 <log>
    80005006:	ffffc097          	auipc	ra,0xffffc
    8000500a:	bc0080e7          	jalr	-1088(ra) # 80000bc6 <acquire>
  while(1){
    if(log.committing){
    8000500e:	00038497          	auipc	s1,0x38
    80005012:	aba48493          	addi	s1,s1,-1350 # 8003cac8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80005016:	4979                	li	s2,30
    80005018:	a039                	j	80005026 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000501a:	85a6                	mv	a1,s1
    8000501c:	8526                	mv	a0,s1
    8000501e:	ffffd097          	auipc	ra,0xffffd
    80005022:	4c8080e7          	jalr	1224(ra) # 800024e6 <sleep>
    if(log.committing){
    80005026:	50dc                	lw	a5,36(s1)
    80005028:	fbed                	bnez	a5,8000501a <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000502a:	509c                	lw	a5,32(s1)
    8000502c:	0017871b          	addiw	a4,a5,1
    80005030:	0007069b          	sext.w	a3,a4
    80005034:	0027179b          	slliw	a5,a4,0x2
    80005038:	9fb9                	addw	a5,a5,a4
    8000503a:	0017979b          	slliw	a5,a5,0x1
    8000503e:	54d8                	lw	a4,44(s1)
    80005040:	9fb9                	addw	a5,a5,a4
    80005042:	00f95963          	bge	s2,a5,80005054 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80005046:	85a6                	mv	a1,s1
    80005048:	8526                	mv	a0,s1
    8000504a:	ffffd097          	auipc	ra,0xffffd
    8000504e:	49c080e7          	jalr	1180(ra) # 800024e6 <sleep>
    80005052:	bfd1                	j	80005026 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80005054:	00038517          	auipc	a0,0x38
    80005058:	a7450513          	addi	a0,a0,-1420 # 8003cac8 <log>
    8000505c:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000505e:	ffffc097          	auipc	ra,0xffffc
    80005062:	c32080e7          	jalr	-974(ra) # 80000c90 <release>
      break;
    }
  }
}
    80005066:	60e2                	ld	ra,24(sp)
    80005068:	6442                	ld	s0,16(sp)
    8000506a:	64a2                	ld	s1,8(sp)
    8000506c:	6902                	ld	s2,0(sp)
    8000506e:	6105                	addi	sp,sp,32
    80005070:	8082                	ret

0000000080005072 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80005072:	7139                	addi	sp,sp,-64
    80005074:	fc06                	sd	ra,56(sp)
    80005076:	f822                	sd	s0,48(sp)
    80005078:	f426                	sd	s1,40(sp)
    8000507a:	f04a                	sd	s2,32(sp)
    8000507c:	ec4e                	sd	s3,24(sp)
    8000507e:	e852                	sd	s4,16(sp)
    80005080:	e456                	sd	s5,8(sp)
    80005082:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80005084:	00038497          	auipc	s1,0x38
    80005088:	a4448493          	addi	s1,s1,-1468 # 8003cac8 <log>
    8000508c:	8526                	mv	a0,s1
    8000508e:	ffffc097          	auipc	ra,0xffffc
    80005092:	b38080e7          	jalr	-1224(ra) # 80000bc6 <acquire>
  log.outstanding -= 1;
    80005096:	509c                	lw	a5,32(s1)
    80005098:	37fd                	addiw	a5,a5,-1
    8000509a:	0007891b          	sext.w	s2,a5
    8000509e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800050a0:	50dc                	lw	a5,36(s1)
    800050a2:	e7b9                	bnez	a5,800050f0 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800050a4:	04091e63          	bnez	s2,80005100 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800050a8:	00038497          	auipc	s1,0x38
    800050ac:	a2048493          	addi	s1,s1,-1504 # 8003cac8 <log>
    800050b0:	4785                	li	a5,1
    800050b2:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800050b4:	8526                	mv	a0,s1
    800050b6:	ffffc097          	auipc	ra,0xffffc
    800050ba:	bda080e7          	jalr	-1062(ra) # 80000c90 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800050be:	54dc                	lw	a5,44(s1)
    800050c0:	06f04763          	bgtz	a5,8000512e <end_op+0xbc>
    acquire(&log.lock);
    800050c4:	00038497          	auipc	s1,0x38
    800050c8:	a0448493          	addi	s1,s1,-1532 # 8003cac8 <log>
    800050cc:	8526                	mv	a0,s1
    800050ce:	ffffc097          	auipc	ra,0xffffc
    800050d2:	af8080e7          	jalr	-1288(ra) # 80000bc6 <acquire>
    log.committing = 0;
    800050d6:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800050da:	8526                	mv	a0,s1
    800050dc:	ffffd097          	auipc	ra,0xffffd
    800050e0:	594080e7          	jalr	1428(ra) # 80002670 <wakeup>
    release(&log.lock);
    800050e4:	8526                	mv	a0,s1
    800050e6:	ffffc097          	auipc	ra,0xffffc
    800050ea:	baa080e7          	jalr	-1110(ra) # 80000c90 <release>
}
    800050ee:	a03d                	j	8000511c <end_op+0xaa>
    panic("log.committing");
    800050f0:	00003517          	auipc	a0,0x3
    800050f4:	71850513          	addi	a0,a0,1816 # 80008808 <syscalls+0x218>
    800050f8:	ffffb097          	auipc	ra,0xffffb
    800050fc:	436080e7          	jalr	1078(ra) # 8000052e <panic>
    wakeup(&log);
    80005100:	00038497          	auipc	s1,0x38
    80005104:	9c848493          	addi	s1,s1,-1592 # 8003cac8 <log>
    80005108:	8526                	mv	a0,s1
    8000510a:	ffffd097          	auipc	ra,0xffffd
    8000510e:	566080e7          	jalr	1382(ra) # 80002670 <wakeup>
  release(&log.lock);
    80005112:	8526                	mv	a0,s1
    80005114:	ffffc097          	auipc	ra,0xffffc
    80005118:	b7c080e7          	jalr	-1156(ra) # 80000c90 <release>
}
    8000511c:	70e2                	ld	ra,56(sp)
    8000511e:	7442                	ld	s0,48(sp)
    80005120:	74a2                	ld	s1,40(sp)
    80005122:	7902                	ld	s2,32(sp)
    80005124:	69e2                	ld	s3,24(sp)
    80005126:	6a42                	ld	s4,16(sp)
    80005128:	6aa2                	ld	s5,8(sp)
    8000512a:	6121                	addi	sp,sp,64
    8000512c:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000512e:	00038a97          	auipc	s5,0x38
    80005132:	9caa8a93          	addi	s5,s5,-1590 # 8003caf8 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80005136:	00038a17          	auipc	s4,0x38
    8000513a:	992a0a13          	addi	s4,s4,-1646 # 8003cac8 <log>
    8000513e:	018a2583          	lw	a1,24(s4)
    80005142:	012585bb          	addw	a1,a1,s2
    80005146:	2585                	addiw	a1,a1,1
    80005148:	028a2503          	lw	a0,40(s4)
    8000514c:	fffff097          	auipc	ra,0xfffff
    80005150:	cce080e7          	jalr	-818(ra) # 80003e1a <bread>
    80005154:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80005156:	000aa583          	lw	a1,0(s5)
    8000515a:	028a2503          	lw	a0,40(s4)
    8000515e:	fffff097          	auipc	ra,0xfffff
    80005162:	cbc080e7          	jalr	-836(ra) # 80003e1a <bread>
    80005166:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80005168:	40000613          	li	a2,1024
    8000516c:	05850593          	addi	a1,a0,88
    80005170:	05848513          	addi	a0,s1,88
    80005174:	ffffc097          	auipc	ra,0xffffc
    80005178:	bc0080e7          	jalr	-1088(ra) # 80000d34 <memmove>
    bwrite(to);  // write the log
    8000517c:	8526                	mv	a0,s1
    8000517e:	fffff097          	auipc	ra,0xfffff
    80005182:	d8e080e7          	jalr	-626(ra) # 80003f0c <bwrite>
    brelse(from);
    80005186:	854e                	mv	a0,s3
    80005188:	fffff097          	auipc	ra,0xfffff
    8000518c:	dc2080e7          	jalr	-574(ra) # 80003f4a <brelse>
    brelse(to);
    80005190:	8526                	mv	a0,s1
    80005192:	fffff097          	auipc	ra,0xfffff
    80005196:	db8080e7          	jalr	-584(ra) # 80003f4a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000519a:	2905                	addiw	s2,s2,1
    8000519c:	0a91                	addi	s5,s5,4
    8000519e:	02ca2783          	lw	a5,44(s4)
    800051a2:	f8f94ee3          	blt	s2,a5,8000513e <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800051a6:	00000097          	auipc	ra,0x0
    800051aa:	c66080e7          	jalr	-922(ra) # 80004e0c <write_head>
    install_trans(0); // Now install writes to home locations
    800051ae:	4501                	li	a0,0
    800051b0:	00000097          	auipc	ra,0x0
    800051b4:	cd8080e7          	jalr	-808(ra) # 80004e88 <install_trans>
    log.lh.n = 0;
    800051b8:	00038797          	auipc	a5,0x38
    800051bc:	9207ae23          	sw	zero,-1732(a5) # 8003caf4 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800051c0:	00000097          	auipc	ra,0x0
    800051c4:	c4c080e7          	jalr	-948(ra) # 80004e0c <write_head>
    800051c8:	bdf5                	j	800050c4 <end_op+0x52>

00000000800051ca <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800051ca:	1101                	addi	sp,sp,-32
    800051cc:	ec06                	sd	ra,24(sp)
    800051ce:	e822                	sd	s0,16(sp)
    800051d0:	e426                	sd	s1,8(sp)
    800051d2:	e04a                	sd	s2,0(sp)
    800051d4:	1000                	addi	s0,sp,32
    800051d6:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800051d8:	00038917          	auipc	s2,0x38
    800051dc:	8f090913          	addi	s2,s2,-1808 # 8003cac8 <log>
    800051e0:	854a                	mv	a0,s2
    800051e2:	ffffc097          	auipc	ra,0xffffc
    800051e6:	9e4080e7          	jalr	-1564(ra) # 80000bc6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800051ea:	02c92603          	lw	a2,44(s2)
    800051ee:	47f5                	li	a5,29
    800051f0:	06c7c563          	blt	a5,a2,8000525a <log_write+0x90>
    800051f4:	00038797          	auipc	a5,0x38
    800051f8:	8f07a783          	lw	a5,-1808(a5) # 8003cae4 <log+0x1c>
    800051fc:	37fd                	addiw	a5,a5,-1
    800051fe:	04f65e63          	bge	a2,a5,8000525a <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80005202:	00038797          	auipc	a5,0x38
    80005206:	8e67a783          	lw	a5,-1818(a5) # 8003cae8 <log+0x20>
    8000520a:	06f05063          	blez	a5,8000526a <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000520e:	4781                	li	a5,0
    80005210:	06c05563          	blez	a2,8000527a <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80005214:	44cc                	lw	a1,12(s1)
    80005216:	00038717          	auipc	a4,0x38
    8000521a:	8e270713          	addi	a4,a4,-1822 # 8003caf8 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000521e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80005220:	4314                	lw	a3,0(a4)
    80005222:	04b68c63          	beq	a3,a1,8000527a <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80005226:	2785                	addiw	a5,a5,1
    80005228:	0711                	addi	a4,a4,4
    8000522a:	fef61be3          	bne	a2,a5,80005220 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000522e:	0621                	addi	a2,a2,8
    80005230:	060a                	slli	a2,a2,0x2
    80005232:	00038797          	auipc	a5,0x38
    80005236:	89678793          	addi	a5,a5,-1898 # 8003cac8 <log>
    8000523a:	963e                	add	a2,a2,a5
    8000523c:	44dc                	lw	a5,12(s1)
    8000523e:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80005240:	8526                	mv	a0,s1
    80005242:	fffff097          	auipc	ra,0xfffff
    80005246:	da6080e7          	jalr	-602(ra) # 80003fe8 <bpin>
    log.lh.n++;
    8000524a:	00038717          	auipc	a4,0x38
    8000524e:	87e70713          	addi	a4,a4,-1922 # 8003cac8 <log>
    80005252:	575c                	lw	a5,44(a4)
    80005254:	2785                	addiw	a5,a5,1
    80005256:	d75c                	sw	a5,44(a4)
    80005258:	a835                	j	80005294 <log_write+0xca>
    panic("too big a transaction");
    8000525a:	00003517          	auipc	a0,0x3
    8000525e:	5be50513          	addi	a0,a0,1470 # 80008818 <syscalls+0x228>
    80005262:	ffffb097          	auipc	ra,0xffffb
    80005266:	2cc080e7          	jalr	716(ra) # 8000052e <panic>
    panic("log_write outside of trans");
    8000526a:	00003517          	auipc	a0,0x3
    8000526e:	5c650513          	addi	a0,a0,1478 # 80008830 <syscalls+0x240>
    80005272:	ffffb097          	auipc	ra,0xffffb
    80005276:	2bc080e7          	jalr	700(ra) # 8000052e <panic>
  log.lh.block[i] = b->blockno;
    8000527a:	00878713          	addi	a4,a5,8
    8000527e:	00271693          	slli	a3,a4,0x2
    80005282:	00038717          	auipc	a4,0x38
    80005286:	84670713          	addi	a4,a4,-1978 # 8003cac8 <log>
    8000528a:	9736                	add	a4,a4,a3
    8000528c:	44d4                	lw	a3,12(s1)
    8000528e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80005290:	faf608e3          	beq	a2,a5,80005240 <log_write+0x76>
  }
  release(&log.lock);
    80005294:	00038517          	auipc	a0,0x38
    80005298:	83450513          	addi	a0,a0,-1996 # 8003cac8 <log>
    8000529c:	ffffc097          	auipc	ra,0xffffc
    800052a0:	9f4080e7          	jalr	-1548(ra) # 80000c90 <release>
}
    800052a4:	60e2                	ld	ra,24(sp)
    800052a6:	6442                	ld	s0,16(sp)
    800052a8:	64a2                	ld	s1,8(sp)
    800052aa:	6902                	ld	s2,0(sp)
    800052ac:	6105                	addi	sp,sp,32
    800052ae:	8082                	ret

00000000800052b0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800052b0:	1101                	addi	sp,sp,-32
    800052b2:	ec06                	sd	ra,24(sp)
    800052b4:	e822                	sd	s0,16(sp)
    800052b6:	e426                	sd	s1,8(sp)
    800052b8:	e04a                	sd	s2,0(sp)
    800052ba:	1000                	addi	s0,sp,32
    800052bc:	84aa                	mv	s1,a0
    800052be:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800052c0:	00003597          	auipc	a1,0x3
    800052c4:	59058593          	addi	a1,a1,1424 # 80008850 <syscalls+0x260>
    800052c8:	0521                	addi	a0,a0,8
    800052ca:	ffffc097          	auipc	ra,0xffffc
    800052ce:	86c080e7          	jalr	-1940(ra) # 80000b36 <initlock>
  lk->name = name;
    800052d2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800052d6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800052da:	0204a423          	sw	zero,40(s1)
}
    800052de:	60e2                	ld	ra,24(sp)
    800052e0:	6442                	ld	s0,16(sp)
    800052e2:	64a2                	ld	s1,8(sp)
    800052e4:	6902                	ld	s2,0(sp)
    800052e6:	6105                	addi	sp,sp,32
    800052e8:	8082                	ret

00000000800052ea <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800052ea:	1101                	addi	sp,sp,-32
    800052ec:	ec06                	sd	ra,24(sp)
    800052ee:	e822                	sd	s0,16(sp)
    800052f0:	e426                	sd	s1,8(sp)
    800052f2:	e04a                	sd	s2,0(sp)
    800052f4:	1000                	addi	s0,sp,32
    800052f6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800052f8:	00850913          	addi	s2,a0,8
    800052fc:	854a                	mv	a0,s2
    800052fe:	ffffc097          	auipc	ra,0xffffc
    80005302:	8c8080e7          	jalr	-1848(ra) # 80000bc6 <acquire>
  while (lk->locked) {
    80005306:	409c                	lw	a5,0(s1)
    80005308:	cb89                	beqz	a5,8000531a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000530a:	85ca                	mv	a1,s2
    8000530c:	8526                	mv	a0,s1
    8000530e:	ffffd097          	auipc	ra,0xffffd
    80005312:	1d8080e7          	jalr	472(ra) # 800024e6 <sleep>
  while (lk->locked) {
    80005316:	409c                	lw	a5,0(s1)
    80005318:	fbed                	bnez	a5,8000530a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000531a:	4785                	li	a5,1
    8000531c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000531e:	ffffc097          	auipc	ra,0xffffc
    80005322:	782080e7          	jalr	1922(ra) # 80001aa0 <myproc>
    80005326:	515c                	lw	a5,36(a0)
    80005328:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000532a:	854a                	mv	a0,s2
    8000532c:	ffffc097          	auipc	ra,0xffffc
    80005330:	964080e7          	jalr	-1692(ra) # 80000c90 <release>
}
    80005334:	60e2                	ld	ra,24(sp)
    80005336:	6442                	ld	s0,16(sp)
    80005338:	64a2                	ld	s1,8(sp)
    8000533a:	6902                	ld	s2,0(sp)
    8000533c:	6105                	addi	sp,sp,32
    8000533e:	8082                	ret

0000000080005340 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80005340:	1101                	addi	sp,sp,-32
    80005342:	ec06                	sd	ra,24(sp)
    80005344:	e822                	sd	s0,16(sp)
    80005346:	e426                	sd	s1,8(sp)
    80005348:	e04a                	sd	s2,0(sp)
    8000534a:	1000                	addi	s0,sp,32
    8000534c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000534e:	00850913          	addi	s2,a0,8
    80005352:	854a                	mv	a0,s2
    80005354:	ffffc097          	auipc	ra,0xffffc
    80005358:	872080e7          	jalr	-1934(ra) # 80000bc6 <acquire>
  lk->locked = 0;
    8000535c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80005360:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80005364:	8526                	mv	a0,s1
    80005366:	ffffd097          	auipc	ra,0xffffd
    8000536a:	30a080e7          	jalr	778(ra) # 80002670 <wakeup>
  release(&lk->lk);
    8000536e:	854a                	mv	a0,s2
    80005370:	ffffc097          	auipc	ra,0xffffc
    80005374:	920080e7          	jalr	-1760(ra) # 80000c90 <release>
}
    80005378:	60e2                	ld	ra,24(sp)
    8000537a:	6442                	ld	s0,16(sp)
    8000537c:	64a2                	ld	s1,8(sp)
    8000537e:	6902                	ld	s2,0(sp)
    80005380:	6105                	addi	sp,sp,32
    80005382:	8082                	ret

0000000080005384 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80005384:	7179                	addi	sp,sp,-48
    80005386:	f406                	sd	ra,40(sp)
    80005388:	f022                	sd	s0,32(sp)
    8000538a:	ec26                	sd	s1,24(sp)
    8000538c:	e84a                	sd	s2,16(sp)
    8000538e:	e44e                	sd	s3,8(sp)
    80005390:	1800                	addi	s0,sp,48
    80005392:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80005394:	00850913          	addi	s2,a0,8
    80005398:	854a                	mv	a0,s2
    8000539a:	ffffc097          	auipc	ra,0xffffc
    8000539e:	82c080e7          	jalr	-2004(ra) # 80000bc6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800053a2:	409c                	lw	a5,0(s1)
    800053a4:	ef99                	bnez	a5,800053c2 <holdingsleep+0x3e>
    800053a6:	4481                	li	s1,0
  release(&lk->lk);
    800053a8:	854a                	mv	a0,s2
    800053aa:	ffffc097          	auipc	ra,0xffffc
    800053ae:	8e6080e7          	jalr	-1818(ra) # 80000c90 <release>
  return r;
}
    800053b2:	8526                	mv	a0,s1
    800053b4:	70a2                	ld	ra,40(sp)
    800053b6:	7402                	ld	s0,32(sp)
    800053b8:	64e2                	ld	s1,24(sp)
    800053ba:	6942                	ld	s2,16(sp)
    800053bc:	69a2                	ld	s3,8(sp)
    800053be:	6145                	addi	sp,sp,48
    800053c0:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800053c2:	0284a983          	lw	s3,40(s1)
    800053c6:	ffffc097          	auipc	ra,0xffffc
    800053ca:	6da080e7          	jalr	1754(ra) # 80001aa0 <myproc>
    800053ce:	5144                	lw	s1,36(a0)
    800053d0:	413484b3          	sub	s1,s1,s3
    800053d4:	0014b493          	seqz	s1,s1
    800053d8:	bfc1                	j	800053a8 <holdingsleep+0x24>

00000000800053da <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800053da:	1141                	addi	sp,sp,-16
    800053dc:	e406                	sd	ra,8(sp)
    800053de:	e022                	sd	s0,0(sp)
    800053e0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800053e2:	00003597          	auipc	a1,0x3
    800053e6:	47e58593          	addi	a1,a1,1150 # 80008860 <syscalls+0x270>
    800053ea:	00038517          	auipc	a0,0x38
    800053ee:	82650513          	addi	a0,a0,-2010 # 8003cc10 <ftable>
    800053f2:	ffffb097          	auipc	ra,0xffffb
    800053f6:	744080e7          	jalr	1860(ra) # 80000b36 <initlock>
}
    800053fa:	60a2                	ld	ra,8(sp)
    800053fc:	6402                	ld	s0,0(sp)
    800053fe:	0141                	addi	sp,sp,16
    80005400:	8082                	ret

0000000080005402 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80005402:	1101                	addi	sp,sp,-32
    80005404:	ec06                	sd	ra,24(sp)
    80005406:	e822                	sd	s0,16(sp)
    80005408:	e426                	sd	s1,8(sp)
    8000540a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000540c:	00038517          	auipc	a0,0x38
    80005410:	80450513          	addi	a0,a0,-2044 # 8003cc10 <ftable>
    80005414:	ffffb097          	auipc	ra,0xffffb
    80005418:	7b2080e7          	jalr	1970(ra) # 80000bc6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000541c:	00038497          	auipc	s1,0x38
    80005420:	80c48493          	addi	s1,s1,-2036 # 8003cc28 <ftable+0x18>
    80005424:	00038717          	auipc	a4,0x38
    80005428:	7a470713          	addi	a4,a4,1956 # 8003dbc8 <ftable+0xfb8>
    if(f->ref == 0){
    8000542c:	40dc                	lw	a5,4(s1)
    8000542e:	cf99                	beqz	a5,8000544c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80005430:	02848493          	addi	s1,s1,40
    80005434:	fee49ce3          	bne	s1,a4,8000542c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80005438:	00037517          	auipc	a0,0x37
    8000543c:	7d850513          	addi	a0,a0,2008 # 8003cc10 <ftable>
    80005440:	ffffc097          	auipc	ra,0xffffc
    80005444:	850080e7          	jalr	-1968(ra) # 80000c90 <release>
  return 0;
    80005448:	4481                	li	s1,0
    8000544a:	a819                	j	80005460 <filealloc+0x5e>
      f->ref = 1;
    8000544c:	4785                	li	a5,1
    8000544e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80005450:	00037517          	auipc	a0,0x37
    80005454:	7c050513          	addi	a0,a0,1984 # 8003cc10 <ftable>
    80005458:	ffffc097          	auipc	ra,0xffffc
    8000545c:	838080e7          	jalr	-1992(ra) # 80000c90 <release>
}
    80005460:	8526                	mv	a0,s1
    80005462:	60e2                	ld	ra,24(sp)
    80005464:	6442                	ld	s0,16(sp)
    80005466:	64a2                	ld	s1,8(sp)
    80005468:	6105                	addi	sp,sp,32
    8000546a:	8082                	ret

000000008000546c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000546c:	1101                	addi	sp,sp,-32
    8000546e:	ec06                	sd	ra,24(sp)
    80005470:	e822                	sd	s0,16(sp)
    80005472:	e426                	sd	s1,8(sp)
    80005474:	1000                	addi	s0,sp,32
    80005476:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80005478:	00037517          	auipc	a0,0x37
    8000547c:	79850513          	addi	a0,a0,1944 # 8003cc10 <ftable>
    80005480:	ffffb097          	auipc	ra,0xffffb
    80005484:	746080e7          	jalr	1862(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    80005488:	40dc                	lw	a5,4(s1)
    8000548a:	02f05263          	blez	a5,800054ae <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000548e:	2785                	addiw	a5,a5,1
    80005490:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80005492:	00037517          	auipc	a0,0x37
    80005496:	77e50513          	addi	a0,a0,1918 # 8003cc10 <ftable>
    8000549a:	ffffb097          	auipc	ra,0xffffb
    8000549e:	7f6080e7          	jalr	2038(ra) # 80000c90 <release>
  return f;
}
    800054a2:	8526                	mv	a0,s1
    800054a4:	60e2                	ld	ra,24(sp)
    800054a6:	6442                	ld	s0,16(sp)
    800054a8:	64a2                	ld	s1,8(sp)
    800054aa:	6105                	addi	sp,sp,32
    800054ac:	8082                	ret
    panic("filedup");
    800054ae:	00003517          	auipc	a0,0x3
    800054b2:	3ba50513          	addi	a0,a0,954 # 80008868 <syscalls+0x278>
    800054b6:	ffffb097          	auipc	ra,0xffffb
    800054ba:	078080e7          	jalr	120(ra) # 8000052e <panic>

00000000800054be <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800054be:	7139                	addi	sp,sp,-64
    800054c0:	fc06                	sd	ra,56(sp)
    800054c2:	f822                	sd	s0,48(sp)
    800054c4:	f426                	sd	s1,40(sp)
    800054c6:	f04a                	sd	s2,32(sp)
    800054c8:	ec4e                	sd	s3,24(sp)
    800054ca:	e852                	sd	s4,16(sp)
    800054cc:	e456                	sd	s5,8(sp)
    800054ce:	0080                	addi	s0,sp,64
    800054d0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800054d2:	00037517          	auipc	a0,0x37
    800054d6:	73e50513          	addi	a0,a0,1854 # 8003cc10 <ftable>
    800054da:	ffffb097          	auipc	ra,0xffffb
    800054de:	6ec080e7          	jalr	1772(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    800054e2:	40dc                	lw	a5,4(s1)
    800054e4:	06f05163          	blez	a5,80005546 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800054e8:	37fd                	addiw	a5,a5,-1
    800054ea:	0007871b          	sext.w	a4,a5
    800054ee:	c0dc                	sw	a5,4(s1)
    800054f0:	06e04363          	bgtz	a4,80005556 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800054f4:	0004a903          	lw	s2,0(s1)
    800054f8:	0094ca83          	lbu	s5,9(s1)
    800054fc:	0104ba03          	ld	s4,16(s1)
    80005500:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80005504:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80005508:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000550c:	00037517          	auipc	a0,0x37
    80005510:	70450513          	addi	a0,a0,1796 # 8003cc10 <ftable>
    80005514:	ffffb097          	auipc	ra,0xffffb
    80005518:	77c080e7          	jalr	1916(ra) # 80000c90 <release>

  if(ff.type == FD_PIPE){
    8000551c:	4785                	li	a5,1
    8000551e:	04f90d63          	beq	s2,a5,80005578 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80005522:	3979                	addiw	s2,s2,-2
    80005524:	4785                	li	a5,1
    80005526:	0527e063          	bltu	a5,s2,80005566 <fileclose+0xa8>
    begin_op();
    8000552a:	00000097          	auipc	ra,0x0
    8000552e:	ac8080e7          	jalr	-1336(ra) # 80004ff2 <begin_op>
    iput(ff.ip);
    80005532:	854e                	mv	a0,s3
    80005534:	fffff097          	auipc	ra,0xfffff
    80005538:	2a4080e7          	jalr	676(ra) # 800047d8 <iput>
    end_op();
    8000553c:	00000097          	auipc	ra,0x0
    80005540:	b36080e7          	jalr	-1226(ra) # 80005072 <end_op>
    80005544:	a00d                	j	80005566 <fileclose+0xa8>
    panic("fileclose");
    80005546:	00003517          	auipc	a0,0x3
    8000554a:	32a50513          	addi	a0,a0,810 # 80008870 <syscalls+0x280>
    8000554e:	ffffb097          	auipc	ra,0xffffb
    80005552:	fe0080e7          	jalr	-32(ra) # 8000052e <panic>
    release(&ftable.lock);
    80005556:	00037517          	auipc	a0,0x37
    8000555a:	6ba50513          	addi	a0,a0,1722 # 8003cc10 <ftable>
    8000555e:	ffffb097          	auipc	ra,0xffffb
    80005562:	732080e7          	jalr	1842(ra) # 80000c90 <release>
  }
}
    80005566:	70e2                	ld	ra,56(sp)
    80005568:	7442                	ld	s0,48(sp)
    8000556a:	74a2                	ld	s1,40(sp)
    8000556c:	7902                	ld	s2,32(sp)
    8000556e:	69e2                	ld	s3,24(sp)
    80005570:	6a42                	ld	s4,16(sp)
    80005572:	6aa2                	ld	s5,8(sp)
    80005574:	6121                	addi	sp,sp,64
    80005576:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80005578:	85d6                	mv	a1,s5
    8000557a:	8552                	mv	a0,s4
    8000557c:	00000097          	auipc	ra,0x0
    80005580:	34c080e7          	jalr	844(ra) # 800058c8 <pipeclose>
    80005584:	b7cd                	j	80005566 <fileclose+0xa8>

0000000080005586 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80005586:	715d                	addi	sp,sp,-80
    80005588:	e486                	sd	ra,72(sp)
    8000558a:	e0a2                	sd	s0,64(sp)
    8000558c:	fc26                	sd	s1,56(sp)
    8000558e:	f84a                	sd	s2,48(sp)
    80005590:	f44e                	sd	s3,40(sp)
    80005592:	0880                	addi	s0,sp,80
    80005594:	84aa                	mv	s1,a0
    80005596:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80005598:	ffffc097          	auipc	ra,0xffffc
    8000559c:	508080e7          	jalr	1288(ra) # 80001aa0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800055a0:	409c                	lw	a5,0(s1)
    800055a2:	37f9                	addiw	a5,a5,-2
    800055a4:	4705                	li	a4,1
    800055a6:	04f76763          	bltu	a4,a5,800055f4 <filestat+0x6e>
    800055aa:	892a                	mv	s2,a0
    ilock(f->ip);
    800055ac:	6c88                	ld	a0,24(s1)
    800055ae:	fffff097          	auipc	ra,0xfffff
    800055b2:	070080e7          	jalr	112(ra) # 8000461e <ilock>
    stati(f->ip, &st);
    800055b6:	fb840593          	addi	a1,s0,-72
    800055ba:	6c88                	ld	a0,24(s1)
    800055bc:	fffff097          	auipc	ra,0xfffff
    800055c0:	2ec080e7          	jalr	748(ra) # 800048a8 <stati>
    iunlock(f->ip);
    800055c4:	6c88                	ld	a0,24(s1)
    800055c6:	fffff097          	auipc	ra,0xfffff
    800055ca:	11a080e7          	jalr	282(ra) # 800046e0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800055ce:	46e1                	li	a3,24
    800055d0:	fb840613          	addi	a2,s0,-72
    800055d4:	85ce                	mv	a1,s3
    800055d6:	04093503          	ld	a0,64(s2)
    800055da:	ffffc097          	auipc	ra,0xffffc
    800055de:	0ae080e7          	jalr	174(ra) # 80001688 <copyout>
    800055e2:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800055e6:	60a6                	ld	ra,72(sp)
    800055e8:	6406                	ld	s0,64(sp)
    800055ea:	74e2                	ld	s1,56(sp)
    800055ec:	7942                	ld	s2,48(sp)
    800055ee:	79a2                	ld	s3,40(sp)
    800055f0:	6161                	addi	sp,sp,80
    800055f2:	8082                	ret
  return -1;
    800055f4:	557d                	li	a0,-1
    800055f6:	bfc5                	j	800055e6 <filestat+0x60>

00000000800055f8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800055f8:	7179                	addi	sp,sp,-48
    800055fa:	f406                	sd	ra,40(sp)
    800055fc:	f022                	sd	s0,32(sp)
    800055fe:	ec26                	sd	s1,24(sp)
    80005600:	e84a                	sd	s2,16(sp)
    80005602:	e44e                	sd	s3,8(sp)
    80005604:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005606:	00854783          	lbu	a5,8(a0)
    8000560a:	c3d5                	beqz	a5,800056ae <fileread+0xb6>
    8000560c:	84aa                	mv	s1,a0
    8000560e:	89ae                	mv	s3,a1
    80005610:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80005612:	411c                	lw	a5,0(a0)
    80005614:	4705                	li	a4,1
    80005616:	04e78963          	beq	a5,a4,80005668 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000561a:	470d                	li	a4,3
    8000561c:	04e78d63          	beq	a5,a4,80005676 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80005620:	4709                	li	a4,2
    80005622:	06e79e63          	bne	a5,a4,8000569e <fileread+0xa6>
    ilock(f->ip);
    80005626:	6d08                	ld	a0,24(a0)
    80005628:	fffff097          	auipc	ra,0xfffff
    8000562c:	ff6080e7          	jalr	-10(ra) # 8000461e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80005630:	874a                	mv	a4,s2
    80005632:	5094                	lw	a3,32(s1)
    80005634:	864e                	mv	a2,s3
    80005636:	4585                	li	a1,1
    80005638:	6c88                	ld	a0,24(s1)
    8000563a:	fffff097          	auipc	ra,0xfffff
    8000563e:	298080e7          	jalr	664(ra) # 800048d2 <readi>
    80005642:	892a                	mv	s2,a0
    80005644:	00a05563          	blez	a0,8000564e <fileread+0x56>
      f->off += r;
    80005648:	509c                	lw	a5,32(s1)
    8000564a:	9fa9                	addw	a5,a5,a0
    8000564c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000564e:	6c88                	ld	a0,24(s1)
    80005650:	fffff097          	auipc	ra,0xfffff
    80005654:	090080e7          	jalr	144(ra) # 800046e0 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80005658:	854a                	mv	a0,s2
    8000565a:	70a2                	ld	ra,40(sp)
    8000565c:	7402                	ld	s0,32(sp)
    8000565e:	64e2                	ld	s1,24(sp)
    80005660:	6942                	ld	s2,16(sp)
    80005662:	69a2                	ld	s3,8(sp)
    80005664:	6145                	addi	sp,sp,48
    80005666:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005668:	6908                	ld	a0,16(a0)
    8000566a:	00000097          	auipc	ra,0x0
    8000566e:	3c8080e7          	jalr	968(ra) # 80005a32 <piperead>
    80005672:	892a                	mv	s2,a0
    80005674:	b7d5                	j	80005658 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005676:	02451783          	lh	a5,36(a0)
    8000567a:	03079693          	slli	a3,a5,0x30
    8000567e:	92c1                	srli	a3,a3,0x30
    80005680:	4725                	li	a4,9
    80005682:	02d76863          	bltu	a4,a3,800056b2 <fileread+0xba>
    80005686:	0792                	slli	a5,a5,0x4
    80005688:	00037717          	auipc	a4,0x37
    8000568c:	4e870713          	addi	a4,a4,1256 # 8003cb70 <devsw>
    80005690:	97ba                	add	a5,a5,a4
    80005692:	639c                	ld	a5,0(a5)
    80005694:	c38d                	beqz	a5,800056b6 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80005696:	4505                	li	a0,1
    80005698:	9782                	jalr	a5
    8000569a:	892a                	mv	s2,a0
    8000569c:	bf75                	j	80005658 <fileread+0x60>
    panic("fileread");
    8000569e:	00003517          	auipc	a0,0x3
    800056a2:	1e250513          	addi	a0,a0,482 # 80008880 <syscalls+0x290>
    800056a6:	ffffb097          	auipc	ra,0xffffb
    800056aa:	e88080e7          	jalr	-376(ra) # 8000052e <panic>
    return -1;
    800056ae:	597d                	li	s2,-1
    800056b0:	b765                	j	80005658 <fileread+0x60>
      return -1;
    800056b2:	597d                	li	s2,-1
    800056b4:	b755                	j	80005658 <fileread+0x60>
    800056b6:	597d                	li	s2,-1
    800056b8:	b745                	j	80005658 <fileread+0x60>

00000000800056ba <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800056ba:	715d                	addi	sp,sp,-80
    800056bc:	e486                	sd	ra,72(sp)
    800056be:	e0a2                	sd	s0,64(sp)
    800056c0:	fc26                	sd	s1,56(sp)
    800056c2:	f84a                	sd	s2,48(sp)
    800056c4:	f44e                	sd	s3,40(sp)
    800056c6:	f052                	sd	s4,32(sp)
    800056c8:	ec56                	sd	s5,24(sp)
    800056ca:	e85a                	sd	s6,16(sp)
    800056cc:	e45e                	sd	s7,8(sp)
    800056ce:	e062                	sd	s8,0(sp)
    800056d0:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800056d2:	00954783          	lbu	a5,9(a0)
    800056d6:	10078663          	beqz	a5,800057e2 <filewrite+0x128>
    800056da:	892a                	mv	s2,a0
    800056dc:	8aae                	mv	s5,a1
    800056de:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800056e0:	411c                	lw	a5,0(a0)
    800056e2:	4705                	li	a4,1
    800056e4:	02e78263          	beq	a5,a4,80005708 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800056e8:	470d                	li	a4,3
    800056ea:	02e78663          	beq	a5,a4,80005716 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800056ee:	4709                	li	a4,2
    800056f0:	0ee79163          	bne	a5,a4,800057d2 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800056f4:	0ac05d63          	blez	a2,800057ae <filewrite+0xf4>
    int i = 0;
    800056f8:	4981                	li	s3,0
    800056fa:	6b05                	lui	s6,0x1
    800056fc:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80005700:	6b85                	lui	s7,0x1
    80005702:	c00b8b9b          	addiw	s7,s7,-1024
    80005706:	a861                	j	8000579e <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80005708:	6908                	ld	a0,16(a0)
    8000570a:	00000097          	auipc	ra,0x0
    8000570e:	22e080e7          	jalr	558(ra) # 80005938 <pipewrite>
    80005712:	8a2a                	mv	s4,a0
    80005714:	a045                	j	800057b4 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80005716:	02451783          	lh	a5,36(a0)
    8000571a:	03079693          	slli	a3,a5,0x30
    8000571e:	92c1                	srli	a3,a3,0x30
    80005720:	4725                	li	a4,9
    80005722:	0cd76263          	bltu	a4,a3,800057e6 <filewrite+0x12c>
    80005726:	0792                	slli	a5,a5,0x4
    80005728:	00037717          	auipc	a4,0x37
    8000572c:	44870713          	addi	a4,a4,1096 # 8003cb70 <devsw>
    80005730:	97ba                	add	a5,a5,a4
    80005732:	679c                	ld	a5,8(a5)
    80005734:	cbdd                	beqz	a5,800057ea <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80005736:	4505                	li	a0,1
    80005738:	9782                	jalr	a5
    8000573a:	8a2a                	mv	s4,a0
    8000573c:	a8a5                	j	800057b4 <filewrite+0xfa>
    8000573e:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80005742:	00000097          	auipc	ra,0x0
    80005746:	8b0080e7          	jalr	-1872(ra) # 80004ff2 <begin_op>
      ilock(f->ip);
    8000574a:	01893503          	ld	a0,24(s2)
    8000574e:	fffff097          	auipc	ra,0xfffff
    80005752:	ed0080e7          	jalr	-304(ra) # 8000461e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80005756:	8762                	mv	a4,s8
    80005758:	02092683          	lw	a3,32(s2)
    8000575c:	01598633          	add	a2,s3,s5
    80005760:	4585                	li	a1,1
    80005762:	01893503          	ld	a0,24(s2)
    80005766:	fffff097          	auipc	ra,0xfffff
    8000576a:	264080e7          	jalr	612(ra) # 800049ca <writei>
    8000576e:	84aa                	mv	s1,a0
    80005770:	00a05763          	blez	a0,8000577e <filewrite+0xc4>
        f->off += r;
    80005774:	02092783          	lw	a5,32(s2)
    80005778:	9fa9                	addw	a5,a5,a0
    8000577a:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000577e:	01893503          	ld	a0,24(s2)
    80005782:	fffff097          	auipc	ra,0xfffff
    80005786:	f5e080e7          	jalr	-162(ra) # 800046e0 <iunlock>
      end_op();
    8000578a:	00000097          	auipc	ra,0x0
    8000578e:	8e8080e7          	jalr	-1816(ra) # 80005072 <end_op>

      if(r != n1){
    80005792:	009c1f63          	bne	s8,s1,800057b0 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80005796:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000579a:	0149db63          	bge	s3,s4,800057b0 <filewrite+0xf6>
      int n1 = n - i;
    8000579e:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800057a2:	84be                	mv	s1,a5
    800057a4:	2781                	sext.w	a5,a5
    800057a6:	f8fb5ce3          	bge	s6,a5,8000573e <filewrite+0x84>
    800057aa:	84de                	mv	s1,s7
    800057ac:	bf49                	j	8000573e <filewrite+0x84>
    int i = 0;
    800057ae:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800057b0:	013a1f63          	bne	s4,s3,800057ce <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800057b4:	8552                	mv	a0,s4
    800057b6:	60a6                	ld	ra,72(sp)
    800057b8:	6406                	ld	s0,64(sp)
    800057ba:	74e2                	ld	s1,56(sp)
    800057bc:	7942                	ld	s2,48(sp)
    800057be:	79a2                	ld	s3,40(sp)
    800057c0:	7a02                	ld	s4,32(sp)
    800057c2:	6ae2                	ld	s5,24(sp)
    800057c4:	6b42                	ld	s6,16(sp)
    800057c6:	6ba2                	ld	s7,8(sp)
    800057c8:	6c02                	ld	s8,0(sp)
    800057ca:	6161                	addi	sp,sp,80
    800057cc:	8082                	ret
    ret = (i == n ? n : -1);
    800057ce:	5a7d                	li	s4,-1
    800057d0:	b7d5                	j	800057b4 <filewrite+0xfa>
    panic("filewrite");
    800057d2:	00003517          	auipc	a0,0x3
    800057d6:	0be50513          	addi	a0,a0,190 # 80008890 <syscalls+0x2a0>
    800057da:	ffffb097          	auipc	ra,0xffffb
    800057de:	d54080e7          	jalr	-684(ra) # 8000052e <panic>
    return -1;
    800057e2:	5a7d                	li	s4,-1
    800057e4:	bfc1                	j	800057b4 <filewrite+0xfa>
      return -1;
    800057e6:	5a7d                	li	s4,-1
    800057e8:	b7f1                	j	800057b4 <filewrite+0xfa>
    800057ea:	5a7d                	li	s4,-1
    800057ec:	b7e1                	j	800057b4 <filewrite+0xfa>

00000000800057ee <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800057ee:	7179                	addi	sp,sp,-48
    800057f0:	f406                	sd	ra,40(sp)
    800057f2:	f022                	sd	s0,32(sp)
    800057f4:	ec26                	sd	s1,24(sp)
    800057f6:	e84a                	sd	s2,16(sp)
    800057f8:	e44e                	sd	s3,8(sp)
    800057fa:	e052                	sd	s4,0(sp)
    800057fc:	1800                	addi	s0,sp,48
    800057fe:	84aa                	mv	s1,a0
    80005800:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80005802:	0005b023          	sd	zero,0(a1)
    80005806:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000580a:	00000097          	auipc	ra,0x0
    8000580e:	bf8080e7          	jalr	-1032(ra) # 80005402 <filealloc>
    80005812:	e088                	sd	a0,0(s1)
    80005814:	c551                	beqz	a0,800058a0 <pipealloc+0xb2>
    80005816:	00000097          	auipc	ra,0x0
    8000581a:	bec080e7          	jalr	-1044(ra) # 80005402 <filealloc>
    8000581e:	00aa3023          	sd	a0,0(s4)
    80005822:	c92d                	beqz	a0,80005894 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80005824:	ffffb097          	auipc	ra,0xffffb
    80005828:	2b2080e7          	jalr	690(ra) # 80000ad6 <kalloc>
    8000582c:	892a                	mv	s2,a0
    8000582e:	c125                	beqz	a0,8000588e <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005830:	4985                	li	s3,1
    80005832:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80005836:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000583a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000583e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80005842:	00003597          	auipc	a1,0x3
    80005846:	05e58593          	addi	a1,a1,94 # 800088a0 <syscalls+0x2b0>
    8000584a:	ffffb097          	auipc	ra,0xffffb
    8000584e:	2ec080e7          	jalr	748(ra) # 80000b36 <initlock>
  (*f0)->type = FD_PIPE;
    80005852:	609c                	ld	a5,0(s1)
    80005854:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005858:	609c                	ld	a5,0(s1)
    8000585a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000585e:	609c                	ld	a5,0(s1)
    80005860:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005864:	609c                	ld	a5,0(s1)
    80005866:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000586a:	000a3783          	ld	a5,0(s4)
    8000586e:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005872:	000a3783          	ld	a5,0(s4)
    80005876:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000587a:	000a3783          	ld	a5,0(s4)
    8000587e:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005882:	000a3783          	ld	a5,0(s4)
    80005886:	0127b823          	sd	s2,16(a5)
  return 0;
    8000588a:	4501                	li	a0,0
    8000588c:	a025                	j	800058b4 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000588e:	6088                	ld	a0,0(s1)
    80005890:	e501                	bnez	a0,80005898 <pipealloc+0xaa>
    80005892:	a039                	j	800058a0 <pipealloc+0xb2>
    80005894:	6088                	ld	a0,0(s1)
    80005896:	c51d                	beqz	a0,800058c4 <pipealloc+0xd6>
    fileclose(*f0);
    80005898:	00000097          	auipc	ra,0x0
    8000589c:	c26080e7          	jalr	-986(ra) # 800054be <fileclose>
  if(*f1)
    800058a0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800058a4:	557d                	li	a0,-1
  if(*f1)
    800058a6:	c799                	beqz	a5,800058b4 <pipealloc+0xc6>
    fileclose(*f1);
    800058a8:	853e                	mv	a0,a5
    800058aa:	00000097          	auipc	ra,0x0
    800058ae:	c14080e7          	jalr	-1004(ra) # 800054be <fileclose>
  return -1;
    800058b2:	557d                	li	a0,-1
}
    800058b4:	70a2                	ld	ra,40(sp)
    800058b6:	7402                	ld	s0,32(sp)
    800058b8:	64e2                	ld	s1,24(sp)
    800058ba:	6942                	ld	s2,16(sp)
    800058bc:	69a2                	ld	s3,8(sp)
    800058be:	6a02                	ld	s4,0(sp)
    800058c0:	6145                	addi	sp,sp,48
    800058c2:	8082                	ret
  return -1;
    800058c4:	557d                	li	a0,-1
    800058c6:	b7fd                	j	800058b4 <pipealloc+0xc6>

00000000800058c8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800058c8:	1101                	addi	sp,sp,-32
    800058ca:	ec06                	sd	ra,24(sp)
    800058cc:	e822                	sd	s0,16(sp)
    800058ce:	e426                	sd	s1,8(sp)
    800058d0:	e04a                	sd	s2,0(sp)
    800058d2:	1000                	addi	s0,sp,32
    800058d4:	84aa                	mv	s1,a0
    800058d6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800058d8:	ffffb097          	auipc	ra,0xffffb
    800058dc:	2ee080e7          	jalr	750(ra) # 80000bc6 <acquire>
  if(writable){
    800058e0:	02090d63          	beqz	s2,8000591a <pipeclose+0x52>
    pi->writeopen = 0;
    800058e4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800058e8:	21848513          	addi	a0,s1,536
    800058ec:	ffffd097          	auipc	ra,0xffffd
    800058f0:	d84080e7          	jalr	-636(ra) # 80002670 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800058f4:	2204b783          	ld	a5,544(s1)
    800058f8:	eb95                	bnez	a5,8000592c <pipeclose+0x64>
    release(&pi->lock);
    800058fa:	8526                	mv	a0,s1
    800058fc:	ffffb097          	auipc	ra,0xffffb
    80005900:	394080e7          	jalr	916(ra) # 80000c90 <release>
    kfree((char*)pi);
    80005904:	8526                	mv	a0,s1
    80005906:	ffffb097          	auipc	ra,0xffffb
    8000590a:	0d4080e7          	jalr	212(ra) # 800009da <kfree>
  } else
    release(&pi->lock);
}
    8000590e:	60e2                	ld	ra,24(sp)
    80005910:	6442                	ld	s0,16(sp)
    80005912:	64a2                	ld	s1,8(sp)
    80005914:	6902                	ld	s2,0(sp)
    80005916:	6105                	addi	sp,sp,32
    80005918:	8082                	ret
    pi->readopen = 0;
    8000591a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000591e:	21c48513          	addi	a0,s1,540
    80005922:	ffffd097          	auipc	ra,0xffffd
    80005926:	d4e080e7          	jalr	-690(ra) # 80002670 <wakeup>
    8000592a:	b7e9                	j	800058f4 <pipeclose+0x2c>
    release(&pi->lock);
    8000592c:	8526                	mv	a0,s1
    8000592e:	ffffb097          	auipc	ra,0xffffb
    80005932:	362080e7          	jalr	866(ra) # 80000c90 <release>
}
    80005936:	bfe1                	j	8000590e <pipeclose+0x46>

0000000080005938 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005938:	7159                	addi	sp,sp,-112
    8000593a:	f486                	sd	ra,104(sp)
    8000593c:	f0a2                	sd	s0,96(sp)
    8000593e:	eca6                	sd	s1,88(sp)
    80005940:	e8ca                	sd	s2,80(sp)
    80005942:	e4ce                	sd	s3,72(sp)
    80005944:	e0d2                	sd	s4,64(sp)
    80005946:	fc56                	sd	s5,56(sp)
    80005948:	f85a                	sd	s6,48(sp)
    8000594a:	f45e                	sd	s7,40(sp)
    8000594c:	f062                	sd	s8,32(sp)
    8000594e:	ec66                	sd	s9,24(sp)
    80005950:	1880                	addi	s0,sp,112
    80005952:	84aa                	mv	s1,a0
    80005954:	8b2e                	mv	s6,a1
    80005956:	8ab2                	mv	s5,a2
  int i = 0;
  struct proc *pr = myproc();
    80005958:	ffffc097          	auipc	ra,0xffffc
    8000595c:	148080e7          	jalr	328(ra) # 80001aa0 <myproc>
    80005960:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005962:	8526                	mv	a0,s1
    80005964:	ffffb097          	auipc	ra,0xffffb
    80005968:	262080e7          	jalr	610(ra) # 80000bc6 <acquire>
  while(i < n){
    8000596c:	0b505663          	blez	s5,80005a18 <pipewrite+0xe0>
  int i = 0;
    80005970:	4901                	li	s2,0
    if(pi->readopen == 0 || pr->killed==1){
    80005972:	4a05                	li	s4,1
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005974:	5bfd                	li	s7,-1
      wakeup(&pi->nread);
    80005976:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000597a:	21c48c13          	addi	s8,s1,540
    8000597e:	a091                	j	800059c2 <pipewrite+0x8a>
      release(&pi->lock);
    80005980:	8526                	mv	a0,s1
    80005982:	ffffb097          	auipc	ra,0xffffb
    80005986:	30e080e7          	jalr	782(ra) # 80000c90 <release>
      return -1;
    8000598a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000598c:	854a                	mv	a0,s2
    8000598e:	70a6                	ld	ra,104(sp)
    80005990:	7406                	ld	s0,96(sp)
    80005992:	64e6                	ld	s1,88(sp)
    80005994:	6946                	ld	s2,80(sp)
    80005996:	69a6                	ld	s3,72(sp)
    80005998:	6a06                	ld	s4,64(sp)
    8000599a:	7ae2                	ld	s5,56(sp)
    8000599c:	7b42                	ld	s6,48(sp)
    8000599e:	7ba2                	ld	s7,40(sp)
    800059a0:	7c02                	ld	s8,32(sp)
    800059a2:	6ce2                	ld	s9,24(sp)
    800059a4:	6165                	addi	sp,sp,112
    800059a6:	8082                	ret
      wakeup(&pi->nread);
    800059a8:	8566                	mv	a0,s9
    800059aa:	ffffd097          	auipc	ra,0xffffd
    800059ae:	cc6080e7          	jalr	-826(ra) # 80002670 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800059b2:	85a6                	mv	a1,s1
    800059b4:	8562                	mv	a0,s8
    800059b6:	ffffd097          	auipc	ra,0xffffd
    800059ba:	b30080e7          	jalr	-1232(ra) # 800024e6 <sleep>
  while(i < n){
    800059be:	05595e63          	bge	s2,s5,80005a1a <pipewrite+0xe2>
    if(pi->readopen == 0 || pr->killed==1){
    800059c2:	2204a783          	lw	a5,544(s1)
    800059c6:	dfcd                	beqz	a5,80005980 <pipewrite+0x48>
    800059c8:	01c9a783          	lw	a5,28(s3)
    800059cc:	fb478ae3          	beq	a5,s4,80005980 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800059d0:	2184a783          	lw	a5,536(s1)
    800059d4:	21c4a703          	lw	a4,540(s1)
    800059d8:	2007879b          	addiw	a5,a5,512
    800059dc:	fcf706e3          	beq	a4,a5,800059a8 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800059e0:	86d2                	mv	a3,s4
    800059e2:	01690633          	add	a2,s2,s6
    800059e6:	f9f40593          	addi	a1,s0,-97
    800059ea:	0409b503          	ld	a0,64(s3)
    800059ee:	ffffc097          	auipc	ra,0xffffc
    800059f2:	d26080e7          	jalr	-730(ra) # 80001714 <copyin>
    800059f6:	03750263          	beq	a0,s7,80005a1a <pipewrite+0xe2>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800059fa:	21c4a783          	lw	a5,540(s1)
    800059fe:	0017871b          	addiw	a4,a5,1
    80005a02:	20e4ae23          	sw	a4,540(s1)
    80005a06:	1ff7f793          	andi	a5,a5,511
    80005a0a:	97a6                	add	a5,a5,s1
    80005a0c:	f9f44703          	lbu	a4,-97(s0)
    80005a10:	00e78c23          	sb	a4,24(a5)
      i++;
    80005a14:	2905                	addiw	s2,s2,1
    80005a16:	b765                	j	800059be <pipewrite+0x86>
  int i = 0;
    80005a18:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005a1a:	21848513          	addi	a0,s1,536
    80005a1e:	ffffd097          	auipc	ra,0xffffd
    80005a22:	c52080e7          	jalr	-942(ra) # 80002670 <wakeup>
  release(&pi->lock);
    80005a26:	8526                	mv	a0,s1
    80005a28:	ffffb097          	auipc	ra,0xffffb
    80005a2c:	268080e7          	jalr	616(ra) # 80000c90 <release>
  return i;
    80005a30:	bfb1                	j	8000598c <pipewrite+0x54>

0000000080005a32 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005a32:	715d                	addi	sp,sp,-80
    80005a34:	e486                	sd	ra,72(sp)
    80005a36:	e0a2                	sd	s0,64(sp)
    80005a38:	fc26                	sd	s1,56(sp)
    80005a3a:	f84a                	sd	s2,48(sp)
    80005a3c:	f44e                	sd	s3,40(sp)
    80005a3e:	f052                	sd	s4,32(sp)
    80005a40:	ec56                	sd	s5,24(sp)
    80005a42:	e85a                	sd	s6,16(sp)
    80005a44:	0880                	addi	s0,sp,80
    80005a46:	84aa                	mv	s1,a0
    80005a48:	892e                	mv	s2,a1
    80005a4a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005a4c:	ffffc097          	auipc	ra,0xffffc
    80005a50:	054080e7          	jalr	84(ra) # 80001aa0 <myproc>
    80005a54:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80005a56:	8526                	mv	a0,s1
    80005a58:	ffffb097          	auipc	ra,0xffffb
    80005a5c:	16e080e7          	jalr	366(ra) # 80000bc6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005a60:	2184a703          	lw	a4,536(s1)
    80005a64:	21c4a783          	lw	a5,540(s1)
    if(pr->killed==1){
    80005a68:	4985                	li	s3,1
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005a6a:	21848b13          	addi	s6,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005a6e:	02f71563          	bne	a4,a5,80005a98 <piperead+0x66>
    80005a72:	2244a783          	lw	a5,548(s1)
    80005a76:	c38d                	beqz	a5,80005a98 <piperead+0x66>
    if(pr->killed==1){
    80005a78:	01ca2783          	lw	a5,28(s4)
    80005a7c:	09378963          	beq	a5,s3,80005b0e <piperead+0xdc>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005a80:	85a6                	mv	a1,s1
    80005a82:	855a                	mv	a0,s6
    80005a84:	ffffd097          	auipc	ra,0xffffd
    80005a88:	a62080e7          	jalr	-1438(ra) # 800024e6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005a8c:	2184a703          	lw	a4,536(s1)
    80005a90:	21c4a783          	lw	a5,540(s1)
    80005a94:	fcf70fe3          	beq	a4,a5,80005a72 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005a98:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005a9a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005a9c:	05505363          	blez	s5,80005ae2 <piperead+0xb0>
    if(pi->nread == pi->nwrite)
    80005aa0:	2184a783          	lw	a5,536(s1)
    80005aa4:	21c4a703          	lw	a4,540(s1)
    80005aa8:	02f70d63          	beq	a4,a5,80005ae2 <piperead+0xb0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80005aac:	0017871b          	addiw	a4,a5,1
    80005ab0:	20e4ac23          	sw	a4,536(s1)
    80005ab4:	1ff7f793          	andi	a5,a5,511
    80005ab8:	97a6                	add	a5,a5,s1
    80005aba:	0187c783          	lbu	a5,24(a5)
    80005abe:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005ac2:	4685                	li	a3,1
    80005ac4:	fbf40613          	addi	a2,s0,-65
    80005ac8:	85ca                	mv	a1,s2
    80005aca:	040a3503          	ld	a0,64(s4)
    80005ace:	ffffc097          	auipc	ra,0xffffc
    80005ad2:	bba080e7          	jalr	-1094(ra) # 80001688 <copyout>
    80005ad6:	01650663          	beq	a0,s6,80005ae2 <piperead+0xb0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005ada:	2985                	addiw	s3,s3,1
    80005adc:	0905                	addi	s2,s2,1
    80005ade:	fd3a91e3          	bne	s5,s3,80005aa0 <piperead+0x6e>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005ae2:	21c48513          	addi	a0,s1,540
    80005ae6:	ffffd097          	auipc	ra,0xffffd
    80005aea:	b8a080e7          	jalr	-1142(ra) # 80002670 <wakeup>
  release(&pi->lock);
    80005aee:	8526                	mv	a0,s1
    80005af0:	ffffb097          	auipc	ra,0xffffb
    80005af4:	1a0080e7          	jalr	416(ra) # 80000c90 <release>
  return i;
}
    80005af8:	854e                	mv	a0,s3
    80005afa:	60a6                	ld	ra,72(sp)
    80005afc:	6406                	ld	s0,64(sp)
    80005afe:	74e2                	ld	s1,56(sp)
    80005b00:	7942                	ld	s2,48(sp)
    80005b02:	79a2                	ld	s3,40(sp)
    80005b04:	7a02                	ld	s4,32(sp)
    80005b06:	6ae2                	ld	s5,24(sp)
    80005b08:	6b42                	ld	s6,16(sp)
    80005b0a:	6161                	addi	sp,sp,80
    80005b0c:	8082                	ret
      release(&pi->lock);
    80005b0e:	8526                	mv	a0,s1
    80005b10:	ffffb097          	auipc	ra,0xffffb
    80005b14:	180080e7          	jalr	384(ra) # 80000c90 <release>
      return -1;
    80005b18:	59fd                	li	s3,-1
    80005b1a:	bff9                	j	80005af8 <piperead+0xc6>

0000000080005b1c <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80005b1c:	7139                	addi	sp,sp,-64
    80005b1e:	fc06                	sd	ra,56(sp)
    80005b20:	f822                	sd	s0,48(sp)
    80005b22:	f426                	sd	s1,40(sp)
    80005b24:	f04a                	sd	s2,32(sp)
    80005b26:	ec4e                	sd	s3,24(sp)
    80005b28:	e852                	sd	s4,16(sp)
    80005b2a:	e456                	sd	s5,8(sp)
    80005b2c:	e05a                	sd	s6,0(sp)
    80005b2e:	0080                	addi	s0,sp,64
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005b30:	ffffc097          	auipc	ra,0xffffc
    80005b34:	f70080e7          	jalr	-144(ra) # 80001aa0 <myproc>
    80005b38:	89aa                	mv	s3,a0

  struct kthread *t = mykthread();
    80005b3a:	ffffc097          	auipc	ra,0xffffc
    80005b3e:	fa6080e7          	jalr	-90(ra) # 80001ae0 <mykthread>
    80005b42:	84aa                	mv	s1,a0
  struct kthread *nt;


  // Kill all process threads 
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];t++){ 
    80005b44:	28898913          	addi	s2,s3,648
    if(nt!=t && nt->state!=TUNUSED){
      acquire(&nt->lock);
      nt->killed=1;
    80005b48:	4a85                	li	s5,1
      if(nt->state == TSLEEPING){
    80005b4a:	4a09                	li	s4,2
        nt->state = TRUNNABLE;
    80005b4c:	4b0d                	li	s6,3
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];t++){ 
    80005b4e:	a801                	j	80005b5e <exec+0x42>
      }

      release(&nt->lock);  
    80005b50:	854a                	mv	a0,s2
    80005b52:	ffffb097          	auipc	ra,0xffffb
    80005b56:	13e080e7          	jalr	318(ra) # 80000c90 <release>
  for(nt = p->kthreads;nt < &p->kthreads[NTHREAD];t++){ 
    80005b5a:	0b848493          	addi	s1,s1,184
    if(nt!=t && nt->state!=TUNUSED){
    80005b5e:	ff248ee3          	beq	s1,s2,80005b5a <exec+0x3e>
    80005b62:	2a09a783          	lw	a5,672(s3)
    80005b66:	dbf5                	beqz	a5,80005b5a <exec+0x3e>
      acquire(&nt->lock);
    80005b68:	854a                	mv	a0,s2
    80005b6a:	ffffb097          	auipc	ra,0xffffb
    80005b6e:	05c080e7          	jalr	92(ra) # 80000bc6 <acquire>
      nt->killed=1;
    80005b72:	2b59a823          	sw	s5,688(s3)
      if(nt->state == TSLEEPING){
    80005b76:	2a09a783          	lw	a5,672(s3)
    80005b7a:	fd479be3          	bne	a5,s4,80005b50 <exec+0x34>
        nt->state = TRUNNABLE;
    80005b7e:	2b69a023          	sw	s6,672(s3)
    80005b82:	b7f9                	j	80005b50 <exec+0x34>

0000000080005b84 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005b84:	7179                	addi	sp,sp,-48
    80005b86:	f406                	sd	ra,40(sp)
    80005b88:	f022                	sd	s0,32(sp)
    80005b8a:	ec26                	sd	s1,24(sp)
    80005b8c:	e84a                	sd	s2,16(sp)
    80005b8e:	1800                	addi	s0,sp,48
    80005b90:	892e                	mv	s2,a1
    80005b92:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005b94:	fdc40593          	addi	a1,s0,-36
    80005b98:	ffffe097          	auipc	ra,0xffffe
    80005b9c:	d40080e7          	jalr	-704(ra) # 800038d8 <argint>
    80005ba0:	04054063          	bltz	a0,80005be0 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005ba4:	fdc42703          	lw	a4,-36(s0)
    80005ba8:	47bd                	li	a5,15
    80005baa:	02e7ed63          	bltu	a5,a4,80005be4 <argfd+0x60>
    80005bae:	ffffc097          	auipc	ra,0xffffc
    80005bb2:	ef2080e7          	jalr	-270(ra) # 80001aa0 <myproc>
    80005bb6:	fdc42703          	lw	a4,-36(s0)
    80005bba:	00a70793          	addi	a5,a4,10
    80005bbe:	078e                	slli	a5,a5,0x3
    80005bc0:	953e                	add	a0,a0,a5
    80005bc2:	611c                	ld	a5,0(a0)
    80005bc4:	c395                	beqz	a5,80005be8 <argfd+0x64>
    return -1;
  if(pfd)
    80005bc6:	00090463          	beqz	s2,80005bce <argfd+0x4a>
    *pfd = fd;
    80005bca:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005bce:	4501                	li	a0,0
  if(pf)
    80005bd0:	c091                	beqz	s1,80005bd4 <argfd+0x50>
    *pf = f;
    80005bd2:	e09c                	sd	a5,0(s1)
}
    80005bd4:	70a2                	ld	ra,40(sp)
    80005bd6:	7402                	ld	s0,32(sp)
    80005bd8:	64e2                	ld	s1,24(sp)
    80005bda:	6942                	ld	s2,16(sp)
    80005bdc:	6145                	addi	sp,sp,48
    80005bde:	8082                	ret
    return -1;
    80005be0:	557d                	li	a0,-1
    80005be2:	bfcd                	j	80005bd4 <argfd+0x50>
    return -1;
    80005be4:	557d                	li	a0,-1
    80005be6:	b7fd                	j	80005bd4 <argfd+0x50>
    80005be8:	557d                	li	a0,-1
    80005bea:	b7ed                	j	80005bd4 <argfd+0x50>

0000000080005bec <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005bec:	1101                	addi	sp,sp,-32
    80005bee:	ec06                	sd	ra,24(sp)
    80005bf0:	e822                	sd	s0,16(sp)
    80005bf2:	e426                	sd	s1,8(sp)
    80005bf4:	1000                	addi	s0,sp,32
    80005bf6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005bf8:	ffffc097          	auipc	ra,0xffffc
    80005bfc:	ea8080e7          	jalr	-344(ra) # 80001aa0 <myproc>
    80005c00:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005c02:	05050793          	addi	a5,a0,80
    80005c06:	4501                	li	a0,0
    80005c08:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005c0a:	6398                	ld	a4,0(a5)
    80005c0c:	cb19                	beqz	a4,80005c22 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005c0e:	2505                	addiw	a0,a0,1
    80005c10:	07a1                	addi	a5,a5,8
    80005c12:	fed51ce3          	bne	a0,a3,80005c0a <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005c16:	557d                	li	a0,-1
}
    80005c18:	60e2                	ld	ra,24(sp)
    80005c1a:	6442                	ld	s0,16(sp)
    80005c1c:	64a2                	ld	s1,8(sp)
    80005c1e:	6105                	addi	sp,sp,32
    80005c20:	8082                	ret
      p->ofile[fd] = f;
    80005c22:	00a50793          	addi	a5,a0,10
    80005c26:	078e                	slli	a5,a5,0x3
    80005c28:	963e                	add	a2,a2,a5
    80005c2a:	e204                	sd	s1,0(a2)
      return fd;
    80005c2c:	b7f5                	j	80005c18 <fdalloc+0x2c>

0000000080005c2e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005c2e:	715d                	addi	sp,sp,-80
    80005c30:	e486                	sd	ra,72(sp)
    80005c32:	e0a2                	sd	s0,64(sp)
    80005c34:	fc26                	sd	s1,56(sp)
    80005c36:	f84a                	sd	s2,48(sp)
    80005c38:	f44e                	sd	s3,40(sp)
    80005c3a:	f052                	sd	s4,32(sp)
    80005c3c:	ec56                	sd	s5,24(sp)
    80005c3e:	0880                	addi	s0,sp,80
    80005c40:	89ae                	mv	s3,a1
    80005c42:	8ab2                	mv	s5,a2
    80005c44:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005c46:	fb040593          	addi	a1,s0,-80
    80005c4a:	fffff097          	auipc	ra,0xfffff
    80005c4e:	1a6080e7          	jalr	422(ra) # 80004df0 <nameiparent>
    80005c52:	892a                	mv	s2,a0
    80005c54:	12050e63          	beqz	a0,80005d90 <create+0x162>
    return 0;

  ilock(dp);
    80005c58:	fffff097          	auipc	ra,0xfffff
    80005c5c:	9c6080e7          	jalr	-1594(ra) # 8000461e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005c60:	4601                	li	a2,0
    80005c62:	fb040593          	addi	a1,s0,-80
    80005c66:	854a                	mv	a0,s2
    80005c68:	fffff097          	auipc	ra,0xfffff
    80005c6c:	e9a080e7          	jalr	-358(ra) # 80004b02 <dirlookup>
    80005c70:	84aa                	mv	s1,a0
    80005c72:	c921                	beqz	a0,80005cc2 <create+0x94>
    iunlockput(dp);
    80005c74:	854a                	mv	a0,s2
    80005c76:	fffff097          	auipc	ra,0xfffff
    80005c7a:	c0a080e7          	jalr	-1014(ra) # 80004880 <iunlockput>
    ilock(ip);
    80005c7e:	8526                	mv	a0,s1
    80005c80:	fffff097          	auipc	ra,0xfffff
    80005c84:	99e080e7          	jalr	-1634(ra) # 8000461e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005c88:	2981                	sext.w	s3,s3
    80005c8a:	4789                	li	a5,2
    80005c8c:	02f99463          	bne	s3,a5,80005cb4 <create+0x86>
    80005c90:	0444d783          	lhu	a5,68(s1)
    80005c94:	37f9                	addiw	a5,a5,-2
    80005c96:	17c2                	slli	a5,a5,0x30
    80005c98:	93c1                	srli	a5,a5,0x30
    80005c9a:	4705                	li	a4,1
    80005c9c:	00f76c63          	bltu	a4,a5,80005cb4 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005ca0:	8526                	mv	a0,s1
    80005ca2:	60a6                	ld	ra,72(sp)
    80005ca4:	6406                	ld	s0,64(sp)
    80005ca6:	74e2                	ld	s1,56(sp)
    80005ca8:	7942                	ld	s2,48(sp)
    80005caa:	79a2                	ld	s3,40(sp)
    80005cac:	7a02                	ld	s4,32(sp)
    80005cae:	6ae2                	ld	s5,24(sp)
    80005cb0:	6161                	addi	sp,sp,80
    80005cb2:	8082                	ret
    iunlockput(ip);
    80005cb4:	8526                	mv	a0,s1
    80005cb6:	fffff097          	auipc	ra,0xfffff
    80005cba:	bca080e7          	jalr	-1078(ra) # 80004880 <iunlockput>
    return 0;
    80005cbe:	4481                	li	s1,0
    80005cc0:	b7c5                	j	80005ca0 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005cc2:	85ce                	mv	a1,s3
    80005cc4:	00092503          	lw	a0,0(s2)
    80005cc8:	ffffe097          	auipc	ra,0xffffe
    80005ccc:	7be080e7          	jalr	1982(ra) # 80004486 <ialloc>
    80005cd0:	84aa                	mv	s1,a0
    80005cd2:	c521                	beqz	a0,80005d1a <create+0xec>
  ilock(ip);
    80005cd4:	fffff097          	auipc	ra,0xfffff
    80005cd8:	94a080e7          	jalr	-1718(ra) # 8000461e <ilock>
  ip->major = major;
    80005cdc:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005ce0:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005ce4:	4a05                	li	s4,1
    80005ce6:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005cea:	8526                	mv	a0,s1
    80005cec:	fffff097          	auipc	ra,0xfffff
    80005cf0:	868080e7          	jalr	-1944(ra) # 80004554 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005cf4:	2981                	sext.w	s3,s3
    80005cf6:	03498a63          	beq	s3,s4,80005d2a <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005cfa:	40d0                	lw	a2,4(s1)
    80005cfc:	fb040593          	addi	a1,s0,-80
    80005d00:	854a                	mv	a0,s2
    80005d02:	fffff097          	auipc	ra,0xfffff
    80005d06:	00e080e7          	jalr	14(ra) # 80004d10 <dirlink>
    80005d0a:	06054b63          	bltz	a0,80005d80 <create+0x152>
  iunlockput(dp);
    80005d0e:	854a                	mv	a0,s2
    80005d10:	fffff097          	auipc	ra,0xfffff
    80005d14:	b70080e7          	jalr	-1168(ra) # 80004880 <iunlockput>
  return ip;
    80005d18:	b761                	j	80005ca0 <create+0x72>
    panic("create: ialloc");
    80005d1a:	00003517          	auipc	a0,0x3
    80005d1e:	b8e50513          	addi	a0,a0,-1138 # 800088a8 <syscalls+0x2b8>
    80005d22:	ffffb097          	auipc	ra,0xffffb
    80005d26:	80c080e7          	jalr	-2036(ra) # 8000052e <panic>
    dp->nlink++;  // for ".."
    80005d2a:	04a95783          	lhu	a5,74(s2)
    80005d2e:	2785                	addiw	a5,a5,1
    80005d30:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005d34:	854a                	mv	a0,s2
    80005d36:	fffff097          	auipc	ra,0xfffff
    80005d3a:	81e080e7          	jalr	-2018(ra) # 80004554 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005d3e:	40d0                	lw	a2,4(s1)
    80005d40:	00003597          	auipc	a1,0x3
    80005d44:	b7858593          	addi	a1,a1,-1160 # 800088b8 <syscalls+0x2c8>
    80005d48:	8526                	mv	a0,s1
    80005d4a:	fffff097          	auipc	ra,0xfffff
    80005d4e:	fc6080e7          	jalr	-58(ra) # 80004d10 <dirlink>
    80005d52:	00054f63          	bltz	a0,80005d70 <create+0x142>
    80005d56:	00492603          	lw	a2,4(s2)
    80005d5a:	00003597          	auipc	a1,0x3
    80005d5e:	b6658593          	addi	a1,a1,-1178 # 800088c0 <syscalls+0x2d0>
    80005d62:	8526                	mv	a0,s1
    80005d64:	fffff097          	auipc	ra,0xfffff
    80005d68:	fac080e7          	jalr	-84(ra) # 80004d10 <dirlink>
    80005d6c:	f80557e3          	bgez	a0,80005cfa <create+0xcc>
      panic("create dots");
    80005d70:	00003517          	auipc	a0,0x3
    80005d74:	b5850513          	addi	a0,a0,-1192 # 800088c8 <syscalls+0x2d8>
    80005d78:	ffffa097          	auipc	ra,0xffffa
    80005d7c:	7b6080e7          	jalr	1974(ra) # 8000052e <panic>
    panic("create: dirlink");
    80005d80:	00003517          	auipc	a0,0x3
    80005d84:	b5850513          	addi	a0,a0,-1192 # 800088d8 <syscalls+0x2e8>
    80005d88:	ffffa097          	auipc	ra,0xffffa
    80005d8c:	7a6080e7          	jalr	1958(ra) # 8000052e <panic>
    return 0;
    80005d90:	84aa                	mv	s1,a0
    80005d92:	b739                	j	80005ca0 <create+0x72>

0000000080005d94 <sys_dup>:
{
    80005d94:	7179                	addi	sp,sp,-48
    80005d96:	f406                	sd	ra,40(sp)
    80005d98:	f022                	sd	s0,32(sp)
    80005d9a:	ec26                	sd	s1,24(sp)
    80005d9c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005d9e:	fd840613          	addi	a2,s0,-40
    80005da2:	4581                	li	a1,0
    80005da4:	4501                	li	a0,0
    80005da6:	00000097          	auipc	ra,0x0
    80005daa:	dde080e7          	jalr	-546(ra) # 80005b84 <argfd>
    return -1;
    80005dae:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005db0:	02054363          	bltz	a0,80005dd6 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005db4:	fd843503          	ld	a0,-40(s0)
    80005db8:	00000097          	auipc	ra,0x0
    80005dbc:	e34080e7          	jalr	-460(ra) # 80005bec <fdalloc>
    80005dc0:	84aa                	mv	s1,a0
    return -1;
    80005dc2:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005dc4:	00054963          	bltz	a0,80005dd6 <sys_dup+0x42>
  filedup(f);
    80005dc8:	fd843503          	ld	a0,-40(s0)
    80005dcc:	fffff097          	auipc	ra,0xfffff
    80005dd0:	6a0080e7          	jalr	1696(ra) # 8000546c <filedup>
  return fd;
    80005dd4:	87a6                	mv	a5,s1
}
    80005dd6:	853e                	mv	a0,a5
    80005dd8:	70a2                	ld	ra,40(sp)
    80005dda:	7402                	ld	s0,32(sp)
    80005ddc:	64e2                	ld	s1,24(sp)
    80005dde:	6145                	addi	sp,sp,48
    80005de0:	8082                	ret

0000000080005de2 <sys_read>:
{
    80005de2:	7179                	addi	sp,sp,-48
    80005de4:	f406                	sd	ra,40(sp)
    80005de6:	f022                	sd	s0,32(sp)
    80005de8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005dea:	fe840613          	addi	a2,s0,-24
    80005dee:	4581                	li	a1,0
    80005df0:	4501                	li	a0,0
    80005df2:	00000097          	auipc	ra,0x0
    80005df6:	d92080e7          	jalr	-622(ra) # 80005b84 <argfd>
    return -1;
    80005dfa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005dfc:	04054163          	bltz	a0,80005e3e <sys_read+0x5c>
    80005e00:	fe440593          	addi	a1,s0,-28
    80005e04:	4509                	li	a0,2
    80005e06:	ffffe097          	auipc	ra,0xffffe
    80005e0a:	ad2080e7          	jalr	-1326(ra) # 800038d8 <argint>
    return -1;
    80005e0e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005e10:	02054763          	bltz	a0,80005e3e <sys_read+0x5c>
    80005e14:	fd840593          	addi	a1,s0,-40
    80005e18:	4505                	li	a0,1
    80005e1a:	ffffe097          	auipc	ra,0xffffe
    80005e1e:	ae0080e7          	jalr	-1312(ra) # 800038fa <argaddr>
    return -1;
    80005e22:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005e24:	00054d63          	bltz	a0,80005e3e <sys_read+0x5c>
  return fileread(f, p, n);
    80005e28:	fe442603          	lw	a2,-28(s0)
    80005e2c:	fd843583          	ld	a1,-40(s0)
    80005e30:	fe843503          	ld	a0,-24(s0)
    80005e34:	fffff097          	auipc	ra,0xfffff
    80005e38:	7c4080e7          	jalr	1988(ra) # 800055f8 <fileread>
    80005e3c:	87aa                	mv	a5,a0
}
    80005e3e:	853e                	mv	a0,a5
    80005e40:	70a2                	ld	ra,40(sp)
    80005e42:	7402                	ld	s0,32(sp)
    80005e44:	6145                	addi	sp,sp,48
    80005e46:	8082                	ret

0000000080005e48 <sys_write>:
{
    80005e48:	7179                	addi	sp,sp,-48
    80005e4a:	f406                	sd	ra,40(sp)
    80005e4c:	f022                	sd	s0,32(sp)
    80005e4e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005e50:	fe840613          	addi	a2,s0,-24
    80005e54:	4581                	li	a1,0
    80005e56:	4501                	li	a0,0
    80005e58:	00000097          	auipc	ra,0x0
    80005e5c:	d2c080e7          	jalr	-724(ra) # 80005b84 <argfd>
    return -1;
    80005e60:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005e62:	04054163          	bltz	a0,80005ea4 <sys_write+0x5c>
    80005e66:	fe440593          	addi	a1,s0,-28
    80005e6a:	4509                	li	a0,2
    80005e6c:	ffffe097          	auipc	ra,0xffffe
    80005e70:	a6c080e7          	jalr	-1428(ra) # 800038d8 <argint>
    return -1;
    80005e74:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005e76:	02054763          	bltz	a0,80005ea4 <sys_write+0x5c>
    80005e7a:	fd840593          	addi	a1,s0,-40
    80005e7e:	4505                	li	a0,1
    80005e80:	ffffe097          	auipc	ra,0xffffe
    80005e84:	a7a080e7          	jalr	-1414(ra) # 800038fa <argaddr>
    return -1;
    80005e88:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005e8a:	00054d63          	bltz	a0,80005ea4 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005e8e:	fe442603          	lw	a2,-28(s0)
    80005e92:	fd843583          	ld	a1,-40(s0)
    80005e96:	fe843503          	ld	a0,-24(s0)
    80005e9a:	00000097          	auipc	ra,0x0
    80005e9e:	820080e7          	jalr	-2016(ra) # 800056ba <filewrite>
    80005ea2:	87aa                	mv	a5,a0
}
    80005ea4:	853e                	mv	a0,a5
    80005ea6:	70a2                	ld	ra,40(sp)
    80005ea8:	7402                	ld	s0,32(sp)
    80005eaa:	6145                	addi	sp,sp,48
    80005eac:	8082                	ret

0000000080005eae <sys_close>:
{
    80005eae:	1101                	addi	sp,sp,-32
    80005eb0:	ec06                	sd	ra,24(sp)
    80005eb2:	e822                	sd	s0,16(sp)
    80005eb4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005eb6:	fe040613          	addi	a2,s0,-32
    80005eba:	fec40593          	addi	a1,s0,-20
    80005ebe:	4501                	li	a0,0
    80005ec0:	00000097          	auipc	ra,0x0
    80005ec4:	cc4080e7          	jalr	-828(ra) # 80005b84 <argfd>
    return -1;
    80005ec8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005eca:	02054463          	bltz	a0,80005ef2 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005ece:	ffffc097          	auipc	ra,0xffffc
    80005ed2:	bd2080e7          	jalr	-1070(ra) # 80001aa0 <myproc>
    80005ed6:	fec42783          	lw	a5,-20(s0)
    80005eda:	07a9                	addi	a5,a5,10
    80005edc:	078e                	slli	a5,a5,0x3
    80005ede:	97aa                	add	a5,a5,a0
    80005ee0:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005ee4:	fe043503          	ld	a0,-32(s0)
    80005ee8:	fffff097          	auipc	ra,0xfffff
    80005eec:	5d6080e7          	jalr	1494(ra) # 800054be <fileclose>
  return 0;
    80005ef0:	4781                	li	a5,0
}
    80005ef2:	853e                	mv	a0,a5
    80005ef4:	60e2                	ld	ra,24(sp)
    80005ef6:	6442                	ld	s0,16(sp)
    80005ef8:	6105                	addi	sp,sp,32
    80005efa:	8082                	ret

0000000080005efc <sys_fstat>:
{
    80005efc:	1101                	addi	sp,sp,-32
    80005efe:	ec06                	sd	ra,24(sp)
    80005f00:	e822                	sd	s0,16(sp)
    80005f02:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005f04:	fe840613          	addi	a2,s0,-24
    80005f08:	4581                	li	a1,0
    80005f0a:	4501                	li	a0,0
    80005f0c:	00000097          	auipc	ra,0x0
    80005f10:	c78080e7          	jalr	-904(ra) # 80005b84 <argfd>
    return -1;
    80005f14:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005f16:	02054563          	bltz	a0,80005f40 <sys_fstat+0x44>
    80005f1a:	fe040593          	addi	a1,s0,-32
    80005f1e:	4505                	li	a0,1
    80005f20:	ffffe097          	auipc	ra,0xffffe
    80005f24:	9da080e7          	jalr	-1574(ra) # 800038fa <argaddr>
    return -1;
    80005f28:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005f2a:	00054b63          	bltz	a0,80005f40 <sys_fstat+0x44>
  return filestat(f, st);
    80005f2e:	fe043583          	ld	a1,-32(s0)
    80005f32:	fe843503          	ld	a0,-24(s0)
    80005f36:	fffff097          	auipc	ra,0xfffff
    80005f3a:	650080e7          	jalr	1616(ra) # 80005586 <filestat>
    80005f3e:	87aa                	mv	a5,a0
}
    80005f40:	853e                	mv	a0,a5
    80005f42:	60e2                	ld	ra,24(sp)
    80005f44:	6442                	ld	s0,16(sp)
    80005f46:	6105                	addi	sp,sp,32
    80005f48:	8082                	ret

0000000080005f4a <sys_link>:
{
    80005f4a:	7169                	addi	sp,sp,-304
    80005f4c:	f606                	sd	ra,296(sp)
    80005f4e:	f222                	sd	s0,288(sp)
    80005f50:	ee26                	sd	s1,280(sp)
    80005f52:	ea4a                	sd	s2,272(sp)
    80005f54:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005f56:	08000613          	li	a2,128
    80005f5a:	ed040593          	addi	a1,s0,-304
    80005f5e:	4501                	li	a0,0
    80005f60:	ffffe097          	auipc	ra,0xffffe
    80005f64:	9bc080e7          	jalr	-1604(ra) # 8000391c <argstr>
    return -1;
    80005f68:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005f6a:	10054e63          	bltz	a0,80006086 <sys_link+0x13c>
    80005f6e:	08000613          	li	a2,128
    80005f72:	f5040593          	addi	a1,s0,-176
    80005f76:	4505                	li	a0,1
    80005f78:	ffffe097          	auipc	ra,0xffffe
    80005f7c:	9a4080e7          	jalr	-1628(ra) # 8000391c <argstr>
    return -1;
    80005f80:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005f82:	10054263          	bltz	a0,80006086 <sys_link+0x13c>
  begin_op();
    80005f86:	fffff097          	auipc	ra,0xfffff
    80005f8a:	06c080e7          	jalr	108(ra) # 80004ff2 <begin_op>
  if((ip = namei(old)) == 0){
    80005f8e:	ed040513          	addi	a0,s0,-304
    80005f92:	fffff097          	auipc	ra,0xfffff
    80005f96:	e40080e7          	jalr	-448(ra) # 80004dd2 <namei>
    80005f9a:	84aa                	mv	s1,a0
    80005f9c:	c551                	beqz	a0,80006028 <sys_link+0xde>
  ilock(ip);
    80005f9e:	ffffe097          	auipc	ra,0xffffe
    80005fa2:	680080e7          	jalr	1664(ra) # 8000461e <ilock>
  if(ip->type == T_DIR){
    80005fa6:	04449703          	lh	a4,68(s1)
    80005faa:	4785                	li	a5,1
    80005fac:	08f70463          	beq	a4,a5,80006034 <sys_link+0xea>
  ip->nlink++;
    80005fb0:	04a4d783          	lhu	a5,74(s1)
    80005fb4:	2785                	addiw	a5,a5,1
    80005fb6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005fba:	8526                	mv	a0,s1
    80005fbc:	ffffe097          	auipc	ra,0xffffe
    80005fc0:	598080e7          	jalr	1432(ra) # 80004554 <iupdate>
  iunlock(ip);
    80005fc4:	8526                	mv	a0,s1
    80005fc6:	ffffe097          	auipc	ra,0xffffe
    80005fca:	71a080e7          	jalr	1818(ra) # 800046e0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005fce:	fd040593          	addi	a1,s0,-48
    80005fd2:	f5040513          	addi	a0,s0,-176
    80005fd6:	fffff097          	auipc	ra,0xfffff
    80005fda:	e1a080e7          	jalr	-486(ra) # 80004df0 <nameiparent>
    80005fde:	892a                	mv	s2,a0
    80005fe0:	c935                	beqz	a0,80006054 <sys_link+0x10a>
  ilock(dp);
    80005fe2:	ffffe097          	auipc	ra,0xffffe
    80005fe6:	63c080e7          	jalr	1596(ra) # 8000461e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005fea:	00092703          	lw	a4,0(s2)
    80005fee:	409c                	lw	a5,0(s1)
    80005ff0:	04f71d63          	bne	a4,a5,8000604a <sys_link+0x100>
    80005ff4:	40d0                	lw	a2,4(s1)
    80005ff6:	fd040593          	addi	a1,s0,-48
    80005ffa:	854a                	mv	a0,s2
    80005ffc:	fffff097          	auipc	ra,0xfffff
    80006000:	d14080e7          	jalr	-748(ra) # 80004d10 <dirlink>
    80006004:	04054363          	bltz	a0,8000604a <sys_link+0x100>
  iunlockput(dp);
    80006008:	854a                	mv	a0,s2
    8000600a:	fffff097          	auipc	ra,0xfffff
    8000600e:	876080e7          	jalr	-1930(ra) # 80004880 <iunlockput>
  iput(ip);
    80006012:	8526                	mv	a0,s1
    80006014:	ffffe097          	auipc	ra,0xffffe
    80006018:	7c4080e7          	jalr	1988(ra) # 800047d8 <iput>
  end_op();
    8000601c:	fffff097          	auipc	ra,0xfffff
    80006020:	056080e7          	jalr	86(ra) # 80005072 <end_op>
  return 0;
    80006024:	4781                	li	a5,0
    80006026:	a085                	j	80006086 <sys_link+0x13c>
    end_op();
    80006028:	fffff097          	auipc	ra,0xfffff
    8000602c:	04a080e7          	jalr	74(ra) # 80005072 <end_op>
    return -1;
    80006030:	57fd                	li	a5,-1
    80006032:	a891                	j	80006086 <sys_link+0x13c>
    iunlockput(ip);
    80006034:	8526                	mv	a0,s1
    80006036:	fffff097          	auipc	ra,0xfffff
    8000603a:	84a080e7          	jalr	-1974(ra) # 80004880 <iunlockput>
    end_op();
    8000603e:	fffff097          	auipc	ra,0xfffff
    80006042:	034080e7          	jalr	52(ra) # 80005072 <end_op>
    return -1;
    80006046:	57fd                	li	a5,-1
    80006048:	a83d                	j	80006086 <sys_link+0x13c>
    iunlockput(dp);
    8000604a:	854a                	mv	a0,s2
    8000604c:	fffff097          	auipc	ra,0xfffff
    80006050:	834080e7          	jalr	-1996(ra) # 80004880 <iunlockput>
  ilock(ip);
    80006054:	8526                	mv	a0,s1
    80006056:	ffffe097          	auipc	ra,0xffffe
    8000605a:	5c8080e7          	jalr	1480(ra) # 8000461e <ilock>
  ip->nlink--;
    8000605e:	04a4d783          	lhu	a5,74(s1)
    80006062:	37fd                	addiw	a5,a5,-1
    80006064:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80006068:	8526                	mv	a0,s1
    8000606a:	ffffe097          	auipc	ra,0xffffe
    8000606e:	4ea080e7          	jalr	1258(ra) # 80004554 <iupdate>
  iunlockput(ip);
    80006072:	8526                	mv	a0,s1
    80006074:	fffff097          	auipc	ra,0xfffff
    80006078:	80c080e7          	jalr	-2036(ra) # 80004880 <iunlockput>
  end_op();
    8000607c:	fffff097          	auipc	ra,0xfffff
    80006080:	ff6080e7          	jalr	-10(ra) # 80005072 <end_op>
  return -1;
    80006084:	57fd                	li	a5,-1
}
    80006086:	853e                	mv	a0,a5
    80006088:	70b2                	ld	ra,296(sp)
    8000608a:	7412                	ld	s0,288(sp)
    8000608c:	64f2                	ld	s1,280(sp)
    8000608e:	6952                	ld	s2,272(sp)
    80006090:	6155                	addi	sp,sp,304
    80006092:	8082                	ret

0000000080006094 <sys_unlink>:
{
    80006094:	7151                	addi	sp,sp,-240
    80006096:	f586                	sd	ra,232(sp)
    80006098:	f1a2                	sd	s0,224(sp)
    8000609a:	eda6                	sd	s1,216(sp)
    8000609c:	e9ca                	sd	s2,208(sp)
    8000609e:	e5ce                	sd	s3,200(sp)
    800060a0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800060a2:	08000613          	li	a2,128
    800060a6:	f3040593          	addi	a1,s0,-208
    800060aa:	4501                	li	a0,0
    800060ac:	ffffe097          	auipc	ra,0xffffe
    800060b0:	870080e7          	jalr	-1936(ra) # 8000391c <argstr>
    800060b4:	18054163          	bltz	a0,80006236 <sys_unlink+0x1a2>
  begin_op();
    800060b8:	fffff097          	auipc	ra,0xfffff
    800060bc:	f3a080e7          	jalr	-198(ra) # 80004ff2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800060c0:	fb040593          	addi	a1,s0,-80
    800060c4:	f3040513          	addi	a0,s0,-208
    800060c8:	fffff097          	auipc	ra,0xfffff
    800060cc:	d28080e7          	jalr	-728(ra) # 80004df0 <nameiparent>
    800060d0:	84aa                	mv	s1,a0
    800060d2:	c979                	beqz	a0,800061a8 <sys_unlink+0x114>
  ilock(dp);
    800060d4:	ffffe097          	auipc	ra,0xffffe
    800060d8:	54a080e7          	jalr	1354(ra) # 8000461e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800060dc:	00002597          	auipc	a1,0x2
    800060e0:	7dc58593          	addi	a1,a1,2012 # 800088b8 <syscalls+0x2c8>
    800060e4:	fb040513          	addi	a0,s0,-80
    800060e8:	fffff097          	auipc	ra,0xfffff
    800060ec:	a00080e7          	jalr	-1536(ra) # 80004ae8 <namecmp>
    800060f0:	14050a63          	beqz	a0,80006244 <sys_unlink+0x1b0>
    800060f4:	00002597          	auipc	a1,0x2
    800060f8:	7cc58593          	addi	a1,a1,1996 # 800088c0 <syscalls+0x2d0>
    800060fc:	fb040513          	addi	a0,s0,-80
    80006100:	fffff097          	auipc	ra,0xfffff
    80006104:	9e8080e7          	jalr	-1560(ra) # 80004ae8 <namecmp>
    80006108:	12050e63          	beqz	a0,80006244 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000610c:	f2c40613          	addi	a2,s0,-212
    80006110:	fb040593          	addi	a1,s0,-80
    80006114:	8526                	mv	a0,s1
    80006116:	fffff097          	auipc	ra,0xfffff
    8000611a:	9ec080e7          	jalr	-1556(ra) # 80004b02 <dirlookup>
    8000611e:	892a                	mv	s2,a0
    80006120:	12050263          	beqz	a0,80006244 <sys_unlink+0x1b0>
  ilock(ip);
    80006124:	ffffe097          	auipc	ra,0xffffe
    80006128:	4fa080e7          	jalr	1274(ra) # 8000461e <ilock>
  if(ip->nlink < 1)
    8000612c:	04a91783          	lh	a5,74(s2)
    80006130:	08f05263          	blez	a5,800061b4 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80006134:	04491703          	lh	a4,68(s2)
    80006138:	4785                	li	a5,1
    8000613a:	08f70563          	beq	a4,a5,800061c4 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000613e:	4641                	li	a2,16
    80006140:	4581                	li	a1,0
    80006142:	fc040513          	addi	a0,s0,-64
    80006146:	ffffb097          	auipc	ra,0xffffb
    8000614a:	b92080e7          	jalr	-1134(ra) # 80000cd8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000614e:	4741                	li	a4,16
    80006150:	f2c42683          	lw	a3,-212(s0)
    80006154:	fc040613          	addi	a2,s0,-64
    80006158:	4581                	li	a1,0
    8000615a:	8526                	mv	a0,s1
    8000615c:	fffff097          	auipc	ra,0xfffff
    80006160:	86e080e7          	jalr	-1938(ra) # 800049ca <writei>
    80006164:	47c1                	li	a5,16
    80006166:	0af51563          	bne	a0,a5,80006210 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000616a:	04491703          	lh	a4,68(s2)
    8000616e:	4785                	li	a5,1
    80006170:	0af70863          	beq	a4,a5,80006220 <sys_unlink+0x18c>
  iunlockput(dp);
    80006174:	8526                	mv	a0,s1
    80006176:	ffffe097          	auipc	ra,0xffffe
    8000617a:	70a080e7          	jalr	1802(ra) # 80004880 <iunlockput>
  ip->nlink--;
    8000617e:	04a95783          	lhu	a5,74(s2)
    80006182:	37fd                	addiw	a5,a5,-1
    80006184:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80006188:	854a                	mv	a0,s2
    8000618a:	ffffe097          	auipc	ra,0xffffe
    8000618e:	3ca080e7          	jalr	970(ra) # 80004554 <iupdate>
  iunlockput(ip);
    80006192:	854a                	mv	a0,s2
    80006194:	ffffe097          	auipc	ra,0xffffe
    80006198:	6ec080e7          	jalr	1772(ra) # 80004880 <iunlockput>
  end_op();
    8000619c:	fffff097          	auipc	ra,0xfffff
    800061a0:	ed6080e7          	jalr	-298(ra) # 80005072 <end_op>
  return 0;
    800061a4:	4501                	li	a0,0
    800061a6:	a84d                	j	80006258 <sys_unlink+0x1c4>
    end_op();
    800061a8:	fffff097          	auipc	ra,0xfffff
    800061ac:	eca080e7          	jalr	-310(ra) # 80005072 <end_op>
    return -1;
    800061b0:	557d                	li	a0,-1
    800061b2:	a05d                	j	80006258 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800061b4:	00002517          	auipc	a0,0x2
    800061b8:	73450513          	addi	a0,a0,1844 # 800088e8 <syscalls+0x2f8>
    800061bc:	ffffa097          	auipc	ra,0xffffa
    800061c0:	372080e7          	jalr	882(ra) # 8000052e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800061c4:	04c92703          	lw	a4,76(s2)
    800061c8:	02000793          	li	a5,32
    800061cc:	f6e7f9e3          	bgeu	a5,a4,8000613e <sys_unlink+0xaa>
    800061d0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800061d4:	4741                	li	a4,16
    800061d6:	86ce                	mv	a3,s3
    800061d8:	f1840613          	addi	a2,s0,-232
    800061dc:	4581                	li	a1,0
    800061de:	854a                	mv	a0,s2
    800061e0:	ffffe097          	auipc	ra,0xffffe
    800061e4:	6f2080e7          	jalr	1778(ra) # 800048d2 <readi>
    800061e8:	47c1                	li	a5,16
    800061ea:	00f51b63          	bne	a0,a5,80006200 <sys_unlink+0x16c>
    if(de.inum != 0)
    800061ee:	f1845783          	lhu	a5,-232(s0)
    800061f2:	e7a1                	bnez	a5,8000623a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800061f4:	29c1                	addiw	s3,s3,16
    800061f6:	04c92783          	lw	a5,76(s2)
    800061fa:	fcf9ede3          	bltu	s3,a5,800061d4 <sys_unlink+0x140>
    800061fe:	b781                	j	8000613e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80006200:	00002517          	auipc	a0,0x2
    80006204:	70050513          	addi	a0,a0,1792 # 80008900 <syscalls+0x310>
    80006208:	ffffa097          	auipc	ra,0xffffa
    8000620c:	326080e7          	jalr	806(ra) # 8000052e <panic>
    panic("unlink: writei");
    80006210:	00002517          	auipc	a0,0x2
    80006214:	70850513          	addi	a0,a0,1800 # 80008918 <syscalls+0x328>
    80006218:	ffffa097          	auipc	ra,0xffffa
    8000621c:	316080e7          	jalr	790(ra) # 8000052e <panic>
    dp->nlink--;
    80006220:	04a4d783          	lhu	a5,74(s1)
    80006224:	37fd                	addiw	a5,a5,-1
    80006226:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000622a:	8526                	mv	a0,s1
    8000622c:	ffffe097          	auipc	ra,0xffffe
    80006230:	328080e7          	jalr	808(ra) # 80004554 <iupdate>
    80006234:	b781                	j	80006174 <sys_unlink+0xe0>
    return -1;
    80006236:	557d                	li	a0,-1
    80006238:	a005                	j	80006258 <sys_unlink+0x1c4>
    iunlockput(ip);
    8000623a:	854a                	mv	a0,s2
    8000623c:	ffffe097          	auipc	ra,0xffffe
    80006240:	644080e7          	jalr	1604(ra) # 80004880 <iunlockput>
  iunlockput(dp);
    80006244:	8526                	mv	a0,s1
    80006246:	ffffe097          	auipc	ra,0xffffe
    8000624a:	63a080e7          	jalr	1594(ra) # 80004880 <iunlockput>
  end_op();
    8000624e:	fffff097          	auipc	ra,0xfffff
    80006252:	e24080e7          	jalr	-476(ra) # 80005072 <end_op>
  return -1;
    80006256:	557d                	li	a0,-1
}
    80006258:	70ae                	ld	ra,232(sp)
    8000625a:	740e                	ld	s0,224(sp)
    8000625c:	64ee                	ld	s1,216(sp)
    8000625e:	694e                	ld	s2,208(sp)
    80006260:	69ae                	ld	s3,200(sp)
    80006262:	616d                	addi	sp,sp,240
    80006264:	8082                	ret

0000000080006266 <sys_open>:

uint64
sys_open(void)
{
    80006266:	7131                	addi	sp,sp,-192
    80006268:	fd06                	sd	ra,184(sp)
    8000626a:	f922                	sd	s0,176(sp)
    8000626c:	f526                	sd	s1,168(sp)
    8000626e:	f14a                	sd	s2,160(sp)
    80006270:	ed4e                	sd	s3,152(sp)
    80006272:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006274:	08000613          	li	a2,128
    80006278:	f5040593          	addi	a1,s0,-176
    8000627c:	4501                	li	a0,0
    8000627e:	ffffd097          	auipc	ra,0xffffd
    80006282:	69e080e7          	jalr	1694(ra) # 8000391c <argstr>
    return -1;
    80006286:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80006288:	0c054163          	bltz	a0,8000634a <sys_open+0xe4>
    8000628c:	f4c40593          	addi	a1,s0,-180
    80006290:	4505                	li	a0,1
    80006292:	ffffd097          	auipc	ra,0xffffd
    80006296:	646080e7          	jalr	1606(ra) # 800038d8 <argint>
    8000629a:	0a054863          	bltz	a0,8000634a <sys_open+0xe4>

  begin_op();
    8000629e:	fffff097          	auipc	ra,0xfffff
    800062a2:	d54080e7          	jalr	-684(ra) # 80004ff2 <begin_op>

  if(omode & O_CREATE){
    800062a6:	f4c42783          	lw	a5,-180(s0)
    800062aa:	2007f793          	andi	a5,a5,512
    800062ae:	cbdd                	beqz	a5,80006364 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800062b0:	4681                	li	a3,0
    800062b2:	4601                	li	a2,0
    800062b4:	4589                	li	a1,2
    800062b6:	f5040513          	addi	a0,s0,-176
    800062ba:	00000097          	auipc	ra,0x0
    800062be:	974080e7          	jalr	-1676(ra) # 80005c2e <create>
    800062c2:	892a                	mv	s2,a0
    if(ip == 0){
    800062c4:	c959                	beqz	a0,8000635a <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800062c6:	04491703          	lh	a4,68(s2)
    800062ca:	478d                	li	a5,3
    800062cc:	00f71763          	bne	a4,a5,800062da <sys_open+0x74>
    800062d0:	04695703          	lhu	a4,70(s2)
    800062d4:	47a5                	li	a5,9
    800062d6:	0ce7ec63          	bltu	a5,a4,800063ae <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800062da:	fffff097          	auipc	ra,0xfffff
    800062de:	128080e7          	jalr	296(ra) # 80005402 <filealloc>
    800062e2:	89aa                	mv	s3,a0
    800062e4:	10050263          	beqz	a0,800063e8 <sys_open+0x182>
    800062e8:	00000097          	auipc	ra,0x0
    800062ec:	904080e7          	jalr	-1788(ra) # 80005bec <fdalloc>
    800062f0:	84aa                	mv	s1,a0
    800062f2:	0e054663          	bltz	a0,800063de <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800062f6:	04491703          	lh	a4,68(s2)
    800062fa:	478d                	li	a5,3
    800062fc:	0cf70463          	beq	a4,a5,800063c4 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80006300:	4789                	li	a5,2
    80006302:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80006306:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000630a:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000630e:	f4c42783          	lw	a5,-180(s0)
    80006312:	0017c713          	xori	a4,a5,1
    80006316:	8b05                	andi	a4,a4,1
    80006318:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000631c:	0037f713          	andi	a4,a5,3
    80006320:	00e03733          	snez	a4,a4
    80006324:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80006328:	4007f793          	andi	a5,a5,1024
    8000632c:	c791                	beqz	a5,80006338 <sys_open+0xd2>
    8000632e:	04491703          	lh	a4,68(s2)
    80006332:	4789                	li	a5,2
    80006334:	08f70f63          	beq	a4,a5,800063d2 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80006338:	854a                	mv	a0,s2
    8000633a:	ffffe097          	auipc	ra,0xffffe
    8000633e:	3a6080e7          	jalr	934(ra) # 800046e0 <iunlock>
  end_op();
    80006342:	fffff097          	auipc	ra,0xfffff
    80006346:	d30080e7          	jalr	-720(ra) # 80005072 <end_op>

  return fd;
}
    8000634a:	8526                	mv	a0,s1
    8000634c:	70ea                	ld	ra,184(sp)
    8000634e:	744a                	ld	s0,176(sp)
    80006350:	74aa                	ld	s1,168(sp)
    80006352:	790a                	ld	s2,160(sp)
    80006354:	69ea                	ld	s3,152(sp)
    80006356:	6129                	addi	sp,sp,192
    80006358:	8082                	ret
      end_op();
    8000635a:	fffff097          	auipc	ra,0xfffff
    8000635e:	d18080e7          	jalr	-744(ra) # 80005072 <end_op>
      return -1;
    80006362:	b7e5                	j	8000634a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80006364:	f5040513          	addi	a0,s0,-176
    80006368:	fffff097          	auipc	ra,0xfffff
    8000636c:	a6a080e7          	jalr	-1430(ra) # 80004dd2 <namei>
    80006370:	892a                	mv	s2,a0
    80006372:	c905                	beqz	a0,800063a2 <sys_open+0x13c>
    ilock(ip);
    80006374:	ffffe097          	auipc	ra,0xffffe
    80006378:	2aa080e7          	jalr	682(ra) # 8000461e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000637c:	04491703          	lh	a4,68(s2)
    80006380:	4785                	li	a5,1
    80006382:	f4f712e3          	bne	a4,a5,800062c6 <sys_open+0x60>
    80006386:	f4c42783          	lw	a5,-180(s0)
    8000638a:	dba1                	beqz	a5,800062da <sys_open+0x74>
      iunlockput(ip);
    8000638c:	854a                	mv	a0,s2
    8000638e:	ffffe097          	auipc	ra,0xffffe
    80006392:	4f2080e7          	jalr	1266(ra) # 80004880 <iunlockput>
      end_op();
    80006396:	fffff097          	auipc	ra,0xfffff
    8000639a:	cdc080e7          	jalr	-804(ra) # 80005072 <end_op>
      return -1;
    8000639e:	54fd                	li	s1,-1
    800063a0:	b76d                	j	8000634a <sys_open+0xe4>
      end_op();
    800063a2:	fffff097          	auipc	ra,0xfffff
    800063a6:	cd0080e7          	jalr	-816(ra) # 80005072 <end_op>
      return -1;
    800063aa:	54fd                	li	s1,-1
    800063ac:	bf79                	j	8000634a <sys_open+0xe4>
    iunlockput(ip);
    800063ae:	854a                	mv	a0,s2
    800063b0:	ffffe097          	auipc	ra,0xffffe
    800063b4:	4d0080e7          	jalr	1232(ra) # 80004880 <iunlockput>
    end_op();
    800063b8:	fffff097          	auipc	ra,0xfffff
    800063bc:	cba080e7          	jalr	-838(ra) # 80005072 <end_op>
    return -1;
    800063c0:	54fd                	li	s1,-1
    800063c2:	b761                	j	8000634a <sys_open+0xe4>
    f->type = FD_DEVICE;
    800063c4:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800063c8:	04691783          	lh	a5,70(s2)
    800063cc:	02f99223          	sh	a5,36(s3)
    800063d0:	bf2d                	j	8000630a <sys_open+0xa4>
    itrunc(ip);
    800063d2:	854a                	mv	a0,s2
    800063d4:	ffffe097          	auipc	ra,0xffffe
    800063d8:	358080e7          	jalr	856(ra) # 8000472c <itrunc>
    800063dc:	bfb1                	j	80006338 <sys_open+0xd2>
      fileclose(f);
    800063de:	854e                	mv	a0,s3
    800063e0:	fffff097          	auipc	ra,0xfffff
    800063e4:	0de080e7          	jalr	222(ra) # 800054be <fileclose>
    iunlockput(ip);
    800063e8:	854a                	mv	a0,s2
    800063ea:	ffffe097          	auipc	ra,0xffffe
    800063ee:	496080e7          	jalr	1174(ra) # 80004880 <iunlockput>
    end_op();
    800063f2:	fffff097          	auipc	ra,0xfffff
    800063f6:	c80080e7          	jalr	-896(ra) # 80005072 <end_op>
    return -1;
    800063fa:	54fd                	li	s1,-1
    800063fc:	b7b9                	j	8000634a <sys_open+0xe4>

00000000800063fe <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800063fe:	7175                	addi	sp,sp,-144
    80006400:	e506                	sd	ra,136(sp)
    80006402:	e122                	sd	s0,128(sp)
    80006404:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006406:	fffff097          	auipc	ra,0xfffff
    8000640a:	bec080e7          	jalr	-1044(ra) # 80004ff2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000640e:	08000613          	li	a2,128
    80006412:	f7040593          	addi	a1,s0,-144
    80006416:	4501                	li	a0,0
    80006418:	ffffd097          	auipc	ra,0xffffd
    8000641c:	504080e7          	jalr	1284(ra) # 8000391c <argstr>
    80006420:	02054963          	bltz	a0,80006452 <sys_mkdir+0x54>
    80006424:	4681                	li	a3,0
    80006426:	4601                	li	a2,0
    80006428:	4585                	li	a1,1
    8000642a:	f7040513          	addi	a0,s0,-144
    8000642e:	00000097          	auipc	ra,0x0
    80006432:	800080e7          	jalr	-2048(ra) # 80005c2e <create>
    80006436:	cd11                	beqz	a0,80006452 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80006438:	ffffe097          	auipc	ra,0xffffe
    8000643c:	448080e7          	jalr	1096(ra) # 80004880 <iunlockput>
  end_op();
    80006440:	fffff097          	auipc	ra,0xfffff
    80006444:	c32080e7          	jalr	-974(ra) # 80005072 <end_op>
  return 0;
    80006448:	4501                	li	a0,0
}
    8000644a:	60aa                	ld	ra,136(sp)
    8000644c:	640a                	ld	s0,128(sp)
    8000644e:	6149                	addi	sp,sp,144
    80006450:	8082                	ret
    end_op();
    80006452:	fffff097          	auipc	ra,0xfffff
    80006456:	c20080e7          	jalr	-992(ra) # 80005072 <end_op>
    return -1;
    8000645a:	557d                	li	a0,-1
    8000645c:	b7fd                	j	8000644a <sys_mkdir+0x4c>

000000008000645e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000645e:	7135                	addi	sp,sp,-160
    80006460:	ed06                	sd	ra,152(sp)
    80006462:	e922                	sd	s0,144(sp)
    80006464:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80006466:	fffff097          	auipc	ra,0xfffff
    8000646a:	b8c080e7          	jalr	-1140(ra) # 80004ff2 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000646e:	08000613          	li	a2,128
    80006472:	f7040593          	addi	a1,s0,-144
    80006476:	4501                	li	a0,0
    80006478:	ffffd097          	auipc	ra,0xffffd
    8000647c:	4a4080e7          	jalr	1188(ra) # 8000391c <argstr>
    80006480:	04054a63          	bltz	a0,800064d4 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80006484:	f6c40593          	addi	a1,s0,-148
    80006488:	4505                	li	a0,1
    8000648a:	ffffd097          	auipc	ra,0xffffd
    8000648e:	44e080e7          	jalr	1102(ra) # 800038d8 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006492:	04054163          	bltz	a0,800064d4 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80006496:	f6840593          	addi	a1,s0,-152
    8000649a:	4509                	li	a0,2
    8000649c:	ffffd097          	auipc	ra,0xffffd
    800064a0:	43c080e7          	jalr	1084(ra) # 800038d8 <argint>
     argint(1, &major) < 0 ||
    800064a4:	02054863          	bltz	a0,800064d4 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800064a8:	f6841683          	lh	a3,-152(s0)
    800064ac:	f6c41603          	lh	a2,-148(s0)
    800064b0:	458d                	li	a1,3
    800064b2:	f7040513          	addi	a0,s0,-144
    800064b6:	fffff097          	auipc	ra,0xfffff
    800064ba:	778080e7          	jalr	1912(ra) # 80005c2e <create>
     argint(2, &minor) < 0 ||
    800064be:	c919                	beqz	a0,800064d4 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800064c0:	ffffe097          	auipc	ra,0xffffe
    800064c4:	3c0080e7          	jalr	960(ra) # 80004880 <iunlockput>
  end_op();
    800064c8:	fffff097          	auipc	ra,0xfffff
    800064cc:	baa080e7          	jalr	-1110(ra) # 80005072 <end_op>
  return 0;
    800064d0:	4501                	li	a0,0
    800064d2:	a031                	j	800064de <sys_mknod+0x80>
    end_op();
    800064d4:	fffff097          	auipc	ra,0xfffff
    800064d8:	b9e080e7          	jalr	-1122(ra) # 80005072 <end_op>
    return -1;
    800064dc:	557d                	li	a0,-1
}
    800064de:	60ea                	ld	ra,152(sp)
    800064e0:	644a                	ld	s0,144(sp)
    800064e2:	610d                	addi	sp,sp,160
    800064e4:	8082                	ret

00000000800064e6 <sys_chdir>:

uint64
sys_chdir(void)
{
    800064e6:	7135                	addi	sp,sp,-160
    800064e8:	ed06                	sd	ra,152(sp)
    800064ea:	e922                	sd	s0,144(sp)
    800064ec:	e526                	sd	s1,136(sp)
    800064ee:	e14a                	sd	s2,128(sp)
    800064f0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800064f2:	ffffb097          	auipc	ra,0xffffb
    800064f6:	5ae080e7          	jalr	1454(ra) # 80001aa0 <myproc>
    800064fa:	892a                	mv	s2,a0
  
  begin_op();
    800064fc:	fffff097          	auipc	ra,0xfffff
    80006500:	af6080e7          	jalr	-1290(ra) # 80004ff2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006504:	08000613          	li	a2,128
    80006508:	f6040593          	addi	a1,s0,-160
    8000650c:	4501                	li	a0,0
    8000650e:	ffffd097          	auipc	ra,0xffffd
    80006512:	40e080e7          	jalr	1038(ra) # 8000391c <argstr>
    80006516:	04054b63          	bltz	a0,8000656c <sys_chdir+0x86>
    8000651a:	f6040513          	addi	a0,s0,-160
    8000651e:	fffff097          	auipc	ra,0xfffff
    80006522:	8b4080e7          	jalr	-1868(ra) # 80004dd2 <namei>
    80006526:	84aa                	mv	s1,a0
    80006528:	c131                	beqz	a0,8000656c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    8000652a:	ffffe097          	auipc	ra,0xffffe
    8000652e:	0f4080e7          	jalr	244(ra) # 8000461e <ilock>
  if(ip->type != T_DIR){
    80006532:	04449703          	lh	a4,68(s1)
    80006536:	4785                	li	a5,1
    80006538:	04f71063          	bne	a4,a5,80006578 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000653c:	8526                	mv	a0,s1
    8000653e:	ffffe097          	auipc	ra,0xffffe
    80006542:	1a2080e7          	jalr	418(ra) # 800046e0 <iunlock>
  iput(p->cwd);
    80006546:	0d093503          	ld	a0,208(s2)
    8000654a:	ffffe097          	auipc	ra,0xffffe
    8000654e:	28e080e7          	jalr	654(ra) # 800047d8 <iput>
  end_op();
    80006552:	fffff097          	auipc	ra,0xfffff
    80006556:	b20080e7          	jalr	-1248(ra) # 80005072 <end_op>
  p->cwd = ip;
    8000655a:	0c993823          	sd	s1,208(s2)
  return 0;
    8000655e:	4501                	li	a0,0
}
    80006560:	60ea                	ld	ra,152(sp)
    80006562:	644a                	ld	s0,144(sp)
    80006564:	64aa                	ld	s1,136(sp)
    80006566:	690a                	ld	s2,128(sp)
    80006568:	610d                	addi	sp,sp,160
    8000656a:	8082                	ret
    end_op();
    8000656c:	fffff097          	auipc	ra,0xfffff
    80006570:	b06080e7          	jalr	-1274(ra) # 80005072 <end_op>
    return -1;
    80006574:	557d                	li	a0,-1
    80006576:	b7ed                	j	80006560 <sys_chdir+0x7a>
    iunlockput(ip);
    80006578:	8526                	mv	a0,s1
    8000657a:	ffffe097          	auipc	ra,0xffffe
    8000657e:	306080e7          	jalr	774(ra) # 80004880 <iunlockput>
    end_op();
    80006582:	fffff097          	auipc	ra,0xfffff
    80006586:	af0080e7          	jalr	-1296(ra) # 80005072 <end_op>
    return -1;
    8000658a:	557d                	li	a0,-1
    8000658c:	bfd1                	j	80006560 <sys_chdir+0x7a>

000000008000658e <sys_exec>:

uint64
sys_exec(void)
{
    8000658e:	7145                	addi	sp,sp,-464
    80006590:	e786                	sd	ra,456(sp)
    80006592:	e3a2                	sd	s0,448(sp)
    80006594:	ff26                	sd	s1,440(sp)
    80006596:	fb4a                	sd	s2,432(sp)
    80006598:	f74e                	sd	s3,424(sp)
    8000659a:	f352                	sd	s4,416(sp)
    8000659c:	ef56                	sd	s5,408(sp)
    8000659e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800065a0:	08000613          	li	a2,128
    800065a4:	f4040593          	addi	a1,s0,-192
    800065a8:	4501                	li	a0,0
    800065aa:	ffffd097          	auipc	ra,0xffffd
    800065ae:	372080e7          	jalr	882(ra) # 8000391c <argstr>
    return -1;
    800065b2:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    800065b4:	0c054a63          	bltz	a0,80006688 <sys_exec+0xfa>
    800065b8:	e3840593          	addi	a1,s0,-456
    800065bc:	4505                	li	a0,1
    800065be:	ffffd097          	auipc	ra,0xffffd
    800065c2:	33c080e7          	jalr	828(ra) # 800038fa <argaddr>
    800065c6:	0c054163          	bltz	a0,80006688 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    800065ca:	10000613          	li	a2,256
    800065ce:	4581                	li	a1,0
    800065d0:	e4040513          	addi	a0,s0,-448
    800065d4:	ffffa097          	auipc	ra,0xffffa
    800065d8:	704080e7          	jalr	1796(ra) # 80000cd8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800065dc:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800065e0:	89a6                	mv	s3,s1
    800065e2:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800065e4:	02000a13          	li	s4,32
    800065e8:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800065ec:	00391793          	slli	a5,s2,0x3
    800065f0:	e3040593          	addi	a1,s0,-464
    800065f4:	e3843503          	ld	a0,-456(s0)
    800065f8:	953e                	add	a0,a0,a5
    800065fa:	ffffd097          	auipc	ra,0xffffd
    800065fe:	244080e7          	jalr	580(ra) # 8000383e <fetchaddr>
    80006602:	02054a63          	bltz	a0,80006636 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80006606:	e3043783          	ld	a5,-464(s0)
    8000660a:	c3b9                	beqz	a5,80006650 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000660c:	ffffa097          	auipc	ra,0xffffa
    80006610:	4ca080e7          	jalr	1226(ra) # 80000ad6 <kalloc>
    80006614:	85aa                	mv	a1,a0
    80006616:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000661a:	cd11                	beqz	a0,80006636 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000661c:	6605                	lui	a2,0x1
    8000661e:	e3043503          	ld	a0,-464(s0)
    80006622:	ffffd097          	auipc	ra,0xffffd
    80006626:	26e080e7          	jalr	622(ra) # 80003890 <fetchstr>
    8000662a:	00054663          	bltz	a0,80006636 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    8000662e:	0905                	addi	s2,s2,1
    80006630:	09a1                	addi	s3,s3,8
    80006632:	fb491be3          	bne	s2,s4,800065e8 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006636:	10048913          	addi	s2,s1,256
    8000663a:	6088                	ld	a0,0(s1)
    8000663c:	c529                	beqz	a0,80006686 <sys_exec+0xf8>
    kfree(argv[i]);
    8000663e:	ffffa097          	auipc	ra,0xffffa
    80006642:	39c080e7          	jalr	924(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006646:	04a1                	addi	s1,s1,8
    80006648:	ff2499e3          	bne	s1,s2,8000663a <sys_exec+0xac>
  return -1;
    8000664c:	597d                	li	s2,-1
    8000664e:	a82d                	j	80006688 <sys_exec+0xfa>
      argv[i] = 0;
    80006650:	0a8e                	slli	s5,s5,0x3
    80006652:	fc040793          	addi	a5,s0,-64
    80006656:	9abe                	add	s5,s5,a5
    80006658:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    8000665c:	e4040593          	addi	a1,s0,-448
    80006660:	f4040513          	addi	a0,s0,-192
    80006664:	fffff097          	auipc	ra,0xfffff
    80006668:	4b8080e7          	jalr	1208(ra) # 80005b1c <exec>
    8000666c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000666e:	10048993          	addi	s3,s1,256
    80006672:	6088                	ld	a0,0(s1)
    80006674:	c911                	beqz	a0,80006688 <sys_exec+0xfa>
    kfree(argv[i]);
    80006676:	ffffa097          	auipc	ra,0xffffa
    8000667a:	364080e7          	jalr	868(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000667e:	04a1                	addi	s1,s1,8
    80006680:	ff3499e3          	bne	s1,s3,80006672 <sys_exec+0xe4>
    80006684:	a011                	j	80006688 <sys_exec+0xfa>
  return -1;
    80006686:	597d                	li	s2,-1
}
    80006688:	854a                	mv	a0,s2
    8000668a:	60be                	ld	ra,456(sp)
    8000668c:	641e                	ld	s0,448(sp)
    8000668e:	74fa                	ld	s1,440(sp)
    80006690:	795a                	ld	s2,432(sp)
    80006692:	79ba                	ld	s3,424(sp)
    80006694:	7a1a                	ld	s4,416(sp)
    80006696:	6afa                	ld	s5,408(sp)
    80006698:	6179                	addi	sp,sp,464
    8000669a:	8082                	ret

000000008000669c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000669c:	7139                	addi	sp,sp,-64
    8000669e:	fc06                	sd	ra,56(sp)
    800066a0:	f822                	sd	s0,48(sp)
    800066a2:	f426                	sd	s1,40(sp)
    800066a4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800066a6:	ffffb097          	auipc	ra,0xffffb
    800066aa:	3fa080e7          	jalr	1018(ra) # 80001aa0 <myproc>
    800066ae:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    800066b0:	fd840593          	addi	a1,s0,-40
    800066b4:	4501                	li	a0,0
    800066b6:	ffffd097          	auipc	ra,0xffffd
    800066ba:	244080e7          	jalr	580(ra) # 800038fa <argaddr>
    return -1;
    800066be:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    800066c0:	0e054063          	bltz	a0,800067a0 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    800066c4:	fc840593          	addi	a1,s0,-56
    800066c8:	fd040513          	addi	a0,s0,-48
    800066cc:	fffff097          	auipc	ra,0xfffff
    800066d0:	122080e7          	jalr	290(ra) # 800057ee <pipealloc>
    return -1;
    800066d4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800066d6:	0c054563          	bltz	a0,800067a0 <sys_pipe+0x104>
  fd0 = -1;
    800066da:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800066de:	fd043503          	ld	a0,-48(s0)
    800066e2:	fffff097          	auipc	ra,0xfffff
    800066e6:	50a080e7          	jalr	1290(ra) # 80005bec <fdalloc>
    800066ea:	fca42223          	sw	a0,-60(s0)
    800066ee:	08054c63          	bltz	a0,80006786 <sys_pipe+0xea>
    800066f2:	fc843503          	ld	a0,-56(s0)
    800066f6:	fffff097          	auipc	ra,0xfffff
    800066fa:	4f6080e7          	jalr	1270(ra) # 80005bec <fdalloc>
    800066fe:	fca42023          	sw	a0,-64(s0)
    80006702:	06054863          	bltz	a0,80006772 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006706:	4691                	li	a3,4
    80006708:	fc440613          	addi	a2,s0,-60
    8000670c:	fd843583          	ld	a1,-40(s0)
    80006710:	60a8                	ld	a0,64(s1)
    80006712:	ffffb097          	auipc	ra,0xffffb
    80006716:	f76080e7          	jalr	-138(ra) # 80001688 <copyout>
    8000671a:	02054063          	bltz	a0,8000673a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000671e:	4691                	li	a3,4
    80006720:	fc040613          	addi	a2,s0,-64
    80006724:	fd843583          	ld	a1,-40(s0)
    80006728:	0591                	addi	a1,a1,4
    8000672a:	60a8                	ld	a0,64(s1)
    8000672c:	ffffb097          	auipc	ra,0xffffb
    80006730:	f5c080e7          	jalr	-164(ra) # 80001688 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80006734:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80006736:	06055563          	bgez	a0,800067a0 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    8000673a:	fc442783          	lw	a5,-60(s0)
    8000673e:	07a9                	addi	a5,a5,10
    80006740:	078e                	slli	a5,a5,0x3
    80006742:	97a6                	add	a5,a5,s1
    80006744:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80006748:	fc042503          	lw	a0,-64(s0)
    8000674c:	0529                	addi	a0,a0,10
    8000674e:	050e                	slli	a0,a0,0x3
    80006750:	9526                	add	a0,a0,s1
    80006752:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006756:	fd043503          	ld	a0,-48(s0)
    8000675a:	fffff097          	auipc	ra,0xfffff
    8000675e:	d64080e7          	jalr	-668(ra) # 800054be <fileclose>
    fileclose(wf);
    80006762:	fc843503          	ld	a0,-56(s0)
    80006766:	fffff097          	auipc	ra,0xfffff
    8000676a:	d58080e7          	jalr	-680(ra) # 800054be <fileclose>
    return -1;
    8000676e:	57fd                	li	a5,-1
    80006770:	a805                	j	800067a0 <sys_pipe+0x104>
    if(fd0 >= 0)
    80006772:	fc442783          	lw	a5,-60(s0)
    80006776:	0007c863          	bltz	a5,80006786 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    8000677a:	00a78513          	addi	a0,a5,10
    8000677e:	050e                	slli	a0,a0,0x3
    80006780:	9526                	add	a0,a0,s1
    80006782:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80006786:	fd043503          	ld	a0,-48(s0)
    8000678a:	fffff097          	auipc	ra,0xfffff
    8000678e:	d34080e7          	jalr	-716(ra) # 800054be <fileclose>
    fileclose(wf);
    80006792:	fc843503          	ld	a0,-56(s0)
    80006796:	fffff097          	auipc	ra,0xfffff
    8000679a:	d28080e7          	jalr	-728(ra) # 800054be <fileclose>
    return -1;
    8000679e:	57fd                	li	a5,-1
}
    800067a0:	853e                	mv	a0,a5
    800067a2:	70e2                	ld	ra,56(sp)
    800067a4:	7442                	ld	s0,48(sp)
    800067a6:	74a2                	ld	s1,40(sp)
    800067a8:	6121                	addi	sp,sp,64
    800067aa:	8082                	ret
    800067ac:	0000                	unimp
	...

00000000800067b0 <kernelvec>:
    800067b0:	7111                	addi	sp,sp,-256
    800067b2:	e006                	sd	ra,0(sp)
    800067b4:	e40a                	sd	sp,8(sp)
    800067b6:	e80e                	sd	gp,16(sp)
    800067b8:	ec12                	sd	tp,24(sp)
    800067ba:	f016                	sd	t0,32(sp)
    800067bc:	f41a                	sd	t1,40(sp)
    800067be:	f81e                	sd	t2,48(sp)
    800067c0:	fc22                	sd	s0,56(sp)
    800067c2:	e0a6                	sd	s1,64(sp)
    800067c4:	e4aa                	sd	a0,72(sp)
    800067c6:	e8ae                	sd	a1,80(sp)
    800067c8:	ecb2                	sd	a2,88(sp)
    800067ca:	f0b6                	sd	a3,96(sp)
    800067cc:	f4ba                	sd	a4,104(sp)
    800067ce:	f8be                	sd	a5,112(sp)
    800067d0:	fcc2                	sd	a6,120(sp)
    800067d2:	e146                	sd	a7,128(sp)
    800067d4:	e54a                	sd	s2,136(sp)
    800067d6:	e94e                	sd	s3,144(sp)
    800067d8:	ed52                	sd	s4,152(sp)
    800067da:	f156                	sd	s5,160(sp)
    800067dc:	f55a                	sd	s6,168(sp)
    800067de:	f95e                	sd	s7,176(sp)
    800067e0:	fd62                	sd	s8,184(sp)
    800067e2:	e1e6                	sd	s9,192(sp)
    800067e4:	e5ea                	sd	s10,200(sp)
    800067e6:	e9ee                	sd	s11,208(sp)
    800067e8:	edf2                	sd	t3,216(sp)
    800067ea:	f1f6                	sd	t4,224(sp)
    800067ec:	f5fa                	sd	t5,232(sp)
    800067ee:	f9fe                	sd	t6,240(sp)
    800067f0:	f09fc0ef          	jal	ra,800036f8 <kerneltrap>
    800067f4:	6082                	ld	ra,0(sp)
    800067f6:	6122                	ld	sp,8(sp)
    800067f8:	61c2                	ld	gp,16(sp)
    800067fa:	7282                	ld	t0,32(sp)
    800067fc:	7322                	ld	t1,40(sp)
    800067fe:	73c2                	ld	t2,48(sp)
    80006800:	7462                	ld	s0,56(sp)
    80006802:	6486                	ld	s1,64(sp)
    80006804:	6526                	ld	a0,72(sp)
    80006806:	65c6                	ld	a1,80(sp)
    80006808:	6666                	ld	a2,88(sp)
    8000680a:	7686                	ld	a3,96(sp)
    8000680c:	7726                	ld	a4,104(sp)
    8000680e:	77c6                	ld	a5,112(sp)
    80006810:	7866                	ld	a6,120(sp)
    80006812:	688a                	ld	a7,128(sp)
    80006814:	692a                	ld	s2,136(sp)
    80006816:	69ca                	ld	s3,144(sp)
    80006818:	6a6a                	ld	s4,152(sp)
    8000681a:	7a8a                	ld	s5,160(sp)
    8000681c:	7b2a                	ld	s6,168(sp)
    8000681e:	7bca                	ld	s7,176(sp)
    80006820:	7c6a                	ld	s8,184(sp)
    80006822:	6c8e                	ld	s9,192(sp)
    80006824:	6d2e                	ld	s10,200(sp)
    80006826:	6dce                	ld	s11,208(sp)
    80006828:	6e6e                	ld	t3,216(sp)
    8000682a:	7e8e                	ld	t4,224(sp)
    8000682c:	7f2e                	ld	t5,232(sp)
    8000682e:	7fce                	ld	t6,240(sp)
    80006830:	6111                	addi	sp,sp,256
    80006832:	10200073          	sret
    80006836:	00000013          	nop
    8000683a:	00000013          	nop
    8000683e:	0001                	nop

0000000080006840 <timervec>:
    80006840:	34051573          	csrrw	a0,mscratch,a0
    80006844:	e10c                	sd	a1,0(a0)
    80006846:	e510                	sd	a2,8(a0)
    80006848:	e914                	sd	a3,16(a0)
    8000684a:	6d0c                	ld	a1,24(a0)
    8000684c:	7110                	ld	a2,32(a0)
    8000684e:	6194                	ld	a3,0(a1)
    80006850:	96b2                	add	a3,a3,a2
    80006852:	e194                	sd	a3,0(a1)
    80006854:	4589                	li	a1,2
    80006856:	14459073          	csrw	sip,a1
    8000685a:	6914                	ld	a3,16(a0)
    8000685c:	6510                	ld	a2,8(a0)
    8000685e:	610c                	ld	a1,0(a0)
    80006860:	34051573          	csrrw	a0,mscratch,a0
    80006864:	30200073          	mret
	...

000000008000686a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000686a:	1141                	addi	sp,sp,-16
    8000686c:	e422                	sd	s0,8(sp)
    8000686e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006870:	0c0007b7          	lui	a5,0xc000
    80006874:	4705                	li	a4,1
    80006876:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006878:	c3d8                	sw	a4,4(a5)
}
    8000687a:	6422                	ld	s0,8(sp)
    8000687c:	0141                	addi	sp,sp,16
    8000687e:	8082                	ret

0000000080006880 <plicinithart>:

void
plicinithart(void)
{
    80006880:	1141                	addi	sp,sp,-16
    80006882:	e406                	sd	ra,8(sp)
    80006884:	e022                	sd	s0,0(sp)
    80006886:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006888:	ffffb097          	auipc	ra,0xffffb
    8000688c:	1e4080e7          	jalr	484(ra) # 80001a6c <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006890:	0085171b          	slliw	a4,a0,0x8
    80006894:	0c0027b7          	lui	a5,0xc002
    80006898:	97ba                	add	a5,a5,a4
    8000689a:	40200713          	li	a4,1026
    8000689e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800068a2:	00d5151b          	slliw	a0,a0,0xd
    800068a6:	0c2017b7          	lui	a5,0xc201
    800068aa:	953e                	add	a0,a0,a5
    800068ac:	00052023          	sw	zero,0(a0)
}
    800068b0:	60a2                	ld	ra,8(sp)
    800068b2:	6402                	ld	s0,0(sp)
    800068b4:	0141                	addi	sp,sp,16
    800068b6:	8082                	ret

00000000800068b8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800068b8:	1141                	addi	sp,sp,-16
    800068ba:	e406                	sd	ra,8(sp)
    800068bc:	e022                	sd	s0,0(sp)
    800068be:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800068c0:	ffffb097          	auipc	ra,0xffffb
    800068c4:	1ac080e7          	jalr	428(ra) # 80001a6c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800068c8:	00d5179b          	slliw	a5,a0,0xd
    800068cc:	0c201537          	lui	a0,0xc201
    800068d0:	953e                	add	a0,a0,a5
  return irq;
}
    800068d2:	4148                	lw	a0,4(a0)
    800068d4:	60a2                	ld	ra,8(sp)
    800068d6:	6402                	ld	s0,0(sp)
    800068d8:	0141                	addi	sp,sp,16
    800068da:	8082                	ret

00000000800068dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800068dc:	1101                	addi	sp,sp,-32
    800068de:	ec06                	sd	ra,24(sp)
    800068e0:	e822                	sd	s0,16(sp)
    800068e2:	e426                	sd	s1,8(sp)
    800068e4:	1000                	addi	s0,sp,32
    800068e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800068e8:	ffffb097          	auipc	ra,0xffffb
    800068ec:	184080e7          	jalr	388(ra) # 80001a6c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800068f0:	00d5151b          	slliw	a0,a0,0xd
    800068f4:	0c2017b7          	lui	a5,0xc201
    800068f8:	97aa                	add	a5,a5,a0
    800068fa:	c3c4                	sw	s1,4(a5)
}
    800068fc:	60e2                	ld	ra,24(sp)
    800068fe:	6442                	ld	s0,16(sp)
    80006900:	64a2                	ld	s1,8(sp)
    80006902:	6105                	addi	sp,sp,32
    80006904:	8082                	ret

0000000080006906 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006906:	1141                	addi	sp,sp,-16
    80006908:	e406                	sd	ra,8(sp)
    8000690a:	e022                	sd	s0,0(sp)
    8000690c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000690e:	479d                	li	a5,7
    80006910:	06a7c963          	blt	a5,a0,80006982 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    80006914:	00037797          	auipc	a5,0x37
    80006918:	6ec78793          	addi	a5,a5,1772 # 8003e000 <disk>
    8000691c:	00a78733          	add	a4,a5,a0
    80006920:	6789                	lui	a5,0x2
    80006922:	97ba                	add	a5,a5,a4
    80006924:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80006928:	e7ad                	bnez	a5,80006992 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000692a:	00451793          	slli	a5,a0,0x4
    8000692e:	00039717          	auipc	a4,0x39
    80006932:	6d270713          	addi	a4,a4,1746 # 80040000 <disk+0x2000>
    80006936:	6314                	ld	a3,0(a4)
    80006938:	96be                	add	a3,a3,a5
    8000693a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000693e:	6314                	ld	a3,0(a4)
    80006940:	96be                	add	a3,a3,a5
    80006942:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006946:	6314                	ld	a3,0(a4)
    80006948:	96be                	add	a3,a3,a5
    8000694a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000694e:	6318                	ld	a4,0(a4)
    80006950:	97ba                	add	a5,a5,a4
    80006952:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006956:	00037797          	auipc	a5,0x37
    8000695a:	6aa78793          	addi	a5,a5,1706 # 8003e000 <disk>
    8000695e:	97aa                	add	a5,a5,a0
    80006960:	6509                	lui	a0,0x2
    80006962:	953e                	add	a0,a0,a5
    80006964:	4785                	li	a5,1
    80006966:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000696a:	00039517          	auipc	a0,0x39
    8000696e:	6ae50513          	addi	a0,a0,1710 # 80040018 <disk+0x2018>
    80006972:	ffffc097          	auipc	ra,0xffffc
    80006976:	cfe080e7          	jalr	-770(ra) # 80002670 <wakeup>
}
    8000697a:	60a2                	ld	ra,8(sp)
    8000697c:	6402                	ld	s0,0(sp)
    8000697e:	0141                	addi	sp,sp,16
    80006980:	8082                	ret
    panic("free_desc 1");
    80006982:	00002517          	auipc	a0,0x2
    80006986:	fa650513          	addi	a0,a0,-90 # 80008928 <syscalls+0x338>
    8000698a:	ffffa097          	auipc	ra,0xffffa
    8000698e:	ba4080e7          	jalr	-1116(ra) # 8000052e <panic>
    panic("free_desc 2");
    80006992:	00002517          	auipc	a0,0x2
    80006996:	fa650513          	addi	a0,a0,-90 # 80008938 <syscalls+0x348>
    8000699a:	ffffa097          	auipc	ra,0xffffa
    8000699e:	b94080e7          	jalr	-1132(ra) # 8000052e <panic>

00000000800069a2 <virtio_disk_init>:
{
    800069a2:	1101                	addi	sp,sp,-32
    800069a4:	ec06                	sd	ra,24(sp)
    800069a6:	e822                	sd	s0,16(sp)
    800069a8:	e426                	sd	s1,8(sp)
    800069aa:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800069ac:	00002597          	auipc	a1,0x2
    800069b0:	f9c58593          	addi	a1,a1,-100 # 80008948 <syscalls+0x358>
    800069b4:	00039517          	auipc	a0,0x39
    800069b8:	77450513          	addi	a0,a0,1908 # 80040128 <disk+0x2128>
    800069bc:	ffffa097          	auipc	ra,0xffffa
    800069c0:	17a080e7          	jalr	378(ra) # 80000b36 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800069c4:	100017b7          	lui	a5,0x10001
    800069c8:	4398                	lw	a4,0(a5)
    800069ca:	2701                	sext.w	a4,a4
    800069cc:	747277b7          	lui	a5,0x74727
    800069d0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800069d4:	0ef71163          	bne	a4,a5,80006ab6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800069d8:	100017b7          	lui	a5,0x10001
    800069dc:	43dc                	lw	a5,4(a5)
    800069de:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800069e0:	4705                	li	a4,1
    800069e2:	0ce79a63          	bne	a5,a4,80006ab6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800069e6:	100017b7          	lui	a5,0x10001
    800069ea:	479c                	lw	a5,8(a5)
    800069ec:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800069ee:	4709                	li	a4,2
    800069f0:	0ce79363          	bne	a5,a4,80006ab6 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800069f4:	100017b7          	lui	a5,0x10001
    800069f8:	47d8                	lw	a4,12(a5)
    800069fa:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800069fc:	554d47b7          	lui	a5,0x554d4
    80006a00:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006a04:	0af71963          	bne	a4,a5,80006ab6 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006a08:	100017b7          	lui	a5,0x10001
    80006a0c:	4705                	li	a4,1
    80006a0e:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006a10:	470d                	li	a4,3
    80006a12:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80006a14:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006a16:	c7ffe737          	lui	a4,0xc7ffe
    80006a1a:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fbd75f>
    80006a1e:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006a20:	2701                	sext.w	a4,a4
    80006a22:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006a24:	472d                	li	a4,11
    80006a26:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006a28:	473d                	li	a4,15
    80006a2a:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80006a2c:	6705                	lui	a4,0x1
    80006a2e:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006a30:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006a34:	5bdc                	lw	a5,52(a5)
    80006a36:	2781                	sext.w	a5,a5
  if(max == 0)
    80006a38:	c7d9                	beqz	a5,80006ac6 <virtio_disk_init+0x124>
  if(max < NUM)
    80006a3a:	471d                	li	a4,7
    80006a3c:	08f77d63          	bgeu	a4,a5,80006ad6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006a40:	100014b7          	lui	s1,0x10001
    80006a44:	47a1                	li	a5,8
    80006a46:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006a48:	6609                	lui	a2,0x2
    80006a4a:	4581                	li	a1,0
    80006a4c:	00037517          	auipc	a0,0x37
    80006a50:	5b450513          	addi	a0,a0,1460 # 8003e000 <disk>
    80006a54:	ffffa097          	auipc	ra,0xffffa
    80006a58:	284080e7          	jalr	644(ra) # 80000cd8 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80006a5c:	00037717          	auipc	a4,0x37
    80006a60:	5a470713          	addi	a4,a4,1444 # 8003e000 <disk>
    80006a64:	00c75793          	srli	a5,a4,0xc
    80006a68:	2781                	sext.w	a5,a5
    80006a6a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    80006a6c:	00039797          	auipc	a5,0x39
    80006a70:	59478793          	addi	a5,a5,1428 # 80040000 <disk+0x2000>
    80006a74:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006a76:	00037717          	auipc	a4,0x37
    80006a7a:	60a70713          	addi	a4,a4,1546 # 8003e080 <disk+0x80>
    80006a7e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006a80:	00038717          	auipc	a4,0x38
    80006a84:	58070713          	addi	a4,a4,1408 # 8003f000 <disk+0x1000>
    80006a88:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80006a8a:	4705                	li	a4,1
    80006a8c:	00e78c23          	sb	a4,24(a5)
    80006a90:	00e78ca3          	sb	a4,25(a5)
    80006a94:	00e78d23          	sb	a4,26(a5)
    80006a98:	00e78da3          	sb	a4,27(a5)
    80006a9c:	00e78e23          	sb	a4,28(a5)
    80006aa0:	00e78ea3          	sb	a4,29(a5)
    80006aa4:	00e78f23          	sb	a4,30(a5)
    80006aa8:	00e78fa3          	sb	a4,31(a5)
}
    80006aac:	60e2                	ld	ra,24(sp)
    80006aae:	6442                	ld	s0,16(sp)
    80006ab0:	64a2                	ld	s1,8(sp)
    80006ab2:	6105                	addi	sp,sp,32
    80006ab4:	8082                	ret
    panic("could not find virtio disk");
    80006ab6:	00002517          	auipc	a0,0x2
    80006aba:	ea250513          	addi	a0,a0,-350 # 80008958 <syscalls+0x368>
    80006abe:	ffffa097          	auipc	ra,0xffffa
    80006ac2:	a70080e7          	jalr	-1424(ra) # 8000052e <panic>
    panic("virtio disk has no queue 0");
    80006ac6:	00002517          	auipc	a0,0x2
    80006aca:	eb250513          	addi	a0,a0,-334 # 80008978 <syscalls+0x388>
    80006ace:	ffffa097          	auipc	ra,0xffffa
    80006ad2:	a60080e7          	jalr	-1440(ra) # 8000052e <panic>
    panic("virtio disk max queue too short");
    80006ad6:	00002517          	auipc	a0,0x2
    80006ada:	ec250513          	addi	a0,a0,-318 # 80008998 <syscalls+0x3a8>
    80006ade:	ffffa097          	auipc	ra,0xffffa
    80006ae2:	a50080e7          	jalr	-1456(ra) # 8000052e <panic>

0000000080006ae6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006ae6:	7119                	addi	sp,sp,-128
    80006ae8:	fc86                	sd	ra,120(sp)
    80006aea:	f8a2                	sd	s0,112(sp)
    80006aec:	f4a6                	sd	s1,104(sp)
    80006aee:	f0ca                	sd	s2,96(sp)
    80006af0:	ecce                	sd	s3,88(sp)
    80006af2:	e8d2                	sd	s4,80(sp)
    80006af4:	e4d6                	sd	s5,72(sp)
    80006af6:	e0da                	sd	s6,64(sp)
    80006af8:	fc5e                	sd	s7,56(sp)
    80006afa:	f862                	sd	s8,48(sp)
    80006afc:	f466                	sd	s9,40(sp)
    80006afe:	f06a                	sd	s10,32(sp)
    80006b00:	ec6e                	sd	s11,24(sp)
    80006b02:	0100                	addi	s0,sp,128
    80006b04:	8aaa                	mv	s5,a0
    80006b06:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006b08:	00c52c83          	lw	s9,12(a0)
    80006b0c:	001c9c9b          	slliw	s9,s9,0x1
    80006b10:	1c82                	slli	s9,s9,0x20
    80006b12:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006b16:	00039517          	auipc	a0,0x39
    80006b1a:	61250513          	addi	a0,a0,1554 # 80040128 <disk+0x2128>
    80006b1e:	ffffa097          	auipc	ra,0xffffa
    80006b22:	0a8080e7          	jalr	168(ra) # 80000bc6 <acquire>
  for(int i = 0; i < 3; i++){
    80006b26:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006b28:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006b2a:	00037c17          	auipc	s8,0x37
    80006b2e:	4d6c0c13          	addi	s8,s8,1238 # 8003e000 <disk>
    80006b32:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006b34:	4b0d                	li	s6,3
    80006b36:	a0ad                	j	80006ba0 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80006b38:	00fc0733          	add	a4,s8,a5
    80006b3c:	975e                	add	a4,a4,s7
    80006b3e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006b42:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006b44:	0207c563          	bltz	a5,80006b6e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006b48:	2905                	addiw	s2,s2,1
    80006b4a:	0611                	addi	a2,a2,4
    80006b4c:	19690d63          	beq	s2,s6,80006ce6 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006b50:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006b52:	00039717          	auipc	a4,0x39
    80006b56:	4c670713          	addi	a4,a4,1222 # 80040018 <disk+0x2018>
    80006b5a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006b5c:	00074683          	lbu	a3,0(a4)
    80006b60:	fee1                	bnez	a3,80006b38 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006b62:	2785                	addiw	a5,a5,1
    80006b64:	0705                	addi	a4,a4,1
    80006b66:	fe979be3          	bne	a5,s1,80006b5c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006b6a:	57fd                	li	a5,-1
    80006b6c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006b6e:	01205d63          	blez	s2,80006b88 <virtio_disk_rw+0xa2>
    80006b72:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006b74:	000a2503          	lw	a0,0(s4)
    80006b78:	00000097          	auipc	ra,0x0
    80006b7c:	d8e080e7          	jalr	-626(ra) # 80006906 <free_desc>
      for(int j = 0; j < i; j++)
    80006b80:	2d85                	addiw	s11,s11,1
    80006b82:	0a11                	addi	s4,s4,4
    80006b84:	ffb918e3          	bne	s2,s11,80006b74 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006b88:	00039597          	auipc	a1,0x39
    80006b8c:	5a058593          	addi	a1,a1,1440 # 80040128 <disk+0x2128>
    80006b90:	00039517          	auipc	a0,0x39
    80006b94:	48850513          	addi	a0,a0,1160 # 80040018 <disk+0x2018>
    80006b98:	ffffc097          	auipc	ra,0xffffc
    80006b9c:	94e080e7          	jalr	-1714(ra) # 800024e6 <sleep>
  for(int i = 0; i < 3; i++){
    80006ba0:	f8040a13          	addi	s4,s0,-128
{
    80006ba4:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006ba6:	894e                	mv	s2,s3
    80006ba8:	b765                	j	80006b50 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006baa:	00039697          	auipc	a3,0x39
    80006bae:	4566b683          	ld	a3,1110(a3) # 80040000 <disk+0x2000>
    80006bb2:	96ba                	add	a3,a3,a4
    80006bb4:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006bb8:	00037817          	auipc	a6,0x37
    80006bbc:	44880813          	addi	a6,a6,1096 # 8003e000 <disk>
    80006bc0:	00039697          	auipc	a3,0x39
    80006bc4:	44068693          	addi	a3,a3,1088 # 80040000 <disk+0x2000>
    80006bc8:	6290                	ld	a2,0(a3)
    80006bca:	963a                	add	a2,a2,a4
    80006bcc:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006bd0:	0015e593          	ori	a1,a1,1
    80006bd4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006bd8:	f8842603          	lw	a2,-120(s0)
    80006bdc:	628c                	ld	a1,0(a3)
    80006bde:	972e                	add	a4,a4,a1
    80006be0:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006be4:	20050593          	addi	a1,a0,512
    80006be8:	0592                	slli	a1,a1,0x4
    80006bea:	95c2                	add	a1,a1,a6
    80006bec:	577d                	li	a4,-1
    80006bee:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006bf2:	00461713          	slli	a4,a2,0x4
    80006bf6:	6290                	ld	a2,0(a3)
    80006bf8:	963a                	add	a2,a2,a4
    80006bfa:	03078793          	addi	a5,a5,48
    80006bfe:	97c2                	add	a5,a5,a6
    80006c00:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    80006c02:	629c                	ld	a5,0(a3)
    80006c04:	97ba                	add	a5,a5,a4
    80006c06:	4605                	li	a2,1
    80006c08:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006c0a:	629c                	ld	a5,0(a3)
    80006c0c:	97ba                	add	a5,a5,a4
    80006c0e:	4809                	li	a6,2
    80006c10:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006c14:	629c                	ld	a5,0(a3)
    80006c16:	973e                	add	a4,a4,a5
    80006c18:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006c1c:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    80006c20:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006c24:	6698                	ld	a4,8(a3)
    80006c26:	00275783          	lhu	a5,2(a4)
    80006c2a:	8b9d                	andi	a5,a5,7
    80006c2c:	0786                	slli	a5,a5,0x1
    80006c2e:	97ba                	add	a5,a5,a4
    80006c30:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    80006c34:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006c38:	6698                	ld	a4,8(a3)
    80006c3a:	00275783          	lhu	a5,2(a4)
    80006c3e:	2785                	addiw	a5,a5,1
    80006c40:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006c44:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006c48:	100017b7          	lui	a5,0x10001
    80006c4c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006c50:	004aa783          	lw	a5,4(s5)
    80006c54:	02c79163          	bne	a5,a2,80006c76 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006c58:	00039917          	auipc	s2,0x39
    80006c5c:	4d090913          	addi	s2,s2,1232 # 80040128 <disk+0x2128>
  while(b->disk == 1) {
    80006c60:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006c62:	85ca                	mv	a1,s2
    80006c64:	8556                	mv	a0,s5
    80006c66:	ffffc097          	auipc	ra,0xffffc
    80006c6a:	880080e7          	jalr	-1920(ra) # 800024e6 <sleep>
  while(b->disk == 1) {
    80006c6e:	004aa783          	lw	a5,4(s5)
    80006c72:	fe9788e3          	beq	a5,s1,80006c62 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006c76:	f8042903          	lw	s2,-128(s0)
    80006c7a:	20090793          	addi	a5,s2,512
    80006c7e:	00479713          	slli	a4,a5,0x4
    80006c82:	00037797          	auipc	a5,0x37
    80006c86:	37e78793          	addi	a5,a5,894 # 8003e000 <disk>
    80006c8a:	97ba                	add	a5,a5,a4
    80006c8c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006c90:	00039997          	auipc	s3,0x39
    80006c94:	37098993          	addi	s3,s3,880 # 80040000 <disk+0x2000>
    80006c98:	00491713          	slli	a4,s2,0x4
    80006c9c:	0009b783          	ld	a5,0(s3)
    80006ca0:	97ba                	add	a5,a5,a4
    80006ca2:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006ca6:	854a                	mv	a0,s2
    80006ca8:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006cac:	00000097          	auipc	ra,0x0
    80006cb0:	c5a080e7          	jalr	-934(ra) # 80006906 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006cb4:	8885                	andi	s1,s1,1
    80006cb6:	f0ed                	bnez	s1,80006c98 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006cb8:	00039517          	auipc	a0,0x39
    80006cbc:	47050513          	addi	a0,a0,1136 # 80040128 <disk+0x2128>
    80006cc0:	ffffa097          	auipc	ra,0xffffa
    80006cc4:	fd0080e7          	jalr	-48(ra) # 80000c90 <release>
}
    80006cc8:	70e6                	ld	ra,120(sp)
    80006cca:	7446                	ld	s0,112(sp)
    80006ccc:	74a6                	ld	s1,104(sp)
    80006cce:	7906                	ld	s2,96(sp)
    80006cd0:	69e6                	ld	s3,88(sp)
    80006cd2:	6a46                	ld	s4,80(sp)
    80006cd4:	6aa6                	ld	s5,72(sp)
    80006cd6:	6b06                	ld	s6,64(sp)
    80006cd8:	7be2                	ld	s7,56(sp)
    80006cda:	7c42                	ld	s8,48(sp)
    80006cdc:	7ca2                	ld	s9,40(sp)
    80006cde:	7d02                	ld	s10,32(sp)
    80006ce0:	6de2                	ld	s11,24(sp)
    80006ce2:	6109                	addi	sp,sp,128
    80006ce4:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006ce6:	f8042503          	lw	a0,-128(s0)
    80006cea:	20050793          	addi	a5,a0,512
    80006cee:	0792                	slli	a5,a5,0x4
  if(write)
    80006cf0:	00037817          	auipc	a6,0x37
    80006cf4:	31080813          	addi	a6,a6,784 # 8003e000 <disk>
    80006cf8:	00f80733          	add	a4,a6,a5
    80006cfc:	01a036b3          	snez	a3,s10
    80006d00:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    80006d04:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    80006d08:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006d0c:	7679                	lui	a2,0xffffe
    80006d0e:	963e                	add	a2,a2,a5
    80006d10:	00039697          	auipc	a3,0x39
    80006d14:	2f068693          	addi	a3,a3,752 # 80040000 <disk+0x2000>
    80006d18:	6298                	ld	a4,0(a3)
    80006d1a:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006d1c:	0a878593          	addi	a1,a5,168
    80006d20:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006d22:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006d24:	6298                	ld	a4,0(a3)
    80006d26:	9732                	add	a4,a4,a2
    80006d28:	45c1                	li	a1,16
    80006d2a:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006d2c:	6298                	ld	a4,0(a3)
    80006d2e:	9732                	add	a4,a4,a2
    80006d30:	4585                	li	a1,1
    80006d32:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    80006d36:	f8442703          	lw	a4,-124(s0)
    80006d3a:	628c                	ld	a1,0(a3)
    80006d3c:	962e                	add	a2,a2,a1
    80006d3e:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffbd00e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006d42:	0712                	slli	a4,a4,0x4
    80006d44:	6290                	ld	a2,0(a3)
    80006d46:	963a                	add	a2,a2,a4
    80006d48:	058a8593          	addi	a1,s5,88
    80006d4c:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006d4e:	6294                	ld	a3,0(a3)
    80006d50:	96ba                	add	a3,a3,a4
    80006d52:	40000613          	li	a2,1024
    80006d56:	c690                	sw	a2,8(a3)
  if(write)
    80006d58:	e40d19e3          	bnez	s10,80006baa <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006d5c:	00039697          	auipc	a3,0x39
    80006d60:	2a46b683          	ld	a3,676(a3) # 80040000 <disk+0x2000>
    80006d64:	96ba                	add	a3,a3,a4
    80006d66:	4609                	li	a2,2
    80006d68:	00c69623          	sh	a2,12(a3)
    80006d6c:	b5b1                	j	80006bb8 <virtio_disk_rw+0xd2>

0000000080006d6e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006d6e:	1101                	addi	sp,sp,-32
    80006d70:	ec06                	sd	ra,24(sp)
    80006d72:	e822                	sd	s0,16(sp)
    80006d74:	e426                	sd	s1,8(sp)
    80006d76:	e04a                	sd	s2,0(sp)
    80006d78:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006d7a:	00039517          	auipc	a0,0x39
    80006d7e:	3ae50513          	addi	a0,a0,942 # 80040128 <disk+0x2128>
    80006d82:	ffffa097          	auipc	ra,0xffffa
    80006d86:	e44080e7          	jalr	-444(ra) # 80000bc6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006d8a:	10001737          	lui	a4,0x10001
    80006d8e:	533c                	lw	a5,96(a4)
    80006d90:	8b8d                	andi	a5,a5,3
    80006d92:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006d94:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006d98:	00039797          	auipc	a5,0x39
    80006d9c:	26878793          	addi	a5,a5,616 # 80040000 <disk+0x2000>
    80006da0:	6b94                	ld	a3,16(a5)
    80006da2:	0207d703          	lhu	a4,32(a5)
    80006da6:	0026d783          	lhu	a5,2(a3)
    80006daa:	06f70163          	beq	a4,a5,80006e0c <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006dae:	00037917          	auipc	s2,0x37
    80006db2:	25290913          	addi	s2,s2,594 # 8003e000 <disk>
    80006db6:	00039497          	auipc	s1,0x39
    80006dba:	24a48493          	addi	s1,s1,586 # 80040000 <disk+0x2000>
    __sync_synchronize();
    80006dbe:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006dc2:	6898                	ld	a4,16(s1)
    80006dc4:	0204d783          	lhu	a5,32(s1)
    80006dc8:	8b9d                	andi	a5,a5,7
    80006dca:	078e                	slli	a5,a5,0x3
    80006dcc:	97ba                	add	a5,a5,a4
    80006dce:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006dd0:	20078713          	addi	a4,a5,512
    80006dd4:	0712                	slli	a4,a4,0x4
    80006dd6:	974a                	add	a4,a4,s2
    80006dd8:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80006ddc:	e731                	bnez	a4,80006e28 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006dde:	20078793          	addi	a5,a5,512
    80006de2:	0792                	slli	a5,a5,0x4
    80006de4:	97ca                	add	a5,a5,s2
    80006de6:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006de8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006dec:	ffffc097          	auipc	ra,0xffffc
    80006df0:	884080e7          	jalr	-1916(ra) # 80002670 <wakeup>

    disk.used_idx += 1;
    80006df4:	0204d783          	lhu	a5,32(s1)
    80006df8:	2785                	addiw	a5,a5,1
    80006dfa:	17c2                	slli	a5,a5,0x30
    80006dfc:	93c1                	srli	a5,a5,0x30
    80006dfe:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006e02:	6898                	ld	a4,16(s1)
    80006e04:	00275703          	lhu	a4,2(a4)
    80006e08:	faf71be3          	bne	a4,a5,80006dbe <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    80006e0c:	00039517          	auipc	a0,0x39
    80006e10:	31c50513          	addi	a0,a0,796 # 80040128 <disk+0x2128>
    80006e14:	ffffa097          	auipc	ra,0xffffa
    80006e18:	e7c080e7          	jalr	-388(ra) # 80000c90 <release>
}
    80006e1c:	60e2                	ld	ra,24(sp)
    80006e1e:	6442                	ld	s0,16(sp)
    80006e20:	64a2                	ld	s1,8(sp)
    80006e22:	6902                	ld	s2,0(sp)
    80006e24:	6105                	addi	sp,sp,32
    80006e26:	8082                	ret
      panic("virtio_disk_intr status");
    80006e28:	00002517          	auipc	a0,0x2
    80006e2c:	b9050513          	addi	a0,a0,-1136 # 800089b8 <syscalls+0x3c8>
    80006e30:	ffff9097          	auipc	ra,0xffff9
    80006e34:	6fe080e7          	jalr	1790(ra) # 8000052e <panic>

0000000080006e38 <call_sigret>:
    80006e38:	48e1                	li	a7,24
    80006e3a:	00000073          	ecall
    80006e3e:	8082                	ret

0000000080006e40 <end_sigret>:
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
