
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
    80000068:	f8c78793          	addi	a5,a5,-116 # 80005ff0 <timervec>
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
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd07ff>
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
    8000011e:	00002097          	auipc	ra,0x2
    80000122:	456080e7          	jalr	1110(ra) # 80002574 <either_copyin>
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
    800001b2:	00001097          	auipc	ra,0x1
    800001b6:	7e6080e7          	jalr	2022(ra) # 80001998 <myproc>
    800001ba:	551c                	lw	a5,40(a0)
    800001bc:	07278863          	beq	a5,s2,8000022c <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001c0:	85a6                	mv	a1,s1
    800001c2:	854e                	mv	a0,s3
    800001c4:	00002097          	auipc	ra,0x2
    800001c8:	f20080e7          	jalr	-224(ra) # 800020e4 <sleep>
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
    80000204:	31e080e7          	jalr	798(ra) # 8000251e <either_copyout>
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
    800002e6:	2e8080e7          	jalr	744(ra) # 800025ca <procdump>
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
    8000043a:	e3c080e7          	jalr	-452(ra) # 80002272 <wakeup>
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
    80000468:	00029797          	auipc	a5,0x29
    8000046c:	4b078793          	addi	a5,a5,1200 # 80029918 <devsw>
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
    80000560:	b9c50513          	addi	a0,a0,-1124 # 800080f8 <digits+0xb8>
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
    80000886:	9f0080e7          	jalr	-1552(ra) # 80002272 <wakeup>
    
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
    8000090e:	00001097          	auipc	ra,0x1
    80000912:	7d6080e7          	jalr	2006(ra) # 800020e4 <sleep>
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
    800009ee:	0002d797          	auipc	a5,0x2d
    800009f2:	61278793          	addi	a5,a5,1554 # 8002e000 <end>
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
    80000abe:	0002d517          	auipc	a0,0x2d
    80000ac2:	54250513          	addi	a0,a0,1346 # 8002e000 <end>
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
    80000b64:	e1c080e7          	jalr	-484(ra) # 8000197c <mycpu>
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
    80000b96:	dea080e7          	jalr	-534(ra) # 8000197c <mycpu>
    80000b9a:	5d3c                	lw	a5,120(a0)
    80000b9c:	cf89                	beqz	a5,80000bb6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	dde080e7          	jalr	-546(ra) # 8000197c <mycpu>
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
    80000bba:	dc6080e7          	jalr	-570(ra) # 8000197c <mycpu>
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
    80000bfa:	d86080e7          	jalr	-634(ra) # 8000197c <mycpu>
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
    80000c0e:	5b8c                	lw	a1,48(a5)
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
    80000c3c:	d44080e7          	jalr	-700(ra) # 8000197c <mycpu>
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
    80000e92:	ade080e7          	jalr	-1314(ra) # 8000196c <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
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
    80000eae:	ac2080e7          	jalr	-1342(ra) # 8000196c <cpuid>
    80000eb2:	85aa                	mv	a1,a0
    80000eb4:	00007517          	auipc	a0,0x7
    80000eb8:	23450513          	addi	a0,a0,564 # 800080e8 <digits+0xa8>
    80000ebc:	fffff097          	auipc	ra,0xfffff
    80000ec0:	6bc080e7          	jalr	1724(ra) # 80000578 <printf>
    kvminithart();    // turn on paging
    80000ec4:	00000097          	auipc	ra,0x0
    80000ec8:	0d8080e7          	jalr	216(ra) # 80000f9c <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ecc:	00002097          	auipc	ra,0x2
    80000ed0:	992080e7          	jalr	-1646(ra) # 8000285e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ed4:	00005097          	auipc	ra,0x5
    80000ed8:	15c080e7          	jalr	348(ra) # 80006030 <plicinithart>
  }

  scheduler();        
    80000edc:	00001097          	auipc	ra,0x1
    80000ee0:	056080e7          	jalr	86(ra) # 80001f32 <scheduler>
    consoleinit();
    80000ee4:	fffff097          	auipc	ra,0xfffff
    80000ee8:	55c080e7          	jalr	1372(ra) # 80000440 <consoleinit>
    printfinit();
    80000eec:	00000097          	auipc	ra,0x0
    80000ef0:	86c080e7          	jalr	-1940(ra) # 80000758 <printfinit>
    printf("\n");
    80000ef4:	00007517          	auipc	a0,0x7
    80000ef8:	20450513          	addi	a0,a0,516 # 800080f8 <digits+0xb8>
    80000efc:	fffff097          	auipc	ra,0xfffff
    80000f00:	67c080e7          	jalr	1660(ra) # 80000578 <printf>
    printf("xv6 kernel is booting\n");
    80000f04:	00007517          	auipc	a0,0x7
    80000f08:	1cc50513          	addi	a0,a0,460 # 800080d0 <digits+0x90>
    80000f0c:	fffff097          	auipc	ra,0xfffff
    80000f10:	66c080e7          	jalr	1644(ra) # 80000578 <printf>
    printf("\n");
    80000f14:	00007517          	auipc	a0,0x7
    80000f18:	1e450513          	addi	a0,a0,484 # 800080f8 <digits+0xb8>
    80000f1c:	fffff097          	auipc	ra,0xfffff
    80000f20:	65c080e7          	jalr	1628(ra) # 80000578 <printf>
    kinit();         // physical page allocator
    80000f24:	00000097          	auipc	ra,0x0
    80000f28:	b76080e7          	jalr	-1162(ra) # 80000a9a <kinit>
    kvminit();       // create kernel page table
    80000f2c:	00000097          	auipc	ra,0x0
    80000f30:	310080e7          	jalr	784(ra) # 8000123c <kvminit>
    kvminithart();   // turn on paging
    80000f34:	00000097          	auipc	ra,0x0
    80000f38:	068080e7          	jalr	104(ra) # 80000f9c <kvminithart>
    procinit();      // process table
    80000f3c:	00001097          	auipc	ra,0x1
    80000f40:	980080e7          	jalr	-1664(ra) # 800018bc <procinit>
    trapinit();      // trap vectors
    80000f44:	00002097          	auipc	ra,0x2
    80000f48:	8f2080e7          	jalr	-1806(ra) # 80002836 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f4c:	00002097          	auipc	ra,0x2
    80000f50:	912080e7          	jalr	-1774(ra) # 8000285e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f54:	00005097          	auipc	ra,0x5
    80000f58:	0c6080e7          	jalr	198(ra) # 8000601a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f5c:	00005097          	auipc	ra,0x5
    80000f60:	0d4080e7          	jalr	212(ra) # 80006030 <plicinithart>
    binit();         // buffer cache
    80000f64:	00002097          	auipc	ra,0x2
    80000f68:	276080e7          	jalr	630(ra) # 800031da <binit>
    iinit();         // inode cache
    80000f6c:	00003097          	auipc	ra,0x3
    80000f70:	908080e7          	jalr	-1784(ra) # 80003874 <iinit>
    fileinit();      // file table
    80000f74:	00004097          	auipc	ra,0x4
    80000f78:	8b6080e7          	jalr	-1866(ra) # 8000482a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f7c:	00005097          	auipc	ra,0x5
    80000f80:	1d6080e7          	jalr	470(ra) # 80006152 <virtio_disk_init>
    userinit();      // first user process
    80000f84:	00001097          	auipc	ra,0x1
    80000f88:	d48080e7          	jalr	-696(ra) # 80001ccc <userinit>
    __sync_synchronize();
    80000f8c:	0ff0000f          	fence
    started = 1;
    80000f90:	4785                	li	a5,1
    80000f92:	00008717          	auipc	a4,0x8
    80000f96:	08f72323          	sw	a5,134(a4) # 80009018 <started>
    80000f9a:	b789                	j	80000edc <main+0x56>

0000000080000f9c <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f9c:	1141                	addi	sp,sp,-16
    80000f9e:	e422                	sd	s0,8(sp)
    80000fa0:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000fa2:	00008797          	auipc	a5,0x8
    80000fa6:	07e7b783          	ld	a5,126(a5) # 80009020 <kernel_pagetable>
    80000faa:	83b1                	srli	a5,a5,0xc
    80000fac:	577d                	li	a4,-1
    80000fae:	177e                	slli	a4,a4,0x3f
    80000fb0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fb2:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fb6:	12000073          	sfence.vma
  sfence_vma();
}
    80000fba:	6422                	ld	s0,8(sp)
    80000fbc:	0141                	addi	sp,sp,16
    80000fbe:	8082                	ret

0000000080000fc0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fc0:	7139                	addi	sp,sp,-64
    80000fc2:	fc06                	sd	ra,56(sp)
    80000fc4:	f822                	sd	s0,48(sp)
    80000fc6:	f426                	sd	s1,40(sp)
    80000fc8:	f04a                	sd	s2,32(sp)
    80000fca:	ec4e                	sd	s3,24(sp)
    80000fcc:	e852                	sd	s4,16(sp)
    80000fce:	e456                	sd	s5,8(sp)
    80000fd0:	e05a                	sd	s6,0(sp)
    80000fd2:	0080                	addi	s0,sp,64
    80000fd4:	84aa                	mv	s1,a0
    80000fd6:	89ae                	mv	s3,a1
    80000fd8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fda:	57fd                	li	a5,-1
    80000fdc:	83e9                	srli	a5,a5,0x1a
    80000fde:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fe0:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fe2:	04b7f263          	bgeu	a5,a1,80001026 <walk+0x66>
    panic("walk");
    80000fe6:	00007517          	auipc	a0,0x7
    80000fea:	11a50513          	addi	a0,a0,282 # 80008100 <digits+0xc0>
    80000fee:	fffff097          	auipc	ra,0xfffff
    80000ff2:	540080e7          	jalr	1344(ra) # 8000052e <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ff6:	060a8663          	beqz	s5,80001062 <walk+0xa2>
    80000ffa:	00000097          	auipc	ra,0x0
    80000ffe:	adc080e7          	jalr	-1316(ra) # 80000ad6 <kalloc>
    80001002:	84aa                	mv	s1,a0
    80001004:	c529                	beqz	a0,8000104e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001006:	6605                	lui	a2,0x1
    80001008:	4581                	li	a1,0
    8000100a:	00000097          	auipc	ra,0x0
    8000100e:	cce080e7          	jalr	-818(ra) # 80000cd8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001012:	00c4d793          	srli	a5,s1,0xc
    80001016:	07aa                	slli	a5,a5,0xa
    80001018:	0017e793          	ori	a5,a5,1
    8000101c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001020:	3a5d                	addiw	s4,s4,-9
    80001022:	036a0063          	beq	s4,s6,80001042 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001026:	0149d933          	srl	s2,s3,s4
    8000102a:	1ff97913          	andi	s2,s2,511
    8000102e:	090e                	slli	s2,s2,0x3
    80001030:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001032:	00093483          	ld	s1,0(s2)
    80001036:	0014f793          	andi	a5,s1,1
    8000103a:	dfd5                	beqz	a5,80000ff6 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000103c:	80a9                	srli	s1,s1,0xa
    8000103e:	04b2                	slli	s1,s1,0xc
    80001040:	b7c5                	j	80001020 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001042:	00c9d513          	srli	a0,s3,0xc
    80001046:	1ff57513          	andi	a0,a0,511
    8000104a:	050e                	slli	a0,a0,0x3
    8000104c:	9526                	add	a0,a0,s1
}
    8000104e:	70e2                	ld	ra,56(sp)
    80001050:	7442                	ld	s0,48(sp)
    80001052:	74a2                	ld	s1,40(sp)
    80001054:	7902                	ld	s2,32(sp)
    80001056:	69e2                	ld	s3,24(sp)
    80001058:	6a42                	ld	s4,16(sp)
    8000105a:	6aa2                	ld	s5,8(sp)
    8000105c:	6b02                	ld	s6,0(sp)
    8000105e:	6121                	addi	sp,sp,64
    80001060:	8082                	ret
        return 0;
    80001062:	4501                	li	a0,0
    80001064:	b7ed                	j	8000104e <walk+0x8e>

0000000080001066 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001066:	57fd                	li	a5,-1
    80001068:	83e9                	srli	a5,a5,0x1a
    8000106a:	00b7f463          	bgeu	a5,a1,80001072 <walkaddr+0xc>
    return 0;
    8000106e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001070:	8082                	ret
{
    80001072:	1141                	addi	sp,sp,-16
    80001074:	e406                	sd	ra,8(sp)
    80001076:	e022                	sd	s0,0(sp)
    80001078:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000107a:	4601                	li	a2,0
    8000107c:	00000097          	auipc	ra,0x0
    80001080:	f44080e7          	jalr	-188(ra) # 80000fc0 <walk>
  if(pte == 0)
    80001084:	c105                	beqz	a0,800010a4 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001086:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001088:	0117f693          	andi	a3,a5,17
    8000108c:	4745                	li	a4,17
    return 0;
    8000108e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001090:	00e68663          	beq	a3,a4,8000109c <walkaddr+0x36>
}
    80001094:	60a2                	ld	ra,8(sp)
    80001096:	6402                	ld	s0,0(sp)
    80001098:	0141                	addi	sp,sp,16
    8000109a:	8082                	ret
  pa = PTE2PA(*pte);
    8000109c:	00a7d513          	srli	a0,a5,0xa
    800010a0:	0532                	slli	a0,a0,0xc
  return pa;
    800010a2:	bfcd                	j	80001094 <walkaddr+0x2e>
    return 0;
    800010a4:	4501                	li	a0,0
    800010a6:	b7fd                	j	80001094 <walkaddr+0x2e>

00000000800010a8 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010a8:	715d                	addi	sp,sp,-80
    800010aa:	e486                	sd	ra,72(sp)
    800010ac:	e0a2                	sd	s0,64(sp)
    800010ae:	fc26                	sd	s1,56(sp)
    800010b0:	f84a                	sd	s2,48(sp)
    800010b2:	f44e                	sd	s3,40(sp)
    800010b4:	f052                	sd	s4,32(sp)
    800010b6:	ec56                	sd	s5,24(sp)
    800010b8:	e85a                	sd	s6,16(sp)
    800010ba:	e45e                	sd	s7,8(sp)
    800010bc:	0880                	addi	s0,sp,80
    800010be:	8aaa                	mv	s5,a0
    800010c0:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010c2:	777d                	lui	a4,0xfffff
    800010c4:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c8:	167d                	addi	a2,a2,-1
    800010ca:	00b609b3          	add	s3,a2,a1
    800010ce:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010d2:	893e                	mv	s2,a5
    800010d4:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d8:	6b85                	lui	s7,0x1
    800010da:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010de:	4605                	li	a2,1
    800010e0:	85ca                	mv	a1,s2
    800010e2:	8556                	mv	a0,s5
    800010e4:	00000097          	auipc	ra,0x0
    800010e8:	edc080e7          	jalr	-292(ra) # 80000fc0 <walk>
    800010ec:	c51d                	beqz	a0,8000111a <mappages+0x72>
    if(*pte & PTE_V)
    800010ee:	611c                	ld	a5,0(a0)
    800010f0:	8b85                	andi	a5,a5,1
    800010f2:	ef81                	bnez	a5,8000110a <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010f4:	80b1                	srli	s1,s1,0xc
    800010f6:	04aa                	slli	s1,s1,0xa
    800010f8:	0164e4b3          	or	s1,s1,s6
    800010fc:	0014e493          	ori	s1,s1,1
    80001100:	e104                	sd	s1,0(a0)
    if(a == last)
    80001102:	03390863          	beq	s2,s3,80001132 <mappages+0x8a>
    a += PGSIZE;
    80001106:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001108:	bfc9                	j	800010da <mappages+0x32>
      panic("remap");
    8000110a:	00007517          	auipc	a0,0x7
    8000110e:	ffe50513          	addi	a0,a0,-2 # 80008108 <digits+0xc8>
    80001112:	fffff097          	auipc	ra,0xfffff
    80001116:	41c080e7          	jalr	1052(ra) # 8000052e <panic>
      return -1;
    8000111a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111c:	60a6                	ld	ra,72(sp)
    8000111e:	6406                	ld	s0,64(sp)
    80001120:	74e2                	ld	s1,56(sp)
    80001122:	7942                	ld	s2,48(sp)
    80001124:	79a2                	ld	s3,40(sp)
    80001126:	7a02                	ld	s4,32(sp)
    80001128:	6ae2                	ld	s5,24(sp)
    8000112a:	6b42                	ld	s6,16(sp)
    8000112c:	6ba2                	ld	s7,8(sp)
    8000112e:	6161                	addi	sp,sp,80
    80001130:	8082                	ret
  return 0;
    80001132:	4501                	li	a0,0
    80001134:	b7e5                	j	8000111c <mappages+0x74>

0000000080001136 <kvmmap>:
{
    80001136:	1141                	addi	sp,sp,-16
    80001138:	e406                	sd	ra,8(sp)
    8000113a:	e022                	sd	s0,0(sp)
    8000113c:	0800                	addi	s0,sp,16
    8000113e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001140:	86b2                	mv	a3,a2
    80001142:	863e                	mv	a2,a5
    80001144:	00000097          	auipc	ra,0x0
    80001148:	f64080e7          	jalr	-156(ra) # 800010a8 <mappages>
    8000114c:	e509                	bnez	a0,80001156 <kvmmap+0x20>
}
    8000114e:	60a2                	ld	ra,8(sp)
    80001150:	6402                	ld	s0,0(sp)
    80001152:	0141                	addi	sp,sp,16
    80001154:	8082                	ret
    panic("kvmmap");
    80001156:	00007517          	auipc	a0,0x7
    8000115a:	fba50513          	addi	a0,a0,-70 # 80008110 <digits+0xd0>
    8000115e:	fffff097          	auipc	ra,0xfffff
    80001162:	3d0080e7          	jalr	976(ra) # 8000052e <panic>

0000000080001166 <kvmmake>:
{
    80001166:	1101                	addi	sp,sp,-32
    80001168:	ec06                	sd	ra,24(sp)
    8000116a:	e822                	sd	s0,16(sp)
    8000116c:	e426                	sd	s1,8(sp)
    8000116e:	e04a                	sd	s2,0(sp)
    80001170:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001172:	00000097          	auipc	ra,0x0
    80001176:	964080e7          	jalr	-1692(ra) # 80000ad6 <kalloc>
    8000117a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117c:	6605                	lui	a2,0x1
    8000117e:	4581                	li	a1,0
    80001180:	00000097          	auipc	ra,0x0
    80001184:	b58080e7          	jalr	-1192(ra) # 80000cd8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001188:	4719                	li	a4,6
    8000118a:	6685                	lui	a3,0x1
    8000118c:	10000637          	lui	a2,0x10000
    80001190:	100005b7          	lui	a1,0x10000
    80001194:	8526                	mv	a0,s1
    80001196:	00000097          	auipc	ra,0x0
    8000119a:	fa0080e7          	jalr	-96(ra) # 80001136 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000119e:	4719                	li	a4,6
    800011a0:	6685                	lui	a3,0x1
    800011a2:	10001637          	lui	a2,0x10001
    800011a6:	100015b7          	lui	a1,0x10001
    800011aa:	8526                	mv	a0,s1
    800011ac:	00000097          	auipc	ra,0x0
    800011b0:	f8a080e7          	jalr	-118(ra) # 80001136 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b4:	4719                	li	a4,6
    800011b6:	004006b7          	lui	a3,0x400
    800011ba:	0c000637          	lui	a2,0xc000
    800011be:	0c0005b7          	lui	a1,0xc000
    800011c2:	8526                	mv	a0,s1
    800011c4:	00000097          	auipc	ra,0x0
    800011c8:	f72080e7          	jalr	-142(ra) # 80001136 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011cc:	00007917          	auipc	s2,0x7
    800011d0:	e3490913          	addi	s2,s2,-460 # 80008000 <etext>
    800011d4:	4729                	li	a4,10
    800011d6:	80007697          	auipc	a3,0x80007
    800011da:	e2a68693          	addi	a3,a3,-470 # 8000 <_entry-0x7fff8000>
    800011de:	4605                	li	a2,1
    800011e0:	067e                	slli	a2,a2,0x1f
    800011e2:	85b2                	mv	a1,a2
    800011e4:	8526                	mv	a0,s1
    800011e6:	00000097          	auipc	ra,0x0
    800011ea:	f50080e7          	jalr	-176(ra) # 80001136 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011ee:	4719                	li	a4,6
    800011f0:	46c5                	li	a3,17
    800011f2:	06ee                	slli	a3,a3,0x1b
    800011f4:	412686b3          	sub	a3,a3,s2
    800011f8:	864a                	mv	a2,s2
    800011fa:	85ca                	mv	a1,s2
    800011fc:	8526                	mv	a0,s1
    800011fe:	00000097          	auipc	ra,0x0
    80001202:	f38080e7          	jalr	-200(ra) # 80001136 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001206:	4729                	li	a4,10
    80001208:	6685                	lui	a3,0x1
    8000120a:	00006617          	auipc	a2,0x6
    8000120e:	df660613          	addi	a2,a2,-522 # 80007000 <_trampoline>
    80001212:	040005b7          	lui	a1,0x4000
    80001216:	15fd                	addi	a1,a1,-1
    80001218:	05b2                	slli	a1,a1,0xc
    8000121a:	8526                	mv	a0,s1
    8000121c:	00000097          	auipc	ra,0x0
    80001220:	f1a080e7          	jalr	-230(ra) # 80001136 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001224:	8526                	mv	a0,s1
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	600080e7          	jalr	1536(ra) # 80001826 <proc_mapstacks>
}
    8000122e:	8526                	mv	a0,s1
    80001230:	60e2                	ld	ra,24(sp)
    80001232:	6442                	ld	s0,16(sp)
    80001234:	64a2                	ld	s1,8(sp)
    80001236:	6902                	ld	s2,0(sp)
    80001238:	6105                	addi	sp,sp,32
    8000123a:	8082                	ret

000000008000123c <kvminit>:
{
    8000123c:	1141                	addi	sp,sp,-16
    8000123e:	e406                	sd	ra,8(sp)
    80001240:	e022                	sd	s0,0(sp)
    80001242:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001244:	00000097          	auipc	ra,0x0
    80001248:	f22080e7          	jalr	-222(ra) # 80001166 <kvmmake>
    8000124c:	00008797          	auipc	a5,0x8
    80001250:	dca7ba23          	sd	a0,-556(a5) # 80009020 <kernel_pagetable>
}
    80001254:	60a2                	ld	ra,8(sp)
    80001256:	6402                	ld	s0,0(sp)
    80001258:	0141                	addi	sp,sp,16
    8000125a:	8082                	ret

000000008000125c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125c:	715d                	addi	sp,sp,-80
    8000125e:	e486                	sd	ra,72(sp)
    80001260:	e0a2                	sd	s0,64(sp)
    80001262:	fc26                	sd	s1,56(sp)
    80001264:	f84a                	sd	s2,48(sp)
    80001266:	f44e                	sd	s3,40(sp)
    80001268:	f052                	sd	s4,32(sp)
    8000126a:	ec56                	sd	s5,24(sp)
    8000126c:	e85a                	sd	s6,16(sp)
    8000126e:	e45e                	sd	s7,8(sp)
    80001270:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001272:	03459793          	slli	a5,a1,0x34
    80001276:	e795                	bnez	a5,800012a2 <uvmunmap+0x46>
    80001278:	8a2a                	mv	s4,a0
    8000127a:	892e                	mv	s2,a1
    8000127c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000127e:	0632                	slli	a2,a2,0xc
    80001280:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001284:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	6b05                	lui	s6,0x1
    80001288:	0735e263          	bltu	a1,s3,800012ec <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128c:	60a6                	ld	ra,72(sp)
    8000128e:	6406                	ld	s0,64(sp)
    80001290:	74e2                	ld	s1,56(sp)
    80001292:	7942                	ld	s2,48(sp)
    80001294:	79a2                	ld	s3,40(sp)
    80001296:	7a02                	ld	s4,32(sp)
    80001298:	6ae2                	ld	s5,24(sp)
    8000129a:	6b42                	ld	s6,16(sp)
    8000129c:	6ba2                	ld	s7,8(sp)
    8000129e:	6161                	addi	sp,sp,80
    800012a0:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a2:	00007517          	auipc	a0,0x7
    800012a6:	e7650513          	addi	a0,a0,-394 # 80008118 <digits+0xd8>
    800012aa:	fffff097          	auipc	ra,0xfffff
    800012ae:	284080e7          	jalr	644(ra) # 8000052e <panic>
      panic("uvmunmap: walk");
    800012b2:	00007517          	auipc	a0,0x7
    800012b6:	e7e50513          	addi	a0,a0,-386 # 80008130 <digits+0xf0>
    800012ba:	fffff097          	auipc	ra,0xfffff
    800012be:	274080e7          	jalr	628(ra) # 8000052e <panic>
      panic("uvmunmap: not mapped");
    800012c2:	00007517          	auipc	a0,0x7
    800012c6:	e7e50513          	addi	a0,a0,-386 # 80008140 <digits+0x100>
    800012ca:	fffff097          	auipc	ra,0xfffff
    800012ce:	264080e7          	jalr	612(ra) # 8000052e <panic>
      panic("uvmunmap: not a leaf");
    800012d2:	00007517          	auipc	a0,0x7
    800012d6:	e8650513          	addi	a0,a0,-378 # 80008158 <digits+0x118>
    800012da:	fffff097          	auipc	ra,0xfffff
    800012de:	254080e7          	jalr	596(ra) # 8000052e <panic>
    *pte = 0;
    800012e2:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e6:	995a                	add	s2,s2,s6
    800012e8:	fb3972e3          	bgeu	s2,s3,8000128c <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012ec:	4601                	li	a2,0
    800012ee:	85ca                	mv	a1,s2
    800012f0:	8552                	mv	a0,s4
    800012f2:	00000097          	auipc	ra,0x0
    800012f6:	cce080e7          	jalr	-818(ra) # 80000fc0 <walk>
    800012fa:	84aa                	mv	s1,a0
    800012fc:	d95d                	beqz	a0,800012b2 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800012fe:	6108                	ld	a0,0(a0)
    80001300:	00157793          	andi	a5,a0,1
    80001304:	dfdd                	beqz	a5,800012c2 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001306:	3ff57793          	andi	a5,a0,1023
    8000130a:	fd7784e3          	beq	a5,s7,800012d2 <uvmunmap+0x76>
    if(do_free){
    8000130e:	fc0a8ae3          	beqz	s5,800012e2 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001312:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001314:	0532                	slli	a0,a0,0xc
    80001316:	fffff097          	auipc	ra,0xfffff
    8000131a:	6c4080e7          	jalr	1732(ra) # 800009da <kfree>
    8000131e:	b7d1                	j	800012e2 <uvmunmap+0x86>

0000000080001320 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001320:	1101                	addi	sp,sp,-32
    80001322:	ec06                	sd	ra,24(sp)
    80001324:	e822                	sd	s0,16(sp)
    80001326:	e426                	sd	s1,8(sp)
    80001328:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000132a:	fffff097          	auipc	ra,0xfffff
    8000132e:	7ac080e7          	jalr	1964(ra) # 80000ad6 <kalloc>
    80001332:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001334:	c519                	beqz	a0,80001342 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001336:	6605                	lui	a2,0x1
    80001338:	4581                	li	a1,0
    8000133a:	00000097          	auipc	ra,0x0
    8000133e:	99e080e7          	jalr	-1634(ra) # 80000cd8 <memset>
  return pagetable;
}
    80001342:	8526                	mv	a0,s1
    80001344:	60e2                	ld	ra,24(sp)
    80001346:	6442                	ld	s0,16(sp)
    80001348:	64a2                	ld	s1,8(sp)
    8000134a:	6105                	addi	sp,sp,32
    8000134c:	8082                	ret

000000008000134e <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    8000134e:	7179                	addi	sp,sp,-48
    80001350:	f406                	sd	ra,40(sp)
    80001352:	f022                	sd	s0,32(sp)
    80001354:	ec26                	sd	s1,24(sp)
    80001356:	e84a                	sd	s2,16(sp)
    80001358:	e44e                	sd	s3,8(sp)
    8000135a:	e052                	sd	s4,0(sp)
    8000135c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000135e:	6785                	lui	a5,0x1
    80001360:	04f67863          	bgeu	a2,a5,800013b0 <uvminit+0x62>
    80001364:	8a2a                	mv	s4,a0
    80001366:	89ae                	mv	s3,a1
    80001368:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000136a:	fffff097          	auipc	ra,0xfffff
    8000136e:	76c080e7          	jalr	1900(ra) # 80000ad6 <kalloc>
    80001372:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001374:	6605                	lui	a2,0x1
    80001376:	4581                	li	a1,0
    80001378:	00000097          	auipc	ra,0x0
    8000137c:	960080e7          	jalr	-1696(ra) # 80000cd8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001380:	4779                	li	a4,30
    80001382:	86ca                	mv	a3,s2
    80001384:	6605                	lui	a2,0x1
    80001386:	4581                	li	a1,0
    80001388:	8552                	mv	a0,s4
    8000138a:	00000097          	auipc	ra,0x0
    8000138e:	d1e080e7          	jalr	-738(ra) # 800010a8 <mappages>
  memmove(mem, src, sz);
    80001392:	8626                	mv	a2,s1
    80001394:	85ce                	mv	a1,s3
    80001396:	854a                	mv	a0,s2
    80001398:	00000097          	auipc	ra,0x0
    8000139c:	99c080e7          	jalr	-1636(ra) # 80000d34 <memmove>
}
    800013a0:	70a2                	ld	ra,40(sp)
    800013a2:	7402                	ld	s0,32(sp)
    800013a4:	64e2                	ld	s1,24(sp)
    800013a6:	6942                	ld	s2,16(sp)
    800013a8:	69a2                	ld	s3,8(sp)
    800013aa:	6a02                	ld	s4,0(sp)
    800013ac:	6145                	addi	sp,sp,48
    800013ae:	8082                	ret
    panic("inituvm: more than a page");
    800013b0:	00007517          	auipc	a0,0x7
    800013b4:	dc050513          	addi	a0,a0,-576 # 80008170 <digits+0x130>
    800013b8:	fffff097          	auipc	ra,0xfffff
    800013bc:	176080e7          	jalr	374(ra) # 8000052e <panic>

00000000800013c0 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c0:	1101                	addi	sp,sp,-32
    800013c2:	ec06                	sd	ra,24(sp)
    800013c4:	e822                	sd	s0,16(sp)
    800013c6:	e426                	sd	s1,8(sp)
    800013c8:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013ca:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013cc:	00b67d63          	bgeu	a2,a1,800013e6 <uvmdealloc+0x26>
    800013d0:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d2:	6785                	lui	a5,0x1
    800013d4:	17fd                	addi	a5,a5,-1
    800013d6:	00f60733          	add	a4,a2,a5
    800013da:	767d                	lui	a2,0xfffff
    800013dc:	8f71                	and	a4,a4,a2
    800013de:	97ae                	add	a5,a5,a1
    800013e0:	8ff1                	and	a5,a5,a2
    800013e2:	00f76863          	bltu	a4,a5,800013f2 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e6:	8526                	mv	a0,s1
    800013e8:	60e2                	ld	ra,24(sp)
    800013ea:	6442                	ld	s0,16(sp)
    800013ec:	64a2                	ld	s1,8(sp)
    800013ee:	6105                	addi	sp,sp,32
    800013f0:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f2:	8f99                	sub	a5,a5,a4
    800013f4:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f6:	4685                	li	a3,1
    800013f8:	0007861b          	sext.w	a2,a5
    800013fc:	85ba                	mv	a1,a4
    800013fe:	00000097          	auipc	ra,0x0
    80001402:	e5e080e7          	jalr	-418(ra) # 8000125c <uvmunmap>
    80001406:	b7c5                	j	800013e6 <uvmdealloc+0x26>

0000000080001408 <uvmalloc>:
  if(newsz < oldsz)
    80001408:	0ab66163          	bltu	a2,a1,800014aa <uvmalloc+0xa2>
{
    8000140c:	7139                	addi	sp,sp,-64
    8000140e:	fc06                	sd	ra,56(sp)
    80001410:	f822                	sd	s0,48(sp)
    80001412:	f426                	sd	s1,40(sp)
    80001414:	f04a                	sd	s2,32(sp)
    80001416:	ec4e                	sd	s3,24(sp)
    80001418:	e852                	sd	s4,16(sp)
    8000141a:	e456                	sd	s5,8(sp)
    8000141c:	0080                	addi	s0,sp,64
    8000141e:	8aaa                	mv	s5,a0
    80001420:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001422:	6985                	lui	s3,0x1
    80001424:	19fd                	addi	s3,s3,-1
    80001426:	95ce                	add	a1,a1,s3
    80001428:	79fd                	lui	s3,0xfffff
    8000142a:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000142e:	08c9f063          	bgeu	s3,a2,800014ae <uvmalloc+0xa6>
    80001432:	894e                	mv	s2,s3
    mem = kalloc();
    80001434:	fffff097          	auipc	ra,0xfffff
    80001438:	6a2080e7          	jalr	1698(ra) # 80000ad6 <kalloc>
    8000143c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000143e:	c51d                	beqz	a0,8000146c <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001440:	6605                	lui	a2,0x1
    80001442:	4581                	li	a1,0
    80001444:	00000097          	auipc	ra,0x0
    80001448:	894080e7          	jalr	-1900(ra) # 80000cd8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000144c:	4779                	li	a4,30
    8000144e:	86a6                	mv	a3,s1
    80001450:	6605                	lui	a2,0x1
    80001452:	85ca                	mv	a1,s2
    80001454:	8556                	mv	a0,s5
    80001456:	00000097          	auipc	ra,0x0
    8000145a:	c52080e7          	jalr	-942(ra) # 800010a8 <mappages>
    8000145e:	e905                	bnez	a0,8000148e <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001460:	6785                	lui	a5,0x1
    80001462:	993e                	add	s2,s2,a5
    80001464:	fd4968e3          	bltu	s2,s4,80001434 <uvmalloc+0x2c>
  return newsz;
    80001468:	8552                	mv	a0,s4
    8000146a:	a809                	j	8000147c <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000146c:	864e                	mv	a2,s3
    8000146e:	85ca                	mv	a1,s2
    80001470:	8556                	mv	a0,s5
    80001472:	00000097          	auipc	ra,0x0
    80001476:	f4e080e7          	jalr	-178(ra) # 800013c0 <uvmdealloc>
      return 0;
    8000147a:	4501                	li	a0,0
}
    8000147c:	70e2                	ld	ra,56(sp)
    8000147e:	7442                	ld	s0,48(sp)
    80001480:	74a2                	ld	s1,40(sp)
    80001482:	7902                	ld	s2,32(sp)
    80001484:	69e2                	ld	s3,24(sp)
    80001486:	6a42                	ld	s4,16(sp)
    80001488:	6aa2                	ld	s5,8(sp)
    8000148a:	6121                	addi	sp,sp,64
    8000148c:	8082                	ret
      kfree(mem);
    8000148e:	8526                	mv	a0,s1
    80001490:	fffff097          	auipc	ra,0xfffff
    80001494:	54a080e7          	jalr	1354(ra) # 800009da <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001498:	864e                	mv	a2,s3
    8000149a:	85ca                	mv	a1,s2
    8000149c:	8556                	mv	a0,s5
    8000149e:	00000097          	auipc	ra,0x0
    800014a2:	f22080e7          	jalr	-222(ra) # 800013c0 <uvmdealloc>
      return 0;
    800014a6:	4501                	li	a0,0
    800014a8:	bfd1                	j	8000147c <uvmalloc+0x74>
    return oldsz;
    800014aa:	852e                	mv	a0,a1
}
    800014ac:	8082                	ret
  return newsz;
    800014ae:	8532                	mv	a0,a2
    800014b0:	b7f1                	j	8000147c <uvmalloc+0x74>

00000000800014b2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014b2:	7179                	addi	sp,sp,-48
    800014b4:	f406                	sd	ra,40(sp)
    800014b6:	f022                	sd	s0,32(sp)
    800014b8:	ec26                	sd	s1,24(sp)
    800014ba:	e84a                	sd	s2,16(sp)
    800014bc:	e44e                	sd	s3,8(sp)
    800014be:	e052                	sd	s4,0(sp)
    800014c0:	1800                	addi	s0,sp,48
    800014c2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014c4:	84aa                	mv	s1,a0
    800014c6:	6905                	lui	s2,0x1
    800014c8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014ca:	4985                	li	s3,1
    800014cc:	a821                	j	800014e4 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014ce:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014d0:	0532                	slli	a0,a0,0xc
    800014d2:	00000097          	auipc	ra,0x0
    800014d6:	fe0080e7          	jalr	-32(ra) # 800014b2 <freewalk>
      pagetable[i] = 0;
    800014da:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014de:	04a1                	addi	s1,s1,8
    800014e0:	03248163          	beq	s1,s2,80001502 <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014e4:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e6:	00f57793          	andi	a5,a0,15
    800014ea:	ff3782e3          	beq	a5,s3,800014ce <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014ee:	8905                	andi	a0,a0,1
    800014f0:	d57d                	beqz	a0,800014de <freewalk+0x2c>
      panic("freewalk: leaf");
    800014f2:	00007517          	auipc	a0,0x7
    800014f6:	c9e50513          	addi	a0,a0,-866 # 80008190 <digits+0x150>
    800014fa:	fffff097          	auipc	ra,0xfffff
    800014fe:	034080e7          	jalr	52(ra) # 8000052e <panic>
    }
  }
  kfree((void*)pagetable);
    80001502:	8552                	mv	a0,s4
    80001504:	fffff097          	auipc	ra,0xfffff
    80001508:	4d6080e7          	jalr	1238(ra) # 800009da <kfree>
}
    8000150c:	70a2                	ld	ra,40(sp)
    8000150e:	7402                	ld	s0,32(sp)
    80001510:	64e2                	ld	s1,24(sp)
    80001512:	6942                	ld	s2,16(sp)
    80001514:	69a2                	ld	s3,8(sp)
    80001516:	6a02                	ld	s4,0(sp)
    80001518:	6145                	addi	sp,sp,48
    8000151a:	8082                	ret

000000008000151c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000151c:	1101                	addi	sp,sp,-32
    8000151e:	ec06                	sd	ra,24(sp)
    80001520:	e822                	sd	s0,16(sp)
    80001522:	e426                	sd	s1,8(sp)
    80001524:	1000                	addi	s0,sp,32
    80001526:	84aa                	mv	s1,a0
  if(sz > 0)
    80001528:	e999                	bnez	a1,8000153e <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000152a:	8526                	mv	a0,s1
    8000152c:	00000097          	auipc	ra,0x0
    80001530:	f86080e7          	jalr	-122(ra) # 800014b2 <freewalk>
}
    80001534:	60e2                	ld	ra,24(sp)
    80001536:	6442                	ld	s0,16(sp)
    80001538:	64a2                	ld	s1,8(sp)
    8000153a:	6105                	addi	sp,sp,32
    8000153c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000153e:	6605                	lui	a2,0x1
    80001540:	167d                	addi	a2,a2,-1
    80001542:	962e                	add	a2,a2,a1
    80001544:	4685                	li	a3,1
    80001546:	8231                	srli	a2,a2,0xc
    80001548:	4581                	li	a1,0
    8000154a:	00000097          	auipc	ra,0x0
    8000154e:	d12080e7          	jalr	-750(ra) # 8000125c <uvmunmap>
    80001552:	bfe1                	j	8000152a <uvmfree+0xe>

0000000080001554 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001554:	c679                	beqz	a2,80001622 <uvmcopy+0xce>
{
    80001556:	715d                	addi	sp,sp,-80
    80001558:	e486                	sd	ra,72(sp)
    8000155a:	e0a2                	sd	s0,64(sp)
    8000155c:	fc26                	sd	s1,56(sp)
    8000155e:	f84a                	sd	s2,48(sp)
    80001560:	f44e                	sd	s3,40(sp)
    80001562:	f052                	sd	s4,32(sp)
    80001564:	ec56                	sd	s5,24(sp)
    80001566:	e85a                	sd	s6,16(sp)
    80001568:	e45e                	sd	s7,8(sp)
    8000156a:	0880                	addi	s0,sp,80
    8000156c:	8b2a                	mv	s6,a0
    8000156e:	8aae                	mv	s5,a1
    80001570:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001572:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001574:	4601                	li	a2,0
    80001576:	85ce                	mv	a1,s3
    80001578:	855a                	mv	a0,s6
    8000157a:	00000097          	auipc	ra,0x0
    8000157e:	a46080e7          	jalr	-1466(ra) # 80000fc0 <walk>
    80001582:	c531                	beqz	a0,800015ce <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001584:	6118                	ld	a4,0(a0)
    80001586:	00177793          	andi	a5,a4,1
    8000158a:	cbb1                	beqz	a5,800015de <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000158c:	00a75593          	srli	a1,a4,0xa
    80001590:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001594:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001598:	fffff097          	auipc	ra,0xfffff
    8000159c:	53e080e7          	jalr	1342(ra) # 80000ad6 <kalloc>
    800015a0:	892a                	mv	s2,a0
    800015a2:	c939                	beqz	a0,800015f8 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015a4:	6605                	lui	a2,0x1
    800015a6:	85de                	mv	a1,s7
    800015a8:	fffff097          	auipc	ra,0xfffff
    800015ac:	78c080e7          	jalr	1932(ra) # 80000d34 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015b0:	8726                	mv	a4,s1
    800015b2:	86ca                	mv	a3,s2
    800015b4:	6605                	lui	a2,0x1
    800015b6:	85ce                	mv	a1,s3
    800015b8:	8556                	mv	a0,s5
    800015ba:	00000097          	auipc	ra,0x0
    800015be:	aee080e7          	jalr	-1298(ra) # 800010a8 <mappages>
    800015c2:	e515                	bnez	a0,800015ee <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015c4:	6785                	lui	a5,0x1
    800015c6:	99be                	add	s3,s3,a5
    800015c8:	fb49e6e3          	bltu	s3,s4,80001574 <uvmcopy+0x20>
    800015cc:	a081                	j	8000160c <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015ce:	00007517          	auipc	a0,0x7
    800015d2:	bd250513          	addi	a0,a0,-1070 # 800081a0 <digits+0x160>
    800015d6:	fffff097          	auipc	ra,0xfffff
    800015da:	f58080e7          	jalr	-168(ra) # 8000052e <panic>
      panic("uvmcopy: page not present");
    800015de:	00007517          	auipc	a0,0x7
    800015e2:	be250513          	addi	a0,a0,-1054 # 800081c0 <digits+0x180>
    800015e6:	fffff097          	auipc	ra,0xfffff
    800015ea:	f48080e7          	jalr	-184(ra) # 8000052e <panic>
      kfree(mem);
    800015ee:	854a                	mv	a0,s2
    800015f0:	fffff097          	auipc	ra,0xfffff
    800015f4:	3ea080e7          	jalr	1002(ra) # 800009da <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015f8:	4685                	li	a3,1
    800015fa:	00c9d613          	srli	a2,s3,0xc
    800015fe:	4581                	li	a1,0
    80001600:	8556                	mv	a0,s5
    80001602:	00000097          	auipc	ra,0x0
    80001606:	c5a080e7          	jalr	-934(ra) # 8000125c <uvmunmap>
  return -1;
    8000160a:	557d                	li	a0,-1
}
    8000160c:	60a6                	ld	ra,72(sp)
    8000160e:	6406                	ld	s0,64(sp)
    80001610:	74e2                	ld	s1,56(sp)
    80001612:	7942                	ld	s2,48(sp)
    80001614:	79a2                	ld	s3,40(sp)
    80001616:	7a02                	ld	s4,32(sp)
    80001618:	6ae2                	ld	s5,24(sp)
    8000161a:	6b42                	ld	s6,16(sp)
    8000161c:	6ba2                	ld	s7,8(sp)
    8000161e:	6161                	addi	sp,sp,80
    80001620:	8082                	ret
  return 0;
    80001622:	4501                	li	a0,0
}
    80001624:	8082                	ret

0000000080001626 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001626:	1141                	addi	sp,sp,-16
    80001628:	e406                	sd	ra,8(sp)
    8000162a:	e022                	sd	s0,0(sp)
    8000162c:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000162e:	4601                	li	a2,0
    80001630:	00000097          	auipc	ra,0x0
    80001634:	990080e7          	jalr	-1648(ra) # 80000fc0 <walk>
  if(pte == 0)
    80001638:	c901                	beqz	a0,80001648 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000163a:	611c                	ld	a5,0(a0)
    8000163c:	9bbd                	andi	a5,a5,-17
    8000163e:	e11c                	sd	a5,0(a0)
}
    80001640:	60a2                	ld	ra,8(sp)
    80001642:	6402                	ld	s0,0(sp)
    80001644:	0141                	addi	sp,sp,16
    80001646:	8082                	ret
    panic("uvmclear");
    80001648:	00007517          	auipc	a0,0x7
    8000164c:	b9850513          	addi	a0,a0,-1128 # 800081e0 <digits+0x1a0>
    80001650:	fffff097          	auipc	ra,0xfffff
    80001654:	ede080e7          	jalr	-290(ra) # 8000052e <panic>

0000000080001658 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001658:	c6bd                	beqz	a3,800016c6 <copyout+0x6e>
{
    8000165a:	715d                	addi	sp,sp,-80
    8000165c:	e486                	sd	ra,72(sp)
    8000165e:	e0a2                	sd	s0,64(sp)
    80001660:	fc26                	sd	s1,56(sp)
    80001662:	f84a                	sd	s2,48(sp)
    80001664:	f44e                	sd	s3,40(sp)
    80001666:	f052                	sd	s4,32(sp)
    80001668:	ec56                	sd	s5,24(sp)
    8000166a:	e85a                	sd	s6,16(sp)
    8000166c:	e45e                	sd	s7,8(sp)
    8000166e:	e062                	sd	s8,0(sp)
    80001670:	0880                	addi	s0,sp,80
    80001672:	8b2a                	mv	s6,a0
    80001674:	8c2e                	mv	s8,a1
    80001676:	8a32                	mv	s4,a2
    80001678:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000167a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000167c:	6a85                	lui	s5,0x1
    8000167e:	a015                	j	800016a2 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001680:	9562                	add	a0,a0,s8
    80001682:	0004861b          	sext.w	a2,s1
    80001686:	85d2                	mv	a1,s4
    80001688:	41250533          	sub	a0,a0,s2
    8000168c:	fffff097          	auipc	ra,0xfffff
    80001690:	6a8080e7          	jalr	1704(ra) # 80000d34 <memmove>

    len -= n;
    80001694:	409989b3          	sub	s3,s3,s1
    src += n;
    80001698:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000169a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000169e:	02098263          	beqz	s3,800016c2 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016a2:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016a6:	85ca                	mv	a1,s2
    800016a8:	855a                	mv	a0,s6
    800016aa:	00000097          	auipc	ra,0x0
    800016ae:	9bc080e7          	jalr	-1604(ra) # 80001066 <walkaddr>
    if(pa0 == 0)
    800016b2:	cd01                	beqz	a0,800016ca <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016b4:	418904b3          	sub	s1,s2,s8
    800016b8:	94d6                	add	s1,s1,s5
    if(n > len)
    800016ba:	fc99f3e3          	bgeu	s3,s1,80001680 <copyout+0x28>
    800016be:	84ce                	mv	s1,s3
    800016c0:	b7c1                	j	80001680 <copyout+0x28>
  }
  return 0;
    800016c2:	4501                	li	a0,0
    800016c4:	a021                	j	800016cc <copyout+0x74>
    800016c6:	4501                	li	a0,0
}
    800016c8:	8082                	ret
      return -1;
    800016ca:	557d                	li	a0,-1
}
    800016cc:	60a6                	ld	ra,72(sp)
    800016ce:	6406                	ld	s0,64(sp)
    800016d0:	74e2                	ld	s1,56(sp)
    800016d2:	7942                	ld	s2,48(sp)
    800016d4:	79a2                	ld	s3,40(sp)
    800016d6:	7a02                	ld	s4,32(sp)
    800016d8:	6ae2                	ld	s5,24(sp)
    800016da:	6b42                	ld	s6,16(sp)
    800016dc:	6ba2                	ld	s7,8(sp)
    800016de:	6c02                	ld	s8,0(sp)
    800016e0:	6161                	addi	sp,sp,80
    800016e2:	8082                	ret

00000000800016e4 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016e4:	caa5                	beqz	a3,80001754 <copyin+0x70>
{
    800016e6:	715d                	addi	sp,sp,-80
    800016e8:	e486                	sd	ra,72(sp)
    800016ea:	e0a2                	sd	s0,64(sp)
    800016ec:	fc26                	sd	s1,56(sp)
    800016ee:	f84a                	sd	s2,48(sp)
    800016f0:	f44e                	sd	s3,40(sp)
    800016f2:	f052                	sd	s4,32(sp)
    800016f4:	ec56                	sd	s5,24(sp)
    800016f6:	e85a                	sd	s6,16(sp)
    800016f8:	e45e                	sd	s7,8(sp)
    800016fa:	e062                	sd	s8,0(sp)
    800016fc:	0880                	addi	s0,sp,80
    800016fe:	8b2a                	mv	s6,a0
    80001700:	8a2e                	mv	s4,a1
    80001702:	8c32                	mv	s8,a2
    80001704:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001706:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001708:	6a85                	lui	s5,0x1
    8000170a:	a01d                	j	80001730 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000170c:	018505b3          	add	a1,a0,s8
    80001710:	0004861b          	sext.w	a2,s1
    80001714:	412585b3          	sub	a1,a1,s2
    80001718:	8552                	mv	a0,s4
    8000171a:	fffff097          	auipc	ra,0xfffff
    8000171e:	61a080e7          	jalr	1562(ra) # 80000d34 <memmove>

    len -= n;
    80001722:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001726:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001728:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000172c:	02098263          	beqz	s3,80001750 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001730:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001734:	85ca                	mv	a1,s2
    80001736:	855a                	mv	a0,s6
    80001738:	00000097          	auipc	ra,0x0
    8000173c:	92e080e7          	jalr	-1746(ra) # 80001066 <walkaddr>
    if(pa0 == 0)
    80001740:	cd01                	beqz	a0,80001758 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001742:	418904b3          	sub	s1,s2,s8
    80001746:	94d6                	add	s1,s1,s5
    if(n > len)
    80001748:	fc99f2e3          	bgeu	s3,s1,8000170c <copyin+0x28>
    8000174c:	84ce                	mv	s1,s3
    8000174e:	bf7d                	j	8000170c <copyin+0x28>
  }
  return 0;
    80001750:	4501                	li	a0,0
    80001752:	a021                	j	8000175a <copyin+0x76>
    80001754:	4501                	li	a0,0
}
    80001756:	8082                	ret
      return -1;
    80001758:	557d                	li	a0,-1
}
    8000175a:	60a6                	ld	ra,72(sp)
    8000175c:	6406                	ld	s0,64(sp)
    8000175e:	74e2                	ld	s1,56(sp)
    80001760:	7942                	ld	s2,48(sp)
    80001762:	79a2                	ld	s3,40(sp)
    80001764:	7a02                	ld	s4,32(sp)
    80001766:	6ae2                	ld	s5,24(sp)
    80001768:	6b42                	ld	s6,16(sp)
    8000176a:	6ba2                	ld	s7,8(sp)
    8000176c:	6c02                	ld	s8,0(sp)
    8000176e:	6161                	addi	sp,sp,80
    80001770:	8082                	ret

0000000080001772 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001772:	c6c5                	beqz	a3,8000181a <copyinstr+0xa8>
{
    80001774:	715d                	addi	sp,sp,-80
    80001776:	e486                	sd	ra,72(sp)
    80001778:	e0a2                	sd	s0,64(sp)
    8000177a:	fc26                	sd	s1,56(sp)
    8000177c:	f84a                	sd	s2,48(sp)
    8000177e:	f44e                	sd	s3,40(sp)
    80001780:	f052                	sd	s4,32(sp)
    80001782:	ec56                	sd	s5,24(sp)
    80001784:	e85a                	sd	s6,16(sp)
    80001786:	e45e                	sd	s7,8(sp)
    80001788:	0880                	addi	s0,sp,80
    8000178a:	8a2a                	mv	s4,a0
    8000178c:	8b2e                	mv	s6,a1
    8000178e:	8bb2                	mv	s7,a2
    80001790:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001792:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001794:	6985                	lui	s3,0x1
    80001796:	a035                	j	800017c2 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001798:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000179c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000179e:	0017b793          	seqz	a5,a5
    800017a2:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017a6:	60a6                	ld	ra,72(sp)
    800017a8:	6406                	ld	s0,64(sp)
    800017aa:	74e2                	ld	s1,56(sp)
    800017ac:	7942                	ld	s2,48(sp)
    800017ae:	79a2                	ld	s3,40(sp)
    800017b0:	7a02                	ld	s4,32(sp)
    800017b2:	6ae2                	ld	s5,24(sp)
    800017b4:	6b42                	ld	s6,16(sp)
    800017b6:	6ba2                	ld	s7,8(sp)
    800017b8:	6161                	addi	sp,sp,80
    800017ba:	8082                	ret
    srcva = va0 + PGSIZE;
    800017bc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017c0:	c8a9                	beqz	s1,80001812 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017c2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017c6:	85ca                	mv	a1,s2
    800017c8:	8552                	mv	a0,s4
    800017ca:	00000097          	auipc	ra,0x0
    800017ce:	89c080e7          	jalr	-1892(ra) # 80001066 <walkaddr>
    if(pa0 == 0)
    800017d2:	c131                	beqz	a0,80001816 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017d4:	41790833          	sub	a6,s2,s7
    800017d8:	984e                	add	a6,a6,s3
    if(n > max)
    800017da:	0104f363          	bgeu	s1,a6,800017e0 <copyinstr+0x6e>
    800017de:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017e0:	955e                	add	a0,a0,s7
    800017e2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017e6:	fc080be3          	beqz	a6,800017bc <copyinstr+0x4a>
    800017ea:	985a                	add	a6,a6,s6
    800017ec:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017ee:	41650633          	sub	a2,a0,s6
    800017f2:	14fd                	addi	s1,s1,-1
    800017f4:	9b26                	add	s6,s6,s1
    800017f6:	00f60733          	add	a4,a2,a5
    800017fa:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd1000>
    800017fe:	df49                	beqz	a4,80001798 <copyinstr+0x26>
        *dst = *p;
    80001800:	00e78023          	sb	a4,0(a5)
      --max;
    80001804:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001808:	0785                	addi	a5,a5,1
    while(n > 0){
    8000180a:	ff0796e3          	bne	a5,a6,800017f6 <copyinstr+0x84>
      dst++;
    8000180e:	8b42                	mv	s6,a6
    80001810:	b775                	j	800017bc <copyinstr+0x4a>
    80001812:	4781                	li	a5,0
    80001814:	b769                	j	8000179e <copyinstr+0x2c>
      return -1;
    80001816:	557d                	li	a0,-1
    80001818:	b779                	j	800017a6 <copyinstr+0x34>
  int got_null = 0;
    8000181a:	4781                	li	a5,0
  if(got_null){
    8000181c:	0017b793          	seqz	a5,a5
    80001820:	40f00533          	neg	a0,a5
}
    80001824:	8082                	ret

0000000080001826 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    80001826:	7139                	addi	sp,sp,-64
    80001828:	fc06                	sd	ra,56(sp)
    8000182a:	f822                	sd	s0,48(sp)
    8000182c:	f426                	sd	s1,40(sp)
    8000182e:	f04a                	sd	s2,32(sp)
    80001830:	ec4e                	sd	s3,24(sp)
    80001832:	e852                	sd	s4,16(sp)
    80001834:	e456                	sd	s5,8(sp)
    80001836:	e05a                	sd	s6,0(sp)
    80001838:	0080                	addi	s0,sp,64
    8000183a:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183c:	00010497          	auipc	s1,0x10
    80001840:	e9448493          	addi	s1,s1,-364 # 800116d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001844:	8b26                	mv	s6,s1
    80001846:	00006a97          	auipc	s5,0x6
    8000184a:	7baa8a93          	addi	s5,s5,1978 # 80008000 <etext>
    8000184e:	04000937          	lui	s2,0x4000
    80001852:	197d                	addi	s2,s2,-1
    80001854:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001856:	0001ea17          	auipc	s4,0x1e
    8000185a:	e7aa0a13          	addi	s4,s4,-390 # 8001f6d0 <tickslock>
    char *pa = kalloc();
    8000185e:	fffff097          	auipc	ra,0xfffff
    80001862:	278080e7          	jalr	632(ra) # 80000ad6 <kalloc>
    80001866:	862a                	mv	a2,a0
    if(pa == 0)
    80001868:	c131                	beqz	a0,800018ac <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000186a:	416485b3          	sub	a1,s1,s6
    8000186e:	859d                	srai	a1,a1,0x7
    80001870:	000ab783          	ld	a5,0(s5)
    80001874:	02f585b3          	mul	a1,a1,a5
    80001878:	2585                	addiw	a1,a1,1
    8000187a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000187e:	4719                	li	a4,6
    80001880:	6685                	lui	a3,0x1
    80001882:	40b905b3          	sub	a1,s2,a1
    80001886:	854e                	mv	a0,s3
    80001888:	00000097          	auipc	ra,0x0
    8000188c:	8ae080e7          	jalr	-1874(ra) # 80001136 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001890:	38048493          	addi	s1,s1,896
    80001894:	fd4495e3          	bne	s1,s4,8000185e <proc_mapstacks+0x38>
  }
}
    80001898:	70e2                	ld	ra,56(sp)
    8000189a:	7442                	ld	s0,48(sp)
    8000189c:	74a2                	ld	s1,40(sp)
    8000189e:	7902                	ld	s2,32(sp)
    800018a0:	69e2                	ld	s3,24(sp)
    800018a2:	6a42                	ld	s4,16(sp)
    800018a4:	6aa2                	ld	s5,8(sp)
    800018a6:	6b02                	ld	s6,0(sp)
    800018a8:	6121                	addi	sp,sp,64
    800018aa:	8082                	ret
      panic("kalloc");
    800018ac:	00007517          	auipc	a0,0x7
    800018b0:	94450513          	addi	a0,a0,-1724 # 800081f0 <digits+0x1b0>
    800018b4:	fffff097          	auipc	ra,0xfffff
    800018b8:	c7a080e7          	jalr	-902(ra) # 8000052e <panic>

00000000800018bc <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    800018bc:	7139                	addi	sp,sp,-64
    800018be:	fc06                	sd	ra,56(sp)
    800018c0:	f822                	sd	s0,48(sp)
    800018c2:	f426                	sd	s1,40(sp)
    800018c4:	f04a                	sd	s2,32(sp)
    800018c6:	ec4e                	sd	s3,24(sp)
    800018c8:	e852                	sd	s4,16(sp)
    800018ca:	e456                	sd	s5,8(sp)
    800018cc:	e05a                	sd	s6,0(sp)
    800018ce:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018d0:	00007597          	auipc	a1,0x7
    800018d4:	92858593          	addi	a1,a1,-1752 # 800081f8 <digits+0x1b8>
    800018d8:	00010517          	auipc	a0,0x10
    800018dc:	9c850513          	addi	a0,a0,-1592 # 800112a0 <pid_lock>
    800018e0:	fffff097          	auipc	ra,0xfffff
    800018e4:	256080e7          	jalr	598(ra) # 80000b36 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018e8:	00007597          	auipc	a1,0x7
    800018ec:	91858593          	addi	a1,a1,-1768 # 80008200 <digits+0x1c0>
    800018f0:	00010517          	auipc	a0,0x10
    800018f4:	9c850513          	addi	a0,a0,-1592 # 800112b8 <wait_lock>
    800018f8:	fffff097          	auipc	ra,0xfffff
    800018fc:	23e080e7          	jalr	574(ra) # 80000b36 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001900:	00010497          	auipc	s1,0x10
    80001904:	dd048493          	addi	s1,s1,-560 # 800116d0 <proc>
      initlock(&p->lock, "proc");
    80001908:	00007b17          	auipc	s6,0x7
    8000190c:	908b0b13          	addi	s6,s6,-1784 # 80008210 <digits+0x1d0>
      p->kstack = KSTACK((int) (p - proc));
    80001910:	8aa6                	mv	s5,s1
    80001912:	00006a17          	auipc	s4,0x6
    80001916:	6eea0a13          	addi	s4,s4,1774 # 80008000 <etext>
    8000191a:	04000937          	lui	s2,0x4000
    8000191e:	197d                	addi	s2,s2,-1
    80001920:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001922:	0001e997          	auipc	s3,0x1e
    80001926:	dae98993          	addi	s3,s3,-594 # 8001f6d0 <tickslock>
      initlock(&p->lock, "proc");
    8000192a:	85da                	mv	a1,s6
    8000192c:	8526                	mv	a0,s1
    8000192e:	fffff097          	auipc	ra,0xfffff
    80001932:	208080e7          	jalr	520(ra) # 80000b36 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001936:	415487b3          	sub	a5,s1,s5
    8000193a:	879d                	srai	a5,a5,0x7
    8000193c:	000a3703          	ld	a4,0(s4)
    80001940:	02e787b3          	mul	a5,a5,a4
    80001944:	2785                	addiw	a5,a5,1
    80001946:	00d7979b          	slliw	a5,a5,0xd
    8000194a:	40f907b3          	sub	a5,s2,a5
    8000194e:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001950:	38048493          	addi	s1,s1,896
    80001954:	fd349be3          	bne	s1,s3,8000192a <procinit+0x6e>
  }
}
    80001958:	70e2                	ld	ra,56(sp)
    8000195a:	7442                	ld	s0,48(sp)
    8000195c:	74a2                	ld	s1,40(sp)
    8000195e:	7902                	ld	s2,32(sp)
    80001960:	69e2                	ld	s3,24(sp)
    80001962:	6a42                	ld	s4,16(sp)
    80001964:	6aa2                	ld	s5,8(sp)
    80001966:	6b02                	ld	s6,0(sp)
    80001968:	6121                	addi	sp,sp,64
    8000196a:	8082                	ret

000000008000196c <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000196c:	1141                	addi	sp,sp,-16
    8000196e:	e422                	sd	s0,8(sp)
    80001970:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001972:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001974:	2501                	sext.w	a0,a0
    80001976:	6422                	ld	s0,8(sp)
    80001978:	0141                	addi	sp,sp,16
    8000197a:	8082                	ret

000000008000197c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    8000197c:	1141                	addi	sp,sp,-16
    8000197e:	e422                	sd	s0,8(sp)
    80001980:	0800                	addi	s0,sp,16
    80001982:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001984:	2781                	sext.w	a5,a5
    80001986:	079e                	slli	a5,a5,0x7
  return c;
}
    80001988:	00010517          	auipc	a0,0x10
    8000198c:	94850513          	addi	a0,a0,-1720 # 800112d0 <cpus>
    80001990:	953e                	add	a0,a0,a5
    80001992:	6422                	ld	s0,8(sp)
    80001994:	0141                	addi	sp,sp,16
    80001996:	8082                	ret

0000000080001998 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001998:	1101                	addi	sp,sp,-32
    8000199a:	ec06                	sd	ra,24(sp)
    8000199c:	e822                	sd	s0,16(sp)
    8000199e:	e426                	sd	s1,8(sp)
    800019a0:	1000                	addi	s0,sp,32
  push_off();
    800019a2:	fffff097          	auipc	ra,0xfffff
    800019a6:	1d8080e7          	jalr	472(ra) # 80000b7a <push_off>
    800019aa:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019ac:	2781                	sext.w	a5,a5
    800019ae:	079e                	slli	a5,a5,0x7
    800019b0:	00010717          	auipc	a4,0x10
    800019b4:	8f070713          	addi	a4,a4,-1808 # 800112a0 <pid_lock>
    800019b8:	97ba                	add	a5,a5,a4
    800019ba:	7b84                	ld	s1,48(a5)
  pop_off();
    800019bc:	fffff097          	auipc	ra,0xfffff
    800019c0:	274080e7          	jalr	628(ra) # 80000c30 <pop_off>
  return p;
}
    800019c4:	8526                	mv	a0,s1
    800019c6:	60e2                	ld	ra,24(sp)
    800019c8:	6442                	ld	s0,16(sp)
    800019ca:	64a2                	ld	s1,8(sp)
    800019cc:	6105                	addi	sp,sp,32
    800019ce:	8082                	ret

00000000800019d0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019d0:	1141                	addi	sp,sp,-16
    800019d2:	e406                	sd	ra,8(sp)
    800019d4:	e022                	sd	s0,0(sp)
    800019d6:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019d8:	00000097          	auipc	ra,0x0
    800019dc:	fc0080e7          	jalr	-64(ra) # 80001998 <myproc>
    800019e0:	fffff097          	auipc	ra,0xfffff
    800019e4:	2b0080e7          	jalr	688(ra) # 80000c90 <release>

  if (first) {
    800019e8:	00007797          	auipc	a5,0x7
    800019ec:	e787a783          	lw	a5,-392(a5) # 80008860 <first.1>
    800019f0:	eb89                	bnez	a5,80001a02 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    800019f2:	00001097          	auipc	ra,0x1
    800019f6:	ee8080e7          	jalr	-280(ra) # 800028da <usertrapret>
}
    800019fa:	60a2                	ld	ra,8(sp)
    800019fc:	6402                	ld	s0,0(sp)
    800019fe:	0141                	addi	sp,sp,16
    80001a00:	8082                	ret
    first = 0;
    80001a02:	00007797          	auipc	a5,0x7
    80001a06:	e407af23          	sw	zero,-418(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    80001a0a:	4505                	li	a0,1
    80001a0c:	00002097          	auipc	ra,0x2
    80001a10:	de8080e7          	jalr	-536(ra) # 800037f4 <fsinit>
    80001a14:	bff9                	j	800019f2 <forkret+0x22>

0000000080001a16 <allocpid>:
allocpid() {
    80001a16:	1101                	addi	sp,sp,-32
    80001a18:	ec06                	sd	ra,24(sp)
    80001a1a:	e822                	sd	s0,16(sp)
    80001a1c:	e426                	sd	s1,8(sp)
    80001a1e:	e04a                	sd	s2,0(sp)
    80001a20:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a22:	00010917          	auipc	s2,0x10
    80001a26:	87e90913          	addi	s2,s2,-1922 # 800112a0 <pid_lock>
    80001a2a:	854a                	mv	a0,s2
    80001a2c:	fffff097          	auipc	ra,0xfffff
    80001a30:	19a080e7          	jalr	410(ra) # 80000bc6 <acquire>
  pid = nextpid;
    80001a34:	00007797          	auipc	a5,0x7
    80001a38:	e3078793          	addi	a5,a5,-464 # 80008864 <nextpid>
    80001a3c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a3e:	0014871b          	addiw	a4,s1,1
    80001a42:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a44:	854a                	mv	a0,s2
    80001a46:	fffff097          	auipc	ra,0xfffff
    80001a4a:	24a080e7          	jalr	586(ra) # 80000c90 <release>
}
    80001a4e:	8526                	mv	a0,s1
    80001a50:	60e2                	ld	ra,24(sp)
    80001a52:	6442                	ld	s0,16(sp)
    80001a54:	64a2                	ld	s1,8(sp)
    80001a56:	6902                	ld	s2,0(sp)
    80001a58:	6105                	addi	sp,sp,32
    80001a5a:	8082                	ret

0000000080001a5c <proc_pagetable>:
{
    80001a5c:	1101                	addi	sp,sp,-32
    80001a5e:	ec06                	sd	ra,24(sp)
    80001a60:	e822                	sd	s0,16(sp)
    80001a62:	e426                	sd	s1,8(sp)
    80001a64:	e04a                	sd	s2,0(sp)
    80001a66:	1000                	addi	s0,sp,32
    80001a68:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a6a:	00000097          	auipc	ra,0x0
    80001a6e:	8b6080e7          	jalr	-1866(ra) # 80001320 <uvmcreate>
    80001a72:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a74:	c121                	beqz	a0,80001ab4 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a76:	4729                	li	a4,10
    80001a78:	00005697          	auipc	a3,0x5
    80001a7c:	58868693          	addi	a3,a3,1416 # 80007000 <_trampoline>
    80001a80:	6605                	lui	a2,0x1
    80001a82:	040005b7          	lui	a1,0x4000
    80001a86:	15fd                	addi	a1,a1,-1
    80001a88:	05b2                	slli	a1,a1,0xc
    80001a8a:	fffff097          	auipc	ra,0xfffff
    80001a8e:	61e080e7          	jalr	1566(ra) # 800010a8 <mappages>
    80001a92:	02054863          	bltz	a0,80001ac2 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001a96:	4719                	li	a4,6
    80001a98:	05893683          	ld	a3,88(s2)
    80001a9c:	6605                	lui	a2,0x1
    80001a9e:	020005b7          	lui	a1,0x2000
    80001aa2:	15fd                	addi	a1,a1,-1
    80001aa4:	05b6                	slli	a1,a1,0xd
    80001aa6:	8526                	mv	a0,s1
    80001aa8:	fffff097          	auipc	ra,0xfffff
    80001aac:	600080e7          	jalr	1536(ra) # 800010a8 <mappages>
    80001ab0:	02054163          	bltz	a0,80001ad2 <proc_pagetable+0x76>
}
    80001ab4:	8526                	mv	a0,s1
    80001ab6:	60e2                	ld	ra,24(sp)
    80001ab8:	6442                	ld	s0,16(sp)
    80001aba:	64a2                	ld	s1,8(sp)
    80001abc:	6902                	ld	s2,0(sp)
    80001abe:	6105                	addi	sp,sp,32
    80001ac0:	8082                	ret
    uvmfree(pagetable, 0);
    80001ac2:	4581                	li	a1,0
    80001ac4:	8526                	mv	a0,s1
    80001ac6:	00000097          	auipc	ra,0x0
    80001aca:	a56080e7          	jalr	-1450(ra) # 8000151c <uvmfree>
    return 0;
    80001ace:	4481                	li	s1,0
    80001ad0:	b7d5                	j	80001ab4 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ad2:	4681                	li	a3,0
    80001ad4:	4605                	li	a2,1
    80001ad6:	040005b7          	lui	a1,0x4000
    80001ada:	15fd                	addi	a1,a1,-1
    80001adc:	05b2                	slli	a1,a1,0xc
    80001ade:	8526                	mv	a0,s1
    80001ae0:	fffff097          	auipc	ra,0xfffff
    80001ae4:	77c080e7          	jalr	1916(ra) # 8000125c <uvmunmap>
    uvmfree(pagetable, 0);
    80001ae8:	4581                	li	a1,0
    80001aea:	8526                	mv	a0,s1
    80001aec:	00000097          	auipc	ra,0x0
    80001af0:	a30080e7          	jalr	-1488(ra) # 8000151c <uvmfree>
    return 0;
    80001af4:	4481                	li	s1,0
    80001af6:	bf7d                	j	80001ab4 <proc_pagetable+0x58>

0000000080001af8 <proc_freepagetable>:
{
    80001af8:	1101                	addi	sp,sp,-32
    80001afa:	ec06                	sd	ra,24(sp)
    80001afc:	e822                	sd	s0,16(sp)
    80001afe:	e426                	sd	s1,8(sp)
    80001b00:	e04a                	sd	s2,0(sp)
    80001b02:	1000                	addi	s0,sp,32
    80001b04:	84aa                	mv	s1,a0
    80001b06:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b08:	4681                	li	a3,0
    80001b0a:	4605                	li	a2,1
    80001b0c:	040005b7          	lui	a1,0x4000
    80001b10:	15fd                	addi	a1,a1,-1
    80001b12:	05b2                	slli	a1,a1,0xc
    80001b14:	fffff097          	auipc	ra,0xfffff
    80001b18:	748080e7          	jalr	1864(ra) # 8000125c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b1c:	4681                	li	a3,0
    80001b1e:	4605                	li	a2,1
    80001b20:	020005b7          	lui	a1,0x2000
    80001b24:	15fd                	addi	a1,a1,-1
    80001b26:	05b6                	slli	a1,a1,0xd
    80001b28:	8526                	mv	a0,s1
    80001b2a:	fffff097          	auipc	ra,0xfffff
    80001b2e:	732080e7          	jalr	1842(ra) # 8000125c <uvmunmap>
  uvmfree(pagetable, sz);
    80001b32:	85ca                	mv	a1,s2
    80001b34:	8526                	mv	a0,s1
    80001b36:	00000097          	auipc	ra,0x0
    80001b3a:	9e6080e7          	jalr	-1562(ra) # 8000151c <uvmfree>
}
    80001b3e:	60e2                	ld	ra,24(sp)
    80001b40:	6442                	ld	s0,16(sp)
    80001b42:	64a2                	ld	s1,8(sp)
    80001b44:	6902                	ld	s2,0(sp)
    80001b46:	6105                	addi	sp,sp,32
    80001b48:	8082                	ret

0000000080001b4a <freeproc>:
{
    80001b4a:	1101                	addi	sp,sp,-32
    80001b4c:	ec06                	sd	ra,24(sp)
    80001b4e:	e822                	sd	s0,16(sp)
    80001b50:	e426                	sd	s1,8(sp)
    80001b52:	1000                	addi	s0,sp,32
    80001b54:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b56:	6d28                	ld	a0,88(a0)
    80001b58:	c509                	beqz	a0,80001b62 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b5a:	fffff097          	auipc	ra,0xfffff
    80001b5e:	e80080e7          	jalr	-384(ra) # 800009da <kfree>
  p->trapframe = 0;
    80001b62:	0404bc23          	sd	zero,88(s1)
  if(p->user_trapframe_backup)
    80001b66:	3704b503          	ld	a0,880(s1)
    80001b6a:	c509                	beqz	a0,80001b74 <freeproc+0x2a>
    kfree((void*)p->user_trapframe_backup);
    80001b6c:	fffff097          	auipc	ra,0xfffff
    80001b70:	e6e080e7          	jalr	-402(ra) # 800009da <kfree>
  p->user_trapframe_backup = 0;
    80001b74:	3604b823          	sd	zero,880(s1)
  if(p->pagetable)
    80001b78:	68a8                	ld	a0,80(s1)
    80001b7a:	c511                	beqz	a0,80001b86 <freeproc+0x3c>
    proc_freepagetable(p->pagetable, p->sz);
    80001b7c:	64ac                	ld	a1,72(s1)
    80001b7e:	00000097          	auipc	ra,0x0
    80001b82:	f7a080e7          	jalr	-134(ra) # 80001af8 <proc_freepagetable>
  p->pagetable = 0;
    80001b86:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b8a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b8e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b92:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b96:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b9a:	0204b023          	sd	zero,32(s1)
  p->xstate = 0;
    80001b9e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ba2:	0004ac23          	sw	zero,24(s1)
}
    80001ba6:	60e2                	ld	ra,24(sp)
    80001ba8:	6442                	ld	s0,16(sp)
    80001baa:	64a2                	ld	s1,8(sp)
    80001bac:	6105                	addi	sp,sp,32
    80001bae:	8082                	ret

0000000080001bb0 <allocproc>:
{
    80001bb0:	7179                	addi	sp,sp,-48
    80001bb2:	f406                	sd	ra,40(sp)
    80001bb4:	f022                	sd	s0,32(sp)
    80001bb6:	ec26                	sd	s1,24(sp)
    80001bb8:	e84a                	sd	s2,16(sp)
    80001bba:	e44e                	sd	s3,8(sp)
    80001bbc:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bbe:	00010497          	auipc	s1,0x10
    80001bc2:	b1248493          	addi	s1,s1,-1262 # 800116d0 <proc>
    80001bc6:	0001e997          	auipc	s3,0x1e
    80001bca:	b0a98993          	addi	s3,s3,-1270 # 8001f6d0 <tickslock>
    acquire(&p->lock);
    80001bce:	8526                	mv	a0,s1
    80001bd0:	fffff097          	auipc	ra,0xfffff
    80001bd4:	ff6080e7          	jalr	-10(ra) # 80000bc6 <acquire>
    if(p->state == UNUSED) {
    80001bd8:	4c9c                	lw	a5,24(s1)
    80001bda:	cf81                	beqz	a5,80001bf2 <allocproc+0x42>
      release(&p->lock);
    80001bdc:	8526                	mv	a0,s1
    80001bde:	fffff097          	auipc	ra,0xfffff
    80001be2:	0b2080e7          	jalr	178(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001be6:	38048493          	addi	s1,s1,896
    80001bea:	ff3492e3          	bne	s1,s3,80001bce <allocproc+0x1e>
  return 0;
    80001bee:	4481                	li	s1,0
    80001bf0:	a051                	j	80001c74 <allocproc+0xc4>
  p->pid = allocpid();
    80001bf2:	00000097          	auipc	ra,0x0
    80001bf6:	e24080e7          	jalr	-476(ra) # 80001a16 <allocpid>
    80001bfa:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bfc:	4785                	li	a5,1
    80001bfe:	cc9c                	sw	a5,24(s1)
  for(int i=0;i<32;i++){
    80001c00:	17048793          	addi	a5,s1,368
    80001c04:	37048713          	addi	a4,s1,880
    p->signal_handlers[i].sa_handler = SIG_DFL;
    80001c08:	0007b023          	sd	zero,0(a5)
    p->signal_handlers[i].sigmask = 0;
    80001c0c:	0007a423          	sw	zero,8(a5)
  for(int i=0;i<32;i++){
    80001c10:	07c1                	addi	a5,a5,16
    80001c12:	fee79be3          	bne	a5,a4,80001c08 <allocproc+0x58>
  p->signal_mask= 0;
    80001c16:	1604a623          	sw	zero,364(s1)
  p->pending_signals = 0;
    80001c1a:	1604a423          	sw	zero,360(s1)
  p->frozen=0;
    80001c1e:	3604ac23          	sw	zero,888(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c22:	fffff097          	auipc	ra,0xfffff
    80001c26:	eb4080e7          	jalr	-332(ra) # 80000ad6 <kalloc>
    80001c2a:	892a                	mv	s2,a0
    80001c2c:	eca8                	sd	a0,88(s1)
    80001c2e:	c939                	beqz	a0,80001c84 <allocproc+0xd4>
   if((p->user_trapframe_backup = (struct trapframe *)kalloc()) == 0){
    80001c30:	fffff097          	auipc	ra,0xfffff
    80001c34:	ea6080e7          	jalr	-346(ra) # 80000ad6 <kalloc>
    80001c38:	892a                	mv	s2,a0
    80001c3a:	36a4b823          	sd	a0,880(s1)
    80001c3e:	cd39                	beqz	a0,80001c9c <allocproc+0xec>
  p->pagetable = proc_pagetable(p);
    80001c40:	8526                	mv	a0,s1
    80001c42:	00000097          	auipc	ra,0x0
    80001c46:	e1a080e7          	jalr	-486(ra) # 80001a5c <proc_pagetable>
    80001c4a:	892a                	mv	s2,a0
    80001c4c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c4e:	c13d                	beqz	a0,80001cb4 <allocproc+0x104>
  memset(&p->context, 0, sizeof(p->context));
    80001c50:	07000613          	li	a2,112
    80001c54:	4581                	li	a1,0
    80001c56:	06048513          	addi	a0,s1,96
    80001c5a:	fffff097          	auipc	ra,0xfffff
    80001c5e:	07e080e7          	jalr	126(ra) # 80000cd8 <memset>
  p->context.ra = (uint64)forkret;
    80001c62:	00000797          	auipc	a5,0x0
    80001c66:	d6e78793          	addi	a5,a5,-658 # 800019d0 <forkret>
    80001c6a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c6c:	60bc                	ld	a5,64(s1)
    80001c6e:	6705                	lui	a4,0x1
    80001c70:	97ba                	add	a5,a5,a4
    80001c72:	f4bc                	sd	a5,104(s1)
}
    80001c74:	8526                	mv	a0,s1
    80001c76:	70a2                	ld	ra,40(sp)
    80001c78:	7402                	ld	s0,32(sp)
    80001c7a:	64e2                	ld	s1,24(sp)
    80001c7c:	6942                	ld	s2,16(sp)
    80001c7e:	69a2                	ld	s3,8(sp)
    80001c80:	6145                	addi	sp,sp,48
    80001c82:	8082                	ret
    freeproc(p);
    80001c84:	8526                	mv	a0,s1
    80001c86:	00000097          	auipc	ra,0x0
    80001c8a:	ec4080e7          	jalr	-316(ra) # 80001b4a <freeproc>
    release(&p->lock);
    80001c8e:	8526                	mv	a0,s1
    80001c90:	fffff097          	auipc	ra,0xfffff
    80001c94:	000080e7          	jalr	ra # 80000c90 <release>
    return 0;
    80001c98:	84ca                	mv	s1,s2
    80001c9a:	bfe9                	j	80001c74 <allocproc+0xc4>
    freeproc(p);
    80001c9c:	8526                	mv	a0,s1
    80001c9e:	00000097          	auipc	ra,0x0
    80001ca2:	eac080e7          	jalr	-340(ra) # 80001b4a <freeproc>
    release(&p->lock);
    80001ca6:	8526                	mv	a0,s1
    80001ca8:	fffff097          	auipc	ra,0xfffff
    80001cac:	fe8080e7          	jalr	-24(ra) # 80000c90 <release>
    return 0;
    80001cb0:	84ca                	mv	s1,s2
    80001cb2:	b7c9                	j	80001c74 <allocproc+0xc4>
    freeproc(p);
    80001cb4:	8526                	mv	a0,s1
    80001cb6:	00000097          	auipc	ra,0x0
    80001cba:	e94080e7          	jalr	-364(ra) # 80001b4a <freeproc>
    release(&p->lock);
    80001cbe:	8526                	mv	a0,s1
    80001cc0:	fffff097          	auipc	ra,0xfffff
    80001cc4:	fd0080e7          	jalr	-48(ra) # 80000c90 <release>
    return 0;
    80001cc8:	84ca                	mv	s1,s2
    80001cca:	b76d                	j	80001c74 <allocproc+0xc4>

0000000080001ccc <userinit>:
{
    80001ccc:	1101                	addi	sp,sp,-32
    80001cce:	ec06                	sd	ra,24(sp)
    80001cd0:	e822                	sd	s0,16(sp)
    80001cd2:	e426                	sd	s1,8(sp)
    80001cd4:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cd6:	00000097          	auipc	ra,0x0
    80001cda:	eda080e7          	jalr	-294(ra) # 80001bb0 <allocproc>
    80001cde:	84aa                	mv	s1,a0
  initproc = p;
    80001ce0:	00007797          	auipc	a5,0x7
    80001ce4:	34a7b423          	sd	a0,840(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001ce8:	03400613          	li	a2,52
    80001cec:	00007597          	auipc	a1,0x7
    80001cf0:	b8458593          	addi	a1,a1,-1148 # 80008870 <initcode>
    80001cf4:	6928                	ld	a0,80(a0)
    80001cf6:	fffff097          	auipc	ra,0xfffff
    80001cfa:	658080e7          	jalr	1624(ra) # 8000134e <uvminit>
  p->sz = PGSIZE;
    80001cfe:	6785                	lui	a5,0x1
    80001d00:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d02:	6cb8                	ld	a4,88(s1)
    80001d04:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d08:	6cb8                	ld	a4,88(s1)
    80001d0a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d0c:	4641                	li	a2,16
    80001d0e:	00006597          	auipc	a1,0x6
    80001d12:	50a58593          	addi	a1,a1,1290 # 80008218 <digits+0x1d8>
    80001d16:	15848513          	addi	a0,s1,344
    80001d1a:	fffff097          	auipc	ra,0xfffff
    80001d1e:	110080e7          	jalr	272(ra) # 80000e2a <safestrcpy>
  p->cwd = namei("/");
    80001d22:	00006517          	auipc	a0,0x6
    80001d26:	50650513          	addi	a0,a0,1286 # 80008228 <digits+0x1e8>
    80001d2a:	00002097          	auipc	ra,0x2
    80001d2e:	4f8080e7          	jalr	1272(ra) # 80004222 <namei>
    80001d32:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d36:	478d                	li	a5,3
    80001d38:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d3a:	8526                	mv	a0,s1
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	f54080e7          	jalr	-172(ra) # 80000c90 <release>
}
    80001d44:	60e2                	ld	ra,24(sp)
    80001d46:	6442                	ld	s0,16(sp)
    80001d48:	64a2                	ld	s1,8(sp)
    80001d4a:	6105                	addi	sp,sp,32
    80001d4c:	8082                	ret

0000000080001d4e <growproc>:
{
    80001d4e:	1101                	addi	sp,sp,-32
    80001d50:	ec06                	sd	ra,24(sp)
    80001d52:	e822                	sd	s0,16(sp)
    80001d54:	e426                	sd	s1,8(sp)
    80001d56:	e04a                	sd	s2,0(sp)
    80001d58:	1000                	addi	s0,sp,32
    80001d5a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d5c:	00000097          	auipc	ra,0x0
    80001d60:	c3c080e7          	jalr	-964(ra) # 80001998 <myproc>
    80001d64:	892a                	mv	s2,a0
  sz = p->sz;
    80001d66:	652c                	ld	a1,72(a0)
    80001d68:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d6c:	00904f63          	bgtz	s1,80001d8a <growproc+0x3c>
  } else if(n < 0){
    80001d70:	0204cc63          	bltz	s1,80001da8 <growproc+0x5a>
  p->sz = sz;
    80001d74:	1602                	slli	a2,a2,0x20
    80001d76:	9201                	srli	a2,a2,0x20
    80001d78:	04c93423          	sd	a2,72(s2)
  return 0;
    80001d7c:	4501                	li	a0,0
}
    80001d7e:	60e2                	ld	ra,24(sp)
    80001d80:	6442                	ld	s0,16(sp)
    80001d82:	64a2                	ld	s1,8(sp)
    80001d84:	6902                	ld	s2,0(sp)
    80001d86:	6105                	addi	sp,sp,32
    80001d88:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d8a:	9e25                	addw	a2,a2,s1
    80001d8c:	1602                	slli	a2,a2,0x20
    80001d8e:	9201                	srli	a2,a2,0x20
    80001d90:	1582                	slli	a1,a1,0x20
    80001d92:	9181                	srli	a1,a1,0x20
    80001d94:	6928                	ld	a0,80(a0)
    80001d96:	fffff097          	auipc	ra,0xfffff
    80001d9a:	672080e7          	jalr	1650(ra) # 80001408 <uvmalloc>
    80001d9e:	0005061b          	sext.w	a2,a0
    80001da2:	fa69                	bnez	a2,80001d74 <growproc+0x26>
      return -1;
    80001da4:	557d                	li	a0,-1
    80001da6:	bfe1                	j	80001d7e <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001da8:	9e25                	addw	a2,a2,s1
    80001daa:	1602                	slli	a2,a2,0x20
    80001dac:	9201                	srli	a2,a2,0x20
    80001dae:	1582                	slli	a1,a1,0x20
    80001db0:	9181                	srli	a1,a1,0x20
    80001db2:	6928                	ld	a0,80(a0)
    80001db4:	fffff097          	auipc	ra,0xfffff
    80001db8:	60c080e7          	jalr	1548(ra) # 800013c0 <uvmdealloc>
    80001dbc:	0005061b          	sext.w	a2,a0
    80001dc0:	bf55                	j	80001d74 <growproc+0x26>

0000000080001dc2 <fork>:
{
    80001dc2:	7139                	addi	sp,sp,-64
    80001dc4:	fc06                	sd	ra,56(sp)
    80001dc6:	f822                	sd	s0,48(sp)
    80001dc8:	f426                	sd	s1,40(sp)
    80001dca:	f04a                	sd	s2,32(sp)
    80001dcc:	ec4e                	sd	s3,24(sp)
    80001dce:	e852                	sd	s4,16(sp)
    80001dd0:	e456                	sd	s5,8(sp)
    80001dd2:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dd4:	00000097          	auipc	ra,0x0
    80001dd8:	bc4080e7          	jalr	-1084(ra) # 80001998 <myproc>
    80001ddc:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001dde:	00000097          	auipc	ra,0x0
    80001de2:	dd2080e7          	jalr	-558(ra) # 80001bb0 <allocproc>
    80001de6:	14050463          	beqz	a0,80001f2e <fork+0x16c>
    80001dea:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dec:	04893603          	ld	a2,72(s2)
    80001df0:	692c                	ld	a1,80(a0)
    80001df2:	05093503          	ld	a0,80(s2)
    80001df6:	fffff097          	auipc	ra,0xfffff
    80001dfa:	75e080e7          	jalr	1886(ra) # 80001554 <uvmcopy>
    80001dfe:	04054863          	bltz	a0,80001e4e <fork+0x8c>
  np->sz = p->sz;
    80001e02:	04893783          	ld	a5,72(s2)
    80001e06:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e0a:	05893683          	ld	a3,88(s2)
    80001e0e:	87b6                	mv	a5,a3
    80001e10:	058a3703          	ld	a4,88(s4)
    80001e14:	12068693          	addi	a3,a3,288
    80001e18:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e1c:	6788                	ld	a0,8(a5)
    80001e1e:	6b8c                	ld	a1,16(a5)
    80001e20:	6f90                	ld	a2,24(a5)
    80001e22:	01073023          	sd	a6,0(a4)
    80001e26:	e708                	sd	a0,8(a4)
    80001e28:	eb0c                	sd	a1,16(a4)
    80001e2a:	ef10                	sd	a2,24(a4)
    80001e2c:	02078793          	addi	a5,a5,32
    80001e30:	02070713          	addi	a4,a4,32
    80001e34:	fed792e3          	bne	a5,a3,80001e18 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e38:	058a3783          	ld	a5,88(s4)
    80001e3c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e40:	0d090493          	addi	s1,s2,208
    80001e44:	0d0a0993          	addi	s3,s4,208
    80001e48:	15090a93          	addi	s5,s2,336
    80001e4c:	a00d                	j	80001e6e <fork+0xac>
    freeproc(np);
    80001e4e:	8552                	mv	a0,s4
    80001e50:	00000097          	auipc	ra,0x0
    80001e54:	cfa080e7          	jalr	-774(ra) # 80001b4a <freeproc>
    release(&np->lock);
    80001e58:	8552                	mv	a0,s4
    80001e5a:	fffff097          	auipc	ra,0xfffff
    80001e5e:	e36080e7          	jalr	-458(ra) # 80000c90 <release>
    return -1;
    80001e62:	54fd                	li	s1,-1
    80001e64:	a85d                	j	80001f1a <fork+0x158>
  for(i = 0; i < NOFILE; i++)
    80001e66:	04a1                	addi	s1,s1,8
    80001e68:	09a1                	addi	s3,s3,8
    80001e6a:	01548b63          	beq	s1,s5,80001e80 <fork+0xbe>
    if(p->ofile[i])
    80001e6e:	6088                	ld	a0,0(s1)
    80001e70:	d97d                	beqz	a0,80001e66 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e72:	00003097          	auipc	ra,0x3
    80001e76:	a4a080e7          	jalr	-1462(ra) # 800048bc <filedup>
    80001e7a:	00a9b023          	sd	a0,0(s3)
    80001e7e:	b7e5                	j	80001e66 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e80:	15093503          	ld	a0,336(s2)
    80001e84:	00002097          	auipc	ra,0x2
    80001e88:	baa080e7          	jalr	-1110(ra) # 80003a2e <idup>
    80001e8c:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e90:	4641                	li	a2,16
    80001e92:	15890593          	addi	a1,s2,344
    80001e96:	158a0513          	addi	a0,s4,344
    80001e9a:	fffff097          	auipc	ra,0xfffff
    80001e9e:	f90080e7          	jalr	-112(ra) # 80000e2a <safestrcpy>
  pid = np->pid;
    80001ea2:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001ea6:	8552                	mv	a0,s4
    80001ea8:	fffff097          	auipc	ra,0xfffff
    80001eac:	de8080e7          	jalr	-536(ra) # 80000c90 <release>
  acquire(&wait_lock);
    80001eb0:	0000f517          	auipc	a0,0xf
    80001eb4:	40850513          	addi	a0,a0,1032 # 800112b8 <wait_lock>
    80001eb8:	fffff097          	auipc	ra,0xfffff
    80001ebc:	d0e080e7          	jalr	-754(ra) # 80000bc6 <acquire>
  np->parent = p;
    80001ec0:	032a3c23          	sd	s2,56(s4)
  np->signal_mask = p->signal_mask;
    80001ec4:	16c92783          	lw	a5,364(s2)
    80001ec8:	16fa2623          	sw	a5,364(s4)
  for(int i=0;i<32;i++){
    80001ecc:	17090793          	addi	a5,s2,368
    80001ed0:	170a0713          	addi	a4,s4,368
    80001ed4:	37090613          	addi	a2,s2,880
    np->signal_handlers[i].sa_handler = p->signal_handlers[i].sa_handler;
    80001ed8:	6394                	ld	a3,0(a5)
    80001eda:	e314                	sd	a3,0(a4)
    np->signal_handlers[i].sigmask = p->signal_handlers[i].sigmask;
    80001edc:	4794                	lw	a3,8(a5)
    80001ede:	c714                	sw	a3,8(a4)
  for(int i=0;i<32;i++){
    80001ee0:	07c1                	addi	a5,a5,16
    80001ee2:	0741                	addi	a4,a4,16
    80001ee4:	fec79ae3          	bne	a5,a2,80001ed8 <fork+0x116>
  np-> pending_signals=0;
    80001ee8:	160a2423          	sw	zero,360(s4)
  np->frozen=0;
    80001eec:	360a2c23          	sw	zero,888(s4)
  release(&wait_lock);
    80001ef0:	0000f517          	auipc	a0,0xf
    80001ef4:	3c850513          	addi	a0,a0,968 # 800112b8 <wait_lock>
    80001ef8:	fffff097          	auipc	ra,0xfffff
    80001efc:	d98080e7          	jalr	-616(ra) # 80000c90 <release>
  acquire(&np->lock);
    80001f00:	8552                	mv	a0,s4
    80001f02:	fffff097          	auipc	ra,0xfffff
    80001f06:	cc4080e7          	jalr	-828(ra) # 80000bc6 <acquire>
  np->state = RUNNABLE;
    80001f0a:	478d                	li	a5,3
    80001f0c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f10:	8552                	mv	a0,s4
    80001f12:	fffff097          	auipc	ra,0xfffff
    80001f16:	d7e080e7          	jalr	-642(ra) # 80000c90 <release>
}
    80001f1a:	8526                	mv	a0,s1
    80001f1c:	70e2                	ld	ra,56(sp)
    80001f1e:	7442                	ld	s0,48(sp)
    80001f20:	74a2                	ld	s1,40(sp)
    80001f22:	7902                	ld	s2,32(sp)
    80001f24:	69e2                	ld	s3,24(sp)
    80001f26:	6a42                	ld	s4,16(sp)
    80001f28:	6aa2                	ld	s5,8(sp)
    80001f2a:	6121                	addi	sp,sp,64
    80001f2c:	8082                	ret
    return -1;
    80001f2e:	54fd                	li	s1,-1
    80001f30:	b7ed                	j	80001f1a <fork+0x158>

0000000080001f32 <scheduler>:
{
    80001f32:	7139                	addi	sp,sp,-64
    80001f34:	fc06                	sd	ra,56(sp)
    80001f36:	f822                	sd	s0,48(sp)
    80001f38:	f426                	sd	s1,40(sp)
    80001f3a:	f04a                	sd	s2,32(sp)
    80001f3c:	ec4e                	sd	s3,24(sp)
    80001f3e:	e852                	sd	s4,16(sp)
    80001f40:	e456                	sd	s5,8(sp)
    80001f42:	e05a                	sd	s6,0(sp)
    80001f44:	0080                	addi	s0,sp,64
    80001f46:	8792                	mv	a5,tp
  int id = r_tp();
    80001f48:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f4a:	00779a93          	slli	s5,a5,0x7
    80001f4e:	0000f717          	auipc	a4,0xf
    80001f52:	35270713          	addi	a4,a4,850 # 800112a0 <pid_lock>
    80001f56:	9756                	add	a4,a4,s5
    80001f58:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f5c:	0000f717          	auipc	a4,0xf
    80001f60:	37c70713          	addi	a4,a4,892 # 800112d8 <cpus+0x8>
    80001f64:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f66:	498d                	li	s3,3
        p->state = RUNNING;
    80001f68:	4b11                	li	s6,4
        c->proc = p;
    80001f6a:	079e                	slli	a5,a5,0x7
    80001f6c:	0000fa17          	auipc	s4,0xf
    80001f70:	334a0a13          	addi	s4,s4,820 # 800112a0 <pid_lock>
    80001f74:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f76:	0001d917          	auipc	s2,0x1d
    80001f7a:	75a90913          	addi	s2,s2,1882 # 8001f6d0 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f7e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f82:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f86:	10079073          	csrw	sstatus,a5
    80001f8a:	0000f497          	auipc	s1,0xf
    80001f8e:	74648493          	addi	s1,s1,1862 # 800116d0 <proc>
    80001f92:	a811                	j	80001fa6 <scheduler+0x74>
      release(&p->lock);
    80001f94:	8526                	mv	a0,s1
    80001f96:	fffff097          	auipc	ra,0xfffff
    80001f9a:	cfa080e7          	jalr	-774(ra) # 80000c90 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f9e:	38048493          	addi	s1,s1,896
    80001fa2:	fd248ee3          	beq	s1,s2,80001f7e <scheduler+0x4c>
      acquire(&p->lock);
    80001fa6:	8526                	mv	a0,s1
    80001fa8:	fffff097          	auipc	ra,0xfffff
    80001fac:	c1e080e7          	jalr	-994(ra) # 80000bc6 <acquire>
      if(p->state == RUNNABLE) {
    80001fb0:	4c9c                	lw	a5,24(s1)
    80001fb2:	ff3791e3          	bne	a5,s3,80001f94 <scheduler+0x62>
        p->state = RUNNING;
    80001fb6:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001fba:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001fbe:	06048593          	addi	a1,s1,96
    80001fc2:	8556                	mv	a0,s5
    80001fc4:	00001097          	auipc	ra,0x1
    80001fc8:	808080e7          	jalr	-2040(ra) # 800027cc <swtch>
        c->proc = 0;
    80001fcc:	020a3823          	sd	zero,48(s4)
    80001fd0:	b7d1                	j	80001f94 <scheduler+0x62>

0000000080001fd2 <sched>:
{
    80001fd2:	7179                	addi	sp,sp,-48
    80001fd4:	f406                	sd	ra,40(sp)
    80001fd6:	f022                	sd	s0,32(sp)
    80001fd8:	ec26                	sd	s1,24(sp)
    80001fda:	e84a                	sd	s2,16(sp)
    80001fdc:	e44e                	sd	s3,8(sp)
    80001fde:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fe0:	00000097          	auipc	ra,0x0
    80001fe4:	9b8080e7          	jalr	-1608(ra) # 80001998 <myproc>
    80001fe8:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fea:	fffff097          	auipc	ra,0xfffff
    80001fee:	b62080e7          	jalr	-1182(ra) # 80000b4c <holding>
    80001ff2:	c93d                	beqz	a0,80002068 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ff4:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001ff6:	2781                	sext.w	a5,a5
    80001ff8:	079e                	slli	a5,a5,0x7
    80001ffa:	0000f717          	auipc	a4,0xf
    80001ffe:	2a670713          	addi	a4,a4,678 # 800112a0 <pid_lock>
    80002002:	97ba                	add	a5,a5,a4
    80002004:	0a87a703          	lw	a4,168(a5)
    80002008:	4785                	li	a5,1
    8000200a:	06f71763          	bne	a4,a5,80002078 <sched+0xa6>
  if(p->state == RUNNING)
    8000200e:	4c98                	lw	a4,24(s1)
    80002010:	4791                	li	a5,4
    80002012:	06f70b63          	beq	a4,a5,80002088 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002016:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000201a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000201c:	efb5                	bnez	a5,80002098 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000201e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002020:	0000f917          	auipc	s2,0xf
    80002024:	28090913          	addi	s2,s2,640 # 800112a0 <pid_lock>
    80002028:	2781                	sext.w	a5,a5
    8000202a:	079e                	slli	a5,a5,0x7
    8000202c:	97ca                	add	a5,a5,s2
    8000202e:	0ac7a983          	lw	s3,172(a5)
    80002032:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002034:	2781                	sext.w	a5,a5
    80002036:	079e                	slli	a5,a5,0x7
    80002038:	0000f597          	auipc	a1,0xf
    8000203c:	2a058593          	addi	a1,a1,672 # 800112d8 <cpus+0x8>
    80002040:	95be                	add	a1,a1,a5
    80002042:	06048513          	addi	a0,s1,96
    80002046:	00000097          	auipc	ra,0x0
    8000204a:	786080e7          	jalr	1926(ra) # 800027cc <swtch>
    8000204e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002050:	2781                	sext.w	a5,a5
    80002052:	079e                	slli	a5,a5,0x7
    80002054:	97ca                	add	a5,a5,s2
    80002056:	0b37a623          	sw	s3,172(a5)
}
    8000205a:	70a2                	ld	ra,40(sp)
    8000205c:	7402                	ld	s0,32(sp)
    8000205e:	64e2                	ld	s1,24(sp)
    80002060:	6942                	ld	s2,16(sp)
    80002062:	69a2                	ld	s3,8(sp)
    80002064:	6145                	addi	sp,sp,48
    80002066:	8082                	ret
    panic("sched p->lock");
    80002068:	00006517          	auipc	a0,0x6
    8000206c:	1c850513          	addi	a0,a0,456 # 80008230 <digits+0x1f0>
    80002070:	ffffe097          	auipc	ra,0xffffe
    80002074:	4be080e7          	jalr	1214(ra) # 8000052e <panic>
    panic("sched locks");
    80002078:	00006517          	auipc	a0,0x6
    8000207c:	1c850513          	addi	a0,a0,456 # 80008240 <digits+0x200>
    80002080:	ffffe097          	auipc	ra,0xffffe
    80002084:	4ae080e7          	jalr	1198(ra) # 8000052e <panic>
    panic("sched running");
    80002088:	00006517          	auipc	a0,0x6
    8000208c:	1c850513          	addi	a0,a0,456 # 80008250 <digits+0x210>
    80002090:	ffffe097          	auipc	ra,0xffffe
    80002094:	49e080e7          	jalr	1182(ra) # 8000052e <panic>
    panic("sched interruptible");
    80002098:	00006517          	auipc	a0,0x6
    8000209c:	1c850513          	addi	a0,a0,456 # 80008260 <digits+0x220>
    800020a0:	ffffe097          	auipc	ra,0xffffe
    800020a4:	48e080e7          	jalr	1166(ra) # 8000052e <panic>

00000000800020a8 <yield>:
{
    800020a8:	1101                	addi	sp,sp,-32
    800020aa:	ec06                	sd	ra,24(sp)
    800020ac:	e822                	sd	s0,16(sp)
    800020ae:	e426                	sd	s1,8(sp)
    800020b0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800020b2:	00000097          	auipc	ra,0x0
    800020b6:	8e6080e7          	jalr	-1818(ra) # 80001998 <myproc>
    800020ba:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020bc:	fffff097          	auipc	ra,0xfffff
    800020c0:	b0a080e7          	jalr	-1270(ra) # 80000bc6 <acquire>
  p->state = RUNNABLE;
    800020c4:	478d                	li	a5,3
    800020c6:	cc9c                	sw	a5,24(s1)
  sched();
    800020c8:	00000097          	auipc	ra,0x0
    800020cc:	f0a080e7          	jalr	-246(ra) # 80001fd2 <sched>
  release(&p->lock);
    800020d0:	8526                	mv	a0,s1
    800020d2:	fffff097          	auipc	ra,0xfffff
    800020d6:	bbe080e7          	jalr	-1090(ra) # 80000c90 <release>
}
    800020da:	60e2                	ld	ra,24(sp)
    800020dc:	6442                	ld	s0,16(sp)
    800020de:	64a2                	ld	s1,8(sp)
    800020e0:	6105                	addi	sp,sp,32
    800020e2:	8082                	ret

00000000800020e4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020e4:	7179                	addi	sp,sp,-48
    800020e6:	f406                	sd	ra,40(sp)
    800020e8:	f022                	sd	s0,32(sp)
    800020ea:	ec26                	sd	s1,24(sp)
    800020ec:	e84a                	sd	s2,16(sp)
    800020ee:	e44e                	sd	s3,8(sp)
    800020f0:	1800                	addi	s0,sp,48
    800020f2:	89aa                	mv	s3,a0
    800020f4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020f6:	00000097          	auipc	ra,0x0
    800020fa:	8a2080e7          	jalr	-1886(ra) # 80001998 <myproc>
    800020fe:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002100:	fffff097          	auipc	ra,0xfffff
    80002104:	ac6080e7          	jalr	-1338(ra) # 80000bc6 <acquire>
  release(lk);
    80002108:	854a                	mv	a0,s2
    8000210a:	fffff097          	auipc	ra,0xfffff
    8000210e:	b86080e7          	jalr	-1146(ra) # 80000c90 <release>

  // Go to sleep.
  p->chan = chan;
    80002112:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002116:	4789                	li	a5,2
    80002118:	cc9c                	sw	a5,24(s1)

  sched();
    8000211a:	00000097          	auipc	ra,0x0
    8000211e:	eb8080e7          	jalr	-328(ra) # 80001fd2 <sched>

  // Tidy up.
  p->chan = 0;
    80002122:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002126:	8526                	mv	a0,s1
    80002128:	fffff097          	auipc	ra,0xfffff
    8000212c:	b68080e7          	jalr	-1176(ra) # 80000c90 <release>
  acquire(lk);
    80002130:	854a                	mv	a0,s2
    80002132:	fffff097          	auipc	ra,0xfffff
    80002136:	a94080e7          	jalr	-1388(ra) # 80000bc6 <acquire>
}
    8000213a:	70a2                	ld	ra,40(sp)
    8000213c:	7402                	ld	s0,32(sp)
    8000213e:	64e2                	ld	s1,24(sp)
    80002140:	6942                	ld	s2,16(sp)
    80002142:	69a2                	ld	s3,8(sp)
    80002144:	6145                	addi	sp,sp,48
    80002146:	8082                	ret

0000000080002148 <wait>:
{
    80002148:	715d                	addi	sp,sp,-80
    8000214a:	e486                	sd	ra,72(sp)
    8000214c:	e0a2                	sd	s0,64(sp)
    8000214e:	fc26                	sd	s1,56(sp)
    80002150:	f84a                	sd	s2,48(sp)
    80002152:	f44e                	sd	s3,40(sp)
    80002154:	f052                	sd	s4,32(sp)
    80002156:	ec56                	sd	s5,24(sp)
    80002158:	e85a                	sd	s6,16(sp)
    8000215a:	e45e                	sd	s7,8(sp)
    8000215c:	e062                	sd	s8,0(sp)
    8000215e:	0880                	addi	s0,sp,80
    80002160:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002162:	00000097          	auipc	ra,0x0
    80002166:	836080e7          	jalr	-1994(ra) # 80001998 <myproc>
    8000216a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000216c:	0000f517          	auipc	a0,0xf
    80002170:	14c50513          	addi	a0,a0,332 # 800112b8 <wait_lock>
    80002174:	fffff097          	auipc	ra,0xfffff
    80002178:	a52080e7          	jalr	-1454(ra) # 80000bc6 <acquire>
    havekids = 0;
    8000217c:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    8000217e:	4a95                	li	s5,5
        havekids = 1;
    80002180:	4a05                	li	s4,1
    for(np = proc; np < &proc[NPROC]; np++){
    80002182:	0001d997          	auipc	s3,0x1d
    80002186:	54e98993          	addi	s3,s3,1358 # 8001f6d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000218a:	0000fc17          	auipc	s8,0xf
    8000218e:	12ec0c13          	addi	s8,s8,302 # 800112b8 <wait_lock>
    havekids = 0;
    80002192:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002194:	0000f497          	auipc	s1,0xf
    80002198:	53c48493          	addi	s1,s1,1340 # 800116d0 <proc>
    8000219c:	a0bd                	j	8000220a <wait+0xc2>
          pid = np->pid;
    8000219e:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800021a2:	000b0e63          	beqz	s6,800021be <wait+0x76>
    800021a6:	4691                	li	a3,4
    800021a8:	02c48613          	addi	a2,s1,44
    800021ac:	85da                	mv	a1,s6
    800021ae:	05093503          	ld	a0,80(s2)
    800021b2:	fffff097          	auipc	ra,0xfffff
    800021b6:	4a6080e7          	jalr	1190(ra) # 80001658 <copyout>
    800021ba:	02054563          	bltz	a0,800021e4 <wait+0x9c>
          freeproc(np);
    800021be:	8526                	mv	a0,s1
    800021c0:	00000097          	auipc	ra,0x0
    800021c4:	98a080e7          	jalr	-1654(ra) # 80001b4a <freeproc>
          release(&np->lock);
    800021c8:	8526                	mv	a0,s1
    800021ca:	fffff097          	auipc	ra,0xfffff
    800021ce:	ac6080e7          	jalr	-1338(ra) # 80000c90 <release>
          release(&wait_lock);
    800021d2:	0000f517          	auipc	a0,0xf
    800021d6:	0e650513          	addi	a0,a0,230 # 800112b8 <wait_lock>
    800021da:	fffff097          	auipc	ra,0xfffff
    800021de:	ab6080e7          	jalr	-1354(ra) # 80000c90 <release>
          return pid;
    800021e2:	a0a5                	j	8000224a <wait+0x102>
            release(&np->lock);
    800021e4:	8526                	mv	a0,s1
    800021e6:	fffff097          	auipc	ra,0xfffff
    800021ea:	aaa080e7          	jalr	-1366(ra) # 80000c90 <release>
            release(&wait_lock);
    800021ee:	0000f517          	auipc	a0,0xf
    800021f2:	0ca50513          	addi	a0,a0,202 # 800112b8 <wait_lock>
    800021f6:	fffff097          	auipc	ra,0xfffff
    800021fa:	a9a080e7          	jalr	-1382(ra) # 80000c90 <release>
            return -1;
    800021fe:	59fd                	li	s3,-1
    80002200:	a0a9                	j	8000224a <wait+0x102>
    for(np = proc; np < &proc[NPROC]; np++){
    80002202:	38048493          	addi	s1,s1,896
    80002206:	03348463          	beq	s1,s3,8000222e <wait+0xe6>
      if(np->parent == p){
    8000220a:	7c9c                	ld	a5,56(s1)
    8000220c:	ff279be3          	bne	a5,s2,80002202 <wait+0xba>
        acquire(&np->lock);
    80002210:	8526                	mv	a0,s1
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	9b4080e7          	jalr	-1612(ra) # 80000bc6 <acquire>
        if(np->state == ZOMBIE){
    8000221a:	4c9c                	lw	a5,24(s1)
    8000221c:	f95781e3          	beq	a5,s5,8000219e <wait+0x56>
        release(&np->lock);
    80002220:	8526                	mv	a0,s1
    80002222:	fffff097          	auipc	ra,0xfffff
    80002226:	a6e080e7          	jalr	-1426(ra) # 80000c90 <release>
        havekids = 1;
    8000222a:	8752                	mv	a4,s4
    8000222c:	bfd9                	j	80002202 <wait+0xba>
    if(!havekids || p->killed==1){
    8000222e:	c709                	beqz	a4,80002238 <wait+0xf0>
    80002230:	02892783          	lw	a5,40(s2)
    80002234:	03479863          	bne	a5,s4,80002264 <wait+0x11c>
      release(&wait_lock);
    80002238:	0000f517          	auipc	a0,0xf
    8000223c:	08050513          	addi	a0,a0,128 # 800112b8 <wait_lock>
    80002240:	fffff097          	auipc	ra,0xfffff
    80002244:	a50080e7          	jalr	-1456(ra) # 80000c90 <release>
      return -1;
    80002248:	59fd                	li	s3,-1
}
    8000224a:	854e                	mv	a0,s3
    8000224c:	60a6                	ld	ra,72(sp)
    8000224e:	6406                	ld	s0,64(sp)
    80002250:	74e2                	ld	s1,56(sp)
    80002252:	7942                	ld	s2,48(sp)
    80002254:	79a2                	ld	s3,40(sp)
    80002256:	7a02                	ld	s4,32(sp)
    80002258:	6ae2                	ld	s5,24(sp)
    8000225a:	6b42                	ld	s6,16(sp)
    8000225c:	6ba2                	ld	s7,8(sp)
    8000225e:	6c02                	ld	s8,0(sp)
    80002260:	6161                	addi	sp,sp,80
    80002262:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002264:	85e2                	mv	a1,s8
    80002266:	854a                	mv	a0,s2
    80002268:	00000097          	auipc	ra,0x0
    8000226c:	e7c080e7          	jalr	-388(ra) # 800020e4 <sleep>
    havekids = 0;
    80002270:	b70d                	j	80002192 <wait+0x4a>

0000000080002272 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002272:	7139                	addi	sp,sp,-64
    80002274:	fc06                	sd	ra,56(sp)
    80002276:	f822                	sd	s0,48(sp)
    80002278:	f426                	sd	s1,40(sp)
    8000227a:	f04a                	sd	s2,32(sp)
    8000227c:	ec4e                	sd	s3,24(sp)
    8000227e:	e852                	sd	s4,16(sp)
    80002280:	e456                	sd	s5,8(sp)
    80002282:	0080                	addi	s0,sp,64
    80002284:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002286:	0000f497          	auipc	s1,0xf
    8000228a:	44a48493          	addi	s1,s1,1098 # 800116d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000228e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002290:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002292:	0001d917          	auipc	s2,0x1d
    80002296:	43e90913          	addi	s2,s2,1086 # 8001f6d0 <tickslock>
    8000229a:	a811                	j	800022ae <wakeup+0x3c>
      }
      release(&p->lock);
    8000229c:	8526                	mv	a0,s1
    8000229e:	fffff097          	auipc	ra,0xfffff
    800022a2:	9f2080e7          	jalr	-1550(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800022a6:	38048493          	addi	s1,s1,896
    800022aa:	03248663          	beq	s1,s2,800022d6 <wakeup+0x64>
    if(p != myproc()){
    800022ae:	fffff097          	auipc	ra,0xfffff
    800022b2:	6ea080e7          	jalr	1770(ra) # 80001998 <myproc>
    800022b6:	fea488e3          	beq	s1,a0,800022a6 <wakeup+0x34>
      acquire(&p->lock);
    800022ba:	8526                	mv	a0,s1
    800022bc:	fffff097          	auipc	ra,0xfffff
    800022c0:	90a080e7          	jalr	-1782(ra) # 80000bc6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800022c4:	4c9c                	lw	a5,24(s1)
    800022c6:	fd379be3          	bne	a5,s3,8000229c <wakeup+0x2a>
    800022ca:	709c                	ld	a5,32(s1)
    800022cc:	fd4798e3          	bne	a5,s4,8000229c <wakeup+0x2a>
        p->state = RUNNABLE;
    800022d0:	0154ac23          	sw	s5,24(s1)
    800022d4:	b7e1                	j	8000229c <wakeup+0x2a>
    }
  }
}
    800022d6:	70e2                	ld	ra,56(sp)
    800022d8:	7442                	ld	s0,48(sp)
    800022da:	74a2                	ld	s1,40(sp)
    800022dc:	7902                	ld	s2,32(sp)
    800022de:	69e2                	ld	s3,24(sp)
    800022e0:	6a42                	ld	s4,16(sp)
    800022e2:	6aa2                	ld	s5,8(sp)
    800022e4:	6121                	addi	sp,sp,64
    800022e6:	8082                	ret

00000000800022e8 <reparent>:
{
    800022e8:	7179                	addi	sp,sp,-48
    800022ea:	f406                	sd	ra,40(sp)
    800022ec:	f022                	sd	s0,32(sp)
    800022ee:	ec26                	sd	s1,24(sp)
    800022f0:	e84a                	sd	s2,16(sp)
    800022f2:	e44e                	sd	s3,8(sp)
    800022f4:	e052                	sd	s4,0(sp)
    800022f6:	1800                	addi	s0,sp,48
    800022f8:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800022fa:	0000f497          	auipc	s1,0xf
    800022fe:	3d648493          	addi	s1,s1,982 # 800116d0 <proc>
      pp->parent = initproc;
    80002302:	00007a17          	auipc	s4,0x7
    80002306:	d26a0a13          	addi	s4,s4,-730 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000230a:	0001d997          	auipc	s3,0x1d
    8000230e:	3c698993          	addi	s3,s3,966 # 8001f6d0 <tickslock>
    80002312:	a029                	j	8000231c <reparent+0x34>
    80002314:	38048493          	addi	s1,s1,896
    80002318:	01348d63          	beq	s1,s3,80002332 <reparent+0x4a>
    if(pp->parent == p){
    8000231c:	7c9c                	ld	a5,56(s1)
    8000231e:	ff279be3          	bne	a5,s2,80002314 <reparent+0x2c>
      pp->parent = initproc;
    80002322:	000a3503          	ld	a0,0(s4)
    80002326:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002328:	00000097          	auipc	ra,0x0
    8000232c:	f4a080e7          	jalr	-182(ra) # 80002272 <wakeup>
    80002330:	b7d5                	j	80002314 <reparent+0x2c>
}
    80002332:	70a2                	ld	ra,40(sp)
    80002334:	7402                	ld	s0,32(sp)
    80002336:	64e2                	ld	s1,24(sp)
    80002338:	6942                	ld	s2,16(sp)
    8000233a:	69a2                	ld	s3,8(sp)
    8000233c:	6a02                	ld	s4,0(sp)
    8000233e:	6145                	addi	sp,sp,48
    80002340:	8082                	ret

0000000080002342 <exit>:
{
    80002342:	7179                	addi	sp,sp,-48
    80002344:	f406                	sd	ra,40(sp)
    80002346:	f022                	sd	s0,32(sp)
    80002348:	ec26                	sd	s1,24(sp)
    8000234a:	e84a                	sd	s2,16(sp)
    8000234c:	e44e                	sd	s3,8(sp)
    8000234e:	e052                	sd	s4,0(sp)
    80002350:	1800                	addi	s0,sp,48
    80002352:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	644080e7          	jalr	1604(ra) # 80001998 <myproc>
    8000235c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000235e:	00007797          	auipc	a5,0x7
    80002362:	cca7b783          	ld	a5,-822(a5) # 80009028 <initproc>
    80002366:	0d050493          	addi	s1,a0,208
    8000236a:	15050913          	addi	s2,a0,336
    8000236e:	02a79363          	bne	a5,a0,80002394 <exit+0x52>
    panic("init exiting");
    80002372:	00006517          	auipc	a0,0x6
    80002376:	f0650513          	addi	a0,a0,-250 # 80008278 <digits+0x238>
    8000237a:	ffffe097          	auipc	ra,0xffffe
    8000237e:	1b4080e7          	jalr	436(ra) # 8000052e <panic>
      fileclose(f);
    80002382:	00002097          	auipc	ra,0x2
    80002386:	58c080e7          	jalr	1420(ra) # 8000490e <fileclose>
      p->ofile[fd] = 0;
    8000238a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000238e:	04a1                	addi	s1,s1,8
    80002390:	01248563          	beq	s1,s2,8000239a <exit+0x58>
    if(p->ofile[fd]){
    80002394:	6088                	ld	a0,0(s1)
    80002396:	f575                	bnez	a0,80002382 <exit+0x40>
    80002398:	bfdd                	j	8000238e <exit+0x4c>
  begin_op();
    8000239a:	00002097          	auipc	ra,0x2
    8000239e:	0a8080e7          	jalr	168(ra) # 80004442 <begin_op>
  iput(p->cwd);
    800023a2:	1509b503          	ld	a0,336(s3)
    800023a6:	00002097          	auipc	ra,0x2
    800023aa:	880080e7          	jalr	-1920(ra) # 80003c26 <iput>
  end_op();
    800023ae:	00002097          	auipc	ra,0x2
    800023b2:	114080e7          	jalr	276(ra) # 800044c2 <end_op>
  p->cwd = 0;
    800023b6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800023ba:	0000f497          	auipc	s1,0xf
    800023be:	efe48493          	addi	s1,s1,-258 # 800112b8 <wait_lock>
    800023c2:	8526                	mv	a0,s1
    800023c4:	fffff097          	auipc	ra,0xfffff
    800023c8:	802080e7          	jalr	-2046(ra) # 80000bc6 <acquire>
  reparent(p);
    800023cc:	854e                	mv	a0,s3
    800023ce:	00000097          	auipc	ra,0x0
    800023d2:	f1a080e7          	jalr	-230(ra) # 800022e8 <reparent>
  wakeup(p->parent);
    800023d6:	0389b503          	ld	a0,56(s3)
    800023da:	00000097          	auipc	ra,0x0
    800023de:	e98080e7          	jalr	-360(ra) # 80002272 <wakeup>
  acquire(&p->lock);
    800023e2:	854e                	mv	a0,s3
    800023e4:	ffffe097          	auipc	ra,0xffffe
    800023e8:	7e2080e7          	jalr	2018(ra) # 80000bc6 <acquire>
  p->xstate = status;
    800023ec:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800023f0:	4795                	li	a5,5
    800023f2:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800023f6:	8526                	mv	a0,s1
    800023f8:	fffff097          	auipc	ra,0xfffff
    800023fc:	898080e7          	jalr	-1896(ra) # 80000c90 <release>
  sched();
    80002400:	00000097          	auipc	ra,0x0
    80002404:	bd2080e7          	jalr	-1070(ra) # 80001fd2 <sched>
  panic("zombie exit");
    80002408:	00006517          	auipc	a0,0x6
    8000240c:	e8050513          	addi	a0,a0,-384 # 80008288 <digits+0x248>
    80002410:	ffffe097          	auipc	ra,0xffffe
    80002414:	11e080e7          	jalr	286(ra) # 8000052e <panic>

0000000080002418 <kill>:


// new kill sending signal to process pid - task 2.2.1
int
kill(int pid, int signum)
{
    80002418:	7179                	addi	sp,sp,-48
    8000241a:	f406                	sd	ra,40(sp)
    8000241c:	f022                	sd	s0,32(sp)
    8000241e:	ec26                	sd	s1,24(sp)
    80002420:	e84a                	sd	s2,16(sp)
    80002422:	e44e                	sd	s3,8(sp)
    80002424:	e052                	sd	s4,0(sp)
    80002426:	1800                	addi	s0,sp,48
    80002428:	892a                	mv	s2,a0
    8000242a:	8a2e                	mv	s4,a1
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000242c:	0000f497          	auipc	s1,0xf
    80002430:	2a448493          	addi	s1,s1,676 # 800116d0 <proc>
    80002434:	0001d997          	auipc	s3,0x1d
    80002438:	29c98993          	addi	s3,s3,668 # 8001f6d0 <tickslock>
    // printf("proc %d try to acquire proc %d\n",myproc()->pid,pid);//TODO delete
    acquire(&p->lock);
    8000243c:	8526                	mv	a0,s1
    8000243e:	ffffe097          	auipc	ra,0xffffe
    80002442:	788080e7          	jalr	1928(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    80002446:	589c                	lw	a5,48(s1)
    80002448:	01278d63          	beq	a5,s2,80002462 <kill+0x4a>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000244c:	8526                	mv	a0,s1
    8000244e:	fffff097          	auipc	ra,0xfffff
    80002452:	842080e7          	jalr	-1982(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002456:	38048493          	addi	s1,s1,896
    8000245a:	ff3491e3          	bne	s1,s3,8000243c <kill+0x24>
  }
  return -1;
    8000245e:	557d                	li	a0,-1
    80002460:	a815                	j	80002494 <kill+0x7c>
      if(p->signal_handlers[signum].sa_handler!=(void*)SIG_IGN){
    80002462:	017a0793          	addi	a5,s4,23
    80002466:	0792                	slli	a5,a5,0x4
    80002468:	97a6                	add	a5,a5,s1
    8000246a:	6398                	ld	a4,0(a5)
    8000246c:	4785                	li	a5,1
    8000246e:	00f70963          	beq	a4,a5,80002480 <kill+0x68>
        p->pending_signals|= (1<<signum);
    80002472:	0147973b          	sllw	a4,a5,s4
    80002476:	1684a783          	lw	a5,360(s1)
    8000247a:	8fd9                	or	a5,a5,a4
    8000247c:	16f4a423          	sw	a5,360(s1)
      if(p->state == SLEEPING && signum == SIGKILL){
    80002480:	4c98                	lw	a4,24(s1)
    80002482:	4789                	li	a5,2
    80002484:	02f70063          	beq	a4,a5,800024a4 <kill+0x8c>
      release(&p->lock);
    80002488:	8526                	mv	a0,s1
    8000248a:	fffff097          	auipc	ra,0xfffff
    8000248e:	806080e7          	jalr	-2042(ra) # 80000c90 <release>
      return 0;
    80002492:	4501                	li	a0,0
}
    80002494:	70a2                	ld	ra,40(sp)
    80002496:	7402                	ld	s0,32(sp)
    80002498:	64e2                	ld	s1,24(sp)
    8000249a:	6942                	ld	s2,16(sp)
    8000249c:	69a2                	ld	s3,8(sp)
    8000249e:	6a02                	ld	s4,0(sp)
    800024a0:	6145                	addi	sp,sp,48
    800024a2:	8082                	ret
      if(p->state == SLEEPING && signum == SIGKILL){
    800024a4:	47a5                	li	a5,9
    800024a6:	fefa11e3          	bne	s4,a5,80002488 <kill+0x70>
        p->state = RUNNABLE;
    800024aa:	478d                	li	a5,3
    800024ac:	cc9c                	sw	a5,24(s1)
    800024ae:	bfe9                	j	80002488 <kill+0x70>

00000000800024b0 <sig_stop>:
//   return -1;
// }

int
sig_stop(int pid)//TODO delete if not used
{
    800024b0:	7179                	addi	sp,sp,-48
    800024b2:	f406                	sd	ra,40(sp)
    800024b4:	f022                	sd	s0,32(sp)
    800024b6:	ec26                	sd	s1,24(sp)
    800024b8:	e84a                	sd	s2,16(sp)
    800024ba:	e44e                	sd	s3,8(sp)
    800024bc:	1800                	addi	s0,sp,48
    800024be:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800024c0:	0000f497          	auipc	s1,0xf
    800024c4:	21048493          	addi	s1,s1,528 # 800116d0 <proc>
    800024c8:	0001d997          	auipc	s3,0x1d
    800024cc:	20898993          	addi	s3,s3,520 # 8001f6d0 <tickslock>
    acquire(&p->lock);
    800024d0:	8526                	mv	a0,s1
    800024d2:	ffffe097          	auipc	ra,0xffffe
    800024d6:	6f4080e7          	jalr	1780(ra) # 80000bc6 <acquire>
    if(p->pid == pid){
    800024da:	589c                	lw	a5,48(s1)
    800024dc:	01278d63          	beq	a5,s2,800024f6 <sig_stop+0x46>
      p->pending_signals|=(1<<SIGSTOP);

      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024e0:	8526                	mv	a0,s1
    800024e2:	ffffe097          	auipc	ra,0xffffe
    800024e6:	7ae080e7          	jalr	1966(ra) # 80000c90 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800024ea:	38048493          	addi	s1,s1,896
    800024ee:	ff3491e3          	bne	s1,s3,800024d0 <sig_stop+0x20>
  }
  return -1;
    800024f2:	557d                	li	a0,-1
    800024f4:	a831                	j	80002510 <sig_stop+0x60>
      p->pending_signals|=(1<<SIGSTOP);
    800024f6:	1684a783          	lw	a5,360(s1)
    800024fa:	00020737          	lui	a4,0x20
    800024fe:	8fd9                	or	a5,a5,a4
    80002500:	16f4a423          	sw	a5,360(s1)
      release(&p->lock);
    80002504:	8526                	mv	a0,s1
    80002506:	ffffe097          	auipc	ra,0xffffe
    8000250a:	78a080e7          	jalr	1930(ra) # 80000c90 <release>
      return 0;
    8000250e:	4501                	li	a0,0
}
    80002510:	70a2                	ld	ra,40(sp)
    80002512:	7402                	ld	s0,32(sp)
    80002514:	64e2                	ld	s1,24(sp)
    80002516:	6942                	ld	s2,16(sp)
    80002518:	69a2                	ld	s3,8(sp)
    8000251a:	6145                	addi	sp,sp,48
    8000251c:	8082                	ret

000000008000251e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000251e:	7179                	addi	sp,sp,-48
    80002520:	f406                	sd	ra,40(sp)
    80002522:	f022                	sd	s0,32(sp)
    80002524:	ec26                	sd	s1,24(sp)
    80002526:	e84a                	sd	s2,16(sp)
    80002528:	e44e                	sd	s3,8(sp)
    8000252a:	e052                	sd	s4,0(sp)
    8000252c:	1800                	addi	s0,sp,48
    8000252e:	84aa                	mv	s1,a0
    80002530:	892e                	mv	s2,a1
    80002532:	89b2                	mv	s3,a2
    80002534:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002536:	fffff097          	auipc	ra,0xfffff
    8000253a:	462080e7          	jalr	1122(ra) # 80001998 <myproc>
  if(user_dst){
    8000253e:	c08d                	beqz	s1,80002560 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002540:	86d2                	mv	a3,s4
    80002542:	864e                	mv	a2,s3
    80002544:	85ca                	mv	a1,s2
    80002546:	6928                	ld	a0,80(a0)
    80002548:	fffff097          	auipc	ra,0xfffff
    8000254c:	110080e7          	jalr	272(ra) # 80001658 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002550:	70a2                	ld	ra,40(sp)
    80002552:	7402                	ld	s0,32(sp)
    80002554:	64e2                	ld	s1,24(sp)
    80002556:	6942                	ld	s2,16(sp)
    80002558:	69a2                	ld	s3,8(sp)
    8000255a:	6a02                	ld	s4,0(sp)
    8000255c:	6145                	addi	sp,sp,48
    8000255e:	8082                	ret
    memmove((char *)dst, src, len);
    80002560:	000a061b          	sext.w	a2,s4
    80002564:	85ce                	mv	a1,s3
    80002566:	854a                	mv	a0,s2
    80002568:	ffffe097          	auipc	ra,0xffffe
    8000256c:	7cc080e7          	jalr	1996(ra) # 80000d34 <memmove>
    return 0;
    80002570:	8526                	mv	a0,s1
    80002572:	bff9                	j	80002550 <either_copyout+0x32>

0000000080002574 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002574:	7179                	addi	sp,sp,-48
    80002576:	f406                	sd	ra,40(sp)
    80002578:	f022                	sd	s0,32(sp)
    8000257a:	ec26                	sd	s1,24(sp)
    8000257c:	e84a                	sd	s2,16(sp)
    8000257e:	e44e                	sd	s3,8(sp)
    80002580:	e052                	sd	s4,0(sp)
    80002582:	1800                	addi	s0,sp,48
    80002584:	892a                	mv	s2,a0
    80002586:	84ae                	mv	s1,a1
    80002588:	89b2                	mv	s3,a2
    8000258a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000258c:	fffff097          	auipc	ra,0xfffff
    80002590:	40c080e7          	jalr	1036(ra) # 80001998 <myproc>
  if(user_src){
    80002594:	c08d                	beqz	s1,800025b6 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002596:	86d2                	mv	a3,s4
    80002598:	864e                	mv	a2,s3
    8000259a:	85ca                	mv	a1,s2
    8000259c:	6928                	ld	a0,80(a0)
    8000259e:	fffff097          	auipc	ra,0xfffff
    800025a2:	146080e7          	jalr	326(ra) # 800016e4 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025a6:	70a2                	ld	ra,40(sp)
    800025a8:	7402                	ld	s0,32(sp)
    800025aa:	64e2                	ld	s1,24(sp)
    800025ac:	6942                	ld	s2,16(sp)
    800025ae:	69a2                	ld	s3,8(sp)
    800025b0:	6a02                	ld	s4,0(sp)
    800025b2:	6145                	addi	sp,sp,48
    800025b4:	8082                	ret
    memmove(dst, (char*)src, len);
    800025b6:	000a061b          	sext.w	a2,s4
    800025ba:	85ce                	mv	a1,s3
    800025bc:	854a                	mv	a0,s2
    800025be:	ffffe097          	auipc	ra,0xffffe
    800025c2:	776080e7          	jalr	1910(ra) # 80000d34 <memmove>
    return 0;
    800025c6:	8526                	mv	a0,s1
    800025c8:	bff9                	j	800025a6 <either_copyin+0x32>

00000000800025ca <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025ca:	715d                	addi	sp,sp,-80
    800025cc:	e486                	sd	ra,72(sp)
    800025ce:	e0a2                	sd	s0,64(sp)
    800025d0:	fc26                	sd	s1,56(sp)
    800025d2:	f84a                	sd	s2,48(sp)
    800025d4:	f44e                	sd	s3,40(sp)
    800025d6:	f052                	sd	s4,32(sp)
    800025d8:	ec56                	sd	s5,24(sp)
    800025da:	e85a                	sd	s6,16(sp)
    800025dc:	e45e                	sd	s7,8(sp)
    800025de:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025e0:	00006517          	auipc	a0,0x6
    800025e4:	b1850513          	addi	a0,a0,-1256 # 800080f8 <digits+0xb8>
    800025e8:	ffffe097          	auipc	ra,0xffffe
    800025ec:	f90080e7          	jalr	-112(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025f0:	0000f497          	auipc	s1,0xf
    800025f4:	23848493          	addi	s1,s1,568 # 80011828 <proc+0x158>
    800025f8:	0001d917          	auipc	s2,0x1d
    800025fc:	23090913          	addi	s2,s2,560 # 8001f828 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002600:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002602:	00006997          	auipc	s3,0x6
    80002606:	c9698993          	addi	s3,s3,-874 # 80008298 <digits+0x258>
    printf("%d %s %s", p->pid, state, p->name);
    8000260a:	00006a97          	auipc	s5,0x6
    8000260e:	c96a8a93          	addi	s5,s5,-874 # 800082a0 <digits+0x260>
    printf("\n");
    80002612:	00006a17          	auipc	s4,0x6
    80002616:	ae6a0a13          	addi	s4,s4,-1306 # 800080f8 <digits+0xb8>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000261a:	00006b97          	auipc	s7,0x6
    8000261e:	cd6b8b93          	addi	s7,s7,-810 # 800082f0 <states.0>
    80002622:	a00d                	j	80002644 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002624:	ed86a583          	lw	a1,-296(a3)
    80002628:	8556                	mv	a0,s5
    8000262a:	ffffe097          	auipc	ra,0xffffe
    8000262e:	f4e080e7          	jalr	-178(ra) # 80000578 <printf>
    printf("\n");
    80002632:	8552                	mv	a0,s4
    80002634:	ffffe097          	auipc	ra,0xffffe
    80002638:	f44080e7          	jalr	-188(ra) # 80000578 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000263c:	38048493          	addi	s1,s1,896
    80002640:	03248263          	beq	s1,s2,80002664 <procdump+0x9a>
    if(p->state == UNUSED)
    80002644:	86a6                	mv	a3,s1
    80002646:	ec04a783          	lw	a5,-320(s1)
    8000264a:	dbed                	beqz	a5,8000263c <procdump+0x72>
      state = "???";
    8000264c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000264e:	fcfb6be3          	bltu	s6,a5,80002624 <procdump+0x5a>
    80002652:	02079713          	slli	a4,a5,0x20
    80002656:	01d75793          	srli	a5,a4,0x1d
    8000265a:	97de                	add	a5,a5,s7
    8000265c:	6390                	ld	a2,0(a5)
    8000265e:	f279                	bnez	a2,80002624 <procdump+0x5a>
      state = "???";
    80002660:	864e                	mv	a2,s3
    80002662:	b7c9                	j	80002624 <procdump+0x5a>
  }
}
    80002664:	60a6                	ld	ra,72(sp)
    80002666:	6406                	ld	s0,64(sp)
    80002668:	74e2                	ld	s1,56(sp)
    8000266a:	7942                	ld	s2,48(sp)
    8000266c:	79a2                	ld	s3,40(sp)
    8000266e:	7a02                	ld	s4,32(sp)
    80002670:	6ae2                	ld	s5,24(sp)
    80002672:	6b42                	ld	s6,16(sp)
    80002674:	6ba2                	ld	s7,8(sp)
    80002676:	6161                	addi	sp,sp,80
    80002678:	8082                	ret

000000008000267a <is_valid_sigmask>:

int 
is_valid_sigmask(int sigmask){
    8000267a:	1141                	addi	sp,sp,-16
    8000267c:	e422                	sd	s0,8(sp)
    8000267e:	0800                	addi	s0,sp,16
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002680:	000207b7          	lui	a5,0x20
    80002684:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    80002688:	8d7d                	and	a0,a0,a5
    return 0;
  return 1;
}
    8000268a:	00153513          	seqz	a0,a0
    8000268e:	6422                	ld	s0,8(sp)
    80002690:	0141                	addi	sp,sp,16
    80002692:	8082                	ret

0000000080002694 <sigprocmask>:

uint
sigprocmask(uint new_procmask){
    80002694:	7179                	addi	sp,sp,-48
    80002696:	f406                	sd	ra,40(sp)
    80002698:	f022                	sd	s0,32(sp)
    8000269a:	ec26                	sd	s1,24(sp)
    8000269c:	e84a                	sd	s2,16(sp)
    8000269e:	e44e                	sd	s3,8(sp)
    800026a0:	1800                	addi	s0,sp,48
    800026a2:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800026a4:	fffff097          	auipc	ra,0xfffff
    800026a8:	2f4080e7          	jalr	756(ra) # 80001998 <myproc>
  if(is_valid_sigmask(new_procmask) == 0)
    800026ac:	000207b7          	lui	a5,0x20
    800026b0:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    800026b4:	00f977b3          	and	a5,s2,a5
    return -1;
    800026b8:	59fd                	li	s3,-1
  if(is_valid_sigmask(new_procmask) == 0)
    800026ba:	ef99                	bnez	a5,800026d8 <sigprocmask+0x44>
    800026bc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800026be:	ffffe097          	auipc	ra,0xffffe
    800026c2:	508080e7          	jalr	1288(ra) # 80000bc6 <acquire>
  int old_procmask = p->signal_mask;
    800026c6:	16c4a983          	lw	s3,364(s1)
  p->signal_mask = new_procmask;
    800026ca:	1724a623          	sw	s2,364(s1)
  release(&p->lock);
    800026ce:	8526                	mv	a0,s1
    800026d0:	ffffe097          	auipc	ra,0xffffe
    800026d4:	5c0080e7          	jalr	1472(ra) # 80000c90 <release>
  
  return old_procmask;
}
    800026d8:	854e                	mv	a0,s3
    800026da:	70a2                	ld	ra,40(sp)
    800026dc:	7402                	ld	s0,32(sp)
    800026de:	64e2                	ld	s1,24(sp)
    800026e0:	6942                	ld	s2,16(sp)
    800026e2:	69a2                	ld	s3,8(sp)
    800026e4:	6145                	addi	sp,sp,48
    800026e6:	8082                	ret

00000000800026e8 <sigaction>:
 
int 
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP)
    800026e8:	0005079b          	sext.w	a5,a0
    800026ec:	477d                	li	a4,31
    800026ee:	08f76663          	bltu	a4,a5,8000277a <sigaction+0x92>
sigaction(int signum, const struct sigaction *act, struct sigaction *oldact){
    800026f2:	7179                	addi	sp,sp,-48
    800026f4:	f406                	sd	ra,40(sp)
    800026f6:	f022                	sd	s0,32(sp)
    800026f8:	ec26                	sd	s1,24(sp)
    800026fa:	e84a                	sd	s2,16(sp)
    800026fc:	e44e                	sd	s3,8(sp)
    800026fe:	e052                	sd	s4,0(sp)
    80002700:	1800                	addi	s0,sp,48
    80002702:	84aa                	mv	s1,a0
    80002704:	892e                	mv	s2,a1
    80002706:	8a32                	mv	s4,a2
  if(signum<0||signum>31 || signum == SIGKILL || signum == SIGSTOP)
    80002708:	37dd                	addiw	a5,a5,-9
    8000270a:	9bdd                	andi	a5,a5,-9
    8000270c:	2781                	sext.w	a5,a5
    8000270e:	cba5                	beqz	a5,8000277e <sigaction+0x96>
    return -1;
  if(act == 0||is_valid_sigmask(act->sigmask) == 0)
    80002710:	c9ad                	beqz	a1,80002782 <sigaction+0x9a>
  if((sigmask & (1<<SIGKILL)) || (sigmask & (1<<SIGSTOP)))
    80002712:	4598                	lw	a4,8(a1)
  if(act == 0||is_valid_sigmask(act->sigmask) == 0)
    80002714:	000207b7          	lui	a5,0x20
    80002718:	20078793          	addi	a5,a5,512 # 20200 <_entry-0x7ffdfe00>
    8000271c:	8ff9                	and	a5,a5,a4
    8000271e:	e7a5                	bnez	a5,80002786 <sigaction+0x9e>
    return -1;
  struct proc *p = myproc();
    80002720:	fffff097          	auipc	ra,0xfffff
    80002724:	278080e7          	jalr	632(ra) # 80001998 <myproc>
    80002728:	89aa                	mv	s3,a0
  acquire(&p->lock);
    8000272a:	ffffe097          	auipc	ra,0xffffe
    8000272e:	49c080e7          	jalr	1180(ra) # 80000bc6 <acquire>
  if(oldact!=0){
    80002732:	000a0d63          	beqz	s4,8000274c <sigaction+0x64>
    oldact->sa_handler = p->signal_handlers[signum].sa_handler;
    80002736:	00449793          	slli	a5,s1,0x4
    8000273a:	97ce                	add	a5,a5,s3
    8000273c:	1707b703          	ld	a4,368(a5)
    80002740:	00ea3023          	sd	a4,0(s4)
    oldact->sigmask = p->signal_handlers[signum].sigmask;
    80002744:	1787a783          	lw	a5,376(a5)
    80002748:	00fa2423          	sw	a5,8(s4)
  }
  p->signal_handlers[signum] = *act;
    8000274c:	04dd                	addi	s1,s1,23
    8000274e:	0492                	slli	s1,s1,0x4
    80002750:	94ce                	add	s1,s1,s3
    80002752:	00093783          	ld	a5,0(s2)
    80002756:	e09c                	sd	a5,0(s1)
    80002758:	00893783          	ld	a5,8(s2)
    8000275c:	e49c                	sd	a5,8(s1)
  release(&p->lock);
    8000275e:	854e                	mv	a0,s3
    80002760:	ffffe097          	auipc	ra,0xffffe
    80002764:	530080e7          	jalr	1328(ra) # 80000c90 <release>
  
  return 0;
    80002768:	4501                	li	a0,0
}
    8000276a:	70a2                	ld	ra,40(sp)
    8000276c:	7402                	ld	s0,32(sp)
    8000276e:	64e2                	ld	s1,24(sp)
    80002770:	6942                	ld	s2,16(sp)
    80002772:	69a2                	ld	s3,8(sp)
    80002774:	6a02                	ld	s4,0(sp)
    80002776:	6145                	addi	sp,sp,48
    80002778:	8082                	ret
    return -1;
    8000277a:	557d                	li	a0,-1
}
    8000277c:	8082                	ret
    return -1;
    8000277e:	557d                	li	a0,-1
    80002780:	b7ed                	j	8000276a <sigaction+0x82>
    return -1;
    80002782:	557d                	li	a0,-1
    80002784:	b7dd                	j	8000276a <sigaction+0x82>
    80002786:	557d                	li	a0,-1
    80002788:	b7cd                	j	8000276a <sigaction+0x82>

000000008000278a <sigret>:

void 
sigret(void){
    8000278a:	1141                	addi	sp,sp,-16
    8000278c:	e406                	sd	ra,8(sp)
    8000278e:	e022                	sd	s0,0(sp)
    80002790:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002792:	fffff097          	auipc	ra,0xfffff
    80002796:	206080e7          	jalr	518(ra) # 80001998 <myproc>
  if(p!=0&&p->user_trapframe_backup){
    8000279a:	cd09                	beqz	a0,800027b4 <sigret+0x2a>
    8000279c:	37053783          	ld	a5,880(a0)
    800027a0:	cb91                	beqz	a5,800027b4 <sigret+0x2a>
      memmove(p->trapframe, &(p->user_trapframe_backup),sizeof(struct trapframe));  
    800027a2:	12000613          	li	a2,288
    800027a6:	37050593          	addi	a1,a0,880
    800027aa:	6d28                	ld	a0,88(a0)
    800027ac:	ffffe097          	auipc	ra,0xffffe
    800027b0:	588080e7          	jalr	1416(ra) # 80000d34 <memmove>
  }
  printf("we shell never be here\n");
    800027b4:	00006517          	auipc	a0,0x6
    800027b8:	afc50513          	addi	a0,a0,-1284 # 800082b0 <digits+0x270>
    800027bc:	ffffe097          	auipc	ra,0xffffe
    800027c0:	dbc080e7          	jalr	-580(ra) # 80000578 <printf>
}
    800027c4:	60a2                	ld	ra,8(sp)
    800027c6:	6402                	ld	s0,0(sp)
    800027c8:	0141                	addi	sp,sp,16
    800027ca:	8082                	ret

00000000800027cc <swtch>:
    800027cc:	00153023          	sd	ra,0(a0)
    800027d0:	00253423          	sd	sp,8(a0)
    800027d4:	e900                	sd	s0,16(a0)
    800027d6:	ed04                	sd	s1,24(a0)
    800027d8:	03253023          	sd	s2,32(a0)
    800027dc:	03353423          	sd	s3,40(a0)
    800027e0:	03453823          	sd	s4,48(a0)
    800027e4:	03553c23          	sd	s5,56(a0)
    800027e8:	05653023          	sd	s6,64(a0)
    800027ec:	05753423          	sd	s7,72(a0)
    800027f0:	05853823          	sd	s8,80(a0)
    800027f4:	05953c23          	sd	s9,88(a0)
    800027f8:	07a53023          	sd	s10,96(a0)
    800027fc:	07b53423          	sd	s11,104(a0)
    80002800:	0005b083          	ld	ra,0(a1)
    80002804:	0085b103          	ld	sp,8(a1)
    80002808:	6980                	ld	s0,16(a1)
    8000280a:	6d84                	ld	s1,24(a1)
    8000280c:	0205b903          	ld	s2,32(a1)
    80002810:	0285b983          	ld	s3,40(a1)
    80002814:	0305ba03          	ld	s4,48(a1)
    80002818:	0385ba83          	ld	s5,56(a1)
    8000281c:	0405bb03          	ld	s6,64(a1)
    80002820:	0485bb83          	ld	s7,72(a1)
    80002824:	0505bc03          	ld	s8,80(a1)
    80002828:	0585bc83          	ld	s9,88(a1)
    8000282c:	0605bd03          	ld	s10,96(a1)
    80002830:	0685bd83          	ld	s11,104(a1)
    80002834:	8082                	ret

0000000080002836 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002836:	1141                	addi	sp,sp,-16
    80002838:	e406                	sd	ra,8(sp)
    8000283a:	e022                	sd	s0,0(sp)
    8000283c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000283e:	00006597          	auipc	a1,0x6
    80002842:	ae258593          	addi	a1,a1,-1310 # 80008320 <states.0+0x30>
    80002846:	0001d517          	auipc	a0,0x1d
    8000284a:	e8a50513          	addi	a0,a0,-374 # 8001f6d0 <tickslock>
    8000284e:	ffffe097          	auipc	ra,0xffffe
    80002852:	2e8080e7          	jalr	744(ra) # 80000b36 <initlock>
}
    80002856:	60a2                	ld	ra,8(sp)
    80002858:	6402                	ld	s0,0(sp)
    8000285a:	0141                	addi	sp,sp,16
    8000285c:	8082                	ret

000000008000285e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000285e:	1141                	addi	sp,sp,-16
    80002860:	e422                	sd	s0,8(sp)
    80002862:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002864:	00003797          	auipc	a5,0x3
    80002868:	6fc78793          	addi	a5,a5,1788 # 80005f60 <kernelvec>
    8000286c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002870:	6422                	ld	s0,8(sp)
    80002872:	0141                	addi	sp,sp,16
    80002874:	8082                	ret

0000000080002876 <handle_stop>:


  usertrapret();
}
void
handle_stop(struct proc* p){
    80002876:	1101                	addi	sp,sp,-32
    80002878:	ec06                	sd	ra,24(sp)
    8000287a:	e822                	sd	s0,16(sp)
    8000287c:	e426                	sd	s1,8(sp)
    8000287e:	e04a                	sd	s2,0(sp)
    80002880:	1000                	addi	s0,sp,32
    80002882:	84aa                	mv	s1,a0
  p->frozen=1;
    80002884:	4785                	li	a5,1
    80002886:	36f52c23          	sw	a5,888(a0)
  while ((p->pending_signals&1<<SIGCONT)==0)
    8000288a:	16852783          	lw	a5,360(a0)
    8000288e:	00080737          	lui	a4,0x80
    80002892:	8ff9                	and	a5,a5,a4
    80002894:	ef89                	bnez	a5,800028ae <handle_stop+0x38>
    80002896:	00080937          	lui	s2,0x80
  {
    // printf("in handle stop, yielding pid=%d \n",p->pid);//TODO delete
    yield();
    8000289a:	00000097          	auipc	ra,0x0
    8000289e:	80e080e7          	jalr	-2034(ra) # 800020a8 <yield>
  while ((p->pending_signals&1<<SIGCONT)==0)
    800028a2:	1684a783          	lw	a5,360(s1)
    800028a6:	0127f7b3          	and	a5,a5,s2
    800028aa:	2781                	sext.w	a5,a5
    800028ac:	d7fd                	beqz	a5,8000289a <handle_stop+0x24>
  }  
  p->frozen=0;
    800028ae:	3604ac23          	sw	zero,888(s1)
}
    800028b2:	60e2                	ld	ra,24(sp)
    800028b4:	6442                	ld	s0,16(sp)
    800028b6:	64a2                	ld	s1,8(sp)
    800028b8:	6902                	ld	s2,0(sp)
    800028ba:	6105                	addi	sp,sp,32
    800028bc:	8082                	ret

00000000800028be <backup_trapframe>:
//     p->handlingSignal=1;
//     return;                                                 
// }

void
backup_trapframe(struct trapframe *trap_frame_backup, struct trapframe *user_trap_frame){
    800028be:	1141                	addi	sp,sp,-16
    800028c0:	e406                	sd	ra,8(sp)
    800028c2:	e022                	sd	s0,0(sp)
    800028c4:	0800                	addi	s0,sp,16
  memmove(trap_frame_backup, user_trap_frame, sizeof(struct trapframe));
    800028c6:	12000613          	li	a2,288
    800028ca:	ffffe097          	auipc	ra,0xffffe
    800028ce:	46a080e7          	jalr	1130(ra) # 80000d34 <memmove>
}
    800028d2:	60a2                	ld	ra,8(sp)
    800028d4:	6402                	ld	s0,0(sp)
    800028d6:	0141                	addi	sp,sp,16
    800028d8:	8082                	ret

00000000800028da <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800028da:	1141                	addi	sp,sp,-16
    800028dc:	e406                	sd	ra,8(sp)
    800028de:	e022                	sd	s0,0(sp)
    800028e0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028e2:	fffff097          	auipc	ra,0xfffff
    800028e6:	0b6080e7          	jalr	182(ra) # 80001998 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ea:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028ee:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028f0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800028f4:	00004617          	auipc	a2,0x4
    800028f8:	70c60613          	addi	a2,a2,1804 # 80007000 <_trampoline>
    800028fc:	00004697          	auipc	a3,0x4
    80002900:	70468693          	addi	a3,a3,1796 # 80007000 <_trampoline>
    80002904:	8e91                	sub	a3,a3,a2
    80002906:	040007b7          	lui	a5,0x4000
    8000290a:	17fd                	addi	a5,a5,-1
    8000290c:	07b2                	slli	a5,a5,0xc
    8000290e:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002910:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002914:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002916:	180026f3          	csrr	a3,satp
    8000291a:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000291c:	6d38                	ld	a4,88(a0)
    8000291e:	6134                	ld	a3,64(a0)
    80002920:	6585                	lui	a1,0x1
    80002922:	96ae                	add	a3,a3,a1
    80002924:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002926:	6d38                	ld	a4,88(a0)
    80002928:	00000697          	auipc	a3,0x0
    8000292c:	22868693          	addi	a3,a3,552 # 80002b50 <usertrap>
    80002930:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002932:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002934:	8692                	mv	a3,tp
    80002936:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002938:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000293c:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002940:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002944:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002948:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000294a:	6f18                	ld	a4,24(a4)
    8000294c:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002950:	692c                	ld	a1,80(a0)
    80002952:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002954:	00004717          	auipc	a4,0x4
    80002958:	73c70713          	addi	a4,a4,1852 # 80007090 <userret>
    8000295c:	8f11                	sub	a4,a4,a2
    8000295e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002960:	577d                	li	a4,-1
    80002962:	177e                	slli	a4,a4,0x3f
    80002964:	8dd9                	or	a1,a1,a4
    80002966:	02000537          	lui	a0,0x2000
    8000296a:	157d                	addi	a0,a0,-1
    8000296c:	0536                	slli	a0,a0,0xd
    8000296e:	9782                	jalr	a5
}
    80002970:	60a2                	ld	ra,8(sp)
    80002972:	6402                	ld	s0,0(sp)
    80002974:	0141                	addi	sp,sp,16
    80002976:	8082                	ret

0000000080002978 <handle_user_signal>:
handle_user_signal(struct proc* p,int signum){
    80002978:	1141                	addi	sp,sp,-16
    8000297a:	e406                	sd	ra,8(sp)
    8000297c:	e022                	sd	s0,0(sp)
    8000297e:	0800                	addi	s0,sp,16
  usertrapret();
    80002980:	00000097          	auipc	ra,0x0
    80002984:	f5a080e7          	jalr	-166(ra) # 800028da <usertrapret>
}
    80002988:	60a2                	ld	ra,8(sp)
    8000298a:	6402                	ld	s0,0(sp)
    8000298c:	0141                	addi	sp,sp,16
    8000298e:	8082                	ret

0000000080002990 <check_pending_signals>:
check_pending_signals(struct proc* p){
    80002990:	711d                	addi	sp,sp,-96
    80002992:	ec86                	sd	ra,88(sp)
    80002994:	e8a2                	sd	s0,80(sp)
    80002996:	e4a6                	sd	s1,72(sp)
    80002998:	e0ca                	sd	s2,64(sp)
    8000299a:	fc4e                	sd	s3,56(sp)
    8000299c:	f852                	sd	s4,48(sp)
    8000299e:	f456                	sd	s5,40(sp)
    800029a0:	f05a                	sd	s6,32(sp)
    800029a2:	ec5e                	sd	s7,24(sp)
    800029a4:	e862                	sd	s8,16(sp)
    800029a6:	e466                	sd	s9,8(sp)
    800029a8:	e06a                	sd	s10,0(sp)
    800029aa:	1080                	addi	s0,sp,96
    800029ac:	89aa                	mv	s3,a0
  for(int sig_num=0;sig_num<32;sig_num++){
    800029ae:	17050a13          	addi	s4,a0,368 # 2000170 <_entry-0x7dfffe90>
    800029b2:	4481                	li	s1,0
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    800029b4:	4b05                	li	s6,1
      else if(act.sa_handler != (void*)SIG_IGN){ 
    800029b6:	4b85                	li	s7,1
        switch (sig_num)
    800029b8:	4cc5                	li	s9,17
    800029ba:	4c4d                	li	s8,19
  for(int sig_num=0;sig_num<32;sig_num++){
    800029bc:	02000a93          	li	s5,32
    800029c0:	a089                	j	80002a02 <check_pending_signals+0x72>
        switch (sig_num)
    800029c2:	03948163          	beq	s1,s9,800029e4 <check_pending_signals+0x54>
    800029c6:	09848063          	beq	s1,s8,80002a46 <check_pending_signals+0xb6>
              acquire(&p->lock);
    800029ca:	854e                	mv	a0,s3
    800029cc:	ffffe097          	auipc	ra,0xffffe
    800029d0:	1fa080e7          	jalr	506(ra) # 80000bc6 <acquire>
              p->killed = 1;
    800029d4:	0379a423          	sw	s7,40(s3)
              release(&p->lock);
    800029d8:	854e                	mv	a0,s3
    800029da:	ffffe097          	auipc	ra,0xffffe
    800029de:	2b6080e7          	jalr	694(ra) # 80000c90 <release>
    800029e2:	a031                	j	800029ee <check_pending_signals+0x5e>
              handle_stop(p);
    800029e4:	854e                	mv	a0,s3
    800029e6:	00000097          	auipc	ra,0x0
    800029ea:	e90080e7          	jalr	-368(ra) # 80002876 <handle_stop>
      p->pending_signals^=1<<sig_num;
    800029ee:	1689a783          	lw	a5,360(s3)
    800029f2:	0127c933          	xor	s2,a5,s2
    800029f6:	1729a423          	sw	s2,360(s3)
  for(int sig_num=0;sig_num<32;sig_num++){
    800029fa:	2485                	addiw	s1,s1,1
    800029fc:	0a41                	addi	s4,s4,16
    800029fe:	05548763          	beq	s1,s5,80002a4c <check_pending_signals+0xbc>
    if((p->pending_signals & (1<<sig_num))&& !(p->signal_mask&(1<<sig_num))){
    80002a02:	009b193b          	sllw	s2,s6,s1
    80002a06:	1689a783          	lw	a5,360(s3)
    80002a0a:	0127f7b3          	and	a5,a5,s2
    80002a0e:	2781                	sext.w	a5,a5
    80002a10:	d7ed                	beqz	a5,800029fa <check_pending_signals+0x6a>
    80002a12:	16c9ad03          	lw	s10,364(s3)
    80002a16:	012d77b3          	and	a5,s10,s2
    80002a1a:	2781                	sext.w	a5,a5
    80002a1c:	fff9                	bnez	a5,800029fa <check_pending_signals+0x6a>
      struct sigaction act = p->signal_handlers[sig_num];
    80002a1e:	000a3783          	ld	a5,0(s4)
      if(act.sa_handler == (void*)SIG_DFL){
    80002a22:	d3c5                	beqz	a5,800029c2 <check_pending_signals+0x32>
      else if(act.sa_handler != (void*)SIG_IGN){ 
    80002a24:	fd7785e3          	beq	a5,s7,800029ee <check_pending_signals+0x5e>
        backup_trapframe(p->user_trapframe_backup, p->trapframe);
    80002a28:	0589b583          	ld	a1,88(s3)
    80002a2c:	3709b503          	ld	a0,880(s3)
    80002a30:	00000097          	auipc	ra,0x0
    80002a34:	e8e080e7          	jalr	-370(ra) # 800028be <backup_trapframe>
  usertrapret();
    80002a38:	00000097          	auipc	ra,0x0
    80002a3c:	ea2080e7          	jalr	-350(ra) # 800028da <usertrapret>
        p->signal_mask = original_mask;
    80002a40:	17a9a623          	sw	s10,364(s3)
    80002a44:	b76d                	j	800029ee <check_pending_signals+0x5e>
            p->frozen = 0;
    80002a46:	3609ac23          	sw	zero,888(s3)
            break;
    80002a4a:	b755                	j	800029ee <check_pending_signals+0x5e>
}
    80002a4c:	60e6                	ld	ra,88(sp)
    80002a4e:	6446                	ld	s0,80(sp)
    80002a50:	64a6                	ld	s1,72(sp)
    80002a52:	6906                	ld	s2,64(sp)
    80002a54:	79e2                	ld	s3,56(sp)
    80002a56:	7a42                	ld	s4,48(sp)
    80002a58:	7aa2                	ld	s5,40(sp)
    80002a5a:	7b02                	ld	s6,32(sp)
    80002a5c:	6be2                	ld	s7,24(sp)
    80002a5e:	6c42                	ld	s8,16(sp)
    80002a60:	6ca2                	ld	s9,8(sp)
    80002a62:	6d02                	ld	s10,0(sp)
    80002a64:	6125                	addi	sp,sp,96
    80002a66:	8082                	ret

0000000080002a68 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a68:	1101                	addi	sp,sp,-32
    80002a6a:	ec06                	sd	ra,24(sp)
    80002a6c:	e822                	sd	s0,16(sp)
    80002a6e:	e426                	sd	s1,8(sp)
    80002a70:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002a72:	0001d497          	auipc	s1,0x1d
    80002a76:	c5e48493          	addi	s1,s1,-930 # 8001f6d0 <tickslock>
    80002a7a:	8526                	mv	a0,s1
    80002a7c:	ffffe097          	auipc	ra,0xffffe
    80002a80:	14a080e7          	jalr	330(ra) # 80000bc6 <acquire>
  ticks++;
    80002a84:	00006517          	auipc	a0,0x6
    80002a88:	5ac50513          	addi	a0,a0,1452 # 80009030 <ticks>
    80002a8c:	411c                	lw	a5,0(a0)
    80002a8e:	2785                	addiw	a5,a5,1
    80002a90:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002a92:	fffff097          	auipc	ra,0xfffff
    80002a96:	7e0080e7          	jalr	2016(ra) # 80002272 <wakeup>
  release(&tickslock);
    80002a9a:	8526                	mv	a0,s1
    80002a9c:	ffffe097          	auipc	ra,0xffffe
    80002aa0:	1f4080e7          	jalr	500(ra) # 80000c90 <release>
}
    80002aa4:	60e2                	ld	ra,24(sp)
    80002aa6:	6442                	ld	s0,16(sp)
    80002aa8:	64a2                	ld	s1,8(sp)
    80002aaa:	6105                	addi	sp,sp,32
    80002aac:	8082                	ret

0000000080002aae <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002aae:	1101                	addi	sp,sp,-32
    80002ab0:	ec06                	sd	ra,24(sp)
    80002ab2:	e822                	sd	s0,16(sp)
    80002ab4:	e426                	sd	s1,8(sp)
    80002ab6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ab8:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002abc:	00074d63          	bltz	a4,80002ad6 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002ac0:	57fd                	li	a5,-1
    80002ac2:	17fe                	slli	a5,a5,0x3f
    80002ac4:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002ac6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002ac8:	06f70363          	beq	a4,a5,80002b2e <devintr+0x80>
  }
}
    80002acc:	60e2                	ld	ra,24(sp)
    80002ace:	6442                	ld	s0,16(sp)
    80002ad0:	64a2                	ld	s1,8(sp)
    80002ad2:	6105                	addi	sp,sp,32
    80002ad4:	8082                	ret
     (scause & 0xff) == 9){
    80002ad6:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002ada:	46a5                	li	a3,9
    80002adc:	fed792e3          	bne	a5,a3,80002ac0 <devintr+0x12>
    int irq = plic_claim();
    80002ae0:	00003097          	auipc	ra,0x3
    80002ae4:	588080e7          	jalr	1416(ra) # 80006068 <plic_claim>
    80002ae8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002aea:	47a9                	li	a5,10
    80002aec:	02f50763          	beq	a0,a5,80002b1a <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002af0:	4785                	li	a5,1
    80002af2:	02f50963          	beq	a0,a5,80002b24 <devintr+0x76>
    return 1;
    80002af6:	4505                	li	a0,1
    } else if(irq){
    80002af8:	d8f1                	beqz	s1,80002acc <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002afa:	85a6                	mv	a1,s1
    80002afc:	00006517          	auipc	a0,0x6
    80002b00:	82c50513          	addi	a0,a0,-2004 # 80008328 <states.0+0x38>
    80002b04:	ffffe097          	auipc	ra,0xffffe
    80002b08:	a74080e7          	jalr	-1420(ra) # 80000578 <printf>
      plic_complete(irq);
    80002b0c:	8526                	mv	a0,s1
    80002b0e:	00003097          	auipc	ra,0x3
    80002b12:	57e080e7          	jalr	1406(ra) # 8000608c <plic_complete>
    return 1;
    80002b16:	4505                	li	a0,1
    80002b18:	bf55                	j	80002acc <devintr+0x1e>
      uartintr();
    80002b1a:	ffffe097          	auipc	ra,0xffffe
    80002b1e:	e70080e7          	jalr	-400(ra) # 8000098a <uartintr>
    80002b22:	b7ed                	j	80002b0c <devintr+0x5e>
      virtio_disk_intr();
    80002b24:	00004097          	auipc	ra,0x4
    80002b28:	9fa080e7          	jalr	-1542(ra) # 8000651e <virtio_disk_intr>
    80002b2c:	b7c5                	j	80002b0c <devintr+0x5e>
    if(cpuid() == 0){
    80002b2e:	fffff097          	auipc	ra,0xfffff
    80002b32:	e3e080e7          	jalr	-450(ra) # 8000196c <cpuid>
    80002b36:	c901                	beqz	a0,80002b46 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b38:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b3c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b3e:	14479073          	csrw	sip,a5
    return 2;
    80002b42:	4509                	li	a0,2
    80002b44:	b761                	j	80002acc <devintr+0x1e>
      clockintr();
    80002b46:	00000097          	auipc	ra,0x0
    80002b4a:	f22080e7          	jalr	-222(ra) # 80002a68 <clockintr>
    80002b4e:	b7ed                	j	80002b38 <devintr+0x8a>

0000000080002b50 <usertrap>:
{
    80002b50:	1101                	addi	sp,sp,-32
    80002b52:	ec06                	sd	ra,24(sp)
    80002b54:	e822                	sd	s0,16(sp)
    80002b56:	e426                	sd	s1,8(sp)
    80002b58:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b5a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b5e:	1007f793          	andi	a5,a5,256
    80002b62:	ebad                	bnez	a5,80002bd4 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b64:	00003797          	auipc	a5,0x3
    80002b68:	3fc78793          	addi	a5,a5,1020 # 80005f60 <kernelvec>
    80002b6c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b70:	fffff097          	auipc	ra,0xfffff
    80002b74:	e28080e7          	jalr	-472(ra) # 80001998 <myproc>
    80002b78:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b7a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b7c:	14102773          	csrr	a4,sepc
    80002b80:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b82:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b86:	47a1                	li	a5,8
    80002b88:	06f71463          	bne	a4,a5,80002bf0 <usertrap+0xa0>
    if(p->killed==1)
    80002b8c:	5518                	lw	a4,40(a0)
    80002b8e:	4785                	li	a5,1
    80002b90:	04f70a63          	beq	a4,a5,80002be4 <usertrap+0x94>
    p->trapframe->epc += 4;
    80002b94:	6cb8                	ld	a4,88(s1)
    80002b96:	6f1c                	ld	a5,24(a4)
    80002b98:	0791                	addi	a5,a5,4
    80002b9a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002ba0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ba4:	10079073          	csrw	sstatus,a5
    syscall();
    80002ba8:	00000097          	auipc	ra,0x0
    80002bac:	2e4080e7          	jalr	740(ra) # 80002e8c <syscall>
  check_pending_signals(p);
    80002bb0:	8526                	mv	a0,s1
    80002bb2:	00000097          	auipc	ra,0x0
    80002bb6:	dde080e7          	jalr	-546(ra) # 80002990 <check_pending_signals>
  if(p->killed==1)
    80002bba:	5498                	lw	a4,40(s1)
    80002bbc:	4785                	li	a5,1
    80002bbe:	08f70063          	beq	a4,a5,80002c3e <usertrap+0xee>
  usertrapret();
    80002bc2:	00000097          	auipc	ra,0x0
    80002bc6:	d18080e7          	jalr	-744(ra) # 800028da <usertrapret>
}
    80002bca:	60e2                	ld	ra,24(sp)
    80002bcc:	6442                	ld	s0,16(sp)
    80002bce:	64a2                	ld	s1,8(sp)
    80002bd0:	6105                	addi	sp,sp,32
    80002bd2:	8082                	ret
    panic("usertrap: not from user mode");
    80002bd4:	00005517          	auipc	a0,0x5
    80002bd8:	77450513          	addi	a0,a0,1908 # 80008348 <states.0+0x58>
    80002bdc:	ffffe097          	auipc	ra,0xffffe
    80002be0:	952080e7          	jalr	-1710(ra) # 8000052e <panic>
      exit(-1);
    80002be4:	557d                	li	a0,-1
    80002be6:	fffff097          	auipc	ra,0xfffff
    80002bea:	75c080e7          	jalr	1884(ra) # 80002342 <exit>
    80002bee:	b75d                	j	80002b94 <usertrap+0x44>
  else if((which_dev = devintr()) != 0){
    80002bf0:	00000097          	auipc	ra,0x0
    80002bf4:	ebe080e7          	jalr	-322(ra) # 80002aae <devintr>
    80002bf8:	c909                	beqz	a0,80002c0a <usertrap+0xba>
  if(which_dev == 2)
    80002bfa:	4789                	li	a5,2
    80002bfc:	faf51ae3          	bne	a0,a5,80002bb0 <usertrap+0x60>
    yield();
    80002c00:	fffff097          	auipc	ra,0xfffff
    80002c04:	4a8080e7          	jalr	1192(ra) # 800020a8 <yield>
    80002c08:	b765                	j	80002bb0 <usertrap+0x60>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c0a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c0e:	5890                	lw	a2,48(s1)
    80002c10:	00005517          	auipc	a0,0x5
    80002c14:	75850513          	addi	a0,a0,1880 # 80008368 <states.0+0x78>
    80002c18:	ffffe097          	auipc	ra,0xffffe
    80002c1c:	960080e7          	jalr	-1696(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c20:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c24:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c28:	00005517          	auipc	a0,0x5
    80002c2c:	77050513          	addi	a0,a0,1904 # 80008398 <states.0+0xa8>
    80002c30:	ffffe097          	auipc	ra,0xffffe
    80002c34:	948080e7          	jalr	-1720(ra) # 80000578 <printf>
    p->killed = 1;
    80002c38:	4785                	li	a5,1
    80002c3a:	d49c                	sw	a5,40(s1)
  if(which_dev == 2)
    80002c3c:	bf95                	j	80002bb0 <usertrap+0x60>
    exit(-1);
    80002c3e:	557d                	li	a0,-1
    80002c40:	fffff097          	auipc	ra,0xfffff
    80002c44:	702080e7          	jalr	1794(ra) # 80002342 <exit>
    80002c48:	bfad                	j	80002bc2 <usertrap+0x72>

0000000080002c4a <kerneltrap>:
{
    80002c4a:	7179                	addi	sp,sp,-48
    80002c4c:	f406                	sd	ra,40(sp)
    80002c4e:	f022                	sd	s0,32(sp)
    80002c50:	ec26                	sd	s1,24(sp)
    80002c52:	e84a                	sd	s2,16(sp)
    80002c54:	e44e                	sd	s3,8(sp)
    80002c56:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c58:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c5c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c60:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c64:	1004f793          	andi	a5,s1,256
    80002c68:	cb85                	beqz	a5,80002c98 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c6a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c6e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c70:	ef85                	bnez	a5,80002ca8 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002c72:	00000097          	auipc	ra,0x0
    80002c76:	e3c080e7          	jalr	-452(ra) # 80002aae <devintr>
    80002c7a:	cd1d                	beqz	a0,80002cb8 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c7c:	4789                	li	a5,2
    80002c7e:	06f50a63          	beq	a0,a5,80002cf2 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c82:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c86:	10049073          	csrw	sstatus,s1
}
    80002c8a:	70a2                	ld	ra,40(sp)
    80002c8c:	7402                	ld	s0,32(sp)
    80002c8e:	64e2                	ld	s1,24(sp)
    80002c90:	6942                	ld	s2,16(sp)
    80002c92:	69a2                	ld	s3,8(sp)
    80002c94:	6145                	addi	sp,sp,48
    80002c96:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c98:	00005517          	auipc	a0,0x5
    80002c9c:	72050513          	addi	a0,a0,1824 # 800083b8 <states.0+0xc8>
    80002ca0:	ffffe097          	auipc	ra,0xffffe
    80002ca4:	88e080e7          	jalr	-1906(ra) # 8000052e <panic>
    panic("kerneltrap: interrupts enabled");
    80002ca8:	00005517          	auipc	a0,0x5
    80002cac:	73850513          	addi	a0,a0,1848 # 800083e0 <states.0+0xf0>
    80002cb0:	ffffe097          	auipc	ra,0xffffe
    80002cb4:	87e080e7          	jalr	-1922(ra) # 8000052e <panic>
    printf("scause %p\n", scause);
    80002cb8:	85ce                	mv	a1,s3
    80002cba:	00005517          	auipc	a0,0x5
    80002cbe:	74650513          	addi	a0,a0,1862 # 80008400 <states.0+0x110>
    80002cc2:	ffffe097          	auipc	ra,0xffffe
    80002cc6:	8b6080e7          	jalr	-1866(ra) # 80000578 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cca:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cce:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002cd2:	00005517          	auipc	a0,0x5
    80002cd6:	73e50513          	addi	a0,a0,1854 # 80008410 <states.0+0x120>
    80002cda:	ffffe097          	auipc	ra,0xffffe
    80002cde:	89e080e7          	jalr	-1890(ra) # 80000578 <printf>
    panic("kerneltrap");
    80002ce2:	00005517          	auipc	a0,0x5
    80002ce6:	74650513          	addi	a0,a0,1862 # 80008428 <states.0+0x138>
    80002cea:	ffffe097          	auipc	ra,0xffffe
    80002cee:	844080e7          	jalr	-1980(ra) # 8000052e <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cf2:	fffff097          	auipc	ra,0xfffff
    80002cf6:	ca6080e7          	jalr	-858(ra) # 80001998 <myproc>
    80002cfa:	d541                	beqz	a0,80002c82 <kerneltrap+0x38>
    80002cfc:	fffff097          	auipc	ra,0xfffff
    80002d00:	c9c080e7          	jalr	-868(ra) # 80001998 <myproc>
    80002d04:	4d18                	lw	a4,24(a0)
    80002d06:	4791                	li	a5,4
    80002d08:	f6f71de3          	bne	a4,a5,80002c82 <kerneltrap+0x38>
    yield();
    80002d0c:	fffff097          	auipc	ra,0xfffff
    80002d10:	39c080e7          	jalr	924(ra) # 800020a8 <yield>
    80002d14:	b7bd                	j	80002c82 <kerneltrap+0x38>

0000000080002d16 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d16:	1101                	addi	sp,sp,-32
    80002d18:	ec06                	sd	ra,24(sp)
    80002d1a:	e822                	sd	s0,16(sp)
    80002d1c:	e426                	sd	s1,8(sp)
    80002d1e:	1000                	addi	s0,sp,32
    80002d20:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d22:	fffff097          	auipc	ra,0xfffff
    80002d26:	c76080e7          	jalr	-906(ra) # 80001998 <myproc>
  switch (n) {
    80002d2a:	4795                	li	a5,5
    80002d2c:	0497e163          	bltu	a5,s1,80002d6e <argraw+0x58>
    80002d30:	048a                	slli	s1,s1,0x2
    80002d32:	00005717          	auipc	a4,0x5
    80002d36:	72e70713          	addi	a4,a4,1838 # 80008460 <states.0+0x170>
    80002d3a:	94ba                	add	s1,s1,a4
    80002d3c:	409c                	lw	a5,0(s1)
    80002d3e:	97ba                	add	a5,a5,a4
    80002d40:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d42:	6d3c                	ld	a5,88(a0)
    80002d44:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d46:	60e2                	ld	ra,24(sp)
    80002d48:	6442                	ld	s0,16(sp)
    80002d4a:	64a2                	ld	s1,8(sp)
    80002d4c:	6105                	addi	sp,sp,32
    80002d4e:	8082                	ret
    return p->trapframe->a1;
    80002d50:	6d3c                	ld	a5,88(a0)
    80002d52:	7fa8                	ld	a0,120(a5)
    80002d54:	bfcd                	j	80002d46 <argraw+0x30>
    return p->trapframe->a2;
    80002d56:	6d3c                	ld	a5,88(a0)
    80002d58:	63c8                	ld	a0,128(a5)
    80002d5a:	b7f5                	j	80002d46 <argraw+0x30>
    return p->trapframe->a3;
    80002d5c:	6d3c                	ld	a5,88(a0)
    80002d5e:	67c8                	ld	a0,136(a5)
    80002d60:	b7dd                	j	80002d46 <argraw+0x30>
    return p->trapframe->a4;
    80002d62:	6d3c                	ld	a5,88(a0)
    80002d64:	6bc8                	ld	a0,144(a5)
    80002d66:	b7c5                	j	80002d46 <argraw+0x30>
    return p->trapframe->a5;
    80002d68:	6d3c                	ld	a5,88(a0)
    80002d6a:	6fc8                	ld	a0,152(a5)
    80002d6c:	bfe9                	j	80002d46 <argraw+0x30>
  panic("argraw");
    80002d6e:	00005517          	auipc	a0,0x5
    80002d72:	6ca50513          	addi	a0,a0,1738 # 80008438 <states.0+0x148>
    80002d76:	ffffd097          	auipc	ra,0xffffd
    80002d7a:	7b8080e7          	jalr	1976(ra) # 8000052e <panic>

0000000080002d7e <fetchaddr>:
{
    80002d7e:	1101                	addi	sp,sp,-32
    80002d80:	ec06                	sd	ra,24(sp)
    80002d82:	e822                	sd	s0,16(sp)
    80002d84:	e426                	sd	s1,8(sp)
    80002d86:	e04a                	sd	s2,0(sp)
    80002d88:	1000                	addi	s0,sp,32
    80002d8a:	84aa                	mv	s1,a0
    80002d8c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d8e:	fffff097          	auipc	ra,0xfffff
    80002d92:	c0a080e7          	jalr	-1014(ra) # 80001998 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002d96:	653c                	ld	a5,72(a0)
    80002d98:	02f4f863          	bgeu	s1,a5,80002dc8 <fetchaddr+0x4a>
    80002d9c:	00848713          	addi	a4,s1,8
    80002da0:	02e7e663          	bltu	a5,a4,80002dcc <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002da4:	46a1                	li	a3,8
    80002da6:	8626                	mv	a2,s1
    80002da8:	85ca                	mv	a1,s2
    80002daa:	6928                	ld	a0,80(a0)
    80002dac:	fffff097          	auipc	ra,0xfffff
    80002db0:	938080e7          	jalr	-1736(ra) # 800016e4 <copyin>
    80002db4:	00a03533          	snez	a0,a0
    80002db8:	40a00533          	neg	a0,a0
}
    80002dbc:	60e2                	ld	ra,24(sp)
    80002dbe:	6442                	ld	s0,16(sp)
    80002dc0:	64a2                	ld	s1,8(sp)
    80002dc2:	6902                	ld	s2,0(sp)
    80002dc4:	6105                	addi	sp,sp,32
    80002dc6:	8082                	ret
    return -1;
    80002dc8:	557d                	li	a0,-1
    80002dca:	bfcd                	j	80002dbc <fetchaddr+0x3e>
    80002dcc:	557d                	li	a0,-1
    80002dce:	b7fd                	j	80002dbc <fetchaddr+0x3e>

0000000080002dd0 <fetchstr>:
{
    80002dd0:	7179                	addi	sp,sp,-48
    80002dd2:	f406                	sd	ra,40(sp)
    80002dd4:	f022                	sd	s0,32(sp)
    80002dd6:	ec26                	sd	s1,24(sp)
    80002dd8:	e84a                	sd	s2,16(sp)
    80002dda:	e44e                	sd	s3,8(sp)
    80002ddc:	1800                	addi	s0,sp,48
    80002dde:	892a                	mv	s2,a0
    80002de0:	84ae                	mv	s1,a1
    80002de2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002de4:	fffff097          	auipc	ra,0xfffff
    80002de8:	bb4080e7          	jalr	-1100(ra) # 80001998 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002dec:	86ce                	mv	a3,s3
    80002dee:	864a                	mv	a2,s2
    80002df0:	85a6                	mv	a1,s1
    80002df2:	6928                	ld	a0,80(a0)
    80002df4:	fffff097          	auipc	ra,0xfffff
    80002df8:	97e080e7          	jalr	-1666(ra) # 80001772 <copyinstr>
  if(err < 0)
    80002dfc:	00054763          	bltz	a0,80002e0a <fetchstr+0x3a>
  return strlen(buf);
    80002e00:	8526                	mv	a0,s1
    80002e02:	ffffe097          	auipc	ra,0xffffe
    80002e06:	05a080e7          	jalr	90(ra) # 80000e5c <strlen>
}
    80002e0a:	70a2                	ld	ra,40(sp)
    80002e0c:	7402                	ld	s0,32(sp)
    80002e0e:	64e2                	ld	s1,24(sp)
    80002e10:	6942                	ld	s2,16(sp)
    80002e12:	69a2                	ld	s3,8(sp)
    80002e14:	6145                	addi	sp,sp,48
    80002e16:	8082                	ret

0000000080002e18 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002e18:	1101                	addi	sp,sp,-32
    80002e1a:	ec06                	sd	ra,24(sp)
    80002e1c:	e822                	sd	s0,16(sp)
    80002e1e:	e426                	sd	s1,8(sp)
    80002e20:	1000                	addi	s0,sp,32
    80002e22:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e24:	00000097          	auipc	ra,0x0
    80002e28:	ef2080e7          	jalr	-270(ra) # 80002d16 <argraw>
    80002e2c:	c088                	sw	a0,0(s1)
  return 0;
}
    80002e2e:	4501                	li	a0,0
    80002e30:	60e2                	ld	ra,24(sp)
    80002e32:	6442                	ld	s0,16(sp)
    80002e34:	64a2                	ld	s1,8(sp)
    80002e36:	6105                	addi	sp,sp,32
    80002e38:	8082                	ret

0000000080002e3a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002e3a:	1101                	addi	sp,sp,-32
    80002e3c:	ec06                	sd	ra,24(sp)
    80002e3e:	e822                	sd	s0,16(sp)
    80002e40:	e426                	sd	s1,8(sp)
    80002e42:	1000                	addi	s0,sp,32
    80002e44:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e46:	00000097          	auipc	ra,0x0
    80002e4a:	ed0080e7          	jalr	-304(ra) # 80002d16 <argraw>
    80002e4e:	e088                	sd	a0,0(s1)
  return 0;
}
    80002e50:	4501                	li	a0,0
    80002e52:	60e2                	ld	ra,24(sp)
    80002e54:	6442                	ld	s0,16(sp)
    80002e56:	64a2                	ld	s1,8(sp)
    80002e58:	6105                	addi	sp,sp,32
    80002e5a:	8082                	ret

0000000080002e5c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e5c:	1101                	addi	sp,sp,-32
    80002e5e:	ec06                	sd	ra,24(sp)
    80002e60:	e822                	sd	s0,16(sp)
    80002e62:	e426                	sd	s1,8(sp)
    80002e64:	e04a                	sd	s2,0(sp)
    80002e66:	1000                	addi	s0,sp,32
    80002e68:	84ae                	mv	s1,a1
    80002e6a:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002e6c:	00000097          	auipc	ra,0x0
    80002e70:	eaa080e7          	jalr	-342(ra) # 80002d16 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002e74:	864a                	mv	a2,s2
    80002e76:	85a6                	mv	a1,s1
    80002e78:	00000097          	auipc	ra,0x0
    80002e7c:	f58080e7          	jalr	-168(ra) # 80002dd0 <fetchstr>
}
    80002e80:	60e2                	ld	ra,24(sp)
    80002e82:	6442                	ld	s0,16(sp)
    80002e84:	64a2                	ld	s1,8(sp)
    80002e86:	6902                	ld	s2,0(sp)
    80002e88:	6105                	addi	sp,sp,32
    80002e8a:	8082                	ret

0000000080002e8c <syscall>:
[SYS_sigret] sys_sigret,
};

void
syscall(void)
{
    80002e8c:	1101                	addi	sp,sp,-32
    80002e8e:	ec06                	sd	ra,24(sp)
    80002e90:	e822                	sd	s0,16(sp)
    80002e92:	e426                	sd	s1,8(sp)
    80002e94:	e04a                	sd	s2,0(sp)
    80002e96:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e98:	fffff097          	auipc	ra,0xfffff
    80002e9c:	b00080e7          	jalr	-1280(ra) # 80001998 <myproc>
    80002ea0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ea2:	05853903          	ld	s2,88(a0)
    80002ea6:	0a893783          	ld	a5,168(s2) # 800a8 <_entry-0x7ff7ff58>
    80002eaa:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002eae:	37fd                	addiw	a5,a5,-1
    80002eb0:	475d                	li	a4,23
    80002eb2:	00f76f63          	bltu	a4,a5,80002ed0 <syscall+0x44>
    80002eb6:	00369713          	slli	a4,a3,0x3
    80002eba:	00005797          	auipc	a5,0x5
    80002ebe:	5be78793          	addi	a5,a5,1470 # 80008478 <syscalls>
    80002ec2:	97ba                	add	a5,a5,a4
    80002ec4:	639c                	ld	a5,0(a5)
    80002ec6:	c789                	beqz	a5,80002ed0 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002ec8:	9782                	jalr	a5
    80002eca:	06a93823          	sd	a0,112(s2)
    80002ece:	a839                	j	80002eec <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002ed0:	15848613          	addi	a2,s1,344
    80002ed4:	588c                	lw	a1,48(s1)
    80002ed6:	00005517          	auipc	a0,0x5
    80002eda:	56a50513          	addi	a0,a0,1386 # 80008440 <states.0+0x150>
    80002ede:	ffffd097          	auipc	ra,0xffffd
    80002ee2:	69a080e7          	jalr	1690(ra) # 80000578 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ee6:	6cbc                	ld	a5,88(s1)
    80002ee8:	577d                	li	a4,-1
    80002eea:	fbb8                	sd	a4,112(a5)
  }
}
    80002eec:	60e2                	ld	ra,24(sp)
    80002eee:	6442                	ld	s0,16(sp)
    80002ef0:	64a2                	ld	s1,8(sp)
    80002ef2:	6902                	ld	s2,0(sp)
    80002ef4:	6105                	addi	sp,sp,32
    80002ef6:	8082                	ret

0000000080002ef8 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002ef8:	1101                	addi	sp,sp,-32
    80002efa:	ec06                	sd	ra,24(sp)
    80002efc:	e822                	sd	s0,16(sp)
    80002efe:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002f00:	fec40593          	addi	a1,s0,-20
    80002f04:	4501                	li	a0,0
    80002f06:	00000097          	auipc	ra,0x0
    80002f0a:	f12080e7          	jalr	-238(ra) # 80002e18 <argint>
    return -1;
    80002f0e:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f10:	00054963          	bltz	a0,80002f22 <sys_exit+0x2a>
  exit(n);
    80002f14:	fec42503          	lw	a0,-20(s0)
    80002f18:	fffff097          	auipc	ra,0xfffff
    80002f1c:	42a080e7          	jalr	1066(ra) # 80002342 <exit>
  return 0;  // not reached
    80002f20:	4781                	li	a5,0
}
    80002f22:	853e                	mv	a0,a5
    80002f24:	60e2                	ld	ra,24(sp)
    80002f26:	6442                	ld	s0,16(sp)
    80002f28:	6105                	addi	sp,sp,32
    80002f2a:	8082                	ret

0000000080002f2c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f2c:	1141                	addi	sp,sp,-16
    80002f2e:	e406                	sd	ra,8(sp)
    80002f30:	e022                	sd	s0,0(sp)
    80002f32:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f34:	fffff097          	auipc	ra,0xfffff
    80002f38:	a64080e7          	jalr	-1436(ra) # 80001998 <myproc>
}
    80002f3c:	5908                	lw	a0,48(a0)
    80002f3e:	60a2                	ld	ra,8(sp)
    80002f40:	6402                	ld	s0,0(sp)
    80002f42:	0141                	addi	sp,sp,16
    80002f44:	8082                	ret

0000000080002f46 <sys_fork>:

uint64
sys_fork(void)
{
    80002f46:	1141                	addi	sp,sp,-16
    80002f48:	e406                	sd	ra,8(sp)
    80002f4a:	e022                	sd	s0,0(sp)
    80002f4c:	0800                	addi	s0,sp,16
  return fork();
    80002f4e:	fffff097          	auipc	ra,0xfffff
    80002f52:	e74080e7          	jalr	-396(ra) # 80001dc2 <fork>
}
    80002f56:	60a2                	ld	ra,8(sp)
    80002f58:	6402                	ld	s0,0(sp)
    80002f5a:	0141                	addi	sp,sp,16
    80002f5c:	8082                	ret

0000000080002f5e <sys_wait>:

uint64
sys_wait(void)
{
    80002f5e:	1101                	addi	sp,sp,-32
    80002f60:	ec06                	sd	ra,24(sp)
    80002f62:	e822                	sd	s0,16(sp)
    80002f64:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002f66:	fe840593          	addi	a1,s0,-24
    80002f6a:	4501                	li	a0,0
    80002f6c:	00000097          	auipc	ra,0x0
    80002f70:	ece080e7          	jalr	-306(ra) # 80002e3a <argaddr>
    80002f74:	87aa                	mv	a5,a0
    return -1;
    80002f76:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002f78:	0007c863          	bltz	a5,80002f88 <sys_wait+0x2a>
  return wait(p);
    80002f7c:	fe843503          	ld	a0,-24(s0)
    80002f80:	fffff097          	auipc	ra,0xfffff
    80002f84:	1c8080e7          	jalr	456(ra) # 80002148 <wait>
}
    80002f88:	60e2                	ld	ra,24(sp)
    80002f8a:	6442                	ld	s0,16(sp)
    80002f8c:	6105                	addi	sp,sp,32
    80002f8e:	8082                	ret

0000000080002f90 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f90:	7179                	addi	sp,sp,-48
    80002f92:	f406                	sd	ra,40(sp)
    80002f94:	f022                	sd	s0,32(sp)
    80002f96:	ec26                	sd	s1,24(sp)
    80002f98:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002f9a:	fdc40593          	addi	a1,s0,-36
    80002f9e:	4501                	li	a0,0
    80002fa0:	00000097          	auipc	ra,0x0
    80002fa4:	e78080e7          	jalr	-392(ra) # 80002e18 <argint>
    return -1;
    80002fa8:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002faa:	00054f63          	bltz	a0,80002fc8 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002fae:	fffff097          	auipc	ra,0xfffff
    80002fb2:	9ea080e7          	jalr	-1558(ra) # 80001998 <myproc>
    80002fb6:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002fb8:	fdc42503          	lw	a0,-36(s0)
    80002fbc:	fffff097          	auipc	ra,0xfffff
    80002fc0:	d92080e7          	jalr	-622(ra) # 80001d4e <growproc>
    80002fc4:	00054863          	bltz	a0,80002fd4 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002fc8:	8526                	mv	a0,s1
    80002fca:	70a2                	ld	ra,40(sp)
    80002fcc:	7402                	ld	s0,32(sp)
    80002fce:	64e2                	ld	s1,24(sp)
    80002fd0:	6145                	addi	sp,sp,48
    80002fd2:	8082                	ret
    return -1;
    80002fd4:	54fd                	li	s1,-1
    80002fd6:	bfcd                	j	80002fc8 <sys_sbrk+0x38>

0000000080002fd8 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002fd8:	7139                	addi	sp,sp,-64
    80002fda:	fc06                	sd	ra,56(sp)
    80002fdc:	f822                	sd	s0,48(sp)
    80002fde:	f426                	sd	s1,40(sp)
    80002fe0:	f04a                	sd	s2,32(sp)
    80002fe2:	ec4e                	sd	s3,24(sp)
    80002fe4:	e852                	sd	s4,16(sp)
    80002fe6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002fe8:	fcc40593          	addi	a1,s0,-52
    80002fec:	4501                	li	a0,0
    80002fee:	00000097          	auipc	ra,0x0
    80002ff2:	e2a080e7          	jalr	-470(ra) # 80002e18 <argint>
    return -1;
    80002ff6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ff8:	06054763          	bltz	a0,80003066 <sys_sleep+0x8e>
  acquire(&tickslock);
    80002ffc:	0001c517          	auipc	a0,0x1c
    80003000:	6d450513          	addi	a0,a0,1748 # 8001f6d0 <tickslock>
    80003004:	ffffe097          	auipc	ra,0xffffe
    80003008:	bc2080e7          	jalr	-1086(ra) # 80000bc6 <acquire>
  ticks0 = ticks;
    8000300c:	00006997          	auipc	s3,0x6
    80003010:	0249a983          	lw	s3,36(s3) # 80009030 <ticks>
  while(ticks - ticks0 < n){
    80003014:	fcc42783          	lw	a5,-52(s0)
    80003018:	cf95                	beqz	a5,80003054 <sys_sleep+0x7c>
    if(myproc()->killed==1){
    8000301a:	4905                	li	s2,1
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000301c:	0001ca17          	auipc	s4,0x1c
    80003020:	6b4a0a13          	addi	s4,s4,1716 # 8001f6d0 <tickslock>
    80003024:	00006497          	auipc	s1,0x6
    80003028:	00c48493          	addi	s1,s1,12 # 80009030 <ticks>
    if(myproc()->killed==1){
    8000302c:	fffff097          	auipc	ra,0xfffff
    80003030:	96c080e7          	jalr	-1684(ra) # 80001998 <myproc>
    80003034:	551c                	lw	a5,40(a0)
    80003036:	05278163          	beq	a5,s2,80003078 <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    8000303a:	85d2                	mv	a1,s4
    8000303c:	8526                	mv	a0,s1
    8000303e:	fffff097          	auipc	ra,0xfffff
    80003042:	0a6080e7          	jalr	166(ra) # 800020e4 <sleep>
  while(ticks - ticks0 < n){
    80003046:	409c                	lw	a5,0(s1)
    80003048:	413787bb          	subw	a5,a5,s3
    8000304c:	fcc42703          	lw	a4,-52(s0)
    80003050:	fce7eee3          	bltu	a5,a4,8000302c <sys_sleep+0x54>
  }
  release(&tickslock);
    80003054:	0001c517          	auipc	a0,0x1c
    80003058:	67c50513          	addi	a0,a0,1660 # 8001f6d0 <tickslock>
    8000305c:	ffffe097          	auipc	ra,0xffffe
    80003060:	c34080e7          	jalr	-972(ra) # 80000c90 <release>
  return 0;
    80003064:	4781                	li	a5,0
}
    80003066:	853e                	mv	a0,a5
    80003068:	70e2                	ld	ra,56(sp)
    8000306a:	7442                	ld	s0,48(sp)
    8000306c:	74a2                	ld	s1,40(sp)
    8000306e:	7902                	ld	s2,32(sp)
    80003070:	69e2                	ld	s3,24(sp)
    80003072:	6a42                	ld	s4,16(sp)
    80003074:	6121                	addi	sp,sp,64
    80003076:	8082                	ret
      release(&tickslock);
    80003078:	0001c517          	auipc	a0,0x1c
    8000307c:	65850513          	addi	a0,a0,1624 # 8001f6d0 <tickslock>
    80003080:	ffffe097          	auipc	ra,0xffffe
    80003084:	c10080e7          	jalr	-1008(ra) # 80000c90 <release>
      return -1;
    80003088:	57fd                	li	a5,-1
    8000308a:	bff1                	j	80003066 <sys_sleep+0x8e>

000000008000308c <sys_kill>:

uint64
sys_kill(void)
{
    8000308c:	1101                	addi	sp,sp,-32
    8000308e:	ec06                	sd	ra,24(sp)
    80003090:	e822                	sd	s0,16(sp)
    80003092:	1000                	addi	s0,sp,32
  int pid;
  int signum;

  if(argint(0, &pid) < 0)
    80003094:	fec40593          	addi	a1,s0,-20
    80003098:	4501                	li	a0,0
    8000309a:	00000097          	auipc	ra,0x0
    8000309e:	d7e080e7          	jalr	-642(ra) # 80002e18 <argint>
    800030a2:	87aa                	mv	a5,a0
    return -1;
    800030a4:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800030a6:	0207c963          	bltz	a5,800030d8 <sys_kill+0x4c>
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    800030aa:	fe840593          	addi	a1,s0,-24
    800030ae:	4505                	li	a0,1
    800030b0:	00000097          	auipc	ra,0x0
    800030b4:	d68080e7          	jalr	-664(ra) # 80002e18 <argint>
    800030b8:	02054463          	bltz	a0,800030e0 <sys_kill+0x54>
    800030bc:	fe842583          	lw	a1,-24(s0)
    800030c0:	0005871b          	sext.w	a4,a1
    800030c4:	47fd                	li	a5,31
    return -1;
    800030c6:	557d                	li	a0,-1
  if(argint(1,&signum) < 0 || signum>31 || signum < 0)
    800030c8:	00e7e863          	bltu	a5,a4,800030d8 <sys_kill+0x4c>
  return kill(pid, signum);
    800030cc:	fec42503          	lw	a0,-20(s0)
    800030d0:	fffff097          	auipc	ra,0xfffff
    800030d4:	348080e7          	jalr	840(ra) # 80002418 <kill>
}
    800030d8:	60e2                	ld	ra,24(sp)
    800030da:	6442                	ld	s0,16(sp)
    800030dc:	6105                	addi	sp,sp,32
    800030de:	8082                	ret
    return -1;
    800030e0:	557d                	li	a0,-1
    800030e2:	bfdd                	j	800030d8 <sys_kill+0x4c>

00000000800030e4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030e4:	1101                	addi	sp,sp,-32
    800030e6:	ec06                	sd	ra,24(sp)
    800030e8:	e822                	sd	s0,16(sp)
    800030ea:	e426                	sd	s1,8(sp)
    800030ec:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030ee:	0001c517          	auipc	a0,0x1c
    800030f2:	5e250513          	addi	a0,a0,1506 # 8001f6d0 <tickslock>
    800030f6:	ffffe097          	auipc	ra,0xffffe
    800030fa:	ad0080e7          	jalr	-1328(ra) # 80000bc6 <acquire>
  xticks = ticks;
    800030fe:	00006497          	auipc	s1,0x6
    80003102:	f324a483          	lw	s1,-206(s1) # 80009030 <ticks>
  release(&tickslock);
    80003106:	0001c517          	auipc	a0,0x1c
    8000310a:	5ca50513          	addi	a0,a0,1482 # 8001f6d0 <tickslock>
    8000310e:	ffffe097          	auipc	ra,0xffffe
    80003112:	b82080e7          	jalr	-1150(ra) # 80000c90 <release>
  return xticks;
}
    80003116:	02049513          	slli	a0,s1,0x20
    8000311a:	9101                	srli	a0,a0,0x20
    8000311c:	60e2                	ld	ra,24(sp)
    8000311e:	6442                	ld	s0,16(sp)
    80003120:	64a2                	ld	s1,8(sp)
    80003122:	6105                	addi	sp,sp,32
    80003124:	8082                	ret

0000000080003126 <sys_sigprocmask>:

uint64
sys_sigprocmask(void)
{
    80003126:	1101                	addi	sp,sp,-32
    80003128:	ec06                	sd	ra,24(sp)
    8000312a:	e822                	sd	s0,16(sp)
    8000312c:	1000                	addi	s0,sp,32
  int sigmask;

  if(argint(0, &sigmask) < 0)
    8000312e:	fec40593          	addi	a1,s0,-20
    80003132:	4501                	li	a0,0
    80003134:	00000097          	auipc	ra,0x0
    80003138:	ce4080e7          	jalr	-796(ra) # 80002e18 <argint>
    8000313c:	87aa                	mv	a5,a0
    return -1;
    8000313e:	557d                	li	a0,-1
  if(argint(0, &sigmask) < 0)
    80003140:	0007ca63          	bltz	a5,80003154 <sys_sigprocmask+0x2e>
  return sigprocmask((uint)sigmask);
    80003144:	fec42503          	lw	a0,-20(s0)
    80003148:	fffff097          	auipc	ra,0xfffff
    8000314c:	54c080e7          	jalr	1356(ra) # 80002694 <sigprocmask>
    80003150:	1502                	slli	a0,a0,0x20
    80003152:	9101                	srli	a0,a0,0x20
}
    80003154:	60e2                	ld	ra,24(sp)
    80003156:	6442                	ld	s0,16(sp)
    80003158:	6105                	addi	sp,sp,32
    8000315a:	8082                	ret

000000008000315c <sys_sigaction>:

uint64
sys_sigaction(void)
{
    8000315c:	7179                	addi	sp,sp,-48
    8000315e:	f406                	sd	ra,40(sp)
    80003160:	f022                	sd	s0,32(sp)
    80003162:	1800                	addi	s0,sp,48
  int signum;
  uint64 newact;
  uint64 oldact;
  
  if(argint(0, &signum) < 0)
    80003164:	fec40593          	addi	a1,s0,-20
    80003168:	4501                	li	a0,0
    8000316a:	00000097          	auipc	ra,0x0
    8000316e:	cae080e7          	jalr	-850(ra) # 80002e18 <argint>
    return -1;
    80003172:	57fd                	li	a5,-1
  if(argint(0, &signum) < 0)
    80003174:	04054163          	bltz	a0,800031b6 <sys_sigaction+0x5a>
  if(argaddr(1, &newact) < 0)
    80003178:	fe040593          	addi	a1,s0,-32
    8000317c:	4505                	li	a0,1
    8000317e:	00000097          	auipc	ra,0x0
    80003182:	cbc080e7          	jalr	-836(ra) # 80002e3a <argaddr>
    return -1;
    80003186:	57fd                	li	a5,-1
  if(argaddr(1, &newact) < 0)
    80003188:	02054763          	bltz	a0,800031b6 <sys_sigaction+0x5a>
  if(argaddr(1, &oldact) < 0)
    8000318c:	fd840593          	addi	a1,s0,-40
    80003190:	4505                	li	a0,1
    80003192:	00000097          	auipc	ra,0x0
    80003196:	ca8080e7          	jalr	-856(ra) # 80002e3a <argaddr>
    return -1;
    8000319a:	57fd                	li	a5,-1
  if(argaddr(1, &oldact) < 0)
    8000319c:	00054d63          	bltz	a0,800031b6 <sys_sigaction+0x5a>

  return sigaction(signum,newact,oldact);
    800031a0:	fd843603          	ld	a2,-40(s0)
    800031a4:	fe043583          	ld	a1,-32(s0)
    800031a8:	fec42503          	lw	a0,-20(s0)
    800031ac:	fffff097          	auipc	ra,0xfffff
    800031b0:	53c080e7          	jalr	1340(ra) # 800026e8 <sigaction>
    800031b4:	87aa                	mv	a5,a0
  
}
    800031b6:	853e                	mv	a0,a5
    800031b8:	70a2                	ld	ra,40(sp)
    800031ba:	7402                	ld	s0,32(sp)
    800031bc:	6145                	addi	sp,sp,48
    800031be:	8082                	ret

00000000800031c0 <sys_sigret>:
uint64
sys_sigret(void)
{
    800031c0:	1141                	addi	sp,sp,-16
    800031c2:	e406                	sd	ra,8(sp)
    800031c4:	e022                	sd	s0,0(sp)
    800031c6:	0800                	addi	s0,sp,16
  sigret();
    800031c8:	fffff097          	auipc	ra,0xfffff
    800031cc:	5c2080e7          	jalr	1474(ra) # 8000278a <sigret>
  return 0;
}
    800031d0:	4501                	li	a0,0
    800031d2:	60a2                	ld	ra,8(sp)
    800031d4:	6402                	ld	s0,0(sp)
    800031d6:	0141                	addi	sp,sp,16
    800031d8:	8082                	ret

00000000800031da <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800031da:	7179                	addi	sp,sp,-48
    800031dc:	f406                	sd	ra,40(sp)
    800031de:	f022                	sd	s0,32(sp)
    800031e0:	ec26                	sd	s1,24(sp)
    800031e2:	e84a                	sd	s2,16(sp)
    800031e4:	e44e                	sd	s3,8(sp)
    800031e6:	e052                	sd	s4,0(sp)
    800031e8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800031ea:	00005597          	auipc	a1,0x5
    800031ee:	35658593          	addi	a1,a1,854 # 80008540 <syscalls+0xc8>
    800031f2:	0001c517          	auipc	a0,0x1c
    800031f6:	4f650513          	addi	a0,a0,1270 # 8001f6e8 <bcache>
    800031fa:	ffffe097          	auipc	ra,0xffffe
    800031fe:	93c080e7          	jalr	-1732(ra) # 80000b36 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003202:	00024797          	auipc	a5,0x24
    80003206:	4e678793          	addi	a5,a5,1254 # 800276e8 <bcache+0x8000>
    8000320a:	00024717          	auipc	a4,0x24
    8000320e:	74670713          	addi	a4,a4,1862 # 80027950 <bcache+0x8268>
    80003212:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003216:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000321a:	0001c497          	auipc	s1,0x1c
    8000321e:	4e648493          	addi	s1,s1,1254 # 8001f700 <bcache+0x18>
    b->next = bcache.head.next;
    80003222:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003224:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003226:	00005a17          	auipc	s4,0x5
    8000322a:	322a0a13          	addi	s4,s4,802 # 80008548 <syscalls+0xd0>
    b->next = bcache.head.next;
    8000322e:	2b893783          	ld	a5,696(s2)
    80003232:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003234:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003238:	85d2                	mv	a1,s4
    8000323a:	01048513          	addi	a0,s1,16
    8000323e:	00001097          	auipc	ra,0x1
    80003242:	4c2080e7          	jalr	1218(ra) # 80004700 <initsleeplock>
    bcache.head.next->prev = b;
    80003246:	2b893783          	ld	a5,696(s2)
    8000324a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000324c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003250:	45848493          	addi	s1,s1,1112
    80003254:	fd349de3          	bne	s1,s3,8000322e <binit+0x54>
  }
}
    80003258:	70a2                	ld	ra,40(sp)
    8000325a:	7402                	ld	s0,32(sp)
    8000325c:	64e2                	ld	s1,24(sp)
    8000325e:	6942                	ld	s2,16(sp)
    80003260:	69a2                	ld	s3,8(sp)
    80003262:	6a02                	ld	s4,0(sp)
    80003264:	6145                	addi	sp,sp,48
    80003266:	8082                	ret

0000000080003268 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003268:	7179                	addi	sp,sp,-48
    8000326a:	f406                	sd	ra,40(sp)
    8000326c:	f022                	sd	s0,32(sp)
    8000326e:	ec26                	sd	s1,24(sp)
    80003270:	e84a                	sd	s2,16(sp)
    80003272:	e44e                	sd	s3,8(sp)
    80003274:	1800                	addi	s0,sp,48
    80003276:	892a                	mv	s2,a0
    80003278:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000327a:	0001c517          	auipc	a0,0x1c
    8000327e:	46e50513          	addi	a0,a0,1134 # 8001f6e8 <bcache>
    80003282:	ffffe097          	auipc	ra,0xffffe
    80003286:	944080e7          	jalr	-1724(ra) # 80000bc6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000328a:	00024497          	auipc	s1,0x24
    8000328e:	7164b483          	ld	s1,1814(s1) # 800279a0 <bcache+0x82b8>
    80003292:	00024797          	auipc	a5,0x24
    80003296:	6be78793          	addi	a5,a5,1726 # 80027950 <bcache+0x8268>
    8000329a:	02f48f63          	beq	s1,a5,800032d8 <bread+0x70>
    8000329e:	873e                	mv	a4,a5
    800032a0:	a021                	j	800032a8 <bread+0x40>
    800032a2:	68a4                	ld	s1,80(s1)
    800032a4:	02e48a63          	beq	s1,a4,800032d8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800032a8:	449c                	lw	a5,8(s1)
    800032aa:	ff279ce3          	bne	a5,s2,800032a2 <bread+0x3a>
    800032ae:	44dc                	lw	a5,12(s1)
    800032b0:	ff3799e3          	bne	a5,s3,800032a2 <bread+0x3a>
      b->refcnt++;
    800032b4:	40bc                	lw	a5,64(s1)
    800032b6:	2785                	addiw	a5,a5,1
    800032b8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800032ba:	0001c517          	auipc	a0,0x1c
    800032be:	42e50513          	addi	a0,a0,1070 # 8001f6e8 <bcache>
    800032c2:	ffffe097          	auipc	ra,0xffffe
    800032c6:	9ce080e7          	jalr	-1586(ra) # 80000c90 <release>
      acquiresleep(&b->lock);
    800032ca:	01048513          	addi	a0,s1,16
    800032ce:	00001097          	auipc	ra,0x1
    800032d2:	46c080e7          	jalr	1132(ra) # 8000473a <acquiresleep>
      return b;
    800032d6:	a8b9                	j	80003334 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800032d8:	00024497          	auipc	s1,0x24
    800032dc:	6c04b483          	ld	s1,1728(s1) # 80027998 <bcache+0x82b0>
    800032e0:	00024797          	auipc	a5,0x24
    800032e4:	67078793          	addi	a5,a5,1648 # 80027950 <bcache+0x8268>
    800032e8:	00f48863          	beq	s1,a5,800032f8 <bread+0x90>
    800032ec:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800032ee:	40bc                	lw	a5,64(s1)
    800032f0:	cf81                	beqz	a5,80003308 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800032f2:	64a4                	ld	s1,72(s1)
    800032f4:	fee49de3          	bne	s1,a4,800032ee <bread+0x86>
  panic("bget: no buffers");
    800032f8:	00005517          	auipc	a0,0x5
    800032fc:	25850513          	addi	a0,a0,600 # 80008550 <syscalls+0xd8>
    80003300:	ffffd097          	auipc	ra,0xffffd
    80003304:	22e080e7          	jalr	558(ra) # 8000052e <panic>
      b->dev = dev;
    80003308:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000330c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003310:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003314:	4785                	li	a5,1
    80003316:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003318:	0001c517          	auipc	a0,0x1c
    8000331c:	3d050513          	addi	a0,a0,976 # 8001f6e8 <bcache>
    80003320:	ffffe097          	auipc	ra,0xffffe
    80003324:	970080e7          	jalr	-1680(ra) # 80000c90 <release>
      acquiresleep(&b->lock);
    80003328:	01048513          	addi	a0,s1,16
    8000332c:	00001097          	auipc	ra,0x1
    80003330:	40e080e7          	jalr	1038(ra) # 8000473a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003334:	409c                	lw	a5,0(s1)
    80003336:	cb89                	beqz	a5,80003348 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003338:	8526                	mv	a0,s1
    8000333a:	70a2                	ld	ra,40(sp)
    8000333c:	7402                	ld	s0,32(sp)
    8000333e:	64e2                	ld	s1,24(sp)
    80003340:	6942                	ld	s2,16(sp)
    80003342:	69a2                	ld	s3,8(sp)
    80003344:	6145                	addi	sp,sp,48
    80003346:	8082                	ret
    virtio_disk_rw(b, 0);
    80003348:	4581                	li	a1,0
    8000334a:	8526                	mv	a0,s1
    8000334c:	00003097          	auipc	ra,0x3
    80003350:	f4a080e7          	jalr	-182(ra) # 80006296 <virtio_disk_rw>
    b->valid = 1;
    80003354:	4785                	li	a5,1
    80003356:	c09c                	sw	a5,0(s1)
  return b;
    80003358:	b7c5                	j	80003338 <bread+0xd0>

000000008000335a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000335a:	1101                	addi	sp,sp,-32
    8000335c:	ec06                	sd	ra,24(sp)
    8000335e:	e822                	sd	s0,16(sp)
    80003360:	e426                	sd	s1,8(sp)
    80003362:	1000                	addi	s0,sp,32
    80003364:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003366:	0541                	addi	a0,a0,16
    80003368:	00001097          	auipc	ra,0x1
    8000336c:	46c080e7          	jalr	1132(ra) # 800047d4 <holdingsleep>
    80003370:	cd01                	beqz	a0,80003388 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003372:	4585                	li	a1,1
    80003374:	8526                	mv	a0,s1
    80003376:	00003097          	auipc	ra,0x3
    8000337a:	f20080e7          	jalr	-224(ra) # 80006296 <virtio_disk_rw>
}
    8000337e:	60e2                	ld	ra,24(sp)
    80003380:	6442                	ld	s0,16(sp)
    80003382:	64a2                	ld	s1,8(sp)
    80003384:	6105                	addi	sp,sp,32
    80003386:	8082                	ret
    panic("bwrite");
    80003388:	00005517          	auipc	a0,0x5
    8000338c:	1e050513          	addi	a0,a0,480 # 80008568 <syscalls+0xf0>
    80003390:	ffffd097          	auipc	ra,0xffffd
    80003394:	19e080e7          	jalr	414(ra) # 8000052e <panic>

0000000080003398 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003398:	1101                	addi	sp,sp,-32
    8000339a:	ec06                	sd	ra,24(sp)
    8000339c:	e822                	sd	s0,16(sp)
    8000339e:	e426                	sd	s1,8(sp)
    800033a0:	e04a                	sd	s2,0(sp)
    800033a2:	1000                	addi	s0,sp,32
    800033a4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033a6:	01050913          	addi	s2,a0,16
    800033aa:	854a                	mv	a0,s2
    800033ac:	00001097          	auipc	ra,0x1
    800033b0:	428080e7          	jalr	1064(ra) # 800047d4 <holdingsleep>
    800033b4:	c92d                	beqz	a0,80003426 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800033b6:	854a                	mv	a0,s2
    800033b8:	00001097          	auipc	ra,0x1
    800033bc:	3d8080e7          	jalr	984(ra) # 80004790 <releasesleep>

  acquire(&bcache.lock);
    800033c0:	0001c517          	auipc	a0,0x1c
    800033c4:	32850513          	addi	a0,a0,808 # 8001f6e8 <bcache>
    800033c8:	ffffd097          	auipc	ra,0xffffd
    800033cc:	7fe080e7          	jalr	2046(ra) # 80000bc6 <acquire>
  b->refcnt--;
    800033d0:	40bc                	lw	a5,64(s1)
    800033d2:	37fd                	addiw	a5,a5,-1
    800033d4:	0007871b          	sext.w	a4,a5
    800033d8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800033da:	eb05                	bnez	a4,8000340a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800033dc:	68bc                	ld	a5,80(s1)
    800033de:	64b8                	ld	a4,72(s1)
    800033e0:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800033e2:	64bc                	ld	a5,72(s1)
    800033e4:	68b8                	ld	a4,80(s1)
    800033e6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800033e8:	00024797          	auipc	a5,0x24
    800033ec:	30078793          	addi	a5,a5,768 # 800276e8 <bcache+0x8000>
    800033f0:	2b87b703          	ld	a4,696(a5)
    800033f4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800033f6:	00024717          	auipc	a4,0x24
    800033fa:	55a70713          	addi	a4,a4,1370 # 80027950 <bcache+0x8268>
    800033fe:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003400:	2b87b703          	ld	a4,696(a5)
    80003404:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003406:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000340a:	0001c517          	auipc	a0,0x1c
    8000340e:	2de50513          	addi	a0,a0,734 # 8001f6e8 <bcache>
    80003412:	ffffe097          	auipc	ra,0xffffe
    80003416:	87e080e7          	jalr	-1922(ra) # 80000c90 <release>
}
    8000341a:	60e2                	ld	ra,24(sp)
    8000341c:	6442                	ld	s0,16(sp)
    8000341e:	64a2                	ld	s1,8(sp)
    80003420:	6902                	ld	s2,0(sp)
    80003422:	6105                	addi	sp,sp,32
    80003424:	8082                	ret
    panic("brelse");
    80003426:	00005517          	auipc	a0,0x5
    8000342a:	14a50513          	addi	a0,a0,330 # 80008570 <syscalls+0xf8>
    8000342e:	ffffd097          	auipc	ra,0xffffd
    80003432:	100080e7          	jalr	256(ra) # 8000052e <panic>

0000000080003436 <bpin>:

void
bpin(struct buf *b) {
    80003436:	1101                	addi	sp,sp,-32
    80003438:	ec06                	sd	ra,24(sp)
    8000343a:	e822                	sd	s0,16(sp)
    8000343c:	e426                	sd	s1,8(sp)
    8000343e:	1000                	addi	s0,sp,32
    80003440:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003442:	0001c517          	auipc	a0,0x1c
    80003446:	2a650513          	addi	a0,a0,678 # 8001f6e8 <bcache>
    8000344a:	ffffd097          	auipc	ra,0xffffd
    8000344e:	77c080e7          	jalr	1916(ra) # 80000bc6 <acquire>
  b->refcnt++;
    80003452:	40bc                	lw	a5,64(s1)
    80003454:	2785                	addiw	a5,a5,1
    80003456:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003458:	0001c517          	auipc	a0,0x1c
    8000345c:	29050513          	addi	a0,a0,656 # 8001f6e8 <bcache>
    80003460:	ffffe097          	auipc	ra,0xffffe
    80003464:	830080e7          	jalr	-2000(ra) # 80000c90 <release>
}
    80003468:	60e2                	ld	ra,24(sp)
    8000346a:	6442                	ld	s0,16(sp)
    8000346c:	64a2                	ld	s1,8(sp)
    8000346e:	6105                	addi	sp,sp,32
    80003470:	8082                	ret

0000000080003472 <bunpin>:

void
bunpin(struct buf *b) {
    80003472:	1101                	addi	sp,sp,-32
    80003474:	ec06                	sd	ra,24(sp)
    80003476:	e822                	sd	s0,16(sp)
    80003478:	e426                	sd	s1,8(sp)
    8000347a:	1000                	addi	s0,sp,32
    8000347c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000347e:	0001c517          	auipc	a0,0x1c
    80003482:	26a50513          	addi	a0,a0,618 # 8001f6e8 <bcache>
    80003486:	ffffd097          	auipc	ra,0xffffd
    8000348a:	740080e7          	jalr	1856(ra) # 80000bc6 <acquire>
  b->refcnt--;
    8000348e:	40bc                	lw	a5,64(s1)
    80003490:	37fd                	addiw	a5,a5,-1
    80003492:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003494:	0001c517          	auipc	a0,0x1c
    80003498:	25450513          	addi	a0,a0,596 # 8001f6e8 <bcache>
    8000349c:	ffffd097          	auipc	ra,0xffffd
    800034a0:	7f4080e7          	jalr	2036(ra) # 80000c90 <release>
}
    800034a4:	60e2                	ld	ra,24(sp)
    800034a6:	6442                	ld	s0,16(sp)
    800034a8:	64a2                	ld	s1,8(sp)
    800034aa:	6105                	addi	sp,sp,32
    800034ac:	8082                	ret

00000000800034ae <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800034ae:	1101                	addi	sp,sp,-32
    800034b0:	ec06                	sd	ra,24(sp)
    800034b2:	e822                	sd	s0,16(sp)
    800034b4:	e426                	sd	s1,8(sp)
    800034b6:	e04a                	sd	s2,0(sp)
    800034b8:	1000                	addi	s0,sp,32
    800034ba:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800034bc:	00d5d59b          	srliw	a1,a1,0xd
    800034c0:	00025797          	auipc	a5,0x25
    800034c4:	9047a783          	lw	a5,-1788(a5) # 80027dc4 <sb+0x1c>
    800034c8:	9dbd                	addw	a1,a1,a5
    800034ca:	00000097          	auipc	ra,0x0
    800034ce:	d9e080e7          	jalr	-610(ra) # 80003268 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800034d2:	0074f713          	andi	a4,s1,7
    800034d6:	4785                	li	a5,1
    800034d8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800034dc:	14ce                	slli	s1,s1,0x33
    800034de:	90d9                	srli	s1,s1,0x36
    800034e0:	00950733          	add	a4,a0,s1
    800034e4:	05874703          	lbu	a4,88(a4)
    800034e8:	00e7f6b3          	and	a3,a5,a4
    800034ec:	c69d                	beqz	a3,8000351a <bfree+0x6c>
    800034ee:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800034f0:	94aa                	add	s1,s1,a0
    800034f2:	fff7c793          	not	a5,a5
    800034f6:	8ff9                	and	a5,a5,a4
    800034f8:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800034fc:	00001097          	auipc	ra,0x1
    80003500:	11e080e7          	jalr	286(ra) # 8000461a <log_write>
  brelse(bp);
    80003504:	854a                	mv	a0,s2
    80003506:	00000097          	auipc	ra,0x0
    8000350a:	e92080e7          	jalr	-366(ra) # 80003398 <brelse>
}
    8000350e:	60e2                	ld	ra,24(sp)
    80003510:	6442                	ld	s0,16(sp)
    80003512:	64a2                	ld	s1,8(sp)
    80003514:	6902                	ld	s2,0(sp)
    80003516:	6105                	addi	sp,sp,32
    80003518:	8082                	ret
    panic("freeing free block");
    8000351a:	00005517          	auipc	a0,0x5
    8000351e:	05e50513          	addi	a0,a0,94 # 80008578 <syscalls+0x100>
    80003522:	ffffd097          	auipc	ra,0xffffd
    80003526:	00c080e7          	jalr	12(ra) # 8000052e <panic>

000000008000352a <balloc>:
{
    8000352a:	711d                	addi	sp,sp,-96
    8000352c:	ec86                	sd	ra,88(sp)
    8000352e:	e8a2                	sd	s0,80(sp)
    80003530:	e4a6                	sd	s1,72(sp)
    80003532:	e0ca                	sd	s2,64(sp)
    80003534:	fc4e                	sd	s3,56(sp)
    80003536:	f852                	sd	s4,48(sp)
    80003538:	f456                	sd	s5,40(sp)
    8000353a:	f05a                	sd	s6,32(sp)
    8000353c:	ec5e                	sd	s7,24(sp)
    8000353e:	e862                	sd	s8,16(sp)
    80003540:	e466                	sd	s9,8(sp)
    80003542:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003544:	00025797          	auipc	a5,0x25
    80003548:	8687a783          	lw	a5,-1944(a5) # 80027dac <sb+0x4>
    8000354c:	cbd1                	beqz	a5,800035e0 <balloc+0xb6>
    8000354e:	8baa                	mv	s7,a0
    80003550:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003552:	00025b17          	auipc	s6,0x25
    80003556:	856b0b13          	addi	s6,s6,-1962 # 80027da8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000355a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000355c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000355e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003560:	6c89                	lui	s9,0x2
    80003562:	a831                	j	8000357e <balloc+0x54>
    brelse(bp);
    80003564:	854a                	mv	a0,s2
    80003566:	00000097          	auipc	ra,0x0
    8000356a:	e32080e7          	jalr	-462(ra) # 80003398 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000356e:	015c87bb          	addw	a5,s9,s5
    80003572:	00078a9b          	sext.w	s5,a5
    80003576:	004b2703          	lw	a4,4(s6)
    8000357a:	06eaf363          	bgeu	s5,a4,800035e0 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    8000357e:	41fad79b          	sraiw	a5,s5,0x1f
    80003582:	0137d79b          	srliw	a5,a5,0x13
    80003586:	015787bb          	addw	a5,a5,s5
    8000358a:	40d7d79b          	sraiw	a5,a5,0xd
    8000358e:	01cb2583          	lw	a1,28(s6)
    80003592:	9dbd                	addw	a1,a1,a5
    80003594:	855e                	mv	a0,s7
    80003596:	00000097          	auipc	ra,0x0
    8000359a:	cd2080e7          	jalr	-814(ra) # 80003268 <bread>
    8000359e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035a0:	004b2503          	lw	a0,4(s6)
    800035a4:	000a849b          	sext.w	s1,s5
    800035a8:	8662                	mv	a2,s8
    800035aa:	faa4fde3          	bgeu	s1,a0,80003564 <balloc+0x3a>
      m = 1 << (bi % 8);
    800035ae:	41f6579b          	sraiw	a5,a2,0x1f
    800035b2:	01d7d69b          	srliw	a3,a5,0x1d
    800035b6:	00c6873b          	addw	a4,a3,a2
    800035ba:	00777793          	andi	a5,a4,7
    800035be:	9f95                	subw	a5,a5,a3
    800035c0:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800035c4:	4037571b          	sraiw	a4,a4,0x3
    800035c8:	00e906b3          	add	a3,s2,a4
    800035cc:	0586c683          	lbu	a3,88(a3)
    800035d0:	00d7f5b3          	and	a1,a5,a3
    800035d4:	cd91                	beqz	a1,800035f0 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035d6:	2605                	addiw	a2,a2,1
    800035d8:	2485                	addiw	s1,s1,1
    800035da:	fd4618e3          	bne	a2,s4,800035aa <balloc+0x80>
    800035de:	b759                	j	80003564 <balloc+0x3a>
  panic("balloc: out of blocks");
    800035e0:	00005517          	auipc	a0,0x5
    800035e4:	fb050513          	addi	a0,a0,-80 # 80008590 <syscalls+0x118>
    800035e8:	ffffd097          	auipc	ra,0xffffd
    800035ec:	f46080e7          	jalr	-186(ra) # 8000052e <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800035f0:	974a                	add	a4,a4,s2
    800035f2:	8fd5                	or	a5,a5,a3
    800035f4:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    800035f8:	854a                	mv	a0,s2
    800035fa:	00001097          	auipc	ra,0x1
    800035fe:	020080e7          	jalr	32(ra) # 8000461a <log_write>
        brelse(bp);
    80003602:	854a                	mv	a0,s2
    80003604:	00000097          	auipc	ra,0x0
    80003608:	d94080e7          	jalr	-620(ra) # 80003398 <brelse>
  bp = bread(dev, bno);
    8000360c:	85a6                	mv	a1,s1
    8000360e:	855e                	mv	a0,s7
    80003610:	00000097          	auipc	ra,0x0
    80003614:	c58080e7          	jalr	-936(ra) # 80003268 <bread>
    80003618:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000361a:	40000613          	li	a2,1024
    8000361e:	4581                	li	a1,0
    80003620:	05850513          	addi	a0,a0,88
    80003624:	ffffd097          	auipc	ra,0xffffd
    80003628:	6b4080e7          	jalr	1716(ra) # 80000cd8 <memset>
  log_write(bp);
    8000362c:	854a                	mv	a0,s2
    8000362e:	00001097          	auipc	ra,0x1
    80003632:	fec080e7          	jalr	-20(ra) # 8000461a <log_write>
  brelse(bp);
    80003636:	854a                	mv	a0,s2
    80003638:	00000097          	auipc	ra,0x0
    8000363c:	d60080e7          	jalr	-672(ra) # 80003398 <brelse>
}
    80003640:	8526                	mv	a0,s1
    80003642:	60e6                	ld	ra,88(sp)
    80003644:	6446                	ld	s0,80(sp)
    80003646:	64a6                	ld	s1,72(sp)
    80003648:	6906                	ld	s2,64(sp)
    8000364a:	79e2                	ld	s3,56(sp)
    8000364c:	7a42                	ld	s4,48(sp)
    8000364e:	7aa2                	ld	s5,40(sp)
    80003650:	7b02                	ld	s6,32(sp)
    80003652:	6be2                	ld	s7,24(sp)
    80003654:	6c42                	ld	s8,16(sp)
    80003656:	6ca2                	ld	s9,8(sp)
    80003658:	6125                	addi	sp,sp,96
    8000365a:	8082                	ret

000000008000365c <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    8000365c:	7179                	addi	sp,sp,-48
    8000365e:	f406                	sd	ra,40(sp)
    80003660:	f022                	sd	s0,32(sp)
    80003662:	ec26                	sd	s1,24(sp)
    80003664:	e84a                	sd	s2,16(sp)
    80003666:	e44e                	sd	s3,8(sp)
    80003668:	e052                	sd	s4,0(sp)
    8000366a:	1800                	addi	s0,sp,48
    8000366c:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000366e:	47ad                	li	a5,11
    80003670:	04b7fe63          	bgeu	a5,a1,800036cc <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    80003674:	ff45849b          	addiw	s1,a1,-12
    80003678:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000367c:	0ff00793          	li	a5,255
    80003680:	0ae7e463          	bltu	a5,a4,80003728 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003684:	08052583          	lw	a1,128(a0)
    80003688:	c5b5                	beqz	a1,800036f4 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000368a:	00092503          	lw	a0,0(s2)
    8000368e:	00000097          	auipc	ra,0x0
    80003692:	bda080e7          	jalr	-1062(ra) # 80003268 <bread>
    80003696:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003698:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000369c:	02049713          	slli	a4,s1,0x20
    800036a0:	01e75593          	srli	a1,a4,0x1e
    800036a4:	00b784b3          	add	s1,a5,a1
    800036a8:	0004a983          	lw	s3,0(s1)
    800036ac:	04098e63          	beqz	s3,80003708 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800036b0:	8552                	mv	a0,s4
    800036b2:	00000097          	auipc	ra,0x0
    800036b6:	ce6080e7          	jalr	-794(ra) # 80003398 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800036ba:	854e                	mv	a0,s3
    800036bc:	70a2                	ld	ra,40(sp)
    800036be:	7402                	ld	s0,32(sp)
    800036c0:	64e2                	ld	s1,24(sp)
    800036c2:	6942                	ld	s2,16(sp)
    800036c4:	69a2                	ld	s3,8(sp)
    800036c6:	6a02                	ld	s4,0(sp)
    800036c8:	6145                	addi	sp,sp,48
    800036ca:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800036cc:	02059793          	slli	a5,a1,0x20
    800036d0:	01e7d593          	srli	a1,a5,0x1e
    800036d4:	00b504b3          	add	s1,a0,a1
    800036d8:	0504a983          	lw	s3,80(s1)
    800036dc:	fc099fe3          	bnez	s3,800036ba <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800036e0:	4108                	lw	a0,0(a0)
    800036e2:	00000097          	auipc	ra,0x0
    800036e6:	e48080e7          	jalr	-440(ra) # 8000352a <balloc>
    800036ea:	0005099b          	sext.w	s3,a0
    800036ee:	0534a823          	sw	s3,80(s1)
    800036f2:	b7e1                	j	800036ba <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800036f4:	4108                	lw	a0,0(a0)
    800036f6:	00000097          	auipc	ra,0x0
    800036fa:	e34080e7          	jalr	-460(ra) # 8000352a <balloc>
    800036fe:	0005059b          	sext.w	a1,a0
    80003702:	08b92023          	sw	a1,128(s2)
    80003706:	b751                	j	8000368a <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003708:	00092503          	lw	a0,0(s2)
    8000370c:	00000097          	auipc	ra,0x0
    80003710:	e1e080e7          	jalr	-482(ra) # 8000352a <balloc>
    80003714:	0005099b          	sext.w	s3,a0
    80003718:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000371c:	8552                	mv	a0,s4
    8000371e:	00001097          	auipc	ra,0x1
    80003722:	efc080e7          	jalr	-260(ra) # 8000461a <log_write>
    80003726:	b769                	j	800036b0 <bmap+0x54>
  panic("bmap: out of range");
    80003728:	00005517          	auipc	a0,0x5
    8000372c:	e8050513          	addi	a0,a0,-384 # 800085a8 <syscalls+0x130>
    80003730:	ffffd097          	auipc	ra,0xffffd
    80003734:	dfe080e7          	jalr	-514(ra) # 8000052e <panic>

0000000080003738 <iget>:
{
    80003738:	7179                	addi	sp,sp,-48
    8000373a:	f406                	sd	ra,40(sp)
    8000373c:	f022                	sd	s0,32(sp)
    8000373e:	ec26                	sd	s1,24(sp)
    80003740:	e84a                	sd	s2,16(sp)
    80003742:	e44e                	sd	s3,8(sp)
    80003744:	e052                	sd	s4,0(sp)
    80003746:	1800                	addi	s0,sp,48
    80003748:	89aa                	mv	s3,a0
    8000374a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000374c:	00024517          	auipc	a0,0x24
    80003750:	67c50513          	addi	a0,a0,1660 # 80027dc8 <itable>
    80003754:	ffffd097          	auipc	ra,0xffffd
    80003758:	472080e7          	jalr	1138(ra) # 80000bc6 <acquire>
  empty = 0;
    8000375c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000375e:	00024497          	auipc	s1,0x24
    80003762:	68248493          	addi	s1,s1,1666 # 80027de0 <itable+0x18>
    80003766:	00026697          	auipc	a3,0x26
    8000376a:	10a68693          	addi	a3,a3,266 # 80029870 <log>
    8000376e:	a039                	j	8000377c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003770:	02090b63          	beqz	s2,800037a6 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003774:	08848493          	addi	s1,s1,136
    80003778:	02d48a63          	beq	s1,a3,800037ac <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000377c:	449c                	lw	a5,8(s1)
    8000377e:	fef059e3          	blez	a5,80003770 <iget+0x38>
    80003782:	4098                	lw	a4,0(s1)
    80003784:	ff3716e3          	bne	a4,s3,80003770 <iget+0x38>
    80003788:	40d8                	lw	a4,4(s1)
    8000378a:	ff4713e3          	bne	a4,s4,80003770 <iget+0x38>
      ip->ref++;
    8000378e:	2785                	addiw	a5,a5,1
    80003790:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003792:	00024517          	auipc	a0,0x24
    80003796:	63650513          	addi	a0,a0,1590 # 80027dc8 <itable>
    8000379a:	ffffd097          	auipc	ra,0xffffd
    8000379e:	4f6080e7          	jalr	1270(ra) # 80000c90 <release>
      return ip;
    800037a2:	8926                	mv	s2,s1
    800037a4:	a03d                	j	800037d2 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037a6:	f7f9                	bnez	a5,80003774 <iget+0x3c>
    800037a8:	8926                	mv	s2,s1
    800037aa:	b7e9                	j	80003774 <iget+0x3c>
  if(empty == 0)
    800037ac:	02090c63          	beqz	s2,800037e4 <iget+0xac>
  ip->dev = dev;
    800037b0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800037b4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800037b8:	4785                	li	a5,1
    800037ba:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800037be:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800037c2:	00024517          	auipc	a0,0x24
    800037c6:	60650513          	addi	a0,a0,1542 # 80027dc8 <itable>
    800037ca:	ffffd097          	auipc	ra,0xffffd
    800037ce:	4c6080e7          	jalr	1222(ra) # 80000c90 <release>
}
    800037d2:	854a                	mv	a0,s2
    800037d4:	70a2                	ld	ra,40(sp)
    800037d6:	7402                	ld	s0,32(sp)
    800037d8:	64e2                	ld	s1,24(sp)
    800037da:	6942                	ld	s2,16(sp)
    800037dc:	69a2                	ld	s3,8(sp)
    800037de:	6a02                	ld	s4,0(sp)
    800037e0:	6145                	addi	sp,sp,48
    800037e2:	8082                	ret
    panic("iget: no inodes");
    800037e4:	00005517          	auipc	a0,0x5
    800037e8:	ddc50513          	addi	a0,a0,-548 # 800085c0 <syscalls+0x148>
    800037ec:	ffffd097          	auipc	ra,0xffffd
    800037f0:	d42080e7          	jalr	-702(ra) # 8000052e <panic>

00000000800037f4 <fsinit>:
fsinit(int dev) {
    800037f4:	7179                	addi	sp,sp,-48
    800037f6:	f406                	sd	ra,40(sp)
    800037f8:	f022                	sd	s0,32(sp)
    800037fa:	ec26                	sd	s1,24(sp)
    800037fc:	e84a                	sd	s2,16(sp)
    800037fe:	e44e                	sd	s3,8(sp)
    80003800:	1800                	addi	s0,sp,48
    80003802:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003804:	4585                	li	a1,1
    80003806:	00000097          	auipc	ra,0x0
    8000380a:	a62080e7          	jalr	-1438(ra) # 80003268 <bread>
    8000380e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003810:	00024997          	auipc	s3,0x24
    80003814:	59898993          	addi	s3,s3,1432 # 80027da8 <sb>
    80003818:	02000613          	li	a2,32
    8000381c:	05850593          	addi	a1,a0,88
    80003820:	854e                	mv	a0,s3
    80003822:	ffffd097          	auipc	ra,0xffffd
    80003826:	512080e7          	jalr	1298(ra) # 80000d34 <memmove>
  brelse(bp);
    8000382a:	8526                	mv	a0,s1
    8000382c:	00000097          	auipc	ra,0x0
    80003830:	b6c080e7          	jalr	-1172(ra) # 80003398 <brelse>
  if(sb.magic != FSMAGIC)
    80003834:	0009a703          	lw	a4,0(s3)
    80003838:	102037b7          	lui	a5,0x10203
    8000383c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003840:	02f71263          	bne	a4,a5,80003864 <fsinit+0x70>
  initlog(dev, &sb);
    80003844:	00024597          	auipc	a1,0x24
    80003848:	56458593          	addi	a1,a1,1380 # 80027da8 <sb>
    8000384c:	854a                	mv	a0,s2
    8000384e:	00001097          	auipc	ra,0x1
    80003852:	b4e080e7          	jalr	-1202(ra) # 8000439c <initlog>
}
    80003856:	70a2                	ld	ra,40(sp)
    80003858:	7402                	ld	s0,32(sp)
    8000385a:	64e2                	ld	s1,24(sp)
    8000385c:	6942                	ld	s2,16(sp)
    8000385e:	69a2                	ld	s3,8(sp)
    80003860:	6145                	addi	sp,sp,48
    80003862:	8082                	ret
    panic("invalid file system");
    80003864:	00005517          	auipc	a0,0x5
    80003868:	d6c50513          	addi	a0,a0,-660 # 800085d0 <syscalls+0x158>
    8000386c:	ffffd097          	auipc	ra,0xffffd
    80003870:	cc2080e7          	jalr	-830(ra) # 8000052e <panic>

0000000080003874 <iinit>:
{
    80003874:	7179                	addi	sp,sp,-48
    80003876:	f406                	sd	ra,40(sp)
    80003878:	f022                	sd	s0,32(sp)
    8000387a:	ec26                	sd	s1,24(sp)
    8000387c:	e84a                	sd	s2,16(sp)
    8000387e:	e44e                	sd	s3,8(sp)
    80003880:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003882:	00005597          	auipc	a1,0x5
    80003886:	d6658593          	addi	a1,a1,-666 # 800085e8 <syscalls+0x170>
    8000388a:	00024517          	auipc	a0,0x24
    8000388e:	53e50513          	addi	a0,a0,1342 # 80027dc8 <itable>
    80003892:	ffffd097          	auipc	ra,0xffffd
    80003896:	2a4080e7          	jalr	676(ra) # 80000b36 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000389a:	00024497          	auipc	s1,0x24
    8000389e:	55648493          	addi	s1,s1,1366 # 80027df0 <itable+0x28>
    800038a2:	00026997          	auipc	s3,0x26
    800038a6:	fde98993          	addi	s3,s3,-34 # 80029880 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800038aa:	00005917          	auipc	s2,0x5
    800038ae:	d4690913          	addi	s2,s2,-698 # 800085f0 <syscalls+0x178>
    800038b2:	85ca                	mv	a1,s2
    800038b4:	8526                	mv	a0,s1
    800038b6:	00001097          	auipc	ra,0x1
    800038ba:	e4a080e7          	jalr	-438(ra) # 80004700 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800038be:	08848493          	addi	s1,s1,136
    800038c2:	ff3498e3          	bne	s1,s3,800038b2 <iinit+0x3e>
}
    800038c6:	70a2                	ld	ra,40(sp)
    800038c8:	7402                	ld	s0,32(sp)
    800038ca:	64e2                	ld	s1,24(sp)
    800038cc:	6942                	ld	s2,16(sp)
    800038ce:	69a2                	ld	s3,8(sp)
    800038d0:	6145                	addi	sp,sp,48
    800038d2:	8082                	ret

00000000800038d4 <ialloc>:
{
    800038d4:	715d                	addi	sp,sp,-80
    800038d6:	e486                	sd	ra,72(sp)
    800038d8:	e0a2                	sd	s0,64(sp)
    800038da:	fc26                	sd	s1,56(sp)
    800038dc:	f84a                	sd	s2,48(sp)
    800038de:	f44e                	sd	s3,40(sp)
    800038e0:	f052                	sd	s4,32(sp)
    800038e2:	ec56                	sd	s5,24(sp)
    800038e4:	e85a                	sd	s6,16(sp)
    800038e6:	e45e                	sd	s7,8(sp)
    800038e8:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800038ea:	00024717          	auipc	a4,0x24
    800038ee:	4ca72703          	lw	a4,1226(a4) # 80027db4 <sb+0xc>
    800038f2:	4785                	li	a5,1
    800038f4:	04e7fa63          	bgeu	a5,a4,80003948 <ialloc+0x74>
    800038f8:	8aaa                	mv	s5,a0
    800038fa:	8bae                	mv	s7,a1
    800038fc:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800038fe:	00024a17          	auipc	s4,0x24
    80003902:	4aaa0a13          	addi	s4,s4,1194 # 80027da8 <sb>
    80003906:	00048b1b          	sext.w	s6,s1
    8000390a:	0044d793          	srli	a5,s1,0x4
    8000390e:	018a2583          	lw	a1,24(s4)
    80003912:	9dbd                	addw	a1,a1,a5
    80003914:	8556                	mv	a0,s5
    80003916:	00000097          	auipc	ra,0x0
    8000391a:	952080e7          	jalr	-1710(ra) # 80003268 <bread>
    8000391e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003920:	05850993          	addi	s3,a0,88
    80003924:	00f4f793          	andi	a5,s1,15
    80003928:	079a                	slli	a5,a5,0x6
    8000392a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000392c:	00099783          	lh	a5,0(s3)
    80003930:	c785                	beqz	a5,80003958 <ialloc+0x84>
    brelse(bp);
    80003932:	00000097          	auipc	ra,0x0
    80003936:	a66080e7          	jalr	-1434(ra) # 80003398 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000393a:	0485                	addi	s1,s1,1
    8000393c:	00ca2703          	lw	a4,12(s4)
    80003940:	0004879b          	sext.w	a5,s1
    80003944:	fce7e1e3          	bltu	a5,a4,80003906 <ialloc+0x32>
  panic("ialloc: no inodes");
    80003948:	00005517          	auipc	a0,0x5
    8000394c:	cb050513          	addi	a0,a0,-848 # 800085f8 <syscalls+0x180>
    80003950:	ffffd097          	auipc	ra,0xffffd
    80003954:	bde080e7          	jalr	-1058(ra) # 8000052e <panic>
      memset(dip, 0, sizeof(*dip));
    80003958:	04000613          	li	a2,64
    8000395c:	4581                	li	a1,0
    8000395e:	854e                	mv	a0,s3
    80003960:	ffffd097          	auipc	ra,0xffffd
    80003964:	378080e7          	jalr	888(ra) # 80000cd8 <memset>
      dip->type = type;
    80003968:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000396c:	854a                	mv	a0,s2
    8000396e:	00001097          	auipc	ra,0x1
    80003972:	cac080e7          	jalr	-852(ra) # 8000461a <log_write>
      brelse(bp);
    80003976:	854a                	mv	a0,s2
    80003978:	00000097          	auipc	ra,0x0
    8000397c:	a20080e7          	jalr	-1504(ra) # 80003398 <brelse>
      return iget(dev, inum);
    80003980:	85da                	mv	a1,s6
    80003982:	8556                	mv	a0,s5
    80003984:	00000097          	auipc	ra,0x0
    80003988:	db4080e7          	jalr	-588(ra) # 80003738 <iget>
}
    8000398c:	60a6                	ld	ra,72(sp)
    8000398e:	6406                	ld	s0,64(sp)
    80003990:	74e2                	ld	s1,56(sp)
    80003992:	7942                	ld	s2,48(sp)
    80003994:	79a2                	ld	s3,40(sp)
    80003996:	7a02                	ld	s4,32(sp)
    80003998:	6ae2                	ld	s5,24(sp)
    8000399a:	6b42                	ld	s6,16(sp)
    8000399c:	6ba2                	ld	s7,8(sp)
    8000399e:	6161                	addi	sp,sp,80
    800039a0:	8082                	ret

00000000800039a2 <iupdate>:
{
    800039a2:	1101                	addi	sp,sp,-32
    800039a4:	ec06                	sd	ra,24(sp)
    800039a6:	e822                	sd	s0,16(sp)
    800039a8:	e426                	sd	s1,8(sp)
    800039aa:	e04a                	sd	s2,0(sp)
    800039ac:	1000                	addi	s0,sp,32
    800039ae:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039b0:	415c                	lw	a5,4(a0)
    800039b2:	0047d79b          	srliw	a5,a5,0x4
    800039b6:	00024597          	auipc	a1,0x24
    800039ba:	40a5a583          	lw	a1,1034(a1) # 80027dc0 <sb+0x18>
    800039be:	9dbd                	addw	a1,a1,a5
    800039c0:	4108                	lw	a0,0(a0)
    800039c2:	00000097          	auipc	ra,0x0
    800039c6:	8a6080e7          	jalr	-1882(ra) # 80003268 <bread>
    800039ca:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039cc:	05850793          	addi	a5,a0,88
    800039d0:	40c8                	lw	a0,4(s1)
    800039d2:	893d                	andi	a0,a0,15
    800039d4:	051a                	slli	a0,a0,0x6
    800039d6:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    800039d8:	04449703          	lh	a4,68(s1)
    800039dc:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    800039e0:	04649703          	lh	a4,70(s1)
    800039e4:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    800039e8:	04849703          	lh	a4,72(s1)
    800039ec:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    800039f0:	04a49703          	lh	a4,74(s1)
    800039f4:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    800039f8:	44f8                	lw	a4,76(s1)
    800039fa:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800039fc:	03400613          	li	a2,52
    80003a00:	05048593          	addi	a1,s1,80
    80003a04:	0531                	addi	a0,a0,12
    80003a06:	ffffd097          	auipc	ra,0xffffd
    80003a0a:	32e080e7          	jalr	814(ra) # 80000d34 <memmove>
  log_write(bp);
    80003a0e:	854a                	mv	a0,s2
    80003a10:	00001097          	auipc	ra,0x1
    80003a14:	c0a080e7          	jalr	-1014(ra) # 8000461a <log_write>
  brelse(bp);
    80003a18:	854a                	mv	a0,s2
    80003a1a:	00000097          	auipc	ra,0x0
    80003a1e:	97e080e7          	jalr	-1666(ra) # 80003398 <brelse>
}
    80003a22:	60e2                	ld	ra,24(sp)
    80003a24:	6442                	ld	s0,16(sp)
    80003a26:	64a2                	ld	s1,8(sp)
    80003a28:	6902                	ld	s2,0(sp)
    80003a2a:	6105                	addi	sp,sp,32
    80003a2c:	8082                	ret

0000000080003a2e <idup>:
{
    80003a2e:	1101                	addi	sp,sp,-32
    80003a30:	ec06                	sd	ra,24(sp)
    80003a32:	e822                	sd	s0,16(sp)
    80003a34:	e426                	sd	s1,8(sp)
    80003a36:	1000                	addi	s0,sp,32
    80003a38:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a3a:	00024517          	auipc	a0,0x24
    80003a3e:	38e50513          	addi	a0,a0,910 # 80027dc8 <itable>
    80003a42:	ffffd097          	auipc	ra,0xffffd
    80003a46:	184080e7          	jalr	388(ra) # 80000bc6 <acquire>
  ip->ref++;
    80003a4a:	449c                	lw	a5,8(s1)
    80003a4c:	2785                	addiw	a5,a5,1
    80003a4e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a50:	00024517          	auipc	a0,0x24
    80003a54:	37850513          	addi	a0,a0,888 # 80027dc8 <itable>
    80003a58:	ffffd097          	auipc	ra,0xffffd
    80003a5c:	238080e7          	jalr	568(ra) # 80000c90 <release>
}
    80003a60:	8526                	mv	a0,s1
    80003a62:	60e2                	ld	ra,24(sp)
    80003a64:	6442                	ld	s0,16(sp)
    80003a66:	64a2                	ld	s1,8(sp)
    80003a68:	6105                	addi	sp,sp,32
    80003a6a:	8082                	ret

0000000080003a6c <ilock>:
{
    80003a6c:	1101                	addi	sp,sp,-32
    80003a6e:	ec06                	sd	ra,24(sp)
    80003a70:	e822                	sd	s0,16(sp)
    80003a72:	e426                	sd	s1,8(sp)
    80003a74:	e04a                	sd	s2,0(sp)
    80003a76:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003a78:	c115                	beqz	a0,80003a9c <ilock+0x30>
    80003a7a:	84aa                	mv	s1,a0
    80003a7c:	451c                	lw	a5,8(a0)
    80003a7e:	00f05f63          	blez	a5,80003a9c <ilock+0x30>
  acquiresleep(&ip->lock);
    80003a82:	0541                	addi	a0,a0,16
    80003a84:	00001097          	auipc	ra,0x1
    80003a88:	cb6080e7          	jalr	-842(ra) # 8000473a <acquiresleep>
  if(ip->valid == 0){
    80003a8c:	40bc                	lw	a5,64(s1)
    80003a8e:	cf99                	beqz	a5,80003aac <ilock+0x40>
}
    80003a90:	60e2                	ld	ra,24(sp)
    80003a92:	6442                	ld	s0,16(sp)
    80003a94:	64a2                	ld	s1,8(sp)
    80003a96:	6902                	ld	s2,0(sp)
    80003a98:	6105                	addi	sp,sp,32
    80003a9a:	8082                	ret
    panic("ilock");
    80003a9c:	00005517          	auipc	a0,0x5
    80003aa0:	b7450513          	addi	a0,a0,-1164 # 80008610 <syscalls+0x198>
    80003aa4:	ffffd097          	auipc	ra,0xffffd
    80003aa8:	a8a080e7          	jalr	-1398(ra) # 8000052e <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003aac:	40dc                	lw	a5,4(s1)
    80003aae:	0047d79b          	srliw	a5,a5,0x4
    80003ab2:	00024597          	auipc	a1,0x24
    80003ab6:	30e5a583          	lw	a1,782(a1) # 80027dc0 <sb+0x18>
    80003aba:	9dbd                	addw	a1,a1,a5
    80003abc:	4088                	lw	a0,0(s1)
    80003abe:	fffff097          	auipc	ra,0xfffff
    80003ac2:	7aa080e7          	jalr	1962(ra) # 80003268 <bread>
    80003ac6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ac8:	05850593          	addi	a1,a0,88
    80003acc:	40dc                	lw	a5,4(s1)
    80003ace:	8bbd                	andi	a5,a5,15
    80003ad0:	079a                	slli	a5,a5,0x6
    80003ad2:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003ad4:	00059783          	lh	a5,0(a1)
    80003ad8:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003adc:	00259783          	lh	a5,2(a1)
    80003ae0:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003ae4:	00459783          	lh	a5,4(a1)
    80003ae8:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003aec:	00659783          	lh	a5,6(a1)
    80003af0:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003af4:	459c                	lw	a5,8(a1)
    80003af6:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003af8:	03400613          	li	a2,52
    80003afc:	05b1                	addi	a1,a1,12
    80003afe:	05048513          	addi	a0,s1,80
    80003b02:	ffffd097          	auipc	ra,0xffffd
    80003b06:	232080e7          	jalr	562(ra) # 80000d34 <memmove>
    brelse(bp);
    80003b0a:	854a                	mv	a0,s2
    80003b0c:	00000097          	auipc	ra,0x0
    80003b10:	88c080e7          	jalr	-1908(ra) # 80003398 <brelse>
    ip->valid = 1;
    80003b14:	4785                	li	a5,1
    80003b16:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003b18:	04449783          	lh	a5,68(s1)
    80003b1c:	fbb5                	bnez	a5,80003a90 <ilock+0x24>
      panic("ilock: no type");
    80003b1e:	00005517          	auipc	a0,0x5
    80003b22:	afa50513          	addi	a0,a0,-1286 # 80008618 <syscalls+0x1a0>
    80003b26:	ffffd097          	auipc	ra,0xffffd
    80003b2a:	a08080e7          	jalr	-1528(ra) # 8000052e <panic>

0000000080003b2e <iunlock>:
{
    80003b2e:	1101                	addi	sp,sp,-32
    80003b30:	ec06                	sd	ra,24(sp)
    80003b32:	e822                	sd	s0,16(sp)
    80003b34:	e426                	sd	s1,8(sp)
    80003b36:	e04a                	sd	s2,0(sp)
    80003b38:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003b3a:	c905                	beqz	a0,80003b6a <iunlock+0x3c>
    80003b3c:	84aa                	mv	s1,a0
    80003b3e:	01050913          	addi	s2,a0,16
    80003b42:	854a                	mv	a0,s2
    80003b44:	00001097          	auipc	ra,0x1
    80003b48:	c90080e7          	jalr	-880(ra) # 800047d4 <holdingsleep>
    80003b4c:	cd19                	beqz	a0,80003b6a <iunlock+0x3c>
    80003b4e:	449c                	lw	a5,8(s1)
    80003b50:	00f05d63          	blez	a5,80003b6a <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003b54:	854a                	mv	a0,s2
    80003b56:	00001097          	auipc	ra,0x1
    80003b5a:	c3a080e7          	jalr	-966(ra) # 80004790 <releasesleep>
}
    80003b5e:	60e2                	ld	ra,24(sp)
    80003b60:	6442                	ld	s0,16(sp)
    80003b62:	64a2                	ld	s1,8(sp)
    80003b64:	6902                	ld	s2,0(sp)
    80003b66:	6105                	addi	sp,sp,32
    80003b68:	8082                	ret
    panic("iunlock");
    80003b6a:	00005517          	auipc	a0,0x5
    80003b6e:	abe50513          	addi	a0,a0,-1346 # 80008628 <syscalls+0x1b0>
    80003b72:	ffffd097          	auipc	ra,0xffffd
    80003b76:	9bc080e7          	jalr	-1604(ra) # 8000052e <panic>

0000000080003b7a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003b7a:	7179                	addi	sp,sp,-48
    80003b7c:	f406                	sd	ra,40(sp)
    80003b7e:	f022                	sd	s0,32(sp)
    80003b80:	ec26                	sd	s1,24(sp)
    80003b82:	e84a                	sd	s2,16(sp)
    80003b84:	e44e                	sd	s3,8(sp)
    80003b86:	e052                	sd	s4,0(sp)
    80003b88:	1800                	addi	s0,sp,48
    80003b8a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003b8c:	05050493          	addi	s1,a0,80
    80003b90:	08050913          	addi	s2,a0,128
    80003b94:	a021                	j	80003b9c <itrunc+0x22>
    80003b96:	0491                	addi	s1,s1,4
    80003b98:	01248d63          	beq	s1,s2,80003bb2 <itrunc+0x38>
    if(ip->addrs[i]){
    80003b9c:	408c                	lw	a1,0(s1)
    80003b9e:	dde5                	beqz	a1,80003b96 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003ba0:	0009a503          	lw	a0,0(s3)
    80003ba4:	00000097          	auipc	ra,0x0
    80003ba8:	90a080e7          	jalr	-1782(ra) # 800034ae <bfree>
      ip->addrs[i] = 0;
    80003bac:	0004a023          	sw	zero,0(s1)
    80003bb0:	b7dd                	j	80003b96 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003bb2:	0809a583          	lw	a1,128(s3)
    80003bb6:	e185                	bnez	a1,80003bd6 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003bb8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003bbc:	854e                	mv	a0,s3
    80003bbe:	00000097          	auipc	ra,0x0
    80003bc2:	de4080e7          	jalr	-540(ra) # 800039a2 <iupdate>
}
    80003bc6:	70a2                	ld	ra,40(sp)
    80003bc8:	7402                	ld	s0,32(sp)
    80003bca:	64e2                	ld	s1,24(sp)
    80003bcc:	6942                	ld	s2,16(sp)
    80003bce:	69a2                	ld	s3,8(sp)
    80003bd0:	6a02                	ld	s4,0(sp)
    80003bd2:	6145                	addi	sp,sp,48
    80003bd4:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003bd6:	0009a503          	lw	a0,0(s3)
    80003bda:	fffff097          	auipc	ra,0xfffff
    80003bde:	68e080e7          	jalr	1678(ra) # 80003268 <bread>
    80003be2:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003be4:	05850493          	addi	s1,a0,88
    80003be8:	45850913          	addi	s2,a0,1112
    80003bec:	a021                	j	80003bf4 <itrunc+0x7a>
    80003bee:	0491                	addi	s1,s1,4
    80003bf0:	01248b63          	beq	s1,s2,80003c06 <itrunc+0x8c>
      if(a[j])
    80003bf4:	408c                	lw	a1,0(s1)
    80003bf6:	dde5                	beqz	a1,80003bee <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003bf8:	0009a503          	lw	a0,0(s3)
    80003bfc:	00000097          	auipc	ra,0x0
    80003c00:	8b2080e7          	jalr	-1870(ra) # 800034ae <bfree>
    80003c04:	b7ed                	j	80003bee <itrunc+0x74>
    brelse(bp);
    80003c06:	8552                	mv	a0,s4
    80003c08:	fffff097          	auipc	ra,0xfffff
    80003c0c:	790080e7          	jalr	1936(ra) # 80003398 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003c10:	0809a583          	lw	a1,128(s3)
    80003c14:	0009a503          	lw	a0,0(s3)
    80003c18:	00000097          	auipc	ra,0x0
    80003c1c:	896080e7          	jalr	-1898(ra) # 800034ae <bfree>
    ip->addrs[NDIRECT] = 0;
    80003c20:	0809a023          	sw	zero,128(s3)
    80003c24:	bf51                	j	80003bb8 <itrunc+0x3e>

0000000080003c26 <iput>:
{
    80003c26:	1101                	addi	sp,sp,-32
    80003c28:	ec06                	sd	ra,24(sp)
    80003c2a:	e822                	sd	s0,16(sp)
    80003c2c:	e426                	sd	s1,8(sp)
    80003c2e:	e04a                	sd	s2,0(sp)
    80003c30:	1000                	addi	s0,sp,32
    80003c32:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c34:	00024517          	auipc	a0,0x24
    80003c38:	19450513          	addi	a0,a0,404 # 80027dc8 <itable>
    80003c3c:	ffffd097          	auipc	ra,0xffffd
    80003c40:	f8a080e7          	jalr	-118(ra) # 80000bc6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c44:	4498                	lw	a4,8(s1)
    80003c46:	4785                	li	a5,1
    80003c48:	02f70363          	beq	a4,a5,80003c6e <iput+0x48>
  ip->ref--;
    80003c4c:	449c                	lw	a5,8(s1)
    80003c4e:	37fd                	addiw	a5,a5,-1
    80003c50:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003c52:	00024517          	auipc	a0,0x24
    80003c56:	17650513          	addi	a0,a0,374 # 80027dc8 <itable>
    80003c5a:	ffffd097          	auipc	ra,0xffffd
    80003c5e:	036080e7          	jalr	54(ra) # 80000c90 <release>
}
    80003c62:	60e2                	ld	ra,24(sp)
    80003c64:	6442                	ld	s0,16(sp)
    80003c66:	64a2                	ld	s1,8(sp)
    80003c68:	6902                	ld	s2,0(sp)
    80003c6a:	6105                	addi	sp,sp,32
    80003c6c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c6e:	40bc                	lw	a5,64(s1)
    80003c70:	dff1                	beqz	a5,80003c4c <iput+0x26>
    80003c72:	04a49783          	lh	a5,74(s1)
    80003c76:	fbf9                	bnez	a5,80003c4c <iput+0x26>
    acquiresleep(&ip->lock);
    80003c78:	01048913          	addi	s2,s1,16
    80003c7c:	854a                	mv	a0,s2
    80003c7e:	00001097          	auipc	ra,0x1
    80003c82:	abc080e7          	jalr	-1348(ra) # 8000473a <acquiresleep>
    release(&itable.lock);
    80003c86:	00024517          	auipc	a0,0x24
    80003c8a:	14250513          	addi	a0,a0,322 # 80027dc8 <itable>
    80003c8e:	ffffd097          	auipc	ra,0xffffd
    80003c92:	002080e7          	jalr	2(ra) # 80000c90 <release>
    itrunc(ip);
    80003c96:	8526                	mv	a0,s1
    80003c98:	00000097          	auipc	ra,0x0
    80003c9c:	ee2080e7          	jalr	-286(ra) # 80003b7a <itrunc>
    ip->type = 0;
    80003ca0:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003ca4:	8526                	mv	a0,s1
    80003ca6:	00000097          	auipc	ra,0x0
    80003caa:	cfc080e7          	jalr	-772(ra) # 800039a2 <iupdate>
    ip->valid = 0;
    80003cae:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003cb2:	854a                	mv	a0,s2
    80003cb4:	00001097          	auipc	ra,0x1
    80003cb8:	adc080e7          	jalr	-1316(ra) # 80004790 <releasesleep>
    acquire(&itable.lock);
    80003cbc:	00024517          	auipc	a0,0x24
    80003cc0:	10c50513          	addi	a0,a0,268 # 80027dc8 <itable>
    80003cc4:	ffffd097          	auipc	ra,0xffffd
    80003cc8:	f02080e7          	jalr	-254(ra) # 80000bc6 <acquire>
    80003ccc:	b741                	j	80003c4c <iput+0x26>

0000000080003cce <iunlockput>:
{
    80003cce:	1101                	addi	sp,sp,-32
    80003cd0:	ec06                	sd	ra,24(sp)
    80003cd2:	e822                	sd	s0,16(sp)
    80003cd4:	e426                	sd	s1,8(sp)
    80003cd6:	1000                	addi	s0,sp,32
    80003cd8:	84aa                	mv	s1,a0
  iunlock(ip);
    80003cda:	00000097          	auipc	ra,0x0
    80003cde:	e54080e7          	jalr	-428(ra) # 80003b2e <iunlock>
  iput(ip);
    80003ce2:	8526                	mv	a0,s1
    80003ce4:	00000097          	auipc	ra,0x0
    80003ce8:	f42080e7          	jalr	-190(ra) # 80003c26 <iput>
}
    80003cec:	60e2                	ld	ra,24(sp)
    80003cee:	6442                	ld	s0,16(sp)
    80003cf0:	64a2                	ld	s1,8(sp)
    80003cf2:	6105                	addi	sp,sp,32
    80003cf4:	8082                	ret

0000000080003cf6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003cf6:	1141                	addi	sp,sp,-16
    80003cf8:	e422                	sd	s0,8(sp)
    80003cfa:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003cfc:	411c                	lw	a5,0(a0)
    80003cfe:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d00:	415c                	lw	a5,4(a0)
    80003d02:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d04:	04451783          	lh	a5,68(a0)
    80003d08:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003d0c:	04a51783          	lh	a5,74(a0)
    80003d10:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003d14:	04c56783          	lwu	a5,76(a0)
    80003d18:	e99c                	sd	a5,16(a1)
}
    80003d1a:	6422                	ld	s0,8(sp)
    80003d1c:	0141                	addi	sp,sp,16
    80003d1e:	8082                	ret

0000000080003d20 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d20:	457c                	lw	a5,76(a0)
    80003d22:	0ed7e963          	bltu	a5,a3,80003e14 <readi+0xf4>
{
    80003d26:	7159                	addi	sp,sp,-112
    80003d28:	f486                	sd	ra,104(sp)
    80003d2a:	f0a2                	sd	s0,96(sp)
    80003d2c:	eca6                	sd	s1,88(sp)
    80003d2e:	e8ca                	sd	s2,80(sp)
    80003d30:	e4ce                	sd	s3,72(sp)
    80003d32:	e0d2                	sd	s4,64(sp)
    80003d34:	fc56                	sd	s5,56(sp)
    80003d36:	f85a                	sd	s6,48(sp)
    80003d38:	f45e                	sd	s7,40(sp)
    80003d3a:	f062                	sd	s8,32(sp)
    80003d3c:	ec66                	sd	s9,24(sp)
    80003d3e:	e86a                	sd	s10,16(sp)
    80003d40:	e46e                	sd	s11,8(sp)
    80003d42:	1880                	addi	s0,sp,112
    80003d44:	8baa                	mv	s7,a0
    80003d46:	8c2e                	mv	s8,a1
    80003d48:	8ab2                	mv	s5,a2
    80003d4a:	84b6                	mv	s1,a3
    80003d4c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d4e:	9f35                	addw	a4,a4,a3
    return 0;
    80003d50:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003d52:	0ad76063          	bltu	a4,a3,80003df2 <readi+0xd2>
  if(off + n > ip->size)
    80003d56:	00e7f463          	bgeu	a5,a4,80003d5e <readi+0x3e>
    n = ip->size - off;
    80003d5a:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d5e:	0a0b0963          	beqz	s6,80003e10 <readi+0xf0>
    80003d62:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d64:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003d68:	5cfd                	li	s9,-1
    80003d6a:	a82d                	j	80003da4 <readi+0x84>
    80003d6c:	020a1d93          	slli	s11,s4,0x20
    80003d70:	020ddd93          	srli	s11,s11,0x20
    80003d74:	05890793          	addi	a5,s2,88
    80003d78:	86ee                	mv	a3,s11
    80003d7a:	963e                	add	a2,a2,a5
    80003d7c:	85d6                	mv	a1,s5
    80003d7e:	8562                	mv	a0,s8
    80003d80:	ffffe097          	auipc	ra,0xffffe
    80003d84:	79e080e7          	jalr	1950(ra) # 8000251e <either_copyout>
    80003d88:	05950d63          	beq	a0,s9,80003de2 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003d8c:	854a                	mv	a0,s2
    80003d8e:	fffff097          	auipc	ra,0xfffff
    80003d92:	60a080e7          	jalr	1546(ra) # 80003398 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003d96:	013a09bb          	addw	s3,s4,s3
    80003d9a:	009a04bb          	addw	s1,s4,s1
    80003d9e:	9aee                	add	s5,s5,s11
    80003da0:	0569f763          	bgeu	s3,s6,80003dee <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003da4:	000ba903          	lw	s2,0(s7)
    80003da8:	00a4d59b          	srliw	a1,s1,0xa
    80003dac:	855e                	mv	a0,s7
    80003dae:	00000097          	auipc	ra,0x0
    80003db2:	8ae080e7          	jalr	-1874(ra) # 8000365c <bmap>
    80003db6:	0005059b          	sext.w	a1,a0
    80003dba:	854a                	mv	a0,s2
    80003dbc:	fffff097          	auipc	ra,0xfffff
    80003dc0:	4ac080e7          	jalr	1196(ra) # 80003268 <bread>
    80003dc4:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dc6:	3ff4f613          	andi	a2,s1,1023
    80003dca:	40cd07bb          	subw	a5,s10,a2
    80003dce:	413b073b          	subw	a4,s6,s3
    80003dd2:	8a3e                	mv	s4,a5
    80003dd4:	2781                	sext.w	a5,a5
    80003dd6:	0007069b          	sext.w	a3,a4
    80003dda:	f8f6f9e3          	bgeu	a3,a5,80003d6c <readi+0x4c>
    80003dde:	8a3a                	mv	s4,a4
    80003de0:	b771                	j	80003d6c <readi+0x4c>
      brelse(bp);
    80003de2:	854a                	mv	a0,s2
    80003de4:	fffff097          	auipc	ra,0xfffff
    80003de8:	5b4080e7          	jalr	1460(ra) # 80003398 <brelse>
      tot = -1;
    80003dec:	59fd                	li	s3,-1
  }
  return tot;
    80003dee:	0009851b          	sext.w	a0,s3
}
    80003df2:	70a6                	ld	ra,104(sp)
    80003df4:	7406                	ld	s0,96(sp)
    80003df6:	64e6                	ld	s1,88(sp)
    80003df8:	6946                	ld	s2,80(sp)
    80003dfa:	69a6                	ld	s3,72(sp)
    80003dfc:	6a06                	ld	s4,64(sp)
    80003dfe:	7ae2                	ld	s5,56(sp)
    80003e00:	7b42                	ld	s6,48(sp)
    80003e02:	7ba2                	ld	s7,40(sp)
    80003e04:	7c02                	ld	s8,32(sp)
    80003e06:	6ce2                	ld	s9,24(sp)
    80003e08:	6d42                	ld	s10,16(sp)
    80003e0a:	6da2                	ld	s11,8(sp)
    80003e0c:	6165                	addi	sp,sp,112
    80003e0e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e10:	89da                	mv	s3,s6
    80003e12:	bff1                	j	80003dee <readi+0xce>
    return 0;
    80003e14:	4501                	li	a0,0
}
    80003e16:	8082                	ret

0000000080003e18 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e18:	457c                	lw	a5,76(a0)
    80003e1a:	10d7e863          	bltu	a5,a3,80003f2a <writei+0x112>
{
    80003e1e:	7159                	addi	sp,sp,-112
    80003e20:	f486                	sd	ra,104(sp)
    80003e22:	f0a2                	sd	s0,96(sp)
    80003e24:	eca6                	sd	s1,88(sp)
    80003e26:	e8ca                	sd	s2,80(sp)
    80003e28:	e4ce                	sd	s3,72(sp)
    80003e2a:	e0d2                	sd	s4,64(sp)
    80003e2c:	fc56                	sd	s5,56(sp)
    80003e2e:	f85a                	sd	s6,48(sp)
    80003e30:	f45e                	sd	s7,40(sp)
    80003e32:	f062                	sd	s8,32(sp)
    80003e34:	ec66                	sd	s9,24(sp)
    80003e36:	e86a                	sd	s10,16(sp)
    80003e38:	e46e                	sd	s11,8(sp)
    80003e3a:	1880                	addi	s0,sp,112
    80003e3c:	8b2a                	mv	s6,a0
    80003e3e:	8c2e                	mv	s8,a1
    80003e40:	8ab2                	mv	s5,a2
    80003e42:	8936                	mv	s2,a3
    80003e44:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003e46:	00e687bb          	addw	a5,a3,a4
    80003e4a:	0ed7e263          	bltu	a5,a3,80003f2e <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003e4e:	00043737          	lui	a4,0x43
    80003e52:	0ef76063          	bltu	a4,a5,80003f32 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e56:	0c0b8863          	beqz	s7,80003f26 <writei+0x10e>
    80003e5a:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e5c:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003e60:	5cfd                	li	s9,-1
    80003e62:	a091                	j	80003ea6 <writei+0x8e>
    80003e64:	02099d93          	slli	s11,s3,0x20
    80003e68:	020ddd93          	srli	s11,s11,0x20
    80003e6c:	05848793          	addi	a5,s1,88
    80003e70:	86ee                	mv	a3,s11
    80003e72:	8656                	mv	a2,s5
    80003e74:	85e2                	mv	a1,s8
    80003e76:	953e                	add	a0,a0,a5
    80003e78:	ffffe097          	auipc	ra,0xffffe
    80003e7c:	6fc080e7          	jalr	1788(ra) # 80002574 <either_copyin>
    80003e80:	07950263          	beq	a0,s9,80003ee4 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003e84:	8526                	mv	a0,s1
    80003e86:	00000097          	auipc	ra,0x0
    80003e8a:	794080e7          	jalr	1940(ra) # 8000461a <log_write>
    brelse(bp);
    80003e8e:	8526                	mv	a0,s1
    80003e90:	fffff097          	auipc	ra,0xfffff
    80003e94:	508080e7          	jalr	1288(ra) # 80003398 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003e98:	01498a3b          	addw	s4,s3,s4
    80003e9c:	0129893b          	addw	s2,s3,s2
    80003ea0:	9aee                	add	s5,s5,s11
    80003ea2:	057a7663          	bgeu	s4,s7,80003eee <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003ea6:	000b2483          	lw	s1,0(s6)
    80003eaa:	00a9559b          	srliw	a1,s2,0xa
    80003eae:	855a                	mv	a0,s6
    80003eb0:	fffff097          	auipc	ra,0xfffff
    80003eb4:	7ac080e7          	jalr	1964(ra) # 8000365c <bmap>
    80003eb8:	0005059b          	sext.w	a1,a0
    80003ebc:	8526                	mv	a0,s1
    80003ebe:	fffff097          	auipc	ra,0xfffff
    80003ec2:	3aa080e7          	jalr	938(ra) # 80003268 <bread>
    80003ec6:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ec8:	3ff97513          	andi	a0,s2,1023
    80003ecc:	40ad07bb          	subw	a5,s10,a0
    80003ed0:	414b873b          	subw	a4,s7,s4
    80003ed4:	89be                	mv	s3,a5
    80003ed6:	2781                	sext.w	a5,a5
    80003ed8:	0007069b          	sext.w	a3,a4
    80003edc:	f8f6f4e3          	bgeu	a3,a5,80003e64 <writei+0x4c>
    80003ee0:	89ba                	mv	s3,a4
    80003ee2:	b749                	j	80003e64 <writei+0x4c>
      brelse(bp);
    80003ee4:	8526                	mv	a0,s1
    80003ee6:	fffff097          	auipc	ra,0xfffff
    80003eea:	4b2080e7          	jalr	1202(ra) # 80003398 <brelse>
  }

  if(off > ip->size)
    80003eee:	04cb2783          	lw	a5,76(s6)
    80003ef2:	0127f463          	bgeu	a5,s2,80003efa <writei+0xe2>
    ip->size = off;
    80003ef6:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003efa:	855a                	mv	a0,s6
    80003efc:	00000097          	auipc	ra,0x0
    80003f00:	aa6080e7          	jalr	-1370(ra) # 800039a2 <iupdate>

  return tot;
    80003f04:	000a051b          	sext.w	a0,s4
}
    80003f08:	70a6                	ld	ra,104(sp)
    80003f0a:	7406                	ld	s0,96(sp)
    80003f0c:	64e6                	ld	s1,88(sp)
    80003f0e:	6946                	ld	s2,80(sp)
    80003f10:	69a6                	ld	s3,72(sp)
    80003f12:	6a06                	ld	s4,64(sp)
    80003f14:	7ae2                	ld	s5,56(sp)
    80003f16:	7b42                	ld	s6,48(sp)
    80003f18:	7ba2                	ld	s7,40(sp)
    80003f1a:	7c02                	ld	s8,32(sp)
    80003f1c:	6ce2                	ld	s9,24(sp)
    80003f1e:	6d42                	ld	s10,16(sp)
    80003f20:	6da2                	ld	s11,8(sp)
    80003f22:	6165                	addi	sp,sp,112
    80003f24:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f26:	8a5e                	mv	s4,s7
    80003f28:	bfc9                	j	80003efa <writei+0xe2>
    return -1;
    80003f2a:	557d                	li	a0,-1
}
    80003f2c:	8082                	ret
    return -1;
    80003f2e:	557d                	li	a0,-1
    80003f30:	bfe1                	j	80003f08 <writei+0xf0>
    return -1;
    80003f32:	557d                	li	a0,-1
    80003f34:	bfd1                	j	80003f08 <writei+0xf0>

0000000080003f36 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003f36:	1141                	addi	sp,sp,-16
    80003f38:	e406                	sd	ra,8(sp)
    80003f3a:	e022                	sd	s0,0(sp)
    80003f3c:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003f3e:	4639                	li	a2,14
    80003f40:	ffffd097          	auipc	ra,0xffffd
    80003f44:	e70080e7          	jalr	-400(ra) # 80000db0 <strncmp>
}
    80003f48:	60a2                	ld	ra,8(sp)
    80003f4a:	6402                	ld	s0,0(sp)
    80003f4c:	0141                	addi	sp,sp,16
    80003f4e:	8082                	ret

0000000080003f50 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003f50:	7139                	addi	sp,sp,-64
    80003f52:	fc06                	sd	ra,56(sp)
    80003f54:	f822                	sd	s0,48(sp)
    80003f56:	f426                	sd	s1,40(sp)
    80003f58:	f04a                	sd	s2,32(sp)
    80003f5a:	ec4e                	sd	s3,24(sp)
    80003f5c:	e852                	sd	s4,16(sp)
    80003f5e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003f60:	04451703          	lh	a4,68(a0)
    80003f64:	4785                	li	a5,1
    80003f66:	00f71a63          	bne	a4,a5,80003f7a <dirlookup+0x2a>
    80003f6a:	892a                	mv	s2,a0
    80003f6c:	89ae                	mv	s3,a1
    80003f6e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f70:	457c                	lw	a5,76(a0)
    80003f72:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003f74:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f76:	e79d                	bnez	a5,80003fa4 <dirlookup+0x54>
    80003f78:	a8a5                	j	80003ff0 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003f7a:	00004517          	auipc	a0,0x4
    80003f7e:	6b650513          	addi	a0,a0,1718 # 80008630 <syscalls+0x1b8>
    80003f82:	ffffc097          	auipc	ra,0xffffc
    80003f86:	5ac080e7          	jalr	1452(ra) # 8000052e <panic>
      panic("dirlookup read");
    80003f8a:	00004517          	auipc	a0,0x4
    80003f8e:	6be50513          	addi	a0,a0,1726 # 80008648 <syscalls+0x1d0>
    80003f92:	ffffc097          	auipc	ra,0xffffc
    80003f96:	59c080e7          	jalr	1436(ra) # 8000052e <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f9a:	24c1                	addiw	s1,s1,16
    80003f9c:	04c92783          	lw	a5,76(s2)
    80003fa0:	04f4f763          	bgeu	s1,a5,80003fee <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fa4:	4741                	li	a4,16
    80003fa6:	86a6                	mv	a3,s1
    80003fa8:	fc040613          	addi	a2,s0,-64
    80003fac:	4581                	li	a1,0
    80003fae:	854a                	mv	a0,s2
    80003fb0:	00000097          	auipc	ra,0x0
    80003fb4:	d70080e7          	jalr	-656(ra) # 80003d20 <readi>
    80003fb8:	47c1                	li	a5,16
    80003fba:	fcf518e3          	bne	a0,a5,80003f8a <dirlookup+0x3a>
    if(de.inum == 0)
    80003fbe:	fc045783          	lhu	a5,-64(s0)
    80003fc2:	dfe1                	beqz	a5,80003f9a <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003fc4:	fc240593          	addi	a1,s0,-62
    80003fc8:	854e                	mv	a0,s3
    80003fca:	00000097          	auipc	ra,0x0
    80003fce:	f6c080e7          	jalr	-148(ra) # 80003f36 <namecmp>
    80003fd2:	f561                	bnez	a0,80003f9a <dirlookup+0x4a>
      if(poff)
    80003fd4:	000a0463          	beqz	s4,80003fdc <dirlookup+0x8c>
        *poff = off;
    80003fd8:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003fdc:	fc045583          	lhu	a1,-64(s0)
    80003fe0:	00092503          	lw	a0,0(s2)
    80003fe4:	fffff097          	auipc	ra,0xfffff
    80003fe8:	754080e7          	jalr	1876(ra) # 80003738 <iget>
    80003fec:	a011                	j	80003ff0 <dirlookup+0xa0>
  return 0;
    80003fee:	4501                	li	a0,0
}
    80003ff0:	70e2                	ld	ra,56(sp)
    80003ff2:	7442                	ld	s0,48(sp)
    80003ff4:	74a2                	ld	s1,40(sp)
    80003ff6:	7902                	ld	s2,32(sp)
    80003ff8:	69e2                	ld	s3,24(sp)
    80003ffa:	6a42                	ld	s4,16(sp)
    80003ffc:	6121                	addi	sp,sp,64
    80003ffe:	8082                	ret

0000000080004000 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004000:	711d                	addi	sp,sp,-96
    80004002:	ec86                	sd	ra,88(sp)
    80004004:	e8a2                	sd	s0,80(sp)
    80004006:	e4a6                	sd	s1,72(sp)
    80004008:	e0ca                	sd	s2,64(sp)
    8000400a:	fc4e                	sd	s3,56(sp)
    8000400c:	f852                	sd	s4,48(sp)
    8000400e:	f456                	sd	s5,40(sp)
    80004010:	f05a                	sd	s6,32(sp)
    80004012:	ec5e                	sd	s7,24(sp)
    80004014:	e862                	sd	s8,16(sp)
    80004016:	e466                	sd	s9,8(sp)
    80004018:	1080                	addi	s0,sp,96
    8000401a:	84aa                	mv	s1,a0
    8000401c:	8aae                	mv	s5,a1
    8000401e:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004020:	00054703          	lbu	a4,0(a0)
    80004024:	02f00793          	li	a5,47
    80004028:	02f70363          	beq	a4,a5,8000404e <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000402c:	ffffe097          	auipc	ra,0xffffe
    80004030:	96c080e7          	jalr	-1684(ra) # 80001998 <myproc>
    80004034:	15053503          	ld	a0,336(a0)
    80004038:	00000097          	auipc	ra,0x0
    8000403c:	9f6080e7          	jalr	-1546(ra) # 80003a2e <idup>
    80004040:	89aa                	mv	s3,a0
  while(*path == '/')
    80004042:	02f00913          	li	s2,47
  len = path - s;
    80004046:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80004048:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000404a:	4b85                	li	s7,1
    8000404c:	a865                	j	80004104 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    8000404e:	4585                	li	a1,1
    80004050:	4505                	li	a0,1
    80004052:	fffff097          	auipc	ra,0xfffff
    80004056:	6e6080e7          	jalr	1766(ra) # 80003738 <iget>
    8000405a:	89aa                	mv	s3,a0
    8000405c:	b7dd                	j	80004042 <namex+0x42>
      iunlockput(ip);
    8000405e:	854e                	mv	a0,s3
    80004060:	00000097          	auipc	ra,0x0
    80004064:	c6e080e7          	jalr	-914(ra) # 80003cce <iunlockput>
      return 0;
    80004068:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000406a:	854e                	mv	a0,s3
    8000406c:	60e6                	ld	ra,88(sp)
    8000406e:	6446                	ld	s0,80(sp)
    80004070:	64a6                	ld	s1,72(sp)
    80004072:	6906                	ld	s2,64(sp)
    80004074:	79e2                	ld	s3,56(sp)
    80004076:	7a42                	ld	s4,48(sp)
    80004078:	7aa2                	ld	s5,40(sp)
    8000407a:	7b02                	ld	s6,32(sp)
    8000407c:	6be2                	ld	s7,24(sp)
    8000407e:	6c42                	ld	s8,16(sp)
    80004080:	6ca2                	ld	s9,8(sp)
    80004082:	6125                	addi	sp,sp,96
    80004084:	8082                	ret
      iunlock(ip);
    80004086:	854e                	mv	a0,s3
    80004088:	00000097          	auipc	ra,0x0
    8000408c:	aa6080e7          	jalr	-1370(ra) # 80003b2e <iunlock>
      return ip;
    80004090:	bfe9                	j	8000406a <namex+0x6a>
      iunlockput(ip);
    80004092:	854e                	mv	a0,s3
    80004094:	00000097          	auipc	ra,0x0
    80004098:	c3a080e7          	jalr	-966(ra) # 80003cce <iunlockput>
      return 0;
    8000409c:	89e6                	mv	s3,s9
    8000409e:	b7f1                	j	8000406a <namex+0x6a>
  len = path - s;
    800040a0:	40b48633          	sub	a2,s1,a1
    800040a4:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800040a8:	099c5463          	bge	s8,s9,80004130 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800040ac:	4639                	li	a2,14
    800040ae:	8552                	mv	a0,s4
    800040b0:	ffffd097          	auipc	ra,0xffffd
    800040b4:	c84080e7          	jalr	-892(ra) # 80000d34 <memmove>
  while(*path == '/')
    800040b8:	0004c783          	lbu	a5,0(s1)
    800040bc:	01279763          	bne	a5,s2,800040ca <namex+0xca>
    path++;
    800040c0:	0485                	addi	s1,s1,1
  while(*path == '/')
    800040c2:	0004c783          	lbu	a5,0(s1)
    800040c6:	ff278de3          	beq	a5,s2,800040c0 <namex+0xc0>
    ilock(ip);
    800040ca:	854e                	mv	a0,s3
    800040cc:	00000097          	auipc	ra,0x0
    800040d0:	9a0080e7          	jalr	-1632(ra) # 80003a6c <ilock>
    if(ip->type != T_DIR){
    800040d4:	04499783          	lh	a5,68(s3)
    800040d8:	f97793e3          	bne	a5,s7,8000405e <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800040dc:	000a8563          	beqz	s5,800040e6 <namex+0xe6>
    800040e0:	0004c783          	lbu	a5,0(s1)
    800040e4:	d3cd                	beqz	a5,80004086 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800040e6:	865a                	mv	a2,s6
    800040e8:	85d2                	mv	a1,s4
    800040ea:	854e                	mv	a0,s3
    800040ec:	00000097          	auipc	ra,0x0
    800040f0:	e64080e7          	jalr	-412(ra) # 80003f50 <dirlookup>
    800040f4:	8caa                	mv	s9,a0
    800040f6:	dd51                	beqz	a0,80004092 <namex+0x92>
    iunlockput(ip);
    800040f8:	854e                	mv	a0,s3
    800040fa:	00000097          	auipc	ra,0x0
    800040fe:	bd4080e7          	jalr	-1068(ra) # 80003cce <iunlockput>
    ip = next;
    80004102:	89e6                	mv	s3,s9
  while(*path == '/')
    80004104:	0004c783          	lbu	a5,0(s1)
    80004108:	05279763          	bne	a5,s2,80004156 <namex+0x156>
    path++;
    8000410c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000410e:	0004c783          	lbu	a5,0(s1)
    80004112:	ff278de3          	beq	a5,s2,8000410c <namex+0x10c>
  if(*path == 0)
    80004116:	c79d                	beqz	a5,80004144 <namex+0x144>
    path++;
    80004118:	85a6                	mv	a1,s1
  len = path - s;
    8000411a:	8cda                	mv	s9,s6
    8000411c:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    8000411e:	01278963          	beq	a5,s2,80004130 <namex+0x130>
    80004122:	dfbd                	beqz	a5,800040a0 <namex+0xa0>
    path++;
    80004124:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004126:	0004c783          	lbu	a5,0(s1)
    8000412a:	ff279ce3          	bne	a5,s2,80004122 <namex+0x122>
    8000412e:	bf8d                	j	800040a0 <namex+0xa0>
    memmove(name, s, len);
    80004130:	2601                	sext.w	a2,a2
    80004132:	8552                	mv	a0,s4
    80004134:	ffffd097          	auipc	ra,0xffffd
    80004138:	c00080e7          	jalr	-1024(ra) # 80000d34 <memmove>
    name[len] = 0;
    8000413c:	9cd2                	add	s9,s9,s4
    8000413e:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80004142:	bf9d                	j	800040b8 <namex+0xb8>
  if(nameiparent){
    80004144:	f20a83e3          	beqz	s5,8000406a <namex+0x6a>
    iput(ip);
    80004148:	854e                	mv	a0,s3
    8000414a:	00000097          	auipc	ra,0x0
    8000414e:	adc080e7          	jalr	-1316(ra) # 80003c26 <iput>
    return 0;
    80004152:	4981                	li	s3,0
    80004154:	bf19                	j	8000406a <namex+0x6a>
  if(*path == 0)
    80004156:	d7fd                	beqz	a5,80004144 <namex+0x144>
  while(*path != '/' && *path != 0)
    80004158:	0004c783          	lbu	a5,0(s1)
    8000415c:	85a6                	mv	a1,s1
    8000415e:	b7d1                	j	80004122 <namex+0x122>

0000000080004160 <dirlink>:
{
    80004160:	7139                	addi	sp,sp,-64
    80004162:	fc06                	sd	ra,56(sp)
    80004164:	f822                	sd	s0,48(sp)
    80004166:	f426                	sd	s1,40(sp)
    80004168:	f04a                	sd	s2,32(sp)
    8000416a:	ec4e                	sd	s3,24(sp)
    8000416c:	e852                	sd	s4,16(sp)
    8000416e:	0080                	addi	s0,sp,64
    80004170:	892a                	mv	s2,a0
    80004172:	8a2e                	mv	s4,a1
    80004174:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004176:	4601                	li	a2,0
    80004178:	00000097          	auipc	ra,0x0
    8000417c:	dd8080e7          	jalr	-552(ra) # 80003f50 <dirlookup>
    80004180:	e93d                	bnez	a0,800041f6 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004182:	04c92483          	lw	s1,76(s2)
    80004186:	c49d                	beqz	s1,800041b4 <dirlink+0x54>
    80004188:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000418a:	4741                	li	a4,16
    8000418c:	86a6                	mv	a3,s1
    8000418e:	fc040613          	addi	a2,s0,-64
    80004192:	4581                	li	a1,0
    80004194:	854a                	mv	a0,s2
    80004196:	00000097          	auipc	ra,0x0
    8000419a:	b8a080e7          	jalr	-1142(ra) # 80003d20 <readi>
    8000419e:	47c1                	li	a5,16
    800041a0:	06f51163          	bne	a0,a5,80004202 <dirlink+0xa2>
    if(de.inum == 0)
    800041a4:	fc045783          	lhu	a5,-64(s0)
    800041a8:	c791                	beqz	a5,800041b4 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041aa:	24c1                	addiw	s1,s1,16
    800041ac:	04c92783          	lw	a5,76(s2)
    800041b0:	fcf4ede3          	bltu	s1,a5,8000418a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800041b4:	4639                	li	a2,14
    800041b6:	85d2                	mv	a1,s4
    800041b8:	fc240513          	addi	a0,s0,-62
    800041bc:	ffffd097          	auipc	ra,0xffffd
    800041c0:	c30080e7          	jalr	-976(ra) # 80000dec <strncpy>
  de.inum = inum;
    800041c4:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041c8:	4741                	li	a4,16
    800041ca:	86a6                	mv	a3,s1
    800041cc:	fc040613          	addi	a2,s0,-64
    800041d0:	4581                	li	a1,0
    800041d2:	854a                	mv	a0,s2
    800041d4:	00000097          	auipc	ra,0x0
    800041d8:	c44080e7          	jalr	-956(ra) # 80003e18 <writei>
    800041dc:	872a                	mv	a4,a0
    800041de:	47c1                	li	a5,16
  return 0;
    800041e0:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041e2:	02f71863          	bne	a4,a5,80004212 <dirlink+0xb2>
}
    800041e6:	70e2                	ld	ra,56(sp)
    800041e8:	7442                	ld	s0,48(sp)
    800041ea:	74a2                	ld	s1,40(sp)
    800041ec:	7902                	ld	s2,32(sp)
    800041ee:	69e2                	ld	s3,24(sp)
    800041f0:	6a42                	ld	s4,16(sp)
    800041f2:	6121                	addi	sp,sp,64
    800041f4:	8082                	ret
    iput(ip);
    800041f6:	00000097          	auipc	ra,0x0
    800041fa:	a30080e7          	jalr	-1488(ra) # 80003c26 <iput>
    return -1;
    800041fe:	557d                	li	a0,-1
    80004200:	b7dd                	j	800041e6 <dirlink+0x86>
      panic("dirlink read");
    80004202:	00004517          	auipc	a0,0x4
    80004206:	45650513          	addi	a0,a0,1110 # 80008658 <syscalls+0x1e0>
    8000420a:	ffffc097          	auipc	ra,0xffffc
    8000420e:	324080e7          	jalr	804(ra) # 8000052e <panic>
    panic("dirlink");
    80004212:	00004517          	auipc	a0,0x4
    80004216:	55650513          	addi	a0,a0,1366 # 80008768 <syscalls+0x2f0>
    8000421a:	ffffc097          	auipc	ra,0xffffc
    8000421e:	314080e7          	jalr	788(ra) # 8000052e <panic>

0000000080004222 <namei>:

struct inode*
namei(char *path)
{
    80004222:	1101                	addi	sp,sp,-32
    80004224:	ec06                	sd	ra,24(sp)
    80004226:	e822                	sd	s0,16(sp)
    80004228:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000422a:	fe040613          	addi	a2,s0,-32
    8000422e:	4581                	li	a1,0
    80004230:	00000097          	auipc	ra,0x0
    80004234:	dd0080e7          	jalr	-560(ra) # 80004000 <namex>
}
    80004238:	60e2                	ld	ra,24(sp)
    8000423a:	6442                	ld	s0,16(sp)
    8000423c:	6105                	addi	sp,sp,32
    8000423e:	8082                	ret

0000000080004240 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004240:	1141                	addi	sp,sp,-16
    80004242:	e406                	sd	ra,8(sp)
    80004244:	e022                	sd	s0,0(sp)
    80004246:	0800                	addi	s0,sp,16
    80004248:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000424a:	4585                	li	a1,1
    8000424c:	00000097          	auipc	ra,0x0
    80004250:	db4080e7          	jalr	-588(ra) # 80004000 <namex>
}
    80004254:	60a2                	ld	ra,8(sp)
    80004256:	6402                	ld	s0,0(sp)
    80004258:	0141                	addi	sp,sp,16
    8000425a:	8082                	ret

000000008000425c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000425c:	1101                	addi	sp,sp,-32
    8000425e:	ec06                	sd	ra,24(sp)
    80004260:	e822                	sd	s0,16(sp)
    80004262:	e426                	sd	s1,8(sp)
    80004264:	e04a                	sd	s2,0(sp)
    80004266:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004268:	00025917          	auipc	s2,0x25
    8000426c:	60890913          	addi	s2,s2,1544 # 80029870 <log>
    80004270:	01892583          	lw	a1,24(s2)
    80004274:	02892503          	lw	a0,40(s2)
    80004278:	fffff097          	auipc	ra,0xfffff
    8000427c:	ff0080e7          	jalr	-16(ra) # 80003268 <bread>
    80004280:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004282:	02c92683          	lw	a3,44(s2)
    80004286:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004288:	02d05863          	blez	a3,800042b8 <write_head+0x5c>
    8000428c:	00025797          	auipc	a5,0x25
    80004290:	61478793          	addi	a5,a5,1556 # 800298a0 <log+0x30>
    80004294:	05c50713          	addi	a4,a0,92
    80004298:	36fd                	addiw	a3,a3,-1
    8000429a:	02069613          	slli	a2,a3,0x20
    8000429e:	01e65693          	srli	a3,a2,0x1e
    800042a2:	00025617          	auipc	a2,0x25
    800042a6:	60260613          	addi	a2,a2,1538 # 800298a4 <log+0x34>
    800042aa:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800042ac:	4390                	lw	a2,0(a5)
    800042ae:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042b0:	0791                	addi	a5,a5,4
    800042b2:	0711                	addi	a4,a4,4
    800042b4:	fed79ce3          	bne	a5,a3,800042ac <write_head+0x50>
  }
  bwrite(buf);
    800042b8:	8526                	mv	a0,s1
    800042ba:	fffff097          	auipc	ra,0xfffff
    800042be:	0a0080e7          	jalr	160(ra) # 8000335a <bwrite>
  brelse(buf);
    800042c2:	8526                	mv	a0,s1
    800042c4:	fffff097          	auipc	ra,0xfffff
    800042c8:	0d4080e7          	jalr	212(ra) # 80003398 <brelse>
}
    800042cc:	60e2                	ld	ra,24(sp)
    800042ce:	6442                	ld	s0,16(sp)
    800042d0:	64a2                	ld	s1,8(sp)
    800042d2:	6902                	ld	s2,0(sp)
    800042d4:	6105                	addi	sp,sp,32
    800042d6:	8082                	ret

00000000800042d8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800042d8:	00025797          	auipc	a5,0x25
    800042dc:	5c47a783          	lw	a5,1476(a5) # 8002989c <log+0x2c>
    800042e0:	0af05d63          	blez	a5,8000439a <install_trans+0xc2>
{
    800042e4:	7139                	addi	sp,sp,-64
    800042e6:	fc06                	sd	ra,56(sp)
    800042e8:	f822                	sd	s0,48(sp)
    800042ea:	f426                	sd	s1,40(sp)
    800042ec:	f04a                	sd	s2,32(sp)
    800042ee:	ec4e                	sd	s3,24(sp)
    800042f0:	e852                	sd	s4,16(sp)
    800042f2:	e456                	sd	s5,8(sp)
    800042f4:	e05a                	sd	s6,0(sp)
    800042f6:	0080                	addi	s0,sp,64
    800042f8:	8b2a                	mv	s6,a0
    800042fa:	00025a97          	auipc	s5,0x25
    800042fe:	5a6a8a93          	addi	s5,s5,1446 # 800298a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004302:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004304:	00025997          	auipc	s3,0x25
    80004308:	56c98993          	addi	s3,s3,1388 # 80029870 <log>
    8000430c:	a00d                	j	8000432e <install_trans+0x56>
    brelse(lbuf);
    8000430e:	854a                	mv	a0,s2
    80004310:	fffff097          	auipc	ra,0xfffff
    80004314:	088080e7          	jalr	136(ra) # 80003398 <brelse>
    brelse(dbuf);
    80004318:	8526                	mv	a0,s1
    8000431a:	fffff097          	auipc	ra,0xfffff
    8000431e:	07e080e7          	jalr	126(ra) # 80003398 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004322:	2a05                	addiw	s4,s4,1
    80004324:	0a91                	addi	s5,s5,4
    80004326:	02c9a783          	lw	a5,44(s3)
    8000432a:	04fa5e63          	bge	s4,a5,80004386 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000432e:	0189a583          	lw	a1,24(s3)
    80004332:	014585bb          	addw	a1,a1,s4
    80004336:	2585                	addiw	a1,a1,1
    80004338:	0289a503          	lw	a0,40(s3)
    8000433c:	fffff097          	auipc	ra,0xfffff
    80004340:	f2c080e7          	jalr	-212(ra) # 80003268 <bread>
    80004344:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004346:	000aa583          	lw	a1,0(s5)
    8000434a:	0289a503          	lw	a0,40(s3)
    8000434e:	fffff097          	auipc	ra,0xfffff
    80004352:	f1a080e7          	jalr	-230(ra) # 80003268 <bread>
    80004356:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004358:	40000613          	li	a2,1024
    8000435c:	05890593          	addi	a1,s2,88
    80004360:	05850513          	addi	a0,a0,88
    80004364:	ffffd097          	auipc	ra,0xffffd
    80004368:	9d0080e7          	jalr	-1584(ra) # 80000d34 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000436c:	8526                	mv	a0,s1
    8000436e:	fffff097          	auipc	ra,0xfffff
    80004372:	fec080e7          	jalr	-20(ra) # 8000335a <bwrite>
    if(recovering == 0)
    80004376:	f80b1ce3          	bnez	s6,8000430e <install_trans+0x36>
      bunpin(dbuf);
    8000437a:	8526                	mv	a0,s1
    8000437c:	fffff097          	auipc	ra,0xfffff
    80004380:	0f6080e7          	jalr	246(ra) # 80003472 <bunpin>
    80004384:	b769                	j	8000430e <install_trans+0x36>
}
    80004386:	70e2                	ld	ra,56(sp)
    80004388:	7442                	ld	s0,48(sp)
    8000438a:	74a2                	ld	s1,40(sp)
    8000438c:	7902                	ld	s2,32(sp)
    8000438e:	69e2                	ld	s3,24(sp)
    80004390:	6a42                	ld	s4,16(sp)
    80004392:	6aa2                	ld	s5,8(sp)
    80004394:	6b02                	ld	s6,0(sp)
    80004396:	6121                	addi	sp,sp,64
    80004398:	8082                	ret
    8000439a:	8082                	ret

000000008000439c <initlog>:
{
    8000439c:	7179                	addi	sp,sp,-48
    8000439e:	f406                	sd	ra,40(sp)
    800043a0:	f022                	sd	s0,32(sp)
    800043a2:	ec26                	sd	s1,24(sp)
    800043a4:	e84a                	sd	s2,16(sp)
    800043a6:	e44e                	sd	s3,8(sp)
    800043a8:	1800                	addi	s0,sp,48
    800043aa:	892a                	mv	s2,a0
    800043ac:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800043ae:	00025497          	auipc	s1,0x25
    800043b2:	4c248493          	addi	s1,s1,1218 # 80029870 <log>
    800043b6:	00004597          	auipc	a1,0x4
    800043ba:	2b258593          	addi	a1,a1,690 # 80008668 <syscalls+0x1f0>
    800043be:	8526                	mv	a0,s1
    800043c0:	ffffc097          	auipc	ra,0xffffc
    800043c4:	776080e7          	jalr	1910(ra) # 80000b36 <initlock>
  log.start = sb->logstart;
    800043c8:	0149a583          	lw	a1,20(s3)
    800043cc:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800043ce:	0109a783          	lw	a5,16(s3)
    800043d2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800043d4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800043d8:	854a                	mv	a0,s2
    800043da:	fffff097          	auipc	ra,0xfffff
    800043de:	e8e080e7          	jalr	-370(ra) # 80003268 <bread>
  log.lh.n = lh->n;
    800043e2:	4d34                	lw	a3,88(a0)
    800043e4:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800043e6:	02d05663          	blez	a3,80004412 <initlog+0x76>
    800043ea:	05c50793          	addi	a5,a0,92
    800043ee:	00025717          	auipc	a4,0x25
    800043f2:	4b270713          	addi	a4,a4,1202 # 800298a0 <log+0x30>
    800043f6:	36fd                	addiw	a3,a3,-1
    800043f8:	02069613          	slli	a2,a3,0x20
    800043fc:	01e65693          	srli	a3,a2,0x1e
    80004400:	06050613          	addi	a2,a0,96
    80004404:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004406:	4390                	lw	a2,0(a5)
    80004408:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000440a:	0791                	addi	a5,a5,4
    8000440c:	0711                	addi	a4,a4,4
    8000440e:	fed79ce3          	bne	a5,a3,80004406 <initlog+0x6a>
  brelse(buf);
    80004412:	fffff097          	auipc	ra,0xfffff
    80004416:	f86080e7          	jalr	-122(ra) # 80003398 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000441a:	4505                	li	a0,1
    8000441c:	00000097          	auipc	ra,0x0
    80004420:	ebc080e7          	jalr	-324(ra) # 800042d8 <install_trans>
  log.lh.n = 0;
    80004424:	00025797          	auipc	a5,0x25
    80004428:	4607ac23          	sw	zero,1144(a5) # 8002989c <log+0x2c>
  write_head(); // clear the log
    8000442c:	00000097          	auipc	ra,0x0
    80004430:	e30080e7          	jalr	-464(ra) # 8000425c <write_head>
}
    80004434:	70a2                	ld	ra,40(sp)
    80004436:	7402                	ld	s0,32(sp)
    80004438:	64e2                	ld	s1,24(sp)
    8000443a:	6942                	ld	s2,16(sp)
    8000443c:	69a2                	ld	s3,8(sp)
    8000443e:	6145                	addi	sp,sp,48
    80004440:	8082                	ret

0000000080004442 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004442:	1101                	addi	sp,sp,-32
    80004444:	ec06                	sd	ra,24(sp)
    80004446:	e822                	sd	s0,16(sp)
    80004448:	e426                	sd	s1,8(sp)
    8000444a:	e04a                	sd	s2,0(sp)
    8000444c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000444e:	00025517          	auipc	a0,0x25
    80004452:	42250513          	addi	a0,a0,1058 # 80029870 <log>
    80004456:	ffffc097          	auipc	ra,0xffffc
    8000445a:	770080e7          	jalr	1904(ra) # 80000bc6 <acquire>
  while(1){
    if(log.committing){
    8000445e:	00025497          	auipc	s1,0x25
    80004462:	41248493          	addi	s1,s1,1042 # 80029870 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004466:	4979                	li	s2,30
    80004468:	a039                	j	80004476 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000446a:	85a6                	mv	a1,s1
    8000446c:	8526                	mv	a0,s1
    8000446e:	ffffe097          	auipc	ra,0xffffe
    80004472:	c76080e7          	jalr	-906(ra) # 800020e4 <sleep>
    if(log.committing){
    80004476:	50dc                	lw	a5,36(s1)
    80004478:	fbed                	bnez	a5,8000446a <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000447a:	509c                	lw	a5,32(s1)
    8000447c:	0017871b          	addiw	a4,a5,1
    80004480:	0007069b          	sext.w	a3,a4
    80004484:	0027179b          	slliw	a5,a4,0x2
    80004488:	9fb9                	addw	a5,a5,a4
    8000448a:	0017979b          	slliw	a5,a5,0x1
    8000448e:	54d8                	lw	a4,44(s1)
    80004490:	9fb9                	addw	a5,a5,a4
    80004492:	00f95963          	bge	s2,a5,800044a4 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004496:	85a6                	mv	a1,s1
    80004498:	8526                	mv	a0,s1
    8000449a:	ffffe097          	auipc	ra,0xffffe
    8000449e:	c4a080e7          	jalr	-950(ra) # 800020e4 <sleep>
    800044a2:	bfd1                	j	80004476 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800044a4:	00025517          	auipc	a0,0x25
    800044a8:	3cc50513          	addi	a0,a0,972 # 80029870 <log>
    800044ac:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800044ae:	ffffc097          	auipc	ra,0xffffc
    800044b2:	7e2080e7          	jalr	2018(ra) # 80000c90 <release>
      break;
    }
  }
}
    800044b6:	60e2                	ld	ra,24(sp)
    800044b8:	6442                	ld	s0,16(sp)
    800044ba:	64a2                	ld	s1,8(sp)
    800044bc:	6902                	ld	s2,0(sp)
    800044be:	6105                	addi	sp,sp,32
    800044c0:	8082                	ret

00000000800044c2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800044c2:	7139                	addi	sp,sp,-64
    800044c4:	fc06                	sd	ra,56(sp)
    800044c6:	f822                	sd	s0,48(sp)
    800044c8:	f426                	sd	s1,40(sp)
    800044ca:	f04a                	sd	s2,32(sp)
    800044cc:	ec4e                	sd	s3,24(sp)
    800044ce:	e852                	sd	s4,16(sp)
    800044d0:	e456                	sd	s5,8(sp)
    800044d2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800044d4:	00025497          	auipc	s1,0x25
    800044d8:	39c48493          	addi	s1,s1,924 # 80029870 <log>
    800044dc:	8526                	mv	a0,s1
    800044de:	ffffc097          	auipc	ra,0xffffc
    800044e2:	6e8080e7          	jalr	1768(ra) # 80000bc6 <acquire>
  log.outstanding -= 1;
    800044e6:	509c                	lw	a5,32(s1)
    800044e8:	37fd                	addiw	a5,a5,-1
    800044ea:	0007891b          	sext.w	s2,a5
    800044ee:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800044f0:	50dc                	lw	a5,36(s1)
    800044f2:	e7b9                	bnez	a5,80004540 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800044f4:	04091e63          	bnez	s2,80004550 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800044f8:	00025497          	auipc	s1,0x25
    800044fc:	37848493          	addi	s1,s1,888 # 80029870 <log>
    80004500:	4785                	li	a5,1
    80004502:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004504:	8526                	mv	a0,s1
    80004506:	ffffc097          	auipc	ra,0xffffc
    8000450a:	78a080e7          	jalr	1930(ra) # 80000c90 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000450e:	54dc                	lw	a5,44(s1)
    80004510:	06f04763          	bgtz	a5,8000457e <end_op+0xbc>
    acquire(&log.lock);
    80004514:	00025497          	auipc	s1,0x25
    80004518:	35c48493          	addi	s1,s1,860 # 80029870 <log>
    8000451c:	8526                	mv	a0,s1
    8000451e:	ffffc097          	auipc	ra,0xffffc
    80004522:	6a8080e7          	jalr	1704(ra) # 80000bc6 <acquire>
    log.committing = 0;
    80004526:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000452a:	8526                	mv	a0,s1
    8000452c:	ffffe097          	auipc	ra,0xffffe
    80004530:	d46080e7          	jalr	-698(ra) # 80002272 <wakeup>
    release(&log.lock);
    80004534:	8526                	mv	a0,s1
    80004536:	ffffc097          	auipc	ra,0xffffc
    8000453a:	75a080e7          	jalr	1882(ra) # 80000c90 <release>
}
    8000453e:	a03d                	j	8000456c <end_op+0xaa>
    panic("log.committing");
    80004540:	00004517          	auipc	a0,0x4
    80004544:	13050513          	addi	a0,a0,304 # 80008670 <syscalls+0x1f8>
    80004548:	ffffc097          	auipc	ra,0xffffc
    8000454c:	fe6080e7          	jalr	-26(ra) # 8000052e <panic>
    wakeup(&log);
    80004550:	00025497          	auipc	s1,0x25
    80004554:	32048493          	addi	s1,s1,800 # 80029870 <log>
    80004558:	8526                	mv	a0,s1
    8000455a:	ffffe097          	auipc	ra,0xffffe
    8000455e:	d18080e7          	jalr	-744(ra) # 80002272 <wakeup>
  release(&log.lock);
    80004562:	8526                	mv	a0,s1
    80004564:	ffffc097          	auipc	ra,0xffffc
    80004568:	72c080e7          	jalr	1836(ra) # 80000c90 <release>
}
    8000456c:	70e2                	ld	ra,56(sp)
    8000456e:	7442                	ld	s0,48(sp)
    80004570:	74a2                	ld	s1,40(sp)
    80004572:	7902                	ld	s2,32(sp)
    80004574:	69e2                	ld	s3,24(sp)
    80004576:	6a42                	ld	s4,16(sp)
    80004578:	6aa2                	ld	s5,8(sp)
    8000457a:	6121                	addi	sp,sp,64
    8000457c:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000457e:	00025a97          	auipc	s5,0x25
    80004582:	322a8a93          	addi	s5,s5,802 # 800298a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004586:	00025a17          	auipc	s4,0x25
    8000458a:	2eaa0a13          	addi	s4,s4,746 # 80029870 <log>
    8000458e:	018a2583          	lw	a1,24(s4)
    80004592:	012585bb          	addw	a1,a1,s2
    80004596:	2585                	addiw	a1,a1,1
    80004598:	028a2503          	lw	a0,40(s4)
    8000459c:	fffff097          	auipc	ra,0xfffff
    800045a0:	ccc080e7          	jalr	-820(ra) # 80003268 <bread>
    800045a4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800045a6:	000aa583          	lw	a1,0(s5)
    800045aa:	028a2503          	lw	a0,40(s4)
    800045ae:	fffff097          	auipc	ra,0xfffff
    800045b2:	cba080e7          	jalr	-838(ra) # 80003268 <bread>
    800045b6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800045b8:	40000613          	li	a2,1024
    800045bc:	05850593          	addi	a1,a0,88
    800045c0:	05848513          	addi	a0,s1,88
    800045c4:	ffffc097          	auipc	ra,0xffffc
    800045c8:	770080e7          	jalr	1904(ra) # 80000d34 <memmove>
    bwrite(to);  // write the log
    800045cc:	8526                	mv	a0,s1
    800045ce:	fffff097          	auipc	ra,0xfffff
    800045d2:	d8c080e7          	jalr	-628(ra) # 8000335a <bwrite>
    brelse(from);
    800045d6:	854e                	mv	a0,s3
    800045d8:	fffff097          	auipc	ra,0xfffff
    800045dc:	dc0080e7          	jalr	-576(ra) # 80003398 <brelse>
    brelse(to);
    800045e0:	8526                	mv	a0,s1
    800045e2:	fffff097          	auipc	ra,0xfffff
    800045e6:	db6080e7          	jalr	-586(ra) # 80003398 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045ea:	2905                	addiw	s2,s2,1
    800045ec:	0a91                	addi	s5,s5,4
    800045ee:	02ca2783          	lw	a5,44(s4)
    800045f2:	f8f94ee3          	blt	s2,a5,8000458e <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800045f6:	00000097          	auipc	ra,0x0
    800045fa:	c66080e7          	jalr	-922(ra) # 8000425c <write_head>
    install_trans(0); // Now install writes to home locations
    800045fe:	4501                	li	a0,0
    80004600:	00000097          	auipc	ra,0x0
    80004604:	cd8080e7          	jalr	-808(ra) # 800042d8 <install_trans>
    log.lh.n = 0;
    80004608:	00025797          	auipc	a5,0x25
    8000460c:	2807aa23          	sw	zero,660(a5) # 8002989c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004610:	00000097          	auipc	ra,0x0
    80004614:	c4c080e7          	jalr	-948(ra) # 8000425c <write_head>
    80004618:	bdf5                	j	80004514 <end_op+0x52>

000000008000461a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000461a:	1101                	addi	sp,sp,-32
    8000461c:	ec06                	sd	ra,24(sp)
    8000461e:	e822                	sd	s0,16(sp)
    80004620:	e426                	sd	s1,8(sp)
    80004622:	e04a                	sd	s2,0(sp)
    80004624:	1000                	addi	s0,sp,32
    80004626:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004628:	00025917          	auipc	s2,0x25
    8000462c:	24890913          	addi	s2,s2,584 # 80029870 <log>
    80004630:	854a                	mv	a0,s2
    80004632:	ffffc097          	auipc	ra,0xffffc
    80004636:	594080e7          	jalr	1428(ra) # 80000bc6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000463a:	02c92603          	lw	a2,44(s2)
    8000463e:	47f5                	li	a5,29
    80004640:	06c7c563          	blt	a5,a2,800046aa <log_write+0x90>
    80004644:	00025797          	auipc	a5,0x25
    80004648:	2487a783          	lw	a5,584(a5) # 8002988c <log+0x1c>
    8000464c:	37fd                	addiw	a5,a5,-1
    8000464e:	04f65e63          	bge	a2,a5,800046aa <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004652:	00025797          	auipc	a5,0x25
    80004656:	23e7a783          	lw	a5,574(a5) # 80029890 <log+0x20>
    8000465a:	06f05063          	blez	a5,800046ba <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000465e:	4781                	li	a5,0
    80004660:	06c05563          	blez	a2,800046ca <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004664:	44cc                	lw	a1,12(s1)
    80004666:	00025717          	auipc	a4,0x25
    8000466a:	23a70713          	addi	a4,a4,570 # 800298a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000466e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004670:	4314                	lw	a3,0(a4)
    80004672:	04b68c63          	beq	a3,a1,800046ca <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004676:	2785                	addiw	a5,a5,1
    80004678:	0711                	addi	a4,a4,4
    8000467a:	fef61be3          	bne	a2,a5,80004670 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000467e:	0621                	addi	a2,a2,8
    80004680:	060a                	slli	a2,a2,0x2
    80004682:	00025797          	auipc	a5,0x25
    80004686:	1ee78793          	addi	a5,a5,494 # 80029870 <log>
    8000468a:	963e                	add	a2,a2,a5
    8000468c:	44dc                	lw	a5,12(s1)
    8000468e:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004690:	8526                	mv	a0,s1
    80004692:	fffff097          	auipc	ra,0xfffff
    80004696:	da4080e7          	jalr	-604(ra) # 80003436 <bpin>
    log.lh.n++;
    8000469a:	00025717          	auipc	a4,0x25
    8000469e:	1d670713          	addi	a4,a4,470 # 80029870 <log>
    800046a2:	575c                	lw	a5,44(a4)
    800046a4:	2785                	addiw	a5,a5,1
    800046a6:	d75c                	sw	a5,44(a4)
    800046a8:	a835                	j	800046e4 <log_write+0xca>
    panic("too big a transaction");
    800046aa:	00004517          	auipc	a0,0x4
    800046ae:	fd650513          	addi	a0,a0,-42 # 80008680 <syscalls+0x208>
    800046b2:	ffffc097          	auipc	ra,0xffffc
    800046b6:	e7c080e7          	jalr	-388(ra) # 8000052e <panic>
    panic("log_write outside of trans");
    800046ba:	00004517          	auipc	a0,0x4
    800046be:	fde50513          	addi	a0,a0,-34 # 80008698 <syscalls+0x220>
    800046c2:	ffffc097          	auipc	ra,0xffffc
    800046c6:	e6c080e7          	jalr	-404(ra) # 8000052e <panic>
  log.lh.block[i] = b->blockno;
    800046ca:	00878713          	addi	a4,a5,8
    800046ce:	00271693          	slli	a3,a4,0x2
    800046d2:	00025717          	auipc	a4,0x25
    800046d6:	19e70713          	addi	a4,a4,414 # 80029870 <log>
    800046da:	9736                	add	a4,a4,a3
    800046dc:	44d4                	lw	a3,12(s1)
    800046de:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800046e0:	faf608e3          	beq	a2,a5,80004690 <log_write+0x76>
  }
  release(&log.lock);
    800046e4:	00025517          	auipc	a0,0x25
    800046e8:	18c50513          	addi	a0,a0,396 # 80029870 <log>
    800046ec:	ffffc097          	auipc	ra,0xffffc
    800046f0:	5a4080e7          	jalr	1444(ra) # 80000c90 <release>
}
    800046f4:	60e2                	ld	ra,24(sp)
    800046f6:	6442                	ld	s0,16(sp)
    800046f8:	64a2                	ld	s1,8(sp)
    800046fa:	6902                	ld	s2,0(sp)
    800046fc:	6105                	addi	sp,sp,32
    800046fe:	8082                	ret

0000000080004700 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004700:	1101                	addi	sp,sp,-32
    80004702:	ec06                	sd	ra,24(sp)
    80004704:	e822                	sd	s0,16(sp)
    80004706:	e426                	sd	s1,8(sp)
    80004708:	e04a                	sd	s2,0(sp)
    8000470a:	1000                	addi	s0,sp,32
    8000470c:	84aa                	mv	s1,a0
    8000470e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004710:	00004597          	auipc	a1,0x4
    80004714:	fa858593          	addi	a1,a1,-88 # 800086b8 <syscalls+0x240>
    80004718:	0521                	addi	a0,a0,8
    8000471a:	ffffc097          	auipc	ra,0xffffc
    8000471e:	41c080e7          	jalr	1052(ra) # 80000b36 <initlock>
  lk->name = name;
    80004722:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004726:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000472a:	0204a423          	sw	zero,40(s1)
}
    8000472e:	60e2                	ld	ra,24(sp)
    80004730:	6442                	ld	s0,16(sp)
    80004732:	64a2                	ld	s1,8(sp)
    80004734:	6902                	ld	s2,0(sp)
    80004736:	6105                	addi	sp,sp,32
    80004738:	8082                	ret

000000008000473a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000473a:	1101                	addi	sp,sp,-32
    8000473c:	ec06                	sd	ra,24(sp)
    8000473e:	e822                	sd	s0,16(sp)
    80004740:	e426                	sd	s1,8(sp)
    80004742:	e04a                	sd	s2,0(sp)
    80004744:	1000                	addi	s0,sp,32
    80004746:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004748:	00850913          	addi	s2,a0,8
    8000474c:	854a                	mv	a0,s2
    8000474e:	ffffc097          	auipc	ra,0xffffc
    80004752:	478080e7          	jalr	1144(ra) # 80000bc6 <acquire>
  while (lk->locked) {
    80004756:	409c                	lw	a5,0(s1)
    80004758:	cb89                	beqz	a5,8000476a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000475a:	85ca                	mv	a1,s2
    8000475c:	8526                	mv	a0,s1
    8000475e:	ffffe097          	auipc	ra,0xffffe
    80004762:	986080e7          	jalr	-1658(ra) # 800020e4 <sleep>
  while (lk->locked) {
    80004766:	409c                	lw	a5,0(s1)
    80004768:	fbed                	bnez	a5,8000475a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000476a:	4785                	li	a5,1
    8000476c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000476e:	ffffd097          	auipc	ra,0xffffd
    80004772:	22a080e7          	jalr	554(ra) # 80001998 <myproc>
    80004776:	591c                	lw	a5,48(a0)
    80004778:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000477a:	854a                	mv	a0,s2
    8000477c:	ffffc097          	auipc	ra,0xffffc
    80004780:	514080e7          	jalr	1300(ra) # 80000c90 <release>
}
    80004784:	60e2                	ld	ra,24(sp)
    80004786:	6442                	ld	s0,16(sp)
    80004788:	64a2                	ld	s1,8(sp)
    8000478a:	6902                	ld	s2,0(sp)
    8000478c:	6105                	addi	sp,sp,32
    8000478e:	8082                	ret

0000000080004790 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004790:	1101                	addi	sp,sp,-32
    80004792:	ec06                	sd	ra,24(sp)
    80004794:	e822                	sd	s0,16(sp)
    80004796:	e426                	sd	s1,8(sp)
    80004798:	e04a                	sd	s2,0(sp)
    8000479a:	1000                	addi	s0,sp,32
    8000479c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000479e:	00850913          	addi	s2,a0,8
    800047a2:	854a                	mv	a0,s2
    800047a4:	ffffc097          	auipc	ra,0xffffc
    800047a8:	422080e7          	jalr	1058(ra) # 80000bc6 <acquire>
  lk->locked = 0;
    800047ac:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800047b0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800047b4:	8526                	mv	a0,s1
    800047b6:	ffffe097          	auipc	ra,0xffffe
    800047ba:	abc080e7          	jalr	-1348(ra) # 80002272 <wakeup>
  release(&lk->lk);
    800047be:	854a                	mv	a0,s2
    800047c0:	ffffc097          	auipc	ra,0xffffc
    800047c4:	4d0080e7          	jalr	1232(ra) # 80000c90 <release>
}
    800047c8:	60e2                	ld	ra,24(sp)
    800047ca:	6442                	ld	s0,16(sp)
    800047cc:	64a2                	ld	s1,8(sp)
    800047ce:	6902                	ld	s2,0(sp)
    800047d0:	6105                	addi	sp,sp,32
    800047d2:	8082                	ret

00000000800047d4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800047d4:	7179                	addi	sp,sp,-48
    800047d6:	f406                	sd	ra,40(sp)
    800047d8:	f022                	sd	s0,32(sp)
    800047da:	ec26                	sd	s1,24(sp)
    800047dc:	e84a                	sd	s2,16(sp)
    800047de:	e44e                	sd	s3,8(sp)
    800047e0:	1800                	addi	s0,sp,48
    800047e2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800047e4:	00850913          	addi	s2,a0,8
    800047e8:	854a                	mv	a0,s2
    800047ea:	ffffc097          	auipc	ra,0xffffc
    800047ee:	3dc080e7          	jalr	988(ra) # 80000bc6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800047f2:	409c                	lw	a5,0(s1)
    800047f4:	ef99                	bnez	a5,80004812 <holdingsleep+0x3e>
    800047f6:	4481                	li	s1,0
  release(&lk->lk);
    800047f8:	854a                	mv	a0,s2
    800047fa:	ffffc097          	auipc	ra,0xffffc
    800047fe:	496080e7          	jalr	1174(ra) # 80000c90 <release>
  return r;
}
    80004802:	8526                	mv	a0,s1
    80004804:	70a2                	ld	ra,40(sp)
    80004806:	7402                	ld	s0,32(sp)
    80004808:	64e2                	ld	s1,24(sp)
    8000480a:	6942                	ld	s2,16(sp)
    8000480c:	69a2                	ld	s3,8(sp)
    8000480e:	6145                	addi	sp,sp,48
    80004810:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004812:	0284a983          	lw	s3,40(s1)
    80004816:	ffffd097          	auipc	ra,0xffffd
    8000481a:	182080e7          	jalr	386(ra) # 80001998 <myproc>
    8000481e:	5904                	lw	s1,48(a0)
    80004820:	413484b3          	sub	s1,s1,s3
    80004824:	0014b493          	seqz	s1,s1
    80004828:	bfc1                	j	800047f8 <holdingsleep+0x24>

000000008000482a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000482a:	1141                	addi	sp,sp,-16
    8000482c:	e406                	sd	ra,8(sp)
    8000482e:	e022                	sd	s0,0(sp)
    80004830:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004832:	00004597          	auipc	a1,0x4
    80004836:	e9658593          	addi	a1,a1,-362 # 800086c8 <syscalls+0x250>
    8000483a:	00025517          	auipc	a0,0x25
    8000483e:	17e50513          	addi	a0,a0,382 # 800299b8 <ftable>
    80004842:	ffffc097          	auipc	ra,0xffffc
    80004846:	2f4080e7          	jalr	756(ra) # 80000b36 <initlock>
}
    8000484a:	60a2                	ld	ra,8(sp)
    8000484c:	6402                	ld	s0,0(sp)
    8000484e:	0141                	addi	sp,sp,16
    80004850:	8082                	ret

0000000080004852 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004852:	1101                	addi	sp,sp,-32
    80004854:	ec06                	sd	ra,24(sp)
    80004856:	e822                	sd	s0,16(sp)
    80004858:	e426                	sd	s1,8(sp)
    8000485a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000485c:	00025517          	auipc	a0,0x25
    80004860:	15c50513          	addi	a0,a0,348 # 800299b8 <ftable>
    80004864:	ffffc097          	auipc	ra,0xffffc
    80004868:	362080e7          	jalr	866(ra) # 80000bc6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000486c:	00025497          	auipc	s1,0x25
    80004870:	16448493          	addi	s1,s1,356 # 800299d0 <ftable+0x18>
    80004874:	00026717          	auipc	a4,0x26
    80004878:	0fc70713          	addi	a4,a4,252 # 8002a970 <ftable+0xfb8>
    if(f->ref == 0){
    8000487c:	40dc                	lw	a5,4(s1)
    8000487e:	cf99                	beqz	a5,8000489c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004880:	02848493          	addi	s1,s1,40
    80004884:	fee49ce3          	bne	s1,a4,8000487c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004888:	00025517          	auipc	a0,0x25
    8000488c:	13050513          	addi	a0,a0,304 # 800299b8 <ftable>
    80004890:	ffffc097          	auipc	ra,0xffffc
    80004894:	400080e7          	jalr	1024(ra) # 80000c90 <release>
  return 0;
    80004898:	4481                	li	s1,0
    8000489a:	a819                	j	800048b0 <filealloc+0x5e>
      f->ref = 1;
    8000489c:	4785                	li	a5,1
    8000489e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800048a0:	00025517          	auipc	a0,0x25
    800048a4:	11850513          	addi	a0,a0,280 # 800299b8 <ftable>
    800048a8:	ffffc097          	auipc	ra,0xffffc
    800048ac:	3e8080e7          	jalr	1000(ra) # 80000c90 <release>
}
    800048b0:	8526                	mv	a0,s1
    800048b2:	60e2                	ld	ra,24(sp)
    800048b4:	6442                	ld	s0,16(sp)
    800048b6:	64a2                	ld	s1,8(sp)
    800048b8:	6105                	addi	sp,sp,32
    800048ba:	8082                	ret

00000000800048bc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800048bc:	1101                	addi	sp,sp,-32
    800048be:	ec06                	sd	ra,24(sp)
    800048c0:	e822                	sd	s0,16(sp)
    800048c2:	e426                	sd	s1,8(sp)
    800048c4:	1000                	addi	s0,sp,32
    800048c6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800048c8:	00025517          	auipc	a0,0x25
    800048cc:	0f050513          	addi	a0,a0,240 # 800299b8 <ftable>
    800048d0:	ffffc097          	auipc	ra,0xffffc
    800048d4:	2f6080e7          	jalr	758(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    800048d8:	40dc                	lw	a5,4(s1)
    800048da:	02f05263          	blez	a5,800048fe <filedup+0x42>
    panic("filedup");
  f->ref++;
    800048de:	2785                	addiw	a5,a5,1
    800048e0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800048e2:	00025517          	auipc	a0,0x25
    800048e6:	0d650513          	addi	a0,a0,214 # 800299b8 <ftable>
    800048ea:	ffffc097          	auipc	ra,0xffffc
    800048ee:	3a6080e7          	jalr	934(ra) # 80000c90 <release>
  return f;
}
    800048f2:	8526                	mv	a0,s1
    800048f4:	60e2                	ld	ra,24(sp)
    800048f6:	6442                	ld	s0,16(sp)
    800048f8:	64a2                	ld	s1,8(sp)
    800048fa:	6105                	addi	sp,sp,32
    800048fc:	8082                	ret
    panic("filedup");
    800048fe:	00004517          	auipc	a0,0x4
    80004902:	dd250513          	addi	a0,a0,-558 # 800086d0 <syscalls+0x258>
    80004906:	ffffc097          	auipc	ra,0xffffc
    8000490a:	c28080e7          	jalr	-984(ra) # 8000052e <panic>

000000008000490e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000490e:	7139                	addi	sp,sp,-64
    80004910:	fc06                	sd	ra,56(sp)
    80004912:	f822                	sd	s0,48(sp)
    80004914:	f426                	sd	s1,40(sp)
    80004916:	f04a                	sd	s2,32(sp)
    80004918:	ec4e                	sd	s3,24(sp)
    8000491a:	e852                	sd	s4,16(sp)
    8000491c:	e456                	sd	s5,8(sp)
    8000491e:	0080                	addi	s0,sp,64
    80004920:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004922:	00025517          	auipc	a0,0x25
    80004926:	09650513          	addi	a0,a0,150 # 800299b8 <ftable>
    8000492a:	ffffc097          	auipc	ra,0xffffc
    8000492e:	29c080e7          	jalr	668(ra) # 80000bc6 <acquire>
  if(f->ref < 1)
    80004932:	40dc                	lw	a5,4(s1)
    80004934:	06f05163          	blez	a5,80004996 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004938:	37fd                	addiw	a5,a5,-1
    8000493a:	0007871b          	sext.w	a4,a5
    8000493e:	c0dc                	sw	a5,4(s1)
    80004940:	06e04363          	bgtz	a4,800049a6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004944:	0004a903          	lw	s2,0(s1)
    80004948:	0094ca83          	lbu	s5,9(s1)
    8000494c:	0104ba03          	ld	s4,16(s1)
    80004950:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004954:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004958:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000495c:	00025517          	auipc	a0,0x25
    80004960:	05c50513          	addi	a0,a0,92 # 800299b8 <ftable>
    80004964:	ffffc097          	auipc	ra,0xffffc
    80004968:	32c080e7          	jalr	812(ra) # 80000c90 <release>

  if(ff.type == FD_PIPE){
    8000496c:	4785                	li	a5,1
    8000496e:	04f90d63          	beq	s2,a5,800049c8 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004972:	3979                	addiw	s2,s2,-2
    80004974:	4785                	li	a5,1
    80004976:	0527e063          	bltu	a5,s2,800049b6 <fileclose+0xa8>
    begin_op();
    8000497a:	00000097          	auipc	ra,0x0
    8000497e:	ac8080e7          	jalr	-1336(ra) # 80004442 <begin_op>
    iput(ff.ip);
    80004982:	854e                	mv	a0,s3
    80004984:	fffff097          	auipc	ra,0xfffff
    80004988:	2a2080e7          	jalr	674(ra) # 80003c26 <iput>
    end_op();
    8000498c:	00000097          	auipc	ra,0x0
    80004990:	b36080e7          	jalr	-1226(ra) # 800044c2 <end_op>
    80004994:	a00d                	j	800049b6 <fileclose+0xa8>
    panic("fileclose");
    80004996:	00004517          	auipc	a0,0x4
    8000499a:	d4250513          	addi	a0,a0,-702 # 800086d8 <syscalls+0x260>
    8000499e:	ffffc097          	auipc	ra,0xffffc
    800049a2:	b90080e7          	jalr	-1136(ra) # 8000052e <panic>
    release(&ftable.lock);
    800049a6:	00025517          	auipc	a0,0x25
    800049aa:	01250513          	addi	a0,a0,18 # 800299b8 <ftable>
    800049ae:	ffffc097          	auipc	ra,0xffffc
    800049b2:	2e2080e7          	jalr	738(ra) # 80000c90 <release>
  }
}
    800049b6:	70e2                	ld	ra,56(sp)
    800049b8:	7442                	ld	s0,48(sp)
    800049ba:	74a2                	ld	s1,40(sp)
    800049bc:	7902                	ld	s2,32(sp)
    800049be:	69e2                	ld	s3,24(sp)
    800049c0:	6a42                	ld	s4,16(sp)
    800049c2:	6aa2                	ld	s5,8(sp)
    800049c4:	6121                	addi	sp,sp,64
    800049c6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800049c8:	85d6                	mv	a1,s5
    800049ca:	8552                	mv	a0,s4
    800049cc:	00000097          	auipc	ra,0x0
    800049d0:	34c080e7          	jalr	844(ra) # 80004d18 <pipeclose>
    800049d4:	b7cd                	j	800049b6 <fileclose+0xa8>

00000000800049d6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800049d6:	715d                	addi	sp,sp,-80
    800049d8:	e486                	sd	ra,72(sp)
    800049da:	e0a2                	sd	s0,64(sp)
    800049dc:	fc26                	sd	s1,56(sp)
    800049de:	f84a                	sd	s2,48(sp)
    800049e0:	f44e                	sd	s3,40(sp)
    800049e2:	0880                	addi	s0,sp,80
    800049e4:	84aa                	mv	s1,a0
    800049e6:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800049e8:	ffffd097          	auipc	ra,0xffffd
    800049ec:	fb0080e7          	jalr	-80(ra) # 80001998 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800049f0:	409c                	lw	a5,0(s1)
    800049f2:	37f9                	addiw	a5,a5,-2
    800049f4:	4705                	li	a4,1
    800049f6:	04f76763          	bltu	a4,a5,80004a44 <filestat+0x6e>
    800049fa:	892a                	mv	s2,a0
    ilock(f->ip);
    800049fc:	6c88                	ld	a0,24(s1)
    800049fe:	fffff097          	auipc	ra,0xfffff
    80004a02:	06e080e7          	jalr	110(ra) # 80003a6c <ilock>
    stati(f->ip, &st);
    80004a06:	fb840593          	addi	a1,s0,-72
    80004a0a:	6c88                	ld	a0,24(s1)
    80004a0c:	fffff097          	auipc	ra,0xfffff
    80004a10:	2ea080e7          	jalr	746(ra) # 80003cf6 <stati>
    iunlock(f->ip);
    80004a14:	6c88                	ld	a0,24(s1)
    80004a16:	fffff097          	auipc	ra,0xfffff
    80004a1a:	118080e7          	jalr	280(ra) # 80003b2e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004a1e:	46e1                	li	a3,24
    80004a20:	fb840613          	addi	a2,s0,-72
    80004a24:	85ce                	mv	a1,s3
    80004a26:	05093503          	ld	a0,80(s2)
    80004a2a:	ffffd097          	auipc	ra,0xffffd
    80004a2e:	c2e080e7          	jalr	-978(ra) # 80001658 <copyout>
    80004a32:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004a36:	60a6                	ld	ra,72(sp)
    80004a38:	6406                	ld	s0,64(sp)
    80004a3a:	74e2                	ld	s1,56(sp)
    80004a3c:	7942                	ld	s2,48(sp)
    80004a3e:	79a2                	ld	s3,40(sp)
    80004a40:	6161                	addi	sp,sp,80
    80004a42:	8082                	ret
  return -1;
    80004a44:	557d                	li	a0,-1
    80004a46:	bfc5                	j	80004a36 <filestat+0x60>

0000000080004a48 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004a48:	7179                	addi	sp,sp,-48
    80004a4a:	f406                	sd	ra,40(sp)
    80004a4c:	f022                	sd	s0,32(sp)
    80004a4e:	ec26                	sd	s1,24(sp)
    80004a50:	e84a                	sd	s2,16(sp)
    80004a52:	e44e                	sd	s3,8(sp)
    80004a54:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004a56:	00854783          	lbu	a5,8(a0)
    80004a5a:	c3d5                	beqz	a5,80004afe <fileread+0xb6>
    80004a5c:	84aa                	mv	s1,a0
    80004a5e:	89ae                	mv	s3,a1
    80004a60:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a62:	411c                	lw	a5,0(a0)
    80004a64:	4705                	li	a4,1
    80004a66:	04e78963          	beq	a5,a4,80004ab8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a6a:	470d                	li	a4,3
    80004a6c:	04e78d63          	beq	a5,a4,80004ac6 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a70:	4709                	li	a4,2
    80004a72:	06e79e63          	bne	a5,a4,80004aee <fileread+0xa6>
    ilock(f->ip);
    80004a76:	6d08                	ld	a0,24(a0)
    80004a78:	fffff097          	auipc	ra,0xfffff
    80004a7c:	ff4080e7          	jalr	-12(ra) # 80003a6c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004a80:	874a                	mv	a4,s2
    80004a82:	5094                	lw	a3,32(s1)
    80004a84:	864e                	mv	a2,s3
    80004a86:	4585                	li	a1,1
    80004a88:	6c88                	ld	a0,24(s1)
    80004a8a:	fffff097          	auipc	ra,0xfffff
    80004a8e:	296080e7          	jalr	662(ra) # 80003d20 <readi>
    80004a92:	892a                	mv	s2,a0
    80004a94:	00a05563          	blez	a0,80004a9e <fileread+0x56>
      f->off += r;
    80004a98:	509c                	lw	a5,32(s1)
    80004a9a:	9fa9                	addw	a5,a5,a0
    80004a9c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004a9e:	6c88                	ld	a0,24(s1)
    80004aa0:	fffff097          	auipc	ra,0xfffff
    80004aa4:	08e080e7          	jalr	142(ra) # 80003b2e <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004aa8:	854a                	mv	a0,s2
    80004aaa:	70a2                	ld	ra,40(sp)
    80004aac:	7402                	ld	s0,32(sp)
    80004aae:	64e2                	ld	s1,24(sp)
    80004ab0:	6942                	ld	s2,16(sp)
    80004ab2:	69a2                	ld	s3,8(sp)
    80004ab4:	6145                	addi	sp,sp,48
    80004ab6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004ab8:	6908                	ld	a0,16(a0)
    80004aba:	00000097          	auipc	ra,0x0
    80004abe:	3c8080e7          	jalr	968(ra) # 80004e82 <piperead>
    80004ac2:	892a                	mv	s2,a0
    80004ac4:	b7d5                	j	80004aa8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004ac6:	02451783          	lh	a5,36(a0)
    80004aca:	03079693          	slli	a3,a5,0x30
    80004ace:	92c1                	srli	a3,a3,0x30
    80004ad0:	4725                	li	a4,9
    80004ad2:	02d76863          	bltu	a4,a3,80004b02 <fileread+0xba>
    80004ad6:	0792                	slli	a5,a5,0x4
    80004ad8:	00025717          	auipc	a4,0x25
    80004adc:	e4070713          	addi	a4,a4,-448 # 80029918 <devsw>
    80004ae0:	97ba                	add	a5,a5,a4
    80004ae2:	639c                	ld	a5,0(a5)
    80004ae4:	c38d                	beqz	a5,80004b06 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004ae6:	4505                	li	a0,1
    80004ae8:	9782                	jalr	a5
    80004aea:	892a                	mv	s2,a0
    80004aec:	bf75                	j	80004aa8 <fileread+0x60>
    panic("fileread");
    80004aee:	00004517          	auipc	a0,0x4
    80004af2:	bfa50513          	addi	a0,a0,-1030 # 800086e8 <syscalls+0x270>
    80004af6:	ffffc097          	auipc	ra,0xffffc
    80004afa:	a38080e7          	jalr	-1480(ra) # 8000052e <panic>
    return -1;
    80004afe:	597d                	li	s2,-1
    80004b00:	b765                	j	80004aa8 <fileread+0x60>
      return -1;
    80004b02:	597d                	li	s2,-1
    80004b04:	b755                	j	80004aa8 <fileread+0x60>
    80004b06:	597d                	li	s2,-1
    80004b08:	b745                	j	80004aa8 <fileread+0x60>

0000000080004b0a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004b0a:	715d                	addi	sp,sp,-80
    80004b0c:	e486                	sd	ra,72(sp)
    80004b0e:	e0a2                	sd	s0,64(sp)
    80004b10:	fc26                	sd	s1,56(sp)
    80004b12:	f84a                	sd	s2,48(sp)
    80004b14:	f44e                	sd	s3,40(sp)
    80004b16:	f052                	sd	s4,32(sp)
    80004b18:	ec56                	sd	s5,24(sp)
    80004b1a:	e85a                	sd	s6,16(sp)
    80004b1c:	e45e                	sd	s7,8(sp)
    80004b1e:	e062                	sd	s8,0(sp)
    80004b20:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004b22:	00954783          	lbu	a5,9(a0)
    80004b26:	10078663          	beqz	a5,80004c32 <filewrite+0x128>
    80004b2a:	892a                	mv	s2,a0
    80004b2c:	8aae                	mv	s5,a1
    80004b2e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b30:	411c                	lw	a5,0(a0)
    80004b32:	4705                	li	a4,1
    80004b34:	02e78263          	beq	a5,a4,80004b58 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b38:	470d                	li	a4,3
    80004b3a:	02e78663          	beq	a5,a4,80004b66 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b3e:	4709                	li	a4,2
    80004b40:	0ee79163          	bne	a5,a4,80004c22 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004b44:	0ac05d63          	blez	a2,80004bfe <filewrite+0xf4>
    int i = 0;
    80004b48:	4981                	li	s3,0
    80004b4a:	6b05                	lui	s6,0x1
    80004b4c:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004b50:	6b85                	lui	s7,0x1
    80004b52:	c00b8b9b          	addiw	s7,s7,-1024
    80004b56:	a861                	j	80004bee <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004b58:	6908                	ld	a0,16(a0)
    80004b5a:	00000097          	auipc	ra,0x0
    80004b5e:	22e080e7          	jalr	558(ra) # 80004d88 <pipewrite>
    80004b62:	8a2a                	mv	s4,a0
    80004b64:	a045                	j	80004c04 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004b66:	02451783          	lh	a5,36(a0)
    80004b6a:	03079693          	slli	a3,a5,0x30
    80004b6e:	92c1                	srli	a3,a3,0x30
    80004b70:	4725                	li	a4,9
    80004b72:	0cd76263          	bltu	a4,a3,80004c36 <filewrite+0x12c>
    80004b76:	0792                	slli	a5,a5,0x4
    80004b78:	00025717          	auipc	a4,0x25
    80004b7c:	da070713          	addi	a4,a4,-608 # 80029918 <devsw>
    80004b80:	97ba                	add	a5,a5,a4
    80004b82:	679c                	ld	a5,8(a5)
    80004b84:	cbdd                	beqz	a5,80004c3a <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004b86:	4505                	li	a0,1
    80004b88:	9782                	jalr	a5
    80004b8a:	8a2a                	mv	s4,a0
    80004b8c:	a8a5                	j	80004c04 <filewrite+0xfa>
    80004b8e:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004b92:	00000097          	auipc	ra,0x0
    80004b96:	8b0080e7          	jalr	-1872(ra) # 80004442 <begin_op>
      ilock(f->ip);
    80004b9a:	01893503          	ld	a0,24(s2)
    80004b9e:	fffff097          	auipc	ra,0xfffff
    80004ba2:	ece080e7          	jalr	-306(ra) # 80003a6c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ba6:	8762                	mv	a4,s8
    80004ba8:	02092683          	lw	a3,32(s2)
    80004bac:	01598633          	add	a2,s3,s5
    80004bb0:	4585                	li	a1,1
    80004bb2:	01893503          	ld	a0,24(s2)
    80004bb6:	fffff097          	auipc	ra,0xfffff
    80004bba:	262080e7          	jalr	610(ra) # 80003e18 <writei>
    80004bbe:	84aa                	mv	s1,a0
    80004bc0:	00a05763          	blez	a0,80004bce <filewrite+0xc4>
        f->off += r;
    80004bc4:	02092783          	lw	a5,32(s2)
    80004bc8:	9fa9                	addw	a5,a5,a0
    80004bca:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004bce:	01893503          	ld	a0,24(s2)
    80004bd2:	fffff097          	auipc	ra,0xfffff
    80004bd6:	f5c080e7          	jalr	-164(ra) # 80003b2e <iunlock>
      end_op();
    80004bda:	00000097          	auipc	ra,0x0
    80004bde:	8e8080e7          	jalr	-1816(ra) # 800044c2 <end_op>

      if(r != n1){
    80004be2:	009c1f63          	bne	s8,s1,80004c00 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004be6:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004bea:	0149db63          	bge	s3,s4,80004c00 <filewrite+0xf6>
      int n1 = n - i;
    80004bee:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004bf2:	84be                	mv	s1,a5
    80004bf4:	2781                	sext.w	a5,a5
    80004bf6:	f8fb5ce3          	bge	s6,a5,80004b8e <filewrite+0x84>
    80004bfa:	84de                	mv	s1,s7
    80004bfc:	bf49                	j	80004b8e <filewrite+0x84>
    int i = 0;
    80004bfe:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004c00:	013a1f63          	bne	s4,s3,80004c1e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004c04:	8552                	mv	a0,s4
    80004c06:	60a6                	ld	ra,72(sp)
    80004c08:	6406                	ld	s0,64(sp)
    80004c0a:	74e2                	ld	s1,56(sp)
    80004c0c:	7942                	ld	s2,48(sp)
    80004c0e:	79a2                	ld	s3,40(sp)
    80004c10:	7a02                	ld	s4,32(sp)
    80004c12:	6ae2                	ld	s5,24(sp)
    80004c14:	6b42                	ld	s6,16(sp)
    80004c16:	6ba2                	ld	s7,8(sp)
    80004c18:	6c02                	ld	s8,0(sp)
    80004c1a:	6161                	addi	sp,sp,80
    80004c1c:	8082                	ret
    ret = (i == n ? n : -1);
    80004c1e:	5a7d                	li	s4,-1
    80004c20:	b7d5                	j	80004c04 <filewrite+0xfa>
    panic("filewrite");
    80004c22:	00004517          	auipc	a0,0x4
    80004c26:	ad650513          	addi	a0,a0,-1322 # 800086f8 <syscalls+0x280>
    80004c2a:	ffffc097          	auipc	ra,0xffffc
    80004c2e:	904080e7          	jalr	-1788(ra) # 8000052e <panic>
    return -1;
    80004c32:	5a7d                	li	s4,-1
    80004c34:	bfc1                	j	80004c04 <filewrite+0xfa>
      return -1;
    80004c36:	5a7d                	li	s4,-1
    80004c38:	b7f1                	j	80004c04 <filewrite+0xfa>
    80004c3a:	5a7d                	li	s4,-1
    80004c3c:	b7e1                	j	80004c04 <filewrite+0xfa>

0000000080004c3e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004c3e:	7179                	addi	sp,sp,-48
    80004c40:	f406                	sd	ra,40(sp)
    80004c42:	f022                	sd	s0,32(sp)
    80004c44:	ec26                	sd	s1,24(sp)
    80004c46:	e84a                	sd	s2,16(sp)
    80004c48:	e44e                	sd	s3,8(sp)
    80004c4a:	e052                	sd	s4,0(sp)
    80004c4c:	1800                	addi	s0,sp,48
    80004c4e:	84aa                	mv	s1,a0
    80004c50:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004c52:	0005b023          	sd	zero,0(a1)
    80004c56:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004c5a:	00000097          	auipc	ra,0x0
    80004c5e:	bf8080e7          	jalr	-1032(ra) # 80004852 <filealloc>
    80004c62:	e088                	sd	a0,0(s1)
    80004c64:	c551                	beqz	a0,80004cf0 <pipealloc+0xb2>
    80004c66:	00000097          	auipc	ra,0x0
    80004c6a:	bec080e7          	jalr	-1044(ra) # 80004852 <filealloc>
    80004c6e:	00aa3023          	sd	a0,0(s4)
    80004c72:	c92d                	beqz	a0,80004ce4 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004c74:	ffffc097          	auipc	ra,0xffffc
    80004c78:	e62080e7          	jalr	-414(ra) # 80000ad6 <kalloc>
    80004c7c:	892a                	mv	s2,a0
    80004c7e:	c125                	beqz	a0,80004cde <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004c80:	4985                	li	s3,1
    80004c82:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004c86:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004c8a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004c8e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004c92:	00004597          	auipc	a1,0x4
    80004c96:	a7658593          	addi	a1,a1,-1418 # 80008708 <syscalls+0x290>
    80004c9a:	ffffc097          	auipc	ra,0xffffc
    80004c9e:	e9c080e7          	jalr	-356(ra) # 80000b36 <initlock>
  (*f0)->type = FD_PIPE;
    80004ca2:	609c                	ld	a5,0(s1)
    80004ca4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004ca8:	609c                	ld	a5,0(s1)
    80004caa:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004cae:	609c                	ld	a5,0(s1)
    80004cb0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004cb4:	609c                	ld	a5,0(s1)
    80004cb6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004cba:	000a3783          	ld	a5,0(s4)
    80004cbe:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004cc2:	000a3783          	ld	a5,0(s4)
    80004cc6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004cca:	000a3783          	ld	a5,0(s4)
    80004cce:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004cd2:	000a3783          	ld	a5,0(s4)
    80004cd6:	0127b823          	sd	s2,16(a5)
  return 0;
    80004cda:	4501                	li	a0,0
    80004cdc:	a025                	j	80004d04 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004cde:	6088                	ld	a0,0(s1)
    80004ce0:	e501                	bnez	a0,80004ce8 <pipealloc+0xaa>
    80004ce2:	a039                	j	80004cf0 <pipealloc+0xb2>
    80004ce4:	6088                	ld	a0,0(s1)
    80004ce6:	c51d                	beqz	a0,80004d14 <pipealloc+0xd6>
    fileclose(*f0);
    80004ce8:	00000097          	auipc	ra,0x0
    80004cec:	c26080e7          	jalr	-986(ra) # 8000490e <fileclose>
  if(*f1)
    80004cf0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004cf4:	557d                	li	a0,-1
  if(*f1)
    80004cf6:	c799                	beqz	a5,80004d04 <pipealloc+0xc6>
    fileclose(*f1);
    80004cf8:	853e                	mv	a0,a5
    80004cfa:	00000097          	auipc	ra,0x0
    80004cfe:	c14080e7          	jalr	-1004(ra) # 8000490e <fileclose>
  return -1;
    80004d02:	557d                	li	a0,-1
}
    80004d04:	70a2                	ld	ra,40(sp)
    80004d06:	7402                	ld	s0,32(sp)
    80004d08:	64e2                	ld	s1,24(sp)
    80004d0a:	6942                	ld	s2,16(sp)
    80004d0c:	69a2                	ld	s3,8(sp)
    80004d0e:	6a02                	ld	s4,0(sp)
    80004d10:	6145                	addi	sp,sp,48
    80004d12:	8082                	ret
  return -1;
    80004d14:	557d                	li	a0,-1
    80004d16:	b7fd                	j	80004d04 <pipealloc+0xc6>

0000000080004d18 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004d18:	1101                	addi	sp,sp,-32
    80004d1a:	ec06                	sd	ra,24(sp)
    80004d1c:	e822                	sd	s0,16(sp)
    80004d1e:	e426                	sd	s1,8(sp)
    80004d20:	e04a                	sd	s2,0(sp)
    80004d22:	1000                	addi	s0,sp,32
    80004d24:	84aa                	mv	s1,a0
    80004d26:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004d28:	ffffc097          	auipc	ra,0xffffc
    80004d2c:	e9e080e7          	jalr	-354(ra) # 80000bc6 <acquire>
  if(writable){
    80004d30:	02090d63          	beqz	s2,80004d6a <pipeclose+0x52>
    pi->writeopen = 0;
    80004d34:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004d38:	21848513          	addi	a0,s1,536
    80004d3c:	ffffd097          	auipc	ra,0xffffd
    80004d40:	536080e7          	jalr	1334(ra) # 80002272 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004d44:	2204b783          	ld	a5,544(s1)
    80004d48:	eb95                	bnez	a5,80004d7c <pipeclose+0x64>
    release(&pi->lock);
    80004d4a:	8526                	mv	a0,s1
    80004d4c:	ffffc097          	auipc	ra,0xffffc
    80004d50:	f44080e7          	jalr	-188(ra) # 80000c90 <release>
    kfree((char*)pi);
    80004d54:	8526                	mv	a0,s1
    80004d56:	ffffc097          	auipc	ra,0xffffc
    80004d5a:	c84080e7          	jalr	-892(ra) # 800009da <kfree>
  } else
    release(&pi->lock);
}
    80004d5e:	60e2                	ld	ra,24(sp)
    80004d60:	6442                	ld	s0,16(sp)
    80004d62:	64a2                	ld	s1,8(sp)
    80004d64:	6902                	ld	s2,0(sp)
    80004d66:	6105                	addi	sp,sp,32
    80004d68:	8082                	ret
    pi->readopen = 0;
    80004d6a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004d6e:	21c48513          	addi	a0,s1,540
    80004d72:	ffffd097          	auipc	ra,0xffffd
    80004d76:	500080e7          	jalr	1280(ra) # 80002272 <wakeup>
    80004d7a:	b7e9                	j	80004d44 <pipeclose+0x2c>
    release(&pi->lock);
    80004d7c:	8526                	mv	a0,s1
    80004d7e:	ffffc097          	auipc	ra,0xffffc
    80004d82:	f12080e7          	jalr	-238(ra) # 80000c90 <release>
}
    80004d86:	bfe1                	j	80004d5e <pipeclose+0x46>

0000000080004d88 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004d88:	7159                	addi	sp,sp,-112
    80004d8a:	f486                	sd	ra,104(sp)
    80004d8c:	f0a2                	sd	s0,96(sp)
    80004d8e:	eca6                	sd	s1,88(sp)
    80004d90:	e8ca                	sd	s2,80(sp)
    80004d92:	e4ce                	sd	s3,72(sp)
    80004d94:	e0d2                	sd	s4,64(sp)
    80004d96:	fc56                	sd	s5,56(sp)
    80004d98:	f85a                	sd	s6,48(sp)
    80004d9a:	f45e                	sd	s7,40(sp)
    80004d9c:	f062                	sd	s8,32(sp)
    80004d9e:	ec66                	sd	s9,24(sp)
    80004da0:	1880                	addi	s0,sp,112
    80004da2:	84aa                	mv	s1,a0
    80004da4:	8b2e                	mv	s6,a1
    80004da6:	8ab2                	mv	s5,a2
  int i = 0;
  struct proc *pr = myproc();
    80004da8:	ffffd097          	auipc	ra,0xffffd
    80004dac:	bf0080e7          	jalr	-1040(ra) # 80001998 <myproc>
    80004db0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004db2:	8526                	mv	a0,s1
    80004db4:	ffffc097          	auipc	ra,0xffffc
    80004db8:	e12080e7          	jalr	-494(ra) # 80000bc6 <acquire>
  while(i < n){
    80004dbc:	0b505663          	blez	s5,80004e68 <pipewrite+0xe0>
  int i = 0;
    80004dc0:	4901                	li	s2,0
    if(pi->readopen == 0 || pr->killed==1){
    80004dc2:	4a05                	li	s4,1
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004dc4:	5bfd                	li	s7,-1
      wakeup(&pi->nread);
    80004dc6:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004dca:	21c48c13          	addi	s8,s1,540
    80004dce:	a091                	j	80004e12 <pipewrite+0x8a>
      release(&pi->lock);
    80004dd0:	8526                	mv	a0,s1
    80004dd2:	ffffc097          	auipc	ra,0xffffc
    80004dd6:	ebe080e7          	jalr	-322(ra) # 80000c90 <release>
      return -1;
    80004dda:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ddc:	854a                	mv	a0,s2
    80004dde:	70a6                	ld	ra,104(sp)
    80004de0:	7406                	ld	s0,96(sp)
    80004de2:	64e6                	ld	s1,88(sp)
    80004de4:	6946                	ld	s2,80(sp)
    80004de6:	69a6                	ld	s3,72(sp)
    80004de8:	6a06                	ld	s4,64(sp)
    80004dea:	7ae2                	ld	s5,56(sp)
    80004dec:	7b42                	ld	s6,48(sp)
    80004dee:	7ba2                	ld	s7,40(sp)
    80004df0:	7c02                	ld	s8,32(sp)
    80004df2:	6ce2                	ld	s9,24(sp)
    80004df4:	6165                	addi	sp,sp,112
    80004df6:	8082                	ret
      wakeup(&pi->nread);
    80004df8:	8566                	mv	a0,s9
    80004dfa:	ffffd097          	auipc	ra,0xffffd
    80004dfe:	478080e7          	jalr	1144(ra) # 80002272 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004e02:	85a6                	mv	a1,s1
    80004e04:	8562                	mv	a0,s8
    80004e06:	ffffd097          	auipc	ra,0xffffd
    80004e0a:	2de080e7          	jalr	734(ra) # 800020e4 <sleep>
  while(i < n){
    80004e0e:	05595e63          	bge	s2,s5,80004e6a <pipewrite+0xe2>
    if(pi->readopen == 0 || pr->killed==1){
    80004e12:	2204a783          	lw	a5,544(s1)
    80004e16:	dfcd                	beqz	a5,80004dd0 <pipewrite+0x48>
    80004e18:	0289a783          	lw	a5,40(s3)
    80004e1c:	fb478ae3          	beq	a5,s4,80004dd0 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004e20:	2184a783          	lw	a5,536(s1)
    80004e24:	21c4a703          	lw	a4,540(s1)
    80004e28:	2007879b          	addiw	a5,a5,512
    80004e2c:	fcf706e3          	beq	a4,a5,80004df8 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e30:	86d2                	mv	a3,s4
    80004e32:	01690633          	add	a2,s2,s6
    80004e36:	f9f40593          	addi	a1,s0,-97
    80004e3a:	0509b503          	ld	a0,80(s3)
    80004e3e:	ffffd097          	auipc	ra,0xffffd
    80004e42:	8a6080e7          	jalr	-1882(ra) # 800016e4 <copyin>
    80004e46:	03750263          	beq	a0,s7,80004e6a <pipewrite+0xe2>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004e4a:	21c4a783          	lw	a5,540(s1)
    80004e4e:	0017871b          	addiw	a4,a5,1
    80004e52:	20e4ae23          	sw	a4,540(s1)
    80004e56:	1ff7f793          	andi	a5,a5,511
    80004e5a:	97a6                	add	a5,a5,s1
    80004e5c:	f9f44703          	lbu	a4,-97(s0)
    80004e60:	00e78c23          	sb	a4,24(a5)
      i++;
    80004e64:	2905                	addiw	s2,s2,1
    80004e66:	b765                	j	80004e0e <pipewrite+0x86>
  int i = 0;
    80004e68:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004e6a:	21848513          	addi	a0,s1,536
    80004e6e:	ffffd097          	auipc	ra,0xffffd
    80004e72:	404080e7          	jalr	1028(ra) # 80002272 <wakeup>
  release(&pi->lock);
    80004e76:	8526                	mv	a0,s1
    80004e78:	ffffc097          	auipc	ra,0xffffc
    80004e7c:	e18080e7          	jalr	-488(ra) # 80000c90 <release>
  return i;
    80004e80:	bfb1                	j	80004ddc <pipewrite+0x54>

0000000080004e82 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004e82:	715d                	addi	sp,sp,-80
    80004e84:	e486                	sd	ra,72(sp)
    80004e86:	e0a2                	sd	s0,64(sp)
    80004e88:	fc26                	sd	s1,56(sp)
    80004e8a:	f84a                	sd	s2,48(sp)
    80004e8c:	f44e                	sd	s3,40(sp)
    80004e8e:	f052                	sd	s4,32(sp)
    80004e90:	ec56                	sd	s5,24(sp)
    80004e92:	e85a                	sd	s6,16(sp)
    80004e94:	0880                	addi	s0,sp,80
    80004e96:	84aa                	mv	s1,a0
    80004e98:	892e                	mv	s2,a1
    80004e9a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e9c:	ffffd097          	auipc	ra,0xffffd
    80004ea0:	afc080e7          	jalr	-1284(ra) # 80001998 <myproc>
    80004ea4:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ea6:	8526                	mv	a0,s1
    80004ea8:	ffffc097          	auipc	ra,0xffffc
    80004eac:	d1e080e7          	jalr	-738(ra) # 80000bc6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004eb0:	2184a703          	lw	a4,536(s1)
    80004eb4:	21c4a783          	lw	a5,540(s1)
    if(pr->killed==1){
    80004eb8:	4985                	li	s3,1
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004eba:	21848b13          	addi	s6,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ebe:	02f71563          	bne	a4,a5,80004ee8 <piperead+0x66>
    80004ec2:	2244a783          	lw	a5,548(s1)
    80004ec6:	c38d                	beqz	a5,80004ee8 <piperead+0x66>
    if(pr->killed==1){
    80004ec8:	028a2783          	lw	a5,40(s4)
    80004ecc:	09378963          	beq	a5,s3,80004f5e <piperead+0xdc>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ed0:	85a6                	mv	a1,s1
    80004ed2:	855a                	mv	a0,s6
    80004ed4:	ffffd097          	auipc	ra,0xffffd
    80004ed8:	210080e7          	jalr	528(ra) # 800020e4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004edc:	2184a703          	lw	a4,536(s1)
    80004ee0:	21c4a783          	lw	a5,540(s1)
    80004ee4:	fcf70fe3          	beq	a4,a5,80004ec2 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ee8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004eea:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004eec:	05505363          	blez	s5,80004f32 <piperead+0xb0>
    if(pi->nread == pi->nwrite)
    80004ef0:	2184a783          	lw	a5,536(s1)
    80004ef4:	21c4a703          	lw	a4,540(s1)
    80004ef8:	02f70d63          	beq	a4,a5,80004f32 <piperead+0xb0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004efc:	0017871b          	addiw	a4,a5,1
    80004f00:	20e4ac23          	sw	a4,536(s1)
    80004f04:	1ff7f793          	andi	a5,a5,511
    80004f08:	97a6                	add	a5,a5,s1
    80004f0a:	0187c783          	lbu	a5,24(a5)
    80004f0e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f12:	4685                	li	a3,1
    80004f14:	fbf40613          	addi	a2,s0,-65
    80004f18:	85ca                	mv	a1,s2
    80004f1a:	050a3503          	ld	a0,80(s4)
    80004f1e:	ffffc097          	auipc	ra,0xffffc
    80004f22:	73a080e7          	jalr	1850(ra) # 80001658 <copyout>
    80004f26:	01650663          	beq	a0,s6,80004f32 <piperead+0xb0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f2a:	2985                	addiw	s3,s3,1
    80004f2c:	0905                	addi	s2,s2,1
    80004f2e:	fd3a91e3          	bne	s5,s3,80004ef0 <piperead+0x6e>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004f32:	21c48513          	addi	a0,s1,540
    80004f36:	ffffd097          	auipc	ra,0xffffd
    80004f3a:	33c080e7          	jalr	828(ra) # 80002272 <wakeup>
  release(&pi->lock);
    80004f3e:	8526                	mv	a0,s1
    80004f40:	ffffc097          	auipc	ra,0xffffc
    80004f44:	d50080e7          	jalr	-688(ra) # 80000c90 <release>
  return i;
}
    80004f48:	854e                	mv	a0,s3
    80004f4a:	60a6                	ld	ra,72(sp)
    80004f4c:	6406                	ld	s0,64(sp)
    80004f4e:	74e2                	ld	s1,56(sp)
    80004f50:	7942                	ld	s2,48(sp)
    80004f52:	79a2                	ld	s3,40(sp)
    80004f54:	7a02                	ld	s4,32(sp)
    80004f56:	6ae2                	ld	s5,24(sp)
    80004f58:	6b42                	ld	s6,16(sp)
    80004f5a:	6161                	addi	sp,sp,80
    80004f5c:	8082                	ret
      release(&pi->lock);
    80004f5e:	8526                	mv	a0,s1
    80004f60:	ffffc097          	auipc	ra,0xffffc
    80004f64:	d30080e7          	jalr	-720(ra) # 80000c90 <release>
      return -1;
    80004f68:	59fd                	li	s3,-1
    80004f6a:	bff9                	j	80004f48 <piperead+0xc6>

0000000080004f6c <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004f6c:	de010113          	addi	sp,sp,-544
    80004f70:	20113c23          	sd	ra,536(sp)
    80004f74:	20813823          	sd	s0,528(sp)
    80004f78:	20913423          	sd	s1,520(sp)
    80004f7c:	21213023          	sd	s2,512(sp)
    80004f80:	ffce                	sd	s3,504(sp)
    80004f82:	fbd2                	sd	s4,496(sp)
    80004f84:	f7d6                	sd	s5,488(sp)
    80004f86:	f3da                	sd	s6,480(sp)
    80004f88:	efde                	sd	s7,472(sp)
    80004f8a:	ebe2                	sd	s8,464(sp)
    80004f8c:	e7e6                	sd	s9,456(sp)
    80004f8e:	e3ea                	sd	s10,448(sp)
    80004f90:	ff6e                	sd	s11,440(sp)
    80004f92:	1400                	addi	s0,sp,544
    80004f94:	892a                	mv	s2,a0
    80004f96:	dea43423          	sd	a0,-536(s0)
    80004f9a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f9e:	ffffd097          	auipc	ra,0xffffd
    80004fa2:	9fa080e7          	jalr	-1542(ra) # 80001998 <myproc>
    80004fa6:	84aa                	mv	s1,a0

  begin_op();
    80004fa8:	fffff097          	auipc	ra,0xfffff
    80004fac:	49a080e7          	jalr	1178(ra) # 80004442 <begin_op>

  if((ip = namei(path)) == 0){
    80004fb0:	854a                	mv	a0,s2
    80004fb2:	fffff097          	auipc	ra,0xfffff
    80004fb6:	270080e7          	jalr	624(ra) # 80004222 <namei>
    80004fba:	c93d                	beqz	a0,80005030 <exec+0xc4>
    80004fbc:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004fbe:	fffff097          	auipc	ra,0xfffff
    80004fc2:	aae080e7          	jalr	-1362(ra) # 80003a6c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004fc6:	04000713          	li	a4,64
    80004fca:	4681                	li	a3,0
    80004fcc:	e4840613          	addi	a2,s0,-440
    80004fd0:	4581                	li	a1,0
    80004fd2:	8556                	mv	a0,s5
    80004fd4:	fffff097          	auipc	ra,0xfffff
    80004fd8:	d4c080e7          	jalr	-692(ra) # 80003d20 <readi>
    80004fdc:	04000793          	li	a5,64
    80004fe0:	00f51a63          	bne	a0,a5,80004ff4 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004fe4:	e4842703          	lw	a4,-440(s0)
    80004fe8:	464c47b7          	lui	a5,0x464c4
    80004fec:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004ff0:	04f70663          	beq	a4,a5,8000503c <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004ff4:	8556                	mv	a0,s5
    80004ff6:	fffff097          	auipc	ra,0xfffff
    80004ffa:	cd8080e7          	jalr	-808(ra) # 80003cce <iunlockput>
    end_op();
    80004ffe:	fffff097          	auipc	ra,0xfffff
    80005002:	4c4080e7          	jalr	1220(ra) # 800044c2 <end_op>
  }
  return -1;
    80005006:	557d                	li	a0,-1
}
    80005008:	21813083          	ld	ra,536(sp)
    8000500c:	21013403          	ld	s0,528(sp)
    80005010:	20813483          	ld	s1,520(sp)
    80005014:	20013903          	ld	s2,512(sp)
    80005018:	79fe                	ld	s3,504(sp)
    8000501a:	7a5e                	ld	s4,496(sp)
    8000501c:	7abe                	ld	s5,488(sp)
    8000501e:	7b1e                	ld	s6,480(sp)
    80005020:	6bfe                	ld	s7,472(sp)
    80005022:	6c5e                	ld	s8,464(sp)
    80005024:	6cbe                	ld	s9,456(sp)
    80005026:	6d1e                	ld	s10,448(sp)
    80005028:	7dfa                	ld	s11,440(sp)
    8000502a:	22010113          	addi	sp,sp,544
    8000502e:	8082                	ret
    end_op();
    80005030:	fffff097          	auipc	ra,0xfffff
    80005034:	492080e7          	jalr	1170(ra) # 800044c2 <end_op>
    return -1;
    80005038:	557d                	li	a0,-1
    8000503a:	b7f9                	j	80005008 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000503c:	8526                	mv	a0,s1
    8000503e:	ffffd097          	auipc	ra,0xffffd
    80005042:	a1e080e7          	jalr	-1506(ra) # 80001a5c <proc_pagetable>
    80005046:	8b2a                	mv	s6,a0
    80005048:	d555                	beqz	a0,80004ff4 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000504a:	e6842783          	lw	a5,-408(s0)
    8000504e:	e8045703          	lhu	a4,-384(s0)
    80005052:	c735                	beqz	a4,800050be <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80005054:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005056:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000505a:	6a05                	lui	s4,0x1
    8000505c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005060:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80005064:	6d85                	lui	s11,0x1
    80005066:	7d7d                	lui	s10,0xfffff
    80005068:	aca1                	j	800052c0 <exec+0x354>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000506a:	00003517          	auipc	a0,0x3
    8000506e:	6a650513          	addi	a0,a0,1702 # 80008710 <syscalls+0x298>
    80005072:	ffffb097          	auipc	ra,0xffffb
    80005076:	4bc080e7          	jalr	1212(ra) # 8000052e <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000507a:	874a                	mv	a4,s2
    8000507c:	009c86bb          	addw	a3,s9,s1
    80005080:	4581                	li	a1,0
    80005082:	8556                	mv	a0,s5
    80005084:	fffff097          	auipc	ra,0xfffff
    80005088:	c9c080e7          	jalr	-868(ra) # 80003d20 <readi>
    8000508c:	2501                	sext.w	a0,a0
    8000508e:	1ca91963          	bne	s2,a0,80005260 <exec+0x2f4>
  for(i = 0; i < sz; i += PGSIZE){
    80005092:	009d84bb          	addw	s1,s11,s1
    80005096:	013d09bb          	addw	s3,s10,s3
    8000509a:	2174f363          	bgeu	s1,s7,800052a0 <exec+0x334>
    pa = walkaddr(pagetable, va + i);
    8000509e:	02049593          	slli	a1,s1,0x20
    800050a2:	9181                	srli	a1,a1,0x20
    800050a4:	95e2                	add	a1,a1,s8
    800050a6:	855a                	mv	a0,s6
    800050a8:	ffffc097          	auipc	ra,0xffffc
    800050ac:	fbe080e7          	jalr	-66(ra) # 80001066 <walkaddr>
    800050b0:	862a                	mv	a2,a0
    if(pa == 0)
    800050b2:	dd45                	beqz	a0,8000506a <exec+0xfe>
      n = PGSIZE;
    800050b4:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800050b6:	fd49f2e3          	bgeu	s3,s4,8000507a <exec+0x10e>
      n = sz - i;
    800050ba:	894e                	mv	s2,s3
    800050bc:	bf7d                	j	8000507a <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800050be:	4481                	li	s1,0
  iunlockput(ip);
    800050c0:	8556                	mv	a0,s5
    800050c2:	fffff097          	auipc	ra,0xfffff
    800050c6:	c0c080e7          	jalr	-1012(ra) # 80003cce <iunlockput>
  end_op();
    800050ca:	fffff097          	auipc	ra,0xfffff
    800050ce:	3f8080e7          	jalr	1016(ra) # 800044c2 <end_op>
  p = myproc();
    800050d2:	ffffd097          	auipc	ra,0xffffd
    800050d6:	8c6080e7          	jalr	-1850(ra) # 80001998 <myproc>
    800050da:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800050dc:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800050e0:	6785                	lui	a5,0x1
    800050e2:	17fd                	addi	a5,a5,-1
    800050e4:	94be                	add	s1,s1,a5
    800050e6:	77fd                	lui	a5,0xfffff
    800050e8:	8fe5                	and	a5,a5,s1
    800050ea:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800050ee:	6609                	lui	a2,0x2
    800050f0:	963e                	add	a2,a2,a5
    800050f2:	85be                	mv	a1,a5
    800050f4:	855a                	mv	a0,s6
    800050f6:	ffffc097          	auipc	ra,0xffffc
    800050fa:	312080e7          	jalr	786(ra) # 80001408 <uvmalloc>
    800050fe:	8c2a                	mv	s8,a0
  ip = 0;
    80005100:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005102:	14050f63          	beqz	a0,80005260 <exec+0x2f4>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005106:	75f9                	lui	a1,0xffffe
    80005108:	95aa                	add	a1,a1,a0
    8000510a:	855a                	mv	a0,s6
    8000510c:	ffffc097          	auipc	ra,0xffffc
    80005110:	51a080e7          	jalr	1306(ra) # 80001626 <uvmclear>
  stackbase = sp - PGSIZE;
    80005114:	7afd                	lui	s5,0xfffff
    80005116:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005118:	df043783          	ld	a5,-528(s0)
    8000511c:	6388                	ld	a0,0(a5)
    8000511e:	c925                	beqz	a0,8000518e <exec+0x222>
    80005120:	e8840993          	addi	s3,s0,-376
    80005124:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80005128:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000512a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000512c:	ffffc097          	auipc	ra,0xffffc
    80005130:	d30080e7          	jalr	-720(ra) # 80000e5c <strlen>
    80005134:	0015079b          	addiw	a5,a0,1
    80005138:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000513c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80005140:	15596463          	bltu	s2,s5,80005288 <exec+0x31c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005144:	df043d83          	ld	s11,-528(s0)
    80005148:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000514c:	8552                	mv	a0,s4
    8000514e:	ffffc097          	auipc	ra,0xffffc
    80005152:	d0e080e7          	jalr	-754(ra) # 80000e5c <strlen>
    80005156:	0015069b          	addiw	a3,a0,1
    8000515a:	8652                	mv	a2,s4
    8000515c:	85ca                	mv	a1,s2
    8000515e:	855a                	mv	a0,s6
    80005160:	ffffc097          	auipc	ra,0xffffc
    80005164:	4f8080e7          	jalr	1272(ra) # 80001658 <copyout>
    80005168:	12054463          	bltz	a0,80005290 <exec+0x324>
    ustack[argc] = sp;
    8000516c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005170:	0485                	addi	s1,s1,1
    80005172:	008d8793          	addi	a5,s11,8
    80005176:	def43823          	sd	a5,-528(s0)
    8000517a:	008db503          	ld	a0,8(s11)
    8000517e:	c911                	beqz	a0,80005192 <exec+0x226>
    if(argc >= MAXARG)
    80005180:	09a1                	addi	s3,s3,8
    80005182:	fb9995e3          	bne	s3,s9,8000512c <exec+0x1c0>
  sz = sz1;
    80005186:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000518a:	4a81                	li	s5,0
    8000518c:	a8d1                	j	80005260 <exec+0x2f4>
  sp = sz;
    8000518e:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005190:	4481                	li	s1,0
  ustack[argc] = 0;
    80005192:	00349793          	slli	a5,s1,0x3
    80005196:	f9040713          	addi	a4,s0,-112
    8000519a:	97ba                	add	a5,a5,a4
    8000519c:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd0ef8>
  sp -= (argc+1) * sizeof(uint64);
    800051a0:	00148693          	addi	a3,s1,1
    800051a4:	068e                	slli	a3,a3,0x3
    800051a6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800051aa:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800051ae:	01597663          	bgeu	s2,s5,800051ba <exec+0x24e>
  sz = sz1;
    800051b2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800051b6:	4a81                	li	s5,0
    800051b8:	a065                	j	80005260 <exec+0x2f4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800051ba:	e8840613          	addi	a2,s0,-376
    800051be:	85ca                	mv	a1,s2
    800051c0:	855a                	mv	a0,s6
    800051c2:	ffffc097          	auipc	ra,0xffffc
    800051c6:	496080e7          	jalr	1174(ra) # 80001658 <copyout>
    800051ca:	0c054763          	bltz	a0,80005298 <exec+0x32c>
  p->trapframe->a1 = sp;
    800051ce:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    800051d2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800051d6:	de843783          	ld	a5,-536(s0)
    800051da:	0007c703          	lbu	a4,0(a5)
    800051de:	cf11                	beqz	a4,800051fa <exec+0x28e>
    800051e0:	0785                	addi	a5,a5,1
    if(*s == '/')
    800051e2:	02f00693          	li	a3,47
    800051e6:	a039                	j	800051f4 <exec+0x288>
      last = s+1;
    800051e8:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800051ec:	0785                	addi	a5,a5,1
    800051ee:	fff7c703          	lbu	a4,-1(a5)
    800051f2:	c701                	beqz	a4,800051fa <exec+0x28e>
    if(*s == '/')
    800051f4:	fed71ce3          	bne	a4,a3,800051ec <exec+0x280>
    800051f8:	bfc5                	j	800051e8 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    800051fa:	4641                	li	a2,16
    800051fc:	de843583          	ld	a1,-536(s0)
    80005200:	158b8513          	addi	a0,s7,344
    80005204:	ffffc097          	auipc	ra,0xffffc
    80005208:	c26080e7          	jalr	-986(ra) # 80000e2a <safestrcpy>
  for(int i=0; i<32; i++){
    8000520c:	170b8793          	addi	a5,s7,368
    80005210:	370b8613          	addi	a2,s7,880
    if(!((p->signal_handlers[i].sa_handler) == (void*)SIG_IGN)){
    80005214:	4685                	li	a3,1
    80005216:	a801                	j	80005226 <exec+0x2ba>
        p->signal_handlers[i].sa_handler=SIG_DFL;
    80005218:	0007b023          	sd	zero,0(a5)
        p->signal_handlers[i].sigmask=0;   
    8000521c:	0007a423          	sw	zero,8(a5)
  for(int i=0; i<32; i++){
    80005220:	07c1                	addi	a5,a5,16
    80005222:	00c78663          	beq	a5,a2,8000522e <exec+0x2c2>
    if(!((p->signal_handlers[i].sa_handler) == (void*)SIG_IGN)){
    80005226:	6398                	ld	a4,0(a5)
    80005228:	fed718e3          	bne	a4,a3,80005218 <exec+0x2ac>
    8000522c:	bfd5                	j	80005220 <exec+0x2b4>
  oldpagetable = p->pagetable;
    8000522e:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80005232:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80005236:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000523a:	058bb783          	ld	a5,88(s7)
    8000523e:	e6043703          	ld	a4,-416(s0)
    80005242:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005244:	058bb783          	ld	a5,88(s7)
    80005248:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000524c:	85ea                	mv	a1,s10
    8000524e:	ffffd097          	auipc	ra,0xffffd
    80005252:	8aa080e7          	jalr	-1878(ra) # 80001af8 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005256:	0004851b          	sext.w	a0,s1
    8000525a:	b37d                	j	80005008 <exec+0x9c>
    8000525c:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005260:	df843583          	ld	a1,-520(s0)
    80005264:	855a                	mv	a0,s6
    80005266:	ffffd097          	auipc	ra,0xffffd
    8000526a:	892080e7          	jalr	-1902(ra) # 80001af8 <proc_freepagetable>
  if(ip){
    8000526e:	d80a93e3          	bnez	s5,80004ff4 <exec+0x88>
  return -1;
    80005272:	557d                	li	a0,-1
    80005274:	bb51                	j	80005008 <exec+0x9c>
    80005276:	de943c23          	sd	s1,-520(s0)
    8000527a:	b7dd                	j	80005260 <exec+0x2f4>
    8000527c:	de943c23          	sd	s1,-520(s0)
    80005280:	b7c5                	j	80005260 <exec+0x2f4>
    80005282:	de943c23          	sd	s1,-520(s0)
    80005286:	bfe9                	j	80005260 <exec+0x2f4>
  sz = sz1;
    80005288:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000528c:	4a81                	li	s5,0
    8000528e:	bfc9                	j	80005260 <exec+0x2f4>
  sz = sz1;
    80005290:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005294:	4a81                	li	s5,0
    80005296:	b7e9                	j	80005260 <exec+0x2f4>
  sz = sz1;
    80005298:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000529c:	4a81                	li	s5,0
    8000529e:	b7c9                	j	80005260 <exec+0x2f4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800052a0:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052a4:	e0843783          	ld	a5,-504(s0)
    800052a8:	0017869b          	addiw	a3,a5,1
    800052ac:	e0d43423          	sd	a3,-504(s0)
    800052b0:	e0043783          	ld	a5,-512(s0)
    800052b4:	0387879b          	addiw	a5,a5,56
    800052b8:	e8045703          	lhu	a4,-384(s0)
    800052bc:	e0e6d2e3          	bge	a3,a4,800050c0 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800052c0:	2781                	sext.w	a5,a5
    800052c2:	e0f43023          	sd	a5,-512(s0)
    800052c6:	03800713          	li	a4,56
    800052ca:	86be                	mv	a3,a5
    800052cc:	e1040613          	addi	a2,s0,-496
    800052d0:	4581                	li	a1,0
    800052d2:	8556                	mv	a0,s5
    800052d4:	fffff097          	auipc	ra,0xfffff
    800052d8:	a4c080e7          	jalr	-1460(ra) # 80003d20 <readi>
    800052dc:	03800793          	li	a5,56
    800052e0:	f6f51ee3          	bne	a0,a5,8000525c <exec+0x2f0>
    if(ph.type != ELF_PROG_LOAD)
    800052e4:	e1042783          	lw	a5,-496(s0)
    800052e8:	4705                	li	a4,1
    800052ea:	fae79de3          	bne	a5,a4,800052a4 <exec+0x338>
    if(ph.memsz < ph.filesz)
    800052ee:	e3843603          	ld	a2,-456(s0)
    800052f2:	e3043783          	ld	a5,-464(s0)
    800052f6:	f8f660e3          	bltu	a2,a5,80005276 <exec+0x30a>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800052fa:	e2043783          	ld	a5,-480(s0)
    800052fe:	963e                	add	a2,a2,a5
    80005300:	f6f66ee3          	bltu	a2,a5,8000527c <exec+0x310>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005304:	85a6                	mv	a1,s1
    80005306:	855a                	mv	a0,s6
    80005308:	ffffc097          	auipc	ra,0xffffc
    8000530c:	100080e7          	jalr	256(ra) # 80001408 <uvmalloc>
    80005310:	dea43c23          	sd	a0,-520(s0)
    80005314:	d53d                	beqz	a0,80005282 <exec+0x316>
    if(ph.vaddr % PGSIZE != 0)
    80005316:	e2043c03          	ld	s8,-480(s0)
    8000531a:	de043783          	ld	a5,-544(s0)
    8000531e:	00fc77b3          	and	a5,s8,a5
    80005322:	ff9d                	bnez	a5,80005260 <exec+0x2f4>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005324:	e1842c83          	lw	s9,-488(s0)
    80005328:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000532c:	f60b8ae3          	beqz	s7,800052a0 <exec+0x334>
    80005330:	89de                	mv	s3,s7
    80005332:	4481                	li	s1,0
    80005334:	b3ad                	j	8000509e <exec+0x132>

0000000080005336 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005336:	7179                	addi	sp,sp,-48
    80005338:	f406                	sd	ra,40(sp)
    8000533a:	f022                	sd	s0,32(sp)
    8000533c:	ec26                	sd	s1,24(sp)
    8000533e:	e84a                	sd	s2,16(sp)
    80005340:	1800                	addi	s0,sp,48
    80005342:	892e                	mv	s2,a1
    80005344:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005346:	fdc40593          	addi	a1,s0,-36
    8000534a:	ffffe097          	auipc	ra,0xffffe
    8000534e:	ace080e7          	jalr	-1330(ra) # 80002e18 <argint>
    80005352:	04054063          	bltz	a0,80005392 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005356:	fdc42703          	lw	a4,-36(s0)
    8000535a:	47bd                	li	a5,15
    8000535c:	02e7ed63          	bltu	a5,a4,80005396 <argfd+0x60>
    80005360:	ffffc097          	auipc	ra,0xffffc
    80005364:	638080e7          	jalr	1592(ra) # 80001998 <myproc>
    80005368:	fdc42703          	lw	a4,-36(s0)
    8000536c:	01a70793          	addi	a5,a4,26
    80005370:	078e                	slli	a5,a5,0x3
    80005372:	953e                	add	a0,a0,a5
    80005374:	611c                	ld	a5,0(a0)
    80005376:	c395                	beqz	a5,8000539a <argfd+0x64>
    return -1;
  if(pfd)
    80005378:	00090463          	beqz	s2,80005380 <argfd+0x4a>
    *pfd = fd;
    8000537c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005380:	4501                	li	a0,0
  if(pf)
    80005382:	c091                	beqz	s1,80005386 <argfd+0x50>
    *pf = f;
    80005384:	e09c                	sd	a5,0(s1)
}
    80005386:	70a2                	ld	ra,40(sp)
    80005388:	7402                	ld	s0,32(sp)
    8000538a:	64e2                	ld	s1,24(sp)
    8000538c:	6942                	ld	s2,16(sp)
    8000538e:	6145                	addi	sp,sp,48
    80005390:	8082                	ret
    return -1;
    80005392:	557d                	li	a0,-1
    80005394:	bfcd                	j	80005386 <argfd+0x50>
    return -1;
    80005396:	557d                	li	a0,-1
    80005398:	b7fd                	j	80005386 <argfd+0x50>
    8000539a:	557d                	li	a0,-1
    8000539c:	b7ed                	j	80005386 <argfd+0x50>

000000008000539e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000539e:	1101                	addi	sp,sp,-32
    800053a0:	ec06                	sd	ra,24(sp)
    800053a2:	e822                	sd	s0,16(sp)
    800053a4:	e426                	sd	s1,8(sp)
    800053a6:	1000                	addi	s0,sp,32
    800053a8:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800053aa:	ffffc097          	auipc	ra,0xffffc
    800053ae:	5ee080e7          	jalr	1518(ra) # 80001998 <myproc>
    800053b2:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800053b4:	0d050793          	addi	a5,a0,208
    800053b8:	4501                	li	a0,0
    800053ba:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800053bc:	6398                	ld	a4,0(a5)
    800053be:	cb19                	beqz	a4,800053d4 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800053c0:	2505                	addiw	a0,a0,1
    800053c2:	07a1                	addi	a5,a5,8
    800053c4:	fed51ce3          	bne	a0,a3,800053bc <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800053c8:	557d                	li	a0,-1
}
    800053ca:	60e2                	ld	ra,24(sp)
    800053cc:	6442                	ld	s0,16(sp)
    800053ce:	64a2                	ld	s1,8(sp)
    800053d0:	6105                	addi	sp,sp,32
    800053d2:	8082                	ret
      p->ofile[fd] = f;
    800053d4:	01a50793          	addi	a5,a0,26
    800053d8:	078e                	slli	a5,a5,0x3
    800053da:	963e                	add	a2,a2,a5
    800053dc:	e204                	sd	s1,0(a2)
      return fd;
    800053de:	b7f5                	j	800053ca <fdalloc+0x2c>

00000000800053e0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800053e0:	715d                	addi	sp,sp,-80
    800053e2:	e486                	sd	ra,72(sp)
    800053e4:	e0a2                	sd	s0,64(sp)
    800053e6:	fc26                	sd	s1,56(sp)
    800053e8:	f84a                	sd	s2,48(sp)
    800053ea:	f44e                	sd	s3,40(sp)
    800053ec:	f052                	sd	s4,32(sp)
    800053ee:	ec56                	sd	s5,24(sp)
    800053f0:	0880                	addi	s0,sp,80
    800053f2:	89ae                	mv	s3,a1
    800053f4:	8ab2                	mv	s5,a2
    800053f6:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800053f8:	fb040593          	addi	a1,s0,-80
    800053fc:	fffff097          	auipc	ra,0xfffff
    80005400:	e44080e7          	jalr	-444(ra) # 80004240 <nameiparent>
    80005404:	892a                	mv	s2,a0
    80005406:	12050e63          	beqz	a0,80005542 <create+0x162>
    return 0;

  ilock(dp);
    8000540a:	ffffe097          	auipc	ra,0xffffe
    8000540e:	662080e7          	jalr	1634(ra) # 80003a6c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005412:	4601                	li	a2,0
    80005414:	fb040593          	addi	a1,s0,-80
    80005418:	854a                	mv	a0,s2
    8000541a:	fffff097          	auipc	ra,0xfffff
    8000541e:	b36080e7          	jalr	-1226(ra) # 80003f50 <dirlookup>
    80005422:	84aa                	mv	s1,a0
    80005424:	c921                	beqz	a0,80005474 <create+0x94>
    iunlockput(dp);
    80005426:	854a                	mv	a0,s2
    80005428:	fffff097          	auipc	ra,0xfffff
    8000542c:	8a6080e7          	jalr	-1882(ra) # 80003cce <iunlockput>
    ilock(ip);
    80005430:	8526                	mv	a0,s1
    80005432:	ffffe097          	auipc	ra,0xffffe
    80005436:	63a080e7          	jalr	1594(ra) # 80003a6c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000543a:	2981                	sext.w	s3,s3
    8000543c:	4789                	li	a5,2
    8000543e:	02f99463          	bne	s3,a5,80005466 <create+0x86>
    80005442:	0444d783          	lhu	a5,68(s1)
    80005446:	37f9                	addiw	a5,a5,-2
    80005448:	17c2                	slli	a5,a5,0x30
    8000544a:	93c1                	srli	a5,a5,0x30
    8000544c:	4705                	li	a4,1
    8000544e:	00f76c63          	bltu	a4,a5,80005466 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005452:	8526                	mv	a0,s1
    80005454:	60a6                	ld	ra,72(sp)
    80005456:	6406                	ld	s0,64(sp)
    80005458:	74e2                	ld	s1,56(sp)
    8000545a:	7942                	ld	s2,48(sp)
    8000545c:	79a2                	ld	s3,40(sp)
    8000545e:	7a02                	ld	s4,32(sp)
    80005460:	6ae2                	ld	s5,24(sp)
    80005462:	6161                	addi	sp,sp,80
    80005464:	8082                	ret
    iunlockput(ip);
    80005466:	8526                	mv	a0,s1
    80005468:	fffff097          	auipc	ra,0xfffff
    8000546c:	866080e7          	jalr	-1946(ra) # 80003cce <iunlockput>
    return 0;
    80005470:	4481                	li	s1,0
    80005472:	b7c5                	j	80005452 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005474:	85ce                	mv	a1,s3
    80005476:	00092503          	lw	a0,0(s2)
    8000547a:	ffffe097          	auipc	ra,0xffffe
    8000547e:	45a080e7          	jalr	1114(ra) # 800038d4 <ialloc>
    80005482:	84aa                	mv	s1,a0
    80005484:	c521                	beqz	a0,800054cc <create+0xec>
  ilock(ip);
    80005486:	ffffe097          	auipc	ra,0xffffe
    8000548a:	5e6080e7          	jalr	1510(ra) # 80003a6c <ilock>
  ip->major = major;
    8000548e:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005492:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005496:	4a05                	li	s4,1
    80005498:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    8000549c:	8526                	mv	a0,s1
    8000549e:	ffffe097          	auipc	ra,0xffffe
    800054a2:	504080e7          	jalr	1284(ra) # 800039a2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800054a6:	2981                	sext.w	s3,s3
    800054a8:	03498a63          	beq	s3,s4,800054dc <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800054ac:	40d0                	lw	a2,4(s1)
    800054ae:	fb040593          	addi	a1,s0,-80
    800054b2:	854a                	mv	a0,s2
    800054b4:	fffff097          	auipc	ra,0xfffff
    800054b8:	cac080e7          	jalr	-852(ra) # 80004160 <dirlink>
    800054bc:	06054b63          	bltz	a0,80005532 <create+0x152>
  iunlockput(dp);
    800054c0:	854a                	mv	a0,s2
    800054c2:	fffff097          	auipc	ra,0xfffff
    800054c6:	80c080e7          	jalr	-2036(ra) # 80003cce <iunlockput>
  return ip;
    800054ca:	b761                	j	80005452 <create+0x72>
    panic("create: ialloc");
    800054cc:	00003517          	auipc	a0,0x3
    800054d0:	26450513          	addi	a0,a0,612 # 80008730 <syscalls+0x2b8>
    800054d4:	ffffb097          	auipc	ra,0xffffb
    800054d8:	05a080e7          	jalr	90(ra) # 8000052e <panic>
    dp->nlink++;  // for ".."
    800054dc:	04a95783          	lhu	a5,74(s2)
    800054e0:	2785                	addiw	a5,a5,1
    800054e2:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800054e6:	854a                	mv	a0,s2
    800054e8:	ffffe097          	auipc	ra,0xffffe
    800054ec:	4ba080e7          	jalr	1210(ra) # 800039a2 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800054f0:	40d0                	lw	a2,4(s1)
    800054f2:	00003597          	auipc	a1,0x3
    800054f6:	24e58593          	addi	a1,a1,590 # 80008740 <syscalls+0x2c8>
    800054fa:	8526                	mv	a0,s1
    800054fc:	fffff097          	auipc	ra,0xfffff
    80005500:	c64080e7          	jalr	-924(ra) # 80004160 <dirlink>
    80005504:	00054f63          	bltz	a0,80005522 <create+0x142>
    80005508:	00492603          	lw	a2,4(s2)
    8000550c:	00003597          	auipc	a1,0x3
    80005510:	23c58593          	addi	a1,a1,572 # 80008748 <syscalls+0x2d0>
    80005514:	8526                	mv	a0,s1
    80005516:	fffff097          	auipc	ra,0xfffff
    8000551a:	c4a080e7          	jalr	-950(ra) # 80004160 <dirlink>
    8000551e:	f80557e3          	bgez	a0,800054ac <create+0xcc>
      panic("create dots");
    80005522:	00003517          	auipc	a0,0x3
    80005526:	22e50513          	addi	a0,a0,558 # 80008750 <syscalls+0x2d8>
    8000552a:	ffffb097          	auipc	ra,0xffffb
    8000552e:	004080e7          	jalr	4(ra) # 8000052e <panic>
    panic("create: dirlink");
    80005532:	00003517          	auipc	a0,0x3
    80005536:	22e50513          	addi	a0,a0,558 # 80008760 <syscalls+0x2e8>
    8000553a:	ffffb097          	auipc	ra,0xffffb
    8000553e:	ff4080e7          	jalr	-12(ra) # 8000052e <panic>
    return 0;
    80005542:	84aa                	mv	s1,a0
    80005544:	b739                	j	80005452 <create+0x72>

0000000080005546 <sys_dup>:
{
    80005546:	7179                	addi	sp,sp,-48
    80005548:	f406                	sd	ra,40(sp)
    8000554a:	f022                	sd	s0,32(sp)
    8000554c:	ec26                	sd	s1,24(sp)
    8000554e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005550:	fd840613          	addi	a2,s0,-40
    80005554:	4581                	li	a1,0
    80005556:	4501                	li	a0,0
    80005558:	00000097          	auipc	ra,0x0
    8000555c:	dde080e7          	jalr	-546(ra) # 80005336 <argfd>
    return -1;
    80005560:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005562:	02054363          	bltz	a0,80005588 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005566:	fd843503          	ld	a0,-40(s0)
    8000556a:	00000097          	auipc	ra,0x0
    8000556e:	e34080e7          	jalr	-460(ra) # 8000539e <fdalloc>
    80005572:	84aa                	mv	s1,a0
    return -1;
    80005574:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005576:	00054963          	bltz	a0,80005588 <sys_dup+0x42>
  filedup(f);
    8000557a:	fd843503          	ld	a0,-40(s0)
    8000557e:	fffff097          	auipc	ra,0xfffff
    80005582:	33e080e7          	jalr	830(ra) # 800048bc <filedup>
  return fd;
    80005586:	87a6                	mv	a5,s1
}
    80005588:	853e                	mv	a0,a5
    8000558a:	70a2                	ld	ra,40(sp)
    8000558c:	7402                	ld	s0,32(sp)
    8000558e:	64e2                	ld	s1,24(sp)
    80005590:	6145                	addi	sp,sp,48
    80005592:	8082                	ret

0000000080005594 <sys_read>:
{
    80005594:	7179                	addi	sp,sp,-48
    80005596:	f406                	sd	ra,40(sp)
    80005598:	f022                	sd	s0,32(sp)
    8000559a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000559c:	fe840613          	addi	a2,s0,-24
    800055a0:	4581                	li	a1,0
    800055a2:	4501                	li	a0,0
    800055a4:	00000097          	auipc	ra,0x0
    800055a8:	d92080e7          	jalr	-622(ra) # 80005336 <argfd>
    return -1;
    800055ac:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055ae:	04054163          	bltz	a0,800055f0 <sys_read+0x5c>
    800055b2:	fe440593          	addi	a1,s0,-28
    800055b6:	4509                	li	a0,2
    800055b8:	ffffe097          	auipc	ra,0xffffe
    800055bc:	860080e7          	jalr	-1952(ra) # 80002e18 <argint>
    return -1;
    800055c0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055c2:	02054763          	bltz	a0,800055f0 <sys_read+0x5c>
    800055c6:	fd840593          	addi	a1,s0,-40
    800055ca:	4505                	li	a0,1
    800055cc:	ffffe097          	auipc	ra,0xffffe
    800055d0:	86e080e7          	jalr	-1938(ra) # 80002e3a <argaddr>
    return -1;
    800055d4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055d6:	00054d63          	bltz	a0,800055f0 <sys_read+0x5c>
  return fileread(f, p, n);
    800055da:	fe442603          	lw	a2,-28(s0)
    800055de:	fd843583          	ld	a1,-40(s0)
    800055e2:	fe843503          	ld	a0,-24(s0)
    800055e6:	fffff097          	auipc	ra,0xfffff
    800055ea:	462080e7          	jalr	1122(ra) # 80004a48 <fileread>
    800055ee:	87aa                	mv	a5,a0
}
    800055f0:	853e                	mv	a0,a5
    800055f2:	70a2                	ld	ra,40(sp)
    800055f4:	7402                	ld	s0,32(sp)
    800055f6:	6145                	addi	sp,sp,48
    800055f8:	8082                	ret

00000000800055fa <sys_write>:
{
    800055fa:	7179                	addi	sp,sp,-48
    800055fc:	f406                	sd	ra,40(sp)
    800055fe:	f022                	sd	s0,32(sp)
    80005600:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005602:	fe840613          	addi	a2,s0,-24
    80005606:	4581                	li	a1,0
    80005608:	4501                	li	a0,0
    8000560a:	00000097          	auipc	ra,0x0
    8000560e:	d2c080e7          	jalr	-724(ra) # 80005336 <argfd>
    return -1;
    80005612:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005614:	04054163          	bltz	a0,80005656 <sys_write+0x5c>
    80005618:	fe440593          	addi	a1,s0,-28
    8000561c:	4509                	li	a0,2
    8000561e:	ffffd097          	auipc	ra,0xffffd
    80005622:	7fa080e7          	jalr	2042(ra) # 80002e18 <argint>
    return -1;
    80005626:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005628:	02054763          	bltz	a0,80005656 <sys_write+0x5c>
    8000562c:	fd840593          	addi	a1,s0,-40
    80005630:	4505                	li	a0,1
    80005632:	ffffe097          	auipc	ra,0xffffe
    80005636:	808080e7          	jalr	-2040(ra) # 80002e3a <argaddr>
    return -1;
    8000563a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000563c:	00054d63          	bltz	a0,80005656 <sys_write+0x5c>
  return filewrite(f, p, n);
    80005640:	fe442603          	lw	a2,-28(s0)
    80005644:	fd843583          	ld	a1,-40(s0)
    80005648:	fe843503          	ld	a0,-24(s0)
    8000564c:	fffff097          	auipc	ra,0xfffff
    80005650:	4be080e7          	jalr	1214(ra) # 80004b0a <filewrite>
    80005654:	87aa                	mv	a5,a0
}
    80005656:	853e                	mv	a0,a5
    80005658:	70a2                	ld	ra,40(sp)
    8000565a:	7402                	ld	s0,32(sp)
    8000565c:	6145                	addi	sp,sp,48
    8000565e:	8082                	ret

0000000080005660 <sys_close>:
{
    80005660:	1101                	addi	sp,sp,-32
    80005662:	ec06                	sd	ra,24(sp)
    80005664:	e822                	sd	s0,16(sp)
    80005666:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005668:	fe040613          	addi	a2,s0,-32
    8000566c:	fec40593          	addi	a1,s0,-20
    80005670:	4501                	li	a0,0
    80005672:	00000097          	auipc	ra,0x0
    80005676:	cc4080e7          	jalr	-828(ra) # 80005336 <argfd>
    return -1;
    8000567a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000567c:	02054463          	bltz	a0,800056a4 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005680:	ffffc097          	auipc	ra,0xffffc
    80005684:	318080e7          	jalr	792(ra) # 80001998 <myproc>
    80005688:	fec42783          	lw	a5,-20(s0)
    8000568c:	07e9                	addi	a5,a5,26
    8000568e:	078e                	slli	a5,a5,0x3
    80005690:	97aa                	add	a5,a5,a0
    80005692:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80005696:	fe043503          	ld	a0,-32(s0)
    8000569a:	fffff097          	auipc	ra,0xfffff
    8000569e:	274080e7          	jalr	628(ra) # 8000490e <fileclose>
  return 0;
    800056a2:	4781                	li	a5,0
}
    800056a4:	853e                	mv	a0,a5
    800056a6:	60e2                	ld	ra,24(sp)
    800056a8:	6442                	ld	s0,16(sp)
    800056aa:	6105                	addi	sp,sp,32
    800056ac:	8082                	ret

00000000800056ae <sys_fstat>:
{
    800056ae:	1101                	addi	sp,sp,-32
    800056b0:	ec06                	sd	ra,24(sp)
    800056b2:	e822                	sd	s0,16(sp)
    800056b4:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800056b6:	fe840613          	addi	a2,s0,-24
    800056ba:	4581                	li	a1,0
    800056bc:	4501                	li	a0,0
    800056be:	00000097          	auipc	ra,0x0
    800056c2:	c78080e7          	jalr	-904(ra) # 80005336 <argfd>
    return -1;
    800056c6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800056c8:	02054563          	bltz	a0,800056f2 <sys_fstat+0x44>
    800056cc:	fe040593          	addi	a1,s0,-32
    800056d0:	4505                	li	a0,1
    800056d2:	ffffd097          	auipc	ra,0xffffd
    800056d6:	768080e7          	jalr	1896(ra) # 80002e3a <argaddr>
    return -1;
    800056da:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800056dc:	00054b63          	bltz	a0,800056f2 <sys_fstat+0x44>
  return filestat(f, st);
    800056e0:	fe043583          	ld	a1,-32(s0)
    800056e4:	fe843503          	ld	a0,-24(s0)
    800056e8:	fffff097          	auipc	ra,0xfffff
    800056ec:	2ee080e7          	jalr	750(ra) # 800049d6 <filestat>
    800056f0:	87aa                	mv	a5,a0
}
    800056f2:	853e                	mv	a0,a5
    800056f4:	60e2                	ld	ra,24(sp)
    800056f6:	6442                	ld	s0,16(sp)
    800056f8:	6105                	addi	sp,sp,32
    800056fa:	8082                	ret

00000000800056fc <sys_link>:
{
    800056fc:	7169                	addi	sp,sp,-304
    800056fe:	f606                	sd	ra,296(sp)
    80005700:	f222                	sd	s0,288(sp)
    80005702:	ee26                	sd	s1,280(sp)
    80005704:	ea4a                	sd	s2,272(sp)
    80005706:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005708:	08000613          	li	a2,128
    8000570c:	ed040593          	addi	a1,s0,-304
    80005710:	4501                	li	a0,0
    80005712:	ffffd097          	auipc	ra,0xffffd
    80005716:	74a080e7          	jalr	1866(ra) # 80002e5c <argstr>
    return -1;
    8000571a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000571c:	10054e63          	bltz	a0,80005838 <sys_link+0x13c>
    80005720:	08000613          	li	a2,128
    80005724:	f5040593          	addi	a1,s0,-176
    80005728:	4505                	li	a0,1
    8000572a:	ffffd097          	auipc	ra,0xffffd
    8000572e:	732080e7          	jalr	1842(ra) # 80002e5c <argstr>
    return -1;
    80005732:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005734:	10054263          	bltz	a0,80005838 <sys_link+0x13c>
  begin_op();
    80005738:	fffff097          	auipc	ra,0xfffff
    8000573c:	d0a080e7          	jalr	-758(ra) # 80004442 <begin_op>
  if((ip = namei(old)) == 0){
    80005740:	ed040513          	addi	a0,s0,-304
    80005744:	fffff097          	auipc	ra,0xfffff
    80005748:	ade080e7          	jalr	-1314(ra) # 80004222 <namei>
    8000574c:	84aa                	mv	s1,a0
    8000574e:	c551                	beqz	a0,800057da <sys_link+0xde>
  ilock(ip);
    80005750:	ffffe097          	auipc	ra,0xffffe
    80005754:	31c080e7          	jalr	796(ra) # 80003a6c <ilock>
  if(ip->type == T_DIR){
    80005758:	04449703          	lh	a4,68(s1)
    8000575c:	4785                	li	a5,1
    8000575e:	08f70463          	beq	a4,a5,800057e6 <sys_link+0xea>
  ip->nlink++;
    80005762:	04a4d783          	lhu	a5,74(s1)
    80005766:	2785                	addiw	a5,a5,1
    80005768:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000576c:	8526                	mv	a0,s1
    8000576e:	ffffe097          	auipc	ra,0xffffe
    80005772:	234080e7          	jalr	564(ra) # 800039a2 <iupdate>
  iunlock(ip);
    80005776:	8526                	mv	a0,s1
    80005778:	ffffe097          	auipc	ra,0xffffe
    8000577c:	3b6080e7          	jalr	950(ra) # 80003b2e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005780:	fd040593          	addi	a1,s0,-48
    80005784:	f5040513          	addi	a0,s0,-176
    80005788:	fffff097          	auipc	ra,0xfffff
    8000578c:	ab8080e7          	jalr	-1352(ra) # 80004240 <nameiparent>
    80005790:	892a                	mv	s2,a0
    80005792:	c935                	beqz	a0,80005806 <sys_link+0x10a>
  ilock(dp);
    80005794:	ffffe097          	auipc	ra,0xffffe
    80005798:	2d8080e7          	jalr	728(ra) # 80003a6c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000579c:	00092703          	lw	a4,0(s2)
    800057a0:	409c                	lw	a5,0(s1)
    800057a2:	04f71d63          	bne	a4,a5,800057fc <sys_link+0x100>
    800057a6:	40d0                	lw	a2,4(s1)
    800057a8:	fd040593          	addi	a1,s0,-48
    800057ac:	854a                	mv	a0,s2
    800057ae:	fffff097          	auipc	ra,0xfffff
    800057b2:	9b2080e7          	jalr	-1614(ra) # 80004160 <dirlink>
    800057b6:	04054363          	bltz	a0,800057fc <sys_link+0x100>
  iunlockput(dp);
    800057ba:	854a                	mv	a0,s2
    800057bc:	ffffe097          	auipc	ra,0xffffe
    800057c0:	512080e7          	jalr	1298(ra) # 80003cce <iunlockput>
  iput(ip);
    800057c4:	8526                	mv	a0,s1
    800057c6:	ffffe097          	auipc	ra,0xffffe
    800057ca:	460080e7          	jalr	1120(ra) # 80003c26 <iput>
  end_op();
    800057ce:	fffff097          	auipc	ra,0xfffff
    800057d2:	cf4080e7          	jalr	-780(ra) # 800044c2 <end_op>
  return 0;
    800057d6:	4781                	li	a5,0
    800057d8:	a085                	j	80005838 <sys_link+0x13c>
    end_op();
    800057da:	fffff097          	auipc	ra,0xfffff
    800057de:	ce8080e7          	jalr	-792(ra) # 800044c2 <end_op>
    return -1;
    800057e2:	57fd                	li	a5,-1
    800057e4:	a891                	j	80005838 <sys_link+0x13c>
    iunlockput(ip);
    800057e6:	8526                	mv	a0,s1
    800057e8:	ffffe097          	auipc	ra,0xffffe
    800057ec:	4e6080e7          	jalr	1254(ra) # 80003cce <iunlockput>
    end_op();
    800057f0:	fffff097          	auipc	ra,0xfffff
    800057f4:	cd2080e7          	jalr	-814(ra) # 800044c2 <end_op>
    return -1;
    800057f8:	57fd                	li	a5,-1
    800057fa:	a83d                	j	80005838 <sys_link+0x13c>
    iunlockput(dp);
    800057fc:	854a                	mv	a0,s2
    800057fe:	ffffe097          	auipc	ra,0xffffe
    80005802:	4d0080e7          	jalr	1232(ra) # 80003cce <iunlockput>
  ilock(ip);
    80005806:	8526                	mv	a0,s1
    80005808:	ffffe097          	auipc	ra,0xffffe
    8000580c:	264080e7          	jalr	612(ra) # 80003a6c <ilock>
  ip->nlink--;
    80005810:	04a4d783          	lhu	a5,74(s1)
    80005814:	37fd                	addiw	a5,a5,-1
    80005816:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000581a:	8526                	mv	a0,s1
    8000581c:	ffffe097          	auipc	ra,0xffffe
    80005820:	186080e7          	jalr	390(ra) # 800039a2 <iupdate>
  iunlockput(ip);
    80005824:	8526                	mv	a0,s1
    80005826:	ffffe097          	auipc	ra,0xffffe
    8000582a:	4a8080e7          	jalr	1192(ra) # 80003cce <iunlockput>
  end_op();
    8000582e:	fffff097          	auipc	ra,0xfffff
    80005832:	c94080e7          	jalr	-876(ra) # 800044c2 <end_op>
  return -1;
    80005836:	57fd                	li	a5,-1
}
    80005838:	853e                	mv	a0,a5
    8000583a:	70b2                	ld	ra,296(sp)
    8000583c:	7412                	ld	s0,288(sp)
    8000583e:	64f2                	ld	s1,280(sp)
    80005840:	6952                	ld	s2,272(sp)
    80005842:	6155                	addi	sp,sp,304
    80005844:	8082                	ret

0000000080005846 <sys_unlink>:
{
    80005846:	7151                	addi	sp,sp,-240
    80005848:	f586                	sd	ra,232(sp)
    8000584a:	f1a2                	sd	s0,224(sp)
    8000584c:	eda6                	sd	s1,216(sp)
    8000584e:	e9ca                	sd	s2,208(sp)
    80005850:	e5ce                	sd	s3,200(sp)
    80005852:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005854:	08000613          	li	a2,128
    80005858:	f3040593          	addi	a1,s0,-208
    8000585c:	4501                	li	a0,0
    8000585e:	ffffd097          	auipc	ra,0xffffd
    80005862:	5fe080e7          	jalr	1534(ra) # 80002e5c <argstr>
    80005866:	18054163          	bltz	a0,800059e8 <sys_unlink+0x1a2>
  begin_op();
    8000586a:	fffff097          	auipc	ra,0xfffff
    8000586e:	bd8080e7          	jalr	-1064(ra) # 80004442 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005872:	fb040593          	addi	a1,s0,-80
    80005876:	f3040513          	addi	a0,s0,-208
    8000587a:	fffff097          	auipc	ra,0xfffff
    8000587e:	9c6080e7          	jalr	-1594(ra) # 80004240 <nameiparent>
    80005882:	84aa                	mv	s1,a0
    80005884:	c979                	beqz	a0,8000595a <sys_unlink+0x114>
  ilock(dp);
    80005886:	ffffe097          	auipc	ra,0xffffe
    8000588a:	1e6080e7          	jalr	486(ra) # 80003a6c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000588e:	00003597          	auipc	a1,0x3
    80005892:	eb258593          	addi	a1,a1,-334 # 80008740 <syscalls+0x2c8>
    80005896:	fb040513          	addi	a0,s0,-80
    8000589a:	ffffe097          	auipc	ra,0xffffe
    8000589e:	69c080e7          	jalr	1692(ra) # 80003f36 <namecmp>
    800058a2:	14050a63          	beqz	a0,800059f6 <sys_unlink+0x1b0>
    800058a6:	00003597          	auipc	a1,0x3
    800058aa:	ea258593          	addi	a1,a1,-350 # 80008748 <syscalls+0x2d0>
    800058ae:	fb040513          	addi	a0,s0,-80
    800058b2:	ffffe097          	auipc	ra,0xffffe
    800058b6:	684080e7          	jalr	1668(ra) # 80003f36 <namecmp>
    800058ba:	12050e63          	beqz	a0,800059f6 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800058be:	f2c40613          	addi	a2,s0,-212
    800058c2:	fb040593          	addi	a1,s0,-80
    800058c6:	8526                	mv	a0,s1
    800058c8:	ffffe097          	auipc	ra,0xffffe
    800058cc:	688080e7          	jalr	1672(ra) # 80003f50 <dirlookup>
    800058d0:	892a                	mv	s2,a0
    800058d2:	12050263          	beqz	a0,800059f6 <sys_unlink+0x1b0>
  ilock(ip);
    800058d6:	ffffe097          	auipc	ra,0xffffe
    800058da:	196080e7          	jalr	406(ra) # 80003a6c <ilock>
  if(ip->nlink < 1)
    800058de:	04a91783          	lh	a5,74(s2)
    800058e2:	08f05263          	blez	a5,80005966 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800058e6:	04491703          	lh	a4,68(s2)
    800058ea:	4785                	li	a5,1
    800058ec:	08f70563          	beq	a4,a5,80005976 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800058f0:	4641                	li	a2,16
    800058f2:	4581                	li	a1,0
    800058f4:	fc040513          	addi	a0,s0,-64
    800058f8:	ffffb097          	auipc	ra,0xffffb
    800058fc:	3e0080e7          	jalr	992(ra) # 80000cd8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005900:	4741                	li	a4,16
    80005902:	f2c42683          	lw	a3,-212(s0)
    80005906:	fc040613          	addi	a2,s0,-64
    8000590a:	4581                	li	a1,0
    8000590c:	8526                	mv	a0,s1
    8000590e:	ffffe097          	auipc	ra,0xffffe
    80005912:	50a080e7          	jalr	1290(ra) # 80003e18 <writei>
    80005916:	47c1                	li	a5,16
    80005918:	0af51563          	bne	a0,a5,800059c2 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000591c:	04491703          	lh	a4,68(s2)
    80005920:	4785                	li	a5,1
    80005922:	0af70863          	beq	a4,a5,800059d2 <sys_unlink+0x18c>
  iunlockput(dp);
    80005926:	8526                	mv	a0,s1
    80005928:	ffffe097          	auipc	ra,0xffffe
    8000592c:	3a6080e7          	jalr	934(ra) # 80003cce <iunlockput>
  ip->nlink--;
    80005930:	04a95783          	lhu	a5,74(s2)
    80005934:	37fd                	addiw	a5,a5,-1
    80005936:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000593a:	854a                	mv	a0,s2
    8000593c:	ffffe097          	auipc	ra,0xffffe
    80005940:	066080e7          	jalr	102(ra) # 800039a2 <iupdate>
  iunlockput(ip);
    80005944:	854a                	mv	a0,s2
    80005946:	ffffe097          	auipc	ra,0xffffe
    8000594a:	388080e7          	jalr	904(ra) # 80003cce <iunlockput>
  end_op();
    8000594e:	fffff097          	auipc	ra,0xfffff
    80005952:	b74080e7          	jalr	-1164(ra) # 800044c2 <end_op>
  return 0;
    80005956:	4501                	li	a0,0
    80005958:	a84d                	j	80005a0a <sys_unlink+0x1c4>
    end_op();
    8000595a:	fffff097          	auipc	ra,0xfffff
    8000595e:	b68080e7          	jalr	-1176(ra) # 800044c2 <end_op>
    return -1;
    80005962:	557d                	li	a0,-1
    80005964:	a05d                	j	80005a0a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005966:	00003517          	auipc	a0,0x3
    8000596a:	e0a50513          	addi	a0,a0,-502 # 80008770 <syscalls+0x2f8>
    8000596e:	ffffb097          	auipc	ra,0xffffb
    80005972:	bc0080e7          	jalr	-1088(ra) # 8000052e <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005976:	04c92703          	lw	a4,76(s2)
    8000597a:	02000793          	li	a5,32
    8000597e:	f6e7f9e3          	bgeu	a5,a4,800058f0 <sys_unlink+0xaa>
    80005982:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005986:	4741                	li	a4,16
    80005988:	86ce                	mv	a3,s3
    8000598a:	f1840613          	addi	a2,s0,-232
    8000598e:	4581                	li	a1,0
    80005990:	854a                	mv	a0,s2
    80005992:	ffffe097          	auipc	ra,0xffffe
    80005996:	38e080e7          	jalr	910(ra) # 80003d20 <readi>
    8000599a:	47c1                	li	a5,16
    8000599c:	00f51b63          	bne	a0,a5,800059b2 <sys_unlink+0x16c>
    if(de.inum != 0)
    800059a0:	f1845783          	lhu	a5,-232(s0)
    800059a4:	e7a1                	bnez	a5,800059ec <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059a6:	29c1                	addiw	s3,s3,16
    800059a8:	04c92783          	lw	a5,76(s2)
    800059ac:	fcf9ede3          	bltu	s3,a5,80005986 <sys_unlink+0x140>
    800059b0:	b781                	j	800058f0 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800059b2:	00003517          	auipc	a0,0x3
    800059b6:	dd650513          	addi	a0,a0,-554 # 80008788 <syscalls+0x310>
    800059ba:	ffffb097          	auipc	ra,0xffffb
    800059be:	b74080e7          	jalr	-1164(ra) # 8000052e <panic>
    panic("unlink: writei");
    800059c2:	00003517          	auipc	a0,0x3
    800059c6:	dde50513          	addi	a0,a0,-546 # 800087a0 <syscalls+0x328>
    800059ca:	ffffb097          	auipc	ra,0xffffb
    800059ce:	b64080e7          	jalr	-1180(ra) # 8000052e <panic>
    dp->nlink--;
    800059d2:	04a4d783          	lhu	a5,74(s1)
    800059d6:	37fd                	addiw	a5,a5,-1
    800059d8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800059dc:	8526                	mv	a0,s1
    800059de:	ffffe097          	auipc	ra,0xffffe
    800059e2:	fc4080e7          	jalr	-60(ra) # 800039a2 <iupdate>
    800059e6:	b781                	j	80005926 <sys_unlink+0xe0>
    return -1;
    800059e8:	557d                	li	a0,-1
    800059ea:	a005                	j	80005a0a <sys_unlink+0x1c4>
    iunlockput(ip);
    800059ec:	854a                	mv	a0,s2
    800059ee:	ffffe097          	auipc	ra,0xffffe
    800059f2:	2e0080e7          	jalr	736(ra) # 80003cce <iunlockput>
  iunlockput(dp);
    800059f6:	8526                	mv	a0,s1
    800059f8:	ffffe097          	auipc	ra,0xffffe
    800059fc:	2d6080e7          	jalr	726(ra) # 80003cce <iunlockput>
  end_op();
    80005a00:	fffff097          	auipc	ra,0xfffff
    80005a04:	ac2080e7          	jalr	-1342(ra) # 800044c2 <end_op>
  return -1;
    80005a08:	557d                	li	a0,-1
}
    80005a0a:	70ae                	ld	ra,232(sp)
    80005a0c:	740e                	ld	s0,224(sp)
    80005a0e:	64ee                	ld	s1,216(sp)
    80005a10:	694e                	ld	s2,208(sp)
    80005a12:	69ae                	ld	s3,200(sp)
    80005a14:	616d                	addi	sp,sp,240
    80005a16:	8082                	ret

0000000080005a18 <sys_open>:

uint64
sys_open(void)
{
    80005a18:	7131                	addi	sp,sp,-192
    80005a1a:	fd06                	sd	ra,184(sp)
    80005a1c:	f922                	sd	s0,176(sp)
    80005a1e:	f526                	sd	s1,168(sp)
    80005a20:	f14a                	sd	s2,160(sp)
    80005a22:	ed4e                	sd	s3,152(sp)
    80005a24:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005a26:	08000613          	li	a2,128
    80005a2a:	f5040593          	addi	a1,s0,-176
    80005a2e:	4501                	li	a0,0
    80005a30:	ffffd097          	auipc	ra,0xffffd
    80005a34:	42c080e7          	jalr	1068(ra) # 80002e5c <argstr>
    return -1;
    80005a38:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005a3a:	0c054163          	bltz	a0,80005afc <sys_open+0xe4>
    80005a3e:	f4c40593          	addi	a1,s0,-180
    80005a42:	4505                	li	a0,1
    80005a44:	ffffd097          	auipc	ra,0xffffd
    80005a48:	3d4080e7          	jalr	980(ra) # 80002e18 <argint>
    80005a4c:	0a054863          	bltz	a0,80005afc <sys_open+0xe4>

  begin_op();
    80005a50:	fffff097          	auipc	ra,0xfffff
    80005a54:	9f2080e7          	jalr	-1550(ra) # 80004442 <begin_op>

  if(omode & O_CREATE){
    80005a58:	f4c42783          	lw	a5,-180(s0)
    80005a5c:	2007f793          	andi	a5,a5,512
    80005a60:	cbdd                	beqz	a5,80005b16 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005a62:	4681                	li	a3,0
    80005a64:	4601                	li	a2,0
    80005a66:	4589                	li	a1,2
    80005a68:	f5040513          	addi	a0,s0,-176
    80005a6c:	00000097          	auipc	ra,0x0
    80005a70:	974080e7          	jalr	-1676(ra) # 800053e0 <create>
    80005a74:	892a                	mv	s2,a0
    if(ip == 0){
    80005a76:	c959                	beqz	a0,80005b0c <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a78:	04491703          	lh	a4,68(s2)
    80005a7c:	478d                	li	a5,3
    80005a7e:	00f71763          	bne	a4,a5,80005a8c <sys_open+0x74>
    80005a82:	04695703          	lhu	a4,70(s2)
    80005a86:	47a5                	li	a5,9
    80005a88:	0ce7ec63          	bltu	a5,a4,80005b60 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005a8c:	fffff097          	auipc	ra,0xfffff
    80005a90:	dc6080e7          	jalr	-570(ra) # 80004852 <filealloc>
    80005a94:	89aa                	mv	s3,a0
    80005a96:	10050263          	beqz	a0,80005b9a <sys_open+0x182>
    80005a9a:	00000097          	auipc	ra,0x0
    80005a9e:	904080e7          	jalr	-1788(ra) # 8000539e <fdalloc>
    80005aa2:	84aa                	mv	s1,a0
    80005aa4:	0e054663          	bltz	a0,80005b90 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005aa8:	04491703          	lh	a4,68(s2)
    80005aac:	478d                	li	a5,3
    80005aae:	0cf70463          	beq	a4,a5,80005b76 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ab2:	4789                	li	a5,2
    80005ab4:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005ab8:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005abc:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005ac0:	f4c42783          	lw	a5,-180(s0)
    80005ac4:	0017c713          	xori	a4,a5,1
    80005ac8:	8b05                	andi	a4,a4,1
    80005aca:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005ace:	0037f713          	andi	a4,a5,3
    80005ad2:	00e03733          	snez	a4,a4
    80005ad6:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005ada:	4007f793          	andi	a5,a5,1024
    80005ade:	c791                	beqz	a5,80005aea <sys_open+0xd2>
    80005ae0:	04491703          	lh	a4,68(s2)
    80005ae4:	4789                	li	a5,2
    80005ae6:	08f70f63          	beq	a4,a5,80005b84 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005aea:	854a                	mv	a0,s2
    80005aec:	ffffe097          	auipc	ra,0xffffe
    80005af0:	042080e7          	jalr	66(ra) # 80003b2e <iunlock>
  end_op();
    80005af4:	fffff097          	auipc	ra,0xfffff
    80005af8:	9ce080e7          	jalr	-1586(ra) # 800044c2 <end_op>

  return fd;
}
    80005afc:	8526                	mv	a0,s1
    80005afe:	70ea                	ld	ra,184(sp)
    80005b00:	744a                	ld	s0,176(sp)
    80005b02:	74aa                	ld	s1,168(sp)
    80005b04:	790a                	ld	s2,160(sp)
    80005b06:	69ea                	ld	s3,152(sp)
    80005b08:	6129                	addi	sp,sp,192
    80005b0a:	8082                	ret
      end_op();
    80005b0c:	fffff097          	auipc	ra,0xfffff
    80005b10:	9b6080e7          	jalr	-1610(ra) # 800044c2 <end_op>
      return -1;
    80005b14:	b7e5                	j	80005afc <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005b16:	f5040513          	addi	a0,s0,-176
    80005b1a:	ffffe097          	auipc	ra,0xffffe
    80005b1e:	708080e7          	jalr	1800(ra) # 80004222 <namei>
    80005b22:	892a                	mv	s2,a0
    80005b24:	c905                	beqz	a0,80005b54 <sys_open+0x13c>
    ilock(ip);
    80005b26:	ffffe097          	auipc	ra,0xffffe
    80005b2a:	f46080e7          	jalr	-186(ra) # 80003a6c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b2e:	04491703          	lh	a4,68(s2)
    80005b32:	4785                	li	a5,1
    80005b34:	f4f712e3          	bne	a4,a5,80005a78 <sys_open+0x60>
    80005b38:	f4c42783          	lw	a5,-180(s0)
    80005b3c:	dba1                	beqz	a5,80005a8c <sys_open+0x74>
      iunlockput(ip);
    80005b3e:	854a                	mv	a0,s2
    80005b40:	ffffe097          	auipc	ra,0xffffe
    80005b44:	18e080e7          	jalr	398(ra) # 80003cce <iunlockput>
      end_op();
    80005b48:	fffff097          	auipc	ra,0xfffff
    80005b4c:	97a080e7          	jalr	-1670(ra) # 800044c2 <end_op>
      return -1;
    80005b50:	54fd                	li	s1,-1
    80005b52:	b76d                	j	80005afc <sys_open+0xe4>
      end_op();
    80005b54:	fffff097          	auipc	ra,0xfffff
    80005b58:	96e080e7          	jalr	-1682(ra) # 800044c2 <end_op>
      return -1;
    80005b5c:	54fd                	li	s1,-1
    80005b5e:	bf79                	j	80005afc <sys_open+0xe4>
    iunlockput(ip);
    80005b60:	854a                	mv	a0,s2
    80005b62:	ffffe097          	auipc	ra,0xffffe
    80005b66:	16c080e7          	jalr	364(ra) # 80003cce <iunlockput>
    end_op();
    80005b6a:	fffff097          	auipc	ra,0xfffff
    80005b6e:	958080e7          	jalr	-1704(ra) # 800044c2 <end_op>
    return -1;
    80005b72:	54fd                	li	s1,-1
    80005b74:	b761                	j	80005afc <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005b76:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005b7a:	04691783          	lh	a5,70(s2)
    80005b7e:	02f99223          	sh	a5,36(s3)
    80005b82:	bf2d                	j	80005abc <sys_open+0xa4>
    itrunc(ip);
    80005b84:	854a                	mv	a0,s2
    80005b86:	ffffe097          	auipc	ra,0xffffe
    80005b8a:	ff4080e7          	jalr	-12(ra) # 80003b7a <itrunc>
    80005b8e:	bfb1                	j	80005aea <sys_open+0xd2>
      fileclose(f);
    80005b90:	854e                	mv	a0,s3
    80005b92:	fffff097          	auipc	ra,0xfffff
    80005b96:	d7c080e7          	jalr	-644(ra) # 8000490e <fileclose>
    iunlockput(ip);
    80005b9a:	854a                	mv	a0,s2
    80005b9c:	ffffe097          	auipc	ra,0xffffe
    80005ba0:	132080e7          	jalr	306(ra) # 80003cce <iunlockput>
    end_op();
    80005ba4:	fffff097          	auipc	ra,0xfffff
    80005ba8:	91e080e7          	jalr	-1762(ra) # 800044c2 <end_op>
    return -1;
    80005bac:	54fd                	li	s1,-1
    80005bae:	b7b9                	j	80005afc <sys_open+0xe4>

0000000080005bb0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005bb0:	7175                	addi	sp,sp,-144
    80005bb2:	e506                	sd	ra,136(sp)
    80005bb4:	e122                	sd	s0,128(sp)
    80005bb6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005bb8:	fffff097          	auipc	ra,0xfffff
    80005bbc:	88a080e7          	jalr	-1910(ra) # 80004442 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005bc0:	08000613          	li	a2,128
    80005bc4:	f7040593          	addi	a1,s0,-144
    80005bc8:	4501                	li	a0,0
    80005bca:	ffffd097          	auipc	ra,0xffffd
    80005bce:	292080e7          	jalr	658(ra) # 80002e5c <argstr>
    80005bd2:	02054963          	bltz	a0,80005c04 <sys_mkdir+0x54>
    80005bd6:	4681                	li	a3,0
    80005bd8:	4601                	li	a2,0
    80005bda:	4585                	li	a1,1
    80005bdc:	f7040513          	addi	a0,s0,-144
    80005be0:	00000097          	auipc	ra,0x0
    80005be4:	800080e7          	jalr	-2048(ra) # 800053e0 <create>
    80005be8:	cd11                	beqz	a0,80005c04 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005bea:	ffffe097          	auipc	ra,0xffffe
    80005bee:	0e4080e7          	jalr	228(ra) # 80003cce <iunlockput>
  end_op();
    80005bf2:	fffff097          	auipc	ra,0xfffff
    80005bf6:	8d0080e7          	jalr	-1840(ra) # 800044c2 <end_op>
  return 0;
    80005bfa:	4501                	li	a0,0
}
    80005bfc:	60aa                	ld	ra,136(sp)
    80005bfe:	640a                	ld	s0,128(sp)
    80005c00:	6149                	addi	sp,sp,144
    80005c02:	8082                	ret
    end_op();
    80005c04:	fffff097          	auipc	ra,0xfffff
    80005c08:	8be080e7          	jalr	-1858(ra) # 800044c2 <end_op>
    return -1;
    80005c0c:	557d                	li	a0,-1
    80005c0e:	b7fd                	j	80005bfc <sys_mkdir+0x4c>

0000000080005c10 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c10:	7135                	addi	sp,sp,-160
    80005c12:	ed06                	sd	ra,152(sp)
    80005c14:	e922                	sd	s0,144(sp)
    80005c16:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005c18:	fffff097          	auipc	ra,0xfffff
    80005c1c:	82a080e7          	jalr	-2006(ra) # 80004442 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c20:	08000613          	li	a2,128
    80005c24:	f7040593          	addi	a1,s0,-144
    80005c28:	4501                	li	a0,0
    80005c2a:	ffffd097          	auipc	ra,0xffffd
    80005c2e:	232080e7          	jalr	562(ra) # 80002e5c <argstr>
    80005c32:	04054a63          	bltz	a0,80005c86 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005c36:	f6c40593          	addi	a1,s0,-148
    80005c3a:	4505                	li	a0,1
    80005c3c:	ffffd097          	auipc	ra,0xffffd
    80005c40:	1dc080e7          	jalr	476(ra) # 80002e18 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c44:	04054163          	bltz	a0,80005c86 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005c48:	f6840593          	addi	a1,s0,-152
    80005c4c:	4509                	li	a0,2
    80005c4e:	ffffd097          	auipc	ra,0xffffd
    80005c52:	1ca080e7          	jalr	458(ra) # 80002e18 <argint>
     argint(1, &major) < 0 ||
    80005c56:	02054863          	bltz	a0,80005c86 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c5a:	f6841683          	lh	a3,-152(s0)
    80005c5e:	f6c41603          	lh	a2,-148(s0)
    80005c62:	458d                	li	a1,3
    80005c64:	f7040513          	addi	a0,s0,-144
    80005c68:	fffff097          	auipc	ra,0xfffff
    80005c6c:	778080e7          	jalr	1912(ra) # 800053e0 <create>
     argint(2, &minor) < 0 ||
    80005c70:	c919                	beqz	a0,80005c86 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c72:	ffffe097          	auipc	ra,0xffffe
    80005c76:	05c080e7          	jalr	92(ra) # 80003cce <iunlockput>
  end_op();
    80005c7a:	fffff097          	auipc	ra,0xfffff
    80005c7e:	848080e7          	jalr	-1976(ra) # 800044c2 <end_op>
  return 0;
    80005c82:	4501                	li	a0,0
    80005c84:	a031                	j	80005c90 <sys_mknod+0x80>
    end_op();
    80005c86:	fffff097          	auipc	ra,0xfffff
    80005c8a:	83c080e7          	jalr	-1988(ra) # 800044c2 <end_op>
    return -1;
    80005c8e:	557d                	li	a0,-1
}
    80005c90:	60ea                	ld	ra,152(sp)
    80005c92:	644a                	ld	s0,144(sp)
    80005c94:	610d                	addi	sp,sp,160
    80005c96:	8082                	ret

0000000080005c98 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005c98:	7135                	addi	sp,sp,-160
    80005c9a:	ed06                	sd	ra,152(sp)
    80005c9c:	e922                	sd	s0,144(sp)
    80005c9e:	e526                	sd	s1,136(sp)
    80005ca0:	e14a                	sd	s2,128(sp)
    80005ca2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005ca4:	ffffc097          	auipc	ra,0xffffc
    80005ca8:	cf4080e7          	jalr	-780(ra) # 80001998 <myproc>
    80005cac:	892a                	mv	s2,a0
  
  begin_op();
    80005cae:	ffffe097          	auipc	ra,0xffffe
    80005cb2:	794080e7          	jalr	1940(ra) # 80004442 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005cb6:	08000613          	li	a2,128
    80005cba:	f6040593          	addi	a1,s0,-160
    80005cbe:	4501                	li	a0,0
    80005cc0:	ffffd097          	auipc	ra,0xffffd
    80005cc4:	19c080e7          	jalr	412(ra) # 80002e5c <argstr>
    80005cc8:	04054b63          	bltz	a0,80005d1e <sys_chdir+0x86>
    80005ccc:	f6040513          	addi	a0,s0,-160
    80005cd0:	ffffe097          	auipc	ra,0xffffe
    80005cd4:	552080e7          	jalr	1362(ra) # 80004222 <namei>
    80005cd8:	84aa                	mv	s1,a0
    80005cda:	c131                	beqz	a0,80005d1e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005cdc:	ffffe097          	auipc	ra,0xffffe
    80005ce0:	d90080e7          	jalr	-624(ra) # 80003a6c <ilock>
  if(ip->type != T_DIR){
    80005ce4:	04449703          	lh	a4,68(s1)
    80005ce8:	4785                	li	a5,1
    80005cea:	04f71063          	bne	a4,a5,80005d2a <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005cee:	8526                	mv	a0,s1
    80005cf0:	ffffe097          	auipc	ra,0xffffe
    80005cf4:	e3e080e7          	jalr	-450(ra) # 80003b2e <iunlock>
  iput(p->cwd);
    80005cf8:	15093503          	ld	a0,336(s2)
    80005cfc:	ffffe097          	auipc	ra,0xffffe
    80005d00:	f2a080e7          	jalr	-214(ra) # 80003c26 <iput>
  end_op();
    80005d04:	ffffe097          	auipc	ra,0xffffe
    80005d08:	7be080e7          	jalr	1982(ra) # 800044c2 <end_op>
  p->cwd = ip;
    80005d0c:	14993823          	sd	s1,336(s2)
  return 0;
    80005d10:	4501                	li	a0,0
}
    80005d12:	60ea                	ld	ra,152(sp)
    80005d14:	644a                	ld	s0,144(sp)
    80005d16:	64aa                	ld	s1,136(sp)
    80005d18:	690a                	ld	s2,128(sp)
    80005d1a:	610d                	addi	sp,sp,160
    80005d1c:	8082                	ret
    end_op();
    80005d1e:	ffffe097          	auipc	ra,0xffffe
    80005d22:	7a4080e7          	jalr	1956(ra) # 800044c2 <end_op>
    return -1;
    80005d26:	557d                	li	a0,-1
    80005d28:	b7ed                	j	80005d12 <sys_chdir+0x7a>
    iunlockput(ip);
    80005d2a:	8526                	mv	a0,s1
    80005d2c:	ffffe097          	auipc	ra,0xffffe
    80005d30:	fa2080e7          	jalr	-94(ra) # 80003cce <iunlockput>
    end_op();
    80005d34:	ffffe097          	auipc	ra,0xffffe
    80005d38:	78e080e7          	jalr	1934(ra) # 800044c2 <end_op>
    return -1;
    80005d3c:	557d                	li	a0,-1
    80005d3e:	bfd1                	j	80005d12 <sys_chdir+0x7a>

0000000080005d40 <sys_exec>:

uint64
sys_exec(void)
{
    80005d40:	7145                	addi	sp,sp,-464
    80005d42:	e786                	sd	ra,456(sp)
    80005d44:	e3a2                	sd	s0,448(sp)
    80005d46:	ff26                	sd	s1,440(sp)
    80005d48:	fb4a                	sd	s2,432(sp)
    80005d4a:	f74e                	sd	s3,424(sp)
    80005d4c:	f352                	sd	s4,416(sp)
    80005d4e:	ef56                	sd	s5,408(sp)
    80005d50:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d52:	08000613          	li	a2,128
    80005d56:	f4040593          	addi	a1,s0,-192
    80005d5a:	4501                	li	a0,0
    80005d5c:	ffffd097          	auipc	ra,0xffffd
    80005d60:	100080e7          	jalr	256(ra) # 80002e5c <argstr>
    return -1;
    80005d64:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d66:	0c054a63          	bltz	a0,80005e3a <sys_exec+0xfa>
    80005d6a:	e3840593          	addi	a1,s0,-456
    80005d6e:	4505                	li	a0,1
    80005d70:	ffffd097          	auipc	ra,0xffffd
    80005d74:	0ca080e7          	jalr	202(ra) # 80002e3a <argaddr>
    80005d78:	0c054163          	bltz	a0,80005e3a <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005d7c:	10000613          	li	a2,256
    80005d80:	4581                	li	a1,0
    80005d82:	e4040513          	addi	a0,s0,-448
    80005d86:	ffffb097          	auipc	ra,0xffffb
    80005d8a:	f52080e7          	jalr	-174(ra) # 80000cd8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005d8e:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005d92:	89a6                	mv	s3,s1
    80005d94:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005d96:	02000a13          	li	s4,32
    80005d9a:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005d9e:	00391793          	slli	a5,s2,0x3
    80005da2:	e3040593          	addi	a1,s0,-464
    80005da6:	e3843503          	ld	a0,-456(s0)
    80005daa:	953e                	add	a0,a0,a5
    80005dac:	ffffd097          	auipc	ra,0xffffd
    80005db0:	fd2080e7          	jalr	-46(ra) # 80002d7e <fetchaddr>
    80005db4:	02054a63          	bltz	a0,80005de8 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005db8:	e3043783          	ld	a5,-464(s0)
    80005dbc:	c3b9                	beqz	a5,80005e02 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005dbe:	ffffb097          	auipc	ra,0xffffb
    80005dc2:	d18080e7          	jalr	-744(ra) # 80000ad6 <kalloc>
    80005dc6:	85aa                	mv	a1,a0
    80005dc8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005dcc:	cd11                	beqz	a0,80005de8 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005dce:	6605                	lui	a2,0x1
    80005dd0:	e3043503          	ld	a0,-464(s0)
    80005dd4:	ffffd097          	auipc	ra,0xffffd
    80005dd8:	ffc080e7          	jalr	-4(ra) # 80002dd0 <fetchstr>
    80005ddc:	00054663          	bltz	a0,80005de8 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005de0:	0905                	addi	s2,s2,1
    80005de2:	09a1                	addi	s3,s3,8
    80005de4:	fb491be3          	bne	s2,s4,80005d9a <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005de8:	10048913          	addi	s2,s1,256
    80005dec:	6088                	ld	a0,0(s1)
    80005dee:	c529                	beqz	a0,80005e38 <sys_exec+0xf8>
    kfree(argv[i]);
    80005df0:	ffffb097          	auipc	ra,0xffffb
    80005df4:	bea080e7          	jalr	-1046(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005df8:	04a1                	addi	s1,s1,8
    80005dfa:	ff2499e3          	bne	s1,s2,80005dec <sys_exec+0xac>
  return -1;
    80005dfe:	597d                	li	s2,-1
    80005e00:	a82d                	j	80005e3a <sys_exec+0xfa>
      argv[i] = 0;
    80005e02:	0a8e                	slli	s5,s5,0x3
    80005e04:	fc040793          	addi	a5,s0,-64
    80005e08:	9abe                	add	s5,s5,a5
    80005e0a:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd0e80>
  int ret = exec(path, argv);
    80005e0e:	e4040593          	addi	a1,s0,-448
    80005e12:	f4040513          	addi	a0,s0,-192
    80005e16:	fffff097          	auipc	ra,0xfffff
    80005e1a:	156080e7          	jalr	342(ra) # 80004f6c <exec>
    80005e1e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e20:	10048993          	addi	s3,s1,256
    80005e24:	6088                	ld	a0,0(s1)
    80005e26:	c911                	beqz	a0,80005e3a <sys_exec+0xfa>
    kfree(argv[i]);
    80005e28:	ffffb097          	auipc	ra,0xffffb
    80005e2c:	bb2080e7          	jalr	-1102(ra) # 800009da <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e30:	04a1                	addi	s1,s1,8
    80005e32:	ff3499e3          	bne	s1,s3,80005e24 <sys_exec+0xe4>
    80005e36:	a011                	j	80005e3a <sys_exec+0xfa>
  return -1;
    80005e38:	597d                	li	s2,-1
}
    80005e3a:	854a                	mv	a0,s2
    80005e3c:	60be                	ld	ra,456(sp)
    80005e3e:	641e                	ld	s0,448(sp)
    80005e40:	74fa                	ld	s1,440(sp)
    80005e42:	795a                	ld	s2,432(sp)
    80005e44:	79ba                	ld	s3,424(sp)
    80005e46:	7a1a                	ld	s4,416(sp)
    80005e48:	6afa                	ld	s5,408(sp)
    80005e4a:	6179                	addi	sp,sp,464
    80005e4c:	8082                	ret

0000000080005e4e <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e4e:	7139                	addi	sp,sp,-64
    80005e50:	fc06                	sd	ra,56(sp)
    80005e52:	f822                	sd	s0,48(sp)
    80005e54:	f426                	sd	s1,40(sp)
    80005e56:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005e58:	ffffc097          	auipc	ra,0xffffc
    80005e5c:	b40080e7          	jalr	-1216(ra) # 80001998 <myproc>
    80005e60:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005e62:	fd840593          	addi	a1,s0,-40
    80005e66:	4501                	li	a0,0
    80005e68:	ffffd097          	auipc	ra,0xffffd
    80005e6c:	fd2080e7          	jalr	-46(ra) # 80002e3a <argaddr>
    return -1;
    80005e70:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005e72:	0e054063          	bltz	a0,80005f52 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005e76:	fc840593          	addi	a1,s0,-56
    80005e7a:	fd040513          	addi	a0,s0,-48
    80005e7e:	fffff097          	auipc	ra,0xfffff
    80005e82:	dc0080e7          	jalr	-576(ra) # 80004c3e <pipealloc>
    return -1;
    80005e86:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005e88:	0c054563          	bltz	a0,80005f52 <sys_pipe+0x104>
  fd0 = -1;
    80005e8c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005e90:	fd043503          	ld	a0,-48(s0)
    80005e94:	fffff097          	auipc	ra,0xfffff
    80005e98:	50a080e7          	jalr	1290(ra) # 8000539e <fdalloc>
    80005e9c:	fca42223          	sw	a0,-60(s0)
    80005ea0:	08054c63          	bltz	a0,80005f38 <sys_pipe+0xea>
    80005ea4:	fc843503          	ld	a0,-56(s0)
    80005ea8:	fffff097          	auipc	ra,0xfffff
    80005eac:	4f6080e7          	jalr	1270(ra) # 8000539e <fdalloc>
    80005eb0:	fca42023          	sw	a0,-64(s0)
    80005eb4:	06054863          	bltz	a0,80005f24 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005eb8:	4691                	li	a3,4
    80005eba:	fc440613          	addi	a2,s0,-60
    80005ebe:	fd843583          	ld	a1,-40(s0)
    80005ec2:	68a8                	ld	a0,80(s1)
    80005ec4:	ffffb097          	auipc	ra,0xffffb
    80005ec8:	794080e7          	jalr	1940(ra) # 80001658 <copyout>
    80005ecc:	02054063          	bltz	a0,80005eec <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005ed0:	4691                	li	a3,4
    80005ed2:	fc040613          	addi	a2,s0,-64
    80005ed6:	fd843583          	ld	a1,-40(s0)
    80005eda:	0591                	addi	a1,a1,4
    80005edc:	68a8                	ld	a0,80(s1)
    80005ede:	ffffb097          	auipc	ra,0xffffb
    80005ee2:	77a080e7          	jalr	1914(ra) # 80001658 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005ee6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ee8:	06055563          	bgez	a0,80005f52 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005eec:	fc442783          	lw	a5,-60(s0)
    80005ef0:	07e9                	addi	a5,a5,26
    80005ef2:	078e                	slli	a5,a5,0x3
    80005ef4:	97a6                	add	a5,a5,s1
    80005ef6:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005efa:	fc042503          	lw	a0,-64(s0)
    80005efe:	0569                	addi	a0,a0,26
    80005f00:	050e                	slli	a0,a0,0x3
    80005f02:	9526                	add	a0,a0,s1
    80005f04:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005f08:	fd043503          	ld	a0,-48(s0)
    80005f0c:	fffff097          	auipc	ra,0xfffff
    80005f10:	a02080e7          	jalr	-1534(ra) # 8000490e <fileclose>
    fileclose(wf);
    80005f14:	fc843503          	ld	a0,-56(s0)
    80005f18:	fffff097          	auipc	ra,0xfffff
    80005f1c:	9f6080e7          	jalr	-1546(ra) # 8000490e <fileclose>
    return -1;
    80005f20:	57fd                	li	a5,-1
    80005f22:	a805                	j	80005f52 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005f24:	fc442783          	lw	a5,-60(s0)
    80005f28:	0007c863          	bltz	a5,80005f38 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005f2c:	01a78513          	addi	a0,a5,26
    80005f30:	050e                	slli	a0,a0,0x3
    80005f32:	9526                	add	a0,a0,s1
    80005f34:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005f38:	fd043503          	ld	a0,-48(s0)
    80005f3c:	fffff097          	auipc	ra,0xfffff
    80005f40:	9d2080e7          	jalr	-1582(ra) # 8000490e <fileclose>
    fileclose(wf);
    80005f44:	fc843503          	ld	a0,-56(s0)
    80005f48:	fffff097          	auipc	ra,0xfffff
    80005f4c:	9c6080e7          	jalr	-1594(ra) # 8000490e <fileclose>
    return -1;
    80005f50:	57fd                	li	a5,-1
}
    80005f52:	853e                	mv	a0,a5
    80005f54:	70e2                	ld	ra,56(sp)
    80005f56:	7442                	ld	s0,48(sp)
    80005f58:	74a2                	ld	s1,40(sp)
    80005f5a:	6121                	addi	sp,sp,64
    80005f5c:	8082                	ret
	...

0000000080005f60 <kernelvec>:
    80005f60:	7111                	addi	sp,sp,-256
    80005f62:	e006                	sd	ra,0(sp)
    80005f64:	e40a                	sd	sp,8(sp)
    80005f66:	e80e                	sd	gp,16(sp)
    80005f68:	ec12                	sd	tp,24(sp)
    80005f6a:	f016                	sd	t0,32(sp)
    80005f6c:	f41a                	sd	t1,40(sp)
    80005f6e:	f81e                	sd	t2,48(sp)
    80005f70:	fc22                	sd	s0,56(sp)
    80005f72:	e0a6                	sd	s1,64(sp)
    80005f74:	e4aa                	sd	a0,72(sp)
    80005f76:	e8ae                	sd	a1,80(sp)
    80005f78:	ecb2                	sd	a2,88(sp)
    80005f7a:	f0b6                	sd	a3,96(sp)
    80005f7c:	f4ba                	sd	a4,104(sp)
    80005f7e:	f8be                	sd	a5,112(sp)
    80005f80:	fcc2                	sd	a6,120(sp)
    80005f82:	e146                	sd	a7,128(sp)
    80005f84:	e54a                	sd	s2,136(sp)
    80005f86:	e94e                	sd	s3,144(sp)
    80005f88:	ed52                	sd	s4,152(sp)
    80005f8a:	f156                	sd	s5,160(sp)
    80005f8c:	f55a                	sd	s6,168(sp)
    80005f8e:	f95e                	sd	s7,176(sp)
    80005f90:	fd62                	sd	s8,184(sp)
    80005f92:	e1e6                	sd	s9,192(sp)
    80005f94:	e5ea                	sd	s10,200(sp)
    80005f96:	e9ee                	sd	s11,208(sp)
    80005f98:	edf2                	sd	t3,216(sp)
    80005f9a:	f1f6                	sd	t4,224(sp)
    80005f9c:	f5fa                	sd	t5,232(sp)
    80005f9e:	f9fe                	sd	t6,240(sp)
    80005fa0:	cabfc0ef          	jal	ra,80002c4a <kerneltrap>
    80005fa4:	6082                	ld	ra,0(sp)
    80005fa6:	6122                	ld	sp,8(sp)
    80005fa8:	61c2                	ld	gp,16(sp)
    80005faa:	7282                	ld	t0,32(sp)
    80005fac:	7322                	ld	t1,40(sp)
    80005fae:	73c2                	ld	t2,48(sp)
    80005fb0:	7462                	ld	s0,56(sp)
    80005fb2:	6486                	ld	s1,64(sp)
    80005fb4:	6526                	ld	a0,72(sp)
    80005fb6:	65c6                	ld	a1,80(sp)
    80005fb8:	6666                	ld	a2,88(sp)
    80005fba:	7686                	ld	a3,96(sp)
    80005fbc:	7726                	ld	a4,104(sp)
    80005fbe:	77c6                	ld	a5,112(sp)
    80005fc0:	7866                	ld	a6,120(sp)
    80005fc2:	688a                	ld	a7,128(sp)
    80005fc4:	692a                	ld	s2,136(sp)
    80005fc6:	69ca                	ld	s3,144(sp)
    80005fc8:	6a6a                	ld	s4,152(sp)
    80005fca:	7a8a                	ld	s5,160(sp)
    80005fcc:	7b2a                	ld	s6,168(sp)
    80005fce:	7bca                	ld	s7,176(sp)
    80005fd0:	7c6a                	ld	s8,184(sp)
    80005fd2:	6c8e                	ld	s9,192(sp)
    80005fd4:	6d2e                	ld	s10,200(sp)
    80005fd6:	6dce                	ld	s11,208(sp)
    80005fd8:	6e6e                	ld	t3,216(sp)
    80005fda:	7e8e                	ld	t4,224(sp)
    80005fdc:	7f2e                	ld	t5,232(sp)
    80005fde:	7fce                	ld	t6,240(sp)
    80005fe0:	6111                	addi	sp,sp,256
    80005fe2:	10200073          	sret
    80005fe6:	00000013          	nop
    80005fea:	00000013          	nop
    80005fee:	0001                	nop

0000000080005ff0 <timervec>:
    80005ff0:	34051573          	csrrw	a0,mscratch,a0
    80005ff4:	e10c                	sd	a1,0(a0)
    80005ff6:	e510                	sd	a2,8(a0)
    80005ff8:	e914                	sd	a3,16(a0)
    80005ffa:	6d0c                	ld	a1,24(a0)
    80005ffc:	7110                	ld	a2,32(a0)
    80005ffe:	6194                	ld	a3,0(a1)
    80006000:	96b2                	add	a3,a3,a2
    80006002:	e194                	sd	a3,0(a1)
    80006004:	4589                	li	a1,2
    80006006:	14459073          	csrw	sip,a1
    8000600a:	6914                	ld	a3,16(a0)
    8000600c:	6510                	ld	a2,8(a0)
    8000600e:	610c                	ld	a1,0(a0)
    80006010:	34051573          	csrrw	a0,mscratch,a0
    80006014:	30200073          	mret
	...

000000008000601a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000601a:	1141                	addi	sp,sp,-16
    8000601c:	e422                	sd	s0,8(sp)
    8000601e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006020:	0c0007b7          	lui	a5,0xc000
    80006024:	4705                	li	a4,1
    80006026:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006028:	c3d8                	sw	a4,4(a5)
}
    8000602a:	6422                	ld	s0,8(sp)
    8000602c:	0141                	addi	sp,sp,16
    8000602e:	8082                	ret

0000000080006030 <plicinithart>:

void
plicinithart(void)
{
    80006030:	1141                	addi	sp,sp,-16
    80006032:	e406                	sd	ra,8(sp)
    80006034:	e022                	sd	s0,0(sp)
    80006036:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006038:	ffffc097          	auipc	ra,0xffffc
    8000603c:	934080e7          	jalr	-1740(ra) # 8000196c <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006040:	0085171b          	slliw	a4,a0,0x8
    80006044:	0c0027b7          	lui	a5,0xc002
    80006048:	97ba                	add	a5,a5,a4
    8000604a:	40200713          	li	a4,1026
    8000604e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006052:	00d5151b          	slliw	a0,a0,0xd
    80006056:	0c2017b7          	lui	a5,0xc201
    8000605a:	953e                	add	a0,a0,a5
    8000605c:	00052023          	sw	zero,0(a0)
}
    80006060:	60a2                	ld	ra,8(sp)
    80006062:	6402                	ld	s0,0(sp)
    80006064:	0141                	addi	sp,sp,16
    80006066:	8082                	ret

0000000080006068 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006068:	1141                	addi	sp,sp,-16
    8000606a:	e406                	sd	ra,8(sp)
    8000606c:	e022                	sd	s0,0(sp)
    8000606e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006070:	ffffc097          	auipc	ra,0xffffc
    80006074:	8fc080e7          	jalr	-1796(ra) # 8000196c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006078:	00d5179b          	slliw	a5,a0,0xd
    8000607c:	0c201537          	lui	a0,0xc201
    80006080:	953e                	add	a0,a0,a5
  return irq;
}
    80006082:	4148                	lw	a0,4(a0)
    80006084:	60a2                	ld	ra,8(sp)
    80006086:	6402                	ld	s0,0(sp)
    80006088:	0141                	addi	sp,sp,16
    8000608a:	8082                	ret

000000008000608c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000608c:	1101                	addi	sp,sp,-32
    8000608e:	ec06                	sd	ra,24(sp)
    80006090:	e822                	sd	s0,16(sp)
    80006092:	e426                	sd	s1,8(sp)
    80006094:	1000                	addi	s0,sp,32
    80006096:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006098:	ffffc097          	auipc	ra,0xffffc
    8000609c:	8d4080e7          	jalr	-1836(ra) # 8000196c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800060a0:	00d5151b          	slliw	a0,a0,0xd
    800060a4:	0c2017b7          	lui	a5,0xc201
    800060a8:	97aa                	add	a5,a5,a0
    800060aa:	c3c4                	sw	s1,4(a5)
}
    800060ac:	60e2                	ld	ra,24(sp)
    800060ae:	6442                	ld	s0,16(sp)
    800060b0:	64a2                	ld	s1,8(sp)
    800060b2:	6105                	addi	sp,sp,32
    800060b4:	8082                	ret

00000000800060b6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800060b6:	1141                	addi	sp,sp,-16
    800060b8:	e406                	sd	ra,8(sp)
    800060ba:	e022                	sd	s0,0(sp)
    800060bc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800060be:	479d                	li	a5,7
    800060c0:	06a7c963          	blt	a5,a0,80006132 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800060c4:	00025797          	auipc	a5,0x25
    800060c8:	f3c78793          	addi	a5,a5,-196 # 8002b000 <disk>
    800060cc:	00a78733          	add	a4,a5,a0
    800060d0:	6789                	lui	a5,0x2
    800060d2:	97ba                	add	a5,a5,a4
    800060d4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800060d8:	e7ad                	bnez	a5,80006142 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800060da:	00451793          	slli	a5,a0,0x4
    800060de:	00027717          	auipc	a4,0x27
    800060e2:	f2270713          	addi	a4,a4,-222 # 8002d000 <disk+0x2000>
    800060e6:	6314                	ld	a3,0(a4)
    800060e8:	96be                	add	a3,a3,a5
    800060ea:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800060ee:	6314                	ld	a3,0(a4)
    800060f0:	96be                	add	a3,a3,a5
    800060f2:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    800060f6:	6314                	ld	a3,0(a4)
    800060f8:	96be                	add	a3,a3,a5
    800060fa:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    800060fe:	6318                	ld	a4,0(a4)
    80006100:	97ba                	add	a5,a5,a4
    80006102:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006106:	00025797          	auipc	a5,0x25
    8000610a:	efa78793          	addi	a5,a5,-262 # 8002b000 <disk>
    8000610e:	97aa                	add	a5,a5,a0
    80006110:	6509                	lui	a0,0x2
    80006112:	953e                	add	a0,a0,a5
    80006114:	4785                	li	a5,1
    80006116:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000611a:	00027517          	auipc	a0,0x27
    8000611e:	efe50513          	addi	a0,a0,-258 # 8002d018 <disk+0x2018>
    80006122:	ffffc097          	auipc	ra,0xffffc
    80006126:	150080e7          	jalr	336(ra) # 80002272 <wakeup>
}
    8000612a:	60a2                	ld	ra,8(sp)
    8000612c:	6402                	ld	s0,0(sp)
    8000612e:	0141                	addi	sp,sp,16
    80006130:	8082                	ret
    panic("free_desc 1");
    80006132:	00002517          	auipc	a0,0x2
    80006136:	67e50513          	addi	a0,a0,1662 # 800087b0 <syscalls+0x338>
    8000613a:	ffffa097          	auipc	ra,0xffffa
    8000613e:	3f4080e7          	jalr	1012(ra) # 8000052e <panic>
    panic("free_desc 2");
    80006142:	00002517          	auipc	a0,0x2
    80006146:	67e50513          	addi	a0,a0,1662 # 800087c0 <syscalls+0x348>
    8000614a:	ffffa097          	auipc	ra,0xffffa
    8000614e:	3e4080e7          	jalr	996(ra) # 8000052e <panic>

0000000080006152 <virtio_disk_init>:
{
    80006152:	1101                	addi	sp,sp,-32
    80006154:	ec06                	sd	ra,24(sp)
    80006156:	e822                	sd	s0,16(sp)
    80006158:	e426                	sd	s1,8(sp)
    8000615a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000615c:	00002597          	auipc	a1,0x2
    80006160:	67458593          	addi	a1,a1,1652 # 800087d0 <syscalls+0x358>
    80006164:	00027517          	auipc	a0,0x27
    80006168:	fc450513          	addi	a0,a0,-60 # 8002d128 <disk+0x2128>
    8000616c:	ffffb097          	auipc	ra,0xffffb
    80006170:	9ca080e7          	jalr	-1590(ra) # 80000b36 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006174:	100017b7          	lui	a5,0x10001
    80006178:	4398                	lw	a4,0(a5)
    8000617a:	2701                	sext.w	a4,a4
    8000617c:	747277b7          	lui	a5,0x74727
    80006180:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006184:	0ef71163          	bne	a4,a5,80006266 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80006188:	100017b7          	lui	a5,0x10001
    8000618c:	43dc                	lw	a5,4(a5)
    8000618e:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006190:	4705                	li	a4,1
    80006192:	0ce79a63          	bne	a5,a4,80006266 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006196:	100017b7          	lui	a5,0x10001
    8000619a:	479c                	lw	a5,8(a5)
    8000619c:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    8000619e:	4709                	li	a4,2
    800061a0:	0ce79363          	bne	a5,a4,80006266 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800061a4:	100017b7          	lui	a5,0x10001
    800061a8:	47d8                	lw	a4,12(a5)
    800061aa:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061ac:	554d47b7          	lui	a5,0x554d4
    800061b0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800061b4:	0af71963          	bne	a4,a5,80006266 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061b8:	100017b7          	lui	a5,0x10001
    800061bc:	4705                	li	a4,1
    800061be:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061c0:	470d                	li	a4,3
    800061c2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800061c4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800061c6:	c7ffe737          	lui	a4,0xc7ffe
    800061ca:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd075f>
    800061ce:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061d0:	2701                	sext.w	a4,a4
    800061d2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061d4:	472d                	li	a4,11
    800061d6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061d8:	473d                	li	a4,15
    800061da:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800061dc:	6705                	lui	a4,0x1
    800061de:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800061e0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800061e4:	5bdc                	lw	a5,52(a5)
    800061e6:	2781                	sext.w	a5,a5
  if(max == 0)
    800061e8:	c7d9                	beqz	a5,80006276 <virtio_disk_init+0x124>
  if(max < NUM)
    800061ea:	471d                	li	a4,7
    800061ec:	08f77d63          	bgeu	a4,a5,80006286 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800061f0:	100014b7          	lui	s1,0x10001
    800061f4:	47a1                	li	a5,8
    800061f6:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    800061f8:	6609                	lui	a2,0x2
    800061fa:	4581                	li	a1,0
    800061fc:	00025517          	auipc	a0,0x25
    80006200:	e0450513          	addi	a0,a0,-508 # 8002b000 <disk>
    80006204:	ffffb097          	auipc	ra,0xffffb
    80006208:	ad4080e7          	jalr	-1324(ra) # 80000cd8 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000620c:	00025717          	auipc	a4,0x25
    80006210:	df470713          	addi	a4,a4,-524 # 8002b000 <disk>
    80006214:	00c75793          	srli	a5,a4,0xc
    80006218:	2781                	sext.w	a5,a5
    8000621a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000621c:	00027797          	auipc	a5,0x27
    80006220:	de478793          	addi	a5,a5,-540 # 8002d000 <disk+0x2000>
    80006224:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006226:	00025717          	auipc	a4,0x25
    8000622a:	e5a70713          	addi	a4,a4,-422 # 8002b080 <disk+0x80>
    8000622e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006230:	00026717          	auipc	a4,0x26
    80006234:	dd070713          	addi	a4,a4,-560 # 8002c000 <disk+0x1000>
    80006238:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000623a:	4705                	li	a4,1
    8000623c:	00e78c23          	sb	a4,24(a5)
    80006240:	00e78ca3          	sb	a4,25(a5)
    80006244:	00e78d23          	sb	a4,26(a5)
    80006248:	00e78da3          	sb	a4,27(a5)
    8000624c:	00e78e23          	sb	a4,28(a5)
    80006250:	00e78ea3          	sb	a4,29(a5)
    80006254:	00e78f23          	sb	a4,30(a5)
    80006258:	00e78fa3          	sb	a4,31(a5)
}
    8000625c:	60e2                	ld	ra,24(sp)
    8000625e:	6442                	ld	s0,16(sp)
    80006260:	64a2                	ld	s1,8(sp)
    80006262:	6105                	addi	sp,sp,32
    80006264:	8082                	ret
    panic("could not find virtio disk");
    80006266:	00002517          	auipc	a0,0x2
    8000626a:	57a50513          	addi	a0,a0,1402 # 800087e0 <syscalls+0x368>
    8000626e:	ffffa097          	auipc	ra,0xffffa
    80006272:	2c0080e7          	jalr	704(ra) # 8000052e <panic>
    panic("virtio disk has no queue 0");
    80006276:	00002517          	auipc	a0,0x2
    8000627a:	58a50513          	addi	a0,a0,1418 # 80008800 <syscalls+0x388>
    8000627e:	ffffa097          	auipc	ra,0xffffa
    80006282:	2b0080e7          	jalr	688(ra) # 8000052e <panic>
    panic("virtio disk max queue too short");
    80006286:	00002517          	auipc	a0,0x2
    8000628a:	59a50513          	addi	a0,a0,1434 # 80008820 <syscalls+0x3a8>
    8000628e:	ffffa097          	auipc	ra,0xffffa
    80006292:	2a0080e7          	jalr	672(ra) # 8000052e <panic>

0000000080006296 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006296:	7119                	addi	sp,sp,-128
    80006298:	fc86                	sd	ra,120(sp)
    8000629a:	f8a2                	sd	s0,112(sp)
    8000629c:	f4a6                	sd	s1,104(sp)
    8000629e:	f0ca                	sd	s2,96(sp)
    800062a0:	ecce                	sd	s3,88(sp)
    800062a2:	e8d2                	sd	s4,80(sp)
    800062a4:	e4d6                	sd	s5,72(sp)
    800062a6:	e0da                	sd	s6,64(sp)
    800062a8:	fc5e                	sd	s7,56(sp)
    800062aa:	f862                	sd	s8,48(sp)
    800062ac:	f466                	sd	s9,40(sp)
    800062ae:	f06a                	sd	s10,32(sp)
    800062b0:	ec6e                	sd	s11,24(sp)
    800062b2:	0100                	addi	s0,sp,128
    800062b4:	8aaa                	mv	s5,a0
    800062b6:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800062b8:	00c52c83          	lw	s9,12(a0)
    800062bc:	001c9c9b          	slliw	s9,s9,0x1
    800062c0:	1c82                	slli	s9,s9,0x20
    800062c2:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800062c6:	00027517          	auipc	a0,0x27
    800062ca:	e6250513          	addi	a0,a0,-414 # 8002d128 <disk+0x2128>
    800062ce:	ffffb097          	auipc	ra,0xffffb
    800062d2:	8f8080e7          	jalr	-1800(ra) # 80000bc6 <acquire>
  for(int i = 0; i < 3; i++){
    800062d6:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800062d8:	44a1                	li	s1,8
      disk.free[i] = 0;
    800062da:	00025c17          	auipc	s8,0x25
    800062de:	d26c0c13          	addi	s8,s8,-730 # 8002b000 <disk>
    800062e2:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    800062e4:	4b0d                	li	s6,3
    800062e6:	a0ad                	j	80006350 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    800062e8:	00fc0733          	add	a4,s8,a5
    800062ec:	975e                	add	a4,a4,s7
    800062ee:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800062f2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800062f4:	0207c563          	bltz	a5,8000631e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800062f8:	2905                	addiw	s2,s2,1
    800062fa:	0611                	addi	a2,a2,4
    800062fc:	19690d63          	beq	s2,s6,80006496 <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006300:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006302:	00027717          	auipc	a4,0x27
    80006306:	d1670713          	addi	a4,a4,-746 # 8002d018 <disk+0x2018>
    8000630a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000630c:	00074683          	lbu	a3,0(a4)
    80006310:	fee1                	bnez	a3,800062e8 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006312:	2785                	addiw	a5,a5,1
    80006314:	0705                	addi	a4,a4,1
    80006316:	fe979be3          	bne	a5,s1,8000630c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000631a:	57fd                	li	a5,-1
    8000631c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000631e:	01205d63          	blez	s2,80006338 <virtio_disk_rw+0xa2>
    80006322:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006324:	000a2503          	lw	a0,0(s4)
    80006328:	00000097          	auipc	ra,0x0
    8000632c:	d8e080e7          	jalr	-626(ra) # 800060b6 <free_desc>
      for(int j = 0; j < i; j++)
    80006330:	2d85                	addiw	s11,s11,1
    80006332:	0a11                	addi	s4,s4,4
    80006334:	ffb918e3          	bne	s2,s11,80006324 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006338:	00027597          	auipc	a1,0x27
    8000633c:	df058593          	addi	a1,a1,-528 # 8002d128 <disk+0x2128>
    80006340:	00027517          	auipc	a0,0x27
    80006344:	cd850513          	addi	a0,a0,-808 # 8002d018 <disk+0x2018>
    80006348:	ffffc097          	auipc	ra,0xffffc
    8000634c:	d9c080e7          	jalr	-612(ra) # 800020e4 <sleep>
  for(int i = 0; i < 3; i++){
    80006350:	f8040a13          	addi	s4,s0,-128
{
    80006354:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006356:	894e                	mv	s2,s3
    80006358:	b765                	j	80006300 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000635a:	00027697          	auipc	a3,0x27
    8000635e:	ca66b683          	ld	a3,-858(a3) # 8002d000 <disk+0x2000>
    80006362:	96ba                	add	a3,a3,a4
    80006364:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006368:	00025817          	auipc	a6,0x25
    8000636c:	c9880813          	addi	a6,a6,-872 # 8002b000 <disk>
    80006370:	00027697          	auipc	a3,0x27
    80006374:	c9068693          	addi	a3,a3,-880 # 8002d000 <disk+0x2000>
    80006378:	6290                	ld	a2,0(a3)
    8000637a:	963a                	add	a2,a2,a4
    8000637c:	00c65583          	lhu	a1,12(a2) # 200c <_entry-0x7fffdff4>
    80006380:	0015e593          	ori	a1,a1,1
    80006384:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[1]].next = idx[2];
    80006388:	f8842603          	lw	a2,-120(s0)
    8000638c:	628c                	ld	a1,0(a3)
    8000638e:	972e                	add	a4,a4,a1
    80006390:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006394:	20050593          	addi	a1,a0,512
    80006398:	0592                	slli	a1,a1,0x4
    8000639a:	95c2                	add	a1,a1,a6
    8000639c:	577d                	li	a4,-1
    8000639e:	02e58823          	sb	a4,48(a1)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800063a2:	00461713          	slli	a4,a2,0x4
    800063a6:	6290                	ld	a2,0(a3)
    800063a8:	963a                	add	a2,a2,a4
    800063aa:	03078793          	addi	a5,a5,48
    800063ae:	97c2                	add	a5,a5,a6
    800063b0:	e21c                	sd	a5,0(a2)
  disk.desc[idx[2]].len = 1;
    800063b2:	629c                	ld	a5,0(a3)
    800063b4:	97ba                	add	a5,a5,a4
    800063b6:	4605                	li	a2,1
    800063b8:	c790                	sw	a2,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800063ba:	629c                	ld	a5,0(a3)
    800063bc:	97ba                	add	a5,a5,a4
    800063be:	4809                	li	a6,2
    800063c0:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    800063c4:	629c                	ld	a5,0(a3)
    800063c6:	973e                	add	a4,a4,a5
    800063c8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800063cc:	00caa223          	sw	a2,4(s5)
  disk.info[idx[0]].b = b;
    800063d0:	0355b423          	sd	s5,40(a1)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800063d4:	6698                	ld	a4,8(a3)
    800063d6:	00275783          	lhu	a5,2(a4)
    800063da:	8b9d                	andi	a5,a5,7
    800063dc:	0786                	slli	a5,a5,0x1
    800063de:	97ba                	add	a5,a5,a4
    800063e0:	00a79223          	sh	a0,4(a5)

  __sync_synchronize();
    800063e4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800063e8:	6698                	ld	a4,8(a3)
    800063ea:	00275783          	lhu	a5,2(a4)
    800063ee:	2785                	addiw	a5,a5,1
    800063f0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800063f4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800063f8:	100017b7          	lui	a5,0x10001
    800063fc:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006400:	004aa783          	lw	a5,4(s5)
    80006404:	02c79163          	bne	a5,a2,80006426 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    80006408:	00027917          	auipc	s2,0x27
    8000640c:	d2090913          	addi	s2,s2,-736 # 8002d128 <disk+0x2128>
  while(b->disk == 1) {
    80006410:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006412:	85ca                	mv	a1,s2
    80006414:	8556                	mv	a0,s5
    80006416:	ffffc097          	auipc	ra,0xffffc
    8000641a:	cce080e7          	jalr	-818(ra) # 800020e4 <sleep>
  while(b->disk == 1) {
    8000641e:	004aa783          	lw	a5,4(s5)
    80006422:	fe9788e3          	beq	a5,s1,80006412 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006426:	f8042903          	lw	s2,-128(s0)
    8000642a:	20090793          	addi	a5,s2,512
    8000642e:	00479713          	slli	a4,a5,0x4
    80006432:	00025797          	auipc	a5,0x25
    80006436:	bce78793          	addi	a5,a5,-1074 # 8002b000 <disk>
    8000643a:	97ba                	add	a5,a5,a4
    8000643c:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80006440:	00027997          	auipc	s3,0x27
    80006444:	bc098993          	addi	s3,s3,-1088 # 8002d000 <disk+0x2000>
    80006448:	00491713          	slli	a4,s2,0x4
    8000644c:	0009b783          	ld	a5,0(s3)
    80006450:	97ba                	add	a5,a5,a4
    80006452:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006456:	854a                	mv	a0,s2
    80006458:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000645c:	00000097          	auipc	ra,0x0
    80006460:	c5a080e7          	jalr	-934(ra) # 800060b6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006464:	8885                	andi	s1,s1,1
    80006466:	f0ed                	bnez	s1,80006448 <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006468:	00027517          	auipc	a0,0x27
    8000646c:	cc050513          	addi	a0,a0,-832 # 8002d128 <disk+0x2128>
    80006470:	ffffb097          	auipc	ra,0xffffb
    80006474:	820080e7          	jalr	-2016(ra) # 80000c90 <release>
}
    80006478:	70e6                	ld	ra,120(sp)
    8000647a:	7446                	ld	s0,112(sp)
    8000647c:	74a6                	ld	s1,104(sp)
    8000647e:	7906                	ld	s2,96(sp)
    80006480:	69e6                	ld	s3,88(sp)
    80006482:	6a46                	ld	s4,80(sp)
    80006484:	6aa6                	ld	s5,72(sp)
    80006486:	6b06                	ld	s6,64(sp)
    80006488:	7be2                	ld	s7,56(sp)
    8000648a:	7c42                	ld	s8,48(sp)
    8000648c:	7ca2                	ld	s9,40(sp)
    8000648e:	7d02                	ld	s10,32(sp)
    80006490:	6de2                	ld	s11,24(sp)
    80006492:	6109                	addi	sp,sp,128
    80006494:	8082                	ret
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006496:	f8042503          	lw	a0,-128(s0)
    8000649a:	20050793          	addi	a5,a0,512
    8000649e:	0792                	slli	a5,a5,0x4
  if(write)
    800064a0:	00025817          	auipc	a6,0x25
    800064a4:	b6080813          	addi	a6,a6,-1184 # 8002b000 <disk>
    800064a8:	00f80733          	add	a4,a6,a5
    800064ac:	01a036b3          	snez	a3,s10
    800064b0:	0ad72423          	sw	a3,168(a4)
  buf0->reserved = 0;
    800064b4:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800064b8:	0b973823          	sd	s9,176(a4)
  disk.desc[idx[0]].addr = (uint64) buf0;
    800064bc:	7679                	lui	a2,0xffffe
    800064be:	963e                	add	a2,a2,a5
    800064c0:	00027697          	auipc	a3,0x27
    800064c4:	b4068693          	addi	a3,a3,-1216 # 8002d000 <disk+0x2000>
    800064c8:	6298                	ld	a4,0(a3)
    800064ca:	9732                	add	a4,a4,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800064cc:	0a878593          	addi	a1,a5,168
    800064d0:	95c2                	add	a1,a1,a6
  disk.desc[idx[0]].addr = (uint64) buf0;
    800064d2:	e30c                	sd	a1,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800064d4:	6298                	ld	a4,0(a3)
    800064d6:	9732                	add	a4,a4,a2
    800064d8:	45c1                	li	a1,16
    800064da:	c70c                	sw	a1,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800064dc:	6298                	ld	a4,0(a3)
    800064de:	9732                	add	a4,a4,a2
    800064e0:	4585                	li	a1,1
    800064e2:	00b71623          	sh	a1,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800064e6:	f8442703          	lw	a4,-124(s0)
    800064ea:	628c                	ld	a1,0(a3)
    800064ec:	962e                	add	a2,a2,a1
    800064ee:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd000e>
  disk.desc[idx[1]].addr = (uint64) b->data;
    800064f2:	0712                	slli	a4,a4,0x4
    800064f4:	6290                	ld	a2,0(a3)
    800064f6:	963a                	add	a2,a2,a4
    800064f8:	058a8593          	addi	a1,s5,88
    800064fc:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800064fe:	6294                	ld	a3,0(a3)
    80006500:	96ba                	add	a3,a3,a4
    80006502:	40000613          	li	a2,1024
    80006506:	c690                	sw	a2,8(a3)
  if(write)
    80006508:	e40d19e3          	bnez	s10,8000635a <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000650c:	00027697          	auipc	a3,0x27
    80006510:	af46b683          	ld	a3,-1292(a3) # 8002d000 <disk+0x2000>
    80006514:	96ba                	add	a3,a3,a4
    80006516:	4609                	li	a2,2
    80006518:	00c69623          	sh	a2,12(a3)
    8000651c:	b5b1                	j	80006368 <virtio_disk_rw+0xd2>

000000008000651e <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000651e:	1101                	addi	sp,sp,-32
    80006520:	ec06                	sd	ra,24(sp)
    80006522:	e822                	sd	s0,16(sp)
    80006524:	e426                	sd	s1,8(sp)
    80006526:	e04a                	sd	s2,0(sp)
    80006528:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000652a:	00027517          	auipc	a0,0x27
    8000652e:	bfe50513          	addi	a0,a0,-1026 # 8002d128 <disk+0x2128>
    80006532:	ffffa097          	auipc	ra,0xffffa
    80006536:	694080e7          	jalr	1684(ra) # 80000bc6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000653a:	10001737          	lui	a4,0x10001
    8000653e:	533c                	lw	a5,96(a4)
    80006540:	8b8d                	andi	a5,a5,3
    80006542:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006544:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006548:	00027797          	auipc	a5,0x27
    8000654c:	ab878793          	addi	a5,a5,-1352 # 8002d000 <disk+0x2000>
    80006550:	6b94                	ld	a3,16(a5)
    80006552:	0207d703          	lhu	a4,32(a5)
    80006556:	0026d783          	lhu	a5,2(a3)
    8000655a:	06f70163          	beq	a4,a5,800065bc <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    8000655e:	00025917          	auipc	s2,0x25
    80006562:	aa290913          	addi	s2,s2,-1374 # 8002b000 <disk>
    80006566:	00027497          	auipc	s1,0x27
    8000656a:	a9a48493          	addi	s1,s1,-1382 # 8002d000 <disk+0x2000>
    __sync_synchronize();
    8000656e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006572:	6898                	ld	a4,16(s1)
    80006574:	0204d783          	lhu	a5,32(s1)
    80006578:	8b9d                	andi	a5,a5,7
    8000657a:	078e                	slli	a5,a5,0x3
    8000657c:	97ba                	add	a5,a5,a4
    8000657e:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006580:	20078713          	addi	a4,a5,512
    80006584:	0712                	slli	a4,a4,0x4
    80006586:	974a                	add	a4,a4,s2
    80006588:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    8000658c:	e731                	bnez	a4,800065d8 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    8000658e:	20078793          	addi	a5,a5,512
    80006592:	0792                	slli	a5,a5,0x4
    80006594:	97ca                	add	a5,a5,s2
    80006596:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006598:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000659c:	ffffc097          	auipc	ra,0xffffc
    800065a0:	cd6080e7          	jalr	-810(ra) # 80002272 <wakeup>

    disk.used_idx += 1;
    800065a4:	0204d783          	lhu	a5,32(s1)
    800065a8:	2785                	addiw	a5,a5,1
    800065aa:	17c2                	slli	a5,a5,0x30
    800065ac:	93c1                	srli	a5,a5,0x30
    800065ae:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800065b2:	6898                	ld	a4,16(s1)
    800065b4:	00275703          	lhu	a4,2(a4)
    800065b8:	faf71be3          	bne	a4,a5,8000656e <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800065bc:	00027517          	auipc	a0,0x27
    800065c0:	b6c50513          	addi	a0,a0,-1172 # 8002d128 <disk+0x2128>
    800065c4:	ffffa097          	auipc	ra,0xffffa
    800065c8:	6cc080e7          	jalr	1740(ra) # 80000c90 <release>
}
    800065cc:	60e2                	ld	ra,24(sp)
    800065ce:	6442                	ld	s0,16(sp)
    800065d0:	64a2                	ld	s1,8(sp)
    800065d2:	6902                	ld	s2,0(sp)
    800065d4:	6105                	addi	sp,sp,32
    800065d6:	8082                	ret
      panic("virtio_disk_intr status");
    800065d8:	00002517          	auipc	a0,0x2
    800065dc:	26850513          	addi	a0,a0,616 # 80008840 <syscalls+0x3c8>
    800065e0:	ffffa097          	auipc	ra,0xffffa
    800065e4:	f4e080e7          	jalr	-178(ra) # 8000052e <panic>
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
